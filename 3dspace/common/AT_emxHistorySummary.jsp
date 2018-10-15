<%-- emxHistorySummary.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxHistorySummary.jsp.rca 1.48.2.1 Fri Nov  7 09:39:39 2008 ds-kvenkanna Experimental $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>

<head>
<title>History</title>

<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<script src="scripts/emxNavigatorHelp.js" type="text/javascript"></script>
<%
    DomainObject boGeneric = DomainObject.newInstance(context);

    boolean isPrinterFriendly = false;
    String Header=emxGetParameter(request, "Header");
    String sAction  = "";
    String sActionProp  = "";
    String sActionI18N = "";
    String sStateI18N = "";
    String sUser    = "";
    String sTime    = "";
    String sDescription  = "";
    String sState   = "";
    String hiddenActions="";
    String sComma=",";
    String HistoryMode ="";
    String SpecialCaseAccesses ="";
    TreeMap TMap=new TreeMap();
    String subHeader                = emxGetParameter(request, "subHeader");
    String sFilter                  = emxGetParameter(request, "txtFilter");
    sFilter = XSSUtil.decodeFromURL(sFilter);
    HistoryMode                     = emxGetParameter(request, "HistoryMode");
    String aFilter                  = emxGetParameter(request, "hiddenActionFilter");
    String sBusId                   = emxGetParameter(request, "objectId");
    String jsTreeID                 = emxGetParameter(request,"jsTreeID");
    String suiteKey                 = emxGetParameter(request,"suiteKey");
    StringBuffer sParams = new StringBuffer(50);
    sParams.append("jsTreeID=");
    sParams.append(XSSUtil.encodeForURL(context, jsTreeID));
    sParams.append("&objectId=");
    sParams.append(XSSUtil.encodeForURL(context, sBusId));
    sParams.append("&suiteKey=");
    sParams.append(XSSUtil.encodeForURL(context, suiteKey));
    String printerFriendly          = emxGetParameter(request, "PrinterFriendly");

    String revisionlist             = emxGetParameter(request, "revisionlist");
    String fromlist                 = emxGetParameter(request, "fromlist");
    String tolist                   = emxGetParameter(request, "tolist");
    String preFilter                = emxGetParameter(request,"preFilter");
    String showFilterAction         = emxGetParameter(request,"showFilterAction");
    String showFilterTextBox        = emxGetParameter(request,"showFilterTextBox");

    String DateFrm = PersonUtil.getPreferenceDateFormatString(context);
    String historySelects=emxGetParameter(request,"historySelects");

    if(preFilter!=null  && !preFilter.equalsIgnoreCase("null") &&
                        !preFilter.equalsIgnoreCase("*") && !preFilter.equals("")) {
        aFilter=preFilter;
    }

    String resourceFile = ( suiteKey != null && suiteKey.length() > 0 ) ?
        UINavigatorUtil.getStringResourceFileId(context, suiteKey) :
        "emxFrameworkStringResource";

    BusinessObject lastestRevObject = new BusinessObject();
    BusinessObjectList bObjList     = new BusinessObjectList();
    String subHeaderOriginal        = subHeader;

    SpecialCaseAccesses = EnoviaResourceBundle.getProperty(context, "emxFramework.History.SpecialActionType");

    if(SpecialCaseAccesses==null || SpecialCaseAccesses.equals("")){
        SpecialCaseAccesses="change owner,change policy,change type,change name,change vault,modify form,vc connect,add interface,vc checkin,vc checkout,vc modify,vc lock,vc unlock,vc modify connection,vc delete connection,remove interface";
    }

    if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly)) {
        isPrinterFriendly = "true".equals(printerFriendly);
    }
    String sSubHeader = EnoviaResourceBundle.getProperty(context,resourceFile , request.getLocale(), subHeader);

    // If key is not found in resource file, try the framework file
    if ( subHeader != null && subHeader.equals(sSubHeader) )
    	sSubHeader = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, subHeader, request.getLocale());

    if(sSubHeader==null || sSubHeader.equals("")) {
        sSubHeader="Revision";
    }
