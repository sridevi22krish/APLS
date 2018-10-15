 <%--  FullSearchPreProcess.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@ page import="com.matrixone.apps.unresolvedebom.*,com.matrixone.apps.domain.DomainObject" %>
<%@ page import="com.matrixone.apps.unresolvedebom.UnresolvedEBOM" %>

<jsp:useBean id="unresolvedEBOM" class="com.matrixone.apps.unresolvedebom.UnresolvedEBOM" scope="session"/>
<jsp:useBean id="pueChange" class="com.matrixone.apps.unresolvedebom.PUEChange" scope="session"/>
<jsp:useBean id="unresolvedPart" class="com.matrixone.apps.unresolvedebom.UnresolvedPart" scope="session"/>

<%

boolean allowAddExisting = true;
boolean isIntersectEffectivityForReplace= true;
//2012x-Starts
//String isWipBomAllowed  = FrameworkProperties.getProperty("emxUnresolvedEBOM.WIPBOM.Allowed");
String isWipBomAllowed  = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOM.WIPBOM.Allowed");
String parentOID        = emxGetParameter(request, "parentOID");
String ObjectId        = emxGetParameter(request, "objectId");
if(parentOID == null)
	parentOID = ObjectId;

String calledMethod     = emxGetParameter(request,"calledMethod");
String affectedItems    = "";
String isWipMode        = "false";
String STATEPRELIMINARY = PropertyUtil.getSchemaProperty(context,"policy",UnresolvedEBOMConstants.POLICY_CONFIGURED_PART,"state_Preliminary");
boolean isCyclicDependent = false;

//2012x-Ends
String language  = request.getHeader("Accept-Language");
String addToPUEECONotAllowed = i18nStringNowUtil("emxUnresolvedEBOM.PUEECO.ErrorOnCreateOrAddExisiting","emxUnresolvedEBOMStringResource", language); 
String editInviewMode = i18nStringNowUtil("emxUnresolvedEBOM.Command.editPartsInViewMode","emxUnresolvedEBOMStringResource", language);
String pleaseSelectAlert = i18nStringNowUtil("emxUnresolvedEBOM.PUEECO.PleaseSelect","emxUnresolvedEBOMStringResource", language);
String strMultipleSelection        = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", 
		context.getLocale(),"emxFramework.Common.PleaseSelectOneItemOnly");

String isFromRMB    		= emxGetParameter(request, "isFromRMB");
String selPartRowId 		= "";

// Filter Add For Alstom
String sTypeFilterSearch = "";
String sAlertMessageReplaceExisting = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.ReplaceExistingPart","emxUnresolvedEBOMStringResource", language);
String sAlertAddExistingCOSStandardPart = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.AlertAddExistingCOSStandardPart","emxUnresolvedEBOMStringResource", language);
boolean bAlertAddExistingPart = false;
boolean bAlertReplaceExistingPart = false;

//String releaseProcess = DomainObject.newInstance(context, parentOID).getInfo(context, EngineeringConstants.ATTRIBUTE_RELEASE_PHASE_VALUE);
//isWipBomAllowed = Boolean.toString(EngineeringConstants.DEVELOPMENT.equals(releaseProcess));
int nosRowsselected = 0;
isWipBomAllowed =  UnresolvedEBOM.isWipBomAllowedForParts(context,parentOID);
if("addExisting".equalsIgnoreCase(calledMethod)){
	String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
	
	if(tableRowIdList == null){
		nosRowsselected = 0;
	}
	else{
		nosRowsselected = tableRowIdList.length;
	}
}
if("true".equalsIgnoreCase(isFromRMB)) {
	String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
    StringList tempList     = FrameworkUtil.split(" "+tableRowIdList[0], "|");
    selPartRowId            = ((String)tempList.get(3)).trim(); 
}

