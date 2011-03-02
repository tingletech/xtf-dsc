<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:dc="http://purl.org/dc/elements/1.1/" 
                              xmlns:mets="http://www.loc.gov/METS/"
                              xmlns:xlink="http://www.w3.org/TR/xlink" 
                              xmlns:xs="http://www.w3.org/2001/XMLSchema"
                              xmlns:parse="http://cdlib.org/parse" 
                              xmlns:session="java:org.cdlib.xtf.xslt.Session" 
   xmlns:saxon="http://saxon.sf.net/"
   xmlns:freeformQuery="java:org.cdlib.xtf.xslt.FreeformQuery"
   extension-element-prefixes="session freeformQuery"
                              exclude-result-prefixes="xsl dc mets xlink xs parse">

<!-- ====================================================================== -->
<!-- Output Parameters                                                      -->
<!-- ====================================================================== -->
   
  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>
  
<!-- ====================================================================== -->
<!-- Global parameters (specified in the URL)                               -->
<!-- ====================================================================== -->
  
  <!-- style param -->
  <xsl:param name="style" select="'oac4'"/>
  
  <!-- brand mode -->
  <xsl:param name="brand"/>

  <!-- sort mode -->
  <xsl:param name="sort" select="'relevance'"/>
  <xsl:variable name="sortString">
	<xsl:choose>
		<xsl:when test="lower-case($sort)='title'">
			<xsl:text>sort-title</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>relevance</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:variable>
  
  <!-- raw XML dump flag -->
  <xsl:param name="raw" select="'1'"/>

  <xsl:param name="page" as="xs:integer" select="1"/>

  <!-- documents per page -->
  <xsl:param name="docsPerPage" as="xs:integer">
        <xsl:value-of select="20"/>
  </xsl:param>
  
  <!-- first hit on page -->
  <xsl:param name="startDoc" as="xs:integer" select="(($page - 1 ) * $docsPerPage) + 1"/>

  <!-- mode trigger parameters -->
  <xsl:param name="titlesAZ"/>
  <xsl:param name="autocomplete"/>
  <xsl:param name="facetcomplete"/>
  <xsl:param name="contributing"/>
  <xsl:param name="Institution"/>
  <xsl:param name="getDescription"/>
  <xsl:param name="map"/>
  <xsl:param name="ff"/>
  <xsl:param name="relation"/>
  <xsl:param name="limit"/>

  <!-- list of keyword search fields -->
  <xsl:param name="fieldList" select="'text title creator subject description publisher contributor date type format identifier source language relation coverage rights year'"/>
  
<!-- ====================================================================== -->
<!-- Local parameters                                                       -->
<!-- ====================================================================== -->

  <!-- browsing parameters -->
  <!-- xsl:param name="facet" select="'oac4-tab'"/ -->
  <xsl:param name="rmode"/>
  <xsl:param name="group" select="if ($rmode = 'oac' or  $style='oac-img' or $style='oac-tei') then 'Items' else ('Collections')"/>
  <xsl:param name="viewAll"/>
  <xsl:param name="view5"/>
  <xsl:param name="institution"/> 
  <xsl:param name="decade"/>
  <xsl:param name="facet-subject"/>
  <xsl:param name="facet-coverage"/>
  <xsl:param name="onlineItems"/>
  <xsl:param name="id"/>
  <xsl:param name="idT"/>
  <xsl:param name="fI-ignore" select="'value'"/>
  <xsl:param name="fD-ignore" select="'value'"/>
  
  <xsl:param name="endDoc" as="xs:integer" select="($startDoc + $docsPerPage)-1"/>
  <xsl:param name="docRange">
    <xsl:if test="$docsPerPage > 0">
       <xsl:value-of select="concat('#',$startDoc,'-',$endDoc)"/>  
    </xsl:if>
  </xsl:param>
  
  <!-- group sorting -->
  <xsl:param name="sortGroupsBy" select="'value'"/>
  
  <!-- doc sorting -->
  <xsl:param name="sortDocsBy"/>

  <xsl:param name="type"/>
	
  <xsl:variable name="strQuery" select="replace(lower-case(/parameters/param[@name='query']/@value),'(.*\w)-(\w.*)','$1 $2')"/>
  
