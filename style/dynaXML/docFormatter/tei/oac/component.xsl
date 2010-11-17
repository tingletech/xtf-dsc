<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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

<!-- ====================================================================== -->
<!-- Heads                                                                  -->
<!-- ====================================================================== -->

<xsl:template match="head">

  <xsl:variable name="level" select="substring-after(name(parent::*), 'div')"/>

  <xsl:variable name="style">
    <xsl:choose>
      <xsl:when test="@rend='center'">text-align: center;</xsl:when>
      <xsl:when test="@rend='under'">text-decoration: none;</xsl:when>
      <xsl:when test="@rend='italics'">font-style: italic;</xsl:when>
      <xsl:when test="@rend='center under'">text-align: center; text-decoration: none;</xsl:when>
      <xsl:when test="@rend='bold'">font-weight: bold;</xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$level != ''">
      <xsl:choose>
        <xsl:when test="number($level)=1">
          <h1>
            <xsl:attribute name="style">
              <xsl:value-of select="$style"/>
            </xsl:attribute>
            <xsl:if test="parent::*/@n">
              <xsl:value-of select="parent::*/@n"/><xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
          </h1>
        </xsl:when>
        <xsl:when test="number($level)=2">
          <h2>
            <xsl:attribute name="style">
              <xsl:value-of select="$style"/>
            </xsl:attribute>
            <xsl:if test="parent::*/@n">
              <xsl:value-of select="parent::*/@n"/><xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
          </h2>
        </xsl:when>
        <xsl:when test="number($level)=3">
          <h3>
            <xsl:attribute name="style">
              <xsl:value-of select="$style"/>
            </xsl:attribute>
            <xsl:if test="parent::*/@n">
              <xsl:value-of select="parent::*/@n"/><xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
          </h3>
        </xsl:when>
        <xsl:when test="number($level)=4">
          <h4>
            <xsl:attribute name="style">
              <xsl:value-of select="$style"/>
            </xsl:attribute>
            <xsl:if test="parent::*/@n">
              <xsl:value-of select="parent::*/@n"/><xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
          </h4>
        </xsl:when>
        <xsl:when test="number($level)=5">
          <h5>
            <xsl:attribute name="style">
              <xsl:value-of select="$style"/>
            </xsl:attribute>
            <xsl:if test="parent::*/@n">
              <xsl:value-of select="parent::*/@n"/><xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
          </h5>
        </xsl:when>
        <xsl:when test="number($level)=6">
          <h6>
            <xsl:attribute name="style">
              <xsl:value-of select="$style"/>
            </xsl:attribute>
            <xsl:if test="parent::*/@n">
              <xsl:value-of select="parent::*/@n"/><xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
          </h6>
        </xsl:when>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="docAuthor">
  <h4><xsl:apply-templates/></h4>
</xsl:template>

<!-- ====================================================================== -->
<!-- Verse                                                                  -->
<!-- ====================================================================== -->

<xsl:template match="lg">
  <xsl:choose>
    <xsl:when test="parent::lg">
      <tr>
        <td colspan="2">
          <br/><table border="0" cellspacing="0" cellpadding="0"><xsl:apply-templates/></table>
        </td>
      </tr>
    </xsl:when>
    <xsl:otherwise>
      <br/>
      <table border="0" cellspacing="0" cellpadding="0" width="100%"><xsl:apply-templates/></table>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="l">
  <xsl:variable name="indent">
    <xsl:choose>
      <xsl:when test="@rend='indent1'">60</xsl:when>
      <xsl:when test="@rend='indent2'">90</xsl:when>
      <xsl:when test="@rend='indent3'">120</xsl:when>
      <xsl:when test="@rend='indent4'">150</xsl:when>
      <xsl:when test="@rend='indent5'">180</xsl:when>
      <xsl:when test="@rend='indent6'">210</xsl:when>
      <xsl:otherwise>30</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="parent::lg">
      <tr>
        <td width="{$indent}">
          <xsl:choose>
            <xsl:when test="@n">
              <span class="run-head"><xsl:value-of select="@n"/></span>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text> </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:apply-templates/>
        </td>
      </tr>      
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/><br/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template match="seg">
  <xsl:if test="position() > 1">
    <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
  </xsl:if>
  <xsl:apply-templates/><br/>
