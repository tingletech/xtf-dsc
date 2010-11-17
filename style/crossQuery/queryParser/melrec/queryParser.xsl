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
                              xmlns:session="java:org.cdlib.xtf.xslt.Session"
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
  
  <!-- object view -->
  <xsl:param name="object"/>
  
  <!-- brand mode -->
  <xsl:param name="brand"/>
  
  <!-- sort mode -->
  <xsl:param name="sort"/>
  
  <!-- FRBR (old and new) -->
  <xsl:param name="frbrize"/>
  
  <!-- raw XML dump flag -->
  <xsl:param name="raw"/>
  
  <!-- score normalization and explanation (for debugging) -->
  <xsl:param name="normalizeScores"/>
  <xsl:param name="explainScores"/>
   
  <!-- Recommendation parameters -->
  <xsl:param name="maxRecords" as="xs:integer" select="5"/>
  
  <!-- first hit on page -->
  <xsl:param name="startDoc" as="xs:integer" select="1"/>
  
  <!-- documents per page -->
  <xsl:param name="docsPerPage" as="xs:integer">
    <xsl:choose>
      <xsl:when test="($smode = 'test')">
        <xsl:value-of select="10000"/>
      </xsl:when>
      <xsl:when test="$frbrize = 'old'">
        <xsl:value-of select="200"/>
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
  
  <!-- parameters for 'getRecommendations' mode -->
  <xsl:param name="awsID"/>
  <xsl:param name="sysID"/>
  
  <!-- parameters for 'moreLike' mode -->
  <xsl:param name="minWordLen" select="4"/>
  <xsl:param name="maxWordLen" select="50"/>
  <xsl:param name="minDocFreq" select="2"/>
  <xsl:param name="maxDocFreq" select="-1"/>
  <xsl:param name="minTermFreq" select="1"/>
  <xsl:param name="termBoost" select="'yes'"/>
  <xsl:param name="maxQueryTerms" select="10"/>
  <xsl:param name="moreLikeFields" select="'author,callnum,callnum-class,catAuthority,facet-subject,title-main,subject,year'"/>
  <xsl:param name="moreLikeBoosts" select="'0,0,0,0,0,0,1,0'"/>
  
<!-- ====================================================================== -->
<!-- Local parameters                                                       -->
<!-- ====================================================================== -->
  
  <xsl:param name="weight"/>
  
  <xsl:param name="boostSet">
    <xsl:choose>
      <xsl:when test="$weight = '1'">
        <xsl:value-of select="'weights/charge_weights.txt'"/>
      </xsl:when>
      <xsl:when test="$weight = '2'">
        <xsl:value-of select="'weights/uc_holdings_weights.txt'"/>
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
  
  <!-- group sorting -->
  <xsl:param name="sortGroupsBy" select="'value'"/>
  
  <!-- doc sorting -->
  <xsl:param name="sortDocsBy" select="relevance"/>
  
