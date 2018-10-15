<%--  AT_emxFileDownload.jsp
  Copyright (c) 1992-2013 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = $Id: emxImportLogFileDownLoad.jsp.rca 1.1.4.4 Wed Oct 22 15:48:22 2008 przemek Experimental przemek $
--%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.PrintWriter"%>
<%@page
	import="com.matrixone.apps.domain.util.FrameworkUtil,com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="java.util.logging.Logger"%>
<%@page import="java.util.logging.Level"%>
<%@page import="java.util.logging.Handler"%>
<%@page import="java.util.logging.FileHandler"%>
<%@page import="java.util.logging.SimpleFormatter"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow" %>
<%@page import="com.matrixone.apps.domain.DomainConstants" %>
<%@include file="emxNavigatorBaseInclude.inc"%>

<%@ page
	import="matrix.db.*, matrix.util.*, com.matrixone.servlet.*, java.text.* ,java.util.* , java.net.URLEncoder, com.matrixone.apps.domain.util.*, com.matrixone.apps.framework.ui.UINavigatorUtil, com.matrixone.apps.framework.taglib.*"%>

<%

	i18nNow i18nNowInstance = new i18nNow();
	String fileFormat =emxGetParameter(request, "fileFormat"); 
    String logFormat = PropertyUtil.getSchemaProperty(context, "format_"+fileFormat);
    String fileName = emxGetParameter(request, "fileName");
	String objectId = emxGetParameter(request, "objectId");
	String url = "emxLogin.jsp?objectId="+objectId+"&fileName="+XSSUtil.encodeForURL(fileName);
	
	
	%>
	
	<html>
	<body >
	<button onclick="loginAndDownloadFile()">Click me</button>
	
	<script type="text/javascript">
	function loginAndDownloadFile() {
		document.location.href="<%=url%>";
}
		
	</script>
	</body>
</html>
	
	<%boolean isUserAgentContextActivated = false;
	String strDocName = "None";
		   
	try{
		String PERSON_USERAGENT = PropertyUtil.getSchemaProperty("person_UserAgent");

		ContextUtil.pushContext(context, PERSON_USERAGENT, null, null);
		isUserAgentContextActivated = true;
		
    	DomainObject doDoc = DomainObject.newInstance(context, objectId);
		
	    if(doDoc != null){
	    	
	    	strDocName = doDoc.getInfo(context, DomainConstants.SELECT_NAME);
			
		    if(fileName != null && !fileName.isEmpty()){
			    
		    	String workspace = context.createWorkspace();
			    
			    if(workspace != null && !workspace.isEmpty()){
			    	
				    java.io.File file = new java.io.File(workspace + java.io.File.separator + fileName);
				    
				    try{
				    	
				    	doDoc.checkoutFile(context, false, logFormat, fileName, workspace);
				    				    	
				        FileInputStream fis = new FileInputStream(file);
				        response.setHeader ("Content-Disposition", "attachment;filename=\"" + file.getName() + "\"");
				        response.setHeader ("Content-Type", "application/octet-stream");
	
				        PrintWriter output = response.getWriter();
	
				        int i;   
				        while ((i=fis.read()) != -1) {  
				        	output.write(i);
				        }   
				        fis.close();
				        output.flush();
				        output.close();
				    	
				       
						
				    }catch(Exception e) {
						System.out.println("Exception1 file download "+e.getMessage());
				   		    	
				    }
				}else{
					//logger.log(Level.SEVERE, strWorkspaceNullOrEmpty);
				}	    
		    }else{
		    	//logger.log(Level.SEVERE, strFileParamNullOrEmpty);
		    }
	    }else{
	    	//logger.log(Level.SEVERE, strDocParamNullOrEmpty);
	    }
	}catch(Exception e){
		System.out.println("Exception file download "+e.getMessage());
	}finally{
    	if (isUserAgentContextActivated) {

			ContextUtil.popContext(context);

		}
	}

%>

