<%--  emxCommonDocumentCreateDialog.jsp
    Copyright (c) 1992-2015 Dassault Systemes.
    All Rights Reserved  This program contains proprietary and trade secret
    information of MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

    Description : Document Create Wizard, Step 1

    static const char RCSID[] = "$Id: emxCommonDocumentCreateDialog.jsp.rca 1.41.2.1 Tue Dec 23 05:40:19 2008 ds-hkarthikeyan Experimental $";
--%>

<%
  // This is added because adding emxUICommonHeaderEndInclude.inc add
  request.setAttribute("warn", "false");
%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>  

<script language="javascript">
	function chooseOwner_onclick() {
		var objCommonAutonomySearch = new emxCommonAutonomySearch();
		
		objCommonAutonomySearch.txtType = "type_Person";
		objCommonAutonomySearch.selection = "single";
		objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitSelectedOwner"; 
					
		objCommonAutonomySearch.open();
	}
	
	function submitSelectedOwner (arrSelectedObjects) {
	    for (var i = 0; i < arrSelectedObjects.length; i++) {
	        var objSelection = arrSelectedObjects[i];
	        if (document.forms[0].person) {
	        	document.forms[0].person.value = objSelection.name;
	        }
	        break;
	    }
	}
	
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%

  Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");

  if(emxCommonDocumentCheckinData == null)
  {
    emxCommonDocumentCheckinData = new HashMap();
  }

  String objectId = emxGetParameter(request,"parentId");
  Enumeration enumParam = request.getParameterNames();

  // Loop through the request elements and
  // stuff into emxCommonDocumentCheckinData
  while (enumParam.hasMoreElements())
  {
    String name  = (String) enumParam.nextElement();
    String value = emxGetParameter(request,name);
    emxCommonDocumentCheckinData.put(name, value);
  }

  // retrive previously entered values, if any, which are stored in FormBean
  String documentName        = (String) emxCommonDocumentCheckinData.get("name");
  String documentAutoName    = (String) emxCommonDocumentCheckinData.get("AutoName");
  String documentType        = (String) emxCommonDocumentCheckinData.get("documentType");
  String documentPolicy      = (String) emxCommonDocumentCheckinData.get("policy");
  String documentRevision    = (String) emxCommonDocumentCheckinData.get("revision");
  String documentTitle       = (String) emxCommonDocumentCheckinData.get("title");
  
  //QC4583 - Inherit Part Title to Doc - Start
  if(UIUtil.isNullOrEmpty(documentTitle)){
	  if(UIUtil.isNotNullAndNotEmpty(objectId)){
		  DomainObject partObject = DomainObject.newInstance(context, objectId);
		  documentTitle = partObject.getInfo(context, "attribute["+PropertyUtil.getSchemaProperty(context, "attribute_V_Name")+"]");
	  }
  }
