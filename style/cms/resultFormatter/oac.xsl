<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<xsl:output method="html" media-type="text/html"/>
<!-- thanks Eric van der Vlist 
http://www.xml.com/pub/a/2000/07/26/xslt/xsltstyle.html 
-->



<xsl:variable name="page" select="/"/>
<xsl:variable name="layout" select="document('OACresults-thumbnails.html')"/>

<xsl:template match="/">
    <xsl:apply-templates select="$layout/html"/>
</xsl:template>

<xsl:template match="nbsp">
        <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="copy">
        <xsl:text disable-output-escaping='yes'><![CDATA[&copy;]]></xsl:text>
</xsl:template>

<xsl:template match="insert-SearchResults">
    <!-- Get the body here -->
        <xsl:apply-templates select="$page/SearchResults" mode="sr" />
</xsl:template>

<xsl:template match="insert-finding-aid-title">
        <xsl:apply-templates select="$page/SearchResults/parent/qdc" mode="fa-title" />
</xsl:template>

<xsl:template match="insert-suggest">
<xsl:if test="$page/SearchResults/Query/term/suggest">
<form method="GET" action="/">
<input type="hidden" name="relation" value="oac.cdlib.org"/>
<input type="hidden" name="mode" value="content"/>
You may have misspelled something.<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
        Did you mean: <xsl:apply-templates select="$page/SearchResults/Query/term" mode="sr" />
<input type="submit" name="" value="use this spelling"/>
        </form>
</xsl:if>
</xsl:template>

<xsl:template match="insert-Query">
        <xsl:apply-templates select="$page/SearchResults/Query" mode="form" />
        <!-- <xsl:apply-templates select="$page/SearchResults/Query/word[@index != 'relation' and @index !='type']" mode="sr" />-->
</xsl:template>

<xsl:template match="insert-previous"> 
        <xsl:apply-templates select="$page/SearchResults/previous" mode="sr" />
</xsl:template>

<xsl:template match="insert-next">
        <xsl:apply-templates select="$page/SearchResults/next" mode="sr" />
</xsl:template>

<xsl:template match="insert-SearchSummary">
        <xsl:apply-templates select="$page/SearchResults" mode="summary" />
</xsl:template>

<xsl:template match="insert-Fisheye">
<xsl:if test="(count($page/SearchResults/page) &gt; 1) or (number($page/SearchResults/page/@n) &gt; 1)"> 
        More Results Pages:
        <xsl:apply-templates select="$page/SearchResults/previousGroup" mode="sr" />
        <xsl:apply-templates select="$page/SearchResults/page" mode="sr" />
        <xsl:apply-templates select="$page/SearchResults/nextGroup" mode="sr" />
</xsl:if>
</xsl:template>



<xsl:template match="@*|*">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>

<xsl:template match='*' mode="sr">
        <xsl:choose>
                <xsl:when test="name()='type' and  (
								starts-with(text(),'image') or
								starts-with(text(),'facsimile')
								) ">

<a href="{../identifier}"><img src="{../identifier}/thumbnail" alt="[thumbnail]" border="0"/></a>
                </xsl:when>
                <xsl:when test="name()='type' and starts-with(text(),'item')">
<a href="{../identifier}"><img src="{../identifier}/thumbnail" alt="[thumbnail]" border="0"/></a>
                </xsl:when>
                <xsl:otherwise>
<dt><font color="silver"><xsl:value-of select="name()"/></font></dt>
<dd><xsl:apply-templates/></dd>
                </xsl:otherwise>
        </xsl:choose>
</xsl:template>

<xsl:template match="term" mode="sr">
<select name="search">
<xsl:choose>
<xsl:when test="suggest"><xsl:apply-templates mode="sr"/></xsl:when>
<xsl:otherwise><option><xsl:value-of select="@word"/></option></xsl:otherwise>
</xsl:choose>
</select>
</xsl:template>

<xsl:template match="suggest" mode="sr">
<option><xsl:apply-templates/></option>
</xsl:template>

<xsl:template match="qdc" mode="fa-title">
<h1><a href="{identifier}"><xsl:value-of select="title"/></a>: Search Results</h1>
</xsl:template>

<xsl:template match="qdc" mode="sr">
<tr>

<td valign="top" align="center">

<xsl:apply-templates select="type" mode="sr"/>

