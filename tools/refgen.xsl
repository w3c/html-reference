<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:h='http://www.w3.org/1999/xhtml'
                xmlns='http://www.w3.org/1999/xhtml'
                xmlns:date="http://exslt.org/dates-and-times"
                exclude-result-prefixes='h date'
                version='1.0' id='xslt'>
  <xsl:output method='xml' encoding='us-ascii'
    doctype-public='html'
    doctype-system='about:legacy-compat'
    media-type='text/html; charset=us-ascii'
    indent="yes"/>
  <xsl:template match="/">
    <html>
      <xsl:text>&#10;</xsl:text>
      <head>
        <xsl:text>&#10;</xsl:text>
        <title>HTML element reference</title>
        <xsl:text>&#10;</xsl:text>
      </head>
      <xsl:text>&#10;</xsl:text>
      <body>
        <xsl:for-each select="//h:section[child::h:h2[@class='element-head']]">
          <xsl:text>&#10;</xsl:text>
          <h4 id="the-{@id}-element">The <xsl:value-of select="@id"/> element</h4>
          <xsl:text>&#10;</xsl:text>
          <dl class="element">
            <xsl:text>&#10;</xsl:text>
            <dt>Contexts in which this element may be used:</dt>
            <xsl:text>&#10;</xsl:text>
            <xsl:for-each select="descendant::h:li[@class='context-mdl']">
              <dd><xsl:copy-of select="node()"/></dd>
            </xsl:for-each>
            <xsl:text>&#10;</xsl:text>
            <dt>Content model:</dt>
            <xsl:text>&#10;</xsl:text>
            <xsl:for-each select="descendant::h:dt[@class='content-model']">
              <dd><xsl:copy-of select="node()"/><xsl:copy-of select="following-sibling::h:dd/node()"/></dd>
              <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
            <xsl:for-each select="descendant::h:p[@class='elem-mdl']">
              <dd><xsl:copy-of select="node()"/></dd>
              <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
          </dl>
          <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>
      </body>
      <xsl:text>&#10;</xsl:text>
    </html>
  </xsl:template>
</xsl:stylesheet>
