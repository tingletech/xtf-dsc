<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                                                                                          -->
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
                              xmlns:xs="http://www.w3.org/2001/XMLSchema" 
                              xmlns:session="java:org.cdlib.xtf.xslt.Session">
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="common/resultFormatterCommon.xsl"/>
  <xsl:import href="grid/resultFormatter.xsl"/>
  <xsl:import href="list/resultFormatter.xsl"/>
  <xsl:import href="browse/resultFormatter.xsl"/>
  <!-- xsl:import href="../common/spelling.xsl"/ -->
  
  <!-- ====================================================================== -->
  <!-- Output Parameters                                                      -->
  <!-- ====================================================================== -->

  <xsl:output method="xhtml" indent="yes" encoding="UTF-8" media-type="text/html" 
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
              omit-xml-declaration="yes" 
              exclude-result-prefixes="#all"/>


  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->
  
  <xsl:param name="xtfURL" select="'/'"/>
  
  <!-- ====================================================================== -->
  <!-- Root Template                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$rmode=test">
        <xsl:apply-templates select="crossQueryResult" mode="test"/>
      </xsl:when> 
      <xsl:when test="$facet='azBrowse' or $facet='ethBrowse' or $facet='jardaBrowse'">
        <xsl:apply-templates select="crossQueryResult" mode="browse"/>
      </xsl:when> 
      <xsl:otherwise>
        <xsl:apply-templates select="crossQueryResult" mode="results"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Results Template                                                       -->
  <!-- ====================================================================== -->
  
  <xsl:template match="crossQueryResult" mode="results">
    
    <xsl:variable name="keywordValue">
      <xsl:if test="$keyword-add">
        <xsl:value-of select="$keyword-add"/>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:if test="$keyword">
        <xsl:value-of select="$keyword"/>
      </xsl:if>
    </xsl:variable>
    
    <xsl:variable name="totalDocs">
      <xsl:choose>
        <xsl:when test="facet/@totalDocs > 999999">
          <xsl:analyze-string select="facet/@totalDocs" regex="([0-9]+)([0-9][0-9][0-9])([0-9][0-9][0-9])$">
            <xsl:matching-substring>
              <xsl:value-of select="regex-group(1)"/>
              <xsl:value-of select="','"/>
              <xsl:value-of select="regex-group(2)"/>
              <xsl:value-of select="','"/>
              <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="facet/@totalDocs > 999">
          <xsl:analyze-string select="facet/@totalDocs" regex="([0-9]+)([0-9][0-9][0-9])$">
            <xsl:matching-substring>
              <xsl:value-of select="regex-group(1)"/>
              <xsl:value-of select="','"/>
              <xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="facet/@totalDocs"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
      <head>
        <title><xsl:copy-of select="$brand.search.title"/></title>
        <xsl:copy-of select="$brand.links"/>
      </head>
      <body>  
        <a class="jump-to-content" href="#content">Jump to Content</a>
        <xsl:comment>BEGIN PAGE ID</xsl:comment>
        <div>
          <xsl:attribute name="id">
            <xsl:choose>
              <xsl:when test="facet/group[@value='image']/docHit and not(matches($group,'text|website'))">results-grid</xsl:when>
              <xsl:otherwise>results</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:comment>BEGIN HEADER ROW</xsl:comment>
          <xsl:copy-of select="$brand.header"/>
          <xsl:comment>END HEADER ROW</xsl:comment>
          <xsl:comment>BEGIN SECONDARY HEADER ROW</xsl:comment>
          <div id="header-secondary">
            <div id="multi-use">
              <!-- xsl:if test="$brand='calcultures' or $brand='jarda'">
                <a href="{$brand.hotdog.img/@href}"><img src="{$brand.hotdog.img/@src}" border="0"/></a>
              </xsl:if -->
              <xsl:comment>BEGIN BREADCRUMBS</xsl:comment>
              <div id="breadcrumbs">
                <xsl:copy-of select="$brand.breadcrumb.base"/>
                <xsl:text> &gt; Search Results</xsl:text>
              </div>
              <xsl:comment>END BREADCRUMBS</xsl:comment>
              <xsl:comment>BEGIN RESULTS STATUS</xsl:comment>
              <div id="results-status">
                <xsl:comment>BEGIN NAVBOX OUTER</xsl:comment>
                <div id="navbox-outer" class="nifty1">
                  <div class="box1">
                    <div id="navbox-inner">
                      <h1>
                        <xsl:value-of select="$totalDocs"/>
                        <xsl:choose>
                          <xsl:when test="number($totalDocs) = 1">
                            <xsl:text> result</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text> results</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </h1>
                      <span class="matching-terms">
                        <xsl:text>for: </xsl:text>
                        <xsl:call-template name="format-query"/>
                      </span>

											<!-- xsl:call-template name="did-you-mean" -->
											 <xsl:if test="//spelling">
                <!-- xsl:call-template name="did-you-mean">
                  <xsl:with-param name="baseURL" select="concat($xtfURL, $crossqueryPath, '?', $queryString)"/>
                  <xsl:with-param name="spelling" select="//spelling"/>
                </xsl:call-template -->
          </xsl:if>



                      <xsl:comment>BEGIN BUTTONS OUTER</xsl:comment>
                      <div id="buttons-outer" class="nifty4">
                        <div class="box4">
                          <table>
                            <tr>
                              <xsl:apply-templates select="facet[1]/group" mode="tab"/>
                            </tr>
                          </table>
                        </div>
                      </div>
                      <xsl:comment>END BUTTONS OUTER</xsl:comment>
                    </div>
                  </div>
                </div>
                <xsl:comment>END NAVBOX OUTER</xsl:comment>
              </div>
              <xsl:comment>END RESULTS STATUS</xsl:comment>
            </div>
            <xsl:comment>BEGIN SITE-SEARCH</xsl:comment>
            <xsl:copy-of select="$brand.search.box"/>
            <xsl:comment>END SITE-SEARCH</xsl:comment>
            <br clear="all"/>
          </div>
          <xsl:comment>END SECONDARY HEADER ROW</xsl:comment>
          <xsl:choose>
            <!-- Display results -->
            <xsl:when test="facet/group/docHit">
              <a name="content"/>
              <xsl:comment>BEGIN DISPLAY RESULTS</xsl:comment>
              <div id="content" class="nifty1">
                <div class="box1">
                  <div id="content-inner">
                    <xsl:comment>BEGIN CONTENT SECONDARY</xsl:comment>
                    <div class="results-tools">
                      <div id="results-tools-top">
                        <div class="hitcount-pag">
                          <div class="hitcount">
                            <xsl:call-template name="page-summary">
                              <xsl:with-param name="object-type">
                                <xsl:choose>
                                  <xsl:when test="facet/group[@value='image']/docHit">images</xsl:when>
                                  <xsl:when test="facet/group[@value='text']/docHit">texts</xsl:when>
                                  <xsl:otherwise>websites</xsl:otherwise>
                                </xsl:choose>
                              </xsl:with-param>
                            </xsl:call-template>
                          </div>
                          <div class="pagination">
                            <xsl:call-template name="pages"/>
                          </div>
                          <br clear="all" />
                        </div>
                        <div class="disp-form">
                          <div class="display">display:</div>
                          <div class="display-form">
                            <form name="display-form" action="{$xtfURL}{$crossqueryPath}" method="GET">
                              <xsl:call-template name="page.options"/>
                              <input type="hidden" name="facet" value="{$facet}"/>
                              <input type="hidden" name="group" value="{$group}"/>
                              <input type="hidden" name="type" value="{$type}"/>
                              <xsl:if test="$subject">
                                <input type="hidden" name="subject" value="{$subject}"/>
                              </xsl:if>
			      <xsl:if test="$relation-join">
                                <input type="hidden" name="relation-join" value="{$relation-join}"/>
                              </xsl:if>
                              <xsl:if test="$keyword">
                                <input type="hidden" name="keyword" value="{$keyword}"/>
                                <input type="hidden" name="keyword-add" value="{$keyword-add}"/>
                                <input type="hidden" name="keyword-join" value="{$keyword-join}"/>
                              </xsl:if>
                              <xsl:if test="$format">
                                <input type="hidden" name="format" value="{$format}"/>
                              </xsl:if>
                              <xsl:if test="$azBrowse">
                                <input type="hidden" name="azBrowse" value="{$azBrowse}"/>
                                <input type="hidden" name="azBrowse-join" value="{$azBrowse-join}"/>
                              </xsl:if>
                              <xsl:if test="$ethBrowse">
                                <input type="hidden" name="ethBrowse" value="{$ethBrowse}"/>
                                <input type="hidden" name="ethBrowse-join" value="{$ethBrowse-join}"/>
                              </xsl:if>
                              <xsl:if test="$jardaBrowse">
                                <input type="hidden" name="jardaBrowse" value="{$jardaBrowse}"/>
                                <input type="hidden" name="jardaBrowse-join" value="{$jardaBrowse-join}"/>
                              </xsl:if>
                              <xsl:if test="$subject">
                                <input type="hidden" name="subject" value="{$subject}"/>
                                <input type="hidden" name="subject-join" value="{$subject-join}"/>
                              </xsl:if>
                              <xsl:if test="$publisher">
                                <input type="hidden" name="publisher" value="{$publisher}"/>
                                <input type="hidden" name="publisher-join" value="{$publisher-join}"/>
                              </xsl:if>
                              <xsl:if test="$relation">
                                <input type="hidden" name="relation" value="{$relation}"/>
                                <input type="hidden" name="relation-join" value="{$relation-join}"/>
                              </xsl:if>
                              <input type="hidden" name="sortDocsBy" value="{$sortDocsBy}"/>
                              <input type="hidden" name="style" value="{$style}"/>
                              <input type="hidden" name="brand" value="{$brand}"/>
                              <input type="image" src="http://www.calisphere.universityofcalifornia.edu/images/buttons/go.gif" class="search-button" alt="Go!" title="Go!"/>
                            </form>
                          </div>
                          <br clear="all"/>
                        </div>
                      </div>
                      <div id="search-narrow">
                        <xsl:comment>BEGIN SEARCH WITHIN RESULTS BOX</xsl:comment>
                        <div class="searchbox-outer nifty2">
                          <div class="box2">
                            <div id="search-within-inner">
                              <img src="http://www.calisphere.universityofcalifornia.edu/images/headings_text/search_within_results.gif" width="132" height="13" alt="Search Within Results" title="Search Within Results"/>
                              <form action="{$xtfURL}{$crossqueryPath}" class="search-form" name="search-form" method="GET">
                                <input name="keyword" type="text" size="17" maxlength="80"/>
                                <input type="hidden" name="keyword-add" value="{$keywordValue}"/>
                                <input type="hidden" name="facet" value="{$facet}"/>
                              <xsl:if test="$subject">
                                <input type="hidden" name="subject" value="{$subject}"/>
                              </xsl:if>
                              <xsl:if test="$publisher">
                                <input type="hidden" name="publisher" value="{$publisher}"/>
                              </xsl:if>
                                <xsl:if test="$relation">
                                  <input type="hidden" name="relation" value="{$relation}"/>
                                </xsl:if>
                                <xsl:if test="$relation-join">
                                  <input type="hidden" name="relation-join" value="{$relation-join}"/>
                                </xsl:if>
                              <xsl:if test="$format">
                                <input type="hidden" name="format" value="{$format}"/>
                              </xsl:if>
                                <xsl:if test="$azBrowse">
                                  <input type="hidden" name="azBrowse" value="{$azBrowse}"/>
                                  <input type="hidden" name="azBrowse-join" value="{$azBrowse-join}"/>
                                </xsl:if>
                                <xsl:if test="$ethBrowse">
                                  <input type="hidden" name="ethBrowse" value="{$ethBrowse}"/>
                                  <input type="hidden" name="ethBrowse-join" value="{$ethBrowse-join}"/>
                                </xsl:if>
                                <xsl:if test="$jardaBrowse">
                                  <input type="hidden" name="jardaBrowse" value="{$jardaBrowse}"/>
                                  <input type="hidden" name="jardaBrowse-join" value="{$jardaBrowse-join}"/>
                                </xsl:if>
                                <input type="hidden" name="style" value="{$style}"/>
                                <input type="hidden" name="sortDocsBy" value="{$sortDocsBy}"/>

                                <input type="hidden" name="brand" value="{$brand}"/>
                                <input type="image" src="http://www.calisphere.universityofcalifornia.edu/images/buttons/search.gif" class="search-button" alt="Search" title="Search"/>
                              </form>
                            </div>
                          </div>
                        </div>
                        <!-- div class="searchbox-outer nifty2">
                          <div class="box2">
                            <div id="search-within-inner">
				<xsl:apply-templates select="facet[@field='facet-subject']/group" mode="blue"/>
                            </div>
                          </div>
                        </div -->
                        <xsl:comment>END SEARCH WITHIN RESULTS BOX</xsl:comment>
                      </div>
                      <br clear="all"/>
                    </div>
                    <xsl:comment>END CONTENT SECONDARY</xsl:comment>
                    <xsl:comment>BEGIN CONTENT PRIMARY</xsl:comment>
                    <!-- This structure should eventually be compacted -->
                    <xsl:choose>
                      <xsl:when test="$group='image' and facet/group[@value='image']/docHit">
                        <xsl:call-template name="content-primary-grid"/>
                      </xsl:when>
                      <xsl:when test="$group='text' and facet/group[@value='text']/docHit">
                        <xsl:call-template name="content-primary-list"/>
                      </xsl:when>
                      <xsl:when test="$group='website' and facet/group[@value='website']/docHit">
                        <xsl:call-template name="content-primary-list"/>
                      </xsl:when>
                      <xsl:when test="facet/group[@value='image']/docHit">
                        <xsl:call-template name="content-primary-grid"/>
                      </xsl:when>
                      <xsl:when test="facet/group[@value='text']/docHit">
                        <xsl:call-template name="content-primary-list"/>
                      </xsl:when>
                      <xsl:when test="facet/group[@value='website']/docHit">
                        <xsl:call-template name="content-primary-list"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:call-template name="content-primary-grid"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:comment>END CONTENT PRIMARY</xsl:comment>
                    <br clear="all"/>
                  </div>
                </div>
              </div>
            </xsl:when>
            <!-- 0 results page -->
            <xsl:otherwise>

