<!-- copyright notice at end of file -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xtf="http://cdlib.org/xtf"
  version="2.0"
>
<!-- copyright notice at bottom of file --> 
<xsl:import href="xmlverbatim.xsl"/>
<xsl:import href="search.xsl"/>
<xsl:import href="parameter.xsl"/>
<xsl:include href="table.html.xsl"/>
<xsl:output method="html" media-type="text/html" />
<xsl:include href="http://voro.cdlib.org:8081/xslt/institution-ark2url.xsl"/>

<xsl:param name="docId"/>
<xsl:param name="doc.view"></xsl:param>
<xsl:param name="debug"/>
<xsl:param name="chunk.id"><xsl:value-of select="$page/ead/archdesc/*[@id][1]/@id"/></xsl:param>
<xsl:param name="item.id"><xsl:value-of 
	select="$page/ead/archdesc//*/@id[../*/dao or ../*/daogrp][1]"/></xsl:param>
<xsl:param name="query"/>
<xsl:param name="source"/>

<xsl:variable name="page" select="/"/>
<xsl:variable name="layout" select="document('template.xhtml.html')"/>

<xsl:key name="hit-num-dynamic" match="xtf:hit" use="@hitNum"/>
<xsl:key name="hit-rank-dynamic" match="xtf:hit" use="@rank"/>
<xsl:key name="item-id" match="*[@id]" use="@id"/> 

<xsl:template match="/">
    <xsl:apply-templates select="$layout/html" mode="html"/>
</xsl:template>

<!-- mode html -->

<xsl:template match="@*|*" mode="html">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="html"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="insert-breadcrumbs" mode="html">
<a href="http://www.oac.cdlib.org/search.findingaid.html">Finding Aids</a> &gt;
<xsl:choose>
<xsl:when test="1=2"/>
<xsl:otherwise>
   <xsl:if test="$page/ead/CDLPATH[@type='grandparent']">
	<a href="http://www.oac.cdlib.org/institutions/{$page/ead/CDLPATH[@type='grandparent']}">
		<xsl:call-template name="institution-ark2label">
		<xsl:with-param name="ark" select="$page/ead/CDLPATH[@type='grandparent']"/>
		</xsl:call-template>
	</a>
	&gt;
   </xsl:if>
	<a href="http://www.oac.cdlib.org/institutions/{$page/ead/CDLPATH[@type='parent']}">
		<xsl:call-template name="institution-ark2label">
		<xsl:with-param name="ark" select="$page/ead/CDLPATH[@type='parent']"/>
		</xsl:call-template>
	</a>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="insert-viewOptions" mode="html">
	<xsl:choose>
	  <xsl:when test="$doc.view = 'entire_text'">
<ul><li><a href="/view?docId={$docId}">Standard</a></li><li>Entire finding aid</li></ul>
	  </xsl:when>
	  <xsl:otherwise>
<ul><li>Standard</li><li><a href="/view?docId={$docId}&#038;doc.view=entire_text">Entire finding aid</a></li></ul>
	  </xsl:otherwise>
	</xsl:choose>

<xsl:if test="$page//dao | $page//daogrp">
  <xsl:choose>
    <xsl:when test='$doc.view = "items"'>
	<div class="padded">
	<img alt="" width="84" border="0" height="16" 
		src="http://www.oac.cdlib.org/images/onlineitemsbutton.gif"/>
	<img alt="" width="17" border="0" height="14" 
		src="http://www.oac.cdlib.org/images/image_icon.gif"/>
 	<xsl:value-of select="count($page//dao | $page//daogrp)"/>
	</div>
    </xsl:when>
    <xsl:otherwise>
	<div class="padded">
	<img alt="" width="84" border="0" height="16" 
		src="http://www.oac.cdlib.org/images/onlineitemsbutton.gif"/>
	<a href="/view?docId={$docId}&#038;doc.view=items">
	<img alt="" width="17" border="0" height="14" 
		src="http://www.oac.cdlib.org/images/image_icon.gif"/></a>
	<a href="/view?docId={$docId}&#038;doc.view=items">
 	<xsl:value-of select="count($page//dao | $page//daogrp)"/></a>
	</div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:if>
</xsl:template>

<xsl:template match="insert-searchForm" mode="html">
<form method="GET" action="/view">
<input type="hidden" name="docId" value="{$docId}"/>
<input type="text" size="15" name="query"/><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><input type="image" name="submit" src="http://www.oac.cdlib.org/images/goto.gif" align="middle" border="0"/>
</form>
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
[<a href="/view?docId={$docId}&#038;{$lastbit}">Clear Hits</a>]<br/>
<xsl:value-of select="$page/ead/@xtf:hitCount"/> occurences of <xsl:value-of select="$query"/>
</xsl:if>