</td>
<td>
<xsl:apply-templates select="title | subject.series" mode="sr"/>
<br /><xsl:if test="subject">Subjects
<xsl:apply-templates select="subject" mode="sr"/>
</xsl:if>
</td>
</tr>
      <tr><td colspan="2"></td></tr>
      <tr>
        <td colspan="2"><hr noshade="noshade" /></td>
      </tr>
</xsl:template>

<xsl:template match="SearchResults" mode="sr">

<table border="0" width="100%">
<xsl:choose>
        <xsl:when test="qdc">
    <xsl:apply-templates select="qdc" mode="sr"/>
        </xsl:when>
        <xsl:otherwise>
        <tr><td><p class="directions">Helpful hints to improve your results: 
      <ul>
        <span class="help"> Try simple and direct words (example: if you want 
        to see pictures of squirrels use &quot;squirrel&quot; and not &quot;rodent&quot;) 
        <br/>
        If you want more results, try a broader word (example:try &quot;animal&quot; 
        not &quot;squirrel&quot;)<br/>
</span>
      </ul>
        </p></td></tr>
        </xsl:otherwise>
</xsl:choose>

</table>
</xsl:template>

<xsl:template match="SearchResults" mode="summary">
Displaying <font color="#000000"><xsl:value-of select="@start"/> - <xsl:value-of select="@end"/></font> of <xsl:value-of select="@hits"/> images
</xsl:template>


<xsl:template match="previous" mode="sr">
<a href="{.}"><img src="/images/previous.gif" width="72" height="22" border="0" alt="&lt;&lt; previous" class="prevNextButton" align="middle"/></a><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="next" mode="sr">
<a href="{.}"><img src="/images/next.gif" width="51" height="22" border="0" alt="next &gt;&gt;" class="prevNextButton" align="middle"/></a>
</xsl:template>

<xsl:template match="previousGroup" mode="sr">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text> <a href="{.}">&lt;&lt;</a> <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="nextGroup" mode="sr">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text> <a href="{.}">&gt;&gt;</a> <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="page" mode="sr">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
<!-- <xsl:text disable-output-escaping='yes'>&nbsp;</xsl:text> -->
<xsl:choose>
        <xsl:when test="text()">
                <a href="{.}"><xsl:value-of select="@n"/></a> 
        </xsl:when>
        <xsl:otherwise>
                <xsl:value-of select="@n"/>
        </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="Query" mode="hits">
</xsl:template>

<xsl:template match="Query" mode="form">
<form name="refine" method="GET" action="/">
<input type="hidden" name="mode" value="content"/>
<xsl:apply-templates select="word" mode="form"/>
<input type="image" src="/images/goto.gif" border="0" align="middle"/>
</form>
</xsl:template>

<xsl:template match="word" mode="form">
<xsl:choose>
<xsl:when test="@index='search'">
<input name="{@index}" value="{text()}"/>
</xsl:when>
<xsl:otherwise>
<input type="hidden" name="{@index}" value="{text()}"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="word" mode="sr">
<xsl:apply-templates select="text()"/>
</xsl:template>

<xsl:template match="mode" mode="sr">
</xsl:template>


<xsl:template match="subject" mode="sr">
| <a href="?relation=oac.cdlib.org;mode=content;search={.}">
<xsl:value-of select="."/></a>
</xsl:template>

<xsl:template match="relation.ispartof[2]" mode="sr">
<dt><font color="silver"><xsl:value-of select="name()"/></font></dt>
    <dd><a href="{.}"><xsl:value-of select="."/></a></dd>
</xsl:template>

<xsl:template match="relation.ispartof[1]" mode="sr">
</xsl:template>


<xsl:template match="title[1]" mode="sr">
    <a href="{../identifier[1]}"><xsl:value-of select="."/></a>
</xsl:template>

<xsl:template match="subject.series[1]" mode="sr">
        <xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text><br /> from <a href="{../relation.ispartof[1]}"><xsl:value-of select="."/></a>
</xsl:template>

<xsl:template match="subject.series[position() &gt; 1]" mode="sr">
        -- <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="identifier" mode="sr">
</xsl:template>

<xsl:template match="relation.ispartof[2]" mode="sr">
<dt><font color="silver"><xsl:value-of select="name()"/></font></dt>
        <dd><a href="{.}"><xsl:value-of select="."/></a></dd>
</xsl:template>

<xsl:template match="relation.ispartof[1]" mode="sr">
</xsl:template>

</xsl:stylesheet>