//QC4583 - Inherit Part Title to Doc - End
  
  String documentDescription = (String) emxCommonDocumentCheckinData.get("description");
  String documentOwner       = (String) emxCommonDocumentCheckinData.get("person");
  String documentAccessType  = (String) emxCommonDocumentCheckinData.get("AccessType");
  // Bug 301712 fix - previously entered folder name is not retained.
  String wsFolder            = (String) emxCommonDocumentCheckinData.get("txtWSFolder");
  String wsFolderId          = (String) emxCommonDocumentCheckinData.get("folderId");

  //  Reading request parameters and storing into variables
  String showName            = (String) emxCommonDocumentCheckinData.get("showName");
  String showDescription     = (String) emxCommonDocumentCheckinData.get("showDescription");
  String showTitle           = (String) emxCommonDocumentCheckinData.get("showTitle");
  String showOwner           = (String) emxCommonDocumentCheckinData.get("showOwner");
  String showType            = (String) emxCommonDocumentCheckinData.get("showType");
  // added for the Bug 344426
  String showTypeChooser     = (String) emxCommonDocumentCheckinData.get("typeChooser");
  String showPolicy          = (String) emxCommonDocumentCheckinData.get("showPolicy");
  String showAccessType      = (String) emxCommonDocumentCheckinData.get("showAccessType");
  String showRevision        = (String) emxCommonDocumentCheckinData.get("showRevision");
  String showFolder          = (String) emxCommonDocumentCheckinData.get("showFolder");
  String folderURL           = (String) emxCommonDocumentCheckinData.get("folderURL");
  String defaultType         = (String) emxCommonDocumentCheckinData.get("defaultType");
  String reloadPage          = (String) emxCommonDocumentCheckinData.get("reloadPage");
  String typeChanged         = (String) emxCommonDocumentCheckinData.get("typeChanged");
  String objectAction = (String) emxCommonDocumentCheckinData.get("objectAction");
  String disableFileFolder   = "false";

  String path = (String)emxCommonDocumentCheckinData.get("path");
  String vcDocumentType = (String)emxCommonDocumentCheckinData.get("vcDocumentType");
  String selector = (String)emxCommonDocumentCheckinData.get("selector");
  String server = (String)emxCommonDocumentCheckinData.get("server");
  String defaultFormat = (String)emxCommonDocumentCheckinData.get("format");
  String populateDefaults = (String)emxCommonDocumentCheckinData.get("populateDefaults");
  String showFormat = (String) emxCommonDocumentCheckinData.get("showFormat");
  String fromPage = (String)emxCommonDocumentCheckinData.get("fromPage");

  // Bug 303724 fix, list of coma delimited symbolic type names only included in type chooser
  String includeTypes        = (String) emxCommonDocumentCheckinData.get("includeTypes");

  // Bug 303724 fix, list of coma delimited symbolic policy names to be excluded being displayed in policy list
  String excludePolicies     = (String) emxCommonDocumentCheckinData.get("excludePolicies");
  // added for the Bug 344426
  //  Validating the request parameter values and setting to defaults
  //  if showTypeChooser is not passed from the command setting the value to true
  if (showTypeChooser == null || "".equals(showTypeChooser) || "null".equals(showTypeChooser) || "true".equalsIgnoreCase(showTypeChooser))
  {
      showTypeChooser = "true";
  }
  //  Validating the request parameter values and setting to defaults
  //  if not defined in request
  //  Description, Title are set true if null
  if (showName == null || "".equals(showName) || "null".equals(showName) || "true".equalsIgnoreCase(showName))
  {
      showName = "required";
  }

  if (showDescription == null || showDescription.equals("") )
  {
      showDescription = "true";
  }

  if (showTitle == null || showTitle.equals("") )
  {
      showTitle = "true";
  }

  // all other parameters are set to false if null
  if (showOwner == null || showOwner.equals("") )
  {
      showOwner = "false";
  }

  if (showType == null || showType.equals("") )
  {
      showType = "false";
  }

  if (showPolicy == null || showPolicy.equals("") )
  {
      showPolicy = "required";
  }

  if( objectAction.equals(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER))
  {
      showPolicy = "required";
      disableFileFolder = "true";
  }

  if (showAccessType == null || showAccessType.equals("") )
  {
      showAccessType = "false";
  }

  if (showRevision == null || showRevision.equals("") )
  {
      showRevision = "false";
  }

  if (showFolder == null || showFolder.equals("") )
  {
        showFolder = "false";
  }

  if( documentName == null || documentName.equals("null"))
  {
      documentName = "";
  }

  if( documentAutoName == null || documentAutoName.equals("null"))
  {
      documentAutoName = "";
  }

  if(reloadPage != null && "true".equals(reloadPage))
  {
      documentType = (String) emxCommonDocumentCheckinData.get("realType");
      BusinessType docType = new BusinessType(documentType, context.getVault());
      StringList parents = docType.getParents(context);
      if ((parents.contains(DomainObject.TYPE_IC_DOCUMENT)) || (documentType.equals(DomainObject.TYPE_IC_DOCUMENT)))
        vcDocumentType = "File";
      else if ((parents.contains(DomainObject.TYPE_IC_FOLDER)) || (documentType.equals(DomainObject.TYPE_IC_FOLDER)))
        vcDocumentType = "Folder";
  }

  // Bug 301712 fix - previously entered folder name is not retained.
  if (wsFolder == null || "".equals(wsFolder) || "null".equals(wsFolder))
  {
      wsFolder="";
  }

  // Bug 301712 fix - previously entered folder name is not retained.
  if (wsFolderId == null || "".equals(wsFolderId) || "null".equals(wsFolderId))
  {
      wsFolderId="";
  }


  // Bug 303724 fix, prepare string list of excluded policies
  StringList listExcludePolicies = new StringList();
  if( excludePolicies != null && !"null".equals(excludePolicies) && !"".equals(excludePolicies.trim()))
  {
      StringList listSymExcludePolicies = FrameworkUtil.split(excludePolicies, ",");
      Iterator itr = listSymExcludePolicies.iterator();
      while(itr.hasNext())
      {
        // get the aboslute policy name
        listExcludePolicies.add(PropertyUtil.getSchemaProperty(context, (String)itr.next()));
      }
  }

  boolean bTypeChanged = false;
  if(typeChanged != null && "true".equals(typeChanged))
  {
    bTypeChanged = true;
    //defaultType = FrameworkUtil.getAliasForAdmin(context, "type", documentType, true);
    //Above statement is commented to fix 371838. 
    //When type is changed through Type chooser, should not change 'defaultType' value.
  }

  // default to defaultType, first time
  if( documentType == null || documentType.equals("null"))
  {
    if( defaultType != null)
    {
      try
      {
        documentType = PropertyUtil.getSchemaProperty(context, defaultType);
      }
      catch (Exception exp)
      {
        // if there is any error default to "Document" type
        documentType = PropertyUtil.getSchemaProperty(context, "type_AT_C_DOCUMENT");
      }
    }
    else
    {
        documentType = PropertyUtil.getSchemaProperty(context, "type_AT_C_DOCUMENT");
    }
  }
  String actualType  = PropertyUtil.getSchemaProperty(context, documentType);
  documentType       = !com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(actualType)?actualType:documentType;
  BusinessType bType = new BusinessType(documentType, context.getVault());
  boolean isAbstract = bType.isAbstract(context);

  // type chooser needs Symbolic name to pass,
  // if no default type passed then the type chooser displayes the subtypes of type DOCUMENTS
  String symbolicDocumentType = "";
  if( defaultType != null)
  {
    symbolicDocumentType = FrameworkUtil.getAliasForAdmin(context, "type", PropertyUtil.getSchemaProperty(context,defaultType), true);
  }
  else
  {
    symbolicDocumentType = FrameworkUtil.getAliasForAdmin(context, "type", PropertyUtil.getSchemaProperty(context, "type_DOCUMENTS"), true);
  }

  if( documentPolicy == null || "null".equals(documentPolicy) || "".equals(documentPolicy) || bTypeChanged)
  {
      // If no policy passed then read the default policy (symbolic name) defined for the current type
      // in properties
      try
      {
        documentPolicy = EnoviaResourceBundle.getProperty(context,"emxComponents.DefaultPolicy." + symbolicDocumentType);

        if( documentPolicy != null && !"".equals(documentPolicy.trim()))
        {
          documentPolicy = PropertyUtil.getSchemaProperty(context, documentPolicy);
        }
        else
        {
          documentPolicy = null;
        }
      }
      catch (Exception e)
      {
        documentPolicy = null;
      }
  }

  // Bug 303724 fix
  // if Inclusion list is not passed then include DOCUMENTS type by default
  if( includeTypes == null || includeTypes.equals("null") || "".equals(includeTypes.trim()))
  {
      includeTypes = symbolicDocumentType;
  }

  String sAllowChangePolicy   = EnoviaResourceBundle.getProperty(context,"emxComponents.AllowChangePolicy");
  boolean bAllowChangePolicy  = true;
  if(sAllowChangePolicy != null && "false".equalsIgnoreCase(sAllowChangePolicy))
  {
    bAllowChangePolicy =  false;
  }

  MapList documentPolicies         = mxType.getPolicies( context, documentType, false);
  Map defaultDocumentPolicyMap     = null;
  Map documentPolicyMap            = new HashMap();
  String defaultDocumentPolicyName = null;
  StringList documentPolicyNames   = new StringList();
  Iterator documentPolicyItr       = null;
  String policyName = null;

  if ( documentPolicies != null && !documentPolicies.isEmpty())
  {
      documentPolicyItr = documentPolicies.iterator();
      while( documentPolicyItr.hasNext())
      {
        documentPolicyMap = (Map)documentPolicyItr.next();
        policyName        = (String)documentPolicyMap.get("name");

        if(!listExcludePolicies.contains(policyName))
           documentPolicyNames.add(policyName);
        else
           documentPolicyItr.remove();

        if(documentPolicy == null)
        {
          defaultDocumentPolicyMap = (Map) documentPolicies.get(0);
        }
        else if (policyName.equals(documentPolicy))
        {
          defaultDocumentPolicyMap = documentPolicyMap;
        }
      }

      if(defaultDocumentPolicyMap == null)
      {
        defaultDocumentPolicyMap = (Map) documentPolicies.get(0);
      }

      defaultDocumentPolicyName = (String)defaultDocumentPolicyMap.get("name");

      documentRevision = (String)defaultDocumentPolicyMap.get("revision");
  }
  if( documentPolicy != null && !"".equals(documentPolicy))
  {
      defaultDocumentPolicyName = documentPolicy;
  }

  String states = MqlUtil.mqlCommand(context, "print policy $1 select $2 dump $3", defaultDocumentPolicyName,"state","|");
  StringList stateList = FrameworkUtil.split(states, "|");

  String txtLable = "label";
%>
<script language="javascript">

  // function to close the window and refresh the parent window.
  function closeWindow()
  {
    window.location.href = "emxCommonDocumentCancelCreateProcess.jsp";
  }

  // function to truncate the blank values.
  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }

