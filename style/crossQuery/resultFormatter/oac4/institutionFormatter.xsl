<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session"
	xmlns:editURL="http://cdlib.org/xtf/editURL" 
	xmlns:sql="java:/net.sf.saxon.sql.SQLElementFactory"
	exclude-result-prefixes="#all"
	xmlns:lookup="xslt://org.cdlib.dsc.util.InstitutionToArk"
	extension-element-prefixes="sql"
	xmlns:tmpl="xslt://template">


<xsl:import href="../common/editURL.xsl"/>
<xsl:include href="../../../common/SSI.xsl"/>
<xsl:include href="azBrowseResults.xsl"/>

<xsl:include href="autocomplete-js.xsl"/>

  <xsl:output method="xhtml"
    indent="yes"
    encoding="utf-8"
	media-type="text/html; charset=UTF-8" 
        omit-xml-declaration="yes"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>


<xsl:param name="Institution"/>
<xsl:param name="descriptions"/>
<xsl:param name="titlesAZ"/>
<xsl:param name="group" select="'collection'"/>
<xsl:param name="limit"/>

<!-- filter untrusted input -->
<xsl:variable name="Institution.filtered" select="replace($Institution,'[^\i\s\.\(\)/,-].*','')"/>

<xsl:variable name="Institution.filtered.parts" select="tokenize($Institution.filtered,'::')"/>

<xsl:variable name="Institution.filtered.reversed">
	<xsl:choose>
		<xsl:when test="$Institution.filtered.parts[2]">
			<xsl:value-of select="$Institution.filtered.parts[2]"/>
			<xsl:text>, </xsl:text>
			<xsl:value-of select="$Institution.filtered.parts[1]"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$Institution.filtered"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>


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

<xsl:variable name="onlineItemCount" select="$page/crossQueryResult/facet[@field='facet-onlineItems']/group[@value='Items online']/@totalDocs"/>
<xsl:variable name="marcItemCount" select="$page/crossQueryResult/facet[@field='oac4-tab']/group[@value='Collections']/group[@value='marc']/@totalDocs"/>
<xsl:variable name="eadItemCount" select="$page/crossQueryResult/facet[@field='oac4-tab']/group[@value='Collections']/group[@value='ead']/@totalDocs"/>

<xsl:variable name="filename">
	<xsl:text>/institutions/</xsl:text>
	<xsl:value-of select="replace($Institution.filtered,'\s','+')"/>
</xsl:variable>

<xsl:variable name="layout" select="document($layoutFile)"/>

<xsl:variable name="pageType">
	<xsl:choose>
<xsl:when test="$page/crossQueryResult/facet[@field='facet-institution']/group[starts-with($Institution,@value)]/@totalSubGroups &lt;= 1">
		<xsl:text>Collections</xsl:text>
	</xsl:when>
	<xsl:otherwise>
		<xsl:text>Locations</xsl:text>
	</xsl:otherwise>
	</xsl:choose>
</xsl:variable>


<xsl:param name="BACK_SERVER" select="System:getenv('BACK_SERVER')" xmlns:System="java:java.lang.System"/>

<xsl:variable name="djUrl">
	<!-- xsl:text>http://oac-dev.cdlib.org:8089/djsite/institution/address_info/div/</xsl:text -->
	<xsl:value-of select="concat('http://',$BACK_SERVER,'/djsite/institution/address_info/div/')"/>
	<!-- need to work around a strange wsgi bug , / can't be escaped -->
	<xsl:value-of select="replace(encode-for-uri($Institution.filtered),'%2F','/')"/>
</xsl:variable>
<xsl:variable name="repodata" select="document($djUrl)">
</xsl:variable>
<xsl:variable name="ark" select="($repodata)/div/@ark"/>

<xsl:variable name="descriptionsCgi">
	<xsl:choose>
		<xsl:when test="not($descriptions) or $descriptions=''"/>
		<xsl:otherwise>
			<xsl:text>;descriptions=show</xsl:text>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="limitCgi">
	<xsl:choose>
		<xsl:when test="not($limit) or $limit=''"/>
		<xsl:otherwise>
			<xsl:text>;limit=</xsl:text>	
			<xsl:value-of select="$limit"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:template match="/">
<xsl:apply-templates select="($layout)//*[local-name()='html']"/>
        <xsl:comment>
	url: <xsl:value-of select="$http.URL"/>
        xslt: <xsl:value-of select="static-base-uri()"/>
	layoutfile: <xsl:value-of select="$layoutFile"/>
        </xsl:comment>
</xsl:template>

  <!-- default match identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

