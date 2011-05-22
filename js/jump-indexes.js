// No copyright is asserted on this file.

var jumpIndexA;
document.addEventListener('click', window.showjumpIndexA, false);
document.addEventListener("keydown", function (e) {
  if (!e) {
    e = window.event;
  }
  var key = e.keyCode ? e.keyCode : e.which;
  if (key === 27 && jumpIndexA) {
    document.getElementById('jumpIndexA-button').firstChild.textContent = "jump";
    jumpIndexA.parentNode.removeChild(jumpIndexA);
    jumpIndexA = null;
  }
  if ((key === 32 || key === 13) && !jumpIndexA) {
    window.showjumpIndexA(e);
    if (e.target.id === "jumpIndexA-button") {
      e.preventDefault();
      e.stopPropagation();
      e.returnValue = false;
      e.cancelBubble = true;
      return false;
    }
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
  ["global-attributes", "index-of-terms", "toc", "toggle"]
];

function showjumpIndexA(event) {
  var node = event.target, indexDiv, i, j, items, len, jlen, ul, li, a,
  separator, itemName, fragID, pageNode;
  if (jumpIndexA) {
    document.getElementById('jumpIndexA-button').firstChild.textContent = "jump";
    jumpIndexA.parentNode.removeChild(jumpIndexA);
    jumpIndexA = null;
  } else if (event.target.id === 'jumpIndexA-button') {
    indexDiv = document.createElement('div');
    indexDiv.id = 'jumpIndexA';
    ul = document.createElement('ul');
    for (i = 0, len = itemList.length; i < len; i = i + 1) {
      li = document.createElement('li');
      items = itemList[i];
      for (j = 0, jlen = items.length; j < jlen; j = j + 1) {
        a = document.createElement('a');
        separator = document.createTextNode(" ");
        itemName = items[j];
        if (document.body.className.indexOf("chunk") !== -1) {
          if (itemName === 'toc') {
            a.setAttribute("href", "Overview.html#toc");
          } else if (itemName === 'toggle') {
            itemName = "";
            if (document.documentElement.id) {
              itemName = "#" + document.documentElement.id;
            }
            if (window.location.hash) {
              itemName = "#" + window.location.hash.substring(1, window.location.hash.length);
            }
            a.setAttribute("href", "spec.html" + itemName);
            itemName = "single";
          } else {
            a.setAttribute("href", itemName + ".html");
          }
        } else {
          if (itemName === 'toc') {
            a.setAttribute("href", "#toc");
          } else if (itemName === 'toggle') {
            itemName = "Overview.html";
            if (window.location.hash) {
              fragID = window.location.hash.substring(1, window.location.hash.length);
              if (fragID === "index-of-terms") {
                itemName = "index-of-terms.html";
              } else if (fragID === "elements") {
                itemName = "elements.html";
              } else {
                pageNode = document.evaluate("//*[@id = '" + fragID + "']/ancestor-or-self::div[contains(@class,'section')][count(ancestor::div[contains(@class,'section')])=0 and not(@id='elements')]|//*[@id = '" + fragID + "']/ancestor-or-self::div[contains(@class,'section')][child::h2[@class='element-head']]",
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
        if (itemName === 'global-attributes') {
          itemName = 'global attributes';
          li.setAttribute("class", "jumpIndexA-other");
        }
        if (itemName === 'index-of-terms') {
          itemName = 'terms';
        }
        a.textContent = itemName;
        li.appendChild(a);
        li.appendChild(separator);
        ul.appendChild(li);
      }
      indexDiv.appendChild(ul);
    }
    document.getElementById('jumpIndexA-button').firstChild.textContent = "(ESC to close)";
    document.getElementById('jumpIndexA-button').appendChild(indexDiv);
    jumpIndexA = indexDiv;
  }
}
