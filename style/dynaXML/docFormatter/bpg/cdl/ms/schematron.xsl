<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sch="http://www.ascc.net/xml/schematron" version="1.0">
   <axsl:template name="errors">
      <html>
         <style>
         a:link    { color: black}
         a:visited { color: gray}
         a:active  { color: #FF0088}
         h3        { background-color:black; color:white;
                     font-family:Arial Black; font-size:12pt; }
         h3.linked { background-color:black; color:white;
                     font-family:Arial Black; font-size:12pt; }
      </style>
         <h2 title="Schematron contact-information is at the end of                   this page">
            <font color="#FF0080">Schematron</font> Report
      </h2>
         <h1 title=" "/>
         <div class="errors">
            <ul>
               <h3>&lt;idno @type="ARK"&gt;</h3>
               <axsl:apply-templates select="/" mode="M0"/>
               <h3>Missing @id on &lt;divn&gt; elements</h3>
               <axsl:apply-templates select="/" mode="M1"/>
               <h3>Missing &lt;head&gt; elements</h3>
               <axsl:apply-templates select="/" mode="M2"/>
               <h3>Empty &lt;p&gt; Elements</h3>
               <axsl:apply-templates select="/" mode="M3"/>
               <h3>Invalid entity in rend="popup()"</h3>
               <axsl:apply-templates select="/" mode="M4"/>
               <h3>Improper &lt;list&gt; attribute combinations</h3>
               <axsl:apply-templates select="/" mode="M5"/>
               <h3>Document Structure</h3>
               <axsl:apply-templates select="/" mode="M6"/>
               <h3>&lt;ab&gt; and &lt;seg&gt;</h3>
               <axsl:apply-templates select="/" mode="M7"/>
            </ul>
         </div>
         <hr color="#FF0080"/>
      </html>
   </axsl:template>
   <axsl:template match="idno[@type='ARK']" priority="4000" mode="M0">
      <axsl:choose>
         <axsl:when test="(substring-after(normalize-space(.), 'ark:/13030/')) = (normalize-space(//TEI.2/@id))"/>
         <axsl:otherwise>
            <li>
               <xsl:variable name="anchor.id">
                  <xsl:value-of select="name()"/>
                  <xsl:text>-</xsl:text>
                  <xsl:number count="*" level="multiple"/>
               </xsl:variable>
               <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was expected">
         [error]: 
         The unique key of the ARK does not match TEI.2/@id<b/>
               </a>
            </li>
            <axsl:comment>error</axsl:comment>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates mode="M0"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M0"/>
   <axsl:template match="div1|div2|div3|div4|div5|div6|div7" priority="4000" mode="M1">
      <axsl:choose>
         <axsl:when test="@id"/>
         <axsl:otherwise>
            <li>
               <xsl:variable name="anchor.id">
                  <xsl:value-of select="name()"/>
                  <xsl:text>-</xsl:text>
                  <xsl:number count="*" level="multiple"/>
               </xsl:variable>
               <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was expected">
         [warning]: 
         This &lt;divn&gt; element is missing an ID attribute, which will prevent it from being listed in the table of contents.<b/>
               </a>
            </li>
            <axsl:comment>warning</axsl:comment>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates mode="M1"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M1"/>
   <axsl:template match="div1[not(head or @type='dedication')]|div2[not(head)]|div3[not(head)]|div4[not(head)]|div5[not(head)]|div6[not(head)]|div7[not(head)]" priority="4000" mode="M2">
      <axsl:if test="preceding-sibling::*[head]|following-sibling::*[head]">
         <li>
            <xsl:variable name="anchor.id">
               <xsl:value-of select="name()"/>
               <xsl:text>-</xsl:text>
               <xsl:number count="*" level="multiple"/>
            </xsl:variable>
            <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was found">
         [error]: 
         This &lt;divn&gt; element is missing a &lt;head&gt;, but has SIBLINGS that are not.<b/>
            </a>
         </li>
         <axsl:comment>error</axsl:comment>
      </axsl:if>
      <axsl:if test="descendant::div1[head]|descendant::div2[head]|descendant::div3[head]|descendant::div4[head]|descendant::div5[head]|descendant::div6[head]|descendant::div7[head]">
         <li>
            <xsl:variable name="anchor.id">
               <xsl:value-of select="name()"/>
               <xsl:text>-</xsl:text>
               <xsl:number count="*" level="multiple"/>
            </xsl:variable>
            <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was found">
         [error]: 
         This &lt;divn&gt; element is missing a &lt;head&gt;, but has CHILDREN that are not.<b/>
            </a>
         </li>
         <axsl:comment>error</axsl:comment>
      </axsl:if>
      <axsl:apply-templates mode="M2"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M2"/>
   <axsl:template match="p" priority="4000" mode="M3">
      <axsl:choose>
         <axsl:when test="normalize-space(.) or *"/>
         <axsl:otherwise>
            <li>
               <xsl:variable name="anchor.id">
                  <xsl:value-of select="name()"/>
                  <xsl:text>-</xsl:text>
                  <xsl:number count="*" level="multiple"/>
               </xsl:variable>
               <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was expected">
         [error]: 
         Empty &lt;p&gt; element<b/>
               </a>
            </li>
            <axsl:comment>error</axsl:comment>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates mode="M3"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M3"/>
   <axsl:template match="figure[contains(@rend, 'popup')]" priority="4000" mode="M4">
      <axsl:choose>
         <axsl:when test="unparsed-entity-uri(substring-before(substring-after(@rend, 'popup('), ')'))"/>
         <axsl:otherwise>
            <li>
               <xsl:variable name="anchor.id">
                  <xsl:value-of select="name()"/>
                  <xsl:text>-</xsl:text>
                  <xsl:number count="*" level="multiple"/>
               </xsl:variable>
               <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was expected">
         [error]: 
         Invalid entity in rend="popup()"<b/>
               </a>
            </li>
            <axsl:comment>error</axsl:comment>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates mode="M4"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M4"/>
   <axsl:template match="list[@type='bulleted' or @type='simple' or @type='gloss' or not(@type)]" priority="4000" mode="M5">
      <axsl:if test="@rend='arabic'">
         <li>
            <xsl:variable name="anchor.id">
               <xsl:value-of select="name()"/>
               <xsl:text>-</xsl:text>
               <xsl:number count="*" level="multiple"/>
            </xsl:variable>
            <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was found">
         [error]: 
         Only @type="ordered" may be used with @rend="arabic"<b/>
            </a>
         </li>
         <axsl:comment>error</axsl:comment>
      </axsl:if>
      <axsl:if test="@rend='upperalpha'">
         <li>
            <xsl:variable name="anchor.id">
               <xsl:value-of select="name()"/>
               <xsl:text>-</xsl:text>
               <xsl:number count="*" level="multiple"/>
            </xsl:variable>
            <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was found">
         [error]: 
         Only @type="ordered" may be used with @rend="upperalpha"<b/>
            </a>
         </li>
         <axsl:comment>error</axsl:comment>
      </axsl:if>
      <axsl:if test="@rend='loweralpha'">
         <li>
            <xsl:variable name="anchor.id">
               <xsl:value-of select="name()"/>
               <xsl:text>-</xsl:text>
               <xsl:number count="*" level="multiple"/>
            </xsl:variable>
            <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was found">
         [error]: 
         Only @type="ordered" may be used with @rend="loweralpha"<b/>
            </a>
         </li>
         <axsl:comment>error</axsl:comment>
      </axsl:if>
      <axsl:if test="@rend='upperroman'">
         <li>
            <xsl:variable name="anchor.id">
               <xsl:value-of select="name()"/>
               <xsl:text>-</xsl:text>
               <xsl:number count="*" level="multiple"/>
            </xsl:variable>
            <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was found">
         [error]: 
         Only @type="ordered" may be used with @rend="upperroman"<b/>
            </a>
         </li>
         <axsl:comment>error</axsl:comment>
      </axsl:if>
      <axsl:if test="@rend='lowerroman'">
         <li>
            <xsl:variable name="anchor.id">
               <xsl:value-of select="name()"/>
               <xsl:text>-</xsl:text>
               <xsl:number count="*" level="multiple"/>
            </xsl:variable>
            <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was found">
         [error]: 
         Only @type="ordered" may be used with @rend="lowerroman"<b/>
            </a>
         </li>
         <axsl:comment>error</axsl:comment>
      </axsl:if>
      <axsl:if test="@rend='supplied'">
         <li>
            <xsl:variable name="anchor.id">
               <xsl:value-of select="name()"/>
               <xsl:text>-</xsl:text>
               <xsl:number count="*" level="multiple"/>
            </xsl:variable>
            <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was found">
         [error]: 
         Only @type="ordered" may be used with @rend="supplied"<b/>
            </a>
         </li>
         <axsl:comment>error</axsl:comment>
      </axsl:if>
      <axsl:apply-templates mode="M5"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M5"/>
   <axsl:template match="body | back" priority="4000" mode="M6">
      <axsl:choose>
         <axsl:when test="div1"/>
         <axsl:otherwise>
            <li>
               <xsl:variable name="anchor.id">
                  <xsl:value-of select="name()"/>
                  <xsl:text>-</xsl:text>
                  <xsl:number count="*" level="multiple"/>
               </xsl:variable>
               <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was expected">
         [error]: 
         &lt;body&gt; must contain at least one &lt;div1&gt;<b/>
               </a>
            </li>
            <axsl:comment>error</axsl:comment>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates mode="M6"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M6"/>
   <axsl:template match="figure[@rend='block'] | table" priority="4000" mode="M7">
      <axsl:if test="(parent::*[not(name(.)='ab' or name(.)='seg')])                                     and                                     (not(preceding-sibling::*))                                     and                                     (not(following-sibling::*))">
         <li>
            <xsl:variable name="anchor.id">
               <xsl:value-of select="name()"/>
               <xsl:text>-</xsl:text>
               <xsl:number count="*" level="multiple"/>
            </xsl:variable>
            <a href="{$doc.path}&amp;doc.view=document&amp;anchor.id={$anchor.id}#X" target="document" title="Link to where this pattern was found">
         [warning]: 
         Did you mean to use &lt;ab&gt; or &lt;seg&gt; here?<b/>
            </a>
         </li>
         <axsl:comment>warning</axsl:comment>
      </axsl:if>
      <axsl:apply-templates mode="M7"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M7"/>
   <axsl:template match="text()" priority="-1"/>
   <axsl:template match="*|@*" mode="schematron-get-full-path">
      <axsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <axsl:text>/</axsl:text>
      <axsl:if test="count(. | ../@*) = count(../@*)">@</axsl:if>
      <axsl:value-of select="name()"/>
      <axsl:text>[</axsl:text>
      <axsl:value-of select="1+count(preceding-sibling::*[name()=name(current())])"/>
      <axsl:text>]</axsl:text>
   </axsl:template>
</axsl:stylesheet>