 <%--  ATDeleteInstancesAndUpdateQuantity.jsp  -  Search dialog frameset
   This jsp was added as a part of ALSTOM customization
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>

<%@page import="matrix.util.MatrixException,com.matrixone.apps.domain.util.SetUtil,java.util.HashMap,java.util.Enumeration,java.util.Vector,java.util.Iterator,matrix.util.StringList,com.matrixone.apps.domain.util.MapList,com.matrixone.apps.domain.util.XSSUtil,com.matrixone.apps.domain.util.FrameworkUtil,com.matrixone.apps.domain.util.PropertyUtil,com.matrixone.apps.domain.DomainConstants,com.matrixone.apps.domain.util.MqlUtil"%>

<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>

<%!
//public float returnMaxTreeOrder(Context context, String selectedObjectId)throws Exception{
public float returnMaxTreeOrder(Context context, String relToBeDeleted)throws Exception{
	float fMax = 0;
	String sActualRole = context.getRole();
	try{
		//HashMap programMap = (HashMap) JPO.unpackArgs(args);
		
		//String selectedObjectId = (String) programMap.get("objectId");
		//DomainObject selectedObject = DomainObject.newInstance(context, selectedObjectId);
		//Below is the way to retrieve Reference Id from Part selected
		//String specID = selectedObject.getInfo(context, "to["+PropertyUtil.getSchemaProperty(context, "relationship_EBOM")+"].from.from["+PropertyUtil.getSchemaProperty(context, "relationship_PartSpecification")+"].to.id");
		String specID = (String) MqlUtil.mqlCommand(context,"print connection $1 select $2 dump", relToBeDeleted, "from.id");
		
		DomainObject specObject = DomainObject.newInstance(context, specID);
		StringList selectStmts = new StringList(4);
        selectStmts.addElement(DomainConstants.SELECT_ID);
        selectStmts.addElement(DomainConstants.SELECT_TYPE);
        selectStmts.addElement(DomainConstants.SELECT_NAME);
        selectStmts.addElement(DomainConstants.SELECT_REVISION);
        StringList selectRelStmts = new StringList(2);
        selectRelStmts.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);
        selectRelStmts.addElement("attribute["+PropertyUtil.getSchemaProperty(context, "attribute_PLMInstance.V_TreeOrder")+"].value");
        StringBuffer sbTypes = new StringBuffer();
        sbTypes.append(PropertyUtil.getSchemaProperty(context, "type_AT_ENG_DESIGN_PRODUCT")).append(",").append(PropertyUtil.getSchemaProperty(context, "type_AT_ENG_COS")).append(",").append(PropertyUtil.getSchemaProperty(context, "type_AT_ENG_STANDARD_PRODUCT"));
        
        //ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"), "", "");
		
		String sContext = sActualRole.replaceFirst("ctx::", "");          
		String[] asContext = sContext.split("\\.");		
		String strContextOrganization = asContext[1];
		String strContextCollabSpace = asContext[2];

		String synchroUser = UINavigatorUtil.getI18nString("ATCredentials.Deformable.SynchroUser",	"ATCredentials", context.getLocale().getLanguage());
		String synchroPassword = UINavigatorUtil.getI18nString("ATCredentials.Deformable.SynchroPassword",	"ATCredentials", context.getLocale().getLanguage());

		if(UIUtil.isNullOrEmpty(synchroPassword) || synchroPassword.equals("ATCredentials.Deformable.SynchroPassword")){
			ContextUtil.pushContext(context, synchroUser, "", "");
		} else {
			ContextUtil.pushContext(context, synchroUser, synchroPassword, "");
		}		
		
		context.resetRole("ctx::VPLMProjectLeaderATSynchro."+strContextOrganization+"."+strContextCollabSpace);
			 		
		MapList listOfSpecs = specObject.getRelatedObjects(context,
                PropertyUtil.getSchemaProperty(context, "relationship_AT_REF_Instance"),// relationship
                // pattern
               	sbTypes.toString(), // object pattern
                selectStmts, // object selects
                selectRelStmts, // relationship selects
                true, // to direction
                true, // from direction
                (short) 1, // recursion level
                null, // object where clause
                null); // relationship where clause
		
		float fTemp;
		String value;
		Vector valVactor = new Vector();
		if (listOfSpecs != null) {
			for (int i = 0; i < listOfSpecs.size(); i++) {
				Map obj      = (Map) listOfSpecs.get(i);
				 value = (String) obj.get("attribute["+PropertyUtil.getSchemaProperty(context, "attribute_PLMInstance.V_TreeOrder")+"].value");
				if (UIUtil.isNotNullAndNotEmpty(value)){
					fTemp = Float.parseFloat(value);
					if(fTemp>fMax){
						fMax=fTemp;
					}
					
				}
			}
		}
		return fMax;
	}catch(Exception e){
		e.printStackTrace();
	}finally {
		ContextUtil.popContext(context);
		context.resetRole(sActualRole);
	}
	return fMax;		
}
%>

