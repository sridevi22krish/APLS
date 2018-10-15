<%--  PartCreatePostProcess.jsp - The post-process jsp for the Part create component used to do the post process operations after Part creation.
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
   Suresh S; Oct 5, 2017, Modified for Redmine 8091.
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxEngrFramesetUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import="com.matrixone.apps.domain.util.i18nNow,com.matrixone.jsystem.util.StringUtils"%>
<%@ page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%@ page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@ page import="com.matrixone.apps.engineering.Part"%>
<%@ page import="com.matrixone.apps.domain.*" %>
<%@ page import="java.lang.reflect.*" %>
<%@ page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session" />

<%
    String languageStr   = request.getHeader("Accept-Language");//context.getSession().getLanguage();
    String createMode    = emxGetParameter(request, "createMode");
    String multiObjectCreate    = emxGetParameter(request, "multiPartCreation");
    String partMode      = emxGetParameter(request, "PartMode");
    String fromView      = emxGetParameter(request, "fromView");
    String strPartObjId  = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "newObjectId")); 
    String noOfParts            = emxGetParameter(request, "NoOfParts");
    String timeStamp            = emxGetParameter(request, "timeStamp");
    String isWipMode     = emxGetParameter(request,"isWipMode");
    String contextECO    = emxGetParameter(request,"contextECO");
    String fromMarkupView = emxGetParameter(request, "fromMarkupView");
    String VPMProductName1 = emxGetParameter(request, "VPMProductName1");
    String VPMProductName = emxGetParameter(request, "VPMProductName");
    String ImageData = emxGetParameter(request, "ImageData");
    String initSource  = emxGetParameter(request,"initSource");
    String jsTreeID    = emxGetParameter(request,"jsTreeID");
    String suiteKey     = emxGetParameter(request,"suiteKey"); 
    String struiType =  emxGetParameter(request,"uiType");
    String prmode    		= emxGetParameter(request, "prmode");
    String selPartRowId    		= emxGetParameter(request, "selPartRowId");
    boolean refresh = false;
    String strVname = (VPMProductName1 == null) ? VPMProductName : VPMProductName1;
    String ecoName       = "";
    String displayValue  = "";
    int FNvalue = 1;
    context = (matrix.db.Context)request.getAttribute("context");
    //For DEC use case
    boolean isDSCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionDesignerCentral",false,null,null);
    boolean isECCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionEngineeringConfigurationCentral",false,null,null);
    boolean isMFGInstalled = EngineeringUtil.isMBOMInstalled(context);
  
    if (isECCInstalled && "false".equalsIgnoreCase(isWipMode) && "UEBOMAddNew".equalsIgnoreCase(createMode)) {
        contextECO = emxGetParameter(request,"contextECO");
        if (contextECO != null && !"null".equalsIgnoreCase(contextECO) && !"".equalsIgnoreCase(contextECO)) {
            DomainObject ecoObj  = DomainObject.newInstance(context,contextECO);
            ecoName = (String)ecoObj.getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_NAME);
            Class<?> c = Class.forName("com.matrixone.apps.unresolvedebom.UnresolvedPart");
            Object unresolvedPart =c.newInstance();
            // parameters depending on the bean method
            Class[] inputType = new Class[4];
            inputType[0]  = matrix.db.Context.class;
            inputType[1]  = String.class;
            inputType[2]  = String.class;
            inputType[3]  = boolean.class;
            Method method = c.getMethod("getEffectivityValue", inputType);
            displayValue  = (String)method.invoke(unresolvedPart,new Object[]{context, contextECO, "displayValue", true});
         }
    }
    
    String methodName = "doPartSelect";
    String busName      = "";
    Part partObj = null;
    
    try {
        
        partObj = new Part();
        partObj.setId(strPartObjId);
        busName = partObj.getInfo(context,DomainConstants.SELECT_NAME);
		//if(UIUtil.isNullOrEmpty(strVname)) 8091
        	//partObj.setAttributeValue(context, EngineeringConstants.ATTRIBUTE_V_NAME, busName); 8091
       
    } catch ( Exception e){
        e.printStackTrace();
    }
    
%>

    <script language="Javascript">
<%   
    if(isDSCInstalled && createMode.equals("DEC"))
    {
%>
			//XSSOK
            getTopWindow().getWindowOpener().<%=methodName%>("<%=busName%>", "<%=strPartObjId%>");
           
<%
    }
%>
    </script>
