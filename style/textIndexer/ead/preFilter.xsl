<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
        xmlns:saxon="http://saxon.sf.net/"
        xmlns:xtf="http://cdlib.org/xtf"
        xmlns:date="http://exslt.org/dates-and-times"
        xmlns:parse="http://cdlib.org/xtf/parse"
	xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/TR/xlink"
	xmlns:ead="http://www.loc.gov/EAD/"
	xmlns:sql="java:/net.sf.saxon.sql.SQLElementFactory"
	xmlns:cdlpath="http://www.cdlib.org/path/"
	xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils"
	xmlns:HumanFileSize="java:org.cdlib.dsc.util.HumanFileSize"
        extension-element-prefixes="date sql"
        exclude-result-prefixes="#all">

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

<!-- ====================================================================== -->
<!-- Import Common Templates and Functions                                  -->
<!-- ====================================================================== -->

  <xsl:import href="../common/preFilterCommon.xsl"/>
  <xsl:import href="../calisphere/preFilter.xsl"/>
	<!-- xsl:import href="http://voro.cdlib.org:8081/xslt/institution-ark2url.xsl"/ -->

<xsl:output indent="yes"/>

<!-- ====================================================================== -->
<!-- keys                                                                   -->
<!-- ====================================================================== -->

<xsl:key 
	name="c01nav" 
	match="c01[@id][@level='series'] | c01[@id][@level='collection'] | c01[@id][@level='recordgrp'] | c01[@id][@level='subseries']
	       | c01[@id][level='subgrp'] | c01[@id][@level='subfonds'] | c01[@id][@level='fonds']"
	use="@id | child::*/@id"
/>

<xsl:key 
	name="c02nav" 
	match="c02[@id][@level='series'] | c02[@id][@level='collection'] | c02[@id][@level='recordgrp'] | c02[@id][@level='subseries']
	       | c02[@id][level='subgrp'] | c02[@id][@level='subfonds'] | c02[@id][@level='fonds']"
	use="@id | child::*/@id"
/>


<!-- ====================================================================== -->
<!-- variables                                                              -->
<!-- ====================================================================== -->
  <xsl:variable name="docpath" select="saxon:system-id()"/>
    <xsl:variable name="base" select="substring-before($docpath, '.xml')"/>
    <xsl:variable name="dcpath" select="concat($base, '.dc.xml')"/>
    <xsl:variable name="metspath" select="concat($base, '.mets.xml')"/>
    <xsl:variable name="dcdoc" select="document($dcpath)"/>
    <xsl:variable name="metsdoc" select="document($metspath)"/>

	<xsl:variable name="extent" select="($metsdoc)//ead:extent[@type='dao']"/>

	<xsl:variable name="parent_ark" select="/ead/eadheader/eadid/@cdlpath:parent"/>

<!-- ====================================================================== -->
<!-- Default: identity transformation                                       -->
<!-- ====================================================================== -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <!-- xsl:apply-templates select="@*|node()"/ -->
	<xsl:copy-of select="@*"/>
  <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->

  <xsl:template match="ead">
    <ead xmlns:xtf="http://cdlib.org/xtf" xmlns:cdlpath="http://www.cdlib.org/path/">
      <xsl:namespace name="xtf">http://cdlib.org/xtf</xsl:namespace>
      <xsl:namespace name="cdlpath">http://www.cdlib.org/path/</xsl:namespace>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="get-meta"/>
      <xsl:apply-templates select="*" mode="fu"/>
      <heads><xsl:apply-templates select="archdesc/dsc" mode="dsc-headers"/></heads>
    </ead>
  </xsl:template>

<!-- ====================================================================== -->
<!-- EAD dsc headers                                                        -->
<!-- ====================================================================== -->

<xsl:template match="dsc" mode="dsc-headers">
	<div cid="{@id}" class="dsc">
		<xsl:value-of select="
			if (head) then normalize-space(head) 
			else if (did/unittitle) then normalize-space(did/unittitle)
			else 'Collection Contents'
		"/></div>
	<xsl:apply-templates select="c01" mode="dsc-headers"/>
</xsl:template>

<xsl:template 
	match="c01[@id][@level='series'] | c01[@id][@level='collection'] | c01[@id][@level='recordgrp'] | c01[@id][@level='subseries'] 
		| c01[@id][@level='subgrp'] | c01[@id][@level='fonds'] | c01[@id][@level='subfonds']" 
	mode="dsc-headers">
	<div cid="{@id}" class="c01" apropos="{@id | child::*/@id}">
		<xsl:if test="@C-ORDER">
			<xsl:attribute name="C-ORDER" select="@C-ORDER"/>
		</xsl:if>
		<xsl:value-of 
			select="if (did/unittitle) then normalize-space(did/unittitle[1])
				else if (did/head) then normalize-space(did/head[1])
				else 'no label supplied'"
		/>
	</div>
	<xsl:apply-templates select="c02" mode="dsc-headers"/>
