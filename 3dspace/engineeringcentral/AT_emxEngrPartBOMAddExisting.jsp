<%--  emxEngrPartBOMAddExisting.jsp   - The Processing page for Part connections.
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>


<%!

    public String getMarkup(Context context,String selPartObjectId, String[] selectedItems, String strLanguage, String highestFN, String commonViewAddExisting, String tablemode) throws Exception {			
      String selectedId;    
      //Multitenant
      /* String strStandard = i18nNow.getI18nString("emxEngineeringCentral.Attribute.Usage.Standard",
              "emxEngineeringCentralStringResource",
              strLanguage); */
		//String strStandard = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Attribute.Usage.Standard");
        String sDefaultUsageValue=new AttributeType((String)PropertyUtil.getSchemaProperty(context,"attribute_Usage")).getDefaultValue(context);
        String sDefaultUsage= UIUtil.isNullOrEmpty(sDefaultUsageValue)?"":
    		   EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Attribute.Usage."+sDefaultUsageValue);		   
		String incrementFN = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.StructureBrowser.FNIncrement");
        int FNvalue = 1;
        DomainObject domObj = null;
		String currentState = "";
        StringList eBOMFN;
        if(UIUtil.isNotNullAndNotEmpty(selPartObjectId)){
       	domObj = new DomainObject(selPartObjectId);
       	currentState = domObj.getInfo(context, DomainObject.SELECT_CURRENT);
       	eBOMFN = domObj.getInfoList(context, "from["+ EngineeringConstants.RELATIONSHIP_EBOM+"].attribute["+EngineeringConstants.ATTRIBUTE_FIND_NUMBER+"].value" );
       	FNvalue = (FNvalue<=1)?EngineeringUtil.getHighestNumber(eBOMFN):FNvalue;
        }
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

    	if(highestFN != null && !("0".equals(highestFN))){
    		FNvalue = Integer.parseInt(highestFN);
    	}
    	
        int length = (selectedItems == null) ? 0 : selectedItems.length;        
        StringBuffer sbOut = new StringBuffer(length * 150 + 100);
        if(currentState.equalsIgnoreCase(DomainConstants.STATE_PART_PRELIMINARY) && "view".equalsIgnoreCase(tablemode)){
        	sbOut.append("<mxRoot>").append("<action>add</action>").append("<data status=\"comitted\">");        
        }
        else{
        	sbOut.append("<mxRoot>").append("<action>add</action>").append("<data status=\"pending\">");  
        }
    	
        String vpmControlState = "";
        String strVPMVisibleTrue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.TRUE");  
        String strVPMVisibleFalse = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.FALSE");
        boolean isENGSMBInstalled = EngineeringUtil.isENGSMBInstalled(context, false);        
        
        if(isENGSMBInstalled) {     		
        	String mqlQuery = new StringBuffer(100).append("print bus $1 select $2 dump").toString();
    		vpmControlState = MqlUtil.mqlCommand(context, mqlQuery,selPartObjectId,"from["+DomainConstants.RELATIONSHIP_PART_SPECIFICATION+"|to.type.kindof["+EngineeringConstants.TYPE_VPLM_CORE_REF+"]].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");    		
        } 
        String sUOMForMarkUp = "";//UOM Management: Show the UOM value of Part in the Markup
    	                
        for (int i = 0; i < length; i++) {
			FNvalue+=incrementIntValue;
            //if this is coming from the Full Text Search, have to parse out objectId|relId|
            selectedId = (String) FrameworkUtil.split(selectedItems[i], "|").get(0);
            sUOMForMarkUp = DomainObject.newInstance(context,selectedId ).getInfo(context, EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE); //UOM Management
            String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
			String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
			String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
			DomainRelationship dr = new DomainRelationship();
			if(currentState.equalsIgnoreCase(DomainConstants.STATE_PART_PRELIMINARY) && "view".equalsIgnoreCase(tablemode)){
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
				}
				sbOut.append("<item oid=\"").append(selectedId).append("\" pid=\"").append(selPartObjectId).append("\" relId=\"").append(dr.getName()).append("\" relType=\"relationship_EBOM\">");
				sbOut.append("<column name=\"Find Number\" edited=\"true\">"+ FNvalue +"</column>").append("<column name=\"Reference Designator\" edited=\"true\"></column>");
	            sbOut.append("<column name=\"Usage\" edited=\"true\" actual=\""+sDefaultUsageValue+"\">"+sDefaultUsage+"</column>");              
	            sbOut.append("<column name=\"AT_C_Quantity\" edited=\"true\">1.0</column>");
			}
			else{
				sbOut.append("<item oid=\"").append(selectedId).append("\" pid=\"").append(selPartObjectId).append("\" relType=\"relationship_EBOM\">");
				sbOut.append("<column name=\"Find Number\" edited=\"true\">"+ FNvalue +"</column>").append("<column name=\"Reference Designator\" edited=\"true\"></column>");
	            sbOut.append("<column name=\"Usage\" edited=\"true\" actual=\""+sDefaultUsageValue+"\">"+sDefaultUsage+"</column>");              
	            sbOut.append("<column name=\"AT_C_Quantity\" edited=\"true\">1.0</column>");
			}
            
             if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
            	sbOut.append("<column name=\"VPMVisible\" edited=\"true\" actual=\"False\">"+strVPMVisibleFalse+"</column>");
            } else {
            	sbOut.append("<column name=\"VPMVisible\" edited=\"true\" actual=\"True\">"+strVPMVisibleTrue+"</column>");
            } 
             if(!"true".equalsIgnoreCase(commonViewAddExisting))
            sbOut.append("<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"); //UOM Management
            sbOut.append("</item>");                                 
        }
    
        sbOut.append("</data>").append("</mxRoot>");
        
        return sbOut.toString();    
    }

