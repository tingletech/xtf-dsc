<xsl:stylesheet version="2.0"
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

<xsl:param name="relation"></xsl:param>
<xsl:param name="title"></xsl:param>
<xsl:param name="subject"></xsl:param>
<xsl:param name="creator"></xsl:param>

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
<title>counting California Search</title>
<link type="text/css" rel="stylesheet"
href="http://countingcalifornia.cdlib.org/styles/web.css"/>
<xsl:text disable-output-escaping='yes'><![CDATA[
<SCRIPT LANGUAGE="JavaScript">
/* Copyright 2003,2004 The Regents of the University of California */

function generateStudyList( ) {
	/* Function to determine which, if any, studies have been
	 * specified as limits.
	 */

	/* Declare the variable that we'll use to hold the study names we
	 * find in the "search" element.
	 */
	var whichStudies = new Array( );

	/* Access the query portion of the URL, if any.  Break it at
	 * the ampersands.
	 */
	var pairs = location.search.substring(1).split("&");

	/* Look at each keyword=value substring.  */
	for (i = 0; i < pairs.length; i++) {

		/* Find the equal sign in it.  */
		var position = pairs[i].indexOf('=');

		/* If there isn't an equal sign, ignore it.  */
		if (position < 0) {
			continue;
			}

		/* Separate the string into the keyword and the value.  */
		var keywd = pairs[i].substring(0, position);
		var value = pairs[i].substring(position + 1);

		/* Ignore it if it isn't "relation=" something.  */
		if (keywd != "relation") {
			continue;
			}

		/* Ignore it if there is nothing after the equal sign.  */
		if (value.length == 0) {
			continue;
			}

		/* If there are any "+OR+" or " OR " (or "%20OR%20", sheesh)
		 * in it, then we have more than one study name.
		 */
		var studyNames = value.split("+OR+");
		for (var j = 0; j < studyNames.length; j++) {
			var studyNames2 = studyNames[j].split(" OR ");
			for (var k = 0; k < studyNames2.length; k++) {
				var studyNames3 = studyNames2[k].
					split("%20OR%20");
				for (var l = 0; l < studyNames3.length; l++) {
					whichStudies.push(studyNames3[l]);
					}
				}
			}
		}

	/* Return the list.  */
	return(whichStudies);
	}

function printTitleLimit( ) {
	/* Function to provide a note at the top of the basic search page
	 * saying to which title the search will be limited.  The note
	 * will be absent if the search is not limited to any title.
	 */

	/* Declare some variables.  */
	var i, foundOne, whichFound;
	var titleLimitList = new Array( );

	/* Get the study or studies listed in the basic search URL.  */
	whichStudies = generateStudyList( );

	/* If there aren't any, there is nothing for us to do here.  */
	if (whichStudies.length == 0) {
		return;
		}

	/* We have one or more studies.  */

	/* Check to see if this might be the CBP umbrella study.  For that
	 * to be true, all of the subordinate studies must be present.  Start
	 * by checking to see if one of them is present.
	 */
	foundOne = 0;
	for (i = 0; i < whichStudies.length; i++) {
		if ((whichStudies[i] == "cbp94") ||
			(whichStudies[i] == "cbp95") ||
			(whichStudies[i] == "cbp96") ||
			(whichStudies[i] == "cbp1967") ||
			(whichStudies[i] == "cbp97")) {
			foundOne = 1;
			break;
			}
		}
	if (foundOne) {
		/* We did have one of the CBP studies present.  Now, check
		 * to see if all of them are present.
		 */
		whichFound = 0;
		for (i = 0; i < whichStudies.length; i++) {
			switch(whichStudies[i]) {
			case "cbp94":
				whichFound |= 1;
				break;

			case "cbp95":
				whichFound |= 2;
				break;

			case "cbp96":
				whichFound |= 4;
				break;

			case "cbp97":
				whichFound |= 8;
				break;

			case "cbp1967":
				whichFound |= 16;
				break;
				}
			}

		if (whichFound == 31) {
			/* All of the CBP studies are present.  Put the
			 * name of the umbrella study in the output list,
			 * and remove the subordinate studies from the
			 * working list.
			 */
			titleLimitList.push(
				"County Business Patterns, [California] on CD-ROM");

			var newWhichStudies = new Array( );

			for (i = 0; i < whichStudies.length; i++) {
				if ((whichStudies[i] != "cbp94") &&
					(whichStudies[i] != "cbp95") &&
					(whichStudies[i] != "cbp96") &&
					(whichStudies[i] != "cbp1967") &&
					(whichStudies[i] != "cbp97")) {
					newWhichStudies.push(whichStudies[i]);
					}
				}
			whichStudies = newWhichStudies;
			}
		}

	/* Check to see if this might be the CSA umbrella study.  For that
	 * to be true, all of the subordinate studies must be present.  Start
	 * by checking to see if one of them is present.
	 */
	foundOne = 0;
	for (i = 0; i < whichStudies.length; i++) {
		if ((whichStudies[i] == "castat99") ||
			(whichStudies[i] == "castat00") ||
			(whichStudies[i] == "castat01") ||
			(whichStudies[i] == "castat02") ||
			(whichStudies[i] == "castat03")) {
			foundOne = 1;
			break;
			}
		}
	if (foundOne) {
		/* We did have one of the CSA studies present.  Now, check
		 * to see if all of them are present.
		 */
		whichFound = 0;
		for (i = 0; i < whichStudies.length; i++) {
			switch(whichStudies[i]) {
			case "castat99":
				whichFound |= 1;
				break;

			case "castat00":
				whichFound |= 2;
				break;

			case "castat01":
				whichFound |= 4;
				break;

			case "castat02":
				whichFound |= 8;
				break;

			case "castat03":
				whichFound |= 16;
				break;
				}
			}

		if (whichFound == 31) {
			/* All of the CSA studies are present.  Put the
			 * name of the umbrella study in the output list,
			 * and remove the subordinate studies from the
			 * working list.
			 */
			titleLimitList.push("California Statistical Abstract");

			var newWhichStudies = new Array( );

			for (i = 0; i < whichStudies.length; i++) {
				if ((whichStudies[i] != "castat99") &&
					(whichStudies[i] != "castat00") &&
					(whichStudies[i] != "castat01") &&
					(whichStudies[i] != "castat02") &&
					(whichStudies[i] != "castat03")) {
					newWhichStudies.push(whichStudies[i]);
					}
				}
			whichStudies = newWhichStudies;
			}
		}

	/* For any studies remaining in the list, translate them from their
	 * internal names to their external names, and append them to the
	 * list that will be displayed.
	 */
	for (i = 0; i < whichStudies.length; i++) {
		var fullStudyName;

		/* Translate internal name to external name.  */
		switch(whichStudies[i]) {
		case "castat99":
			fullStudyName = "California Statistical Abstract 1999";
			break;

		case "castat00":
			fullStudyName = "California Statistical Abstract 2000";
			break;

		case "castat01":
			fullStudyName = "California Statistical Abstract 2001";
			break;

		case "castat02":
			fullStudyName = "California Statistical Abstract 2002";
			break;

		case "castat03":
			fullStudyName = "California Statistical Abstract 2003";
			break;

		case "cbp1967":
			fullStudyName = "County Business Patterns, 1967 [California]";
			break;

		case "cbp94":
			fullStudyName = "County Business Patterns, 1994 [California] on CD-ROM";
			break;

		case "cbp95":
			fullStudyName = "County Business Patterns, 1995 [California] on CD-ROM";
			break;

		case "cbp96":
			fullStudyName = "County Business Patterns, 1996 [California] on CD-ROM";
			break;

		case "cbp97":
			fullStudyName = "County Business Patterns, 1997 [California] on CD-ROM";
			break;

		case "ccdbca4777":
			fullStudyName = "County and City Data Book [California] Consolidated File: County Data, 1944-1977";
			break;

		case "deathage":
			fullStudyName = "Deaths by Age by, County, and Selected City Health Departments, California 1998-2002 (By Place of Residence)";
			break;

		case "deathcnty":
			fullStudyName = "Deaths by Year of Death, by County, California 1990-2002 (By Place of Residence)";
			break;

		case "deathrace":
			fullStudyName = "Deaths by Race, County and Selected City Health Departments, California 1998-2002 (By Place of Residence)";
			break;

		case "eeo1980":
			fullStudyName = "Census of Population, Equal Employment Opportunity Special File, California 1980";
			break;

		case "histpop":
			fullStudyName = "Historical Census Populations of Counties, Places, Towns, and Cities in California, 1850-1990";
			break;

		case "legal_imm98_sta":
			fullStudyName =
				"Legal Immigration to California, 1990-1998";
			break;

		case "legal_imm98_stc":
			fullStudyName = "Legal Immigration to California by County, 1990-1998";
			break;

		case "livebirth":
			fullStudyName = "Live Births, California Counties, 1990-2002 (By Place of Residence)";
			break;

		case "liveteen":
			fullStudyName = "Number and Percent of Live Births to Teen Mothers, California Counties, 1990-2002 (By Place of Residence)";
			break;

		case "publaw":
			fullStudyName = "Census 2000 Redistricting Data (Public Law 94-171) Summary File [California]";
			break;

		case "racesexage":
			fullStudyName = "Race/Ethnic Population Projection with Age and Sex Detail 1970 - 2040";
			break;

		case "sc1970":
			fullStudyName = "Census of Population, 1970: 2nd Count [California]";
			break;

		case "sf12000":
			fullStudyName = "Census of Population and Housing, 2000 [California]:  Summary File 1";
			break;

		case "sf22000":
			fullStudyName = "Census of Population and Housing, 2000 [California]: Summary File 2";
			break;

		case "sf32000":
			fullStudyName = "Census of Population and Housing, 2000 [California]: Summary File 3";
			break;

		case "sf42000":
			fullStudyName = "Census of Population and Housing, 2000 [California]: Summary File 4";
			break;

		case "stf3":
			fullStudyName = "Census of Population and Housing, 1990 Summary Tape File 3 [California]";
			break;

		case "stf31980":
			fullStudyName = "Census of Population and Housing, 1980 Summary Tape File 3 [California]";
			break;

		case "usaco":
			fullStudyName = "USA Counties, 1998 [California]";
			break;

		default:
			fullStudyName = "the title with internal name " +
				whichStudies[i];
			break;
			}

		/* Append to list that will be displayed.  */
		titleLimitList.push(fullStudyName);
		}

	/* List complete.  Put out the note.  I don't think the list can
	 * be empty at this point, but check anyway.
	 */
	if (titleLimitList.length == 0) {
		return;
		}

	for (i = 0; i < titleLimitList.length; i++) {
		if (i == 0) {
			document.write("<P ALIGN=\"LEFT\">Search " +
				"limited to:&nbsp; ");
			}
		document.write("<STRONG>" + titleLimitList[i] + "</STRONG>" +
			"<BR>\n");
		}
	document.write("</P>\n");
/*
	document.write("<P ALIGN=\"LEFT\"><A " +
		"HREF=\"/?type=table&xslt=coca\">Search all titles</A>." +
		"</P>\n");
*/
	return;
	}
</SCRIPT>
]]></xsl:text>
</head>
<body>

