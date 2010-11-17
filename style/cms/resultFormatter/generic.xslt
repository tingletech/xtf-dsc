<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<xsl:output method="html" media-type="text/html" />
<!-- thanks Eric van der Vlist 
http://www.xml.com/pub/a/2000/07/26/xslt/xsltstyle.html 
-->
<xsl:output method="html" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

<xsl:variable name="page" select="/"/>
<xsl:variable name="layout" select="document('simplify.html')"/>

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
<input type="hidden" name="relation" value="findaid.oac.cdlib.org"/>
<input type="hidden" name="type" value="image"/>
<input type="hidden" name="xslt" value="thumbnails"/>
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

<xsl:template match="insert-Tabs"> 
<!-- 
<div class="tab-selected" id="tab-pos1">
All
</div> 

<div class="tab" id="tab-pos2">
Images
</div>

<div class="tab" id="tab-pos3">
Statistics
</div>

<div class="tab" id="tab-pos4">
Texts
</div>

<div class="tab" id="tab-pos5">
Collections
</div>
-->
<p>
<xsl:apply-templates select="$page/SearchResults/type" mode="tabs" /> 
</p> 
</xsl:template>

<xsl:template match="insert-previous"> 
	<xsl:apply-templates select="$page/SearchResults/previous" mode="sr" />
</xsl:template>

<xsl:template match="insert-Css">
<style type="text/css"><xsl:text disable-output-escaping='yes'><![CDATA[
@import "/css/publicdl.css";
]]></xsl:text>
</style>
</xsl:template>

<xsl:template match="insert-next">
	<xsl:apply-templates select="$page/SearchResults/next" mode="sr" />
</xsl:template>

<xsl:template match="insert-SearchSummary">
	<xsl:apply-templates select="$page/SearchResults" mode="summary" />
</xsl:template>

<xsl:template match="insert-SummaryShort">
	<xsl:apply-templates select="$page/SearchResults" mode="Summary1" />
</xsl:template>

<xsl:template match="insert-SearchForm">
	<xsl:apply-templates select="$page/SearchResults" mode="Form" />
</xsl:template>

<xsl:template match="insert-PagenationShort">
<xsl:apply-templates select="$page/SearchResults" mode="PagenationShort" />
</xsl:template>

<xsl:template match="insert-PagenationMore">
<xsl:apply-templates select="$page/SearchResults" mode="PagenationMore" />
</xsl:template>

<xsl:template match="insert-Fisheye">
<xsl:if test="(count($page/SearchResults/page) &gt; 1) or (number($page/SearchResults/page/@n) &gt; 1)"> 
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

<xsl:template match='*' mode="metadata-def">
<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
<span class="label">
<xsl:value-of select="name()"/></span>:
<span class="{name()}">
<xsl:value-of select="text()"/></span>
</xsl:template>

<xsl:template match="term" mode="sr">
<select name="search"><xsl:apply-templates mode="sr"/></select>
</xsl:template>

<xsl:template match="suggest" mode="sr">
<option><xsl:apply-templates/></option>
</xsl:template>

<xsl:template match="qdc" mode="sr">
<p>
<span
class="item-out">
<xsl:value-of select="/SearchResults/@start + position() - 1"/>.
</span>

<span class="item-in">
<xsl:apply-templates select="title" mode="metadata-l1" />
<xsl:apply-templates select="creator" mode="metadata-l1"/> 
<!-- <xsl:apply-templates select="description | subject" mode="metadata-l2"/>
-->
<xsl:apply-templates select="subject.series[1]" mode="metadata"/> 
<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
<xsl:apply-templates select="date" mode="metadata"/> 
<xsl:apply-templates select="description" mode="metadata"/>
<xsl:apply-templates select="subject | subject.lcsh" mode="metadata"/>
<xsl:apply-templates select="identifier | relation.ispartof" mode="metadata"/>
<xsl:apply-templates select="*" mode="metadata-def"/>
</span>
</p>
</xsl:template>

<xsl:template match="subject | subject.lcsh | description | title | creator 
	| date | type | identifier | relation.ispartof | subject.series" mode="metadata-def">
</xsl:template>

<xsl:template match="date" mode="metadata">
<xsl:value-of select="."/> -
</xsl:template>

<xsl:template match="relation.ispartof" mode="metadata">
<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
Is Part Of <a href="{.}"><xsl:value-of select="."/></a>
</xsl:template>
<xsl:template match="identifier" mode="metadata">
<xsl:text disable-output-escaping='yes'><![CDATA[<br />]]></xsl:text>
URL: <a href="{.}"><xsl:value-of select="."/></a>
</xsl:template>


<xsl:template match="SearchResults" mode="sr">
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

</xsl:template>

