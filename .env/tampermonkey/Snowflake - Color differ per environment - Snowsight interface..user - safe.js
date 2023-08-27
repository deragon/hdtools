// ==UserScript==
// @name         Snowflake - Color differ per environment - Snowsight interface.
// @description  Snowflake - Color differ per environment - Snowsight interface.
// @namespace    http://tampermonkey.net/
// @version      0.1
// @author       Hans Deragon
// @include      https://<rest of URL of target website here>
// @require      http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js
// @require      https://gist.github.com/raw/2625891/waitForKeyElements.js
// @grant        none
// ==/UserScript==
debugger;

//var selector="#reactRoot > div.content > div.al.am.gi.bf.bg > div.bm.af.ga.gq.gp.go.aq.ai.an.cl.al.ge > div > div > header";
var selector="div > div > header";

// Here, we wait for the element to be loaded and drawn before configuring its color.
// To know where waitForKeyElements() comes from, see:
// https://stackoverflow.com/questions/12897446/userscript-to-wait-for-page-to-load-before-executing-code-techniques
waitForKeyElements(selector, actionFunction);

function actionFunction (jNode) {

  // Default is red for production. If there's a bug and it's not production
  // the red color will alert the user that there is a bug in this script.
  var color = "red"; // "rgba(255, 0, 0, 0.7)";

  if (/<part of FQDN here>/.test(location.href) ) {
    // DV
    color = "#88FF88";
  }
  // else if (/<qa server/.test(location.hostname) ) {
  //   // QA
  //   color = "dodgerblue";
  // }

  console.log("Tampermonkey - Color choosen:  " + color)

  document.querySelector(selector).setAttribute("style", "background-color:" + color + ";color:white");
  var homeimage = document.querySelector(".crumbs")
  if (homeimage) {
      homeimage.setAttribute("style", "background-color:" + color + ";color:white");
  }
}
