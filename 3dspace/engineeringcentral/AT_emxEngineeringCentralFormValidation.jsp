<%--  emxEngineeringCentralFormValidation.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@page import="com.matrixone.apps.engineering.*"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="java.util.Locale"%>

<%
out.clear();
response.setContentType("text/javascript; charset=" + response.getCharacterEncoding());
//tjx
matrix.util.StringList slMfgPolicy = EngineeringUtil.getManuPartPolicy(context);
String strMfgPolicy = slMfgPolicy.toString();

//tjx
String accLanguage  = request.getHeader("Accept-Language");
//Multitenant
//String strSelectRootNode     =  i18nNow.getI18nString("emxEngineeringCentral.SpareParts.AddSpareParts.SelectRootNode", "emxEngineeringCentralStringResource",accLanguage);
String strSelectRootNode     = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.SpareParts.AddSpareParts.SelectRootNode");
String fnLength  =   JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","FindNumberLength");
String rdLength     = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","ReferenceDesignatorLength");
String fnUniqueness = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","FindNumberUnique");
String rdQtyValidation = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","ReferenceDesignatorQtyValidation");
String rdUniqueness = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","ReferenceDesignatorUnique");
String ebomUniquenessOperator = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","EBOMUniquenessOperator");
String fnDisplayLeadingZeros = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","FindNumberDisplayLeadingZeros");
String attFindNumber = com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,"attribute_FindNumber");
String attRefDes = com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,"attribute_ReferenceDesignator");
String attQty = com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,"attribute_Quantity");
String emxNameBadChars = FrameworkProperties.getProperty(context, "emxFramework.Javascript.NameBadChars");
String propertySuite = "emxEngineeringCentralStringResource";
String BOMChartViewNotsupported    =EnoviaResourceBundle.getProperty(context, propertySuite,locale,"emxEngineeringCentral.Alert.BOMChartViewNotSupported");
String replaceSelectedConfirmation = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.Confirmation.ReplaceSelected");
String replaceAllConfirmation      = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.Confirmation.ReplaceAll");
String rootNodeErrorForReplace     = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.ReplaceByLatest.RootNodeError");
String configuredPartNotAllowedError = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.ReplaceByLatest.ConfiguredPartError");
String partAlreadyLatestRevisionError= EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.ReplaceByLatest.AlreadyLatestError");
String onlyRootNodeExists = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.ReplaceByLatest.OnlyRootNodeExists");
String revisionMgmtConfirmation = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.Confirmation.RevisionManagement");
String revMgmtNotSelectedError  = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"emxEngineeringCentral.Common.PleaseSelectAnItem");
String replaceSelectedWhereUsedConfirmation = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.WhereUsedConfirmation.ReplaceSelected");
String replaceAllWhereUsedConfirmation      = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.WhereUsedConfirmation.ReplaceAll");
String configuredPartsNotAllowed    = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.ConfiguredPart.NotAllowed");
String selectOneItemOnly = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Common.PleaseSelectOneItemOnly");
String whereUsedRevMgmtConfirmation = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.WhereUsedRevMgmtConfirmation.ReplaceSelected");
String ReplaceRevisionOnAddedDeleted = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.Validation.ReplaceRevisionOnAddedDeleted");
String rangeEAeach = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", locale, "emxFramework.Range.Unit_of_Measure.EA_(each)");

//UOM Management---Start
Locale en = new Locale("en");
String uomTypeLengthDefault = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"emxEngineeringCentral.UOM_Type.Length.Default");
String uomTypeWeightDefault = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"emxEngineeringCentral.UOM_Type.Weight.Default");
String uomTypeAreaDefault = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"emxEngineeringCentral.UOM_Type.Area.Default");
String uomTypeVolumeDefault = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"emxEngineeringCentral.UOM_Type.Volume.Default");
String uomTypeLiquidVolumeDefault = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"emxEngineeringCentral.UOM_Type.Liquid_Volume.Default");
String uomTypePorportionDefault = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"emxEngineeringCentral.UOM_Type.Proportion.Default");
String uomTypeLengthDefaultAct = EnoviaResourceBundle.getProperty(context,propertySuite,en,"emxEngineeringCentral.UOM_Type.Length.Default");
String uomTypeWeightDefaultAct = EnoviaResourceBundle.getProperty(context,propertySuite,en,"emxEngineeringCentral.UOM_Type.Weight.Default");
String uomTypeAreaDefaultAct = EnoviaResourceBundle.getProperty(context,propertySuite,en,"emxEngineeringCentral.UOM_Type.Area.Default");
String uomTypeVolumeDefaultAct = EnoviaResourceBundle.getProperty(context,propertySuite,en,"emxEngineeringCentral.UOM_Type.Volume.Default");
String uomTypeLiquidVolumeDefaultAct = EnoviaResourceBundle.getProperty(context,propertySuite,en,"emxEngineeringCentral.UOM_Type.Liquid_Volume.Default");
String uomTypePorportionDefaultAct = EnoviaResourceBundle.getProperty(context,propertySuite,en,"emxEngineeringCentral.UOM_Type.Proportion.Default");


String uomTypeWeight = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",en,"emxFramework.Range.UOM_Type.Weight");
String uomTypeArea = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",en,"emxFramework.Range.UOM_Type.Area");
String uomTypeLength = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",en,"emxFramework.Range.UOM_Type.Length");
String uomTypeLiquidVolume = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",en,"emxFramework.Range.UOM_Type.Liquid_Volume");
String uomTypeVolume = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",en,"emxFramework.Range.UOM_Type.Volume");
String uomTypePorportion = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",en,"emxFramework.Range.UOM_Type.Proportion");
//UOM Management---End

String selectChangeControlledTrueAct = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",en,"emxFramework.Range.Change_Controlled.True");
String selectChangeControlledTrueDisp = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Range.Change_Controlled.True");
String selectChangeControlledFalseAct = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",en,"emxFramework.Range.Change_Controlled.False");
String selectChangeControlledFalseDisp = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Range.Change_Controlled.False");

//UX Modifications
String strMultipleSelection= EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource",context.getLocale(),"emxFramework.Common.PleaseSelectOneItemOnly");
String strEditInNonDetailsView= EnoviaResourceBundle.getProperty(context, propertySuite,context.getLocale(),"emxEngineeringCentral.Command.EditingPartsNotInDetailsView");
String strRemoveRootPart = EnoviaResourceBundle.getProperty(context, propertySuite,context.getLocale(),"emxEngineeringCentral.Command.RemoveRootPartNotPossible");
String strReplaceRootPart = EnoviaResourceBundle.getProperty(context, propertySuite,context.getLocale(),"FloatOnEBOMManagement.ReplaceByLatest.RootNodeError");
String strRemoveConfirm = EnoviaResourceBundle.getProperty(context, propertySuite,context.getLocale(),"emxEngineeringCentral.Common.MsgConfirm");

//Check for ENGSMB Installation
boolean isENGSMBInstalled = EngineeringUtil.isENGSMBInstalled(context, true);
String msgFNValidationKey = "emxEngineeringCentral.Common.FindNumberHasToBeANumber";
//TBE supports Decimal values, so the ENG FN alert message gets changed here for TBE
    if(isENGSMBInstalled){
        msgFNValidationKey = "emxEngineeringCentral.Common.EnterValidFindNumber";
    }

    String propAllowLevel = JSPUtil.getCentralProperty(application, session, "emxEngineeringCentral" ,"AllowMassEBOMChangeUptoLevel");
    if (propAllowLevel != null && !"null".equalsIgnoreCase(propAllowLevel) && !"".equals(propAllowLevel) ) {
      propAllowLevel = propAllowLevel.trim();
    } else {
      propAllowLevel="1";
    }
    String strEBOMSubRel = PropertyUtil.getSchemaProperty(context,"relationship_EBOMSubstitute");
    
%>
<%@include file = "../components/emx3DLiveCrossHighlightJavaScript.inc" %>
//XSSOK
var fnLength               = "<%=fnLength%>";
//XSSOK
var rdLength               = "<%=rdLength%>";
//XSSOK
var ebomUniquenessOperator = "<%=ebomUniquenessOperator%>";
//XSSOK
var fnUniqueness           = "<%=fnUniqueness%>";
//XSSOK
var rdUniqueness           = "<%=rdUniqueness%>";
//XSSOK
var rdQtyValidation           = "<%=rdQtyValidation%>";
//XSSOK
var fnDisplayLeadingZeros  = "<%=fnDisplayLeadingZeros%>";
//XSSOK
var attFindNumber		   = "<%=attFindNumber%>";
//XSSOK
var attRefDes			   = "<%=attRefDes%>";
//XSSOK
var attQty				   = "<%=attQty%>";
var fnPropertyArray = new Array();
var rdPropertyArray = new Array();
var newArray = new Array();
//XSSOK
var isENGSMBInstalled = "<%=isENGSMBInstalled%>";

/* Added for IR-037786  */
//XSSOK
var sBadCharInName	= "<%=emxNameBadChars%>";


<%
//create array of FN/RD Required property settings
String parentAlias = "";
String fnRequired = "";
String rdRequired = "";
String actualType  = "";

//374918 fix starts
Map fnMap = EngineeringUtil.typeFNRDRequiredStatusMap(context);
Iterator iterator = fnMap.keySet().iterator();
while(iterator.hasNext()) {
     actualType  = (String)iterator.next();
      if (actualType==null || "".equals(actualType))
           continue;
  StringList sValue = (StringList)fnMap.get(actualType);
  fnRequired = (String)sValue.get(0);
  rdRequired = (String)sValue.get(1);
  %>
  //XSSOK
  fnPropertyArray["<%=actualType%>"]="<%=fnRequired%>";
  //XSSOK
  rdPropertyArray["<%=actualType%>"]="<%=rdRequired%>";
<%
}
 //374918 fix ends
%>
<%
HashMap hmRev = new HashMap();
MapList mResult = new MapList();
MapList policyList = new MapList();
HashMap argsMap = new HashMap();
argsMap.put("type", DomainConstants.TYPE_PART);
mResult = (com.matrixone.apps.domain.util.MapList)JPO.invoke(context, "emxPart", null, "getPolicyRevision", JPO.packArgs(argsMap),com.matrixone.apps.domain.util.MapList.class);

hmRev = (HashMap)mResult.get(0);
policyList = (MapList)mResult.get(1);


for(int i=0;i<policyList.size();i++)
{
%>
newArray["<%=(String)policyList.get(i)%>"]="<%=(String)hmRev.get((String)policyList.get(i))%>";
<%
}
%>
// IR017352
//XSSOK
<%-- Multitenant--%>
<%-- var VPLM_EA_EACH = "<%=i18nNow.getI18nString("emxEngineeringCentral.Qty.AllowEADecimal","emxEngineeringCentral",accLanguage)%>";--%>
var VPLM_EA_EACH = "<%=EnoviaResourceBundle.getProperty(context,"emxEngineeringCentral.Qty.AllowEADecimal")%>";

//XSSOK
<%-- Multitenant--%>
<%-- var VPLM_EA_EACH_STRING = "<%=i18nNow.getI18nString("emxEngineeringCentral.Qty.AllowEADecimal.String","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var VPLM_EA_EACH_STRING = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Qty.AllowEADecimal.String")%>";
//XSSOK
<%-- Multitenant--%>
<%--var INVALID_FORMAT_MSG = "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.InvalidFormat", "emxEngineeringCentralStringResource",accLanguage)%>";--%>
var INVALID_FORMAT_MSG = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.InvalidFormat")%>";

//XSSOK
<%-- Multitenant--%>
<%--var MULTI_PREFIX_MSG = "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.MultiplePrefix", "emxEngineeringCentralStringResource",accLanguage)%>";--%>
var MULTI_PREFIX_MSG = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.MultiplePrefix")%>";

//XSSOK
<%-- Multitenant--%>
<%--var INVALID_CHAR_MSG ="<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.InvalidChar","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var INVALID_CHAR_MSG ="<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.InvalidChar")%>";
//XSSOK
<%-- Multitenant--%>
<%--var INVALID_QUANTITY = "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.SingleQuantity","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var INVALID_QUANTITY ="<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.SingleQuantity")%>";
//XSSOK
<%-- Multitenant--%>
<%--var NOT_UNIQUE_MSG= "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.NotUnique","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var NOT_UNIQUE_MSG="<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.NotUnique")%>";
//XSSOK
<%-- Multitenant--%>
<%--var SINGLE_RANGE_MSG= "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.Range","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var SINGLE_RANGE_MSG="<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.Range")%>";
//XSSOK
<%-- Multitenant--%>
<%--var INVALID_MSG= "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.Invalid","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var INVALID_MSG="<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.Invalid")%>";
//XSSOK
<%-- Multitenant--%>
<%--var VALUE_SEPARATOR_MSG= "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.DiffValues","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var VALUE_SEPARATOR_MSG="<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.DiffValues")%>";
//Added for V6R2009.HF0.2 - Starts
//XSSOK
<%-- Multitenant--%>
<%--var FN_VALIDATION = "<%=i18nNow.getI18nString("emxEngineeringCentral.FindNumber.ValidationFailed","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var FN_VALIDATION = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.FindNumber.ValidationFailed")%>";
//XSSOK
<%-- Multitenant--%>
<%--var RD_VALIDATION = "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.ValidationFailed","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var RD_VALIDATION = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.ValidationFailed")%>";
//XSSOK
<%-- Multitenant--%>
<%--var FN_UNIQUE_MSG = "<%=i18nNow.getI18nString("emxEngineeringCentral.FindNumber.Unique","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var FN_UNIQUE_MSG = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.FindNumber.Unique")%>";
//XSSOK
<%-- Multitenant--%>
<%--var RD_UNIQUE_MSG = "<%=i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.Unique","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var RD_UNIQUE_MSG = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.Unique")%>";
//Added for V6R2009.HF0.2 - Ends
//Start Bug 358154
var DISPFIELDRETURN_ALERT_MSG = "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.EditFieldReturnDispositionCodes</emxUtil:i18nScript>";
var DISPINFIELD_ALERT_MSG = "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.EditInFieldDispositionCodes</emxUtil:i18nScript>";
var DISPINPROCESS_ALERT_MSG = "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.EditInProcessDispositionCodes</emxUtil:i18nScript>";
var DISPINSTOCK_ALERT_MSG = "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.EditInStockDispositionCodes</emxUtil:i18nScript>";
var DISPONORDER_ALERT_MSG = "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.EditOnOrderDispositionCodes</emxUtil:i18nScript>";
//XSSOK
<%-- Multitenant--%>
<%--var FOR_REVISE = "<%=i18nNow.getI18nString("emxFramework.Range.Requested_Change.For_Revise","emxFrameworkStringResource",accLanguage)%>";--%>
var FOR_REVISE = "<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.Requested_Change.For_Revise")%>";
//XSSOK
<%-- Multitenant--%>
<%--var FOR_OBSOLESCENCE = "<%=i18nNow.getI18nString("emxFramework.Range.Requested_Change.For_Obsolescence","emxFrameworkStringResource",accLanguage)%>";--%>
var FOR_OBSOLESCENCE = "<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.Requested_Change.For_Obsolescence")%>";
//End Bug 358154
//XSSOK
var RANGE_SEPARATOR="<%=JSPUtil.getCentralProperty(application,session,"emxEngineeringCentral","RangeReferenceDesignatorSeparator")%>";
//XSSOK
var SINGLE_SEPARATOR="<%=JSPUtil.getCentralProperty(application,session,"emxEngineeringCentral","DelimitedReferenceDesignatorSeparator")%>";

//chetan
//XSSOK
var STR_DEC_SYM = "<%=FrameworkProperties.getProperty(context, "emxFramework.DecimalSymbol")%>";

//IR-133539V6R2013
//XSSOK
<%-- Multitenant--%>
<%--var CustomView_Alert_Msg = "<%=i18nNow.getI18nString("emxEngineeringCentral.Customview.Requiredcolumnsmissingalert","emxEngineeringCentralStringResource",accLanguage)%>";--%>
var CustomView_Alert_Msg = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Customview.Requiredcolumnsmissingalert")%>";
var mType = colMap.getColumnByName("Type");
var mName = colMap.getColumnByName("Name");
var mRev = colMap.getColumnByName("Revision");
var mRD = colMap.getColumnByName("Reference Designator");
var mFN = colMap.getColumnByName("Find Number");
var mQty= colMap.getColumnByName("AT_C_Quantity");
var mUOM= colMap.getColumnByName("UOM");
var mState= colMap.getColumnByName("State");
var isENCBOM = this.location.href.indexOf("&table=ENCEBOMIndentedSummary") > -1

if (isENCBOM && (mRD == undefined || mFN == undefined || mQty == undefined || mUOM == undefined || mType == undefined || mName == undefined || mRev == undefined || mState == undefined)) {
      alert(CustomView_Alert_Msg);
}