<!-- ====================================================================== -->
<!-- Root Template                                                          -->
<!-- ====================================================================== -->
<!-- main MAIN -->
  <xsl:template match="/" >
	<xsl:choose>
		<!-- ModsView return colleciton view page -->
		<!-- view a single MODS record for a collection -->
		<xsl:when test="$id or $idT">
			<xsl:apply-templates select="." mode="ModsView"/>
		</xsl:when>

		<!-- viewAll returns xml/html div -->
		<!-- single facet AJAX -->
		<xsl:when test="$viewAll">
			<xsl:apply-templates select="." mode="viewAll"/>
		</xsl:when>

		<!-- limitF return xml/html div -->
		<!-- overview of all facet limits -->
		<xsl:when test="$style='oac4L'">
			<xsl:apply-templates select="." mode="limitF"/>
		</xsl:when>
		
		<!-- Institution view by label -->
		<xsl:when test="$Institution != '' and not($autocomplete != '')">
			<xsl:apply-templates select="." mode="institutionView"/>
		</xsl:when>

		<!-- for titlesAZ pages -->
		<xsl:when test="$titlesAZ != ''">
			<xsl:apply-templates select="." mode="titlesAZ"/>
		</xsl:when>

		<!-- for titlesAZ autocomplete -->
		<xsl:when test="$autocomplete != ''">
			<xsl:apply-templates select="." mode="autocomplete"/>
		</xsl:when>

		<!-- for subject/coverage autocomplete -->
		<xsl:when test="$facetcomplete != ''">
			<xsl:apply-templates select="." mode="facetcomplete"/>
		</xsl:when>

		<!-- double listed institutions -->
		<xsl:when test="$contributing != ''">
			<xsl:apply-templates select="." mode="double"/>
		</xsl:when>

		<!-- for "Read More" link on descriptions -->
		<xsl:when test="$getDescription != ''">
			<xsl:apply-templates select="." mode="getDescription"/>
		</xsl:when>

		<!-- search items attached to a finding aid -->
		<xsl:when test="$style='attached' or $style='carousel'">
			<xsl:apply-templates select="." mode="attached"/>
		</xsl:when>

		<!-- resultF the main search results query -->
		<xsl:otherwise>
			<xsl:apply-templates select="." mode="resultF"/>
		</xsl:otherwise>

	</xsl:choose>
  </xsl:template>

  <xsl:template match="/" mode="institutionView"> <!-- Instutution -->

    	<xsl:variable name="stylesheet" select="if ($map = 'map') then 'style/crossQuery/resultFormatter/oac4/ssi-institutions.xsl' else 'style/crossQuery/resultFormatter/oac4/institutionFormatter.xsl'"/>
       	<query indexPath="index" termLimit="1000" workLimit="20000000"
                style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="0" normalizeScores="false" 
		sortDocsBy="sort-title">
	<facet field="institution-doublelist" select="**" sortGroupsBy="value"/>
	<facet field="facet-onlineItems" select="*"/>
	<facet field="oac4-tab" select="**"/>
	<!-- facet field="facet-subject" select="**"/ -->
	<facet field="facet-institution" select="**" sortGroupsBy="value"/>

	<xsl:variable name="howMany">
		<xsl:choose>
			<xsl:when test="starts-with($Institution,'UC') 
						and not(contains($Institution,'::'))
						and not(contains($Institution,'Merced'))
			">
				<xsl:text>*</xsl:text>
			</xsl:when>
			<xsl:when test="starts-with($Institution,'UC Berkeley::Bancroft') or $Institution='Hoover Institution'">
				<xsl:value-of select="if ($titlesAZ) then upper-case($titlesAZ) else 'A'"/>
				<xsl:text>#all</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>*#all</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- facet field="facet-titlesAZ" select="*#1-500" sortGroupsBy="value" sortDocsBy="sort-title"/ -->
	<xsl:choose>
	  	<xsl:when test="$limit='ead'">
			<facet field="facet-titlesAZ-limit" select="ead::*#all" 
				sortGroupsBy="value" sortDocsBy="sort-title"/>
		</xsl:when>
	  	<xsl:when test="$limit='online'">
			<facet field="facet-titlesAZ-limit" select="online::*#all" 
				sortGroupsBy="value" sortDocsBy="sort-title"/>
		</xsl:when>
	  	<xsl:when test="$limit='marc'">
			<facet field="facet-titlesAZ-limit" select="marc::{$howMany}" 
				sortGroupsBy="value" sortDocsBy="sort-title"/>
		</xsl:when>
		<xsl:otherwise>
			<facet field="facet-titlesAZ" select="{$howMany}" 
				sortGroupsBy="value" sortDocsBy="sort-title"/>
		</xsl:otherwise>
	</xsl:choose>
		<and maxSnippets="0">
		<and field="oac4-tab">
		<term>Collections::*</term>
		</and>
                	<and field="institution-doublelist"><term><xsl:value-of 
		select="concat(
				substring($Institution,1,1),
				'::',
				$Institution,'*')"/></term></and>
		</and>
	</query>
  </xsl:template>
  <xsl:template match="/" mode="double">
    	<xsl:variable name="stylesheet" select="if ($contributing != 'map') then 'style/crossQuery/resultFormatter/oac4/html-institutions.xsl' else 'style/crossQuery/resultFormatter/oac4/ssi-institutions.xsl'"/>
       	<query indexPath="index" termLimit="1000" workLimit="20000000"
                style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="0" normalizeScores="false">
	<facet field="institution-doublelist" select="**" sortGroupsBy="value"/>
	<facet field="facet-subject" select="*"/>
	<and maxSnippets="0">
                <and field="oac4-tab"><term>Collections::*</term></and>
	</and>
	</query>
  </xsl:template>

  <xsl:template match="/" mode="getDescription">
    	<xsl:variable name="stylesheet" select="'style/crossQuery/resultFormatter/oac4/descriptionFormatter.xsl'"/>
       	<query indexPath="index" termLimit="1000" workLimit="20000000"
                style="{$stylesheet}" startDoc="1" maxDocs="1" normalizeScores="false">
	<or>
		<and field="identifier">
			<xsl:apply-templates select="parameters/param[@name='getDescription']/token"/>
		</and>
		<and field="id">
			<xsl:apply-templates select="parameters/param[@name='getDescription']/token"/>
		</and>
	</or>
	</query>
  </xsl:template>

  <xsl:template match="/" mode="facetcomplete">
    	<xsl:variable name="stylesheet" select="'style/crossQuery/resultFormatter/oac4/autoFormatter.xsl'"/>
	<xsl:variable name="parsed" select="if ($strQuery) then freeformQuery:parse($strQuery) else parameters"/>
       	<query indexPath="index" termLimit="1000" workLimit="20000000"
                style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="0" normalizeScores="false">
	<facet field="facet-{$facetcomplete}" select="*[1-10000]" />
	<and maxSnippets="0">
	<and field="oac4-tab"><term><xsl:text>*::*</xsl:text></term></and>
		<xsl:apply-templates select="$parsed/query/*" mode="freeform"/>
	<xsl:if test="$Institution != ''">
                        <and field="institution-doublelist"><term><xsl:value-of select="concat(
                                substring($Institution,1,1),
                                '::',
                                $Institution,'*')"/></term></and>
	</xsl:if>
			<xsl:apply-templates select="parameters"/>
	</and>
	</query>
  </xsl:template>

  <xsl:template match="/" mode="autocomplete">
    	<xsl:variable name="stylesheet" select="'style/crossQuery/resultFormatter/oac4/autoFormatter.xsl'"/>
       	<query indexPath="index" termLimit="1000" workLimit="20000000"
                style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="20" normalizeScores="false">
	<and maxSnippets="0">
                <and field="oac4-tab"><term>Collections::*</term></and>
		<and field="title">
		<xsl:apply-templates select="parameters/param[@name='query']/token" 
			mode="autotitle"/></and>
	<xsl:if test="$Institution != ''">
                        <and field="institution-doublelist"><term><xsl:value-of select="concat(
                                substring($Institution,1,1),
                                '::',
                                $Institution,'*')"/></term></and>
	</xsl:if>
	</and>
	</query>
  </xsl:template>

  <xsl:template match="token[position()=last()]" mode="autotitle">
	<xsl:variable name="value">
		<xsl:value-of select="@value"/>
		<xsl:text>*</xsl:text>
	</xsl:variable>
	<or>
	<near slop="13"><term><xsl:value-of select="$value"/></term></near>
	<near slop="13"><term><xsl:value-of select="@value"/></term></near>
	</or>
  </xsl:template>

  <xsl:template match="token" mode="autotitle">
	<term><xsl:value-of select="@value"/></term>
  </xsl:template>

  <xsl:template match="/" mode="attached">
    	<xsl:variable 
		name="stylesheet" 
		select="if ($style='carousel') 
			then 'style/crossQuery/resultFormatter/oac4/carousel.xsl'
			else ('style/crossQuery/resultFormatter/oac4/attached.xsl')
		"
	/>
	<xsl:variable name="parsed" select="if ($strQuery) then freeformQuery:parse($strQuery) else parameters"/>

       	<query indexPath="index" termLimit="1000" workLimit="20000000"
                style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="20" normalizeScores="false">
	<facet field="facet-collection-order" select="{$relation}::*" sortGroupsBy="value"/>
	<and maxSnippets="0">
                <and field="oac4-tab"><term>Items::*</term></and>
		<and field="relation"><xsl:apply-templates select="parameters/param[@name='relation']/token"/></and>
		<xsl:apply-templates select="$parsed/query/*" mode="freeform"/>
	</and>
	</query>
  </xsl:template>

  <xsl:template match="/" mode="titlesAZ">
    	<xsl:variable name="stylesheet" select="'style/crossQuery/resultFormatter/oac4/titlesFormatter.xsl'"/>
        <xsl:variable name="parsed" select="if ($strQuery) then freeformQuery:parse($strQuery) else parameters"/>


       <query indexPath="index" termLimit="1000" workLimit="20000000"
                style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="0" normalizeScores="false">
                <!-- spellcheck suggestionsPerTerm="1"/ -->
                <!-- facet field="oac4-tab" sortGroupsBy="value" includeEmptyGroups="yes" sortDocsBy="relevance"
                        select="**|{$group}#1-15"/ -->
                <facet field="facet-titlesAZ" select="{upper-case($titlesAZ)}#all" sortGroupsBy="value" 
			sortDocsBy="sort-title"/>
                <!-- facet field="facet-subject" select="*[1-10]"/ -->
                <!-- facet field="facet-creator" select="*[1-10]"/ -->
                <and>
                        <!-- and field="oac4-tab"><term><xsl:value-of select="$group"/><xsl:text>*</xsl:text></term></and -->
                        <xsl:variable name="wtf">
                        <term><xsl:value-of select="$group"/><xsl:text>*</xsl:text></term>
                        </xsl:variable>
                        <and field="oac4-tab"><term><xsl:value-of select="$wtf"/></term></and>
                        <xsl:apply-templates select="$parsed/query/*" mode="freeform"/>
                        <xsl:if test="$decade">
                                <and field="facet-decade"><term><xsl:value-of select="$decade"/></term></and>
                        </xsl:if>
                        <xsl:if test="$institution">
                                <and field="facet-institution"><term><xsl:value-of select="$institution"/></term></and>
                        </xsl:if>
                        <xsl:if test="$onlineItems">
                                <and field="facet-onlineItems"><term><xsl:value-of select="$onlineItems"/></term></and>
                        </xsl:if>
                </and>
        </query>



  </xsl:template>

  <xsl:template match="/" mode="ModsView">
    	<xsl:variable name="stylesheet" select="'style/crossQuery/resultFormatter/oac4/modsFormatter.xsl'"/>
	<xsl:variable name="idQuery" select="parameters/param[@name='id' or @name='idT']"/>
    	<query indexPath="index" termLimit="1000" workLimit="20000000" 
		style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="1" normalizeScores="false">
		<!-- and field="id"><term><xsl:value-of select="$id"/></term></and -->
		<and>
			<and field="oac4-tab" maxSnippets="0"><term>*</term></and>
			<!-- xsl:apply-templates select="$idQuery"/ -->
			<and field="id" maxSnippets="0"><term><xsl:value-of select="replace($idQuery/@value,'\|','*')"/></term></and>
		</and>
    	</query>
  </xsl:template>


  <xsl:template match="/" mode="resultF">
    	<xsl:variable name="stylesheet" select="'style/crossQuery/resultFormatter/oac4/resultFormatter.xsl'"/>
	<xsl:variable name="parsed" select="if ($strQuery) then freeformQuery:parse($strQuery) else parameters"/>
    	<query indexPath="index" termLimit="1000" workLimit="20000000" 
		style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="0" normalizeScores="false">
      		<spellcheck suggestionsPerTerm="1"/>
      		<facet field="oac4-tab" sortGroupsBy="value" includeEmptyGroups="yes" sortDocsBy="{$sortString}" 
			select="**|{$group}#{$startDoc}-{$endDoc}"/> 

			<!-- select="**|{$group}#{$startDoc}-{$endDoc}"/> --><!-- only one level of tabs -->
      		<!-- facet field="facet-institution" select="**"> 
				<xsl:if test="not(parameters/param[@name='query'])">
					<xsl:attribute name="sortGroupsBy" select="'value'"/>
				</xsl:if>
      		</facet -->
		<and>
			<and field="oac4-tab"><term>*</term></and>
			<xsl:apply-templates select="$parsed/query/*" mode="freeform"/>
			<xsl:if test="$decade">
				<and field="facet-decade"><term><xsl:value-of select="$decade"/></term></and>
			</xsl:if>
			<xsl:if test="$institution">
				<and field="facet-institution"><term><xsl:value-of select="$institution"/></term></and>
			</xsl:if>
			<xsl:if test="$facet-subject">
				<and field="facet-subject"><term><xsl:value-of select="replace($facet-subject,'&amp;',' ')"/></term></and>
			</xsl:if>
			<xsl:if test="$facet-coverage">
				<and field="facet-coverage"><term><xsl:value-of select="$facet-coverage"/></term></and>
			</xsl:if>
			<xsl:if test="$onlineItems">
				<and field="facet-onlineItems"><term><xsl:value-of select="$onlineItems"/></term></and>
			</xsl:if>
			<xsl:apply-templates select="parameters"/>
		</and>
    	</query>
  </xsl:template>

  <xsl:template match="/" mode="limitF">
    	<xsl:variable name="stylesheet" select="'style/crossQuery/resultFormatter/oac4/limitFormatter.xsl'"/>
	<xsl:variable name="parsed" select="if ($strQuery) then freeformQuery:parse($strQuery) else parameters"/>
    	<query indexPath="index" termLimit="1000" workLimit="20000000" 
		style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="0" normalizeScores="false">
      		<facet field="facet-institution" select="**[1-5]" sortGroupsBy="{$fI-ignore}"> 
      		</facet>
      		<!-- facet field="facet-collection-title" select="**[1-5]" sortGroupsBy="{$fI-ignore}"> 
      		</facet -->
		<xsl:choose>
			<xsl:when test="$decade ne ''">
				<facet field="facet-decade" select="{$decade}" sortGroupsBy="value"/>
			</xsl:when>
			<xsl:otherwise>
				<facet field="facet-decade" select="*[1-5]" sortGroupsBy="{$fD-ignore}"/>
			</xsl:otherwise>
		</xsl:choose>
      		<facet field="facet-onlineItems" select="*"/>
		<xsl:choose>
			<xsl:when test="$facet-subject ne ''">
				<xsl:variable name="q1">&quot;</xsl:variable>
				<xsl:variable name="q2">\\&quot;</xsl:variable>
				<xsl:variable name="q3">&amp;</xsl:variable>
				<xsl:variable name="q4">*</xsl:variable>
				<facet field="facet-subject" select='"{replace($facet-subject,$q1,$q2)}"' sortGroupsBy="value"/>
			</xsl:when>
			<xsl:otherwise>
      				<facet field="facet-subject" select="*[1-5]" sortGroupsBy="{$fI-ignore}"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="$facet-coverage ne ''">
				<facet field="facet-coverage" select='"{$facet-coverage}"' sortGroupsBy="value"/>
			</xsl:when>
			<xsl:otherwise>
      				<facet field="facet-coverage" select="*[1-5]" sortGroupsBy="{$fI-ignore}"/>
			</xsl:otherwise>
		</xsl:choose>



		<and>
			<xsl:variable name="wtf">
			<term><xsl:value-of select="$group"/><xsl:text>*</xsl:text></term>
			</xsl:variable>
			<and field="oac4-tab"><term><xsl:value-of select="$wtf"/></term></and>

                        <xsl:apply-templates select="$parsed/query/*" mode="freeform"/>
			<xsl:if test="$decade">
				<and field="facet-decade"><term><xsl:value-of select="$decade"/></term></and>
			</xsl:if>
			<xsl:if test="$institution">
				<and field="facet-institution"><term><xsl:value-of select="$institution"/></term></and>
			</xsl:if>
                        <xsl:if test="$facet-subject">
                                <and field="facet-subject"><term><xsl:value-of select="$facet-subject"/></term></and>
                        </xsl:if>
                        <xsl:if test="$facet-coverage">
                                <and field="facet-coverage"><term><xsl:value-of select="$facet-coverage"/></term></and>
                        </xsl:if>
			<xsl:if test="$onlineItems">
				<and field="facet-onlineItems"><term><xsl:value-of select="$onlineItems"/></term></and>
			</xsl:if>
			<xsl:apply-templates select="parameters"/>
		</and>
    	</query>
  </xsl:template>
  <xsl:template match="/" mode="viewAll">
    	<xsl:variable name="stylesheet" select="'style/crossQuery/resultFormatter/oac4/limitFormatter.xsl'"/>
	<xsl:variable name="parsed" select="if ($strQuery) then freeformQuery:parse($strQuery) else parameters"/>
    	<query indexPath="index" termLimit="1000" workLimit="20000000" 
		style="{$stylesheet}" startDoc="{$startDoc}" maxDocs="0" normalizeScores="false">
		<xsl:variable name="depthMode" select="if ($viewAll = 'facet-coverage' or $viewAll='facet-subject') then ('*') else ('**')"/>
      		<facet field="{$viewAll}" select="{$depthMode}{if ($view5) then '[1-5]' else ''}" 
			sortGroupsBy="{if ($viewAll = 'facet-institution') then $fI-ignore else ($fD-ignore)}"/>
		<and>
			<xsl:variable name="wtf">
			<term><xsl:value-of select="$group"/><xsl:text>*</xsl:text></term>
			</xsl:variable>
			<and field="oac4-tab"><term><xsl:value-of select="$wtf"/></term></and>
			<xsl:apply-templates select="$parsed/query/*" mode="freeform"/>
			<xsl:if test="$decade">
				<and field="facet-decade"><term><xsl:value-of select="$decade"/></term></and>
			</xsl:if>
			<xsl:if test="$institution">
				<and field="facet-institution"><term><xsl:value-of select="$institution"/></term></and>
			</xsl:if>
 			<xsl:if test="$facet-subject">
                                <and field="facet-subject"><term><xsl:value-of select="$facet-subject"/></term></and>
                        </xsl:if>
                        <xsl:if test="$facet-coverage">
                                <and field="facet-coverage"><term><xsl:value-of select="$facet-coverage"/></term></and>
                        </xsl:if>

			<xsl:if test="$onlineItems">
				<and field="facet-onlineItems"><term><xsl:value-of select="$onlineItems"/></term></and>
			</xsl:if>
			<xsl:apply-templates select="parameters"/>
		</and>
    	</query>
  </xsl:template>

  <xsl:template match="phrase[@field='serverChoice']" mode="freeform">
	<and>
	<xsl:attribute name="fields" select="'text title creator subject description publisher contributor date type format identifier source language relation coverage rights year'"/>
	<xsl:attribute name="slop" select="'10'"/>
	<xsl:attribute name="maxTextSnippets" select="'3'"/>
	<xsl:attribute name="maxMetaSnippets" select="'3'"/>
		<phrase><xsl:copy-of select="term"/></phrase>
	</and>
  </xsl:template>

  <xsl:template match="term[@field='serverChoice']" mode="freeform">
	<and>
	<xsl:attribute name="fields" select="'text title creator subject description publisher contributor date type format identifier source language relation coverage rights year'"/>
	<xsl:attribute name="slop" select="'10'"/>
	<xsl:attribute name="maxTextSnippets" select="'3'"/>
	<xsl:attribute name="maxMetaSnippets" select="'3'"/>
		<term><xsl:value-of select="."/></term>
	</and>
  </xsl:template>
	<!-- slop="10" maxTextSnippets="2" maxMetaSnippets="all" -->

  <xsl:template match="@field" mode="freeform">
	<xsl:attribute name="field" select="."/>
	<!-- xsl:attribute name="slop" select="'10'"/>
	<xsl:attribute name="maxTextSnippets" select="'2'"/>
	<xsl:attribute name="maxMetaSnippets" select="'2'"/ -->
  </xsl:template>

  <xsl:template match="@field[.='serverChoice']" mode="freeform">
	<xsl:attribute name="fields" select="'text title creator subject description publisher contributor date type format identifier source language relation coverage rights year'"/>
	<xsl:attribute name="slop" select="'10'"/>
	<xsl:attribute name="maxTextSnippets" select="'2'"/>
	<xsl:attribute name="maxMetaSnippets" select="'2'"/>
  </xsl:template>

  <xsl:template match="allDocs" mode="freeform"/>

  <xsl:template match="node()|@*" mode="freeform">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="freeform"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="term[not(text())]" mode="freeform">
  </xsl:template>

  <xsl:template match="parameters">

    <!-- Scan for non-empty parameters (but skip "-exclude", "-join", "-prox", "-max", and "-ignore") -->
    <xsl:variable name="queryParams" select="param[count(*) &gt; 0 and not(matches(@name, '.*-exclude')) 
                                                                   and not(matches(@name, '.*-join')) 
                                                                   and not(matches(@name, '.*-prox')) 
                                                                   and not(matches(@name, '.*-max')) 
                                                                   and not(matches(@name, '.*-add')) 
                                                                   and not(matches(@name, '.*-ignore'))]"/>

    <!-- Find the full-text query, if any -->
    <xsl:variable name="textParam" select="$queryParams[matches(@name, 'text|query')]"/>
    
    <!-- Find the meta-data queries, if any -->

    <xsl:variable name="metaParams" select="$queryParams[not(matches(@name, 'text*|query*|ff|style|decade|institution|view|view5|viewAll|onlineItems|developer|page|smode|rmode|brand|sort|startDoc|docsPerPage|sectionType|facet|group|sortGroupsBy|sortDocsBy|^x$|^y$|.*-ignore'))]"/>
    
    <and>
      <!-- Process the meta-data queries, if any -->
      <xsl:if test="count($metaParams) &gt; 0">
        <xsl:apply-templates select="$metaParams"/>
      </xsl:if>       
      <!-- Process the text query, if any -->
      <xsl:if test="count($textParam) &gt; 0">
        <xsl:apply-templates select="$textParam"/>
      </xsl:if>         
      <!-- Unary Not -->
      <xsl:for-each select="param[contains(@name, '-exclude')]">
        <xsl:variable name="field" select="replace(@name, '-exclude', '')"/>
        <xsl:if test="not(//param[@name=$field])">
          <not field="{$field}">
            <xsl:apply-templates/>
          </not>
        </xsl:if>
      </xsl:for-each>
      <!-- If there are no meta, text queries, or unary nots, output a dummy -->
      <!-- xsl:if test="count($metaParams) = 0 and count($textParam) = 0 and not(param[matches(@name, '.*-exclude')])">
        <term field="text">$!@$$@!$</term>
      </xsl:if -->
    </and>

  </xsl:template>

  