</xsl:template>

<!-- ====================================================================== -->
<!-- Speech                                                                 -->
<!-- ====================================================================== -->

<xsl:template match="sp">
  <xsl:apply-templates/><br/>
</xsl:template>

<xsl:template match="speaker">
  <b><xsl:apply-templates/></b>
</xsl:template>

<xsl:template match="sp/p">
  <p class="noindent"><xsl:apply-templates/></p>
</xsl:template>

<!-- ====================================================================== -->
<!-- Lists                                                                  -->
<!-- ====================================================================== -->

<xsl:template match="list">
  <xsl:if test="head">
    <h4>
      <xsl:apply-templates select="head"/>
    </h4>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="@type='gloss'">
       <ul class="nobull"><xsl:apply-templates/></ul>
    </xsl:when>
    <xsl:when test="@type='simple'">
      <ul class="nobull"><xsl:apply-templates/></ul>
    </xsl:when>
    <xsl:when test="@type='ordered'">
      <xsl:choose>
        <xsl:when test="@rend='alpha' or @rend='lower-alpha' or @rend='loweralpha'">
          <ol class="alpha"><xsl:apply-templates/></ol>
        </xsl:when>
        <xsl:otherwise>
          <ol><xsl:apply-templates/></ol>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="@type='unordered'">
      <ul><xsl:apply-templates/></ul>
    </xsl:when>
    <xsl:when test="@type='bulleted'">
      <xsl:choose>
        <xsl:when test="@rend='dash'">
          <ul class="nobull"><xsl:text>- </xsl:text><xsl:apply-templates/></ul>
        </xsl:when>
        <xsl:otherwise>
          <ul><xsl:apply-templates/></ul>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="@type='numbered'">
      <ol><xsl:apply-templates/></ol>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template  match="label">
  <li><xsl:apply-templates/></li>
</xsl:template>

<xsl:template match="item">
  <xsl:choose>
    <xsl:when test="parent::list[@type='gloss']">
      <li>&#160;&#160;&#160;&#160;<xsl:apply-templates/></li>
    </xsl:when>
    <xsl:otherwise>
      <li><xsl:apply-templates/></li>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="name">
  <xsl:apply-templates/>
</xsl:template>

<!-- ====================================================================== -->
<!-- Notes                                                                  -->
<!-- ====================================================================== -->

<xsl:template match="note">
  <xsl:choose>
    <xsl:when test="@type='footnote' or @place='foot'">      
      <xsl:variable name="id" select="@id"/>      
      <xsl:choose>
        <xsl:when test="$doc.view='popup' or $doc.view='entire_text'">
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="not(//ref[@target=$id])">
            <sup class="ref">
              <xsl:text>[</xsl:text>
              <a>
                <xsl:attribute name="href">javascript://</xsl:attribute>
                <xsl:attribute name="onClick">
                  <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$doc.path"/>&#038;doc.view=popup&#038;chunk.id=<xsl:value-of select="$id"/><xsl:text>','popup','width=300,height=300,resizable=yes,scrollbars=yes')</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="@n"/>
              </a>
              <xsl:text>]</xsl:text>
            </sup>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="@type='endnote' or @place='end'">
      <xsl:choose>
        <xsl:when test="$anchor.id=@id">
          <a name="X"></a>
          <div class="note-hi">
            <xsl:choose>
              <xsl:when test="p">
                <xsl:apply-templates/>
              </xsl:when>
              <xsl:otherwise>
                <p>
                  <xsl:call-template name="notenum"/>
                  <xsl:apply-templates/>
                </p>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <div class="note">
            <xsl:choose>
              <xsl:when test="p">
                <xsl:apply-templates/>
              </xsl:when>
              <xsl:otherwise>
                <p>
                  <xsl:call-template name="notenum"/>
                  <xsl:apply-templates/>
                </p>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$anchor.id=@id">
          <a name="X"></a>
          <div class="note-hi">
            <xsl:choose>
              <xsl:when test="p">
                <xsl:apply-templates/>
              </xsl:when>
              <xsl:otherwise>
                <p>
                  <xsl:call-template name="notenum"/>
                  <xsl:apply-templates/>
                </p>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <div class="note">
            <xsl:choose>
              <xsl:when test="p">
                <xsl:apply-templates/>
              </xsl:when>
              <xsl:otherwise>
                <p>
                  <xsl:call-template name="notenum"/>
                  <xsl:apply-templates/>
                </p>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="p[parent::note]">

  <xsl:variable name="n" select="parent::note/@n"/>

  <p>
    <xsl:if test="position()=1">
      <xsl:if test="$n != ''">
        <xsl:value-of select="$n"/><xsl:text>. </xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates/>
  </p>
