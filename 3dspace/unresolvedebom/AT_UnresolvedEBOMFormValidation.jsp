<%--  UnresolvedEBOMFormValidation.jsp   - page to include the custom webform validation functions.
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>

<%
out.clear();
response.setContentType("text/javascript; charset=" + response.getCharacterEncoding());

String accLanguage  = request.getHeader("Accept-Language");
Locale Local = context.getLocale();
String fnLength  =   JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","FindNumberLength");
String rdLength     = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","ReferenceDesignatorLength");
String fnUniqueness = JSPUtil.getCentralProperty(application, session,"emxUnresolvedEBOM","FindNumberUnique");
String rdUniqueness = JSPUtil.getCentralProperty(application, session,"emxUnresolvedEBOM","ReferenceDesignatorUnique");
String ebomUniquenessOperator = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","EBOMUniquenessOperator");
String fnDisplayLeadingZeros = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","FindNumberDisplayLeadingZeros");
String rdQtyValidation = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","ReferenceDesignatorQtyValidation");
//2012
//String isWipBomAllowed = FrameworkProperties.getProperty("emxUnresolvedEBOM.WIPBOM.Allowed");
String isWipBomAllowed = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOM.WIPBOM.Allowed");
//String emxNameBadChars = FrameworkProperties.getProperty("emxFramework.Javascript.NameBadChars");
String emxNameBadChars = EnoviaResourceBundle.getProperty(context,"emxFramework.Javascript.NameBadChars");
String msgFNValidationKey = "emxEngineeringCentral.Common.FindNumberHasToBeANumber";
String attFindNumber = com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,"attribute_FindNumber");
String attRefDes = com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,"attribute_ReferenceDesignator");

//Float ON EBOM validations
String propertySuite = "emxEngineeringCentralStringResource";

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
String ReplaceRevisionOnAddedDeleted = EnoviaResourceBundle.getProperty(context,propertySuite,locale,"FloatOnEBOMManagement.Validation.ReplaceRevisionOnAddedDeleted");

//Added for BGTP
Locale en = new Locale("en");
String selectChangeControlledTrueAct = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",en,"emxFramework.Range.Change_Controlled.True");
String selectChangeControlledTrueDisp = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Range.Change_Controlled.True");
String selectChangeControlledFalseAct = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",en,"emxFramework.Range.Change_Controlled.False");
String selectChangeControlledFalseDisp = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Range.Change_Controlled.False");



//2012
%>
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
var rdQtyValidation        = "<%=rdQtyValidation%>";
//XSSOK
var fnDisplayLeadingZeros  = "<%=fnDisplayLeadingZeros%>";
//XSSOK
var attFindNumber		   = "<%=attFindNumber%>";
//XSSOK
var attRefDes			   = "<%=attRefDes%>";
//XSSOK
var FN_UNIQUE_MSG = "<%=i18nStringNowUtil("emxEngineeringCentral.FindNumber.Unique","emxEngineeringCentralStringResource",accLanguage)%>";
//XSSOK
var FN_VALIDATION = "<%=i18nStringNowUtil("emxEngineeringCentral.FindNumber.ValidationFailed","emxEngineeringCentralStringResource",accLanguage)%>";
var fnPropertyArray = new Array();
var rdPropertyArray = new Array();
var newArray = new Array();
<%
//create array of FN/RD Required property settings
String parentAlias = "";
String fnRequired = "";
String rdRequired = "";
//330846 - Modified below line to get type name from symbolic name.
String partType = PropertyUtil.getSchemaProperty(context,"type_Part");
StringTokenizer stsubTypes = null;

