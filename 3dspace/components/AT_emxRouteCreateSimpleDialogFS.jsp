<%--  emxRouteCreateSimpleDialogFS.jsp   -   Create Frameset for Simple Route
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual
   or intended publication of such program

   static const char RCSID[] = $Id: emxRouteCreateSimpleDialogFS.jsp.rca 1.2.2.6 Wed Oct 22 16:17:53 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%

     String keyValue=emxGetParameter(request,"keyValue");
     String scopeId="All";
    if(keyValue == null){
       keyValue = formBean.newFormKey(session);
    }
     String firstTime=emxGetParameter(request,"init1");
     /*For the First time clear the Form Bean*/
     if(firstTime!=null && firstTime.equals("true"))
     {
            formBean.clear();
     }

    formBean.processForm(session,request,"keyValue");
    String routeInstructions="";
    String routeInitiateManner="";
    String routeAction="";
    String routeDueDate="";
    String routeMemberString="";
     if(firstTime==null)
    { 
    	routeInstructions = UIUtil.isNullOrEmpty(emxGetParameter(request,"routeInstructions")) ? "" : emxGetParameter(request,"routeInstructions");
    	routeInitiateManner= UIUtil.isNullOrEmpty(emxGetParameter(request,"routeInitiateManner"))?"":emxGetParameter(request,"routeInitiateManner");
    	routeAction= UIUtil.isNullOrEmpty(emxGetParameter(request,"routeAction"))?"":emxGetParameter(request,"routeAction");
    	routeDueDate= UIUtil.isNullOrEmpty(emxGetParameter(request,"routeDueDate"))?"":emxGetParameter(request,"routeDueDate");
    	routeMemberString= UIUtil.isNullOrEmpty(emxGetParameter(request,"routeMemberString"))?"":emxGetParameter(request,"routeMemberString");
    }
    
    String searchDocId=(String) formBean.getElementValue("ContentID");
    String  objectId      =  (String) formBean.getElementValue("objectId");
    String tableBeanName = "AT_emxRouteCreateSimpleDialogFS";
    framesetObject fs    = new framesetObject();
    String initSource = emxGetParameter(request,"initSource");
    if (initSource == null)
    {
       initSource = "";
    }
    String jsTreeID   =  emxGetParameter(request, "jsTreeID");
    String suiteKey   =  emxGetParameter(request, "suiteKey");
    String portalMode =  emxGetParameter(request, "portalMode");
    String supplierOrgId = emxGetParameter(request,"supplierOrgId");
    fs.setDirectory(appDirectory);

  // ----------------- Do Not Edit Above ------------------------------

    boolean bTeam = FrameworkUtil.isSuiteRegistered(context,
                                                  "featureVersionTeamCentral",
                                                  false,
                                                  null,
                                                  null);
    boolean bProgram = FrameworkUtil.isSuiteRegistered(context,
                                                     "appVersionProgramCentral",
                                                     false,
                                                     null,
                                                     null);

try
{
  //added for the bug 316267
  Person personObj=Person.getPerson(context);
  boolean boolHostCompanyEmployee=false;
  if((Company.getHostCompany(context)).equals(personObj.getCompanyId(context)))
      boolHostCompanyEmployee=true;
  //till here

    if(searchDocId==null || searchDocId.equals("null"))
    {
        searchDocId="";
    }
  //added for the bug 316267
  if(objectId!=null)
  {
  //till here
    DomainObject relatedObject=new DomainObject(objectId);

    StringList selects = new StringList(3);
    selects.add(DomainObject.SELECT_TYPE);
    selects.add(DomainConstants.SELECT_KINDOF_PROJECT_SPACE);
    selects.add(DomainConstants.SELECT_KINDOF_PROJECT_CONCEPT);
    
    Map infoMap = relatedObject.getInfo(context,selects);
    
    String isProjectSpace = (String)infoMap.get(DomainConstants.SELECT_KINDOF_PROJECT_SPACE);
    String isProjectConcept = (String)infoMap.get(DomainConstants.SELECT_KINDOF_PROJECT_CONCEPT);
    boolean isProjectSpaceOrConcept = "true".equalsIgnoreCase(isProjectSpace) || "true".equalsIgnoreCase(isProjectConcept);

    String curType=(String)infoMap.get(DomainObject.SELECT_TYPE);

    if( (!curType.equals(DomainConstants.TYPE_PROJECT)) &&
                  (!curType.equals(DomainObject.TYPE_PROJECT_VAULT)) &&
                             (!curType.equals(DomainObject.TYPE_INBOX_TASK)))
    {
            searchDocId+=objectId+"~";
    }
     if( (curType.equals(DomainObject.TYPE_WORKSPACE)) || isProjectSpaceOrConcept || (curType.equals(DomainObject.TYPE_WORKSPACE_VAULT)))//Modified to handle Sub Type
    {
            scopeId=objectId;
    }
  //added for the bug 316267
  else if(!boolHostCompanyEmployee)
  {
    scopeId="Organization";
  }
  }
  else if(!boolHostCompanyEmployee)
  {
    scopeId="Organization";
  }

  //Till here added for the bug 316267
}
catch(Exception e)
{
}

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(175);
  contentURL.append("AT_emxRouteCreateSimpleDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&beanName=");
  contentURL.append(tableBeanName);
  contentURL.append("&searchDocId=");
  contentURL.append(searchDocId);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&keyValue=");
  contentURL.append(keyValue);
  contentURL.append("&scopeId=");
  contentURL.append(scopeId);
  contentURL.append("&supplierOrgId=");
  contentURL.append(supplierOrgId);
  contentURL.append("&routeInstructions=");
  contentURL.append(routeInstructions);
  contentURL.append("&routeInitiateManner=");
  contentURL.append(routeInitiateManner);
  contentURL.append("&routeAction=");
  contentURL.append(routeAction);
  contentURL.append("&routeDueDate=");
  contentURL.append(routeDueDate);
  contentURL.append("&routeMemberString=");
  contentURL.append(routeMemberString);

  fs.setBeanName(tableBeanName);
  fs.setStringResourceFile("emxComponentsStringResource");

  // Page Heading - Internationalized
  String PageHeading = "emxComponents.CreateSimpleRouteDialog.CreateSimple";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside

  String HelpMarker = "emxhelpcreatesimpleroute";

  fs.initFrameset(PageHeading,
                  HelpMarker,
                  contentURL.toString(),
                  false,
                  true,
                  false,
                  false);

  fs.createCommonLink("emxComponents.Common.AddContent",
                      "AddContent()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      true,3);


  fs.createCommonLink("emxComponents.Button.RemoveSelected",
                      "removeSelectedContent()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      false,3);


   // show Upload only if TeamCentral or ProgramCentral is installed


   fs.createFooterLink("emxComponents.Button.Done",
                       "submitForm()",
                       "role_GlobalUser",
                       false,
                       true,
                       "common/images/buttonDialogDone.gif",
                       3);

   fs.createFooterLink("emxComponents.Button.Cancel",
                       "closeWindow()",
                       "role_GlobalUser",
                       false,
                       true,
                       "common/images/buttonDialogCancel.gif",
                       3);

  // ----------------- Do Not Edit Below ------------------------------

   fs.writePage(out);

%>
