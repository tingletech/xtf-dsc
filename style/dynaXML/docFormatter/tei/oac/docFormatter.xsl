<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- dynaXML Stylesheet                                                     -->
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

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xtf="http://cdlib.org/xtf" 
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:m="http://www.loc.gov/METS/"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:view="http://www.cdlib.org/view"
                xmlns:session="java:org.cdlib.xtf.xslt.Session">

<!-- ====================================================================== -->
<!-- Import Common Templates                                                -->
<!-- ====================================================================== -->

<xsl:import href="../../common/cdlDocFormatterCommon.xsl"/>

<!-- ====================================================================== -->
<!-- Output Format                                                          -->
<!-- ====================================================================== -->
  
<xsl:output method="html" indent="yes" encoding="UTF-8" media-type="text/html" 
  doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

<!-- ====================================================================== -->
<!-- Strip Space                                                            -->
<!-- ====================================================================== -->

<xsl:strip-space elements="*"/>

<!-- ====================================================================== -->
<!-- Included Stylesheets                                                   -->
<!-- ====================================================================== -->

<xsl:include href="autotoc.xsl"/>
<xsl:include href="component.xsl"/>
<xsl:include href="search.xsl"/>
<xsl:include href="parameter.xsl"/>
<xsl:include href="structure.xsl"/>
<xsl:include href="table.xsl"/>
<xsl:include href="titlepage.xsl"/>
<xsl:include href="http://ark.cdlib.org/data/mets/xslt/OAC-ETEXT/oac-text-breadcrumbs.xslt"/>


<!-- ====================================================================== -->
<!-- Define Keys                                                            -->
<!-- ====================================================================== -->

<xsl:key name="generic-id" match="note[not(@type='footnote' or @place='foot')]|pb|figure|table" use="@id"/>
<xsl:key name="hit-num-dynamic" match="xtf:hit" use="@hitNum"/>
<xsl:key name="hit-rank-dynamic" match="xtf:hit" use="@rank"/>
<xsl:key name="div-id" match="div1|div2|div3|div4|div5|div6|div7|div8" use="@id"/>
<xsl:key name="fnote-id" match="note[@type='footnote' or @place='foot']" use="@id"/>
<xsl:key name="formula-id" match="formula" use="@id"/>
<xsl:key name="text-rend" match="text" use="@rend"/>

<!-- ====================================================================== -->
<!-- Keys for METS viewer                                                   -->
<!-- ====================================================================== -->

 <xsl:key name="divShowsChild" match="m:div[m:div/m:div/m:fptr]">
    <xsl:value-of select="count( preceding::m:div[@ORDER or @LABEL][m:div] | ancestor::m:div[@ORDER or @LABEL][m:div])+1"/>
  </xsl:key>
 <xsl:key name="divShowsChildStrict" match="m:div[m:div[@ORDER or @LABEL][1]/m:div[1]/m:fptr]">
    <xsl:value-of select="count( preceding::m:div[@ORDER or @LABEL][m:div] | ancestor::m:div[@ORDER or @LABEL][m:div])+1"/>
  </xsl:key>
  <xsl:key name="divChildShowsChild"  match="m:div[m:div/m:div/m:div/m:fptr]">
    <xsl:value-of select="count( preceding::m:div[@ORDER or @LABEL][m:div] | ancestor::m:div[@ORDER or @LABEL][m:div])+1"/>
  </xsl:key>

<xsl:key name="absPos" match="m:div[@ORDER or @LABEL][m:div]">
        <xsl:value-of select="count( preceding::m:div[@ORDER or @LABEL][m:div] | ancestor::m:div[@ORDER or @LABEL][m:div])+1"/>
</xsl:key>
<xsl:key name="absPosItem" match="m:div[m:div/m:fptr]">
        <xsl:value-of select="count( preceding::m:div[@ORDER or @LABEL][m:div] | ancestor::m:div[@ORDER or @LABEL][m:div])+1"/>
</xsl:key>
<xsl:key name="md" match="*" use="@ID"/>

<!-- ====================================================================== -->
<!-- Local params 	                                                    -->
<!-- ====================================================================== -->
  
<xsl:param name="brand" select="'calisphere'"/>
<xsl:param name="queryURL" select="session:getData('queryURL')"/>
<xsl:param name="http.Referer"/>
<xsl:variable name="theHost" select="replace($root.path , ':[0-9]+.+' , '')"/>
<xsl:param name="NAAN" select="'13030'"/>
  
