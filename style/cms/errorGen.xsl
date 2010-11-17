<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Error page generation stylesheet                                       -->
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

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/elements/1.1/">

<xsl:output method="html"
            indent="yes"
            encoding="utf-8"
            media-type="text/html"
            doctype-public="-//W3C//DTD HTML 4.0//EN"/>

<!-- =====================================================================
    
    When an error occurs (either authorization or an internal error),
    a stylesheet is used to produce a nicely formatted page for the
    requester. This tag specifies the path to the stylesheet, relative
    to the servlet base directory.

    The stylesheet receives one of the following mini-documents as input:

        <CMSParse>
            <message>error message from parser</message>
        </CMSParse>

    or

        <some general exception>
            <message>a descriptive error message (if any)</message>
            <stackTrace>HTML-formatted Java stack trace</stackTrace>
        </some general exception>

    For convenience, all of this information is also made available in XSLT
    parameters:

        $docId        Identifier of requested document

        $exception    Name of the exception that occurred - "InvalidDocument",
                      "NoPermission", or other names.

        $message      More descriptive details about what occurred

        $stackTrace   JAVA stack trace for non-standard exceptions.

======================================================================= -->


<!-- ====================================================================== -->
<!-- Parameters                                                             -->
<!-- ====================================================================== -->

<xsl:param name="exception"/>
<xsl:param name="message"/>
<xsl:param name="ipAddr" select="''"/>
<xsl:param name="stackTrace" select="''"/>

<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->

<!-- ======================================================================
    For this sample error generation stylesheet, we use the input mini-
    document instead of the parameters.
-->

<xsl:variable name="reason">
  <xsl:choose>
    <xsl:when test="//CMSParse">
      <xsl:text>CMS Error: Query Syntax Error</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>CMS Error: Servlet Error</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:template match="/">

  <html>
    <head>
      <title><xsl:value-of select="$reason"/></title>
      <link type="text/css" rel="stylesheet" href="http://texts.cdlib.org/dynaxml/css/eschol/content.css"/>
    </head>

    <body>

      <div class="content">
        <xsl:choose>
          <xsl:when test="CMSParse">
            <xsl:apply-templates/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="*">
              <xsl:call-template name="GeneralError"/>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>

      </div>

     </body>
  </html>

</xsl:template>


<!-- In the case of a CMSParse exception, the only relevant info is the message. -->
<xsl:template match="CMSParse">
  <h1>Query Syntax Error</h1>
  <p>Failed to parse the query.</p>
  <xsl:apply-templates/>
  <p>
	If you have questions, need further technical assistance, or believe that you have reached this page in error, please contact us via e-mail at
	<a href="{concat('mailto:oacops@cdlib.org?subject=Access%20denied%20-%20', encode-for-uri($reason))}">oacops@cdlib.org</a>.
	In your e-mail, include the text of any error messages that you may have received.
</p>
</xsl:template>


<!-- For all other exceptions, output all the information we can. -->
<xsl:template name="GeneralError">
  <h1>Servlet Error: <xsl:value-of select="name()"/></h1>
  <h3>An unexpected servlet error has occurred.</h3>
  <xsl:apply-templates/>
  <p>
	If you have questions, need further technical assistance, or believe that you have reached this page in error, please contact us via e-mail at
	<a href="{concat('mailto:oacops@cdlib.org?subject=Access%20denied%20-%20', encode-for-uri($reason))}">oacops@cdlib.org</a>.
	In your e-mail, include the text of any error messages that you may have received.
</p>
</xsl:template>


<!-- If a message was passed in, format it. -->
<xsl:template match="message">
  <p><b>Message:</b><br/><br/><span style="font-family: Courier"><xsl:apply-templates/></span></p>
</xsl:template>


<!-- If stack trace was specified, format it. Note that it already contains internal <br/> tags to separate lines. -->
<xsl:template match="stackTrace">
  <p><b>Stack Trace:</b><br/><br/><xsl:apply-templates/></p>
</xsl:template>


<!-- Pass <br> tags through untouched. -->
<xsl:template match="br">
    <br/>
</xsl:template>


</xsl:stylesheet>

