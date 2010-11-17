<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Simple query parser stylesheet                                         -->
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
  This stylesheet implements a simple query parser which does not handle any
  complex queries (boolean and/or/not, ranges, nested queries, etc.) An
  experimental parser is available that does parse these constructs; see
  complexQueryParser.xsl.
  
  For details on the input and output expected of this stylesheet, see the
  comment section at the bottom of this file.
-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:dc="http://purl.org/dc/elements/1.1/" 
                              xmlns:mets="http://www.loc.gov/METS/"
                              xmlns:xlink="http://www.w3.org/TR/xlink" 
                              xmlns:xs="http://www.w3.org/2001/XMLSchema"
                              xmlns:parse="http://cdlib.org/parse"
                              exclude-result-prefixes="xsl dc mets xlink xs parse">
  
  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  
  <xsl:strip-space elements="*"/>
  
<!-- ====================================================================== -->
<!-- Global parameters (specified in the URL)                               -->
<!-- ====================================================================== -->
  
  <!-- style param -->
  <xsl:param name="style"/>
  
  <!-- search mode -->
  <xsl:param name="smode"/>
  
  <!-- result mode -->
  <xsl:param name="rmode"/>
  
  <!-- brand mode -->
  <xsl:param name="brand"/>
  
  <!-- sort mode -->
  <xsl:param name="sort"/>
  
  <!-- raw XML dump flag -->
  <xsl:param name="raw"/>
  
  <!-- score normalization and explanation (for debugging) -->
  <xsl:param name="normalizeScores"/>
  <xsl:param name="explainScores"/>
   
  <!-- Recommendation parameters -->
  <xsl:param name="maxRecords" as="xs:integer" select="10"/>
  
  <!-- first hit on page -->
  <xsl:param name="startDoc" as="xs:integer" select="1"/>
  
  <!-- documents per page -->
  <xsl:param name="docsPerPage" as="xs:integer">
    <xsl:choose>
      <xsl:when test="($smode = 'test')">
        <xsl:value-of select="10000"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="25"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <!-- max query docs -->
  <xsl:param name="maxDocs" as="xs:integer">
    <xsl:choose>
      <xsl:when test="$facet='type-tab'">
        <xsl:value-of select="0"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$docsPerPage"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <!-- list of keyword search fields -->
  <xsl:param name="fieldList" select="'text title creator subject description publisher contributor date type format identifier source language relation coverage rights year'"/>
  
  <!-- parameters for 'getRecommendations' mode -->
  <xsl:param name="awsID"/>
  <xsl:param name="sysID"/>
  
<!-- ====================================================================== -->
<!-- Local parameters                                                       -->
<!-- ====================================================================== -->
  
  <xsl:param name="weight"/>
  
  <xsl:param name="boostSet">
    <xsl:choose>
      <xsl:when test="$weight = '1'">
        <!--<xsl:value-of select="'weights/alltrans_weights.txt'"/>-->
        <!--<xsl:value-of select="'weights/combined_weights.txt'"/>-->
        <xsl:value-of select="'weights/uc_holdings_weights.txt'"/>
      </xsl:when>
      <xsl:when test="$weight = '2'">
        <xsl:value-of select="'weights/charge_weights.txt'"/>
      </xsl:when>
      <xsl:when test="$weight = '3'">
        <xsl:value-of select="'weights/uc_holdings_weights.txt'"/>
      </xsl:when>
      <xsl:when test="$weight = '4'">
        <xsl:value-of select="'weights/wc_holdings_weights.txt'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <xsl:param name="boostSetExponent"/>

  <!-- browsing parameters -->
  <xsl:param name="facet"/>
  <xsl:param name="group"/>
  
  <xsl:param name="endDoc" as="xs:integer" select="($startDoc + $docsPerPage)-1"/>
  <xsl:param name="docRange">
    <xsl:if test="$docsPerPage > 0">
       <xsl:value-of select="concat('#',$startDoc,'-',$endDoc)"/>  
    </xsl:if>
  </xsl:param>
  
    
  <!-- default group sorting by value -->
  <xsl:param name="sortGroupsBy" select="'value'"/>
  
  <!-- doc sorting -->
  <xsl:param name="sortDocsBy"/>
  
  <!-- force inclusion of empty groups in alpha grouping -->
  <xsl:param name="includeEmpty" select="'yes'"/>
  
