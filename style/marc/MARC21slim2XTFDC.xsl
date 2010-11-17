<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:marc="http://www.loc.gov/MARC21/slim" 
	xmlns:srw_dc="info:srw/schema/1/dc-schema" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://purl.org/dc/elements/1.1/" 
	xmlns:xtf="http://cdlib.org/xtf"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:sql="java:/net.sf.saxon.sql.SQLElementFactory" 
	xmlns:saxon="http://saxon.sf.net/"
        extension-element-prefixes="saxon sql"
	xmlns:parse="http://cdlib.org/xtf/parse"
        xmlns:decade="java:org.cdlib.dsc.util.FacetDecade"
	xmlns:Md5Hash="java:org.cdlib.dsc.util.Md5Hash"
	exclude-result-prefixes="marc Md5Hash">
	<xsl:import href="./MARC21slimUtils.xsl"/>
	<xsl:import href="./MARC21slim2MODS3.cdl.xsl"/>
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

	<!-- modification log 
	further mods not logged
source: http://www.loc.gov/standards/marcxml/xslt/MARC21slim2SRWDC.xsl
               JR 08/21/2007:   Fixed a couple of Dublin Core Links
	2006-12-11 ntra Fixed 500 fields.
	JR 05/05/06:  Updated the schemaLocation
	RG 10/07/05: Corrected subject subfields; 10/12/05: added if statement for <language>
	JR 09/05:  Added additional <subject> subfields and 651 for <coverage>
	JR 06/04:  Added ISBN identifier
	NT 01/04:  added collection level element
			and removed attributes   	
   	
-->
<xsl:variable name="HOME" select="System:getenv('HOME')" xmlns:System="java:java.lang.System"/>
<xsl:variable name="databases" select="document(concat($HOME,'/.databases.xml'))"/>
<xsl:variable name="db" select="$databases/databases/database[@name='default-ro']"/>
<xsl:param name="sqlConnect.database">
  <xsl:text>jdbc:mysql://</xsl:text>
  <xsl:value-of select="$db/host"/>
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$db/port"/>
  <xsl:text>/</xsl:text>
  <xsl:value-of select="$db/name"/>
</xsl:param>
<xsl:param name="sqlConnect.user" select="$db/user"/>
<xsl:param name="sqlConnect.password" select="$db/password"/>
<xsl:param name="sqlConnect.driver" select="'com.mysql.jdbc.Driver'"/>

	<xsl:template match="/">
		<xsl:apply-templates select="marc:record"/>
	</xsl:template>

  	<xsl:template match="decade" mode="decade">
        	<facet-decade xtf:meta="true" xtf:tokenize="no"><xsl:value-of select="."/></facet-decade>
  	</xsl:template>

	<xsl:template match="marc:datafield[@tag=245]" mode="sort-title">
		<xsl:variable name="titleText">
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">abfghk</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<sort-title xtf:meta="true" xtf:tokenize="false">
			<xsl:value-of select="parse:title($titleText)"/>
		</sort-title>

    <!-- facet-titlesAZ xtf:meta="true" xtf:tokenize="no">
        <xsl:variable name="firstChar" select="upper-case(substring(parse:title($titleText),1,1))"/>
        <xsl:value-of select="if (matches($firstChar,'[A-Z]')) then $firstChar else '0'"/>
    </facet-titlesAZ>
    <facet-titlesAZ-limit xtf:meta="true" xtf:tokenize="no">
	<xsl:text>marc::</xsl:text>
        <xsl:variable name="firstChar" select="upper-case(substring(parse:title($titleText),1,1))"/>
        <xsl:value-of select="if (matches($firstChar,'[A-Z]')) then $firstChar else '0'"/>
    </facet-titlesAZ-limit -->
	</xsl:template>
									
	<!-- main MAIN -->
	<xsl:template match="marc:record">

