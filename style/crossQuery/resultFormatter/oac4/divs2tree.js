	// http://content-dev.cdlib.org/yui/cdl/divs2tree.js
	YAHOO.namespace ("oac");
        YAHOO.oac.div2tree = {
            init: function() {
                this.start = YAHOO.util.Dom.get('searchResults');
                this.treeView = new YAHOO.widget.TreeView("searchResults");
                this.root = this.treeView.getRoot();
                //this.parseOuterDivs(this.start,this.root);
                this.parseOuterDivs(this.start,this.root);
                this.treeView.draw();
            },
            parseOuterDivs: function(elm, treeNode) {
		var tmp = treeNode;
		for (var i = 0; i < elm.childNodes.length; i++) {
			if (elm.childNodes[i].nodeName == 'DIV') {
				this.parseDivs (elm.childNodes[i], tmp);
			} 
		}
            },
            parseDivs: function(elm, treeNode) {
		var title;
		if (elm.getElementsByTagName("h5")[0]) { title = elm.getElementsByTagName("h5")[0] };
		if (elm.getElementsByTagName("h4")[0]) { title = elm.getElementsByTagName("h4")[0] };
		if (elm.getElementsByTagName("h3")[0]) { title = elm.getElementsByTagName("h3")[0] };
		if (elm.getElementsByTagName("h2")[0]) { title = elm.getElementsByTagName("h2")[0] };
		//var tmp = new YAHOO.widget.MenuNode(title.innerHTML, treeNode, false);
		var tmp = new YAHOO.widget.TextNode(title.innerHTML, treeNode, false);
		title.display = "none";
		for (var i = 0; i < elm.childNodes.length; i++) {
			if (
				elm.childNodes[i].nodeName == 'DIV' 
			    	&& 
			    	(
					elm.childNodes[i].getElementsByTagName("h2") ||
					elm.childNodes[i].getElementsByTagName("h3") ||
					elm.childNodes[i].getElementsByTagName("h4") ||
					elm.childNodes[i].getElementsByTagName("h5")
				)
			) {
				this.parseDivs (elm.childNodes[i], tmp);
			} else if (elm.childNodes[i].nodeName == '#text') {
				var tmp2 = new YAHOO.widget.TextNode(elm.childNodes[i].innerHTML, tmp, false);
			} else if (
					elm.childNodes[i].nodeName == 'H2' ||
					elm.childNodes[i].nodeName == 'H3' ||
					elm.childNodes[i].nodeName == 'H4' ||
					elm.childNodes[i].nodeName == 'H5' 
				) 
			{
			} else {
				var tmp2 = new YAHOO.widget.HTMLNode(elm.childNodes[i].innerHTML, tmp, false);
			}
		}
            }
        }
        YAHOO.util.Event.addListener(window, 'load', YAHOO.oac.div2tree.init, YAHOO.oac.div2tree, true);
