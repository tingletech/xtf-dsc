<!-- copyright notice at end of file -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xtf="http://cdlib.org/xtf"
  xmlns:cdlpath="http://www.cdlib.org/path/"
  version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:exslt="http://exslt.org/common"
  exclude-result-prefixes="#all"
>
<!-- copyright notice at bottom of file --> 
<xsl:import href="../../../../common/brandCommon.xsl"/>
<xsl:import href="xmlverbatim.xsl"/>
<xsl:import href="search.xsl"/>
<xsl:import href="parameter.xsl"/>
<!-- xsl:import href="../../common/docFormatterCommon.xsl"/ -->
<xsl:include href="page.xsl"/>
<xsl:include href="table.html.xsl"/>
<xsl:output method="html" media-type="text/html" />
<xsl:include href="http://voro.cdlib.org:8081/xslt/institution-ark2url.xsl"/>
<xsl:param name="root.path"/>
<xsl:param name="baseURL" select="replace($root.path, ':[0-9]+.+', '/')"/>
<xsl:param name="brand" select="'oac'"/>
<xsl:variable name="brandCgi">
  <xsl:choose>
	<xsl:when test="not($brand = 'calisphere' or $brand='woodblock')">
		<xsl:text>&amp;brand=</xsl:text>
		<xsl:value-of select="$brand"/>
	</xsl:when>
	<xsl:otherwise/>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="brandCgiQ">
  <xsl:choose>
	<xsl:when test="not($brandCgi = '')">
		<xsl:text>?</xsl:text>
		<xsl:value-of select="$brandCgi"/>
	</xsl:when>
	<xsl:otherwise/>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="brand.file">
  <xsl:choose>
    <xsl:when test="$brand = 'calisphere' or $brand = 'calcultures' or $brand='jarda' or $brand='woodblock'">
      <xsl:copy-of select="document('../../../../../brand/oac.xml')"/>
    </xsl:when>
    <xsl:when test="$brand != ''">
      <xsl:copy-of select="document(concat('../../../../../brand/',$brand,'.xml'))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="document('../../../../../brand/oac.xml')"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:param name="docId"/>
<xsl:param name="doc.view"></xsl:param>
<xsl:param name="debug"/>
<xsl:param name="link.id"/>
<xsl:param name="chunk.id">
  <xsl:choose>
      <xsl:when test="$doc.view='items'">
      </xsl:when>
      <!-- xsl:when test="not($hit.rank) and not($link.id)">
      </xsl:when -->
      <xsl:when test="$hit.rank != '0' and key('hit-rank-dynamic', $hit.rank)/ancestor-or-self::c01">
       <xsl:value-of select="key('hit-rank-dynamic', $hit.rank)/ancestor::c01[1]/@id"/>
      </xsl:when>
      <xsl:when test="$hit.rank != '0' and key('hit-rank-dynamic', $hit.rank)/ancestor-or-self::*[name(..)='archdesc'][@id]">
       <xsl:value-of select="(key('hit-rank-dynamic', $hit.rank)/ancestor-or-self::*[name(..)='archdesc'][@id])/@id"/>
      </xsl:when>
      <xsl:when test="$link.id != '0' and key('c0x', $link.id)/ancestor-or-self::c01">
       <xsl:value-of select="key('c0x', $link.id)/ancestor::c01[1]/@id"/>
      </xsl:when>
      <xsl:when test="$link.id != '0' and key('c0x', $link.id)/ancestor-or-self::*[name(..)='archdesc'][@id]">
       <xsl:value-of select="(key('c0x', $link.id)/ancestor-or-self::*[name(..)='archdesc'])[@id]/@id"/>
      </xsl:when>
      <xsl:otherwise>
<xsl:value-of select="$page/ead/archdesc/*[@id][1]/@id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

<xsl:param name="item.position">1</xsl:param>
<!-- xsl:param name="item.id">
   <xsl:choose>
   	<xsl:when test="$page/ead/archdesc/@eadFirstItem">
		<xsl:value-of select="$page/ead/archdesc/@eadFirstItem"/>
   	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="
	$page/ead/archdesc//*/@id[../*/dao or ../*/daogrp][1]"/>
	</xsl:otherwise>
   </xsl:choose>
</xsl:param -->
<xsl:param name="query"/>
<xsl:param name="source"/>

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

<xsl:param name="dao-label">
   <xsl:choose>
	<xsl:when test="$page/ead/archdesc/did/physdesc/extent[@type='dao']">
        <xsl:value-of select="$page/ead/archdesc/did/physdesc/extent[@type='dao']"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="$dao-count"/>
	</xsl:otherwise>
   </xsl:choose>
</xsl:param>

<xsl:variable name="page" select="/"/>
<xsl:variable name="layout" select="document('template.xhtml.html')"/>
<!-- convert this to a key somehow? -->
<!-- xsl:variable name="daos" select="$page/ead/archdesc//*[did/daogrp or did/dao] 
		| $page/ead/archdesc/did[dao[starts-with(@role,'http://oac.cdlib.org/arcrole/link/search')]]"/ -->

<xsl:key name="daos" match="*[did/daogrp] | *[did/dao]" >
	<xsl:value-of select="@ORDER"/>