<div align="center">
<img src="http://countingcalifornia.cdlib.org/images/2ndlevel.gif" width="640" height="89" border="0" alt="Counting California Navigation Bar" usemap="#2ndlevel"/>

<map name="2ndlevel">
<area shape="rect" coords="0,5,276,58" href="http://countingcalifornia.cdlib.org" title="Counting California" alt="Counting California"/>
<area shape="rect" coords="581,43,623,59" href="http://countingcalifornia.cdlib.org/cms.search.html" title="Search" alt="Search"/>
<area shape="rect" coords="522,42,565,59" href="http://countingcalifornia.cdlib.org/provider/" title="Agency" alt="Agency"/>
<area shape="rect" coords="471,43,506,60" href="http://countingcalifornia.cdlib.org/title/" title="Titles" alt="Titles"/>
<area shape="rect" coords="396,43,458,60" href="http://countingcalifornia.cdlib.org/geography/" title="Geography" alt="Geography"/>
<area shape="rect" coords="341,43,382,59" href="http://countingcalifornia.cdlib.org/topics.html" title="Topics" alt="Topics"/>
<area shape="rect" coords="262,65,302,80" href="http://countingcalifornia.cdlib.org/help.html" title="Help" alt="Help"/>
<area shape="rect" coords="206,63,250,82" href="http://countingcalifornia.cdlib.org/news.html" title="News" alt="News"/>
<area shape="rect" coords="137,64,193,82" href="http://countingcalifornia.cdlib.org/feedback.html" title="Feedback" alt="Feedback"/>
<area shape="rect" coords="66,64,123,80" href="http://countingcalifornia.cdlib.org/about.html" title="About Us" alt="About Us"/>
<area shape="rect" coords="11,64,53,80" href="http://countingcalifornia.cdlib.org" title="Home" alt="Home"/>
</map>

