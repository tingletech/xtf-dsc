<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    
    <!-- ====================================================================== -->
    <!-- Group Results Template                                                 -->
    <!-- ====================================================================== -->
    
    <xsl:template match="group" mode="results">
        
        <xsl:variable name="modifyString" select="replace($queryString, '(smode=[A-Za-z0-9]*)', '$1-modify')"/>
        
        <html>
            <head>
                <title>Relvyl: Grouped Results</title>
            </head>
            <body id="results">
                <div align="center">
                    <table cellpadding="2" cellspacing="2" border="0" width="95%" style="border: double blue">
                        <tr>
                            <td colspan="2" valign="top" align="left">
                                <span class="heading">Results: </span>
                                <xsl:value-of select="@totalDocs"/>
                                <xsl:text> Item(s)</xsl:text>
                            </td>
                            <td align="center">
                                <table cellpadding="2" cellspacing="2" border="0" width="50%">
                                    <tr>
                                        <td align="center" valign="top">
                                            <xsl:call-template name="pages"/>Y
                                        </td>
                                        <td align="center" valign="top">
                                            <form  method="get" action="{$xtfURL}{$crossqueryPath}">
                                                <xsl:for-each select="parameters/param[not(matches(@name, 'maxRecords'))]">
                                                    <input type="hidden">
                                                        <xsl:attribute name="name">
                                                            <xsl:value-of select="@name"/>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="value">
                                                            <xsl:value-of select="@value"/>
                                                        </xsl:attribute>
                                                    </input>
                                                </xsl:for-each>
                                                <xsl:call-template name="sort.options"/>
                                                <input class="button" type="submit" value="Sort"/>
                                            </form>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td valign="top" align="center">
                                <xsl:text>Relevance</xsl:text>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" align="left">
                                <xsl:text>Query Time: </xsl:text>
                                <xsl:value-of select="@queryTime"/>
                            </td>
                            <td align="center">
                                <table cellpadding="2" cellspacing="2" border="0" width="50%">
                                    <tr>
                                        <td align="center">
                                            <xsl:text>Query: </xsl:text>
                                            <xsl:for-each select="parameters/param[not(matches(@name, 'brand|style|weight'))]">
                                                <xsl:value-of select="@name"/>
                                                <xsl:text>=</xsl:text>
                                                <xsl:value-of select="@value"/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </td>
                                        <td align="center">
                                            <a href="search?style=melrec&amp;brand=melrec&amp;rmode=viewGroups">Browse Metadata</a>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td align="center">
                                <xsl:text>(Boost: </xsl:text>
                                <xsl:value-of select="parameters/param[@name='weight']/@value"/>
                                <xsl:text>)</xsl:text>
                            </td>
                        </tr>
                        <xsl:choose>
                            <xsl:when test="facet/group/docHit">
                                <tr>
                                    <td colspan="4">
                                        <hr size="1"/>
                                    </td>
                                </tr>
                                <xsl:apply-templates select="facet/group/docHit"/>    
                            </xsl:when>
                            <xsl:when test="docHit">
                                <tr>
                                    <td colspan="4">
                                        <hr size="1"/>
                                    </td>
                                </tr>    
                                <xsl:apply-templates select="docHit"/>
                            </xsl:when>
                        </xsl:choose>
                    </table>
                </div>
            </body>
        </html>
    </xsl:template>
    
    <!-- ====================================================================== -->
    <!-- Metadata Browse                                                        -->
    <!-- ====================================================================== -->
    
    <xsl:template match="crossQueryResult" mode="viewGroups">
        <xsl:variable name="groupString" select="replace(replace($queryString, '[&amp;]*startGroup=[0-9]+', ''), '[&amp;]*group=[0-9A-Za-z\-\+:''%% ]+', '')"/>
        <xsl:variable name="sortString" select="replace($groupString, '[&amp;]*sortGroupsBy=[0-9A-Za-z\-\+''%% ]+', '')"/>
        
        <html>
            <head>
                <title>Relvyl: Metadata Browse</title>
            </head>
            <body id="metadata">
                <h2 align="center">Metadata Browse</h2>
                <table style="border: 1px solid black" width="100%" border="0" cellpadding="0" cellspacing="0">  
                    <tr>
                        <td align="center">
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=title-main&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">title-main</a>
                            <xsl:text> | </xsl:text>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=title-series&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">title-series</a>
                            <xsl:text> | </xsl:text>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=title-journal&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">title-journal</a>
                            <xsl:text> | </xsl:text>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=author&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">author</a>
                            <xsl:text> | </xsl:text>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=author-corporate&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">author-corporate</a>
                            <xsl:text> | </xsl:text>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=publisher&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">publisher</a>
                            <br/>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=language&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">language</a>
                            <xsl:text> | </xsl:text>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=subject&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">subject</a>
                            <xsl:text> | </xsl:text>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=subject-geographic&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">subject-geographic</a>
                            <xsl:text> | </xsl:text>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=subject-temporal&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">subject-temporal</a>
                            <xsl:text> | </xsl:text>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=subject-topic&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">subject-topic</a>
                            <xsl:text> | </xsl:text>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=format&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">format</a>
                            <xsl:text> | </xsl:text>
                            <a href="search?style=melrec&amp;brand=melrec&amp;facet=callnum-class&amp;location=LAGE&amp;rmode=viewGroups&amp;docsPerPage=0">callnum-class</a>
                        </td>
                    </tr>
                    <xsl:if test="$facet">
                        <xsl:variable name="missing">
                            <xsl:choose>
                                <xsl:when test="facet/group[@value='1 MISSING']">
                                    <xsl:value-of select="number(facet/group[@value='1 MISSING']/@totalDocs)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="number(0)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <tr>
                            <td align="center" style="border: solid black 1px">
                                <h4>facet: <xsl:value-of select="$facet"/></h4>
                                <p>(Present in <xsl:value-of select="number(facet/@totalDocs) - $missing"/> of <xsl:value-of select="@totalDocs"/> records.)</p>
                                <xsl:if test="$group">
                                    <h4>group: <xsl:value-of select="replace($group, '::', ' -- ')"/></h4>
                                </xsl:if>
                                <xsl:call-template name="page-summary">
                                    <xsl:with-param name="object-type">
                                        <xsl:choose>
                                            <xsl:when test="facet/group/group">
                                                <xsl:value-of select="'Sub-Groups'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'Groups'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:with-param>
                                    <xsl:with-param name="groups" select="'yes'"/>
                                </xsl:call-template>
                                <br/>
                                <xsl:choose>
                                    <xsl:when test="$sortGroupsBy='value'">
                                        <xsl:text>Sort by: </xsl:text>
                                        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortGroupsBy=totalDocs">count</a>
                                        <xsl:text> | alpha</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$sortGroupsBy='totalDocs'">
                                        <xsl:text>Sort by: </xsl:text>
                                        <xsl:text>count | </xsl:text>
                                        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortGroupsBy=value">alpha</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Sort by: </xsl:text>
                                        <a href="{$xtfURL}{$crossqueryPath}?{$sortString}&amp;sortGroupsBy=totalDocs">count</a>
                                        <xsl:text> | alpha</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <ol>
                                    <xsl:apply-templates select="facet/group" mode="browseGroups"/>
                                </ol>
                            </td>
                        </tr>
                    </xsl:if>
                </table>
            </body>
        </html>
        
    </xsl:template>
    
    <xsl:template match="group" mode="browseGroups">
        
        <xsl:variable name="facet" select="replace(replace(ancestor::facet/@field, 'facet-', ''), '-[0-9]+', '')"/>
        
        <xsl:variable name="value">
            <xsl:for-each select="ancestor::group">
                <xsl:value-of  select="replace(@value, '\+', '%2B')"/>
                <xsl:text>::</xsl:text>
            </xsl:for-each>
            <xsl:value-of select="replace(@value, '\+', '%2B')"/>
        </xsl:variable> 
        
        <xsl:variable name="parent">
            <xsl:value-of select="replace($value,'::[^:]+$','')"/>
        </xsl:variable>
        
        <xsl:variable name="rmode">
            <xsl:if test="@totalSubGroups > 0">
                <xsl:text>viewGroups</xsl:text>
            </xsl:if>
        </xsl:variable>
        
        <xsl:variable name="docs">
            <xsl:choose>
                <xsl:when test="@totalSubGroups > 0">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="20"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="parentRank" select="parent::group/@rank"/>
        <xsl:variable name="startParent" select="floor($parentRank div $groupsPerPage)+1"/>
        
        <xsl:if test="(position() = 1) and (number(@rank) > $groupsPerPage) and not(group)">
            <a name="X"/>
            <li style="list-style-type: none">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($xtfURL,$crossqueryPath,'?facet=',$facet,'&amp;group=',$parent,'&amp;location=LAGE&amp;style=melrec&amp;brand=melrec&amp;rmode=viewGroups','&amp;startGroup=')"/>
                        <xsl:value-of select="$startGroup - $groupsPerPage"/>
                        <xsl:value-of select="concat('&amp;startParent=',$startParent)"/>
                        <xsl:text>&amp;docsPerPage=0#X</xsl:text>
                    </xsl:attribute>
                    <xsl:text>&lt; &lt; &lt;</xsl:text>
                </a>
            </li>
        </xsl:if>
        
        <li value="{@rank}">
            <xsl:if test="position() = 1">
                <a name="X"/>
            </xsl:if>
            <a href="{$xtfURL}{$crossqueryPath}?facet={$facet}&amp;group={$value}&amp;location=LAGE&amp;style=melrec&amp;brand=melrec&amp;rmode={$rmode}&amp;docsPerPage={$docs}&amp;startParent={$startGroup}#X">
                <xsl:value-of select="@value"/>
            </a>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="@totalDocs"/>
            <xsl:text>) </xsl:text>
            <xsl:if test="group">
                <ol>
                    <xsl:apply-templates select="group" mode="browseGroups"/>
                </ol>
            </xsl:if>
        </li>
        
        <xsl:if test="(position() = last()) and (number(@rank) &lt; number(parent::group/@totalSubGroups)) and not(group)">
            <li style="list-style-type: none">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat($xtfURL,$crossqueryPath,'?facet=',$facet,'&amp;group=',$parent,'&amp;location=LAGE&amp;style=melrec&amp;brand=melrec&amp;rmode=viewGroups','&amp;startGroup=')"/>
                        <xsl:value-of select="$startGroup + $groupsPerPage"/>
                        <xsl:value-of select="concat('&amp;startParent=',$startParent)"/>
                        <xsl:text>&amp;docsPerPage=0#X</xsl:text>
                    </xsl:attribute>
                    <xsl:text>> > ></xsl:text>
                </a>
            </li>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>
