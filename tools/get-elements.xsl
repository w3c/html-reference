<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:h="http://www.w3.org/1999/xhtml"
  extension-element-prefixes="exsl"
  version='1.0'>
  <xsl:output method="xml" indent="yes"/>
  <xsl:template match="/" >
    <div xmlns="http://www.w3.org/1999/xhtml">
      <xsl:for-each
        select="//h4[following-sibling::*[1][self::dl][@class='element']]">
        <xsl:sort select="normalize-space(substring-after(.,' '))"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:variable name="title">
          <xsl:value-of select="normalize-space(substring-after(.,' '))"/>
        </xsl:variable>
        <xsl:variable name="element">
          <xsl:value-of select="substring-before(substring-after($title,' '),' ')"/>
        </xsl:variable>
        <div id="{$element}">
          <xsl:text>&#10;</xsl:text>
          <h4>
            <xsl:value-of select="$title"/>
          </h4>
          <xsl:text>&#10;</xsl:text>
          <div class="longdesc">
            <xsl:text>&#10;</xsl:text>
            <xsl:choose>
              <xsl:when test="contains($title,' dl ')">
                <p>The <a href="#dl" class="element">dl</a> element
                  introduces an association list consisting of
                  zero or more name-value groups (a description
                  list).</p>
              </xsl:when>
              <xsl:when test="contains($title,' h1, ')">
                <p>The <a href="#h1" class="element">h1</a> through
                  <a href="#h6" class="element">h6</a> elements are
                  headings for the sections with which they are
                  associated.</p>
              </xsl:when>
              <xsl:when test="contains($title,' sub ')">
                <p>The <a href="#sub" class="element">sub</a> element
                  represents a subscript.</p>
                <xsl:text>&#10;</xsl:text>
                <p>The <a href="#sup" class="element">sup</a> element
                  represents a superscript.</p>
              </xsl:when>
              <xsl:when test="contains($title,' a ')">
                <xsl:for-each select="(following-sibling::p[not(@class='big-issue')][1]
                  |following-sibling::p[not(@class='big-issue')][2])">
                  <xsl:call-template name="copy.longdesc"/>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="following-sibling::p[not(@class='big-issue')][1]">
                  <xsl:call-template name="copy.longdesc"/>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>&#10;</xsl:text>
          </div>
          <xsl:text>&#10;</xsl:text>
          <xsl:if test="//dfn[starts-with(@title,'attr-')]
            [substring-before(substring-after(@title,'attr-'),'-')=$element]
            [not(contains(substring-after(substring-after(@title,'attr-'),'-'),'-'))]
            or $element='a'
            or $element='audio'
            or $element='del'
            or $element='ins'
            or $element='embed'
            or $element='iframe'
            or $element='video'
            or $element='meta'
            or $element='img'
            or $element='object'
            or $element='area'
            or $element='td'
            or $element='th'
            ">
            <div class="attributes">
              <xsl:text>&#10;</xsl:text>
              <xsl:choose>
                <xsl:when test="$element='a'">
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-hyperlink')]
                    [not(contains(substring-after(substring-after(@title,'attr-'),'-'),'-'))]
                    [not(contains(@title,'usemap'))]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="$element='audio'
                  or $element='video'
                  ">
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-')]
                    [substring-before(substring-after(@title,'attr-'),'-')=$element]
                    [not(contains(substring-after(substring-after(@title,'attr-'),'-'),'-'))]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-media')]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="media.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                  <xsl:if test="$element='video'">
                    <xsl:for-each
                      select="//dfn[starts-with(@title,'attr-dim-')]
                      ">
                      <xsl:text>&#10;</xsl:text>
                      <dl>
                        <xsl:text>&#10;</xsl:text>
                        <dt id="{$element}.attrs.{.}">
                          <xsl:value-of select="."/>
                        </dt>
                        <xsl:text>&#10;</xsl:text>
                        <dd>
                          <xsl:copy-of select="ancestor::p/node()"/>
                        </dd>
                        <xsl:text>&#10;</xsl:text>
                      </dl>
                    </xsl:for-each>
                  </xsl:if>
                </xsl:when>
                <xsl:when test="$element='del' or $element='ins'">
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-mod-')]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="$element='embed'
                  or $element='iframe'
                  ">
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-')]
                    [substring-before(substring-after(@title,'attr-'),'-')=$element]
                    [not(contains(substring-after(substring-after(@title,'attr-'),'-'),'-'))]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-dim-')]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="$element='meta'
                  ">
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-')]
                    [substring-before(substring-after(@title,'attr-'),'-')=$element]
                    [not(contains(substring-after(substring-after(@title,'attr-'),'-'),'-'))]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                  <xsl:for-each
                    select="//dfn[@title='attr-meta-http-equiv']
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="$element='img'
                  or $element='object'
                  ">
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-')]
                    [substring-before(substring-after(@title,'attr-'),'-')=$element]
                    [not(contains(substring-after(substring-after(@title,'attr-'),'-'),'-'))]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-hyperlink-usemap')]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-dim-')]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="$element='area'">
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-hyperlink')]
                    [not(contains(substring-after(substring-after(@title,'attr-'),'-'),'-'))]
                    [not(contains(@title,'usemap'))]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-')]
                    [substring-before(substring-after(@title,'attr-'),'-')=$element]
                    [not(contains(substring-after(substring-after(@title,'attr-'),'-'),'-'))]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="$element='td'
                  or $element='th'
                  ">
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-')]
                    [substring-before(substring-after(@title,'attr-'),'-')=$element]
                    [not(contains(substring-after(substring-after(@title,'attr-'),'-'),'-'))]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-tdth-')]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each
                    select="//dfn[starts-with(@title,'attr-')]
                    [substring-before(substring-after(@title,'attr-'),'-')=$element]
                    [not(contains(substring-after(substring-after(@title,'attr-'),'-'),'-'))]
                    ">
                    <xsl:text>&#10;</xsl:text>
                    <dl>
                      <xsl:text>&#10;</xsl:text>
                      <dt id="{$element}.attrs.{.}">
                        <xsl:value-of select="."/>
                      </dt>
                      <xsl:text>&#10;</xsl:text>
                      <dd>
                        <xsl:copy-of select="ancestor::p/node()"/>
                      </dd>
                      <xsl:text>&#10;</xsl:text>
                    </dl>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text>&#10;</xsl:text>
            </div>
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
          <xsl:variable name="next-h4">
            <xsl:value-of select="following-sibling::h4[1]/@id"/>
          </xsl:variable>
          <!-- * <xsl:if test="following-sibling::*[@class='example'][following-sibling::h4[1][@id=$next-h4]]"> -->
            <!-- * <xsl:message> -->
              <!-- * <xsl:value-of select="concat('examples/',$element,'.xml')"/> -->
            <!-- * </xsl:message> -->
            <!-- * <exsl:document -->
              <!-- * href="{concat('examples/',$element,'.xml')}"> -->
              <!-- * <div class="examples" -->
                <!-- * xmlns="http://www.w3.org/1999/xhtml" -->
                <!-- * > -->
              <!-- * <xsl:text>&#10;</xsl:text> -->
              <!-- * <xsl:for-each select="following-sibling::*[@class='example'][following-sibling::h4[1][@id=$next-h4]]"> -->
                <!-- * <xsl:copy-of select="."/> -->
                <!-- * <xsl:text>&#10;</xsl:text> -->
              <!-- * </xsl:for-each> -->
              <!-- * <xsl:text>&#10;</xsl:text> -->
            <!-- * </div> -->
          <!-- * </exsl:document> -->
          <!-- * </xsl:if> -->
          <!-- * <xsl:text>&#10;</xsl:text> -->
        </div>
      </xsl:for-each>
      <xsl:text>&#10;</xsl:text>
    </div>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="copy.longdesc">
    <xsl:text>&#10;</xsl:text>
    <p xmlns="http://www.w3.org/1999/xhtml">
      <xsl:for-each select="node()">
        <xsl:choose>
          <xsl:when test="name()=''">
            <xsl:copy-of select="."/>
          </xsl:when>
          <xsl:when test="self::code and @title">
            <code>
              <xsl:value-of select="."/>
            </code>
          </xsl:when>
          <xsl:when test="self::code">
            <code>
              <a href="#{.}" class="element">
                <xsl:value-of select="."/>
              </a>
            </code>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="not(starts-with(.,'['))">
              <xsl:value-of select="."/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </p>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
</xsl:stylesheet>

