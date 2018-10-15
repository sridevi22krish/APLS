/*!================================================================
 *  JavaScript Modal Dialog
 *  emxUIModal.js
 *  Version 1.5
 *  Requires: emxUIConstants.js
 *  Last Updated: 28-Apr-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains the class definition of the structure tree.
 *
 *  Copyright (c) 1992-2015 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIModal.js.rca 1.43 Tue Oct 28 18:55:06 2008 przemek Experimental przemek $
 *=================================================================
 */
// Try to consolidate all the browser checks. Use emxUICore for browser detection
var Browser = (function () {
	/*
	 * User Agent String for all the supported browser
	 *
	 *
	 * */
	var browsers = {
				"IE" : false,
				"FIREFOX" : false,
				"CHROME" : false,
				"MOZILLA_FAMILY": false,
				"SAFARI" : false,
				"MOBILE" : false
 			};


	detectBrowser = function(ua){
		var ie = /(msie|trident)/i.test(ua)
      , chrome = /chrome|crios/i.test(ua)
      , safari = /safari/i.test(ua) && !chrome
      , firefox = /firefox/i.test(ua)
      , mobile = /(Mobile)/i.test(ua) || /(Touch|Tablet PC*)/.test(ua);
		if(ie){
			browsers.IE=true;
		}else if (chrome){
			browsers.CHROME=true;
		}else if(safari){
			browsers.SAFARI=true;
		}else if(firefox){
			browsers.FIREFOX=true;
		}
		if(mobile){
			browsers.MOBILE = true;
		}
		if(chrome || safari || firefox){
			browsers.MOZILLA_FAMILY=true;
		}
	};
	detectBrowser(navigator.userAgent);
	return browsers;
}());

var bPageHistory = false;

var isKHTML_M= Browser.SAFARI || Browser.CHROME ;
var isIE_M = Browser.IE;
var isMoz_M = Browser.MOZILLA_FAMILY;

var isMac_M = navigator.platform.indexOf("Mac") > -1;

//All below check should beremoved after discussion with application team
var strUserAgent_M = navigator.userAgent.toLowerCase();
var isMinIE5_M = false,isMinIE55_M = false,isMinIE6_M = false;
if (isIE_M) {
    var reIE_M = new RegExp("msie (\\S*);");
    reIE_M.test(strUserAgent_M);
    var fVer_M = parseFloat(RegExp["$1"]);
    isMinIE5_M = fVer_M >= 5;
    isMinIE55_M = fVer_M >= 5.5;
    isMinIE6_M = fVer_M >= 6;
}
var isNS6_M = strUserAgent_M.indexOf("netscape6") > -1 && strUserAgent_M.indexOf("opera") == -1;
var isMinNS6_M = isNS6_M,isMinNS61_M = false,isMinNS62_M = false;
if (isNS6_M) {
    var reNS6_M = new RegExp("netscape6\\/(\\S*)");
    reNS6_M.test(strUserAgent_M);
    var fVer_M = parseFloat(RegExp["$1"]);
    isMinNS6_M = (fVer_M >= 6);
    isMinNS61_M = (fVer_M >= 6.1);
    isMinNS62_M = (fVer_M >= 6.2);
}
var isNS4_M =false;
var contentWindowRef;




var showWindowShadeDialog;
if(typeof getTopWindow != 'undefined' && getTopWindow != null){
	showWindowShadeDialog = getTopWindow().showWindowShadeDialog;
	if(!getTopWindow().shortcut){
		getTopWindow().shortcut=[];
}
}

if(!showWindowShadeDialog){
	showWindowShadeDialog = showModalDialog;
}

var strProtocol, strHost, strPort;

with(document.location){
    strProtocol = protocol;
    strHost = hostname;
    strPort = port;
}

//! Class emxUIModalDialog
//!     This class represents a modal dialog window. This class
//!     should not be instantiated directly by a developer.
function emxUIModalDialog(objParent, strURL, intWidth, intHeight, blnScrollbars, applyIEMask) {
	if(strURL && strURL.indexOf("?") > -1)
		strURL = strURL + "&targetLocation=popup";
	else
		strURL = strURL + "?targetLocation=popup";

        if (isIE_M || isKHTML_M) {
                return new emxUIIEModalDialog(objParent, strURL, intWidth, intHeight, blnScrollbars, applyIEMask);
        } else {
                return new emxUIMozillaModalDialog(objParent, strURL, intWidth, intHeight, blnScrollbars);
        }
}

