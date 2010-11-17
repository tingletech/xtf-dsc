<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- OAC docHits formatting                                                 -->
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
  
<!-- xsl:import href="../common/cdlResultFormatterCommon.xsl"/ -->
  
<xsl:include href="http://voro.cdlib.org:8081/xslt/institution-ark2url.xsl"/>
  
<xsl:param name="scale-max-ignore" select="number(100)"/>
<xsl:param name="title-ignore"/>
  
<xsl:variable name="dev">
   <xsl:choose>
        <xsl:when test="contains($root.path,'http://content.cdlib.org/')">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
   </xsl:choose>
</xsl:variable>

  
  <!-- ====================================================================== -->
  <!-- Normal Document Hit Template                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit">
   <xsl:choose>
	<xsl:when test="$title-ignore = 'only'">
    <tr class="search-row">
          <td class="listIcon">
	     <xsl:choose>
		<xsl:when test="meta/extent">
			<img alt="" width="17" border="0" height="14" 
			src="http://oac.cdlib.org/images/image_icon.gif"/> 
			<xsl:text> </xsl:text>
		</xsl:when>
	     	<xsl:otherwise>
		<xsl:text> </xsl:text>
	     	</xsl:otherwise>
	     </xsl:choose>
	  </td>
          <td class="listItem">
			<xsl:call-template name="docHit-div"/>
		<xsl:if test="meta/extent">
			<xsl:text> (</xsl:text>
			<xsl:value-of select="meta/extent"/>
			<xsl:text>)</xsl:text>
		</xsl:if>
	  </td>
    </tr>
	</xsl:when>
	<xsl:otherwise>
    <tr class="search-row">
          <td class="search-results-number">
		<xsl:call-template name="docHit-number"/>
	  </td>
          <td class="search-results-thumbnail">
      	  	<xsl:call-template name="docHit-thumbnail"/>
	  </td>
          <td class="search-results-text">
        	<div class="search-results-text-inner">
			<xsl:call-template name="docHit-div"/>
		</div>
	  </td>
    </tr>
	</xsl:otherwise>
   </xsl:choose>
  </xsl:template>

  <xsl:template name="docHit-number">
          <xsl:value-of select="@rank"/>.
  </xsl:template>

  <!-- xsl:template name="docHit-thumbnail">
  <xsl:choose>
    <xsl:when test="contains(meta/type[1],'image') or contains(meta/type[1],'Image') or meta/type[1]='cartographic' or meta/type[1] = 'mixed material' or meta/type[1] = 'facsimile text' or meta/type[1] = 'mixed+material' ">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="dynaxml.url">
              <xsl:with-param name="fullark" select="meta/identifier[1]"/>
            </xsl:call-template>
          </xsl:attribute>