%>
<script language="javascript">
<%    
    if(isPrinterFriendly) {
%>
		addStyleSheet("emxUIDefaultPF");
		addStyleSheet("emxUIListPF");
<%
    } else {
%>
		addStyleSheet("emxUIDefault");
		addStyleSheet("emxUIList");
<%
    }
%>
</script>
<%if(UINavigatorUtil.isMobile(context)) { %>
    	<LINK rel="stylesheet" href="mobile/styles/emxUIMobile.css" type="text/css" />
    <%} %>
</head>
<body class="content" onload="turnOffProgress();">
<%if(UINavigatorUtil.isMobile(context)) { %>
    	<div class="history-wrapper">
<%} %>
<%
    if(isPrinterFriendly) {
        String sHeader =EnoviaResourceBundle.getProperty(context,resourceFile , request.getLocale(), Header);

        // If key is not found in resource file, try the framework file
        if ( Header != null && Header.equals(sHeader) )
        	sHeader =EnoviaResourceBundle.getFrameworkStringResourceProperty(context, Header , request.getLocale());
        if(sHeader.indexOf("$")>=0) {
            sHeader=UIExpression.substituteValues(context, sHeader, sBusId);
        }
%>
    <link rel="stylesheet" href="../emxUIPF.css" type="text/css" />
    <table border="0" cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
        </tr>
    </table>

    <table border="0" width="100%" cellspacing="2" cellpadding="4">
        <tr>
        <td class="pageHeader" width="99%"><xss:encodeForHTML><%=sHeader%></xss:encodeForHTML></td>
        <td width="1%">&nbsp;</td>
        </tr>
    </table>

    <table border="0" cellspacing="0" cellpadding="0" width="100%">
        <tr>
        <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
        </tr>
        <tr>
        <td>&nbsp;</td>
        </tr>
    </table>
<%
    }