<!-- xsl:template match="meta" >
<div><a href="/findaid/{replace(identifier[1],'http://ark.cdlib.org/','')}"><xsl:value-of select="title"/></a></div>
</xsl:template -->

<xsl:template match="group" mode="double">
					<xsl:apply-templates select="group[not(@value='onlineItems')]" mode="double2"/>
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
                           <div class="institutions-right">
		<a href="/institutions/{replace(../@value,'\s','+')}::{replace(@value,'\s','+')}">
		<xsl:value-of select="@value"/>
		</a>
                           </div>
                        </div>
</xsl:template>


<xsl:template match="*[@tmpl:insert='Tabs']" >
<xsl:choose>
	<xsl:when test="($Institution='UC Berkeley::Bancroft Library' or $Institution='Hoover Institution') and not($limit='ead' or $limit='online')">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
<xsl:for-each select="for $n in ('0-9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q', 'R','S','T','U','V','W','X','Y','Z') return $n">
	<xsl:text> </xsl:text>
	<a class="a-z-link" href="/institutions/{replace($Institution,'\s','+')}?titlesAZ={substring(.,1,1)}{$limitCgi}"><xsl:value-of select="."/></a>
	<xsl:text> </xsl:text>
</xsl:for-each>
	</xsl:element>
	</xsl:when>

	<xsl:when test="$pageType = 'Collections'">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
		<!-- xsl:copy-of select="@*" copy-namespaces="no"/ -->
		<xsl:variable name="facet" select="
					if ($limit) 
					then $page/crossQueryResult/facet[starts-with(@field,'facet-titlesAZ')]/group 
					else ($page/crossQueryResult/facet[starts-with(@field,'facet-titlesAZ')]) "/>
<xsl:for-each select="for $n in ('0-9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q', 'R','S','T','U','V','W','X','Y','Z') return $n">
<xsl:variable name="letter" select="."/>
		<xsl:choose>
			<xsl:when test="$facet//group[@value=substring($letter,1,1)]">
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
	</xsl:when>
	<xsl:otherwise/>
</xsl:choose>
</xsl:template>

<!-- online items graphic element -->
<xsl:template match="div[@class='institutions-container-top']">
<xsl:if test="$onlineItemCount &gt; 0 and not($limit='marc')">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
	<!-- TODO; generate HTML rather than copying it from the template file -->
<div class="institutions-left">
<img width="17" height="10" title="" alt="" src="/images/icons/eye_icon_white_bg.gif"/>
</div>
<div class="institutions-right">
	<xsl:choose>
		<xsl:when test="not($limit = 'online')">
	<a href="{$filename}?limit=online{$descriptionsCgi}">Show collections with online items</a>
		</xsl:when>
		<xsl:otherwise>
	<a href="{$filename}?{$descriptionsCgi}">Show all collections</a>
		</xsl:otherwise>
	</xsl:choose>
</div>
	<!-- xsl:apply-templates/ -->
	</xsl:element>
</xsl:if>
</xsl:template>

<xsl:template match="div[@class='find-institution']">
  <xsl:choose>
	<xsl:when test="$pageType = 'Collections'">
        	<div class="find-institution">Find a collection at this institution</div>
	</xsl:when>
	<xsl:otherwise>
        	<div class="find-institution">Find a collection at these institutions</div>
	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[@class='from-a-z']">
<xsl:choose>
	<xsl:when test="$pageType = 'Collections'">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
		<xsl:apply-templates/>
	</xsl:element>
	</xsl:when>
	<xsl:otherwise/>
</xsl:choose>
</xsl:template>

<xsl:template match="*[@tmpl:insert='show-collection-descriptions']">
<xsl:if test="$pageType='Collections'">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
        <xsl:apply-templates mode="show-collection-descriptions"/>
        </xsl:element>

	<xsl:if test="not($limit='online') and $marcItemCount and $eadItemCount">
        <xsl:call-template name="hide-marc"/>
	</xsl:if>

	<!-- div><xsl:apply-templates select="$page/crossQueryResult/facet[@field='facet-subject']/group" mode="subject"/></div -->
</xsl:if>
</xsl:template>

<xsl:template match="group" mode="subject">
<div>
	<xsl:value-of select="@value"/>
	(<xsl:value-of select="@totalDocs"/>)
</div>
</xsl:template>

