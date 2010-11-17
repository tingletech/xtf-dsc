<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:editURL="http://cdlib.org/xtf/editURL"
	exclude-result-prefixes="#all"
	xmlns:tmpl="xslt://template">

<!-- DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd" -->
<xsl:import href="../common/editURL.xsl"/>
<xsl:include href="../../../common/SSI.xsl"/>
<xsl:include href="../../../common/online-items-graphic-element.xsl"/>

  <xsl:output method="xhtml"
    indent="yes"
	      encoding="UTF-8" media-type="text/html; charset=UTF-8" 
        omit-xml-declaration="yes"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>



<xsl:param name="sort"/>
<xsl:param name="style" select="'oac4'"/>
<!--	xmlns:editURL="http://cdlib.org/xtf/editURL" -->
<xsl:param name="http.URL"/>
<xsl:param name="queryString" select="editURL:remove(editURL:remove(editURL:remove(
				substring-after($http.URL,'?'),'page'),'x'),'y')"/>

<!-- xsl:param name="queryString" select="editURL:remove(editURL:set(substring-after($http.URL,'?'),'style','oac4'),'page')"/ -->
<xsl:variable name="queryURL">
	<xsl:text>/search?</xsl:text>
	<xsl:value-of select="$queryString"/>
</xsl:variable>
<xsl:param name="query"/>
<xsl:param name="page" select="1"/>
<xsl:param name="keyword"/>
<xsl:param name="idT"/>
<xsl:param name="rmode"/>
<xsl:variable name="pageXML" select="/"/>
<xsl:param name="group" select="if ($rmode = 'oac' or  $style='oac-img' or $style='oac-tei') then 'Items' else ('Collections')"/>
<xsl:variable name="beforeGroup" select="if (substring-before($group,'::')) 
		then substring-before($group,'::') else $group"/>
<xsl:variable name="afterGroup" select="if (substring-before($group,'::')) 
		then substring-after($group,'::') else $group"/>

<xsl:param name="sR"/><!-- testing param for search results mode -->
<xsl:param name="fI"/><!-- testing param for institution facet -->
<xsl:param name="fD"/><!-- testing param for date facet -->

<xsl:param name="onlineItems"/>
<xsl:param name="decade"/>
<xsl:param name="institution"/>
<xsl:param name="production"/>
<xsl:param name="relation"/>

<xsl:variable name="layoutFile">
        <xsl:value-of select="$layoutBase"/>
        <xsl:text>/layouts/results-template.xhtml</xsl:text>
</xsl:variable>

<xsl:variable name="sectionCollectionFile">
       	<xsl:value-of select="$layoutBase"/>
       	<xsl:text>/sections/result-sections.xhtml</xsl:text>
</xsl:variable>

<xsl:variable name="sectionItemFile">
       	<xsl:value-of select="$layoutBase"/>
       	<xsl:text>/sections/result-item.xhtml</xsl:text>
</xsl:variable>

<xsl:variable name="sectionOfflineFile">
       	<xsl:value-of select="$layoutBase"/>
       	<xsl:text>/sections/result-offline.xhtml</xsl:text>
</xsl:variable>

<xsl:variable name="layout" select="document($layoutFile)"/>
<xsl:variable name="section-collection" select="document($sectionCollectionFile)"/>
<xsl:variable name="section-item" select="document($sectionItemFile)"/>
<xsl:variable name="section-offline" select="document($sectionOfflineFile)"/>

<!-- xsl:variable name="layout" select="document('tab-template.xhtml')"/ -->



<xsl:template match="/">
	<xsl:choose>
		<xsl:when test="$style='oac4L'">
<div>hello!!!</div>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="($layout)//*[local-name()='html']"/>
		</xsl:otherwise>
	</xsl:choose>
        <xsl:comment>
        url: <xsl:value-of select="$http.URL"/>
        xslt: <xsl:value-of select="static-base-uri()"/>
	layoutFile: <xsl:value-of select="$layoutFile"/>
        </xsl:comment>
</xsl:template>

  <!-- default match identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

<xsl:template match="*[@tmpl:href='RawXml']">
  <xsl:element name="{name()}">
		<xsl:for-each select="@*">
			<xsl:choose>
				<xsl:when test="local-name()='href'">
					<xsl:attribute name="href">
<xsl:text>/search?</xsl:text>
<xsl:value-of select="editURL:set(substring-after($http.URL,'?'),'raw','1')"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy copy-namespaces="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:apply-templates/>
	</xsl:element>
</xsl:template>

<xsl:template name="hiddenInputTestFlags">
	<xsl:if test="$pageXML/crossQueryResult/parameters/param[@name='sR']">
		<input type="hidden" name="sR" value="{$pageXML/crossQueryResult/parameters/param[@name='sR']/@value}"/>
	</xsl:if>
	<xsl:if test="$pageXML/crossQueryResult/parameters/param[@name='fI']">
		<input type="hidden" name="fI" value="{$pageXML/crossQueryResult/parameters/param[@name='fI']/@value}"/>
	</xsl:if>
	<xsl:if test="$pageXML/crossQueryResult/parameters/param[@name='fD']">
		<input type="hidden" name="fD" value="{$pageXML/crossQueryResult/parameters/param[@name='fD']/@value}"/>
	</xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:insert='ModifySearchForm']"><!-- <form -->
  <xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
		<xsl:attribute name="action">/search</xsl:attribute>