<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->

<xsl:template match="/">
  <xsl:choose>    
    <xsl:when test="$doc.view='bbar'">
      <xsl:call-template name="bbar"/>
    </xsl:when>
    <xsl:when test="$doc.view='toc'">
      <xsl:call-template name="toc"/>
    </xsl:when>
    <xsl:when test="$doc.view='multiuse'">
      <xsl:call-template name="multiuse"/>
    </xsl:when>
    <xsl:when test="$doc.view='content'">
      <xsl:call-template name="content"/>
    </xsl:when>
    <xsl:when test="$doc.view='entire_text'">
      <xsl:call-template name="entire_text"/>
    </xsl:when>
    <xsl:when test="$doc.view='popup'">
      <xsl:call-template name="popup"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="frames"/>
    </xsl:otherwise>
    <!--<xsl:otherwise>
      <xsl:choose>
        <xsl:when test="($div.count &gt; 1) or (//div1[1]/div2)">
          <xsl:call-template name="frames"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="entire_text"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>-->
  </xsl:choose>
</xsl:template>

<!-- ====================================================================== -->
<!-- Frames Template                                                        -->
<!-- ====================================================================== -->

<xsl:template name="frames">

  <xsl:variable name="bbar.href"><xsl:value-of select="$query.string"/>&#038;doc.view=bbar&#038;chunk.id=<xsl:call-template name="find.chunk"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/><xsl:value-of select="$search"/></xsl:variable>

  <xsl:variable name="toc.href"><xsl:value-of select="$query.string"/>&#038;doc.view=toc&#038;chunk.id=<xsl:call-template name="find.chunk"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/>&#038;toc.id=<xsl:value-of select="$toc.id"/><xsl:value-of select="$search"/>#X</xsl:variable>

  <xsl:variable name="multiuse.href"><xsl:value-of select="$query.string"/>&#038;doc.view=multiuse&#038;chunk.id=<xsl:call-template name="find.chunk"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/><xsl:value-of select="$search"/></xsl:variable>

  <xsl:variable name="content.href"><xsl:value-of select="$query.string"/>&#038;doc.view=content&#038;chunk.id=<xsl:call-template name="find.chunk"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/>&#038;anchor.id=<xsl:value-of select="$anchor.id"/><xsl:value-of select="$search"/><xsl:call-template name="create.anchor"/></xsl:variable>

  <xsl:variable name="height">
    <xsl:choose>
      <xsl:when test="$brand = 'calcultures' or $brand='jarda'">
        <xsl:value-of select="'150'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'127'"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:variable>
  
  <html>
    <head>
      <title>
        <xsl:value-of select="$doc.title"/>
      </title>
    </head>

<!-- referer madness; off-site (not matches...) referers
cause the queryURL to be set to the referer -->

<xsl:if test="session:isEnabled()
                and
                        (not (matches($http.Referer, $theHost))
                         or (matches($http.Referer, '/test/qa.html$'))
                        )
                and (normalize-space($http.Referer) != '')"
             use-when="function-available('session:setData')">
          <xsl:value-of select="session:setData('queryURL',$http.Referer)"/>
<xsl:comment>session queryURL reset</xsl:comment>
</xsl:if>


    <frameset rows="{$height},*" border="1" framespacing="2" frameborder="1">
      <frame scrolling="no" title="Navigation Bar" noresize="noresize">
        <xsl:attribute name="name">bbar</xsl:attribute>
        <xsl:attribute name="src"><xsl:value-of select="$xtfURL"/><xsl:value-of select="$dynaxmlPath"/>?<xsl:value-of select="$bbar.href"/></xsl:attribute>
      </frame>
      <frameset cols="30%,70%" border="1" framespacing="2" frameborder="1">
        <frame title="Table of Contents">
          <xsl:attribute name="name">toc</xsl:attribute>
          <xsl:attribute name="src"><xsl:value-of select="$xtfURL"/><xsl:value-of select="$dynaxmlPath"/>?<xsl:value-of select="$toc.href"/></xsl:attribute>
        </frame>
        <frameset rows="90,*" border="0" framespacing="2" frameborder="0">
          <frame scrolling="no" title="Multiuse">
            <xsl:attribute name="name">multiuse</xsl:attribute>
            <xsl:attribute name="src"><xsl:value-of select="$xtfURL"/><xsl:value-of select="$dynaxmlPath"/>?<xsl:value-of select="$multiuse.href"/></xsl:attribute>
          </frame>
          <frame scrolling="yes" title="Content">
            <xsl:attribute name="name">content</xsl:attribute>
            <xsl:attribute name="src"><xsl:value-of select="$xtfURL"/><xsl:value-of select="$dynaxmlPath"/>?<xsl:value-of select="$content.href"/></xsl:attribute>
          </frame>
        </frameset>
      </frameset>
    </frameset>
    <noframes>
      <h1>Sorry, your browser doesn't support frames...</h1>
    </noframes>
  </html>
