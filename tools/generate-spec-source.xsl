<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns='http://www.w3.org/1999/xhtml'
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:s='http://www.ascc.net/xml/schematron'
  xmlns:str="http://exslt.org/strings"
  xmlns:exsl="http://exslt.org/common"
  version='1.0'
  exclude-result-prefixes="h s str exsl"
  >
  <xsl:output method="xml"/>
  <xsl:param name="show-content-models" select="0"/>
  <xsl:param name="aria" select="0"/>
  <xsl:param name="rnc-html" select="document('../schema.html')"/>
  <xsl:param name="attributes" select="document('../src/attributes.html')"/>
  <xsl:param name="head" select="document('../src/head.html')"/>
  <xsl:param name="header" select="document('../src/header.src.html')"/>
  <xsl:key name="elements" match="*" use="@id"/>
  <xsl:key name="datatypes" match="h:dt" use="."/>
  <xsl:key name="filename-map" match="ul" use="li"/>
  <xsl:key name="interface-name" match="pre[@class='idl']" use="dfn/@id"/>
  <xsl:variable name="htmlelement-filename">
    <xsl:call-template name="get-spec-filename">
      <xsl:with-param name="ref">#htmlelement</xsl:with-param>
      <xsl:with-param name="base">http://dev.w3.org/html5/spec/</xsl:with-param>
      <xsl:with-param name="fragment-file">../fragment-links-full.html</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="assertions">
    <!-- * FIXME: really should be doing this with keys... -->
    <xsl:for-each
      select="document('../syntax/relaxng/assertions.sch')//*[@context]">
      <s:rule>
        <xsl:choose>
          <xsl:when test="contains(@context,'|')">
            <xsl:for-each select="str:tokenize(@context,'|')">
              <xsl:call-template name="get-context"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="@context">
              <xsl:call-template name="get-context"/>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="s:report|s:assert">
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </s:rule>
    </xsl:for-each>
  </xsl:variable>
  <!-- * <xsl:variable name="warnings"> -->
    <!-- * <xsl:for-each -->
      <!-- * select="document('../syntax/relaxng/warnings.sch')//*[@context]"> -->
      <!-- * <s:rule> -->
        <!-- * <xsl:choose> -->
          <!-- * <xsl:when test="contains(@context,'|')"> -->
            <!-- * <xsl:for-each select="str:tokenize(@context,'|')"> -->
              <!-- * <xsl:call-template name="get-context"/> -->
            <!-- * </xsl:for-each> -->
          <!-- * </xsl:when> -->
          <!-- * <xsl:otherwise> -->
            <!-- * <xsl:for-each select="@context"> -->
              <!-- * <xsl:call-template name="get-context"/> -->
            <!-- * </xsl:for-each> -->
          <!-- * </xsl:otherwise> -->
        <!-- * </xsl:choose> -->
        <!-- * <xsl:for-each select="s:report|s:assert"> -->
          <!-- * <xsl:copy-of select="."/> -->
        <!-- * </xsl:for-each> -->
      <!-- * </s:rule> -->
    <!-- * </xsl:for-each> -->
  <!-- * </xsl:variable> -->
  <xsl:template match="/">
    <html xml:lang="en">
      <xsl:text>&#10;  </xsl:text>
      <xsl:copy-of select="$head"/>
      <xsl:text>&#10;  </xsl:text>
      <body>
        <xsl:copy-of select="$header//*[local-name() = 'body']/node()"/>
        <div id="this_sections">
          <xsl:text>&#10;      </xsl:text>
          <xsl:copy-of select="document('../src/intro-scope.html')"/>
          <xsl:text>&#10;      </xsl:text>
          <xsl:copy-of select="document('../src/terms.html')"/>
          <xsl:text>&#10;    </xsl:text>
          <xsl:copy-of select="document('../src/documents.html')"/>
          <xsl:text>&#10;    </xsl:text>
          <xsl:copy-of select="document('../src/syntax.html')"/>
          <xsl:text>&#10;        </xsl:text>
          <section id="elements-by-function">
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="make.elements.by.function"/>
            <xsl:text>&#10;</xsl:text>
          </section>
          <section id="elements">
            <xsl:text>&#10;        </xsl:text>
            <h2>HTML elements</h2>
            <!-- * make the Elements section -->
            <p>The complete set of
              <dfn
                id="html-elements"
                title="html-elements">HTML elements</dfn>
              is the set of elements described in the following
              sections.</p>
            <p>In addition to the HTML elements listed below, the
              <code class="element">math</code> element from the MathML namespace and the
              <code class="element">svg</code> element from the SVG namespace are allowed in
              documents wherever 
              <a href="#phrasing-content">phrasing content</a> is allowed.</p>
            <div class="toc"/>
            <xsl:apply-templates select="descendant::*[local-name() = 'element'][@name]">
              <xsl:sort select="@name"/>
            </xsl:apply-templates>
          </section>
          <xsl:text>&#10;    </xsl:text>
          <section id="common-models">
            <xsl:text>&#10;        </xsl:text>
            <h2>Common content models</h2>
            <p>This section describes content models that are
              referenced by a number of different element
              descriptions in the
              <i class="subsection-citation">Content model</i>
              subsections of the per-element documentation in the
              <a href="#elements">HTML elements</a>
              section.</p>
            <xsl:for-each
              select="$rnc-html//*[@class='pattern']
              [starts-with(@id,'common.elem.')]">
              <xsl:sort select="@id"/>
              <xsl:variable name="type">
                <xsl:call-template name="substring-after-last">
                  <xsl:with-param name="input" select="@id"/>
                  <xsl:with-param name="substr">.</xsl:with-param>
                </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="type-tc">
                <xsl:value-of select="translate(
                  substring($type,1,1),
                  'abcdefghijklmnopqrstuvwxyz',
                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                  )"/><xsl:value-of
                  select="substring($type,2)"/>
              </xsl:variable>
              <xsl:text>&#10;      </xsl:text>
              <section id="common.elem.{$type}">
              <xsl:text>&#10;        </xsl:text>
                <xsl:choose>
                  <xsl:when test="$type='anything'">
                    <h2 class="common-subhead">Any element from any namespace</h2>
                  </xsl:when>
                  <xsl:otherwise>
                    <h2 class="common-subhead"><xsl:value-of select="$type-tc"/> elements</h2>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&#10;        </xsl:text>
                <div class="content-models">
                  <xsl:text>&#10;          </xsl:text>
                  <p>
                    <xsl:choose>
                      <xsl:when test="$type='anything'">
                        <span class="attr-prose-desc"
                          >any element from any namespace</span>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:for-each select="node()">
                          <xsl:call-template name="garnish.as.needed"/>
                        </xsl:for-each>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>&#10;          </xsl:text>
                  </p>
                  <xsl:text>&#10;        </xsl:text>
                </div>
                <xsl:text>&#10;      </xsl:text>
              </section>
            </xsl:for-each>
            <xsl:text>&#10;    </xsl:text>
          </section>
          <xsl:text>&#10;    </xsl:text>
          <section id="global-attributes">
            <xsl:text>&#10;        </xsl:text>
            <h2>Global attributes</h2>
            <xsl:text>&#10;        </xsl:text>
            <p>This section describes attributes that are common to
              all elements in the
              <a href="#html-language">HTML language</a>.</p>
            <xsl:text>&#10;        </xsl:text>
            <div id="common.attrs-mdl">
              <xsl:text>&#10;        </xsl:text>
              <div class="attr-content-models">
                  <xsl:for-each
                    select="$rnc-html//h:*[@id='common.attrs']/node()">
                    <xsl:variable name="ref" select="substring-after(@href,'#')"/>
                    <xsl:variable name="type">
                      <xsl:call-template name="substring-after-last">
                        <xsl:with-param name="input" select="$ref"/>
                        <xsl:with-param name="substr">.</xsl:with-param>
                      </xsl:call-template>
                    </xsl:variable>
              <xsl:choose>
                <xsl:when test="starts-with(.,'common.')">
                  <a href="{@href}">
                  <xsl:value-of select="$type"/>
                  <xsl:text> attributes</xsl:text>
                  </a>
                  <span class="postfix optional">?</span>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="."/>
                </xsl:otherwise>
              </xsl:choose>
                  </xsl:for-each>
                  <xsl:text>&#10;            </xsl:text>
              </div>
              <xsl:text>&#10;        </xsl:text>
            </div>
            <xsl:text>&#10;      </xsl:text>
            <xsl:for-each select="$rnc-html//h:*
              [@id='common.attrs']/h:a[not(.='common.attrs.other')][not(@class='rnc-symbol')]">
              <xsl:variable name="ref" select="substring-after(@href,'#')"/>
              <xsl:variable name="type">
                <xsl:call-template name="substring-after-last">
                  <xsl:with-param name="input" select="$ref"/>
                  <xsl:with-param name="substr">.</xsl:with-param>
                </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="type-tc">
                <xsl:value-of select="translate(
                  substring($type,1,1),
                  'abcdefghijklmnopqrstuvwxyz',
                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                  )"/><xsl:value-of
                  select="substring($type,2)"/>
              </xsl:variable>
              <section id="{$ref}">
                <xsl:text>&#10;        </xsl:text>
                <h2 class="common-subhead">
                  <xsl:choose>
                    <xsl:when test="$type='xml'">
                      <xsl:text>XML</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$type-tc"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:text> attributes</xsl:text>
                </h2>
                <div id="{$ref}-mdl">
                  <xsl:text>&#10;        </xsl:text>
                  <xsl:text>&#10;          </xsl:text>
                  <div class="attr-content-models">
                    <xsl:text>&#10;            </xsl:text>
                    <p>
                      <!-- * <span class="common-pattern-name"><a -->
                          <!-- * href="#{$ref}" -->
                          <!-- * id="{$ref}"> -->
                          <!-- * <xsl:value-of select="."/> -->
                      <!-- * </a></span> -->
                      <!-- * <xsl:text> = </xsl:text> -->
                      <xsl:for-each select="$rnc-html//*[@id=$ref]/node()">
                        <xsl:choose>
                          <xsl:when test="@href='#common.attrs.xmlbase'">
                            <xsl:copy>
                              <xsl:copy-of select="@*"/>
                              <xsl:text>xml:base</xsl:text>
                            </xsl:copy>
                          </xsl:when>
                          <xsl:when test="@href='#common.attrs.xmlspace'">
                            <xsl:copy>
                              <xsl:copy-of select="@*"/>
                              <xsl:text>xml:space</xsl:text>
                            </xsl:copy>
                          </xsl:when>
                          <xsl:when test="@href='#common.attrs.xmllang'">
                            <xsl:copy>
                              <xsl:copy-of select="@*"/>
                              <xsl:text>xml:lang</xsl:text>
                            </xsl:copy>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:copy-of select="."/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </p>
                    <xsl:text>&#10;          </xsl:text>
                  </div>
                  <xsl:text>&#10;        </xsl:text>
                </div>
                <xsl:text>&#10;        </xsl:text>
                <div class="no-number no-toc">
                  <xsl:text>&#10;        </xsl:text>
                  <dl class="attr-defs">
                    <xsl:for-each select="$rnc-html//h:*[@id=$ref]/h:a[not(@class='rnc-symbol')]">
                      <xsl:call-template name="make.attribute.definition"/>
                    </xsl:for-each>
                    <xsl:text>&#10;        </xsl:text>
                  </dl>
                </div>
              </section>
            </xsl:for-each>
            <xsl:for-each select="$rnc-html//h:*
              [@id='common.attrs.other']/h:a">
              <xsl:variable name="ref" select="substring-after(@href,'#')"/>
              <xsl:variable name="type">
                <xsl:call-template name="substring-after-last">
                  <xsl:with-param name="input" select="$ref"/>
                  <xsl:with-param name="substr">.</xsl:with-param>
                </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="type-tc">
                <xsl:value-of select="translate(
                  substring($type,1,1),
                  'abcdefghijklmnopqrstuvwxyz',
                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                  )"/><xsl:value-of
                  select="substring($type,2)"/>
              </xsl:variable>
              <xsl:text>&#10;        </xsl:text>
              <section id="{$ref}-attrs">
                <xsl:text>&#10;        </xsl:text>
                <h2 class="common-subhead">
                  <xsl:choose>
                    <xsl:when test="$ref='common.attrs.interact'">
                      <xsl:text>Interaction</xsl:text>
                    </xsl:when>
                    <xsl:when test="$ref='aria.global'">
                      <xsl:text>Global ARIA</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$type-tc"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:text> attributes</xsl:text>
                </h2>
                <div id="{$ref}-mdl">
                  <xsl:text>&#10;        </xsl:text>
                  <xsl:text>&#10;          </xsl:text>
                  <div class="content-models">
                    <xsl:text>&#10;            </xsl:text>
                    <p><span class="common-pattern-name"><a
                          href="#{$ref}"
                          id="{$ref}">
                          <xsl:value-of select="."/>
                      </a></span>
                      <xsl:text> = </xsl:text>
                      <xsl:for-each select="$rnc-html//*[@id=$ref]/node()">
                        <xsl:copy-of select="."/>
                      </xsl:for-each>
                      <xsl:text>&#10;            </xsl:text>
                    </p>
                    <xsl:text>&#10;          </xsl:text>
                  </div>
                  <xsl:text>&#10;        </xsl:text>
                </div>
                <xsl:text>&#10;        </xsl:text>
                <xsl:if test="not($ref='aria.global')">
                  <div class="no-number no-toc">
                    <xsl:text>&#10;        </xsl:text>
                    <dl class="attr-defs">
                      <xsl:for-each select="$rnc-html//h:*[@id=$ref]/h:a">
                        <xsl:call-template name="make.attribute.definition"/>
                      </xsl:for-each>
                      <xsl:text>&#10;        </xsl:text>
                    </dl>
                    <xsl:text>&#10;      </xsl:text>
                  </div>
                  <xsl:text>&#10;    </xsl:text>
                </xsl:if>
              </section>
            </xsl:for-each>
          </section>
          <xsl:text>&#10;    </xsl:text>
          <section id="datatypes">
            <xsl:text>&#10;        </xsl:text>
            <h2>Data types (common microsyntaxes)</h2>
            <xsl:text>&#10;        </xsl:text>
            <p>This section describes data types (microsyntaxes) that are referenced
              by attribute descriptions in the 
              <a href="#elements">HTML elements</a>,
              and
              <a href="#global-attributes">Global attributes</a>
              sections.</p>
            <xsl:text>&#10;        </xsl:text>
            <xsl:copy-of
              select="document('../src/datatypes.html')//h:section[ancestor::h:section]"/>
            <xsl:for-each
              select="$rnc-html//*[@class='pattern']
              [starts-with(@id,'common.data.')
              or starts-with(@id,'form.data.')]">
              <xsl:variable name="pattern">
                <xsl:value-of select="substring-after(substring-after(@id,'.'),'.')"/>
              </xsl:variable>
              <xsl:variable name="qualified" select="contains($pattern,'.')"/>
              <xsl:variable name="first">
                <xsl:choose>
                  <xsl:when test="not($qualified)">
                    <xsl:value-of select="$pattern"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of
                      select="substring-after($pattern,'.')"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:text>&#10;      </xsl:text>
              <xsl:if test="$pattern='uri'">
                <section id="data-url-no-spaces-def" class="no-toc no-number">
                  <h2 class="common-subhead"><dfn id="data-url-no-spaces">URL</dfn></h2>
                  <xsl:copy-of
                    select="document('../src/datatypes.html')//
                    h:dd[preceding-sibling::h:dt='data-url-no-spaces'][not(position()=1)]/node()"/>
                </section>
              </xsl:if>
              <section id="{@id}-def" class="no-toc no-number">
              <xsl:text>&#10;        </xsl:text>
                <xsl:choose>
                  <xsl:when test="$pattern='tokens'">
                    <h2 class="common-subhead"><dfn id="{@id}">set of space-separated tokens</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='browsing-context-name'">
                    <h2 class="common-subhead"><dfn id="{@id}">browsing-context name</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='browsing-context-name-or-keyword'">
                    <h2 class="common-subhead"><dfn id="{@id}">browsing-context name or keyword</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='hash-name'">
                    <h2 class="common-subhead"><dfn id="{@id}">hash-name reference</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='mediaquery'">
                    <h2 class="common-subhead"><dfn id="{@id}">media-query list</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='langcode'">
                    <h2 class="common-subhead"><dfn id="{@id}">language tag</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='datetime'">
                    <h2 class="common-subhead"><dfn id="{@id}">date and time</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='datetime-local'">
                    <h2 class="common-subhead"><dfn id="{@id}">local date and time</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='date-or-time'">
                    <h2 class="common-subhead"><dfn id="{@id}">date or time</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='sandbox-allow-list'">
                    <h2 class="common-subhead"><dfn id="{@id}">sandbox “allow” keywords list</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='audio-states-list'">
                    <h2 class="common-subhead"><dfn id="{@id}">list of audio states</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='charset'">
                    <h2 class="common-subhead"><dfn id="{@id}">character encoding name</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='charsetlist'">
                    <h2 class="common-subhead"><dfn id="{@id}">list of character-encoding names</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='keylabellist'">
                    <h2 class="common-subhead"><dfn id="{@id}">list of key labels</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='dropzonevalue'">
                    <h2 class="common-subhead"><dfn id="{@id}">dropzone value</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='default-style'">
                    <h2 class="common-subhead"><dfn id="{@id}">default-style name</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='meta-charset'">
                    <h2 class="common-subhead"><dfn id="{@id}">meta-charset string</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='refresh'">
                    <h2 class="common-subhead"><dfn id="{@id}">refresh value</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='mimetype'">
                    <h2 class="common-subhead"><dfn id="{@id}">MIME type</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='mimetypelist'">
                    <h2 class="common-subhead"><dfn id="{@id}">list of MIME types</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='emailaddresslist'">
                    <h2 class="common-subhead"><dfn id="{@id}">list of e-mail addresses</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='emailaddress'">
                    <h2 class="common-subhead"><dfn id="{@id}">e-mail address</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='float'">
                    <h2 class="common-subhead"><dfn id="{@id}">floating-point number</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='float.non-negative'">
                    <h2 class="common-subhead"><dfn id="{@id}">non-negative floating-point number</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='integer.non-negative'">
                    <h2 class="common-subhead"><dfn id="{@id}">non-negative integer</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='integer.positive'">
                    <h2 class="common-subhead"><dfn id="{@id}">positive integer</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='float.positive'">
                    <h2 class="common-subhead"><dfn id="{@id}">positive floating-point number</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='uri.absolute'">
                    <h2 class="common-subhead"><dfn id="{@id}">absolute URL potentially surrounded by spaces</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='uri'">
                    <h2 class="common-subhead"><dfn id="{@id}">URL potentially surrounded by spaces</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='uri.non-empty'">
                    <h2 class="common-subhead"><dfn id="{@id}">non-empty URL potentially surrounded by spaces</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='uris'">
                    <h2 class="common-subhead"><dfn id="{@id}">list of URIs</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='id'">
                    <h2 class="common-subhead"><dfn id="{@id}">ID</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='idref'">
                    <h2 class="common-subhead"><dfn id="{@id}">ID reference</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='idrefs'">
                    <h2 class="common-subhead"><dfn id="{@id}">list of ID references</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='color'">
                    <h2 class="common-subhead"><dfn id="{@id}">simple color</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='nonemptystring'">
                    <h2 class="common-subhead"><dfn id="{@id}">non-empty string</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='stringwithoutlinebreaks'">
                    <h2 class="common-subhead"><dfn id="{@id}">string without line breaks</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='rectangle'">
                    <h2 class="common-subhead"><dfn id="{@id}">rectangle coordinates</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='circle'">
                    <h2 class="common-subhead"><dfn id="{@id}">circle coordinates</dfn></h2>
                  </xsl:when>
                  <xsl:when test="$pattern='polygon'">
                    <h2 class="common-subhead"><dfn id="{@id}">polygon coordinates</dfn></h2>
                  </xsl:when>
                  <xsl:otherwise>
                    <h2 class="common-subhead">
                      <dfn id="{@id}">
                        <xsl:value-of select="$first"/>
                        <xsl:if test="$qualified">
                          <xsl:text> </xsl:text>
                          <xsl:value-of
                            select="substring-before($pattern,'.')"/>
                        </xsl:if>
                      </dfn>
                    </h2>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&#10;        </xsl:text>
                  <!-- * <div> -->
                    <!-- * <span -->
                      <!-- * class="common-pattern-name"> -->
                      <!-- * <dfn id="{@id}" -->
                        <!-- * > -->
                        <!-- * <xsl:value-of select="$pattern"/> -->
                      <!-- * </dfn> -->
                    <!-- * </span> -->
                    <!-- * <code class="punc"><xsl:text> = </xsl:text></code> -->
                    <!-- * <xsl:copy-of -->
                      <!-- * select="document('../src/datatypes.html')// -->
                      <!-- * h:dd[preceding-sibling::h:dt=substring-after(current()/@id,'.data.')][position()=1]/node()"/> -->
                    <!-- * <xsl:text> </xsl:text> -->
                    <!-- * <a href="#{@id}" class="hash">#</a> -->
                  <!-- * </div> -->
                  <xsl:copy-of
                    select="document('../src/datatypes.html')//
                    h:dd[preceding-sibling::h:dt=substring-after(current()/@id,'.data.')][not(position()=1)]/node()"/>
                <xsl:text>&#10;      </xsl:text>
              </section>
              <xsl:text>&#10;        </xsl:text>
              <xsl:if test="$pattern='tokens'">
                <section id="data-unordered-tokens-def" class="no-toc no-number">
                  <h2 class="common-subhead"><dfn id="data-unordered-tokens">unordered set of unique space-separated tokens</dfn></h2>
                  <xsl:copy-of
                    select="document('../src/datatypes.html')//
                    h:dd[preceding-sibling::h:dt='unordered-tokens'][not(position()=1)]/node()"/>
                </section>
                <section id="data-ordered-tokens-def" class="no-toc no-number">
                  <h2 class="common-subhead"><dfn id="data-ordered-tokens">ordered set of unique space-separated tokens</dfn></h2>
                  <xsl:copy-of
                    select="document('../src/datatypes.html')//
                    h:dd[preceding-sibling::h:dt='ordered-tokens'][not(position()=1)]/node()"/>
                </section>
              </xsl:if>
            </xsl:for-each>
            <xsl:text>&#10;    </xsl:text>
            </section>
          <xsl:text>&#10;    </xsl:text>
          <xsl:if test="not($aria=0)">
            <section id="aria">
              <xsl:text>&#10;        </xsl:text>
              <h2>ARIA</h2>
              <xsl:text>&#10;        </xsl:text>
              <p>This section provides information about 
                <a href="http://www.w3.org/WAI/PF/aria/">ARIA</a>
                attributes.</p>
              <xsl:text>&#10;        </xsl:text>
              <section id="common-aria">
                <xsl:text>&#10;        </xsl:text>
                <h2>Common ARIA attribute sets</h2>
                <xsl:text>&#10;        </xsl:text>
                <div id="common.attrs.aria-mdl">
                  <xsl:text>&#10;        </xsl:text>
                  <dl class="content-models">
                    <xsl:text>&#10;            </xsl:text>
                    <dt class="content-model">
                      <span class="common-pattern-name">
                        <dfn
                          id="common.attrs.aria">common.attrs.aria</dfn>
                      </span>
                      <xsl:text> = </xsl:text>
                      <a class="hash" href="#common.attrs.aria">#</a>
                    </dt>
                    <dd>
                      <xsl:for-each
                        select="$rnc-html//h:*[@id='common.attrs.aria']/node()">
                        <xsl:copy-of select="."/>
                      </xsl:for-each>
                      <xsl:text>&#10;            </xsl:text>
                    </dd>
                    <xsl:text>&#10;          </xsl:text>
                  </dl>
                  <xsl:text>&#10;        </xsl:text>
                </div>
                <xsl:for-each select="$rnc-html//h:*
                  [@id='common.attrs.aria']/h:a[not(@class='rnc-symbol')]">
                  <xsl:variable name="ref" select="substring-after(@href,'#')"/>
                  <xsl:variable name="type">
                    <xsl:call-template name="substring-after-last">
                      <xsl:with-param name="input" select="$ref"/>
                      <xsl:with-param name="substr">.</xsl:with-param>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:variable name="type-tc">
                    <xsl:value-of select="translate(
                      substring($type,1,1),
                      'abcdefghijklmnopqrstuvwxyz',
                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                      )"/><xsl:value-of
                      select="substring($type,2)"/>
                  </xsl:variable>
                  <section id="{$type}-attrs" class="no-toc">
                    <xsl:text>&#10;        </xsl:text>
                    <h2 class="common-subhead">
                      <xsl:value-of select="$type-tc"/>
                    </h2>
                    <xsl:text>&#10;        </xsl:text>
                    <div id="{$ref}-mdl">
                      <xsl:text>&#10;          </xsl:text>
                      <dl class="content-models">
                        <xsl:text>&#10;            </xsl:text>
                        <dt class="content-model">
                          <span class="common-pattern-name"><a
                              href="#{$ref}"
                              id="{$ref}">
                              <xsl:value-of select="."/>
                          </a></span>
                          <xsl:text> = </xsl:text>
                        </dt>
                        <dd>
                          <xsl:for-each select="$rnc-html//*[@id=$ref]/node()">
                            <xsl:copy-of select="."/>
                          </xsl:for-each>
                          <xsl:text>&#10;            </xsl:text>
                        </dd>
                        <xsl:text>&#10;          </xsl:text>
                      </dl>
                      <xsl:text>&#10;        </xsl:text>
                    </div>
                    <xsl:text>&#10;        </xsl:text>
                  </section>
                </xsl:for-each>
                <xsl:text>&#10;      </xsl:text>
              </section>
              <xsl:text>&#10;    </xsl:text>
              <section id="implicit-aria">
                <xsl:text>&#10;        </xsl:text>
                <h2>ARIA attribute sets for implicit semantics</h2>
                <xsl:text>&#10;        </xsl:text>
                <div id="common.attrs.aria.implicit-mdl">
                  <xsl:text>&#10;        </xsl:text>
                  <xsl:for-each
                    select="$rnc-html//h:*[@class='pattern'][starts-with(@id,'common.attrs.aria.implicit')]">
                    <dl class="content-models">
                      <xsl:text>&#10;            </xsl:text>
                      <dt class="content-model">
                        <span class="common-pattern-name">
                          <dfn
                            id="{@id}">
                            <xsl:value-of select="@id"/>
                          </dfn>
                        </span>
                        <xsl:text> = </xsl:text>
                        <a class="hash" href="#{@id}">#</a>
                      </dt>
                      <dd>
                        <xsl:for-each
                          select="node()">
                          <xsl:copy-of select="."/>
                        </xsl:for-each>
                        <xsl:text>&#10;            </xsl:text>
                      </dd>
                      <xsl:text>&#10;          </xsl:text>
                    </dl>
                    <xsl:text>&#10;        </xsl:text>
                  </xsl:for-each>
                </div>
                <xsl:text>&#10;      </xsl:text>
              </section>
              <section id="landmark-aria">
                <xsl:text>&#10;        </xsl:text>
                <h2>ARIA attribute sets for landmark roles</h2>
                <xsl:text>&#10;        </xsl:text>
                <div id="common.attrs.aria.landmark-mdl">
                  <xsl:text>&#10;        </xsl:text>
                  <xsl:for-each
                    select="$rnc-html//h:*[@class='pattern'][starts-with(@id,'common.attrs.aria.landmark')]">
                    <dl class="content-models">
                      <xsl:text>&#10;            </xsl:text>
                      <dt class="content-model">
                        <span class="common-pattern-name">
                          <dfn
                            id="{@id}">
                            <xsl:value-of select="@id"/>
                          </dfn>
                        </span>
                        <xsl:text> = </xsl:text>
                        <a class="hash" href="#{@id}">#</a>
                      </dt>
                      <dd>
                        <xsl:for-each
                          select="node()">
                          <xsl:copy-of select="."/>
                        </xsl:for-each>
                        <xsl:text>&#10;            </xsl:text>
                      </dd>
                      <xsl:text>&#10;          </xsl:text>
                    </dl>
                    <xsl:text>&#10;        </xsl:text>
                  </xsl:for-each>
                </div>
                <xsl:text>&#10;      </xsl:text>
              </section>
              <section id="aria-attrs-all">
                <xsl:text>&#10;        </xsl:text>
                <h2>ARIA attribute models</h2>
                <p>The semantics of the following attributes are
                  normatively defined in the
                  <a href="http://www.w3.org/WAI/PF/aria/">ARIA specification</a>.</p>
                <xsl:text>&#10;        </xsl:text>
                <div class="no-number no-toc">
                  <xsl:text>&#10;        </xsl:text>
                  <div class="attr-defs">
                    <xsl:for-each select="$rnc-html//h:*[@class='define']
                      [starts-with(@id,'aria-')]/*[@class='patternname']/h:a
                      ">
                      <xsl:sort select="@href"/>
                      <xsl:call-template name="make.attribute.definition">
                        <xsl:with-param name="href">
                          <xsl:value-of
                            select="concat('#',substring-after(@href,'#the-'))"/>
                        </xsl:with-param>
                        <xsl:with-param name="wrapper">p</xsl:with-param>
                      </xsl:call-template>
                    </xsl:for-each>
                    <xsl:text>&#10;        </xsl:text>
                  </div>
                  <xsl:text>&#10;      </xsl:text>
                </div>
                <xsl:text>&#10;    </xsl:text>
              </section>
            </section>
          <xsl:text>&#10;    </xsl:text>
          </xsl:if>
        </div>
        <!-- * <xsl:text>&#10;      </xsl:text> -->
        <div id="appendices">
          <xsl:text>&#10;     </xsl:text>
          <section id="references">
            <xsl:text>&#10;      </xsl:text>
            <xsl:copy-of
              select="document('../src/references.html')/*/node()"/>
          </section>
          <xsl:text>&#10;     </xsl:text>
          <section id="acknowledgments">
            <xsl:text>&#10;      </xsl:text>
            <h2>Acknowledgments</h2>
            <xsl:text>&#10;      </xsl:text>
            <!-- * <p>Parts of this document were programatically -->
              <!-- * generated from a modified version of a -->
              <!-- * RELAX NG schema for HTML5 from the <a -->
                <!-- * href="http://syntax.whattf.org/relaxng/" -->
                <!-- * >syntax.whattf.org source repository</a>, -->
              <!-- * distributed with the following copyright notice and -->
              <!-- * license statement:</p> -->
            <!-- * <xsl:text>&#10;      </xsl:text> -->
            <!-- * <pre class="license"><xsl:copy-of -->
                <!-- * select="document('../LICENSE.xml')/license/node()"/></pre> -->
            <!-- * <xsl:text>&#10;      </xsl:text> -->
            <p>This document incorporates a modified version of a 
              <a
                href="http://svn.webkit.org/repository/webkit/trunk/Source/WebCore/css/html.css"
                >CSS stylesheet from the WebKit source repository</a>,
              distributed with the following copyright notice and
              license statement:</p>
            <xsl:text>&#10;      </xsl:text>
            <pre class="license"><xsl:copy-of
                select="document('../html.css.LICENSE.xml')/license/node()"/></pre>
            <xsl:text>&#10;      </xsl:text>
            <p>This document incorporates modified and verbatim
              content from the document
              <a href="http://dev.w3.org/html5/spec/">HTML5</a>,
              distributed with the following copyright notice and
              license statement:</p>
            <xsl:text>&#10;      </xsl:text>
            <p class="license"><a href="http://www.w3.org/Consortium/Legal/ipr-notice#Copyright">Copyright</a> © 2010 <a href="http://www.w3.org/"><abbr title="World Wide Web Consortium">W3C</abbr></a><sup>®</sup> (<a href="http://www.csail.mit.edu/"><abbr title="Massachusetts Institute of Technology">MIT</abbr></a>, <a href="http://www.ercim.eu/"><abbr title="European Research Consortium for Informatics and Mathematics">ERCIM</abbr></a>, <a href="http://www.keio.ac.jp/">Keio</a>), All Rights Reserved. W3C <a href="http://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer">liability</a>, <a href="http://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks">trademark</a> and <a href="http://www.w3.org/Consortium/Legal/copyright-documents">document use</a> rules apply.</p>
            <xsl:text>&#10;      </xsl:text>
          </section>
          <!-- * <section id="schema-appendix"> -->
            <!-- * <xsl:text>&#10;      </xsl:text> -->
            <!-- * <h2>RELAX NG schema for HTML 5</h2> -->
            <!-- * <xsl:text>&#10;      </xsl:text> -->
            <!-- * <div class="note"> -->
              <!-- * <p>This section is non-normative. The schema -->
                <!-- * provided in this section is not a complete -->
                <!-- * expression of all constraints of the HTML language -->
                <!-- * and should never be used as such.</p> -->
            <!-- * </div> -->
            <!-- * <p>The following is a “flattened” schema for HTML 5, -->
              <!-- * in RELAX NG compact syntax. It’s also available as a -->
              <!-- * standalone file (<a href="schema.rnc" -->
                <!-- * >html.rnc</a>). It was generated (using the -->
              <!-- * <code>incelim</code> and <code>trang</code> -->
              <!-- * programs) from the source form of the schema: -->
              <!-- * A modular set of files available as a zip archive -->
              <!-- * (<a href="schema.zip" -->
                <!-- * >schema.zip</a>).</p> -->
            <!-- * <xsl:text>&#10;      </xsl:text> -->
            <!-- * <p>Also available is an <a href="schema.html" >HTML -->
                <!-- * interpretation of the schema</a>. It modifies the -->
              <!-- * schema for ease of readability and browsing, and its -->
              <!-- * content is not necessarily functionally equivalent -->
              <!-- * to the source form of the schema.</p> -->
            <!-- * <xsl:text>&#10;      </xsl:text> -->
            <!-- * <pre id="schema"><xsl:copy-of select="document('../html.rnc.xml')/*/node()"/></pre> -->
            <!-- * <xsl:text>&#10;     </xsl:text> -->
          <!-- * </section> -->
          <!-- * <xsl:text>&#10;     </xsl:text> -->
          <!-- * <section id="assertions-appendix"> -->
            <!-- * <xsl:text>&#10;      </xsl:text> -->
            <!-- * <h2>Schematron Assertions</h2> -->
            <!-- * <xsl:text>&#10;      </xsl:text> -->
            <!-- * <p>This section is non-normative.</p> -->
            <!-- * <xsl:text>&#10;      </xsl:text> -->
            <!-- * <pre id="assertions"><xsl:copy-of select="document('../assertions.sch.xml')/*/node()"/></pre> -->
            <!-- * <xsl:text>&#10;     </xsl:text> -->
          <!-- * </section> -->
          <!-- * <xsl:text>&#10;     </xsl:text> -->
        <xsl:text>&#10;  </xsl:text>
        </div>
        <xsl:text>&#10;  </xsl:text>
        <script src="js/jump-indexes.js" type="text/javascript"></script>
        <xsl:text>&#10;</xsl:text>
        <script src="js/dfn.js" type="text/javascript"></script>
      </body>
      <xsl:text>&#10;</xsl:text>
    </html>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE ELEMENTS-BY-FUNCTION SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make.elements.by.function">
    <xsl:apply-templates select="document('../src/elements-by-function.html')/node()"/>
  </xsl:template>
  <xsl:template match="h:section[@id='elements-by-function']/*[not(h:section)]">
    <xsl:copy-of select="."/>
  </xsl:template>
  <xsl:template match="h:section[@id='elements-by-function']/h:section">
    <section class="no-toc" id="{@id}">
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  <xsl:template match="h:section[@id='elements-by-function']/h:section/*[not(h:ul)]">
    <xsl:copy-of select="."/>
  </xsl:template>
  <xsl:template match="h:section[@id='elements-by-function']/h:section/h:ul">
    <ul>
      <xsl:text>&#10;</xsl:text>
      <xsl:for-each select="h:li">
        <xsl:variable name="element-name" select="normalize-space(.)"/>
        <xsl:variable name="target">
          <xsl:call-template name="get-spec-target">
            <xsl:with-param name="name" select="$element-name"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="filename">
          <xsl:call-template name="get-spec-filename">
            <xsl:with-param name="ref" select="$target"/>
          </xsl:call-template>
        </xsl:variable>
        <li>
          <xsl:call-template name="make-element-spec-link">
            <xsl:with-param name="element-name" select="$element-name"/>
            <xsl:with-param name="filename" select="$filename"/>
            <xsl:with-param name="target" select="$target"/>
          </xsl:call-template>
          <xsl:text> </xsl:text>
          <a href="#{$element-name}">
            <span class="element">
              <xsl:value-of select="$element-name"/>
            </span>
            <xsl:text> – </xsl:text>
            <xsl:call-template name="get-shortdesc">
              <xsl:with-param name="element-name" select="$element-name"/>
            </xsl:call-template>
          </a>
          <xsl:call-template name="make-markup-feature-flags">
            <xsl:with-param name="element-name" select="$element-name"/>
          </xsl:call-template>
        </li>
      </xsl:for-each>
      <xsl:text>&#10;</xsl:text>
    </ul>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE ELEMENT SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template match="*[local-name() = 'element'][@name]">
    <xsl:variable name="name" select="substring-before(ancestor::*[local-name()='define']/@name,'.elem')"/>
    <xsl:variable name="short-name">
      <xsl:choose>
        <xsl:when test="contains(ancestor::*[local-name()='define']/@name,'.')">
          <xsl:value-of select="substring-before(ancestor::*[local-name()='define']/@name,'.')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$name"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="the-name" select="concat('the-',$name)"/>
    <xsl:variable name="inner-id" select="concat($name, '.inner')"/>
    <xsl:variable name="attrs-id" select="concat($name, '.attrs')"/>
    <xsl:variable name="name-dot" select="concat($name, '.')"/>
    <xsl:if test="not(preceding::*[local-name() = 'element']
      [@name = current()/@name]
      [not(@name='input')]
      [not(@name='button')]
      [not(@name='command')]
      [not(@name='meta')]
      )"
      >
      <xsl:variable name="target">
        <xsl:call-template name="get-spec-target">
          <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="filename">
        <xsl:call-template name="get-spec-filename">
          <xsl:with-param name="ref" select="$target"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$name='button.submit'">
          <xsl:text>&#10;    </xsl:text>
          <section id="button" class="no-number elementpage">
            <xsl:text>&#10;      </xsl:text>
            <h2 class="element-head">
              <xsl:call-template name="make-element-spec-link">
                <xsl:with-param name="element-name">button</xsl:with-param>
                <xsl:with-param name="filename">
                  <xsl:call-template name="get-spec-filename">
                    <xsl:with-param name="ref">#the-button-element</xsl:with-param>
                  </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="target">#the-button-element</xsl:with-param>
              </xsl:call-template>
              <xsl:text> </xsl:text>
              <span class="element">button</span>
              <xsl:text> – </xsl:text>
              <xsl:call-template name="get-shortdesc">
                <xsl:with-param name="element-name">button</xsl:with-param>
              </xsl:call-template>
            </h2>
            <xsl:text>&#10;      </xsl:text>
            <div id="button-longdesc" class="longdesc">
              <xsl:text>&#10;      </xsl:text>
              <p>The
                <span class="element">button</span>
                element is a multipurpose element for representing buttons.</p>
            </div>
            <xsl:text>&#10;      </xsl:text>
            <div class="toc">
              <xsl:text>&#10;      </xsl:text>
              <xsl:for-each
                select="$rnc-html
                //h:span[@id='button']
                ">
                <xsl:call-template name="make.special.context">
                  <xsl:with-param name="element-name">button</xsl:with-param>
                </xsl:call-template>
              </xsl:for-each>
              <xsl:text>&#10;      </xsl:text>
            </div>
            <p>A
              <span class="element">button</span>
              element with no
              <span class="attribute">type</span>
              attribute specified represents the same thing as a
              <a href="#button.submit">button element with its type
                attribute set to "submit"</a>.</p>
            <xsl:text>&#10;      </xsl:text>
          </section>
        </xsl:when>
        <xsl:when test="$name='command.command'">
          <xsl:text>&#10;    </xsl:text>
          <section id="command" class="no-number elementpage">
            <xsl:text>&#10;      </xsl:text>
            <h2 class="element-head">
              <xsl:call-template name="make-element-spec-link">
                <xsl:with-param name="element-name">command</xsl:with-param>
                <xsl:with-param name="filename">
                  <xsl:call-template name="get-spec-filename">
                    <xsl:with-param name="ref">#the-command</xsl:with-param>
                  </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="target">#the-command</xsl:with-param>
              </xsl:call-template>
              <xsl:text> </xsl:text>
              <span class="element">command</span>
              <xsl:text> – </xsl:text>
              <xsl:call-template name="get-shortdesc">
                <xsl:with-param name="element-name">command</xsl:with-param>
              </xsl:call-template>
              <xsl:text> </xsl:text>
              <xsl:call-template name="make-markup-feature-flags">
                <xsl:with-param name="element-name">command</xsl:with-param>
              </xsl:call-template>
            </h2>
            <xsl:text>&#10;      </xsl:text>
            <div id="command-longdesc" class="longdesc">
              <xsl:text>&#10;      </xsl:text>
              <p>The
                <span class="element">command</span>
                element is a multipurpose element for representing commands.</p>
            </div>
            <xsl:text>&#10;      </xsl:text>
            <div class="toc">
              <xsl:text>&#10;      </xsl:text>
              <xsl:for-each
                select="$rnc-html
                //h:span[@id='command']
                ">
                <xsl:call-template name="make.special.context">
                  <xsl:with-param name="element-name">command</xsl:with-param>
                </xsl:call-template>
              </xsl:for-each>
            </div>
            <xsl:text>&#10;      </xsl:text>
            <p>A
              <span class="element">command</span>
              element with no
              <span class="attribute">type</span>
              attribute specified represents the same thing as a
              <a href="#command.command">command element with its type
                attribute set to "command"</a>.</p>
          </section>
        </xsl:when>
        <xsl:when test="$name='input.text'">
          <xsl:text>&#10;    </xsl:text>
          <section id="input" class="no-number elementpage">
            <xsl:text>&#10;      </xsl:text>
            <h2 class="element-head">
              <xsl:call-template name="make-element-spec-link">
                <xsl:with-param name="element-name">input</xsl:with-param>
                <xsl:with-param name="filename">
                  <xsl:call-template name="get-spec-filename">
                    <xsl:with-param name="ref">#the-input-element</xsl:with-param>
                  </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="target">#the-input-element</xsl:with-param>
              </xsl:call-template>
              <xsl:text> </xsl:text>
              <span class="element">input</span>
              <xsl:text> – </xsl:text>
              <xsl:call-template name="get-shortdesc">
                <xsl:with-param name="element-name">input</xsl:with-param>
              </xsl:call-template>
              <xsl:text> </xsl:text>
              <xsl:call-template name="make-markup-feature-flags">
                <xsl:with-param name="element-name">input</xsl:with-param>
              </xsl:call-template>
            </h2>
            <xsl:text>&#10;      </xsl:text>
            <div id="input-longdesc" class="longdesc">
              <xsl:text>&#10;      </xsl:text>
              <p>The
                <span class="element">input</span>
                element is a multipurpose element for representing input controls.</p>
            </div>
            <xsl:text>&#10;      </xsl:text>
            <div class="toc">
              <xsl:text>&#10;      </xsl:text>
              <xsl:for-each
                select="$rnc-html
                //h:span[@id='input']
                ">
                <xsl:call-template name="make.special.context">
                  <xsl:with-param name="element-name">input</xsl:with-param>
                </xsl:call-template>
              </xsl:for-each>
              <xsl:text>&#10;      </xsl:text>
            </div>
            <p>An
              <span class="element">input</span>
              element with no
              <span class="attribute">type</span>
              attribute specified represents the same thing as an
              <a href="#input.text">input element with its type
                attribute set to "text"</a>.</p>
            <xsl:text>&#10;      </xsl:text>
            <div class="no-number no-toc" id="input-changes">
              <xsl:text>&#10;</xsl:text>
              <h2 class="element-subhead">Changes in HTML5</h2>
              <div class="changes">
                <p>Several new 
                  <span class="element">input</span>
                  element types have been added, and several new
                  attributes are now allowed on the element.</p>
              </div>
            </div>
          </section>
        </xsl:when>
        <xsl:when test="$name='meta.name'">
          <xsl:text>&#10;    </xsl:text>
          <section id="meta" class="no-number elementpage">
            <xsl:text>&#10;      </xsl:text>
            <h2 class="element-head">
              <xsl:call-template name="make-element-spec-link">
                <xsl:with-param name="element-name">meta</xsl:with-param>
                <xsl:with-param name="filename">
                  <xsl:call-template name="get-spec-filename">
                    <xsl:with-param name="ref">#meta</xsl:with-param>
                  </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="target">#meta</xsl:with-param>
              </xsl:call-template>
              <xsl:text> </xsl:text>
              <span class="element">meta</span>
              <xsl:text> – </xsl:text>
              <xsl:call-template name="get-shortdesc">
                <xsl:with-param name="element-name">meta</xsl:with-param>
              </xsl:call-template>
              <xsl:text> </xsl:text>
              <xsl:call-template name="make-markup-feature-flags">
                <xsl:with-param name="element-name">meta</xsl:with-param>
              </xsl:call-template>
            </h2>
            <xsl:text>&#10;      </xsl:text>
            <div id="meta-longdesc" class="longdesc">
              <xsl:text>&#10;      </xsl:text>
              <p>The
                <span class="element">meta</span>
                element is a multipurpose element for representing
                metadata.</p>
            <xsl:text>&#10;      </xsl:text>
            </div>
            <xsl:text>&#10;      </xsl:text>
            <p>The details of the
              <span class="element">meta</span>
              element are described in the following sections:</p>
            <xsl:text>&#10;      </xsl:text>
            <div class="toc">
            <ul>
              <xsl:text>&#10;      </xsl:text>
              <li>
                <xsl:call-template name="make-element-spec-link">
                  <xsl:with-param name="element-name">meta</xsl:with-param>
                  <xsl:with-param name="filename">
                    <xsl:call-template name="get-spec-filename">
                      <xsl:with-param name="ref">#attr-meta-name</xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                  <xsl:with-param name="target">#attr-meta-name</xsl:with-param>
                </xsl:call-template>
                <span><xsl:text> </xsl:text></span>
                <a href="#meta.name">meta name</a>
              </li>
              <xsl:text>&#10;      </xsl:text>
              <li>
                <xsl:call-template name="make-element-spec-link">
                  <xsl:with-param name="element-name">meta</xsl:with-param>
                  <xsl:with-param name="filename">
                    <xsl:call-template name="get-spec-filename">
                      <xsl:with-param name="ref">#attr-meta-http-equiv-refresh</xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                  <xsl:with-param name="target">#attr-meta-http-equiv-refresh</xsl:with-param>
                </xsl:call-template>
                <span><xsl:text> </xsl:text></span>
                <a href="#meta.http-equiv.refresh">meta http-equiv=refresh</a>
              </li>
              <xsl:text>&#10;      </xsl:text>
              <li>
                <xsl:call-template name="make-element-spec-link">
                  <xsl:with-param name="element-name">meta</xsl:with-param>
                  <xsl:with-param name="filename">
                    <xsl:call-template name="get-spec-filename">
                      <xsl:with-param name="ref">#attr-meta-http-equiv-default-style</xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                  <xsl:with-param name="target">#attr-meta-http-equiv-default-style</xsl:with-param>
                </xsl:call-template>
                <span><xsl:text> </xsl:text></span>
                <a href="#meta.http-equiv.default-style">meta http-equiv=default-style</a>
              </li>
              <xsl:text>&#10;      </xsl:text>
              <li>
                <xsl:call-template name="make-element-spec-link">
                  <xsl:with-param name="element-name">meta</xsl:with-param>
                  <xsl:with-param name="filename">
                    <xsl:call-template name="get-spec-filename">
                      <xsl:with-param name="ref">#attr-meta-charset</xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                  <xsl:with-param name="target">#attr-meta-charset</xsl:with-param>
                </xsl:call-template>
                <span><xsl:text> </xsl:text></span>
                <a href="#meta.charset">meta charset</a>
                <span><xsl:text> </xsl:text></span>
                <span class="new-feature"
                  title="This markup feature is newly added in HTML5."
                  >NEW</span>
              </li>
              <xsl:text>&#10;      </xsl:text>
              <li>
                <xsl:call-template name="make-element-spec-link">
                  <xsl:with-param name="element-name">meta</xsl:with-param>
                  <xsl:with-param name="filename">
                    <xsl:call-template name="get-spec-filename">
                      <xsl:with-param name="ref">#attr-meta-http-equiv-content-type</xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                  <xsl:with-param name="target">#attr-meta-http-equiv-content-type</xsl:with-param>
                </xsl:call-template>
                <span><xsl:text> </xsl:text></span>
                <a href="#meta.http-equiv.content-type">meta http-equiv=content-type</a>
              </li>
              <xsl:text>&#10;      </xsl:text>
            </ul>
          </div>
          <xsl:if test="exsl:node-set($assertions)/s:rule[child::s:context = 'meta']">
          <xsl:text>&#10;      </xsl:text>
          <div class="no-number no-toc" id="meta-constraints">
            <xsl:text>&#10;        </xsl:text>
            <h2 class="element-subhead">Additional constraints and admonitions</h2>
            <xsl:text>&#10;        </xsl:text>
            <ul class="assertions">
              <xsl:for-each
                select="exsl:node-set($assertions)/s:rule[child::s:context = 'meta']">
                <xsl:text>&#10;          </xsl:text>
                <xsl:for-each select="s:report|s:assert">
                  <li>
                    <span>
                      <!-- * <xsl:if test="contains(.,'obsolete')"> -->
                        <!-- * <xsl:attribute -->
                          <!-- * name="class">obsolete</xsl:attribute> -->
                      <!-- * </xsl:if> -->
                      <xsl:for-each select="node()">
                        <xsl:choose>
                          <xsl:when test="local-name() = 'name'">meta</xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="."/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </span>
                  </li>
                </xsl:for-each>
              </xsl:for-each>
              <xsl:text>&#10;        </xsl:text>
            </ul>
            <xsl:text>&#10;      </xsl:text>
          </div>
          </xsl:if>
            <xsl:text>&#10;      </xsl:text>
            <div class="no-number no-toc" id="meta-changes">
              <xsl:text>&#10;</xsl:text>
              <h2 class="element-subhead">Changes in HTML5</h2>
              <div class="changes">
                <p>Although previous versions of HTML allowed the
                  <span class="attribute">http-equiv</span>
                  attribute on the
                  <span class="element">meta</span>
                  element to have any number of possible values, the
                  <span class="attribute">http-equiv</span>
                  attribute is now restricted to only the specific
                  values described in this reference. Also, the new
                  <span class="attribute">charset</span>
                  attribute is now allowed.</p>
              </div>
            </div>
          </section>
        </xsl:when>
      </xsl:choose>
      <xsl:message>
        <xsl:value-of select="$short-name"/>
      </xsl:message>
      <section>
        <xsl:attribute name="id">
          <xsl:value-of select="$name"/>
        </xsl:attribute>
        <xsl:attribute name="class">no-number elementpage</xsl:attribute>
        <xsl:text>&#10;      </xsl:text>
        <h2 class="element-head">
          <xsl:call-template name="make-element-spec-link">
            <xsl:with-param name="element-name" select="$short-name"/>
            <xsl:with-param name="filename" select="$filename"/>
            <xsl:with-param name="target" select="$target"/>
          </xsl:call-template>
          <xsl:choose>
            <xsl:when test="contains($name,'.notype')">
              <span class="element"><xsl:value-of select="substring-before($name,'.')"/></span>
              <xsl:text> </xsl:text>
              <span class="elem-qualifier">
                <xsl:text> </xsl:text>
                <span class="attribute-name">type</span> unspecified</span>
            </xsl:when>
            <xsl:when test="contains($name,'.noshape')">
              <span class="element"><xsl:value-of select="substring-before($name,'.')"/></span>
              <xsl:text> </xsl:text>
              <span class="elem-qualifier">
                <xsl:text> </xsl:text>
                <span class="attribute-name">shape</span> unspecified</span>
            </xsl:when>
            <xsl:when test="contains($name,'.')">
              <span class="element"><xsl:value-of select="substring-before($name,'.')"/></span>
              <xsl:text> </xsl:text>
              <xsl:variable name="qualifier">
                <xsl:choose>
                  <xsl:when test="$short-name='input'
                    or $short-name='input'
                    or $short-name='button'
                    or $short-name='command'
                    ">
                    <xsl:text>type</xsl:text>
                  </xsl:when>
                  <xsl:when test="$name='meta.name'">
                    <xsl:text>name</xsl:text>
                  </xsl:when>
                  <xsl:when test="$name='meta.charset'">
                    <xsl:text>charset</xsl:text>
                  </xsl:when>
                  <xsl:when test="contains($name,'http-equiv')">
                    <xsl:text>http-equiv</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:variable>
              <span class="elem-qualifier">
                <xsl:text> </xsl:text>
                <span class="attribute-name">
                  <xsl:value-of select="$qualifier"/>
                  </span><xsl:if
                  test="not($name='meta.name')
                  and not($name='meta.charset')
                  ">=<span class="equals-value" >
                    <xsl:call-template name="substring-after-last">
                      <xsl:with-param name="input" select="$name"/>
                      <xsl:with-param name="substr">.</xsl:with-param>
                    </xsl:call-template>
                  </span>
                </xsl:if>
              </span>
            </xsl:when>
            <xsl:otherwise>
              <span class="element"><xsl:value-of select="$name"/></span>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text> – </xsl:text>
          <xsl:call-template name="get-shortdesc">
            <xsl:with-param name="element-name" select="$name"/>
          </xsl:call-template>
          <xsl:call-template name="make-markup-feature-flags">
            <xsl:with-param name="element-name" select="$name"/>
          </xsl:call-template>
        </h2>
        <xsl:text>&#10;      </xsl:text>
        <xsl:variable name="space-name">
          <xsl:value-of select="concat(' ',$name,' ')"/>
        </xsl:variable>
        <div id="{$name}-longdesc" class="longdesc">
          <xsl:choose>
            <xsl:when test="document(concat('../elements/',$name,'.html'))//h:div[@id='longdesc']/node()">
              <xsl:copy-of select="document(concat('../elements/',$name,'.html'))//h:div[@id='longdesc']/node()"/>
            </xsl:when>
            <xsl:otherwise>
              <p><i class="TK">(element description to come)</i></p>
            </xsl:otherwise>
          </xsl:choose>
        </div>
        <xsl:text>&#10;      </xsl:text>
        <xsl:call-template name="make.content.models.section">
          <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
        <xsl:call-template name="make.attribute.models.section">
          <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
        <xsl:text>&#10;      </xsl:text>
        <!-- * <xsl:call-template name="make.attribute.definitions.section"> -->
          <!-- * <xsl:with-param name="name" select="$name"/> -->
        <!-- * </xsl:call-template> -->
        <!-- * <xsl:text>&#10;      </xsl:text> -->
        <xsl:call-template name="make.assertions.section">
          <xsl:with-param name="short-name" select="$short-name"/>
          <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
        <xsl:text>&#10;      </xsl:text>
        <xsl:call-template name="make.tag.omission.section">
          <xsl:with-param name="name">
            <xsl:choose>
              <xsl:when test="contains($name,'.')">
                <xsl:value-of select="substring-before($name,'.')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$name"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="full-name" select="$name"/>
        </xsl:call-template>
        <xsl:text>&#10;      </xsl:text>
        <xsl:call-template name="make.context.section">
          <xsl:with-param name="name">
            <xsl:choose>
              <xsl:when test="contains($name,'.')">
                <xsl:value-of select="substring-before($name,'.')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$name"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="full-name" select="$name"/>
        </xsl:call-template>
        <xsl:text>&#10;      </xsl:text>
        <!-- * ***************************************************************** -->
        <!-- * * MAKE "CHANGES" SECTION -->
        <!-- * ***************************************************************** -->
        <xsl:call-template name="make.changes.section">
          <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
        <!-- * ***************************************************************** -->
        <!-- * * MAKE "DETAILS" SECTION -->
        <!-- * ***************************************************************** -->
        <xsl:call-template name="make.details.section">
          <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
        <!-- * ***************************************************************** -->
        <!-- * * MAKE "DOM INTERFACE" SECTION -->
        <!-- * ***************************************************************** -->
        <xsl:call-template name="make.dom-interface.section">
          <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
        <!-- * ***************************************************************** -->
        <!-- * * MAKE "TYPICAL DEFAULT DISPLAY PROPERTIES" SECTION -->
        <!-- * ***************************************************************** -->
        <xsl:variable name="name-colon" select="concat($name,':')"/>
        <xsl:variable name="name-bracket" select="concat($name,'[')"/>
        <xsl:choose>
          <xsl:when
            test="document('../html.css.xml')/css/rule[child::selector[.=$name
            or starts-with(.,$name-colon)
            or starts-with(.,$name-bracket)
            ]]">
            <xsl:text>&#10;      </xsl:text>
            <div class="no-number no-toc display" id="{$name}-display">
              <xsl:text>&#10;        </xsl:text>
              <h2 class="element-subhead">Typical default display properties</h2>
              <!-- * <p class="non-norm">This section is non-normative.</p> -->
              <xsl:text>&#10;        </xsl:text>
              <div class="css-props" id="{$name}-css">
                <xsl:for-each select="document('../html.css.xml')/css/rule[child::selector[.=$name
                  or starts-with(.,$name-colon)
                  or starts-with(.,$name-bracket)
                  ]]">
                  <xsl:if test="properties/property and not(selector[contains(., '(')])">
                    <!-- * only include this rule if it actually has some -->
                    <!-- * properties -->
                  <div class="selectors">
                    <xsl:for-each select="selector[.=$name
                      or starts-with(.,$name-colon)
                      or starts-with(.,$name-bracket)
                      ]">
                      <span class="selector">
                        <xsl:for-each select="node()">
                          <xsl:choose>
                            <xsl:when test="self::i[class='vendor-value']">
                              <var class="vendor-value">
                                <xsl:copy-of select="node()"/>
                              </var>
                            </xsl:when>
                            <xsl:when test="self::span[@class='predicate']">
                              <span class="predicate">
                                <xsl:copy-of select="node()"/>
                              </span>
                            </xsl:when>
                            <xsl:when test="self::span[@class='pseudo']">
                              <span class="pseudo">
                                <xsl:copy-of select="node()"/>
                              </span>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:copy-of select="."/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:for-each>
                      </span>
                      <xsl:if test="following-sibling::selector[.=$name
                      or starts-with(.,$name-colon)
                      or starts-with(.,$name-bracket)
                      ]">
                        <xsl:text>, </xsl:text>
                      </xsl:if>
                    </xsl:for-each>
                    <xsl:text> {&#10;</xsl:text>
                  </div>
                  <div class="properties">
                    <xsl:for-each select="properties/property">
                      <div class="css-property">
                        <span class="prop-name">
                          <xsl:for-each select="name/node()">
                            <xsl:choose>
                              <xsl:when test="local-name() = 'i'">
                                <var class="vendor-value">
                                  <xsl:copy-of select="node()"/>
                                </var>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:copy-of select="."/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:for-each>
                        </span>
                        <xsl:text>: </xsl:text>
                        <span class="prop-value">
                          <xsl:for-each select="value/node()">
                            <xsl:choose>
                              <xsl:when test="local-name() = 'i'">
                                <var class="vendor-value">
                                  <xsl:copy-of select="node()"/>
                                </var>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:copy-of select="."/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:for-each>
                        </span>
                        <xsl:text>;</xsl:text>
                        <xsl:if
                          test="not(following-sibling::property)">
                          <xsl:text> }</xsl:text>
                        </xsl:if>
                      </div>
                    </xsl:for-each>
                  </div>
                </xsl:if>
                </xsl:for-each>
              </div>
            </div>
          </xsl:when>
        </xsl:choose>
        <!-- * ***************************************************************** -->
        <!-- * * MAKE EXAMPLES SECTION -->
        <!-- * ***************************************************************** -->
        <xsl:if
          test="document(concat('../elements/',$name,'.html'))//h:div[@id='examples']">
          <xsl:text>&#10;</xsl:text>
          <div class="no-number no-toc examples" id="{$name}-examples">
            <xsl:text>&#10;</xsl:text>
            <h2 class="element-subhead">Examples</h2>
            <xsl:text>&#10;</xsl:text>
            <xsl:for-each 
              select="document(concat('../elements/',$name,'.html'))//h:div[@id='examples']/h:div">
              <xsl:copy-of select="document(concat('../examples/',.,'.xml'))"/>
              <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
          </div>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
      </section>
    </xsl:if>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE THE CONTENT MODELS SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make.content.models.section">
    <xsl:param name="name"/>
    <xsl:param name="name-dot" select="concat($name, '.')"/>
    <div class="no-number no-toc" id="{$name}-content-model">
      <xsl:text>&#10;        </xsl:text>
      <h2 class="element-subhead">Permitted contents</h2>
      <xsl:if test="$name='a' or $name='canvas' or $name='del' or $name='ins' or $name='map' or $name='noscript'">
        <a href="#transparent"></a>
      </xsl:if>
      <div class="content-models">
      <xsl:text>&#10;        </xsl:text>
      <xsl:text>&#10;      </xsl:text>
      <xsl:if test="
        $name='audio' or $name='video' or $name='object'">
        <p class="content-model-prologue"><a href="#transparent">Transparent</a>,
          with the following specific structure:</p>
      </xsl:if>
      <div>
        <xsl:attribute name="id">
          <xsl:value-of select="concat($name,'-mdls')"/>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="starts-with($name,'input.')">
            <xsl:text>&#10;        </xsl:text>
            <p class="elem-mdl"><span>empty (<a href="#void-element">void element</a>)</span></p>
          </xsl:when>
          <xsl:when test="$name='li'">
            <xsl:for-each select="$rnc-html//*[@id='li']/*[@class = 'model']">
              <xsl:text>&#10;        </xsl:text>
              <p class="elem-mdl">
                <xsl:apply-templates/>
              </p>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="$name='style'">
            <xsl:for-each select="$rnc-html//*[@id='style']/*[@class = 'model']">
              <xsl:text>&#10;        </xsl:text>
              <p class="elem-mdl">
                <xsl:apply-templates/>
              </p>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="$name='script'">
            <xsl:for-each select="$rnc-html//*[@id='script.elem.embedded']/*[@class = 'model']">
              <xsl:text>&#10;        </xsl:text>
              <p class="elem-mdl">
                <xsl:apply-templates/>
              </p>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each
              select="$rnc-html//*[@id=$name
              or (starts-with(@id,$name-dot) and child::h:span[@class='type']='element ')]/*[@class = 'model']">
              <xsl:text>&#10;        </xsl:text>
              <p class="elem-mdl">
                <xsl:apply-templates/>
              </p>
              <xsl:if test="not(position() = last())">
                <div class="postfix or">or</div>
              </xsl:if>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#10;        </xsl:text>
      </div>
      <xsl:text>&#10;      </xsl:text>
      </div>
    </div>
    <xsl:if
      test="document(concat('../elements/',$name,'.html'))//h:div[@id='prose-model']
      and not($show-content-models = 0)">
      <xsl:call-template name="show.static.content.model">
        <xsl:with-param name="name" select="$name"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE THE "CONTENT NOTES" SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="show.static.content.model">
    <xsl:param name="name"/>
    <div class="no-number no-toc" id="{$name}-contents">
      <h2 class="element-subhead">Content notes</h2>
      <div class="prose-model">
        <xsl:choose>
          <xsl:when
            test="document(concat('../elements/',$name,'.html'))//h:div[@id='prose-model'] = 'Phrasing content'">
            <p>
              <a href="#normal-character-data">normal character data</a>
              and
              <a href="#common.elem.phrasing">phrasing elements</a>
            </p>
          </xsl:when>
          <xsl:when
            test="document(concat('../elements/',$name,'.html'))//h:div[@id='prose-model'] = 'Flow content'">
            <p>
              <a href="#normal-character-data">normal character data</a>
              and
              <a href="#common.elem.phrasing">flow elements</a>
            </p>
          </xsl:when>
          <xsl:when
            test="document(concat('../elements/',$name,'.html'))//h:div[@id='prose-model'] = 'Transparent'">
            <div id="prose-model">
              <p><a href="#transparent">transparent</a></p>
            </div>
          </xsl:when>
          <xsl:when
            test="document(concat('../elements/',$name,'.html'))//h:div[@id='prose-model'] = 'Empty'">
            <p>Empty</p>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="document(concat('../elements/',$name,'.html'))//h:div[@id='prose-model']/node()"/>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
</xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE THE "TAG OMISSION" SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make.tag.omission.section">
    <xsl:param name="name"/>
    <xsl:param name="full-name"/>
    <div class="no-number no-toc tag-omission" id="{$full-name}-tags">
      <xsl:text>&#10;        </xsl:text>
      <h2 class="element-subhead">Tag omission</h2>
      <xsl:text>&#10;        </xsl:text>
      <xsl:choose>
        <xsl:when test="
          $name='area' 
          or $name='base' 
          or $name='br' 
          or $name='col' 
          or $name='command' 
          or $name='embed' 
          or $name='hr' 
          or $name='img' 
          or $name='input' 
          or $name='keygen' 
          or $name='link' 
          or $name='meta' 
          or $name='param' 
          or $name='source'
          or $name='track'
          or $name='wbr'
          ">
          <p>The
            <span class="element"><xsl:value-of select="$name"/></span>
            element is a <a href="#void-element" >void element</a>.
            A<xsl:if test="
              $name='area'
              or $name='hr'
              or starts-with($name,'e')
              or starts-with($name,'i')
              "><xsl:text>n</xsl:text>
            </xsl:if>
            <xsl:text> </xsl:text>
            <span class="element"><xsl:value-of select="$name"/></span>
            element must have a
            <span title="syntax-start-tag" >start tag</span>
            but must not have an
            <span title="syntax-end-tag" >end tag</span>.</p>
        </xsl:when>
        <xsl:when
          test="document(concat('../elements/',$full-name,'.html'))//h:div[@id='tags']/node()">
          <xsl:copy-of select="document(concat('../elements/',$full-name,'.html'))//h:div[@id='tags']/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <p>A<xsl:if test="
              $name='area'
              or starts-with($name,'a')
              or starts-with($name,'e')
              or starts-with($name,'i')
              or starts-with($name,'o')
              or $name='h1'
              or $name='h2'
              or $name='h3'
              or $name='h4'
              or $name='h5'
              or $name='h6'
              or $name='h6'
              or $name='s'
              "><xsl:text>n</xsl:text>
            </xsl:if>
            <xsl:text> </xsl:text>
            <span class="element"><xsl:value-of select="$name"/></span>
            element must have both a
            <span title="syntax-start-tag">start tag</span>
            and an
            <span title="syntax-end-tag">end tag</span>.</p>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#10;      </xsl:text>
    </div>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE THE "CONTEXT" SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make.context.section">
    <xsl:param name="name"/>
    <xsl:param name="full-name"/>
    <xsl:if test="not($name = 'html')">
      <div class="no-number no-toc" id="{$full-name}-context">
        <xsl:text>&#10;        </xsl:text>
        <h2 class="element-subhead">Permitted parent elements</h2>
        <xsl:text>&#10;        </xsl:text>
        <p class="permitted-parents">
          <xsl:choose>
            <xsl:when test="$name='li'">
              <xsl:for-each
                select="$rnc-html//h:span[@class
                = 'pattern'][child::h:a[@href = '#li'
                or @href = '#mli'
                or @href = '#oli'
                ]]">
                <xsl:call-template name="make.context"/>
                <xsl:if test="not(position() = last())">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="$name='param'">
              <a href="#object">
                <xsl:text>object</xsl:text>
              </a>
            </xsl:when>
            <xsl:when test="$name='source' or $name='track'">
              <a href="#audio">
                <xsl:text>audio</xsl:text>
              </a>
              <xsl:text>, </xsl:text>
              <a href="#video">
                <xsl:text>video</xsl:text>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="
                  $name='button'
                  or $name='input'
                  or $name='command'
                  ">
                  <xsl:for-each
                    select="$rnc-html//h:span[@class
                    = 'pattern'][child::h:a[@href = concat('#',$name)
                    or starts-with(@href,concat('#',$name,'.elem.'))
                    ]]">
                    <xsl:call-template name="make.context"/>
                    <xsl:if test="not(position() = last())">
                      <xsl:text>, </xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each
                    select="$rnc-html//h:span[@class
                    = 'pattern'][descendant::h:a[@href = concat('#',$full-name)
                    or starts-with(@href,concat('#',$full-name,'.elem.'))
                    ]][not(@id='script')]">
                    <xsl:if test="not($full-name = @id)">
                      <xsl:call-template name="make.context"/>
                    </xsl:if>
                    <xsl:if test="not(position() = last())">
                      <xsl:text>, </xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </p>
        <xsl:text>&#10;      </xsl:text>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE THE "DOM INTERFACE" SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make.dom-interface.section">
    <xsl:param name="name"/>
    <xsl:variable name="spec-url">http://dev.w3.org/html5/spec/</xsl:variable>
    <div class="no-number no-toc interface" id="{$name}-interface">
      <xsl:text>&#10;        </xsl:text>
      <h2 class="element-subhead">DOM interface</h2>
      <xsl:choose>
        <xsl:when test="document(concat('../elements/',$name,'.html'))//h:div[@id='dom-interface']">
          <xsl:variable name="interface" select="document(concat('../elements/',$name,'.html'))//h:div[@id='dom-interface']"/>
          <xsl:variable name="idl-section">
            <xsl:call-template name="get-idl">
              <xsl:with-param name="interface" select="$interface"/>
            </xsl:call-template>
          </xsl:variable>
          <pre class="idl">
            <xsl:for-each select="exsl:node-set($idl-section)/pre[@class='idl']/node()">
              <xsl:choose>
                <xsl:when test="self::dfn">
                  <b><xsl:value-of select="."/></b>
                </xsl:when>
                <xsl:when test="self::a">
                  <xsl:choose>
                    <xsl:when test="starts-with(@href,'http://')">
                      <a href="{@href}" title="{@title}"><xsl:value-of select="."/></a>
                    </xsl:when>
                    <xsl:when test="starts-with(@href,'#')">
                      <xsl:variable name="filename">
                        <xsl:call-template name="get-spec-filename">
                          <xsl:with-param name="ref" select="@href"/>
                          <xsl:with-param name="base">http://dev.w3.org/html5/spec/</xsl:with-param>
                          <xsl:with-param name="fragment-file">../fragment-links-full.html</xsl:with-param>
                        </xsl:call-template>
                      </xsl:variable>
                      <a href="{$filename}{@href}" title="{@title}"><xsl:value-of select="."/></a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="{$spec-url}{@href}" title="{@title}"><xsl:value-of select="."/></a>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="not(name() = '')">
                  <xsl:element name="{local-name(.)}">
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="node()"/>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </pre>
        </xsl:when>
        <xsl:otherwise>
          <p class="dom-interface">Uses
            <a href="{$htmlelement-filename}#htmlelement" title="HTMLElement">HTMLElement</a>.
          </p>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE THE "CHANGES" SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make.changes.section">
    <xsl:param name="name"/>
    <xsl:if
      test="document(concat('../elements/',$name,'.html'))//h:div[@id='changes']">
      <xsl:text>&#10;        </xsl:text>
      <div class="no-number no-toc" id="{$name}-changes">
        <xsl:text>&#10;        </xsl:text>
        <h2 class="element-subhead">Changes in HTML5</h2>
        <div class="changes">
          <xsl:copy-of select="document(concat('../elements/',$name,'.html'))//h:div[@id='changes']/node()"/>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE THE "DETAILS" SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make.details.section">
    <xsl:param name="name"/>
    <xsl:if
      test="document(concat('../elements/',$name,'.html'))//h:div[@id='details']">
      <xsl:text>&#10;        </xsl:text>
      <div class="no-number no-toc" id="{$name}-details">
        <xsl:text>&#10;        </xsl:text>
        <h2 class="element-subhead">Details</h2>
        <div class="details">
          <xsl:copy-of select="document(concat('../elements/',$name,'.html'))//h:div[@id='details']/node()"/>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

<!-- * ================================================================= -->
<!-- * ================================================================= -->

  <!-- * ***************************************************************** -->
  <!-- * * MAKE AN INDIVIDUAL CONTEXT SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make.context">
    <xsl:variable name="parent">
      <xsl:value-of select="substring-before(@id,'.inner')"/>
    </xsl:variable>
    <xsl:variable name="adjusted-ref">
      <!-- * HACK special-casing to deal with media.source -->
      <xsl:value-of select="substring-before(@id,'.inner.')"/>
    </xsl:variable>
    <span class="context-mdl">
      <xsl:choose>
        <xsl:when test="@id='script'">
          <a href="#{@id}">
            <xsl:value-of select="@id"/>
          </a>
          <!-- * <xsl:text> = </xsl:text> -->
          <!-- * <xsl:for-each select="node()"> -->
            <!-- * <xsl:call-template name="garnish.as.needed"/> -->
          <!-- * </xsl:for-each> -->
        </xsl:when>
        <xsl:when test="@id='common.elem.phrasing'">
          <span>any element that can contain
            <a href="#{@id}">
              <xsl:text>phrasing elements</xsl:text>
            </a>
          </span>
        </xsl:when>
        <xsl:when test="@id='common.elem.flow'">
          <span>any element that can contain
            <a href="#{@id}">
              <xsl:text>flow elements</xsl:text>
            </a>
          </span>
        </xsl:when>
        <xsl:when test="@id='common.elem.metadata'">
          <span>any element that can contain
            <a href="#{@id}">
              <xsl:text>metadata elements</xsl:text>
            </a>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="
              contains(@id,'.inner.flow')
              or 
              contains(@id,'.inner.phrasing')
              ">
              <!-- * HACK special-casing to deal with <param> and <source> elements -->
              <a href="#{$adjusted-ref}"><xsl:value-of select="$adjusted-ref"/></a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="contains($parent,'.elem.')">
                  <a href="#{substring-before($parent,'.elem.')}">
                    <xsl:value-of select="substring-before($parent,'.elem.')"/>
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <a href="#{$parent}">
                    <xsl:value-of select="$parent"/>
                  </a>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
          <!-- * <xsl:text> = </xsl:text> -->
          <!-- * <xsl:for-each select="node()"> -->
            <!-- * <xsl:call-template name="garnish.as.needed"/> -->
          <!-- * </xsl:for-each> -->
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template name="make.special.context">
    <xsl:param name="element-name"/>
    The details of the
      <span class="element">
        <xsl:value-of select="$element-name"/>
      </span>
      element are described in the following sections:
    <ul>
      <xsl:for-each select="node()">
        <xsl:if test="@href">
          <li>
            <xsl:variable name="target">
              <xsl:call-template name="get-spec-target">
                <xsl:with-param name="name" select="normalize-space(.)"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="filename">
              <xsl:call-template name="get-spec-filename">
                <xsl:with-param name="ref" select="$target"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$element-name = 'input'">
              <xsl:call-template name="make-element-spec-link">
                <xsl:with-param name="element-name" select="$element-name"/>
                <xsl:with-param name="filename" select="$filename"/>
                <xsl:with-param name="target" select="$target"/>
              </xsl:call-template>
              <span><xsl:text> </xsl:text></span>
            </xsl:if>
            <a>
              <xsl:copy-of select="@*"/>
              <xsl:value-of select="concat(substring-before(.,'.'),' type=',substring-after(.,'.'))"/>
            </a>
            <xsl:if test="$element-name = 'input'">
              <span><xsl:text> </xsl:text></span>
              <xsl:call-template name="make-markup-feature-flags">
                <xsl:with-param name="element-name" select="normalize-space(.)"/>
              </xsl:call-template>
            </xsl:if>
          </li>
        </xsl:if>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE THE ATTRIBUTE MODELS SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make.attribute.models.section">
    <xsl:param name="name"/>
    <xsl:param name="name-dot" select="concat($name, '.')"/>
    <xsl:variable name="attribute-model">
      <xsl:choose>
        <xsl:when test="$rnc-html//*[(starts-with(@id,$name-dot)
          and substring(@id,string-length(@id)-4)='attrs')]">
          <xsl:choose>
            <xsl:when test="@name='embed'">
              <div class="attr-content-models">
                <div class="attr-content-model">
                  <xsl:for-each
                    select="$rnc-html//*[@class='pattern']
                    [@id='embed.attrs']/node()">
                    <xsl:choose>
                      <xsl:when test="contains(@class,'zeroormore')"/>
                      <xsl:when test="@href = '#embed.attrs.other'"/>
                      <xsl:otherwise>
                        <xsl:copy-of select="."/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                  <xsl:text> </xsl:text>
                  <span class="attr-prose-desc">Any other attribute that has no namespace</span>
                </div>
              </div>
            </xsl:when>
            <xsl:when test="@name='colgroup'">
              <div class="attr-content-models">
                <p>
                  <span class="pattern" id="colgroup.attrs">
                    <a
                      title="global-attributes"
                      href="#global-attributes">global attributes</a>
                    <span class="postfix optional">?</span>
                    <xsl:text> </xsl:text>
                    <span class="postfix intermixed">&amp;</span>
                    <xsl:text> </xsl:text>
                    <span class="postfix optional">?</span>
                    <xsl:text> </xsl:text>
                    <a class="ref"
                      title="colgroup.attrs.span"
                      href="#colgroup.attrs.span">span</a>
                    <span class="postfix optional">?</span>
                  </span>
                </p>
              </div>
            </xsl:when>
            <xsl:when test="@name='area'">
              <div class="attr-content-models">
                <p>
                  <!-- * <a -->
                    <!-- * href="#area.attrs"> -->
                    <!-- * <xsl:text>area.attrs</xsl:text> -->
                    <!-- * </a> -->
                  <!-- * <xsl:text> -->
                    <!-- * = -->
                    <!-- * </xsl:text> -->
                  <span
                    class="pattern" id="area.attrs">
                    <xsl:for-each
                      select="$rnc-html//*[@id='area.attrs']/node()">
                      <xsl:choose>
                        <xsl:when
                          test="@href='#area.attrs.shape'">
                          <xsl:copy-of
                            select="$rnc-html//*[@id='area.attrs.shape']/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:copy-of select="."/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                  </span>
                </p>
              </div>
            </xsl:when>
            <xsl:when test="@name='li'">
              <div class="attr-content-models">
                <p>
                  <a
                    title="global-attributes"
                    href="#global-attributes">global attributes</a>
                  <span class="postfix optional">?</span>
                  <xsl:text> </xsl:text>
                  <span class="postfix &amp;">&amp;</span>
                  <xsl:text> </xsl:text>
                  <a
                    class="ref"
                    title="li.attrs.value"
                    href="#li.attrs.value">value</a>
                  <span class="postfix optional">?</span>
                </p>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="$rnc-html">
                <div>
                  <xsl:attribute name="class">attr-content-models</xsl:attribute>
                  <xsl:for-each select="//*[starts-with(@id,$name-dot)
                    and substring(@id,string-length(@id)-4)='attrs']">
                    <xsl:text>&#10;          </xsl:text>
                    <p>
                      <xsl:variable name="ref" select="@id"/>
                      <xsl:choose>
                        <xsl:when test="starts-with($ref,'meta.')">
                          <xsl:for-each select="node()">
                            <xsl:choose>
                              <xsl:when test="@href='#common.attrs.core'">
                                <a href="#common.attrs.core">core attributes</a>
                                <span class="postfix optional">?</span>
                              </xsl:when>
                              <xsl:when test="@href='#common.attrs.event-handler'">
                                <a href="#common.attrs.core">event-handler attributes</a>
                                <span class="postfix optional">?</span>
                              </xsl:when>
                              <xsl:when test="@href='#common.attrs.xml'">
                                <a href="#common.attrs.core">xml attributes</a>
                                <span class="postfix optional">?</span>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:copy-of select="."/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="
                          key('elements',$ref)//h:a[@href='#common-form.attrs']
                          or key('elements',$ref)//h:a[starts-with(@href,'#shared-form.attrs')]
                          or key('elements',$ref)//h:a[starts-with(@href,'#common-form.attrs')]
                          or key('elements',$ref)//h:a[starts-with(@href,'#input.attrs')]
                          ">
                          <span class="pattern" id="{@id}">
                            <xsl:for-each select="key('elements',$ref)/node()">
                              <xsl:choose>
                                <xsl:when test="@class='agroupof'">
                                  <span class="agroupof">
                                    <xsl:for-each select="node()">
                                      <xsl:choose>
                                        <xsl:when test="@href='#common-form.attrs'">
                                          <xsl:for-each select="key('elements','common-form.attrs')/node()">
                                            <xsl:call-template name="pack-common-attribute">
                                              <xsl:with-param name="name" select="$name"/>
                                              <xsl:with-param name="prefix">#common-form.attrs.</xsl:with-param>
                                            </xsl:call-template>
                                          </xsl:for-each>
                                        </xsl:when>
                                        <xsl:when test="starts-with(@href,'#common-form.attrs')">
                                          <xsl:call-template name="pack-common-attribute">
                                            <xsl:with-param name="name" select="$name"/>
                                            <xsl:with-param name="prefix">#common-form.attrs.</xsl:with-param>
                                          </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="starts-with(@href,'#shared-form.attrs')">
                                          <xsl:call-template name="pack-common-attribute">
                                            <xsl:with-param name="name" select="$name"/>
                                            <xsl:with-param name="prefix">#shared-form.attrs.</xsl:with-param>
                                          </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="starts-with(@href,'#input.attrs')">
                                          <xsl:call-template name="pack-common-attribute">
                                            <xsl:with-param name="name" select="$name"/>
                                            <xsl:with-param name="prefix">#input.attrs.</xsl:with-param>
                                          </xsl:call-template>
                                        </xsl:when>
                                        <xsl:otherwise>
                                          <xsl:copy-of select="."/>
                                        </xsl:otherwise>
                                      </xsl:choose>
                                    </xsl:for-each>
                                  </span>
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:choose>
                                    <xsl:when test="@href='#common-form.attrs'">
                                      <xsl:for-each
                                        select="key('elements','common-form.attrs')/node()">
                                        <xsl:call-template name="pack-common-attribute">
                                          <xsl:with-param name="name" select="$name"/>
                                          <xsl:with-param name="prefix">#common-form.attrs.</xsl:with-param>
                                        </xsl:call-template>
                                      </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="starts-with(@href,'#common-form.attrs')">
                                      <xsl:call-template name="pack-common-attribute">
                                        <xsl:with-param name="name" select="$name"/>
                                        <xsl:with-param name="prefix">#common-form.attrs.</xsl:with-param>
                                      </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="starts-with(@href,'#shared-form.attrs')">
                                      <xsl:call-template name="pack-common-attribute">
                                        <xsl:with-param name="name" select="$name"/>
                                        <xsl:with-param name="prefix">#shared-form.attrs.</xsl:with-param>
                                      </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="starts-with(@href,'#input.attrs')">
                                      <xsl:call-template name="pack-common-attribute">
                                        <xsl:with-param name="name" select="$name"/>
                                        <xsl:with-param name="prefix">#input.attrs.</xsl:with-param>
                                      </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                  </xsl:choose>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:for-each>
                          </span>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:copy-of select="."/>
                          <xsl:if test="$name = 'audio'">
                            <span class="postfix intermixed">&amp;</span>
                            <xsl:text> </xsl:text>
                            <a
                              class="ref"
                              title="video.attrs.src"
                              href="#audio.attrs.src">src</a>
                            <span class="postfix optional">?</span>
                          </xsl:if>
                          <xsl:if test="$name = 'video'">
                            <span class="postfix intermixed">&amp;</span>
                            <xsl:text> </xsl:text>
                            <a
                              class="ref"
                              title="video.attrs.src"
                              href="#video.attrs.src">src</a>
                            <span class="postfix optional">?</span>
                          </xsl:if>
                        </xsl:otherwise>
                      </xsl:choose>
                    </p>
                    <xsl:if test="not(position() = last())">
                      <span class="postfix or">or</span>
                    </xsl:if>
                  </xsl:for-each>
                </div>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$rnc-html">
            <div class="attr-content-models">
              <xsl:for-each select="key('elements','script.attrs.embedded')">
                <xsl:text>&#10;          </xsl:text>
                <p>
                  <xsl:copy-of select="node()"/>
                </p>
              </xsl:for-each>
              <xsl:text>&#10;        </xsl:text>
              <div class="postfix or">or</div>
              <xsl:for-each select="key('elements','script.attrs.imported')">
                <xsl:text>&#10;          </xsl:text>
                <p>
                  <xsl:copy-of select="node()"/>
                </p>
              </xsl:for-each>
              <xsl:text>&#10;        </xsl:text>
            </div>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="no-number no-toc" id="{$name}-attributes">
      <xsl:text>&#10;        </xsl:text>
      <h2 class="element-subhead">Permitted attributes</h2>
      <xsl:text>&#10;        </xsl:text>
      <xsl:if test="count(exsl:node-set($attribute-model)//h:a) > 1">
        <xsl:copy-of select="$attribute-model"/>
        <xsl:text>&#10;        </xsl:text>
      </xsl:if>
      <dl class="attr-defs">
        <xsl:for-each select="exsl:node-set($attribute-model)//h:a">
          <xsl:call-template name="make.attribute.definition">
            <xsl:with-param name="name" select="$name"/>
          </xsl:call-template>
        </xsl:for-each>
        <xsl:text>&#10;        </xsl:text>
      </dl>
    </div>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE AN INDIVIDUAL ATTRIBUTE DEFINITION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make.attribute.definition">
    <xsl:param name="name"/>
    <xsl:param name="attribute-name" select="."/>
    <xsl:param name="href">
      <xsl:choose>
        <xsl:when test="@href='#global-attributes'">
          <xsl:value-of select="@href"/>
        </xsl:when>
        <xsl:when test="not(@class = 'ref')">
          <xsl:value-of select="@class"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@href"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:choose>
      <xsl:when
        test="(not(preceding::*[@href=$href])
        or starts-with($href,'#aria-')
        or $href='#tables.attrs.headers'
        or $href='#common-form.attrs.form')
        and
        not(starts-with($href,'#area.attrs.coords.'))
        ">
        <xsl:variable name="ref">
          <xsl:value-of select="substring-after($href,'#')"/>
        </xsl:variable>
        <xsl:text>&#10;            </xsl:text>
        <xsl:variable name="definition">
        <dt>
          <xsl:if test="not(@href = '#global-attributes') and not(@href = '#common.attrs')">
            <xsl:attribute name="id">
              <xsl:value-of select="substring-after(@href,'#')"/>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:value-of select="substring-after(@href,'#')"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:variable name="spec-target">
            <xsl:choose>
              <xsl:when test="document('../src/map-attributes.html')//*[preceding-sibling::*=$ref]">
                <xsl:value-of select="concat('#',document('../src/map-attributes.html')//*[preceding-sibling::*=$ref])"/>
              </xsl:when>
              <xsl:when test="starts-with($href,'#scripting.attr.on')">
                <xsl:value-of select="concat('#ix-handler-',substring-after($href,'#scripting.attr.'))"/>
              </xsl:when>
              <xsl:when test="starts-with($href,'#body.attrs.on')">
                <xsl:value-of select="concat('#ix-handler-window-',substring-after($href,'#body.attrs.'))"/>
              </xsl:when>
              <xsl:when test="starts-with($href,'#input.attrs.step.')">#attr-input-step</xsl:when>
              <xsl:when test="starts-with($href,'#input.') and
                (
                contains($href,'.attrs.type')
                or
                contains($href,'.attrs.value')
                )
                ">
                <xsl:value-of select="concat('#',substring-before(substring-after($href,'#input.'),'.attrs.'),'-state')"/>
              </xsl:when>
              <xsl:when test="starts-with($href,'#input.')">
                <xsl:value-of select="concat('#attr-input-',substring-after($href,'.attrs.'))"/>
              </xsl:when>
              <xsl:when test="starts-with($href,'#shared-form.attrs.')">
                <xsl:value-of select="concat('#the-',substring-after($href,'#shared-form.attrs.'),'-attribute')"/>
              </xsl:when>
              <xsl:when test="starts-with($href,'#area.attrs.shape.')">#attr-area-shape</xsl:when>
              <xsl:when test="starts-with($href,'#area.attrs.coords.')"/>
              <xsl:otherwise>
                <xsl:value-of select="concat('#attr-',$name,'-',$attribute-name)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="filename">
            <xsl:if test="not($spec-target = '')">
              <xsl:call-template name="get-spec-filename">
                <xsl:with-param name="ref" select="$spec-target"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="starts-with($spec-target,'#ix-')">
              <a
                class="spec-link"
                title="Read about this attribute in the HTML5 spec"
                href="http://dev.w3.org/html5/spec/section-index.html{$spec-target}">&#9432;</a>
              <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="not($filename='')">
                <a
                  class="spec-link"
                  title="Read about this attribute in the HTML5 spec"
                  href="{$filename}{$spec-target}">&#9432;</a>
                <xsl:text>&#10;</xsl:text>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="$ref = 'common.attrs'
              or @href = '#global-attributes'">
              <a class="attribute-name"
                title="global-attributes"
                href="#global-attributes">
                <xsl:text>global attributes</xsl:text> 
              </a>
            </xsl:when>
            <xsl:when test="starts-with($ref,'area.attrs.shape.')">
              <xsl:call-template name="make.area.shape.attribute.definition">
                <xsl:with-param name="ref" select="$ref"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="$ref = 'time.attrs.datetime'">
              <span class="attribute-name">datetime</span> (any)
            </xsl:when>
            <xsl:when test="$ref = 'time.attrs.datetime.dateonly'">
              <span class="attribute-name">datetime</span> (date only)
            </xsl:when>
            <xsl:when test="$ref = 'time.attrs.datetime.tz'">
              <span class="attribute-name">datetime</span> (date and time)
            </xsl:when>
            <xsl:when test="contains(node(),'.')">
              <span class="attribute-name">
                <xsl:choose>
                  <xsl:when test="starts-with(node(),'wrap.')">
                    <xsl:text>wrap</xsl:text> 
                  </xsl:when>
                  <xsl:when
                    test="$ref='input.email.attrs.value.single'">
                    <xsl:text>value</xsl:text> 
                  </xsl:when>
                  <xsl:when
                    test="$ref='input.email.attrs.value.multiple'">
                    <xsl:text>value</xsl:text> 
                  </xsl:when>
                  <xsl:when test="starts-with(node(),'type.')">
                    <xsl:value-of select="substring-before(node(),'.')"/>
                  </xsl:when>
                  <xsl:when test="contains($ref,'.attrs.http-equiv.')">
                    <xsl:text>http-equiv</xsl:text>
                  </xsl:when>
                  <xsl:when test="contains($ref,'.attrs.content.')">
                    <xsl:text>content</xsl:text>
                  </xsl:when>
                  <xsl:when test="starts-with($ref,'input.attrs.step.')">
                    <xsl:text>step</xsl:text>
                  </xsl:when>
                  <xsl:when test="starts-with($ref,'scripting.attr.form.')">
                    <xsl:value-of
                      select="concat('on',substring-after($ref,'scripting.attr.form.'))"/>
                  </xsl:when>
                  <xsl:when test="contains($ref,'xmlbase')">
                    <xsl:text>xml:base</xsl:text>
                  </xsl:when>
                  <xsl:when test="contains($ref,'xmllang')">
                    <xsl:text>xml:lang</xsl:text>
                  </xsl:when>
                  <xsl:when test="contains($ref,'xmlspace')">
                    <xsl:text>xml:space</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="substring-after-last">
                      <xsl:with-param name="input" select="node()"/>
                      <xsl:with-param name="substr">.</xsl:with-param>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </span>
            </xsl:when>
            <xsl:when test="starts-with($ref,'button.')
              or starts-with($ref,'input.')
              or starts-with($ref,'command.')
              or starts-with($ref,'meta.')
              ">
              <span class="attribute-name">
                <xsl:copy-of select="node()"/>
              </span>
            </xsl:when>
            <xsl:otherwise>
              <span class="attribute-name">
                <xsl:choose>
                  <xsl:when test="$ref='common.attrs.xml-id'">
                    <xsl:text>xml:id</xsl:text>
                  </xsl:when>
                  <xsl:when test="$ref='common.attrs.xmlbase'">
                    <xsl:text>xml:base</xsl:text>
                  </xsl:when>
                  <xsl:when test="$ref='common.attrs.xmlspace'">
                    <xsl:text>xml:space</xsl:text>
                  </xsl:when>
                  <xsl:when test="$ref='common.attrs.xmllang'">
                    <xsl:text>xml:lang</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="node()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </span>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:variable name="model">
            <xsl:copy-of
              select="key('elements',$ref)//*[@class='model']"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$ref = 'common.attrs'
              or @href='#global-attributes'
              or starts-with($ref,'area.attrs.shape.')
              "/>
            <xsl:otherwise>
              <xsl:text> = </xsl:text>
              <span class="attr-values">
                <xsl:for-each select="$rnc-html">
                  <xsl:choose>
                    <xsl:when test="$ref='form.attrs.method'
                      or $ref='form.attrs.enctype'
                      or $ref='shared-form.attrs.formmethod'
                      or $ref='shared-form.attrs.formenctype'
                      ">
                      <xsl:variable name="datatype" select="concat($ref,'.data')"/>
                      <xsl:for-each select="key('elements',$datatype)/node()">
                        <xsl:call-template name="process.datatype.reference"/>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="normalize-space(key('elements',$ref)//*[@class='model'])='string'">
                      <a href="#data-string">string</a>
                    </xsl:when>
                    <xsl:when test="normalize-space(key('elements',$ref)//*[@class='model'])='d:link-rel'">
                      <a href="#common.data.tokens">set of space-separated tokens</a>
                    </xsl:when>
                    <xsl:when test="normalize-space(key('elements',$ref)//*[@class='model'])='d:meta-name'">
                      <a href="#data-string">string</a>
                    </xsl:when>
                    <xsl:when
                      test="not(key('elements',$ref)//*[@class='model']/h:a)">
                      <xsl:for-each select="key('elements',$ref)//*[@class='model']/node()">
                        <xsl:choose>
                          <xsl:when test="name()=''">
                            <xsl:call-template name="string.subst">
                              <xsl:with-param name="string" select="."/>
                              <xsl:with-param name="target"> string "</xsl:with-param>
                              <xsl:with-param name="replacement">"</xsl:with-param>
                            </xsl:call-template>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:copy-of select="."/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each
                        select="key('elements',$ref)//*[@class='model']/node()">
                        <xsl:choose>
                          <xsl:when test="name()=''">
                            <xsl:call-template name="string.subst">
                              <xsl:with-param name="string" select="."/>
                              <xsl:with-param name="target"> string "</xsl:with-param>
                              <xsl:with-param name="replacement">"</xsl:with-param>
                            </xsl:call-template>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:call-template name="process.datatype.reference"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </span>
              <xsl:text> </xsl:text>
              <xsl:if test="not($name='') and document(concat('../elements/',$name,'.html'))//*[@id=$ref][contains(@class,'new')]
                or $attributes//*[@id=$ref][contains(@class,'new')]
                ">
                <span class="new-feature"
                  title="This markup feature is newly added in HTML5."
                  >NEW</span>
              </xsl:if>
              <xsl:if test="not($name='') and document(concat('../elements/',$name,'.html'))//*[@id=$ref][contains(@class,'changed')]
                or $attributes//*[@id=$ref][contains(@class,'changed')]
                ">
                <span class="changed-feature"
                  title="The meaning, structure, or purpose of this markup feature has changed in HTML5."
                  >CHANGED</span>
              </xsl:if>
              <xsl:if test="not($name='') and document(concat('../elements/',$name,'.html'))//*[@id=$ref][contains(@class,'obsolete')]">
                <span class="obsoleted-feature"
                  title="This markup feature has been obsoleted in HTML5."
                  >OBSOLETE</span>
              </xsl:if>
              <xsl:text>&#10;</xsl:text>
              <a class="hash"
                href="{@href}">#</a>
              <xsl:text>&#10;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </dt>
        </xsl:variable>
        <xsl:copy-of select="$definition"/>
        <xsl:text>&#10;            </xsl:text>
        <xsl:choose>
          <xsl:when test="$ref = 'common.attrs' or @href = '#global-attributes'">
            <dd>Any attributes permitted globally.</dd>
          </xsl:when>
          <xsl:when
            test="not($name='') and document(concat('../elements/',$name,'.html'))//*[@id=$ref]">
            <xsl:copy-of select="document(concat('../elements/',$name,'.html'))//h:dd[preceding-sibling::h:dt[@id=$ref]]"/>
          </xsl:when>
          <xsl:when
            test="$attributes//*[@id=$ref]">
            <xsl:copy-of
              select="$attributes//h:dd[preceding-sibling::h:dt[@id=$ref]]"/>
          </xsl:when>
          <xsl:otherwise>
            <dd>
              <xsl:if test="not(starts-with($ref,'scripting.attr'))
                and not(starts-with($ref,'body.attrs'))">
                <xsl:message>Missing description for:<xsl:text> </xsl:text><xsl:value-of select="$ref"/></xsl:message>
                <i class="TK">(detailed attribute description to come)</i>
              </xsl:if>
            </dd>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#10;          </xsl:text>
        <!-- * <xsl:if -->
          <!-- * test="exsl:node-set($warnings)/s:rule[child::s:context = $name] -->
          <!-- * [child::s:report[@test[contains(.,concat('@',$attribute-name))]]] -->
          <!-- * and not($attribute-name='summary') -->
          <!-- * "> -->
          <!-- * <dd class="warning"> -->
            <!-- * <xsl:value-of -->
              <!-- * select="exsl:node-set($warnings)/s:rule[child::s:context = $name] -->
              <!-- * /s:report[@test[contains(.,concat('@',$attribute-name))]] -->
              <!-- * "/> -->
          <!-- * </dd> -->
        <!-- * </xsl:if> -->
        <xsl:for-each select="exsl:node-set($definition)/*/*[@class='attr-values']/h:a">
          <xsl:if test="
            starts-with(@href,'#common.data.')
            or starts-with(@href,'#form.data.')
            ">
            <xsl:variable name="datatype">
              <xsl:choose>
                <xsl:when test="starts-with(@href,'#common.data.')">
                  <xsl:value-of select="substring-after(@href,'#common.data.')"/>
                </xsl:when>
                <xsl:when test="starts-with(@href,'#form.data.')">
                  <xsl:value-of select="substring-after(@href,'#form.data.')"/>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:for-each select="document('../src/datatypes.html')">
              <xsl:if test="not(
                $datatype = 'tokens'
                or $datatype = 'idref'
                or $datatype = 'hash-name'
                or $datatype = 'default-style'
                or $datatype = 'sandbox-allow-list'
                or $datatype = 'functionbody'
                or $datatype = 'audio-states-list'
                or starts-with($datatype,'uri')
                or starts-with($datatype,'integer')
                or starts-with($datatype,'float')
                )">
                <xsl:text>&#10;</xsl:text>
                <xsl:for-each select="key('datatypes',$datatype)/following-sibling::h:dd[not(position() = 1)]">
                  <dd>
                    <xsl:for-each select="*">
                      <xsl:element name="{local-name()}">
                        <xsl:copy-of select="@*"/>
                        <xsl:for-each select="node()">
                          <xsl:choose>
                            <xsl:when test="@id">
                              <var class="defined-elsewhere">
                                <xsl:copy-of select="node()"/>
                              </var>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:copy-of select="."/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:for-each>
                      </xsl:element>
                    </xsl:for-each>
                  </dd>
                </xsl:for-each>
              </xsl:if>
            </xsl:for-each>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <!-- * do nothing -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="make.area.shape.attribute.definition">
    <xsl:param name="ref"/>
    <xsl:variable name="shape" select="substring-after($ref,'area.attrs.shape.')"/>
    <xsl:variable name="coords.pattern" select="concat('area.attrs.coords.',$shape)"/>
    <xsl:for-each select="$rnc-html">
      <span class="qualified-attribute">
      <span class="attribute-name">shape</span>
      <xsl:text> = </xsl:text>
      <span class="attr-values">
        <xsl:variable name="model">
          <xsl:copy-of select="key('elements',$ref)//*[@class='model']"/>
        </xsl:variable>
        <xsl:call-template name="string.subst">
          <xsl:with-param name="string" select="$model"/>
          <xsl:with-param name="target"> string "</xsl:with-param>
          <xsl:with-param name="replacement">"</xsl:with-param>
        </xsl:call-template>
      </span>
      </span>
      <xsl:if test="not($ref='area.attrs.shape.default')">
        <span class="punc postfix &amp;">&amp;</span>
        <xsl:text> </xsl:text>
        <span class="attribute-name"
          id="{$coords.pattern}"
          >coords</span>
        <xsl:text> = </xsl:text>
        <span class="attr-values">
          <xsl:for-each select="key('elements',$coords.pattern)//*[@class='model']//h:a">
            <a>
              <xsl:copy-of select="@*"/>
              <xsl:value-of select="concat(.,' coordinates')"/>
            </a>
          </xsl:for-each>
        </span>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
      <a class="hash"
        title="{$ref}"
        href="#{$ref}">
        <xsl:text>#</xsl:text>
      </a>
      <xsl:text>&#10;</xsl:text>
      <xsl:if test="not($ref='area.attrs.shape.default')">
        <a class="hash"
          title="{$coords.pattern}"
          href="#{$coords.pattern}"
          >
          <xsl:text>#</xsl:text>
        </a>
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE THE ASSERTIONS SECTION -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make.assertions.section">
    <xsl:param name="name"/>
    <xsl:param name="short-name"/>
    <xsl:if test="
      not(starts-with($name,'meta.http-equiv.'))
      and not($name='meta.charset')
      ">
      <xsl:choose>
        <xsl:when
          test="exsl:node-set($assertions)/s:rule[child::s:context = $short-name]
          |document(concat('../elements/',$name,'.html'))//h:*[@id='constraints']
        ">
        <xsl:text>&#10;      </xsl:text>
        <div class="no-number no-toc" id="{$name}-constraints">
          <xsl:text>&#10;        </xsl:text>
          <h2 class="element-subhead">Additional constraints and admonitions</h2>
          <xsl:text>&#10;        </xsl:text>
          <ul class="assertions">
            <xsl:copy-of select="document(concat('../elements/',$name,'.html'))//h:*[@id='constraints']/node()"/>
            <xsl:if test="
              not($name='meta.name')
              ">
            <!-- * FIXME: the below doesn't handle expressions that -->
            <!-- * contain more than one element name -->
            <xsl:for-each
              select="exsl:node-set($assertions)/s:rule[child::s:context = $short-name]">
              <xsl:text>&#10;          </xsl:text>
              <xsl:for-each select="s:report|s:assert">
                <li>
                  <span>
                    <!-- * <xsl:if test="contains(.,'obsolete')"> -->
                      <!-- * <xsl:attribute -->
                        <!-- * name="class">obsolete</xsl:attribute> -->
                    <!-- * </xsl:if> -->
                    <xsl:for-each select="node()">
                      <xsl:choose>
                        <xsl:when test="local-name() = 'name'">
                          <xsl:value-of select="$short-name"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="."/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                  </span>
                </li>
              </xsl:for-each>
            </xsl:for-each>
            </xsl:if>
            <xsl:text>&#10;        </xsl:text>
          </ul>
          <xsl:text>&#10;      </xsl:text>
        </div>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- * ================================================================= -->
  <!-- * ================================================================= -->

  <!-- * ***************************************************************** -->
  <!-- * * GET CONTEXT for ASSERTIONS -->
  <!-- * ***************************************************************** -->
  <xsl:template name="get-context">
    <xsl:variable name="context-path">
      <xsl:choose>
        <xsl:when test="contains(.,'[')">
          <xsl:value-of
            select="normalize-space(substring-before(.,'['))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="context-raw">
      <xsl:choose>
        <xsl:when test="contains($context-path,'/')">
          <xsl:call-template name="substring-after-last">
            <xsl:with-param name="input" select="$context-path"/>
            <xsl:with-param name="substr">/</xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$context-path"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="context">
      <xsl:choose>
        <xsl:when test="contains($context-raw,'*')"/>
        <xsl:otherwise>
          <xsl:value-of
            select="substring-after($context-raw,'h:')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="not($context='')">
      <s:context>
        <xsl:value-of select="$context"/>
      </s:context>
    </xsl:if>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * HANDLE HYPERLINKS in ELEMENT CONTENT MODELS -->
  <!-- * ***************************************************************** -->
  <xsl:template match="h:a[@class='ref']">
    <xsl:param name="ref" select="substring-after(@href,'#')"/>
    <xsl:variable name="parent" select="../@id"/>
    <xsl:choose>
      <xsl:when test="$ref = 'normal-character-data'">
        <a href="#normal-character-data">normal character data</a>
        <span class="postfix optional">?</span>
      </xsl:when>
      <xsl:when test="$ref = 'colgroup.inner'">
        <!-- * special-case constraint of col element vs. span -->
        <!-- * attribute in colgroup content model requires some -->
        <!-- * additional finessing to make things clear -->
        <xsl:for-each select="//h:*[@id = $ref]/node()">
          <xsl:choose>
            <xsl:when test=".='span'">
              <a href="#colgroup.attrs.span" class="attribute">
                <xsl:text>span</xsl:text>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="garnish.as.needed"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$ref = 'option'">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:when test="$ref = 'script.attrs.embedded'">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:when test="$ref = 'script.attrs.imported'">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:when test="contains(.,'attrs')">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="$parent = 'meta.elem.encoding'">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="//h:*[@id = $ref]/node()">
          <xsl:call-template name="garnish.as.needed"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * GET ELEMENT SHORTDESC -->
  <!-- * ***************************************************************** -->
  <xsl:template name="get-shortdesc">
    <xsl:param name="element-name"/>
    <span class="shortdesc">
      <xsl:choose>
        <xsl:when test="$element-name = 'meta'">
          <xsl:text>metadata</xsl:text>
        </xsl:when>
        <xsl:when test="$element-name = 'input'">
          <xsl:text>input control</xsl:text>
        </xsl:when>
        <xsl:when test="$element-name = 'button'">
          <xsl:text>button</xsl:text>
        </xsl:when>
        <xsl:when test="$element-name = 'command'">
          <xsl:text>command</xsl:text>
        </xsl:when>
        <xsl:when test="document(concat('../elements/',$element-name,'.html'))//h:div[@id='shortdesc']/node()">
          <xsl:copy-of select="document(concat('../elements/',$element-name,'.html'))//h:div[@id='shortdesc']/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="element.shortdesc">
            <xsl:choose>
              <xsl:when test="$element-name = 'li'">
                <xsl:text>list item</xsl:text>
              </xsl:when>
              <xsl:when
                test="preceding-sibling::*[local-name() = 'documentation']
                and not(preceding-sibling::*[local-name() = 'documentation'][1] = '')">
                <xsl:value-of
                  select="preceding-sibling::*[local-name() = 'documentation'][1]"/>
              </xsl:when>
              <xsl:when
                test="ancestor::*[local-name() = 'define']/*[local-name() = 'documentation']
                and not(ancestor::*[local-name() = 'define']/*[local-name() = 'documentation'] = '')">
                <xsl:value-of
                  select="ancestor::*[local-name() = 'define']/*[local-name() = 'documentation'][1]"/>
              </xsl:when>
              <xsl:when test="$element-name = 'code'">
                <xsl:text>code fragment</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>@@ FIXME @@</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="contains($element.shortdesc,':')">
              <xsl:value-of
                select="translate(substring-before($element.shortdesc,':'),
                'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of
                select="translate($element.shortdesc,
                'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE OBSOLETE/CHANGED/NEW FLAGS -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make-markup-feature-flags">
    <xsl:param name="element-name"/>
    <xsl:choose>
      <xsl:when test="$element-name='button'"/>
      <xsl:when test="$element-name='input' or $element-name='meta'">
        <xsl:text> </xsl:text>
        <span class="changed-feature"
          title="The meaning, structure, or purpose of this markup feature has changed in HTML5."
          >CHANGED</span>
      </xsl:when>
      <xsl:when test="$element-name='command'">
        <xsl:text> </xsl:text>
        <span class="new-feature" title="This markup feature is newly added in HTML5.">NEW</span>
      </xsl:when>
      <xsl:when test="document(concat('../elements/',$element-name,'.html'))//*[@id='shortdesc'][@class[contains(.,'obsoleted')]]">
        <xsl:text> </xsl:text>
        <span class="obsoleted-feature"
          title="This markup feature has been obsoleted in HTML5."
          >OBSOLETE</span>
      </xsl:when>
      <xsl:when test="document(concat('../elements/',$element-name,'.html'))//*[@id='shortdesc'][@class[contains(.,'changed')]]">
        <xsl:text> </xsl:text>
        <span class="changed-feature"
          title="The meaning, structure, or purpose of this markup feature has changed in HTML5."
          >CHANGED</span>
      </xsl:when>
      <xsl:when test="document(concat('../elements/',$element-name,'.html'))//*[@id='shortdesc'][@class[contains(.,'new')]]">
        <xsl:text> </xsl:text>
        <span class="new-feature"
          title="This markup feature is newly added in HTML5."
          >NEW</span>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- * ***************************************************************** -->
  <!-- * * MAKE ELEMENT LINK TO HTML5 SPEC -->
  <!-- * ***************************************************************** -->
  <xsl:template name="make-element-spec-link">
    <xsl:param name="element-name"/>
    <xsl:param name="filename"/>
    <xsl:param name="target"/>
    <span class="spec-link">
      <a title="Read about the {$element-name} element in the HTML5 spec"
        href="{$filename}{$target}">&#9432;</a>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>
  <xsl:template name="get-spec-target">
    <xsl:param name="name"/>
    <xsl:choose>
      <xsl:when test="$name = 'input'">#the-input-element</xsl:when>
      <xsl:when test="$name = 'input.password'">#password-state-(type=password)</xsl:when>
      <xsl:when test="$name = 'input.checkbox'">#checkbox-state-(type=checkbox)</xsl:when>
      <xsl:when test="$name = 'input.hidden'">#hidden-state-(type=hidden)</xsl:when>
      <xsl:when test="$name = 'input.button'">#button-state-(type=button)</xsl:when>
      <xsl:when test="$name = 'input.date'">#date-state-(type=date)</xsl:when>
      <xsl:when test="$name = 'input.month'">#month-state-(type=month)</xsl:when>
      <xsl:when test="$name = 'input.time'">#time-state-(type=time)</xsl:when>
      <xsl:when test="$name = 'input.week'">#week-state-(type=week)</xsl:when>
      <xsl:when test="$name = 'input.number'">#number-state-(type=number)</xsl:when>
      <xsl:when test="$name = 'input.range'">#range-state-(type=range)</xsl:when>
      <xsl:when test="$name = 'input.url'">#url-state-(type=url)</xsl:when>
      <xsl:when test="$name = 'input.color'">#color-state-(type=color)</xsl:when>
      <xsl:when test="$name = 'input.text'">#text-(type=text)-state-and-search-state-(type=search)</xsl:when>
      <xsl:when test="$name = 'input.search'">#text-(type=text)-state-and-search-state-(type=search)</xsl:when>
      <xsl:when test="$name = 'input.radio'">#radio-button-state-(type=radio)</xsl:when>
      <xsl:when test="$name = 'input.submit'">#submit-button-state-(type=submit)</xsl:when>
      <xsl:when test="$name = 'input.reset'">#reset-button-state-(type=reset)</xsl:when>
      <xsl:when test="$name = 'input.tel'">#telephone-state-(type=tel)</xsl:when>
      <xsl:when test="$name = 'input.datetime'">#date-and-time-state-(type=datetime)</xsl:when>
      <xsl:when test="$name = 'input.datetime-local'">#local-date-and-time-state-(type=datetime-local)</xsl:when>
      <xsl:when test="$name = 'input.file'">#file-upload-state-(type=file)</xsl:when>
      <xsl:when test="$name = 'input.image'">#image-button-state-(type=image)</xsl:when>
      <xsl:when test="$name = 'input.email'">#e-mail-state-(type=email)</xsl:when>
      <xsl:when test="starts-with($name,'input.')">
        <xsl:value-of select="concat('#',substring-after($name,'input.'),'-state')"/>
      </xsl:when>
      <xsl:when test="$name = 'h1'">#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements</xsl:when>
      <xsl:when test="$name = 'h2'">#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements</xsl:when>
      <xsl:when test="$name = 'h3'">#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements</xsl:when>
      <xsl:when test="$name = 'h4'">#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements</xsl:when>
      <xsl:when test="$name = 'h5'">#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements</xsl:when>
      <xsl:when test="$name = 'h6'">#the-h1,-h2,-h3,-h4,-h5,-and-h6-elements</xsl:when>
      <xsl:when test="$name = 'sub'">#the-sub-and-sup-elements</xsl:when>
      <xsl:when test="$name = 'sup'">#the-sub-and-sup-elements</xsl:when>
      <xsl:when test="starts-with($name,'button')">#the-button-element</xsl:when>
      <xsl:when test="starts-with($name,'command')">#the-command-element</xsl:when>
      <xsl:when test="$name = 'meta.http-equiv.content-language'">#attr-meta-http-equiv-content-language</xsl:when>
      <xsl:when test="$name = 'meta.http-equiv.content-type'">#attr-meta-http-equiv-content-type</xsl:when>
      <xsl:when test="$name = 'meta.http-equiv.default-style'">#attr-meta-http-equiv-default-style</xsl:when>
      <xsl:when test="$name = 'meta.http-equiv.refresh'">#attr-meta-http-equiv-refresh</xsl:when>
      <xsl:when test="$name = 'meta.charset'">#attr-meta-charset</xsl:when>
      <xsl:when test="$name = 'meta.name'">#attr-meta-name</xsl:when>
      <!-- * <xsl:when test="$name = 'meta'">#meta</xsl:when> -->
      <!-- * <xsl:when test="$name = 'audio'">#audio</xsl:when> -->
      <!-- * <xsl:when test="$name = 'body'">#the-body-element-0</xsl:when> -->
      <!-- * <xsl:when test="$name = 'command'">#the-command</xsl:when> -->
      <!-- * <xsl:when test="$name = 'h1'">#the-h1-h2-h3-h4-h5-and-h6-elements</xsl:when> -->
      <!-- * <xsl:when test="$name = 'h2'">#the-h1-h2-h3-h4-h5-and-h6-elements</xsl:when> -->
      <!-- * <xsl:when test="$name = 'h3'">#the-h1-h2-h3-h4-h5-and-h6-elements</xsl:when> -->
      <!-- * <xsl:when test="$name = 'h4'">#the-h1-h2-h3-h4-h5-and-h6-elements</xsl:when> -->
      <!-- * <xsl:when test="$name = 'h5'">#the-h1-h2-h3-h4-h5-and-h6-elements</xsl:when> -->
      <!-- * <xsl:when test="$name = 'h6'">#the-h1-h2-h3-h4-h5-and-h6-elements</xsl:when> -->
      <!-- * <xsl:when test="$name = 'head'">#the-head-element-0</xsl:when> -->
      <!-- * <xsl:when test="$name = 'html'">#the-html-element-0</xsl:when> -->
      <!-- * <xsl:when test="$name = 'menu'">#menus</xsl:when> -->
      <!-- * <xsl:when test="$name = 'script'">#script</xsl:when> -->
      <!-- * <xsl:when test="$name = 'sub'">#the-sub-and-sup-elements</xsl:when> -->
      <!-- * <xsl:when test="$name = 'sup'">#the-sub-and-sup-elements</xsl:when> -->
      <!-- * <xsl:when test="$name = 'title'">#the-title-element-0</xsl:when> -->
      <!-- * <xsl:when test="$name = 'video'">#video</xsl:when> -->
      <xsl:otherwise>
        <xsl:value-of select="concat('#the-',$name,'-element')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="get-spec-filename">
    <xsl:param name="ref"/>
    <xsl:param name="base">http://dev.w3.org/html5/spec/</xsl:param>
    <!-- * <xsl:param name="base">http://developers.whatwg.org/</xsl:param> -->
    <xsl:param name="fragment-file">../fragment-links-full.html</xsl:param>
    <xsl:for-each select="document($fragment-file)">
      <xsl:choose>
        <xsl:when test="key('filename-map',$ref)">
          <xsl:value-of select="concat($base,key('filename-map',$ref)/*[2],'.html')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="document('../fragment-links-full.html')">
            <xsl:choose>
              <xsl:when test="key('filename-map',$ref)">
                <xsl:value-of select="concat('http://dev.w3.org/html5/spec/',key('filename-map',$ref)/*[2],'.html')"/>
              </xsl:when>
              <xsl:when test="contains($ref,'common.attrs.xmlspace')"/>
              <xsl:otherwise>
                <xsl:message>
                  <xsl:text>    ** SPEC TARGET NOT FOUND: </xsl:text>
                  <xsl:value-of select="$ref"/>
                </xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="get-idl">
    <xsl:param name="interface"/>
    <xsl:param name="lowercase-interface"
      select="translate($interface,
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
      'abcdefghijklmnopqrstuvwxyz')"/>
    <xsl:param name="base">../html5-spec/</xsl:param>
    <xsl:variable name="filename">
      <xsl:call-template name="get-spec-filename">
        <xsl:with-param name="ref" select="concat('#',$lowercase-interface)"/>
        <xsl:with-param name="base"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="target">
      <xsl:value-of select="concat($base,$filename)"/>
    </xsl:variable>
    <xsl:for-each select="document($target)">
      <xsl:choose>
        <xsl:when test="key('interface-name',$lowercase-interface)">
          <xsl:copy-of select="key('interface-name',$lowercase-interface)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>    ** INTERFACE NOT FOUND: <xsl:value-of select="$interface"/></xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="h:a[@class = 'html5-spec']" priority="100">
    <xsl:message> FOO FOO FOO </xsl:message>
    <xsl:variable name="filename">
      <xsl:call-template name="get-spec-filename">
        <xsl:with-param name="ref" select="@href"/>
      </xsl:call-template>
    </xsl:variable>
    <a href="{$filename}{@href}" class="html5-spec">
      <xsl:copy-of select="node()"/>
    </a>
  </xsl:template>

<!-- * ***************************************************************** -->
<!-- * * UTILITY TEMPLATES -->
<!-- * ***************************************************************** -->
  <xsl:template name="garnish.as.needed">
    <xsl:choose>
      <xsl:when test="@class='agroupof'">
      <span class='agroupof'>
        <xsl:for-each select="node()">
          <xsl:call-template name="garnish.as.needed"/>
        </xsl:for-each>
      </span>
      </xsl:when>
      <xsl:when test="@href = '#non-replaceable-character-data'">
        <a href="#non-replaceable-character-data">non-replaceable character data</a>
        <span class="postfix optional">?</span>
      </xsl:when>
      <xsl:when test="@href = '#replaceable-character-data'">
        <a href="#replaceable-character-data">replaceable character data</a>
        <span class="postfix optional">?</span>
      </xsl:when>
      <xsl:when test="@href = '#mli'">
        <a href="#li">li</a>
      </xsl:when>
      <xsl:when test="@href = '#oli'">
        <a href="#li">li</a>
      </xsl:when>
      <xsl:when test="@href = '#common.inner.flow'">
        <a href="#flow-content">flow content</a>
      </xsl:when>
      <xsl:when test="@href = '#common.inner.phrasing'">
        <a href="#phrasing-content">phrasing content</a>
      </xsl:when>
      <xsl:when test=". = 'common.inner.anything'">
        <xsl:text>(</xsl:text>
        <xsl:copy-of
          select="//h:*[@id = 'common.inner.anything']/node()"/>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test=". = 'common.inner.metadata'">
        <a href="#common.elem.metadata">metadata elements</a>
      </xsl:when>
      <xsl:when test="@href='#audio.attrs.src'">
        <a class="ref attribute" href="{@href}">src</a>
      </xsl:when>
      <xsl:when test="@href='#video.attrs.src'">
        <a class="ref attribute" href="{@href}">src</a>
      </xsl:when>
      <xsl:when test="@href='#common.elem.phrasing'">
        <a class="ref" href="{@href}">phrasing elements</a>
      </xsl:when>
      <xsl:when test="contains(@href,'.elem.')">
        <a class="ref" href="{substring-before(@href,'.elem.')}">
          <xsl:value-of select="substring-after(substring-before(@href,'.elem.'),'#')"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- * ================================================================= -->
  <xsl:template name="process.datatype.reference">
    <xsl:choose>
      <xsl:when test="normalize-space(.)='string'">
        <a href="#data-string">string</a>
      </xsl:when>
      <xsl:when test=".='tokens'">
        <a href="{@href}">set of space-separated tokens</a>
      </xsl:when>
      <xsl:when test=".='browsing-context-name'">
        <a href="{@href}">browsing-context name</a>
      </xsl:when>
      <xsl:when test=".='browsing-context-name-or-keyword'">
        <a href="{@href}">browsing-context name or keyword</a>
      </xsl:when>
      <xsl:when test=".='hash-name'">
        <a href="{@href}">hash-name reference</a>
      </xsl:when>
      <xsl:when test=".='mediaquery'">
        <a href="{@href}">media-query list</a>
      </xsl:when>
      <xsl:when test=".='langcode'">
        <a href="{@href}">language tag</a>
      </xsl:when>
      <xsl:when test=".='datetime'">
        <a href="{@href}">date and time</a>
      </xsl:when>
      <xsl:when test=".='datetime-local'">
        <a href="{@href}">local date and time</a>
      </xsl:when>
      <xsl:when test=".='date-or-time'">
        <a href="{@href}">date or time</a>
      </xsl:when>
      <xsl:when test=".='sandbox-allow-list'">
        <a href="{@href}">sandbox “allow” keywords list</a>
      </xsl:when>
      <xsl:when test=".='audio-states-list'">
        <a href="{@href}">list of audio states</a>
      </xsl:when>
      <xsl:when test=".='charset'">
        <a href="{@href}">character encoding name</a>
      </xsl:when>
      <xsl:when test=".='charsetlist'">
        <a href="{@href}">list of character-encoding names</a>
      </xsl:when>
      <xsl:when test=".='keylabellist'">
        <a href="{@href}">list of key labels</a>
      </xsl:when>
      <xsl:when test=".='dropzonevalue'">
        <a href="{@href}">dropzone value</a>
      </xsl:when>
      <xsl:when test=".='default-style'">
        <a href="{@href}">default-style name</a>
      </xsl:when>
      <xsl:when test=".='meta-charset'">
        <a href="{@href}">meta-charset string</a>
      </xsl:when>
      <xsl:when test=".='refresh'">
        <a href="{@href}">refresh value</a>
      </xsl:when>
      <xsl:when test=".='mimetype'">
        <a href="{@href}">MIME type</a>
      </xsl:when>
      <xsl:when test=".='mimetypelist'">
        <a href="{@href}">list of MIME types</a>
      </xsl:when>
      <xsl:when test=".='emailaddresslist'">
        <a href="{@href}">list of e-mail addresses</a>
      </xsl:when>
      <xsl:when test=".='emailaddress'">
        <a href="{@href}">e-mail address</a>
      </xsl:when>
      <xsl:when test=".='float'">
        <a href="{@href}">floating-point number</a>
      </xsl:when>
      <xsl:when test=".='float.non-negative'">
        <a href="{@href}">non-negative floating-point number</a>
      </xsl:when>
      <xsl:when test=".='integer.non-negative'">
        <a href="{@href}">non-negative integer</a>
      </xsl:when>
      <xsl:when test=".='integer.positive'">
        <a href="{@href}">positive integer</a>
      </xsl:when>
      <xsl:when test=".='float.positive'">
        <a href="{@href}">positive floating-point number</a>
      </xsl:when>
      <xsl:when test=".='uri.absolute'">
        <a href="{@href}">absolute URL potentially surrounded by spaces</a>
      </xsl:when>
      <xsl:when test=".='uri'">
        <a href="{@href}">URL potentially surrounded by spaces</a>
      </xsl:when>
      <xsl:when test=".='uri.non-empty'">
        <a href="{@href}">non-empty URL potentially surrounded by spaces</a>
      </xsl:when>
      <xsl:when test=".='uris'">
        <a href="{@href}">list of URIs</a>
      </xsl:when>
      <xsl:when test=".='id'">
        <a href="{@href}">ID</a>
      </xsl:when>
      <xsl:when test=".='idref'">
        <a href="{@href}">ID reference</a>
      </xsl:when>
      <xsl:when test=".='idrefs'">
        <a href="{@href}">list of ID references</a>
      </xsl:when>
      <xsl:when test=".='color'">
        <a href="{@href}">simple color</a>
      </xsl:when>
      <xsl:when test=".='nonemptystring'">
        <a href="{@href}">non-empty string</a>
      </xsl:when>
      <xsl:when test=".='stringwithoutlinebreaks'">
        <a href="{@href}">string without line breaks</a>
      </xsl:when>
      <xsl:when test=".='rectangle'">
        <a href="{@href}">rectangle coordinates</a>
      </xsl:when>
      <xsl:when test=".='circle'">
        <a href="{@href}">circle coordinates</a>
      </xsl:when>
      <xsl:when test=".='polygon'">
        <a href="{@href}">polygon coordinates</a>
      </xsl:when>
      <xsl:when test=".='normal-character-data'">
        <a href="#syntax-attribute-value">any value</a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="pack-common-attribute">
    <xsl:param name="name"/>
    <xsl:param name="prefix"/>
    <xsl:choose>
      <xsl:when test="@href">
        <xsl:variable name="target">
          <xsl:value-of select="concat($name,'.attrs.',substring-after(@href,$prefix))"/>
        </xsl:variable>
        <a class="{@href}"
          title="{$target}"
          href="#{$target}">
          <xsl:copy-of select="node()"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- * ================================================================= -->
  <xsl:template name="substring-after-last">
    <!-- * from XSLT Cookbook -->
    <xsl:param name="input"/>
    <xsl:param name="substr"/>
    <xsl:variable name="temp" select="substring-after($input,$substr)"/>
    <xsl:choose>
      <xsl:when test="$substr and contains($temp,$substr)">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="input" select="$temp"/>
          <xsl:with-param name="substr" select="$substr"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$temp"/>
      </xsl:otherwise>
    </xsl:choose>
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
  <!-- * ================================================================= -->
  <!-- * <xsl:message> -->
    <!-- * <xsl:for-each select="@*"> -->
      <!-- * <xsl:value-of select="name()"/> -->
      <!-- * <xsl:text>: </xsl:text> -->
      <!-- * <xsl:value-of select="."/> -->
      <!-- * <xsl:text>&#160;</xsl:text> -->
      <!-- * </xsl:for-each> -->
    <!-- * <xsl:value-of select="."/> -->
    <!-- * <xsl:text>&#160;</xsl:text> -->
    <!-- * </xsl:message> -->
  <xsl:template match="h:span[@class='postfix intermixed']">
    <xsl:copy-of select="."/>
  </xsl:template>
  <xsl:template match="node()[normalize-space(.)='empty']">
    <span>empty (<a href="#void-element">void element</a>)</span>
  </xsl:template>
</xsl:stylesheet>