</div>

<!-- Call template to give option to repeat search -->
<xsl:call-template name="searchagain"/>

<p align="left">Your search for "<b><xsl:value-of select="//Query/word"/></b>" found no results.</p>

<p>Did you search for a <strong>place</strong>, e.g., San Francisco, Los Angeles? Go to <a href="http://countingcalifornia.cdlib.org/geography/">Browse by Geography</a> instead.</p>

<p>Try <a href="http://countingcalifornia.cdlib.org/topics.html">Browsing by Topics</a> instead.</p>

<p>Use truncation to broaden your search (for example: try <strong>educat*</strong>  to find education, educational, etc. )</p>


<SCRIPT LANGUAGE="JavaScript">printTitleLimit( );</SCRIPT>

<xsl:choose>
<xsl:when test="SearchResults/Query/term/suggest">
<!--
<xsl:call-template name="suggest"/>
-->
</xsl:when>
</xsl:choose>

<!-- Separate the footer from the search box -->

<br />
<br />
<br />

<!-- doesn't work
<xsl:variable name="footer" 
select="document(/calcounts/cc/prd/webdocs/images/footer)"/>
<xsl:apply-templates select="$footer//body/*"/>

<hr />
<p class="footer">A service of <a 
href="http://countingcalifornia.cdlib.org/">CountingCalifornia</a>.</p>
-->
<DIV CLASS="footer">
<HR WIDTH="75%" SIZE="1" />
<DIV id="comments">
<A CLASS="comments-link" HREF="/feedback.html">Comments? Questions?</A><BR />
</DIV>Counting California is a service of the
<A TARGET="_blank" HREF="http://libraries.universityofcalifornia.edu">UC
Libraries</A>, powered by the
<A TARGET="_blank" HREF="http://www.cdlib.org">CDL</A>.
<BR /><xsl:text disable-output-escaping='yes'><![CDATA[&copy;]]></xsl:text> 2001-2004 The Regents of the University of California
</DIV>