</xsl:template>

<!-- ====================================================================== -->
<!-- Find Chunk Template                                                        -->
<!-- ====================================================================== -->

<xsl:template name="find.chunk">
  <xsl:choose>
    <xsl:when test="$chunk.id != '0'">
      <xsl:value-of select="$chunk.id"/>
    </xsl:when>
    <!-- Automatic scrolling to first hit -->
    <!-- xsl:when test="($chunk.id = '0') and ($query != '0') and ($query != '')">
      <xsl:choose>
        <xsl:when test="key('hit-num-dynamic', '1')/ancestor::div1">
          <xsl:value-of select="key('hit-num-dynamic', '1')/ancestor::div1/@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'0'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$chunk.id = '0' and ($query = '0' or $query = '')">
      <xsl:value-of select="'0'"/>
    </xsl:when -->
    <xsl:otherwise>
      <xsl:value-of select="'0'"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ====================================================================== -->
<!-- Anchor Template                                                        -->
<!-- ====================================================================== -->

  <xsl:template name="create.anchor">
    <xsl:choose>
      <xsl:when test="($query != '0') and ($query != '') and ($chunk.id != '0')">
        <xsl:if test="key('div-id', $chunk.id)/@xtf:hitCount">
          <xsl:text>#</xsl:text><xsl:value-of select="key('div-id', $chunk.id)/@xtf:firstHit"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$set.anchor != '0'">
        <xsl:text>#</xsl:text><xsl:value-of select="$set.anchor"/>
      </xsl:when>
      <!-- Automatic scrolling to first hit -->
      <xsl:when test="($query != '0') and ($query != '')">
        <xsl:text>#1</xsl:text>
      </xsl:when>
      <xsl:when test="$anchor.id != '0'">
        <xsl:text>#X</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

<!-- ====================================================================== -->
<!-- TOC Template                                                           -->
<!-- ====================================================================== -->

<xsl:template name="toc">

  <xsl:variable name="view">
    <xsl:choose>
      <xsl:when test="$doc.view='frames' or $doc.view='bbar' or $doc.view='toc' or $doc.view='content'">frames</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
    
    <xsl:variable name="sum">
      <xsl:choose>
        <xsl:when test="($query != '0') and ($query != '')">
          <xsl:value-of select="if (/TEI.2/text/@xtf:hitCount) then
          /TEI.2/text/@xtf:hitCount else /TEI.2/@xtf:hitCount"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="occur">
      <xsl:choose>
        <xsl:when test="number($sum) != number(1)">occurrences</xsl:when>
        <xsl:otherwise>occurrence</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
  
  <html>
    <head>
      <title>
        <xsl:value-of select="$doc.title"/>
      </title>
      <xsl:copy-of select="$brand.links"/>
    </head>
    <body>
      <div id="tei" align="center">


		  <!-- BEGIN QTVR LINKS BOX --> 
<xsl:if test="/TEI.2/m:mets">
	<div id="wrapper">	  
      <div id="object-version-tei" class="nifty4">
              <div class="box4">
                    <table>
                        <tr>
		   <td><a href="/ark:/{$NAAN}/{$docId}/?brand={$brand}&amp;doc.view=mets" target="_parent">view scanned version</a>
                           </td>
			<td class="pipe-spacing">|</td>
                           <td>transcription</td>
                        </tr>
                     </table>
                  </div>
               </div> 
	</div>	  