<!-- do sql stuff -->
<xsl:variable
              name="connection"
              xmlns:java="http://saxon.sf.net/java-type"
              as="java:java.sql.Connection"  >
  <!-- sql:connect database="jdbc:sqlite://findaid/developers/tingle/repodata.db"
              driver="SQLite.JDBCDriver"
              -->
  <sql:connect database="{$sqlConnect.database}"
	user="{$sqlConnect.user}" password="{$sqlConnect.password}"
	driver="com.mysql.jdbc.Driver">
   <xsl:fallback>
          <xsl:message terminate="yes">SQL extensions are not installed</xsl:message>
   </xsl:fallback>
  </sql:connect>
</xsl:variable>


                      <xsl:variable name="code">
<xsl:for-each select="marc:datafield[@tag=852][1]">
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">a</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">b</xsl:with-param>
        </xsl:call-template>
</xsl:for-each>
                        </xsl:variable>

<!-- a handful of hardcoded exceptions -->

<xsl:variable name="exceptional_institution_res">
<sql:query
        connection="$connection"
        table="oac_locationoverridedisplay"
        column="campus_name, primary_loc_display"
        where="mai_code_location = '{$code}'"
        row-tag="r" column-tag="c"
        />
</xsl:variable>

<xsl:variable name="exceptional_institution">
	<xsl:choose>
		<xsl:when test="$exceptional_institution_res/r/c[2] 
				and $exceptional_institution_res/r/c[2] != ''
		">
			<xsl:value-of select="$exceptional_institution_res/r/c[1]"/>
			<xsl:text>::</xsl:text>
			<xsl:value-of select="$exceptional_institution_res/r/c[2]"/>
		</xsl:when>
		<xsl:when test="$exceptional_institution_res/r/c[1] 
				and $exceptional_institution_res/r/c[1] != ''
		">
			<xsl:value-of select="$exceptional_institution_res/r/c[1]"/>
		</xsl:when>
		<xsl:otherwise/>
	</xsl:choose>
</xsl:variable>

<!-- look up the fisrt part in the location table from Melvyl -->

                        <xsl:variable name="campus_name">
<sql:query
        connection="$connection"
        table="oac_location"
        column="campus_name"
        where="mai_code_location = '{$code}'"
        row-tag="r" column-tag="c"
        />
                        </xsl:variable>

                        <xsl:variable name="primary_name">
<sql:query
        connection="$connection"
        table="oac_location"
        column="primary_name, notes, prefix"
        where="mai_code_location = '{$code}'"
        row-tag="r" column-tag="c"
        />
                        </xsl:variable>
                        <xsl:variable name="primary_loc_display">
<sql:query
        connection="$connection"
        table="oac_marcprimarynamedisplay"
        column="primary_loc_display, flag"
        where="campus_name = '{$campus_name/r/c[1]}' and primary_loc = '{$primary_name/r/c[1]}'"
        row-tag="r" column-tag="c"
        />
                        </xsl:variable>
        <sql:close connection="$connection"/>

<xsl:variable name="onDouble">
	<xsl:choose>
		<xsl:when test="
				$campus_name and $campus_name != '' 
				and not($primary_loc_display/r/c[2] = 'r')
				and ( 
					( $primary_loc_display and $primary_loc_display/r/c[1] != '' )
					or
					( contains($exceptional_institution,'::'))
				    )
		">
			<xsl:text>two</xsl:text>
		</xsl:when>
		<xsl:when test="($campus_name and $campus_name != '') or $exceptional_institution">
			<xsl:text>one</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>none</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="campus_name_text">
	<xsl:value-of select="	if ($exceptional_institution = '') 
				then replace(normalize-space($campus_name/r/c[1]),'^UC Los Angeles$','UCLA')
				else if (not(contains($exceptional_institution,'::'))) then $exceptional_institution
				else substring-before($exceptional_institution,'::') "/>
</xsl:variable>

<xsl:variable name="primary_name_note">
	<xsl:value-of select="$primary_name/r/c[2]"/>
</xsl:variable>

<xsl:variable name="primary_name_prefix">
	<xsl:value-of select="$primary_name/r/c[3]"/>
</xsl:variable>

<xsl:variable name="primary_loc_display_text">
	<xsl:value-of select="	if ($exceptional_institution = '')
				then normalize-space(replace($primary_loc_display/r/c[1],' &amp; ',' and '))
				else substring-after($exceptional_institution,'::') "/>
