<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:h='http://www.w3.org/1999/xhtml'
                xmlns='http://www.w3.org/1999/xhtml'
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes='h date'
                version='1.0' id='xslt'>
  <xsl:output method='html' encoding='us-ascii'
    doctype-public='html'
    doctype-system='about:legacy-compat'
    indent="yes"/>
  <xsl:include href="toc.xsl"/>
  <xsl:include href="chunker.xsl"/>
  <xsl:param name="site">W3C</xsl:param>
  <xsl:param name="chunk" select="0"/>
  <xsl:param name="TOC-file"/>
  <xsl:param name="toc-link" select="concat($TOC-file,'#toc')"/>
  <xsl:param name="aria" select="0"/>
  <xsl:key name="elements" match="*" use="@id"/>
  <xsl:key name="dfn" match="h:dfn" use="substring-after(@id,string-length(@id))"/>
  <xsl:key name="dfnid" match="h:dfn" use="@id"/>
  <xsl:key name="refs" match="h:a[starts-with(@href,'#')]" use="substring-after(@href,'#')"/>
  <xsl:key name="chunk" match="*[@id='elements']/h:section
    |//h:section[count(ancestor::h:section)=0]
    [not(@id='abstract')][not(@id='status')][not(@id='toc-full')]" use="@id"/>
  <xsl:variable name='sectionsID'>this_sections</xsl:variable>
  <xsl:variable name='appendicesID'>appendices</xsl:variable>
  <xsl:variable name='id' select='/*/h:head/h:meta[@name="revision"]/@content'/>
  <xsl:variable name='rev' select='substring-before(substring-after(substring-after($id, " "), " "), " ")'/>
  <xsl:variable name='toc-marker' select='key("elements","toc-full")[1]'/>
  <xsl:variable name='info' select="key('elements','info')"/>
  <xsl:variable name="maturity" select="key('elements','maturity')"/>
  <xsl:variable name="normativity" select="key('elements','normativity')"/>
  <xsl:variable name="source" select="key('elements','source')"/>
  <xsl:variable name="this" select="key('elements','this')"/>
  <xsl:variable name="latest" select="key('elements','latest')"/>
  <xsl:variable name="previous-nodeset" select="key('elements','versions')/*[contains(@class,'previous')]"/>
  <xsl:variable name="person-nodeset" select='key("elements","editors")/*[@ class="person"]'/>
  <xsl:variable name="groupinfo-nodeset" select="key('elements','groupinfo')"/>
  <xsl:template match='/'>
    <xsl:apply-templates select='/*'/>
  </xsl:template>
  <xsl:template match='h:*'>
    <xsl:element name="{name()}">
      <xsl:copy-of select='@*[namespace-uri()=""]'/>
      <xsl:apply-templates select='node()'/>
    </xsl:element>
  </xsl:template>
  <xsl:template match='h:head'>
    <head>
      <xsl:copy-of select='@*[namespace-uri()=""]'/>
      <xsl:apply-templates select='node()'/>
      <xsl:text>&#10;  </xsl:text>
      <xsl:choose>
        <xsl:when test="$maturity = 'ED'">
          <link rel='stylesheet' href='ED.css' type='text/css'/>
        </xsl:when>
        <xsl:when test='
          $maturity="WD"
          or $maturity="FPWD"
          or $maturity="LCWD"
          or $maturity="FPWDLC"
          '>
          <link rel='stylesheet' href='http://www.w3.org/StyleSheets/TR/W3C-WD' type='text/css'/>
        </xsl:when>
        <xsl:otherwise>
          <link rel='stylesheet' href='http://www.w3.org/StyleSheets/TR/W3C-{$maturity}' type='text/css'/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not($chunk=0)">
        <link rel="next" href="intro.html" title="intro"/>
        <link rel="index" href="index-of-terms.html"/>
        <link rel="contents" href="Overview.html#toc"/>
      </xsl:if>
      <xsl:if test="$site='whatwg'">
        <style>
