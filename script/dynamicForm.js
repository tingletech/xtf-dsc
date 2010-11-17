var debug = 0;

function egh_exclusiveSelectUpdate (el) {
    var exclusive_select_id = egh_getClassOption (el, "exclusive-select-id");
    var other_element = document.getElementById (exclusive_select_id);
    egh_disableOptionByValue (other_element, el.value);
}

function egh_disableOptionByValue (theSelect, theValue) {
    var options = theSelect.getElementsByTagName("option");
    for (var i = 0 ; i < options.length ; i++) {
	if (options[i].value == theValue) {
	    options[i].setAttribute('disabled', 'disabled');
	} else {
	    options[i].removeAttribute ('disabled');
	}
    }
}
    
function egh_initialUpdate (el) {
    if (el.tagName.toLowerCase() == 'input') {
	if ((el.type.toLowerCase() == 'radio') && el.checked) { el.onchange (null) };
	if (el.type.toLowerCase() == 'text') { 
	   el.onchange (null)
	};
    }
    if (el.tagName.toLowerCase() == 'select') {
    	el.onchange (null);
    }
}

function egh_getClassOption (my_node, my_targeter) {
    var my_regex = new RegExp ("(^|\\s)" + my_targeter + "=([\\w-]+)(\\s|$)");
    var my_results = my_regex.exec (my_node.className);
    return my_results[2] || null;
}

function egh_NameSetter (target_name) {
    this.target_name = target_name;
    this.whichName = function (el) { return el.value; };
    this.update = function (el) {
	var target_id = egh_getClassOption (el, target_name);
	document.getElementById (target_id).setAttribute ('name', this.whichName (el));
    };
    this.initElement = function (el) {
	var the_id = egh_getClassOption (el, this.target_name);
	var myHiddenElement = document.createElement ("input");
	myHiddenElement.setAttribute("type", "hidden");
	myHiddenElement.setAttribute("id", the_id);
	el.parentNode.appendChild (myHiddenElement);
	this.update (el);
    };
}

function egh_disableSubmitIfElementsEmpty (theSelector, submitId) {
    var disabled = true;
    var elements = document.getElementsBySelector(theSelector);
    for (var i = 0 ; i < elements.length ; i++) {
	if (elements[i].value != "" && elements[i].value != null) { 
	    document.getElementById (submitId).removeAttribute ("disabled");	    
	    return true;
	}
    }
    document.getElementById ("search-submit").setAttribute ("disabled", "disabled");
    return false;
}

name_setter_normal = new egh_NameSetter ('name-setter');

name_setter_with_parent_id_prefix = new egh_NameSetter ('name-setter-with-parent-id-prefix');
name_setter_with_parent_id_prefix.whichName = function (el) {
    return el.parentNode.id + el.value;
};

name_setter_with_parent_id_suffix = new egh_NameSetter ('name-setter-with-parent-id-suffix');
name_setter_with_parent_id_suffix.whichName = function (el) {
    return el.value + el.parentNode.id;
};

name_setter_with_static_suffix = new egh_NameSetter ('name-setter-with-static-suffix');
name_setter_with_static_suffix.whichName = function (el) {
    return el.value + egh_getClassOption (el, 'static-suffix');
};

var myrules = {
    '.exclusive-select' : 
    {
	onchange : function (e) {
	    egh_exclusiveSelectUpdate (this);
 	},
 	onload : function (el) {
	    egh_exclusiveSelectUpdate (el);
 	}
    },
	
    ".name-setter" : 
    {
	onchange : function (e) {
	    name_setter_normal.update(this);
 	},
 	onload : function (el) {
	    name_setter_normal.initElement (el);
	}
    },
    '.name-setter-with-parent-id-prefix' : {
 	onchange : function (e) {
	    name_setter_with_parent_id_prefix.update (this);
 	},
 	onload : function (el) {
	    name_setter_with_parent_id_prefix.initElement (el);
 	}
     },
     '.name-setter-with-parent-id-suffix' : {
 	onchange : function (e) {
	    name_setter_with_parent_id_suffix.update (this);
 	},
 	onload : function (el) {
	    name_setter_with_parent_id_suffix.initElement (el);
 	}
     },
    '.name-setter-with-static-suffix' : {
	onchange : function (e) {
	    name_setter_with_static_suffix.update (this);
	},
	onload : function (el) {
	    name_setter_with_static_suffix.initElement (el);
	}
    },
    '.value-setter' : {
	onchange : function (e) {
	    var target_id = egh_getClassOption (this, "value-setter");
	    document.getElementById(target_id).setAttribute('value', this.value);
	},
	onload : function (el) {
	    egh_initialUpdate (el);
	}
    },
    'input.search-text' : {
	onchange : function (e) {
	    egh_disableSubmitIfElementsEmpty ("input.search-text", "search-submit");
	},
	onload : function (el) {
	    egh_disableSubmitIfElementsEmpty ("input.search-text", "search-submit");
	}
    }
};

Behavior.register(myrules);