</xsl:variable>
<xsl:variable name="primary_loc_display_flag">
	<xsl:value-of select="$primary_loc_display/r/c[2]"/>
</xsl:variable>

<!-- whee, done with all the sql -->
<!-- xsl:if test="$primary_loc_display/r/c[2] = 'r'">
<xsl:message>
	<xsl:copy-of select="$primary_loc_display"/>
	<xsl:for-each select="marc:datafield[@tag=852][1]">

 <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">a</xsl:with-param>
        </xsl:call-template>
<xsl:text>::</xsl:text>        
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">b</xsl:with-param>
        </xsl:call-template>
</xsl:for-each>

</xsl:message>
</xsl:if -->

	<xsl:if test="($primary_loc_display_flag != 'r') and ( $campus_name_text != 'So. Regional Library Facility')">
	<xtf:meta>
		<xsl:variable name="leader" select="marc:leader"/>
		<xsl:variable name="leader6" select="substring($leader,7,1)"/>
		<xsl:variable name="leader7" select="substring($leader,8,1)"/>
		<xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>

		<!-- fake ID -->
		<xsl:variable name="fakeID" as="xs:string">
                             <xsl:value-of select="Md5Hash:md5Hash(/)"/>
		</xsl:variable>
                <id source="852" xtf:meta="true" xtf:tokenize="true">
                               <xsl:value-of select="$fakeID"/>
                </id>
                <idT source="852" xtf:meta="true" xtf:tokenize="false">
                               <xsl:value-of select="$fakeID"/>
                </idT>
	
<!-- spit out stuff from database for browse -->	
<facet-institution xtf:meta="true" xtf:facet="yes">
<xsl:choose>
	<xsl:when test="$onDouble = 'two'">
		<xsl:value-of select="$campus_name_text"/>
		<xsl:text>::</xsl:text>
		<xsl:value-of select="$primary_loc_display_text"/>
	</xsl:when>
	<xsl:when test="$onDouble = 'one'">
		<xsl:value-of select="$campus_name_text"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="$code"/>
	</xsl:otherwise>
</xsl:choose>
</facet-institution>

        <identifier q="call" xtf:meta="true">
                                <xsl:text>Collection Number: </xsl:text>

<xsl:choose>
	<xsl:when test="$campus_name_text = 'UC Berkeley' 
			and $primary_loc_display_text = 'Bancroft Library'">

<xsl:for-each select="marc:datafield[@tag=090][1]">
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">b</xsl:with-param>
        </xsl:call-template>
</xsl:for-each>

</xsl:when>
<xsl:otherwise>
<xsl:for-each select="marc:datafield[@tag=852][1]">
	<xsl:variable name="prefik">
        	<xsl:call-template name="subfieldSelect">
          	<xsl:with-param name="codes">k</xsl:with-param>
        	</xsl:call-template>
	</xsl:variable>
	<xsl:if test="$prefik !=''">
		<xsl:value-of select="$prefik"/>
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:if test="$primary_name_prefix != ''">
		<xsl:value-of select="$primary_name_prefix"/>
		<xsl:text> </xsl:text>
	</xsl:if>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">hij</xsl:with-param>
        </xsl:call-template>
</xsl:for-each>
	<xsl:if test="$primary_name_note != ''">
		<xsl:text> </xsl:text>
		<xsl:value-of select="$primary_name_note"/>
	</xsl:if>
</xsl:otherwise>
</xsl:choose>
        </identifier>

                        <!-- list parent first -->
<institution-doublelist xtf:meta="true" xtf:tokenize="false">
<xsl:choose>
	<xsl:when test="$onDouble = 'two'">
		<xsl:value-of select="substring(($campus_name_text),1,1)"/>
		<xsl:text>::</xsl:text>
		<xsl:value-of select="$campus_name_text"/>
		<xsl:text>::</xsl:text>
		<xsl:value-of select="$primary_loc_display_text"/>
	</xsl:when>
	<xsl:when test="$onDouble = 'one'">
		<xsl:value-of select="substring(($campus_name_text),1,1)"/>
		<xsl:text>::</xsl:text>
		<xsl:value-of select="$campus_name_text"/>
	</xsl:when>
