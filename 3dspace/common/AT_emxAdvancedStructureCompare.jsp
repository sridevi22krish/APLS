<%--  emxStructureCompareAdvanced.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>


<%


String strObjectId1 = "";
String strObjectId2 = "";
String contentURL = "";
boolean isPortalDispaly = false;
String objSelectLimitMsg = "";

String suiteKey = emxGetParameter(request,"suiteKey");
String targetLocation = emxGetParameter(request,"targetLocation");
String helpMarker = emxGetParameter(request,"HelpMarker");
String AppSuiteKey = emxGetParameter(request,"AppSuiteKey");
String strHeader = emxGetParameter(request,"header");
String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
int intNumRows = 0;
String strLanguage = request.getHeader("Accept-Language");
String scTimeStamp = emxGetParameter(request,"SCTimeStamp");

String strResourceFile = UINavigatorUtil.getStringResourceFileId(context,suiteKey);

String strSCHeader =    "emxFramework.Common.StructureCompare";
String cellWrap = emxGetParameter(request,"cellwrap");
cellWrap = UITableIndented.getSBWrapStatus(context, cellWrap);

String expandFilter = emxGetParameter(request,"expandFilter");
String showDiffIcon = emxGetParameter(request,"diffCodeIcons");
String summaryIcons = emxGetParameter(request,"summaryIcons");

if(UIUtil.isNullOrEmpty(strHeader))
{
    strHeader = strSCHeader;
}
  
if (tableRowIdList!= null)
{
    intNumRows = tableRowIdList.length;
    if (intNumRows > 2)
    {
        objSelectLimitMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(strLanguage), "emxFramework.FreezePane.SBCompare.SelectMinObjects");
    }
}


