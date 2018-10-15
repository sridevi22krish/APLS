
<%--
  ECMDisconnectProcess.jsp

  Copyright (c) 1992-2015 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: ECMDisconnectProcess.jsp 1.13 Tue Oct 28 23:01:03 2008 przemek Experimental przemek $";
  
  ECMDisconnectProcess.jsp is process jsp for all disconnect operations in ECM.
  Suresh S; 12-Oct-2017; Modified for QC 5045.
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "ECMDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="changeUtil" class="com.dassault_systemes.enovia.enterprisechangemgt.util.ChangeUtil" scope="session"/>
<jsp:useBean id="changeSubscription" class="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeSubscription" scope="session"/>

<%
    String strMode   	   = emxGetParameter(request, "mode");
    String functionality   = emxGetParameter(request, "functionality");    
    String strTreeId 	   = emxGetParameter(request,"jsTreeID");
    String objectId  	   = emxGetParameter(request, "objectId"); 
    String[] strTableRowIds= emxGetParameterValues(request, "emxTableRowId");
    String targetCOId      = emxGetParameter(request, "newObjectId");
    String targetCRId      = emxGetParameter(request, "newObjectId");
    String strCommandName  = emxGetParameter(request, "commandName");
    String tmplId = emxGetParameter(request,"tmplId");
    String strLanguage     = context.getSession().getLanguage();    
    boolean bIsError       = false; 
    String strAlertMessage = DomainConstants.EMPTY_STRING;
	ChangeOrder changeOrder=  new ChangeOrder(objectId);
   
	Map mapObjIdRelId 	   = changeUtil.getObjRelRowIdsMapFromTableRowID(strTableRowIds);
	StringList listObjIDs  = (StringList)mapObjIdRelId.get("ObjId");
	StringList listRelIDs  = (StringList)mapObjIdRelId.get("RelId");
	StringList listRowIDs  = (StringList)mapObjIdRelId.get("RowId");
	
	StringBuffer xmlResponse = new StringBuffer(1024); 
	boolean isRemoveDone     = false; 
	StringList selectedItemsList;
	String errorMessage = "";
	
    try {       
         ContextUtil.startTransaction(context,true);
         if (("disconnectAffectedItem".equalsIgnoreCase(functionality) && listRelIDs != null) || "disconnectAffectedItemFromChangeMgmt".equalsIgnoreCase(functionality)) {          	 	
        	 	mapObjIdRelId = changeUtil.getObjRelRowIdsMapFromTableRowID(strTableRowIds);
        	 	
        	 	//Added as part of Redmine 7777 -  QC 5045 - Start
        	 	Map map = new HashMap(1);
      		  	map.put("RelId", (StringList)mapObjIdRelId.get("RelId"));
      		    map.put("ObjId", (StringList)mapObjIdRelId.get("ObjId"));
      		  	map.put("COId", (StringList)mapObjIdRelId.get("objectId"));
      		  	String[] args = JPO.packArgs(map);
      		  	//fetch list of rel IDs Physical Products of CIs connected to CA
      		  	//Rel between Physical Product and CA is obtained only if CI is connected to CA
         		StringList relIDOfPRD = (StringList) JPO.invoke(context, "emxPart", null, "getCOConnectedPRDs", args, StringList.class);
         		changeOrder.disconnectAffectedItems(context,(StringList)relIDOfPRD);
         		//Added as part of Redmine 7777 -  QC 5045 - End
        	 	
        	 	changeOrder.disconnectAffectedItems(context,(StringList)mapObjIdRelId.get("RelId"));
         		
         		isRemoveDone = true;
         }
         else if ("disconnect".equalsIgnoreCase(functionality) &&  listRelIDs != null) {                            			        	 
        	 	changeOrder.disconnect(context,listRelIDs);
		      	isRemoveDone = true;
         }
         else if ("delete".equalsIgnoreCase(functionality)) {
				changeOrder.delete(context,listObjIDs);
				isRemoveDone = true;
		 }
         else if ("MoveToNewCO".equalsIgnoreCase(functionality) || "MoveToExistingCO".equalsIgnoreCase(functionality)) {                                  	
	    		selectedItemsList = strTableRowIds != null ? changeUtil.getObjectIdsFromTableRowID(strTableRowIds) : new StringList();
	    		targetCOId		  = changeUtil.isNullOrEmpty(targetCOId) ? (String)selectedItemsList.get(0) : targetCOId;
        	 	context			  = "MoveToNewCO".equalsIgnoreCase(functionality)? (matrix.db.Context)request.getAttribute("context") : context;        	 	
            	mapObjIdRelId 	  = changeUtil.getObjRelRowIdsMapFromTableRowID((String[])session.getAttribute("sourceAffectedItemRowIds"));        	
            	changeOrder.setId(targetCOId);    			
            	changeOrder.moveToChangeOrder(context, (StringList)mapObjIdRelId.get("RelId"), (StringList)mapObjIdRelId.get("ObjId"),objectId); 
        	 	listRowIDs = (StringList)mapObjIdRelId.get("RowId");
        	 	isRemoveDone = true;
				functionality= "move";
		}
         else if ("MoveToNewCR".equalsIgnoreCase(functionality) || "MoveToExistingCR".equalsIgnoreCase(functionality)) {                                  	
        	    selectedItemsList = strTableRowIds != null ? changeUtil.getObjectIdsFromTableRowID(strTableRowIds) : new StringList();
	    		targetCRId		  = changeUtil.isNullOrEmpty(targetCRId) ? (String)selectedItemsList.get(0) : targetCRId;

            	mapObjIdRelId = changeUtil.getObjRelRowIdsMapFromTableRowID((String[])session.getAttribute("sourceAffectedItemRowIds"));     	 		listRowIDs		  = (StringList)((Map)changeUtil.getObjRelRowIdsMapFromTableRowID((String[])session.getAttribute("sourceAffectedItemRowIds"))).get("RowId");
     	 		context			  = "MoveToNewCR".equalsIgnoreCase(functionality) ? (matrix.db.Context)request.getAttribute("context") : context;
     	 		ChangeRequest changeRequest=  new ChangeRequest(targetCRId);
     	 		changeRequest.moveAffectedItems(context, (StringList)mapObjIdRelId.get("RelId"), (StringList)mapObjIdRelId.get("ObjId"));
      			isRemoveDone = true;
				functionality= "move";
		} else if ("disconnectCAAffectedItem".equalsIgnoreCase(functionality)) {
			 ChangeAction changeAction = new ChangeAction(objectId);
				//Added as part of Redmine 7777 -  QC 5045 - Start
				Map map = new HashMap(1);
				map.put("RelId", (StringList)mapObjIdRelId.get("RelId"));
				map.put("ObjId", (StringList)mapObjIdRelId.get("ObjId"));
				map.put("COId", (StringList)mapObjIdRelId.get("objectId"));
				
				String[] args = JPO.packArgs(map);
				//fetch list of rel IDs Physical Products of CIs connected to CA
				//Rel between Physical Product and CA is obtained only if CI is connected to CA
				StringList relIDOfPRD = (StringList) JPO.invoke(context, "emxPart", null, "getCOConnectedPRDs", args, StringList.class);
				changeOrder.disconnectAffectedItems(context,(StringList)relIDOfPRD);
				//Added as part of Redmine 7777 -  QC 5045 - End
				 changeAction.disconnectAffectedItems(context,listRelIDs);
	    		 isRemoveDone = true;
			
		}
		else if ("disconnectImplementedItem".equalsIgnoreCase(functionality) &&  listRelIDs != null) {                            			        	 
			String[] ObjArr = (String[])listRelIDs.toArray(new String[listRelIDs.size()]);
			ChangeAction changeAction = new ChangeAction(objectId);
			boolean isinvalid = changeAction.disconnectImplementedItem(context,ObjArr);
			strCommandName = "ECMCAImplementedItems";
			if(isinvalid)
		    {
		    	%>
			 	<script language="javascript" type="text/javaScript">
			 	alert("<%=EnoviaResourceBundle.getProperty(context,  ChangeConstants.RESOURCE_BUNDLE_ENTERPRISE_STR, 
								context.getLocale(),"EnterpriseChangeMgt.Notice.RemoveImplementedItems")%>");
			 	var framename = findFrame(getTopWindow(),"<%=XSSUtil.encodeForJavaScript(context, strCommandName)%>");
			 	framename.document.location.href = framename.document.location.href;
			 	</script>
		        <% 
			}else{
				isRemoveDone = true;
			}
     	 }
    	else if ("deleteSubscriptions".equalsIgnoreCase(functionality)) {

	   		listObjIDs			  = (UIUtil.isNullOrEmpty(objectId)) ? listObjIDs : new StringList(objectId);
	   		String strObjDeleted  = (String) changeSubscription.deleteSubscriptionEvents(context,listObjIDs);

        %>
		 	<script language="javascript" type="text/javaScript">
        	var channelFrame = findFrame(getTopWindow(),"<%=XSSUtil.encodeForJavaScript(context, strCommandName)%>");
        	
        	if(channelFrame != null){
        		
        	channelFrame.document.location.href = channelFrame.document.location.href;
        	
        	} else {
        		
        		getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
        		getTopWindow().close();
        		
        	}
        	</script>
        		
        <% 
        		
		 }
    	else if ("removeReferential".equalsIgnoreCase(functionality) &&  listObjIDs != null) {
   			 new ChangeAction().removeReferential(context, objectId, listObjIDs);
    	   	isRemoveDone = true;
	      }
         
         if(isRemoveDone) {
				xmlResponse.append("<mxRoot>").append("<action>remove</action>");
				xmlResponse.append(changeUtil.getItemXMLFromList(listRowIDs));
				xmlResponse.append("</mxRoot>");
         }
         ContextUtil.commitTransaction(context);
     } 
    catch(Exception e) 
	{
    	e.printStackTrace();
    	ContextUtil.abortTransaction(context);
        bIsError=true;
        errorMessage = e.getMessage();
        session.putValue("error.message",errorMessage);
	}