//! Public Function showModalDialog()
//!     This function opens a modal dialog window and centers it.
function showModalDialog(strURL, intWidth, intHeight, bScrollbars, strPopupSize,searchDim, applyIEMask) {
            //FIX for IR-076967V6R2012
		if(isSnN() && isFullSearchPage(strURL)){
			var snnOrFTSURL = strURL.replace("emxFullSearch.jsp", "emxFullSearchGetData.jsp");
			snnOrFTSURL = snnOrFTSURL + "&action=" + "getOnlyJSON";
			if(returnIfSnN(snnOrFTSURL, strURL)){
				return;
			}
	    }
		if(!this.emxUIConstants || !emxUIConstants.ARR_PopupWidth){
	    	emxUIConstants = getTopWindow().emxUIConstants;
	    	if((!this.emxUIConstants || !emxUIConstants.ARR_PopupWidth) && getTopWindow().getWindowOpener()){
	    		emxUIConstants = getTopWindow().getWindowOpener().getTopWindow().emxUIConstants;
	    		if(!this.emxUIConstants || !emxUIConstants.ARR_PopupWidth){
	    			emxUIConstants = getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow().emxUIConstants;
	    		}
	    	}
	    }
		var applyIEMask = (applyIEMask === "true");
	    if(emxUIConstants.ARR_PopupWidth){
		    if(strPopupSize){
		    	if( emxUIConstants.ARR_PopupWidth[strPopupSize]){
		    		intWidth = emxUIConstants.ARR_PopupWidth[strPopupSize];
		    		intHeight = emxUIConstants.ARR_PopupHeight[strPopupSize];
		    	} else {
		    		intWidth = emxUIConstants.ARR_PopupWidth['Default'];
		    		intHeight = emxUIConstants.ARR_PopupHeight['Default'];
		    	}
		    } else {
		    	if(! emxUIConstants.ARR_PopupDimensions ['' + intWidth + 'x' + intHeight + '']){
		    		intWidth = emxUIConstants.ARR_PopupWidth['Default'];
		    		intHeight = emxUIConstants.ARR_PopupHeight['Default'];
		    	}
		    }
	    } else {
	    	intWidth = "812";
	    	intHeight = "500";
	    }
	    if(searchDim){
	    	var topPosition = jQuery('#pageHeadDiv').height() ;
			intWidth = emxUICore.getWinWidth();
	    	intHeight = emxUICore.getWinHeight()-topPosition;
	    }
		try {
			if (getTopWindow().modalDialog  && !getTopWindow().modalDialog.contentWindow.closed) {
				getTopWindow().modalDialog.show();
				return;
			}
		} catch(e) {}

		var objModalDialog = new emxUIModalDialog(self, strURL, intWidth, intHeight, bScrollbars, applyIEMask);
		objModalDialog.show();
}

function returnIfSnN (snnOrFTSURL, searchURL) {
	var strData = snnOrFTSURL.substring(snnOrFTSURL.indexOf('?')+1, snnOrFTSURL.length);
	var strURL = snnOrFTSURL.substring(0, snnOrFTSURL.indexOf('?'));
	var searchData = emxUICore.getDataPost(strURL, strData);
	if(searchData.trim() != ""){
		getTopWindow().SnN.FRAME_TO_BE_REFRESHED = this;
		getTopWindow().SnN.loadSnN(searchData, snnOrFTSURL);
		return true;
	}else{
		return false;
	}
}

//! Public Function showDialog()
//!     This function shows a generic dialog.
//!     This function is considered public and may be used
//!     by developers.
function showDialog(strURL) {
        showModalDialog(strURL, 570, 520,true, 'Small');
}
//! Public Function showListDialog()
//!     This function shows a generic list dialog.
//!     This function is considered public and may be used
//!     by developers.
function showListDialog(strURL) {
        showModalDialog(strURL, 730, 450,true, 'Medium');
}
//! Public Function showTreeDialog()
//!     This function shows a generic tree dialog.
function showTreeDialog(strURL) {
        showModalDialog(strURL, 400, 400,true, 'Small');
}
//! Public Function showWizard()
//!     This function shows a wizard dialog.
//!     This function is considered public and may be used
//!     by developers.
function showWizard(strURL) {
        showModalDialog(strURL, 780, 500,true, 'Medium');
}
//! Public Function showDetailsPopup()
//!     This function shows a details tree in a popup window.
//!     This function is considered public and may be used
//!     by developers.
function showDetailsPopup(strURL) {
        showNonModalDialog(strURL, 875, 550,true, '', 'Large');
}
//! Public Function showSearch()
//!     This function shows a search dialog.
//!     This function is considered public and may be used
//!     by developers.
function showSearch(strURL) {
        showNonModalDialog(strURL, 700, 500,true, '', 'Medium');
}
//! Public Function showChooser()
//!     This function shows a chooser dialog.
//!     This function is considered public and may be used
//!     by developers.
function showChooser(strURL,intWidth,intHeight) {
        if(intWidth == null || intWidth=="" ) {
                intWidth="700";
        }
        if(intHeight == null || intHeight=="" ) {
                intHeight="500";
        }
        showModalDialog(strURL, intWidth, intHeight, true, 'Medium');
}
function showChooserInHiddenFrame(strURL, targetLocation) {
	var targetFrame = findFrame(getTopWindow(), targetLocation);
	targetFrame.location.href = strURL;
}
//! Public Function showPrinterFriendlyPage()
//!     This function shows a printer-friendly page.
//!     This function is considered public and may be used
//!     by developers.
function showPrinterFriendlyPage(strURL) {
	if(strURL && strURL.indexOf("?") > -1)
		strURL = strURL + "&targetLocation=popup";
	else
		strURL = strURL + "?targetLocation=popup";

        var strFeatures = "scrollbars=yes,toolbar=yes,location=no";
        if (isNS4_M) {
                strFeatures += ",resizable=no";
        } else {
                strFeatures += ",resizable=yes";
        }
        var objWindow = window.open(strURL, "PF" + (new Date()).getTime(), strFeatures);
        if ( typeof(objWindow) != "undefined" && objWindow != null ){
        	registerChildWindows(objWindow, getTopWindow());
        	objWindow.focus();
        }
}
//! Public Function showPopupListPage()
//!     This function shows a popup list page.
function showPopupListPage(strURL) {
    showNonModalDialog(strURL, 700, 500,true, '', 'Medium');
}
//! Public Function showModalDetailsPopup()
//!     This function is a wrapper for showModalDialog.
function showModalDetailsPopup(strURL) {
        showModalDialog(strURL, 760,600,true, 'Medium');
}

