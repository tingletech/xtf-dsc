<xsl:stylesheet version="1.1"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<xsl:output method="html" media-type="text/html" />
<!-- thanks Eric van der Vlist 
http://www.xml.com/pub/a/2000/07/26/xslt/xsltstyle.html 
-->
<xsl:variable name="start" select="SearchResults/@start"/>
<xsl:variable name="search" select="SearchResults/Query/word"/>
<xsl:variable name="indextosearch" select="SearchResults/Query/word/@index"/>

<!-- this is how to grab a parameter passed to the stylesheet -->
<xsl:param name="nrights"></xsl:param>
<xsl:variable name="public">
<xsl:value-of select="$nrights"/>
</xsl:variable>

<xsl:param name="display"></xsl:param>
<xsl:variable name="style">
<xsl:value-of select="$display"/>
</xsl:variable>

<xsl:param name="pageSize">20</xsl:param>
<xsl:variable name="page">
  <xsl:value-of select="$pageSize"/>
</xsl:variable>

<xsl:template match="/">
<xsl:choose>
<xsl:when test="SearchResults/qdc">
<xsl:call-template name="results"/>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="noresults"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="noresults">

<html>
  <head>
    <title>UC Press Book Description Search</title>
<link rel="stylesheet" type="text/css" 
href="http://texts.cdlib.org/styles/escholarship-editions.css"/> 
</head>
<body>

<!-- BEGIN OUTER LAYOUT TABLE -->
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<!-- BEGIN HEADER ROW -->
<map name="header_left" id="header_left">
<area shape="rect" coords="23,13,314,58" 
href="http://texts.cdlib.org/escholarship/" />
</map>
<map name="header_right" id="header_right">
<area shape="rect" coords="347,16,393,61" href="http://www.cdlib.org/" 
alt="CDL" />
</map>
<tr width="100%">
<td class="header-left" width="312" height="75" align="left"><img 
src="http://texts.cdlib.org/images/escholarship_editions_header_lt.jpg" 
width="312" height="75" 
border="0" usemap="#header_left" alt="eScholarship Editions" /></td>

<td width="100%" class="header-middle"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text></td>

<td class="header-right" width="408" height="75" align="right"><img 
src="http://texts.cdlib.org/images/escholarship_editions_header_rt.jpg" 
width="408" height="75" 
border="0" usemap="#header_right" alt="eScholarship Editions" /></td>
</tr>
<!-- END HEADER ROW -->
<!-- BEGIN TOPNAV ROW -->
<tr  width="100%">
<td class="topnav-outer" colspan="3" width="100%" height="31" 
align="center" valign="middle">

<!-- BEGIN TOPNAV LEFT -->
<table width="100%" height="27" border="0" cellpadding="0" 
cellspacing="0">
<tr>
<td class="topnav-inner" width="25%"  align="center" valign="middle">

<!-- BEGIN TOPNAV LEFT INNER TABLE -->
<table border="0" cellpadding="0" cellspacing="0">
<tr align="left" valign="middle">
<td width="15" nowrap="nowrap"><a class="topnav" 
href="http://texts.cdlib.org/escholarship/"><img 
src="http://texts.cdlib.org/images/arrow.gif" width="15" height="15" 
border="0" alt="Home" 
/></a></td>
<td nowrap="nowrap"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><a 
class="topnav" href="http://texts.cdlib.org/escholarship/">Home</a></td>
<td width="15" nowrap="nowrap"><img 
src="http://texts.cdlib.org/images/spacer.gif" width="15" 
/></td>
<td width="15" nowrap="nowrap"><a class="topnav" 
href="http://texts.cdlib.org/escholarship/"><img 
src="http://texts.cdlib.org/images/arrow.gif" width="15" height="15" 
border="0" alt="Search" 
/></a></td>
<td nowrap="nowrap"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><a 
class="topnav" 
href="http://texts.cdlib.org/escholarship/">Search</a><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text></td>
</tr>
</table>
<!-- END TOPNAV LEFT INNER TABLE -->

