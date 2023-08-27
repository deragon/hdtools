// ==UserScript==
// @name         Snowflake - Color differ per environment - Classic interface.
// @description  Snowflake - Color differ per environment - Classic interface.
// @namespace    http://tampermonkey.net/
// @version      0.1
// @author       Hans Deragon
// @include      https://<rest of URL of target website here>
// @require      http://ajax.googleapis.com/ajax/libs/jquery/3.7.0/jquery.min.js
// @require      https://gist.github.com/raw/2625891/waitForKeyElements.js
// @grant        none
// ==/UserScript==
// debugger;

// Here, we wait for the element to be loaded and drawn before configuring its color.
// To know where waitForKeyElements() comes from, see:
// https://stackoverflow.com/questions/12897446/userscript-to-wait-for-page-to-load-before-executing-code-techniques

// The id changes with time, thus we search for the one that starts (operator '^=') with this string.
waitForKeyElements("span[id^='home-common-dock-logo']", actionFunction, true);


function actionFunction (jNode) {

  // Default is red for production. If there's a bug and it's not production
  // the red color will alert the user that there is a bug in this script.
  var color = "red"; // "rgba(255, 0, 0, 0.7)";

  if ( /(<other string here>|<part of FQDN here>)/.test(location.hostname) ) {
    // DEV
    color = "#88FF88";
  }
  // else if (/<qa server/.test(location.hostname) ) {
  //   // QA
  //   color = "dodgerblue";
  // }

  console.log("Tampermonkey - Color choosen:  " + color)
  // console.log(jNode);
  // console.log("Tampermonkey - jNode:  " + jNode['0'].innerText);
  // console.log("Tampermonkey - jNode:  " + JSON.stringify(jNode, null, 4));  // Does not work; does not show content of jNode.

  jNode['0'].setAttribute("style","background-color:" + color);
}
