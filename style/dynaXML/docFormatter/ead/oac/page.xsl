<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:xtf="http://cdlib.org/xtf">

<xsl:template name="pagination">
<!-- ported from LibCDL::SearchResults -->
<xsl:param name="base"/>
<xsl:param name="start">1</xsl:param>
<xsl:param name="pageSize">50</xsl:param>
<xsl:param name="hits"/>
<xsl:variable name="page" 
	select="floor(($start div $pageSize ) +1)"/>
<xsl:variable name="group">
  <xsl:choose>
    <xsl:when test="(($start -1) mod ($pageSize * 10)) = 0 ">
	<xsl:value-of select="floor((($start - $pageSize) div ( $pageSize * 10)) +1) +1"/>
    </xsl:when>
    <xsl:otherwise>
	<xsl:value-of select="floor(($start - $pageSize) div ( $pageSize * 10)) + 1"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<!-- xsl:variable name="last-group" 
	select="floor(($hits - $pageSize) div ( $pageSize * 10))"/ -->
<xsl:variable name="page-in-group" 
	select="$page - ( $group - 1) * 10"/>
<xsl:variable name="page-one" 
	select="($group - 1) * 10 * $pageSize"/>
<xsl:variable name="previousGroup">
  <xsl:if test="$group &gt; 1">
	<xsl:value-of select="($group - 2) * 10 * $pageSize +1"/>
  </xsl:if> 
</xsl:variable>
<xsl:variable name="nextGroup">
  <!-- xsl:if test="$group != $last-group and ($group*10*$pageSize+1) &lt; $hits" -->
  <xsl:if test="($group*10*$pageSize+1) &lt; $hits">
	<xsl:value-of select="($group) * 10 * $pageSize + 1"/>
  </xsl:if> 
</xsl:variable>
<xsl:variable name="previous">
  <xsl:if test="$start &gt; $pageSize">
	<xsl:value-of select="$start - $pageSize"/>
  </xsl:if> 
</xsl:variable>
<xsl:variable name="next">
  <xsl:if test="($start -1 + $pageSize) &lt; $hits">
	<xsl:value-of select="$start + $pageSize"/>
  </xsl:if> 
</xsl:variable>

<!-- p>page: <xsl:value-of select="$page"/></p>
<p>group: <xsl:value-of select="$group"/></p>
<p>page-in-group: <xsl:value-of select="$page-in-group"/></p>
<p>previous: <xsl:value-of select="$previous"/></p>
<p>previousGroup: <xsl:value-of select="$previousGroup"/></p>
<p>next: <xsl:value-of select="$next"/></p>
<p>nextGroup: <xsl:value-of select="$nextGroup"/>
<p>page 10: <xsl:value-of select="($group -1)*10+10"/></p>
</p -->


<xsl:if test="$previous != ''">
<a href="{$base}{$previous}{$brandCgi}">
<img src="http://www.oac.cdlib.org/images/previous.gif" width="72" height="22" border="0" alt="&lt;&lt; previous" class="prevNextButton" align="middle"/></a>
</xsl:if>

<xsl:if test="$previousGroup != ''">
<xsl:text> </xsl:text>
 <a href="{$base}{$previousGroup}{$brandCgi}">&lt;&lt;</a> 
</xsl:if>

<xsl:variable name="page01" select="($group -1)*10+1"/>
<xsl:variable name="page02" select="($group -1)*10+2"/>
<xsl:variable name="page03" select="($group -1)*10+3"/>
<xsl:variable name="page04" select="($group -1)*10+4"/>
<xsl:variable name="page05" select="($group -1)*10+5"/>
<xsl:variable name="page06" select="($group -1)*10+6"/>
<xsl:variable name="page07" select="($group -1)*10+7"/>
<xsl:variable name="page08" select="($group -1)*10+8"/>
<xsl:variable name="page09" select="($group -1)*10+9"/>
<xsl:variable name="page10" select="($group -1)*10+10"/>

<xsl:if test="($group -1)*10+1 &lt;= ceiling($hits div $pageSize)">
<xsl:text> </xsl:text>
 <xsl:choose>
	<xsl:when test="$page-in-group = 1">
		<xsl:value-of select="($group -1)*10+1 "/>
	</xsl:when>
	<xsl:otherwise>
		<a href="{$base}{($page01 -1) * $pageSize + 1}{$brandCgi}"><xsl:value-of select="($group -1)*10+1 "/></a>
	</xsl:otherwise>
 </xsl:choose>
</xsl:if>

<xsl:if test="($group -1)*10+2 &lt;= ceiling($hits div $pageSize)">
<xsl:text> </xsl:text>
 <xsl:choose>
	<xsl:when test="$page-in-group = 2">
		<xsl:value-of select="($group -1)*10+2 "/>
	</xsl:when>
	<xsl:otherwise>
		<a href="{$base}{($page02 -1 ) * $pageSize + 1}{$brandCgi}"><xsl:value-of select="($group -1)*10+2 "/></a>
	</xsl:otherwise>
 </xsl:choose>
</xsl:if>