</td>
<!-- END TOPNAV LEFT -->

<td width="2"><img src="http://texts.cdlib.org/images/spacer.gif" 
width="2" /></td>

<!-- BEGIN TOPNAV CENTER -->
<td class="topnav-inner" width="50%" align="center" 
nowrap="nowrap"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text></td>
<!-- END TOPNAV CENTER -->

<td width="2"><img src="http://texts.cdlib.org/images/spacer.gif" 
width="2" /></td>

<!-- BEGIN TOPNAV RIGHT -->
<td class="topnav-inner" width="25%" align="center" valign="middle">

<!-- BEGIN TOPNAV RIGHT INNER TABLE -->
<table border="0" cellpadding="0" cellspacing="0">
<tr align="right" valign="middle">
<td width="15" nowrap="nowrap"><a class="topnav" 
href="http://texts.cdlib.org/escholarship/about.html"><img 
src="http://texts.cdlib.org/images/arrow.gif" width="15" height="15" 
border="0" alt="About Us" 
/></a></td>
<td nowrap="nowrap"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><a 
class="topnav" href="http://texts.cdlib.org/escholarship/about.html">About 
Us</a></td>
<td width="15" nowrap="nowrap"><img 
src="http://texts.cdlib.org/images/spacer.gif" width="15" 
/></td>
<td width="15" nowrap="nowrap"><a class="topnav" 
href="http://texts.cdlib.org/escholarship/help.html"><img 
src="http://texts.cdlib.org/images/arrow.gif" width="15" height="15" 
border="0" alt="Help" 
/></a></td>
<td nowrap="nowrap"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><a 
class="topnav" 
href="http://texts.cdlib.org/escholarship/help.html">Help</a></td>
</tr>
</table>
<!-- END TOPNAV RIGHT INNER TABLE -->

</td>
<!-- END TOPNAV RIGHT -->

</tr>
</table>

</td>
</tr>
<!-- END TOPNAV ROW -->
<!-- BEGIN CONTENT ROW -->
<tr>
<td colspan="3" align="left" valign="top">
<div class="content2">

 <div 
align="center"> <p>Your 
search for "<b><xsl:value-of select="//Query/word"/></b>" found no 
results.</p>

<xsl:choose>
<xsl:when test="SearchResults/Query/term/suggest">
<xsl:call-template name="suggest"/>
</xsl:when>
</xsl:choose>

<form method="get" 
action="http://texts.cdlib.org/cgi-bin/searchucpress.pl">
Search <select name="mode">
<xsl:choose><xsl:when test="($indextosearch) = 'search'">
<option value="search" selected="selected">full description</option>
</xsl:when><xsl:otherwise><option value="search">full description</option>
</xsl:otherwise></xsl:choose>
<xsl:choose>
<xsl:when test="($indextosearch) = 'creator'">
<option value="creator" selected="selected">authors</option>
</xsl:when><xsl:otherwise><option value="creator">authors</option>
</xsl:otherwise></xsl:choose>
<xsl:choose>
<xsl:when test="($indextosearch) = 'title'">
<option value="title" selected="selected">titles</option>
</xsl:when><xsl:otherwise>
<option value="title">titles</option>
</xsl:otherwise></xsl:choose>
<xsl:choose><xsl:when test="($indextosearch) = 'subject'">
<option value="subject" selected="selected">subjects</option>
</xsl:when><xsl:otherwise><option value="subject">subjects</option>
</xsl:otherwise></xsl:choose>
</select> for 
<input type="text" name="search" size="30" value="{$search}" />
<input type="submit" value="Go!" /><br />
<input type="hidden" name="pageSize" value="{$page}" />
<xsl:choose>
<xsl:when test="($style) = 'brief'"><input type="hidden" 
name="display" value="brief" /></xsl:when>
<xsl:otherwise><input type="hidden" name="display" 
value="full" /></xsl:otherwise>
</xsl:choose>
</form>
</div>

