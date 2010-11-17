<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xtf="http://cdlib.org/xtf"
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns:mets="http://www.loc.gov/METS/" 
  xmlns:xlink="http://www.w3.org/TR/xlink" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:session="java:org.cdlib.xtf.xslt.Session"
  xmlns:sql="java:/org.cdlib.xtf.saxonExt.SQL"
  xmlns:frbr="http://www.cdlib.org/frbr"
  extension-element-prefixes="sql"
  exclude-result-prefixes="frbr">

  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->
  
  <xsl:import href="../common/cdlResultFormatterCommon.xsl"/>
  
  <!-- ====================================================================== -->
  <!-- Group Results Template                                                 -->
  <!-- ====================================================================== -->
  
  <xsl:template match="group" mode="frbr">
    <xsl:variable name="class" select="if(position() mod 2 = 0) then 'even' else 'odd'"/>
    <tr class="{$class}">
      <td valign="top">
        <xsl:value-of select="@rank"/>
        <xsl:text>. </xsl:text>
      </td>
      <td>
        <xsl:variable name="bestHit" select="frbr:selectBestHit(docHit)"/>
        <xsl:apply-templates select="docHit[position() = $bestHit]" mode="frbr-work"/>
        <xsl:apply-templates select="docHit[position() &lt; 2]" mode="frbr-item"/>
        <xsl:if test="count(docHit) &gt;= 2">
          <xsl:variable name="linkDivId" select="concat(@value, '-link')"/>
          <xsl:variable name="dataDivId" select="concat(@value, '-data')"/>
          <div id="{$dataDivId}" style="visibility:hidden; height:0">
            <xsl:apply-templates select="docHit[position() &gt; 1]" mode="frbr-item"/>
          </div>
          <div id="{$linkDivId}">
            <table class="assess-hit" border="0">
              <tr>
                <td>
                  <xsl:text>&#9654;</xsl:text>
                </td>
                <td width="300" align="right" valign="top">
                </td>
                <td>
                  <a>
                    <xsl:attribute name="href" select="'javascript://'"/>
                    <xsl:attribute name="onclick">
                      javascript:swapVis('<xsl:value-of select="$linkDivId"/>', '<xsl:value-of select="$dataDivId"/>')
                    </xsl:attribute>
                    Show remaining
                    <xsl:choose>
                      <xsl:when test="count(docHit) = 2">
                        item
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="count(docHit) - 1"/> items
                      </xsl:otherwise>
                    </xsl:choose>
                  </a>
                </td>
              </tr>
            </table>
          </div>
        </xsl:if>
      </td>
    </tr>    
  </xsl:template>
  
  <xsl:function name="frbr:selectBestHit">
    <xsl:param name="docHits"/>
    
    <!-- Get the title and author of each one -->
    <xsl:variable name="keys">
      <xsl:for-each select="$docHits">
        <key docNum="{position()}">
          <xsl:attribute name="value">
            <xsl:value-of select="if(meta/title-main) then meta/title-main[1] else meta/title-journal[1]"/>,
            <xsl:value-of select="if(meta/author) then meta/author[1] else meta/author-corporate[1]"/>
          </xsl:attribute>
          <xsl:value-of select="if(meta/title-main) then meta/title-main[1] else meta/title-journal[1]"/>,
          <xsl:value-of select="if(meta/author) then meta/author[1] else meta/author-corporate[1]"/>
        </key>
      </xsl:for-each>
    </xsl:variable>
    
    <!-- Group by key -->
    <xsl:variable name="grouped">
      <xsl:for-each-group select="$keys/key" group-by="@value">
        <xsl:sort select="count(current-group())" order="descending"/>
        <key docNum="{current-group()[1]/@docNum}" 
             value="{current-group()[1]/@value}" 
             groupSize="{count(current-group())}"/>
      </xsl:for-each-group>
    </xsl:variable>

    <!-- The key we want is the first one in the sort. -->
    <xsl:value-of select="$grouped/key[1]/@docNum"/>
  </xsl:function>
  
  <!-- ====================================================================== -->
  <!-- Document Hit Template (for the hit that represents a whole work)       -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit" mode="frbr-work">
    
    <xsl:variable name="rank" select="@rank"/>
    <xsl:variable name="resultString" select="replace($queryString,'&amp;rmode=[A-Za-z]+','')"/>
    <xsl:variable name="sysID" select="meta/sysID[1]"/>
    <xsl:variable name="quotedSysid" select="concat('&quot;', $sysID, '&quot;')"/>
    <xsl:variable name="numHits" select="count(parent::*/docHit)"/>
    
    <xsl:text>Title: </xsl:text>
    <xsl:choose>
      <xsl:when test="meta/title-main">
        <xsl:apply-templates select="meta/title-main[1]"/>
      </xsl:when>
      <xsl:when test="meta/title-journal">
        <xsl:apply-templates select="meta/title-journal[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[Untitled]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="meta/author or meta/meta/author-corporate">
     <xsl:text> , Author: </xsl:text>
      <xsl:choose>
        <xsl:when test="meta/author">
          <xsl:apply-templates select="meta/author[1]"/>
          <xsl:text>&#160;</xsl:text>
        </xsl:when>
        <xsl:when test="meta/author-corporate">
          <xsl:apply-templates select="meta/author-corporate[1]"/>
          <xsl:text>&#160;</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="$numHits"/>
    <xsl:choose>
      <xsl:when test="$numHits > 1">
        <xsl:text> Items)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> Item)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#160;</xsl:text>
    <a href="javascript://">
      <xsl:attribute name="onClick">
        <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$crossqueryPath"/><xsl:text>?style=</xsl:text><xsl:value-of select="$style"/><xsl:text>&amp;brand=</xsl:text><xsl:value-of select="$brand"/><xsl:text>&amp;rmode=pop-item','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
      </xsl:attribute>
      <img src="icons/melrec/help_icon.gif" alt="help" border="0"/>
    </a>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Document Hit Template (for hits within a work)                         -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit" mode="frbr-item">
    
    <xsl:variable name="rank" select="@rank"/>    
    <xsl:variable name="score" select="@score"/>
    <xsl:variable name="resultString" select="replace($queryString,'&amp;rmode=[A-Za-z]+','')"/>
    <xsl:variable name="sysID" select="meta/sysID[1]"/>
    <xsl:variable name="quotedSysid" select="concat('&quot;', $sysID, '&quot;')"/>
    
    <!--<li>-->
      <table class="assess-hit" border="0">
        <tr>
          <td>
            <xsl:choose>
              <xsl:when test="following-sibling::docHit or preceding-sibling::docHit">
                <xsl:text>&#9654;</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>&#160;</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </td>
          <td width="300" align="right" valign="top">
            <h2>Title: </h2>
          </td>
          <td>
            <a>
              <xsl:attribute name="href">
                <xsl:call-template name="crossquery.url">
                  <xsl:with-param name="sysID" select="meta/sysID"/>
                </xsl:call-template>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="meta/title-main">
                  <xsl:apply-templates select="meta/title-main[1]"/>
                </xsl:when>
                <xsl:when test="meta/title-journal">
                  <xsl:apply-templates select="meta/title-journal[1]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>[Untitled]</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </a>
          </td>
        </tr>
        <xsl:if test="meta/title-series">
          <tr>
            <td>&#160;</td>
            <td width="300" align="right" valign="top">
              <h2>Series: </h2>
            </td>
            <td>
              <xsl:apply-templates select="meta/title-series[1]"/>
            </td>
          </tr>
        </xsl:if>
        <xsl:if test="meta/author or meta/meta/author-corporate">
          <tr>
            <td>&#160;</td>
            <td width="300" align="right" valign="top">
              <h2>Author: </h2>
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="meta/author">
                  <xsl:apply-templates select="meta/author[1]"/>
                  <xsl:text>&#160;</xsl:text>
                </xsl:when>
                <xsl:when test="meta/author-corporate">
                  <xsl:apply-templates select="meta/author-corporate[1]"/>
                  <xsl:text>&#160;</xsl:text>
                </xsl:when>
              </xsl:choose>
            </td>
          </tr>
        </xsl:if>
        <tr>
          <td>&#160;</td>
          <td width="300" align="right" valign="top">
            <h2>Publisher, Place, Date: </h2>
          </td>
          <td>
            <xsl:if test="meta/publisher">
              <xsl:apply-templates select="meta/publisher[1]"/>
            </xsl:if>
            <xsl:if test="meta/place">
              <xsl:if test="meta/publisher">
                <xsl:text>, </xsl:text>
              </xsl:if>
              <xsl:apply-templates select="meta/pub-place[1]"/>
            </xsl:if>
            <xsl:if test="meta/year">
              <xsl:if test="meta/publisher or meta/place">
                <xsl:text>, </xsl:text>
              </xsl:if>
              <xsl:apply-templates select="meta/year[1]"/>
            </xsl:if>
          </td>
        </tr>
        <xsl:if test="meta/subject">
          <tr>
            <td>&#160;</td>
            <td width="300" align="right" valign="top">
              <h2>Subjects: </h2>
            </td>
            <td>
              <xsl:apply-templates select="meta/subject"/>
            </td>
          </tr>
        </xsl:if>
        <xsl:if test="meta/format">
          <tr>
            <td>&#160;</td>
            <td width="300" align="right" valign="top">
              <h2>Format: </h2>
            </td>
            <td>
              <xsl:choose>
                <xsl:when test="matches(meta/origin, 'ESR|OCA')">
                  <xsl:value-of select="'PDF'"/>
                </xsl:when>
                <xsl:when test="meta/origin = 'TEI'">
                  <xsl:value-of select="'TEI'"/>
                </xsl:when>
                <xsl:otherwise>
                  <span class="format">
                    <xsl:call-template name="map-format">
                      <xsl:with-param name="string" select="string(meta/format[1])"/>
                    </xsl:call-template>
                  </span>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
        </xsl:if>
        <xsl:if test="meta/callnum">
          <tr>
            <td>&#160;</td>
            <td width="300" align="right" valign="top">
              <h2>Call Number: </h2>
            </td>
            <td>
              <xsl:apply-templates select="meta/callnum[1]"/>
            </td>
          </tr>
        </xsl:if>
        <xsl:if test="contains($rmode, 'moreDetails')">
          <xsl:if test="meta/language">
            <tr>
              <td>&#160;</td>
              <td align="right" valign="top" nowrap="nowrap">
                <h2>Language: </h2>
              </td>
              <td>
                <xsl:for-each select="meta/language">
                  <xsl:if test="normalize-space(string(.)) != ''">
                    <xsl:call-template name="map-language">
                      <xsl:with-param name="string" select="string(.)"/>
                    </xsl:call-template>
                    <xsl:if test="position() != last()">
                      <xsl:text>, </xsl:text>
                    </xsl:if>
                  </xsl:if>
                </xsl:for-each>
              </td>
            </tr>
          </xsl:if>
          <xsl:if test="meta/note">
            <tr>
              <td>&#160;</td>
              <td align="right" valign="top" nowrap="nowrap">
                <h2>Note(s): </h2>
              </td>
              <td>
                <xsl:for-each select="meta/note">
                  <p><xsl:apply-templates/></p>
                </xsl:for-each>
              </td>
            </tr>
          </xsl:if>
          <xsl:if test="meta/identifier-isbn">
            <tr>
              <td>&#160;</td>
              <td align="right" valign="top" nowrap="nowrap">
                <h2>ISBN: </h2>
              </td>
              <td>
                <xsl:apply-templates select="meta/identifier-isbn[1]"/>
              </td>
            </tr>
          </xsl:if>
          <xsl:if test="meta/identifier-issn">
            <tr>
              <td>&#160;</td>
              <td align="right" valign="top" nowrap="nowrap">
                <h2>ISSN: </h2>
              </td>
              <td>
                <xsl:apply-templates select="meta/identifier-issn[1]"/>
              </td>
            </tr>
          </xsl:if>
        </xsl:if>
        
        <xsl:if test="snippet">          
          <tr>
            <td>&#160;</td>
            <td align="right" valign="top" nowrap="nowrap">
              <h2>Matches  (<xsl:value-of select="@totalHits"/>)</h2>
            </td>
            <td>
              <xsl:apply-templates select="snippet"/>
            </td>
          </tr>
        </xsl:if>
        
        <xsl:if test="contains($rmode,'analysis')">
          <tr>
            <td>&#160;</td>
            <td width="300" align="right" valign="top">
              <h2>Score: </h2>
            </td>
            <td>
              <xsl:value-of select="$score"/>
            </td>
          </tr>
        </xsl:if>
          
        <xsl:if test="explanation">
          <tr>
            <td>&#160;</td>
            <td width="300" align="right" valign="top">
              <h2>Explanation: </h2>
            </td>
            <td>
              <xsl:apply-templates select="explanation"/>
            </td>
          </tr>
        </xsl:if>
        
        <xsl:if test="session:isEnabled()">
          <tr>
            <td>&#160;</td>
            <td width="300" align="right" valign="top">
              <xsl:text>&#160;</xsl:text>
            </td>
            <td>
              <xsl:call-template name="bookBag">
                <xsl:with-param name="sysID" select="meta/sysID"/>
              </xsl:call-template>
            </td>
          </tr>
        </xsl:if>
        
      </table>
    <!--</li>-->
    
  </xsl:template>
      
</xsl:stylesheet>
