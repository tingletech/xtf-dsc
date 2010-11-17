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

  <xsl:output method="xhtml"
    indent="yes"
	      encoding="UTF-8" media-type="text/html; charset=UTF-8" 
        omit-xml-declaration="yes"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>



<!--	xmlns:editURL="http://cdlib.org/xtf/editURL" -->
<xsl:param name="http.URL"/>
<xsl:param name="queryString" select="editURL:remove(editURL:set(substring-after($http.URL,'?'),'style','attached'),'page')"/>
<xsl:param name="query"/>
<xsl:param name="page" select="1"/>
<xsl:param name="sort"/>
<xsl:param name="style" select="'attached'"/>
<xsl:param name="keyword"/>
<xsl:param name="idT"/>
<xsl:param name="group" select="'Collections'"/>
<xsl:variable name="beforeGroup" select="if (substring-before($group,'::')) 
		then substring-before($group,'::') else $group"/>
<xsl:variable name="afterGroup" select="if (substring-before($group,'::')) 
		then substring-after($group,'::') else $group"/>

<xsl:variable name="pageXML" select="/"/>

<xsl:variable name="queryURL">
	<xsl:text>/search?style=attached</xsl:text>
	<xsl:if test="$query"><xsl:text>;query=</xsl:text><xsl:value-of select="$query"/></xsl:if>
	<xsl:if test="$keyword"><xsl:text>;keyword=</xsl:text><xsl:value-of select="$keyword"/></xsl:if>
	<xsl:if test="$developer != 'local'"><xsl:text>;developer=</xsl:text><xsl:value-of select="$developer"/></xsl:if>
	<xsl:if test="$group"><xsl:text>;group=</xsl:text><xsl:value-of select="$group"/></xsl:if>
</xsl:variable>

<xsl:template match="/">

<html><head>
</head>
<body>

<!-- Combo-handled YUI CSS files: --><link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/combo?2.8.0r4/build/carousel/assets/skins/sam/carousel.css"></link>

<style type="text/css">
.yui-carousel-element li {
    height: 100px;
    width: 100px;
}

    .yui-skin-sam .yui-carousel-nav ul,
    .yui-skin-sam .yui-carousel-nav select {
        display: none;
    }   
    
    </style>
<!-- Combo-handled YUI JS files: -->
<script type="text/javascript" src="http://yui.yahooapis.com/combo?2.8.0r4/build/yahoo-dom-event/yahoo-dom-event.js&amp;2.8.0r4/build/animation/animation-min.js&amp;2.8.0r4/build/element/element-min.js&amp;2.8.0r4/build/carousel/carousel-min.js"></script>

<div id="container" class="yui-skin-sam">
  <ol id="carousel">

<xsl:choose>
	<xsl:when test="crossQueryResult/@totalDocs != '0'"><!-- not zero results -->
	<xsl:apply-templates select="crossQueryResult/docHit" mode="searchResults"/>
	</xsl:when>
	<xsl:otherwise>
		<div class="row2-zero-results">
		<div class="zero-results">
			There are no results for this query. Please modify your search and try again.
		</div>
		</div>
	</xsl:otherwise>
</xsl:choose>
</ol>
</div>
<div id="spotlight"/>
<script type="text/javascript">
<![CDATA[
YAHOO.util.Event.onDOMReady(function (ev) {
  var carousel = new YAHOO.widget.Carousel('container', {
        animation: { speed: 0.5 },
        numVisible: 1,
        revealAmount: 25,
	autoPlayInterval: 2000,
	isCircular: true
  });
  var spotlight = document.getElementById('spotlight');
  carousel.on("itemSelected", function (index) {
   var item = carousel.getElementForItem(index);

   if (item) {
       spotlight.innerHTML = item.firstElementChild.firstElementChild.alt;
	console.log(item);
   }
  });
  carousel.render();
  carousel.show();
carousel.startAutoPlay();


})
]]>
</script>
</body>
        <xsl:comment>
        url: <xsl:value-of select="$http.URL"/>
        xslt: <xsl:value-of select="static-base-uri()"/>
	layoutFile: <!-- xsl:value-of select="$layoutFile"/ -->
        </xsl:comment>
</html>
</xsl:template>


<!-- search results docHit -->

<xsl:template 
	match="docHit[./meta/oac4-tab='Items::image'] | docHit[./meta/oac4-tab='Items::text']"
	mode="searchResults">
