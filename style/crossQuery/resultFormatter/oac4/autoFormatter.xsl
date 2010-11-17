<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session"
	xmlns:editURL="http://cdlib.org/xtf/editURL" 
	xmlns:tmpl="xslt://template">
  <xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="text/xml"/>
<xsl:param name="query"/>
<xsl:param name="http.URL"/>

<xsl:template match="/">
        <xsl:comment>
	url: <xsl:value-of select="$http.URL"/>
        xslt: <xsl:value-of select="static-base-uri()"/>
        </xsl:comment>
	<xsl:choose>
	<xsl:when test="/crossQueryResult/docHit">
		<titles><xsl:apply-templates select="/crossQueryResult/docHit/meta"/></titles>
	</xsl:when>
	<xsl:otherwise>
		<groups c="{/crossQueryResult/facet/@totalGroups}"><xsl:apply-templates select="/crossQueryResult/facet/group"/></groups>
	</xsl:otherwise>
	</xsl:choose>
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

  <xsl:template match="group">
	<g>
	<xsl:attribute name="c" select="@totalDocs"/>
	<xsl:value-of select="@value"/>
	</g>
  </xsl:template>


</xsl:stylesheet>
