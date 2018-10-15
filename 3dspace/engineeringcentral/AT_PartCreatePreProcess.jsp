<%--  PartCreatePreProcess.jsp - The pre-process jsp for the Part create component used in EBOM "Add New" and "Replace New" functionality.
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file ="emxEngrFramesetUtil.inc"%>

<%@page import="com.matrixone.apps.engineering.EngineeringUtil" %>
<%@page import="com.matrixone.apps.engineering.EngineeringConstants" %>
<%@ page import="java.lang.reflect.*" %>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<%
String objectId             = emxGetParameter(request,"objectId");
String targetLocation       = emxGetParameter(request,"targetLocation");
String SuiteDirectory       = emxGetParameter(request,"SuiteDirectory");
String StringResourceFileId = emxGetParameter(request,"StringResourceFileId");
String suiteKey             = emxGetParameter(request,"suiteKey");
String fromView      		= emxGetParameter(request, "fromView");
String fromMarkupView 		= emxGetParameter(request, "fromMarkupView");
String isFromRMB    		= emxGetParameter(request, "isFromRMB");
String ATTypeToCreate    		= emxGetParameter(request, "ATTypeToCreate");

// MGS Custo Start
String MGStype   		= emxGetParameter(request, "MGStype");
String MGSrel    		= emxGetParameter(request, "MGSrel");
//MGS Custo End
String contentURL           = "";
String partNotInEditMode = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Command.EditingPartsInViewMode");
String noModifyAccess = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.DragDrop.Message.NoModifyAccess");
String editInviewMode = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.Command.editPartsInViewMode");
String editUnConfigfromConfig = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.CommonView.Alert.Invalidselection");
String strMultipleSelection        = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Common.PleaseSelectOneItemOnly");
String sCreateMode           = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"CreateMode"));
String multiPartCreation           = emxGetParameter(request,"multiPartCreation");
String language  = request.getHeader("Accept-Language");
String bomRelId         = "";
String bomObjectId      = "";
String bomParentOID     = "";
//2012x
String isWipBomAllowed;String isWipMode = "false";
String contextECO="";String strContextECOSelection;String selectedPartState;
boolean isECCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionEngineeringConfigurationCentral",false,null,null);
String sRowId = "";
String strVPLMControlled = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
		context.getLocale(),"emxEngineeringCentral.Command.ReplaceNotPossibleForVPLMControlled");
