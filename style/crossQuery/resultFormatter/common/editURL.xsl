<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xtf="http://cdlib.org/xtf" 
   xmlns:editURL="http://cdlib.org/xtf/editURL"
   xmlns="http://www.w3.org/1999/xhtml"
   exclude-result-prefixes="#all"
   version="2.0">
   
   <!-- Query String -->
   <!-- grab url -->
   <!-- xsl:param name="http.URL"/ -->
   <!-- extract query string and clean it up -->
   <!-- xsl:param name="queryString" select="editURL:remove(replace($http.URL, '.+search\?|.+oai\?', ''),'startDoc')"/ -->
   
   <!-- ====================================================================== -->
   <!-- Utility functions for handy editing of URLs                           -->
   <!-- ====================================================================== -->
   
   <!-- Function to set the value of a URL parameter, replacing the old value 
        of that parameter if any.
   -->
   <xsl:function name="editURL:set">
      <xsl:param name="url"/>
      <xsl:param name="param"/>
      <xsl:param name="value"/>
      
      <xsl:variable name="cleanURL" select="editURL:clean($url)"/>
      <xsl:variable name="regex" select="concat('(^|;)', $param, '[^;]*(;|$)')"/>
      <xsl:variable name="regex2" select="concat(';', $param, '[^;]*(;|$)')"/>
      <xsl:choose>
         <xsl:when test="matches($cleanURL, $regex)">
	   <xsl:choose>
	   <xsl:when test="matches($cleanURL, $regex2)">
           	<xsl:value-of select="replace($cleanURL, $regex, concat(';', $param, '=', $value, ';'))"/>
	   </xsl:when>
	   <xsl:otherwise>
           	<xsl:value-of select="replace($cleanURL, $regex, concat($param, '=', $value, ';'))"/>
	   </xsl:otherwise>
	   </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="concat($cleanURL, ';', $param, '=', $value)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   
   <!-- Function to remove a URL parameter, if it exists in the URL -->
   <xsl:function name="editURL:remove">
      <xsl:param name="url"/>
      <xsl:param name="param"/>
      
      <xsl:variable name="regex" select="concat('(^|;)', $param, '[^;]*(;|$)')"/>
      <xsl:value-of select="editURL:clean(replace($url, $regex, ';'))"/>
   </xsl:function>
   
   <!-- Function to replace an empty URL (parameter?) with a value. If the URL isn't empty
        it is returned unchanged. By the way, certain parameters such as
        "expand" are still counted as empty.
   -->
   <xsl:function name="editURL:replaceEmpty">
      <xsl:param name="url"/>
      <xsl:param name="replacement"/>
      <xsl:choose>
         <xsl:when test="matches(editURL:clean($url), '^(expand=[^;]*)*$')">
            <xsl:value-of select="$replacement"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$url"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   
   <!-- Function to clean up a URL, removing leading and trailing ';' chars, etc. -->
   <xsl:function name="editURL:clean">
      <xsl:param name="v0"/>
      <!-- Change old ampersands to new easy-to-read semicolons -->
      <xsl:variable name="v1" select="replace($v0, '&amp;', ';')"/>
      <!-- Get rid of empty parameters -->
      <xsl:variable name="v2" select="replace($v1, '[^;=]+=(;|$)', '')"/>
      <!-- Replace ";;" with ";" -->
      <xsl:variable name="v3" select="replace($v2, ';;+', ';')"/>
      <!-- Get rid of leading and trailing ';' -->
      <xsl:variable name="v4" select="replace($v3, '^;|;$', '')"/>
      <!-- All done. -->
      <xsl:value-of select="$v4"/>
   </xsl:function>
   
   <!-- Function to calculate an unused name for the next facet parameter -->
   <xsl:function name="editURL:nextFacetParam">
      <xsl:param name="queryString"/>
      <xsl:param name="field"/>
      <xsl:variable name="nums">
         <num n="0"/>
         <xsl:analyze-string select="$queryString" regex="(^|;)f([0-9]+)-">
            <xsl:matching-substring><num n="{number(regex-group(2))}"/></xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:variable>
      <xsl:value-of select="concat('f', 1+max(($nums/*/@n)), '-', $field)"/>
   </xsl:function>

   <xsl:function name="editURL:toHidden">
      <xsl:param name="queryString"/>
      <xsl:for-each select="tokenize($queryString,';')">
	<input type="hidden" name="{substring-before(.,'=')}" value="{substring-after(.,'=')}"/>
      </xsl:for-each>
   </xsl:function>

</xsl:stylesheet>
