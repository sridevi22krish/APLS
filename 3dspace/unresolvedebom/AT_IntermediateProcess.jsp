 <%--  IntermediateProcess.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%-- Added for X7 - Starts --%>
<%@ page import="com.matrixone.apps.domain.util.i18nNow" %>
<%@ page import="com.matrixone.apps.domain.DomainRelationship" %>
<%@ page import="com.matrixone.apps.unresolvedebom.UnresolvedEBOMConstants" %>
<%@ page import="com.matrixone.apps.unresolvedebom.UnresolvedEBOM" %>

<%
String strPartId = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "objectId"));
String strFrom   = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "From"));
String isWipMode = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "isWipMode"));

//String isWipBomAllowed = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOM.WIPBOM.Allowed");
String isWipBomAllowed = UnresolvedEBOM.isWipBomAllowedForParts(context,strPartId);

String url ="";
boolean blnSucess = false;
boolean blnError = false;
String errorMessage = "";
String strProduct="";
String strProductID="";
String strChangeView="";
String strPolicyClassification = "";
String language  = request.getHeader("Accept-Language");
String calledMethod = emxGetParameter(request, "calledMethod");
Locale Local = context.getLocale();
HashMap programMap = new HashMap();
programMap.put("objectId", strPartId);
boolean blnApply = (Boolean)JPO.invoke(context,"emxENCActionLinkAccess",null,"isApplyAllowed",JPO.packArgs(programMap),Boolean.class);