<table>
<tr>
<td><input name="query" value="{$query}" type="text" class="text-field" size="30" maxlength="80"/></td>

<td><input type="image" src="/images/buttons/go.gif" class="search-button" value="search" alt="Go" title="Go" /></td>

</tr>
</table>
		<!-- xsl:call-template name="hiddenInputTestFlags"/ -->
		<xsl:copy-of select="editURL:toHidden(editURL:remove($queryString,'query'))"/>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='title']">
  <xsl:element name="{name()}">
	<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@class='facet-results-right']">
  <xsl:element name="{name()}">
	<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<xsl:if test="$pageXML/crossQueryResult/query/and/and[starts-with(@field, 'facet-')] 
			or $pageXML/crossQueryResult/parameters/param[@name='relation']">
		<div class="subheading">Limited to:</div>
		<xsl:apply-templates
			select="$pageXML/crossQueryResult/parameters"
			mode="oac3Facets"/>
		<xsl:apply-templates 
			select="$pageXML/crossQueryResult/query/and/and[starts-with(@field, 'facet-')]"
			mode="onFacets"/>
		<xsl:if test="$relation ne ''">
		<xsl:apply-templates 
			select="$pageXML/crossQueryResult/query/and/and/and[@field='subject']
			        | $pageXML/crossQueryResult/query/and/and/and[@field='coverage']"
			mode="onFacets"/>
		</xsl:if>
	</xsl:if>
  </xsl:element>
</xsl:template>

<xsl:template match="parameters" mode="oac3Facets">
<xsl:choose>
   	<xsl:when test="param[@name='relation']">
	<div class="column">							
		<div class="facet">							
			<div class="left">
