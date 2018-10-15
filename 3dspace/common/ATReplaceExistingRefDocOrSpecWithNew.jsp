<%--  ATConnectDisconnectMaterialORProtectionToPart.jsp   - This jsp was added as part of ALSTOM Customization
This jsp connects/disconnects Preferred Material/Protection to the part
--%>

<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file="enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship,com.matrixone.apps.engineering.PartDefinition"%>
<%
String[] strParamValues = request.getParameterValues("emxTableRowId"); 
String emxTableRowId;
String strErrorMessage = "";
String connectType = request.getParameter("connectType");
String partObjectId = request.getParameter("objectId");
String docSpecId = request.getParameter("docSpecId");
String relId = request.getParameter("relId");

try{
	emxTableRowId = strParamValues[0];
	StringTokenizer tokenizer = new StringTokenizer(emxTableRowId, "|");
	
	if(tokenizer.countTokens()>1){
		//tokenizer.nextToken();
		String docSpecNewId = tokenizer.nextToken();
		String rendition;
		
		DomainObject domObjPart = DomainObject.newInstance(context, partObjectId);
		DomainObject newRefDocOrSpecObject = DomainObject.newInstance(context, docSpecNewId);
		rendition = newRefDocOrSpecObject.getAttributeValue(context, "AT_C_Rendition");
		
		if(rendition.equalsIgnoreCase("true")){
			%>
			<script language="javascript">
				alert("Rendition document cannot be selected");
			</script>
			<%
			strErrorMessage="Rendition document cannot be selected";
		}else{
			DomainRelationship.disconnect(context, relId);
			DomainRelationship.connect(context, domObjPart, PropertyUtil.getSchemaProperty(context, connectType), newRefDocOrSpecObject);
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
