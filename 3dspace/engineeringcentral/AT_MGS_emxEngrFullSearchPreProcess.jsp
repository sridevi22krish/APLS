 <%--  emxEngrFullSearchPreProcess.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
   Suresh S; 02-Nov-2017;Modified for QC 5209.
--%>
<%@ page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@ page import="matrix.db.BusinessObject"%>
<%@ page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<%

    // Variable Declarations
  	String selPartRelId = "";
  	String selPartObjectId = "";
  	String selPartParentOId = "";
    String selPartRowId     = "";
    String strRelEbomIds    = "";
    String relType = emxGetParameter(request,"relType");
    long timeinMilli = System.currentTimeMillis();
    // get the parameters from the request object
    String calledMethod      = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"calledMethod"));
    String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
    String objectId              = emxGetParameter(request,"objectId");
    String prevmode          = emxGetParameter(request, "prevmode");
    String language         = request.getHeader("Accept-Language");
    String suiteKey         = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"suiteKey"));
    String sCustomFilter  =  emxGetParameter(request,"ENCBillOfMaterialsViewCustomFilter");
    
    boolean isMBOMInstalled = EngineeringUtil.isMBOMInstalled(context);
    int nosRowsselected = 0;
    if(tableRowIdList == null){
    	nosRowsselected = 0;
    }
    else{
    	nosRowsselected = tableRowIdList.length;
    }
    
   // boolean isENGSMBInstalled = EngineeringUtil.isENGSMBInstalled(context); //Commented for IR-213006
  //Multitenant
    /* String strInvalidSelectionMsg = i18nNow.getI18nString("emxEngineeringCentral.CommonView.Alert.Invalidselection",
            "emxEngineeringCentralStringResource", 
            language); */
    String strInvalidSelectionMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
    		context.getLocale(),"emxEngineeringCentral.CommonView.Alert.Invalidselection");          
 	//Multitenant
	/* String strAddDeleteErrorMsg   = i18nNow.getI18nString("emxEngineeringCentral.BOM.ChangePositionOnAddDelete",
            "emxEngineeringCentralStringResource",
            language); */
    String strAddDeleteErrorMsg   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
    		context.getLocale(),"emxEngineeringCentral.BOM.ChangePositionOnAddDelete");
	//Multitenant
	/* String ChangePositionErrorMessage        = i18nNow.getI18nString("emxEngineeringCentral.BOM.ChangePositionFail",
            "emxEngineeringCentralStringResource",
            language); */
	String ChangePositionErrorMessage        = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
			context.getLocale(),"emxEngineeringCentral.BOM.ChangePositionFail");
            String strMultipleSelection        = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", 
        			context.getLocale(),"emxFramework.Common.PleaseSelectOneItemOnly");
            
    String editInViewMode        = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
			context.getLocale(),"emxEngineeringCentral.Command.EditingPartsInViewMode");
    String noModifyAccess        = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
			context.getLocale(),"emxEngineeringCentral.DragDrop.Message.NoModifyAccess");
            