//! Public Function showNonModalDialog()
//!     This function shows a non-modal (regular) dialog.
//parameter returnWindow should be true to get new NonModalDialog window opened
//When this function is assigned to an href don't use returnWindow parameter
function showNonModalDialog(strURL, intWidth, intHeight, bScrollbars,returnWindow, strPopupSize) {
	if(isSnN() && isFullSearchPage(strURL)){
		var snnOrFTSURL = strURL.replace("emxFullSearch.jsp", "emxFullSearchGetData.jsp");
		snnOrFTSURL = snnOrFTSURL + "&action=" + "getOnlyJSON";
		if(strURL.indexOf("emxAEFSubmitPopupAction.jsp") >= 0){
			snnOrFTSURL = getSnNorFTSURL(snnOrFTSURL);
		}
		if(returnIfSnN(snnOrFTSURL, strURL)){
			return;
		}
    }
	if(!this.emxUIConstants || !emxUIConstants.ARR_PopupWidth){
    	emxUIConstants = getTopWindow().emxUIConstants;
    	if((!this.emxUIConstants || !emxUIConstants.ARR_PopupWidth) && getTopWindow().getWindowOpener()){
    		emxUIConstants = getTopWindow().getWindowOpener().getTopWindow().emxUIConstants;
    		if(!this.emxUIConstants || !emxUIConstants.ARR_PopupWidth){
    			emxUIConstants = getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().getTopWindow().emxUIConstants;
    		}
    	}
    }
    if(emxUIConstants.ARR_PopupWidth){
	    if(strPopupSize){
	    	if( emxUIConstants.ARR_PopupWidth[strPopupSize]){
	    		intWidth = emxUIConstants.ARR_PopupWidth[strPopupSize];
	    		intHeight = emxUIConstants.ARR_PopupHeight[strPopupSize];
	    	} else {
	    		intWidth = emxUIConstants.ARR_PopupWidth['Default'];
	    		intHeight = emxUIConstants.ARR_PopupHeight['Default'];
	    	}
	    } else {
	    	if(! emxUIConstants.ARR_PopupDimensions ['' + intWidth + 'x' + intHeight + '']){
	    		intWidth = emxUIConstants.ARR_PopupWidth['Default'];
	    		intHeight = emxUIConstants.ARR_PopupHeight['Default'];
	    	}
	    }
    } else {
    	intWidth = "812";
    	intHeight = "500";
    }
	var winObj = showAndGetNonModalDialog(strURL, intWidth, intHeight, bScrollbars);
    if(typeof returnWindow!='undefined' && returnWindow){
    	return winObj;
    }
}

//Added for Bug : 347649
function getMaxFeatures(scrollbars){

	var strFeatures ="";
 	if (isIE_M) {
      strFeatures ="width="+(window.screen.availWidth-10)+",height="+(window.screen.availHeight-35)+",left="+(0)+",top="+(0);
 	} else {
      strFeatures ="width="+window.screen.width+",height="+window.screen.height+",screenX=0,screenY=0";
 	}

 	if (scrollbars) {
       strFeatures += ",scrollbars=yes";
    }

    if (isNS4_M) {
       strFeatures += ",resizable=no";
    } else {
       strFeatures += ",resizable=yes";
    }

 	return strFeatures;

}