MQLCommand mqlCmd = new MQLCommand();
//330846 - Used above declared variable in the below MQL
mqlCmd.executeCommand(context, "print type \""+partType+"\" select derivative dump |");
String subTypes = mqlCmd.getResult();
if ( subTypes != null )
{
    stsubTypes = new StringTokenizer( subTypes, "|" );
}
do
{
    parentAlias  = FrameworkUtil.getAliasForAdmin(context, "type", partType, true);
    fnRequired   = JSPUtil.getCentralProperty(application, session,parentAlias,"FindNumberRequired");
    if(fnRequired==null || "null".equals(fnRequired) || "".equals(fnRequired))
    {
        fnRequired= EngineeringUtil.getParentTypeProperty(context,partType,"FindNumberRequired");
    }
    rdRequired   = JSPUtil.getCentralProperty(application, session,parentAlias,"ReferenceDesignatorRequired");
    if(rdRequired==null || "null".equals(rdRequired) || "".equals(rdRequired))
    {
        rdRequired= EngineeringUtil.getParentTypeProperty(context,partType,"ReferenceDesignatorRequired");
    }
%>
	//XSSOK
    fnPropertyArray["<%=partType%>"]="<%=fnRequired%>";
    //XSSOK
    rdPropertyArray["<%=partType%>"]="<%=rdRequired%>";
<%
    if (stsubTypes!=null && stsubTypes.hasMoreTokens())
    {
        partType = stsubTypes.nextToken().trim();
    }
    else
    {
        partType = null;
    }
} while (partType != null )	;
%>

<%
HashMap hmRev = new HashMap();
MapList mResult = new MapList();
MapList policyList = new MapList();
HashMap argsMap = new HashMap();
argsMap.put("type", DomainConstants.TYPE_PART);
mResult = (com.matrixone.apps.domain.util.MapList)JPO.invoke(context, "emxUnresolvedPart", null, "getPolicyRevision", JPO.packArgs(argsMap),com.matrixone.apps.domain.util.MapList.class);

hmRev = (HashMap)mResult.get(0);
policyList = (MapList)mResult.get(1);


for(int i=0;i<policyList.size();i++)
{
%>
//XSSOK
newArray["<%=(String)policyList.get(i)%>"]="<%=(String)hmRev.get((String)policyList.get(i))%>";
<%
}
%>
//IR-016850 - Starts
//XSSOK
var RD_UNIQUE_MSG = "<%=i18nStringNowUtil("emxEngineeringCentral.ReferenceDesignator.Unique","emxEngineeringCentralStringResource",accLanguage)%>";
//XSSOK
var RD_VALIDATION = "<%=i18nStringNowUtil("emxEngineeringCentral.ReferenceDesignator.ValidationFailed","emxEngineeringCentralStringResource",accLanguage)%>";
//IR-016850 - Ends
//XSSOK
var INVALID_FORMAT_MSG = "<%=i18nStringNowUtil("emxEngineeringCentral.ReferenceDesignator.InvalidFormat", "emxEngineeringCentralStringResource",accLanguage)%>";
//XSSOK
var MULTI_PREFIX_MSG = "<%=i18nStringNowUtil("emxEngineeringCentral.ReferenceDesignator.MultiplePrefix", "emxEngineeringCentralStringResource",accLanguage)%>";
//XSSOK
var INVALID_CHAR_MSG ="<%=i18nStringNowUtil("emxEngineeringCentral.ReferenceDesignator.InvalidChar","emxEngineeringCentralStringResource",accLanguage)%>";
//XSSOK
var INVALID_QUANTITY = "<%=i18nStringNowUtil("emxEngineeringCentral.ReferenceDesignator.SingleQuantity","emxEngineeringCentralStringResource",accLanguage)%>";
//XSSOK
var NOT_UNIQUE_MSG= "<%=i18nStringNowUtil("emxEngineeringCentral.ReferenceDesignator.NotUnique","emxEngineeringCentralStringResource",accLanguage)%>";
//XSSOK
var SINGLE_RANGE_MSG= "<%=i18nStringNowUtil("emxEngineeringCentral.ReferenceDesignator.Range","emxEngineeringCentralStringResource",accLanguage)%>";
//XSSOK
var INVALID_MSG= "<%=i18nStringNowUtil("emxEngineeringCentral.ReferenceDesignator.Invalid","emxEngineeringCentralStringResource",accLanguage)%>";
//XSSOK
var VALUE_SEPARATOR_MSG= "<%=i18nStringNowUtil("emxEngineeringCentral.ReferenceDesignator.DiffValues","emxEngineeringCentralStringResource",accLanguage)%>";
//XSSOK
var RANGE_SEPARATOR="<%=JSPUtil.getCentralProperty(application,session,"emxEngineeringCentral","RangeReferenceDesignatorSeparator")%>";
//XSSOK
var SINGLE_SEPARATOR="<%=JSPUtil.getCentralProperty(application,session,"emxEngineeringCentral","DelimitedReferenceDesignatorSeparator")%>";
//2012--Starts
//XSSOK
var EFFECTIVITY_ALERT="<%=i18nStringNowUtil("emxUnresolvedEBOM.CurrentEffectivity.alert","emxUnresolvedEBOMStringResource",accLanguage)%>";
//XSSOK
var sBadCharInName  = "<%=emxNameBadChars%>";
//2012--ends
/******************************************************************************/
/* function isEmpty() - checks whether the value is blank or not              */
/*                                                                            */
/******************************************************************************/