</xsl:key>

  <xsl:key
        name="dscPositions"
        match="dscgrp|dsc|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c12" >
<xsl:value-of select="@C-ORDER"/>
  </xsl:key>



<xsl:key name="hit-num-dynamic" match="xtf:hit" use="@hitNum"/>
<xsl:key name="hit-rank-dynamic" match="xtf:hit" use="@rank"/>
<xsl:key name="item-id" match="*/did/dao | */did/daogrp" use="@id"/> 
<xsl:key name="c0x" match="archdesc/*|c|c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12" use="@id"/> 
<xsl:key name="hasContent" match="*[@id][.//dao|.//daogrp]" use="@id"/>
<!-- xsl:key name="all-ids" match="*" use="@id"/ --> 
<!-- xsl:key name="linkable.docIds" match="archdesc/*[@id] | c01[@id][@level='series'] | c01[@id][@level='collection'] | c01[@id][@level='recordgrp'] | c01[@id][@level='subseries'] | c02[@id][@level='series'] | c02[@id][@level='collection'] | c02[@id][@level='recordgrp'] | c02[@id][@level='subseries']" use="@id"/ -->

<xsl:variable name="this.chunk" select="key('c0x', $chunk.id)"/>

<xsl:strip-space elements="did"/>

<xsl:template match="/">
<!-- xsl:for-each select="//*[did/daogrp] | //*[did/dao]" >
<xsl:message><xsl:value-of select="name()"/> key='<xsl:value-of select="count(preceding::*[did/daogrp] | preceding::*[did/dao] | ancestor::*[did/dao] | ancestor::*[did/daogrp] )"/>'</xsl:message>
</xsl:for-each -->
    <xsl:apply-templates select="$layout/html" mode="html"/>
</xsl:template>

<!-- mode html -->

<xsl:template match="@*|*" mode="html">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="html"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="insert-links" mode="html">
	<xsl:copy-of select="$brand.links"/>
</xsl:template>

<xsl:template match="insert-head" mode="html">
<xsl:if test="$brand='oac'">
	<meta http-equiv="refresh">
	<xsl:attribute name="content">
		<xsl:text>0;url=http://www.oac.cdlib.org/findaid/</xsl:text>
		<xsl:value-of select="$page/ead/eadheader/eadid/@identifier"/>
	</xsl:attribute>
	</meta>
</xsl:if>
	<xsl:copy-of select="$brand.header"/>
</xsl:template>

<xsl:template match="insert-footer" mode="html">
	<xsl:copy-of select="$brand.footer"/>
</xsl:template>

<xsl:template match="insert-base" mode="html">
<xsl:if test="($docId)">
	<xsl:if test="not ($query)">
	<base href="{$baseURL}"/>
	</xsl:if>
</xsl:if>
</xsl:template>

<xsl:template match="insert-fa-url" mode="html">
http://www.oac.cdlib.org/findaid/<xsl:value-of select="$page/ead/eadheader/eadid/@identifier"/>
</xsl:template>

<xsl:template match="insert-breadcrumbs" mode="html">
<a href="http://www.oac.cdlib.org/search.findingaid.html">Finding Aids</a> &gt;
   <xsl:if test="$page/ead/eadheader/eadid/@cdlpath:grandparent">
	<a href="http://www.oac.cdlib.org/institutions/{$page/ead/eadheader/eadid/@cdlpath:grandparent}">
		<xsl:call-template name="institution-ark2label">
		<xsl:with-param name="ark" select="$page/ead/eadheader/eadid/@cdlpath:grandparent"/>
		</xsl:call-template>
	</a>
	&gt;
   </xsl:if>
	<a href="http://www.oac.cdlib.org/institutions/{$page/ead/eadheader/eadid/@cdlpath:parent}">
		<xsl:call-template name="institution-ark2label">
		<xsl:with-param name="ark" select="$page/ead/eadheader/eadid/@cdlpath:parent"/>
		</xsl:call-template>
	</a>
</xsl:template>


<xsl:template match="insert-viewOptions" mode="html">
	<xsl:variable name="lastbit">
	<xsl:if test="$source">&#038;source=<xsl:value-of select="$source"/></xsl:if>
	</xsl:variable>
	<xsl:choose>
	  <xsl:when test="$doc.view = 'entire_text'">
<ul><li><a href="/view?docId={$docId}{$lastbit}{$brandCgi}">Standard</a></li><li>Entire finding aid</li></ul>
	  </xsl:when>
	  <xsl:when test="$doc.view = 'items'">
<ul><li><a href="/view?docId={$docId}{$lastbit}{$brandCgi}">Standard</a></li></ul>
<ul>
<li><a href="/view?docId={$docId}&#038;doc.view=entire_text{$brandCgi}">Entire finding aid</a></li></ul>
	  </xsl:when>
	  <xsl:otherwise>
<ul><li>Standard</li></ul><ul>
<li><a href="/view?docId={$docId}&#038;doc.view=entire_text{$lastbit}{$brandCgi}">Entire finding aid</a></li></ul>
	  </xsl:otherwise>
	</xsl:choose>

