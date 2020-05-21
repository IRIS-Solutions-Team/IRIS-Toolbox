// load Foundation styles
$(document).foundation();

// do the rendering
(function () {
  'use strict';

  // browser tab title
  document.title = $report.Title || "";

  // apply custom css class to .report-content div
  if ($report.Settings.Class && typeof $report.Settings.Class === "string") {
    var reportDiv = document.querySelector('.report-content');
    $(reportDiv).addClass($report.Settings.Class);
  }

  // render or disable header
  var headerDiv = document.querySelector('.report-header');
  if (!$report.hasOwnProperty("Title") || $report.Title === null) { } else {
    var headerTextDiv = headerDiv.querySelector('.header-text');
    // set title
    headerTextDiv
      .querySelector('.title')
      .innerText = $report.Title || "";
    // set subtitle
    headerTextDiv
      .querySelector('.subtitle')
      .innerText = $report.Settings.Subtitle || "";

    // add logo(s)
    var leftLogoDiv = headerDiv.querySelector('.left-logo');
    var rightLogoDiv = headerDiv.querySelector('.right-logo');
    var logo = $report.Settings.Logo || [];
    if (typeof logo === "object" && !(logo instanceof Array)) {
      logo = [logo];
    }
    var hasLeft, hasRight = false;
    for (var i = 0; i < logo.length; i++) {
      const lg = logo[i];
      if (typeof lg === "object" && lg.hasOwnProperty("Path") && lg.Path
        && lg.hasOwnProperty("Position") && lg.Position !== "None") {
        if (lg.Position.toLowerCase() === "left") {
          leftLogoDiv.innerHTML = '<img class="left-logo-img" src="' + lg.Path + '" alt="logo"></img>';
          hasLeft = true;
        }
        if (lg.Position.toLowerCase() === "right") {
          rightLogoDiv.innerHTML = '<img class="right-logo-img" src="' + lg.Path + '" alt="logo"></img>';
          hasRight = true;
        }
      }
    }
    if (!hasLeft) {
      leftLogoDiv.style.display = 'none';
    }
    if (!hasRight) {
      rightLogoDiv.style.display = 'none';
    }
  }

  var footerDiv = document.querySelector('.report-footer');

  if (!$report.Settings.hasOwnProperty("Footer") || $report.Settings.Footer === null) {
    footerDiv.style.display = 'none';
  } else {
    var footerText = footerDiv.querySelector('.footer-text');
    footerText.innerText = $report.Settings.Footer || "";
  }

  // create report body
  var bodyDiv = document.querySelector('.report-body');
  var gridDiv = document.createElement("div");
  $(gridDiv).addClass(["grid-x", "grid-padding-x"]);
  bodyDiv.appendChild(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
  $ru.createChart(gridDiv);
})();