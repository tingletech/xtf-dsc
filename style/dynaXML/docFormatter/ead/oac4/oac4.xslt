<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:saxon="http://icl.com/saxon" 
  xmlns:editURL="http://cdlib.org/xtf/editURL"
  xmlns:xtf="http://cdlib.org/xtf"
  xmlns:oac="http://oac.cdlib.org"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  extension-element-prefixes="saxon" 
  xmlns:tmpl="xslt://template"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:strip-space elements="*"/>
  <xsl:include href="table.html.xsl"/>
  <xsl:include href="ead.html.xsl"/>
  <xsl:include href="search.xsl"/>
    
<!-- DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" -->

  <xsl:output method="xhtml"
    indent="yes"
    encoding="utf-8"
    media-type="text/html; charset=UTF-8" 
	omit-xml-declaration="yes"
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
  
  <xsl:include href="../../common/docFormatterCommon.xsl"/>
  <xsl:include href="parameter.xsl"/>
  <xsl:include href="page.xsl"/>
  <xsl:include href="../../../../crossQuery/resultFormatter/common/editURL.xsl"/>
  <xsl:include href="../../../../common/SSI.xsl"/>
  <xsl:include href="../../../../common/scaleImage.xsl"/>
  <xsl:include href="../../../../common/online-items-graphic-element.xsl"/>
  <xsl:include href="supplied-labels-headings.xsl"/>
  
  <xsl:key name="hit-num-dynamic" match="xtf:hit" use="@hitNum"/>

  <!-- refLink -->
  <xsl:key name="not.archdesc" match="*[@id][not(ancestor-or-self::archdesc)]" use="@id"/>
  <xsl:key name="archdesc" match="archdesc[@id]|archdesc//*[@id][not(ancestor-or-self::dsc)]" use="@id"/>
  <xsl:key name="dsc" match="dsc[@id]|dsc//*[@id]" use="@id"/>

  <xsl:key name="c0x" match="archdesc/*|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12" use="@id"/>
  <xsl:key name="hasContent" match="*[@id][.//dao|.//daogrp]" use="@id"/>
  <xsl:key 
	name="dscPositions" 
	match="dscgrp|dsc|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12"
  >
        <xsl:value-of select="@C-ORDER"/>
  </xsl:key>

<xsl:key name="daos" match="*[did/daogrp] | *[did/dao] | *[did][dao] | *[did][daogrp]" >
        <xsl:value-of select="@ORDER"/>
</xsl:key>


 <xsl:param name="http.URL"/> 

<xsl:param name="view"/>
<xsl:param name="style"/>

<xsl:param name="item.position">1</xsl:param>
<xsl:param name="dsc.position">1</xsl:param>
<xsl:param name="s"/>

<xsl:variable name="http.query" select="substring-after($http.URL,'?')"/>

<!--         .label { font-weight:bold; width: 10% !important; }     
        .item { padding: .5em; } -->

<xsl:param name="dao-count">
<xsl:choose>
  <xsl:when test="$page/ead/archdesc/@daoCount">
        <xsl:value-of select="$page/ead/archdesc/@daoCount"/>
  </xsl:when>
  <xsl:otherwise>
        <xsl:value-of select="count($page//dao | $page//daogrp) + number(1)"/>
  </xsl:otherwise>
</xsl:choose>
</xsl:param>

<xsl:variable name="layoutFile">
	<xsl:value-of select="$layoutBase"/>
	<xsl:text>/layouts/collection-guide-template.xhtml</xsl:text>
</xsl:variable>
<xsl:variable name="overviewFile">
	<xsl:value-of select="$layoutBase"/>
	<xsl:text>/sections/collection-overview.xhtml</xsl:text>
</xsl:variable>

<xsl:variable name="layoutEntireFile">
	<xsl:value-of select="$layoutBase"/>
	<xsl:text>/layouts/full-collection.xhtml</xsl:text>
</xsl:variable>


<xsl:variable name="layout" select="document($layoutFile)"/>
<xsl:variable name="layoutFull" select="document($layoutEntireFile)"/>
<xsl:variable name="overview" select="document($overviewFile)"/>
<!-- xsl:variable name="layout" select="document('oac4.xhtml')"/ -->
<xsl:variable name="page" select="/"/>

<xsl:template match="/">
	<xsl:choose>

		<xsl:when test="$doc.view='entire_text'">
 <xsl:apply-templates select="($layoutFull)//*[local-name()='html']"/>
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
  <!-- xsl:template match="@*[not(namespace-uri(.)='http://cdlib.org/xtf')]|node()[not(namespace-uri(.)='xslt://template')]">
	<xsl:copy copy-namespaces="no">
	<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
  </xsl:template -->
  <xsl:template match="*">
	        <xsl:element name="{name(.)}">
              <xsl:for-each select="@*">
                  <xsl:attribute name="{name(.)}">
                      <xsl:value-of select="."/>
                  </xsl:attribute>
              </xsl:for-each>
              <xsl:apply-templates/>
          </xsl:element>
  </xsl:template>

  <xsl:template match="@*[not(namespace-uri(.)='http://cdlib.org/xtf')]|node()" mode="Overview">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*[not(namespace-uri(.)='xslt://template')]|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:variable name="file">
    <xsl:value-of select="ead/eadheader/eadid"/>
  </xsl:variable>


<!-- tmpl: xmlns="xslt://template" -->
<!-- entire_text -->
<xsl:template match="*[@tmpl:insert='full-content']">
	<xsl:element name="{name()}">
        	<xsl:call-template name="copy-attributes">
                	<xsl:with-param name="element" select="."/>
        	</xsl:call-template>

       <!-- div class="collection-admin-view">
                        <xsl:apply-templates select="$page/ead/archdesc/*[not(dsc)]" mode="ead"/>
       </div -->
       <div class="collection-contents">

<xsl:variable name="max-c-order" select="$page/key('dscPositions','1')/@MAX-C-ORDER"/>
<xsl:variable name="pageme">
        <xsl:if test="$max-c-order &gt; number(5000)">
                <xsl:call-template name="pagination">
                        <xsl:with-param name="pageStart" select="number($dsc.position)"/>
                        <xsl:with-param name="pageSize" select="number(5000)"/>
                        <xsl:with-param name="hits" select="$max-c-order"/>
                        <xsl:with-param name="docId" select="$docId"/>
                        <xsl:with-param name="base">
                                <xsl:text>/view?</xsl:text>
				<xsl:value-of select="editURL:remove($http.query,'dsc.position')"/>
                                <xsl:text>;dsc.position=</xsl:text>
                        </xsl:with-param>
                        <xsl:with-param name="mode" select="'dsc'"/>
                </xsl:call-template>
        </xsl:if>