</xsl:template>

<xsl:template match="insert-title" mode="html">
	<xsl:value-of select="$page/ead/eadheader/filedesc/titlestmt/titleproper[1]"/>
</xsl:template>

<xsl:template match="insert-toc" mode="html">
	<xsl:apply-templates select="$page/ead/archdesc/*[@id]" mode="toc"/>
</xsl:template>

<xsl:template match="insert-text" mode="html">
	<xsl:choose>
	<xsl:when test="$doc.view='items'">
-<xsl:copy-of  select="key('item-id',$item.id)"/>-
-<xsl:value-of select="key('item-id',$item.id)"/>-
-<xsl:value-of select="key('item-id','brk3041')"/>-
-<xsl:copy-of  select="key('item-id','brk3041')"/>-
hello:<xsl:value-of select="$item.id"/>
	<xsl:apply-templates select="$page/ead/archdesc//*[@id=$item.id]" mode="items"/>
		<xsl:if test="$debug='xml'">
			<xsl:apply-templates select="$page/ead/archdesc//*[@id=$item.id]" mode="xmlverb"/>
		</xsl:if>
        </xsl:when>
	<xsl:when test="$doc.view='entire_text'">
	<xsl:apply-templates select="$page/ead/archdesc | $page/ead/eadheader | $page/ead/frontmatter"/>
		<xsl:if test="$debug='xml'">
			<xsl:apply-templates select="$page/ead/archdesc | $page/ead/eadheader | $page/ead/frontmatter" mode="xmlverb"/>
		</xsl:if>
        </xsl:when>
	<xsl:when test="$chunk.id">
	<xsl:apply-templates select="$page/ead//*[@id=$chunk.id]"/>
		<xsl:if test="$debug='xml'">
			<xsl:apply-templates select="$page/ead//*[@id=$chunk.id]" mode="xmlverb"/>
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
	<xsl:with-param name="ark" select="$page/ead/CDLPATH[@type='parent']"/>
	</xsl:call-template>
</xsl:attribute>
	<xsl:call-template name="institution-ark2label">
	<xsl:with-param name="ark" select="$page/ead/CDLPATH[@type='parent']"/>
	</xsl:call-template>
</a>
</xsl:template>

<!-- mode toc -->

<xsl:template name="camera">
<img class="icon" alt="[Online Content]" width="17" border="0" height="14" src="http://www.oac.cdlib.org/images/image_icon.gif"/>
</xsl:template>

<xsl:template match="*" mode="toc">
<xsl:variable name="lastbit">
  <xsl:if test="$query">&#038;query=<xsl:value-of select="$query"/></xsl:if>
  <xsl:if test="$source">&#038;source=<xsl:value-of select="$source"/></xsl:if>
</xsl:variable>

<xsl:variable name="camera">
  <xsl:choose>
    <xsl:when test=".//dao | .//daogrp">1</xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:variable>


 <xsl:choose>
  <xsl:when test="head">
	<xsl:choose>
	   <xsl:when test="$chunk.id = @id">
		<div class="navCategorySelected">
			<xsl:if test="$camera = '1'">
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
			<xsl:if test="$camera = '1'">
				<xsl:call-template name="camera"/>
			</xsl:if>
		<a href="/view?docId={$docId}&#038;chunk.id={@id}{$lastbit}">
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
			<xsl:if test="$camera = '1'">
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
			<xsl:if test="$camera = '1'">
				<xsl:call-template name="camera"/>
			</xsl:if>
		<a href="/view?docId={$docId}&#038;chunk.id={@id}{$lastbit}">
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
<xsl:template match="*" mode="items">

<xsl:apply-templates/>

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
        <xsl:choose>
        <xsl:when test="child::text()">
                <xsl:apply-templates/><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
        </xsl:when>
        <xsl:otherwise>
                <xsl:apply-templates/>
        </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="@LABEL">
        <xsl:text disable-output-escaping='yes'><![CDATA[</p>]]></xsl:text>
        </xsl:if>
</xsl:template>

<xsl:template match="xtf:hit"><xsl:apply-imports/></xsl:template>
<xsl:template match="xtf:term"><xsl:apply-imports/></xsl:template>

<xsl:template match="CDLTITLE | NTITLE | eadheader |CDLPATH">
</xsl:template>

<!-- xsl:template match="table">
	<xsl:apply-templates/>
</xsl:template -->

<xsl:template match="emph">
	<em><xsl:apply-templates/></em>
</xsl:template>

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

