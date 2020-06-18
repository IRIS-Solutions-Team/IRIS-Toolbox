// delay page loading so that headless chrome 
// manages to load and resize Chart.js charts in time
(function () {
  'use strict';
  if (location.href.toUpperCase().indexOf("HTTP") != 0) {
    var delay = 1000; // Delaying up load (in milliseconds).
    delay = new Date().getTime() + delay;
    var xhttp = new XMLHttpRequest();

    while (new Date().getTime() < delay) {
      xhttp.open("GET", location.href, true);
      xhttp.send();
    }
  }
})();