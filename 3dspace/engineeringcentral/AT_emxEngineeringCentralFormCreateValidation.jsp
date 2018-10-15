<%--  emxEngineeringCentralFormCreateValidation.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file="emxDesignTopInclude.inc"%>
<%@include file="../common/scripts/emxJSValidationUtil.js"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.enovia.bom.ReleasePhase"%>
var fromPreProcess = false;
var STR_DEC_SYM = "<%=FrameworkProperties.getProperty(context, "emxFramework.DecimalSymbol")%>";
<%
    //MFG
    String mfgPartType = PropertyUtil.getSchemaProperty(context,"type_ManufacturingPart");
    boolean isMBOMInstalled = EngineeringUtil.isMBOMInstalled(context);
    String languageStr = context.getSession().getLanguage();        
    boolean partFamilyNameGen = false;
	//Multitenant
    //String strLangPartFamily = i18nNow.getI18nString("emxEngineeringCentral.Common.PartFamily",   "emxEngineeringCentralStringResource",languageStr);
    String strLangPartFamily =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.PartFamily");
//Added for Planning MBOM-Planning Required--Start
    String planningRequiredYesOption = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource",  new Locale("en"), "emxFramework.Range.Planning_Required.Yes");
    String planningRequiredNoOption = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale("en"), "emxFramework.Range.Planning_Required.No");
    String planningRequiredAlert = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.PLBOM.PLReqAlert");
    String endItemYesOption = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale("en"), "emxFramework.Range.End_Item.Yes" );
    String endItemNoOption = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", new Locale("en"), "emxFramework.Range.End_Item.No");
    
    String sProductValidation1 =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Form.ValidateProductField1");
	String sProductValidation2 =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Form.ValidateProductField2");
	
	//WP7 QC4697 START
	String sATSymmetryWarning =EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"AT.Symmetry.Warning");
	//WP7 QC4697 END
	
    String planningRequiredDefOption = "";
    if(isMBOMInstalled)
    { 		
    	planningRequiredDefOption =          EnoviaResourceBundle.getProperty(context, "emxMBOM.PlanningMBOM.Planning_Required.DefaultValue");
    	
    	
    }
    //Added for Planning MBOM-Planning Required--End
    
        BusinessType partBusinessType = new BusinessType(DomainConstants.TYPE_PART, context.getVault());
        partBusinessType.open(context);
        PolicyList allPartPolicyList = partBusinessType.getPoliciesForPerson(context,false);
        partBusinessType.close(context);
        PolicyItr  partPolicyItr  = new PolicyItr(allPartPolicyList);
        HashMap policyMap = new HashMap();
        while(partPolicyItr.next())
        {
            Policy policyValue1 =  (Policy)partPolicyItr.obj();
            String policyValueName1 = policyValue1.getName();
            String policyClassification1 = EngineeringUtil.getPolicyClassification(context,policyValueName1);
            policyMap.put(policyValueName1,policyClassification1);
            
        }
        
    //Added for BGTP to decide Rev of part from policy during part creation
    String sDevPartSequence=MqlUtil.mqlCommand(context,"print policy $1 select $2 dump",EngineeringConstants.POLICY_DEVELOPMENT_PART,"minorsequence");
    StringList sequence = FrameworkUtil.split(sDevPartSequence, ",");
   	String sequenceOfDevPart = (String)sequence.get(0);
   	
    String sECPartSequence=MqlUtil.mqlCommand(context,"print policy $1 select $2 dump",EngineeringConstants.POLICY_EC_PART,"minorsequence");
    StringList sECSequence = FrameworkUtil.split(sECPartSequence, ",");
   	String sequenceOfECPart = (String)sECSequence.get(0);
   	
   	StringList slPhaseList = ReleasePhase.getPhaseListForType(context, DomainConstants.TYPE_PART);
   	String sChangeCotrolledValue = "{";
   	for(int i=0; i<slPhaseList.size();i++ ){
   		sChangeCotrolledValue = sChangeCotrolledValue +"\""+ (String)slPhaseList.get(i) +"\":\""+ ReleasePhase.getChangeControlled(context, (String)slPhaseList.get(i))+"\",";
   	}
   	sChangeCotrolledValue = sChangeCotrolledValue+"}";    
%>
function isNumericGeneric(fieldObj)
{
	var decSymb 	= STR_DEC_SYM;
	var varValue = fieldObj;
	var isDot 		= varValue.indexOf(".") != -1;
  	var isComma 	= varValue.indexOf(",") != -1;
  	var result		= false;
  	if(decSymb == "," && isComma && !isDot){
  			result= !isNaN( varValue.replace(/,/, '.') );
	} 
  	if(decSymb == "." && isDot && !isComma){
  			result= !isNaN( varValue );
	} 
  	if (decSymb == "." && !isComma && !isDot){
  			result= !isNaN( varValue );
  	}
  	if (decSymb == "," && !isComma && !isDot){
  			result= !isNaN( varValue );
  	}
  	return result;	
}
function checkPositiveReal(fieldname){
    var fieldname = "" ; 
    if(!fieldname) {
        fieldname=this;
    }

    if( isNaN(fieldname.value) || fieldname.value < 0 )
    {
        alert("<emxUtil:i18nScript localize='i18nId'>emxEngineeringCentral.Alert.checkPositiveNumeric</emxUtil:i18nScript>");
        fieldname.focus();
        return false;
    }
    return true;
}
function clearRelatedFields()
{
      basicClear('ResponsibleDesignEngineer1');
      basicClear('ResponsibleManufacturingEngineer'); 
      basicClear('RDEngineer');     
}

function clearRDO()
{
      basicClear('DesignResponsibility');
      basicClear('ResponsibleDesignEngineer1');
      basicClear('ResponsibleDesignEngineer');
      basicClear('ResponsibleManufacturingEngineer');
}

/*function validatePartPolicy() {
   
    var policy = document.forms[0].elements["Policy"].value ;    
    var ECO = document.forms[0].elements["COToReleaseDisplay"].value ;
    <!-- XSSOK -->
    if(policy == '<%= PropertyUtil.getSchemaProperty(context,"policy_DevelopmentPart")%>' && ECO != ""  ) {     
        alert("<emxUtil:i18nScript localize='i18nId'>emxEngineeringCentral.Part.CannotConnectECOToDevPart</emxUtil:i18nScript>");
        basicClear('ECO');
    }  
     
        return true ;  
}*/


function validatePlanningRequired() {
  	if(document.emxCreateForm.PlanningRequired !=  undefined) {
		if(document.emxCreateForm.EndItem!=undefined && document.emxCreateForm.EndItem.value == "<%= endItemNoOption %>") {
	       		var prPropValue = document.emxCreateForm.PlanningRequired.value;
	       		if(prPropValue == "<%=planningRequiredYesOption%>")
	       		{
	       		alert("<%=planningRequiredAlert%>");
	       		return false;  	
	       		}	       		
  	  }
        
      }
      return true;
}

function validatePartNameRules(){
    var partName = document.forms[0].Name.value;
    var autoNameCheckState = document.forms[0].autoNameCheck.checked;
    
    //If TBE is installed, Part Family will not be supported.. 
    //Please have the application check for any changes related to Part Family
    var partFamilyAutoGenerate = "";
    var partFamilyVal = "" ; 
	
	    partFamilyVal = document.forms[0].partFamilyDisplay.value;
	    partFamilyAutoGenerate = document.forms[0].partFamilyAutoGenerate.value;
	
    if(partFamilyVal != "" &&  partFamilyAutoGenerate == "TRUE" ){
        if( partName != ""  || autoNameCheckState == true ){
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.NameGeneratedByPartFamily</emxUtil:i18nScript>");
            document.forms[0].Name.requiredValidate = "";
	        document.forms[0].Name.disabled = true;
	        document.forms[0].Name.value = "";
	        document.forms[0].autoNameCheck.checked = false;
	        document.forms[0].AutoNameSeries.options[0].selected = true;
            return false;
        }   
        document.forms[0].Name.requiredValidate = "";
        document.forms[0].Name.disabled = true;
        document.forms[0].Name.value = "";
        document.forms[0].autoNameCheck.checked = false;
        document.forms[0].AutoNameSeries.options[0].selected = true;
        return true;
    }
    else{
        if((autoNameCheckState == false) && (partName == "")){
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.SelectPartNaming</emxUtil:i18nScript>");
            document.forms[0].AutoNameSeries.options[0].selected = true;
            return false;
        }
        else{
            return isBadNameChars(document.forms[0].Name);
        }
    }
    return true;
}

// Javascript releated to the choosers in create forms

function showReportedAgainst() { 
	showModalDialog("../common/emxFullSearch.jsp?field=TYPES=type_Part,type_Builds,type_CADDrawing,type_CADModel,type_DrawingPrint,type_PartSpecification,type_Products&table=APPECReportedAgainstSearchList&selection=single&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/SearchUtil.jsp&srcDestRelName=relationship_ReportedAgainstChange&formName=emxCreateForm&fieldNameActual=ReportedAgainstOID&fieldNameDisplay=ReportedAgainstDisplay&mode=Chooser&chooserType=FormChooser&HelpMarker=emxhelpfullsearch&suiteKey=EngineeringCentral",850,630); 
} 

function clearReportedAgainst() { 
	document.emxCreateForm.ReportedAgainstDisplay.value = ""; 
	document.emxCreateForm.ReportedAgainstOID.value     = ""; 
}

function showDistributionList() { 
	showModalDialog("../common/emxFullSearch.jsp?field=TYPES=type_MemberList:CURRENT=policy_MemberList.state_Active&table=APPECMemberListsSearchList&selection=single&submitAction=refreshCaller&hideHeader=true&formName=emxCreateForm&frameName=formCreateDisplay&fieldNameDisplay=DistributionListDisplay&fieldNameActual=DistributionListOID&submitURL=../engineeringcentral/SearchUtil.jsp&mode=Chooser&chooserType=FormChooser&HelpMarker=emxhelpfullsearch",850,630);
} 

function clearDistributionList() { 
	document.emxCreateForm.DistributionListDisplay.value = ""; 
	document.emxCreateForm.DistributionListOID.value     = ""; 
}

function showReviewersList() { 
	showModalDialog("../common/emxFullSearch.jsp?field=TYPES=type_RouteTemplate:ROUTE_BASE_PURPOSE=Review:CURRENT=policy_RouteTemplate.state_Active:LATESTREVISION=TRUE&table=APPECRouteTemplateSearchList&selection=single&submitAction=refreshCaller&hideHeader=true&formName=emxCreateForm&frameName=formCreateDisplay&fieldNameActual=ReviewersListOID&fieldNameDisplay=ReviewersListDisplay&submitURL=../engineeringcentral/SearchUtil.jsp&mode=Chooser&chooserType=FormChooser&HelpMarker=emxhelpfullsearch" ,850,630); 
} 

