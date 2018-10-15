<%--  ATConnectDisconnectMaterialORProtectionToPart.jsp   - This jsp was added as part of ALSTOM Customization
This jsp connects/disconnects Preferred Material/Protection to the part
--%>

<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file="enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%
String[] strParamValues = request.getParameterValues("emxTableRowId"); 
String emxTableRowId;
String strErrorMessage = "";
String connectType = request.getParameter("connectType");
String operationType = request.getParameter("operationType");
try{
	final String RELATIONSHIP_AT_PART_MATERIAL = PropertyUtil.getSchemaProperty(context, "relationship_AT_PART_MATERIAL");
	final String RELATIONSHIP_AT_PART_PROTECTION = PropertyUtil.getSchemaProperty(context, "relationship_AT_PART_PROTECTION");
	for (int i = 0; i < strParamValues.length; i++) {
		emxTableRowId = strParamValues[i];
		StringTokenizer tokenizer = new StringTokenizer(emxTableRowId, "|");
		if(tokenizer.countTokens()>1){
			//operationType specifies whether connection or disconnection has to be performed
			   if(operationType!=null && operationType.equals("Disconnect")){
				   String relID = tokenizer.nextToken();
				   //connectType specifies the type of selected objects 
				   if(connectType!=null && connectType.equals("Material")){
					   DomainRelationship.disconnect(context, relID);
				   } else if(connectType!=null && connectType.equals("Protection")){
					   DomainRelationship.disconnect(context, relID);
				   }
			   } else {
				   String strMaterialORProtectionID = tokenizer.nextToken();
				   DomainObject materialORProtection = DomainObject.newInstance(context, strMaterialORProtectionID);
				   String strPartID = tokenizer.nextToken();
				   DomainObject part = DomainObject.newInstance(context, strPartID);
				   if(connectType!=null && connectType.equals("Material")){
					   DomainRelationship.connect(context, part, RELATIONSHIP_AT_PART_MATERIAL, materialORProtection);
				   } else if(connectType!=null && connectType.equals("Protection")){
					   DomainRelationship.connect(context, part, RELATIONSHIP_AT_PART_PROTECTION, materialORProtection);
				   }
			   }
		}

	} 

}catch(Exception e){
	e.printStackTrace();
	strErrorMessage = e.getMessage();
	throw e;
}
   

%>
<%@include file="emxNavigatorBottomErrorInclude.inc"%>

<script language="javascript">
var strErrorMessage = "<%=strErrorMessage%>";
if(strErrorMessage!="" || strErrorMessage!=" "){
	var pageToRefresh = getTopWindow().getWindowOpener();
	if (pageToRefresh) {
		getTopWindow().getWindowOpener().location.reload();
		getTopWindow().closeWindow();
	}
	else
	{
		getTopWindow().refreshTablePage();
	}
} else {
	alert(strErrorMessage);
	top.close();
}

</script>