if(UIUtil.isNullOrEmpty(objSelectLimitMsg))
{

    String fromContext  = emxGetParameter(request,"fromContext");
    String strForm      = emxGetParameter(request,"form");
    String strSubmitURL = emxGetParameter(request,"submitURL");
    String strTable     = emxGetParameter(request,"table");
    String selectedTable            =   emxGetParameter(request, "selectedTable");
    String userTable = emxGetParameter(request, "userTable");
    
    if(Boolean.parseBoolean(userTable)  && UIUtil.isNotNullAndNotEmpty(selectedTable)){    	
    	selectedTable = UITableCustom.getSystemTableName(context, selectedTable);
    }
     if(strTable == null){
         strTable           =   selectedTable;
     }
    String strObjId     = emxGetParameter(request,"objectId");
    
    
    String strRel               =   emxGetParameter(request, "relationship");
    String strDir               =   emxGetParameter(request, "direction"); 
    String strExpandProgram     =   emxGetParameter(request, "expandProgram");
    
    String strconnectionProgram  =  emxGetParameter(request, "connectionProgram");
    
    StringBuffer appendURL = new StringBuffer();
    appendURL.append("&relationship=");appendURL.append(strRel);
    appendURL.append("&direction=");appendURL.append(strDir);
    appendURL.append("&toolbar=AEFStructureCompareToolbar");
    appendURL.append("&connectionProgram=");appendURL.append(strconnectionProgram);
    appendURL.append("&expandProgram=");
    appendURL.append(strExpandProgram);
    boolean isBPSStructureCompareReport = (UIUtil.isNullOrEmpty(strForm) && UIUtil.isNullOrEmpty(strSubmitURL)) ? true : false;
    

    if (tableRowIdList!= null)
    {
        intNumRows = tableRowIdList.length;
        
        if (intNumRows == 2)
        {
            String strRowInfo = tableRowIdList[0];
            StringList strlRowInfo = FrameworkUtil.split(strRowInfo, "|");
           
            if (strlRowInfo.size() == 3)
            {
                strObjectId1 = (String) strlRowInfo.get(0);
            }
            else
            {
                strObjectId1 = (String) strlRowInfo.get(1);
            }
    
            strRowInfo = tableRowIdList[1];
            strlRowInfo = FrameworkUtil.split(strRowInfo, "|");
            if (strlRowInfo.size() == 3)
            {
                strObjectId2 = (String) strlRowInfo.get(0);
            }
            else
            {
                strObjectId2 = (String) strlRowInfo.get(1);
            }
        }
        else if (intNumRows == 1)
        {
            String strRowInfo = tableRowIdList[0];
            StringList strlRowInfo = FrameworkUtil.split(strRowInfo, "|");
    
            if (strlRowInfo.size() == 3)
            {
                strObjectId1 = (String) strlRowInfo.get(0);
            }
            else
            {
                strObjectId1 = (String) strlRowInfo.get(1);
            }
        }
    }
    
    if(UIUtil.isNullOrEmpty(strObjectId2))
    {
        strObjectId2 = emxGetParameter(request,"objectId2");
    }
    
    if(UIUtil.isNullOrEmpty(strObjectId1))
    {
        strObjectId1 = emxGetParameter(request,"objectId1");
    }
    
    if (strObjectId1 == null)
    {
        strObjectId1 = emxGetParameter(request,"objectId");
    }
    
    String objIDs = strObjectId1 + "," + strObjectId2 + "," + strObjId;
    
    if(UIUtil.isNullOrEmpty(scTimeStamp))
    {
        scTimeStamp = UIComponent.getTimeStamp()+"";
    }
    
    //When invoked from Channel commands
    if(!UIUtil.isNullOrEmpty(fromContext))
    {
        if(isBPSStructureCompareReport)
        {
			contentURL = "../common/emxStructureCompare.jsp?suiteKey=Framework&SCTimeStamp="+XSSUtil.encodeForJavaScript(context,scTimeStamp)+"&rowGrouping=false&SuiteDirectory=common&StringResourceFileId=emxFrameworkStringResource&objectId="+XSSUtil.encodeForJavaScript(context,strObjId)+"&objectId1="+XSSUtil.encodeForJavaScript(context,strObjectId1)+"&objectId2="+XSSUtil.encodeForJavaScript(context,strObjectId2)+"&table="+XSSUtil.encodeForJavaScript(context,strTable)+"&objIDs="+objIDs+appendURL.toString()+"&HelpMarker="+XSSUtil.encodeForJavaScript(context,helpMarker)+"&cellwrap="+XSSUtil.encodeForJavaScript(context,cellWrap);
        }
        else
        {
            if(null != AppSuiteKey)
            {
                suiteKey = AppSuiteKey;
            }

			String strPostProcessURL = "../common/emxStructureCompareIntermediate.jsp?rowGrouping=false&cellwrap="+XSSUtil.encodeForJavaScript(context,cellWrap);
			//Modified for REQ11.025 - START
            contentURL = "../common/emxForm.jsp?form="+XSSUtil.encodeForJavaScript(context,strForm)+"&formFieldsOnly=true&SCTimeStamp="+XSSUtil.encodeForJavaScript(context,scTimeStamp)+"&submitMultipleTimes=true&submitLabel=Apply&hideCancel=true&resetForm=true&mode=Edit&submitAction=refreshCaller&postProcessURL="+strPostProcessURL+"&suiteKey="+XSSUtil.encodeForJavaScript(context,suiteKey)+"&findMxLink=false&showClipboard=false&IsStructureCompare=true&objectId1="+XSSUtil.encodeForJavaScript(context,strObjectId1)+"&objectId2="+XSSUtil.encodeForJavaScript(context,strObjectId2)+"&objectId="+XSSUtil.encodeForJavaScript(context,strObjectId1)+"&preProcessJavaScript=preProcessInBOMCompare&portalMode=true&hideLaunchButton=true"+"&submitURL="+XSSUtil.encodeForJavaScript(context,strSubmitURL)+"&HelpMarker="+XSSUtil.encodeForJavaScript(context,helpMarker);
            //Modified for REQ11.025 - END        
        }
    }
    else //Invoke the Portal
    {
        if(isBPSStructureCompareReport)
        {
            isPortalDispaly = true;
            String sQueryForBPS = "";

            Map requestMapToSubmit = UINavigatorUtil.getRequestParameterMap(request);

            java.util.Set ketSet = requestMapToSubmit.keySet();
            Iterator itrKey = ketSet.iterator();
            
            while(itrKey.hasNext()) {
                String sKey = (String)itrKey.next();
                String sVal = "";
                try {
                    sVal = (String)requestMapToSubmit.get(sKey);
                } catch (Exception e) {
                    //Do nothing
                } if(!sVal.equals("")) {
                    sQueryForBPS += sKey+"="+sVal+"&";
                }
            }
            sQueryForBPS = sQueryForBPS.substring(0, sQueryForBPS.length()-1);
            
            %>
                <input type="hidden" name="urlParameters" value="<xss:encodeForHTMLAttribute><%=sQueryForBPS%></xss:encodeForHTMLAttribute>" />
            <%
                
            contentURL = "../common/emxPortal.jsp?SCTimeStamp="+XSSUtil.encodeForJavaScript(context,scTimeStamp)+"&portal=AEFStructureComparePortal&header="+XSSUtil.encodeForJavaScript(context,strSCHeader)+"&suiteKey=Framework&SuiteDirectory=common&StringResourceFileId=emxFrameworkStringResource&objectId1="+XSSUtil.encodeForJavaScript(context,strObjectId1)+"&objectId2="+XSSUtil.encodeForJavaScript(context,strObjectId2)+"&table="+XSSUtil.encodeForJavaScript(context,strTable)+"&objIDs="+objIDs+"&objectId="+XSSUtil.encodeForJavaScript(context,strObjId)+appendURL.toString()+"&selectedTable="+selectedTable+"&HelpMarker="+XSSUtil.encodeForJavaScript(context,helpMarker);
        }
        else
        {
            isPortalDispaly = true;
            contentURL = "../common/emxPortal.jsp?SCTimeStamp="+XSSUtil.encodeForJavaScript(context,scTimeStamp)+"&portal=AEFStructureComparePortal&header="+XSSUtil.encodeForJavaScript(context,strHeader)+"&AppSuiteKey="+XSSUtil.encodeForJavaScript(context,suiteKey)+"&suiteKey="+XSSUtil.encodeForJavaScript(context,suiteKey)+"&objectId1="+XSSUtil.encodeForJavaScript(context,strObjectId1)+"&objectId2="+XSSUtil.encodeForJavaScript(context,strObjectId2)+"&form="+XSSUtil.encodeForJavaScript(context,strForm)+"&submitURL="+XSSUtil.encodeForJavaScript(context,strSubmitURL)+"&HelpMarker="+XSSUtil.encodeForJavaScript(context,helpMarker);

        }
       
    }
    
    if(UIUtil.isNotNullAndNotEmpty(expandFilter)){
    	contentURL +="&expandFilter="+expandFilter;
    }
    
    if(UIUtil.isNotNullAndNotEmpty(showDiffIcon)){
    	contentURL +="&diffCodeIcons="+showDiffIcon;
    }
    
    if(UIUtil.isNotNullAndNotEmpty(summaryIcons)){
    	contentURL +="&summaryIcons="+summaryIcons;
    }
}
%>

<script language="JavaScript" type="text/javascript">

//XSSOK
var isPortalDispaly = "<%=isPortalDispaly%>";
var targetLocation = "<xss:encodeForJavaScript><%=targetLocation%></xss:encodeForJavaScript>";

if("<%=objSelectLimitMsg %>" != "")
{
    alert("<%=objSelectLimitMsg %>");
}
else
{
    if(isPortalDispaly == "true")
    {
        if(null !=targetLocation && targetLocation == "content") {
            var contentFrame = findFrame(parent.getTopWindow(),"content");
            if(contentFrame) {
            	//XSSOK
            contentFrame.location.href='<%=contentURL%>';   
            }
        } else {
        	//XSSOK
        showAndGetNonModalDialog("<%=contentURL%>", "Max", "Max", "true");
        }
        
    }
    else
    {
    	//XSSOK
        document.location.href='<%=contentURL%>';
    }
}
</script>


