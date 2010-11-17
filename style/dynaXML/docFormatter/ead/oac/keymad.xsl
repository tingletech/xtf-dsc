<!-- copyright notice at end of file -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xtf="http://cdlib.org/xtf"
  version="2.0"
>
<!-- copyright notice at bottom of file --> 

<xsl:import href="xmlverbatim.xsl"/>
<xsl:import href="search.xsl"/>
<xsl:import href="parameter.xsl"/>
<xsl:include href="table.html.xsl"/>
<xsl:output method="html" media-type="text/html" />
<xsl:include href="http://voro.cdlib.org:8081/xslt/institution-ark2url.xsl"/>


<xsl:param name="docId"/>
<xsl:param name="doc.view"></xsl:param>
<xsl:param name="debug"/>
<xsl:param name="chunk.id"><xsl:value-of select="$page/ead/archdesc/*[@id][1]/@id"/></xsl:param>
<xsl:param name="item.id"><xsl:value-of 
	select="$page/ead/archdesc//*/@id[../*/dao or ../*/daogrp][1]"/></xsl:param>
<xsl:param name="query"/>
<xsl:param name="source"/>

<xsl:variable name="page" select="/"/>
<xsl:variable name="layout" select="document('template.xhtml.html')"/>

<xsl:key name="hit-num-dynamic" match="xtf:hit" use="@hitNum"/>
<xsl:key name="hit-rank-dynamic" match="xtf:hit" use="@rank"/>
<xsl:key name="item-id" match="*[@id]" use="@id"/> 

<xsl:template match="/">
<xsl:copy-of select="key('item-id','brk3041')"/>
</xsl:template>
</xsl:stylesheet>
