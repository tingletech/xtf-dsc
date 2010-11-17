<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:fm="http://www.cdlib.org/frbrize"
    exclude-result-prefixes="#all">
    
  <xsl:output indent="yes"/>
  
  <!-- ====================================================================== -->
  <!-- For standalone testing of the FRBRize functionality (not used when     -->
  <!-- called from another stylesheet).                                        -->  
  <!-- ====================================================================== -->
  
  <xsl:template match="crossQueryResult">
    <xsl:copy>
      
      <!-- Copy everything except the doc hits -->
      <xsl:copy-of select="@*|*[name() != 'docHit']"/>
      
      <!-- Now FRBRize the doc hits -->
      <xsl:call-template name="frbrizeHits">
        <xsl:with-param name="docHits" select="docHits"/>
      </xsl:call-template>
      
    </xsl:copy>
  </xsl:template>

  
  <!-- ====================================================================== -->
  <!-- Template that creates a fake "frbr-work" facet for a sequence of       --> 
  <!-- docHits.                                                               -->  
  <!-- ====================================================================== -->
  
  <xsl:template name="frbrizeHits">
    <xsl:param name="docHits"/>
    <xsl:param name="maxWorks"/>
    
    <!-- Step 1: add author and title info to them -->
    <xsl:variable name="annotatedHits" select="fm:annotateHits(docHit)"></xsl:variable>
    
    <!-- Step 2: Group the hits into works -->
    <xsl:variable name="groupedHits">
      <xsl:for-each-group select="$annotatedHits" group-by="frbrWork">
        <!-- For now, sort by the rank of the first docHit in the group -->
        <xsl:sort select="frbrWork/docHit[1]/@rank"/>
        <frbrWork>
          <xsl:copy-of select="frbrWork/*"/>
          <xsl:for-each select="current-group()">
            <xsl:copy>
              <xsl:copy-of select="@*|meta|explanation|snippet"/>
            </xsl:copy>
          </xsl:for-each>
        </frbrWork>
      </xsl:for-each-group>
    </xsl:variable>
    
    <!-- Step 3: Generate the fake facet data -->
    <facet field="frbr-work" totalGroups="{count($groupedHits/frbrWork)}" totalDocs="{count(docHit)}">
      <xsl:for-each select="$groupedHits/frbrWork">
        <xsl:if test="position() &lt;= $maxWorks">
          <group value="{concat(string(frbrAuthor), ' | ', string(frbrTitle))}" rank="{position()}" totalSubGroups="0" totalDocs="{count(docHit)}" startDoc="1" endDoc="{count(docHit)}">
            <xsl:copy-of select="docHit"/>
          </group>
        </xsl:if>
      </xsl:for-each>
    </facet>
    
  </xsl:template>
    
  
  <!-- ====================================================================== -->
  <!-- Add frbrAuthor and frbrTitle elements to each docHit                   -->
  <!-- ====================================================================== -->
  
  <xsl:function name="fm:annotateHits">
    <xsl:param name="docHits"/>
    <xsl:for-each select="$docHits">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        
        <frbrWork>
          
          <!-- Pick the best author (if any) -->
          <xsl:choose>
            <xsl:when test="meta/author">
              <frbrAuthor>
                <xsl:value-of select="fm:normalize-author(string(meta/author[1]))"/>
              </frbrAuthor>
            </xsl:when>
            <xsl:when test="meta/author-corporate">
              <frbrAuthor>
                <xsl:value-of select="fm:normalize-author(string(meta/author-corporate[1]))"/>
              </frbrAuthor>
            </xsl:when>
          </xsl:choose>
          
          <!-- Pick the best title (if any) -->
          <xsl:choose>
            <xsl:when test="meta/title-main">
              <frbrTitle>
                <xsl:value-of select="fm:normalize-title(string(meta/title-main[1]))"/>
              </frbrTitle>
            </xsl:when>
            <xsl:when test="meta/title-journal">
              <frbrTitle>
                <xsl:value-of select="fm:normalize-title(string(meta/title-journal[1]))"/>
              </frbrTitle>
            </xsl:when>
            <xsl:when test="meta/title-series">
              <frbrTitle>
                <xsl:value-of select="fm:normalize-title(string(meta/title-series[1]))"/>
              </frbrTitle>
            </xsl:when>
          </xsl:choose>
          
        </frbrWork>
        
        <xsl:copy-of select="snippet"/>
        <xsl:copy-of select="explanation"/>
        <xsl:copy-of select="meta"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:function>
    
  
  <!-- ====================================================================== -->
  <!-- Function to normalize titles in various standard ways                  -->  
  <!-- ====================================================================== -->

  <xsl:function name="fm:normalize-title">
    <xsl:param name="title"/>
    
    <!-- Normalize Case -->
    <xsl:variable name="lower-title">
      <xsl:value-of select="normalize-space(translate($title, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))"/>
    </xsl:variable>
    
    <!-- Remove sub-titles -->
    <xsl:variable name="short-title">
      <xsl:value-of select="replace($lower-title, '[,:.;].*', '')"/>
    </xsl:variable>
    
    <!-- Remove Punctuation -->
    <xsl:variable name="parse-title">
      <xsl:value-of select="replace($short-title, '[^a-z0-9 ]', '')"/>
    </xsl:variable>
    
    <!-- Remove Leading Articles -->
    <!-- KVH: Eventually this should handle French, German, and Spanish articles as well -->
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
  <!-- Function to normalize author names                                     -->  
  <!-- ====================================================================== -->
  
  <xsl:function name="fm:normalize-author">
    <xsl:param name="author"/>
    
    <!-- Normalize Case -->
    <xsl:variable name="lower-author">
      <xsl:value-of select="normalize-space(translate($author, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))"/>
    </xsl:variable>
    
    <!-- Get rid of punctuation at end -->
    <xsl:variable name="nopunct-author">
      <xsl:value-of select="replace($lower-author, '[^a-zA-Z0-9]+$', '')"/>
    </xsl:variable>
    
    <!-- Get rid of dates at the end -->
    <xsl:variable name="nodate-author">
      <xsl:value-of select="replace($nopunct-author, ',\s?[0-9]+\s?(-\s?([0-9]+)?)?$', '')"/>
    </xsl:variable>
    
    <!-- Normalize space before comma -->
    <xsl:value-of select="replace($nodate-author, ' ,', ',')"/>
    
  </xsl:function>
  
</xsl:stylesheet>
