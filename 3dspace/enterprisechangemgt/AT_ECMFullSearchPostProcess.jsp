<%--
  ECMFullSearchPostProcess.jsp

  Copyright (c) 1992-2015 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: ECMFullSearchPostProcess.jsp 1.13 Tue Oct 28 23:01:03 2008 przemek Experimental przemek $";
  
  ECMFullSearchPostProcess.jsp which is post process jsp for all the add existing operations from toolbar.
	Modification Hisotry
	--------------------
	Suresh S;1.0;June 5, 2017;Modified for REQ08.005
  
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "ECMDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="changeUtil" class="com.dassault_systemes.enovia.enterprisechangemgt.util.ChangeUtil" scope="session"/>
<%!
//Added the method for REQ 08.005
public String isChangeActionAllowed (Context context,String[] selectedItems) throws Exception {
			boolean bchangeactionAllowed = true;
			String sLNType = PropertyUtil.getSchemaProperty(context, "type_AT_C_LOGICAL_NODE");
			StringList slObject = new StringList();
			DomainObject dobj;
			String serr = "";
					
			slObject.add(DomainConstants.SELECT_NAME);
			slObject.add(DomainConstants.SELECT_TYPE);
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
				if (stemptype!= null && stemptype.equals(sLNType)) { 
				bchangeactionAllowed = false;
			   }
			}
			if (!bchangeactionAllowed) {
				serr = "Action you have chosen is not allowed for this type.";
			}
			return serr;
	}