</body>
</html>

</xsl:template>

<!--
<xsl:template name="suggest">
<div align="center">
<form method="get" action="http://content.cdlib.org/cms">
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
-->

<xsl:template name="results">

<html>
<head>
<title>Counting California Search</title>
<link type="text/css" rel="stylesheet" href="http://countingcalifornia.cdlib.org/styles/web.css" />
<xsl:text disable-output-escaping='yes'><![CDATA[
<SCRIPT LANGUAGE="JavaScript">
/* Copyright 2003,2004 The Regents of the University of California */

function generateStudyList( ) {
	/* Function to determine which, if any, studies have been
	 * specified as limits.
	 */

	/* Declare the variable that we'll use to hold the study names we
	 * find in the "search" element.
	 */
	var whichStudies = new Array( );

	/* Access the query portion of the URL, if any.  Break it at
	 * the ampersands.
	 */
	var pairs = location.search.substring(1).split("&");

	/* Look at each keyword=value substring.  */
	for (i = 0; i < pairs.length; i++) {

		/* Find the equal sign in it.  */
		var position = pairs[i].indexOf('=');

		/* If there isn't an equal sign, ignore it.  */
		if (position < 0) {
			continue;
			}

		/* Separate the string into the keyword and the value.  */
		var keywd = pairs[i].substring(0, position);
		var value = pairs[i].substring(position + 1);

		/* Ignore it if it isn't "relation=" something.  */
		if (keywd != "relation") {
			continue;
			}

		/* Ignore it if there is nothing after the equal sign.  */
		if (value.length == 0) {
			continue;
			}

		/* If there are any "+OR+" or " OR " (or "%20OR%20", sheesh)
		 * in it, then we have more than one study name.
		 */
		var studyNames = value.split("+OR+");
		for (var j = 0; j < studyNames.length; j++) {
			var studyNames2 = studyNames[j].split(" OR ");
			for (var k = 0; k < studyNames2.length; k++) {
				var studyNames3 = studyNames2[k].
					split("%20OR%20");
				for (var l = 0; l < studyNames3.length; l++) {
					whichStudies.push(studyNames3[l]);
					}
				}
			}
		}

	/* Return the list.  */
	return(whichStudies);
	}

function printTitleLimit( ) {
	/* Function to provide a note at the top of the basic search page
	 * saying to which title the search will be limited.  The note
	 * will be absent if the search is not limited to any title.
	 */

	/* Declare some variables.  */
	var i, foundOne, whichFound;
	var titleLimitList = new Array( );

	/* Get the study or studies listed in the basic search URL.  */
	whichStudies = generateStudyList( );

	/* If there aren't any, there is nothing for us to do here.  */
	if (whichStudies.length == 0) {
		return;
		}

	/* We have one or more studies.  */

	/* Check to see if this might be the CBP umbrella study.  For that
	 * to be true, all of the subordinate studies must be present.  Start
	 * by checking to see if one of them is present.
	 */
	foundOne = 0;
	for (i = 0; i < whichStudies.length; i++) {
		if ((whichStudies[i] == "cbp94") ||
			(whichStudies[i] == "cbp95") ||
			(whichStudies[i] == "cbp96") ||
			(whichStudies[i] == "cbp1967") ||
			(whichStudies[i] == "cbp97")) {
			foundOne = 1;
			break;
			}
		}
	if (foundOne) {
		/* We did have one of the CBP studies present.  Now, check
		 * to see if all of them are present.
		 */
		whichFound = 0;
		for (i = 0; i < whichStudies.length; i++) {
			switch(whichStudies[i]) {
			case "cbp94":
				whichFound |= 1;
				break;

			case "cbp95":
				whichFound |= 2;
				break;

			case "cbp96":
				whichFound |= 4;
				break;

			case "cbp97":
				whichFound |= 8;
				break;

			case "cbp1967":
				whichFound |= 16;
				break;
				}
			}

		if (whichFound == 31) {
			/* All of the CBP studies are present.  Put the
			 * name of the umbrella study in the output list,
			 * and remove the subordinate studies from the
			 * working list.
			 */
			titleLimitList.push(
				"County Business Patterns, [California] on CD-ROM");

			var newWhichStudies = new Array( );

			for (i = 0; i < whichStudies.length; i++) {
				if ((whichStudies[i] != "cbp94") &&
					(whichStudies[i] != "cbp95") &&
					(whichStudies[i] != "cbp96") &&
					(whichStudies[i] != "cbp1967") &&
					(whichStudies[i] != "cbp97")) {
					newWhichStudies.push(whichStudies[i]);
					}
				}
			whichStudies = newWhichStudies;
			}
		}

	/* Check to see if this might be the CSA umbrella study.  For that
	 * to be true, all of the subordinate studies must be present.  Start
	 * by checking to see if one of them is present.
	 */
	foundOne = 0;
	for (i = 0; i < whichStudies.length; i++) {
		if ((whichStudies[i] == "castat99") ||
			(whichStudies[i] == "castat00") ||
			(whichStudies[i] == "castat01") ||
			(whichStudies[i] == "castat02") ||
			(whichStudies[i] == "castat03")) {
			foundOne = 1;
			break;
			}
		}
	if (foundOne) {
		/* We did have one of the CSA studies present.  Now, check
		 * to see if all of them are present.
		 */
		whichFound = 0;
		for (i = 0; i < whichStudies.length; i++) {
			switch(whichStudies[i]) {
			case "castat99":
				whichFound |= 1;
				break;

			case "castat00":
				whichFound |= 2;
				break;

			case "castat01":
				whichFound |= 4;
				break;

			case "castat02":
				whichFound |= 8;
				break;

			case "castat03":
				whichFound |= 16;
				break;
				}
			}

		if (whichFound == 31) {
			/* All of the CSA studies are present.  Put the
			 * name of the umbrella study in the output list,
			 * and remove the subordinate studies from the
			 * working list.
			 */
			titleLimitList.push("California Statistical Abstract");

			var newWhichStudies = new Array( );

			for (i = 0; i < whichStudies.length; i++) {
				if ((whichStudies[i] != "castat99") &&
					(whichStudies[i] != "castat00") &&
					(whichStudies[i] != "castat01") &&
					(whichStudies[i] != "castat02") &&
					(whichStudies[i] != "castat03")) {
					newWhichStudies.push(whichStudies[i]);
					}
				}
			whichStudies = newWhichStudies;
			}
		}

	/* For any studies remaining in the list, translate them from their
	 * internal names to their external names, and append them to the
	 * list that will be displayed.
	 */
	for (i = 0; i < whichStudies.length; i++) {
		var fullStudyName;

		/* Translate internal name to external name.  */
		switch(whichStudies[i]) {
		case "castat99":
			fullStudyName = "California Statistical Abstract 1999";
			break;

		case "castat00":
			fullStudyName = "California Statistical Abstract 2000";
			break;

		case "castat01":
			fullStudyName = "California Statistical Abstract 2001";
			break;

		case "castat02":
			fullStudyName = "California Statistical Abstract 2002";
			break;

		case "castat03":
			fullStudyName = "California Statistical Abstract 2003";
			break;

		case "cbp1967":
			fullStudyName = "County Business Patterns, 1967 [California]";
			break;

		case "cbp94":
			fullStudyName = "County Business Patterns, 1994 [California] on CD-ROM";
			break;

		case "cbp95":
			fullStudyName = "County Business Patterns, 1995 [California] on CD-ROM";
			break;

		case "cbp96":
			fullStudyName = "County Business Patterns, 1996 [California] on CD-ROM";
			break;

		case "cbp97":
			fullStudyName = "County Business Patterns, 1997 [California] on CD-ROM";
			break;

		case "ccdbca4777":
			fullStudyName = "County and City Data Book [California] Consolidated File: County Data, 1944-1977";
			break;

		case "deathage":
			fullStudyName = "Deaths by Age by, County, and Selected City Health Departments, California 1998-2002 (By Place of Residence)";
			break;

		case "deathcnty":
			fullStudyName = "Deaths by Year of Death, by County, California 1990-2002 (By Place of Residence)";
			break;

		case "deathrace":
			fullStudyName = "Deaths by Race, County and Selected City Health Departments, California 1998-2002 (By Place of Residence)";
			break;

		case "eeo1980":
			fullStudyName = "Census of Population, Equal Employment Opportunity Special File, California 1980";
			break;

		case "histpop":
			fullStudyName = "Historical Census Populations of Counties, Places, Towns, and Cities in California, 1850-1990";
			break;

		case "legal_imm98_sta":
			fullStudyName =
				"Legal Immigration to California, 1990-1998";
			break;

		case "legal_imm98_stc":
			fullStudyName = "Legal Immigration to California by County, 1990-1998";
			break;

		case "livebirth":
			fullStudyName = "Live Births, California Counties, 1990-2002 (By Place of Residence)";
			break;

		case "liveteen":
			fullStudyName = "Number and Percent of Live Births to Teen Mothers, California Counties, 1990-2002 (By Place of Residence)";
			break;

		case "publaw":
			fullStudyName = "Census 2000 Redistricting Data (Public Law 94-171) Summary File [California]";
			break;

		case "sc1970":
			fullStudyName = "Census of Population, 1970: 2nd Count [California]";
			break;

		case "racesexage":
			fullStudyName = "Race/Ethnic Population Projection with Age and Sex Detail 1970 - 2040";
			break;

		case "sf12000":
			fullStudyName = "Census of Population and Housing, 2000 [California]:  Summary File 1";
			break;

		case "sf22000":
			fullStudyName = "Census of Population and Housing, 2000 [California]: Summary File 2";
			break;

		case "sf32000":
			fullStudyName = "Census of Population and Housing, 2000 [California]: Summary File 3";
			break;

		case "sf42000":
			fullStudyName = "Census of Population and Housing, 2000 [California]: Summary File 4";
			break;

		case "stf3":
			fullStudyName = "Census of Population and Housing, 1990 Summary Tape File 3 [California]";
			break;

		case "stf31980":
			fullStudyName = "Census of Population and Housing, 1980 Summary Tape File 3 [California]";
			break;

		case "usaco":
			fullStudyName = "USA Counties, 1998 [California]";
			break;

		default:
			fullStudyName = "the title with internal name " +
				whichStudies[i];
			break;
			}

		/* Append to list that will be displayed.  */
		titleLimitList.push(fullStudyName);
		}

	/* List complete.  Put out the note.  I don't think the list can
	 * be empty at this point, but check anyway.
	 */
	if (titleLimitList.length == 0) {
		return;
		}

	for (i = 0; i < titleLimitList.length; i++) {
		if (i == 0) {
			document.write("<P ALIGN=\"LEFT\">Search " +
				"limited to:&nbsp; ");
			}
		document.write("<STRONG>" + titleLimitList[i] + "</STRONG>" +
			"<BR>\n");
		}
	document.write("</P>\n");
/*
	document.write("<P ALIGN=\"LEFT\"><A " +
		"HREF=\"/?type=table&xslt=coca\">Search all titles</A>." +
		"</P>\n");
*/
	return;
	}
</SCRIPT>
]]></xsl:text>
</head>
<body>

