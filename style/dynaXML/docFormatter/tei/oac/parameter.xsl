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
                              xmlns:mods="http://www.loc.gov/mods/v3"
                              xmlns:dc="http://purl.org/dc/elements/1.1/">
  
  <!-- Removing port for CDL -->
  
  <xsl:param name="icon.path" select="concat($xtfURL, 'icons/oac/')"/>

  <xsl:param name="css.path" select="concat($xtfURL, 'css/oac/')"/>

  <xsl:param name="fig.ent" select="'0'"/>

  <xsl:param name="formula.id" select="'0'"/>

  <!-- old version -->
  <!--<xsl:param name="doc.title">
    <xsl:choose>
      <xsl:when test="contains($collection, 'fbull') or contains($collection, 'siopub')">
        <xsl:value-of select="/TEI.2/text/front/titlePage/docTitle/titlePart[@type='main'][1]"/>
      </xsl:when>
      <xsl:when test="contains($collection, 'seaadoc')">
        <xsl:value-of select="/TEI.2/teiHeader/fileDesc/sourceDesc/biblFull/titleStmt/title"/>
      </xsl:when>
      <xsl:when test="contains($collection, 'fsm')">
        <xsl:value-of select="/TEI.2/teiHeader/fileDesc/sourceDesc/biblFull/titleStmt/title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="/TEI.2/teiHeader/fileDesc/sourceDesc/bibl/title"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>-->

  <xsl:param name="doc.title">
    <xsl:choose>
      <xsl:when test="/TEI.2/teiHeader/fileDesc/sourceDesc/bibl/title">
        <xsl:value-of select="/TEI.2/teiHeader/fileDesc/sourceDesc/bibl/title[1]"/>
      </xsl:when>
      <xsl:when test="/TEI.2/teiHeader/fileDesc/sourceDesc/biblFull/titleStmt/title">
        <xsl:value-of select="/TEI.2/teiHeader/fileDesc/sourceDesc/biblFull/titleStmt/title[1]"/>
      </xsl:when>
      <xsl:when test="/TEI.2/text/front/titlePage/docTitle/titlePart[@type='main']">
        <xsl:value-of select="/TEI.2/text/front/titlePage/docTitle/titlePart[@type='main'][1]"/>
      </xsl:when>
      <xsl:when test="/TEI.2/text/front/titlePage/docTitle">
        <xsl:value-of select="/TEI.2/text/front/titlePage/docTitle/*"/>
      </xsl:when>
      <xsl:when test="/TEI.2/text/body/div1[1]/head">
        <xsl:value-of select="/TEI.2/text/body/div1[1]/head[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'[No title Available]'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="doc.subtitle" select="/TEI.2/text/front/titlePage/docTitle/titlePart[@type='sub'][1]"/>

  <xsl:param name="doc.author" select="/TEI.2/text/front/titlePage/docAuthor"/>

  <!-- xsl:param name="div.count" select="count(//div1)"/ -->
  <xsl:param name="div.count" select="/TEI.2/@div1Count"/>

  <!-- Any namespaces used here must be declared in the stylesheet element WITH the CORRECT URI or they won't match -->

  <xsl:variable name="collection">
    <xsl:choose>
      <xsl:when test="$METS//mods:relatedItem/mods:identifier">
        <xsl:choose>
          <xsl:when test="$METS//mods:relatedItem/mods:identifier[. = 'http://scilib.ucsd.edu/sio/guide/siopublns.html']">
            <xsl:value-of select="'http://scilib.ucsd.edu/sio/guide/siopublns.html'"/>
          </xsl:when>
          <xsl:when test="$METS//mods:relatedItem/mods:identifier[. = 'http://www.ucpress.edu']">
            <xsl:value-of select="'http://www.ucpress.edu'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$METS//mods:relatedItem/mods:identifier"/>
          </xsl:otherwise>
        </xsl:choose>      
      </xsl:when>
      <xsl:when test="$METS//dc:relation">
        <xsl:choose>
          <xsl:when test="$METS//dc:relation[. = 'http://scilib.ucsd.edu/sio/guide/siopublns.html']">
            <xsl:value-of select="'http://scilib.ucsd.edu/sio/guide/siopublns.html'"/>
          </xsl:when>
          <xsl:when test="$METS//dc:relation[. = 'http://www.ucpress.edu']">
            <xsl:value-of select="'http://www.ucpress.edu'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$METS//dc:relation"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>


  <!-- bct figure sniffing logic; tests for figures directory, if
	not there, assumes this was voroBasic'ed  -->

  <xsl:param name="servlet.dir" select="'/texts/xtf/'"/>
  
  <xsl:variable name="figure.dir" select="concat($servlet.dir , $sourceDir, 'figures')"/>
  
  <xsl:param name="figureStyle">
    <xsl:choose>
      <xsl:when test="FileUtils:exists($figure.dir)" xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils">
        <xsl:text>dynaXML</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>voroBasic</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

</xsl:stylesheet>
