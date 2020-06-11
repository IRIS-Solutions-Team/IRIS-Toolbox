'use strict';

// utility methods
var $ru = {
  createChart: createChart,
  createSeries: createSeries,
  createChartForChartJs: createChartForChartJs,
  createSeriesForChartJs: createSeriesForChartJs,
  createChartForPlotly: createChartForPlotly,
  createSeriesForPlotly: createSeriesForPlotly,
  freqToUnit: freqToMomentJsUnit,
  createTable: createTable,
  createGrid: createGrid,
  addReportElement: addReportElement,
  getColorList: getColorList,
  addPageBreak: addPageBreak,
  createTextBlock: createTextBlock,
  appendObjSettings: appendObjSettings,
  databank: {
    getEntry: getEntry,
    getEntryName: getEntryName,
    getSeriesContent: getSeriesContent,

  }
};

const DEFAULT_CHART_LIBRARY = "plotly";
const DEFAULT_HIGHLIGHT_COLOR = "rgba(100, 100, 100, 0.2)";

// generic function preparing the chart area and calling the implementation
// specific for the chosen ChartLibrary
function createChart(parent, chartObj) {
  const chartLib = chartObj.Settings.ChartLibrary || DEFAULT_CHART_LIBRARY;
  var chartParent = document.createElement("div");
  $(chartParent).addClass("rephrase-chart");
  // apply custom css class to .rephrase-chart div
  if (chartObj.Settings.Class && (typeof chartObj.Settings.Class === "string"
    || chartObj.Settings.Class instanceof Array)) {
    $(chartParent).addClass(chartObj.Settings.Class);
  }
  parent.appendChild(chartParent);
  // whether to include title in canvas or make it a separate div
  const titleOutOfCanvas = (chartObj.Settings.hasOwnProperty("IsTitlePartOfChart") && !chartObj.Settings.IsTitlePartOfChart);
  // create chart title
  const chartTitle = chartObj.Title || "";
  if (chartTitle && titleOutOfCanvas) {
    var chartTitleDiv = document.createElement("div");
    $(chartTitleDiv).addClass(["rephrase-chart-title", "h4"]);
    chartTitleDiv.innerText = chartTitle;
    chartParent.appendChild(chartTitleDiv);
  }
  // generate data for the chart
  var data = [];
  const limits = {
    min: chartObj.Settings.StartDate ? new Date(chartObj.Settings.StartDate) : null,
    max: chartObj.Settings.EndDate ? new Date(chartObj.Settings.EndDate) : null
  };
  if (chartObj.hasOwnProperty("Content") && chartObj.Content instanceof Array) {
    const colorList = $ru.getColorList(chartObj.Content.length);
    for (var i = 0; i < chartObj.Content.length; i++) {
      const seriesObj = chartObj.Content[i];
      data.push($ru.createSeries(seriesObj, limits, colorList[i], chartLib));
    }
  }
  const interactive = (!chartObj.Settings.hasOwnProperty("InteractiveCharts"))
    ? true
    : chartObj.Settings.InteractiveCharts;
  const chartBody = (chartLib.toLowerCase() === "chartjs")
    ? $ru.createChartForChartJs(chartTitle, data, titleOutOfCanvas, limits, chartObj.Settings.DateFormat, chartObj.Settings.Highlight || [])
    : $ru.createChartForPlotly(chartTitle, data, titleOutOfCanvas, limits, chartObj.Settings.DateFormat, chartObj.Settings.Highlight || [], interactive);
  chartParent.appendChild(chartBody);
}

