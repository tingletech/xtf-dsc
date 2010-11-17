
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
                              xmlns:xtf="http://cdlib.org/xtf">

<!-- Search Hits -->

<xsl:template match="xtf:hit">

  <a name="{@hitNum}"/>

  <xsl:call-template name="prev.hit"/>

  <xsl:choose>
    <xsl:when test="xtf:term">
      <span class="hitsection">
        <xsl:apply-templates/>
      </span>
    </xsl:when>
    <xsl:otherwise>
      <span class="hit">
          <xsl:apply-templates/>
      </span>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:if test="not(@more='yes')">
    <xsl:call-template name="next.hit"/>
  </xsl:if>

</xsl:template>

<xsl:template match="xtf:more">

  <span class="hitsection">
    <xsl:apply-templates/>
  </span>

  <xsl:if test="not(@more='yes')">
    <xsl:call-template name="next.hit"/>
  </xsl:if>

</xsl:template>

<xsl:template match="xtf:term">
  <!--<xsl:if test="parent::xtf:hit">-->
    <span class="subhit">
      <xsl:if test="preceding-sibling::xtf:term">
        <xsl:text>&#160;</xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
    </span>
  <!--</xsl:if>-->
</xsl:template>

<!-- rather than use div1 here could we use a construct like that employed for the navigation arrows -->

<xsl:template name="prev.hit">

  <xsl:variable name="num" select="@hitNum"/>
  <xsl:variable name="prev" select="$num - 1"/>

  <xsl:choose>
    <xsl:when test="key('hit-num-dynamic', string($prev))/ancestor::*[@id = $chunk.id]">
      <a>
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text><xsl:value-of select="$prev"/>
        </xsl:attribute>
        <img src="{$icon.path}b_inprev.gif" border="0" alt="previous hit"/>
      </a>
      <xsl:text>&#160;</xsl:text>
    </xsl:when>
    <xsl:when test="key('hit-num-dynamic', string($prev))/ancestor::div1">
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="$doc.path"/>
          <xsl:text>&#038;chunk.id=</xsl:text>
          <xsl:value-of select="key('hit-num-dynamic', string($prev))/ancestor::div1/@id"/>
          <xsl:text>&#038;brand=</xsl:text>
          <xsl:value-of select="$brand"/>
          <xsl:value-of select="$search"/>
          <xsl:choose>
            <xsl:when test="$doc.view='bbar' or $doc.view='toc' or $doc.view='content'">
              <xsl:text>&#038;set.anchor=</xsl:text><xsl:value-of select="$prev"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>#</xsl:text><xsl:value-of select="$prev"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="target">_top</xsl:attribute>
        <img src="{$icon.path}b_inprev.gif" border="0" alt="previous hit"/>
      </a>
      <xsl:text>&#160;</xsl:text>
    </xsl:when>
    <!-- <xsl:otherwise>
      <xsl:text>&#160;</xsl:text>
    </xsl:otherwise> -->
  </xsl:choose>
</xsl:template>

<xsl:template name="next.hit">

  <xsl:variable name="num" select="@hitNum"/>
  <xsl:variable name="next" select="$num + 1"/>

  <xsl:choose>
    <xsl:when test="key('hit-num-dynamic', string($next))/ancestor::*[@id = $chunk.id]">
      <xsl:text>&#160;</xsl:text>
      <a>
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text><xsl:value-of select="$next"/>
        </xsl:attribute>
        <img src="{$icon.path}b_innext.gif" border="0" alt="next hit"/>
      </a>
    </xsl:when>
    <xsl:when test="key('hit-num-dynamic', string($next))/ancestor::div1">
      <xsl:text>&#160;</xsl:text>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="$doc.path"/>
          <xsl:text>&#038;chunk.id=</xsl:text>
          <xsl:value-of select="key('hit-num-dynamic', string($next))/ancestor::div1/@id"/>
          <xsl:text>&#038;brand=</xsl:text>
          <xsl:value-of select="$brand"/>          
          <xsl:value-of select="$search"/>
          <xsl:choose>
            <xsl:when test="$doc.view='bbar' or $doc.view='toc' or $doc.view='content'">
              <xsl:text>&#038;set.anchor=</xsl:text><xsl:value-of select="$next"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>#</xsl:text><xsl:value-of select="$next"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="target">_top</xsl:attribute>
        <img src="{$icon.path}b_innext.gif" border="0" alt="next hit"/>
      </a>
    </xsl:when>
    <!-- <xsl:otherwise>
      <xsl:text>&#160;</xsl:text>
    </xsl:otherwise> -->
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
