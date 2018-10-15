<%--  ECMFullSearchPreProcess.jsp

	Copyright (c) 1992-2015 Dassault Systemes.
	All Rights Reserved.
	This program contains proprietary and trade secret information of MatrixOne, Inc.
	Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
	
	ECMFullSearchPreProcess.jsp which gets the search types from the DB, and forms the search url, used in all addexisting operations in ECM.
	Modification Hisotry
	--------------------
	Suresh S;1.0;June 5, 2017;Modified for REQ08.005
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "ECMDesignTopInclude.inc"%>
<%@page import="com.matrixone.apps.engineering.EngineeringConstants,com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
				
<jsp:useBean id="changeUtil" class="com.dassault_systemes.enovia.enterprisechangemgt.util.ChangeUtil" scope="session"/>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<%!
//Added the method for REQ 08.005
public String isChangeActionAllowed (Context context,String[] selectedItems) throws Exception {
			boolean isLNObj = false;
			boolean isECDevObj = false;

			String sLNType = PropertyUtil.getSchemaProperty(context, "type_AT_C_LOGICAL_NODE");
			StringList slObject = new StringList();
			DomainObject dobj;
			String serr = "";
					
			slObject.add(DomainConstants.SELECT_NAME);
			slObject.add(DomainConstants.SELECT_TYPE);
			slObject.add(DomainConstants.SELECT_ID);
			MapList mlObjects = new MapList();
						
			String[] ObjectIds = new String[selectedItems.length];
			for(int iTemp=0;iTemp < selectedItems.length;iTemp++) {
				
				StringList strlObjectIdList = FrameworkUtil.split(" "+selectedItems[iTemp],"|");
				String stempid = (String)strlObjectIdList.elementAt(1);
				ObjectIds[iTemp] = stempid;
			}
			if (selectedItems.length > 0) {
			    mlObjects = DomainObject.getInfo(context,ObjectIds,slObject);
			} 		
			Iterator itr = mlObjects.iterator();
			while (itr.hasNext()) {
				Map map = (Map) itr.next();
				String stemptype = (String) map.get(DomainConstants.SELECT_TYPE);
				String stempId = (String) map.get(DomainConstants.SELECT_ID);
								
				if (stemptype!= null && stemptype.equals(sLNType)){
					isLNObj=true;
			    }else if(isECDevelopmentPart(context, stempId)){
					isECDevObj = true;
			    }
			}
			if (isLNObj) {
				serr = "Action you have chosen is not allowed for this type.";
			}
			
			if(isECDevObj){
				serr += EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "AT.ExceptionPart.ErrorMessage3");
			}
			return serr;
	}
	
	
	public boolean isECDevelopmentPart(Context context, String objectId) throws Exception {
			
		boolean isECDevelopmentPart = false;
			
		//System.out.println("objectId : "+objectId);	
		
		DomainObject domObjPart = DomainObject.newInstance(context, objectId);
		
		//System.out.println("domObjPart : "+domObjPart);	
		
		String strReleasePhase = domObjPart.getInfo(context, "attribute["+PropertyUtil.getSchemaProperty(context, "attribute_ReleasePhase")+"]");
		String strPolicy = domObjPart.getInfo(context, DomainConstants.SELECT_POLICY);
		
		//System.out.println("strReleasePhase : "+strReleasePhase);
		//System.out.println("strPolicy : "+strPolicy);
							
		if(strReleasePhase != null && strPolicy != null && DomainConstants.POLICY_EC_PART.equals(strPolicy) && EngineeringConstants.DEVELOPMENT.equals(strReleasePhase)){
			isECDevelopmentPart = true;
		}
		
		return isECDevelopmentPart;
	}
%>

<%
	String functionality    = emxGetParameter(request,"functionality");
	String objectId         = emxGetParameter(request, "objectId");
	String isFrom			= emxGetParameter(request, "isFrom");
	String targetRelName	= emxGetParameter(request, "targetRelName");
	String suiteKey         = emxGetParameter(request, "suiteKey");
	String languageStr      = context.getSession().getLanguage();
	String emxTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
	String currentCriteria  = emxGetParameter(request, "CURRENT");
	currentCriteria  		= !changeUtil.isNullOrEmpty(currentCriteria) ? currentCriteria : ""; 
		
	boolean fullSearch = (UIUtil.isNotNullAndNotEmpty((String)emxGetParameter(request, "isFullSearch")));
	String excludeTypes        = emxGetParameter(request, "excludeTypes");
	StringList excludeTypeList = !changeUtil.isNullOrEmpty(excludeTypes) ? FrameworkUtil.splitString(excludeTypes,",") : new StringList();
	String proposedChangeAllowedTypes = "";
	String searchTypes 	       = "";
	//REDMINE 7689 START