<xsl:if test="($group -1)*10+3 &lt;= ceiling($hits div $pageSize)">
<xsl:text> </xsl:text>
 <xsl:choose>
	<xsl:when test="$page-in-group = 3">
		<xsl:value-of select="($group -1)*10+3 "/>
	</xsl:when>
	<xsl:otherwise>
		<a href="{$base}{($page03 -1 ) * $pageSize + 1}{$brandCgi}"><xsl:value-of select="($group -1)*10+3 "/></a>
	</xsl:otherwise>
 </xsl:choose>
</xsl:if>

<xsl:if test="($group -1)*10+4 &lt;= ceiling($hits div $pageSize)">
<xsl:text> </xsl:text>
 <xsl:choose>
	<xsl:when test="$page-in-group = 4">
		<xsl:value-of select="($group -1)*10+4 "/>
	</xsl:when>
	<xsl:otherwise>
		<a href="{$base}{($page04 -1 ) * $pageSize + 1}{$brandCgi}"><xsl:value-of select="($group -1)*10+4 "/></a>
	</xsl:otherwise>
 </xsl:choose>
</xsl:if>

<xsl:if test="($group -1)*10+5 &lt;= ceiling($hits div $pageSize)">
<xsl:text> </xsl:text>
 <xsl:choose>
	<xsl:when test="$page-in-group = 5">
		<xsl:value-of select="($group -1)*10+5 "/>
	</xsl:when>
	<xsl:otherwise>
		<a href="{$base}{($page05 -1 ) * $pageSize + 1}{$brandCgi}"><xsl:value-of select="($group -1)*10+5 "/></a>
	</xsl:otherwise>
 </xsl:choose>
</xsl:if>

<xsl:if test="($group -1)*10+6 &lt;= ceiling($hits div $pageSize)">
<xsl:text> </xsl:text>
 <xsl:choose>
	<xsl:when test="$page-in-group = 6">
		<xsl:value-of select="($group -1)*10+6 "/>
	</xsl:when>
	<xsl:otherwise>
		<a href="{$base}{($page06 -1 ) * $pageSize + 1}{$brandCgi}"><xsl:value-of select="($group -1)*10+6 "/></a>
	</xsl:otherwise>
 </xsl:choose>
</xsl:if>

<xsl:if test="($group -1)*10+7 &lt;= ceiling($hits div $pageSize)">
<xsl:text> </xsl:text>
 <xsl:choose>
	<xsl:when test="$page-in-group = 7">
		<xsl:value-of select="($group -1)*10+7 "/>
	</xsl:when>
	<xsl:otherwise>
		<a href="{$base}{($page07 -1 ) * $pageSize + 1}{$brandCgi}"><xsl:value-of select="($group -1)*10+7 "/></a>
	</xsl:otherwise>
 </xsl:choose>
</xsl:if>

<xsl:if test="($group -1)*10+8 &lt;= ceiling($hits div $pageSize)">
<xsl:text> </xsl:text>
 <xsl:choose>
	<xsl:when test="$page-in-group = 8">
		<xsl:value-of select="($group -1)*10+8 "/>
	</xsl:when>
	<xsl:otherwise>
		<a href="{$base}{($page08 -1 ) * $pageSize + 1}{$brandCgi}"><xsl:value-of select="($group -1)*10+8 "/></a>
	</xsl:otherwise>
 </xsl:choose>
</xsl:if>

<xsl:if test="($group -1)*10+9 &lt;= ceiling($hits div $pageSize)">
<xsl:text> </xsl:text>
 <xsl:choose>
	<xsl:when test="$page-in-group = 9">
		<xsl:value-of select="($group -1)*10+9 "/>
	</xsl:when>
	<xsl:otherwise>
		<a href="{$base}{($page09 -1 ) * $pageSize + 1}{$brandCgi}"><xsl:value-of select="($group -1)*10+9 "/></a>
	</xsl:otherwise>
 </xsl:choose>
</xsl:if>

<xsl:if test="($group -1)*10+10 &lt;= ceiling($hits div $pageSize)">
<xsl:text> </xsl:text>
 <xsl:choose>
	<xsl:when test="$page-in-group = 10">
		<xsl:value-of select="($group -1)*10+10 "/>
	</xsl:when>
	<xsl:otherwise>
		<a href="{$base}{($page10 -1 ) * $pageSize + 1}{$brandCgi}"><xsl:value-of select="($group -1)*10+10 "/></a>
	</xsl:otherwise>
 </xsl:choose>
</xsl:if>

<xsl:if test="$nextGroup != ''">
<xsl:text> </xsl:text>
 <a href="{$base}{$nextGroup}{$brandCgi}">&gt;&gt;</a> 
</xsl:if>

<xsl:if test="$next != ''">
<xsl:text> </xsl:text>
<a href="{$base}{$next}{$brandCgi}">
<img src="http://www.oac.cdlib.org/images/next.gif" width="51" height="22" border="0" alt="next &gt;&gt;" class="prevNextButton" align="middle"/></a>
</xsl:if>


</xsl:template>

</xsl:stylesheet>