function clearReviewersList() {
	document.emxCreateForm.ReviewersListDisplay.value = ""; 
	document.emxCreateForm.ReviewersListOID.value = ""; 
}

function showApprovalList() { 
	showModalDialog("../common/emxFullSearch.jsp?field=TYPES=type_RouteTemplate:ROUTE_BASE_PURPOSE=Approval:CURRENT=policy_RouteTemplate.state_Active:LATESTREVISION=TRUE&table=APPECRouteTemplateSearchList&selection=single&submitAction=refreshCaller&hideHeader=true&formName=emxCreateForm&frameName=formCreateDisplay&fieldNameActual=ApprovalListOID&fieldNameDisplay=ApprovalListDisplay&submitURL=../engineeringcentral/SearchUtil.jsp&mode=Chooser&chooserType=FormChooser&HelpMarker=emxhelpfullsearch" ,850,630); 
}

function clearApprovalList() { 
	document.emxCreateForm.ApprovalListDisplay.value = ""; 
	document.emxCreateForm.ApprovalListOID.value     = ""; 
}

function setRDOECO(dontUpdate) {
    setRDO(dontUpdate);
    if (document.emxCreateForm.COToRelease != undefined) {
		document.emxCreateForm.COToReleaseOID.value = document.emxCreateForm.hdnECOId.value;
		document.emxCreateForm.COToReleaseDisplay.value = document.emxCreateForm.hdnECOName.value;
		document.emxCreateForm.COToRelease.value = document.emxCreateForm.hdnECOName.value;
	}
}

function setRDO(dontUpdate) {
    var fieldRDO = document.emxCreateForm.DesignResponsibility;
    if (!dontUpdate && (fieldRDO != undefined)) {
    	<!-- XSSOK -->
        document.emxCreateForm.DesignResponsibilityOID.value = "<%=defaultRDOId %>";
        <!-- XSSOK -->
        document.emxCreateForm.DesignResponsibilityDisplay.value = "<%=defaultRDOName %>";
        <!-- XSSOK -->
        document.emxCreateForm.DesignResponsibility.value = "<%=defaultRDOName %>";
    }
     emxFormReloadField("UOM");
}

// IR-085678V6R2012 : Start

function setVault() {
    if (document.emxCreateForm.Vault != null) {
    <!-- XSSOK -->
        document.emxCreateForm.Vault.value = "<%= defaultVault %>";
    }        
    if (document.emxCreateForm.VaultDisplay != null) { 
        
        // Modified for 091260
        <!-- XSSOK -->
        document.emxCreateForm.VaultDisplay.value = "<%= i18nNow.getAdminI18NString("Vault", defaultVault, languageStr) %>";
    }
}

function preProcessInCreateSpec() {
    setRDO(false);
    setVault();    
    var modelTypeTxtField = document.getElementById("Model Type");
    if (modelTypeTxtField && modelTypeTxtField.value == "Unassigned") {
    	modelTypeTxtField.value = "";
    }    
    
     //Added for IR-216979
    document.emxCreateForm.DesignResponsibilityDisplay.disabled = true;        
	document.emxCreateForm.btnDesignResponsibility.disabled = true;
	
	var autoNameSeriesElement = document.emxCreateForm.AutoNameSeries;
	
	if(!isNullOrEmpty(autoNameSeriesElement)) {
   		for (var i = 0; i < autoNameSeriesElement.length; i++) {
	        if (autoNameSeriesElement.options[i].value == "") {
	          	autoNameSeriesElement.remove(i);          
	        }
		}
	}
}

function preProcessInCreateSketch() {
    setVault();
}

function preProcessInCreateSpecFromIntermediate() {
    setRDOECO(false);
    setVault();
    
    var modelTypeTxtField = document.getElementById("Model Type");
    if (modelTypeTxtField && modelTypeTxtField.value == "Unassigned") {
    	modelTypeTxtField.value = "";
    }
    //Added for IR-216979
    document.emxCreateForm.DesignResponsibilityDisplay.disabled = true;        
	document.emxCreateForm.btnDesignResponsibility.disabled = true; 
}

function preProcessInCreatePart() {
	var fieldAutoName = document.getElementById("Name");
	if (fieldAutoName != null && fieldAutoName != undefined) { fieldAutoName.oldRequiredValidate = fieldAutoName.requiredValidate; }
	
    setRDO(false);
    setVault();
    setPartCreateFormFields();    
}

function setPartCreateFormFields() {

	reloadUOMField(); //UOM Management: To reload the UOM field as per page object settings
    emxFormReloadField("CustomRevisionLevel");
    var partPolicy = null;
    
    if(document.emxCreateForm.elements["PolicyId"]!= null){
    	partPolicy = document.emxCreateForm.elements["PolicyId"].value;
    }
    else{
    	partPolicy = getPolicy();
    }
    
    var configured;
    if(document.emxCreateForm.Configured != undefined)
    	configured = document.emxCreateForm.Configured.checked;
    var tempPFId = document.emxCreateForm.partFamilyId;
    var tempPFName = document.emxCreateForm.partFamilyName;
    var tempPFNameGen = document.emxCreateForm.partFamilyNameGen;
    var partFamilyId = "";
    var partFamilyName = "";
    var partFamilyNameGen = "";    
    
    if(configured){
    <% 
    	String configPolicy = PropertyUtil.getSchemaProperty(context,"policy_ConfiguredPart");
    	Policy policy = new Policy(configPolicy);
    	String strRevisionResolved = policy.getFirstInSequence(context);
    %>
    
    //if(partPolicy == "<%=configPolicy%>"){
    	document.emxCreateForm.CustomRevisionLevel.readOnly = "true";
    	document.emxCreateForm.CustomRevisionLevel.value = "<%=strRevisionResolved%>";
    }
    
    var partFamilyField = document.emxCreateForm.PartFamily;
    if(partFamilyField && (tempPFId != undefined)&&(tempPFName != undefined)&&(tempPFNameGen!= undefined)){
        partFamilyId = tempPFId.value;
        partFamilyName = tempPFName.value;
        partFamilyNameGen = tempPFNameGen.value;
        document.emxCreateForm.PartFamilyDisplay.value=partFamilyName;
        document.emxCreateForm.PartFamily.value=partFamilyName;
        document.emxCreateForm.PartFamilyOID.value=partFamilyId;
        
        if (partFamilyNameGen == "TRUE") {
	        document.emxCreateForm.Name.disabled=true;
	        document.emxCreateForm.autoNameCheck.checked = true; 
	        document.emxCreateForm.Name.requiredValidate = null;
        }
     }
     
   
    var AutoNameSeries = document.emxCreateForm.AutoNameSeriesId;
    if(((partFamilyNameGen == "true") || (partFamilyNameGen == "TRUE"))&& (AutoNameSeries!=null)){
    	<!-- XSSOK -->
         var langPartFamily="<%=strLangPartFamily%>";
         addSelectOption(AutoNameSeries, langPartFamily, "Part Family", true);
    }
	//Modified for Planning MBOM-Planning Required--Start	
    if(document.emxCreateForm.PlanningRequired !=  undefined) {  
    	setDisabledPlanningRequiredOption(true); 	
    }
	//Modified for Planning MBOM-Planning Required--End
	 if(document.emxCreateForm.Product !=  undefined) {  
    	setDisabledProductOption(true);	
    }
	
	 //Added for IR-216979
	 if (document.emxCreateForm.DesignResponsibility != undefined) {
    	document.emxCreateForm.DesignResponsibilityDisplay.disabled = true;        
		document.emxCreateForm.btnDesignResponsibility.disabled = true; 
	}
	if(partPolicy!=undefined && partPolicy=="<%=EngineeringConstants.POLICY_MANUFACTURING_PART%>"){
	  var createForm = document.forms['emxCreateForm'];
	  var eleProdMakeBuy = createForm.elements["ProductionMakeBuyCodeId"];
	  if(!isNullOrEmpty(eleProdMakeBuy)) {    
   		for(var i=0;i < eleProdMakeBuy.length; i++){
	        if(eleProdMakeBuy.options[i].value == "Make"){
	          eleProdMakeBuy.remove(i);          
	        }
	        if(eleProdMakeBuy.options[i].value == "Buy"){
	         eleProdMakeBuy.remove(i);
	        }
		}       
    }
    
    var eleEI = createForm.elements["EndItemId"];    
    for(var i=0;i < eleEI.length; i++)
    {
        if(eleEI.options[i].value == "Yes") {
            eleEI.remove(i);
        }
    }
    }
   
var policyClass = getPolicyClass(partPolicy);

	if (policyClass != "" && (partPolicy=="<%=EngineeringConstants.POLICY_MANUFACTURING_PART%>")) {
		disableCOToRelease(true);  
	}
	if(document.emxCreateForm.ReleaseProcess != undefined){
		var map = <%=sChangeCotrolledValue%>;
		var changeControlledReqd = map[document.emxCreateForm.ReleaseProcess.value];
		if(changeControlledReqd == "Mandatory")
			setChangeControlled(true, true);
		else
			setChangeControlled(false, false);
	} 
}

//Added for Planning MBOM-Planning Required - For Planning Required dependency on End Item field
function onChangeEndItem()
{
	if(document.emxCreateForm.PlanningRequired !=  undefined) {
		if(document.emxCreateForm.EndItem!=undefined && document.emxCreateForm.EndItem.value == "<%= endItemYesOption %>") {
		   var partPolicy = null;
		   if(document.emxCreateForm.elements["PolicyId"]!= undefined){
		   		partPolicy = document.emxCreateForm.elements["PolicyId"].value;
		   } 
		   else{
		   		partPolicy = getPolicy();
		   }
		   
		   setDisabledProductOption(false);
			if(partPolicy=="<%=DomainConstants.POLICY_EC_PART%>") {
	       		setDisabledPlanningRequiredOption(false);
	       		var prPropValue = "<%=planningRequiredDefOption%>";
	       		if(prPropValue == "<%=planningRequiredYesOption%>")
	       		{
	       			document.emxCreateForm.PlanningRequired.value = "<%=planningRequiredYesOption%>";
	       		}
	       		else
	       		{
	       			document.emxCreateForm.PlanningRequired.value = "<%=planningRequiredNoOption%>";
	       		}
			}
	   	}else {
	   		document.emxCreateForm.PlanningRequired.value = "<%=planningRequiredNoOption%>";
	   		setDisabledPlanningRequiredOption(true); 
	   		setDisabledProductOption(true);
	  	}
  	}else{
  		if(document.emxCreateForm.EndItem!=undefined && document.emxCreateForm.EndItem.value == "<%= endItemYesOption %>") {
  			setDisabledProductOption(false);
  		}else{
  			setDisabledProductOption(true);
  		}
  	}
}

