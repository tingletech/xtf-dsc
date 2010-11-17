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

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="../common/resultFormatterCommon.xsl"/>

  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->
    
  
  
  <!-- ====================================================================== -->
  <!-- Primary List Template                                                  -->
  <!-- ====================================================================== -->
  
  <xsl:template name="content-primary-list">
    <div id="content-primary">
      <xsl:choose>
        <xsl:when test="facet/group[@value=$group]/docHit">
          <xsl:apply-templates select="facet/group[@value=$group]/docHit" mode="list"/>
        </xsl:when>
        <xsl:when test="facet/group[@value='text']/docHit">
          <xsl:apply-templates select="facet/group[@value='text']/docHit" mode="list"/>
        </xsl:when>
        <xsl:when test="facet/group[@value='website']/docHit">
          <xsl:apply-templates select="facet/group[@value='website']/docHit" mode="list"/>
        </xsl:when>
      </xsl:choose>
      <div class="results-tools">
        <div id="results-tools-bottom">
          <div class="hitcount-pag">
            <div class="hitcount">
              <xsl:call-template name="page-summary">
                <xsl:with-param name="object-type">
                  <xsl:choose>
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
  <!-- List Document Hit Template                                             -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit" mode="list">
    
    <xsl:variable name="fullark" select="meta/identifier[1]"/>
    
    <div class="dochit">
      <div class="item">
        <xsl:value-of select="@rank"/>
      </div>
      <div class="citation">
        <xsl:choose>
          <xsl:when test="meta/facet-type-tab='website'">
            <xsl:if test="meta/title">
              <a href="{meta/identifier[1]}">
                <xsl:value-of select="meta/title[1]"/>
              </a>
            </xsl:if>
            <xsl:if test="meta/description">
              <div class="description">
                <xsl:apply-templates select="meta/description[1]"/>
              </div>
            </xsl:if>
            <xsl:if test="meta/publisher">
              <div class="source">
                <xsl:apply-templates select="meta/publisher[1]"/>
              </div>
            </xsl:if>
            <xsl:if test="meta/clrn_rated = 'rated'">
						<xsl:comment>
              <div class="description">
                <xsl:apply-templates select="meta/clrn_gradeLevel"/>
                <xsl:apply-templates select="meta/clrn_readingLevel"/>
              </div>
						</xsl:comment>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <a>
              <xsl:attribute name="href">
                <xsl:call-template name="dynaxml.url">
                  <xsl:with-param name="fullark" select="$fullark"/>
                </xsl:call-template>
              </xsl:attribute>
              <xsl:apply-templates select="meta/title[1]" mode="trim"/>
            </a>
            <xsl:if test="snippet">
              <div class="snippets">
                <xsl:apply-templates select="snippet"/>
              </div>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <xsl:text disable-output-escaping="yes"><![CDATA[<br clear="all"/>]]></xsl:text>
    </div>
    
  </xsl:template>

  <xsl:template match="clrn_readingLevel">
Reading Level: <xsl:value-of select="."/>
<xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="clrn_gradeLevel">
Grade Level: <xsl:value-of select="."/>
<xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="*" mode="trim">
    <xsl:variable name="string" select="."/>
    <xsl:choose>
      <xsl:when test="matches($string , '.{200}')">
        <xsl:value-of select="replace($string, '(.{200}).+', '$1')"/>
        <xsl:text> . . . </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