</xsl:template>

<xsl:template 
	match="c02[@id][@level='series'] | c02[@id][@level='collection'] | c02[@id][@level='recordgrp'] | c02[@id][@level='subseries']
		| c02[@id][@level='subgrp'] | c02[@id][@level='fonds'] | c02[@id][@level='subfonds']" 
	mode="dsc-headers">
	<div cid="{@id}" class="c02" apropos="{@id | child::*/@id}">
		<xsl:if test="@C-ORDER">
			<xsl:attribute name="C-ORDER" select="@C-ORDER"/>
		</xsl:if>
		<xsl:apply-templates select="did/unittitle | did/head" mode="ead-dsc"/>
	</div>
</xsl:template>

<xsl:template match="*" mode="dsc-headers"/>

<xsl:template match="unittitle| unitdate"  mode="ead-dsc">
<xsl:value-of select="normalize-space(.)"/><xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="emph" mode="ead">
  <xsl:choose>
    <xsl:when test="@render">
  <span>
  <xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
  <xsl:apply-templates mode="ead"/>
  </span>
    </xsl:when>
    <xsl:otherwise><em><xsl:apply-templates mode="ead"/></em></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ====================================================================== -->
<!-- EAD Indexing                                                           -->
<!-- ====================================================================== -->

  <!-- Ignored Elements -->
  
  <xsl:template match="eadheader" mode="fu">
    <xsl:copy>
      <xsl:namespace name="cdlpath">http://www.cdlib.org/path/</xsl:namespace>
      <xsl:copy-of select="@*"/>
      <!-- xsl:attribute name="xtf:index" select="'no'"/ -->
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Structural Indexing -->

  <xsl:template match="frontmatter" mode="fu">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:attribute name="xtf:sectionType">eadfrontmatter</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:copy>
  </xsl:template>

  <xsl:template match="archdesc" mode="fu">
	<xsl:copy>
		<xsl:attribute name="daoCount"><xsl:value-of select="count(//dao | //daogrp)"/></xsl:attribute>
		<xsl:attribute name="xtf:sectionType">eadarchdesc</xsl:attribute>
		<xsl:copy-of select="@*"/>
		<xsl:variable name="href-foo" select="(.//dao)[1]/@href"/>
		<xsl:if test="$href-foo != ''">
			<xsl:attribute name="first-dao-href" select="(.//dao)[1]/@href"/>
		</xsl:if>
		<!-- xsl:attribute name="eadFirstItemID"><xsl:value-of 
	select="(*//@id[../*/dao or ../*/daogrp])[1]"/></xsl:attribute -->
		<xsl:apply-templates/>
	</xsl:copy>
  </xsl:template>

  <xsl:template match="dsc">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:attribute name="xtf:sectionType">eaddsc</xsl:attribute>
		<!-- C-ORDER = component order -->
		<!-- C-ORDER can be added in more cheaply in pre-processing -->
		<xsl:if test="not(@C-ORDER)">
			<xsl:attribute name="C-ORDER">
        			<xsl:value-of select="count( preceding::dscgrp | ancestor::dscgrp | 
				preceding::dsc | ancestor::dsc | preceding::c | ancestor::c | 
				preceding::c01 | ancestor::c01 | preceding::c02 | ancestor::c02 | 
				preceding::c03 | ancestor::c03 | preceding::c04 | ancestor::c04 | 
				preceding::c05 | ancestor::c05 | preceding::c06 | ancestor::c06 | 
				preceding::c07 | ancestor::c07 | preceding::c08 | ancestor::c08 | 
				preceding::c09 | ancestor::c09 | preceding::c10 | ancestor::c10 | 
				preceding::c11 | ancestor::c11 | preceding::c12 | ancestor::c12) 
				+ 1" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:copy>
  </xsl:template>

  <xsl:template match="dscgrp|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<!-- C-ORDER = component order -->
		<!-- C-ORDER can be added in more cheaply in pre-processing -->
		<xsl:if test="not(@C-ORDER)">
			<xsl:attribute name="C-ORDER">
        			<xsl:value-of select="count( preceding::dscgrp | ancestor::dscgrp | 
				preceding::dsc | ancestor::dsc | preceding::c | ancestor::c | 
				preceding::c01 | ancestor::c01 | preceding::c02 | ancestor::c02 | 
				preceding::c03 | ancestor::c03 | preceding::c04 | ancestor::c04 | 
				preceding::c05 | ancestor::c05 | preceding::c06 | ancestor::c06 | 
				preceding::c07 | ancestor::c07 | preceding::c08 | ancestor::c08 | 
				preceding::c09 | ancestor::c09 | preceding::c10 | ancestor::c10 | 
				preceding::c11 | ancestor::c11 | preceding::c12 | ancestor::c12) 
				+ 1" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:copy>
  </xsl:template>

  <xsl:template match="*[did/daogrp] | *[did/dao] | *[did][daogrp] | *[did][dao]">
	<xsl:copy>
	<xsl:copy-of select="@*"/>
	  <xsl:attribute name="ORDER"><xsl:value-of select="
		count(
		  preceding::*[did/daogrp] | preceding::*[did/dao] | ancestor::*[did/dao] | ancestor::*[did/daogrp] |
		  preceding::*[did][daogrp] | preceding::*[did][dao] | ancestor::*[did][dao] | ancestor::*[did][daogrp] 
			) + 1"/></xsl:attribute>
		<!-- C-ORDER = component order -->
		<!-- C-ORDER can be added in more cheaply in pre-processing -->
		<xsl:if test="not(@C-ORDER)">
			<xsl:attribute name="C-ORDER">
        			<xsl:value-of select="count( preceding::dscgrp | ancestor::dscgrp | 
				preceding::dsc | ancestor::dsc | preceding::c | ancestor::c | 
				preceding::c01 | ancestor::c01 | preceding::c02 | ancestor::c02 | 
				preceding::c03 | ancestor::c03 | preceding::c04 | ancestor::c04 | 
				preceding::c05 | ancestor::c05 | preceding::c06 | ancestor::c06 | 
				preceding::c07 | ancestor::c07 | preceding::c08 | ancestor::c08 | 
				preceding::c09 | ancestor::c09 | preceding::c10 | ancestor::c10 | 
				preceding::c11 | ancestor::c11 | preceding::c12 | ancestor::c12) 
				+ 1" />
			</xsl:attribute>
		</xsl:if>
	  <xsl:apply-templates/>
	</xsl:copy>
  </xsl:template>

  <xsl:template match="unitid">
	<xsl:variable name="sectionType">
	<xsl:choose>
	  <xsl:when test="ancestor::dsc">eaddsc</xsl:when>
	  <xsl:otherwise>eadarchdesc</xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:attribute name="xtf:sectionType"><xsl:value-of select="$sectionType"/> unitid</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:copy>
  </xsl:template>

  <xsl:template match="archdesc/did/unittitle">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:attribute name="xtf:sectionType">eadarchdesc eadtitle</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:copy>
  </xsl:template>
	
  <xsl:template match="titleproper">
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:attribute name="xtf:sectionType">eadtitle</xsl:attribute>
		<xsl:attribute name="xtf:index">yes</xsl:attribute>
		<xsl:apply-templates/>
	</xsl:copy>
  </xsl:template>