/******************************************************************************/
/* function isEmpty() - checks whether the value is blank or not              */
/*                                                                            */
/******************************************************************************/

function isEmpty(s)
{
  return ((s == null)||(s.length == 0));
}

/******************************************************************************/
/* function isNumeric() - checks whether the value is numeric or not          */
/*                                                                            */
/******************************************************************************/

function isNumeric(varValue)
{
    if (isNaN(varValue))
    {
        return false;
    } else {
        return true;
    }
}

/******************************************************************************/
/* function chkLength() - returns true is length of the text field             */
/* is below the specified length.                                              */
/******************************************************************************/

function chkLength(validLength,txtLength)
{
     return((validLength!=0 && txtLength.length>validLength));

}



/******************************************************************************/
/* function isInteger() - returns true if the text field is Interger             */
/* add for the bug 345214                                             */
/******************************************************************************/

function isInteger(str)
{
	var num = "0123456789";
	for(var i=0;i<str.length;i++)
	{
		if(num.indexOf(str.charAt(i))==-1)
		{
		  alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotValid</emxUtil:i18nScript>");
		  return false;
		}
	}
	return true;
}

 /******************************************************************************/
 /* function trim() - removes any leading spaces                               */
 /*                                                                            */
 /******************************************************************************/

    function trim(str)
    {
      while(str.length != 0 && str.substring(0,1) == ' ')
      {
        str = str.substring(1);
      }
      while(str.length != 0 && str.substring(str.length -1) == ' ')
      {
        str = str.substring(0, str.length -1);
      }
      //039096 - Starts
      while (str.length != 0 && str.match(/^\s/) != null) {
      	str = str.replace(/^\s/, '');
      }
      //039096 - Ends
      return str;
    }

/******************************************************************************/
/* function isFNUnique() - returns true if the supplied value                 */
/* is unique with respect to the other values on the form.			          */
/* takes column values and new value as arguments			                  */
/******************************************************************************/

function isFNUnique(cellData, inputFN, cellActualValue)
{
    var arrayValue="";
    var parsedinputFN = parseFloat(inputFN);
    for(var i=0;i < cellData.length; i++)
    {
       arrayValue = cellData[i];;
       if(cellData[i]!="" && parseFloat(cellData[i])==parseFloat(inputFN) && cellData[i]!=cellActualValue){
           return false;
       }
      
    }

    return true;
}

/********************************************************************************* /
/* function isRDAlphaNumeric(string) - returns the valid format of alphaNumeric  */
/* value of Reference Designator  . It returns true if it is valid else false    */
/********************************************************************************/
function isRDAlphaNumeric(string)
{
    var format=string.match(/^[a-zA-Z]+[0-9]+$/g);

    if(format)
    {
      return true;
    }
    else
    {
      return false;
    }

    return true;
}


/*******************************************************************************/
/* function isRDFormatCorrect(str)(stralpha) - returns the well formed value of*/
/* Reference Designator. The format depends on the forma rules .               */
/* It returns true if well formed else returns false.                          */
/*******************************************************************************/

function isRDFormatCorrect(stralpha)
{

  var string= stralpha;
  var check = new Array();
  var delim=false;
  var merge=true;
  finalstr=string;

  if((string.lastIndexOf(RANGE_SEPARATOR)==(string.length-1)) || (string.indexOf(RANGE_SEPARATOR)==0))
  {
      alert(INVALID_FORMAT_MSG);
      return false;

  }
  else if((string.indexOf(RANGE_SEPARATOR)==string.lastIndexOf(RANGE_SEPARATOR)) && string.indexOf(SINGLE_SEPARATOR)<=-1)
  {
      range=string.split(RANGE_SEPARATOR);

      if(range.length<=2)
      {
          string=range.join();
      }
  }

  check=string.split(SINGLE_SEPARATOR);

  for(var i=0;i < check.length;i++)
  {
      var str=check[i].toString();

      if ((str.lastIndexOf(RANGE_SEPARATOR)) > (str.indexOf(RANGE_SEPARATOR)))
      {
        alert(SINGLE_RANGE_MSG);
        return false;
      }
  }


  if((string.indexOf(SINGLE_SEPARATOR)> 0) && (string.lastIndexOf(SINGLE_SEPARATOR)!=(string.length-1)))
  {
      var hyphenval=new Array()
      for(var j=0;j < check.length;j++)
      {
          st=check[j].toString();
          if (st.indexOf(RANGE_SEPARATOR) > -1)
          {
              var temp=st.split(RANGE_SEPARATOR);
              hyphenval.push(temp[0])
              hyphenval.push(temp[1])
          }
          else
          {
              hyphenval.push(st);
          }
      }

      if(hyphenval.length > 1)
      {
          prevstr = hyphenval[0].match(/^[a-zA-Z]*/g);
          for(var k=0;k<hyphenval.length;k++)
          {
              newstr = hyphenval[k].match(/^[a-zA-Z]*/g);
              if(prevstr.toString()==newstr.toString())
              {
                   delim=true;
                   continue ;
              }
              else
              {
                   alert(MULTI_PREFIX_MSG);
                   delim=false;
                   return false;
              }
          } // for
      } //if
  } // if string.indexOf

  if (delim)
  {
      for(i=0;i<hyphenval.length;i++)
      {
         var str=hyphenval[i];
         bol=isRDAlphaNumeric(str);
         if (!bol)
         {
                break;
         }
         else
         {
                qty=1;
         }
       } //for
   }
   else
   {
       qty=0;
       bol=isRDAlphaNumeric(string);
   }

   if(!bol)
   {
           alert(INVALID_CHAR_MSG);
           return false;
   }

   return true;
}// end of function

function validateUsage()
{
	var cellData = getColumnDataAtLevel();
	var inputUsage = trim(arguments[0]);
	var objectType = getActualValueForColumn("Type");
	var objectName = getActualValueForColumn("Name");
	var objectrev = getActualValueForColumn("Revision");
	//XSSOK
	var partType = "<%=PropertyUtil.getSchemaProperty(context,"type_Part")%>";

    /*	354346
	if(objectType=="Manufacturing Part" )
	{
    //changed for Internationalization support
	<%--Multitenant--%>
	<%--alert("<%=i18nNow.getI18nString("emxMBOM.MassUpdate.MfgPartValidation","emxMBOMStringResource",accLanguage)%>");--%>
	alert("<%=EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.MassUpdate.MfgPartValidation")%>");
	return false;
	} else {
		// creating HTTP request
		var url = "/ematrix/engineeringcentral/emxMBOMgetpolicyforMassupdate.jsp?type="+objectType+"&name="+objectName+"&rev="+objectrev;
		var oXMLHTTP = emxUICore.createHttpRequest();
		oXMLHTTP.open("post", url, false);
		oXMLHTTP.send(null);
		var result = oXMLHTTP.responseText;
		result = trimAll(result);
		if(result =="Standard Part")
		{
			//changed for Internationalization support
			<%--Multitenant--%>
			<%--alert("<%=i18nNow.getI18nString("emxMBOM.MassUpdate.MfgPartValidation","emxMBOMStringResource",accLanguage)%>");--%>
			alert("<%=EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.MassUpdate.MfgPartValidation")%>");
			return false;
		} else
   354346 */
		if(objectType == partType && inputUsage =="Reference-Mfg")
		{
			//changed for Internationalization support
			//XSSOK
			<%--Multitenant--%>
			<%--alert("<%=i18nNow.getI18nString("emxMBOM.MassUpdate.ECPartValidation","emxMBOMStringResource",accLanguage)%>");--%>
			alert("<%=EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.MassUpdate.ECPartValidation")%>");
			return false;
		} else {
				return true;
		}
//	}
}
/* function to remove new line/form feed/return characters
MBOM */
function trimAll(sString)
{
	while (sString.substring(0,1) == ' ' || sString.substring(0,1) == '\n' || sString.substring(0,1) == '\f' || sString.substring(0,1) == '\r')
	{
		sString = sString.substring(1, sString.length);
	}
	while (sString.substring(sString.length-1, sString.length) == ' '|| sString.substring(sString.length-1, sString.length) == '\n' || sString.substring(sString.length-1, sString.length) == '\f' || sString.substring(sString.length-1, sString.length) == '\r')
	{
		sString = sString.substring(0,sString.length-1);
	}
	return sString;
}
/***************************************************************************** /
/* function getRDQuantity(string) - returns the no. of Reference Designator   */
/*   components. It returns 1 if the RD is a single value else returns        */
/*   the no. of RD components.This function has to be used when the           */
/*   RD value is given.                                                       */
/*****************************************************************************/
   function getRDQuantity(string)
   {
       var str1=string;
       var tot=0;
	   if (str1==null || str1=="null" || str1=="")
	      return 0;
       if((str1.indexOf(SINGLE_SEPARATOR) !=-1) && (str1.indexOf(RANGE_SEPARATOR) != -1))
       {
          hyp = str1.split(SINGLE_SEPARATOR);
          for(var i=0,diff1=0,delimct=0;i<hyp.length;i++)
          {
            st=hyp[i];

            if(st.indexOf(RANGE_SEPARATOR)!=-1)
            {
               ctr= (st.indexOf(RANGE_SEPARATOR));
               num1=st.substring(0,st.indexOf(RANGE_SEPARATOR));
               num2=st.substring(st.indexOf(RANGE_SEPARATOR)+1);
			   diff1= sumRDRange(num1,num2);
               tot=tot+diff1;
             }
             else
             {
               delimct++;
             }
        }

      	return (tot+delimct);

      }
      else if(str1.indexOf(SINGLE_SEPARATOR)!=-1)
      {
		   ctr=str1.split(SINGLE_SEPARATOR);
           return ctr.length;
      }
      else if(str1.indexOf(RANGE_SEPARATOR)!=-1)
      {
		   num1=str1.substring(0,str1.indexOf(RANGE_SEPARATOR));
           num2=str1.substring(str1.indexOf(RANGE_SEPARATOR)+1);
           diff1=sumRDRange(num1,num2);
           return diff1;
      }
      else
      {
		   return 1;
      }
	return 0;
   }


/********************************************************************* /
/* function sumRDRange(num1,num2) - returns the no. of Reference      */
/*  Designator components in a range . It returns the range of the RD */
/**********************************************************************/
  function sumRDRange(num1,num2)
  {

     var txt1=num1.match(/[0-9]*$/g);
     var txt2=num2.match(/[0-9]*$/g);
     arr1=txt1.toString().split(SINGLE_SEPARATOR);
     arr2=txt2.toString().split(SINGLE_SEPARATOR);
     var diff1 =parseInt(arr2[0]) -parseInt(arr1[0]);
     return ++diff1;
  }

/*******************************************************************************/
/* function validateFNByLevel()                                                */
/* Validates the Find Number entered from indented table edit  .               */
/*******************************************************************************/
//R208.HF1 - Starts
//function validateFNByLevel()
function validateFNByLevel(str1,str2)
//R208.HF1 - Ends
{
    //R208.HF1 - Starts
    //if(str2 == "lookup")
    if(str2 == "lookup" && str1 == "")
    {
        return true;
    }
    //R208.HF1 - Ends
	var cellData   = getColumnDataAtLevel();
    //var inputFN    = trim(arguments[0]);//Modified for the IR-027159
    //Commented and modified for IR-028188 and IR-031153 - Starts
    //var inputFN = arguments[0].replace(/^\s*/, "").replace(/\s*$/, "").replace(/\W/g,"");
    var inputFN    = trim(arguments[0]);
    if (inputFN.length == 1 && !isNaN(inputFN) && undefined == eval(inputFN)) {
        inputFN = "";
    }
    //Commented and modified for IR-028188 and IR-031153 - Ends
    var objectType = getActualValueForColumn("Type");
    var fnRequired = fnPropertyArray[objectType];
    var rdValue    = getValueForColumn(attRefDes);
    var rdRequired = rdPropertyArray[objectType];

    //Below code is to bypass the current cell from the array
    //to avoid checking of value against itself.
    var cellActualValue = getValueForColumn(attFindNumber);

   // var findNumberCellData = new Array();
   // var fnIndex=0;
   /* for(var i=0;i<cellData.length;i++)
    {
		if(cellData[i]!="" && cellData[i]!=cellActualValue)
		{
			findNumberCellData[fnIndex]=cellData[i];
			fnIndex++;
		}
	}*/

    //Above code is to bypass the current cell from the array
    //to avoid checking of value against itself.
	//R208.HF1 - Starts
    //  //verfieid for undefined values of the variables for R208.HF1
    //if(fnRequired.toLowerCase()=="true" && fnUniqueness.toLowerCase()=="true" && rdRequired.toLowerCase()=="true" && rdUniqueness.toLowerCase()=="true")
    if(fnRequired && fnUniqueness && rdRequired && rdUniqueness && fnRequired.toLowerCase()=="true" && fnUniqueness.toLowerCase()=="true" && rdRequired.toLowerCase()=="true" && rdUniqueness.toLowerCase()=="true")
    //R208.HF1 - Ends
    {
    	if(!validateFNRDByLevel(inputFN,rdValue,fnRequired,rdRequired))
    	{
			return false;
		}
	}
	else
	{
        //R208.HF1 - Starts
        //if(fnRequired.toLowerCase()!="false")
        if(fnRequired && fnRequired.toLowerCase()!="false")
        //R208.HF1 - Ends
        {
            //if(isEmpty(inputFN))
            if(inputFN == null || inputFN.length == 0)
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
                return false;
            }
        }
	}

    //R208.HF1 - Starts
	//if(fnUniqueness.toLowerCase()=="true" && !isFNUnique(findNumberCellData,inputFN))
     if(fnUniqueness && fnUniqueness.toLowerCase()=="true" && !isFNUnique(cellData,inputFN,cellActualValue))
    //R208.HF1 - Ends
	{
  	    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
        return false;
	}
    //R208.HF1 - Starts
	//else if(fnUniqueness.toLowerCase()!="true" && rdUniqueness.toLowerCase()!="true")
    else if(fnUniqueness && rdUniqueness && fnUniqueness.toLowerCase()!="true" && rdUniqueness.toLowerCase()!="true")
    //R208.HF1 - Ends
	{

//		if(!isFNUnique(findNumberCellData,inputFN))
		if(!isFNUnique(cellData,inputFN,cellActualValue))
		{
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
			return false;
		}
	}
	if(chkLength(fnLength,inputFN))
	{
		alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldLengthExceedsMaxLimit</emxUtil:i18nScript>"+" "+fnLength);
		return false;
	}
	/* 	add for the bug 345214	*/
	
	
		if(!isInteger(inputFN))
		{
			return false;
		}
	



    return true;
}

/*******************************************************************************/
/* function validateRDByLevel()                                                */
/* Validates the Reference Designator entered from indented table edit         */
/*******************************************************************************/
//R208.HF1 - Starts
//function validateRDByLevel()
function validateRDByLevel(str1,str2)
//R208.HF1 - Ends
{
    //R208.HF1 - Starts
    if(str2 == "lookup")
    {
        return true;
    }
    //R208.HF1 - Ends
    var cellData   = getColumnDataAtLevel();
    var inputRD    = arguments[0];
    var objectType = getActualValueForColumn("Type");
    var fnRequired = fnPropertyArray[objectType];
	var fnValue    = getValueForColumn(attFindNumber);
	var rdRequired = rdPropertyArray[objectType];
    //Below code is to bypass the current cell from the array
    //to avoid checking of value against itself.
    var cellActualValue = getValueForColumn(attRefDes);
    var refDesignatorCellData = new Array();
    var refIndex=0;
	var qtyvalue = getValueForColumn(attQty);
    for(var i=0;i<cellData.length;i++)
    {
		if(cellData[i]!="" && cellData[i]!=cellActualValue)
		{
			refDesignatorCellData[refIndex]=cellData[i];
			refIndex++;
		}
	}
    //Above code is to bypass the currentcell from array
    //to avoid checking of value against itself

    if(fnRequired && fnUniqueness && rdRequired && rdUniqueness && fnRequired.toLowerCase()=="true" && fnUniqueness.toLowerCase()=="true" && rdRequired.toLowerCase()=="true" && rdUniqueness.toLowerCase()=="true")
    {

	    if(!validateFNRDByLevel(fnValue,inputRD,fnRequired,rdRequired))
	    {
			return false;
		}
	}
	else
	{
         if(rdRequired && rdRequired.toLowerCase()!="false")
         {
             //if(isEmpty(inputRD))
             if(inputRD == null || inputRD.length == 0)
             {
                 alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.RDfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
                 return false;
             }
  	     }
	 }
     if(inputRD!="")
     {
         if(!isRDFormatCorrect(inputRD))
         {
              return false;
         } else{
			var rdQty = getRDQuantity(inputRD);
			  
			if(((rdRequired && rdRequired.toLowerCase()=="true") || (rdRequired && rdQtyValidation && (rdRequired.toLowerCase()=="false"))) && (rdQtyValidation.toLowerCase()=="true"))
			  {
			  qtyvalue = Math.round(qtyvalue);
			    if (qtyvalue != rdQty)
				  {
					alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity</emxUtil:i18nScript>");
					return false;
				  }
			  }
		 }
         if(rdUniqueness && rdUniqueness.toLowerCase()=="true")
         {

            if(!isRDUnique(refDesignatorCellData.join(),inputRD))
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.RDNotUniqueForTNR</emxUtil:i18nScript>"+" "+inputRD);
                return false;
            }
         }
     }
     if(chkLength(rdLength,inputRD))
     {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.Length </emxUtil:i18nScript>"+rdLength);
        return false;
     }
  return true;
}

