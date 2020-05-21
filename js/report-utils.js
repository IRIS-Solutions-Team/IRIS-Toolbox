'use strict';

// utility methods
var $ru = {
  createChart: createChart
};

// create chart elements
function createChart(parent) {
  var canvasParent = document.createElement("div");
  $(canvasParent).addClass(["cell", "medium-4", "rephrase-chart"]);
  parent.appendChild(canvasParent);
  var canvas = document.createElement("canvas");
  $(canvas).addClass(["rephrase-chart-canvas"]);
  canvasParent.appendChild(canvas);
  var sDate = moment("2010-04-01");
  var nDates = 20;
  var qRange = [];
  for (let i = 0; i < nDates; i++) {
    const d = sDate.add(1, 'Q').toDate();
    qRange.push(d);
  }
  var tsData1 = qRange.map(d => ({ x: d, y: Math.random() }));
  var tsData2 = qRange.map(d => ({ x: d, y: Math.random() }));
  new Chart(canvas, {
    type: 'line',
    data: {
      datasets: [
        { data: tsData1, lineTension: 0, label: 'tsData1', backgroundColor: 'rgba(0,0,0,0)', borderColor: 'rgba(255,0,0,0.3)' },
        { data: tsData2, lineTension: 0, label: 'tsData2', backgroundColor: 'rgba(0,0,0,0)', borderColor: 'rgba(255,0,255,0.8)' }
      ]
    },
    options: {
      maintainAspectRatio: false,
      scales: {
        xAxes: [{
          type: 'time',
          distribution: 'series',
          time: {
            unit: 'quarter',
            displayFormats: {
              quarter: 'YYYY[Q]Q'
            }
          }
        }]
      }
    }
  });

}