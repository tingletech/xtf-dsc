<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0"
>
  <xsl:output indent="no" method="text" encoding="UTF-8" media-type="application/json"/>
  <xsl:strip-space elements="*"/>
  <xsl:param name="callback"/>

  <xsl:template match="/">
    <!-- regex on callback parameter to sanitize user input -->
    <!-- http://www.w3.org/TR/xmlschema-2/ '\c' = the set of name characters, those ·match·ed by NameChar -->
    <xsl:if test="$callback">
      <xsl:value-of select="replace(replace($callback,'[^\c]',''),':','')"/>
      <xsl:text>(</xsl:text>
    </xsl:if>
    <xsl:text>{"api":{"version":"x-001","license":"All Rights Reserved; Unauthorized use is strictly prohibited; http://www.oac.cdlib.org/terms.html"},"objset_total":</xsl:text>
    <xsl:value-of select="//*[docHit]/@totalDocs"/>
    <xsl:text>,"objset_start":</xsl:text>
    <xsl:value-of select="//*[docHit]/@startDoc"/>
    <xsl:text>,"objset_end":</xsl:text>
    <xsl:value-of select="//*[docHit]/@endDoc"/>
    <xsl:text>,"objset":[</xsl:text>
    <xsl:apply-templates select="/crossQueryResult//docHit/meta" mode="x"/>
    <xsl:text>],}</xsl:text>
    <xsl:if test="$callback">
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="meta" mode="x">
      <!-- arbitrarily qualified dublin core 
           based on http://purl.org/dc/elements/1.1/, but designed before dcterms -->
    <xsl:text>
{"qdc":{</xsl:text>
      <xsl:variable name="result" select="."/>
      <xsl:for-each select="
        'title', 'creator', 'subject', 'description', 'publisher', 'contributor', 'date', 
        'type', 'format', 'identifier', 'source', 'language', 'relation', 'coverage', 'rights'" >
      <!-- xsl:for-each select="'title', 'creator', 'subject', 'description'"  -->
        <xsl:call-template name="dc-json-element">
          <xsl:with-param name="element-name" select="."/>
          <xsl:with-param name="result" select="$result"/>
        </xsl:call-template>
      </xsl:for-each>
    <xsl:text>
},"files":{</xsl:text>
    <xsl:if test="$result/thumbnail">
      <xsl:text>"thumbnail":</xsl:text>
      <xsl:apply-templates select="$result/thumbnail"/>
      <xsl:text></xsl:text>
    </xsl:if>
    <xsl:variable name="reference-count" select="count($result/reference-image)"/>
    <xsl:if test="$reference-count &gt; 0">
      <xsl:text>"reference":</xsl:text>
      <xsl:choose>
        <xsl:when test="$reference-count = 1">
          <xsl:apply-templates select="$result/reference-image"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>[</xsl:text>
          <xsl:apply-templates select="$result/reference-image"/>
          <xsl:text>],</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:text>},
},</xsl:text>
  </xsl:template>

  <xsl:template name="dc-json-element">
    <xsl:param name="element-name"/>
    <xsl:param name="result"/>
    <xsl:variable name="element-count" select="count($result/*[name()=$element-name][text()])"/>
    <xsl:if test="$element-count &gt; 0">
      <xsl:text>
"</xsl:text>
      <xsl:value-of select="$element-name"/>
      <xsl:text>":</xsl:text>
      <xsl:choose>
        <xsl:when test="$element-count = 1">
          <xsl:apply-templates select="$result/*[name()=$element-name][text()]" mode="dcel"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>[</xsl:text>
          <xsl:apply-templates select="$result/*[name()=$element-name][text()]" mode="dcel"/>
          <xsl:text>],</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[text()][not(@q)]" mode="dcel">
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="."/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>
  </xsl:template>

  <xsl:template match="*[text()][@q]" mode="dcel">
    <xsl:text>{"q":</xsl:text>
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="@q"/>
    </xsl:call-template>
    <xsl:text>,"v":</xsl:text>
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="."/>
    </xsl:call-template>
    <xsl:text>},</xsl:text>
  </xsl:template>
  
  <!-- ignore document text -->
  <xsl:template match="text()[preceding-sibling::node() or following-sibling::node()]"/>

  <!-- string -->
  <xsl:template match="text()">
    <xsl:call-template name="escape-string">
      <xsl:with-param name="s" select="."/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Main template for escaping strings; used by above template and for object-properties 
       Responsibilities: placed quotes around string, and chain up to next filter, escape-bs-string -->
  <xsl:template name="escape-string">
    <xsl:param name="s"/>
    <xsl:text>"</xsl:text>
    <xsl:call-template name="escape-bs-string">
      <xsl:with-param name="s" select="$s"/>
    </xsl:call-template>
    <xsl:text>"</xsl:text>
  </xsl:template>
  
  <!-- Escape the backslash (\) before everything else. -->
  <xsl:template name="escape-bs-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,'\')">
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'\'),'\\')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-bs-string">
          <xsl:with-param name="s" select="substring-after($s,'\')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Escape the double quote ("). -->
  <xsl:template name="escape-quot-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <xsl:when test="contains($s,'&quot;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&quot;'),'\&quot;')"/>
        </xsl:call-template>
        <xsl:call-template name="escape-quot-string">
          <xsl:with-param name="s" select="substring-after($s,'&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="$s"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Replace tab, line feed and/or carriage return by its matching escape code. Can't escape backslash
       or double quote here, because they don't replace characters (&#x0; becomes \t), but they prefix 
       characters (\ becomes \\). Besides, backslash should be seperate anyway, because it should be 
       processed first. This function can't do that. -->
  <xsl:template name="encode-string">
    <xsl:param name="s"/>
    <xsl:choose>
      <!-- tab -->
      <xsl:when test="contains($s,'&#x9;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#x9;'),'\t',substring-after($s,'&#x9;'))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- line feed -->
      <xsl:when test="contains($s,'&#xA;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#xA;'),'\n',substring-after($s,'&#xA;'))"/>
        </xsl:call-template>
      </xsl:when>
      <!-- carriage return -->
      <xsl:when test="contains($s,'&#xD;')">
        <xsl:call-template name="encode-string">
          <xsl:with-param name="s" select="concat(substring-before($s,'&#xD;'),'\r',substring-after($s,'&#xD;'))"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- number (no support for javascript mantissa) -->
  <xsl:template match="text()[not(string(number())='NaN' or
                       (starts-with(.,'0' ) and . != '0'))]">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- boolean, case-insensitive -->
  <xsl:template match="text()[translate(.,'TRUE','true')='true']">true</xsl:template>
  <xsl:template match="text()[translate(.,'FALSE','false')='false']">false</xsl:template>

  <xsl:template match="snippet|hit|term" mode="value dcel">
    <xsl:apply-templates mode="value"/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="thumbnail">
    <xsl:text>{"src":"</xsl:text>
    <xsl:apply-templates select="../identifier[1]" mode="value"/>
    <xsl:text>/thumbnail"</xsl:text>
    <xsl:if test="@X!='' and @Y!=''">
      <xsl:text>,"x":</xsl:text>
      <xsl:value-of select="@X"/>
      <xsl:text>,"y":</xsl:text>
      <xsl:value-of select="@Y"/>
    </xsl:if>
    <xsl:text>,},</xsl:text>
  </xsl:template>

  <xsl:template match="reference-image">
    <xsl:text>{"src":"</xsl:text>
    <xsl:apply-templates select="@src"/>
    <xsl:text>","x":</xsl:text>
    <xsl:value-of select="@X"/>
    <xsl:text>,"y":</xsl:text>
    <xsl:value-of select="@Y"/>
    <xsl:text>,},</xsl:text>
  </xsl:template>

</xsl:stylesheet>