body {
background-image: url(http://www.whatwg.org/images/WD);
background-repeat: repeat-y;
}
h1, h2, h3, .section-title-ref {
color: #3C790A;
}
        </style>
      </xsl:if>
      <xsl:text>&#10;  </xsl:text>
    </head>
  </xsl:template>
  <!-- * suppress meta@charset -->
  <xsl:template match="h:meta[@charset]"/>
  <!-- * suppress duplication of ED CSS link -->
  <xsl:template match="h:head/h:link[contains(@href,'ED')]"/>
  <!-- * remove source CSS link -->
  <xsl:template match="h:head/h:link[@href = 'src.css']"/>
  <!-- * remove info stuff -->
  <xsl:template match="h:*[@id = 'info']"/>
  <!-- * remove source admonition -->
  <xsl:template match="*[@id = 'source-admonition']" priority="10"/>
  <xsl:template name='monthName'>
    <xsl:param name='n' select='1'/>
    <xsl:param name='s' select='"January February March April May June July August September October November December "'/>
    <xsl:choose>
      <xsl:when test='string(number($n))="NaN"'>@@</xsl:when>
      <xsl:when test='$n = 1'>
        <xsl:value-of select='substring-before($s, " ")'/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name='monthName'>
          <xsl:with-param name='n' select='$n - 1'/>
          <xsl:with-param name='s' select='substring-after($s, " ")'/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="h:body">
    <body onload="initDfn()">
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:if test="not($chunk = 0)">
        <xsl:attribute name="class">chunk</xsl:attribute>
      </xsl:if>
      <xsl:call-template name="top"/>
      <xsl:apply-templates/>
      <xsl:call-template name="make-index"/>
    </body>
  </xsl:template>
  <xsl:template name="make-index">
    <xsl:variable name="index-contents">
      <xsl:text>&#10;</xsl:text>
      <div id="index-contents" class="section">
        <xsl:text>&#10;</xsl:text>
        <h2>Index of terms <a class="hash" href="#index-of-terms">#</a>
          <xsl:text> </xsl:text>
          <a class="toc-bak" href="{$TOC-file}#index-toc">T</a>
        </h2>
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each select="key('dfn','')">
          <xsl:sort select="translate(normalize-space(.),
            'abcdefghijklmnopqrstuvwxyz-',
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ '
            )"/>
          <div class="index-entry" id="{@id}_index">
            <xsl:text>&#10;</xsl:text>
            <p class="index-term">
              <xsl:value-of select="normalize-space(.)"/>
              <xsl:if test="starts-with(@id,'refs')">
                <xsl:text> (specification)</xsl:text>
              </xsl:if>
            </p>
            <xsl:text>&#10;</xsl:text>
            <ul>
              <xsl:text>&#10;</xsl:text>
              <li>
                <xsl:call-template name="make-link-with-name-of-named-ancestor-of-node">
                  <xsl:with-param name="id-of-target" select="@id"/>
                </xsl:call-template>
                <xsl:text> </xsl:text>
                <span class="index-notation">(defining instance)</span></li>
              <xsl:text>&#10;</xsl:text>
            </ul>
            <ul id="{@id}_index_items">
              <xsl:choose>
                <xsl:when test="key('refs',@id)">
                  <xsl:call-template name="make-consolidated-index-entry"/>
                </xsl:when>
                <xsl:otherwise>
                  <li class="index-no-references">
                    <a href="" class="placeholder">No references in this document.</a>
                  </li>
                </xsl:otherwise>
              </xsl:choose>
            </ul>
            <xsl:text>&#10;</xsl:text>
          </div>
          <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
      </div>
      <xsl:text>&#10;</xsl:text>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$chunk = 0">
        <div id="index-of-terms" class="section">
          <xsl:copy-of select="exsl:node-set($index-contents)/*/node()"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="write.chunk">
          <xsl:with-param name="id">index-of-terms</xsl:with-param>
          <xsl:with-param name="filename">index-of-terms.html</xsl:with-param>
          <xsl:with-param name="maturity" select="$maturity"/>
          <xsl:with-param name="quiet" select="$quiet"/>
          <xsl:with-param name="content" select="$index-contents"/>
          <xsl:with-param name="title">Index - HTML5</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="write.chunk">
          <xsl:with-param name="method">xml</xsl:with-param>
          <xsl:with-param name="id">index-of-terms</xsl:with-param>
          <xsl:with-param name="filename">index-of-terms.xhtml</xsl:with-param>
          <xsl:with-param name="maturity" select="$maturity"/>
          <xsl:with-param name="quiet" select="$quiet"/>
          <xsl:with-param name="content" select="$index-contents"/>
          <xsl:with-param name="title">Index - HTML5</xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="make-consolidated-index-entry">
    <xsl:variable name="index-items">
      <xsl:for-each select="key('refs',@id)">
        <li><xsl:call-template name="make-link-with-name-of-named-ancestor-of-node"/></li>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="exsl:node-set($index-items)/h:li/h:a">
      <xsl:variable name="contents" select="."/>
      <xsl:choose>
        <xsl:when test="$contents=preceding::h:a"/>
        <xsl:otherwise>
          <li>
            <xsl:copy-of select="$contents"/>
            <xsl:for-each select="following::h:a[.=$contents]">
              <span class="index-counter">
                <xsl:text> [</xsl:text>
                <a href="{@href}">
                  <xsl:value-of select="position() + 1"/>
                </a>
                <xsl:text>]</xsl:text>
              </span>
            </xsl:for-each>
          </li>
          <xsl:text>&#10;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="make-link-with-name-of-named-ancestor-of-node">
    <xsl:param name="id" select="generate-id()"/>
    <xsl:param name="ref" select="substring-after(@href,'#')"/>
    <xsl:param name="id-of-target">
      <xsl:for-each select="key('refs',$ref)">
        <xsl:if test="generate-id() = $id">
          <xsl:value-of select="concat($ref,'_xref',position())"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:param>
    <xsl:param name="section" select="(ancestor::h:section[child::h:h2])[last()]"/>
    <xsl:param name="subsection" select="
      (ancestor::h:dt
      |ancestor::h:dd/preceding-sibling::h:dt[1]
      |(ancestor::h:*[child::h:h2])[last()])[last()]
      "/>
    <xsl:param name="page"
      select="key('elements',$section/@id)/ancestor-or-self::h:section[child::h:h2[@class='element-head']]
      |key('elements',$section/@id)/ancestor-or-self::h:section[(count(ancestor::h:section)=0 and not(@id='elements'))]
      "/>
    <xsl:variable name="link-text">
      <xsl:choose>
        <xsl:when test="$section/*/h:span[@class='element']">
          <xsl:copy-of select="$section/*/h:span[@class='element']"/>
          <xsl:if test="$section/*/h:span[@class='elem-qualifier']">
            <xsl:copy-of select="$section/*/h:span[@class='elem-qualifier']"/>
          </xsl:if>
          <xsl:text> element</xsl:text>
        </xsl:when>
        <xsl:when test="$section/*[@class='datatype-desc']">
          <cite class="index">
            <xsl:value-of select="normalize-space($section/h:h2)"/>
          </cite>
          <xsl:text> data type</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <cite class="index">
            <xsl:value-of select="normalize-space($section/h:h2)"/>
          </cite>
          <xsl:text> section</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$subsection/@id = $section/@id"/>
        <xsl:otherwise>
          <xsl:text>: </xsl:text>
          <xsl:choose>
            <xsl:when test="$subsection/h:h2">
              <cite class="index">
                <xsl:value-of select="normalize-space($subsection/h:h2)"/>
              </cite>
            </xsl:when>
            <xsl:when test="$subsection/self::h:dt">
              <xsl:choose>
                <xsl:when test="$subsection//*[@class='qualified-attribute']">
                  <xsl:copy-of select="$subsection//*[@class='qualified-attribute']"/>
                  <xsl:text> attribute </xsl:text>
                </xsl:when>
                <xsl:when test="$subsection//*[@class='attribute-name']">
                  <xsl:copy-of select="$subsection//*[@class='attribute-name']"/>
                  <xsl:text> attribute</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <cite class="index-dfn">
                    <xsl:value-of select="normalize-space($subsection)"/>
                  </cite>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>@@FIXME@@</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="
            $id-of-target = 'flow-content_xref2'
        or $id-of-target = 'flow-content_xref11'
        or $id-of-target = 'flow-content_xref14'
        or $id-of-target = 'flow-content_xref30'
        or $id-of-target = 'flow-content_xref25'
        or $id-of-target = 'flow-content_xref27'
        or $id-of-target = 'phrasing-content_xref4'
        or $id-of-target = 'phrasing-content_xref14'
        or $id-of-target = 'phrasing-content_xref18'
        or $id-of-target = 'phrasing-content_xref28'
        or $id-of-target = 'phrasing-content_xref32'
        or $id-of-target = 'phrasing-content_xref35'
        "/>
      <xsl:when test="not($chunk = 0)">
        <a href="{$page/@id}.html#{$id-of-target}"><xsl:copy-of select="$link-text"/></a>
      </xsl:when>
      <xsl:otherwise>
        <a href="#{$id-of-target}"><xsl:copy-of select="$link-text"/></a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name='top'>
    <div id="jump-indexes" class="no-number no-toc">
      <div id="jumpIndexA-button"
        role="button" aria-haspopup="true"
        tabindex="0">jump</div>
    </div>
    <div class='head'>
      <xsl:choose>
      <xsl:when test="$maturity = 'ED'">
        <div><img src="HTML5_Badge_128.png" alt="5"/></div>
      </xsl:when>
      <xsl:when test="$site = 'W3C' and not($maturity = 'ED')">
        <div><a href="http://www.w3.org/"><img height="48" width="72" alt="W3C" src="http://www.w3.org/Icons/w3c_home"/></a></div>
      </xsl:when>
      <xsl:when test="$site = 'whatwg'">
      <div><a href="http://www.whatwg.org/"><img src="http://www.whatwg.org/images/logo"></img></a></div>
      </xsl:when>
      </xsl:choose>
      <h1><xsl:value-of select='/*/h:head/h:title'/></h1>
      <xsl:if test='key("elements","subtitle")'>
        <h3 id="subtitle"><xsl:value-of select='key("elements","subtitle")'/></h3>
      </xsl:if>
      <h2>
        <xsl:choose>
          <xsl:when test="$maturity = 'ED'">Unofficial </xsl:when>
          <xsl:otherwise>W3C </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test='
            $maturity="WD"
            or $maturity="FPWD"
            or $maturity="LCWD"
            or $maturity="FPWDLC"
            '>Working Draft</xsl:when>
          <xsl:when test='$maturity="CR"'>Candidate Recommendation</xsl:when>
          <xsl:when test='$maturity="PR"'>Proposed Recommendation</xsl:when>
          <xsl:when test='$maturity="PER"'>Proposed Edited Recommendation</xsl:when>
          <xsl:when test='$maturity="REC"'>Recommendation</xsl:when>
          <xsl:when test='$maturity="WG-NOTE"'>Working Group Note</xsl:when>
          <xsl:when test='$maturity="NOTE"'>Working Group Note</xsl:when>
          <xsl:otherwise>Editor’s Draft</xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <em>
          <xsl:call-template name='date'/>
        </em>
      </h2>

        <xsl:if test="$site = 'W3C' and not($maturity = 'ED')">
          <dl>
        <xsl:choose>
          <xsl:when test='$source and $maturity="ED"'>
            <dt>Editor’s Draft is also available:</dt>
            <dd>
              <a id='latestED' href='{$source}'><xsl:value-of select='$source'/></a>
              <xsl:text> </xsl:text>
              <!-- * <xsl:value-of select='date:date-time()'/> -->
            </dd>
            <xsl:if test='$latest and not($latest = "")'>
              <dt>Latest Published Version:</dt>
              <dd><a href='{$latest}'><xsl:value-of select='$latest'/></a></dd>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
              <dt>This Version:</dt>
              <dd>
                <a href='{$this}'><xsl:value-of select='$this'/></a>
              </dd>
            <xsl:if test='not($latest = "")'>
              <dt>Latest Published Version:</dt>
              <dd><a href='{$latest}'><xsl:value-of select='$latest'/></a></dd>
              <dt class="ed-draft-link">Editor’s Draft:</dt>
              <dd>
                <a id='latestED' href='{$source}'><xsl:value-of select='$source'/></a>
                <xsl:text> </xsl:text>
                <!-- * <xsl:value-of select='date:date-time()'/> -->
              </dd>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test='$previous-nodeset
          and not($previous-nodeset = "")'>
          <dt>Previous Version<xsl:if test='count($previous-nodeset) > 1'>s</xsl:if>:</dt>
          <xsl:for-each select='$previous-nodeset'>
            <dd><a href='{.}'><xsl:value-of select='.'/></a></dd>
          </xsl:for-each>
        </xsl:if>
      </dl>
        </xsl:if>

        <xsl:if test="$person-nodeset">
          <dl>
          <dt>Editor<xsl:if test='count($person-nodeset) &gt; 1'>s</xsl:if>:</dt>
          <xsl:for-each select='$person-nodeset'>
            <xsl:choose>
              <xsl:when test="h:span[contains(@class, 'affiliation') = 'W3C'] and $maturity = 'ED'"/>
              <xsl:when test="not(h:span[contains(@class, 'affiliation')]) and not($maturity = 'ED')"/>
              <xsl:otherwise>
            <dd>
              <xsl:choose>
                <xsl:when test='h:*[contains(@class,"homepage")]'>
                  <a href='{h:*[contains(@class,"homepage")]}'><xsl:value-of select='h:span[@class = "name"]'/></a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select='h:span[@class = "name"]'/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test='h:span[@class = "affiliation"]'>
                <xsl:text>, </xsl:text>
                <xsl:value-of select='h:span[@class = "affiliation"]'/>
              </xsl:if>
              <xsl:if test='h:*[contains(@class,"email")]'>
                <xsl:text> &lt;</xsl:text>
                <a href='mailto:{h:*[contains(@class,"email")]}'><xsl:value-of select='h:*[contains(@class,"email")]'/></a>
                <xsl:text>&gt;</xsl:text>
              </xsl:if>
            </dd>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
          </dl>
        </xsl:if>
      <p>The content of this document is also available as
        <xsl:choose>
          <xsl:when test="$chunk=1">
            <a href="spec.html">a single HTML file</a>.
          </xsl:when>
          <xsl:otherwise>
            <a href="Overview.html">multiple HTML files</a>.
          </xsl:otherwise>
        </xsl:choose>
      </p>
      <xsl:choose>
      <xsl:when test="$site = 'W3C' and not($maturity = 'ED')">
        <p class="copyright"><a href="http://www.w3.org/Consortium/Legal/ipr-notice#Copyright">Copyright</a> © <xsl:value-of select="date:year()"/><xsl:text> </xsl:text><a href="http://www.w3.org/"><abbr title="World Wide Web Consortium">W3C</abbr></a><sup>®</sup> (<a href="http://www.csail.mit.edu/"><abbr title="Massachusetts Institute of Technology">MIT</abbr></a>, <a href="http://www.ercim.eu/"><abbr title="European Research Consortium for Informatics and Mathematics">ERCIM</abbr></a>, <a href="http://www.keio.ac.jp/">Keio</a>), All Rights Reserved. W3C <a href="http://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer">liability</a>, <a href="http://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks">trademark</a> and <a href="http://www.w3.org/Consortium/Legal/copyright-documents">document use</a> rules apply.</p>
      </xsl:when>
      <xsl:otherwise>
        <!-- * <xsl:if test="$person-nodeset"> -->
          <!-- * <div class="main-license"> -->
            <!-- * <p class="copyright"> -->
              <!-- * Copyright © <xsl:value-of select="date:year()"/> -->
              <!-- * <xsl:text> </xsl:text> -->
              <!-- * <xsl:for-each select='$person-nodeset'> -->
                <!-- * <xsl:choose> -->
                  <!-- * <xsl:when test="h:span[contains(@class, 'affiliation') = 'W3C']"/> -->
                  <!-- * <xsl:otherwise> -->
                    <!-- * <span> -->
                      <!-- * <xsl:value-of select='h:span[@class = "name"]'/> -->
                    <!-- * </span> -->
                    <!-- * <xsl:if test="not(position() = last())"> -->
                      <!-- * <xsl:text>, </xsl:text> -->
                    <!-- * </xsl:if> -->
                  <!-- * </xsl:otherwise> -->
                <!-- * </xsl:choose> -->
              <!-- * </xsl:for-each> -->
            <!-- * </p> -->
            <!-- * <xsl:if test="$maturity = 'ED'"> -->
            <!-- * <p class="copyright"> -->
              <!-- * Permission is hereby granted, free of charge, to any -->
              <!-- * person obtaining a copy of this document (the “Document”), to deal -->
              <!-- * in the Document without restriction, including without limitation -->
              <!-- * the rights to use, copy, modify, merge, publish, distribute, -->
              <!-- * sublicense, and/or sell copies of the Document, and to permit -->
              <!-- * persons to whom the Document is furnished to do so, subject to the -->
              <!-- * following conditions: -->
            <!-- * </p> -->
            <!-- * <p class="copyright"> -->
              <!-- * The above copyright notice and this permission notice shall be -->
              <!-- * included in all copies or substantial portions of the Document. -->
            <!-- * </p> -->
            <!-- * </xsl:if> -->
          <!-- * </div> -->
        <!-- * </xsl:if> -->
      </xsl:otherwise>
      </xsl:choose>
    </div>
    <hr/>
  </xsl:template>
  <xsl:template name='date'>
    <xsl:variable name='date'>
      <xsl:value-of select='substring($this, string-length($this) - 8, 8)'/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test='$maturity="ED"'>
        <xsl:value-of select="date:day-in-month()"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="date:month-name()"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="date:year()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select='number(substring($date, 7))'/>
        <xsl:text> </xsl:text>
        <xsl:call-template name='monthName'>
          <xsl:with-param name='n' select='number(substring($date, 5, 2))'/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:value-of select='substring($date, 1, 4)'/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name='maturity'>
    <xsl:choose>
      <xsl:when test='$maturity="FPWD"'>First Public Working Draft</xsl:when>
      <xsl:when test='$maturity="LCWD"'>Last Call Working Draft</xsl:when>
      <xsl:when test='$maturity="FPWDLC"'>First Public Working Draft and Last Call Working Draft</xsl:when>
      <xsl:when test='$maturity="WD"'>Working Draft</xsl:when>
      <xsl:when test='$maturity="CR"'>Candidate Recommendation</xsl:when>
      <xsl:when test='$maturity="PR"'>Proposed Recommendation</xsl:when>
      <xsl:when test='$maturity="PER"'>Proposed Edited Recommendation</xsl:when>
      <xsl:when test='$maturity="REC"'>Recommendation</xsl:when>
      <xsl:when test='$maturity="WG-NOTE"'>Working Group Note</xsl:when>
      <xsl:otherwise>Editor’s Draft</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name='maturity-short'>
    <xsl:choose>
      <xsl:when test='$maturity="FPWD"'>Working Draft</xsl:when>
      <xsl:when test='$maturity="LCWD"'>Working Draft</xsl:when>
      <xsl:when test='$maturity="FPWDLC"'>Working Draft</xsl:when>
      <xsl:when test='$maturity="WD"'>Working Draft</xsl:when>
      <xsl:when test='$maturity="CR"'>Candidate Recommendation</xsl:when>
      <xsl:when test='$maturity="PR"'>Proposed Recommendation</xsl:when>
      <xsl:when test='$maturity="PER"'>Proposed Edited Recommendation</xsl:when>
      <xsl:when test='$maturity="REC"'>Recommendation</xsl:when>
      <xsl:when test='$maturity="WG-NOTE"'>Working Group Note</xsl:when>
      <xsl:when test='$maturity="NOTE"'>Working Group Note</xsl:when>
      <xsl:otherwise>Editor’s Draft</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="h:*[@id = 'abstract']">
    <div id="abstract">
      <xsl:apply-templates/>
      <!-- * <xsl:call-template name="revision-note"/> -->
    </div>
  </xsl:template>
  <xsl:template name='revision-note'>
    <xsl:if test='$maturity="ED"'>
      <div class='ednote'>
        <h4 class='ednoteHeader'>Editorial note</h4>
        <p>This document was generated on
          <b><xsl:value-of select='date:date-time()'/></b>.</p>
      </div>
    </xsl:if>
  </xsl:template>
  <xsl:template match="h:*[@id = 'status']">
    <div>
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:apply-templates select='node()'/>
      <xsl:call-template name="sotd"/>
    </div>
  </xsl:template>
  <xsl:template name='sotd'>
    <xsl:variable name='w3c-ipp' select='$groupinfo-nodeset/*[@id = "w3c-ipp"]'/>
    <xsl:variable name='comments-address' select='$groupinfo-nodeset/*[@id = "comments-address"]'/>
    <xsl:variable name='comments-archive' select='$groupinfo-nodeset/*[@id = "comments-archive"]'/>
    <xsl:variable name='group-url' select='$groupinfo-nodeset/*[@id = "group-url"]'/>
    <xsl:variable name='group-name' select='$groupinfo-nodeset/*[@id = "group-name"]'/>
    <xsl:variable name="activity">
      <a href="{$groupinfo-nodeset/*[@id = 'activity']}">
        <xsl:choose>
          <xsl:when test="$groupinfo-nodeset/*[@id = 'activity'] = 'http://www.w3.org/html/Activity.html'"
            >HTML Activity</xsl:when>
          <xsl:otherwise>[undefined activity]</xsl:otherwise>
        </xsl:choose>
      </a>
    </xsl:variable>
    <xsl:variable name="domain">
      <a href="{$groupinfo-nodeset/*[@id = 'domain']}">
        <xsl:choose>
          <xsl:when test="$groupinfo-nodeset/*[@id = 'domain'] = 'http://www.w3.org/Interaction/'"
            >Interaction Domain</xsl:when>
          <xsl:otherwise>[undefined domain]</xsl:otherwise>
        </xsl:choose>
      </a>
    </xsl:variable>
    <xsl:variable name="source">
      <a href="{$source}">online</a>
    </xsl:variable>
    <xsl:text>&#10;    </xsl:text>
    <xsl:if test="$site = 'W3C' and not($maturity = 'ED')">
    <p>
      <em>
        This section describes the status of this document at the time of
        its publication.  Other documents may supersede this document. A list
        of current W3C publications and the latest revision of this technical
        report can be found in the <a href="http://www.w3.org/TR/">W3C technical
          reports index</a> at http://www.w3.org/TR/.
      </em>
    </p>
    <xsl:text>&#10;    </xsl:text>
    </xsl:if>
    <p>
      <xsl:if test='$maturity!="REC" and $maturity!="WG-NOTE"'>
        This document is the <xsl:call-template name='date'/><xsl:text> </xsl:text>
        <xsl:call-template name='maturity'/> of 
        <cite><xsl:value-of select='/*/h:head/h:title'/></cite>.
      </xsl:if>
      If you’d like to comment on this document, the preferred
      means for commenting is to submit your comments through the
      <a href="https://www.w3.org/Bugs/Public/enter_bug.cgi?product=HTML%20WG&amp;component=HTML5%3A%20The%20Markup%20Language%20%28editor%3A%20Michael%28tm%29%20Smith%29"
        >HTML Working Group bugzilla database, with the <b>Component</b> field set to <code>HTML5: The Markup Language</code></a>.
      Alternatively, you can send comments by e-mail to
      <a href='mailto:{$comments-address}'><xsl:value-of select='$comments-address'/></a>
      (<a href='{$comments-archive}'>archived</a>).
    </p>
    <xsl:text>&#10;    </xsl:text>
    <xsl:if test="$site = 'W3C' and not($maturity = 'ED')">
    <p>
      This document
      <xsl:choose>
        <xsl:when test="$maturity='ED'">
          <xsl:text> is associated with </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> was published by </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      the <a href="{$group-url}"
        ><xsl:copy-of select="normalize-space($group-name)"/></a>,
      part of the <xsl:copy-of select="$activity"/>
      in the W3C <xsl:copy-of select="$domain"/>.
    </p>
    <xsl:text>&#10;    </xsl:text>
    </xsl:if>
    <xsl:copy-of select="document('../src/status.html')"/>
    <xsl:text>&#10;    </xsl:text>
    <xsl:choose>
    <xsl:when test="$site = 'W3C'">
      <xsl:choose>
        <xsl:when test='$maturity="REC"'>
        <p>
          This document has been reviewed by W3C Members, by software developers,
          and by other W3C groups and interested parties, and is endorsed by the
          Director as a W3C Recommendation. It is a stable document and may be
          used as reference material or cited from another document. W3C’s role
          in making the Recommendation is to draw attention to the specification
          and to promote its widespread deployment. This enhances the
          functionality and interoperability of the Web.
        </p>
        </xsl:when>
        <xsl:when test='not($maturity="ED")'>
        <p>
          Publication as a
          <xsl:text> </xsl:text>
          <xsl:call-template name='maturity-short'/> does not imply endorsement by the
          W3C Membership. This is a draft document and may be updated, replaced
          or obsoleted by other documents at any time. It is inappropriate to cite
          this document as other than work in progress.
        </p>
        </xsl:when>
      </xsl:choose>
    <xsl:text>&#10;    </xsl:text>
    <xsl:if test="not($maturity='ED')">
      <p>
        This document was produced by a group operating under the
        <a href='http://www.w3.org/Consortium/Patent-Policy-20040205/'>5 February
          2004 W3C Patent Policy</a>.
        <xsl:if test="$normativity = 'informative'">This document is informative only.</xsl:if>
        W3C maintains a
        <a href='{$w3c-ipp}'>public list of
          any patent disclosures</a> made in connection with the deliverables of
        the group; that page also includes instructions for disclosing a patent.
        An individual who has actual knowledge of a patent which the individual
        believes contains
        <a href='http://www.w3.org/Consortium/Patent-Policy-20040205/#def-essential'>Essential
          Claim(s)</a> must disclose the information in accordance with
        <a href='http://www.w3.org/Consortium/Patent-Policy-20040205/#sec-Disclosure'>section
          6 of the W3C Patent Policy</a>.
      </p>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <p>This is a draft document and may be updated, replaced or
      obsoleted by other documents at any time. It is inappropriate to
      cite this document as other than work in progress.</p>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match='processing-instruction("sref")'>
    <xsl:variable name='id' select='string(.)'/>
    <xsl:variable name='s' select='key("elements",$id)/self::h:section'/>
    <xsl:choose>
      <xsl:when test='$s'>
        <xsl:call-template name='section-number'>
          <xsl:with-param name='section' select='$s'/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>@@</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match='processing-instruction("sdir")'>
    <xsl:variable name='id' select='string(.)'/>
    <xsl:choose>
      <xsl:when test='preceding::h:*[@id=$id]'>above</xsl:when>
      <xsl:when test='following::h:*[@id=$id]'>below</xsl:when>
      <xsl:otherwise>@@</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match='processing-instruction()|comment()'/>
  <xsl:template name='section-number'>
    <xsl:param name='section'/>
    <xsl:param name='sections' select="key('elements',$sectionsID)"/>
    <xsl:param name='appendices' select="key('elements',$appendicesID)"/>
    <xsl:choose>
      <xsl:when test='$section/ancestor::* = $sections'>
        <xsl:for-each select='$section/ancestor-or-self::h:section'>
          <!-- * <xsl:if test='not(position()=1) and position()=last() and 9 > count(preceding-sibling::h:section)'> -->
            <!-- * <xsl:text>0</xsl:text> -->
          <!-- * </xsl:if> -->
          <xsl:value-of select='count(preceding-sibling::h:section) + 1'/>
          <xsl:if test='position() != last()'>
            <xsl:text>.</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test='$section/ancestor::* = $appendices'>
        <xsl:for-each select='$section/ancestor-or-self::h:section'>
          <xsl:choose>
            <xsl:when test='position()=1'>
              <xsl:number value='count(preceding-sibling::h:section) + 1' format='A'/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select='count(preceding-sibling::h:section) + 1'/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test='position() != last()'>
            <xsl:text>.</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match='h:h2'>
    <xsl:variable name="myid">
      <xsl:value-of select="../@id"/>
    </xsl:variable>
    <xsl:variable name="id-adjusted">
      <xsl:value-of select="substring-before($myid, '_')"/>
    </xsl:variable>
    <xsl:variable name="filename">
      <xsl:value-of
        select="concat(substring-before(ancestor-or-self::h:section[../../../h:*[@id = $sectionsID]]/@id, '_'),'.html')"/>
    </xsl:variable>
    <xsl:element name="{name()}" namespace="{namespace-uri()}">
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:if test='$toc-marker
        and not(parent::h:*[contains(@class,"no-number")])'>
        <xsl:variable name='num'>
          <xsl:call-template name='section-number'>
            <xsl:with-param name='section' select='..'/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test='$num != ""'>
          <xsl:value-of select='$num'/>
          <xsl:text>. </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select='node()'/>
      <xsl:if test='@class = "element-head"
        and parent::h:*//*[@class = "obsolete"]'>
        <xsl:text> </xsl:text>
        <span class="obsolete">(obsolete)</span>
      </xsl:if>
      <xsl:text> </xsl:text>
      <xsl:if test='not(../@id = "abstract")
        and not(../@id="status")
        and not(../@id="toc-full")
        '>
        <a class="hash" href="#{$myid}">#</a>
      </xsl:if>
      <xsl:if test='not(../@id = "abstract")
        and not(../@id="status")
        and not(../@id="toc-full")
        and not(parent::h:*[contains(@class,"no-toc")])'>
        <xsl:text> </xsl:text>
        <xsl:choose>
          <xsl:when test="$myid = 'toc'"/>
          <xsl:when test="not($chunk=0)">
            <a class="toc-bak" href="{$TOC-file}#{$myid}-toc">T</a>
          </xsl:when>
          <xsl:otherwise>
            <a class="toc-bak" href="#{$myid}-toc">T</a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:element>
  </xsl:template>
  <xsl:template match='h:*[@class="ednote"]'>
    <div>
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <div class='ednoteHeader'>Editorial note</div>
      <xsl:apply-templates select='node()'/>
    </div>
  </xsl:template>
  <!-- * <xsl:template match='h:*[@class="example"]'> -->
    <!-- * <div> -->
      <!-- * <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/> -->
      <!-- * <div class='exampleHeader'>Example</div> -->
      <!-- * <xsl:apply-templates select='node()'/> -->
    <!-- * </div> -->
  <!-- * </xsl:template> -->
  <!-- * <xsl:template match='h:*[@class="note"]'> -->
    <!-- * <div> -->
      <!-- * <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/> -->
      <!-- * <div class='noteHeader'>Note</div> -->
      <!-- * <xsl:apply-templates select='node()'/> -->
    <!-- * </div> -->
  <!-- * </xsl:template> -->
  <!-- * <xsl:template match="h:dfn"> -->
    <!-- * <dfn> -->
      <!-- * <xsl:copy-of select="@*"/> -->
      <!-- * <xsl:attribute name="onclick">dfnShow()</xsl:attribute> -->
      <!-- * <xsl:copy-of select="node()"/> -->
    <!-- * </dfn> -->
  <!-- * </xsl:template> -->
  <xsl:template match='h:section'>
    <xsl:variable name="content">
      <div>
        <xsl:choose>
          <xsl:when test="(../*[@id=$sectionsID or @id=$appendicesID] or contains(@class,'elementpage')) and not($chunk = 0)">
            <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"][not(name()="id")]'/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:attribute name="class">
          <xsl:value-of select="normalize-space(concat(@class,' section'))"/>
        </xsl:attribute>
        <xsl:apply-templates select='node()'/>
      </div>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not($chunk=0) and (count(ancestor::h:section)=0 or child::h:h2[@class='element-head'])">
        <xsl:call-template name="write.chunk">
          <xsl:with-param name="id" select="@id"/>
          <xsl:with-param name="maturity" select="$maturity"/>
          <xsl:with-param name="quiet" select="$quiet"/>
          <xsl:with-param name="content" select="$content"/>
          <xsl:with-param name="title">
            <xsl:for-each select='h:h2/node()
              [not(contains(@class,"obsoleted-feature"))]
              [not(contains(@class,"changed-feature"))]
              [not(contains(@class,"new-feature"))]
              [not(contains(@class,"spec-link"))]
              '>
              <xsl:copy-of select='.'/>
            </xsl:for-each>
            <xsl:if test='h:h2/node()[contains(@class,"obsoleted-feature")]'>
              <xsl:text>(OBSOLETE)</xsl:text>
            </xsl:if>
            <xsl:if test='h:h2/node()[contains(@class,"changed-feature")]'>
              <xsl:text>(CHANGED)</xsl:text>
            </xsl:if>
            <xsl:if test='h:h2/node()[contains(@class,"new-feature")]'>
              <xsl:text>(NEW)</xsl:text>
            </xsl:if>
            <xsl:text> - HTML5</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="filename">
            <xsl:if test="not($aria=0)">
              <xsl:text>aria/</xsl:text>
            </xsl:if>
            <xsl:value-of select="@id"/>
            <xsl:text>.html</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="prev" select="(key('chunk',@id)/preceding-sibling::h:section[1]
            |key('chunk',@id)/parent::*[self::h:section]
            |key('chunk',@id)/../preceding-sibling::*[@id=$sectionsID]/h:section[last()]
            )[last()]"/>
          <xsl:with-param name="next" select="(key('chunk',@id)/following-sibling::h:section[1]
            |key('chunk',@id)/parent::*[self::h:section]/following-sibling::*[self::h:section]
            |key('chunk',@id)/../following-sibling::*[@id=$appendicesID]/h:section[1]
            )[1]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match='*'/>
  <xsl:template match="h:dfn">
    <dfn>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="role">button</xsl:attribute>
      <xsl:attribute name="tabindex">0</xsl:attribute>
      <xsl:attribute name="aria-haspopup">true</xsl:attribute>
      <xsl:copy-of select="node()"/>
    </dfn>
  </xsl:template>
  <xsl:template match="h:a[@href[starts-with(.,'#')]][ancestor::*[@class='elem-mdl']]"
    priority="100">
    <xsl:choose>
      <xsl:when test="preceding-sibling::h:span[@class='postfix intermixed']
        and contains(@href,'.attrs')
        "/>
      <xsl:otherwise>
        <!-- * if we don’t inject this span, the CSS-generated dot/period -->
        <!-- * we append to content models ends up getting underlined as -->
        <!-- * part of any preceding hyperlink -->
        <span>
          <xsl:call-template name="link-handler" select="."/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="h:a[@href[starts-with(.,'#')]]" name="link-handler">
    <xsl:variable name="id">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:variable>
    <xsl:variable name="ref" select="substring-after(@href,'#')"/>
    <xsl:choose>
      <xsl:when test="preceding-sibling::h:span[@class='postfix intermixed']
        and ancestor::*[@class='elem-mdl']
        and contains(@href,'.attrs')
        "/>
      <xsl:otherwise>
        <!-- * if we don’t inject this span, the CSS-generated dot/period -->
        <!-- * we append to content models ends up getting underlined as -->
        <!-- * part of any preceding hyperlink -->
    <!-- * href ID references in chunked output need to become intra-file -->
    <!-- * references to IDs that are to targets in other files; so this -->
    <!-- * template prepends the correct file name to all "bare" -->
    <!-- * (filename-less) fragment href ID references -->
    <xsl:if test="ancestor::*[@class='content-models']
    and not(ancestor::*[@id='common-models'])
    and not(ancestor::*[@id='datatypes'])
    and not(@href='#normal-character-data')
    and not(@href='#non-replaceable-character-data')
    and not(@href='#replaceable-character-data')
    and not(@href='#phrasing-content')
    and not(@href='#flow-content')
    and not(starts-with(@href,'#common.'))
    and not(starts-with(@href,'#global.'))
    ">
      <xsl:choose>
        <xsl:when test="following-sibling::*[1][@class='postfix zeroormore']">
          <span>zero or more </span>
        </xsl:when>
        <xsl:when test="following-sibling::*[1][@class='postfix optional']">
          <span>an optional </span>
        </xsl:when>
        <xsl:when test="following-sibling::*[1][@class='postfix oneormore']">
          <span>one or more </span>
        </xsl:when>
        <xsl:when test="ancestor::*[@class='agroupof']">
          <xsl:choose>
            <xsl:when test="contains(@href,'.attrs.')">
              <span>a </span>
            </xsl:when>
            <xsl:otherwise>
              <span>one </span>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="following-sibling::*
        ">
          <span>one </span>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="not($chunk=0)">
        <xsl:variable name="href" select="substring-after(@href,'#')"/>
        <xsl:variable name="section"
          select="key('elements',$href)/ancestor-or-self::h:section[child::h:h2[@class='element-head']]
          |key('elements',$href)/ancestor::h:section[(count(ancestor::h:section)=0 and not(@id='elements'))]
          "/>
        <xsl:choose>
          <xsl:when test="$href='syntax'">
            <a>
              <xsl:copy-of select="@*"/>
              <xsl:attribute name="href">
                <xsl:text>syntax.html</xsl:text>
              </xsl:attribute>
              <xsl:apply-templates/>
            </a>
          </xsl:when>
          <xsl:when test="$href='elements'">
            <a>
              <xsl:copy-of select="@*"/>
              <xsl:attribute name="href">
                <xsl:text>elements.html</xsl:text>
              </xsl:attribute>
              <xsl:apply-templates/>
            </a>
          </xsl:when>
          <xsl:when test="$href='html-elements'">
            <a>
              <xsl:copy-of select="@*"/>
              <xsl:attribute name="href">
                <xsl:text>elements.html#html-elements</xsl:text>
              </xsl:attribute>
              <xsl:apply-templates/>
            </a>
          </xsl:when>
          <xsl:when test="$href='common-models'">
            <a>
              <xsl:copy-of select="@*"/>
              <xsl:attribute name="href">
                <xsl:text>common-models.html</xsl:text>
              </xsl:attribute>
              <xsl:apply-templates/>
            </a>
          </xsl:when>
          <xsl:when test="$href='global-attributes'">
            <a>
              <xsl:copy-of select="@*"/>
              <xsl:attribute name="href">
                <xsl:text>global-attributes.html</xsl:text>
              </xsl:attribute>
              <xsl:apply-templates/>
            </a>
          </xsl:when>
          <xsl:when test=". ='common.attrs'">
            <a>
              <xsl:copy-of select="@*"/>
              <xsl:attribute name="href">
                <xsl:text>global-attributes.html</xsl:text>
              </xsl:attribute>
              <xsl:text>global attributes</xsl:text>
            </a>
          </xsl:when>
          <xsl:when test=". = 'embed.attrs.other'"/>
          <xsl:when test="$href='forms-attributes'">
            <a>
              <xsl:copy-of select="@*"/>
              <xsl:attribute name="href">
                <xsl:text>forms-attributes.html</xsl:text>
              </xsl:attribute>
              <xsl:apply-templates/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="not($section/@id)">
              <xsl:message>
                <xsl:text>XXX UNDEFINED: </xsl:text>
                <xsl:value-of select="$href"/>
                <xsl:text> in </xsl:text>
                <xsl:value-of select="ancestor::h:section[child::h:h2[@class='element-head']]/@id
                  |ancestor::h:section[(count(ancestor::h:section)=0 and not(@id='elements'))]/@id"/>
                <xsl:text>.html</xsl:text>
              </xsl:message>
            </xsl:if>
            <a>
              <xsl:copy-of select="@*"/>
              <xsl:if test="not(@id) and key('dfnid',$ref)">
                <xsl:for-each select="key('refs',$ref)">
                  <xsl:if test="generate-id() = $id">
                    <xsl:attribute name="id">
                      <xsl:value-of select="concat($ref,'_xref',position())"/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:for-each>
              </xsl:if>
              <xsl:attribute name="href">
                <xsl:value-of select="concat($section/@id,'.html')"/>
                <xsl:value-of select="@href"/>
              </xsl:attribute>
              <xsl:apply-templates/>
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test=". = 'common.attrs'">
        <a>
          <xsl:attribute name="href">#global-attributes</xsl:attribute>
          <xsl:text>global attributes</xsl:text>
        </a>
      </xsl:when>
      <xsl:when test=". = 'embed.attrs.other'"/>
      <xsl:otherwise>
        <a>
          <xsl:copy-of select="@*"/>
          <xsl:if test="key('dfnid',$ref)">
            <xsl:for-each select="key('refs',$ref)">
              <xsl:if test="generate-id() = $id">
                <xsl:attribute name="id">
                  <xsl:value-of select="concat($ref,'_xref',position())"/>
                </xsl:attribute>
              </xsl:if>
            </xsl:for-each>
          </xsl:if>
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="
    not(.='embed.attrs.other')
    and not(starts-with(.,'common.'))
    and not(starts-with(.,'global.'))
    and not(.='shape')
    and not(.='http-equiv')
    and not(.='wrap')
    and not(following-sibling::*[1][self::h:span[contains(@class,'optional')]])
    and ancestor::h:*[@class='attr-content-models']
    ">
      <span class="postfix required" title="REQUIRED">&#x2605;</span>
    </xsl:if>
    <xsl:if test="ancestor::*[@class='content-models']
    and not(ancestor::*[@id='common-models'])
    and not(ancestor::*[@id='datatypes'])
    and not(@href='#normal-character-data')
    and not(@href='#non-replaceable-character-data')
    and not(@href='#replaceable-character-data')
    and not(@href='#phrasing-content')
    and not(@href='#flow-content')
    and not(starts-with(@href,'#common.'))
    and not(starts-with(@href,'#global.'))
    ">
      <xsl:choose>
        <xsl:when test="
        ancestor::h:*[@class='content-models']
        and following-sibling::*[1][self::h:*[contains(@class,'zeroormore')]]
        ">
          <span> elements</span>
          <xsl:if test="following-sibling::*[not(contains(@class,'postfix'))][not(contains(.,'.attrs'))]">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="
        ancestor::h:*[@class='content-models']
        and following-sibling::*[1][self::h:*[contains(@class,'optional')]]
        ">
          <xsl:choose>
            <xsl:when test="contains(@href,'.attrs.')">
              <span> attribute</span>
            </xsl:when>
            <xsl:otherwise>
              <span> element</span>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="following-sibling::*[not(contains(@class,'postfix'))][not(contains(.,'.attrs'))]">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="
        ancestor::h:*[@class='content-models']
        and following-sibling::*[1][self::h:*[contains(@class,'oneormore')]]
        ">
          <span> elements</span>
          <xsl:if test="following-sibling::*[not(contains(@class,'postfix'))][not(contains(.,'.attrs'))]">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="ancestor::*[@class='agroupof']
        ">
          <xsl:choose>
            <xsl:when test="contains(@href,'.attrs.')">
              <span> attribute</span>
            </xsl:when>
            <xsl:otherwise>
              <span> element</span>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="following-sibling::*[not(contains(@class,'postfix'))][not(contains(.,'.attrs'))]">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="following-sibling::*
        ">
          <span> element</span>
          <xsl:if test="following-sibling::*[not(contains(@class,'postfix'))][not(contains(.,'.attrs'))]">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:otherwise>
  </xsl:choose>
  </xsl:template>
  <xsl:template match="h:a[. = 'datetime']">
    <a href="#time.attrs.datetime">datetime (any)</a>
  </xsl:template>
  <xsl:template match="h:a[. = 'datetime.dateonly']">
    <a href="#time.attrs.datetime.dateonly">datetime (date only)</a>
  </xsl:template>
  <xsl:template match="h:a[. = 'datetime.tz']">
    <a href="#time.attrs.datetime.tz">datetime (date and time)</a>
  </xsl:template>
  <xsl:template match="h:div[@id='tocjump']">
    <div id="tocjump" class="skip-link" style="text-align: center">
      <a href="{$toc-link}">Skip to Table of Contents</a>
    </div>
  </xsl:template>
  <xsl:template match="*[@class='toc']">
    <div class="toc">
      <xsl:copy-of select='@*[namespace-uri()="" or namespace-uri="http://www.w3.org/XML/1998/namespace"]'/>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates select='node()'/>
      <xsl:choose>
        <xsl:when test="@id='toc'">
          <xsl:call-template name="toc">
            <xsl:with-param name="unexpanded" select="1"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="@id='toc-full'">
          <xsl:call-template name="toc"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="..">
            <xsl:call-template name="toc1">
              <xsl:with-param name="main-toc">0</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  <xsl:template match="h:span[@class='agroupof']
    [following-sibling::*[1][@class='postfix zeroormore']]
    [ancestor::*[@class='content-models']]
  ">
    <span>zero or more of: </span>
    <span class="agroupof">
      <xsl:apply-templates/>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>
  <xsl:template match="h:span[@class='agroupof']
    [following-sibling::*[1][@class='postfix optional']]
    [ancestor::*[@class='content-models']]
  ">
    <span>optionally: </span>
    <span class="agroupof">
      <xsl:apply-templates/>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>
  <xsl:template match="h:span[@class='agroupof']
    [following-sibling::*[1][@class='postfix oneormore']]
    [ancestor::*[@class='content-models']]
  ">
    <span>one or more of: </span>
    <span class="agroupof">
      <xsl:apply-templates/>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>
  <xsl:template match="h:span[@class='postfix zeroormore']"/>
  <xsl:template match="h:span[@class='postfix optional']"/>
  <xsl:template match="h:span[@class='postfix oneormore']"/>
  <xsl:template match="h:span[@class='postfix intermixed']">
    <xsl:choose>
      <xsl:when test="following-sibling::h:*[1][self::h:a[contains(@href,'.attrs')]]
        and ancestor::*[@class='elem-mdl']
      "/>
      <xsl:when test="ancestor::*[@class='attr-content-models']">
        <span class="postfix intermixed">&amp;</span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="h:*[@class='elem-mdl']
    [child::*[1][self::h:a[@href='#phrasing-content']]]
    [following-sibling::*[1][@class='postfix or']
      [following-sibling::*[1]
        [self::h:*[@class='elem-mdl']
          [child::*[1][self::h:a[@href='#flow-content']]]
        ]
      ]
    ]
    ">
    <xsl:call-template name="transparent"/>
  </xsl:template>
  <xsl:template match="h:*[@class='elem-mdl']
    [child::*[1][self::h:a[@href='#flow-content']]]
    [following-sibling::*[1][@class='postfix or']
      [following-sibling::*[1]
        [self::h:*[@class='elem-mdl']
          [child::*[1][self::h:a[@href='#phrasing-content']]]
        ]
      ]
    ]
    ">
    <xsl:call-template name="transparent"/>
  </xsl:template>
  <xsl:template match="h:*[@class='postfix or']
    [preceding-sibling::*[1]
      [self::h:*[@class='elem-mdl']
        [child::*[1][self::h:a[@href='#flow-content']]]
      ]
    ]
    [following-sibling::*[1]
      [self::h:*[@class='elem-mdl']
        [child::*[1][self::h:a[@href='#phrasing-content']]]
      ]
    ]
  "/>
  <xsl:template match="h:*[@class='postfix or']
    [preceding-sibling::*[1]
      [self::h:*[@class='elem-mdl']
        [child::*[1][self::h:a[@href='#phrasing-content']]]
      ]
    ]
    [following-sibling::*[1]
      [self::h:*[@class='elem-mdl']
        [child::*[1][self::h:a[@href='#flow-content']]]
      ]
    ]
  "/>
  <xsl:template match="h:*[@class='elem-mdl']
    [child::*[1][self::h:a[@href='#phrasing-content']]]
    [preceding-sibling::*[1][@class='postfix or']
      [preceding-sibling::*[1]
        [self::h:*[@class='elem-mdl']
          [child::*[1][self::h:a[@href='#flow-content']]]
        ]
      ]
    ]
  "/>
  <xsl:template match="h:*[@class='elem-mdl']
    [child::*[1][self::h:a[@href='#flow-content']]]
    [preceding-sibling::*[1][@class='postfix or']
      [preceding-sibling::*[1]
        [self::h:*[@class='elem-mdl']
          [child::*[1][self::h:a[@href='#phrasing-content']]]
        ]
      ]
    ]
  "/>
  <xsl:template name="transparent">
    <xsl:variable name="terminology.html">
      <xsl:if test="$chunk=1">terminology.html</xsl:if>
    </xsl:variable>
    <p class="elem-mdl"><span class="transparent"><a href="{$terminology.html}#transparent">transparent</a>
      <xsl:text> (</xsl:text>
      <span class="postfix or">either</span>
      <xsl:text> </xsl:text>
      phrasing content
      <xsl:text> </xsl:text>
      <span class="postfix or">or</span>
      <xsl:text> </xsl:text>
      flow content
      <xsl:text>)</xsl:text>
    </span>
    </p>
  </xsl:template>
</xsl:stylesheet>