<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->
  
  <xsl:template match="/">
    
    <!-- choose stylesheet -->
    <xsl:variable name="stylesheet">
      <xsl:choose>
        <xsl:when test="$style = 'eschol'">
          <xsl:value-of select="'style/crossQuery/resultFormatter/tei/eschol/resultFormatter.xsl'"/>
        </xsl:when>
        <xsl:when test="$style = 'oac-ead'">
          <xsl:value-of select="'style/crossQuery/resultFormatter/ead/resultFormatter.xsl'"/>
        </xsl:when>
        <xsl:when test="$style = 'oac-img'">
          <xsl:value-of select="'style/crossQuery/resultFormatter/img/resultFormatter.xsl'"/>
        </xsl:when>
        <xsl:when test="$style = 'oac-tei'">
          <xsl:value-of select="'style/crossQuery/resultFormatter/tei/oac/resultFormatter.xsl'"/>
        </xsl:when>
        <!-- recommender -->
        <xsl:when test="$style = 'melrec'">
          <xsl:value-of select="'style/crossQuery/resultFormatter/marc/resultFormatter.xsl'"/>
        </xsl:when>
        <!-- browsing -->
        <!-- this stylesheet will eventual replace the eschol stylesheet? -->
        <xsl:when test="$style = 'browse'">
          <xsl:value-of select="'style/crossQuery/resultFormatter/browse/resultFormatter.xsl'"/>
        </xsl:when>
        <xsl:when test="$style = 'raw'">
          <xsl:value-of select="'style/crossQuery/resultFormatter/raw/resultFormatter.xsl'"/>
        </xsl:when>
	      <!-- eqf EQF earthquake fire 1906 -->
        <xsl:when test="$style = 'eqf'">
          <xsl:value-of select="'style/crossQuery/resultFormatter/mixed-mode/resultFormatter.xsl'"/>
        </xsl:when>
        <!-- CUI resultFormatters -->
        <xsl:when test="$style = 'cui-grid'">
          <xsl:value-of select="'style/crossQuery/resultFormatter/cui/grid/resultFormatter.xsl'"/>
        </xsl:when>
        <xsl:when test="$style = 'cui-list'">
          <xsl:value-of select="'style/crossQuery/resultFormatter/cui/list/resultFormatter.xsl'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'style/crossQuery/resultFormatter/default/resultFormatter.xsl'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- The top-level query element tells what stylesheet will be used to
       format the results, which document to start on, and how many documents
       to display on this page. -->

    <query indexPath="index" termLimit="1000" workLimit="20000000" style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="{$maxDocs}">

      <xsl:if test="$style = 'melrec'">
        <xsl:attribute name="normalizeScores" select="'false'"/>
      </xsl:if>
      <xsl:if test="not($boostSet = '')">
        <xsl:attribute name="boostSet" select="$boostSet"/>
        <xsl:attribute name="boostSetField" select="'sysID'"/>
        <xsl:if test="not($boostSetExponent = '')">
          <xsl:attribute name="boostSetExponent" select="$boostSetExponent"/>
        </xsl:if>
      </xsl:if>

      <!-- sort attribute -->
      <xsl:if test="$sort">
        <xsl:attribute name="sortMetaFields">
          <xsl:choose>
            <xsl:when test="$sort='title'">
              <xsl:value-of select="'sort-title,sort-creator,sort-publisher,-sort-year'"/>
            </xsl:when>
            <xsl:when test="$sort='year'">
              <xsl:value-of select="'-sort-year,sort-title,sort-creator,sort-publisher'"/>
            </xsl:when>
            <xsl:when test="$sort='reverse-year'">
              <xsl:value-of select="'sort-year,sort-title,sort-creator,sort-publisher'"/>
            </xsl:when>
            <xsl:when test="$sort='creator'">
              <xsl:value-of select="'sort-creator,-sort-year,sort-title'"/>
            </xsl:when>
            <xsl:when test="$sort='publisher'">
              <xsl:value-of select="'sort-publisher,sort-title,-sort-year'"/>
            </xsl:when>
            <xsl:when test="$sort='sysid'">
              <xsl:value-of select="'-sort-sysid'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'relevance'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      
      <!-- grouping -->
      
      <xsl:if test="$facet">
        
        <facet field="facet-{$facet}" sortDocsBy="{$sortDocsBy}" includeEmptyGroups="yes">
          <xsl:attribute name="select">
            <xsl:choose>
              <!-- Groups -->
              <xsl:when test="$group">
                <xsl:value-of select="concat('*|',$group, $docRange)"/>
              </xsl:when>
              <!-- Facet Only -->
              <xsl:otherwise>
                <xsl:value-of select="concat('*|*[nonEmpty][1]',$docRange)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </facet>
        
      </xsl:if>
      
      <!-- score normalization and explanation -->
      <xsl:if test="$normalizeScores">
        <xsl:attribute name="normalizeScores" select="$normalizeScores"/>
      </xsl:if>
      <xsl:if test="$explainScores">
        <xsl:attribute name="explainScores" select="$explainScores"/>
      </xsl:if>
      
      <!-- process query -->
      <xsl:choose>
        <xsl:when test="$rmode = 'getRecommendations'">
          <xsl:call-template name="getRecommendations"/>          
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
      
      
    </query>
  </xsl:template>

  <xsl:template match="parameters">

    <!-- Scan for non-empty parameters (but skip "-exclude", "-join", "-prox", "-max", and "-ignore") -->
    <xsl:variable name="queryParams" select="param[count(*) &gt; 0 and not(matches(@name, '.*-exclude')) 
                                                                   and not(matches(@name, '.*-join')) 
                                                                   and not(matches(@name, '.*-prox')) 
                                                                   and not(matches(@name, '.*-max')) 
                                                                   and not(matches(@name, '.*-ignore'))]"/>

    <!-- Find the full-text query, if any -->
    <xsl:variable name="textParam" select="$queryParams[matches(@name, 'text|query')]"/>
    
    <!-- Find the meta-data queries, if any -->

    <xsl:variable name="metaParams" select="$queryParams[not(matches(@name, 'text*|query*|style|smode|rmode|brand|sort|startDoc|docsPerPage|sectionType|fieldList|object|facet|group|startGroup|startParent|sortGroupsBy|sortDocsBy|weight|normalizeScores|explainScores|maxRecords|boolean-type-a|boolean-type-b|boostSetExponent|participantID|scenarioID|ranking_method|^x$|^y$|.*-ignore'))]"/>
    
    <and>
      <!-- Process the meta-data queries, if any -->
      <xsl:if test="count($metaParams) &gt; 0">
        <xsl:apply-templates select="$metaParams"/>
      </xsl:if>       
      <!-- Process the text query, if any -->
      <xsl:if test="count($textParam) &gt; 0">
        <xsl:apply-templates select="$textParam"/>
      </xsl:if>         
      <!-- Unary Not -->
      <xsl:for-each select="param[contains(@name, '-exclude')]">
        <xsl:variable name="field" select="replace(@name, '-exclude', '')"/>
        <xsl:if test="not(//param[@name=$field])">
          <not field="{$field}">
            <xsl:apply-templates/>
          </not>
        </xsl:if>
      </xsl:for-each>
      <!-- If there are no meta, text queries, or unary nots, output a dummy -->
      <xsl:if test="count($metaParams) = 0 and count($textParam) = 0 and not(param[matches(@name, '.*-exclude')])">
        <term field="text">$!@$$@!$</term>
      </xsl:if>
    </and>
    
  </xsl:template>
  
