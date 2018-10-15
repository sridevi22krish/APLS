 <%--  AT_C_ENCSendToERPIntermediate.jsp  -  Search dialog frameset
   This jsp is added as a part of ALSTOM customization - [REQE2G_02  – New link “Send to ERP” ]
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>

<%@page import="java.util.Map,java.util.HashMap,java.util.Enumeration,matrix.util.StringList,com.matrixone.apps.domain.util.PropertyUtil,com.matrixone.apps.domain.DomainObject,com.matrixone.apps.domain.util.ContextUtil,matrix.db.BusinessObject"%>


<%
final String ATTRIBUTE_AT_C_SENDTOERP = PropertyUtil.getSchemaProperty("attribute_AT_C_SendToERP");
final String ATTRIBUTE_AT_C_KNOWBYERP = PropertyUtil.getSchemaProperty("attribute_AT_C_Known_By_ERP");
final String ATTRIBUTE_AT_C_SENDTOERP_INITIATED = "To Be Sent";
final String ATTRIBUTE_AT_C_SENDTOERP_DEFAULT = "None";
final String ATTRIBUTE_AT_C_SENDTOERP_SENT = "Sent";

String sStatusMsg = "";
try{
	
  //Push the context to User Agent
  ContextUtil.pushContext(context, "User Agent", null, null);
  
  String sSelectedObjectId = request.getParameter("objectId");
  if(UIUtil.isNotNullAndNotEmpty(sSelectedObjectId)){
	DomainObject doPartObj = DomainObject.newInstance(context, sSelectedObjectId);
	
	StringList slBusSelect = new StringList();
	slBusSelect.add("attribute["+ATTRIBUTE_AT_C_SENDTOERP+"]");
	 HashMap hmERPattributes = new HashMap();
     hmERPattributes.put(ATTRIBUTE_AT_C_SENDTOERP, ATTRIBUTE_AT_C_SENDTOERP_INITIATED);
     hmERPattributes.put(ATTRIBUTE_AT_C_KNOWBYERP, "TRUE");
	String sSendToERPStatus = "";
	
	if(doPartObj != null){
		Map mpPartInfo = doPartObj.getInfo(context, slBusSelect);
		sSendToERPStatus = (String)mpPartInfo.get("attribute["+ATTRIBUTE_AT_C_SENDTOERP+"]");
		//modified for QC5382 
		//if(!ATTRIBUTE_AT_C_SENDTOERP_INITIATED.equals(sSendToERPStatus)){
			//set the attribute SendToERPStatus value to To Be sent
			doPartObj.setAttributeValues(context,hmERPattributes);
		//}
		//Check if there is any previous revision for this part
		BusinessObject boPart = doPartObj.getPreviousRevision(context);
		if(boPart != null){
			String sPrevRevID = boPart.getObjectId(context);
			if(UIUtil.isNotNullAndNotEmpty(sPrevRevID)){
				DomainObject doPrevRevObj = DomainObject.newInstance(context, sPrevRevID);
				//Set the ERP status if It is not sent to GSI
				String sPrevRevERPStatus = doPrevRevObj.getInfo(context, "attribute["+ATTRIBUTE_AT_C_SENDTOERP+"]");
				String sPrevRevState = doPrevRevObj.getInfo(context, "current");
				if(sPrevRevState.equals("Release") ){
					 if(!ATTRIBUTE_AT_C_SENDTOERP_SENT.equals(sPrevRevERPStatus)) {
						 doPrevRevObj.setAttributeValues(context,hmERPattributes);
					 }
					
				} else {
						BusinessObject boPrev2 = doPrevRevObj.getPreviousRevision(context);
						if(boPrev2 != null){
						String sPrevRevID2 = boPrev2.getObjectId(context);
						if(UIUtil.isNotNullAndNotEmpty(sPrevRevID2)){
							DomainObject doPrevRevObj2 = DomainObject.newInstance(context, sPrevRevID2);
							//Set the ERP status if It is not sent to GSI
							String sPrevRevERPStatus2 = doPrevRevObj2.getInfo(context, "attribute["+ATTRIBUTE_AT_C_SENDTOERP+"]");
							String sPrevRevState2 = doPrevRevObj2.getInfo(context, "current");
							if(sPrevRevState2.equals("Release") ){
								 if(!ATTRIBUTE_AT_C_SENDTOERP_SENT.equals(sPrevRevERPStatus2)) {
									 doPrevRevObj2.setAttributeValues(context,hmERPattributes);
								 }
								
							}
						}
					}
				}
				
			}
		} 
	} 
  }
  sStatusMsg = "Part is subscribed to ERP successfully";
  
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