String sSymbolicRelEBOMName   = FrameworkUtil.getAliasForAdmin(context,
        "relationship", 
        DomainConstants.RELATIONSHIP_EBOM, 
        true);

    // JavaScript Exception message
    //Multitenant
    /* String strErrorMessage                          = i18nNow.getI18nString("emxEngineeringCentral.BOM.AddExistingFail",
                                                                      "emxEngineeringCentralStringResource",
                                                                       language); */
	String strErrorMessage                          = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
			context.getLocale(),"emxEngineeringCentral.BOM.AddExistingFail");

    //Added R208.HF1 - Starts
    //Multitenant
    /* String inlinErrorMessage                        = i18nNow.getI18nString("emxFramework.FreezePane.SBEditActions.RowSelectError",
                                                                      "emxFrameworkStringResource",
                                                                       language); */
	String inlinErrorMessage                        = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", 
			context.getLocale(),"emxFramework.FreezePane.SBEditActions.RowSelectError");
    
	//Multitenant
    /* String changePositionRootNodeSelectionMess      = i18nNow.getI18nString("emxEngineeringCentral.BOM.ChangePositionRootNodeError",
            "emxEngineeringCentralStringResource",
             language); */
	String changePositionRootNodeSelectionMess      = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
			context.getLocale(),"emxEngineeringCentral.BOM.ChangePositionRootNodeError");
    
    //Added R208.HF1 - Ends
    
    //IR-044514	
     //Multitenant
     /* String strDone = i18nNow.getI18nString("emxFramework.Command.Done", "emxEngineeringCentralStringResource",language); */
     String strDone = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxFramework.Command.Done");
   //Multitenant
   /* String strCancel = i18nNow.getI18nString("emxFramework.Command.Cancel", "emxEngineeringCentralStringResource",language); */
     String strCancel = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxFramework.Command.Cancel");
     String isFromRMB    		= emxGetParameter(request, "isFromRMB");
     
     if("true".equalsIgnoreCase(isFromRMB)) {
         StringList tempList = FrameworkUtil.split(" "+tableRowIdList[0], "|");
         selPartRowId     = ((String)tempList.get(3)).trim(); 
     }
     
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript">
    // Added for V6R2009.HF0.2 - Starts
    var warningMessage = "";
    var warningMessageinViewMode = "";
    //XSSOK
    var varIsMbomInstalled = "<%=isMBOMInstalled%>";
    var dupemxUICore = undefined;
    var mxRoot = undefined;
    // IR-027941V6R2011 Changed from top to parent.
    var contentFrame   = findFrame(parent,"listHidden");
    if (contentFrame != null && contentFrame != "undefined") {
        var xmlRef = contentFrame.parent.oXML;
    }    
    //Added for the bug 376740
    var excludeID="";
    var rowId ="";
    var checkedRow ="";
    //376740 ends
    if(xmlRef!=undefined)
    {
    	dupemxUICore   = contentFrame.parent.emxUICore;
    	mxRoot         = contentFrame.parent.oXML.documentElement;
    }
    var highest = 0;
    var isFROMRMB = "<%=XSSUtil.encodeForJavaScript(context, isFromRMB)%>";
	var rmbRowId  = "<%=selPartRowId%>";
	var xPath     =  isFROMRMB == "true" ?  "/mxRoot/rows//r[@id='"+rmbRowId+"']" : "/mxRoot/rows//r[@checked='checked']";	
  if("addExisting" == "<%=calledMethod%>"){
   var findNumberIndex = contentFrame.parent.colMap.getColumnByName("Find Number").index; 
   var checkedRows = emxUICore.selectNodes(contentFrame.parent.oXML, xPath); 
    var findNumberList = emxUICore.selectNodes(contentFrame.parent.oXML, xPath +"/r/c["+findNumberIndex+"]/text()");
    //Start ----- For DragNDrop
    if(checkedRows.length == 0 || rmbRowId == "0"){
    	xPath = "/mxRoot/rows//r[@id='0']";
    	checkedRows = emxUICore.selectNodes(contentFrame.parent.oXML, "/mxRoot/rows//r['0']");
    	findNumberList = emxUICore.selectNodes(contentFrame.parent.oXML, xPath+"/r/c["+findNumberIndex+"]/text()");
    }
  //END ----- For DragNDrop
    for(j=0;j<findNumberList.length;j++){
    	if (findNumberList[j].nodeValue != "") {
    	var intNodeValue = parseInt(findNumberList[j].nodeValue);
    	if(j==0)
    		highest = intNodeValue;
    	else if (highest<intNodeValue)
    		highest = intNodeValue;    	
    	}
    }
  }
    var status         =  null;
    var rel            = null;
    
	var isFROMRMB = "<%=XSSUtil.encodeForJavaScript(context, isFromRMB)%>";
	var rmbRowId  = "<%=selPartRowId%>";
	var xPath     =  isFROMRMB == "true" ?  "/mxRoot/rows//r[@id='"+rmbRowId+"']" : "/mxRoot/rows//r[@checked='checked']";	            	
	
	var calledMethod = "<%=XSSUtil.encodeForJavaScript(context, calledMethod)%>";
	var sCustomFilter = "<%=XSSUtil.encodeForJavaScript(context, sCustomFilter)%>";
    
    try{
    	if(calledMethod!= "addExisting" && ((sCustomFilter != "engineering") || (sCustomFilter != "Engineering"))){
	    	if(dupemxUICore!=undefined)
	    	{
	            //checkedRow     = dupemxUICore.selectSingleNode(mxRoot, "/mxRoot/rows//r[@checked='checked']");
	            checkedRow     = dupemxUICore.selectSingleNode(mxRoot, xPath);
	        	status         = checkedRow.getAttribute("status");
	        	rel            = checkedRow.getAttribute("rel");
	        	if(rel == null){
	            	rel = checkedRow.getAttribute("relType");
	            	if(rel != null){
	            		var arrRel = rel.split("|");
	            		rel = arrRel[0];
	        		}
	        	}
	       	}
    	}
    }
    catch(e){
    	//XSSOK
        warningMessage = "<%=strErrorMessage%>" + e.message;
   		}
    // Added for V6R2009.HF0.2 - Ends