</xsl:if>

		    <!-- END QTVR LINKS BOX -->


        <table width="95%" cellpadding="0" cellspacing="0" border="0">
          <tbody>
            <tr>
              <td id="left-frame">  
                <xsl:if test="($query != '0') and ($query != '')">
                  <p>
                    <span class="hi-lite">
                      <xsl:value-of select="$sum"/>
                    </span>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$occur"/>
                    <xsl:text> of </xsl:text>
                    <span class="hi-lite">
                      <xsl:value-of select="$query"/>
                    </span>
                  </p>
                  <p>
                    <a>
                      <xsl:attribute name="href"><xsl:value-of select="$doc.path"/>&#038;doc.view=<xsl:value-of select="$view"/>&#038;chunk.id=<xsl:value-of select="$chunk.id"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;toc.id=<xsl:value-of select="$toc.id"/>&#038;brand=<xsl:value-of select="$brand"/></xsl:attribute>
                      <xsl:attribute name="target">_top</xsl:attribute>
                      <xsl:text>clear search results</xsl:text>
                    </a>
                  </p>
                  <p class="hr"></p>
                </xsl:if>
                <table>
                  <tr>
                    <xsl:choose>
                      <xsl:when test="($query != '0') and ($query != '')">
                        <xsl:choose>
                          <xsl:when test="$sum != '0'">
                            <td class="navCategory" width="20" align="right" valign="top">
                              <span class="hit-count">
                                <xsl:value-of select="$sum"/>
                              </span>
                            </td>
                          </xsl:when>
                          <xsl:otherwise>
                            <td width="20">&#160;</td>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <td width="1">&#160;</td>
                      </xsl:otherwise>
                    </xsl:choose>
                    <td valign="top">
                      <a href="{$xtfURL}view?docId={$docId}&amp;brand={$brand}" target="_top">
                        <img src="{$brand.arrow.dn}" border="0"/>
                      </a>
                    </td>
                    <td valign="top">
                      <b>
                        <xsl:choose>
                          <xsl:when test="$chunk.id!='0'">
                            <a href="{$xtfURL}view?docId={$docId}&amp;query={$query}&amp;brand={$brand}" target="_top">
                              <xsl:value-of select="$doc.title"/>
                            </a>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="$doc.title"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </b>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
            <tr>
              <td>
                <!-- Table of Contents -->
                <xsl:call-template name="book.autotoc"/>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </body>
  </html>
</xsl:template>

<!-- ====================================================================== -->
<!-- Multiuse Template                                                      -->
<!-- ====================================================================== -->
  