<div align="center">
<img src="http://countingcalifornia.cdlib.org/images/2ndlevel.gif" width="640" height="89" border="0" alt="Counting California Navigation Bar" usemap="#2ndlevel"/>

<map name="2ndlevel">
<area shape="rect" coords="0,5,276,58" href="http://countingcalifornia.cdlib.org" title="Counting California" alt="Counting California"/>
<area shape="rect" coords="581,43,623,59" href="http://countingcalifornia.cdlib.org/cms.search.html" title="Search" alt="Search"/>
<area shape="rect" coords="522,42,565,59" href="http://countingcalifornia.cdlib.org/provider/" title="Agency" alt="Agency"/>
<area shape="rect" coords="471,43,506,60" href="http://countingcalifornia.cdlib.org/title/" title="Titles" alt="Titles"/>
<area shape="rect" coords="396,43,458,60" href="http://countingcalifornia.cdlib.org/geography/" title="Geography" alt="Geography"/>
<area shape="rect" coords="341,43,382,59" href="http://countingcalifornia.cdlib.org/topics.html" title="Topics" alt="Topics"/>
<area shape="rect" coords="262,65,302,80" href="http://countingcalifornia.cdlib.org/help.html" title="Help" alt="Help"/>
<area shape="rect" coords="206,63,250,82" href="http://countingcalifornia.cdlib.org/news.html" title="News" alt="News"/>
<area shape="rect" coords="137,64,193,82" href="http://countingcalifornia.cdlib.org/feedback.html" title="Feedback" alt="Feedback"/>
<area shape="rect" coords="66,64,123,80" href="http://countingcalifornia.cdlib.org/about.html" title="About Us" alt="About Us"/>
<area shape="rect" coords="11,64,53,80" href="http://countingcalifornia.cdlib.org" title="Home" alt="Home"/>
</map>

