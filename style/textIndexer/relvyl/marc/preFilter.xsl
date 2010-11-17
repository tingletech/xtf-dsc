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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:marc="http://www.loc.gov/MARC21/slim" 
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:xtf="http://cdlib.org/xtf"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:parse="http://cdlib.org/xtf/parse"
	xmlns:mets="http://www.loc.gov/METS/"
	extension-element-prefixes="date"
	exclude-result-prefixes="marc">
	
	<!-- ====================================================================== -->
	<!-- Import Common Templates and Functions                                  -->
	<!-- ====================================================================== -->
	
	<xsl:import href="../../common/preFilterCommon.xsl"/>
	
	<!-- ====================================================================== -->
	<!-- Local Parameters                                                       -->
	<!-- ====================================================================== -->
	
	<!-- Aare double slashes necessary? -->
	<xsl:variable name="sysID" select="//marc:controlfield[@tag=001]"/>
	<xsl:variable name="leader" select="//marc:leader"/>
	<xsl:variable name="leader6" select="substring($leader,7,1)"/>
	<xsl:variable name="leader7" select="substring($leader,8,1)"/>
	<xsl:variable name="controlField008" select="//marc:controlfield[@tag=008]"/>
	<xsl:variable name="controlField008-7-10" select="normalize-space(substring($controlField008, 8, 4))"/>
	<xsl:variable name="controlField008-11-14" select="normalize-space(substring($controlField008, 12, 4))"/>
	<xsl:variable name="controlField008-15-17" select="normalize-space(substring($controlField008, 16, 3))"/>				
	<xsl:variable name="controlField008-35-37" select="normalize-space(substring($controlField008, 36, 3))"/>
	<xsl:variable name="typeOf008">
		<xsl:choose>
			<xsl:when test="$leader6='b' or $leader6='p'">MX</xsl:when>
			<xsl:when test="$leader6='t'">BK</xsl:when>
			<xsl:when test="$leader6='c' or $leader6='d' or $leader6='i' or $leader6='j'">MU</xsl:when>
			<xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>
			<xsl:when test="$leader6='g' or $leader6='k' or $leader6='o' or $leader6='r'">VM</xsl:when>
			<xsl:when test="$leader6='m'">CF</xsl:when>
			<xsl:when test="$leader6='a'">
				<xsl:choose>
					<xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">BK</xsl:when>
					<xsl:when test="$leader7='b' or $leader7='s'">SE</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="LOC">
		<xsl:for-each select="//marc:datafield[@tag=050]">
			<xsl:value-of select="."/>
		</xsl:for-each>
		<xsl:for-each select="//marc:datafield[@tag=060]">
			<xsl:value-of select="."/>
		</xsl:for-each>
		<xsl:for-each select="//marc:datafield[@tag=090]">
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:variable>
	
	<!-- ====================================================================== -->
	<!-- Root Template                                                          -->
	<!-- ====================================================================== -->

	<xsl:template match="/">
		<xtf:meta>
			
			<!-- Normal Processing -->
			<!--<xsl:apply-templates/>-->
			
			<!-- Dedupe Processing -->
			<xsl:call-template name="deDupe"/>
			
			<!-- Record metadata and/or text origin -->
			<origin xtf:meta="true">
				<xsl:value-of select="'MARC'"/>
			</origin>
			
		</xtf:meta>
	</xsl:template>

    <xsl:template match="marc:record">
        <xsl:apply-templates/>
	    <xsl:call-template name="processControlFields"/>
    </xsl:template>

	<!-- CDL: title-main -->
	<xsl:template match="marc:datafield[@tag=130 or @tag=240]">
		
		<xsl:variable name="str">
			<xsl:choose>
				<xsl:when test="@tag=130">
					<xsl:for-each select="marc:subfield">
						<xsl:if test="(contains('adfgklmnoprst',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=240">
					<xsl:for-each select="marc:subfield">
						<xsl:if test="(contains('adfgklmnoprs',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="title">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<title-main>	
			<xsl:call-template name="meta-attributes"/>
			<xsl:value-of select="$title"/>
		</title-main>
		
		<xsl:if test="$typeOf008='SE'">
			<title-journal>	
				<xsl:call-template name="meta-attributes"/>
				<xsl:value-of select="$title"/>
			</title-journal>
		</xsl:if>
		
		<!--<xsl:call-template name="createFacetTitle">
			<xsl:with-param name="label" select="'title-main'"/>
			<xsl:with-param name="string">
				<xsl:value-of select="$title"/>
			</xsl:with-param>
		</xsl:call-template>-->
		
		<merge-title>
			<xsl:attribute name="xtf:meta" select="'true'"/>
			<xsl:attribute name="xtf:tokenize" select="'no'"/>
			<xsl:attribute name="xtf:index" select="'yes'"/>
			<xsl:value-of select="parse:merge-title($title)"/>
			<xsl:value-of select="concat(' [', @tag, ']')"/>
		</merge-title>
		
	</xsl:template>

	<!-- CDL: title-main -->
	<xsl:template match="marc:datafield[@tag=245 or @tag=247]">
		
		<xsl:variable name="str">
			<xsl:choose>
				<xsl:when test="@tag=245">
					<xsl:choose>
						<xsl:when test="marc:subfield[@code='b']">
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="axis">b</xsl:with-param>
								<xsl:with-param name="beforeCodes">adefgknps</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">adefgknps</xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="@tag=247">
					<xsl:choose>
						<xsl:when test="marc:subfield[@code='b']">
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="axis">b</xsl:with-param>
								<xsl:with-param name="beforeCodes">adegnp</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="subfieldSelect">
								<xsl:with-param name="codes">adegnp</xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="titleChop">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:value-of select="$str"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="afterCodes">
			<xsl:choose>
				<xsl:when test="@tag=245">adefgknps</xsl:when>
				<xsl:when test="@tag=247">adegnp</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="title">	
			<xsl:value-of select="$titleChop"/>
			<xsl:if test="marc:subfield[@code='b']">
				<xsl:text>: </xsl:text>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="specialSubfieldSelect">
							<xsl:with-param name="axis">b</xsl:with-param>
							<xsl:with-param name="anyCodes">b</xsl:with-param>
							<xsl:with-param name="afterCodes" select="$afterCodes"/>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		
		<title-main>	
			<xsl:call-template name="meta-attributes"/>	
			<xsl:value-of select="$title"/>
		</title-main>
		
		<xsl:if test="$typeOf008='SE'">
			<title-journal>		
				<xsl:call-template name="meta-attributes"/>	
				<xsl:value-of select="$title"/>
			</title-journal>
			<!--<xsl:call-template name="createFacetTitle">
				<xsl:with-param name="label" select="'title-journal'"/>
				<xsl:with-param name="string">
					<xsl:value-of select="$title"/>
				</xsl:with-param>
				</xsl:call-template>-->		
			
			<merge-title>
				<xsl:attribute name="xtf:meta" select="'true'"/>
				<xsl:attribute name="xtf:tokenize" select="'no'"/>
				<xsl:attribute name="xtf:index" select="'yes'"/>
				<xsl:value-of select="parse:merge-title($title)"/>
				<xsl:value-of select="concat(' [', @tag, ']')"/>
			</merge-title>
			
		</xsl:if>
		
		<!-- CDL: sort-title from 245[1] only? -->
		<xsl:if test="@tag=245 and not(preceding-sibling::marc:datafield[@tag=245])">
			<sort-title>
				<xsl:call-template name="meta-attributes"/>
				<xsl:attribute name="xtf:tokenize">
					<xsl:value-of select="'no'"/>
				</xsl:attribute>
				<xsl:variable name="sort-title">		
					<xsl:choose>
						<!-- CDL: Get rid of non-sort string -->
						<xsl:when test="number(@ind2)&gt;0">
							<xsl:value-of select="substring($titleChop,number(@ind2)+1)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$titleChop"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="parse:title($sort-title)"/>
			</sort-title>
		</xsl:if>
		
		<!--<xsl:call-template name="createFacetTitle">
			<xsl:with-param name="label" select="'title-main'"/>
			<xsl:with-param name="string">
				<xsl:value-of select="$title"/>
			</xsl:with-param>
		</xsl:call-template>-->
		
		<merge-title>
			<xsl:attribute name="xtf:meta" select="'true'"/>
			<xsl:attribute name="xtf:tokenize" select="'no'"/>
			<xsl:attribute name="xtf:index" select="'yes'"/>
			<xsl:value-of select="parse:merge-title($title)"/>
			<xsl:value-of select="concat(' [', @tag, ']')"/>
		</merge-title>
		
	</xsl:template>
	
	<!-- CDL: title-journal -->
	<xsl:template match="marc:datafield[@tag=100 or @tag=110 or @tag=111 or @tag=210 or 
		                                @tag=212 or @tag=222 or @tag=241 or @tag=242 or 
		                                @tag=243 or @tag=246 or @tag=700 or @tag=710 or 
		                                @tag=730 or @tag=740 or @tag=780 or @tag=785 or 
		                                @tag=791 or @tag=792 or @tag=793 or @tag=796 or 
		                                @tag=797 or @tag=798 or @tag=799]">
		
		<xsl:variable name="tag">
			<xsl:value-of select="@tag"/>
		</xsl:variable>
		
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:choose>
					<xsl:when test="$tag=100">
						<xsl:if test="(contains('abcdfgklnpqt',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=110">
						<xsl:if test="(contains('abcdfgklnpt',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=111">
						<xsl:if test="(contains('abcdefgklnpqt',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=210">
						<xsl:if test="(contains('a',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=212">
						<xsl:if test="(contains('a',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=222">
						<xsl:if test="(contains('ab',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=241">
						<xsl:if test="(contains('a',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=242">
						<xsl:if test="(contains('abden',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=243">
						<xsl:if test="(contains('adfgklmnoprs',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=246">
						<xsl:if test="(contains('abdegnp',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=700">
						<xsl:if test="(contains('bcdfgklmnopqrst',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=710">
						<xsl:if test="(contains('abcdfgklmnoprst',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=730">
						<xsl:if test="(contains('adfgklmnoprst',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=740">
						<xsl:if test="(contains('anp',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=780">
						<xsl:if test="(contains('ast',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=785">
						<xsl:if test="(contains('ast',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=791">
						<xsl:if test="(contains('abcdfgklmnopqrst',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=792">
						<xsl:if test="(contains('abcdfgklmnoprst',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=793">
						<xsl:if test="(contains('abcdefgklnpqst',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=796">
						<xsl:if test="(contains('adfgklmnoprst',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=797">
						<xsl:if test="(contains('abcdfgklmnopqrst',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=798">
						<xsl:if test="(contains('abcdfgklmnoprst',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=799">
						<xsl:if test="(contains('abcdefgklnpqst',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="title">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:if test="$typeOf008='SE'">
			<title-journal>	
				<xsl:call-template name="meta-attributes"/>
				<xsl:value-of select="$title"/>
			</title-journal>
			<!--<xsl:call-template name="createFacetTitle">
				<xsl:with-param name="label" select="'title-journal'"/>
				<xsl:with-param name="string">
					<xsl:value-of select="$title"/>
				</xsl:with-param>
				</xsl:call-template>-->		
			<merge-title>
				<xsl:attribute name="xtf:meta" select="'true'"/>
				<xsl:attribute name="xtf:tokenize" select="'no'"/>
				<xsl:attribute name="xtf:index" select="'yes'"/>
				<xsl:value-of select="parse:merge-title($title)"/>
				<xsl:value-of select="concat(' [', @tag, ']')"/>
			</merge-title>
		</xsl:if>
		        
		<xsl:if test="@tag=100 or @tag=700 or @tag=796">
			<author>	
				<xsl:call-template name="meta-attributes"/>
				<xsl:call-template name="nameABCDQ"/>
			</author>
			<!--<xsl:call-template name="createFacetAuthor">
				<xsl:with-param name="label" select="'author'"/>
				<xsl:with-param name="string">
					<xsl:call-template name="nameABCDQ"/>
				</xsl:with-param>
				</xsl:call-template>-->	
			
			<xsl:variable name="merge-author">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">aq</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="punctuation">
						<xsl:text>:,;/ </xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			
			<merge-author>
				<xsl:attribute name="xtf:meta" select="'true'"/>
				<xsl:attribute name="xtf:tokenize" select="'no'"/>
				<xsl:attribute name="xtf:index" select="'yes'"/>
				<xsl:value-of select="lower-case(replace($merge-author, '[.,]', ''))"/>
				<xsl:value-of select="concat(' [', @tag, ']')"/>
			</merge-author>
			
		</xsl:if>
		
		<xsl:if test="@tag=110 or @tag=710 or @tag=791 or @tag=797 or @tag=798">
			<author-corporate>	
				<xsl:call-template name="meta-attributes"/>
				<xsl:call-template name="nameABCDN"/>
			</author-corporate>
			
			<!--<xsl:call-template name="createFacetAlpha">
				<xsl:with-param name="label" select="'author-corporate'"/>
				<xsl:with-param name="string">
					<xsl:call-template name="nameABCDN"/>
				</xsl:with-param>
				</xsl:call-template>-->		
			
			<xsl:variable name="merge-author">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">a</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="punctuation">
						<xsl:text>:,;/ </xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			
			<merge-author>
				<xsl:attribute name="xtf:meta" select="'true'"/>
				<xsl:attribute name="xtf:tokenize" select="'no'"/>
				<xsl:attribute name="xtf:index" select="'yes'"/>
				<xsl:value-of select="lower-case(replace($merge-author, '[.,]', ''))"/>
				<xsl:value-of select="concat(' [', @tag, ']')"/>
			</merge-author>
			
		</xsl:if>
		
        <!-- CDL: sort-author from 100[1] only? -->
        <xsl:if test="@tag=100 and not(preceding-sibling::marc:datafield[@tag=100])">
            <sort-author>
                <xsl:call-template name="meta-attributes"/>
                <xsl:attribute name="xtf:tokenize">
                    <xsl:value-of select="'no'"/>
                </xsl:attribute>
                <xsl:variable name="sort-author">
                    <xsl:for-each select="marc:subfield">
                        <xsl:if test="(contains('abcdkq',@code))">
                            <xsl:value-of select="text()"/>
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="parse:name($sort-author)"/>
            </sort-author>
        </xsl:if>
        
	</xsl:template>
	
	<!-- CDL: title-series -->
	<xsl:template match="marc:datafield[@tag=400 or @tag=410 or @tag=411 or @tag=440 or 
		                                @tag=490 or @tag=800 or @tag=810 or @tag=811 or 
		                                @tag=830 or @tag=840 or @tag=896 or @tag=897 or 
		                                @tag=898 or @tag=899]">
		
		<xsl:variable name="tag">
			<xsl:value-of select="@tag"/>
		</xsl:variable>
		
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:choose>
					<xsl:when test="$tag=400">
						<xsl:if test="(contains('abcdfgklnptv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=410">
						<xsl:if test="(contains('abcdfgklnptv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=411">
						<xsl:if test="(contains('abcdefgklnpqtv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=440">
						<xsl:if test="(contains('anpv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=490">
						<xsl:if test="(contains('av',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=800">
						<xsl:if test="(contains('abcdfgklmnopqrstv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=810">
						<xsl:if test="(contains('abcdfgklmnoprstv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=811">
						<xsl:if test="(contains('abcdefgklnpqstv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=830">
						<xsl:if test="(contains('adfgklmnoprstv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=840">
						<xsl:if test="(contains('av',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=896">
						<xsl:if test="(contains('abcdfgklmnopqrstv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=897">
						<xsl:if test="(contains('abcdfgklmnoprstv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=898">
						<xsl:if test="(contains('abcdefgklnpqstv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$tag=899">
						<xsl:if test="(contains('adfgklmnoprstv',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="title">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<title-series>	
			<xsl:call-template name="meta-attributes"/>
			<xsl:value-of select="$title"/>
		</title-series>
		
		<!--<xsl:call-template name="createFacetTitle">
			<xsl:with-param name="label" select="'title-series'"/>
			<xsl:with-param name="string">
				<xsl:value-of select="$title"/>
			</xsl:with-param>
		</xsl:call-template>-->
		
		<merge-title>
			<xsl:attribute name="xtf:meta" select="'true'"/>
			<xsl:attribute name="xtf:tokenize" select="'no'"/>
			<xsl:attribute name="xtf:index" select="'yes'"/>
			<xsl:value-of select="parse:merge-title($title)"/>
			<xsl:value-of select="concat(' [', @tag, ']')"/>
		</merge-title>
		
		<xsl:if test="@tag=400 or @tag=800 or @tag=896">
			<author>	
				<xsl:call-template name="meta-attributes"/>
				<xsl:call-template name="nameABCDQ"/>
			</author>
			<!--<xsl:call-template name="createFacetAuthor">
				<xsl:with-param name="label" select="'author'"/>
				<xsl:with-param name="string">
					<xsl:call-template name="nameABCDQ"/>
				</xsl:with-param>
				</xsl:call-template>-->		

			<xsl:variable name="merge-author">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">aq</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="punctuation">
						<xsl:text>:,;/ </xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			
			<merge-author>
				<xsl:attribute name="xtf:meta" select="'true'"/>
				<xsl:attribute name="xtf:tokenize" select="'no'"/>
				<xsl:attribute name="xtf:index" select="'yes'"/>
				<xsl:value-of select="lower-case(replace($merge-author, '[.,]', ''))"/>
				<xsl:value-of select="concat(' [', @tag, ']')"/>
			</merge-author>
			
		</xsl:if>
		
		<xsl:if test="@tag=410 or @tag=810 or @tag=897">
			<author-corporate>	
				<xsl:call-template name="meta-attributes"/>
				<xsl:call-template name="nameABCDN"/>
			</author-corporate>	
			
			<!--<xsl:call-template name="createFacetAlpha">
				<xsl:with-param name="label" select="'author-corporate'"/>
				<xsl:with-param name="string">
				<xsl:call-template name="nameABCDN"/>
				</xsl:with-param>
				</xsl:call-template>-->
			
			<xsl:variable name="merge-author">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">a</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="punctuation">
						<xsl:text>:,;/ </xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			
			<merge-author>
				<xsl:attribute name="xtf:meta" select="'true'"/>
				<xsl:attribute name="xtf:tokenize" select="'no'"/>
				<xsl:attribute name="xtf:index" select="'yes'"/>
				<xsl:value-of select="lower-case(replace($merge-author, '[.,]', ''))"/>
				<xsl:value-of select="concat(' [', @tag, ']')"/>
			</merge-author>

		</xsl:if>
		
	</xsl:template>

	<!-- CDL: author -->
	<xsl:template match="marc:datafield[@tag=790]">	
		
		<author>	
			<xsl:call-template name="meta-attributes"/>
			<xsl:call-template name="nameABCDQ"/>
		</author>
		
		<!--<xsl:call-template name="createFacetAuthor">
			<xsl:with-param name="label" select="'author'"/>
			<xsl:with-param name="string">
				<xsl:call-template name="nameABCDQ"/>
			</xsl:with-param>
			</xsl:call-template>-->

		<xsl:variable name="merge-author">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">aq</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="punctuation">
					<xsl:text>:,;/ </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<merge-author>
			<xsl:attribute name="xtf:meta" select="'true'"/>
			<xsl:attribute name="xtf:tokenize" select="'no'"/>
			<xsl:attribute name="xtf:index" select="'yes'"/>
			<xsl:value-of select="lower-case(replace($merge-author, '[.,]', ''))"/>
			<xsl:value-of select="concat(' [', @tag, ']')"/>
		</merge-author>
		
	</xsl:template>

	<!-- CDL: publisher -->		
	<xsl:template match="marc:datafield[@tag=260]">

		<xsl:for-each select="marc:subfield[@code='a']">		
			<pub-place>	
				<xsl:call-template name="meta-attributes"/>
				<xsl:call-template name="chopPunctuationFront">
					<xsl:with-param name="chopString">
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString" select="."/>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</pub-place>
		</xsl:for-each>
		
		<xsl:for-each select="marc:subfield[@code='b']">	
			<xsl:variable name="publisher">
				<xsl:call-template name="chopPunctuationFront">
					<xsl:with-param name="chopString">
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString" select="."/>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<publisher>	
				<xsl:call-template name="meta-attributes"/>
				<xsl:value-of select="$publisher"/>
			</publisher>
			<!--<xsl:call-template name="createFacetAlpha">
				<xsl:with-param name="label" select="'publisher'"/>
				<xsl:with-param name="string">
				<xsl:value-of select="$publisher"/>
				</xsl:with-param>
			</xsl:call-template>-->
		</xsl:for-each>
		
	</xsl:template>

	<!-- CDL: pub-place -->						
	<xsl:template match="marc:datafield[@tag=261 or @tag=262]">
		
		<xsl:variable name="str">
			<xsl:choose>
				<xsl:when test="@tag=261">
					<xsl:for-each select="marc:subfield">
						<xsl:if test="(contains('f',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=262">
					<xsl:for-each select="marc:subfield">
						<xsl:if test="(contains('ab',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<pub-place>	
			<xsl:call-template name="meta-attributes"/>
			<xsl:call-template name="chopPunctuationFront">
				<xsl:with-param name="chopString">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString" select="substring($str,1,string-length($str)-1)"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</pub-place>
		
	</xsl:template>


	<!-- CDL: language -->					
	<xsl:template match="marc:datafield[@tag=041]">
		<xsl:variable name="langCodes" select="marc:subfield[@code='a'or @code='d' or @code='e' or @code='2']"/>
		<xsl:variable name="language">
			<xsl:choose>
				<xsl:when test="marc:subfield[@code='2']='rfc3066'">
					<xsl:call-template name="rfcLanguages">
						<xsl:with-param name="nodeNum">
							<xsl:value-of select="1"/>
						</xsl:with-param>
						<xsl:with-param name="usedLanguages">
							<xsl:text/>
						</xsl:with-param>
						<xsl:with-param name="controlField008-35-37">
							<xsl:value-of select="$controlField008-35-37"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="allLanguages">
						<xsl:copy-of select="$langCodes"/>
					</xsl:variable>
					<xsl:variable name="currentLanguage">
						<xsl:value-of select="substring($allLanguages,1,3)"/>
					</xsl:variable>
					<xsl:call-template name="isoLanguage">
						<xsl:with-param name="currentLanguage">
							<xsl:value-of select="substring($allLanguages,1,3)"/>
						</xsl:with-param>
						<xsl:with-param name="remainingLanguages">
							<xsl:value-of select="substring($allLanguages,4,string-length($allLanguages)-3)"/>
						</xsl:with-param>
						<xsl:with-param name="usedLanguages">
							<xsl:if test="$controlField008-35-37">
								<xsl:value-of select="$controlField008-35-37"/>
							</xsl:if>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space($language) != ''">
			<language>
				<xsl:call-template name="meta-attributes"/>
				<xsl:value-of select="$language"/>
			</language>
			<!--<xsl:call-template name="createFacetLanguage">
				<xsl:with-param name="label" select="'language'"/>
				<xsl:with-param name="string">
					<xsl:value-of select="translate($language, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
				</xsl:with-param>
			</xsl:call-template>-->
		</xsl:if>
	</xsl:template>

	<!-- CDL: note -->	
	<!-- CDL: identifier-isbn -->
	<!-- CDL: identifier-issn -->
	<xsl:template match="marc:datafield[@tag=500 or @tag=501 or @tag=502 or @tag=503 or 
		                                @tag=504 or @tag=505 or @tag=506 or @tag=507 or 
		                                @tag=508 or @tag=510 or @tag=511 or @tag=512 or 
		                                @tag=513 or @tag=514 or @tag=515 or @tag=516 or 
		                                @tag=517 or @tag=518 or @tag=521 or @tag=522 or 
		                                @tag=523 or @tag=524 or @tag=525 or @tag=527 or 
		                                @tag=530 or @tag=533 or @tag=534 or @tag=535 or 
		                                @tag=536 or @tag=537 or @tag=538 or @tag=540 or 
		                                @tag=541 or @tag=543 or @tag=544 or @tag=545 or 
		                                @tag=546 or @tag=547 or @tag=550 or @tag=551 or 
		                                @tag=555 or @tag=556 or @tag=561 or @tag=562 or 
		                                @tag=565 or @tag=567 or @tag=570 or @tag=580 or 
		                                @tag=581 or @tag=582 or @tag=583 or @tag=584 or 
		                                @tag=585 or @tag=586]">
		
		<xsl:variable name="str">
			<xsl:choose>
				<xsl:when test="@tag=500 or @tag=501 or @tag=502 or @tag=503 or 
					            @tag=508 or @tag=511 or @tag=512 or @tag=516 or 
					            @tag=523 or @tag=525 or @tag=530 or @tag=538 or 
					            @tag=540 or @tag=543 or @tag=567 or @tag=582 or 
					            @tag=585 or @tag=586">
					<xsl:for-each select="marc:subfield[@code='a']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=504 or @tag=507 or @tag=513 or @tag=518 or 
					            @tag=522 or @tag=524 or @tag=545 or @tag=561 or 
					            @tag=584">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=515 or @tag=527 or @tag=547 or @tag=550 or 
					            @tag=556 or @tag=570 or @tag=580 or @tag=581">
					<xsl:for-each select="marc:subfield[@code='a' or @code='z']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=517">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=521 or @tag=546">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='z']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=505">
					<xsl:for-each select="marc:subfield[@code='a' or @code='g' or @code='r' or @code='t']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=506">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or 
						                                @code='e']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=510">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='x']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=514">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or 
						                                @code='e' or @code='f' or @code='g' or @code='h' or 
						                                @code='i' or @code='j' or @code='k' or @code='m']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=533">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or 
						                                @code='z']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=534">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or 
						                                @code='e' or @code='f' or @code='m' or @code='n']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=535">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or 
						                                @code='f' or @code='k' or @code='l' or @code='m' or 
						                                @code='n' or @code='p' or @code='t' or @code='x' or 
						                                @code='z']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=536">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or 
						                                @code='g']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=537 or @tag=555">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=541">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or 
						                                @code='e' or @code='f' or @code='h' or @code='n' or 
						                                @code='o']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=544 or @tag=562 or @tag=565">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or 
						                                @code='e']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=551">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or 
						                                @code='e' or @code='f' or @code='g' or @code='h' or 
						                                @code='i' or @code='j' or @code='k' or @code='l' or 
						                                @code='m' or @code='n' or @code='o' or @code='p']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="@tag=583">
					<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c' or @code='d' or 
						                                @code='e' or @code='f' or @code='h' or @code='i' or 
						                                @code='j' or @code='k' or @code='l' or @code='n' or 
						                                @code='o' or @code='x' or @code='z']">
						<xsl:value-of select="."/>
						<xsl:text> </xsl:text>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="note">
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:variable>
		
		<note>
			<xsl:call-template name="meta-attributes"/>
			<xsl:value-of select="$note"/>
		</note>
		
		<xsl:if test="@tag=534">
			<xsl:call-template name="relatedIdentifierISSN"/>
			<xsl:for-each select="marc:subfield[@code='z']">
				<identifier-isbn>
					<xsl:value-of select="."/>
				</identifier-isbn>
				<merge-id>
					<xsl:attribute name="xtf:meta" select="'true'"/>
					<xsl:attribute name="xtf:tokenize" select="'no'"/>
					<xsl:attribute name="xtf:index" select="'yes'"/>
					<xsl:value-of select="concat(., ' (ISBN)')"/>
					<xsl:value-of select="concat(' [', @tag, ']')"/>
				</merge-id>
			</xsl:for-each>
		</xsl:if>
		
	</xsl:template>

	<!-- CDL: subject -->	
	<xsl:template match="marc:datafield[@tag=600 or @tag=610 or @tag=611 or @tag=630 or 
		                                @tag=650 or @tag=651 or @tag=653 or @tag=655 or 
		                                @tag=690 or @tag=691 or @tag=692 or @tag=693 or 
		                                @tag=694 or @tag=695 or @tag=696 or @tag=697 or 
		                                @tag=698 or @tag=699 or @tag=755]">	
		
		<xsl:variable name="subjectAuthority">
			<xsl:call-template name="subjectAuthority"/>
		</xsl:variable>
		
		<xsl:variable name="str">
			<xsl:call-template name="subjectSubfieldSelect">
				<xsl:with-param name="subjectAuthority" select="$subjectAuthority"/>
				<xsl:with-param name="codes">
					<xsl:choose>
						<xsl:when test="@tag=600">abcdfgklmnopqrstvxyz</xsl:when>
						<xsl:when test="@tag=610">abcdfgklmnoprstvxyz</xsl:when>
						<xsl:when test="@tag=611">abcdefgklnpqstvxyz</xsl:when>
						<xsl:when test="@tag=630">adfgklmnoprstvxyz</xsl:when>
						<xsl:when test="@tag=650">abcdvxyz</xsl:when>
						<xsl:when test="@tag=651">abvxyz</xsl:when>
						<xsl:when test="@tag=653">a</xsl:when>
						<xsl:when test="@tag=655">abvxyz</xsl:when>
						<xsl:when test="@tag=690">abcdvxyz</xsl:when>
						<xsl:when test="@tag=691">abvxy</xsl:when>
						<xsl:when test="@tag=692">abcfgklmnopqrstvxyz</xsl:when>
						<xsl:when test="@tag=693">abcdfgklmnoprstvxyz</xsl:when>
						<xsl:when test="@tag=694">abcdefgklnpqstvxyz</xsl:when>
						<xsl:when test="@tag=695">adfgklmnorstxvyz</xsl:when>
						<xsl:when test="@tag=696">abcdfgklmnopqrstvxyz</xsl:when>
						<xsl:when test="@tag=697">abcdfgklmnoprstvxyz</xsl:when>
						<xsl:when test="@tag=698">abcdefgklnpqstvxyz</xsl:when>
						<xsl:when test="@tag=699">adfgklmnoprstvxyz</xsl:when>
						<xsl:when test="@tag=755">axyz</xsl:when>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="subject">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:value-of select="$str"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<subject>
			<xsl:call-template name="meta-attributes"/>
			<xsl:value-of select="$subject"/>
		</subject>
		
		<!--<xsl:call-template name="createFacetSubject">
			<xsl:with-param name="label" select="'subject'"/>
			<xsl:with-param name="string">
				<xsl:call-template name="createSubjectHierarchy">
					<xsl:with-param name="subject" select="$subject"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>-->
		
		<xsl:call-template name="subjectAnyOrder"/>
		
	</xsl:template>

	<!-- CDL: callnum -->	
	<!-- CDL: callnum-class -->	
	<!-- CDL: location -->	
	<xsl:template match="marc:datafield[@tag=852]">
		<xsl:if test="marc:subfield[@code='h' or @code='i' or @code='j']">
			<callnum>
				<xsl:call-template name="meta-attributes"/>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">hij</xsl:with-param>
				</xsl:call-template>
			</callnum>
		</xsl:if>                                                                      <!-- To filter out those call numbers beginning with I,X, and Y, except Y4 -->                                     
		<xsl:if test="(marc:subfield[@code='h']) and (normalize-space($LOC) != '') and (matches(marc:subfield[@code='h'], '^[ABCDEFGHJKLMNOPQRSTUVWZ]') or matches(marc:subfield[@code='h'], '^Y4'))">
			<callnum-class>
				<xsl:call-template name="meta-attributes"/>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">h</xsl:with-param>
				</xsl:call-template>
			</callnum-class>
			<!--<xsl:call-template name="createFacetCallnumClass">
				<xsl:with-param name="label" select="'callnum-class'"/>
				<xsl:with-param name="string">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">h</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>-->
		</xsl:if>
		<xsl:if test="marc:subfield[@code='a' or @code='b' or @code='e' or @code='j']">
			<location>
				<xsl:call-template name="meta-attributes"/>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abej</xsl:with-param>
				</xsl:call-template>
			</location>
		</xsl:if>
	</xsl:template>	
		
	<!-- CDL: identifier-isbn -->	
	<xsl:template match="marc:datafield[@tag=020]">
		<identifier-isbn>
			<xsl:call-template name="meta-attributes"/>
			<xsl:value-of select="marc:subfield[@code='a']"/>
		</identifier-isbn>
		<merge-id>
			<xsl:attribute name="xtf:meta" select="'true'"/>
			<xsl:attribute name="xtf:tokenize" select="'no'"/>
			<xsl:attribute name="xtf:index" select="'yes'"/>
			<xsl:value-of select="concat(marc:subfield[@code='a'][1], ' (ISBN)')"/>
			<xsl:value-of select="concat(' [', @tag, ']')"/>
		</merge-id>
	</xsl:template>
	
	<!-- CDL: identifier-issn -->	
	<xsl:template match="marc:datafield[@tag=022]">
		<identifier-issn>
			<xsl:call-template name="meta-attributes"/>
			<xsl:value-of select="marc:subfield[@code='a']"/>
		</identifier-issn>
		<merge-id>
			<xsl:attribute name="xtf:meta" select="'true'"/>
			<xsl:attribute name="xtf:tokenize" select="'no'"/>
			<xsl:attribute name="xtf:index" select="'yes'"/>
			<xsl:value-of select="concat(marc:subfield[@code='a'][1], ' (ISSN)')"/>
			<xsl:value-of select="concat(' [', @tag, ']')"/>
		</merge-id>
	</xsl:template>

	<xsl:template match="marc:datafield[@tag=901]">
		<merge-id>
			<xsl:attribute name="xtf:meta" select="'true'"/>
			<xsl:attribute name="xtf:tokenize" select="'no'"/>
			<xsl:attribute name="xtf:index" select="'yes'"/>
			<xsl:value-of select="concat(marc:subfield[@code='b'][1], ' (',marc:subfield[@code='a'],')')"/>
			<xsl:value-of select="concat(' [', @tag, ']')"/>
		</merge-id>
	</xsl:template>
	
	<!-- CDL: Added to contain OCLC Number -->
	<xsl:template match="marc:datafield[@tag=035]">
		<xsl:variable name="M035a" select="string(marc:subfield[@code='a'][1])"/>
		<merge-id>
			<xsl:attribute name="xtf:meta" select="'true'"/>
			<xsl:attribute name="xtf:tokenize" select="'no'"/>
			<xsl:attribute name="xtf:index" select="'yes'"/>
			<xsl:choose>
				<xsl:when test="contains($M035a, '(OCoLC)ocm')">
					<xsl:value-of select="substring-after($M035a, '(OCoLC)ocm')"/>
				</xsl:when>
				<xsl:when test="contains($M035a, '(OCoLC)')">
					<xsl:value-of select="substring-after($M035a, '(OCoLC)')"/>
				</xsl:when>
				<xsl:when test="contains($M035a, 'ocm')">
					<xsl:choose>
						<xsl:when test="contains($M035a, ' ')">
							<xsl:value-of select="substring-before(substring-after($M035a, 'ocm'), ' ')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring-after($M035a, 'ocm')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<xsl:text> (OCLC)</xsl:text>
			<xsl:value-of select="concat(' [', @tag, ']')"/>
		</merge-id>
	</xsl:template>
		
	<!-- ====================================================================== -->
	<!-- Named Templates                                                        -->
	<!-- ====================================================================== -->
	
	<xsl:template name="processControlFields">
		<!-- CDL: pub-place -->	
		<xsl:if test="translate($controlField008-15-17,'|','')">
			<pub-place>	
				<xsl:call-template name="meta-attributes"/>
				<xsl:value-of select="$controlField008-15-17"/>
			</pub-place>
		</xsl:if>		
		<!-- CDL: year -->	
	   <xsl:if test="translate($controlField008-7-10,'|','')">
	      <xsl:variable name="year" select="$controlField008-7-10"/>
			<year>	
				<xsl:call-template name="meta-attributes"/>
			   <xsl:value-of select="$year"/>
			</year>
	      <!-- CDL: sort-year  -->
			<sort-year>
				<xsl:call-template name="meta-attributes"/>
				<xsl:attribute name="xtf:tokenize">
					<xsl:value-of select="'no'"/>
				</xsl:attribute>
			   <xsl:value-of select="$year"/>
			</sort-year>
		   <!-- CDL: date range -->
		   <iso-start-date xtf:meta="true" xtf:tokenize="no">
		      <xsl:value-of select="concat($year,':00:00')"/>
		   </iso-start-date>
		   <iso-end-date xtf:meta="true" xtf:tokenize="no">
		      <xsl:value-of select="concat($year,':00:00')"/>
		   </iso-end-date>
	   </xsl:if>
	   <!-- CDL: year -->	
		<xsl:if test="translate($controlField008-11-14,'|','')">
		   <xsl:if test="not(translate($controlField008-7-10,'|',''))">
		      <xsl:variable name="year" select="$controlField008-11-14"/>
				<year>	
					<xsl:call-template name="meta-attributes"/>
					<xsl:value-of select="$year"/>
				</year>
				<!-- CDL: sort-year  -->
				<sort-year>
					<xsl:call-template name="meta-attributes"/>
					<xsl:attribute name="xtf:tokenize">
				        <xsl:value-of select="'no'"/>
					</xsl:attribute>
				   <xsl:value-of select="$year"/>
				</sort-year>
			   <!-- CDL: date range -->
			   <iso-start-date xtf:meta="true" xtf:tokenize="no">
			      <xsl:value-of select="concat($year,':00:00')"/>
			   </iso-start-date>
			   <iso-end-date xtf:meta="true" xtf:tokenize="no">
			      <xsl:value-of select="concat($year,':00:00')"/>
			   </iso-end-date>
			</xsl:if>
		</xsl:if>
	   
	   
	   
		<!-- CDL: language -->	
		<xsl:if test="translate($controlField008-35-37,'|#','')">
			<language>
				<xsl:call-template name="meta-attributes"/>
				<xsl:value-of select="$controlField008-35-37"/>
			</language>
			<!--<xsl:call-template name="createFacetLanguage">
				<xsl:with-param name="label" select="'language'"/>
				<xsl:with-param name="string">
					<xsl:value-of select="translate($controlField008-35-37, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
				</xsl:with-param>
			</xsl:call-template>-->
		</xsl:if>
		<!-- CDL: format -->
		<xsl:if test="$typeOf008">
			<format>	
				<xsl:call-template name="meta-attributes"/>
				<xsl:value-of select="$typeOf008"/>
			</format>
			<!--<xsl:call-template name="createFacet">
				<xsl:with-param name="label" select="'format'"/>
				<xsl:with-param name="string">
					<xsl:value-of select="$typeOf008"/>
				</xsl:with-param>
				</xsl:call-template>-->
		</xsl:if>
		<!-- CDL: sysID -->
		<sysID>
		    <xsl:call-template name="meta-attributes"/>
			<xsl:value-of select="$sysID"/>
		</sysID>
		<!-- CDL: sort-sysid, for 'random' result ordering in relvyl -->
		<sort-sysid>
			<xsl:call-template name="meta-attributes"/>
			<xsl:attribute name="xtf:tokenize">
				<xsl:value-of select="'no'"/>
			</xsl:attribute>
			<xsl:value-of select="$sysID"/>
		</sort-sysid>	
		<!-- CDL: 050 -->
		<!-- Temporary, please remove -->
		<catAuthority>
		    <xsl:call-template name="meta-attributes"/>
			<xsl:if test="//marc:datafield[@tag=050]">
				<xsl:text>LOC </xsl:text>
			</xsl:if>
			<xsl:if test="//marc:datafield[@tag=060]">
				<xsl:text>NLM </xsl:text>
			</xsl:if>
			<xsl:if test="//marc:datafield[@tag=086]">
				<xsl:text>GVT Docs</xsl:text>
			</xsl:if>
		</catAuthority>
	</xsl:template>

	<xsl:template name="relatedIdentifierISSN">
		<xsl:for-each select="marc:subfield[@code='x']">
			<identifier-issn>
				<xsl:call-template name="meta-attributes"/>
				<xsl:value-of select="."/>
			</identifier-issn>
			<merge-id>
				<xsl:attribute name="xtf:meta" select="'true'"/>
				<xsl:attribute name="xtf:tokenize" select="'no'"/>
				<xsl:attribute name="xtf:index" select="'yes'"/>
				<xsl:value-of select="concat(., ' (ISSN)')"/>
			</merge-id>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="subjectGeographicZ">
		<subject-geographic>
			<xsl:call-template name="meta-attributes"/>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</subject-geographic>
		<!--<xsl:call-template name="createFacetAlpha">
			<xsl:with-param name="label" select="'subject-geographic'"/>
			<xsl:with-param name="string">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
			</xsl:with-param>
			</xsl:call-template>-->
	</xsl:template>
	
	<xsl:template name="subjectTemporalY">
		<subject-temporal>
			<xsl:call-template name="meta-attributes"/>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</subject-temporal>
		<!--<xsl:call-template name="createFacetAlpha">
			<xsl:with-param name="label" select="'subject-temporal'"/>
			<xsl:with-param name="string">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
				</xsl:call-template>
			</xsl:with-param>
			</xsl:call-template>-->
	</xsl:template>
	
	<xsl:template name="subjectTopic">
		<subject-topic>
			<xsl:call-template name="meta-attributes"/>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</subject-topic>
		<!--<xsl:call-template name="createFacetAlpha">
			<xsl:with-param name="label" select="'subject-topic'"/>
			<xsl:with-param name="string">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
				</xsl:call-template>
			</xsl:with-param>
			</xsl:call-template>-->
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Utility Templates                                                      -->
	<!-- ====================================================================== -->
		
	<!-- CDL: modified -->
	<xsl:template name="nameABCDN">
		<xsl:for-each select="marc:subfield[@code='a']">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='b']">
			<xsl:text> </xsl:text>
			<xsl:value-of select="."/>
		</xsl:for-each>
		<!-- added gk, but still doesn't account for pqst in 798 -->
		<xsl:if test="marc:subfield[@code='c'] or marc:subfield[@code='d'] or 
			          marc:subfield[@code='g'] or marc:subfield[@code='k'] or 
			          marc:subfield[@code='n']">
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">cdgkn</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- CDL: modified -->
	<xsl:template name="nameABCDQ">
		<xsl:call-template name="chopPunctuation">
			<xsl:with-param name="chopString">
				<xsl:call-template name="subfieldSelect">
					<!-- added k -->
					<xsl:with-param name="codes">akq</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="punctuation">
				<xsl:text>:,;/ </xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="termsOfAddress"/>
		<xsl:call-template name="nameDate"/>
	</xsl:template>

	<!-- CDL: modified -->
	<xsl:template name="nameDate">
		<xsl:for-each select="marc:subfield[@code='d']">
			<xsl:text>, </xsl:text>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="subjectAuthority">
		<xsl:if test="number(@ind2)!=4">
			<xsl:if test="number(@ind2)!=8">
				<xsl:if test="number(@ind2)!=9">
					<xsl:choose>
						<xsl:when test="number(@ind2)=0">lcsh</xsl:when>
						<xsl:when test="number(@ind2)=1">lcshac</xsl:when>
						<xsl:when test="number(@ind2)=2">mesh</xsl:when>
						<xsl:when test="number(@ind2)=3">nal</xsl:when>
						<xsl:when test="number(@ind2)=5">csh</xsl:when>
						<xsl:when test="number(@ind2)=6">rvm</xsl:when>
						<xsl:when test="number(@ind2)=7">
							<xsl:value-of select="marc:subfield[@code='2']"/>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="subjectAnyOrder">
		<xsl:for-each select="marc:subfield[@code='a' or @code='v' or @code='x' or @code='y' or @code='z']">
			<xsl:choose>
				<xsl:when test="@code='a'">
					<xsl:call-template name="subjectTopic"/>
				</xsl:when>
				<xsl:when test="@code='v'">
					<xsl:call-template name="subjectTopic"/>
				</xsl:when>
				<xsl:when test="@code='x'">
					<xsl:call-template name="subjectTopic"/>
				</xsl:when>
				<xsl:when test="@code='y'">
					<xsl:call-template name="subjectTemporalY"/>
				</xsl:when>
				<xsl:when test="@code='z'">
					<xsl:call-template name="subjectGeographicZ"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="specialSubfieldSelect">
		<xsl:param name="anyCodes"/>
		<xsl:param name="axis"/>
		<xsl:param name="beforeCodes"/>
		<xsl:param name="afterCodes"/>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if test="contains($anyCodes, @code) or (contains($beforeCodes,@code) 
					          and following-sibling::marc:subfield[@code=$axis]) or (contains($afterCodes,@code) 
					          and preceding-sibling::marc:subfield[@code=$axis])">
					<xsl:value-of select="text()"/>
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
	</xsl:template>
	
	<!-- CDL: modified -->
	<xsl:template name="termsOfAddress">
		<xsl:if test="marc:subfield[@code='b' or @code='c']">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">bc</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="isoLanguage">
		<xsl:param name="currentLanguage"/>
		<xsl:param name="usedLanguages"/>
		<xsl:param name="remainingLanguages"/>
		<xsl:choose>
			<xsl:when test="string-length($currentLanguage)=0"/>
			<xsl:when test="not(contains($usedLanguages, $currentLanguage))">
				<xsl:value-of select="$currentLanguage"/>
				<xsl:call-template name="isoLanguage">
					<xsl:with-param name="currentLanguage">
						<xsl:value-of select="substring($remainingLanguages,1,3)"/>
					</xsl:with-param>
					<xsl:with-param name="usedLanguages">
						<xsl:value-of select="concat($usedLanguages,$currentLanguage)"/>
					</xsl:with-param>
					<xsl:with-param name="remainingLanguages">
						<xsl:value-of select="substring($remainingLanguages,4,string-length($remainingLanguages))"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="isoLanguage">
					<xsl:with-param name="currentLanguage">
						<xsl:value-of select="substring($remainingLanguages,1,3)"/>
					</xsl:with-param>
					<xsl:with-param name="usedLanguages">
						<xsl:value-of select="concat($usedLanguages,$currentLanguage)"/>
					</xsl:with-param>
					<xsl:with-param name="remainingLanguages">
						<xsl:value-of select="substring($remainingLanguages,4,string-length($remainingLanguages))"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="rfcLanguages">
		<xsl:param name="nodeNum"/>
		<xsl:param name="usedLanguages"/>
		<xsl:param name="controlField008-35-37"/>
		<xsl:variable name="currentLanguage" select="marc:subfield[position()=$nodeNum]/text()"/>
		<xsl:choose>
			<xsl:when test="not($currentLanguage)"/>
			<xsl:when test="$currentLanguage!=$controlField008-35-37 and $currentLanguage!='rfc3066'">
				<xsl:if test="not(contains($usedLanguages,$currentLanguage))">
					<xsl:value-of select="$currentLanguage"/>
				</xsl:if>
				<xsl:call-template name="rfcLanguages">
					<xsl:with-param name="nodeNum">
						<xsl:value-of select="$nodeNum+1"/>
					</xsl:with-param>
					<xsl:with-param name="usedLanguages">
						<xsl:value-of select="concat($usedLanguages,'|',$currentLanguage)"/>
					</xsl:with-param>
					<xsl:with-param name="controlField008-35-37">
						<xsl:value-of select="$controlField008-35-37"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="rfcLanguages">
					<xsl:with-param name="nodeNum">
						<xsl:value-of select="$nodeNum+1"/>
					</xsl:with-param>
					<xsl:with-param name="usedLanguages">
						<xsl:value-of select="concat($usedLanguages,$currentLanguage)"/>
					</xsl:with-param>
					<xsl:with-param name="controlField008-35-37">
						<xsl:value-of select="$controlField008-35-37"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="subfieldSelect">
		<xsl:param name="codes">abcdefghijklmnopqrstuvwxyz</xsl:param>
		<xsl:param name="delimeter">
			<xsl:text> </xsl:text>
		</xsl:param>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if test="contains($codes, @code)">
					<xsl:value-of select="text()"/>
					<xsl:value-of select="$delimeter"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($str,1,string-length($str)-string-length($delimeter))"/>
	</xsl:template>
	
	<xsl:template name="subjectSubfieldSelect">
		<xsl:param name="codes">abcdefghijklmnopqrstuvwxyz</xsl:param>
		<xsl:param name="subjectAuthority">lcsh</xsl:param>
		<xsl:param name="delimeter">
			<xsl:choose>
				<xsl:when test="$subjectAuthority = 'lcsh'">
					<xsl:text> -- </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if test="contains($codes, @code)">
					<xsl:value-of select="text()"/>
					<xsl:value-of select="$delimeter"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($str,1,string-length($str)-string-length($delimeter))"/>
	</xsl:template>
	
	<xsl:template name="createSubjectHierarchy">
		<xsl:param name="subject"/>
		<xsl:value-of select="replace($subject, ' -- ', '::')"/>
	</xsl:template>
	
	<xsl:template name="chopPunctuation">
		<xsl:param name="chopString"/>
		<xsl:param name="punctuation">
			<xsl:text>.:,;/ </xsl:text>
		</xsl:param>
		<xsl:variable name="length" select="string-length($chopString)"/>
		<xsl:choose>
			<xsl:when test="$length=0"/>
			<xsl:when test="contains($punctuation, substring($chopString,$length,1))">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="substring($chopString,1,$length - 1)"/>
					<xsl:with-param name="punctuation" select="$punctuation"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not($chopString)"/>
			<xsl:otherwise>
				<xsl:value-of select="$chopString"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="chopPunctuationFront">
		<xsl:param name="chopString"/>
		<xsl:variable name="length" select="string-length($chopString)"/>
		<xsl:choose>
			<xsl:when test="$length=0"/>
			<xsl:when test="contains('.:,;/[ ', substring($chopString,1,1))">
				<xsl:call-template name="chopPunctuationFront">
					<xsl:with-param name="chopString" select="substring($chopString,2,$length - 1)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not($chopString)"/>
			<xsl:otherwise>
				<xsl:value-of select="$chopString"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Meta Attributes Template                                               -->
	<!-- ====================================================================== -->
	
	<xsl:template name="meta-attributes">
		<xsl:attribute name="xtf:meta">
			<xsl:value-of select="'true'"/>
		</xsl:attribute>
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Facet Templates                                                     -->
	<!-- ====================================================================== -->
	
	<!-- generate callnum class facet fields -->
	<xsl:template name="createFacetCallnumClass"> 
		<xsl:param name="label"/>
		<xsl:param name="string"/>
		<xsl:variable name="name" select="concat('facet-', $label)"/>
	  <!-- get rid of spaces -->
	  <xsl:variable name="value" select="replace($string, ' ', '')"/>
	  <xsl:variable name="hierarchy">
	    <xsl:choose>
	      <xsl:when test="matches($value, '^[A-Z]+')">
	        <xsl:choose>
	          <xsl:when test="matches($value, '^[A-Z][A-Z][A-Z]')">
	            <xsl:analyze-string select="$value" regex="^([A-Z])([A-Z])([A-Z])">
	              <xsl:matching-substring>
	                <xsl:value-of select="regex-group(1)"/>
	                <xsl:text>::</xsl:text>
	                <xsl:value-of select="regex-group(1)"/>
	                <xsl:value-of select="regex-group(2)"/>
	                <xsl:text>::</xsl:text>
	                <xsl:value-of select="regex-group(1)"/>
	                <xsl:value-of select="regex-group(2)"/>
	                <xsl:value-of select="regex-group(3)"/>
	              </xsl:matching-substring>
	            </xsl:analyze-string>
	          </xsl:when>
	          <xsl:when test="matches($value, '^[A-Z][A-Z]')">
	            <xsl:analyze-string select="$value" regex="^([A-Z])([A-Z])">
	              <xsl:matching-substring>
	                <xsl:value-of select="regex-group(1)"/>
	                <xsl:text>::</xsl:text>
	                <xsl:value-of select="regex-group(1)"/>
	                <xsl:value-of select="regex-group(2)"/>
	              </xsl:matching-substring>
	            </xsl:analyze-string>
	          </xsl:when>
	          <xsl:when test="matches($value, '^[A-Z]')">
	            <xsl:analyze-string select="$value" regex="^([A-Z]+)">
	              <xsl:matching-substring>
	                <xsl:value-of select="regex-group(1)"/>
	              </xsl:matching-substring>
	            </xsl:analyze-string>
	          </xsl:when>
	        </xsl:choose>
	        <xsl:if test="matches($value, '^[A-Z]+[0-9]+')">
	          <xsl:analyze-string select="$value" regex="^([A-Z]+[0-9]+)">
	            <xsl:matching-substring>
	              <xsl:text>::</xsl:text>
	              <xsl:value-of select="regex-group(1)"/>
	            </xsl:matching-substring>
	          </xsl:analyze-string>
	        </xsl:if>
	      </xsl:when>
	      <xsl:otherwise>
	      	<xsl:text>other::</xsl:text>
	        <xsl:value-of select="$value"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>
	  <xsl:variable name="callnum" select="replace($hierarchy, '::$', '')"/>
		<xsl:element name="{$name}">
			<xsl:attribute name="xtf:meta">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:attribute name="xtf:facet">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:value-of select="$callnum"/>
		</xsl:element>
	</xsl:template>
		
	<!-- generate facet fields -->
	<xsl:template name="createFacet"> 
		<xsl:param name="label"/>
		<xsl:param name="string"/>
		<xsl:variable name="name" select="concat('facet-', $label)"/>
		<!-- Get rid of quotes -->
		<xsl:variable name="value" select="translate($string, '&quot;', '')"/>
		<xsl:element name="{$name}">
			<xsl:attribute name="xtf:meta">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:attribute name="xtf:facet">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="normalize-space($value) = ''">
					<xsl:value-of select="'empty'"/>
				</xsl:when>
				<xsl:otherwise>
			      <xsl:value-of select="$value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<!-- generate facet-*-* -->
	<xsl:template name="createFacetAlpha"> 
		<xsl:param name="label"/>
		<xsl:param name="string"/>
		<xsl:variable name="name" select="concat('facet-', $label)"/>
		<!-- Get rid of quotes -->
		<xsl:variable name="value" select="translate($string, '&quot;', '')"/>
		<xsl:element name="{$name}">
			<xsl:attribute name="xtf:meta">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:attribute name="xtf:facet">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="starts-with($value, 'A') or starts-with($value, 'a')">
					<xsl:value-of select="'A-C::A'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'B') or starts-with($value, 'b')">
					<xsl:value-of select="'A-C::B'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'C') or starts-with($value, 'c')">
					<xsl:value-of select="'A-C::C'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'D') or starts-with($value, 'd')">
					<xsl:value-of select="'D-F::D'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'E') or starts-with($value, 'e')">
					<xsl:value-of select="'D-F::E'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'F') or starts-with($value, 'f')">
					<xsl:value-of select="'D-F::F'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'G') or starts-with($value, 'g')">
					<xsl:value-of select="'G-I::G'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'H') or starts-with($value, 'h')">
					<xsl:value-of select="'G-I::H'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'I') or starts-with($value, 'i')">
					<xsl:value-of select="'G-I::I'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'J') or starts-with($value, 'j')">
					<xsl:value-of select="'J-L::J'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'K') or starts-with($value, 'k')">
					<xsl:value-of select="'J-L::K'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'L') or starts-with($value, 'l')">
					<xsl:value-of select="'J-L::L'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'M') or starts-with($value, 'm')">
					<xsl:value-of select="'M-O::M'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'N') or starts-with($value, 'n')">
					<xsl:value-of select="'M-O::N'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'O') or starts-with($value, 'o')">
					<xsl:value-of select="'M-O::O'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'P') or starts-with($value, 'p')">
					<xsl:value-of select="'P-R::P'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'Q') or starts-with($value, 'q')">
					<xsl:value-of select="'P-R::Q'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'R') or starts-with($value, 'r')">
					<xsl:value-of select="'P-R::R'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'S') or starts-with($value, 's')">
					<xsl:value-of select="'S-V::S'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'T') or starts-with($value, 't')">
					<xsl:value-of select="'S-V::T'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'U') or starts-with($value, 'u')">
					<xsl:value-of select="'S-V::U'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'V') or starts-with($value, 'v')">
					<xsl:value-of select="'S-V::V'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'W') or starts-with($value, 'w')">
					<xsl:value-of select="'W-Z::W'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'X') or starts-with($value, 'x')">
					<xsl:value-of select="'W-Z::X'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'Y') or starts-with($value, 'y')">
					<xsl:value-of select="'W-Z::Y'"/>
				</xsl:when>
				<xsl:when test="starts-with($value, 'Z') or starts-with($value, 'z')">
					<xsl:value-of select="'W-Z::Z'"/>
				</xsl:when>
				<xsl:when test="normalize-space($value) = ''">
					<xsl:value-of select="'empty'"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- to catch diacritics and unusal creators -->
					<xsl:value-of select="'other'"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="($label=publisher or $label='subject-geographic' or 
				$label='subject-temporal' or $label='subject-topic') and (normalize-space($value) != '')">
				<xsl:text>::</xsl:text>
				<xsl:value-of select="$value"/>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
    <!-- generate facet-title-* -->
	<xsl:template name="createFacetTitle"> 
		<xsl:param name="label"/>
		<xsl:param name="string"/>
		<xsl:variable name="name" select="concat('facet-', $label)"/>
		<!-- Get rid of quotes -->
		<xsl:variable name="title" select="translate($string, '&quot;', '')"/>
		<xsl:element name="{$name}">
			<xsl:attribute name="xtf:meta">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:attribute name="xtf:facet">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:choose>
				<!-- for numeric titles -->
				<xsl:when test="starts-with(parse:title($title), '0')">
					<xsl:value-of select="'0-9::0'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), '1')">
					<xsl:value-of select="'0-9::1'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), '2')">
					<xsl:value-of select="'0-9::2'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), '3')">
					<xsl:value-of select="'0-9::3'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), '4')">
					<xsl:value-of select="'0-9::4'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), '5')">
					<xsl:value-of select="'0-9::5'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), '6')">
					<xsl:value-of select="'0-9::6'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), '7')">
					<xsl:value-of select="'0-9::7'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), '8')">
					<xsl:value-of select="'0-9::8'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), '9')">
					<xsl:value-of select="'0-9::9'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'a')">
					<xsl:value-of select="'A-C::A'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'b')">
					<xsl:value-of select="'A-C::B'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'c')">
					<xsl:value-of select="'A-C::C'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'd')">
					<xsl:value-of select="'D-F::D'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'e')">
					<xsl:value-of select="'D-F::E'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'f')">
					<xsl:value-of select="'D-F::F'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'g')">
					<xsl:value-of select="'G-I::G'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'h')">
					<xsl:value-of select="'G-I::H'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'i')">
					<xsl:value-of select="'G-I::I'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'j')">
					<xsl:value-of select="'J-L::J'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'k')">
					<xsl:value-of select="'J-L::K'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'l')">
					<xsl:value-of select="'J-L::L'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'm')">
					<xsl:value-of select="'M-O::M'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'n')">
					<xsl:value-of select="'M-O::N'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'o')">
					<xsl:value-of select="'M-O::O'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'p')">
					<xsl:value-of select="'P-R::P'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'q')">
					<xsl:value-of select="'P-R::Q'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'r')">
					<xsl:value-of select="'P-R::R'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 's')">
					<xsl:value-of select="'S-V::S'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 't')">
					<xsl:value-of select="'S-V::T'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'u')">
					<xsl:value-of select="'S-V::U'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'v')">
					<xsl:value-of select="'S-V::V'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'w')">
					<xsl:value-of select="'W-Z::W'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'x')">
					<xsl:value-of select="'W-Z::X'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'y')">
					<xsl:value-of select="'W-Z::Y'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:title($title), 'z')">
					<xsl:value-of select="'W-Z::Z'"/>
				</xsl:when>
				<xsl:when test="normalize-space($title) = ''">
					<xsl:value-of select="'empty'"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- to catch diacritics and unusual titles -->
					<xsl:value-of select="'other'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<!-- generate facet-author-* -->
	<xsl:template name="createFacetAuthor"> 
		<xsl:param name="label"/>
		<xsl:param name="string"/>
		<xsl:variable name="name" select="concat('facet-', $label)"/>
		<!-- Get rid of quotes -->
		<xsl:variable name="author" select="translate($string, '&quot;', '')"/>
		<xsl:element name="{$name}">
			<xsl:attribute name="xtf:meta">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:attribute name="xtf:facet">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="starts-with(parse:name($author), 'A')">
					<xsl:value-of select="'A-C::A'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'B')">
					<xsl:value-of select="'A-C::B'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'C')">
					<xsl:value-of select="'A-C::C'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'D')">
					<xsl:value-of select="'D-F::D'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'E')">
					<xsl:value-of select="'D-F::E'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'F')">
					<xsl:value-of select="'D-F::F'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'G')">
					<xsl:value-of select="'G-I::G'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'H')">
					<xsl:value-of select="'G-I::H'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'I')">
					<xsl:value-of select="'G-I::I'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'J')">
					<xsl:value-of select="'J-L::J'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'K')">
					<xsl:value-of select="'J-L::K'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'L')">
					<xsl:value-of select="'J-L::L'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'M')">
					<xsl:value-of select="'M-O::M'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'N')">
					<xsl:value-of select="'M-O::N'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'O')">
					<xsl:value-of select="'M-O::O'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'P')">
					<xsl:value-of select="'P-R::P'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'Q')">
					<xsl:value-of select="'P-R::Q'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'R')">
					<xsl:value-of select="'P-R::R'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'S')">
					<xsl:value-of select="'S-V::S'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'T')">
					<xsl:value-of select="'S-V::T'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'U')">
					<xsl:value-of select="'S-V::U'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'V')">
					<xsl:value-of select="'S-V::V'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'W')">
					<xsl:value-of select="'W-Z::W'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'X')">
					<xsl:value-of select="'W-Z::X'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'Y')">
					<xsl:value-of select="'W-Z::Y'"/>
				</xsl:when>
				<xsl:when test="starts-with(parse:name($author), 'Z')">
					<xsl:value-of select="'W-Z::Z'"/>
				</xsl:when>
				<xsl:when test="normalize-space($author) = ''">
					<xsl:value-of select="'empty'"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- to catch diacritics and unusal creators -->
					<xsl:value-of select="'other'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
		
	<!-- generate subject facet fields -->
	<xsl:template name="createFacetSubject"> 
		<xsl:param name="label"/>
		<xsl:param name="string"/>
		<xsl:variable name="name" select="concat('facet-', $label)"/>
		<!-- Get rid of quotes -->
		<xsl:variable name="value" select="translate($string, '&quot;', '')"/>
		<xsl:variable name="subject">
			<xsl:value-of select="$value"/>
		</xsl:variable>
		<xsl:element name="{$name}">
			<xsl:attribute name="xtf:meta">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:attribute name="xtf:facet">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="starts-with($subject, 'A') or starts-with($subject, 'a')">
					<xsl:value-of select="'A-C::A'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'B') or starts-with($subject, 'b')">
					<xsl:value-of select="'A-C::B'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'C') or starts-with($subject, 'c')">
					<xsl:value-of select="'A-C::C'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'D') or starts-with($subject, 'd')">
					<xsl:value-of select="'D-F::D'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'E') or starts-with($subject, 'e')">
					<xsl:value-of select="'D-F::E'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'F') or starts-with($subject, 'f')">
					<xsl:value-of select="'D-F::F'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'G') or starts-with($subject, 'g')">
					<xsl:value-of select="'G-I::G'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'H') or starts-with($subject, 'h')">
					<xsl:value-of select="'G-I::H'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'I') or starts-with($subject, 'i')">
					<xsl:value-of select="'G-I::I'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'J') or starts-with($subject, 'j')">
					<xsl:value-of select="'J-L::J'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'K') or starts-with($subject, 'k')">
					<xsl:value-of select="'J-L::K'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'L') or starts-with($subject, 'l')">
					<xsl:value-of select="'J-L::L'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'M') or starts-with($subject, 'm')">
					<xsl:value-of select="'M-O::M'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'N') or starts-with($subject, 'n')">
					<xsl:value-of select="'M-O::N'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'O') or starts-with($subject, 'o')">
					<xsl:value-of select="'M-O::O'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'P') or starts-with($subject, 'p')">
					<xsl:value-of select="'P-R::P'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'Q') or starts-with($subject, 'q')">
					<xsl:value-of select="'P-R::Q'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'R') or starts-with($subject, 'r')">
					<xsl:value-of select="'P-R::R'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'S') or starts-with($subject, 's')">
					<xsl:value-of select="'S-V::S'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'T') or starts-with($subject, 't')">
					<xsl:value-of select="'S-V::T'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'U') or starts-with($subject, 'u')">
					<xsl:value-of select="'S-V::U'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'V') or starts-with($subject, 'v')">
					<xsl:value-of select="'S-V::V'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'W') or starts-with($subject, 'w')">
					<xsl:value-of select="'W-Z::W'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'X') or starts-with($subject, 'x')">
					<xsl:value-of select="'W-Z::X'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'Y') or starts-with($subject, 'y')">
					<xsl:value-of select="'W-Z::Y'"/>
				</xsl:when>
				<xsl:when test="starts-with($subject, 'Z') or starts-with($subject, 'z')">
					<xsl:value-of select="'W-Z::Z'"/>
				</xsl:when>
				<xsl:when test="normalize-space($subject) = ''">
					<xsl:value-of select="'empty'"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- to catch diacritics and unusal creators -->
					<xsl:value-of select="'other'"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="not(normalize-space($subject) = '')">
				<xsl:text>::</xsl:text>
				<xsl:value-of select="$subject"/>
			</xsl:if>
		</xsl:element>
	</xsl:template>
		
	<!-- generate subject facet fields -->
	<xsl:template name="createFacetLanguage"> 
		<xsl:param name="label"/>
		<xsl:param name="string"/>
		<xsl:variable name="name" select="concat('facet-', $label)"/>
		<!-- Get rid of quotes -->
		<xsl:variable name="value" select="translate($string, '&quot;', '')"/>
		<xsl:variable name="language">
			<xsl:value-of select="$value"/>
		</xsl:variable>
		<xsl:element name="{$name}">
			<xsl:attribute name="xtf:meta">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:attribute name="xtf:facet">
				<xsl:value-of select="'true'"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="starts-with($language, 'A') or starts-with($language, 'a')">
					<xsl:value-of select="'A-C::A'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'B') or starts-with($language, 'b')">
					<xsl:value-of select="'A-C::B'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'C') or starts-with($language, 'c')">
					<xsl:value-of select="'A-C::C'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'D') or starts-with($language, 'd')">
					<xsl:value-of select="'D-F::D'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'E') or starts-with($language, 'e')">
					<xsl:value-of select="'D-F::E'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'F') or starts-with($language, 'f')">
					<xsl:value-of select="'D-F::F'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'G') or starts-with($language, 'g')">
					<xsl:value-of select="'G-I::G'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'H') or starts-with($language, 'h')">
					<xsl:value-of select="'G-I::H'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'I') or starts-with($language, 'i')">
					<xsl:value-of select="'G-I::I'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'J') or starts-with($language, 'j')">
					<xsl:value-of select="'J-L::J'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'K') or starts-with($language, 'k')">
					<xsl:value-of select="'J-L::K'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'L') or starts-with($language, 'l')">
					<xsl:value-of select="'J-L::L'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'M') or starts-with($language, 'm')">
					<xsl:value-of select="'M-O::M'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'N') or starts-with($language, 'n')">
					<xsl:value-of select="'M-O::N'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'O') or starts-with($language, 'o')">
					<xsl:value-of select="'M-O::O'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'P') or starts-with($language, 'p')">
					<xsl:value-of select="'P-R::P'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'Q') or starts-with($language, 'q')">
					<xsl:value-of select="'P-R::Q'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'R') or starts-with($language, 'r')">
					<xsl:value-of select="'P-R::R'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'S') or starts-with($language, 's')">
					<xsl:value-of select="'S-V::S'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'T') or starts-with($language, 't')">
					<xsl:value-of select="'S-V::T'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'U') or starts-with($language, 'u')">
					<xsl:value-of select="'S-V::U'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'V') or starts-with($language, 'v')">
					<xsl:value-of select="'S-V::V'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'W') or starts-with($language, 'w')">
					<xsl:value-of select="'W-Z::W'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'X') or starts-with($language, 'x')">
					<xsl:value-of select="'W-Z::X'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'Y') or starts-with($language, 'y')">
					<xsl:value-of select="'W-Z::Y'"/>
				</xsl:when>
				<xsl:when test="starts-with($language, 'Z') or starts-with($language, 'z')">
					<xsl:value-of select="'W-Z::Z'"/>
				</xsl:when>
				<xsl:when test="normalize-space($language) = ''">
					<xsl:value-of select="'empty'"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- to catch diacritics and unusal creators -->
					<xsl:value-of select="'other'"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="not(normalize-space($language) = '')">
				<xsl:text>::</xsl:text>
				<xsl:value-of select="$language"/>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Deduping and Sorting                                                   -->
	<!-- ====================================================================== -->
		
	<xsl:template name="deDupe">
		
		<xsl:variable name="allFields">
		    <xsl:apply-templates/>
		</xsl:variable>
		
		<xsl:variable name="uniqueFields">
		    <xsl:apply-templates select="$allFields" mode="deDupe"/>
		</xsl:variable>
		
		<xtf:meta>
			<xsl:for-each select="$uniqueFields/*">
				<xsl:sort select="replace(replace(name(.),'^facet-',''),'^sort-','')"/>
				<xsl:element name="{name(.)}">
					<xsl:copy-of select="@*"/>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:for-each>
		</xtf:meta>
		
	</xsl:template>
	
	<xsl:template match="@*|node()" mode="deDupe">
		<xsl:if test="not(node()) or not(preceding-sibling::node()[.=string(current()) and name()=name(current())])">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="deDupe"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
