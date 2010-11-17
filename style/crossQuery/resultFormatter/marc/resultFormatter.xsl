<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

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

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                              xmlns:xtf="http://cdlib.org/xtf"
                              xmlns:dc="http://purl.org/dc/elements/1.1/" 
                              xmlns:mets="http://www.loc.gov/METS/" 
                              xmlns:xlink="http://www.w3.org/TR/xlink" 
                              xmlns:xs="http://www.w3.org/2001/XMLSchema"
                              xmlns:session="java:org.cdlib.xtf.xslt.Session"
                              xmlns:sql="java:/org.cdlib.xtf.saxonExt.SQL"
                              extension-element-prefixes="sql">
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="../common/cdlResultFormatterCommon.xsl"/>
  
  <!-- ====================================================================== -->
  <!-- Import FRBR Templates                                                  -->
  <!-- ====================================================================== -->
  
  <xsl:import href="FRBRize.xsl"/>
  <xsl:import href="FRBRFacetFormatter.xsl"/>
  
  <!-- ====================================================================== -->
  <!-- Output Parameters                                                      -->
  <!-- ====================================================================== -->

  <xsl:output method="html" indent="yes" encoding="UTF-8" media-type="text/html" doctype-public="-//W3C//DTD HTML 4.0//EN"/>

  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->
  
  <!-- Not sure why we were using absolute URLs, but relative works better for
       tracking session IDs in the URL if cookies are disabled. So for now,
       setting $xtfURL to empty string accomplishes this. -->
  <xsl:param name="xtfURL" select="''"/>
  <!-- Removing port for CDL -->
  <!--<xsl:param name="xtfURL" select="replace($root.path, ':[0-9]{4}/', '/')"/>-->
  
  <!-- Display parameters -->
  <xsl:param name="rmode"/>
  <xsl:param name="smode"/>
  <xsl:param name="frbrize"/>
  
  <!-- Selected object -->
  <xsl:param name="object"/>
  
  <!-- Weight file selection -->
  <xsl:param name="weight"/>
  
  <!-- Recommendation parameters -->
  <xsl:param name="maxRecords" as="xs:integer" select="5"/>
  
  <!-- moreLike parameters -->
  <xsl:param name="explainScores"/>
  <xsl:param name="minWordLen" select="4"/>
  <xsl:param name="maxWordLen" select="50"/>
  <xsl:param name="minDocFreq" select="2"/>
  <xsl:param name="maxDocFreq" select="-1"/>
  <xsl:param name="minTermFreq" select="1"/>
  <xsl:param name="termBoost" select="'yes'"/>
  <xsl:param name="maxQueryTerms" select="10"/>
  <xsl:param name="moreLikeFields" select="'author,callnum,callnum-class,catAuthority,facet-subject,title-main,subject,year'"/>
  <xsl:param name="moreLikeBoosts" select="'0,0,0,0,0,0,1,0'"/>
  
  <!-- login parameters -->
  <xsl:param name="userID"/>
  <xsl:param name="password"/>
  
  <!-- Multi-field keyword search -->
  <xsl:param name="keyword"/>
  <xsl:param name="keyword-join"/>
  <xsl:param name="keyword-prox"/>
  <xsl:param name="keyword-exclude"/>
  <xsl:param name="keyword-max"/>

  <xsl:param name="fieldList"/>
  
  <!-- Index field parameters -->
 
  <xsl:param name="author"/>
  <xsl:param name="author-join"/>
  <xsl:param name="author-prox"/>
  <xsl:param name="author-exclude"/>
  <xsl:param name="author-max"/>

  <xsl:param name="author-corporate"/>
  <xsl:param name="author-corporate-join"/>
  <xsl:param name="author-corporate-prox"/>
  <xsl:param name="author-corporate-exclude"/>
  <xsl:param name="author-corporate-max"/>
  
  <xsl:param name="callnum-class"/>
  <xsl:param name="callnum-class-join"/>
  <xsl:param name="callnum-class-prox"/>
  <xsl:param name="callnum-class-exclude"/>
  <xsl:param name="callnum-class-max"/>
  
  <xsl:param name="identifier-isbn"/>
  <xsl:param name="identifier-isbn-join"/>
  <xsl:param name="identifier-isbn-prox"/>
  <xsl:param name="identifier-isbn-exclude"/>
  <xsl:param name="identifier-isbn-max"/>
  
  <xsl:param name="identifier-issn"/>
  <xsl:param name="identifier-issn-join"/>
  <xsl:param name="identifier-issn-prox"/>
  <xsl:param name="identifier-issn-exclude"/>
  <xsl:param name="identifier-issn-max"/>
  
  <xsl:param name="language"/>
  <xsl:param name="language-join"/>
  <xsl:param name="language-prox"/>
  <xsl:param name="language-exclude"/>
  <xsl:param name="language-max"/>
  
  <xsl:param name="location"/>
  <xsl:param name="location-join"/>
  <xsl:param name="location-prox"/>
  <xsl:param name="location-exclude"/>
  <xsl:param name="location-max"/>

  <xsl:param name="note"/>
  <xsl:param name="note-join"/>
  <xsl:param name="note-prox"/>
  <xsl:param name="note-exclude"/>
  <xsl:param name="note-max"/>
  
  <xsl:param name="publisher"/>
  <xsl:param name="publisher-join"/>
  <xsl:param name="publisher-prox"/>
  <xsl:param name="publisher-exclude"/>
  <xsl:param name="publisher-max"/>

  <xsl:param name="pub-place"/>
  <xsl:param name="pub-place-join"/>
  <xsl:param name="pub-place-prox"/>
  <xsl:param name="pub-place-exclude"/>
  <xsl:param name="pub-place-max"/>

  <xsl:param name="subject"/>
  <xsl:param name="subject-join"/>
  <xsl:param name="subject-prox"/>
  <xsl:param name="subject-exclude"/>
  <xsl:param name="subject-max"/>
  
  <xsl:param name="subject-geographic"/>
  <xsl:param name="subject-geographic-join"/>
  <xsl:param name="subject-geographic-prox"/>
  <xsl:param name="subject-geographic-exclude"/>
  <xsl:param name="subject-geographic-max"/>
  
  <xsl:param name="subject-temporal"/>
  <xsl:param name="subject-temporal-join"/>
  <xsl:param name="subject-temporal-prox"/>
  <xsl:param name="subject-temporal-exclude"/>
  <xsl:param name="subject-temporal-max"/>
  
  <xsl:param name="subject-topic"/>
  <xsl:param name="subject-topic-join"/>
  <xsl:param name="subject-topic-prox"/>
  <xsl:param name="subject-topic-exclude"/>
  <xsl:param name="subject-topic-max"/>
  
  <xsl:param name="sysID"/>
  <xsl:param name="sysID-join"/>
  <xsl:param name="sysID-prox"/>
  <xsl:param name="sysID-exclude"/>
  <xsl:param name="sysID-max"/>
  
  <xsl:param name="title-journal"/>
  <xsl:param name="title-journal-join"/>
  <xsl:param name="title-journal-prox"/>
  <xsl:param name="title-journal-exclude"/>
  <xsl:param name="title-journal-max"/>
  
  <xsl:param name="title-main"/>
  <xsl:param name="title-main-join"/>
  <xsl:param name="title-main-prox"/>
  <xsl:param name="title-main-exclude"/>
  <xsl:param name="title-main-max"/>
  
  <xsl:param name="title-series"/>
  <xsl:param name="title-series-join"/>
  <xsl:param name="title-series-prox"/>
  <xsl:param name="title-series-exclude"/>
  <xsl:param name="title-series-max"/>

  <xsl:param name="year"/>
  <xsl:param name="year-join"/>
  <xsl:param name="year-prox"/>
  <xsl:param name="year-exclude"/>
   <xsl:param name="year-max"/>
   <xsl:param name="iso-year"/>
   <xsl:param name="iso-year-max"/>
  
  <xsl:param name="origin"/>
  <xsl:param name="origin-join"/>
  <xsl:param name="origin-prox"/>
  <xsl:param name="origin-exclude"/>
  <xsl:param name="origin-max"/>
  
  <!-- ====================================================================== -->
  <!-- Recreating Search Parameters                                           -->
  <!-- ====================================================================== -->
  
    <xsl:variable name="completeString" select="concat('|keyword=',$keyword,
                                                       '|author=',$author,
                                                       '|author-corporate=',$author-corporate,
                                                       '|callnum-class=',$callnum-class,
                                                       '|identifier-isbn=',$identifier-isbn,
                                                       '|identifier-issn=',$identifier-issn,
                                                       '|publisher=',$publisher,
                                                       '|pub-place=',$pub-place,
                                                       '|subject=',$subject,
                                                       '|subject-geographic=',$subject-geographic,
                                                       '|subject-temporal=',$subject-temporal,
                                                       '|subject-topic=',$subject-topic,
                                                       '|sysID=',$sysID,
                                                       '|title-journal=',$title-journal,
                                                       '|title-main=',$title-main,
                                                       '|title-series=',$title-series,
                                                       '|keyword-join=',$keyword-join,
                                                       '|author-join=',$author-join,
                                                       '|author-corporate-join=',$author-corporate-join,
                                                       '|callnum-class-join=',$callnum-class-join,
                                                       '|identifier-isbn-join=',$identifier-isbn-join,
                                                       '|identifier-issn-join=',$identifier-issn-join,
                                                       '|publisher-join=',$publisher-join,
                                                       '|pub-place-join=',$pub-place-join,
                                                       '|subject-join=',$subject-join,
                                                       '|subject-geographic-join=',$subject-geographic-join,
                                                       '|subject-temporal-join=',$subject-temporal-join,
                                                       '|subject-topic-join=',$subject-topic-join,
                                                       '|sysID-join=',$sysID-join,
                                                       '|title-journal-join=',$title-journal-join,
                                                       '|title-main-join=',$title-main-join,
                                                       '|title-series-join=',$title-series-join,
                                                       '|')"/>
  
  <xsl:variable name="cleanString" select="replace(replace($completeString,'[A-Za-z\-]+=\|',''),'\|$','')"/>
  
  <xsl:param name="param1">
    <xsl:analyze-string select="$cleanString" regex="^([0-9A-Za-z\-]+)=[0-9A-Za-z\-\+'' &quot;]+">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:param>  
  <xsl:param name="value1">
    <xsl:analyze-string select="$cleanString" regex="^[0-9A-Za-z\-]+=([0-9A-Za-z\-\+'' &quot;]+)">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:param>  
  <xsl:param name="join1">
    <xsl:analyze-string select="$cleanString" regex="\|[0-9A-Za-z\-]+-join=([a-z]+)\|?">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:param>
  
  <xsl:param name="param2">
    <xsl:analyze-string select="$cleanString" regex="^[0-9A-Za-z\-]+=[0-9A-Za-z\-\+'' &quot;]+\|([0-9A-Za-z\-]+)=[0-9A-Za-z\-\+'' &quot;]+\|?">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:param>  
  <xsl:param name="value2">
    <xsl:analyze-string select="$cleanString" regex="^[0-9A-Za-z\-]+=[0-9A-Za-z\-\+'' &quot;]+\|[0-9A-Za-z\-]+=([0-9A-Za-z\-\+'' &quot;]+)\|?">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:param>  
  <xsl:param name="join2">
    <xsl:analyze-string select="$cleanString" regex="[0-9A-Za-z\-]+-join=[a-z]+\|[0-9A-Za-z\-]+-join=([a-z]+)$">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:param>

  <!-- ====================================================================== -->
  <!-- Root Template                                                          -->
  <!-- ====================================================================== -->

  <xsl:template match="/">
    <xsl:choose>
      <!-- for QA testing -->
      <xsl:when test="$smode = 'test'">
        <xsl:apply-templates select="crossQueryResult" mode="test"/>
      </xsl:when>
      <!-- Book Bag -->
      <xsl:when test="$smode = 'addToBag'">
        <span class="harshMellow">Selected</span>
      </xsl:when>
      <xsl:when test="$smode = 'removeFromBag'">
        <!-- No output needed -->
      </xsl:when>
      <!-- Object view -->
      <xsl:when test="starts-with($rmode, 'objview')">
        <xsl:apply-templates select="crossQueryResult" mode="objview"/>
      </xsl:when>
      <!-- Recommendations -->
      <xsl:when test="$rmode = 'getRecommendations'">
        <xsl:apply-templates select="crossQueryResult" mode="getRecommendations"/>
      </xsl:when>
      <!-- moreLike -->
      <xsl:when test="$smode = 'moreLike'">
        <xsl:apply-templates select="crossQueryResult" mode="moreLike"/>
      </xsl:when>
      <!-- login -->
      <xsl:when test="starts-with($smode, 'login-')">
        <xsl:call-template name="login"/>
      </xsl:when>
      <!-- popup -->
      <xsl:when test="contains($rmode,'pop-')">
        <xsl:call-template name="pop">
          <xsl:with-param name="popString">
            <xsl:value-of select="substring-after($rmode,'pop-')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$smode ='showBag'">
        <xsl:apply-templates select="crossQueryResult" mode="bookBag"/>
      </xsl:when>
      <!-- Results -->
      <xsl:when test="
        $keyword or
        $author or
        $author-corporate or
        $callnum-class or
        $format or
        $identifier-isbn or
        $identifier-issn or
        $language or
        $location or
        $publisher or
        $pub-place or
        $subject or
        $subject-temporal or
        $subject-topic or
        $subject-geographic or
        $sysID or 
        $title-main or 
        $title-journal or
        $title-series or
        $year or
        $origin">
        <xsl:apply-templates select="crossQueryResult" mode="results"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="crossQueryResult" mode="form"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Popup Template                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template name="pop">
    <xsl:param name="popString"/>
    <html>
      <head>
        <title>Popup</title>
      </head>
      <body>
        <p>
          <xsl:choose>
            <xsl:when test="$popString='boost'">
              <xsl:text>Relevance boosts use additional data to change the way that relevance is calculated, and therefore the way that results are ordered.  Choose the "circulation" boost to increase scores for items that circulate often; choose the "holdings" boost to increase scores for items held by more UC campus libraries.</xsl:text>
            </xsl:when>
            <xsl:when test="$popString='explain'">
              <xsl:text>"Explain scores" reveals the details of relevance scoring for each item on the results page.</xsl:text>
            </xsl:when>
            <xsl:when test="$popString='frbr'">
              <xsl:text>FRBR groups records that are closely related (our algorithm groups them based on title and author); for example, multiple versions or editions of the same work.  This feature allows you to choose between result sets that are produced with the FRBR algorithm on or off.</xsl:text>
            </xsl:when>
            <xsl:when test="$popString='set'">
              <xsl:text>Similarity settings modify the algorithm used to recommend items based on similarities between bibliographic records.  This algorithm identifies the most important words in the bibliographic record for an item, creates a new query based on those words, then presents the top results of that new query as recommendations. This feature allows you to experiment with different settings, and view different sets of recommendations based on those changes.</xsl:text>
            </xsl:when>
            <xsl:when test="$popString='rec1'">
              <xsl:text>Recommendations based on similarities between records are generated using an algorithm that identifies the most important words in the bibliographic record for an item, and creates a new query based on those characteristics.  The top results of that new query are presented as recommendations.</xsl:text>
            </xsl:when>
            <xsl:when test="$popString='rec2'">
              <xsl:text>Recommendations based on patron borrowing patterns are generated by analyzing circulation data that has been anonymized to protect patron privacy.</xsl:text>
            </xsl:when>
            <xsl:when test="$popString='rec3'">
              <xsl:text>Amazon recommendations are supplied by Amazon's web service.  They are available only for a small portion of the collection.</xsl:text>
            </xsl:when>
            <xsl:when test="$popString='item'">
              <xsl:text>The Relvyl prototype groups records for items that are closely related (based on title and author); for example, multiple versions or editions of the same work. </xsl:text>
            </xsl:when>
          </xsl:choose>
        </p>
        <p>
          <a>
            <xsl:attribute name="href">javascript://</xsl:attribute>
            <xsl:attribute name="onClick">
              <xsl:text>javascript:window.close('popup')</xsl:text>
            </xsl:attribute>
            <span class="down1">Close this Window</span>
          </a>
        </p>
      </body>
    </html>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Form Template                                                          -->
  <!-- ====================================================================== -->

  <xsl:template match="crossQueryResult" mode="form">
    <html>
      <head>
        <title>
          <xsl:text>Relvyl: </xsl:text>
          <xsl:choose>
            <xsl:when test="contains($smode, 'advanced')">
              <xsl:text>Advanced Search</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Search</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </title>
        <xsl:copy-of select="$brand.links"/>
        <script type="text/javascript" src="script/getElementsBySelector.js"/>
        <script type="text/javascript" src="script/behavior.js"/>
        <script type="text/javascript" src="script/dynamicForm.js"/>
        <script src="script/AsyncLoader.js"/>
        <script src="script/MoreLike.js"/>
        <xsl:if test="session:isEnabled()">
          <script src="script/BookBag.js"/>
        </xsl:if>
      </head>
      <body> 
        <xsl:attribute name="id">
          <xsl:choose>
            <xsl:when test="contains($smode, 'advanced')">
              <xsl:value-of select="'search-advanced'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'search-simple'"/>
            </xsl:otherwise>
          </xsl:choose>
          
        </xsl:attribute>
        
        <xsl:call-template name="header"/>
        
        <xsl:choose>
          <xsl:when test="contains($smode, 'advanced')">
            <form>
              <table border="0" id="refine">
                <tr>
                  <td width="60%" valign="top">
                    <h1 class="page-title">Advanced Search</h1>
                    <fieldset id="iset1">
                      <table border="0" id="index1">
                        <xsl:call-template name="search1"/>
                      </table>
                    </fieldset>
                    <fieldset id="iset2">
                      <table border="0" id="index2">
                        <xsl:call-template name="search2"/>
                      </table>
                    </fieldset>
                    <xsl:if test="matches($smode, 'analysis')">
                      <table>
                        <tr>
                          <td>
                            <b>Order Results By </b>
                          </td>
                          <td>
                            <xsl:call-template name="sort.options"/>
                          </td>
                        </tr>
                      </table>
                    </xsl:if>
                  </td>
                  <td valign="top" width="40%">
                    <h2>Limit By</h2>
                    <div id="limits">
                      <xsl:call-template name="limits"/>
                    </div>
                    <xsl:if test="contains($smode, 'analysis')">
                      <br clear="all"/>
                      <h2>
                        <xsl:text>Relevance Boost</xsl:text>
                        <xsl:text>&#160;</xsl:text>
                        <a href="javascript://">
                          <xsl:attribute name="onClick">
                            <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-boost','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
                          </xsl:attribute>
                          <xsl:text>&#160;</xsl:text>
                          <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
                        </a>
                      </h2>
                      <div id="boost">
                        <xsl:call-template name="boostFactor"/>
                      </div>
                    </xsl:if>
                  </td>
                </tr>
                <tr id="buttons">
                  <td colspan="2">
                    <input id="search-submit" class="button" type="submit" value="Search" method="GET" action="{$xtfURL}{$crossqueryPath}"/>
                    <input class="button" type="reset" value="Clear"/>
                    <input type="hidden" name="style" value="{$style}"/>
                    <input type="hidden" name="brand" value="{$brand}"/>
                    <xsl:if test="$sort = 'sysid'">
                      <input type="hidden" name="sort" value="sysid"/>
                    </xsl:if>
                    <xsl:if test="$weight != '' and not(contains($smode, 'analysis'))">
                      <input type="hidden" name="weight" value="{$weight}"/>
                    </xsl:if>
                    <input type="hidden" name="frbrize" value="yes"/>
                    <xsl:if test="contains($smode,'analysis')">
                      <input type="hidden" name="rmode" value="analysis"/>
                    </xsl:if>
                  </td>
                </tr>
              </table>
            </form>
          </xsl:when>
          <xsl:otherwise>
            <div id="content-primary">
              <form method="get" action="{$xtfURL}{$crossqueryPath}">
                <input type="text" name="keyword" size="40" value="{$keyword}"/>
                <input class="button" type="submit" value="Search"/>
                <xsl:if test="matches($smode, 'analysis')">
                  <div align="center">
                    <table cellpadding="5" cellspacing="5">
                      <tr>
                        <td>
                          <b>Order Results By </b>
                        </td>
                        <td>
                          <xsl:call-template name="sort.options"/>
                        </td>
                      </tr>
                      <tr>
                        <td valign="top">
                          <xsl:text>Relevance Boost</xsl:text>
                          <xsl:text>&#160;</xsl:text>
                          <a href="javascript://">
                            <xsl:attribute name="onClick">
                              <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-boost','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
                            </xsl:attribute>
                            <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
                          </a>
                        </td>
                        <td align="right"><xsl:call-template name="boostFactor"/></td>
                      </tr>
                    </table>
                  </div>
                </xsl:if>
                <input type="hidden" name="style" value="{$style}"/>
                <input type="hidden" name="brand" value="{$brand}"/>
                <xsl:if test="$sort = 'sysid'">
                  <input type="hidden" name="sort" value="sysid"/>
                </xsl:if>
                <xsl:if test="$weight != '' and not(contains($smode, 'analysis'))">
                  <input type="hidden" name="weight" value="{$weight}"/>
                </xsl:if>
                <input type="hidden" name="frbrize" value="yes"/>
                <xsl:if test="contains($smode,'analysis')">
                  <input type="hidden" name="rmode" value="analysis"/>
                </xsl:if>
              </form>
            </div>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:copy-of select="$brand.footer"/>
        
      </body>
    </html>
  </xsl:template>

  <xsl:template name="search1">
    <tr>
      <td>
        <select id="select1" class="name-setter name-setter=search-term-a name-setter-with-static-suffix name-setter-with-static-suffix=boolean-type-a static-suffix=-join exclusive-select exclusive-select-id=select2">
          <option value="">
            <xsl:text>[SELECT]</xsl:text>
          </option>
          <option value="keyword">
            <xsl:if test="$param1='keyword'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Keyword</xsl:text>
          </option>
          <option value="title-main">
            <xsl:if test="$param1='title-main'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Title</xsl:text>
          </option>
          <option value="title-journal">
            <xsl:if test="$param1='title-journal'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Title - Journal</xsl:text>
          </option>
          <option value="title-series">
            <xsl:if test="$param1='title-series'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Title - Series</xsl:text>
          </option>
          <option value="author">
            <xsl:if test="$param1='author'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Author</xsl:text>
          </option>
          <option value="author-corporate">
            <xsl:if test="$param1='author-corporate'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Author - Organization</xsl:text>
          </option>
          <option value="subject">
            <xsl:if test="$param1='subject'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Subject</xsl:text>
          </option>
          <option value="subject-geographic">
            <xsl:if test="$param1='subject-geographic'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Subject - Geographic</xsl:text>
          </option>
          <option value="subject-temporal">
            <xsl:if test="$param1='subject-temporal'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Subject - Temporal</xsl:text>
          </option>
          <option value="subject-topic">
            <xsl:if test="$param1='subject-topic'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Subject - Topic</xsl:text>
          </option>
          <option value="publisher">
            <xsl:if test="$param1='publisher'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Publisher</xsl:text>
          </option>
          <option value="identifier-isbn">
            <xsl:if test="$param1='identifier-isbn'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>ISBN</xsl:text>
          </option>
          <option value="identifier-issn">
            <xsl:if test="$param1='identifier-issn'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>ISSN</xsl:text>
          </option>
          <xsl:if test="contains($smode,'analysis')">
            <option value="pub-place">
              <xsl:if test="$param1='pub-place'">
                <xsl:attribute name="selected" select="'selected'"/>
              </xsl:if>
              <xsl:text>Place of Publication</xsl:text>
            </option>
            <option value="callnum-class">
              <xsl:if test="$param1='callnum-class'">
                <xsl:attribute name="selected" select="'selected'"/>
              </xsl:if>
              <xsl:text>Call Number Class</xsl:text>
            </option>
            <option value="sysID">
              <xsl:if test="$param1='sysID'">
                <xsl:attribute name="selected" select="'selected'"/>
              </xsl:if>
              <xsl:text>sysID</xsl:text>
            </option>
          </xsl:if>
        </select>
      </td>
      <td>
        <input type="text" size="40" class="value-setter value-setter=search-term-a search-text" value="{$value1}"/>
      </td>
    </tr>
    <tr>
      <td>&#160;</td>
      <td>
        <input name="boolean-type-a" class="value-setter value-setter=boolean-type-a" type="radio" value="and">
          <xsl:if test="$join1 != 'or'">
            <xsl:attribute name="checked" select="'checked'"/>
          </xsl:if>
        </input>
        <xsl:text>all of these words</xsl:text>
        <input name="boolean-type-a" class="value-setter value-setter=boolean-type-a" type="radio" value="or">
          <xsl:if test="$join1 = 'or'">
            <xsl:attribute name="checked" select="'checked'"/>
          </xsl:if>
        </input>
        <xsl:text>any of these words</xsl:text>
      </td>
    </tr>
  </xsl:template>
  
  <xsl:template name="search2">
    <tr>
      <td>
        <select id="select2" class="name-setter name-setter=search-term-b name-setter-with-static-suffix name-setter-with-static-suffix=boolean-type-b static-suffix=-join exclusive-select exclusive-select-id=select1">
          <option value="">
            <xsl:text>[SELECT]</xsl:text>
          </option>
          <option value="keyword">
            <xsl:if test="$param2='keyword'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Keyword</xsl:text>
          </option>
          <option value="title-main">
            <xsl:if test="$param2='title-main'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Title</xsl:text>
          </option>
          <option value="title-journal">
            <xsl:if test="$param2='title-journal'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Title - Journal</xsl:text>
          </option>
          <option value="title-series">
            <xsl:if test="$param2='title-series'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Title - Series</xsl:text>
          </option>
          <option value="author">
            <xsl:if test="$param2='author'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Author</xsl:text>
          </option>
          <option value="author-corporate">
            <xsl:if test="$param2='author-corporate'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Author - Organization</xsl:text>
          </option>
          <option value="subject">
            <xsl:if test="$param2='subject'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Subject</xsl:text>
          </option>
          <option value="subject-geographic">
            <xsl:if test="$param2='subject-geographic'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Subject - Geographic</xsl:text>
          </option>
          <option value="subject-temporal">
            <xsl:if test="$param2='subject-temporal'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Subject - Temporal</xsl:text>
          </option>
          <option value="subject-topic">
            <xsl:if test="$param2='subject-topic'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Subject - Topic</xsl:text>
          </option>
          <option value="publisher">
            <xsl:if test="$param2='publisher'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>Publisher</xsl:text>
          </option>
          <option value="identifier-isbn">
            <xsl:if test="$param2='identifier-isbn'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>ISBN</xsl:text>
          </option>
          <option value="identifier-issn">
            <xsl:if test="$param2='identifier-issn'">
              <xsl:attribute name="selected" select="'selected'"/>
            </xsl:if>
            <xsl:text>ISSN</xsl:text>
          </option>
          <xsl:if test="contains($smode,'analysis')">
            <option value="pub-place">
              <xsl:if test="$param2='pub-place'">
                <xsl:attribute name="selected" select="'selected'"/>
              </xsl:if>
              <xsl:text>Place of Publication</xsl:text>
            </option>
            <option value="callnum-class">
              <xsl:if test="$param2='callnum-class'">
                <xsl:attribute name="selected" select="'selected'"/>
              </xsl:if>
              <xsl:text>Call Number Class</xsl:text>
            </option>
            <option value="sysID">
              <xsl:if test="$param2='sysID'">
                <xsl:attribute name="selected" select="'selected'"/>
              </xsl:if>
              <xsl:text>sysID</xsl:text>
            </option>
          </xsl:if>
        </select>
      </td>
      <td>
        <input type="text" size="40" class="value-setter value-setter=search-term-b search-text">
          <xsl:if test="not(matches($param2, '-join'))">
            <xsl:attribute name="value" select="$value2"/>
          </xsl:if>
        </input>
      </td>
    </tr>
    <tr>
      <td>&#160;</td>
      <td>
        <input type="radio" name="boolean-type-b" class="value-setter value-setter=boolean-type-b" value="and">
          <xsl:if test="$join2 != 'or'">
            <xsl:attribute name="checked" select="'checked'"/>
          </xsl:if>
        </input>
        <xsl:text>all of these words</xsl:text>
        <input type="radio" name="boolean-type-b" class="value-setter value-setter=boolean-type-b" value="or">
          <xsl:if test="$join2 = 'or'">
            <xsl:attribute name="checked" select="'checked'"/>
          </xsl:if>
        </input>
        <xsl:text>any of these words</xsl:text>
      </td>
    </tr>
  </xsl:template>

  
  <xsl:template name="limits">
    <label for="year">Year</label>
    <input type="text" name="iso-year" size="5" value="{$iso-year}"/>
    <xsl:text> to </xsl:text>
    <input type="text" name="iso-year-max" size="5" value="{$iso-year-max}"/>
    <br/>
    <label for="language">Language</label>
    <select name="language">
      <option value="">ALL languages</option>
      <option value="eng">
        <xsl:if test="$language = 'eng'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>English</xsl:text>
      </option>
      <option value="fre">
        <xsl:if test="$language = 'fre'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>French</xsl:text>
      </option>
      <option value="ger">
        <xsl:if test="$language = 'ger'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>German</xsl:text>
      </option>
      <option value="ita">
        <xsl:if test="$language = 'ita'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Italian</xsl:text>
      </option>
      <option value="lat">
        <xsl:if test="$language = 'lat'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Latin</xsl:text>
      </option>
      <option value="rus">
        <xsl:if test="$language = 'rus'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Russian</xsl:text>
      </option>
      <option value="spa">
        <xsl:if test="$language = 'spa'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Spanish</xsl:text>
      </option>
      <option value="jap">
        <xsl:if test="$language = 'jap'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Japanese</xsl:text>
      </option>
      <option value="chi">
        <xsl:if test="$language = 'chi'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Chinese</xsl:text>
      </option>
    </select>
    <br/>
    <label for="format">Format</label>
    <select name="format">
      <option value="">ALL formats</option>
      <option value="BK">
        <xsl:if test="$format = 'BK'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Books</xsl:text>
      </option>
      <option value="CF">
        <xsl:if test="$format = 'CF'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Conferences</xsl:text>
      </option>
      <option value="MP">
        <xsl:if test="$format = 'MP'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Maps</xsl:text>
      </option>
      <option value="MU">
        <xsl:if test="$format = 'MU'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Music</xsl:text>
      </option>
      <option value="MX">
        <xsl:if test="$format = 'MX'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Manuscripts</xsl:text>
      </option>
      <option value="SE">
        <xsl:if test="$format = 'SE'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Journals</xsl:text>
      </option>
      <option value="VM">
        <xsl:if test="$format = 'VM'">
          <xsl:attribute name="selected" select="'selected'"/>
        </xsl:if>
        <xsl:text>Videorecordings</xsl:text>
      </option>
    </select>
    <br/>
  </xsl:template>
  
  <xsl:template name="boostFactor">
    <xsl:text>None&#160;(0)&#160;</xsl:text>
    <input type="radio" name="weight" value="0" checked="checked"/><br/>
    <xsl:text>Circulation&#160;(1)&#160;</xsl:text>
    <input type="radio" name="weight" value="1"/><br/>
    <xsl:text>UC Holdings&#160;(2)&#160;</xsl:text>
    <input type="radio" name="weight" value="2"/><br/>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Login Page Template                                                    -->
  <!-- ====================================================================== -->

  <xsl:template name="login">
    <html>
      <head>
        <title>Relvyl: Log In</title>
        <xsl:copy-of select="$brand.links"/>
      </head>
      <body id="login"> 
        <xsl:copy-of select="$brand.header"/>
        
        <!-- Connect to the database -->
        <xsl:if test="not(element-available('sql:connect'))">
          <xsl:message terminate="yes">sql:connect is not available</xsl:message>
        </xsl:if>
        <xsl:variable name="connection" as="java:java.sql.Connection" 
                      xmlns:java="http://saxon.sf.net/java-type">
          <sql:connect database="jdbc:mysql://cassatt.cdlib.org:3312/meldev"
                       driver="com.mysql.jdbc.Driver"
                       user="meldevrw" password="meldevrw">
            <xsl:fallback>
              <xsl:message terminate="yes">SQL extensions are not installed</xsl:message>
              Invalid connection.
            </xsl:fallback>
          </sql:connect>
        </xsl:variable>
        
        <!-- Try to add user if in add mode, and the user name is new. -->
        <xsl:if test="$smode = 'login-create' and not($userID = '' or $password = '')">
          <xsl:variable name="pre-check">
            <sql:query connection="$connection" table="user" column="*" 
                       where="userID='{$userID}'"/>
          </xsl:variable>
          <xsl:if test="not($pre-check/row)">
            <sql:insert connection="$connection" table="user">
              <sql:column name="userID" select="$userID"/>
              <sql:column name="password" select="$password"/>
            </sql:insert>
          </xsl:if>
        </xsl:if>
        
        <!-- Check if the username/password is correct -->
        <xsl:variable name="login-check">
          <sql:query connection="$connection" table="user" column="*" 
                     where="userID='{$userID}' AND password='{$password}'"/>
        </xsl:variable>
        
        <!-- Update session data to reflect current log-in status -->
        <xsl:variable name="loginData">
          <xsl:choose>
            <xsl:when test="$login-check/row and not($smode = 'login-close')">
              <login user="{$userID}"/>
            </xsl:when>
            <xsl:otherwise>
              <noLogin/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="session:setData('login', $loginData)"/>
        
        <!-- Now we're ready to show the correct login status -->
        <xsl:call-template name="login-status"/>
        
        <!-- Hand off to various sub-templates to finish the job -->
        <xsl:choose>
          <xsl:when test="$login-check/row">
            <xsl:call-template name="login-success">
              <xsl:with-param name="connection" select="$connection"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$smode = 'login-main'">
            <xsl:call-template name="login-main"/>
          </xsl:when>
          <xsl:when test="$smode = 'login-create'">
            <xsl:call-template name="login-create">
              <xsl:with-param name="connection" select="$connection"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$smode = 'login-close'">
            <xsl:call-template name="login-close"/>
          </xsl:when>
        </xsl:choose>
        
        <xsl:copy-of select="$brand.footer"/>
      </body>
    </html>
  </xsl:template>
  
  <!-- Primary log-in page -->
  <xsl:template name="login-main">
    <xsl:choose>
      <xsl:when test="$userID = ''">
        <h3>Please log in.</h3>
      </xsl:when>
      <xsl:otherwise>
        <h3>Error logging in.</h3>
        <p><b>You apparently entered the wrong password, or the wrong user name. Either try again, or
          create a new account.</b></p>
      </xsl:otherwise>
    </xsl:choose>
    
    <form action="{$crossqueryPath}">
      <table>
        <tr>
          <td>User name</td>
          <td><input type="text" size="20" name="userID"/></td>
        </tr>
        <tr>
          <td>Password</td>
          <td><input type="password" size="20" name="password" value=""/></td>
        </tr>
        <tr>
          <td>
            <input type="hidden" name="style" value="{$style}"/>
            <input type="hidden" name="brand" value="{$brand}"/>
            <input type="hidden" name="smode" value="{$smode}"/>
          </td>
          <td><input type="submit" value="Log in"/></td>
        </tr>
      </table>
    </form>
    <br/>
    <a href="search?style={$style};brand={$brand};smode=login-create">Create a new account</a> 
    if you don't have one already.
  </xsl:template>
  
  <!-- New login creation -->
  <xsl:template name="login-create">
    <xsl:param name="connection"/>
    
    <xsl:choose>
      <xsl:when test="$userID = ''">
        <h3>Create a new account.</h3>
      </xsl:when>
      <xsl:otherwise>
        <h3>Error creating account.</h3>
        <p><b>The user name "<xsl:value-of select="$userID"/>" has already been taken. 
          Please choose another one.</b></p>
      </xsl:otherwise>
    </xsl:choose>
    
    <form action="{$crossqueryPath}">
      <table>
        <tr>
          <td>New user name</td>
          <td><input type="text" size="20" name="userID"/></td>
        </tr>
        <tr>
          <td>New password</td>
          <td><input type="password" size="20" name="password" value=""/></td>
        </tr>
        <tr>
          <td>
            <input type="hidden" name="style" value="{$style}"/>
            <input type="hidden" name="brand" value="{$brand}"/>
            <input type="hidden" name="smode" value="{$smode}"/>
          </td>
          <td><input type="submit" value="Create"/></td>
        </tr>
      </table>
    </form>
    <br/>
  </xsl:template>
  
  <!-- Login successful -->
  <xsl:template name="login-success">
    <xsl:param name="connection"/>
    
    <h3>Thanks for logging in.</h3>
    
    <div id="refine">
      <xsl:if test="session:getData('queryURL')">
        <h2>
          <xsl:text>^Return to Search Results </xsl:text>
          <a href="{session:getData('queryURL')}">
            <img src="icons/melrec/show.gif" alt="show" border="0"/>
          </a>
        </h2>
        <br/>
      </xsl:if>
      
      <h2>
        <xsl:text>Begin a new search </xsl:text>
        <a href="{$crossqueryPath}?style={$style};brand={$brand}">
          <img src="icons/melrec/show.gif" alt="show" border="0"/>
        </a>
      </h2>
    </div>
    
    <!-- Update the last login field -->
    <sql:update connection="$connection" table="user" where="userID='{$userID}'">
      <sql:column name="lastLogin" select="'now()'" is-expression="yes"/>
    </sql:update>
    
  </xsl:template>
  
  <!-- Log out -->
  <xsl:template name="login-close">
    
    <h3>Thanks for using Relvyl.</h3>
    <div id="refine">
      <h2>
        <xsl:text>Begin a new search </xsl:text>
        <a href="{$crossqueryPath}?style={$style};brand={$brand}">
          <img src="icons/melrec/show.gif" alt="show" border="0"/>
        </a>
      </h2>
    </div>
    
  </xsl:template>
    
  <!-- Show login status, allow user to log in or out -->
  <xsl:template name="login-status">
    <div id="login-status">
      <xsl:choose>
        <xsl:when test="session:getData('login')/login">
          <b>Hello, <xsl:value-of select="session:getData('login')/login/@user"/></b>
          <xsl:text>. </xsl:text>
          <xsl:text>Log out </xsl:text>
          <a href="search?style={$style};brand={$brand};smode=login-close">
            <img src="icons/melrec/show.gif" alt="show" border="0"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$smode = 'login-main'">
              Not logged in
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Log in </xsl:text>
              <a href="search?style={$style};brand={$brand};smode=login-main">
                <img src="icons/melrec/show.gif" alt="show" border="0"/>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  
  <!-- ====================================================================== -->
  <!-- Results Template                                                       -->
  <!-- ====================================================================== -->

  <xsl:template match="crossQueryResult" mode="results">
    
    <html>
      <head>
        <title>Relvyl: Results</title>
        <xsl:copy-of select="$brand.links"/>
        <script type="text/javascript" src="script/getElementsBySelector.js"/>
        <script type="text/javascript" src="script/behavior.js"/>
        <script type="text/javascript" src="script/dynamicForm.js"/>
        <script src="script/AsyncLoader.js"/>
        <script src="script/MoreLike.js"/>
        <script src="script/SwapVis.js"/>
        <xsl:if test="session:isEnabled()">
          <script src="script/BookBag.js"/>
        </xsl:if>
      </head>
      
      <body id="results">
        
        <!-- For Testing -->
        <!--<xsl:call-template name="viewParams"/>-->

        <xsl:call-template name="header"/>
        
        <div id="header-secondary">
          <div>
            <xsl:attribute name="class">
              <xsl:if test="@totalDocs = 0">error</xsl:if>
            </xsl:attribute>
            <xsl:text>Your search for </xsl:text>
            <xsl:call-template name="format-query"/>
            <xsl:text> returned </xsl:text>
            <xsl:value-of select="@totalDocs"/>
            <xsl:text> result(s).</xsl:text>  
          </div>
          <div>
            <xsl:if test="//spelling">
              <tr>
                <td align="right" width="10%"></td>
                <td width="1%"/>
                <td align="left">
                  <xsl:call-template name="did-you-mean">
                    <xsl:with-param name="baseURL" select="concat($xtfURL,$crossqueryPath, '?', $queryString)"/>
                    <xsl:with-param name="spelling" select="//spelling"/>
                  </xsl:call-template>
                </td>
              </tr>
            </xsl:if>
          </div>
        </div>
        
        <xsl:variable name="refineString">
          <xsl:choose>
            <xsl:when test="matches($rmode, 'analysis')">
              <xsl:value-of select="replace($queryString,'&amp;rmode=[A-Za-z\-]+','&amp;rmode=analysis-')"/>
            </xsl:when>
            <xsl:when test="not($rmode)">
              <xsl:value-of select="concat($queryString,'&amp;rmode=')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="replace($queryString,'&amp;rmode=[A-Za-z\-]+','&amp;rmode=')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
          <xsl:when test="(contains($rmode, 'refine') or (@totalDocs = 0))">
            <form>
              <table border="0" id="refine">
                <tr>
                  <td width="60%" valign="top">
                    <h2>
                      <xsl:text>Refine Search </xsl:text>
                      <a href="{$xtfURL}{$crossqueryPath}?{$refineString}">
                        <img src="icons/melrec/hide.gif" alt="hide" border="0"/>
                      </a>
                    </h2>
                    <fieldset id="iset1">
                      <table border="0" id="index1">
                        <xsl:call-template name="search1"/>
                      </table>
                    </fieldset>
                    <fieldset id="iset2">
                      <table border="0" id="index2">
                        <xsl:call-template name="search2"/>
                      </table>
                    </fieldset>
                  </td>
                  <td valign="top" width="40%">
                    <h2>Limit By</h2>
                    <div id="limits">
                      <xsl:call-template name="limits"/>
                    </div>
                    <xsl:if test="contains($rmode, 'analysis')">
                      <br clear="all"/>
                      <h2>
                        <xsl:text>Relevance Boost</xsl:text>
                        <xsl:text>&#160;</xsl:text>
                        <a href="javascript://">
                          <xsl:attribute name="onClick">
                            <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-boost','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
                          </xsl:attribute>
                          <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
                        </a>
                      </h2>
                      <div id="boost">
                        <xsl:call-template name="boostFactor"/>
                      </div>
                    </xsl:if>
                  </td>
                </tr>
                <tr id="buttons">
                  <td colspan="2">
                    <input id="search-submit" class="button" type="submit" value="Search" method="GET" action="{$xtfURL}{$crossqueryPath}"/>
                    <input class="button" type="reset" value="Clear"/>
                    <input type="hidden" name="style" value="{$style}"/>
                    <input type="hidden" name="brand" value="{$brand}"/>
                    <xsl:if test="$sort = 'sysid'">
                      <input type="hidden" name="sort" value="sysid"/>
                    </xsl:if>
                    <xsl:if test="$weight != '' and not(contains($smode, 'analysis'))">
                      <input type="hidden" name="weight" value="{$weight}"/>
                    </xsl:if>
                    <input type="hidden" name="frbrize" value="yes"/>
                    <xsl:if test="contains($smode,'analysis')">
                      <input type="hidden" name="rmode" value="analysis"/>
                    </xsl:if>
                  </td>
                </tr>
              </table>
            </form>
          </xsl:when>
          <xsl:otherwise>
            <div id="refine">
              <h2>
                <xsl:text>Refine Search </xsl:text>
                <a href="{$xtfURL}{$crossqueryPath}?{$refineString}refine">
                  <img src="icons/melrec/show.gif" alt="show" border="0"/>
                </a>
              </h2>
            </div>
          </xsl:otherwise>
        </xsl:choose>
        
        <table border="0" cellpadding="5" cellspacing="0" width="100%">
          <tr>
            <td align="left" valign="top" width="33%">
              <xsl:if test="not(//spelling)">
                <form  method="get" action="{$xtfURL}{$crossqueryPath}">
                  <xsl:for-each select="parameters/param[not(matches(@name, 'sort'))]">
                    <input type="hidden">
                      <xsl:attribute name="name">
                        <xsl:value-of select="@name"/>
                      </xsl:attribute>
                      <xsl:attribute name="value">
                        <xsl:value-of select="@value"/>
                      </xsl:attribute>
                    </input>
                  </xsl:for-each>
                  <xsl:call-template name="sort.options"/>
                  <input class="button" type="submit" value="Sort"/>
                </form>
              </xsl:if>&#160;
            </td>
            <td align="center" valign="top" width="33%">
              <xsl:if test="not(//spelling/suggestion)">
                <xsl:variable name="moreString">
                  <xsl:choose>
                    <xsl:when test="matches($rmode, 'analysis')">
                      <xsl:value-of select="replace($queryString,'&amp;rmode=[A-Za-z\-]+','&amp;rmode=analysis-')"/>
                    </xsl:when>
                    <xsl:when test="not($rmode)">
                      <xsl:value-of select="concat($queryString, '&amp;rmode=')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="replace($queryString,'&amp;rmode=[A-Za-z\-]+','&amp;rmode=')"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="contains($rmode, 'moreDetails')">
                    <a href="{$xtfURL}{$crossqueryPath}?{$moreString}">Brief Record</a>
                    <xsl:text> | More Details</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Brief Record | </xsl:text>
                    <a href="{$xtfURL}{$crossqueryPath}?{$moreString}moreDetails">More Details</a>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>&#160;
            </td>
            <td align="right" valign="top" width="33%">
              <xsl:call-template name="pages"/>
            </td>
          </tr>
          <tr>
            <td colspan="3" align="center">
              <xsl:if test="contains($rmode, 'analysis')">
                <table border="0" width="100%">
                  <tr>
                    <td align="left">
                      <xsl:text>Query Time: </xsl:text>
                      <xsl:value-of select="@queryTime"/>
                      <xsl:text> | Boost</xsl:text>
                      <xsl:text>&#160;</xsl:text>
                      <a href="javascript://">
                        <xsl:attribute name="onClick">
                          <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-boost','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
                        </xsl:attribute>
                        <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
                      </a>
                      <xsl:text>: </xsl:text>
                      <xsl:choose>
                        <xsl:when test="parameters/param[@name='weight']/@value">
                          <xsl:value-of select="parameters/param[@name='weight']/@value"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="'0'"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </td>
                    <td align="right">
                      <xsl:choose>
                        <xsl:when test="$explainScores">
                          <a href="search?{replace($queryString, '&amp;explainScores=yes', '')}">UnExplain Scores</a>
                        </xsl:when>
                        <xsl:otherwise>
                          <a href="search?{$queryString}&amp;explainScores=yes">Explain Scores</a>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:text>&#160;</xsl:text>
                      <a href="javascript://">
                        <xsl:attribute name="onClick">
                          <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-explain','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
                        </xsl:attribute>
                        <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
                      </a>
                      <xsl:text> | </xsl:text>
                      <xsl:choose>
                        <xsl:when test="$frbrize = 'yes' or $frbrize = 'old'">
                          <a href="search?{replace($queryString,'&amp;frbrize=[a-z]+','')}">UnFRBRize</a>
                        </xsl:when>
                        <xsl:otherwise>
                          <a href="search?{replace($queryString,'&amp;rmode=[A-Za-z\-]+','&amp;rmode=analysis&amp;frbrize=yes')}">FRBRize</a>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:text>&#160;</xsl:text>
                      <a href="javascript://">
                        <xsl:attribute name="onClick">
                          <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-frbr','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
                        </xsl:attribute>
                        <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
                      </a>
                      <br/>
                    </td>
                  </tr>
                </table>
              </xsl:if>
              <xsl:if test="//docHit">
                <xsl:variable name="tabString" select="replace($queryString,'&amp;origin=[A-Z]+','')"/>
                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                  <tr>
                    <td align="center" width="20%">
                      <xsl:choose>
                        <xsl:when test="$origin=''">
                          <xsl:attribute name="style" select="'border: black solid 1px;background-color: lightgray'"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:attribute name="style" select="'border: black solid 1px'"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <a href="{$xtfURL}{$crossqueryPath}?{$tabString}">All</a>
                    </td>
                    <td align="center" width="20%">
                      <xsl:choose>
                        <xsl:when test="$origin='MARC'">
                          <xsl:attribute name="style" select="'border: black solid 1px;background-color: lightgray'"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:attribute name="style" select="'border: black solid 1px'"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <a href="{$xtfURL}{$crossqueryPath}?{$tabString}&amp;origin=MARC">MARC</a>
                    </td>
                    <td align="center" width="20%">
                      <xsl:choose>
                        <xsl:when test="$origin='OCA'">
                          <xsl:attribute name="style" select="'border: black solid 1px;background-color: lightgray'"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:attribute name="style" select="'border: black solid 1px'"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <a href="{$xtfURL}{$crossqueryPath}?{$tabString}&amp;origin=OCA">OCA</a>
                    </td>
                    <td align="center" width="20%">
                      <xsl:choose>
                        <xsl:when test="$origin='ESR'">
                          <xsl:attribute name="style" select="'border: black solid 1px;background-color: lightgray'"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:attribute name="style" select="'border: black solid 1px'"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <a href="{$xtfURL}{$crossqueryPath}?{$tabString}&amp;origin=ESR">ESR</a>
                    </td>
                    <td align="center" width="20%">
                      <xsl:choose>
                        <xsl:when test="$origin='TEI'">
                          <xsl:attribute name="style" select="'border: black solid 1px;background-color: lightgray'"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:attribute name="style" select="'border: black solid 1px'"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <a href="{$xtfURL}{$crossqueryPath}?{$tabString}&amp;origin=TEI">TEI</a>
                    </td>
                  </tr>
                </table>
              </xsl:if>
            </td>
          </tr>
        </table>
        
        <xsl:choose>
          <xsl:when test="$frbrize = 'old'">
            <xsl:variable name="frbrFacet">
              <xsl:call-template name="frbrizeHits">
                <xsl:with-param name="docHits" select="docHit"/>
                <xsl:with-param name="maxWorks" select="$docsPerPage"/>
              </xsl:call-template>
            </xsl:variable>
            <table width="100%" id="content-primary" cellpadding="5" cellspacing="0" style="border: black solid 1px">
              <xsl:apply-templates select="$frbrFacet" mode="frbr"/>
            </table>
          </xsl:when>
          <xsl:when test="$frbrize = 'yes'">
            <xsl:variable name="frbrFacet" select="//facet[@field='dynamicFRBR']"/>
            <table width="100%" id="content-primary" cellpadding="5" cellspacing="0" style="border: black solid 1px">
              <xsl:apply-templates select="$frbrFacet" mode="frbr"/>
            </table>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="docHit">
              <table width="100%" id="content-primary" cellpadding="5" cellspacing="0">
                <xsl:apply-templates select="docHit"/>
              </table>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        
        <xsl:copy-of select="$brand.footer"/>
  
      </body>
    </html>
  </xsl:template>  
  
  <!-- ====================================================================== -->
  <!-- Book Bag Search Results                                                  -->
  <!-- ====================================================================== -->
  
  <xsl:template match="crossQueryResult" mode="bookBag">
    
    <html>
      <head>
        <title>Relvyl: Results</title>
        <xsl:copy-of select="$brand.links"/>
        <script type="text/javascript" src="script/getElementsBySelector.js"/>
        <script type="text/javascript" src="script/behavior.js"/>
        <script type="text/javascript" src="script/dynamicForm.js"/>
        <script src="script/AsyncLoader.js"/>
        <script src="script/MoreLike.js"/>
        <xsl:if test="session:isEnabled()">
          <script src="script/BookBag.js"/>
        </xsl:if>
      </head>
      
      <body id="results">
        
        <xsl:call-template name="header"/>
        
        <div id="header-secondary">
          <table width="100%">
            <tr>
              <td align="left">
                <a href="{session:getData('queryURL')}">
                  <xsl:text>^Return to Search Results </xsl:text>
                </a>
              </td>
              <td align="right">
                <xsl:attribute name="class">
                  <xsl:if test="@totalDocs = 0">error</xsl:if>
                </xsl:attribute>
                <xsl:text>Your bookbag contains </xsl:text>
                <span id="itemCount">
                  <xsl:value-of select="@totalDocs"/>
                </span>
                <xsl:text> item(s).</xsl:text>
              </td>
            </tr>
          </table>
        </div>
    
        <table width="100%" id="content-primary" cellpadding="5" cellspacing="0" border="0">    
          <thead>
            <tr>
              <th align="left">
                <a href="{concat($xtfURL, $crossqueryPath, '?', replace($queryString,'&amp;sort=[a-z\-]+',''),'&amp;sort=title')}">Title</a>
              </th>
              <th align="left">
                <a href="{concat($xtfURL, $crossqueryPath, '?', replace($queryString,'&amp;sort=[a-z\-]+',''),'&amp;sort=author')}">Author</a>
              </th>
              <th align="left">
                <a href="{concat($xtfURL, $crossqueryPath, '?', replace($queryString,'&amp;sort=[a-z\-]+',''),'&amp;sort=year')}">Date</a>
              </th>
              <th align="left">
                <xsl:value-of select="'&#160;'"/>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr><td colspan="4">&#160;</td></tr>
            <xsl:apply-templates select="docHit" mode="bookBag"/>
          </tbody>
        </table>
        
        <xsl:copy-of select="$brand.footer"/>
        
      </body>
    </html>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Document Hit Template                                                  -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit">
    
    <xsl:variable name="rank" select="@rank"/>    
    <xsl:variable name="score" select="@score"/>
    <xsl:variable name="resultString" select="replace($queryString,'&amp;rmode=[A-Za-z]+','')"/>
    <xsl:variable name="sysID" select="meta/sysID[1]"/>
    <xsl:variable name="quotedSysid" select="concat('&quot;', $sysID, '&quot;')"/>
    
    <tr id="{$sysID}-main">
      <xsl:choose>
        <xsl:when test="position() mod 2 = 0">
          <xsl:attribute name="class" select="'even'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class" select="'odd'"/>
        </xsl:otherwise>
      </xsl:choose>
      
      <xsl:choose>
        <xsl:when test="$sort != 'title' and $sort != 'author' and $sort != 'year'">
          <td valign="top">
            <xsl:value-of select="@rank"/>
            <xsl:text>. </xsl:text>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td valign="top">
            <xsl:value-of select="' '"/>
          </td>
        </xsl:otherwise>
      </xsl:choose>
 
      <td>
        <table class="assess-hit" border="0">
          <tr>
            <td width="300" align="right" valign="top">
              <h2>Title: </h2>
            </td>
            <td>
              <a>
                <xsl:attribute name="href">
                  <xsl:call-template name="crossquery.url">
                    <xsl:with-param name="sysID" select="meta/sysID[1]"/>
                  </xsl:call-template>
                </xsl:attribute>
                <xsl:choose>
                  <xsl:when test="meta/title-main">
                    <xsl:apply-templates select="meta/title-main[1]"/>
                  </xsl:when>
                  <xsl:when test="meta/title-journal">
                    <xsl:apply-templates select="meta/title-journal[1]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>[Untitled]</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </a>
            </td>
          </tr>
          <xsl:if test="meta/title-series">
            <tr>
              <td width="300" align="right" valign="top">
                <h2>Series: </h2>
              </td>
              <td>
                <xsl:apply-templates select="meta/title-series[1]"/>
              </td>
            </tr>
          </xsl:if>
          <xsl:if test="meta/author or meta/meta/author-corporate">
            <tr>
              <td width="300" align="right" valign="top">
                <h2>Author: </h2>
              </td>
              <td>
                <xsl:choose>
                  <xsl:when test="meta/author">
                    <xsl:apply-templates select="meta/author[1]"/>
                    <xsl:text>&#160;</xsl:text>
                  </xsl:when>
                  <xsl:when test="meta/author-corporate">
                    <xsl:apply-templates select="meta/author-corporate[1]"/>
                    <xsl:text>&#160;</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </td>
            </tr>
          </xsl:if>
          <tr>
            <td width="300" align="right" valign="top">
              <h2>Publisher, Place, Date: </h2>
            </td>
            <td>
              <xsl:if test="meta/publisher">
                <xsl:apply-templates select="meta/publisher[1]"/>
              </xsl:if>
              <xsl:if test="meta/place">
                <xsl:if test="meta/publisher">
                  <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:apply-templates select="meta/pub-place[1]"/>
              </xsl:if>
              <xsl:if test="meta/year">
                <xsl:if test="meta/publisher or meta/place">
                  <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:apply-templates select="meta/year[1]"/>
              </xsl:if>
            </td>
          </tr>
          <xsl:if test="meta/subject">
            <tr>
              <td width="300" align="right" valign="top">
                <h2>Subjects: </h2>
              </td>
              <td>
                <xsl:apply-templates select="meta/subject"/>
              </td>
            </tr>
          </xsl:if>
          <xsl:if test="meta/format">
            <tr>
              <td width="300" align="right" valign="top">
                <h2>Format: </h2>
              </td>
              <td>
                <xsl:choose>
                  <xsl:when test="matches(meta/origin, 'ESR|OCA')">
                    <xsl:value-of select="'PDF'"/>
                  </xsl:when>
                  <xsl:when test="meta/origin = 'TEI'">
                    <xsl:value-of select="'TEI'"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <span class="format">
                      <xsl:call-template name="map-format">
                        <xsl:with-param name="string" select="string(meta/format[1])"/>
                      </xsl:call-template>
                    </span>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
          </xsl:if>
          <xsl:if test="meta/callnum">
            <tr>
              <td width="300" align="right" valign="top">
                <h2>Call Number: </h2>
              </td>
              <td>
                <xsl:apply-templates select="meta/callnum[1]"/>
              </td>
            </tr>
          </xsl:if>
          <xsl:if test="contains($rmode, 'moreDetails')">
            <xsl:if test="meta/language">
              <tr>
                <td align="right" valign="top" nowrap="nowrap">
                  <h2>Language: </h2>
                </td>
                <td>
                  <xsl:for-each select="meta/language">
                    <xsl:if test="normalize-space(string(.)) != ''">
                      <xsl:call-template name="map-language">
                        <xsl:with-param name="string" select="string(.)"/>
                      </xsl:call-template>
                      <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                      </xsl:if>
                    </xsl:if>
                  </xsl:for-each>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="meta/note">
              <tr>
                <td align="right" valign="top" nowrap="nowrap">
                  <h2>Note(s): </h2>
                </td>
                <td>
                  <xsl:for-each select="meta/note">
                    <p><xsl:apply-templates/></p>
                  </xsl:for-each>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="meta/identifier-isbn">
              <tr>
                <td align="right" valign="top" nowrap="nowrap">
                  <h2>ISBN: </h2>
                </td>
                <td>
                  <xsl:apply-templates select="meta/identifier-isbn[1]"/>
                </td>
              </tr>
            </xsl:if>
            <xsl:if test="meta/identifier-issn">
              <tr>
                <td align="right" valign="top" nowrap="nowrap">
                  <h2>ISSN: </h2>
                </td>
                <td>
                  <xsl:apply-templates select="meta/identifier-issn[1]"/>
                </td>
              </tr>
            </xsl:if>
          </xsl:if>
          
          <xsl:if test="snippet">          
            <tr>
              <td align="right" valign="top" nowrap="nowrap">
                <h2>Matches  (<xsl:value-of select="@totalHits"/>)</h2>
              </td>
              <td>
                <xsl:apply-templates select="snippet"/>
              </td>
            </tr>
          </xsl:if>
          
          <xsl:if test="contains($rmode,'analysis')">
            <tr>
              <td width="300" align="right" valign="top">
                <h2>Score: </h2>
              </td>
              <td>
                <xsl:value-of select="$score"/>
              </td>
            </tr>
          </xsl:if>
          
          <xsl:if test="explanation">
            <tr>
              <td width="300" align="right" valign="top">
                <h2>Explanation: </h2>
              </td>
              <td>
                <xsl:apply-templates select="explanation"/>
              </td>
            </tr>
          </xsl:if>
          
          <xsl:if test="session:isEnabled()">
            <tr>
              <td width="300" align="right" valign="top">
                <xsl:text>&#160;</xsl:text>
              </td>
              <td>
                <xsl:call-template name="bookBag">
                  <xsl:with-param name="sysID" select="meta/sysID[1]"/>
                </xsl:call-template>
              </td>
            </tr>
          </xsl:if>
 
        </table>
      </td>
    </tr>
    
  </xsl:template>
        
  <!-- ====================================================================== -->
  <!-- Snippet Template                                                       -->
  <!-- ====================================================================== -->

  <xsl:template match="snippet[parent::docHit]">
    <span class="search-results-snippet">
      <xsl:text>...</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>...</xsl:text>
    </span>
    <br/>
  </xsl:template>   
  
  <!-- ====================================================================== -->
  <!-- Hit Template                                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="hit">
    <xsl:apply-templates/>
  </xsl:template>
    
  <!-- ====================================================================== -->
  <!-- Term Template                                                          -->
  <!-- ====================================================================== -->
 
  <xsl:template match="term">
    <span class="keyword">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Object View Templates                                                  -->
  <!-- ====================================================================== -->  
  
  <xsl:template match="crossQueryResult" mode="objview">
    
    <xsl:variable name="rank" select="docHit[matches(string(meta/sysID[1]),$object)]/@rank"/>
    <xsl:variable name="start" select="(floor($rank div 20 ) * 20 ) + 1"/>
    <xsl:variable name="search" select="replace(replace(replace(replace(replace(replace($queryString,'object=[0-9]+',''),'rmode=objview',''),'docsPerPage=[0-9]+',''),'&amp;+','&amp;'),'^&amp;',''),'&amp;$','')"/>
    <xsl:variable name="prev" select="string(docHit[matches(string(meta/sysID[1]),$object)]/preceding-sibling::docHit[1]/meta/sysID[1])"/>
    <xsl:variable name="next" select="string(docHit[matches(string(meta/sysID[1]),$object)]/following-sibling::docHit[1]/meta/sysID[1])"/>
    <xsl:variable name="startDoc" select="docHit[matches(string(meta/sysID[1]),$object)]/preceding-sibling::docHit[1]/@rank"/>
    <xsl:variable name="analysisString" select="replace(replace($queryString, '&amp;rmode=[A-Za-z\-]+',''),'&amp;explainScores=[A-Za-z\-]+','')"/>
    <xsl:variable name="normalString" select="replace(replace($queryString, '&amp;rmode=[A-Za-z\-]+', '&amp;rmode=objview'), '&amp;explainScores=[A-Za-z\-]+', '')"/>
    
    <xsl:variable name="sysID" select="$object"/>
    <xsl:variable name="quotedSysid" select="concat('&quot;', $sysID, '&quot;')"/>
    <xsl:variable name="url" select="session:encodeURL(concat($xtfURL, $crossqueryPath, '?smode=moreLike&amp;docsPerPage=5&amp;style=melrec&amp;brand=melrec&amp;sysID=', $sysID, if($explainScores) then concat('&amp;explainScores=', $explainScores) else ''))"/>               
  
    
    <html>
      <head>
        <title>
          <xsl:value-of select="concat('Record: ', docHit[matches(string(meta/sysID[1]),$object)]/meta/title-main[1])"/>
        </title>
        <xsl:copy-of select="$brand.links"/>
        <script src="script/AsyncLoader.js"/>
        <script src="script/MoreLike.js"/>
        <xsl:if test="session:isEnabled()">
          <script src="script/BookBag.js"/>
        </xsl:if>
        <script src="script/Recommend.js"/>
        <script type="text/javascript">
          <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/identifier-isbn">
            <xsl:analyze-string select="docHit[matches(string(meta/sysID[1]),$object)]/meta/identifier-isbn[1]" regex="([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9X])">
              <xsl:matching-substring>
                var awsURL = &quot;<xsl:value-of select="concat($crossqueryPath, '?awsID=', regex-group(1), '&amp;maxRecords=', $maxRecords, '&amp;style=melrec&amp;brand=melrec&amp;rmode=getRecommendations')"/>&quot;;
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:if>
          var localRecsURL = &quot;<xsl:value-of select="concat($crossqueryPath, '?sysID=', $object, '&amp;maxRecords=', $maxRecords,  '&amp;style=melrec&amp;brand=melrec&amp;rmode=getRecommendations')"/>&quot;;
        </script>
      </head>
      <body id="metadata">

        <xsl:call-template name="header"/>
        
        <xsl:if test="not(matches($rmode, 'morelike'))">
          <div id="header-secondary">
            <table width="100%">
              <tr>
                <td width="34%">
                  <span class="goback">
                    <xsl:if test="session:getData('queryURL')">
                      <a href="{session:getData('queryURL')}">
                        <xsl:text>^Return to search results</xsl:text>
                      </a>
                    </xsl:if>
                    <!--<a href="search?{$search}&amp;startDoc={$start}">^Return to search results</a>-->
                  </span>
                </td>
                <!--<td width="34%">
                  <span class="pagination">
                    <xsl:choose>
                      <xsl:when test="not(normalize-space($prev)='')">
                        <a href="search?{$search}&amp;object={$prev}&amp;startDoc={$startDoc - 1}&amp;rmode=objview">&lt; Previous</a>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>&lt; Previous</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>&#160;</xsl:text>
                    <xsl:choose>
                      <xsl:when test="not(normalize-space($next)='')">
                        <a href="search?{$search}&amp;object={$next}&amp;startDoc={$startDoc}&amp;rmode=objview">Next &gt;</a>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>Next &gt;</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </span>
                </td>-->
              </tr>
            </table>
          </div>
        </xsl:if>

        <xsl:choose>
          <!-- If explainScores is enabled, allow user to fiddle with the 
            parameters for the 'more like this' query. -->
          <xsl:when test="$explainScores">
            <div id="content-primary">
              <tr>
                <td align="center" colspan="3">
                  <form>
                    <xsl:attribute name="action" select="concat('javascript:moreLike(', $quotedSysid, ', &quot;', $url, '&quot;)')"/>
                    <table width="100%" border="1" cellpadding="5" cellspacing="0">
                      <!--<tr>
                        <td>
                          <input type="text" name="minWordLen" size="3" value="{$minWordLen}" id="{$sysID}-minWordLen"/>
                          Min word length
                        </td>
                        <td>
                          <input type="text" name="maxWordLen" size="3" value="{$maxWordLen}" id="{$sysID}-maxWordLen"/>
                          Max word length
                        </td>
                        <td>
                          <input type="text" name="minDocFreq" size="3" value="{$minDocFreq}" id="{$sysID}-minDocFreq"/>
                          Min frequency in docs
                        </td>
                      </tr>
                      <tr>
                        <td>
                          <input type="text" name="maxDocFreq" size="3" value="{$maxDocFreq}" id="{$sysID}-maxDocFreq"/>
                          Max frequency in docs
                        </td>
                        <td>
                          <input type="text" name="minTermFreq" size="3" value="{$minTermFreq}" id="{$sysID}-minTermFreq"/>
                          Min term frequency
                        </td>
                        <td>
                          <input type="text" name="termBoost" size="3" value="{$termBoost}" id="{$sysID}-termBoost"/>
                          Apply term boost
                        </td>
                      </tr>
                      <tr>
                        <td>
                          <input type="text" name="maxQueryTerms" size="3" value="{$maxQueryTerms}" id="{$sysID}-maxQueryTerms"/>
                          Max query terms
                        </td>
                      </tr>-->
                      
                      <!-- Allow user to tweak boost on a per-field basis. First, make a
                        handy list of the fields and their corresponding boost values. -->
                      <xsl:variable name="parsedFields">
                        <xsl:analyze-string select="$moreLikeFields" regex="[\-a-zA-Z0-9]+">
                          <xsl:matching-substring>
                            <field name="{string()}"/>
                          </xsl:matching-substring>
                        </xsl:analyze-string>
                      </xsl:variable>
                      
                      <xsl:variable name="parsedBoosts">
                        <xsl:analyze-string select="$moreLikeBoosts" regex="[0-9.]+">
                          <xsl:matching-substring>
                            <boost value="{string()}"/>
                          </xsl:matching-substring>
                        </xsl:analyze-string>
                      </xsl:variable>
                      
                      <xsl:variable name="boostList" select="'^title-main$|^author$|^callnum-class$|^subject$'"/>
                      
                      <!-- To make things look nice and save space, lay out the boost
                        boxes in three columns. -->
                      <!--<xsl:variable name="count" select="count($parsedFields/field)"/>
                      <xsl:variable name="nRows" select="($count + 2) idiv 3"/>
                      <xsl:for-each select="1 to ($nRows)">
                        <xsl:variable name="row" select="position()"/>
                        <tr>
                          <xsl:for-each select="1 to 3">
                            <xsl:variable name="col" select="position()"/>
                            <td>
                              <xsl:variable name="fieldNum" select="(($col - 1) * $nRows) + $row"/>
                              <xsl:if test="$fieldNum &lt;= $count">
                                <xsl:variable name="fieldName" select="$parsedFields/field[$fieldNum]/@name"></xsl:variable>
                                <xsl:variable name="fieldBoost" select="$parsedBoosts/boost[$fieldNum]/@value"></xsl:variable>
                                <input type="text" name="{$fieldName}" size="3" value="{$fieldBoost}" id="{$sysID}-field-{$fieldNum}"/>
                                <xsl:text>&#160;</xsl:text>
                                <xsl:value-of select="$fieldName"/>
                              </xsl:if>
                            </td>
                          </xsl:for-each>
                        </tr>
                        </xsl:for-each>-->
                      
                      <xsl:variable name="count" select="count($parsedFields/field)"/>
                      <xsl:variable name="docHit" select="docHit[matches(string(meta/sysID[1]),$object)]"/>
                      <xsl:for-each select="1 to ($count)">
                        <xsl:variable name="fieldNum" select="position()"/>
                        <xsl:if test="$fieldNum &lt;= $count">
                          <xsl:variable name="fieldName" select="$parsedFields/field[$fieldNum]/@name"></xsl:variable>
                          <xsl:variable name="fieldBoost" select="$parsedBoosts/boost[$fieldNum]/@value"></xsl:variable>
                          <xsl:if test="matches($fieldName, $boostList)">
                            <tr>
                              <td width="20%" align="right" valign="top">
                                <b>
                                  <xsl:value-of select="$fieldName"/>
                                </b>
                              </td>
                              <td width="80%" align="left" valign="top">
                                <xsl:for-each select="$docHit/meta/*[name()=$fieldName]">
                                  <xsl:value-of select="."/><br/>
                                </xsl:for-each>
                              </td>
                              <td width="20%" align="center" valign="top">
                                <input type="text" name="{$fieldName}" size="3" value="{$fieldBoost}" id="{$sysID}-field-{$fieldNum}"/>
                              </td>
                            </tr>
                          </xsl:if>
                        </xsl:if>
                      </xsl:for-each>
                      
                      <tr>
                        <td width="20%" align="right" valign="top">
                          <b>Other settings</b>
                        </td>
                        <td width="80%" align="left" valign="top">
                          <xsl:text>Max query terms</xsl:text><br/>
                          <xsl:text>Apply term boost</xsl:text>
                        </td>
                        <td width="20%" align="center" valign="top">
                          <input type="text" name="maxQueryTerms" size="3" value="{$maxQueryTerms}" id="{$sysID}-maxQueryTerms"/><br/>
                          <input type="text" name="termBoost" size="3" value="{$termBoost}" id="{$sysID}-termBoost"/>
                        </td>
                      </tr>
                      <tr>
                        <td colspan="3" align="center" valign="top">
                          <input type="submit" value="Regenerate Similar Records"/>
                          <xsl:text>&#160;&#160;</xsl:text>
                          <input type="reset" value="Return to Default Settings"/>
                        </td>
                      </tr>
                    </table>
                  </form>
                </td>
              </tr>
            </div>
          </xsl:when>
          <xsl:otherwise>       
            <div id="content-primary">
              <xsl:call-template name="longDisplay"/>
            </div>
          </xsl:otherwise>
        </xsl:choose>

        <div id="content-secondary">
          <h2>Recommendations:</h2>
          <table cellspacing="0">
            <thead>
              <tr>
                <th align="center" width="33%">
                  <span id="recommendHeader">Similar Records</span>
                  <xsl:text>&#160;</xsl:text>
                  <a href="javascript://">
                    <xsl:attribute name="onClick">
                      <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-rec1','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
                    </xsl:attribute>
                    <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
                  </a>
                  <br/>
                  <xsl:if test="matches($rmode, 'analysis')">
                    <xsl:choose>
                      <xsl:when test="$explainScores">
                        <a style="font-size: 80%" href="{$xtfURL}{$crossqueryPath}?{$analysisString}&amp;rmode=objview-analysis">(Remove similarity settings)</a>
                        <xsl:text>&#160;</xsl:text>
                        <a href="javascript://">
                          <xsl:attribute name="onClick">
                            <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-set','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
                          </xsl:attribute>
                          <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
                        </a>
                      </xsl:when>
                      <xsl:otherwise>
                        <a style="font-size: 80%" href="{$xtfURL}{$crossqueryPath}?{$analysisString}&amp;rmode=objview-analysis&amp;explainScores=yes">(Experiment with the similarity settings)</a>
                        <xsl:text>&#160;</xsl:text>
                        <a href="javascript://">
                          <xsl:attribute name="onClick">
                            <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-set','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
                          </xsl:attribute>
                          <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
                        </a>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                </th>
                <th align="center" width="34%">
                  <span id="recommendHeader">Patrons who borrowed this item also borrowed</span>
                  <xsl:text>&#160;</xsl:text>
                  <a href="javascript://">
                    <xsl:attribute name="onClick">
                      <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-rec2','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
                    </xsl:attribute>
                    <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
                  </a>
                </th>
                <th align="center" width="33%">
                  <span id="recommendHeader">Amazon Recommendations</span>
                  <xsl:text>&#160;</xsl:text>
                  <a href="javascript://">
                    <xsl:attribute name="onClick">
                      <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-rec3','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
                    </xsl:attribute>
                    <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
                  </a>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td valign="top" width="33%">
                  <!-- Fetch 'more like this' recommendations -->
                  <ol id="{$sysID}-moreLike">            
                    <script type="text/javascript">
                      <xsl:value-of select="concat('javascript:moreLike(', $quotedSysid, ', &quot;', $url, '&quot;)')"/>
                    </script>
                  </ol>
                </td>
                <td valign="top" width="34%"><!-- HERE -->
                  <div id="recommendations"/>
                </td>
                <td valign="top" width="33%">
                  <div id="amazon"/>
                </td>
              </tr>
            </tbody>
          </table>
          
        </div>
        
        <xsl:copy-of select="$brand.footer"/>
        
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="*" mode="objview">
    <p>
      <h2>
        <xsl:value-of select="string(name())"/>
      </h2>
      <xsl:text>&#160;</xsl:text>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template name="longDisplay">
    <table class="assess-hit" width="100%" border="0">
      <tr>
        <td align="right" valign="top" nowrap="nowrap">
          <h2>Title: </h2>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="docHit[matches(string(meta/sysID[1]),$object)]/meta/title-main">
              <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/title-main[1]"/>
            </xsl:when>
            <xsl:when test="docHit[matches(string(meta/sysID[1]),$object)]/meta/title-journal">
              <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/title-journal[1]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>[Untitled]</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
      <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/origin != 'MARC'">
        <xsl:variable name="origin" select="docHit[matches(string(meta/sysID[1]),$object)]/meta/origin"/>
        <xsl:variable name="id" select="docHit[matches(string(meta/sysID[1]),$object)]/meta/sysID"/>
      <tr>
        <td align="right" valign="top" nowrap="nowrap">
          <h2>Online Edition: </h2>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="$origin = 'ESR'">
              <a href="{docHit[matches(string(meta/sysID[1]),$object)]/meta/xlink}">
                <xsl:text>eScholarship Repository</xsl:text>
              </a>
            </xsl:when>
            <xsl:when test="$origin = 'OCA'">
              <a href="http://www.archive.org/download/{$id}/{$id}.pdf">
                <xsl:text>Internet Archive</xsl:text>
              </a>
            </xsl:when>
            <xsl:when test="$origin = 'TEI'">
              <a href="http://content.cdlib.org/view?docId={$id}">
                <xsl:text>California Digital Library</xsl:text>
              </a>
            </xsl:when>
          </xsl:choose>
        </td>
      </tr>
      </xsl:if>
      <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/title-series">
        <tr>
          <td align="right" valign="top" nowrap="nowrap">
            <h2>Series: </h2>
          </td>
          <td>
            <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/title-series[1]"/>
          </td>
        </tr>
      </xsl:if>
      <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/author or docHit[matches(string(meta/sysID[1]),$object)]/meta/docHit[matches(string(meta/sysID[1]),$object)]/meta/author-corporate">
        <tr>
          <td align="right" valign="top" nowrap="nowrap">
            <h2>Author: </h2>
          </td>
          <td>
            <xsl:choose>
              <xsl:when test="docHit[matches(string(meta/sysID[1]),$object)]/meta/author">
                <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/author[1]"/>
                <xsl:text>&#160;</xsl:text>
              </xsl:when>
              <xsl:when test="docHit[matches(string(meta/sysID[1]),$object)]/meta/author-corporate">
                <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/author-corporate[1]"/>
                <xsl:text>&#160;</xsl:text>
              </xsl:when>
            </xsl:choose>
          </td>
        </tr>
      </xsl:if>
      <tr>
        <td align="right" valign="top" nowrap="nowrap">
          <h2>Publisher: </h2>
        </td>
        <td>
          <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/publisher">
            <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/publisher[1]"/>
          </xsl:if>
          <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/place">
            <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/publisher">
              <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/pub-place[1]"/>
          </xsl:if>
          <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/year">
            <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/publisher or docHit[matches(string(meta/sysID[1]),$object)]/meta/place">
              <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/year[1]"/>
          </xsl:if>
        </td>
      </tr>
      <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/subject">
        <tr>
          <td align="right" valign="top" nowrap="nowrap">
            <h2>Subjects: </h2>
          </td>
          <td>
            <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/subject" mode="longDisplay"/>
          </td>
        </tr>
      </xsl:if>
      <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/format">
        <tr>
          <td align="right" valign="top" nowrap="nowrap">
            <h2>Format: </h2>
          </td>
          <td>
            <xsl:choose>
              <xsl:when test="matches(docHit[matches(string(meta/sysID[1]),$object)]/meta/origin, 'ESR|OCA')">
                <xsl:value-of select="'PDF'"/>
              </xsl:when>
              <xsl:when test="docHit[matches(string(meta/sysID[1]),$object)]/meta/origin = 'TEI'">
                <xsl:value-of select="'TEI'"/>
              </xsl:when>
              <xsl:otherwise>
                <span class="format">
                  <xsl:call-template name="map-format">
                    <xsl:with-param name="string" select="string(docHit[matches(string(meta/sysID[1]),$object)]/meta/format[1])"/>
                  </xsl:call-template>
                </span>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </xsl:if>
      <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/callnum">
        <tr>
          <td align="right" valign="top" nowrap="nowrap">
            <h2>Call Number: </h2>
          </td>
          <td>
            <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/callnum[1]"/>
          </td>
        </tr>
      </xsl:if>
      <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/language">
        <tr>
          <td align="right" valign="top" nowrap="nowrap">
            <h2>Language: </h2>
          </td>
          <td>
            <xsl:for-each select="docHit[matches(string(meta/sysID[1]),$object)]/meta/language">
              <xsl:if test="normalize-space(string(.)) != ''">
                <xsl:call-template name="map-language">
                  <xsl:with-param name="string" select="string(.)"/>
                </xsl:call-template>
                <xsl:if test="position() != last()">
                  <xsl:text>, </xsl:text>
                </xsl:if>
              </xsl:if>
            </xsl:for-each>
          </td>
        </tr>
      </xsl:if>
      <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/note">
        <tr>
          <td align="right" valign="top" nowrap="nowrap">
            <h2>Note(s): </h2>
          </td>
          <td>
            <xsl:for-each select="docHit[matches(string(meta/sysID[1]),$object)]/meta/note">
              <p><xsl:apply-templates/></p>
            </xsl:for-each>
          </td>
        </tr>
      </xsl:if>
      <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/identifier-isbn">
        <tr>
          <td align="right" valign="top" nowrap="nowrap">
            <h2>ISBN: </h2>
          </td>
          <td>
            <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/identifier-isbn[1]"/>
          </td>
        </tr>
      </xsl:if>
      <xsl:if test="docHit[matches(string(meta/sysID[1]),$object)]/meta/identifier-issn">
        <tr>
          <td align="right" valign="top" nowrap="nowrap">
            <h2>ISSN: </h2>
          </td>
          <td>
            <xsl:apply-templates select="docHit[matches(string(meta/sysID[1]),$object)]/meta/identifier-issn[1]"/>
          </td>
        </tr>
      </xsl:if>
    </table>
    
  </xsl:template>
  
  <xsl:template match="subject" mode="longDisplay">
    <a href="{$xtfURL}{$crossqueryPath}?subject={.}&amp;subject-join=exact&amp;style={$style}&amp;brand={$brand}">
      <xsl:apply-templates/>
    </a>
    <xsl:if test="not(position() = last())">
      <xsl:text> | </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <!-- crossQuery object link -->
  
  <xsl:template name="crossquery.url">
    
    <xsl:param name="sysID"/>
    <xsl:variable name="queryString" select="replace(replace(replace($queryString, 'rmode=[A-Za-z0-9\-]+', ''), '&amp;+', '&amp;'), '&amp;$', '')"/>
    
    <xsl:choose>
      <xsl:when test="matches($rmode, 'analysis')">
        <xsl:value-of select="concat($xtfURL, $crossqueryPath, '?object=', $sysID, '&amp;', $queryString,'&amp;rmode=objview-analysis', '&amp;startDoc=', $startDoc)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($xtfURL, $crossqueryPath, '?object=', $sysID, '&amp;', $queryString,'&amp;rmode=objview', '&amp;startDoc=', $startDoc)"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  
  <!-- ====================================================================== -->
  <!-- Recommendation Templates                                               -->
  <!-- ====================================================================== -->  
  
  <xsl:template match="crossQueryResult" mode="getRecommendations">
    <xsl:choose>
      <xsl:when test="$sysID">
        <ol id="recommendList">
          <xsl:apply-templates select="query//resultData/recommendation" mode="getRecommendations"/>
        </ol>
      </xsl:when>
      <xsl:otherwise>
        <ol id="recommendList">
          <xsl:apply-templates select="query//resultData/*[local-name()='SimilarProduct']" mode="getRecommendations"/>
        </ol>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Local recommendation -->
  <xsl:template match="recommendation" mode="getRecommendations">
    <xsl:variable name="recSysID" select="@sysID"/>
    <xsl:variable name="docHit" select="//docHit[string(meta/sysID[1]/snippet/hit/term)=$recSysID]"/>
    <li id="recommendItem">
      <xsl:choose>
        <xsl:when test="$docHit">
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="concat($crossqueryPath, '?object=', @sysID, '&amp;sysID=', @sysID, '&amp;style=melrec&amp;brand=melrec&amp;rmode=objview')"/>
            </xsl:attribute>
            <xsl:value-of select="$docHit/meta/title-main"/>
          </a>  
        </xsl:when>
        <xsl:otherwise>    
          <xsl:value-of select="@title"/>    
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$docHit/meta/title-series">
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="$docHit/meta/title-series[1]"/>
      </xsl:if>
      <xsl:if test="$docHit/meta/author or $docHit/meta/author-corporate">
        <xsl:choose>
          <xsl:when test="$docHit/meta/author">
            <xsl:text> / </xsl:text>
            <xsl:apply-templates select="$docHit/meta/author[1]"/>
            <xsl:if test="not(matches($docHit/meta/author[1],'.$'))">
              <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:text>&#160;</xsl:text>
          </xsl:when>
          <xsl:when test="$docHit/meta/author-corporate">
            <xsl:text> / </xsl:text>
            <xsl:apply-templates select="$docHit/meta/author-corporate[1]"/>
            <xsl:if test="not(matches($docHit/meta/author-corporate[1],'.$'))">
              <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:text>&#160;</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="$docHit/meta/publisher or $docHit/meta/place or $docHit/meta/year">
        <xsl:if test="$docHit/meta/publisher">
          <xsl:apply-templates select="$docHit/meta/publisher[1]"/>
        </xsl:if>
        <xsl:if test="$docHit/meta/place">
          <xsl:text>, </xsl:text>
          <xsl:apply-templates select="$docHit/meta/pub-place[1]"/>
        </xsl:if>
        <xsl:if test="$docHit/meta/year">
          <xsl:text>, </xsl:text>
          <xsl:apply-templates select="$docHit/meta/year[1]"/>
        </xsl:if>
        <xsl:text>. </xsl:text>
      </xsl:if>
      <xsl:if test="$docHit/meta/subject">
        <b>Subjects: </b>
        <span style="font-size:small">
          <xsl:apply-templates select="$docHit/meta/subject" mode="longDisplay"/>
        </span>
      </xsl:if>
      <!--<xsl:if test="$docHit/meta/format">
        <br/><b>Format: </b>
        <xsl:call-template name="map-format">
          <xsl:with-param name="string" select="string($docHit/meta/format[1])"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$docHit/meta/callnum">
        <br/><b>Call Number: </b>
        <xsl:apply-templates select="$docHit/meta/callnum[1]"/>
      </xsl:if>
      <br/>-->
    </li>
  </xsl:template>
  
  <!-- AWS recommendation -->
  <xsl:template match="*[local-name()='SimilarProduct']" mode="getRecommendations">
    <xsl:if test="position() &lt;= ($maxRecords)">
      <xsl:variable name="asin" select="string(*[local-name()='ASIN'])"/>
      <xsl:variable name="docHit" select="//docHit[string(meta/identifier-isbn[1]/snippet/hit/term)=$asin][1]"/>
      <xsl:variable name="sysID" select="$docHit/meta/sysID[1]"/>
      
      <li id="recommendItem">
        <!-- Is there a matching record here at CDL? -->
        <xsl:choose>
          <xsl:when test="$docHit">
            <a>
              <xsl:attribute name="href">
                <xsl:value-of select="concat($crossqueryPath, '?object=', $sysID, '&amp;sysID=', $sysID, '&amp;style=melrec&amp;brand=melrec&amp;rmode=objview')"/>
              </xsl:attribute>
              <xsl:value-of select="$docHit/meta/title-main[1]"/>
            </a>
            <xsl:if test="$docHit/meta/author">
              <xsl:text> / </xsl:text>
              <xsl:value-of select="$docHit/meta/author[1]"/>
              <xsl:if test="not(matches($docHit/meta/author[1],'.$'))">
                <xsl:text>.</xsl:text>
              </xsl:if>
              <xsl:text>&#160;</xsl:text>
            </xsl:if>
            <xsl:if test="$docHit/meta/publisher or $docHit/meta/pubDate">
              <xsl:if test="$docHit/meta/publisher">
                <xsl:value-of select="$docHit/meta/publisher[1]"/>
              </xsl:if>
              <xsl:if test="$docHit/meta/pubDate">
                <xsl:value-of select="$docHit/meta/pubDate[1]"/>
                <xsl:text>, </xsl:text>
              </xsl:if>
              <xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:if test="$docHit/meta/subject">
              <b>Subjects: </b>
              <span style="font-size:small">
                <xsl:for-each select="$docHit/meta/subject">
                  <xsl:value-of select="string(.)"/>
                  <xsl:if test="position() != last()">
                    <xsl:text> | </xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </span>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <a>
              <xsl:attribute name="href">
                <xsl:text>http://www.amazon.com/exec/obidos/tg/detail/-/</xsl:text>
                <xsl:value-of select="$asin"/>
              </xsl:attribute>
              <xsl:value-of select="*[local-name()='Title']"/>
            </a>
          </xsl:otherwise>
        </xsl:choose>
        
      </li>
    </xsl:if>
  </xsl:template>
  
  
  <!-- ====================================================================== -->
  <!-- More Like This Templates                                               -->
  <!-- ====================================================================== -->
  
  <xsl:template match="crossQueryResult" mode="moreLike">
    <xsl:choose>
      <xsl:when test="docHit">
        <!--<xsl:if test="$explainScores">
          <b>More-like-this query:</b>
          <xsl:value-of select="replace(docHit[1]/explanation/explanation/@description, 'weight\(', '')"/>
        </xsl:if>-->
        <xsl:apply-templates select="docHit" mode="moreLike"/>
      </xsl:when>
      <xsl:otherwise>
        No similar documents found.
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="docHit" mode="moreLike">
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:call-template name="morelike.crossquery.url">
            <xsl:with-param name="sysID" select="meta/sysID[1]"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="meta/title-main">
            <xsl:apply-templates select="meta/title-main[1]"/>
          </xsl:when>
          <xsl:when test="meta/title-journal">
            <xsl:apply-templates select="meta/title-journal[1]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>[Untitled]</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </a>
      <xsl:if test="meta/title-series">
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="meta/title-series[1]"/>
      </xsl:if>
      <xsl:if test="meta/author or meta/author-corporate">
        <xsl:choose>
          <xsl:when test="meta/author">
            <xsl:text> / </xsl:text>
            <xsl:apply-templates select="meta/author[1]"/>
            <xsl:if test="not(matches(meta/author[1],'.$'))">
              <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:text>&#160;</xsl:text>
          </xsl:when>
          <xsl:when test="meta/author-corporate">
            <xsl:text> / </xsl:text>
            <xsl:apply-templates select="meta/author-corporate[1]"/>
            <xsl:if test="not(matches(meta/author[1],'.$'))">
              <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:text>&#160;</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="meta/publisher or meta/place or meta/year">
        <xsl:if test="meta/publisher">
          <xsl:apply-templates select="meta/publisher[1]"/>
        </xsl:if>
        <xsl:if test="meta/place">
          <xsl:text>, </xsl:text>
          <xsl:apply-templates select="meta/pub-place[1]"/>
        </xsl:if>
        <xsl:if test="meta/year">
          <xsl:text>, </xsl:text>
          <xsl:apply-templates select="meta/year[1]"/>
        </xsl:if>
        <xsl:text>. </xsl:text>
      </xsl:if>
      <xsl:if test="meta/subject">
        <b>Subjects: </b>
        <span style="font-size:small">
          <xsl:apply-templates select="meta/subject" mode="longDisplay"/>
        </span>
      </xsl:if>
      <!--<xsl:if test="meta/format">
        <br/><b>Format: </b>
        <xsl:call-template name="map-format">
          <xsl:with-param name="string" select="string(meta/format[1])"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="meta/callnum">
        <br/><b>Call Number: </b>
        <xsl:apply-templates select="meta/callnum[1]"/>
      </xsl:if>
      <xsl:if test="explanation">
        <br/><b>Score: </b>
        <xsl:value-of select="explanation/@value"/>
      </xsl:if>-->
    </li>
  </xsl:template>
  
  <xsl:template name="morelike.crossquery.url">
    
    <xsl:param name="sysID"/>
    <xsl:variable name="queryString" select="replace(replace(replace(replace(replace(replace($queryString, 'rmode=[A-Za-z0-9]+', ''), 
      'docsPerPage=[0-9]+', ''), 
      'identifier=[A-Za-z0-9]+', ''), 
      'smode=[A-Za-z0-9]+', ''), 
      '&amp;+', '&amp;'), 
      '&amp;$', '')"/>
    
    <xsl:value-of select="concat($xtfURL, $crossqueryPath, '?object=', $sysID, '&amp;sysID=', $sysID, '&amp;', $queryString,'&amp;rmode=morelike-objview', '&amp;startDoc=', $startDoc)"/>
    
  </xsl:template>   

  
  <!-- ====================================================================== -->
  <!-- Book Bag Templates                                                     -->
  <!-- ====================================================================== -->
    
  <xsl:template name="bookBag">
    
    <xsl:param name="sysID"/>
    <xsl:variable name="quotedSysID" select="concat('&quot;', $sysID, '&quot;')"/>
    
    <xsl:if test="session:isEnabled()">
        <xsl:choose>
          <xsl:when test="$smode = 'showBag'">
            <xsl:variable name="removeURL" select="session:encodeURL(concat($xtfURL, $crossqueryPath, '?smode=removeFromBag&amp;sysID=', $sysID, '&amp;style=melrec'))"/>
            <span id="{$sysID}-remove">
              <span class="harshMellow">
                <a href="{concat('javascript:removeFromBag(', $quotedSysID, ', &quot;', $removeURL, '&quot;)')}">Remove</a>
              </span>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="session:getData('bag')/bag/savedDoc[@sysID=$sysID]">
                <span class="harshMellow">Selected</span>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="addURL" select="session:encodeURL(concat($xtfURL, $crossqueryPath, '?smode=addToBag&amp;sysID=', $sysID, '&amp;style=melrec'))"/>
                <span id="{$sysID}-add">
                  <span class="harshMellow">
                    <a href="{concat('javascript:addToBag(', $quotedSysID, ', &quot;', $addURL, '&quot;)')}">Add to Bookbag</a>
                  </span>
                </span>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="session:setData('queryURL', concat($xtfURL, $crossqueryPath, '?', $queryString))"/>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template match="docHit" mode="bookBag">
    
    <xsl:variable name="rank" select="@rank"/>    
    <xsl:variable name="score" select="@score"/>
    <xsl:variable name="resultString" select="replace($queryString,'&amp;rmode=[A-Za-z]+','')"/>
    <xsl:variable name="sysID" select="meta/sysID[1]"/>
    <xsl:variable name="quotedSysid" select="concat('&quot;', $sysID, '&quot;')"/>

    <tr id="{$sysID}-main">
      <xsl:choose>
        <xsl:when test="position() mod 2 = 0">
          <xsl:attribute name="class" select="'even'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class" select="'odd'"/>
        </xsl:otherwise>
      </xsl:choose>
      <td valign="top" width="60%">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="bookbag.crossquery.url">
              <xsl:with-param name="sysID" select="meta/sysID[1]"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="meta/title-main">
              <xsl:apply-templates select="meta/title-main[1]"/>
            </xsl:when>
            <xsl:when test="meta/title-journal">
              <xsl:apply-templates select="meta/title-journal[1]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>[Untitled]</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </td>
      <td valign="top" width="28%">
        <xsl:choose>
          <xsl:when test="meta/author">
            <xsl:apply-templates select="meta/author[1]"/>
            <xsl:text>&#160;</xsl:text>
          </xsl:when>
          <xsl:when test="meta/author-corporate">
            <xsl:apply-templates select="meta/author-corporate[1]"/>
            <xsl:text>&#160;</xsl:text>
          </xsl:when>
        </xsl:choose>
      </td>
      <td valign="top" width="4%" align="center">
        <xsl:apply-templates select="meta/year[1]"/>
      </td>
      
      <td valign="top" width="6%" align="center">
        <xsl:call-template name="bookBag">
          <xsl:with-param name="sysID" select="meta/sysID[1]"/>
        </xsl:call-template>
      </td>
    </tr>
  </xsl:template>
  
  
  <xsl:template name="bookbag.crossquery.url">
    
    <xsl:param name="sysID"/>
    
    <xsl:choose>
      <xsl:when test="matches($rmode, 'analysis')">
        <xsl:value-of select="concat($xtfURL, $crossqueryPath, '?object=', $sysID, '&amp;sysID=', $sysID, '&amp;rmode=objview-analysis', '&amp;startDoc=', $startDoc, '&amp;style=melrec&amp;brand=melrec')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($xtfURL, $crossqueryPath, '?object=', $sysID, '&amp;rmode=objview', '&amp;sysID=', $sysID, '&amp;startDoc=', $startDoc, '&amp;style=melrec&amp;brand=melrec')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Explanation Template                                                   -->
  <!-- ====================================================================== -->
  
  <xsl:template match="explanation">
    <xsl:param name="indent" select="0"/>
    <xsl:variable name="linkDivId" select="concat(generate-id(), '-link')"/>
    <xsl:variable name="dataDivId" select="concat(generate-id(), '-data')"/>

    <xsl:if test="count(*) &gt; 0">
      <div id="{$dataDivId}" style="visibility:hidden; height:0">
        <nobr>
          <img src="icons/default/spacer.gif" width="{20 * $indent}" height="1" border="0"/>
          <img src="icons/default/i_colpse.gif" border="0"/>
          <img src="icons/default/spacer.gif" width="10" height="1" border="0"/>
          <xsl:value-of select="@value"/>
          <xsl:text> = </xsl:text>
          <xsl:value-of select="@description"/>
          <xsl:if test="count(*) &gt;= 10">
            (omitting all but 10 of the <xsl:value-of select="count(*)"/> explanations...)
          </xsl:if>
        </nobr>
        <br/>
        <xsl:apply-templates select="*[position() &lt;= 10]">
          <xsl:with-param name="indent" select="$indent + 1"/>
        </xsl:apply-templates>
      </div>
    </xsl:if>
    
    <div id="{$linkDivId}">
      <nobr>
        <img src="icons/default/spacer.gif" width="{20 * $indent}" height="1" border="0"/>
        <xsl:choose>
          <xsl:when test="count(*) &gt; 0">
            <a>
              <xsl:attribute name="href" select="'javascript://'"/>
              <xsl:attribute name="onclick">
                javascript:swapVis('<xsl:value-of select="$linkDivId"/>', '<xsl:value-of select="$dataDivId"/>')
              </xsl:attribute>
              <img src="icons/default/i_expand.gif" border="0"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <img src="icons/default/i_colpse.gif" border="0"/>
          </xsl:otherwise>
        </xsl:choose>
        <img src="icons/default/spacer.gif" width="10" height="1" border="0"/>
        <xsl:value-of select="@value"/>
        <xsl:text> = </xsl:text>
        <xsl:value-of select="@description"/>
      </nobr>
      <br/>
    </div>
    
  </xsl:template>
  
  
  <!-- ====================================================================== -->
  <!-- Subject Links                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template match="subject">
    <a href="{$xtfURL}{$crossqueryPath}?subject={.}&amp;subject-join=exact&amp;smode={$smode}&amp;rmode={$rmode}&amp;style={$style}&amp;brand={$brand}&amp;frbrize={$frbrize}">
      <xsl:apply-templates/>
    </a>
    <xsl:if test="not(position() = last())">
      <xsl:text> | </xsl:text>
    </xsl:if>
  </xsl:template>
  
  
  <!-- ====================================================================== -->
  <!-- Mapping Templates                                                      -->
  <!-- ====================================================================== -->
  
  <xsl:template name="map-label">
    <xsl:param name="string"/>
    <xsl:variable name="map" select="document('')//xtf:label-map"/>
    <xsl:value-of select="$map/xtf:regex/xtf:replace[preceding-sibling::xtf:find[1]/text()=$string]"/>
  </xsl:template>
  
  <xtf:label-map>
    <xtf:regex>
      <xtf:find>title-journal</xtf:find>
      <xtf:replace>Journal</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>title-main</xtf:find>
      <xtf:replace>Title</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>title-series</xtf:find>
      <xtf:replace>Series</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>author</xtf:find>
      <xtf:replace>Author</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>author-corporate</xtf:find>
      <xtf:replace>Corporate Author</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>pub-place</xtf:find>
      <xtf:replace>Place of Publication</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>publisher</xtf:find>
      <xtf:replace>Publisher</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>year</xtf:find>
      <xtf:replace>Year</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>language</xtf:find>
      <xtf:replace>Language</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>note</xtf:find>
      <xtf:replace>Note</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>subject</xtf:find>
      <xtf:replace>Subject</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>subject-geographic</xtf:find>
      <xtf:replace>Geographic Subject</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>subject-topic</xtf:find>
      <xtf:replace>Topical Subject</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>subject-temporal</xtf:find>
      <xtf:replace>Temporal Subject</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>callnum</xtf:find>
      <xtf:replace>Call Number</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>callnum-class</xtf:find>
      <xtf:replace>Call Number Class</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>format</xtf:find>
      <xtf:replace>Format</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>location</xtf:find>
      <xtf:replace>Location</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>identifier-isbn</xtf:find>
      <xtf:replace>ISBN</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>identifier-issn</xtf:find>
      <xtf:replace>ISSN</xtf:replace>
    </xtf:regex>
  </xtf:label-map>
  
  <xsl:template name="map-format">
    <xsl:param name="string"/>
    <xsl:variable name="map" select="document('')//xtf:format-map"/>
    <xsl:choose>
      <xsl:when test="$map/xtf:regex/xtf:replace[preceding-sibling::xtf:find[1]/text()=$string]">
        <xsl:value-of select="$map/xtf:regex/xtf:replace[preceding-sibling::xtf:find[1]/text()=$string]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xtf:format-map>
    <xtf:regex>
      <xtf:find>BK</xtf:find>
      <xtf:replace>Book</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>CF</xtf:find>
      <xtf:replace>Conference</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>MP</xtf:find>
      <xtf:replace>Map</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>MU</xtf:find>
      <xtf:replace>Music</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>MX</xtf:find>
      <xtf:replace>Manuscript</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>SE</xtf:find>
      <xtf:replace>Journal</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>VM</xtf:find>
      <xtf:replace>Videorecording</xtf:replace>
    </xtf:regex>
  </xtf:format-map>
  
  <xsl:template name="map-language">
    <xsl:param name="string"/>
    <xsl:variable name="map" select="document('')//xtf:language-map"/>
    <xsl:choose>
      <xsl:when test="$map/xtf:regex/xtf:replace[preceding-sibling::xtf:find[1]/text()=$string]">
        <xsl:value-of select="$map/xtf:regex/xtf:replace[preceding-sibling::xtf:find[1]/text()=$string]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xtf:language-map>
    <xtf:regex>
      <xtf:find>eng</xtf:find>
      <xtf:replace>English</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>fre</xtf:find>
      <xtf:replace>French</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>ger</xtf:find>
      <xtf:replace>German</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>ita</xtf:find>
      <xtf:replace>Italian</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>lat</xtf:find>
      <xtf:replace>Latin</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>rus</xtf:find>
      <xtf:replace>Russian</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>spa</xtf:find>
      <xtf:replace>Spanish</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>jap</xtf:find>
      <xtf:replace>Japanese</xtf:replace>
    </xtf:regex>
    <xtf:regex>
      <xtf:find>chi</xtf:find>
      <xtf:replace>Chinese</xtf:replace>
    </xtf:regex>
  </xtf:language-map>
  
  
  <!-- ====================================================================== -->
  <!-- Site Mode Template                                                     -->
  <!-- ====================================================================== -->
  
  <xsl:template name="site-mode">
    
    <xsl:variable name="patronString">
      <xsl:value-of select="replace(replace(replace($queryString, '-analysis',''), 'analysis', ''), '&amp;explainScores=[a-z]+', '')"/>
    </xsl:variable>
 
    <xsl:variable name="analysisString">
      <xsl:choose>
        <xsl:when test="$smode">
          <xsl:choose>
            <xsl:when test="matches($smode, 'advanced')">
              <xsl:value-of select="replace($queryString, '&amp;smode=[A-Za-z\-]+','&amp;smode=advanced-analysis')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="replace($queryString, '&amp;smode=[A-Za-z\-]+','&amp;smode=analysis')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$rmode">
          <xsl:choose>
            <xsl:when test="matches($rmode, 'objview')">
              <xsl:value-of select="replace($queryString, '&amp;rmode=[A-Za-z\-]+','&amp;rmode=objview-analysis')"/>
            </xsl:when>
            <xsl:when test="matches($rmode, 'refine')">
              <xsl:value-of select="replace($queryString, '&amp;rmode=[A-Za-z\-]+','&amp;rmode=refine-analysis')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="replace($queryString, '&amp;rmode=[A-Za-z\-]+','&amp;rmode=analysis')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="//docHit">
              <xsl:value-of select="concat($queryString,'&amp;rmode=analysis')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat($queryString,'&amp;smode=analysis')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$smode='showBag'">
        <span style="color: silver">Patron Mode | Analysis Mode</span>
      </xsl:when>
      <xsl:when test="matches($rmode, 'analysis')">
        <a href="{$xtfURL}{$crossqueryPath}?{$patronString}">Patron Mode</a>
        <xsl:text> | Analysis Mode</xsl:text>
      </xsl:when>
      <xsl:when test="matches($smode, 'analysis')">
        <a href="{$xtfURL}{$crossqueryPath}?{$patronString}">Patron Mode</a>
        <xsl:text> | Analysis Mode</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Patron Mode | </xsl:text>
        <a href="{$xtfURL}{$crossqueryPath}?{$analysisString}">Analysis Mode</a>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Sort Options                                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template name="sort.options">
    <select size="1" name="sort">
      <xsl:choose>
        <xsl:when test="$sort = ''">
          <option value="" selected="selected">relevance</option>
          <option value="title">title</option>
          <option value="author">author</option>
          <option value="year">publication date</option>
          <option value="reverse-year">reverse date</option>
        </xsl:when>
        <xsl:when test="$sort = 'title'">
          <option value="">relevance</option>
          <option value="title" selected="selected">title</option>
          <option value="author">author</option>
          <option value="year">publication date</option>
          <option value="reverse-year">reverse date</option>
        </xsl:when>
        <xsl:when test="$sort = 'author'">
          <option value="">relevance</option>
          <option value="title">title</option>
          <option value="author" selected="selected">author</option>
          <option value="year">publication date</option>
          <option value="reverse-year">reverse date</option>
        </xsl:when>
        <xsl:when test="$sort = 'year'">
          <option value="">relevance</option>
          <option value="title">title</option>
          <option value="author">author</option>
          <option value="year" selected="selected">publication date</option>
          <option value="reverse-year">reverse date</option>
        </xsl:when>
        <xsl:when test="$sort = 'reverse-year'">
          <option value="">relevance</option>
          <option value="title">title</option>
          <option value="author">author</option>
          <option value="year">publication date</option>
          <option value="reverse-year" selected="selected">reverse date</option>
        </xsl:when>
      </xsl:choose>
    </select>
  </xsl:template>  
  
  <!-- ====================================================================== -->
  <!-- Header Template                                                        -->
  <!-- ====================================================================== -->
  
  <xsl:template name="header">
    <div id="header">
      <table width="100%" border="0">
        <tr>
          <td align="left" width="30%">
            <xsl:choose>
              <xsl:when test="matches($smode,'analysis') or matches($rmode,'analysis')">
                <a href="search?style=melrec&amp;brand=melrec&amp;smode=analysis"><img src="/melrec/images/relvyl_logo.gif" alt="Relvyl" title="Relvyl" border="0"/></a>                
              </xsl:when>
              <xsl:otherwise>
                <a href="search?style=melrec&amp;brand=melrec"><img src="/melrec/images/relvyl_logo.gif" alt="Relvyl" title="Relvyl" border="0"/></a>
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td align="center" width="30%">
            <xsl:call-template name="site-mode"/>
          </td>
          <td align="right" width="40%">
            <xsl:choose>
              <xsl:when test="not($smode or $rmode or //docHit)">
                <xsl:text>Home</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="matches($smode, 'analysis') or matches($rmode, 'analysis')">
                    <a href="search?style=melrec&amp;brand=melrec&amp;smode=analysis">Home</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <a href="search?style=melrec&amp;brand=melrec">Home</a>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text> | </xsl:text>
            <xsl:choose>
              <xsl:when test="contains($smode,'advanced')">
                <xsl:text>Advanced Search</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="matches($smode, 'analysis') or matches($rmode, 'analysis')">
                    <a href="search?style=melrec&amp;brand=melrec&amp;smode=analysis-advanced">Advanced Search</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <a href="search?style=melrec&amp;brand=melrec&amp;smode=advanced">Advanced Search</a>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text> | </xsl:text>
            <xsl:choose>
              <xsl:when test="contains($smode,'showBag')">
                <xsl:text>Bookbag</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="matches($smode,'analysis') or matches($rmode,'analysis')">
                    <a href="{concat($xtfURL, $crossqueryPath, '?smode=showBag&amp;sort=title&amp;rmode=analysis&amp;', replace(replace(replace($queryString,'&amp;*object=[A-Za-z0-9\-]+',''),'&amp;*frbrize=yes',''),'&amp;*rmode=[A-Za-z\-]+',''))}">Bookbag</a>
                  </xsl:when>
                  <xsl:otherwise>
                    <a href="{concat($xtfURL, $crossqueryPath, '?smode=showBag&amp;sort=title&amp;', replace(replace(replace($queryString,'&amp;*object=[A-Za-z0-9\-]+',''),'&amp;*frbrize=yes',''),'&amp;*rmode=[A-Za-z\-]+',''))}">Bookbag</a>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text> | </xsl:text>
            <a href="/melrec/help.html">Help</a>
            <!--<xsl:call-template name="login-status"/> -->
          </td>
        </tr>
      </table>
    </div>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Search Form Debug Template                                             -->
  <!-- ====================================================================== -->
  
  <xsl:template name="viewParams">
    <div style="background: yellow">
      <p>
        <h4>Search Parameter Diagnostic:</h4>
        <xsl:for-each select="parameters/param[not(matches(@name, 'brand|style|weight'))]">
          <xsl:value-of select="@name"/>
          <xsl:text>=</xsl:text>
          <xsl:value-of select="@value"/>
          <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </p>
      <p>
        completeString=<xsl:value-of select="$completeString"/><br/>
        cleanString=<xsl:value-of select="$cleanString"/><br/>
        param1=<xsl:value-of select="$param1"/><br/>
        value1=<xsl:value-of select="$value1"/><br/>
        join1=<xsl:value-of select="$join1"/><br/><br/>
        param2=<xsl:value-of select="$param2"/><br/>
        value2=<xsl:value-of select="$value2"/><br/>
        join2=<xsl:value-of select="$join2"/><br/>
      </p>
    </div>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Generate ARK List for Testing                                          -->
  <!-- ====================================================================== -->
  
  <!-- Leave indenting as is in the following template! -->
  
  <xsl:template match="crossQueryResult" mode="test">
    <xsl:result-document format="xml" exclude-result-prefixes="#all">
      <search count="{@totalDocs}" queryString="{$queryString}">
        <xsl:for-each select="docHit">
          <xsl:sort select="number(@rank)" />
          <hit sysID="{meta/sysID[1]}"
            rank="{@rank}"
            score="{@score}"
            totalHits="{count(.//hit)}"/>
        </xsl:for-each>
      </search>
    </xsl:result-document>
  </xsl:template>
  
</xsl:stylesheet>