<%
 /* START of CMC Specific CODE */
      boolean isCMCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMComponentReuse",false,null,null);
      if(isCMCInstalled){
        String itemId    = emxGetParameter(request, "sourcingItemId");
            String RDO = emxGetParameter(request, "RDO");
         DomainObject dObj = DomainObject.newInstance(context,strPartObjId); 
            busName = dObj.getInfo(context,DomainConstants.SELECT_NAME);
            String busRev = dObj.getInfo(context,DomainConstants.SELECT_REVISION);
            String busType = dObj.getInfo(context,DomainConstants.SELECT_TYPE);
            if(itemId != null && !itemId.equals("")){
            boolean isCMAInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionLibrarianforCESV5",false,null,null);
            String isAdmin=(String)session.getAttribute("isAdmin");
            HashMap cmcParamMap = new HashMap();
                cmcParamMap.put("itemId", itemId);
                cmcParamMap.put("sessionId", session.getId());
                    cmcParamMap.put("partName", busName);
            cmcParamMap.put("partType", busType);
                cmcParamMap.put("partRevision", busRev);
                    cmcParamMap.put("RDO", RDO);
                cmcParamMap.put("updateItemRecord","true");
                    String[] methodargs = JPO.packArgs(cmcParamMap);
                    //Map & store the info in i2 db
                    int status = JPO.invoke(context, "CMCItem", null, "mapPartToItem", methodargs);
              
                String I18NCESResourceBundle = "emxComponentMgmtConnectorStringResource";
                String appStatus = FrameworkProperties.getProperty(context, "DEFAULT_APPROVAL_STATUS");
            String fromEBOM = (String)session.getAttribute("fromEBOM");
            String strMsg = "";         
            if(fromEBOM == null)
                fromEBOM = "";
                
            if(fromEBOM != null && fromEBOM.equals("")){
            	
            	//Multitenant
            	//strMsg = UINavigatorUtil.getI18nString("CES.Nci.Success",I18NCESResourceBundle,languageStr);
            	strMsg =EnoviaResourceBundle.getProperty(context, I18NCESResourceBundle, context.getLocale(),"CES.Nci.Success"); 
                if( status != 0)
                	//Multitenant
                	//strMsg = UINavigatorUtil.getI18nString("CES.Nci.Failure",I18NCESResourceBundle,languageStr);
                	strMsg = EnoviaResourceBundle.getProperty(context, I18NCESResourceBundle, context.getLocale(),"CES.Nci.Failure");
            
            }else {
                                
                if(!isAdmin.equals("true") && !appStatus.equals("APPROVED")) {
                	
                	//Multitenant
                	//String errorMsg = UINavigatorUtil.getI18nString("CES.NCI.DesignUser.Failure","emxComponentMgmtBaseStringResource",languageStr);
                	String errorMsg =EnoviaResourceBundle.getProperty(context, "emxComponentMgmtBaseStringResource", context.getLocale(),"CES.NCI.DesignUser.Failure"); 
                    %>
                    <script>
					//XSSOK
                        alert("<%=errorMsg%>");
                        getTopWindow().closeWindow();
                    </script>
                    <%
                    return;
                }
                else if(isAdmin!=null && isAdmin.equals("true") && status == 0 && isCMAInstalled == true && !appStatus.equals("APPROVED")) {
                    String project    = emxGetParameter(request, "sourcingProject");
                    String plmObjId    = emxGetParameter(request, "sourcingPlmObjId");
                    session.setAttribute("fromEC","true");
                    String fromObject =  emxGetParameter(request, "objectId");
                    StringBuffer strBuffer = new StringBuffer();
                    strBuffer.append("<mxRoot>")
                             .append("<action>add</action>")
                             .append("<data status=\"pending\">")
                             .append("<item oid=\"")
                             .append(strPartObjId)
                             .append("\" pid=\"")
                             .append(fromObject)
                             .append("\" relType=\"relationship_EBOM\">")
                             .append("<column name=\"Find Number\" edited=\"true\"></column>")
                             .append("<column name=\"Reference Designator\" edited=\"true\"></column>") 
                             .append("<column name=\"Usage\">Standard</column>") 
                             .append("</item>")
                             .append("</data>")
                             .append("</mxRoot>");
                        String strInput = strBuffer.toString();
                                                
                %>
                    <script language="Javascript">
					//XSSOK
						getTopWindow().location.href= '../componentmgmtbase/emxCMCApprovalProcess.jsp?approvalProcess=manageApproval&fromEBOM=true&fromEC=true&project=<xss:encodeForJavaScript><%=project%></xss:encodeForJavaScript>&plmObjId=<xss:encodeForJavaScript><%=plmObjId%></xss:encodeForJavaScript>&partName=<%=busName%>&strInput=<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>';
                    </script>
                        
                <%  
        
                }   
                    
            }
                        
             %>
            <script language="Javascript">
			//XSSOK
				if("<%=fromEBOM%>" == ""){
				//XSSOK
                    alert("<%=strMsg%>");
				}
            </script>
             <%
             }
      }
    /* END OF CMC Specific CODE    */
    //LBC code, to update Classification Attribute values for the created Part
    //code would be invoked only if LBC is installed and the create part
    //is not from Global Toolbar && from BOM PowerView Add New
    boolean isLBCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionLibraryCentral",false,null,null);
    if(isLBCInstalled && !("ENG").equalsIgnoreCase(createMode) && !(("EBOM").equalsIgnoreCase(createMode))){
        Map allAttrsinAGMap = new HashMap();
        String clsObjectId=emxGetParameter(request, "GeneralClassOID");
        if(UIUtil.isNullOrEmpty(clsObjectId))
        {
            clsObjectId=emxGetParameter(request, "PartFamilyOID");
        }
        if(!UIUtil.isNullOrEmpty(clsObjectId))
        {
        	DomainObject domObj=new DomainObject(strPartObjId);
            String[] args = JPO.packArgs(clsObjectId);
            String[] constructor = { null };
            MapList classificationAttributes = (MapList) JPO.invoke(context,
                    "emxLibraryCentralClassificationAttributes", constructor,
                    "getClassClassificationAttributes", args, MapList.class);
            for(int i=0;i<classificationAttributes.size();i++){
                HashMap attributeGroup = (HashMap)classificationAttributes.get(i);
                String attributeGroupName = (String)attributeGroup.get("name");
                MapList attributes = (MapList)attributeGroup.get("attributes");
                for(int j=0;j<attributes.size();j++){
                    HashMap attribute =  (HashMap)attributes.get(j);
                    String attributeName = (String)attribute.get("name");
                    //String attributeNameinAG=attributeGroupName+"|"+attributeName;
					
					// Changes added by PSA11 start(IR-449489-3DEXPERIENCER2016x)
					String attributeNameinAG = (attributeGroupName + clsObjectId).replaceAll("\\.", "") +"|"+ attributeName;
                    if(UOMUtil.isAssociatedWithDimension(context,attributeName) && (UIUtil.isNotNullAndNotEmpty(emxGetParameter(request,attributeNameinAG))) && !(attribute.get("valuetype").equals("multival"))){
                        allAttrsinAGMap.put(attributeName,emxGetParameter(request,attributeNameinAG)+" "+emxGetParameter(request,"units_"+attributeNameinAG));
                    }
					// Changes added by PSA11 end.
        			//checking if attribute is of type multival
                	else if(attribute.get("valuetype").equals("multival")){
            			AttributeType multiValueAttrType = new AttributeType(attributeName);
            			AttributeList multiValueAttributeList= new AttributeList();
            			if(!UIUtil.isNullOrEmpty((String)emxGetParameter(request,attributeNameinAG+"_order"))){
           						String multiValOrder=(String)emxGetParameter(request,attributeNameinAG+"_order");
                            	StringTokenizer tokens = new StringTokenizer(multiValOrder, ":");
                            	int index=1;
                            	HashMap multiValuesMap=new HashMap();
                            	while(tokens.hasMoreTokens())
                            	{
                            		String multiAttributeValue = (String) emxGetParameter(request,(String)tokens.nextToken());
                            		if(!multiAttributeValue.isEmpty()){
                            			multiValuesMap.put(index, multiAttributeValue);
                            			index++;
                            		}
                            	}
                            	Attribute multiValueAttr=new Attribute(multiValueAttrType,multiValuesMap);
                            	multiValueAttributeList.addElement(multiValueAttr);
                            	domObj.setAttributeValues(context,multiValueAttributeList);
            				}
            			else
            				allAttrsinAGMap.put(attributeName,emxGetParameter(request,attributeNameinAG));
            		}
                    else
                        allAttrsinAGMap.put(attributeName,emxGetParameter(request,attributeNameinAG));
                }
            }
            domObj.setAttributeValues(context,allAttrsinAGMap);
        }
    } 
    //END LBC Code    
    // START - Added as a part of FTR Preview BOM Functionality - IR-077468V6R2012 
    
    boolean isFTRInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionVariantConfiguration",false,null,null);
    if(isFTRInstalled == true &&  createMode.equals("FTR") ) {
          HashMap hmCurrentModifiedFeatureFromSession = (HashMap)session.getValue("currentmodifiedfeature");
          if(hmCurrentModifiedFeatureFromSession!=null && hmCurrentModifiedFeatureFromSession.size()>0) 
              {
          String strSubmitURL                 = (String)session.getAttribute("submitURL");
          session.removeAttribute("submitURL");
          String url = strSubmitURL+"?emxTableRowId=" + strPartObjId ;
         %>
    <script language="Javascript">
	//XSSOK
        document.location.href = "<%=url%>";            
    </script>
        <%
            return;
            }
        // END - Added as part of FTR Preview BOM Functionality - IR-077468V6R2012 
    }
 
    // when invoked from Product, Add New Top Level Part
    if (createMode.equals("assignTopLevelPart")) {
     
     try {
          String strModelId     = emxGetParameter(request, "sModelId");
          partObj.ConnectProductWithTopLevelPart(context,strPartObjId,strModelId);
 %>          
          <script language="Javascript">
          parent.closeWindow();
          var parentDetailsFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
          parentDetailsFrame.document.location.href=parentDetailsFrame.document.location.href;
          </script>
 <%
     } catch (Exception e) {
         System.out.println("Exception =="+e.getMessage());   
     }
    }
    
    String partFamilyId = "";
    if (createMode.equals("EBOMReplaceNew")) {
        
        
        String bomRelId        = emxGetParameter(request, "bomRelId");
        String bomObjectId     = emxGetParameter(request, "bomObjectId");
        String bomParentOID    = emxGetParameter(request, "bomParentOID");
        String sRowId          = emxGetParameter(request, "sRowId");
        
        String newUrl = "../engineeringcentral/emxEngrBOMReplaceDailogFS.jsp?partFamilyContextId="+partFamilyId+"&selPartObjectId="+bomObjectId+"&selPartParentOId="+bomParentOID+"&selPartRelId="+bomRelId+"&createdPartObjId="+strPartObjId+"&sRowId="+sRowId+"&tablemode="+prmode;

 %>
     <script language="Javascript">
     //XSSOK
         getTopWindow().location.href = "<%=newUrl%>"; 
     </script>
 <% 
   } 
    
    String partIds = null;
  //Added for To Create Multiple part from Part Clone
    String strMode = emxGetParameter(request,"mode");    
    strMode = (strMode != null) ? strMode : "";      
    
    // If multi part creation feature is enabled 
    if("true".equalsIgnoreCase(multiObjectCreate) ){        
        if(noOfParts != null && !"".equals(noOfParts)){
            int partCount = 0;
            try{
                partCount = Integer.parseInt(noOfParts);
            }catch(NumberFormatException ne){
                ne.printStackTrace();
                throw new FrameworkException(ne);
            }
            if((partCount>1) && (strPartObjId != null)){
                MapList fields = createBean.getFormFields(timeStamp);
                HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
                HashMap requestValuesMap = UINavigatorUtil.getRequestParameterValuesMap(request);
                String timeZone = (String) session.getAttribute("timeZone");
                requestMap.put("RequestValuesMap", requestValuesMap);
                String temp = "";
                partIds = Part.createMultipleParts(context, createBean, requestMap,fields, timeZone, partCount);
                
              //Added for To Create Multiple part from Part Clone start
                                  
                if(strMode.equalsIgnoreCase("clonedPartOpenInEditMode")) { 
                    String newObjectId = requestMap.get("newObjectId").toString();                      
                    String objectId = emxGetParameter(request, "objectId");                                                                                 
                    String postProcessJPO = emxGetParameter(request, "postProcessJPO");                 
                    String strJPOName = postProcessJPO.substring(0,postProcessJPO.indexOf(":"));                     
                    String strMethodName = postProcessJPO.substring(postProcessJPO.indexOf(":") + 1, postProcessJPO.length());                                      
                    HashMap programMap = new HashMap(6);
                    HashMap paramMap = new HashMap(6);                    
                    paramMap.put("objectId", newObjectId);
                    paramMap.put("newObjectId", partIds);                    
                    paramMap.put("languageStr", languageStr);
                    programMap.put("requestMap", UINavigatorUtil.getRequestParameterMap(pageContext));
                    programMap.put("paramMap", paramMap);
                    HashMap formMap = createBean.getFormData(timeStamp);
                    programMap.put("formMap", formMap);
                     
                    String[] methodargs = JPO.packArgs(programMap);                     
                    Map returnMap = (HashMap)JPO.invoke(context, strJPOName, null, strMethodName, methodargs, Object.class);
                } //Added for To Create Multiple part from Part Clone end
				
				if(partIds != null){
                    StringTokenizer st = new StringTokenizer(partIds, "~");
                    String tempid;
                    while(st.hasMoreTokens()){
                        tempid = st.nextToken();
                        partObj.setId(tempid);
                        //if(UIUtil.isNullOrEmpty(strVname)) 8091
                        	//partObj.setAttributeValue(context, EngineeringConstants.ATTRIBUTE_V_NAME, partObj.getInfo(context,DomainConstants.SELECT_NAME)); 8091
                    }
        		}  
           }
        }
    }
    
    StringBuffer strBuffer1 = new StringBuffer();
    String strInput = "";
    String callbackFunctionName = "addToSelected";
    String highestFN = emxGetParameter(request, "highestFN");
    
    if(partIds == null){
        partIds = strPartObjId;
    }else{
        partIds = strPartObjId + "~" + partIds;
    }
    
    if (createMode.equals("EBOM") || (isECCInstalled && createMode.equals("UEBOMAddNew"))){
        
        String fromObject =  emxGetParameter(request, "bomObjectId"); 
        String relType    =  "relationship_EBOM";
        boolean AllowUEBOMAddNewInContextChange = false;
        String incrementFN = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.StructureBrowser.FNIncrement");
        if (isECCInstalled && "false".equalsIgnoreCase(isWipMode)&& createMode.equals("UEBOMAddNew")) {
               relType    =  "relationship_EBOMPending";    
               AllowUEBOMAddNewInContextChange = true;
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
    		FNvalue = Integer.parseInt(highestFN)+incrementIntValue;
    	}
    	
        StringTokenizer st = new StringTokenizer(partIds, "~");
        String tempid; 
        strBuffer1.append("<mxRoot>");
        
      //Multitenant
      //String strStandard =  i18nNow.getI18nString("emxFramework.Range.Usage.Standard","emxFrameworkStringResource", languageStr);
      //String strStandard =EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.Usage.Standard");  
      String sDefaultUsageValue=new AttributeType((String)PropertyUtil.getSchemaProperty(context,"attribute_Usage")).getDefaultValue(context);
      String sDefaultUsage= UIUtil.isNullOrEmpty(sDefaultUsageValue)?"":
    		   EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Attribute.Usage."+sDefaultUsageValue);
      String vpmControlState = "";
      String strVPMVisibleTrue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.TRUE");  
      String strVPMVisibleFalse = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.FALSE");
      boolean isENGSMBInstalled = EngineeringUtil.isENGSMBInstalled(context, false); 
   
      if(isENGSMBInstalled) {   	
      	String mqlQuery = new StringBuffer(100).append("print bus $1 select $2 dump").toString();
  		vpmControlState = MqlUtil.mqlCommand(context, mqlQuery,fromObject,"from["+DomainConstants.RELATIONSHIP_PART_SPECIFICATION+"|to.type.kindof["+EngineeringConstants.TYPE_VPLM_CORE_REF+"]].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");  		
      } 
      
      //UOM Management: Show the UOM value of Part in the Markup - start
      HashMap mPartAndUOMMap = new HashMap();
      StringList sUOMSels = new StringList();
      sUOMSels.addElement(EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
      sUOMSels.addElement(DomainConstants.SELECT_ID);
      
      StringList stListOfParts = new StringList();
      StringTokenizer st_parts = new StringTokenizer(partIds, "~");
      while(st_parts.hasMoreTokens())
       {
    	   stListOfParts.addElement(st_parts.nextToken());
       }
      String[] sListOfPartsArr = (String[])stListOfParts.toArray(new String[stListOfParts.size()]);
      MapList mListOfUOMVals = DomainObject.getInfo(context, sListOfPartsArr,sUOMSels);
      for(int i =0; i<mListOfUOMVals.size(); i++)
      {
    	  Map mPartUOM = (Map)mListOfUOMVals.get(i);
    	  mPartAndUOMMap.put((String)mPartUOM.get("id"), (String)mPartUOM.get("attribute[Unit of Measure]"));
      }
      String sUOMForMarkUp = "";
      //UOM Management: Show the UOM value of Part in the Markup - end
            
	  DomainObject domObj = null;
      String currentState ="";
      StringList eBOMFN;
      if(UIUtil.isNotNullAndNotEmpty(fromObject)){
     	domObj = new DomainObject(fromObject);
     	currentState = domObj.getInfo(context, DomainObject.SELECT_CURRENT);
     	eBOMFN = domObj.getInfoList(context, "from["+ EngineeringConstants.RELATIONSHIP_EBOM+"].attribute["+EngineeringConstants.ATTRIBUTE_FIND_NUMBER+"].value" );
     	FNvalue = (FNvalue <= 1)?EngineeringUtil.getHighestNumber(eBOMFN)+incrementIntValue:FNvalue;
     	}
        while(st.hasMoreTokens()){
             tempid = st.nextToken();
             sUOMForMarkUp = (String)mPartAndUOMMap.get(tempid);//UOM Management
             String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
			 String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
			 String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
			 String tempStrVname = "";
             if(UIUtil.isNullOrEmpty(strVname)){
                 partObj.setId(tempid);
                 tempStrVname = partObj.getAttributeValue(context, EngineeringConstants.ATTRIBUTE_V_NAME); 
             }
             else
            	 tempStrVname = strVname;
             if(currentState.equalsIgnoreCase(DomainConstants.STATE_PART_PRELIMINARY) && "view".equalsIgnoreCase(prmode)){
            	 DomainRelationship dr = new DomainRelationship();
            	 HashMap hmRelAttributesMap = new HashMap();
            	 hmRelAttributesMap.put(EngineeringConstants.ATTRIBUTE_FIND_NUMBER,Integer.toString(FNvalue));
     		    	hmRelAttributesMap.put(EngineeringConstants.ATTRIBUTE_UNIT_OF_MEASURE, sUOMForMarkUp);
            	 HashMap paramMap = new HashMap();
            	 paramMap.put("objectId", fromObject);
            	 String[] methodargs = JPO.packArgs(paramMap);
            	 boolean status =  JPO.invoke(context, "emxENCActionLinkAccess", null, "isApplyAllowed", methodargs,Boolean.class);
            	 if(status){
            		 try{
            		  dr=DomainRelationship.connect(context, domObj, EngineeringConstants.RELATIONSHIP_EBOM, DomainObject.newInstance(context, tempid));
            		 }catch(Exception e){
            			emxNavErrorObject.addMessage(e.getMessage());
         	    		throw e;
            		 }
            		 dr.setAttributeValues(context, hmRelAttributesMap);
                 refresh = true;
            	 }
            	 
            	 strBuffer1.append("<action>add</action>")
                 .append("<data status=\"commited\">")
                 .append("<item oid=\"")
                 .append(tempid)
                 .append("\" pid=\"")
                 .append(fromObject)
                 .append("\" relType=\""+relType+"\" relId=\""+dr.getName()+"\">");
            	 if (AllowUEBOMAddNewInContextChange){
                     strBuffer1.append("<column name=\"ProposedEffectivity\">"+displayValue+"</column>")
                               .append("<column name=\"Add\">"+ecoName+"</column>");
                      } else if (isECCInstalled && createMode.equals("UEBOMAddNew")) {
                          strBuffer1.append("<column name=\"CurrentEffectivity\"></column>");
                      }
                      
                      if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
                    	  strBuffer1.append("<column name=\"VPMVisible\" edited=\"true\" actual=\"False\">"+strVPMVisibleFalse+"</column>");
                      } else {
                    	  strBuffer1.append("<column name=\"VPMVisible\" edited=\"true\" actual=\"True\">"+strVPMVisibleTrue+"</column>");
                      } 
                      
                   strBuffer1.append("<column name=\"Find Number\" edited=\"true\">"+ FNvalue +"</column>")
                   .append("<column name=\"AT_C_Quantity\" edited=\"true\">1.0</column>")
                 .append("<column name=\"Reference Designator\" edited=\"true\"></column>") 
                 .append("<column name=\"V_Name\" edited=\"true\">"+ tempStrVname +"</column>")
                 .append("<column name=\"V_Name1\" edited=\"true\">"+ tempStrVname +"</column>")
				 .append("<column name=\"Usage\" edited=\"true\" actual=\""+sDefaultUsageValue+"\">"+sDefaultUsage+"</column>");
                if(!"MBOMCommon".equalsIgnoreCase(fromView))
                	 strBuffer1.append("<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"); //UOM Management
                 
                 strBuffer1.append("</item>")
                 .append("</data>");
				 FNvalue+=incrementIntValue;
            	 if(st.hasMoreTokens()){
            		 continue;
            	 }
             }
             else{
            	 strBuffer1.append("<action>add</action>")
                 .append("<data status=\"pending\">")
                 .append("<item oid=\"")
                 .append(tempid)
                 .append("\" pid=\"")
                 .append(fromObject)
                 .append("\" relType=\""+relType+"\">");
            	 if (AllowUEBOMAddNewInContextChange){
                     strBuffer1.append("<column name=\"ProposedEffectivity\">"+displayValue+"</column>")
                               .append("<column name=\"Add\">"+ecoName+"</column>");
                      } else if (isECCInstalled && createMode.equals("UEBOMAddNew")) {
                          strBuffer1.append("<column name=\"CurrentEffectivity\"></column>");
                      }
                      
                      if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
                    	  strBuffer1.append("<column name=\"VPMVisible\" edited=\"true\" actual=\"False\">"+strVPMVisibleFalse+"</column>");
                      } else {
                    	  strBuffer1.append("<column name=\"VPMVisible\" edited=\"true\" actual=\"True\">"+strVPMVisibleTrue+"</column>");
                      } 
                      
                   strBuffer1.append("<column name=\"Find Number\" edited=\"true\">"+ FNvalue +"</column>")
                   .append("<column name=\"AT_C_Quantity\" edited=\"true\">1.0</column>")
                 .append("<column name=\"Reference Designator\" edited=\"true\"></column>") 
                 .append("<column name=\"V_Name\" edited=\"true\">"+ tempStrVname +"</column>")
                 .append("<column name=\"V_Name1\" edited=\"true\">"+ tempStrVname +"</column>")
                 .append("<column name=\"Usage\" edited=\"true\" actual=\""+sDefaultUsageValue+"\">"+sDefaultUsage+"</column>");
                if(!"MBOMCommon".equalsIgnoreCase(fromView))
                	 strBuffer1.append("<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"); //UOM Management
                 
                 strBuffer1.append("</item>")
                .append("</data>");
          	 FNvalue+=incrementIntValue; 
             }
             
        }
        strBuffer1.append("</mxRoot>");
        strInput = StringUtils.replaceAll(strBuffer1.toString(),"&","&amp;");
        strInput = FrameworkUtil.findAndReplace(strInput,"'","\\'");
        FNvalue-=incrementIntValue;
        String targetWindow = ("UEBOMAddNew".equalsIgnoreCase(createMode)) ? "PUEUEBOM" : "ENCBOM";
        if("MBOMCommon".equals(fromView)){
        	targetWindow = fromView;
        }
         %> 
          <script language="Javascript">
          //XSSOK
          	   var fromMarkupView = "<%=fromMarkupView%>";
          	   var targetFrame = (fromMarkupView == "true") ? parent.getWindowOpener() : findFrame(getTopWindow(),"<%=targetWindow%>");
