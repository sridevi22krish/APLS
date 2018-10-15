<%@include file = "emxTagLibInclude.inc"%>
<%@include file = "emxContentTypeInclude.inc"%>
<%@include file = "emxRequestWrapperMethods.inc"%>
<%@ page import="matrix.db.*, matrix.util.*, com.matrixone.servlet.*, java.text.* ,java.util.* , java.net.URLEncoder, com.matrixone.apps.domain.util.*, com.matrixone.apps.framework.ui.UINavigatorUtil, com.matrixone.apps.framework.taglib.*"  %>

<emxUtil:localize id="i18nId" bundle="emxFrameworkStringResource" locale='<%= request.getHeader("Accept-Language") %>' />
<!DOCTYPE html>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />

<%
String objectId = emxGetParameter(request, "objectId");
String fileName = emxGetParameter(request, "fileName");
String fileFormat = emxGetParameter(request, "fileFormat");
String url = "AT_emxAutoLogin.jsp?objectId="+objectId+"&fileName="+XSSUtil.encodeForURL(fileName)+"&fileFormat="+fileFormat;
%>

<html>
	<body onload=loginAndDownloadFile('<%=url%>')>
	</body>
	<script type="text/javascript">
		var loginAndDownloadFile = function(url){
			document.location.href=url;
		}
	</script>
</html>



