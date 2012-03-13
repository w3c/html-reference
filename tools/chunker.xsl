<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:h='http://www.w3.org/1999/xhtml'
                xmlns='http://www.w3.org/1999/xhtml'
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes='h date'
                extension-element-prefixes="exsl"
                version='1.0' id='xslt'>
  <!-- * This stylesheet is based on code from stylesheets in the DocBook -->
  <!-- * XSL Stylesheets distribution; for details, see the -->
  <!-- * "Acknowledgements" comment at the end of this file. -->

  <xsl:template name="write.chunk">
    <xsl:param name="id" select="@id"/>
    <xsl:param name="maturity">ED</xsl:param>
    <xsl:param name="filename" select="''"/>
    <xsl:param name="quiet" select="0"/>
    <xsl:param name="method">html</xsl:param>
    <xsl:param name="encoding">us-ascii</xsl:param>
    <xsl:param name="media-type">text/html; charset=us-ascii</xsl:param>
    <xsl:param name="doctype-public">html</xsl:param>
    <xsl:param name="doctype-system">about:legacy-compat</xsl:param>
    <xsl:param name="indent">yes</xsl:param>
    <xsl:param name="omit-xml-declaration">yes</xsl:param>
    <xsl:param name="cdata-section-elements"></xsl:param>
    <xsl:param name="content"/>
    <xsl:param name="title"/>
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="up">Overview.html</xsl:param>
    <xsl:param name="index">index-of-terms.html</xsl:param>
    <xsl:if test="$quiet = 0">
      <xsl:message>
        <xsl:value-of select="$filename"/>
      </xsl:message>
    </xsl:if>
    <exsl:document href="{$filename}"
      method="{$method}"
      encoding="{$encoding}"
      indent="{$indent}"
      omit-xml-declaration="{$omit-xml-declaration}"
      cdata-section-elements="{$cdata-section-elements}"
      media-type="{$media-type}"
      doctype-public="{$doctype-public}"
      doctype-system="{$doctype-system}"
      >
      <xsl:call-template name="build.chunk">
        <xsl:with-param name="id" select="$id"/>
        <xsl:with-param name="title" select="$title"/>
        <xsl:with-param name="prev" select="$prev"/>
        <xsl:with-param name="next" select="$next"/>
        <xsl:with-param name="up" select="$up"/>
        <xsl:with-param name="index" select="$index"/>
        <xsl:with-param name="content" select="$content"/>
      </xsl:call-template>
    </exsl:document>
  </xsl:template>
  <xsl:template name="build.chunk">
    <xsl:param name="id" select="@id"/>
    <xsl:param name="title"/>
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="up"/>
    <xsl:param name="index"/>
    <xsl:param name="content">
      <xsl:apply-imports/>
    </xsl:param>
    <xsl:variable name="prev-text">
      <xsl:choose>
        <xsl:when test="not($prev)"/>
        <xsl:when test="contains($prev/@id,'.')">
          <xsl:choose>
            <xsl:when test="$prev/@id='meta.name'">
              <xsl:text>meta name</xsl:text>
            </xsl:when>
            <xsl:when test="$prev/@id='meta.charset'">
              <xsl:text>meta charset</xsl:text>
            </xsl:when>
            <xsl:when test="contains($prev/@id,'meta.http-equiv.')">
              <xsl:value-of select="concat('meta http-equiv=',substring-after($prev/@id,'meta.http-equiv.'))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(substring-before($prev/@id,'.'),' type=',substring-after($prev/@id,'.'))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="contains($prev/@id,'-')">
          <xsl:call-template name="string.subst">
            <xsl:with-param name="string" select="$prev/@id"/>
            <xsl:with-param name="target">-</xsl:with-param>
            <xsl:with-param name="replacement">
              <xsl:text> </xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$prev/@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="next-text">
      <xsl:choose>
        <xsl:when test="not($next)"/>
        <xsl:when test="contains($next/@id,'.')">
          <xsl:choose>
            <xsl:when test="$next/@id='meta.name'">
              <xsl:text>meta name</xsl:text>
            </xsl:when>
            <xsl:when test="$next/@id='meta.charset'">
              <xsl:text>meta charset</xsl:text>
            </xsl:when>
            <xsl:when test="contains($next/@id,'meta.http-equiv.')">
              <xsl:value-of select="concat('meta http-equiv=',substring-after($next/@id,'meta.http-equiv.'))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(substring-before($next/@id,'.'),' type=',substring-after($next/@id,'.'))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="contains($next/@id,'-')">
          <xsl:call-template name="string.subst">
            <xsl:with-param name="string" select="$next/@id"/>
            <xsl:with-param name="target">-</xsl:with-param>
            <xsl:with-param name="replacement">
              <xsl:text> </xsl:text>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$next/@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <html id="{$id}">
      <xsl:text>&#10;</xsl:text>
      <head>
        <xsl:text>&#10;</xsl:text>
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
        <title>
          <xsl:value-of select="$title"/>
        </title>
        <xsl:for-each select="//h:link[@rel='stylesheet']">
          <xsl:text>&#10;</xsl:text>
          <xsl:copy-of select="."/>
        </xsl:for-each>
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
        <xsl:call-template name="head.nav.links">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev-text" select="$prev-text"/>
          <xsl:with-param name="next-text" select="$next-text"/>
          <xsl:with-param name="up" select="$up"/>
          <xsl:with-param name="index" select="$index"/>
        </xsl:call-template>
        <xsl:text>&#10;</xsl:text>
      </head>
      <xsl:text>&#10;</xsl:text>
      <body class="chunk" onload="initDfn()">
        <div id="jump-indexes" class="no-number no-toc">
          <div id="jumpIndexA-button"
            role="button" aria-haspopup="true"
            tabindex="0">jump</div>
        </div>
        <xsl:call-template name="header.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev-text" select="$prev-text"/>
          <xsl:with-param name="next-text" select="$next-text"/>
        </xsl:call-template>
        <xsl:copy-of select="$content"/>
        <xsl:call-template name="footer.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="prev-text" select="$prev-text"/>
          <xsl:with-param name="next-text" select="$next-text"/>
        </xsl:call-template>
        <xsl:text>&#10;</xsl:text>
        <script src="js/jump-indexes.js" type="text/javascript"></script>
        <xsl:text>&#10;</xsl:text>
        <script src="js/dfn.js" type="text/javascript"></script>
      </body>
      <xsl:text>&#10;</xsl:text>
    </html>
  </xsl:template>
  <xsl:template name="header.navigation">
    <xsl:param name="prev" select="preceding-sibling::*"/>
    <xsl:param name="next" select="following-sibling::*"/>
    <xsl:param name="prev-text"/>
    <xsl:param name="next-text"/>
    <xsl:text>&#10;</xsl:text>
    <h2 class="chunkpagetitle"><a
        href="{$toc-link}"><xsl:value-of select="/*/h:head/h:title"/></a></h2>
    <xsl:text>&#10;</xsl:text>
    <div class="nav">
      <xsl:text>&#10;</xsl:text>
      <xsl:if test="$prev">
        <span class="nav-prev">
          <a href="{$prev/@id}.html">« <xsl:value-of select="$prev-text"/></a>
        </span>
      </xsl:if>
      <xsl:if test="$next">
        <xsl:text>&#10;</xsl:text>
        <span class="nav-next">
          <a href="{$next/@id}.html"><xsl:value-of select="$next-text"/> »</a>
        </span>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
    </div>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template name="footer.navigation">
    <xsl:param name="prev" select="preceding-sibling::*"/>
    <xsl:param name="next" select="following-sibling::*"/>
    <xsl:param name="prev-text"/>
    <xsl:param name="next-text"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="$prev or $next">
      <hr class="footerbreak"/>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
    <div class="nav">
      <xsl:text>&#10;</xsl:text>
      <xsl:if test="$prev">
        <span class="nav-prev">
          <a href="{$prev/@id}.html">« <xsl:value-of select="$prev-text"/></a>
        </span>
      </xsl:if>
      <xsl:if test="$next">
        <xsl:text>&#10;</xsl:text>
        <span class="nav-next">
          <a href="{$next/@id}.html"><xsl:value-of select="$next-text"/> »</a>
        </span>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
    </div>
  </xsl:template>

  <xsl:template name="head.nav.links">
    <xsl:param name="prev"/>
    <xsl:param name="prev-text"/>
    <xsl:param name="next"/>
    <xsl:param name="next-text"/>
    <xsl:param name="up"/>
    <xsl:param name="index"/>
    <xsl:if test="$prev">
      <link rel="prev" href="{$prev/@id}.html" title="{$prev-text}"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="$next">
      <link rel="next" href="{$next/@id}.html" title="{$next-text}"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="$up">
      <link rel="section" href="{$up}"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="$toc-link">
      <link rel="contents" href="{$toc-link}"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="$index">
      <link rel="index" href="{$index}"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="string.subst">
    <xsl:param name="string"/>
    <xsl:param name="target"/>
    <xsl:param name="replacement"/>
    <xsl:choose>
      <xsl:when test="contains($string, $target)">
        <xsl:variable name="rest">
          <xsl:call-template name="string.subst">
            <xsl:with-param name="string" select="substring-after($string, $target)"/>
            <xsl:with-param name="target" select="$target"/>
            <xsl:with-param name="replacement" select="$replacement"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat(substring-before($string, $target),$replacement,$rest)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- * ***************************************************************** -->
  <!-- *                                 Acknowledgements  -->
  <!-- * ***************************************************************** -->
  <!-- * This stylesheet is based on code from stylesheets in the DocBook -->
  <!-- * XSL Stylesheets distribution, which are distributed with the -->
  <!-- * following copyright statement. -->
  <!-- *  -->
  <!-- * Copyright -->
  <!-- *  -->
  <!-- * Copyright (C) 1999-2007 Norman Walsh -->
  <!-- * Copyright (C) 2003 Jiří Kosek -->
  <!-- * Copyright (C) 2004-2007 Steve Ball -->
  <!-- * Copyright (C) 2005-2008 The DocBook Project -->
  <!-- *  -->
  <!-- * Permission is hereby granted, free of charge, to any person -->
  <!-- * obtaining a copy of this software and associated documentation -->
  <!-- * files (the ``Software''), to deal in the Software without -->
  <!-- * restriction, including without limitation the rights to use, -->
  <!-- * copy, modify, merge, publish, distribute, sublicense, and/or -->
  <!-- * sell copies of the Software, and to permit persons to whom the -->
  <!-- * Software is furnished to do so, subject to the following -->
  <!-- * conditions: -->
  <!-- *  -->
  <!-- * The above copyright notice and this permission notice shall be -->
  <!-- * included in all copies or substantial portions of the Software. -->
  <!-- *  -->
  <!-- * Except as contained in this notice, the names of individuals -->
  <!-- * credited with contribution to this software shall not be used in -->
  <!-- * advertising or otherwise to promote the sale, use or other -->
  <!-- * dealings in this Software without prior written authorization -->
  <!-- * from the individuals in question. -->
  <!-- *  -->
  <!-- * Any stylesheet derived from this Software that is publically -->
  <!-- * distributed will be identified with a different name and the -->
  <!-- * version strings in any derived Software will be changed so that -->
  <!-- * no possibility of confusion between the derived package and this -->
  <!-- * Software will exist. -->
  <!-- *  -->
  <!-- * Warranty -->
  <!-- *  -->
  <!-- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, -->
  <!-- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES -->
  <!-- * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND -->
  <!-- * NONINFRINGEMENT.  IN NO EVENT SHALL NORMAN WALSH OR ANY OTHER -->
  <!-- * CONTRIBUTOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, -->
  <!-- * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING -->
  <!-- * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR -->
  <!-- * OTHER DEALINGS IN THE SOFTWARE. -->
  <!-- *  -->
  <!-- * Contacting the Author -->
  <!-- *  -->
  <!-- * The DocBook XSL stylesheets are maintained by Norman Walsh, -->
  <!-- * <ndw@nwalsh.com>, and members of the DocBook Project, -->
  <!-- * <docbook-developers@sf.net> -->

</xsl:stylesheet>
