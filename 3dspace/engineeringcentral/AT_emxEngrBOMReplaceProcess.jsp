<%--  emxEngrBOMReplaceProcess.jsp -  This page Call the Bean to invoke JPO for resequence BOM.
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
   modified as part of ALSTOM - Redmine ticket 6893 - Replace Part in Bom doesn't keep quantity
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<jsp:useBean id="replacePart" class="com.matrixone.apps.engineering.Part" scope="session" />
<jsp:useBean id="connectPart" class="com.matrixone.apps.engineering.Part" scope="session" />
<%@page import="com.matrixone.apps.engineering.Part" %>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%


//read the necessary parameters from the posted data
String languageStr   = request.getHeader("Accept-Language");
String objId = emxGetParameter(request, "objectId");
String partFamilyContextId = emxGetParameter(request,"partFamilyContextId");
String selPartObjectId = emxGetParameter(request,"selPartObjectId");
String selPartParentOId = emxGetParameter(request,"selPartParentOId");
String createdPartObjId = emxGetParameter(request,"createdPartObjId");
String radioOption = emxGetParameter(request,"radioBOM");
String selPartRelId = emxGetParameter(request,"selPartRelId");
String replaceWithExisting = emxGetParameter(request,"replaceWithExisting");
String relType = emxGetParameter(request,"relType");
String tablemode = emxGetParameter(request,"tablemode");
//Added for V6R2009.HF0.2 - Starts
 // Commented and added for Part Create conversion to common comp. R211
//String selPartRowId = (String)session.getAttribute("selPartRowId");
String selPartRowId         = "";
String sErrorSynchro = "";
boolean isReplaceForSynchro = false;

String expandLevel = emxGetParameter(request,"expandLevel");

//System.out.println("expandLevel : "+expandLevel);

if (replaceWithExisting!=null && !("null".equals(replaceWithExisting)) && replaceWithExisting.equals("true"))
{
	selPartRowId = (String)session.getAttribute("selPartRowId");
} else {
	selPartRowId   = emxGetParameter(request,"sRowId");
}

StringList slExpandLevel = FrameworkUtil.split(selPartRowId, ",");
int iExpandLevel = slExpandLevel.size()-1;

//System.out.println("selPartRowId : "+selPartRowId);
//System.out.println("iExpandLevel : "+iExpandLevel);


//Start : Added for IR-044888V6R2011
int iselPartParentRowId = selPartRowId.lastIndexOf(",");
String selPartParentRowId = selPartRowId.substring(0,iselPartParentRowId);
//End : IR-044888V6R2011
session.removeAttribute("selPartRowId");
//Added for V6R2009.HF0.2 - Ends


if (relType == null || "".equals(relType)) {
	relType = "EBOM";
}

String symRelType = FrameworkUtil.getAliasForAdmin(context,"relationship",relType,true);
    String totalCount = emxGetParameter(request,"totalCount");
String[] checkBoxArray =  {"|||"+selPartRowId};
String rid = selPartRowId.substring(0, selPartRowId.lastIndexOf(","));
String sParentRowId = "|||"+selPartRowId.substring(0, selPartRowId.lastIndexOf(","));
//XML string input to the callBack function
String strInput = "<mxRoot>";
//Modified the parent row to support rowId
//Start : Modified for IR-044888V6R2011
if(!"view".equalsIgnoreCase(tablemode)){
	strInput = strInput + "<object objectId=\"" + selPartParentOId + "\" rowId=\""+selPartParentRowId+"\">";
}
//End : IR-044888V6R2011
String callbackFunctionName = "loadMarkUpXML";
String newPart = "";

HashMap paramMap = new HashMap();

