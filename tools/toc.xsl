<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:h='http://www.w3.org/1999/xhtml'
                xmlns='http://www.w3.org/1999/xhtml'
                version='1.0' id='xslt'>
  <xsl:template name='toc'>
    <xsl:param name="unexpanded" select="0"/>
    <xsl:for-each select='key("elements",$sectionsID)'>
      <xsl:call-template name='toc1'>
        <xsl:with-param name="unexpanded" select="$unexpanded"/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select='key("elements",$appendicesID)'>
      <xsl:call-template name='toc1'>
        <xsl:with-param name="unexpanded" select="$unexpanded"/>
        <xsl:with-param name='alpha' select='true()'/>
      </xsl:call-template>
    </xsl:for-each>
    <ul class="index-toc">
      <li>
        <xsl:if test="$unexpanded=0">
          <xsl:attribute name="id">index-toc</xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$chunk = 0">
            <a href="#index-of-terms">Index of terms</a>
          </xsl:when>
          <xsl:otherwise>
            <a href="index-of-terms.html">Index of terms</a>
          </xsl:otherwise>
        </xsl:choose>
      </li>
    </ul>
  </xsl:template>
  <xsl:template name='toc1'>
    <xsl:param name='prefix'/>
    <xsl:param name='alpha'/>
    <xsl:param name="unexpanded" select="0"/>
    <xsl:param name='main-toc'>1</xsl:param>
    <xsl:variable name='subsections' select='h:section[not(contains(@class,"no-toc"))]'/>
    <xsl:if test='$subsections'>
      <ul>
      <xsl:text>&#10;</xsl:text>
        <xsl:for-each select='h:section[not(contains(@class,"no-toc"))]'>
          <xsl:variable name='number'>
            <xsl:value-of select='$prefix'/>
            <xsl:if test='$prefix'>
              <xsl:text>.</xsl:text>
              <!-- * <xsl:if test='10 > position()'> -->
                <!-- * <xsl:text>0</xsl:text> -->
              <!-- * </xsl:if> -->
            </xsl:if>
            <xsl:choose>
              <xsl:when test='$alpha'><xsl:number value='position()' format='A'/></xsl:when>
              <xsl:otherwise><xsl:value-of select='position()'/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name='frag'>
            <xsl:choose>
              <xsl:when test='@id'><xsl:value-of select='@id'/></xsl:when>
              <xsl:otherwise><xsl:value-of select='generate-id(.)'/></xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name='section-id'>
            <xsl:choose>
              <xsl:when test='$chunk=0'/>
              <xsl:otherwise>
                <xsl:value-of select="
                  key('elements',$frag)[ancestor-or-self::h:section[@id='elements']]/@id
                  |key('elements',$frag)/ancestor-or-self::h:section[count(ancestor::h:section)=0 and not(@id='elements')]/@id
                  "/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name='filename'>
            <xsl:choose>
              <xsl:when test='$chunk=0'/>
              <xsl:otherwise>
                <xsl:value-of select="concat($section-id,'.html')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <li>
            <xsl:if test="$unexpanded=0 and $main-toc=1">
              <xsl:attribute name="id">
                <xsl:value-of select="concat($frag,'-toc')"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:for-each select='(h:h2|h:h3|h:h4|h:h5|h:h6)/node()
              [@class="spec-link"]
              '>
              <xsl:copy-of select='.'/>
            </xsl:for-each>
            <xsl:text> </xsl:text>
            <a href='{$filename}#{$frag}'>
              <span class="toc-section-number">
                <xsl:if test="not(contains(@class,'no-number'))">
                  <xsl:value-of select='$number'/>
                  <xsl:text>. </xsl:text>
                </xsl:if>
              </span>
              <span class="toc-section-name">
                <xsl:if test="not(contains(@class,'no-number'))">
                  <xsl:text>&#xa0;</xsl:text>
                </xsl:if>
                <xsl:for-each select='(h:h2|h:h3|h:h4|h:h5|h:h6)/node()
                  [not(normalize-space(.)="")]
                  [not(contains(@class,"obsoleted-feature"))]
                  [not(contains(@class,"changed-feature"))]
                  [not(contains(@class,"new-feature"))]
                  [not(@class="spec-link")]
                  '>
                  <xsl:copy-of select='.'/>
                </xsl:for-each>
              </span>
            </a>
            <xsl:if test='(h:h2|h:h3|h:h4|h:h5|h:h6)/node()[contains(@class,"obsoleted-feature")]'>
              <xsl:text> </xsl:text>
              <span class="obsoleted-feature"
                title="This markup feature has been obsoleted in HTML5."
                >OBSOLETE</span>
            </xsl:if>
            <xsl:if test='(h:h2|h:h3|h:h4|h:h5|h:h6)/node()[contains(@class,"changed-feature")]'>
              <xsl:text> </xsl:text>
              <span class="changed-feature"
                title="The meaning, structure, or purpose of this markup feature has changed in HTML5."
                >CHANGED</span>
            </xsl:if>
            <xsl:if test='(h:h2|h:h3|h:h4|h:h5|h:h6)/node()[contains(@class,"new-feature")]'>
              <xsl:text> </xsl:text>
              <span class="new-feature"
                title="This markup feature is newly added in HTML5."
                >NEW</span>
            </xsl:if>
            <xsl:text>&#10;</xsl:text>
            <xsl:if test="$unexpanded=0">
              <xsl:call-template name='toc1'>
                <xsl:with-param name='prefix' select='$number'/>
                <xsl:with-param name='unexpanded' select='$unexpanded'/>
              </xsl:call-template>
            </xsl:if>
          </li>
          <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
      </ul>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