<!-- ====================================================================== -->
<!-- Single-field parameter template                                        -->
<!--                                                                        -->
<!-- Join all the terms of a single text or meta-data query together. For   -->
<!-- meta-data queries, we must also specify the field to search in.        -->
<!-- ====================================================================== -->
  
  <xsl:template match="param">
    
    <xsl:variable name="metaField" select="@name"/>
    
    <xsl:variable name="exclude" select="//param[@name=concat($metaField, '-exclude')]"/>
    <xsl:variable name="join" select="//param[@name=concat($metaField, '-join')]"/>
    <xsl:variable name="prox" select="//param[@name=concat($metaField, '-prox')]"/>
    <xsl:variable name="max" select="//param[@name=concat($metaField, '-max')]"/>
          <!-- To support Calipshere additive search -->
    <xsl:variable name="add" select="//param[@name=concat($metaField, '-add')]"/>
    
    <xsl:variable name="op">
      <xsl:choose>
        <xsl:when test="$max/@value != ''">
          <xsl:value-of select="'range'"/>
        </xsl:when>       
        <xsl:when test="$prox/@value != ''">
          <xsl:value-of select="'near'"/>
        </xsl:when>
        <xsl:when test="$join/@value != ''">
          <xsl:value-of select="$join/@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'and'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- 'and' all the terms together, unless "<field>-join" specifies a
       different operator (like 'or'). In the simple case when there's 
       only one term, the query processor optimizes this out, so it's 
       harmless. -->
    <xsl:element name="{$op}">
      
      <!-- Specify the field name for meta-data queries -->
        <xsl:choose>
            <xsl:when test="not(matches(@name, 'text|query|keyword'))">
                <xsl:attribute name="field" select="$metaField"/>
            </xsl:when>
            <xsl:when test="matches(@name, 'text')">
                <xsl:attribute name="field" select="'text'"/>
                <xsl:attribute name="maxSnippets" select="'2'"/>
                <xsl:attribute name="maxContext" select="'100'"/>
            </xsl:when>
            <xsl:when test="matches(@name, 'query')">
                <xsl:attribute name="fields" select="$fieldList"/>
                <xsl:attribute name="slop" select="'10'"/>
                <xsl:attribute name="maxTextSnippets" select="'2'"/>
                <xsl:attribute name="maxMetaSnippets" select="'all'"/>
            </xsl:when>
        </xsl:choose>
        
        <!-- Specify the maximum term separation for a proximity query -->
        <xsl:if test="$prox/@value != ''">
            <xsl:attribute name="slop" select="$prox/@value"/>
        </xsl:if>
        
        <!-- Process all the phrases and/or terms -->
        <xsl:apply-templates/>
        
        <!-- -add  -->
	<xsl:apply-templates select="//param[@name=concat($metaField, '-add')]/*"/>
        
        <!-- If there is an 'exclude' parameter for this field, process it -->
        <xsl:if test="$exclude/@value != ''">
            <not>
                <xsl:apply-templates select="$exclude/*"/>
            </not>
        </xsl:if>
        
    <!-- If there is a sectionType parameter, process it -->
    <xsl:if test="matches($metaField, 'text|query') and (//param[@name='sectionType']/@value != '')">
      <sectionType>
        <xsl:apply-templates select="//param[@name='sectionType']/*"/>
      </sectionType>
    </xsl:if>

    </xsl:element>
    
  </xsl:template>

