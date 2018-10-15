<%--  emxRouteMembersSearch.jsp   -  
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
	
   To Redirect to People/Role/Group/Member List search page based on parameters
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxComponentsUtil.inc" %>
<%@ page import="matrix.db.Context,com.matrixone.apps.common.util.ComponentsUIUtil,com.matrixone.apps.framework.ui.UIUtil,com.matrixone.apps.domain.DomainObject,com.matrixone.apps.common.Route,java.util.*,com.matrixone.apps.domain.util.FrameworkException,com.matrixone.apps.domain.util.ENOCsrfGuard" %>
<%!

	private static final String SUBMIT_URL = "../components/AT_emxRouteAddPeopleProcess.jsp";
	private static final String DEFAULT_MEMBERLIST_SEARCH = "../common/emxFullSearch.jsp?showInitialResults=true&field=TYPES=type_MemberList:CURRENT=policy_MemberList.state_Active&table=AEFGeneralSearchResults&selection=multiple&hideHeader=true&mode=Chooser&chooserType=TypeChooser&HelpMarker=emxhelpsearch";
	
	private boolean isALlScope(String scopeId) {
	    return scopeId.equalsIgnoreCase("All");
	}
	
	private boolean isOrganizationScope(String scopeId) {
	    return scopeId.equalsIgnoreCase("Organization");
	}
	
	private void INDENTED_TABLE(StringBuffer buffer) {

	    buffer.append("../common/emxIndentedTable.jsp?");
	    buffer.append("selection=multiple").append('&');
	    buffer.append("expandLevelFilterMenu=false").append('&');
	    buffer.append("customize=false").append('&');
	    buffer.append("Export=false").append('&');
	    buffer.append("multiColumnSort=false").append('&');
	    buffer.append("PrinterFriendly=false").append('&');
	    buffer.append("showPageURLIcon=false").append('&');
	    buffer.append("showRMB=false").append('&');
	    buffer.append("showClipboard=false").append('&');
	    buffer.append("objectCompare=false").append('&');
	    buffer.append("submitLabel=emxFramework.Common.Done").append('&');
	    buffer.append("cancelLabel=emxFramework.Common.Cancel").append('&');
	    buffer.append("cancelButton=true").append('&');
	    buffer.append("displayView=details").append('&');
	    buffer.append("HelpMarker=emxhelpselectgroup").append('&');
	    buffer.append("submitURL=").append(SUBMIT_URL);
	    
	}
	
	//availability has been added by FD11 and parentId has been added by the Custo
	private String getMemberSearchURL(Context context, Map paramMap, String objectId, String scopeId,
			String owningOrganization, String memberType, String fromPage, String action, String availability, String strParentId) throws FrameworkException {	
    StringBuffer buffer = new StringBuffer(300);
	    if("Person".equalsIgnoreCase(memberType)) {
	        buffer.append(getPersonSearchURL(context, scopeId, owningOrganization, availability, strParentId ));
	    } else if("Role".equalsIgnoreCase(memberType)) {
	        buffer.append(getRoleSearchURL(scopeId));
	    } else if("Group".equalsIgnoreCase(memberType)) {
	        buffer.append(getGroupSearchURL(scopeId));
	    } else if("MemberList".equalsIgnoreCase(memberType)) {
	        buffer.append(getMemberListSearchURL(scopeId));
	    } else if("editAccess".equalsIgnoreCase(memberType)) {
	        buffer.append(getEditAccessURL(scopeId));
	    } else {
	        throw new FrameworkException("Invalid memberType:" + memberType);
	    }	
		
	    
	    paramMap.remove("submitURL");
	    paramMap.remove("SubmitURL");
	    paramMap.remove("action");
	    paramMap.remove("HelpMarker");
	    paramMap.remove("helpMarker");
	    paramMap.remove("categoryTreeName");
	    paramMap.remove("toolbar");
	    paramMap.remove("editLink");
	    paramMap.remove("PrinterFriendly");

	    String tokenName = (String)paramMap.get(ENOCsrfGuard.CSRF_TOKEN_NAME);
	    if(UIUtil.isNotNullAndNotEmpty(tokenName)){
	    	paramMap.remove(ENOCsrfGuard.CSRF_TOKEN_NAME);
	    	paramMap.remove(tokenName);
	    }
	    
        for (Iterator iterator = paramMap.keySet().iterator(); iterator.hasNext();) {
            String paramName = (String) iterator.next();
            if(buffer.charAt(buffer.length()-1)=='?'){
            	buffer.append(paramName).append('=').append(paramMap.get(paramName));	
            }else{
            buffer.append('&').append(paramName).append('=').append(paramMap.get(paramName));
        }
	    
        }	    
	    return buffer.toString();
	}

	//availability has been added by FD11 and objectId has been added by the Custo
	private String getPersonSearchURL(Context context, String scopeId, String owningOrganization, String availability, String objectId) throws FrameworkException {
		StringBuffer buffer = new StringBuffer();
		if(isALlScope(scopeId)) {
			if ("Enterprise".equalsIgnoreCase(availability)) {
				buffer.append(ComponentsUIUtil.getPersonSearchFTSURL(getmemberField(context, owningOrganization)));
			} else {
		    Map map = new HashMap(1);
		    map.put("submitURL", SUBMIT_URL);
    	    buffer.append(ComponentsUIUtil.getPersonSearchFTSURL(map));
			}
			
    	} else if(isOrganizationScope(scopeId)) {
			buffer.append(ComponentsUIUtil.getPersonSearchFTSURL(getmemberField(context, owningOrganization)));
    	} else {
	    INDENTED_TABLE(buffer);	
    	    buffer.append("&program=emxRoute:getPersonsInWorkspace").append('&').
    	    append("table=APPPersonSearchResults");			
    	}
		
    	buffer.append("&header=emxComponents.Common.SelectPerson&excludeOIDprogram=emxRoute:excludeLastPromotedUser");	
		System.out.println("\n\n buffer 111 : " + buffer.toString()); 		
    	return buffer.toString();
	}
	
	private String getRoleSearchURL(String scopeId) {
	    StringBuffer buffer = new StringBuffer();
	    INDENTED_TABLE(buffer);   
	    buffer.append('&').
	    append("table=APPRoleSummary").append('&').
	    append("header=emxComponents.AddRoles.SelectRoles").append('&');
    	if(isALlScope(scopeId) || isOrganizationScope(scopeId)) {
    	    buffer.append("program=emxRoleUtil:getRolesSearchResults").append('&');
    	    buffer.append("toolbar=APPRoleSearchToolbar").append('&');
    	}  else {
    	    buffer.append("program=emxRoute:getRolesInWorkspace").append('&');
    	    buffer.append("scopeId=").append(scopeId).append('&');
    	}
    	return buffer.toString();
	}

	private String getGroupSearchURL(String scopeId) {
	    StringBuffer buffer = new StringBuffer();
	    INDENTED_TABLE(buffer);
	    buffer.append('&').
	    append("table=APPGroupSummary").append('&').
	    append("header=emxComponents.AddGroups.SelectGroups").append('&');
    	if(isALlScope(scopeId) || isOrganizationScope(scopeId)) {
    	    buffer.append("program=emxGroupUtil:getGroupSearchResults").append('&');
    	    buffer.append("toolbar=APPGroupSearchToolbar").append('&');
    	}  else {
    	    buffer.append("program=emxRoute:getGroupsInWorkspace").append('&');
    	}
    	return buffer.toString();
	}

	private String getMemberListSearchURL(String scopeId) {
	    StringBuffer buffer = new StringBuffer(300);
    	if(isALlScope(scopeId) || isOrganizationScope(scopeId)) {
    	    buffer.append(DEFAULT_MEMBERLIST_SEARCH).append("&includeOIDprogram=emxMemberList:getAllMemberLists").append('&').
    	    append("&submitURL=").append(SUBMIT_URL);
    	}  else {
    	    	    INDENTED_TABLE(buffer);
    	    buffer.append("&program=emxRoute:getMemberLists").append('&').
    	    append("table=APPMemberList");
    	}
    	return buffer.toString();
	}
	private String getEditAccessURL(String scopeId) {
	    StringBuffer buffer = new StringBuffer();	    
	    buffer.append("emxRouteTemplateEditAccessFS.jsp?");
    	return buffer.toString();
	}
	
	private Map getmemberField(Context context, String owningOrganization) throws FrameworkException {
		Map urlMap = null;
		DomainObject scopeObj = null;
		String memberField = "";
		try {
			scopeObj = new DomainObject(com.matrixone.apps.domain.util.PersonUtil.getUserCompanyId(context));
			memberField = scopeObj.getInfo(context, DomainObject.SELECT_NAME);
			memberField = (owningOrganization.equalsIgnoreCase(memberField)
					|| (UIUtil.isNullOrEmpty(owningOrganization))) ? (memberField) : (owningOrganization);
			urlMap = new HashMap(2);
			urlMap.put("submitURL", SUBMIT_URL);
			urlMap.put("field", "TYPES=type_Person:CURRENT=policy_Person.state_Active:MEMBER=" + memberField);
		} catch (Exception e) {
			throw new FrameworkException(e);
		}
		return urlMap;

	}%>

