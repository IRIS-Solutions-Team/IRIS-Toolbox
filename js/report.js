// load Foundation styles
$(document).foundation();

// create header
var headerDiv = document.querySelector('.report-header');
$(headerDiv).addClass(["cell", "shrink"]);
headerDiv.innerHTML = `
<div class="grid-x grid-padding-x">
  <div class="cell shrink">
    <img class="logo" src="./img/logo.png" alt="logo">
  </div>
  <div class="cell auto">
    <h2>My report name <br/>
      <small>My report subtitle</small>
    </h2>
  </div>
</div>`;
// create footer
var footerDiv = document.querySelector('.report-footer');
$(footerDiv).addClass(["cell", "shrink"]);
footerDiv.innerHTML = `
<p class="text-center">Here's my footer</p>`;

// create report body
var bodyDiv = document.querySelector('.report-body');
$(bodyDiv).addClass(["cell", "auto"]);
var gridDiv = document.createElement("div");
$(gridDiv).addClass(["grid-x", "grid-padding-x"]);
bodyDiv.appendChild(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);
createChartElement(gridDiv);

function createChartElement(parent) {
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