</xsl:variable>
<xsl:copy-of select="$pageme"/>
<xsl:if test="not($dsc.position) or number($dsc.position) = 1">
                <xsl:apply-templates select="$page/ead/eadheader/filedesc" mode="ead"/>
		<hr/>
		<xsl:apply-templates select="$page/ead/frontmatter" mode="ead"/>
		<hr/>
                <xsl:apply-templates select="$page/ead/archdesc" mode="ead"/>
		<hr/>
</xsl:if>
	<xsl:choose>
		<xsl:when test="$max-c-order">
                       <xsl:apply-templates
                                select="for $i in xs:integer($dsc.position)
                                        to (xs:integer($dsc.position)+4999)
                                        return $page/key('dscPositions',$i)"
                                mode="eadFlat"
                        />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="$page/ead/archdesc/dsc" mode="eadStart"/>
		</xsl:otherwise>
	</xsl:choose>

<xsl:copy-of select="$pageme"/>

       </div>

	</xsl:element>
</xsl:template>

<xsl:template match="archdesc" mode="ead-with-headings">
        <div class="collection-admin-view">
        <xsl:apply-templates select="did| accessrestrict| accruals| acqinfo| altformavail| appraisal| arrangement| bibliography| bioghist|
 controlaccess| custodhist| dao| daogrp| descgrp| fileplan| index| note| odd| originalsloc| otherfindaid| phystech| prefercite| processinfo| relatedmaterial| runner| scopecontent| separatedmaterial| userestrict" mode="contents-overview"/>
<hr/>
                <xsl:apply-templates select="did" mode="ead"/>
                <xsl:apply-templates select="
accessrestrict| accruals| acqinfo| altformavail| appraisal| arrangement| bibliography| bioghist| controlaccess| custodhist| dao| daogrp| descgrp| fileplan| index| note| odd| originalsloc| otherfindaid| phystech| prefercite| processinfo| relatedmaterial| runner| scopecontent| separatedmaterial| userestrict" mode="ead"/>
        </div>
</xsl:template>


<xsl:template match="*[@tmpl:linkpattern='comments']">
	<xsl:variable name="ark" select="($page)/ead/eadheader/eadid/@identifier"/>
	<a>
		<xsl:attribute name="href" select="replace(@href,'ARK',$ark)"/>
		<xsl:apply-templates/>
	</a>

</xsl:template>

<!-- no longer used; need to move up in template (really uses class= ) -->
<xsl:template match="*[@tmpl:link='guide-entire']">
                <a href="##">
                        <xsl:apply-templates/>
                </a>
</xsl:template>

<!-- no longer used; need to move up in template (really uses class= ) -->
<xsl:template match="*[@tmpl:link='guide-download']">
                <a href="##">
                        <xsl:apply-templates/>
                </a>
</xsl:template>

<xsl:template match="*[@tmpl:process='collection-search']">
                <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
<input type="hidden" name="docId" value="{$docId}"/>
<input type="hidden" name="developer" value="{$developer}"/>
<input type="hidden" name="style" value="{$style}"/>
<input type="hidden" name="s" value="1"/>
                        <xsl:apply-templates/>
                </xsl:element>
</xsl:template>

<xsl:template match="input[@name='query']">
	<input name="query" value="{$query}">
		<xsl:apply-templates select="@type | @class | @size | @maxlength"/>
	</input>
</xsl:template>

<xsl:template match="input">
	<input>
		<xsl:apply-templates select="@*"/>
	</input>
</xsl:template>

<xsl:template match="@*">
	<xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="*[@class='guide-entire']"><!-- PDF / HTML link -->
  <xsl:element name="{name()}">
    	<xsl:for-each select="@*"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<img height="15" width="15" src="/images/icons/pdf-icon.gif" class="bullet-icon"/>
	<span class="guide-download">
<xsl:choose>
	<xsl:when test="$page/ead/pdf-size">
<xsl:variable name="ark" select="($page)/ead/eadheader/eadid/@identifier"/>
<xsl:variable name="part" select="replace($ark,'ark:/13030/','')"/>
<xsl:variable name="dir" select="substring($part,(string-length($part) - 1),2)"/>
<a href="/data/13030/{$dir}/{$part}/files/{$part}.pdf">PDF</a> (<xsl:value-of select="$page/ead/pdf-size"/>)
	</xsl:when>
	<xsl:otherwise>
	no PDF 
	</xsl:otherwise>
</xsl:choose>
</span>

	<img height="15" width="15" src="/images/icons/web-page-icon.gif" class="bullet-icon"/>
	<xsl:variable name="link">
		<xsl:text>/view?docId=</xsl:text>
		<xsl:value-of select="$docId"/>
		<xsl:if test="$developer != 'local'">
		  <xsl:text>;developer=</xsl:text>
		  <xsl:value-of select="$developer"/>
		</xsl:if>
		<xsl:text>;query=</xsl:text>
		<xsl:value-of select="$query"/>
		<xsl:text>;style=oac4;doc.view=entire_text</xsl:text>
	</xsl:variable>
	<a href="{$link}">HTML</a>
	<xsl:if test="($page)/ead/archdesc/@xtf:hitCount | ($page)/ead/frontmatter/@xtf:hitCount "><!-- need to check the correct sections to add up hits; find first hit/ -->
		<span class="subhit"><a href="{$link}#hitNum{
							if (($page)/ead/frontmatter/@xtf:firstHit)
							then ($page)/ead/frontmatter/@xtf:firstHit
							else ($page)/ead/archdesc/@xtf:firstHit
							     }">
                <xsl:text>[</xsl:text><xsl:value-of select="sum(($page)/ead/archdesc/@xtf:hitCount | ($page)/ead/frontmatter/@xtf:hitCount)"/>
                <xsl:text> hit</xsl:text>
                <xsl:value-of select="if (($page)/ead/@xtf:hitCount &gt; 1) then 's' else ''"/>]
                </a></span>
	</xsl:if>
  </xsl:element>
</xsl:template>

<!-- xsl:template match="*[@class='guide-download']">
  <xsl:element name="{name()}">
    	<xsl:for-each select="@*"><xsl:copy copy-namespaces="no"/></xsl:for-each>
  </xsl:element>
</xsl:template -->