function createSeries(seriesObj, limits, color, chartLib) {
  // return empty object if smth. is wrong
  if (!seriesObj || !(typeof seriesObj === "object") || !seriesObj.hasOwnProperty("Type")
    || seriesObj.Type.toLowerCase() !== "series" || !seriesObj.hasOwnProperty("Content")
    || !((typeof seriesObj.Content === "string")
      || (typeof seriesObj.Content === "object"
        && seriesObj.Content.hasOwnProperty("Dates")
        && seriesObj.Content.hasOwnProperty("Values")))) {
    return {};
  }
  if (typeof seriesObj.Content === "string") {
    seriesObj.Content = $ru.databank.getSeriesContent(seriesObj.Content);
  } else {
    seriesObj.Content.Dates = seriesObj.Content.Dates.map(function (d) {
      return new Date(d);
    });
  }
  const overrideColor = (seriesObj.hasOwnProperty("Settings") && (typeof seriesObj.Settings === "object")
    && seriesObj.Settings.hasOwnProperty("Color")) ? seriesObj.Settings.Color : null;
  const colors = {
    barFaceColor: (overrideColor || color).replace(/,\s*\d*\.?\d+\)$/, ",0.2)"),
    barBorderColor: overrideColor || color,
    lineColor: overrideColor || color
  }
  switch (chartLib.toLowerCase()) {
    case "chartjs":
      return $ru.createSeriesForChartJs(seriesObj.Title, seriesObj.Content.Dates, seriesObj.Content.Values, seriesObj.Settings.Type, colors, limits);
    case "plotly":
    default:
      return $ru.createSeriesForPlotly(seriesObj.Title, seriesObj.Content.Dates, seriesObj.Content.Values, seriesObj.Settings.Type, colors);
  }
}

// fetch an object stored in the global $databank variable under the given name
function getEntry(name) {
  if ($databank && typeof $databank === "object" && $databank.hasOwnProperty(name)) {
    return $databank[name];
  }
  return {};
}

// fetch an object stored in the global $databank variable under the given name
function getEntryName(name) {
  const dataObj = getEntry(name);
  return dataObj.Name || "";
}

// fetch the series from $databank reconstructing all the dates
function getSeriesContent(name) {
  const dataObj = getEntry(name);
  if (dataObj && typeof dataObj === "object" && dataObj.hasOwnProperty("Values")
    && (dataObj.Values instanceof Array) && dataObj.hasOwnProperty("Dates")) {
    var dates = [];
    if (dataObj.Dates instanceof Array) {
      dates = dataObj.Dates.map(function (d) {
        return new Date(d);
      });
    } else {
      const freqUnit = $ru.freqToUnit(dataObj.Frequency);
      const startDate = new Date(dataObj.Dates);
      for (var i = 0; i < dataObj.Values.length; i++) {
        dates.push(moment(startDate).add(i, freqUnit).toDate());
      }
    }
    return { Values: dataObj.Values, Dates: dates };
  }
  return {};
}

// add div that would force page break when printing
function addPageBreak(parent, breakObj) {
  var pageBreakDiv = document.createElement("div");
  $(pageBreakDiv).addClass("page-break");
  pageBreakDiv.innerHTML = "&nbsp;";
  parent.appendChild(pageBreakDiv);
}