<xsl:value-of select="if ($pageXML/crossQueryResult/facet//group/docHit/meta/facet-collection-title[1]) 
then (($pageXML/crossQueryResult/facet//group/docHit/meta/facet-collection-title)[1]) 
else (param[@name='relation']/@value)"/> 
			</div>
			<div class="right">
			<a href="/search?{editURL:remove($queryString, 'relation')}">
			<img class="close-window-icon" 
		src="/images/buttons/close_window.gif" width="10" height="10" 
		alt="Close window" title="Close window" />
			</a>
			</div> 
			<br clear="all" />						
		</div>
	</div>
	</xsl:when>
	<xsl:otherwise/>
</xsl:choose>
</xsl:template>

<xsl:template match="and" mode="onFacets">
	<div class="column">							
		<div class="facet">							
			<div class="left">
				<xsl:value-of select="."/>
			</div>
			<div class="right">
			<a href="/search?{editURL:remove(editURL:remove($queryString, replace(@field, 'facet-','')),@field)}">
			<img class="close-window-icon" 
		src="/images/buttons/close_window.gif" width="10" height="10" 
		alt="Close window" title="Close window" />
			</a>
			</div> 
			<br clear="all" />						
		</div>
	</div>
</xsl:template>

<!-- xsl:template match="and[@field='facet-institution']" mode="onFacets">
	<div class="column">							
		<div class="facet">							
			<div class="left">
				<xsl:value-of select="."/>
			</div>
			<div class="right">
			<a href="/search?{editURL:remove($queryString, replace(@field, 'facet-', ''))}">
			<img class="close-window-icon" 
		src="/images/buttons/close_window.gif" width="10" height="10" 
		alt="Close window" title="Close window" />
			</a>
			</div> 
			<br clear="all" />						
		</div>
	</div>
</xsl:template -->

<xsl:template match="and[@field='facet-onlineItems']" mode="onFacets">
	<div class="column">							
		<div class="facet">							
			<div class="left">
				<xsl:call-template name="online-items-graphic-element"/>
			</div>
			<div class="right">
			<a href="/search?{editURL:remove($queryString, replace(@field, 'facet-', ''))}">
			<img class="close-window-icon" 
		src="/images/buttons/close_window.gif" width="10" height="10" 
		alt="Close window" title="Close window" />
			</a>
			</div> 
			<br clear="all" />						
		</div>
	</div>
</xsl:template>


<xsl:template match="*[@tmpl:insert='NumberOfResults']">
  <xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<xsl:variable name="thisFacetGroup" select="$pageXML/crossQueryResult/facet//group[docHit]"/>
	<xsl:variable name="startDoc" select="$thisFacetGroup/@startDoc"/>
	<xsl:variable name="endDoc" select="$thisFacetGroup/@endDoc"/>
	<xsl:variable name="totalDocs" select="$thisFacetGroup/@totalDocs"/>
	<xsl:value-of select="format-number($startDoc,'###,###')"/>
	<xsl:text>-</xsl:text>
	<xsl:value-of select="format-number($endDoc,'###,###')"/>
	<xsl:text> of </xsl:text>
	<xsl:value-of select="format-number($totalDocs,'###,###')"/>
	<xsl:text> results</xsl:text>
<!-- (facet/group[@value=$group]) -->
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='ResultsPageIndicator']">
  <xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
<form action="/search" id="results-page"><span class="caption">Results page: </span>
	<xsl:copy-of copy-namespaces="no" select="editURL:toHidden($queryString)"/>
	<xsl:choose>
		<xsl:when test="number($page) = 1"><span>|&lt;&lt;</span> <span>Previous</span></xsl:when>
		<xsl:otherwise>
			<a>
				<xsl:call-template name="pageLink">
					<xsl:with-param name="page">1</xsl:with-param>
				</xsl:call-template>
				<xsl:text>|&lt;&lt;</xsl:text>
			</a>
			<xsl:text> </xsl:text>
			<a>
				<xsl:call-template name="pageLink">
					<xsl:with-param name="page" select="number($page) - 1"/>
				</xsl:call-template>
				<xsl:text>Previous</xsl:text>
			</a>
		</xsl:otherwise>
	</xsl:choose>
<xsl:variable 
	name="lastPage" 
	select="if 
		($pageXML/crossQueryResult/facet//group[docHit]/@totalDocs 
			and $pageXML/crossQueryResult/facet//group[docHit]/@totalDocs &gt; 0)
		then xs:integer(ceiling(number($pageXML/crossQueryResult/facet//group[docHit]/@totalDocs) div 20))
		else 1"/>

<select name="page" onchange="this.form.submit();">
	<xsl:for-each select="1 to $lastPage">
		<option>
			<xsl:if test="number($page) = number(.)">
				<xsl:attribute name="selected"><xsl:text>selected</xsl:text></xsl:attribute>
			</xsl:if>
			<xsl:value-of select="."/>
		</option>
	</xsl:for-each>
</select>
        <input type="submit" value="go" class="go-hide"/>
	<xsl:choose>
		<xsl:when test="number($page) = number($lastPage)">
			<span>Next</span> <span>>>|</span>
		</xsl:when>
		<xsl:otherwise>
			<a>
				<xsl:call-template name="pageLink">
					<xsl:with-param name="page" select="number($page) + 1"/>
				</xsl:call-template>
				<xsl:text>Next</xsl:text>
			</a>
			<xsl:text> </xsl:text>
			<a>
				<xsl:call-template name="pageLink">
					<xsl:with-param name="page" select="$lastPage"/>
				</xsl:call-template>
				<xsl:text>&gt;&gt;|</xsl:text>
			</a>
		</xsl:otherwise>
	</xsl:choose>
</form>
  </xsl:element>
</xsl:template>

<xsl:template name="pageLink">
	<xsl:param name="page"/>
	<xsl:attribute name="href">
		<xsl:text>/search?</xsl:text>
		<xsl:value-of select="editURL:set($queryString,'page',$page)"/>
	</xsl:attribute>
</xsl:template>

<xsl:template match="*[@tmpl:insert='SortResults']">
  <xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<form action="/search" id="sort-order">Sort 
	<xsl:copy-of copy-namespaces="no" select="editURL:toHidden(editURL:remove($queryString,'sort'))"/>
	<select name="sort" onchange="this.form.submit();">
		<option>Relevance</option>
		<option>
			<xsl:if test="lower-case($sort) ='title'">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>
			<xsl:text>Title</xsl:text>
		</option>
	</select>
        <input type="submit" value="go" class="go-hide"/>
	</form>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='results-legend']">
 <xsl:if test="$group = 'Items'">
  <xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<xsl:apply-templates/>
  </xsl:element>
 </xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:insert='Tabs']">
<xsl:comment> *[@tmpl:insert='Tabs'] </xsl:comment>
<xsl:if test="$pageXML/crossQueryResult/@totalDocs != 0"><!-- not zero results -->
  <xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>

              <ul>
		<xsl:apply-templates select="$pageXML/crossQueryResult/facet[@field='oac4-tab']/group" mode="tabsL1"/>
              </ul>
           <!-- div class="bd">
              <ul>
		<xsl:apply-templates select="$pageXML/crossQueryResult/facet[@field='oac4-tab']/group[@value=$beforeGroup]/group" mode="tabsL2"/>
              </ul>
           </div --> 
	</xsl:element>
</xsl:if>
</xsl:template>
<xsl:template match="div[@class='row2']">
	<xsl:choose>
		<xsl:when test="$pageXML/crossQueryResult/@totalDocs = 0">
<div class="row2-zero-results">
<div class="zero-results">There are no results for this query. Please modify your search and try again.</div>
</div>
		</xsl:when>
		<xsl:otherwise>
  		<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]">
			<xsl:copy copy-namespaces="no"/>
		</xsl:for-each>
		<xsl:apply-templates/>
		</xsl:element>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template match="group" mode="tabsL1"><!-- Tabs -->
<xsl:variable name="icon">
	<xsl:if test="@value='Items'"><xsl:text> </xsl:text></xsl:if>
</xsl:variable>
	<xsl:choose>
		<xsl:when test="(@value = $group)">
			<li class="on"><xsl:copy-of select="$icon"/><xsl:value-of select="@value"/> (<xsl:value-of select="@totalDocs"/>)</li>
		</xsl:when>
		<xsl:when test="@totalDocs = 0">
			<li><a><xsl:value-of select="@value"/> (0)</a></li>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="link">
				<xsl:value-of select="editURL:set($queryURL,'group', @value)"/>
				<xsl:if test="$onlineItems and $onlineItems != ''">
					<xsl:text>;onlineItems=Items online</xsl:text>
				</xsl:if>
				<xsl:if test="$decade and $decade != ''">
					<xsl:text>;decade=</xsl:text>
					<xsl:value-of select="$decade"/>
				</xsl:if>
				<xsl:if test="$institution and $institution != ''">
					<xsl:text>;institution=</xsl:text>
					<xsl:value-of select="$institution"/>
				</xsl:if>
			</xsl:variable>
			
			<li><a href="{$link}"><xsl:copy-of select="$icon"/><xsl:value-of select="@value"/> (<xsl:value-of select="@totalDocs"/>)</a></li>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

				<!-- xsl:if test="position() = last()"><xsl:attribute name="class">last</xsl:attribute></xsl:if -->
<xsl:template match="group" mode="tabsL2">
	<xsl:choose>
		<xsl:when test="@value = $afterGroup">
			<li class="on"><strong><xsl:value-of select="@value"/> (<xsl:value-of select="@totalDocs"/>)</strong></li>
		</xsl:when>
		<xsl:otherwise>
			<li><a href="{$queryURL}&amp;group={$beforeGroup}::{@value}"><xsl:value-of select="@value"/> (<xsl:value-of select="@totalDocs"/>)</a></li>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- search results (template call) -->
<xsl:template match="tmpl:searchResults">
	<div>
	<xsl:choose>
		<xsl:when test="$sR='b'">
			<xsl:apply-templates 
				select="$pageXML/crossQueryResult/facet//docHit" 
				mode="searchResultsAlternate" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates 
				select="$pageXML/crossQueryResult/facet//docHit" 
				mode="searchResults"/>
		</xsl:otherwise>
	</xsl:choose>
	</div>
</xsl:template>

<!-- xsl:template match="tmpl:Head">
	<xsl:copy-of select="($section)//*[local-name()='html']/*[local-name()='head']/*[local-name()='style']"/>
</xsl:template -->

<!-- search results docHit -->

<xsl:template 
	match="docHit[./meta/oac4-tab='Collections::marc']" 
	mode="searchResults">
	<xsl:apply-templates 
		select="($section-collection)//*[local-name()='html']/*[local-name()='body']//*[@tmpl:process='collection-result']" 
		mode="searchResultsItemMARC">
		<xsl:with-param name="docHit" select="."/>
	</xsl:apply-templates>
	<!-- xsl:apply-templates select="meta/identifier[starts-with(.,'http://')]" mode="marc-link"/ -->
</xsl:template>

<xsl:template 
	match="docHit[./meta/oac4-tab='Items::offline']" 
	mode="searchResults">
	<xsl:apply-templates 
		select="($section-offline)//*[local-name()='html']/*[local-name()='body']//*[@tmpl:process='collection-result']" 
		mode="searchResultsItemMARC">
		<xsl:with-param name="docHit" select="."/>
	</xsl:apply-templates>
	<!-- xsl:apply-templates select="meta/identifier[starts-with(.,'http://')]" mode="marc-link"/ -->
</xsl:template>

<!-- xsl:template match="identifier" mode="marc-link">
	<a href="{.}"><xsl:value-of select="."/></a>
</xsl:template -->

<xsl:template 
	match="docHit[./meta/oac4-tab='Collections::ead'] | docHit[./meta/oac4-tab='Items::image']" 
	mode="searchResults">
<xsl:comment><xsl:value-of select="@rank"/></xsl:comment>
	<xsl:apply-templates 
		select="($section-collection)/*[local-name()='html']/*[local-name()='body']//*[@tmpl:process='collection-result']" 
		mode="searchResultsItemEAD">
		<xsl:with-param name="docHit" select="."/>
	</xsl:apply-templates><!-- 
					tmpl:process="collection-result"
					tmpl:insert="result-number"
					tmpl:insert="result-link"
					tmpl:insert="result-institution"
					tmpl:insert="result-description"
					tmpl:insert="result-online"
					tmpl:insert="collection-items" 
					tmpl:insert="result-terms" 
				-->
</xsl:template>

<xsl:template 
	match="docHit[./meta/oac4-tab='Items::image'] | docHit[./meta/oac4-tab='Items::text']"
	mode="searchResults">
<xsl:comment><xsl:value-of select="@rank"/></xsl:comment>
	<xsl:apply-templates 
		select="($section-item)/*[local-name()='html']/*[local-name()='body']//*[@tmpl:process='collection-result']" 
		mode="searchResultsItemMETS">
		<xsl:with-param name="docHit" select="."/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="a[@class='more']" mode="searchResultsItemEAD searchResultsItemMARC searchResultsItemMETS"/>

<xsl:template match="*[@tmpl:process='collection-result']" mode="searchResultsItemMARC searchResultsItemMETS">
	<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]">
			<xsl:copy copy-namespaces="no"/>
		</xsl:for-each>
		<xsl:apply-templates mode="searchResultsItemMARC">
			<xsl:with-param name="docHit" select="$docHit"/>
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:process='collection-result']" mode="searchResultsItemEAD">
	<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]">
			<xsl:copy copy-namespaces="no"/>
		</xsl:for-each>
		<xsl:apply-templates mode="searchResultsItemEAD">
			<xsl:with-param name="docHit" select="$docHit"/>
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:process='collection-result']" mode="searchResultsItemMETS">
	<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]">
			<xsl:copy copy-namespaces="no"/>
		</xsl:for-each>
		<xsl:apply-templates mode="searchResultsItemMETS">
			<xsl:with-param name="docHit" select="$docHit"/>
		</xsl:apply-templates>
	</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='result-number']" mode="searchResultsItemEAD searchResultsItemMARC searchResultsItemMETS">
	<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]">
			<xsl:choose>
				<xsl:when test="local-name(.)='href'"/>
				<xsl:otherwise><xsl:copy copy-namespaces="no"/></xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:value-of select="format-number($docHit[1]/@rank,'###,###')"/>
		<xsl:text>. </xsl:text>
	</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='result-link']" mode="searchResultsItemMARC">
	<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]">
			<xsl:choose>
				<xsl:when test="local-name(.)='href'"/>
				<xsl:otherwise><xsl:copy copy-namespaces="no"/></xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:attribute name="href">
			<xsl:value-of select="$queryURL"/>
			<xsl:text>;idT=</xsl:text>
			<xsl:value-of select="$docHit/meta/idT[1]"/>
		</xsl:attribute>
		<xsl:value-of select="$docHit/meta/title[1]" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="$docHit/meta/date[1]"/>
	</xsl:element>
