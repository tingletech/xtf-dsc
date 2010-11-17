<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- CMS query parser stylesheet                                            -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

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

<!--
  This stylesheet implements a query parser that translates a CMS query
  to XTF's internal query format.
  
  The input and output of this stylesheet are identical to crossQuery, except
  that in addition to tokenizing the URL parameters, the cms servlet also attempts
  to parse each one as a structured query.
-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:dc="http://purl.org/dc/elements/1.1/" 
                              xmlns:mets="http://www.loc.gov/METS/"
                              xmlns:xlink="http://www.w3.org/TR/xlink" 
                              xmlns:xs="http://www.w3.org/2001/XMLSchema"
                              exclude-result-prefixes="xsl dc mets xlink xs">
  
  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  
  <xsl:strip-space elements="*"/>
  
<!-- ====================================================================== -->
<!-- Global parameters (specified in the URL)                               -->
<!-- ====================================================================== -->

  <!-- servlet path from the URL -->
  <xsl:param name="servlet.path"/>
  <xsl:param name="root.path"/>
  
  <!-- The stylesheet to use for formatting -->
  <xsl:param name="xslt" select="'generic'"/>
  
  <!-- Sorting of the result records -->
  <xsl:param name="sort" select="'relevance'"/>
  
  <!-- first hit on page -->
  <xsl:param name="start" select='1'/>
  
  <!-- documents per page -->
  <xsl:param name="pageSize" select="'20'"/>
  
<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->
  
  <xsl:template match="/">

    <!-- The top-level query element tells what stylesheet will be used to
       format the results, which document to start on, and how many documents
       to display on this page. -->
    <query indexPath="index" termLimit="1000" workLimit="1000000" startDoc="{$start}" maxDocs="{$pageSize}">

      <!-- Look up the formatter and make sure it's in our table. -->
      <xsl:if test="not($xslt='raw xml')">
        <xsl:variable name="formatters"
                      select="document('./formatters.xml')"/>
        <xsl:variable name="formatterUrl"
                      select="$formatters//formatter[@name=$xslt]/@url"/>
        
        <xsl:choose>
          <xsl:when test="$formatterUrl">
            <xsl:attribute name="style" select="$formatterUrl"/>
          </xsl:when>
          <xsl:otherwise>
            <error message="{concat('Unrecognized style: ', $xslt)}"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      
      <!-- Validate the sort field -->
      <xsl:if test="not($sort='relevance')">
        <xsl:attribute name="sortDocsBy">
          <xsl:choose>
            <xsl:when test="$sort='title'">
              <xsl:value-of select="'sort-title'"/>
            </xsl:when>
            <xsl:when test="$sort='year'">
              <xsl:value-of select="'sort-year'"/>
            </xsl:when>              
            <xsl:when test="$sort='creator'">
              <xsl:value-of select="'sort-creator'"/>
            </xsl:when>
            <xsl:when test="$sort='publisher'">
              <xsl:value-of select="'sort-publisher'"/>
            </xsl:when>
            <xsl:when test="$sort='type'">
              <xsl:value-of select="'type'"/>
            </xsl:when>
            <xsl:when test="$sort='identifier'">
              <xsl:value-of select="'identifier'"/>
            </xsl:when>
          </xsl:choose>
        </xsl:attribute>
        
        <!-- Give an error message if we don't recognize the 'sort' field -->
        <xsl:if test="not(matches($sort, '^(title|year|creator|publisher|type|identifier)$'))">
          <error>
            <xsl:attribute name="message" select="concat('Unrecognized sort value: ', $sort)"/>
          </error>
        </xsl:if>
      </xsl:if>
      
      <!-- Process the query -->
      <and>
        <xsl:for-each select="parameters/param">
          <xsl:choose>
          
            <!-- Handle normal DC fields -->
            <xsl:when test="matches(@name, '^(title|creator|subject|description|publisher|contributor|date|type|format|identifier|source|language|relation|coverage|rights)$')">
              <and field="{@name}" maxSnippets="0">
              
                <!-- 
                  Within this field, the CMS servlet has taken care of parsing 
                  OR, AND, NOT, nested parentheses, terms, phrases, etc. Just 
                  copy that through.
                -->
                <xsl:call-template name="copyParsedQuery"/>
              </and>
            </xsl:when>
            
            <!-- If a field is prefixed with "n", perform a NOT search on it -->
            <xsl:when test="matches(@name, '^(ntitle|ncreator|nsubject|ndescription|npublisher|ncontributor|ndate|ntype|nformat|nidentifier|nsource|nlanguage|nrelation|ncoverage|nrights)$')">
              <xsl:variable name="field" select="substring(@name, 2)"/>
              <not field="{$field}" maxSnippets="0">
                <xsl:call-template name="copyParsedQuery"/>
              </not>
            </xsl:when>
            
            <!-- The special field "search" searches every DC field -->
            <xsl:when test="@name = 'search'">
              <xsl:variable name="base" select="."/>
              <or>
                <xsl:for-each select="'title', 'creator', 'subject', 'description', 'publisher', 'contributor', 'date', 'type', 'format', 'identifier', 'source', 'language', 'relation', 'coverage', 'rights'">
                  <and field="{string(.)}" maxSnippets="0">
                    <xsl:call-template name="copyParsedQuery">
                      <xsl:with-param name="base" select="$base"/>
                    </xsl:call-template>
                  </and>
                </xsl:for-each>
              </or>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </and>
      
    </query>

  </xsl:template>

<!-- ====================================================================== -->
<!-- copyParsedQuery Template                                                          -->
<!-- ====================================================================== -->
  
  <xsl:template name="copyParsedQuery">
    <xsl:param name="base" select="."/>
    <xsl:choose>
      <!-- 
        Make sure no errors were found by the servlet while it was parsing the
        CMS query syntax.
      -->
      <xsl:when test="$base//error">
        <xsl:copy-of select="$base//error"/>
      </xsl:when>
      
      <!-- Otherwise, copy the parsed query intact -->
      <xsl:otherwise>
        <xsl:copy-of select="$base/parsed/*"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