</script>
<%
    //In case of "Add Existing" and "Add New" commands
    //constructs the table Row Id for context part
    if(tableRowIdList == null){
        tableRowIdList = new String[1];
        tableRowIdList[0] = "|"+objectId+"||0";
    }

  if (tableRowIdList!= null) {
    for (int i=0; i< tableRowIdList.length; i++) {
            // Modfied for V6R2009.HF0.2 - Starts
            selPartRelId = selPartObjectId = selPartParentOId = selPartRowId = "";
       //process - relId|objectId|parentId - using the tableRowId
       		String tableRowId = XSSUtil.encodeForJavaScript(context,tableRowIdList[i]);
            StringList slList = FrameworkUtil.split(" "+tableRowIdList[i], "|");
            try
            {
	            selPartRelId     = ((String)slList.get(0)).trim();
	            selPartRelId = XSSUtil.encodeForJavaScript(context,selPartRelId); 
	            selPartObjectId  = ((String)slList.get(1)).trim();
	            selPartObjectId = XSSUtil.encodeForJavaScript(context,selPartObjectId); 
	            selPartParentOId = ((String)slList.get(2)).trim();
	            selPartParentOId = XSSUtil.encodeForJavaScript(context,selPartParentOId); 
	            selPartRowId     = ((String)slList.get(3)).trim();
	            selPartRowId = XSSUtil.encodeForJavaScript(context,selPartRowId); 
            }
            catch(Exception e)
            {
                selPartParentOId="";
            }
            //Added R208.HF1 - Starts
            %>
                <script language="javascript">
                if ("<%=selPartObjectId%>" == "" || "<%=selPartObjectId%>" == null) {
                	//XSSOK
                    warningMessage = "<%=inlinErrorMessage%>";
                }
                </script>
            <%
            //Added R208.HF1 - Ends
            //if the selected part is parent part
            if("0".equals(selPartRowId)){
                selPartParentOId = selPartObjectId;
       }

            // Add Existing
            if(calledMethod.equals("addExisting")){
            	//Multitenant
            	/* String strWarningAEDeleteMsg = i18nNow.getI18nString("emxEngineeringCentral.BOM.AddExistingOnDeleted",
                                                                 "emxEngineeringCentralStringResource",
                                                                 language); */
				String strWarningAEDeleteMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.AddExistingOnDeleted");
                String strWarningAEEBOMSQMsg = "";
                String sSymbolicRelESQName   = "";
                if(isMBOMInstalled) {
                	//Multitenant
                	/* strWarningAEEBOMSQMsg = i18nNow.getI18nString("emxMBOM.BOM.AddExistingOnSplitQuantity",
	                        "emxMBOMStringResource",
	                        language); */
	                        strWarningAEEBOMSQMsg = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", 
	                        		context.getLocale(),"emxMBOM.BOM.AddExistingOnSplitQuantity");
					sSymbolicRelESQName   = FrameworkUtil.getAliasForAdmin(context,
	                                    "relationship",
	                                    EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY,
	                                    true);
                }

        %>
            <script language="Javascript">
                    //Added for the bug 376740
                  if(calledMethod!= "addExisting" && ((sCustomFilter != "engineering") || (sCustomFilter != "Engineering"))){
                   rowId = checkedRow.getAttribute("id");
                   var Rows = dupemxUICore.selectNodes(mxRoot, "/mxRoot/rows//r[@id='" + rowId + "']/ancestor::r");
               	   var j = Rows.length;
               	   for(var i=0;i<j;i++) {
      	   		   var objid = Rows[i].getAttribute('o');
      	   		   excludeID = objid+","+excludeID;
        		}
            }
    	          // 376740 ends
    	          //XSSOK 
					if(varIsMbomInstalled == "true" && (rel != null && (rel == "<%=EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY%>" || rel == "<%=sSymbolicRelESQName%>"))){
						//XSSOK
						warningMessage = "<%=strWarningAEEBOMSQMsg%>";
					} else if(status == 'cut'){
						//XSSOK
                        warningMessage = "<%=strWarningAEDeleteMsg%>";
                    }
            </script>
        <%
            }//end of addExisting

            // Copy From
            else if(calledMethod.equals("copyFrom")){
            	//Multitenant
            	/* String strWarningCFDeleteMsg =  i18nNow.getI18nString("emxEngineeringCentral.BOM.CopyFromOnDeleted",
                                                                  "emxEngineeringCentralStringResource",
                                                                  language); */
				String strWarningCFDeleteMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.CopyFromOnDeleted");  
                
                //Multitenant
				/* String strWarningCFRootNode  = i18nNow.getI18nString("emxEngineeringCentral.BOM.CopyFromRootNodeError",
                                                                 "emxEngineeringCentralStringResource",
                                                                 language); */
				String strWarningCFRootNode  = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.CopyFromRootNodeError");
                String strWarningCFEBOMSQMsg = "";
                String sSymbolicRelESQName  = "";
                if(isMBOMInstalled) {
                	//Multitenant
                	/* strWarningCFEBOMSQMsg = i18nNow.getI18nString("emxMBOM.BOM.CopyFromOnSplitQuantity",
	                        "emxMBOMStringResource",
	                        language); */
	                        strWarningCFEBOMSQMsg = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", 
	                        		context.getLocale(),"emxMBOM.BOM.CopyFromOnSplitQuantity");
					sSymbolicRelESQName   = FrameworkUtil.getAliasForAdmin(context,
	                                     "relationship",
	                                      EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY,
	                                     true);
                }
             
                %>
                <script language="Javascript">
                //XSSOK
					if(varIsMbomInstalled == "true" && (rel != null && (rel == "<%=EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY%>" || rel == "<%=sSymbolicRelESQName%>"))){
                        //XSSOK
                        warningMessage = "<%=strWarningCFEBOMSQMsg%>";
                    }else if(status == 'cut' && warningMessage == "") {
                        //XSSOK
                        warningMessage = "<%=strWarningCFDeleteMsg%>";
                	}
                </script>
                <%
            }//end of copyFrom

            // Copy To
            else if(calledMethod.equals("copyTo")){
            	//Multitenant
            	/* String strWarningCopyToMsg           = i18nNow.getI18nString("emxEngineeringCentral.BOM.CopyToOnAdded",
                                                                         "emxEngineeringCentralStringResource",
                                                                         language); */
				String strWarningCopyToMsg           = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.CopyToOnAdded");
                //Multitenant
				/* String strRootNodeErrorMsgForCopyTo  = i18nNow.getI18nString("emxEngineeringCentral.BOM.CopyToRootNodeError",
                                                                          "emxEngineeringCentralStringResource",
                                                                         language); */
				String strRootNodeErrorMsgForCopyTo  = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.CopyToRootNodeError");

                String strWarningCTEBOMSQMsg = "";
                String sSymbolicRelESQName  = "";
                if(isMBOMInstalled) {
                	//Multitenant
                	/* strWarningCTEBOMSQMsg  = i18nNow.getI18nString("emxMBOM.BOM.CopyToOnSplitQuantity",
                        "emxMBOMStringResource",
                        language); */
                strWarningCTEBOMSQMsg  = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", 
                		context.getLocale(),"emxMBOM.BOM.CopyToOnSplitQuantity");
                sSymbolicRelESQName   = FrameworkUtil.getAliasForAdmin(context,
                        "relationship",
                        EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY,
                        true);
                }
                %>
                <script language="Javascript">
                    if(warningMessage == "" && dupemxUICore!=undefined){
                        try{
                        	//XSSOK
                           if(varIsMbomInstalled == "true" && (rel != null && (rel == "<%=EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY%>" || rel == "<%=sSymbolicRelESQName%>"))){
                               //XSSOK 
                                warningMessage = "<%=strWarningCTEBOMSQMsg%>";
                            } else {
                            	var checkedRows     = dupemxUICore.selectNodes(mxRoot, "/mxRoot/rows//r[@checked='checked' and @status='add']");
                                if(checkedRows.length > 0){
                                	//XSSOK
                                warningMessage = "<%=strWarningCopyToMsg%>";
                            	}
                            }
                        }
                        catch(e){
                        	//XSSOK
                            warningMessage = "<%=strErrorMessage%>" + e.message;
                        }
       }
       			//XSSOK
              if(varIsMbomInstalled == "true" && (rel != null && rel != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && rel != "<%=sSymbolicRelEBOMName%>"))
              {
            	  //XSSOK
                 warningMessage = "<%=strInvalidSelectionMsg%>";
              }
       
                </script>
                <%
                if("0".equals(selPartRowId)){
				%>
              <script language="Javascript">
                        if(warningMessage == "" && dupemxUICore!=undefined){
                        	//XSSOK
                            warningMessage = "<%=strRootNodeErrorMsgForCopyTo%>";
                        }
              </script>
              <%
              break;
            }
                else if(selPartRelId != null && !"null".equals(selPartRelId) && !"".equals(selPartRelId)){
                    if(!"".equals(strRelEbomIds)){
                        strRelEbomIds += ",";
                    }
                    strRelEbomIds += selPartRelId;
       }
            }//end of copyTo

            //    Replace with Existing
            else if(calledMethod.equals("replaceExisting")){
            	//Multitenant
            	/* String strWarningReplaceExistingMsg  = i18nNow.getI18nString("emxEngineeringCentral.BOM.ReplacewithExistingOnAddedDeleted",
                                                                                 "emxEngineeringCentralStringResource",
                                                                                 language); */
				String strWarningReplaceExistingMsg  = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.ReplacewithExistingOnAddedDeleted");
                //Multitenant
				/* String strRootNodeErrorMsgForReplaceExisting = i18nNow.getI18nString("emxEngineeringCentral.BOM.ReplaceExistingRootNodeError",
                                                                                 "emxEngineeringCentralStringResource",
                                                                                 language); */
				String strRootNodeErrorMsgForReplaceExisting = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.ReplaceExistingRootNodeError");
               
               
                if(isMBOMInstalled) {
                	//Multitenant
                	/* strInvalidSelectionMsg = i18nNow.getI18nString("emxEngineeringCentral.CommonView.Alert.Invalidselection",
	                        "emxEngineeringCentralStringResource",
	                        language); */
					strInvalidSelectionMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
							context.getLocale(),"emxEngineeringCentral.CommonView.Alert.Invalidselection");
	                sSymbolicRelEBOMName = FrameworkUtil.getAliasForAdmin(context,
	                        "relationship",
	                        DomainConstants.RELATIONSHIP_EBOM,
	                        true);
                }



                %>
                <script language="Javascript">
                //XSSOK
  		           if(varIsMbomInstalled == "true" && (rel != null && rel != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && rel != "<%=sSymbolicRelEBOMName%>")){
  		        	//XSSOK
                        warningMessage = "<%=strInvalidSelectionMsg%>";
                    }
                    else if((status == 'add' || status == 'cut') && warningMessage == ""){
                    	//XSSOK
                        warningMessage = "<%=strWarningReplaceExistingMsg%>";
                    }
                </script>
                <%
                if("0".equals(selPartRowId)){
                    %>
                    <script language="Javascript">
                        if(warningMessage == ""){
                        	//XSSOK
                            warningMessage = "<%=strRootNodeErrorMsgForReplaceExisting%>";
    }
                    </script>
                    <%
                    break;
  }
            }//end of replaceExisting
        }//end of for (int i=0; i< ...
    }// end of if (tableRowIdList!= null)
    // Modfied for V6R2009.HF0.2 - Ends
    
    //Start - Added for IR-044888V6R2011
     session.setAttribute("selPartRowId",selPartRowId);
    //End - IR-044888V6R2011

  if(prevmode == null || "null".equals(prevmode)){
    prevmode ="";
  }

  // Put EBOM's RelIds in Session
  if(!prevmode.equals("true")){
    session.setAttribute("strRelEbomIds",strRelEbomIds);
    session.removeAttribute("searchPARTprop_KEY");
  }
  
    String stateNames = EngineeringUtil.getProductAndDevelopmentPolicyList(context); 

	String contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_Part:" + stateNames + "&table=ENCAffectedItemSearchResult&HelpMarker=emxhelpfullsearch&hideHeader=true&objectId="+objectId;
	StringBuffer sBuff = new StringBuffer();
	// Input for Alstom
	String sTypeObject = "";
	String strPolicyClassification =  "";
	boolean bAlertAddExistingPart = false;
	boolean bAlertReplaceExistingPart = false;
	 if(selPartObjectId!=null && !"".equals(selPartObjectId)) {
		  com.matrixone.apps.domain.DomainObject domPart = new com.matrixone.apps.domain.DomainObject(selPartObjectId);
		  sTypeObject = (String)domPart.getInfo(context, DomainObject.SELECT_TYPE);
		  strPolicyClassification = (String)domPart.getInfo(context,"policy.property[PolicyClassification].value");
	    }
	// ALstom	  
	String sTypeFilterSearch ="";
	//String sTypeObject = (String)domPart.getInfo(context, DomainObject.SELECT_TYPE);
		  // ALstom
		  if ("AT_C_LOGICAL_NODE".equals(sTypeObject)) {
        	  sTypeFilterSearch ="type_AT_C_CONFIGURATION_ITEM,type_AT_C_LOGICAL_NODE";
          } else if ("AT_C_CONFIGURATION_ITEM".equals(sTypeObject)) {
        	  sTypeFilterSearch ="type_AT_C_EXPECTED_PRODUCT";
          } else if ("AT_C_EXPECTED_PRODUCT".equals(sTypeObject) || "AT_C_DESIGN_PART".equals(sTypeObject) ) {
        	  sTypeFilterSearch ="type_AT_C_DESIGN_PART,type_AT_C_COS,type_AT_C_STANDARD_PART";
          }  else {
			  sTypeFilterSearch ="type_Part";
		  }
		  
          if (calledMethod.equals("addExisting") && strPolicyClassification.equalsIgnoreCase("Unresolved"))
		  {
			if ("AT_C_COS".equals(sTypeObject) || "AT_C_STANDARD_PART".equals(sTypeObject) ) {
        	    bAlertAddExistingPart =true;
            }	  
          } else if(calledMethod.equals("replaceExisting")){
			  
			if (!"AT_C_DESIGN_PART".equals(sTypeObject) && !"AT_C_COS".equals(sTypeObject) && !"AT_C_STANDARD_PART".equals(sTypeObject) ) {
        	    bAlertReplaceExistingPart =true;
            } 
		  }
		  // Alstom
	if(calledMethod.equals("addExisting")){
    	//Modified to fix IR-090294V6R2012
		if ("AT_C_COS".equals(sTypeObject) || "AT_C_STANDARD_PART".equals(sTypeObject) ) {
			String sAlertAddExistingCOSStandardPart = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.AlertAddExistingCOSStandardPart","emxUnresolvedEBOMStringResource", language);
        	%>
	    		<script language="javascript">
				warningMessage = "<%=sAlertAddExistingCOSStandardPart%>";
	    		</script>
	    	<%
        }	  
		//contentURL ="../common/emxFullSearch.jsp?field=TYPES="+sTypeFilterSearch+":SPARE_PART=No:" + stateNames + "&freezePane=Name,Name1&showInitialResults=false&calledMethod="+calledMethod+"&table=ENCAffectedItemSearchResult&suiteKey="+suiteKey+"&submitLabel="+"emxFramework.Command.Done"+"&hideHeader=true&HelpMarker=emxhelpfullsearch&excludeOIDprogram=emxUnresolvedPart:at_excludeRecursiveOIDAddExistingAndTemplate&objectId="+objectId+"&selection=multiple&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&selPartParentOId="+selPartParentOId+"&selPartRowId="+selPartRowId;
		DomainObject domObj = UIUtil.isNotNullAndNotEmpty(selPartObjectId)?new DomainObject(selPartObjectId):null;
		String currentState = UIUtil.isNotNullAndNotEmpty(selPartObjectId)?domObj.getInfo(context, EngineeringConstants.SELECT_CURRENT): "";
		 
		  if(!currentState.equalsIgnoreCase(DomainConstants.STATE_PART_PRELIMINARY)){
			  %>
		        <script language="javascript">
		        if(warningMessageinViewMode == ""){
		        	//XSSOK
		            warningMessageinViewMode = "<%=editInViewMode%>";
		        }
		        </script>

			<%
		  }
		  HashMap paramMap = new HashMap();
	    	 paramMap.put("objectId", selPartObjectId);
	    	 String[] methodargs = JPO.packArgs(paramMap);
	    	 boolean status =  JPO.invoke(context, "emxENCActionLinkAccess", null, "isApplyAllowed", methodargs,Boolean.class);
			if(!status){
				  %>
			        <script language="javascript">
			        if(warningMessageinViewMode == ""){
			        	//XSSOK
			            warningMessageinViewMode = "<%=noModifyAccess%>";
			        }
			        </script>

			<%
		  }
    	//Modified to fix IR-090294V6R2012
		
//MGS Start
		contentURL ="../common/emxFullSearch.jsp?field=TYPES="+sTypeFilterSearch+":POLICY=policy_ECPart,policy_DevelopmentPart,policy_ConfiguredPart,policy_StandardPart:IS_ASSIGNED_PART=False:CURRENT=policy_ECPart.state_Preliminary,policy_ECPart.state_Review,policy_ECPart.state_Approved,policy_ECPart.state_Release,policy_DevelopmentPart.state_Complete,policy_DevelopmentPart.state_PeerReview,policy_DevelopmentPart.state_Create,policy_ConfiguredPart.state_Preliminary&table=ENCAffectedItemSearchResult&showInitialResults=true&submitLabel=emxFramework.Command.Done&hideHeader=true&suiteKey=UnresolvedEBOM&HelpMarker=emxhelpfullsearch&freezePane=Name,Name1&calledMethod="+calledMethod+"&excludeOIDprogram=emxUnresolvedPart:at_excludeRecursiveOIDAddExistingAndTemplate"+"&objectId="+objectId+"&selection=multiple&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&selPartParentOId="+selPartParentOId;
		//contentURL ="../common/emxFullSearch.jsp?field=TYPES=type_Part:SPARE_PART=No:" + stateNames + "&freezePane=Name,Name1&showInitialResults=true&calledMethod="+calledMethod+"&table=ENCAffectedItemSearchResult&suiteKey="+suiteKey+"&submitLabel="+"emxFramework.Command.Done"+"&hideHeader=true&HelpMarker=emxhelpfullsearch&excludeOIDprogram=emxENCFullSearch:excludeRecursiveOIDAddExisting&objectId="+objectId+"&selection=multiple&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&selPartParentOId="+selPartParentOId;
			//MGS End
    }
    else if(calledMethod.equals("replaceExisting")){
	//Modified to fix IR-090294V6R2012
	contentURL ="../common/emxFullSearch.jsp?field=TYPES="+sTypeFilterSearch+":" + stateNames + "&showInitialResults=false&table=ENCAffectedItemSearchResult&suiteKey="+suiteKey+"&cancelLabel=emxFramework.Command.Cancel&submitLabel=emxFramework.Command.Done&HelpMarker=emxhelpfullsearch&excludeOIDprogram=emxUnresolvedPart:at_excludeRecursiveOIDAddExistingAndTemplate&excludeOID="+selPartObjectId+"&hideHeader=true&objectId="+objectId+"&selection=multiple&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&relType="+relType+"&selPartParentOId="+selPartParentOId+"&replace=true&submitURL=../engineeringcentral/emxEngrPartBOMHiddenProcess.jsp?calledMethod="+calledMethod;
        session.removeAttribute("selPartRowId");
        session.setAttribute("selPartRowId", selPartRowId);
    } else if(calledMethod.equals("copyFrom") || calledMethod.equals("AVLCopyFrom")){
	//Modified to fix IR-090294V6R2012
		contentURL += "&showInitialResults=false&selection=single&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&excludeOID="+selPartObjectId+"," + selPartParentOId + "&selPartParentOId="+selPartParentOId+"&submitURL=../engineeringcentral/emxEngrPartBOMHiddenProcess.jsp?calledMethod="+calledMethod;
    } else if(calledMethod.equals("copyTo")){
	//Modified to fix IR-090294V6R2012
		contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_Part:" + stateNames + "&table=ENCAffectedItemSearchResult&HelpMarker=emxhelpfullsearch&hideHeader=true&objectId="+objectId;
        contentURL += "&showInitialResults=false&selection=single&zprevmode="+prevmode+"&excludeOID="+selPartObjectId+"," + selPartParentOId+"&submitURL=../engineeringcentral/emxEngrPartBOMHiddenProcess.jsp?calledMethod="+calledMethod;
    } else if (calledMethod.equals("removePart")) {
    	 String[] selectedObj    = (String[])session.getAttribute("selectedObjs");
    	
    	  for(int i=0;i<selectedObj.length;i++){
    		  String selectedObjId=	(String) selectedObj[i].substring(0, selectedObj[i].indexOf('|'));
    		  	sBuff.append(selectedObjId);
    		  	
    		  	if(i<selectedObj.length-1){    		  	   
    		  	   sBuff.append("|");
    		  	}
    		    }
    	contentURL = "../common/emxFullSearch.jsp?field=TYPES="+sTypeFilterSearch+"&objectId="+objectId+"&includeOIDprogram=emxENCFullSearch:includeCommonParts&HelpMarker=emxhelpfullsearch&table=ENCAffectedItemEBOMRemovePartSearchResult&freezePane=Name,Matches&selection=single&submitURL=../engineeringcentral/emxEngrMarkupChangeProcess.jsp&fieldNameActual=partToRemoveId&fieldNameDisplay=partToRemove&formName=massEBOMUpdate&suiteKey=EngineeringCentral";
    }    else if(calledMethod.equals("changePosition")) {
	
	  //IR-136973V6R2013
        %>
        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="Javascript">
            try{
                var selectedRow = getTopWindow().getWindowOpener().emxUICore.selectSingleNode(getTopWindow().getWindowOpener().oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
                var level    = selectedRow.getAttribute("level");
                var status = selectedRow.getAttribute("status");
              //XSSOK
                if(<%=isMBOMInstalled%>){
					var rel = selectedRow.getAttribute("rel");
					if(rel == null){
						rel = selectedRow.getAttribute("relType");
						var arrRel = rel.split("|");
						rel = arrRel[0];
					}
					//XSSOK
					if(rel != null && rel != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && rel != "<%=sSymbolicRelEBOMName%>"){
						//XSSOK
						alert("<%=strInvalidSelectionMsg%>");
						getTopWindow().closeWindow();
					}
					else{
						var Xpath="/mxRoot/rows//r[@level = '"+level+"' and (@status = 'add' or @status = 'cut')]";
						var AddorDelRow=getTopWindow().getWindowOpener().emxUICore.selectNodes(getTopWindow().getWindowOpener().oXML.documentElement, Xpath);
						
						if(AddorDelRow.length > 0)    {
							//XSSOK
							alert("<%=strAddDeleteErrorMsg%>");
							getTopWindow().closeWindow();
						}
					    }
				}else{ 
					  var Xpath="/mxRoot/rows//r[@level = '"+level+"' and (@status = 'add' or @status = 'cut')]";
                      var AddorDelRow=getTopWindow().getWindowOpener().emxUICore.selectNodes(getTopWindow().getWindowOpener().oXML.documentElement, Xpath);
                      
                      if(AddorDelRow.length > 0)    {
                    	//XSSOK
                      alert("<%=strAddDeleteErrorMsg%>");
                      getTopWindow().closeWindow();
                }
			   }
               }
            catch(e){
              //  alert("<%=ChangePositionErrorMessage%>"+e.message);
              //  getTopWindow().close();
      }
        </script>
        <%
    	contentURL = "../common/emxIndentedTable.jsp?program=emxPart:getEBOMDataForChangePosition&massPromoteDemote=false&triggerValidation=false&suiteKey=EngineeringCentral&table=ENCEBOMIndentedSummary&HelpMarker=emxhelppartbomedit&objectId="+selPartParentOId+"&tableRowId="+XSSUtil.encodeForJavaScript(context,tableRowIdList[0])+"&selection=single&header=emxEngineeringCentral.Part.ChangePositionPageHeading&submitURL=../engineeringcentral/emxEngrBOMChangePositionDailogProcess.jsp&cancelLabel=emxEngineeringCentral.Button.Cancel&submitLabel=emxEngineeringCentral.Button.Submit";
    }
    
    //if(isENGSMBInstalled){ //Commented for IR-213006
    	contentURL +="&formInclusionList=VPM_PRODUCT_NAME,PART_RELEASE_PHASE";
    //}
    if(isMBOMInstalled)
    {
        String commonViewAddExisting = emxGetParameter(request,"commonViewAddExisting");
        if("true".equalsIgnoreCase(commonViewAddExisting))
    	contentURL +="&commonViewAddExisting=true";
    }
%>
<html>
<head>
</head>
<body>
<form name="engrfullsearch" method="post">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<input type="hidden" name="excludeOID" value=""/>
<input type="hidden" name="highestFN" value="0"/>
<input type="hidden" name="selectedObjs" value=""/>
<script language="Javascript">
var frameName = parent.name;
    if(warningMessage != ""){
        alert(warningMessage);
    } else {
    	//XSSOK
        var mode = "<%=calledMethod%>";
        var sCustomFilter = "<%=sCustomFilter%>";
        if(mode == 'changePosition' || mode=='AVLCopyFrom') {
           // var selectedRowId = "<xss:encodeForJavaScript><%=selPartRowId%><xss:encodeForJavaScript>";
           //XSSOK
            var selectedRowId = "<%=selPartRowId%>";
            if ("0" == selectedRowId &&  mode!='AVLCopyFrom') {
            	//XSSOK
            	alert("<%=changePositionRootNodeSelectionMess%>");
                closeWindow();
            } else {
            	//XSSOK
            	document.location.href = "<%=contentURL%>";
            }
            
        } else {
 	       //Modified for IR-070371V6R2012
 	       if(mode!='removePart' && mode!='addExisting') {
  	    	  showModalDialog("../common/emxBlank.jsp","570","570","true"); 	          
	    	  var objWindow =  getTopWindow().modalDialog.contentWindow;
	    	  document.engrfullsearch.target=objWindow.name;
            }
 	      	if(mode=='addExisting') {
				//QC 5209 Start
				var str = window.top.parent.name;
				var n = str.indexOf("parentOID");
 	      		if((!getTopWindow().getWindowOpener()) && (sCustomFilter == "engineering" || sCustomFilter == "Engineering") && n>0){
 	      		//if((!getTopWindow().getWindowOpener()) && (sCustomFilter == "engineering" || sCustomFilter == "Engineering")){
				////QC 5209 End	
 	 	      		var contentFrame = findFrame(getTopWindow(),frameName);
 	 	      		contentFrame = (contentFrame != null && contentFrame != undefined)? contentFrame : getTopWindow();
	 	      		var tablemode = "view";
	 	      		if(contentFrame && contentFrame.editableTable && contentFrame.editableTable != null && contentFrame.editableTable != undefined){
	 	      				tablemode = contentFrame.editableTable.mode; 
	 	      		}
	 	      		else{
	 	      			tablemode = "edit";
	 	      		}
	 	      		if("view"== tablemode && warningMessageinViewMode != ""){
		 	      	        alert(warningMessageinViewMode);
	 	      		}
	 	      		else{
	 	      			var nosRowsselected = "<%=nosRowsselected%>";
	 	      			if(nosRowsselected>1){
	 	      				alert("<%=strMultipleSelection%>");
	 	      			}
	 	      			else{
		 	      			contentURL = "<%=contentURL%>"+"&highestFN="+highest+"&frameName="+frameName+"&submitURL=../engineeringcentral/AT_MGS_emxEngrPartBOMAddExisting.jsp?calledMethod="+mode+"&tablemode="+tablemode;
		 	      					showWindowShadeDialog(contentURL,true);
	 	      			}
	 	      		}
 	      		}
 	      		else{
 	      			contentURL = "<%=contentURL%>"+"&highestFN="+highest+"&cancelLabel="+"emxFramework.Command.Cancel"+"&submitLabel="+"emxFramework.Command.Done"+"&submitURL=../engineeringcentral/AT_MGS_emxEngrPartBOMAddExisting.jsp?calledMethod="+mode;
	 	      		showModalDialog("../common/emxBlank.jsp","570","570","true"); 	          
	 	      		var objWindow =  getTopWindow().modalDialog.contentWindow;
	 		    	document.engrfullsearch.target=objWindow.name;
	 	      		document.engrfullsearch.excludeOID.value=excludeID;
			        document.engrfullsearch.highestFN.value = highest;
			      //XSSOK
			        document.engrfullsearch.action=contentURL
			        document.engrfullsearch.submit();
 	      		}
	        }
 	      	else if(mode=='removePart') {
		        document.engrfullsearch.selectedObjs.value="<xss:encodeForJavaScript><%=sBuff.toString()%></xss:encodeForJavaScript>";
		      //XSSOK
		        document.engrfullsearch.action="<%=contentURL%>";
		        document.engrfullsearch.submit();
			}	else {
				//XSSOK
		        document.engrfullsearch.action="<%=contentURL%>";
	    	    document.engrfullsearch.submit();
	        }
        }
    }
</script>
</form>
</body>
</html>
