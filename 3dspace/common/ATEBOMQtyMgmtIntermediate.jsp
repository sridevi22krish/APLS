 <%--  ATEBOMQtyMgmtIntermediate.jsp  -  Search dialog frameset
   This jsp was added as a part of ALSTOM customization
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>

<%@page import="matrix.util.MatrixException,com.matrixone.apps.domain.util.SetUtil,java.util.HashMap,java.util.Enumeration,java.util.Vector,java.util.Iterator,matrix.util.StringList,com.matrixone.apps.domain.util.MapList,com.matrixone.apps.domain.util.XSSUtil,com.matrixone.apps.domain.util.FrameworkUtil,com.matrixone.apps.domain.util.PropertyUtil,com.matrixone.apps.domain.util.MqlUtil"%>

<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>

<%
try{
  String[] strSelectedROWObjectsIDs = request.getParameterValues("emxTableRowId");
  if(strSelectedROWObjectsIDs==null || strSelectedROWObjectsIDs.length>1){
	  %>
	  <script language="Javascript">
		alert("Please, make a single selection");
		window.close();
	  </script>
	  <%
  } else {
	  StringList slObjectIDs = FrameworkUtil.split(strSelectedROWObjectsIDs[0], "|");
	  String objectId = (String)slObjectIDs.get(1);
	  String relId = (String)slObjectIDs.get(0);
	  //int intATQuantity = (int)Integer.parseInt(strATQuantity);
	  if (UIUtil.isNullOrEmpty(objectId)){
		   %>
				  <script language="Javascript">
					alert("Please select object as a Child  of DESIGN PART ");
					window.close();
				  </script>
		<%
	  } else {
		String strATQuantity = MqlUtil.mqlCommand(context, "print connection $1 select $2 dump", relId, "attribute[AT_C_Quantity].value");
		  
		DomainObject selectedObject = DomainObject.newInstance(context, objectId);
		String parentObjectId = MqlUtil.mqlCommand(context, "print connection $1 select $2 dump", relId, "from.id");
		DomainObject parent = DomainObject.newInstance(context, parentObjectId);
		
		String specID = parent.getInfo(context, "from["+PropertyUtil.getSchemaProperty(context, "relationship_PartSpecification")+"].to.id");
		String fromType = parent.getType(context);
		if(fromType!=null && !(fromType.equals(PropertyUtil.getSchemaProperty(context, "type_AT_C_DESIGN_PART")) || fromType.equals(PropertyUtil.getSchemaProperty(context, "type_AT_C_EXPECTED_PRODUCT")))){
			%>
			  <script language="Javascript">
				alert("Please select object with DESIGN PART or EXPECTED PRODUCT as parent");
				window.close();
			  </script>
			  <%
		}
		if(UIUtil.isNullOrEmpty(specID)){
			%>
			  <script language="Javascript">
				alert("Collaborate with physical has not been performed, please do this action before.");
				window.close();
			  </script>
			  <%
		} 
		
		//Modified as part of ALSTOM Cusotmization - Deformable customization - start
		MapList listOfSpecsToDisplay = new MapList();
		String sActualRole = context.getRole();
		String sActualUser = context.getUser();
		try{
	         String sContext = context.getRole().replaceFirst("ctx::", "");          
			 String[] asContext = sContext.split("\\.");		
			 String strContextOrganization = asContext[1];
			 String strContextCollabSpace = asContext[2];

			 String sUser = context.getUser();
			 String synchroUser = UINavigatorUtil.getI18nString("ATCredentials.Deformable.SynchroUser",	"ATCredentials", context.getLocale().getLanguage());
			 String synchroPassword = UINavigatorUtil.getI18nString("ATCredentials.Deformable.SynchroPassword",	"ATCredentials", context.getLocale().getLanguage());

			if(UIUtil.isNullOrEmpty(synchroPassword) || synchroPassword.equals("ATCredentials.Deformable.SynchroPassword")){
				ContextUtil.pushContext(context, synchroUser, "", "");
			} else {
				ContextUtil.pushContext(context, synchroUser, synchroPassword, "");
			}

			context.resetRole("ctx::VPLMProjectLeaderATSynchro."+strContextOrganization+"."+strContextCollabSpace);
			 
			DomainObject specObject = DomainObject.newInstance(context, specID);
			StringList selectStmts = new StringList(5);
	        selectStmts.addElement(DomainConstants.SELECT_ID);
	        selectStmts.addElement(DomainConstants.SELECT_TYPE);
	        selectStmts.addElement(DomainConstants.SELECT_NAME);
	        selectStmts.addElement(DomainConstants.SELECT_REVISION);
			selectStmts.addElement("to["+PropertyUtil.getSchemaProperty(context, "relationship_PartSpecification")+"].from.id");
	        StringList selectRelStmts = new StringList(2);
	        selectRelStmts.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);
	        selectRelStmts.addElement("attribute["+PropertyUtil.getSchemaProperty(context, "attribute_PLMInstance.PLM_ExternalID")+"].value");
			
	        StringBuffer sbTypes = new StringBuffer();
	        sbTypes.append(PropertyUtil.getSchemaProperty(context, "type_AT_ENG_DESIGN_PRODUCT")).append(",").append(PropertyUtil.getSchemaProperty(context, "type_AT_ENG_COS")).append(",").append(PropertyUtil.getSchemaProperty(context, "type_AT_ENG_STANDARD_PRODUCT"));
	        
			MapList listOfSpecs = specObject.getRelatedObjects(context,
	                PropertyUtil.getSchemaProperty(context, "relationship_AT_REF_Instance"),// relationship
	                // pattern
	                sbTypes.toString(), // object pattern
	                selectStmts, // object selects
	                selectRelStmts, // relationship selects
	                false, // to direction
	                true, // from direction
	                (short) 1, // recursion level
	                null, // object where clause
	                null); // relationship where clause
					
			if (listOfSpecs != null) {
				for (int i = 0; i < listOfSpecs.size(); i++) {
					Map obj      = (Map) listOfSpecs.get(i);
					String value = (String) obj.get("to["+PropertyUtil.getSchemaProperty(context, "relationship_PartSpecification")+"].from.id");
					if (!UIUtil.isNullOrEmpty(value)){
						if (objectId.equals(value)) {
							listOfSpecsToDisplay.add(obj);
						}
							
					}
						
				}
			
			}
		}
		catch(Exception e){
			e.printStackTrace();
			throw e;
		}
		finally{
			ContextUtil.popContext(context);
			context.resetRole(sActualRole);
		}
		//Modified as part of ALSTOM Cusotmization - Deformable customization - end
		int instanceSize = listOfSpecsToDisplay.size();
		String strInstanceSize = Integer.toString(instanceSize);
		strATQuantity = strATQuantity.substring(0, strATQuantity.indexOf("."));
		
		String sUOM = selectedObject.getAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_UnitofMeasure"));
		//String fromCurrent = selectedObject.getInfo(context, "to["+PropertyUtil.getSchemaProperty(context, "relationship_EBOM")+"].from.current");
		String fromCurrent = parent.getInfo(context, "current");
		String sPhysicalProduct = selectedObject.getInfo(context, "from["+PropertyUtil.getSchemaProperty(context, "relationship_PartSpecification")+"].to.id");
		//if(sPhysicalProduct!=null && !sPhysicalProduct.equals("") && intATQuantity==instanceSize){
		//fix for redmine 7792 - Issue on EBOM for Quantity - Start
		//added a error message if user tries to reduce quantity for a consumable part
		if(sUOM!=null && !sUOM.equals("EA (each)")){
			 %>
			  <script language="Javascript">
				alert("Consumable quantity should be only updated from EBOM table");
				window.close();
			  </script>
			<%
		 }
		//fix for redmine 7792 - Issue on EBOM for Quantity - End
		
		if(fromType!=null && !(fromType.equals(PropertyUtil.getSchemaProperty(context, "type_AT_C_DESIGN_PART")) || fromType.equals(PropertyUtil.getSchemaProperty(context, "type_AT_C_EXPECTED_PRODUCT")))){
			%>
			  <script language="Javascript">
				alert("Please select object with DESIGN PART or EXPECTED PRODUCT as parent");
				window.close();
			  </script>
			  <%
		} 
		if( sPhysicalProduct!=null && !sPhysicalProduct.equals("") && strATQuantity.equals(strInstanceSize) ){
		 if(instanceSize>1){
			 if(sUOM!=null && sUOM.equals("EA (each)")){
			  if(fromCurrent!=null && fromCurrent.equals("Preliminary")){
				  //String fromType = selectedObject.getInfo(context, "to["+PropertyUtil.getSchemaProperty(context, "relationship_EBOM")+"].from.type");
				  //String fromType = parent.getType(context);
				  if(fromType!=null && (fromType.equals(PropertyUtil.getSchemaProperty(context, "type_AT_C_DESIGN_PART")) || fromType.equals(PropertyUtil.getSchemaProperty(context, "type_AT_C_EXPECTED_PRODUCT")))){
					   %>
					  <script language="Javascript">
						var objectId = "<%=objectId%>";
						var relId = "<%=relId%>";
						document.location.href = "../common/emxIndentedTable.jsp?program=emxPart:quantityManagementALSTOM&table=ATSpecListTable&selection=multiple&submitURL=../common/ATDeleteInstancesAndUpdateQuantity.jsp&objectId="+objectId+"&relId="+relId;
					  </script>
					  <%
					} else {
					   %>
					  <script language="Javascript">
						alert("Please select object with DESIGN PART or EXPECTED PRODUCT as parent");
						window.close();
					  </script>
					  <%
					}
			  } else {
				  %>
				  <script language="Javascript">
					alert("Please select part with Parent in IN Work state");
					window.close();
				  </script>
				<%
			  }
			 } else {
			   %>
			  <script language="Javascript">
				alert("Please select object with EACH as UOM");
				window.close();
			  </script>
			  <%
			}
		 } else {
			 %>
		  <script language="Javascript">
			alert("Ooperation possible only if quanity is more than 1");
			window.close();
		  </script>
		  <%
		 }
	    } else {
		   %>
		  <script language="Javascript">
			alert("Collaborate with physical has not been performed, please do this action before.");
			window.close();
		  </script>
		  <%
	    } 
		  
	  }
	 
  }
}catch(Exception e){
	e.printStackTrace();
}
  
%>