</xsl:choose>
</institution-doublelist>
                        <!-- list grandparent first -->
<xsl:if test="$onDouble = 'two'">
<institution-doublelist xtf:meta="true" xtf:tokenize="false">
		<xsl:value-of select="substring(($primary_loc_display_text),1,1)"/>
		<xsl:text>::</xsl:text>
        	<xsl:value-of select="$primary_loc_display_text"/>
        	<xsl:text>,::</xsl:text>
        	<xsl:value-of select="$campus_name_text"/>
</institution-doublelist>
</xsl:if>

	<xsl:variable name="title245">
		<xsl:for-each select="marc:datafield[@tag=245][1]">
			<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abfghk</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="creator100">
		<xsl:for-each select="/marc:record/marc:datafield[@tag=100][1]">
			<!-- copied from the MARC -> MODS -->
                        <xsl:call-template name="chopPunctuation">
                                <xsl:with-param name="chopString">
                                        <xsl:call-template name="subfieldSelect">
                                                <xsl:with-param name="codes">aq</xsl:with-param>
                                        </xsl:call-template>
                                </xsl:with-param>
                                <xsl:with-param name="punctuation">
                                        <xsl:text>:,;/ </xsl:text>
                                </xsl:with-param>
                        </xsl:call-template>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="creator11x">
		<xsl:for-each select="(/marc:record/marc:datafield[@tag=110] 
					| /marc:record/marc:datafield[@tag=111])[1]">
			<xsl:call-template name="subfieldSelect"/>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable 
		name="normalTitle245" 
		select="lower-case(replace($title245,'[^(\w|\s)+]',''))"
	/>
	<!--	regex documentation [^(\w|\s)+]	things that are neither word chars nor spaces
	-->

<normalTitle245 xtf:meta="true">
	<xsl:value-of select="$normalTitle245"/>
