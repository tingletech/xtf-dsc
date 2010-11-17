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

  <xsl:import href="../common/cdlResultFormatterCommon.xsl"/>
  <xsl:import href="oacDocHit.xsl"/>
<xsl:param name="brand" select="'oac'"/>
<xsl:param name="xtfURL" select="replace($root.path, ':[0-9]{4}/xtf/', '/')"/>
<xsl:variable name="grandparent">
	<xsl:if test="starts-with($relation, 'ark:/')">
		<xsl:call-template name="institution-ark2parent">
			<xsl:with-param name="ark" select="$relation"/>
		</xsl:call-template>
	</xsl:if>
</xsl:variable>
<xsl:variable name="parentLabel">
	<xsl:call-template name="institution-ark2label">
		<xsl:with-param name="ark" select="$relation"/>
	</xsl:call-template>
</xsl:variable>
<xsl:variable name="grandparentLabel">
	<xsl:call-template name="institution-ark2label">
	  	   <xsl:with-param name="ark" select="$grandparent"/>
	</xsl:call-template>
</xsl:variable>

  
  <!-- ====================================================================== -->
  <!-- Output Parameters                                                      -->
  <!-- ====================================================================== -->

  <xsl:output method="xhtml" indent="yes" encoding="UTF-8" media-type="text/html" 
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->

  <xsl:param name="oac.server" select="'http://www.oac.cdlib.org/'"/>
    
  <!-- ====================================================================== -->
  <!-- Root Template                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template match="/">
    <xsl:choose>
      <!-- xsl:when test="contains($smode, '-modify')">
        <xsl:apply-templates select="crossQueryResult" mode="results-form"/>
      </xsl:when -->      
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
	<xsl:choose>
	  <xsl:when test="starts-with($relation, 'ark:/')">
		<title>OAC: 
		   <xsl:if test="not(normalize-space($grandparentLabel) eq '')">
			<xsl:value-of select="$grandparentLabel"/>:
		   </xsl:if>
			<xsl:value-of select="$parentLabel"/>: Search Results
		</title>
	  </xsl:when>
	  <xsl:otherwise>
        	<title>OAC Archival Collections: Search Results</title>
	  </xsl:otherwise>
	</xsl:choose>
        <xsl:copy-of select="$brand.links"/>
      </head>
      
      <body>
        
        <xsl:copy-of select="$brand.header"/>

<table cellspacing="0" class="maintable" width="100%" cellpadding="0" border="0">
<tr>
            <td class="findingheaderback" width="20"><img alt="" src="http://www.oac.cdlib.org/images/spacer.gif" width="20" height="1" border="0" /></td>
            <td class="findingheaderback" width="730" align="left"><a href="{$oac.server}search.findingaid.html">Finding Aids</a> &gt; 
		<xsl:choose>
		   <xsl:when test="starts-with($relation, 'ark:/')">
		   	<xsl:if test="not(normalize-space($grandparentLabel) eq '')">
		         <a href="{$oac.server}institutions/{$grandparent}">
			  <xsl:value-of select="$grandparentLabel"/>
			 </a>
			  <xsl:text> &gt; </xsl:text>
			</xsl:if>
		        <a href="{$oac.server}institutions/{$relation}">
			  <xsl:value-of select="$parentLabel"/>
			</a>
			  <xsl:text> &gt; Search Results</xsl:text>
		   </xsl:when>
		   <xsl:otherwise>
			Search Results
		   </xsl:otherwise>
		</xsl:choose>
            </td>
         </tr>
      </table>

        <xsl:comment>BEGIN SEARCH RESULTS</xsl:comment>
        <div class="search-results-outer">

		<xsl:choose>
		   <xsl:when test="$title-ignore = 'only'">
            <h3>
		   	<xsl:if test="not(normalize-space($grandparentLabel) eq '')">
			  <xsl:value-of select="$grandparentLabel"/>
			  <xsl:text> &gt; </xsl:text>
			</xsl:if>
			  <xsl:value-of select="$parentLabel"/>
            </h3>
		   </xsl:when>
		   <xsl:otherwise>
			<h3>Search Results</h3>
            
          <p>
            <xsl:text>Your search for </xsl:text>
            <!-- xsl:call-template name="format-query">
              <xsl:with-param name="query" select="$query"/>
            </xsl:call-template -->

		<span class="search-term">
		<xsl:value-of select="$text"/>
		</span>
		in
		<span class="search-type">
		<xsl:choose>
			<xsl:when test="$sectionType='eadarchdesc'">
			Collection description
			</xsl:when>
			<xsl:when test="$sectionType='eaddsc'">
			Collection inventory
			</xsl:when>
			<xsl:when test="$sectionType='eadtitle'">
			Collection title
			</xsl:when>
			<xsl:when test="$sectionType='unitid'">
			Call number
			</xsl:when>
		<xsl:otherwise>Entire Finding Aid</xsl:otherwise>
		</xsl:choose>
		</span>

		<xsl:if test="starts-with($relation, 'ark:/')">
		at 
			<xsl:value-of select="$parentLabel"/>
			<xsl:if test="$grandparent">,
				<xsl:call-template name="institution-ark2label">
			  	   <xsl:with-param name="ark" select="$grandparent"/>
				</xsl:call-template>
				<xsl:value-of select="grandparentLabel"/>
			</xsl:if>
		</xsl:if>

            <xsl:text> found </xsl:text>
            <xsl:value-of select="@totalDocs"/>
            <xsl:text> item(s). </xsl:text>
            <xsl:choose>
              <xsl:when test="($text or 
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
                $keyword) and (not(contains($smode, '-modify')))">
                <a class="top-link" href="{$oac.server}search.findingaid.html">
                  <xsl:text>New Search</xsl:text>
                </a>
                <!-- a class="top-link" href="{$xtfURL}{$crossqueryPath}?{$modifyString}">
                      <xsl:text>Modify Search</xsl:text>
                    </a -->
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>&#160;</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </p>
		   </xsl:otherwise>
		</xsl:choose>
          
          <div class="number-items">