<xsl:template name="multiuse">
  <html>
    <head>
      <title>
        <xsl:value-of select="$doc.title"/>
      </title>
      <xsl:copy-of select="$brand.links"/>
    </head>
    <body>
      <!-- BEGIN PAGE ID -->
      <div id="tei">
        <div id="midframe">
         
        <xsl:variable name="print.chunk.id">
          <xsl:choose>
            <!-- needs work -->
            <xsl:when test="($div.count = 1) and not(//div1[1]/div2)"/>
            <xsl:when test="$chunk.id='0' and not(//titlePage)">
              <xsl:value-of select="//div1[1]/@id"/>
            </xsl:when>
            <xsl:when test="$chunk.id='0' and //titlePage">
              <xsl:value-of select="'tpage'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$chunk.id"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
          
        <div id="print">
          <div id="content-secondary">
            <!-- BEGIN PRINT PREVIEW BOX -->      
            <div id="print-control" class="nifty4">
              <div class="box4">
                
                <table cellspacing="0" cellpadding="0">
                  <tr>
                    <td align="left" valign="middle">
                      <img>
                        <xsl:copy-of select="$brand.print.img"/>
                      </img>
                    </td>
                    <td align="left" valign="middle">
                      <div class="button nifty6">
                        <div class="box6">
                          <a href="{$xtfURL}view?docId={$docId}&amp;chunk.id={$print.chunk.id}&amp;brand={$brand}&amp;doc.view=entire_text{if ($NAAN!='13030') then concat('&amp;NAAN=',$NAAN) else ''}" target="_top">current pages</a>
                        </div>
                      </div>
                    </td>
                    <td align="left" valign="middle">
                      <div class="button nifty6">
                        <div class="box6">
                          <a href="{$xtfURL}view?docId={$docId}&amp;brand={$brand}&amp;doc.view=entire_text{if ($NAAN!='13030') then concat('&amp;NAAN=',$NAAN) else ''}" target="_top">all pages</a>
                        </div>
                      </div>
                    </td>
                  </tr>
                </table>
              </div>
              
            </div> 
            <!-- END PRINT PREVIEW BOX -->
            
          </div>
          <!-- END CONTENT SECONDARY -->
          
          <xsl:if test="not(matches($metsProfile,'kt7j49p867')) and not(matches($chunk.id, 'meta'))">
            <div id="text">
              <a href="{$xtfURL}view?docId={$docId}&amp;brand={$brand}&amp;chunk.id=meta{if ($NAAN!='13030') then concat('&amp;NAAN=',$NAAN) else ''}" target="_top">More information about this text</a>
            </div>
          </xsl:if>

        </div>
        
        <div id="search">
          <div id="site-search" class="searchbox-outer nifty2">
            <div class="box2">
              <div class="searchbox-inner">
                <xsl:text> search within this text </xsl:text>
                <form action="{$xtfURL}view" class="search-form" target="_top" name="search-form" method="GET">
                  <input name="query" size="18" maxlength="80" type="text">
                    <xsl:if test="$query">
                      <xsl:attribute name="value" select="$query"/>
                    </xsl:if>
                  </input>
                  <input type="hidden" name="docId">
                    <xsl:attribute name="value">
                      <xsl:value-of select="$docId"/>
                    </xsl:attribute>
                  </input>
                  <input type="hidden" name="chunk.id">
                    <xsl:attribute name="value">
                      <xsl:value-of select="$chunk.id"/>
                    </xsl:attribute>
                  </input>
                  <input type="hidden" name="toc.depth">
                    <xsl:attribute name="value">
                      <xsl:value-of select="$toc.depth"/>
                    </xsl:attribute>
                  </input>
                  <input type="hidden" name="toc.id">
                    <xsl:attribute name="value">
                      <xsl:value-of select="$toc.id"/>
                    </xsl:attribute>
                  </input>         
                  <xsl:if test="$brand">
                    <input type="hidden" name="brand" value="{$brand}"/>
                  </xsl:if>
                  <xsl:if test="$NAAN!='13030'">
                    <input type="hidden" name="NAAN" value="{$NAAN}"/>
                  </xsl:if>
                  <!--<input src="http://www.calisphere.universityofcalifornia.edu/images/buttons/search.gif" class="search-button" alt="Search" title="Search" type="image"/>-->
                  <xsl:copy-of select="$brand.search.img"/>
                </form>
              </div>
            </div>
          </div>
        </div>
        
        <br clear="all" />
      </div>
      <!-- END MIDFRAME -->
      </div>
      <!-- END PAGE ID -->
      
    </body>
  </html>
    
</xsl:template>

<!-- ====================================================================== -->
<!-- Content Template                                                       -->
<!-- ====================================================================== -->

  <xsl:template name="content">
    
    <xsl:param name="doc.view"/>
    
    <html>
      <head>
        <title>
          <xsl:value-of select="$doc.title"/>
        </title>
        <xsl:copy-of select="$brand.links"/>
<xsl:if test="/TEI.2/xtf:meta/relation[contains(.,'roho')]">
	<meta name="robots" content="noindex"/>
</xsl:if>
      </head>
      <body>
        <div id="tei" align="center">
          <xsl:choose>
            <xsl:when test="$chunk.id = 'meta'"> 
              <div id="metadata">
                <div class="nifty1">
                  <div class="metadata-text">
                    <xsl:copy-of select="view:MODS(($METS-MODS3//*[local-name()='mods'])[1],'')"/>
                    <!-- Need to work out how to display owning institution, BT will implement -->
                    <xsl:apply-templates select="$METS-MODS3/m:mets/m:dmdSec/m:mdRef[@MDTYPE='EAD']" mode="link"/>
                    <p><h2>Contributing Institution:</h2>
                       <xsl:call-template name="insert-institution-url"/>
                    </p>
                  </div>
                </div>
              </div>
              <!-- Removinbg Temporarily at Rosalie's Request -->
              <!--<div id="content-secondary">
                <div id="permission-box">
                  <div class="nifty2">
                    <div class="box2">
                      <div class="secondary-text">
                        <p>Do I need permission to reproduce Calisphere images and texts for classroom use? <a href="http://calisphere-dev.cdlib.org:8080/copyright-cs.html" target="_top">Learn more...</a></p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>-->
              <xsl:copy-of select="$brand.footer"/>
            </xsl:when>
            <xsl:otherwise>
              <table width="95%">
                <tr>
                  <td>
                    <xsl:choose>
                      <xsl:when test="key('text-rend', $chunk.id)">
                        <xsl:apply-templates select="key('text-rend',$chunk.id)//titlePage"/>
                      </xsl:when>
                      <xsl:when test="($chunk.id = '0') and (//titlePage)">
                        <xsl:apply-templates select="/TEI.2/text/front/titlePage"/>
                      </xsl:when>
                      <xsl:when test="$chunk.id = '0'">
                        <div align="left">
                          <xsl:apply-templates select="//div1[1]"/>
                        </div>
                      </xsl:when>
                      <xsl:otherwise>
                        <div align="left">
                          <xsl:apply-templates select="key('div-id', $chunk.id)"/>
                        </div>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:copy-of select="$brand.footer"/>
                  </td>
                </tr>
              </table>
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </body>
    </html>
  </xsl:template>

