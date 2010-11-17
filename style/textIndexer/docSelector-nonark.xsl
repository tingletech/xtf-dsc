<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns:xtf="http://cdlib.org/xtf"
		xmlns:mets="http://www.loc.gov/METS/"
		xmlns:date="http://exslt.org/dates-and-times"
		xmlns:mprofile="http://www.cdlib.org/mets/profiles"
		xmlns:local="http://www.example.org/local/"
		extension-element-prefixes="date"
		exclude-result-prefixes="#all">

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
  <xsl:function name="local:getProfileXsltTool">
    <xsl:param name="profile-id"/>
    <xsl:param name="tool-role"/>
    
    <xsl:variable name="which-driver"
		  select="($driver/mets-profile-driver[PROFILE=$profile-id], $default-driver)[1]"/>
    <xsl:value-of select="$which-driver/tool[@type='xslt' and @role=$tool-role]"/>
  </xsl:function>

  <xsl:variable name="default-driver">
    <PROFILE>default</PROFILE>
      <tool type="xslt" role="xtf:displayStyle">style/dynaXML/docFormatter/tei/oac/docFormatter.xsl</tool>
      <tool type="xslt" role="xtf:preFilter">style/textIndexer/mets-simple/preFilter.xsl</tool>
  </xsl:variable>

  <xsl:variable name="driver">
    <!--      move this someday -->
    <mets-profile-driver>
      <PROFILE>http://ark.cdlib.org/ark:/13030/kt3v19p5bk</PROFILE>
      <PROFILE>http://ark.cdlib.org/ark:/13030/kt5z09p6zn</PROFILE>
      <tool type="xslt" role="xtf:displayStyle">style/dynaXML/docFormatter/tei/eschol/docFormatter.xsl</tool>
      <tool type="xslt" role="xtf:preFilter">style/textIndexer/tei/eschol/preFilter.xsl</tool>
    </mets-profile-driver>
    <mets-profile-driver>
      <PROFILE>http://ark.cdlib.org/ark:/13030/kt3v19p5bk</PROFILE>
      <PROFILE>http://ark.cdlib.org/ark:/13030/kt5z09p6zn</PROFILE>
    </mets-profile-driver>
    <mets-profile-driver>
      <PROFILE>http://ark.cdlib.org/ark:/13030/kt5k40135s</PROFILE>
      <PROFILE>http://ark.cdlib.org/ark:/13030/kt7j49p867</PROFILE>
      <PROFILE>UCBTextProfile</PROFILE>
      <tool type="xslt" role="xtf:displayStyle">style/dynaXML/docFormatter/tei/oac/docFormatter.xsl</tool>
      <tool type="xslt" role="xtf:preFilter">style/textIndexer/tei/oac/preFilter.xsl</tool>
    </mets-profile-driver>
    <mets-profile-driver>
      <PROFILE>http://ark.cdlib.org/ark:/13030/kt0t1nb6x7</PROFILE>
      <tool type="xslt" role="xtf:displayStyle">style/textIndexer/ead/preFilter.xsl</tool>
      <tool type="xslt" role="xtf:preFilter">style/dynaXML/docFormatter/ead/oac/docFormatter.xsl</tool>
    </mets-profile-driver>
    <mets-profile-driver>
      <PROFILE>http://ark.cdlib.org/ark:/13030/kt4g5012g0</PROFILE>
      <PROFILE>http://ark.cdlib.org/ark:/13030/kt400011f8</PROFILE>
      <tool type="xslt" role="xtf:displayStyle">style/dynaXML/docFormatter/mets/extimg/docFormatter.xsl</tool>
      <tool type="xslt" role="xtf:preFilter">style/textIndexer/mets/extimg/preFilter.xsl</tool>
    </mets-profile-driver>
    <mets-profile-driver>
      <!-- oai style -->
      <PROFILE>http://ark.cdlib.org/ark:/13030/kt79nc95n</PROFILE>
      <tool type="xslt" role="xtf:displayStyle">style/dynaXML/docFormatter/tei/oac/docFormatter.xsl</tool>
      <tool type="xslt" role="xtf:preFilter">style/textIndexer/mets-simple/preFilter.xsl</tool>
    </mets-profile-driver>
  </xsl:variable>

  <!-- Create indexFiles Element -->  
  <xsl:template match="directory">
    <indexFiles>
      <xsl:apply-templates/>
    </indexFiles>
  </xsl:template>

  <!-- METS -->
  <xsl:template match="file[ends-with(@fileName, '.mets.xml') or ends-with(@fileName, '.mets.xml')]">
    <!-- Read METS PROFILE attribute -->
    <xsl:variable name="dirPath" select="parent::directory/@dirPath"/>
    <xsl:variable name="METS" select="document(concat($dirPath, @fileName))"/>
    <xsl:variable name="metsProfile" select="string($METS//mets:mets/@PROFILE)"/>
    
    <indexFile
	fileName="{@fileName}" 
	type="XML"
	preFilter="{local:getProfileXsltTool ($metsProfile, 'xtf:preFilter')}"
	displayStyle="{local:getProfileXsltTool ($metsProfile, 'xtf:displayStyle')}"/>
  </xsl:template>

	<!-- MARC -->
	<xsl:template match="file[ends-with(@fileName, '.marc')]">
    <indexFile 
			fileName="{@fileName}" 
			type="MARC"
			preFilter="style/marc/MARC21slim2XTFDC.xsl" 
			/>
  </xsl:template>
</xsl:stylesheet>