try {
    //To store the Filter parameter/ Business Id
    String languageStr      = request.getHeader("Accept-Language");

    //By default set the filter to "*"
    if (sFilter == null || sFilter.trim().equals("")) {
        sFilter = "*";
    }else{
        sFilter = (sFilter.indexOf("*")!=0)?("*"+sFilter):sFilter;
        sFilter = (sFilter.endsWith("*"))?sFilter:(sFilter+"*");
    }

    //By default set History filter to "CurrentRevision"
    if (HistoryMode == null || HistoryMode.trim().equals("")) {
        HistoryMode = "CurrentRevision";
    }

    //By default set the action filter to "*"
    if (aFilter == null || aFilter.trim().equals("")) {
        aFilter = "*";
    }

    Vector ActionFilterValues=new Vector();
    boolean showAllHistoryItems=false;

     //if action filter is equal to "*" then show everything
     //else put all of the action filter choices in a vector called ActionFilterValues
     //to be used later to determine whether to display the history entry or not

    if(aFilter.equals("*")) {
        showAllHistoryItems=true;
    }
    else {
        if(aFilter.indexOf(",")<0) {
            ActionFilterValues.addElement(aFilter);
        }else {
            StringTokenizer actFilter = new StringTokenizer(aFilter, sComma);
            while(actFilter.hasMoreTokens()) {
               ActionFilterValues.addElement(actFilter.nextToken().trim());
             }
          }
    }

    boolean showLatestRev=false;
    String displayDirection="";
    String displayList="";
    String displayon="";
    Vector displayVector=new Vector();


     //CHECK TO SEE IF A TOLIST AND FROM LIST VALUES HAVE BEEN PASSED IN
     //IF NOT, THEN WE NEED TO DISPLAY THE LATEST REVISION
     //IF FROMLIST AND TOLIST WAS PASSED IN, THEN GET THE DISPLAY RANGE
    if(HistoryMode.equalsIgnoreCase("AllRevisions"))  //SECTION M
    {
       if(fromlist==null || tolist==null || fromlist.equals("") || tolist.equals("")) {
            showLatestRev=true;
       }else {
            int posFrom=revisionlist.indexOf("$"+fromlist+"$");
            int posTo=revisionlist.indexOf("$"+tolist+"$");

            if(posFrom==posTo){
                displayDirection="none";
            }else if(posFrom > posTo) {
                displayDirection="ascending";
                displayList=revisionlist.substring(posTo,posFrom+fromlist.length()+2);
            }else if(posFrom < posTo) {
                displayDirection="descending";
                displayList=revisionlist.substring(posFrom,posTo+tolist.length()+2);
            }
       }

       //IF THE DISPLAY RANGE IS NOT EMPTY, THEN THE SELECTION WAS A RANGE GREATER THAN ONE REVISION
       //MORE THAN ONE REVISION IS BEING REQUESTED, PUT THEM IN A VECTOR
        if(!displayList.equals("")) {
            displayList=displayList.substring(1,displayList.length()-1);
            StringTokenizer displayTokenizer = new StringTokenizer(displayList, "$");
            while(displayTokenizer.hasMoreTokens()) {
                displayVector.addElement(displayTokenizer.nextToken().trim());
            }

            //IF THE DISPLAY RANGE IS EMPTY, THEN EITHER WE NEED TO DISPLAY THE LATEST REVISION OR
            //A SINGLE REVISION THAT IS NOT THE LATEST REV--(COULD BE THE LATEST REV IF THE LATEST REV WAS
            //SELECTED ONLY)

        }else {
            if(showLatestRev) {
                //get the latest revision
                BusinessObject pObj = new BusinessObject(sBusId);
                BusinessObjectList blist=new BusinessObjectList();

                pObj.open(context);
                blist=pObj.getRevisions(context);
                lastestRevObject=blist.getElement(blist.size()-1);
                displayVector.addElement(lastestRevObject.getRevision());
                pObj.close(context);
            }else {
                displayVector.addElement(fromlist);
            }
        }

    } //END of Section M


    boGeneric.setId(sBusId);
    boGeneric.open(context);
    String sPolicy = boGeneric.getPolicy(context).getName();


    boolean bMatch  = false;
    BusinessObject itemObj = null;
    String sBusRev2="";
    BusinessObjectList bObjList2=new BusinessObjectList();
    BusinessObject passedObj = new BusinessObject(sBusId);
    passedObj.open(context);

    if(HistoryMode.equalsIgnoreCase("AllRevisions"))  //Section H
    {
        bObjList2 = passedObj.getRevisions(context);
        if(displayDirection.equalsIgnoreCase("ascending")) {
            for (int asc=0;asc<bObjList2.size();asc++) {
                itemObj=bObjList2.getElement(asc);
                sBusRev2=itemObj.getRevision();
                if(displayVector.contains(sBusRev2))
                bObjList.addElement(itemObj);
            }
        }else if(displayDirection.equalsIgnoreCase("descending")){
            for (int desc=bObjList2.size()-1;desc>=0;desc--) {
                itemObj=bObjList2.getElement(desc);
                sBusRev2=itemObj.getRevision();

                if(displayVector.contains(sBusRev2)) {
                    bObjList.addElement(itemObj);
                }
            }
        }else {
            if(showLatestRev) {
                bObjList.addElement(lastestRevObject);
            }
            else {
                for (int none=0;none<bObjList2.size();none++) {
                    itemObj=bObjList2.getElement(none);
                    sBusRev2=itemObj.getRevision();

                    if(displayVector.contains(sBusRev2)){
                        bObjList.addElement(itemObj);
                        break;
                    }
                }
            }
        }
    }else {            //Else for Section H
        bObjList.addElement(passedObj);
    }

    passedObj.close(context);
    int vectSize = bObjList.size();
    BusinessObject lastObj = null;
    int revCount=0;
    int revCount1=1;
    boolean StopDisplay=false;
    String theAction="";
    int position;
    boolean isSpecialAccess;
    String sSpecialAction="";
    boolean customaction=false;
    boolean bCanDisplay = true;
    for( int i=0; i < vectSize; i++) {  //SECTION R
        lastObj = bObjList.getElement(i);
        String sBusRev = lastObj.getRevision();
        HashMap hmaplist = new HashMap();

        if (historySelects !=null && historySelects.length() >0)
        {
            // If Relationship History records need to be included.
            hmaplist=UINavigatorUtil.getHistoryData(context,lastObj.getObjectId(),historySelects);
        }
        else
        {
            // If Relationship History records need not to be included.
            hmaplist=UINavigatorUtil.getHistoryData(context,lastObj.getObjectId());
            String sMaxRecords = (String)hmaplist.get("MaxRecords");
            if(!"NoMessage".equals(sMaxRecords) && bCanDisplay ) {
                String sTooLargeMsg1 = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.LogTooLarge1" , request.getLocale());
                String sTooLargeMsg2 =EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.LogTooLarge2" , request.getLocale());

                emxNavErrorObject.addMessage(sTooLargeMsg1 + " " + sMaxRecords + " " + sTooLargeMsg2);
                bCanDisplay = false;
            }
        }

        Vector timeArray = (Vector)hmaplist.get("time");
        Vector userArray = (Vector)hmaplist.get("user");
        Vector actionArray = (Vector)hmaplist.get("action");
        Vector stateArray = (Vector)hmaplist.get("state");
        Vector descriptionArray = (Vector)hmaplist.get("description");
        MapList templateMapList =  new MapList();

        if (timeArray == null || timeArray.size() == 0) {
            String noHistoryMsg = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.History.NoHistoryData" , request.getLocale());
            throw new MatrixException(noHistoryMsg);
        }
		
		//Start - WP7 Task [PLMV6_[Ebom]_kept user name instead of ID ENOVIA QC4911]		
		DomainObject doObj = DomainObject.newInstance(context, lastObj.getObjectId());		
		boolean bAT_C_ECPartFound = false;
		boolean bAT_C_DOCUMENTFound = false;
		String sModifiedAttrName = "";
		
		if(doObj.isKindOf(context, "AT_C_EC_Part")){
			bAT_C_ECPartFound = true;	
			sModifiedAttrName = "AT_C_LastPromoteUser";		
		}
		else if(doObj.isKindOf(context, "AT_C_DOCUMENT")){
			bAT_C_DOCUMENTFound = true;
			sModifiedAttrName = "AT_C_DocumentLastPromoteUser";	
		}
		//End - WP7 Task [PLMV6_[Ebom]_kept user name instead of ID ENOVIA QC4911]

        String currStateTranslated = "";
        for( int j=0; j < timeArray.size(); j++) {  //SECTION P
            sUser    = (String)userArray.get(j);
            sTime    = (String)timeArray.get(j);
            sAction    = (String)actionArray.get(j);
            sDescription    = (String)descriptionArray.get(j);
            sState   = (String)stateArray.get(j);
			
			//Start: WP7 Task [PLMV6_[Ebom]_kept user name instead of ID ENOVIA QC4911]
			if(bAT_C_ECPartFound || bAT_C_DOCUMENTFound){
				if(sDescription.contains(sModifiedAttrName)){
					int iModifiedAttrLength = sModifiedAttrName.length()+1;
					String sCurrentAT_C_LastPromoteUser = sDescription.substring(sDescription.indexOf(sModifiedAttrName+":")+iModifiedAttrLength,sDescription.indexOf("was:")).trim();
					String sPastAT_C_LastPromoteUser = sDescription.substring(sDescription.indexOf("was:")+4,sDescription.length()).trim();
					
					//get the person full name and update the description
					if(UIUtil.isNotNullAndNotEmpty(sCurrentAT_C_LastPromoteUser)){
						String sPromoterFullName = PersonUtil.getFullName(context, sCurrentAT_C_LastPromoteUser);
						sDescription = sDescription.replace(sCurrentAT_C_LastPromoteUser,sPromoterFullName);
					}
					
					if(UIUtil.isNotNullAndNotEmpty(sPastAT_C_LastPromoteUser)){
						String sPromoterFullName = PersonUtil.getFullName(context, sPastAT_C_LastPromoteUser);
						sDescription = sDescription.replace(sPastAT_C_LastPromoteUser,sPromoterFullName);
					}
				}
			}
			//END: WP7 Task [PLMV6_[Ebom]_kept user name instead of ID ENOVIA QC4911]
			
			
            if(sState != null && !"null".equals(sState) && sState.length() > 0) {
                sState = sState.substring(sState.indexOf("state: ")+ 7,sState.length());
                sState=sState.trim();
            }

            if(sTime != null && !"null".equals(sTime) && sTime.length() > 0) {
                sTime = sTime.substring(sTime.indexOf("time: ")+ 6,sTime.length());
                sTime=sTime.trim();
            }

            if(sUser != null && !"null".equals(sUser) && sUser.length() > 0){
                sUser = sUser.substring(sUser.indexOf("user: ")+ 6,sUser.length());
                sUser=sUser.trim();
            }

            isSpecialAccess=false;
            String sSpace=" ";

            
                if(sAction!=null && !sAction.equalsIgnoreCase("null") && !sAction.equals("")) {
                   if(sAction.indexOf("(")==0) {
                        customaction=true;
                    }else {
                        StringTokenizer SpecialActionList = new StringTokenizer(SpecialCaseAccesses, ",");
                        while(SpecialActionList.hasMoreTokens()) {
                            sSpecialAction=SpecialActionList.nextToken();
                            if(sAction.indexOf(sSpecialAction) != -1)//if sAction contains SpecialCaseAccesses
                            {
                                position=sAction.indexOf(sSpecialAction);
                                theAction=sAction.substring(0,position+sSpecialAction.length());
                                isSpecialAccess=true;
                                sAction=theAction;
                            }
                        }

                        if(!isSpecialAccess) {
                            StringTokenizer completeAction = new StringTokenizer(sAction, sSpace);
                            if(completeAction.hasMoreTokens()) {
                                sAction=completeAction.nextToken();
                            }
                        }
                    }
                }


            //if this action has not been recorded , then add the action type

            if(!TMap.containsKey(sAction)) {
                TMap.put(sAction,sAction);
            }

            HashMap historyHashMap   = new HashMap();

            if(ActionFilterValues.contains(sAction) || showAllHistoryItems ) {
                bMatch = true;
                historyHashMap.put("sAction", sAction);
                 try {
                	sUser=PersonUtil.getFullName(context, sUser);
                 } catch (Exception e) {
                         sUser = new StringBuffer(sUser).toString();
                 }
                historyHashMap.put("sUser", sUser);
                historyHashMap.put("sTime", sTime);
                historyHashMap.put("sDescription", UINavigatorUtil.getHistoryDescriptionDisplayString(context, sDescription, languageStr));//desc
                String translatedState="";

                if(sState!=null && sState.length()>0) {
                    translatedState=i18nNow.getStateI18NString(sPolicy,sState.trim(),languageStr);
                    currStateTranslated = translatedState;
                }

                // always put currentState and currStateTranslated in map. currState and currStateTranslated is always the latest and last state in history.
                //sState = currState;
                translatedState = currStateTranslated;
                historyHashMap.put("sState", sState);
                historyHashMap.put("translatedState", translatedState);

                String timeZone=(String)session.getAttribute("timeZone");
                double iClientTimeOffset = (new Double(timeZone)).doubleValue();
                int iDateFormat = PersonUtil.getPreferenceDateFormatValue(context);
                boolean bDisplayTime = true; //PersonUtil.getPreferenceDisplayTimeValue(context);
                String formatedDate = eMatrixDateFormat.getFormattedDisplayDateTime(sTime, bDisplayTime, iDateFormat, iClientTimeOffset, request.getLocale());

                StringBuffer finalHistory = new StringBuffer(50);
                finalHistory.append(sUser);
                finalHistory.append(sDescription);
                finalHistory.append(sState);
                finalHistory.append(translatedState);
                finalHistory.append(formatedDate);

                String finalHistoryStr = "";
                if(finalHistory.toString() != null && finalHistory.toString().indexOf(",")>-1) {
                       finalHistoryStr = finalHistory.toString().replace(',','|');
                       sFilter = sFilter.replace(',','|');
                }else {
                	finalHistoryStr = finalHistory.toString();
                }

                Pattern patternGeneric = new Pattern(sFilter);
                if(patternGeneric.match(finalHistoryStr)) {
                    templateMapList.add(historyHashMap);
                }
             }

            if (!isPrinterFriendly && revCount==0 && (!StopDisplay)) {
%>
                <form name="objectHistory" method="get" action="emxHistorySummary.jsp">
                <table class='list'>
<%
                StopDisplay=true;
            }else if((isPrinterFriendly && revCount==0 && (!StopDisplay))){
                 StopDisplay=true;
%>
                 <table>
<%
            }
        }//CLOSE OF SECTION P
%>
<%
    if(HistoryMode !=null && HistoryMode.equalsIgnoreCase("AllRevisions")){
%>
   <tr><td colspan="6" bgcolor="#ffffff">
        <table border="0" cellspacing="0" cellpadding="0" width="100%">
          <tr>
               <td>&nbsp;</td>
          </tr>
          <tr>
               <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
          </tr>
        </table>
   </td></tr>
    <tr><td colspan="6" bgcolor="#ffffff"><b>
         <xss:encodeForHTML><%=sSubHeader%></xss:encodeForHTML>&nbsp;<%=sBusRev%></b></font>
    </td></tr>

<%
    }
	for (Iterator iter = templateMapList.iterator(); iter.hasNext();) {
    	Map historyMap = (Map) iter.next();
	    sAction  = (String)historyMap.get("sAction");
	    sAction = sAction.replace('(',' ');
	    sAction = sAction.replace(')',' ');
    	sState   = (String)historyMap.get("sState");
	    if(customaction){
    		sActionI18N = sAction;
	    }else{
        	sActionProp = "emxFramework.History." + sAction.replace(' ','_');
        	sActionI18N = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, sActionProp , request.getLocale());
    	}
	    historyMap.put("sActionI18N", sActionI18N);
    	historyMap.put("sStateI18N", i18nNow.getStateI18NString(sPolicy, sState.trim(),languageStr));
	}
%>
<!-- //XSSOK -->
  <framework:sortInit  defaultSortKey="sTime"  defaultSortType="date"  mapList="<%=templateMapList%>"  resourceBundle="emxFrameworkStringResource"  ascendText="emxFramework.Common.SortAscending"  descendText="emxFramework.Common.SortDescending"  params = "<%=sParams.toString()%>" />
   <tr>
     <th nowrap>
       <framework:sortColumnHeader
         title= "emxFramework.History.Date"
         sortKey="sTime"
         sortType="date"
         anchorClass="sortMenuItem"
         pinfo="<%=isPrinterFriendly %>"/><!-- XSSOK -->
     </th>
     <th nowrap>
       <framework:sortColumnHeader
         title="emxFramework.History.User"
         sortKey="sUser"
         sortType="string"
         anchorClass="sortMenuItem"
         pinfo="<%=isPrinterFriendly %>"/><!-- XSSOK -->
     </th>
     <th nowrap>
       <framework:sortColumnHeader
         title="emxFramework.History.Action"
         sortKey="sActionI18N"
         sortType="string"
         anchorClass="sortMenuItem"
         pinfo="<%=isPrinterFriendly %>"/><!-- XSSOK -->
     </th>
     <th nowrap>
       <framework:sortColumnHeader
         title="emxFramework.History.State"
         sortKey="sStateI18N"
         sortType="string"
         anchorClass="sortMenuItem"
         pinfo="<%=isPrinterFriendly %>"/><!-- XSSOK -->
     </th>
     <th nowrap>
       <framework:sortColumnHeader
         title="emxFramework.Common.Description"
         sortKey="sDescription"
         sortType="string"
         anchorClass="sortMenuItem"
         pinfo="<%=isPrinterFriendly %>"/><!-- XSSOK -->
     </th>
  </tr>

  <framework:mapListItr mapList="<%=templateMapList%>" mapName="tempMap">

<%
         sAction  = (String)tempMap.get("sAction");
		 sActionI18N = (String)tempMap.get("sActionI18N");
         sUser    = (String)tempMap.get("sUser");
         sTime    = (String)tempMap.get("sTime");
         sDescription  = (String)tempMap.get("sDescription");
         sDescription= sDescription.replaceAll("<","&lt;").replaceAll(">","&gt;");
         sStateI18N   = (String)tempMap.get("sStateI18N");
%>
    <tr class='<framework:swap id ="1" />'>

      <!-- //XSSOK -->
      <td nowrap><emxUtil:lzDate displaydate="true" displaytime="true" localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, (String)session.getAttribute("timeZone"))%>' format='<%=DateFrm %>' ><%=sTime%></emxUtil:lzDate>&nbsp;
      </td>
      <!-- //XSSOK -->
      <td><%=sUser%>&nbsp;</td>
      <!-- //XSSOK -->
      <td><%=sActionI18N%>&nbsp;</td>
      <!-- //XSSOK -->
      <td><%=sStateI18N%>&nbsp;</td>
      <!-- //XSSOK -->
      <td><%=sDescription%>&nbsp;</td>
    </tr>
  </framework:mapListItr>
