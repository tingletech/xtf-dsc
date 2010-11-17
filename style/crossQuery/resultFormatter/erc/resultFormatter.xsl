<xsl:stylesheet version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

<!-- we don't want XML out -->
<xsl:output method="text" media-type="text/plain"/>

<!-- brief is the default level of record -->
<!-- need the '-ignore' in param names in crossQuery -->
<xsl:param name="level-ignore" select="'brief'"/>

<!-- put the record into a variable for shorter reference -->
<xsl:variable name="record" select="/crossQueryResult/docHit[1]/meta"/>

<!-- main template -->
<xsl:template match="crossQueryResult">
	<xsl:text>|set: cdlib.org | </xsl:text>
	<xsl:value-of select="replace(
			$record/identifier[1],
			'http://.*/ark:',
			'ark:')"
	/>
	<xsl:text> | temper
here: 1 | 1 | 1

erc:
</xsl:text>
	<xsl:call-template name="who"/>
	<xsl:call-template name="what"/>
	<xsl:call-template name="when"/>
	<xsl:call-template name="where"/>
	<xsl:if test="$level-ignore != 'brief'">
		<!-- put persist policy statment here -->
		<xsl:text>erc-support:
who:   cdlib.org
what:  (:tba) Commitment statement pending.
when:  20031219
where: http://www.cdlib.org/inside/diglib/ark/
</xsl:text>
	</xsl:if>
</xsl:template>

<!-- erc mappping -->

<xsl:template name="who">
<xsl:text>who: </xsl:text>
<xsl:call-template name="formater">
<xsl:with-param name="node" select="$record/creator | $record/contributor"/>
</xsl:call-template>
<!-- trailing return -->
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template name="what">
<xsl:text>what: </xsl:text>
<xsl:call-template name="formater">
<xsl:with-param name="node" select="$record/title[1]"/>
</xsl:call-template>
<!-- trailing return -->
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template name="when">
<xsl:text>when: </xsl:text>
<xsl:call-template name="formater">
<xsl:with-param name="node" select="$record/date"/>
</xsl:call-template>
<!-- trailing return -->
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template name="where">
<xsl:text>where: </xsl:text>
<xsl:call-template name="formater">
<xsl:with-param name="node" select="$record/identifier[1]"/>
</xsl:call-template>
<!-- trailing return -->
<xsl:text>
</xsl:text>
</xsl:template>

<!-- heavy lifting for formatting -->

<xsl:template name="formater">
  <xsl:param name="node"/>
  <xsl:variable name="unwrapped">
  <xsl:choose>
    <xsl:when test="$node">
	<!-- I could have multiple values -->
	<xsl:for-each select="$node">
	<!-- there could be empty elements -->
	<xsl:if test="text()">
	  <!-- seperate multiple values with pipes -->
	  <xsl:if test="position() &gt; 1">
		<xsl:text> | </xsl:text>
	  </xsl:if>
	</xsl:if>
	<!-- normalize-space will remove stray CRs -->
	<xsl:value-of select="normalize-space(.)"/>
	</xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
	<xsl:text>(:unav) unavailable</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  </xsl:variable>
  <xsl:call-template name="wraper">
    <xsl:with-param name="text" select="normalize-space($unwrapped)"/>
    <xsl:with-param name="sofar" select="number(4)"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="wraper">
  <xsl:param name="text"/>
  <xsl:param name="sofar"/>
  <xsl:variable name="thisWord" select="if (contains($text,' ')) then substring-before($text,' ') else $text"/>
  <xsl:variable name="newLeng" select="number($sofar) + string-length($thisWord)"/> 
  <xsl:value-of select="$thisWord"/><xsl:text> </xsl:text>
  <xsl:if test="$newLeng &gt; 62"><xsl:text>
	</xsl:text>
  </xsl:if>
  <xsl:if test="contains($text,' ')">
  <xsl:call-template name="wraper">
   <xsl:with-param name="text" select="substring-after($text,' ')"/>
   <xsl:with-param name="sofar" select="if ($newLeng &gt; 62) then number(0) else number($newLeng)"/>
  </xsl:call-template>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
