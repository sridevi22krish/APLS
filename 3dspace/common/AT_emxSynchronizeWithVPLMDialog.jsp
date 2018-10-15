<%@ page import="com.dassault_systemes.vplmintegration.VPLMIntegSynchronizerObject"%>
<%@ page import="com.dassault_systemes.vplmintegration.sdk.VPLMIntegException"%>
<%@ page import="com.dassault_systemes.vplmintegration.sdk.enovia.VPLMBusObject"%>
<%@ page import="com.matrixone.apps.domain.DomainConstants"%>
<%@ page import="com.matrixone.apps.framework.taglib.*"%>
<%@ page import="com.matrixone.apps.framework.ui.*"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMIntegSessionUtils"%>
<%@ page import="com.matrixone.vplmintegrationitf.itf.IVPLMChgOperations"%>
<%@ page import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@ page import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationReporter"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMIntegTraceUtil" %>
<%@ page import="matrix.db.*"%>
<%@ page import="java.util.List"%>
<%@ include file="emxNavigatorInclude.inc"%>
<%@ include file="emxNavigatorTopErrorInclude.inc"%>
<%@ include file="../emxUICommonHeaderBeginInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxVPLMSynchroStringResource" locale='<%= request.getHeader("Accept-Language") %>' />
<%
	boolean isUserVPLMAdmin = false  ;
    String objectId = emxGetParameter(request, "objectId");
    String targetLocation = emxGetParameter(request, "targetLocation");
	//SBM1: 02/14/2017 IR-495077: retrieve objectId from emxTableRowId in case of RMB click
	String strRMBTableID = emxGetParameter(request, "emxTableRowId");
	if (strRMBTableID != null && !"null".equals(strRMBTableID) && !"".equals(strRMBTableID)) {
		StringList sList = FrameworkUtil.split(strRMBTableID, "|");    
		if (sList.size() == 3) {
			objectId = (String) sList.get(0);		    
		} else if (sList.size() == 4) {
			objectId = (String) sList.get(1);		    
		} else if (sList.size() == 2) {
			objectId = (String) sList.get(1);
		} else {
			objectId = strRMBTableID;
		}
	}
    boolean bIsBellEnv = Boolean.valueOf(com.matrixone.jsystem.util.Sys.getEnvEx("PUEECOSync"));
    boolean bWithPUECO = false;
    VPLMBusObject boToSync  = new VPLMBusObject(context,objectId);

		String objectType=boToSync.getBasicTypeName();
	    boolean isPartConfigured = VPLMIntegSynchronizerObject.isPartConfigured(context, boToSync);
    	String sprefDepth=null;
    	String prefName="preference_DepthSync_"+objectType;
    	String prefDepth=PropertyUtil.getAdminProperty(context, "person", context.getUser(), prefName);
   		String prefNameCustom="preference_DepthSyncCustom_"+objectType;
  		String prefDepthCustom=PropertyUtil.getAdminProperty(context, "person", context.getUser(), prefNameCustom);
  		if(prefDepthCustom==null)
  			prefDepthCustom="";
		// yes => we show the values
			String sAllowDepthChange = emxGetParameter(request,
					"enableDepthChange");
			boolean allowDepthChange = true;
		if (sAllowDepthChange != null && sAllowDepthChange.length() != 0) {
			allowDepthChange = Boolean.parseBoolean(sAllowDepthChange);
		}
	    // depth value can be changed by the user
		String enabledDepth="";
 		String languageStr = request.getHeader("Accept-Language");
		String sDefaultDepth = emxGetParameter(request, "DefaultDepth");
			if (sDefaultDepth == null || sDefaultDepth.length() == 0) {
			if(prefDepth!=null && !prefDepth.isEmpty()) {
				if(prefDepth.equals("-1"))
					sDefaultDepth = "2";
				else
					sDefaultDepth=prefDepth;
			} else {
				sDefaultDepth = "2";
			}
		} 
		int defaultDepth = Integer.parseInt(sDefaultDepth);
		//SM7 - Apr 04, 2012 - ECC-VPM synch Support HL - Start
		// if Released "conf part": no transfer 
		String currentState = boToSync.getStateCurrentValue();
		String enabledTransfer = "";
		if(!bIsBellEnv && isPartConfigured && currentState.equalsIgnoreCase(DomainConstants.STATE_PART_RELEASE) )
		{
			enabledTransfer = "disabled";
		}
		//SM7 - Apr 04, 2012 - ECC- VPM Highlight - End

		// Specify URL to come in middle of frameset
		String url = "";

		// add these parameters to each content URL, and any others the App needs

		//Pass all the arguments in the URL        
		Map params = request.getParameterMap();
		java.util.Set keys = params.keySet();
		Iterator it = keys.iterator();
		int count = 0;
		while (it.hasNext()) {
			String key = (String) it.next();
			String value[] = (String[]) params.get(key);
			if (value != null && value[0].toString().length() > 0
					&& ++count == 1) {
				url += key + "=" + value[0].toString();
			} else {
					url += "&" + key + "=" + value[0].toString();
			}
		}

		//VKY: Check if the transfer is enabled by the command.
		// transfer checkbox is enabled or not
		// if true => checked =>"give" or unchecked=>"no"
		// if false => "no"
	  	String sEnableTransfer = emxGetParameter(request, "enableTransfer");
	  	boolean bEnableTransfer=true;
	  	if (sEnableTransfer != null && sEnableTransfer.length() == 0)
			bEnableTransfer = Boolean.parseBoolean(sEnableTransfer);
		if (sEnableTransfer == null || sEnableTransfer.length() == 0 || bEnableTransfer) {
				//VKY: If transfer is enabled by the command, check if the user has the authority to transfer control.
				try {
					bEnableTransfer = VPLMIntegSessionUtils.isAuthorizedToTransferVPLMControl(context,bEnableTransfer);
				}
			  catch (VPLMIntegException me) {
			  	VPLMIntegTraceUtil.trace(context,"Error in transferring control:" + me);
				}
			}
			//S45 Bell step 2 begin: force depth and transfert values for Configured Part only
			String checkedTransfer="";
			if(bIsBellEnv && isPartConfigured) {
				// depth
				defaultDepth = 0;
				allowDepthChange=true;
				enabledDepth="disabled";
				// transfer of control
				bEnableTransfer=true;
				enabledTransfer = "disabled";
				checkedTransfer="checked";
			}
			//S45 Bell step 2 end	
			String myQ = request.getQueryString();

			//LUS - Begin 6/12/2008 for Bug: A0627779 
			StringBuffer returnFrameset = new StringBuffer("emxSynchronizeReportDialogFS.jsp?" + url);
			String sreturnFramesetEncoded = Framework.encodeURL(response,returnFrameset.toString());
			//LUS - End 6/12/2008 for Bug: A0627779