/*******************************************************************************/
/* function validateQuantity()                                                 */
/* Validates the Quantity entered from indented table edit                     */
/*******************************************************************************/
//R208.HF1 - Starts
//function validateQuantity()
function validateQuantity(str1,str2)
//R208.HF1 - Ends
{
    //R208.HF1 - Starts
    if(str2 == "lookup")
    {
       return true;
    }
    //R208.HF1 - Ends
    var qtyvalue = arguments[0];
    var rows=emxEditableTable.getRowColumnValues(0);
    for(var j=0 ; j < rows.length ; j++)
    {        
   		 rows[j]= rows[j].Name;
   		 if(rows.indexOf("UOM")!= -1){
   		 	 var rdUOM = getValueForColumn("UOM");
   		 }
    }
    //351137
    var rdValue = getValueForColumn(attRefDes);
    //IR017352
   
    var NumberofDigitsAfterDecimal = 0;
    // 361185
    var objectType = getActualValueForColumn("Type");
    var rdRequired = rdPropertyArray[objectType];

    if(qtyvalue != null)
    {
      if( isEmpty(qtyvalue)) {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.Quantityfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
        return false;
      }
      if (qtyvalue.indexOf(",") != -1 ) {
        qtyvalue = qtyvalue.replace(",", ".");
      }
      if(!isNumeric(qtyvalue))
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeANumber</emxUtil:i18nScript>");
        return false;
      }

     //Modified the condition for IR A0672251
     var qtyvalue1 = parseFloat(qtyvalue);
     if(qtyvalue == '0' || qtyvalue == '0.0' || qtyvalue == '+0' || qtyvalue1 == '0.0')
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeGreaterThanZero</emxUtil:i18nScript>");
        return false;
      }
      if((qtyvalue).substr(0,1) == '-')
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeAPositiveNumber</emxUtil:i18nScript>");
        return false;
      }

	  // #IR017352
      if(rdUOM != undefined){
      if((rdUOM.slice(0, 2) == "EA")){
      if(checkForDecimal(qtyvalue)) {
	      alert(VPLM_EA_EACH_STRING);
      return false;
      }
      }
      }

      /*commented for the bug no 332272
      // added for the bug no 305791
      if(qtyvalue.indexOf(".") != -1){
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeNumber</emxUtil:i18nScript>");
                qtyobj.focus();
                return;
                    }
      	//end the bug no 305791
      */
      if (rdValue!=null && rdValue!="null" && rdValue!="")
	  {
 	      //Modified below code to fix 323806
		  if (isRDFormatCorrect(rdValue)) {
			  var rdQty = getRDQuantity(rdValue);
			  // 361185
			  
			if(((rdRequired && rdRequired.toLowerCase()=="true") || (rdRequired && rdQtyValidation && (rdRequired.toLowerCase()=="false"))) && (rdQtyValidation.toLowerCase()=="true"))
			  {
			  qtyvalue = Math.round(qtyvalue);
				  if (qtyvalue != rdQty)
				  {
					alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity</emxUtil:i18nScript>");
					return false;
				  }
			  }
		  } else {
		     return false;
		  }
	  }

    }
    return true;
}

// added for IR017352
function checkForDecimal(num)
{
	return num%1 ? true : false;
}

//R208.HF1 - Starts
/********************************************************************************* /
/* function isPolicy(Pname) -    */
/********************************************************************************/
function isPolicy(Pname)
{

   Pname = trim(Pname);
     Pname = Pname.replace(/\W/g,"_");
 if(Pname!=null && Pname!="" && Pname != " "){
   var sresult= "";
   sresult = newArray[Pname];
    emxEditableTable.setCellValueByRowId(currentRow.getAttribute("id"),"Revision",sresult,sresult,true);
  }
  return true;
}

String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
}
/*******************************************************************************/
/* function validateTargetCost()                                                 */
/* Validates the TargetCost entered from indented table edit                     */
/*******************************************************************************/

function validateTargetCost()
{
    //Below code added for IR-402812 - Target Cost Dimension
    //var qtyvalue = arguments[0];
    var tcValue = arguments[0];
	var SplitVal = tcValue.split(" ");
	 var qtyvalue = SplitVal[0];
   if(SplitVal[1] == "undefined"){
   	alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.TargetCostHasToBeANumber</emxUtil:i18nScript>");
   	return false;
   }
   //End of modification for IR-402812
   //IR-033986-Starts
      if( isEmpty(qtyvalue) || qtyvalue == " ") {
      		alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.TargetCostIsEmpty</emxUtil:i18nScript>");
      		return false;
            	}
       //IR-033986-Ends
      
      
      if (qtyvalue.indexOf("  ") > -1 ) {
             alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.TargetCostHasToBeANumber</emxUtil:i18nScript>");
              return false;
          }
    
      if(qtyvalue != null){
      
		if(!isNumericGeneric(qtyvalue)){
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.TargetCostHasToBeANumber</emxUtil:i18nScript>");
			return false;
		}
		if(parseFloat(qtyvalue) == '0'){
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.TargetCostHasToBeGreaterThanZero</emxUtil:i18nScript>");
			return false;
		}
		if((qtyvalue).substr(0,1) == '-'){
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.TargetCostHasToBeAPositiveNumber</emxUtil:i18nScript>");
			return false;
		}

   	}
    return true;
}
/*******************************************************************************/
/* function validateEstimatedCost()                                               */
/* Validates the validateEstimatedCost entered from indented table edit                     */
/*******************************************************************************/

function validateEstimatedCost()
{
   //Below code added for IR-068994 - Estimated Cost Dimension
    var ecValue = arguments[0];
	var SplitVal = ecValue.split(" ");
	 var qtyvalue = SplitVal[0];
   if(SplitVal[1] == "undefined"){
   	alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.EstimatedCostHasToBeANumber</emxUtil:i18nScript>");
   	return false;
   }
   //End of modification for IR-068994
   //IR-033986-Starts
         if( isEmpty(qtyvalue) || qtyvalue == " ") {
         		alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.EstimatedCostIsEmpty</emxUtil:i18nScript>");
         		return false;
               	}
      //IR-033986-Ends
   
   if (qtyvalue.indexOf("  ") > -1 ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.EstimatedCostHasToBeANumber</emxUtil:i18nScript>");
        return false;

    }
	if(qtyvalue != null){

		if(!isNumericGeneric(qtyvalue)){
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.EstimatedCostHasToBeANumber</emxUtil:i18nScript>");
			return false;
		}

		if(qtyvalue == '0' || qtyvalue == '0.0' || qtyvalue == '+0' ){
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.EstimatedCostHasToBeGreaterThanZero</emxUtil:i18nScript>");
			return false;
		}

		if((qtyvalue).substr(0,1) == '-'){
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.EstimatedCostHasToBeAPositiveNumber</emxUtil:i18nScript>");
			return false;
		}

	}
    return true;
}
//R208.HF1 - Ends
/*******************************************************************************/
/* function validateQuantityonApply()                                          */
/* Validates the Quantity and RD values on Apply Edits                         */
/*******************************************************************************/

function validateQuantityonApply()
{
    var rdValue = getValueForColumn(attRefDes);
    var qtyvalue = getValueForColumn(attQty);
    if(qtyvalue != null)
    {
      if (qtyvalue.indexOf(",") != -1 ) {
        qtyvalue = qtyvalue.replace(",", ".");
      }
      if(!isNumeric(qtyvalue))
      {
        return "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeANumber</emxUtil:i18nScript>";
      }
     //Modified the condition for IR A0672251
     var qtyvalue1 = parseFloat(qtyvalue);
     if(qtyvalue == '0' || qtyvalue == '0.0' || qtyvalue == '+0' || qtyvalue1 == '0.0')
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeGreaterThanZero</emxUtil:i18nScript>");
        return false;
      }
      if((qtyvalue).substr(0,1) == '-')
      {
        return "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeAPositiveNumber</emxUtil:i18nScript>";
      }
      if (rdValue!=null && rdValue!="null" && rdValue!="")
	  {
 	      var rdQty = getRDQuantity(rdValue)
 	      qtyvalue = Math.round(qtyvalue);
	      if (qtyvalue != rdQty)
	      {
            var msg = "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg1</emxUtil:i18nScript>";
		    msg = msg + " " + rdValue;
		    msg = msg + " " + "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg2</emxUtil:i18nScript>";
		    msg = msg + " " + qtyvalue;
		    msg = msg + "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg3</emxUtil:i18nScript>";
            return msg;
	      }
	  }
    }
    return "";
}

/**********************************************************************************/
/* function validateFNRDByLevel - common method used to call validateFNRD method   */
/* whose argument values change depending on from where the function is called    */
/*                                                                                */
/**********************************************************************************/


function validateFNRDByLevel(fnValue,rdValue,fnRequired,rdRequired)
{
    if(!validateFNRD(fnValue,rdValue,fnRequired,rdRequired))
    {
		return false;
	}
 return true;
}

/**********************************************************************************/
/* function validateFNRD - validates the Find number and Reference Designator     */
/* for empty,length,RD Format and returns false if any value violates             */
/*                                                                                */
/**********************************************************************************/
function validateFNRD(fnObjValue,rdObjValue,fnRequired,rdRequired)
{
//    var findNumberValue = (isEmpty(fnObjValue))?fnObjValue:trim(fnObjValue);
    var findNumberValue = (fnObjValue== null ||fnObjValue.length == 0)?fnObjValue:trim(fnObjValue);
    var rdvalue         = rdObjValue;
    if(ebomUniquenessOperator.toLowerCase()=="and")
    {
              //if(isEmpty(findNumberValue))
              if(findNumberValue == null ||findNumberValue.length == 0)
              {
                  alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
                  return false;
              }
              //if(isEmpty(rdvalue))
              if(rdvalue == null || rdvalue.length == 0)
              {
                 alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.RDfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
                 return false;
              }
              if (!isRDFormatCorrect(rdvalue))
              {
                 return false;
              }

    }
    if(ebomUniquenessOperator.toLowerCase()=="or")
    {
//        if(isEmpty(findNumberValue) && isEmpty(rdvalue))
if((findNumberValue == null || findNumberValue.length == 0) && (rdvalue == null || rdvalue.length == 0))
        {
             alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNAndRDfieldemptypleaseenterAnyOne</emxUtil:i18nScript>");
             return false;
        }
        if(!(rdvalue == null || rdvalue.length == 0))
        {
            if(!isRDFormatCorrect(rdvalue))
            {
                return false;
            }
        }
     }

   return true;
}

   /****************************************************************/
   /* function isRDUnique(refarray,strval) returns true if         */
   /* Reference Designator. is unique                              */
   /*  It returns false if teh RD is not unique                    */
   /****************************************************************/

  function isRDUnique(refarray,strval)
  {
     var refstr=strval.split(SINGLE_SEPARATOR);
     var refval= refarray.split(SINGLE_SEPARATOR);

     var strflat = "";
     if(!checkUnique(refstr))
     {
         return false;
     }
     else
     {
          var strarr = flattenRD(refval);
          if(strarr.indexOf(SINGLE_SEPARATOR)==0)
          {
             strarr=strarr.substring(1);
          }

          var refarr = strarr.split(SINGLE_SEPARATOR);
          var strflat = flattenRD(refstr);
          strcheck = strflat.split(SINGLE_SEPARATOR);

          for (var i=0;i < strcheck.length;i++)
          {
              if (strcheck[i].toString().length!=0)
              {
                for(var j=0 ; j < refarr.length; j++)
                {
                    if (strcheck[i].toString()==refarr[j].toString())
                    {
                        return false;
                    }
                }
              }
          }

      }
      return true;
  }

   /**********************************************************************/
   /* function checkUnique() - returns true if the Rd value is unique    */
   /*  Used by the checkRefUnique() method for validating the rd value   */
   /*  This function have to be used when the property of unique         */
   /*  is set to true for a Part.                                        */
  /***********************************************************************/
  function checkUnique(refvalue)
  {

    str=refvalue.join();
    var longstr="";
    arr=str.split(SINGLE_SEPARATOR);
    var finalarr=new Array();

    longstr = flattenRD(arr);
    st2=longstr.split(SINGLE_SEPARATOR);
    finalarr=st2;
    finalarr.sort();


    for(i=0;i<finalarr.length-1;i++)
    {
           for(var j=i+1;j<finalarr.length;j++)
           {
            if (finalarr[i].toString().length!=0 && finalarr[j].toString().length!=0)
                {
                if(finalarr[i].toString()==finalarr[j].toString())
                {
					alert(NOT_UNIQUE_MSG+finalarr[i] );
					return false;
                }
            }
         }
      }

  return true;
}

/****************************************************************/
  /* function flattenRD(strarr) - returns the RD string flattened */
  /* Reference Designator. The format depends on the format rules */
  /*  It returns the string with each RD vale.                    */
  /****************************************************************/

function flattenRD(strarr)
{
    var arr = strarr;
    var longstr="";
    var dbval;
    var newarr;
    for(i=0;i < arr.length;i++)
    {
           newarr=new Array();
           newstr=arr[i];
           //IR-028660V6R2011
           if(typeof newstr!="undefined" && newstr.indexOf(RANGE_SEPARATOR) != -1)
           {
                var st=arr[i];
                str=st.split(RANGE_SEPARATOR);
                ctr=sumRDRange(str[0],str[1]);
                if(ctr > 0)
                {
                    var  val=str[0].toString().match(/[0-9]*$/g);
                    var alpha=str[0].toString().match(/^[a-zA-Z]*/g);
                    num = val.toString().substring(0,val.toString().indexOf(SINGLE_SEPARATOR));
                    st=arr[i];
                   for(var k=0,m=i+1;ctr > 1;k++,ctr--,m++)
                   {
                         st1=st.substring(0,st.indexOf(RANGE_SEPARATOR));
                         if(k==0)
                         {
                              n = parseInt(num)+1;
                            }
                        else
                        {
                              n++;
                        }
                newarr[k]=alpha + n.toString();
                 }  //end of for
             longstr=longstr + SINGLE_SEPARATOR + str[0] + SINGLE_SEPARATOR + newarr.join();
             arr[i]=st1;
           }
        }
        else
        {
             if (i==0)
             {
                 longstr=newstr;
             }
             else
             {
                longstr = longstr + SINGLE_SEPARATOR + newstr ;
             }
           }
        } // end of for
        return longstr;
  }

/**************************************************************************/
/* function validateFindNumberOnApply() - validates the Find Number       */
/* on Apply. this is mathod is setting for table "ENCEBOMIndentedSummary" */
/* on the column "Find Number".                                           */
/* Added for V6R2009.HF0.2                                                          */
/**************************************************************************/
var FNcount = 1;
var arrFNError = new Array();
//R208.HF1 - Starts
//function validateFindNumberOnApply()
function validateFindNumberOnApply(str1,str2){
	if(str2 == "lookup")
	{
		return true;
	}
    //R208.HF1 - Ends
    var returnMsgFN = "";
    //Reverting back commented code for 354346 - starts
    try{
        var returnMsgFN = "";
        //Fix for Bug #360022 - Starts
        //The following code has been commented to fix this bug
        //var objectType = getActualValueForColumn("Type");
        //var fnRequired = fnPropertyArray[objectType];
        //Fix for Bug #360022 - Ends

        if(fnUniqueness && fnUniqueness.toLowerCase()=="true"){

            var objColumnFN = colMap.getColumnByName(attFindNumber);
            var nodeList = emxUICore.selectNodes(oXML.documentElement, "//c["+ objColumnFN.index +"][@edited = 'true']");
            var totalRows = nodeList.length;
            var mCurrentRow = nodeList[FNcount-1].parentNode;
            var currentRowValue = arguments[0];
            var alevel = mCurrentRow.getAttribute("level");
            var arowId = mCurrentRow.getAttribute("id");

            var currentParentRowId = mCurrentRow.parentNode.getAttribute("id");

            var aSiblingRows = emxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@level = '" + alevel + "' and @id != '" + arowId + "']");

            for(var i=0;i < aSiblingRows.length; i++){
                var siblingParentRowId = aSiblingRows[i].parentNode.getAttribute("id");
                if(siblingParentRowId != currentParentRowId){
                    continue;
                }

                var status = aSiblingRows[i].getAttribute("status");
                if(status != null && (typeof status != 'undefined') && status == 'cut'){
                    continue;
                }
                var lastobj = emxUICore.selectSingleNode(aSiblingRows[i], "c[" + objColumnFN.index + "]").lastChild;
                if (lastobj) {
                    var val = lastobj.nodeValue;
                    //if(val!=""){
                    if(val && val!=""){
                        if(trim(val) == trim(currentRowValue)){
                            var pattern = val+" at level "+alevel;
                            var error = arrFNError.toString();
                            if(error.indexOf(pattern) == -1){
                                arrFNError.push(val+" at level "+alevel);
                            }
                        }
                    }
                }
            }

            if(totalRows == FNcount){
                FNcount = 1;
                if(arrFNError.length > 0){
                    returnMsgFN = FN_UNIQUE_MSG+" ["+arrFNError+"]";
                }
                arrFNError = new Array();
            }
            else{
                FNcount++;
            }
        }
    } //Reverting back commented code for 354346-Ends
    catch(e){
        returnMsgFN = FN_VALIDATION+e.message;
    }
    return returnMsgFN;
}

