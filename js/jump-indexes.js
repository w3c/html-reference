// No copyright is asserted on this file.

var jumpIndexA;
document.addEventListener('click', showjumpIndexA, false);
document.addEventListener("keyup", function(e) {
  if(!e) e=window.event;
  var key = e.keyCode ? e.keyCode : e.which;
  if ( key == 27 && jumpIndexA) {
    jumpIndexA.parentNode.removeChild(jumpIndexA);
    jumpIndexA = null;
  }
}, true);

var itemList =
[
  ["a", "abbr", "address", "area", "article", "aside", "audio"],
  ["b", "base", "bdi", "bdo", "blockquote", "body", "br", "button"],
  ["canvas", "caption", "cite", "code", "col", "colgroup", "command"],
  ["datalist", "dd", "del", "details", "dfn", "dir", "div", "dl", "dt"],
  ["em", "embed", "fieldset", "figcaption", "figure", "footer", "form"],
  ["h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "hr", "html"],
  ["i", "iframe", "img", "input", "ins", "kbd", "keygen"],
  ["label", "legend", "li", "link", "map", "mark", "menu", "meta", "meter"],
  ["nav", "noscript", "object", "ol", "optgroup", "option", "output"],
  ["p", "param", "pre", "progress", "q", "rp", "rt", "ruby"],
  ["s", "samp", "script", "section", "select", "small", "source", "span"],
  ["strong", "style", "sub", "summary", "sup"],
  ["table", "tbody", "td", "textarea", "tfoot", "th", "thead", "time", "title"],
  [ "tr", "track", "u", "ul", "var", "video", "wbr"],
  ["global-attributes","index-of-terms","toc","toggle"]
  ];

function showjumpIndexA(event) {
  var node = event.target;
  if (jumpIndexA) {
    jumpIndexA.parentNode.removeChild(jumpIndexA);
    jumpIndexA = null;
  } else if (node.id == 'jumpIndexA-button') {
    var indexDiv = document.createElement('div');
    var items;
    indexDiv.className = 'jumpIndexA';
    for (var i=0, len=itemList.length; i<len; ++i) {
      var p = document.createElement('p');
      items = itemList[i];
      for (var j=0, jlen=items.length; j<jlen; ++j) {
        var a = document.createElement('a');
        var separator = document.createTextNode(" ");
        var itemName = items[j];
        if (document.body.className.indexOf("chunk") != -1) {
          if (itemName == 'toc') {
            a.setAttribute("href", "Overview.html#toc");
          } else if (itemName == 'toggle') {
            itemName = "";
            if (document.documentElement.id) {
              itemName = "#" + document.documentElement.id;
            }
            if (window.location.hash) {
              itemName = "#" + window.location.hash.substring(1,window.location.hash.length);
            }
            a.setAttribute("href", "spec.html" + itemName);
            itemName = "single";
          } else {
            a.setAttribute("href", itemName + ".html");
          }
        } else {
          if (itemName == 'toc') {
            a.setAttribute("href", "#toc");
          } else if (itemName == 'toggle') {
            itemName = "Overview.html";
            if (window.location.hash) {
              var fragID = window.location.hash.substring(1,window.location.hash.length);
              if (fragID == "index-of-terms") {
                itemName = "index-of-terms.html";
              } else if (fragID == "elements") {
                itemName = "elements.html";
              } else {
                var pageNode = document.evaluate("//*[@id = '" + fragID +"']/ancestor-or-self::div[contains(@class,'section')][count(ancestor::div[contains(@class,'section')])=0 and not(@id='elements')]|//*[@id = '" + fragID + "']/ancestor-or-self::div[contains(@class,'section')][child::h2[@class='element-head']]",
                    document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
                if (pageNode) {
                  itemName = pageNode.id + ".html" + window.location.hash;
                }
              }
            }
            a.setAttribute("href", itemName);
            itemName = "multi";
          } else {
            a.setAttribute("href", "#" + itemName);
          }
        }
        if (itemName == 'global-attributes') {
          itemName = 'global attributes';
          p.setAttribute("class", "jumpIndexA-other");
        }
        if (itemName == 'index-of-terms') {
          itemName = 'terms';
        }
        a.textContent = itemName;
        p.appendChild(a);
        p.appendChild(separator);
      }
      indexDiv.appendChild(p);
    }
    var posY = event.pageY - 371;
    var posX = event.pageX - 449;
    indexDiv.setAttribute("style","top: " + posY+ "px; left: " + posX + "px;");
    document.getElementById('jump-indexes').appendChild(indexDiv);
    jumpIndexA = indexDiv;
  }
}