<%
  if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ON_DEMAND))
    {
%>
  function onFileFolderSelect(folderObject){
<%
   if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ON_DEMAND)){
%>
    if(folderObject.value == "Folder"){
       document.frmMain.vcDocumentType.value = "Folder";
    }
    else if(folderObject.value == "Module")
    {
      
        document.frmMain.vcDocumentType.value = "Module";
        
    }
    else {
       document.frmMain.vcDocumentType.value = "File";
    }
<% } else
    {
%>
    if(folderObject.value == "Folder"){
       document.frmMain.format.disabled= true;
       document.frmMain.vcDocumentType.value = "Folder";
       document.frmMain.selector.value = "Trunk:Latest";
    }
    else if(folderObject.value == "Module") 
    {
    	document.frmMain.format.disabled = true;
    	document.frmMain.vcDocumentType.value = "Module";
    	 //DSFA added for selector change Nov 13 2008
       document.frmMain.selector.value = "DSFA:Latest";
    }
    else { 
    	document.frmMain.vcDocumentType.value = "File"; 
    	document.frmMain.format.disabled= false;   
    	 //DSFA added for selector change Nov 13 2008
       document.frmMain.selector.value = "Trunk:Latest"; 
    	}
<%} %>
  }
<%
    }
 %>

  function submitForm()
  {
	 //QC 4313 - PLMV6_[eBom] REQ11.001_TC01_03 create doc on LN - START 
     if ( document.frmMain.AT_C_Doc_Type.value == "") {
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.InValidAT_C_Doc_Type</emxUtil:i18nScript>");
 	    return;
      }
	 //QC 4313 - PLMV6_[eBom] REQ11.001_TC01_03 create doc on LN - END
<%
     if ( isAbstract )
     {
%>
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.InValidType</emxUtil:i18nScript>");
        return;
<%
     }

    if((showName.equalsIgnoreCase("required")) || (showName.equalsIgnoreCase("true")))
    {
%>
      var checkedAutoname = false;
     // var namebadCharName = checkForNameBadCharsList(document.frmMain.name);
      //if (namebadCharName.length != 0)
      var namebadCharName = checkForUnifiedNameBadChars(document.frmMain.name,true);
      if (namebadCharName.length != 0)      
      {
      	var nameAllBadCharName = getAllNameBadChars(document.frmMain.name);
      	var name = document.frmMain.name.name;
      	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInvalidInput</emxUtil:i18nScript>"+nameAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript> "+name+" <emxUtil:i18nScript localize="i18nId">emxComponents.Alert.Field</emxUtil:i18nScript>");
		//alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
        document.frmMain.name.focus();
        return;
      }
      else if (!document.frmMain.AutoName.checked )
      {
        if(document.frmMain.name.value == "")
        {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.EnterDocumentName</emxUtil:i18nScript>");
          document.frmMain.name.focus();
          return;
        }
        else if(!(isValidLength(trim(document.frmMain.name.value), 1,128)))
        {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.ValidateLength</emxUtil:i18nScript>");
          document.frmMain.name.value = trim(document.frmMain.name.value);
          document.frmMain.name.focus();
          return;
        }
        else if ( !(isAlphanumeric(trim(document.frmMain.name.value), true)) || trim(document.frmMain.name.value) == "")
        {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidName</emxUtil:i18nScript>");
          document.frmMain.name.focus();
          return;
        }
        document.frmMain.name.value = trim(document.frmMain.name.value);
      }
<%
    }

    if ( showType.equalsIgnoreCase("required") )
    {
%>
      if ( document.frmMain.type.value == "" ) {
        document.frmMain.type.focus();
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.TypeError</emxUtil:i18nScript>");
        return;
      }
<%
    }

    if ( showPolicy.equalsIgnoreCase("required") )
    {
%>
      if ( document.frmMain.policy.value == "" ) {
        document.frmMain.policy.focus();
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.PolicyError</emxUtil:i18nScript>");
        return;
      }
<%
    }

    if ( showRevision.equalsIgnoreCase("required") )
    {
%>
      if ( document.frmMain.revision.value == "" ) {
        document.frmMain.revision.focus();
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.RevisionError</emxUtil:i18nScript>");
        return;
      }
<%
    }

    if ( showDescription.equalsIgnoreCase("required") )
    {
%>
      if ( document.frmMain.description.value == "" )
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.FillDescription</emxUtil:i18nScript>");
        document.frmMain.description.focus();
        return;
      }
<%
    }

    if ( showOwner.equalsIgnoreCase("required") )
    {
%>
      if (trim(document.frmMain.person.value) == "")
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.OwnerError</emxUtil:i18nScript>");
        document.frmMain.person.focus();
        return;
      }
<%
    }

    if ( showTitle.equalsIgnoreCase("required") )
    {
%>
      if ( document.frmMain.title.value == "" ) {
        document.frmMain.title.focus();
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.TitleError</emxUtil:i18nScript>");
        return;
      }
<%
    }

    if ( showTitle.equalsIgnoreCase("true")  ||  showTitle.equalsIgnoreCase("required") )
    {
%>
      var titleBadCharName = checkForNameBadChars(document.frmMain.title,true);
      if (titleBadCharName.length != 0)
      {
      	//var titleAllBadCharName = getAllBadChars(document.frmMain.title);
        var nameAllBadCharName = getAllNameBadChars(document.frmMain.title);
      	var name = document.frmMain.title.name;
      	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+titleBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInvalidInput</emxUtil:i18nScript>"+nameAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript> "+name+" <emxUtil:i18nScript localize="i18nId">emxComponents.Alert.Field</emxUtil:i18nScript>");
        document.frmMain.title.focus();
        return;
      }
<%
    }

    if ( showDescription.equalsIgnoreCase("true") || showDescription.equalsIgnoreCase("required") )
    {
%>
      var descriptionBadCharName = checkForBadChars(document.frmMain.description);      
      if (descriptionBadCharName.length != 0)
      {
      	var descriptionAllBadCharName = getAllBadChars(document.frmMain.description);
      	
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+descriptionBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInvalidInput</emxUtil:i18nScript>"+descriptionAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
        document.frmMain.description.focus();
        return;
      }
<%
    }

    if ( showAccessType.equalsIgnoreCase("required") )
    {
%>
      if ( document.frmMain.AccessType.value == "" ) {
        document.frmMain.AccessType.focus();
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AccessTypeError</emxUtil:i18nScript>");
        return;
      }
<%
    }

    if ( showFolder.equalsIgnoreCase("required") )
    {
%>
      if ( document.frmMain.txtWSFolder.value == "" ) {
        document.frmMain.txtWSFolder.focus();
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Checkin.SelectFolder</emxUtil:i18nScript>");
        return;
      }
<%
    }