<%
try{
  String[] strSelectedROWObjectsIDs = request.getParameterValues("emxTableRowId");
  //String relID = "";
  //String relIDString = "";
  StringList slRelIDs = new StringList();
  String strParentObjectId = "";
  String strFatherId = null;
  String sActualRole = context.getRole();
  boolean isSynchroUserActivated = false;
  if(strSelectedROWObjectsIDs.length>=1){
	  String[] relsToBeDisconnceted = new String[strSelectedROWObjectsIDs.length];
	  for(int i=0; i<strSelectedROWObjectsIDs.length ; i++){
		  //relIDString = (String)strSelectedROWObjectsIDs[i];
		  slRelIDs = FrameworkUtil.split(strSelectedROWObjectsIDs[i], "|");
		  relsToBeDisconnceted[i]=(String)slRelIDs.get(0);
		  //strParentObjectId = (String)slRelIDs.get(2);
	  }
	  
	  //float maxTreeOrder = returnMaxTreeOrder(context, strParentObjectId);
	  //float maxTreeOrder = returnMaxTreeOrder(context, relsToBeDisconnceted[0]);
	  //maxTreeOrder++;
	  
	  //DomainObject parentObject = DomainObject.newInstance(context, strParentObjectId);
	  //String oldQuantity = (String) parentObject.getInfo(context, "to["+PropertyUtil.getSchemaProperty(context, "relationship_EBOM")+"].attribute["+PropertyUtil.getSchemaProperty(context, "attribute_AT_C_Quantity")+"].value");
	  String relIDforUpdate = request.getParameter("relId");
	  DomainRelationship relForQtyUpdate = DomainRelationship.newInstance(context, relIDforUpdate);
	  String oldQuantity = relForQtyUpdate.getAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_Quantity"));
	  
	  String[] relIds = { relIDforUpdate };
	  StringList slRelSelect = new StringList("from.id");
	  MapList mlPart = DomainRelationship.getInfo(context, relIds, slRelSelect);
	  
	  if(!mlPart.isEmpty() ){
		  Map mPart = (Map) mlPart.get(0);
		  strFatherId = (String) mPart.get("from.id");
	  }
	  
	  float quantityFloat = Float.parseFloat(oldQuantity);
	  int newQuantity = (int)quantityFloat - strSelectedROWObjectsIDs.length;
	  //if newQuantity<1 then it means user is trying to delete all instances which needs to be blocked 
		  if(newQuantity<1){
			  %>
			  <script language="Javascript">
				alert("All instances cannot be deleted");
				top.close();
			  </script>
		  <%
		  }else{
			if(strFatherId != null){

			  try{
				  			 				   
				  ContextUtil.startTransaction(context, true);
				    
				  //Synchro BOM - prevent any modification
				  Hashtable mSynchro = new Hashtable();
				  mSynchro.put("ROOTID", strFatherId);
				  mSynchro.put("objectId", strFatherId);
				  mSynchro.put("SYNC_DEPTH", "0");
				  mSynchro.put("SYNC_AND_TRANSFER", "no");
						  
				  String[] synchroBOMArgs = JPO.packArgs(mSynchro);
				//Modified to fix redmine 8680 - Use public API for synchronization - start
				  Map matrixObjIDvplmObjIDMapBOM  = (Map) JPO.invoke(context,"AT_emxDeformable", null, "launchEncapsulatedSynchroPublicAPI", synchroBOMArgs,	Map.class);
				//Modified to fix redmine 8680 - Use public API for synchronization - end
				  System.out.println("matrixObjIDvplmObjIDMapBOM : "+matrixObjIDvplmObjIDMapBOM);
				  
				  //Synchro CAD - delete CATIA instances
				  mSynchro.put("SYNC_AND_TRANSFER", "give");
				  String[] synchroCADArgs = JPO.packArgs(mSynchro);
				//Modified to fix redmine 8680 - Use public API for synchronization - start
				  Map matrixObjIDvplmObjIDMapCAD  = (Map) JPO.invoke(context,"AT_emxDeformable", null, "launchEncapsulatedSynchroPublicAPI", synchroBOMArgs,	Map.class);
				//Modified to fix redmine 8680 - Use public API for synchronization - end
				  System.out.println("matrixObjIDvplmObjIDMapCAD : "+matrixObjIDvplmObjIDMapCAD);
				  
				  String sContext = sActualRole.replaceFirst("ctx::", "");          
				  String[] asContext = sContext.split("\\.");		
				  String strContextOrganization = asContext[1];
				  String strContextCollabSpace = asContext[2];

				  String synchroUser = UINavigatorUtil.getI18nString("ATCredentials.Deformable.SynchroUser",	"ATCredentials", context.getLocale().getLanguage());
				  String synchroPassword = UINavigatorUtil.getI18nString("ATCredentials.Deformable.SynchroPassword",	"ATCredentials", context.getLocale().getLanguage());
				
				  if(UIUtil.isNullOrEmpty(synchroPassword) || synchroPassword.equals("ATCredentials.Deformable.SynchroPassword")){
					ContextUtil.pushContext(context, synchroUser, "", "");
				  } else {
					ContextUtil.pushContext(context, synchroUser, synchroPassword, "");
				  }			
				  isSynchroUserActivated = true;				  
				  context.resetRole("ctx::VPLMProjectLeaderATSynchro."+strContextOrganization+"."+strContextCollabSpace);
				  
				  
				  //Deformed Remove
				  HashMap hmArgs = new HashMap();
				  hmArgs.put( "relsToBeDisconnceted", relsToBeDisconnceted );
				  String[] args = JPO.packArgs( hmArgs );
				
				  JPO.invoke( context, "emxPart", null, "deleteDeformedInstancesForOriginatedInstances", args, String.class );	
				  
				  //Disconnection of selected CATIA instances
				  DomainRelationship.disconnect(context, relsToBeDisconnceted);
				  
				  //Synchro CAD-BOM
				  String strFatherProductId = (String) MqlUtil.mqlCommand(context,"print bus $1 select $2 dump;",strFatherId, "from[Part Specification].to[AT_ENG_PRODUCT].id");
				  System.out.println("strFatherProductId : "+strFatherProductId);
					
				  Vector<String> idList = new Vector<String>();
				  idList.add(strFatherProductId);

				  Hashtable<String, Object> synchArgumentsTable = new Hashtable<String, Object>();
				  synchArgumentsTable.put("IDLIST", idList);
				  synchArgumentsTable.put("SYNC_DEPTH", "0");
				  synchArgumentsTable.put("SYNC_AND_TRANSFER", "give");

				  String[] tmpargs = JPO.packArgs(synchArgumentsTable);

				  @SuppressWarnings("rawtypes")
				  Map matrixObjIDvplmObjIDMapBOM2 = JPO.invoke(context, "VPLMIntegBOMVPLMSynchronizeBase", null, "synchronizeFromVPMToMatrix", tmpargs, Map.class);
				  System.out.println("matrixObjIDvplmObjIDMapBOM2 : "+matrixObjIDvplmObjIDMapBOM2);						

				  //OOTB-Custo Quantity update
				  relForQtyUpdate.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_AT_C_Quantity"), String.valueOf(newQuantity));
				  relForQtyUpdate.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_Quantity"), String.valueOf(newQuantity));

				  ContextUtil.commitTransaction(context);
			  
			  }catch(Exception e){
				   String ExceptionMessage = e.getMessage();
				  %>
				  <script language="Javascript">
					alert("<%=ExceptionMessage%>");
					top.close();				
				  </script>
				  <%
				  e.printStackTrace();
				  ContextUtil.abortTransaction(context);
				  throw e;
			 }finally{
				 
				if(isSynchroUserActivated){
					ContextUtil.popContext(context);
					context.resetRole(sActualRole);
				}
				
			   %>
				  <script language="Javascript">
					top.opener.location.href=top.opener.location.href;
					top.close();
				  </script>
			   <% 
			 }
		  }
		}
	  } else {
	   %>
		  // <script language="Javascript">
			// alert("you have not made any selections");
			// top.close();
		  // </script>
		<%
  }
} catch (Exception e){
	e.printStackTrace();
}
 
  
%>

