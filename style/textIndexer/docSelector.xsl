<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Index document selection stylesheet                                    -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
        xmlns:saxon="http://saxon.sf.net/"
        xmlns:xtf="http://cdlib.org/xtf"
        xmlns:mets="http://www.loc.gov/METS/"
        xmlns:date="http://exslt.org/dates-and-times"
        xmlns:mprofile="http://www.cdlib.org/mets/profiles"
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
  
<!--
    When the textIndexer tool encounters a directory filled with possible 
    files to index, it passes them to this stylesheet for evaluation. Our job
    here is to decide which of the files to index, and specify various
    parameters for those we do decide to index.

    Specifically, the stylesheet receives a document that looks like this:
      
    <directory dirPath="{path of the directory}">
        <file fileName="{file name #1}"/>
        <file fileName="{file name #2}"/>
        ...etc...
    </directory>
    
    The output of this stylesheet should be an XML document like this:
      
    <indexFiles>
        <indexFile dirPath="{path of the directory}"
                   fileName="{file name #1}"
                   type="{XML|PDF|HTML|...}"
                   preFilter="{path to input filter stylesheet}"
                   displayStyle="{path to display stylesheet}"/>
        <indexFile .../>
        ...etc...
    </indexFiles>

    Notes on the output tags:
      
      - If no files should be indexed, the output document should be empty.
      
      - All filesystem paths are relative to the XTF home directory.
      
      - The 'dirPath' and 'fileName' attributes are required
      
      - The other attributes ('type', 'preFilter' and 'displayStyle') are
        all optional.
        
      - If the 'type' attribute is not specified, the textIndexer will 
        attempt to deduce the file's format based on its file name extension.
        
      - If 'preFilter' isn't specified, no pre-filtering will be performed
        on the source document.
        
      - If 'displayStyle' isn't specified, no XSL keys will be pre-computed
        (see below for more info on displayStyle.)

    What is 'displayStyle' all about? Well, stylesheet processing can be 
    optimized by using XSLT 'keys', which are declared with an <xsl:key> tag.
    The first time a key is used in a given source document, it must be 
    calculated and its values stored on disk. The text indexer can optionally 
    pre-compute the keys so they need not be calculated later during the 
    display process. 
    
    The 'displayStyle' attribute simply specifies a stylesheet that the
    text indexer will look in to gather XSLT key definitions. Then it will
    pre-compute all of these keys for the document and store them on disk.
    
-->

