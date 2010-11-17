<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Query result formatter stylesheet                                      -->
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
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="../common/resultFormatterCommon.xsl"/>

  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->
    
 <xsl:template match="crossQueryResult" mode="browse">
   
   <xsl:variable name="keywordValue">
     <xsl:if test="$keyword-add">
       <xsl:value-of select="$keyword-add"/>
       <xsl:text> </xsl:text>
     </xsl:if>
     <xsl:if test="$keyword">
       <xsl:value-of select="$keyword"/>
     </xsl:if>
   </xsl:variable>
   
   <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
     <head>
       <title>Calisphere Search Results</title>
       <xsl:copy-of select="$brand.links"/>
     </head>
     <body>  
       <a class="jump-to-content" href="#content">Jump to Content</a>
       <xsl:comment>BEGIN PAGE ID</xsl:comment>
       <div id="results">
         <xsl:comment>BEGIN HEADER ROW</xsl:comment>
         <xsl:copy-of select="$brand.header"/>
         <xsl:comment>END HEADER ROW</xsl:comment>
         <xsl:comment>BEGIN DISPLAY RESULTS</xsl:comment>
         <div id="content" class="nifty1">
           <div class="box1">
             <ol>
               <xsl:apply-templates select="facet/group" mode="browse"/>
             </ol>
           </div>
         </div>
         <xsl:comment>END DISPLAY RESULTS</xsl:comment>
         <xsl:copy-of select="$brand.footer"/>
         <xsl:comment>END PAGE ID</xsl:comment>
       </div>
     </body>
   </html>
 </xsl:template>
  
  <xsl:template match="group" mode="browse">
    <xsl:variable name="browseURL" select="concat($xtfURL,$crossqueryPath,'?facet=type-tab&amp;style=cui&amp;',$facet,'=',@value,'&amp;',$facet,'-join=exact')"/>
    <li>
      <a href="/browse/{$facet}/{replace(@value,' ','+')}"><xsl:value-of select="@value"/></a> (<xsl:value-of select="@totalDocs"/>)
    </li>
    
  </xsl:template>
 
</xsl:stylesheet>
