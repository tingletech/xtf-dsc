<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
        xmlns:saxon="http://saxon.sf.net/"
        xmlns:xtf="http://cdlib.org/xtf"
        xmlns:date="http://exslt.org/dates-and-times"
        xmlns:parse="http://cdlib.org/xtf/parse"
        xmlns:mets="http://www.loc.gov/METS/"
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
<xsl:output method="xml" indent="yes"/>
<!-- ====================================================================== -->
<!-- Variables                                                              -->
<!-- ====================================================================== -->
<xsl:variable name="docpath" select="base-uri(/)"/>
<xsl:variable name="base" select="substring-before($docpath, '.xml')"/>
    <xsl:variable name="dcpath" select="concat($base, '.dc.xml')"/>
    <xsl:variable name="dcdoc" select="document($dcpath)"/>
    <xsl:variable name="metspath" select="concat($base, '.mets.xml')"/>
    <xsl:variable name="metsdoc" select="document($metspath)"/>

<xsl:key name="file" match="mets:file" use="@ID"/>

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

  <xsl:template match="/*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="div1Count" select="count(//div1)"/>
      <xsl:call-template name="get-meta"/>
      <xsl:apply-templates/>
      <xsl:call-template name="getMETS"/>
			<xsl:call-template name="zoom"/>
    </xsl:copy>
  </xsl:template>

<!-- ====================================================================== -->
<!-- TEI Indexing                                                           -->
<!-- ====================================================================== -->

  <!-- Ignored Elements -->
  
  <xsl:template match="teiHeader">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:index" select="'no'"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- sectionType Indexing and Element Boosting -->
  
  <xsl:template match="head[parent::*[self::div1 or self::div2 or self::div3 or self::div4 or self::div5 or self::div6 or self::div7]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:sectionType" select="concat('head ', @type)"/>
      <xsl:attribute name="xtf:wordBoost" select="2.0"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="titlePart[ancestor::titlePage]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xtf:wordBoost" select="100.0"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
<!-- ====================================================================== -->
<!-- Metadata Indexing                                                      -->
<!-- ====================================================================== -->

  <!-- Access Dublin Core Record -->
  <xsl:template name="get-meta">
    <xtf:meta>
      <xsl:apply-templates select="($dcdoc)/qdc | ($dcdoc)/x/dc" mode="inmeta"/>

    <xsl:variable name="parent_ark">
        <xsl:value-of select="replace((($dcdoc)//relation[contains(.,'oac.cdlib.org/findaid/ark:/')])[1],'^.*ark:/','ark:/')"/>
    </xsl:variable>

    <xsl:call-template name="getGoodInfo"><!-- wsgi -->
        <xsl:with-param name="ark" select="($metsdoc)/mets:mets/@OBJID"/>
        <xsl:with-param name="parent_ark" select="$parent_ark"/>
    </xsl:call-template>

    </xtf:meta>
  </xsl:template>
  
  <!-- Process DC -->
  <xsl:template match="qdc | dc" mode="inmeta">
    <xsl:for-each select="*">
      <xsl:element name="{name()}">
        <xsl:attribute name="xtf:meta" select="'true'"/>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:element>
    </xsl:for-each>
    <xsl:call-template name="keywords"/>
    
    <xsl:apply-templates select="title" mode="sort"/>    
    <xsl:apply-templates select="publisher" mode="sort"/>
    <xsl:apply-templates select="date" mode="sort"/>
    <!-- derived fields added to DC in XTF -->
    <xsl:apply-templates select="(relation[contains(.,'oac.cdlib.org/findaid/ark:/')])[1]" mode="from"/>
    <!-- create facet fields -->
    <xsl:apply-templates select="title" mode="facet"/>
    <xsl:apply-templates select="creator" mode="facet"/>
    <xsl:apply-templates select="subject" mode="facet"/>
    <xsl:apply-templates select="description" mode="facet"/>
    <xsl:apply-templates select="publisher" mode="facet"/>
    <xsl:apply-templates select="contributor" mode="facet"/>
    <xsl:apply-templates select="date" mode="facet"/>
    <xsl:apply-templates select="type" mode="facet"/>
    <xsl:apply-templates select="format" mode="facet"/>
    <xsl:apply-templates select="identifier" mode="facet"/>
    <xsl:apply-templates select="source" mode="facet"/>
    <xsl:apply-templates select="language" mode="facet"/>
    <xsl:apply-templates select="relation" mode="facet"/>
    <xsl:apply-templates select="coverage" mode="facet"/>
    <xsl:apply-templates select="rights" mode="facet"/>

    <!-- AZ and Ethnic Browse for Calisphere and Cal Cultures -->
    <xsl:call-template name="createBrowse"/>
    
    <!-- Metadata Snippets for Calisphere and Cal Cultures -->
    <xsl:apply-templates select="creator|subject|description|publisher" mode="metaSnippets"/>

<dateStamp xtf:meta="true" xtf:tokenize="no">
        <xsl:value-of
                xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils"
                select="FileUtils:lastModified($docpath,'yyyy-MM-dd')"
        />
</dateStamp>

    
  </xsl:template>
  
  <xsl:template match="xsubject|ntitle|lastmod" mode="inmeta">
    <xsl:element name="{name()}">
      <xsl:attribute name="xtf:index" select="'no'"/>
      <xsl:value-of select="string()"/>
    </xsl:element>    
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

  <!-- generate sort-publisher -->
  <xsl:template match="publisher" mode="sort">
    
    <xsl:variable name="publisher" select="string(.)"/>
    
    <xsl:if test="number(position()) = 1">
      <sort-publisher>
        <xsl:attribute name="xtf:meta" select="'true'"/>
        <xsl:attribute name="xtf:tokenize" select="'no'"/>
        <xsl:copy-of select="parse:title($publisher)"/>
      </sort-publisher>
    </xsl:if>
    
  </xsl:template>
  
  <!-- generate year and sort-year -->
  <xsl:template match="date" mode="sort">

    <xsl:variable name="date" select="string(.)"/>
    <xsl:variable name="pos" select="number(position())"/>
    
    <xsl:copy-of select="parse:year($date, $pos)"/>
    
  </xsl:template>

  <!-- keywords "index" -->
  <xsl:template name="keywords">
    <keywords xtf:meta="true">
      <xsl:apply-templates select="." mode="bogus"/>
    </keywords>
  </xsl:template>

<!-- ====================================================================== -->
<!-- insert METS for compount TEI/METS                                      -->
<!-- ====================================================================== -->


  <xsl:template name="getMETS">
    <xsl:if test="$metsdoc/mets:mets/mets:fileSec//mets:file[@ID='thumbnail']">
      <xsl:apply-templates select="$metsdoc" mode="upMetsTeiHybrid"/>
    </xsl:if>
	  <xsl:if test="$metsdoc/mets:mets/mets:dmdSec/mets:mdWrap/mets:xmlData/*[local-name()='mods']">
      <format q="x" xtf:meta="true">mods</format>
    </xsl:if>
  </xsl:template>

  <!--                                                    -->
  <!--    identity for the external METS file             -->
  <!--                                                    -->

  <xsl:template match="@*|node()" mode="upMetsTeiHybrid">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="upMetsTeiHybrid"/>
    </xsl:copy>
  </xsl:template>

  <!--                                                    -->
  <!--    buff up the first structMap                     -->
  <!--                                                    -->

  <xsl:template match="mets:structMap[1]" mode="upMetsTeiHybrid">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="structMap1up"/>
    </xsl:copy>
  </xsl:template>

  <!--                                                    -->
  <!--    recalculate ORDER for object viewer             -->
  <!--                                                    -->

  <xsl:template match="mets:div[@ORDER or @LABEL]" mode="structMap1up">
    <mets:div ORDER="{(count(preceding::mets:div[@ORDER or @LABEL] | ancestor::mets:div[@ORDER or @LABEL]) + 1)}">
      <xsl:for-each select="@*[not(name()='ORDER')]">
         <xsl:copy/>
      </xsl:for-each>
      <xsl:apply-templates mode="structMap1up"/>
    </mets:div>
  </xsl:template>

  <!--                                                    -->
  <!--    insert some more divs                           -->
  <!--                                                    -->

  <xsl:template match="mets:fptr" mode="structMap1up">
    <xsl:if test="not(contains(key('file',@FILEID)/../@USE, 'tei' ))">
      <mets:div>
      <xsl:attribute name="TYPE">
        <xsl:value-of select="key('file',@FILEID)/../@USE"/>
      </xsl:attribute>
      <mets:fptr>
        <xsl:for-each select="@*">
        <xsl:copy-of select="."/>
        </xsl:for-each>
      </mets:fptr>
      </mets:div>
    </xsl:if>
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
      <xsl:value-of select="."/>
      <xsl:text>|</xsl:text>
      <xsl:value-of select="$relLabel"/>
    </relation-from>
  </xsl:template>

  <xsl:template name="zoom">
    <xsl:variable name="jp2shadow" select="replace(replace($base,'/[^/]*$','/'),'/xtf/data/','/var/jp2shadow/')"/>
    <!-- xsl:message><xsl:value-of select="$jp2shadow"/></xsl:message -->
    <xsl:if test="FileUtils:exists($jp2shadow)">
      <format q="x" xtf:meta="true">jp2</format>
    </xsl:if>

  </xsl:template>



</xsl:stylesheet>
