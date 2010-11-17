<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- BPG Stylesheet                                                         -->
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:import href="schematron.xsl"/>
  
  <xsl:output method="html" indent="yes" encoding="utf-8" media-type="text/html" doctype-public="-//W3C//DTD HTML 4.0//EN"/>
  
  <xsl:param name="docId"/>
  <xsl:param name="source"/>
  <xsl:param name="doc.view"/>
  <xsl:param name="anchor.id"/>
  <xsl:param name="result"/>
  <xsl:param name="doc.path" select="concat('view?', 'docId=', $docId, '&amp;source=', $source)"/>
  
  <xsl:variable name="check">
    <xsl:copy>
      <xsl:call-template name="errors"/>
    </xsl:copy>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="($doc.view='errors') and (not($check//comment()='error'))">
        <xsl:call-template name="pass"/>
      </xsl:when>
      <xsl:when test="$doc.view='errors'">
        <xsl:call-template name="errors"/>
      </xsl:when>
      <xsl:when test="$doc.view='document'">
        <xsl:call-template name="document"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="frames"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="frames">
    <html>
      <frameset rows="50%,50%">
        <frame title="Errors">
          <xsl:attribute name="name">errors</xsl:attribute>
          <xsl:attribute name="src">
            <xsl:value-of select="$doc.path"/>&#038;doc.view=errors</xsl:attribute>
        </frame>
        <frame title="document">
          <xsl:attribute name="name">document</xsl:attribute>
          <xsl:attribute name="src"><xsl:value-of select="$doc.path"/>&#038;doc.view=document</xsl:attribute>
        </frame>
      </frameset>
    </html>
  </xsl:template>
  
  <xsl:template name="pass">
    <html>
      <style> a:link { color: black} a:visited { color: gray} a:active { color: #FF0088} h3 {
        background-color:black; color:white; font-family:Arial Black; font-size:12pt; } h3.linked {
        background-color:black; color:white; font-family:Arial Black; font-size:12pt; } </style>
      <h2>
        <font color="#FF0080">Schematron</font> Report </h2>
      <p>Congratulations! Your document is free of best practice errors.</p>
      <hr color="#FF0080"/>
    </html>
  </xsl:template>
  
  <xsl:template name="document">
    <html>
      <div>
        <pre>
          <xsl:apply-templates mode="doc"/>
        </pre>
      </div>
    </html>
  </xsl:template>
  
  <xsl:template mode="doc" match="*[*]">
    <xsl:variable name="local.id">
      <xsl:value-of select="name()"/><xsl:text>-</xsl:text><xsl:number count="*" level="multiple"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$local.id=$anchor.id">
        <a name="X"/>
        <span style="color:red">
          <xsl:value-of select="concat('&lt;',name(.))"/>
          <xsl:apply-templates mode="doc" select="@*"/>
          <xsl:text>&gt;</xsl:text>
        </span>
        <xsl:apply-templates mode="doc"/>
        <xsl:value-of select="concat('&lt;/',name(.),'&gt;')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('&lt;',name(.))"/>
        <xsl:apply-templates mode="doc" select="@*"/>
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates mode="doc"/>
        <xsl:value-of select="concat('&lt;/',name(.),'&gt;')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="doc" match="*[text()][not(*)]|*[comment()][not(*)]|*[processing-instruction()][not(*)]">
    <xsl:variable name="local.id">
      <xsl:value-of select="name()"/><xsl:text>-</xsl:text><xsl:number count="*" level="multiple"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$local.id=$anchor.id">
        <a name="X"/>
        <span style="color:red">
          <xsl:value-of select="concat('&lt;',name(.))"/>
          <xsl:apply-templates mode="doc" select="@*"/>
          <xsl:text>&gt;</xsl:text>
          <xsl:apply-templates mode="doc"/>
          <xsl:value-of select="concat('&lt;/',name(.),'&gt;')"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('&lt;',name(.))"/>
        <xsl:apply-templates mode="doc" select="@*"/>
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates mode="doc"/>
        <xsl:value-of select="concat('&lt;/',name(.),'&gt;')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="doc" match="*">
    <xsl:variable name="local.id">
      <xsl:value-of select="name()"/><xsl:text>-</xsl:text><xsl:number count="*" level="multiple"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$local.id=$anchor.id">
        <a name="X"/>
        <span style="color:red">
          <xsl:value-of select="concat('&lt;',name(.))"/>
          <xsl:apply-templates mode="doc" select="@*"/>
          <xsl:text>/&gt;</xsl:text>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('&lt;',name(.))"/>
        <xsl:apply-templates mode="doc" select="@*"/>
        <xsl:text>/&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="doc" match="@*">
    <xsl:variable name="local.id">
      <xsl:value-of select="name()"/><xsl:text>-</xsl:text><xsl:number count="*" level="multiple"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$local.id=$anchor.id">
        <a name="X"/>
        <span style="color:red">
          <xsl:value-of select="concat(' ',name(.),'=')"/>
          <xsl:text>"</xsl:text>
          <xsl:call-template name="string-replace">
            <xsl:with-param name="from" select="'&quot;'"/>
            <xsl:with-param name="to" select="'&amp;quot;'"/>
            <xsl:with-param name="string" select="."/>
          </xsl:call-template>
          <xsl:text>"</xsl:text>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(' ',name(.),'=')"/>
        <xsl:text>"</xsl:text>
        <xsl:call-template name="string-replace">
          <xsl:with-param name="from" select="'&quot;'"/>
          <xsl:with-param name="to" select="'&amp;quot;'"/>
          <xsl:with-param name="string" select="."/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="doc" match="processing-instruction()">
    <xsl:variable name="local.id">
      <xsl:text>pi-</xsl:text><xsl:number count="*" level="multiple"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$local.id=$anchor.id">
        <a name="X"/>
        <span style="color:red">
          <xsl:value-of select="concat('&lt;?',name(.),' ',.,'?&gt;')"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('&lt;?',name(.),' ',.,'?&gt;')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="doc" match="comment()">
    <xsl:variable name="local.id">
      <xsl:text>comment-</xsl:text><xsl:number count="*" level="multiple"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$local.id=$anchor.id">
        <a name="X"/>
        <span style="color:red">
          <xsl:value-of select="concat('&lt;!--',.,'--&gt;')"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('&lt;!--',.,'--&gt;')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="doc" match="text()">
    <xsl:variable name="local.id">
      <xsl:text>text-</xsl:text><xsl:number count="*" level="multiple"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$local.id=$anchor.id">
        <a name="X"/>
        <span style="color:red">
          <xsl:call-template name="string-replace">
            <xsl:with-param name="to" select="'&amp;gt;'"/>
            <xsl:with-param name="from" select="'&gt;'"/>
            <xsl:with-param name="string">
              <xsl:call-template name="string-replace">
                <xsl:with-param name="to" select="'&amp;lt;'"/>
                <xsl:with-param name="from" select="'&lt;'"/>
                <xsl:with-param name="string">
                  <xsl:call-template name="string-replace">
                    <xsl:with-param name="to" select="'&amp;amp;'"/>
                    <xsl:with-param name="from" select="'&amp;'"/>
                    <xsl:with-param name="string" select="."/>
                  </xsl:call-template>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="string-replace">
          <xsl:with-param name="to" select="'&amp;gt;'"/>
          <xsl:with-param name="from" select="'&gt;'"/>
          <xsl:with-param name="string">
            <xsl:call-template name="string-replace">
              <xsl:with-param name="to" select="'&amp;lt;'"/>
              <xsl:with-param name="from" select="'&lt;'"/>
              <xsl:with-param name="string">
                <xsl:call-template name="string-replace">
                  <xsl:with-param name="to" select="'&amp;amp;'"/>
                  <xsl:with-param name="from" select="'&amp;'"/>
                  <xsl:with-param name="string" select="."/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="string-replace">
    <xsl:param name="string"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:choose>
      <xsl:when test="contains($string,$from)">
        <xsl:value-of select="substring-before($string,$from)"/>
        <xsl:value-of select="$to"/>
        <xsl:call-template name="string-replace">
          <xsl:with-param name="string" select="substring-after($string,$from)"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
