<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
        xmlns:saxon="http://saxon.sf.net/"
        xmlns:xtf="http://cdlib.org/xtf"
        xmlns:date="http://exslt.org/dates-and-times"
        xmlns:parse="http://cdlib.org/xtf/parse"
        xmlns:mets="http://www.loc.gov/METS/"
        extension-element-prefixes="date"
        exclude-result-prefixes="#all">

<!--
   Copyright (c) 2006, Regents of the University of California
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


  <xsl:import href="Browse.xsl"/>

  <xsl:param name="BACK_SERVER" select="System:getenv('BACK_SERVER')" xmlns:System="java:java.lang.System"/>
  <xsl:param name="wsgiConnect.href" select="concat('http://',$BACK_SERVER,'/wsgi/ois_service.wsgi')"/>

  <!-- calisphere A-Z browse data -->
  <xsl:variable name="azBrowseDoc" select="document('azBrowse_maps.xml')"/>

  <!-- calcultures ethnic browse -->
  <xsl:variable name="ethBrowseDoc" select="document('ethBrowse_maps.xml')"/>

  <!-- jarda browse -->
  <xsl:variable name="jardaBrowseDoc" select="document('jardaBrowse_maps.xml')"/>

  <xsl:variable name="docpath" select="base-uri(/)"/>
  <xsl:variable name="base" select="substring-before(replace($docpath,'.mets',''), '.xml')"/>
  <xsl:variable name="dcpath" select="concat($base, '.dc.xml')"/>
  <xsl:variable name="dcdoc" select="document($dcpath)"/>

  <xsl:variable name="keywords">
    <xsl:for-each select="$dcdoc/*">
      <xsl:value-of select="string(.)"/>
      <xsl:text> </xsl:text>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template name="createBrowse">
    <xsl:call-template name="Browse">
      <xsl:with-param name="keywords" select="$keywords"/>
      <xsl:with-param name="subject" select="subject"/>
      <xsl:with-param name="mapDoc" select="$azBrowseDoc"/>
      <xsl:with-param name="elementNamePrefix" select="'azBrowse'"/>
    </xsl:call-template>
    <xsl:call-template name="Browse">
      <xsl:with-param name="keywords" select="$keywords"/>
      <xsl:with-param name="subject" select="subject"/>
      <xsl:with-param name="mapDoc" select="$ethBrowseDoc"/>
      <xsl:with-param name="elementNamePrefix" select="'ethBrowse'"/>
    </xsl:call-template>
    <xsl:call-template name="Browse">
      <xsl:with-param name="keywords" select="$keywords"/>
      <xsl:with-param name="subject" select="subject"/>
      <xsl:with-param name="mapDoc" select="$jardaBrowseDoc"/>
      <xsl:with-param name="elementNamePrefix" select="'jardaBrowse'"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Special type-tab facet for Calisphere and Calcultures -->
  <xsl:template match="type" mode="facet"> 
    <xsl:variable name="name">
      <xsl:choose>
        <!-- To disambiguate types -->
        <xsl:when test="position() = 1">
          <xsl:value-of select="'facet-type-tab'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'facet-type'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="value">
      <xsl:choose>
        <xsl:when test="position() = 1">
          <xsl:choose>
            <xsl:when test="matches(.,'mixed','i')">
              <xsl:value-of select="'mixed'"/>
            </xsl:when>
            <xsl:when test="matches(.,'image|cartographic|three','i')">
              <xsl:value-of select="'image'"/>
            </xsl:when>
            <xsl:when test="matches(.,'text','i')">
              <xsl:value-of select="'text'"/>
            </xsl:when>
            <xsl:when test="matches(.,'website','i')">
              <xsl:value-of select="'website'"/>
            </xsl:when>
            <xsl:when test="matches(.,'archival collection','i')">
              <xsl:value-of select="'archival collection'"/>
              </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'OTHER'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="replace(string(.), '&quot;', '')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$value = 'mixed'">
        <facet-type-tab xtf:meta="true" xtf:tokenize="no">image</facet-type-tab>
        <facet-type-tab xtf:meta="true" xtf:tokenize="no">text</facet-type-tab>
        <facet-oac-tab xtf:meta="true" xtf:tokenize="no">digital item</facet-oac-tab>
				<if test="position() = 1">
					<oac4-tab xtf:meta="true" xtf:tokenize="no">Items::image</oac4-tab>
					<oac4-tab xtf:meta="true" xtf:tokenize="no">Items::text</oac4-tab>
				</if>
      </xsl:when>
      <xsl:when test="not($value = 'OTHER') and not($value= 'archival collection')">
        <xsl:element name="{$name}">
          <xsl:attribute name="xtf:meta" select="'true'"/>
          <xsl:attribute name="xtf:tokenize" select="'no'"/>
          <xsl:choose>
            <xsl:when test="normalize-space() = ''">
              <xsl:value-of select="'1 EMPTY'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$value"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
				<xsl:if test="position() = 1">
					<oac4-tab xtf:meta="true" xtf:tokenize="no">Items::<xsl:value-of select="$value"/></oac4-tab>
				</xsl:if>
        <xsl:if test="$name = 'facet-type-tab'">
        <facet-oac-tab xtf:meta="true" xtf:tokenize="no">
							<xsl:text>digital item</xsl:text>
        </facet-oac-tab>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise><!-- mush be an archival collection? -->
        <facet-oac-tab xtf:meta="true" xtf:tokenize="no">archival collection</facet-oac-tab>
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:template>
  
  <!-- Metadata Snippets for Calisphere and Calcultures -->
  <xsl:template match="*" mode="metaSnippets">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- look up good institution data from an external service -->
  <xsl:template name="getGoodInfo">
    <xsl:param name="ark"/>
    <xsl:param name="parent_ark"/>

    <xsl:variable name="daoinfoURL">
	<xsl:value-of select="$wsgiConnect.href"/>
	<xsl:text>?ark=</xsl:text>
	<xsl:value-of select="$ark"/>
	<xsl:text>&amp;parent_ark=</xsl:text>
	<xsl:value-of select="$parent_ark"/>
    </xsl:variable>
    <xsl:variable name="daoinfo" select="document($daoinfoURL)"/>

    <!-- in theory the same object can be in many collections, so we need to know the order in 
	the particular collection -->
    <facet-collection-order xtf:meta="true" xtf:tokenize="false">
	<xsl:value-of select="$parent_ark"/>
	<xsl:text>::</xsl:text>
	<xsl:value-of select="($daoinfo)/daoinfo/order"/>
    </facet-collection-order>

        <xsl:choose> <!-- main choice is 2 listings or 1 listing -->
                <xsl:when test="($daoinfo)/daoinfo/inst_parent != ''"> <!-- there are 2 -->
                        <!-- list parent first -->
                        <institution-doublelist xtf:meta="true" xtf:tokenize="false">
                                <xsl:value-of select="substring(($daoinfo)/daoinfo/inst,1,1)"/>
                                <xsl:text>::</xsl:text>
                                <xsl:value-of select="($daoinfo)/daoinfo/inst"/>
                                <xsl:text>::</xsl:text>
                                <xsl:value-of select="($daoinfo)/daoinfo/inst_parent"/>
                        </institution-doublelist>
                        <!-- list grandparent first -->
                        <institution-doublelist xtf:meta="true" xtf:tokenize="false">
                                <xsl:value-of select="substring(($daoinfo)/daoinfo/inst_parent,1,1)"/>
                                <xsl:text>::</xsl:text>
                                <xsl:value-of select="($daoinfo)/daoinfo/inst_parent"/>
                                <xsl:text>::</xsl:text>
                                <xsl:value-of select="($daoinfo)/daoinfo/inst"/>
                        </institution-doublelist>
                        <facet-institution xtf:meta="true" xtf:facet="true">
                                <xsl:value-of select="($daoinfo)/daoinfo/inst_parent"/>
                                <xsl:text>::</xsl:text>
                                <xsl:value-of select="($daoinfo)/daoinfo/inst"/>
                        </facet-institution>
                </xsl:when>
                <xsl:otherwise>
                        <institution-doublelist xtf:meta="true" xtf:tokenize="false">
                                <xsl:value-of select="substring(($daoinfo)/daoinfo/inst,1,1)"/>
                                <xsl:text>::</xsl:text>
                                <xsl:value-of select="($daoinfo)/daoinfo/inst"/>
                        </institution-doublelist>
                        <facet-institution xtf:meta="true" xtf:facet="true">
                                <xsl:value-of select="($daoinfo)/daoinfo/inst"/>
                        </facet-institution>
                </xsl:otherwise>
        </xsl:choose>

  </xsl:template>

</xsl:stylesheet>