%>


<%
      String objectId = emxGetParameter(request, "objectId");
      String selPartObjectId = emxGetParameter(request, "selPartObjectId");
      String highestFN = emxGetParameter(request, "highestFN");
      String frameName = emxGetParameter(request, "frameName");
      String tablemode = emxGetParameter(request, "tablemode");
      String selPartRowId = emxGetParameter(request, "selPartRowId");
      boolean refresh = false;
      
  	  String multipleRevisionsNotAllowed = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",locale,"FloatOnEBOMManagement.AddExisting.MultipleRevisionsNotAllowed");
  	  String MultipleRevisionsConflict   = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",locale,"FloatOnEBOMManagement.AddExisting.MultipleRevisionsConflict");
  	    	  
      String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
      String strLanguage         = request.getHeader("Accept-Language");
      String strInput = "";      
      String callbackFunctionName = "addToSelected";

      boolean isMBOMInstalled = EngineeringUtil.isMBOMInstalled(context);
      String commonViewAddExisting = DomainConstants.EMPTY_STRING;
      if(isMBOMInstalled) { 
    	  commonViewAddExisting = emxGetParameter(request, "commonViewAddExisting");
      }
		
      if ("".equals(selPartObjectId) || selPartObjectId == null) {
          selPartObjectId = objectId;
      }
      
      try {          
			
		          strInput = getMarkup(context,selPartObjectId, selectedItems,strLanguage,highestFN, commonViewAddExisting,tablemode);   
		          strInput = FrameworkUtil.findAndReplace(strInput,"'","\\'");           
      } catch (Exception ex) {
          if (ex.toString() != null && (ex.toString().trim()).length() > 0)
              emxNavErrorObject.addMessage(ex.toString().trim()); 
      }  
