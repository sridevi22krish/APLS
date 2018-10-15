<%-- AddExistingPartProcess.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@include file = "../engineeringcentral/emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../engineeringcentral/emxEngrStartUpdateTransaction.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%-- 2011x - Starts --%>
<%@page import = "com.matrixone.apps.unresolvedebom.*,com.matrixone.apps.effectivity.EffectivityFramework,matrix.util.StringList,java.util.*,com.matrixone.jsystem.util.StringUtils"%>
<%-- 2011x - Ends --%>

<%
  String objectId = emxGetParameter(request, "objectId");
  String contextECO = emxGetParameter(request,"contextECO");
  String strCurrent = emxGetParameter(request,"current");
  String isWipMode  = emxGetParameter(request,"isWipMode");
  String CreateMode  = emxGetParameter(request,"CreateMode");
  String language  = request.getHeader("Accept-Language");

  String highestFN = emxGetParameter(request, "highestFN");
  String frameName = emxGetParameter(request, "frameName");
  String tablemode = emxGetParameter(request, "tablemode");
  String selPartRowId = emxGetParameter(request, "selPartRowId");
  String ecoName = "";
  String displayValue = "";
  
  //String isWipBomAllowed = EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOM.WIPBOM.Allowed");
  String isWipBomAllowed = isWipMode;
  if ( UIUtil.isNotNullAndNotEmpty(objectId) ) {
		isWipBomAllowed = UnresolvedEBOM.isWipBomAllowedForParts(context,objectId);
  }
  String incrementFN = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.StructureBrowser.FNIncrement");
  String strInput = "<mxRoot>";
  String callbackFunctionName = "addToSelected";
  String calledMethod = emxGetParameter(request, "calledMethod");
  if (calledMethod != null && !"".equals(calledMethod) && "addToProduct".equals(calledMethod)) {
    String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
    StringList slPartObjectList = FrameworkUtil.split(selectedItems[0], "|");
    String sPartId = (String) slPartObjectList.get(0);
    DomainRelationship.connect(context, new DomainObject(objectId),
                                  com.matrixone.apps.unresolvedebom.UnresolvedEBOMConstants.RELATIONSHIP_ASSIGNED_PART,
                                  new DomainObject(sPartId));
  }
  
  //2012--Starts invoking bean with stringlist of affected items
  else if ("true".equalsIgnoreCase(isWipBomAllowed) && ("addToExistingPUEECO".equalsIgnoreCase(calledMethod) ||  "CreateECO".equalsIgnoreCase(CreateMode)))
  { 
	String ecoId = "";
	if("addToExistingPUEECO".equalsIgnoreCase(calledMethod)) {
		String[]   selectedECOItems  = emxGetParameterValues(request, "emxTableRowId");
	    StringList slECOObjectList   = FrameworkUtil.split(selectedECOItems[0], "|");
		ecoId  = (String) slECOObjectList.get(0);
	}
	ecoId	= "CreateECO".equalsIgnoreCase(CreateMode)?emxGetParameter(request,"newObjectId"):ecoId;
	context = "CreateECO".equalsIgnoreCase(CreateMode)?(matrix.db.Context)request.getAttribute("context"):context;
	 String alertMessage    = i18nStringNowUtil("emxUnresolvedEBOM.ContextChange.CONotConnected","emxUnresolvedEBOMStringResource", language); 
	if ("addToExistingPUEECO".equalsIgnoreCase(calledMethod) && !PUEECO.isCOConnected(context, ecoId)) {
%>
		<script language="javascript" src="../common/scripts/emxUICore.js"></script>
		<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	          <script language="Javascript">
	          alert("<%=alertMessage%>");
	      	 var fullSearchReference = findFrame(getTopWindow(), "structure_browser");
	    	 fullSearchReference.setSubmitURLRequestCompleted();
          	 </script>
		 
<%			
		
	} else {
		String  selectedParts   = emxGetParameter(request, "selectedPartsList");
		boolean connect         = ("addToExistingPUEECO".equals(calledMethod))?true:false;
	    StringList slPartObjectList   = new StringList();
	    StringTokenizer selectedIdTok = new StringTokenizer(selectedParts, "~");
		while (selectedIdTok.hasMoreTokens()){
		    String selectedId    = selectedIdTok.nextToken();
		    String strObjectId   = selectedId.substring(0,selectedId.indexOf("|")).trim();
		    slPartObjectList.addElement(strObjectId);
	       }
	
	PUEECO.connectOrDisconnectAffectedItemsToPUEECO(context,slPartObjectList,ecoId,connect,CreateMode);
	
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	          <script language="Javascript">
			      getTopWindow().getWindowOpener().parent.emxEditableTable.refreshStructureWithOutSort();
			      if ("addToExistingPUEECO" == "<xss:encodeForJavaScript><%=calledMethod%></xss:encodeForJavaScript>") {
		          		getTopWindow().closeWindow();
			      }
          	 </script>

<%	
 }
  }
  
  if ("addExisting".equalsIgnoreCase(calledMethod)) {

	  int incrementIntValue;
      try {
      incrementIntValue = Integer.parseInt(incrementFN);
      }catch(Exception e)
      {
      incrementIntValue = 1; 
      }

      if(incrementIntValue <0){
      incrementIntValue = 1;
      }
  	int FNvalue = 1;
  	if(highestFN != null && !("0".equals(highestFN))){
  		FNvalue = Integer.parseInt(highestFN)+incrementIntValue;
  	}

	  //2012x -Starts- ignoring context change for preliminary parts
	   if("true".equalsIgnoreCase(isWipMode)){
		  ecoName      = "";
		  displayValue = "";
	  }
	  //2012x -Ends
  
		  if ("false".equalsIgnoreCase(isWipMode)) 
		  {
			  com.matrixone.apps.domain.DomainObject ecoObj = new com.matrixone.apps.domain.DomainObject(contextECO);
			  matrix.util.StringList ecoSelecttables = new matrix.util.StringList(1);
			  ecoSelecttables.add(com.matrixone.apps.domain.DomainConstants.SELECT_NAME);
			  java.util.Map ecoMap = ecoObj.getInfo(context,ecoSelecttables);
			  ecoName = (String)ecoMap.get(com.matrixone.apps.domain.DomainConstants.SELECT_NAME);
			  displayValue   = UnresolvedPart.getEffectivityValue(context, contextECO, EffectivityFramework.DISPLAY_VALUE, true);
		  }
  
  
		  String selPartObjectId = emxGetParameter(request, "selPartObjectId");
		  if("".equals(selPartObjectId) || selPartObjectId == null)
		  {
		      selPartObjectId = objectId;
		  }
		  String selPartRelId = emxGetParameter(request, "selPartRelId");
		  String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
		  com.matrixone.apps.domain.util.MapList tempListNewget=(com.matrixone.apps.domain.util.MapList)session.getAttribute("tempListNew");
		  if("view".equalsIgnoreCase(tablemode)){
		  	strInput = strInput + "<action>add</action><data status=\"comitted\">";
		  }
		  else{
			  strInput = strInput + "<action>add</action><data status=\"pending\">";
		  }
		  String selectedId = "";
  
		  String sUOMForMarkUp = "";//UOM Management: Show the UOM value of Part in the Markup
		  DomainObject domObj = UIUtil.isNotNullAndNotEmpty(selPartObjectId)?new DomainObject(selPartObjectId):null;
		  String changeControlled = UIUtil.isNotNullAndNotEmpty(selPartObjectId)?domObj.getInfo(context, EngineeringConstants.SELECT_ATTRIBUTE_CHANGE_CONTROLLED): "";
		  for (int i=0; i < selectedItems.length ;i++)
		  {
		      selectedId = selectedItems[i];
		      //if this is coming from the Full Text Search, have to parse out |objectId|relId|
		      java.util.StringTokenizer strTokens = new java.util.StringTokenizer(selectedItems[i],"|");
		      if ( strTokens.hasMoreTokens())
		      {
		          selectedId = strTokens.nextToken();
		          selectedId = selectedId.trim();
		          sUOMForMarkUp = DomainObject.newInstance(context,selectedId ).getInfo(context, "attribute[Unit of Measure]"); //UOM Management		            
		      }
		      // change callback to addToSelected and xml format
		      DomainRelationship dr = new DomainRelationship();
			if("view".equalsIgnoreCase(tablemode)){
				HashMap hmRelAttributesMap = new HashMap();
				hmRelAttributesMap.put(EngineeringConstants.ATTRIBUTE_FIND_NUMBER,Integer.toString(FNvalue));
				hmRelAttributesMap.put(EngineeringConstants.ATTRIBUTE_UNIT_OF_MEASURE, sUOMForMarkUp);
				HashMap paramMap = new HashMap();
				paramMap.put("objectId", selPartObjectId);
				String[] methodargs = JPO.packArgs(paramMap);
				boolean status =  JPO.invoke(context, "emxENCActionLinkAccess", null, "isApplyAllowed", methodargs,Boolean.class);
				if(status){
					dr =DomainRelationship.connect(context, domObj, EngineeringConstants.RELATIONSHIP_EBOM, DomainObject.newInstance(context, selectedId));
					dr.setAttributeValues(context, hmRelAttributesMap);
					System.out.println(dr.getName());
				}
				if ("true".equalsIgnoreCase(isWipMode)){
			    	  strInput = strInput + "<item oid=\""+ selectedId + "\" pid=\"" + selPartObjectId  + "\" relId=\"" + dr.getName() + "\" relType=\"relationship_EBOM\"><column name=\"CurrentEffectivity\"></column><column name=\"AT_C_Quantity\" edited=\"true\">1.0</column><column name=\"Find Number\" edited=\"true\">"+ FNvalue +"</column><column name=\"UOM\" edited=\"true\">"+ sUOMForMarkUp +"</column><column name=\"VPMVisible\" edited=\"true\">True</column></item>";
			      }else{
			    	  strInput = strInput + "<item oid=\""+ selectedId + "\" pid=\"" + selPartObjectId  + "\" relId=\"" + dr.getName() + "\" relType=\"relationship_EBOMPending\"><column name=\"ProposedEffectivity\">"+displayValue+"</column><column name=\"Add\">"+ecoName+"</column><column name=\"AT_C_Quantity\" edited=\"true\">1.0</column><column name=\"Find Number\" edited=\"true\">"+ FNvalue +"</column><column name=\"UOM\" edited=\"true\">"+ sUOMForMarkUp +"</column><column name=\"VPMVisible\" edited=\"true\">True</column></item>";
			      }
			      //2012x--Ends
			      FNvalue+=incrementIntValue;
			}
			else{
		      //2012x-- proposed effectivity values in the xml are not needed ,hence removed for WIP BOM
		      //strInput = strInput + "<item oid=\""+ selectedId + "\" pid=\"" + selPartObjectId + "\" relType=\"relationship_EBOM\"><column name=\"ProposedEffectivity\">"+displayValue+"</column><column name=\"Add\">"+ecoName+"</column></item>";
		      
		      if ("true".equalsIgnoreCase(isWipMode)){
		    	  strInput = strInput + "<item oid=\""+ selectedId + "\" pid=\"" + selPartObjectId + "\" relType=\"relationship_EBOM\"><column name=\"CurrentEffectivity\"></column><column name=\"AT_C_Quantity\" edited=\"true\">1.0</column><column name=\"Find Number\" edited=\"true\">"+ FNvalue +"</column><column name=\"UOM\" edited=\"true\">"+ sUOMForMarkUp +"</column><column name=\"VPMVisible\" edited=\"true\">True</column></item>";
		      }else{
		    	  strInput = strInput + "<item oid=\""+ selectedId + "\" pid=\"" + selPartObjectId + "\" relType=\"relationship_EBOMPending\"><column name=\"ProposedEffectivity\">"+displayValue+"</column><column name=\"Add\">"+ecoName+"</column><column name=\"AT_C_Quantity\" edited=\"true\">1.0</column><column name=\"Find Number\" edited=\"true\">"+ FNvalue +"</column><column name=\"UOM\" edited=\"true\">"+ sUOMForMarkUp +"</column><column name=\"VPMVisible\" edited=\"true\">True</column></item>";
		      }
		      //2012x--Ends
		      FNvalue+=incrementIntValue;
			}
		    }
    strInput = strInput + "</data></mxRoot>";
          
    strInput = StringUtils.replaceAll(strInput,"&","&amp;");
    
    
  }