<!-- search inside -->
<xsl:template match="input[@name='servlet'][@value='view']">
  <xsl:element name="{name()}">
    	<xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<xsl:if test="$doc.view!='items'">
		<xsl:attribute name="checked" select="'checked'"/>
	</xsl:if>
  </xsl:element>
</xsl:template>

<xsl:template match="input[@name='servlet'][@value='search']">
  <xsl:element name="{name()}">
    	<xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<xsl:if test="not(($page)/ead/facet-onlineItems='Items online')">
		<xsl:attribute name="disabled" select="'disabled'"/>
	</xsl:if>
	<xsl:if test="$doc.view='items'">
		<xsl:attribute name="checked" select="'checked'"/>
	</xsl:if>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='Title']">
  <xsl:element name="{name()}">
    	<xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<xsl:apply-templates select="$page/ead/eadheader/filedesc/titlestmt/titleproper[1]" mode="ead-no-hit-nav"/>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='title']">
  <xsl:element name="{name()}">
    	<xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<xsl:value-of select="$page/ead/eadheader/filedesc/titlestmt/titleproper[1]"/>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='ColNumber']"><!-- collection-number -->
  <xsl:element name="{name()}">
    	<xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
<xsl:choose>
<xsl:when test="count($page/ead/archdesc/did/repository) = 1">
	<xsl:choose>
	<xsl:when test="$page/ead/archdesc/did/unitid">
	<xsl:apply-templates select="$page/ead/archdesc/did/unitid[1]" mode="collectionId"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:text>Consult repository</xsl:text>
	</xsl:otherwise>
	</xsl:choose>
</xsl:when>
<xsl:otherwise>
	<xsl:text>Various; consult contributing institutions</xsl:text>
</xsl:otherwise>
</xsl:choose>
&#160;
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='Institution']">
  <xsl:element name="{name()}">
    	<xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<xsl:choose>
		<xsl:when test="count($page/ead/archdesc/did/repository) &gt; 1">
<a href="/view?docId={$docId};query={$query};style=oac4;view=admin#oac-multi-institution-ref">See multiple institutions</a>
		</xsl:when>
		<xsl:otherwise>
			<!-- xsl:apply-templates 
				select="$page/ead/archdesc/did/repository" 
				mode="collectionId"/ -->
			<xsl:value-of select="$page/ead/facet-institution"/>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='MainEAD']">
  <xsl:element name="{name()}">
    	<xsl:for-each select="@*[not(namespace-uri()='xslt://template')]"><xsl:copy copy-namespaces="no"/></xsl:for-each>
	<xsl:choose>
		<xsl:when test="$view='dsc'">

<xsl:variable name="max-c-order" select="$page/key('dscPositions','1')/@MAX-C-ORDER"/>
<xsl:variable name="pageme">
	<xsl:if test="$max-c-order &gt; number(2500)">
		<xsl:call-template name="pagination">
			<xsl:with-param name="pageStart" select="number($dsc.position)"/>
			<xsl:with-param name="pageSize" select="number(2500)"/>
			<xsl:with-param name="hits" select="$max-c-order"/>
			<xsl:with-param name="docId" select="$docId"/>
			<xsl:with-param name="base">
				<xsl:text>/view?docId=</xsl:text>
				<xsl:value-of select="$docId"/>
				<xsl:text>&#038;view=dsc&#038;style=oac4&#038;dsc.position=</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="mode" select="'dsc'"/>
		</xsl:call-template>
	</xsl:if>
</xsl:variable>

			<!-- xsl:apply-templates select="$page/ead/archdesc/dsc" mode="eadStart"/ -->
			<!-- if this is long -->
			<xsl:if test="number($dsc.position) &gt; 1">
				<!--    need to check for the odd case that the
					page naturally breaks on an
					hr/seriesTrigger
				-->
				<xsl:if test="not($page/ead/heads/div[number(@C-ORDER) = number($dsc.position)])">
					<xsl:apply-templates 
		select="$page/ead/heads/div[number(@C-ORDER) &lt; number($dsc.position)][position()=last()]"
						mode="pageDscFixup"
					/>
				</xsl:if>
			</xsl:if>
			<xsl:copy-of select="$pageme"/>
  			<xsl:apply-templates 
				select="for $i in xs:integer($dsc.position) 
					to (xs:integer($dsc.position)+2499) 
					return $page/key('dscPositions',$i)" 
				mode="eadFlat"
			/>
			<xsl:copy-of select="$pageme"/>
		</xsl:when>
		<xsl:when test="$view='admin'">
			<div class="collection-admin-view">
			<xsl:apply-templates select="$page/ead/archdesc" mode="ead-with-headings"/> 
			</div>
		</xsl:when>
		<xsl:when test="$doc.view='items'">

			<xsl:variable name="pageme">
        			<xsl:call-template name="pagination">
                			<xsl:with-param name="pageStart" select="number($item.position)"/>
                			<xsl:with-param name="pageSize" select="number(20)"/>
                			<xsl:with-param name="hits" select="number($dao-count)"/>
					<xsl:with-param name="docId" select="$docId"/>
                			<xsl:with-param name="base">
						<xsl:text>/view?docId=</xsl:text>
						<xsl:value-of select="$docId"/>
<xsl:text>&#038;doc.view=items&#038;style=oac4&#038;item.position=</xsl:text>
					</xsl:with-param>
        			</xsl:call-template>
			</xsl:variable>
			<xsl:copy-of select="$pageme"/>
			<div class="collection-admin-view">
  <xsl:apply-templates select="for $i in xs:integer($item.position) to (xs:integer($item.position)+19) return $page/key('daos',$i)" mode="items"/>
			</div>
			<xsl:copy-of select="$pageme"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="$page/ead/archdesc" mode="Overview"/> 
		</xsl:otherwise>
	</xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="*" mode="pageDscFixup">
<div class="cx hr" id="{@cid}"/>
</xsl:template>

<xsl:template match="c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12" mode="eadFlat">
	<xsl:apply-templates select="." mode="ead">
		<xsl:with-param name="flat" select="'flat'"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="dsc|dscgrp" mode="eadFlat">
	<!-- xsl:apply-templates select="*[name()!='c01']" mode="ead"/ -->
</xsl:template>

<xsl:template match="c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12" mode="items">
<xsl:call-template name="series"/>
<div class="collection-result">
<xsl:apply-templates select="did[daogrp or dao] | did[../daogrp or ../dao]" mode="items" />
</div>
</xsl:template>


<xsl:template match="did" mode="items">
<xsl:variable name="baseURL" select="'/'"/>

