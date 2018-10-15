<%-- emxEngrBOMIntermediateProcess.jsp --
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%--
  * @quickreview gh4 qwm 2016-06-08 _IR-444360: MBOMConsolidated View Changes
  * @quickreview gh4 2015-09-16 _IR-399342: No fixes, changes to just correct the indentation
  * @quickreview gh4 2015-09-16 _IR-399342: Undo-command not seen, fixed by adding showRMBInlineCommands=true to the URL
--%>

<%@page import="com.matrixone.apps.common.Plant"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
	String[] objectid = emxGetParameterValues(request, "objectId");
	String relId = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "relId"));
	String strPartId = objectid[0];
	String suiteKey = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "suiteKey"));
	//if(com.matrixone.apps.engineering.EngineeringUtil.isENGSMBInstalled(context)) { //Commented for IR-213006
		//suiteKey = "TeamBOMEditor";
		//replacing the physical id passed in the URL to ObjectId in the session, if web session is opened from "Open in Web" command
		com.matrixone.apps.domain.DomainObject partObj = new com.matrixone.apps.domain.DomainObject(strPartId);
		strPartId =  partObj.getInfo(context, com.matrixone.apps.domain.DomainObject.SELECT_ID);
		String sType=partObj.getInfo(context,DomainConstants.SELECT_TYPE);
	//}
	String[] sENCBillOfMaterialsViewCustomFilter = emxGetParameterValues(request, "ENCBillOfMaterialsViewCustomFilter");
	String sBOMFilter = XSSUtil.encodeForJavaScript(context,sENCBillOfMaterialsViewCustomFilter[0]);
	String sRevisionFilterVal = emxGetParameter(request, "ENCBOMRevisionCustomFilter");
String sInstanceMaturityFilterVal = emxGetParameter(request, "MGS_InstanceMaturityCustomFilter");
	
	String strUnAssinged = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.Unassigned");
	StringList slPlantName  = new StringList();
	StringList slPlantID  = new StringList();
	String sPlantObjId = "";
	String sSubHeader = "";
	if(EngineeringUtil.isMBOMInstalled(context) && (sBOMFilter.equalsIgnoreCase("plantspecificConsolidated") || sBOMFilter.equalsIgnoreCase("plantspecific") || sBOMFilter.equalsIgnoreCase("common"))){
		
		slPlantName  = partObj.getInfoList(context,"to["+DomainConstants.RELATIONSHIP_MANUFACTURING_RESPONSIBILITY+"].from.name");
		if(slPlantName.size()>0){
			slPlantID  = partObj.getInfoList(context,"to["+DomainConstants.RELATIONSHIP_MANUFACTURING_RESPONSIBILITY+"].from.id");
			sSubHeader= (String)slPlantName.get(0);
			sPlantObjId= (String)slPlantID.get(0);
		}
		
		if(strUnAssinged.equalsIgnoreCase(sSubHeader))
		{
			sSubHeader = "";
		}
		else {
			if(sSubHeader != null && !sSubHeader.equals(strUnAssinged) && !sSubHeader.equals("null")) {
				if(UIUtil.isNotNullAndNotEmpty(sPlantObjId) && (sBOMFilter.equalsIgnoreCase("plantspecificConsolidated") || sBOMFilter.equalsIgnoreCase("plantspecific"))){
					String sPlantTZVal = Plant.getTimeZoneDisplayValue(context, sPlantObjId);
					sSubHeader = sSubHeader+sPlantTZVal;
				}
				if(sBOMFilter.equalsIgnoreCase("common")){
					sSubHeader = sSubHeader;
				}
			}
		}
	}
	
	HashMap programMap = new HashMap();
	programMap.put("objectId", strPartId);
	
	// Code changes for X-BOM Cost Analytics-START
	boolean isCamInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMCostAnalytics",false,null,null);
	
	Boolean  blnIsApplyAllowed; 
	
	if(isCamInstalled)
	{
	  blnIsApplyAllowed = (Boolean)JPO.invoke(context,"CAENCActionLinkAccessBase",null,"isApplyAllowed",JPO.packArgs(programMap),Boolean.class);
	} else {
	  blnIsApplyAllowed = (Boolean)JPO.invoke(context,"emxENCActionLinkAccess",null,"isApplyAllowed",JPO.packArgs(programMap),Boolean.class);
	}
	//Code changes for X-BOM Cost Analytics-END
	
	if("plantspecificConsolidated".equalsIgnoreCase(sBOMFilter) || "plantspecific".equalsIgnoreCase(sBOMFilter))
	{
		blnIsApplyAllowed = (Boolean)JPO.invoke(context,"emxMBOMUIUtil",null,"isApplyAllowed",JPO.packArgs(programMap),Boolean.class);
	}
	boolean blnApply = blnIsApplyAllowed.booleanValue();
	
	String findNumber = com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,"attribute_FindNumber");
