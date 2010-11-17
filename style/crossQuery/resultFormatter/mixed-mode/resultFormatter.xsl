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
	xmlns:session="java:org.cdlib.xtf.xslt.Session"
>
  <xsl:import href="../common/cdlResultFormatterCommon.xsl"/>

  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="../ead/oacDocHit.xsl"/>
<xsl:include href="http://voro.cdlib.org:8081/xslt/institution-ark2url.xsl"/>
  <xsl:param name="brand" select="'oac'"/>
<xsl:param name="browse-ignore" select="'no'"/>
<xsl:param name="this-ignore"/>
<xsl:param name="display-ignore"/>
<xsl:param name="xtfURL" select="replace($root.path, ':[0-9]{4}/xtf/', '/')"/>

  <!-- Query String -->
  <xsl:param name="http.URL"/>
  <xsl:param name="queryString">
    <xsl:value-of select="replace(replace(replace(replace(replace(replace($http.URL, 
                                         '.+\?', ''), 
                                         '[0-9A-Za-z\-]+=&amp;', '&amp;'), 
                                         '&amp;[0-9A-Za-z\-]+=$', '&amp;'), 
                                         '&amp;+', '&amp;'),
					 '&amp;sort=.*$' , ''),
					 '&amp;startDoc=.*$' , '')
			"/>
  </xsl:param> 
  
  <!-- ====================================================================== -->
  <!-- Output Parameters                                                      -->
  <!-- ====================================================================== -->

  <xsl:output method="xhtml" indent="yes" encoding="UTF-8" media-type="text/html" 
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->

  <xsl:param name="css.path" select="concat($xtfURL, 'css/oac/')"/>
  <xsl:param name="oac.server" select="'http://www.oac.cdlib.org/'"/>
    
  <!-- ====================================================================== -->
  <!-- Root Template                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="contains($smode, '-modify')">
        <xsl:apply-templates select="crossQueryResult" mode="results-form"/>
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

<xsl:variable name="modifyString">
        <xsl:choose>
          <xsl:when test="contains($queryString,'smode=')">
                <xsl:value-of select="replace($queryString, '(smode=[A-Za-z0-9]*)', '$1-modify')"/>
          </xsl:when>
          <xsl:otherwise>
                <xsl:value-of select="$queryString"/><xsl:text>&amp;smode=-modify</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
</xsl:variable>

  
    <html xmlns="http://www.w3.org/1999/xhtml">
      
      <head>
        <!-- title>The 1906 San Francisco Earthquake and Fire</title -->
				<title><xsl:value-of select="if ($brand.search.title) then $brand.search.title else 'The 1906 San Francisco Earthquake and Fire'"/></title>
        <xsl:copy-of select="$brand.links"/>
      </head>
        <!-- Store search -->
        <xsl:if test="session:isEnabled()">
          <xsl:value-of select="session:setData('queryURL', concat($xtfURL, $crossqueryPath, '?', $queryString, '&amp;startDoc=', $startDoc))"/>
        </xsl:if>
      <body>
        
        <xsl:apply-templates mode="hack" select="$brand.header"/>

<!-- div class="breadcrumb-img">
<a href="{$oac.server}search.image.html">Images</a> &gt;

<xsl:choose>
<xsl:when test="not ($browse-ignore = 'no')">
        <a href="{$oac.server}browse-images/">Browse</a> &gt;
<a href="{$oac.server}browse-images/{$browse-ignore}.html"><xsl:value-of select="$browse-ignore"/></a> &gt;
<xsl:value-of select="$this-ignore"/>
 </xsl:when>
 <xsl:when test="$relation and docHit/meta/relation-from">
<a href="{substring-before((docHit/meta/relation-from)[1],'|')}">
	<xsl:value-of select="substring-after((docHit/meta/relation-from)[1],'|')"/>
</a>
 </xsl:when>
 <xsl:when test="$relation">
 </xsl:when>
 <xsl:otherwise>Search Results
 </xsl:otherwise>
</xsl:choose>