%>
<%
    String strMode         = emxGetParameter(request, "mode");
    String functionality   = emxGetParameter(request, "functionality");    
    String strTreeId       = emxGetParameter(request,"jsTreeID");
    String objectId        = emxGetParameter(request, "objectId");
    String targetObjId      = emxGetParameter(request, "newObjectId");
    String frameName       = emxGetParameter(request, "frameName");
    String targetLocation         = emxGetParameter(request, "targetLocation");
    targetLocation         =  !UIUtil.isNullOrEmpty(targetLocation) ? targetLocation : "";
    boolean boolAddAffectedItem = true; // added for configured part adding from My ENG view 
    //---------bIsLegacyMode
	boolean bIsLegacyMode = ChangeUtil.isLegacyEnable(context);	
    
    String strLanguage     = context.getSession().getLanguage();    
    String errorMessage    = ""; 
    
    String strIsFrom            = emxGetParameter(request, "isFrom");
    String strRelSymbolic       = emxGetParameter(request, "targetRelName");
    String tmplId = emxGetParameter(request,"tmplId");
    String strRelationshipName  = ""; 
    strRelationshipName =  !UIUtil.isNullOrEmpty(strRelSymbolic) ? PropertyUtil.getSchemaProperty(context, strRelSymbolic) : "";
    String emxTableRowIds[]     = emxGetParameterValues(request, "emxTableRowId");
    Map objToRelIdMap = null;    
    ChangeOrder changeOrder = !changeUtil.isNullOrEmpty(objectId) ? new ChangeOrder(objectId) : new ChangeOrder(objectId);
    StringList selectedItemsList;DomainObject fromObj = null;DomainObject toObj = null;DomainRelationship rel = null;
    StringList selectedRelList;
    String stringResFileId = "emxEnterpriseChangeMgtStringResource";
    String strInvalidAffectedItems = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Message.InvalidRelatedItem");
    String strMergeCAmsg = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Message.MergeCA");
    String strInvalidObjectts = "";
    Map mpInvalidObjects = null;
    String FastTrackProcess = emxGetParameter(request, "FastTrackProcess");
    try {       
        
        ContextUtil.startTransaction(context,true);
		//Added for REQ 08.005 start
		if ("AffectedItemsAddExisting".equalsIgnoreCase(functionality)) {
			errorMessage = isChangeActionAllowed(context,emxTableRowIds);
			if (errorMessage !="") {
				boolAddAffectedItem = false;
			}
		}
		//Added for REQ 08.005 End
        if (("AffectedItemsAddExisting".equalsIgnoreCase(functionality) || "AffectedItemsAddExistingForCR".equalsIgnoreCase(functionality))&& emxTableRowIds != null) {
        	selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
        	if (ChangeUtil.isCFFInstalled(context)) {
				String effectivity = emxGetParameter(request, "ChangeEffectivityOID");
				String funcTemp = "AddToExistingChange";
				String strChangeOrderId = changeOrder.getObjectId(); 
				if(!UIUtil.isNullOrEmpty(effectivity)){
				boolAddAffectedItem = changeOrder.validateEffectivityOnCO(context, strChangeOrderId, selectedItemsList, funcTemp);	
			}
			}
			
			if (boolAddAffectedItem) {
				
        	mpInvalidObjects = changeOrder.connectAffectedItems(context, selectedItemsList);
    		
    		strInvalidObjectts = (String)mpInvalidObjects.get("strErrorMSG");
			} else {
				strInvalidObjectts = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Select.Effectivity");
			}
    		
        } else if ("AddToExistingChange".equalsIgnoreCase(functionality) || "AddToNewChange".equalsIgnoreCase(functionality) ||
        		   "ECMAddToExistingCO".equalsIgnoreCase(functionality) || "ECMAddToNewCO".equalsIgnoreCase(functionality)) {
        	targetObjId        = changeUtil.isNullOrEmpty(targetObjId) ? (String)(changeUtil.getObjectIdsFromTableRowID(emxTableRowIds)).get(0) : targetObjId;
			selectedItemsList  = ("ECMAddToExistingCO".equalsIgnoreCase(functionality) || "ECMAddToNewCO".equalsIgnoreCase(functionality)) ? new StringList(objectId) : changeUtil.getObjectIdsFromTableRowID((String[])session.getAttribute("sourceAffectedItemRowIds"));
			context		       = ("AddToNewChange".equalsIgnoreCase(functionality) || "ECMAddToNewCO".equalsIgnoreCase(functionality)) ? (matrix.db.Context)request.getAttribute("context") : context;			
			changeOrder	       = new ChangeOrder(targetObjId);			
			
						
			if (ChangeUtil.isCFFInstalled(context)) {
				String effectivity = emxGetParameter(request, "ChangeEffectivityOID");
				String funcTemp = "AddToExistingChange";
				if (("AddToNewChange".equalsIgnoreCase(functionality) || "ECMAddToNewCO".equalsIgnoreCase(functionality)) && (effectivity == null || "".equals(effectivity) || "null".equals(effectivity))) {
					funcTemp = "AddToNewChange";
				}
				if(!UIUtil.isNullOrEmpty(effectivity)){
				boolAddAffectedItem = changeOrder.validateEffectivityOnCO(context, targetObjId, selectedItemsList, funcTemp);	
				}
			}
			
			if (boolAddAffectedItem) {
				mpInvalidObjects   = changeOrder.connectAffectedItems(context, selectedItemsList);
				
				strInvalidObjectts = (String)mpInvalidObjects.get("strErrorMSG");
			} else {
				strInvalidObjectts = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Select.Effectivity");
			}
    		
	    } else if ("AddToExistingChangeRequest".equalsIgnoreCase(functionality) || "AddToNewChangeRequest".equalsIgnoreCase(functionality) ||
	    		   "ECMAddToExistingCR".equalsIgnoreCase(functionality) || "ECMAddToNewCR".equalsIgnoreCase(functionality))  {
	    	targetObjId   = changeUtil.isNullOrEmpty(targetObjId) ? (String)(changeUtil.getObjectIdsFromTableRowID(emxTableRowIds)).get(0) : targetObjId;
			StringList affeItemList = ("ECMAddToExistingCR".equalsIgnoreCase(functionality) || "ECMAddToNewCR".equalsIgnoreCase(functionality)) ? new StringList(objectId) : (StringList)session.getAttribute("sourceAffectedItemRowIds");
			context		  =  ("AddToNewChangeRequest".equalsIgnoreCase(functionality) || "ECMAddToNewCR".equalsIgnoreCase(functionality)) ? (matrix.db.Context)request.getAttribute("context") : context;
			ChangeRequest changeRequest	  = new ChangeRequest(targetObjId);
			mpInvalidObjects = changeRequest.connectAffectedItems(context, affeItemList);
    		strInvalidObjectts = (String)mpInvalidObjects.get("strErrorMSG");
	    } else if ("AddToExistingChangeAction".equalsIgnoreCase(functionality) || "AddToExistingCA".equalsIgnoreCase(functionality) 
	    		|| "AddToNewChangeAction".equalsIgnoreCase(functionality) || "AddToNewCA".equalsIgnoreCase(functionality))  {
	    	targetObjId   = changeUtil.isNullOrEmpty(targetObjId) ? (String)(changeUtil.getObjectIdsFromTableRowID(emxTableRowIds)).get(0) : targetObjId;
	    	selectedItemsList  = ("AddToExistingCA".equalsIgnoreCase(functionality) || "AddToNewCA".equalsIgnoreCase(functionality)) ? new StringList(objectId) : (StringList)session.getAttribute("sourceAffectedItemRowIds");
			context		  =  ("AddToNewChangeAction".equalsIgnoreCase(functionality) || "AddToNewCA".equalsIgnoreCase(functionality)) ? (matrix.db.Context)request.getAttribute("context") : context;
			ChangeAction changeAction	  = new ChangeAction(targetObjId);
			mpInvalidObjects = changeAction.connectAffectedItems(context, selectedItemsList);
 		strInvalidObjectts = (String)mpInvalidObjects.get("strErrorMSG");
	    }
	    else if (("AddExisting".equalsIgnoreCase(functionality) || "AddExistingRelatedCAs".equalsIgnoreCase(functionality) || "AddExistingPrerequisiteCOs".equalsIgnoreCase(functionality)) && emxTableRowIds != null) {                                  	 
    		selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
    		changeOrder.connect(context, selectedItemsList,strRelationshipName,"true".equalsIgnoreCase(strIsFrom)? true : false);
	    } else if ("CAAffectedItemsAddExisting".equalsIgnoreCase(functionality) && emxTableRowIds != null) {
        	selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
        	if(ChangeUtil.isCFFInstalled(context))
        	{
        		
        		boolAddAffectedItem = !new ChangeUtil().isConfiguredPartSelected(context, (String[]) selectedItemsList.toArray(new String[0]));
        	}
        	if (boolAddAffectedItem) 
        	{
        	mpInvalidObjects = new ChangeAction(objectId).connectAffectedItems(context, selectedItemsList);
    		strInvalidObjectts = (String)mpInvalidObjects.get("strErrorMSG");
        	} 
        	else 
        	{
				strInvalidObjectts = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Select.Effectivity");
			}
        	
        } else if ("CAImplementedItemsAddExisting".equalsIgnoreCase(functionality) && emxTableRowIds != null) {
        	selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
        	strInvalidObjectts = new ChangeAction(objectId).connectImplementedItems(context, selectedItemsList); 
        } else if ("MoveToNewCA".equalsIgnoreCase(functionality)) {
        	Map mapObjIdRelId 	  = changeUtil.getObjRelRowIdsMapFromTableRowID(emxTableRowIds);        	
        	changeOrder		  = new ChangeOrder(objectId);
        	if(bIsLegacyMode){
        		changeOrder.moveToNewChangeAction(context, (StringList)mapObjIdRelId.get("RelId"));
        	}else{
			  changeOrder.moveToChangeAction(context, (StringList)mapObjIdRelId.get("RelId"),(StringList)mapObjIdRelId.get("ObjId"),null);
        	}
        } else if ("MoveToExistingCA".equalsIgnoreCase(functionality)) {
        	selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
			Map mapObjIdRelId 	  = changeUtil.getObjRelRowIdsMapFromTableRowID((String[])session.getAttribute("sourceAffectedItemRowIds"));        	
        	changeOrder		  = new ChangeOrder(objectId);
        	if(bIsLegacyMode){
			  changeOrder.moveToChangeAction(context, (StringList)mapObjIdRelId.get("RelId"),(String)selectedItemsList.get(0));
        	}else{
			  changeOrder.moveToChangeAction(context, (StringList)mapObjIdRelId.get("RelId"),(StringList)mapObjIdRelId.get("ObjId"),(String)selectedItemsList.get(0));
        	}
        } else if ("MergeCA".equalsIgnoreCase(functionality)) {
        	selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
        	if(selectedItemsList.size() > 1){
        	changeOrder		  = new ChangeOrder(objectId);
        	changeOrder.checkForMergeCA(context, selectedItemsList);
			changeOrder.mergeChangeAction(context,selectedItemsList);
        	}else{
        		functionality = "";
        		errorMessage = XSSUtil.encodeForJavaScript(context,strMergeCAmsg);
        		%>
        		<script language="JavaScript">
        		alert("<%=XSSUtil.encodeForJavaScript(context,strMergeCAmsg)%>");
        		</script>
        		<%
        	}
        	
        }else if((ChangeConstants.FOR_RELEASE.equalsIgnoreCase(functionality))||(ChangeConstants.FOR_OBSOLETE.equalsIgnoreCase(functionality))){
        	session.removeAttribute("functionality");
        	StringList affeItemList = (StringList)session.getAttribute("sourceAffectedItemRowIds");
			context = (matrix.db.Context)request.getAttribute("context");
    	 	changeOrder.setId(targetObjId);
	        changeOrder.MassReleaseOrObsolete(context,affeItemList,functionality,FastTrackProcess);
    	 	functionality = "MassReleaseOrObsolete";
         }else if ("CRSupportingDocAddExisting".equalsIgnoreCase(functionality)){
        	 selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
     		 changeOrder.connect(context, selectedItemsList,strRelationshipName,"true".equalsIgnoreCase(strIsFrom)? true : false);
        }
         else if("AddCAReferential".equalsIgnoreCase(functionality)){
        	 session.removeAttribute("functionality");
        	 selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
        	 new ChangeAction().addReferential(context, objectId, selectedItemsList);        	 
         }        
        ContextUtil.commitTransaction(context);
        if(!ChangeUtil.isNullOrEmpty(strInvalidObjectts)){
        	if (!boolAddAffectedItem) {
        		strInvalidAffectedItems = strInvalidObjectts;
        	} else {
        		strInvalidAffectedItems += strInvalidObjectts;
        	}
        	%>
        	<script language="JavaScript">
        	<!-- XSSOK -->
        	alert("<%=strInvalidAffectedItems%>");
        	</script>
        	<%
        }
    }  catch(FrameworkException e) {
        e.printStackTrace();
        ContextUtil.abortTransaction(context);
        errorMessage=e.getMessage();
        if(!errorMessage.contains("ErrorCode:1500167")){
        	 session.putValue("error.message",errorMessage);
        }
       
    }
