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
String operationType = request.getParameter("operationType");
String partObjectId = request.getParameter("objectId");
try{
	final String TYPE_AT_C_STANDARD_DOC = PropertyUtil.getSchemaProperty(context, "type_AT_C_STANDARD_DOC");
	final String TYPE_AT_C_DOCUMENT = PropertyUtil.getSchemaProperty(context, "type_AT_C_DOCUMENT");
	final String TYPE_AT_ENG_DESIGN_PRODUCT = PropertyUtil.getSchemaProperty(context, "type_AT_ENG_DESIGN_PRODUCT");
	final String POLICY_DOCUMENTRELEASE = PropertyUtil.getSchemaProperty(context, "policy_Document");
	
	DomainObject domObjPart = DomainObject.newInstance(context, partObjectId);
	if(strParamValues==null || strParamValues.length==0){
		%>
		<script language="javascript">
		alert("Select one Reference Document or Specification");
		</script>
		<%
		strErrorMessage="Select one Reference Document or Specification";
	}else if(strParamValues.length>1){
		%>
		<script language="javascript">
		alert("Cannot select more than one Reference Document or Specification");
		</script>
		<%
		strErrorMessage="Cannot select more than one Reference Document or Specification";
	}else{
		StringList refDocSpecSelects = new StringList(9);
		refDocSpecSelects.add(DomainConstants.SELECT_ID);
		refDocSpecSelects.add(DomainConstants.SELECT_TYPE);
		refDocSpecSelects.add(DomainConstants.SELECT_NAME);
		refDocSpecSelects.add(DomainConstants.SELECT_VAULT);
		refDocSpecSelects.add(DomainConstants.SELECT_POLICY);
		refDocSpecSelects.add("last.id");
		refDocSpecSelects.add("last.current");
		refDocSpecSelects.add("last.previous.id");
		refDocSpecSelects.add("last.previous.current");
		refDocSpecSelects.add("last.attribute[AT_C_RENDITION].value");
		
		StringList partSelects = new StringList(4);
		partSelects.add(DomainConstants.SELECT_ID);
		partSelects.add(DomainConstants.SELECT_TYPE);
		partSelects.add(DomainConstants.SELECT_CURRENT);
		
		emxTableRowId = strParamValues[0];
		StringTokenizer tokenizer = new StringTokenizer(emxTableRowId, "|");
		
		if(tokenizer.countTokens()>1){
			String relId = tokenizer.nextToken();//first token is rel id, second token is ref doc/spec, throd token is part id
			String docSpecId = tokenizer.nextToken();
			String strObjectId = tokenizer.nextToken();
			String docSpecNewId;
			String rendition;
			
			//DomainObject partObject = DomainObject.newInstance(context, docSpecId);
			Map partMap = domObjPart.getInfo(context, partSelects);
			String partCurrent = (String) partMap.get(DomainConstants.SELECT_CURRENT);
			DomainObject refDocOrSpecObject = DomainObject.newInstance(context, docSpecId);
			Map refDocSpecMap = refDocOrSpecObject.getInfo(context, refDocSpecSelects);
			String type = (String)refDocSpecMap.get(DomainConstants.SELECT_TYPE);
			String name = (String)refDocSpecMap.get(DomainConstants.SELECT_NAME);
			String vault = (String)refDocSpecMap.get(DomainConstants.SELECT_VAULT);
			String policy = (String)refDocSpecMap.get(DomainConstants.SELECT_POLICY);
			
			//proceed only if type is not PRD or Standard Doc
			if(type!=null && type.equals(TYPE_AT_ENG_DESIGN_PRODUCT) ){
				%>
				<script language="javascript">
				alert("Physical Product shouldn’t be replaced");
				</script>
				<%
				strErrorMessage="Physical Product shouldn’t be replaced";
			} else if (type!=null &&  type.equals(TYPE_AT_C_STANDARD_DOC)){
				%>
				<script language="javascript">
				alert("Cannot select Standards for Replace");
				</script>
				<%
				strErrorMessage="Cannot select Standards for Replace";
			} else if (type!=null){
				//if operation type is AT_ReplaceLatestRevision, then replace latest revision of spec/doc
				if(operationType!=null && operationType.equals("AT_ReplaceLatestRevision")){
					System.out.println("operationType from AT_ReplaceLatestRevision==>"+operationType);
					docSpecNewId = (String)refDocSpecMap.get("last.id");//last revision of doc/spec
					rendition = (String)refDocSpecMap.get("last.attribute[AT_C_RENDITION].value");//check the rendition of the last doc/spec
					System.out.println("docSpecNewId from AT_ReplaceLatestRevision==>"+docSpecNewId);
					if(docSpecNewId.equals(docSpecId)){
						//last revision of spec or doc is already connected
						%>
						<script language="javascript">
						alert("Latest revision of document is already connected");
						</script>
						<%
						strErrorMessage="Latest revision of document is already connected";
						System.out.println("Latest revision of document is already connected from AT_ReplaceLatestRevision==>");
					}else{
						//if rendition is true then 
						if(rendition!=null && rendition.equalsIgnoreCase("true")){
							%>
							<script language="javascript">
							alert("Rendition document cannot be selected");
							</script>
							<%
							strErrorMessage="Rendition document cannot be selected";
						}else{
							System.out.println("docSpecNewId from AT_ReplaceLatestRevision==>"+docSpecNewId+connectType+partObjectId);
							DomainObject newRefDocOrSpecObject = DomainObject.newInstance(context, docSpecNewId);
							if(connectType.equals("relationship_PartSpecification") && !partCurrent.equals("Preliminary")){
								%>
								<script language="javascript">
								alert("Cannot replace specification if Part is NOT in \"In Work\" state");
								</script>
								<%
								strErrorMessage="Cannot replace specification if Part is NOT in \"In Work\" state";
							}else{
								DomainRelationship.disconnect(context, relId);
								DomainRelationship.connect(context, domObjPart, PropertyUtil.getSchemaProperty(context, connectType), newRefDocOrSpecObject);
							}	
						}
					}
				}else if(operationType!=null && operationType.equals("AT_ReplaceLatestReleased")){
					if(policy.equals(POLICY_DOCUMENTRELEASE)){
						StringList strlSelects = new StringList(5);
						strlSelects.add(DomainConstants.SELECT_TYPE);
						strlSelects.add(DomainConstants.SELECT_ID);
						strlSelects.add(DomainConstants.SELECT_NAME);
						strlSelects.add(DomainConstants.SELECT_POLICY);
						strlSelects.add("attribute[AT_C_RENDITION].value");
						
						String STATE_RELEASE =  PropertyUtil.getSchemaProperty(context,"policy", POLICY_DOCUMENTRELEASE, "state_RELEASED");
						String strWhereClause = "(current == \"" + STATE_RELEASE + "\") && !(next.current == \"" + STATE_RELEASE + "\")";

						MapList mapListParts = DomainObject.findObjects(context,
								  type,
								  name,
								  "*",
								  null,
								  vault,
								  strWhereClause,
								  false,
								  strlSelects);

						if (mapListParts.size() > 0){
							Map mapPart = (Map) mapListParts.get(0);
							docSpecNewId = (String) mapPart.get(DomainConstants.SELECT_ID);
							rendition = (String) mapPart.get("attribute[AT_C_RENDITION].value");
						} else {
							docSpecNewId="";
							rendition="";
							%>
							<script language="javascript">
							alert("There is no Released version of Document/Specification");
							</script>
							<%
						}
					}else{
						docSpecNewId = (String)refDocSpecMap.get("last.id");//last revision of doc/spec
						rendition = (String)refDocSpecMap.get("last.attribute[AT_C_RENDITION].value");//check the rendition of the last doc/spec
						System.out.println("else AT_ReplaceLatestReleased==>"+docSpecNewId+rendition);
					}
					if(docSpecNewId.equals(docSpecId)){
						//lastest released revision of spec or doc is already connected
						%>
						<script language="javascript">
						alert("Latest  released revision of document is already connected");
						</script>
						<%
					}else{
						//if rendition is true then 
						if(rendition.equalsIgnoreCase("true")){
							%>
							<script language="javascript">
							alert("Rendition document cannot be selected");
							</script>
							<%
						}else{
							DomainObject newRefDocOrSpecObject = DomainObject.newInstance(context, docSpecNewId);
							if(connectType.equals("relationship_PartSpecification") && !partCurrent.equals("Preliminary")){
								%>
								<script language="javascript">
								alert("Cannot replace specification if Part is NOT in \"In Work\" state");
								</script>
								<%
								strErrorMessage="Cannot replace specification if Part is NOT in \"In Work\" state";
							}else{
								DomainRelationship.disconnect(context, relId);
								//String sResult = MqlUtil.mqlCommand(context, "connect bus $1 relationship $2 to $3", partObjectId, , docSpecNewId);
								DomainRelationship.connect(context, domObjPart, PropertyUtil.getSchemaProperty(context, connectType), newRefDocOrSpecObject);
							}
						}
					}
				}else if(operationType!=null && operationType.equals("AT_ReplaceSelectedRevision")){
					if(connectType.equals("relationship_PartSpecification") ){
						if(!partCurrent.equals("Preliminary")){
							%>
							<script language="javascript">
							alert("Cannot replace specification if Part is NOT in \"In Work\" state");
							</script>
							<%
							strErrorMessage="Cannot replace specification if Part is NOT in \"In Work\" state";
						} else {
							%>
							<script language="javascript">
								window.location.href = "../common/emxFullSearch.jsp?field=TYPES=type_PartSpecification,type_TechnicalSpecification,type_Document,type_CADDrawing,type_CADModel,type_Viewable,type_SoftwareRequirementSpecification,type_DrawingPrint,type_AT_C_DOCUMENT:Policy!=policy_Version&table=ENCDocumentSummary&selection=multiple&submitAction=refreshCaller&submitURL=../common/ATReplaceExistingRefDocOrSpecWithNew.jsp&freezePane=Name,Title&srcDestRelName=relationship_PartSpecification&excludeOIDprogram=emxPartBase:excludeOIDPartSpecificationConnectedItems&HelpMarker=emxhelpfullsearch&relId=<%=relId%>&docSpecId=<%=docSpecId%>&objectId=<%=strObjectId%>&connectType=<%=connectType%>";
							</script>
							<%	
						}
					}else{
						%>
						<script language="javascript">
	    					window.location.href = "../common/emxFullSearch.jsp?field=TYPES=type_AT_C_DOCUMENT&showInitialResults=false&excludeOIDprogram=emxPart:excludeConnectedObjects&table=ENCPartSearchResult&selection=multiple&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../common/ATReplaceExistingRefDocOrSpecWithNew.jsp&relName=relationship_ReferenceDocument&from=true&formInclusionList=Description&relId=<%=relId%>&docSpecId=<%=docSpecId%>&objectId=<%=strObjectId%>&connectType=<%=connectType%>";
						</script>
						<%	
					}
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