<xsl:if test="$dao-count &gt; 0">
  <xsl:choose>
    <xsl:when test='$doc.view = "items"'>
	<div class="padded">
	<img alt="" width="84" border="0" height="16" 
		src="http://www.oac.cdlib.org/images/onlineitemsbutton.gif"/>
	<img alt="" width="17" border="0" height="14" 
		src="http://www.oac.cdlib.org/images/image_icon.gif"/>
 	<xsl:value-of select="$dao-label"/> 
	</div>
    </xsl:when>
    <xsl:otherwise>
	<xsl:variable name="link"><!-- /view?docId=<xsl:value-of select="$docId"/>&#038;doc.view=items<xsl:value-of select="$lastbit"/ -->
	<xsl:choose>
 	  <xsl:when test="$page/ead/archdesc/did/dao[starts-with(@role,'http://oac.cdlib.org/arcrole/link/search')]">
	<xsl:value-of select="($page/ead//dao)[1]/@href"/><xsl:value-of select="if (starts-with(@href,'http://ark.cdlib.org/ark:/')) then $brandCgi else ''"/>
 	  </xsl:when>
 	  <xsl:otherwise>/view?docId=<xsl:value-of select="$docId"/>&#038;doc.view=items<xsl:value-of select="$lastbit"/><xsl:value-of select="$brandCgi"/></xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
	
	<div class="padded">
	<img alt="" width="84" border="0" height="16" 
		src="http://www.oac.cdlib.org/images/onlineitemsbutton.gif"/>
	<a href="{$link}">
	<img alt="" width="17" border="0" height="14" 
		src="http://www.oac.cdlib.org/images/image_icon.gif"/></a>
	<a href="{$link}">
 	<xsl:value-of select="$dao-label"/></a>
	</div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:if>
</xsl:template>

<xsl:template match="insert-searchForm" mode="html">

<xsl:choose>
	<xsl:when test="($dao-count &gt; 0) and ($doc.view = 'items')">
<h2>Search these items</h2>
<form method="GET" action="/search">
<input type="hidden" name="relation" value="ark:/13030/{$docId}"/>
<input type="hidden" name="style" value="oac-img"/>
<input type="text" size="15" name="keyword"/><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><input type="image" name="submit-ignore" src="http://www.oac.cdlib.org/images/goto.gif" align="middle" border="0"/>
<xsl:if test="not($brand = 'oac')"> <input type="hidden" name="brand" value="{$brand}"/> </xsl:if>
</form>
	</xsl:when>

	<xsl:otherwise>
<h2>Search within this document:</h2>
<form method="GET" action="/view">
<input type="hidden" name="docId" value="{$docId}"/>
<input type="text" size="15" name="query"/><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><input type="image" name="submit" src="http://www.oac.cdlib.org/images/goto.gif" align="middle" border="0"/>

<xsl:if test="not($brand = 'oac')"> <input type="hidden" name="brand" value="{$brand}"/> </xsl:if>
</form>
	</xsl:otherwise>
</xsl:choose>	
</xsl:template>

<xsl:template match="insert-hits" mode="html">
<xsl:variable name="lastbit">
 <xsl:choose>
  <xsl:when test="$chunk.id">&#038;chunk.id=<xsl:value-of select="$chunk.id"/>
  </xsl:when>
  <xsl:otherwise/>
 </xsl:choose>
</xsl:variable>
<xsl:if test="$page/ead/@xtf:hitCount">
[<a href="/view?docId={$docId}&#038;{$lastbit}{$brandCgi}">Clear Hits</a>]<br/>
<xsl:value-of select="$page/ead/@xtf:hitCount"/> occurrences of <xsl:value-of select="$query"/>
</xsl:if>


</xsl:template>

<xsl:template match="insert-title" mode="html">
	<xsl:value-of select="$page/ead/eadheader/filedesc/titlestmt/titleproper[1]"/>
</xsl:template>

<xsl:template match="insert-toc" mode="html">
	<xsl:apply-templates select="$page/ead/archdesc/*[@id]" mode="toc"/>
</xsl:template>

<xsl:template match="insert-text" mode="html">
	<xsl:variable name="lastbit">
	<xsl:if test="$source">&#038;source=<xsl:value-of select="$source"/></xsl:if></xsl:variable>

	<xsl:choose>
	<xsl:when test="$doc.view='items'">
	<div>
<xsl:variable name="pageme">
	<xsl:call-template name="pagination">
		<xsl:with-param name="start" select="number($item.position)"/>
		<xsl:with-param name="pageSize" select="number(50)"/>
		<xsl:with-param name="hits" select="number($dao-count)"/>
		<xsl:with-param name="base">/view?docId=<xsl:value-of select="$docId"/>&#038;doc.view=items<xsl:value-of select="$lastbit"/>&#038;item.position=</xsl:with-param>
	</xsl:call-template>
</xsl:variable>

<xsl:copy-of select="$pageme"/>

<xsl:for-each select="($page/key('daos',number($item.position)))[1]">
	<xsl:call-template name="series-top"/>
</xsl:for-each>

	<xsl:apply-templates select="for $i in xs:integer($item.position) to (xs:integer($item.position)+49) return $page/key('daos',$i)" mode="items"/>