%>

    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

    <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="javascript" src="../common/scripts/emxUISlideIn.js"></script>
    
    <script language="Javascript">
    
    //refresh the calling structure browser and close the search window  
    //XSSOK

    var parentId               = "<%=selPartObjectId%>";
    var multipleRevsNotAllowed = "<%=multipleRevisionsNotAllowed%>";
    var MultipleRevsConflict   = "<%=MultipleRevisionsConflict%>";
    var selPartRowId = '|||'+'<%=selPartRowId%>';
    var frameName = "<%=frameName%>";
    var isValidationPassed   = validateMultipleRevUseCase();	
	if(isValidationPassed) {
        var callback = null;
        
        if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN || !(getTopWindow().getWindowOpener())){
        	eval(findFrame(getTopWindow(),frameName).FreezePaneregister(selPartRowId,"true"));
        	callback  = eval(findFrame(getTopWindow(),frameName).emxEditableTable.<%=callbackFunctionName%>);
        	
        }
        else{
        	eval(getTopWindow().getWindowOpener().parent.FreezePaneregister(selPartRowId,"true"));
        	callback = eval(getTopWindow().getWindowOpener().parent.emxEditableTable.<%=callbackFunctionName%>);
        	
        }
        var oxmlstatus = callback('<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>');
        
        if(getTopWindow().getWindowOpener())
      	 {
      	 	getTopWindow().closeWindow();	 
      	 }
        else{
       	getTopWindow().closeWindowShadeDialog();
		getTopWindow().closeWindow();
        }    	
    }    
    
    //This is to block use case of adding multiple revisions of same part under a parent
	function validateMultipleRevUseCase() {
    	var fullSearchReference = null;
	if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN || !getTopWindow().getWindowOpener()){
    		fullSearchReference 	= findFrame(getTopWindow(),"<%=frameName%>");
    	}
	else {
		fullSearchReference  = getTopWindow().getWindowOpener().parent;
	}
    	var sbReference 		= null;
    	if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN || !getTopWindow().getWindowOpener()){
    		sbReference 		= findFrame(getTopWindow(),"<%=frameName%>");
    	}else{ 
    		sbReference 		= getTopWindow().getWindowOpener().parent;
    	}
    	
		var selectedRows = emxUICore.selectNodes(fullSearchReference.oXML, "/mxRoot/rows//r[@checked='checked']");
		var nameCell,nameActualVal,revisionCell,revActualVal,existingRevVal,multipleRevRows,alreadyExistingRows;
		if(selectedRows && selectedRows.length > 0) {
  			for(var i=0; i<selectedRows.length; i++) {
  				nameActualVal   = getCellVal(selectedRows[i],"Name",fullSearchReference);
  				revActualVal    = getCellVal(selectedRows[i],"Revision",fullSearchReference);
  				multipleRevRows = emxUICore.selectNodes(fullSearchReference.oXML,"/mxRoot/rows//r[@checked='checked' and child::c[@a='"+nameActualVal+"']]");
  				
  				//Block the use case if multiple revisions were selected for same part
  				if(multipleRevRows && multipleRevRows.length > 1) {  					
  					fullSearchReference.setSubmitURLRequestCompleted();
  					multipleRevsNotAllowed = multipleRevsNotAllowed.replace("CHILDNAME", getCellVal(selectedRows[i],"Name",fullSearchReference,"display"));  					
  					alert(multipleRevsNotAllowed);
  					return false;
  				}
  				
  				alreadyExistingRows = emxUICore.selectNodes(sbReference.oXML,"/mxRoot/rows//r[@p='"+parentId+"' and child::c[@a='"+nameActualVal+"']]");  				
  				if(alreadyExistingRows && alreadyExistingRows.length > 0) {
  					for(var i=0; i<alreadyExistingRows.length; i++) {
  						existingRevVal  = getCellVal(alreadyExistingRows[i],"Revision",sbReference);
  						if(existingRevVal != revActualVal) {  							
  							fullSearchReference.setSubmitURLRequestCompleted();
  							
  							var parentRow = emxUICore.selectSingleNode(sbReference.oXML, "/mxRoot/rows//r[@o='"+parentId+"']");
  							MultipleRevsConflict = MultipleRevsConflict.replace("CHILDNAME", getCellVal(alreadyExistingRows[i],"Name",sbReference,"display"));
  							MultipleRevsConflict = MultipleRevsConflict.replace("CHILDREVISION", getCellVal(alreadyExistingRows[i],"Revision",sbReference,"display"));
  							MultipleRevsConflict = MultipleRevsConflict.replace("PARENTNAME", getCellVal(parentRow,"Name",fullSearchReference,"display"));  							
  												
  							alert(MultipleRevsConflict);   								  							  						
  							return false;
  						}
  					}
  				}  				
  			}
		}
		return true;
	} 
    
	function getCellVal(tRow,colName,reference) {
		return getCellVal(tRow,colName,reference,"actual");
	}
    
    function getCellVal(tRow,colName,reference,valueType) {
        var objColumn = reference.colMap.getColumnByName(colName);
        var colIndex  = objColumn ? objColumn.index : 0;
        var tCell     = emxUICore.selectSingleNode(tRow, "c[" + colIndex + "]");
        return ("actual" == valueType) ? tCell.getAttribute("a") : emxUICore.getText(tCell); 
    }
          
    </script>
