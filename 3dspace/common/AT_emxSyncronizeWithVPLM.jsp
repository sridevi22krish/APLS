<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page
	import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@page
	import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationReporter"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.*"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="matrix.util.StringList"%>
<%@page
	import="com.dassault_systemes.vplmintegration.sdk.enovia.VPLMBusObject"%>

<html>

<head>
<title></title>

<%@page import="com.matrixone.vplmintegration.util.*"%>
<!-- SM7 - IR-96983- Feb 24, 2011 - The link to hide/show the "corresponding modifications in VPM" is NLS enabled now -->
<%
    String targetLocation = emxGetParameter(request,"targetLocation");
	String hidecModinVPM = UINavigatorUtil.getI18nString(
			"emxVPLMSynchro.Msg.Success.HideModinVPM",
			"emxVPLMSynchroStringResource",
			request.getHeader("Accept-Language"));
	String showModinVPM = UINavigatorUtil.getI18nString(
			"emxVPLMSynchro.Msg.Success.ShowModinVPM",
			"emxVPLMSynchroStringResource",
			request.getHeader("Accept-Language"));
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script language="javaScript" src="../common/scripts/emxUITableUtil.js"></script>

<script language="javascript">
		    addStyleSheet("emxUIDefault","../common/styles/");
		    addStyleSheet("emxUIToolbar","../common/styles/");
		    addStyleSheet("emxUIList","../common/styles/");
		    addStyleSheet("emxUIProperties","../common/styles/");
    addStyleSheet("emxUITemp","../");
		    addStyleSheet("emxUIForm","../common/styles/");
    </script>

<script language="javascript">
			function showVPMDetails(){
				var hidecModinVPMJS = "<%=hidecModinVPM%>";
				var showModinVPMJS = "<%=showModinVPM%>";
				var VPMDetails = document.getElementById('VPMDetails');
				var VPMDetailsLink = document.getElementById("VPMDetailsLink");
				if(VPMDetails.style.display=="none"){
					VPMDetails.style.display="block";
					<!-- SM7 - IR-96983- Feb 24,2011 - Providing the translated string to display -->
					//VPMDetailsLink.firstChild.data="Hide corresponding modifications in VPM";
					VPMDetailsLink.firstChild.data=hidecModinVPMJS;
				}else if(VPMDetails.style.display=="block"){
					VPMDetails.style.display="none";
					<!-- SM7 - IR-96983- Feb 24,2011 - Providing the translated string to display -->
					//VPMDetailsLink.firstChild.data="See corresponding modifications in VPM";
					VPMDetailsLink.firstChild.data=showModinVPMJS;
			}
        }
		
			function doCancel(targetLocation){
				if(targetLocation=="popup"){
					top.close();
				}else if(targetLocation=="slidein"){
					top.closeSlideInDialog();
		}
		}
		<!-- SM7 - IR-96983- Feb 24, 2011 - Javascript method added to close when done button is clicked -->
		function doneAction()
        {
            if('<%=targetLocation%>' == 'slidein')
           	{
				var frame = findFrame(getTopWindow(), "detailsDisplay");
			if (frame != null) {	
					frame.location.href = frame.location.href; 
					getTopWindow().closeSlideInDialog();
				}
				
           	}else{
				//Close the popup window
				parent.window.close();
				//Refresh the table view
				parent.window.opener.top.refreshTablePage();
          }
       }
		function doUnload()
		{
		 if (window.event.clientX < 0 && window.event.clientY < 0)
		 {
		   alert("Window is closed.");
		 }
		}
	    </script>


</head>

<%
	String header = "Publish Precise BOM";

	String browser = request.getHeader("USER-AGENT");
	boolean isIE = browser.indexOf("MSIE") > 0;
%>
<!-- SM7 - IR-96983- extra header showing "Publish Precise BOM" is disabled -->