<xsl:copy-of select="$pageme"/>
</div>




        </xsl:when>
	<xsl:when test="$doc.view='entire_text'">
	<xsl:apply-templates select="$page/ead/archdesc | $page/ead/eadheader/filedesc | $page/ead/frontmatter/publicationstmt"/>
		<xsl:if test="$debug='xml'">
			<xsl:apply-templates select="$page/ead/archdesc | $page/ead/eadheader | $page/ead/frontmatter/publicationstmt" mode="xmlverb"/>
		</xsl:if>
        </xsl:when>
	<xsl:when test="$chunk.id">
	<xsl:apply-templates select="$this.chunk"/>
		<xsl:if test="$debug='xml'">
			<xsl:apply-templates select="$this.chunk" mode="xmlverb"/>
		</xsl:if>
	</xsl:when>
	<xsl:otherwise>
	<xsl:apply-templates select="$page/ead/archdesc/*[@id][1]"/>
		<xsl:if test="$debug='xml'">
			<xsl:apply-templates select="$page/ead/archdesc/*[@id][1]" mode="xmlverb"/>
		</xsl:if>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="insert-institution" mode="html">

<a>
 <xsl:attribute name="href">
       <xsl:call-template name="institution-ark2url">
       <xsl:with-param name="ark" select="$page/ead/eadheader/eadid/@cdlpath:parent"/>
       </xsl:call-template>
 </xsl:attribute>

                <xsl:call-template name="institution-ark2label">
                <xsl:with-param name="ark" select="$page/ead/eadheader/eadid/@cdlpath:parent"/>
                </xsl:call-template>
<xsl:if test="$page/ead/eadheader/eadid/@cdlpath:grandparent">,
                <xsl:call-template name="institution-ark2label">
                <xsl:with-param name="ark" select="$page/ead/eadheader/eadid/@cdlpath:grandparent"/>
                </xsl:call-template>
   </xsl:if>
        </a>


</xsl:template>

<!-- mode toc -->

<xsl:template name="camera">
<img class="icon" alt="[Online Content]" width="17" border="0" height="14" src="http://www.oac.cdlib.org/images/image_icon.gif"/>
</xsl:template>

<xsl:template match="archdesc/*[@id] | c01[@id][@level='series'] | c01[@id][@level='collection']
 | c01[@id][@level='recordgrp'] | c01[@id][@level='subseries'] | c02[@id][@level='series'] 
 | c02[@id][@level='collection'] | c02[@id][@level='recordgrp'] | c02[@id][@level='subseries']" mode="toc">
<xsl:variable name="lastbit">
  <xsl:if test="$query">&#038;query=<xsl:value-of select="$query"/></xsl:if>
  <xsl:if test="$source">&#038;source=<xsl:value-of select="$source"/></xsl:if>
</xsl:variable>

 <xsl:choose>
  <xsl:when test="head">
	<xsl:choose>
	   <xsl:when test="$chunk.id = @id">
		<div class="navCategorySelected">
			<xsl:if test="key('hasContent',@id)">
				<xsl:call-template name="camera"/>
			</xsl:if>
			<xsl:value-of select="head"/>
			<xsl:if test="($query != '0') and ($query != '') and (@xtf:hitCount)">
        		<span class="subhit">[ <xsl:value-of select="@xtf:hitCount"/> hits]</span>
			</xsl:if>
		</div>
	   </xsl:when>
	   <xsl:otherwise>
		<div class="navCategory">
			<xsl:if test="key('hasContent',@id)">
				<xsl:call-template name="camera"/>
			</xsl:if>
		<a href="/view?docId={$docId}&#038;chunk.id={@id}{$lastbit}{$brandCgi}">
			<xsl:value-of select="head"/></a>
			<xsl:if test="($query != '0') and ($query != '') and (@xtf:hitCount)">
        		<span class="subhit">[ <xsl:value-of select="@xtf:hitCount"/> hits]</span>
			</xsl:if>
		</div>
	   </xsl:otherwise>
	</xsl:choose>
  </xsl:when>
  <xsl:when test="did/unittitle">
	<xsl:choose>
	   <xsl:when test="$chunk.id = @id">
		<div class="otl{name()}selected">
			<xsl:if test="key('hasContent',@id)">
				<xsl:call-template name="camera"/>
			</xsl:if>
			<xsl:value-of select="did/unittitle"/>
			<xsl:if test="($query != '0') and ($query != '') and (@xtf:hitCount)">
        		<span class="subhit">[ <xsl:value-of select="@xtf:hitCount"/> hits]</span>
			</xsl:if>
		</div>
	   </xsl:when>
	   <xsl:otherwise>
		<div class="otl{name()}menu">
			<xsl:if test="key('hasContent',@id)">
				<xsl:call-template name="camera"/>
			</xsl:if>
		<a href="/view?docId={$docId}&#038;chunk.id={@id}{$lastbit}{$brandCgi}">
			<xsl:value-of select="did/unittitle"/></a>
			<xsl:if test="($query != '0') and ($query != '') and (@xtf:hitCount)">
        		<span class="subhit">[ <xsl:value-of select="@xtf:hitCount"/> hits]</span>
			</xsl:if>
		</div>
	   </xsl:otherwise>
	</xsl:choose>
  </xsl:when>
  <xsl:otherwise/>
 </xsl:choose>
 <xsl:apply-templates mode="toc" select="c01[@id][@level='series'] | c01[@id][@level='collection'] | c01[@id][@level='recordgrp'] | c01[@id][@level='subseries'] | c02[@id][@level='series'] | c02[@id][@level='collection'] | c02[@id][@level='recordgrp'] | c02[@id][@level='subseries']"/>
