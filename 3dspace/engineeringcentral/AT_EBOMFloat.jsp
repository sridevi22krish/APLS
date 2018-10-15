<%--  EBOMFloat.jsp -  This JSP used for all the util functionalities related to BOM Float functionality.
   Copyright (c) 1992-2014 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@page import="com.matrixone.json.JSONObject,com.matrixone.json.JSONArray"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.*"%>


<jsp:useBean id="floatOnEBOM" class="com.matrixone.apps.engineering.EBOMFloat" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%!

private String updateGlobalObjectListCache(Context context,Map tableData,Map relObjMap,String[] tableRowId) 
{	         
     TreeMap indexedObjectList = (TreeMap)tableData.get("IndexedObjectList");
     StringList tempList 	   = new StringList();
     
	 int iRowSize  = tableRowId.length; String relId,objectId,rowId;
	 String rowObjectIdsInfo = "";
	 for (int i = 0; i < iRowSize; i++) 
	 {
	     	tempList = FrameworkUtil.split(tableRowId[i], "|");
	     	
	     	relId	 = (String) tempList.get(0);
	     	objectId = (String) tempList.get(1);
	     	rowId    = (String) tempList.get(3);
			
	     	if(relObjMap.containsKey(relId)) {
	     		 objectId 	  = (String)relObjMap.get(relId);//To place floated rev id into cache
	             Map objInfo  = (Map)indexedObjectList.get(rowId);
	             if(objInfo != null) {
	                 //objInfo.put("id[connection]", relId); Not required
	                 objInfo.put("id", objectId);
	                 objInfo.put("OBJECTID_REPLACED", "TRUE");
	                 rowObjectIdsInfo = (rowObjectIdsInfo.length() > 0 ) ? rowObjectIdsInfo+"~"+rowId+"|"+objectId : rowId+"|"+objectId;
	             }
	        }
	 }
	 return rowObjectIdsInfo;
}
%>

<%!

private boolean checkIfParentIsEPAndInsMatIsApproved(Context context, String[] tableRowId) throws Exception
{	         
     StringList tempList 	   = new StringList();
     
	 int iRowSize  = tableRowId.length; String relId,objectId,rowId,parentId;
	 String rowObjectIdsInfo = "";
	 //Redmine #8771 Added try catch block and some checks for handling run time exceptions 
	 try {
		 for (int i = 0; i < iRowSize; i++) 
		 {
				tempList = FrameworkUtil.split(tableRowId[i], "|");
				
				relId	 = (String) tempList.get(0);
				objectId = (String) tempList.get(1);
				parentId = (String) tempList.get(2);
				rowId    = (String) tempList.get(3);
				//Redmine #8771 Added null checks for handling run time exceptions 
				if(!parentId.equalsIgnoreCase("") && parentId != null ) {
					DomainObject parent = DomainObject.newInstance(context, parentId);
					if( parent != null && parent.exists(context) ) {
						String parentType = parent.getInfo(context, DomainConstants.SELECT_TYPE);
						if( !relId.equalsIgnoreCase("") && relId != null ) {
							DomainRelationship selectRel = new DomainRelationship(relId);
							String instanceMaturity = selectRel.getAttributeValue(context, (String)PropertyUtil.getSchemaProperty(context, "attribute_MGS_Inst_Maturity"));
							
							if(parentType.equalsIgnoreCase("AT_C_EXPECTED_PRODUCT") && instanceMaturity.equalsIgnoreCase("RELEASED")){
								String strInstanceMaturiyReleasedwithEPParent = "Part under Expected Product with Instance Maturity as Approved cannot be Replaced/Removed";
								return true;
							}
						}
					}
				}
		 }
	 } catch (Exception ex) {
		 System.out.println("Exception in processing function checkIfParentIsEPAndInsMatIsApproved() "+ex.getMessage());
	 }
	 return false;
}
     

%>

<html>
<head>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script>

function isValidFrame(frameEle) {
        return (frameEle == null || frameEle == undefined || frameEle.location.href.indexOf("about:blank")>-1) ? false : true;
 }
 