<!-- xsl:variable name="href" select="if (dao[1]/@href) then dao[1]/@href else (daogrp/@poi)"/ -->

<xsl:variable name="hackedLink" select="if (dao[1]/@href) then
        replace(replace(replace(dao[1]/@href,'http://.*/ark:/', concat($baseURL , 'ark:/') ) ,'/$','') ,'\s$','')
	else (concat('/', daogrp/@poi )) "/>

<xsl:variable name="brandMe">
        <xsl:if test="starts-with(dao[1]/@href,'http://ark.cdlib.org/ark:/')
                     or starts-with(dao[1]/@href,'/ark:/13030/')">
		<xsl:text>yes</xsl:text>
	</xsl:if>
</xsl:variable>


<div class="col-left">
<xsl:choose>
        <xsl:when test="daogrp/@poi">
                <a href="/{daogrp/@poi}/?brand=oac4">
                <img src="/{daogrp/@poi}/thumbnail"/></a>
        </xsl:when>
        <xsl:when test="dao/@poi">
                <!-- a href="{$hackedLink}{$brandCgiQ}" -->
                <a href="/{dao/@poi}/?brand=oac4">
<img src="/{dao/@poi}/thumbnail"/>
                </a>
        </xsl:when>
        <xsl:when test="contains(dao[1]/@href,'/ark:/')">
                <xsl:variable name="poi" select="replace(dao[1]/@href,'^.*ark:/(\d+)/([a-z0-9]+).*$','ark:/$1/$2')"/>
                <a href="/{dao[1]/$poi}/?brand=oac4">
                        <img title="thumbnail" alt="thumbnail" src="/{dao/$poi}/thumbnail"/>
                </a>
	</xsl:when>
        <xsl:when test="dao/@href
                        and
                        dao[1][starts-with(@role,'http://oac.cdlib.org/arcrole/link')]
                        and
                        not ( starts-with(dao[1]/@href,'http://ark.cdlib.org/ark:') )
                        and
                        not ( starts-with(dao[1]/@href,'/ark:/13030/') )
                        or
                         ( ends-with(dao[1]/@content-role,'link/text') )
                ">
                <div>
                <a href="{dao/@href}">
                <xsl:choose>
                <xsl:when test="dao/@title">
                        <xsl:value-of select="dao/@title"/>
                </xsl:when>
                <xsl:when test="ends-with(dao/@content-role,'link/text')">
                        <xsl:text>View text</xsl:text>
                </xsl:when>
                <xsl:otherwise>View items</xsl:otherwise>
                </xsl:choose>
                </a>
                </div>
        </xsl:when>
        <xsl:when test="starts-with(dao[1]/@href,'http://ark.cdlib.org/ark:/')
                     or starts-with(dao[1]/@href,'/ark:/13030/')">
                <a href="{$hackedLink}/?brand=oac4">
                <img src="{$hackedLink}/thumbnail"/></a>
        </xsl:when>
	<xsl:when test="daogrp">
		<xsl:apply-templates select="daogrp" mode="ead-dsc"/>
	</xsl:when>
	<xsl:when test="../dao[@href]">
		<xsl:apply-templates select="../dao" mode="items"/>
	</xsl:when>
        <xsl:otherwise></xsl:otherwise>
</xsl:choose>
</div>
<div class="col-right">
<xsl:if test="dao[1]/@href or daogrp/@poi">
<div class="object-title"><a href="{$hackedLink}{if ($brandMe='yes') then '/?brand=oac4' else ''}"><xsl:value-of select="if (unittitle) then unittitle else (unitid)"/></a></div>
</xsl:if>
</div>
</xsl:template>


  <xsl:template match="dao" mode="items">
<div>
	<a href="{if (contains(@href, '/ark:/')) then ( replace(@href,'^.*ark:/(\d+)/([a-z0-9]+).*$','/ark:/$1/$2/?brand=oac4')) else @href}">
	<xsl:value-of select="if (.//text()) then . else 'view item'"/>
	</a>
</div>
  </xsl:template>


  <xsl:template name="series">

    <xsl:if test="../did/unittitle 
			and not ( preceding-sibling::*[did/dao or did/daogrp ] )
			and not ( preceding-sibling::*[did and dao ] )
			and not ( preceding-sibling::*[did and daogrp ] )
	">
      <xsl:for-each select=".." >
        <xsl:call-template name="series"/>
      </xsl:for-each>
      <xsl:apply-templates select="../did/unittitle" mode="series"/>
    </xsl:if>

  </xsl:template>

  <xsl:template match="unittitle" mode="series">
    <div class="{if (name(../..) = 'c01') then 'series-heading' else 'sub-series-heading'}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>



<xsl:template match="*" mode="stats">
<xsl:value-of select="name()"/>,
</xsl:template>

<xsl:template match="archdesc" mode="Overview">
	<!-- overview-* -->
	<xsl:apply-templates 
		select="$overview/*[local-name()='html']/*[local-name()='body']/*[local-name()='div'][@tmpl:process='collection-overview']" 
		mode="Overview"
	/>
</xsl:template>

<xsl:template match="*[@tmpl:insert='breadcrumbs']">
	<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
<div class="breadwrapper">
<span class="breadcrumbs-item"><a href="/">&gt; Home</a></span>
<xsl:variable name="fi" select="$page/ead/facet-institution[1]"/>
<xsl:choose>
	<xsl:when test="contains($fi,'::')">
		<span class="breadcrumbs-item">
			<a href="/institutions/{replace(substring-before($fi,'::'),'\s','+')}" class="breadcrumbs-link" >
				&gt; <xsl:value-of select="substring-before($fi,'::')"/>
			</a>
		</span>
		<span class="breadcrumbs-item">
			<a href="/institutions/{replace($fi,'\s','+')}" class="breadcrumbs-link" >
				&gt; <xsl:value-of select="substring-after($fi,'::')"/>
			</a>
		</span>
	</xsl:when>
	<xsl:otherwise>
		<span class="breadcrumbs-item">
			<a href="/institutions/{replace($fi,'\s','+')}" class="breadcrumbs-link" >
				&gt; <xsl:value-of select="$fi"/>
			</a>
		</span>
	</xsl:otherwise>
</xsl:choose>
</div>
<a class="a2a_dd" href="http://www.addtoany.com/share_save">
<img src="/default/images/share_save_120_16.gif" width="120" height="16" border="0"
        alt="Share/Save/Bookmark"/></a>