</div -->

        
        <xsl:comment>BEGIN SEARCH RESULTS</xsl:comment>
        <div class="search-results-outer">
            <h3>
              <xsl:text>Search Results </xsl:text>
            </h3>
          <xsl:if test="$browse-ignore = 'no'">  
          <p>
		<xsl:if test="$keyword or $subject or $coverage or $type">
            <xsl:text>Your search for </xsl:text>
 			<span class="search-term">
				<xsl:choose>
				  <xsl:when test="$keyword">
					<xsl:value-of select="$keyword"/>
				  </xsl:when>
				  <xsl:otherwise>
					<xsl:value-of select="$subject"/>
					<xsl:value-of select="$coverage"/>
					<xsl:value-of select="$type"/>
				  </xsl:otherwise>
				</xsl:choose>
                	</span> 
		</xsl:if>

<!-- xsl:if test="$relation and docHit/meta/relation-from">
	 <xsl:value-of select="substring-after((docHit/meta/relation-from)[1],'|')"/>
</xsl:if -->


            <xsl:text> found </xsl:text>
            <xsl:value-of select="@totalDocs"/>
            <xsl:text> item(s). </xsl:text>
  		<xsl:choose>
                  <xsl:when test="($keyword) and (not(contains($smode, '-modify')))">
                        <a class="top-link" href="{$oac.server}search.image.html">
                                <xsl:text>New Search</xsl:text>
                        </a>
                        <!-- a class="top-link" href="{$xtfURL}{$crossqueryPath}?{$modifyString}">
                                <xsl:text>Modify Search</xsl:text>
                        </a -->
                  </xsl:when>
                </xsl:choose>
          </p>
          </xsl:if> 
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
		<xsl:when test="$rmode = 'grid'">
                        <xsl:for-each select="docHit[position() mod 5 = 1]">
                           <tr><td>
<xsl:apply-templates select=". | following-sibling::docHit[position() &lt; 5]" mode="grid"/>
                           </td></tr>
                        </xsl:for-each>
                </xsl:when>
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
  <!-- Results Template                                                       -->
  <!-- ====================================================================== -->

  <xsl:template match="crossQueryResult" mode="results-form">
  
    <html xmlns="http://www.w3.org/1999/xhtml">
      
      <head>
        <title>OAC Images: Search Results</title>
        <xsl:copy-of select="$brand.links"/>
      </head>
      
      <body>
        
        <xsl:apply-templates mode="hack" select="$brand.header"/>

<div class="breadcrumb-img">
<a href="{$oac.server}search.image.html">Images</a> &gt;

<xsl:choose>
<xsl:when test="not ($browse-ignore = 'no')">
        <a href="{$oac.server}browse-images/">Browse</a> &gt;
<a href="{$oac.server}browse-images/{$browse-ignore}.html"><xsl:value-of select="$browse-ignore"/></a> &gt;
<xsl:value-of select="$this-ignore"/>
 </xsl:when>
 <xsl:when test="$relation and docHit/meta/relation-from">
<a href="{substring-before((docHit/meta/relation-from)[1],'|')}">
	<xsl:value-of select="substring-after((docHit/meta/relation-from)[1],'|')"/>
</a>
 </xsl:when>
 <xsl:when test="$relation">
 </xsl:when>
 <xsl:otherwise>Search Results
 </xsl:otherwise>
</xsl:choose>

</div>

        
        <xsl:comment>BEGIN SEARCH RESULTS</xsl:comment>
        <div class="search-results-outer">
            <h3>
              <xsl:text>Search Results </xsl:text>
            </h3>
          <xsl:if test="$browse-ignore = 'no'">  
          <form class="search-form" method="get" actions="{$xtfURL}{$crossqueryPath}">
               <input type="hidden" name="brand" value="{$brand}"/>
               <input type="hidden" name="style" value="{$style}"/>
               <input type="hidden" name="type" value="{$type}"/>
               <input type="hidden" name="type-join" value="{$type-join}"/>
		<xsl:if test="$keyword">
            <xsl:text>Your search for </xsl:text>
 			<span class="search-term">
				<input type="text" name="keyword" value="{$keyword}"/>
                	</span>
		</xsl:if>

<xsl:if test="$relation and docHit/meta/relation-from">
	 <xsl:value-of select="substring-after((docHit/meta/relation-from)[1],'|')"/>
</xsl:if>
<xsl:if test="$relation">
	<input type="hidden" name="relation" value="{$relation}"/>
