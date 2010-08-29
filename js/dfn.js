// dfn.js - makes <dfn> elements link back to all uses of the term.
// No copyright is asserted on this file.

var dfnLinks;
var dfnLinksFile = 'index-of-terms.xhtml';
function initDfn() {
  if (document.body.className.indexOf("chunk") != -1) {
    var request = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
    request.onreadystatechange = function () {
      if (request.readyState == 4) {
        dfnLinks = request.responseXML;
      }
    };
    try {
      request.open('GET', dfnLinksFile, true);
      request.send(null);
    } catch (e) {
      console.log(e);
      return -1;
    }
  } else {
    dfnLinks = document.implementation.createDocument('http://www.w3.org/1999/xhtml', 'html', null);
    var index = dfnLinks.importNode(document.getElementById("index-of-terms"), true);
    dfnLinks.documentElement.appendChild(index);
  }
  document.body.className += " dfnEnabled";
}
var dfnPanel;
document.addEventListener('click', dfnShow, false);
document.addEventListener("keyup", function(e) {
  if(!e) e=window.event;
  var key = e.keyCode ? e.keyCode : e.which;
  if ( key == 27 && dfnPanel) {
    dfnPanel.parentNode.removeChild(dfnPanel);
    dfnPanel = null;
  }
}, true);
function dfnShow(event) {
  if (dfnPanel) {
    dfnPanel.parentNode.removeChild(dfnPanel);
    dfnPanel = null;
  }
  var node = event.target;
  while (node && (node.nodeType != event.target.ELEMENT_NODE || node.tagName != "DFN"))
    node = node.parentNode;
    var panel = document.createElement('div');
    panel.className = 'dfnPanel';
  if (node) {
    var permalinkP = document.createElement('p');
    var permalinkA = document.createElement('a');
    permalinkA.href = '#' + node.id;
    permalinkA.textContent = '#' + node.id;
    permalinkP.appendChild(permalinkA);
    panel.appendChild(permalinkP);
    panelDiv = document.createElement('div');
    if (node.id && dfnLinks) {
      panelDiv.innerHTML = dfnLinks.getElementById(node.id+"_index_items").innerHTML;
      panel.appendChild(panelDiv);
    } else {
      return -1;
    }
    node.appendChild(panel);
    dfnPanel = panel;
  }
}