</xsl:template>



<xsl:template match="*[@tmpl:insert='result-link']" mode="searchResultsItemEAD">
	<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]">
			<xsl:copy copy-namespaces="no"/>
		</xsl:for-each>
		<xsl:attribute name="href">
			<xsl:text>/findaid/ark:/13030/</xsl:text>
			<xsl:value-of select="replace($docHit/meta/identifier[1],'http://ark.cdlib.org/ark:/13030/','')"/>
			<xsl:text>?query=</xsl:text>
			<xsl:value-of select="$query"/>
		</xsl:attribute>
		<xsl:value-of select="$docHit/meta/title[1]" />
                <xsl:text> </xsl:text>
                <xsl:value-of select="$docHit/meta/date[1]"/>
	</xsl:element>
</xsl:template>


<xsl:template match="*[@tmpl:insert='result-link']" mode="searchResultsItemMETS">
	<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]">
			<xsl:copy copy-namespaces="no"/>
		</xsl:for-each>
		<xsl:attribute name="href">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="replace($docHit/meta/identifier[1],'http://ark.cdlib.org/','')"/>
			<xsl:text>/?brand=oac4</xsl:text>
		</xsl:attribute>
		<xsl:value-of select="$docHit/meta/title[1]" />
	</xsl:element>
</xsl:template>

