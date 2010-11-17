<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:editURL="http://cdlib.org/xtf/editURL"
	exclude-result-prefixes="#all"
	xmlns:tmpl="xslt://template">

<!-- DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd" -->
<xsl:import href="../common/editURL.xsl"/>
<xsl:include href="../../../common/SSI.xsl"/>
<xsl:include href="azBrowseResults.xsl"/>
<xsl:include href="autocomplete-js.xsl"/>
  <xsl:output method="xhtml"
    indent="yes"
              encoding="UTF-8" media-type="text/html; charset=UTF-8"
        omit-xml-declaration="yes"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

<!--	xmlns:editURL="http://cdlib.org/xtf/editURL" -->
<xsl:param name="http.URL"/>
<xsl:param name="queryString" select="editURL:remove(editURL:set(substring-after($http.URL,'?'),'style','oac4'),'page')"/>
<xsl:param name="query"/>
<xsl:param name="page" select="1"/>
<xsl:param name="sort"/>
<xsl:param name="style"/>
<xsl:param name="keyword"/>
<xsl:param name="descriptions"/>
<xsl:param name="titlesAZ"/>
<xsl:param name="Institution"/>
<xsl:param name="group" select="'Collections'"/>
<xsl:variable name="beforeGroup" select="if (substring-before($group,'::')) 
		then substring-before($group,'::') else $group"/>
<xsl:variable name="afterGroup" select="if (substring-before($group,'::')) 
		then substring-after($group,'::') else $group"/>

<xsl:variable name="layoutFile">
        <xsl:value-of select="$layoutBase"/>
        <xsl:text>/layouts/browse.xhtml</xsl:text>
</xsl:variable>

<xsl:variable name="layout" select="document($layoutFile)"/>

<xsl:variable name="pageXML" select="/"/>

<xsl:variable name="queryURL">
	<xsl:text>/search?style=</xsl:text><xsl:value-of select="$style"/>
	<xsl:if test="$query"><xsl:text>;query=</xsl:text><xsl:value-of select="$query"/></xsl:if>
	<xsl:if test="$keyword"><xsl:text>;keyword=</xsl:text><xsl:value-of select="$keyword"/></xsl:if>
	<xsl:if test="$developer != 'local'"><xsl:text>;developer=</xsl:text><xsl:value-of select="$developer"/></xsl:if>
	<xsl:if test="$group"><xsl:text>;group=</xsl:text><xsl:value-of select="$group"/></xsl:if>
</xsl:variable>

<xsl:template match="*[@tmpl:insert='Tabs']">
<xsl:for-each select="for $n in ('0-9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q', 'R','S','T','U','V','W','X','Y','Z') return $n">
	<xsl:choose>
		<xsl:when test=" . = $titlesAZ">
			<xsl:value-of select="."/>
		</xsl:when>
		<xsl:otherwise>
			<a href="/titles/{lower-case(.)}.html">
				<xsl:value-of select="."/>
			</a>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text> </xsl:text>
</xsl:for-each>
</xsl:template>

<xsl:template match="/">
	<xsl:choose>
		<xsl:when test="$style='oac4L'">
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="($layout)//*[local-name()='html']"/>
		</xsl:otherwise>
	</xsl:choose>
        <xsl:comment>
        url: <xsl:value-of select="$http.URL"/>
        xslt: <xsl:value-of select="static-base-uri()"/>
        </xsl:comment>
</xsl:template>

  <!-- default match identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>


<!-- search results (template call) -->
<xsl:template match="tmpl:insert[@name='main-list']">

<div class="institutions-container-heading">
	<div class="institutions-left">&#160;</div>
	<div class="institutions-heading">
		<xsl:value-of select="if ($titlesAZ = '0') then '0-9' else (upper-case($titlesAZ))"/>
	</div>
</div>
	<xsl:choose>
		<xsl:when test="$descriptions='show'">
		<xsl:apply-templates select="$pageXML/crossQueryResult/facet//docHit" mode="azBrowseResultsDescriptions"/>
		</xsl:when>
		<xsl:otherwise>
		<xsl:apply-templates select="$pageXML/crossQueryResult/facet//docHit" mode="azBrowseResults"/>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template match="tmpl:Head">
</xsl:template>

<xsl:template match="*[@tmpl:insert='browse-row1']"/>

<xsl:template match="*[@tmpl:insert='show-collection-descriptions']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
	<xsl:apply-templates mode="show-collection-descriptions"/>
        </xsl:element>
</xsl:template>

<xsl:template match="a" mode="show-collection-descriptions">
	<xsl:variable name="filename">
		<xsl:choose>
			<xsl:when test="$titlesAZ='a'">
				<xsl:text>/titles/a.html</xsl:text>
			</xsl:when>
			<xsl:when test="$titlesAZ='0'">
				<xsl:text>/titles/</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>/titles/</xsl:text>
				<xsl:copy-of select="$titlesAZ"/>
				<xsl:text>.html</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:choose>
	<xsl:when test="$descriptions='show'">
		<a href="{$filename}">Hide collection descriptions</a>
	</xsl:when>
	<xsl:otherwise>
		<a href="{$filename}?descriptions=show"><xsl:apply-templates/></a>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

  <!-- default match identity transform -->
  <xsl:template match="@*|node()" mode="show-collection-descriptions">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

<xsl:template match="*[@tmpl:insert='browse-page-label']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
        <xsl:text>Browse the Collections</xsl:text>
        </xsl:element>
</xsl:template>

<xsl:template match="div[@class='find-institution']">
	<div class="find-institution">Find a collection</div>
</xsl:template>

<xsl:template match="*[@tmpl:insert='browse-search']">
  <xsl:element name="{name()}">
        <xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
        <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='title']">
  <xsl:element name="{name()}">
        <xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
        Browse Collections 
	(<xsl:value-of select="if ($titlesAZ = '0') then '0-9' else (upper-case($titlesAZ))"/>), 
	<xsl:apply-templates/>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
<!--
   Copyright (c) 2005, Regents of the University of California
   All rights reserved.
 
   Redistribution and use in source and binary forms, with or without 
   modification, are permitted provided that the following conditions are 
   met:

   - Redistributions of source code must retain the above copyright notice, 
     this list of conditions and the following disclaimer.
   - Redistributions in binary form must reproduce the above copyright 
     notice, this list of conditions and the following disclaimer in the 
     documentation and/or other materials provided with the distribution.
   - Neither the name of the University of California nor the names of its
     contributors may be used to endorse or promote products derived from 
     this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
   POSSIBILITY OF SUCH DAMAGE.
-->
