<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<!--
   Copyright (c) 2006, Regents of the University of California
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

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="../common/resultFormatterCommon.xsl"/>

  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->
    
  <!-- Number of <td> elements in a <tr> -->
  <xsl:param name="gridFactor" select="5"/>
  <!-- Caption string length -->
  <xsl:param name="captionLength" select="40"/>
  
  <!-- ====================================================================== -->
  <!-- Primary Grid Template                                                  -->
  <!-- ====================================================================== -->
  
  <xsl:template name="content-primary-grid">
    <div id="content-primary">
      <xsl:comment>BEGIN SEARCH RESULTS TABLE</xsl:comment>
      <div id="displayresults">
        <table border="0">
          <xsl:choose>
            <xsl:when test="facet/group[@value=$group]/docHit">
              <xsl:apply-templates select="facet/group[@value=$group]/docHit" mode="grid"/>
            </xsl:when>
            <xsl:when test="facet/group[@value='image']/docHit">
              <xsl:apply-templates select="facet/group[@value='image']/docHit" mode="grid"/>
            </xsl:when>
          </xsl:choose>
        </table>
      </div>
      <xsl:comment>END RESULTS TABLE</xsl:comment>
      <div class="results-tools">
        <div id="results-tools-bottom">
          <div class="hitcount-pag">
            <div class="hitcount">
              <xsl:call-template name="page-summary">
                <xsl:with-param name="object-type">
                  <xsl:choose>
                    <xsl:when test="facet/group[@value='image']/docHit">images</xsl:when>
                    <xsl:when test="facet/group[@value='text']/docHit">texts</xsl:when>
                    <xsl:otherwise>websites</xsl:otherwise>
                  </xsl:choose>
                </xsl:with-param>
              </xsl:call-template>
            </div>
            <div class="pagination">
              <xsl:call-template name="pages"/>
            </div>
            <br clear="all" />
          </div>
        </div>
      </div>
    </div>
    
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Grid Document Hit Template                                             -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit" mode="grid">
    
    <xsl:variable name="fullark" select="meta/identifier[1]"/>
    <xsl:variable name="xy">
      <xsl:call-template name="scale-max">
        <xsl:with-param name="max" select="100"/>
        <xsl:with-param name="x" select="meta/thumbnail/@X"/>
        <xsl:with-param name="y" select="meta/thumbnail/@Y"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="height" select="$xy/xy/@height"/>
    <xsl:variable name="width" select="$xy/xy/@width"/>
    
    <xsl:if test="position() mod $gridFactor = 1">
      <xsl:comment>BEGIN SEARCH RESULTS ROW</xsl:comment>
      <xsl:text disable-output-escaping="yes"><![CDATA[<tr>]]></xsl:text>
    </xsl:if>   
    <xsl:comment>BEGIN SEARCH RESULTS SINGLE ITEM</xsl:comment>
    <td width="20%">
      <!--<xsl:if test="(position() = last()) and ((position() mod $gridFactor) != 0)">
        <xsl:attribute name="colspan" select="($gridFactor + 1) - (position() mod $gridFactor)"/>
        </xsl:if>-->
      <div class="dochit">
        <div class="thumbnail nifty7">
          <div class="box7">
            <a>
              <xsl:attribute name="href">
                <xsl:call-template name="dynaxml.url">
                  <xsl:with-param name="fullark" select="$fullark"/>
                </xsl:call-template>
              </xsl:attribute>
              <img height="{$height}" width="{$width}" alt="" title="{meta/title[1]}" border="0">
                <xsl:attribute name="src">
                  <!--<xsl:text>http://ark.cdlib.org/</xsl:text>-->
                  <xsl:value-of select="replace(meta/identifier[1],'^http://ark.cdlib.org','')"/>
                  <xsl:text>/thumbnail</xsl:text>
                </xsl:attribute>
              </img>
            </a>
          </div>
        </div>
        <div class="citation">
          <xsl:choose>
            <xsl:when test="string-length(normalize-space(string(meta/title[1]))) &lt; $captionLength">
              <xsl:value-of select="normalize-space(string(meta/title[1]))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring(normalize-space(string(meta/title[1])),1,$captionLength)"/>
              <xsl:value-of select="'...'"/>
            </xsl:otherwise>
          </xsl:choose>
        </div>
        <!--<div class="details">
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="dynaxml.url">
                <xsl:with-param name="fullark" select="$fullark"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:text>details</xsl:text>
          </a>
        </div>-->
      </div>
    </td>
    <!-- Empty TD padding -->
    <xsl:if test="(position() = last()) and ((position() mod $gridFactor) != 0)">
      <td width="20%">&#160;</td>
      <xsl:choose>
        <xsl:when test="($gridFactor - (position() mod $gridFactor)) = 2">
          <td width="20%">&#160;</td>
        </xsl:when>
        <xsl:when test="($gridFactor - (position() mod $gridFactor)) = 3">
          <td width="20%">&#160;</td>
          <td width="20%">&#160;</td>
        </xsl:when>
        <xsl:when test="($gridFactor - (position() mod $gridFactor)) = 4">
          <td width="20%">&#160;</td>
          <td width="20%">&#160;</td>
          <td width="20%">&#160;</td>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:comment>END SEARCH RESULTS SINGLE ITEM</xsl:comment>
    <xsl:if test="position() mod $gridFactor = 0">
      <xsl:text disable-output-escaping="yes"><![CDATA[</tr>]]></xsl:text>
      <xsl:comment>END SEARCH RESULTS ROW</xsl:comment>
    </xsl:if>
    
  </xsl:template>
  
</xsl:stylesheet>