<!-- removed from design -->
<xsl:template match="*[@tmpl:insert='result-icon']" mode="searchResultsItemMARC searchResultsItemMETS"/>

<xsl:template match="*[@tmpl:insert='result-thumbnail']" mode="searchResultsItemMARC">
	<xsl:param name="docHit"/>
	<a>
                <xsl:attribute name="href">
                        <xsl:value-of select="$queryURL"/>
                        <xsl:text>;idT=</xsl:text>
                        <xsl:value-of select="$docHit/meta/idT[1]"/>
                </xsl:attribute>
		<img src="/images/icons/car-icon-lg.gif" 
			alt="Go to institution for this item" 
			title="Go to institution for this item" />
	</a>
</xsl:template>

<xsl:template match="*[@tmpl:insert='result-thumbnail']" mode="searchResultsItemMETS">
	<xsl:param name="docHit"/>
	<xsl:param name="thumbnail-link">
		<xsl:choose>
		  <xsl:when test="$docHit/meta/thumbnail">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="replace($docHit/meta/identifier[1],'http://ark.cdlib.org/','')"/>
			<xsl:text>/thumbnail</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
			<xsl:text>/images/icons/page-icon-lg.gif</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="thumbnail-bs">
		<xsl:choose>
		  <xsl:when test="$docHit/meta/thumbnail">
			<xsl:text>Thumbnail image of item</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
			<xsl:text>Online text available for this item</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<a>
                <xsl:attribute name="href">
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="replace($docHit/meta/identifier[1],'http://ark.cdlib.org/','')"/>
                        <xsl:text>/?brand=oac4</xsl:text>
                </xsl:attribute>
	
		<img>
			<xsl:attribute name="src" select="$thumbnail-link"/>
			<xsl:attribute name="width" select="'50'"/>
			<xsl:attribute name="height" select="'50'"/>
			<xsl:attribute name="alt" select="$thumbnail-bs"/>
			<xsl:attribute name="title" select="$thumbnail-bs"/>
		</img>
	</a>
</xsl:template>

<xsl:template match="*[@tmpl:insert='result-institution']" mode="searchResultsItemEAD searchResultsItemMARC searchResultsItemMETS">
	<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
		<xsl:value-of select="if ($docHit/meta/facet-institution[1]) 
			then $docHit/meta/facet-institution[1] 
			else $docHit/meta/publisher[1]"/>
	</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='result-author']" mode="searchResultsItemMARC">
	<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
		<xsl:value-of select="$docHit/meta/creator[1]"/>
	</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='result-description']" mode="searchResultsItemEAD searchResultsItemMARC searchResultsItemMETS">
	<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>

 <xsl:value-of select="tokenize($docHit/meta/description[1],'\s+')[position() &lt; 41]"/>
	<xsl:variable name="getId">
		<xsl:choose>
		  <xsl:when test="$docHit/meta/idT">
			<xsl:value-of select="$docHit/meta/idT"/>
		  </xsl:when>
		  <xsl:otherwise>
			<xsl:value-of select="replace($docHit/meta/identifier[1],'http://ark.cdlib.org/','')"/>
		  </xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
                <xsl:if test="tokenize($docHit/meta/description[1],'\s+')[41]">
                        <span class="read-more" onclick="getDescription('{$getId}',this)">...</span>
			<!-- a class="more" href="">Read More</a -->
                </xsl:if>


	</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='result-date']" mode="searchResultsItemEAD searchResultsItemMARC searchResultsItemMETS">
