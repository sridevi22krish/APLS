<%--  ATCloneEBOMStart.jsp   -  This page displays a list of parts.
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
   modified as part of ALSTOM - Redmine ticket 6893 - Replace Part in Bom doesn't keep quantity
--%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>

<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%@page import="matrix.util.MatrixException,com.matrixone.apps.domain.util.SetUtil,java.util.HashMap,java.util.Enumeration,java.util.Vector,java.util.Iterator,matrix.util.StringList,com.matrixone.apps.domain.util.MapList,com.matrixone.apps.domain.util.XSSUtil,com.matrixone.apps.domain.util.FrameworkUtil,com.matrixone.apps.domain.util.PropertyUtil,com.matrixone.apps.domain.DomainConstants,com.matrixone.apps.domain.util.MqlUtil,com.matrixone.apps.domain.DomainObject"%>

<%
String TYPE_AT_EXPECTED_PRODUCT = PropertyUtil.getSchemaProperty("type_AT_C_EXPECTED_PRODUCT");
String TYPE_AT_CONFIGURATION_ITEM = PropertyUtil.getSchemaProperty("type_AT_C_CONFIGURATION_ITEM");
String TYPE_AT_LOGICAL_NODE = PropertyUtil.getSchemaProperty("type_AT_C_LOGICAL_NODE");

String stop = "false";
String objectId = emxGetParameter(request,"objectId");
String[] selectedIds = emxGetParameterValues(request, "emxTableRowId");

if(selectedIds==null || selectedIds.length<1){
	//objectId = emxGetParameter(request,"objectId");
}else if(selectedIds!=null && selectedIds.length>1){
	stop = "true";
	String alert_NoMultiSelectionAllowed = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"ATEngineeringCentral.Command.NoMultiSelectionAllowed");
	%>
		<script language="JavaScript">
	 		alert("<%=alert_NoMultiSelectionAllowed%>");
	 		top.close();
	 	</script>
	<%
}else{
	StringTokenizer st = new StringTokenizer(selectedIds[0], "|");
	if(st.countTokens()>2){
		st.nextToken();
	}
	objectId = st.nextToken();
}
	
	DomainObject domObjPart = new DomainObject(objectId);
    User usrPartOrganization = domObjPart.getAltOwner1(context);
    User usrPartCollabSpace = domObjPart.getAltOwner2(context);
    
    String type = domObjPart.getInfo(context, DomainConstants.SELECT_TYPE);
          
    String strPartOrganization = usrPartOrganization.getName();
    String strPartCollabSpace = usrPartCollabSpace.getName();  
    
    String sContext = context.getRole().replaceFirst("ctx::", "");          
	 String[] asContext = sContext.split("\\.");
	 String strContextRole = asContext[0];
	 String strContextOrganization = asContext[1];
	 String strContextCollabSpace = asContext[2];
	 
	 String strLeaderRole = PropertyUtil.getSchemaProperty("role_VPLMProjectLeader");
	 if(type.equals(TYPE_AT_EXPECTED_PRODUCT) || type.equals(TYPE_AT_CONFIGURATION_ITEM)){
		 if( !(strPartOrganization.equals(strContextOrganization) && strContextRole.equals(strLeaderRole)) )
			{
			 stop = "true";
			 String alert_OnlyLeaderFromSameOrgAllowed = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"ATEngineeringCentral.Command.OnlyLeaderFromSameOrgAllowed");
				%>
					<script language="JavaScript">
	  					alert("<%=alert_OnlyLeaderFromSameOrgAllowed%>");
	  					top.close();
	 				</script>
				<%
			} 
	 }else if(type.equals(TYPE_AT_LOGICAL_NODE)){
		 if( !(strContextOrganization.equals("Architecture") && strContextRole.equals(strLeaderRole)) ){
			 stop = "true";
			 String alert_OnlyArchitectureLeaderFromSameOrgAllowed = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"ATEngineeringCentral.Command.OnlyArchitectureLeaderFromSameOrgAllowed");
			 %>
				<script language="JavaScript">
					alert("<%=alert_OnlyArchitectureLeaderFromSameOrgAllowed%>");
					top.close();
				</script>
			<%
		 }
	 }
	
	


try{
	if(stop.equals("false") && (objectId!=null || objectId!="")){
		String[] args = {objectId};
		JPO.invoke(context,"emxPart", null, "initAdvancedDuplicate", args);
%>	

		<script language="JavaScript">
		  document.location.href = "../common/emxIndentedTable.jsp?objectId=<%=objectId%>&insertNewRow=false&PrinterFriendly=false&massPromoteDemote=false&multiColumnSort=false&expandProgram=MGS_emxPart:getUM5EBOMsWithRelSelectables&editLink=false&mode=edit&applyURL=javascript:refreshViewAfterCloningBehaviourSave&table=ATCloneEBOMSB&suiteKey=EngineeringCentral&selection=multiple&header=ATEngineeringCentral.BOM.CloneEBOM&editRootNode=false&showApply=true";
		 </script>
 <%
 }
}catch(Exception e){
	e.printStackTrace();
}

%>