%>
    j = 0;
    for ( var i = 0; i < document.frmMain.elements.length; i++ ) {
        j = document.frmMain.elements[i].name.length;
        k = j - 6;
        if (document.frmMain.elements[i].type == "hidden" && document.frmMain.elements[i].name.substring(k,j) == "Number"  ){

            j = i;
            j--;
            if ( !isNumeric(document.frmMain.elements[j].value) )
            {
                alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.PleaseTypeNumbers</emxUtil:i18nScript>" + document.frmMain.elements[j].name);
                document.frmMain.elements[j].focus();
                return;
            }
        }
        // Trim leading and trailing white spaces from title field - 353717
		else if ( document.frmMain.elements[i].type == "text" && document.frmMain.elements[i].name == "title" )
		{
		document.frmMain.elements[i].value = trim(document.frmMain.elements[i].value);
		}
<%
  if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ) )
    {
%>
        if ((document.frmMain.elements[i].type == "radio") && (document.frmMain.elements[i].name=="vcDocumentTmp") && (document.frmMain.elements[i].checked)){
          if(document.frmMain.elements[i].value == "Folder"){
            var path = document.frmMain.path.value;
            path = path.substring(path.length-1, path.length);
            if (path == ";")
            {
               alert("<emxUtil:i18n localize = "i18nId">emxComponents.CommonDocument.FolderPathError</emxUtil:i18n>");
               return;
            }
          }
<%
         if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) || objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER)) {
%>
            if(document.frmMain.elements[i].value == "File") {
                var path = document.frmMain.path.value;
                path = path.substring(path.length-1, path.length);
                if (path == "/")
                {
                   alert("<emxUtil:i18n localize = "i18nId">emxComponents.CommonDocument.FilePathError</emxUtil:i18n>");
                   return;
                }
            }
            if(document.frmMain.elements[i].value == "Module")
            {
            	var path = document.frmMain.path.value;
            	path = "ModuleName";
            	if(path == "")
            	{
            		alert("<emxUtil:i18n localize = "i18nId">emxComponents.CommonDocument.FilePathError</emxUtil:i18n>");
            	}
            }
<%
        }
%>
        }
<%
    }
%>
<%
    if (objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER))
    {
%>
       var path = document.frmMain.path.value;
       var server = document.frmMain.server.value;
       if(path.length <= 0 || path==" ")
       {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.PathEmpty</emxUtil:i18nScript>");
          return;
       }
      
       
       	if(path=="Modules/" || path=="Modules")
       	{
        	  alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.ModulePathInvalid</emxUtil:i18nScript>");
         	  return;
       	}
       

<%
    }
    if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
          objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
          objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
          objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
          objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ) )
    {
        String emxFilePathBadChars = EnoviaResourceBundle.getProperty(context,"emxComponents.VCFile.PathBadChars");
        String emxFolderPathBadChars = EnoviaResourceBundle.getProperty(context,"emxComponents.VCFolder.PathBadChars");
        String emxSelectorBadChars = EnoviaResourceBundle.getProperty(context,"emxComponents.VCFileFolder.SelectorBadChars");
%>
       if(document.frmMain.elements[i].name== "path"){
         var FILE_CHARS = "<%= emxFilePathBadChars.trim() %>";
         var FOLDER_CHARS = "<%= emxFolderPathBadChars.trim() %>";
         var STR_PATH_BAD_CHARS = "";
         if(document.frmMain.vcDocumentTmp[1].checked){
           STR_PATH_BAD_CHARS = FOLDER_CHARS;
         }
         else{
           STR_PATH_BAD_CHARS = FILE_CHARS;
         }
         var ARR_PATH_BAD_CHARS = "";
         if (STR_PATH_BAD_CHARS != "")
         {
          ARR_PATH_BAD_CHARS = STR_PATH_BAD_CHARS.split(" ");
         }
         var strResult = checkFieldForChars(document.frmMain.path,ARR_PATH_BAD_CHARS,false);
         if (strResult.length > 0) {
           //XSSOK	 
           var msg = "<%= i18nNow.getI18nString("emxComponents.Alert.InvalidChars","emxComponentsStringResource",request.getHeader("Accept-Language")) %>";
           msg += STR_PATH_BAD_CHARS;
         //XSSOK
           msg += "<%= i18nNow.getI18nString("emxComponents.Alert.RemoveInvalidChars", "emxComponentsStringResource",request.getHeader("Accept-Language")) %> ";
           msg += document.frmMain.path.name;
           alert(msg);
           document.frmMain.path.focus();
           return;
         }
       }
       if(document.frmMain.elements[i].name== "selector"){
         var selector = document.frmMain.selector.value;
         if(selector.length <= 0)
         {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.SelectorEmpty</emxUtil:i18nScript>");
            return;
         }
         var STR_SELECTOR_BAD_CHARS = "<%= emxSelectorBadChars.trim() %>";
         var ARR_SELECTOR_BAD_CHARS = "";
         if (STR_SELECTOR_BAD_CHARS != "")
         {
           ARR_SELECTOR_BAD_CHARS = STR_SELECTOR_BAD_CHARS.split(" ");
         }
         var strSelectorResult = checkFieldForChars(document.frmMain.selector,ARR_SELECTOR_BAD_CHARS,false);
         if (strSelectorResult.length > 0) {
           alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.InvalidChars</emxUtil:i18nScript>\n"
                 + STR_SELECTOR_BAD_CHARS + "\n<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.RemoveInvalidChars</emxUtil:i18nScript>\n"
                 +document.frmMain.selector.name);
          document.frmMain.selector.focus();
          return;
        }
      }
<%
    }
%>
    }

    // Make sure user doesnt double clicks on create document
    if (jsDblClick())
    {
      startProgressBar(false);
      document.frmMain.submit();
      return;
    }
  }

<%
     String excludeTypes = EnoviaResourceBundle.getProperty(context, "emxComponents.CreateDocument.ExcludeTypeList");
%>
  function showTypeSelector()
  {
    document.frmMain.typeChanged.value="true";
    var strURL="../common/emxTypeChooser.jsp?fieldNameDisplay=type&fieldNameActual=realType&formName=frmMain&ShowIcons=true&InclusionList=<%=XSSUtil.encodeForURL(context, includeTypes)%>&ExclusionList=<%=excludeTypes%>&ObserveHidden=true&SelectType=singleselect&ReloadOpener=true";
    var win = showModalDialog(strURL, 450, 500, true);
  }

  // this function is called by type chooser, everytime a type is selected
  // this reloads the page, and populates the policy chooser correctly
  function reload() {
      document.frmMain.target="";
      document.frmMain.action="../components/AT_emxCommonDocumentCreateDialog.jsp?reloadPage=true&contentPageIsDialog=true";
      document.frmMain.submit();
  }

  //function  to move the focus from AutoName to Name, when AutoName checkBox is Unchecked.
  function txtNameFocus()
  {
    if(!document.frmMain.AutoName.checked )
    {
      document.frmMain.AutoName.value = "";
      document.frmMain.name.focus();
    }
    else
    {
      autoNameValue();
    }
    return;
  }

  function autoNameValue()
  {
    if(document.frmMain.AutoName.checked )
    {
      document.frmMain.name.value = "";
      document.frmMain.AutoName.value = "checked";
      document.frmMain.AutoName.focus();
    }
    return;
  }

  function  folderlist() {
    emxShowModalDialog("../common/emxIndentedTable.jsp?expandProgram=emxWorkspace:getWorkspaceVaults&table=TMCSelectFolder&program=emxWorkspace:getDisabledWorkspaces&displayView=details&header=emxFramework.IconMail.Common.SelectOneFolder&submitURL=../components/emxCommonSelectWorkspaceFolderProcess.jsp&cancelLabel=emxFramework.Button.Cancel&submitLabel=emxFramework.FormComponent.Done",575,575);
  }

  </script>