//! Public Function showAndGetNonModalDialog()
//!     This function shows a non-modal (regular) dialog and returns the window object.
function showAndGetNonModalDialog(strURL, intWidth, intHeight, bScrollbars) {
	if(strURL && strURL.indexOf("?") > -1) {
		strURL = strURL + "&targetLocation=popup";
	} else {
		strURL = strURL + "?targetLocation=popup";
	}
	var strFeatures = "";
	if(intWidth == "Max"  || intHeight == "Max")
	{
		strFeatures = getMaxFeatures(bScrollbars);
	} else {
		strFeatures = "width=" + intWidth + ",height=" + intHeight;
		var intLeft = parseInt((screen.width - intWidth) / 2);
		var intTop = parseInt((screen.height - intHeight) / 2);
		if (isIE_M) {
			strFeatures += ",left=" + intLeft + ",top=" + intTop;
		} else{
			strFeatures += ",screenX=" + intLeft + ",screenY=" + intTop;
		}
		if (isNS4_M) {
			strFeatures += ",resizable=no";
		} else {
			strFeatures += ",resizable=yes";
		}
		// Passing an additional parameter for scrollbars
		if (bScrollbars)
		{
			strFeatures += ",scrollbars=yes";
		}
	}
	strURL = addSuiteDirectory(strURL);
	var objWindow = null;
	if(isIE_M && encodeURIComponent(strURL).length >= 2048){
		//For IR-068098V6R2012,HF-068098V6R2011x_
		if(isComponentPage(strURL)){
			var objWindow1 = window.open("../common/emxNavigatorDialog.jsp", "NonModalWindow" + (new Date()).getTime(), strFeatures);
			objWindow = findFrame(objWindow1, "content");

		} else {
			objWindow = window.open("../common/emxBlank.jsp", "NonModalWindow" + (new Date()).getTime(), strFeatures);
		}
		var strActionURL = strURL.substring(0,strURL.indexOf("?"));
		var objForm = createRequestForm(strURL);
		objForm.target = objWindow.name;
		objForm.action = strActionURL;
		objForm.method = "post";
		objForm.submit();
	}else{
		if(isComponentPage(strURL)){
			objWindow = openNavigatorDialog(strURL, strFeatures);
		} else {
			objWindow = window.open(strURL, "NonModalWindow" + (new Date()).getTime(), strFeatures);
		}
	}
	registerChildWindows(objWindow, getTopWindow());
	objWindow.focus();
	return objWindow;
}
//added for bug 351827
function createRequestForm(query) {
   var FORM_DATA = new Object();
   var objHiddenWindow = findFrame(getTopWindow(), "submitHiddenFrame");
   if(objHiddenWindow == null){
   		objHiddenWindow = document.createElement("IFRAME");
   		objHiddenWindow.width="0%" ;
   		objHiddenWindow.height="0%" ;
   		objHiddenWindow.name = "submitHiddenFrame";
   		objHiddenWindow.src = "../common/emxBlank.jsp";
   		if(document.body){
   			document.body.appendChild(objHiddenWindow);
   		}else{
   			getTopWindow().document.body.appendChild(objHiddenWindow);
   		}
   	}
   var objHiddenWindowDocument = objHiddenWindow.document;
   if(!objHiddenWindowDocument){
	   objHiddenWindowDocument = objHiddenWindow.contentDocument;
	   objHiddenWindowDocument.write("<body></body>");
   }
   var docfrag = objHiddenWindowDocument.createDocumentFragment();
   var objForm    = objHiddenWindowDocument.createElement('form');
   objForm.name   = "postHiddenForm";
   objForm.id   = "postHiddenForm";

   docfrag.appendChild(objForm);
   var oldform = objHiddenWindowDocument.getElementById("postHiddenForm");
   if(oldform){
	   objHiddenWindowDocument.body.removeChild(oldform);
   }
   objHiddenWindowDocument.body.appendChild(docfrag);

  var separator = ',';
  query = query.substring((query.indexOf('?')) + 1);
  if (query.length < 1) { return false; }
  var keypairs = new Object();
  var numKP = 1;
  while (query.indexOf('&') > -1)
   {
    keypairs[numKP] = query.substring(0,query.indexOf('&'));
    query = query.substring((query.indexOf('&')) + 1);
    numKP++;
  }
  keypairs[numKP] = query;
  for (i in keypairs)
  {
    keyName = keypairs[i].substring(0,keypairs[i].indexOf('='));
    keyValue = keypairs[i].substring((keypairs[i].indexOf('=')) + 1);
    while (keyValue.indexOf('+') > -1)
    {
      keyValue = keyValue.substring(0,keyValue.indexOf('+')) + ' ' + keyValue.substring(keyValue.indexOf('+') + 1);
    }
    keyValue = unescape(keyValue);
    var hiddenEle = document.createElement("input");
    hiddenEle.setAttribute("type","hidden");
    hiddenEle.setAttribute("name", keyName);
    hiddenEle.setAttribute("value", keyValue);
    objForm.appendChild(hiddenEle);
    FORM_DATA[keyName] = keyValue;
  }
  return objForm;
}
//! Public Function showAndGetNonModalDialogWithName()
//!     This function shows a non-modal (regular) dialog with a name and returns the window object.
function showAndGetNonModalDialogWithName(strURL, strName, intWidth, intHeight, bScrollbars) {

	if(strURL && strURL.indexOf("?") > -1)
		strURL = strURL + "&targetLocation=popup";
	else
		strURL = strURL + "?targetLocation=popup";

	var strFeatures = "";

	if(intWidth == "Max" || intHeight == "Max")
	{
		strFeatures = getMaxFeatures(bScrollbars);
	}else
	{

	    strFeatures = "width=" + intWidth + ",height=" + intHeight;
	    var intLeft = parseInt((screen.width - intWidth) / 2);
	    var intTop = parseInt((screen.height - intHeight) / 2);
	    if (isIE_M) {
	            strFeatures += ",left=" + intLeft + ",top=" + intTop;
	    } else{
	            strFeatures += ",screenX=" + intLeft + ",screenY=" + intTop;
	    }
	    if (isNS4_M) {
	            strFeatures += ",resizable=no";
	    } else {
	            strFeatures += ",resizable=yes";
	    }
	    // Passing an additional parameter for scrollbars
	    if (bScrollbars)
	    {
	         strFeatures += ",scrollbars=yes";
	    }
	 }
	strURL = addSuiteDirectory(strURL);
	var objWindow = null;
	if(isComponentPage(strURL)){
		//objWindow = window.open("../common/emxNavigatorDialog.jsp?contentURL=" + encodeURIComponent(strURL), strName, strFeatures);
		objWindow = openNavigatorDialog(strURL, strFeatures);
	}else {
		objWindow = window.open(strURL, strName, strFeatures);
	}
    registerChildWindows(objWindow, getTopWindow());
    objWindow.focus();
    return objWindow;
}

/**
	Method: showNonModalDialogWithName(strURL, intWidth, intHeight, bScrollbars, strWindowName, bReturn)
	strURL : URL to be launched
	intWidth : width of the window
	intHeight : height of the window
	bScrollbars : whether to display scroll bars when the page content is more than the window size
	strWindowName : user defined window name. If this is not passed, default window name will be used with the combination of strProtocol+strHost+strPort
					user can pass empty string if the default windown name to be used
	bReturn : whether to return the window object created or not. By default, this method returns the window object.
*/
function showNonModalDialogWithName(strURL, intWidth, intHeight, bScrollbars, strWindowName, bReturn) {
	if(strURL && strURL.indexOf("?") > -1)
		strURL = strURL + "&targetLocation=popup";
	else
		strURL = strURL + "?targetLocation=popup";


    var sWindowName = "";
    if(typeof strWindowName != "undefined" && strWindowName != ""){
    	sWindowName = strWindowName;
    } else {
    	sWindowName = strProtocol+strHost+strPort;
    }
    sWindowName = sWindowName.replace(/\W/g, "_");
     var strFeatures = "";

     if(intWidth == "Max" || intHeight == "Max")
	 {
		strFeatures = getMaxFeatures(bScrollbars);
	 }else
	 {
	    var strFeatures = "width=" + intWidth + ",height=" + intHeight;
	    var intLeft = parseInt((screen.width - intWidth) / 2);
	    var intTop = parseInt((screen.height - intHeight) / 2);

	    if (isIE_M) {
	            strFeatures += ",left=" + intLeft + ",top=" + intTop;
	    } else{
	            strFeatures += ",screenX=" + intLeft + ",screenY=" + intTop;
	    }
	    if (isNS4_M) {
	            strFeatures += ",resizable=no";
	    } else {
	            strFeatures += ",resizable=yes";
	    }
	    // Passing an additional parameter for scrollbars
	    if (bScrollbars)
	    {
	         strFeatures += ",scrollbars=yes";
	    }
    }

    strURL = addSuiteDirectory(strURL);

    var objWindow = window.open(strURL, sWindowName, strFeatures);
    registerChildWindows(objWindow, getTopWindow());
    objWindow.focus();
    if(bReturn != false){
    return objWindow;
    }
}

