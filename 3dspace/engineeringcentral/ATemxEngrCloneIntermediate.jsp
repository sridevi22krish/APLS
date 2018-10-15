 <%--  emxEngrCloneIntermediate.jsp  -  Search dialog frameset
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
   Modification History
   --------------------
   Suresh S; Version 1.0; 11-Apr-2017; Modified for RedMine defect 5805
   Suresh S; Version 1.1; 20-Apr-2017; Modified for RedMine defect 5805
   Suresh S; Version 1.2; 21-Apr-2017; Modified for RedMine defect 5805
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>

<%@page import="matrix.util.MatrixException,com.matrixone.apps.domain.util.SetUtil,java.util.HashMap,java.util.Enumeration,java.util.Vector,java.util.Iterator,matrix.util.StringList,com.matrixone.apps.domain.util.MapList,com.matrixone.apps.framework.lifecycle.CalculateSequenceNumber,com.matrixone.apps.domain.util.PolicyUtil,com.matrixone.apps.domain.util.XSSUtil"%>

<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<%
String strAction="";
String objectId = emxGetParameter(request, "objectId");
String typeStr = emxGetParameter(request,"type");
strAction =emxGetParameter(request,"action");
String parentOID = emxGetParameter(request, "parentOID");
String copyObjectId = emxGetParameter(request, "objectId");
String createMode    = emxGetParameter(request, "createMode");
String cloningBehaviour = emxGetParameter(request, "cloningBehaviour");
String pfId = null;
String pfAutoNameGenerator = "FALSE";
String sFromPartProperty = "true";
String sSubmitAction = "treePopup";
//String emxTableRowIds[]     =(String[]) emxGetParameterValues(request, "emxTableRowId");
String sCurrentRowId = "";
if(createMode !=null && (!"null".equals(createMode)) && createMode.equals("PartProperties"))
{
	sCurrentRowId = copyObjectId;
    sSubmitAction = "refreshCaller";	
}
else
{
	String checkBoxId[] = emxGetParameterValues(request, "emxTableRowId");
		if(checkBoxId != null) {
			
			String objectIdList[] = new String[checkBoxId.length];
			

			for (int i = 0; i < checkBoxId.length; i++) {
				
				StringTokenizer st = new StringTokenizer(checkBoxId[i], "|");
				String sObjId = st.nextToken();
				sCurrentRowId = sObjId;
				
				while (st.hasMoreTokens()) {
					sObjId = st.nextToken();
				}
			}
				
		}
		sFromPartProperty = "False";
}

copyObjectId = sCurrentRowId;
objectId = sCurrentRowId;

String sTypeObjectId = "Part";
String sSymbolicPolicyObjectId = "policy_ECPart";
if (copyObjectId != null && !"null".equals(copyObjectId) && !"".equals(copyObjectId)) {
	DomainObject domObj = DomainObject.newInstance(context, copyObjectId);
	
	sTypeObjectId = domObj.getInfo(context, DomainConstants.SELECT_TYPE);
	sSymbolicPolicyObjectId = FrameworkUtil.getAliasForAdmin(context, "policy", domObj.getInfo(context, DomainConstants.SELECT_POLICY), true);
		
	if(sTypeObjectId != null && sTypeObjectId.equals("AT_C_STANDARD_PART")){
		%>
		<script language="Javascript">
			alert("Standard part can not be cloned");
			window.close();
		</script>
		<%
		return;
	}
	
	
	String SELECT_PARTFAMILY_ID = "to[" + DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM + "].from.id";
    String SELECT_PARTFAMILY_NAME_GENERATOR_ON = "to[" + DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM + "].from.attribute[" + DomainConstants.ATTRIBUTE_PART_FAMILY_NAME_GENERATOR_ON + "]";
    
    StringList objectselect = new StringList(2);
    objectselect.add(SELECT_PARTFAMILY_ID);
    objectselect.add(SELECT_PARTFAMILY_NAME_GENERATOR_ON);
    
    Map infoMap = domObj.getInfo(context, objectselect);
    pfId = (String) infoMap.get(SELECT_PARTFAMILY_ID);           
    pfAutoNameGenerator = (String) infoMap.get(SELECT_PARTFAMILY_NAME_GENERATOR_ON);
    
    if (pfAutoNameGenerator == null) {
    	pfAutoNameGenerator = "false";
    }
}