/*	String searchURL 		   = "../common/emxFullSearch.jsp?showInitialResults=false&HelpMarker=emxhelpfullsearch&suiteKey="+suiteKey+"&";
*/
	String searchURL 		   = "../common/emxFullSearch.jsp?showInitialResults=true&HelpMarker=emxhelpfullsearch&suiteKey="+suiteKey+"&";
	//REDMINE 7689 END
	String excludeOIDprogram   = emxGetParameter(request, "excludeOIDprogram");
	excludeOIDprogram		   = !changeUtil.isNullOrEmpty(excludeOIDprogram) ? excludeOIDprogram : ""; 
	String targetRelActualName = !changeUtil.isNullOrEmpty(targetRelName) ? PropertyUtil.getSchemaProperty(context,targetRelName) : ""; 

	
	StringList objSelects = new StringList(2);
	Map orgMap = null;
	String orgNameSelect   = ChangeConstants.SELECT_ORGANIZATION;
	String orgIdSelect     = ChangeConstants.SELECT_ORGANIZATION+".id";
	String errorMessage  = "";
	long timeinMilli = System.currentTimeMillis();
	Locale locale    = context.getLocale();
	String itemConnectedToChangeAlready = EnoviaResourceBundle.getProperty(context,ChangeConstants.RESOURCE_BUNDLE_ENTERPRISE_STR, locale,"EnterpriseChangeMgt.Warning.ContextItemAlreadyConnectedWarning");
	String portalFrame = emxGetParameter(request, "portalFrame");
	portalFrame 	= (UIUtil.isNullOrEmpty(portalFrame) || "undefined".equalsIgnoreCase(portalFrame)) ? "listHidden" : portalFrame;
	
	//System.out.println("functionality : "+functionality);
	
	try { 
	    ContextUtil.startTransaction(context,true);
		
		
	    //For IR-430176
	    if("AddToNewChange".equalsIgnoreCase(functionality)||
	    		"AddToNewChangeRequest".equalsIgnoreCase(functionality)||
	    		"AddToNewChangeAction".equalsIgnoreCase(functionality)||
	    		"AddToExistingChange".equalsIgnoreCase(functionality)||
	    		"AddToExistingChangeRequest".equalsIgnoreCase(functionality)||
	    		"AddToExistingChangeAction".equalsIgnoreCase(functionality)){
	    	StringList affeObjList = changeUtil.getObjectIdsFromTableRowID((String[])emxTableRowIds);
	    	Map mapControlledItems = ChangeUtil.checkForChangeControlledItems(context, affeObjList);
	    	String strInvalidAffectedItems = EnoviaResourceBundle.getProperty(context, ChangeConstants.RESOURCE_BUNDLE_ENTERPRISE_STR,locale,"EnterpriseChangeMgt.Message.InvalidRelatedItem");
	    	errorMessage = mapControlledItems.get("ErrorMsg").toString();
	    	if(!errorMessage.isEmpty()){
	    		errorMessage = strInvalidAffectedItems+":"+errorMessage;
	    	}
			errorMessage = isChangeActionAllowed(context,emxTableRowIds);	//Added for REQ 08.005			
	    }
		if ("AddExisting".equalsIgnoreCase(functionality)) 
		{
			searchTypes  =  changeUtil.getRelationshipTypes(context,targetRelName,true,false,excludeTypeList);
			searchTypes  =  !"".equals(currentCriteria) ? searchTypes+":CURRENT="+currentCriteria : searchTypes;
			
			excludeOIDprogram = !"".equals(excludeOIDprogram) ? excludeOIDprogram : "enoECMChangeUtil:excludeConnectedObjects";
			searchTypes       =  !"".equals(currentCriteria) ? searchTypes+":CURRENT="+currentCriteria : searchTypes;
			searchURL        += "table=ECMGeneralSearchResults&selection=multiple&excludeOID="+objectId+"&showSavedQuery=True&excludeOIDprogram="+excludeOIDprogram+"&searchCollectionEnabled=True&formInclusionList=Description&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=refreshCaller";		
		}
		else if("CAAffectedItemsAddExisting".equalsIgnoreCase(functionality))
		{
			//Modeler API to get the allowed seach type
			searchTypes=changeUtil.getListOfAllowedTypesForGivenCategory(context, ChangeConstants.PROPOSEDACTIVITY);
			searchURL	+= "&table=ECMGeneralSearchResults&excludeOIDprogram=enoECMChangeAction:excludeAffectedItems&selection=multiple&showSavedQuery=True&searchCollectionEnabled=True&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=refreshCaller";
		}
		else if("AffectedItemsAddExisting".equalsIgnoreCase(functionality)) 
		{
			//Modeler API to get the allowed seach type
			
			searchTypes=changeUtil.getListOfAllowedTypesForGivenCategory(context, ChangeConstants.PROPOSEDACTIVITY);
			searchURL	+= "&table=ECMGeneralSearchResults&excludeOIDprogram=enoECMChangeOrder:excludeAffectedItems&selection=multiple&showSavedQuery=True&searchCollectionEnabled=True&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=refreshCaller";
		}
		else if("AffectedItemsAddExistingForCR".equalsIgnoreCase(functionality)) 
		{							
			//Modeler API to get the allowed seach type
			searchTypes=changeUtil.getListOfAllowedTypesForGivenCategory(context, ChangeConstants.PROPOSEDACTIVITY);
			searchURL	+= "&table=ECMGeneralSearchResults&excludeOIDprogram=enoECMChangeOrder:excludeAffectedItems&selection=multiple&showSavedQuery=True&searchCollectionEnabled=True&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=refreshCaller";
		}
		else if("MoveToExistingCO".equalsIgnoreCase(functionality)) 
		{	
			
			ChangeOrder changeOrder = new ChangeOrder(objectId);
			String crId =  changeOrder.getInfo(context, "to["+ChangeConstants.RELATIONSHIP_CHANGE_ORDER+"].from.id");
			session.setAttribute("sourceAffectedItemRowIds",emxTableRowIds);
			if(UIUtil.isNullOrEmpty(crId)){
				searchTypes    = "type_ChangeOrder:CURRENT=policy_FormalChange.state_Propose,policy_FormalChange.state_Prepare:Organization=" + changeOrder.getInfo(context, orgNameSelect);
				searchURL	  += "&table=ECMGeneralSearchResults&hideHeader=true&selection=single&showSavedQuery=True&excludeOID="+objectId+"&HelpMarker=emxhelpfullsearch&searchCollectionEnabled=True&submitURL=../enterprisechangemgt/ECMDisconnectProcess.jsp?submitAction=refreshCaller";
			} else{
				searchTypes    = "type_ChangeOrder:POLICY=policy_FasttrackChange:CURRENT=policy_FasttrackChange.state_Prepare:Organization=" + changeOrder.getInfo(context, orgNameSelect);
				searchURL	  += "&table=ECMGeneralSearchResults&includeOIDprogram=enoECMChangeRequest:includeCOOIDs&excludeOID="+objectId+"&hideHeader=true&selection=single&showSavedQuery=True&HelpMarker=emxhelpfullsearch&searchCollectionEnabled=True&submitURL=../enterprisechangemgt/ECMDisconnectProcess.jsp?submitAction=refreshCaller";
			}
		}
		else if("MoveToNewCO".equalsIgnoreCase(functionality)) 
		{			
			
			ChangeOrder changeOrder = new ChangeOrder(objectId);
			String crId =  changeOrder.getInfo(context, "to["+ChangeConstants.RELATIONSHIP_CHANGE_ORDER+"].from.id");
			objSelects.addElement(orgNameSelect);
			orgMap = changeOrder.getInfo(context,objSelects);
			orgMap.put(orgIdSelect,ChangeUtil.getRtoIdFromName(context, (String)orgMap.get(orgNameSelect)));
			session.setAttribute("sourceAffectedItemRowIds",emxTableRowIds);
			searchURL  = "../common/emxCreate.jsp?form=type_CreateChangeOrderSlidein&type=type_ChangeOrder&CreateMode=CreateCO&targetLocation=slidein&typeChooser=true&header=EnterpriseChangeMgt.Command.CreateChange&nameField=autoname&createJPO=enoECMChangeOrder:createChange&submitAction=refreshCaller&preProcessJavaScript=preProcessInCreateCO&objectId="+objectId+"&functionality="+functionality+"&suiteKey="+suiteKey+"&postProcessURL=../enterprisechangemgt/ECMDisconnectProcess.jsp&HelpMarker=emxhelpchangeordercreate&objectId="+objectId+"&appendURL=ChangeEffectivity|EnterpriseChangeMgt&mode=create&SuiteDirectory=enterprisechangemgt";
			if(UIUtil.isNotNullAndNotEmpty(crId)){
				searchURL+="&isconnectedtoCR=true";
			}
		}
		else if("MoveToExistingCR".equalsIgnoreCase(functionality)) 
		{	
			
			session.setAttribute("sourceAffectedItemRowIds",emxTableRowIds);
			searchTypes    = "type_ChangeRequest:CURRENT=policy_ChangeRequest.state_Create,policy_ChangeRequest.state_Evaluate:Organization=" + DomainObject.newInstance(context,objectId).getInfo(context, orgNameSelect);			
			searchURL	  += "&table=ECMGeneralSearchResults&hideHeader=true&excludeOID="+objectId+"&selection=single&showSavedQuery=True&HelpMarker=emxhelpfullsearch&searchCollectionEnabled=True&submitURL=../enterprisechangemgt/ECMDisconnectProcess.jsp?submitAction=refreshCaller";
		}
		else if("MoveToNewCR".equalsIgnoreCase(functionality)) 
		{		
			
			objSelects.addElement(orgNameSelect);
			orgMap     = DomainObject.newInstance(context,objectId).getInfo(context, objSelects);
			orgMap.put(orgIdSelect, ChangeUtil.getRtoIdFromName(context, (String)orgMap.get(orgNameSelect)));
			session.setAttribute("sourceAffectedItemRowIds",emxTableRowIds);
			searchURL  = "../common/emxCreate.jsp?form=type_CreateChangeRequest&type=type_ChangeRequest&targetLocation=slidein&typeChooser=true&header=EnterpriseChangeMgt.Command.CreateChange&nameField=autoname&createJPO=enoECMChangeRequest:createChangeRequest&submitAction=refreshCaller&preProcessJavaScript=setCreateFormROField&suiteKey="+suiteKey+"&postProcessURL=../enterprisechangemgt/ECMDisconnectProcess.jsp&HelpMarker=emxhelpchangerequestcreate";
	
		}
		else if("AddExistingPrerequisiteCOs".equalsIgnoreCase(functionality)) 
		{	
			searchTypes  = "type_ChangeOrder:CURRENT=policy_FormalChange.state_Propose,policy_FormalChange.state_Prepare,policy_FormalChange.state_InReview";
			searchURL   += "table=ECMGeneralSearchResults&excludeOID="+objectId+"&excludeOIDprogram=enoECMChangeUtil:excludePrerequisites&selection=multiple&showSavedQuery=True&searchCollectionEnabled=True&formInclusionList=Description&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=refreshCaller";
		}
		else if("AddExistingRelatedCAs".equalsIgnoreCase(functionality)) 
		{	
			searchTypes = "type_ChangeAction";
			ChangeAction caObj = new ChangeAction(objectId);
			String coObjId = caObj.getInfo(context, "to["+ChangeConstants.RELATIONSHIP_CHANGE_ACTION+"].from.id");
			if(!UIUtil.isNullOrEmpty(coObjId)) {
				searchTypes += ":CONNECTED_CO="+coObjId;
			}
			searchURL   += "table=ECMGeneralSearchResults&excludeOID="+objectId+"&excludeOIDprogram=enoECMChangeUtil:excludePrerequisites&selection=multiple&showSavedQuery=True&searchCollectionEnabled=True&formInclusionList=Description&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=refreshCaller";
		}
		else if("CAImplementedItemsAddExisting".equalsIgnoreCase(functionality))  {
			//searchTypes  =  changeUtil.getRelationshipTypes(context,ChangeConstants.RELATIONSHIP_IMPLEMENTED_ITEM, true, false, excludeTypeList);
			//searchTypes += ":CURRENT!=state_Release";
			searchURL   += "field=&table=ECMGeneralSearchResults&selection=multiple&showSavedQuery=True&excludeOIDprogram="+excludeOIDprogram+"&searchCollectionEnabled=True&formInclusionList=Description&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=refreshCaller";
		} 
		else if("MoveToExistingCA".equalsIgnoreCase(functionality)) 
		{	
			session.setAttribute("sourceAffectedItemRowIds",emxTableRowIds);
			Map mapObjIdRelId 	    = changeUtil.getObjRelRowIdsMapFromTableRowID(emxTableRowIds);
			StringList affectedRels = (StringList)mapObjIdRelId.get("RelId");								
			MapList objectList    =  DomainRelationship.getInfo(context, (String[])affectedRels.toArray(new String[affectedRels.size()]), new StringList(ChangeConstants.SELECT_FROM_ID));
			StringList caIdsList = changeUtil.getStringListFromMapList(objectList,ChangeConstants.SELECT_FROM_ID); 	
			
			new ChangeOrder().checkForMoveToExistingCA(context, caIdsList);
			searchTypes    = "type_ChangeAction:CONNECTED_CO="+objectId+":CURRENT=policy_ChangeAction.state_Prepare";
			searchURL	  += "&table=ECMGeneralSearchResults&hideHeader=true&excludeOID="+ FrameworkUtil.join(caIdsList, ",") +"&selection=single&showSavedQuery=True&HelpMarker=emxhelpfullsearch&searchCollectionEnabled=True&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=refreshCaller";
		}
		else if ("AddToExistingChange".equalsIgnoreCase(functionality) || "ECMAddToExistingCO".equalsIgnoreCase(functionality)) 
		{							
			session.setAttribute("sourceAffectedItemRowIds",emxTableRowIds);
			searchTypes  = "type_ChangeOrder:CURRENT=policy_FormalChange.state_Propose,policy_FormalChange.state_Prepare";
			searchURL   += "field=TYPES="+searchTypes+"&table=ECMGeneralSearchResults&selection=single&showSavedQuery=True&searchCollectionEnabled=True&functionality="+functionality+"&objectId="+objectId+"&formInclusionList=Description&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=doNothing";
			
			if("ECMAddToExistingCO".equalsIgnoreCase(functionality)) {
				// this API restricts when the user tries to add existing/new for un released part which is already connected to change from Part -->Change Mgt Powerview context
				errorMessage = changeUtil.validateAffectedItemForChange(context,objectId);
				if(UIUtil.isNotNullAndNotEmpty(errorMessage)) {
					errorMessage += itemConnectedToChangeAlready;	
				}

				if(emxTableRowIds == null || "null".equals(emxTableRowIds)){
					if(isECDevelopmentPart(context, objectId)){
						errorMessage += EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "AT.ExceptionPart.ErrorMessage3");
					}
				}				
			}
		}
		else if ("AddToNewChange".equalsIgnoreCase(functionality) || "ECMAddToNewCO".equalsIgnoreCase(functionality)) 
		{
			session.setAttribute("sourceAffectedItemRowIds",emxTableRowIds);
			searchURL	 = "../common/emxCreate.jsp?form=type_CreateChangeOrderSlidein&header=EnterpriseChangeMgt.Command.CreateChange&type=type_ChangeOrder&nameField=autoname&createJPO=enoECMChangeOrder:createChange&CreateMode=CreateCO&typeChooser=true&submitAction=doNothing&suiteKey="+suiteKey+"&preProcessJavaScript=preProcessInCreateCO&postProcessURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp&appendURL=ChangeEffectivity|EnterpriseChangeMgt&SuiteDirectory=enterprisechangemgt&mode=create&functionality="+functionality+"&jpoAppServerParamList=session:sourceAffectedItemRowIds&HelpMarker=emxhelpchangeordercreate&objectId="+objectId+"";
			if("ECMAddToNewCO".equalsIgnoreCase(functionality)) {
				// this API restricts when the user tries to add existing/new for un released part which is already connected to change from Part -->Change Mgt Powerview context
				errorMessage = changeUtil.validateAffectedItemForChange(context,objectId);
				if(UIUtil.isNotNullAndNotEmpty(errorMessage)) {
					errorMessage += itemConnectedToChangeAlready;	
				}
				
				if(emxTableRowIds == null || "null".equals(emxTableRowIds)){
					if(isECDevelopmentPart(context, objectId)){
						errorMessage += EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "AT.ExceptionPart.ErrorMessage3");
					}
				}	
			}
		}
		else if ("AddToExistingChangeAction".equalsIgnoreCase(functionality) || "AddToExistingCA".equalsIgnoreCase(functionality)) 
		{							
			//Map ObjMap = changeUtil.getObjectIdsRelIdsMapFromTableRowID((String[])emxTableRowIds);
			//StringList AffeObjList  = (StringList)ObjMap.get("ObjId");
			StringList AffeObjList = changeUtil.getObjectIdsFromTableRowID((String[])emxTableRowIds);
			session.setAttribute("sourceAffectedItemRowIds",AffeObjList);
			searchTypes  = "type_ChangeAction:CURRENT=policy_ChangeAction.state_Prepare,policy_ChangeAction.state_InWork";
			searchURL   += "field=TYPES="+searchTypes+"&table=ECMGeneralSearchResults&selection=single&showSavedQuery=True&searchCollectionEnabled=True&functionality="+functionality+"&objectId="+objectId+"&formInclusionList=Description&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=doNothing";
			
			if("AddToExistingCA".equalsIgnoreCase(functionality)) {
				// this API restricts when the user tries to add existing/new for un released part which is already connected to change from Part -->Change Mgt Powerview context
				errorMessage = changeUtil.validateAffectedItemForChange(context,objectId);
				if(UIUtil.isNotNullAndNotEmpty(errorMessage)) {
					errorMessage += itemConnectedToChangeAlready;	
				}					
			}
		}
		else if ("AddToNewChangeAction".equalsIgnoreCase(functionality) || "AddToNewCA".equalsIgnoreCase(functionality)) 
		{
			//Map ObjMap = changeUtil.getObjectIdsRelIdsMapFromTableRowID((String[])emxTableRowIds);
			//StringList AffeObjList  = (StringList)ObjMap.get("ObjId");
			StringList AffeObjList = changeUtil.getObjectIdsFromTableRowID((String[])emxTableRowIds);
			session.setAttribute("sourceAffectedItemRowIds",AffeObjList);
			searchURL	 = "../common/emxCreate.jsp?form=type_CreateChangeActionSlidein&functionality="+functionality+"&header=EnterpriseChangeMgt.Command.CreateChangeAction&type=type_ChangeAction&nameField=autoname&createJPO=enoECMChangeAction:createChangeAction&CreateMode=CreateCA&submitAction=doNothing&suiteKey="+suiteKey+"&postProcessURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp&SuiteDirectory=enterprisechangemgt&mode=create&functionality="+functionality+"&HelpMarker=emxhelpchangeactioncreate&objectId="+objectId+"";
			if("AddToNewCA".equalsIgnoreCase(functionality)) {
				// this API restricts when the user tries to add existing/new for un released part which is already connected to change from Part -->Change Mgt Powerview context
				errorMessage = changeUtil.validateAffectedItemForChange(context,objectId);
				if(UIUtil.isNotNullAndNotEmpty(errorMessage)) {
					errorMessage += itemConnectedToChangeAlready;	
				}
			}
		}
		else if ("AddToExistingChangeRequest".equalsIgnoreCase(functionality) || "ECMAddToExistingCR".equalsIgnoreCase(functionality))  
		{							
			Map ObjMap = changeUtil.getObjectIdsRelIdsMapFromTableRowID((String[])emxTableRowIds);
			StringList AffeObjList  = (StringList)ObjMap.get("ObjId");
			StringList connectedCRs = changeUtil.getconnectedCRs(context, AffeObjList, "ECMAddToExistingCR".equalsIgnoreCase(functionality) ? 
									  "to["+ChangeConstants.RELATIONSHIP_CHANGE_ACTION+"].from.id" : "to["+ChangeConstants.RELATIONSHIP_CHANGE_AFFECTED_ITEM+"].from.to["+ChangeConstants.RELATIONSHIP_CHANGE_ACTION+"].from.id");
			session.setAttribute("sourceAffectedItemRowIds",AffeObjList);
			searchTypes  = "type_ChangeRequest:CURRENT=policy_ChangeRequest.state_Create,policy_ChangeRequest.state_Evaluate";
			searchURL   += "field=TYPES="+searchTypes+"&table=ECMGeneralSearchResults&selection=multiple&showSavedQuery=True&searchCollectionEnabled=True&functionality="+functionality+"&objectId="+objectId+"&formInclusionList=Description&excludeOID="+ FrameworkUtil.join(connectedCRs, ",") +"&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=doNothing";
			if("ECMAddToExistingCR".equalsIgnoreCase(functionality)) {
				// this API restricts when the user tries to add existing/new for un released part which is already connected to change from Part -->Change Mgt Powerview context
				errorMessage = changeUtil.validateAffectedItemForChange(context,objectId);
				if(UIUtil.isNotNullAndNotEmpty(errorMessage)) {
					errorMessage += itemConnectedToChangeAlready;	
				}					
			}			
		}
		else if ("AddToNewChangeRequest".equalsIgnoreCase(functionality) || "ECMAddToNewCR".equalsIgnoreCase(functionality))  
		{
			Map ObjMap = changeUtil.getObjectIdsRelIdsMapFromTableRowID((String[])emxTableRowIds);
			StringList AffeObjList = (StringList)ObjMap.get("ObjId");
			session.setAttribute("sourceAffectedItemRowIds",AffeObjList);
			searchURL	 = "../common/emxCreate.jsp?form=type_CreateChangeRequest&header=EnterpriseChangeMgt.Command.CreateChangeRequest&type=type_ChangeRequest&nameField=autoname&createJPO=enoECMChangeRequest:createChangeRequest&typeChooser=true&submitAction=doNothing&suiteKey="+suiteKey+"&preProcessJavaScript=setRO&postProcessURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp&functionality="+functionality+"&HelpMarker=emxhelpchangerequestcreate&objectId="+objectId+"";
			if("ECMAddToNewCR".equalsIgnoreCase(functionality)) {
				// this API restricts when the user tries to add existing/new for un released part which is already connected to change from Part -->Change Mgt Powerview context
				errorMessage = changeUtil.validateAffectedItemForChange(context,objectId);
				if(UIUtil.isNotNullAndNotEmpty(errorMessage)) {
					errorMessage += itemConnectedToChangeAlready;	
				}					
			}
		}
		else if("AddExistingCandidate".equalsIgnoreCase(functionality))
		{
			searchTypes =  changeUtil.getSearchTypesForAffectedItem(context);
			searchURL	+= "&table=ECMGeneralSearchResults&excludeOIDprogram=enoECMChangeOrder:excludeCandidateItems&selection=multiple&showSavedQuery=True&searchCollectionEnabled=True&submitURL=../enterprisechangemgt/ECMUtil.jsp?mode=AddExisting&submitAction=refreshCaller";		
		}
		else if("MassRelease".equalsIgnoreCase(functionality)) 
		{
			errorMessage = isChangeActionAllowed(context,emxTableRowIds); //Added for REQ 08.005
			session.setAttribute("functionality",functionality);
			functionality=ChangeConstants.FOR_RELEASE;
			Map ObjMap = changeUtil.getObjectIdsRelIdsMapFromTableRowID((String[])emxTableRowIds);
			StringList AffeObjList = (StringList)ObjMap.get("ObjId");
			changeUtil.checkForMassReleaseOrObsolete(context,changeUtil.getTypeNamePolicyForObjList(context,AffeObjList),ChangeConstants.FOR_RELEASE);
			session.setAttribute("sourceAffectedItemRowIds",AffeObjList);
			searchURL  = "../common/emxCreate.jsp?form=type_CreateChangeOrderSlidein&header=EnterpriseChangeMgt.Command.MassRelease&type=type_ChangeOrder&policy=policy_FasttrackChange&nameField=autoname&createJPO=enoECMChangeOrder:createChange&submitAction=doNothing&preProcessJavaScript=preProcessInCreateCO&CreateMode=CreateCO&functionality="+functionality+"&suiteKey="+suiteKey+"&postProcessURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp&HelpMarker=emxhelpchangeordercreate&appendURL=ChangeEffectivity|EnterpriseChangeMgt&mode=create&SuiteDirectory=enterprisechangemgt";
		}
		else if("MassObsolete".equalsIgnoreCase(functionality)) 
		{
			errorMessage = isChangeActionAllowed(context,emxTableRowIds); //Added for REQ 08.005	
			session.setAttribute("functionality",functionality);
			functionality=ChangeConstants.FOR_OBSOLETE;
			Map ObjMap = changeUtil.getObjectIdsRelIdsMapFromTableRowID((String[])emxTableRowIds);
			StringList AffeObjList = (StringList)ObjMap.get("ObjId");
			changeUtil.checkForMassReleaseOrObsolete(context,changeUtil.getTypeNamePolicyForObjList(context,AffeObjList),ChangeConstants.FOR_OBSOLETE);
			MapList ObjInfoList = changeUtil.getTypeNamePolicyForObjList(context,AffeObjList);
			session.setAttribute("sourceAffectedItemRowIds",AffeObjList);
			searchURL  = "../common/emxCreate.jsp?form=type_CreateChangeOrderSlidein&header=EnterpriseChangeMgt.Command.MassObsolete&type=type_ChangeOrder&policy=policy_FasttrackChange&nameField=autoname&createJPO=enoECMChangeOrder:createChange&submitAction=doNothing&preProcessJavaScript=preProcessInCreateCO&CreateMode=CreateCO&functionality="+functionality+"&suiteKey="+suiteKey+"&postProcessURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp&HelpMarker=emxhelpchangeordercreate&appendURL=ChangeEffectivity|EnterpriseChangeMgt&mode=create&SuiteDirectory=enterprisechangemgt";
		}
		else if("CRSupportingDocAddExisting".equalsIgnoreCase(functionality)) 
		{
			session.setAttribute("functionality",functionality);
			searchTypes  = "type_Sketch,type_Markup";
			searchURL   += "&table=ECMGeneralSearchResults&selection=multiple&excludeOIDprogram=enoECMChangeRequest:excludeConnectSupportingDocOIDs&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=refreshCaller&relName="+targetRelName+"";
		}
		else if("AddCAReferential".equalsIgnoreCase(functionality)) 
		{
			session.setAttribute("functionality",functionality);
			searchTypes=changeUtil.getListOfAllowedTypesForGivenCategory(context, ChangeConstants.REFERENTIAL);
			searchURL   += "&table=ECMGeneralSearchResults&selection=multiple&excludeOIDprogram=enoECMChangeAction:excludeReferentialOIDs&submitURL=../enterprisechangemgt/ECMFullSearchPostProcess.jsp?submitAction=refreshCaller&relName="+targetRelName+"";
		}
		ContextUtil.commitTransaction(context);
	}
	catch (Exception ex) {
		errorMessage = ex.getMessage();
		ex.printStackTrace();
		ContextUtil.abortTransaction(context);
	}

