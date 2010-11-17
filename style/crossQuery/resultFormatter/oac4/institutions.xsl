<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session"
	xmlns:editURL="http://cdlib.org/xtf/editURL" 
	xmlns:tmpl="xslt://template"
	exclude-result-prefixes="#all">
<xsl:import href="../common/editURL.xsl"/>
<xsl:include href="../../../common/SSI.xsl"/>


<xsl:param name="query"/>
<xsl:param name="viewAll"/>
<xsl:param name="contributing"/>
<xsl:param name="style"/>
<xsl:param name="keyword"/>
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

<xsl:variable name="layoutFile">
        <xsl:value-of select="$layoutBase"/>
        <xsl:text>/layouts/browse.xhtml</xsl:text>
</xsl:variable>

<xsl:variable name="layout" select="document($layoutFile)"/>


  <!-- default match identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

<xsl:template match="group" mode="az">
	<a href="#{@value}"><xsl:value-of select="@value"/></a>
	<xsl:text> | </xsl:text>
</xsl:template>

<xsl:template match="group[@value='onlineItems']| group[@value=',']" mode="alpha">
</xsl:template>

<xsl:template match="group" mode="alpha">

<a name="{@value}" id="{lower-case(@value)}"></a>
<div class="institutions-container-heading">
<div class="institutions-left">&#160;</div>
<div class="institutions-heading"><xsl:value-of select="if (@value = '0') then '0-9' else (upper-case(@value))"/></div>
</div>

	<xsl:apply-templates select="group" mode="double1"/>

<div class="backtotop-container">
<div class="backtotop-left">&#160;</div>
<div class="backtotop-right"><a href="#top">back to top</a></div>
</div>
</xsl:template>

<xsl:template match="group" mode="double">
	<xsl:choose>
		<xsl:when test="ends-with(@value,',')">
			<xsl:for-each select="group">
				<div>
				<a href="/institutions/{replace(@value,'\s','+')}::{replace(replace(../@value,',$',''),'\s','+')}">
				<xsl:value-of select="../@value"/>
				</a>
				<xsl:text> </xsl:text>
				<a href="/institutions/{replace(@value,'\s','+')}">
				<xsl:value-of select="@value"/>
				</a>
				</div>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<div>
				<a href="/institutions/{replace(@value,'\s','+')}"><xsl:value-of select="@value"/></a>
				<xsl:if test="group[not(@value='onlineItems')]">
				<div style="text-indent:1em;">
					<xsl:apply-templates select="group[not(@value='onlineItems')]" mode="double2a"/>
				</div>
				</xsl:if>
			</div>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="group" mode="double1">
	<xsl:choose>
		<xsl:when test="ends-with(@value,',')">
			<xsl:for-each select="group">
				<div class="institutions-container">
				<div class="institutions-left">
					<xsl:choose>
						<xsl:when test="group/@value='onlineItems'">
						<img src="/images/icons/eye_icon_white_bg.gif" width="17" height="10" alt="" title="descriptions" />
						</xsl:when>
						<xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="institutions-right">
				<a href="/institutions/{replace(@value,'\s','+')}::{replace(replace(../@value,',$',''),'\s','+')}">
				<xsl:value-of select="../@value"/>
				</a>
				<xsl:text> </xsl:text>
				<a href="/institutions/{replace(@value,'\s','+')}">
				<xsl:value-of select="@value"/>
				</a>
				</div>
				</div>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<div class="institutions-container">
				<div class="institutions-left">
					<xsl:choose>
						<xsl:when test="group/@value='onlineItems'">
						<img src="/images/icons/eye_icon_white_bg.gif" width="17" height="10" alt="" title="descriptions" />
						</xsl:when>
						<xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="institutions-right">
				<a href="/institutions/{replace(@value,'\s','+')}"><xsl:value-of select="@value"/></a>
				</div>
			</div>
			<xsl:apply-templates select="group[not(@value='onlineItems')]" mode="double2"/>


		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="group" mode="double2">
	<div class="institutions-container">
		<div class="institutions-left">
			<xsl:choose>
				<xsl:when test="group/@value='onlineItems'">
				<img src="/images/icons/eye_icon_white_bg.gif" width="17" height="10" alt="" title="descriptions" />
				</xsl:when>
				<xsl:otherwise><xsl:text>&#160;</xsl:text></xsl:otherwise>
			</xsl:choose>
		</div>
		<div class="institutions-right indent">
		<a href="/institutions/{replace(../@value,'\s','+')}::{replace(@value,'\s','+')}"><xsl:value-of select="@value"/></a>
		</div>
	</div>
</xsl:template>

<xsl:template match="group" mode="double2a">
	<div>
		<a href="/institutions/{replace(../@value,'\s','+')}::{replace(@value,'\s','+')}"><xsl:value-of select="@value"/></a>
	</div>
</xsl:template>

<xsl:template match="*[@tmpl:insert='Tabs']" >
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
                <xsl:variable name="facet" select="$page/crossQueryResult/facet[@field='institution-doublelist']"/>
<xsl:for-each select="for $n in ('0-9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q', 'R','S','T'
,'U','V','W','X','Y','Z') return $n">
<xsl:variable name="letter" select="."/>
                <xsl:choose>
                        <xsl:when test="$facet/group[@value=substring($letter,1,1)]">
                        <xsl:text> </xsl:text>
                        <a class="a-z-link" href="#{lower-case(.)}"><xsl:value-of select="."/></a>
                        <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                        <xsl:text> </xsl:text>
                        <span><xsl:value-of select="."/></span>
                        <xsl:text> </xsl:text>
                        </xsl:otherwise>
                </xsl:choose>
</xsl:for-each>
        </xsl:element>
</xsl:template>


<xsl:template match="*[@tmpl:insert='browse-row1'] | 
			*[@tmpl:insert='browse-search']">
</xsl:template>

<xsl:template match="*[@tmpl:insert='show-collection-descriptions']"> 
<div class="state-map-wrapper">

         <a href="/map/">
	<img title="map of california" alt="map of california" src="/images/misc/state_map.gif"/>
	</a>
            <div class="state-map">

            <div class="map-banner"><img width="273" height="24" src="/images/misc/map_header.gif"/>
		<img width="10" height="11" src="/images/misc/right_arrow.gif" class="arrow"/>
		<a href="/map/">Browse Map</a></div>
            </div>
  </div>
</xsl:template>


<xsl:template match="*[@tmpl:insert='browse-page-label']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
	<xsl:text>Contributing Institution</xsl:text>
	</xsl:element>
</xsl:template>

<xsl:template match="tmpl:insert[@name='main-list']">
 <xsl:apply-templates select="$page/crossQueryResult/facet[@field='institution-doublelist']/group[not(@value='')]" 
	mode="alpha"/>
</xsl:template>

<xsl:template match="*[@tmpl:insert='title']">
  <xsl:element name="{name()}">
        <xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
        Browse Institutions, <xsl:apply-templates/>
  </xsl:element>
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