<br />
</div>
</td>
</tr>
<!-- END CONTENT ROW -->
<!-- BEGIN FOOTER ROW -->
<tr>
<td colspan="3" align="left">
<div class="footer2">
<a href="http://texts.cdlib.org/cgi/mail.eschol">Comments? 
Questions?</a><br />
eScholarship Editions are published by <a 
href="http://escholarship.cdlib.org/">eScholarship</a>, the <a 
href="http://www.cdlib.org/">California Digital Library</a><br />
(c) 2003 The Regents of the University of California.</div>
</td>
</tr>
<!-- END FOOTER ROW -->

</table>
<!-- END OUTER LAYOUT TABLE -->
</body>
</html>

</xsl:template>

<xsl:template name="suggest">
<div align="center">
<form method="get" 
action="http://texts.cdlib.org/cgi-bin/searchucpress.pl">
You may have mispelled or mistyped your search.<br/>
Perhaps you meant:
<select name="search">
<xsl:for-each select="SearchResults/Query/term/suggest">
<xsl:element name="option"><xsl:value-of select="."/>
</xsl:element>
</xsl:for-each>
</select>
<input type="hidden" name="mode" value="search" />
<input type="submit" value="Use this spelling" /></form>
<p><i>or, try again:</i></p></div>
</xsl:template>

<xsl:template name="results">

<html>
  <head>
    <title>UC Press Description Search</title>
<link type="text/css" rel="stylesheet" 
href="http://texts.cdlib.org/styles/escholarship-editions.css" />
</head>
<body>

<!-- BEGIN OUTER LAYOUT TABLE -->
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<!-- BEGIN HEADER ROW -->
<map name="header_left" id="header_left">
<area shape="rect" coords="23,13,314,58" 
href="http://texts.cdlib.org/escholarship/" />
</map>
<map name="header_right" id="header_right">
<area shape="rect" coords="347,16,393,61" href="http://www.cdlib.org/" 
alt="CDL" />
</map>
<tr width="100%">
<td class="header-left" width="312" height="75" align="left"><img 
src="http://texts.cdlib.org/images/escholarship_editions_header_lt.jpg" 
width="312" height="75" 
border="0" usemap="#header_left" alt="eScholarship Editions" /></td>

<td width="100%" class="header-middle"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text></td>

<td class="header-right" width="408" height="75" align="right"><img 
src="http://texts.cdlib.org/images/escholarship_editions_header_rt.jpg" 
width="408" height="75" 
border="0" usemap="#header_right" alt="eScholarship Editions" /></td>
</tr>
<!-- END HEADER ROW -->
<!-- BEGIN TOPNAV ROW -->
<tr  width="100%">
<td class="topnav-outer" colspan="3" width="100%" height="31" 
align="center" valign="middle">

<!-- BEGIN TOPNAV LEFT -->
<table width="100%" height="27" border="0" cellpadding="0" 
cellspacing="0">
<tr>
<td class="topnav-inner" width="25%"  align="center" valign="middle">

<!-- BEGIN TOPNAV LEFT INNER TABLE -->
<table border="0" cellpadding="0" cellspacing="0">
<tr align="left" valign="middle">
<td width="15" nowrap="nowrap"><a class="topnav" 
href="http://texts.cdlib.org/escholarship/"><img 
src="http://texts.cdlib.org/images/arrow.gif" width="15" height="15" 
border="0" alt="Home" 
/></a></td>
<td nowrap="nowrap"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><a 
class="topnav" href="http://texts.cdlib.org/escholarship/">Home</a></td>
<td width="15" nowrap="nowrap"><img 
src="http://texts.cdlib.org/images/spacer.gif" width="15" 
/></td>
<td width="15" nowrap="nowrap"><a class="topnav" 
href="http://texts.cdlib.org/escholarship/"><img 
src="http://texts.cdlib.org/images/arrow.gif" width="15" height="15" 
border="0" alt="Search" 
/></a></td>
<td nowrap="nowrap"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><a 
class="topnav" 
href="http://texts.cdlib.org/escholarship/">Search</a><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text></td>
</tr>
</table>
<!-- END TOPNAV LEFT INNER TABLE -->

