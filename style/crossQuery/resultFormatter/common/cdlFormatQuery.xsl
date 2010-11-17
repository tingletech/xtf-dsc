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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xtf="http://cdlib.org/xtf"
                version="2.0">
    
    <xsl:param name="keyword"/>
    <xsl:param name="fieldList"/>
    <xsl:param name="style"/>
    
<!-- ====================================================================== -->
<!-- Format Query for Display                                               -->
<!-- ====================================================================== -->
    
    <xsl:template name="format-query">
        
        <xsl:param name="query"/>
        
        <xsl:choose>
            <xsl:when test="$keyword">
                <!-- probably very fragile -->
                <xsl:apply-templates select="(query//*[@fields])[1]/*" mode="query"/>
                <xsl:choose>
                    <!-- if they did not search all fields, tell them which are in the fieldList -->
                    <xsl:when test="$fieldList">
                        <xsl:text> in </xsl:text>
                        <span class="search-type">
                            <xsl:value-of select="replace($fieldList,'\s',', ')"/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> in </xsl:text>
                        <span class="search-type"> keywords</span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="query" mode="query"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="and | or | exact | near | range | not" mode="query">
        <xsl:choose>
            <xsl:when test="@field">    
                <xsl:if test="not(position() = 2)">
                    <xsl:value-of select="name(..)"/><xsl:text> </xsl:text>
                </xsl:if>
                <xsl:apply-templates mode="query"/>
                <xsl:text> in </xsl:text>
                <span class="search-type">
                    <xsl:choose>
                        <xsl:when test="@field = 'text'">
                            <xsl:text> the full text </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="$style='melrec'">
                                    <xsl:call-template name="map-index">
                                        <xsl:with-param name="string" select="@field"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@field"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="query"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="term" mode="query">
        <xsl:if test="preceding-sibling::term and (. != $keyword)">
            <xsl:value-of select="name(..)"/>
            <xsl:text> </xsl:text>
        </xsl:if>
        <span class="search-term">
            <xsl:value-of select="."/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="phrase" mode="query">
        <xsl:text>&quot;</xsl:text>
        <span class="search-term">
            <xsl:value-of select="term"/>
        </span>
        <xsl:text>&quot;</xsl:text>
    </xsl:template>
    
    <xsl:template match="exact" mode="query">
        <xsl:text>'</xsl:text>
        <span class="search-term"><xsl:value-of select="term"/></span>
        <xsl:text>'</xsl:text>
        <xsl:if test="@field">
            <xsl:text> in </xsl:text>
            <span class="search-type"><xsl:value-of select="@field"/></span>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="upper" mode="query">
        <xsl:if test="../lower != .">
            <xsl:text> - </xsl:text>
            <xsl:apply-templates mode="query"/>
        </xsl:if>
    </xsl:template>
    
    <!-- ====================================================================== -->
    <!-- Mapping Templates                                                      -->
    <!-- ====================================================================== -->
    
    <xsl:template name="map-index">
        <xsl:param name="string"/>
        <xsl:variable name="map" select="document('')//xtf:label-map"/>
        <xsl:value-of select="$map/xtf:regex/xtf:replace[preceding-sibling::xtf:find[1]/text()=$string]"/>
    </xsl:template>
    
    <xtf:label-map>
        <xtf:regex>
            <xtf:find>title-journal</xtf:find>
            <xtf:replace>journal title</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>title-main</xtf:find>
            <xtf:replace>title</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>title-series</xtf:find>
            <xtf:replace>series title</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>author</xtf:find>
            <xtf:replace>author</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>author-corporate</xtf:find>
            <xtf:replace>organization author</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>pub-place</xtf:find>
            <xtf:replace>place of publication</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>publisher</xtf:find>
            <xtf:replace>publisher</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>year</xtf:find>
            <xtf:replace>year</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>language</xtf:find>
            <xtf:replace>language</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>note</xtf:find>
            <xtf:replace>note</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>subject</xtf:find>
            <xtf:replace>subject</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>subject-geographic</xtf:find>
            <xtf:replace>georgraphic subject</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>subject-topic</xtf:find>
            <xtf:replace>topical subject</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>subject-temporal</xtf:find>
            <xtf:replace>temporal subject</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>callnum</xtf:find>
            <xtf:replace>call number</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>callnum-class</xtf:find>
            <xtf:replace>call number class</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>format</xtf:find>
            <xtf:replace>format</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>location</xtf:find>
            <xtf:replace>location</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>identifier-isbn</xtf:find>
            <xtf:replace>ISBN</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>identifier-issn</xtf:find>
            <xtf:replace>ISSN</xtf:replace>
        </xtf:regex>
        <xtf:regex>
            <xtf:find>origin</xtf:find>
            <xtf:replace>origin</xtf:replace>
        </xtf:regex>
    </xtf:label-map>    
</xsl:stylesheet>