%>

<html>
<head>
</head>
<body>	
<form name="ECMfullsearch" method="post">
<input type="hidden" name="field" value="<xss:encodeForHTMLAttribute><%= "TYPES="+searchTypes %></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="functionality" value="<xss:encodeForHTMLAttribute><%=functionality %></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="isFrom" value="<xss:encodeForHTMLAttribute><%= isFrom%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="targetRelName" value="<xss:encodeForHTMLAttribute><%=targetRelName%></xss:encodeForHTMLAttribute>"/>
<%
if("MoveToNewCO".equalsIgnoreCase(functionality) || "MoveToNewCR".equalsIgnoreCase(functionality)) {
%>
<input type="hidden" name="ROOID" value="<xss:encodeForHTMLAttribute><%= (String)orgMap.get(orgIdSelect) %></xss:encodeForHTMLAttribute>"/>	
<input type="hidden" name="RODisplay" value="<xss:encodeForHTMLAttribute><%= (String)orgMap.get(orgNameSelect) %></xss:encodeForHTMLAttribute>"/>
<%
}
if (emxTableRowIds != null){
	%>
	<input type="hidden" name="selectedObjIdList" value="<xss:encodeForHTMLAttribute><%=com.matrixone.apps.domain.util.StringUtil.join(emxTableRowIds, "~")%></xss:encodeForHTMLAttribute>"/>
	<%
}
%>
<script language="Javascript">
//XSSOK
var error 		= "<%=errorMessage%>";
var portalFrame = "<%=XSSUtil.encodeForJavaScript(context,portalFrame)%>";