/**************************************************************************/
/* function validateECQuantityonApply() - helps  the method               */
/* validateReferenceDesignatorOnApply to validate the Quantity field and  */
/* Reference Designator field together.                                   */
/* Added for V6R2009.HF0.2                                                          */
/**************************************************************************/
function validateECQuantityonApply(rdValue, qtyvalue)
{
	//Start : IR-060860
    if (qtyvalue.indexOf(",") != -1 ) {
        qtyvalue = qtyvalue.replace(",", ".");
    }
      //End : HF-060860
    if(qtyvalue != null)
    {
      if(!isNumeric(qtyvalue))
      {
        return "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeANumber</emxUtil:i18nScript>";
      }
      if((qtyvalue).substr(0,1) == '-')
      {
        return "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeAPositiveNumber</emxUtil:i18nScript>";
      }
      if (rdValue!=null && rdValue!="null" && rdValue!="")
      {
           var rdQty = getRDQuantity(rdValue)
           qtyvalue = Math.round(qtyvalue);
          if (qtyvalue != rdQty)
          {
            var msg = "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg1</emxUtil:i18nScript>";
            msg = msg + " " + rdValue;
            msg = msg + " " + "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg2</emxUtil:i18nScript>";
            msg = msg + " " + qtyvalue;
            msg = msg + "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg3</emxUtil:i18nScript>";
            return msg;
          }
      }
    }
    return "";
}

/**************************************************************************/
/* function validateReferenceDesignatorOnApply() - validates the          */
/* Reference Designator on Apply. this is mathod is setting for table     */
/* "ENCEBOMIndentedSummary" on the column "Reference Designator".         */
/* Added for V6R2009.HF0.2                                                          */
/**************************************************************************/
var RDcount = 1;
var arrRDError = new Array();
var arrQTYError = new Array();
function validateReferenceDesignatorOnApply(curRDVal,curQtyVal){
    try{
        var returnMsgRD = "";
	var objectType = getActualValueForColumn("Type");
	var rdRequired = rdPropertyArray[objectType];
        if((rdRequired && rdRequired.toLowerCase()=="true") || (rdRequired && rdQtyValidation && (rdRequired.toLowerCase()=="false") && (rdQtyValidation.toLowerCase()=="true"))){

            var objColumnRD = colMap.getColumnByName(attRefDes);
            var objColumnQTY = colMap.getColumnByName(attQty);

            var nodeList = emxUICore.selectNodes(oXML.documentElement, "//c["+ objColumnRD.index +"][@edited = 'true']");
            var totalRows = nodeList.length;
            if(totalRows == 0) {
        	return "";
        	}
            var mCurrentRow = nodeList[RDcount-1].parentNode;
            var currentRowValue = curRDVal;
            var alevel = mCurrentRow.getAttribute("level");
            var arowId = mCurrentRow.getAttribute("id");

            var currentParentRowId = mCurrentRow.parentNode.getAttribute("id");

            var Qty = emxUICore.selectSingleNode(mCurrentRow,"c["+objColumnQTY.index+"]");
            var QTYValue = emxUICore.getText(Qty);
	    //curQty value is used instead of QTYValue as corresponding Qty value is required to validate against RD
            var QTYError = validateECQuantityonApply(currentRowValue, curQtyVal);
            if(QTYError!=""){
                arrQTYError.push("\n"+QTYError);
            }

            //Reverting back commented code for 354346
           /* Commented for GBOM112-Starts
            var aSiblingRows = emxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@level = '" + alevel + "' and @id != '" + arowId + "']");

            for(var i=0;i < aSiblingRows.length; i++){
                var siblingParentRowId = aSiblingRows[i].parentNode.getAttribute("id");
                if(siblingParentRowId != currentParentRowId){
                    continue;
                }

                var status = aSiblingRows[i].getAttribute("status");
                if(status != null && (typeof status != 'undefined') && status == 'cut'){
                    continue;
                }
                var lastobj = emxUICore.selectSingleNode(aSiblingRows[i], "c[" + objColumnRD.index + "]").lastChild;
                if (lastobj) {
                    var val = lastobj.nodeValue;
                    //if(val!=""){
                    if(val && val!=""){
                        if(trim(val) == trim(currentRowValue)){
                            var pattern = val+" at level "+alevel;
                            var error = arrRDError.toString();
                            if(error.indexOf(pattern) == -1){
                                arrRDError.push(val+" at level "+alevel);
                            }
                        }
                    }
                }
            } // Reverting back commented code for 354346
			Comented for GBOM 112- Ends*/
            if(totalRows == RDcount){
                RDcount = 1;
                if(arrRDError.length > 0) {
                    returnMsgRD = RD_UNIQUE_MSG+" ["+arrRDError+"]";
                }

                for(var err=0;err<arrQTYError.length;err++){
                    returnMsgRD += arrQTYError[err];
                }
                arrRDError = new Array();
                arrQTYError = new Array();
            } else {
                RDcount++;
            }
        }
    }
    catch(e){
        returnMsgRD = RD_VALIDATION+e.message;
    }
    return returnMsgRD;
}

/*Following methods are added for LG -Performance Issue.
	validateFNByLevelOnApply
	getChildRows
*/