%>

<script language="Javascript">
//XSSOK
var sBOMFilterVal = "<%=sBOMFilter%>";

	if(sBOMFilterVal=="plantspecificConsolidated")
	{
		sURL = "../common/emxIndentedTable.jsp?type=<%=sType%>&preProcessJPO=emxMBOMPart:hasMBOMEditSelected&expandProgram=enoMBOMConsolidated:getPlantSpecificConsolidatedView&table=MFGMBOMSummarySBConsolidated&toolbar=MFGMBOMToolBar,MFGMBOMCustomFilterMenu&header=emxMBOM.Command.BOMHeader&sortColumnName=<xss:encodeForURL><%=findNumber%></xss:encodeForURL>,Sequence&sortDirection=ascending&HelpMarker=emxhelpbomplantview&PrinterFriendly=true&selection=multiple&portalMode=true&objectCompare=false&objectId=<xss:encodeForURL><%=strPartId%></xss:encodeForURL>&suiteKey=<%=suiteKey%>&editRootNode=false&showApply=<%=blnApply%>&showTabHeader=true&subHeader=" +"<xss:encodeForURL><%=sSubHeader%></xss:encodeForURL>"+ "&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&connectionProgram=enoMBOMConsolidated:doMBOMActions&postProcessJPO=emxMBOMPart:validateStateForApply&showRMB=false&effectivityRelationship=relationship_MBOM,relationship_MBOMPending&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&expandLevelFilter=true";
	}
	else if(sBOMFilterVal=="plantspecific")
	{
		sURL = "../common/emxIndentedTable.jsp?type=<%=sType%>&preProcessJPO=emxMBOMPart:hasMBOMEditSelected&expandProgram=emxMBOMPart:getPlantSpecificViewMBOM&table=MFGMBOMSummarySB&toolbar=MFGMBOMToolBar,MFGMBOMCustomFilterMenu&header=emxMBOM.Command.BOMHeader&sortColumnName=<xss:encodeForURL><%=findNumber%></xss:encodeForURL>,Sequence&sortDirection=ascending&HelpMarker=emxhelpbomplantview&PrinterFriendly=true&selection=multiple&portalMode=true&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&objectId=<xss:encodeForURL><%=strPartId%></xss:encodeForURL>&suiteKey=<%=suiteKey%>&editRootNode=false&showApply=<%=blnApply%>&showTabHeader=true&subHeader=" +"<xss:encodeForURL><%=sSubHeader%></xss:encodeForURL>"+ "&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&connectionProgram=emxMBOMPart:visualQuesForManuParts&postProcessJPO=emxMBOMPart:validateStateForApply&lookupJPO=emxMBOMPart:lookupEntries&insertNewRow=true&addJPO=addJPO&showRMB=false&effectivityRelationship=relationship_MBOM,relationship_MBOMPending&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&showRMBInlineCommands=true";
	}
	else if(sBOMFilterVal=="planning")
	{
		sURL = "../common/emxIndentedTable.jsp?type=<%=sType%>&expandProgram=emxPlanningMBOM:getPlanningMBOMForConsumption&table=MFGPlanningMBOMIndentedSummary&toolbar=MFGPlanningMBOMViewToolbar,MFGPlanningMBOMCustomToolBar,MFGPlanningMBOMChangeToolBar&header=emxMBOM.Command.BOMHeader&sortColumnName=Find Number,Sequence&sortDirection=ascending&HelpMarker=emxhelpbomplanningview&PrinterFriendly=true&selection=multiple&portalMode=true&expandLevelFilter=true&objectCompare=false&objectId=<xss:encodeForURL><%=strPartId%></xss:encodeForURL>&suiteKey=<%=suiteKey%>&editRootNode=false&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&showApply=<%=blnApply%>&connectionProgram=emxPlanningMBOM:connectPLBOMPendingMfgPart&postProcessJPO=emxMBOMPart:validateStateForApply&lookupJPO=emxMBOMPart:lookupEntries&addJPO=addJPO&showRMB=true&Initial=true&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp";
	}
	else if(sBOMFilterVal=="common")
	{
		sURL = "../common/emxIndentedTable.jsp?type=<%=sType%>&expandProgram=emxPartMaster:getCommonViewBOM&table=MBOMCommonMBOMSummary&toolbar=MBOMCommonViewToolBar,MBOMCommonCustomFilterMenu&sortColumnName=<xss:encodeForURL><%=findNumber%></xss:encodeForURL>&sortDirection=ascending&header=emxMBOM.Command.BOMHeader&HelpMarker=emxhelpbomcommonview&PrinterFriendly=true&selection=multiple&expandLevelFilter=true&portalMode=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&objectId=<xss:encodeForURL><%=strPartId%></xss:encodeForURL>&suiteKey=<%=suiteKey%>&showTabHeader=true&subHeader=" +"<xss:encodeForURL><%=sSubHeader%></xss:encodeForURL>"+ "&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&connectionProgram=emxMBOMPart:inlineCreateAndConnectPart&editRootNode=false&showApply=<%=blnApply%>&postProcessJPO=emxPart:validateStateForApply&lookupJPO=emxPart:lookupEntries&insertNewRow=true&addJPO=addJPO&relType=EBOM&editRelationship=relationship_EBOM&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&showRMBInlineCommands=true";
	}
	else if(sBOMFilterVal=="atBOMnSPEC")
	{
		sURL = "../common/emxIndentedTable.jsp?table=AT_BOMnSPECSB&expandProgram=emxPart:atGetPartConnectedObjects&header=ATemxEngineeringCentral.Part.SpecAndBOM&objectId=<xss:encodeForURL><%=strPartId%></xss:encodeForURL>&freezePane=Name,Revision,RevisionStatus,DetailPopup&multiColumnSort=false&massPromoteDemote=false&PrinterFriendly=false&triggerValidation=false&showRMB=false&toolbar=ATSPECnBOMToolBar&sortColumnName=none&selection=multiple&suiteKey=EngineeringCentral";
	}
	else
	{
// MGS Custo 
	    sURL = "../common/emxIndentedTable.jsp?type=<%=sType%>&expandByDefault=true&expandProgram=MGS_emxPart:getUM5EBOMsWithRelSelectables&portalMode=true&insertNewRow=false&addJPO=addJPO&connectionProgram=emxPart:inlineCreateAndConnectPart&relType=EBOM&editRelationship=relationship_EBOM&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&table=MGS_ENCEBOMIndentedSummarySB&reportType=BOM&sortColumnName=<xss:encodeForURL><%=findNumber%></xss:encodeForURL>&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&showRMBInlineCommands=true&toolbar=MGS_ENCBOMToolBar,ENCBOMCustomToolBar&objectId=<%=XSSUtil.encodeForJavaScript(context,strPartId)%>&suiteKey=EngineeringCentral&selection=multiple&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&editRootNode=false&showApply=<%=blnApply%>&postProcessJPO=emxPart:validateStateForApply&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&selection=multiple&BOMMode=ENG&isRMBForEBOM=true&displayView=tree,details,thumbnail&hideBPSMenu=true&appendURL=Effectivity|Effectivity&ENCBOMRevisionCustomFilter=<%=sRevisionFilterVal%>&MGS_InstanceMaturityCustomFilter=<%=sInstanceMaturityFilterVal%>&freezePane=Name,Revision,RevisionStatus,DetailPopup";//UIPack : remove "&freezePane=Name,V_Name1,V_Name" see bellow new one
	// sURL = "../common/emxIndentedTable.jsp?type=<%=sType%>&expandProgram=emxPart:getEBOMsWithRelSelectablesSB&portalMode=true&insertNewRow=false&addJPO=addJPO&connectionProgram=emxPart:inlineCreateAndConnectPart&relType=EBOM&editRelationship=relationship_EBOM&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&table=ENCEBOMIndentedSummarySB&reportType=BOM&sortColumnName=<xss:encodeForURL><%=findNumber%></xss:encodeForURL>&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&showRMBInlineCommands=true&toolbar=ENCBOMToolBar,ENCBOMCustomToolBar&objectId=<%=XSSUtil.encodeForJavaScript(context,strPartId)%>&suiteKey=EngineeringCentral&selection=multiple&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&editRootNode=false&showApply=<%=blnApply%>&postProcessJPO=emxPart:validateStateForApply&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&selection=multiple&BOMMode=ENG&isRMBForEBOM=true&displayView=tree,details,thumbnail&hideBPSMenu=true&freezePane=Name,V_Name1,V_Name&ENCBOMRevisionCustomFilter=<%=sRevisionFilterVal%>";
	}
	
	//XSSOK
	if("<%=relId%>" != null){
	//XSSOK
			sURL += "&relId=<%=relId%>";
	}
	//X3 MBOM Code Ends
	
	
	sURL += "&selectHandler=crossHighlightENG"; 
	//sURL += "&crossHighlight=true";
	window.location.href = sURL;
</script>