<img src="{replace(meta/identifier[1],'http://ark.cdlib.org/','/'
)}/thumbnail" border="0"/>
        </a>
    </xsl:when>
    <xsl:otherwise>&#160;</xsl:otherwise>
  </xsl:choose>
  </xsl:template -->

 <xsl:template name="docHit-thumbnail">
  <xsl:variable name="x" select="number(meta/thumbnail/@X)"/>
  <xsl:variable name="y" select="number(meta/thumbnail/@Y)"/>
  <xsl:variable name="ratio" select="number($x div $y)"/>
  <xsl:variable name="width">
   <xsl:choose>
	<xsl:when test="$x &gt; number($scale-max-ignore) or $y &gt; number($scale-max-ignore)">
    	   <xsl:choose>
		<xsl:when test="$ratio &gt; 1"><!-- landscape, x leads -->
			<xsl:value-of select="number($scale-max-ignore)"/>
		</xsl:when>
		<xsl:when test="$ratio &lt; 1"><!-- portrait, y leads; x is scaled -->
			<xsl:value-of select="round(number($scale-max-ignore) * $ratio)"/>
		</xsl:when>
		<xsl:when test="$ratio =  1"><!-- what a square! -->
			<xsl:value-of select="number($scale-max-ignore)"/>
		</xsl:when>
    	   </xsl:choose>
	</xsl:when>
	<xsl:otherwise><xsl:value-of select="$x"/></xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="height">
   <xsl:choose>
	<xsl:when test="$x &gt; number($scale-max-ignore) or $y &gt; number($scale-max-ignore)">
    	   <xsl:choose>
		<xsl:when test="$ratio &gt; 1"><!-- landscape, x leads; y is scaled -->
			<xsl:value-of select="round(number($scale-max-ignore) div $ratio)"/>
		</xsl:when>
		<xsl:when test="$ratio &lt; 1"><!-- portrait, y leads -->
			<xsl:value-of select="number($scale-max-ignore)"/>
		</xsl:when>
		<xsl:when test="$ratio =  1"><!-- what a square! -->
			<xsl:value-of select="number($scale-max-ignore)"/>
		</xsl:when>
    	   </xsl:choose>
	</xsl:when>
	<xsl:otherwise><xsl:value-of select="$y"/></xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <!-- xsl:when test="contains(meta/type[1],'image') or contains(meta/type[1],'Image') or meta/type[1]='cartographic' or meta/type[1] = 'mixed material'  " -->
    <xsl:when test="meta/thumbnail">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="dynaxml.url">
              <xsl:with-param name="fullark" select="meta/identifier[1]"/>
            </xsl:call-template>
          </xsl:attribute>
<img> 
	<xsl:if test="number($width)">
		<xsl:attribute name="width" select="$width"/>
		<xsl:attribute name="height" select="$height"/>
	</xsl:if>
	<xsl:attribute name="src">
<xsl:value-of select="replace(meta/identifier[1],'http://ark.cdlib.org/','/')"/>
<xsl:text>/thumbnail</xsl:text>
	</xsl:attribute>
	<xsl:attribute name="alt" select="meta/title[1]"/>
	<xsl:attribute name="border" select="'0'"/>
</img>
</a>
<!--  x<xsl:value-of select="$x"/>
y<xsl:value-of select="$y"/>
|<xsl:value-of select="$height"/>
-<xsl:value-of select="$width"/>| 
<xsl:if test="number($width)">NUMBER</xsl:if> -->
    </xsl:when>
    <xsl:otherwise>&#160;</xsl:otherwise>
  </xsl:choose>
  </xsl:template>


  <xsl:template name="docHit-div">
    <xsl:variable name="fullark" select="meta/identifier[1]"/> 


<xsl:choose>
   <xsl:when test="$title-ignore = 'only'">
	 <a>
            <xsl:attribute name="href">
              <xsl:call-template name="dynaxml.url">
                <xsl:with-param name="fullark" select="$fullark"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="meta/title[1]"/>
        </a>
   </xsl:when>
   <xsl:when test="meta/type[1] = 'archival collection' ">

          <strong>Collection Title: </strong>
	<xsl:choose>
	 <xsl:when test="$dev = 0">
          <a href="{replace($fullark,'org/findaid/',
						'org/findaid/')}">
            <xsl:apply-templates select="meta/title[1]"/>
          </a>         
	 </xsl:when>
	 <xsl:otherwise>
	<a>
            <xsl:attribute name="href">
              <xsl:call-template name="dynaxml.url">
                <xsl:with-param name="fullark" select="$fullark"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="meta/title[1]"/>
	</a>
	 </xsl:otherwise>
	</xsl:choose>
          <xsl:if test="meta/publisher">
					<div>
            <strong>Contributing Institution: </strong>
            <xsl:value-of select="meta/publisher[1]"/>
					</div>
          </xsl:if>
	<div>
            <strong>Collection Dates: </strong>
          <xsl:choose>
		<xsl:when test="meta/date">
            <xsl:value-of select="meta/date[1]"/>
		</xsl:when>
		<xsl:otherwise>
	    None given
		</xsl:otherwise>
          </xsl:choose>          
  </div>
       
  <div>  
	  	<strong>Items Online</strong>
          <xsl:choose>
		<xsl:when test="meta/extent">

