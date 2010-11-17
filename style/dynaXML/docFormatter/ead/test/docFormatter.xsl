<!-- copyright notice at end of file -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xtf="http://cdlib.org/xtf"
  xmlns:cdlpath="http://www.cdlib.org/path/"
  version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:exslt="http://exslt.org/common"
  xmlns:m="http://www.loc.gov/METS/"
	xmlns:tmpl="xslt://template"
  exclude-result-prefixes="#all"
>
<xsl:param name="root.path"/>
<xsl:param name="doc.view"/>
<xsl:param name="query"/>
<xsl:param name="source"/>
<xsl:param name="chunk.id"/>
<xsl:param name="docId"/>
<xsl:param name="brandCgi"/>
<xsl:param name="view"/>
<xsl:param name="show.id" select="if ($page/ead/archdesc/scopecontent) 
																			then ($page/ead/archdesc/scopecontent)[1]/@id
																			else if ($page/ead/archdesc/bioghist) 
																			then ($page/ead/archdesc/bioghist)[1]/@id
																			else ($page/ead/archdesc/*)[1][@id]/@id"/>
<xsl:output method="html" media-type="text/html" />
<xsl:variable name="page" select="/"/>
<xsl:variable name="layoutXML" select="document('template.xhtml.html')"/>
<xsl:variable name="myARK" select="replace($page/ead/identifier[1],'http://ark.cdlib.org/','')"/>
<xsl:key name="hit-num-dynamic" match="xtf:hit" use="@hitNum"/>
<xsl:key name="hit-rank-dynamic" match="xtf:hit" use="@rank"/>


<!-- root template -->
<xsl:template match="/">
        <xsl:comment>dynaXML xtf.sf.net
        xml: <xsl:value-of select="base-uri($page)"/>
        xslt: <xsl:value-of select="static-base-uri()"/>
        layout: <xsl:value-of select="base-uri($layoutXML)"/>
        </xsl:comment>
        <xsl:apply-templates select="($layoutXML)//*[local-name()='html']"/>
</xsl:template>

<xsl:template match="node()|@*">
   <xsl:copy>
   <xsl:apply-templates select="@*"/>
   <xsl:apply-templates/>
   </xsl:copy>
</xsl:template>

<!-- xsl:template match="tmpl:titleProper" name="tmpl-titleProper">
	<xsl:value-of select="$page/ead/eadheader/filedesc/titlestmt/titleproper[1]"/>
</xsl:template -->

<xsl:template match="tmpl:institution" name="tmpl-institution">
	<img src="/yui/foo.gif"/>
	<div class="EAD">design notes: zoom out to 12 (max); resize to 250 from current 300.  Include address
to repository, and map will be link to map site get directions page.  Would be built ahead of time/ at sign
up of new institutions.</div>
</xsl:template>

<xsl:template match="tmpl:frontDisp" name="tmpl-frontDisp">
	<xsl:choose>
		<xsl:when test="$view!='dsc'">
			<xsl:apply-templates select="$page/ead/archdesc/scopecontent[head]" mode="fpToc"/>
			<xsl:apply-templates select="$page/ead/archdesc/*[head][name()!='scopecontent']" mode="fpToc"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="insert-dsc-divs"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="dsc" mode="fpToc">
</xsl:template>

<xsl:template match="*" mode="fpToc">
	<xsl:choose>
		<xsl:when test="@id = $show.id">
			<xsl:apply-templates select="*" mode="ead2html"/>
		</xsl:when>
		<xsl:otherwise>
	     <h3><a href="/{$myARK}?style=ead-test;show.id={@id}"><xsl:value-of select="head"/></a></h3>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="tmpl:extentLine" name="tmpl-extentLine">
	<p><xsl:value-of select="$page/ead/facet-institution"/> - <xsl:apply-templates select="$page/ead/format" mode="extentLine"/></p>
</xsl:template>

<xsl:template match="format[1]" mode="extentLine">
	<xsl:choose>
		<xsl:when test="not($view='dsc')">
	<a href="/{$myARK}?style=ead-test;view=dsc"><xsl:value-of select="."/></a>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="."/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="format" mode="extentLine">
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="insert-findingaid" name="insert-findingaid">
	<xsl:choose>
	  <xsl:when test="$doc.view='dsc'">
	<xsl:apply-templates select="($page)/ead/archdesc/dsc" mode="ead2html"/>
	  </xsl:when>
	  <xsl:otherwise>
	<xsl:apply-templates select="($page)/ead/archdesc/*" mode="ead2html"/>
	  </xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="dsc" mode="ead2html">
</xsl:template>

<xsl:template match="*" mode="ead2html">
<xsl:apply-templates select="." mode="innerHtml"/>
</xsl:template>

<xsl:template match="tmpl:titleProper" name="tmpl-titleProper">
	<xsl:choose>
		<xsl:when test="not($view='dsc')">
        <xsl:value-of select="$page/ead/eadheader/filedesc/titlestmt/titleproper[1]"/>
		</xsl:when>
		<xsl:otherwise>
				<a href="/{$myARK}?style=ead-test">
        <xsl:value-of select="$page/ead/eadheader/filedesc/titlestmt/titleproper[1]"/>
				</a>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="head" mode="innerHtml">
	<h3><xsl:value-of select="."/></h3>
</xsl:template>

<xsl:template match="p" mode="innerHtml">
<p><xsl:apply-templates mode="innerHtml"/></p>
</xsl:template>

<xsl:template match="*" mode="innerHtml">
<div class="p">
<div class="EAD"><xsl:value-of select="name()"/></div>
        <xsl:if test="@label">
        <!-- xsl:text disable-output-escaping='yes'> <![CDATA[<p>]]></xsl:text -->
        <b><xsl:value-of select="@label"/>
                <xsl:if test="
                        substring(@label,string-length(@label)) != ':'
                        and
                        substring(@label, string-length(@label)-1) != ': '
                ">:
                </xsl:if><!-- xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text -->
        </b>
        </xsl:if>

        <xsl:apply-templates mode="innerHtml"/>

<xsl:if test="child::text() and not((ancestor::dsc) and (../did))">
<!-- xsl:text disable-output-escaping='yes'><![CDATA[<br/>]]></xsl:text -->
</xsl:if>

        <xsl:if test="@LABEL">
        <!-- xsl:text disable-output-escaping='yes'><![CDATA[</p>]]></xsl:text -->
        </xsl:if>
</div>
</xsl:template>

<xsl:template match="insert-dsc-divs" name="insert-dsc-divs">
 <div id="dsc_a" title="{$page/ead/eadheader//titleproper[@type='filing'][1]}">
	<xsl:apply-templates select="$page/ead/archdesc/dsc/*" mode="toc2"/>
 </div>
<div class="EAD">design idea, use <a href="http://developer.yahoo.com/yui/examples/treeview/customicons_clean.html">custom icons</a> that show container info to the left of the treeview control.  Box and folders and a generic container icons could be used.</div>
</xsl:template>

<xsl:template match="archdesc" mode="toc2">
<div title="Collection Description">
	<xsl:apply-templates select="*[not(name()='dsc')]" mode="toc2"/>
</div>
	<xsl:apply-templates select="dsc/*" mode="toc2"/>
</xsl:template>

<xsl:template match="*[parent::archdesc]" mode="toc2">
<div title="{head}">
	<xsl:apply-templates mode="toc2"/>
</div>
</xsl:template>

<xsl:template match="dao" mode="toc2">
<xsl:text>[</xsl:text>
<a href="{@href}"><xsl:value-of select="if (@title) then @title else 'view item'"/></a>
<xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="*" mode="toc2">
<div><xsl:apply-templates mode="toc2"/></div>
</xsl:template>

<xsl:template match="container" mode="toc2">
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
<xsl:apply-templates mode="toc2"/>
</xsl:template>

<xsl:template mode="toc2" match="c01|c02|c03|c04|c05|c06|c07|c08|c09|c10|c11|c12">
  <div class="{name()}" title="{if (did/unittitle) then normalize-space(did/unittitle) else normalize-space(did)}"> 
     <xsl:apply-templates mode="toc2"/>
  </div>
</xsl:template>

<xsl:template match="c01[@id][@level='series'] | c01[@id][@level='collection']
 | c01[@id][@level='recordgrp'] | c01[@id][@level='subseries'] | c02[@id][@level='series']
 | c02[@id][@level='collection'] | c02[@id][@level='recordgrp'] | c02[@id][@level='subseries']" mode="toc">

<li>
<xsl:value-of select="did/unittitle"/>
<xsl:if test="c02 | c03">
	<ul>
	<xsl:apply-templates select="c02 | c03" mode="toc"/>
	</ul>
</xsl:if>
</li>

</xsl:template>


</xsl:stylesheet>
<!--
   Copyright (c) 2007, Regents of the University of California
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