//Added for Planning MBOM-Planning Required - To udpdate Planning Required based on End Item field
function setDisabledPlanningRequiredOption(optionEnableOrDisable)
{
	var elePL = document.emxCreateForm.PlanningRequired;   
    if(elePL != undefined){
		for(var i=0;i < elePL.length; i++) {
			if(elePL.options[i].value == "<%= planningRequiredYesOption %>") {
            elePL.options[i].disabled = optionEnableOrDisable;
			}
		}
    }
}

function addSelectOption (selectObj, text, value, isSelected) {    
        var newOption = document.createElement("OPTION"); 
        newOption.text = text;
        newOption.value = value;
        newOption.selected = isSelected;
        //selectObj.options[selectObj.options.length] = newOption;
        selectObj.options.add(newOption);
}

function preProcessInCreatePartIntermediate() {
	var fieldAutoName = document.getElementById("Name");
	if (fieldAutoName != null && fieldAutoName != undefined) { fieldAutoName.oldRequiredValidate = fieldAutoName.requiredValidate; }
    setRDO(false);
    setVault();
    var disableYesOption = document.emxCreateForm.sDisableSparePartYesOption;
    if( disableYesOption && (disableYesOption != undefined) && 
		((disableYesOption.value == "true") || (disableYesOption.value == "TRUE")))
	{
		setSparePartOptionYesDisabled(true);	
	}
    setPartCreateFormFields();
}

function preProcessInCreatePartClone() {
	var fieldAutoName = document.getElementById("Name");
	if (fieldAutoName != null && fieldAutoName != undefined) { fieldAutoName.oldRequiredValidate = fieldAutoName.requiredValidate; }
    setRDO(false);
    setVault();
    
    if (document.emxCreateForm.fromPartProperties) {
        if (document.emxCreateForm.fromPartProperties.value == "true") {
            document.emxCreateForm.clonePartNumDisplay.disabled = true;
            document.emxCreateForm.btnclonePartNum.disabled = true;
        }
    }
    
    if (document.emxCreateForm.PartFamilyDisplay && document.emxCreateForm.clonePartNumDisplay.value == "") {
        document.emxCreateForm.PartFamilyDisplay.disabled = true;
        document.emxCreateForm.btnPartFamily.disabled = true;
    }
    
    if (document.emxCreateForm.PartFamilyDisplay && document.emxCreateForm.PartFamilyDisplay.value != "") {
        document.emxCreateForm.PartFamilyDisplay.disabled = true;
        document.emxCreateForm.btnPartFamily.disabled = true;
        
        if (document.emxCreateForm.PartFamilyAutoName.value == "TRUE") {
        	if (document.emxCreateForm.autoNameCheck != undefined) {
	            document.emxCreateForm.autoNameCheck.checked = true;            
	            onAutoNameClick(document.emxCreateForm.autoNameCheck);
            }                        
            
            var newOption = document.createElement("OPTION");
            <!-- XSSOK -->
		    newOption.text = "<%=strLangPartFamily %>";
		    <!-- XSSOK -->
		    newOption.value = "<%=strLangPartFamily %>";
		    newOption.selected = true;
		    
		    if (document.emxCreateForm.AutoNameSeries == undefined) {
		    	document.emxCreateForm.NameId.options[document.emxCreateForm.NameId.options.length] = newOption;
		    	document.emxCreateForm.NameId.disabled = true;
		    } else {
		    	document.emxCreateForm.AutoNameSeries.options[document.emxCreateForm.AutoNameSeries.options.length] = newOption;
		    	document.emxCreateForm.AutoNameSeries.disabled = true;
		    }
		    		    
		    if (document.emxCreateForm.autoNameCheck != undefined) {
		    	document.emxCreateForm.autoNameCheck.disabled = true;
		    }
		    
		    if (document.emxCreateForm.Name != undefined) {
		    	document.emxCreateForm.Name.disabled = true;
		    }
		    
		    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.NameGeneratedByPartFamily</emxUtil:i18nScript>");
        }
    }
 if(document.emxCreateForm.ReleaseProcess != undefined){
		var map = <%=sChangeCotrolledValue%>;
		var changeControlledReqd = map[document.emxCreateForm.ReleaseProcess.value];
		if(changeControlledReqd == "Mandatory")
			setChangeControlled(true, true);
		else
			setChangeControlled(false, false);
	}
}

function preProcessCreatePartInFamily() {
    setRDO(false);
    setVault();    
    /*if (document.emxCreateForm.PartMode != null) {
        if (document.emxCreateForm.PartMode.value == "Unresolved") {
            document.emxCreateForm.CustomRevisionLevel.readOnly = "true";
            document.emxCreateForm.COToReleaseDisplay.readOnly = "true";
            document.emxCreateForm.btnCOToRelease.disabled = "true";
        }
    }*/
    reloadUOMField(); //UOM Management: To reload the UOM field as per page object settings
    emxFormReloadField("CustomRevisionLevel");
    var policy = getPolicy();  
    if(policy == "<%= PropertyUtil.getSchemaProperty(context,"policy_ConfiguredPart")%>"){
    	document.emxCreateForm.CustomRevisionLevel.readOnly = "true";
    }
    
    if (document.emxCreateForm.PFNameGen != null) {
       if (document.emxCreateForm.PFNameGen.value != null && document.emxCreateForm.PFNameGen.value == "TRUE") {
           document.emxCreateForm.autoNameCheck.checked = true;
           document.emxCreateForm.Name.disabled = true;
           document.emxCreateForm.Name.value = "";
           document.emxCreateForm.Name.requiredValidate = null;          
       } 
    }
    
    //added for IR-326681-3DEXPERIENCER2015x
     if(document.emxCreateForm.PlanningRequired !=  undefined) {  
    	setDisabledPlanningRequiredOption(true); 	
    }
    if(document.emxCreateForm.Product !=  undefined) {  
    	setDisabledProductOption(true);	
    }
    if(document.emxCreateForm.ReleaseProcess != undefined){
		var map = <%=sChangeCotrolledValue%>;
		var changeControlledReqd = map[document.emxCreateForm.ReleaseProcess.value];
		if(changeControlledReqd == "Mandatory")
			setChangeControlled(true, true);
		else
			setChangeControlled(false, false);
	}
}

// IR-085678V6R2012 : End

//Start for Next Gen UI--
//this function will be loaded in Create ECO page which enables RDE,RME fields if RDO field is not empty else disables.
function preProcessInCreateECO(dontUpdate){
    //Default RDO Population        
    setRDO(dontUpdate);
    var  fieldRDO      = document.emxCreateForm.DesignResponsibilityDisplay.value;
    var  displayField  = fieldRDO != "" ? false : true;
    
    // IR-143196V6R2013
    if (document.emxCreateForm.disableRDO) {
        var varDisableRDO = document.emxCreateForm.disableRDO.value;
        if (varDisableRDO == "true") {
           if(fieldRDO){
	            document.emxCreateForm.DesignResponsibilityDisplay.disabled = true;        
	            document.emxCreateForm.btnDesignResponsibility.disabled = true; 
            }       
        }
    }
    
	    //Added for IR-216979
    document.emxCreateForm.DesignResponsibilityDisplay.disabled = true;        
	document.emxCreateForm.btnDesignResponsibility.disabled = true; 
    
    document.emxCreateForm.ResponsibleManufacturingEngineerDisplay.disabled=displayField;
    document.emxCreateForm.btnResponsibleManufacturingEngineer.disabled=displayField;
    basicClear('ResponsibleManufacturingEngineer');
    
    document.emxCreateForm.ResponsibleDesignEngineer1Display.disabled=displayField;
    document.emxCreateForm.btnResponsibleDesignEngineer1.disabled=displayField;
    basicClear('ResponsibleDesignEngineer1');    
}

//this function was the onChange handler for RDO field in Create ECO page,which enables RDE,RME fields if RDO field is changed and is not empty else disables.
function updateRDOForCreateECO() {
    preProcessInCreateECO(true); 
    if(!fromPreProcess) {
	    if(document.emxCreateForm.ResponsibleDesignEngineer1.value != "" 
	    	&& document.emxCreateForm.ResponsibleDesignEngineer1.value != "Unassigned") {
	    	basicClear('ResponsibleDesignEngineer1');
	    }
		
		if(document.emxCreateForm.ResponsibleManufacturingEngineer.value != "" 
			&& document.emxCreateForm.ResponsibleManufacturingEngineer.value != "Unassigned") {
	    	basicClear('ResponsibleManufacturingEngineer');
	    }
    } else {
    	fromPreProcess = false;
    	basicClear('ResponsibleDesignEngineer1');
    	basicClear('ResponsibleManufacturingEngineer');
    }
   
}

function preProcessInCreateECR() {
    var  fieldRDO      = document.emxCreateForm.ChangeResponsibilityDisplay.value;
    var  displayField  = fieldRDO != "" ? false : true;

    document.emxCreateForm.RDEngineerDisplay.disabled=displayField;
    document.emxCreateForm.btnRDEngineer.disabled=displayField;
    basicClear('RDEngineer');
}

function updateRDOForCreateECR() {
	preProcessInCreateECR();
	
	if(document.emxCreateForm.RDEngineer.value != "" 
		&& document.emxCreateForm.RDEngineer.value != "Unassigned") {
    	basicClear('RDEngineer');
    }
}

