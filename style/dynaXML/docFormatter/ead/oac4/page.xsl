<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xtf="http://cdlib.org/xtf"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">

<!-- indexed by item.position value. calculate other values from this -->
<xsl:template name="pagination">
<!-- ported from LibCDL::SearchResults -->
<xsl:param name="base"/>
<xsl:param name="docId"/>
<xsl:param name="pageStart">1</xsl:param>
<xsl:param name="pageSize">50</xsl:param>
<xsl:param name="hits"/>
<xsl:param name="mode" select="'items'"/>
<!-- Setup variable values needed for pagination -->
<xsl:variable name="page" 
	select="floor($pageStart div $pageSize ) +1"/>
<xsl:variable name="num-pages"
    select="floor($hits div $pageSize) + 1"/>

<xsl:variable name="pageEnd">
    <xsl:choose>
        <xsl:when test="($pageStart+$pageSize) &gt; $hits">
            <xsl:value-of select="$hits"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="($pageStart+$pageSize)-1"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:variable name="pageStart-last">
    <xsl:if test="($pageStart - 1 + $pageSize) &lt; $hits">
        <xsl:value-of select="(floor(($hits div $pageSize))*$pageSize + 1)"/>
    </xsl:if>
</xsl:variable>
<xsl:variable name="pageStart-first">
    <xsl:if test="$pageStart != 1">
        <xsl:value-of select="1"/>
    </xsl:if>
</xsl:variable>

<xsl:variable name="previous">
  <xsl:if test="$pageStart &gt; $pageSize">
	<xsl:value-of select="$pageStart - $pageSize"/>
  </xsl:if> 
</xsl:variable>
<xsl:variable name="next">
  <xsl:if test="($pageStart -1 + $pageSize) &lt; $hits">
	<xsl:value-of select="$pageStart + $pageSize"/>
  </xsl:if> 
</xsl:variable>

<div class="pagination-hdr">
    <table>
        <tr>
            <td><span class="pagination-item">
		<xsl:if test="$mode='items'">
                    <xsl:value-of select="$pageStart"/> -
                    <xsl:value-of select="$pageEnd"/> of
                    <xsl:value-of select="$hits"/> results
		</xsl:if>
		<xsl:if test="$mode='dsc'">
                    <xsl:value-of select="$page"/> of
                    <xsl:value-of select="$num-pages"/> pages
		</xsl:if>
            </span></td> 
          <td><span class="pagination-item">
                  <form action="{$base}" id="results-page">
                      <span class="caption">Results page: </span>
                      <input xmlns="http://www.w3.org/1999/xhtml" type="hidden"
                          name="docId" value="{$docId}" />
                      <input xmlns="http://www.w3.org/1999/xhtml" type="hidden"
                        name="{if ($mode='items') then 'doc.' else ''}view" value="{$mode}" />
                    <input xmlns="http://www.w3.org/1999/xhtml"
    type="hidden" name="style" value="oac4" />

<xsl:if test="$doc.view='entire_text'">
	<input type="hidden" name="doc.view" value="entire_text" />
</xsl:if>

<!-- call templates for various controls -->
    <xsl:choose>
        <xsl:when test="$pageStart-first = ''">
            <span>|&lt;&lt;</span>
        </xsl:when>
        <xsl:otherwise>
            <a href="{$base}1">|&lt;&lt;</a>
        </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
        <xsl:when test="$previous = ''">
            <span>Previous</span>
        </xsl:when>
        <xsl:otherwise>
        <a href="{$base}{$previous}">Previous</a>
        </xsl:otherwise>
    </xsl:choose>
    
<!-- select page form option set -->
<select name="{if ($mode eq 'items') then 'item' else ($mode)}.position" onchange="this.form.submit();">
    <xsl:for-each select="1 to xs:integer($num-pages)">
        <xsl:variable name="optPage" select="position()"/>
        <xsl:variable name="optPageStart"
            select="xs:integer((($optPage)-1)*$pageSize + 1)"/>
        <xsl:choose>
            <xsl:when test="position() = $page">
                <option value="{$optPageStart}" selected="true" >
                    <xsl:value-of select="$optPage"/>
                </option>
            </xsl:when>
            <xsl:otherwise>
                <option value="{$optPageStart}" >
                    <xsl:value-of select="$optPage"/>
                </option>
            </xsl:otherwise>
        </xsl:choose>

        </xsl:for-each>
</select>
	<input type="submit" value="go" class="go-hide"/>
    <xsl:choose>
        <xsl:when test="$next = ''">
            <span>Next</span>
        </xsl:when>
        <xsl:otherwise>
        <a href="{$base}{$next}">Next</a>
        </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
        <xsl:when test="$pageStart-last = ''">
            <span>&gt;&gt;|</span>
        </xsl:when>
        <xsl:otherwise>
            <a href="{$base}{$pageStart-last}">&gt;&gt;|</a>
        </xsl:otherwise>
    </xsl:choose>
    <!--
<xsl:call-template name="first"/>
<xsl:call-template name="previous"/>
<xsl:call-template name="page-select"/>
<xsl:call-template name="next"/>
<xsl:call-template name="last"/>
-->

</form>
</span>
</td>
</tr>
</table>
</div>

</xsl:template>

</xsl:stylesheet>
