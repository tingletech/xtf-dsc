<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
        xmlns:saxon="http://saxon.sf.net/"
        xmlns:xtf="http://cdlib.org/xtf"
        xmlns:date="http://exslt.org/dates-and-times"
        xmlns:parse="http://cdlib.org/xtf/parse"
	xmlns:mets="http://www.loc.gov/METS/"
	xmlns:m="http://www.loc.gov/METS/"
	xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:xlink="http://www.w3.org/TR/xlink"
	xmlns:ead="http://www.loc.gov/EAD/"
        xmlns:cdl="http://www.cdlib.org/"
	xmlns:decade="java:org.cdlib.dsc.util.FacetDecade"
  xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils"
        extension-element-prefixes="date"
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

  <xsl:import href="../../common/preFilterCommon.xsl"/>
  <xsl:import href="../../calisphere/preFilter.xsl"/>

<!-- upgrade MODS2 to MODS3; normalize xlink namespace -->
<xsl:import href="../../../../../mets-support/xslt/dc/common/upMods.xsl"/>

<xsl:output method="xml" indent="yes"/>

<xsl:variable name="unfiltered">
        <xsl:apply-templates mode="upMods"/>
</xsl:variable>
<xsl:variable name="page" select="/"/>
<xsl:variable name="docpath" select="base-uri($page)"/>
<xsl:variable name="base" select="substring-before($docpath, '.mets.xml')"/>

<xsl:template match="/">
        <xsl:apply-templates select="$unfiltered" mode="mets"/>
</xsl:template>


<!-- ====================================================================== -->
<!-- Default: identity transformation                                       -->
<!-- ====================================================================== -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->

  <xsl:template match="/*" mode="mets">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="m:fileSec//m:file[contains(@MIMETYPE,'mrsid')]">
      	<xsl:attribute name="mrSidHack" select="'needIt'"/>
      </xsl:if>
			<xsl:comment>get-meta</xsl:comment>
      <xsl:call-template name="get-meta"/>
      <xsl:call-template name="reference-image"/>
      <xsl:comment>zoom</xsl:comment>
      <xsl:call-template name="zoom"/>
      <xsl:comment>mets</xsl:comment>
      <xsl:apply-templates mode="mets"/>
    </xsl:copy>
  </xsl:template>