function setCreateFormFields() {
	fromPreProcess = true;
	if(document.emxCreateForm.ReportedAgainstChangeName != null) {
		document.emxCreateForm.ReportedAgainstDisplay.value = document.emxCreateForm.ReportedAgainstChangeName.value;
		document.emxCreateForm.ReportedAgainstOID.value = document.emxCreateForm.ReportedAgainstChangeOID.value;
		
		document.emxCreateForm.DesignResponsibilityDisplay.value = document.emxCreateForm.DesignRespName.value;
		document.emxCreateForm.DesignResponsibilityOID.value = document.emxCreateForm.DesignRespOID.value;

		document.emxCreateForm.DistributionListDisplay.value = document.emxCreateForm.DistListName.value;
		document.emxCreateForm.DistributionListOID.value = document.emxCreateForm.DistListOID.value;
		
		document.emxCreateForm.ReviewersListDisplay.value = document.emxCreateForm.RevListName.value;
		document.emxCreateForm.ReviewersListOID.value = document.emxCreateForm.RevListOID.value;
		
		document.emxCreateForm.ApprovalListDisplay.value = document.emxCreateForm.AprListValue.value;
		document.emxCreateForm.ApprovalListOID.value = document.emxCreateForm.AprListOID.value;
		
		document.emxCreateForm.ResponsibleDesignEngineer1Display.value = document.emxCreateForm.RDE.value;
		document.emxCreateForm.ResponsibleDesignEngineer1.value = document.emxCreateForm.RDE.value;
		document.emxCreateForm.ResponsibleDesignEngineer1OID.value = document.emxCreateForm.RDE.value;
		
	}
	if (document.emxCreateForm.setRDOValue) {
	    document.emxCreateForm.DesignResponsibilityDisplay.value = decodeURIComponent(document.emxCreateForm.DesignRespName.value);
        document.emxCreateForm.DesignResponsibilityOID.value     = document.emxCreateForm.DesignRespOID.value;
        //Added for RDO Convergence
        document.emxCreateForm.DesignResponsibility.value = decodeURIComponent(document.emxCreateForm.DesignRespName.value);
    }
	
	preProcessInCreateECO(true); 
		
	if (document.emxCreateForm.DesignResponsibilityDisplay.value == null || document.emxCreateForm.DesignResponsibilityDisplay.value == "") {
       setRDO(false); 
    }    
}

function setRDOForCreateECO() {
    if (document.emxCreateForm.DesignRespName) {
        if (document.emxCreateForm.DesignRespName.value != "") {
	        document.emxCreateForm.DesignResponsibilityDisplay.value = decodeURIComponent(decodeURIComponent(document.emxCreateForm.DesignRespName.value));
	        document.emxCreateForm.DesignResponsibilityOID.value     = document.emxCreateForm.DesignRespOID.value;
	        //Added for RDO Convergence
	        document.emxCreateForm.DesignResponsibility.value = decodeURIComponent(decodeURIComponent(document.emxCreateForm.DesignRespName.value));
        }
    }
    preProcessInCreateECO(true);
}
//End for Next Gen UI

// Start Part Create conversion to common component

function reloadFirstRevision(){
    emxFormReloadField("CustomRevisionLevel");
	//Added for Planning MBOM-Planning Required-Start - To reload Planning Required option according to the Policy selected
	var createForm = document.forms['emxCreateForm'];
	
	var partPolicy = null;
	if(createForm.elements["PolicyId"] != undefined){
		partPolicy = createForm.elements["PolicyId"].value;
	}
	else {
		partPolicy = getPolicy();
	}
		
	var policyClass = getPolicyClass(partPolicy);

	var planningRequiredField = createForm.elements["PlanningRequiredId"];
	if(partPolicy!="<%=DomainConstants.POLICY_EC_PART%>" && planningRequiredField != undefined) {   
		planningRequiredField.value= "<%= planningRequiredNoOption %>";
		setDisabledPlanningRequiredOption(true);  
	}  else if(document.emxCreateForm.EndItem!=undefined && document.emxCreateForm.EndItem.value == "<%= planningRequiredYesOption %>") {
		setDisabledPlanningRequiredOption(false);  
	}
	//Added for Planning MBOM-Planning Required-End
	
	var tempForm = document.forms['emxCreateForm'];
    var policyName = tempForm.Policy;
    
    if(policyName.value == "<%=PropertyUtil.getSchemaProperty(context,"policy_ConfiguredPart")%>"){
    	tempForm.CustomRevisionLevel.readOnly=true;
    }
    else{
    	tempForm.CustomRevisionLevel.readOnly=false;
    }
}
 
function partFamilyChangeEvent()
{

    var createForm = document.forms['emxCreateForm'];
  
    var pfOID       = createForm.elements["PartFamilyOID"];
    var pfDisp      = createForm.elements["PartFamilyDisplay"];
    var pFly        = createForm.elements["PartFamily"];
    var pFlyAutoName = createForm.elements["PartFamilyAutoName"];
    
    //var createMode  = createForm.elements["createMode"].value ;
      
   if(pfDisp.value == '') 
   {
        pFlyAutoName.value  = 'FALSE';
   }   
    return true;
}

function validatePartName(){
    return true;
}

var newRevisionList = new Array();
function onChangePartMode(){

    var tempForm = document.forms['emxCreateForm'];
    //var policyName = tempForm.Policy;
    var policyName = getPolicy();
    var revisionName = tempForm.CustomRevisionLevel;
    var partMode = tempForm.PartMode;
   
    var policyResolvedArray = new Array();
    var policyUnresolvedArray = new Array();
    var i=0;
    var j=0;
    
    setVault();
    
    if(partMode.value=="Unresolved")
    {
  
        tempForm.CustomRevisionLevel.readOnly=true;
    /*  tempForm.COToReleaseDisplay.value="";
        tempForm.COToReleaseOID.value="";
        tempForm.COToRelease.value="";
        tempForm.COToReleaseDisplay.readOnly=true;
        tempForm.btnCOToRelease.disabled = true;
	tempForm.COToReleaseDisplay.disabled=true; */
        
    }
    else
    {
        tempForm.CustomRevisionLevel.readOnly=false;
    /*  tempForm.COToReleaseDisplay.value="";
        tempForm.COToReleaseOID.value="";
        tempForm.COToRelease.value="";
        tempForm.COToReleaseDisplay.readOnly=true;
        tempForm.btnCOToRelease.disabled = false;
	tempForm.COToReleaseDisplay.disabled=false; */
    }
    
    var a=0;
    var length = policyName.options.length;
    
    while(a < length)
    {
        policyName.removeChild(policyName.options[a]);
        length--;
    }
    
    <%        
        String POLICY_STANDARD_PART = PropertyUtil.getSchemaProperty(context,"policy_StandardPart");
        StringList revisionResolved = new StringList();
        StringList revisionUnresolved = new StringList();
        int ritr =0;
        int unitr=0;
      
        
        PolicyItr  partPolicyItr2  = new PolicyItr(allPartPolicyList);
        while(partPolicyItr2.next())
        {
            Policy policyValue =  (Policy)partPolicyItr2.obj();
            String policyValueName = policyValue.getName();
            String policyClassification = EngineeringUtil.getPolicyClassification(context,policyValueName);
            String policyText = i18nNow.getAdminI18NString("Policy", policyValueName, languageStr);
              if(!isMBOMInstalled && POLICY_STANDARD_PART.equalsIgnoreCase(policyValueName)){
                  continue;
            }
            if("Unresolved Part".equalsIgnoreCase(policyValueName)){
                continue;
            }
    %>
            if(partMode.value=="Resolved")
            {
                <%
                        if(("Development".equalsIgnoreCase(policyClassification))||("Production".equalsIgnoreCase(policyClassification)))
                        {
                            String strrevisionResolved = policyValue.getFirstInSequence(context);
                            revisionResolved.addElement(strrevisionResolved);
                %>
                		    <!-- XSSOK -->
                            policyResolvedArray[i] = "<%=policyValueName%>";
                            var objOption = document.createElement("OPTION");
                            policyName.appendChild(objOption);
                            <!-- XSSOK -->
                            policyName.options[i].text = "<%=policyText%>";
                            policyName.options[i].value = policyResolvedArray[i];
                            <!-- XSSOK -->
                            tempForm.CustomRevisionLevel.value = "<%=revisionResolved.get(0)%>";
                            <!-- XSSOK -->
                            newRevisionList[i] = "<%=revisionResolved.get(ritr)%>";

                            i++;
               <%
                        ritr++;
                        }
               %>
            }
            else if(partMode.value=="Unresolved")
            {
                <%
                        if("Unresolved".equalsIgnoreCase(policyClassification))
                        {
                                String strRevisionUnresolved = policyValue.getFirstInSequence(context);
                                revisionUnresolved.addElement(strRevisionUnresolved);
                             %>
								<!-- XSSOK -->
                                policyUnresolvedArray[j] = "<%=policyValueName%>";
                                var objOption = document.createElement("OPTION");
                                policyName.appendChild(objOption);
                                <!-- XSSOK -->
                                policyName.options[j].text = "<%=policyText%>";
                                policyName.options[j].value = policyUnresolvedArray[j];
                                <!-- XSSOK -->
                                tempForm.CustomRevisionLevel.value = "<%=revisionUnresolved.get(0)%>";
                                <!-- XSSOK -->
                                newRevisionList[j] = "<%=revisionUnresolved.get(unitr)%>";
                                j++;
                            <%
                                unitr++;
                        }
               %>
            }
    <%
        }        
    %>
}

function validatePartFamily() {
    var createForm      = document.forms['emxCreateForm']
    var policy          = null;
    if(createForm.elements["Policy"] != undefined){
    	policy = createForm.elements["Policy"].value ;
    }
    else {
    	policy = getPolicy();
    }
    var partName = "";
    if(createForm.elements["Name"] != undefined){
      partName        = createForm.elements["Name"].value ;
    }
    var vNameField   = createForm.elements["nameField"].value;
    var autoNameSeriesField = createForm.elements["AutoNameSeriesId"];
    var autoNameSeriesID = ""; 
    
	    var autoNamecheck = "";
    if((vNameField == "autoName" || vNameField == "autoname") && createForm.elements["autoNameCheck"] == undefined){
    autoNamecheck = true;
    }
     else if(vNameField == "keyin"){
        autoNamecheck = false;
    }
    else{
    autoNamecheck   = createForm.elements["autoNameCheck"].value;
    }
    
    if(autoNameSeriesField == undefined){
    	autoNameSeriesField = createForm.elements["NameId"];  
    	if(vNameField == "keyin"){
    	   autoNameSeriesField = createForm.elements["Name"]; 
    	}  	
    }
	
    if(autoNameSeriesField != null){
	    var autoNameSeriesID = autoNameSeriesField.value;
	    
	    var PartFamilyOID   = createForm.elements["PartFamilyOID"].value;
	    var PartFamilyDisplay  = createForm.elements["PartFamilyDisplay"].value;
	    var PartFamily  = createForm.elements["PartFamily"].value;
	    var PartFamilyAutoName  = createForm.elements["PartFamilyAutoName"].value;
	    
	    if ( PartFamilyAutoName =='TRUE' && (partName != "" || autoNameSeriesID != 'Part Family' ) ) 
	    { 
	            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.PartFamilyValidationMsg1</emxUtil:i18nScript>");
	            return false;
	    } else if( PartFamilyAutoName =='FALSE' && autoNameSeriesID == 'Part Family') {
	            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.PartFamilyValidationMsg2</emxUtil:i18nScript>");
	            return false;
	    } else {
	        return true;
	    }
    }else if(autoNamecheck == 'false'){        
        return false;
    }
    return true;
}