<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->
  
  <xsl:template match="/">
    
    <!-- display stylesheet -->
    <xsl:variable name="stylesheet">
      <xsl:value-of select="'style/crossQuery/resultFormatter/marc/resultFormatter.xsl'"/>
    </xsl:variable>
    
    <!-- The top-level query element tells what stylesheet will be used to
       format the results, which document to start on, and how many documents
       to display on this page. -->

    <query indexPath="index" termLimit="1000" workLimit="20000000" style="{$stylesheet}">

      <xsl:attribute name="startDoc" select="if($frbrize = 'yes') then 1 else $startDoc"/>
      <xsl:attribute name="maxDocs" select="if($frbrize = 'yes' and not(starts-with($rmode, 'objview'))) then 0 else $maxDocs"/>
      
      <xsl:attribute name="normalizeScores" select="'false'"/>

      <xsl:if test="not($boostSet = '')">
        <xsl:attribute name="boostSet" select="$boostSet"/>
        <xsl:attribute name="boostSetField" select="'sysID'"/>
        <xsl:if test="not($boostSetExponent = '')">
          <xsl:attribute name="boostSetExponent" select="$boostSetExponent"/>
        </xsl:if>
      </xsl:if>

      <!-- sort attribute -->
      <xsl:if test="$sort and not($frbrize = 'yes')">
        <xsl:attribute name="sortMetaFields">
          <xsl:choose>
            <xsl:when test="$sort='title'">
              <xsl:value-of select="'sort-title,sort-author,sort-publisher,-sort-year'"/>
            </xsl:when>
            <xsl:when test="$sort='year'">
              <xsl:value-of select="'-sort-year,sort-title,sort-author,sort-publisher'"/>
            </xsl:when>
            <xsl:when test="$sort='reverse-year'">
              <xsl:value-of select="'sort-year,sort-title,sort-author,sort-publisher'"/>
            </xsl:when>
            <xsl:when test="$sort='author'">
              <xsl:value-of select="'sort-author,-sort-year,sort-title'"/>
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
      
      <!-- score normalization and explanation -->
      <xsl:if test="$normalizeScores">
        <xsl:attribute name="normalizeScores" select="$normalizeScores"/>
      </xsl:if>
      
      <xsl:if test="$explainScores">
        <xsl:attribute name="explainScores" select="$explainScores"/>
      </xsl:if>
      
      <!-- grouping -->
      
      <xsl:choose>
        <xsl:when test="$facet">
          
          <facet field="facet-{$facet}" sortGroupsBy="{$sortGroupsBy}" includeEmptyGroups="yes" sortDocsBy="{$sortDocsBy}">
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
          
        </xsl:when>
        
        <!-- dynamic FRBR -->
        
        <xsl:when test="$frbrize = 'yes' and not(starts-with($rmode, 'objview'))">
          
          <xsl:variable name="frbrSortMode">
            <xsl:choose>
              <xsl:when test="$sort='title'">
                <xsl:value-of select="'[sort=title],'"/>
              </xsl:when>
              <xsl:when test="$sort='year'">
                <xsl:value-of select="'[sort=date],'"/>
              </xsl:when>
              <xsl:when test="$sort='reverse-year'">
                <xsl:value-of select="'[sort=-date],'"/>
              </xsl:when>
              <xsl:when test="$sort='author'">
                <xsl:value-of select="'[sort=author],'"/>
              </xsl:when>
              <xsl:when test="$sort='sysid'">
                <xsl:value-of select="'[sort=id],'"/>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          
          <xsl:variable name="frbrGroupSort">
            <xsl:choose>
              <xsl:when test="$sort='title' or $sort = 'year' or $sort = 'reverse-year' or $sort = 'author' or $sort = 'sysId'">
                <xsl:value-of select="'value'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'maxDocScore'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          
          <facet field="java:org.cdlib.xtf.textEngine.facet.FRBRGroupData({$frbrSortMode}merge-title,merge-author,sort-year,merge-id)" 
                 sortGroupsBy="{$frbrGroupSort}" 
                 includeEmptyGroups="no" 
                 sortDocsBy="{$sortDocsBy}">
            <xsl:attribute name="select" select="concat('*[', $startDoc, '-', $endDoc, ']#all')"/>
          </facet>
          
        </xsl:when>
      </xsl:choose>
      
      <!-- process query -->
      <xsl:choose>
        <xsl:when test="$rmode = 'getRecommendations'">
          <xsl:call-template name="getRecommendations"/>          
        </xsl:when>
        <xsl:when test="$smode = 'addToBag'">
          <xsl:call-template name="addToBag"/>
        </xsl:when>
        <xsl:when test="$smode = 'removeFromBag'">
          <xsl:call-template name="removeFromBag"/>
        </xsl:when>
        <xsl:when test="$smode = 'showBag'">
          <xsl:call-template name="showBag"/>
        </xsl:when>
        <xsl:when test="$smode = 'moreLike'">
          <xsl:call-template name="moreLike"/>
        </xsl:when>
        <xsl:when test="starts-with($smode, 'login')">
          <!-- Do nothing, let resultFormatter handle it. -->
        </xsl:when>
        <xsl:when test="starts-with($rmode, 'objview')">
          <xsl:call-template name="objview"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="spellcheck"/>
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

     <xsl:variable name="metaParams" select="$queryParams[not(matches(@name, 'text*|query*|style|smode|rmode|brand|sort|startDoc|docsPerPage|sectionType|object|facet|group|sortGroupsBy|sortDocsBy|weight|normalizeScores|explainScores|maxRecords|boolean-type-a|boolean-type-b|boostSetExponent|participantID|scenarioID|ranking_method|frbrize|.*-ignore|iso-.*'))]"/>
    
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
       
       <!-- Date Range -->
       
       <!-- lower -->
       <xsl:if test="param[contains(@name, 'iso-')]">
          <xsl:variable name="iso-year">
             <xsl:value-of select="param[@name='iso-year']/@value"/>
          </xsl:variable>
          <xsl:variable name="iso-month">
             <xsl:choose>
                <xsl:when test="matches(param[@name='iso-month']/@value,'[0-1][0-9]')">
                   <xsl:value-of select="param[@name='iso-month']/@value"/>
                </xsl:when>
                <xsl:otherwise>01</xsl:otherwise>
             </xsl:choose>
          </xsl:variable>
          <xsl:variable name="iso-day">
             <xsl:choose>
                <xsl:when test="matches(param[@name='iso-day']/@value,'[0-3][0-9]')">
                   <xsl:value-of select="param[@name='iso-day']/@value"/>
                </xsl:when>
                <xsl:otherwise>01</xsl:otherwise>
             </xsl:choose>
          </xsl:variable>
          
          <!-- upper -->
          <xsl:variable name="iso-year-max">
             <xsl:choose>
                <xsl:when test="matches(param[@name='iso-year-max']/@value,'[0-2][0-9][0-9][0-9]')">
                   <xsl:value-of select="param[@name='iso-year-max']/@value"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="param[@name='iso-year']/@value"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:variable>
          <xsl:variable name="iso-month-max">
             <xsl:choose>
                <xsl:when test="matches(param[@name='iso-month-max']/@value,'[0-1][0-9]')">
                   <xsl:value-of select="param[@name='iso-month-max']/@value"/>
                </xsl:when>
                <!-- Decided Steve's stuff is too hard (6 dimension table) -->
                <!--<xsl:when test="matches(param[@name='iso-month']/@value,'[0-1][0-9]') and 
                   ((param[@name='iso-year']/@value = param[@name='iso-year-max']/@value) or 
                   (param[@name='iso-year']/@value=''))">
                   <xsl:value-of select="param[@name='iso-month']/@value"/>
                   </xsl:when>-->
                <xsl:otherwise>12</xsl:otherwise>
             </xsl:choose>
          </xsl:variable>
          <xsl:variable name="iso-day-max">
             <xsl:choose>
                <xsl:when test="matches(param[@name='iso-day-max']/@value,'[0-3][0-9]')">
                   <xsl:value-of select="param[@name='iso-day-max']/@value"/>
                </xsl:when>
                <!--<xsl:when test="matches(param[@name='iso-day']/@value,'[0-3][0-9]') and 
                   ((param[@name='iso-year']/@value = param[@name='iso-year-max']/@value) or 
                   (param[@name='iso-year']/@value=''))">
                   <xsl:value-of select="param[@name='iso-day']/@value"/>
                   </xsl:when>-->
                <xsl:otherwise>31</xsl:otherwise>
             </xsl:choose>
          </xsl:variable>
          
          <xsl:variable name="lower" select="concat($iso-year,':',$iso-month,':',$iso-day)"/>
          <xsl:variable name="upper" select="concat($iso-year-max,':',$iso-month-max,':',$iso-day-max)"/>
          
          <!--<range field="iso-date" numeric="true">
             <lower>
             <xsl:value-of select="$lower"/>
             </lower>
             <upper>
             <xsl:value-of select="$upper"/>
             </upper>
             </range>-->
          
          <!-- this may not look right, but it is -->
          <and>
             <range numeric="yes" inclusive="yes" field="iso-start-date">
                <upper>
                   <xsl:value-of select="$upper"/>
                </upper>
             </range>
             <range numeric="yes" inclusive="yes" field="iso-end-date">
                <lower>
                   <xsl:value-of select="$lower"/>
                </lower>
             </range>
          </and>
          
       </xsl:if>
       
      <!-- If there are no meta, text queries, or unary nots, output a dummy -->
       <xsl:if test="count($metaParams) = 0 and count($textParam) = 0 and not(param[matches(@name, '.*-exclude')]) and not(param[matches(@name, 'iso-.*')])">
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
                <xsl:attribute name="fields" select="'text title-main author subject note'"/>
                <xsl:attribute name="boosts" select="'0.5  1.0        1.0    0.5     1.0 '"/>
                <xsl:attribute name="slop" select="'10'"/>
                <xsl:attribute name="maxTextSnippets" select="'3'"/>
                <xsl:attribute name="maxMetaSnippets" select="'all'"/>
            </xsl:when>
            <xsl:when test="matches(@name, 'text')">
                <xsl:attribute name="field" select="'text'"/>
                <xsl:attribute name="maxSnippets" select="'3'"/>
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
<!-- Object viewing template                                                -->
<!-- ====================================================================== -->