</normalTitle245>

	<xsl:variable name="title">
		<xsl:choose>
			<!-- generic title; add in the creator -->
			<xsl:when test="
        starts-with($normalTitle245, 'addresses') or
        starts-with($normalTitle245, 'administrative') or
        starts-with($normalTitle245, 'agendas') or
        starts-with($normalTitle245, 'annual report') or
        starts-with($normalTitle245, 'annual reports') or
        starts-with($normalTitle245, 'archives') or
        starts-with($normalTitle245, 'brochures') or
        starts-with($normalTitle245, 'collected') or
        starts-with($normalTitle245, 'collection') or
        starts-with($normalTitle245, 'correspondence') or
        starts-with($normalTitle245, 'diaries') or
        starts-with($normalTitle245, 'diaro') or
        starts-with($normalTitle245, 'diary') or
        starts-with($normalTitle245, 'films') or
        starts-with($normalTitle245, 'letter') or
        starts-with($normalTitle245, 'manuscripts') or
        starts-with($normalTitle245, 'map') or
        starts-with($normalTitle245, 'miscellanea') or
        starts-with($normalTitle245, 'miscellaneous') or
        starts-with($normalTitle245, 'miscellanies') or
        starts-with($normalTitle245, 'notebooks') or
        starts-with($normalTitle245, 'pamphlets') or
        starts-with($normalTitle245, 'papers') or
        starts-with($normalTitle245, 'photographs') or
        starts-with($normalTitle245, 'plays') or
        starts-with($normalTitle245, 'poems') or
        starts-with($normalTitle245, 'poetry') or
        starts-with($normalTitle245, 'portfolio') or
        starts-with($normalTitle245, 'postcards') or
        starts-with($normalTitle245, 'publications') or
        starts-with($normalTitle245, 'records') or
        starts-with($normalTitle245, 'reports') or
        starts-with($normalTitle245, 'reprints') or
        starts-with($normalTitle245, 'scripts') or
        starts-with($normalTitle245, 'scrapbooks') or
        starts-with($normalTitle245, 'selected offprints') or
        starts-with($normalTitle245, 'yearbooks')"
			>
				<xsl:choose>
					<xsl:when test="$creator100 and $creator100 != ''">
						<xsl:value-of select="$creator100"/>
						<xsl:text> </xsl:text>
					</xsl:when>	
					<xsl:when test="$creator11x and $creator11x != ''">
						<xsl:value-of select="$creator11x"/>
						<xsl:text> </xsl:text>
					</xsl:when>	
					<xsl:otherwise>
						<!-- xsl:message>generic title <xsl:value-of select="$title245"/></xsl:message -->
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$title245"/>
			</xsl:when>
			<!-- title looks okay -->
			<xsl:otherwise>
				<xsl:value-of select="$title245"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<title xtf:meta="true"><xsl:value-of select="$title"/></title>

        <sort-title xtf:meta="true" xtf:tokenize="false">
        	<xsl:value-of select="parse:title($title)"/>
        </sort-title>

    	<facet-titlesAZ xtf:meta="true" xtf:tokenize="no">
        	<xsl:variable name="firstChar" select="upper-case(substring(parse:title($title),1,1))"/>
        	<xsl:value-of select="if (matches($firstChar,'[A-Z]')) then $firstChar else '0'"/>
    	</facet-titlesAZ>
    	<facet-titlesAZ-limit xtf:meta="true" xtf:tokenize="no">
		<xsl:text>marc::</xsl:text>
        	<xsl:variable name="firstChar" select="upper-case(substring(parse:title($title),1,1))"/>
        	<xsl:value-of select="if (matches($firstChar,'[A-Z]')) then $firstChar else '0'"/>
    	</facet-titlesAZ-limit>


		<!-- from here, it is pretty much LOC style -->

		<xsl:for-each select="marc:datafield[@tag=245][position()&gt;1]">
			<title xtf:meta="true">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abfghk</xsl:with-param>
				</xsl:call-template>
			</title>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=100]|marc:datafield[@tag=110]|marc:datafield[@tag=111]|marc:datafield[@tag=700]|marc:datafield[@tag=710]|marc:datafield[@tag=711]|marc:datafield[@tag=720]">
			<creator xtf:meta="true">
				<xsl:call-template name="subfieldSelect"/>
			</creator>
		</xsl:for-each>
		<xsl:if test="$leader7='c'">
			<oac4-tab xtf:meta="true" xtf:tokenize="false">Collections::marc</oac4-tab>
			<type xtf:meta="true">
				<xsl:text>archival collection</xsl:text>
			</type>
		</xsl:if>

		<xsl:if test="not($leader7='c')">
			<oac4-tab xtf:meta="true" xtf:tokenize="false">Items::offline</oac4-tab>
		</xsl:if>


			<xsl:if test="$leader6='d' or $leader6='f' or $leader6='p' or $leader6='t'">
				<!-- nt fix 1/04 -->
				<!--<xsl:attribute name="manuscript">yes</xsl:attribute> -->
		<type xtf:meta="true">
				<xsl:text>manuscript</xsl:text>
		</type>
			</xsl:if>

		<type xtf:meta="true">
			<xsl:choose>
				<xsl:when test="$leader6='a' or $leader6='t'">text</xsl:when>
				<xsl:when test="$leader6='e' or $leader6='f'">cartographic</xsl:when>
				<xsl:when test="$leader6='c' or $leader6='d'">notated music</xsl:when>
				<xsl:when test="$leader6='i' or $leader6='j'">sound recording</xsl:when>
				<xsl:when test="$leader6='k'">still image</xsl:when>
				<xsl:when test="$leader6='g'">moving image</xsl:when>
				<xsl:when test="$leader6='r'">three dimensional object</xsl:when>
				<xsl:when test="$leader6='m'">software, multimedia</xsl:when>
				<xsl:when test="$leader6='p'">mixed material</xsl:when>
			</xsl:choose>
		</type>

		<xsl:for-each select="marc:datafield[@tag=655]">
			<type xtf:meta="true">
				<xsl:value-of select="normalize-space(.)"/>
			</type>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=260]">
			<publisher xtf:meta="true">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ab</xsl:with-param>
				</xsl:call-template>
			</publisher>
		</xsl:for-each>
		<xsl:variable name="dates">
			<xsl:value-of select="marc:datafield[@tag=260]/marc:subfield[@code='c']"/>
		</xsl:variable>
		<xsl:variable name="decades">
			<xsl:copy-of select="decade:facetDecade($dates)"/>
		</xsl:variable>
		<xsl:if test="$decades != ''">
 		<xsl:apply-templates select="saxon:parse($decades)/decades/decade" mode="decade"/>
		</xsl:if>
		<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='c']">
			<date xtf:meta="true">
				<xsl:value-of select="."/>
			</date>
		</xsl:for-each>
		<xsl:if test="substring($controlField008,36,3)">
			<language xtf:meta="true">
				<xsl:value-of select="substring($controlField008,36,3)"/>
			</language>
		</xsl:if>		
		<xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='q']">
			<format xtf:meta="true">
				<xsl:value-of select="."/>
			</format>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=520]/marc:subfield[@code='a']">
			<description xtf:meta="true">
				<!-- nt fix 01/04 -->
				<!-- xsl:value-of select="normalize-space(marc:subfield[@code='a'])"/ -->
				<xsl:value-of select="."/>
			</description>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=521]">
			<description xtf:meta="true">
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</description>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[500 &lt;= number(@tag) and number(@tag) &lt;= 599][not(@tag=506 or @tag=530 or @tag=540 or @tag=546)]">
			<description xtf:meta="true">
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</description>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=600]">
			<subject xtf:meta="true">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdefghjklmnopqrstu4</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">
				<xsl:text>--</xsl:text>
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">vxyz</xsl:with-param>
					<xsl:with-param name="delimeter">--</xsl:with-param>
				</xsl:call-template>
				</xsl:if>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=610]">
			<subject xtf:meta="true">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdefghklmnoprstu4</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=611]">
			<subject xtf:meta="true">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">acdefghklnpqstu4</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=630]">
			<subject xtf:meta="true">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">adfghklmnoprst</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=650]">
			<subject xtf:meta="true">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ae</xsl:with-param></xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=653]">
			<subject xtf:meta="true">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">a</xsl:with-param>
				</xsl:call-template>
			</subject>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=651]">
			<coverage xtf:meta="true">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">a</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="marc:subfield[@code='v' or @code='x' or @code='y' or
					@code='z']">
					<xsl:text>--</xsl:text>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">vxyz</xsl:with-param>
						<xsl:with-param name="delimeter">--</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</coverage>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=752]">
			<coverage xtf:meta="true">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcd</xsl:with-param>
				</xsl:call-template>
			</coverage>
		</xsl:for-each>
		<relation xtf:meta="true">oac.cdlib.org</relation>

		<xsl:for-each select="marc:datafield[@tag=530]">
			<!-- nt 01/04 attribute fix -->
			<relation xtf:meta="true">
				<!--<xsl:attribute name="type">original</xsl:attribute>-->
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">abcdu</xsl:with-param>
				</xsl:call-template>
			</relation>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=760]|marc:datafield[@tag=762]|marc:datafield[@tag=765]|marc:datafield[@tag=767]|marc:datafield[@tag=770]|marc:datafield[@tag=772]|marc:datafield[@tag=773]|marc:datafield[@tag=774]|marc:datafield[@tag=775]|marc:datafield[@tag=776]|marc:datafield[@tag=777]|marc:datafield[@tag=780]|marc:datafield[@tag=785]|marc:datafield[@tag=786]|marc:datafield[@tag=787]">
			<relation xtf:meta="true">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">ot</xsl:with-param>
				</xsl:call-template>
			</relation>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag='852']">

    <xsl:if test="marc:subfield[@code='h' or @code='i' or @code='j']">
	<!-- location xtf:meta="true">
				<xsl:text>Call Number: </xsl:text>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">ehij</xsl:with-param>
        </xsl:call-template>
	</location -->
    </xsl:if>   
    <xsl:if test="marc:subfield[@code='a' or @code='b']">

			<xsl:variable name="a">
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">a</xsl:with-param>
        </xsl:call-template>
			</xsl:variable>

			<xsl:variable name="b">
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">b</xsl:with-param>
        </xsl:call-template>
			</xsl:variable>