<!-- ====================================================================== -->
<!-- For the link back to the owning institution                            -->
<!-- ====================================================================== -->

<xsl:template match="insert-institution-url" name="insert-institution-url">
<xsl:comment>insert-institution-url</xsl:comment>
        <xsl:apply-templates
          select="($METS-MODS3/mets:mets/mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods)[1]/mods:location[1]/mods:physicalLocation[1]" 
	  mode="viewMODS"
        />
</xsl:template>


<!-- ====================================================================== -->
<!-- Entire Text Template                                                  -->
<!-- ====================================================================== -->

  <xsl:template name="entire_text">
    <html>
      <head>
        <title>
          <xsl:value-of select="$doc.title"/>
        </title>
        <xsl:copy-of select="$brand.links"/>
<xsl:if test="$chunk.id != '0' and /TEI.2/xtf:meta/relation[contains(.,'roho')]">
	<meta name="robots" content="noindex"/>
</xsl:if>
      </head>
      <body>
        <div id="tei">
          <div id="printable">
            <xsl:copy-of select="$brand.header.dynaxml.header"/>
            <div id="content">
              <div align="left">
                <xsl:choose>
                  <xsl:when test="$chunk.id='tpage'">
                    <xsl:apply-templates select="//titlePage"/>
                  </xsl:when>
                  <xsl:when test="$chunk.id='meta'">
                    <div id="metadata">
                      <div class="nifty1">
                        <div class="metadata-text">
                          <xsl:copy-of select="view:MODS(($METS-MODS3//*[local-name()='mods'])[1],'')"/>
                          <!-- Need to work out how to display owning institution, BT will implement -->
                    <xsl:apply-templates select="$METS-MODS3/m:mets/m:dmdSec/m:mdRef[@MDTYPE='EAD']" mode="link"/>
                    <p><h2>Contributing Institution:</h2>
                       <xsl:call-template name="insert-institution-url"/>
                    </p>
                        </div>
                      </div>
                    </div>
                    <!-- Removing temporarily at Rosalie's request -->
                   <!-- <div id="content-secondary">
                      <div id="permission-box">
                        <div class="nifty2">
                          <div class="box2">
                            <div class="secondary-text">
                              <p>Do I need permission to reproduce Calisphere images and texts for classroom use? <a href="http://calisphere-dev.cdlib.org:8080/copyright-cs.html" target="_top">Learn more...</a></p>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>-->
                  </xsl:when>
                  <xsl:when test="$chunk.id != '0'">
                    <h3><xsl:value-of select="$doc.title"/></h3>
                    <xsl:apply-templates select="//*[@id=$chunk.id]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="/TEI.2/text"/>
                  </xsl:otherwise>
                </xsl:choose>
              </div>
              <div id="about-text">
                <span class="heading">About this text</span><br/>
                <xsl:if test="$DC//publisher">
                  Courtesy of <xsl:value-of select="$DC//publisher[1]"/><!-- BT needs to supply this --><br/>
                  http://content.cdlib.org/<xsl:value-of select="$dynaxmlPath"/>?docId=<xsl:value-of select="$docId"/>&amp;brand=<xsl:value-of select="$brand"/><br/>
                </xsl:if>
                <xsl:if test="$DC//title">
                  <span class="heading">Title:</span>&#160;<xsl:value-of select="$DC//title[1]"/><br/>
                </xsl:if>
                <xsl:if test="$DC//contributor">
                  <span class="heading">By:</span>&#160;
                  <xsl:for-each select="$DC//contributor">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">
                      <xsl:text>,&#160;</xsl:text>
                    </xsl:if>
                  </xsl:for-each><br/>
                </xsl:if>
                <xsl:if test="$DC//date">
                  <span class="heading">Date:</span>&#160;<xsl:value-of select="$DC//date[1]"/><br/>
                </xsl:if>
                <xsl:if test="$DC//publisher">
                  <span class="heading">Contributing Institution:</span>&#160;<xsl:value-of select="$DC//publisher[1]"/><!-- BT needs to supply this --><br/>
                </xsl:if>
                <span class="heading">Copyright Note:</span>&#160;Copyright status unknown. Some materials in these collections may be
                protected by the U.S. Copyright Law (Title 17, U.S.C.). In addition, the
                reproduction, and/or commercial use, of some materials may be restricted
                by gift or purchase agreements, donor restrictions, privacy and
                publicity rights, licensing agreements, and/or trademark rights.
                Distribution or reproduction of materials protected by copyright beyond
                that allowed by fair use requires the written permission of the
                copyright owners. To the extent that restrictions other than copyright
                apply, permission for distribution or reproduction from the applicable
                rights holder is also required. Responsibility for obtaining
                permissions, and for any use rests exclusively with the user.
              </div>
              <xsl:copy-of select="$brand.footer"/>
            </div>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>

