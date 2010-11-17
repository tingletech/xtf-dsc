<?xml version="1.0"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xtf="http://cdlib.org/xtf"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:parse="http://cdlib.org/xtf/parse"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:mods="http://www.loc.gov/mods/v3"
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
  
  <xsl:import href="../common/preFilterCommon.xsl"/>
	<!-- xsl:import href="../calisphere/preFilter.xsl"/ -->
  <xsl:import href="dc.xsl"/>  
  
  <xsl:output indent="yes" method="xml"/>
  
  <xsl:template match="/">
    <empty-doc xmlns:dc="http://purl.org/dc/elements/1.1/">
      <xsl:apply-templates select="mets:mets/mets:dmdSec/mets:mdWrap[@MDTYPE='DC']/mets:xmlData" mode="dc"/>
      <xsl:apply-templates select="mets:mets/mets:dmdSec/mets:mdWrap[@MDTYPE='MODS']/mets:xmlData/mods:mods/mods:targetAudience[starts-with(@authority,'clrn_')]" mode="clrn"/>
      <xsl:choose>
        <xsl:when test="not(mets:mets/mets:dmdSec/mets:mdWrap[@MDTYPE='MODS']/mets:xmlData/mods:mods/mods:targetAudience[starts-with(@authority,'clrn_')])">
	<clrn_rated xtf:meta="true" xtf:tokenize="no">not rated</clrn_rated>
        </xsl:when>
        <xsl:otherwise>
	<clrn_rated xtf:meta="true" xtf:tokenize="no">rated</clrn_rated>
	<xsl:for-each select="mets:mets/mets:dmdSec/mets:mdWrap[@MDTYPE='DC']/mets:xmlData/dc:subject[contains(.,'::')]">
		<clrn_subject xtf:meta="true" xtf:tokenize="no"><xsl:value-of select="."/></clrn_subject>
  </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
	  <!-- AZ and Ethnic Browse for Calisphere and Cal Cultures -->
    <!-- xsl:call-template name="createBrowse"/ -->
    </empty-doc>
  </xsl:template>

  <xsl:template match="mods:targetAudience" mode="clrn">
	<xsl:variable name="authority" select="@authority"/>
  <xsl:for-each select="tokenize(.,',')">
		<xsl:element name="{$authority}">
	 		<xsl:attribute name="xtf:meta" select="'true'"/>
     	<xsl:attribute name="xtf:tokenize" select="'no'"/>
	 		<xsl:value-of select="normalize-space(.)"/>
		</xsl:element>
	</xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