// create chart elements using Chart.js library
function createChartForChartJs(chartTitle, data, titleOutOfCanvas, limits, dateFormat, highlight) {
  var canvas = document.createElement("canvas");
  $(canvas).addClass("rephrase-chart-body");
  // draw chart in canvas
  Chart.defaults.global.defaultFontFamily = 'Lato';
  const chartConfig = {
    type: 'line',
    data: {
      datasets: data
    },
    options: {
      title: {
        display: chartTitle !== "" && !titleOutOfCanvas,
        text: chartTitle,
        fontFamily: 'Lato',
        fontSize: 20,
        fontStyle: '300',
        fontColor: '#0a0a0a'
      },
      tooltips: {
        intersect: false,
        mode: 'x',
        callbacks: {
          label: function (tooltipItem, data) {
            var label = data.datasets[tooltipItem.datasetIndex].label || '';
            if (label) {
              label += ': ';
            }
            label += Math.round(tooltipItem.yLabel * 1000) / 1000;
            return label;
          }
        }
      },
      aspectRatio: 1.5,
      maintainAspectRatio: true,
      scales: {
        xAxes: [{
          id: 'x-axis',
          type: 'time',
          distribution: 'series',
          ticks: {
            min: limits.min,
            max: limits.max,
            callback: function (d) {
              return moment(d).format(dateFormat);
            }
          },
          time: {
            minUnit: 'day',
            tooltipFormat: dateFormat
          }
        }]
      }
    }
  };
  // add range highlighting if needed so
  if (highlight && highlight instanceof Array && highlight.length > 0) {
    chartConfig.options.annotation = {
      drawTime: 'beforeDatasetsDraw',
      annotations: []
    };
    for (let i = 0; i < highlight.length; i++) {
      const hConfig = highlight[i];
      chartConfig.options.annotation.annotations.push({
        id: 'highlight-' + i,
        type: 'box',
        xScaleID: 'x-axis',
        xMin: hConfig.StartDate ? new Date(hConfig.StartDate) : undefined,
        xMax: hConfig.EndDate ? new Date(hConfig.EndDate) : undefined,
        backgroundColor: hConfig.Color || DEFAULT_HIGHLIGHT_COLOR,
        borderColor: hConfig.Color || DEFAULT_HIGHLIGHT_COLOR,
      });
    }
  }
  new Chart(canvas, chartConfig);
  return canvas;
}

// create series object for Chart.js chart
function createSeriesForChartJs(title, dates, values, seriesType, colors, limits) {
  var tsData = [];
  for (var i = 0; i < values.length; i++) {
    const thisDate = dates[i];
    if ((limits.min && thisDate < limits.min) || (limits.max && thisDate > limits.max)) {
      continue;
    }
    tsData.push({
      x: thisDate,
      y: values[i]
    });
  }
  const seriesPlotType = seriesType || "line";
  var seriesObj = {
    data: tsData,
    label: title || "",
    type: seriesPlotType.toLowerCase()
  };
  if (seriesObj.type === "bar") {
    seriesObj.borderWidth = 1;
    seriesObj.borderColor = colors.barBorderColor;
    seriesObj.backgroundColor = colors.barFaceColor;
  } else {
    seriesObj.lineTension = 0;
    seriesObj.fill = false;
    seriesObj.borderColor = colors.lineColor;
    seriesObj.backgroundColor = colors.lineColor;
  }
  return seriesObj;
}


// create chart elements using Plotly library
function createChartForPlotly(chartTitle, data, titleOutOfCanvas, limits, dateFormat, highlight, interactive) {
  var chartBody = document.createElement("div");
  $(chartBody).addClass("rephrase-chart-body");
  const layout = {
    title: {
      text: chartTitle !== "" && !titleOutOfCanvas ? chartTitle : undefined,
      font: {
        size: 20,
        family: "Lato",
        color: "#0a0a0a"
      }
    },
    font: {
      family: "Lato",
      color: "#0a0a0a"
    },
    xaxis: {
      range: [limits.min, limits.max],
      type: 'date'
    },
    yaxis: {
      autorange: true,
      type: 'linear'
    },
    legend: {
      x: 0.5,
      y: 1,
      xanchor: "center",
      yanchor: "bottom",
      orientation: "h"
    }
  };
  if (titleOutOfCanvas) {
    layout.margin = {
      l: 50,
      r: 50,
      b: 30,
      t: 10,
      pad: 4
    };
  }
  const config = {
    responsive: true,
    staticPlot: !interactive
  };
  // add range highlighting if needed so
  if (highlight && highlight instanceof Array && highlight.length > 0) {
    layout.shapes = [];
    for (let i = 0; i < highlight.length; i++) {
      const hConfig = highlight[i];
      layout.shapes.push(
        {
          type: 'rect',
          // x-reference is assigned to the x-values
          xref: 'x',
          // y-reference is assigned to the plot paper [0,1]
          yref: 'paper',
          x0: hConfig.StartDate ? new Date(hConfig.StartDate) : limits.min,
          y0: 0,
          x1: hConfig.EndDate ? new Date(hConfig.EndDate) : limits.max,
          y1: 1,
          fillcolor: hConfig.Color || DEFAULT_HIGHLIGHT_COLOR,
          // opacity: 0.2,
          line: {
            width: 0
          }
        });
    }
  }
  // we are adding charts only after document is ready
  // because it (1) makes the browser open quicker (almost immediately 
  // even for the huge reports), and (2) the widths of DIV containers 
  // of the charts is not 100% known before document is ready (that's how
  //  "cell auto" of XY grid behaves)
  $(document).ready(function () {
    Plotly.newPlot(chartBody, data, layout, config);
  });

  // make sure chart resizes correctly before printing
  const resizeChartWidth = function () {
    var bBox = chartBody.getBoundingClientRect();
    Plotly.relayout(chartBody, { width: bBox.width, height: bBox.height });
  };

  if (window.matchMedia) { // Webkit
    window.matchMedia('print').addListener(function (print) {
      if (print.matches) {
        resizeChartWidth();
      } else {
        Plotly.relayout(chartBody, { width: null, height: null, autosize: true })
      }
    });
  }
  window.onbeforeprint = resizeChartWidth; // FF, IE

  return chartBody;
}