</td>
<!-- END TOPNAV LEFT -->

<td width="2"><img src="http://texts.cdlib.org/images/spacer.gif" 
width="2" /></td>

<!-- BEGIN TOPNAV CENTER -->
<td class="topnav-inner" width="50%" align="center" 
nowrap="nowrap"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text></td>
<!-- END TOPNAV CENTER -->

<td width="2"><img src="http://texts.cdlib.org/images/spacer.gif" 
width="2" /></td>

<!-- BEGIN TOPNAV RIGHT -->
<td class="topnav-inner" width="25%" align="center" valign="middle">

<!-- BEGIN TOPNAV RIGHT INNER TABLE -->
<table border="0" cellpadding="0" cellspacing="0">
<tr align="right" valign="middle">
<td width="15" nowrap="nowrap"><a class="topnav" 
href="http://texts.cdlib.org/escholarship/about.html"><img 
src="http://texts.cdlib.org/images/arrow.gif" width="15" height="15" 
border="0" alt="About Us" 
/></a></td>
<td nowrap="nowrap"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><a 
class="topnav" 
href="http://texts.cdlib.org/escholarship/about.html">About 
Us</a></td>
<td width="15" nowrap="nowrap"><img 
src="http://texts.cdlib.org/images/spacer.gif" width="15" 
/></td>
<td width="15" nowrap="nowrap"><a class="topnav" 
href="http://texts.cdlib.org/escholarship/help.html"><img 
src="http://texts.cdlib.org/images/arrow.gif" width="15" height="15" 
border="0" alt="Help" 
/></a></td>
<td nowrap="nowrap"><xsl:text
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><a 
class="topnav" 
href="http://texts.cdlib.org/escholarship/help.html">Help</a></td>
</tr>
</table>
<!-- END TOPNAV RIGHT INNER TABLE -->

</td>
<!-- END TOPNAV RIGHT -->

</tr>
</table>

</td>
</tr>
<!-- END TOPNAV ROW -->
<!-- BEGIN CONTENT ROW -->
<tr>
<td colspan="3" align="left" valign="top">
<div class="content2">

<div align="center">
<p><form method="get"
action="http://texts.cdlib.org/cgi-bin/searchucpress.pl">
Search <select name="mode">
<xsl:choose>
<xsl:when test="($indextosearch) = 'search'"><option 
value="search" selected="selected">full description</option>
</xsl:when><xsl:otherwise><option value="search">full description</option>
</xsl:otherwise></xsl:choose>
<xsl:choose>
<xsl:when test="($indextosearch) = 'creator'"><option 
value="creator" selected="selected">authors</option>
</xsl:when><xsl:otherwise><option value="creator">authors</option>
</xsl:otherwise></xsl:choose>
<xsl:choose>
<xsl:when test="($indextosearch) = 'title'">
<option value="title" selected="selected">titles</option>
</xsl:when><xsl:otherwise>
<option value="title">titles</option>
</xsl:otherwise></xsl:choose>
<xsl:choose>
<xsl:when test="($indextosearch) = 'subject'">
<option value="subject" selected="selected">subjects</option> 
</xsl:when>
<xsl:otherwise><option value="subject">subjects</option>
</xsl:otherwise></xsl:choose>
</select> for
<input type="text" name="search" size="30" value="{$search}" />
<input type="submit" value="Go!" /><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>[ <a 
href="http://texts.cdlib.org/ucpress/advanced.html">more 
options</a> ]
<input type="hidden" name="pageSize" value="{$page}" />
<xsl:choose>
<xsl:when test="($style) = 'brief'"><input type="hidden"
name="display" value="brief" /></xsl:when>
<xsl:otherwise><input type="hidden" name="display" 
value="full" /></xsl:otherwise>
</xsl:choose>
</form></p>
</div>

