 <%--  AT_C_ENCPublishToCLAMPIntermediate.jsp  -  Search dialog frameset
   This jsp is added as a part of ALSTOM customization - [REQP2C_02  – New link "Publish to CLAMP"]
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>

<%@page import="java.util.Map,java.util.HashMap,java.util.Enumeration,matrix.util.StringList,com.matrixone.apps.domain.util.PropertyUtil,com.matrixone.apps.domain.DomainObject,com.matrixone.apps.domain.util.ContextUtil,matrix.db.BusinessObject"%>


<%
final String ATTRIBUTE_AT_C_CLAMPTRANSFERSTATUS = PropertyUtil.getSchemaProperty("attribute_AT_C_CLAMPTransferStatus");
final String ATTRIBUTE_AT_C_CLAMPTRANSFERSTATUS_INITIATED = "Initiated";
final String ATTRIBUTE_AT_C_CLAMPTRANSFERSTATUS_NOT_INITIATED = "Not Initiated";

String sStatusMsg = "";
try{
	
  //Push the context to User Agent
  ContextUtil.pushContext(context, "User Agent", null, null);
  
  String sSelectedObjectId = request.getParameter("objectId");
  if(UIUtil.isNotNullAndNotEmpty(sSelectedObjectId)){
	DomainObject doPartObj = DomainObject.newInstance(context, sSelectedObjectId);
	
	StringList slBusSelect = new StringList();
	slBusSelect.add("attribute["+ATTRIBUTE_AT_C_CLAMPTRANSFERSTATUS+"]");
	
	String sCLAMPTransferStatus = "";
	
	if(doPartObj != null){
		Map mpPartInfo = doPartObj.getInfo(context, slBusSelect);
		sCLAMPTransferStatus = (String)mpPartInfo.get("attribute["+ATTRIBUTE_AT_C_CLAMPTRANSFERSTATUS+"]");
		
		if(!ATTRIBUTE_AT_C_CLAMPTRANSFERSTATUS_INITIATED.equals(sCLAMPTransferStatus)){
			//set the attribute CLAMP Transfer Status value to Initiated
			doPartObj.setAttributeValue(context, "AT_C_CLAMPTransferStatus", ATTRIBUTE_AT_C_CLAMPTRANSFERSTATUS_INITIATED);
		}
		//Check if there is any next revision for this part
		BusinessObject boPart = doPartObj.getNextRevision(context);
		if(boPart != null){
			String sNextRevId = boPart.getObjectId(context);
			
			if(UIUtil.isNotNullAndNotEmpty(sNextRevId)){
				DomainObject doNextRevObj = DomainObject.newInstance(context, sNextRevId);
				
				//Check if the next revision's CLAMP Transfer Status is 'Not Initiated' or not, if not set it to 'Not Initiated'
				String sNextRevCLAMPTransferStatus = doNextRevObj.getInfo(context, "attribute["+ATTRIBUTE_AT_C_CLAMPTRANSFERSTATUS+"]");
				if(!ATTRIBUTE_AT_C_CLAMPTRANSFERSTATUS_NOT_INITIATED.equals(sNextRevCLAMPTransferStatus)){
					doNextRevObj.setAttributeValue(context, "AT_C_CLAMPTransferStatus", ATTRIBUTE_AT_C_CLAMPTRANSFERSTATUS_NOT_INITIATED);
				}
			}
		}
	} 
  }
  sStatusMsg = "Part is published to CLAMP successfully";
  
}catch(Exception e){
	e.printStackTrace();
	sStatusMsg = e.getMessage();
}
finally {
	//Pop the context
	ContextUtil.popContext(context);
}

  
%>

<script language="javascript">
	var vStatus = "<%=sStatusMsg%>";
	if(vStatus != null && vStatus != ""){
		alert(vStatus);
	}
</script>