//R208.HF1 - Starts
function validateFNByLevelOnApply(str1,str2)
        {
   	if(str2 == "lookup" || str2 =="new"){
			return true;
	}
    //R208.HF1 - Ends
        var inputStr    = trim(arguments[0]);
        var inputParentRowFNArray = inputStr.split(":");

		var curFNObj;
		var siblings;
		var inputFNArray;
		var inputFNValues;
		var strMsg = "";
		var curFNVal;

		var k;
		for(var j=0;j<inputParentRowFNArray.length;j++) {
			inputFNArray = getChildRows(inputParentRowFNArray[j]);
			inputFNValues = new Array();
			k=0;
			for(var i=0;i<inputFNArray.length;i++) {
				curFNObj = inputFNArray[i];
				if(curFNObj.getAttribute('rg')){
					continue;
				}
				curFNVal = getCurrentValue("Find Number",curFNObj);
				var status = inputFNArray[i].getAttribute("status");
				//IR-028660V6R2011
				if(status !='cut'){
					inputFNValues[k] = curFNVal;
					k++;
				}
				var strMsg = validateFNValue(curFNObj,curFNVal)
				if(strMsg != "" && strMsg.length >0){
					return strMsg;

				}

			}
			strMsg = checkForUniqueness(inputFNValues);
			if(strMsg != "" && strMsg.length >0){
				return strMsg;
			}
		}

	return "";
	}

	/*
	getChildRows will retriew all the childrows from the parent
	*/
	function getChildRows(parent) {
		var mCurrentRow =emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + parent + "']");
		var childRows = emxUICore.selectNodes(mCurrentRow, "r");
		return childRows;

	}

	/**
	Method will check for the uniqueness of findnumber at the given level based on the property settings
	*/
    function checkForUniqueness(fnArray) {

	if(fnUniqueness && fnUniqueness.toLowerCase()=="true" && !isFNUniqueOnApply(fnArray))  {
		return ("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
        }
        else if(fnUniqueness && rdUniqueness && fnUniqueness.toLowerCase()!="true" && rdUniqueness.toLowerCase()!="true") {
		if(!isFNUniqueOnApply(fnArray)) {
			return ("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");

                }
        }
	return true;
    }

	//This method will check for the duplicate findnumber in the array
	function isFNUniqueOnApply(fnValueArray) {

	fnValueArray.sort(function(a,b){return a - b});
	for(var j=1;j<fnValueArray.length;j++) {
		//IR-028660V6R2011
		if(typeof fnValueArray[j]!="undefined" && typeof fnValueArray[j-1]!="undefined"){
			if(trim(fnValueArray[j-1]) != "" && trim(fnValueArray[j]) != "" && fnValueArray[j-1]==fnValueArray[j]) {
				return false;
			}
		}
	}
	return true;
	}

	/*
	This method will retriew the actual value for the given cell
	 */
	function getActualValueForOtherColumn(colName,curFNObj){
    var aRows = new Array();
    aRows[0] = curFNObj;

    var objColumn = colMap.getColumnByName(colName);
    var colIndex = objColumn.index;

    return (emxUICore.selectSingleNode(curFNObj, "c[" + colIndex + "]").getAttribute("a"));
	}

	/*
	This method will return the value for the given cell. Will return "" if row is newly added.
	*/
	function getValueForColumnOnApply(colName,curFNObj, mxLink){
    var aRows = new Array();
    aRows[0] = curFNObj;


    var objColumn = colMap.getColumnByName(colName);

    if(mxLink == "true") {
        var objDOM = emxUICore.createXMLDOM();
        objDOM.loadXML(emxUICore.selectSingleNode(curFNObj, "c[" + objColumn.index + "]").xml);
        var cNode = emxUICore.selectSingleNode(objDOM, "/c/mxLink");
        if(cNode) {
            return cNode.xml;
        }else {
            return "";
        }
    }
    var colIndex = objColumn.index;
    var isEdited = emxUICore.selectSingleNode(curFNObj, "c[" + colIndex + "]").getAttribute("edited") == "true"?true:false;
    //return nothing if the row is newly added and the cell is not edited
    if(curFNObj.getAttribute("status") == 'add' &&  !isEdited){
        return "";
    }
    var lastobj = emxUICore.selectSingleNode(curFNObj, "c[" + colIndex + "]").lastChild;
    var retValue = "";
    if (lastobj) {
        retValue = lastobj.nodeValue;
    }
    return (retValue);
	}

	/*
	This method will return the latest value i.e., modified value for the given cell
	*/
	//Modified For GBOM 112
	function getCurrentValue(colName, currentObj,flag) {
	 var aRows = new Array();
    aRows[0] = currentObj;

    var objColumn = colMap.getColumnByName(colName);

    var colIndex = objColumn.index;
    var lastobj = emxUICore.selectSingleNode(currentObj, "c[" + colIndex + "]").lastChild;
    var retValue = "";
    if (lastobj) {
        retValue = emxUICore.getText(lastobj);
    }
    return (retValue);
	}

	/**
	This method will validate the findnumber value entered.
	validateFNValue(curFNObj,curFNVal,mfgUsageVal)
	*/
	
	function validateFNValue(curFNObj,curFNVal) {
		var inputFN = curFNVal;

                var objectType = getActualValueForOtherColumn("Type",curFNObj);
                //var objectType = getActualValueForColumn("Type");
                var fnRequired = fnPropertyArray[objectType];
                var rdValue    = getValueForColumnOnApply("Reference Designator", curFNObj);
                var rdRequired = rdPropertyArray[objectType];
                var cellActualValue = getValueForColumnOnApply("Find Number", curFNObj);

                //Below Code is to bypass validation for substitutes



	                if(isNaN(inputFN)) {
	                	   //XSSOK
	                       //Multitenant
						   <%--return ("<%=i18nNow.getI18nString(msgFNValidationKey,"emxEngineeringCentralStringResource",accLanguage)%>");--%>
						   return ("<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),msgFNValidationKey)%>");

			}
	                else if ((inputFN).substr(0,1) == '-') {
	                		//XSSOK
	                        //Multitenant
						   <%--return ("<%=i18nNow.getI18nString(msgFNValidationKey,"emxEngineeringCentralStringResource",accLanguage)%>");--%>
						   return ("<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),msgFNValidationKey)%>");

			}
             if(fnRequired && rdRequired && fnRequired.toLowerCase()=="true" && rdRequired.toLowerCase()=="true") {
			        	var msgvalFNRD = validateFNRDOnApply(inputFN,rdValue,fnRequired,rdRequired)
			        	if(msgvalFNRD != "") {
							return msgvalFNRD;
					}
			}
            //IR-041871V6R2011 - Starts
            //if(fnRequired.toLowerCase()!="false") {
            if(fnRequired && rdRequired && fnRequired.toLowerCase()!="false" && rdRequired.toLowerCase() != "true") {
            //IR-041871V6R2011 - Ends
					if(inputFN == null || inputFN.length==0) {
	                                        return ("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
			                }
				}

			if(fnLength!=0 && inputFN.length>fnLength) {
	                        return ("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldLengthExceedsMaxLimit</emxUtil:i18nScript>"+" "+fnLength);
			}



       return "";
	}

	/**
	This is a custom method which is same as getColumnDataAtLevel() except the omission of call to fillupColumns
	*/
function getColumnDataAtLevelCustom(){

    var level = currentRow.getAttribute("level");
    var xpath = "r";
    var aRowsAtLevel = null;
    if (level == "0") {
        aRowsAtLevel = emxUICore.selectNodes(oXML, "/mxRoot/rows/r");
    } else {
        aRowsAtLevel = emxUICore.selectNodes(currentRow.parentNode, "r");
    }


    var returnArray = new Array();
    for(var i=0;i < aRowsAtLevel.length; i++){
        var lastobj = emxUICore.selectSingleNode(aRowsAtLevel[i], "c[" + currentColumnPosition + "]").lastChild;
        if (lastobj) {
            returnArray[i] = lastobj.nodeValue;
        }
        else {
            returnArray[i] = "";
        }
    }
    return returnArray;
	}

	/**
	This is a validateOnApply method for Reference Designator column.
	*/
	function validateRDByLevelOnApply()
	{
        var inputStr    = trim(arguments[0]);
        var inputParentRowRDArray = inputStr.split(":");

		var curRDObj;
		var siblings;
		var inputRDArray;
		var strMsg;
		var curRDVal;

		var inputRDValues;
		var k;
		for(var j=0;j<inputParentRowRDArray.length;j++) {
			inputRDArray = getChildRows(inputParentRowRDArray[j]);
			inputRDValues = new Array();
			k=0;
			for(var i=0;i<inputRDArray.length;i++) {

				curRDObj = inputRDArray[i];
				if(curRDObj.getAttribute('rg')){
					continue;
				}
				curRDVal = getCurrentValue("Reference Designator",curRDObj);
				curQtyVal = getCurrentValue("AT_C_Quantity",curRDObj);
				//IR-028660V6R2011
				var status = inputRDArray[i].getAttribute("status");
				if(typeof curRDVal != 'undefined' && curRDVal!="" && status!= 'cut'){
					inputRDValues[k] = curRDVal;
					k++;
				}
				strMsg = validateRDValue(curRDObj,curRDVal);
				if(strMsg != "" && strMsg.length >0){
					return strMsg;
				}
				//strMsg = validateReferenceDesignatorOnApply(curRDVal,curQtyVal);
				if(rdQtyValidation && (rdQtyValidation.toLowerCase()=="true")) {
					strMsg = validateECQuantityonApply(curRDVal, curQtyVal);
					if(strMsg != "" && strMsg.length >0){
						return strMsg;
					}
				}

			}
			strMsg = checkForRDUniqueness(inputRDValues);
			if(strMsg != "true" && strMsg != "" && strMsg.length >0){
				return strMsg;
			}
		}
		return "";
	}

	/**
	This method validates reference designator value.
	*/

	function validateRDValue(curRDObj,curRDVal)
	{

    var inputRD    =  curRDVal;

    var objectType = getActualValueForOtherColumn("Type",curRDObj);
    //var objectType = getActualValueForColumn("Type");
    var rdRequired = rdPropertyArray[objectType];
   	var fnRequired = fnPropertyArray[objectType];

	//Added For GBOM 112
	//var fnValue    = getValueForColumn(attFindNumber);
	var fnValue = getValueForColumnOnApply(attFindNumber, curRDObj);
	
	if(fnRequired && rdRequired && fnRequired.toLowerCase()=="true" && rdRequired.toLowerCase()=="true")
    {

	    var msgvalFNRD = validateFNRDOnApply(fnValue,inputRD,fnRequired,rdRequired)
			        	if(msgvalFNRD != "") {
							return msgvalFNRD;
					}
	}else{
         if(rdRequired && rdRequired.toLowerCase()!="false") {
			if(inputRD == null || inputRD.length == 0) {
				return "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.RDfieldisemptypleaseenteranumber</emxUtil:i18nScript>";
			}
		}
	 }




	if(inputRD!="") {
		var frmtMsg = isRDFormatCorrectOnApply(inputRD);
		if(frmtMsg != "") {
	              return frmtMsg;
		}

	}

	if((rdLength!=0 && inputRD.length>rdLength)) {
	        return "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.Length </emxUtil:i18nScript>"+rdLength;
	}

	return "";
	}

	/**
	This method checks for the uniqueness of Reference designator value
	*/
	function checkForRDUniqueness(rdArray) {
	if(rdUniqueness && rdUniqueness.toLowerCase()=="true") {
		var inputRD = isRDValUnique(rdArray);
		//IR-028660V6R2011
		if(inputRD != null && typeof inputRD!="undefined") {
			return "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.RDNotUniqueForTNR</emxUtil:i18nScript>"+" "+inputRD;
		}
	}
	return "";
	}

	/**
	This method checks for the duplicate in the RD Array
	*/
	function isRDValUnique(rdValueArray) {
	var finalRDArray = [];
	var tempRDArray = [];
	for(var i=0;i< rdValueArray.length;i++)
	{
	tempRDArray = rdValueArray[i].split(SINGLE_SEPARATOR);
	finalRDArray = finalRDArray.concat(tempRDArray);
	}
	var strarr = flattenRD(finalRDArray);
        if(strarr.indexOf(SINGLE_SEPARATOR)==0) {
		strarr=strarr.substring(1);
	}

	var refarr = strarr.split(SINGLE_SEPARATOR);
	refarr.sort();
	for(var j=1;j<refarr.length;j++) {
		//IR-028660V6R2011
		if(typeof refarr[j-1]!="undefined" && typeof refarr[j]!="undefined"){
			if(trim(refarr[j-1])!= "" && trim(refarr[j])!="" && refarr[j-1]==refarr[j]) {
				return refarr[j];
			}
		}
	}
	return null;
	}

	/**
This method checks for RDFormat and returns the error message. this is same as isRDFormatCorrect method except returning message instead of alerting
*/
function isRDFormatCorrectOnApply(stralpha)
{

  var string= stralpha;
  var check = new Array();
  var delim=false;
  var merge=true;
  finalstr=string;

  if((string.lastIndexOf(RANGE_SEPARATOR)==(string.length-1)) || (string.indexOf(RANGE_SEPARATOR)==0))
  {
      return INVALID_FORMAT_MSG;

  }
  else if((string.indexOf(RANGE_SEPARATOR)==string.lastIndexOf(RANGE_SEPARATOR)) && string.indexOf(SINGLE_SEPARATOR)<=-1)
  {
      range=string.split(RANGE_SEPARATOR);

      if(range.length<=2)
      {
          string=range.join();
      }
  }

  check=string.split(SINGLE_SEPARATOR);

  for(var i=0;i < check.length;i++)
  {
      var str=check[i].toString();

      if ((str.lastIndexOf(RANGE_SEPARATOR)) > (str.indexOf(RANGE_SEPARATOR)))
      {
        return (SINGLE_RANGE_MSG);
      }
  }


  if((string.indexOf(SINGLE_SEPARATOR)> 0) && (string.lastIndexOf(SINGLE_SEPARATOR)!=(string.length-1)))
  {
      var hyphenval=new Array()
      for(var j=0;j < check.length;j++)
      {
          st=check[j].toString();
          if (st.indexOf(RANGE_SEPARATOR) > -1)
          {
              var temp=st.split(RANGE_SEPARATOR);
              hyphenval.push(temp[0])
              hyphenval.push(temp[1])
          }
          else
          {
              hyphenval.push(st);
          }
      }

      if(hyphenval.length > 1)
      {
          prevstr = hyphenval[0].match(/^[a-zA-Z]*/g);
          for(var k=0;k<hyphenval.length;k++)
          {
              newstr = hyphenval[k].match(/^[a-zA-Z]*/g);
              if(prevstr.toString()==newstr.toString())
              {
                   delim=true;
                   continue ;
              }
              else
              {
                   delim=false;
                   return (MULTI_PREFIX_MSG);
              }
          } // for
      } //if
  } // if string.indexOf

  if (delim)
  {
      for(i=0;i<hyphenval.length;i++)
      {
         var str=hyphenval[i];
         bol=isRDAlphaNumeric(str);
         if (!bol)
         {
                break;
         }
         else
         {
                qty=1;
         }
       } //for
   }
   else
   {
       qty=0;
       bol=isRDAlphaNumeric(string);
   }

   if(!bol)
   {
           return (INVALID_CHAR_MSG);
   }

   return "";
}

/**
This is same ad validateFNRD except that this mehtod returns the message instead of alerting
*/
function validateFNRDOnApply(fnObjValue,rdObjValue,fnRequired,rdRequired)
{

    var findNumberValue = (fnObjValue== null ||fnObjValue.length == 0)?fnObjValue:trim(fnObjValue);
    var rdvalue         = rdObjValue;
    if(ebomUniquenessOperator.toLowerCase()=="and")
    {

              if(findNumberValue == null || findNumberValue.length==0)
              {
                  return ("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
              }
              if(rdvalue == null || rdvalue.length==0)
              {
                 return ("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.RDfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
              }

    }
    if(ebomUniquenessOperator.toLowerCase()=="or")
    {

        if((findNumberValue == null || findNumberValue.length == 0)&& (rdvalue == null || rdvalue.length == 0))
        {
             return ("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNAndRDfieldemptypleaseenterAnyOne</emxUtil:i18nScript>");
        }

     }

   return "";
}

	/* Start Bug 358154 */
	function validateDispCodesFieldReturn(val, id) {

		var objColumnRC = colMap.getColumnByName("Requested Change");
	    if(objColumnRC==undefined){
	    	objColumnRC = colMap.getColumnByName("Requested Change2");
	    	if(objColumnRC==undefined){
	    		objColumnRC = colMap.getColumnByName("Requested Change3");
	    	}
	    }
		//var id = currentCell.target.parentNode.getAttribute("id");
		var requestCH = emxUICore.selectSingleNode(oXML.documentElement,"//r[@id='"+id+"']/c["+ objColumnRC.index +"]");
		var RCValue = emxUICore.getText(requestCH);
		
		RCValue = RCValue.replace(/\s/g,"_");
		FOR_REVISE = FOR_REVISE.replace(/\s/g,"_");
		FOR_OBSOLESCENCE = FOR_OBSOLESCENCE.replace(/\s/g,"_");
		
	  	if(!((RCValue == FOR_REVISE)||(RCValue == FOR_OBSOLESCENCE))){
			return DISPFIELDRETURN_ALERT_MSG+"\n";
	   	} else {
	   		return "";
	   	}
	}

	function validateDispCodesInField(val, id) {

		var objColumnRC = colMap.getColumnByName("Requested Change");
	    if(objColumnRC==undefined){
	    	objColumnRC = colMap.getColumnByName("Requested Change2");
	    	if(objColumnRC==undefined){
	    		objColumnRC = colMap.getColumnByName("Requested Change3");
	    	}
	    }
		//var id = currentCell.target.parentNode.getAttribute("id");
		var requestCH = emxUICore.selectSingleNode(oXML.documentElement,"//r[@id='"+id+"']/c["+ objColumnRC.index +"]");
		var RCValue = emxUICore.getText(requestCH);
		
		RCValue = RCValue.replace(/\s/g,"_");
        FOR_REVISE = FOR_REVISE.replace(/\s/g,"_");
        FOR_OBSOLESCENCE = FOR_OBSOLESCENCE.replace(/\s/g,"_");
		
	  	if(!((RCValue == FOR_REVISE)||(RCValue == FOR_OBSOLESCENCE))){
			return DISPINFIELD_ALERT_MSG+"\n";
	   	} else {
	   		return "";
	   	}
	}

	function validateDispCodesInProcess(val, id) {

		var objColumnRC = colMap.getColumnByName("Requested Change");
	    if(objColumnRC==undefined){
	    	objColumnRC = colMap.getColumnByName("Requested Change2");
	    	if(objColumnRC==undefined){
	    		objColumnRC = colMap.getColumnByName("Requested Change3");
	    	}
	    }
		//var id = currentCell.target.parentNode.getAttribute("id");
		var requestCH = emxUICore.selectSingleNode(oXML.documentElement,"//r[@id='"+id+"']/c["+ objColumnRC.index +"]");
		var RCValue = emxUICore.getText(requestCH);
		
		RCValue = RCValue.replace(/\s/g,"_");
        FOR_REVISE = FOR_REVISE.replace(/\s/g,"_");
        FOR_OBSOLESCENCE = FOR_OBSOLESCENCE.replace(/\s/g,"_");
        
		if(!((RCValue == FOR_REVISE)||(RCValue == FOR_OBSOLESCENCE))){
			return DISPINPROCESS_ALERT_MSG+"\n";
	   	} else {
	   		return "";
	   	}
	}

	function validateDispCodesInStock(val, id) {

		var objColumnRC = colMap.getColumnByName("Requested Change");
	    if(objColumnRC==undefined){
	    	objColumnRC = colMap.getColumnByName("Requested Change2");
	    	if(objColumnRC==undefined){
	    		objColumnRC = colMap.getColumnByName("Requested Change3");
	    	}
	    }
		//var id = currentCell.target.parentNode.getAttribute("id");
		var requestCH = emxUICore.selectSingleNode(oXML.documentElement,"//r[@id='"+id+"']/c["+ objColumnRC.index +"]");
		var RCValue = emxUICore.getText(requestCH);
		
		RCValue = RCValue.replace(/\s/g,"_");
        FOR_REVISE = FOR_REVISE.replace(/\s/g,"_");
        FOR_OBSOLESCENCE = FOR_OBSOLESCENCE.replace(/\s/g,"_");
        
	  	if(!((RCValue == FOR_REVISE)||(RCValue == FOR_OBSOLESCENCE))){
			return DISPINSTOCK_ALERT_MSG+"\n";
	   	} else {
	   		return "";
	   	}
	}

	function validateDispCodesOnOrder(val, id) {

		var objColumnRC = colMap.getColumnByName("Requested Change");
	    if(objColumnRC==undefined){
	    	objColumnRC = colMap.getColumnByName("Requested Change2");
	    	if(objColumnRC==undefined){
	    		objColumnRC = colMap.getColumnByName("Requested Change3");
	    	}
	    }
		//var id = currentCell.target.parentNode.getAttribute("id");
		var requestCH = emxUICore.selectSingleNode(oXML.documentElement,"//r[@id='"+id+"']/c["+ objColumnRC.index +"]");
		var RCValue = emxUICore.getText(requestCH);
		
		RCValue = RCValue.replace(/\s/g,"_");
        FOR_REVISE = FOR_REVISE.replace(/\s/g,"_");
        FOR_OBSOLESCENCE = FOR_OBSOLESCENCE.replace(/\s/g,"_");
        
	  	if(!((RCValue == FOR_REVISE)||(RCValue == FOR_OBSOLESCENCE))){
			return DISPONORDER_ALERT_MSG+"\n";
	   	} else {
	   		return "";
	   	}
	}

	/* End Bug 358154 */



       /* Added for IR-037786 */

	function validateSpecialCharOnName (sName,sFlag) {
	
		var ARR_FOR_BAD_CHARS = "";
  		if (sBadCharInName != "") 
  		{    
  			ARR_FOR_BAD_CHARS = sBadCharInName.split(" ");   
  		}
		var namebadCharName = checkStringForChars(sName,ARR_FOR_BAD_CHARS);
	 
	   	if (namebadCharName.length != 0){
       			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
				return false;
		} else {
				return true;
		}
				
	}
	/* Added for IR-037786 */
	
	function checkStringForChars(strText, arrBadChars) {
        //IR-040860 - Starts	
	    strText = strText.trim();
	    //IR-040860 - Ends
	    var strBadChars = "";
	    for (var i=0; i < arrBadChars.length; i++) {
	    	//IR-040860 - Starts
			//if (strText.indexOf(arrBadChars[i]) > -1) {
			if (strText.indexOf(arrBadChars[i]) > -1 && arrBadChars[i] != " ") {
			//IR-040860 - Ends
					strBadChars += arrBadChars[i] + " ";
			}
		}
		        
		if (eval(strBadChars.length) > 0) {
			return strBadChars;
		} else {
			return "";
		}
	}
	
	/* End of Bug IR-037786 */

//IR-033986-Starts
function validateWeight(){
	var Weightvalue = arguments[0];
	var SplitVal = Weightvalue.split(" ");
	Weightvalue = SplitVal[0];
	if(isEmpty(Weightvalue) || Weightvalue == " "){
		alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.WeightIsEmpty</emxUtil:i18nScript>");
		return false;
	}
	if(!isNumericGeneric(Weightvalue)){
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.WeightHasToBeANumber</emxUtil:i18nScript>");
			return false;
      	}
      	if((Weightvalue).substr(0,1) == '-'){
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.WeightHasToBeAPositiveNumber</emxUtil:i18nScript>");
			return false;
		}
return true;
}
//IR-033986-Ends
//Chetan
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

function enableDisableLevelField() {
    var selectedLevel = getTopWindow().document.getElementById("ENCPartWhereUsedLevel").value;
    var levelTextBox  = getTopWindow().document.getElementById("ENCPartWhereUsedLevelTextBox");

    if (selectedLevel == "Highest" || selectedLevel == "All") {
        levelTextBox.value = "";
        levelTextBox.disabled = true;
    } else {
        levelTextBox.disabled = false;
        if (levelTextBox.value == "") {
            levelTextBox.value = "1";
        }        
    }
}

function clearEffectivityField() {
    document.getElementById("CFFExpressionFilterInput").value = "";
    document.getElementById("CFFExpressionFilterInput_actualValue").value = "";
    document.getElementById("CFFExpressionFilterInput_OID").value = "";
}

    // Attach onload event to the window, If context partWhereUsed
    var isPartWhereUsed = this.location.href.indexOf("&partWhereUsed=true&") > -1 //2011x    

    if (isPartWhereUsed) {
        attachEventHandler(window, "load", refreshFilters);
    }

    function refreshFilters(){
        //Once Toolbar is loaded, load them with initial values
        setTimeout(initialProcessing, 400);        
    }

    /*
    * This function loads product filter with initial value
    */
    function initialProcessing() {
        if(uiType == "structureBrowser" && typeof objectId != "undefined" && objectId.length != 0) {            
            if (isPartWhereUsed) {
                enableDisableLevelField();
            }
        }
    }

function validateInt(iString) {
     // no leading 0s allowed
     return (("" + parseInt(iString)) == iString);
  }
  
function submitFilterButton() {


var bolModePortal = false;
var modePortal = "false";
var prmStr = window.location.search.substr(1);
var prmStr1 = prmStr.split ("&");

for ( var i = 0; i < prmStr1.length; i++) {
    var temp = prmStr1[i].split("=");
    if(temp[0] == "portalMode"){
    	bolModePortal = true;
    	modePortal = temp[1];
    	break;    	
	}
}

	<%String maxShort    = Short.toString(Short.MAX_VALUE);%>
    var selectedLevel = getTopWindow().document.getElementById("ENCPartWhereUsedLevel").value;  

    if (selectedLevel == "UpTo..." || selectedLevel == "UpTo..And Highest") {
        var levelValue = getTopWindow().document.getElementById("ENCPartWhereUsedLevelTextBox").value;
        if (!isNumeric(levelValue) || !validateInt(levelValue) || (levelValue.substr(0, 1) == "-")) {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.WhereUsedLevelShouldBeNumeric</emxUtil:i18nScript>");
            return;
        }
        //XSSOK
        if(levelValue >= <%=maxShort%>) {
        	//XSSOK
        	alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOM.InvalidLevelRange</emxUtil:i18nScript>" + <%=maxShort%>);
            return;
        }
    }

  var sURL = "../common/emxIndentedTable.jsp?header=emxEngineeringCentral.Common.WhereUsed&suiteKey=EngineeringCentral&partWhereUsed=true&table=PartWhereUsedTable&program=emxPart:getPartWhereUsed&toolbar=ENCpartReviewWhereUsedSummaryToolBar,ENCPartWhereUsedFiltersToolbar1,ENCPartWhereUsedFiltersToolbar2&HelpMarker=emxhelppartwhereused&selection=multiple&expandLevelFilter=false&showApply=false&onReset=resetWhereUsedMassChange&showMassUpdate=false&expandByDefault=true";
if(bolModePortal==true){
sURL = sURL + "&portalMode="+modePortal;
}
    var fieldArr = ["objectId", "ENCPartWhereUsedLevel", "ENCPartWhereUsedLevelTextBox", "ENCPartWhereUsedRevisions", "ENCPartWhereUsedRelated", "ENCPartWhereUsedRefDesTextBox", "ENCPartWhereUsedFNTextBox", "ENCPartWhereUsedEBOMSubCheckBox", "CFFExpressionFilterInput", "CFFExpressionFilterInput_actualValue", "CFFExpressionFilterInput_OID", "sortColumnName","PUEUEBOMProductConfigurationFilter", "PUEUEBOMProductConfigurationFilter_actualValue", "PUEUEBOMProductConfigurationFilter_OID"];

    for (var i = 0; i < fieldArr.length; i++) {
        fieldObject = document.getElementById(fieldArr[i]);
        if(fieldObject == "null" || fieldObject == null || fieldObject == "undefined")
        {
        fieldObject = getTopWindow().document.getElementById(fieldArr[i]);
        }
        if (fieldObject != null && fieldObject != "undefined") {

            if (fieldArr[i] == "ENCPartWhereUsedEBOMSubCheckBox") {
                sURL += "&" + fieldArr[i] + "=" + fieldObject.checked;
                sURL += "&displayEBOMSub=" + fieldObject.checked;
            } else {
                sURL += "&" + fieldArr[i] + "=" + fieldObject.value;
            }

            if (fieldArr[i] == "ENCPartWhereUsedRelated" && (fieldObject.value != "None")) {
                sURL += "&expandProgram=emxPart:getWhereUsedRelatedDatas";
            }
        }
    }
    if(sURL.indexOf("expandProgram=emxPart:getWhereUsedRelatedDatas")== -1){
    sURL += "&expandProgram=emxPart:getPartWhereUsed&editLink=true";
    }

    this.document.location.href = sURL;
}

function validateSparePartQuantity(str1,str2) {
    var qtyvalue = arguments[0];
    var NumberofDigitsAfterDecimal = 0; 

    if(qtyvalue != null)
    {
      if( isEmpty(qtyvalue)) {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.Quantityfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
        return false;
      }
      if (qtyvalue.indexOf(",") != -1 ) {
        qtyvalue = qtyvalue.replace(",", ".");
      }
      if(!isNumeric(qtyvalue))
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeANumber</emxUtil:i18nScript>");
        return false;
      }
      var qtyvalue1 = parseFloat(qtyvalue);
      if(qtyvalue == '0' || qtyvalue == '0.0' || qtyvalue == '+0' || qtyvalue1 == '0.0')
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeGreaterThanZero</emxUtil:i18nScript>");
        return false;
      }
      if((qtyvalue).substr(0,1) == '-')
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeAPositiveNumber</emxUtil:i18nScript>");
        return false;
      }   
    }
    return true;
}

function showSearch()
{
        var sbReference = findFrame(getTopWindow(), "ENCSpareParts");
    if (sbReference == null) {
        sbReference = findFrame(getTopWindow(), "portalDisplay") == null ? findFrame(getTopWindow(), "content") : findFrame(getTopWindow(), "portalDisplay").frames[2];
    }
        var dupemxUICore = sbReference.emxUICore;    
        var oXML         = sbReference.oXML;
        var objId=sbReference.objectId;
        var checkedRows = dupemxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
        var  ischild=true;
        for (var i = 0; i < checkedRows.length; i++) {
         var objectId = checkedRows[i].getAttribute("o");
         if(objectId==objId)
         {
         ischild=false;
         break;
         }
         }
         var length=checkedRows.length;
        
         if((checkedRows.length>1)||(length==1 && ischild) )
         {
         //XSSOK
         alert("<%=strSelectRootNode %>");
         }
       else
         {          
             var contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_Part:SPARE_PART=Yes&showInitialResults=true&table=ENCPartSparePart&selection=multiple&hideHeader=true&suiteKey=EngineeringCentral&submitLabel=emxFramework.Command.Done&submitAction=refreshCaller&cancelLabel=emxFramework.Command.Cancel&submitURL=../engineeringcentral/emxpartConnectSparePartProcess.jsp&excludeOIDprogram=emxENCFullSearch:excludeConnectedSpareOIDs&HelpMarker=emxhelpfullsearch&toolbar=ENCSparePartsFilterToolBar&objectId="+objId;
             contentURL=contentURL+"&ENCSparePartOptionCheckBox=false";
             showModalDialog(contentURL, 850, 630);
         }
            
}
function validateProductionMakeBuy()
{
     var objectPolicy = getActualValueForColumn("Policy");
     //XSSOK
  	if("<%=strMfgPolicy%>".indexOf(objectPolicy)!=-1){
  		//XSSOK
		<%--Multitenant--%>
		<%--var error_msg = "<%=i18nNow.getI18nString("emxEngineeringCentral.Part.Edit.ProductionMakeBuyCode","emxEngineeringCentralStringResource",accLanguage)%>";--%>
		var error_msg = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.Edit.ProductionMakeBuyCode")%>";
		alert(error_msg);
		return false;
      }
 return true;
}
function validateEndItem()
{
    var objectPolicy = getActualValueForColumn("Policy");
    //XSSOK
   	if("<%=strMfgPolicy%>".indexOf(objectPolicy)!=-1){
   		//XSSOK
		<%--Multitenant--%>
		<%--var error_msg = "<%=i18nNow.getI18nString("emxEngineeringCentral.Part.Edit.EndItem","emxEngineeringCentralStringResource",accLanguage)%>";--%>
		var error_msg = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.Edit.EndItem")%>";
		alert(error_msg);
		return false;
      }
 return true;
}
function validateDesignResp()
{
    var objectPolicy = getActualValueForColumn("Policy");
    //XSSOK
  	if("<%=strMfgPolicy%>".indexOf(objectPolicy)!=-1){
  		//XSSOK
		<%--Multitenant--%>
		<%--var error_msg = "<%=i18nNow.getI18nString("emxEngineeringCentral.Part.Edit.DesignResp","emxEngineeringCentralStringResource",accLanguage)%>";--%>
		var error_msg = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.Edit.DesignResp")%>";
		alert(error_msg);
		return false;
      }
 return true;
}

function validateEffectivityDate() {
    
    var effectivityDate = (arguments[0].indexOf(" ") > 0 || arguments[0].indexOf(",") > 0)? parseInt(hiddenVal) : parseInt(arguments[0]);
    
    var currentDate = new Date();
    var eDate = new Date(effectivityDate);
    
    if((parseInt(eDate.getTime()))<=(parseInt(currentDate.getTime()))) {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.TargetRelDateHasToBeGreaterThanPresentDate</emxUtil:i18nScript>");
        return false;
    }
    return true;
}

var channelAffectedItem3dLiveFrame 	= null;
var sbAffectedItemFrame = null;

//Function to select affected Items in ECO/ECR/DCO
function highlight3DAffectedItem(strID, flag) {
	var aId = strID.split("|");
    var id = aId[3];
    
    if(channelAffectedItem3dLiveFrame == null)
		channelAffectedItem3dLiveFrame 	= findFrame(getTopWindow(),"ENCLaunchAffectedItem3DLiveChannel");
	
	if(sbAffectedItemFrame == null) {
		sbAffectedItemFrame = findFrame(getTopWindow(), "ENCECOAffectedItemsTreeCategory");
		if(sbAffectedItemFrame == null) {
			sbAffectedItemFrame = findFrame(getTopWindow(), "ENCECRAffectedItemsTreeCategory");
		}
	}
	
	if(typeof channelAffectedItem3dLiveFrame != 'undefined' && channelAffectedItem3dLiveFrame != null) {    
		var rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + id + "']");
		var selPartId = rowNode.getAttribute("o");
		var objId=sbAffectedItemFrame.objectId;
			
		var idPath = emxUICore.getData("../engineeringcentral/emxEngrGetAffectedItemPath.jsp?contextECOId="+objId+"&selPartId="+selPartId);
		idPath = idPath.substring(0, idPath.indexOf("@"));
		if("NOTEXIST" == idPath && flag == true) {
			//do nothing
			//alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.3DLiveExamine.3DRepDoesntExist</emxUtil:i18nScript>");
		} else {
			toggleSelect(channelAffectedItem3dLiveFrame, flag, idPath);
		}
	}
}

