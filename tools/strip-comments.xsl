<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
  version='1.0'>
  <xsl:output method="xml" indent="no"/>
  <!-- * ***************************************************************** -->
  <!-- * strip-comments.xsl - strip out comments and annotations -->
  <!-- * ***************************************************************** -->
  <xsl:template match="comment()|a:documentation"/>
  <!-- * for anything else, just do an identity transform -->
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>