<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
		<xsl:value-of select="$docHit/meta/date[1]"/>
	</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='result-from']" mode="searchResultsItemEAD searchResultsItemMARC searchResultsItemMETS">
<xsl:param name="docHit"/>
<xsl:variable name="relation-from-url" select="substring-before((($docHit)/meta/relation-from)[1],'|')"/>
<xsl:variable name="relation-from-text" select="substring-after((($docHit)/meta/relation-from)[1],'|')"/>

	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
 <a href="{if 
		( not($production = 'production') ) 
	then 	
		replace($relation-from-url,'^http://.*oac\.cdlib\.org','') 
	else 	
		$relation-from-url}
	">
                        <xsl:value-of select="$relation-from-text"/>
                </a>
	</xsl:element>
</xsl:template>

<xsl:template match="*[@class='result-description-more']" mode="searchResultsItemEAD searchResultsItemMARC searchResultsItemMETS">
	<xsl:param name="docHit"/>
	<xsl:element name="{name()}">
		<xsl:for-each select="@*[not(namespace-uri(.)='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
		<xsl:if test="string-length($docHit/meta/description[1])&gt; 200"><a href="">Read More</a></xsl:if>
	</xsl:element>
</xsl:template>


<xsl:template match="*[@tmpl:insert='result-online']" mode="searchResultsItemMARC"/>

<xsl:template match="*[@tmpl:insert='result-online']" mode="searchResultsItemEAD">
<!-- collection-item -->
	<xsl:param name="docHit"/>
        <xsl:variable name="href">
                        <xsl:text>/findaid/ark:/13030/</xsl:text>
                        <xsl:value-of select="replace($docHit/meta/identifier[1],'http://ark.cdlib.org/ark:/13030/','')"/>
                        <xsl:text>?query=</xsl:text>
                        <xsl:value-of select="$query"/>
                        <xsl:text>;doc.view=items</xsl:text>
        </xsl:variable>

	<xsl:if test="$docHit/meta/extent">

<div class="online">

                              <div class="left">
                              <img height="20" width="41" class="eye-icon" src="/images/icons/sq-eye_icon.gif" alt="Online items available" title="Online items available"/>
                              </div>
                  
                                <div class="right">          
             <span class="online-items">Online items available</span>
                          		</div>

                           </div>


			<!-- xsl:call-template name="online-items-graphic-element">
				<xsl:with-param name="class" select="'online'"/>
				<xsl:with-param name="element" select="name()"/>
			</xsl:call-template -->
	</xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:insert='result-terms']" mode="searchResultsItemEAD">
	<xsl:param name="docHit"/>
	<xsl:if test="$docHit/@totalHits &gt; 0">
	<div><span class="label"><xsl:value-of select="$docHit/@totalHits"/> search terms found:</span></div>
	<xsl:apply-templates select="$docHit/snippet" mode="snippet"/>
	</xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:insert='result-terms']" mode="searchResultsItemMARC">
	<xsl:param name="docHit"/>
	<xsl:if test="$docHit/@totalHits &gt; 0">
	<div><span class="label"><xsl:value-of select="$docHit/@totalHits"/> search terms found:</span></div>
	<xsl:apply-templates select="$docHit//snippet" mode="snippet"/>
	</xsl:if>
</xsl:template>

<xsl:template match="docHit[./meta/oac4-tab='Collections::ead']|docHit[./meta/oac4-tab='Collections::marc']|docHit[./meta/oac4-tab='item::image']" mode="searchResultsAlternate">
	<div class="collection-result">
		<div class="title">
		<!-- span class="docHitRank"><xsl:value-of select="@rank"/></span --> 
		<xsl:variable name="href">
                        <xsl:text>/view?docId=</xsl:text>
                        <xsl:value-of select="replace(meta/identifier[1],'http://ark.cdlib.org/ark:/13030/','')"/>
                        <xsl:text>;developer=</xsl:text>
                        <xsl:value-of select="$developer"/>
                        <xsl:text>;query=</xsl:text>
                        <xsl:value-of select="$query"/>
                        <xsl:text>;style=oac4</xsl:text>
		</xsl:variable>

		<a href="{$href}">
		<span style="font-weight: normal;">
		<xsl:apply-templates select="meta/title[1]" mode="snippetAlt"/>
		<xsl:text> </xsl:text>
		<span style="font-size: smaller;">
		<xsl:value-of select="meta/date[1]"/>
		</span></span>
		</a>
		</div>
		<!-- xsl:apply-templates select="meta" mode="searchResults"/ -->
	<div style="text-indent: 0em; margin-left:0em;">
		<xsl:choose>
	<xsl:when test="meta/oac4-tab='Collections::marc'">
		<xsl:apply-templates select=".//snippet" mode="snippetSpan"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:apply-templates select="snippet" mode="snippetSpan"/>
	</xsl:otherwise>
		</xsl:choose>
	<!-- a href="#" onclick="return false;">[<xsl:value-of select="@totalHits"/>
	<xsl:text> term</xsl:text><xsl:if test="number(@totalHits) &gt; 1">s</xsl:if> in context]</a -->
	</div>
	<div style="text-indent: 0em; margin-left:0em; color:#00443E; font-size:85%;">
		<xsl:value-of select="meta/facet-institution[1]"/>
	</div>