</xsl:template>

<!-- mode items -->
<!-- xsl:template match="*" mode="items">

<xsl:apply-templates />

</xsl:template -->

<xsl:template match="c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12" mode="items">
<div class="item">
<xsl:call-template name="series"/>
<xsl:apply-templates select="did[daogrp or dao]" mode="items" />
</div>
</xsl:template>

<xsl:template match="did" mode="items">

<xsl:variable name="hackedLink" select="
	replace(replace(dao[1]/@href,'http://ark.cdlib.org/ark:/', concat($baseURL , 'ark:/') ) ,'/$','')" />

<xsl:choose>
	<xsl:when test="daogrp/@poi">
		<a href="/{daogrp/@poi}{$brandCgiQ}">
		<img src="/{daogrp/@poi}/thumbnail"/></a>
	</xsl:when>
	<xsl:when test="dao/@poi">
		<!-- a href="{$hackedLink}{$brandCgiQ}" -->
		<a href="/{dao/@poi}{$brandCgiQ}">
<img border="0" width="17" height="14" alt="[image]" src="http://oac.cdlib.org/images/image_icon.gif"/>
		</a>
	</xsl:when>
        <xsl:when test="contains(dao/@href,'cdlib.org/ark:/')">
                <xsl:variable name="poi" select="replace(dao/@href,'^.*ark:/(\d+)/([a-z0-9]+).*$','ark:/$1/$2')"/>
                <a href="/{dao/$poi}/{$brandCgi}">
                        <img src="/{dao/$poi}/thumbnail"/>
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
		<a href="{$hackedLink}{$brandCgiQ}">
		<img src="{$hackedLink}/thumbnail"/></a>
	</xsl:when>
	<xsl:when test="daogrp">
		<xsl:apply-templates select="daogrp"/>
	</xsl:when>
	<xsl:otherwise>[]</xsl:otherwise>
</xsl:choose>
<div class="item">
<xsl:value-of select="unittitle"/>
</div>
<hr/>
</xsl:template>


<!-- ead formatting templates -->

<xsl:template match="*">
        <xsl:if test="@label">
        <xsl:text disable-output-escaping='yes'> <![CDATA[<p>]]></xsl:text>
        <b><xsl:value-of select="@label"/>
                <xsl:if test="
                        substring(@label,string-length(@label)) != ':'
                        and
                        substring(@label, string-length(@label)-1) != ': '
                ">:
                </xsl:if><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
        </b>
        </xsl:if>

        <xsl:apply-templates/>

<xsl:if test="child::text() and not((ancestor::dsc) and (../did))">
<xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
</xsl:if>

        <xsl:if test="@LABEL">
        <xsl:text disable-output-escaping='yes'><![CDATA[</p>]]></xsl:text>
        </xsl:if>
</xsl:template>

<xsl:template match="xtf:hit"><xsl:apply-imports/></xsl:template>
<xsl:template match="xtf:term"><xsl:apply-imports/></xsl:template>

<xsl:template match="CDLTITLE | NTITLE | frontmatter |CDLPATH">
</xsl:template>

<!-- xsl:template match="table">
	<xsl:apply-templates/>
</xsl:template -->

<xsl:template match="/" mode="br">
	<br><xsl:apply-templates mode="br"/></br>
</xsl:template>

<xsl:template match="/" mode="space">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
<xsl:apply-templates mode="space"/>
</xsl:template>

<!-- <xsl:template match="PHYSFACET | DIMENSIONS">
<xsl:apply-templates/>
<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
</xsl:template> -->

<xsl:template match="c01 | c02 | c03 | c04 | c05 | c06 | c07 | c08 | c09 | c10 | c11 | c12">




	<ul>
<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
<p><a name="{@id}"></a>
	<img src="http://www.oac.cdlib.org/images/black.gif" width="400" height="1"
alt="---------------------------------------" />
</p>
	<xsl:apply-templates/>
	</ul>
<!--
</xsl:when>
<xsl:otherwise>
	<ul>
	<xsl:apply-templates/>
	</ul>
</xsl:otherwise>
</xsl:choose>
-->
</xsl:template>

<xsl:template match="odd">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="did">
<xsl:choose>
<xsl:when test="ancestor::node()/c01">
	<xsl:apply-templates mode="dscdid"/>
</xsl:when>
<xsl:otherwise>
	<xsl:apply-templates select="*[not (name(.)='unitdate')]"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="unittitle/unitdate">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
<xsl:apply-templates/> 
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<!-- xsl:choose>
 <xsl:when test="@label">
        <p><b><xsl:value-of select="@label"/>
                <xsl:if test="
                        substring(@label,string-length(@label)) != ':'
                        and
                        substring(@label, string-length(@label)-1) != ': '
                ">:
                </xsl:if><xsl:text disable-output-escaping='yes'><![CDATA[<br />
]]></xsl:text>
        </b><xsl:apply-templates/></p>
 </xsl:when>
 <xsl:otherwise>
        <b><xsl:apply-templates/></b>