//! Public Function registerChildWindows()
//!     This function registers a child window with the parent
//!     window in order to keep track and close when a logout occurs.
function registerChildWindows(objChild, objParent) {
    try{
        var limit = 10;
        //make sure we have the childWindows array
        while(!objParent.childWindows && limit > 0){
            limit--;
            //modified for bug : 347120
            if(objParent.getWindowOpener())
            	objParent = objParent.getWindowOpener().getTopWindow();
            else if(getTopWindow().getWindowOpener())
            	objParent = getTopWindow().getWindowOpener().getTopWindow();
        }
        //make a local pointer so we can just call getTopWindow().childWindows later
        //objChild represents a newly created window and is therefore equal to "top"
        if (objParent.childWindows) {
        objChild.childWindows = objParent.childWindows;
        objParent.childWindows[objParent.childWindows.length] = objChild;
        }
        else if (objParent.getTopWindow().getWindowOpener() != null) {
            if(!objParent.getWindowOpener().closed) {
                var objParentTop = objParent.getWindowOpener().getTopWindow();
                registerChildWindows(objChild, objParentTop);
            }
        }
    }catch(e){
	   if(-2146828218 != e.number && -2147418094 != e.number && -2147417848 != e.number)
	   {
    	if(e.description == ""){
		alert(emxUIConstants.STR_JS_AnExceptionOccurred + " " + emxUIConstants.STR_JS_ErrorName + " " + e.name
		+ emxUIConstants.STR_JS_ErrorDescription + " " + e.description
		+ emxUIConstants.STR_JS_ErrorNumber + " " + e.number
		+ emxUIConstants.STR_JS_ErrorMessage + " " + e.message)
        } else {
        throw new Error("registerChildWindows had the following error: " + e.description);
	   }
    }

}
}
//! Public Function closeAllChildWindows()
//!     This function closes all registered child windows.
function closeAllChildWindows() {
	if(typeof sessionStorage != "undefined"){
			sessionStorage.removeItem('uiConstantsCache');
	}
    //close all windows that are stored in childWindows
    if(bPageHistory == true) {
        bPageHistory = false;
        return;
    }
    if (getTopWindow().childWindows)
    {
        for (var i=0; i < getTopWindow().childWindows.length; i++)
        {
            if(isMac_M && isIE_M)
            {
                eval("try { \
                    if (getTopWindow().childWindows[i] && !getTopWindow().childWindows[i].closed) \
                        getTopWindow().childWindows[i].close(); \
                } catch(e) { \
                }");
             }else{
                    try
                    {
                if (getTopWindow().childWindows[i] && !getTopWindow().childWindows[i].closed)
                    getTopWindow().childWindows[i].close();
                } catch(ex) {
                }

            }
        }
    }
}
//! Public Function addSuiteDirectory()
//!     This function add the URL parameter "emxSuiteDirectory"
//!     to the URL, if it is "emxTree.jsp?.."
function addSuiteDirectory(strURL) {
        var strNewURL = strURL;
        if (strNewURL.indexOf("emxTree.jsp?") > -1){
                var strLoc = document.location.href;
                var strParam;
                var intIndex = strLoc.lastIndexOf("/");
                strLoc = strLoc.substring(0,intIndex);
                intIndex = strLoc.lastIndexOf("/");
                strLoc = strLoc.substring(intIndex+1,strLoc.length);
                if (strLoc) {
                        strParam = "emxSuiteDirectory=" + strLoc;
                    if (strNewURL.indexOf("emxSuiteDirectory=") == -1) {
                                strNewURL += (strNewURL.indexOf('?') > -1 ? '&' : '?') + strParam;
                        }
                }
    }
        return strNewURL;
}

//------------------------------------------------------------
function emxUICoreModalDialog(strURL, intWidth, intHeight, blnScrollbars, applyIEMask) {
        this.contentWindow = null;
        this.height = intHeight;
        this.parentWindow = null;
        this.scrollbars = !!blnScrollbars;
        this.url = strURL;
        this.width = intWidth;
		this.applyIEMask = applyIEMask;
}

emxUICoreModalDialog.prototype.capture = function () {

};

emxUICoreModalDialog.prototype.captureMouse = function (objWindow) {
        if (!objWindow) {
                throw new Error("No window provided for capture. (emxUICoreModalDialog.prototype.captureMouse)");
        }
        if (objWindow.frames.length > 0) {
                for (var i=0; i < objWindow.frames.length; i++) {
                        this.captureMouse(objWindow.frames[i]);
                }
        }
            this.capture(objWindow);
};