<xsl:template name="objview">
  
  <and>
    <!-- Fetch just the object of interest -->
    <term field="sysID" maxSnippets="0">
      <xsl:value-of select="$object"/>
    </term>
    
    <!-- Highlight keywords in the data for display -->
    <xsl:apply-templates/>
  </and>
  
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
        </or>
      </xsl:if>
      
      <!-- If sysID was specified in URL, get local recommendations -->
      <xsl:if test="$sysID">
        <xsl:variable name="recs" select="document(concat('http://rec-proto.cdlib.org/cgi-bin/recommendations7.pl?sys_id=', $sysID, '&amp;max_records=', $maxRecords, '&amp;format=XML'))"/>
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

<!-- ====================================================================== -->
<!-- "Add To Bag" template                                                  -->
<!--                                                                        -->
<!-- Adds the document sysID specified in the URL to the bag in the    -->
<!-- current session.                                                       -->
<!-- ====================================================================== -->
  
  <xsl:template name="addToBag">
    <xsl:variable name="sysID" select="string(//param[@name='sysID']/@value)"/>
    <xsl:variable name="newBag">
      <bag>
        <xsl:copy-of select="session:getData('bag')/bag/savedDoc"/>
        <savedDoc sysID="{$sysID}"/>
      </bag>
    </xsl:variable>
    <xsl:value-of select="session:setData('bag', $newBag)"/>
  </xsl:template>
    