//Function to select SB  row from 3DLive Examine window in affected items page
function highlightSBAffectedItem(strPath, flag) {
	var tempArr = strPath.split("/");
	if(tempArr.length == 1) {
		nSelRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o = '" + tempArr[0] + "']");
	} else {
		var strRel 	= tempArr[tempArr.length-1];
		
		var tempIdArr = strRel.split(".");
		if(tempIdArr.length == 5) {
			strRel = strRel.substring(0, strRel.lastIndexOf("."));
		}
		
		var idPath = emxUICore.getData("../engineeringcentral/emxEngrGetAffectedItemPath.jsp?strRel="+strRel+"&fromAffectedItems=true");
		idPath = idPath.substring(0, idPath.indexOf("@"));
		nSelRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@o = '" + idPath + "']");
	}
	
	if(typeof nSelRow != 'undefined' && nSelRow != null) {
		if(sbAffectedItemFrame == null) {
			sbAffectedItemFrame = findFrame(getTopWindow(), "ENCECOAffectedItemsTreeCategory");
			if(sbAffectedItemFrame == null) {
				sbAffectedItemFrame = findFrame(getTopWindow(), "ENCECRAffectedItemsTreeCategory");
			}
		}
		if(flag) {
			sbAffectedItemFrame.emxEditableTable.select([nSelRow.getAttribute("id")]);
		} else {
			sbAffectedItemFrame.emxEditableTable.unselect([nSelRow.getAttribute("id")]);
		}
	}
}

//Function to select/deselect the highlights in ENG BOM Powerview
//OOTB channel is used for 3D Live Examine
function crossHighlightENG(rowIds, flag) {
	var chkAllFlag = false;
	var objForm = document.forms["emxTableForm"];
	if(objForm.chkList) {
		chkAllFlag = objForm.chkList.checked;
	}
	
	var strIDs = rowIds.split(":");
	if(chkAllFlag) {
		var tempVal = strIDs[0];
		strIDs = new Array();
		strIDs[0] = tempVal;
	}

	var aId = "";
	var rowId = "";
	var rowNode = null;
	var idPath = "";
	
	if(channel3dLiveFrame == null)
		channel3dLiveFrame 	= findFrame(getTopWindow(),"APPLaunch3DLiveChannel");
	
	if(typeof channel3dLiveFrame != 'undefined' && channel3dLiveFrame != null) {
 		channel3dLiveFrame.beginSelection("viewer");
		for (var j = 0; j < strIDs.length; j++) {
			aId = strIDs[j].split("|");
		    rowId = aId[3];
			rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + rowId + "']");
			idPath = getIDPathFromXMLNode(rowNode);
			
			try {
				if(getCurrentValue("Quantity",rowNode) != null) {
					var quan = getCurrentValue("Quantity",rowNode);
					for(count = 1; count < parseInt(quan); count++) {
						toggleSelect(channel3dLiveFrame, flag, idPath+"."+count);
					}
				}
			} catch(e){}
			
			toggleSelect(channel3dLiveFrame, flag, idPath);
		}
		channel3dLiveFrame.commitSelection("viewer");
	}
}


var leftQtyIndex = null;
var rightQtyIndex = null;
if(colMap.getColumnByName("Quantity")) {
	leftQtyIndex = (colMap.getColumnByName("Quantity").index - (colMap.columns.length/2));
	rightQtyIndex = colMap.getColumnByName("Quantity").index;
}


//Function to highlight remaining nodes if qty > 1
function getAllNodes(rowNode, idPath, index) {
	var allNodes = new Array();
	try {
	    if(getCurrentValue("Quantity", rowNode) != null) {
			var quan = emxUICore.selectSingleNode(rowNode, "c[" + index + "]").attributes["a"].value;
			for(count = 1; count < parseInt(quan); count++) {
				//toggleSelect(channel3dLiveFrame, mode, idPath+"."+count);
				allNodes[count-1] = idPath+"."+count;
			}
		}
	} catch(e) {
		allNodes = new Array();
	}
	return allNodes;
}

channel3dLiveFrame1 = null;
channel3dLiveFrame = null;

function resetWhereUsedMassChange() {
	var cutOrChangedRows =emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@status='cut' or @status='changed']");
	for(var i=0;i<cutOrChangedRows.length;i++){
		cutOrChangedRows[i].parentNode.removeChild(cutOrChangedRows[i]);
	}
}
//Function to highlight Compare results
function highlightCompareItem(rowIds, mode) {
	if(finalResultsFrame == "") {
		finalResultsFrame = getCompareResultsFrameName();
	}
	
	var strIDs = rowIds.split(":");
	var aId = "";
	var id = "";
	var rowNode = null;
	var idPath = "";
	var i = 0;
	var selectedRowIdsFrame1 = new Array();
	var selectedRowIdsFrame2 = new Array();
	
	for (var j = 0; j < strIDs.length; j++) {
		aId = strIDs[j].split("|");
	    id = aId[3];
		rowNode = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + id + "']");
		
		if(channel3dLiveFrame1 == null || channel3dLiveFrame1.location == null) {
			channel3dLiveFrame 	= findFrame(getTopWindow(),"APPLaunch3DLiveChannel");
			channel3dLiveFrame1	= findFrame(getTopWindow(),"APPLaunch3DLiveChannelCompare");
		}
		
		idPath 			= getIDPathFromXMLNode(rowNode);
		var quan = 0;
	    var matchresult = rowNode.getAttribute("matchresult");
	    
	   	if(typeof matchresult != 'undefined' && matchresult != null) {
	   		
	   		if("AEFSCBOM2UniqueComponentsReport" == finalResultsFrame) {
	   			matchresult = "right";
	   		}
	
	   		if("AEFSCBOM1UniqueComponentsReport" == finalResultsFrame) {
	   			leftQtyIndex = rightQtyIndex;
	   		}
	   		
	   		if(matchresult == "left") {
		        selectedRowIdsFrame1.push(idPath);
		        selectedRowIdsFrame1 = selectedRowIdsFrame1.concat(getAllNodes(rowNode, idPath, leftQtyIndex));
	   		} else if(matchresult == "right") {
		        selectedRowIdsFrame2.push(idPath);
		        selectedRowIdsFrame2 = selectedRowIdsFrame2.concat(getAllNodes(rowNode, idPath, rightQtyIndex));
	   		} else if(matchresult == "common") {
				selectedRowIdsFrame1.push(idPath);
		        selectedRowIdsFrame1 = selectedRowIdsFrame1.concat(getAllNodes(rowNode, idPath, leftQtyIndex));	        
		        
		        idPath = getIDPathFromXMLNodeRight(rowNode, "true");
		        
		        selectedRowIdsFrame2.push(idPath);
		        selectedRowIdsFrame2 = selectedRowIdsFrame2.concat(getAllNodes(rowNode, idPath, rightQtyIndex));
	   		}
	   	} else {
	   		toggleSelect(channel3dLiveFrame, mode, idPath);
	   	}
   	}
   	
	//Multi select
	channel3dLiveFrame.beginSelection("viewer");
	for(var counter=0; counter < selectedRowIdsFrame1.length; counter++) {
		toggleSelect(channel3dLiveFrame, mode, selectedRowIdsFrame1[counter]);
	}
	channel3dLiveFrame.commitSelection("viewer");
   	
	channel3dLiveFrame1.beginSelection("viewer");
	for(var counter=0; counter < selectedRowIdsFrame2.length; counter++) {
		toggleSelect(channel3dLiveFrame1, mode, selectedRowIdsFrame2[counter]);
	}
	channel3dLiveFrame1.commitSelection("viewer");
}
function validateQuantityForSubstitute(str1,str2)
  {
     //validate that all required fields are entered
     var qtyvalue = arguments[0];

     if(isEmpty(qtyvalue))
     {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.Quantityfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
       return;
     }
     
     if (qtyvalue.indexOf(",") != -1 ) {
        qtyvalue = qtyvalue.replace(",", ".");
      }
      
       var qtyvalue1 = parseFloat(qtyvalue);
     if(qtyvalue == '0' || qtyvalue == '0.0' || qtyvalue == '+0' || qtyvalue1 == '0.0')
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeGreaterThanZero</emxUtil:i18nScript>");
        return false;
      }
      
     if(!isNumeric(qtyvalue))
     {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeANumber</emxUtil:i18nScript>");
       return;
     }
     if((qtyvalue).substr(0,1) == '-')
     {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeAPositiveNumber</emxUtil:i18nScript>");
       return;
     }
     if(qtyvalue== 0)
     {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeGreaterThanZero</emxUtil:i18nScript>");
       return;
     }
     return true;
  }
  
  /* Added for Alternate / Substitute for ENG by D2E -- Start */
  
  function confirmSwitchMEP(msg, url){
  	var done = confirm(msg);
  	
  	if(done){
  		showChooser(url, '700', '600', 'false', 'popup', '');
  	}
  }
  
  /* Added for Alternate / Substitute for ENG by D2E -- End */
  
  //Chart widgets