emxUICoreModalDialog.prototype.counter = 0;
emxUICoreModalDialog.prototype.checkFocus = function () {
    try{
                if (this.contentWindow && !this.contentWindow.closed) {

                    if (this.contentWindow.modalDialog && this.contentWindow.modalDialog.contentWindow
                            && !this.contentWindow.modalDialog.contentWindow.closed) {
                            this.contentWindow.modalDialog.checkFocus();
                    } else {
                            this.contentWindow.focus();
                    }

        } else {
				//IR-057466V6R2011x
                this.release(this.parentWindow);
                this.releaseMouse(this.parentWindow);
        }
        }catch(e){
            //need to resolve timing of access to window
            this.counter++;
            if(this.counter < 10){
                    var oThis = this;
                    setTimeout(function(){oThis.checkFocus();},500);
            }else{
        //Change the condition for Bug#376863
		if(-2146828218 != e.number && -2147418094 != e.number && -2146823277!= e.number)
		{
    	if(e.description != ""){
    		alert(emxUIConstants.STR_JS_AnExceptionOccurred + " " + emxUIConstants.STR_JS_ErrorName + " " + e.name
    				+ emxUIConstants.STR_JS_ErrorDescription + " " + e.description
    				+ emxUIConstants.STR_JS_ErrorNumber + " " + e.number
    				+ emxUIConstants.STR_JS_ErrorMessage + " " + e.message)
        }
        //Start:25-08-09:OEP:Bug#376863
        //else {
            //        alert(e.description);
           // }
        //End:OEP
		}
        }
        }
};

emxUICoreModalDialog.prototype.getFeatureString = function () {
        return "";
};

//Added for Bug : 347649
emxUICoreModalDialog.prototype.getMaxFeatures = function ()
{
		var strFeatures ="";
        if (isIE_M) {
         	 strFeatures ="width="+(window.screen.availWidth-10)+",height="+(window.screen.availHeight-35)+",left="+(0)+",top="+(0);
     	} else {
          	 strFeatures ="width="+window.screen.width+",height="+window.screen.height+",resizable=yes,screenX=0,screenY=0,modal=yes";
     	}

     	if (this.scrollbars) {
           strFeatures += ",scrollbars=yes";
        }
     	return strFeatures;
};

emxUICoreModalDialog.prototype.release = function () {

};

emxUICoreModalDialog.prototype.releaseMouse = function (objWindow) {
	if (!objWindow) {
		//objWindow = this.parentWindow;
		return;
	}
	for (var i=0; i < objWindow.frames.length; i++) {
		this.releaseMouse(objWindow.frames[i]);
	}
	this.release(objWindow);
};

emxUICoreModalDialog.prototype.show = function () {
        if (!this.contentWindow || this.contentWindow.closed) {
                this.parentWindow.getTopWindow().modalDialog = this;
                if(isComponentPage(this.url)){
            		//this.contentWindow = window.open("../common/emxNavigatorDialog.jsp?contentURL=" + encodeURIComponent(this.url),"ModalDialog" + (new Date()).getTime(), this.getFeatureString());
            		this.contentWindow = openNavigatorDialog(this.url, this.getFeatureString());

            	} else {
					if(this.url.length >= 2048) {
                		this.contentWindow = window.open("../common/emxBlank.jsp", "NonModalWindow" + (new Date()).getTime(), this.getFeatureString());
	            		var strActionURL = this.url.substring(0,this.url.indexOf("?"));
	            		var objForm = createRequestForm(this.url);
	            		objForm.target = this.contentWindow.name;
	            		objForm.action = strActionURL;
	            		objForm.method = "post";
	            		objForm.submit();
                	} else {
            			this.contentWindow = window.open(this.url, "ModalDialog" + (new Date()).getTime(), this.getFeatureString());
            		}
            	}
                registerChildWindows(this.contentWindow, getTopWindow());
                this.capture(this.parentWindow);
                this.captureMouse(this.parentWindow);
                //Addded for Bug 368004
                if(getTopWindow().registerSearchWindows) {
                	getTopWindow().registerSearchWindows(this.contentWindow);
                }
        }

        if (!this.contentWindow) {
                throw new Error("The modal dialog failed to create the new window. (emxUICoreModalDialog.prototype.show)");
        }

        this.contentWindow.focus();
};


//-----------------------------------------------------------------


function emxUIMozillaModalDialog(objParent, strURL, intWidth, intHeight, blnScrollbars) {
        emxUICoreModalDialog.call(this, strURL, intWidth, intHeight, blnScrollbars);
        this.parentWindow = objParent.getTopWindow();

        var objThis = this;
        this.fnTemp = function (objEvent) {
                objThis.checkFocus();
                objEvent.stopPropagation();
                objEvent.preventDefault();
        };
}

emxUIMozillaModalDialog.prototype = new emxUICoreModalDialog;

emxUIMozillaModalDialog.prototype.getFeatureString = function () {

		if( this.width == "Max" || this.height == "Max"){
			return this.getMaxFeatures();
		}

        var strFeatures = "width=" + this.width + ",height=" + this.height;
        strFeatures += ",resizable=yes,modal=yes";
      	try{
        	var intLeft = parseInt((screen.width - this.width) / 2);
        	var intTop = parseInt((screen.height - this.height) / 2);
       		strFeatures += ",screenX=" + intLeft + ",screenY=" + intTop;
        }
        catch(e)
        {
        	strFeatures += ",screenX=212,screenY=84";
        }

        if (this.scrollbars) {
                strFeatures += ",scrollbars=yes";
        }
        return strFeatures;
};

emxUIMozillaModalDialog.prototype.capture = function (objWindow) {
        if (!objWindow) {
                throw new Error("No window provided for release. (emxUIMozillaModalDialog.prototype.release)");
        }
        if (typeof objWindow.name =="string" && objWindow.name.toLowerCase().indexOf("hidden") > -1) return;
        objWindow.addEventListener("click", this.fnTemp, true);
		objWindow.addEventListener("dblclick", this.fnTemp, true);
        objWindow.addEventListener("mousedown", this.fnTemp, true);
        objWindow.addEventListener("mouseup", this.fnTemp, true);
        objWindow.addEventListener("focus", this.fnTemp, true);
};

