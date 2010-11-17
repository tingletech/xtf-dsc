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

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all">
  
  <!-- ====================================================================== -->
  <!-- Import Common Templates                                                -->
  <!-- ====================================================================== -->

  <xsl:import href="../../common/cdlResultFormatterCommon.xsl"/>
  
  <!-- ====================================================================== -->
  <!-- Output Parameters                                                      -->
  <!-- ====================================================================== -->

  <xsl:output method="html" indent="yes" encoding="UTF-8" media-type="text/html" 
              doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" 
              omit-xml-declaration="yes" />

  <!-- ====================================================================== -->
  <!-- Local Parameters                                                       -->
  <!-- ====================================================================== -->
  
  <!-- Removing port for CDL -->
  <xsl:param name="xtfURL" select="replace($root.path, ':[0-9]{4}/', '/')"/>
  <xsl:param name="css.path" select="concat($xtfURL, 'css/eschol/')"/>
  <xsl:param name="brand" select="'eschol'"/>
  
  <!-- ====================================================================== -->
  <!-- Root Template                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$smode = 'test'">
        <xsl:apply-templates select="crossQueryResult" mode="test"/>
      </xsl:when>
       <xsl:when test="$smode = 'denied'">
          <xsl:apply-templates select="crossQueryResult" mode="denied"/>
       </xsl:when>
      <xsl:when test="not(//docHit)">
        <xsl:apply-templates select="crossQueryResult" mode="form"/>
      </xsl:when>
      <xsl:when test="contains($smode, '-modify')">
        <xsl:apply-templates select="crossQueryResult" mode="form"/>
      </xsl:when>      
      <xsl:when test="
        $text or 
        $title or 
        $creator or 
        $subject or 
        $description or 
        $publisher or 
        $contributor or 
        $date or 
        $type or 
        $format or 
        $identifier or 
        $source or 
        $language or 
        $relation or 
        $coverage or 
        $rights or 
        $year or
        $keyword">
        <xsl:apply-templates select="crossQueryResult" mode="results"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="crossQueryResult" mode="form"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Results Template                                                       -->
  <!-- ====================================================================== -->

  <xsl:template match="crossQueryResult" mode="results">
    
    <xsl:variable name="modifyString" select="replace($queryString, '(smode=[A-Za-z0-9]*)', '$1-modify')"/>
    
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
      
      <head>
        <title>eScholarship Editions: Search Results</title>
        <xsl:copy-of select="$brand.links"/>
        <style type="text/css"> .center { text-align: center; } </style>
      </head>
      
      <body>
        
        <xsl:comment> BEGIN OUTER LAYOUT TABLE </xsl:comment>
        <table width="100%" border="0" cellpadding="0" cellspacing="0">        
          
          <xsl:copy-of select="$brand.header"/>

          <xsl:comment> BEGIN CONTENT ROW </xsl:comment>
          <tr>
            <td colspan="3" align="left" valign="top">
              <div class="content2">
                
                <xsl:comment> BEGIN SEARCH RESULTS </xsl:comment>
                <div class="search-results-outer">
                  
                  <div class="search-summary">
                    <xsl:text>Your </xsl:text>
                    <xsl:call-template name="searchOrBrowse"/>
                    <xsl:call-template name="format-query"/>
                    <xsl:text> found </xsl:text>
                    <xsl:value-of select="@totalDocs"/>
                    <xsl:text> books. </xsl:text>
                    <a class="top-link" href="{$xtfURL}{$crossqueryPath}?style={$style}&amp;brand={$brand}">
                      <xsl:text>New Search</xsl:text>
                    </a>
                    <a class="top-link" href="{$xtfURL}{$crossqueryPath}?{$modifyString}">
                      <xsl:text>Modify Search</xsl:text>
                    </a>                                       
                  </div>
                  
                  <xsl:if test="docHit">
                    <div class="number-items">
                      <xsl:call-template name="page-summary">
                        <xsl:with-param name="object-type" select="'books'"/>
                      </xsl:call-template>
                    </div>
                  </xsl:if>                  
                  <xsl:call-template name="searchBar"/>
                  
                  <xsl:if test="docHit">
                    <br clear="all"/>
                    <table class="search-results-table" border="0">
                      <xsl:choose>
                        <xsl:when test="contains($rmode, 'compact')">
                          <xsl:apply-templates select="docHit" mode="compact"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:apply-templates select="docHit"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </table>
                  </xsl:if>       
                  
                  <xsl:call-template name="searchBar"/>
                  
                </div>
                <xsl:comment> END SEARCH RESULTS </xsl:comment>
                
                <br/>
              </div>
            </td>
          </tr>         
          
          <xsl:comment> END CONTENT ROW </xsl:comment>
        
          <xsl:copy-of select="$brand.footer"/>     
        
        </table>
        <xsl:comment> END OUTER LAYOUT TABLE </xsl:comment>
        
      </body>
    </html>
    
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Form Template                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template match="crossQueryResult" mode="form">
    
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
      
      <head>
        <title>eScholarship Editions: Search Form</title>
        <xsl:copy-of select="$brand.links"/>
        <style type="text/css"> .center { text-align: center; } </style>
      </head>
      <body>
        
        <xsl:comment> BEGIN OUTER LAYOUT TABLE </xsl:comment>
        <table width="100%" border="0" cellpadding="0" cellspacing="0">        
          
          <xsl:copy-of select="$brand.header"/>
           
          <xsl:comment> BEGIN CONTENT ROW </xsl:comment>             
          <tr>
            <td colspan="3" align="left" valign="top">
              <div class="content2">
                
                <xsl:comment> BEGIN BASIC SEARCH </xsl:comment>
                <div class="search-outer">
                  <xsl:choose>
                    <xsl:when test="contains($smode, 'advanced')">                  
                      <span class="search-tabs-keyword-off">
                        <a class="keyword-off" href="{$xtfURL}{$crossqueryPath}?style={$style}&amp;brand={$brand}">Keyword Search</a>
                      </span>
                      <span class="search-tabs-adv-on">
                        <span class="adv-on">Advanced Search</span>
                      </span>
                    </xsl:when>
                    <xsl:otherwise>
                      <span class="search-tabs-keyword-on">
                        <span class="keyword-on">Keyword Search</span>
                      </span>
                      <span class="search-tabs-adv-off">
                        <a class="adv-off" href="{$xtfURL}{$crossqueryPath}?style={$style}&amp;brand={$brand}&amp;smode=advanced">Advanced Search</a>
                      </span>                        
                    </xsl:otherwise>
                  </xsl:choose>
                  <div class="search-inner">
                    <div class="search-topbar">Search books for:</div>
                    <div class="search-tips">
                      <a href="{$serverURL}escholarship/faq.html#srchoptions">search tips</a>
                    </div>    
                    <xsl:if test="
                      ($text or 
                      $title or 
                      $creator or 
                      $subject or 
                      $description or 
                      $publisher or 
                      $contributor or 
                      $date or 
                      $type or 
                      $format or 
                      $identifier or 
                      $source or 
                      $language or 
                      $relation or 
                      $coverage or 
                      $rights or 
                      $year or
                      $keyword) and not(docHit)">
                      <xsl:comment> NO RESULTS </xsl:comment>  
                      <div class="no-results">                             
                        <br/>
                        <xsl:text>Your search for </xsl:text>
                        <xsl:call-template name="format-query"/>
                        <xsl:text> found </xsl:text>
                        <xsl:value-of select="@totalDocs"/>
                        <xsl:text> books. </xsl:text>
                        <br/>
                        <xsl:call-template name="eschol-help"/>                   
                      </div>
                    </xsl:if>
                    <xsl:choose>
                      <xsl:when test="contains($smode, 'advanced')">
                        <form class="search-form" name="search-form" method="get" action="{$xtfURL}{$crossqueryPath}">
                          <div align="center">
                            <table class="search-query-table" border="0">
                              <tr class="search-row">
                                <td class="search-column-left">Search in Book Text: </td>
                                <td class="search-column-mid">
                                  <input name="text" type="text" size="30" maxlength="60" value="{$text}"/>
                                </td>
                                <td class="search-column-right" valign="top">
                                  <xsl:text>Find my words within </xsl:text>
                                  <select size="1" name="text-prox">
                                    <option value="">any</option>
                                    <xsl:call-template name="selectBuilder">
                                      <xsl:with-param name="selectType" select="'text-prox'"/>
                                      <xsl:with-param name="optionList" select="'1::2::3::4::5::10::20::'"/>
                                     <xsl:with-param name="count" select="1"/>
                                    </xsl:call-template>
                                  </select>
				  <xsl:text disable-output-escaping="yes"><![CDATA[<br />]]></xsl:text>
                                  <xsl:text> words of each other</xsl:text>
                                </td>
                              </tr>
                              <tr class="search-row">
                                <td class="search-column-left">Title: </td>
                                <td class="search-column-mid">
                                  <input name="title" type="text" size="30" maxlength="60" value="{$title}"/>
                                </td>
                                <td rowspan="6">&#160;</td>
                              </tr>
                              <tr class="search-row">
                                <td class="search-column-left">Author: </td>
                                <td class="search-column-mid">
                                  <input name="creator" type="text" size="30" maxlength="60" value="{$creator}"/>
                                </td>
                              </tr>
                              <tr class="search-row">
                                <td class="search-column-left">Subject: </td>
                                <td class="search-column-mid">
                                  <select size="1" name="subject">
                                    <option value="">All</option>
                                    <xsl:call-template name="selectBuilder">
                                      <xsl:with-param name="selectType" select="'subject'"/>
                                      <xsl:with-param name="optionList" select="'African American Studies::African History::African Studies::Aging::Agriculture::American Literature::American Music::American Studies::Ancient History::Animal Behavior::Animals::Anthropology::Archaeology::Architectural History::Architecture::Art::Art and Architecture::Art Criticism::Art History::Art Theory::Asian American Studies::Asian History::Asian Literature::Asian Studies::Astronomy::Autobiographies and Biographies::Autobiography::Biology::Botany::Buddhism::California and the West::Californian and Western History::Chemical oceanography::Chicano Studies::China::Christianity::Cinema and Performance Arts::Classical History::Classical Literature and Language::Classical Music::Classical Philosophy::Classical Politics::Classical Religions::Classics::Cognitive Science::Comparative Literature::Comparative Religions::Composers::Computer Science::Conservation::Consumerism::Contemporary Music::Criminology::Cultural Anthropology::Dance::Demography::Disease::Earth Sciences::East Asia Other::Ecology::Ecology, Evolution, Environment::Economics and Business::Education::Electronic Media::English Literature::Entomology::Environment::Environmental Studies::Ethics::Ethnic Studies::Ethnomusicology::European History::European Literature::European Studies::Evolution::Fiction::Film::Folklore and Mythology::Food and Cooking::French Studies::Gardening::Gay, Lesbian and Bisexual Studies::Gender Studies::Geography::Geology::German Studies::Global Studies::Health Care::Herpetology::Hinduism::Historiography::History::History and Philosophy of Science::History of Food::History of Medicine::History of Science::Ichthyology::Immigration::Indigenous Religions::Intellectual History::International Relations::Islam::Islands of the Pacific::Japan::Jazz::Jewish Studies::Judaism::Labor Studies::Landscape Architecture::Language and Linguistics::Latin American History::Latin American Studies::Latino Studies::Law::Letters::Library Science::Linguistic Theory::Literary Theory and Criticism::Literature::Literature in Translation::Mammalogy::Marine and Freshwater Sciences::Marine biology::Marine meteorology::Mathematics::Media Studies::Medical Anthropology::Medicine::Medieval History::Medieval Studies::Men and Masculinity::Middle Eastern History::Middle Eastern Studies::Military History::Music::Musicology::Native American Ethnicity::Native American Studies::Natural History::Neuroscience::Oceanography::Opera::Organismal Biology::Ornithology::Pacific Rim Studies::Paleontology::Philosophy::Photography::Physical Anthropology::Physical Sciences::Physics::Plants::Poetry::Political Theory::Politics::Popular Culture::Popular Music::Postcolonial Studies::Print Media::Psychiatry::Psychology::Public Policy::Publishing::Reference::Religion::Renaissance History::Renaissance Literature::Research::Rhetoric::Russian and Eastern European Studies::Science::Social and Political Thought::Social Problems::Social Science::Social Theory::Sociology::South Asia::Southeast Asia::Sports::Taoism::Technology::Technology and Instruments::Technology and Society::Television and Radio::Theatre::Tibet::Travel::Twain::United States History::Urban Studies::Victorian History::Viticulture::Water::Wine::Wine and Viticulture::Womens Studies::Writing::Zoology::'"/>
                                      <xsl:with-param name="count" select="1"/>
                                    </xsl:call-template>
                                  </select>
                                </td>
                              </tr>
                              <tr class="search-row">
                                <td class="search-column-left">Publisher: </td>
                                <td class="search-column-mid">
                                  <select name="relation">
                                    <xsl:choose>
                                      <xsl:when test="$relation = 'www.ucpress.edu'">
                                        <option value="escholarship.cdlib.org">All</option>
                                        <option value="www.ucpress.edu" selected="yes">UC Press</option>
                                        <!--<option value="scilib.ucsd.edu">Scripps Institution of Oceanography</option>-->
                                      </xsl:when>
                                      <!--<xsl:when test="$relation = 'scilib.ucsd.edu'">
                                      <option value="escholarship.cdlib.org">All</option>
                                      <option value="www.ucpress.edu">UC Press</option>
                                      <option value="scilib.ucsd.edu" selected="yes">Scripps Institution of Oceanography</option>
                                      </xsl:when>-->
                                      <xsl:otherwise>
                                        <option value="escholarship.cdlib.org" selected="yes">All</option>
                                        <option value="www.ucpress.edu">University of California Press</option>
                                        <!--<option value="scilib.ucsd.edu">Scripps Institution of Oceanography</option>-->
                                      </xsl:otherwise>
                                    </xsl:choose>
                                  </select>     
                                </td>
                              </tr>
                              <tr class="search-row">
                                <td class="search-column-left">Publisher's Description: </td>
                                <td class="search-column-mid">
                                  <input name="description" type="text" size="30" maxlength="60" value="{$description}"/>
                                </td>
                              </tr>
                              <tr class="search-row">
                                <td class="search-column-left">&#160;</td>
                                <td class="search-column-mid">
                                  <span class="exact-phrase">Exact phrase: "dissent in america"</span>
                                </td>
                              </tr>
                            </table>   
                          </div>
                          <div class="search-lower">
                            <div class="optional-limits">
                              <strong>Optional limits:</strong>
                              <div class="optional-limits2">
                                <p> 
                                  <xsl:text>From Publication Year: </xsl:text>
                                  <xsl:call-template name="date-select"/>
                                  <span class="submit-button">
                                    <input type="submit" value="Go!"/>       
                                  </span>
                                </p>
                                <p>
                                  <xsl:text>Show </xsl:text>
                                  <xsl:choose>
                                    <xsl:when test="$rights = 'Public'">
                                      <input type="radio" name="rights" value=""/>
                                      <xsl:text> all books</xsl:text>
                                      <input type="radio" name="rights" value="Public" checked="yes"/>
                                      <xsl:text> public access books</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <input type="radio" name="rights" value="" checked="yes"/>
                                      <xsl:text> all books</xsl:text> 
                                      <input type="radio" name="rights" value="Public"/>
                                      <xsl:text> public access books</xsl:text> 
                                    </xsl:otherwise>
                                  </xsl:choose>
                                  <xsl:text> &#160; [</xsl:text>
                                  <a href="{$serverURL}escholarship/faq.html#public"
                                    title="Public means that this book is available online to everyone, everywhere. This does not mean that the book is in the public domain, only that anyone can access it. The book is still under copyright to the University of California Press.">
                                    <xsl:text>?</xsl:text>
                                  </a>
                                 <xsl:text>]</xsl:text>
                                </p>                                
                              </div>
                            </div>
                          </div>
                          <input type="hidden" name="fieldList" value="text title creator description"/>
                          <input type="hidden" name="style" value="{$style}"/>
                          <input type="hidden" name="smode">
                            <xsl:attribute name="value" select="replace($smode, '-modify', '')"/>
                          </input>
                          <input type="hidden" name="rmode" value="{$rmode}"/>
                          <input type="hidden" name="brand" value="{$brand}"/>                         
                          <input type="hidden" name="relation" value="escholarship.cdlib.org"/>
                        </form>
                      </xsl:when>
                      <xsl:otherwise>
                        <form class="search-form" name="search-form" method="get" action="{$xtfURL}{$crossqueryPath}">
                          <div align="center">
                            <div class="basic-search">                             
                              <table border="0">
                                <tr>
                                  <td align="left">
                                    <input name="keyword" type="text" size="40"  maxlength="60" value="{$keyword}"/>
                                    <xsl:text>&#160;</xsl:text>
                                    <input type="submit" value="Go!"/>
                                  </td>
                                </tr>
                                <tr>
                                  <td align="left">
                                    <span class="exact-phrase">Exact phrase: "dissent in america"</span>
                                  </td>
                                </tr>
                              </table>
                            </div>
                          </div>
                          <div class="search-lower">
                            <div class="optional-limits">
                              <strong>Optional limits:</strong>
                              <div class="optional-limits2">
                                <p> 
                                  <xsl:text>From Publication Year: </xsl:text>
                                  <xsl:call-template name="date-select"/>
                                </p>
                                <p>
                                  <xsl:text>Show </xsl:text>
                                  <xsl:choose>
                                    <xsl:when test="$rights = 'Public'">
                                      <input type="radio" name="rights" value=""/>
                                      <xsl:text> all books</xsl:text>
                                      <input type="radio" name="rights" value="Public" checked="yes"/>
                                      <xsl:text> public access books</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <input type="radio" name="rights" value="" checked="yes"/>
                                      <xsl:text> all books</xsl:text> 
                                      <input type="radio" name="rights" value="Public"/>
                                      <xsl:text> public access books</xsl:text> 
                                    </xsl:otherwise>
                                  </xsl:choose>
                                  <xsl:text> &#160; [</xsl:text>
                                  <a href="{$serverURL}escholarship/faq.html#public" 
                                    title="Public means that this book is available online to everyone, everywhere. This does not mean that the book is in the public domain, only that anyone can access it. The book is still under copyright to the University of California Press.">
                                    <xsl:text>?</xsl:text>
                                  </a>
                                  <xsl:text>]</xsl:text>
                                </p>                                
                              </div>
                            </div>
                          </div>
                          <input type="hidden" name="fieldList" value="text title creator description"/>
                          <input type="hidden" name="style" value="{$style}"/>
                          <input type="hidden" name="smode">
                            <xsl:attribute name="value" select="replace($smode, '-modify', '')"/>
                          </input>
                          <input type="hidden" name="rmode" value="{$rmode}"/>
                          <input type="hidden" name="brand" value="{$brand}"/>
                          <input type="hidden" name="relation" value="escholarship.cdlib.org"/>
                        </form>
                      </xsl:otherwise>
                    </xsl:choose>
                  </div>
                  <xsl:comment> END SEARCH RESULTS </xsl:comment>
                
                <br/>
                </div>
              </div>
            </td>
          </tr>      
          
          <xsl:comment> END CONTENT ROW </xsl:comment>
          
          <xsl:copy-of select="$brand.footer"/>     
          
        </table>
        <xsl:comment> END OUTER LAYOUT TABLE </xsl:comment>
        
      </body>
    </html>
  </xsl:template>

  
  <!-- ====================================================================== -->
  <!-- Normal Document Hit Template                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit">

    <xsl:variable name="fullark" select="meta/identifier[1]"/>
    <xsl:variable name="ark" select="substring($fullark, string-length($fullark)-9)"/>
    <xsl:variable name="subDir" select="concat('13030/',substring($ark, 9, 2))"/>    
    <xsl:variable name="cover" select="concat($xtfURL,'data/',$subDir,'/',$ark,'/figures/',$ark,'_cover.jpg')"/>
    
    <tr class="search-row">
      <td class="search-results-number">
        <xsl:value-of select="@rank"/><xsl:text>.</xsl:text>
      </td>
      <td class="search-results-thumbnail" width="85">
        <a>                
          <xsl:attribute name="href">
            <xsl:call-template name="dynaxml.url">
              <xsl:with-param name="fullark" select="$fullark"/>
            </xsl:call-template>
          </xsl:attribute>
          <img src="{$cover}" width="85" border="0" alt="cover"/>
        </a>
      </td>
      <td class="search-results-text">
        <div class="search-results-text-inner">
          <a>
            <xsl:attribute name="name">
              <xsl:value-of select="substring(meta/identifier[1], string-length($fullark)-9)"/>
            </xsl:attribute>
          </a>
          <strong>Title: </strong>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="dynaxml.url">
                <xsl:with-param name="fullark" select="$fullark"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:apply-templates select="meta/title[1]"/>
          </a>   
          <xsl:if test="meta/rights='Public'">
            <xsl:text>&#160;</xsl:text>
            <img src="{$serverURL}images/public.gif" width="40" height="14" border="0" alt="online access is available to everyone" title="online access is available to everyone"/>
          </xsl:if>
          <br/>
          <xsl:if test="meta/creator">
            <strong>Author: </strong>
            <xsl:value-of select="meta/creator[1]"/>
            <br/>
          </xsl:if>
          <xsl:if test="meta/sort-year">
            <strong>Published: </strong>
            <xsl:choose>
              <xsl:when test="contains(meta/relation[1], 'ucpress')">
                <xsl:text>University of California Press,&#160;&#160;</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="meta/publisher"/>
                <xsl:text>,&#160;&#160;</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="meta/sort-year[1]"/>
            <br/>
          </xsl:if>          
          <xsl:if test="meta/subject">
            <strong>Subjects: </strong>
            <xsl:apply-templates select="meta/subject"/>
            <br/>
          </xsl:if>   
          <xsl:if test="normalize-space(meta/description[1]) != ''">
            <strong>Publisher's Description: </strong>
            <xsl:call-template name="moreBlock">
              <xsl:with-param name="block" select="meta/description[1]"/>
              <xsl:with-param name="identifier" select="substring(meta/identifier[1], string-length($fullark)-9)"/>
            </xsl:call-template>
            <br/>
          </xsl:if>
          <xsl:if test="snippet">          
            <strong>Matches in book (<xsl:value-of select="@totalHits"/>):</strong>
            <br/>
            <div class="search-results-snippets">
              <xsl:apply-templates select="snippet"/>
            </div>
          </xsl:if>
        </div>
      </td>
    </tr>

  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Compact Document Hit Template                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="docHit" mode="compact">
    
    <xsl:variable name="fullark" select="meta/identifier[1]"/>

    <tr>
      <td align="left" width="5%">
        <xsl:value-of select="@rank"/><xsl:text>.</xsl:text>
      </td>
      <td align="left" width="45%">
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="dynaxml.url">
              <xsl:with-param name="fullark" select="$fullark"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates select="meta/title[1]"/>
        </a>
      </td>
      <td align="left" width="20%">
        <xsl:apply-templates select="meta/creator[1]"/>
      </td>      
      <td align="left" width="20%">
        <xsl:apply-templates select="meta/subject[1]"/>
      </td>     
      <td align="center" width="5%">
        <xsl:apply-templates select="meta/year[1]"/>
      </td>  
      <td align="right" width="5%">
        <xsl:value-of select="@totalHits"/>
      </td>  
    </tr>
    <tr>
      <td colspan="7"><hr/></td>
    </tr>
    
  </xsl:template>
        
  <!-- ====================================================================== -->
  <!-- Snippet Template                                                       -->
  <!-- ====================================================================== -->

  <xsl:template match="snippet[parent::docHit]">
    <span class="search-results-snippet">
      <xsl:text>...</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>...</xsl:text>
    </span>
    <br/>
  </xsl:template>
    
  <!-- ====================================================================== -->
  <!-- Hit Template                                                           -->
  <!-- ====================================================================== -->
  
  <xsl:template match="hit">
    <xsl:apply-templates/>
  </xsl:template>
    
  <!-- ====================================================================== -->
  <!-- Term Template                                                          -->
  <!-- ====================================================================== -->
 
  <xsl:template match="term">
    <xsl:variable name="fullark" select="ancestor::docHit/meta/identifier[1]"/>
    <xsl:variable name="hit.rank"><xsl:value-of select="ancestor::snippet/@rank"/></xsl:variable>
    
    <xsl:variable name="snippet.link">    
      <xsl:call-template name="dynaxml.url">
        <xsl:with-param name="fullark" select="$fullark"/>
      </xsl:call-template>
      <xsl:value-of select="concat('&amp;hit.rank=', $hit.rank)"/>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="ancestor::snippet[parent::docHit]">
        <a class="search-item" href="{$snippet.link}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="search-term">  
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose> 
   
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Search Bar                                                             -->
  <!-- ====================================================================== -->

  <xsl:template name="searchBar">
    <xsl:if test="docHit">
      <xsl:comment> BEGIN SEARCH BAR </xsl:comment> 
      <div class="search-bar-outer">
        <div class="search-bar-inner-left">
          <form class="search-form" method="get" action="{$xtfURL}{$crossqueryPath}">
            <span class="form-element">Sort by:</span>
            <xsl:call-template name="sort.options"/>
            <span class="form-element">Show:</span>
            <xsl:call-template name="access.options"/>
            <xsl:call-template name="hidden.query">
              <xsl:with-param name="queryString" select="$queryString"/>
            </xsl:call-template>
            <span class="form-element">&#160;<input type="submit" value="Go!"/></span>
          </form>
        </div>   
        <div class="search-bar-inner-right">
          <span class="pagenumber-links">
            <xsl:call-template name="pages"/>
          </span>
        </div>
      </div>
      <xsl:comment> END SEARCH BAR </xsl:comment>
    </xsl:if>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Access Options                                                         -->
  <!-- ====================================================================== -->
  
  <xsl:template name="access.options">
    
    <select size="1" name="rights">
      <xsl:choose>
        <xsl:when test="$rights = ''">
          <option value="" selected="selected">all books</option>
          <option value="Public">public access books</option> 
        </xsl:when>
        <xsl:when test="$rights = 'Public'">
          <option value="">all books</option>
          <option value="Public" selected="selected">public access books</option> 
        </xsl:when>
      </xsl:choose>
    </select>
    
  </xsl:template>               
  <!-- ====================================================================== -->
  <!-- Date Selector                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template name="date-select">
    <select size="1" name="year" class="publisher">
      <option value=""></option>
      <xsl:call-template name="selectBuilder">
        <xsl:with-param name="selectType" select="'year'"/>
        <xsl:with-param name="optionList" select="'2005::2004::2003::2002::2001::2000::1999::1998::1997::1996::1995::1994::1993::1992::1991::1990::1989::1988::1987::1986::1985::1984::1983::1982::1981::1980::1979::1978::1977::1976::1975::1974::1973::1972::1971::1970::1969::1968::1967::1966::1965::1964::1963::1962::1961::1960::1959::1958::1957::1956::1955::1954::1953::1952::1951::1950::1949::1948::1947::1946::1945::1944::1943::1942::1941::1940::'"/>
        <xsl:with-param name="count" select="1"/>
      </xsl:call-template>
    </select>
    <xsl:text>&#160; to &#160;</xsl:text>
    <select size="1" name="year-max" class="publisher">
      <option value=""></option>
      <xsl:call-template name="selectBuilder">
        <xsl:with-param name="selectType" select="'year-max'"/>
        <xsl:with-param name="optionList" select="'2005::2004::2003::2002::2001::2000::1999::1998::1997::1996::1995::1994::1993::1992::1991::1990::1989::1988::1987::1986::1985::1984::1983::1982::1981::1980::1979::1978::1977::1976::1975::1974::1973::1972::1971::1970::1969::1968::1967::1966::1965::1964::1963::1962::1961::1960::1959::1958::1957::1956::1955::1954::1953::1952::1951::1950::1949::1948::1947::1946::1945::1944::1943::1942::1941::1940::'"/>
        <xsl:with-param name="count" select="1"/>
      </xsl:call-template>
    </select>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- eScholarship Help                                                      -->
  <!-- ====================================================================== -->

  <xsl:template name="eschol-help">
    <table border="0" width="100%">
      <tr>
        <td>
          <p class="directions">Helpful hints to improve your results: <ul>
            <span class="help"> Try simple and direct words (example: if you 
              want to see pictures of squirrels use &quot;squirrel&quot; and 
              not &quot;rodent&quot;) <br/>If you want more results, try a 
                broader word (example:try &quot;animal&quot; not &quot;squirrel&quot;)
                <br/></span></ul></p>
        </td>
      </tr>
    </table>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Subject Links                                                          -->
  <!-- ====================================================================== -->

  <xsl:template match="subject">
    <a href="{$xtfURL}{$crossqueryPath}?subject={.}&amp;subject-join=exact&amp;relation={$relation}&amp;style={$style}&amp;smode={$smode}&amp;rmode={$rmode}&amp;brand={$brand}">
      <xsl:apply-templates/>
    </a>
    <xsl:if test="not(position() = last())">
      <xsl:text> | </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Generate ARK List for Testing                                          -->
  <!-- ====================================================================== -->
  
  <!-- Leave indenting as is in the following template! -->
  
  <xsl:template match="crossQueryResult" mode="test">
    <xsl:result-document format="xml" exclude-result-prefixes="#all">
      <search count="{@totalDocs}" queryString="{$queryString}">
        <xsl:for-each select="docHit">
          <xsl:sort select="number(@rank)" />
          <hit sysID="{meta/identifier[1]}"
            rank="{@rank}"
            score="{@score}"
            totalHits="{count(.//hit)}"/>
        </xsl:for-each>
      </search>
    </xsl:result-document>
  </xsl:template>
  

  <!-- ====================================================================== -->
  <!-- Format Query for Display                                               -->
  <!-- ====================================================================== -->
  <!-- should this go in its own file in xtf-sf common? 		      -->

  <xsl:template name="format-query">

    <xsl:param name="query"/>
    <!-- nowadays, the <query> xml is repeated in the crossQuery results, but the
	 param is kept for backwards compatability 
      -->
    <!-- xsl:copy-of select="query"/ -->
    <xsl:choose>
	<xsl:when test="$keyword">
		<!-- probably very fragile -->
		<xsl:apply-templates select="(query//*[@field != 'relation'])[1]/*" mode="query"/>
		<xsl:choose>
			<!-- if they did not search all fields, tell them which are in the feildList -->
			<xsl:when test="$fieldList">
				in <span class="search-type">
				<xsl:value-of select="replace($fieldList,'\s',', ')"/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				in <span class="search-type"> keywords</span>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="query//*[@field = 'rights']" mode="query"/>
	</xsl:when>
	<xsl:otherwise>
    		<xsl:apply-templates select="query" mode="query"/>
	</xsl:otherwise>
    </xsl:choose>
    

  </xsl:template>

  <xsl:template match="query" mode="query">
	<xsl:apply-templates mode="query"/>
	<xsl:apply-templates mode="leary"/>
  </xsl:template>

  <xsl:template match="and | or | near | range | not" mode="query">
	<xsl:if test="preceding-sibling::*[@field != 'relation'][@field != 'rights'] and not (@field = 'relation')">
		<xsl:value-of select="name(..)"/><xsl:text> </xsl:text>
	</xsl:if>
	<xsl:if test="not (@field = 'relation')">
		<xsl:apply-templates mode="query"/>
		<xsl:if test="@field">
			in <span class="search-type"><xsl:value-of select="@field"/></span>
		</xsl:if>
	</xsl:if>
  </xsl:template>

  <xsl:template match="term" mode="query">
	<xsl:if test="preceding-sibling::term and (. != $keyword)">
		<xsl:value-of select="name(..)"/><xsl:text> </xsl:text>
	</xsl:if>
	<span class="search-term"><xsl:value-of select="."/></span>
	<xsl:text> </xsl:text>
  </xsl:template>
 
  <xsl:template match="phrase" mode="query">
	&quot;<span class="search-term"><xsl:value-of select="term"/></span>&quot;
  </xsl:template>

  <xsl:template match="exact" mode="query">
	'<span class="search-term"><xsl:value-of select="term"/></span>'
		<xsl:if test="@field">
			in <span class="search-type"><xsl:value-of select="@field"/></span>
		</xsl:if>
  </xsl:template>

  <xsl:template match="upper" mode="query">
	<xsl:if test="../lower != .">
	- <xsl:apply-templates mode="query"/>
	</xsl:if>
  </xsl:template>

  <!-- this template is escholarship specific -->
  <xsl:template match="*[@field='rights'][term/text()='public']" mode="query">
  </xsl:template>
  <xsl:template match="*[@field='rights'][term/text()='public']" mode="leary">
	in <span class="search-type">public access</span>
  </xsl:template>
  <xsl:template match="*[@field][@field != 'rights']" mode="leary">
  </xsl:template>

  <!-- this template will be fragile and escholarship specific -->
  <xsl:template name="searchOrBrowse">
	<xsl:choose>
		<!-- exact subject searches are marketed as browse -->
		<xsl:when test="query/and/exact[@field='subject']">
			<xsl:text>browse for </xsl:text>
		</xsl:when>
		<!-- Author and Title browse are sorted list of all eschol -->
		<xsl:when test="
			(query/and/and[@field='relation'] and
			 query/and/and[@field='rights'] and
			 count(query/and/*) = 2 
			) or (
			 query/and/and[@field='relation'] and
			 count(query/and/*) = 1 
			)">
			<xsl:text>browse </xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>search for </xsl:text>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
   
   
   <!-- ====================================================================== -->
   <!-- Access Denied Template                                                 -->
   <!-- ====================================================================== -->
   
   <xsl:template match="crossQueryResult" mode="denied">
      <xsl:variable name="title" select="//meta/title"/>
      <xsl:variable name="creator" select="//meta/creator"/>
      <xsl:variable name="bnum" select="//meta/bnum"/>
      <html>
         <head>
            <title>Access Restricted</title>
            <xsl:copy-of select="$brand.links"/>
         </head>
         <body>
            <table width="100%" border="0" cellpadding="0" cellspacing="0">         
               <xsl:copy-of select="$brand.header"/>
            </table>
            <div align="center">
            <table width="92%" border="0" cellpadding="0" cellspacing="0">
               <tr>
                  <td colspan="3">
                     <h2>Access Restricted</h2>
                     <p>The book you seek in the eScholarship Editions - <b><xsl:value-of select="$title"/>,
                        <xsl:value-of select="$creator"/></b> - is available only to University of California staff,
                        faculty, and students. If you <i>are</i> a member of the UC community and are off campus, you
                        must use the <a href="http://www.cdlib.org/inside/resources/services/offcampusaccess.html">proxy</a> server for your campus to access the title.</p>
                     <p>If you are <i>not</i> affiliated with the University of California, please visit our <a href="/xtf/search?sort=title&amp;relation=escholarship.cdlib.org&amp;style=eschol&amp;rights=Public">public
                        browse page</a>, which features over 500 scholarly monographs freely available to the public.</p>
                     <p>If you would like to purchase <b><xsl:value-of select="$title"/>,
                        <xsl:value-of select="$creator"/></b> from the publisher, click the button below.</p>
                     <p><a href="http://www.ucpress.edu/books/pages/{$bnum}.html"><img src="/xtf/icons/eschol/buy_this_book.gif"/></a></p>
                     <p>Our apologies for the inconvenience.</p>
                  </td>
               </tr>     
            </table>
               </div>
            <table width="100%" border="0" cellpadding="0" cellspacing="0">
               <xsl:copy-of select="$brand.footer"/>     
            </table>
         </body>
      </html>
   </xsl:template>
   
   
</xsl:stylesheet>
