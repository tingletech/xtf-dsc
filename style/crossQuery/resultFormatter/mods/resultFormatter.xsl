<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

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
                              xmlns:dc="http://purl.org/dc/elements/1.1/" 
                              xmlns:mets="http://www.loc.gov/METS/" 
                              xmlns:xlink="http://www.w3.org/TR/xlink">
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="../common/cdlResultFormatterCommon.xsl"/>
  
  <!-- ====================================================================== -->
  <!-- Output Parameters                                                      -->
  <!-- ====================================================================== -->
  
  <!-- ====================================================================== -->
  <!-- Output Format                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:output method="html" indent="yes" encoding="UTF-8" media-type="text/html" 
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
  
  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->
  
  <xsl:param name="rmode"/>
  
  <!-- MODS Metadata Elements -->
  
  <!-- ADD PARAMS -->
   
  <xsl:param name="sysID"/>
  
  <xsl:param name="keyword"/>
  <xsl:param name="keyword-join"/>
  <xsl:param name="keyword-prox"/>
  <xsl:param name="keyword-exclude"/>
  <xsl:param name="keyword-max"/>

  <xsl:param name="fieldList"/>
  
  <xsl:param name="title-keyword"/>
  <xsl:param name="title-keyword-join"/>
  <xsl:param name="title-keyword-prox"/>
  <xsl:param name="title-keyword-exclude"/>
  <xsl:param name="title-keyword-max"/>
  
  <xsl:param name="title-main"/>
  <xsl:param name="title-main-join"/>
  <xsl:param name="title-main-prox"/>
  <xsl:param name="title-main-exclude"/>
  <xsl:param name="title-main-max"/>

  <xsl:param name="author-keyword"/>
  <xsl:param name="author-keyword-join"/>
  <xsl:param name="author-keyword-prox"/>
  <xsl:param name="author-keyword-exclude"/>
  <xsl:param name="author-keyword-max"/>
  
  <xsl:param name="author"/>
  <xsl:param name="author-join"/>
  <xsl:param name="author-prox"/>
  <xsl:param name="author-exclude"/>
  <xsl:param name="author-max"/>

  <xsl:param name="author-corporate"/>
  <xsl:param name="author-corporate-join"/>
  <xsl:param name="author-corporate-prox"/>
  <xsl:param name="author-corporate-exclude"/>
  <xsl:param name="author-corporate-max"/>

  <xsl:param name="publisher"/>
  <xsl:param name="publisher-join"/>
  <xsl:param name="publisher-prox"/>
  <xsl:param name="publisher-exclude"/>
  <xsl:param name="publisher-max"/>

  <xsl:param name="pub-place"/>
  <xsl:param name="pub-place-join"/>
  <xsl:param name="pub-place-prox"/>
  <xsl:param name="pub-place-exclude"/>
  <xsl:param name="pub-place-max"/>

  <xsl:param name="language"/>
  <xsl:param name="language-join"/>
  <xsl:param name="language-prox"/>
  <xsl:param name="language-exclude"/>
  <xsl:param name="language-max"/>
  
  <xsl:param name="note-keyword"/>
  <xsl:param name="note-keyword-join"/>
  <xsl:param name="note-keyword-prox"/>
  <xsl:param name="note-keyword-exclude"/>
  <xsl:param name="note-keyword-max"/>
  
  <xsl:param name="note"/>
  <xsl:param name="note-join"/>
  <xsl:param name="note-prox"/>
  <xsl:param name="note-exclude"/>
  <xsl:param name="note-max"/>
  
  <xsl:param name="abstract"/>
  <xsl:param name="abstract-join"/>
  <xsl:param name="abstract-prox"/>
  <xsl:param name="abstract-exclude"/>
  <xsl:param name="abstracte-max"/>

  <xsl:param name="toc"/>
  <xsl:param name="toc-join"/>
  <xsl:param name="toc-prox"/>
  <xsl:param name="toc-exclude"/>
  <xsl:param name="toc-max"/>

  <xsl:param name="subject"/>
  <xsl:param name="subject-join"/>
  <xsl:param name="subject-prox"/>
  <xsl:param name="subject-exclude"/>
  <xsl:param name="subject-max"/>

  <xsl:param name="subject-topic"/>
  <xsl:param name="subject-topic-join"/>
  <xsl:param name="subject-topic-prox"/>
  <xsl:param name="subject-topic-exclude"/>
  <xsl:param name="subject-topic-max"/>

  <xsl:param name="subject-temporal"/>
  <xsl:param name="subject-temporal-join"/>
  <xsl:param name="subject-temporal-prox"/>
  <xsl:param name="subject-temporal-exclude"/>
  <xsl:param name="subject-temporal-max"/>

  <xsl:param name="subject-geographic"/>
  <xsl:param name="subject-geographic-join"/>
  <xsl:param name="subject-geographic-prox"/>
  <xsl:param name="subject-geogrpahic-exclude"/>
  <xsl:param name="subject-geographic-max"/>

  <xsl:param name="title-series"/>
  <xsl:param name="title-series-join"/>
  <xsl:param name="title-series-prox"/>
  <xsl:param name="title-series-exclude"/>
  <xsl:param name="title-series-max"/>

  <xsl:param name="title-journal"/>
  <xsl:param name="title-journal-join"/>
  <xsl:param name="title-journal-prox"/>
  <xsl:param name="title-journal-exclude"/>
  <xsl:param name="title-journal-max"/>

  <xsl:param name="location"/>
  <xsl:param name="location-join"/>
  <xsl:param name="location-prox"/>
  <xsl:param name="location-exclude"/>
  <xsl:param name="location-max"/>

  <xsl:param name="identifier-isbn"/>
  <xsl:param name="identifier-isbn-join"/>
  <xsl:param name="identifier-isbn-prox"/>
  <xsl:param name="identifier-isbn-exclude"/>
  <xsl:param name="identifier-isbn-max"/>

  <xsl:param name="identifier-issn"/>
  <xsl:param name="identifier-issn-join"/>
  <xsl:param name="identifier-issn-prox"/>
  <xsl:param name="identifier-issn-exclude"/>
  <xsl:param name="identifier-issn-max"/>

  <xsl:param name="callnum-class"/>
  <xsl:param name="callnum-class-join"/>
  <xsl:param name="callnum-class-prox"/>
  <xsl:param name="callnum-class-exclude"/>
  <xsl:param name="callnum-class-max"/>

  <xsl:param name="year"/>
  <xsl:param name="year-join"/>
  <xsl:param name="year-prox"/>
  <xsl:param name="year-exclude"/>
  <xsl:param name="year-max"/>
  
  <!-- ====================================================================== -->
  <!-- Root Template                                                          -->
  <!-- ====================================================================== -->

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$smode = 'test'">
        <xsl:apply-templates select="crossQueryResult" mode="test"/>
      </xsl:when>
      <xsl:when test="$rmode = 'viewAll'">
        <xsl:apply-templates select="crossQueryResult" mode="viewAll"/>
      </xsl:when>
      <xsl:when test="$rmode = 'objview'">
        <xsl:apply-templates select="crossQueryResult" mode="objview"/>
      </xsl:when>
      <xsl:when test="contains($smode, '-modify')">
        <xsl:apply-templates select="crossQueryResult" mode="form"/>
      </xsl:when>
      <!-- ADD TO LIST -->
      <xsl:when test="
        $keyword or
        $title-keyword or
        $author-keyword or
        $note-keyword or
        $title-main or 
        $author or
        $author-corporate or
        $publisher or
        $pub-place or
        $language or
        $abstract or
        $toc or
        $note or
        $subject or
        $subject-topic or
        $subject-temporal or
        $subject-geographic or
        $title-series or
        $title-journal or
        $location or
        $format or
        $identifier-isbn or
        $identifier-issn or
        $callnum-class or
        $year or
        $sysID">
        <xsl:apply-templates select="crossQueryResult" mode="results"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="crossQueryResult" mode="form"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Form Template                                                          -->
  <!-- ====================================================================== -->

  <xsl:template match="crossQueryResult" mode="form">
    <html>
      <head>
        <title>XTF: Search Form</title>
      </head>
      <body>
        <div align="center">
          <h3>Melvyl Recommender Search</h3>
            
          <form method="get" action="{$xtfURL}{$crossqueryPath}">
            <table cellpadding="10" cellspacing="10" border="0" style="border: double blue">
              <tr>
                <td valign="top" style="border-right: solid blue">
                  <table cellpadding="2" cellspacing="2" border="0">
                    <tr>
                      <td width="250"><b>All Fields</b></td>
                      <td align="right">
                        <input type="text" name="keyword" size="20" value="{$keyword}"/>
                      </td>
                    </tr>
                    <tr>
                      <td colspan="2"><hr/></td>
                    </tr>
                    <tr>
                      <td width="250"><b>All Titles</b></td>
                      <td align="right">
                        <input type="text" name="title-keyword" size="20" value="{$title-keyword}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Main Title</b></td>
                      <td>
                        <input type="checkbox" name="title-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="title-main" size="20" value="{$title-main}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Series Title</b></td>
                      <td>
                        <input type="checkbox" name="title-series-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="title-series" size="20" value="{$title-series}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Journal Title</b></td>
                      <td>
                        <input type="checkbox" name="title-journal-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="title-journal" size="20" value="{$title-journal}"/>
                      </td>
                    </tr>
                    <tr>
                      <td colspan="2"><hr/></td>
                    </tr>
                    <tr>
                      <td width="250"><b>All Authors</b></td>
                      <td align="right">
                        <input type="text" name="author-keyword" size="20" value="{$author-keyword}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Personal Author</b></td>
                      <td>
                        <input type="checkbox" name="author-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="author" size="20" value="{$author}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Organization Author</b></td>
                      <td>
                        <input type="checkbox" name="author-corporate-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="author-corporate" size="20" value="{$author-corporate}"/>
                      </td>
                    </tr>
                    <tr>
                      <td colspan="2"><hr/></td>
                    </tr>
                    <tr>
                      <td width="250"><b>LCSH Subject</b></td>
                      <td>
                        <input type="checkbox" name="subject-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="subject" size="20" value="{$subject}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Topical Subject</b></td>
                      <td>
                        <input type="checkbox" name="subject-topic-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="subject-topic" size="20" value="{$subject-topic}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Temporal Subject</b></td>
                      <td>
                        <input type="checkbox" name="subject-temporal-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="subject-temporal" size="20" value="{$subject-temporal}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Geographic Subject</b></td>
                      <td>
                        <input type="checkbox" name="subject-geographic-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="subject-geographic" size="20" value="{$subject-geographic}"/>
                      </td>
                    </tr>
                    <tr>
                      <td colspan="2"><hr/></td>
                    </tr>
                    <tr>
                      <td width="250"><b>Publisher</b></td>
                      <td>
                        <input type="checkbox" name="publisher-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="publisher" size="20" value="{$publisher}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Place of Publication</b></td>
                      <td>
                        <input type="checkbox" name="pub-place-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="pub-place" size="20" value="{$pub-place}"/>
                      </td>
                    </tr>
                  </table>
                </td>
                <td valign="top" style="border-left: solid blue">
                  <table cellpadding="2" cellspacing="2" border="0">
                    <tr>
                      <td width="250"><b>All Descriptive Fields</b></td>
                      <td align="right">
                        <input type="text" name="note-keyword" size="20" value="{$note-keyword}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Abstract</b></td>
                      <td align="right">
                        <input type="checkbox" name="abstract-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="abstract" size="20" value="{$abstract}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Note(s)</b></td>
                      <td align="right">
                        <input type="checkbox" name="note-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="note" size="20" value="{$note}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Table of Contents</b></td>
                      <td align="right">
                        <input type="checkbox" name="toc-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="toc" size="20" value="{$toc}"/>
                      </td>
                    </tr>
                    <tr>
                      <td colspan="2"><hr/></td>
                    </tr>
                    <tr>
                      <td colspan="2"><b>Identifiers</b></td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>ISBN</b></td>
                      <td align="right">
                        <input type="checkbox" name="identifier-isbn-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="identifier-isbn" size="20" value="{$identifier-isbn}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>ISSN</b></td>
                      <td align="right">
                        <input type="checkbox" name="identifier-issn-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="identifier-issn" size="20" value="{$identifier-issn}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>CALL NUMBER CLASS</b></td>
                      <td align="right">
                        <input type="checkbox" name="callnum-class-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="callnum-class" size="20" value="{$callnum-class}"/>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>SYSID</b></td>
                      <td align="right">
                        <input type="checkbox" name="sysID-join" value="exact"/>
                        <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                        <input type="text" name="sysID" size="20" value="{$sysID}"/>
                      </td>
                    </tr>
                    <tr>
                      <td colspan="2"><hr/></td>
                    </tr>
                    <tr>
                      <td colspan="2"><b>Limits</b></td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Language</b></td>
                      <td align="right">
                        <select name="language">
                          <option value="">ALL</option>
                          <option value="eng">English</option>
                          <option value="fra">French</option>
                          <option value="ger">German</option>
                          <option value="ita">Italian</option>
                          <option value="lat">Latin</option>
                          <option value="rus">Russian</option>
                          <option value="spa">Spanish</option>
                          <option value="jap">Japanese</option>
                          <option value="chi">Chinese</option>
                        </select>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Format</b></td>
                      <td align="right">
                        <select name="format">
                          <option value="">ALL</option>
                          <option value="BK">BK</option>
                          <option value="CF">CF</option>
                          <option value="MP">MP</option>
                          <option value="MU">MU</option>
                          <option value="MX">MX</option>
                          <option value="SE">SE</option>
                          <option value="VM">VM</option>
                        </select>
                      </td>
                    </tr>
                    <tr>
                      <td width="250">&#160;&#160;&#160;&#160;<b>Location</b></td>
                      <td align="right">
                        <select name="location">
                          <option value="">ALL</option>
                          <option value="LAGE">UC Los Angeles</option>
                          <option value="GLAD">UC Berkeley</option>
                        </select>
                      </td>
                    </tr>
                    <tr>
                      <td width="250" valign="top">&#160;&#160;&#160;&#160;<b>Year</b></td>
                      <td align="right">
                        <table>
                          <tr>
                            <td><input type="text" name="year" size="5" value="{$year}"/></td>
                            <td width="5"/>
                            <td><input type="text" name="year-max" size="5" value="{$year-max}"/></td>
                          </tr>
                          <tr>
                            <td align="center"><xsl:text>From</xsl:text></td>
                            <td width="5"/>
                            <td align="center"><xsl:text>To</xsl:text></td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                    <tr>
                      <td colspan="2"><hr/></td>
                    </tr>
                    <tr>
                      <td width="250" valign="top"><b>Boost</b></td>
                      <td align="right">
                        <xsl:text>None&#160;</xsl:text>
                        <input type="radio" name="weight" value="0" checked="checked"/><br/>
                        <xsl:text>Circulation&#160;</xsl:text>
                        <input type="radio" name="weight" value="1"/><br/>
                        <xsl:text>Charges Only&#160;</xsl:text>
                        <input type="radio" name="weight" value="2"/>
                      </td>
                    </tr>
                    <tr>
                      <td colspan="2"><hr/></td>
                    </tr>
                    <!-- ADD TO FORM -->
                    <tr>
                      <td width="250"/>
                      <td height="40" align="center">
                        <input type="hidden" name="style" value="{$style}"/>
                        <input type="hidden" name="brand" value="{$brand}"/>
                        <input type="submit" value="Search"/>
                        <input type="reset" OnClick="location.href='{$xtfURL}{$crossqueryPath}?style=melrec'" value="Clear"/>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </form>
        </div>
      </body>
    </html>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Results Template                                                       -->
  <!-- ====================================================================== -->

  <xsl:template match="crossQueryResult" mode="results">

    <xsl:variable name="modifyString" select="replace($queryString, '(smode=[A-Za-z0-9]*)', '$1-modify')"/>

    <html>
      <head>
        <title>XTF: Search Results</title>
      </head>
      <body>
        <div align="center">
          <table cellpadding="2" cellspacing="2" border="0" width="95%" style="border: double blue">
            <tr>
              <td colspan="2" valign="top" align="left">
                <span class="heading">Results: </span>
                <xsl:value-of select="@totalDocs"/>
                <xsl:text> Item(s)</xsl:text>
              </td>
              <td align="center">
                <table cellpadding="2" cellspacing="2" border="0" width="50%">
                  <tr>
                    <td align="center" valign="top">
                      <xsl:call-template name="pages"/>
                    </td>
                    <td align="center" valign="top">
                      <form  method="get" action="{$xtfURL}{$crossqueryPath}">
                        <xsl:for-each select="parameters/param[not(matches(@name, 'sort'))]">
                          <input type="hidden">
                            <xsl:attribute name="name">
                              <xsl:value-of select="@name"/>
                            </xsl:attribute>
                            <xsl:attribute name="value">
                              <xsl:value-of select="@value"/>
                            </xsl:attribute>
                          </input>
                        </xsl:for-each>
                        <xsl:call-template name="sort.options"/>
                        <input type="submit" value="Sort"/>
                      </form>
                    </td>
                  </tr>
                </table>
              </td>
              <td valign="top" align="center">
                <xsl:text>Relevance</xsl:text>
              </td>
            </tr>
            <tr>
              <td colspan="2" align="left">
                <xsl:text>Query Time: </xsl:text>
                <xsl:value-of select="@queryTime"/>
              </td>
              <td align="center">
                <table cellpadding="2" cellspacing="2" border="0" width="50%">
                  <tr>
                    <td align="center">
                      <xsl:text>Query: </xsl:text>
                      <xsl:for-each select="parameters/param[not(matches(@name, 'brand|style|weight'))]">
                        <xsl:value-of select="@name"/>
                        <xsl:text>=</xsl:text>
                        <xsl:value-of select="@value"/>
                        <xsl:if test="position() != last()">
                          <xsl:text>, </xsl:text>
                        </xsl:if>
                      </xsl:for-each>
                    </td>
                    <td align="center">
                      <a href="search?style=melrec&amp;rmode=viewAll">Browse Metadata</a>
                    </td>
                  </tr>
                </table>
              </td>
              <td align="center">
                <xsl:text>(Boost: </xsl:text>
                <xsl:value-of select="parameters/param[@name='weight']/@value"/>
                <xsl:text>)</xsl:text>
              </td>
            </tr>
            <xsl:if test="docHit">
              <tr>
                <td colspan="4">
                  <hr size="1"/>
                </td>
              </tr>    
              <xsl:apply-templates select="docHit"/>
            </xsl:if>
          </table>
        </div>
      </body>
    </html>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Document Hit Template                                                       -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit">

    <tr>
      <td align="right"  valign="top" width="4%">
        <xsl:choose>
          <xsl:when test="$sort != 'title' and $sort != 'creator' and $sort != 'year'">
            <span class="heading"><xsl:value-of select="@rank"/></span>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>&#160;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td align="right"  valign="top" width="10%">
        <span class="heading">Author:&#160;&#160;</span>
      </td>
      <td align="left" valign="top">
        <xsl:choose>
          <xsl:when test="meta/author">
            <xsl:apply-templates select="meta/author[1]"/>
          </xsl:when>
          <xsl:when test="meta/author-corporate">
            <xsl:apply-templates select="meta/author-corporate[1]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>NA</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td align="center"  valign="top">
        <span class="heading"><xsl:value-of select="@score"/></span>
      </td>
    </tr>
    <tr>
      <td align="right" valign="top">
        <xsl:text>&#160;</xsl:text>
      </td>
      <td align="right" valign="top">
        <span class="heading">Title:&#160;&#160;</span>
      </td>
      <td align="left" valign="top">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="crossquery.url">
              <xsl:with-param name="sysID" select="meta/sysID"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="meta/title-main[1]"/>
        </a>
      </td>
      <td align="center" valign="top">
        <xsl:text>&#160;</xsl:text>
      </td>
    </tr>
    <xsl:if test="meta/subject">
      <tr>
        <td align="right" valign="top">
          <xsl:text>&#160;</xsl:text>
        </td>
        <td align="right" valign="top">
          <span class="heading">Subject:&#160;&#160;</span>
        </td>
        <td align="left" valign="top">
          <xsl:apply-templates select="meta/subject"/>
        </td>
        <td align="center" valign="top">
          <xsl:text>&#160;</xsl:text>
        </td>
      </tr>
    </xsl:if>
    <xsl:if test="meta/title-series">
      <tr>
        <td align="right" valign="top">
          <xsl:text>&#160;</xsl:text>
        </td>
        <td align="right" valign="top">
          <span class="heading">Series:&#160;&#160;</span>
        </td>
        <td align="left" valign="top">
          <xsl:apply-templates select="meta/title-series[1]"/>
        </td>
        <td align="center" valign="top">
          <xsl:text>&#160;</xsl:text>
        </td>
      </tr>
    </xsl:if>
    <xsl:if test="meta/title-journal">
      <tr>
        <td align="right" valign="top">
          <xsl:text>&#160;</xsl:text>
        </td>
        <td align="right" valign="top">
          <span class="heading">Journal:&#160;&#160;</span>
        </td>
        <td align="left" valign="top">
          <xsl:apply-templates select="meta/title-journal[1]"/>
        </td>
        <td align="center" valign="top">
          <xsl:text>&#160;</xsl:text>
        </td>
      </tr>
    </xsl:if>
    <xsl:if test="meta/sysID">
      <tr>
        <td align="right" valign="top">
          <xsl:text>&#160;</xsl:text>
        </td>
        <td align="right" valign="top">
          <span class="heading">SYSID:&#160;&#160;</span>
        </td>
        <td align="left" valign="top">
          <xsl:apply-templates select="meta/sysID[1]"/>
        </td>
        <td align="center" valign="top">
          <xsl:text>&#160;</xsl:text>
        </td>
      </tr>
    </xsl:if>
    <!-- ADD MORE DISPLAY FIELDS HERE -->
    <tr>
      <td colspan="4">
        <hr size="1" width="100%"/>
      </td>
    </tr>
    
  </xsl:template>
    
  <!-- ====================================================================== -->
  <!-- Snippet Template                                                       -->
  <!-- ====================================================================== -->

  <xsl:template match="snippet[parent::docHit]">
    <span class="search-results-snippet">
      <xsl:text>...</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>...</xsl:text>
    </span>
    <br/>
  </xsl:template>   
  
  <!-- ====================================================================== -->
  <!-- Hit Template                                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="hit">
    <xsl:apply-templates/>
  </xsl:template>
    
  <!-- ====================================================================== -->
  <!-- Term Template                                                          -->
  <!-- ====================================================================== -->
 
  <xsl:template match="term">
    <span style="color: red">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
    
  <!-- ====================================================================== -->
  <!-- crossQuery Object Link                                                 -->
  <!-- ====================================================================== -->  
  
  <xsl:template name="crossquery.url">
    
    <xsl:param name="sysID"/>
    <xsl:variable name="query" select="$queryString"/>
    
    <xsl:value-of select="concat($crossqueryPath, '?sysID=', $sysID, '&amp;', $query,'&amp;style=melrec&amp;rmode=objview')"/>
    
  </xsl:template>
      
  <!-- ====================================================================== -->
  <!-- Object View Templates                                                  -->
  <!-- ====================================================================== -->  
  
  <xsl:template match="crossQueryResult" mode="objview">
       
    <html>
      <head>
        <title>
          <xsl:value-of select="concat('Record: ', $sysID)"/>
        </title>
      </head>
      <body bgcolor="white">
        <div align="left">
          <xsl:text>[</xsl:text>
          <a href="search?style=melrec">New Search</a>
          <xsl:text>]</xsl:text>
        </div>
        <div align="center">
          <h3>Record: <xsl:value-of select="$sysID"/></h3>
          <table width="95%" border="1" cellpadding="2" cellspacing="2" style="border: double blue">
            <tr>
              <td align="center">INDEX FIELD</td>
              <td align="center">CONTENT</td>
            </tr>
            <xsl:apply-templates select="docHit/meta/*" mode="objview"/>
            <!-- AMAZON -->
            <xsl:if test="docHit/meta/identifier-isbn">
              <xsl:variable name="awsID">
                <xsl:analyze-string select="docHit/meta/identifier-isbn[1]" regex="([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])">
                  <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                  </xsl:matching-substring>
                </xsl:analyze-string>
              </xsl:variable>
              <xsl:variable name="AWS" select="document(concat('http://webservices.amazon.com/onca/xml?Service=AWSECommerceService&amp;SubscriptionId=1X3XCKDVXDSSQ4V69HG2&amp;Operation=ItemLookup&amp;ResponseGroup=Similarities&amp;ItemId=', $awsID))"/>
              <xsl:if test="$AWS//*[local-name()='SimilarProduct']">
                <tr>
                  <td valign="top">Amazon customers also bought:</td>
                  <td>
                    <xsl:apply-templates select="$AWS//*[local-name()='SimilarProduct']" mode="objview"/>
                  </td>
                </tr>
              </xsl:if>
            </xsl:if>
            <!-- END AMAZON -->
          </table>
        </div>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="*[local-name()='SimilarProduct']" mode="objview">
    <a>
      <xsl:attribute name="href">
        <xsl:text>http://www.amazon.com/exec/obidos/tg/detail/-/</xsl:text>
        <xsl:value-of select="*[local-name()='ASIN']"/>
      </xsl:attribute>
      <xsl:value-of select="*[local-name()='Title']"/>
    </a>
    <br/>
  </xsl:template>
  
  <xsl:template match="*" mode="objview">
    <tr>
      <td>
        <xsl:value-of select="string(name())"/>
      </td>
      <td>
        <xsl:apply-templates/>
      </td>
    </tr>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Metadata Browse                                                        -->
  <!-- ====================================================================== -->
    
  <xsl:template match="crossQueryResult" mode="viewAll">
    <xsl:variable name="groupString" select="replace(replace($queryString, '[&amp;]*startGroup=[0-9]+', ''), '[&amp;]*group=[0-9A-Za-z\-\+:''%% ]+', '')"/>
    <xsl:variable name="sortString" select="replace($groupString, '[&amp;]*sortGroupsBy=[0-9A-Za-z\-\+''%% ]+', '')"/>
    
    <html>
      <head>
        <title>Metadata Browse</title>
      </head>
      <body style="margin: 5%">
        <table style="border: 1px solid black" width="100%" border="0" cellpadding="0" cellspacing="0">  
          <tr>
            <td align="center">
              <a href="search?style=melrec&amp;facet=title-main&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">title-main</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=melrec&amp;facet=title-series&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">title-series</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=melrec&amp;facet=title-journal&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">title-journal</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=melrec&amp;facet=author&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">author</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=melrec&amp;facet=author-corporate&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">author-corporate</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=melrec&amp;facet=publisher&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">publisher</a>
              <br/>
              <a href="search?style=melrec&amp;facet=language&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">language</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=melrec&amp;facet=subject&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">subject</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=melrec&amp;facet=subject-geographic&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">subject-geographic</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=melrec&amp;facet=subject-temporal&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">subject-temporal</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=melrec&amp;facet=subject-topic&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">subject-topic</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=melrec&amp;facet=format&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">format</a>
              <xsl:text> | </xsl:text>
              <a href="search?style=melrec&amp;facet=callnum-class&amp;location=LAGE&amp;rmode=viewAll&amp;groupsPerPage=100">callnum-class</a>
            </td>
          </tr>
          <xsl:if test="facet">
            <xsl:variable name="missing">
              <xsl:choose>
                <xsl:when test="facet/group[@value='1 MISSING']">
                  <xsl:value-of select="number(facet/group[@value='1 MISSING']/@totalDocs)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="number(0)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <tr>
              <td align="center" style="border: solid black 1px">
                <h4>dc element: <xsl:value-of select="$facet"/></h4>
                <p>(Present in <xsl:value-of select="number(facet/@totalDocs) - $missing"/> of <xsl:value-of select="@totalDocs"/> records.)</p>
                <xsl:call-template name="page-summary">
                  <xsl:with-param name="object-type" select="'Groups'"/>
                  <xsl:with-param name="groups" select="'yes'"/>
                </xsl:call-template>
                <br/>
                <xsl:call-template name="pages">
                  <xsl:with-param name="groups" select="'yes'"/>
                </xsl:call-template>
                <br/>
                <xsl:choose>
                  <xsl:when test="$sortGroupsBy='value'">
                    <xsl:text>Sort by: </xsl:text>
                    <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortGroupsBy=totalDocs">count</a>
                    <xsl:text> | alpha</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Sort by: </xsl:text>
                    <xsl:text>count | </xsl:text>
                    <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortGroupsBy=value">alpha</a>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
            <tr>
              <td>
                <ol>
                  <xsl:apply-templates select="facet/group" mode="browseGroups"/>
                </ol>
              </td>
            </tr>
          </xsl:if>
        </table>
      </body>
    </html>
    
  </xsl:template>
  
  <xsl:template match="group" mode="browseGroups">
    <xsl:variable name="facet" select="replace(replace(parent::facet/@field, 'facet-', ''), '-[0-9]+', '')"/>
    <xsl:variable name="value" select="replace(@value, '\+', '%2B')"/>
    <li value="{@rank}">
      <a href="{$xtfURL}{$crossqueryPath}?location=LAGE&amp;{$facet}={$value}&amp;{$facet}-join=exact&amp;style={$style}">
        <xsl:value-of select="@value"/>
      </a>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="@totalDocs"/>
      <xsl:text>) </xsl:text>
    </li>
  </xsl:template>
    
</xsl:stylesheet>
