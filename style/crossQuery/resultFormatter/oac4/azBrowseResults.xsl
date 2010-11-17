<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:editURL="http://cdlib.org/xtf/editURL"
	exclude-result-prefixes="#all"
	xmlns:tmpl="xslt://template">


<!-- use for /titles/ and /institution/repository/ pages -->

<xsl:template match="docHit[meta/oac4-tab='Collections::marc']" mode="azBrowseResults">
<div class="institutions-container">
	<div class="institutions-left">&#160;</div>
	<div class="institutions-right">
		<a href="/search?{editURL:set(substring-after($http.URL,'?'),'idT',meta/idT[1])}">
			<xsl:value-of select="meta/title[1]"/>
		</a>
	</div>
</div>
</xsl:template>

<xsl:template match="docHit[meta/oac4-tab='Collections::marc']" mode="azBrowseResultsDescriptions">
<div class="institutions-container">
	<div class="institutions-left">&#160;</div>
	<div class="institutions-right">
		<a href="/search?{editURL:set(substring-after($http.URL,'?'),'idT',meta/idT[1])}">
			<b><xsl:value-of select="meta/title[1]"/></b>
		</a>
		<p>
		<xsl:value-of select="tokenize(meta/description[1],'\s+')[position() &lt; 41]"/>
		<xsl:if test="tokenize(meta/description[1],'\s+')[41]">
			<xsl:text>...</xsl:text>
		</xsl:if>
		</p>
	</div>
</div>
</xsl:template>

<xsl:template match="docHit[meta/oac4-tab='Collections::ead']" mode="azBrowseResults">
<div class="institutions-container">
	<div class="institutions-left">
		<xsl:choose>
			<xsl:when test="meta/facet-onlineItems = 'Items online'">
				<img src="/images/icons/eye_icon_white_bg.gif" 
					width="17" height="10" alt="" 
					title="descriptions" />
			</xsl:when>
			<xsl:otherwise>&#160;</xsl:otherwise>
		</xsl:choose>
	</div>
	<div class="institutions-right">
		<a href="/findaid/{replace(meta/identifier[1],'.*(ark:/.*)','$1')}/">
			<xsl:value-of select="meta/title[1]"/>
		</a>
	</div>
</div>
</xsl:template>

<xsl:template match="docHit[meta/oac4-tab='Collections::ead']" mode="azBrowseResultsDescriptions">
<div class="institutions-container">
        <div class="institutions-left">
                <xsl:choose>
                        <xsl:when test="meta/facet-onlineItems = 'Items online'">
                                <img src="/images/icons/eye_icon_white_bg.gif" 
                                        width="17" height="10" alt="" 
                                        title="descriptions" />
                        </xsl:when>
                        <xsl:otherwise>&#160;</xsl:otherwise>
                </xsl:choose>
        </div>
        <div class="institutions-right">
                <a href="/findaid/{replace(meta/identifier[1],'.*(ark:/.*)','$1')}/">
                        <b><xsl:value-of select="meta/title[1]"/></b>
                </a>
		<p>
		<xsl:value-of select="tokenize(meta/description[1],'\s+')[position() &lt; 41]"/>
		<xsl:if test="tokenize(meta/description[1],'\s+')[41]">
			<xsl:text>...</xsl:text>
		</xsl:if>
		</p>
        </div>
</div>
</xsl:template>

<xsl:template match="*" mode="azBrowseResults azBrowseResultsDescriptions">
<div><xsl:value-of select="."/></div>
</xsl:template>

</xsl:stylesheet>
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