</div>

<xsl:call-template name="searchagain"/>

<p align="left">Your search for "<b><xsl:value-of select="//Query/word"/></b>" found <B>
<xsl:value-of select="SearchResults/@hits"/></B> tables, sorted by relevance.
<xsl:choose>

<xsl:when test="($style) = 'brief'"> 
<xsl:element name="a">
<xsl:attribute name="href">?<xsl:value-of select="SearchResults/Query/word/@index"/>=%22<xsl:value-of select="SearchResults/Query/word"/>%22<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>start=<xsl:value-of select="SearchResults/@start"/><xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>type=table<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>xslt=coca<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>relation=<xsl:value-of select="$relation"/><xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>display=full<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>pageSize=<xsl:value-of select="SearchResults/@pageSize"/>
<xsl:choose><xsl:when test="($public) = 'uconly'">;nrights=uconly</xsl:when></xsl:choose>
</xsl:attribute>
Change to the full display</xsl:element>
</xsl:when>

<xsl:otherwise>
<xsl:element name="a">
<xsl:attribute name="href">?<xsl:value-of select="SearchResults/Query/word/@index"/>=%22<xsl:value-of select="SearchResults/Query/word"/>%22<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>start=<xsl:value-of select="SearchResults/@start"/><xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>type=table<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>xslt=coca<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>relation=<xsl:value-of select="$relation"/><xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>display=brief<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>pageSize=<xsl:value-of select="SearchResults/@pageSize"/>
<xsl:choose><xsl:when test="($public) = 'uconly'">;nrights=uconly
</xsl:when></xsl:choose>
</xsl:attribute>
Change to the brief display.</xsl:element>
</xsl:otherwise> </xsl:choose>
 
