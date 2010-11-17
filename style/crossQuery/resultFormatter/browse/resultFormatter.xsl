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
                              xmlns:xs="http://www.w3.org/2001/XMLSchema">
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="../common/cdlResultFormatterCommon.xsl"/>
  
  <!-- ====================================================================== -->
  <!-- Output Parameters                                                      -->
  <!-- ====================================================================== -->

  <xsl:output method="html" indent="yes" encoding="UTF-8" media-type="text/html" 
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
              omit-xml-declaration="yes" />

  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->
  
  <!-- Removing port for CDL -->
  <xsl:param name="xtfURL" select="replace($root.path, ':[0-9]{4}/', '/')"/>
  
  <xsl:param name="css.path" select="concat($xtfURL, 'css/eschol/')"/>
  
  <xsl:param name="brand" select="'calisphere'"/>
  
  <xsl:param name="sortGroupsBy" select="'totalDocs'"/>
  
  <xsl:param name="sort">
    <xsl:choose>
      <xsl:when test="$facet = 'creator'">
        <xsl:value-of select="'creator'"/>
      </xsl:when>
      <xsl:when test="$facet = 'date'">
        <xsl:value-of select="'year'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'title'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  
  <xsl:param name="sortDocsBy">
    <xsl:choose>
      <xsl:when test="$facet = 'creator'">
        <xsl:value-of select="'sort-creator'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'sort-title'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <!-- ====================================================================== -->
  <!-- Root Template                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$rmode = 'viewAll'">
        <xsl:apply-templates select="crossQueryResult" mode="viewAll"/>
      </xsl:when>
      <xsl:when test="//docHit">
        <xsl:apply-templates select="crossQueryResult" mode="results"/>
      </xsl:when> 
      <xsl:otherwise>
        <xsl:apply-templates select="crossQueryResult" mode="form"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Results Template                                                       -->
  <!-- ====================================================================== -->
  
  <xsl:template match="crossQueryResult" mode="results">
    
    <xsl:variable name="groupString" select="replace(replace($queryString, '[&amp;]*startGroup=[0-9]+', ''), '[&amp;]*group=[0-9A-Za-z\-\+:''%% ]+', '')"/>
    <xsl:variable name="sortString" select="replace($groupString, '[&amp;]*sortGroupsBy=[0-9A-Za-z\-\+''%% ]+', '')"/>
    
    <html>
      <head>
        <title>Grouping Test</title>
        <!-- xsl:copy-of select="$brand.links"/ -->
      </head>
      <body style="margin: 5%">  
        <!-- xsl:copy-of select="$brand.header"/ -->
        <table style="border: 1px solid black" width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td colspan="3">
              <xsl:if test="$group or $keyword">
                <xsl:call-template name="browseHistory"/>
              </xsl:if>
              <table style="border-left: 1px solid black; border-right: 1px solid black" width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="left">
                    <!-- Top Tabs: Removed becasue of performance/display problems-->
                    <!--<table width="100%" border="0" cellpadding="0" cellspacing="0">
                      <tr>
                        <xsl:choose>
                          <xsl:when test="facet/group">
                            <xsl:apply-templates select="facet/group" mode="showGroups"/>
                          </xsl:when>
                          <xsl:when test="//docHit"/>
                          <xsl:otherwise>
                            <td>
                              <xsl:text>Sorry, no results...</xsl:text>
                            </td>
                          </xsl:otherwise>
                        </xsl:choose>
                      </tr>
                    </table>-->
                  </td>
                  <td align="right" valign="bottom">
                    <form name="search-form" method="get" action="{$xtfURL}{$crossqueryPath}" style="margin: 0">
                      <input type="text" name="keyword" size="30" maxlength="60" value="{$keyword}"/>
                      <input type="hidden" name="fieldList" value="text title creator year description"/> 
                      <input type="hidden" name="relation-exclude" value="{$relation-exclude}"/>
                      <input type="hidden" name="facet" value="{$facet}"/>
                      <input type="hidden" name="group" value="{$group}"/>
                      <input type="hidden" name="sort" value="{$sort}"/>
                      <input type="hidden" name="style" value="{$style}"/>
                      <!-- input type="hidden" name="brand" value="{$brand}"/ -->
                      <xsl:text>&#160;&#160;</xsl:text>
                      <input type="submit" value="&gt;"/>
                    </form>
                  </td>
                </tr>
              </table>
              <table style="border: 1px solid black" width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr>
                  <td valign="top">
                    <table width="100%" border="0" cellpadding="2" cellspacing="2">
                      <xsl:choose>
                        <xsl:when test="facet//group[docHit]">
                          <xsl:apply-templates select="facet//group[docHit]" mode="showHits"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:call-template name="allHits"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
        <!-- xsl:copy-of select="$brand.footer"/ -->
      </body>
    </html>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Search Form Template                                                   -->
  <!-- ====================================================================== -->  
  
  <xsl:template match="crossQueryResult" mode="form">
    
    <html>
      <head>
        <title>Calisphere: Search Form</title>
        <!-- xsl:copy-of select="$brand.links"/ -->
      </head>
      <body style="margin: 5%">
        <!-- xsl:copy-of select="$brand.header"/ -->
        <table style="border: 1px solid black" width="100%" border="0" cellpadding="0" cellspacing="0">       
          <tr>
            <td align="left" valign="top">
              <br/>
              <xsl:choose>
                <xsl:when test="contains($smode, 'advanced')">
                  <xsl:text> | </xsl:text>
                  <a href="{$xtfURL}{$crossqueryPath}?style={$style}&amp;brand={$brand}">Keyword Search</a>
                  <xsl:text> | Advanced Search |</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>| Keyword Search | </xsl:text>
                  <a href="{$xtfURL}{$crossqueryPath}?style={$style}&amp;brand={$brand}&amp;smode=advanced">Advanced Search</a>      
                  <xsl:text> | </xsl:text>                 
                </xsl:otherwise>
              </xsl:choose>
              <a href="{$xtfURL}{$crossqueryPath}?style={$style}&amp;rmode=viewAll&amp;relation-exclude=escholarship.cdlib.org&amp;brand={$brand}">Browse</a>
              <xsl:text> | </xsl:text>
              <hr/>
              <xsl:if test="matches($queryString, 'text|title|creator|subject|description|publisher|contributor|date|type|format|identifier|source|language|relation|coverage|rights|year|keyword')
                and not(docHit)">
                <xsl:if test="$group or $keyword">
                  <xsl:call-template name="browseHistory"/>
                </xsl:if>
                <xsl:text>Your search for </xsl:text>
                <!-- DO BETTER -->
                <xsl:call-template name="format-query">
                  <xsl:with-param name="query" select="$queryString"/>
                </xsl:call-template>
                <xsl:text> found </xsl:text>
                <xsl:value-of select="@totalDocs"/>
                <xsl:text> items. </xsl:text>   
                <hr/>
              </xsl:if>
              <xsl:choose>
                <xsl:when test="contains($smode, 'advanced')">
                  <form name="search-form" method="get" action="{$xtfURL}{$crossqueryPath}">
                    <table border="0">
                      <tr>
                        <td>Keyword: </td>
                        <td>
                          <input name="text" type="text" size="30" maxlength="60" value="{$text}"/>
                          <xsl:text>&#160;</xsl:text>
                          <input type="submit" value="Go!"/> 
                        </td>
                      </tr>
                      <tr>
                        <td>Title: </td>
                        <td>
                          <input name="title" type="text" size="30" maxlength="60" value="{$title}"/>
                        </td>
                      </tr>
                      <tr>
                        <td>Author: </td>
                        <td>
                          <input name="creator" type="text" size="30" maxlength="60" value="{$creator}"/>
                        </td>
                      </tr>
                      <tr>
                        <td>Subject: </td>
                        <td>
                          <input name="subject" type="text" size="30" maxlength="60" value="{$subject}"/>
                        </td>
                      </tr>
                      <tr>
                        <td>Publisher: </td>
                        <td>
                          <input name="publisher" type="text" size="30" maxlength="60" value="{$publisher}"/>
                        </td>
                      </tr>
                      <tr>
                        <td>Description: </td>
                        <td>
                          <input name="description" type="text" size="30" maxlength="60" value="{$description}"/>
                        </td>
                      </tr>
                    </table>
                    <input type="hidden" name="fieldList" value="text title creator year description"/>
                    <input type="hidden" name="relation-exclude" value="escholarship.cdlib.org"/>
                    <input type="hidden" name="smode">
                      <xsl:attribute name="value" select="replace($smode, '-modify', '')"/>
                    </input>
                    <input type="hidden" name="rmode" value="{$rmode}"/>
                    <input type="hidden" name="facet" value="type-1"/>
                    <input type="hidden" name="style" value="{$style}"/>
                    <!-- input type="hidden" name="brand" value="{$brand}"/ -->
                  </form>
                </xsl:when>
                <xsl:otherwise>
                  <form name="search-form" method="get" action="{$xtfURL}{$crossqueryPath}">
                    <table border="0">
                      <tr>
                        <td>Keyword:</td>
                        <td align="left">
                          <input name="keyword" type="text" size="40"  maxlength="60" value="{$keyword}"/>
                          <xsl:text>&#160;</xsl:text>
                          <input type="submit" value="Go!"/>
                        </td>
                      </tr>
                    </table>
                    <input type="hidden" name="fieldList" value="text title creator year description"/> 
                    <input type="hidden" name="relation-exclude" value="escholarship.cdlib.org"/>
                    <input type="hidden" name="smode">
                      <xsl:attribute name="value" select="replace($smode, '-modify', '')"/>
                    </input>
                    <input type="hidden" name="rmode" value="{$rmode}"/>
                    <input type="hidden" name="facet" value="type-1"/>
                    <input type="hidden" name="style" value="{$style}"/>
                    <input type="hidden" name="brand" value="{$brand}"/>
                  </form>
                </xsl:otherwise>
              </xsl:choose>
              <hr/>
            </td>
          </tr>     
        </table>
        <xsl:copy-of select="$brand.footer"/>             
      </body>
    </html>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- All Hits Template                                                      -->
  <!-- ====================================================================== -->
  
  <xsl:template name="allHits">
    <xsl:variable name="totalDocs" select="@totalDocs"/>
    <tr>
      <td align="center" width="40%" style="border-bottom: 1px solid black; border-right: 1px solid black; background-color: silver">
        <xsl:call-template name="page-summary">
          <xsl:with-param name="object-type" select="'Hits'"/>
        </xsl:call-template>
      </td>
      <td align="center" style="border-bottom: 1px solid black; border-right: 1px solid black; background-color: silver">
        <!-- Rosalie doesn't want sort -->
        <!--<xsl:call-template name="sort"/>-->
        <a href="search?style=browse&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll">Browse Metadata</a>
      </td>
      <td align="center" width="40%" style="border-bottom: 1px solid black; background-color: silver">
        <xsl:if test="$totalDocs > $docsPerPage">
          <xsl:call-template name="pages"/>
        </xsl:if>
      </td>
    </tr>
    <tr>
      <td colspan="3">
        <table width="100%">
          <xsl:apply-templates select="docHit"/>
        </table>
      </td>
    </tr>
    <tr>
      <td colspan="3" align="center">
        <xsl:if test="$totalDocs > $docsPerPage">
          <xsl:call-template name="pages"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Groups Template                                                    -->
  <!-- ====================================================================== -->
  
  <xsl:template match="group" mode="showGroups">
    <xsl:variable name="newGroup" select="replace(@value, '\+', '%2B')"/>
    <xsl:variable name="groupString" select="replace(replace($queryString, '[&amp;]*startGroup=[0-9]+', ''), '[&amp;]*group=[0-9A-Za-z\-\+:''%% ]+', '')"/>
    <xsl:variable name="sortString" select="replace($groupString, '[&amp;]*sortGroupsBy=[0-9A-Za-z\-\+''%% ]+', '')"/>
    <td align="center">
      <xsl:attribute name="style">
        <xsl:choose>
          <!-- NEEDS WORK -->
          <xsl:when test="(docHit or not(parent::*/group/docHit)) and not(@totalDocs = 0)">
            <xsl:value-of select="'border-right: 1px solid black; background-color: silver'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'border-right: 1px solid black'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="docHit or @totalDocs=0">
          <xsl:value-of select="@value"/>
        </xsl:when>
        <xsl:otherwise>
          <a href="{$xtfURL}{$crossqueryPath}?{$groupString}&amp;group={$newGroup}&amp;startGroup={$startGroup}">
            <xsl:value-of select="@value"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="@totalDocs"/>
      <xsl:text>)</xsl:text>
    </td>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Group Hits Template                                                    -->
  <!-- ====================================================================== -->
  
  <xsl:template match="group" mode="showHits">
    <xsl:variable name="totalDocs" select="@totalDocs"/>
    <tr>
      <td align="center" width="40%" style="border-bottom: 1px solid black; border-right: 1px solid black; background-color: silver">
        <xsl:call-template name="page-summary">
          <xsl:with-param name="object-type" select="'Hits'"/>
        </xsl:call-template>
      </td>
      <td align="center" style="border-bottom: 1px solid black; border-right: 1px solid black; background-color: silver">
        <a href="search?style=browse&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll">Browse Metadata</a>
      </td>
      <td align="center" width="40%" style="border-bottom: 1px solid black; background-color: silver">
        <xsl:if test="$totalDocs > $docsPerPage">
          <xsl:call-template name="pages"/>
        </xsl:if>
      </td>
    </tr>
    <tr>
      <td colspan="3">
        <table width="100%">
          <xsl:apply-templates select="docHit"/>
        </table>
      </td>
    </tr>
    <tr>
      <td colspan="3" align="center">
        <xsl:if test="$totalDocs > $docsPerPage">
          <xsl:call-template name="pages"/>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Document Hit Template                                                  -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit">
    
    <xsl:variable name="fullark" select="meta/identifier[1]"/>
    
    <tr>
      <td valign="top">
        <xsl:value-of select="@rank"/><xsl:text>.</xsl:text>
      </td>
      <xsl:if test="meta/type = 'image'">
        <td valign="top">
          <img width="200px">
            <xsl:attribute name="src">
              <xsl:value-of select="meta/identifier[1]"/>
              <xsl:text>/thumbnail</xsl:text>
            </xsl:attribute>
          </img>
        </td>
      </xsl:if>
      <td valign="top" align="left">
        <xsl:if test="meta/type='text'">
          <xsl:attribute name="colspan" select="'2'"/>
        </xsl:if>
        <a>
          <xsl:attribute name="name">
            <xsl:value-of select="replace(meta/identifier[1], '.+13030/', '')"/>
          </xsl:attribute>
        </a>
        <strong>Title: </strong>
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="dynaxml.url">
              <xsl:with-param name="fullark" select="$fullark"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="meta/title[1]"/>
        </a>
        <br/>
        <xsl:if test="meta/creator and meta/type = 'text'">
          <strong>Author: </strong>
          <xsl:value-of select="meta/creator[1]"/>
          <br/>
        </xsl:if>
        <xsl:if test="meta/publisher">
          <strong>Publisher: </strong>
          <xsl:apply-templates select="meta/publisher[1]"/>
          <br/>
        </xsl:if>    
        <xsl:if test="meta/sort-year">
          <strong>Date: </strong>
          <xsl:apply-templates select="meta/sort-year[1]"/>
          <br/>
        </xsl:if>          
        <xsl:if test="meta/subject">
          <strong>Subjects: </strong>
          <xsl:apply-templates select="meta/subject"/>
          <br/>
        </xsl:if>   
        <xsl:if test="normalize-space(meta/description[1]) != ''">
          <strong>Description: </strong>
          <xsl:call-template name="moreBlock">
            <xsl:with-param name="block" select="meta/description[1]"/>
            <xsl:with-param name="identifier" select="replace(meta/identifier[1], '.+13030/', '')"/>
          </xsl:call-template>
          <br/>
        </xsl:if>
        <xsl:if test="meta/relation-from">
          <xsl:variable name="relation" select="meta/relation-from[1]"/>
          <xsl:variable name="href" select="substring-before($relation, '|')"/>
          <xsl:variable name="label" select="substring-after($relation, '|')"/>
          <strong>From: </strong>
          <a href="{$href}">
            <xsl:value-of select="$label"/>
          </a>
          <br/>
        </xsl:if>          
        <xsl:if test="meta/identifier">
          <strong>Identifier: </strong>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="dynaxml.url">
                <xsl:with-param name="fullark" select="$fullark"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="meta/identifier[1]"/>
          </a>
          <br/>
        </xsl:if>
        <xsl:if test="snippet">          
          <strong>Search terms in context (<xsl:value-of select="@totalHits"/>):</strong>
          <br/>
          <xsl:apply-templates select="snippet"/>
        </xsl:if>
      </td>
    </tr>
    <tr>
      <td colspan="3">
        <hr/>
      </td>
    </tr>
    
  </xsl:template>
        
  <!-- ====================================================================== -->
  <!-- Snippet Template                                                       -->
  <!-- ====================================================================== -->

  <xsl:template match="snippet[parent::docHit]">
    <xsl:text>...</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>...</xsl:text>
    <br/>
  </xsl:template>
    
  <!-- ====================================================================== -->
  <!-- Hit Template                                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="hit">
    <span style="background-color: silver">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
    
  <!-- ====================================================================== -->
  <!-- Term Template                                                          -->
  <!-- ====================================================================== -->
 
  <xsl:template match="term">
    <xsl:variable name="fullark" select="ancestor::docHit/meta/identifier[1]"/>
    <xsl:variable name="hit.rank"><xsl:value-of select="ancestor::snippet/@rank"/></xsl:variable>
    
    <xsl:variable name="snippet.link">    
      <xsl:call-template name="dynaxml.url">
        <xsl:with-param name="fullark" select="$fullark"/>
      </xsl:call-template>
      <xsl:value-of select="concat('&amp;hit.rank=', $hit.rank)"/>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="ancestor::snippet[parent::docHit]">
        <a href="{$snippet.link}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose> 
   
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Hit Sort Template                                                      -->
  <!-- ====================================================================== -->
  
  <xsl:template name="sort">
    <xsl:variable name="sortString" select="replace($queryString, '[&amp;]*sort=[a-z\-]+', '')"/>
    <xsl:choose>
      <xsl:when test="$sort='title'">
        <xsl:text>Sort by: title | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=creator">author</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=publisher">publisher</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=year">date</a>
      </xsl:when>
      <xsl:when test="$sort='creator'">
        <xsl:text>Sort by: </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=title">title</a>
        <xsl:text> | author | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=publisher">publisher</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=year">date</a>
      </xsl:when>
      <xsl:when test="$sort='publisher'">
        <xsl:text>Sort by: </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=title">title</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=creator">author</a>
        <xsl:text> | publisher | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=year">date</a>
      </xsl:when>
      <xsl:when test="$sort='year'">
        <xsl:text>Sort by: </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=title">title</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=creator">author</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sort=publisher">publisher</a>
        <xsl:text> | date</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>  
  
  <!-- ====================================================================== -->
  <!-- Group Sort Template                                                    -->
  <!-- ====================================================================== -->
  
  <xsl:template name="group-sort">
    <xsl:variable name="sortString" select="replace($queryString, '[&amp;]*sortDocsBy=[a-z\-]+', '')"/>
    <xsl:choose>
      <xsl:when test="$sortDocsBy='sort-title'">
        <xsl:text>Sort by: title | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-creator">author</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-publisher">publisher</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-year">date</a>
      </xsl:when>
      <xsl:when test="$sortDocsBy='sort-creator'">
        <xsl:text>Sort by: </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-title">title</a>
        <xsl:text> | author | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-publisher">publisher</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-year">date</a>
      </xsl:when>
      <xsl:when test="$sortDocsBy='sort-publisher'">
        <xsl:text>Sort by: </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-title">title</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-creator">author</a>
        <xsl:text> | publisher | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-year">date</a>
      </xsl:when>
      <xsl:when test="$sortDocsBy='sort-year'">
        <xsl:text>Sort by: </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-title">title</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-creator">author</a>
        <xsl:text> | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortDocsBy=sort-publisher">publisher</a>
        <xsl:text> | date</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Browse History                                                         -->
  <!-- ====================================================================== -->  
  
  <xsl:template name="browseHistory">
    
    <xsl:variable name="clearStart" select="replace($queryString, '[&amp;]*startGroup=[0-9]+', '')"/>
    
    <table style="border: 1px solid black" width="100%" border="0" cellpadding="2" cellspacing="2">
      <tr>
        <td align="left">
          <b>Browse History:</b>
        </td>
        <td align="right">
          <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
          <a href="{$xtfURL}{$crossqueryPath}?style=browse&amp;brand={$brand}&amp;relation-exclude={$relation-exclude}&amp;facet=type-1">
            <xsl:text>clear all</xsl:text>
          </a>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <xsl:if test="$group">
            <xsl:variable name="groupClear" select="replace($clearStart, '[&amp;]*group=[0-9A-Za-z\-\+:''%% ]+', '')"/>
            <xsl:text>&#160;&#160;&#160;&#160;Group: </xsl:text>
            <xsl:value-of select="$group"/>
            <xsl:text>&#160;</xsl:text>
            <a href="{$xtfURL}{$crossqueryPath}?{$groupClear}">
              <xsl:text>clear</xsl:text>
            </a>
          </xsl:if>
          <xsl:if test="$keyword">
            <xsl:variable name="keywordClear" select="replace(replace(replace($clearStart, '[&amp;]*keyword=[0-9A-Za-z\-\+:''%% ]+', ''), '[&amp;]*fieldList=[0-9A-Za-z \+]+', ''), '^&amp;', '')"/>
            <xsl:text>&#160;&#160;&#160;&#160;Keyword: </xsl:text>
            <xsl:value-of select="$keyword"/>
            <xsl:text>&#160;</xsl:text>
            <a href="{$xtfURL}{$crossqueryPath}?{$keywordClear}">
              <xsl:text>clear</xsl:text>
            </a>
          </xsl:if>