<!-- ====================================================================== -->
<!-- For the link back to the parent finding aid                            -->
<!-- ====================================================================== -->


<xsl:template match="m:mdRef" mode="link">
 <xsl:variable name="brandCgi">
        <xsl:if test="$brand">
          <xsl:text>&amp;brand=</xsl:text>
          <xsl:value-of select="$brand"/>
        </xsl:if>
 </xsl:variable>

<p>
        <xsl:if test="position()=1"><h2>Collection:</h2></xsl:if>
        <a target="_top" href="{@*[local-name()='href']}{$brandCgi}"><xsl:value-of select="@LABEL"/></a>
</p>
</xsl:template>


<!-- ====================================================================== -->
<!-- Button Bar Templates                                                   -->
<!-- ====================================================================== -->

  <xsl:template name="bbar">
    <html>
      <head>
        <title>
          <xsl:value-of select="$doc.title"/>
        </title>
        <xsl:copy-of select="$brand.links"/>
      </head>
      <body>
        <!-- BEGIN PAGE ID -->
        <div id="tei">
          
          <!-- BEGIN HEADER ROW-->
          <xsl:copy-of select="$brand.header.dynaxml.header"/>
          <!-- END HEADER ROW-->
          
          <!-- BEGIN SECONDARY HEADER ROW-->
          <div id="header-secondary">
            
            <div id="multi-use">
              <xsl:if test="$brand='calcultures' or $brand='jarda'">
                <a target="_top" href="{$brand.hotdog.img/@href}"><img src="{$brand.hotdog.img/@src}" border="0"/></a>
              </xsl:if>
              <!-- BEGIN BREADCRUMBS-->
              <div id="breadcrumbs">
                <xsl:if test="normalize-space($queryURL) != ''">
                  <a href="{$queryURL}" target="_top">Back</a>
                </xsl:if>
              </div>
              <!-- END BREADCRUMBS-->
            </div>
            
            <!-- BEGIN SITE-SEARCH -->
            <xsl:copy-of select="$brand.search.box"/>
            <!-- END SITE-SEARCH -->
            
            <br clear="all"/>
          </div>        
          <!-- END SECONDARY HEADER ROW-->
        </div>
        <!-- END PAGE ID -->
      </body>
    </html>
  </xsl:template>
  
