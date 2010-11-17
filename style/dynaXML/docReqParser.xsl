<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- Document lookup stylesheet                                             -->
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

<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:mets="http://www.loc.gov/METS/"
  xmlns:xlink="http://www.w3.org/TR/xlink"
  xmlns:parse="http://cdlib.org/parse"
  xmlns:mprofile="http://www.cdlib.org/mets/profiles"
  xmlns:FileUtils="java:org.cdlib.xtf.xslt.FileUtils"
  exclude-result-prefixes="#all">
  
  <!-- Templates used for parsing text queries -->               
  <xsl:import href="../crossQuery/queryParser/old/queryParser.xsl"/>

  <!-- bct extention function to tie into profile logic -->  
  <!-- {http://www.cdlib.org/mets/profiles}:URItoDisplayXslt($URI) returns xslt file name -->
  <xsl:import href="../../mets-support/xslt/mets-profile.xsl"/>  

  <xsl:output method="xml"
    indent="yes"
    encoding="utf-8"/>
  
  <!--
  When a request is made for a particular document (by specifying docId),
  dynaXML will run the document lookup stylesheet to obtain the source path, 
  stylesheet, branding profile, and authorization info for that document.
  
  Specifically, the stylesheet receives a XSLT parameter $docId 
  containing the document ID as specified in the request URL.
  
  It should output an XML document, which must always contain "style",
  "source", and one or more "auth" tags.
  
  Note that all filesystem paths are relative to the servlet base directory.
  -->
  
  <!-- ====================================================================== -->
  <!-- Parameters                                                             -->
  <!-- ====================================================================== -->
  
  <xsl:param name="docId"/>
  <xsl:param name="query" select="'0'"/>
  <xsl:param name="query-join" select="'0'"/>
  <xsl:param name="query-exclude" select="'0'"/>
  <xsl:param name="sectionType" select="'0'"/>
  <xsl:param name="doc.view"/>
  <xsl:param name="style"/>
  <xsl:param name="mode"/>
  
  <!-- ====================================================================== -->
  <!-- Variables                                                              -->
  <!-- ====================================================================== -->
 
  <xsl:param name="NAAN" select="'13030'"/> 
  <xsl:variable name="subDir" select="substring($docId, (string-length($docId) -1 ), 2)"/>
  <xsl:variable name="sourceDir" select="concat('data/', $NAAN, '/', $subDir, '/', $docId, '/')"/>

  <!-- In order to accomadate Brian's needs we need to check if there are 
  <behaviorSec>s in the METS. If NOT, then we might need to use a different 
  docFormatter, source file, brand, index, authentication mechanism, etc.-->
  <xsl:variable name="METS" select="document(concat('../../', $sourceDir, $docId, '.mets.xml'))"/>
  
  <!-- KVH: Added this-->  
  <xsl:variable name="profile" select="$METS//mets:mets/@PROFILE"/>
  <xsl:variable name="displayMechURL" select="$METS//mets:behavior[@BTYPE='display']/mets:mechanism/@*[local-name()='href']"/>
  <xsl:variable name="displayMorphed" select="replace($displayMechURL, '.+/profiles', '../../profiles')"/>  
  <!-- Need to check for existence of this file before we populate variable -->
  <!-- bct: attempting to do this; still need a better way -->
  <xsl:variable name="displayMech">
  <xsl:if test="boolean(FileUtils:exists(string($displayMorphed))) and $displayMechURL">
   <xsl:copy-of select="document($displayMorphed)"/>
  </xsl:if>
  </xsl:variable>

  
  
  <xsl:variable name="authMechURL" select="$METS//mets:behavior[@BTYPE='authentication']/mets:mechanism/@*[local-name()='href']"/>
  <xsl:variable name="authMorphed" select="replace($authMechURL, '.+/profiles', '../../profiles')"/>
  <!-- Need to check for existence of this file before we populate variable -->
  <!-- bct: attempting to do this; still need a better way -->
  <xsl:variable name="authMech">
  <xsl:if test="boolean(FileUtils:exists(string($authMorphed))) and $authMechURL">
   <xsl:copy-of select="document($authMorphed)"/>
  </xsl:if>
  </xsl:variable>

  
  <!-- ====================================================================== -->
  <!-- Root Template                                                          -->
  <!-- ====================================================================== -->
  
  <xsl:template match="/">
    <!-- ==================================================================
    The "style" tag specifies a filesystem path, relative to the servlet
    base directory, to a stylesheet that translates an XML source document
    into an HTML page
    -->
    
    <xsl:choose>
      <xsl:when test="$docId='cdl-book-bpg'">
        <style path="style/dynaXML/docFormatter/bpg/cdl/book/docFormatter.xsl"/>
      </xsl:when>
      <xsl:when test="$docId='cdl-lite-bpg'">
        <style path="style/dynaXML/docFormatter/bpg/cdl/book/docFormatter.xsl"/>
      </xsl:when>
      <xsl:when test="$docId='cdl-ms-bpg'">
        <style path="style/dynaXML/docFormatter/bpg/cdl/book/docFormatter.xsl"/>
      </xsl:when>
      <xsl:when test="$docId='cdl-oh-bpg'">
        <style path="style/dynaXML/docFormatter/bpg/cdl/book/docFormatter.xsl"/>
      </xsl:when>
      <xsl:when test="$style='ead-test'">
        <style path="style/dynaXML/docFormatter/ead/test/docFormatter.xsl"/>
      </xsl:when>
      <xsl:when test="$style = 'oac4jsod'">
	<style>
        <xsl:attribute name="path">style/dynaXML/docFormatter/ead/oac4/oac4.jsod.xslt</xsl:attribute>
	</style>
      </xsl:when>

      <!-- For MTP Test -->
      <!-- Letters -->
      <xsl:when test="$docId='mtp-l-bpg'">
        <style path="style/dynaXML/docFormatter/bpg/cdl/mtp/letters/docFormatter.xsl"/>
      </xsl:when>
      <!-- Works -->
      <xsl:when test="$docId='mtp-w-bpg'">
        <style path="style/dynaXML/docFormatter/bpg/cdl/mtp/works/docFormatter.xsl"/>
      </xsl:when>
      <!-- For Paul's Test -->
      <xsl:when test="$docId='test-bpg'">
        <style path="style/dynaXML/docFormatter/bpg/test/docFormatter.xsl"/>
      </xsl:when>
      <!-- xxxxxxxxxxxx -->
      <xsl:when test="$docId='default-preview'">
        <style path="style/dynaXML/docFormatter/default/docFormatter.xsl"/>
      </xsl:when>
      <xsl:when test="$docId='ead-preview'">
        <style path="style/dynaXML/docFormatter/ead/oac4/oac4.xslt"/>
      </xsl:when>
      <xsl:when test="$docId='ead-v1to02-preview'">
        <style path="style/dynaXML/docFormatter/ead/v1to02/docFormatter.xsl"/>
      </xsl:when>
      <xsl:when test="$docId='eschol-preview'">
        <style path="style/dynaXML/docFormatter/tei/eschol/docFormatter.xsl"/>
      </xsl:when>
      <xsl:when test="$docId='oac-preview'">
        <style path="style/dynaXML/docFormatter/tei/oac/docFormatter.xsl"/>
      </xsl:when>
<!-- http://ark.cdlib.org/ark:/13030/kt4199q42g
	removed items might have a $displayMech//style -->
      <!-- This is very fragile, but I can't figure out how to check if $displayMech actually contains XML -->
      <xsl:when test="$profile = 'http://ark.cdlib.org/ark:/13030/kt4199q42g'">
        <xsl:variable name="mprofile" select="mprofile:URItoDisplayXslt('http://ark.cdlib.org/ark:/13030/kt4199q42g')"/>
        <style path="{$mprofile}"/>
      </xsl:when>
      <xsl:when test="$style = 'oac4'">
        <style>
        <xsl:attribute name="path">style/dynaXML/docFormatter/ead/oac4/oac4.xslt</xsl:attribute>
        </style>
      </xsl:when>
			<!-- Jsod detection and routing -->
			<xsl:when test="$mode='jsod'">
        <xsl:variable name="mprofile" select="mprofile:URItoJsodXslt($profile)"/>
        <style path="{$mprofile}"/>
      </xsl:when>
      <!-- classic XTF selector from behaviourSec -->
      <xsl:when test="$displayMech//style and not ($doc.view='mets')">
        <xsl:variable name="dispStyle" select="$displayMech//style/@path"/>
        <style path="{$dispStyle}"/>
      </xsl:when>
        <!-- bct: this should only happen if there was not a behaviourSec
                  in the METS file -->
        <xsl:when test="boolean(mprofile:URItoDisplayXslt($profile))">
        <xsl:variable name="mprofile" select="mprofile:URItoDisplayXslt($profile)"/>
        <style path="{$mprofile}"/>
      </xsl:when>
      <xsl:otherwise>
        <style path="style/dynaXML/docFormatter/tei/oac/docFormatter.xsl"/>
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- ==================================================================
    The "source" tag specifies a filesystem path (relative to the servlet
    base directory), or an HTTP URL. The referenced XML document is
    parsed and fed into the display stylesheet.
    -->

    <!-- bct: changed the logic so that its based on the presense or absence of a docId.xml file; oterwise use the docId.mets.xml -->
    <xsl:choose>
      <!-- kvh: this is to support the new agnostic docId used in the default sytlesheets (docId=13030/1r/ft5q2nb41r/ft5q2nb41r.xml) -->
      <xsl:when test="boolean(FileUtils:exists(string(concat('../../data/', $docId))))">
        <source path="{concat('data/',$docId)}"/>
      </xsl:when>
      <xsl:when test="boolean(FileUtils:exists(string(concat('../../', $sourceDir, $docId, '.xml'))))">
        <source path="{concat($sourceDir, $docId, '.xml')}"/>
      </xsl:when>
      <xsl:otherwise>
        <source path="{concat($sourceDir, $docId, '.mets.xml')}"/>
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- ==================================================================
    The optional "brand" tag specifies a filesystem path (relative to the
    servlet base directory) that is a simple stylesheet. It should produce
    any custom brand-related parameters that need be passed to the display
    stylesheet. The output should be of the form:
    
    <name>value</name>
    <name>value</name>
    ...
    
    This can be quite useful for instance if you want to have two or more
    color schemes for different sets of documents.
    -->
    
    <!-- ==================================================================
    For speed, a persistent or "lazy" version of each document is
    stored in the index. The servlet needs to be able to get back to
    that place to fetch the persistent version.
    -->
    
    <index configPath="conf/textIndexer.conf" name="cdl"/>
    
    
    <!-- ==================================================================
    If the user specifies a text query, it needs to be parsed into the
    same format as required by CrossQuery. Uses templates imported 
    from queryParser.xsl to do most of the work... see detailed 
    comments there for more information.
    -->
    <xsl:if test="$query != '0' and $query != ''">
      
      <xsl:variable name="query" select="/parameters/param[@name='query']"/>
      <xsl:variable name="sectionType" select="/parameters/param[@name='sectionType']"/>
      
      <query indexPath="index" termLimit="1000" workLimit="500000">
        <xsl:apply-templates select="$query"/>
      </query>
      
    </xsl:if>
    
    
    <!-- ==================================================================
    Finally, one or more "auth" sections must be included. These sections 
    will be processed in the order produced until one of them matches.  If 
    none match, access will be denied.
    
    To grant or deny access to everyone, output an auth tag with type 
    "all", like this:
    
    <auth access = ["allow" | "deny"]
    type   = "all"/>
    
    To allow or deny access based on the IP address of the requestor, use 
    the "IP" type like this:
    
    <auth access = ["allow" | "deny"]
    type   = "IP" 
    list   = [URL or file path to a list of IP addresses] />
    
    To allow access to be controlled by an LDAP database, output an auth 
    tag with type "LDAP". There are typically three ways an LDAP database 
    can be used for authentication:
    
    (1) Anonymous bind to the LDAP server, then look up user's record 
    in the database and verify the password. Supply these attributes:
    - server
    - realm
    - queryName  (containing "%" where user name should be placed)
    - matchField (name of field containing password)
    - matchValue (containing "%" where password should be placed)
    
    (2) Bind as administrator to LDAP server using admin password, then
    look up user's record in database and verify their password.
    Supply these attributes:
    - server
    - realm
    - bindName     (the DN of the administrator)
    - bindPassword (the password of the administrator)
    - queryName    (containing "%" where user name should be placed)
    - matchField   (name of field containing password)
    - matchValue   (containing "%" where password should be placed)
    
    (3) Bind to LDAP server using the user's name and password.
    - server
    - realm
    - bindName     (the user's DN, put "%" where user name should go)
    - bindPassword (the string "%" to supply the user's password)
    - queryName    (record to query, often the same as bindName)
    
    <auth access       = "allow"
    type         = "LDAP"
    server       = [URL of LDAP server; begins with "ldap://"]
    realm        = [Description of document collection, shown to
    user when requesting name and password]
    bindName     = [Optional: DN for LDAP bind; string may contain
    "%" which will be replaced by user name]
    bindPassword = [Optional: Password for bind, or use "%" for
    the password entered by the requestor]
    queryName    = [DN to query; string may contain "%" which will
    be replaced by user name]
    matchField   = [Optional: field name to look for]
    matchValue   = [Optional: value to match, "%" to put in the
    user's password]/>
    
    To allow access to be controlled by an external web page (e.g. 
    form-based login, .htpasswd, Shibboleth, etc) output an "external" 
    type auth tag. The external page will receive the following URL 
    parameters:
    
    - returnto    (the URL to return to once authentication is accepted)
    - nonce       (a nonsense string specific to this attempt)
    
    and it must return the following parameters to the "returnto" URL:
    
    - nonce       (the same nonsense string)
    - hash        (hex string MD5 hash of the concatenation of 
    "nonce:key" where key is the shared secret key string)
    
    <auth access = "allow"
    type   = "external" 
    key    = [shared secret key string]
    url    = [URL of the external authentication web page]/>
    -->
    
    <!-- CDL-specific: Since we don't read METS yet, each directory has an 
    authInfo.xml file which has authentication directives.
    
    Note that the path here, since we're reading the file directly, must
    be relative to this stylesheet, *not* to the servlet base directory.
    Hence the "../" below.
    
    If not found, allow access. This is for testing only!
    -->
    
    <xsl:choose>
      <xsl:when test="contains($docId, 'preview')">
        <auth access="allow" type="all"/>
      </xsl:when>
      <xsl:when test="contains($docId, 'bpg-checker')">
        <auth access="allow" type="all"/>
      </xsl:when>
      <xsl:when test="$authMech//auth">
        <xsl:copy-of select="$authMech//auth"/>
      </xsl:when>
      <xsl:otherwise>
        <auth access="allow" type="all"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
</xsl:stylesheet>