<xsl:template match="a" mode="show-collection-descriptions">
        <!-- xsl:variable name="filename">
		<xsl:text>/institutions/</xsl:text>
		<xsl:value-of select="replace($Institution.filtered,'\s','+')"/>
        </xsl:variable -->
        <xsl:choose>
	<!-- only bancroft showing all items when not of the first page -->
	<xsl:when test="$titlesAZ != ''">
		<xsl:choose>
			<xsl:when test="$descriptions='show'">
                <a href="{$filename}?titlesAZ={$titlesAZ}{$limitCgi}">Hide collection descriptions</a>
			</xsl:when>
			<xsl:otherwise>
                <a href="{$filename}?titlesAZ={$titlesAZ};descriptions=show{$limitCgi}"><xsl:apply-templates/></a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
        <xsl:when test="$descriptions='show'">
                <a href="{$filename}{replace($limitCgi,'^;','?')}">Hide collection descriptions</a>
        </xsl:when>
        <xsl:otherwise>
                <a href="{$filename}?descriptions=show{$limitCgi}"><xsl:apply-templates/></a>
        </xsl:otherwise>
        </xsl:choose>
</xsl:template>

<xsl:template name="hide-marc">

<div class="show-collection-records"><img src="/images/misc/arrow.gif" width="9" height="10" border="0" alt="Show records" title="Show records" /><span class="header">Show records:</span> 

	<xsl:choose>
	<xsl:when test="$limit = 'ead'">
<a href="{$filename}{replace($descriptionsCgi,'^;','?')}">All</a> | <span class="off">EAD</span> | <a href="{$filename}&amp;limit=marc{$descriptionsCgi}">MARC</a>
	</xsl:when>
	<xsl:when test="$limit = 'marc'">
<a href="{$filename}{replace($descriptionsCgi,'^;','?')}">All</a> | <a href="{$filename}&amp;limit=ead{$descriptionsCgi}">EAD</a> | <span class="off">MARC</span>
	</xsl:when>
        <xsl:otherwise>
<span class="off">All</span> | <a href="{$filename}&amp;limit=ead{$descriptionsCgi}">EAD</a> | <a href="{$filename}&amp;limit=marc{$descriptionsCgi}">MARC</a>
	</xsl:otherwise>
	</xsl:choose>

</div>
</xsl:template>

  <!-- default match identity transform -->
  <xsl:template match="@*|node()" mode="show-collection-descriptions hide-marc">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>


<xsl:template match="*[@tmpl:insert='browse-row1']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
	<xsl:apply-templates/>
        </xsl:element>
</xsl:template>
                        
<!-- xsl:template match="*[@tmpl:insert='browse-search']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
        </xsl:element>
</xsl:template -->

<xsl:template match="*[@tmpl:insert='browse-page-label']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
        <xsl:text>Browse the Collections</xsl:text>
        </xsl:element>
</xsl:template>

<xsl:template match="tmpl:insert[@name='main-list']" name="main-list">
<xsl:choose>
	<xsl:when test="$pageType = 'Collections'">
  		<xsl:choose>
                	<xsl:when test="$descriptions='show' and $limit">
                		<xsl:apply-templates 
					select="$page/crossQueryResult/facet[@field='facet-titlesAZ-limit']/group/group" 
					mode="azBrowseResultsDescriptions"/>
                	</xsl:when>
                	<xsl:when test="$descriptions='show'">
                		<xsl:apply-templates 
					select="$page/crossQueryResult/facet[@field='facet-titlesAZ']/group" 
					mode="azBrowseResultsDescriptions"/>
                	</xsl:when>
                	<xsl:when test="$limit">
                		<xsl:apply-templates 
					select="$page/crossQueryResult/facet[@field='facet-titlesAZ-limit']/group/group" 
					mode="azBrowseResults"/>
                	</xsl:when>
                	<xsl:otherwise>
                		<xsl:apply-templates 
					select="$page/crossQueryResult/facet[@field='facet-titlesAZ']/group" 
					mode="azBrowseResults"/>
                	</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
<div>
        <xsl:apply-templates
select="$page/crossQueryResult/facet[@field='institution-doublelist']//group[starts-with(@value,$Institution)]"
                        mode="double"/>
</div>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="group" mode="azBrowseResults">
<div class="institutions-container-heading">
	<div class="institutions-left">&#160;</div>
	<div class="institutions-heading">
		<a name="{lower-case(@value)}">
		<xsl:value-of select="if (@value = '0') then '0-9' else (upper-case(@value))"/>
		</a>
	</div>
</div>

	<xsl:apply-templates select="docHit" mode="azBrowseResults"/>
<div class="backtotop-container">
<div class="backtotop-left">&#160;</div>
<div class="backtotop-right"><a href="#top">back to top</a></div>
</div>
</xsl:template>