<xsl:if test="(meta/description[@q='abstract'][text()] 
                and meta/description[@q='abstract'] != '...'
							) 
					or meta/subject 
					or meta/identifier[2]">
	<!-- div class="docHitDetails">
		<a href="#" onclick="return false;" rel="nofollow">[more details]</a>
			<span class="docHitDetailsHide">
			<xsl:if test="meta/description[@q='abstract'][text()] 
								and meta/description[@q='abstract'] != '...'">
				<xsl:apply-templates select="meta/description[@q='abstract']" mode="docHitDetails"/>
			</xsl:if>
			<xsl:if test="meta/subject">
				<p><b>Subjects:</b><xsl:text> </xsl:text>
				<xsl:apply-templates select="meta/subject" mode="docHitDetails"/>
				</p>
			</xsl:if>
			<xsl:if test="meta/identifier[2]">
				<p><b>Collection Identifier:</b><xsl:text> </xsl:text>
				<xsl:apply-templates select="meta/identifier[2]" mode="docHitDetails"/>
				</p>
			</xsl:if>
		</span>
	</div -->
</xsl:if>
	<div>
		<xsl:if test="meta/extent">
			<img alt="" width="84" border="0" height="16" src="http://oac.cdlib.org/images/onlineitemsbutton.gif" /><img alt="" width="17" border="0" height="14" src="http://oac.cdlib.org/images/image_icon.gif" />
			<xsl:text> </xsl:text>
			<xsl:value-of select="meta/extent[1]"/>
		</xsl:if>
	</div>
	</div>
</xsl:template>

<xsl:template match="description" mode="docHitDetails">
<p><b>Collection Description:</b><xsl:text> </xsl:text>
<xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="identifier" mode="docHitDetails">
<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="subject" mode="docHitDetails">
<xsl:value-of select="."/>
<xsl:text> | </xsl:text>
</xsl:template>

<xsl:template match="snippet" mode="snippet">
	<div>
	<xsl:text>...</xsl:text>
	<xsl:apply-templates mode="snippet"/>
	<xsl:text>...</xsl:text>
	</div>
</xsl:template>

<xsl:template match="snippet" mode="snippetSpan">
	<xsl:text>...</xsl:text>
	<xsl:apply-templates mode="snippet"/>
	<xsl:text>...</xsl:text>
</xsl:template>

<xsl:template match="snippet" mode="snippetAlt">
	<xsl:apply-templates mode="snippet"/>
</xsl:template>

<xsl:template match="hit" mode="snippetAlt">
	<span style="background: rgb(188, 202, 203);"><xsl:value-of select="."/></span>
</xsl:template>

<xsl:template match="hit" mode="snippet">
	<b><xsl:value-of select="."/></b>
</xsl:template>

<!-- search results metadata -->
<xsl:template match="meta" mode="searchResults">
	<h2><xsl:value-of select="title"/></h2>
	<xsl:apply-templates select="creator[text()], subject[text()], description[@q='abstract'][text()], 
					publisher[text()], date[text()], extent[text()], format[text()], identifier[text()]" mode="searchResults"/>
</xsl:template>

<!-- xsl:template match="creator[1]|subject[1]|description[1]|publisher[1]|data[1]|format[1]|identifier[1]" mode="searchResults">
	<div>
	<xsl:variable name="name" select="name()"/>
	<h3><xsl:value-of select="$name"/> (<xsl:value-of select="1 + count(following-sibling::*[name() = $name])"/>)</h3>
		<xsl:for-each select="., following-sibling::*[name() = $name]">
			<xsl:call-template name="metaValue">
				<xsl:with-param name="metaValue" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</div>
</xsl:template -->

<xsl:template match="*" mode="searchResults">
<div><xsl:value-of select="."/></div>
</xsl:template>

<xsl:template name="metaValue">
	<xsl:param name="metaValue"/>
	<p><xsl:value-of select="$metaValue"/></p>
</xsl:template>


<!-- search limits -->
<xsl:template match="tmpl:searchLimits">
<div class="searchLimits">
	<h1>Limit to:</h1>
	<div id="searchLimits">
<!-- a href="{replace($queryURL,'style=oac4','style=oac4L')}">search limits</a -->
	</div>
</div>
</xsl:template>

<xsl:template match="facet" mode="searchLimits">
	<xsl:if test="@totalDocs &gt; 0">
	<div>
		<h2><xsl:value-of select="replace(@field,'^facet-','')"/> ( groups:<xsl:value-of select="@totalGroups"/> documents: <xsl:value-of select="@totalDocs"/> )</h2>
		<xsl:apply-templates mode="searchLimits"/>
	</div>
	</xsl:if>
</xsl:template>

<xsl:template match="group" mode="searchLimits">
	<div><h3><xsl:value-of select="@value"/> (<xsl:value-of select="@totalDocs"/>)</h3>
		<xsl:apply-templates mode="searchLimits"/>
	</div>
</xsl:template>

<xsl:template match="tmpl:spellingSuggestion">
	<xsl:apply-templates select="$pageXML/crossQueryResult/spelling" mode="spelling"/>
</xsl:template>