<!-- ====================================================================== -->
<!-- Single-field parameter template                                        -->
<!--                                                                        -->
<!-- Join all the terms of a single text or meta-data query together. For   -->
<!-- meta-data queries, we must also specify the field to search in.        -->
<!-- ====================================================================== -->
  
  <xsl:template match="param">
    
    <xsl:variable name="metaField" select="@name"/>
    
    <xsl:variable name="exclude" select="//param[@name=concat($metaField, '-exclude')]"/>
    <xsl:variable name="join" select="//param[@name=concat($metaField, '-join')]"/>
    <xsl:variable name="prox" select="//param[@name=concat($metaField, '-prox')]"/>
    <xsl:variable name="max" select="//param[@name=concat($metaField, '-max')]"/>
    
    <xsl:variable name="op">
      <xsl:choose>
        <xsl:when test="$max/@value != ''">
          <xsl:value-of select="'range'"/>
        </xsl:when>       
        <xsl:when test="$prox/@value != ''">
          <xsl:value-of select="'near'"/>
        </xsl:when>
        <xsl:when test="$join/@value != ''">
          <xsl:value-of select="$join/@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'and'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- 'and' all the terms together, unless "<field>-join" specifies a
       different operator (like 'or'). In the simple case when there's 
       only one term, the query processor optimizes this out, so it's 
       harmless. -->
    <xsl:element name="{$op}">
      
      <!-- Specify the field name for meta-data queries -->
        <xsl:choose>
            <xsl:when test="not(matches(@name, 'text|query|keyword'))">
                <xsl:attribute name="field" select="$metaField"/>
            </xsl:when>
            <xsl:when test="matches(@name, 'keyword')">
                <xsl:attribute name="fields" select="$fieldList"/>
                <xsl:attribute name="slop" select="'10'"/>
                <xsl:attribute name="maxTextSnippets" select="'2'"/>
                <xsl:attribute name="maxMetaSnippets" select="'all'"/>
            </xsl:when>
            <!-- Changed for Calisphere. Was 3, 100 -->
            <xsl:when test="matches(@name, 'text')">
                <xsl:attribute name="field" select="'text'"/>
                <xsl:attribute name="maxSnippets" select="'2'"/>
                <xsl:attribute name="maxContext" select="'80'"/>
            </xsl:when>
            <xsl:when test="matches(@name, 'query')">
                <xsl:attribute name="field" select="'text'"/>
                <xsl:attribute name="maxSnippets" select="'-1'"/>
                <xsl:attribute name="maxContext" select="'80'"/>
            </xsl:when>
        </xsl:choose>
        
        <!-- Specify the maximum term separation for a proximity query -->
        <xsl:if test="$prox/@value != ''">
            <xsl:attribute name="slop" select="$prox/@value"/>
        </xsl:if>
        
        <!-- Process all the phrases and/or terms -->
        <xsl:apply-templates/>
        
        <!-- If there is an 'exclude' parameter for this field, process it -->
        <xsl:if test="$exclude/@value != ''">
            <not>
                <xsl:apply-templates select="$exclude/*"/>
            </not>
        </xsl:if>
        
    <!-- If there is a sectionType parameter, process it -->
    <xsl:if test="matches($metaField, 'text|query') and (//param[@name='sectionType']/@value != '')">
      <sectionType>
        <xsl:apply-templates select="//param[@name='sectionType']/*"/>
      </sectionType>
    </xsl:if>

    </xsl:element>
    
  </xsl:template>