</xsl:if>


            <xsl:text> found </xsl:text>
            <xsl:value-of select="@totalDocs"/>
            <xsl:text> item(s). </xsl:text>
	    <span class="form-element">&#160;<input type="submit" value="Go!"/></span>
          </form>
          </xsl:if> 
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
		<xsl:when test="$rmode = 'grid'">
                        <xsl:for-each select="docHit[position() mod 5 = 1]">
                           <tr><td>
<xsl:apply-templates select=". | following-sibling::docHit[position() &lt; 5]" mode="grid"/>
                           </td></tr>
                        </xsl:for-each>
                </xsl:when>
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
  <!-- Brand hacking template                                                 -->
  <!-- ====================================================================== -->

<xsl:template match="@href[contains(.,'search.findingaid.html')][parent::area][$brand='oac']" mode="hack">
        <xsl:attribute name="href">
                <xsl:value-of select="$oac.server"/>
                <xsl:text>search.image.html</xsl:text>
        </xsl:attribute>
</xsl:template>

<xsl:template match="node() | @*" mode="hack">
         <xsl:copy>
              <xsl:apply-templates select="node() | @*" mode="hack"/>
         </xsl:copy>
</xsl:template>

  
  <!-- ====================================================================== -->
  <!-- Form Template                                                          -->
  <!-- ====================================================================== -->

  <xsl:template match="crossQueryResult" mode="form">  
      
    <html xmlns="http://www.w3.org/1999/xhtml">
      
      <head>
        <title>OAC Images: Search Results</title>
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
      <div class="search-bar-outer-img" xmlns="http://www.w3.org/1999/xhtml">
        <div class="search-bar-inner-left">
          <form class="search-form" method="get" action="{$xtfURL}{$crossqueryPath}">
            <span class="form-element">Sort by:</span>
            <xsl:call-template name="sort.options"/>
            <xsl:call-template name="hidden.query">
              <xsl:with-param name="queryString" select="$queryString"/>
            </xsl:call-template>
            <xsl:if test="$browse-ignore and $this-ignore">
              <input type="hidden" name="browse-ignore" value="{$browse-ignore}"/>
              <input type="hidden" name="this-ignore" value="{$this-ignore}"/>
            </xsl:if>
            <span class="form-element">&#160;<input type="submit" value="Go!"/></span>
          </form>
        </div>   
        <div class="search-bar-inner-right">
          <span class="pagenumber-links">
            <xsl:call-template name="pages">
	    </xsl:call-template>
          </span>
        </div>
      </div>
      <xsl:comment>END SEARCH BAR</xsl:comment>
    </xsl:if>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- EQF custom result formatter templates				      -->
  <!-- ====================================================================== -->

  <xsl:template name="docHit-div">
    <xsl:variable name="fullark" select="meta/identifier[1]"/> 
    <xsl:choose>
      <xsl:when test="$display-ignore = 'long'">
<strong>Title: </strong>
	<xsl:apply-templates mode="res" select="meta/title"/>
<xsl:if test="meta/creator"><strong>Creator: </strong></xsl:if>
	<xsl:apply-templates mode="res" select="meta/creator"/>
<xsl:if test="meta/date"><strong>Date: </strong></xsl:if>
	<xsl:apply-templates mode="res" select="meta/date[1]"/>
<div><strong>Subject/Genre: </strong></div>
<div class="eqf-inner-res-div">
	<xsl:apply-templates mode="res" select="meta/type[position()=last()]"/>
	<xsl:apply-templates mode="res" select="meta/subject"/>
	<xsl:apply-templates mode="res" select="meta/coverage"/>
</div>
<xsl:if test="meta/description">
	<div><strong>Notes: </strong>
	<xsl:apply-templates mode="res" select="meta/description"/>
	</div>
</xsl:if>
<xsl:if test="meta/description"></xsl:if>
<xsl:if test="meta/identifier[3]">
	<div><strong>Filename: </strong>
	<xsl:apply-templates mode="res" select="meta/identifier[3]"/>
	</div>
</xsl:if>
<xsl:if test="meta/identifier[2]"><div><strong>Local ID: </strong>
	<xsl:apply-templates mode="res" select="meta/identifier[2]"/></div></xsl:if>
<div><strong>Repository Name: </strong>
	<xsl:apply-templates mode="res" select="meta/publisher"/>
