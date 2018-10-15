<%--  emxComponentsPackageReportSummary.jsp -  This page displays a list of specs for a part (CAD Drawing, CAD Model, Drawing Print)
   Copyright (c) 199x-2002 MatrixOne, Inc.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

static const char RCSID[] = $Id: emxComponentsPackageReportSummary.jsp.rca 1.27 Wed Oct 22 16:18:55 2008 przemek Experimental przemek $
--%>

<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxComponentsJavaScript.js" %>
<%@ include file = "../emxJSValidation.inc" %>

<%
  String languageStr = request.getHeader("Accept-Language");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String partId = emxGetParameter(request,"objectId");
  String selectedlevelno = emxGetParameter(request,"level");
  String tokenalllevels = emxGetParameter(request,"tokenalllevels");
  String incBOMStructure = emxGetParameter(request,"incBOMStructure");

  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");

  String strDownloadProgram = emxGetParameter(request,"downloadProgram");
  String strDownloadMethod = emxGetParameter(request,"downloadMethod");
  String sArchiveName = "";
  String sWorkspaceFolderId = "";
  
  String bTeam =  emxGetParameter(request,"bTeam");
  //enter only if  teamcentral is installed or not. 
  if( bTeam !=null && !"null".equals(bTeam) && !"".equals(bTeam) && "true".equals(bTeam))
  {
       Properties createPackageprop = (Properties) session.getAttribute("createPackage_KEY");
       sWorkspaceFolderId      = createPackageprop.getProperty("workspaceFolderId_KEY");
       sArchiveName = createPackageprop.getProperty("archiveName_KEY");
  }
  
    //Fix for IR-575425-3DEXPERIENCER2016x Starts
  String MQLResultModel = MqlUtil.mqlCommand(context, "print type $1 select $2 dump", "MCAD Model", "derivative");
  HashSet addedInMap  = new HashSet();
  String MQLResultDrawing = MqlUtil.mqlCommand(context, "print type $1 select $2 dump", "MCAD Drawing", "derivative");
  String CADTypeMQL = MQLResultModel+","+MQLResultDrawing;
  //Fix for IR-575425-3DEXPERIENCER2016x Ends
  
  boolean isPrinterFriendly = false;
  String printerFriendly = emxGetParameter(request, "PrinterFriendly");

  if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly)) {
    isPrinterFriendly = "true".equals(printerFriendly);
  }


  String strRelEBOM = DomainRelationship.RELATIONSHIP_EBOM; //for sub part
  String typePart = DomainObject.TYPE_PART;
  String parttypetrn = typePart;

    String spectypetrn="*";

  String strRelPartSpecification= DomainRelationship.RELATIONSHIP_PART_SPECIFICATION; //for specification
  String strRelRefDocument= DomainRelationship.RELATIONSHIP_REFERENCE_DOCUMENT; //for ref doc node
  String specrelationshiptrn = strRelPartSpecification+","+strRelRefDocument;
  
      String includeRelPattern = EnoviaResourceBundle.getProperty(context,"emxFramework.PackageReport.SpecRelationshipPattern.IncludeList");
    if(UIUtil.isNotNullAndNotEmpty(includeRelPattern)){
    	StringList includeRelPatternList = FrameworkUtil.split(includeRelPattern, ",");
        Iterator includeRelPatternListItr = includeRelPatternList.iterator();

        while(includeRelPatternListItr.hasNext())
        {
            String relPatternSymbolic = (String) includeRelPatternListItr.next();
            String relPatternActual = (String)PropertyUtil.getSchemaProperty(context, relPatternSymbolic);
            specrelationshiptrn = specrelationshiptrn + "," + relPatternActual;
        }
    }

  String defaultTypeIcon = JSPUtil.getCentralProperty(application, session, "type_Default", "SmallIcon");

  Short SLevel = new Short(selectedlevelno);
  short shLevel = SLevel.shortValue();

  com.matrixone.apps.common.Person currentUser = com.matrixone.apps.common.Person.getPerson (context);

 SelectList selectRelStmts = new SelectList();
 selectRelStmts.addElement(DomainRelationship.SELECT_RELATIONSHIP_ID);
 selectRelStmts.addElement(DomainRelationship.SELECT_RELATIONSHIP_NAME);
 selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_QUANTITY);

 SelectList selectStmts = new SelectList();
 selectStmts.addElement(DomainObject.SELECT_ID);
 selectStmts.addElement(DomainObject.SELECT_TYPE);
 selectStmts.addElement(DomainObject.SELECT_NAME);
 selectStmts.addElement(DomainObject.SELECT_REVISION);
 selectStmts.addElement(DomainObject.SELECT_DESCRIPTION);
 selectStmts.addElement(DomainObject.SELECT_CURRENT);
 selectStmts.addElement(DomainObject.SELECT_POLICY);
 selectStmts.addElement(DomainObject.SELECT_ATTRIBUTE_QUANTITY);
 selectStmts.addElement(DomainObject.SELECT_ATTRIBUTE_UNITOFMEASURE);
 selectStmts.addElement(DomainObject.SELECT_FILE_SIZE);

    MapList ebomList = new MapList();
    MapList specList = new MapList();
    MapList fileList = new MapList();
    MapList displaymapList = new MapList();

	java.util.Set inputIDS = new HashSet();
	Hashtable specIDSpecLevel = new Hashtable();
	String typeCADModel   = (String)PropertyUtil.getSchemaProperty(context, "type_CADModel");
	String typeCADDrawing = (String)PropertyUtil.getSchemaProperty(context, "type_CADDrawing");
	boolean baseTypeFound = false;
	String type = "";
	String baseType = "";		
	
    String slevelno ="";
    String levelno = "";
    String checkBoxValue= "";
    String displayIcon = "";
    String nextURL="";
    String target= "";
    String sFmtName ="";
    String sFileName="";
    char cFieldSep = 0x09;
    String delimiter = String.valueOf(cFieldSep);

  //Determine if we should use printer friendly version
  String showPrinterFriendly = emxGetParameter(request,"showPrinterFriendly");
  if (("".equals(showPrinterFriendly)) || (showPrinterFriendly == null)){

    try {
      Part partObj = new Part(partId);
     String parentPartType = (String)partObj.getInfo(context,DomainConstants.SELECT_TYPE);
     String parentPartName = (String)partObj.getInfo(context,DomainConstants.SELECT_NAME);
     String parentPart = parentPartType+"_"+parentPartName;

     //step 1- get specifications for parent part  & files attached to it
     //insert info into displaymap

         slevelno="0";
         Short PLevel = new Short(slevelno);
         short sPLevel = PLevel.shortValue();

         specList = partObj.getRelatedObjects(context,specrelationshiptrn,spectypetrn,selectStmts,selectRelStmts,false,true,sPLevel,"","");

          if(specList.size() > 0){
                Iterator ipspec = specList.iterator();
                     while (ipspec.hasNext()) {
                          Map mpspec = (Map) ipspec.next();
                          String selectparentspecobjId = (String)mpspec.get(DomainConstants.SELECT_ID);
                          String selectparentspecobjName =(String)mpspec.get(DomainConstants.SELECT_NAME);
			  inputIDS.add(selectparentspecobjId);
                          //Added for the fix 372917 
                          if (selectparentspecobjName.indexOf("/")!=-1)
                          {
                              selectparentspecobjName=com.matrixone.jsystem.util.StringUtils.replaceAll(selectparentspecobjName,"/","-");
							  
						   }
                          //372719 fix ends
                          String selectparentspecobjType =(String)mpspec.get(DomainConstants.SELECT_TYPE);
                          String selectparentspecobjRev =(String)mpspec.get(DomainConstants.SELECT_REVISION);
                          String selectparentspecObj = selectparentspecobjType+"_"+selectparentspecobjName+"_"+selectparentspecobjRev;
                          
                          String selectparentspecUOM = (String)mpspec.get(DomainConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
                          if (! UIUtil.isNullOrEmpty(selectparentspecUOM)){
                        	  selectparentspecUOM = selectparentspecUOM.replace(' ','_');
                        	  selectparentspecUOM = "emxFramework.Range.Unit_of_Measure."+selectparentspecUOM;
                        	  selectparentspecUOM = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), selectparentspecUOM); 
                          }
                          
                          int selectparentspecobjlevel = 0; //document level = part level

			  specIDSpecLevel.put(selectparentspecobjId, Integer.toString(selectparentspecobjlevel));

                          nextURL =  "../common/emxTree.jsp?AppendParameters=true&mode=insert&objectId=" + selectparentspecobjId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey +"&parentId="+partId;
                          target = " target=\"content\"";

                          String typeIcon3;
                          String alias3 = FrameworkUtil.getAliasForAdmin(context, "type", selectparentspecobjType, true);
                          if ( alias3 == null || alias3.equals("")){
                                typeIcon3 = defaultTypeIcon;
                          }else if(alias3.equals("type_AT_C_DOCUMENT")){
                        	  typeIcon3 = "iconSmallDocument.gif";
                          }else if(alias3.equals("type_AT_C_LOGICAL_NODE")){
                        	  typeIcon3 = "Logical_Node.png";
                          }else if(alias3.equals("type_AT_C_CONFIGURATION_ITEM")){
                        	  typeIcon3 = "Configure_Item.png";
                          }else if(alias3.equals("type_AT_C_EXPECTED_PRODUCT")){
                        	  typeIcon3 = "Expected_Product.png";
                          }else if(alias3.equals("type_AT_C_DESIGN_PART")){
                        	  typeIcon3 = "Part_Design.png";
                          }else if(alias3.equals("type_AT_C_COS")){
                        	  typeIcon3 = "Component_on_Specification.png";
                          }else if(alias3.equals("type_AT_C_STANDARD_PART")){
                        	  typeIcon3 = "Standard_Part.png";
                          }else if(alias3.equals("type_AT_C_STANDARD_DOC")){
                        	  typeIcon3 = "Standard_Doc.png";
                          }else{
                                 typeIcon3 = JSPUtil.getCentralProperty(application, session, alias3, "SmallIcon");
                          }
                          displayIcon = typeIcon3;
                             
							if(typeIcon3 == null)
							{
								baseTypeFound = false;
								type = selectparentspecobjType;							 
								 
								 while(baseTypeFound == false)
								{
									if(Document.isSuperType(context, type))
									{
										break;
									}
									BusinessType businessType = new BusinessType(type, context.getVault());
									String parentType = businessType.getParent(context);

									if(parentType.equals(typeCADDrawing))
									{
										baseType = typeCADDrawing;
										typeIcon3= "iconSmallCADDrawing.gif";
										baseTypeFound = true;
									}
									else if(parentType.equals(typeCADModel))
									{
										baseType = typeCADModel;
										typeIcon3="iconSmallCADModel.gif";
										baseTypeFound = true;
									}
									else
									{
										type = parentType;
									}
								}
							}
                             //map to store spec info
                              HashMap displayparentspecmap = new HashMap();
                              displayparentspecmap.put("checkbox","none");
                              displayparentspecmap.put("typeicon",typeIcon3);
                              displayparentspecmap.put("nexturl",nextURL);
                              displayparentspecmap.put("id",selectparentspecobjId);
                              displayparentspecmap.put("lvl",""+selectparentspecobjlevel);
                              displayparentspecmap.put("name",selectparentspecobjName);
                              displayparentspecmap.put("rev",(String)mpspec.get(DomainConstants.SELECT_REVISION));
                              displayparentspecmap.put("type",selectparentspecobjType);
                              displayparentspecmap.put("desc",(String)mpspec.get(DomainConstants.SELECT_DESCRIPTION));
                              displayparentspecmap.put("state",i18nNow.getStateI18NString ((String)mpspec.get(DomainConstants.SELECT_POLICY),(String)mpspec.get(DomainConstants.SELECT_CURRENT ),languageStr));
                              displayparentspecmap.put("qty",(String)mpspec.get(DomainConstants.SELECT_ATTRIBUTE_QUANTITY));
                              displayparentspecmap.put("uom",selectparentspecUOM);
                           
                             // displayparentspecmap.put("size",(StringList)mpspec.get(DomainConstants.SELECT_FILE_SIZE));
                      String parentSpecFilesize = "";
                      StringList parentSpecFilesizeList = new StringList();
                       try{
                         parentSpecFilesizeList = (StringList)mpspec.get(DomainConstants.SELECT_FILE_SIZE);
                       }catch(ClassCastException exp){
                         parentSpecFilesize = (String)mpspec.get(DomainConstants.SELECT_FILE_SIZE);
                       }
                          displayparentspecmap.put("size","");

                               //for each specifications get the attachments
                               DomainObject domainObj = DomainObject.newInstance(context);
                               domainObj.setId(selectparentspecobjId);
                               String isVCDoc = domainObj.getInfo(context, com.matrixone.apps.common.CommonDocument.SELECT_IS_KIND_OF_VC_DOCUMENT);
                               if ((isVCDoc == null) || ("".equals(isVCDoc)) || ("null".equals(isVCDoc)))
                                 isVCDoc = "false";
                               StringList pversionSelectList = new StringList(3);
                               pversionSelectList.add(Document.SELECT_ID);
                               pversionSelectList.add(Document.SELECT_TITLE);
                               pversionSelectList.add(Document.SELECT_CHECKIN_REASON);
                               MapList pversionList = null;
                               String strVCIndex = "";
                               String strVCVersion = "";
                               
                               if (isVCDoc.equalsIgnoreCase("false"))
                               {
                                 pversionList = domainObj.getRelatedObjects(context,
                                                                            Document.RELATIONSHIP_ACTIVE_VERSION,
                                                                            Document.TYPE_DOCUMENTS,
                                                                            pversionSelectList,
                                                                            null,
                                                                            false,
                                                                            true,
                                                                            (short)1,
                                                                            null,
                                                                            null,
                                                                            null,
                                                                            null,
                                                                            null);
                                 fileList = domainObj.getAllFormatFiles(context);
                                 strVCIndex = "0";
                                 strVCVersion = "0";
                               }
                               else
                               {
	                              String isVCFolder = domainObj.getInfo(context, "vcfolder");
	                              String vcSelect = "vcfile[1]";
	                              if (isVCFolder.equalsIgnoreCase("true"))
	                                vcSelect = "vcfolder[1]";
                                  pversionSelectList.add(vcSelect + ".vcname");
                                  pversionSelectList.add(vcSelect + ".format");
                                  pversionSelectList.add(vcSelect + ".versionid");
                                  pversionSelectList.add(vcSelect + ".index");
	                              Map vcMap = domainObj.getInfo(context, pversionSelectList);
                                  pversionList = new MapList();
                                  pversionList.add(vcMap);
                                  
                                  Map fileMap = new HashMap();
                                  fileMap.put("filename", (String)vcMap.get(vcSelect + ".vcname"));
                                  fileMap.put("format", (String)vcMap.get(vcSelect + ".format"));
                                  strVCIndex = (String)vcMap.get(vcSelect + ".index");
                                  strVCVersion = (String)vcMap.get(vcSelect + ".versionid");
                                  fileList.add(fileMap);
                               }

                               int k=0;

                               Map pversionMap ;
                               String ptitle ="";
                               String pfileDescription = null;

                               int fileSize = fileList.size();
                               if(fileSize > 0) {
                                  displaymapList.add(displayparentspecmap); //add spec obj info
                                  Iterator ipfile = fileList.iterator();
                                  while (ipfile.hasNext()) {
                                       Map pfileMap = (Map) ipfile.next();
                                       sFmtName   = (String)pfileMap.get(domainObj.KEY_FORMAT);
                                       sFileName    = (String)pfileMap.get(domainObj.KEY_FILENAME);
                                       Iterator pitr = pversionList.iterator();
                                       pfileDescription = "";
                                       while(pitr.hasNext()) {
                                           pversionMap = (Map)pitr.next();
                                           ptitle = (String)pversionMap.get(Document.SELECT_TITLE);
                                           if(sFileName.equals(ptitle)) {
                                               pfileDescription = (String)pversionMap.get(Document.SELECT_CHECKIN_REASON);
                                           }

                                       }


                     String tempParentFolder = parentPart;
                     String combFolderAdd=tempParentFolder+java.io.File.separator+selectparentspecObj;

                     checkBoxValue = combFolderAdd+delimiter+ partId + "|" + selectparentspecobjId +delimiter+sFmtName  + delimiter + sFileName + delimiter + strVCIndex +delimiter+"versionid@" + strVCVersion;

                                      target = " target=\"content\"";

                                      displayIcon = defaultTypeIcon;
                                       //map to store file info
                                       HashMap displayparentfilemap = new HashMap();
                                      displayparentfilemap.put("checkbox",checkBoxValue);
                                      displayparentfilemap.put("typeicon",defaultTypeIcon);
                                      displayparentfilemap.put("nexturl",nextURL);
                                      displayparentfilemap.put("id",selectparentspecobjId);
                                      displayparentfilemap.put("lvl",""+selectparentspecobjlevel);
                                      displayparentfilemap.put("name",sFileName);
                                      displayparentfilemap.put("rev","");
                                      displayparentfilemap.put("type","File");
                                      displayparentfilemap.put("desc",pfileDescription);
                                      displayparentfilemap.put("state"," ");
                                      displayparentfilemap.put("qty"," ");
                                      displayparentfilemap.put("uom"," ");
                                      if (fileSize == 1)
                                      {
                                         displayparentfilemap.put("size",parentSpecFilesize);
                                      }
                                      else
                                      {
	                                      if (parentSpecFilesizeList.size() > k)
                                             displayparentfilemap.put("size",parentSpecFilesizeList.elementAt(k));
                                       }

                                         //add obj info only if there are files attached
                                         displaymapList.add(displayparentfilemap); //add file info
                                         k++;
                                  }
                            }
                      }
                }

if(!(selectedlevelno.equals("0")&&tokenalllevels.equals("")))  {
     //step 2 - get ebom part for parent part, get the specifications for each part & files attached to it
     //insert info into displaymap

      //get list of ebom for parent part
     // ebomList = partObj.getEBOMs(context,selectStmts,selectRelStmts,relationship,false,shLevel,false);

     // getRelatedObjects(matrix.db.Context context, java.lang.String relationshipPattern, java.lang.String typePattern, matrix.util.StringList objectSelects, matrix.util.StringList relationshipSelects, boolean getTo, boolean getFrom, short recurseToLevel, java.lang.String objectWhere, java.lang.String relationshipWhere)

     ebomList = partObj.getRelatedObjects(context,strRelEBOM,parttypetrn,selectStmts,selectRelStmts,false,true,shLevel,"","");

     int ebomlistSize = ebomList.size();

     String sSupplierId="";
     boolean isSupplierComp=false;
     sSupplierId = currentUser.getCompanyId(context);

     if(sSupplierId!=null && !"null".equals(sSupplierId) && !"".equals(sSupplierId))
     {
        DomainObject supDomObj = DomainObject.newInstance(context,sSupplierId);

        Pattern relPattern  = new Pattern(PropertyUtil.getSchemaProperty(context,"relationship_Supplier"));
        Pattern typePattern = new Pattern(DomainConstants.TYPE_COMPANY);
        MapList buyerCompanyList = supDomObj.getRelatedObjects(context,
                                                                  relPattern.getPattern(),
                                                                  typePattern.getPattern(),
                                                                  null,
                                                                  null,
                                                                  true,
                                                                  false,
                                                                  (short)1,
                                                                  "",
                                                                  "",
                                                                  null,
                                                                  null,
                                                                  null);
        if(buyerCompanyList!=null && buyerCompanyList.size() >0)
        {
          isSupplierComp=true;
        }
     }

      Hashtable thisEBOMParents = new Hashtable();
      if( ebomlistSize > 0){
            Iterator ibom = ebomList.iterator();
            while (ibom.hasNext()) {
				Map tempMap=new HashMap();
                Map mbom = (Map) ibom.next();
                String selectobjId = (String)mbom.get(DomainConstants.SELECT_ID);
                String selectobjName = (String)mbom.get(DomainConstants.SELECT_NAME);
                String selectobjType = (String)mbom.get(DomainConstants.SELECT_TYPE);
                String selectobjRev = (String)mbom.get(DomainConstants.SELECT_REVISION);
                String selectobjlevel = (String)mbom.get("level");
                
                String selectobjUOM = (String)mbom.get(DomainConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
                if (! UIUtil.isNullOrEmpty(selectobjUOM)){
                    selectobjUOM = selectobjUOM.replace(' ','_');
                    selectobjUOM = "emxFramework.Range.Unit_of_Measure."+selectobjUOM;
                    selectobjUOM = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), selectobjUOM);
                }

                String ebomPart = selectobjType+"_"+selectobjName+"_"+selectobjRev;
                thisEBOMParents.put(selectobjlevel,ebomPart);

                 nextURL =  "../common/emxTree.jsp?AppendParameters=true&mode=insert&objectId=" + selectobjId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey +"&parentId="+partId;
                 target = " target=\"content\"";

                String typeIcon1;
                String alias1 = FrameworkUtil.getAliasForAdmin(context, "type", selectobjType, true);
                if ( alias1 == null || alias1.equals("")){
                  typeIcon1 = defaultTypeIcon;
                }else if(alias1.equals("type_AT_C_DOCUMENT")){
                	typeIcon1 = "iconSmallDocument.gif";
                }else if(alias1.equals("type_AT_C_LOGICAL_NODE")){
                	typeIcon1 = "Logical_Node.png";
                }else if(alias1.equals("type_AT_C_CONFIGURATION_ITEM")){
                	typeIcon1 = "Configure_Item.png";
                }else if(alias1.equals("type_AT_C_EXPECTED_PRODUCT")){
                	typeIcon1 = "Expected_Product.png";
                }else if(alias1.equals("type_AT_C_DESIGN_PART")){
                	typeIcon1 = "Part_Design.png";
                }else if(alias1.equals("type_AT_C_COS")){
                	typeIcon1 = "Component_on_Specification.png";
                }else if(alias1.equals("type_AT_C_STANDARD_PART")){
              	  typeIcon1 = "Standard_Part.png";
                }else if(alias1.equals("type_AT_C_STANDARD_DOC")){
                	typeIcon1 = "Standard_Doc.png";
                }else{
                  typeIcon1 = JSPUtil.getCentralProperty(application, session, alias1, "SmallIcon");
                }
                 displayIcon = typeIcon1;

                    //map to store ebom part info
                    HashMap displaymap = new HashMap();
                    displaymap.put("checkbox","none");
                    displaymap.put("typeicon",typeIcon1);
                    displaymap.put("nexturl",nextURL);
                    displaymap.put("id",selectobjId);
                    displaymap.put("lvl",selectobjlevel);
                    displaymap.put("name",(String)mbom.get(DomainConstants.SELECT_NAME));
                    displaymap.put("rev",(String)mbom.get(DomainConstants.SELECT_REVISION));
                    displaymap.put("type",(String)mbom.get(DomainConstants.SELECT_TYPE));
                    displaymap.put("desc",(String)mbom.get(DomainConstants.SELECT_DESCRIPTION));
                    displaymap.put("state",i18nNow.getStateI18NString ((String)mbom.get(DomainConstants.SELECT_POLICY),(String)mbom.get(DomainConstants.SELECT_CURRENT ),languageStr));
                    displaymap.put("qty",(String)mbom.get(DomainConstants.SELECT_ATTRIBUTE_QUANTITY));
                    displaymap.put("uom",selectobjUOM);
                    displaymap.put("size","");

                    //get specs for each part
                    Part subpartObj = new Part(selectobjId);

                    levelno="0";
                    Short pLevel2 = new Short(levelno);
                    short SpLevel2 = pLevel2.shortValue();
					
					//Fix for IR-575425-3DEXPERIENCER2016x Starts
					String typeDECList = (String)tempMap.get(DomainObject.SELECT_TYPE);
					if(CADTypeMQL.toLowerCase().contains(typeDECList.toLowerCase()) && !addedInMap.contains(selectobjId))
						specList = subpartObj.getRelatedObjects(context,specrelationshiptrn,spectypetrn,selectStmts,selectRelStmts,false,true,SpLevel2,"","");
					addedInMap.add(selectobjId);
					//Fix for IR-575425-3DEXPERIENCER2016x Ends

                    //specList  = subpartObj.getSpecifications(context, selectsubStmts, selectsubRelStmts, false);
                    specList = subpartObj.getRelatedObjects(context,specrelationshiptrn,spectypetrn,selectStmts,selectRelStmts,false,true,SpLevel2,"","");

                    boolean filesExist = false;
                    int speclistSize = specList.size();
                    if(speclistSize > 0){
                        displaymapList.add(displaymap);  //add ebom part info

                         Iterator ispec = specList.iterator();
                           while (ispec.hasNext()) {
                              Map mspec = (Map) ispec.next();
                               String selectspecobjId = (String)mspec.get(DomainConstants.SELECT_ID);
 			       inputIDS.add(selectspecobjId);
                               String selectspecobjName =(String)mspec.get(DomainConstants.SELECT_NAME);
                               String selectspecobjType =(String)mspec.get(DomainConstants.SELECT_TYPE);
                               String selectspecobjRev =(String)mspec.get(DomainConstants.SELECT_REVISION);
                               
                               String selectspecobjUOM = (String)mspec.get(DomainConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
                               if (! UIUtil.isNullOrEmpty(selectspecobjUOM)){
                            	    selectspecobjUOM = selectspecobjUOM.replace(' ','_');
                            	    selectspecobjUOM = "emxFramework.Range.Unit_of_Measure."+selectspecobjUOM;
                            	    selectspecobjUOM = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), selectspecobjUOM);
                               }
                               
                               String specObjName = selectspecobjType+"_"+selectspecobjName+"_"+selectspecobjRev;

                               int selectspecobjlevel = Integer.parseInt(selectobjlevel)+1; //document level = part level
     				specIDSpecLevel.put(selectspecobjId, selectobjlevel);

                                nextURL =  "../common/emxTree.jsp?AppendParameters=true&mode=insert&objectId=" + selectspecobjId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey +"&parentId="+partId;
                                target = " target=\"content\"";

                              String typeIcon2;
                              String alias2 = FrameworkUtil.getAliasForAdmin(context, "type", selectspecobjType, true);
                              if ( alias2 == null || alias2.equals("")){
                                typeIcon2 = defaultTypeIcon;
                               }else if(alias2.equals("type_AT_C_DOCUMENT")){
                            	   typeIcon2 = "iconSmallDocument.gif";
                               }else if(alias2.equals("type_AT_C_LOGICAL_NODE")){
                            	   typeIcon2 = "Logical_Node.png";
                               }else if(alias2.equals("type_AT_C_CONFIGURATION_ITEM")){
                            	   typeIcon2 = "Configure_Item.png";
                               }else if(alias2.equals("type_AT_C_EXPECTED_PRODUCT")){
                            	   typeIcon2 = "Expected_Product.png";
                               }else if(alias2.equals("type_AT_C_DESIGN_PART")){
                            	   typeIcon2 = "Part_Design.png";
                               }else if(alias2.equals("type_AT_C_COS")){
                            	   typeIcon2 = "Component_on_Specification.png";
                               }else if(alias2.equals("type_AT_C_STANDARD_PART")){
                            	   typeIcon2 = "Standard_Part.png";
                               }else if(alias2.equals("type_AT_C_STANDARD_DOC")){
                            	   typeIcon2 = "Standard_Doc.png";
                               }else{
                                 typeIcon2 = JSPUtil.getCentralProperty(application, session, alias2, "SmallIcon");
                               }
                                displayIcon = typeIcon2;

								if(typeIcon2 == null)
								{
									baseTypeFound = false;
									type = selectspecobjType;
																 
									 while(baseTypeFound == false)
									{
										if(Document.isSuperType(context, type))
										{
											break;
										}
										BusinessType businessType = new BusinessType(type, context.getVault());
										String parentType = businessType.getParent(context);

										if(parentType.equals(typeCADDrawing))
										{
											baseType = typeCADDrawing;
											typeIcon2= "iconSmallCADDrawing.gif";
											baseTypeFound = true;
										}
										else if(parentType.equals(typeCADModel))
										{
											baseType = typeCADModel;
											typeIcon2="iconSmallCADModel.gif";
											baseTypeFound = true;
										}
										else
										{
											type = parentType;
										}
									}
								}
								
                              //map to store spec info
                              HashMap displayspecmap = new HashMap();
                              displayspecmap.put("checkbox","none");
                              displayspecmap.put("typeicon",typeIcon2);
                              displayspecmap.put("nexturl",nextURL);
                              displayspecmap.put("id",selectspecobjId);
                              displayspecmap.put("lvl",selectobjlevel);//document level = part level
                              displayspecmap.put("name",selectspecobjName);
                              displayspecmap.put("rev",(String)mspec.get(DomainConstants.SELECT_REVISION));
                              displayspecmap.put("type",selectspecobjType);
                              displayspecmap.put("desc",(String)mspec.get(DomainConstants.SELECT_DESCRIPTION));
                              displayspecmap.put("state",i18nNow.getStateI18NString ((String)mspec.get(DomainConstants.SELECT_POLICY),(String)mspec.get(DomainConstants.SELECT_CURRENT ),languageStr));
                              displayspecmap.put("qty",(String)mspec.get(DomainConstants.SELECT_ATTRIBUTE_QUANTITY));
                              displayspecmap.put("uom",selectspecobjUOM);

                             String specFilesize = "";
                             StringList specFilesizeList = new StringList();
                             try{
                                specFilesizeList = (StringList)mspec.get(DomainConstants.SELECT_FILE_SIZE);
                             }catch(ClassCastException exp){
                                specFilesize = (String)mspec.get(DomainConstants.SELECT_FILE_SIZE);
                             }
                              displayspecmap.put("size","");

                               //for each specifications get the attachments
                               DomainObject domainObj = DomainObject.newInstance(context);
                               domainObj.setId(selectspecobjId);
                               StringList versionSelectList = new StringList(3);
                               versionSelectList.add(Document.SELECT_ID);
                               versionSelectList.add(Document.SELECT_TITLE);
                               versionSelectList.add(Document.SELECT_CHECKIN_REASON);
                               String isVCDoc = domainObj.getInfo(context, com.matrixone.apps.common.CommonDocument.SELECT_IS_KIND_OF_VC_DOCUMENT);
                               if ((isVCDoc == null) || ("".equals(isVCDoc)) || ("null".equals(isVCDoc)))
                                 isVCDoc = "false"; 
                               String strVCIndex = "";
                               String strVCVersion = "";
                               MapList versionList = null;
                                 
                               if (isVCDoc.equalsIgnoreCase("false"))
                               {
                                    versionList = domainObj.getRelatedObjects(context,
                                                                                      Document.RELATIONSHIP_ACTIVE_VERSION,
                                                                                      Document.TYPE_DOCUMENTS,
                                                                                      versionSelectList,
                                                                                      null,
                                                                                      false,
                                                                                      true,
                                                                                      (short)1,
                                                                                      null,
                                                                                      null,
                                                                                      null,
                                                                                      null,
                                                                                      null);
                                 fileList = domainObj.getAllFormatFiles(context);
                                 strVCIndex = "0";
                                 strVCVersion = "0";
                               }
                               else
                               {
	                              String isVCFolder = domainObj.getInfo(context, "vcfolder");
	                              String vcSelect = "vcfile[1]";
	                              if (isVCFolder.equalsIgnoreCase("true"))
	                                vcSelect = "vcfolder[1]";
                                  versionSelectList.add(vcSelect + ".vcname");
                                  versionSelectList.add(vcSelect + ".format");
                                  versionSelectList.add(vcSelect + ".versionid");
                                  versionSelectList.add(vcSelect + ".index");
	                              Map vcMap = domainObj.getInfo(context, versionSelectList);
                                  versionList = new MapList();
                                  versionList.add(vcMap);
                                  
                                  Map fileMap = new HashMap();
                                  fileMap.put("filename", (String)vcMap.get(vcSelect + ".vcname"));
                                  fileMap.put("format", (String)vcMap.get(vcSelect + ".format"));
                                  strVCIndex = (String)vcMap.get(vcSelect + ".index");
                                  strVCVersion = (String)vcMap.get(vcSelect + ".versionid");
                                  fileList.add(fileMap);
                               }
                               
                               int filelistsize = fileList.size();
                               int m=0;

                               Map versionMap ;
                               String title ="";
                               String fileDescription = null;

                               if(filelistsize > 0) {
                                    filesExist = true;
                                    displaymapList.add(displayspecmap); //add spec obj info
                                    Iterator ifile = fileList.iterator();
                                    while (ifile.hasNext()) {
                                       Map fileMap = (Map) ifile.next();
                                       sFmtName   = (String)fileMap.get(domainObj.KEY_FORMAT);
                                       sFileName    = (String)fileMap.get(domainObj.KEY_FILENAME);
                                       Iterator itr = versionList.iterator();
                                       fileDescription = "";
                                       while(itr.hasNext()) {
                                           versionMap = (Map)itr.next();
                                           title = (String)versionMap.get(Document.SELECT_TITLE);
                                           if(sFileName.equals(title)) {
                                               fileDescription = (String)versionMap.get(Document.SELECT_CHECKIN_REASON);
                                           }

                                       }

                                      // checkBoxValue = selectobjlevel + "|" + selectobjId + "|" + selectspecobjId + "|" + sFmtName  + "&" + sFileName;
                                        String tempParentFolder = parentPart;
                                        for(int j=1; j<selectspecobjlevel ; j++){
                                            tempParentFolder = tempParentFolder+java.io.File.separator+thisEBOMParents.get(""+j);
                                        }
                                        String combFolderAdd=tempParentFolder+java.io.File.separator+specObjName;

                                       
                                     checkBoxValue = combFolderAdd+delimiter+ selectobjId + "|" + selectspecobjId +delimiter+sFmtName  + delimiter + sFileName + delimiter + strVCIndex +delimiter+"versionid@" + strVCVersion;

                                      target = " target=\"content\"";
                                      displayIcon = defaultTypeIcon;

                                      //map to store file info
                                      HashMap displayfilemap = new HashMap();
                                      displayfilemap.put("checkbox",checkBoxValue);
                                      displayfilemap.put("typeicon",defaultTypeIcon);
                                      displayfilemap.put("nexturl",nextURL);
                                      displayfilemap.put("id",selectspecobjId);
                                      displayfilemap.put("lvl",selectobjlevel);
                                      displayfilemap.put("name",sFileName);
                                      displayfilemap.put("rev","");
                                      displayfilemap.put("type","File");
                                      displayfilemap.put("desc",fileDescription);
                                      displayfilemap.put("state"," ");
                                      displayfilemap.put("qty"," ");
                                      displayfilemap.put("uom"," ");

                                      if(filelistsize == 1){
                                       displayfilemap.put("size",specFilesize);
                                      }else {
										  if (specFilesizeList.size() > m)
                                       displayfilemap.put("size",specFilesizeList.elementAt(m));
                                       }

                                      //add all elements only if files exist
                                      displaymapList.add(displayfilemap); //add file info
                                      m++;
                                  }

                                }//end of file list
                               //if none of the spec have attached files donot display part
                           }
                            } //spec list is more than zero

                          if(!filesExist){
                                 displaymapList.remove(displaymap);  //remove ebom part info
                                }
                     }

                   }//ebom list is more than zero

			HashMap map = new HashMap(1);
                      map.put("objectIdSet", inputIDS);
                     	Hashtable specIdFamId = null;
						try{
					    specIdFamId =(Hashtable)matrix.db.JPO.invoke(context,
												  "emxGetFamilyIds",
												   null,
												  "getFamilyIds",
													JPO.packArgs(map),
												  Hashtable.class);
						}
						catch(Exception e){}
			if(null != specIdFamId  && specIdFamId.size() > 0)
			{
				//Fix for IR-559172 Start
				HashSet OBJIDSSet = new HashSet();
                Iterator famSpecsItr = specIdFamId.values().iterator();
				for(int i =0; famSpecsItr.hasNext(); i++)
				{
					String famId	= (String)famSpecsItr.next();
					
					if(!OBJIDSSet.contains(famId))
						OBJIDSSet.add(famId);
				}
				
				String[] objIds = new String[OBJIDSSet.size()];
				OBJIDSSet.toArray(objIds);
				//Fix for IR-559172 End
			
				BusinessObjectWithSelectList busWithSelectList = BusinessObject.getSelectBusinessObjectData(context, objIds, selectStmts);

				for (int i = 0; i < busWithSelectList.size(); i++)
				{
					BusinessObjectWithSelect busWithSelect = busWithSelectList.getElement(i);
                     
                          String famId = (String)busWithSelect.getSelectData(DomainConstants.SELECT_ID);
                          String famName =(String)busWithSelect.getSelectData(DomainConstants.SELECT_NAME);
						 
						  //Added for the fix 372917 
                          if (famName.indexOf("/")!=-1)
                          {
                              famName=com.matrixone.jsystem.util.StringUtils.replaceAll(famName,"/","-");
							  
						   }
                          //372719 fix ends
                          String famType =(String)busWithSelect.getSelectData(DomainConstants.SELECT_TYPE);
                          String famRev =(String)busWithSelect.getSelectData(DomainConstants.SELECT_REVISION);
                          String famObj = famType+"_"+famName+"_"+famRev;
                          
                          String famUOM = (String)busWithSelect.getSelectData(DomainConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
                          if (! UIUtil.isNullOrEmpty(famUOM)){
                        	  famUOM = famUOM.replace(' ','_');
                        	  famUOM = "emxFramework.Range.Unit_of_Measure."+famUOM;
                        	  famUOM = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), famUOM); 
                          }
                          //specIDSpecLevel.put(selectspecobjId, selectobjlevel);
						  int famLevel	= 0;
							Iterator specIdFamIdEntryItr =  specIdFamId.entrySet().iterator();
		
							while(specIdFamIdEntryItr.hasNext())
							{ 
								java.util.Map.Entry specIdFamIdEntry = (java.util.Map.Entry)specIdFamIdEntryItr.next();
								String specIdKey                  = (String)specIdFamIdEntry.getKey();
								String famIdVal                  = (String)specIdFamIdEntry.getValue();
								if(specIDSpecLevel.containsKey(specIdKey) && famIdVal.equals(famId))
								{
									String    instLevel             = (String)specIDSpecLevel.get(specIdKey);
									famLevel = Integer.parseInt(instLevel); //fam level = specInst level
									
									break;
								}
							}
                          nextURL =  "../common/emxTree.jsp?AppendParameters=true&mode=insert&objectId=" + famId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey;
                          target = " target=\"content\"";

                          String typeIcon3;
                          String alias3 = FrameworkUtil.getAliasForAdmin(context, "type", famType, true);
                          if ( alias3 == null || alias3.equals("")){
                                typeIcon3 = defaultTypeIcon;
                          }else if(alias3.equals("type_AT_C_DOCUMENT")){
                        	  typeIcon3 = "iconSmallDocument.gif";
                          }else if(alias3.equals("type_AT_C_LOGICAL_NODE")){
                        	  typeIcon3 = "Logical_Node.png";
                          }else if(alias3.equals("type_AT_C_CONFIGURATION_ITEM")){
                        	  typeIcon3 = "Configure_Item.png";
                          }else if(alias3.equals("type_AT_C_EXPECTED_PRODUCT")){
                        	  typeIcon3 = "Expected_Product.png";
                          }else if(alias3.equals("type_AT_C_DESIGN_PART")){
                        	  typeIcon3 = "Part_Design.png";
                          }else if(alias3.equals("type_AT_C_COS")){
                        	  typeIcon3 = "Component_on_Specification.png";
                          }else if(alias3.equals("type_AT_C_STANDARD_PART")){
                        	  typeIcon3 = "Standard_Part.png";
                          }else if(alias3.equals("type_AT_C_STANDARD_DOC")){
                        	  typeIcon3 = "Standard_Doc.png";
                          }else{
                                 typeIcon3 = JSPUtil.getCentralProperty(application, session, alias3, "SmallIcon");
                          }
                          displayIcon = typeIcon3;
						  
							if(typeIcon3 == null)
							{
								baseTypeFound = false;
								type = famType;
															 
								 while(baseTypeFound == false)
								{
									if(Document.isSuperType(context, type))
									{
										break;
									}
									BusinessType businessType = new BusinessType(type, context.getVault());
									String parentType = businessType.getParent(context);

									if(parentType.equals(typeCADDrawing))
									{
										baseType = typeCADDrawing;
										typeIcon3= "iconSmallCADDrawing.gif";
										baseTypeFound = true;
									}
									else if(parentType.equals(typeCADModel))
									{
										baseType = typeCADModel;
										typeIcon3="iconSmallCADModel.gif";
										baseTypeFound = true;
									}
									else
									{
										type = parentType;
									}
								}
							}
						  
                             //map to store spec info
                              HashMap famSpecMap = new HashMap();
                              famSpecMap.put("checkbox","none");
                              famSpecMap.put("typeicon",typeIcon3);
                              famSpecMap.put("nexturl",nextURL);
                              famSpecMap.put("id",famId);
                              famSpecMap.put("lvl",""+famLevel);
                              famSpecMap.put("name",famName);
                              famSpecMap.put("rev",(String)busWithSelect.getSelectData(DomainConstants.SELECT_REVISION));
                              famSpecMap.put("type",famType);
                              famSpecMap.put("desc",(String)busWithSelect.getSelectData(DomainConstants.SELECT_DESCRIPTION));
                              famSpecMap.put("state",i18nNow.getStateI18NString ((String)busWithSelect.getSelectData(DomainConstants.SELECT_POLICY),(String)busWithSelect.getSelectData(DomainConstants.SELECT_CURRENT ),languageStr));
                              famSpecMap.put("qty",(String)busWithSelect.getSelectData(DomainConstants.SELECT_ATTRIBUTE_QUANTITY));
                              famSpecMap.put("uom",famUOM);
                           
                      String famFilesize = "";
                      StringList famFilesizeList = new StringList();
                       try{
                         famFilesizeList = (StringList)busWithSelect.getSelectDataList(DomainConstants.SELECT_FILE_SIZE);
                       }catch(ClassCastException exp){
                         famFilesize = (String)busWithSelect.getSelectData(DomainConstants.SELECT_FILE_SIZE);
                       }
                          famSpecMap.put("size","");

                               //for each specifications get the attachments
                               DomainObject domainObj = DomainObject.newInstance(context);
                               domainObj.setId(famId);
                               String isVCDoc = domainObj.getInfo(context, com.matrixone.apps.common.CommonDocument.SELECT_IS_KIND_OF_VC_DOCUMENT);
                               if ((isVCDoc == null) || ("".equals(isVCDoc)) || ("null".equals(isVCDoc)))
                                 isVCDoc = "false";
                               StringList pversionSelectList = new StringList(3);
                               pversionSelectList.add(Document.SELECT_ID);
                               pversionSelectList.add(Document.SELECT_TITLE);
                               pversionSelectList.add(Document.SELECT_CHECKIN_REASON);
                               MapList pversionList = null;
                               String strVCIndex = "";
                               String strVCVersion = "";
                               
                               if (isVCDoc.equalsIgnoreCase("false"))
                               {
                                 pversionList = domainObj.getRelatedObjects(context,
                                                                            Document.RELATIONSHIP_ACTIVE_VERSION,
                                                                            Document.TYPE_DOCUMENTS,
                                                                            pversionSelectList,
                                                                            null,
                                                                            false,
                                                                            true,
                                                                            (short)1,
                                                                            null,
                                                                            null,
                                                                            null,
                                                                            null,
                                                                            null);
                                 fileList = domainObj.getAllFormatFiles(context);
								 if(fileList.size() < 1)
								   {
									 DomainObject domainObjwithFile = DomainObject.newInstance(context);

									 domainObjwithFile.setId(famId);
								   }
                                 strVCIndex = "0";
                                 strVCVersion = "0";
                               }
                               else
                               {
	                              String isVCFolder = domainObj.getInfo(context, "vcfolder");
	                              String vcSelect = "vcfile[1]";
	                              if (isVCFolder.equalsIgnoreCase("true"))
	                                vcSelect = "vcfolder[1]";
                                  pversionSelectList.add(vcSelect + ".vcname");
                                  pversionSelectList.add(vcSelect + ".format");
                                  pversionSelectList.add(vcSelect + ".versionid");
                                  pversionSelectList.add(vcSelect + ".index");
	                              Map vcMap = domainObj.getInfo(context, pversionSelectList);
                                  pversionList = new MapList();
                                  pversionList.add(vcMap);
                                  
                                  Map fileMap = new HashMap();
                                  fileMap.put("filename", (String)vcMap.get(vcSelect + ".vcname"));
                                  fileMap.put("format", (String)vcMap.get(vcSelect + ".format"));
                                  strVCIndex = (String)vcMap.get(vcSelect + ".index");
                                  strVCVersion = (String)vcMap.get(vcSelect + ".versionid");
                                  fileList.add(fileMap);
                               }

                               int k=0;

                               Map pversionMap ;
                               String ptitle ="";
                               String pfileDescription = null;

                               int fileSize = fileList.size();
                               if(fileSize > 0) {
                                  displaymapList.add(famSpecMap); //add spec obj info
                                  Iterator ipfile = fileList.iterator();
                                  while (ipfile.hasNext()) {
                                       Map pfileMap = (Map) ipfile.next();
                                       sFmtName   = (String)pfileMap.get(domainObj.KEY_FORMAT);
                                       sFileName    = (String)pfileMap.get(domainObj.KEY_FILENAME);
                                       Iterator pitr = pversionList.iterator();
                                       pfileDescription = "";
                                       while(pitr.hasNext()) {
                                           pversionMap = (Map)pitr.next();
                                           ptitle = (String)pversionMap.get(Document.SELECT_TITLE);
                                           if(sFileName.equals(ptitle)) {
                                               pfileDescription = (String)pversionMap.get(Document.SELECT_CHECKIN_REASON);
                                           }

                                       }
								


                     String tempParentFolder = parentPart;
					 String combFolderAdd=tempParentFolder+java.io.File.separator+famObj;

                                        if (combFolderAdd.indexOf("&")!=-1)
                                        {
                                       	 combFolderAdd = com.matrixone.jsystem.util.StringUtils.replaceAll(combFolderAdd,"&","@#%");
										 
                                        }
                      //SR00467691 : Holmatro:  DS Template Fix               
                    // checkBoxValue = combFolderAdd+"&"+ partId + "|" + famId +"&"+sFmtName  + "&" + sFileName + "&" + strVCIndex + "&versionid@" + strVCVersion;
						checkBoxValue = combFolderAdd+delimiter+ partId + "|" + famId +delimiter+sFmtName  + delimiter + sFileName + delimiter + strVCIndex + delimiter + "versionid@" + strVCVersion;

                                      target = " target=\"content\"";

                                      displayIcon = defaultTypeIcon;;
                                       //map to store file info
                                       HashMap famFileMap = new HashMap();
                                      famFileMap.put("checkbox",checkBoxValue);
                                      famFileMap.put("typeicon",defaultTypeIcon);
                                      famFileMap.put("nexturl",nextURL);
                                      famFileMap.put("id",famId);
                                      famFileMap.put("lvl",""+famLevel);
                                      famFileMap.put("name",sFileName);
                                      famFileMap.put("rev","");
                                      famFileMap.put("type","File");
                                      famFileMap.put("desc",pfileDescription);
                                      famFileMap.put("state"," ");
                                      famFileMap.put("qty"," ");
                                      famFileMap.put("uom"," ");
                                      if (fileSize == 1)
                                      {
                                         famFileMap.put("size",famFilesize);
                                      }
                                      else
                                      {
	                                      if (famFilesizeList.size() > k)
                                             famFileMap.put("size",famFilesizeList.elementAt(k));
                                       }

                                         //add obj info only if there are files attached
                                         displaymapList.add(famFileMap); //add file info
                                         k++;
                                  }
                            }
                      }
                }
            }
       String queryString = request.getQueryString();

     //Additional objects to be downloaded

       MapList mpLstLESSpecificObjects = new MapList();
       if(UIUtil.isNotNullAndNotEmpty(strDownloadProgram) && UIUtil.isNotNullAndNotEmpty(strDownloadMethod)){
    	   HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request,session,application);

    	   String field = (String)requestMap.get("fieldName");
   		   String timeStamp = (String)requestMap.get("timeStamp");
   		   String uiType = (String)requestMap.get("uiType");
   		   com.matrixone.apps.framework.ui.UITableIndented indentedTableBean = new UITableIndented();
   		   if("structureBrowser".equalsIgnoreCase(uiType) && UIUtil.isNotNullAndNotEmpty(field) && UIUtil.isNotNullAndNotEmpty(timeStamp)) {
      				MapList fields = indentedTableBean.getColumns(timeStamp);
   				if(fields!=null && fields.size()>0){
   					for (int i = 0; i < fields.size(); i++) {
   						Map fieldMap = (HashMap) fields.get(i);
   						if (fieldMap != null && field.equals(fieldMap.get("name"))){
   							requestMap.put("fieldMap",fieldMap);
   							break;
   						}
   					}
   				}
   			}
   		   mpLstLESSpecificObjects = (MapList)JPO.invoke(context, strDownloadProgram, null, strDownloadMethod, JPO.packArgs(requestMap), MapList.class);