</p>
<SCRIPT LANGUAGE="JavaScript">printTitleLimit( );</SCRIPT>

<xsl:if test="SearchResults/previous|SearchResults/next">
<xsl:call-template name="navbar"/>
</xsl:if>

<ol start="{$start}">
<xsl:for-each select="SearchResults/qdc">
<p>
<li class="searchresults">
<xsl:call-template name="qdc"/>
<br />
<span class="small"><b>Publication: </b><xsl:element name="a">
<xsl:attribute name="href"><xsl:value-of select="./relation.ispartof"/></xsl:attribute><xsl:value-of select="substring-after(./relation.ispartof[1], 'title/')"/></xsl:element></span>
<xsl:if test="./relation.ispartof[position() = last()]">
<span class="small"><b> Table Number: </b><xsl:value-of select="./relation.ispartof[position() = last()]"/></span>
</xsl:if>
<br />
<span class="small"><b>Time period covered:</b><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><xsl:value-of select="date"/></span>
<xsl:choose>
<xsl:when test="$style = 'brief'">
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="full"/>
</xsl:otherwise>
</xsl:choose>
</li>
</p>
</xsl:for-each>
</ol>
<xsl:if test="SearchResults/previous|SearchResults/next">
<xsl:call-template name="navbar"/>
</xsl:if>

<!-- this was removed from the noresults output, but was not
	commented out here.  I commented it out.   MAR 6/9/2004
<xsl:variable name="footer" 
select="document(/calcounts/cc/prd/webdocs/image/footer)"/>
-->

<DIV CLASS="footer">
<HR WIDTH="75%" SIZE="1" />
<DIV id="comments">
<A CLASS="comments-link" HREF="/feedback.html">Comments? Questions?</A><BR />
</DIV>Counting California is a service of the
<A TARGET="_blank" HREF="http://libraries.universityofcalifornia.edu">UC
Libraries</A>, powered by the
<A TARGET="_blank" HREF="http://www.cdlib.org">CDL</A>.
<BR /><xsl:text disable-output-escaping='yes'><![CDATA[&copy;]]></xsl:text> 2001-2004 The Regents of the University of California
</DIV>

</body>
</html>
</xsl:template>

<xsl:template name="qdc">
<b><xsl:element name="a">
 <xsl:attribute name="href"><xsl:value-of select="replace(identifier,'^http://ark.cdlib.org/','http://content.cdlib.org/')"/><xsl:text>/fptr1</xsl:text>
</xsl:attribute><xsl:value-of select="title"/></xsl:element>
</b>
<xsl:if test="./creator">
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;&#151;&nbsp;]]></xsl:text> <xsl:value-of select="./creator"/>
<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
</xsl:if>
</xsl:template>


<xsl:template name="full">

<br/>
<b>Topics:</b><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text><xsl:for-each select="subject.concept">
<xsl:element name="A">
<xsl:attribute name="href">?subject=%22<xsl:value-of select="."/>%22<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text><xsl:choose><xsl:when test="($public) = 'uconly'">nrights=uconly<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text></xsl:when></xsl:choose>type=table<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>xslt=coca<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>pageSize=<xsl:value-of select="//SearchResults/@pageSize"/><xsl:choose><xsl:when test="($style) = 'brief'"><xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>display=brief</xsl:when><xsl:when test = "($style) = 'full'"><xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>display=full</xsl:when></xsl:choose><xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>relation=<xsl:value-of select="($relation)"/></xsl:attribute><xsl:value-of select="."/>
</xsl:element> | </xsl:for-each>

