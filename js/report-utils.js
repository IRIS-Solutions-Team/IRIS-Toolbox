'use strict';

// utility methods
var $ru = {
  createChart: createChart,
  createChartSeries: createChartSeries,
  createChartForChartJs: createChartForChartJs,
  createSeriesForChartJs: createSeriesForChartJs,
  createChartForPlotly: createChartForPlotly,
  createSeriesForPlotly: createSeriesForPlotly,
  freqToUnit: freqToMomentJsUnit,
  createTable: createTable,
  createTableSeries: createTableSeries,
  createGrid: createGrid,
  createMatrix: createMatrix,
  addReportElement: addReportElement,
  getColorList: getColorList,
  addPageBreak: addPageBreak,
  createWrapper: createWrapper,
  createTextBlock: createTextBlock,
  appendObjSettings: appendObjSettings,
  momentJsDateFormatToD3TimeFormat: momentJsDateFormatToD3TimeFormat,
  postProcessIrisCode: postProcessIrisCode,
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
  const hideTitle = (chartObj.Settings.hasOwnProperty("DisplayTitle") && !chartObj.Settings.DisplayTitle);
  // create chart title
  const chartTitle = chartObj.Title || "";
  if (chartTitle && !hideTitle) {
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
      seriesObj.Settings = appendObjSettings(seriesObj.Settings || {}, chartObj.Settings || {});
      data.push($ru.createChartSeries(seriesObj, limits, colorList[i], chartLib));
    }
  }
  const interactive = (!chartObj.Settings.hasOwnProperty("InteractiveCharts"))
    ? true
    : chartObj.Settings.InteractiveCharts;
  const chartBody = (chartLib.toLowerCase() === "chartjs")
    ? $ru.createChartForChartJs(data, limits, chartObj.Settings.DateFormat, chartObj.Settings.Highlight || [])
    : $ru.createChartForPlotly(data, limits, chartObj.Settings.DateFormat, chartObj.Settings.Highlight || [], interactive);
  chartParent.appendChild(chartBody);
}