<xsl:template match="SearchResults" mode="summary">
Displaying <font color="#000000"><xsl:value-of select="@start"/> - <xsl:value-of select="@end"/></font> of <xsl:value-of select="@hits"/> images
</xsl:template>

<xsl:template match="SearchResults" mode="PagenationShort">
<xsl:value-of select="@start"/> - <xsl:value-of select="@end"/> 
</xsl:template>

<xsl:template match="SearchResults" mode="PagenationMore">
<xsl:if test="next"><xsl:text disable-output-escaping='yes'><![CDATA[ ]]></xsl:text><a class="onpage" href="#morePages">[more pages?]</a>
</xsl:if>
</xsl:template>

<xsl:template match="SearchResults" mode="Form">
	<xsl:apply-templates select="Query" mode="Form"/>
</xsl:template>


<xsl:template match="Query" mode="Form">
<form action="/" method="GET">
<xsl:apply-templates mode="Form"/>
<input type="image" src="/images/goto.gif" border="0" align="middle"/>
</form>
</xsl:template>

<xsl:template match="core" mode="Form">
</xsl:template>

<xsl:template match="word" mode="Form">
<xsl:variable name="realIndex">
<xsl:choose>
	<xsl:when test="../core">
		<xsl:value-of select="../core"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="@index"/>
	</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:value-of select="$realIndex"/> = <input name="{$realIndex}" value="{text()}"/>
</xsl:template>


<xsl:template match="SearchResults" mode="Summary1">
search for 
<em><xsl:apply-templates select="Query" mode="Summary1"/></em>
found <xsl:value-of select="@hits"/> resources
</xsl:template>

<xsl:template match="Query" mode="Summary1">
	<xsl:apply-templates select="mode" mode="Summary1"/>
	<xsl:apply-templates select="word" mode="Summary1"/>
</xsl:template>

<xsl:template match="word" mode="Summary1">
<xsl:if test="@index != 'search'">
	<xsl:value-of select="@index"/>=
</xsl:if>
	<xsl:apply-templates mode="Summary1"/>
</xsl:template>

<xsl:template match="mode" mode="Summary1">
	<xsl:if test="text()">
<xsl:value-of select="text()"/> =
	</xsl:if>
</xsl:template>


<xsl:template match="previous" mode="sr">
<a href="{.}"><img src="/images/previous.gif" width="72" height="22" border="0" alt="&lt;&lt; previous" class="prevNextButton" align="middle"/></a><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="next" mode="sr">
<a href="{.}"><img src="/images/next.gif" width="51" height="22" border="0" alt="next &gt;&gt;" class="prevNextButton" align="middle"/></a><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="previousGroup" mode="sr">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text> <a href="{.}">&lt;&lt;</a> <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="nextGroup" mode="sr">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text> <a href="{.}">&gt;&gt;</a> <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template match="type" mode="tabs">
| <xsl:value-of select="text()"/> (<xsl:value-of select="@count"/>)
</xsl:template>


<xsl:template match="page" mode="sr">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text> 
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
<input type="hidden" name="xslt" value="thumbnails"/>
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
</xsl:template>

<xsl:template match="description" mode="metadata">
<span class="description"> <xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="subject | subject.lcsh" mode="metadata">
| <a href="?mode=publicdl;search={.}">
<xsl:value-of select="."/></a>
</xsl:template>


<!-- <xsl:template match="subject.lcsh" mode="metadata">
</xsl:template>
-->

<xsl:template match="relation.ispartof[2]" mode="sr">
<dt><font color="silver"><xsl:value-of select="name()"/></font></dt>
    <dd><a href="{.}"><xsl:value-of select="."/></a></dd>
</xsl:template>

<xsl:template match="relation.ispartof[1]" mode="sr">
</xsl:template>


<xsl:template match="title[1]" mode="metadata">
</xsl:template>

<xsl:template match="creator" mode="metadata">
</xsl:template>

<xsl:template match="title[1]" mode="metadata-l1">
<a class="title" href="{../identifier[1]}"><xsl:value-of select="."/></a>
</xsl:template>
<xsl:template match="creator" mode="metadata-l1">
<span class="creator"> - <xsl:value-of select="."/></span>
</xsl:template>

<xsl:template match="subject.series[1]" mode="metadata">
- <a href="{../relation.ispartof[1]}"><xsl:value-of select="."/></a>
</xsl:template>

<xsl:template match="identifier" mode="sr">
</xsl:template>

<!-- <xsl:template match="identifier | relation.ispartof" mode="metadata">
<tr><td class="label"><xsl:value-of select="name()"/></td>
	<td><a href="{.}"><xsl:value-of select="."/></a></td>
</tr>
</xsl:template> -->

<xsl:template match="relation.ispartof[1]" mode="sr">
</xsl:template>

</xsl:stylesheet>
