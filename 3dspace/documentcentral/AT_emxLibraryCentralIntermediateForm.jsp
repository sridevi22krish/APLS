<%--  emxLibraryCentralIntermediateForm.jsp  -
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxLibraryCentralUtils.inc"%>

<%@ page import="java.util.List,java.util.Map,com.matrixone.apps.library.LibraryCentralCommon" %>
<emxUtil:localize id="i18nId" bundle="emxApparelAcceleratorStringResource" locale='<xss:encodeForHTML><%= request.getHeader("Accept-Language") %></xss:encodeForHTML>' />

<%
    try
    {
        String objectId         = emxGetParameter(request,"objectId");
        String parentOId        = emxGetParameter(request,"parentOID");
        String webFormName      = emxGetParameter(request,"form");
        String mode             = emxGetParameter(request,"mode");
        String type             = "";
        String policy           = "";
        String pageHeader       = "";
        String helpMarker       = "";
        String createJPO        = "emxLibraryCentralCommon:createLBCObject"; 
        StringBuffer contentURL = new StringBuffer("../common/emxCreate.jsp?");
        
        String sATTtypeClass             = emxGetParameter(request,"ATTtypeClass");

        
        StringList objectSelects = new StringList(2);
        objectSelects.add(DomainConstants.SELECT_TYPE);
        objectSelects.add(DomainConstants.SELECT_POLICY);
        
        DomainObject domObj     = new DomainObject(objectId);
        Map mapResults          = domObj.getInfo(context , objectSelects);
        type                    = (String)mapResults.get(DomainConstants.SELECT_TYPE);
        policy                  = FrameworkUtil.getAliasForAdmin(context,"policy",(String)mapResults.get(DomainConstants.SELECT_POLICY),true);
        String strType          = FrameworkUtil.getAliasForAdmin(context,"type", type, true);  
        
        // Copy Forms Will Be used Both For Copy Objects and Revise Objects
        if(mode != null && !"null".equals(mode) && ("copy".equalsIgnoreCase(mode)|| "revise".equalsIgnoreCase(mode))) {
               
            String form             = "";        
            if (LibraryCentralConstants.TYPE_FOLDER.equals(type)){//folder
                form        = "type_CopyWorkspaceVault";
            } else if (LibraryCentralConstants.TYPE_GENERIC_DOCUMENT.equals(type)){//Generic Document
                form        = "type_CopyGenericDocument";
            } else if (LibraryCentralConstants.TYPE_DOCUMENT_SHEET.equals(type)){// Document Sheet
                form        = "type_CopyDocumentSheet";
            }  
                       
            if("revise".equalsIgnoreCase(mode)) {
                pageHeader          = "emxDocumentCentral.Common.Revise";
                helpMarker          = "emxhelpreviseobject";
                createJPO           = "emxLibraryCentralCommon:createRevision";
            }else {
                if(LibraryCentralConstants.TYPE_FOLDER.equals(type))  {
                    helpMarker      = "emxhelpfoldercopy";
                    pageHeader      = "emxLibraryCentral.Shortcut.CopyFolder";
                } else if (LibraryCentralConstants.TYPE_GENERIC_DOCUMENT.equals(type)){
                    helpMarker      = "emxhelpcopyobject";
                    pageHeader      = "emxLibraryCentral.Shortcut.CopyGenericDocument";
                } else if (LibraryCentralConstants.TYPE_DOCUMENT_SHEET.equals(type)){
                    helpMarker      = "emxhelpcopyobject";
                    pageHeader      = "emxLibraryCentral.Shortcut.CopyDocumentSheet";
                }
                createJPO           = "emxLibraryCentralCommon:createClone";
            }
           
            contentURL.append("policy=").append(policy);
            contentURL.append("&form=").append(form);
            contentURL.append("&type=").append(strType);
            contentURL.append("&typeChooser=false&nameField=keyin");
            contentURL.append("&copyObjectId=").append(objectId);
            contentURL.append("&mode=").append(mode);          
            
        } else {
            String allowedClasses   = LibraryCentralCommon.getAllowedClassesForObject(context,objectId);
            if (LibraryCentralConstants.TYPE_GENERAL_LIBRARY.equals(type)) {
                allowedClasses          = "type_GeneralClass,"+allowedClasses; 
            }
            type                    = allowedClasses;
            if (allowedClasses.indexOf(",") > 0) {
                type                = allowedClasses.substring(0,allowedClasses.indexOf(","));
            }
            type                    = PropertyUtil.getSchemaProperty(context, type);
          
            //contentURL.append("type=");
            //contentURL.append(allowedClasses);
	    	//Alstom
	   		if (sATTtypeClass != null && !"".equals(sATTtypeClass))
	    		contentURL.append("type="+sATTtypeClass);
	    	else
	    		contentURL.append("type=type_AT_C_GeneralClass");
            
	    	contentURL.append("&ExclusionList=type_ManufacturingPartFamily");
            contentURL.append("&typeChooser=true&nameField=keyin");
            
            if(LibraryCentralConstants.TYPE_DOCUMENT_FAMILY.equals(type)) {
                helpMarker          = "emxhelpcreatecontainerobject";
                pageHeader          = "emxDocumentCentral.Command.CreateDocumentFamily";
            } else if(LibraryCentralConstants.TYPE_GENERAL_CLASS.equals(type)) {
                helpMarker          = "emxhelpcreateclass";
                pageHeader          = "emxLibraryCentral.Shortcut.CreateGeneralClass";
            } else if(DomainConstants.TYPE_PART_FAMILY.equals(type)) {
                helpMarker          = "emxhelpcreatepartfamily";
                pageHeader          = "emxLibraryCentral.Shortcut.CreatePartFamily";
            }
            createJPO           = "emxLibraryCentralCommon:createLBCObject";

        }
        
        if (UIUtil.isNullOrEmpty(parentOId)){
            parentOId = objectId;
        }
        contentURL.append("&parentOID=").append(parentOId);
        contentURL.append("&header=").append(pageHeader);
        contentURL.append("&HelpMarker=").append(helpMarker);
        contentURL.append("&createJPO=").append(createJPO);
        
        contentURL.append("&submitAction=refreshCaller&findMxLink=false&");
        contentURL.append(emxGetQueryString(request));
//Added for External Request #6475 QC 4207 - START		
contentURL.append("&Create InOID="+objectId);
//Added for External Request #6475 QC 4207 - END
        contentURL.append("&postProcessURL=../documentcentral/emxLibraryCentralPostProcess.jsp?");
        contentURL.append("mode=").append(mode);
%>
        <script>
            document.location.href='<xss:encodeForJavaScript><%=contentURL.toString()%></xss:encodeForJavaScript>';
        </script>
<%
    }
    catch (Exception ex)
    {
        ex.printStackTrace();
    }
%>