if (calledMethod == null || "".equals(calledMethod)) {
    blnSucess = true;

    StringList selects   =  new StringList("policy.property[PolicyClassification].value");
    selects.addElement(com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
    DomainObject domPart = new DomainObject(strPartId);
    Map resultMap        = (Map)domPart.getInfo(context,selects);
    
    strPolicyClassification  = (String)resultMap.get("policy.property[PolicyClassification].value");
    String strSessionValue   = (String)session.getAttribute(strPartId);
    String partState         = (String)resultMap.get(com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
    isWipMode                = (UnresolvedEBOMConstants.STATE_PART_PRELIMINARY.equalsIgnoreCase(partState) 
    		                    && "true".equalsIgnoreCase(isWipBomAllowed))?"true":"false";
    		
    if(strSessionValue!=null && !"".equalsIgnoreCase(strSessionValue))
    {
	    if(strSessionValue.indexOf("|")>-1)
	    {
	        StringList strSessionValueList = FrameworkUtil.split(strSessionValue,"|");
	        strChangeView = (String) strSessionValueList.get(0);
	        }
	    }

    } else {
	    DomainObject doProduct = new DomainObject(strPartId);
	    String assignedPartRelId = doProduct.getInfo(context, "relationship["
                                                            +UnresolvedEBOMConstants.RELATIONSHIP_ASSIGNED_PART
                                                            +"].id");
    if (assignedPartRelId == null || "".equals(assignedPartRelId)) {
        if ("addToProduct".equals(calledMethod)) {
            url = "./FullSearchPreProcess.jsp?calledMethod=addToProduct&objectId="+strPartId;
        } else if ("createAndaddToProduct".equals(calledMethod)) {
           
        	/* R211 - Commented as part of Create Part conversion to common Componet */
        	//url = "../engineeringcentral/emxpartCreatePartDialogFS.jsp?fromAction=assignTopLevelPart&objectId="+strPartId;
          
        	/* R211 - Added as part of Create Part conversion to common Componet */
        	url ="../common/emxCreate.jsp?nameField=both&form=type_CreatePart&header=emxFramework.Shortcut.CreatePart&type=type_Part&HelpMarker=emxhelppartcreate&suiteKey=EngineeringCentral&preProcessJavaScript=preProcessInCreateTopPart&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&createMode=assignTopLevelPart&createJPO=emxECPartBase:createPartJPO&sModelId="+strPartId+"&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart";
        } else if ("removeAssignedPart".equals(calledMethod)) {
            blnError = true;
            //errorMessage = i18nNow.getI18nString("emxUnresolvedEBOM.IntermediateProcess.ErrorOnRemove","emxUnresolvedEBOMStringResource", language);
            errorMessage = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource", Local,"emxUnresolvedEBOM.IntermediateProcess.ErrorOnRemove");
        }
    } else {
        if (!"removeAssignedPart".equals(calledMethod)) {
            blnError = true;
            //errorMessage = i18nNow.getI18nString("emxUnresolvedEBOM.IntermediateProcess.ErrorOnCreateOrAddExisiting","emxUnresolvedEBOMStringResource", language);
            errorMessage = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource", Local,"emxUnresolvedEBOM.IntermediateProcess.ErrorOnCreateOrAddExisiting");
        } else {
        	%>
        	<script language="javascript">
        	<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
        	</script>
        	<%
        	
            DomainRelationship.disconnect(context, assignedPartRelId);
            %>
            <script language="javascript">
                parent.document.location.href = parent.document.location.href;
            </script>
            <%
        }
    }
}
%>
<script language="Javascript">
//XSSOK
var isWipMode = "<%=isWipMode%>";

<%
if (blnSucess) {
%>
    <%if(strFrom !=null)
    {
    	if ("CopyFrom".equals(strFrom)) {
%>
    //XSSOK
	sURL = "../common/emxIndentedTable.jsp?expandProgram=emxUnresolvedPart:getUEBOM&hideRootSelection=true&table=PUEUEBOMIndentedSummary&sortDirection=ascending&From=CopyFrom&HelpMarker=emxhelppartbom&PrinterFriendly=true&showApply=false&toolbar=PUEUEBOMChangeToolBar&objectId=<%=strPartId%>&policy=<%=strPolicyClassification%>&suiteKey=UnresolvedEBOM&selection=multiple&PUEUEBOMChangeViewFilter=<%=strChangeView%>&header=emxUnresolvedEBOM.CopyFrom.Header&editRootNode=false&relId=&changeViewFilter=<%=strChangeView%>&submitLabel=emxUnresolvedEBOM.Command.Submit&submitURL=../unresolvedebom/CopyFromPreProcess.jsp&isWipMode="+isWipMode+"&appendURL=ChangeEffectivity|UnresolvedEBOM";
<%
    	} else { 
%>
	//XSSOK
	sURL = "../common/emxIndentedTable.jsp?expandProgram=emxUnresolvedPart:getUEBOM&portalMode=true&hideRootSelection=true&table=PUEUEBOMIndentedSummary&sortDirection=ascending&From=CopyFrom&HelpMarker=emxhelppartbom&PrinterFriendly=true&showApply=false&toolbar=PUEUEBOMChangeToolBar&objectId=<%=strPartId%>&policy=<%=strPolicyClassification%>&suiteKey=UnresolvedEBOM&selection=multiple&PUEUEBOMChangeViewFilter=<%=strChangeView%>&header=emxUnresolvedEBOM.CopyFrom.Header&editRootNode=false&relId=&changeViewFilter=<%=strChangeView%>&submitLabel=emxUnresolvedEBOM.Command.Submit&submitURL=../unresolvedebom/CopyFromPreProcess.jsp&isWipMode="+isWipMode+"&appendURL=ChangeEffectivity|UnresolvedEBOM";
<%}}else{ %>
    //XSSOK
   sURL = "../common/emxIndentedTable.jsp?type=type_Part&preProcessJPO=emxUnresolvedPart:hasProductSelected&expandProgram=emxUnresolvedPart:getUEBOM&freezePane=Name,Revision,RevisionStatus,DetailPopup&portalMode=true&insertNewRow=false&isWipMode="+isWipMode+"&table=PUEUEBOMIndentedSummary&sortDirection=ascending&HelpMarker=emxhelppartbom&PrinterFriendly=true&toolbar=PUEUEBOMToolBar,PUEUEBOMChangeToolBar&fromConfigBOM=true&objectId=<%=strPartId%>&policy=<%=strPolicyClassification%>&suiteKey=UnresolvedEBOM&selection=multiple&PUEUEBOMChangeViewFilter=<%=strChangeView%>&header=emxUnresolvedEBOM.Part.ConfigTableBillOfMaterials&editRootNode=false&changeViewFilter=<%=strChangeView%>&connectionProgram=emxUnresolvedPart:inlineCreateForConfiguredBOM&relType=EBOM&editRelationship=relationship_EBOM&addJPO=addJPO&postProcessJPO=emxUnresolvedPart:updateUnresolvedEBOM&postProcessURL=../engineeringcentral/emxEngrValidateApplyEdit.jsp&appendURL=ChangeEffectivity|UnresolvedEBOM&displayView=tree,details,thumbnail&showApply=<%=blnApply%>&showRMBInlineCommands=true";

<% } %>

     window.location.href = sURL;
 <%
 } else if (blnError) {
 %>
 	//XSSOK
     alert("<%=errorMessage%>");
 <%
     } else  if (!"removeAssignedPart".equals(calledMethod)) {    	 
 %>//XSSOK
         emxShowModalDialog("<%=url%>",520,570,true);
 <%
     }
 %>

</script>
