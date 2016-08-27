// ==UserScript==
// @name         Warning for Skype
// @namespace    https://github.com/Autotonic/
// @version      0.1
// @description  Warn when closing Skype
// @author       Aida
// @match        https://web.skype.com/en/
// @grant        none
// ==/UserScript==

window.onbeforeunload=function(e){return 'Are you sure you want to close Skype?';};