<!-- ====================================================================== -->
<!-- Phrase template                                                        -->
<!--                                                                        -->
<!-- A phrase consists simply of several tokens.                            -->
<!-- ====================================================================== -->
  
  <xsl:template match="phrase">
    <phrase>
      <xsl:apply-templates/>
    </phrase>
  </xsl:template>
  
<!-- ====================================================================== -->
<!-- Token template                                                         -->
<!--                                                                        -->
<!-- Tokens form the basic search terms which make up all other types of    -->
<!-- queries. For simplicity, we disregard any "non-word" tokens (i.e.      -->
<!-- symbols such as "+", "&", etc.)                                        -->
<!-- ====================================================================== -->
  
  <xsl:template match="token[@isWord='yes']">
    
    <xsl:variable name="metaField" select="parent::*/@name"/>
    <xsl:variable name="max" select="//param[@name=concat($metaField, '-max')]"/>
   
    <xsl:choose>
      <xsl:when test="$max/@value != ''">
        <lower>
          <xsl:value-of select="@value"/>
        </lower>
        <upper>
          <xsl:value-of select="$max/@value"/>
        </upper>
      </xsl:when>
      <xsl:otherwise>       
        <term>
          <xsl:value-of select="@value"/>
        </term>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>

</xsl:stylesheet>
<!--
   Copyright (c) 2009, Regents of the University of California
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