%>

<SCRIPT LANGUAGE="JavaScript" SRC="scripts/emxUIConstants.js"
	TYPE="text/javascript"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="scripts/emxUIModal.js"
	TYPE="text/javascript"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="scripts/emxUIPopups.js"
	TYPE="text/javascript"></SCRIPT>
<SCRIPT TYPE="text/javascript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIForm");
        </SCRIPT>

<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
        var syncDepth_Custom=<%=(prefDepthCustom=="" ? "''" : "'"+prefDepthCustom+"'")%>;
        function getTransfer()
        {
        	if(document.emxSyncDialog.SYNC_AND_TRANSFER.checked)
				return "<%=VPLMIntegrationConstants.TRANSFER_CONTROL%>";
        	else
				return "no";
            }
        
        function getSyncDepthCustom()
        {
			if(document.emxSyncDialog.syncDepth_Custom)
				return document.emxSyncDialog.syncDepth_Custom.value;
			else
			 return "-1";
        }
        
            function enableCustom()
            {
			if(!document.emxSyncDialog.syncDepth_Custom || !document.emxSyncDialog.syncDepth_Default)
				return;
        	//alert('enableCustom:'+document.emxSyncDialog.syncDepth_Default.value);
                if (document.emxSyncDialog.syncDepth_Default.value == "3")
                {
                        document.emxSyncDialog.syncDepth_Custom.disabled=false;
                   		document.emxSyncDialog.syncDepth_Custom.value=syncDepth_Custom;
                }
                else
                {
                        document.emxSyncDialog.syncDepth_Custom.disabled=true;
                   		syncDepth_Custom=document.emxSyncDialog.syncDepth_Custom.value;
                    	document.emxSyncDialog.syncDepth_Custom.value="";
                }
            }
                                            
            function isInteger()
            {
                var ValidChars = "0123456789";
                var isIntegerVal = true;
                var Char;
                var text = document.emxSyncDialog.syncDepth_Custom.value;

                for (i = 0; i < text.length && isIntegerVal; i++)
                    {
                        Char = text.charAt(i);
                        if (ValidChars.indexOf(Char) == -1)
                            {
                                isIntegerVal = false;
                            }
                    }
                return isIntegerVal;
            }        
                                
            function checkInput()
            {
				//Add the SYNC_DEPTH parameter to the URL
         	var syncDepth = "-1";
           	if (document.emxSyncDialog.syncDepth_Custom && document.emxSyncDialog.syncDepth_Default && document.emxSyncDialog.syncDepth_Default.value == "3")
                {
                    var isInt = isInteger();
                    if(isInt)
					{
						if(document.emxSyncDialog.syncDepth_Custom.value.length<1)
						{
							alert("<emxUtil:i18nScript localize="i18nId">emxVPLMSynchro.Synchronization.BadDepthValue</emxUtil:i18nScript>");
							return;
						}
						syncDepth = document.emxSyncDialog.syncDepth_Custom.value;
					}
                    else
					{
						alert("<emxUtil:i18nScript localize="i18nId">emxVPLMSynchro.Synchronization.BadDepthValue</emxUtil:i18nScript>");
						return;
					}
                }
            else if(document.emxSyncDialog.syncDepth_Custom && document.emxSyncDialog.syncDepth_Default)
                {
                    if (document.emxSyncDialog.syncDepth_Default.value == "0")
                    {
                            syncDepth="0"; //-1 = no synch by VPLMIntegGenericMatrixSynchronizer on anyone other than root
                    }
                    if (document.emxSyncDialog.syncDepth_Default.value == "1")
                    {
                            syncDepth = "1";  //2 = processing will be done for immediate child of root
                    }
                    if (document.emxSyncDialog.syncDepth_Default.value == "2")
                    {
                            syncDepth = "-1";  //0 = automatically synchs all levels
                    }
                }			
           	//LUS - Begin 6/25/2008 for Bug: A0627779 
			
			var href = "<%=sreturnFramesetEncoded %>&vplmContext=" + document.emxSyncDialog.vplmContext.value + "&SYNC_DEPTH=" + syncDepth+ "&SYNC_DEPTH_CUSTOM=" + getSyncDepthCustom();		
			if(<%=bEnableTransfer%>) 
			{				 
				href += "&SYNC_AND_TRANSFER=" + getTransfer();		
			}
			else
			{
				href += "&SYNC_AND_TRANSFER=no";
			}
           	if('<%=targetLocation%>' == 'slidein')
           	{
           		var slideInFrame = findFrame(getTopWindow(),"slideInFrame");
           		slideInFrame.location.href = href;
           	}
           	else{
			top.location.href=href;
			//LUS - End 6/25/2008 for Bug: A0627779 
            }
        }
         function cancelSlideIn()
         {
        	 getTopWindow().closeSlideInDialog();
         }
        </SCRIPT>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<emxUtil:localize id="i18nId" bundle="emxVPLMSynchroStringResource"
	locale='<%=request.getHeader("Accept-Language")%>' />