</xsl:template>

<xsl:template name="notenum">
  <xsl:if test="@n">
    <b><xsl:value-of select="@n"/><xsl:text>.&#160;</xsl:text></b>
  </xsl:if>
</xsl:template>

<!-- ====================================================================== -->
<!-- Paragraphs                                                             -->
<!-- ====================================================================== -->

<xsl:template match="p">

  <xsl:choose>
    <xsl:when test="parent::td">
      <p><xsl:apply-templates/></p>
    </xsl:when>
    <xsl:when test="not(preceding-sibling::p)">
      <xsl:choose>
        <xsl:when test="@rend='hang'">
          <p class="hang"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:when test="@rend='indent'">
          <p class="indent"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:when test="@rend='noindent'">
          <p class="noindent"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:when test="@rend">
          <p style="{@rend}"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:otherwise>
          <p class="noindent"><xsl:apply-templates/></p>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="not(following-sibling::p)">
      <xsl:choose>
        <xsl:when test="@rend='hang'">
          <p class="hang"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:when test="@rend='indent'">
          <p class="indent"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:when test="@rend='noindent'">
          <p class="noindent"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:when test="@rend">
          <p style="{@rend}"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:otherwise>
          <p class="padded"><xsl:apply-templates/></p>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="@rend">
          <p style="{@rend}"><xsl:apply-templates/></p>
        </xsl:when>
        <xsl:otherwise>
          <p><xsl:apply-templates/></p>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!-- ====================================================================== -->
<!-- Other Text Blocks                                                      -->
<!-- ====================================================================== -->

<xsl:template match="epigraph">
  <blockquote><xsl:apply-templates/></blockquote><br/>
</xsl:template>

<xsl:template match="epigraph/bibl">
  <p class="right"><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="byline">
  <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="cit">
  <blockquote><xsl:apply-templates/></blockquote>
</xsl:template>

<xsl:template match="cit/bibl">
  <p class="right"><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="quote">
  <blockquote><xsl:apply-templates/></blockquote>
</xsl:template>

<xsl:template match="q">
  <blockquote><xsl:apply-templates/></blockquote>
</xsl:template>

<xsl:template match="date">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="foreign">
  <i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="address">
  <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="addrLine">
  <xsl:apply-templates/><br/>
</xsl:template>

<!-- ====================================================================== -->
<!-- Bibliographies                                                         -->
<!-- ====================================================================== -->

<xsl:template match="listBibl">
  <xsl:if test="$anchor.id=@id">
    <a name="X"></a>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="bibl">
  <xsl:choose>
    <xsl:when test="parent::listBibl">
      <xsl:choose>
	<xsl:when test="$anchor.id=@id">
	  <a name="X"></a>
	  <div class="bibl-hi">
	    <p class="hang">
              <xsl:apply-templates/>
            </p>
          </div>
	</xsl:when>
	<xsl:otherwise>
	  <p class="hang">
            <xsl:apply-templates/>
          </p>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Because of order in the following, "rend" takes precedence over "level" -->