try {
	final String ATTRIBUTE_QUANTITY = PropertyUtil.getSchemaProperty("attribute_AT_C_Quantity");
	final String SELECT_ATTRIBUTE_QUANTITY = "attribute["+ATTRIBUTE_QUANTITY+"].value";

     ContextUtil.startTransaction(context, true);

    DomainRelationship selPartDomObj = DomainRelationship.newInstance(context,selPartRelId);
    Map attrMap = (Map)selPartDomObj.getAttributeMap(context);
    String CompLocation = (String) attrMap.get(DomainConstants.ATTRIBUTE_COMPONENT_LOCATION);
    String FindNumber = (String) attrMap.get(DomainConstants.ATTRIBUTE_FIND_NUMBER);     
    String RefDesig = (String) attrMap.get(DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR);     
    String Usage = (String) attrMap.get(DomainConstants.ATTRIBUTE_USAGE); 
    String strUsage = FrameworkUtil.findAndReplace(i18nNow.getRangeI18NString("Usage", Usage, languageStr),"'","\\'");
    //String Qty = (String) attrMap.get(DomainConstants.ATTRIBUTE_QUANTITY);
    String Qty = (String) attrMap.get(ATTRIBUTE_QUANTITY);
	int fnValue=Integer.parseInt(FindNumber);
    StringList fnValueUnderParentObject = DomainObject.newInstance(context, selPartParentOId).getInfoList(context, "from["+relType+"].attribute["+EngineeringConstants.ATTRIBUTE_FIND_NUMBER+"].value");
    int sHighestFn = getHighestNumber(fnValueUnderParentObject);
	
	StringList slDeformedInstanceToDelete = null;
	String sParentProductId = null;	
		
    // Creating and Adding select statements for the object
    SelectList resultSelects = new SelectList(8);
    resultSelects.add(DomainObject.SELECT_ID);
    resultSelects.add(DomainObject.SELECT_TYPE);
    resultSelects.add(DomainObject.SELECT_NAME);
    resultSelects.add(DomainObject.SELECT_REVISION);
    resultSelects.add(DomainObject.SELECT_DESCRIPTION);
    resultSelects.add(DomainObject.SELECT_CURRENT);
    resultSelects.add(DomainObject.SELECT_OWNER);
    resultSelects.addElement(DomainConstants.SELECT_POLICY);
    resultSelects.addElement(DomainConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);//UOM Management.

    // Creating and Adding select statements for the relationsip object
    StringList selectRelStmts = new StringList(6);
    selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);
    //selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_QUANTITY);
    selectRelStmts.addElement(SELECT_ATTRIBUTE_QUANTITY);
    selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);
    selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_COMPONENT_LOCATION);
    selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_USAGE);
    selectRelStmts.addElement(Part.SELECT_RELATIONSHIP_ID);
	Part selPartParentOId1 = new Part(selPartParentOId);
    String selPartParentCurrent = selPartParentOId1.getInfo(context, DomainObject.SELECT_CURRENT);
    // Create new object with the part selected in BOM
    Part selPart = new Part(selPartObjectId);
	String strObjType = (String) selPart.getInfo(context, DomainConstants.SELECT_TYPE);
    // Get the BOM under the part selected in BOM
    MapList ebomList = selPart.getEBOMs(context, resultSelects, selectRelStmts, false);
	DomainRelationship domRelation = new DomainRelationship(selPartRelId);
    
    String vpmControlState = "";
    String strVPMVisibleTrue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.TRUE");  
    String strVPMVisibleFalse = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.FALSE");
    boolean isENGSMBInstalled = EngineeringUtil.isENGSMBInstalled(context, false); 
     
    if(isENGSMBInstalled) { 		
    	String mqlQuery = new StringBuffer(100).append("print bus $1 select $2 dump").toString();
		vpmControlState = MqlUtil.mqlCommand(context, mqlQuery,selPartParentOId,"from["+DomainConstants.RELATIONSHIP_PART_SPECIFICATION+"|to.type.kindof["+EngineeringConstants.TYPE_VPLM_CORE_REF+"]].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");		
    }
	
	if(selPartParentCurrent.equalsIgnoreCase(DomainObject.STATE_PART_PRELIMINARY) && "view".equalsIgnoreCase(tablemode)){
        Map attrMap1 = domRelation.getAttributeMap(context, true);
    	if (replaceWithExisting.equals("true") && !totalCount.equals("")) {
            Integer count = new Integer(totalCount);
	        String selPartIds[] = (String[])session.getValue("selPartIds");
	        strInput = strInput + "<action>add</action>";
	        strInput = strInput + "<data status=\"commited\">";
	    	for(int i=0; i<count.intValue(); i++) {
	    		
	    		newPart = selPartIds[i];
    	      String sUOMForMarkUp = DomainObject.newInstance(context,newPart).getInfo(context,EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
    	      String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
    		  String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
    		  String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
		        if(i<1){
		        	String cmd = "mod connection $1_relID $2_direction $3_destinationid";
					MqlUtil.mqlCommand(context, cmd, selPartRelId, "to", newPart);
					new DomainRelationship(selPartRelId).setAttributeValues(context, attrMap1);
					 
	    	    	  strInput = strInput + "<item oid=\"";
	    	    	  strInput = strInput + selPartIds[i];
	    	    	  strInput = strInput + "\" pid=\"";
	    	    	  strInput = strInput + selPartParentOId;
	    	    	   strInput = strInput + "\" id=\"";
	    	    	  strInput = strInput + rid; 
	    	    	  strInput = strInput + "\" relType=\""+symRelType+"\" relId=\""+selPartRelId+"\">";
	    	    	  

		            
		                //strInput = strInput + "<object objectId=\"" + selPartIds[i] + "\" relId=\"\" relType=\"" + symRelType + "\" pasteAction=\"pasteBelow\" rowIdForPasteAction=\""+ selPartRowId +"\" markup=\"add\" param1=\""+selPartRelId+"\" param2=\""+selPartObjectId+"\" param3=\"replace\">";
		                // Modified for V6R2009.HF0.2 - Ends
	    			    // Adding EBOM attributes to the replaced part.
	    			    
	    			    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+FindNumber+"</column>";
	    			    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\">"+RefDesig+"</column>";
	    			    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\">"+CompLocation+"</column>";
	    			    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+Qty+"</column>";
	    			    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\" a=\""+Usage+"\">"+strUsage+"</column>";
	    			    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
	    			    
	    			    //Added for Common View Replace operation
	    			    
	    			     if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
	    			    	 strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"False\">"+strVPMVisibleFalse+"</column>";
	    			     } else {
	    			    	 strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"True\">"+strVPMVisibleTrue+"</column>";
	    			     } 
	    			    
	    			    if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)){
	    			    	strInput = strInput + "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Stype\" edited=\"true\">Unassigned</column><column name=\"Switch\" edited=\"true\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
	    			    }
	    			    //strInput = strInput + "</object>";
	    			    strInput = strInput + "</item>";
	    			    //strInput = strInput + "</data>";
		        }
		        else{
			        attrMap1.put(DomainConstants.ATTRIBUTE_FIND_NUMBER, fnValue+"");
				    Relationship newRelation = new BusinessObject(selPartParentOId).connect(context, new RelationshipType(EngineeringConstants.RELATIONSHIP_EBOM),true, new BusinessObject(newPart));
			    	new DomainRelationship(newRelation).setAttributeValues(context, attrMap1);
	    	    	  strInput = strInput + "<item oid=\"";
	    	    	  strInput = strInput + selPartIds[i];
	    	    	  strInput = strInput + "\" pid=\"";
	    	    	  strInput = strInput + selPartParentOId;
	    	    	  strInput = strInput + "\" id=\"";
	    	    	  strInput = strInput + rid; 
	    	    	  strInput = strInput + "\" relType=\""+symRelType+"\" relId=\""+newRelation.getName()+"\">";
	    			    //strInput = strInput + "<object objectId=\"" + selPartIds[i] + "\" relId=\"" + selPartRelId + "\" relType=\"" + symRelType + "\" markup=\"add\" param1=\""+selPartRelId+"\" param2=\""+selPartObjectId+"\">";
	    			    //Added for Common View Replace opertaion : Start
	    			        if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)){
	        			strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\"></column>";
	    			    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\"></column>";
	    			    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\"></column>";
	        			strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\"></column>";
	    			    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\" a=\""+Usage+"\">"+strUsage+"</column>";
	    			    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
	    			     
	    			    if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
	    			    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"False\">"+strVPMVisibleFalse+"</column>";
	    			    } else {
	    			    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"True\">"+strVPMVisibleTrue+"</column>";
	    			    } 
	    			    
	    			    strInput = strInput + "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Stype\" edited=\"true\">Unassigned</column><column name=\"Switch\" edited=\"true\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
	    			    //Added for Common View Replace opertaion : End
	    			    }
	    			   // strInput = strInput + "</object>";
	    			        strInput = strInput + "</item>";
	        			    //strInput = strInput + "</data>";
		    	}
		        fnValue = sHighestFn+i+1;
	    	}
	    	strInput = strInput + "</data></mxRoot>";
    	}else{
    		newPart = createdPartObjId;
    		String cmd = "mod connection $1_relID $2_direction $3_destinationid";
			MqlUtil.mqlCommand(context, cmd, selPartRelId, "to", newPart);
			new DomainRelationship(selPartRelId).setAttributeValues(context, attrMap1);
		      //UOM Management: Show the UOM value of Part in the Markup - start
		      String sUOMForMarkUp = DomainObject.newInstance(context,newPart).getInfo(context,EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
		      String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
			  String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
			  String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
		      //UOM Management: Show the UOM value of Part in the Markup - end
			strInput = strInput + "<action>add</action>";
	        strInput = strInput + "<data status=\"commited\">";

		    
	        strInput = strInput + "<item oid=\"";
	    	  strInput = strInput + createdPartObjId;
	    	  strInput = strInput + "\" pid=\"";
	    	  strInput = strInput + selPartParentOId;
	    	   strInput = strInput + "\" id=\"";
	    	  strInput = strInput + rid; 
	    	  strInput = strInput + "\" relType=\""+symRelType+"\" relId=\""+selPartRelId+"\">";

	        // Modified for V6R2009.HF0.2 - Starts
		     //   strInput = strInput + "<object objectId=\"" + createdPartObjId + "\" relId=\"" + selPartRelId + "\" relType=\"" + symRelType + "\" pasteAction=\"pasteBelow\" rowIdForPasteAction=\""+ selPartRowId +"\" markup=\"add\" param1=\""+selPartRelId+"\" param2=\""+selPartObjectId+"\" param3=\"replace\">";
		        // Modified for V6R2009.HF0.2 - Ends
		    // Adding EBOM attributes to the replaced part.
		    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+FindNumber+"</column>";
		    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\">"+RefDesig+"</column>";
		    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\">"+CompLocation+"</column>";
		    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+Qty+"</column>";
		    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\" a=\""+Usage+"\">"+strUsage+"</column>";
		    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
		    
		    if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
		    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"False\">"+strVPMVisibleFalse+"</column>";
		    } else {
		    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"True\">"+strVPMVisibleTrue+"</column>";
		    }
		    
		    //Added for Common View Replace opertaion
		    if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)){
		    strInput = strInput + "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Stype\" edited=\"true\">Unassigned</column><column name=\"Switch\" edited=\"true\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
		    }
		    strInput = strInput + "</item>";
		    //strInput = strInput + "</object>";
		    strInput = strInput + "</data></mxRoot>";
    	}
    	if (radioOption.equals("replaceWithExistingBOM")) {
    	    if (ebomList!=null) {
    	    	fnValueUnderParentObject = DomainObject.newInstance(context, newPart).getInfoList(context, "from["+ EngineeringConstants.RELATIONSHIP_EBOM+"].attribute["+EngineeringConstants.ATTRIBUTE_FIND_NUMBER+"].value");
    	        sHighestFn = getHighestNumber(fnValueUnderParentObject);
		    	Iterator ebomItr = ebomList.iterator();
		        while (ebomItr.hasNext()) {
					sHighestFn = sHighestFn+1;
			        Map newMap = (Map) ebomItr.next();
			        String sObjId = (String) newMap.get("id");
			        String relId = (String) newMap.get("id[connection]");
			        attrMap1 = DomainRelationship.newInstance(context, relId).getAttributeMap(context, true);
			        Relationship newRelation1 = new BusinessObject(newPart).connect(context, new RelationshipType(EngineeringConstants.RELATIONSHIP_EBOM),true, new BusinessObject(sObjId));
			        attrMap1.put(DomainConstants.ATTRIBUTE_FIND_NUMBER, sHighestFn+"");
			        new DomainRelationship(newRelation1).setAttributeValues(context, attrMap1);
		        }
    	    }
    	}
	}
    else{
    
    // Check if the Option choosen is replace with existing Action command
    if (replaceWithExisting.equals("true") && !totalCount.equals("")) {
        Integer count = new Integer(totalCount);
    String selPartIds[] = (String[])session.getValue("selPartIds");
	
    //Start : Modified for IR-044888V6R2011
    //Remove the selected part from BOM
    strInput = strInput + "<object objectId=\"" + selPartObjectId + "\" relId=\"" + selPartRelId + "\" relType=\"" + symRelType + "\" markup=\"cut\" param1=\"replace\" rowId=\""+ selPartRowId +"\"></object>";
    //End : IR-044888V6R2011

    for(int i=0; i<count.intValue(); i++) {
    // Add the existing part and update EBOM attributes of the removed part
    	
        //UOM Management: Show the UOM value of Part in the Markup - start
      newPart = selPartIds[i];
      String sUOMForMarkUp = DomainObject.newInstance(context,newPart).getInfo(context,EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
      String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
	  String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
	  String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
      //UOM Management: Show the UOM value of Part in the Markup - end
    if(i<1) {
    //newPart = selPartIds[i];
    // Call the Bean to invoke JPO
	
   	//System.out.println("before replacePartinBOM");
   	
   	//System.out.println("strObjType : "+strObjType);

   	if(strObjType.equals("AT_C_DESIGN_PART") || strObjType.equals("AT_C_COS") || strObjType.equals("AT_C_STANDARD_PART")){
   		 HashMap mEBOMLinkInfo = new HashMap();
   		 mEBOMLinkInfo.put("objectId", selPartObjectId);
   		 mEBOMLinkInfo.put("relId", selPartRelId);

   		 String[] ebomLinkArgs = JPO.packArgs(mEBOMLinkInfo);
   		 Map mVPMInstanceInfo = JPO.invoke(context,"AT_emxDeformable", null, "getVPMInstanceInfoFromEBOMLink", ebomLinkArgs,Map.class); 
   		 
   		 //System.out.println("mVPMInstanceInfo : "+mVPMInstanceInfo);
   		 
   		 if(mVPMInstanceInfo.containsKey("listOfDeformedInstanceToDelete")){ slDeformedInstanceToDelete = (StringList) mVPMInstanceInfo.get("listOfDeformedInstanceToDelete");}
   		 if(mVPMInstanceInfo.containsKey("sParentProductId")){ sParentProductId = (String) mVPMInstanceInfo.get("sParentProductId");}

   		 //replacePart.replacePartinBOM(context, selPartRelId, selPartObjectId, selPartIds[i], selPartParentOId, partFamilyContextId, radioOption);
   		 
		try {
			DomainObject doObj = DomainObject.newInstance(context, selPartIds[i]);	
			DomainRelationship.setToObject(context, selPartRelId, doObj);
			
			isReplaceForSynchro = true;
		
		} catch (FrameworkException e) {
			e.printStackTrace();
		}	
				
   	}	
   	//System.out.println("after replacePartinBOM");
	
	// Modified for V6R2009.HF0.2 - Starts
	strInput = strInput + "<object objectId=\"" + selPartIds[i] + "\" relId=\"\" relType=\"" + symRelType + "\" pasteAction=\"pasteBelow\" rowIdForPasteAction=\""+ selPartRowId +"\" markup=\"add\" param1=\""+selPartRelId+"\" param2=\""+selPartObjectId+"\" param3=\"replace\">";
	// Modified for V6R2009.HF0.2 - Ends
    // Adding EBOM attributes to the replaced part.
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+FindNumber+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\">"+RefDesig+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\">"+CompLocation+"</column>";
    //strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+Qty+"</column>";
    strInput = strInput + "<column name=\""+ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+Qty+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\" a=\""+Usage+"\">"+strUsage+"</column>";
    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
    //Added for Common View Replace operation
    
     if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
    	 strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"False\">"+strVPMVisibleFalse+"</column>";
     } else {
    	 strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"True\">"+strVPMVisibleTrue+"</column>";
     } 
    
    if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)){
    strInput = strInput + "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Stype\" edited=\"true\">Unassigned</column><column name=\"Switch\" edited=\"true\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
    }
    strInput = strInput + "</object>";
    
    } else {
    //connectPart.connectPartToBOMBean(context, selPartParentOId, selPartIds[i], relType);
    //Modified for Common View Replace operation    
    strInput = strInput + "<object objectId=\"" + selPartIds[i] + "\" relId=\"" + selPartRelId + "\" relType=\"" + symRelType + "\" markup=\"add\" param1=\""+selPartRelId+"\" param2=\""+selPartObjectId+"\">";
    //Added for Common View Replace opertaion : Start
        if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)){
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\"></column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\"></column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\"></column>";
    //strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\"></column>";
    strInput = strInput + "<column name=\""+ATTRIBUTE_QUANTITY+"\" edited=\"true\"></column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\" a=\""+Usage+"\">"+strUsage+"</column>";
    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
     
    if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"False\">"+strVPMVisibleFalse+"</column>";
    } else {
    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"True\">"+strVPMVisibleTrue+"</column>";
    } 
    
    strInput = strInput + "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Stype\" edited=\"true\">Unassigned</column><column name=\"Switch\" edited=\"true\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
    //Added for Common View Replace opertaion : End
    }
    strInput = strInput + "</object>";
    }
      
    }
    }
    // Check if the option choosen is replace with new part.
    else if(!"".equals(createdPartObjId)){
    newPart = createdPartObjId;
    // Call the Bean to invoke JPO
    // replacePart.replacePartinBOM(context, selPartRelId, selPartObjectId, createdPartObjId, selPartParentOId, partFamilyContextId, radioOption);
    //Start : Modified for IR-044888V6R2011
    
    //UOM Management: Show the UOM value of Part in the Markup - start
      String sUOMForMarkUp = DomainObject.newInstance(context,newPart).getInfo(context,EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
      String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
	  String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
	  String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
      //UOM Management: Show the UOM value of Part in the Markup - end
    
    
    strInput = strInput + "<object objectId=\"" + selPartObjectId + "\" relId=\"" + selPartRelId + "\" relType=\"" + symRelType + "\" markup=\"cut\" param1=\"replace\" rowId=\""+ selPartRowId +"\"></object>";
    //End : IR-044888V6R2011
        // Modified for V6R2009.HF0.2 - Starts
        strInput = strInput + "<object objectId=\"" + createdPartObjId + "\" relId=\"" + selPartRelId + "\" relType=\"" + symRelType + "\" pasteAction=\"pasteBelow\" rowIdForPasteAction=\""+ selPartRowId +"\" markup=\"add\" param1=\""+selPartRelId+"\" param2=\""+selPartObjectId+"\" param3=\"replace\">";
        // Modified for V6R2009.HF0.2 - Ends
    // Adding EBOM attributes to the replaced part.
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+FindNumber+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\">"+RefDesig+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\">"+CompLocation+"</column>";
    //strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+Qty+"</column>";
    strInput = strInput + "<column name=\""+ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+Qty+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\" a=\""+Usage+"\">"+strUsage+"</column>";
    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
    
    if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"False\">"+strVPMVisibleFalse+"</column>";
    } else {
    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"True\">"+strVPMVisibleTrue+"</column>";
    }
    
    //Added for Common View Replace opertaion
    if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)){
    strInput = strInput + "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Stype\" edited=\"true\">Unassigned</column><column name=\"Switch\" edited=\"true\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
    }
    strInput = strInput + "</object>";
    }
    // Check if the option choosen is replace with the BOM of existing part
    if (radioOption.equals("replaceWithExistingBOM")) {
    if (ebomList!=null) {
    strInput = strInput + "</object>";
    strInput = strInput + "<object objectId=\"" + newPart + "\">";
    Iterator ebomItr = ebomList.iterator();
    while (ebomItr.hasNext()) {
    Map newMap = (Map) ebomItr.next();
    String sObjId = (String) newMap.get("id");
    String relId = (String) newMap.get("id[connection]");
    String NewCompLocation = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_COMPONENT_LOCATION);
    String NewFindNumber = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);
    String NewRefDesig = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);
    String NewUsage = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_USAGE);
    String strNewUsage = FrameworkUtil.findAndReplace(i18nNow.getRangeI18NString("Usage", NewUsage, languageStr),"'","\\'");
    //String NewQty = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_QUANTITY);
    String NewQty = (String) newMap.get(SELECT_ATTRIBUTE_QUANTITY);
  //UOM Management: Show the UOM value of Part in the Markup - start
  	String sUOMForMarkUp = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
    String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
	String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
	String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
    //UOM Management: Show the UOM value of Part in the Markup - end

    //strInput = strInput + "<object objectId=\"" + sObjId + "\" relId=\"\" relType=\"" + symRelType + "\" markup=\"add\" param1=\""+selPartRelId+"\"></object>";
        strInput = strInput + "<object objectId=\"" + sObjId + "\" relId=\"\" relType=\"" + symRelType + "\" markup=\"add\" param1=\""+selPartRelId+"\">";
	    // Adding EBOM attributes to the replaced part.
	    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+NewFindNumber+"</column>";
	    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\">"+NewRefDesig+"</column>";
	    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\">"+NewCompLocation+"</column>";
	    //strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+NewQty+"</column>";
	    strInput = strInput + "<column name=\""+ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+NewQty+"</column>";
	    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\" a=\""+NewUsage+"\">"+strNewUsage+"</column>";
	    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
	    
	    if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
	    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"False\">"+strVPMVisibleFalse+"</column>";
	    } else {
	    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"True\">"+strVPMVisibleTrue+"</column>";
	    }
	    
    //Added for Common View Replace opertaion : Start
    if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)){
    strInput = strInput + "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Stype\" edited=\"true\">Unassigned</column><column name=\"Switch\" edited=\"true\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
    }   
    strInput = strInput + "</object>";
    }
    } 
    }
    strInput = strInput + "</object></mxRoot>";
    }
	
	if(isReplaceForSynchro){
		Hashtable mSynchro = new Hashtable();
		mSynchro.put("ROOTID", selPartParentOId);
		mSynchro.put("objectId", selPartParentOId);
		mSynchro.put("SYNC_DEPTH", "1");
		mSynchro.put("SYNC_AND_TRANSFER", "no");
	  
		String[] synchroArgs = JPO.packArgs(mSynchro);
		//Modified to fix redmine 8680 - Use public API for synchronization - start
		//Map matrixObjIDvplmObjIDMap  = (Map) JPO.invoke(context,"AT_emxDeformable", null, "launchEncapsulatedSynchro", synchroArgs,	Map.class);
		Map matrixObjIDvplmObjIDMap  = (Map) JPO.invoke(context,"AT_emxDeformable", null, "launchEncapsulatedSynchroPublicAPI", synchroArgs,	Map.class);
		//Modified to fix redmine 8680 - Use public API for synchronization - end
			
		if(matrixObjIDvplmObjIDMap != null && matrixObjIDvplmObjIDMap.containsKey("RESULT_MESSAGE")){
			 
			 HashMap mDisconnectDeformable = new HashMap();
			 mDisconnectDeformable.put("sParentProductId", sParentProductId);
			 mDisconnectDeformable.put("listOfDeformedInstanceToDelete", slDeformedInstanceToDelete);

			 String[] disconnectDeformableArgs = JPO.packArgs(mDisconnectDeformable);
			 JPO.invoke(context,"AT_emxDeformable", null, "disconnectDeformableInPostSynchro", disconnectDeformableArgs);
			 
		}else{
			if(matrixObjIDvplmObjIDMap != null && matrixObjIDvplmObjIDMap.containsKey("ERROR_MESSAGE")){
				
				Object errorMessage = matrixObjIDvplmObjIDMap.get("ERROR_MESSAGE");
				
				if(errorMessage instanceof String) {
					sErrorSynchro = (String) errorMessage;
				}else if(matrixObjIDvplmObjIDMap.get("ERROR_MESSAGE") instanceof ArrayList<?>){
					ArrayList<String> alErrorSynchro = (ArrayList<String>) errorMessage;
					Iterator<String> itResult = alErrorSynchro.iterator();
					while(itResult.hasNext()){
						sErrorSynchro += itResult.next();
					}
				}
				
				ContextUtil.abortTransaction(context);
			}
		}
	}
	
	ContextUtil.commitTransaction(context);
		 
} catch (Exception ex) {
     
     ContextUtil.abortTransaction(context);
	 ex.printStackTrace();
	 sErrorSynchro+=ex.getMessage();
}
//clear the output buffer
out.clear();