</div>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates mode="res" select="meta/title"/>
	<xsl:apply-templates mode="res" select="meta/creator"/>
	<xsl:apply-templates mode="res" select="meta/date[1]"/>
		<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
	<xsl:apply-templates mode="res" select="meta/type[position()=last()]"/>
	<xsl:apply-templates mode="res" select="meta/subject"/>
	<xsl:apply-templates mode="res" select="meta/coverage"/>
		<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
	<xsl:apply-templates mode="res" select="meta/identifier[2]"/>
		<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
	<xsl:apply-templates mode="res" select="meta/publisher"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="res-long" match="title">
<div>
	<strong>Title: </strong>
	<xsl:apply-templates mode="res" select="."/>
</div>
  </xsl:template>

  <xsl:template mode="res-long" match="creator">
<div>	
	<strong>Creator: </strong>
	<xsl:apply-templates mode="res" select="."/>
</div>
  </xsl:template>

  <xsl:template mode="res" match="title| creator| date| description| identifier| publisher">
<div>
	<xsl:value-of select="."/>
</div>
  </xsl:template>
  <xsl:template mode="res" match="title[1]">
    <xsl:variable name="fullark" select="../identifier[1]"/> 
<div>
	<a>
            <xsl:attribute name="href">
              <xsl:call-template name="dynaxml.url">
                <xsl:with-param name="fullark" select="$fullark"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </a>
</div>
  </xsl:template>
  <xsl:template mode="res" match="subject[@q='series'] | 
	subject[text()='The 1906 San Francisco Earthquake and Fire Digital Collection'] 
	| type[text()='still image']
"><!-- remove these -->
</xsl:template>


  <xsl:template mode="res" match="subject | type | coverage">
	
<!-- a href="{$xtfURL}{$crossqueryPath}?brand={$brand}&amp;style={$style}&amp;relation={$relation}&amp;subject={.}&amp;subject-join=exact" -->
<div>
<a href="{$xtfURL}{$crossqueryPath}?brand={$brand}&amp;style={$style}&amp;relation={$relation}&amp;{name(.)}=&quot;{.}&quot;">
            <xsl:value-of select="."/>
        </a>
</div>
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
              not &quot;rodent&quot;) 
								<br/>If you want more results, try a 
                broader word (example:try &quot;animal&quot; not &quot;squirrel&quot;)
                <br/></span></ul></p>
        </td>
      </tr>
    </table>
  </xsl:template>

<!-- should be in oacDocHit!!! -->
<!-- this can't *really* need to be here, but they say this
	can't be don't in css??? --> 
  <xsl:template match="docHit">

    <tr class="search-row">
          <td class="search-results-number">
                <xsl:call-template name="docHit-number"/>
          </td>
          <td class="search-results-thumbnail" align="center" valign="top">
                <xsl:call-template name="docHit-thumbnail"/>
          </td>
          <td class="search-results-text">
                <div class="search-results-text-inner">
                        <xsl:call-template name="docHit-div"/>
                </div>
          </td>
    </tr>
  </xsl:template>

  <xsl:template name="docHit-thumbnail">
  <xsl:choose>
    <xsl:when test="contains(meta/type[1],'image') or contains(meta/type[1],'Image') or meta/type[1]='cartographic' or meta/type[1] = 'mixed material' or meta/type[1] = 'facsimile text' or meta/type[1] = 'mixed+material' ">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="dynaxml.url">
              <xsl:with-param name="fullark" select="meta/identifier[1]"/>
            </xsl:call-template>
          </xsl:attribute>
<img src="{replace(meta/identifier[1],'http://ark.cdlib.org/','/')}/thumbnail" border="0"/>
        </a>
    </xsl:when>
    <xsl:when test="meta/type[1] = 'text'">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="dynaxml.url">
              <xsl:with-param name="fullark" select="meta/identifier[1]"/>
            </xsl:call-template>
          </xsl:attribute>
<img src="http://bancroft.berkeley.edu/collections/earthquakeandfire/images/icon_text.gif" border="0"/>
        </a>
    </xsl:when>
    <xsl:otherwise>&#160;</xsl:otherwise>
  </xsl:choose>
  </xsl:template>

  
</xsl:stylesheet>