<%
	
	String objectId  	= emxGetParameter(request,"objectId");
	String scopeId   	= emxGetParameter(request,"scopeId");
	String availability = emxGetParameter(request, "availability");
	String rtState = "";
	String owningOrganization = emxGetParameter(request,"OwningOrganization");
	String strParentId  = emxGetParameter(request,"parentId");
	if(strParentId == null)
	{
		strParentId = "";
	}
	
	String fromPage = emxGetParameter(request, "fromPage");
	String action = emxGetParameter(request, "action");
	String memberType = emxGetParameter(request, "memberType");
	String type ="";
	String revisionAlertMsg = "";
	objectId = UIUtil.isNullOrEmpty(objectId) ? "": objectId;
	scopeId = UIUtil.isNullOrEmpty(scopeId) ? "": scopeId;
	availability = UIUtil.isNullOrEmpty(availability) ? "" : availability;
	owningOrganization = UIUtil.isNullOrEmpty(owningOrganization) ? "": owningOrganization;
	
	DomainObject domObj = DomainObject.newInstance(context);	
	if(!objectId.equals("")) {
	    domObj.setId(objectId);
	    type = domObj.getType(context);
	    rtState =  domObj.getInfo(context,domObj.SELECT_CURRENT);
	    if(scopeId.equals("")){
		    scopeId = domObj.getAttributeValue(context, Route.ATTRIBUTE_RESTRICT_MEMBERS);
	    }
	}
	
	Map paramMap = new HashMap();
    Enumeration eNumParameters = emxGetParameterNames(request);

    while( eNumParameters.hasMoreElements() ) {
    	String strParamName = (String)eNumParameters.nextElement();
    	paramMap.put(strParamName, emxGetParameter(request, strParamName));
    }
    String suiteKey = (String)paramMap.get("suiteKey");
    if(suiteKey == null || "".equals(suiteKey) || "".equals(suiteKey)) {
        paramMap.put("suiteKey", "Components");
    }
	paramMap.remove("program");
	String URL = getMemberSearchURL(context, paramMap, objectId, scopeId, owningOrganization, memberType, fromPage, action, availability, strParentId); 
	
	if(fromPage.equals("RouteAccessSummary") && type.equals("Route Template")){
		revisionAlertMsg = i18nNow.getI18nString("emxComponents.RouteTaskSummary.EditAllMessage", "emxComponentsStringResource",request.getHeader("Accept-Language"));
	}
%>	
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script type="text/javascript">
//XSSOK
var revisionAlertMsg = "<%=revisionAlertMsg%>";
//XSSOK
if(revisionAlertMsg != "" && "<%=rtState%>" != "Inactive" && ! confirm(revisionAlertMsg)){
	window.closeWindow();
}else{
	//XSSOK
	if(<%=fromPage.equals("RouteAccessSummary")%>) {

    showModalDialog("<%=XSSUtil.encodeURLwithParsing(context, URL)%>",800,520, true);    

		} else {

		document.location.href = "<%=XSSUtil.encodeURLwithParsing(context, URL)%>";

		}
   
}
</script>

