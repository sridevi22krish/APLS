<%-- emxBOMFilterProcess.jsp --
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%--
	* @quickreview gh4 qwm 2016-06-08 _IR-444360: MBOMConsolidated View Changes
--%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%
	String[] objectid = emxGetParameterValues(request, "objectId");
	String strPartId = objectid[0];
	HashMap programMap = new HashMap();
	programMap.put("objectId", strPartId);
	String[] strType=emxGetParameterValues(request, "type");
	String sType = strType[0];
	i18nNow i18nInstance = new i18nNow();
	String acceptLanguage = request.getHeader("Accept-Language");
	/*String strAsStored = 
	i18nInstance.GetString("emxEngineeringCentralStringResource", 
												 "en",
											 "emxEngineeringCentral.RevisionFilterOption.As_Stored");*/
String strAsStored =EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",new Locale("en"),"emxEngineeringCentral.RevisionFilterOption.As_Stored");
	Boolean  blnIsApplyAllowed = (Boolean)JPO.invoke(context,"emxENCActionLinkAccess",null,"isApplyAllowed",JPO.packArgs(programMap),Boolean.class);
	boolean blnApply = blnIsApplyAllowed.booleanValue();
	boolean isMBOMinstalled = com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context);
	String[] sBOMFilterValArray = emxGetParameterValues(request, "ENCBillOfMaterialsViewCustomFilter");
	String sBOMFilterVal = sBOMFilterValArray[0];
%>