<div>Yes. Must visit contributing institution to view entire collection.</div>
<img alt="" width="84" border="0" height="16" src="http://oac.cdlib.org/images/onlineitemsbutton.gif"/> <img alt="" width="17" border="0" height="14" src="http://oac.cdlib.org/images/image_icon.gif"/> <xsl:text> </xsl:text>
<xsl:value-of select="meta/extent"/>

		</xsl:when>
		<xsl:otherwise>
None online. Must visit contributing institution.
		</xsl:otherwise>
          </xsl:choose>
    </div>
	  <xsl:if test="meta/description"> 
				<div>
            <strong>Summary: </strong>
            <xsl:apply-templates select="meta/description[1]"/>
				</div>
          </xsl:if>        
          <xsl:if test="snippet">          
		<div>
	   <a>
            <xsl:attribute name="href">
              <xsl:call-template name="dynaxml.url">
                <xsl:with-param name="fullark" select="$fullark"/>
              </xsl:call-template>
            </xsl:attribute>
            <strong>Search terms in context (<xsl:value-of select="@totalHits"/>):</strong></a>
		</div>
            
            <div class="search-results-snippets">
              <xsl:apply-templates select="snippet"/>
            </div>
          </xsl:if>
  </xsl:when>
  <!-- xsl:when test="contains(meta/type[1] , 'image')" -->
  <xsl:otherwise>
<div>
 <strong>Title: </strong>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="dynaxml.url">
                <xsl:with-param name="fullark" select="$fullark"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="meta/title[1]"/>
          </a>
</div>
          <xsl:if test="meta/publisher">
						<div>
            <strong>Publisher: </strong>
            <xsl:value-of select="meta/publisher[1]"/>
            </div>
          </xsl:if>
          <xsl:if test="meta/sort-year">
						<div>
            <strong>Date: </strong>
            <xsl:value-of select="meta/sort-year[1]"/>
            </div>
          </xsl:if>
          <xsl:if test="meta/subject and contains(meta/type[1],'text') ">
						<div>
            <strong>Subjects: </strong>
            <xsl:apply-templates select="meta/subject"/>
            </div>
          </xsl:if>
	  <xsl:if test="meta/relation-from and substring-after((meta/relation-from)[1],'|') != ''">
		<div>
		<strong>From: </strong>
		<a href="{substring-before((meta/relation-from)[1],'|')}">
			<xsl:value-of select="substring-after((meta/relation-from)[1],'|')"/>
		</a>
		</div>
          </xsl:if>
          <xsl:if test="snippet">
						<div>
            <strong>Search terms in context (<xsl:value-of select="@totalHits"/>):</strong>
            </div>
            <div class="search-results-snippets">
              <xsl:apply-templates select="snippet"/>
            </div>
          </xsl:if>
  </xsl:otherwise>

</xsl:choose>

  </xsl:template>

  <xsl:template match="docHit" mode="old">
    <xsl:variable name="fullark" select="meta/identifier[1]"/>
    <tr class="search-row">
          <td class="search-results-number"><xsl:value-of select="@rank"/>.</td>
      <td class="search-results-thumbnail">&#160;</td>
      <td class="search-results-text">
        <div class="search-results-text-inner">
					<div>
          <strong>Collection Title: </strong>
          <a href="{$fullark}">
            <xsl:apply-templates select="meta/title[1]"/>
          </a>
					</div>
          <xsl:if test="meta/publisher">
						<div>
            <strong>Contributing Institution: </strong>
            <xsl:value-of select="meta/publisher[1]"/>
            </div>
          </xsl:if>
					<div>
            <strong>Collection Dates: </strong>
          <xsl:choose>
		<xsl:when test="meta/date">
            <xsl:value-of select="meta/date[1]"/>
		</xsl:when>
		<xsl:otherwise>
	    None given
		</xsl:otherwise>
          </xsl:choose>          
            </div>
      
    			<div> 
	  	<strong>Items Online</strong>
          <xsl:choose>
		<xsl:when test="meta/extent">