<xsl:template name="bbar.table">
  
  <table cellspacing="0" class="maintable" width="100%" cellpadding="0" border="0">
    <xsl:copy-of select="$brand.header.dynaxml.header"/>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tbody>
      <tr>
        <td class="textheaderback" width="10">&#160;</td>
        <td class="textheaderback" align="left" width="730">
          <a href="http://www.oac.cdlib.org/texts" target="_top">
            <xsl:text>Texts</xsl:text>
          </a>
          <xsl:text>&#160;&gt;&#160;</xsl:text>
            <xsl:choose xmlns:mets="http://www.loc.gov/METS/">
	      <!-- there is a link to a parent FA -->
              <xsl:when test="$METS/mets:mets/mets:dmdSec/mets:mdRef[@MDTYPE='EAD']">
                <a href="{$METS/mets:mets/mets:dmdSec/mets:mdRef[@MDTYPE='EAD']/@*[local-name()='href']}" target="_top">
                  <xsl:value-of select="$METS/mets:mets/mets:dmdSec/mets:mdRef[@MDTYPE='EAD']/@LABEL"/>
                </a>
              </xsl:when>
	      <!-- no parent FA; use the Alvin code -->
              <xsl:otherwise>
                <xsl:call-template name="oac-text-breadcrumbs">
                  <xsl:with-param name="alvincode"><xsl:value-of select="$collection"/></xsl:with-param>
                  <xsl:with-param name="mode">both</xsl:with-param>
                  <xsl:with-param name="target">_top</xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
        </td>
      </tr>
      <tr>
        <td width="10">&#160;</td>
        <td>
          <h1><nobr>
            <a>
              <xsl:attribute name="href">
                <xsl:value-of select="concat('http://ark.cdlib.org/',$METS//*[local-name()='mets']/@OBJID)"/>
              </xsl:attribute>
              <xsl:attribute name="target">_top</xsl:attribute>
              <xsl:value-of select="$doc.title"/>
            </a>
          </nobr></h1>
        </td>
      </tr>
    </tbody>
  </table>

</xsl:template>

<!-- ====================================================================== -->
<!-- Popup Window Template                                                  -->
<!-- ====================================================================== -->

<xsl:template name="popup">
  <html>
    <head>
      <title>
        <xsl:choose>
          <xsl:when test="key('generic-id', $chunk.id)/@type = 'footnote'">
            <xsl:text>Footnote</xsl:text>
          </xsl:when>
          <xsl:when test="key('div-id', $chunk.id)/@type = 'dedication'">
            <xsl:text>Dedication</xsl:text>
          </xsl:when>
          <xsl:when test="$fig.ent != '0'">
            <xsl:text>Illustration</xsl:text>
          </xsl:when>
         <xsl:when test="$formula.id != '0'">
            <xsl:text>Formula</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>popup</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </title>
      <xsl:copy-of select="$brand.links"/>
    </head>
    <body>
      <xsl:choose>
        <xsl:when test="(key('fnote-id', $chunk.id)/@type = 'footnote') or (key('fnote-id', $chunk.id)/@place = 'foot')">
          <xsl:apply-templates select="key('fnote-id', $chunk.id)"/>
        </xsl:when>
        <xsl:when test="key('div-id', $chunk.id)/@type = 'dedication'">
          <xsl:apply-templates select="key('div-id', $chunk.id)" mode="titlepage"/>  
        </xsl:when>
        <xsl:when test="$fig.ent != '0'"><!-- Removed {$figure.path} because $fig.ent now carries the full figure url -->
          <img src="{$fig.ent}" alt="full-size image"/>        
        </xsl:when>
        <xsl:when test="$formula.id != '0'">
          <div align="center">
            <applet code="HotEqn.class" archive="{$xtfURL}applets/HotEqn.jar" height="550" width="550" name="{$formula.id}" align="middle">
              <param name="equation">
                <xsl:attribute name="value">
                  <xsl:value-of select="key('formula-id', $formula.id)"/>
                </xsl:attribute>
              </param>
              <param name="fontname" value="TimesRoman"/>
              <param name="bgcolor" value="CCCCCC"/>
              <param name="fgcolor" value="0000ff"/>
              <param name="halign" value="center"/>
              <param name="valign" value="middle"/> 
              <param name="debug" value="true"/>
            </applet>
          </div>
        </xsl:when>
      </xsl:choose>
      <p>
        <a>
          <xsl:attribute name="href">javascript://</xsl:attribute>
          <xsl:attribute name="onClick">
            <xsl:text>javascript:window.close('popup')</xsl:text>
          </xsl:attribute>
          <span class="down1">Close this Window</span>
        </a>
      </p>
    </body>
  </html>
</xsl:template>

</xsl:stylesheet>
