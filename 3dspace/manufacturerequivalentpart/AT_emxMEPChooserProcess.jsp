<%--  emxMEPChooserProcess.jsp

  Copyright Dassault Systemes, 2007. All rights reserved
  This program is proprietary property of Dassault Systemes and its subsidiaries.
  This documentation shall be treated as confidential information and may only be used by employees or contractors
  with the Customer in accordance with the applicable Software License Agreement
  static const char RCSID[] = $Id: /ENOManufacturerEquivalentPart/CNext/webroot/manufactuerequivalentpart/emxMEPChooserProcess.jsp 1.4.2.1.1.1 Wed Oct 29 22:14:50 2008 GMT przemek Experimental$
  
  Revision History: Cloned from OOTB JSP and commented 2 lines of code for redmine ticket #6612 QC 4566 
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../manufacturerequivalentpart/scripts/emxMEPFormValidation.js"%>
<%@page import="com.matrixone.apps.domain.DomainConstants,com.matrixone.apps.domain.util.MapList,matrix.util.StringList,com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.util.*"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
    String timeStamp = emxGetParameter(request, "timeStamp");
    String populateRevision = emxGetParameter(request, "populateRevision");
    String searchMode = emxGetParameter(request, "searchMode");
   
    // Modification for TypeAhead
    String typeAhead        = emxGetParameter(request, "typeAhead");
    String frameName        = emxGetParameter(request, "frameName");
    // End Modification
    
    boolean autoPopulateRev = false ; 
    if(populateRevision == null ) {
    	autoPopulateRev = true ; 
    }
    String sObjectIds[] = emxGetParameterValues(request,"emxTableRowId");
    HashMap requestMap = null;
   
    if(!"fullTextSearch".equalsIgnoreCase(searchMode))
    {
    	requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
    }
    String fieldName = emxGetParameter(request,"fieldName");
    String clearManuLoc = null;
    if(requestMap!=null )
    {
     clearManuLoc = (String)requestMap.get("clearManuLoc");
    }
    else
    {
       clearManuLoc =   emxGetParameter(request,"clearManuLoc");
    }
    
    //Added IR-010681 & IR-010742 
    String sFlagVal		  = "false";
    String defaultValue   = "";
    String sformname      = null;
    String clearCustomRev = null;
    if(requestMap!=null)
    {
         sformname = (String) requestMap.get("formname");
         clearCustomRev = (String) requestMap.get("clearCustomRev");
    }
    else
    {
         sformname      = emxGetParameter(request,"formname");
         clearCustomRev = emxGetParameter(request,"clearCustomRev");
    }
    
   
    String screateform    = PropertyUtil.getSchemaProperty(context , "form_type_CreateMEP");
    String seditform      = PropertyUtil.getSchemaProperty(context , "form_type_Part");
    String customRevision = FrameworkProperties.getProperty(context, "emxManufacturerEquivalentPart.MEP.allowCustomRevisions");
    if ((("true".equalsIgnoreCase(customRevision)) || (seditform.equals(sformname)))
    		&& "true".equalsIgnoreCase(clearCustomRev)) {
		sFlagVal		= "true";
		HashMap hargs	=	new HashMap();
		hargs.put("orgId",sObjectIds[0]);
		HashMap hMap 	= (HashMap) JPO.invoke(context, "jpo.manufacturerequivalentpart.Part",
												null, "getRevisionValue",
												JPO.packArgs (hargs), HashMap.class);
		String CompId   =   (String)hMap.get("CompId");
		String CageCode =   (String)hMap.get("CageCode");
		String uniqueIdentifier =   (String)hMap.get("uniqueIdentifier");
		String revSeq   =   ((StringBuffer)hMap.get("revSeqValue")).toString();
		if( "attribute_OrganizationID".equals(uniqueIdentifier))
		{
			defaultValue=CompId;
		}
		else if("attribute_CageCode".equals(uniqueIdentifier))
		{
			defaultValue=CageCode;
		}
		else
		{
			StringList Idxvalues=FrameworkUtil.split(revSeq, ",");
			defaultValue=(String)Idxvalues.get(0);
        }
	}
    //Ends IR-010681 & IR-010742 
    if(fieldName==null){
    	if(requestMap!=null)
    	{
    		fieldName=(String)requestMap.get("fieldNameDisplay");
    	}
    	else
	    {
	    	fieldName= emxGetParameter(request,"fieldNameDisplay");
	    }
    }

    String fieldOId = emxGetParameter(request,"fieldOId");
    if(fieldOId==null){
    	if(requestMap!=null)
    	     fieldOId=(String)requestMap.get("fieldNameActual");
    	else    
    	     fieldOId= emxGetParameter(request,"fieldNameActual");
   
    }
    StringBuffer sbObjName = new StringBuffer();
    StringBuffer sbObjId = new StringBuffer();
    StringList objectSelects = new StringList(1);
    objectSelects.add(DomainObject.SELECT_NAME);
    objectSelects.add(DomainObject.SELECT_ID);
    String sObjIds[] = new String[1];
    StringTokenizer sToken = new StringTokenizer(sObjectIds[0],"|");
    if(sToken.hasMoreTokens())
    {
         sObjIds[0] = sToken.nextToken();
    }
    
    MapList mapList = DomainObject.getInfo(context,sObjIds,objectSelects);
    for(int i=0,arrayLen = mapList.size();i < arrayLen;i++)
    {
        Map map = (Map)mapList.get(i);
        String strObjName = (String)map.get("name");
        String strObjId = (String)map.get("id");
        if(i>=1){sbObjName.append(",");sbObjId.append(",");}
            sbObjName.append(strObjName);
            sbObjId.append(strObjId);
    }
