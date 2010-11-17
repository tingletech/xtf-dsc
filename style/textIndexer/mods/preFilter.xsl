<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
        xmlns:saxon="http://saxon.sf.net/"
        xmlns:xtf="http://cdlib.org/xtf"
        xmlns:date="http://exslt.org/dates-and-times"
        xmlns:parse="http://cdlib.org/xtf/parse"
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

<!-- ====================================================================== -->
<!-- Local Parameters                                                       -->
<!-- ====================================================================== -->
  
  <xsl:param name="sysID" select="/mods:mods/mods:identifier[@type='SYSID']"/>
  
<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->

  <xsl:template match="/">
    <xtf:meta>
      <xsl:apply-templates select="/mods:mods"/>
    </xtf:meta>
  </xsl:template>

<!-- ====================================================================== -->
<!-- Metadata Indexing                                                      -->
<!-- ====================================================================== -->
  
  <xsl:template match="mods:mods">
    
    <xsl:apply-templates select="mods:titleInfo"/>
    <xsl:apply-templates select="mods:name"/>
    <xsl:apply-templates select="mods:originInfo/mods:publisher"/>
    <xsl:apply-templates select="mods:originInfo/mods:place/mods:placeTerm[@type='text']"/>
    <xsl:apply-templates select="mods:originInfo/mods:dateIssued"/>
    <xsl:apply-templates select="mods:language/mods:languageTerm"/>
    <xsl:apply-templates select="mods:abstract"/>
    <xsl:apply-templates select="mods:tableOfContents"/>
    <xsl:apply-templates select="mods:note"/>
    <xsl:apply-templates select="mods:subject"/>
    <xsl:apply-templates select="mods:subject" mode="concat"/>
    <xsl:apply-templates select="mods:relatedItem/mods:titleInfo/mods:title"/>
    <xsl:apply-templates select="mods:location/mods:physicalLocation"/>
    <xsl:apply-templates select="mods:identifier[@type='isbn' and not(@invalid='yes')]"/>
    <xsl:apply-templates select="mods:identifier[@type='SYSID']"/>
    
    <!-- parsed year -->
    <xsl:apply-templates select="mods:originInfo/mods:dateIssued[1]" mode="parse"/>
    
    <!-- sort fields -->
    <xsl:apply-templates select="mods:titleInfo[not(@type)][1]" mode="sort"/>
    <xsl:choose>
      <xsl:when test="mods:name[@type='personal']">
        <xsl:apply-templates select="mods:name[@type='personal'][1]" mode="sort"/>
      </xsl:when>
      <xsl:when test="mods:name[@type='corporate']">
        <xsl:apply-templates select="mods:name[@type='corporate'][1]" mode="sort"/>      
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="mods:name[1]" mode="sort"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="mods:originInfo/mods:dateIssued[1]" mode="sort"/>
    
  </xsl:template>
  
  <!-- title indexes -->
  
  <xsl:template match="mods:mods/mods:titleInfo[not(@type)]">
    <title>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </title>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'title'"/>
      <xsl:with-param name="string" select="string(.)"/><!-- Captures sub-elements. Is that right? -->
    </xsl:call-template>
  </xsl:template>
    
  <xsl:template match="mods:mods/mods:titleInfo[@type='uniform']">
    <title-uniform>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </title-uniform>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'title-uniform'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
    
  <xsl:template match="mods:mods/mods:titleInfo[@type='abbreviated']">
    <title-abbreviated>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </title-abbreviated>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'title-abbreviated'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
    
  <xsl:template match="mods:mods/mods:titleInfo[@type='alternative']">
    <title-alternative>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </title-alternative>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'title-alternative'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
    
  <xsl:template match="mods:mods/mods:titleInfo[@type='translated']">
    <title-translated>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </title-translated>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'title-translated'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mods:mods/mods:titleInfo" mode="sort">
    <sort-title>
      <xsl:call-template name="meta-attributes"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:variable name="title">
        <xsl:for-each select="*[not(name()='nonSort')]">
          <xsl:value-of select="string(.)"/>
          <xsl:text> </xsl:text>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="parse:title($title)"/>
    </sort-title>
  </xsl:template>
  
  <xsl:template match="mods:subTitle">
    <xsl:text>: </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="mods:nonSort">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="mods:partName|mods:partNumber">
    <xsl:text>, </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- author indexes -->
  
  <xsl:template match="mods:mods/mods:name[@type='personal' or not(@type)]">
    <author>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </author>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'author'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mods:mods/mods:name[@type='corporate']">
    <author-corporate>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </author-corporate>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'author-corporate'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mods:mods/mods:name[@type='conference']">
    <author-conference>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </author-conference>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'author-conference'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mods:mods/mods:name" mode="sort">
    <sort-creator>
      <xsl:call-template name="meta-attributes"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:variable name="name">
        <xsl:for-each select="mods:namePart">
          <xsl:value-of select="string(.)"/>
          <xsl:text>, </xsl:text>
        </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="@type='corporate' or @type='conference'">
          <xsl:value-of select="$name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="parse:name($name)"/>
        </xsl:otherwise>
      </xsl:choose>
    </sort-creator>
  </xsl:template>
  
  <xsl:template match="mods:role"/>
  
  <xsl:template match="mods:namePart[@type]|mods:affiliation">
    <xsl:text>, </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- originInfo indexes -->
  
  <xsl:template match="mods:publisher">
    <publisher>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </publisher>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'publisher'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mods:placeTerm[@type='text']">
    <pub-place>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </pub-place>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'pub-place'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mods:dateIssued">
    <pub-date>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </pub-date>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'pub-date'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mods:dateIssued" mode="parse">
    <year>
      <xsl:call-template name="meta-attributes"/>
      <xsl:value-of select="parse:year(string(.), 0)"/>
    </year>
  </xsl:template>
    
  <xsl:template match="mods:dateIssued" mode="sort">
    <sort-year>
      <xsl:call-template name="meta-attributes"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:value-of select="parse:year(string(.), 0)"/>
    </sort-year>
  </xsl:template>
  
  <!-- language indexes -->
  
  <xsl:template match="mods:languageTerm">
    <language>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </language>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'language'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- note indexes -->
  
  <xsl:template match="mods:abstract">
    <abstract>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </abstract>
  </xsl:template>
  
  <xsl:template match="mods:toc">
    <toc>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </toc>
  </xsl:template>
  
  <xsl:template match="mods:note">
    <note>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </note>
  </xsl:template>
  
  <!-- subject indexes -->
  
  <!-- Create concatenated subjects -->
  <xsl:template match="mods:subject" mode="concat">
    <xsl:if test="mods:geographic or mods:name or mods:temporal or mods:title or mods:topic">
      <subject>
        <xsl:call-template name="meta-attributes"/>
        <xsl:for-each select="*">
          <xsl:choose>
            <xsl:when test="(self::mods:geographic or self::mods:temporal or mods:title or self::mods:topic) and position()=1">
              <xsl:value-of select="string(.)"/>
            </xsl:when>
            <xsl:when test="self::mods:geographic or self::mods:temporal or mods:title or self::mods:topic">
              <xsl:text> -- </xsl:text>
              <xsl:value-of select="string(.)"/>
            </xsl:when>
            <xsl:when test="self::mods:name">
              <xsl:if test="not(position()=1)">
                <xsl:text> -- </xsl:text>
              </xsl:if>
              <xsl:for-each select="*">
                <xsl:choose>
                  <xsl:when test="position()=1">
                    <xsl:value-of select="string(.)"/>
                  </xsl:when>
                  <xsl:when test="self::mods:namePart[@type='date']">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="string(.)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="string(.)"/> 
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </subject>
      <xsl:call-template name="createGroup">
        <xsl:with-param name="label" select="'subject'"/>
        <xsl:with-param name="string" select="string(.)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mods:subject">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="mods:subject/mods:geographic">
    <subject-geographic>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </subject-geographic>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'subject-geographic'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mods:subject/mods:name">
    <subject-name>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </subject-name>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'subject-name'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mods:subject/mods:temporal">
    <subject-temporal>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </subject-temporal>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'subject-temporal'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mods:subject/mods:title">
    <subject-title>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </subject-title>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'subject-title'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="mods:subject/mods:topic">
    <subject-topic>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </subject-topic>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'subject-topic'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- relatedItem indexes -->
  
  <xsl:template match="mods:relatedItem[@type='series']/mods:titleInfo/mods:title">
    <title-series>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </title-series>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'title-series'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- identifier indexes -->
  
  <xsl:template match="mods:identifier[@type='isbn']">
    <identifier-isbn>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </identifier-isbn>
  </xsl:template>
  
  <xsl:template match="mods:identifier[@type='SYSID']">
    <sysID>
      <xsl:call-template name="meta-attributes"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:apply-templates/>
    </sysID>
  </xsl:template>
    
  <!-- location indexes -->
  
  <xsl:template match="mods:location/mods:physicalLocation">
    <location>
      <xsl:call-template name="meta-attributes"/>
      <xsl:apply-templates/>
    </location>
    <xsl:call-template name="createGroup">
      <xsl:with-param name="label" select="'location'"/>
      <xsl:with-param name="string" select="string(.)"/>
    </xsl:call-template>
  </xsl:template>
     
<!-- ====================================================================== -->
<!-- Meta Attributes Template                                               -->
<!-- ====================================================================== -->

  <xsl:template name="meta-attributes">
    <xsl:attribute name="xtf:meta" select="'true'"/>
  </xsl:template>
  
<!-- ====================================================================== -->
<!-- Default Template                                                       -->
<!-- ====================================================================== -->
  
  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>
  
<!-- ====================================================================== -->
<!-- Grouping Templates                                                     -->
<!-- ====================================================================== -->
  
  <!-- generate facet fields -->
  <xsl:template name="createGroup"> 
    <xsl:param name="label"/>
    <xsl:param name="string"/>
    <xsl:variable name="name" select="concat('facet-', $label)"/>
    <!-- Get rid of quotes -->
    <xsl:variable name="value" select="replace($string, '&quot;', '')"/>
    <xsl:element name="{$name}">
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:if test="$value = ''">1 EMPTY</xsl:if>
      <xsl:value-of select="$value"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