<p align="center">Your search for "<b><xsl:value-of select="//Query/word"/></b>" found 
<xsl:value-of select="SearchResults/@hits"/> books, sorted by relevance.
<xsl:choose> <xsl:when test="($style) = 'brief'"> 

<xsl:element name="a">
<xsl:attribute 
name="href">?mode=ucpress;<xsl:value-of 
select="SearchResults/Query/word/@index"/>=<xsl:value-of 
select="SearchResults/Query/word"/>;start=<xsl:value-of 
select="SearchResults/@start"/>;display=full;pageSize=<xsl:value-of 
select="SearchResults/@pageSize"/> <xsl:choose><xsl:when test="($public) 
= 'uconly'">;nrights=uconly</xsl:when></xsl:choose></xsl:attribute>Change 
to the full display</xsl:element>
</xsl:when> <xsl:otherwise>
<xsl:element name="a">
<xsl:attribute
name="href">?mode=ucpress;<xsl:value-of select="SearchResults/Query/word/@index"/>=<xsl:value-of
select="SearchResults/Query/word"/>;start=<xsl:value-of
select="SearchResults/@start"/>;display=brief;pageSize=<xsl:value-of
select="SearchResults/@pageSize"/><xsl:choose><xsl:when test="($public) 
= 'uconly'">;nrights=uconly</xsl:when></xsl:choose></xsl:attribute>Change 
to the brief display.</xsl:element>
</xsl:otherwise> </xsl:choose>
 
</p>

<div align="center">
<table><tr><td><img 
src="http://texts.cdlib.org/images/public.gif" alt="Available to Everyone"/></td><td><span 
class="search-text">
= Available to 
Everyone; All others 
are UC Only.<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
<xsl:choose>
<xsl:when test="($public) = 'uconly'">
<xsl:element name="a">
<xsl:attribute name="href">
/?mode=ucpress;<xsl:value-of 
select="SearchResults/Query/word/@index"/>=<xsl:value-of
select="SearchResults/Query/word"/>;pageSize=<xsl:value-of
select="SearchResults/@pageSize"/><xsl:choose>
<xsl:when test="($style) = 'brief'">;display=brief</xsl:when>
<xsl:otherwise>;display=full</xsl:otherwise>
</xsl:choose></xsl:attribute>Show 
all.</xsl:element>
</xsl:when>
<xsl:otherwise>
<xsl:element name="a">
<xsl:attribute name="href">
/?mode=ucpress;<xsl:value-of 
select="SearchResults/Query/word/@index"/>=<xsl:value-of 
select="SearchResults/Query/word"/>;nrights=uconly;pageSize=<xsl:value-of 
select="SearchResults/@pageSize"/><xsl:choose><xsl:when test="($style) = 'brief'">;display=brief</xsl:when><xsl:otherwise>;display=full</xsl:otherwise></xsl:choose>
</xsl:attribute>Show only public 
titles.</xsl:element>
</xsl:otherwise>
</xsl:choose>
</span> </td></tr></table></div>

<xsl:if test="SearchResults/previous|SearchResults/next">
<xsl:call-template name="navbar"/>
</xsl:if>

