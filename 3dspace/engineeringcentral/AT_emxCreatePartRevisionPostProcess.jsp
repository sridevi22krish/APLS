<%--  emxCreatePartRevisionPostProcess.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxEngrFramesetUtil.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="matrix.db.Context"%>
<%@page import = "com.matrixone.apps.engineering.EngineeringConstants" %>
<%@page import = "com.matrixone.apps.engineering.Part" %>

<%
  
  String sErrMsgCode    = "";
  
  String copyObjectId = emxGetParameter(request,"copyObjectId");
  Part part = new Part(copyObjectId);
  
  String newRevId = emxGetParameter(request,"newObjectId");
  Part revPart = new Part(newRevId);

  context = (Context)request.getAttribute("context");
  
  
  	 //External Request 7898 WP7 QC5070	START
	 DomainObject newObj = DomainObject.newInstance(context, newRevId);
	 String ObjType = newObj.getInfo(context,DomainConstants.SELECT_TYPE);
	 
	 String TYPE_AT_C_COS = PropertyUtil.getSchemaProperty("type_AT_C_COS");
	 String TYPE_AT_C_DESIGN_PART = PropertyUtil.getSchemaProperty("type_AT_C_DESIGN_PART");
	 String TYPE_AT_C_EXPECTED_PRODUCT = PropertyUtil.getSchemaProperty("type_AT_C_EXPECTED_PRODUCT");
	 String TYPE_AT_C_STANDARD_PART = PropertyUtil.getSchemaProperty("type_AT_C_STANDARD_PART");

	 
	 if(TYPE_AT_C_COS.equals(ObjType) || TYPE_AT_C_DESIGN_PART.equals(ObjType) || TYPE_AT_C_EXPECTED_PRODUCT.equals(ObjType) || TYPE_AT_C_STANDARD_PART.equals(ObjType)){
	 
				Hashtable argTable = new Hashtable();
				argTable.put("ROOTID", newRevId);
				argTable.put("SYNC_DEPTH", "-1");
						  
				  String[] synchroBOMArgs = JPO.packArgs(argTable);
				//Modified to fix redmine 8680 - Use public API for synchronization - start
				  //Map synchroResults  = (Map) JPO.invoke(context,"AT_emxDeformable", null, "launchEncapsulatedSynchro", synchroBOMArgs,	Map.class);
				  Map synchroResults  = (Map) JPO.invoke(context,"AT_emxDeformable", null, "launchEncapsulatedSynchroPublicAPI", synchroBOMArgs,	Map.class);
				//Modified to fix redmine 8680 - Use public API for synchronization - end
				  
				if (synchroResults != null) {
					if (synchroResults.containsKey("ERROR_MESSAGE")) {
						Object errorMessage = synchroResults.get("ERROR_MESSAGE");
						String sErrorSynchro = "Synchronization Error: \\n";
						if (errorMessage instanceof String) {
							sErrorSynchro += (String) errorMessage;
						} else if (synchroResults.get("ERROR_MESSAGE") instanceof ArrayList<?>) {
							ArrayList<String> alErrorSynchro = (ArrayList<String>) errorMessage;
							Iterator<String> itResult = alErrorSynchro.iterator();
							while (itResult.hasNext()) {
								sErrorSynchro += itResult.next();
							}
						}																			
	%>           
					 <script language="javascript" type="text/javaScript">
					 alert("<%=sErrorSynchro%>");
					 </script>
	 <%
					} else if (synchroResults.containsKey("ERROR_MESSAGES")) {
						ArrayList alERROR_MESSAGES = (ArrayList) synchroResults.get("ERROR_MESSAGES");

						StringBuffer sbErrorMessage = new StringBuffer();
						if (alERROR_MESSAGES != null & alERROR_MESSAGES.size() > 0) {
							for (int i = 0; i < alERROR_MESSAGES.size(); i++) {
								sbErrorMessage.append((String) alERROR_MESSAGES.get(i));
							}
							String ErrorMessage = sbErrorMessage.toString();
	%>           
					 <script language="javascript" type="text/javaScript">
					 alert("Synchronization Error: \n <%=ErrorMessage%>");
					 </script>
	 <%
						}
					}else{
						  JPO.invoke(context,"AT_emxDeformable", null, "setInstanceDeformVisibilityAtRevise", synchroBOMArgs,	Map.class);
					}
				}
	 }				
	 //External Request 7898 WP7 QC5070	END
  
  String sUserToset= part.getInfo(context, "attribute[Originator]");
  revPart.setAttributeValue(context, "Originator", sUserToset);
  
  boolean isMFGInstalled = EngineeringUtil.isMBOMInstalled(context);
%>

