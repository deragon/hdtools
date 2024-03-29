// jQuery WARNING:
//
//    If your require jQuery (like @require
//    https://code.jquery.com/jquery-3.7.1.min.js) jQuery will cause all error
//    messages to show up as '[object Object]' instead of showing the actual
//    error message.  Fortunately, jQuery is not needed with NiFi.  But think
//    twice if one day, you plan to @require jQuery.

// ==UserScript==
// @name         NiFi - Color differ per environment.
// @description  NiFi - Color differ per environment.
// @namespace    http://tampermonkey.net/
// @version      0.1
// @author       Hans Deragon
// @include      https://<rest of URL of target website here>
// @require      https://gist.github.com/raw/2625891/waitForKeyElements.js
// @grant        none
// ==/UserScript==

//debugger

// I cannot get '@match' working.  2023-01-28
// @match        https:*nifi*


// Here, we wait for the element to be loaded and drawn before configuring its color.
// To know where waitForKeyElements() comes from, see:
// https://stackoverflow.com/questions/12897446/userscript-to-wait-for-page-to-load-before-executing-code-techniques
waitForKeyElements("md-toolbar",  actionFunction);  // NiFi Instance
waitForKeyElements("mat-toolbar", actionFunction);  // NiFi Registry

function actionFunction (jNode) {

  // Default is red for production. If there's a bug and it's not production
  // the red color will alert the user that there is a bug in this script.
  var color = "red"; // "rgba(255, 0, 0, 0.7)";

  if (/^<string here> {
    // DV
    color = "#88FF88";
  }
  else if (/^<string here> {
    // QA
    color = "dodgerblue";
  }

  console.log("Tampermonkey - Color choosen:  " + color)

  try {
    // Attempt to setup NiFi Instance element.  If element is not present,
    // an exception is raised but ignored so the next element can be tried.
    document.getElementById("header").setAttribute("style", "background-color:" + color);
    document.querySelector("#global-menu-button").setAttribute("style", "background-color:" + color);
  } catch (e) {;}
  try {
    // Attempt to setup NiFi Registry element.  If element is not present,
    // an exception is raised but ignored so the next element can be tried.
    document.getElementById("nifi-registry-toolbar").setAttribute("style", "background-color:" + color);
  } catch (e) {;}
}