targetFrame     = (targetFrame) ? targetFrame : findFrame(getTopWindow(),"MGS_ENCBOM");
          	   targetFrame	   = (targetFrame) ? targetFrame : findFrame(getTopWindow(),"content");
          	   var selPartRowId = '|||'+'<%=selPartRowId%>';
               eval(targetFrame.FreezePaneregister(selPartRowId,"true"));
               var callback    = eval(targetFrame.emxEditableTable.<%=callbackFunctionName%>);
               var oxmlstatus  = callback('<%=strInput%>');
               eval(targetFrame.FreezePaneunregister(selPartRowId,"true"));
	           window.parent.emxCreateForm.highestFN.value = <%=FNvalue%>;			   
          </script>
<%
        }
/* MGS CUSTO Start		*/
		if (createMode.equals("MGS_EBOM")){
        
        String fromObject =  emxGetParameter(request, "bomObjectId"); 
        String relType    =  emxGetParameter(request, "MGSrel");
        boolean AllowUEBOMAddNewInContextChange = false;
        String incrementFN = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.StructureBrowser.FNIncrement");
        

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
    		FNvalue = Integer.parseInt(highestFN)+incrementIntValue;
    	}
    	
        StringTokenizer st = new StringTokenizer(partIds, "~");
        String tempid; 




        strBuffer1.append("<mxRoot>");
        
      //Multitenant
      //String strStandard =  i18nNow.getI18nString("emxFramework.Range.Usage.Standard","emxFrameworkStringResource", languageStr);
      String strStandard =EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.Usage.Standard");  
      
      String vpmControlState = "";
      String strVPMVisibleTrue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.TRUE");  
      String strVPMVisibleFalse = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.FALSE");
      boolean isENGSMBInstalled = EngineeringUtil.isENGSMBInstalled(context, false); 
   
      if(isENGSMBInstalled) {   	
      	String mqlQuery = new StringBuffer(100).append("print bus $1 select $2 dump").toString();
  		vpmControlState = MqlUtil.mqlCommand(context, mqlQuery,fromObject,"from["+DomainConstants.RELATIONSHIP_PART_SPECIFICATION+"|to.type.kindof["+EngineeringConstants.TYPE_VPLM_CORE_REF+"]].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");  		
      } 
      
      //UOM Management: Show the UOM value of Part in the Markup - start
      HashMap mPartAndUOMMap = new HashMap();
      StringList sUOMSels = new StringList();
      sUOMSels.addElement(EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
      sUOMSels.addElement(DomainConstants.SELECT_ID);
      
      StringList stListOfParts = new StringList();
      StringTokenizer st_parts = new StringTokenizer(partIds, "~");
      while(st_parts.hasMoreTokens())
       {
    	   stListOfParts.addElement(st_parts.nextToken());
       }
      String[] sListOfPartsArr = (String[])stListOfParts.toArray(new String[stListOfParts.size()]);
      MapList mListOfUOMVals = DomainObject.getInfo(context, sListOfPartsArr,sUOMSels);
      for(int i =0; i<mListOfUOMVals.size(); i++)
      {
    	  Map mPartUOM = (Map)mListOfUOMVals.get(i);
    	  mPartAndUOMMap.put((String)mPartUOM.get("id"), (String)mPartUOM.get("attribute[Unit of Measure]"));
      }
      String sUOMForMarkUp = "";
      //UOM Management: Show the UOM value of Part in the Markup - end
      
        while(st.hasMoreTokens()){
             tempid = st.nextToken();
             sUOMForMarkUp = (String)mPartAndUOMMap.get(tempid);//UOM Management
             String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
			 String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
			 String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
             
             strBuffer1.append("<action>add</action>")
             .append("<data status=\"pending\">")
             .append("<item oid=\"")
             .append(tempid)
             .append("\" pid=\"")
             .append(fromObject)
             .append("\" relType=\""+relType+"\">");
              if (AllowUEBOMAddNewInContextChange){
             strBuffer1.append("<column name=\"ProposedEffectivity\">"+displayValue+"</column>")
                       .append("<column name=\"Add\">"+ecoName+"</column>");
              } else if (isECCInstalled && createMode.equals("UEBOMAddNew")) {
                  strBuffer1.append("<column name=\"CurrentEffectivity\"></column>");
              }
              
              if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
            	  strBuffer1.append("<column name=\"VPMVisible\" edited=\"true\" actual=\"False\">"+strVPMVisibleFalse+"</column>");
              } else {
            	  strBuffer1.append("<column name=\"VPMVisible\" edited=\"true\" actual=\"True\">"+strVPMVisibleTrue+"</column>");
              } 
              
           strBuffer1.append("<column name=\"Find Number\" edited=\"true\">"+ FNvalue +"</column>")
           .append("<column name=\"Quantity\" edited=\"true\">1.0</column>")
         .append("<column name=\"Reference Designator\" edited=\"true\"></column>") 
         .append("<column name=\"V_Name\" edited=\"true\">"+ strVname +"</column>")
         .append("<column name=\"V_Name1\" edited=\"true\">"+ strVname +"</column>")
         .append("<column name=\"Usage\" edited=\"true\" actual=\"Standard\">"+strStandard+"</column>");
        if(!"MBOMCommon".equalsIgnoreCase(fromView))
        	 strBuffer1.append("<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"); //UOM Management
         
         strBuffer1.append("</item>")
         .append("</data>");
           FNvalue+=incrementIntValue;  
        }
        strBuffer1.append("</mxRoot>");
        strInput = StringUtils.replaceAll(strBuffer1.toString(),"&","&amp;");
        strInput = FrameworkUtil.findAndReplace(strInput,"'","\\'");
		System.out.println("================================= strInput = " + strInput);
        FNvalue-=incrementIntValue;
        String targetWindow = ("UEBOMAddNew".equalsIgnoreCase(createMode)) ? "PUEUEBOM" : "MGS_ENCBOM";
        if("MBOMCommon".equals(fromView)){
        	targetWindow = fromView;
        }