<!--BEGIN ERROR BOX -->
<div id="error">
<div class="nifty1">
<div class="box1">

<p>Sorry, your search for 
<xsl:call-template name="format-query"/> 
did not find any matches.</p>

</div>
</div>
</div>
<!--END ERROR BOX -->
            </xsl:otherwise>
          </xsl:choose>
          <xsl:comment>END DISPLAY RESULTS</xsl:comment>
          <xsl:copy-of select="$brand.footer"/>
          <xsl:comment>END PAGE ID</xsl:comment>
        </div>
        <!-- Store search -->
        <xsl:if test="session:isEnabled()">
          <xsl:value-of select="session:setData('queryURL', concat($xtfURL, $crossqueryPath, '?', $queryString, '&amp;startDoc=', $startDoc))"/>
        </xsl:if>
      </body>
    </html>
  </xsl:template>



  <!-- xsl:template match="group" mode="blue">
	<div><xsl:value-of select="@value"/> (<xsl:value-of select="@totalDocs"/>)</div>
  </xsl:template -->

  <!-- ====================================================================== -->
  <!-- Type Tab Template                                                      -->
  <!-- ====================================================================== -->
  
  <xsl:template match="group" mode="tab">
    
    <xsl:variable name="tabString" select="replace(replace(replace($queryString,'group=[A-Za-z0-9\-]+',''),'style=[A-Za-z0-9\-]+',''), '&amp;+', '&amp;')"/>
    <xsl:variable name="totalDocs">
      <xsl:choose>
        <xsl:when test="@totalDocs > 999999">
          <xsl:analyze-string select="@totalDocs" regex="([0-9]+)([0-9][0-9][0-9])([0-9][0-9][0-9])$">
            <xsl:matching-substring>
              <xsl:value-of select="regex-group(1)"/>
              <xsl:value-of select="','"/>
              <xsl:value-of select="regex-group(2)"/>
              <xsl:value-of select="','"/>
              <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="@totalDocs > 999">
          <xsl:analyze-string select="@totalDocs" regex="([0-9]+)([0-9][0-9][0-9])$">
            <xsl:matching-substring>
              <xsl:value-of select="regex-group(1)"/>
              <xsl:value-of select="','"/>
              <xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@totalDocs"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="tabValue">
      <xsl:choose>
        <xsl:when test="@totalDocs = 1">
          <xsl:value-of select="@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(@value,'s')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="@value='OTHER' and not($rmode='reveal')"/>
      <!-- Hiding finding aids for now -->
      <xsl:when test="@value='finding aid' and not($rmode='reveal')"/>
      <xsl:when test="@value=$group and docHit">
        <td>
          <xsl:comment>BEGIN BUTTON</xsl:comment>
          <div class="button nifty5">
            <div class="box5">
              <xsl:value-of select="$totalDocs"/>
              <xsl:text>&#160;</xsl:text>
              <xsl:value-of select="$tabValue"/>
            </div>
          </div>
          <xsl:comment>END BUTTON</xsl:comment>
        </td>
      </xsl:when>
      <xsl:when test="not($group) and docHit">
        <td>
          <xsl:comment>BEGIN BUTTON</xsl:comment>
          <div class="button nifty5">
            <div class="box5">
              <xsl:value-of select="$totalDocs"/>
              <xsl:text>&#160;</xsl:text>
              <xsl:value-of select="$tabValue"/>
            </div>
          </div>
          <xsl:comment>END BUTTON</xsl:comment>
        </td>
      </xsl:when>
      <xsl:when test="@totalDocs > 0">
        <td>
          <xsl:comment>BEGIN BUTTON</xsl:comment>
          <div class="button nifty6">
            <div class="box6">
              <a href="{$xtfURL}{$crossqueryPath}?{$tabString}&amp;style={$style}&amp;group={@value}">
                <xsl:value-of select="$totalDocs"/>
                <xsl:text>&#160;</xsl:text>
                <xsl:value-of select="$tabValue"/>
              </a>
            </div>
          </div>
          <xsl:comment>END BUTTON</xsl:comment>
        </td>
      </xsl:when>
      <xsl:otherwise>
        <td>
          <xsl:comment>BEGIN BUTTON</xsl:comment>
          <div class="button nifty6">
            <div class="box6">
              <xsl:value-of select="$totalDocs"/>
              <xsl:text>&#160;</xsl:text>
              <xsl:value-of select="$tabValue"/>
            </div>
          </div>
          <xsl:comment>END BUTTON</xsl:comment>
        </td>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Snippet Template                                                       -->
  <!-- ====================================================================== -->

  <xsl:template match="snippet">
    <xsl:choose>
      <xsl:when test="parent::docHit">
				<div>
        <xsl:text>...</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>...</xsl:text>
				</div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <!-- ====================================================================== -->
  <!-- Hit Template                                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="hit">
    <span class="hit">
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
        <!-- Snippet links removed at Rosalie's request -->
        <!--<a href="{$snippet.link}">-->
          <xsl:apply-templates/>
        <!--</a>-->
      </xsl:when>
      <xsl:otherwise>
        <b><xsl:apply-templates/></b>
      </xsl:otherwise>
    </xsl:choose> 
   
  </xsl:template>
  
</xsl:stylesheet>