<!--The following line was what was there before -->
<!--xsl:apply-templates/-->
</xsl:template>

<xsl:template name="navbar">
<p><span class="small">Results on this page: <xsl:value-of select="SearchResults/@start"/>-<xsl:value-of select="SearchResults/@end"/><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;&#8226;&nbsp;]]></xsl:text>
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
        <a href="{translate(.,';','&#x26;')}"><xsl:value-of select="@n"/></a>...
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

<!-- template that presents current search and gives opportunity to search again -->
<xsl:template name="searchagain">

<div align="center">
<p><form method="get" action="http://content.cdlib.org/cms">
<!-- This section is no longer used, but may be used again later.
<font size="3">
Repeat<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]><![CDATA[&nbsp;]]></xsl:text>
<xsl:choose>
<xsl:when test="($indextosearch) = 'title'">
<font color="blue">title</font> search
</xsl:when>
<xsl:when test="($indextosearch) = 'subject'">
<font color="blue">concept</font>
</xsl:when>
<xsl:when test="($indextosearch) = 'search'">
<font color="blue">entire table</font>
</xsl:when>
<xsl:when test="($indextosearch) = 'creator'">
<font color="blue">agency</font>
</xsl:when>
</xsl:choose>

<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>for<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]><![CDATA[&nbsp;]]></xsl:text>
</font>
-->

<!-- This section is no longer used either, but may be used again later.
	MAR 6/2/2004
<xsl:choose>
<xsl:when test="($indextosearch) = 'title'">
<input type="text" name="title" size="30" value="{$title}"/>
</xsl:when>
<xsl:when test="($indextosearch) = 'subject'">
<input type="text" name="subject" size="30" value="{$subject}"/>
</xsl:when>
<xsl:when test="($indextosearch) = 'search'">
<input type="text" name="search" size="30" value="{$search}"/>
</xsl:when>
<xsl:when test="($indextosearch) = 'creator'">
<input type="text" name="creator" size="30" value="{$creator}"/>
</xsl:when>
</xsl:choose>
-->
<xsl:choose>
<xsl:when test="($indextosearch) = 'search'">
<input type="text" name="search" size="30" value="{$search}"/>
</xsl:when>
<xsl:when test="($indextosearch) = 'title'">
<input type="text" name="search" size="30" value="{$title}"/>
</xsl:when>
<xsl:when test="($indextosearch) = 'subject'">
<input type="text" name="search" size="30" value="{$subject}"/>
</xsl:when>
<xsl:when test="($indextosearch) = 'creator'">
<input type="text" name="search" size="30" value="{$creator}"/>
</xsl:when>
</xsl:choose>

<xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;&nbsp;]]></xsl:text>
<input type="submit" value="Search" /><xsl:text disable-output-escaping='yes'><![CDATA[&nbsp;]]></xsl:text>
<input type="hidden" name="pageSize" value="{$page}" />
<xsl:choose>
<xsl:when test="($style) = 'brief'"><input type="hidden" name="display" value="brief" /></xsl:when>
<xsl:otherwise><input type="hidden" name="display" value="full" /></xsl:otherwise>
</xsl:choose>
<input type="hidden" name="relation" value="{$relation}"/>
<input type="hidden" name="type" value="table"/>
<input type="hidden" name="xslt" value="coca"/>
</form></p>
</div>

</xsl:template>


<!--
<xsl:template match="suggest" mode="error">
<li class="searchresults"><xsl:element name="A">
<xsl:attribute name="href">/?<xsl:value-of 
select="SearchResults/Query/word/@index"/>=<xsl:value-of 
select="."/><xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>type=table<xsl:text disable-output-escaping='yes'><![CDATA[&]]></xsl:text>xslt=coca</xsl:attribute><xsl:value-of select="."/></xsl:element></li>
</xsl:template>
-->

<xsl:template match="/SearchResults/Query">
</xsl:template>
<!--
<xsl:template match="/SearchResults/description">
<xsl:value-of select="."/>
</xsl:template>
-->
<!--
<xsl:template match="//description">
<br /><span class="small"><xsl:apply-templates/></span>    
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
-->


<xsl:template match="/SearchResults/qdc/creator">
</xsl:template>
<xsl:template match="/SearchResults/qdc/subject">
</xsl:template>
<xsl:template match="/SearchResults/qdc/subject.concept">
</xsl:template>
<xsl:template match="/SearchResults/qdc/description">
</xsl:template>
<xsl:template match="/SearchResults/qdc/publisher">
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
