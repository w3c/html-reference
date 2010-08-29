<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'
  xmlns="http://www.w3.org/1999/xhtml"
  >
  <xsl:output method="xml"/>
  <xsl:template match="/">
    <table>
      <xsl:copy-of
        select="(//*[local-name()='table'])[last()]/node()"/>
    </table>
  </xsl:template>
</xsl:stylesheet>