function createChartSeries(seriesObj, limits, color, chartLib) {
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
      return $ru.createSeriesForChartJs(seriesObj.Title, seriesObj.Content.Dates, seriesObj.Content.Values, seriesObj.Settings, colors, limits);
    case "plotly":
    default:
      return $ru.createSeriesForPlotly(seriesObj.Title, seriesObj.Content.Dates, seriesObj.Content.Values, seriesObj.Settings, colors);
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
function createChartForChartJs(data, limits, dateFormat, highlight) {
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
        display: false // title is always out of canvas
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
              return moment(new Date(d)).format(dateFormat);
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
function createSeriesForChartJs(title, dates, values, seriesSettings, colors, limits) {
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
  const seriesPlotType = seriesSettings.Type || "line";
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
function createChartForPlotly(data, limits, dateFormat, highlight, interactive) {
  const DEFAULT_GRID_COLOR = '#ddd';
  const DEFAULT_SHOW_AXIS = true;
  const DEFAULT_AXIS_COLOR = '#aaa';
  var chartBody = document.createElement("div");
  $(chartBody).addClass("rephrase-chart-body");
  const layout = {
    font: {
      family: "Lato",
      color: "#0a0a0a"
    },
    xaxis: {
      range: [limits.min, limits.max],
      type: 'date',
      tickformat: $ru.momentJsDateFormatToD3TimeFormat(dateFormat),
      gridcolor: DEFAULT_GRID_COLOR,
      showline: DEFAULT_SHOW_AXIS,
      linecolor: DEFAULT_AXIS_COLOR
      // tickformatstops: [
      //   {
      //     "dtickrange": [null, 604800000],
      //     "value": "%b %d, %Y"
      //   },
      //   {
      //     "dtickrange": [604800000,"M1"],
      //     "value": "%b %Y"
      //   },
      //   {
      //     "dtickrange": ["M1", null],
      //     "value": $ru.momentJsDateFormatToD3TimeFormat(dateFormat)
      //   }
      // ]
    },
    yaxis: {
      autorange: true,
      type: 'linear',
      fixedrange: true,
      gridcolor: DEFAULT_GRID_COLOR,
      showline: DEFAULT_SHOW_AXIS,
      linecolor: DEFAULT_AXIS_COLOR
    },
    legend: {
      x: 0.5,
      y: 1,
      xanchor: "center",
      yanchor: "bottom",
      orientation: "h"
    },
    margin: {
      l: 50,
      r: 50,
      b: 30,
      t: 10,
      pad: 4
    }
  };
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
    var bBox = chartBody.getBoundingClientRect();
    layout.height = bBox.width / 1.5;
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
function createSeriesForPlotly(title, dates, values, seriesSettings, colors) {
  const seriesPlotType = seriesSettings.Type || "scatter";
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


function createMatrix(parent, matrixObj) {
  // by default do not round matrix numbers
  const nDecParsed = parseInt(matrixObj.Settings.NumDecimals);
  const nDecimals = isNaN(nDecParsed) ? -1 : nDecParsed;
  var matrixParent = document.createElement("div");
  $(matrixParent).addClass("rephrase-matrix");
  // apply custom css class to .rephrase-matrix div
  if (matrixObj.Settings.Class && (typeof matrixObj.Settings.Class === "string"
    || matrixObj.Settings.Class instanceof Array)) {
    $(matrixParent).addClass(matrixObj.Settings.Class);
  }
  parent.appendChild(matrixParent);
  // create title
  if (matrixObj.Title) {
    var matrixTitle = document.createElement("div");
    $(matrixTitle).addClass(["rephrase-matrix-title", "h3"]);
    matrixTitle.innerText = matrixObj.Title;
    matrixParent.appendChild(matrixTitle);
  }
  var matrixBodyDiv = document.createElement("div");
  $(matrixBodyDiv).addClass(["rephrase-matrix-body", "table-scroll"]);
  matrixParent.appendChild(matrixBodyDiv);
  // create content
  if (matrixObj.Content && (matrixObj.Content instanceof Array) && matrixObj.Content.length > 0) {
    var matrix = document.createElement("table");
    $(matrix).addClass(["rephrase-matrix-table", "hover", "unstriped"]);
    // apply custom css class to .rephrase-chart div
    if (matrixObj.Settings.Class && (typeof matrixObj.Settings.Class === "string"
      || matrixObj.Settings.Class instanceof Array)) {
      $(matrix).addClass(matrixObj.Settings.Class);
    }
    matrixBodyDiv.appendChild(matrix);
    // initiate matrix header column if needed
    const hasColNames = (matrixObj.Settings.ColNames && (matrixObj.Settings.ColNames instanceof Array) && matrixObj.Settings.ColNames.length > 0);
    const hasRowNames = (matrixObj.Settings.RowNames && (matrixObj.Settings.RowNames instanceof Array) && matrixObj.Settings.RowNames.length > 0);
    if (hasColNames) {
      var thead = document.createElement("thead");
      $(thead).addClass('rephrase-matrix-header');
      matrix.appendChild(thead);
      var theadRow = document.createElement("tr");
      thead.appendChild(theadRow);
      if (hasRowNames) {
        var theadFirstCell = document.createElement("th");
        $(theadFirstCell).addClass(['rephrase-matrix-header-cell', 'rephrase-matrix-header-cell-col', 'rephrase-matrix-header-cell-row']);
        theadRow.appendChild(theadFirstCell);
      }
      for (let i = 0; i < matrixObj.Settings.ColNames.length; i++) {
        const cName = matrixObj.Settings.ColNames[i];
        var theadCell = document.createElement("th");
        $(theadCell).addClass(['rephrase-matrix-header-cell', 'rephrase-matrix-header-cell-col']);
        theadCell.innerText = cName;
        theadRow.appendChild(theadCell);
      }
    }
    var tbody = document.createElement("tbody");
    $(tbody).addClass('rephrase-matrix-table-body');
    matrix.appendChild(tbody);
    // populate table body
    for (var i = 0; i < matrixObj.Content.length; i++) {
      var tbodyRow = document.createElement("tr");
      tbody.appendChild(tbodyRow);
      const matrixRow = matrixObj.Content[i];
      if (hasRowNames) {
        const rName = matrixObj.Settings.RowNames[i];
        var theadCell = document.createElement("th");
        $(theadCell).addClass(['rephrase-matrix-header-cell', 'rephrase-matrix-header-cell-row']);
        theadCell.innerText = rName;
        tbodyRow.appendChild(theadCell);
      }
      for (let j = 0; j < matrixRow.length; j++) {
        const v = (nDecimals === -1) ? matrixRow[j] : matrixRow[j].toFixed(nDecimals);
        var tbodyDataCell = document.createElement("td");
        $(tbodyDataCell).addClass('rephrase-matrix-data-cell');
        tbodyDataCell.innerText = v;
        tbodyRow.appendChild(tbodyDataCell);
      }
    }
  }
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
        const isIris = (lang.toLowerCase() === "iris");
        if (isIris) {
          lang = "matlab";
        }
        const validLang = hljs.getLanguage(lang) ? lang : 'plaintext';
        const theCode = "<pre><code class=\"hljs"
          + (validLang ? " language-" + validLang : "")
          + "\">" + hljs.highlight(validLang, code).value
          + "</code></pre>";
        // add IRIS specific highlighting on the top of MATLAB's
        return (isIris) ? postProcessIrisCode(postProcessMatlabCode(theCode)) : postProcessMatlabCode(theCode);
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

function postProcessMatlabCode(code) {
  // add missing stuff to Matlab highlighting

  // make %%-comments bold
  code = code.replace(/(\<span class\=['"]hljs\-comment)(['"]\>\s*%%\s+.*?\<\/span\>)/gim, "$1 hljs-bold$2");

  return code;
}

function postProcessIrisCode(code) {
  // add hljs classes to IRIS specific keywords

  // todo: implement this properly

  // make all words starting with "!" a keywords (.hljs-keyword)
  code = code.replace(/(![a-zA-Z_]*)/gim, "<span class='hljs-keyword'>$1</span>");
  // highlight lags and leads (.hljs-symbol)
  code = code.replace(/\{\<span class\=['"]hljs\-number['"]\>([\+\-]?\d+)\<\/span\>\}/gim, "<span class='hljs-symbol'>{$1}</span>");

  return code;
}

function momentJsDateFormatToD3TimeFormat(dateFormat) {
  // percent sign has a special meaning in D3
  var d3TimeFormat = dateFormat.replace("%", "%%");
  // moment.js [] escape -- temporary take them out
  var escaped = [];
  var re = /\[(.*?)\]/ig;
  var match = re.exec(d3TimeFormat);
  while (match !== null) {
    escaped.push(match[1]);
    match = re.exec(d3TimeFormat);
  }
  d3TimeFormat = d3TimeFormat.replace(re, "[]");
  // years
  d3TimeFormat = d3TimeFormat.replace("YYYY", "%Y");
  d3TimeFormat = d3TimeFormat.replace("YY", "%y");
  // quarters
  d3TimeFormat = d3TimeFormat.replace("QQ", "0%q");
  d3TimeFormat = d3TimeFormat.replace("Q", "%q");
  // months
  d3TimeFormat = d3TimeFormat.replace("MMMM", "%B");
  d3TimeFormat = d3TimeFormat.replace("MMM", "%b");
  d3TimeFormat = d3TimeFormat.replace("MM", "%m");
  d3TimeFormat = d3TimeFormat.replace("M", "%-m");
  // week days
  d3TimeFormat = d3TimeFormat.replace("dddd", "%A");
  d3TimeFormat = d3TimeFormat.replace("ddd", "%a");
  // days
  d3TimeFormat = d3TimeFormat.replace("DDDD", "%j");
  d3TimeFormat = d3TimeFormat.replace("DDD", "%j");
  d3TimeFormat = d3TimeFormat.replace("DD", "%d");
  d3TimeFormat = d3TimeFormat.replace("D", "%-d");
  // moment.js [] escape -- put them back
  var i = 0;
  d3TimeFormat = d3TimeFormat.replace(/\[\]/g, function () { return escaped[i++]; });
  return d3TimeFormat;
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
  // what rows to display
  tableObj.Settings.DisplayRows = tableObj.Settings.DisplayRows || {
    "Diff": true,
    "Baseline": false,
    "Alternative": false
  };
  const isDiffTable = tableObj.Content.findIndex(function (el) { return el.Type.toLowerCase() === "diffseries"; }) !== -1;
  if (isDiffTable) {
    // create button group
    var buttonGroup = document.createElement("div");
    $(buttonGroup).addClass(["small", "button-group", "rephrase-diff-table-button-group"]);
    var showBaselineBtn = document.createElement("a");
    showBaselineBtn.innerText = "Hide Baseline";
    $(showBaselineBtn).addClass(["button", "rephrase-diff-table-button", "rephrase-diff-table-button-show-baseline"]);
    if (!tableObj.Settings.DisplayRows.Baseline) {
      showBaselineBtn.innerText = "Show Baseline";
      $(showBaselineBtn).addClass("hollow");
    }
    showBaselineBtn.addEventListener("click", onBtnClick, false);
    buttonGroup.appendChild(showBaselineBtn);
    var showAlternativeBtn = document.createElement("a");
    showAlternativeBtn.innerText = "Hide Alternative";
    $(showAlternativeBtn).addClass(["button", "rephrase-diff-table-button", "rephrase-diff-table-button-show-alternative"]);
    if (!tableObj.Settings.DisplayRows.Alternative) {
      showAlternativeBtn.innerText = "Show Alternative";
      $(showAlternativeBtn).addClass("hollow");
    }
    showAlternativeBtn.addEventListener("click", onBtnClick, false);
    buttonGroup.appendChild(showAlternativeBtn);
    var showDiffBtn = document.createElement("a");
    showDiffBtn.innerText = "Hide Diff";
    $(showDiffBtn).addClass(["button", "rephrase-diff-table-button", "rephrase-diff-table-button-show-diff"]);
    if (!tableObj.Settings.DisplayRows.Diff) {
      showDiffBtn.innerText = "Show Diff";
      $(showDiffBtn).addClass("hollow");
    }
    showDiffBtn.addEventListener("click", onBtnClick, false);
    buttonGroup.appendChild(showDiffBtn);
    tableParent.appendChild(buttonGroup);
  }
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
  // populate table body
  for (var i = 0; i < tableObj.Content.length; i++) {
    const tableRowObj = tableObj.Content[i];
    // skip this entry if it's neither a SERIES nor HEADING or if smth. else is wrong
    if (!tableRowObj.hasOwnProperty("Type")
      || ["diffseries", "series", "heading"].indexOf(tableRowObj.Type.toLowerCase()) === -1
      || (tableRowObj.Type.toLowerCase() === "series"
        && (!tableRowObj.hasOwnProperty("Content")
          || !((typeof tableRowObj.Content === "string")
            || (typeof tableRowObj.Content === "object"
              && tableRowObj.Content.hasOwnProperty("Dates")
              && tableRowObj.Content.hasOwnProperty("Values")
              && (dates instanceof Array)
              && tableRowObj.Content.Values.length === dates.length))))
      || (tableRowObj.Type.toLowerCase() === "diffseries"
        && (!tableRowObj.hasOwnProperty("Content")
          || !((tableRowObj.Content instanceof Array)
            && ((typeof tableRowObj.Content[0] === "string")
              || (typeof tableRowObj.Content[0] === "object"
                && tableRowObj.Content[0].hasOwnProperty("Dates")
                && tableRowObj.Content[0].hasOwnProperty("Values")
                && (dates instanceof Array)
                && tableRowObj.Content[0].Values.length === dates.length)))))) {
      continue;
    }
    const isSeries = (["series", "diffseries"].indexOf(tableRowObj.Type.toLowerCase()) !== -1);
    // create new table row
    var tbodyRow = document.createElement("tr");
    tbody.appendChild(tbodyRow);
    $(tbodyRow).addClass(['rephrase-table-row',
      isSeries ? 'rephrase-table-data-row' : 'rephrase-table-heading-row']);
    // create title cell
    if (isSeries) {
      tableRowObj.Settings = appendObjSettings(tableRowObj.Settings || {}, tableObj.Settings || {});
      $ru.createTableSeries(tbodyRow, tableRowObj);
    } else {
      var tbodyTitleCell = document.createElement("td");
      $(tbodyTitleCell).addClass('h5');
      tbodyTitleCell.setAttribute('colspan', dates.length + 1);
      tbodyTitleCell.innerText = tableRowObj.Title || "";
      tbodyRow.appendChild(tbodyTitleCell);
    }
  }
  if (!tableObj.Settings.DisplayRows.Diff) {
    toggleRows(tableParent, "hide", "diff");
  }
  if (!tableObj.Settings.DisplayRows.Baseline) {
    toggleRows(tableParent, "hide", "baseline");
  }
  if (!tableObj.Settings.DisplayRows.Alternative) {
    toggleRows(tableParent, "hide", "alternative");
  }
  // button click event handler
  function onBtnClick(event) {
    const thisBtn = event.target;
    const tableParent = $(thisBtn).parent().parent();
    const otherBtn1 = $(thisBtn).siblings()[0];
    const otherBtn2 = $(thisBtn).siblings()[1];
    const isDiff = $(thisBtn).hasClass("rephrase-diff-table-button-show-diff");
    const isBaseline = $(thisBtn).hasClass("rephrase-diff-table-button-show-baseline");
    const btnType = isDiff ? "diff" : (isBaseline ? "baseline" : "alternative");
    if ($(thisBtn).hasClass("hollow")) {
      // toggle ON
      $(thisBtn).removeClass("hollow");
      thisBtn.innerText = thisBtn.innerText.replace("Show", "Hide");
      toggleRows(tableParent, "show", btnType);
    } else if (!($(otherBtn1).hasClass("hollow") && $(otherBtn2).hasClass("hollow"))) {
      // toggle OFF (if the other buttons are not OFF both)
      $(thisBtn).addClass("hollow");
      thisBtn.innerText = thisBtn.innerText.replace("Hide", "Show");
      toggleRows(tableParent, "hide", btnType);
    }
  }
  // show/hide the specified rows of the diff table
  function toggleRows(tableParent, toggleState, btnType) {
    const rows = (btnType === "diff")
      ? $(tableParent).find(".rephrase-diff-table-data-row-diff")
      : ((btnType === "baseline")
        ? $(tableParent).find(".rephrase-diff-table-data-row-baseline")
        : $(tableParent).find(".rephrase-diff-table-data-row-alternative"));
    for (var i = 0; i < rows.length; i++) {
      const row = rows[i];
      row.style.display = (toggleState === "hide") ? "none" : "";
    }
  }
}

function createTableSeries(tbodyRow, tableRowObj) {
  // number of decimals when showing numbers
  const nDecParsed = parseInt(tableRowObj.Settings.NumDecimals);
  const nDecimals = isNaN(nDecParsed) ? 2 : nDecParsed;
  const diffMethod = (tableRowObj.Settings.Method || "Difference").toLowerCase();
  const nanValue = (tableRowObj.Settings.NaN === undefined || tableRowObj.Settings.NaN === null)
    ? NaN
    : tableRowObj.Settings.NaN;
  var tbodyTitleCell = document.createElement("td");
  $(tbodyTitleCell).addClass('rephrase-table-data-row-title');
  tbodyTitleCell.innerText = tableRowObj.Title || "";
  tbodyRow.appendChild(tbodyTitleCell);
  // create data cells
  if (tableRowObj.Type.toLowerCase() === "diffseries") {
    $(tbodyRow).addClass("rephrase-diff-table-data-row-title");
    tbodyTitleCell.setAttribute('colspan', tableRowObj.Settings.Dates.length + 1);
    var diffRow = document.createElement("tr");
    $(diffRow).addClass("rephrase-diff-table-data-row-diff");
    var diffRowTitleCell = document.createElement("td");
    $(diffRowTitleCell).addClass(['rephrase-table-data-row-title', 'rephrase-diff-table-data-row-diff-title']);
    diffRowTitleCell.innerText = (tableRowObj.Settings.RowTitles && tableRowObj.Settings.RowTitles.Diff)
      ? tableRowObj.Settings.RowTitles.Diff
      : "Diff";
    diffRow.appendChild(diffRowTitleCell);
    var baselineRow = document.createElement("tr");
    $(baselineRow).addClass("rephrase-diff-table-data-row-baseline");
    var baselineRowTitleCell = document.createElement("td");
    $(baselineRowTitleCell).addClass(['rephrase-table-data-row-title', 'rephrase-diff-table-data-row-baseline-title']);
    baselineRowTitleCell.innerText = (tableRowObj.Settings.RowTitles && tableRowObj.Settings.RowTitles.Baseline)
      ? tableRowObj.Settings.RowTitles.Baseline
      : "Baseline";
    baselineRow.appendChild(baselineRowTitleCell);
    var alternativeRow = document.createElement("tr");
    $(alternativeRow).addClass("rephrase-diff-table-data-row-alternative");
    var alternativeRowTitleCell = document.createElement("td");
    $(alternativeRowTitleCell).addClass(['rephrase-table-data-row-title', 'rephrase-diff-table-data-row-alternative-title']);
    alternativeRowTitleCell.innerText = (tableRowObj.Settings.RowTitles && tableRowObj.Settings.RowTitles.Alternative)
      ? tableRowObj.Settings.RowTitles.Alternative
      : "Alternative";
    alternativeRow.appendChild(alternativeRowTitleCell);
    var baselineSeries = (typeof tableRowObj.Content[0] === "string")
      ? $ru.databank.getSeriesContent(tableRowObj.Content[0])
      : tableRowObj.Content[0];
    var alternativeSeries = (typeof tableRowObj.Content[1] === "string")
      ? $ru.databank.getSeriesContent(tableRowObj.Content[1])
      : tableRowObj.Content[1];
    for (var j = 0; j < Math.max(baselineSeries.Values.length, alternativeSeries.Values.length); j++) {
      const v1 = (baselineSeries.Values[j] === null) ? NaN : baselineSeries.Values[j];
      const v2 = (alternativeSeries.Values[j] === null) ? NaN : alternativeSeries.Values[j];
      const vDiff = (diffMethod === "ratio")
        ? v2 / v1
        : ((diffMethod === "percent")
          ? 100 * (v2 - v1) / v1
          : v2 - v1); // difference
      var baselineDataCell = document.createElement("td");
      $(baselineDataCell).addClass(['rephrase-table-data-cell', 'rephrase-diff-table-data-cell-baseline']);
      baselineDataCell.innerText = isNaN(v1) ? nanValue : v1.toFixed(nDecimals);
      baselineRow.appendChild(baselineDataCell);
      var alternativeDataCell = document.createElement("td");
      $(alternativeDataCell).addClass(['rephrase-table-data-cell', 'rephrase-diff-table-data-cell-alternative']);
      alternativeDataCell.innerText = isNaN(v2) ? nanValue : v2.toFixed(nDecimals);
      alternativeRow.appendChild(alternativeDataCell);
      var diffDataCell = document.createElement("td");
      $(diffDataCell).addClass(['rephrase-table-data-cell', 'rephrase-diff-table-data-cell-diff']);
      diffDataCell.innerText = isNaN(vDiff) ? nanValue : vDiff.toFixed(nDecimals) + ((diffMethod === "percent") ? "%" : "");
      diffRow.appendChild(diffDataCell);
    }
    $(tbodyRow).after(baselineRow);
    $(baselineRow).after(alternativeRow);
    $(alternativeRow).after(diffRow);
  } else {
    if (typeof tableRowObj.Content === "string") {
      tableRowObj.Content = $ru.databank.getSeriesContent(tableRowObj.Content);
    }
    for (var j = 0; j < tableRowObj.Content.Values.length; j++) {
      const v = (tableRowObj.Content.Values[j] === null) ? NaN : tableRowObj.Content.Values[j];
      var tbodyDataCell = document.createElement("td");
      $(tbodyDataCell).addClass('rephrase-table-data-cell');
      tbodyDataCell.innerText = isNaN(v) ? nanValue : v.toFixed(nDecimals);
      tbodyRow.appendChild(tbodyDataCell);
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

// wrapper element for cascading its settings down the ladder
function createWrapper(parent, wrapperObj) {
  for (let i = 0; i < wrapperObj.Content.length; i++) {
    const elementObj = wrapperObj.Content[i];
    $ru.addReportElement(parent, elementObj, wrapperObj.Settings);
  }
}

function addReportElement(parentElement, elementObj, parentObjSettings) {
  // do nothing if smth. is wrong
  if (!elementObj || !(typeof elementObj === "object") || !elementObj.hasOwnProperty("Type")) {
    return {};
  }
  elementObj.Settings = appendObjSettings(elementObj.Settings || {}, parentObjSettings || {});
  switch (elementObj.Type.toLowerCase()) {
    case "chart":
      $ru.createChart(parentElement, elementObj);
      break;
    case "table":
      $ru.createTable(parentElement, elementObj);
      break;
    case "matrix":
      $ru.createMatrix(parentElement, elementObj);
      break;
    case "grid":
      $ru.createGrid(parentElement, elementObj);
      break;
    case "text":
      $ru.createTextBlock(parentElement, elementObj);
      break;
    case "wrapper":
      $ru.createWrapper(parentElement, elementObj);
      break;
    case "pagebreak":
      $ru.addPageBreak(parentElement, elementObj);
      break;
    default:
      console.log("Unknown report element");
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
    if (key.toLowerCase() === "class") {
      continue
    }
    if (!objSettings.hasOwnProperty(key)) {
      objSettings[key] = parentSettings[key];
    }
  }
  return objSettings;
}
