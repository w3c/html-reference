<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
  version='1.0'>
  <xsl:output method="xml" indent="no"/>
  <!-- * ***************************************************************** -->
  <!-- * combine.xsl - consolidate RNG define@combine instances -->
  <!-- * ***************************************************************** -->
  <xsl:key name="names" match="rng:define[@name]" use="@name"/>
  <xsl:template match="rng:define[@name]">
    <xsl:variable name="name" select="@name"/>
    <xsl:choose>
      <xsl:when test="not(preceding::rng:define[@name = $name])">
        <xsl:copy>
        <xsl:call-template name="combine">
          <xsl:with-param name="name" select="$name"/>
        </xsl:call-template>
      </xsl:copy>
      </xsl:when>
      <xsl:when test="preceding::rng:define[@name = $name]"/>
      <xsl:otherwise>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="combine">
    <xsl:param name="name"/>
    <xsl:choose>
      <xsl:when test="key('names',$name)[@combine = 'choice']">
        <xsl:apply-templates select="@*"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each select="a:documentation">
          <xsl:apply-templates select="."/>
          <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <rng:choice>
          <xsl:text>&#10;</xsl:text>
          <xsl:apply-templates select="*[not(local-name() = 'documentation') and not(local-name() = 'notAllowed')]"/>
          <xsl:text>&#10;</xsl:text>
          <xsl:for-each select="key('names',$name)[preceding::rng:define[@name = $name]]">
            <xsl:apply-templates/>
          </xsl:for-each>
        </rng:choice>
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="key('names',$name)[@combine = 'interleave']">
        <xsl:apply-templates select="@*"/>
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each select="a:documentation">
          <xsl:apply-templates select="."/>
          <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>
        <rng:interleave>
          <xsl:text>&#10;</xsl:text>
          <xsl:apply-templates select="*[not(local-name() = 'documentation') and not(local-name() = 'notAllowed')]"/>
          <xsl:text>&#10;</xsl:text>
          <xsl:for-each select="key('names',$name)[preceding::rng:define[@name = $name]]">
            <xsl:apply-templates/>
          </xsl:for-each>
        </rng:interleave>
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="comment()[contains(.,'REVISIT') or contains(.,'FIXME')]"/>
  <xsl:template match="rng:optional[count(*)=1][child::rng:choice[count(*)=1][child::rng:notAllowed]]"/>
  <xsl:template match="rng:optional[count(*)=1][child::rng:notAllowed]"/>
  <!-- * for anything else, just do an identity transform -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