function openChartView(functionality,objIds,relIds) {

 	 var chartForm = document.createElement('form')
	 document.body.appendChild(chartForm);
	 chartForm.appendChild(getHiddenField("objIds",objIds));
	 chartForm.appendChild(getHiddenField("relIds",relIds));
	 chartForm.appendChild(getHiddenField("functionality",functionality));
	 chartForm.appendChild(getHiddenField("rootObjectId",objectId));
	 	 
	 chartForm.method = "post";
	 chartForm.target = "listHidden";
	 chartForm.action =  "../engineeringcentral/EngineeringWidgetUtil.jsp";     
	 chartForm.submit(); 	    	   
}

function openBOMChartView() {

     var groupRows = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[@rg]");
     if(groupRows != null && groupRows != "undefined" && groupRows.length > 0) { 
     alert("<%= BOMChartViewNotsupported%>");
     	return;
     }
     var visibleRows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[ (@filter = 'false') and ( parent::r[@display != 'none'])]");
	 var relIds="";
	 var objIds="";

 	 if (visibleRows != null){
		for(var i=0; i<visibleRows.length; i++){
			if("0"===visibleRows[i].getAttribute("id"))continue;			
			objIds = objIds.length > 0 ? objIds+"|"+visibleRows[i].getAttribute("o") : visibleRows[i].getAttribute("o");        
			relIds = relIds.length > 0 ? relIds+"|"+visibleRows[i].getAttribute("r") : visibleRows[i].getAttribute("r");
		}
	 }	 	 
	openChartView("bomCharts",objIds,relIds);
}

function openMyEngineeringChartView() {

     var visibleRows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[(@filter = 'false')]");
	 var relIds="";
	 var objIds="";

 	 if (visibleRows != null){
		for(var i=0; i<visibleRows.length; i++){		
			objIds = objIds.length > 0 ? objIds+"|"+visibleRows[i].getAttribute("o") : visibleRows[i].getAttribute("o");        
		}
	 }	 	 
	openChartView("partCharts",objIds,"");
}

function getHiddenField(name,val) {		
	var ele = document.createElement('input');
	ele.setAttribute("type","hidden");
	ele.setAttribute("name",name);
	ele.setAttribute("id",name);
	ele.setAttribute("value",val);
	return ele;
}
function getLookupJPO() {		
     setRequestSetting("lookupJPO","emxPart:lookupEntries");        
     emxEditableTable.addExistingChildRow();
}
function getLookupJPOAddExistingRowBelow() {		
     setRequestSetting("lookupJPO","emxPart:lookupEntries");        
     emxEditableTable.addExistingChildRowBelow();
}
function getLookupJPOAddExistingRowAbove() {		
     setRequestSetting("lookupJPO","emxPart:lookupEntries");        
     emxEditableTable.addExistingChildRowAbove();
}

//************Float on EBOM CHANGES******************

var isBOMPowerview,isPartWhereUsed,isConfiguredBOM;

function replaceWithLatestRevision() {
	replaceWith("replaceWithLatestRevision");
}

function replaceWithLatestReleased() {
	replaceWith("replaceWithLatestReleased");
}

function replaceWithSpecificRevision() {
	replaceWith("replaceWithSpecificRevision");
}

function replaceWithSpecificRevisionForAll() {
	replaceWith("replaceWithSpecificRevisionForAll");
}

function replaceWith(functionality) {
	
	isBOMPowerview  = ("ENG" == jQuery("#BOMMode").val()) ? true : false;
	isPartWhereUsed = ("true" == jQuery("#partWhereUsed").val()) ? true : false;
	isConfiguredBOM = ("true" == jQuery("#fromConfigBOM").val()) ? true : false;
	
	var selectedRows = emxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
	
	var confirmation = "";  	 	
  	if(isBOMPowerview) {
  		confirmation = (selectedRows.length > 0 ) ? "<%=replaceSelectedConfirmation%>" : "<%=replaceAllConfirmation%>";
  	}  	
  	if(isPartWhereUsed) {  	
  	  	confirmation = (selectedRows.length > 0 ) ? "<%=replaceSelectedWhereUsedConfirmation%>" : "<%=replaceAllWhereUsedConfirmation%>";
  	}	  	 		  	
		
	if(validateForAddOrCutStatusRows(functionality)) { // To check whether rows were involved in add or cut operation 
		return;
	}
		
	if(functionality == "replaceWithSpecificRevision" && selectedRows.length > 1) {  		
  			alert("<%=selectOneItemOnly%>");  		
  			return;  			
  	}
	if(!isPartWhereUsed && validateReplaceCommands()) {  // validate selections In case of bom powerview only
		return;
	}
			  	
    if(functionality != "replaceWithSpecificRevision" || functionality != "replaceWithSpecificRevisionForAll") {
    	toggleProgress("visible");    	
    }	  	  		  	  	
	
	if((functionality == "replaceWithLatestRevision" || functionality == "replaceWithLatestReleased") && !confirm(confirmation)) {
		return;	
	}
	 //START REDMINE #7460
	if(functionality == "replaceWithLatestRevision" && checkParentReleased() ) {
		return;	
	}
	if(functionality == "replaceWithLatestReleased" && checkParentReleased() ) {
		return;	
	}
	//END REDMINE #7460
		
	appendToTableForm("functionality",functionality);   	 
	submitToFloatOnEBOM();  			 
  }
  //START REDMINE #7460
  function checkParentReleased() {
	  
	  var parentReleased=false;
	 // var rootNode  = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@id='0']");	
	 //rootNode != null && rootNode != undefined &&
	  var currentState  = getValueForCell("0","State","display");	
  	if (  currentState == "Released" ) {
  		var partName = getValueForCell("0","Name","display");
	  	var partRev  = getValueForCell("0","Revision","display");	
		parentReleased=true;
		alert("Modification failed, Parent Part "+partName+ " "+ partRev+" is in "+ currentState +" state.");  
	}
	  return parentReleased;
  }
  //END REDMINE #7460
  
  function validateForAddOrCutStatusRows(functionality) {
    var validationFailed = true;

	var Xpath = "/mxRoot/rows//r[@checked = 'checked' and (@status = 'add' or @status = 'cut')]";
	var statusRows   = emxUICore.selectNodes(oXML.documentElement, Xpath);
	
	if (statusRows && statusRows.length > 0) {  		
		alert("<%=ReplaceRevisionOnAddedDeleted%>");
		return validationFailed;
	}
	else 
	{
	
	//If no rows were selected, we have to validate all levels for revision management and 1 level for replace commands
	var Xpath = (functionality == "replaceWithSpecificRevisionForAll") ? 
								  "/mxRoot/rows//r[@status = 'add' or @status = 'cut']" : 
								  "/mxRoot/rows//r[@level  = '1' and (@status = 'add' or @status = 'cut')]";
		
	statusRows   = emxUICore.selectNodes(oXML.documentElement, Xpath);
	if (statusRows && statusRows.length > 0) {  		
			alert("<%=ReplaceRevisionOnAddedDeleted%>");
			return validationFailed;
		}
    }	
	return false;
}
  
function validateReplaceCommands() {

	var validationFailed = true;
	
	//Root node cannot be selected validation
	var rootNode  = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@id='0']");	
  	if (rootNode != null && rootNode != undefined && rootNode.getAttribute("checked") === "checked") {
  		alert("<%=rootNodeErrorForReplace%>");  		
  		return validationFailed;
  	}
  	
  	//Need to provide validation if the selected part already contains latest revision
  	var selectedRows = emxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
	if (selectedRows && selectedRows.length > 0) {
  		for(var i=0; i<selectedRows.length; i++){  		
  			var revStatus = getValueForCell(selectedRows[i].getAttribute("id"),"RevisionStatus","actual");
  			var policy    = getValueForCell(selectedRows[i].getAttribute("id"),"Policy","actual");
  			var partName  = getValueForCell(selectedRows[i].getAttribute("id"),"Name","display");
		    var partRev   = getValueForCell(selectedRows[i].getAttribute("id"),"Revision","display");
  			
  			  			  	
		  	//Validation for already latest part revision		  			  
		  	if(revStatus != "null" &&  revStatus != undefined && revStatus.indexOf("img") < 0) {
				alert(partName + " " + partRev + " "+ "<%=partAlreadyLatestRevisionError%>");
			    return validationFailed;
		  	}
		  	//validation for configured part
		  	if(policy == "Configured Part") {
		  		alert("<%=configuredPartsNotAllowed%>" + " "+partName+" "+partRev);
		  		return validationFailed;
		  	}		  	
  		}  		
  	} 
  	
  	//Need to validate if only one root node exists in the bom  	 
  	if(selectedRows.length == 0) {  		
  		var totalSbRows = emxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r");
  		if (totalSbRows && totalSbRows.length == 1) {
			var partName = getValueForCell("0","Name","display");
	  		var partRev  = getValueForCell("0","Revision","display");
			alert(partName + " " + partRev + " "+ "<%=onlyRootNodeExists%>");
  			return validationFailed;
  		}  	
  	}	  	
	return false;	  
}
  
  
function submitToFloatOnEBOM() {	 
	 document.emxTableForm.method = "post";
	 document.emxTableForm.target = "listHidden";
	 document.emxTableForm.action =  "../engineeringcentral/EBOMFloat.jsp";     
	 document.emxTableForm.submit(); 
  }
  
function appendToTableForm(paramName,paramValue) {
	var tempParam = jQuery('input[name=functionality]',document.emxTableForm);
	if(tempParam && tempParam.val()) {	 	
	 	tempParam.val(paramValue);
	 }
	 else {
	 	document.emxTableForm.appendChild(getHiddenField(paramName,paramValue));
	 }	 	 		
}

  function submitFromRevisionManagement() {
  	   	  
  	 var selectedRows        = emxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
  	 var isPartWhereUsed     = ("ENCWhereUsed" == jQuery("#frameName").val()) ? true : false;  	 
  	 var confirmationMessage = isPartWhereUsed ? "<%=whereUsedRevMgmtConfirmation%>" : "<%=revisionMgmtConfirmation%>"
  	 if(!confirm(confirmationMessage)) {
  	 	return;
  	 }  	 
  	 if(selectedRows.length <1) {
  	 	alert("<%=revMgmtNotSelectedError%>")
  	 	return;
  	 }
  	  appendToTableForm("functionality","submitFromRevisionManagement");   	 
	  submitToFloatOnEBOM();  	
  	  
  }

  function submitFromEvolveInstance() {
  	   	  
  	 var selectedRows        = emxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
  	   	 
  	 if(selectedRows.length <1) {
  	 	alert("<%=revMgmtNotSelectedError%>")
  	 	return;
  	 }
  	  appendToTableForm("functionality","submitFromEvolveInstance");   	 
	  submitToFloatOnEBOM();  	
  }
  
  function getValueForCell(rowId,cellName,valueType) {
 	 var cellContent    = emxEditableTable.getCellValueByRowId(rowId,cellName);
 	 return cellContent ?  valueType == "actual" ? cellContent.value.current.actual : cellContent.value.current.display : "";
  }
  
  function toggleSelectionInRevMgmt(tableRowId,selectionFlag) {
  
  		var arrId = tableRowId.split("|");
  		var selectedRowId = arrId[3];
  		var selectedRow  = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@id='"+selectedRowId+"']");
  		var selObjId	 = selectedRow.getAttribute("o");
  		var selObjName   = getValueForCell(selectedRowId,"Name","actual");
  		var selObjParent = getValueForCell(selectedRowId,"Parent","actual");
  		var selObjFN     = getValueForCell(selectedRowId,"Find Number","actual");
  		var selObjLevel  = getValueForCell(selectedRowId,"levelInfo","actual");
  		
  		//var sameObjectRows = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[child::c[@a='"+selObjName+"']]");
  		var sameObjectRows = emxUICore.selectNodes(oXML,"/mxRoot/rows//r[child::c[@a='"+selObjName+"'] and c[@a='"+selObjFN+"'] and c[@a='"+selObjLevel+"']]");
  		
  		if (sameObjectRows && sameObjectRows.length > 0) {
  			for(var i=0; i<sameObjectRows.length; i++) {  			
  				var eachRowId = sameObjectRows[i].getAttribute("id");
  				if(selectedRowId == eachRowId) continue;
		  		var objParent = getValueForCell(eachRowId,"Parent","actual");
		  		var objFN     = getValueForCell(eachRowId,"Find Number","actual");
		  		var objLevel  = getValueForCell(eachRowId,"levelInfo","actual");
				 				
  				if(selObjParent == objParent && selObjFN == objFN && selObjLevel == objLevel) {  					
  					//If one of the revisions chosen, remaining revisions need to be disabled.
  					selectionFlag ? sameObjectRows[i].setAttribute("disableSelection","true") : sameObjectRows[i].removeAttribute("disableSelection");	  				
  				}
  			}
  			rebuildView();
  		}  		 		
  }
  //UOM Management - start
function onUOMFocused() {
if(null !=emxEditableTable && "null" != emxEditableTable)		
	emxEditableTable.reloadCell("UOM");
return true;
}

function reloadUOMField(){
    emxFormReloadField("UOM");
}

 function reloadUOMFieldForTable(){
	  if(null !=emxEditableTable && "null" != emxEditableTable){
	  		emxEditableTable.reloadCell("Unit of Measure");
	  		var inputStr    = trim(arguments[0]);
		  	var defaultValue = getDefaultValue(inputStr );
		  	var defValueArr = defaultValue.split(":");
	 		emxEditableTable.setCellValueByRowId(currentRow.getAttribute("id"),"Unit of Measure",defValueArr[1],defValueArr[0],true);
	  	}
	  return true;
  }
  
  function reloadUOMFieldForTableForBOMPowerView(){
  	  var status = currentRow.getAttribute("status");
	  if(null !=emxEditableTable && "null" != emxEditableTable && status == "new"){
	  	emxEditableTable.reloadCell("UOM");
	  	var inputStr    = trim(arguments[0]);
		var defaultValue = getDefaultValue(inputStr );
		var defValueArr = defaultValue.split(":");
	 	emxEditableTable.setCellValueByRowId(currentRow.getAttribute("id"),"UOM",defValueArr[1],defValueArr[0],true);
	  }	
	  return true;
  }
 function onMultiPartCreate() {
	if(null !=emxEditableTable && "null" != emxEditableTable)		
		emxEditableTable.reloadCell("Unit of Measure");
	return true;
}
	function validateUOMOnApply()
        {
        var inputStr    = trim(arguments[0]);
        var uomCantBlank = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.UOMCanNotBeBlank")%>";
        if(inputStr == null || inputStr == "" || inputStr == "null")
        	return uomCantBlank;
		return "";
	}
	function validateUOM()
        {        
        var inputStr    = trim(arguments[0]);
        var uomCantBlank = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.UOMCanNotBeBlank")%>";
        if(inputStr == null || inputStr == "" || inputStr == "null")
        	return uomCantBlank;
		
		var sQtyValue = getValueForColumn("Quantity").replace(",",".");
		if(sQtyValue % 1 != 0 && inputStr == "<%=rangeEAeach%>"){
		//var VPLM_UOM_EA_EACH = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Qty.AllowEADecimal.String")%>";
		var VPLM_UOM_EA_EACH = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.UOM.AllowEADecimal.String")%>";
     		alert(VPLM_UOM_EA_EACH);
     		return false;
     	}
     	return true;
	}
	 function getDefaultValue(uomType) {
		var uomDisplay;
		var uomActual;
		switch (uomType) {
		    case "<%=uomTypeWeight%>":
		        uomDisplay = "<%=uomTypeWeightDefault%>";
		        uomActual = "<%=uomTypeWeightDefaultAct%>";
		        break;
		    case "<%=uomTypeArea%>":
		        uomDisplay = "<%=uomTypeAreaDefault%>";
		        uomActual = "<%=uomTypeAreaDefaultAct%>";
		        break;
		    case "<%=uomTypeLength%>":
		        uomDisplay = "<%=uomTypeLengthDefault%>";
		        uomActual = "<%=uomTypeLengthDefaultAct%>";
		        break;
		    case "<%=uomTypeLiquidVolume%>":
		        uomDisplay = "<%=uomTypeLiquidVolumeDefault%>";
		        uomActual = "<%=uomTypeLiquidVolumeDefaultAct%>";
		        break;
		   case "<%=uomTypeVolume%>":
		        uomDisplay = "<%=uomTypeVolumeDefault%>";
		        uomActual = "<%=uomTypeVolumeDefaultAct%>";
		        break;
		   case "<%=uomTypePorportion%>":
		        uomDisplay = "<%=uomTypePorportionDefault%>";
		        uomActual = "<%=uomTypePorportionDefaultAct%>";
		        break;
		} 
	return uomDisplay+":"+uomActual;
	}
//UOM Management - end

function onFocusChangeControlled(){
		if(null !=emxEditableTable && "null" != emxEditableTable){
			emxEditableTable.reloadCell("ChangeControlled");
		}		
		return true;
}