if(strAction==null){
    strAction="";
}
DomainObject domPartObj = new DomainObject(objectId);
String srcObjType = domPartObj.getInfo(context, com.matrixone.apps.domain.DomainConstants.SELECT_TYPE);
String symbolicName = com.matrixone.apps.domain.util.FrameworkUtil.getAliasForAdmin(context,"type",srcObjType,true);
if(strAction.equals("PartClone")){
    response.setHeader("Cache-Control", "no-cache");
    response.getWriter().write("@"+symbolicName+"@");   
}
String selectedObjectType= "_selectedType:"+srcObjType+",type_Part";
%>
<script language="Javascript">
var isFromPartFamilyNav = "false";
var cloningBehaviour = "<%=cloningBehaviour%>";
try {
	//XSSOK
	var bCallSubmit       = '<%=XSSUtil.encodeForJavaScript(context,strAction)%>';
	var isFromPartFamily  = false;
	var vbreadCrumArray   = getTopWindow().getWindowOpener().getTopWindow()?getTopWindow().getWindowOpener().getTopWindow().bclist.getCurrentBreadCrumbTrail().getBreadCrumbArray():"";
	if (vbreadCrumArray.length >= 2) {
		isFromPartFamilyNav = "true"; 
	   //var parentOID       = vbreadCrumArray[vbreadCrumArray.length - 2 ].id;
	  
	}
    //var finalSubmitAction = (isFromPartFamily && isFromPartFamily.indexOf("true") > -1)?"refreshCaller":"treeContent";
    //var isFromPartFamilyNav = (isFromPartFamily.indexOf("true") > -1) ? "true" : "false";
    
}
catch (e) {
   alert(e.message);
}
if ((bCallSubmit=="") || (bReload==null)){
    
    
    //Modified for To Create Multiple part from Part Clone
    
// Modified for REQ03.047 - Insert part from classification - START

if("ClassificationSlideIn"=="<%=createMode%>"){

// Modified for External Request #6615 QC - 4685 - START
	//Replace sTypeObjectId by selectedObjectType as in FD11
	sURL = "../common/emxCreate.jsp?showPolicy=false&policy=<%=sSymbolicPolicyObjectId%>&formFieldsOnly=true&submitAction=treePopup&ReloadOpener=true&nameField=autoName&header=emxEngineeringCentral.Part.ClonePart&form=ATENCClonePart&suiteKey=EngineeringCentral&multiPartCreation=true&HelpMarker=emxhelppartclone&copyObjectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&type=type_<%=selectedObjectType%>&postProcessJPO=emxPart:postProcessForClonePart&preProcessJavaScript=preProcessInCreatePartClone&TypeActual=<%=sTypeObjectId%>&createJPO=emxPart:ATcheckLicenseAndCloneObject&partFamilyID=<%=pfId%>&PartFamilyAutoName=<%=pfAutoNameGenerator%>&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp?mode=clonedPartOpenInEditMode&emxTableRowId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&fromPartFamilyNav=" + isFromPartFamilyNav;
// Modified for External Request #6615 QC - 4685 - END
//Modified as part of ALSTOM Customization for fixing ticket - 6366 - start
}
else{
// Modified for REQ03.047 - Insert part from classification - END    
	//XSSOK
	//Modified as part of ALSTOM Customization for fixing ticket - 6366 - start
    //sURL = "../common/emxCreate.jsp?showPolicy=false&policy=<%=sSymbolicPolicyObjectId%>&formFieldsOnly=true&fromPartProperties=true&submitAction=doNothing&nameField=autoName&header=emxEngineeringCentral.Part.ClonePart&form=ATENCClonePart&suiteKey=EngineeringCentral&multiPartCreation=true&HelpMarker=emxhelppartclone&copyObjectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&type=type_<%=sTypeObjectId%>&postProcessJPO=emxPart:postProcessForClonePart&preProcessJavaScript=preProcessInCreatePartClone&TypeActual=<%=sTypeObjectId%>&createJPO=emxPart:ATcheckLicenseAndCloneObject&partFamilyID=<%=pfId%>&PartFamilyAutoName=<%=pfAutoNameGenerator%>&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp?mode=clonedPartOpenInEditMode&emxTableRowId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&fromPartFamilyNav=" + isFromPartFamilyNav;
    //version 1.0 start
	if(cloningBehaviour != null && cloningBehaviour != "null"){
		sURL = "../common/emxCreate.jsp?showPolicy=false&policy=<%=sSymbolicPolicyObjectId%>&formFieldsOnly=true&fromPartProperties=<%=sFromPartProperty%>&submitAction=<%=sSubmitAction%>&nameField=autoName&header=emxEngineeringCentral.Part.ClonePart&form=ATENCAdvancedDuplicatePart&customParameter=EBOMAdvancedDuplication&suiteKey=EngineeringCentral&multiPartCreation=true&HelpMarker=emxhelppartclone&copyObjectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&type=type_<%=selectedObjectType%>&postProcessJPO=emxPart:postProcessForClonePart&preProcessJavaScript=preProcessInCreatePartClone&TypeActual=<%=sTypeObjectId%>&createJPO=emxPart:ATcheckLicenseAndCloneObject&partFamilyID=<%=pfId%>&PartFamilyAutoName=<%=pfAutoNameGenerator%>&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp?mode=clonedPartOpenInEditMode&emxTableRowId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&fromPartFamilyNav=" + isFromPartFamilyNav;
	}else{
		sURL = "../common/emxCreate.jsp?showPolicy=false&policy=<%=sSymbolicPolicyObjectId%>&formFieldsOnly=true&fromPartProperties=<%=sFromPartProperty%>&submitAction=<%=sSubmitAction%>&nameField=autoName&header=emxEngineeringCentral.Part.ClonePart&form=ATENCClonePart&suiteKey=EngineeringCentral&multiPartCreation=true&HelpMarker=emxhelppartclone&copyObjectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&type=type_<%=selectedObjectType%>&postProcessJPO=emxPart:postProcessForClonePart&preProcessJavaScript=preProcessInCreatePartClone&TypeActual=<%=sTypeObjectId%>&createJPO=emxPart:ATcheckLicenseAndCloneObject&partFamilyID=<%=pfId%>&PartFamilyAutoName=<%=pfAutoNameGenerator%>&postProcessURL=../engineeringcentral/AT_PartCreatePostProcess.jsp?mode=clonedPartOpenInEditMode&emxTableRowId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&fromPartFamilyNav=" + isFromPartFamilyNav;
	}
    //version 1.0 End
	//Modified as part of ALSTOM Customization for fixing ticket - 6366 - end
   //XSSOK 
// Modified for REQ03.047 - Insert part from classification - START
}
// Modified for REQ03.047 - Insert part from classification - END
   if("MFG"=="<%=XSSUtil.encodeForJavaScript(context,createMode)%>"){
	   sURL = sURL+"&createMode=MFG";
	   sURL = sURL+"&HelpMarker=emxmfgpartclonedetails";
    }
   else
	   {
	   sURL = sURL+"&createMode=ENG";
	   sURL = sURL+"&HelpMarker=emxhelppartclone";
	   }
    window.location.href = sURL;
}
</script>