<body class="slide-in-panel" onload="turnOffProgress();">
	<!--
		<div id="pageHeadDiv">
			<form name="formHeaderForm">
				<table>
					<tr>
						<td class="page-title">
							<h2><%=header%></h2>
						</td>
						<td class="functions">
							<table>
								<tr>
									<td class="progress-indicator"><div id="imgProgressDiv"></div></td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
				<div class="toolbar-container" id="divToolbarContainer">
					<div id="divToolbar" class="toolbar-frame"></div>
				</div>
			</form>     		
		</div>
    
		<div id="divPageBody" <%if (isIE) {%> style="top:85px;" <%}%>>
		-->
	<%
		try {

			String objectProcessed = UINavigatorUtil.getI18nString(
					"emxVPLMSynchro.Notify.Success.ObjProcessed",
					"emxVPLMSynchroStringResource",
					request.getHeader("Accept-Language"));
			String objectCreated = UINavigatorUtil.getI18nString(
					"emxVPLMSynchro.Notify.Success.ObjCreated",
					"emxVPLMSynchroStringResource",
					request.getHeader("Accept-Language"));
			String objectUpdated = UINavigatorUtil.getI18nString(
					"emxVPLMSynchro.Notify.Success.ObjUpdated",
					"emxVPLMSynchroStringResource",
					request.getHeader("Accept-Language"));
			String objectDeleted = UINavigatorUtil.getI18nString(
					"emxVPLMSynchro.Notify.Success.ObjDeleted",
					"emxVPLMSynchroStringResource",
					request.getHeader("Accept-Language"));

			String msgString = null;
			String languageStr = request.getHeader("Accept-Language");
			// Get the object ID
			String objID = emxGetParameter(request, "objectId");

			//Create the arguments
			Hashtable argTable = new Hashtable();
			argTable.put("ROOTID", objID);

			//Pass all the arguments in the URL
			Map params = request.getParameterMap();
			java.util.Set keys = params.keySet();
			Iterator it = keys.iterator();
			while (it.hasNext()) {
				String key = (String) it.next();
				String value[] = (String[]) params.get(key);
				if (value != null && value[0].toString().length() > 0) {
					argTable.put(key, value[0].toString());
				}
			}

			String[] args = JPO.packArgs(argTable);

			if (Boolean.valueOf(com.matrixone.jsystem.util.Sys.getEnvEx("PUEECOSync"))) {

				//SBM1: IR-367074-V6R2013x:  Block the synchronization and add a warning message if a context item is missing 
				// This code is added here instead of java code, to block only manual synchronization
				VPLMBusObject chgObj = new VPLMBusObject(context, (String) argTable.get("ROOTID"));
				if (chgObj.matchWithTypes(PropertyUtil.getSchemaProperty("type_PUEECO"))) {
					MapList contextItemList = chgObj.getHandlerForADK().getRelatedObjects(
									context,
									PropertyUtil.getSchemaProperty(context,"relationship_ContextItem"),// relationship pattern
									DomainConstants.TYPE_PART, // object pattern
									new StringList(DomainConstants.SELECT_ID), // object selects
									new StringList(DomainConstants.SELECT_RELATIONSHIP_ID), // relationship selects
									false, // to direction
									true, // from direction
									(short) 1, // recursion level
									null, // object where clause
									null, // relationship where clause
									null, null, null);

					if (contextItemList == null	|| contextItemList.isEmpty()) {
						String st_msg = UINavigatorUtil.getI18nString("emxVPLMSynchro.Warning.ContextItemMissing","emxVPLMSynchroStringResource", request.getHeader("Accept-Language"));
						throw new Exception(st_msg);
					}
				}
			}

//Modified for REQ13.xxx Deformables Synchro Encapsulation 1601 - START
		  
			Map matrixObjIDvplmObjIDMap  = (Map) JPO.invoke(context,"AT_emxDeformable", null, "launchEncapsulatedSynchro", args,	Map.class);

//Modified for REQ13.xxx Deformables Synchro Encapsulation 1601 - END

			if (matrixObjIDvplmObjIDMap != null
					&& matrixObjIDvplmObjIDMap.size() > 0) {
				String operationStatus = (String) matrixObjIDvplmObjIDMap
						.get(VPLMIntegrationConstants.MAPKEY_OPERATION_STATUS);
				if (operationStatus.equals("false")) {
					Object error = matrixObjIDvplmObjIDMap
							.get(VPLMIntegrationConstants.MAPKEY_ERROR_MESSAGE);
					Exception exc = null;

					if (error instanceof Exception) {
						exc = (Exception) error;
					} else if (error instanceof String) {
						exc = new Exception((String) error);
					} else {
						exc = new Exception(
								"unknown error type (neither exception nor message available)");
					}

					throw exc;
				}
				//Reached here means operation status is true, so remove this element from the table
				matrixObjIDvplmObjIDMap
						.remove(VPLMIntegrationConstants.MAPKEY_OPERATION_STATUS);

				List msgVector = null;
				int msgVectorSize = 0;
				if (matrixObjIDvplmObjIDMap
						.containsKey(VPLMIntegrationConstants.MAPKEY_REPORT_MESSAGE)) {
					msgVector = (List) matrixObjIDvplmObjIDMap
							.get(VPLMIntegrationConstants.MAPKEY_REPORT_MESSAGE);
					msgVectorSize = msgVector.size();
				}
				//SM7- Apr 23, 2010 - IR-44507 - UI changed for the scenario where there a re no changes to synchronise.
				//SM7 - July 20, 2010 -IR-064240 - Code modified because the handling is done in the Engine now
				msgString = (String) matrixObjIDvplmObjIDMap
						.get("RESULT_MESSAGE");
	%>
	<table>
		<tr>
			<td class="heading1">
				<!-- SM7 - IR-96983- Feb 24, 2011 - The synchronisation report is NLS enabled now -->
				<p style="text-align: center; color: green; font-size: 10pt;"><%=UINavigatorUtil.getI18nString(msgString,
							"emxVPLMSynchroStringResource",
							request.getHeader("Accept-Language"))%></p>
			</td>
		</tr>

		<tr>
			<td class="inputField">
				<%
					//LUS - BOM_Sync_Reporting Enhancements : Start 12/2/2008
							VPLMIntegrationReporter syncReport = (VPLMIntegrationReporter) matrixObjIDvplmObjIDMap
									.get("REPORTER");
							String strCATIAReport = syncReport.getCatiaReport();
							StringTokenizer tokens = new StringTokenizer(
									strCATIAReport, "|");
							int tokenCount = tokens.countTokens();

							//SM&- Apr 23, 2010 - IR-44507 - UI changed for the scenario where there a re no changes to synchronise.
							//If there are no details to be displayed then we are not displaying anything but, the message "Object(s) already synchronized". 

							if (msgVectorSize > 0) {
								while (tokens.hasMoreTokens()) {
									if (tokenCount > 4 && tokenCount < 8) {
										tokens.nextToken();
									}
									if (tokenCount == 4) {
				%>
				<p><%=tokens.nextToken()%>
					<%=objectProcessed%></p> <%
 	} else if (tokenCount == 3) {
 %>
				<p><%=tokens.nextToken()%>&nbsp;<%=objectCreated%></p> <%
 	} else if (tokenCount == 2) {
 %>
				<p><%=tokens.nextToken()%>&nbsp;<%=objectUpdated%></p> <%
 	} else if (tokenCount == 1) {
 %>
				<p><%=tokens.nextToken()%>&nbsp;<%=objectDeleted%></p> <%
 	}
 					tokenCount--;
 				}
 			}
 %>
			</td>
		</tr>
	</table>

	<table>
		<tr>
			<td class="heading1" style="text-align: center;">
				<!-- SM7 - IR-96983-  The link to hide/show the "corresponding modifications in VPM" is NLS enabled now -->
				<a id="VPMDetailsLink" href="javascript:showVPMDetails()"> <%=showModinVPM%></p></a>
				<!--<a id="VPMDetailsLink"  href="javascript:showVPMDetails()"> See corresponding modifications in VPM</p></a>  -->
			</td>
		</tr>
		<tr>
			<td class="inputField" id="VPMDetails" style="display: none;">
				<%
					if (msgVector != null) {
								for (int i = 0; i < msgVector.size(); i++) {
									String msg = (String) msgVector.get(i);
				%>
				<p><%=msg%></p> <%
 	}
 			}
 %>
			</td>
		</tr>
	</table>
	<%
		}
		} catch (Exception exception) {
			String msgSyncFailed = UINavigatorUtil.getI18nString(
					"emxVPLMSynchroCfg.Info.PublicationFailed",
					"emxVPLMSynchroCfgStringResource",
					request.getHeader("Accept-Language"));
			String msgString = ("" + exception.getMessage()).replaceAll(
					"'", "");

			java.util.List list = new ArrayList();
			StringTokenizer tok = new StringTokenizer(msgString, "|");
			int counter = 0;
			while (tok.hasMoreElements()) {
				String line = (String) tok.nextElement();
				list.add(line.substring(line.lastIndexOf('|') + 1));
			}
	%>
	<table>
		<tr>
			<td class="heading1">
				<p style="text-align: center; color: red; font-size: 10pt;"><%=msgSyncFailed%></p>
			</td>
		</tr>
		<tr>
			<td class="inputField">
				<table>
					<tr>
						<th><%=UINavigatorUtil.getI18nString(
						"emxVPLMSynchro.Failed.Name",
						"emxVPLMSynchroStringResource",
						request.getHeader("Accept-Language"))%></th>
						<th><%=UINavigatorUtil.getI18nString(
						"emxVPLMSynchro.Failed.Message",
						"emxVPLMSynchroStringResource",
						request.getHeader("Accept-Language"))%></th>
					</tr>
					<%
						if (list.size() == 3) {
					%>
					<tr class="even">
						<td><a
							href="JavaScript:onLink('emxTree.jsp?objectId=<%=(String) list.get(0)%>')"><%=(String) list.get(1)%></a></td>
						<td class="field"><%=(String) list.get(2)%></td>
					</tr>
					<%
						} else {
					%>
					<tr class="even">
						<td class="field">&nbsp;</td>
						<td class="field"><%=msgString%></td>
					</tr>
					<%
						}
					%>
				</table>
			</td>
		</tr>
	</table>
	<%
		}
	%>
	</div>

	<div id="divPageFoot">
		<table>
			<tr>
				<td class="functions"></td>
				<td class="buttons">
					<table>
						<tr>
							<!-- SM7 - IR-96983-  The extra cancel button in the page is hidden-->
							<!--  <td><a n0ame="cancelButton" id="cancelButtonId" href="javascript:doCancel('<%=targetLocation%>')"><img src="images/buttonDialogCancel.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Common.Close</emxUtil:i18n>"></a></td> 
								<td><a name="cancelLabel" id="cancelLabelId" href="javascript:doCancel('<%=targetLocation%>')" class="button"><emxUtil:i18n localize="i18nId">emxFramework.Common.Close</emxUtil:i18n></a></td> -->
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>

</body>

</html>