%>
<%!
public static int getHighestNumber(StringList slValues) {
	int iNumber;
	int highestNumber = 0;
	for (int i = 0; i < slValues.size(); i++) {
		String slValue = (String) slValues.get(i);
		slValue = slValue.contains(".")? slValue.replaceAll("\\..*", ""):slValue;
		if(UIUtil.isNotNullAndNotEmpty(slValue)){
		iNumber = Integer.parseInt(slValue);
		if (iNumber > highestNumber) { highestNumber = iNumber; }
		}
	}
	
	return highestNumber;
}
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIFreezePane.js"></script>

<script>
 var frameName = "ENCBOM";

 var callback = "";
 var objWin = getTopWindow().getWindowOpener().parent;
 var errorSynchro = "<%=sErrorSynchro%>";
 var isReplaceForSynchro = "<%=isReplaceForSynchro%>";

  if(getTopWindow().getWindowOpener().parent.name == "treeContent")
  {
     objWin=getTopWindow().getWindowOpener();
  }
 //Added for the fix 376740
 //XSSOK
 if ("true"=="<%=XSSUtil.encodeForJavaScript(context,replaceWithExisting)%>"){
	//XSSOK
     	if ("view"!="<%=XSSUtil.encodeForJavaScript(context,tablemode)%>"){
     callback = eval(getTopWindow().getWindowOpener().parent.emxEditableTable.prototype.<%=callbackFunctionName%>);
	}
     }
 else{
	//XSSOK
     	if ("view"!="<%=XSSUtil.encodeForJavaScript(context,tablemode)%>"){
    	 callback = eval(getTopWindow().getWindowOpener().emxEditableTable.prototype.<%=callbackFunctionName%>);
	}
     }
  //376740 ends
   if(errorSynchro != ""){
	 alert(errorSynchro);
   }else{
	  if ("view"!="<%=XSSUtil.encodeForJavaScript(context,tablemode)%>"){
  		var oxmlstatus = callback('<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>', "true");
	  } else {
		  var rowsSelected = "<%=XSSUtil.encodeForJavaScript(context, ComponentsUIUtil.arrayToString(checkBoxArray, "~"))%>";
		  if ("true"=="<%=XSSUtil.encodeForJavaScript(context,replaceWithExisting)%>"){
			  objWin = getTopWindow().getWindowOpener().parent.openerFindFrame(getTopWindow(),frameName);
			  frameName = ((objWin != null)) ? frameName :"content";
			  getTopWindow().getWindowOpener().parent.emxEditableTable.removeRowsSelected(rowsSelected.split("~")); 
			  eval(getTopWindow().getWindowOpener().parent.openerFindFrame(getTopWindow(),frameName).FreezePaneregister('<%=sParentRowId%>',"true"));
			  getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected('<%=strInput%>');
			  eval(getTopWindow().getWindowOpener().parent.openerFindFrame(getTopWindow(),frameName).FreezePaneunregister('<%=sParentRowId%>',"true"));
		  }else {
			  objWin = getTopWindow().getWindowOpener().openerFindFrame(getTopWindow(),frameName);
			  frameName = ((objWin != null)) ? frameName :"content";
			  getTopWindow().getWindowOpener().emxEditableTable.removeRowsSelected(rowsSelected.split("~")); 
			  eval(getTopWindow().getWindowOpener().openerFindFrame(getTopWindow(),frameName).FreezePaneregister('<%=sParentRowId%>',"true"));
			  getTopWindow().getWindowOpener().emxEditableTable.addToSelected('<%=strInput%>');
			  eval(getTopWindow().getWindowOpener().openerFindFrame(getTopWindow(),frameName).FreezePaneunregister('<%=sParentRowId%>',"true"));
		  }
	  }
   }
  
  if(isReplaceForSynchro == "true"){
	   objWin.document.location.href=objWin.document.location.href+"&expandByDefault=true&expandLevel=<%=iExpandLevel%>"; 
  }
  parent.closeWindow();
  window.close();

</script>

      <%@include file = "emxEngrCommitTransaction.inc"%>