<xsl:template match="title">
  <xsl:choose>
    <xsl:when test="@rend='italic'">
      <i><xsl:apply-templates/></i>
    </xsl:when>
    <xsl:when test="@level='m'">
      <i><xsl:apply-templates/></i>
    </xsl:when>
    <xsl:when test="@level='a'">
      &#x201C;<xsl:apply-templates/>&#x201D;
    </xsl:when>
    <xsl:when test="@level='j'">
      <i><xsl:apply-templates/></i>
    </xsl:when>
    <xsl:when test="@level='s'">
      <i><xsl:apply-templates/></i>
    </xsl:when>
    <xsl:when test="@level='u'">
      <i><xsl:apply-templates/></i>
    </xsl:when>
    <xsl:otherwise>
      <i><xsl:apply-templates/></i>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="author">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="editor">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="publisher">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="pubPlace">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="biblScope">
  <xsl:apply-templates/>
</xsl:template>

<!-- ====================================================================== -->
<!-- Formatting                                                             -->
<!-- ====================================================================== -->

<xsl:template match="hi">
  <xsl:choose>
    <xsl:when test="@rend='bold'">
      <b><xsl:apply-templates/></b>
    </xsl:when>
    <xsl:when test="@rend='italic' or @rend='italics'">
      <i><xsl:apply-templates/></i>
    </xsl:when>
    <xsl:when test="@rend='center'">
      <span style="text-align: center;"><xsl:apply-templates/></span>
    </xsl:when>
    <xsl:when test="@rend='sub'">
      <sub><xsl:apply-templates/></sub>
    </xsl:when>
    <xsl:when test="@rend='sup'">
      <sup><xsl:apply-templates/></sup>
    </xsl:when>
    <xsl:when test="@rend='under' or @rend='underline'">
      <u><xsl:apply-templates/></u>
    </xsl:when>
    <xsl:otherwise>
      <i><xsl:apply-templates/></i>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="emph">
  <xsl:choose>
    <xsl:when test="@rend='bold'">
      <b><xsl:apply-templates/></b>
    </xsl:when>
    <xsl:when test="@rend='italic' or @rend='italics'">
      <i><xsl:apply-templates/></i>
    </xsl:when>
    <xsl:when test="@rend='center'">
      <span style="text-align: center;"><xsl:apply-templates/></span>
    </xsl:when>
    <xsl:when test="@rend='sub'">
      <sub><xsl:apply-templates/></sub>
    </xsl:when>
    <xsl:when test="@rend='sup'">
      <sup><xsl:apply-templates/></sup>
    </xsl:when>
    <xsl:when test="@rend='under' or @rend='underline'">
      <u><xsl:apply-templates/></u>
    </xsl:when>
    <xsl:otherwise>
      <i><xsl:apply-templates/></i>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="lb">
  <br/>
</xsl:template>

<!-- ====================================================================== -->
<!-- References                                                             -->
<!-- ====================================================================== -->

<xsl:template match="ptr">

  <xsl:variable name="target" select="@target"/>

  <xsl:variable name="chunk">
    <xsl:value-of select="key('generic-id', $target)/ancestor::*[self::div1 or self::div2 or self::div3 or self::div4 or self::div5 or self::div6 or self::div7 or self::div8][1]/@id"/>
  </xsl:variable>

  <xsl:variable name="toc" select="key('div-id', $chunk)/parent::*/@id"/>

  <xsl:choose>
    <xsl:when test="@rend='marked'">
      <sup class="ref">
        <xsl:text>[</xsl:text>
          <a>
            <xsl:attribute name="href"><xsl:value-of select="$doc.path"/>&#038;chunk.id=<xsl:value-of select="$chunk"/>&#038;toc.id=<xsl:value-of select="$toc"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/><xsl:value-of select="$search"/>&#038;anchor.id=<xsl:value-of select="$target"/>#X</xsl:attribute>
            <xsl:attribute name="target">_top</xsl:attribute>
            <xsl:value-of select="@n"/>
          </a>
        <xsl:text>]</xsl:text>
      </sup>
    </xsl:when>
    <xsl:when test="@rend='unmarked'"/>
  </xsl:choose>