<!-- ====================================================================== -->
<!-- "Remove From Bag" template                                             -->
<!--                                                                        -->
<!-- Removes the document sysID specified in the URL from the bag in   -->
<!-- the current session.                                                   -->
<!-- ====================================================================== -->
  
  <xsl:template name="removeFromBag">
    <xsl:variable name="sysID" select="string(//param[@name='sysID']/@value)"/>
    <xsl:variable name="newBag">
      <bag>
        <xsl:copy-of select="session:getData('bag')/bag/savedDoc[not(@sysID=$sysID)]"/>
      </bag>
    </xsl:variable>
    <xsl:value-of select="session:setData('bag', $newBag)"/>
  </xsl:template>
    
<!-- ====================================================================== -->
<!-- "Show Bag" template                                                    -->
<!--                                                                        -->
<!-- Forms a query of all the documents currently in the bag.               -->
<!-- ====================================================================== -->
  
  <xsl:template name="showBag">
    <xsl:variable name="bag" select="session:getData('bag')"/>
    <xsl:if test="$bag/bag/savedDoc">
      <or>
        <xsl:for-each select="$bag/bag/savedDoc">
          <term field="sysID"><xsl:value-of select="@sysID"/></term>
        </xsl:for-each>
      </or>
    </xsl:if>
  </xsl:template>
    
  
<!-- ====================================================================== -->
<!-- "More Like This" template                                              -->
<!--                                                                        -->
<!-- Forms a query of a single document ID, and fetches documents like it.  -->
<!-- ====================================================================== -->
  
  <xsl:template name="moreLike">
    <xsl:variable name="sysID" select="string(//param[@name='sysID']/@value)"/>
    <moreLike minWordLen="{$minWordLen}" maxWordLen="{$maxWordLen}" minDocFreq="{$minDocFreq}" maxDocFreq="{$maxDocFreq}" minTermFreq="{$minTermFreq}" termBoost="{$termBoost}" maxQueryTerms="{$maxQueryTerms}" fields="{$moreLikeFields}" boosts="{$moreLikeBoosts}">
      <term field="sysID"><xsl:value-of select="$sysID"/></term>
    </moreLike>
  </xsl:template>
     
  
<!-- ====================================================================== -->
<!-- Spellcheck Template                                                    -->
<!--                                                                        -->
<!-- Specifies parameters for spellcheck of search terms.                   -->
<!-- ====================================================================== -->

  <xsl:template name="spellcheck">
    <spellcheck suggestionsPerTerm="1"/>
  </xsl:template>
  
</xsl:stylesheet>