%> 

<script language="javascript" type="text/javaScript">
<!-- XSSOK -->
var bError = "<%=bIsError%>";
//XSSOK
var functionality = "<%=functionality%>";
//XSSOK
var isRemoveDone  = "<%=isRemoveDone%>";

if (bError=="true") {
	alert("Exception Occurred: "+errorMessage);
 }
else if(("MoveToNewCO" == functionality || "disconnectAffectedItem" == functionality || "disconnectCAAffectedItem" == functionality || 
		 "MoveToExistingCO" == functionality || "MoveToNewCR" == functionality || "MoveToExistingCR" == functionality) && bError == "false") {
	var addExistingCase    = functionality.indexOf("Existing") > -1 ? true : false;
//	var affectedItemFrame  = findFrame(addExistingCase ? getTopWindow().opener.getTopWindow() :getTopWindow() ,"ECMCRCOAffectedItems");
//	var changeActionsFrame = findFrame(addExistingCase ? getTopWindow().opener.getTopWindow() :getTopWindow(),"ECMCRCOAffectedChangeActions");	
//	affectedItemFrame.location.href  = affectedItemFrame.location.href;
//	changeActionsFrame.location.href = changeActionsFrame.location.href;
	
//  IR 454663
	var windowToRefer = addExistingCase ? getTopWindow().getWindowOpener().getTopWindow() : getTopWindow();
	var varDetailsDisplay = findFrame(windowToRefer, "detailsDisplay");
	if (varDetailsDisplay) {
			varDetailsDisplay.location.href = varDetailsDisplay.location.href;
	}
	
	if(addExistingCase) getTopWindow().close();
}
else if(isRemoveDone && getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().removedeletedRows) {
	//XSSOK
	//getTopWindow().getWindowOpener().removedeletedRows("<%=xmlResponse%>");
	//parent.location.href = parent.location.href;
	getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
	getTopWindow().close();
}
else if(isRemoveDone && parent.removedeletedRows) {	 
	//XSSOK
	//Added for removing XML Parsing error
	var response = "<%=xmlResponse%>";
	if(response != "")
	{
		parent.removedeletedRows("<%=xmlResponse%>");
	}
}
else {	
	refreshTreeDetailsPage();  
}
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
