<%--  emxEngrReviseIntermediate.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
--%>

<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@include file="../common/emxNavigatorInclude.inc"%>

<%@page import="java.util.Map"%>
<%@page import="matrix.db.Policy"%>
<%@page import="matrix.db.BusinessObject"%>
<%@page import="matrix.util.StringList"%>
<%@page import="matrix.util.SelectList"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="com.matrixone.apps.engineering.ReleasePhaseManager"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%

final String sMarkupCurrent = PropertyUtil.getSchemaProperty("policy", DomainConstants.RELATIONSHIP_EBOM_MARKUP, "state_Applied");
String strApplyBGTPItemMarkup   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
		context.getLocale(),"ENCBOMGoToProduction.Confirm.ApplyBGTPItemMarkup");


	String strAction="";
	String objectId = emxGetParameter(request, "objectId");
	String typeStr = emxGetParameter(request,"type");
	strAction =emxGetParameter(request,"reviseAction");
	strAction = (strAction == null) ? "" : strAction;
	
	String showMode = emxGetParameter(request, "showMode"); // it will be slideIn when it is called from specifications revise command.
	if (showMode == null) {
		showMode = "";
	}
	
	DomainObject dmObj = new DomainObject(objectId);
	String srcObjType = dmObj.getInfo(context, com.matrixone.apps.domain.DomainConstants.SELECT_TYPE);
	String symbolicName = com.matrixone.apps.domain.util.FrameworkUtil.getAliasForAdmin(context,"type",srcObjType,true);
	if(strAction.equals("PartClone")){
	    response.setHeader("Cache-Control", "no-cache");
	    response.getWriter().write("@"+symbolicName+"@");   
	}
	
	SelectList objSelects = new SelectList(2);
	objSelects.add(DomainConstants.SELECT_ID);
	objSelects.add(DomainConstants.SELECT_CURRENT);
	String objWhere = "(attribute[" + EngineeringConstants.ATTRIBUTE_RELEASE_PHASE + "]==Development)" ;
	
	MapList sMarkupIDState = dmObj.getRelatedObjects(context, DomainConstants.RELATIONSHIP_EBOM_MARKUP, EngineeringConstants.TYPE_ITEM_MARKUP , objSelects, null, false, true, (short) 1, null, null);
	
	for(int i = 0; i < sMarkupIDState.size(); i++)
	{
		Map map = (Map)sMarkupIDState.get(i);
		String sMarkupId = (String)map.get("id");
		String sMarkupState = (String)map.get("current");
		boolean isBGTPMarkup = ReleasePhaseManager.isItemMarkupForSetToProduction(context,sMarkupId);
	
		if(isBGTPMarkup && !sMarkupCurrent.equals(sMarkupState))
		{
			%>
			 <script>
				    alert("<%=strApplyBGTPItemMarkup%>");
				    parent.close();
			 </script>
			<%	
		   return;
		}
		
	}
			
	String strRevs = MqlUtil.mqlCommand(context, "print bus $1 select $2 dump",objectId,"revisions");
	StringList sList = FrameworkUtil.split(strRevs,",");
	int len = sList.size();
	int highNum = 0;
	String highStr = null;
	
	for(int i=len-1;i>=0;i--){
	  String strVal = (String)sList.get(i);
	  try{
	      int intVal = Integer.parseInt(strVal);
	      if(highNum==0){
	          highNum = intVal;
	      }
	  }catch(NumberFormatException nfe){
	      if(highStr==null){
	          highStr = strVal;
	      }
	  }
	  if(highNum!=0 && highStr!=null){
	      break;
	  }
	}
	
	
	BusinessObject lastRevObj = dmObj.getLastRevision(context);
	String nextRev = lastRevObj.getNextSequence(context);
	String lastRevVault = lastRevObj.getVault();
	
	//Modified for Planning MBOM-Planning Required-Start
	SelectList sPartSelStmts = new SelectList(11);
	//Modified for Planning MBOM-Planning Required-End
	sPartSelStmts.addName();
	sPartSelStmts.addPolicy();
	sPartSelStmts.addDescription();
	sPartSelStmts.addType();
	sPartSelStmts.addRevision();
	sPartSelStmts.add("current");
	sPartSelStmts.add("last");
	sPartSelStmts.add("last.id");
	sPartSelStmts.add("last.attribute[Unit of Measure]");
    //Added for Planning MBOM-Planning Required-Start
    boolean isMBOMInstalled = EngineeringUtil.isMBOMInstalled(context);
	if(isMBOMInstalled) {
	sPartSelStmts.add("last."+EngineeringConstants.SELECT_PLANNING_REQUIRED);
	sPartSelStmts.add("last."+EngineeringConstants.SELECT_END_ITEM);
	sPartSelStmts.add("to["+EngineeringConstants.RELATIONSHIP_MANUFACTURING_RESPONSIBILITY+"]");
    }
	//Added for Planning MBOM-Planning Required-End
	
	Map objMap = dmObj.getInfo(context, (StringList)sPartSelStmts);
	
	String strSelectedPolicy = emxGetParameter(request, "Policy");
	String sPolicy  = (String)objMap.get("policy");
	String sType  = (String)objMap.get("type");
	String sName  = (String)objMap.get("name");
	String latestRevision = (String)objMap.get("last");
	String lastRevObjId = (String)objMap.get("last.id");
	//Added for Planning MBOM-Planning Required-Start
	String prevPlanningRequired = "";
	String prevEndItem = "";
	String isMRAttached = "";
    if(isMBOMInstalled) {
 	prevPlanningRequired = (String)objMap.get("last."+EngineeringConstants.SELECT_PLANNING_REQUIRED);
	prevEndItem = (String)objMap.get("last."+EngineeringConstants.SELECT_END_ITEM);
	isMRAttached = (String)objMap.get("to["+EngineeringConstants.RELATIONSHIP_MANUFACTURING_RESPONSIBILITY+"]");
	//Added for Planning MBOM-Planning Required-End
    }
    String prevUOM =(String)objMap.get("last.attribute[Unit of Measure]");
	DomainObject dmLastRevObj = new DomainObject(lastRevObjId);
	String hasRDO = dmLastRevObj.getInfo(context, "to["
			+ com.matrixone.apps.domain.DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY + "]");
	
    String formName = "type_ReviseSpecification";
    String createJPO = "emxPartDefinition:reviseSpecJPO";
    String headerStr = "emxFramework.Command.Revise";
    String preProcessJS = "preProcessInReviseSpec";
    String postProcessURL = "";
    String helpMarker = "emxhelpspeccreaterevision";
    if(dmObj.isKindOf(context, DomainObject.TYPE_PART)) {
		//modified for ALSTOM customization - start
        //formName = "type_RevisePart";
		formName = "AT_RevisePart";
		//modified for ALSTOM customization - end
        createJPO = "emxPart:revisePartJPO";
        preProcessJS = "preProcessInRevisePart";
        postProcessURL = "../engineeringcentral/AT_emxCreatePartRevisionPostProcess.jsp";
        helpMarker = "emxhelppartrevisions";
    }
	
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
//XSSOK
if ("<%=XSSUtil.encodeForJavaScript(context,showMode)%>" == "slideIn") { 
	//XSSOK
	//Modified for Planning MBOM-Planning Required-Start
    var sURL = "../common/emxCreate.jsp?lastRevPolicy=<xss:encodeForURL><%=sPolicy%></xss:encodeForURL>&policy=<xss:encodeForURL><%=sPolicy%></xss:encodeForURL>&lastRevVault=<xss:encodeForURL><%=lastRevVault%></xss:encodeForURL>&copyObjectId=<xss:encodeForURL><%=lastRevObjId%></xss:encodeForURL>&latestRevision=<xss:encodeForURL><%=latestRevision%></xss:encodeForURL>&highNum=<xss:encodeForURL><%=highNum%></xss:encodeForURL>&highStr=<xss:encodeForURL><%=highStr%></xss:encodeForURL>&form=<xss:encodeForURL><%=formName%></xss:encodeForURL>&header=<xss:encodeForURL><%=headerStr%></xss:encodeForURL>&type=<xss:encodeForURL><%=symbolicName%></xss:encodeForURL>&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=refreshCaller&createJPO=<xss:encodeForURL><%=createJPO%></xss:encodeForURL>&preProcessJavaScript=<xss:encodeForURL><%=preProcessJS%></xss:encodeForURL>&HelpMarker=<xss:encodeForURL><%=helpMarker%></xss:encodeForURL>&hasRDO=<xss:encodeForURL><%=hasRDO%></xss:encodeForURL>&suiteKey=EngineeringCentral&formFieldsOnly=true&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&partName=<xss:encodeForURL><%=sName%></xss:encodeForURL>&nextRev=<xss:encodeForURL><%=nextRev%></xss:encodeForURL>&reviseAction=true&createMode=ENG&postProcessURL=<xss:encodeForURL><%=postProcessURL%></xss:encodeForURL>&prevUOM=<xss:encodeForURL><%=prevUOM%></xss:encodeForURL>";
	 if("<%=isMBOMInstalled%>"=="true") {
	  sURL=sURL+"&prevPlanningRequired=<xss:encodeForURL><%=prevPlanningRequired%></xss:encodeForURL>&prevEndItem=<xss:encodeForURL><%=prevEndItem%></xss:encodeForURL>&isMRAttached=<xss:encodeForURL><%=isMRAttached%></xss:encodeForURL>";
	 }
    getTopWindow().showSlideInDialog(sURL, true);
    //Modified for Planning MBOM-Planning Required-End    
} else {
	//XSSOK
	//Modified for Planning MBOM-Planning Required-Start
	var sURL = "../common/emxCreate.jsp?lastRevPolicy=<xss:encodeForURL><%=sPolicy%></xss:encodeForURL>&policy=<xss:encodeForURL><%=sPolicy%></xss:encodeForURL>&lastRevVault=<xss:encodeForURL><%=lastRevVault%></xss:encodeForURL>&copyObjectId=<xss:encodeForURL><%=lastRevObjId%></xss:encodeForURL>&latestRevision=<xss:encodeForURL><%=latestRevision%></xss:encodeForURL>&highNum=<xss:encodeForURL><%=highNum%></xss:encodeForURL>&highStr=<xss:encodeForURL><%=highStr%></xss:encodeForURL>&form=<xss:encodeForURL><%=formName%></xss:encodeForURL>&header=<xss:encodeForURL><%=headerStr%></xss:encodeForURL>&type=<xss:encodeForURL><%=symbolicName%></xss:encodeForURL>&suiteKey=EngineeringCentral&formFieldsOnly=true&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=refreshCaller&createJPO=<%=createJPO%>&preProcessJavaScript=<xss:encodeForURL><%=preProcessJS%></xss:encodeForURL>&HelpMarker=<xss:encodeForURL><%=helpMarker%></xss:encodeForURL>&hasRDO=<xss:encodeForURL><%=hasRDO%></xss:encodeForURL>&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&targetLocation=popup&partName=<xss:encodeForURL><%=sName%></xss:encodeForURL>&nextRev=<xss:encodeForURL><%=nextRev%></xss:encodeForURL>&reviseAction=true&createMode=ENG&postProcessURL=<xss:encodeForURL><%=postProcessURL%></xss:encodeForURL>&prevUOM=<xss:encodeForURL><%=prevUOM%></xss:encodeForURL>";
	 if("<%=isMBOMInstalled%>"=="true") {
	  sURL=sURL+"&prevPlanningRequired=<xss:encodeForURL><%=prevPlanningRequired%></xss:encodeForURL>&prevEndItem=<xss:encodeForURL><%=prevEndItem%></xss:encodeForURL>&isMRAttached=<xss:encodeForURL><%=isMRAttached%></xss:encodeForURL>";
	 }
    window.location.href = sURL;
    	//Modified for Planning MBOM-Planning Required-end
}    
</script>