%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript">
    var warningMessage="";
	var warningMessageInViewMode="";
    var dupemxUICore;
    var mxRoot;
    var xmlRef;
    var contentFrame  = findFrame(parent,"listHidden");
    var validationFailed = false;
    var objectNames = "";

    if (contentFrame != null)
        xmlRef = contentFrame.parent.oXML;

    if(xmlRef!=undefined)
    {
    	dupemxUICore   = contentFrame.parent.emxUICore;
    	mxRoot         = contentFrame.parent.oXML.documentElement;
    }
    var status;
    var rel;
    var isReplaceExisting = "false";
    var findNumberIndex = contentFrame.parent.colMap.getColumnByName("Find Number").index;
    
	var isFROMRMB = "<%=isFromRMB%>";
	var rmbRowId  = "<%=selPartRowId%>";
	var xPath     =  isFROMRMB == "true" ?  "/mxRoot/rows//r[@id='"+rmbRowId+"']" : "/mxRoot/rows//r[@checked='checked']";	            	

    var checkedRows = emxUICore.selectNodes(contentFrame.parent.oXML,xPath); 
    var findNumberList = emxUICore.selectNodes(contentFrame.parent.oXML, xPath+"/r/c["+findNumberIndex+"]/text()");  
     
     var highest = 0;
  //Start ----- of DragNDrop
    if(checkedRows.length == 0  || rmbRowId == "0"){
    	xPath = "/mxRoot/rows//r[@id='0']";
    	checkedRows = emxUICore.selectNodes(contentFrame.parent.oXML, "/mxRoot/rows//r['0']");
    	findNumberList = emxUICore.selectNodes(contentFrame.parent.oXML,xPath+"/r/c["+findNumberIndex+"]/text()");
    }
  //End ----- of DragNDrop
  
  
     for(j=0;j<findNumberList.length;j++){
     	var intNodeValue = parseInt(findNumberList[j].nodeValue);
     	if(j==0)
     		highest = intNodeValue;
     	else if (highest<intNodeValue)
     		highest = intNodeValue;    	
     }
     
    
    //2012x--Starts
    //XSSOK
    var isWipBomAllowed = "<%=isWipBomAllowed%>";
    var selectedParts="";

    var releaseProcessIndex = contentFrame.parent.colMap.getColumnByName("ReleaseProcess").index; 
    var releaseProcessCell = emxUICore.selectNodes(contentFrame.parent.oXML, "/mxRoot/rows//r[@id='0']/c["+releaseProcessIndex+"]");
	var actual ="";
	if(releaseProcessCell[0]!= null && releaseProcessCell[0] != undefined){
         actual= releaseProcessCell[0].getAttribute('a');	   
	}
       
    isWipBomAllowed = (actual == "<%=EngineeringConstants.DEVELOPMENT%>")? "true": "false";
   	
    //2012x--Ends

     try{
        if(dupemxUICore!=undefined)
        {
            var checkCount;
            var MxRootPath  = "/mxRoot/columns//column";
            var nColumn     = dupemxUICore.selectNodes(mxRoot, MxRootPath);
            var checkedRow  = dupemxUICore.selectSingleNode(mxRoot, xPath);
            if (checkedRow != null) {
            	status = checkedRow.getAttribute("status");
            }

            //2012x-Starts-prepares a string with selected obj ids information for ADD TO PUEECO Existing
            var calledMethod = "<xss:encodeForJavaScript><%=calledMethod%></xss:encodeForJavaScript>";
            if ((calledMethod == "createAndassignPUEECO" || calledMethod == "addToExistingPUEECO" || calledMethod == "createAndAssignChangeOrder") && isWipBomAllowed.toLowerCase()=="true")
            {
	            var rowsSelected = dupemxUICore.selectNodes(mxRoot, xPath);
	            if (rowsSelected.length == 0){
	            	//XSSOK   
	            	warningMessage   = "<%=pleaseSelectAlert%>";
	            	   }
	            else
	            	warningMessage   = "";
            
	            if (rowsSelected.length > 0){

                    for(var i=0; i<rowsSelected.length; i++) {
                            var oid   = rowsSelected[i].getAttribute("o");
                            var id    = rowsSelected[i].getAttribute("id");
                            var p     = rowsSelected[i].getAttribute("p");
                            var relId = rowsSelected[i].getAttribute("r");
                            p         = (p == null || p == "null")?"":p;
                            relId     = (relId == null || relId == "null")?"":relId;
                            
                            if (selectedParts.indexOf(oid) > -1) {
								continue;
                            }
                            
                            selectedParts += oid+"|"+relId+"|"+id +"~";
                            var colInitialRelease = contentFrame.parent.emxEditableTable.getCellValueByRowId(id,"InitialRelease");
                            var InitialRelease    = colInitialRelease.value.current.actual;
                            var columnState       = contentFrame.parent.emxEditableTable.getCellValueByRowId(id,"State");
                            var objState          = columnState.value.current.actual;
                            var columnAdd         = contentFrame.parent.emxEditableTable.getCellValueByRowId(id,"Add");
                            var columnAddVal      = columnAdd.value.current.actual;
                            var columnName        = contentFrame.parent.emxEditableTable.getCellValueByRowId(id,"Name");
                            var objName           = columnName.value.current.actual;
                            var columnPolicy      = contentFrame.parent.emxEditableTable.getCellValueByRowId(id,"Policy");
                            var columnPolicyVal   = columnPolicy.value.current.actual;

                            //condition check for allowing only preliminary parts and those are not connected to any PUEECO
                            if ((InitialRelease != "" || objState != "<%=UnresolvedEBOMConstants.STATE_PART_PRELIMINARY%>") || columnAddVal != "" || columnPolicyVal != "Configured Part") {
                            	validationFailed = true;                            	
                            	objectNames = (objectNames == "") ? objName : (objectNames + "," + objName);
                            }
                     }

                    if (validationFailed) {
                    	//XSSOK
                    	warningMessage = "<%=addToPUEECONotAllowed%>";
                    	warningMessage += "\n" + objectNames; 
                    } 
               } //2012x-Ends
          }   
      }
   }      
    catch(e){
        warningMessage = e.message;
    }

