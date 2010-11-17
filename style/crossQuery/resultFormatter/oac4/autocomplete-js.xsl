<xsl:stylesheet version="2.0" 
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        exclude-result-prefixes="#all"
        xmlns:tmpl="xslt://template">


<xsl:template match="*[@tmpl:process='institution-search']">


<form method="get" name="search-form" class="search-form" action="/search" onsubmit="return queryformcheck(this);">
                <input type="hidden" name="style" value="oac4"/>
                <input type="hidden" name="ff" value="0"/>
                <xsl:if test="$developer != 'local'"><input type="hidden" name="developer" value="{$developer}"/></xsl:if>
		<xsl:if test="$Institution != ''"><input type="hidden" name="institution" value="{$Institution}"/></xsl:if>

                                 
                                 <table>
                                    
                                    <tbody><tr>
                                       
                                       <td>

<div id="ysearchautocomplete">
		<input id="ysearchinput" type="text" maxlength="80" size="35" class="text-field" name="query"/>
		<div id="ysearchcontainer"></div>
	</div>


                                       </td>
                                       
                                       <td>
<input type="image" title="Go" alt="Go" value="Search" class="search-button" src="/images/buttons/go.gif"/>
                                       </td>
                                       
                                    </tr>
                                    
                                 </tbody></table>
                                 
                            </form>
</xsl:template>

  <xsl:template match="head">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
      <link rel="stylesheet" type="text/css" href="/yui/build/autocomplete/assets/skins/sam/autocomplete.css" />
<style type="text/css">
.yui-ac-content {
background:#FFFFFF none repeat scroll 0% 50%;
position:absolute;
border:1px solid #808080;
overflow:hidden;
z-index:9050;
}
</style>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="body">
    <xsl:copy copy-namespaces="no">
<xsl:apply-templates/>
<script type="text/javascript" src="/yui/build/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="/yui/build/animation/animation-min.js"></script>
<script type="text/javascript" src="/yui/build/connection/connection-min.js"></script>
<script type="text/javascript" src="/yui/build/autocomplete/autocomplete-min.js"></script>
<script type="text/javascript" encoding="UTF-8">
YAHOO.example.ACXml = new function(){
	// shortcut for access to YUI Dom 
	var yD = YAHOO.util.Dom;
	var ysearchinput = yD.getElementsByClassName('text-field','div')[0];
	// var ysearchconainer = yD.getElementsByClassName('collection-contents','div')[0];
	this.oACDS = new YAHOO.widget.DS_XHR("/search", ["meta", "title"]);
	this.oACDS.responseType = YAHOO.widget.DS_XHR.TYPE_XML;
	this.oACDS.queryMatchContains = true;
	this.oACDS.allowBrowserAutocomplete = false;
	this.oACDS.autoHighlight = false; 
	this.oACDS.maxResultsDisplayed = 20; 
	this.oACDS.typeAhead = true; 
	this.oACDS.forceSelection = true;
	this.oACDS.scriptQueryAppend = encodeURI("style=oac4;autocomplete=autocomplete<xsl:if test="$Institution != ''">;Institution=<xsl:value-of select="$Institution"/></xsl:if>");

	// Instantiate AutoComplete
	this.oAutoComp = new YAHOO.widget.AutoComplete("ysearchinput","ysearchcontainer", this.oACDS);
	// console.log(this);
   
	// Stub for AutoComplete form validation
	this.validateForm = function() {
     		// Validation code goes here
		return false;
    	};
};


function queryformcheck(form){
	if (form.query.value == '') {
		return false;
	}
	else {
        	return true;
	}
};

</script>
</xsl:copy>
</xsl:template>

</xsl:stylesheet>
