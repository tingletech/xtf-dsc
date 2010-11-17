<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session"
	xmlns:editURL="http://cdlib.org/xtf/editURL" 
	xmlns:tmpl="xslt://template">
<xsl:import href="../common/editURL.xsl"/>
<xsl:include href="../../../common/online-items-graphic-element.xsl"/>
  <xsl:output method="xhtml" indent="yes" encoding="UTF-8" media-type="text/xml"/>
              <!-- doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/ -->
<xsl:param name="developer"/>
<xsl:param name="query"/>
<xsl:param name="viewAll"/>
<xsl:param name="view5"/>
<xsl:param name="style"/>
<xsl:param name="keyword"/>
<xsl:param name="decade"/>
<xsl:param name="institution"/>
<xsl:param name="facet-subject"/>
<xsl:param name="facet-coverage"/>
<xsl:param name="relation"/>
<xsl:param name="group" select="'collection'"/>
<xsl:variable name="beforeGroup" select="if (substring-before($group,'::')) 
		then substring-before($group,'::') else $group"/>
<xsl:variable name="afterGroup" select="if (substring-before($group,'::')) 
		then substring-after($group,'::') else $group"/>
<xsl:param name="http.URL"/>
<xsl:param name="queryString" select="editURL:remove(
					editURL:remove(
						editURL:set(substring-after($http.URL,'?'),'style','oac4')
					,'page')
				      ,'viewAll')
				"/>

<xsl:variable name="page" select="/"/>

<xsl:template match="/">
	<xsl:apply-templates select="$page/crossQueryResult/facet[@field='facet-institution' or @field='facet-decade' or @field='facet-onlineItems']" mode="searchLimits"/>
	<xsl:if test="$relation">
	<xsl:apply-templates select="$page/crossQueryResult/facet[@field='facet-subject' or @field='facet-coverage']" mode="searchLimits"/>
	</xsl:if>
</xsl:template>

  <!-- default match identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

<xsl:template match="facet" mode="searchLimits">
	<!-- there must be a better way... -->
	<xsl:variable name="decadeNarrow" select="boolean(
				( @field='facet-decade' and $decade ne '')
				or (@field='facet-coverage' and $facet-coverage ne '' )
				or (@field='facet-subject' and $facet-subject ne '')
			)"/>
	<xsl:if test="@totalDocs &gt; 0">
	<div class="facet">
		<h2><xsl:apply-templates select="@field" mode="searchLimits"/></h2> 
		<xsl:if test="$viewAll and not($view5) and not($decadeNarrow)">
			<div class="viewAll">
				<a href="/search?{editURL:set(substring-after($http.URL,'?'),'view5','view5')}" onclick="replaceGP(this);return false;">View 5</a>
			</div>
		</xsl:if>
		<xsl:apply-templates mode="searchLimits"/>
		<xsl:if test="(@totalGroups &gt; 5) and ( not($viewAll) or  $view5 ) and not($decadeNarrow)">
			<div class="viewAll">
			  <xsl:choose>
			    <xsl:when test="@totalGroups &gt; 100 and not(@field='facet-decade') and not(@field='facet-institution')">
				<a href="#">
					<xsl:attribute name="onclick">
					<xsl:text>facetBrowser('</xsl:text>
					<!-- facet -->
					<xsl:variable name="facet" select="replace(@field,'facet-','')"/>
					<xsl:value-of select="$facet"/>
					<xsl:text>');return false;</xsl:text>
					</xsl:attribute>View all <xsl:value-of select="@totalGroups"/></a>
			    </xsl:when>
			    <xsl:otherwise>
				<a href="/search?{editURL:remove(
							editURL:set(
								substring-after($http.URL,'?')
						      	,'viewAll',@field)
						    ,'view5')}" 
					onclick="replaceGP(this);return false;">View all <xsl:value-of select="@totalGroups"/></a>
			    </xsl:otherwise>
			  </xsl:choose>
			</div>
		</xsl:if>
		<xsl:if test="$viewAll and not($view5)">
			<div class="viewAll">
				<a href="/search?{editURL:set(substring-after($http.URL,'?'),'view5','view5')}" onclick="replaceGP(this);return false;">View 5</a>
			</div>
		</xsl:if>
		<div class="hide" style="visibility:hidden;"/>
	</div>
	</xsl:if>
</xsl:template>

<xsl:template match="facet[@field='facet-onlineItems']" mode="searchLimits">
	<xsl:variable name="docsWithItems" select="group[@value='Items online']/@totalDocs"/>
	<xsl:if test="$docsWithItems &gt; 0 and not($relation)">
	<div class="facet">
		<xsl:choose>
		<xsl:when test="$page/crossQueryResult/parameters/param[@name='onlineItems'][@value='Items online']">
			<xsl:call-template name="online-items-graphic-element"/>
			(<xsl:value-of select="$docsWithItems"/>)
			<a href="/search?{editURL:remove($queryString,'onlineItems')}">
		<img class="close-window-icon" src="/images/buttons/close_window.gif" width="10" height="10" alt="Close window" title="Close window" />
			</a>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="online-items-graphic-element">
				<xsl:with-param name="href">
					<xsl:text>/search?</xsl:text>
					<xsl:value-of select="editURL:set($queryString, 'onlineItems' , 'Items online')"/>
				</xsl:with-param>
			</xsl:call-template>
			(<xsl:value-of select="$docsWithItems"/>)
		</xsl:otherwise>
		</xsl:choose>
	</div>
	</xsl:if>
</xsl:template>

<xsl:template match="group" mode="searchLimits">
	<xsl:variable name="facet" select="replace(replace(ancestor::facet/@field,'facet-decade','decade'),'facet-institution','institution')"/>
	<xsl:variable 
		name="value" 
		select="if (not(ancestor::group))
			then @value
			else concat((ancestor::group)[1]/@value, '::', @value)
		"/>
	<div class="group">
	   <xsl:choose>
		<xsl:when test="$page/crossQueryResult/parameters/param[@name=$facet][@value=$value]">
			<xsl:value-of select="@value"/>
			(<xsl:value-of select="@totalDocs"/>)
			<a href="/search?{editURL:remove($queryString,$facet)}">
<img class="close-window-icon" src="/images/buttons/close_window.gif" width="10" height="10" alt="Close window" title="Close window" />
			</a>
		</xsl:when>
		<xsl:otherwise>
			<a href="/search?{editURL:set($queryString, $facet , $value)}">
				<xsl:value-of select="@value"/>
			</a> (<xsl:value-of select="@totalDocs"/>)
		</xsl:otherwise>
	   </xsl:choose>
		<xsl:apply-templates mode="searchLimits"/>
	</div>
</xsl:template>

<xsl:template match="@field" mode="searchLimits">
	<xsl:choose>
		<xsl:when test=".='facet-institution'">
			<xsl:text>Institutions</xsl:text>
		</xsl:when>
		<xsl:when test=".='facet-decade'">
			<xsl:text>Date</xsl:text>
		</xsl:when>
		<xsl:when test=".='facet-subject'">
			<xsl:text>Subjects</xsl:text>
		</xsl:when>
		<xsl:when test=".='facet-coverage'">
			<xsl:text>Places</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="replace(.,'^facet-','')"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


</xsl:stylesheet>

<!--
   Copyright (c) 2008, Regents of the University of California
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