%>
<script>

   // Modification for enabling Full Text search
   var typeAhead = "<%=XSSUtil.encodeForJavaScript(context,typeAhead)%>";
   var targetWindow = null;
  
  
    if(typeAhead == "true")
    {
        var frameName = "<%=XSSUtil.encodeForJavaScript(context,frameName)%>";
        if(frameName == null || frameName == "null" || frameName == "") {
            targetWindow = window.parent;
        } else {
            targetWindow = getTopWindow().findFrame(window.parent, frameName);
        }
    } else {
        targetWindow = getTopWindow().getWindowOpener();
    }
  
  var vfieldNameActual  = targetWindow.getTopWindow().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldName)%>")[0];
  if(vfieldNameActual== undefined){
	  vfieldNameActual = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldName)%>")[0];
  }
  var vfieldNameOID     = targetWindow.getTopWindow().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldOId)%>")[0];
  if(vfieldNameOID== undefined){
	  vfieldNameOID = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldOId)%>")[0];
	  }
    var vRevision         = targetWindow.getTopWindow().document.getElementsByName("Revision")[0];  
  if(vRevision == undefined){	  
	  vRevision         = targetWindow.document.getElementsByName("Revision")[0];
  }
  
  if(vRevision != undefined){
	  vRevision = vRevision.value;
  }
  
   // End Modification
  var topFrameObj;
   if(getTopWindow().getWindowOpener() && getWindowOpener() != null)
   {
    topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"searchContent");

  
   if(topFrameObj=="" || topFrameObj==null)
  {
     topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"searchPane");
  }

  if(topFrameObj=="" || topFrameObj==null)
  {
     topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"pagecontent");
  }

  if(topFrameObj=="" || topFrameObj==null)
  {
     topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"formEditDisplay");
  }

   }  if(eval(topFrameObj))
  {
	   //XSSOK
    topFrameObj.document.forms[0].<%=XSSUtil.encodeForJavaScript(context,fieldName)%>.value = '<%=sbObjName.toString()%>';

    <%
    if(fieldOId != null)
    {
    %>
     if(eval("topFrameObj.document.forms[0].<%=XSSUtil.encodeForJavaScript(context,fieldOId)%>"))
    {
    	 //XSSOK
        topFrameObj.document.forms[0].<%=XSSUtil.encodeForJavaScript(context,fieldOId)%>.value = '<%=sbObjId.toString()%>';
    }
	<%
    }
    %>
    }else{
//XSSOK
    vfieldNameActual.value='<%=XSSUtil.encodeForJavaScript(context,sbObjName.toString())%>';
    vfieldNameOID.value='<%=XSSUtil.encodeForJavaScript(context,sbObjId.toString())%>';

    targetWindow.getTopWindow().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldName)%>")[0] = vfieldNameActual.value;
    targetWindow.getTopWindow().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldOId)%>")[0] = vfieldNameOID.value;
  // commented out for MEP type ahead
    //if(getTopWindow().getWindowOpener().document.forms[0].Revision && "<%=autoPopulateRev%>" == 'true'){
    
    	//XSSOK
    if( vRevision && "<%=autoPopulateRev%>" == 'true'){
       
		if(typeAhead == "true") {
			/*if(eval(getTopWindow().getWindowOpener())) {
	            getTopWindow().loadRevision(targetWindow);
                getTopWindow().setRevision(targetWindow);
			} else {	*/
				targetWindow.loadRevision(targetWindow);
                targetWindow.setRevision(targetWindow);
			//}
		 } else {
			 // Commented the lines for External Request #6612 QC 4566 - START
                //getTopWindow().getWindowOpener().loadRevision(targetWindow);
                //getTopWindow().getWindowOpener().setRevision(targetWindow);
				// Commented the lines for External Request #6612 QC 4566 - END
		 }       
 	}

   }

   if('<%=XSSUtil.encodeForJavaScript(context,clearManuLoc)%>'=="true"){

		 if(typeAhead == "true")
		 {
			 targetWindow.document.forms[0].ManufacturerLocationDisplay.value = '';
			 
		 } else{
    getTopWindow().getWindowOpener().document.forms[0].ManufacturerLocationDisplay.value = '';
   }
	}
    
   //Added IR-010681 & IR-010742 
   //XSSOK
   if("true" == '<%=sFlagVal%>') {
	   //XSSOK  
       if ('<%=seditform%>' == '<%=XSSUtil.encodeForJavaScript(context,sformname)%>') {
    	   //XSSOK
			getTopWindow().getWindowOpener().document.forms[0].Revision.value = '<%=defaultValue%>';
			//XSSOK
        } else if ('<%=screateform%>' == '<%=XSSUtil.encodeForJavaScript(context,sformname)%>') {
        	//XSSOK
			getTopWindow().getWindowOpener().document.forms[0].CustomRevision.value = '<%=defaultValue%>';
			//XSSOK
       		getTopWindow().getWindowOpener().document.forms[0].revision.value = '<%=defaultValue%>';
		}
   }
   //Ends IR-010681 & IR-010742 
   
   // added for Type Adhead
    if(typeAhead != "true")
        getTopWindow().closeWindow();

</script>
