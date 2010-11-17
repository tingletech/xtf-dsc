<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xtf="http://cdlib.org/xtf">

<!-- mapping structure -->

  <!-- General Keyword Mapping -->
  <xsl:template name="Browse">
    <xsl:param name="keywords"/>
    <xsl:param name="subject"/>
    <xsl:param name="mapDoc"/>
    <xsl:param name="elementNamePrefix"/>

    <!-- mapping structure -->
    <xsl:variable name="azMap" select="($mapDoc)//xtf:keyword-map[@type=$elementNamePrefix]"/>
    <xsl:variable name="azMapS" select="($mapDoc)//xtf:subject-map[@type=$elementNamePrefix]"/>

    <!-- lower-case -->
    <xsl:variable name="lcKeywords" select="lower-case(string($keywords))"/>

    <!-- Create list of groups -->
    <!-- works with 'or' operator -->
    <xsl:variable name="group">
      <xsl:if test="normalize-space($lcKeywords) != ''">
        <xsl:for-each select="$azMap//xtf:mapping/xtf:keyword | $azMap//xtf:mapping/xtf:join[@operator='or']/xtf:keyword">
          <xsl:if test="matches($lcKeywords, lower-case(string(.)))">
            <xsl:value-of select="string(ancestor::*[name()='xtf:mapping']//xtf:group)"/>
            <xsl:text>||</xsl:text>
          </xsl:if>
        </xsl:for-each>
    <!-- 'and' operator -->
        <xsl:for-each select="$azMap//xtf:mapping/xtf:join[@operator='and']">
          <xsl:if test="every $keyword in ./xtf:keyword satisfies contains($lcKeywords, lower-case(string($keyword/text())))">
            <xsl:value-of select="string(ancestor::*[name()='xtf:mapping']//xtf:group)"/>
            <xsl:text>||</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>

    <!-- Generate azBrowse -->
    <xsl:if test="normalize-space(replace($group, '\|+$', '')) != ''">
      <xsl:call-template name="parseAZGroups">
        <xsl:with-param name="groups" select="$group"/>
        <xsl:with-param name="elementNamePrefix" select="$elementNamePrefix"/>
      </xsl:call-template>
    </xsl:if>

  <xsl:apply-templates select="$subject" mode="Browse">
    <xsl:with-param name="azMapS" select="$azMapS"/>
    <xsl:with-param name="elementNamePrefix" select="$elementNamePrefix"/>
  </xsl:apply-templates>

  </xsl:template>

  <!-- Subject Mapping -->
  <xsl:template match="subject" mode="Browse">

    <xsl:param name="azMapS"/>
    <xsl:param name="elementNamePrefix"/>

    <xsl:variable name="subject" select="normalize-space(string(.))"/>
    <!-- lower-case, remove terminal period, normalize spaces around hyphens, and remove terminal semi-colon -->
    <xsl:variable name="azSubject" select="lower-case(replace(replace(replace(replace(replace($subject,'\.$',''),' +-','-'),'- +','-'),'; *$',''),', *$',''))"/>

    <!-- turn concatenated subject list into a regular expression -->
    <!-- escape all meta-characters -->
    <xsl:variable name="multiSubject" select="concat('^',replace(replace(replace(replace(replace(replace(replace(replace(replace($azSubject,'\.','\\.'),       '\?','\\?'),       '\-','\\-'),       '\[','\\['),       '\]','\\]'),       '\(','\\('),       '\)','\\)'),       ' *; *','\$|^'),       ' *\| *','\$|^'),       '$')"/>

    <!-- Create list of groups -->
    <xsl:variable name="group">
      <xsl:if test="normalize-space($azSubject) != ''">
        <xsl:choose>
          <xsl:when test="contains($multiSubject,'|')">
            <xsl:for-each select="$azMapS//xtf:mapping[matches(lower-case(normalize-space(xtf:subject/text())),$multiSubject)]/xtf:group">
              <xsl:value-of select="string(.)"/>
              <xsl:text>||</xsl:text>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="$azMapS//xtf:mapping[lower-case(normalize-space(xtf:subject/text()))=$azSubject]/xtf:group">
              <xsl:value-of select="string(.)"/>
              <xsl:text>||</xsl:text>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>


    <!-- Generate azBrowse -->
    <xsl:if test="normalize-space(replace($group, '\|+$', '')) != ''">
      <xsl:call-template name="parseAZGroups">
        <xsl:with-param name="groups" select="$group"/>
        <xsl:with-param name="elementNamePrefix" select="$elementNamePrefix"/>
      </xsl:call-template>
    </xsl:if>

  </xsl:template>

  <!-- Create ethbrowse and facet-ethBrowse for each group detected -->
  <xsl:template name="parseAZGroups">

    <xsl:param name="groups"/>
    <xsl:param name="elementNamePrefix"/>

    <xsl:variable name="before" select="substring-before($groups,'||')"/>
    <xsl:variable name="after" select="substring-after($groups,'||')"/>

    <xsl:element name="{$elementNamePrefix}">
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'yes'"/>
      <xsl:value-of select="$before"/>
    </xsl:element>

    <xsl:element name="facet-{$elementNamePrefix}">
      <xsl:attribute name="xtf:meta" select="'true'"/>
      <xsl:attribute name="xtf:tokenize" select="'no'"/>
      <xsl:value-of select="$before"/>
    </xsl:element>

    <xsl:if test="normalize-space($after) != ''">
      <xsl:call-template name="parseAZGroups">
        <xsl:with-param name="elementNamePrefix" select="$elementNamePrefix"/>
        <xsl:with-param name="groups" select="$after"/>
      </xsl:call-template>
    </xsl:if>

  </xsl:template>

</xsl:stylesheet>
