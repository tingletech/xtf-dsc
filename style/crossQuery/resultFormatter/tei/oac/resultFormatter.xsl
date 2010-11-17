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

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session">
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="../../common/cdlResultFormatterCommon.xsl"/>
  
  <!-- ====================================================================== -->
  <!-- Output Parameters                                                      -->
  <!-- ====================================================================== -->

  <xsl:output method="xhtml" indent="yes" encoding="UTF-8" media-type="text/html" 
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->

  <!-- Removing port for CDL -->
  <xsl:param name="xtfURL" select="replace($root.path, ':[0-9]{4}/', '/')"/>
  <xsl:param name="css.path" select="concat($xtfURL, 'css/oac/')"/>
  <xsl:param name="oac.server" select="'http://www.oac.cdlib.org/'"/>
  <xsl:param name="brand" select="'oac'"/>
  
  <!-- ====================================================================== -->
  <!-- Root Template                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="contains($smode, '-modify')">
        <xsl:apply-templates select="crossQueryResult" mode="form"/>
      </xsl:when>      
      <xsl:when test="
        $text or 
        $title or 
        $creator or 
        $subject or 
        $description or 
        $publisher or 
        $contributor or 
        $date or 
        $type or 
        $format or 
        $identifier or 
        $source or 
        $language or 
        $relation or 
        $coverage or 
        $rights or 
        $year or
        $keyword">
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
  
    <html xmlns="http://www.w3.org/1999/xhtml">
      
      <head>
        <title>OAC Texts: Search Results</title>
        <xsl:copy-of select="$brand.links"/>
      </head>

        <xsl:if test="session:isEnabled()">
          <xsl:value-of select="session:setData('queryURL', concat($xtfURL, $crossqueryPath, '?', $queryString, '&amp;startDoc=', $startDoc))"/>
	</xsl:if>

      
      <body>
        
        <xsl:copy-of select="$brand.header"/>
        
        <table cellspacing="0" class="maintable" width="100%" cellpadding="0" border="0">
          <tr>
            <td class="textheaderback" width="20">
              <img alt="" src="http://oac.cdlib.org/images/spacer.gif" width="20" height="1" border="0"/>
            </td>
            <td class="textheaderback" width="730" align="left">
              <a href="http://oac.cdlib.org/texts">Texts</a>
              <xsl:text>&gt; Search Results</xsl:text>
            </td>
          </tr>
        </table>
        
        <xsl:comment>BEGIN SEARCH RESULTS</xsl:comment>
        <div class="search-results-outer">
          <form class="search-form" name="shortForm" method="get" action="{$xtfURL}{$crossqueryPath}">
            <h3>
              <xsl:text>Search Results </xsl:text>
              <!-- input name="text" type="text" size="20" value="{$text}"/ -->
              <xsl:text>&#160;</xsl:text>
              <input type="hidden" name="style" value="{$style}"/>                   
              <input type="hidden" name="smode">
                <xsl:attribute name="value" select="replace($smode, '-modify', '')"/>
              </input>               
              <input type="hidden" name="rmode" value="{$rmode}"/>           
              <input type="hidden" name="brand" value="{$brand}"/>
              <!-- This stupid construct introduces 'x' and 'y' attributes into the query string! -->
              <!-- input type="submit" src="{$oac.server}images/goto.gif" align="middle"/ -->
              <!-- a href="javascript:document.shortForm.submit()" onClick="return mySubmit()">
                <img src="{$oac.server}images/goto.gif" border="0" align="middle" alt="Submit"/>
              </a -->
            </h3>
            
          </form>   
          
          <p>
            <xsl:text>Your search for </xsl:text>
            <xsl:call-template name="format-query"/>
            <xsl:text> found </xsl:text>
            <xsl:value-of select="@totalDocs"/>
            <xsl:text> item(s). </xsl:text>

 		<xsl:choose>
                  <xsl:when test="($keyword) and (not(contains($smode, '-modify')))">
                        <a class="top-link" href="{$oac.server}texts/">
                                <xsl:text>New Search</xsl:text>
                        </a>
                        <!-- a class="top-link" href="{$xtfURL}{$crossqueryPath}?{$modifyString}">
                                <xsl:text>Modify Search</xsl:text>
                        </a -->
                  </xsl:when>
                </xsl:choose>




          </p>
          
          <xsl:choose>
            <xsl:when test="docHit">
              <div class="number-items">            
                <xsl:call-template name="page-summary">
                  <xsl:with-param name="object-type" select="'items'"/>
                </xsl:call-template>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="oac-help"/>
            </xsl:otherwise>
          </xsl:choose>
          
          <xsl:call-template name="searchBar"/>

          <xsl:if test="docHit">
            <table class="search-results-table" border="0">
              <xsl:choose>
                <xsl:when test="contains($rmode, 'compact')">            
                  <xsl:apply-templates select="docHit" mode="compact"/>
                </xsl:when>            
                <xsl:otherwise>            
                  <xsl:apply-templates select="docHit"/>
                </xsl:otherwise>
              </xsl:choose>
            </table>
          </xsl:if>
          
          <xsl:comment>END SEARCH RESULTS</xsl:comment>
          
          <xsl:call-template name="searchBar"/>
          
        </div>
        
        <xsl:copy-of select="$brand.footer"/>  
        
      </body>
    </html>
    
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Form Template                                                          -->
  <!-- ====================================================================== -->

  <xsl:template match="crossQueryResult" mode="form">  
      
    <html xmlns="http://www.w3.org/1999/xhtml">
      
      <head>
        <title>OAC Texts: Search Results</title>
        <xsl:copy-of select="$brand.links"/>
      </head>
      
      <body>
        
        <xsl:copy-of select="$brand.header"/>
        
        <xsl:comment>BEGIN SEARCH RESULTS</xsl:comment>
        <div class="search-results-outer" align="center">
          <form class="search-form" name="shortForm" method="get" action="{$xtfURL}{$crossqueryPath}">
            <h3>
              <xsl:text>Keyword </xsl:text>
              <input name="text" type="text" size="20" value="{$text}"/>
              <xsl:text>&#160;</xsl:text>
              <input type="hidden" name="style" value="{$style}"/>                  
              <input type="hidden" name="smode">
                <xsl:attribute name="value" select="replace($smode, '-modify', '')"/>
              </input>             
              <input type="hidden" name="rmode" value="{$rmode}"/>                  
              <input type="hidden" name="brand" value="{$brand}"/>           
              <!-- This stupid construct introduces 'x' and 'y' attributes into the query string! -->
              <!-- input type="submit" src="{$oac.server}images/goto.gif" align="middle"/ -->
              <a href="javascript:document.shortForm.submit()" onClick="return mySubmit()">
                <img src="{$oac.server}images/goto.gif" border="0" align="middle" alt="Submit"/>
              </a>
            </h3>
          </form>  
        </div>
        <xsl:comment>END SEARCH RESULTS</xsl:comment>        
        <xsl:copy-of select="$brand.footer"/>        
      </body>
    </html>
    
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Normal Document Hit Template                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit">

    <xsl:variable name="fullark" select="meta/identifier[1]"/>
    
    <tr class="search-row">
          <td class="search-results-number"><xsl:value-of select="@rank"/>.</td>
      <td class="search-results-text">
        <div class="search-results-text-inner">
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
          <xsl:if test="meta/publisher">
            <strong>Publisher: </strong>
            <xsl:value-of select="meta/publisher[1]"/>
            <br/>
          </xsl:if>
          <xsl:if test="meta/sort-year">
            <strong>Date: </strong>
            <xsl:value-of select="meta/sort-year[1]"/>
            <br/>
          </xsl:if>          
          <xsl:if test="meta/subject">
            <strong>Subjects: </strong>
            <xsl:apply-templates select="meta/subject"/>
            <br/>
          </xsl:if>         
          <xsl:if test="snippet">          
            <strong>Search terms in context (<xsl:value-of select="@totalHits"/>):</strong>
            <br/>
            <div class="search-results-snippets">
              <xsl:apply-templates select="snippet"/>
            </div>
          </xsl:if>
        </div>
      </td>
    </tr>

  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Compact Document Hit Template                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit" mode="compact">
    
    <xsl:variable name="fullark" select="meta/identifier[1]"/>

    <tr>
      <td align="left" width="5%">
        <xsl:if test="$sort != 'title' and $sort != 'publisher' and $sort != 'year'">
          <xsl:value-of select="@rank"/><xsl:text>.</xsl:text>
        </xsl:if>    
      </td>
      <td align="left" width="45%">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="dynaxml.url">
              <xsl:with-param name="fullark" select="$fullark"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="meta/title[1]"/>
        </a>
      </td>
      <td align="left" width="20%">
        <xsl:apply-templates select="meta/publisher[1]"/>
      </td>      
      <td align="left" width="20%">
        <xsl:apply-templates select="meta/subject[1]"/>
      </td>     
      <td align="center" width="5%">
        <xsl:apply-templates select="meta/year[1]"/>
      </td>  
      <td align="right" width="5%">
        <xsl:value-of select="@totalHits"/>
      </td>  
    </tr>
    <tr>
      <td colspan="7"><hr/></td>
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
    <xsl:apply-templates/>
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
        <a class="search-item" href="{$snippet.link}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="search-term">  
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose> 
   
  </xsl:template>
      
  <!-- ====================================================================== -->
  <!-- Search Options (Overides Common Version)                               -->
  <!-- ====================================================================== -->
     
  <xsl:template name="sort.options">
    <select size="1" name="sort">
      <xsl:choose>
        <xsl:when test="$sort = ''">
          <option value="" selected="selected">Relevance</option>
          <option value="title">Title</option>
          <option value="publisher">Publisher</option>
          <option value="year">Year</option>
        </xsl:when>
        <xsl:when test="$sort = 'title'">
          <option value="">Relevance</option>
          <option value="title" selected="selected">Title</option>
          <option value="publisher">Publisher</option>
          <option value="year">Year</option>
        </xsl:when>
        <xsl:when test="$sort = 'publisher'">
          <option value="">Relevance</option>
          <option value="title">Title</option>
          <option value="publisher" selected="selected">Publisher</option>
          <option value="year">Year</option>
        </xsl:when>
        <xsl:when test="$sort = 'year'">
          <option value="">Relevance</option>
          <option value="title">Title</option>
          <option value="publisher">Publisher</option>
          <option value="year" selected="selected">Year</option>
        </xsl:when>
      </xsl:choose>
    </select>
  </xsl:template>
      
  <!-- ====================================================================== -->
  <!-- Search Bar                                                             -->
  <!-- ====================================================================== -->
  
  <xsl:template name="searchBar">
    <xsl:if test="docHit">
      <xsl:comment>BEGIN SEARCH BAR</xsl:comment> 
      <div class="search-bar-outer-txt">
        <div class="search-bar-inner-left">
          <form class="search-form" method="get" action="{$xtfURL}{$crossqueryPath}">
            <span class="form-element">Sort by:</span>
            <xsl:call-template name="sort.options"/>
            <xsl:call-template name="hidden.query">
              <xsl:with-param name="queryString" select="$queryString"/>
            </xsl:call-template>
            <span class="form-element">&#160;<input type="submit" value="Go!"/></span>
          </form>
        </div>   
        <div class="search-bar-inner-right">
          <span class="pagenumber-links">
            <xsl:call-template name="pages"/>
          </span>
        </div>
      </div>
      <xsl:comment>END SEARCH BAR</xsl:comment>
    </xsl:if>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- OAC Help                                                               -->
  <!-- ====================================================================== -->

  <xsl:template name="oac-help">
    <table border="0" width="100%">
      <tr>
        <td>
          <p class="directions">Helpful hints to improve your results: <ul>
            <span class="help"> Try simple and direct words (example: if you 
              want to see pictures of squirrels use &quot;squirrel&quot; and 
              not &quot;rodent&quot;) <br/>If you want more results, try a 
                broader word (example:try &quot;animal&quot; not &quot;squirrel&quot;)
                <br/></span></ul></p>
        </td>
      </tr>
    </table>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Format Query for Display                                               -->
  <!-- ====================================================================== -->
  <!-- should this go in its own file in xtf-sf common? 		      -->

  <xsl:template name="format-query">

    <xsl:param name="query"/>
    <!-- nowadays, the <query> xml is repeated in the crossQuery results, but the
	 param is kept for backwards compatability 
      -->
    <!-- xsl:copy-of select="query"/ -->
    <xsl:choose>
	<xsl:when test="$keyword">
		<!-- probably very fragile -->
		<xsl:apply-templates select="(query//*[@field != 'relation'])[1]/*" mode="query"/>
		<xsl:choose>
			<!-- if they did not search all fields, tell them which are in the feildList -->
			<xsl:when test="$fieldList">
				in <span class="search-type">
				<xsl:value-of select="replace($fieldList,'\s',', ')"/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				in <span class="search-type"> keywords</span>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="query//*[@field = 'rights']" mode="query"/>
	</xsl:when>
	<xsl:otherwise>
    		<xsl:apply-templates select="query" mode="query"/>
	</xsl:otherwise>
    </xsl:choose>
    

  </xsl:template>

  <xsl:template match="query" mode="query">
	<xsl:apply-templates mode="query"/>
	<!-- xsl:apply-templates mode="leary"/ -->
  </xsl:template>

  <xsl:template match="and | or | exact | near | range | not" mode="query">
	<xsl:if test="preceding-sibling::*[@field != 'relation'][@field != 'rights'][@field != 'type'] and not (@field = 'relation')">
		<xsl:value-of select="name(..)"/><xsl:text> </xsl:text>
	</xsl:if>
	<xsl:if test="not (@field = 'relation')">
		<xsl:apply-templates mode="query"/>
		<xsl:if test="@field">
			in <span class="search-type">
				<xsl:choose>
				  <xsl:when test="@field = 'text'">
					the full text
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:value-of select="@field"/>
				  </xsl:otherwise>
				</xsl:choose>
			</span>
		</xsl:if>
	</xsl:if>
  </xsl:template>

  <xsl:template match="term" mode="query">
	<xsl:if test="preceding-sibling::term and (. != $keyword)">
		<xsl:value-of select="name(..)"/><xsl:text> </xsl:text>
	</xsl:if>
	<span class="search-term"><xsl:value-of select="."/></span>
	<xsl:text> </xsl:text>
  </xsl:template>
 
  <xsl:template match="phrase" mode="query">
	&quot;<span class="search-term"><xsl:value-of select="term"/></span>&quot;
  </xsl:template>

  <xsl:template match="exact" mode="query">
	'<span class="search-term"><xsl:value-of select="term"/></span>'
		<xsl:if test="@field">
			in <span class="search-type"><xsl:value-of select="@field"/></span>
		</xsl:if>
  </xsl:template>

  <xsl:template match="upper" mode="query">
	<xsl:if test="../lower != .">
	- <xsl:apply-templates mode="query"/>
	</xsl:if>
  </xsl:template>

  <xsl:template match="and[@field='type']" mode="query">
  </xsl:template>

</xsl:stylesheet>