// create series object for Plotly chart
function createSeriesForPlotly(title, dates, values, seriesType, colors) {
  const seriesPlotType = seriesType || "scatter";
  var seriesObj = {
    x: dates,
    y: values,
    name: title || "",
    type: seriesPlotType.toLowerCase()
  };
  if (seriesObj.type === "bar") {
    seriesObj.marker = {
      color: colors.barFaceColor,
      line: {
        color: colors.barBorderColor,
        width: 1
      }
    }
  } else {
    seriesObj.marker = {
      line: {
        color: colors.lineColor
      }
    }
  }
  return seriesObj;
}

function createTextBlock(parent, textObj) {
  var textParent = document.createElement("div");
  $(textParent).addClass("rephrase-text-block");
  // apply custom css class to .rephrase-text-block div
  if (textObj.Settings.Class && (typeof textObj.Settings.Class === "string"
    || textObj.Settings.Class instanceof Array)) {
    $(textParent).addClass(textObj.Settings.Class);
  }
  parent.appendChild(textParent);
  // create title
  if (textObj.Title) {
    var textTitle = document.createElement("h2");
    $(textTitle).addClass("rephrase-text-block-title");
    textTitle.innerText = textObj.Title;
    textParent.appendChild(textTitle);
  }
  // create content
  if (textObj.Content && (typeof textObj.Content === "string")) {
    var textContent = document.createElement("div");
    $(textContent).addClass("rephrase-text-block-body");
    if (textObj.Settings.HighlightCodeBlocks) {
      const renderer = new marked.Renderer();
      renderer.code = function (code, lang) {
        const validLang = hljs.getLanguage(lang) ? lang : 'plaintext';
        return "<pre><code class=\"hljs"
          + (validLang ? " language-" + validLang : "")
          + "\">" + hljs.highlight(validLang, code).value
          + "</code></pre>";
      }
      marked.setOptions({
        renderer: renderer
      });
    }
    textContent.innerHTML = marked(textObj.Content);
    textParent.appendChild(textContent);
    if (textObj.Settings.ParseFormulas) {
      window.renderMathInElement(textContent, {
        // no options so far
      });
    }
  }

}

// convert frequency letter to Chart.js time unit
function freqToMomentJsUnit(freq) {
  var unit = "";
  switch (freq) {
    case 365:
      unit = "day";
      break;
    case 52:
      unit = "week";
      break;
    case 12:
      unit = "month";
      break;
    case 4:
      unit = "quarter";
      break;
    case 1:
      unit = "year";
      break;
    default:
      unit = "";
  }
  return unit;
}

