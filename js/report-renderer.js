/**
 * # report-renderer.js
 * 
 * Dynamically adds report components defined in `$report` variable 
 * based on data defined in `$databank` variable
 * 
 * ---
 * Copyright © 2021 OGResearch. All rights reserved.
 */

// load Foundation styles
$(document).foundation();

// do the rendering
(function () {
  'use strict';

  const DEFAULT_TOC_DEPTH = 2;
  const EXCLUDE_FROM_TOC = ['SERIES', 'DIFFSERIES', 'HEADING', 'WRAPPER', 'PAGEBREAK'];

  // browser tab title
  document.title = $report.Title || "";

  // apply custom css class to .report-content div
  if ($report.Settings.Class && (typeof $report.Settings.Class === "string"
    || $report.Settings.Class instanceof Array)) {
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
    // default logo container
    const hiddenLogoImg = document.querySelector('.report-default-logo');
    if (!$report.Settings.hasOwnProperty("Logo")) {
      // get img src from the hidden img.report-default-logo
      const imgSrc = hiddenLogoImg.getAttribute("src") || "";
      $report.Settings.Logo = {
        "Path": imgSrc,
        "Position": "Left"
      };
    }
    hiddenLogoImg.parentNode.removeChild(hiddenLogoImg);
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

  // render the footer if defined
  var footerDiv = document.querySelector('.report-footer');
  if (!$report.Settings.hasOwnProperty("Footer") || $report.Settings.Footer === null) {
    footerDiv.style.display = 'none';
  } else {
    var footerText = footerDiv.querySelector('.footer-text');
    footerText.innerText = $report.Settings.Footer || "";
  }

  // assign IDs to all elements
  $report.Content = $ru.assignElementIds($report.Content, []).content;

  // render ToC if needed
  var tocWrapperDiv = document.querySelector('.report-toc-menu-wrapper');
  var tocButton = document.querySelector('.report-toc-button');
  if (!$report.Settings.hasOwnProperty("TableOfContents") || !$report.Settings.TableOfContents) {
    tocWrapperDiv.style.display = 'none';
    tocButton.style.display = 'none';
  } else {
    var tocMenuDiv = document.querySelector('.report-toc-menu');
    var tocMenu = document.createElement("ul");
    $(tocMenu).addClass(["vertical", "menu", "report-toc-menu-content"]);
    const tocDepth = $report.Settings.hasOwnProperty("TableOfContentsDepth")
      ? $report.Settings.TableOfContentsDepth
      : DEFAULT_TOC_DEPTH;
    const tocExcludeTypes = EXCLUDE_FROM_TOC;
    tocMenu = $ru.generateToc(tocMenu, $report.Content, tocDepth, tocExcludeTypes);
    tocMenuDiv.appendChild(tocMenu);
  }

  // create report body
  var bodyDiv = document.querySelector('.report-body');
  for (let i = 0; i < $report.Content.length; i++) {
    const elementObj = $report.Content[i];
    $ru.addReportElement(bodyDiv, elementObj, $report.Settings);
  }
})();