targetWindow = "MGS_ENCBOM";
         %> 
          <script language="Javascript">
          //XSSOK
          	   var fromMarkupView = "<%=fromMarkupView%>";
          	   var targetFrame = (fromMarkupView == "true") ? parent.getWindowOpener() : findFrame(getTopWindow(),"<%=targetWindow%>");
          	   targetFrame	   = (targetFrame) ? targetFrame : findFrame(getTopWindow(),"content");



               var callback    = eval(targetFrame.emxEditableTable.<%=callbackFunctionName%>);
console.log('callback = ' + callback);
               var oxmlstatus  = callback('<%=strInput%>');
console.log('oxmlstatus = ' + oxmlstatus);

	           window.parent.emxCreateForm.highestFN.value = <%=FNvalue%>;			   
          </script>
<%
        }
/* MGS CUSTO End		*/

    if(partIds != null){
        StringTokenizer st = new StringTokenizer(partIds, "~");
        String tempid;
        String planningReq;  //Added for Planning Required changes for Planning MBOM
        while(st.hasMoreTokens()){
            tempid = st.nextToken();
            partObj.setId(tempid);
            
            if (isMFGInstalled) {
				String sProductOID = emxGetParameter(request,
						"ProductOID");
				partObj.setEndItem(context);
				String strPolicy = partObj.getInfo(context,
						DomainConstants.SELECT_POLICY);
				if (UIUtil.isNotNullAndNotEmpty(strPolicy)
						&& strPolicy
								.equals(DomainConstants.POLICY_EC_PART)) {
					planningReq = emxGetParameter(request,
							"PlanningRequired");
					//Added PR Inter-face changes
					if (UIUtil.isNotNullAndNotEmpty(planningReq)) {
						partObj.setPlanningReq(context, planningReq);
					}
				}

				//Added for Manufacturing Plan -Start
				//Part.createAndConnectManufacturingPlan(context,tempid);
				//Added for Manufacturing Plan - End

				if (UIUtil.isNotNullAndNotEmpty(sProductOID)) {
					String relGBOM =PropertyUtil.getSchemaProperty(context, "relationship_GBOM");
					try {
						ContextUtil.pushContext(context);						
						DomainRelationship.connect(context,
													new DomainObject(sProductOID), 
													relGBOM,
													partObj);						
					} catch (Exception e) {
						throw e;
					} finally {
						ContextUtil.popContext(context);
					}
					
				}

			}
		}
	}
	if (isECCInstalled && "UEBOMReplaceNew".equals(createMode)) {

		String bomRelId = emxGetParameter(request, "bomRelId");
		String bomObjectId = emxGetParameter(request, "bomObjectId");
		String bomParentOID = emxGetParameter(request, "bomParentOID");
		String sRowId = emxGetParameter(request, "sRowId");

		String newUrl = "../unresolvedebom/ReplacePartProcess.jsp?contextECO="
				+ contextECO
				+ "&createMode="
				+ createMode
				+ "&isWipMode="
				+ isWipMode
				+ "&selPartObjectId="
				+ bomObjectId
				+ "&selPartParentOId="
				+ bomParentOID
				+ "&selPartRelId="
				+ bomRelId
				+ "&createdPartObjId="
				+ strPartObjId + "&sRowId=" + sRowId;
%>
     <script language="Javascript">
     //XSSOK
     getTopWindow().submitWithCSRF("<%=newUrl%>",getTopWindow());
     
     
     </script>
 <% 
   } 
    if(null != createMode && !"null".equalsIgnoreCase(createMode) && "LIB".equalsIgnoreCase(createMode)){
%>                
    <script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
    <script language="Javascript">
    //XSSOK
    function updateCountAndRefreshTreeTest(appDirectory,openerObj,parentOIDs)
    {
              // Changes added by PSA11 start.  
              var objectIds = getObjectsToBeModified(openerObj,parentOIDs);
           	  var objectIdArray = Object.keys(objectIds);
           	  for (var i = objectIdArray.length-1; i >= 0; i--) {
           		  var updatedLabel = getUpdatedLabel(appDirectory,objectIdArray[i],openerObj);
           		  
           		  openerObj.changeObjectLabelInTree(objectIdArray[i], updatedLabel, true, false, false);
           	  } 
           	  // Changes added by PSA11 end.
    } 

  
         
    updateCountAndRefreshTreeTest("<%=appDirectory%>", getTopWindow().getWindowOpener().getTopWindow());
    var varFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
    varFrame.document.location.href = varFrame.document.location.href; 
    </script>
<% 
   }

 if(partIds != null && !"".equals(partIds) && !partIds.equals(strPartObjId) && ("ENG".equals(createMode) || "LIB".equals(createMode) || ("MFG".equals(createMode)))){
    if(suiteKey == null || "".equals(suiteKey) || "null".equals(suiteKey)) { 
      suiteKey = "eServiceSuiteEngineeringCentral";
     }
//Modified as part of ALSTOM Customization for fixing ticket - 6366 - start
    //String url ="../common/emxIndentedTable.jsp?table=ENCPartSearchEditDetails&HelpMarker=emxhelppartsearchresultsedit&program=emxECSearchMassUpdate:getPartSearchEditDetails&toolbar=EmptyMenu&preProcessJPO=emxPart:checkLicense&hideRMBCommands=true&mode=edit&hideHeader=false&ImageData=" 
String url ="../common/emxIndentedTable.jsp?table=ATPartCloneDetails&HelpMarker=emxhelppartsearchresultsedit&program=emxECSearchMassUpdate:getPartSearchEditDetails&toolbar=EmptyMenu&preProcessJPO=emxPart:checkLicense&hideRMBCommands=true&mode=edit&hideHeader=false&ImageData="
//Modified as part of ALSTOM Customization for fixing ticket - 6366 - end
		+ ImageData +"&initSource="+initSource+"&jsTreeID="+jsTreeID+"&objIds="+partIds+"&languageStr="+languageStr+"&timeStamp="+timeStamp+"&suiteKey="+suiteKey+"&selection=multiple&openShowModalDialog=true";
if("ENG".equals(createMode) || "LIB".equals(createMode) || "MFG".equals(createMode)){
  url+="&header=emxEngineeringCentral.CreatePart.EditPartTitle&createMode="+createMode;
}else{
  url+="&header=emxEngineeringCentral.GlobalSearch.SearchPartTitle";
}
url+="&showSavedQuery=false&searchCollectionEnabled=false&massPromoteDemote=false&multiColumnSort=false&triggerValidation=false&showClipboard=false&objectCompare=false&export=false&autoFilter=false&printerFriendly=false&displayView=details";
   
%>
 <%@include file = "emxDesignBottomInclude.inc" %>
<html>
<head>
</head>
<body>
<form name="partcreateprocess" method="post">
<input type="hidden" name="objectId" value=""/>
<script language="Javascript">
//XSSOK
if("true"== "<%=refresh%>"){
	targetFrame.document.location.href = targetFrame.document.location.href; 
                }
  getTopWindow().showModalDialog("<%=url%>", 600, 500, "true");
   
</script>
</form>
</body>
</html>
     
<%
     } 