function validateEstimatedCost() {
    var createForm   = document.forms['emxCreateForm'];
    var estimatedCost = createForm.elements["EstimatedCost"];    
    if (estimatedCost != null) {
        var estimatedCostValue = estimatedCost.value;
        estimatedCostValue = estimatedCostValue.trim();
        if(!isNumericGeneric(estimatedCostValue)){
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.EstimatedCostHasToBeANumber</emxUtil:i18nScript>");
			return false;
		}
        if((estimatedCostValue.substring(0,1) == "-")) {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.EstimatedCostHasToBeGreaterThanZero</emxUtil:i18nScript>");
            estimatedCost.value = '';
            estimatedCost.focus();
            return false;
        }
    }
    return true;
}

function validateTargetCost() {
    var createForm = document.forms['emxCreateForm'];
    var targetCost = createForm.elements["TargetCost"];
    if (targetCost != null) {
        var targetCostValue = targetCost.value;
        targetCostValue = targetCostValue.trim();
        	if(!isNumericGeneric(targetCostValue)){
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.TargetCostHasToBeANumber</emxUtil:i18nScript>");
			return false;
		}
        if ((targetCostValue.substring(0,1) == "-")) {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.TargetCostHasToBeGreaterThanZero</emxUtil:i18nScript>");
            targetCost.value = '';
            targetCost.focus();
            return false;
        }
    }
    return true;
}

function validateWeight() {
    var createForm = document.forms['emxCreateForm'];
    var weight     = createForm.elements["Weight"];
    if (weight != null) {
        var weightValue = weight.value;
        weightValue = weightValue.trim();
        if(!isNumericGeneric(weightValue)){
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.WeightHasToBeANumber</emxUtil:i18nScript>");
			return false;
      	}
        if ((weightValue.substring(0,1) == "-")) {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.WeightHasToBeGreaterThanZero</emxUtil:i18nScript>");
            weight.value = '';
            weight.focus();
            return false;
        }
    }
    return true;
}
   
function validateEffectivityDate() {
    var createForm      = document.forms['emxCreateForm'];
    var effectivityDate = createForm.elements["EffectivityDate_msvalue"];
    
    var currentDate = new Date();

    var eDate = new Date();
    eDate.setTime(effectivityDate.value);
    
    if(effectivityDate.value != "") {
	    if((parseInt(eDate.getTime()))<=(parseInt(currentDate.getTime()))) {        
	        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.TargetRelDateHasToBeGreaterThanPresentDate</emxUtil:i18nScript>");
	        return false;
	    }
    }
    
    return true;
}

String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
}

function validateRDEForTeamECO(){
    var createForm = document.forms['emxCreateForm'];
    var rdeField   = createForm.elements["ResponsibleDesignEngineer"];
    
    if(rdeField.value == "Unassigned"){
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.alert.MustSelectRDE</emxUtil:i18nScript>");
        return false;
    }
    return true;
}
function validateNoOfParts() {
	<!-- XSSOK -->
    var maxMultiParts = <%=com.matrixone.apps.engineering.Part.MAX_PART_NUMBER_COUNT_VALUE%>;
    var createForm = document.forms['emxCreateForm'];
    var noOfPartsField = createForm.elements["NoOfParts"];
	var vNameField   = createForm.elements["nameField"].value;
    var autoNameSeriesField = createForm.elements["AutoNameSeriesId"];
    var autoNameCheckField = createForm.autoNameCheck;
    var autoNameSeriesValue = "";
	var autoNameCheckValue = "";
    
    if(autoNameSeriesField == undefined){
    	autoNameSeriesField = createForm.elements["NameId"];  
    	if(vNameField == "keyin"){
    	    autoNameSeriesField = createForm.elements["Name"];
    	}   	
    }
    
    if(autoNameSeriesField){
        autoNameSeriesValue = autoNameSeriesField.value;
    }
	
	if((vNameField == "autoName" || vNameField == "autoname") && autoNameCheckField == undefined){
    autoNameCheckValue = true;
    }
    else if(vNameField == "keyin"){
     autoNameCheckValue = false;
    }
    else{
    autoNameCheckValue = autoNameCheckField.checked;
    }
	
    var noOfParts = noOfPartsField.value;
    try{
	    if(noOfPartsField && noOfParts != "" && noOfParts != 1){
		    if((autoNameCheckField || vNameField == "autoName" || vNameField == "autoname") && (autoNameSeriesValue != "Not Selected") && (autoNameCheckValue == true)){
			    if(isNaN(noOfParts) || (noOfParts <= 0) || (noOfParts % 1)!=0){
			        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.NonNegitiveNoOfParts</emxUtil:i18nScript>");
			        noOfPartsField.value = "";
			        noOfPartsField.focus();
			        return false;
			    }
			    if(noOfParts > maxMultiParts){
			        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.LessNoOfParts</emxUtil:i18nScript> " + maxMultiParts);
			        noOfPartsField.value = "";
	                        noOfPartsField.focus();
	                        return false;
			    }
			}else{
			   alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.SelectAutoname</emxUtil:i18nScript>");
			   return false;
			}
		}
	}catch(e){
	  alert("Error validating NoOfParts");
	}
    return true;
}

//Revision Forms Modifications
function preProcessInRevisePart() {
	reloadUOMField() //UOM Management: Reload UOM field based on UOM Type selected
	var createForm = document.forms['emxCreateForm'];
	var nameField = createForm.elements["Name"];
	var partName = createForm.elements["partName"];
	var nextRev = createForm.elements["nextRev"];
	var revValue = createForm.elements["CustomRevisionLevel"];
	var partPolicy = null;
	
	if(createForm.elements["Policy"] != undefined){
		partPolicy = createForm.elements["Policy"].value;
	}
	else {
		partPolicy = getPolicy();
	}
	if(document.emxCreateForm.ReleaseProcess != undefined){
		var map = <%=sChangeCotrolledValue%>;
		var changeControlledReqd = map[document.emxCreateForm.ReleaseProcess.value];
		if(changeControlledReqd == "Mandatory"){
			setChangeControlled(true, false);
			var changeControlledField = createForm.elements["ChangeControlled"];
			for(var i=0;i < changeControlledField.length; i++)
				{
					if(changeControlledField.options[i].value == "False") {
						changeControlledField.options[i].disabled = true;
					}
				}
		}

	}
	//Added for UOM Management
	if(createForm.elements["prevUOM"]) {
		var uom = createForm.elements["UOM"];
		var prevUOM = createForm.elements["prevUOM"].value;
		uom.value = prevUOM;
	}
	
	//Added for Planning MBOM-Planning Required-Start
	if(createForm.elements["prevEndItem"]) {
		var prevEndItem = createForm.elements["prevEndItem"].value;
		if((createForm.elements["prevPlanningRequired"]) != undefined)
		{
			var prevPlanningRequired = createForm.elements["prevPlanningRequired"].value;
			var planningRequiredField = createForm.elements["PlanningRequiredId"];
			if((planningRequiredField != undefined) && ((partPolicy!="<%=DomainConstants.POLICY_EC_PART%>") || (prevPlanningRequired != undefined && prevPlanningRequired == "<%= planningRequiredYesOption %>")|| ((prevEndItem != undefined && prevEndItem =="<%=endItemNoOption%>" )&&(prevPlanningRequired != undefined && (prevPlanningRequired =="<%=planningRequiredNoOption%>"|| prevPlanningRequired == "") ))))
			{
				if((prevEndItem != undefined && prevEndItem =="<%=endItemNoOption%>" ) && (prevPlanningRequired!=undefined && (prevPlanningRequired=="<%=planningRequiredNoOption%>" || prevPlanningRequired == ""))) {
					planningRequiredField.value = "<%=planningRequiredNoOption%>"; 
				}	      
				var planningRequiredFieldValue=planningRequiredField.value;
				for(var i=0;i < planningRequiredField.length; i++)
				{
					if(planningRequiredField.options[i].value != planningRequiredFieldValue) {
						planningRequiredField.options[i].disabled = true;
					}
				}
			}
			else if(createForm.elements["lastRevPolicy"] != undefined && createForm.elements["lastRevPolicy"].value != "<%=DomainConstants.POLICY_EC_PART%>")
			{  
			if(planningRequiredField!= undefined && planningRequiredField!= null){
				   planningRequiredField.value = "<%=planningRequiredNoOption%>";
			   }
			   setDisabledPlanningRequiredOption(true);
			}
			else if(createForm.elements["isMRAttached"] != undefined && createForm.elements["isMRAttached"].value == "True") 
			{  setDisabledPlanningRequiredOption(true); 
			}
		}
		if(prevEndItem=="<%=endItemYesOption%>")
		{  	var EndItemField = createForm.elements["EndItemId"];
			var EndItemFieldValue = createForm.elements["EndItemId"].value;
			for(var i=0;i < EndItemField.length; i++)
			{
				if(EndItemField.options[i].value != EndItemFieldValue)
				{
					EndItemField.options[i].disabled = true;
					//alert("prevEndItem="+prevEndItem+"1");
				}
			} 
		}
	}
	
	//Added for Planning MBOM-Planning Required-End
	if(nextRev) {
		revValue.value = nextRev.value;	      
	}

	if(nameField != undefined){
		nameField.value = partName.value;
		nameField.disabled = true;
	}

	<!-- XSSOK --> 
	if(partPolicy == "<%=mfgPartType%>") {

		var eleProdMakeBuy = createForm.elements["ProductionMakeBuyCodeId"];    
		for(var i=0;i < eleProdMakeBuy.length; i++)
		{
			if(eleProdMakeBuy.options[i].value == "Make" || eleProdMakeBuy.options[i].value == "Buy"){
				eleProdMakeBuy.remove(i);
				eleProdMakeBuy.remove(i);
			}
		}

		var eleEI = createForm.elements["EndItemId"];    
		for(var i=0;i < eleEI.length; i++)
		{
			if(eleEI.options[i].value == "Yes") {
				eleEI.remove(i);
			}
		}

	}

<!-- XSSOK --> 
	if(partPolicy!= "<%=mfgPartType%>") {
    document.emxCreateForm.DesignResponsibilityDisplay.disabled = true;        
	document.emxCreateForm.btnDesignResponsibility.disabled = true; 
	}
	
}

