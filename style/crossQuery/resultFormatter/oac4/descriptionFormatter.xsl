<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session"
	xmlns:editURL="http://cdlib.org/xtf/editURL" 
	xmlns:tmpl="xslt://template">
  <xsl:output method="text" indent="yes" encoding="UTF-8" media-type="text/plain"/>
<xsl:param name="query"/>
<xsl:param name="http.URL"/>

<xsl:template match="/">
<xsl:value-of select="/crossQueryResult/docHit/meta/description[1]"/>
</xsl:template>

  <!-- default match identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="meta">
	<meta>
		<xsl:apply-templates select="title"/>
	</meta>
  </xsl:template>


</xsl:stylesheet>