<xsl:template match="tmpl:FootScript">
<xsl:if test="$pageXML/crossQueryResult/@totalDocs != 0">
	<script type="text/javascript" src="/yui/build/yahoo/yahoo-min.js"></script>
	<script type="text/javascript" src="/yui/build/dom/dom-min.js"></script>
	<script type="text/javascript" src="/yui/build/event/event-min.js"></script>
	<script type="text/javascript" src="/yui/build/connection/connection-min.js"></script>
	<script type="text/javascript" src="/yui/build/dragdrop/dragdrop-min.js"></script>
	<script type="text/javascript" src="/yui/build/container/container-min.js"></script>
	<script type="text/javascript" src="/js/results.js"></script>
	<xsl:variable name="link" select="substring-after($http.URL,'?')"></xsl:variable>
	<xsl:variable name="apos">'</xsl:variable>
<!-- '/js/facet-iframe.html?<xsl:value-of select="replace(replace($queryString,';','&amp;'),'&#59;','%27')"/>&amp;facetcomplete=' + facet; -->
	<script type="text/javascript" encoding="UTF-8">
<xsl:comment>
var div = document.getElementById('searchLimits');

var successHandler = function(o) {
	div.innerHTML = o.responseText;
}

var failureHandler = function(o) {
	div.innerHTML = o.status + " " + o.statusText;
}

var sUrl=encodeURI("/search?<xsl:value-of select="replace( 
					if ( contains($link , 'style=oac4') )
					then replace($link,'style=oac4','style=oac4L') 
					else if ( contains($link, 'style=oac-img') )
					then replace($link,'style=oac-img','style=oac4L&amp;group=Items')
					else if ( contains($link, 'style=oac-tei') )
					then replace($link,'style=oac-tei','style=oac4L&amp;group=Items')
					else concat($link,';style=oac4L')
					,'&quot;','\\&quot;')"/>");
YAHOO.util.Connect.asyncRequest('GET', sUrl, { success : successHandler, failure : failureHandler });

// called by the async page
var replaceGP = function(o) {
	var changeMe = o.parentNode.parentNode;
	var changeMeParent = changeMe.parentNode;
	// var hideSpot = getElementsByClassName("hide", "div", changeMe);
	// hideSpot.innerHTML = changeMe.innerHTML
	var responseText;
	var callback = {
		success: function(o) {
			var newDiv = document.createElement('div');
			newDiv.innerHTML = o.responseText;
			changeMeParent.replaceChild(newDiv,changeMe);
		},
		failure: failureHandler
	};
	YAHOO.util.Connect.asyncRequest('GET', o.href, callback);
	// console.log(responseText);
        return false;
}
var facetBrowserPanel = [];

var facetBrowser = function(facet) {
	var frame = document.createElement('iframe');
	frame.src = 
encodeURI('/js/facet-iframe.html?<xsl:value-of select="replace(replace($queryString,';','&amp;'),$apos,'%27')"/>&amp;facetcomplete=' + facet);
	frame.width = "500";
	frame.height = "500";

	// console.log(frame.src);
	if (!facetBrowserPanel[facet]){
		facetBrowserPanel[facet] = new YAHOO.widget.Panel("facetPanel"+facet, 
			{ modal:true, 
			  fixedcenter:true, 
			  constraintoviewport: true
			} ); 
		var facetLabel = (facet=="coverage") ? "place" : facet;
		facetBrowserPanel[facet].setHeader("limit results to "+facetLabel);
		facetBrowserPanel[facet].setBody(frame);
		facetBrowserPanel[facet].render(document.body);
	} else {
		facetBrowserPanel[facet].show();
	}
}

</xsl:comment>
	</script>
</xsl:if>
</xsl:template>

<xsl:template match="spelling" mode="spelling">
<xsl:variable name="suggestQ" select="editURL:spellingFix($query,suggestion)"/>
<div class="spelling-suggestion">Did you mean: 
<a href="/search?{editURL:set(substring-after($http.URL,'?'), 'query', $suggestQ)}"><xsl:value-of select="$suggestQ"/></a>
</div>
</xsl:template>

  <!-- default match identity transform -->
  <xsl:template match="@*|node()" mode="searchResultsItemEAD" priority="-1">
	<xsl:param name="docHit"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()" mode="searchResultsItemEAD">
		<xsl:with-param name="docHit" select="$docHit"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="spellingSuggest">
  </xsl:template>

  <xsl:template match="@*|node()" mode="searchResultsItemMARC" priority="-1">
	<xsl:param name="docHit"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()" mode="searchResultsItemMARC">
		<xsl:with-param name="docHit" select="$docHit"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" mode="searchResultsItemMETS" priority="-1">
	<xsl:param name="docHit"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()" mode="searchResultsItemMETS">
		<xsl:with-param name="docHit" select="$docHit"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:function name="editURL:spellingFix">
	<xsl:param name="query"/>
	<xsl:param name="suggestion"/>
	<xsl:variable name="thisTerm" select="($suggestion)[1]"/>
	<xsl:variable name="nextTerm" select="($suggestion)[position()&gt;1]"/>
	<xsl:variable name="changedQuery" select="replace($query, $thisTerm/@originalTerm, $thisTerm/@suggestedTerm)"/>
	<xsl:choose>
		<xsl:when test="boolean($nextTerm)">
			<xsl:value-of select="editURL:spellingFix($changedQuery,$nextTerm)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$changedQuery"/>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:function>

</xsl:stylesheet>
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