<%  revCount++;
revCount1++;
 if (!bMatch) {
%>
    <tr class="even">
      <td colspan="6" align="center" class="errorMessage">
        <emxUtil:i18n localize="i18nId">emxFramework.Common.NoMatchFound</emxUtil:i18n>
      </td>
    </tr>
<%


  }
     bMatch=false;

      }//CLOSE SECTION R
} catch (MatrixException e) {
%>
  <table border="0" cellspacing="0" cellpadding="0" width="100%">
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td class="errorMessage"><%=e.getMessage()%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
    emxNavErrorObject.addMessage("emxHistorySummary : " + e.toString().trim());
}catch(Exception e) {
    emxNavErrorObject.addMessage("emxHistorySummary :" + e.toString());
}

  java.util.Set exportSet = TMap.keySet();
  Iterator exportIterator = exportSet.iterator();
  String skey = "";
  while(exportIterator.hasNext()) {
    skey = (String)exportIterator.next();
    hiddenActions+= skey + "|";
  }
%>
</table>
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=sBusId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="hiddenActionFilter" value=""/>
<input type="hidden" name="preFilter" value=""/>
<input type="hidden" name="txtFilter" value=""/>
<input type="hidden" name="hiddenActions" value="<%= XSSUtil.encodeForHTMLAttribute(context,hiddenActions)%>"/>
<input type="hidden" name="HistoryMode" value="<xss:encodeForHTMLAttribute><%=HistoryMode%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="Header" value="<xss:encodeForHTMLAttribute><%=Header%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="subHeader" value="<xss:encodeForHTMLAttribute><%=subHeaderOriginal%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="fromlist" value=""/>
<input type="hidden" name="tolist" value=""/>
<input type="hidden" name="revisionlist" value=""/>
<input type="hidden" name="historySelects" value="<xss:encodeForHTMLAttribute><%=historySelects%></xss:encodeForHTMLAttribute>"/>
</form>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

<%if(UINavigatorUtil.isMobile(context)) { %>
    	</div>
<%} %>
</body>
</html>

