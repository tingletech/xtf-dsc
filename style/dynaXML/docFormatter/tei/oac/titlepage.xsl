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

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="titlePage">
<xsl:if test="preceding-sibling::titlePage">
	<hr width="50%"/>
</xsl:if>
  <div align="center">
    <table width="90%" cellpadding="5" cellspacing="5">
      <tr>
        <td>
          <div align="center">
            <xsl:choose>
              <xsl:when test="//text[@rend = $chunk.id]">
                <xsl:apply-templates select="//text[@rend = $chunk.id]//titlePage/*" mode="titlepage"/>
              </xsl:when>
              <xsl:otherwise>
              <xsl:apply-templates mode="titlepage"/>    
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </td>
      </tr>
    </table>
  </div>
</xsl:template>

<xsl:template match="docTitle/titlePart" mode="titlepage">
  <xsl:choose>
    <xsl:when test="@type='main'">
      <h2><xsl:apply-templates/></h2>
    </xsl:when>
    <xsl:when test="@type='sub'">
      <h4><i><xsl:apply-templates/></i></h4>
    </xsl:when>
    <xsl:otherwise>
      <h4><xsl:apply-templates/></h4>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="docTitle">
  <xsl:apply-templates mode="titlepage"/>
</xsl:template>

<xsl:template match="titlePart" mode="titlepage">
  <xsl:choose>
    <xsl:when test="@type='main'">
      <h2><xsl:apply-templates/></h2>
    </xsl:when>
    <xsl:when test="@type='sub'">
      <h4><i><xsl:apply-templates/></i></h4>
    </xsl:when>
    <xsl:otherwise>
      <h4><xsl:apply-templates/></h4>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="docAuthor" mode="titlepage">
  <h4><xsl:apply-templates/></h4>
</xsl:template>

<xsl:template match="docImprint/publisher" mode="titlepage">
  <h6><xsl:apply-templates/></h6>
</xsl:template>

<xsl:template match="docImprint/pubPlace" mode="titlepage">
  <h6><i><xsl:apply-templates/></i></h6>
</xsl:template>

<xsl:template match="docImprint/docDate" mode="titlepage">
  <h6><xsl:apply-templates/></h6>
</xsl:template>

<xsl:template match="imprimatur" mode="titlepage">
  <h6><xsl:apply-templates/></h6>
</xsl:template>

<xsl:template match="docEdition" mode="titlepage">
  <h6><xsl:apply-templates/></h6>
</xsl:template>

<xsl:template match="div1[@type='dedication']" mode="titlepage">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="div1[@type='epigraph']" mode="titlepage">
  <xsl:apply-templates/>
</xsl:template>

<!-- ====================================================================== -->
<!-- Figures                                                                -->
<!-- ====================================================================== -->

<xsl:template match="figure" xmlns:m="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" mode="titlepage">

  <!-- $figureStyle will be 'voroBasic' or 'dynaXML' -->
  <xsl:variable name="entity" select="@entity"/>
  <xsl:variable name="img_src">
    <xsl:choose>
      <xsl:when test="contains($docId, 'preview')">
        <xsl:value-of select="unparsed-entity-uri(@entity)"/>
      </xsl:when>
      <xsl:when test="$figureStyle = 'voroBasic'">
        <xsl:value-of select="concat($xtfURL, 'data/', $subDir, '/', $docId, '/')"/>
        <xsl:value-of select="$METS/m:mets/m:fileSec/m:fileGrp/m:file[@ID=$entity]/m:FLocat/@*[local-name(.)='href']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($figure.path, @entity)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="fullsize">
    <xsl:choose>
      <xsl:when test="contains($docId, 'preview')">
        <xsl:value-of select="unparsed-entity-uri(substring-before(substring-after(@rend, 'popup('), ')'))"/>
      </xsl:when>
      <xsl:when test="$figureStyle = 'voroBasic'">
	<xsl:value-of select="concat($xtfURL, 'data/', $subDir, '/', $docId, '/')"/>
	<xsl:variable name="popup" select="substring-before(substring-after(@rend,'('),')')"/>
	<xsl:value-of select="$METS/m:mets/m:fileSec/m:fileGrp/m:file[@ID=$popup]/m:FLocat/@*[local-name(.)='href']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($figure.path, substring-before(substring-after(@rend,'('),')'))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$anchor.id=@id">
    <a name="X"></a>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="@rend='inline'">
      <img src="{$img_src}" alt="inline image"/>
    </xsl:when>
    <xsl:when test="@rend='figure'">
      <div class="illgrp">
        <img src="{$img_src}" alt="figure"/>
        <!-- for figDesc -->
        <xsl:apply-templates/>
      </div>
    </xsl:when>
    <xsl:when test="@rend='offline' and not($doc.view='entire_text')">
      <div class="illgrp">
        <a>
          <xsl:attribute name="href">javascript://</xsl:attribute>
          <xsl:attribute name="onClick">
            <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$doc.path"/><xsl:text>&#038;doc.view=popup&#038;fig.ent=</xsl:text><xsl:value-of select="$img_src"/><xsl:text>','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
          </xsl:attribute>
          <img src="{$icon.path}offline.gif" border="0" alt="figure"/>
        </a>
        <!-- for figDesc -->
        <xsl:apply-templates/>
      </div>
    </xsl:when>
    <xsl:when test="contains(@rend, 'popup(')">
      <div class="illgrp">
        <img src="{$img_src}" alt="figure"/>
        <!-- for figDesc -->
        <xsl:apply-templates/>
        <br/>
        <xsl:text>[</xsl:text>
        <a>
          <xsl:attribute name="href">javascript://</xsl:attribute>
          <xsl:attribute name="onClick">
            <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$doc.path"/><xsl:text>&#038;doc.view=popup&#038;fig.ent=</xsl:text><xsl:value-of select="$fullsize"/><xsl:text>','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
          </xsl:attribute>
          <xsl:text>Full Size</xsl:text>
        </a>
        <xsl:text>]</xsl:text>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <div class="illgrp">
        <img src="{$img_src}" alt="figure"/>
        <!-- for figDesc -->
        <xsl:apply-templates/>
      </div>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

</xsl:stylesheet>
