<%--  emxEngRMBIntermediate.jsp -  This is used as Intermediate jsp for all RMB.
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@page import="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeConstants"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<%@include file = "emxDesignTopInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
    String strRMBTableID = emxGetParameter(request, "emxTableRowId");
    String strViewAndEditMode = emxGetParameter(request, "viewAndEditMode");
    String isFromRMB = emxGetParameter(request,"isFromRMB");
    String suiteKey = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "suiteKey"));
    
    
    String objectId = emxGetParameter(request, "objectId");
    String relatedObjects = emxGetParameter(request, "PartRelatedObjectsView");
    String portalCmdName = emxGetParameter(request, "portalCmdName");
    
    String url = "";
    String strRMBID = null;
    String strTableRowId = "0";
    String strCommandName = "";
    String typeName = "";
    String partType ="";
       
    StringList sList = FrameworkUtil.split(strRMBTableID, "|");    
    
    if (sList.size() == 3) {
        strRMBID = (String) sList.get(0);
        strTableRowId = (String) sList.get(2);
    } else if (sList.size() == 4) {
        strRMBID = (String) sList.get(1);
        strTableRowId = (String) sList.get(3);
    } else if (sList.size() == 2) {
        strRMBID = (String) sList.get(1);
    } else {
        strRMBID = strRMBTableID;
    }
    if("true".equals(isFromRMB) && UIUtil.isNotNullAndNotEmpty(strRMBID)){
    	objectId = strRMBID;
    }
    DomainObject dmObj = DomainObject.newInstance(context,objectId);
    partType = dmObj.getInfo(context, DomainConstants.SELECT_TYPE);
    if("true".equals(relatedObjects) || "true".equals(isFromRMB))   
    {
    String strIsKindOf = dmObj.getInfo(context,"type.kindof");
    	    if(strIsKindOf.equals(DomainConstants.TYPE_PART)) 
    	    {
    	    	String sType = dmObj.getInfo(context,"type");
				String strForm = "type_Part";
    	    	if ("AT_C_COS".equals(sType))
    	    		strForm = "type_AT_C_COS";
    	    	else if ("AT_C_DESIGN_PART".equals(sType))
    	    		strForm = "type_AT_C_DESIGN_PART";
    	    	else if ("AT_C_STANDARD_PART".equals(sType))
				     strForm = "type_AT_C_STANDARD_PART";
    	    	else if ("AT_C_LOGICAL_NODE".equals(sType) || "AT_C_EXPECTED_PRODUCT".equals(sType) || "AT_C_CONFIGURATION_ITEM".equals(sType))
					 strForm = "type_AT_C_CONFIGURED_PART";
			    
				url = "../common/emxForm.jsp?form="+strForm+"&formFieldsOnly=true&HelpMarker=emxhelppartproperties&toolbar=ENCRMBProperties&suiteKey="+suiteKey;
    	    }
    	    else if(strIsKindOf.equals(DomainConstants.TYPE_DOCUMENT))
    	    {
    	    	url = "../common/emxForm.jsp?form=type_Spec&HelpMarker=emxhelpspeceditdetails&suiteKey="+suiteKey;
    	    }  
    	    else if(strIsKindOf.equals(ChangeConstants.TYPE_CHANGE_ORDER))
    	    {
    	    	url = "../common/emxForm.jsp?form=type_ChangeOrderSlidein&HelpMarker=false";
    	    }
    	    else if(strIsKindOf.equals(ChangeConstants.TYPE_CHANGE_REQUEST)) 
    	    {
    	    	url = "../common/emxForm.jsp?form=type_ChangeRequestSlidein&HelpMarker=false";
    	    } 
       	    else
       	    {
    	    	url = "../common/emxDynamicAttributes.jsp?HelpMarker=false";
    	    }
    }
    String sDefaultPartForm = "type_AT_C_CONFIGURED_PART";
    String sDefaultPartToolBar = "ATCENCpartConfiguredPartDetailsToolBar";
    String sCurrentType = dmObj.getInfo(context,"type");
	if ("AT_C_COS".equals(sCurrentType)){
		sDefaultPartForm = "type_AT_C_COS";
		sDefaultPartToolBar = "ATCPartCOSENCRMBProperties";
	}else if ("AT_C_DESIGN_PART".equals(sCurrentType)){
		sDefaultPartForm = "type_AT_C_DESIGN_PART";
		sDefaultPartToolBar = "ATCPartDesignPartENCRMBProperties";
	}
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">   

			var skipExecutionOfUnwantedConditions = false;
			var isApplicationPart = false;
				//XSSOK
			if ("true" == "<%=XSSUtil.encodeForJavaScript(context, strViewAndEditMode)%>") {
				var actionURL = "../common/emxForm.jsp?form=<%=sDefaultPartForm%>&HelpMarker=emxhelppartproperties&toolbar=<%=sDefaultPartToolBar%>&objectId=<%=XSSUtil.encodeForJavaScript(context, strRMBID)%>";
			} 
			else if("<%=DomainConstants.TYPE_APPLICATION_PART%>" == "<%=partType%>")
				{
				 var actionURL = "../common/emxTree.jsp?objectId=<%=objectId%>&suiteKey=<%=suiteKey%>";
				 getTopWindow().showModalDialog(actionURL, "600", "500");
				 isApplicationPart = true;
				} 
			else if("true" == "<%=XSSUtil.encodeForJavaScript(context, relatedObjects)%>"){
					   var skipExecutionOfUnwantedConditions = true;
					   var actionURL = "../common/emxTree.jsp?objectId=<%=objectId%>&suiteKey=<%=suiteKey%>";
						 var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
						 contentFrame.location.href = actionURL;
			}
			else if ("true" == "<%=XSSUtil.encodeForJavaScript(context, isFromRMB)%>"){
				if("ENCRelatedItem" == "<%=portalCmdName%>" || "ENCRelatedItem" == parent.name) {
						var actionURL = "<%=url%>&objectId=<%=XSSUtil.encodeForJavaScript(context, objectId)%>";
				}
				else {
				  	var actionURL = "../common/emxForm.jsp?form=type_Part&Header=emxEngineeringCentral.Part.EditPart&toolbar=ENCRMBProperties&HelpMarker=emxhelpparteditdetails&preProcessJavaScript=preProcessInEditPart&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&emxSuiteDirectory=engineeringcentral&preProcessJPO=emxPart:checkLicense&postProcessURL=../engineeringcentral/emxEngCommonRefresh.jsp&refreshStructure=true&submitAction=doNothing&tableRowId=<%=XSSUtil.encodeForJavaScript(context,strTableRowId)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strRMBID)%>&commandName=" + parent.name;
				}
			}
			else {
				 var actionURL = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context, strRMBID)%>&suiteKey=<%=suiteKey%>";
				 var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
				 var contentFrameMultiPartCreate;
				 if(contentFrame!=null)
				 contentFrameMultiPartCreate = contentFrame.location.href;
				  	 if(contentFrame !=null && contentFrameMultiPartCreate!="undefined" &&(contentFrameMultiPartCreate.indexOf("openShowModalDialog")>-1 ||contentFrameMultiPartCreate.indexOf("launched")>-1)) //This is to open a showModalDialog from popups in Part->RMB Open navigation
					 {
					 getTopWindow().showModalDialog(actionURL, "600", "500");
					}else if(contentFrame == null ) {
					 contentFrame = getTopWindow();
					 getTopWindow().showModalDialog(actionURL, "600", "500");
					 }else{									
					 contentFrame.location.href = actionURL;
					 }
			}

			if(skipExecutionOfUnwantedConditions == false){
			if (this.parent.parent.FullSearch) {
					getTopWindow().showModalDialog(actionURL, "600", "500");
			} else {
			if (("true" == "<%=XSSUtil.encodeForJavaScript(context, strViewAndEditMode)%>")||("true" == "<%=XSSUtil.encodeForJavaScript(context, isFromRMB)%>")) {
					getTopWindow().commandName = [];
					getTopWindow().commandName["refreshRowCommandName"] = parent.name;
			}
 
			 if (("true" == "<%=XSSUtil.encodeForJavaScript(context, isFromRMB)%>")&& !isApplicationPart)
			getTopWindow().showSlideInDialog(actionURL, true);
			}
			}
		
</script>

