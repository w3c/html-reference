<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
  <xsl:output method="xml"/>
  <xsl:variable name="next-h3">
    <xsl:value-of select="//h3[preceding-sibling::h3[substring-after(.,' ')='Writing HTML documents']]/@id"/>
  </xsl:variable>
  <xsl:template match="/" >
    <xsl:for-each select="//h3[substring-after(.,' ')='Writing HTML documents']">
      <xsl:variable name="first-h4">
        <xsl:value-of select="following-sibling::h4[1]/@id"/>
      </xsl:variable>

      <div xmlns="http://www.w3.org/1999/xhtml">
        <xsl:apply-templates
          select="
          following-sibling::*[not(position()=1)][following-sibling::h4[@id=$first-h4]]
          |following-sibling::h4[following-sibling::h3[1][@id=$next-h3]]"/>
      </div>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="h4">
    <xsl:variable name="next-h4">
      <xsl:value-of select="following-sibling::h4[1]/@id"/>
    </xsl:variable>
    <xsl:variable name="id">
      <xsl:value-of select="@id"/>
    </xsl:variable>
    <xsl:text>&#10;</xsl:text>
    <section id="{@id}">
      <xsl:text>&#10;</xsl:text>
      <h2>
        <xsl:copy-of select="@*[not(name()='id')]"/>
        <xsl:apply-templates/>
      </h2>
      <xsl:text>&#10;</xsl:text>
      <xsl:for-each select="following-sibling::*[following-sibling::h4[1][@id=$next-h4]]
        [not(@id=$next-h3) and not(preceding-sibling::*[@id=$next-h3])]">
        <xsl:choose>
          <xsl:when test="self::h5">
            <xsl:variable name="next-head">
              <xsl:value-of select="(following-sibling::h4|following-sibling::h5)[1]/@id"/>
            </xsl:variable>
            <xsl:text>&#10;</xsl:text>
            <section id="{@id}" class="no-toc">
              <xsl:text>&#10;</xsl:text>
              <h2>
                <xsl:copy-of select="@*[not(name()='id')]"/>
                <xsl:apply-templates/>
              </h2>
              <xsl:text>&#10;</xsl:text>
              <xsl:for-each
                select="following-sibling::*[preceding-sibling::h4[@id=$id]]
                [following-sibling::*[@id=$next-head]]">
                <xsl:apply-templates select="."/>
              </xsl:for-each>
              <xsl:text>&#10;</xsl:text>
            </section>
            <xsl:text>&#10;</xsl:text>
          </xsl:when>
          <xsl:when test="preceding-sibling::*[name()='h4' or name()='h5'][1][name()='h5']"/>
          <xsl:otherwise>
            <xsl:apply-templates select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:variable name="section-title">
        <xsl:value-of select="."/>
      </xsl:variable>
      <xsl:if test="substring-after($section-title,' ')='Text'">
        <xsl:text>&#10;</xsl:text>
        <section id="space-chars" class="no-toc">
          <xsl:text>&#10;</xsl:text>
          <h2>Space characters</h2>
          <xsl:text>&#10;</xsl:text>
          <xsl:copy-of select="//p[child::dfn[@id='space']]"/>
          <xsl:text>&#10;</xsl:text>
        </section>
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
    </section>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="span[@class='secno']"/>
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="a[@href='#html-elements']">
    <a href="#elements">
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  <xsl:template
    match="a[normalize-space(.)='named character references']">
    <a href="#named">
      <xsl:apply-templates/>
    </a>
  </xsl:template>
</xsl:stylesheet>