<div>Yes. Must visit contributing institution to view entire collection.</div>
<img alt="" width="84" border="0" height="16" src="http://oac.cdlib.org/images/onlineitemsbutton.gif"/> <img alt="" width="17" border="0" height="14" src="http://oac.cdlib.org/images/image_icon.gif"/> <xsl:text> </xsl:text>
<xsl:value-of select="meta/extent"/>
		</xsl:when>
		<xsl:otherwise>
None online. Must visit contributing institution.
		</xsl:otherwise>
          </xsl:choose>
            </div>
	  <xsl:if test="meta/description"> 
						<div>
            <strong>Summary: </strong>
            <xsl:apply-templates select="meta/description[1]"/>
            </div>
          </xsl:if>        
          <xsl:if test="snippet">          
						<div>
	   <a>
            <xsl:attribute name="href">
              <xsl:call-template name="dynaxml.url">
                <xsl:with-param name="fullark" select="$fullark"/>
              </xsl:call-template>
            </xsl:attribute>
            <strong>Search terms in context (<xsl:value-of select="@totalHits"/>):</strong></a>
            </div>
            <div class="search-results-snippets">
              <xsl:apply-templates select="snippet"/>
            </div>
          </xsl:if>
				</div>
      </td>
    </tr>

  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Compact Document Hit Template                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit" mode="compact">
    
    <xsl:variable name="fullark" select="meta/identifier[1]"/>

    <tr>
      <td align="left" width="5%">
        <xsl:if test="$sort != 'title' and $sort != 'publisher' and $sort != 'year'">
          <xsl:value-of select="@rank"/><xsl:text>.</xsl:text>
        </xsl:if>    
      </td>
      <td align="left" width="45%">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="dynaxml.url">
              <xsl:with-param name="fullark" select="$fullark"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="meta/title[1]"/>
        </a>
      </td>
      <td align="left" width="20%">
        <xsl:apply-templates select="meta/publisher[1]"/>
      </td>      
      <td align="left" width="20%">
        <xsl:apply-templates select="meta/subject[1]"/>
      </td>     
      <td align="center" width="5%">
        <xsl:apply-templates select="meta/year[1]"/>
      </td>  
      <td align="right" width="5%">
        <xsl:value-of select="@totalHits"/>
      </td>  
    </tr>
    <tr>
      <td colspan="7"><hr/></td>
    </tr>
    
  </xsl:template>
        
  <!-- ====================================================================== -->
  <!-- Grid Document Hit Template                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit" mode="grid">

    <xsl:variable name="fullark" select="meta/identifier[1]"/>

        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="dynaxml.url">
              <xsl:with-param name="fullark" select="$fullark"/>
            </xsl:call-template>
          </xsl:attribute>
<xsl:call-template name="docHit-thumbnail"/>
        </a>
    
  </xsl:template>
        
  <!-- ====================================================================== -->
  <!-- Snippet Template                                                       -->
  <!-- ====================================================================== -->

  <xsl:template match="snippet[parent::docHit]">
		<div>
    <xsl:text>...</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>...</xsl:text>
		</div>
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
    <xsl:variable name="fullark" select="ancestor::docHit/meta/identifier[1]"/>
    <xsl:variable name="hit.rank"><xsl:value-of select="ancestor::snippet/@rank"/></xsl:variable>
    
    <xsl:variable name="snippet.link">    
      <xsl:call-template name="dynaxml.url">
        <xsl:with-param name="fullark" select="$fullark"/>
      </xsl:call-template>
      <xsl:value-of select="concat('&amp;hit.rank=', $hit.rank)"/>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="ancestor::snippet[parent::docHit]">
        <a class="search-item" href="{$snippet.link}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="search-term">  
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose> 
   
  </xsl:template>
      
</xsl:stylesheet>