<%
  String actionURL = (String) emxCommonDocumentCheckinData.get("actionURL");
  if (actionURL == null )
  {
      actionURL = "AT_emxCommonDocumentCheckinDialogFS.jsp";
  }
  String requiredText = ComponentsUtil.i18nStringNow("emxComponents.Commom.RequiredText",request.getHeader("Accept-Language"));

%>
<form name="frmMain" method="post" action="<%= XSSUtil.encodeForHTML(context, actionURL) %>" target="_parent" onsubmit="submitForm(); return false">
  <input type="hidden" name="folderId" value="<xss:encodeForHTMLAttribute><%=wsFolderId%></xss:encodeForHTMLAttribute>"/>

<table>
  <tr>     
    <!-- //XSSOK -->  
    <td class="requiredNotice"><%=requiredText%></td>
  </tr>
</table>
   <table>
<%
  // Start of display of Name depending on the parametes passed in
  // If showName parameter came as required it will display with labelrequired
  // If showName parameter came as null or true, description field will be displayed as optional
  // If showName parameter came as false, description field will NOT be displayed
  txtLable = "label";
  if ( showName.equalsIgnoreCase("true") || showName.equalsIgnoreCase("required") )
  {
     if ( showName.equalsIgnoreCase("required") )
     {
         txtLable = "labelRequired";
     }
%>
  <tr>
  <!--//XSSOK-->
    <td class="<%=txtLable%>">
      <emxUtil:i18n localize="i18nId">ATemxComponents.Common.Name</emxUtil:i18n>
    </td>

    <td class="inputField">
<%
     if("".equals(documentName))
     {
%>
        <input type="text" name="name" size="20" disabled="disabled" onfocus="autoNameValue()" onkeypress="autoNameValue()" onclick="autoNameValue()" onselect="autoNameValue()" onkeydown="autoNameValue()" onchange="autoNameValue()" value="<xss:encodeForHTMLAttribute><%=documentName%></xss:encodeForHTMLAttribute>"/>
        <input type="checkbox" name="AutoName" disabled="disabled" value="<xss:encodeForHTMLAttribute><%=documentAutoName%></xss:encodeForHTMLAttribute>" onClick="txtNameFocus()" checked />&nbsp;
        <emxUtil:i18n localize="i18nId">emxComponents.Common.AutoName</emxUtil:i18n>
<%
      } else {
%>
        <input type="text" name="name" size="20" disabled="disabled" value="<xss:encodeForHTMLAttribute><%=documentName%></xss:encodeForHTMLAttribute>"   onFocus="autoNameValue()" onKeyPress="autoNameValue()" onClick="autoNameValue()" onSelect="autoNameValue()" onKeyDown="autoNameValue()" onChange="autoNameValue()"/>
        <input type="checkbox" name="AutoName" disabled="disabled" value="<xss:encodeForHTMLAttribute><%=documentAutoName%></xss:encodeForHTMLAttribute>" onClick="txtNameFocus()"/>&nbsp;
        <emxUtil:i18n localize="i18nId">emxComponents.Common.AutoName</emxUtil:i18n>
<%
      }
%>
      </td>
    </tr>
<%
  }
  //added for the Bug 344426
  txtLable = "label";
  if (!showTypeChooser.equalsIgnoreCase("false") )
  {
    txtLable = "labelRequired";
  }
%>

<!-- Displayed only if the current type != AT_C_DOCUMENT  -->
<%
if( ! "AT_C_DOCUMENT".equals(documentType) )
{ 
%>
    <tr><!--//XSSOK-->
      <td class = "<%=txtLable%>" >
        <emxUtil:i18n localize = "i18nId">emxComponents.Common.Type</emxUtil:i18n>
      </td>
      <td class = "inputField" >
<%
        // added for the Bug 344426
        if( "false".equalsIgnoreCase(showTypeChooser))
        {
			String strDefaultDocType = documentType == null ? i18nNow.getTypeI18NString("Document",sLanguage) : i18nNow.getTypeI18NString(documentType,sLanguage);
%>
 		<!-- //XSSOK -->
        <%=  strDefaultDocType %>
		<!-- //XSSOK -->
		<input type="hidden" name="type" size="20" readonly value="<%=strDefaultDocType%>"/>
<%
        }
        else
        {
%>
          <!-- //XSSOK -->
          <input type="text" name="type" value="<%= documentType == null ? i18nNow.getTypeI18NString("Document",sLanguage):i18nNow.getTypeI18NString(documentType,sLanguage)%>" size="20" readonly />
          <input type="button" name="FieldButton" value="..." size="5" onClick="showTypeSelector()"/>
<%
        }
%>
          <!-- //XSSOK -->
          <input type="hidden" name="realType" value="<%= documentType == null ? "Document":documentType%>" />
      </td>

    </tr>
<%
}
else
{
	String defaultDocType = "AT_C_DOCUMENT";
	  // pass the default Type as a hidden variable
	%>  
	<!-- //XSSOK -->
	 <input type="hidden" name="type" size="20" readonly value="<%=defaultDocType%>"/>
	 <input type="hidden" name="realType" value="<%=defaultDocType%>" />
	<%
} // End if the current type != AT_C_DOCUMENT
		