<!-- ====================================================================== -->
<!-- Phrase template                                                        -->
<!--                                                                        -->
<!-- A phrase consists simply of several tokens.                            -->
<!-- ====================================================================== -->
  
  <xsl:template match="phrase">
    <phrase>
      <xsl:apply-templates/>
    </phrase>
  </xsl:template>
  
<!-- ====================================================================== -->
<!-- Token template                                                         -->
<!--                                                                        -->
<!-- Tokens form the basic search terms which make up all other types of    -->
<!-- queries. For simplicity, we disregard any "non-word" tokens (i.e.      -->
<!-- symbols such as "+", "&", etc.)                                        -->
<!-- ====================================================================== -->
  
  <xsl:template match="token[@isWord='yes']">
    
    <xsl:variable name="metaField" select="parent::*/@name"/>
    <xsl:variable name="max" select="//param[@name=concat($metaField, '-max')]"/>
   
    <xsl:choose>
      <xsl:when test="$max/@value != ''">
        <lower>
          <xsl:value-of select="@value"/>
        </lower>
        <upper>
          <xsl:value-of select="$max/@value"/>
        </upper>
      </xsl:when>
      <xsl:otherwise>       
        <term>
          <xsl:value-of select="@value"/>
        </term>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
<!-- ====================================================================== -->
<!-- Recommendation fetching template                                       -->
<!-- ====================================================================== -->
  
  <xsl:template name="getRecommendations">
    
    <or>
      
      <!-- If awsID was specified in URL, get Amazon recommendations -->
      <xsl:if test="$awsID">
        <xsl:variable name="AWS" select="document(concat('http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&amp;SubscriptionId=1X3XCKDVXDSSQ4V69HG2&amp;Operation=ItemLookup&amp;ResponseGroup=Similarities&amp;ItemId=', $awsID))"/>
        <or field="identifier-isbn">
          <xsl:for-each select="$AWS//*[local-name()='SimilarProduct']">
            <term><xsl:value-of select="*[local-name()='ASIN']"/></term>
            <resultData><xsl:copy-of select="."/></resultData>
          </xsl:for-each>
          <!-- Test only: -->
          <!--<term>0026035316</term>-->
        </or>
        <!-- Test only: -->
        <!--<resultData>
          <SimilarProduct xmlns="http://webservices.amazon.com/AWSECommerceService/2005-10-05">
            <ASIN>0026035316</ASIN>
            <Title>God in the pits: confessions of a commodities trader</Title>
          </SimilarProduct>
        </resultData>-->
      </xsl:if>
      
      <!-- If sysID was specified in URL, get local recommendations -->
      <xsl:if test="$sysID">
        <xsl:variable name="recs" select="document(concat('http://recommend-dev.cdlib.org/cgi-bin/recommendations5.pl?sys_id=', $sysID, '&amp;max_records=', $maxRecords, '&amp;format=XML'))"/>
        <xsl:if test="$recs//status[@statusCode='Complete']">
          <or field="sysID">
            <xsl:variable name="sorted">
              <xsl:perform-sort select="$recs//recommendation">
                <xsl:sort select="@rankOrder" order="ascending" data-type="number"/>
              </xsl:perform-sort>
            </xsl:variable>
            <xsl:for-each select="$sorted/recommendation">
              <term><xsl:value-of select="@sysID"/></term>
              <resultData><xsl:copy-of select="."/></resultData>
            </xsl:for-each>
          </or>
        </xsl:if>
      </xsl:if>
    </or>
    
  </xsl:template>
  
</xsl:stylesheet>
