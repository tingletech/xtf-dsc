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

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:xs="http://www.w3.org/2001/XMLSchema">
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="../common/cdlResultFormatterCommon.xsl"/>
  
  <!-- ====================================================================== -->
  <!-- Output Parameters                                                      -->
  <!-- ====================================================================== -->

  <xsl:output method="html" indent="yes" encoding="UTF-8" media-type="text/html" 
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
              omit-xml-declaration="yes" />

  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->
  
<xsl:template match="/">
<html>
<body>
<xsl:apply-templates select="/crossQueryResult/facet"/>
</body>
</html>
</xsl:template> 

<xsl:template match="facet">
<div>
<div><u><b><xsl:value-of select="@field"/></b></u></div>
  <div><b>Total Groups:</b><xsl:text> </xsl:text><xsl:value-of select="@totalGroups"/></div>
  <div><b>Total Docs:</b><xsl:text> </xsl:text><xsl:value-of select="@totalDocs"/></div>
  <ol>
	<xsl:apply-templates/>
  </ol>
<hr/>
</div>
</xsl:template> 

<xsl:template match="group">
  <li><xsl:value-of select="@value"/> (<xsl:value-of select="@totalDocs"/>)</li>
	<xsl:if test="group">
		<ol>
		<xsl:apply-templates select="group"/>
		</ol>
	</xsl:if>
</xsl:template> 
  
</xsl:stylesheet>