if( ! "AT_C_DOCUMENT".equals(documentType) )
{ 
	// Display only if the current type != AT_C_DOCUMENT
    Iterator policyItr = documentPolicyNames.iterator();

    if(!"false".equalsIgnoreCase(showPolicy) && bAllowChangePolicy)
    {
%>
    <tr>
      <td class="labelRequired" >
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Policy</emxUtil:i18n>
      </td>
      <td class="inputField" >
          <select name = "policy" onChange=reload()>
<%
          String docPolicy = "";
          String i18nPolicy = "";
          while( policyItr.hasNext())
          {
            docPolicy = (String)policyItr.next();

            // Bug 303724 fix, do not list the excluded policy
            if(!listExcludePolicies.contains(docPolicy))
            {
              i18nPolicy  = i18nNow.getMXI18NString(docPolicy,"",sLanguage,"Policy");
%>
              <!-- //XSSOK -->
              <option value="<%=docPolicy%>" <%=docPolicy.equals(defaultDocumentPolicyName)?"selected":""%> ><%=i18nPolicy%></option>
<%
            }
         }
%>
        </select>
      </td>
    </tr>
<%
    }
    else if( objectAction.equals(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER))
    {
%>
    <tr>
      <td class="labelRequired" >
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Policy</emxUtil:i18n>
      </td>
      <!-- //XSSOK -->
      <td class="inputField" ><%=defaultDocumentPolicyName%></td>
    </tr>
<%
    }
    else
    {
      // pass the default Policy as a hidden variable
%>  
    <!-- //XSSOK -->
      <input type="hidden" name="policy"  value="<%=defaultDocumentPolicyName%>"/>
<%
    }
}
else
{
  // pass the default Policy as a hidden variable
  String defaultDocTypePolicy = "Document Release";
%>  
<!-- //XSSOK -->
  <input type="hidden" name="policy"  value="<%=defaultDocTypePolicy%>"/>
<%
} // End only if the current type != AT_C_DOCUMENT
		
    if( objectAction.equals(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER))
    {
%>
    <tr>
      <td class="labelRequired" >
        <emxUtil:i18n localize="i18nId">emxComponents.Common.CompletionState</emxUtil:i18n>
      </td>
      <td class="inputField" >
          <select name = "state" >
<%
          Iterator stateItr = stateList.iterator();
          String state = "";
          String i18nState= "";
          while( stateItr.hasNext())
          {
            state = (String)stateItr.next();
            i18nState = i18nNow.getMXI18NString(state, defaultDocumentPolicyName, sLanguage, "State");
%>
			<!-- //XSSOK -->
            <option value="<%=state%>" ><%=i18nState%></option>
<%
         }
%>
        </select>
      </td>
    </tr>
<%
    }

    // Start of display of Revision field depending on the parametes passed in
    // If showRevision parameter came as required it will display with labelrequired
    // If showRevision parameter came as true it will display as optional field
    // If showRevision parameter came as null or false, Revision field will not be displayed
    txtLable = "label";
    if ( showRevision.equalsIgnoreCase("true") || showRevision.equalsIgnoreCase("required") )
    {
        if ( showRevision.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
    <tr><!--//XSSOK-->
      <td class="<%=txtLable%>" >
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Revision</emxUtil:i18n>
      </td>

      <td class="inputField" >
      <!-- //XSSOK -->
        <input type="text" readonly name="revision" size="20" value="<%=documentRevision==null?"0":XSSUtil.encodeForHTMLAttribute(context, documentRevision)%>" />
      </td>
    </tr>
<%
    }

    // Start of display of Title depending on the parametes passed in
    // If showTitle parameter came as required it will display with labelrequired
    // If showTitle parameter came as null or true, description field will be displayed as optional
    // If showTitle parameter came as false, description field will NOT be displayed
    txtLable = "label";
    // REQ23.008 Updated the create page according to MDD- START 
	if("AT_C_DOCUMENT".equals(documentType) )
	{
	  showTitle = "required";
	}
    // REQ23.008 Updated the create page according to MDD- END
    if ( showTitle.equalsIgnoreCase("true") || showTitle.equalsIgnoreCase("required") )
    {

        if ( showTitle.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
    <tr><!--//XSSOK-->
      <td class="<%=txtLable%>" >
        <emxUtil:i18n localize="i18nId">ATemxComponents.Common.Title</emxUtil:i18n>
      </td>

      <td class="inputField" >
        <input type="text" name="title" size="20" maxlength="80" value="<xss:encodeForHTMLAttribute><%=documentTitle==null?"":documentTitle%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

<%
    }
	// REQ23.008 Updated the create page according to MDD- START
	if( ! "AT_C_DOCUMENT".equals(documentType) ) //update 1
	{
    // REQ23.008 Updated the create page according to MDD- END
    // Start of display of Description depending on the parametes passed in
    // If showDescription parameter came as required it will display with labelrequired
    // If showDescription parameter came as null or true, description field will be displayed as optional
    // If showDescription parameter came as false, description field will NOT be displayed
    txtLable = "label";
    if ( showDescription.equalsIgnoreCase("true") || showDescription.equalsIgnoreCase("required") )
    {
        if ( showDescription.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
    <tr>
	<!-- //XSSOK -->
      <td class="<%=txtLable%>"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n> &nbsp;</td>
      <td class="inputField">
        <textarea name="description" rows="5" cols="36" wrap><xss:encodeForHTML><%=documentDescription==null?"":documentDescription%></xss:encodeForHTML></textarea>
      </td>
    </tr>
<%
    }
// REQ23.008 Updated the create page according to MDD- START
	}
// REQ23.008 Updated the create page according to MDD- END
    // Start of display of Owner field depending on the parametes passed in
    // If showOwner parameter came as required it will display with labelrequired
    // If showOwner parameter came as true it will display as optional field
    // If showOwner parameter came as null or false, Owner field will not be displayed
    txtLable = "label";

    if ("".equals(documentOwner) || "null".equals(documentOwner))
      documentOwner=null;

    if ( showOwner.equalsIgnoreCase("true") || showOwner.equalsIgnoreCase("required") )
    {
        if ( showOwner.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>

    <tr>
		<!-- //XSSOK -->
      <td class="<%=txtLable%>">
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Owner</emxUtil:i18n>
      </td>

      <td class="inputField" >
<%
    if (showOwner.equalsIgnoreCase("required")){
%>
        <input type="text" size="20" name="person" onfocus="document.frmMain.person.blur()" value="<xss:encodeForHTMLAttribute><%=documentOwner==null?context.getUser():documentOwner%></xss:encodeForHTMLAttribute>" />
<%
    }else{
%>
        <input type="text" size="20" name="person" onFocus="document.frmMain.person.blur()"  value="<xss:encodeForHTMLAttribute><%=documentOwner==null?"":documentOwner%></xss:encodeForHTMLAttribute>" />
<%
    }
%>

        <input type="button" value="..." name="btn" onclick="chooseOwner_onclick()" />
<%
    if ( !showOwner.equalsIgnoreCase("required")){
      //not required so show clear link
%>
        <a class="dialogClear" href="javascript:;" onclick="document.forms[0].person.value=''" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
<%
    }
%>

      </td>
    </tr>

<%
    }

    // Start of display of Folder field depending on the parametes passed in
    // If showFolder parameter came as required it will display with labelrequired
    // If showFolder parameter came as true it will display as optional field
    // If showFolder parameter came as null or false, Folder field will not be displayed
    // this parameter is used in TeamCentral, Sourcing Central
    txtLable = "label";
    if ( showFolder.equalsIgnoreCase("true") || showFolder.equalsIgnoreCase("required") )
    {
        if ( showFolder.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }

%>
      <tr>
		<!-- //XSSOK -->
        <td class="<%=txtLable%>"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.Common.WorkspaceFolder</emxUtil:i18n></label></td>
        <td class="field">

          <input type="text" name="txtWSFolder" size="20" onfocus="blur()" value="<xss:encodeForHTMLAttribute><%=wsFolder%></xss:encodeForHTMLAttribute>"/>
          <input type="button" name="folder" value="..." onclick="folderlist()"/>

        </td>
      </tr>
<%
    }

    // Start of display of AccessType field depending on the parametes passed in
    // If showAccessType parameter came as required it will display with labelrequired
    // If showAccessType parameter came as true it will display as optional field
    // If showAccessType parameter came as null or false, AccessType field will not be displayed
    txtLable = "label";
    if("true".equalsIgnoreCase( showAccessType ) || "required".equalsIgnoreCase( showAccessType) )
    {
      if ( showAccessType.equalsIgnoreCase("required") )
      {
         txtLable = "labelRequired";
      }

      String accessAttrStr       = PropertyUtil.getSchemaProperty(context, "attribute_AccessType");
      AttributeType accessAttrType      = new AttributeType(accessAttrStr);
      StringList    accessAttributes    = null;
      StringItr     accessAttributesItr = null;
      String        defaultAccess       = null;

      accessAttrType.open(context);
      accessAttributes = accessAttrType.getChoices();
      defaultAccess    = accessAttrType.getDefaultValue(context);
      accessAttrType.close(context);
      accessAttributesItr = new StringItr(accessAttributes);
      // this happens first time the page is loaded
      if (documentAccessType == null || "".equals(documentAccessType) || "null".equals(documentAccessType))
      {
        documentAccessType = defaultAccess;
      }
%>
      <tr>
       <!-- XSSOK -->
        <td class="<%=txtLable%>">
          <%= i18nNow.getAttributeI18NString(accessAttrStr,sLanguage)%>&nbsp;
        </td>
        <td class="inputField" align="left">

        <select name="AccessType" size="1">
<%

      MapList ml = AttributeUtil.sortAttributeRanges(context, accessAttrStr, accessAttributes, sLanguage);
      Iterator mlItr = ml.iterator();
      while (mlItr.hasNext())
      {
        Map choiceMap = (Map) mlItr.next();
        String choice = (String) choiceMap.get("choice");
        String translation = (String) choiceMap.get("translation");
%>
        <option value="<xss:encodeForHTMLAttribute><%= choice %></xss:encodeForHTMLAttribute>" <%=(documentAccessType.equals(choice)? "selected" : "")%>><%= XSSUtil.encodeForHTML(context, translation) %></option>
<%
      }
%>
        </select>
        </td>
      </tr>
<%
  }

  // dynamic attribute display for custom sub-types of DOCUMENTS
  // get the list of Attribute names, filter out the attributes defined

  // by the property
  String excludeAttributes = EnoviaResourceBundle.getProperty(context,"emxComponents.CreateDocument.ExcludeAttributeList");
  StringList excludeAttrList   = new StringList();
  
  if(excludeAttributes != null)
  {
    StringTokenizer excludeAttrTokenizer = new StringTokenizer(excludeAttributes,",");
    while (excludeAttrTokenizer.hasMoreTokens())
    {
      excludeAttrList.add(excludeAttrTokenizer.nextToken().trim());
    }

    if( !excludeAttrList.contains("attribute_Title"))
    {
      excludeAttrList.add("attribute_Title");
    }
    if( !excludeAttrList.contains("attribute_AccessType"))
    {
      excludeAttrList.add("attribute_AccessType");
    }
    if( !excludeAttrList.contains("attribute_CheckinReason"))
    {
      excludeAttrList.add("attribute_CheckinReason");
    }

    if( "AT_C_DOCUMENT".equals(documentType) )
    {
    	excludeAttrList.add("attribute_AT_C_Confidential_Level");
        excludeAttrList.add("attribute_AT_C_Doc_Code");
        excludeAttrList.add("attribute_AT_C_DocumentLastPromoteUser");
        excludeAttrList.add("attribute_AT_C_Rendition_Status");
        excludeAttrList.add("attribute_AT_C_Rendition");
		//START - QC5030
        //excludeAttrList.add("attribute_AT_C_Supplier_Reference");
        //excludeAttrList.add("attribute_AT_C_Supplier_Revision");
		//END - QC5030
        if ( excludeAttrList.contains("attribute_Language") ) {
        	excludeAttrList.remove("attribute_Language") ;
        }        
    }    
  }
  
//added third parameter to get the multiline value for bug no 338579
  MapList attributeMapList = mxType.getAttributes( context, documentType,true);
  Locale locale = request.getLocale();
  Iterator i = attributeMapList.iterator();
  String attributeName = null;
  String attributeValue = null;
  String attributedefValue = null;
  StringList attributeChoices = null;

  String symbolicAttributeName = null;
// REQ23.008 Updated the create page according to MDD- START
  int tempCtr = 0; 
  Map tempMap = new HashMap();
  while(i.hasNext())
  {
	  tempCtr++;
// REQ23.008 Updated the create page according to MDD- END
    Map attributeMap = (Map)i.next();
    attributeName = (String)attributeMap.get("name");
    symbolicAttributeName = FrameworkUtil.getAliasForAdmin(context, "attribute", attributeName, true);

    if(!excludeAttrList.contains(symbolicAttributeName))
    {
      // UIUtil converts the date to formatted date, which will not be correct to display
      // to avoid this, do not use UiUtil for date fields
      if ("timestamp".equalsIgnoreCase((String)attributeMap.get("type")))
      {
%>
        <tr>
          <td class="label" >
            <%= XSSUtil.encodeForHTML(context, i18nNow.getAttributeI18NString(attributeName,sLanguage))%>
          </td>
          <td class="inputField">
              <input type="text" name="<xss:encodeForHTMLAttribute><%=attributeName%></xss:encodeForHTMLAttribute>"
                  value="<xss:encodeForHTMLAttribute><%=(String) emxCommonDocumentCheckinData.get(attributeName)==null?"":(String) emxCommonDocumentCheckinData.get(attributeName)%></xss:encodeForHTMLAttribute>"   />&nbsp;&nbsp;
                  <a href="javascript:showCalendar2('frmMain', '<xss:encodeForJavaScript><%=attributeName%></xss:encodeForJavaScript>','')">
                  <img src="../common/images/iconSmallCalendar.gif" border="0" /></a>&nbsp;
			  <!-- //XSSOK -->
              <a class="dialogClear" href="javascript:;" onclick="document.forms[0]['<%=attributeName%>'].value =''">
                <emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n>
              </a>
          </td>
        </tr>
<%
      }
      else
      {
        attributedefValue = (String)attributeMap.get("default");
        attributeChoices  = (StringList)attributeMap.get("choices");
        attributeValue    = (String) emxCommonDocumentCheckinData.get(attributeName);

        if((attributeChoices != null && attributeChoices.size() > 0) && (attributeValue == null || "".equals(attributeValue) || "null".equals(attributeValue)))
        {
           attributeValue = attributedefValue;
        }
        attributeMap.put("value", attributeValue);
        if( "type_AT_C_DOCUMENT".equals(documentType) )
        {        	
            MapList ml = AttributeUtil.sortAttributeRanges(context, attributeValue, attributeChoices, sLanguage);
            Iterator mlItr = ml.iterator();
            while (mlItr.hasNext())
            {
              Map choiceMap = (Map) mlItr.next();
              String choice = (String) choiceMap.get("choice");
              String translation = (String) choiceMap.get("translation");
      %>
              <option value="<xss:encodeForHTMLAttribute><%= choice %></xss:encodeForHTMLAttribute>" <%=(documentAccessType.equals(choice)? "selected" : "")%>><%= XSSUtil.encodeForHTML(context, translation) %></option>
      <%
            }
        } else {
// REQ23.008 Updated the create page according to MDD- START
        	if ( "AT_C_Doc_Type".equals(attributeName)) {	
					%>
        			<tr>
			          <td class="labelRequired">
			            <%= XSSUtil.encodeForHTML(context, i18nNow.getAttributeI18NString(attributeName,sLanguage))%>
			          </td>
			          <!-- //XSSOK -->
			          <td class="inputField"><%=UIUtil.displayField(context,attributeMap,"edit",sLanguage,"frmMain",session,locale)%>&nbsp;</td>
			        </tr>
					<%
			//START - QC5030	
        	}else if ( "AT_C_ABS".equals(attributeName) || "AT_C_PBS_Code".equals(attributeName)
        			|| "Language".equals(attributeName) || "AT_C_Supplier_Reference".equals(attributeName) || "AT_C_Supplier_Revision".equals(attributeName) ) {	
				//END - QC5030
						tempMap.put( attributeName, ""+(tempCtr-1) );
// REQ23.008 Updated the create page according to MDD- END        	
        	} else {
			%>
			        <tr>
			          <td class="label" class="labelRequired">
			            <%= XSSUtil.encodeForHTML(context, i18nNow.getAttributeI18NString(attributeName,sLanguage))%>
			          </td>
			          <!-- //XSSOK -->
			          <td class="inputField"><%=UIUtil.displayField(context,attributeMap,"edit",sLanguage,"frmMain",session,locale)%>&nbsp;</td>
			        </tr>
			<%  
        	}
		 }
      }
    }
  }
  
// REQ23.008 Updated the create page according to MDD- START  
  if( "AT_C_DOCUMENT".equals(documentType) ) 
	{
		Map tempAttribMap = null;
		int tempInt = 0;
		
		StringList tempStringList = new StringList(4);
		
		tempStringList.add("AT_C_ABS");
		tempStringList.add("AT_C_PBS_Code");
		tempStringList.add("Language");
		//START - QC5030
		tempStringList.add("AT_C_Supplier_Reference");
        tempStringList.add("AT_C_Supplier_Revision");
		//END - QC5030
		String txtLable1 = "label";

		
		Iterator tempStringListItr = tempStringList.iterator(); 
		while (tempStringListItr.hasNext())
            {
				String tempAttrib = (String)tempStringListItr.next();
				
				if("AT_C_ABS".equals(tempAttrib) || "AT_C_PBS_Code".equals(tempAttrib))
				{
					txtLable1 = "labelRequired";
				}
				else{
					txtLable1 = "label";
				}
				String tempIndex = (String)tempMap.get(tempAttrib);
				tempInt = Integer.parseInt(tempIndex);
				tempAttribMap = (Map)attributeMapList.get(tempInt);
				
				//START - QC5030
				String sName = (String)tempAttribMap.get("name");
				if(sName!=null && "Language".equals(sName)){
					StringList slChoices = (StringList)tempAttribMap.get("choices");
					if(slChoices.contains("Japanese"))
						slChoices.remove("Japanese");
					if(slChoices.contains("Chinese"))
						slChoices.remove("Chinese");
					if(slChoices.contains("Korean"))
						slChoices.remove("Korean");
					tempAttribMap.put("choices",slChoices);
				}
				//END - QC5030
				
				if(tempAttribMap!=null)
				{
					%>
        			<tr>
			          <td class="<%=txtLable1%>">
			            <%= XSSUtil.encodeForHTML(context, i18nNow.getAttributeI18NString(tempAttrib,sLanguage))%>
			          </td>
			          <!-- //XSSOK -->
			          <td class="inputField"><%=UIUtil.displayField(context,tempAttribMap,"edit",sLanguage,"frmMain",session,locale)%>&nbsp;</td>
			        </tr>
					<%
					
				}
				
			}

		
    // Start of display of Description depending on the parametes passed in
    // If showDescription parameter came as required it will display with labelrequired
    // If showDescription parameter came as null or true, description field will be displayed as optional
    // If showDescription parameter came as false, description field will NOT be displayed
    txtLable = "label";
    if ( showDescription.equalsIgnoreCase("true") || showDescription.equalsIgnoreCase("required") )
    {
        if ( showDescription.equalsIgnoreCase("required") )
        {
            txtLable = "labelRequired";
        }
%>
    <tr>
	<!-- //XSSOK -->
      <td class="<%=txtLable%>"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n> &nbsp;</td>
      <td class="inputField">
        <textarea name="description" rows="5" cols="36" wrap><xss:encodeForHTML><%=documentDescription==null?"":documentDescription%></xss:encodeForHTML></textarea>
      </td>
    </tr>
<%
    }
	}
// REQ23.008 Updated the create page according to MDD- END
    if("previous".equals(fromPage)) {
            showFormat = (String) emxCommonDocumentCheckinData.get("showFormatBkp");
    }else {
            emxCommonDocumentCheckinData.put("showFormatBkp", showFormat);
    }


  if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ) )
    {

        emxCommonDocumentCheckinData.put("noOfFiles", "1");
        emxCommonDocumentCheckinData.put("isVcDoc", "true");
%>
<!-- //XSSOK -->
    <jsp:include page="../components/emxCommonDocumentVCInformation.jsp"><jsp:param name="path" value="<%=path%>"/><jsp:param name="vcDocumentType" value="<%=vcDocumentType%>"/><jsp:param name="selector" value="<%=selector%>"/><jsp:param name="server" value="<%=server%>"/><jsp:param name="format" value="<%=defaultFormat%>"/><jsp:param name="showFormat" value="<%=showFormat%>"/><jsp:param name="populateDefaults" value="<%=populateDefaults%>"/><jsp:param name="objectAction" value="<%=objectAction%>"/><jsp:param name="disableFileFolder" value="<%=disableFileFolder%>"/><jsp:param name="defaultDocumentPolicyName" value="<%=defaultDocumentPolicyName%>"/><jsp:param name="reloadPage" value="<%=reloadPage%>"/></jsp:include>
<%  }
  if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ON_DEMAND)) {
              emxCommonDocumentCheckinData.put("isVcDoc", "true");
%>
    <tr>
      <td width="10%" class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.VCDocument.DesignSync</emxUtil:i18n>&nbsp;
        </td>
       <td colspan="1" class="inputField">

<%
	if ( vcDocumentType != null && "File".equalsIgnoreCase(vcDocumentType) )
	{
%>
      <input type="radio" name="vcDocumentTmp" value="File" checked onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Folder" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Module" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="hidden" name="vcDocumentType" value="File"/>
<% }
   else if(vcDocumentType != null && "Folder".equalsIgnoreCase(vcDocumentType) ) {
%>
      <input type="radio" name="vcDocumentTmp" value="File"  onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Folder" checked onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Module" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="hidden" name="vcDocumentType" value="Folder"/>
<% }
   else if(vcDocumentType != null && ("Module".equalsIgnoreCase(vcDocumentType) || "Version".equalsIgnoreCase(vcDocumentType)) ) {
       %>
             <input type="radio" name="vcDocumentTmp" value="File"  onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
             <input type="radio" name="vcDocumentTmp" value="Folder" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
             <input type="radio" name="vcDocumentTmp" value="Module" checked onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
             <input type="hidden" name="vcDocumentType" value="Module"/>
<% }
   else{ %>
      <input type="radio" name="vcDocumentTmp" value="File" checked onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Folder" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
      <input type="radio" name="vcDocumentTmp" value="Module" onfocus="onFileFolderSelect(this)"/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="hidden" name="vcDocumentType" value="File"/>
<% } %>
      </td>
      </tr>
<% } %>


    <tr>
      <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
      <td width="90%">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="typeChanged" value="" />
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