//Added for To Create Multiple part from Part Clone start
    else if(strMode.equals("clonedPartOpenInEditMode")) {
     String newObjectId = emxGetParameter(request, "newObjectId");
     String fromPartPropertiesNav = emxGetParameter(request, "fromPartProperties");
     String fromPartFamilyNav = emxGetParameter(request, "fromPartFamilyNav");
	 
	 //External Request 7898 WP7 QC5070	START
	 DomainObject newObj = DomainObject.newInstance(context, newObjectId);
	 String ObjType = newObj.getInfo(context,DomainConstants.SELECT_TYPE);
	 
	 String TYPE_AT_C_COS = PropertyUtil.getSchemaProperty("type_AT_C_COS");
	 String TYPE_AT_C_DESIGN_PART = PropertyUtil.getSchemaProperty("type_AT_C_DESIGN_PART");
	 String TYPE_AT_C_CONFIGURATION_ITEM = PropertyUtil.getSchemaProperty("type_AT_C_CONFIGURATION_ITEM");
	 
	 if(false && (TYPE_AT_C_COS.equals(ObjType) || TYPE_AT_C_DESIGN_PART.equals(ObjType) || TYPE_AT_C_CONFIGURATION_ITEM.equals(ObjType))){
	 
				Hashtable argTable = new Hashtable();
				argTable.put("ROOTID", newObjectId);
				argTable.put("SYNC_DEPTH", "-1");
						  
				  String[] synchroBOMArgs = JPO.packArgs(argTable);
				//Modified to fix redmine 8680 - Use public API for synchronization - start
				  //Map synchroResults  = (Map) JPO.invoke(context,"AT_emxDeformable", null, "launchEncapsulatedSynchro", synchroBOMArgs,	Map.class);
				  Map synchroResults  = (Map) JPO.invoke(context,"AT_emxDeformable", null, "launchEncapsulatedSynchroPublicAPI", synchroBOMArgs,	Map.class);
				//Modified to fix redmine 8680 - Use public API for synchronization - end
				  System.out.println("synchroResults : "+synchroResults);

				if (synchroResults != null) {
					if (synchroResults.containsKey("ERROR_MESSAGE")) {
						Object errorMessage = synchroResults.get("ERROR_MESSAGE");
						String sErrorSynchro = "Synchronization Error: \\n";
						if (errorMessage instanceof String) {
							sErrorSynchro += (String) errorMessage;
						} else if (synchroResults.get("ERROR_MESSAGE") instanceof ArrayList<?>) {
							ArrayList<String> alErrorSynchro = (ArrayList<String>) errorMessage;
							Iterator<String> itResult = alErrorSynchro.iterator();
							while (itResult.hasNext()) {
								sErrorSynchro += itResult.next();
							}
						}																				
	%>           
					 <script language="javascript" type="text/javaScript">
					 alert("<%=sErrorSynchro%>");
					 </script>
	 <%
					} else if (synchroResults.containsKey("ERROR_MESSAGES")) {
						ArrayList alERROR_MESSAGES = (ArrayList) synchroResults.get("ERROR_MESSAGES");

						StringBuffer sbErrorMessage = new StringBuffer();
						if (alERROR_MESSAGES != null & alERROR_MESSAGES.size() > 0) {
							for (int i = 0; i < alERROR_MESSAGES.size(); i++) {
								sbErrorMessage.append((String) alERROR_MESSAGES.get(i));
							}
							String ErrorMessage = sbErrorMessage.toString();
	%>           
					 <script language="javascript" type="text/javaScript">
					 alert("Synchronization Error: \n <%=ErrorMessage%>");
					 </script>
	 <%
						}
					} 
				}
	 }				
	 //External Request 7898 WP7 QC5070	END
	 
%>           
     <script language="javascript" type="text/javaScript">
	 //XSSOK
       <%--  //var url = "../common/emxForm.jsp?fromPartFamilyNav=<%=fromPartFamilyNav%>&form=type_Part&formHeader=emxEngineeringCentral.Part.EditPart&mode=edit&categoryTreeName=type_Part&viewtoolbar=ENCpartPartDetailsToolBar&HelpMarker=emxhelpparteditdetails&preProcessJavaScript=preProcessInEditPart&postProcessJPO=emxPart:partEditPostProcess&suiteKey=TeamBOMEditor&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&objectId=<%=newObjectId%>&emxTableRowId=<%=newObjectId%>&cancelAction=cancel&fromClone=true&postProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent&cancelProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent"; --%>
        <%-- //var url = "../common/emxPortal.jsp?portal=ENCPartPropertyPortal&header=emxEngineeringCentral.Heading.PropertiesHeader&fromPartFamilyNav=<%=fromPartFamilyNav%>&form=type_Part&mode=edit&formHeader=emxEngineeringCentral.Part.EditPart&categoryTreeName=type_Part&viewtoolbar=ENCpartPartDetailsToolBar&HelpMarker=emxhelpparteditdetails&preProcessJavaScript=preProcessInEditPart&postProcessJPO=emxPart:partEditPostProcess&suiteKey=TeamBOMEditor&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&objectId=<%=newObjectId%>&emxTableRowId=<%=newObjectId%>&cancelAction=cancel&fromClone=true&postProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent&cancelProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent"; --%>
        var url = "../common/emxTree.jsp?AppendParameters=true&portal=ENCPartPropertyPortal&header=emxEngineeringCentral.Heading.PropertiesHeader&fromPartFamilyNav=<%=fromPartFamilyNav%>&form=type_Part&formHeader=emxEngineeringCentral.Part.EditPart&categoryTreeName=type_Part&viewtoolbar=ENCpartPartDetailsToolBar&HelpMarker=emxhelpparteditdetails&preProcessJavaScript=preProcessInEditPart&postProcessJPO=emxPart:partEditPostProcess&suiteKey=TeamBOMEditor&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&objectId=<%=newObjectId%>&cancelAction=cancel&fromClone=true&postProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent&cancelProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent";
	    //XSSOK	 
        if ("<%= fromPartPropertiesNav%>" != null && "<%= fromPartPropertiesNav%>" == "true") {         	
       //    		var url = "../common/emxPortal.jsp?portal=ENCPartPropertyPortal&header=emxEngineeringCentral.Heading.PropertiesHeader&fromPartFamilyNav=<%=fromPartFamilyNav%>&form=type_Part&mode=edit&formHeader=emxEngineeringCentral.Part.EditPart&mode=edit&categoryTreeName=type_Part&viewtoolbar=ENCpartPartDetailsToolBar&HelpMarker=emxhelpparteditdetails&preProcessJavaScript=preProcessInEditPart&postProcessJPO=emxPart:partEditPostProcess&suiteKey=TeamBOMEditor&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&objectId=<%=newObjectId%>&cancelAction=cancel&fromClone=true&postProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent&cancelProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent";
       winObject = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
  			 
			winObject.document.location.href = url; 
			getTopWindow().closeWindow();//External Request 7898 WP7 QC5070			
   			  
        } else {
              winObject = findFrame(getTopWindow(), "content");
              var url2 = "../common/emxTree.jsp?AppendParameters=true&portal=ENCPartPropertyPortal&header=emxEngineeringCentral.Heading.PropertiesHeader&fromPartFamilyNav=<%=fromPartFamilyNav%>&form=type_Part&formHeader=emxEngineeringCentral.Part.EditPart&categoryTreeName=type_Part&viewtoolbar=ENCpartPartDetailsToolBar&HelpMarker=emxhelpparteditdetails&preProcessJavaScript=preProcessInEditPart&postProcessJPO=emxPart:partEditPostProcess&suiteKey=TeamBOMEditor&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&objectId=<%=newObjectId%>&cancelAction=cancel&fromClone=true&postProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent&cancelProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent";
              winObject.document.location.href = url2;     
              getTopWindow().closeSlideInDialog();
        }                               
</script>
<%                      
}
//Added for To Create Multiple part from Part Clone end
%>