<script type="text/javascript">a2a_onclick = 1;</script>
<script type="text/javascript" src="/default/js/a2a.js"></script>
	</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='permalink']">
	<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
<a href="http://www.oac.cdlib.org/findaid/ark:/13030/{$docId}">
<xsl:text>&#8734; http://www.oac.cdlib.org/findaid/ark:/13030/</xsl:text>
<xsl:value-of select="$docId"/>
</a>
	</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='contents-overview']">
	<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
	<xsl:apply-templates select="$page/ead/archdesc/*[./head][@id]" mode="contents-overview"/>
	</xsl:element>
</xsl:template>

<xsl:template match="dsc" mode="contents-overview">
 <div>
<a href="/view?docId={$docId};query={$query};style=oac4;view=dsc#{@id}">
<xsl:value-of select="head"/></a></div>
</xsl:template>

<xsl:template match="*[@id]" mode="contents-overview">
 <li>
<a href="/view?docId={$docId};query={$query};style=oac4;view=admin#{@id}">
<xsl:value-of select="if (head) then head else if (@label) then @label else (oac:supply-label-heading(.))"/></a>
</li>
</xsl:template>

  <xsl:template match="head">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
	<xsl:if test="$page/ead/@xtf:hitCount">
      <link rel="stylesheet" type="text/css" href="/yui/build/menu/assets/skins/sam/menu.css" />
	</xsl:if>
    </xsl:copy>
  </xsl:template>

<xsl:template match="*[@tmpl:insert='collection-location']">
	<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
	<xsl:variable 
		name="location" 
		select="$page/ead/facet-institution[1]"
	/>
	<img class="car-icon" src="/images/icons/car_icon.gif" width="17" height="13" alt="Collection location" title="Collection location"/>
	<span class="location"><a class="location-link" href="{$page/ead/institution-url}">Contact <xsl:value-of select="$location"/> </a></span>
	</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='collection-items']">
	<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
   <xsl:choose>
	<xsl:when test="($page)/ead/facet-onlineItems='Items online'">

<xsl:variable name="trueArk">
	<xsl:value-of select="replace($page/ead/archdesc/@first-dao-href,'.*relation=(ark:/.*)[;&amp;]*.*$','$1')"/>
</xsl:variable>

<xsl:variable name="link">
        <xsl:choose>
          <xsl:when test="$page/ead/archdesc/did/dao[starts-with(@role,'http://oac.cdlib.org/arcrole/link/search')]">
		<!-- inner choose -->
		<!-- 	need to check this value; if it is a relation= type 
			link; rewrite it - other wise use encoded link -->
		<xsl:choose>
		   <xsl:when test="starts-with($page/ead/archdesc/@first-dao-href,'http://content.cdlib.org/search')">
			<xsl:text>/search?style=attached;relation=</xsl:text>
			<xsl:value-of select="$trueArk"/>
		   </xsl:when>
        	   <xsl:otherwise>
			<xsl:value-of select="$page/ead/archdesc/@first-dao-href"/>
		   </xsl:otherwise>
		</xsl:choose>
          </xsl:when>
          <xsl:otherwise>
		<xsl:text>/view?docId=</xsl:text>
		<xsl:value-of select="$docId"/>
		<xsl:if test="$developer != ''">
		  <xsl:text>;developer=</xsl:text>
		  <xsl:value-of select="$developer"/>
		</xsl:if>
		<xsl:text>;style=oac4;doc.view=items</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
</xsl:variable>

 
<xsl:variable name="onclick">
        <xsl:choose>
          <xsl:when test="$page/ead/archdesc/did/dao[starts-with(@role,'http://oac.cdlib.org/arcrole/link/search')]">
		<xsl:if test="starts-with($page/ead/archdesc/@first-dao-href,'http://content.cdlib.org/search')">return getitems(this.href);</xsl:if>
	  </xsl:when>
	</xsl:choose>
</xsl:variable>
	<xsl:call-template name="online-items-graphic-element">
		<xsl:with-param name="href" select="$link"/>
		<xsl:with-param name="onclick" select="$onclick"/>
	</xsl:call-template>

	</xsl:when>
	<xsl:otherwise>
<img height="13" width="15" title="No online items" alt="No online items" src="/images/icons/no-online-available.gif" class="eye-icon"/>
				<span class="no-online-items">No online items</span>
	</xsl:otherwise>
  </xsl:choose>
</xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:process='overview-description']">

	<xsl:if test="$page/ead/@xtf:hitCount = '0' and $s = '1'">