function isEmpty(s)
{
  return ((s == null)||(s == "null")||(s.length == 0));
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

/********************************************************************************* /
/* function isPolicy(Pname) - 2012x   */
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

function validateSpecialCharOnName (sName,sFlag) {

    var ARR_FOR_BAD_CHARS = "";
    if (sBadCharInName != "") 
    {    
        ARR_FOR_BAD_CHARS = sBadCharInName.split(" ");   
    }
    var namebadCharName = checkStringForChars(sName,ARR_FOR_BAD_CHARS);
 
    if (namebadCharName.length != 0){
            alert("<emxUtil:i18nScript localize="i18nId">emxUnresolvedEBOM.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
            return false;
    } else {
            return true;
    }
            
}

    function checkStringForChars(strText, arrBadChars) {
        strText = strText.trim();
        var strBadChars = "";
        for (var i=0; i < arrBadChars.length; i++) {
            if (strText.indexOf(arrBadChars[i]) > -1 && arrBadChars[i] != " ") {
                    strBadChars += arrBadChars[i] + " ";
            }
        }
        if (eval(strBadChars.length) > 0) {
            return strBadChars;
        } else {
            return "";
        }
    }
    
String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
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
       arrayValue = cellData[i];
       if(cellData[i]!="" && cellData[i]!=cellActualValue){
       if(fnDisplayLeadingZeros.toLowerCase()=="true" && arrayValue!="" && fnLength>0 && arrayValue.length==fnLength)
       {
           arrayValue = arrayValue.substring(arrayValue.lastIndexOf('0')+1,arrayValue.length);
       }
           if(arrayValue!="" && parseFloat(arrayValue)==parsedinputFN)
       {
           return false;
       }
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

/*	validateFNByLevelOnApply
	getChildRows
*/


function validateFNByLevelOnApply(str1,str2) {
   	if(str2 == "lookup" || str2 =="new"){
			return true;
	}
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
				curFNVal = getCurrentValue(attFindNumber,curFNObj);
				var status = inputFNArray[i].getAttribute("status");
                //if(status != null && (typeof status != 'undefined') && status == 'cut'){
                if(status !='cut'){
                    inputFNValues[k] = curFNVal;
					k++;
                }
				var strMsg = validateFNValue(curFNObj,curFNVal)
				if(strMsg != "" && strMsg.length >0){
					return strMsg;

				}

			}
			strMsg = (fnUniqueness && fnUniqueness.toLowerCase()=="true")?checkForUniqueness(inputFNValues):"";
			if(strMsg != "" && strMsg.length >0){
				return strMsg;
			}
		}

	return "";
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
		if(typeof fnValueArray[j]!="undefined" && typeof fnValueArray[j-1]!="undefined"){
			if(trim(fnValueArray[j-1]) != "" && trim(fnValueArray[j]) != "" && fnValueArray[j-1]==fnValueArray[j]) {
				return false;
			}
		}
	}
	return true;
  }

   /*
getChildRows will retriew all the childrows from the parent
*/
function getChildRows(parent) {
	var mCurrentRow =emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@id = '" + parent + "']");
	var childRows = emxUICore.selectNodes(mCurrentRow, "r");
	return childRows;
}

	/*
	This method will return the latest value i.e., modified value for the given cell
	*/
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
var strarr = flattenRD(rdValueArray);
       if(strarr.indexOf(SINGLE_SEPARATOR)==0) {
	strarr=strarr.substring(1);
    }
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
				curRDVal = getCurrentValue(attRefDes,curRDObj);
				curQtyVal = getCurrentValue("AT_C_Quantity",curRDObj);
				//IR-028660V6R2011
				var status = inputRDArray[i].getAttribute("status");
                //if(status != null && (typeof status != 'undefined') && status == 'cut'){
                if(status !='cut'){
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
			strMsg = (rdUniqueness && rdUniqueness.toLowerCase()=="true")?checkForRDUniqueness(inputRDValues):"";
			if(strMsg != "true" && strMsg != "" && strMsg.length >0){
				return strMsg;
			}
		}
		return "";
	}