<%@include file = "emxEngrStartUpdateTransaction.inc"%>

<%
try {
	if (isMFGInstalled) 
	{
		//A64+ Added for Planning MBOM -> start
		revPart.setEndItem(context);
		String strPolicy = revPart.getInfo(context, DomainConstants.SELECT_POLICY);
		
		if(UIUtil.isNotNullAndNotEmpty(strPolicy) && strPolicy.equals(DomainConstants.POLICY_EC_PART)) {
			String sEndItem = emxGetParameter(request, "EndItem");
			
			//Added PR Inter-face changes
			if(UIUtil.isNotNullAndNotEmpty(sEndItem) && "Yes".equalsIgnoreCase(sEndItem)) {
				String prevProductId= part.getInfo (context, "to["+PropertyUtil.getSchemaProperty(context, "relationship_GBOM")+"].from.id");
				String NewProductId = revPart.getInfo (context, "to["+PropertyUtil.getSchemaProperty(context, "relationship_GBOM")+"].from.id");
				if(UIUtil.isNotNullAndNotEmpty(prevProductId) &&  !(prevProductId.equals(NewProductId))){
				  DomainRelationship.connect(context,new DomainObject(prevProductId),PropertyUtil.getSchemaProperty(context, "relationship_GBOM"),revPart);
				}
			}
		}
		
		
		if(UIUtil.isNotNullAndNotEmpty(strPolicy) && strPolicy.equals(DomainConstants.POLICY_EC_PART)) {
			String planningReq = emxGetParameter(request, "PlanningRequired");
			
			//Added PR Inter-face changes
			if(UIUtil.isNotNullAndNotEmpty(planningReq)) {
				revPart.setPlanningReq(context, planningReq);
				//Added for Manufacturing Plan -Start
				//commented for IR-308242-3DEXPERIENCER2015x
				/* if("Yes".equalsIgnoreCase(planningReq)){
				  revPart.addManufacturingPlan(context);
				} */
				//Added for Manufacturing Plan - End
			}
		}
		
		
		//A64- Added for Planning MBOM -> End
    }
    
    //Added for MCC EC Interoperability Feature
    //Below code will  be used to automatically enable revised EC parts when the Parent part's MCC Update setting is Unset i.e. interface is not associated
    boolean mccInstall = FrameworkUtil.isSuiteRegistered(context,"appVersionMaterialsComplianceCentral",false,null,null);
    if(mccInstall) {
    	String attrEnableCompliance =PropertyUtil.getSchemaProperty(context,"attribute_EnableCompliance");
        String sEnableCompliance = part.getInfo (context, "attribute["+attrEnableCompliance+"]");

         //check if  "Enable Compliance" attribute present on the part. if it does not contain the attribute i.e. interface is not associated then the value for attribute to be return as blank ""
        if("".equals(sEnableCompliance)) {   //check that values for this property will be "Yes"
            String strEnableForMCC = FrameworkProperties.getProperty(context, "emxMaterialsCompliance.EnableMCCForNewECParts");

            if(strEnableForMCC !=null && strEnableForMCC.equalsIgnoreCase("Yes")) {
                //associate the Compliance interface to a new revise part
                MqlUtil.mqlCommand(context,"modify bus $1 add interface $2",newRevId,"Material Compliance");
                //getting default value for "Enable Compliance" attribute & set it
                AttributeType attrEnableComplianceType = new AttributeType(attrEnableCompliance);
                revPart.setAttributeValue(context,attrEnableCompliance,attrEnableComplianceType.getDefaultValue(context));
            }
        }
    }
%>

   <script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
   <script language="javascript">
   
   function updateCountAndRefreshTreeTest(appDirectory,openerObj,parentOIDs)
   {
       var objectIds   = getObjectsToBeModified(openerObj,parentOIDs);
       
       for(var objectId in objectIds) {
       
           var updatedLabel    = getUpdatedLabel(appDirectory,objectId,openerObj);
       
           openerObj.changeObjectLabelInTree(objectId, updatedLabel, true, false, false);
       }
   } 
   updateCountAndRefreshTreeTest("<%=appDirectory%>", getTopWindow().getWindowOpener());
  
   //XSSOK
    
       getTopWindow().getWindowOpener().refreshTable();

   </script>
<% 
} catch(Exception e) {
%>
  <%@include file = "emxEngrAbortTransaction.inc"%>
<%
  session.putValue("error.message",e.toString());
%>
    <script language="javascript">
    getTopWindow().location.href = getTopWindow().location.href;
    </script>
<%
}
%>
<%@include file = "emxEngrCommitTransaction.inc"%>
<%
  session.setAttribute("emxEngErrorMessage", sErrMsgCode);
%>

