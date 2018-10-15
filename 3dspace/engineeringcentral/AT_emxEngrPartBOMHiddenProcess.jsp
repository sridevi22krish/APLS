<%--  emxEngrPartBOMHiddenProcess.jsp  -  Hidden Page
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
   modified as part of ALSTOM - Redmine ticket 6893 - Replace Part in Bom doesn't keep quantity
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIModal.js "></script>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
  String objectId = emxGetParameter(request,"objectId");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String selPartRelId = emxGetParameter(request,"selPartRelId");
  String relType = emxGetParameter(request,"relType");
  String selPartObjectId = emxGetParameter(request,"selPartObjectId");
  String selPartParentOId = emxGetParameter(request,"selPartParentOId");
  String tablemode = emxGetParameter(request,"tablemode");
  String calledMethod      = emxGetParameter(request, "calledMethod");
  String replace = emxGetParameter(request, "replace");
  String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
  int count = selectedItems.length;
  String totalCount = String.valueOf(count);
  String selectedId = "";
  String[] selPartIds = new String[count];
  String hideWithBOMSelection = "false";
        for (int i=0; i < selectedItems.length ;i++)
        {
            selectedId = selectedItems[i];
            //if this is coming from the Full Text Search, have to parse out |objectId|relId|
            StringTokenizer strTokens = new StringTokenizer(selectedItems[i],"|");
            if ( strTokens.hasMoreTokens())
            {
                selectedId = strTokens.nextToken();
                selPartIds[i] = selectedId.trim();
            }
        }
		if(UIUtil.isNotNullAndNotEmpty(tablemode) && tablemode.equals("view") && calledMethod.equals("replaceExisting")){
        	for (int i=0; i < selPartIds.length ;i++)
            {
        		String sState = DomainObject.newInstance(context,selPartIds[i]).getInfo(context, DomainConstants.SELECT_CURRENT);
        		if(sState != null && !sState.equalsIgnoreCase(DomainConstants.STATE_PART_PRELIMINARY)){
        			hideWithBOMSelection = "true";
        			break;
        		}
            }
        }
        if(calledMethod.equals("replaceExisting"))
        {
            session.setAttribute("selPartIds",selPartIds);
        }
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" type="text/javaScript">//<![CDATA[
//XSSOK
var calledMethod = "<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>";
var tablemode = "<%=XSSUtil.encodeForJavaScript(context,tablemode)%>";
var hideWithBOMSelection = "<%=XSSUtil.encodeForJavaScript(context,hideWithBOMSelection)%>";
if(calledMethod == "replaceExisting")
{
//XSSOK
<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>('<%=XSSUtil.encodeForJavaScript(context,objectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartRelId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartObjectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartParentOId)%>','<%=XSSUtil.encodeForJavaScript(context,replace)%>','<%=totalCount%>','<%=XSSUtil.encodeForJavaScript(context,relType)%>');
}
else if(calledMethod == "copyTo")
{
	//XSSOK
<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>('<%=XSSUtil.encodeForJavaScript(context,objectId)%>','<%=XSSUtil.encodeForJavaScript(context,selectedId)%>');
}
else if(calledMethod == "copyFrom")
{
	//XSSOK
<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>('<%=XSSUtil.encodeForJavaScript(context,objectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartRelId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartObjectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartParentOId)%>','<%=XSSUtil.encodeForJavaScript(context,selectedId)%>');
}
else if(calledMethod == "AVLCopyFrom" )
{
	//XSSOK
<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>('<%=XSSUtil.encodeForJavaScript(context,objectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartRelId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartObjectId)%>','<%=XSSUtil.encodeForJavaScript(context,selPartParentOId)%>','<%=XSSUtil.encodeForJavaScript(context,selectedId)%>');
}
function replaceExisting(objectId,selPartRelId,selPartObjectId,selPartParentOId,replace,totalCount,relType)
{
	//REDMINE 7415 QC 4907 - START
    /*var url = "../engineeringcentral/AT_emxEngrBOMReplaceDailogFS.jsp?objectId="+objectId+"&selPartRelId="+selPartRelId+"&selPartObjectId="+selPartObjectId+"&selPartParentOId="+selPartParentOId+"&replaceWithExisting="+replace+"&totalCount="+totalCount+"&relType="+relType;*/
	 var url = "../engineeringcentral/AT_emxEngrBOMReplaceProcess.jsp?objectId="+objectId+"&selPartRelId="+selPartRelId+"&selPartObjectId="+selPartObjectId+"&selPartParentOId="+selPartParentOId+"&replaceWithExisting="+replace+"&totalCount="+totalCount+"&relType="+relType+"&tablemode="+tablemode+"&hideWithBOMSelection="+hideWithBOMSelection+"&radioBOM=replaceWithNoBOM";
	//REDMINE 7415 QC 4907 - END
	
    //showModalDialog(url, 930,650, false);
    getTopWindow().location.href=url;
}

function copyTo(objectId,selectedId)
{
    var url = "../engineeringcentral/emxpartCopyComponentsIntermediateProcess.jsp?objectId="+objectId+"&checkBox="+selectedId;
    //showModalDialog(url, 930,650, false);
    getTopWindow().location.href=url;
}

function copyFrom(objectId,selPartRelId,selPartObjectId,selPartParentOId,selectedId)
{
    var url = "../engineeringcentral/emxEngrBOMCopyFromFS.jsp?objectId="+objectId+"&selPartRelId="+selPartRelId+"&selPartObjectId="+selPartObjectId+"&selPartParentOId="+selPartParentOId+"&checkBox="+selectedId;
    //showModalDialog(url, 930,650, false);
    getTopWindow().location.href=url;
}
function AVLCopyFrom(objectId,selPartRelId,selPartObjectId,selPartParentOId,selectedId)
{
	var url = "../engineeringcentral/emxEngrBOMCopyFromFS.jsp?objectId="+objectId+"&selPartRelId="+selPartRelId+"&selPartObjectId="+selPartObjectId+"&selPartParentOId="+selPartParentOId+"&checkBox="+selectedId+"&AVLReport=TRUE";
    getTopWindow().location.href=url;
}
</script>