<xsl:call-template name="page-summary">
    <xsl:with-param name="object-type" select="'items'"/>
 </xsl:call-template>
          </div>
          
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
                  <xsl:apply-templates select="docHit" mode="grid"/>
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

        <!-- Store search -->
        <xsl:if test="session:isEnabled()">
          <xsl:value-of select="session:setData('queryURL', concat($xtfURL, $crossqueryPath, '?', $queryString, '&amp;startDoc=', $startDoc))"/>
        </xsl:if>

        
      </body>
    </html>
    
  </xsl:template>

  
  <!-- ====================================================================== -->
  <!-- Results/form Template                                                  -->
  <!-- ====================================================================== -->

  <!-- ====================================================================== -->
  <!-- Search Options (Overides Common Version)                               -->
  <!-- ====================================================================== -->

  <xsl:template name="sort.options">
    <select size="1" name="sort">
      <xsl:choose>
        <xsl:when test="$sort = ''">
          <option value="" selected="selected">Relevance</option>
          <option value="title">Collection Title</option>
          <option value="publisher">Contributing Institution</option>
          <option value="year">Collection Dates</option>
        </xsl:when>
        <xsl:when test="$sort = 'title'">
          <option value="">Relevance</option>
          <option value="title" selected="selected">Collection Title</option>
          <option value="publisher">Contributing Institution</option>
          <option value="year">Collection Dates</option>
        </xsl:when>
        <xsl:when test="$sort = 'publisher'">
          <option value="">Relevance</option>
          <option value="title">Collection Title</option>
          <option value="publisher" selected="selected">Contributing Institution</option>
          <option value="year">Collection Dates</option>
        </xsl:when>
        <xsl:when test="$sort = 'year'">
          <option value="">Relevance</option>
          <option value="title">Collection Title</option>
          <option value="publisher">Contributing Institution</option>
          <option value="year" selected="selected">Collection Dates</option>
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
      <div class="search-bar-outer-ead">
        <div class="search-bar-inner-left">
	 <xsl:if test="not($title-ignore = 'only')">
          <form class="search-form" method="get" action="{$xtfURL}{$crossqueryPath}" xmlns="http://www.w3.org/1999/xhtml"> 
            <span class="form-element">Sort by:</span>
            <xsl:call-template name="sort.options"/>
            <xsl:call-template name="hidden.query">
              <xsl:with-param name="queryString" select="$queryString"/>
            </xsl:call-template>
            <span class="form-element">&#160;<input type="submit" value="Go!"/></span>
          </form>
         </xsl:if>
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
  
</xsl:stylesheet>