function onChangeReleaseProcess() {
	var status = currentRow.getAttribute("status");
	if(status != "new" && status != "lookup"){
		return true;
	}
	var changeControlledValAct = "<%=selectChangeControlledTrueAct%>";
	var changeControlledValDisp = "<%=selectChangeControlledTrueDisp %>";
	if(null !=emxEditableTable && "null" != emxEditableTable){
		var inputStr    = trim(arguments[0]);
	  	if(inputStr == "<%=EngineeringConstants.PRODUCTION%>"){
	  		emxEditableTable.setCellValueByRowId(currentRow.getAttribute("id"),"ChangeControlled",changeControlledValAct,changeControlledValDisp,true);
	  	}	 		
	}
	return true;
}
function openWhereUsedInSidePanel() {

	   var tabcommands = findFrame(getTopWindow(),"ENCBOM").parent.objPortal.rows[0].containers[1].tabset.tabs;
		 for (var i = 0; i < tabcommands.length; i++) {
		 if(tabcommands[i].tabName =="ENCWhereUsedCommand") {
					  tabcommands[i].click();     
			}                               
		}	    	   
}
function openDevMarkupInSidePanel() {

	   var tabcommands = findFrame(getTopWindow(),"ENCBOM").parent.objPortal.rows[0].containers[1].tabset.tabs;
		 for (var i = 0; i < tabcommands.length; i++) {
		 if(tabcommands[i].tabName =="ENCDevBOMMarkupsCommand") {
					  tabcommands[i].click();     
			}                               
		}	    	   
}
function openECMarkupInSidePanel() {

	   var tabcommands = findFrame(getTopWindow(),"ENCBOM").parent.objPortal.rows[0].containers[1].tabset.tabs;
		 for (var i = 0; i < tabcommands.length; i++) {
		 if(tabcommands[i].tabName =="ENCECBOMMarkupsCommand") {
					  tabcommands[i].click();     
			}                               
		}	    	   
}
function openBOMChartViewInSidePanel() {

	   var tabcommands = findFrame(getTopWindow(),"ENCBOM").parent.objPortal.rows[0].containers[1].tabset.tabs;
		 for (var i = 0; i < tabcommands.length; i++) {
		 if(tabcommands[i].tabName =="ENCBOMChartViewTabCommand") {
					  tabcommands[i].click();     
			}                               
		}	    	   
}
function open3DLiveExamineInSidePanel() {

	   var tabcommands = findFrame(getTopWindow(),"ENCBOM").parent.objPortal.rows[0].containers[1].tabset.tabs;
		 for (var i = 0; i < tabcommands.length; i++) {
		 if(tabcommands[i].tabName =="ENC3DLiveExamine") {
					  tabcommands[i].click();     
			}                               
		}	    	   
}

var rmtModifiedRowIds = new Array();


emxUICore.instrument = function(context, functionName, callOnEntry, callOnExit) {
    context = context || window;

    var original = context[functionName];

    while (!original && context.prototype) {
        original = context.prototype[functionName];
        context = context.prototype;
    }

    if (!original) {
        return false;
    }

    context[functionName] = function() {

        if (callOnEntry) {
        	try{
            var newResult = callOnEntry.apply(this, arguments);
            if (newResult == false) return;
            if (newResult instanceof Array) return newResult[0];
        	} catch (ex) {}
        }
        var result = original.apply(this, arguments);
        if (callOnExit) {
        	try{
            arguments[arguments.length] = result;
            arguments.length += 1;
            result = callOnExit.apply(this, arguments);
        	} catch (ex) {}
        }
        return result;
    };

    context[functionName]._original = original;
    return true;
};


emxUICore.instrument(editableTable, 'attachOrDetachEventHandlers', null,
    attachRMTEventHandlers);

	var bShowTreeExplorerAndDecorators = false;
if (typeof urlParameters != 'undefined')
    if (urlParameters.indexOf('showTreeExplorer') >= 0) {
        bShowTreeExplorerAndDecorators = true;
    }

function attachRMTEventHandlers() {

    // Dbl click to edit
    jQuery("#mx_divBody").dblclick(function(e) {
        e = e || window.event;
        ImgEditAndGetCell(e);
    });
    
    loadStructureRichTextData();
    mouseoverForSBRMT();
}


function findParentElementselected(object) {
    if (object != null) {
        if (object.id != "treeBodyTable" && object.id != "bodyTable") {
            id = findParentElementselected(object.parentElement);
        } else {
            id = object.id;
        }
    } else {
        id = null;
    }
    return id;
}

function findRowIndex(targetNode) {
    var RowIndex;
    if (targetNode.rowIndex == undefined) {
        RowIndex = findRowIndex(targetNode.parentNode);
    } else {
        RowIndex = targetNode.rowIndex;
    }
    return RowIndex;
}

function findCellIndex(targetNode) {
    var cellIndex;
    if (targetNode.cellIndex == undefined) {
        cellIndex = findCellIndex(targetNode.parentNode);
    } else {
        cellIndex = targetNode.cellIndex;
    }
    return cellIndex;
}

function ImgEditAndGetCell(event) {
    if (document.getElementById("ENCIndentedBOMEditAll") && editableTable.mode != "edit") {
        event = emxUICore.getEvent();
        var targetNode = event.target;
        var RowIndex = findRowIndex(targetNode);
        var ColIndex = findCellIndex(targetNode);

        // Set the current column position
        currentColumnPosition = ColIndex;
        currentCell.tableName = findParentElementselected(targetNode);
        editMode();
        getCell(RowIndex, ColIndex);
    }
}

function checkKeyPressEvent(event) {
    if (editableTable.mode == "edit" && event.which == 27) {
        viewMode();
        if (editableTable.mode == "view") {
            emxEditableTable.refreshStructureWithOutSort();
        }
    }
}

function moveToEditMode(functionality){
	var sbReference = findFrame(getTopWindow(), "ENCBOM")?findFrame(getTopWindow(), "ENCBOM"):findFrame(getTopWindow(), "content");
	var tablemode = sbReference.editableTable.mode; 
	var displayView = sbReference.displayView;
	
    var dupemxUICore = sbReference.emxUICore;    
     var oXML         = sbReference.oXML;
     var objId=sbReference.objectId;
     var checkedRows = dupemxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
	 if(checkedRows.length == 0){
		checkedRows = emxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@id='0']");
	 }
     var  ischild=true;
     var emxTableRowId ="";

     if(checkedRows.length == 0){
     	ischild=false;
     }
     for (var i = 0; i < checkedRows.length; i++) {
       var objectId = checkedRows[i].getAttribute("o");
       if(objectId==objId)
       {
        ischild=false;
        break;
       }
      }
     var length=checkedRows.length;
     if((checkedRows.length>1) && (functionality == "add" || functionality == "replace"))
      {
      	//XSSOK
       alert("<%=strMultipleSelection%>");
       return;
      }
      if(!ischild && (functionality == "cut" || functionality == "replace"))
      {
      	//XSSOK
      	if (functionality == "replace") {
      		alert("<%=strReplaceRootPart%>");
      	} else {
       		alert("<%=strRemoveRootPart%>");
       	}
       return;
      }

    var moveToEdit = false;
  if(functionality ==  "add"){    
    if(ischild){
      	objId = checkedRows[0].getAttribute("o");
      	var relId = checkedRows[0].getAttribute("r");
      	var parentId = checkedRows[0].getAttribute("p");
      	var rowId = checkedRows[0].getAttribute("id");
      	emxTableRowId = relId+"|"+objId+"|"+parentId+"|"+rowId;
      }
     else {
     	emxTableRowId = "|"+objId+"||0";
     }
     var strData = "objectId="+objId;
	var currentState = getActualValueForOtherColumn("State",checkedRows[0]);
	currentState = currentState.trim();
     	 if(!moveToEdit){
	       		if(currentState != "<%=DomainConstants.STATE_PART_PRELIMINARY%>"){
	       			moveToEdit = true;
	       		}
	       }
    }else {
    	for (var i = 0; i < checkedRows.length; i++) {
	       var relId = checkedRows[i].getAttribute("r");
	       var childId = checkedRows[i].getAttribute("o");
	       	var parentId = checkedRows[i].getAttribute("p");
      		var selectedRowId = checkedRows[i].getAttribute("id");
	       var strData = "objectId="+parentId;
			var currentState = getActualValueForOtherColumn("State",checkedRows[i].parentNode); 
			currentState = currentState.trim();
	       if(!moveToEdit){
	       		if(currentState != "<%=DomainConstants.STATE_PART_PRELIMINARY%>"){
	       			moveToEdit = true;
	       		}
	       }
	       if(emxTableRowId == ""){
		    		emxTableRowId = relId+"|"+childId+"|"+parentId+"|"+selectedRowId
		    	}
		    	else {
		    		emxTableRowId = emxTableRowId + "~"+relId+"|"+childId+"|"+parentId+"|"+selectedRowId
		    	}
      }
    }
     
	if(displayView && displayView != null && displayView != undefined && displayView != "detail" && moveToEdit)
      {
      	//XSSOK
       alert("<%=strEditInNonDetailsView%>");
       return;
      }
	if(moveToEdit){
    	editMode();
    	}
	return emxTableRowId; 
}
function createPart()
{
 	var emxTableRowId = moveToEditMode("add");
 	if(emxTableRowId == 'undefined' || emxTableRowId == null || emxTableRowId == 'null' || emxTableRowId ==''){
 		return;
 	}
 	var objId = (emxTableRowId.split("|"))[1];
	getTopWindow().showSlideInDialog("../engineeringcentral/PartCreatePreProcess.jsp?CreateMode=EBOM&multiPartCreation=true&selection=single&suiteKey=EngineeringCentral&objectId="+objId+"&emxTableRowId="+emxTableRowId, true);
            
}
function addExistingPart()
{
	var listHidden = document.getElementById("listHidden");
 	var emxTableRowId = moveToEditMode("add");
 	if(emxTableRowId == 'undefined' || emxTableRowId == null || emxTableRowId == 'null' || emxTableRowId ==''){
 		return;
 	}
 	var objId = (emxTableRowId.split("|"))[1];
 	var resultsPageURL = "../engineeringcentral/emxEngrFullSearchPreProcess.jsp?calledMethod=addExisting&suiteKey=EngineeringCentral&ENCBillOfMaterialsViewCustomFilter=engineering&objectId="+objId+"&emxTableRowId="+emxTableRowId;
    submitWithCSRF(resultsPageURL,listHidden);  
}

function removePart()
{
var result = confirm("<%=strRemoveConfirm %>");
if(true != result){
	return;
	}
	var listHidden = document.getElementById("listHidden");
 	var emxTableRowId = moveToEditMode("cut");
 	if(emxTableRowId == 'undefined' || emxTableRowId == null || emxTableRowId == 'null' || emxTableRowId ==''){
 		return;
 	}
 	var objId = (emxTableRowId.split("|"))[1];
 	//var resultsPageURL = "../engineeringcentral/emxpartDisconnectBOM.jsp?uiType=structureBrowser&suiteKey=EngineeringCentral&objectId="+objId+"&emxTableRowId="+emxTableRowId;
    
    //submitWithCSRF(resultsPageURL,listHidden); 

	var form = document.createElement('form');
	addSecureToken(form);
	addAppName(form);
	document.body.appendChild(form);
	
	form.appendChild(getHiddenField("emxTableRowId",emxTableRowId)); 
	form.method = "post";
	form.target = "listHidden";
	form.action = "../engineeringcentral/emxpartDisconnectBOM.jsp?uiType=structureBrowser&suiteKey=EngineeringCentral&objectId="+objId;     
	form.submit();

	removeSecureToken(form);
	document.body.removeChild(form);
}

function replaceExistingPart()
{
	
	var listHidden = document.getElementById("listHidden");
 	var emxTableRowId = moveToEditMode("replace");
 	if(emxTableRowId == 'undefined' || emxTableRowId == null || emxTableRowId == 'null' || emxTableRowId ==''){
 		return;
 	}
 	var objId = (emxTableRowId.split("|"))[2];
 	var resultsPageURL = "../engineeringcentral/emxEngrFullSearchPreProcess.jsp?calledMethod=replaceExisting&suiteKey=EngineeringCentral&ENCBillOfMaterialsViewCustomFilter=engineering&objectId="+objId+"&emxTableRowId="+emxTableRowId;
    
    submitWithCSRF(resultsPageURL,listHidden);      
}
function replaceNewPart()
{
	var listHidden = document.getElementById("listHidden");
 	var emxTableRowId = moveToEditMode("replace");
 	if(emxTableRowId == 'undefined' || emxTableRowId == null || emxTableRowId == 'null' || emxTableRowId ==''){
 		return;
 	}
 	var objId = (emxTableRowId.split("|"))[2];
 	var resultsPageURL = "../engineeringcentral/PartCreatePreProcess.jsp?CreateMode=EBOMReplaceNew&suiteKey=EngineeringCentral&ENCBillOfMaterialsViewCustomFilter=engineering&objectId="+objId+"&emxTableRowId="+emxTableRowId;
    
    showModalDialog(resultsPageURL, 850, 650);
  
}

/*******************************************************************************/
/* Validates the the value passed for decimals                                 */
/* if value contains only zeros after ".", value is still considered integer   */
/*******************************************************************************/
function doesnotHaveValueafterDecimal(cellValue)
{
	var num = ".0123456789";
	var decimalNum = "123456789";
	var decimalDigit = false;
	for(var i=0;i<cellValue.length;i++)
	{
		if(num.indexOf(cellValue.charAt(i))!=-1 && decimalDigit==false)
		{
			if("."==cellValue.charAt(i)){
				decimalDigit = true;
			}
		} else if(decimalNum.indexOf(cellValue.charAt(i))!=-1 && decimalDigit==true){
			alert("<emxUtil:i18nScript localize="i18nId">AT.BuildEBOM.QtyFieldNotValid</emxUtil:i18nScript>");
			return false;
		}
	}
	return true;
}

/*******************************************************************************/
/* Validates the Quantity entered from indented table edit while single cell edit */
/* if UOM Type is Proportion, then Quantity is only interger, no decimals .    */
/*******************************************************************************/
function validateQuantityOnUOMType(cellValue,cellPosition)
{
	if(validateQuantity(cellValue,cellPosition)){
	    var uomType = getValueForColumn("UOMType");
	    var Type = getValueForColumn("Type");
	    if( Type!=null && Type!="" && (Type=="Configuration Item" || Type=="Logical Node")){
	        return true;
	    }
	    if( uomType!=null && uomType!="" && uomType=="Proportion" && doesnotHaveValueafterDecimal(cellValue)){
	    var actualValue = getActualValueForColumn("AT_C_Quantity");
	    	if(actualValue>Number(cellValue)){
	    		alert("Please use Reduce quantity function");
	    		return false;
	    	} else {
	    		return true;
	    	}
	    } else if( uomType!=null && uomType!="" && uomType!="Proportion" ) {
	    	return true;
	    } else {
	    	return false;
	    }
    } else {
    	return false;
    }
}

/*******************************************************************************/
/* Validates the Quantity entered from indented table edit while apply        */
/* if UOM Type is Proportion, then Quantity is only interger, no decimals .    */
/*******************************************************************************/
function validateQuantityOnUOMTypeOnApply(cellValue,cellPosition){
	//var uomType = getValueForColumn("UOMType");
    //if( uomType!=null && uomType!="" && uomType=="Proportion" && doesnotHaveValueafterDecimal(cellValue)){
    //	return "";
    //} else if( uomType!=null && uomType!="" && uomType!="Proportion" ) {
    //	return "";
    //} else {
    //	return false;
    //}
    return "";
}

/*******************************************************************************/
/* if type is CI or EP the Cloning Behavior cannot be Duplicate */
/*******************************************************************************/
function validateCloningBehavior(cellValue,cellPosition){
var type = getValueForColumn("Type");
if( type!=null && type!="" && (type=="Configuration Item" || type=="Expected Product") ){
    if(cellValue=="Duplicate"){
    	var oldValue = getActualValueForColumn("CloningBehavior")
    	alert("Configuration Item or Expected Product duplication is available only if they are root nodes");
    	emxEditableTable.setCellValueByRowId(cellPosition,"CloningBehavior",oldValue,oldValue,true);
    	return false;
    } else {
    	return true;
    }
}else{
	return true;
}
}

function refreshViewAfterCloningBehaviourSave(){
	if (editableTable.mode == "edit") {
		var rootNode  = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@id='0']");
		var objId = rootNode.getAttribute("o");
		emxEditableTable.performXMLDataPost();
		document.location.href="../engineeringcentral/ATemxEngrCloneIntermediate.jsp?copyObjectId="+objId+"&createMode=PartProperties&cloningBehaviour=true&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&objectId="+objId+"&parentOID="+objId+"";
    }
}

