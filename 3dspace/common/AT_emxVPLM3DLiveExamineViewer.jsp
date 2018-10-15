<%--  emxVPLMPublicAttributes.jsp   -   page for Public attributes of VPLMEntities
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxVPLMLogon.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $
   Wk2  2013- RCI - RI 202511 - Reprise gestion ctx : remplacer getMainContext par getFrameContext
   Wk22 2013- RCI - RI 207033 - IE diplay
   Wk29 2013- RCI - Highlight - Sigle Sign On
   Wk29 2013- XEW - 13:11:06 - IR-263268V6R2014x: "3DLive Examine on product DS web connection -> geometry display KO" - Changed "?Token=" to "&Token=" 
  --%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.HashMap"%>
<%@ page import = "java.util.Set" %>
<%@ page import = "matrix.db.*" %>
<%@ page import = "java.util.ArrayList" %>
<%@ page import = "java.util.List" %>
<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMDebugUtil" %>
<%@ page import = "com.dassault_systemes.vplm.interfaces.access.IPLMxCoreAccess" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.PLMCoreModelerSession" %>
<%@ page import = "com.dassault_systemes.vplm.data.PLMxJResultSet" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.entity.PLMxReferenceEntity" %>
<%@ page import = "com.dassault_systemes.vplm.productNav.interfaces.IVPLMProductNav" %>
<%@ page import = "com.dassault_systemes.Tools.VPLMJLogStreamUnstream"%>
<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMJWebToolsM1Util" %>
<%@ page import = "com.dassault_systemes.Tools.VPLMJWebToolsServices" %>

<%@ page import = "com.dassault_systemes.plmsecurity.ticket.LoginTicketServices" %>
<%@ page import = "com.dassault_systemes.plmsecurity.ticket.LoginTicket" %>

<%@  page  import  =  "java.net.URLEncoder"  %> 
<%@  page  import  =  "com.matrixone.apps.domain.DomainObject"  %> 

<%@include file = "../emxUIFramesetUtil.inc"%>

<!DOCTYPE html>
<html style="height: 100%; overflow: hidden;">
<head>
<script language="javascript" src="../components/ENOVIA3DLiveExamine.js"></script>
<script language="javascript" src="../components/ENOVIA3DLiveExamineExtension.js"></script>

<%
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	//VPLMDebugUtil.dumpObject(requestMap); 
		
	
    String objectId     = (String)emxGetParameter(request, "objectId");
	Context frameCtx = Framework.getFrameContext(session);
	try
	{
	String mcsURL = Framework.getFullClientSideURL(request, response, "");
	
	VPLMJWebToolsServices URLBuilderServices = VPLMJWebToolsServices.getServicesInstance();
	String embedURL = URLBuilderServices.M1IdTo3DLiveURL(frameCtx, objectId, mcsURL);
			
	// SSO dev
	String role = frameCtx.getRole();
	if ( role !=null && role.startsWith("ctx::")) role = role.substring(5);
			
	LoginTicket tk = LoginTicketServices.requireLoginTicket(frameCtx, null,role,null, null, 1, null);
	String sToken = tk.getToken();
	
	DomainObject dom=new DomainObject(objectId);
	String typeObj = dom.getInfo(frameCtx, "type");
	
	embedURL = embedURL + "&Token=" + sToken;
	
	//Start - QC4939 [Add custo drawingType Check]
	if(typeObj.equals("Drawing") || typeObj.equals("AT_ENG_DRAWING")){
		embedURL = embedURL + "&Type=2DCGM" ;
	}
	//End - QC4939 [Add custo drawingType Check]
	
System.out.println("embedURL="+embedURL);
			
%>
<body style="height: 100%; margin: 0px;" onload="javascript:createViewer('divImage', 'viewer', '../components', '<%=embedURL%>')">
  <div id="divImage" name="divImage"style="width:100%;height:100%;" >
  </div>
</body>
<%
}
	finally
	{
		frameCtx.shutdown();
	}
	
%>
</head>
</html>