%>
<script language="Javascript">
var msgflag = false;
var highest = 0;
</script>
<%
if ("fromPartFamily".equals(sCreateMode)) {    
    String strPFNameGenerator = "FALSE";
    String strPFDefaultPart = PropertyUtil.getSchemaProperty(context,"type_Part");
    
    if (objectId != null && !"".equals(objectId)) {
        String SELECT_DEFAULT_PART_TYPE = "attribute[" + PropertyUtil.getSchemaProperty(context,"attribute_DefaultPartType") + "]";
        String SELECT_PART_FAMILY_NAME_GENERATOR = "attribute[" + PropertyUtil.getSchemaProperty(context,"attribute_PartFamilyNameGeneratorOn") + "]";
        
        StringList objectSelect = new StringList(2);
        objectSelect.add(SELECT_DEFAULT_PART_TYPE);
        objectSelect.add(SELECT_PART_FAMILY_NAME_GENERATOR);
        
        DomainObject domObj = DomainObject.newInstance(context, objectId);
                    
        Map dataMap = domObj.getInfo(context, objectSelect);
        strPFNameGenerator = (String) dataMap.get(SELECT_PART_FAMILY_NAME_GENERATOR);
        strPFDefaultPart = PropertyUtil.getSchemaProperty(context,(String) dataMap.get(SELECT_DEFAULT_PART_TYPE));          
    }

	if ("type_AT_C_COS".equals(ATTypeToCreate)){
	    contentURL = "../common/emxCreate.jsp?nameField=autoname&policy=policy_ECPart&form=type_CreatePartATCCOS&showPolicy=false&formFieldsOnly=true&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_AT_C_COS&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=refreshCaller&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&createMode=LIB&createJPO=emxPart:createPartJPO&preProcessJavaScript=preProcessCreatePartInFamily&HelpMarker=emxhelppartcreate&objectId=" + objectId + "&PFNameGen=" + strPFNameGenerator + "&defaultPFPart=" + strPFDefaultPart + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_COS&ExclusionList=type_ManufacturingPart,type_ShopperProduct,type_Part";
	} else if ("type_AT_C_DESIGN_PART".equals(ATTypeToCreate)){
	    contentURL = "../common/emxCreate.jsp?nameField=autoname&policy=policy_ECPart&form=type_CreatePartATDesignPart&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_AT_C_DESIGN_PART&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=refreshCaller&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&createMode=LIB&createJPO=emxPart:createPartJPO&preProcessJavaScript=preProcessCreatePartInFamily&HelpMarker=emxhelppartcreate&objectId=" + objectId + "&PFNameGen=" + strPFNameGenerator + "&defaultPFPart=" + strPFDefaultPart + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_DESIGN_PART&ExclusionList=type_ManufacturingPart,type_ShopperProduct,type_Part&showPolicy=false&formFieldsOnly=true";
	} else if ("type_AT_C_CONFIGURATION_ITEM".equals(ATTypeToCreate)){
	    contentURL = "../common/emxCreate.jsp?nameField=autoname&policy=policy_ConfiguredPart&form=type_CreateConfiguredItem&formFieldsOnly=true&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_AT_C_CONFIGURATION_ITEM&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=refreshCaller&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&createMode=LIB&createJPO=emxPart:createPartJPO&preProcessJavaScript=preProcessCreatePartInFamily&HelpMarker=emxhelppartcreate&objectId=" + objectId + "&PFNameGen=" + strPFNameGenerator + "&defaultPFPart=" + strPFDefaultPart + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_CONFIGURATION_ITEM&ExclusionList=type_ManufacturingPart,type_ShopperProduct,type_Part&policy=policy_Configured_Part&showPolicy=false";
	} else if ("type_AT_C_EXPECTED_PRODUCT".equals(ATTypeToCreate)){
	    contentURL = "../common/emxCreate.jsp?nameField=autoname&policy=policy_ConfiguredPart&form=type_CreateExpectedProduct&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_AT_C_EXPECTED_PRODUCT&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=refreshCaller&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&createMode=LIB&createJPO=emxPart:createPartJPO&preProcessJavaScript=preProcessCreatePartInFamily&HelpMarker=emxhelppartcreate&objectId=" + objectId + "&PFNameGen=" + strPFNameGenerator + "&defaultPFPart=" + strPFDefaultPart + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_EXPECTED_PRODUCT&ExclusionList=type_ManufacturingPart,type_ShopperProduct,type_Part";
	} else if ("type_AT_C_LOGICAL_NODE".equals(ATTypeToCreate)){
	    contentURL = "../common/emxCreate.jsp?nameField=autoname&policy=policy_ConfiguredPart&form=type_CreateATLogicalNode&showPolicy=false&formFieldsOnly=true&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_AT_C_LOGICAL_NODE&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=refreshCaller&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&createMode=LIB&createJPO=emxPart:createPartJPO&preProcessJavaScript=preProcessCreatePartInFamily&HelpMarker=emxhelppartcreate&objectId=" + objectId + "&PFNameGen=" + strPFNameGenerator + "&defaultPFPart=" + strPFDefaultPart + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_LOGICAL_NODE&ExclusionList=type_ManufacturingPart,type_ShopperProduct,type_Part";
	} else {
	    contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreateATCPart&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_AT_C_Part&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=refreshCaller&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&createMode=LIB&createJPO=emxPart:createPartJPO&preProcessJavaScript=preProcessCreatePartInFamily&HelpMarker=emxhelppartcreate&objectId=" + objectId + "&PFNameGen=" + strPFNameGenerator + "&defaultPFPart=" + strPFDefaultPart + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct";
	}

} 
else {

    if (null != objectId && objectId.length() > 0) {
	
	  String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
	  if(tableRowIdList == null){
		  tableRowIdList = new String[1];
		  tableRowIdList[0] = "|"+objectId+"||0";
	  }
	  int nosRowsselected = 0;
	  if(tableRowIdList == null){
	  	nosRowsselected = 0;
	  }
	  else{
	  	nosRowsselected = tableRowIdList.length;
	  }
	  if (null != tableRowIdList) {
	  
		  boolean rootNodeFail = false;
	      //process - relId|objectId|parentId|rowId - using the tableRowId
	      String tableRowId = " "+tableRowIdList[0];
	      StringList slList = FrameworkUtil.split(tableRowId, "|");
	      
	      bomRelId       = ((String)slList.get(0)).trim();
	      bomObjectId    = ((String)slList.get(1)).trim();
	      bomParentOID   = ((String)slList.get(2)).trim();
	      sRowId  = ((String)slList.get(3)).trim();
	      
	          selectedPartState      = (String)(DomainObject.newInstance(context,bomObjectId)).getInfo(context, com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
	          String parentPartState;
			  String selectedPartPolicy = (String)(DomainObject.newInstance(context,bomObjectId)).getInfo(context, com.matrixone.apps.domain.DomainConstants.SELECT_POLICY);
			  
	          if (!"".equalsIgnoreCase(bomParentOID) && UIUtil.isNotNullAndNotEmpty(bomParentOID)) {
	        	  parentPartState  = (String)(DomainObject.newInstance(context,bomParentOID)).getInfo(context, com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
	          }else {
	        	  parentPartState  = selectedPartState;
	          }
              if (!DomainObject.STATE_PART_PRELIMINARY.equalsIgnoreCase(selectedPartState) && !EngineeringConstants.POLICY_CONFIGURED_PART.equalsIgnoreCase(selectedPartPolicy)) {
%>
					<script language="Javascript">
										//XSSOK
								var mode = "";
								var frameName = "ENCBOM";
								frameName = (findFrame(getTopWindow(),"ENCBOM") !=null) ? "ENCBOM" : "content";
								if(findFrame(getTopWindow(),frameName).editableTable){
									mode=findFrame(getTopWindow(),frameName).editableTable.mode;
								}
								if("view" == mode && "EBOMReplaceNew"!='<%=sCreateMode%>'){
									alert('<%=partNotInEditMode%>');
									getTopWindow().window.closeSlideInPanel();
								}
										
					  </script>
            	  <%
				}         
              HashMap paramMap = new HashMap();
          	 paramMap.put("objectId", bomObjectId);
          	 String[] methodargs = JPO.packArgs(paramMap);
          	 boolean status =  JPO.invoke(context, "emxENCActionLinkAccess", null, "isApplyAllowed", methodargs,Boolean.class);
          	 
               if (!status) {
             	  %>
             	  <script language="Javascript">
             	                    //XSSOK
 						 	var mode = "";
 						 	var encTargetFrame =  findFrame(getTopWindow(),"MGS_ENCBOM");
 							var	 targetFrame = encTargetFrame ?  encTargetFrame :  findFrame(getTopWindow(),"ENCBOM");
							targetFrame = encTargetFrame ?  encTargetFrame :  findFrame(getTopWindow(),"PUEUEBOM");
							targetFrame = targetFrame ?  targetFrame :  findFrame(getTopWindow(),"content");
 							if(targetFrame){
 								mode=targetFrame.editableTable.mode;
 							}
 								if("view" == mode && "EBOMReplaceNew"!='<%=sCreateMode%>'){
             	                    alert('<%=noModifyAccess%>');
             	                    getTopWindow().window.closeSlideInPanel();
 								}
             	                    
             	                    </script>
             	  <%
 				}  
                %>
        	  <script language="Javascript">
        	    //XSSOK
				var nosRowsselected = "<%=nosRowsselected%>";
				if(nosRowsselected>1){
					alert("<%=strMultipleSelection%>");
					getTopWindow().window.closeSlideInPanel();
				}
			  </script>
     	     <%
			if (isECCInstalled) {
			  String POLICY_CONFIGURED_PART = PropertyUtil.getSchemaProperty(context,"policy_ConfiguredPart");
			  String STATEPRELIMINARY = PropertyUtil.getSchemaProperty(context,"policy",POLICY_CONFIGURED_PART, "state_Preliminary");
			  String STATESUPERSEDED     = PropertyUtil.getSchemaProperty(context,"policy",POLICY_CONFIGURED_PART, "state_Superseded");
			  //String supersededPartAlert = i18nNow.getI18nString("emxUnresolvedEBOM.Alert.SupersededPart","emxUnresolvedEBOMStringResource", language);
			  String supersededPartAlert = EnoviaResourceBundle.getProperty(context ,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.Alert.SupersededPart");
			  isWipBomAllowed = FrameworkProperties.getProperty(context, "emxUnresolvedEBOM.WIPBOM.Allowed");
			  contextECO      = emxGetParameter(request,"PUEUEBOMContextChangeFilter_actualValue");
			  contextECO      = (contextECO == null || "null".equalsIgnoreCase(contextECO))?"":contextECO;
			  
			  //strContextECOSelection = i18nNow.getI18nString("emxUnresolvedEBOM.CommonView.Alert.ContextECOSelection","emxUnresolvedEBOMStringResource", language);
			  strContextECOSelection = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.CommonView.Alert.ContextECOSelection");
              
			  String releaseProcess = DomainObject.newInstance(context, UIUtil.isNullOrEmpty(bomParentOID) ? bomObjectId : bomParentOID).getInfo(context, EngineeringConstants.ATTRIBUTE_RELEASE_PHASE_VALUE);
              isWipBomAllowed = Boolean.toString(EngineeringConstants.DEVELOPMENT.equals(releaseProcess));
	          
			  if (STATESUPERSEDED.equalsIgnoreCase(parentPartState)) {
			  %>
								<script language="Javascript">
								//XSSOK
								alert("<%=supersededPartAlert%>");
								getTopWindow().window.closeSlideInPanel();
								</script>
			  <%
							 } 
	          if (("true".equalsIgnoreCase(isWipBomAllowed)) && STATEPRELIMINARY.equalsIgnoreCase(selectedPartState)) {
	              isWipMode = "true";
	          }
              //if parent part state is preliminary and development mode setting is true then only wip mode will be true.
              if ("true".equalsIgnoreCase(isWipBomAllowed)) {
                  if ("UEBOMReplaceNew".equalsIgnoreCase(sCreateMode) && STATEPRELIMINARY.equalsIgnoreCase(parentPartState)) {
                       isWipMode = "true";
                  }
                  if (("UEBOMAddNew".equalsIgnoreCase(sCreateMode))) {
                      
                	  String objectIdpolicy = (  bomObjectId == null || "".equals(bomObjectId ) ) ? bomParentOID : bomObjectId;
              		boolean isConfiguredPart = isConfiguredPart(context, objectIdpolicy);
              		
              		if (!isConfiguredPart) {
              		%>
              		  <script language = "javascript">
              		var mode = "";
    					if(findFrame(getTopWindow(),"PUEUEBOM").editableTable){
    						mode=findFrame(getTopWindow(),"PUEUEBOM").editableTable.mode;
    					}
    						if("edit" != mode){
     	                    alert('<%=editUnConfigfromConfig%>');
     	                    getTopWindow().window.closeSlideInPanel();
							}	
              		  </script>
              		<%				
              			 }
                  String objectIdToBeValidated = (  bomObjectId == null || "".equals(bomObjectId ) ) ? bomParentOID : bomObjectId;
                        
                        boolean changeControlled = isChangeControlled(context, objectIdToBeValidated);
               
                        if ( changeControlled ) {
                      	  %>
                         	  <script language="Javascript">
                         	                    //XSSOK
              						 	var mode = "";
              							if(findFrame(getTopWindow(),"PUEUEBOM").editableTable){
              								mode=findFrame(getTopWindow(),"PUEUEBOM").editableTable.mode;
              							}
              								if("edit" != mode){
                         	                    alert('<%=editInviewMode%>');
                         	                    getTopWindow().window.closeSlideInPanel();
              								}
                         	                    
                         	                    </script>
                         	  <%
              	   	 }
                        if("true".equalsIgnoreCase(isWipBomAllowed) && STATEPRELIMINARY.equalsIgnoreCase(selectedPartState)){
                        	isWipMode = "true";
                        }
                  }
              }

	          //Starts for 2012x--force check for released parts to follow change proces incase of replace new/Add new 
	          if("".equals(contextECO) && "false".equalsIgnoreCase(isWipMode) && ("UEBOMAddNew".equalsIgnoreCase(sCreateMode) || "UEBOMReplaceNew".equalsIgnoreCase(sCreateMode))) 
	          {
%>
	          <script language = "javascript">
	          //XSSOK
	          alert("<%=strContextECOSelection%>");
	          getTopWindow().window.closeSlideInPanel();
	            </script>
				<%
		  }
	    }
	 //2012x

	     //IR-083774V6R2012 start
	     boolean boolMBOMInstalled     = EngineeringUtil.isMBOMInstalled(context);
	     String  sSymbolicRelESQName   = FrameworkUtil.getAliasForAdmin(context,"relationship",EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY,true);
	     /*String strWarningAddNewMsg    = i18nNow.getI18nString("emxEngineeringCentral.BOM.AddNewOnDeleted","emxEngineeringCentralStringResource",language);
	     String strWarningANEBOMSQMsg  = i18nNow.getI18nString("emxMBOM.BOM.AddNewOnSplitQuantity","emxMBOMStringResource",language);
         String strWarningREDeleteMsg  = i18nNow.getI18nString("emxEngineeringCentral.BOM.ReplaceWithNewOnAddedDeleted","emxEngineeringCentralStringResource",language);
         String strInvalidSelectionMsg = i18nNow.getI18nString("emxEngineeringCentral.CommonView.Alert.Invalidselection","emxEngineeringCentralStringResource",language);
         String strReplaceErrorMessage = i18nNow.getI18nString("emxEngineeringCentral.BOM.ReplacewithNewFail","emxEngineeringCentralStringResource",language);
        */
        String strWarningAddNewMsg    = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.BOM.AddNewOnDeleted");
	     String strWarningANEBOMSQMsg  = EnoviaResourceBundle.getProperty(context ,"emxMBOMStringResource",context.getLocale(),"emxMBOM.BOM.AddNewOnSplitQuantity");
        String strWarningREDeleteMsg  = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.BOM.ReplaceWithNewOnAddedDeleted");
        String strInvalidSelectionMsg = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.CommonView.Alert.Invalidselection");
        String strReplaceErrorMessage = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.BOM.ReplacewithNewFail");
       
         String sSymbolicRelEBOMName   = FrameworkUtil.getAliasForAdmin(context,"relationship",DomainConstants.RELATIONSHIP_EBOM,true);
         String EBOMPending = PropertyUtil.getSchemaProperty(context, "relationship_EBOMPending");
         String EBOMSubstitute = PropertyUtil.getSchemaProperty(context, "relationship_EBOMSubstitute");
         
         if (EBOMPending == null)
         	EBOMPending="";

	 	  if("EBOMReplaceNew".equalsIgnoreCase(sCreateMode) || "UEBOMReplaceNew".equalsIgnoreCase(sCreateMode)) {
	      {
			  String isVPLMControlled = "";
	    	  if(UIUtil.isNotNullAndNotEmpty(bomParentOID)){
	    		  isVPLMControlled = DomainObject.newInstance(context, bomParentOID).getInfo(context, "from["+EngineeringConstants.RELATIONSHIP_PART_SPECIFICATION+"].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");
	    		  if("TRUE".equalsIgnoreCase(isVPLMControlled))
	  			{
	  				%>
	  		          <script>
	  		        var mode = "";
					if(getTopWindow() && getTopWindow().getWindowOpener()){
						mode=getTopWindow().getWindowOpener().editableTable.mode;
					}
					if("view" == mode){
	  		    	      alert("<%=strVPLMControlled%>");
	  		    	      getTopWindow().closeWindow();
					}
	  		          </script>
	  		       <%	
	  			 }
	    	  }
	    	   %>
	        	  <script language="Javascript">
	        	                    //XSSOK
	            var nosRowsselected = "<%=nosRowsselected%>";
	   			if(nosRowsselected>1){
	   				alert("<%=strMultipleSelection%>");
	   				getTopWindow().closeWindow();
	   			}
	   		 </script>
	     	 <%
	     	if (!DomainObject.STATE_PART_PRELIMINARY.equalsIgnoreCase(parentPartState)) {
				%>
				<script language="Javascript">
								//XSSOK
						var mode = "";
						if(getTopWindow() && getTopWindow().getWindowOpener()){
							mode=getTopWindow().getWindowOpener().editableTable.mode;
						}
						if("view" == mode){
							alert('<%=partNotInEditMode%>');
						   getTopWindow().closeWindow();
						}    
									
				  </script>
				  <%
			}         
			 HashMap paramMap1 = new HashMap();
			 if ( bomParentOID == null || "".equals(bomParentOID) ) {
			 	paramMap1.put("objectId", bomObjectId);
			 } else {
				 paramMap1.put("objectId", bomParentOID);
			 }
			 String[] methodargs1 = JPO.packArgs(paramMap1);
			 boolean status1 =  JPO.invoke(context, "emxENCActionLinkAccess", null, "isApplyAllowed", methodargs1,Boolean.class);
			 
			  if (!status1) {
				  %>
				  <script language="Javascript">
									//XSSOK
					var mode = "";
					var sCreateMode = '<%=sCreateMode%>';
					if(getTopWindow() && getTopWindow().getWindowOpener()){
						mode=getTopWindow().getWindowOpener().editableTable.mode;
					}
					if("view" == mode){
						alert('<%=noModifyAccess%>');
						getTopWindow().closeWindow();
					}          
			 </script>
			 <%
			} 
			  
			  
			  boolean isIntersectEffectivityForReplace = true;
	          if(sRowId.equals("0")) {
                  //String strRootNodeErrorMsgForReplaceNew = i18nNow.getI18nString("emxEngineeringCentral.BOM.ReplaceNewRootNodeError","emxEngineeringCentralStringResource",language);
                  String strRootNodeErrorMsgForReplaceNew = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.BOM.ReplaceNewRootNodeError");
		        	 %>
						<script language="Javascript">
						alert("<%=strRootNodeErrorMsgForReplaceNew%>");			
					    getTopWindow().closeWindow();
						</script>
					<%	
				 }
              //checking for the same pending change or not.
              if (sRowId!= null && !(sRowId.equals("0")) && isECCInstalled && "false".equalsIgnoreCase(isWipMode) && "UEBOMReplaceNew".equalsIgnoreCase(sCreateMode)) 
              {
              
              /*String strCyclicDependency  = i18nNow.getI18nString("emxUnresolvedEBOM.CommonView.Alert.Cyclicdependency","emxUnresolvedEBOMStringResource", language);
              String strWarningReplaceExistingMsgForEdit  = i18nNow.getI18nString("emxUnresolvedEBOM.Edit.checkOnPendingChange","emxUnresolvedEBOMStringResource",language);
              String strWarningMSGForIntersectEffectivity = i18nNow.getI18nString("emxUnresolvedEBOM.Edit.EffectivityMatch","emxUnresolvedEBOMStringResource",language);
              */
              String strCyclicDependency  = EnoviaResourceBundle.getProperty(context ,"emxUnresolvedEBOMStringResource", context.getLocale(),"emxUnresolvedEBOM.CommonView.Alert.Cyclicdependency");
              String strWarningReplaceExistingMsgForEdit  = EnoviaResourceBundle.getProperty(context ,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.Edit.checkOnPendingChange");
              String strWarningMSGForIntersectEffectivity = EnoviaResourceBundle.getProperty(context ,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.Edit.EffectivityMatch");
              
              Class c = Class.forName("com.matrixone.apps.unresolvedebom.UnresolvedPart");
              Object unresolvedPart = c.newInstance();
              // parameters depending on the bean method
              Class[] inputType = new Class[3];
              inputType[0]  = matrix.db.Context.class;
              inputType[1]  = String.class;
              inputType[2]  = String.class;
              Method method = c.getMethod("checkForCyclicPrerequisite", inputType);
              boolean cyclicDependency = (Boolean)method.invoke(unresolvedPart,new Object[]{context, bomRelId,contextECO});
              
                      try { 
                          Class c1 = Class.forName("com.matrixone.apps.unresolvedebom.PUEChange");
                          Object EFF = c1.newInstance();
                          // parameters depending on the bean method
                          Class[] inputType1 = new Class[3];
                          inputType1[0]  = matrix.db.Context.class;
                          inputType1[1]  = String.class;
                          inputType1[2]  = String.class;
                          Method method1 = c1.getMethod("isIntersectEffectivity", inputType1);
                          isIntersectEffectivityForReplace = (Boolean)method1.invoke(EFF,new Object[]{context, contextECO,bomRelId});                          
                          }  
                          catch (Exception e) 
                          {
                              isIntersectEffectivityForReplace = false;
                          }
%>
                 <script language="Javascript">
                 //XSSOK
                 if(<%=cyclicDependency%> == true) {
                	 //XSSOK
                     alert("<%=strCyclicDependency%>");         
                     getTopWindow().closeWindow();
                 }
                 //XSSOK
                  if(<%=isIntersectEffectivityForReplace%> == false) {
                	  //XSSOK
                     alert("<%=strWarningMSGForIntersectEffectivity%>");         
                     getTopWindow().closeWindow();
                   }
                   </script>
<%

              }
	      }      
%>
             
                 <script language="Javascript">
                 
	            try {
					var isFROMRMB = "<%=XSSUtil.encodeForJavaScript(context,isFromRMB)%>";
					var rmbRowId  = "<%=sRowId%>";
					var xPath     =  isFROMRMB == "true" ?  "/mxRoot/rows//r[@id='"+rmbRowId+"']" : "/mxRoot/rows//r[@checked='checked']";	            	
	            	
	                //var aCopiedRowsChecked = getTopWindow().parent.getWindowOpener().emxUICore.selectSingleNode(getTopWindow().parent.getWindowOpener().oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
	                var aCopiedRowsChecked = getTopWindow().parent.getWindowOpener().emxUICore.selectSingleNode(getTopWindow().parent.getWindowOpener().oXML.documentElement, xPath);
	                var status = aCopiedRowsChecked.getAttribute("status");
	              //XSSOK
	                if("<%=boolMBOMInstalled%>" == "true"){
	                 var rel = aCopiedRowsChecked.getAttribute("rel");
	                 if(rel == null){
	                    rel = aCopiedRowsChecked.getAttribute("relType");
	                }

	                if(rel){
	                    var arrRel = rel.split("|");
	                    //XSSOK
	                    if(arrRel[0] != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && arrRel[0] != "<%=sSymbolicRelEBOMName%>" && arrRel[0] != "<%=EBOMPending%>" && arrRel[0] != "relationship_EBOMPending"){
	                    	//XSSOK
	                        alert("<%=strInvalidSelectionMsg%>");
	                        msgflag = true;
	                        getTopWindow().closeWindow();
	                    }
	                    else if(status == 'add' || status == 'cut'){
	                    	msgflag = true;
	                    	//XSSOK
	                        alert("<%=strWarningREDeleteMsg%>");
	                        getTopWindow().closeWindow();
	                    }
	                }
	                else if(status == 'add' || status == 'cut'){
	                	//XSSOK
	                    alert("<%=strWarningREDeleteMsg%>");
	                    getTopWindow().closeWindow();
	                }
					}
					else{
						if(status == 'add' || status == 'cut'){
							msgflag = true;
							//XSSOK
		                    alert("<%=strWarningREDeleteMsg%>");
		                    getTopWindow().closeWindow();
	                }
					}
	            }
	            catch(e){
	            	//XSSOK
	                alert("<%=strReplaceErrorMessage%>"+e.message);
	                getTopWindow().closeWindow();
	            }
			        </script>
<%
	      }
	     
		      %>
          <script language="javascript">
          
          var targetFrame ="";
          var fromMarkupView = "<%=fromMarkupView%>";

          if("<%=fromView%>"=="MBOMCommon") {
         	 targetFrame = findFrame(getTopWindow(),"MBOMCommon");
          }	 
          else if(fromMarkupView == "true") {
        	  targetFrame = parent.getWindowOpener();
          } 	  
          else{
        	 var encTargetFrame =  findFrame(getTopWindow(),"MGS_ENCBOM");
           	 targetFrame = encTargetFrame ?  encTargetFrame :  findFrame(getTopWindow(),"ENCBOM");
			 targetFrame = encTargetFrame ?  encTargetFrame :  findFrame(getTopWindow(),"PUEUEBOM");
           	 targetFrame = targetFrame ?  targetFrame :  findFrame(getTopWindow(),"content");
	       }
          
			var isFROMRMB1 = "<%=XSSUtil.encodeForJavaScript(context,isFromRMB)%>";
			var rmbRowId1  = "<%=sRowId%>";
			var xPath1     =  isFROMRMB1 == "true" ?  "/mxRoot/rows//r[@id='"+rmbRowId1+"']" : "/mxRoot/rows//r[@checked='checked']";	            	

          
            //var aCopiedRowsChecked = targetFrame.emxUICore.selectSingleNode(targetFrame.oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
            var aCopiedRowsChecked = targetFrame.emxUICore.selectSingleNode(targetFrame.oXML.documentElement, xPath1);
		    var status = aCopiedRowsChecked.getAttribute("status");
		    var findNumberIndex = targetFrame.colMap.getColumnByName("Find Number").index;
		    var checkedRows = emxUICore.selectNodes(targetFrame.oXML.documentElement, xPath1); 
		    //var findNumberList = emxUICore.selectNodes(targetFrame.oXML.documentElement, "/mxRoot/rows//r[@checked='checked']/r/c["+findNumberIndex+"]/text()"); 
		    var findNumberList = emxUICore.selectNodes(targetFrame.oXML.documentElement, xPath1+"/r/c["+findNumberIndex+"]/text()");
		    if(checkedRows.length == 0  || rmbRowId1 == "0"){
		    	xPath1 = "/mxRoot/rows//r[@id='0']";
		    	findNumberList = emxUICore.selectNodes(targetFrame.oXML.documentElement, xPath1+"/r/c["+findNumberIndex+"]/text()");
		    }
		    for(j=0;j<findNumberList.length;j++){
		    	if (findNumberList[j].nodeValue != "") {
		     	var intNodeValue = parseInt(findNumberList[j].nodeValue);
		     	if(j==0)
		     		highest = intNodeValue;
		     	else if (highest<intNodeValue)
		     		highest = intNodeValue;    	
		    	}
		     }
		 	
		  //XSSOK
                if("<%=boolMBOMInstalled%>" == "true"){
                var rel = aCopiedRowsChecked.getAttribute("rel");
                if(rel == null){
                    rel = aCopiedRowsChecked.getAttribute("relType");
                }
                if(rel && msgflag == false){
                    var arrRel = rel.split("|");
                  //XSSOK
                    if(arrRel[0] == "<%=EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY%>" || arrRel[0] == "<%=sSymbolicRelESQName%>"){
                    	//XSSOK
                        alert("<%=strWarningANEBOMSQMsg%>");
                        //getTopWindow().closeWindow();
                        fromMarkupView == "true" ? getTopWindow().closeWindow() : getTopWindow().closeSlideInDialog();
                    }
                  //XSSOK
                    else if(status == 'cut' && (arrRel[0] == "<%=DomainConstants.RELATIONSHIP_EBOM%>" || arrRel[0] == "<%=DomainConstants.RELATIONSHIP_ALTERNATE%>" || arrRel[0] == "relationship_EBOMSubstitute" || arrRel[0] == "<%=EBOMSubstitute%>" || arrRel[0] == "<%=sSymbolicRelEBOMName%>" || arrRel[0] == "<%=EBOMPending%>" || arrRel[0] == "relationship_EBOMPending") ){
                    	//XSSOK
                        alert("<%=strWarningAddNewMsg%>");
                        //getTopWindow().window.closeSlideInPanel();
                        fromMarkupView == "true" ? getTopWindow().closeWindow() : getTopWindow().closeSlideInDialog();
                    }
                }
              //XSSOK
             }else if ("<%=isECCInstalled%>" && "<xss:encodeForJavaScript><%=sCreateMode%></xss:encodeForJavaScript>" == 'UEBOMAddNew') {
		           	 if (status == 'cut' || status == 'add') {
		           		 //XSSOK
		                    alert("<%=strWarningAddNewMsg%>");
		                    getTopWindow().window.closeSlideInPanel();
	
		                }
             }
                else{
	                if(status == 'cut' && msgflag == false){
	                	 //XSSOK
	                    alert("<%=strWarningAddNewMsg%>");
	                    //getTopWindow().window.closeSlideInPanel();
	                    fromMarkupView == "true" ? getTopWindow().closeWindow() : getTopWindow().closeSlideInDialog();
	                }
				}
		      
          </script>
       <%   
       DomainObject domObj = DomainObject.newInstance(context, bomObjectId);
       String strGeneric = (String)domObj.getInfo(context, "attribute[AT_C_Generic]");
       
              if(sCreateMode.equals("EBOMReplaceNew") || sCreateMode.equals("UEBOMReplaceNew")){	    	    
            	  contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreateATCPart&header=emxEngineeringCentral.Replace.ReplaceWithNew&type=type_AT_C_Part&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&createMode="+sCreateMode+"&contextECO="+contextECO+"&isWipMode="+isWipMode+"&createJPO=emxPart:createPartJPO&HelpMarker=emxhelppartcreate&targetLocation=replace&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&typeChooser=true&InclusionList=type_AT_C_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct";
	      }else if (sCreateMode.equals("EBOM") || sCreateMode.equals("UEBOMAddNew")) {
	    	  //contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&submitAction=doNothing&header=emxEngineeringCentral.InsertNew.Part&type=type_Part&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+contextECO+"&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+isWipMode + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct&fromMarkupView="+fromMarkupView;
			  if ("type_AT_C_COS".equals(ATTypeToCreate)){
	    		  contentURL = "../common/emxCreate.jsp?nameField=autoname&policy=policy_ECPart&form=type_CreatePartATCCOS&submitAction=doNothing&header=emxEngineeringCentral.InsertNew.Part&type=type_AT_C_COS&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+contextECO+"&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+isWipMode + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_COS&ExclusionList=type_ManufacturingPart,type_ShopperProduct&fromMarkupView="+fromMarkupView;  
	    		} else if ("type_AT_C_DESIGN_PART".equals(ATTypeToCreate)){
	    			contentURL = "../common/emxCreate.jsp?nameField=autoname&policy=policy_ECPart&form=type_CreatePartATDesignPart&submitAction=doNothing&header=emxEngineeringCentral.InsertNew.Part&type=type_AT_C_DESIGN_PART&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+contextECO+"&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+isWipMode + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_DESIGN_PART&ExclusionList=type_ManufacturingPart,type_ShopperProduct&formFieldsOnly=true&fromMarkupView="+fromMarkupView;	    		    
	    		} else if ("type_AT_C_CONFIGURATION_ITEM".equals(ATTypeToCreate)){
	    			contentURL = "../common/emxCreate.jsp?nameField=autoname&policy=policy_ConfiguredPart&form=type_CreateConfiguredItem&formFieldsOnly=true&submitAction=doNothing&header=emxEngineeringCentral.InsertNew.Part&type=type_AT_C_CONFIGURATION_ITEM&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+contextECO+"&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+isWipMode + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_CONFIGURATION_ITEM&ExclusionList=type_ManufacturingPart,type_ShopperProduct&fromMarkupView="+fromMarkupView;	    
	    		} else if ("type_AT_C_EXPECTED_PRODUCT".equals(ATTypeToCreate)){
	    			if(!"TRUE".equals(strGeneric)){
		    			contentURL = "../common/emxCreate.jsp?nameField=autoname&policy=policy_ConfiguredPart&form=type_CreateExpectedProduct&showPolicy=false&formFieldsOnly=true&submitAction=doNothing&header=emxEngineeringCentral.InsertNew.Part&type=type_AT_C_EXPECTED_PRODUCT&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+contextECO+"&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+isWipMode + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_EXPECTED_PRODUCT&ExclusionList=type_ManufacturingPart,type_ShopperProduct&fromMarkupView="+fromMarkupView;
	    			}else{
	    				%>
	    		          <script language="javascript">
	    		          alert("Can not create a Configuration Item under a template");
	    		          top.getTopWindow().closeSlideInDialog();
	    		          </script>
	    		         <%
	    			}
	    		} else if ("type_AT_C_LOGICAL_NODE".equals(ATTypeToCreate)){
	    			contentURL = "../common/emxCreate.jsp?nameField=autoname&policy=policy_ConfiguredPart&form=type_CreateATLogicalNode&formFieldsOnly=true&showPolicy=false&submitAction=doNothing&header=emxEngineeringCentral.InsertNew.Part&type=type_AT_C_LOGICAL_NODE&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+contextECO+"&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+isWipMode + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_LOGICAL_NODE&ExclusionList=type_ManufacturingPart,type_ShopperProduct&fromMarkupView="+fromMarkupView;
	    		} else {
	    			contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreateATCPart&submitAction=doNothing&header=emxEngineeringCentral.InsertNew.Part&type=type_AT_C_Part&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+contextECO+"&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+isWipMode + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_AT_C_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct&fromMarkupView="+fromMarkupView;
	    		}
	    	  if(EngineeringUtil.isMBOMInstalled(context)){
	    		  
	    		  contentURL = contentURL+"&fromView="+fromView;
	    	  }
// MGS Custo Start
          } else if (sCreateMode.equals("MGS_EBOM")) {
	    	  contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&submitAction=doNothing&header=emxEngineeringCentral.PartCreate.FormHeader&type=" + MGStype + "&relationship=" + MGSrel + "&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+contextECO+"&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+isWipMode + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_MGS_Node&MGSrel=" + MGSrel + "&ExclusionList=type_ManufacturingPart,type_ShopperProduct&fromMarkupView="+fromMarkupView;
	    	  if(EngineeringUtil.isMBOMInstalled(context)){
	    		  
	    		  contentURL = contentURL+"&fromView="+fromView;
	    	  }
			  // MGS Custo End 
          }else if(sCreateMode.equals("MFG")){
 
        	  boolean bIsCurrent = false;
        	  boolean isPlantMember = false;
        	  
        	  String tmpId = "";
        	  String mqlQuery = "";
        	  String strErrMsg = "";
        	  String strPlantId = "";
        	  String strBOMView = "";
        	  String attrPlantID = "";
        	  String strContextMCO = "";
        	  String strMBOMStatusQuery = "";
        	  String selectedParentMBOMStatus = "";
        	  String strContextMCOSelectionMSG = "";
        	  
        	  StringList assignedPlantList = null;
        	  
        	  try{	        	 
        		  strBOMView = emxGetParameter(request,"MFGMBOMViewCustomFilter"); 
	        	  strPlantId = emxGetParameter(request,"MFGMBOMPlantCustomFilter"); 
	        	  strContextMCO = emxGetParameter(request,"MFGMBOMMCOContextChangeFilter");
	        	  strContextMCO = (UIUtil.isNullOrEmpty(strContextMCO))?"":strContextMCO;
	        	  
	        	  strContextMCOSelectionMSG = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.PlantSpecificView.Alert.ContextMCOSelection");
	        	  
	        	  if("Current".equals(strBOMView))
	        		{
	        		  strContextMCOSelectionMSG = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.MBOMCustomFilter.AlertMessage");
	 	        	 
	        		}
        	  
        	  if("0".equals(sRowId) && "".equals(bomParentOID)){
				  bomParentOID = bomObjectId;
              }
	        	  assignedPlantList = getAssignedPlants(context);
        	  
	          if(UIUtil.isNullOrEmpty(strContextMCO)){
        	  
	        		  strErrMsg = strContextMCOSelectionMSG;
	        		  
	          }else if(UIUtil.isNullOrEmpty(strPlantId)){
        		  
        		  strErrMsg = EnoviaResourceBundle.getProperty(context,"emxMBOMStringResource",context.getLocale(),"emxMBOM.Common.Process.Error");
        		  strErrMsg += EnoviaResourceBundle.getProperty(context,"emxMBOMStringResource",context.getLocale(),"emxMBOM.Deviation.Raise.Error_2");
        		  
        	  }else{
        		  
        		  for (int j = 0; j < assignedPlantList.size(); j++) {
      				attrPlantID = (String) assignedPlantList.get(j);
      					if(attrPlantID.equals(strPlantId)) {
      						isPlantMember = true;
      						break;
      					}
      				}
	        		  if(!isPlantMember) {
           	  
	        			  strErrMsg = EnoviaResourceBundle.getProperty(context,"emxMBOMStringResource", context.getLocale(),"emxMBOM.Common.Process.Error") + ".";
	        			  strErrMsg += EnoviaResourceBundle.getProperty(context,"emxMBOMStringResource", context.getLocale(),"emxMBOM.Common.Membership.Error");
	  	          }
        	  }
        	  
        	  if(UIUtil.isNotNullAndNotEmpty(strErrMsg)){        		
   %>
   	          <script language = "javascript">
   	          var sERRORMSG = "<%=strErrMsg%>";
   	          var sContextMCOSelectionMSG = "<%=strContextMCOSelectionMSG%>";
   	       	  alert(sERRORMSG);
   	          getTopWindow().closeWindow();
   	          var sRef  = getTopWindow().getWindowOpener();
   	         if(sERRORMSG==sContextMCOSelectionMSG){
	   	        if(sRef!=undefined){
	   	        	sRef.showAutoFilterDisplay();
	   			  }
	             }	
        	  
   	            </script>
	  			 <% } else{
		  			contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreateATCPart&header=emxEngineeringCentral.MBOM.CreateManufacturingPart&type=type_MaterialPart,type_ToolPart,type_SupportPart&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+contextECO+"&MFGMBOMMCOContextChangeFilter=" + strContextMCO + "&postProcessURL=../manufacturingchange/MFGAT_PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+isWipMode + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_MaterialPart,type_ToolPart,type_SupportPart";
	  			    }
	          }catch(Exception e){
	        	  throw e;
	          }
           }
	  }	    
} else {
	   contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreateATCPart&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_AT_C_Part&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=treeContent&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp&createMode=EBOMReplaceNew&createJPO=emxPart:createPartJPO&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&preProcessJavaScript=preProcessInCreatePartIntermediate&typeChooser=true&InclusionList=type_AT_C_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct";
}
}
%>

<%!

	public StringList getAssignedPlants(Context context) throws Exception{
		
		String TYPE_PLANT    = PropertyUtil.getSchemaProperty(context,"type_Plant");
		com.matrixone.apps.common.Person contextUser =	com.matrixone.apps.common.Person.getPerson(context);
		
		String objectWhere = DomainConstants.SELECT_CURRENT + " == " + DomainConstants.STATE_PERSON_ACTIVE;
		
		MapList plantList =	contextUser.getRelatedObjects(context, DomainConstants.RELATIONSHIP_MEMBER, TYPE_PLANT, new StringList(EngineeringConstants.SELECT_PLANT_ID), null, true, false, (short) 1, objectWhere, null);
		StringList slassignedPlant = new StringList();
		for(int i = 0; i < plantList.size(); i++) {
			String attrPlantID	= (String)((Map)plantList.get(i)).get(EngineeringConstants.SELECT_PLANT_ID);
			slassignedPlant.add(attrPlantID);
		}
		return slassignedPlant;
	}
	public boolean isChangeControlled(Context context, String objectId) throws MatrixException {
		String strChangeControlled = DomainObject.newInstance(context, objectId).getAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_ChangeControlled"));
		
		return "True".equalsIgnoreCase(strChangeControlled);
	}
	public boolean isConfiguredPart(Context context, String objectId) throws MatrixException {
		String strObjectPolicy = DomainObject.newInstance(context, objectId).getInfo(context,DomainObject.SELECT_POLICY);
		
		return EngineeringConstants.POLICY_CONFIGURED_PART.equalsIgnoreCase(strObjectPolicy);
	}
%>


<html>
<head>
</head>
<body scrollbar="no" border="0">
<script language="JavaScript" type="text/javascript">
//XSSOK
var frameName = "ENCBOM";
var sCreateMode = '<%=sCreateMode%>';
if(sCreateMode == "EBOMReplaceNew" || sCreateMode == "UEBOMReplaceNew"){
	frameName = getTopWindow().getWindowOpener().name;
}
var prmode = "";
var selPartRowId = "";
var sCreateMode = '<%=sCreateMode%>';
var rmbRowId1  = "<%=sRowId%>";
var encTargetFrame =  findFrame(getTopWindow(),"MGS_ENCBOM");
var	 targetFrame = encTargetFrame ?  encTargetFrame :  findFrame(getTopWindow(),"ENCBOM");
targetFrame = encTargetFrame ?  encTargetFrame :  findFrame(getTopWindow(),"PUEUEBOM");
targetFrame = targetFrame ?  targetFrame :  findFrame(getTopWindow(),"content");
var scontentURL = '<%=XSSUtil.encodeForJavaScript(context,contentURL)%>';
if(sCreateMode=="EBOM" || sCreateMode=="UEBOMAddNew" || sCreateMode=="MGS_EBOM"){
	prmode=((targetFrame&& targetFrame.editableTable) && (sCreateMode=="EBOM" || sCreateMode=="UEBOMAddNew"))?targetFrame.editableTable.mode:"";
	if(prmode=="edit"){
		//scontentURL="../common/emxCreate.jsp?nameField=both&form=type_CreatePart&submitAction=doNothing&header=emxEngineeringCentral.InsertNew.PartasMarkup&type=type_Part&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+"<%=contextECO%>"+"&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+"<%=targetLocation%>"+"&SuiteDirectory="+"<%=SuiteDirectory%>"+"&StringResourceFileId="+"<%=StringResourceFileId%>"+"&suiteKey="+"<%=suiteKey%>"+"&bomRelId="+"<%=bomRelId%>"+"&bomObjectId="+"<%=bomObjectId%>"+"&bomParentOID="+"<%=bomParentOID%>"+"&sRowId="+rmbRowId1+"&sDisableSparePartYesOption=true&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+"<%=isWipMode%>" + "&multiPartCreation=" + "<%=multiPartCreation%>"+"&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct&fromMarkupView="+"<%=fromMarkupView%>";
	}
}
else if(sCreateMode=="EBOMReplaceNew" || sCreateMode=="UEBOMReplaceNew"){
	prmode=((getTopWindow() && getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().editableTable))?getTopWindow().getWindowOpener().editableTable.mode:"";
}
document.location.href=scontentURL+'&highestFN='+highest+'&prmode='+prmode+'&selPartRowId='+rmbRowId1;
</script>
</body>
</html>
              
	      
   