<xsl:comment><xsl:value-of select="@rank"/></xsl:comment>

	<xsl:variable name="link">
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="replace(meta/identifier[1],'http://ark.cdlib.org/','')"/>
                        <xsl:text>/?brand=oac4</xsl:text>
	</xsl:variable>
			    <li class="collection-result">
                                    <a href="{$link}" target="_top">
                                       <img>
					<xsl:attribute name="src">
						<xsl:text>/</xsl:text>
                        			<xsl:value-of select="replace(meta/identifier[1],'http://ark.cdlib.org/','')"/>
                        			<xsl:text>/thumbnail</xsl:text>
                			</xsl:attribute>
                			<xsl:attribute name="width" select="meta/thumbnail/@X"/>
                			<xsl:attribute name="height" select="meta/thumbnail/@Y"/>
					<xsl:attribute name="alt">
						<xsl:value-of select="meta/title[1]"/>
					</xsl:attribute>
				       </img>
                                    </a>
                              </li>

</xsl:template>

<xsl:template name="pagination">
<div class="pagination-hdr">
<table>
                                 <tbody><tr>
                                    <td>
                                       <span class="pagination-item">
        <xsl:value-of select="format-number($pageXML/crossQueryResult/@startDoc,'###,###')"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="format-number($pageXML/crossQueryResult/@endDoc,'###,###')"/>
        <xsl:text> of </xsl:text>
        <xsl:value-of select="format-number($pageXML/crossQueryResult/@totalDocs,'###,###')"/>
        <xsl:text> results</xsl:text>
<!-- (facet/group[@value=$group]) -->
                                          
                                       </span>
                                    </td>
                                    <td>
                                       <span class="pagination-item">

<form action="/search" id="results-page"><span class="caption">Results page: </span>
	<!-- input type="hidden" name="query" value="{$query}"/>
	<input type="hidden" name="developer" value="{$developer}"/>
	<input type="hidden" name="style" value="'oac4'"/ -->

	<xsl:copy-of select="editURL:toHidden($queryString)"/>
	<xsl:choose>
		<xsl:when test="number($page) = 1"><span>|&lt;&lt;</span> <span>Previous</span></xsl:when>
		<xsl:otherwise>
			<a>
				<xsl:call-template name="pageLink">
					<xsl:with-param name="page">1</xsl:with-param>
				</xsl:call-template>
				<xsl:text>|&lt;&lt;</xsl:text>
			</a>
			<xsl:text> </xsl:text>
			<a>
				<xsl:call-template name="pageLink">
					<xsl:with-param name="page" select="number($page) - 1"/>
				</xsl:call-template>
				<xsl:text>Previous</xsl:text>
			</a>
		</xsl:otherwise>
	</xsl:choose>
<xsl:variable 
	name="lastPage" 
	select="if 
		($pageXML/crossQueryResult/@totalDocs 
			and $pageXML/crossQueryResult/@totalDocs &gt; 0)
		then xs:integer(ceiling(number($pageXML/crossQueryResult/@totalDocs) div 20))
		else 1"/>

<select name="page" onchange="return pageinside(this.form);">
	<xsl:for-each select="1 to $lastPage">
		<option>
			<xsl:attribute name="value">
				<xsl:value-of select="number(.)"/>
			</xsl:attribute>
			<xsl:if test="number($page) = number(.)">
				<xsl:attribute name="selected"><xsl:text>selected</xsl:text></xsl:attribute>
			</xsl:if>
			<xsl:value-of select="."/>
		</option>
	</xsl:for-each>
</select>
	<xsl:choose>
		<xsl:when test="number($page) = number($lastPage)">
			<span>Next</span> <span>>>|</span>
		</xsl:when>
		<xsl:otherwise>
			<a>
				<xsl:call-template name="pageLink">
					<xsl:with-param name="page" select="number($page) + 1"/>
				</xsl:call-template>
				<xsl:text>Next</xsl:text>
			</a>
			<xsl:text> </xsl:text>
			<a>
				<xsl:call-template name="pageLink">
					<xsl:with-param name="page" select="$lastPage"/>
				</xsl:call-template>
				<xsl:text>&gt;&gt;|</xsl:text>
			</a>
		</xsl:otherwise>
	</xsl:choose>
</form>

                                       </span>
                                    </td>
                                 </tr>
                              </tbody></table>
</div>
</xsl:template>

<xsl:template name="pageLink">
	<xsl:param name="page"/>
	<xsl:attribute name="href">
		<xsl:text>/search?</xsl:text>
		<xsl:value-of select="editURL:set($queryString,'page',$page)"/>
	</xsl:attribute>
	<xsl:attribute name="onclick">
		<xsl:text>return getitems(this.href);</xsl:text>
	</xsl:attribute>
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
