'use strict';

// utility methods
var $ru = {
  createChart: createChartForChartJs,
  createSeries: createSeriesForChartJs,
  freqToUnit: freqToChartJsUnit,
  createTable: createTable,
  createGrid: createGrid,
  getColorList: getColorList
};

// create chart elements using Chart.js library
function createChartForChartJs(parent, chartObj) {
  var canvasParent = document.createElement("div");
  $(canvasParent).addClass("rephrase-chart");
  // apply custom css class to .rephrase-chart div
  if (chartObj.Settings.Class && (typeof chartObj.Settings.Class === "string"
    || chartObj.Settings.Class instanceof Array)) {
    $(canvasParent).addClass(chartObj.Settings.Class);
  }
  parent.appendChild(canvasParent);
  var canvas = document.createElement("canvas");
  $(canvas).addClass("rephrase-chart-canvas");
  canvasParent.appendChild(canvas);

  const chartTitle = chartObj.Title || "";
  const chartUnit = $ru.freqToUnit(chartObj.Settings.Freq);
  const dates = chartObj.Settings.Dates.map(function (d) {
    return new Date(d);
  });
  var data = [];
  if (chartObj.hasOwnProperty("Content") && chartObj.Content instanceof Array) {
    const colorList = $ru.getColorList(chartObj.Content.length);
    for (var i = 0; i < chartObj.Content.length; i++) {
      const seriesObj = chartObj.Content[i];
      data.push($ru.createSeries(dates, seriesObj, colorList[i]));
    }
  }

  var chartJsObj = new Chart(canvas, {
    type: 'line',
    data: {
      datasets: data
    },
    options: {
      title: {
        display: chartTitle !== "",
        text: chartTitle
      },
      maintainAspectRatio: false,
      scales: {
        xAxes: [{
          type: 'time',
          distribution: 'series',
          time: {
            unit: chartUnit,
            displayFormats: {
              quarter: chartObj.Settings.DateFormat
            }
          }
        }]
      }
    }
  });

  return chartJsObj;
}

// create series object for Chart.js chart
function createSeriesForChartJs(dates, seriesObj, color) {
  // return empty object if smth. is wrong
  if (!seriesObj || !(typeof seriesObj === "object") || !seriesObj.hasOwnProperty("Type")
    || seriesObj.Type.toLowerCase() !== "series" || !seriesObj.hasOwnProperty("Content")
    || !(seriesObj.Content instanceof Array) || !(dates instanceof Array)
    || seriesObj.Content.length !== dates.length) {
    return {};
  }
  var tsData = [];
  for (var i = 0; i < dates.length; i++) {
    tsData.push({
      x: dates[i],
      y: seriesObj.Content[i]
    });
  }
  var overrideColor = null;
  if (seriesObj.hasOwnProperty("Settings") && (typeof seriesObj.Settings === "object")
    && seriesObj.Settings.hasOwnProperty("Color")) {
    overrideColor = seriesObj.Settings.Color;
  }
  return {
    data: tsData,
    lineTension: 0,
    label: seriesObj.Title || "",
    backgroundColor: "rgba(0,0,0,0)",
    borderColor: overrideColor || color
  };
}

// convert frequency letter to Chart.js time unit
function freqToChartJsUnit(freq) {
  var unit = "";
  switch (freq.toLowerCase()) {
    case "d":
    case "day":
    case "daily":
      unit = "day";
      break;
    case "w":
    case "week":
    case "weekly":
      unit = "week";
      break;
    case "m":
    case "month":
    case "monthly":
      unit = "month";
      break;
    case "q":
    case "quarter":
    case "quarterly":
      unit = "quarter";
      break;
    case "y":
    case "year":
    case "yearly":
    case "a":
    case "annual":
    case "annually":
      unit = "year";
      break;
    default:
      unit = "";
  }
  return unit;
}

function getColorList(nColors) {
  const defaultColorList = [
    "#0072bd",
    "#d95319",
    "#edb120",
    "#7e2f8e",
    "#77ac30",
    "#4dbeee",
    "#a2142f"
  ];
  const nDefaults = defaultColorList.length;
  var colorList = [];
  for (let i = 0; i < nColors; i++) {
    colorList.push(defaultColorList[i % nDefaults]);

  }
  return colorList;
}

function createTable(parent, tableObj) {
  if (tableObj.Title) {
    var tableTitle = document.createElement("h3");
    $(table).addClass("rephrase-table-title");
    tableTitle.innerText = tableObj.Title;
  }
  var table = document.createElement("table");
  $(table).addClass("rephrase-table");
  // apply custom css class to .rephrase-chart div
  if (tableObj.Settings.Class && (typeof tableObj.Settings.Class === "string"
    || tableObj.Settings.Class instanceof Array)) {
    $(table).addClass(tableObj.Settings.Class);
  }
  parent.appendChild(table);
  

}

function createGrid(parent, gridObj) {

}