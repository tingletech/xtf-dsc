<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session"
	xmlns:view="http://www.cdlib.org/view"
	xmlns:tmpl="xslt://template"
	exclude-result-prefixes="#all"
	xmlns:mods="http://www.loc.gov/mods/v3">

<xsl:import href="../../../common/MODS-view.xsl"/>
<xsl:import href="../../../common/brandCommon.xsl"/>
<xsl:include href="../../../common/SSI.xsl"/>

  <xsl:output method="xhtml"
    indent="yes"
              encoding="UTF-8" media-type="text/html; charset=UTF-8"
        omit-xml-declaration="yes"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
<xsl:variable name="brandCgi"/>
<xsl:param name="query"/>
<xsl:param name="style"/>
<xsl:param name="keyword"/>
<xsl:param name="group" select="'collection'"/>
<xsl:param name="brand" select="'oac4'"/>
<xsl:variable name="beforeGroup" select="if (substring-before($group,'::')) 
		then substring-before($group,'::') else $group"/>
<xsl:variable name="afterGroup" select="if (substring-before($group,'::')) 
		then substring-after($group,'::') else $group"/>

<xsl:variable name="page" select="/"/>

<xsl:variable name="layoutFile">
        <xsl:value-of select="$layoutBase"/>
        <xsl:text>/layouts/collection-guide-template.xhtml</xsl:text>
</xsl:variable>

<!-- layout for OAC 4 -->
<xsl:variable name="layout" select="document($layoutFile)"/>

<!-- layout for CUI era page design -->
<xsl:variable name="metadataLayout" select="document('../../../../../xtf/mets-support/xslt/view/metadata.xhtml')"/>

<xsl:variable name="queryURL">
	<xsl:text>/search?style=</xsl:text><xsl:value-of select="$style"/>
	<xsl:if test="$query"><xsl:text>;query=</xsl:text><xsl:value-of select="$query"/></xsl:if>
	<xsl:if test="$keyword"><xsl:text>;keyword=</xsl:text><xsl:value-of select="$keyword"/></xsl:if>
	<xsl:if test="$developer != 'local'"><xsl:text>;developer=</xsl:text><xsl:value-of select="$developer"/></xsl:if>
</xsl:variable>

<xsl:template match="/">
	<xsl:choose>
		<xsl:when test="$page/crossQueryResult/docHit[1]/meta/oac4-tab = 'Items::offline'">
 			<xsl:apply-templates select="($metadataLayout)//*[local-name()='html']"/>
		</xsl:when>
		<xsl:otherwise>
 			<xsl:apply-templates select="($layout)//*[local-name()='html']"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- OAC 4 style -->

<xsl:template match="
	*[@tmpl:insert='GuideViews'] | 
	*[@tmpl:insert='SearchInsideHead'] | 
	*[@tmpl:insert='SearchInsideForm'] | 
	*[@tmpl:insert='CollectionContentsHead'] |
	*[@tmpl:insert='CollectionContents'] |
	*[@tmpl:insert='TableOfContents']  |
	*[@tmpl:insert='search-hits'] |
	*[@tmpl:process='collection-search']
	">
  <xsl:element name="{name()}">
        <xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
  </xsl:element>
</xsl:template>

<xsl:template match="
	div[starts-with(@class,'row1-right')] | 
	div[@class='middle-row-inner-right'] |
	div[@class='row2-right-top']
	">
        <xsl:element name="{name()}">
	<xsl:for-each select="@*">
		<xsl:choose>
			<xsl:when test="name()='class'">
				<xsl:attribute name="class">
					<xsl:value-of select="."/>
					<xsl:text> marc</xsl:text>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy copy-namespaces="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
	</xsl:element>
</xsl:template>

<xsl:template match="div[@class='row2-right']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
	<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template match="div[@class='collection-contents-container']"/>

<xsl:template match="div[@tmpl:insert='permalink']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
Brief record only
<!-- a href="#help-guide" onclick="return helpBubbleGuide(this)">
                              <img src="/images/icons/questionmark_purple_bg.gif" width="13" height="13" border="0" alt="What's This?" title="What's This?"></img>
                           </a -->
        </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='collection-items']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
	<xsl:apply-templates/>
        </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='collection-location']" name="collection-location">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
        <xsl:variable
                name="location"
                select="$page/crossQueryResult/docHit/meta/facet-institution[1]"
        />
        <img class="car-icon" src="/images/icons/car_icon.gif" width="17" height="13" alt="Collection location" title="Collection location"/>
        <span class="location">
                <a class="location-link" href="/institutions/{replace($location,'\s','+')}">
                        <xsl:text>Offline.  Contact </xsl:text>
                        <xsl:value-of select="$location"/> 
                </a>
        </span>
        </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='breadcrumbs']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
        <span><a href="/">> Home</a> </span>
        <!-- span><a href="/institutions/">> Contributing Institution</a> </span -->
