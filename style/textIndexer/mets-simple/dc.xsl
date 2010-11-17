<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
        xmlns:saxon="http://saxon.sf.net/"
        xmlns:xtf="http://cdlib.org/xtf"
        xmlns:date="http://exslt.org/dates-and-times"
        xmlns:parse="http://cdlib.org/xtf/parse"
        xmlns:mets="http://www.loc.gov/METS/"
        xmlns:mods="http://www.loc.gov/mods/v3"
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

  <xsl:template match="mets:xmlData" mode="dc">
    
    <xsl:for-each select="dc:*">
      <xsl:element name="{local-name()}">
        <xsl:attribute name="xtf:meta" select="'true'"/>
        <xsl:copy-of select="@*"/>
        <xsl:value-of select="string()"/>
      </xsl:element>
    </xsl:for-each>

    <!-- sort fields -->
    <xsl:apply-templates select="dc:title[1]" mode="sort"/>

    <!-- create facet fields -->
    <xsl:for-each select="dc:*[local-name() ne 'type'] | dc:type[1]">
      <xsl:variable name="prefixless">
        <xsl:element name="{local-name(.)}">
          <xsl:copy-of select="@* | node()"/>
        </xsl:element>
      </xsl:variable>
      <xsl:apply-templates select="$prefixless" mode="facet"/>
    </xsl:for-each>
    <facet-type-tab xtf:meta="true" xtf:tokenize="no">website</facet-type-tab>
    
  </xsl:template>

  <!-- generate sort-title -->
  <xsl:template match="dc:title[1]" mode="sort">

    <xsl:variable name="title" select="string(.)"/>

    <sort-title>
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:value-of select="parse:title($title)"/>
    </sort-title>
  </xsl:template>


  
</xsl:stylesheet>