<!-- ====================================================================== -->
<!-- Metadata Indexing                                                      -->
<!-- ====================================================================== -->

  <!-- Access Dublin Core Record -->
  <xsl:template name="get-meta">
    <oac4-tab xtf:meta="true" xtf:tokenize="false">Collections::ead</oac4-tab>

    <xsl:apply-templates select="($dcdoc)/qdc | ($dcdoc)/x/dc" mode="inmeta"/>
    <xsl:apply-templates select="$metsdoc" mode="inmets"/>

<xsl:variable name="pdfFile">
<xsl:value-of select="replace($base,'(.*/)[^/].*$','$1')"/>
<xsl:text>files/</xsl:text>
<xsl:value-of select="replace($base,'.*/','')"/>
<xsl:text>.pdf</xsl:text>
</xsl:variable>

<dateStamp xtf:meta="true" xtf:tokenize="no">
        <xsl:value-of
                xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils"
                select="FileUtils:lastModified($docpath,'yyyy-MM-dd')"
        />
</dateStamp>


<xsl:if test="FileUtils:exists($pdfFile)">
	<pdf-size xtf:meta="true"><xsl:value-of select="HumanFileSize:humanFileSize(FileUtils:length($pdfFile))"/></pdf-size>
</xsl:if>

	<xsl:call-template name="get-sql">
		<xsl:with-param name="parent_ark" select="$parent_ark"/>
		<xsl:with-param name="extent" select="$extent"/>
	</xsl:call-template>
  </xsl:template>

  <xsl:template match="parent" mode="inmeta">
	<parent xtf:meta="true">
    <xsl:for-each select="*">
	<xsl:copy-of select="."/>
    </xsl:for-each>
	</parent>
  </xsl:template>
  
  <!-- Process DC -->
  <xsl:template match="qdc | dc" mode="inmeta">
    <xsl:for-each select="*">
      <xsl:element name="{name()}">
        <xsl:attribute name="xtf:meta" select="'true'"/>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:element>
    </xsl:for-each>
    
    <xsl:apply-templates select="title" mode="sort"/>    
    <xsl:apply-templates select="creator" mode="sort"/>
    <xsl:apply-templates select="date[text()]" mode="facet"/>
    
    <!-- create facet fields -->
    <!-- xsl:apply-templates select="title" mode="facet"/ -->
    <xsl:apply-templates select="creator" mode="facet"/>
    <xsl:apply-templates select="subject" mode="facet"/>
    <xsl:apply-templates select="type" mode="facet"/>
    <xsl:apply-templates select="language" mode="facet"/>
    <xsl:apply-templates select="coverage" mode="facet"/>
    <!-- xsl:apply-templates select="format" mode="facet"/ -->
    <!-- xsl:apply-templates select="description" mode="facet"/ -->
    <!-- xsl:apply-templates select="publisher" mode="facet"/ -->
    <!-- xsl:apply-templates select="contributor" mode="facet"/ -->
    <!-- 
	xsl:apply-templates select="date" mode="facet"/>
    <xsl:apply-templates select="identifier" mode="facet"/>
    <xsl:apply-templates select="source" mode="facet"/>
    <xsl:apply-templates select="relation" mode="facet"/>
    <xsl:apply-templates select="rights" mode="facet"/ 
    -->
    <!-- Metadata Snippets for Calisphere and Cal Cultures -->
    <xsl:apply-templates select="creator|subject|description|publisher" mode="metaSnippets"/>
    
  </xsl:template>

  <!-- get extent from METS -->

  <xsl:template match="mets:mets" mode="inmets">
	<xsl:for-each select="($extent)">
	<extent xtf:meta="true"><xsl:value-of select="normalize-space(.)"/></extent>
	</xsl:for-each>
	<xsl:choose>
		<xsl:when test="not($extent)">
		<facet-onlineItems xtf:meta="true" xtf:facet="true">No items online</facet-onlineItems>
		</xsl:when>
		<xsl:otherwise>
		<facet-onlineItems xtf:meta="true" xtf:facet="true">Items online</facet-onlineItems>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>

  <!-- generate sort-title -->
  <xsl:template match="title" mode="sort">
    <xsl:variable name="title" select="string(.)"/>
 
    <sort-title>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:value-of select="parse:title($title)"/>
    </sort-title>
    <facet-titlesAZ xtf:meta="true" xtf:tokenize="no">
	<xsl:variable name="firstChar" select="upper-case(substring(parse:title($title),1,1))"/>
	<xsl:value-of select="if (matches($firstChar,'[A-Z]')) then $firstChar else '0'"/>
    </facet-titlesAZ>
    <facet-titlesAZ-limit xtf:meta="true" xtf:tokenize="no">
	<xsl:text>ead::</xsl:text>
	<xsl:variable name="firstChar" select="upper-case(substring(parse:title($title),1,1))"/>
	<xsl:value-of select="if (matches($firstChar,'[A-Z]')) then $firstChar else '0'"/>
    </facet-titlesAZ-limit>

	<xsl:if test="boolean($extent)">
    		<facet-titlesAZ-limit xtf:meta="true" xtf:tokenize="no">
			<xsl:text>online::</xsl:text>
			<xsl:variable name="firstChar" select="upper-case(substring(parse:title($title),1,1))"/>
			<xsl:value-of select="if (matches($firstChar,'[A-Z]')) then $firstChar else '0'"/>
    		</facet-titlesAZ-limit>
	</xsl:if>

  </xsl:template>

  <!-- generate sort-creator -->
  <xsl:template match="creator" mode="sort">
    
    <xsl:variable name="creator" select="string(.)"/>
    
    <xsl:if test="number(position()) = 1">
      <sort-creator>
        <xsl:attribute name="xtf:meta" select="'true'"/>
        <xsl:attribute name="xtf:tokenize" select="'no'"/>
        <xsl:copy-of select="parse:name($creator)"/>
      </sort-creator>
    </xsl:if>
    
  </xsl:template>
  
  <!-- generate year and sort-year -->
  <xsl:template match="date" mode="sort">

    <xsl:variable name="date" select="string(.)"/>
    <xsl:variable name="pos" select="number(position())"/>
    
    <xsl:copy-of select="parse:year($date, $pos)"/>
    
  </xsl:template>

</xsl:stylesheet>