function getValidFrame(frameToSearchWithIn,frameName) {         
        var reference   = findFrame(frameToSearchWithIn,frameName);

        if(!isValidFrame(reference)) {
                var portalFrame = findFrame(frameToSearchWithIn,"detailsDisplay")?findFrame(frameToSearchWithIn,"detailsDisplay"):findFrame(frameToSearchWithIn,"content") ;
                reference       = portalFrame;
        }
        return reference;
}

function processRMBRowAndCallReplaceAPIs(functionality,frameName,rowId,rmbRowData) {
	var isRevMgmt            =  "<%=floatOnEBOM.SUBMIT_FROM_REVISION_MANAGEMENT%>";
	var frameToSearchWithIn  = (isRevMgmt == functionality) ? getTopWindow().getWindowOpener() : getTopWindow();                    
	var frameToRefresh       = getValidFrame(frameToSearchWithIn,frameName);
	var rmbRow 				 = emxUICore.selectSingleNode(frameToRefresh.oXML,"/mxRoot/rows//r[@id='"+rowId+ "']");
	var alreadyChecked       = rmbRow.getAttribute("checked");
	if(!alreadyChecked) {
		rmbRow.setAttribute("checked", "checked");
		frameToRefresh.postDataStore(rmbRowData,"add");// In order to add emxTableRowId as hidden parameter		
	}
	
	switch (functionality) {
	    case "replaceWithLatestRevision":
	    	frameToRefresh.replaceWithLatestRevision();
	        break;
	    case "replaceWithLatestReleased":
	    	frameToRefresh.replaceWithLatestReleased();
	        break;
	    case "replaceWithSpecificRevision":
	    	frameToRefresh.replaceWithSpecificRevision();
	        break;
	   }
	if(!alreadyChecked) {
			rmbRow.setAttribute("checked", "");
			frameToRefresh.postDataStore(rmbRowData,"remove");
		}
	}
   

</script>
</head>
</html>