<div class="zero-results">There are no results for this query. Please modify your search and try again.</div>
	</xsl:if>

	<xsl:if test="
			($page/ead/archdesc/scopecontent//p) 
			or ($page/ead/archdesc/*[not(local-name(.)='dsc')]/abstract)
			or ($page/ead/archdesc/odd[normalize-space(head) eq 'Abstract'])
		">
		<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:insert='overview-description']">
	<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
		<xsl:apply-templates select="
			if ($page/ead/archdesc/*[not(local-name(.)='dsc')]/abstract) 
			then ($page/ead/archdesc/*[not(local-name(.)='dsc')]/abstract)[1] 
			else if (($page/ead/archdesc/scopecontent//p)[1])
			then ($page/ead/archdesc/scopecontent//p)[1]
			else ( ($page/ead/archdesc/odd[normalize-space(head)='Abstract']//p)[1] )
			" 
		mode="ead-overview"/>
<!-- span class="more"><a href="">More...</a></span -->
	</xsl:element>
</xsl:template>

<xsl:template match="*" mode="ead-overview">
<xsl:choose>
	<xsl:when test="@xtf:hitCount">
		<xsl:apply-templates mode="ead-no-hit-nav"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:apply-templates mode="ead"/>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="p" mode="ead-overview">
<xsl:apply-templates mode="ead-overview"/>
</xsl:template>

<xsl:template match="lb" mode="ead-overview">
</xsl:template>

<xsl:template match="head" mode="ead-overview"/>

<xsl:template match="*[@tmpl:process='overview-background']">
	<xsl:if test="($page/ead/archdesc/bioghist//p[text()])">
		<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:insert='overview-background']">
	<xsl:if test="($page/ead/archdesc/bioghist//p[text()])">
		<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
	<xsl:apply-templates select="$page/ead/archdesc/bioghist//p[text()][1]" mode="ead-overview"/>
<!-- span class="more"><a href="">More...</a></span -->
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:process='overview-extent']">
	<xsl:if test="($page/ead/archdesc/did/physdesc[extent[not(@type='dao')]])[1]">
		<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:insert='overview-extent']">
	<xsl:variable name="extent" select="($page/ead/archdesc/did/physdesc[extent[not(@type='dao')]])[1]"/>
	<xsl:if test="$extent">
		<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
				<xsl:apply-templates select="$extent" mode="ead-overview"/>
<!-- span class="more"><a href="">More...</a></span -->
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:process='overview-restrictions']">
        <xsl:if test="($page/ead/archdesc/userestrict) or ($page/ead/archdesc/descgrp/userestrict)">
                <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
                        <xsl:apply-templates/>
                </xsl:element>
        </xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:insert='overview-restrictions']">
	<xsl:variable name="restrict" 
		select="(
			$page/ead/archdesc/userestrict[not(p)] | 
			$page/ead/archdesc/userestrict/p | 
			$page/ead/archdesc/descgrp/userestrict[not(p)] |
			$page/ead/archdesc/descgrp/userestrict/p
		)[1]"/>
	<xsl:if test="$restrict">
		<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
		<xsl:value-of select="$restrict" />
<!-- span class="more"><a href="">More...</a></span -->
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:process='overview-availability']">
        <xsl:if test="($page/ead/archdesc/*[not(local-name(.)='dsc')]/accessrestrict)">
                <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
                        <xsl:apply-templates/>
                </xsl:element>
        </xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:insert='overview-availability']">
	<xsl:variable name="restrict" 
		select="(
			$page/ead/archdesc/*[not(local-name(.)='dsc')]/accessrestrict[not(p)] |
			$page/ead/archdesc/*[not(local-name(.)='dsc')]/accessrestrict/p 
	)[1]"/>
	<xsl:if test="$restrict">
		<xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
			<xsl:value-of select="$restrict"/>
			<!-- span class="more"><a href="">More...</a></span -->
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template match="*[@tmpl:insert='search-hits']">
<xsl:if test="$page/ead/@xtf:hitCount">
  <xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
<div class="number-search-hits yui-skin-sam">
<xsl:text> </xsl:text>
		<xsl:value-of select="$page/ead/archdesc/@xtf:hitCount"/>
		<xsl:text> Search hit</xsl:text>
		<xsl:value-of select="if ($page/ead/archdesc/@xtf:hitCount = 1) then '' else 's'"/>
	</div>
	<div class="clear-search-hits">
		<a href="/view?{editURL:remove(editURL:clean(substring-after($http.URL,'?')),'query')}">
		<xsl:text>Clear search hit</xsl:text>
	<xsl:value-of select="if ($page/ead/archdesc/@xtf:hitCount = 1) then '' else 's'"/>
		</a>
	</div>
  </xsl:element>
</xsl:if>
</xsl:template>

<!-- xsl:template match="*[@tmpl:insert='TableOfContentsHeading']">
  <xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
 	<xsl:if test="$page/ead/archdesc/dsc/*[@id][@level='series' or @level='subseries' or @level='recordgrp' or @level='collection']">
  		<xsl:apply-templates/>
 	</xsl:if>
  </xsl:element>
</xsl:template -->

<xsl:template match="*[@tmpl:insert='CollectionContentsHead']">
  <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
		<!-- xsl:value-of select="."/> <div class="javascript-help-contents"/ -->
		<xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='ViewCollectionGuideHead']">
  <xsl:element name="{name()}">
        <xsl:call-template name="copy-attributes">
                <xsl:with-param name="element" select="."/>
        </xsl:call-template>
		<xsl:value-of select="."/> <div class="javascript-view-help"/>
  </xsl:element>
</xsl:template>

<xsl:template match="*[@tmpl:insert='CollectionContents']">
<ul>
<li>
	<a href="/view?docId={$docId};query={$query};style=oac4">
		<xsl:if test="not($view='dsc') and not($view='admin') and not($doc.view='items')">
			<xsl:attribute name="class" select="'on'"/>
		</xsl:if>
		<xsl:text>Collection Overview</xsl:text>
	</a>
</li>
<li>
	<a href="/view?docId={$docId};query={$query};style=oac4;view=admin">
		<xsl:if test="$view='admin'">
			<xsl:attribute name="class" select="'on'"/>
		</xsl:if>
		<xsl:text>Collection Details</xsl:text>
	</a>
	<!-- test to see if there are any headings? -->

<xsl:variable name="archdescHits" select="number($page/ead/archdesc/@xtf:hitCount)"/>
<xsl:variable name="dscHits" select="sum($page/ead/archdesc/dsc/@xtf:hitCount)"/>

<xsl:variable name="full-overview-hit-link">
	<xsl:choose>
		<xsl:when test="$view='admin'"/>
		<xsl:otherwise>
	<!-- /view?docId={$docId};developer={$developer};query={$query};style=oac4;view=admin" -->
		<xsl:text>/view?docId=</xsl:text>
		<xsl:value-of select="$docId"/>
		<xsl:if test="$developer != 'local'">
		<xsl:text>;developer=</xsl:text>
		<xsl:value-of select="$developer"/>
		</xsl:if>
		<xsl:text>;query=</xsl:text>
		<xsl:value-of select="$query"/>
		<xsl:text>;style=oac4;view=admin</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<!-- some hits are outside of the dsc -->
<xsl:if test="$archdescHits &gt; $dscHits">
	<xsl:variable name="firstHit" select="$page/ead/archdesc/@xtf:firstHit"/>
	<span class="subhit">
	   <a href="{$full-overview-hit-link}#hitNum{$firstHit}">
		<xsl:text>[</xsl:text>
		<xsl:value-of select="$archdescHits - $dscHits"/> 
		<xsl:text> hit</xsl:text>
		<xsl:value-of select="if ($archdescHits - $dscHits = 1) then '' else 's'"/>]
	   </a>
	
	</span>
</xsl:if>
<ul>
<!-- xsl:apply-templates select="did| accessrestrict| accruals| acqinfo| altformavail| appraisal| arrangement| bibliography| bioghist| controlaccess| custodhist| dao| daogrp| descgrp| fileplan| index| note| odd| originalsloc| otherfindaid| phystech| prefercite| processinfo| relatedmaterial| runner| scopecontent| separatedmaterial| userestrict" mode="contents-overview"/ -->
<xsl:apply-templates select="$page/ead/archdesc/*[not(local-name()='dsc')]" mode="contents-overview"/>

</ul>

</li>
<!-- li><a href="/view?docId={$docId};developer={$developer};style=oac4;view=dsc">Collection outline</a></li -->
</ul>
</xsl:template>

<xsl:template match="*[@tmpl:insert='TableOfContents']">
  <xsl:variable name="contents" select="if ($page/ead/heads) then $page/ead/heads else ($page/ead/archdesc/dsc)"/>

  <xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
	<xsl:apply-templates select="$contents" mode="toc"/>
  </xsl:element>

</xsl:template>


<xsl:template match="*[@tmpl:insert='NavWatch']">
   <xsl:element name="{name()}">
	<xsl:call-template name="copy-attributes">
		<xsl:with-param name="element" select="."/>
	</xsl:call-template>
	<xsl:choose>
		<xsl:when test="$view='dsc'">
			<div class="sub-heading-1" id="c01nav">&#xA0;</div>
			<div class="sub-heading-2" id="c02nav">&#xA0;</div>
		</xsl:when>
		<xsl:when test="$view='admin'">
			<div class="sub-heading-1" id="c01nav">Collection Details</div>
			<div class="sub-heading-2" id="c02nav">&#xA0;</div>
		</xsl:when>
		<xsl:when test="$doc.view='items'">
			<div class="sub-heading-1" id="c01nav">Online Items</div>
			<div class="sub-heading-2" id="c02nav">&#xA0;</div>
		</xsl:when>
		<xsl:otherwise>
			<div class="sub-heading-1" id="c01nav">Collection Overview</div>
			<div class="sub-heading-2" id="c02nav">&#xA0;</div>
		</xsl:otherwise>
	</xsl:choose>
   </xsl:element>
</xsl:template>


<xsl:template match="unitid" mode="collectionId">
	<!-- xsl:apply-templates mode="ead"/ -->
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="*" mode="collectionId">
	<xsl:apply-templates mode="collectionId"/>
</xsl:template>

<xsl:template match="address" mode="collectionId">
	<div><i><xsl:apply-templates mode="collectionId"/></i></div>
</xsl:template>

<!-- mode toc -->

<xsl:template name="camera">
<img class="icon" alt="[Online Content]" width="15" border="0" height="9" src="/images/icons/eye_icon.gif"/>
</xsl:template>

<xsl:template match="heads" mode="toc">
	<xsl:apply-templates mode="toc"/>
</xsl:template>

<xsl:template match="div" mode="toc">
	<xsl:variable name="node" select="key('c0x',@cid)[1]"/>
	<xsl:variable name="pageStart" select="floor($node/@C-ORDER div 2500) * 2500 + 1"/>
	<xsl:variable name="this.hit" select="key('hit-num-dynamic', $node/@xtf:firstHit)"/>
	<xsl:variable name="this.hit.pageStart" select="floor($this.hit/ancestor::*[@C-ORDER][1]/@C-ORDER div 2500) * 2500  + 1"/>
        <xsl:variable name="link">
                <xsl:choose>
                        <xsl:when test="( not($view='dsc') 
						or number($pageStart) != number($dsc.position))
					or ($this.hit.pageStart)">
                                <xsl:text>/view?docId=</xsl:text>
                                <xsl:value-of select="$docId"/>
                                <xsl:if test="$developer != 'local'">
                                        <xsl:text>;developer=</xsl:text>
                                        <xsl:value-of select="$developer"/>
                                </xsl:if>
                                <xsl:if test="$query">
                                        <xsl:text>;query=</xsl:text>
                                        <xsl:value-of select="$query"/>
                                </xsl:if>
				<xsl:if test="$pageStart &gt; 1">
                                        <xsl:text>;dsc.position=</xsl:text>
					<xsl:value-of select="$pageStart"/>
                                </xsl:if>
                                <xsl:text>;style=oac4;view=dsc</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:variable>
	<div class="{if (@class='dsc') then 'navCategory' else (@class)}">

		<xsl:if test="key('hasContent',@cid)">
			<xsl:call-template name="camera"/>
		</xsl:if>
		<a href="{$link}#{@cid}" class="navAction">
			<xsl:apply-templates mode="toc"/>
		</a>
		<xsl:if test="$node/@xtf:hitCount and not( $node/c01[@xtf:hitCount][@level='series'] |
			$node/c01[@xtf:hitCount][@level='collection'] | $node/c01[@xtf:hitCount][@level='recordgrp'] |
			$node/c01[@xtf:hitCount][@level='subseries'] | $node/c02[@xtf:hitCount][@level='series'] |
			$node/c02[@xtf:hitCount][@level='collection'] | $node/c02[@xtf:hitCount][@level='recordgrp'] |
			$node/c02[@xtf:hitCount][@level='subseries'] 
			| $node/c01[@xtf:hitCount][level='subgrp'] | $node/c02[@xtf:hitCount][level='subgrp']
			| $node/c01[@xtf:hitCount][level='fonds'] | $node/c02[@xtf:hitCount][level='fonds']
			| $node/c01[@xtf:hitCount][level='subfonds'] | $node/c02[@xtf:hitCount][level='subfonds']
 )
		">
			<span class="subhit">
				<a href="{editURL:set($link,'dsc.position',$this.hit.pageStart)}#hitNum{$node/@xtf:firstHit}">
				<xsl:text>[</xsl:text><xsl:value-of select="$node/@xtf:hitCount"/>
				<xsl:text> hit</xsl:text>
				<xsl:value-of select="if ($node/@xtf:hitCount &gt; 1) then 's' else ''"/>]
				</a>
			</span>
		</xsl:if>
	</div>

</xsl:template>

<xsl:template match="archdesc/*[@id] | c01[@id][@level='series'] | c01[@id][@level='collection']
 | c01[@id][@level='recordgrp'] | c01[@id][@level='subseries'] | c01[@id][level='subgrp'] | c02[@id][@level='series'] 
 | c02[@id][@level='collection'] | c02[@id][@level='recordgrp'] | c02[@id][@level='subseries'] | c02[@id][level='subgrp']
 | c01[@id][@level='fonds'] | c01[@id][@level='fonds'] 
 | c02[@id][@level='subfonds'] | c02[@id][@level='subfonds']" mode="toc">

	<xsl:variable name="link">
		<xsl:choose>
			<xsl:when test="not($view='dsc')">
				<xsl:text>/view?docId=</xsl:text>
				<xsl:value-of select="$docId"/>
				<xsl:if test="$developer != 'local'">
					<xsl:text>;developer=</xsl:text>
					<xsl:value-of select="$developer"/>
				</xsl:if>
				<xsl:if test="$query">
					<xsl:text>;query=</xsl:text>
					<xsl:value-of select="$query"/>
				</xsl:if>
				<xsl:text>;style=oac4;view=dsc</xsl:text>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
 <xsl:choose>
  <xsl:when test="head">
		<div class="navCategory">
			<xsl:if test="key('hasContent',@id)">
				<xsl:call-template name="camera"/>
			</xsl:if>
		<a href="{$link}#{@id}" class="navAction">
			<xsl:value-of select="head"/>
		</a>
			<xsl:if test="@xtf:hitCount and not( c01[@xtf:hitCount][@level='series'] |
				c01[@xtf:hitCount][@level='collection'] | c01[@xtf:hitCount][@level='recordgrp'] |
 				c01[@xtf:hitCount][@level='subseries'] | c02[@xtf:hitCount][@level='series'] |
 				c02[@xtf:hitCount][@level='collection'] | c02[@xtf:hitCount][@level='recordgrp'] |
 				c02[@xtf:hitCount][@level='subseries'] )
			">
				<span class="subhit"><a href="{$link}#hitNum{@xtf:firstHit}">
				<xsl:text>[</xsl:text><xsl:value-of select="@xtf:hitCount"/>
				<xsl:text> hit</xsl:text>
				<xsl:value-of select="if (@xtf:hitCount &gt; 1) then 's' else ''"/>]
				</a></span>
			</xsl:if>
		</div>


  </xsl:when>
  <xsl:when test="did/unittitle">


		<div class="{name()}">
			<xsl:if test="key('hasContent',@id)">
				<xsl:call-template name="camera"/>
			</xsl:if>
		<a href="{$link}#{@id}" class="navAction">
			<xsl:value-of select="did/unittitle"/></a>
                        <xsl:if test="@xtf:hitCount and not( c01[@xtf:hitCount][@level='series'] |
                                c01[@xtf:hitCount][@level='collection'] | c01[@xtf:hitCount][@level='recordgrp'] |
                                c01[@xtf:hitCount][@level='subseries'] | c02[@xtf:hitCount][@level='series'] |
                                c02[@xtf:hitCount][@level='collection'] | c02[@xtf:hitCount][@level='recordgrp'] |
                                c02[@xtf:hitCount][@level='subseries'] )
                        ">
        		<span class="subhit"><a href="{$link}#hitNum{@xtf:firstHit}">
		<xsl:text>[</xsl:text><xsl:value-of select="@xtf:hitCount"/>
		<xsl:text> hit</xsl:text><xsl:value-of select="if (@xtf:hitCount &gt; 1) then 's' else ''"/>
		<xsl:text>]</xsl:text></a>
		</span>
			</xsl:if>
		</div>


  </xsl:when>
  <xsl:otherwise/>
 </xsl:choose>
 <xsl:apply-templates mode="toc" select="c01[@id][@level='series'] | c01[@id][@level='collection'] | c01[@id][@level='recordgrp'] | c01[@id][@level='subseries'] | c02[@id][@level='series'] | c02[@id][@level='collection'] | c02[@id][@level='recordgrp'] | c02[@id][@level='subseries']"/>
</xsl:template>

<xsl:template match="tmpl:FootScript">

<script type="text/javascript" src="/yui/build/yahoo-dom-event/yahoo-dom-event.js"></script> 
<script type="text/javascript" src="/yui/build/dragdrop/dragdrop-min.js"></script>
<script type="text/javascript" src="/yui/build/container/container-min.js"></script>
<script type="text/javascript" src="/yui/build/treeview/treeview-min.js" ></script>
<script type="text/javascript" src="/js/help-bubbles.js"/>

<xsl:if test="$view='dsc' and (count($page/ead/heads/div) > 1 )">
	<xsl:apply-templates select="$page/ead/heads" mode="jsod"/> 
	<script src="/js/container.js" type="text/javascript"/>
</xsl:if>
<xsl:if test="($page)/ead/facet-onlineItems='Items online'">
	<iframe id="yui-history-iframe" src="/images/icons/car_icon.gif"
	    style="position:absolute; top:0; left:0; width:1px, height:1px; visibility:hidden">
	</iframe>
	<input id="yui-history-field" type="hidden"/>
	<script src="/yui/build/history/history-min.js" type="text/javascript"/>
	<script src="/yui/build/connection/connection-min.js" type="text/javascript"/>
	<script src="/js/online-items.js" type="text/javascript"/>
</xsl:if>

</xsl:template>

<xsl:template match="heads" mode="jsod">
<script type="text/javascript">
<xsl:text>var c01Heads = {</xsl:text>
        <xsl:apply-templates select="div[@class='c01']" mode="jsod"/>
<xsl:text>};
</xsl:text>
<xsl:text>var c02Heads = {</xsl:text>
        <xsl:apply-templates select="div[@class='c02']" mode="jsod"/>
<xsl:text>};
</xsl:text>
</script>
</xsl:template>

<xsl:template match="div[@class='c01']" mode="jsod">
        <xsl:variable name="t" select="tokenize(@apropos,'\s')"/>
	<xsl:variable name="pattern"><xsl:text>(&apos;|&quot;)</xsl:text></xsl:variable>
        <xsl:variable name="value" select="normalize-space(.)"/>
        <xsl:for-each select="1 to count($t)-1">
                <xsl:text>"</xsl:text><xsl:value-of select="subsequence($t, ., 1)"/><xsl:text>" : "</xsl:text>
                <xsl:value-of select="replace($value, $pattern, '\\$1')"/>
		<xsl:text>", </xsl:text>
        </xsl:for-each>
        <xsl:text>"</xsl:text><xsl:value-of select="$t[last()]"/><xsl:text>": "</xsl:text>
        <xsl:value-of select="replace($value, $pattern, '\\$1')"/><xsl:text>"</xsl:text>
        <xsl:if test="not(position() = last())">
                <xsl:text>, </xsl:text>
        </xsl:if>
</xsl:template>
 
<xsl:template match="div[@class='c02']" mode="jsod">
	<xsl:variable name="pattern"><xsl:text>(&apos;|&quot;)</xsl:text></xsl:variable>
        <xsl:variable name="value" select="normalize-space(.)"/>
        <xsl:text>"</xsl:text><xsl:value-of select="@cid"/><xsl:text>": "</xsl:text>
        <xsl:value-of select="normalize-space(replace($value,$pattern,'\\$1'))"/><xsl:text>"</xsl:text>
        <xsl:if test="not(position() = last())">
                <xsl:text>, </xsl:text>
        </xsl:if>
</xsl:template>



  
</xsl:stylesheet>