<ol start="{$start}">
<xsl:for-each select="SearchResults/qdc">
<li class="search-results">
<xsl:call-template name="qdc"/>
<xsl:choose>
<xsl:when test="$style = 'brief'">
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="full"/>
</xsl:otherwise>
</xsl:choose>
<br />
<b>Publication Date:</b><xsl:text 
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><xsl:value-of 
select="date"/>
<br /><b>Subjects:</b><xsl:text 
disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><xsl:for-each 
select="subject"><xsl:element name="A">
<xsl:attribute name="href">?mode=ucpress;bsubject=<xsl:value-of
select="."/>;<xsl:choose><xsl:when test="($public) = 
'uconly'">nrights=uconly;</xsl:when></xsl:choose>pageSize=<xsl:value-of
select="//SearchResults/@pageSize"/><xsl:choose><xsl:when 
test="($style) = 'brief'">;display=brief</xsl:when><xsl:when 
test = "($style) = 
'full'">;display=full</xsl:when></xsl:choose></xsl:attribute><xsl:value-of 
select="."/></xsl:element> |
</xsl:for-each><xsl:for-each select="subject.lcsh">
<xsl:element name="A">
<xsl:attribute name="href">?mode=ucpress;bsubject=<xsl:value-of
select="."/>;<xsl:choose><xsl:when test="($public) =
'uconly'">nrights=uconly;</xsl:when></xsl:choose>pageSize=<xsl:value-of
select="//SearchResults/@pageSize"/><xsl:choose><xsl:when test="($style) = 
'brief'">;display=brief</xsl:when><xsl:when
test = "($style) = 
'full'">;display=full</xsl:when></xsl:choose></xsl:attribute><xsl:value-of 
select="."/></xsl:element> |
</xsl:for-each>

</li>
</xsl:for-each>
</ol>
<xsl:if test="SearchResults/previous|SearchResults/next">
<xsl:call-template name="navbar"/>
</xsl:if>

<!-- IGNORED
<xsl:variable name="footer" 
select="document(/escholarship/htdocs/ucpress/footer)"/>
<xsl:apply-templates select="$footer//body/*"/>