<%
    	String functionality     = emxGetParameter(request, "functionality");
        String objectId          = emxGetParameter(request, "objectId");
        String suiteKey          = emxGetParameter(request, "suiteKey");
        String type              = emxGetParameter(request, "type");
        String isFromRMB         = emxGetParameter(request, "isFromRMB");
        String isBOMPowerview    = emxGetParameter(request, "BOMMode");
        String isWhereUsed       = emxGetParameter(request, "partWhereUsed");   
        String isFromConfigBOM   = emxGetParameter(request, "fromConfigBOM");
        String frameName         = emxGetParameter(request, "frameName");
        String timeStamp 		 = emxGetParameter(request,"timeStamp");
        if(UIUtil.isNullOrEmpty(timeStamp)){ timeStamp = emxGetParameter(request,"fpTimeStamp");}
        
        if(UIUtil.isNullOrEmpty(frameName)) {  
				//Redmine #7470 HPQC #4935 Appending MGS to Frame Name
                //frameName  = ("true".equalsIgnoreCase(isFromConfigBOM)) ? "PUEUEBOM" : ("true".equalsIgnoreCase(isWhereUsed))? "ENCWhereUsed" : "ENCBOM";       
				frameName  = ("true".equalsIgnoreCase(isFromConfigBOM)) ? "PUEUEBOM" : ("true".equalsIgnoreCase(isWhereUsed))? "ENCWhereUsed" : "MGS_ENCBOM";       
        }
        HashMap tableData         		   = indentedTableBean.getTableData(timeStamp);
        String emxTableRowIds[]   		   = emxGetParameterValues(request, "emxTableRowId");     
        String replaceSelectedConfirmation = EnoviaResourceBundle.getProperty(context,floatOnEBOM.PROPERTY_SUITE,locale,"FloatOnEBOMManagement.Confirmation.ReplaceSelected");
        String replaceAllConfirmation      = EnoviaResourceBundle.getProperty(context,floatOnEBOM.PROPERTY_SUITE,locale,"FloatOnEBOMManagement.Confirmation.ReplaceAll");
        String selectionMandatory          = EnoviaResourceBundle.getProperty(context,floatOnEBOM.PROPERTY_SUITE,locale,"FloatOnEBOMManagement.ReplaceByRevision.selectionMandatory");

        String evolveInstanceNotAllowed = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",locale,"emxEngineeringCentral.EvolveInstance.NotAllowed");
        
        String confirmation   = "";     
        String errorMessage   = "";
        MapList data = new MapList();
        Map validatedMap = new HashMap();
        
        //BOM retrieval criteria
        short recurseToLevel = 1;
        boolean getFrom      = true;
        boolean getTo        = false;
        boolean latestFilterRequired = true;
        
        String refreshWholeView = "true";
        String rowObjectIdsData = "";

        //Where used criteria for getting Float data
        if(floatOnEBOM.TRUE.equalsIgnoreCase(isWhereUsed)) {

                getFrom      = false;
                getTo        = true;
                latestFilterRequired = false;
        }                                       
        
     	if ("TRUE".equalsIgnoreCase(isFromRMB)) {
         	StringList tempList  = FrameworkUtil.split( " "+emxTableRowIds[0], "|");
         	String RMBrowId      = (String) tempList.get(3);

%>
     	<script>
     		processRMBRowAndCallReplaceAPIs("<%=functionality%>","<%=frameName%>","<%=RMBrowId%>","<%=emxTableRowIds[0]%>");
     	</script>     	
<%
     	}
     	else if(floatOnEBOM.REPLACE_WITH_LATEST_REVISION.equalsIgnoreCase(functionality) || floatOnEBOM.REPLACE_WITH_LATEST_RELEASED.equalsIgnoreCase(functionality)
                                                                                                                           || floatOnEBOM.SUBMIT_FROM_REVISION_MANAGEMENT.equalsIgnoreCase(functionality) ) {
     		boolean boolCheckIfParentIsEPAndInsMatIsApproved = checkIfParentIsEPAndInsMatIsApproved(context, emxTableRowIds);
     		if(boolCheckIfParentIsEPAndInsMatIsApproved){
     			//String strInstanceMaturiyReleasedwithEPParent = "Released Part cannot be replaced for an EP";
     			errorMessage = "Part under Expected Product with Instance Maturity as Approved cannot be Replaced/Removed";
     		}else{
                                if(floatOnEBOM.SUBMIT_FROM_REVISION_MANAGEMENT.equalsIgnoreCase(functionality)) {
                                data =  floatOnEBOM.getTableRowMapList(context,emxTableRowIds); // gives rowId/Obj/Rel in each map
                        }
                        else {
                                if (emxTableRowIds == null) {//If no rows were selected hit the db, get all the data

                                        //In case of where used, criteria will differ
                                        data = floatOnEBOM.getBOMFloatData(context,objectId,recurseToLevel, getFrom, getTo,latestFilterRequired);
                                }
                                else {
                                        Map tableRowDataMap =  floatOnEBOM.getTableRowDataInStringList(emxTableRowIds); // Gives rowId/Obj/Rel in Stringlist format
                                        data = floatOnEBOM.getRelFloatData(context,(StringList)tableRowDataMap.get("RelId"));
                                }                               
                        }
                        
                        validatedMap = floatOnEBOM.validateData(context,data,functionality);
                        errorMessage = (String)validatedMap.get(floatOnEBOM.ERROR_MESSAGE);
                        //If no errors, then proceed for update
                        if(UIUtil.isNullOrEmpty(errorMessage)) {
                        	Map returnMap = floatOnEBOM.updateBOM(context,data);
                        	//Need this below one as if loop instead else loop for replace with selected revision refresh cases
                        	if(UIUtil.isNotNullAndNotEmpty((String)returnMap.get(floatOnEBOM.ERROR_MESSAGE)))  {
                        		refreshWholeView = "doNothing";//Error case dont refresh whole view instead just provide error notice
%>
								<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%                        		
                        	}                        	
                        	else if(UIUtil.isNullOrEmpty((String)returnMap.get(floatOnEBOM.ERROR_MESSAGE)) && (emxTableRowIds != null && !floatOnEBOM.SUBMIT_FROM_REVISION_MANAGEMENT.equalsIgnoreCase(functionality)) && ("ENG".equalsIgnoreCase(isBOMPowerview) || "true".equalsIgnoreCase(isFromConfigBOM))) {
                        		refreshWholeView = "false";                        		
                        		rowObjectIdsData = updateGlobalObjectListCache(context,(Map)tableData,(Map)returnMap.get("FLOATED_DATA"),emxTableRowIds);                        		
                        	}                        	
                        }
     		}
%>      
                        <script>        
                        var message         = "<xss:encodeForJavaScript><%=errorMessage%></xss:encodeForJavaScript>";
                        var functionality   = "<%=functionality%>";
                        var frameName       = "<%=frameName%>";                        
                        
                        var isRevMgmt            =  "<%=floatOnEBOM.SUBMIT_FROM_REVISION_MANAGEMENT%>";
                        var frameToSearchWithIn  = (isRevMgmt == functionality) ? getTopWindow().getWindowOpener() : getTopWindow();                    
                        var frameToRefresh               = getValidFrame(frameToSearchWithIn,frameName);
                        if(message != null && message != "null" && message != "") {
                                alert(message);
                        }
                        else {
                                   //REDMINE 7447 -START
									
									if(frameToRefresh==null){								   
								   var contentWindow = getTopWindow().findFrame(getTopWindow(),'detailsDisplay');
								   var currentURL = contentWindow.document.location.href;
								   var targetURL = "";
								   
								   if(currentURL.indexOf("DefaultCategory")!= -1){
										targetURL = updateURLParameter(currentURL,"DefaultCategory","ENCEBOMPowerViewCommand");
								   }else{
										targetURL = currentURL + '&DefaultCategory=ENCEBOMPowerViewCommand';
								   }
									contentWindow.document.location.href = targetURL;
									}
								else{								
								   //REDMINE 7447 -END
								   
								//frameToRefresh.emxEditableTable.refreshStructureWithOutSort();
                                if("<%=refreshWholeView%>" === "true") {                                	
                                	frameToRefresh.document.location.href = frameToRefresh.document.location.href;	
                                }
                                //else {
                                if("<%=refreshWholeView%>" === "false") {	
                                    var rowObjectIdsData = "<%=rowObjectIdsData%>";
                                    if(rowObjectIdsData != "" && (typeof rowObjectIdsData != 'undefined')) {
                                		var rowIdObjectIDsArr = rowObjectIdsData.split("~");
                                	    var objectId,sourceIdx,rowId,rowIdObjectID,tRow;
                                		for(var i = 0; i < rowIdObjectIDsArr.length; i++) {
                                		  rowIdObjectID = rowIdObjectIDsArr[i];
                                		  sourceIdx     = rowIdObjectID.indexOf("|");
                                		  rowId         = rowIdObjectID.substring(0,sourceIdx);
                                		  objectId      = rowIdObjectID.substring(sourceIdx+1,rowIdObjectID.length);
                                		  tRow 			= frameToRefresh.emxUICore.selectSingleNode(frameToRefresh.oXML,"/mxRoot/rows//r[@id='"+rowId+"']");
                                		  tRow.setAttribute("o", objectId);
                                	    }
                                	}	                            		                                	
                                	frameToRefresh.emxEditableTable.refreshStructureWithOutSort();
                                }                                 
                                if(isRevMgmt == functionality) {
                                        getTopWindow().closeWindow(); 
                                }
								}//REDMINE 7447
                        }
                        frameToRefresh.toggleProgress("hidden");
                        </script>
<%              
   }    
    else if(floatOnEBOM.REPLACE_WITH_SPECIFIC_REVISION.equalsIgnoreCase(functionality) || floatOnEBOM.REPLACE_WITH_SPECIFIC_REVISION_FOR_ALL.equalsIgnoreCase(functionality) || functionality.equals("evolveInstance")) {         

        boolean boolCheckIfParentIsEPAndInsMatIsApproved = false;        
                if (emxTableRowIds == null) {
                //If no rows were selected hit the db, get all the data                         
                        data = floatOnEBOM.getBOMFloatData(context,objectId,(short)0, getFrom, getTo,latestFilterRequired); // replaceWithSpecificRevisionForAll not available for where used
                }
                else {
                	boolCheckIfParentIsEPAndInsMatIsApproved = checkIfParentIsEPAndInsMatIsApproved(context, emxTableRowIds);
             		if(boolCheckIfParentIsEPAndInsMatIsApproved && !functionality.equals("evolveInstance")){
             			%>
             				<script type="text/javascript">
             				  alert("Part under Expected Product with Instance Maturity as Approved cannot be Replaced/Removed");
							</script>
             			<%
             			
             		}else{    
                		Map tableRowDataMap =  floatOnEBOM.getTableRowDataInStringList(emxTableRowIds); // Gives rowId/Obj/Rel in Stringlist format
                        data = floatOnEBOM.getRelFloatData(context,(StringList)tableRowDataMap.get("RelId"),(StringList)tableRowDataMap.get("RowId"),true);
                }     
     		}
		
		String jsonRevData    = floatOnEBOM.getJSONData(context,data);
		String sortColumnName = XSSUtil.encodeForURL(context,PropertyUtil.getSchemaProperty(context,"attribute_FindNumber")+",revision");
                        
		String urlToOpen   = "../common/emxIndentedTable.jsp?program=enoFloatOnEBOM:getRevisionSummary&frameName="+frameName+"&selectHandler=toggleSelectionInRevMgmt&sortColumnName="+sortColumnName+",Revision&suiteKey=EngineeringCentral&cancelLabel=emxEngineeringCentral.Button.Cancel&submitLabel=emxEngineeringCentral.Button.Submit&callbackFunction=submitFromRevisionManagement&portalMode=false&launched=false&table=ENCRevisionManagement&header=FloatOnEBOMManagement.Header.RevisionManagement&selection=multiple&massPromoteDemote=false&editRootNode=false&customize=true&displayView=details&revisionData="+ XSSUtil.encodeForURL(context, jsonRevData);

		if(functionality.equals("evolveInstance")){

			//System.out.println("data : "+data);                                 
			//System.out.println("jsonRevData : "+jsonRevData);

			if(data.size() > 0){
				Map mData = (Map) data.get(0);

				//System.out.println("mData : "+mData);

				String strFromId = (String) mData.get(DomainConstants.SELECT_FROM_ID);

				//System.out.println("strFromId : "+strFromId);

				if(strFromId != null && !strFromId.isEmpty()){

					StringList slRevIds = new StringList();

					DomainObject doFromObj = DomainObject.newInstance(context, strFromId);
					String strType = (String) doFromObj.getInfo(context, DomainConstants.SELECT_TYPE);
					String strCurrent = (String) doFromObj.getInfo(context, DomainConstants.SELECT_CURRENT);

					//System.out.println("strCurrent : "+strCurrent);

					String strTypeEP = PropertyUtil.getSchemaProperty(context, "type_AT_C_EXPECTED_PRODUCT");
					
					if(strType != null && (!(strType.equals(strTypeEP) && strCurrent.equals("Preliminary")))){
						%>
						<script language="Javascript">
							alert('<%=evolveInstanceNotAllowed%>');
							document.location.href = parent.document.location.href;	
    							getTopWindow().closeWindow(); 
						</script>
						<%
					}

					StringList objectSelects = new StringList(4);
					objectSelects.addElement(DomainConstants.SELECT_ID);
					objectSelects.addElement(DomainConstants.SELECT_NAME);
					objectSelects.addElement(DomainConstants.SELECT_TYPE);
					objectSelects.addElement(DomainConstants.SELECT_REVISION);
					objectSelects.addElement(DomainConstants.SELECT_CURRENT);

					StringList relationshipSelects = new StringList(2);
					relationshipSelects.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);
					relationshipSelects.addElement(DomainConstants.SELECT_RELATIONSHIP_TYPE);

					short limit = (short) 0;
					String objectWhere = null;
					String relationshipWhere = null;
					String relPattern = DomainConstants.RELATIONSHIP_EBOM;
					String typePattern = DomainConstants.TYPE_PART;
					MapList objList = (MapList) doFromObj.getRelatedObjects(context, relPattern, typePattern, objectSelects,
							relationshipSelects, getTo, getFrom, recurseToLevel, objectWhere, relationshipWhere, limit);

					//System.out.println("objList : "+objList);

					Iterator itObjList = objList.iterator();
					while(itObjList.hasNext()){
						Map mEBOMChild = (Map) itObjList.next();

						String strEBOMChildId = (String) mEBOMChild.get(DomainConstants.SELECT_ID);
						String strEBOMChildRev = (String) mEBOMChild.get(DomainConstants.SELECT_REVISION);

						DomainObject doEBOMChild = DomainObject.newInstance(context, strEBOMChildId);

						MapList mlRevisions = doEBOMChild.getRevisionsInfo( context, objectSelects, new StringList());
					        //System.out.println("revisionsTEST : "+mlRevisions);

						String strRevFromList = "";

					        //System.out.println("strEBOMChildRev : "+strEBOMChildRev);

						Iterator itmlRevisions = mlRevisions.iterator();
						while(itmlRevisions.hasNext() && !strEBOMChildRev.equals(strRevFromList)){
							Map mRevision = (Map) itmlRevisions.next();
							String strRevId = (String) mRevision.get(DomainConstants.SELECT_ID);
							strRevFromList = (String) mRevision.get(DomainConstants.SELECT_REVISION);
							
					       		//System.out.println("strRevId : "+strRevId);
							slRevIds.add(strRevId);

						}
					}

					//System.out.println("slRevIds after BOM : "+slRevIds);

					JSONObject revData		= new JSONObject(jsonRevData);

					//System.out.println("revData : "+revData);

					JSONArray rowItems      = revData.getJSONArray("revisionData");  

					//System.out.println("rowItems : "+rowItems);

					String strNewJsonRevData = "{\"revisionData\":[";

					if(rowItems != null) {
						int size = rowItems.length();			
						Map map;JSONObject rowItem;
						for(int i=0; i < size; i++) {
							map = new HashMap();
							rowItem = rowItems.getJSONObject(i);

							String strRevId = (String)rowItem.get(DomainConstants.SELECT_ID);
							//System.out.println("slRevIds after BOM : "+slRevIds);

							if(!slRevIds.contains(strRevId)){
								strNewJsonRevData+=(String)rowItem.toString()+",";
								slRevIds.add(strRevId);
							}
						}
					  }

					strNewJsonRevData = strNewJsonRevData.substring(0, strNewJsonRevData.length() - 1);

					strNewJsonRevData+="]}";

					//System.out.println("strNewJsonRevData : "+strNewJsonRevData);

					urlToOpen   = "../common/emxIndentedTable.jsp?program=enoFloatOnEBOM:getRevisionSummary&frameName="+frameName+"&selectHandler=toggleSelectionInRevMgmt&sortColumnName="+sortColumnName+",Revision&suiteKey=EngineeringCentral&cancelLabel=emxEngineeringCentral.Button.Cancel&submitLabel=emxEngineeringCentral.Button.Submit&callbackFunction=submitFromEvolveInstance&portalMode=false&launched=false&table=ENCRevisionManagement&header=FloatOnEBOMManagement.Header.RevisionManagement&selection=multiple&massPromoteDemote=false&editRootNode=false&customize=true&displayView=details&revisionData="+ XSSUtil.encodeForURL(context, strNewJsonRevData);
				}
			}
		}
        if(!boolCheckIfParentIsEPAndInsMatIsApproved && !functionality.equals("evolveInstance")){
        
%>

                <script>                                                                                
                getTopWindow().showModalDialog("<%=urlToOpen%>", "570","570","true");                
                </script>
<%              
       }else if(functionality.equals("evolveInstance")){
%>

                <script>                                                                                
                getTopWindow().showModalDialog("<%=urlToOpen%>", "570","570","true");                
                </script>
<%   
       } 
    }else if(functionality.equals("submitFromEvolveInstance")){

        data =  floatOnEBOM.getTableRowMapList(context,emxTableRowIds); // gives rowId/Obj/Rel in each map

	//System.out.println("emxTableRowIds : "+emxTableRowIds.length);
	//System.out.println("emxTableRowIds : "+emxTableRowIds[0]);
	//System.out.println("data : "+data);

	if(data.size() == 1){

		Map mData = (Map) data.get(0);
		//System.out.println("mData : "+mData);

		String strId = (String) mData.get(DomainConstants.SELECT_ID);
		//System.out.println("strId : "+strId);

		if(strId != null && !strId.isEmpty()){

			DomainObject newRevObj = DomainObject.newInstance(context, strId);

	  		String ATTRIBUTE_MGS_Inst_Maturity = PropertyUtil.getSchemaProperty(context, "attribute_MGS_Inst_Maturity");
			String strAttrUniqueID = PropertyUtil.getSchemaProperty(context, "attribute_AT_C_UniqueID");

			Map tableRowDataMap =  floatOnEBOM.getTableRowDataInStringList(emxTableRowIds); // Gives rowId/Obj/Rel in Stringlist format
	        	data = floatOnEBOM.getRelFloatData(context,(StringList)tableRowDataMap.get("RelId"),(StringList)tableRowDataMap.get("RowId"),true);

			//System.out.println("tableRowDataMap : "+tableRowDataMap);
			//System.out.println("data : "+data);

			if(emxTableRowIds.length == 1){
				mData = (Map) data.get(0);
				//System.out.println("mData : "+mData);
				
				Map relAttrMap = DomainRelationship.getAttributeMap(context, (String)mData.get(DomainConstants.SELECT_RELATIONSHIP_ID));
				//System.out.println("relAttrMap : "+relAttrMap);

				String strFromid = (String)mData.get(DomainConstants.SELECT_FROM_ID);
				//System.out.println("strFromid : "+strFromid);

				try{
					ContextUtil.startTransaction(context,true);

					if(strFromid != null && !strFromid.isEmpty()){
						DomainObject fromObject = DomainObject.newInstance(context, strFromid);
						//System.out.println("fromObject : "+fromObject);
						DomainRelationship newRel = DomainRelationship.connect(context, fromObject, DomainConstants.RELATIONSHIP_EBOM, newRevObj);
						newRel.setAttributeValues(context, relAttrMap);
						newRel.setAttributeValue(context, ATTRIBUTE_MGS_Inst_Maturity, "IN_WORK");

						DomainRelationship initRel = new DomainRelationship((String)mData.get(DomainConstants.SELECT_RELATIONSHIP_ID));
						String strUniqueId = initRel.getAttributeValue(context, strAttrUniqueID);

						if(strUniqueId != null){
							if(strUniqueId.isEmpty()){
								String strPhysicalIdRequest = "print connection $1 select $2 dump $3";
								String strPhysicalIdResult = MqlUtil.mqlCommand(context,strPhysicalIdRequest, (String)mData.get(DomainConstants.SELECT_RELATIONSHIP_ID),"physicalid","");

								if(strPhysicalIdResult != null && !strPhysicalIdResult.isEmpty()){
									newRel.setAttributeValue(context, strAttrUniqueID, strPhysicalIdResult);
								}
							}else{
								newRel.setAttributeValue(context, strAttrUniqueID, strUniqueId);
							}
						}						
					}

					ContextUtil.commitTransaction(context);

				}catch(Exception e){
					e.printStackTrace();
					ContextUtil.abortTransaction(context);
				}
			}
		}
	}
%>
<script language="Javascript">
	//alert(document.location.href);
	//alert(parent.document.location.href);
                   	
	var frameName = "<%=frameName%>";    
    var functionality = "<%=functionality%>";    

    //alert(frameName);   
    //alert(functionality);                                     
                        
     var isRevMgmt = "submitFromEvolveInstance";
     var frameToSearchWithIn = (isRevMgmt == functionality) ? getTopWindow().getWindowOpener() : getTopWindow();                    
     var frameToRefresh = getValidFrame(frameToSearchWithIn,frameName);

	//alert(frameToRefresh);

	frameToRefresh.document.location.href = frameToRefresh.document.location.href;	
    getTopWindow().closeWindow(); 

</script>
<%
    }
%>      