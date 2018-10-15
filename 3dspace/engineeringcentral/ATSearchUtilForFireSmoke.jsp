<%--   ATSearchUtilForFireSmoke.jsp
--%>

<%-- Common Includes --%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>

<%@page import="com.matrixone.apps.engineering.PartFamily"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
String objectId = emxGetParameter(request, "objectId");
String relId = emxGetParameter(request, "relId");
//String strObjId = emxGetParameter(request, "objectId");
String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
if(selectedItems==null){
	selectedItems = emxGetParameterValues(request, "emxTableRowIdActual");
}
String toDoTask = emxGetParameter(request, "toDoTask");
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<%
	boolean bIsError = false;
	try {
		if (UIUtil.isNotNullAndNotEmpty(toDoTask) && toDoTask.equals("FandSStandardEdit")) {
			StringTokenizer st;
			String selectedDocId = "";
			if (selectedItems != null && selectedItems.length > 0) {
				st = new StringTokenizer(selectedItems[0], "|");
				selectedDocId = st.nextToken();
			}
			DomainRelationship ebomRel = DomainRelationship.newInstance(context, relId);
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_FnS_ID"), selectedDocId);
		} else if (UIUtil.isNotNullAndNotEmpty(toDoTask) && toDoTask.equals("FandSInstancesEdit")) {
			StringTokenizer st;
			String selectedPhysicalProductRelId = "";
			if (selectedItems != null && selectedItems.length > 0) {
				for (int i = 0; i < selectedItems.length; i++) {
					st = new StringTokenizer(selectedItems[i], "|");
					selectedPhysicalProductRelId+=st.nextToken();
					selectedPhysicalProductRelId+=",";
				}
			}
			DomainRelationship ebomRel = DomainRelationship.newInstance(context, relId);
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceFnS_ID"), selectedPhysicalProductRelId);
		}else if (UIUtil.isNotNullAndNotEmpty(toDoTask) && toDoTask.equals("SafetyStandardEdit")) {
			StringTokenizer st;
			String selectedDocId = "";
			if (selectedItems != null && selectedItems.length > 0) {
				st = new StringTokenizer(selectedItems[0], "|");
				selectedDocId = st.nextToken();
			}
			DomainRelationship ebomRel = DomainRelationship.newInstance(context, relId);
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_Safety_ID"), selectedDocId);
		} else if (UIUtil.isNotNullAndNotEmpty(toDoTask) && toDoTask.equals("SafetyInstancesEdit")) {
			StringTokenizer st;
			String selectedPhysicalProductRelId = "";
			if (selectedItems != null && selectedItems.length > 0) {
				for (int i = 0; i < selectedItems.length; i++) {
					st = new StringTokenizer(selectedItems[i], "|");
					selectedPhysicalProductRelId+=st.nextToken();
					selectedPhysicalProductRelId+=",";
				}
			}
			DomainRelationship ebomRel = DomainRelationship.newInstance(context, relId);
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceSafety_ID"), selectedPhysicalProductRelId);
		}else if(UIUtil.isNotNullAndNotEmpty(toDoTask) && toDoTask.equals("FandSStandardRemove")){
			DomainRelationship ebomRel = DomainRelationship.newInstance(context, relId);
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_FnS_ID"), "");
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceFnS_ID"), "");
		}else if(UIUtil.isNotNullAndNotEmpty(toDoTask) && toDoTask.equals("SafetyStandardRemove")){
			DomainRelationship ebomRel = DomainRelationship.newInstance(context, relId);
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_Safety_ID"), "");
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceSafety_ID"), "");
		}else if(UIUtil.isNotNullAndNotEmpty(toDoTask) && toDoTask.equals("FandSInstancesRemove")){
			DomainRelationship ebomRel = DomainRelationship.newInstance(context, relId);
			
			StringTokenizer st;
			String temp;
			String strExistingRefInsanceFnS = ebomRel.getAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceFnS_ID"));
			if (selectedItems != null && selectedItems.length > 0) {
				for (int i = 0; i < selectedItems.length; i++) {
					st = new StringTokenizer(selectedItems[i], "|");
					temp = st.nextToken();
					strExistingRefInsanceFnS = strExistingRefInsanceFnS.replaceAll(temp+",", "");
				}
			}
			
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceFnS_ID"), strExistingRefInsanceFnS);
		}else if(UIUtil.isNotNullAndNotEmpty(toDoTask) && toDoTask.equals("SafetyInstancesRemove")){
			DomainRelationship ebomRel = DomainRelationship.newInstance(context, relId);
			
			StringTokenizer st;
			String temp;
			String strExistingRefInsanceFnS = ebomRel.getAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceSafety_ID"));
			if (selectedItems != null && selectedItems.length > 0) {
				for (int i = 0; i < selectedItems.length; i++) {
					st = new StringTokenizer(selectedItems[i], "|");
					temp = st.nextToken();
					strExistingRefInsanceFnS = strExistingRefInsanceFnS.replaceAll(temp+",", "");
				}
			}
			
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceSafety_ID"), strExistingRefInsanceFnS);
		}else if(UIUtil.isNotNullAndNotEmpty(toDoTask) && toDoTask.equals("FandSInstancesAdd")){
			DomainRelationship ebomRel = DomainRelationship.newInstance(context, relId);
			
			StringTokenizer st;
			String temp;
			String strExistingRefInsanceFnS = ebomRel.getAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceFnS_ID"));
			if (selectedItems != null && selectedItems.length > 0) {
				for (int i = 0; i < selectedItems.length; i++) {
					st = new StringTokenizer(selectedItems[i], "|");
					temp = st.nextToken();
					strExistingRefInsanceFnS+=temp;
					strExistingRefInsanceFnS+=",";
				}
			}
			
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceFnS_ID"), strExistingRefInsanceFnS);
		}else if(UIUtil.isNotNullAndNotEmpty(toDoTask) && toDoTask.equals("SafetyInstancesAdd")){
			DomainRelationship ebomRel = DomainRelationship.newInstance(context, relId);
			
			StringTokenizer st;
			String temp;
			String strExistingRefInsanceFnS = ebomRel.getAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceSafety_ID"));
			if (selectedItems != null && selectedItems.length > 0) {
				for (int i = 0; i < selectedItems.length; i++) {
					st = new StringTokenizer(selectedItems[i], "|");
					temp = st.nextToken();
					strExistingRefInsanceFnS+=temp;
					strExistingRefInsanceFnS+=",";
				}
			}
			
			ebomRel.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_RefInstanceSafety_ID"), strExistingRefInsanceFnS);
		}else if(UIUtil.isNotNullAndNotEmpty(toDoTask) && toDoTask.equals("showFandSError")){
			%>
			<script language="javascript">
			alert("Define a contextual standard first");
			</script>
			<%
		}

	} catch (Exception e) {
		bIsError = true;
		e.printStackTrace();
		session.putValue("error.message", e.getMessage());
		//emxNavErrorObject.addMessage(e.toString().trim());
	} // End of main Try-catck block
%>
<script language="javascript">
top.opener.location.href = top.opener.location.href;
getTopWindow().closeWindow();
</script>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