<!--          <xsl:if test="$subject">
            <xsl:variable name="subjectClear" select="replace(replace($clearStart, '[&amp;]*subject=[0-9A-Za-z\-\.\(\)\[\],,;;//\+''%% ]+', ''), '[&amp;]*subject-join=[a-z]+', '')"/>
            <xsl:text>&#160;&#160;&#160;&#160;Subject: </xsl:text>
            <xsl:value-of select="$subject"/>
            <xsl:text>&#160;</xsl:text>
            <a href="{$xtfURL}{$crossqueryPath}?{$subjectClear}">
              <xsl:text>clear</xsl:text>
            </a>
          </xsl:if>-->
        </td>
      </tr>
    </table>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Metadata Browse                                                        -->
  <!-- ====================================================================== -->
    
  <xsl:template match="crossQueryResult" mode="viewAll">
    <xsl:variable name="groupString" select="replace(replace($queryString, '[&amp;]*startGroup=[0-9]+', ''), '[&amp;]*group=[0-9A-Za-z\-\+:''%% ]+', '')"/>
    <xsl:variable name="sortString" select="replace($groupString, '[&amp;]*sortGroupsBy=[0-9A-Za-z\-\+''%% ]+', '')"/>
    
    <html>
      <head>
        <title>Calisphere: Metadata Browse</title>
        <!-- xsl:copy-of select="$brand.links"/ -->
      </head>
      <body style="margin: 5%">
        <!-- xsl:copy-of select="$brand.header"/ -->
        <table style="border: 1px solid black" width="100%" border="0" cellpadding="0" cellspacing="0">  
          <tr>
            <td align="center">
              <a href="search?style=browse&amp;facet=title&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">title</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=creator&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">creator</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=subject&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">subject</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=description&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">description</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=publisher&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">publisher</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=contributor&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">contributor</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=date&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">date</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=type-1&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">type-1</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=type-2&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">type-2</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=type-3&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">type-3</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=format&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">format</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=identifier&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">identifier</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=source&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">source</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=language&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">language</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=relation&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">relation</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=coverage&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">coverage</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=browse&amp;facet=rights&amp;relation-exclude={$relation-exclude}&amp;brand={$brand}&amp;rmode=viewAll&amp;sortGroupsBy=totalDocs&amp;groupsPerPage=100">rights</a>
            </td>
          </tr>
          <xsl:if test="facet">
            <xsl:variable name="missing">
              <xsl:choose>
                <xsl:when test="facet/group[@value='1 MISSING']">
                  <xsl:value-of select="number(facet/group[@value='1 MISSING']/@totalDocs)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="number(0)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <tr>
              <td align="center" style="border: solid black 1px">
                <h4>dc element: <xsl:value-of select="$facet"/></h4>
                <p>(Present in <xsl:value-of select="number(facet/@totalDocs) - $missing"/> of <xsl:value-of select="@totalDocs"/> records.)</p>
                <xsl:call-template name="page-summary">
                  <xsl:with-param name="object-type" select="'Groups'"/>
                  <xsl:with-param name="groups" select="'yes'"/>
                </xsl:call-template>
                <br/>
                <xsl:call-template name="pages">
                  <xsl:with-param name="groups" select="'yes'"/>
                </xsl:call-template>
                <br/>
                <xsl:choose>
                  <xsl:when test="$sortGroupsBy='value'">
                    <xsl:text>Sort by: </xsl:text>
                    <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortGroupsBy=totalDocs">count</a>
                    <xsl:text> | alpha</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Sort by: </xsl:text>
                    <xsl:text>count | </xsl:text>
                    <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortGroupsBy=value">alpha</a>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td align="left">
                <ol>
                  <xsl:apply-templates select="facet/group" mode="browseGroups"/>
                </ol>
              </td>
            </tr>
          </xsl:if>
        </table>
        <!-- xsl:copy-of select="$brand.footer"/ -->
      </body>
    </html>
    
  </xsl:template>
  
  <xsl:template match="group" mode="browseGroups">
    <!-- xsl:variable name="facet" select="replace(replace(parent::facet/@field, 'facet-', ''), '-[0-9]+', '')"/ -->
    <xsl:variable name="value" select="replace(@value, '\+', '%2B')"/>
    <li value="{@rank}">
      <a href="{$xtfURL}{$crossqueryPath}?facet={$facet}&amp;group={$value}&amp;relation-exclude={$relation-exclude}&amp;style={$style}&amp;brand={$brand}">
        <xsl:value-of select="@value"/>
      </a>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="@totalDocs"/>
      <xsl:text>) </xsl:text>
    HEY</li>
  </xsl:template>
  
</xsl:stylesheet>