<xsl:template match="group" mode="azBrowseResultsDescriptions">
<div class="institutions-container-heading">
<div class="institutions-left">&#160;</div>
<div class="institutions-heading"><a name="{lower-case(@value)}"><xsl:value-of select="upper-case(@value)"/></a></div>
</div>

	<xsl:apply-templates select="docHit" mode="azBrowseResultsDescriptions"/>
<div class="backtotop-container">
<div class="backtotop-left">&#160;</div>
<div class="backtotop-right"><a href="#top">back to top</a></div>
</div>
</xsl:template>

<xsl:template match="*[@tmpl:insert='breadcrumbs']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
<div class="breadwrapper">
	<span><a href="/">> Home</a> </span>
	<span><a href="/institutions/">> Contributing Institution</a> </span>
<xsl:variable name="parts" select="tokenize($Institution.filtered,'::')"/>
<xsl:if test="$parts[2]">
	<span><a href="/institutions/{replace($parts[1],'\s','+')}">> <xsl:value-of select="$parts[1]"/></a></span>
</xsl:if>
</div>
<a class="a2a_dd" href="http://www.addtoany.com/share_save">
<img src="/default/images/share_save_120_16.gif" width="120" height="16" border="0"
        alt="Share/Save/Bookmark"/></a>
<script type="text/javascript" src="/default/js/a2a.js"></script>
	</xsl:element>
</xsl:template>

<xsl:template match="div[@class='view-larger-map']">
<div class="view-larger-map">
<img width="298" height="24" src="/images/misc/map_header.gif"/>
<img width="10" height="11" src="/images/misc/right_arrow.gif" class="map_hdr_arrow"/> 
<a href="/map/?ark={$ark}">View larger map/directions</a>
</div>
</xsl:template>

<xsl:template match="img[@class='map1']">
<xsl:variable name="mapURL" >
<xsl:text>http://maps.google.com/staticmap?size=313x200&amp;key=</xsl:text>
<xsl:text>ABQIAAAAPZhPbFDgyqqKaAJtfPgdhRQxAnOebRR8qqjlEjE1Y4ZOeQ67yxSVDP1Eq9oU2BZjw2PaheQ5prTXaw</xsl:text>
<xsl:text>&amp;markers=</xsl:text>
<xsl:apply-templates select="$repodata" mode="repo-marker"/>
<xsl:text>,blue&amp;zoom=9</xsl:text>
</xsl:variable>
	<a href="/map/?ark={$ark}">
	<img class="map1" height="200" width="313" border="0" src="{$mapURL}"/>
	</a>
</xsl:template>

<xsl:template match="*[@class='institution-name']">
<div class="institution-name"><xsl:value-of select="$Institution.filtered.reversed"/></div>
</xsl:template>

<xsl:template match="*[@class='institution-left']">
<xsl:comment><xsl:value-of select="$djUrl"/></xsl:comment>
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>

<xsl:apply-templates select="$repodata" mode="repo-address"/>

	</xsl:element>
</xsl:template>

<xsl:template match="div" mode="repo-address">
	<div>
	<xsl:apply-templates mode="repo-address"/>
	</div>
</xsl:template>

<xsl:template match="a" mode="repo-address">
<a href="{@href}"><xsl:value-of select="."/></a>
</xsl:template>

<xsl:template match="div" mode="repo-marker">
<xsl:value-of select="@latitude"/>
<xsl:text>,</xsl:text>
<xsl:value-of select="@longitude"/>
</xsl:template>

<xsl:template match="*[@class='institution-right']">
        <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
	
<xsl:choose>
	<xsl:when test="$page/crossQueryResult/facet[@field='facet-institution']/group[starts-with($Institution,@value)]/@totalSubGroups &lt;= 1 "/>
<xsl:otherwise>
	<div class="institution-results">Contributing institutions on campus: <xsl:value-of select="$page/crossQueryResult/facet[@field='facet-institution']/group[starts-with($Institution,@value)]/@totalSubGroups"/></div>
</xsl:otherwise>
</xsl:choose>
		<xsl:if test="$onlineItemCount">
			<div class="institution-results">
				Collections with online items: <xsl:value-of select="$onlineItemCount"/>
			</div>
		</xsl:if>
			<div class="institution-results">
				Physical collections: <xsl:value-of select="$page/crossQueryResult/@totalDocs"/>
			</div>
	</xsl:element>
</xsl:template>

<!-- null copy template -->
<xsl:template match="*[@tmpl:insert='browse-search']">
  <xsl:element name="{name()}">
        <xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='title']">
  <xsl:element name="{name()}">
        <xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
        <xsl:value-of select="$Institution.filtered.reversed"/>
	<xsl:text>, </xsl:text>
	<xsl:apply-templates/>
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