function getColorList(nColors) {
  const defaultColorList = [
    'rgba(0, 114, 189, 1)',
    'rgba(217, 83, 25, 1)',
    'rgba(237, 177, 32, 1)',
    'rgba(126, 47, 142, 1)',
    'rgba(119, 172, 48, 1)',
    'rgba(77, 190, 238, 1)',
    'rgba(162, 20, 47, 1)'
  ];
  const nDefaults = defaultColorList.length;
  var colorList = [];
  for (var i = 0; i < nColors; i++) {
    colorList.push(defaultColorList[i % nDefaults]);

  }
  return colorList;
}

function createTable(parent, tableObj) {
  // create a div to wrap the table
  var tableParent = document.createElement("div");
  $(tableParent).addClass(["rephrase-table-parent", "table-scroll"]);
  parent.appendChild(tableParent);
  // create table title
  if (tableObj.Title) {
    var tableTitle = document.createElement("h3");
    $(tableTitle).addClass("rephrase-table-title");
    tableTitle.innerText = tableObj.Title;
  }
  tableParent.appendChild(tableTitle);
  var table = document.createElement("table");
  $(table).addClass(["rephrase-table", "hover", "unstriped"]);
  // apply custom css class to .rephrase-chart div
  if (tableObj.Settings.Class && (typeof tableObj.Settings.Class === "string"
    || tableObj.Settings.Class instanceof Array)) {
    $(table).addClass(tableObj.Settings.Class);
  }
  tableParent.appendChild(table);
  // initiate table header and body
  var thead = document.createElement("thead");
  $(thead).addClass('rephrase-table-header');
  table.appendChild(thead);
  var theadRow = document.createElement("tr");
  $(theadRow).addClass('rephrase-table-header-row');
  thead.appendChild(theadRow);
  var tbody = document.createElement("tbody");
  $(tbody).addClass('rephrase-table-body');
  table.appendChild(tbody);
  // create title column in header
  var theadFirstCell = document.createElement("th");
  $(theadFirstCell).addClass('rephrase-table-header-cell');
  theadRow.appendChild(theadFirstCell);
  // re-format the date string and populate table header
  const dates = tableObj.Settings.Dates.map(function (d) {
    const t = moment(new Date(d)).format(tableObj.Settings.DateFormat);
    var theadDateCell = document.createElement("th");
    $(theadDateCell).addClass('rephrase-table-header-cell');
    theadDateCell.innerText = t;
    theadRow.appendChild(theadDateCell);
    return t;
  });
  // number of decimals when showing numbers
  const nDecimals = tableObj.Settings.NumDecimals || 2;
  // populate table body
  for (var i = 0; i < tableObj.Content.length; i++) {
    const tableRowObj = tableObj.Content[i];
    // skip this entry if it's neither a SERIES nor HEADING or if smth. else is wrong
    if (!tableRowObj.hasOwnProperty("Type")
      || ["series", "heading"].indexOf(tableRowObj.Type.toLowerCase()) === -1
      || (tableRowObj.Type.toLowerCase() === "series"
        && (!tableRowObj.hasOwnProperty("Content")
          || !((typeof tableRowObj.Content === "string")
            || (typeof tableRowObj.Content === "object"
              && tableRowObj.Content.hasOwnProperty("Dates")
              && tableRowObj.Content.hasOwnProperty("Values")
              && (dates instanceof Array)
              && tableRowObj.Content.Values.length === dates.length))))) {
      continue;
    }
    const isSeries = (tableRowObj.Type.toLowerCase() === "series");
    // create new table row
    var tbodyRow = document.createElement("tr");
    $(tbodyRow).addClass(['rephrase-table-row',
      isSeries ? 'rephrase-table-data-row' : 'rephrase-table-heading-row']);
    tbody.appendChild(tbodyRow);
    // create title cell
    var tbodyTitleCell = document.createElement("td");
    if (isSeries) {
      $(tbodyTitleCell).addClass('rephrase-table-data-row-title');
    } else {
      $(tbodyTitleCell).addClass('h5');
      tbodyTitleCell.setAttribute('colspan', dates.length + 1);
    }
    tbodyTitleCell.innerText = tableRowObj.Title || "";
    tbodyRow.appendChild(tbodyTitleCell);
    // create data cells
    if (isSeries) {
      if (typeof tableRowObj.Content === "string") {
        tableRowObj.Content = $ru.databank.getSeriesContent(tableRowObj.Content);
      }
      for (var j = 0; j < tableRowObj.Content.Values.length; j++) {
        const v = tableRowObj.Content.Values[j];
        var tbodyDataCell = document.createElement("td");
        $(tbodyDataCell).addClass('rephrase-table-data-cell');
        tbodyDataCell.innerText = v.toFixed(nDecimals);
        tbodyRow.appendChild(tbodyDataCell);
      }
    }
  }
}

