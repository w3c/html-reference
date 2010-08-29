<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version='1.0'>
  <xsl:output method="xml" indent="no"/>
  <xsl:template match="/" >
    <div xmlns="http://www.w3.org/1999/xhtml">
      <xsl:for-each
        select="//*[child::dfn[starts-with(@title,'attr-')]]">
        <xsl:sort select="dfn[starts-with(@title,'attr-')][1]"/>
        <xsl:text>&#10;</xsl:text>
        <div>
        <h4>
          <xsl:value-of select="dfn[starts-with(@title,'attr-')][1]"/>
          <xsl:text> (</xsl:text>
          <xsl:variable name="element">
            <xsl:choose>
              <xsl:when test="
                not(contains(substring-after(dfn
                [starts-with(@title,'attr-')][1]/@title,
                'attr-'),'-'))">
                <xsl:text>common</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="
                  substring-before(
                  substring-after(dfn
                  [starts-with(@title,'attr-')][1]/@title,
                  'attr-'),
                  '-')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:value-of select="$element"/>
          <xsl:text>)</xsl:text>
        </h4>
        <xsl:text>&#10;</xsl:text>
        <div class="attrdesc">
          <xsl:text>&#10;</xsl:text>
          <xsl:choose>
            <xsl:when test="
              not(contains(substring-after(dfn
              [starts-with(@title,'attr-')][1]/@title,
              'attr-'),'-'))">
              <xsl:copy-of select="following-sibling::p[1]"/>
              <xsl:copy-of select="following-sibling::p[2]"/>
              <xsl:copy-of select="following-sibling::p[3]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="node()"/>
            </xsl:otherwise>
          </xsl:choose>
        </div>
        <xsl:text>&#10;</xsl:text>
      </div>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>
  </div>
</xsl:template>
<xsl:template name="copy.longdesc">
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
          <span class="element">
            <xsl:value-of select="."/>
          </span>
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