</xsl:template>

<xsl:template match="ref">

  <xsl:variable name="target" select="@target"/>

  <xsl:variable name="chunk">
    <xsl:choose>
      <xsl:when test="@type='secref'">
        <xsl:value-of select="@target"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="key('generic-id', $target)/ancestor::*[self::div1 or self::div2 or self::div3 or self::div4 or self::div5 or self::div6 or self::div7 or self::div8][1]/@id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="toc" select="key('div-id', $chunk)/parent::*/@id"/>

  <xsl:choose>
    <xsl:when test="@type='note'">
      <sup class="ref">
        <xsl:text>[</xsl:text>
          <a>
            <xsl:attribute name="href"><xsl:value-of select="$doc.path"/>&#038;chunk.id=<xsl:value-of select="$chunk"/>&#038;toc.id=<xsl:value-of select="$toc"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/><xsl:value-of select="$search"/>&#038;anchor.id=<xsl:value-of select="$target"/>#X</xsl:attribute>
            <xsl:attribute name="target">_top</xsl:attribute>
            <xsl:apply-templates/>
          </a>
        <xsl:text>]</xsl:text>
      </sup>
    </xsl:when>
    <xsl:when test="@type='fnoteref' or @type='fn'">
      <sup class="ref">
        <xsl:text>[</xsl:text>
          <a>
            <xsl:attribute name="href">javascript://</xsl:attribute>
            <xsl:attribute name="onClick">
              <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$doc.path"/>&#038;doc.view=popup&#038;chunk.id=<xsl:value-of select="$target"/><xsl:text>','popup','width=300,height=300,resizable=yes,scrollbars=yes')</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
          </a>
        <xsl:text>]</xsl:text>
      </sup>
    </xsl:when>
    <xsl:when test="@type='endnote' or @type='en'">
      <sup class="ref">
        <xsl:text>[</xsl:text>
          <a>
            <xsl:attribute name="href"><xsl:value-of select="$doc.path"/>&#038;chunk.id=<xsl:value-of select="$chunk"/>&#038;toc.id=<xsl:value-of select="$toc"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/><xsl:value-of select="$search"/>&#038;anchor.id=<xsl:value-of select="$target"/>#X</xsl:attribute>
            <xsl:attribute name="target">_top</xsl:attribute>
            <xsl:apply-templates/>
          </a>
        <xsl:text>]</xsl:text>
      </sup>
    </xsl:when>
    <xsl:otherwise>
      <a>
        <xsl:attribute name="href"><xsl:value-of select="$doc.path"/>&#038;chunk.id=<xsl:value-of select="$chunk"/>&#038;toc.id=<xsl:value-of select="$toc"/>&#038;toc.depth=<xsl:value-of select="$toc.depth"/>&#038;brand=<xsl:value-of select="$brand"/><xsl:value-of select="$search"/>&#038;anchor.id=<xsl:value-of select="$target"/>#X</xsl:attribute>
        <xsl:attribute name="target">_top</xsl:attribute>
        <xsl:apply-templates/>
      </a>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template match="xref">
  <xsl:choose>
    <xsl:when test="@rend='audio'"/>
    <xsl:otherwise>
      <a>
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="@href">
              <xsl:value-of select="@href"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@to"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="target">
          <xsl:choose>
            <xsl:when test="@rend='new'">
              <xsl:value-of select="'new'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'_top'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:apply-templates/>
      </a>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ====================================================================== -->
<!-- Figures                                                                -->
<!-- ====================================================================== -->