<institution xtf:meta="true" xtf:tokenize="yes">
	<xsl:value-of select="if ($a) then $a else 'NONE'"/>
	<xsl:text>::</xsl:text>
	<xsl:value-of select="if ($b) then $b else 'NONE'"/>
</institution>
    </xsl:if>
		</xsl:for-each>

		<xsl:for-each select="marc:datafield[@tag=856]">
			<identifier xtf:meta="true">
				<xsl:value-of select="marc:subfield[@code='u']"/>
			</identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=020]">
			<identifier xtf:meta="true">
				<xsl:text>URN:ISBN:</xsl:text>
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</identifier>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=506]">
			<rights xtf:meta="true">
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</rights>
		</xsl:for-each>
		<xsl:for-each select="marc:datafield[@tag=540]">
			<rights xtf:meta="true">
				<xsl:value-of select="marc:subfield[@code='a']"/>
			</rights>
		</xsl:for-each>


   		<xsl:for-each select="marc:controlfield[@tag=001]">
                        <identifier xtf:meta="true" type="SYSID">
                                <xsl:value-of select="."/>
                        </identifier>
                </xsl:for-each>

                <!-- CDL: Added to contain OCLC Number -->
                <xsl:for-each select="marc:datafield[@tag=035]">
                        <xsl:variable name="M035a" select="string(marc:subfield[@code='a'])"/>
                        <xsl:choose>
                                <xsl:when test="contains($M035a, '(OCoLC)ocm')">
                                        <identifier xtf:meta="true" type="OCLC">
                                                <xsl:value-of select="substring-after($M035a, '(OCoLC)ocm')"/>
                                        </identifier>
                                </xsl:when>
                                <xsl:when test="contains($M035a, '(OCoLC)')">
                                        <identifier xtf:meta="true" type="OCLC">
                                                <xsl:value-of select="substring-after($M035a, '(OCoLC)')"/>
                                        </identifier>
                                </xsl:when>
                                <xsl:when test="contains($M035a, 'ocm')">
                                        <xsl:choose>
                                                <xsl:when test="contains($M035a, ' ')">
                                                        <identifier xtf:meta="true" type="OCLC">
                                                                <xsl:value-of select="substring-before(substring-after($M035a, 'ocm'), ' ')"/>
                                                        </identifier>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                        <identifier xtf:meta="true" type="OCLC">
                                                                <xsl:value-of select="substring-after($M035a, 'ocm')"/>
                                                        </identifier>
                                                </xsl:otherwise>
                                        </xsl:choose>
                                </xsl:when>
                        </xsl:choose>
                </xsl:for-each>


		<!-- pull in mods -->
		<xsl:apply-templates select="." mode="m2m"/>
	</xtf:meta>
	</xsl:if>
	</xsl:template>


  <!-- Function to parse normalized titles out of dc:title -->
  <xsl:function name="parse:title">
   
    <xsl:param name="title"/>
   
    <!-- Normalize Spaces & Case-->
    <xsl:variable name="lower-title">
      <xsl:value-of select="translate(normalize-space($title), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
    </xsl:variable>
   
    <!-- Remove Punctuation -->
    <xsl:variable name="parse-title">
      <xsl:value-of select="replace($lower-title, '[^a-z0-9 ]', '')"/>
    </xsl:variable>

    <!-- Remove Leading Articles -->
    <xsl:choose>
      <xsl:when test="matches($parse-title, '^a ')">
        <xsl:value-of select="replace($parse-title, '^a (.+)', '$1')"/>
      </xsl:when>
      <xsl:when test="matches($parse-title, '^an ')">
        <xsl:value-of select="replace($parse-title, '^an (.+)', '$1')"/>
      </xsl:when>
      <xsl:when test="matches($parse-title, '^the ')">
        <xsl:value-of select="replace($parse-title, '^the (.+)', '$1')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$parse-title"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

</xsl:stylesheet>
