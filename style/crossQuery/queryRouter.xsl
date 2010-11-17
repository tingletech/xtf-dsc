<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Simple query routerr stylesheet                                        -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!--
  This stylesheet implements a simple switching mechanism, allowing one to
  set up multiple distinct crossQuery domains, each with its own query parser
  and associated stylesheets.
  
  As shipped, there is only a single domain, "default".
-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              exclude-result-prefixes="xsl">
  
  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>
   
<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->
  
  <xsl:param name="style"/>
  <xsl:param name="http.URL"/>
 
  <xsl:template match="/">

    <!-- This is the main output of the stylesheet -->
    <route>
      <xsl:choose>
        <xsl:when test="matches($http.URL,'oai\?')">
               <xsl:if test="matches($http.URL,'resumptionToken=http://')">
                  <xsl:variable name="newURL" select="replace(replace($http.URL,'.+resumptionToken=(.+)','$1'),'::',';resumptionToken=')"/>
                  <redirect:send url="{$newURL}" xmlns:redirect="java:/org.cdlib.xtf.saxonExt.Redirect" xsl:extension-element-prefixes="redirect"/>
               </xsl:if>
          <queryParser path="style/crossQuery/queryParser/oai/queryParser.xsl"/>
					<errorGen path="style/crossQuery/oaiErrorGen.xsl"/>
        </xsl:when>
        <xsl:when test="matches($style,'cui')">
          <queryParser path="style/crossQuery/queryParser/cui/queryParser.xsl"/>
        </xsl:when>
        <xsl:when test="matches($style,'melrec')">
          <queryParser path="style/crossQuery/queryParser/melrec/queryParser.xsl"/>
        </xsl:when>
        <xsl:when test="$style='attached'">
          <queryParser path="style/crossQuery/queryParser/oac4/queryParser.xsl"/>
        </xsl:when>
        <xsl:when test="$style='oac4g'">
          <queryParser path="style/crossQuery/queryParser/oac4/queryParser.xsl"/>
        </xsl:when>
        <xsl:when test="matches($style,'oac4') or $style='oac-img' or $style='oac-tei'">
          <queryParser path="style/crossQuery/queryParser/oac4/queryParser.xsl"/>
        </xsl:when>
        <xsl:when test="matches($style,'browse')">
          <queryParser path="style/crossQuery/queryParser/browsex/queryParser.xsl"/>
        </xsl:when>
        <xsl:when test="matches($style,'eqf|eschol|oac|erc')">
          <queryParser path="style/crossQuery/queryParser/old/queryParser.xsl"/>
        </xsl:when>
        <xsl:when test="matches($style,'default')">
          <queryParser path="style/crossQuery/queryParser/default/queryParser.xsl"/>
        </xsl:when>
        <xsl:otherwise>
          <queryParser path="style/crossQuery/queryParser/oac4/queryParser.xsl"/>
        </xsl:otherwise>
      </xsl:choose>   
    </route>
  </xsl:template>

</xsl:stylesheet>
<!--
   Copyright (c) 2007, Regents of the University of California
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