<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
 </xsl:otherwise>
</xsl:choose>

</xsl:template -->


<xsl:template match="unitid | unittitle | unitdate">

<!-- br -->
<xsl:text> </xsl:text>
<xsl:choose>
 <xsl:when test="@label">
        <p><b><xsl:value-of select="@label"/>
		<xsl:if test="
			substring(@label,string-length(@label)) != ':'
			and
			substring(@label, string-length(@label)-1) != ': '
		">:
		</xsl:if><xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
	</b><xsl:apply-templates/> 
<xsl:if test="name()='unittitle'">
	<xsl:apply-templates select="following-sibling::unitdate"/>
</xsl:if>
</p>

 </xsl:when>
 <xsl:when test="name()='unittitle'"> 
	<b><xsl:apply-templates/></b><xsl:text> </xsl:text>
 </xsl:when>
 <xsl:otherwise>
	<xsl:apply-templates/>  
 </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="*" mode="dscdid">
<xsl:variable name="biteMe">
	<xsl:value-of select="normalize-space(preceding::text()[string-length(normalize-space()) &gt; 0][1])"/>
</xsl:variable>
<xsl:variable name="youSuck">
	<xsl:if test="
		preceding-sibling::node()[string-length(normalize-space()) &gt; 0]
		and
		not(name(preceding-sibling::element()[1]) = 'container')
		and
		not(name(preceding-sibling::element()[1]) = 'dao' )
		and
		not(name(preceding-sibling::element()[1]) = 'daogrp' )
		"><xsl:if test="
			not(matches($biteMe,'.*[.:;,]+\s*$'))
			and
			not(matches((text())[1],'^\s*[.:;,]'))
		"><xsl:text>. </xsl:text></xsl:if></xsl:if>
</xsl:variable>
<xsl:if test="$youSuck"><xsl:value-of select="$youSuck"/></xsl:if>
	<xsl:choose>
		<xsl:when test="name()='unittitle' and not(@label)">
			<b><xsl:apply-templates/></b>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates/>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="@label and name()!='container'">
		(<xsl:value-of select="replace(@label,'[.:;,]+\s*$','')"/>)
	</xsl:if>
</xsl:template>

<xsl:template match="p" mode="dscdid">
	<p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="eadid">
<p><b>eadid</b><br/>	<xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="list">
<xsl:apply-templates select="head | listhead"/>
   <xsl:choose>
    <xsl:when test="@type='deflist'">
	<dl class="ead-list"><xsl:apply-templates select="defitem | item"/></dl>
    </xsl:when>
    <xsl:when test="@type='ordered' and @numeration">
	<ol class="ead-{@numeration}"><xsl:apply-templates select="defitem | item"/></ol>
    </xsl:when>
    <xsl:when test="@type='ordered' and not( @numeration )">
	<ol class="ead-arabic"><xsl:apply-templates select="defitem | item"/></ol>
    </xsl:when>
    <xsl:when test="@type='marked'">
	<ul class="ead-list"><xsl:apply-templates select="defitem | item"/></ul>
    </xsl:when>
    <xsl:otherwise>
	<ul class="ead-list-unmarked"><xsl:apply-templates select="defitem | item"/></ul>
    </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template match="item">
	<li><xsl:apply-templates/></li>
</xsl:template>

<xsl:template match="defitem">
	<xsl:for-each select="label">
		<dt><xsl:apply-templates/></dt>
	</xsl:for-each>
	<xsl:for-each select="item">
		<dd><xsl:apply-templates/></dd>
	</xsl:for-each>
</xsl:template>

<xsl:template match="container" mode="dscdid">
<!-- xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text -->
<xsl:text> </xsl:text>
<span class="ead-container">[
<xsl:choose>
<xsl:when test="@label">
<xsl:value-of select="@label"/><xsl:text> </xsl:text>
</xsl:when>
<xsl:when test="@type">
<xsl:value-of select="@type"/>
<xsl:text> </xsl:text>
</xsl:when>
<xsl:otherwise/>
</xsl:choose>

<xsl:apply-templates/>
]</span>
<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
</xsl:template>

<xsl:template match="lb">
<xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
</xsl:template>

<xsl:template match="emph">
  <xsl:choose>
    <xsl:when test="@render">
	<span>
	<xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
	<xsl:apply-templates/>
	</span>
    </xsl:when>
    <xsl:otherwise><em><xsl:apply-templates/></em></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="emph" mode="dscdid">
  <xsl:choose>
    <xsl:when test="@render">
	<span>
	<xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
	<xsl:apply-templates/>
	</span>
    </xsl:when>
    <xsl:otherwise><em><xsl:apply-templates mode="dscdid"/></em></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="titleproper"/>
<xsl:template match="titleproper[@type='filing']">
	<h2>
	<xsl:if test="@render">
	<xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
	</xsl:if>
	<xsl:apply-templates/>
	</h2>
</xsl:template>

<xsl:template match="title">
	<i>
	<xsl:if test="@render">
	<xsl:attribute name="class">ead-<xsl:value-of select="@render"/></xsl:attribute>
	</xsl:if>
	<xsl:apply-templates/>
	</i>

 <xsl:if test="