<xsl:template match="figure" xmlns:m="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" >
  <!-- $figureStyle will be 'voroBasic' or 'dynaXML' -->
  <xsl:variable name="entity" select="@entity"/>
  <xsl:variable name="img_src">
    <xsl:choose>
      <xsl:when test="contains($docId, 'preview')">
        <xsl:value-of select="unparsed-entity-uri(@entity)"/>
      </xsl:when>
      <xsl:when test="$figureStyle = 'voroBasic'">
        <xsl:value-of select="concat($xtfURL, 'data/', $subDir, '/', $docId, '/')"/>
        <xsl:value-of select="$METS/m:mets/m:fileSec/m:fileGrp/m:file[@ID=$entity]/m:FLocat/@*[local-name(.)='href']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($figure.path, @entity)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="fullsize">
    <xsl:choose>
      <xsl:when test="contains($docId, 'preview')">
        <xsl:value-of select="unparsed-entity-uri(substring-before(substring-after(@rend, 'popup('), ')'))"/>
      </xsl:when>
      <xsl:when test="$figureStyle = 'voroBasic'">
	<xsl:value-of select="concat($xtfURL, 'data/', $subDir, '/', $docId, '/')"/>
	<xsl:variable name="popup" select="substring-before(substring-after(@rend,'('),')')"/>
	<xsl:value-of select="$METS/m:mets/m:fileSec/m:fileGrp/m:file[@ID=$popup]/m:FLocat/@*[local-name(.)='href']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($figure.path, substring-before(substring-after(@rend,'('),')'))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$anchor.id=@id">
    <a name="X"></a>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="@rend='inline'">
      <img src="{$img_src}" alt="inline image"/>
        <!-- for figDesc -->
        <xsl:apply-templates/>
    </xsl:when>
    <xsl:when test="@rend='figure'">
      <div class="illgrp">
        <img src="{$img_src}" alt="figure"/>
        <!-- for figDesc -->
        <xsl:apply-templates/>
      </div>
    </xsl:when>
    <xsl:when test="@rend='offline' and not($doc.view='entire_text')">
     <div class="illgrp">
        <a>
          <xsl:attribute name="href">javascript://</xsl:attribute>
          <xsl:attribute name="onClick">
            <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$doc.path"/><xsl:text>&#038;doc.view=popup&#038;fig.ent=</xsl:text><xsl:value-of select="$img_src"/><xsl:text>','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
          </xsl:attribute>
          <img src="{$icon.path}offline.gif" border="0" alt="figure"/>
        </a>
        <!-- for figDesc -->
        <xsl:apply-templates/>
      </div>
    </xsl:when>
    <xsl:when test="contains(@rend, 'popup(')">
      <div class="illgrp">
        <img src="{$img_src}" alt="figure"/>
        <!-- for figDesc -->
        <xsl:apply-templates/>
        <br/>
        <xsl:text>[</xsl:text>
        <a>
          <xsl:attribute name="href">javascript://</xsl:attribute>
          <xsl:attribute name="onClick">
            <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$doc.path"/><xsl:text>&#038;doc.view=popup&#038;fig.ent=</xsl:text><xsl:value-of select="$fullsize"/><xsl:text>','popup','width=400,height=400,resizable=yes,scrollbars=yes')</xsl:text>
          </xsl:attribute>
          <xsl:text>Full Size</xsl:text>
        </a>
        <xsl:text>]</xsl:text>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <div class="illgrp">
        <img src="{$img_src}" alt="figure"/>
        <!-- for figDesc -->
        <xsl:apply-templates/>
      </div>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template match="figDesc">
  <br/><span class="down1"><xsl:if test="@n"><xsl:value-of select="@n"/>. </xsl:if><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="head[parent::figure]">
  <br/><span class="down1"><xsl:if test="@n"><xsl:value-of select="@n"/>. </xsl:if><xsl:apply-templates/></span>
</xsl:template>

<!-- ====================================================================== -->
<!-- Formulas                                                               -->
<!-- ====================================================================== -->