<!-- bct extention function to tie into profile logic -->
   <!-- {http://www.cdlib.org/mets/profiles}:URItoDisplayXslt($URI) returns xslt file name -->
   <xsl:import href="../../mets-support/xslt/mets-profile.xsl"/>

<!-- ====================================================================== -->
<!-- Templates                                                              -->
<!-- ====================================================================== -->

  <!-- Create indexFiles Element -->  
  <xsl:template match="directory">
    <indexFiles>
      <xsl:apply-templates/>
    </indexFiles>
  </xsl:template>
  
  <!-- Create indexFile Element -->    
  <xsl:template match="file">    
<!-- xsl:message><xsl:copy-of select="."/></xsl:message -->
    <!-- File Type? -->
    <xsl:choose>
	  <xsl:when test="@fileName='cache_info.storable'"/>
	  <xsl:when test="@fileName='source.mets.xml'"/>
      <!-- .xml? -->
      <xsl:when test="ends-with(@fileName, '.xml')">
        <!-- is this the .mets.xml; and there is no .xml? -->
        <xsl:choose>
          <xsl:when test="ends-with(@fileName, '.mets.xml')">
            <!-- not sibling .xml? -->
            <xsl:variable name="xmlFile" select="replace(@fileName,'\.mets','')"/>
            <xsl:if test="not(parent::directory/file[@fileName = $xmlFile])">
              <xsl:call-template name="METS"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="ends-with(@fileName, '.mods3.xml')">
            <xsl:call-template name="MODS"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- not .dc.xml? -->
            <xsl:if test="not(ends-with(@fileName, '.dc.xml'))">
              <!-- sibling .dc.xml and .mets.xml? -->
              <xsl:choose>
                <xsl:when test="parent::directory/file[ends-with(@fileName, '.dc.xml')] and 
                                parent::directory/file[ends-with(@fileName, '.mets.xml')]">                      
                  <xsl:call-template name="XML"/>
                </xsl:when>
                <!-- Error -->
                <xsl:otherwise>
                  <xsl:message select="concat('WARNING: ', @fileName, ' does not have an associated .dc.xml or .mets.xml file')"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>     
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:when>
      <xsl:otherwise>
        <!-- .pdf? -->
        <xsl:choose>       
          <xsl:when test="ends-with(@fileName, '.pdf')">
            <xsl:call-template name="PDF"/>
          </xsl:when>
          <xsl:when test="ends-with(@fileName, '.marc')">
            <xsl:call-template name="MARC"/>
          </xsl:when>
          <xsl:when test="ends-with(@fileName, '.htm') or
                          ends-with(@fileName, '.html') or
                          ends-with(@fileName, '.xhtml')">
            <xsl:call-template name="HTML"/>
          </xsl:when>          
          <!-- Error -->
          <xsl:otherwise>
            <xsl:message select="concat('WARNING: Unknown filetype: ', @fileName)"/>
          </xsl:otherwise>
        </xsl:choose>       
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>   

  <!-- PDF -->
  <xsl:template name="PDF">
    <indexFile fileName="{@fileName}" type="PDF"/>
    <!--<xsl:message select="'Profile: PDF'"/>-->
  </xsl:template>
 
  <!-- HTML -->
  <xsl:template name="HTML">
    <indexFile fileName="{@fileName}" type="HTML"/>
    <!--<xsl:message select="'Profile: HTML'"/>-->
  </xsl:template>
      
  <!-- METS -->
  <xsl:template name="METS">
    
    <xsl:variable name="dirPath" select="parent::directory/@dirPath"/>
    <xsl:variable name="METS" select="document(concat($dirPath, @fileName))"/>
    <!-- Read METS PROFILE attribute -->
    <xsl:variable name="metsProfile" select="string($METS//mets:mets/@PROFILE)"/>
    <xsl:variable name="metsProfileXslt" select="mprofile:URItoDisplayXslt($metsProfile)"/>

    <xsl:choose>
	<!-- removed items Remove  -->
	<xsl:when test="$metsProfile = 'http://ark.cdlib.org/ark:/13030/kt4199q42g'">
          <indexFile fileName="{@fileName}" preFilter="style/textIndexer/mets/extimg/removeFilter.xsl" displayStyle="{$metsProfileXslt}"/>
        </xsl:when>

        <!-- lii records -->
	<xsl:when test="$metsProfile = ''">
          <indexFile fileName="{@fileName}" preFilter="style/textIndexer/mets-simple/preFilter.xsl" 
              type="XML"
              displayStyle="style/dynaXML/docFormatter/tei/oac/docFormatter.xsl"/>

        </xsl:when>

      <xsl:when test="$metsProfileXslt">

        <!-- Associate preFilter and docFormatter -->
          <indexFile fileName="{@fileName}" preFilter="style/textIndexer/mets/extimg/preFilter.xsl" displayStyle="{$metsProfileXslt}"/>
      </xsl:when>

	<xsl:when test="contains($metsProfileXslt,'kt3v19p5bk')">
        <xsl:message>WARNING: no XSLT fround for metsProfile <xsl:value-of select="$metsProfile"/> in <xsl:value-of select="@fileName"/>; should not be just a .mets.xml </xsl:message>
        </xsl:when>

      <xsl:otherwise>
        <xsl:message>WARNING: no XSLT fround for metsProfile <xsl:value-of select="$metsProfile"/> in <xsl:value-of select="@fileName"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <!-- MODS -->
  <xsl:template name="MODS">
    <indexFile fileName="{@fileName}" preFilter="style/textIndexer/mods/preFilter.xsl"/>
  </xsl:template>
  
  <!-- MARC -->

  <xsl:template name="MARC">
    <indexFile
                        fileName="{@fileName}"
                        type="MARC"
                        preFilter="style/marc/MARC21slim2XTFDC.xsl"
                        />
  </xsl:template>


  <!-- XML -->  
  <xsl:template name="XML">
    
    <xsl:variable name="dirPath" select="parent::directory/@dirPath"/>      
    <xsl:variable name="fileName" select="replace(@fileName,'\.xml','.mets.xml')"/>
    <xsl:variable name="METS" select="document(concat($dirPath, $fileName))"/>
    <!-- Read METS PROFILE attribute -->
    <xsl:variable name="metsProfile" select="string($METS//mets:mets/@PROFILE)"/>
    <xsl:variable name="metsProfileXslt" select="mprofile:URItoDisplayXslt($metsProfile)"/>
    
    <!-- Determine "Profile" -->
    <xsl:variable name="profile">
      <xsl:choose>
        <xsl:when test="contains($metsProfile, 'kt3v19p5bk') or
                        contains($metsProfile, 'kt5z09p6zn')">
          <xsl:value-of select="'tei-eschol'"/>
        </xsl:when>
        <xsl:when test="
			contains($metsProfile, 'kt5k40135s') or
			contains($metsProfile, '00000003.xml') or
			contains($metsProfile, '00000004.xml') or
			contains($metsProfile, '00000002.xml') or
                        contains($metsProfile, 'kt7j49p867')">
          <xsl:value-of select="'tei-oac'"/>
        </xsl:when>
        <xsl:when test="contains($metsProfile, 'kt0t1nb6x7')">
          <xsl:value-of select="'ead-oac'"/>
        </xsl:when>
        <xsl:when test="contains($metsProfile, 'UCBTextProfile')">
          <xsl:value-of select="'tei-oac'"/>
        </xsl:when>
        <xsl:when test="contains($metsProfile, 'kt4g5012g0') or
                        contains($metsProfile, 'kt400011f8')">
          <xsl:value-of select="'image-oac'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'tei-oac'"/>
        </xsl:otherwise>
      </xsl:choose>      
    </xsl:variable>       
    
    <!-- Associate preFilter and docFormatter -->
    <xsl:choose>
	<!-- removed items Remove  -->
	<xsl:when test="$metsProfile = 'http://ark.cdlib.org/ark:/13030/kt4199q42g'">
          <indexFile fileName="{@fileName}" preFilter="style/textIndexer/mets/extimg/removeFilter.xsl" displayStyle="{$metsProfileXslt}"/>
        </xsl:when>
      <xsl:when test="$profile = 'ead-oac'">
        <indexFile fileName="{@fileName}" 
          preFilter="style/textIndexer/ead/preFilter.xsl" 
          displayStyle="style/dynaXML/docFormatter/ead/oac/docFormatter.xsl"/>
        <!--<xsl:message select="'Profile: xml-ead-oac'"/>-->
      </xsl:when>
      <xsl:when test="$profile = 'tei-eschol'">
        <indexFile fileName="{@fileName}" 
          preFilter="style/textIndexer/tei/eschol/preFilter.xsl" 
          displayStyle="style/dynaXML/docFormatter/tei/eschol/docFormatter.xsl"/>
        <!--<xsl:message select="'Profile: xml-tei-eschol'"/>-->
      </xsl:when>
      <xsl:when test="$profile = 'tei-oac'">
        <indexFile fileName="{@fileName}" 
          preFilter="style/textIndexer/tei/oac/preFilter.xsl" 
          displayStyle="style/dynaXML/docFormatter/tei/oac/docFormatter.xsl"/>
        <!--<xsl:message select="'Profile: xml-tei-oac'"/>-->
      </xsl:when>
      <xsl:when test="$profile = 'image-oac'">
        <indexFile fileName="{@fileName}" 
          preFilter="style/textIndexer/mets/extimg/preFilter.xsl" 
          displayStyle="style/dynaXML/docFormatter/mets/extimg/docFormatter.xsl"/>
        <!--<xsl:message select="'Profile: xml-tei-oac'"/>-->
      </xsl:when>
      <xsl:otherwise>
        <indexFile fileName="{@fileName}" 
          preFilter="style/textIndexer/default/preFilter.xsl" 
          displayStyle="style/dynaXML/docFormatter/tei/oac/docFormatter.xsl"/>
        <!--<xsl:message select="'Profile: xml-default'"/>-->
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>

</xsl:stylesheet>
