<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
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

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                              xmlns:xsi="http://www.w3.org/2001/XMLSchema" 
                              xmlns:dc="http://purl.org/dc/elements/1.1/"
                              xmlns:xs="http://www.w3.org/2001/XMLSchema"
                              xmlns:cms="http://www.cdlib.org/cms"
                              exclude-result-prefixes="xsl xsi dc xs cms">
                              
<!-- ====================================================================== -->
<!-- Global parameters (specified in the URL)                               -->
<!-- ====================================================================== -->

  <!-- servlet path from the URL -->
  <xsl:param name="servlet.path"/>
  <xsl:param name="root.path"/>
  <xsl:param name="http.URL" select="'foo'"/>

  <!-- documents per page -->
  <xsl:param name="pageSize" select="20" as="xs:integer"/>
  
  <!-- pages per group (apparently this is actually a constant -->
  <xsl:param name="groupSize" select="10" as="xs:integer"/>
  
<!-- ====================================================================== -->
<!-- Output Parameters                                                      -->
<!-- ====================================================================== -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="text/xml"/>

<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->
  
  <xsl:template match="/CMSResult">
    <xsl:variable name="totalDocs" select="@totalDocs"/>
    <xsl:variable name="startDoc" select="@startDoc"/>
    <xsl:variable name="endDoc" select="@endDoc"/>
    
    <SearchResults>
      <xsl:attribute name="hits" select="$totalDocs"/>
      <xsl:attribute name="pageSize" select="$pageSize"/>
      <xsl:attribute name="start" select="$startDoc"/>
      <xsl:attribute name="end" select="$endDoc"/>
      
      <!-- Generate all the page links -->
      <xsl:call-template name="makePageLinks">
        <xsl:with-param name="totalDocs" select="$totalDocs"/>
        <xsl:with-param name="startDoc" select="$startDoc"/>
      </xsl:call-template>
      
      <!-- Output an empty 'swish' query, since (hopefully) it doesn't
           matter. However, we need to do the <word> tags; hopefully we're
           doing these right.
      -->
      <Query swish="{cms:calcSwish(parameters/param)}">
        <xsl:call-template name="outputWords"/>
      </Query>
      
      <!-- Output a qdc record for each hit -->
      <xsl:apply-templates select="docHit"/>
      
    </SearchResults>
  </xsl:template>

<!-- ====================================================================== -->
<!-- Page Link Generation Template                                          -->
<!-- ====================================================================== -->

  <xsl:template name="makePageLinks">
    <xsl:param name="totalDocs"/>
    <xsl:param name="startDoc"/>
  
    <!-- Figure out how many pages there are in total -->
    <xsl:variable name="nPages" select="if($totalDocs > 0) then ceiling($totalDocs div $pageSize) else 1"/>
    <xsl:variable name="curPage" select="if($totalDocs > 0) then ceiling($startDoc div $pageSize) else 1"/>
    
    <!-- Figure out how many groups of pages there are in total -->
    <xsl:variable name="nGroups" select="if($totalDocs > 0) then ceiling($nPages div $groupSize) else 1"/>
    <xsl:variable name="curGroup" select="if($totalDocs > 0) then ceiling($curPage div $groupSize) else 1"/>
    
    <!-- Figure out the first and last pages for the current group -->
    <xsl:variable name="firstPage" select="(($curGroup - 1) * $groupSize) + 1"/>
    <xsl:variable name="lastPage" 
                  select="if($curGroup = $nGroups) 
                          then $nPages
                          else ($firstPage + $groupSize - 1)"/>

    <!-- If we're on a page other than the first, generate a link to the
         previous page. -->
    <xsl:if test="not($curPage = 1)">
      <previous>
        <xsl:call-template name="genLink">
          <xsl:with-param name="start" select="(($curPage - 2) * $pageSize) + 1"/>
        </xsl:call-template>
      </previous>
    </xsl:if>
    
    <!-- If we're on a group other than the first, generate a link to the
         previous group. -->
    <xsl:if test="not($curGroup = 1)">
      <previousGroup>
        <xsl:call-template name="genLink">
          <xsl:with-param name="start" select="(($curGroup - 2) * $groupSize * $pageSize) + 1"/>
        </xsl:call-template>
      </previousGroup>
    </xsl:if>
         
    <!-- Generate a link for each page (except the one we're on) -->
    <xsl:for-each select="xs:integer($firstPage) to xs:integer($lastPage)">
      <xsl:variable name="page" select="position() + $firstPage - 1"/>
      <page n="{$page}">
        <xsl:if test="not($page = $curPage)">
          <xsl:call-template name="genLink">
            <xsl:with-param name="start" select="(($page - 1) * $pageSize) + 1"/>
          </xsl:call-template>
        </xsl:if>
      </page>
    </xsl:for-each>
    
    <!-- If we're on a group other than the last, generate a link to the
         next group. -->
    <xsl:if test="not($curGroup = $nGroups)">
      <nextGroup>
        <xsl:call-template name="genLink">
          <xsl:with-param name="start" select="($curGroup * $groupSize * $pageSize) + 1"/>
        </xsl:call-template>
      </nextGroup>
    </xsl:if>
         
    <!-- If we're on a page other than the last, generate a link to the
         next page. -->
    <xsl:if test="not($curPage = $nPages)">
      <next>
        <xsl:call-template name="genLink">
          <xsl:with-param name="start" select="($curPage * $pageSize) + 1"/>
        </xsl:call-template>
      </next>
    </xsl:if>
    
  </xsl:template>
  

<!-- ====================================================================== -->
<!-- Link Generation Template                                               -->
<!-- ====================================================================== -->

  <xsl:template name="genLink">
    <xsl:param name="start"/>
    
    <!-- Begin with a '?' to mark the query string -->
    <xsl:value-of select="'?'"/>
    
    <!-- Copy each URL parameter in turn -->
    <xsl:analyze-string select="$http.URL" regex="(\w+)=([^&amp;;]*)">
      <xsl:matching-substring>
        <xsl:variable name="parmName" select="regex-group(1)"/>
        <xsl:variable name="parmVal" select="regex-group(2)"/>
        
        <!-- Copy all params except 'start' through unchanged -->
        <xsl:if test="not($parmName = 'start')">
          <xsl:value-of select="concat($parmName, '=', $parmVal, '&amp;')"/>
        </xsl:if>
      </xsl:matching-substring>
    </xsl:analyze-string>
    
    <!-- Now enter the correct start for this page -->
    <xsl:value-of select="concat('start=', $start)"/>
  </xsl:template>
  
<!-- ====================================================================== -->
<!-- Document Hit and Meta-Data Templates                                   -->
<!-- ====================================================================== -->

  <xsl:template match="docHit">
    <qdc>
      <xsl:apply-templates/>
    </qdc>
  </xsl:template>

  <xsl:template match="title|creator|subject|description|publisher|contributor|date|type|format|identifier|source|language|relation|coverage|rights">
    <xsl:choose>
      <xsl:when test="@q">
        <xsl:element name="{concat(name(), '.', @q)}">
          <xsl:copy-of select="string()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- ====================================================================== -->
<!-- Word Outputting Template                                               -->
<!-- ====================================================================== -->

  <xsl:template name="outputWords">
    <xsl:for-each select="/CMSResult/parameters/param">
    
      <!-- Handle normal DC fields, plus the special 'search' field -->
      <xsl:if test="matches(@name, '^(search|title|creator|subject|description|publisher|contributor|date|type|format|identifier|source|language|relation|coverage|rights)$')">
        <word index="{@name}">
          <xsl:value-of select="@value"/>
        </word>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:function name="cms:calcSwish">
    <xsl:param name="paramList"/>
    <xsl:for-each select="$paramList">
      
      <!-- Handle normal DC fields, plus the special 'search' field -->
      <xsl:if test="matches(@name, '^(search|title|creator|subject|description|publisher|contributor|date|type|format|identifier|source|language|relation|coverage|rights)$')">
          <xsl:value-of select="concat(@name, '=(')"/>
          <xsl:value-of select="@value"/>
          <xsl:value-of select="') '"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>
  
<!-- ====================================================================== -->
<!-- Template to avoid copying text nodes except when specifically wanted   -->
<!-- ====================================================================== -->

  <xsl:template match="text()" />

</xsl:stylesheet>