%>
 

<script language="javascript" type="text/javaScript">
var isFTS = getTopWindow().location.href.indexOf("common/emxFullSearch.jsp?") != -1;
if(isFTS) {
findFrame(getTopWindow(),"structure_browser").setSubmitURLRequestCompleted();
}
//XSSOK
var error  = "<%=errorMessage%>";
var functionality  = "<%=XSSUtil.encodeForJavaScript(context,functionality)%>";
var stargetLocation ="<%=XSSUtil.encodeForJavaScript(context,targetLocation)%>";
var objectId = "<%=XSSUtil.encodeForJavaScript(context,targetObjId)%>";
if(("MoveToExistingCA" == functionality || "MoveToNewCA" == functionality || "MergeCA" == functionality || 
	"AffectedItemsAddExistingForCR" == functionality || "AffectedItemsAddExisting" == functionality) && error == "") {
	var addExistingCase    = functionality.indexOf("Existing") > -1 ? true : false;
//	var affectedItemFrame  = findFrame(addExistingCase ? getTopWindow().getWindowOpener().getTopWindow() :getTopWindow() ,"ECMCRCOAffectedItems");
//	var changeActionsFrame = findFrame(addExistingCase ? getTopWindow().getWindowOpener().getTopWindow() :getTopWindow() ,"ECMCRCOAffectedChangeActions");
//	affectedItemFrame.location.href  = affectedItemFrame.location.href;
//	changeActionsFrame.location.href = changeActionsFrame.location.href;

//  IR 454663
	var windowToRefer = addExistingCase ? getTopWindow().getWindowOpener().getTopWindow() : getTopWindow();
	var varDetailsDisplay = findFrame(windowToRefer, "detailsDisplay");
	if (varDetailsDisplay) {
			varDetailsDisplay.location.href = varDetailsDisplay.location.href;
	}
	
	if(addExistingCase) getTopWindow().close();
} else if("MassReleaseOrObsolete" == functionality && error == ""){
	getTopWindow().closeSlideInDialog();
	parent.location.href = "../common/emxTree.jsp?objectId="+objectId+"&DefaultCategory=ECMChangeContent";

} 
else if(("ECMAddToNewCR" == functionality || "ECMAddToNewCO"==functionality || "ECMAddToExistingCO" == functionality 
		|| "ECMAddToExistingCR" == functionality || "AddToExistingCA" == functionality || "AddToNewCA" == functionality) && error == "") {	
	var targetFrameName = ("ECMAddToExistingCO" == functionality || "ECMAddToNewCO" == functionality) ?  "ECMCOs" : (("ECMAddToExistingCR" == functionality || "ECMAddToNewCR" == functionality) ? "ECMCRs" : "ECMCAs");
	var windowToRefer   = functionality.indexOf("Existing") >0 ? getTopWindow().getWindowOpener().parent.parent : getTopWindow();
	var targetFrame     = findFrame(windowToRefer ,targetFrameName);
	targetFrame.location.href = targetFrame.location.href;
	doClose(stargetLocation);
}
//IR-435382-3DEXPERIENCER2016x
else if(("AddToExistingChangeRequest" == functionality || "AddToNewChangeRequest" == functionality || "AddToNewChangeAction" == functionality || "AddToExistingChange" == functionality || "AddToNewChange" == functionality || "AddToExistingChangeAction" == functionality) && error == ""){
	doClose(stargetLocation);
}else if("CreateChange" == functionality && error == ""){
	getTopWindow().closeSlideInDialog();
	var contentFrame = findFrame(getTopWindow(), "content");
    if(contentFrame)
    {
        contentFrame.document.location.href = "../common/emxTree.jsp?objectId="+objectId+"&DefaultCategory=ECMChangeContent";
    }else{
	parent.location.href = "../common/emxTree.jsp?objectId="+objectId+"&DefaultCategory=ECMChangeContent";
    }
}else {
	//Modified the aler msg for REQ 08.005 start
	if (error != "") {
		alert("Exception Occured : "+error);
		getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
		getTopWindow().close();
		//Modified the aler msg for REQ 08.005 end
	} else {
	     getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
	     getTopWindow().close();
	}
}

function doClose(targetLocation) {
	"slidein" == targetLocation ? getTopWindow().closeSlideInDialog() : getTopWindow().close();	
}

</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