function isNullOrEmpty(str) {
	return (str == null || str == "null" || str == "undefined" || str.length == 0) ? true : false;
}

function preProcessInReviseSpec() {
    var createForm = document.forms['emxCreateForm'];
    var nameField = createForm.elements["Name"];
    var partName = createForm.elements["partName"];
    var nextRev = createForm.elements["nextRev"];
    var revValue = createForm.elements["CustomRevisionLevel"];
    
    if(nextRev) {
        revValue.value = nextRev.value;
    }
        
    if(nameField != undefined){
        nameField.value = partName.value;
        nameField.disabled = true;
    }
}

function validateRevisionField() {

    var createForm = document.forms['emxCreateForm'];
    var reviseAction = createForm.elements["reviseAction"];

    if(reviseAction == undefined) {
        return isBadNameChars(this);
    } else {
    var RevValue = createForm.elements["CustomRevisionLevel"] ? createForm.elements["CustomRevisionLevel"].value : "";
    var DBnextRev = createForm.elements["nextRev"] ? createForm.elements["nextRev"].value : "";
    var latestRevision = createForm.elements["latestRevision"] ? createForm.elements["latestRevision"].value : "";
    var CustHighNum = createForm.elements["highNum"] ? createForm.elements["highNum"].value : "0";
    var CustHighStr = createForm.elements["highStr"] ? createForm.elements["highStr"].value : "null";
    var revField = createForm.elements["CustomRevisionLevel"];
    
      var DBRevFloat ="";
      var CustomRevFloat = "";
      var latestRevisionFloat = "";
      //End : 372691
      var DBRevInt ="";
      var CustomRevInt = "";
      
      //Modified the if condition for 372691
      //if(/^\d+$/g.test(DBnextRev) && /^\d+$/g.test(RevValue)) {
      if(!isNaN(DBnextRev)&&!isNaN(RevValue)){
          DBRevFloat = parseFloat(DBnextRev);
          CustomRevFloat = parseFloat(RevValue);
          latestRevisionFloat = parseFloat(latestRevision);
          if((CustomRevFloat < DBRevFloat)&&(CustomRevFloat<latestRevisionFloat)) {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.CustomRevisionMustBeGreaterThanLatest</emxUtil:i18nScript>");
            revField.focus();
            return false;
          }
      }else if(/^[A-Z]+$/g.test(DBnextRev) && /^[A-Z]+$/g.test(RevValue)) {
          DBRevInt = parseInt(getAsciiValue(DBnextRev, "[A-Z]"));
          CustomRevInt = parseInt(getAsciiValue(RevValue, "[A-Z]"));
          if(CustomRevInt < DBRevInt) {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.CustomRevisionMustBeGreaterThanLatest</emxUtil:i18nScript>");
            revField.focus();
            return false;
          }
      }else if(/^[a-z]+$/g.test(DBnextRev) && /^[a-z]+$/g.test(RevValue)) {
          DBRevInt = parseInt(getAsciiValue(DBnextRev, "[a-z]"));
          CustomRevInt = parseInt(getAsciiValue(RevValue, "[a-z]"));
          if(CustomRevInt < DBRevInt) {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.CustomRevisionMustBeGreaterThanLatest</emxUtil:i18nScript>");
            revField.focus();
            return false;
          }
      }
// Added the code for bug 341282 1 start
        else if((/^[a-z]+\d*$/ig.test(DBnextRev)) && /^[a-z]+\d*$/ig.test(RevValue)) {
           // Start Bug 349502
          var revValueLen = RevValue.length;
          var DBnextRevLen = DBnextRev.length
          if(DBnextRevLen > revValueLen){
            var diffSize  = DBnextRevLen - revValueLen;
            for(var i=0;i<diffSize;i++){
              RevValue=RevValue+"0";
            }
          } else {
              var custHighStrLen = CustHighStr.length;
              if(custHighStrLen != DBnextRevLen){
                var diffSize  = revValueLen - DBnextRevLen;
                for(var i=0;i<diffSize;i++){
                  DBnextRev=DBnextRev+"0";
                }
              }
          }
          DBRevInt = parseInt(getAsciiValue(DBnextRev, "[A-z0-9]"));
          CustomRevInt = parseInt(getAsciiValue(RevValue, "[A-z0-9]"));
          // End Bug 349502
          if(CustomRevInt < DBRevInt) {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.CustomRevisionMustBeGreaterThanLatest</emxUtil:i18nScript>");
            revField.focus();
            return false;
          }

         //End of addition of code for 341282 1
         // Start Bug 349502
        // If the Customer Entered Revision Sequenceis AlphaNumeric Say [A-Z]+[0-9]*
        // and AutoGenerated Revision Sequence is Numeric
        // DBnextRev condition has been added for bug#346433 - empty seq of the policy was not accepting any cust rev.
        //Modifed the condition for 372691
      } //else if((/^\d+$/g.test(DBnextRev) || DBnextRev == "") && (/^[a-z]+\d*$/ig.test(RevValue))){
          else if((!isNaN(DBnextRev) || DBnextRev == "") && (/^[a-z]+\d*$/ig.test(RevValue))){
            var Custom1 = "";
            if(CustHighStr!="null"){
                var revValueLen = RevValue.length;
                var custHighStrLen = CustHighStr.length
              if(revValueLen > custHighStrLen){
                var diffSize  = revValueLen - custHighStrLen;
                for(var i=0;i<diffSize;i++){
                    CustHighStr=CustHighStr+"0";
                }
              } else {
                var diffSize  = custHighStrLen - revValueLen;
                for(var i=0;i<diffSize;i++){
                    RevValue=RevValue+"0";
              }
              }
              CustomRevInt = parseInt(getAsciiValue(RevValue, "[A-z0-9]"));
              Custom1 = parseInt(getAsciiValue(CustHighStr, "[A-z0-9]"));
              if(CustomRevInt <= Custom1){
                  alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.CustomRevisionMustBeGreaterThanLatest</emxUtil:i18nScript>");
                  revField.focus();
                  return false;
              }
      }
        // If the AutoGenerated Revision Sequence is AlphaNumeric Say [A-Z]+[0-9]*
        // and Customer Entered Revision Sequence is Numeric
        // DBnextRev condition has been added for bug#346433 - empty seq of the policy was not accepting any cust rev.
        //Modified the condition for 372691
      } //else if((/^\d+$/g.test(RevValue)) && (/^[a-z]+\d*$/ig.test(DBnextRev) || DBnextRev == "")){
          else if((!isNaN(RevValue)) && (/^[a-z]+\d*$/ig.test(DBnextRev) || DBnextRev == "")){
            CustomRevInt = parseInt(getAsciiValue(RevValue, "[0-9]"));
            var Custom1 = "";
            if(CustHighNum!=0){
              Custom1 = parseInt(getAsciiValue(CustHighNum, "[0-9]"));
              if(CustomRevInt <= Custom1){
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.CustomRevisionMustBeGreaterThanLatest</emxUtil:i18nScript>");
                    revField.focus();
                  return false;
              }
            }
        // End Bug 349502

     }
      //else {
      //   alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.MustBeSameSequence</emxUtil:i18nScript>");
      //    return false;
      // }
      }
      return true;
}

  function getAsciiValue(str, pattern) {
    var strArray = str.match(new RegExp(pattern,"g"));
    var result="";
	if(strArray == null){
    return result;
    }
    for(var i=0; i<strArray.length; i++) {
        result += (strArray[i].charCodeAt(0));
    }
    return result;
  }
    function validateCount() {  
       var count = document.forms[0].Count;
       var countVal=document.forms[0].Count.value;
        if(isNumeric(countVal, null)!=1)
    {
          alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+countVal+"<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");   
          count.focus();
          return false;
     }
     else
     {
     return true;
     }
         
     }
   
function preProcessInCreateMFGPart(){
    setVault();
	setPartCreateFormFields();
    var createForm = document.forms['emxCreateForm'];
    //var mfgSubmit = createForm.elements["mfgSubmit"].value

    var eleProdMakeBuy = createForm.elements["ProductionMakeBuyCodeId"];
    
    if(!isNullOrEmpty(eleProdMakeBuy)) {  
	    for(var i=0;i < eleProdMakeBuy.length; i++)
	    {
	        if(eleProdMakeBuy.options[i].value == "Make"){
	          eleProdMakeBuy.remove(i);
	        }
	        if(eleProdMakeBuy.options[i].value == "Buy"){
	          eleProdMakeBuy.remove(i);
	        }
	       
	    }
	}    
    var eleEI = createForm.elements["EndItemId"];    
    for(var i=0;i < eleEI.length; i++)
    {
        if(eleEI.options[i].value == "Yes") {
            eleEI.remove(i);
        }
    }
}
     function validatePatternSeparator() {       
       var patternSeparator= document.forms[0].elements["Part Family Pattern Separator"];
       var patternSeparatorVal=document.forms[0].elements["Part Family Pattern Separator"].value;
       var separatorCheckValue = checkForNameBadChars(patternSeparatorVal,false);
	    if (separatorCheckValue == false) {    
	       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.PartFamily.InvalidSeparator</emxUtil:i18nScript>");
	       patternSeparator.focus();
	       return false;
	    }
	     else
	     {
	     return true;
	     }         
     }
   