<!-- ====================================================================== -->
<!-- Merge Title Parsing                                                    -->
<!-- ====================================================================== -->
	
	<!-- Function to parse normalized titles out of dc:title -->  
	<xsl:function name="parse:merge-title">
		
		<xsl:param name="title"/>
		
		<!-- Normalize Spaces & Case-->
		<xsl:variable name="parse-title">
			<xsl:value-of select="translate(normalize-space($title), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
		</xsl:variable>

		<!-- Remove Leading Articles -->
		<xsl:choose>
			<xsl:when test="matches($parse-title, '^a ')">
				<xsl:value-of select="replace($parse-title, '^a (.+)', '$1')"/>
			</xsl:when>
			<xsl:when test="matches($parse-title, '^an ')">
				<xsl:value-of select="replace($parse-title, '^an (.+)', '$1')"/>
			</xsl:when>
			<xsl:when test="matches($parse-title, '^the ')">
				<xsl:value-of select="replace($parse-title, '^the (.+)', '$1')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$parse-title"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>  
	
	<!-- ====================================================================== -->
	<!-- Testing                                                                -->
	<!-- ====================================================================== -->
	   
	<!-- Analysis Template -->
    <!--<xsl:template match="marc:datafield">
        <xsl:element name="{name(.)}-{@tag}">
		    <xsl:call-template name="meta-attributes"/>
            <xsl:for-each select="@*[not(name()='tag')]">
                <xsl:text>@</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text> | </xsl:text>
            </xsl:for-each>
            <xsl:for-each select="*">
                <xsl:value-of select="name()"/>
                <xsl:for-each select="@code">
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="."/>
                </xsl:for-each>
                <xsl:text> | </xsl:text>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>-->

</xsl:stylesheet>