<xsl:variable name="Institution" select="$page/crossQueryResult/docHit/meta/facet-institution"/>
<xsl:variable name="parts" select="tokenize($Institution,'::')"/>
<xsl:choose>
<xsl:when test="$parts[2]">
        <span><a href="/institutions/{replace($parts[1],'\s','+')}">> <xsl:value-of select="$parts[1]"/></a></span>
	<span><a href="/institutions/{replace($Institution,'\s','+')}">> <xsl:value-of select="$parts[2]"/></a></span>
</xsl:when>
<xsl:otherwise>
	<span><a href="{replace($Institution,'\s','+')}"><xsl:value-of select="$Institution"/></a></span>
</xsl:otherwise>
</xsl:choose>
        </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='NavWatch']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
<div class="sub-heading-1">Collection Overview</div>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='Title'] | *[@tmpl:insert='title']">
  <xsl:element name="{name()}">
        <xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
        <xsl:value-of select="$page/crossQueryResult/docHit/meta/title[1]"/>
  </xsl:element>
</xsl:template>

<xsl:template match="tmpl:FootScript"/>

<xsl:template match="*[@tmpl:insert='ColNumber']"><!-- collection-number -->
  <xsl:element name="{name()}">
        <xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
        <xsl:value-of select="replace($page/crossQueryResult/docHit/meta/identifier[@q='call'][1],'^Collection Number: ','')"/>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='Institution']">
  <xsl:element name="{name()}">
        <xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
        <xsl:apply-templates select="$page/crossQueryResult/docHit/meta/facet-institution"/>
  </xsl:element>
</xsl:template>

<xsl:template match='*[@tmpl:insert="MainEAD"]'>
  <xsl:element name="{name()}">
                <xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
		<xsl:variable name="fixNameSpace">
			<xsl:apply-templates select="$page/crossQueryResult/docHit/meta/mods" mode="fixNS"/>
		</xsl:variable>
		<xsl:copy-of select="view:MODS($fixNameSpace,'')"/>
  </xsl:element>
</xsl:template>

<xsl:template match="*" mode="fixNS">
	<xsl:element name="{local-name()}" namespace="http://www.loc.gov/mods/v3">
		<xsl:apply-templates select="node()" mode="fixNS"/>
	</xsl:element>
</xsl:template>

  <!-- default match identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>


<!-- CUI style cui -->

<xsl:template match="insert-head-title">
	<title><xsl:value-of select="$page/crossQueryResult/docHit/meta/title[1]"/></title>
</xsl:template>

<xsl:template match="insert-brand-links">
<xsl:comment>insert-brand-links</xsl:comment>
 <xsl:apply-templates select="$brand.links"/>

</xsl:template>

<xsl:template match="insert-brand-head">
<xsl:comment>insert-brand-head</xsl:comment>
 <xsl:copy-of select="$brand.header"/>
</xsl:template>

<xsl:template match="insert-brand-footer">
<xsl:comment>insert-brand-footer</xsl:comment>
 <xsl:copy-of select="$brand.footer"/>
</xsl:template>

<xsl:template match="insert-multi-use| insert-sitesearch| insert-LaunchPad| insert-print-links"/>

<xsl:template match="insert-metadataPortion">
                 <xsl:variable name="fixNameSpace">
                        <xsl:apply-templates select="$page/crossQueryResult/docHit/meta/mods" mode="fixNS"/>
                </xsl:variable>
                <xsl:copy-of select="view:MODS($fixNameSpace,'')"/>
</xsl:template>

<xsl:template match="insert-image-simple">
<img title="Go to institution for this item" 
     alt="Go to institution for this item" 
     src="/images/icons/car-icon-lg.gif"/>
<div>
 <xsl:value-of select="replace($page/crossQueryResult/docHit/meta/identifier[@q='call'][1],'Collection Number:','Call Number:')"/>

</div>
<div>
       <xsl:variable
                name="location"
                select="$page/crossQueryResult/docHit/meta/facet-institution[1]"
        />
        <span class="location">
                <a class="location-link" href="/institutions/{replace($location,'\s','+')}">
                        <xsl:value-of select="$location"/>
                </a>
        </span>



</div>
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