/*******************************************************************************/
/* function validateFNByLevel()                                                */
/* Validates the Find Number entered from indented table edit  .               */
/*******************************************************************************/
function validateFNByLevel()
{
	var cellData   = getColumnDataAtLevelOnValidate();
    var inputFN    = trim(arguments[0]);
    if (inputFN.length == 1 && !isNaN(inputFN) && undefined == eval(inputFN)) {
        inputFN = "";
    }
    inputFN		   = (inputFN == "") ? getValueForColumn(attFindNumber) : inputFN ;
    var objectType = getActualValueForColumn("Type");
    var fnRequired = fnPropertyArray[objectType];
    var rdValue    = getValueForColumn(attRefDes);
    var rdRequired = rdPropertyArray[objectType];
	
	var cellActualValue = getValueForColumn(attFindNumber);
	    
    if(fnRequired.toLowerCase()=="true" && rdRequired.toLowerCase()=="true")
    {
    	if(!validateFNRDByLevel(inputFN,rdValue,fnRequired,rdRequired))
    	{
			return false;
		}
	}
	else
	{
        if(fnRequired.toLowerCase()!="false")
        {
            if(isEmpty(inputFN))
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
                return false;
            }
        }
	}


	if(fnUniqueness.toLowerCase()=="true" && !isFNUnique(cellData,inputFN,cellActualValue))
	{		
  	    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
        return false;
	}
	if(chkLength(fnLength,inputFN))
	{
		alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldLengthExceedsMaxLimit</emxUtil:i18nScript>"+" "+fnLength);
		return false;
	}
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
function validateRDByLevel()
{
    var cellData   = getColumnDataAtLevelOnValidate();
    var inputRD    = arguments[0];
    if (inputRD.length == 1 && !isNaN(inputRD) && undefined == eval(inputRD)) {
        inputRD = "";
    }
    inputRD	= (inputRD == "") ? getValueForColumn(attRefDes) : inputRD;
    var objectType = getActualValueForColumn("Type");
    var fnRequired = fnPropertyArray[objectType];
	var fnValue    = getValueForColumn(attFindNumber);
	var rdRequired = rdPropertyArray[objectType];
	
	var cellActualValue = getValueForColumn(attRefDes);
	var refDesignatorCellData = new Array();
    var refIndex=0;
    for(var i=0;i<cellData.length;i++)
    {
		if(cellData[i]!="" && cellData[i]!=cellActualValue)
		{
			refDesignatorCellData[refIndex]=cellData[i];
			refIndex++;
		}
	}

    //if(fnRequired.toLowerCase()=="true" && fnUniqueness.toLowerCase()=="true" && rdRequired.toLowerCase()=="true" && rdUniqueness.toLowerCase()=="true")
    if(fnRequired.toLowerCase()=="true" && rdRequired.toLowerCase()=="true")
    {

	    if(!validateFNRDByLevel(fnValue,inputRD,fnRequired,rdRequired))
	    {
			return false;
		}
	}
	else
	{
         if(rdRequired.toLowerCase()!="false")
         {
             if(isEmpty(inputRD))
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
         }
         if(rdUniqueness.toLowerCase()=="true")
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

    function validateFNValue(curFNObj,curFNVal) {
        
                 var inputFN = curFNVal;

                var objectType = getActualValueForColumn("Type");
                var fnRequired = fnPropertyArray[objectType];
                var rdValue    = getValueForColumnOnApply(attRefDes, curFNObj);
                var rdRequired = rdPropertyArray[objectType];
                var cellActualValue = getValueForColumnOnApply(attFindNumber, curFNObj);

	            if(isNaN(inputFN)) {
	            //XSSOK
	                   return ("<%=EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",Local,msgFNValidationKey)%>");
	
	               }
                else if ((inputFN).substr(0,1) == '-') {
                //XSSOK
                            return ("<%=EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",Local,msgFNValidationKey)%>");

                    }
                 //if(fnRequired && fnUniqueness && rdRequired && rdUniqueness && fnRequired.toLowerCase()=="true" && fnUniqueness.toLowerCase()=="true" && rdRequired.toLowerCase()=="true" && rdUniqueness.toLowerCase()=="true") {
                 if(fnRequired && rdRequired && fnRequired.toLowerCase()=="true" && rdRequired.toLowerCase()=="true") {
                        var msgvalFNRD = validateFNRDOnApply(inputFN,rdValue,fnRequired,rdRequired)
                        if(msgvalFNRD != "") {
                            return msgvalFNRD;
                    }
            }


            if(fnRequired && rdRequired && fnRequired.toLowerCase()!="false" && rdRequired.toLowerCase() != "true") {
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
	        retValue = (lastobj.nodeValue == null) ? (isIE)?lastobj.text:lastobj.textContent : lastobj.nodeValue;
	    }
	    return (retValue);
    }
    
    /**
 	* Send an array of values for the current nodes
 	* sibling nodes
 	*/
	function getColumnDataAtLevelOnValidate(){

	    var level = currentRow.getAttribute("level");
	    var xpath = "r";
	    var aRowsAtLevel = null;
	    if (level == "0") {
	        aRowsAtLevel = emxUICore.selectNodes(oXML, "/mxRoot/rows/r");
	    } else {
	        aRowsAtLevel = emxUICore.selectNodes(currentRow.parentNode, "r");
	    }
	    
	    fillupColumns(aRowsAtLevel, 0, aRowsAtLevel.length);
	
	    var returnArray = new Array();
	    for(var i=0;i < aRowsAtLevel.length; i++){
	        var lastobj = emxUICore.selectSingleNode(aRowsAtLevel[i], "c[" + currentColumnPosition + "]").lastChild;
	        if (lastobj) {
	            returnArray[i] = (lastobj.nodeValue == null) ? (isIE)?lastobj.text:lastobj.textContent : lastobj.nodeValue;
	        }
	        else {
	            returnArray[i] = "";
	        }
	    }
    return returnArray;
}

/*******************************************************************************/
/* function validateQuantity()                                                 */
/* Validates the Quantity entered from indented table edit                     */
/*******************************************************************************/

function validateQuantity()
{
    var objectType = getActualValueForColumn("Type");
    var fnRequired = fnPropertyArray[objectType];
    var rdRequired = rdPropertyArray[objectType];
    
    var qtyvalue = arguments[0];
    var fnValue	= getValueForColumn(attFindNumber);
    var rdValue = getValueForColumn(attRefDes);
    
    /* Commented for Bug 177926 
    if(isEmpty(fnValue) && isEmpty(rdValue) && fnRequired.toLowerCase()=="true" && rdRequired.toLowerCase()=="true")
    {
    	if(!validateFNRDByLevel(fnValue,rdValue,fnRequired,rdRequired))
    	{
			return false;
		}
	}
	//end of 177926 
	*/
	
    if(qtyvalue != null)
    {
      if( isEmpty(qtyvalue)) {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.Quantityfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
        return false;
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
			  var rdQty = getRDQuantity(rdValue)
			  if (qtyvalue != rdQty)
			  {
				alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity</emxUtil:i18nScript>");
				return false;
			  }
		  } else {
		     return false;
		  }
	  }

    }
    return true;
}
/*******************************************************************************/
/* function validateQuantityonApply()                                          */
/* Validates the Quantity and RD values on Apply Edits                         */
/*******************************************************************************/
//IR-016850 - Starts
//function validateQuantityonApply()
function validateQuantityonApply(rdValue, qtyvalue)
//IR-016850 - Ends
{
    //var rdValue = getValueForColumn(attRefDes);
    //var qtyvalue = getValueForColumn("Quantity");
    if(qtyvalue != null)
    {
      if(!isNumeric(qtyvalue))
      {
        return "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeANumber</emxUtil:i18nScript>";
      }
      
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
    var findNumberValue = (isEmpty(fnObjValue))?fnObjValue:trim(fnObjValue);
    var rdvalue         = rdObjValue;
    if(ebomUniquenessOperator.toLowerCase()=="and")
    {
              if(isEmpty(findNumberValue))
              {
                  alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNfieldisemptypleaseenteranumber</emxUtil:i18nScript>");
                  return false;
              }
              if(isEmpty(rdvalue))
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
        if(isEmpty(findNumberValue) && isEmpty(rdvalue))
        {
             alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNAndRDfieldemptypleaseenterAnyOne</emxUtil:i18nScript>");
             return false;
        }
        if(!isEmpty(rdvalue))
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
    var strarr=new Array();
    var stalpha ;
    longstr = flattenRD(arr);
    st2=longstr.split(SINGLE_SEPARATOR);
    finalarr=st2;
    finalarr.sort();
    dup=finalarr.toString();

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
    for(i=0;i < arr.length;i++)
    {
           var newarr=new Array();
           newstr=arr[i];
           if(newstr.indexOf(RANGE_SEPARATOR) != -1)
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
function showPendingIcon(objId){
	document.getElementById(objId).style.visibility='visible';
	document.getElementById(objId).src='../common/images/iconRetainedSearch.gif';

}

    /**
    This method validates reference designator value.
    */

    function validateRDValue(curRDObj,curRDVal)
    {

    var inputRD    = curRDVal;
    var objectType = getActualValueForColumn("Type");
    var rdRequired = rdPropertyArray[objectType];
    var fnRequired = fnPropertyArray[objectType];

    var fnValue = getValueForColumnOnApply(attFindNumber, curRDObj);
    
   // if(fnRequired && fnUniqueness && rdRequired && rdUniqueness && fnRequired.toLowerCase()=="true" && fnUniqueness.toLowerCase()=="true" && rdRequired.toLowerCase()=="true" && rdUniqueness.toLowerCase()=="true")
    if(fnRequired && rdRequired && fnRequired.toLowerCase()=="true" && rdRequired.toLowerCase()=="true")
    {

        var msgvalFNRD = validateFNRDOnApply(fnValue,inputRD,fnRequired,rdRequired)
                        if(msgvalFNRD != "") {
                            return msgvalFNRD;
                    }
    }else {
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
        attachEventHandler(window, "load", refreshFiltersInWhereUsed);
    }

    function refreshFiltersInWhereUsed(){
        //Once Toolbar is loaded, load them with initial values
        setTimeout(initialProcessingInWhereUsed, 400);        
    }

    /*
    * This function loads product filter with initial value
    */
    function initialProcessingInWhereUsed() {
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
    var selectedLevel = getTopWindow().document.getElementById("ENCPartWhereUsedLevel").value;
    if (selectedLevel == "UpTo..." || selectedLevel == "UpTo..And Highest") {
        var levelValue = getTopWindow().document.getElementById("ENCPartWhereUsedLevelTextBox").value;
        if (!isNumeric(levelValue) || !validateInt(levelValue) || (levelValue.substr(0, 1) == "-")) {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.WhereUsedLevelShouldBeNumeric</emxUtil:i18nScript>");
            return;
        }
    }

    var sURL = "../common/emxIndentedTable.jsp?partWhereUsed=true&header=emxEngineeringCentral.Common.WhereUsed&suiteKey=UnresolvedEBOM&table=PartWhereUsedTable&program=emxPart:getPartWhereUsed&toolbar=ENCpartReviewWhereUsedSummaryToolBar,ENCPartWhereUsedFiltersToolbar1,ENCPartWhereUsedFiltersToolbar2&HelpMarker=emxhelppartwhereused&selection=multiple&expandLevelFilter=false";
	
    var fieldArr = ["objectId", "portalMode", "ENCPartWhereUsedLevel", "ENCPartWhereUsedLevelTextBox", "ENCPartWhereUsedRevisions", "ENCPartWhereUsedRelated", "ENCPartWhereUsedRefDesTextBox", "ENCPartWhereUsedFNTextBox", "ENCPartWhereUsedEBOMSubCheckBox", "CFFExpressionFilterInput", "CFFExpressionFilterInput_actualValue", "CFFExpressionFilterInput_OID","PUEUEBOMProductConfigurationFilter", "PUEUEBOMProductConfigurationFilter_actualValue", "PUEUEBOMProductConfigurationFilter_OID"];

    for (var i = 0; i < fieldArr.length; i++) {
        fieldObject = document.getElementById(fieldArr[i]);
        if(fieldObject== null || fieldObject == "undefined" || fieldObject == "null" || fieldObject.value == "" || fieldObject.value == null){
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

    this.document.location.href = sURL;
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
	
	isConfiguredBOM = ("true" == jQuery("#fromConfigBOM").val()) ? true : false;
	var selectedRows = emxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
	var confirmation = "";  	
 	
  	if(isConfiguredBOM) {
  		confirmation = (selectedRows.length > 0 ) ? "<%=replaceSelectedConfirmation%>" : "<%=replaceAllConfirmation%>";
  	}  	
	if(validateForAddOrCutStatusRows(functionality)) { // To check whether rows were involved in add or cut operation 
		return;
	}
		
  	if(functionality == "replaceWithSpecificRevision" && selectedRows.length > 1) {  		
  			alert("<%=selectOneItemOnly%>");  		
  			return;  			
  	}
	if(validateReplaceCommands()) {  // validate selections In case of bom powerview only
		return;
	}  	
	if((functionality == "replaceWithLatestRevision" || functionality == "replaceWithLatestReleased") && !confirm(confirmation)) {
		return;	
	}
  	if(functionality != "replaceWithSpecificRevision" || functionality != "replaceWithSpecificRevisionForAll") {
    	        toggleProgress("visible");    	
        }
  	
  	

  		  	
	appendToTableForm("functionality",functionality);   	 
	submitToFloatOnEBOM();  
  }
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

function getHiddenField(name,val) {		
	var ele = document.createElement('input');
	ele.setAttribute("type","hidden");
	ele.setAttribute("name",name);
	ele.setAttribute("value",val);
	return ele;
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
  			
			//validation for configured part
		  	if(policy == "Configured Part") {
		  		alert("<%=configuredPartsNotAllowed%>" + " "+partName+" "+partRev);
		  		return validationFailed;
		  	}		  				  			  			  	
		  	//Validation for already latest part revision		  			  
		  	if(revStatus != "null" &&  revStatus != undefined && revStatus.indexOf("img") < 0) {
				alert(partName + " " + partRev + " "+ "<%=partAlreadyLatestRevisionError%>");
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
	if(document.emxTableForm.paramName) {
	 	document.emxTableForm.paramName.value = paramValue;
	 }
	 else {
	 	document.emxTableForm.appendChild(getHiddenField(paramName,paramValue));
	 }	 	 		
}

  function submitFromRevisionManagement() {
  	   	  
  	 var selectedRows = emxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
	  if(!confirm("<%=revisionMgmtConfirmation%>")) {
	  	return;
	  }
  	 if(selectedRows.length <1) {
  	 	alert("<%=revMgmtNotSelectedError%>")
  	 	return;
  	 }
  	  appendToTableForm("functionality","submitFromRevisionManagement");   	 
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
	  if(null !=emxEditableTable && "null" != emxEditableTable)
	  	emxEditableTable.reloadCell("Unit of Measure");
	  return true;
  }
  
  function reloadUOMFieldForTableForBOMPowerView(){
	  if(null !=emxEditableTable && "null" != emxEditableTable)
	  	emxEditableTable.reloadCell("UOM");
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
//UOM Management - end
  
function onFocusChangeControlled(){
		if(null !=emxEditableTable && "null" != emxEditableTable)		
			emxEditableTable.reloadCell("ChangeControlled");
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
	  	else if(inputStr == "<%=EngineeringConstants.DEVELOPMENT%>"){
	  		emxEditableTable.setCellValueByRowId(currentRow.getAttribute("id"),"ChangeControlled","<%=selectChangeControlledFalseAct%>","<%=selectChangeControlledFalseDisp%>",true);
	  	}
	  	
	  	 		
	}
	
	return true;
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