<%
if(!"".equals(errorMessage)){
%>
	alert(error);
<%
} else if(ChangeConstants.FOR_RELEASE.equalsIgnoreCase(functionality)||
		ChangeConstants.FOR_OBSOLETE.equalsIgnoreCase(functionality) || "AddToNewChangeRequest".equalsIgnoreCase(functionality) ||
		"AddToNewChange".equalsIgnoreCase(functionality) || "ECMAddToNewCR".equalsIgnoreCase(functionality) || "ECMAddToNewCO".equalsIgnoreCase(functionality) || "AddToNewChangeAction".equalsIgnoreCase(functionality) || "AddToNewCA".equalsIgnoreCase(functionality)){
%>
document.ECMfullsearch.action="<%=XSSUtil.encodeForJavaScript(context,searchURL)%>";
<%
if(!fullSearch){
%>	
	var currentFrame = this.parent.frameElement.name;
	//getTopWindow().showSlideInDialog("../common/emxAEFSubmitSlideInAction.jsp?portalFrame="+portalFrame+"&parentFrame="+currentFrame+"&url=" + encodeURIComponent(document.ECMfullsearch.action + "&targetLocation=slidein"), "true");
	var addToNewURL = "<%=XSSUtil.encodeForJavaScript(context,searchURL)%>";
	getTopWindow().showSlideInDialog(addToNewURL, "true");

<%
}else{
%>	
	showModalDialog("../common/emxAEFSubmitPopupAction.jsp?portalFrame="+portalFrame+"&url=" + encodeURIComponent(document.ECMfullsearch.action + "&targetLocation=popup"), "600", "500");
<%
	}
} else if("AddToExistingChangeRequest".equalsIgnoreCase(functionality) || "AddToExistingChange".equalsIgnoreCase(functionality) || "AddToExistingChangeAction".equalsIgnoreCase(functionality) || "AddToExistingCA".equalsIgnoreCase(functionality) ||
		  "ECMAddToExistingCO".equalsIgnoreCase(functionality) || "ECMAddToExistingCR".equalsIgnoreCase(functionality)){
%>
document.ECMfullsearch.action="<%=XSSUtil.encodeForJavaScript(context,searchURL)%>";
showModalDialog(document.ECMfullsearch.action, "600", "500", true);

<%
}else{
%>
document.ECMfullsearch.action="<%=XSSUtil.encodeForJavaScript(context,searchURL)%>";
document.ECMfullsearch.submit();
<%
}
%>	
</script>
</form>
</body>
</html>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