function createGrid(parent, gridObj) {
  // create a parent div elements for rows
  var gridRowParent = document.createElement("div");
  $(gridRowParent).addClass(["rephrase-grid", "grid-y", "grid-padding-y"]);
  parent.appendChild(gridRowParent);
  // create grid title
  if (gridObj.Title) {
    var gridTitle = document.createElement("h2");
    $(gridTitle).addClass("rephrase-grid-title");
    gridTitle.innerText = gridObj.Title;
    gridRowParent.appendChild(gridTitle);
  }
  const nRows = gridObj.Settings.NumRows;
  const nCols = gridObj.Settings.NumColumns;
  // populate rows
  for (var i = 0; i < nRows; i++) {
    // create row
    var gridRow = document.createElement("div");
    $(gridRow).addClass(["cell", "shrink"]);
    gridRowParent.appendChild(gridRow);
    // create parent div for this row's columns
    var gridColParent = document.createElement("div");
    $(gridColParent).addClass(["grid-x", "grid-padding-x"]);
    gridRow.appendChild(gridColParent);
    // populate this row's columns
    for (let j = 0; j < nCols; j++) {
      const contentIndex = nCols * i + j;
      var gridCol = document.createElement("div");
      $(gridCol).addClass(["cell", "auto"]);
      gridColParent.appendChild(gridCol);
      const gridElementObj = gridObj.Content[contentIndex];
      $ru.addReportElement(gridCol, gridElementObj, gridObj.Settings);
    }
  }
}

function addReportElement(parentElement, elementObj, parentObjSettings) {
  // do nothing if smth. is wrong
  if (!elementObj || !(typeof elementObj === "object") || !elementObj.hasOwnProperty("Type")) {
    return {};
  }
  elementObj.Settings = appendObjSettings(elementObj.Settings || {}, parentObjSettings || {})
  switch (elementObj.Type.toLowerCase()) {
    case "chart":
      $ru.createChart(parentElement, elementObj);
      break;
    case "table":
      $ru.createTable(parentElement, elementObj);
      break;
    case "grid":
      $ru.createGrid(parentElement, elementObj);
      break;
    case "text":
      $ru.createTextBlock(parentElement, elementObj);
      break;
    case "pagebreak":
      $ru.addPageBreak(parentElement, elementObj);
      break;
    default:
      break;
  }
}

// copy parent object settings to the current one if the setting
// is not present in the current object yet
// todo: perhaps we need to make the process more sophisticated,
//       taking only the settings that are specific to the current 
//       object or its possible children
function appendObjSettings(objSettings, parentSettings) {
  const parentKeys = Object.keys(parentSettings);
  for (let i = 0; i < parentKeys.length; i++) {
    const key = parentKeys[i];
    if (!objSettings.hasOwnProperty(key)) {
      objSettings[key] = parentSettings[key];
    }
  }
  return objSettings;
}