emxUIMozillaModalDialog.prototype.release = function (objWindow) {
        if (!objWindow) {
                return;
                throw new Error("No window provided for release. (emxUIMozillaModalDialog.prototype.release)");
        }
        if (typeof objWindow.name =="string" && objWindow != objWindow.top && objWindow.name.toLowerCase().indexOf("hidden") > -1) return;
        try{
            objWindow.removeEventListener("click", this.fnTemp, true);
			objWindow.removeEventListener("dblclick", this.fnTemp, true);
            objWindow.removeEventListener("mousedown", this.fnTemp, true);
            objWindow.removeEventListener("mouseup", this.fnTemp, true);
            objWindow.removeEventListener("focus", this.fnTemp, true);
        }catch (objError) {
        }
};

//-----------------------------------------------------------------

function emxUIIEModalDialog(objParent, strURL, intWidth, intHeight, blnScrollbars, applyIEMask) {
        emxUICoreModalDialog.call(this, strURL, intWidth, intHeight, blnScrollbars, applyIEMask);
        this.parentWindow = objParent.getTopWindow();

        var objThis = this;
        this.fnTemp = function () {
				//IR-057466V6R2011x
                objThis.checkFocus();
                return false;
        };
}

emxUIIEModalDialog.prototype = new emxUICoreModalDialog;

emxUIIEModalDialog.prototype.getFeatureString = function () {

		if(this.width == "Max" || this.height == "Max"){
			return this.getMaxFeatures();
		}
        var strFeatures = "width=" + this.width + ",height=" + this.height + ",resizable=yes";
        var intLeft = parseInt((screen.width - this.width) / 2);
        var intTop = parseInt((screen.height - this.height) / 2);
        strFeatures += ",left=" + intLeft + ",top=" + intTop;
        if (this.scrollbars) {
                strFeatures += ",scrollbars=yes";
        }
        return strFeatures;
};

emxUIIEModalDialog.prototype.capture = function (objWindow) {
        if (!objWindow) {
                throw new Error("No window provided for release. (emxUIIEModalDialog.prototype.release)");
        }
        try{
            var objCapture = objWindow.document.body;
            if (!objCapture) return;
            objCapture.setCapture();
            objCapture.onclick = this.fnTemp;
            objCapture.ondblclick = this.fnTemp;
            objCapture.onmousedown = this.fnTemp;
            objCapture.onmouseup = this.fnTemp;
            objCapture.onfocus = this.fnTemp;
            objCapture.oncontextmenu = this.fnTemp;
        }catch(e){

        }

};

emxUIIEModalDialog.prototype.release = function (objWindow) {
        if (!objWindow) {
                return;
                throw new Error("No window provided for release. (emxUIIEModalDialog.prototype.release)");
        }
        try{
            var objCapture = objWindow.document.body;
            if (!objCapture) return;
            objCapture.releaseCapture();
            objCapture.onclick = null;
            objCapture.ondblclick = null;
            objCapture.onmouseover = null;
            objCapture.onmouseout = null;
            objCapture.onmousemove = null;
            objCapture.onmousedown = null;
            objCapture.onmouseup = null;
            objCapture.onfocus = null;
            objCapture.oncontextmenu = null;
        }catch(e){}
};

emxUIIEModalDialog.prototype.show = function () {
        if (!this.contentWindow || this.contentWindow.closed) {
                this.parentWindow.getTopWindow().modalDialog = this;
                if(isComponentPage(this.url)){
                	//this.contentWindow = window.open("../common/emxNavigatorDialog.jsp?contentURL=" + encodeURIComponent(this.url), "ModalDialog" + (new Date()).getTime(), this.getFeatureString());
                	this.contentWindow = openNavigatorDialog(this.url, this.getFeatureString(), this.applyIEMask);
                } else {
                	if(this.url.length >= 2048) {
                		this.contentWindow = window.open("../common/emxBlank.jsp", "NonModalWindow" + (new Date()).getTime(), this.getFeatureString());
	            		var strActionURL = this.url.substring(0,this.url.indexOf("?"));
	            		var objForm = createRequestForm(this.url);
	            		objForm.target = this.contentWindow.name;
	            		objForm.action = strActionURL;
	            		objForm.method = "post";
	            		objForm.submit();
                	} else {
                		this.contentWindow = window.open(this.url, "ModalDialog" + (new Date()).getTime(), this.getFeatureString());
				contentWindowRef = this.contentWindow;
				if(this.applyIEMask){
					var popupHandle = setInterval(function() {
      					if (contentWindowRef.closed) {
						restoreIEMask();
        					clearInterval(popupHandle);
                	}
    					}, 400);
                	}
                }
                	}
				if(this.applyIEMask){
					if(this.parentWindow.jQuery('div#windowshade')){
						this.parentWindow.jQuery('div#layerOverlay').removeClass('search-mask') ;
					}
					this.parentWindow.jQuery("div#layerOverlay").css('display', 'block');
					this.parentWindow.jQuery("div#layerOverlay").css('top',0);
					//this.contentWindow.onunload = function () { restoreIEMask(); };
                }
                registerChildWindows(this.contentWindow, getTopWindow());

                //IR-077244V6R2012 : Moved inside the if block
                this.capture(this.parentWindow);
                this.captureMouse(this.parentWindow);
        }
        if (!this.contentWindow) {
                throw new Error("The modal dialog failed to create the new window. (emxUICoreModalDialog.prototype.show)");
        }
        //Added for Bug 368004
        if(getTopWindow().registerSearchWindows) {
           getTopWindow().registerSearchWindows(this.contentWindow);
        }
        this.contentWindow.focus();
};

function restoreIEMask() {
	
    if(getTopWindow().jQuery('div#windowshade')){
	   getTopWindow().jQuery('div#layerOverlay').addClass('search-mask') ;
	}
	getTopWindow().jQuery("div#layerOverlay").css('display', 'none');
	getTopWindow().jQuery("div#layerOverlay").css('top',0);

}


