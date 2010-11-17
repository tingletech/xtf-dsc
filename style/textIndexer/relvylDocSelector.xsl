<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Index document selection stylesheet                                    -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="2.0" 
  xmlns:date="http://exslt.org/dates-and-times" 
  xmlns:saxon="http://saxon.sf.net/" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xtf="http://cdlib.org/xtf" 
  exclude-result-prefixes="#all" 
  extension-element-prefixes="date">

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
        <indexFile fileName="{file name #1}"
                   type="{XML|PDF|HTML|...}"
                   preFilter="{path to input filter stylesheet}"
                   displayStyle="{path to display stylesheet}"/>
        <indexFile .../>
        ...etc...
    </indexFiles>

    Notes on the output tags:
      
      - If no files should be indexed, the output document should be empty.
      
      - If you use relative paths for the input filter or display style 
        attributes, they will be interpreted as being relative
        to XTF_HOME.
      
      - The 'fileName' attribute is required, and SHOULD NOT contain path
        information. Essentially, this should be one of the file names 
        from an input <file... /> tag.
      
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

  <!-- ====================================================================== -->
  <!-- Templates                                                              -->
  <!-- ====================================================================== -->

  <xsl:template match="directory">
    <indexFiles>
      <xsl:apply-templates/>
    </indexFiles>
  </xsl:template>

  <xsl:template match="file">
    <xsl:choose>
      <!-- .marc file? -> UCLA or BEREKELY MARC -->
      <xsl:when test="ends-with(@fileName, '.marc')">
        <indexFile fileName="{@fileName}" type="MARC" 
                   preFilter="style/textIndexer/relvyl/marc/preFilter.xsl"/>
      </xsl:when>
      <!-- .txt file? -->
      <xsl:when test="ends-with(@fileName, '.txt')">
        <xsl:choose>
          <!-- .djvu.txt file? -> OCA -->
          <xsl:when test="ends-with(@fileName, '_djvu.txt')">
            <indexFile fileName="{@fileName}" type="TEXT" 
                       preFilter="style/textIndexer/relvyl/txt/oca/preFilter.xsl"/>
          </xsl:when>
          <!-- .txt file? -> ESR -->
          <xsl:otherwise>
            <indexFile fileName="{@fileName}" type="TEXT" 
                       preFilter="style/textIndexer/relvyl/txt/esr/preFilter.xsl" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- .xml file? -->
      <xsl:when test="ends-with(@fileName, '.xml')">
        <xsl:choose>
          <!-- Not .dc.xml, .marc.xml, .meta.xml, .mets.xml? -->
          <xsl:when test="not(ends-with(@fileName, '.dc.xml')) and 
                          not(ends-with(@fileName, '.marc.xml')) and 
                          not(ends-with(@fileName, '.meta.xml')) and 
                          not(ends-with(@fileName, '.mets.xml'))">
            <!-- no .pdf present? -->
            <xsl:variable name="pdfFile" select="replace(@fileName,'\.xml','.pdf')"/>
            <xsl:if test="not(parent::directory/file[@fileName = $pdfFile])">
              <!-- mets PROFILE? -->
              <xsl:variable name="dirPath" select="parent::directory/@dirPath"/>      
              <xsl:variable name="fileName" select="replace(@fileName,'\.xml','.mets.xml')"/>
              <xsl:variable name="METS" select="document(concat($dirPath, $fileName))"/>
              <xsl:variable name="metsProfile" select="string($METS//*[local-name()='mets']/@PROFILE)"/>
              <!--<xsl:message select="$metsProfile"/>-->
              <xsl:choose>
                <!-- ESCHOL TEI -->
                <xsl:when test="contains($metsProfile, 'kt3v19p5bk') or contains($metsProfile, 'kt5z09p6zn')">
                  <indexFile fileName="{@fileName}" type="XML" 
                             preFilter="style/textIndexer/relvyl/tei/eschol/preFilter.xsl"/>
                </xsl:when>
                <!-- OAC TEI -->
                <xsl:when test="contains($metsProfile, 'kt5k40135s') or contains($metsProfile, 'kt7j49p867')">
                  <indexFile fileName="{@fileName}" type="XML" 
                             preFilter="style/textIndexer/relvyl/tei/oac/preFilter.xsl"/>
                </xsl:when>
              </xsl:choose>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