%>
<%@include file = "../engineeringcentral/emxEngrCommitTransaction.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
//XSSOK
var isWipBomAllowed = "<%=isWipBomAllowed%>";
var selPartRowId = '|||'+'<%=selPartRowId%>';
var frameName = "<%=frameName%>";
	if ("addToProduct" == "<xss:encodeForJavaScript><%=calledMethod%></xss:encodeForJavaScript>") {

          var parentDetailsFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
          parentDetailsFrame.document.location.href=parentDetailsFrame.document.location.href;
		  //document.location.href=document.location.href;
          getTopWindow().closeWindow();
    } else if ("addExisting" == "<xss:encodeForJavaScript><%=calledMethod%></xss:encodeForJavaScript>") {
	 		//XSSOK
    	//var callbackeval(getTopWindow().getWindowOpener().emxEditableTable.<%=callbackFunctionName%>);
    	var callback = null;
 		if(getTopWindow().getWindowOpener()){
		eval(getTopWindow().getWindowOpener().parent.FreezePaneregister(selPartRowId,"true"));
        	callback = eval(getTopWindow().getWindowOpener().parent.emxEditableTable.<%=callbackFunctionName%>);
        }else{
		eval(findFrame(getTopWindow(),frameName).FreezePaneregister(selPartRowId,"true"));
        	callback  = eval(findFrame(getTopWindow(),"PUEUEBOM").emxEditableTable.<%=callbackFunctionName%>);
        }
    	
		//var status = callback('<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>');
		  //getTopWindow().closeWindow();
    	var oxmlstatus = callback('<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>');  
	 if(!(getTopWindow().getWindowOpener())){
         	eval(findFrame(getTopWindow(),frameName).FreezePaneunregister(selPartRowId,"true"));
         }
         else{
         	eval(getTopWindow().getWindowOpener().parent.FreezePaneunregister(selPartRowId,"true"));
         }
        if(getTopWindow().getWindowOpener())
       	{
       	 	getTopWindow().closeWindow();	 
       	}else{
        	 getTopWindow().closeWindowShadeDialog();
        }
   } else if ("createAndAssignChangeOrder" == "<xss:encodeForJavaScript><%=calledMethod%></xss:encodeForJavaScript>") {
	 var frame = findFrame(getTopWindow(), "PUEUEBOM");
	 
	 if (frame != null && frame != "undefined") {
		 frame.emxEditableTable.refreshStructureWithOutSort();
	 }
 }
</script>