<xsl:template match="c01 | c02 | c03 | c04 | c05 | c06 | c07 | c08 | c09 | c10 | c11">
<!--
<xsl:choose>
<xsl:when test="DAOGRP/DAOLOC | DID/DAOGRP/DAOLOC">
-->
	<ul>
<p>
	<img src="http://www.oac.cdlib.org/images/black.gif" width="400" height="1"
alt="---------------------------------------" />
</p>
<!-- <![CDATA[<br />]]> -->
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
	<li>
	<xsl:apply-templates/>
	</li>
</xsl:when>
<xsl:otherwise>
	<xsl:apply-templates/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="unittitle/unitdate">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
<xsl:apply-templates/> 
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="unitid | unittitle">
<xsl:choose>
 <xsl:when test="@label">
        <p><b><xsl:value-of select="@label"/>
		<xsl:if test="
			substring(@label,string-length(@label)) != ':'
			and
			substring(@label, string-length(@label)-1) != ': '
		">:
		</xsl:if><xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
	</b><xsl:apply-templates/></p>
 </xsl:when>
 <xsl:otherwise>
	<b><xsl:apply-templates/></b>
<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
 </xsl:otherwise>
</xsl:choose>
</xsl:template>

<!--
<xsl:template match="eadheader">
<table border="1">
<tr><th>eadheader</th></tr>
<tr><td>
	<xsl:apply-templates/>
</td></tr></table>
</xsl:template>
-->

<xsl:template match="eadid">
<p><b>eadid</b><br/>	<xsl:value-of select="."/></p>
</xsl:template>

<xsl:template match="list">
	<ul><xsl:apply-templates/></ul>
</xsl:template>

<xsl:template match="item">
	<li><xsl:apply-templates/></li>
</xsl:template>

<xsl:template match="container">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
<font color="#996600">[
<xsl:choose>
<xsl:when test="@label">
	<xsl:value-of select="@label"/>: 
</xsl:when>
<xsl:otherwise>
	<xsl:value-of select="@type"/>: 
</xsl:otherwise>
</xsl:choose>

<xsl:apply-templates/>
]</font>
<xsl:text disable-output-escaping='yes'><![CDATA[<br>]]></xsl:text>
</xsl:template>

<xsl:template match="lb">
<xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
</xsl:template>

<xsl:template match="title">
<i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="head">
<xsl:choose>
<xsl:when test="ancestor-or-self::node()/c01">
	<p><b><xsl:apply-templates/></b></p>
</xsl:when>
<xsl:otherwise>
	<h3><xsl:apply-templates/></h3>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="titleproper">
	<h2><xsl:apply-templates/></h2>
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

<xsl:template match="extent">
	<xsl:apply-templates mode="br"/>
</xsl:template>

<xsl:template match="extref | archref">
<xsl:choose>
 <xsl:when test="@href">
  <a href="{@href}">
  <xsl:choose>
  <xsl:when test="text()">
   <xsl:apply-templates/>
  </xsl:when>
   <xsl:otherwise>Link</xsl:otherwise>
  </xsl:choose>
  </a><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
 </xsl:when>
 <xsl:otherwise>
  <xsl:apply-templates/>
 </xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="repository">
<xsl:choose>
	<xsl:when test="@label">
	<p>
		<b><xsl:value-of select="@label"/>: </b><xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text>
<a>
        <xsl:attribute name="href">
                <xsl:call-template name="institution-ark2url">
                <xsl:with-param name="ark" select="$page/ead/CDLPATH[@type='parent']"/>
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
                <xsl:with-param name="ark" select="$page/ead/CDLPATH[@type='parent']"/>
                </xsl:call-template>
	</xsl:attribute>
	</a><xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="dao">
	    <xsl:choose>
          <xsl:when test="@poi">
        <a href="http://ark.cdlib.org/{@poi}"><img border="0" width="17" height="14" alt="[image]" src="http://oac.cdlib.org/images/image_icon.gif"/> view attached object</a>
        </xsl:when>
        <xsl:otherwise>
        <a href="{@href}"><img border="0" width="17" height="14" alt="[image]" src="http://oac.cdlib.org//images/image_icon.gif"/> view attached object</a>
        </xsl:otherwise>
        </xsl:choose>
</xsl:template>

<xsl:template match="daogrp">
<p>
	<a href="http://ark.cdlib.org/{@poi}"><img border="0" width="17" height="14" alt="[image]" src="http://www.oac.cdlib.org/images/image_icon.gif"/> view image</a>
	<xsl:apply-templates/> 
</p>
</xsl:template>

<xsl:template match="daoloc">
|	<a href="{@href}"><xsl:value-of select="@role"/></a>
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
<xsl:apply-templates select="date"/>
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

<xsl:template match="event | persname | corpname">
<xsl:apply-templates/>
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
