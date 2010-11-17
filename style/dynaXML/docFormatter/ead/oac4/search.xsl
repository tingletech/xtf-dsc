<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xtf="http://cdlib.org/xtf"
	xmlns:editURL="http://cdlib.org/xtf/editURL"
	exclude-result-prefixes="#all">


<xsl:variable name="view.section" select="if ($view='dsc') then '3' else if ($view='admin') then '2' else '1'">
</xsl:variable>

<!-- Search Hits -->

<xsl:template match="xtf:hit" mode="ead-no-hit-nav">
  <xsl:choose>
    <xsl:when test="xtf:term">
      <span id="hitNum{@hitNum}" class="hitsection">
        <xsl:apply-templates mode="ead-no-hit-nav"/>
      </span>
    </xsl:when>
    <xsl:otherwise>
      <span id="hitNum{@hitNum}" class="hit">
          <xsl:apply-templates mode="ead-no-hit-nav"/>
      </span>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xtf:hit" mode="ead">
  <!-- xsl:param name="this.section" select="'hits'"/ -->

  <!-- xsl:variable name="this.hitNum" select="@hitNum"/ -->

<xsl:variable name="prev.hit" select="key('hit-num-dynamic', string(@hitNum - 1))"/>
<xsl:variable name="this.hit" select="key('hit-num-dynamic', @hitNum)"/>
<xsl:variable name="next.hit" select="key('hit-num-dynamic', string(@hitNum + 1))"/>

<xsl:variable name="prev.hit.section"  select="if ( $prev.hit/ancestor::dsc)  then '3' 
			else if ($prev.hit/ancestor::archdesc ) then '2' 
			else if ($prev.hit/ancestor::frontmatter) then '1' 
			else '0' " />
<xsl:variable name="this.hit.section"  select="if ( $this.hit/ancestor::dsc)  then '3' 
			else if ($this.hit/ancestor::archdesc ) then '2' 
			else if ($this.hit/ancestor::frontmatter ) then '1' 
			else '1' " />
<xsl:variable name="next.hit.section" select="if ( $next.hit/ancestor::dsc)  then '3' 
			else if ($next.hit/ancestor::archdesc ) then '2' 
			else if ($next.hit/ancestor::frontmatter) then '1' 
			else '0' " />
<xsl:variable name="prev.hit.pageStart" select="if ($prev.hit.section = '3') then floor($prev.hit/ancestor::*[@C-ORDER][1]/@C-ORDER div 2500) * 2500 + 1 else ('1')"/>
<xsl:variable name="this.hit.pageStart" select="if ($this.hit.section = '3') then floor($this.hit/ancestor::*[@C-ORDER][1]/@C-ORDER div 2500) * 2500 + 1 else ('1')"/>
<xsl:variable name="next.hit.pageStart" select="if ($this.hit.section = '3') then floor($next.hit/ancestor::*[@C-ORDER][1]/@C-ORDER div 2500) * 2500 + 1 else ('1')"/>

<!-- xsl:value-of select="key('hit-num-dynamic', string($this.hitNum - 1))"/ -->


<!-- xsl:variable name="http.query" select="substring-after($http.URL,'?')"/ -->

<xsl:variable name="prev.hit.base">
	<xsl:choose>
		<!-- dsc to admin -->
		<xsl:when test="$view = 'dsc' and number($prev.hit.section) = 2 ">
		<xsl:text>/view?</xsl:text>
		<xsl:value-of select="editURL:remove(editURL:set($http.query,'view','admin'),'dsc.position')"/>
		</xsl:when>
		<!-- dsc paging -->
		<xsl:when test="$view = 'dsc' and number($this.hit.pageStart) ne number($prev.hit.pageStart)">
		<xsl:text>/view?</xsl:text>
		<xsl:value-of select="editURL:set($http.query,'dsc.position',$prev.hit.pageStart)"/>
		</xsl:when>
		<xsl:otherwise/>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="next.hit.base">
	<xsl:choose>
		<!-- from admin to dsc -->
		<xsl:when test="$view = 'admin' and number($next.hit.section )= 3 and $next.hit.pageStart = '1'">
		<xsl:text>/view?</xsl:text>
		<xsl:value-of select="editURL:set($http.query,'view','dsc')"/>
		</xsl:when>
		<!-- dsc paging -->
		<xsl:when test="( $view = 'admin' and number($next.hit.section )= 3 )
				or ( $view='dsc' and $this.hit.pageStart ne $next.hit.pageStart )">
		<xsl:text>/view?</xsl:text>
		<xsl:value-of select="editURL:set(editURL:set($http.query,'view','dsc'),
						'dsc.position',$next.hit.pageStart)"/>
		</xsl:when>
		<xsl:otherwise/>
	</xsl:choose>
</xsl:variable>

<xsl:if test="	( ($this.hit.section eq $prev.hit.section and $this.hit.pageStart eq $prev.hit.pageStart) 
			or $doc.view='entire_text' and number($prev.hit.section) &gt; 0 
		) 
		or ( $prev.hit.base != '')
		">
  	<xsl:call-template name="prev.hit">
		<xsl:with-param name="base" select="$prev.hit.base"/>
	</xsl:call-template>
</xsl:if>

  <xsl:choose>
    <xsl:when test="xtf:term">
      <span id="hitNum{@hitNum}" class="hitsection">
        <xsl:apply-templates mode="ead"/>
      </span>
    </xsl:when>
    <xsl:otherwise>
      <span id="hitNum{@hitNum}" class="hit">
          <xsl:apply-templates mode="ead"/>
      </span>
    </xsl:otherwise>
  </xsl:choose>

<xsl:if test="	( ($this.hit.section eq $next.hit.section ) 
			or $doc.view='entire_text' and number($next.hit.section) &gt; 0 
		) 
		or ( $next.hit.base != '')
		">
    <xsl:call-template name="next.hit">
		<xsl:with-param name="base" select="$next.hit.base"/>
    </xsl:call-template>
</xsl:if>
</xsl:template>

<xsl:template match="xtf:more" mode="ead">

  <span class="hitsection">
    <xsl:apply-templates mode="ead"/>
  </span>

  <!-- xsl:if test="not(@more='yes')">
    <xsl:call-template name="next.hit"/>
  </xsl:if -->

</xsl:template>

<xsl:template match="xtf:term" mode="ead">
    <span class="subhit">
      <xsl:apply-templates mode="ead"/>
    </span>
</xsl:template>


<xsl:template name="prev.hit">
	<xsl:param name="base"/>
	<xsl:variable name="num" select="@hitNum"/>
	<a>
		<xsl:attribute name="href">
			<xsl:value-of select="$base"/>
			<xsl:text>#hitNum</xsl:text>
			<xsl:value-of select="$num -1"/>
		</xsl:attribute>
		<img src="/images/misc/b_inprev.gif" border="0" alt="previous hit"/>
	</a>
</xsl:template>

<xsl:template name="next.hit">
	<xsl:param name="base"/>
	<xsl:variable name="num" select="@hitNum"/>
	<xsl:variable name="next" select="$num + 1"/>
	<a>
		<xsl:attribute name="href">
			<xsl:value-of select="$base"/>
			<xsl:text>#hitNum</xsl:text>
			<xsl:value-of select="$next"/>
		</xsl:attribute>
		<img src="/images/misc/b_innext.gif" border="0" alt="next hit"/>
	</a>
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