<script language="Javascript">

	var sURL = "";
	var relId = null;
	var vFrame = "";
	
	
	var sBOMFilterVal= "<%=sBOMFilterVal%>";
	if(sBOMFilterVal=="Engineering" || sBOMFilterVal=="engineering"){
		vFrame = getTopWindow().findFrame(getTopWindow(), "ENCBOM");
	}
	else if(sBOMFilterVal == "plantspecificConsolidated"){
		vFrame = getTopWindow().findFrame(getTopWindow(), "MBOMConsolidated");
	}
	else if(sBOMFilterVal=="plantspecific"){
		vFrame = getTopWindow().findFrame(getTopWindow(), "MBOMPlantSpecific");
	}
	else if(sBOMFilterVal=="common"){
		vFrame = getTopWindow().findFrame(getTopWindow(), "MBOMCommon");
	}
	else if(sBOMFilterVal=="planning"){    
    	vFrame = getTopWindow().findFrame(getTopWindow(), "MBOMPlanning");
	}	
	var relIdObj = vFrame.document.getElementById('relId');
	if(relIdObj != null){
		relId = relIdObj.value;
	}
	var objectID = vFrame.document.getElementById('objectId').value;
	var suiteKey = vFrame.document.getElementById('suiteKey').value;
	var varShowApply = vFrame.document.getElementById('showApply').value;
	var sBOMRevisionFilter = vFrame.getTopWindow().document.getElementById('ENCBOMRevisionCustomFilter');
	
	//MGS start
	var sBOMInstanceMaturityFilter = vFrame.getTopWindow().document.getElementById('MGS_InstanceMaturityCustomFilter');
	if(sBOMInstanceMaturityFilter != null) {
		var sBOMInstanceMaturityFilterVal= sBOMInstanceMaturityFilter.value;
	} else {
		//XSSOK
		var sBOMInstanceMaturityFilterVal= "IN_WORK";
	}
	//MGS end
	if(sBOMRevisionFilter != null) {
		var sBOMRevisionFilterVal= sBOMRevisionFilter.value;
	} else {
		//XSSOK
		var sBOMRevisionFilterVal= "<%=strAsStored%>";
	}

	//XSSOK
	var varShowApply = "<%=blnApply%>";
	//window.parent.document.getElementById('showApply').value;

	var sMBOMDeviationCustomFilter = "";
		try{
			sMBOMDeviationCustomFilter = vFrame.document.getElementById('MBOMDeviationCustomFilter').value;
		}catch(e){
			sMBOMDeviationCustomFilter = "false";
	}
	
	if(sBOMFilterVal=="Engineering" || sBOMFilterVal=="engineering")
	{
	//XSSOK
	if(<%=isMBOMinstalled%>){
    //Modified for IR-033254
	//sURL = "../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&portalMode=true&table=ENCEBOMIndentedSummary&reportType=BOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&toolbar=ENCBOMToolBar,ENCBOMCustomToolBar&objectId="+objectID+"&suiteKey=EngineeringCentral&selection=multiple&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&editRootNode=false&showApply="+varShowApply+"&ENCBOMRevisionCustomFilter="+sBOMRevisionFilterVal+"&MBOMDeviationCustomFilter="+sMBOMDeviationCustomFilter+"&connectionProgram=emxPart:updateBOM&postProcessJPO=emxPart:validateStateForApply&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp";
    //IR-036860 - Starts
    //sURL = "../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&portalMode=true&table=ENCEBOMIndentedSummary&reportType=BOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&toolbar=ENCBOMToolBar,ENCBOMCustomToolBar&objectId="+objectID+"&suiteKey=EngineeringCentral&selection=multiple&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&editRootNode=false&showApply="+varShowApply+"&ENCBOMRevisionCustomFilter="+sBOMRevisionFilterVal+"&MBOMDeviationCustomFilter="+sMBOMDeviationCustomFilter+"&lookupJPO=emxECPartBase:lookupEntries&insertNewRow=true&addJPO=addJPO&connectionProgram=emxECPartBase:inlineCreateAndConnectPart&postProcessJPO=emxPart:validateStateForApply&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp";
    // Commented the below for SB Performance and added new url 
// sURL = "../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&portalMode=true&table=ENCEBOMIndentedSummary&reportType=BOM&relType=EBOM&editRelationship=relationship_EBOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&toolbar=ENCBOMToolBar,ENCBOMCustomToolBar&objectId="+objectID+"&suiteKey=EngineeringCentral&selection=multiple&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&editRootNode=false&showApply="+varShowApply+"&ENCBOMRevisionCustomFilter="+sBOMRevisionFilterVal+"&MBOMDeviationCustomFilter="+sMBOMDeviationCustomFilter+"&lookupJPO=emxPart:lookupEntries&insertNewRow=true&addJPO=addJPO&connectionProgram=emxPart:inlineCreateAndConnectPart&postProcessJPO=emxPart:validateStateForApply&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp";
   //freezePane has been added by FD11 and lookupJPO + MGS filters has been added, showRMBInlineCommands has been removed by the custo
   sURL = "../common/emxIndentedTable.jsp?type=<%=sType%>&expandProgram=MGS_emxPart:getUM5EBOMsWithRelSelectables&freezePane=Name,V_Name1,V_Name&portalMode=true&table=MGS_ENCEBOMIndentedSummarySB&reportType=BOM&relType=EBOM&editRelationship=relationship_EBOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&toolbar=ENCBOMToolBar,ENCBOMCustomToolBar&objectId="+objectID+"&suiteKey=EngineeringCentral&selection=multiple&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&editRootNode=false&showApply="+varShowApply+"&ENCBOMRevisionCustomFilter="+sBOMRevisionFilterVal+"&MBOMDeviationCustomFilter="+sMBOMDeviationCustomFilter+"&lookupJPO=emxPart:lookupEntries&insertNewRow=true&addJPO=addJPO&connectionProgram=emxPart:inlineCreateAndConnectPart&postProcessJPO=emxPart:validateStateForApply&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&BOMMode=ENG&appendURL=Effectivity|Effectivity&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&MGS_InstanceMaturityCustomFilter="+sBOMInstanceMaturityFilterVal; 
 //IR-036860 - Ends
    //Modified for IR-033254
	}
	else{
        //Modified for IR-033254
		//sURL = "../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&portalMode=true&table=ENCEBOMIndentedSummary&reportType=BOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&toolbar=ENCBOMToolBar,ENCBOMCustomToolBar&objectId="+objectID+"&suiteKey="+suiteKey+"&selection=multiple&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&editRootNode=false&showApply="+varShowApply+"&ENCBOMRevisionCustomFilter="+sBOMRevisionFilterVal+"&connectionProgram=emxPart:updateBOM";
        ////IR-036860 - Starts
        //sURL = "../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&portalMode=true&table=ENCEBOMIndentedSummary&reportType=BOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&toolbar=ENCBOMToolBar,ENCBOMCustomToolBar&objectId="+objectID+"&suiteKey="+suiteKey+"&selection=multiple&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&editRootNode=false&showApply="+varShowApply+"&ENCBOMRevisionCustomFilter="+sBOMRevisionFilterVal+"&lookupJPO=emxECPartBase:lookupEntries&insertNewRow=true&addJPO=addJPO&connectionProgram=emxECPartBase:inlineCreateAndConnectPart";
        // Commented the below for SB Performance and added new url 
        //sURL = "../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&portalMode=true&table=ENCEBOMIndentedSummary&reportType=BOM&relType=EBOM&editRelationship=relationship_EBOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&toolbar=ENCBOMToolBar,ENCBOMCustomToolBar&objectId="+objectID+"&suiteKey="+suiteKey+"&selection=multiple&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&editRootNode=false&showApply="+varShowApply+"&ENCBOMRevisionCustomFilter="+sBOMRevisionFilterVal+"&lookupJPO=emxPart:lookupEntries&insertNewRow=true&addJPO=addJPO&connectionProgram=emxPart:inlineCreateAndConnectPart";
      //freezePane has been added by FD11 and lookupJPO + MGS filters has been added, showRMBInlineCommands has been removed by the custo
	  sURL = "../common/emxIndentedTable.jsp?type=<%=sType%>&expandProgram=MGS_emxPart:getUM5EBOMsWithRelSelectables&freezePane=Name,V_Name1,V_Name&portalMode=true&table=MGS_ENCEBOMIndentedSummarySB&reportType=BOM&relType=EBOM&editRelationship=relationship_EBOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&toolbar=ENCBOMToolBar,ENCBOMCustomToolBar&objectId="+objectID+"&suiteKey="+suiteKey+"&selection=multiple&header=emxEngineeringCentral.Part.ConfigTableBillOfMaterials&editRootNode=false&showApply="+varShowApply+"&ENCBOMRevisionCustomFilter="+sBOMRevisionFilterVal+"&lookupJPO=emxPart:lookupEntries&insertNewRow=true&addJPO=addJPO&connectionProgram=emxPart:inlineCreateAndConnectPart&BOMMode=ENG&appendURL=Effectivity|Effectivity&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&MGS_InstanceMaturityCustomFilter="+sBOMInstanceMaturityFilterVal; 
        ////IR-036860 - Ends
        //End for IR-033254
		}
	}
	else if(sBOMFilterVal=="plantspecific")
	{
		sURL = "../common/emxIndentedTable.jsp?preProcessJPO=emxMBOMPart:hasMBOMEditSelected&expandProgram=emxMBOMPart:getPlantSpecificViewMBOM&table=MFGMBOMSummarySB&toolbar=MFGMBOMToolBar,MFGMBOMCustomFilterMenu&header=emxMBOM.Command.BOMHeader&sortColumnName=Find Number,Sequence&sortDirection=ascending&HelpMarker=emxhelpbomplantview&PrinterFriendly=true&selection=multiple&portalMode=true&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&objectId="+objectID+"&suiteKey=MBOM&editRootNode=false&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&MBOMDeviationCustomFilter="+sMBOMDeviationCustomFilter+"&showApply=true"+"&connectionProgram=emxMBOMPart:visualQuesForManuParts&postProcessJPO=emxMBOMPart:validateStateForApply&effectivityRelationship=relationship_MBOM,relationship_MBOMPending&lookupJPO=emxMBOMPart:lookupEntries&appendURL=ChangeEffectivity|MBOM&insertNewRow=true&addJPO=addJPO&showRMB=false&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp";
	}
	else if(sBOMFilterVal=="plantspecificConsolidated")
	{
		sURL = "../common/emxIndentedTable.jsp?preProcessJPO=emxMBOMPart:hasMBOMEditSelected&expandProgram=enoMBOMConsolidated:getPlantSpecificConsolidatedView&table=MFGMBOMSummarySBConsolidated&toolbar=MFGMBOMToolBar,MFGMBOMCustomFilterMenu&header=emxMBOM.Command.BOMHeader&sortColumnName=Find Number,Sequence&sortDirection=ascending&HelpMarker=emxhelpbomplantview&PrinterFriendly=true&selection=multiple&portalMode=true&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&objectId="+objectID+"&suiteKey=MBOM&editRootNode=false&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&MBOMDeviationCustomFilter="+sMBOMDeviationCustomFilter+"&showApply=true"+"&connectionProgram=enoMBOMConsolidated:doMBOMActions&postProcessJPO=emxMBOMPart:validateStateForApply&effectivityRelationship=relationship_MBOM,relationship_MBOMPending&lookupJPO=emxMBOMPart:lookupEntries&appendURL=ChangeEffectivity|MBOM&insertNewRow=true&addJPO=addJPO&showRMB=false&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp";
	}
	else if(sBOMFilterVal=="common")
	{
		sURL = "../common/emxIndentedTable.jsp?type=<%=sType%>&expandProgram=emxPartMaster:getCommonViewBOM&table=MBOMCommonMBOMSummary&toolbar=MBOMCommonViewToolBar,MBOMCommonCustomFilterMenu&sortColumnName=Find Number&sortDirection=ascending&header=emxMBOM.Command.BOMHeader&HelpMarker=emxhelpbomcommonview&PrinterFriendly=true&selection=multiple&expandLevelFilter=true&portalMode=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&objectId="+objectID+"&suiteKey=MBOM&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&ENCBOMRevisionCustomFilter="+sBOMRevisionFilterVal+"&MBOMDeviationCustomFilter="+sMBOMDeviationCustomFilter+"&connectionProgram=emxMBOMPart:inlineCreateAndConnectPart&editRootNode=false&showApply="+varShowApply+"&postProcessJPO=emxPart:validateStateForApply&lookupJPO=emxPart:lookupEntries&insertNewRow=true&addJPO=addJPO&relType=EBOM&editRelationship=relationship_EBOM&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp";
	}
    else if(sBOMFilterVal=="planning")
	{    
        sURL = "../common/emxIndentedTable.jsp?type=<%=sType%>&expandProgram=emxPlanningMBOM:getPlanningMBOMForConsumption&table=MFGPlanningMBOMIndentedSummary&toolbar=MFGPlanningMBOMViewToolbar,MFGPlanningMBOMCustomToolBar,MFGPlanningMBOMChangeToolBar&header=emxMBOM.Command.BOMHeader&sortColumnName=Find Number,Sequence&sortDirection=ascending&HelpMarker=emxhelpbomplantview&PrinterFriendly=true&selection=multiple&portalMode=true&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&objectId="+objectID+"&suiteKey=MBOM&editRootNode=false&ENCBillOfMaterialsViewCustomFilter="+sBOMFilterVal+"&MBOMDeviationCustomFilter="+sMBOMDeviationCustomFilter+"&showApply=true"+"&connectionProgram=emxPlanningMBOM:connectPLBOMPendingMfgPart&postProcessJPO=emxMBOMPart:validateStateForApply&lookupJPO=emxMBOMPart:lookupEntries&addJPO=addJPO&showRMB=true&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp";
	}
	if(relId != null){
		sURL += "&relId="+relId;
	}
	
	sURL += "&selectHandler=crossHighlightENG"; 
	
	//window.parent.frames.location.href	= sURL;
	vFrame.frames.location.href	= sURL;
</script>

