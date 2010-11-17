<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
        xmlns:saxon="http://saxon.sf.net/"
        xmlns:xtf="http://cdlib.org/xtf"
        xmlns:date="http://exslt.org/dates-and-times"
        xmlns:parse="http://cdlib.org/xtf/parse"
        xmlns:mets="http://www.loc.gov/METS/"
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
  
  <xsl:import href="../../../common/preFilterCommon.xsl"/>

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
      <xsl:call-template name="get-meta"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Turning off dictionary-building for the OCR text -->
  <xsl:template match="text-data">
    <xsl:copy>
      <xsl:attribute name="xtf:spell" select="'no'"/>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
<!-- ====================================================================== -->
<!-- Metadata Indexing                                                      -->
<!-- ====================================================================== -->

  <!-- Access Metadata Record -->
  <xsl:template name="get-meta">
    <xsl:variable name="docpath" select="saxon:system-id()"/>
    <xsl:variable name="base" select="substring-before($docpath, '.txt')"/>
    <xsl:variable name="metapath" select="concat($base, '.xml')"/>
    <xtf:meta>
      <xsl:apply-templates select="document($metapath)//oclc/record" mode="inmeta"/>			
      <!-- Record metadata and/or text origin -->
      <origin xtf:meta="true">
        <xsl:value-of select="'ESR'"/>
      </origin>
    </xtf:meta>
  </xsl:template>
  
  <!-- Process OCLC Record -->
  <xsl:template match="record" mode="inmeta">
    
    <xsl:variable name="sysID" select="string(pubdata/ftlink)"/>

    <xsl:variable name="real-journal">
      <xsl:choose>
        <xsl:when test="matches($sysID,'postprints')">yes</xsl:when>
        <xsl:otherwise>no</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- metadata fields -->
    
    <!-- title -> title-main -->
    <xsl:for-each select="title">
      <xsl:variable name="title-string" select="string(.)"/>
      <title-main xtf:meta="true">
        <xsl:value-of select="$title-string"/>
      </title-main>		
      <merge-title xtf:meta="true" xtf:tokenize="no" xtf:index="yes">
        <xsl:value-of select="parse:merge-title($title-string)"/>
      </merge-title>
    </xsl:for-each>
    
    <!-- author/* -> author -->
    <xsl:for-each select="author">
      <author xtf:meta="true">
        <xsl:value-of select="string(surname)"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="string(fname)"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="string(mname)"/>
      </author>	
      <merge-author xtf:meta="true" xtf:tokenize="no" xtf:index="yes">
        <xsl:value-of select="lower-case(replace(string(surname),'\.',''))"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="lower-case(replace(string(fname),'\.',''))"/>
        <xsl:if test="mname">
          <xsl:text> </xsl:text>
          <xsl:value-of select="lower-case(replace(string(mname),'\.',''))"/>
        </xsl:if>
      </merge-author>
    </xsl:for-each>
    
    <!-- author/aff -> author-aff -->
    <xsl:for-each select="author/aff">
      <author-aff xtf:meta="true">
        <xsl:value-of select="string(.)"/>
      </author-aff>
    </xsl:for-each>
    
    <!-- abstract/p -> note -->
    <xsl:for-each select="abstract">
      <note xtf:meta="true">
        <xsl:apply-templates select="p"/>
      </note>
    </xsl:for-each>

    <!-- journal -> title-journal (postprints only) -->
    <xsl:for-each select="pubdata/journal">
      <xsl:if test="$real-journal = 'yes'">
        <title-journal xtf:meta="true">
          <xsl:value-of select="string(.)"/>
        </title-journal>
      </xsl:if>
    </xsl:for-each>
 
    <!-- keyword -> subject -->
    <xsl:for-each select="pubdata/keyword">
      <subject xtf:meta="true">
        <xsl:value-of select="string(.)"/>
      </subject>
    </xsl:for-each>
    
    <!-- uid1 -> xlink -->
    <xsl:for-each select="pubdata/uid1">
      <xlink xtf:meta="true">
        <xsl:value-of select="string(.)"/>
      </xlink>
    </xsl:for-each>
    
    <!-- language -> language -->
    <xsl:for-each select="pubdata/language">
      <language xtf:meta="true">
      <xsl:choose>
        <xsl:when test="matches(text(), 'english')">
          <xsl:text>eng</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="string(.)"/>
        </xsl:otherwise>
      </xsl:choose>
      </language>
    </xsl:for-each>
    
    <!-- doctype -> format -->
    <xsl:for-each select="pubdata/doctype">
      <format xtf:meta="true">
        <xsl:value-of select="string(.)"/>
      </format>
    </xsl:for-each>
    
    <!-- issn -> identifier-issn -->
    <xsl:for-each select="pubdata/issn">
      <xsl:if test="string(.) != ''">
        <identifier-issn xtf:meta="true">
          <xsl:value-of select="string(.)"/>
        </identifier-issn>
        <merge-id xtf:meta="true" xtf:tokenize="no" xtf:index="yes">
          <xsl:value-of select="concat(string(.),' (ISSN)')"/>
        </merge-id>
      </xsl:if>
    </xsl:for-each>
    
    <!-- ftlink -> sysID -->
    <xsl:for-each select="pubdata/ftlink">
      <sysID xtf:meta="true">
        <xsl:value-of select="string(.)"/>
      </sysID>
    </xsl:for-each>

    <!-- create sort fields -->
    <xsl:apply-templates select="title[1]" mode="sort"/>    
    <xsl:apply-templates select="author[1]/surname" mode="sort"/>
    <xsl:apply-templates select="pubdata/pubdate[1]" mode="sort"/>
    <xsl:apply-templates select="pubdata/ftlink[1]" mode="sort"/>

  </xsl:template>
  
  <xsl:template match="p">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- generate sort-title -->
  <xsl:template match="title" mode="sort">
    
    <xsl:variable name="title" select="string(.)"/>
 
    <sort-title>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:value-of select="parse:title($title)"/>
    </sort-title>
  </xsl:template>

  <!-- generate sort-author -->
  <xsl:template match="surname" mode="sort">
    
    <xsl:variable name="author" select="string(.)"/>
    
    <xsl:if test="number(position()) = 1">
      <sort-author>
        <xsl:attribute name="xtf:meta" select="'true'"/>
        <xsl:attribute name="xtf:tokenize" select="'no'"/>
        <xsl:value-of select="string(.)"/>
      </sort-author>
    </xsl:if>
    
  </xsl:template>
  
   <!-- generate year, range, and sort-year -->
  <xsl:template match="pubdate" mode="sort">

    <xsl:variable name="date" select="string(.)"/>
    <xsl:variable name="pos" select="number(position())"/>
    
    <xsl:copy-of select="parse:year($date, $pos)"/>
  </xsl:template>
  
  <!-- generate sort-sysID -->
  <xsl:template match="ftlink" mode="sort">
    <sort-sysID>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:value-of select="string(.)"/>
    </sort-sysID>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Merge Title Parsing                                                    -->
  <!-- ====================================================================== -->
  
  <!-- Function to parse normalized titles out of dc:title -->  
  <xsl:function name="parse:merge-title">
    
    <xsl:param name="title"/>
    
    <!-- Normalize Spaces & Case-->
    <xsl:variable name="parse-title">
      <xsl:value-of select="translate(normalize-space($title), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
    </xsl:variable>
    
    <!-- Remove Leading Articles -->
    <xsl:choose>
      <xsl:when test="matches($parse-title, '^a ')">
        <xsl:value-of select="replace($parse-title, '^a (.+)', '$1')"/>
      </xsl:when>
      <xsl:when test="matches($parse-title, '^an ')">
        <xsl:value-of select="replace($parse-title, '^an (.+)', '$1')"/>
      </xsl:when>
      <xsl:when test="matches($parse-title, '^the ')">
        <xsl:value-of select="replace($parse-title, '^the (.+)', '$1')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$parse-title"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:function>  
  
</xsl:stylesheet>