<FORM NAME="emxSyncDialog" ID="syncDialog" METHOD="post" ACTION="">
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="2" WIDTH="100%">
	<TR>
		<TD WIDTH="150" CLASS="labelRequired"><emxUtil:i18n
			localize="i18nId">emxVPLMSynchro.Preferences.VPLMContext</emxUtil:i18n>
		</TD>
		<%
		//CRK 2/25/10 IR-041724V6R2011: For current SMB product, user must select a context/role upon login through the web.
		//We should disable the role selection in the UI if the context already has a VPM role set.
		String roleFromContext = context.getRole();
		final String token_pre = "ctx::";
		if(roleFromContext.startsWith(token_pre))
		{
		//disable the selection
			%>
				<TD CLASS="inputField"><SELECT NAME="vplmContext" ID="vplmContext" DISABLED="true">
			<%
		} else {
		//enable the selection
			%>
			<TD CLASS="inputField"><SELECT NAME="vplmContext" ID="vplmContext">
			<%
		}
		
	    	try {
			// Get User Roles
			List userRoles = PersonUtil.getUserRoles(context);

			//Check if context already has a role set
			String userRole = null;
			//If not, then get the preferred context
			if(!roleFromContext.startsWith(token_pre)) {
				userRole = PropertyUtil.getAdminProperty(
					context,
					"person",
					context.getUser(),
					VPLMIntegrationConstants.PREFERENCE_VPLMINTEG_VPLMCONTEXT);
			} else {
			    userRole = roleFromContext.substring(token_pre.length());
			}

			// Check All Roles
			String lRole = "" ;
			for (int i = 0; i < userRoles.size(); i++) {
				lRole = (String) userRoles.get(i);
				if ( lRole.contains("VPLMAdmin") ) {
					isUserVPLMAdmin = true ;
					break ;
				}
			}
			if ( ! isUserVPLMAdmin ) {
				isUserVPLMAdmin = userRole.contains("VPLMAdmin") ;
			}
			
			// for each userRole choice
			for (int i = 0; i < userRoles.size(); i++) {
				// get choice
				String choice = (String) userRoles.get(i);

				//keep only those values which have a "ctx::VPLM"
				if (!choice.contains(token_pre)) {
					continue;
				}
				choice = choice.substring(token_pre.length());

				// if choice is equal to default then
				// mark it selected
				if (choice.equals(userRole)) {
			%>
			<OPTION VALUE="<%=choice%>" SELECTED><%=choice%></OPTION>
			<%
			    } else {
			%>
			<OPTION VALUE="<%=choice%>"><%=choice%></OPTION>
			<%
			    }
			}
		} catch (Exception ex) {
			if (ex.toString() != null
					&& (ex.toString().trim()).length() > 0) {
				emxNavErrorObject.addMessage("emxPrefConversions:"
						+ ex.toString().trim());
			}
		} finally {
		}
			%>
		</SELECT></TD>
	</TR>
	<%
	    if (allowDepthChange) {
	%>
	<TR>
		<TD CLASS="label"><emxUtil:i18n localize="i18nId">emxVPLMSynchro.Synchronization.ProcessDepth</emxUtil:i18n>
		</TD>
		<TD>
		<SELECT NAME="syncDepth_Default" ONCHANGE="enableCustom()" <%=enabledDepth%>>
			<%
			    if (defaultDepth == 0) {
			%>
			<OPTION SELECTED VALUE="0">
			<%
			    } else {
			%>
			<OPTION VALUE="0">
			<%
			    }
			%> <emxUtil:i18n localize="i18nId">emxVPLMSynchro.Notify.SynchDepth.Zero</emxUtil:i18n>:<emxUtil:i18n localize="i18nId">emxVPLMSynchro.Notify.SynchDepth.DoNotExpand</emxUtil:i18n></OPTION>
			<%
			    if (defaultDepth == 1) {
			%>
			<OPTION SELECTED VALUE="1">
			<%
			    } else {
			%>
			<OPTION VALUE="1">
			<%
			    }
			%> <emxUtil:i18n localize="i18nId">emxVPLMSynchro.Notify.SynchDepth.One</emxUtil:i18n>:<emxUtil:i18n localize="i18nId">emxVPLMSynchro.Notify.SynchDepth.Expand1Level</emxUtil:i18n></OPTION>
			<%
			    if (defaultDepth == 2) {
			%>
			<OPTION SELECTED VALUE="2">
			<%
			    } else {
			%>
			<!-- SM7 - June 30, 2011- IR-106689V6R2012x - In the synchronisation dialog page "All" is selected as default instead of zero -->
			<!--S45 take into account the default value without forcing here <OPTION  selected="selected" VALUE="2">-->
			<OPTION VALUE="2">
			<%
			    }
			%> <emxUtil:i18n localize="i18nId">emxVPLMSynchro.Notify.SynchDepth.All</emxUtil:i18n>:<emxUtil:i18n localize="i18nId">emxVPLMSynchro.Notify.SynchDepth.ExpandAllLevel</emxUtil:i18n></OPTION>
			<%
			    if (defaultDepth == 3) {
			%>
			<OPTION SELECTED VALUE="3">
			<%
			    } else {
			%>
			<OPTION VALUE="3">
			<%
			    }
			%> <emxUtil:i18n localize="i18nId">emxVPLMSynchro.Notify.SynchDepth.Specify</emxUtil:i18n></OPTION>
		</SELECT> <INPUT NAME="syncDepth_Custom" SIZE="6" MAXLENGTH="4" ></TD>
	</TR>
	<%
	    } else { //allowDepthChange
	%>
	<INPUT TYPE="hidden" NAME="syncDepth_Default" VALUE="<%=defaultDepth%>">
	<%
	    }
				if (bEnableTransfer && isUserVPLMAdmin) {
	%>
	<TR>
		<TD CLASS="label"><emxUtil:i18n localize="i18nId">emxVPLMSynchro.Synchronization.TransferAuthoringControl</emxUtil:i18n>
		</TD>
		<!-- SM7 - Apr 04, 2012 - ECC-VPM synch Support HL- Introduced the disabled tag to disable the TC in case of configured root part and release state  -->
		<TD CLASS="inputField"><INPUT TYPE="CHECKBOX"
					NAME="SYNC_AND_TRANSFER" <%=checkedTransfer%> <%=enabledTransfer%>></TD>
	</TR>
	<%
		} else {
	%>
	<TR> <INPUT TYPE="hidden"
					NAME="SYNC_AND_TRANSFER" <%=checkedTransfer%> <%=enabledTransfer%>></TR>
	<%
			
		} //bEnableTransfer
	%>
</TABLE>
</FORM>
<SCRIPT TYPE="text/javascript"> enableCustom();</SCRIPT>



<%@include file="emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>



