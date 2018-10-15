<%--  emxLibraryCentralSearchIntermediate.jsp  -
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxLibraryCentralUtils.inc"%>
<jsp:useBean id="LibraryCentralBean" class="com.matrixone.apps.library.Libraries" scope="session"/>
<html>
<body>
<form name="addExisting" method="post" action="../common/emxFullSearch.jsp" target="_top">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<%
    try
    {
       StringBuffer submitURL           = new StringBuffer("../documentcentral/");
       String useMode                   = emxGetParameter(request,"useMode");
       String languageStr               = request.getHeader("Accept-Language");
       String emxTableRowIds[]          = getTableRowIDsArray(emxGetParameterValues(request,"emxTableRowId"));
       String strAllowedSearchItems     = "";
       String parentOId                 = emxGetParameter(request, "objectId");
       String sSymbolicParentType       = "";
       String sType                     = "";
       if(!UIUtil.isNullOrEmpty(parentOId)){
            DomainObject doObj          = new DomainObject(parentOId);
            String strParentType        = doObj.getInfo(context,DomainConstants.SELECT_TYPE);
            sSymbolicParentType         = FrameworkUtil.getAliasForAdmin(context,"type", strParentType,true);
       }
       HashMap allowedClassesMap        = (HashMap)LibraryCentralCommon.getAllowedClassesMap(context);
       HashMap allowedParentsMap        = (HashMap)LibraryCentralCommon.getAllowedParentsMap(context);
       HashMap allowedEndItemsMap       = (HashMap)LibraryCentralCommon.getAllowedEndItemsMap(context);
       useMode                          = UIUtil.isNullOrEmpty(useMode)?"":useMode;
       StringBuffer sbField             = new StringBuffer("TYPES=");
       String sFormInclusionList        = "";
       String selection                 = "multiple";
       String excludeOIDprogram         = "emxLibraryCentralFindObjects:getAddExisitingExcludeOIDs";
       String includeOIDprogram			= "";
       String table                     = "AEFGeneralSearchResults";
       String helpMarker                = "emxhelpfullsearch";
       String formInclusionList         = "";
       String header                    = "emxLibraryCentral.Search.Results";
       String suiteKey                  = emxGetParameter(request,"suiteKey");
       boolean bAddparameters           = false;
       boolean addToFolder              = false;
           if("moveClass".equalsIgnoreCase(useMode)){
           String strObjectId           = "";
           emxTableRowIds               = (String[]) getTableRowIDsArray(emxTableRowIds);
           if(emxTableRowIds != null && emxTableRowIds.length > 0) {
               strObjectId              = emxTableRowIds[0];
           }
           table="LCClassificationList";
           DomainObject doObj           = new DomainObject(strObjectId);
           DomainObject parentDomObj	= new DomainObject(parentOId);
           String parentTypeStr = FrameworkUtil.getAliasForAdmin(context,"type", parentDomObj.getInfo(context,DomainConstants.SELECT_TYPE),true);
           //check whether class is General class & it contains Port
           String classificationType=doObj.getInfo(context,DomainConstants.SELECT_TYPE);
           StringList busSelects=new StringList();
           if(classificationType.equalsIgnoreCase(LibraryCentralConstants.TYPE_GENERAL_CLASS) &&
        		   doObj.getRelatedObjects(context,LibraryCentralConstants.RELATIONSHIP_CLASSIFIED_ITEM,
	                LibraryCentralConstants.TYPE_LIBRARY_FEATURE_PORT,
	                busSelects,
	                null,
	                false,//boolean getTo,
	                true,//boolean getFrom,
	                (short)1,
	                null,
	                null,
	                0).size() >= 1){
        	   %>
               <script>
	               alert("<emxUtil:i18nScript localize="i18nId">emxLibraryCentral.Move.Message</emxUtil:i18nScript>");
	               getTopWindow().closeWindow();
    	       </script>
<%
           }
           //Code added for R216 release
           //To enable population of appropriate Libraries, appropriate Types are appended to the field.
           else{
           busSelects.add(LibraryCentralConstants.SELECT_ID);
           String typeStr = FrameworkUtil.getAliasForAdmin(context,"type", doObj.getInfo(context,DomainConstants.SELECT_TYPE),true);
           sbField.append(LibraryCentralConstants.TYPE_GENERAL_LIBRARY+",");
           if (doObj.isKindOf(context,DomainConstants.TYPE_PART_FAMILY))
           {
        	   sbField.append(LibraryCentralConstants.TYPE_PART_LIBRARY+",");
           }
           else if(doObj.isKindOf(context,LibraryCentralConstants.TYPE_DOCUMENT_FAMILY))
           {
        	   sbField.append(LibraryCentralConstants.TYPE_DOCUMENT_LIBRARY+",");
           }
           sbField.append(typeStr);
           selection                    = "single";
           excludeOIDprogram            = "emxLibraryCentralFindObjects:getMoveExcludeOIDs";
           formInclusionList            = "COUNT";
           submitURL.append("AT_emxMultipleClassificationRemoveClassPreProcess.jsp?Mode=Move");
           }
%>
		<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>">
		<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>">
		<input type="hidden" name="oldParentObjectId" value="<xss:encodeForHTMLAttribute><%=parentOId%></xss:encodeForHTMLAttribute>">
<%
       } else if("addClass".equalsIgnoreCase(useMode)){
           sbField.append((String)allowedClassesMap.get(sSymbolicParentType));
		   //Added for REQ17.005 - START
    	   if(!"type_AT_C_3PL".equals(sSymbolicParentType)){
				sbField.append(",type_AT_C_UNSPSC_LeafClass");
		   }
		   //Added for REQ17.005 - END
           formInclusionList = "COUNT";
           bAddparameters    = true;
           table="LBCGeneralSearchResults";
           submitURL.append("emxLibraryCentralAddExistingProcess.jsp?useMode=");
           submitURL.append(useMode);
       } else if("addClassificationEndItem".equalsIgnoreCase(useMode)){
    	   // if the Symbolic Parent type == type_AT_C_UNSPSC_BranchClass
    	   // So remove the type Part
    	   if ( "type_AT_C_UNSPSC_BranchClass".equals(sSymbolicParentType) ) {
    		   String lAllowedType = (String)allowedEndItemsMap.get(sSymbolicParentType) ;
    		   String[] lTabAllowedType = lAllowedType.split(",") ;
    		   String lNewsSymbolicParentType = "type_AT_C_UNSPSC_BranchClass=" ;
    		   for ( int lI = 0 ; lI < lTabAllowedType.length ; lI++ ) {
    			   String lType = lTabAllowedType[lI] ;
    			   if ( ! ("type_Part".equals(lType) || lType.contains("=type_Part")) ) {
    				   if ( lI > 0 && lI < lTabAllowedType.length-1 ) {
    					   lNewsSymbolicParentType = lNewsSymbolicParentType + "," + lType ;
    				   } else {
    					   lNewsSymbolicParentType = lNewsSymbolicParentType + lType + "," ;
    				   }
    			   }
    		   }
    		   sbField.append(lNewsSymbolicParentType);
			   //Added for REQ17.005 - START
    	   } else if("type_AT_C_3PL".equals(sSymbolicParentType)){
			   sbField.append("type_AT_C_STANDARD_PART,type_AT_C_STANDARD_DOC,type_AT_ENG_CORE_MATERIAL,type_AT_ENG_PROTECTION_MATERIAL");
			   //Added for REQ17.005 - END
    	   } else {
    		   sbField.append((String)allowedEndItemsMap.get(sSymbolicParentType));   
    	   }
           //Fix for 283268V6R2014x. IS_VERSION_OBJECT is required only for Real Time.
           String isIndexedMode=EnoviaResourceBundle.getProperty(context,"emxFramework.FullTextSearch.QueryType");
           if(!("Indexed".equals(isIndexedMode))){
          		sbField.append(":CURRENT!=policy_Version.state_Exists:CURRENT!=policy_VersionedDesignPolicy.state_Exists");
           }
           sbField.append(":current.access[toconnect]=true");

           bAddparameters   = true;
           submitURL.append("emxLibraryCentralObjectAddEndItems.jsp?useMode=");
           submitURL.append(useMode);
           table            = "LBCClassifiedItemSearchResults";
       } else if("addRetainedDocuments".equalsIgnoreCase(useMode)){
           sbField.append((String)JSPUtil.getCentralProperty(application,session,"emxLibraryCentral","Record.SupportedTypes"));
           bAddparameters   = true;
           submitURL.append("emxLibraryCentralRetainedDocumentAddContentsProcess.jsp?useMode=");
           submitURL.append(useMode);
      } else if("addToFolders".equalsIgnoreCase(useMode)  || "addToFoldersFromListPage".equalsIgnoreCase(useMode) ){
           addToFolder      = true;
           includeOIDprogram            = "emxLibraryCentralFindObjects:getFolderIncludeOIDs";
           LibraryCentralBean.setObjectRowID(emxTableRowIds);
           sbField.append("type_ProjectVault");
           table            = "LBCFoldersSearchResults";
           header           = "emxDocumentCentral.Shortcut.SelectFolder";
           submitURL.append("emxDocumentCentralFolderSelectProcess.jsp?useMode=");
           submitURL.append(useMode);
%>
           <input type="hidden" name="includeOIDprogram" value="<xss:encodeForHTMLAttribute><%=includeOIDprogram%></xss:encodeForHTMLAttribute>">
<%
      } else if("searchIn".equalsIgnoreCase(useMode)){
          bAddparameters = true;
          DomainObject doObj    = new DomainObject(parentOId);
          table="LBCGeneralSearchResults";
          String parentType     = FrameworkUtil.getAliasForAdmin(context,"type", doObj.getInfo(context,DomainConstants.SELECT_TYPE),true);
          if ("type_ProjectVault".equals(parentType)) {
              sbField.append("type_Libraries,type_Classification,type_Part,type_DOCUMENTS:REL_HAS_VAULTED_DOCUMENTS_REV2_FROM_ID=");
          }
          sbField.append(parentOId);
          formInclusionList="CreatedOn,Approver,DESCRIPTION";
%>
<input type="hidden" name="toolbar" value="LBCSearchResultToolBar">
<%
         }
%>
<input type="hidden" name="field" value="<xss:encodeForHTMLAttribute><%=sbField.toString()%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=table%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="selection" value="<xss:encodeForHTMLAttribute><%=selection%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%=helpMarker%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="useMode" value="<xss:encodeForHTMLAttribute><%=useMode%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%=header%></xss:encodeForHTMLAttribute>">
<input type="hidden" name="hideHeader" value="true">
<input type="hidden" name="showInitialResults" value="true">
<%
if(!"../documentcentral/".equalsIgnoreCase((submitURL.toString()))) {
%>
<input type="hidden" name="submitURL" value="<xss:encodeForHTMLAttribute><%=submitURL.toString()%></xss:encodeForHTMLAttribute>">
<%
}
if(!"".equals(formInclusionList)) {
%>
<input type="hidden" name="formInclusionList" value="<xss:encodeForHTMLAttribute><%=formInclusionList%></xss:encodeForHTMLAttribute>">
<%
}
if (!addToFolder) {
%>
<input type="hidden" name="excludeOIDprogram" value="<xss:encodeForHTMLAttribute><%=excludeOIDprogram%></xss:encodeForHTMLAttribute>">
<%
}
    // Append the parameter to the content page
    if(bAddparameters) {
        for (Enumeration e = emxGetParameterNames(request); e.hasMoreElements();) {
            String strParamName  = (String)e.nextElement();
            String strParamValue = (String)emxGetParameter(request, strParamName);
%>
			<input type="hidden" name="<%=strParamName%>" value="<xss:encodeForHTMLAttribute><%=strParamValue%></xss:encodeForHTMLAttribute>">
<%
        }
    }
%>
</form>
  <script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
  <script type="text/javascript">
  document.addExisting.submit();
  </script>
<%
    }
    catch (Exception ex)
    {
        ex.printStackTrace();
    }
%>
</body>
</html>
