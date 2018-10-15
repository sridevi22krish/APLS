<%--  emxpartDisconnectBOM.jsp  - To disconnect bom for a part.
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ page import="com.matrixone.apps.engineering.Part" %>
<%@ page import="com.matrixone.apps.domain.util.ContextUtil" %>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import ="com.matrixone.apps.domain.DomainConstants"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  boolean isMBOMInstalled = com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context);
    // Variable declarations
    String sSelectedId = "";
    String sParentId   = "";
    String sStates     = "";

    // Get the parameters from request object
    String objectId         = emxGetParameter(request,"objectId");
    String uiType           = emxGetParameter(request,"uiType");
    String[] sCheckBoxArray = emxGetParameterValues(request, "emxTableRowId");
    String language         = context.getSession().getLanguage();
    String isFromRMB = emxGetParameter(request, "isFromRMB");
	String sExpandLevel = emxGetParameter(request, "expandLevel");
    String selPartRowId = "";
	StringList slRemoveForSynchro = new StringList();
	String sRemoveForSynchro = "";
	
    if("true".equalsIgnoreCase(isFromRMB)) {
        StringList tempList = FrameworkUtil.split(" "+sCheckBoxArray[0], "|");
        selPartRowId     = ((String)tempList.get(3)).trim(); 
    }
    
    String selectedRows = StringUtil.join(sCheckBoxArray, "~");
	
	StringList slRows = FrameworkUtil.split(selectedRows, "~");
				
	Iterator<String> itslRows = slRows.iterator();
	while(itslRows.hasNext()){
		
		StringTokenizer st1 = new StringTokenizer((String)itslRows.next(), "|");
		String sRelId1 = st1.nextToken();
		String sObjId1 = st1.nextToken();
		
		DomainObject doPart = DomainObject.newInstance(context,sObjId1);
		String strObjType = (String) doPart.getInfo(context, DomainConstants.SELECT_TYPE);
		
		if (!(strObjType.equals("AT_C_DESIGN_PART") || strObjType.equals("AT_C_COS") || strObjType.equals("AT_C_STANDARD_PART"))) {
			if(!slRemoveForSynchro.contains("false")){
				slRemoveForSynchro.add("false");
				sRemoveForSynchro+="false";
			}
		}else{
			if(!slRemoveForSynchro.contains("true")){
				slRemoveForSynchro.add("true");
				sRemoveForSynchro+="true";
			}		
		}
	}
	
	String strWarningCFReplaceByNewPartMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	context.getLocale(),"emxEngineeringCentral.BOM.ReplaceByNewPart"); 

    
    String strErrMsg = DomainConstants.EMPTY_STRING;
	String sBOMFilterVal = "";
	String[] sBOMFilterValArray = emxGetParameterValues(request, "ENCBillOfMaterialsViewCustomFilter");
	if(sBOMFilterValArray != null) {
		sBOMFilterVal = sBOMFilterValArray[0];
	}
	if(isMBOMInstalled && "common".equalsIgnoreCase(sBOMFilterVal)){
		String strSelectedPartId = DomainConstants.EMPTY_STRING;
		String strSelectedRelId = DomainConstants.EMPTY_STRING;
		String parentPartId = DomainConstants.EMPTY_STRING;
		String lastRevId  = DomainConstants.EMPTY_STRING;
		StringList slRowInfo = null;
		String sRelType = DomainConstants.EMPTY_STRING;
		String sEBOMSubstituteRel = PropertyUtil.getSchemaProperty("relationship_EBOMSubstitute");
		for (int i = 0; i < sCheckBoxArray.length; i++) {
			strSelectedPartId = (String) sCheckBoxArray[i];
			if(!strSelectedPartId.startsWith("|")){
				slRowInfo = FrameworkUtil.split(strSelectedPartId, "|");
				strSelectedRelId = (String) slRowInfo.get(0);
				strSelectedPartId = (String) slRowInfo.get(1);
			
				if(!"0".equalsIgnoreCase((String) slRowInfo.get(slRowInfo.size()-1)) && UIUtil.isNotNullAndNotEmpty(strSelectedRelId)){
				   sRelType = MqlUtil.mqlCommand(context, "print connection $1 select $2 dump",strSelectedRelId,DomainConstants.SELECT_NAME);
				   parentPartId = (String)slRowInfo.get(2);
				   lastRevId  = DomainObject.newInstance(context, parentPartId).getInfo(context, DomainConstants.SELECT_LAST_ID);
				   if(!parentPartId.equalsIgnoreCase(lastRevId) && (sEBOMSubstituteRel.equalsIgnoreCase(sRelType) || DomainConstants.RELATIONSHIP_ALTERNATE.equalsIgnoreCase(sRelType))) {	
					   strErrMsg = EnoviaResourceBundle.getProperty(context,"emxMBOMStringResource", context.getLocale(),"emxMBOM.ManualFloat.ALtSubNotAllowdForOldRevisions");	
			 	      break;
				   }
				}   
				if(UIUtil.isNotNullAndNotEmpty(strSelectedPartId)){
			 	  String strPolicy = MqlUtil.mqlCommand(context, "print bus $1 select $2 dump",strSelectedPartId,"policy");
			  	  if(DomainConstants.POLICY_MANUFACTURER_EQUIVALENT.equalsIgnoreCase(strPolicy)){
			  		  if(UIUtil.isNotNullAndNotEmpty(strSelectedRelId)) {
			  			sRelType = MqlUtil.mqlCommand(context, "print connection $1 select $2 dump",strSelectedRelId,DomainConstants.SELECT_NAME);
			  			 if(UIUtil.isNotNullAndNotEmpty(sRelType) && (sEBOMSubstituteRel.equalsIgnoreCase(sRelType) || DomainConstants.RELATIONSHIP_ALTERNATE.equalsIgnoreCase(sRelType))) {
			  				strErrMsg = i18nNow.getI18nString("emxMBOM.Common.MsgForAlternateAndSubstitute","emxMBOMStringResource", language);
							   break;
			  			 }
			  			
			  		  }
			  	  }
		    	}
			}
		}
	}
    //Property entries
    String fnUniqueness = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","FindNumberUnique");
    String rdUniqueness = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","ReferenceDesignatorUnique");

    String sSymbolicRelEBOMName  = FrameworkUtil.getAliasForAdmin(context,
                                                                  "relationship",
                                                                  DomainConstants.RELATIONSHIP_EBOM,
                                                                  true);

    String propAllowLevel        = (String)FrameworkProperties.getProperty(context, "emxEngineeringCentral.Part.RestrictPartModification");

   /* String sConformAsStored      = i18nNow.getI18nString("emxEngineeringCentral.Common.CannotRemoveConnectedParts4",
                                                         "emxEngineeringCentralStringResource",
                                                           language);

    String strPStateRestriction  = i18nNow.getI18nString("emxEngineeringCentral.Common.CannotRemoveConnectedParts3",
                                                         "emxEngineeringCentralStringResource",
                                                         language);

    String strWrongSelection     = i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.DeleteSelectParts",
                                                     "emxEngineeringCentralStringResource",
                                                     language);

    String RemoveRootNode     =  i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.RemoveRootNodeError",
                                                     "emxEngineeringCentralStringResource",
                                                     language);
    String strErrorMessage        = i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.RemoveFail",
                                                     "emxEngineeringCentralStringResource",
                                                     language);
    String strProcessing            =  i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.Processing",
                                                     "emxEngineeringCentralStringResource",
                                                     language);
    //Added R208.HF1 - Starts
    String inlineErrorMessage       = i18nNow.getI18nString("emxFramework.FreezePane.SBEditActions.RowSelectError",
                                                        "emxFrameworkStringResource", language);*/
                                                        
           String sConformAsStored      = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",
                                                                  context.getLocale(),"emxEngineeringCentral.Common.CannotRemoveConnectedParts4");

           String strPStateRestriction  = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",
        		   context.getLocale(),"emxEngineeringCentral.Common.CannotRemoveConnectedParts3");

           String strWrongSelection     = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",
                                                            context.getLocale(),"emxEngineeringCentral.Part.BOM.DeleteSelectParts");

           String RemoveRootNode     =  EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",
                                                            context.getLocale(),"emxEngineeringCentral.Part.BOM.RemoveRootNodeError");
           String strErrorMessage        = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",
                                                            context.getLocale(),"emxEngineeringCentral.Part.BOM.RemoveFail");
           String strProcessing            =  EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",
                                                            context.getLocale(),"emxEngineeringCentral.Part.BOM.Processing");
           //Added R208.HF1 - Starts
           String inlineErrorMessage       = EnoviaResourceBundle.getProperty(context ,"emxFrameworkStringResource", context.getLocale(),"emxFramework.FreezePane.SBEditActions.RowSelectError");
    //Added R208.HF1 - Ends

    // Changes for CST. Start	
    
    Boolean  blnIsApplyAllowed = true;
    boolean isCamInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMCostAnalytics",false,null,null);

    if(isCamInstalled) {
    	Boolean  bCheck = true;
		DomainObject camDom = new DomainObject(objectId);
    	if(camDom.getInfo(context,DomainConstants.SELECT_POLICY).equals(PropertyUtil.getSchemaProperty(context,"policy_CostPart")))
    	{
    		blnIsApplyAllowed = (Boolean)JPO.invoke(context,"CATotalCostBase",null,"isDisconnectAllowed",sCheckBoxArray,Boolean.class);
    	}
    }
	
    if(!blnIsApplyAllowed)
	{
		%>
		<script type="text/javascript">
		//XSSOK
		//alert("<%=i18nNow.getI18nString("emxCostAnalytics.EBOMPowerView.RemoveSlected.RemoveECFromEC","emxCostAnalyticsStringResource",language)%>");
		alert("<%=EnoviaResourceBundle.getProperty(context ,"emxCostAnalyticsStringResource",context.getLocale(),"emxCostAnalytics.EBOMPowerView.RemoveSlected.RemoveECFromEC")%>");
		</script>
<%
    } else if(!UIUtil.isNullOrEmpty(strErrMsg)){
  	 	%>
    		<script type="text/javascript">
    		alert("<%=strErrMsg%>");
    		</script>
    	<%
        
    }
   
    else {
	// Changes for CST. End
 
	if(uiType != null && uiType.equals("structureBrowser")){

        if(propAllowLevel != null && !"null".equals(propAllowLevel)){
            StringList slPropAllowList = FrameworkUtil.split(propAllowLevel, "|");
            for(int seeta=0; seeta<slPropAllowList.size(); seeta++){
                String sSelectState = (String)slPropAllowList.get(seeta);
                if(sStates.length() != 0){
                    sStates += ",";
                }
                sStates += FrameworkUtil.lookupStateName(context, DomainConstants.POLICY_EC_PART, sSelectState);
            }
        }
    %>
        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="JavaScript">
            //Added for V6R2009.HF0.2 - Starts
            var refresh        = false;
            var warnDelNames   = "";
            var errorDontAllow = "";
            //XSSOK
            var sym_EBOM       = "<%=sSymbolicRelEBOMName%>";
          //XSSOK
            var states         = "<%=sStates%>";
          //XSSOK
            var warnDelMsg     = "<%=strWrongSelection%>\n";
          //XSSOK
            var errordontMsg   = "<%=strPStateRestriction%>\n";
          //XSSOK
            var removeError    = "<%=RemoveRootNode%>";
          //XSSOK
            var fnUniqueness   = "<%=fnUniqueness%>";
          //XSSOK
            var rdUniqueness   = "<%=rdUniqueness%>";
            var removeMsg      = "";
            var postXML        = null;
            var theRoot        = null;
            var dialogLayerOuterDiv, dialogLayerInnerDiv, iframeEl;

//Modified for IR042348V6R2011
            var contentFrame     = findFrame(parent,"listHidden");
            var mxRoot               = contentFrame.parent.oXML.documentElement;
            var dupemxUICore    = contentFrame.parent.emxUICore;
            var dupcolMap           = contentFrame.parent.colMap;
            var duppostDataXML = contentFrame.parent.postDataXML.documentElement;
            //Added for V6R2009.HF0.2 - Ends
        </script>

        <script language="JavaScript">
        /**************************************************************************/
        /* function trim() - This function trims at both the ends for a given     */
        /* String value.                                                          */
        /* Added for V6R2009.HF0.2                                                */
        /**************************************************************************/
        function trim(str){
            try{
            while(str.length != 0 && str.substring(0,1) == ' '){
                str = str.substring(1);
            }

            while(str.length != 0 && str.substring(str.length -1) == ' '){
                str = str.substring(0, str.length -1);
            }
            }
            catch(e){
                throw e;
            }
            return str;
        }

        /**************************************************************************/
        /* function addMask() - this function doesn't allows the user to do       */
        /* anything while processing Resequence operation.                        */
        /* Added for V6R2009.HF0.2                                                */
        /**************************************************************************/
        function addMask(){
            try{
                dialogLayerOuterDiv = contentFrame.parent.document.createElement("div");
                dialogLayerOuterDiv.className = "mx_divLayerDialogMask";
                contentFrame.parent.document.body.appendChild(dialogLayerOuterDiv);

                if (isIE) {
                    iframeEl = contentFrame.parent.document.createElement("IFRAME");
                    iframeEl.frameBorder = 0;
                    iframeEl.src = "../common/emxBlank.jsp";
                    iframeEl.allowTransparency = true;
                    contentFrame.parent.document.body.insertBefore(iframeEl, dialogLayerOuterDiv);
                }

                dialogLayerInnerDiv = contentFrame.parent.document.createElement("div");
                dialogLayerInnerDiv.className = "mx_alert";
                dialogLayerInnerDiv.setAttribute("id", "mx_divLayerDialog");

                dialogLayerInnerDiv.style.top = contentFrame.parent.editableTable.divPageHead.offsetHeight + 10 + "px";
                dialogLayerInnerDiv.style.left = contentFrame.parent.getWindowWidth()/3 + "px";
                contentFrame.parent.document.body.appendChild(dialogLayerInnerDiv);

                var CENTER = contentFrame.parent.document.createElement("CENTER");
                var BOLD = contentFrame.parent.document.createElement("b");
                if(isIE) {
                	//XSSOK
                    BOLD.innerText = "<%=strProcessing%>";
                }else {
                	//XSSOK
                    BOLD.textContent = "<%=strProcessing%>";
                }

                CENTER.appendChild(BOLD);
                dialogLayerInnerDiv.appendChild(CENTER);
                contentFrame.parent.turnOnProgress();
            }
            catch(e){
            }
        }

        /**************************************************************************/
        /* function removeMask() - Once the Resequence process is finished, it    */
        /* removes the added Mask to the BOM Page.                                */
        /* Added for V6R2009.HF0.2                                                */
        /**************************************************************************/
        function removeMask(){
            try{
                contentFrame.parent.document.body.removeChild(dialogLayerInnerDiv);
                contentFrame.parent.document.body.removeChild(dialogLayerOuterDiv);
                if (isIE)
                {
                    contentFrame.parent.document.body.removeChild(iframeEl);
                }
                contentFrame.parent.turnOffProgress();
            }
            catch(e){
            }
        }
        /**************************************************************************/
        /* function checkForNewlyAddedSubstitutesAndAlternates() - this           */
        /* function helps to remove newly added or existing Substite/Alterante/   */
        /* Split Quantity objects if the primary part is removed                  */
        /* Added for V6R2009.HF0.2                                                */
        /**************************************************************************/
        function checkForNewlyAddedSubstitutesAndAlternates(checkedRow){
            try{
                var returnFlag = false;
                var iLevel = checkedRow.getAttribute("level");
                var FN = "";
                var RD = "";
                var objColumnFN  = dupcolMap.getColumnByName("Find Number");
                //if(fnUniqueness.toLowerCase()=="true"){ //034461
                    var objFN    = dupemxUICore.selectSingleNode(checkedRow, "c["+objColumnFN.index+"]");
                    FN  = dupemxUICore.getText(objFN);
                //} //034461

                var objColumnRD  = dupcolMap.getColumnByName("Reference Designator");
                //if(rdUniqueness.toLowerCase()=="true"){ //034461
                    var objRD    = dupemxUICore.selectSingleNode(checkedRow, "c["+objColumnRD.index+"]");
                    RD  = dupemxUICore.getText(objRD);
				//} //034461

                var objColumnNM  = dupcolMap.getColumnByName("Name");
                var objNM    = dupemxUICore.selectSingleNode(checkedRow, "c["+objColumnNM.index+"]");
                var NM  = dupemxUICore.getText(objNM);


                var xPath = "/mxRoot/rows//r[@level = '" + iLevel + "'";
               // xPath += " and (node() = 'Substitute'";
                ////xPath += " or node() = 'Alternate'";
                //xPath += " or node() = 'Split Quantity')";
                ///xPath += " and node() = '"+ trim(NM) +"'";
                xPath += "]";

                var existintRows = dupemxUICore.selectNodes(mxRoot, xPath);
                var relType = checkedRow.getAttribute("rel");
                //Added for IR-044888V6R2011
                var childRowId = checkedRow.getAttribute("id");

				//034461 start
				var fnSuborAlt = "";
				//034461 end
				//XSSOK
         	if(relType == "<%=DomainConstants.RELATIONSHIP_EBOM%>" ){
                for(var povoy=0; povoy<existintRows.length;povoy++){
                    var subORalt = existintRows[povoy];

                    var objsaFN    = dupemxUICore.selectSingleNode(subORalt, "c["+objColumnFN.index+"]");
                     // 034461 start
                    // var fnSuborAlt = dupemxUICore.getText(objsaFN);

                       var rowId  = subORalt.getAttribute("id");
		       var columnName = objColumnFN.name;
			   if (subORalt.getAttribute("status") != 'add')
				fnSuborAlt = contentFrame.parent.emxEditableTable.getCellValueByRowId(rowId,columnName);
		       // 034461 end
                    var objsaRD    = dupemxUICore.selectSingleNode(subORalt, "c["+objColumnRD.index+"]");
                    var rdSuborAlt = dupemxUICore.getText(objsaRD);

                    /*
					if((fnSuborAlt != FN && fnUniqueness.toLowerCase()=="true") ||
                       (rdSuborAlt != RD && rdUniqueness.toLowerCase()=="true")){
                        continue;
                    }
					*/
					if(fnSuborAlt.value.current.actual != FN) {
                        continue;
                    }

                    var oxmlstatus = subORalt.getAttribute("status");
                    var objId  = subORalt.getAttribute("o");
                    // 034461
                    //var rowId  = subORalt.getAttribute("id");
                    var relId  = subORalt.getAttribute("r");
                    var prnId  = subORalt.parentNode.getAttribute("o");
                    var pRwId  = subORalt.parentNode.getAttribute("id");

                    if(oxmlstatus == "add"){
                        subORalt.parentNode.removeChild(subORalt);
                        var xPath = "/mxRoot//object[@objectId = '" + objId + "' and @rowId = '" + rowId + "' and @markup = 'add']";
                        var postDataRow = dupemxUICore.selectSingleNode(duppostDataXML, xPath);
                        if(postDataRow){
                            var parentEle = postDataRow.parentNode;
                            postDataRow.parentNode.removeChild(postDataRow);
                            if(parentEle.childNodes.length == 0){
                                parentEle.parentNode.removeChild(parentEle);
                            }
                        }
                        returnFlag = true;
                    }
                    else if(oxmlstatus == null || oxmlstatus == "changed"){
                        var found = true;
                        var xPath  = "/mxRoot/object[@objectId = '" + objId + "' and @rowId = '" + rowId + "']";
                        var changedObject =  dupemxUICore.selectSingleNode(duppostDataXML, xPath);

                        if(changedObject != null && (typeof changedObject != 'undefined')){
                            changedObject.parentNode.changedObject(changedObject);
                        }

                        xPath  = "/mxRoot/object[@objectId = '" + prnId + "' and @rowid = '" + pRwId + "']";
                        var topObject =  dupemxUICore.selectSingleNode(postXML.documentElement, xPath);

                        if(topObject == null || (typeof topObject == 'undefined')){
                            topObject = postXML.createElement("object");
                            topObject.setAttribute("objectId", prnId);
                            topObject.setAttribute("rowid", pRwId);
                            found = false;
								}

                        var newNodeMarked = postXML.createElement("object");
                        newNodeMarked.setAttribute("objectId", objId);
                        newNodeMarked.setAttribute("relId", relId);
                        newNodeMarked.setAttribute("relType", sym_EBOM);
                        newNodeMarked.setAttribute("markup", "cut");
                        //Start : IR-044888V6R2011
                        newNodeMarked.setAttribute("rowId",childRowId);
                        topObject.appendChild(newNodeMarked);

                        if(!found){
                            theRoot.appendChild(topObject);
                        }
                    }
						}
					}
					}
            catch(e){
                throw e;
            }
            return returnFlag;
				}




        /**************************************************************************/
        /* function doInitialProcess() - This function to remove all              */
        /* selected parts.                                                        */
        /* Added for V6R2009.HF0.2                                                */
        /**************************************************************************/
        function doInitialProcess(){
            try{
                //var bomFilterValue = window.parent.document.getElementById('ENCBOMRevisionCustomFilter').value;
                var bomFilter = window.parent.getTopWindow().document.getElementById('ENCBOMRevisionCustomFilter');
                var bomFilterValue = "As Stored";
                if(bomFilter){
                    bomFilterValue = bomFilter.value;
                }
                // Initialise postXML and theRoot objects.
                if(postXML == null){
                postXML           = dupemxUICore.createXMLDOM();
                postXML.loadXML("<mxRoot/>");
                theRoot            = postXML.documentElement;
            }

                // get all selected rows
                var isFROMRMB = "<%=XSSUtil.encodeForJavaScript(context, isFromRMB)%>";
                var rmbRowId  = "<%=selPartRowId%>";
               // var xCheckedPath  = "/mxRoot/rows//r[@checked='checked']";
                var xCheckedPath  = isFROMRMB == "true" ?  "/mxRoot/rows//r[@id='"+rmbRowId+"']" : "/mxRoot/rows//r[@checked='checked']"; 
                var checkedRows    = dupemxUICore.selectNodes(mxRoot, xCheckedPath);
                var countW = 0;
                var countE = 0;

				//IR-034461 - Starts
				var objColumnFN  = dupcolMap.getColumnByName("Find Number");
				//IR-034461 - Ends

                //Iterate all the selected parts
                for(var raa=0; raa<checkedRows.length;raa++){
                    var found = true;
                    var Eflag = false;
                    var Wflag = false;
                    var total = "";
                    var checkedRow = checkedRows[raa];

                    // if root node is selected
                    var id         = checkedRow.getAttribute("id");
                    if(id == "0"){
                        removeMsg = removeError;
                        break;
                    }

                    // If parent and child is selected
                    var parentRowChecked = checkedRow.parentNode.getAttribute("checked");
                    if(parentRowChecked == "checked"){
                        continue;
                    }

                    var childRowid = checkedRow.getAttribute("id");
                    var oid              = checkedRow.getAttribute("o");
                    var relid            = checkedRow.getAttribute("r");
                    var rel               = checkedRow.getAttribute("rel");
                    var oxmlstatus         = checkedRow.getAttribute("status");
                    //ADDED FOR IR-036975V6R2011
                    var childRowId  = checkedRow.getAttribute("id");
                    var poid            = checkedRow.parentNode.getAttribute("o");
                    var rowid          = checkedRow.parentNode.getAttribute("id");

                    //Added R208.HF1 - Starts
                    if (oid == "" && removeMsg == "") {
                    	//XSSOK
                        removeMsg = "<%=inlineErrorMessage%>";
                        break;
                    }
                    //Added R208.HF1 - Ends
                    if(relid == null || (typeof relid == 'undefined')){
                        relid = "";
                    }

                    //get the state
                    var ST  = "";
                    var objColumnST  = dupcolMap.getColumnByName("State");
                    if(objColumnST){
                        var objST    = dupemxUICore.selectSingleNode(checkedRow.parentNode, "c["+objColumnST.index+"]");
                        ST  = dupemxUICore.getText(objST);
                    }

                    // if the state of the seleted part doesnt matches with one of the state in States object
                    //XSSOK
                    if(states.indexOf(ST) != -1 && rel == "<%=DomainConstants.RELATIONSHIP_EBOM%>"){
                        Eflag = true;
                    }
                    // if the part is newly added or already removed
                    else if(oxmlstatus == 'add' || oxmlstatus == 'cut'){
                        Wflag = true;
                    }

                    // Contruct the error message
                    if(Eflag || Wflag){
                        var objColumnTP  = dupcolMap.getColumnByName("Type");
                        var objTP    = dupemxUICore.selectSingleNode(checkedRow, "c["+objColumnTP.index+"]");
                        var TP  = dupemxUICore.getText(objTP);

                        var objColumnNM  = dupcolMap.getColumnByName("Name");
                        var objNM    = dupemxUICore.selectSingleNode(checkedRow, "c["+objColumnNM.index+"]");
                        var NM  = dupemxUICore.getText(objNM);


                        var objColumnRN  = dupcolMap.getColumnByName("Revision");
                        var objRN    = dupemxUICore.selectSingleNode(checkedRow, "c["+objColumnRN.index+"]");
                        var RN  = dupemxUICore.getText(objRN);

                        total = "'"+ TP + "' '" + NM + "' '" + RN + "'";
                    }

                    if(Eflag){
                        if(errorDontAllow != ""){
                            errorDontAllow += ", ";
                            if(countE%5 == 0){
                                errorDontAllow += "\n";
                            }
                        }
                        errorDontAllow += total;
                        countE++;
                        continue;
                    }
                    else if(Wflag){
                        if(warnDelNames != ""){
                            warnDelNames += ", ";
                            if(countW%5 == 0){
                                warnDelNames += "\n";
                            }
                        }
                        warnDelNames += total;
                        countW++;
                        continue;
                    }
                    //Commented for IR-034461 - Starts
                    /*
					var isMBOMInstalled = "<%=isMBOMInstalled%>";
					if(isMBOMInstalled == "true"){
                    // if it is common view, check for the newly added Substitues/Alternates/Split Quantities
                    var objColumnMPU  = dupcolMap.getColumnByName("Manufacturing Part Usage");
                    if(objColumnMPU){
            
                        var objMPU    = dupemxUICore.selectSingleNode(checkedRow, "c["+objColumnMPU.index+"]");
                        var MPU  = dupemxUICore.getText(objMPU);
						var relType = checkedRow.getAttribute("rel");
						//if(MPU == 'Primary'){
                        if(relType != null && (relType == "<%=DomainConstants.RELATIONSHIP_EBOM%>")){
                            var rebuild = true; //checkForNewlyAddedSubstitutesAndAlternates(checkedRow);
                            if(rebuild == true){
                                refresh = rebuild;
         						}
         					}
						}
					}
	            */
	            //IR-034461 - Ends
                    // get the markup xml from postXML.
                    var xPath  = "/mxRoot/object[@objectId = '" + poid + "' and @rowid = '" + rowid + "']";
                    var topObject =  dupemxUICore.selectSingleNode(postXML.documentElement, xPath);

                    // if it is not found, create the parent element
                    if(topObject == null || (typeof topObject == 'undefined')){
                        topObject = postXML.createElement("object");
                        topObject.setAttribute("objectId", poid);
                        topObject.setAttribute("rowid", rowid);
                        found = false;
                    }

                    // Create child element for parent element
                    var newNodeMarked = postXML.createElement("object");
                    newNodeMarked.setAttribute("objectId", oid);
                    newNodeMarked.setAttribute("relId", relid);
                    newNodeMarked.setAttribute("parentId", poid);
                    newNodeMarked.setAttribute("relType", sym_EBOM);
                    newNodeMarked.setAttribute("markup", "cut");
                    //Added for IR-036975V6R2011
                    newNodeMarked.setAttribute("rowId",childRowId);
                    topObject.appendChild(newNodeMarked);
                    if(!found){
                        theRoot.appendChild(topObject);
                    }
                }

                // if Revision filter value is as stored
                var loadXML = true;
                if(bomFilterValue != "As Stored"){
                	//XSSOK
                    loadXML = confirm("<%=sConformAsStored%>");
                }

                // load the postXML if there is no problem
                if(loadXML){
                    var msg = "";
                    if(removeMsg != ""){
                        msg += removeMsg+"\n";
                    }
                    if(errorDontAllow != ""){
                        msg += errordontMsg+"["+errorDontAllow+"]\n";
                    }
                    if(warnDelNames != ""){
                        msg += warnDelMsg+"["+warnDelNames+"]\n";
                    }
                    if(msg != ""){
                        alert(msg);
                    }
                    else{
                        if(refresh){
                            contentFrame.parent.rebuildView();
                        }
                        if(theRoot.childNodes.length > 0){
                            var callback = eval(contentFrame.parent.emxEditableTable.prototype.loadMarkUpXML);
                            var oxmlstatus = callback(theRoot.xml, "true");
                        }
                    }
                }
                removeMask();
            }
            catch(e){
                throw e;
            }
            
        }
        </script>
        <script language="JavaScript">
        
        var tablemode = "edit";
        var displayView = contentFrame.parent.displayView
   		if(contentFrame.parent.editableTable && contentFrame.parent.editableTable != null && contentFrame.parent.editableTable != undefined){
   				tablemode = contentFrame.parent.editableTable.mode; 
   		}
   		
		var selectedRow = "<%=selectedRows%>";
 		var request;  
 		if(tablemode != "edit") {
 			var formatedSelectedRow = "";
 			var vSelectedObjectArray =  selectedRow.split("~");
 			var i;
 			for (i = 0; i < vSelectedObjectArray.length; i++) {
 			    var selectedObjArray = vSelectedObjectArray[i].split("|");
 			    if(selectedObjArray.length >3){
 			    	var selectedRowId = selectedObjArray[3];
 			    	var parentId = selectedObjArray[2];
 			    	var childId = selectedObjArray[1];
 			    	var relId = selectedObjArray[0];
 			    	var xSelectedPath1  = "/mxRoot/rows//r[@rowid = '" + selectedRowId + "']";
 			    	var selectedNode = dupemxUICore.selectNodes(mxRoot, xSelectedPath1);
 			    	if(selectedRowId != 0){
	 			    	if(relId == ""){
	 			    		relId            = checkedRow.getAttribute("r");
	 			    	}
	 			    	if(relId == ""){
	 			    		parentId            = checkedRow.getAttribute("p");
	 			    	}
 			    }
 			    	else {
 			    		relId = "rootNode";
 			    	}
 			    	if(formatedSelectedRow == ""){
 			    		formatedSelectedRow = relId+"|"+childId+"|"+parentId+"|"+selectedRowId
 			    	}
 			    	else {
 			    		formatedSelectedRow = formatedSelectedRow + "~"+relId+"|"+childId+"|"+parentId+"|"+selectedRowId
 			    	}
 			    }
 			}

 			var url="../engineeringcentral/enoDisconnectPart.jsp?";  
  		  	var strData = "selectedRow="+formatedSelectedRow+"&displayView="+displayView;
 			var responseTxt = emxUICore.getDataPost(url, strData);
 			responseTxt = responseTxt.trim();
 			if(responseTxt == ""){
				if(contentFrame.parent.displayView && contentFrame.parent.displayView != null && contentFrame.parent.displayView != undefined){
						var rowsSelected = "<%=XSSUtil.encodeForJavaScript(context, ComponentsUIUtil.arrayToString(sCheckBoxArray, "~"))%>";
						parent.emxEditableTable.removeRowsSelected(rowsSelected.split("~")); 
				}
			}
			else {
				if(responseTxt == "Trigger Blocked"){
					window.location.href=window.parent.location.href;
				}
				else
					alert(responseTxt);	
			}
 		}
 		else {
			
			var isRemoveForSynchro = '<%=sRemoveForSynchro%>';
						
			if (isRemoveForSynchro == "true") {
			
				if(confirm("<%=strWarningCFReplaceByNewPartMsg%>")){
					try{
						addMask();
						setTimeout(function(){
							try{
								doInitialProcess();
							}
							catch(e){
								//XSSOK
								alert("<%=strErrorMessage%>"+e.message);
								removeMask();
							}
						},10);
					} catch(e){
						removeMask();
					}
					
					document.location.href = "../engineeringcentral/AT_emxpartDisconnectAndSynchronize.jsp?selectedRows=<%=selectedRows%>&expandLevel=<%=sExpandLevel%>";
				}
			}else if (isRemoveForSynchro == "false") {
				try{
					addMask();
					setTimeout(function(){
						try{
							doInitialProcess();
						}
						catch(e){
							//XSSOK
							alert("<%=strErrorMessage%>"+e.message);
							removeMask();
						}
					},10);
				} catch(e){
					removeMask();
				}
			} else{
				alert("Design, COS and Standard part have to be removed separately");
			}
 		}
        </script>

    <%
    }
    else if("AVLReport".equalsIgnoreCase(uiType)){
        if(sCheckBoxArray != null){
            for(int i=0; i < sCheckBoxArray.length; i++){
                //boolean allowDelete1 = true;
                StringTokenizer st1 = new StringTokenizer(sCheckBoxArray[i], "|");
                String sRelId1 = st1.nextToken();
                String sObjId1 = st1.nextToken();

                ContextUtil.pushContext(context);
                DomainRelationship.disconnect(context, sRelId1);
                ContextUtil.popContext(context);
            }
        }
        %>
        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="javascript">
            var contentFrame = findFrame(getTopWindow(),"listDisplay");
            contentFrame.parent.document.location.href=contentFrame.parent.document.location.href;
        </script>
        <%
    }
    else{
        %>
        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="javascript">
            var contentFrame = findFrame(getTopWindow(),"listDisplay");
            contentFrame.parent.document.location.href=contentFrame.parent.document.location.href;
        </script>
        <%
    }
 }        
%>