name(..) = 'controlaccess'
or name(..) = 'namegrp'
">
  <br/>
 </xsl:if>

</xsl:template>

<xsl:template match="head">
<xsl:choose>
<xsl:when test="ancestor-or-self::node()/c01">
	<h4 class="containerHead"><xsl:apply-templates/></h4>
</xsl:when>
<xsl:otherwise>
	<h3><xsl:apply-templates/></h3>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="address" mode="space">
	<i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="address">
<xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
<xsl:apply-templates/>
</xsl:template>

<!-- 
<xsl:template match="P | NUM | PUBLISHER">
	<p><xsl:apply-templates/></p>
</xsl:template> 
-->

<xsl:template match="blockquote">
	<blockquote><xsl:apply-templates/></blockquote>
</xsl:template>

<xsl:template match="p">
	<xsl:choose>
	<xsl:when test="child::text()">
	<p><xsl:apply-templates/></p>
	</xsl:when>
	<xsl:otherwise>
	<xsl:apply-templates/>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template> 

<xsl:template match="indexentry">
<p><xsl:apply-templates/></p>
</xsl:template> 

<!-- xsl:template match="extent">
	<xsl:apply-templates mode="br"/>
</xsl:template -->

<!-- Emergency removal -->
<!-- xsl:template match="extent[preceding::dsc]">
<h4>Extent</h4><p><xsl:apply-templates/></p>
</xsl:template --> 

<xsl:template match="bibref | extref | archref">
<xsl:if test="(name(..)='bibliography') or 
		( name(..)='otherfindaid') or
		(name(..)='separatedmaterial') or
		( name(..)='relatedmaterial')"><br/>
</xsl:if>
<xsl:choose>
 <xsl:when test="@href and not (@show='embed')">
  <a href="{replace(@href,'http://ark.cdlib.org/ark:/','http://content.cdlib.org/ark:/')}">
  <xsl:choose>
  <xsl:when test=".//text()">
   <!-- xsl:apply-templates mode="ref"/ -->
   <xsl:apply-templates/>
  </xsl:when>
   <xsl:otherwise>Link</xsl:otherwise>
  </xsl:choose>
  </a><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
 </xsl:when>
 <xsl:when test="@href and (@show='embed')">
	<img src="{@href}"/>
 </xsl:when>
 <xsl:otherwise>
  <!-- xsl:apply-templates mode="ref"/ -->
  <xsl:apply-templates/>
 </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="extptr">
 <xsl:choose>
 <xsl:when test="@href and (@show='embed')">
        <img src="{@href}"/>
 </xsl:when>
 <xsl:otherwise>
	<a href="{@href}"><xsl:value-of select="@title"/></a>
 </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="ref">
  <xsl:choose>
	<xsl:when test="@target">
	<a href="/view?docId={$docId}&#038;link.id={@target}{$brandCgi}#{@target}"><xsl:apply-templates/></a>
	</xsl:when>
	<xsl:otherwise>
		<xsl:apply-templates/>
	</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="ptr">
	<a href="/view?docId={$docId}&#038;link.id={@target}{$brandCgi}#{@target}"><xsl:value-of select="@title"/></a>
</xsl:template>

<xsl:template match="repository[1]">
<xsl:choose>
	<xsl:when test="@label">
	<p>
		<b><xsl:value-of select="@label"/>: </b><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
<a>
        <xsl:attribute name="href">
                <xsl:call-template name="institution-ark2url">
                <xsl:with-param name="ark" select="$page/ead/eadheader/eadid/@cdlpath:parent"/>
                </xsl:call-template>
	</xsl:attribute>
	<xsl:apply-templates/>
	</a></p>
	</xsl:when>
<xsl:otherwise>
	<xsl:apply-templates/>
<a>
        <xsl:attribute name="href">
                <xsl:call-template name="institution-ark2url">
                <xsl:with-param name="ark" select="$page/ead/eadheader/eadid/@cdlpath:parent"/>
                </xsl:call-template>
	</xsl:attribute>
	</a><xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="dao" mode="dscdid">
<xsl:variable name="hackedLink" select="
         replace(@href,'http://ark.cdlib.org/ark:/', concat($baseURL , 'ark:/') )" />

<xsl:variable name="linktext">
   <xsl:choose>
	<xsl:when test="@title">
		<xsl:value-of select="@title"/>
	</xsl:when>
	<xsl:otherwise>view item(s)</xsl:otherwise>
   </xsl:choose>
</xsl:variable>

	<xsl:apply-templates select="daodesc/*"/>
	    <xsl:choose>
          <xsl:when test="@poi">
        <a href="/{@poi}{$brandCgiQ}"><img border="0" width="17" height="14" alt="[image]" src="http://oac.cdlib.org/images/image_icon.gif"/> 
<xsl:value-of select="$linktext"/></a><br/>
        </xsl:when>
        <xsl:otherwise>
        <a href="{$hackedLink}{if (starts-with(@href,'http://ark.cdlib.org/ark:/')) then $brandCgiQ else ''}"><img border="0" width="17" height="14" alt="[image]" src="http://oac.cdlib.org/images/image_icon.gif"/> 