<!-- ====================================================================== -->
<!-- METS Indexing                                                           -->
<!-- ====================================================================== -->

  <xsl:template match="mets:dmdSec[mets:mdWrap/mets:xmlData/mods:mods][position() &gt; 1]" mode="mets">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="innerMODS"/>
    </xsl:copy>
  </xsl:template>

	<xsl:template match="mods:*" mode="innerMODS">
			<xsl:variable name="name" select="name()"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
			<xsl:if test="$page/mets:mets/mets:dmdSec[mets:mdWrap/mets:xmlData/mods:mods][1]/mets:mdWrap/mets:xmlData/mods:mods/mods:*[name()=$name] = .">
				<xsl:attribute name="xtf:index" select="'no'"/>
			</xsl:if>
     	<xsl:apply-templates mode="innerMODS"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mets:fileSec[//mets:file/@ID='thumbnail']" mode="mets">
    <thumbnail xtf:meta="true"
	X="{/mets:mets/mets:structMap//mets:fptr[@FILEID='thumbnail']/@cdl:X}" 
	Y="{/mets:mets/mets:structMap//mets:fptr[@FILEID='thumbnail']/@cdl:Y}" 
	/>
    <xsl:copy>
      <xsl:copy-of select="@*|*"/>
    </xsl:copy>
  </xsl:template>

<!--							-->
<!--	recalculate ORDER for object viewer		-->
<!--							-->
  <xsl:template match="mets:div[@ORDER or @LABEL]" mode="mets"> 
	<mets:div ORDER="{(count(preceding::mets:div[@ORDER or @LABEL][mets:div] | ancestor::mets:div[@ORDER or @LABEL][mets:div]) + 1)}">
	<xsl:for-each select="@*[not(name()='ORDER')]">
	   <xsl:copy/>
	</xsl:for-each>
	<xsl:apply-templates mode="mets"/>
	</mets:div>
  </xsl:template>

  <!-- Ignored Elements -->
  
  <xsl:template match="*" mode="mets">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:index" select="'no'"/>
      <xsl:apply-templates mode="mets"/>
    </xsl:copy>
  </xsl:template>

<!-- ====================================================================== -->
<!-- Metadata Indexing                                                      -->
<!-- ====================================================================== -->

  <!-- Access Dublin Core Record -->
  <xsl:template name="get-meta">
    <xsl:variable name="dcpath" select="concat($base, '.dc.xml')"/>
    <xsl:variable name="dcdoc" select="document($dcpath)"/>
    <xsl:apply-templates select="($dcdoc)/qdc | ($dcdoc)/x/dc" mode="inmeta"/>
    <xsl:variable name="parent_ark">
	<xsl:value-of select="replace((($dcdoc)//relation[contains(.,'oac.cdlib.org/findaid/ark:/')])[1],'^.*ark:/','ark:/')"/>
    </xsl:variable>

    <xsl:call-template name="getGoodInfo"><!-- wsgi -->
	<xsl:with-param name="ark" select="/mets:mets/@OBJID"/>
	<xsl:with-param name="parent_ark" select="replace($parent_ark,'/$','')"/>
    </xsl:call-template>

<dateStamp xtf:meta="true" xtf:tokenize="no">
	<xsl:value-of 
		xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils"
		select="FileUtils:lastModified($docpath,'yyyy-MM-dd')"
	/>
</dateStamp>


  </xsl:template>

  <xsl:template match="*" mode="outmeta">
      <xsl:element name="{name()}">
        <xsl:attribute name="xtf:meta" select="'true'"/>
 	<xsl:apply-templates select="@*|node()"/>
      </xsl:element>
  </xsl:template>

  <xsl:template match="type" mode="outmeta">
      <type xtf:meta="true" xtf:wordBoost="0.000001">
        <xsl:apply-templates select="@*|node()"/>
      </type>
  </xsl:template>

  <xsl:template match="title[1]" mode="outmeta">
      <title xtf:meta="true" xtf:wordBoost="1.5">
        <xsl:apply-templates select="@*|node()"/>
      </title>
  </xsl:template>

  
  <!-- Process DC -->
  <xsl:template match="qdc|dc" mode="inmeta">
    <!-- boosts adjusted with outmeta  ... inmeta is what is read from the DC extractor -->
    <xsl:apply-templates select="*" mode="outmeta"/>
    <!-- sort fields -->
    <xsl:apply-templates select="title" mode="sort"/>    
    <xsl:apply-templates select="creator" mode="sort"/>
    <xsl:apply-templates select="date" mode="sort"/>
    <!-- derived fields added to DC in XTF -->
    <xsl:apply-templates select="(relation[contains(.,'oac.cdlib.org/findaid/ark:/')])[1]" mode="from"/>
    <!-- xsl:apply-templates select="(relation[starts-with(.,'ark:/')])[1]" mode="repository"/ -->
    <!-- xsl:apply-templates select="publisher[@q='repository']" mode="repository"/ -->
    <!-- create facet fields -->
    <xsl:apply-templates select="type" mode="facet"/>
    <xsl:apply-templates select="subject" mode="facet"/>
    <xsl:apply-templates select="coverage" mode="facet"/>

    <!-- xsl:apply-templates select="title" mode="facet"/>
    <xsl:apply-templates select="creator" mode="facet"/>
    <xsl:apply-templates select="description" mode="facet"/>
    <xsl:apply-templates select="publisher" mode="facet"/>
    <xsl:apply-templates select="contributor" mode="facet"/>
    <xsl:apply-templates select="date" mode="facet"/>
    <xsl:apply-templates select="format" mode="facet"/>
    <xsl:apply-templates select="identifier" mode="facet"/>
    <xsl:apply-templates select="source" mode="facet"/>
    <xsl:apply-templates select="language" mode="facet"/>
    <xsl:apply-templates select="relation" mode="facet"/>
    <xsl:apply-templates select="rights" mode="facet"/ -->

    <!-- AZ and Ethnic Browse for Calisphere and Cal Cultures -->
    <xsl:call-template name="createBrowse"/>
    
    <!-- Metadata Snippets for Calisphere and Cal Cultures -->
    <xsl:apply-templates select="creator|subject|description|publisher" mode="metaSnippets"/>
    <facet-onlineItems xtf:meta="true" xtf:facet="true">Items online</facet-onlineItems>

 <xsl:if test="date">
    <xsl:variable name="date">
	<xsl:value-of select="date"/>
    </xsl:variable>
    <xsl:variable name="decades">
    	<xsl:copy-of select="decade:facetDecade($date)"/>
    </xsl:variable>
    <xsl:if test="$decades != ''">
    	<xsl:apply-templates select="saxon:parse($decades)/decades/decade" mode="decade"/>
    </xsl:if>
 </xsl:if>


  </xsl:template>

        <xsl:template match="decade" mode="decade">
                <facet-decade xtf:meta="true" xtf:tokenize="no"><xsl:value-of select="."/></facet-decade>
        </xsl:template>

  <!-- generate sort-title -->
  <xsl:template match="title[1]" mode="sort">
    
    <xsl:variable name="title" select="string(.)"/>
 
    <sort-title>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:value-of select="parse:title($title)"/>
    </sort-title>
  </xsl:template>

  <!-- generate sort-creator -->
  <xsl:template match="creator[1]" mode="sort">
    
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
  <xsl:template match="date[1]" mode="sort">

    <xsl:variable name="date" select="string(.)"/>
    <xsl:variable name="pos" select="number(position())"/>
    
    <xsl:copy-of select="parse:year($date, $pos)"/>
    
  </xsl:template>

  <!-- parent finding aid -->
  <xsl:template match="relation" mode="from">
    <xsl:variable name="relLabel">
      <xsl:choose>
        <xsl:when test="../subject[@q='series']">
          <xsl:value-of select="../subject[@q='series'][1]"/>
        </xsl:when>
        <xsl:when test="../relation[not(contains(.,':/'))]">
          <xsl:value-of select="(../relation[not(contains(.,':/'))])[1]"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <relation-from q="collection" xtf:meta="true">
      <xsl:value-of select="replace(.,'^.*(http.*)$','$1')"/>
      <xsl:text>|</xsl:text>
      <xsl:value-of select="$relLabel"/>
    </relation-from>
    <facet-collection-title xtf:meta="true" xtf:tokenize="false">
      <xsl:value-of select="$relLabel"/>
    </facet-collection-title>
  </xsl:template>

	<xsl:template name="zoom">
		<xsl:variable name="jp2shadow" select="replace(replace($base,'/[^/]*$','/'),'/xtf/data/','/xtf/jp2shadow/')"/>
		<!-- xsl:message><xsl:value-of select="$base"/></xsl:message>
		<xsl:message><xsl:value-of select="$jp2shadow"/></xsl:message -->
		<xsl:if test="FileUtils:exists($jp2shadow)">
			<format q="x" xtf:meta="true">jp2</format>
		</xsl:if>
		<xsl:if test="$page/m:mets/m:fileSec/m:fileGrp[@USE='video/reference']">
			<format q="x" xtf:meta="true">qtvr</format>
		</xsl:if>
		<xsl:if test="$page/m:mets/m:dmdSec/m:mdWrap/m:xmlData/*[local-name()='mods']">
			<format q="x" xtf:meta="true">mods</format>
		</xsl:if>
    <!-- test for pdf -->
    <xsl:if test="$page/m:mets/m:fileSec//m:fileGrp[contains(@USE,'application')]/m:file[@MIMETYPE='application/pdf']">
			<format q="x" xtf:meta="true">pdf</format>
		</xsl:if>
  </xsl:template>

  <xsl:template name="reference-image">
  <xsl:apply-templates select="/m:mets/m:structMap/m:div/m:div[
    @LABEL='med-res' or @LABEL='hi-res' or starts-with(@TYPE,'reference')
                                             ][m:fptr/@cdl:X]" mode="reference-image"/>
  </xsl:template>

  <xsl:template match="m:div" mode="reference-image">
    <reference-image xtf:meta="true" X="{m:fptr/@cdl:X}" Y="{m:fptr/@cdl:Y}" src="/{/m:mets/@OBJID}/{m:fptr/@FILEID}"/>
  </xsl:template>

</xsl:stylesheet>
