<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
        xmlns:saxon="http://saxon.sf.net/"
        xmlns:xtf="http://cdlib.org/xtf"
        xmlns:date="http://exslt.org/dates-and-times"
        xmlns:parse="http://cdlib.org/xtf/parse"
        xmlns:mets="http://www.loc.gov/METS/"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
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
<!-- Variables                                                              -->
<!-- ====================================================================== -->
  
  <xsl:variable name="docpath" select="saxon:system-id()"/>
  <xsl:variable name="base" select="substring-before($docpath, '_djvu.txt')"/>
  <xsl:variable name="metapath" select="concat($base, '.dc.xml')"/>
  <xsl:variable name="marcxml" select="concat($base, '.marc.xml')"/>
  
<!-- ====================================================================== -->
<!-- Metadata Indexing                                                      -->
<!-- ====================================================================== -->

  <!-- Access Metadata Record -->
  <xsl:template name="get-meta">
    <xtf:meta>
      <xsl:apply-templates select="document($metapath)//*[local-name()='dc']" mode="inmeta"/>
      <xsl:apply-templates select="document($marcxml)//*[local-name()='record']" mode="mergeid"/>			
      <!-- Record metadata and/or text origin -->
      <origin xtf:meta="true">
        <xsl:value-of select="'OCA'"/>
      </origin>
    </xtf:meta>
  </xsl:template>
  
  <!-- Process DC -->
  <xsl:template match="*[local-name()='dc']" mode="inmeta">
    
    <!-- metadata fields -->
    
    <!-- dc:title -> title-main -->
    <xsl:for-each select="dc:title">
      <xsl:variable name="title-string" select="string(.)"/>
      <title-main xtf:meta="true">
        <xsl:value-of select="$title-string"/>
      </title-main>		
      <merge-title xtf:meta="true" xtf:tokenize="no" xtf:index="yes">
        <xsl:value-of select="parse:merge-title($title-string)"/>
      </merge-title>
    </xsl:for-each>
    
    <!-- dc:creator -> author -->
    <xsl:for-each select="dc:creator">
      <xsl:variable name="creator-string" select="replace(., '\s+', ' ')"/>
      <author xtf:meta="true">
        <xsl:value-of select="$creator-string"/>
      </author>	
      <merge-author xtf:meta="true" xtf:tokenize="no" xtf:index="yes">
        <xsl:analyze-string select="lower-case(replace($creator-string, '\.', ''))" regex="(.+?), ([^,]+)">
          <xsl:matching-substring>
            <xsl:value-of select="regex-group(1)"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="regex-group(2)"/>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </merge-author>
    </xsl:for-each>
    
    <!-- dc:subject -> subject -->
    <xsl:for-each select="dc:subject">
      <subject xtf:meta="true">
        <xsl:value-of select="string(.)"/>
      </subject>
    </xsl:for-each>
    
    <!-- dc:type -> format -->
    <xsl:for-each select="dc:type">
      <format xtf:meta="true">
        <xsl:value-of select="string(.)"/>
      </format>
    </xsl:for-each>
    
    <!-- dc:publisher -> publisher -->
    <xsl:for-each select="dc:publisher">
      <publisher xtf:meta="true">
        <xsl:value-of select="string(.)"/>
      </publisher>
    </xsl:for-each>
    
    <!-- dc:language -> language -->
    <xsl:for-each select="dc:language">
      <language xtf:meta="true">
        <xsl:value-of select="string(.)"/>
      </language>
    </xsl:for-each>
    
    <!-- dc:description -> note -->
    <xsl:for-each select="dc:description">
      <note xtf:meta="true">
        <xsl:value-of select="string(.)"/>
      </note>
    </xsl:for-each>
    
    <!-- filename -> sysID -->
    <xsl:variable name="root" select="replace($base, '.*/', '')"/>
    <sysID xtf:meta="true">
      <xsl:value-of select="$root"/>
    </sysID>
    <sort-sysid xtf:meta="true" xtf:tokenize="no">
      <xsl:value-of select="$root"/>
    </sort-sysid>

    <!-- create sort fields -->
    <xsl:apply-templates select="dc:title[1]" mode="sort"/>    
    <xsl:apply-templates select="dc:creator[1]" mode="sort"/>
    <xsl:apply-templates select="dc:date[1]" mode="sort"/>
    
  </xsl:template>
  
  <xsl:template match="*[local-name()='record']" mode="mergeid">
    
    <xsl:for-each select="*[local-name()='datafield'][@tag=035]">
      <xsl:variable name="M035a" select="string(*[local-name()='subfield'][@code='a'])"/>
      <merge-id>
        <xsl:attribute name="xtf:meta" select="'true'"/>
        <xsl:attribute name="xtf:tokenize" select="'no'"/>
        <xsl:attribute name="xtf:index" select="'yes'"/>
        <xsl:choose>
          <xsl:when test="contains($M035a, '(OCoLC)ocm')">
            <xsl:value-of select="substring-after($M035a, '(OCoLC)ocm')"/>
          </xsl:when>
          <xsl:when test="contains($M035a, '(OCoLC)')">
            <xsl:value-of select="substring-after($M035a, '(OCoLC)')"/>
          </xsl:when>
          <xsl:when test="contains($M035a, 'ocm')">
            <xsl:choose>
              <xsl:when test="contains($M035a, ' ')">
                <xsl:value-of select="substring-before(substring-after($M035a, 'ocm'), ' ')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="substring-after($M035a, 'ocm')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
        <xsl:text> (OCLC)</xsl:text>
      </merge-id>
    </xsl:for-each>
    
    <xsl:for-each select="*[local-name()='datafield'][@tag=901]">
      <merge-id>
        <xsl:attribute name="xtf:meta" select="'true'"/>
        <xsl:attribute name="xtf:tokenize" select="'no'"/>
        <xsl:attribute name="xtf:index" select="'yes'"/>
        <xsl:value-of select="concat(*[local-name()='subfield'][@code='b'][1], ' (',*[local-name()='subfield'][@code='a'],')')"/>
      </merge-id>
    </xsl:for-each>
    
  </xsl:template>
  
  <!-- generate sort-title -->
  <xsl:template match="dc:title" mode="sort">
    
    <xsl:variable name="title" select="string(.)"/>
    
    <sort-title>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:value-of select="parse:title($title)"/>
    </sort-title>
  </xsl:template>
  
  <!-- generate sort-author -->
  <xsl:template match="dc:creator" mode="sort">
    
    <xsl:variable name="creator" select="replace(string(.), '\s+', ' ')"/>
    
    <xsl:if test="number(position()) = 1">
      <sort-author>
        <xsl:attribute name="xtf:meta" select="'true'"/>
        <xsl:attribute name="xtf:tokenize" select="'no'"/>
        <xsl:value-of select="parse:name($creator)"/>
      </sort-author>
    </xsl:if>
    
  </xsl:template>
  
  <!-- generate year, range, and sort-year -->
  <xsl:template match="dc:date" mode="sort">
    
    <xsl:variable name="date" select="string(.)"/>
    <xsl:variable name="pos" select="number(position())"/>
    
    <xsl:copy-of select="parse:year($date, $pos)"/>
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