<xsl:template match="formula">

  <xsl:if test="$anchor.id=@id">
    <a name="X"></a>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="@rend='inline'">
      <img src="{$figure.path}{@id}.gif" alt="formula"/>
      <xsl:text> [</xsl:text>
      <a>
        <xsl:attribute name="href">javascript://</xsl:attribute>
        <xsl:attribute name="onClick">
          <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$doc.path"/><xsl:text>&#038;doc.view=popup&#038;formula.id=</xsl:text><xsl:value-of select="@id"/><xsl:text>','popup','width=600,height=600,resizable=yes,scrollbars=yes')</xsl:text>
        </xsl:attribute>
        <xsl:text>Equation</xsl:text>
      </a>
      <xsl:text>]</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <div class="illgrp">
        <img src="{$figure.path}{@id}.gif" alt="formula"/>
        <br/>
        <xsl:text>[</xsl:text>
        <a>
          <xsl:attribute name="href">javascript://</xsl:attribute>
          <xsl:attribute name="onClick">
            <xsl:text>javascript:window.open('</xsl:text><xsl:value-of select="$doc.path"/><xsl:text>&#038;doc.view=popup&#038;formula.id=</xsl:text><xsl:value-of select="@id"/><xsl:text>','popup','width=600,height=600,resizable=yes,scrollbars=yes')</xsl:text>
          </xsl:attribute>
          <xsl:text>Equation</xsl:text>
        </a>
        <xsl:text>]</xsl:text>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ====================================================================== -->
<!-- Milestones                                                             -->
<!-- ====================================================================== -->

<xsl:template match="milestone">
  <xsl:choose>
    <xsl:when test="not(following-sibling::*)"/>
    <xsl:when test="not(@n)"/>
    <xsl:when test="position()=1">
      <div align="center">&#x2015; <span class="run-head"><xsl:value-of select="@n"/></span> &#x2015;</div>
    </xsl:when>
    <xsl:when test="$anchor.id=@id">
      <a name="X"></a>
      <hr class="pb"/>
      <div align="center">&#x2015; <span class="run-head"><xsl:value-of select="@n"/></span> &#x2015;</div>
    </xsl:when>
    <xsl:otherwise>
      <hr class="pb"/>
      <div align="center">&#x2015; <span class="run-head"><xsl:value-of select="@n"/></span> &#x2015;</div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="pb">
  <xsl:choose>
    <xsl:when test="not(@n)"/>
    <xsl:when test="parent::lg">
      <tr>
        <td align="center" colspan="2">
          <xsl:if test="$anchor.id=@id">
            <a name="X"></a>
          </xsl:if>
          <xsl:if test="not(position()=1)">
            <hr class="pb"/>
          </xsl:if>
          <xsl:text>&#x2015; </xsl:text><span class="run-head"><xsl:value-of select="@n"/></span><xsl:text> &#x2015;</xsl:text>
          <br/><br/>
        </td>
      </tr>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="$anchor.id=@id">
        <a name="X"></a>
      </xsl:if>
      <xsl:if test="not(position()=1)">
        <hr class="pb"/>
      </xsl:if>
      <div align="center">&#x2015; <span class="run-head"><xsl:value-of select="@n"/></span> &#x2015;</div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ====================================================================== -->
<!-- Letters                                                                -->
<!-- ====================================================================== -->

<xsl:template match="opener">
  <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="salute">
  <div><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="closer">
  <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="signed">
  <div><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="dateline">
  <div><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="trailer">
  <p><xsl:apply-templates/></p>
</xsl:template>

<!-- ====================================================================== -->
<!-- Corrections                                                            -->
<!-- ====================================================================== -->

<xsl:template match="unclear">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="sic">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="add">
  <xsl:apply-templates/>
</xsl:template>

<!-- ====================================================================== -->
<!-- Misc                                                            -->
<!-- ====================================================================== -->

<xsl:template match="mentioned">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="rs">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