if(mpLstLESSpecificObjects != null && !mpLstLESSpecificObjects.isEmpty())
   		{
   		for(int j=0;j<mpLstLESSpecificObjects.size();j++)   {
				Map<Object,Object> mpLESObject = (Map<Object,Object>)mpLstLESSpecificObjects.get(j);
    			if(displaymapList.contains(mpLESObject)==false)
				{
					displaymapList.add(mpLESObject);
				}
				
    		}
   		}
    	   }
    
       
//END - LES Addition

%>
<%
  String step1URL = "emxComponentsPackageReportDialogFS.jsp?objectId="+partId;

%>


<html>
<script language = "JavaScript">
var isDone = false;

<%
Enumeration paramEnum = emxGetParameterNames (request);
StringBuffer contentURL = new StringBuffer();
contentURL.append("emxComponentsPackageReportDialogFS.jsp?");
while (paramEnum.hasMoreElements()) {
	String parameter = (String)paramEnum.nextElement();
	String[] values = emxGetParameterValues(request, parameter);
	if( !(parameter.equals("level")) && !(parameter.equals("tokenalllevels")) && !(parameter.equals("bTeam")) )
	{
		contentURL.append(parameter).append("=").append(XSSUtil.encodeForJavaScript(context,values[0])).append("&");
	}
}
contentURL.append("prevmode=true");
%>
function prevMethod(){
	//XSSOK
      document.formPackageSummary.action="<%=contentURL%>";
      document.formPackageSummary.submit();
      return;
 }

 function validateForm(){

  }