</script>
<%
    //2012x-Starts
     String contentURL = "";
     String objectId   = emxGetParameter(request,"objectId");
     String contextECO = emxGetParameter(request,"PUEUEBOMContextChangeFilter_actualValue");
     contextECO  = (contextECO == null || "null".equalsIgnoreCase(contextECO))?"":contextECO;
     String strContextECOSelection = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.ContextECOSelection","emxUnresolvedEBOMStringResource", language);
     
     //Force check for context ECO in case ECO change process/NON WIP BOM Mode
     if("".equals(contextECO) && !"addToProduct".equals(calledMethod) && "false".equalsIgnoreCase(isWipBomAllowed)) {
%>
		    <script language = "javascript">
			    if(warningMessage == ""){
			    	//XSSOK
			        warningMessage = "<%=strContextECOSelection%>";
			    }
		    </script>
<%
		} else { 
    	    
	      String timeStamp              = emxGetParameter(request,"timeStamp");
	      String STATESUPERSEDED        = PropertyUtil.getSchemaProperty(context,"policy",com.matrixone.apps.unresolvedebom.UnresolvedEBOMConstants.POLICY_CONFIGURED_PART, "state_Superseded");
	      String supersededPart         = i18nStringNowUtil("emxUnresolvedEBOM.Alert.SupersededPart","emxUnresolvedEBOMStringResource", language);
	      DomainObject doUnresolvedPart = DomainObject.newInstance(context);
	      
	      
	      String AddExistingOnDeleted    = i18nStringNowUtil("emxUnresolvedEBOM.BOM.AddExistingOnDeleted", "emxUnresolvedEBOMStringResource",language);
	      String strRootNodeErrorMsgForReplaceExisting = i18nStringNowUtil("emxUnresolvedEBOM.BOM.ReplaceExistingRootNodeError","emxUnresolvedEBOMStringResource", language);
	      String strInvalidSelectionMsg  = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.Invalidselection","emxUnresolvedEBOMStringResource", language);
	      String strInvalidApplicability = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.Invalidapplicability","emxUnresolvedEBOMStringResource", language);
	      String alrtMsg                 = i18nStringNowUtil("emxUnresolvedEBOM.Alert.DoNotAllowUnUnresolvedWithinResolved","emxUnresolvedEBOMStringResource",language);
	      String strInvalidSelectionCopyFromMessage = i18nStringNowUtil("emxUnresolvedEBOM.Alert.InvalidPartSelection","emxUnresolvedEBOMStringResource", language);
	      String editInViewMode        = i18nStringNowUtil("emxEngineeringCentral.Command.EditingPartsInViewMode","emxEngineeringCentralStringResource",language);
	      String noModifyAccess        = i18nStringNowUtil("emxEngineeringCentral.DragDrop.Message.NoModifyAccess","emxEngineeringCentralStringResource",language);
	      String jsTreeID         = emxGetParameter(request,"jsTreeID");
	      String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
	      String selPartRelId     = "";
	      String selPartObjectId  = "";
	      String selPartParentOId = "";
	      String strPolicyClassification = "";
	      String strRelEbomIds     = null;
	      String selectedPartRowId = "";
	      String parentPartState   = "";
	      
	      if (tableRowIdList!= null) {
		        for (int i=0; i< tableRowIdList.length; i++) {
		          String tableRow       = (String)tableRowIdList[i];	
		          StringList slDataList = FrameworkUtil.splitString(" "+tableRow, "|");
		          Iterator itrList      = slDataList.iterator();
                  String connectionId   = (itrList.hasNext())?(String)itrList.next(): "";
                  String childObjId     = (itrList.hasNext())?(String)itrList.next(): "";
                  String parentPartId   = (itrList.hasNext())?(String)itrList.next(): "";
                  String selectedRowId  = (itrList.hasNext())?(String)itrList.next(): "";
                  
                  parentPartId = "".equalsIgnoreCase(parentPartId)?childObjId:parentPartId;

		          doUnresolvedPart.setId(parentPartId);
		          parentPartState = doUnresolvedPart.getInfo(context, com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
                  //if the selectedPart state is release allow addexisting operation thru context change only
                  String selectedPartState = "";
                  if (!parentPartId.equals(childObjId)) {
                      selectedPartState = (String)(DomainObject.newInstance(context,childObjId)).getInfo(context, com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
                  }
                  selectedPartState = !"".equals(selectedPartState)?selectedPartState:parentPartState;
                  
                  if (STATESUPERSEDED.equalsIgnoreCase(parentPartState)) {
%>
                      <script language="Javascript">
                      			//XSSOK
                              warningMessage = "<%=supersededPart%>";
                      </script>
<%
                         break;
                      }     


	              //if parent part state is preliminary and development mode setting is true then only wip mode will be true.
	              if ("true".equalsIgnoreCase(isWipBomAllowed)) {
	            	  if ("replaceExisting".equalsIgnoreCase(calledMethod) && STATEPRELIMINARY.equalsIgnoreCase(parentPartState)) {
	                       isWipMode = "true";
	            	  }
	            	  if (("addExisting".equalsIgnoreCase(calledMethod) || "copyFrom".equals(calledMethod)) && STATEPRELIMINARY.equalsIgnoreCase(selectedPartState)) {
	            		  isWipMode = "true";
	            	  }
	              }

	              
	              //Starts for 2012x--force check for released parts to follow change proces incase of replace existing
	              if("".equals(contextECO) && "false".equalsIgnoreCase(isWipMode) && ("replaceExisting".equalsIgnoreCase(calledMethod) || "addExisting".equalsIgnoreCase(calledMethod) || "copyFrom".equals(calledMethod))) {
%>
	              <script language = "javascript">
	                if(warningMessage == ""){
	                	//XSSOK
	                    warningMessage = "<%=strContextECOSelection%>";
	                }
	                </script>
<%                } 
	              
	              else {
%>
				          <script language="Javascript">

				          if(warningMessage == "" && "<xss:encodeForJavaScript><%=calledMethod%></xss:encodeForJavaScript>" == "addExisting") {
					            if (status == 'cut' || status == 'add') {
					            	//XSSOK
					                warningMessage = "<%=AddExistingOnDeleted%>";
					            }
				          }
				          </script>
<%
			
				          if(calledMethod.equals("copyFrom"))
				          {
				            String strWarningCFDeleteMsg =  i18nStringNowUtil("emxUnresolvedEBOM.BOM.CopyFromOnDeleted","emxUnresolvedEBOMStringResource",language);
				            
%>
				          <script language="Javascript">
				          
				              if((status == 'cut' || status == 'add')  && warningMessage == "")
				               {
				            	  	//XSSOK
				            	    warningMessage = "<%=strWarningCFDeleteMsg%>";
				               }
				          </script>
<%

	              StringList sList = com.matrixone.apps.domain.util.FrameworkUtil.split(" "+(tableRowIdList[0]).toString(),"|");
	              String strTargetPartId = ((String)sList.get(1)).trim();
	              String strTarPartRelId = ((String)sList.get(0)).trim();
	              String strTarPartRowId = ((String)sList.get(3)).trim();
	

	              if("0".equals(strTarPartRowId))
	                  strTarPartRelId = strTargetPartId;

	  		    unresolvedEBOM.setSTargetPartId(strTargetPartId);
	  		    unresolvedEBOM.setSTargetCtxtECOId(contextECO);
	  		    unresolvedEBOM.setSTargetPartRelId(strTarPartRelId);
	  		    unresolvedEBOM.setSTargetPartRowId(strTarPartRowId);

	  		}
	       //process - relId|objectId|parentId - using the tableRowId
	       String tableRowId = tableRowIdList[i];
	       String firstIndex = tableRowIdList[i].substring(0,tableRowIdList[i].indexOf("|"));
	       java.util.StringTokenizer strTok = new java.util.StringTokenizer(tableRowId,"|");
	       selPartRelId = strTok.nextToken();
	       String sRelName = "";
	       if(!firstIndex.equals(""))
	       {
	           matrix.db.Relationship rel=new matrix.db.Relationship(selPartRelId);
	           rel.open(context);
	           sRelName=rel.getTypeName();
	           rel.close(context);
	       }
	
	           if(calledMethod.equals("replaceExisting"))
	           {
	               String strWarningReplaceExistingMsg  = i18nStringNowUtil("emxUnresolvedEBOM.BOM.ReplacewithExistingOnAddedDeleted",
	                       "emxUnresolvedEBOMStringResource",
	                       language);
	               String strWarningReplaceExistingMsgForEdit = i18nStringNowUtil("emxUnresolvedEBOM.Edit.checkOnPendingChange",
	                       "emxUnresolvedEBOMStringResource",
	                       language);
	
	               String strWarningMSGForIntersectEffectivity = i18nStringNowUtil("emxUnresolvedEBOM.Edit.EffectivityMatch",
	                       "emxUnresolvedEBOMStringResource",
	                       language);
	               if ("0".equals(selectedPartRowId)){
%>
	                  <script language="Javascript">
	                  //XSSOK
	                  warningMessage = "<%=strRootNodeErrorMsgForReplaceExisting%>";
	                  </script>
<%
	                 break;
	              }
	              
	                //checking for the same pending change or not.
                    if ("false".equalsIgnoreCase(isWipMode)) {
	                    try {
	                    	  isIntersectEffectivityForReplace = pueChange.isIntersectEffectivity(context,contextECO,selPartRelId);
	                    } catch (Exception e) {	                    	
	                        isIntersectEffectivityForReplace = false;
	                    }
	                    
	                    isCyclicDependent = unresolvedPart.checkForCyclicPrerequisite(context, selPartRelId, contextECO);	                    
                    }
%>
	                <script language="Javascript">
	                    isReplaceExisting = "true";
	                   if(status == 'add' && warningMessage == ""){
	                	   //XSSOK
	                       warningMessage = "<%=strWarningReplaceExistingMsg%>";
	                    }
	                   else if(status == 'cut' && warningMessage == ""){
	                	 //XSSOK
	                       warningMessage = "<%=strWarningReplaceExistingMsg%>";
	                    }
	                 //XSSOK
	                   else if(<%=allowAddExisting%> == false){
	                	 //XSSOK
	                       warningMessage = "<%=strWarningReplaceExistingMsgForEdit%>";
	                   }
	                 //XSSOK
	                   else if (<%=isCyclicDependent%> == true) {
	                       warningMessage = "<%=i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.Cyclicdependency", "emxUnresolvedEBOMStringResource", language)%>";
	                   }
	                 //XSSOK
	                   else if(<%=isIntersectEffectivityForReplace%> == false){
	                	 //XSSOK
	                       warningMessage = "<%=strWarningMSGForIntersectEffectivity%>";
	                     }
	               </script>
	
<%
	                if (strTok.countTokens() < 2 || sRelName.equals(""))
	                {
	
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
	           }
	           if(!"".equals(firstIndex)) {
	              selPartObjectId = strTok.nextToken();
	              if (strTok.hasMoreTokens())
	              {
	              selPartParentOId = strTok.nextToken();
	              }
	              else
	              {
	                  selPartParentOId = objectId;
	              }
	
	           } else {
	              selPartObjectId = objectId;
	              selPartParentOId = objectId;
	           }
	           
	       }
	    }
	  }
	  if((selPartObjectId == null || "".equals(selPartObjectId)) && calledMethod.equals("addExisting")){
			  selPartObjectId = objectId;
	          selPartParentOId = objectId;
	          if("true".equals(isWipBomAllowed)){
	        	  isWipMode = "true";
	          }
	  }
	  if(selPartObjectId!=null && !"".equals(selPartObjectId)) {
	      boolean checkAppliability = false;
		  com.matrixone.apps.domain.DomainObject domPart = new com.matrixone.apps.domain.DomainObject(selPartObjectId);
		  String sTypeObject = (String)domPart.getInfo(context, DomainObject.SELECT_TYPE);
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
		  
		  strPolicyClassification = (String)domPart.getInfo(context,"policy.property[PolicyClassification].value");
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
          com.matrixone.apps.domain.DomainObject domParentPart = new com.matrixone.apps.domain.DomainObject(selPartParentOId);
          String parentPartClassification = (String)domParentPart.getInfo(context,"policy.property[PolicyClassification].value");

          if((calledMethod.equals("addExisting") && !strPolicyClassification.equalsIgnoreCase("Unresolved"))
                  || (calledMethod.equals("replaceExisting") && !parentPartClassification.equalsIgnoreCase("Unresolved"))) {
%>

            <script language="Javascript">
                if(warningMessage == ""){
                	//XSSOK
                    warningMessage = "<%=strInvalidSelectionMsg%>";
                }
            </script>

<%

          } else if(!strPolicyClassification.equalsIgnoreCase("Unresolved")&& calledMethod.equals("copyFrom")) {

%>
            <script language="javascript">
	            if(warningMessage == ""){
	            	//XSSOK
	                warningMessage = "<%=strInvalidSelectionCopyFromMessage%>";
	            }
            </script>

<%

          } else {
                if (calledMethod.equals("replaceExisting")) {
                    checkAppliability = true;
                }

              }

    if(checkAppliability && !UnresolvedPart.isTopLevelPart(context,selPartObjectId)) {
        boolean flag = true;
        if(!flag) {

%>

            <script>
                if(warningMessage == "") {
                	//XSSOK
                    warningMessage = "<%=strInvalidApplicability%>";
                }
            </script>
<%

        }
	  }
	}
	if(strRelEbomIds==null) {
	    strRelEbomIds="";
	  }
	  String prevmode = emxGetParameter(request, "prevmode");
	  if(prevmode == null || "null".equals(prevmode)){
	    prevmode ="";
	  }


	  if(!prevmode.equals("true")){
	    session.setAttribute("strRelEbomIds",strRelEbomIds);
	    session.removeAttribute("searchPARTprop_KEY");
	  }
	  String sTypePart ="";
	  if (!"".equals(sTypeFilterSearch)) {
		  sTypePart = sTypeFilterSearch;
	  } else {
		  sTypePart ="type_Part";
	  }
	  if(calledMethod.equals("addExisting") && strPolicyClassification.equalsIgnoreCase("Unresolved"))
	  {
		if (bAlertAddExistingPart) {
			%>
	    		<script language="javascript">
				warningMessage = "<%=sAlertAddExistingCOSStandardPart%>";
	    		</script>
	    	<%
		}
		  DomainObject domObj = UIUtil.isNotNullAndNotEmpty(selPartObjectId)?new DomainObject(selPartObjectId):null;
		  String changeControlled = UIUtil.isNotNullAndNotEmpty(selPartObjectId)?domObj.getInfo(context, EngineeringConstants.SELECT_ATTRIBUTE_CHANGE_CONTROLLED): "";
		  if(!changeControlled.equalsIgnoreCase("false")){
			  %>
		        <script language="javascript">
		        if(warningMessageInViewMode == ""){
		        	//XSSOK
		            warningMessageInViewMode = "<%=strContextECOSelection%>";
		        }
		        var mode = "view";
				if(findFrame(getTopWindow(),"PUEUEBOM").editableTable){
					mode=findFrame(getTopWindow(),"PUEUEBOM").editableTable.mode;
				}
					if("view" == mode){
						warningMessageInViewMode = "<%=editInviewMode%>";
	                   
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
			        if(warningMessageInViewMode == ""){
			        	//XSSOK
			            warningMessageInViewMode = "<%=noModifyAccess%>";
			        }
			        </script>

				<%
			  }
		contentURL ="../common/emxFullSearch.jsp?field=TYPES="+sTypePart+":POLICY=policy_ECPart,policy_DevelopmentPart,policy_ConfiguredPart,policy_StandardPart:CURRENT=policy_ECPart.state_Preliminary,policy_ECPart.state_Review,policy_ECPart.state_Approved,policy_ECPart.state_Release,policy_DevelopmentPart.state_Complete,policy_DevelopmentPart.state_PeerReview,policy_DevelopmentPart.state_Create,policy_ConfiguredPart.state_Preliminary&table=ENCAffectedItemSearchResult&showInitialResults=false&submitLabel=emxFramework.Command.Done&hideHeader=true&suiteKey=UnresolvedEBOM&HelpMarker=emxhelpfullsearch&freezePane=Name,Name1&calledMethod="+calledMethod+"&excludeOIDprogram=emxUnresolvedPart:at_excludeRecursiveOIDAddExistingAndTemplate"+"&contextECO="+contextECO+"&objectId="+objectId+"&current="+parentPartState+"&selection=multiple&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&selPartParentOId="+selPartParentOId;
	  }
	  else if(calledMethod.equals("replaceExisting"))
	  {
		if (bAlertReplaceExistingPart) {
			%>
	    		<script language="javascript">
				warningMessage = "<%=sAlertMessageReplaceExisting%>";
	    		</script>
	    	<%
		} else {
			contentURL ="../common/emxFullSearch.jsp?field=TYPES="+sTypePart+":POLICY=policy_ECPart,policy_DevelopmentPart,policy_StandardPart,policy_ConfiguredPart:IS_ASSIGNED_PART=False:CURRENT=policy_ECPart.state_Preliminary,policy_ECPart.state_Review,policy_ECPart.state_Approved,policy_ECPart.state_Release,policy_DevelopmentPart.state_Complete,policy_DevelopmentPart.state_PeerReview,policy_DevelopmentPart.state_Create,policy_ConfiguredPart.state_Preliminary&table=ENCAffectedItemSearchResult&showInitialResults=false&cancelLabel=emxFramework.Command.Cancel&submitLabel=emxFramework.Command.Done&suiteKey=UnresolvedEBOM&HelpMarker=emxhelpfullsearch&excludeOIDprogram=emxUnresolvedPart:at_excludeRecursiveOIDAddExistingAndTemplate&excludeOID="+selPartObjectId+"," + selPartParentOId +"&hideHeader=true&objectId="+objectId+"&selection=multiple&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&selPartParentOId="+selPartParentOId+"&replace=true&submitURL=../unresolvedebom/ReplacePartProcess.jsp?calledMethod="+calledMethod+"&contextECO="+contextECO+"&isWipMode="+isWipMode;
		}
	  }
	  else if(calledMethod.equals("copyFrom") && strPolicyClassification.equalsIgnoreCase("Unresolved"))
	  {
	    contentURL ="../common/emxFullSearch.jsp?field=TYPES=type_Part:POLICY=policy_ConfiguredPart:CURRENT=policy_ConfiguredPart.state_Release&table=PUEUEBOMSearchTopPart&cancelLabel=emxFramework.Command.Cancel&submitLabel=emxFramework.Command.Done&suiteKey=UnresolvedEBOM&HelpMarker=emxhelpfullsearch&excludeOID="+selPartObjectId+"," + selPartParentOId +"&hideHeader=true&objectId="+objectId+"&selection=single&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&selPartParentOId="+selPartParentOId+"&replace=true&submitURL=../unresolvedebom/HiddenProcess.jsp?calledMethod="+calledMethod+"&isWipMode="+isWipMode;
	  }
      else if("addToProduct".equals(calledMethod)) 
      {
        contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_Part:POLICY=policy_ConfiguredPart:CURRENT=policy_ConfiguredPart.state_Preliminary,policy_ConfiguredPart.state_Release:LATESTREVISION=TRUE&table=ENCAffectedItemSearchResult&HelpMarker=emxhelpfullsearch&hideHeader=true&includeOIDprogram=emxUnresolvedPart:includeUnresolvedParts&objectId="+objectId+"&selection=single&submitURL=../unresolvedebom/AddExistingPartProcess.jsp?calledMethod="+calledMethod+"&isWipMode="+isWipMode;
      }
      
      //2012x-Starts
      else if("addToExistingPUEECO".equals(calledMethod)) 
      {
        contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_PUEECO:POLICY=policy_PUEECO:CURRENT=policy_PUEECO.state_Create,policy_PUEECO.state_DefineComponents,policy_PUEECO.state_DesignWork,policy_PUEECO.state_Review&table=PUEECOSearchTable&showInitialResults=false&selection=single&toolbar=UEBOMFullSearchToolbar&freezePane=ActiveECRECO,Name&HelpMarker=emxhelpfullsearch&submitURL=../unresolvedebom/AddExistingPartProcess.jsp?calledMethod="+calledMethod+"&isWipMode="+isWipMode+"&objectId="+objectId;
      }

      else if("createAndassignPUEECO".equals(calledMethod)) 
      {
    	  contentURL    = "../common/emxCreate.jsp?form=type_CreatePUEECO&type=type_PUEECO&policy=policy_PUEECO&typeChooser=true&nameField=autoname&showApply=true&appendURL=ChangeEffectivity|UnresolvedEBOM&CreateMode=CreateECO&suiteKey=UnresolvedEBOM&StringResourceFileId=emxUnresolvedEBOMStringResource&postProcessURL=../unresolvedebom/AddExistingPartProcess.jsp&SuiteDirectory=unresolvedebom&preProcessJavaScript=preProcessInCreatePUEECO&HelpMarker=emxhelpecocreateheader=emxUnresolvedEBOM.Command.Actions.CreatePUEECO";
      } 
	  
      else if("createAndAssignChangeOrder".equals(calledMethod)) 
      {
    	  contentURL = "../common/emxCreate.jsp?form=type_CreateChangeOrderSlidein&header=EnterpriseChangeMgt.Command.CreateChange&type=type_ChangeOrder&nameField=autoname&createJPO=enoECMChangeOrder:createChange&CreateMode=CreateCO&mode=create&typeChooser=true&suiteKey=EnterpriseChangeMgt&SuiteDirectory=enterprisechangemgt&preProcessJavaScript=preProcessInCreateCO&targetLocation=slidein&appendURL=ChangeEffectivity|EnterpriseChangeMgt&StringResourceFileId=emxUnresolvedEBOMStringResource&effectivityRequired=true&postProcessURL=../unresolvedebom/AddExistingPartProcess.jsp?calledMethod=createAndAssignChangeOrder"+"&objectId="+objectId;
      } 
      //2012x--Ends

      if(!strPolicyClassification.equalsIgnoreCase("Unresolved") && !"".equals(strPolicyClassification))
      {
%>
        <script language="javascript">
        if(warningMessage == "" && isReplaceExisting == "false"){
        	//XSSOK
            warningMessage = "<%=alrtMsg%>";
        }
        </script>

<%

      }

   }

%>


<html>
<head>
</head>
<body>
<form name="UEBOMSearch" method="post">
<input type=hidden name="selectedPartsList" value=""/>
<input type=hidden name="CurrenEffectivityActual" value=""/>
<input type=hidden name="CurrentEffectivityDisplay" value=""/>

<script language="javascript">
var frameName = parent.name;
    //Starts --2012x
    if(warningMessage != "")
        {
        alert(warningMessage);
	//XSSOK
        }else if ("addToProduct" == "<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>")
            {
	    //XSSOK
               document.location.href = "<%=XSSUtil.encodeForJavaScript(context,contentURL)%>";
               
               //submits selectedId values in the form of hidden form field values        
              }else if (("addToExistingPUEECO" == "<xss:encodeForJavaScript><%=calledMethod%></xss:encodeForJavaScript>" || 'createAndassignPUEECO' == "<xss:encodeForJavaScript><%=calledMethod%></xss:encodeForJavaScript>") && isWipBomAllowed.toLowerCase()=="true")
	                {
	                selectedParts = selectedParts != ""?selectedParts.substring(0,selectedParts.lastIndexOf('~')):"";
	      		showModalDialog("../common/emxBlank.jsp","570","570","true"); 
		 	var objWindow =  getTopWindow().modalDialog.contentWindow;

	                document.UEBOMSearch.target=objWindow.name;
	                document.UEBOMSearch.selectedPartsList.value=selectedParts;
	                document.UEBOMSearch.action="<%=XSSUtil.encodeForJavaScript(context,contentURL)%>";
	                document.UEBOMSearch.submit();
		             }
              else if("addExisting" == "<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>") {
            	  var cFrame = findFrame(getTopWindow(),"PUEUEBOM");
            	  var tablemode = "";
            	  if(cFrame && cFrame.editableTable && cFrame.editableTable != null && cFrame.editableTable != undefined){
            	  		tablemode = cFrame.editableTable.mode; 
            	  }
            	  else{
            	  	tablemode = "view";
            	  }
            	  if("view"== tablemode && warningMessageInViewMode != ""){
	 	      	        alert(warningMessageInViewMode);
	      			}
	      			else{
						var selPartRowId = '<%=selPartRowId%>';
	 	      			eval(findFrame(getTopWindow(),frameName).FreezePaneregister(selPartRowId,"true"));
	      				var nosRowsselected = "<%=nosRowsselected%>";
	 	      			if(nosRowsselected>1){
	 	      				alert("<%=strMultipleSelection%>");
	 	      			}
	 	      			else{
							contentURL = "<%=contentURL%>"+"&highestFN="+highest+"&submitURL=../unresolvedebom/AddExistingPartProcess.jsp?calledMethod="+calledMethod+"&tablemode="+tablemode+"&selPartRowId="+selPartRowId+"&frameName="+frameName+"&isWipMode="+<%=XSSUtil.encodeForJavaScript(context,isWipMode)%>;
							
			      			if(getTopWindow().getWindowOpener()){
							showModalDialog(contentURL);
			      			}
			      			else{
			      				showWindowShadeDialog(contentURL,true);		      				
			      			}
	 	      			}
	      			}            	  	        	
	        }
    
              else if ('createAndAssignChangeOrder' == "<xss:encodeForJavaScript><%=calledMethod%></xss:encodeForJavaScript>" && isWipBomAllowed.toLowerCase()=="true"){
            	  selectedParts = selectedParts != ""?selectedParts.substring(0,selectedParts.lastIndexOf('~')):"";
            	  //XSSOK
            	  var targetURL = "<%=contentURL%>" + "&selectedPartsList=" + selectedParts + "&targetLocation=slidein";
            	  var currentFrame = this.parent.frameElement.name; 
            	  getTopWindow().showSlideInDialog("../common/emxAEFSubmitSlideInAction.jsp?portalFrame=listHidden&parentFrame="+currentFrame+"&url=" + encodeURIComponent(targetURL), "true");
              }
	                else
	                    {
			    //XSSOK
	                      contentFrame.parent.showModalDialog("<%=XSSUtil.encodeForJavaScript(context,contentURL)%>"+"&highestFN="+highest+"&frameName="+frameName, 575, 575);
	                    }
//2012x-Ends
</script>
</form>
</body>
</html>
              
	      
    
	  

	