<div class="footer">
<hr width="90%"/> <b><a
href="http://texts.cdlib.org/cgi-bin/mail.ucpress?">Comments?</a> 
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><a
href="http://texts.cdlib.org/cgi-bin/mail.ucpress?">Questions?</a></b> 
<br/>University of California Press eScholarship Editions are published by 
<a
href="http://escholarship.cdlib.org/">eScholarship</a>, the <a
href="http://www.cdlib.org/">California Digital Library</a> <br/>
<xsl:text disable-output-escaping='yes'><![CDATA[&#169;]]></xsl:text> 2002 The Regents of the University of California
</div>
-->
<br />
</div>
</td>
</tr>
<!-- END CONTENT ROW -->
<!-- BEGIN FOOTER ROW -->
<tr> 
<td colspan="3" align="left">
<div class="footer2">
<a href="http://texts.cdlib.org/cgi/mail.eschol">Comments?
Questions?</a><br />
eScholarship Editions are published by <a
href="http://escholarship.cdlib.org/">eScholarship</a>, the <a
href="http://www.cdlib.org/">California Digital Library</a><br />
(c) 2003 The Regents of the University of California.</div>
</td>
</tr>
<!-- END FOOTER ROW -->
</table>
<!-- END OUTER LAYOUT TABLE -->

  </body>
</html>
</xsl:template>

<xsl:template name="qdc">
<b><xsl:element name="a">
 <xsl:attribute name="href"><xsl:value-of select="identifier"/>
</xsl:attribute><xsl:value-of select="title"/></xsl:element>
</b><xsl:if test="./creator">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;&#151;&nbsp;]]></xsl:text> <xsl:value-of select="./creator"/>
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><xsl:choose>
<xsl:when test="rights = 'UCOnly'">
</xsl:when>
<xsl:otherwise>
<img alt="Available to Everyone"
 src="http://texts.cdlib.org/images/public.gif" valign="bottom"/>
</xsl:otherwise>
</xsl:choose>

</xsl:if>
</xsl:template>


<xsl:template name="full">
<xsl:apply-templates/>
</xsl:template>

<xsl:template name="navbar">
<p><span class="search-text">Results on this page: <xsl:value-of 
select="SearchResults/@start"/>-<xsl:value-of select="SearchResults/@end"/> <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;&#8226;&nbsp;]]></xsl:text>
<!--
<xsl:if test="SearchResults/previous">
<xsl:call-template name="previous"/>
</xsl:if>
<xsl:if test="SearchResults/next">
<xsl:call-template name="next"/>
</xsl:if>
-->

<xsl:if test="SearchResults/page">
<xsl:call-template name="page"/>
</xsl:if></span></p>
</xsl:template>

<xsl:template name="page">                
Jump to: 
<xsl:if test="SearchResults/previousGroup">
<xsl:element name="a">
<xsl:attribute name="href"><xsl:value-of select="SearchResults/previousGroup"/></xsl:attribute>&lt;&lt;</xsl:element> <xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:if>
<xsl:for-each select="SearchResults/page">
<xsl:choose>
    <xsl:when test="text()">
        <a href="{.}"><xsl:value-of select="@n"/></a>...
    </xsl:when>
    <xsl:otherwise>   
        <xsl:value-of select="@n"/>...
    </xsl:otherwise>
</xsl:choose>  
</xsl:for-each>
<xsl:if test="SearchResults/nextGroup">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text> <xsl:element name="a">
<xsl:attribute name="href"><xsl:value-of select="SearchResults/nextGroup"/></xsl:attribute>&gt;&gt;</xsl:element>
</xsl:if>
</xsl:template>

<xsl:template name="previous">
<xsl:element name="a">
<xsl:attribute name="href"><xsl:value-of select="SearchResults/previous"/></xsl:attribute>
<img src="/images/previous.gif" width="72" height="22" border="0" 
alt="Previous" /></xsl:element><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>

<xsl:template name="next">
<xsl:element name="a">
<xsl:attribute name="href"><xsl:value-of select="SearchResults/next"/></xsl:attribute>
<img src="/images/next.gif" width="51" height="22" border="0" alt="Next" /></xsl:element>
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:template>


<xsl:template match="SearchResults/Query">
<b><xsl:value-of select="."/></b>
</xsl:template>

<!--
<xsl:template match="suggest" mode="error">
<li class="searchresults"><xsl:element name="A">
<xsl:attribute name="href">/?mode=ucpress;<xsl:value-of 
select="SearchResults/Query/word/@index"/>=<xsl:value-of 
select="."/></xsl:attribute><xsl:value-of select="."/></xsl:element></li>
</xsl:template>
-->

<xsl:template match="/SearchResults/Query">
</xsl:template>
<!--
<xsl:template match="/SearchResults/description">
<xsl:value-of select="."/>
</xsl:template>
-->
<xsl:template match="//description">
<br /><xsl:apply-templates/>
</xsl:template>
<xsl:template match="//description/i">
  <i><xsl:value-of select="."/></i>
</xsl:template>
<xsl:template match="//description/I">
  <i><xsl:value-of select="."/></i>
</xsl:template>
<xsl:template match="//description/b">
  <b><xsl:value-of select="."/></b>
</xsl:template>
<xsl:template match="//description/B">
  <b><xsl:value-of select="."/></b>
</xsl:template>


<xsl:template match="/SearchResults/qdc/creator">
</xsl:template>
<xsl:template match="/SearchResults/qdc/subject">
</xsl:template>
<xsl:template match="/SearchResults/qdc/subject.lcsh">
</xsl:template>
<xsl:template match="/SearchResults/qdc/coverage.temporal">
</xsl:template>
<xsl:template match="/SearchResults/qdc/coverage.spatial">
</xsl:template>


<xsl:template match="/SearchResults/qdc/title">
</xsl:template>
<xsl:template match="/SearchResults/qdc/date">
</xsl:template>
<xsl:template match="/SearchResults/qdc/type">
</xsl:template>
<xsl:template match="/SearchResults/qdc/rights">
</xsl:template>
<xsl:template match="/SearchResults/qdc/relation.ispartof">
</xsl:template>
<xsl:template match="/SearchResults/qdc/identifier">
</xsl:template>

</xsl:stylesheet>