<xsl:value-of select="$linktext"/></a><br/>
        </xsl:otherwise>
        </xsl:choose>
</xsl:template>

<xsl:template match="dao">
<xsl:variable name="hackedLinkBrand" select="if ( starts-with(@href,'http://ark.cdlib.org:/ark:/')  )
			then concat(@href, $brandCgiQ) else @href "/>
<xsl:variable name="linktext">
   <xsl:choose>
	<xsl:when test="@title">
		<xsl:value-of select="@title"/>
	</xsl:when>
	<xsl:otherwise>view item(s)</xsl:otherwise>
   </xsl:choose>
</xsl:variable>
	<xsl:apply-templates select="daodesc/*"/>
	    <xsl:choose>
          <xsl:when test="@poi">
        <a href="/{@poi}{$brandCgiQ}"><img border="0" width="17" height="14" alt="[image]" src="http://oac.cdlib.org/images/image_icon.gif"/> 
<xsl:value-of select="$linktext"/></a><br/>
        </xsl:when>
        <xsl:otherwise>
        <a href="{$hackedLinkBrand}"><img border="0" width="17" height="14" alt="[image]" src="http://oac.cdlib.org//images/image_icon.gif"/> 
<xsl:value-of select="$linktext"/></a><br/>
        </xsl:otherwise>
        </xsl:choose>
</xsl:template>

<xsl:template match="daogrp" mode="dscdid">
<p>
	<xsl:if test="@poi"><a href="/{@poi}{$brandCgi}"><img border="0" width="17" height="14" alt="[image]" src="http://www.oac.cdlib.org/images/image_icon.gif"/> view image</a></xsl:if>
	<xsl:apply-templates/> 
</p>
</xsl:template>

<xsl:template match="daogrp">
<p>
	<xsl:if test="@poi"><a href="/{@poi}{$brandCgi}"><img border="0" width="17" height="14" alt="[image]" src="http://www.oac.cdlib.org/images/image_icon.gif"/> view image</a></xsl:if>
	<xsl:apply-templates/> 
</p>
</xsl:template>

<xsl:template match="daoloc">
<xsl:variable name="linktext">
   <xsl:choose>
	<xsl:when test="@title">
		<xsl:value-of select="@title"/>
	</xsl:when>
	<xsl:otherwise><xsl:value-of select="@role"/></xsl:otherwise>
   </xsl:choose>
</xsl:variable>

|	<a href="{@href}"><xsl:value-of select="$linktext"/></a>
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="chronlist">
<table>
<xsl:apply-templates/>
</table>
</xsl:template>



<xsl:template match="chronitem">
<xsl:choose>
<xsl:when test="eventgrp">
<tr>
<td valign="top"><xsl:apply-templates select="date"/></td>
<td><xsl:apply-templates select="eventgrp/event[1]"/></td>
</tr>
<xsl:for-each select="eventgrp/event[position()>1]">
<tr><td><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text></td><td><xsl:apply-templates/></td></tr>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
<tr>
<td valign="top"><xsl:apply-templates select="date"/></td>
<td><xsl:apply-templates select="event"/></td>
</tr>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="controlaccess">
	<xsl:if test="not(head)"><h4 class="containerHead">Subjects:</h4>
	</xsl:if>
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="event | famname | function | geogname | genreform | persname | corpname | date | name | occupation | subject ">
<xsl:choose>
 <xsl:when test="
		name(..) = 'controlaccess' 
	or 	name(..) = 'namegrp' 
	or 	name(..) = 'index'
	or 	name(..) = 'origination'
	and 	not(ancestor::did)
	">
  <xsl:apply-templates/><br/>
 </xsl:when>
 <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- name series ead ++ --> 
  <xsl:template name="series-top">
    <xsl:if test="../did/unittitle and (preceding-sibling::*[did/dao or did/daogrp])">
      <xsl:for-each select=".." >
        <xsl:call-template name="series"/>
      </xsl:for-each>
      <xsl:apply-templates select="../did/unittitle" mode="series"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="series">
<!-- div>
<span>	<xsl:value-of select="preceding-sibling::*[1]/did"/></span >
	<span>a: <xsl:value-of select="preceding-sibling::*[did/dao]/@id"/></span>
	<span> a: <xsl:value-of select="preceding-sibling::*[1]/@id"/></span>
	<span> a: <xsl:value-of select="@id"/></span>
	<span> 2a: <xsl:value-of select="preceding-sibling::*[1]/../did/unittitle"/></span>
	<span> b: <xsl:value-of select="../@id"/></span>
</div -->
    <xsl:if test="../did/unittitle and not ( preceding-sibling::*[did/dao or did/daogrp] )" >
    <!-- xsl:if test=" (../did/unittitle) and 
	(../did/unittitle = preceding-sibling::*[did/dao]/../did/unittitle) "  -->
      <xsl:for-each select=".." >
        <xsl:call-template name="series"/>
      </xsl:for-each>
      <xsl:apply-templates select="../did/unittitle" mode="series"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="unittitle" mode="series">
    <h4 class="h{name(../..)}">
      <xsl:apply-templates/>
    </h4>
  </xsl:template>


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
