<%--  emxEngrBOMReplaceDailogFS.jsp   -  This page displays a list of parts.
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
   modified as part of ALSTOM - Redmine ticket 6893 - Replace Part in Bom doesn't keep quantity
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");

  // ----------------- Do Not Edit Above ------------------------------

  // Add Parameters Below
  String objectId = emxGetParameter(request,"objectId");
  String objectName = emxGetParameter(request,"objectName");
  String bomInfo = emxGetParameter(request,"bomInfo");
  String partFamilyContextId = emxGetParameter(request,"partFamilyContextId");
  String hideWithBOMSelection = emxGetParameter(request,"hideWithBOMSelection");
  if(partFamilyContextId == null)
	partFamilyContextId = objectId;
  String selPartRelId = emxGetParameter(request,"selPartRelId");
  String relType = emxGetParameter(request,"relType");
  String selPartObjectId = emxGetParameter(request,"selPartObjectId");
  String replaceWithExisting = emxGetParameter(request,"replaceWithExisting");
  String tablemode = emxGetParameter(request,"tablemode");
  
  // Added for Part Create conversion to common comp. R211
  String sRowId = emxGetParameter(request,"sRowId");
   
  if (replaceWithExisting==null || "null".equals(replaceWithExisting)) {
  replaceWithExisting = "";
  }
  
  if (selPartRelId==null || "null".equals(selPartRelId)) {
      selPartRelId = "";
  }
  if (selPartObjectId==null || "null".equals(selPartObjectId)) {
    selPartObjectId = partFamilyContextId;
  }
  
  String selPartParentOId = emxGetParameter(request,"selPartParentOId");
  if (selPartParentOId==null || "null".equals(selPartParentOId)) {
  selPartParentOId = partFamilyContextId;
  }
  String createdPartObjId = emxGetParameter(request,"createdPartObjId");
  String totalCount = emxGetParameter(request,"totalCount");
  if (totalCount==null || "null".equals(totalCount)) {
  totalCount = "";
  }
  // Specify URL to come in middle of frameset
  String contentURL = "AT_emxEngrBOMReplaceDailog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId + "&objectName=" + objectName + "&bomInfo=" + bomInfo;
  contentURL += "&partFamilyContextId=" + partFamilyContextId + "&selPartObjectId=" + selPartObjectId;
  contentURL += "&selPartParentOId=" + selPartParentOId + "&createdPartObjId=" + createdPartObjId;
  contentURL += "&selPartRelId="+selPartRelId+"&totalCount="+totalCount+"&replaceWithExisting="+replaceWithExisting+"&sRowId="+sRowId+"&relType="+relType+"&tablemode="+tablemode+"&hideWithBOMSelection="+hideWithBOMSelection;

  // Page Heading - Internationalized

  String PageHeading =null; 
  
  if("true".equals(replaceWithExisting))
  {

	PageHeading=  "emxEngineeringCentral.BOM.ReplaceWithExisting";

  }
  else
  {

	  PageHeading= "emxEngineeringCentral.Actions.ReplaceWithNew";

  }

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelppartbom";

  /*String roleList = "role_DesignEngineer," + "role_ManufacturingEngineer," + 
  "role_SeniorDesignEngineer," + "role_SeniorManufacturingEngineer";*/
  String roleList ="role_GlobalUser";


  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.setObjectId(objectId);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  fs.createFooterLink("emxFramework.Command.Done",
                      "doDone()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      0);

  fs.createFooterLink("emxFramework.Command.Cancel",
                      "parent.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>