function reloadForm(){
    var url = document.location.href;
    var createForm = document.forms['emxCreateForm'];
    var typeName = createForm.elements["TypeActual"].value;
    var partFamilyField = createForm.elements["PartFamily"];
    var highestFNField = createForm.elements["highestFN"];
    var partFamilyId = "";
    var partFamilyName = "";
    var partFamilyNameGen = "";
    var highestFN="";
    var InclusionList = createForm.elements["InclusionList"].value;
    
    if(partFamilyField){
	    partFamilyId = createForm.elements["PartFamilyOID"].value;
	    partFamilyName = createForm.elements["PartFamilyDisplay"].value;
	    partFamilyNameGen = createForm.elements["PartFamilyAutoName"].value;
    }
    
    //Added for IR-136677V6R2013 start
    var generalClassField = createForm.elements["GeneralClass"];
    var generalClassId = "";
    var generalClassName = "";
    if(generalClassField){
        generalClassId = createForm.elements["GeneralClassOID"].value;
        generalClassName = createForm.elements["GeneralClassDisplay"].value;       
    }
    //Added for IR-136677V6R2013 end
    
    var splitString = url.split("&");
    var resultString = "";
    var temp1 = "";
    var resultURL = "";
    var length = splitString.length;
    for(var i=0; i < length; i++){
        temp1 = splitString[i];
        if((temp1.indexOf("type=")>=0)||(temp1.indexOf("partFamilyId=")>=0)||(temp1.indexOf("partFamilyName=")>=0)||(temp1.indexOf("partFamilyNameGen=")>=0) ||(temp1.indexOf("objectId=")>=0)){
            continue;
        }
        if(resultURL == ""){
            resultURL = temp1;
        }else if(temp1.indexOf("highestFN")== -1){
            resultURL = resultURL.concat("&",temp1);
        }
        else if(highestFNField){
        		highestFN = createForm.elements["highestFN"].value;
        		resultURL = resultURL.concat("&highestFN=",highestFN);
        		}       
    }
    typeName = typeName +","+ InclusionList;
    resultURL = resultURL.concat("&type=_selectedType:", typeName);
    
    //Modified for IR-136677V6R2013 start
    if(partFamilyField) {
	    resultURL = resultURL.concat("&partFamilyId=", partFamilyId);
	    resultURL = resultURL.concat("&partFamilyName=", partFamilyName);
	    resultURL = resultURL.concat("&partFamilyNameGen=", partFamilyNameGen);
	    resultURL = resultURL.concat("&objectId=", partFamilyId);
    }
    
    if(generalClassField){
        resultURL = resultURL.concat("&generalClassId=", generalClassId);
        resultURL = resultURL.concat("&generalClassName=", generalClassName);       
        resultURL = resultURL.concat("&objectId=", generalClassId);
    }
    //Modified for IR-136677V6R2013 end
    
	document.location.href = resultURL;
}

function preProcessInCreateTeamECO() {
	basicClear('ResponsibleDesignEngineer');
}

function preProcessForGoToProduction() {
    var createForm = document.forms['emxCreateForm'];
    var nameField = createForm.elements["Name"];
    var partName = createForm.elements["partName"];  

        
    if(nameField != undefined){
        nameField.value = partName.value;
        nameField.disabled = true;
    }
	 //Added RDO Convergence Start
    var rdoId = createForm.elements["RDOOID"]; 
    if (document.emxCreateForm.DesignResponsibility != undefined) {	    	
    	document.emxCreateForm.DesignResponsibilityOID.value = rdoId.value;    	
    }
    //Added RDO Convergence End
    
    //Added for IR-216979
    document.emxCreateForm.DesignResponsibilityDisplay.disabled = true;        
	document.emxCreateForm.btnDesignResponsibility.disabled = true; 
}

//Added for To Create Multiple part from Part Clone
function validateNoOfCloneParts() {
	<!-- XSSOK -->
    var maxMultiParts = <%=com.matrixone.apps.engineering.Part.MAX_CLONE_PART_NUMBER_COUNT_VALUE%>;    
    var createForm = document.forms['emxCreateForm'];
    var noOfPartsField = createForm.elements["NoOfParts"];
    
    var autoNameSeriesField = createForm.elements["AutoNameSeriesId"];
    
    if (autoNameSeriesField == undefined) {
    	autoNameSeriesField = createForm.elements["NameId"];
    }
    
    var autoNameCheckField = createForm.autoNameCheck;
    
    var autoNameSeriesValue = "";
    
    if(autoNameSeriesField){
        autoNameSeriesValue = autoNameSeriesField.value;
    }
    
    var autoNameCheckValue = true;
    if (autoNameCheckField) {
    	autoNameCheckValue = autoNameCheckField.checked;
    }
    var noOfParts = noOfPartsField.value;
    try{
	    if(noOfPartsField && noOfParts != "" && noOfParts != 1){
		    if (autoNameSeriesValue != "Not Selected" && autoNameCheckValue == true){
			    if(isNaN(noOfParts) || (noOfParts <= 0) || (noOfParts % 1)!=0){
			        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.NonNegitiveNoOfParts</emxUtil:i18nScript>");
			        noOfPartsField.value = "";
			        noOfPartsField.focus();
			        return false;
			    }
			    if(noOfParts > maxMultiParts){			    
			        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.LessNoOfParts</emxUtil:i18nScript> " + maxMultiParts);
			        noOfPartsField.value = "";
	                        noOfPartsField.focus();
	                        return false;
			    }
			}else{
			   alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.SelectAutoname</emxUtil:i18nScript>");
			   return false;
			}
		}
	}catch(e){
	  alert("Error validating NoOfParts");
	}
    return true;
}
  function reloadDuplicateAttributesInCreateForm(fieldName,fieldValue){
  	var currentActualValue  = fieldValue.current.actual;
    var currentDisplayValue = fieldValue.current.display;
    var fieldNameValues     =  fieldName.split("|");
    if (FormHandler) {
        var attributeGroups     = FormHandler.GetField(fieldName).GetSettingValue("AttributeGroups");
        var attributeGroupsList = attributeGroups.split("|");
        for(var i = 0; i < attributeGroupsList.length; i++) {
            if(attributeGroupsList[i] != "" && attributeGroupsList[i]!=fieldNameValues[0]) {
                FormHandler.GetField(attributeGroupsList[i]+"|"+fieldNameValues[1]).SetFieldValue(currentActualValue,currentDisplayValue);
            }
        }
    }
  }
  

function isValidInteger(fieldname){
    <!-- XSSOK --> 
	var STR_DEC_SYM = "<%=PersonUtil.getDecimalSymbol(context)%>";
    if(fieldname == null || fieldname == "undefined" || fieldname == "null" || fieldname == "")
    {
    	fieldname=this;
    }
   var iValue=fieldname.value;
    if (iValue!= null && iValue != "" && iValue != "undefined") {
	   var valid = parseInt(iValue, 10) == iValue;
	   var decPoint= iValue.indexOf(STR_DEC_SYM)<= 0 ? false : true;
	   if(!valid || decPoint ){
	           alert("<emxUtil:i18nScript localize='i18nId'>emxEngineeringCentral.Alert.checkInteger</emxUtil:i18nScript>");
    		    fieldname.focus();
        		return false;
        }
        return true;
    }
    return true;
}
//Added for Planning MBOM-Planning Required
function onChangeEndItemInRevise(){
if(document.emxCreateForm.PlanningRequired !=  undefined) {
	var elePreviousPL = document.emxCreateForm.elements["prevPlanningRequired"];
    if( elePreviousPL != undefined && elePreviousPL.value != "<%= planningRequiredYesOption %>"){
		if(document.emxCreateForm.EndItem!=undefined && document.emxCreateForm.EndItem.value == "<%= endItemYesOption %>"){
		   
		   var partPolicy = null;
		   if(document.emxCreateForm.elements["Policy"] != undefined){
		   		partPolicy = document.emxCreateForm.elements["Policy"].value; 
		   }
		   else {
		   		partPolicy = getPolicy();
		   }
		   
	    if(partPolicy=="<%=DomainConstants.POLICY_EC_PART%>")
	    {
	       		setDisabledPlanningRequiredOptionForRevise(false); 
	       		var prPropValue = "<%=planningRequiredDefOption%>";
	       		if(prPropValue == "<%=planningRequiredYesOption%>")
	       		{
	       			document.emxCreateForm.PlanningRequired.value = "<%=planningRequiredYesOption%>";
	       		}
	       		else
	       		{
	       			document.emxCreateForm.PlanningRequired.value = "<%=planningRequiredNoOption%>";
	       		}
	    }
	 
	   	}else{
	   		document.emxCreateForm.elements["PlanningRequiredId"].value = "<%=planningRequiredNoOption%>";
	   		setDisabledPlanningRequiredOptionForRevise(true); 
	  	}
  	}
  	}
}

//Added for Planning MBOM-Planning Required
function setDisabledPlanningRequiredOptionForRevise(optionEnableOrDisable){
	 var elePL = document.emxCreateForm.elements["PlanningRequiredId"];
    if(elePL!=undefined) { 
     var elePLValue=elePL.value;

    for(var i=0;i < elePL.length; i++)
    {
    if(optionEnableOrDisable) {
        if(elePL.options[i].value != elePLValue) {
            elePL.options[i].disabled = optionEnableOrDisable;
        } else {
        	elePL.options[i].disabled = !optionEnableOrDisable;
        }
        } else {
        elePL.options[i].disabled =optionEnableOrDisable;
        }
    }
   }
}

//Added for RDO Convergence Start
function reloadECOField() {

    if (document.emxCreateForm.ECO != undefined) {    
		document.emxCreateForm.ECODisplay.value = "";	
		document.emxCreateForm.ECO.value = "";
		document.emxCreateForm.ECOOID.value = "";
	} else if (document.emxCreateForm.ECOForRelease != undefined) { 				
	 	document.emxCreateForm.ECOForReleaseOID.value = "";
    	document.emxCreateForm.ECOForReleaseDisplay.value = "";
    	document.emxCreateForm.ECOForRelease.value = "";    	
    } else if (document.emxCreateForm.COToRelease != undefined) { 				
	 	document.emxCreateForm.COToReleaseOID.value = "";
    	document.emxCreateForm.COToReleaseDisplay.value = "";
    	document.emxCreateForm.COToRelease.value = "";    	
    }
}

//Added for RDO Convergence End
function validatePartFamilyBaseNumber() {
    var createForm = document.forms['emxCreateForm'];
    var partFamilyBaseNumberField = createForm.elements["Part Family Base Number"];
    var partFamilyBaseNumber = partFamilyBaseNumberField.value;
    try{
             if(partFamilyBaseNumber !='' && (isNaN(partFamilyBaseNumber) || partFamilyBaseNumber < 0 || parseInt(partFamilyBaseNumber) != partFamilyBaseNumber) ) {
			        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.NonNegitivePartFamilyBaseNumber</emxUtil:i18nScript>");
			        partFamilyBaseNumberField.value = "";
			        partFamilyBaseNumberField.focus();
			        return false;
			    }
	}catch(e){
	  alert("Error validating partFamilyBaseNumber");
	}
    return true;
}

function disableCOToRelease(optionEnableDisable){
	if (document.emxCreateForm.COToRelease != undefined) {
		document.emxCreateForm.COToRelease.value = "";
		document.emxCreateForm.COToReleaseOID.value = "";
	  	document.emxCreateForm.COToReleaseDisplay.value = "";
	  	document.emxCreateForm.COToReleaseDisplay.disabled = optionEnableDisable;
	  	document.emxCreateForm.btnCOToRelease.disabled = optionEnableDisable;
	}
}