function submit()
  {
    if (!isDone){
      if (validateForm()) {
          if (getTopWindow().getWindowOpener().getTopWindow().modalDialog) {
              getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
          }
          isDone = true;
          document.formPackageSummary.submit();
      }

    }
  }

function doneMethod()  {
    if (jsDblClick()) {
    	document.formPackageSummary.action="emxComponentsPackageTransferProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context,partId)%>";
        document.formPackageSummary.submit();
    } else {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Package.ZippingProcessMessage</emxUtil:i18nScript>");
    }
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<form name="formPackageSummary" method="post" target="_parent">
<table class="list">
   <fw:sortInit
        defaultSortKey="lvl"
        defaultSortType="string"
        resourceBundle="emxComponentsStringResource"
        mapList="<%= displaymapList %>"
        params="<%= queryString %>"
        ascendText="emxComponents.Common.SortAscending"
        descendText="emxComponents.Common.SortDescending" />
  <tr>
  <%
        if (!isPrinterFriendly) {
  %>
         <th><input type="checkbox" name="checkAll" onClick="allSelected('formPackageSummary',checkAll,document.formPackageSummary.checkAll.checked)" checked /></th>
<%
        }

%>

    <th nowrap="nowrap"><b><emxUtil:i18n localize="i18nId">emxComponents.Common.Level</emxUtil:i18n></b></th>
    <th nowrap="nowrap"><b><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></b></th>
    <th nowrap="nowrap"><b><emxUtil:i18n localize="i18nId">emxComponents.Common.Revision</emxUtil:i18n></b></th>
    <th nowrap="nowrap"><b><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n></b></th>
    <th nowrap="nowrap"><b><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></b></th>
    <th nowrap="nowrap"><b><emxUtil:i18n localize="i18nId">emxComponents.Common.State</emxUtil:i18n></b></th>
    <th nowrap="nowrap"><b><emxUtil:i18n localize="i18nId">emxComponents.Common.Quantity</emxUtil:i18n></b></th>
    <th nowrap="nowrap"><b><emxUtil:i18n localize="i18nId">emxComponents.Common.UOM</emxUtil:i18n></b></th>
    <th nowrap="nowrap"><b><emxUtil:i18n localize="i18nId">emxComponents.Common.FileSize</emxUtil:i18n></b></th>

  </tr>

  <fw:mapListItr mapList="<%= displaymapList %>" mapName="displaymap">

    <tr class='<fw:swap id="1"/>'>

     <%
      String checkBoxEnable = (String)displaymap.get("checkbox");
      String icondisplay = (String)displaymap.get("typeicon");
      String opennextURL = (String)displaymap.get("nexturl");
      String leveldisp = (String)displaymap.get("lvl");

      if (!isPrinterFriendly) {
        if(checkBoxEnable.equalsIgnoreCase("none")){   %>
           <td wrap="hard">&nbsp;<img src="../common/images/utilCheckOffDisabled.gif" alt=""/></td>
        <%  } else { %>
           <td> <input type="checkbox" name="checkBoxName" value="<xss:encodeForHTMLAttribute><%=checkBoxEnable%></xss:encodeForHTMLAttribute>" checked onclick="javascript:updateSelected('formPackageSummary')"/> </td>
        <%  } } %>

      <!--//XSSOK -->
	  <td><%= (String)displaymap.get("lvl")%></td>
<%
      if(currentUser.hasRole (context, PropertyUtil.getSchemaProperty(context,"role_SupplierRepresentative")) || currentUser.hasRole (context, PropertyUtil.getSchemaProperty(context,"role_SupplierQualityEngineer")) || currentUser.hasRole (context, PropertyUtil.getSchemaProperty(context,"role_SupplierEngineer")) ) {
%>
       <!--//XSSOK -->
	   <td><img src="../common/images/<%=icondisplay%>" border="0"/>&nbsp;<%= XSSUtil.encodeForHTML(context,(String)displaymap.get("name")) %></td>
<%
      } else {
%>
        <!--//XSSOK -->
		<td><b><a href="javascript:emxShowModalDialog('<%=opennextURL%>',700,600,false)"><img src="../common/images/<%=icondisplay%>" border="0"/>&nbsp;<%= XSSUtil.encodeForHTML(context,(String)displaymap.get("name")) %></a></td>
<%
      }
%>
      <!--//XSSOK -->
	  <td><%= XSSUtil.encodeForHTML(context,(String)displaymap.get("rev")) %>&nbsp;</td>
      <td><%= XSSUtil.encodeForHTML(context,i18nNow.getTypeI18NString((displaymap.get("type").toString()),languageStr)) %>&nbsp;</td>
      <!--//XSSOK -->
	  <td><%= XSSUtil.encodeForHTML(context,(String)displaymap.get("desc")) %>&nbsp;</td>
      <!--//XSSOK -->
	  <td><%= XSSUtil.encodeForHTML(context,(String)displaymap.get("state"))%>&nbsp;</td>
      <!--//XSSOK -->
	  <td><%= XSSUtil.encodeForHTML(context,(String)displaymap.get("qty")) %>&nbsp;</td>
      <!--//XSSOK -->
	  <td><%= XSSUtil.encodeForHTML(context,(String)displaymap.get("uom")) %>&nbsp;</td>
      <!--//XSSOK -->
	  <td><%= XSSUtil.encodeForHTML(context,(String)displaymap.get("size")) %>&nbsp;</td>

    </tr>

  </fw:mapListItr>

<%
      } catch(Exception e) {
%>
    <%@include file = "../common/emxNavigatorAbortTransaction.inc"%>
<%
    e.printStackTrace();
         System.out.println("abort transaction-"+e.toString());
      }
%>
  </table>
<%
      if (displaymapList.size() == 0){
             out.println(ComponentsUtil.i18nStringNow("emxComponents.PackageSummary.PartHasNoSpecs",request.getHeader("Accept-Language")));
      }
  }

%>
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=partId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="selectedlevel" value="<xss:encodeForHTMLAttribute><%=selectedlevelno%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="archiveName" value="<xss:encodeForHTMLAttribute><%=sArchiveName%></xss:encodeForHTMLAttribute>"/>
  <!--//XSSOK -->
  <input type="hidden" name="workspaceFolderId" value="<%=sWorkspaceFolderId%>"/>
  <input type="hidden" name="incBOMStructure" value="<xss:encodeForHTMLAttribute><%=incBOMStructure%></xss:encodeForHTMLAttribute>"/>


<%@include file = "emxComponentsCommitTransaction.inc"%>

</html>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "emxComponentsVisiblePageButtomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