//! Public Function closePopupWindow(win)
//!     This function closes windows.
function closePopupWindow(win) {
	
    if (win.getWindowOpener()) {
        var objOpener = win.getWindowOpener();
        objOpener = null;
    }
	win.closeWindow();
}


function isTablePage(strURL){
	var itp = false;
	var isTable = false;
	var isIndentedTable = false;
	var isGridTable = false;
	var index =  strURL.indexOf(".jsp");
	var subStr = strURL.substring(0,index);
	if(subStr.indexOf("emxTable") >= 0){
		isTable = true;
	}
	
	if(subStr.indexOf("emxIndentedTable") >= 0){
		isIndentedTable = true;
	}
	
	if(subStr.indexOf("emxGridTable") >= 0){
		isGridTable = true;
	}
	
	
	if(isTable || isIndentedTable || isGridTable ){
		itp = true;
	} else if(isIndentedTable){
		if(strURL.indexOf("IsStructureCompare=true") >= 0 || strURL.indexOf("IsStructureCompare=TRUE") >= 0 || strURL.indexOf("IsStructureCompare=True") >= 0){
			itp = false;
		} else {
			itp = true;
		}
	}
	return itp;
}

function isFormPage(strURL) {
	var ifp = false;
	var index =  strURL.indexOf(".jsp");
	var subStr = strURL.substring(0,index);
	if(subStr.indexOf("emxForm") >= 0){
		ifp = true;
	}
	return ifp;
}

function isTreePage(strURL) {
	var ifp = false;
	var index =  strURL.indexOf(".jsp");
	var subStr = strURL.substring(0,index);
	if(subStr.indexOf("emxTree") >= 0){
		ifp = true;
	}
	return ifp;
}

function isNavigatorPopup(strURL) {
	var inp = false;
	var index =  strURL.indexOf(".jsp");
	var subStr = strURL.substring(0,index);
	if(subStr.indexOf("emxNavigatorSubmitPopup") >= 0){
		inp = true;
	}
	return inp;
}

function isComponentPage(strURL) {
	var icp = false;
	if(strURL.indexOf("emxNavigatorDialog.jsp") < 0){
		icp = (isTablePage(strURL) || isFormPage(strURL) || isTreePage(strURL) ||  isNavigatorPopup(strURL))? true : false;
	}
	return icp;
}

function isNavigatorDialog(strURL) {
	var ind = false;
	if(strURL.indexOf("emxNavigatorDialog.jsp") >= 0){
		ind = true;
	}
	return ind;
}

function showShortcutPanel(){
	getTopWindow().showShortcutDialog();
}

function openNavigatorDialog(strURL, strFeatures, isApplyIEMask){
	var dialogPage = "../common/emxNavigatorDialog.jsp";
	var objWindow = window.open(dialogPage, "NonModalWindow" + (new Date()).getTime(), strFeatures);
	objWindow.name = objWindow.name + "||" + strURL;
	if(isApplyIEMask){
		var popupTick = setInterval(function() {
      		if (objWindow.closed) {
			restoreIEMask();
        		clearInterval(popupTick);
      		}
    		}, 400);
	}
	return objWindow;
}
function updateShortcutMap(update, id){
	var key = getTopWindow().window.name;
	if(!key){
		key="Shortcut_Content";
	}
	$.ajax({
		   url: "emxShortcutGetData.jsp?action=updateShortcutInfo&key="+key+"&id="+id+"&update="+update,
		   cache: false

	});
}

function adjustSearchLeftPanelLayout(objWin){
	var searchPanelWidth = (jQuery(getTopWindow()).width())/4 ;
	if(searchPanelWidth < 300)
		searchPanelWidth = 300;
	else if(searchPanelWidth >400)
		searchPanelWidth = 400;

	objWin.jQuery("#searchPanel").css("width",searchPanelWidth+"px");
	objWin.jQuery("#refinementPanel").css("width",searchPanelWidth+"px");
	searchPanelWidth++;
	objWin.jQuery("#divSearchHead").css("left",searchPanelWidth+"px");
	objWin.jQuery("#windowshade-content").css("left",searchPanelWidth+"px");
	objWin.jQuery("#searchBody").css("top",(objWin.jQuery("#searchOptions").height() + objWin.jQuery("#searchHead").height())+"px");
}

// To Show Transient Message at the bottom right corner
// messageType: error, warning, primary, success
function showTransientMessage(msg, messageType) {
	var options={
			message:msg,
			messageType:messageType
	}
	showGenericTransientMessage(options);
}

function showGenericTransientMessage(options) {
	if(! options.messageType){
		options.messageType = "error";
	}

	 require(['DS/UIKIT/Alert'], function (Alert) {
         var myAlert = new Alert({
          closable: (options.closable==undefined)?true:options.closable,
          visible: (options.visible ==undefined)?true:options.visible,
          hideDelay: (options.hideDelay == undefined)?4000:options.hideDelay,
          autoHide: (options.autoHide==undefined)?true:options.autoHide
         }).inject(getTopWindow().document.body);
         myAlert.add({ className: options.messageType, message: options.message});
         if(options.events){
         for(var i=0;i<options.events.eventName.length;i++){
          myAlert.addEvent(options.events.eventName[i],options.events.eventfunction[i]);
         }
       }
	 });
}

function isFullSearchPage(strURL) {
	var isFTS = false;
	if(strURL.indexOf("emxFullSearch.jsp") >= 0){
		isFTS = true;
	}
	return isFTS;
}

function getViewMyCompanyURL() {
	jQuery("iframe#content").attr("src", emxUIConstants.VIEWMYCOMPANYURL);
}