function getPolicyClass(partPolicy){


<%
	Iterator keySetIterator = policyMap.keySet().iterator();
	String key;
	
	while (keySetIterator.hasNext()) {
		key = (String) keySetIterator.next();
%>
		var policyClass;
		<!-- XSSOK --> 
		if (partPolicy == "<%= key%>") {
		<!-- XSSOK --> 
			policyClass = "<%= (String) policyMap.get(key)%>";
		}
<%		
	}	
%>

return policyClass;
}

function preProcessInCreateTopPart() {
    setRDO(false);
    setVault();
    setPartCreateFormFields(); 
    if(document.emxCreateForm.Configured != undefined) 
    document.emxCreateForm.CustomRevisionLevel.readOnly = true;   
    	document.emxCreateForm.Configured.value = "true"; 
    	document.emxCreateForm.Configured.checked = true;
    	document.emxCreateForm.Configured.disabled = true;	
   		document.emxCreateForm.CustomRevisionLevel.value = "<%=sequenceOfECPart%>";
		document.emxCreateForm.Configured.value = "true";
		if(document.emxCreateForm.ReleaseProcess != undefined) {
				document.emxCreateForm.ReleaseProcess.value = "Development";
				document.emxCreateForm.ReleaseProcess.disabled = true;
				setChangeControlled(false, false);
		}	
}

function validateProductField() {
	if(document.emxCreateForm.ProductDisplay !=  undefined) {
		if(document.emxCreateForm.PlanningRequired!=undefined){
			if(document.emxCreateForm.PlanningRequired.value == "<%= endItemYesOption %>" && document.emxCreateForm.ProductDisplay!=undefined && document.emxCreateForm.ProductDisplay.value == "") {
				alert("<%=sProductValidation1%>");
				return false;
			}
		}

		if(document.emxCreateForm.EndItem.value != "<%= endItemYesOption %>" && document.emxCreateForm.ProductDisplay!=undefined && document.emxCreateForm.ProductDisplay.value != "") {
			alert("<%=sProductValidation2%>");
			return false;
		}
	}
	return true;
}

 function setDisabledProductOption(optionEnableOrDisable){
		 var eleProductDisplay = document.emxCreateForm.ProductDisplay;
		 var eleProduct = document.emxCreateForm.Product;
		  var eleProductOID = document.emxCreateForm.ProductOID;
		  var btnProduct = document.emxCreateForm.btnProduct;
	        eleProductDisplay.disabled = optionEnableOrDisable;
	        btnProduct.disabled = optionEnableOrDisable;
	        eleProductDisplay.value = "";
	        eleProduct.value = "";
	        eleProductOID.value = "";
	}
	
//UOM Management - start
function reloadUOMField(){
    emxFormReloadField("UOM");
}

function validateUOMField()
{
	var UOMVal = document.emxCreateForm.UOM;
	if(UOMVal)
		return true;
	else
	{
		alert("Unit of Measure cannot be empty. Choose a valid Unit of Measure Type and Unit of Measure");
		return false;
	}
}
function preProcessInCreateMPN(){
	var createForm      = document.forms['emxCreateForm'];
	reloadUOMField();
}
//UOM Management - End

function getPolicy(){
	
	return (document.emxCreateForm.Configured != undefined && document.emxCreateForm.Configured.checked) ? "<%=PropertyUtil.getSchemaProperty(context,"policy_ConfiguredPart")%>":"<%=DomainConstants.POLICY_EC_PART%>";
}

function onChangeConfigured(){
	
	if(document.emxCreateForm.Configured != undefined && document.emxCreateForm.Configured.checked){		
		document.emxCreateForm.CustomRevisionLevel.readOnly = true;	
		document.emxCreateForm.CustomRevisionLevel.value = "<%=sequenceOfECPart%>";
		document.emxCreateForm.Configured.value = "true";
		if(document.emxCreateForm.ReleaseProcess != undefined) {
				document.emxCreateForm.ReleaseProcess.value = "Development";
				document.emxCreateForm.ReleaseProcess.disabled = true;
				setChangeControlled(false, false);
		}		
	}
	else {
		document.emxCreateForm.CustomRevisionLevel.readOnly = false;
		emxFormReloadField("CustomRevisionLevel");
		if(document.emxCreateForm.Configured != undefined){
			document.emxCreateForm.Configured.value = "false";
		}
		if(document.emxCreateForm.ReleaseProcess != undefined) {
				document.emxCreateForm.ReleaseProcess.value = "Development";
				document.emxCreateForm.ReleaseProcess.disabled = false;
		}
 }
}


function onChangeReleaseProcess(){
	
	emxFormReloadField("CustomRevisionLevel");
	if(document.emxCreateForm.ReleaseProcess != undefined){
		var map = <%=sChangeCotrolledValue%>;
		var changeControlledReqd = map[document.emxCreateForm.ReleaseProcess.value];
		if(changeControlledReqd == "Mandatory")
			setChangeControlled(true, true);
		else
			setChangeControlled(false, false);
	}
}

function onChangeControlled()
{
	if(document.emxCreateForm.ChangeControlled.checked) {
			document.emxCreateForm.ChangeControlled.value = "true";
		}
		else {
			document.emxCreateForm.ChangeControlled.value = "false";
		}
	if(document.emxCreateForm.Configured != undefined && document.emxCreateForm.Configured.checked){
		if(document.emxCreateForm.ChangeControlled.checked) {
			document.emxCreateForm.ReleaseProcess.value = "Production";
		}
		else {
			document.emxCreateForm.ReleaseProcess.value = "Development";
		
		}
	
	}
}

function setChangeControlled(defaultValue, disableOption)
{
	var eleChangeControlled = document.emxCreateForm.ChangeControlled;
	if(eleChangeControlled != undefined){
		if(defaultValue)   
	    	eleChangeControlled.checked = true;
	    else 
	    	eleChangeControlled.checked = false;
	    if(disableOption)
			eleChangeControlled.disabled = true;
		else
			eleChangeControlled.disabled = false;
	}
}
var specificationTitleFlag;
function updateSpecificationTitle() {
    var txtSpecificationTitle = document.getElementById("VPMProductName1").value;
    var strFieldValue =document.forms[0].Name.value;
    
    //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(strFieldValue, ARR_NAME_BAD_CHARS, false);
    if(strInvalidChars.length > 0)
    {
         var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxEngineeringCentral.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
         alert(strAlert);
         document.forms[0].Name.value ='';
         return false;
    }
    if (txtSpecificationTitle=="" || specificationTitleFlag!="true")
    {
        document.getElementById("VPMProductName1").value = strFieldValue;
    }
    return true;
}

//This function sets the flag value and calls for updating Specification Title field.
function setSpecificationTitleFlag() {  
    specificationTitleFlag="true";
    var txtSpecificationTitle = document.getElementById("VPMProductName1").value;

    if (txtSpecificationTitle == "") {
        specificationTitleFlag="false";
    } 
    else if (txtSpecificationTitle != "")
    {
        //Check for Bad Name Chars
        var strInvalidChars = checkStringForChars(txtSpecificationTitle, ARR_NAME_BAD_CHARS, false);
        if(strInvalidChars.length > 0)
        {
            var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxEngineeringCentral.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
            alert(strAlert);
            document.getElementById("VPMProductName1").value ='';
            specificationTitleFlag="false";
            return false;
        }
    } 
    else 
    {
        return true; 
    }
    updateSpecificationTitle();
    return true;
}


//This function sets the flag value and calls for updating Specification Title field.
function setSpecsTitleFlag() {  
    specsTitleFlag="true";
    var txtSpecTitle = document.getElementById("Title1").value;

    if (txtSpecTitle == "") {
        specsTitleFlag="false";
    } 
    else if (txtSpecTitle != "")
    {
        //Check for Bad Name Chars
        var strInvalidChars = checkStringForChars(txtSpecTitle, ARR_NAME_BAD_CHARS, false);
        if(strInvalidChars.length > 0)
        {
            var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxEngineeringCentral.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
            alert(strAlert);
            document.getElementById("Title1").value ='';
            specTitleFlag="false";
            return false;
        }
    } 
    else 
    {
        return true; 
    }
    updateSpecsTitle();
    return true;
}

var specsTitleFlag;
function updateSpecsTitle() {
    var txtSpecsTitle = document.getElementById("Title1").value;
    var strFieldValue =document.forms[0].Name.value;
    
    //Check for Bad Name Chars
    var strInvalidChars = checkStringForChars(strFieldValue, ARR_NAME_BAD_CHARS, false);
    if(strInvalidChars.length > 0) {
         var strAlert = "<emxUtil:i18nScript localize='i18nId'>emxEngineeringCentral.Alert.InvalidChars</emxUtil:i18nScript>"+strInvalidChars;
         alert(strAlert);
         document.forms[0].Name.value ='';
         return false;
    }
  
    if (txtSpecsTitle == "" || specsTitleFlag!="true") {
        document.getElementById("Title1").value = strFieldValue;
    }
    return true;
}

function setSparePartOptionYesDisabled(inputState)
{
	if(document.emxCreateForm.SparePart!= undefined)
	{
		var sparePartSelect = document.emxCreateForm.elements["SparePart"];	
		
		for(var i=0; i<sparePartSelect.options.length; i++)
		{
			if(sparePartSelect.options[i].value == "No" || sparePartSelect.options[i].value == "no")
			{
				sparePartSelect.selectedIndex = i;
			}
			else if(sparePartSelect.options[i].value == "Yes" || sparePartSelect.options[i].value == "yes")
			{
				sparePartSelect.options[i].disabled = inputState;				
				
			}
		}
	}
}

//AT Customization Starts
//WP7 QC4697
function atUpdateNumberOfParts() {
    
    var createForm = document.forms['emxCreateForm'];
    var noOfPartsField = createForm.elements["NoOfParts"];
	var AT_C_Symmetry = createForm.elements["AT_C_Symmetry"];
	var BasedonSymmetry = createForm.elements["BasedonSymmetry"];
	var SymmetryWarning = "<%=sATSymmetryWarning%>";
	
	var SymmetryVal = AT_C_Symmetry.value;
	var BasedonSymmetryVal = BasedonSymmetry.value;
	if(SymmetryVal == "Symmetry"){
				noOfPartsField.value = "1";
				noOfPartsField.disabled = true;
				if(BasedonSymmetryVal == "Yes"){
					alert(SymmetryWarning);
				}
	}
	else{
		noOfPartsField.disabled = false;
	}   
}


