<%--emxEmgBOMGoToProductionUtil.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
  --%>

<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.dassault_systemes.enovia.bom.ReleasePhase"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<!--
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>

<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@page import="com.matrixone.apps.engineering.ReleasePhaseManager"%>
<%@page import="matrix.util.SelectList"%>

emxUIConstants.js is included to call the findFrame() method to get a frame-->

<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%@page import="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeConstants"%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>


<%
	String functionality    = emxGetParameter(request,"functionality");
	String objectId         = emxGetParameter(request, "objectId");
	String frameName         = emxGetParameter(request, "frameName");
	String tableName         = emxGetParameter(request, "table");
	if(frameName == null )
		frameName="";
	if(tableName == null )
		tableName="";
	 String strChildStateNotHigherThanParentErrorMsg   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.BOMChildStatesHigherThanParentPart");
	 String strBOMChildReleasePhaseDevErrorMsg   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.BOMChildReleasePhaseDevelopment");
	 String strReleaseChangeAssociatedWithPartErrorMsg   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.ReleaseCAAssociatedWithPart");
	 String strCAConnected   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.CAConnected");
	 String strNextRevisionAssociatedWithChildPartErrorMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.NextRevisionAssociatedWithChildPart");
	 String strPublishToVPMAlert = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Alert.PublishToVPM");
	 String strMarkupShouldBeApprovedORRejected = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Alert.MarkupIsInProposedState");
	 String reviseSequence = MqlUtil.mqlCommand(context,"print policy $1 select $2 dump",DomainConstants.POLICY_EC_PART,"property[ResetRevision].value");
	 String strPartIsInObsoleteState = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Alert.PartInObsoleteStateBlockBGTP");
	 String strEffectivitySet = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"emxEngineeringCentral.DragDrop.Alert.EmptyEffectivity");
	 String strCAConnectedNotWithForUpdate = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"emxEngineeringCentral.ENCBOMGoToProduction.Alert.CAConnectedNotWithForUpdate");
	 String strVPLMControlled = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"emxEngineeringCentral.ENCBOMGoToProduction.Alert.VPLMControlled");
	 String strInvalidTypesForSetToProduction   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ATEngineeringCentral.Alert.InvalidTypesForSetToProduction");
	 
	 
	  String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
	  
	  String sRMBObjectId = "";
	  String sRowId = "";
	  String results = "";
	  if (null != tableRowIdList) {
	  
		  boolean rootNodeFail = false;
	      String tableRowId = " "+tableRowIdList[0];
	      StringList slList = FrameworkUtil.split(tableRowId, "|");
	      
      	  sRMBObjectId    = ((String)slList.get(1)).trim();
          sRowId  = ((String)slList.get(3)).trim();
      	
	  }
	
	if("updatePart".equals(functionality))
	{
		try {
			ContextUtil.pushContext(context);	
			DomainObject domObj = DomainObject.newInstance(context,objectId);
			StringList affectedItems = new StringList();
			boolean isStateLTFrozen = false;
			boolean isStateEqual = false;
			
			SelectList sPartSelStmts = new SelectList(4);
	    	sPartSelStmts.addElement(DomainObject.SELECT_TYPE);
	    	sPartSelStmts.addElement(DomainObject.SELECT_POLICY);
	    	sPartSelStmts.addElement(DomainConstants.SELECT_CURRENT);
	    	sPartSelStmts.addElement("from["+EngineeringConstants.RELATIONSHIP_PART_SPECIFICATION+"].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");
	    	Map objMap = domObj.getInfo(context, (StringList)sPartSelStmts);
	    	
	    	//Modified for Redmine - 7780 - Set to Production should be disabled for CI, EP, LN - Start
	    	String strType = (String)objMap.get(DomainConstants.SELECT_TYPE);
	        if(UIUtil.isNotNullAndNotEmpty(strType) && (strType.equals(PropertyUtil.getSchemaProperty(context, "type_AT_C_CONFIGURATION_ITEM")) || strType.equals(PropertyUtil.getSchemaProperty(context, "type_AT_C_EXPECTED_PRODUCT")) || strType.equals(PropertyUtil.getSchemaProperty(context, "type_AT_C_LOGICAL_NODE"))) ){
	    		%>
		          <script language="JavaScript" type="text/javascript">
		    	      alert("<%=strInvalidTypesForSetToProduction%>");
		          </script>
		       <%	
		         return;
	    	}
	      //Modified for Redmine - 7780 - Set to Production should be disabled for CI, EP, LN - End
	    	
			if(DomainConstants.STATE_PART_OBSOLETE.equals((String)objMap.get(DomainConstants.SELECT_CURRENT)))
			  {
				%>
		          <script language="JavaScript" type="text/javascript">
		    	      alert("<%=strPartIsInObsoleteState%>");
		          </script>
		       <%	
		         return;
			  }
			
			String isVPLMControlled = (String)objMap.get("from["+EngineeringConstants.RELATIONSHIP_PART_SPECIFICATION+"].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");
			if("TRUE".equalsIgnoreCase(isVPLMControlled) && DomainConstants.STATE_PART_RELEASE.equals((String)objMap.get(DomainConstants.SELECT_CURRENT)))
			{
				%>
		          <script language="JavaScript" type="text/javascript">
		    	      alert("<%=strVPLMControlled%>");
		          </script>
		       <%	
		         return;
			 }
	    	
	    	
	    	String changeRequiredState = ReleasePhase.getChangeRequiredState(context,(String)objMap.get(DomainObject.SELECT_TYPE),EngineeringConstants.DEVELOPMENT);
			StringList states = new StringList();
			
			states = EngineeringUtil.getOCDXStateMappingForDisplayStatePart(context,changeRequiredState);
			
			if((String)states.get(0)!=null && (String)states.get(0)!="")
				 changeRequiredState = (String)states.get(0);	
			
			if(changeRequiredState != null && !"".equals(changeRequiredState))
				isStateLTFrozen = com.matrixone.apps.domain.util.PolicyUtil.checkState(context, objectId, changeRequiredState, com.matrixone.apps.domain.util.PolicyUtil.LT);
			
			if(EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)objMap.get(DomainObject.SELECT_POLICY)))
			{
				//State of the Conf part is preliminary
				isStateLTFrozen = true;
			}
			if(("ENCPartProperty".equals(frameName) || frameName.endsWith("PartProperty") || frameName.startsWith("ATPart") ) && !EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)objMap.get(DomainObject.SELECT_POLICY)))
			{
				String sChildPartId = "";
				affectedItems.add(objectId);
			  	StringList busSelects = new StringList(DomainObject.SELECT_POLICY);
			    busSelects = new StringList(DomainObject.SELECT_ID);
				String objWhere = "(attribute[" + EngineeringConstants.ATTRIBUTE_RELEASE_PHASE + "]=="+EngineeringConstants.DEVELOPMENT+")" ;

				MapList mapList = domObj.getRelatedObjects(context,
				DomainConstants.RELATIONSHIP_EBOM, DomainConstants.TYPE_PART, busSelects,
				null, false, true, (short) 0, objWhere, null, 0);
				
				//check for VPM product is attached to the parts
				String vplmVisible = domObj.getInfo(context, "attribute["+EngineeringConstants.ATTRIBUTE_VPM_VISIBLE+"].value");
				if("true".equalsIgnoreCase(vplmVisible))
				{
					boolean retVal = ReleasePhaseManager.isPartSynchronizedWithVPLM(context,objectId);
					if(!retVal)
			    	{
			    	%>
			    	<script language="JavaScript" type="text/javascript">
			    	alert("<%=strPublishToVPMAlert%>");
			    	</script>
			    	<%	
			    	return;
			       	}
				}
				 if(!mapList.isEmpty()){
						%>
					    <script language="JavaScript" type="text/javascript">
					    	alert("<%=strBOMChildReleasePhaseDevErrorMsg%>");
					    </script>
					    <%	
					    return;
					    }
				 isStateEqual = ReleasePhaseManager.checkIfBOMChildStatesHigherThanParent(context,objectId);
			    	if(!isStateEqual)
			    	{
			    	%>
			    	<script language="JavaScript" type="text/javascript">
			    		alert("<%=strChildStateNotHigherThanParentErrorMsg%>");
			    		</script>
			    	<%	
			    	return;
			       	}
			    	
			    boolean markUpRetVal = ReleasePhaseManager.checkIfPartHasProposedMarkups(context,objectId);
				 if(!markUpRetVal)
					 {
					  	%>
						   <script language="JavaScript" type="text/javascript">
							    alert("<%=strMarkupShouldBeApprovedORRejected%>");
						 </script>
						<%	
					   return;
						}
			}

			if(isStateLTFrozen && ("ENCPartProperty".equals(frameName) || frameName.endsWith("PartProperty") || frameName.startsWith("ATPart") ) ){
				MapList changeConnected = domObj.getRelatedObjects(context,
 						ChangeConstants.RELATIONSHIP_AFFECTED_ITEM, EngineeringConstants.TYPE_CHANGE, new StringList(DomainObject.SELECT_ID),
 						null, true, false, (short) 1, "Current != "+EngineeringConstants.STATE_ECO_RELEASE, null, 0);
 				if(changeConnected.size()>0 && !EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)objMap.get(DomainObject.SELECT_POLICY))){
 			    	%>
 					    <script language="JavaScript" type="text/javascript">
 					    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
 					    </script>
 					<%	
 					    return;
 				}
				if(EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)objMap.get(DomainObject.SELECT_POLICY)))
				{
					StringList busSelects = new StringList(DomainObject.SELECT_POLICY);
				    busSelects = new StringList(DomainObject.SELECT_ID);
					String objWhere = "(attribute[" + EngineeringConstants.ATTRIBUTE_RELEASE_PHASE + "]=="+EngineeringConstants.DEVELOPMENT+")" ;

					MapList mapList = domObj.getRelatedObjects(context,
					DomainConstants.RELATIONSHIP_EBOM, DomainConstants.TYPE_PART, busSelects,
					null, false, true, (short) 0, objWhere, null, 0);
					 if(!mapList.isEmpty()){
							%>
						    <script language="JavaScript" type="text/javascript">
						    	alert("<%=strBOMChildReleasePhaseDevErrorMsg%>");
						    </script>
						    <%	
						    return;
						    }
					 
				   boolean retVal = ReleasePhaseManager.isPartSynchronizedWithVPLM(context,objectId);
						if(!retVal)
				    	{
				    	%>
				    	<script language="JavaScript" type="text/javascript">
				    	alert("<%=strPublishToVPMAlert%>");
				    	</script>
				    	<%	
				    	return;
				       	}
				boolean isEffEmpty = ReleasePhaseManager.checkEffectivityExists(context,objectId);
						if(isEffEmpty)
				    	{
				    	%>
				    	<script language="JavaScript" type="text/javascript">
				    	alert("<%=strEffectivitySet%>");
				    	</script>
				    	<%	
				    	return;
				       	}
				}
 			  		affectedItems.add(objectId);
 			  		ReleasePhaseManager.setAttributesOnPartObj(context,affectedItems);
 			  		if(!EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)objMap.get(DomainObject.SELECT_POLICY)) && "True".equals(reviseSequence))
 			  			ReleasePhaseManager.resetRevision(context,affectedItems);
			%>
			<%
			if(EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)objMap.get(DomainObject.SELECT_POLICY)))
			{
			%>
			<script language="JavaScript" type="text/javascript">
					var targetXCEPropertiesFrame = emxUICore.findFrame(getTopWindow(),"ENCPartProperty");
					targetXCEPropertiesFrame.location.href = targetXCEPropertiesFrame.location.href;
 			</script>
			<%	
			}else {
				%>
				<script language="JavaScript" type="text/javascript">
				var targetFrame = findFrame(getTopWindow(), "content");
				//IR-562881 : Gray out of Back and forward button - Start
				<%--getTopWindow().location.href = "../common/emxNavigator.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>";--%>
				targetFrame.location.href = targetFrame.location.href;
				//IR-562881 - End

	 			</script>
				<%	
			}
			}
			else if(("PUEUEBOMIndentedSummary".equals(tableName)))
			{
				
			boolean retVal = ReleasePhaseManager.isPartSynchronizedWithVPLM(context,objectId);
				if(!retVal)
		    	{
		    	%>
		    	<script language="JavaScript" type="text/javascript">
		    	alert("<%=strPublishToVPMAlert%>");
		    	</script>
		    	<%	
		    	return;
		       	}
		  boolean isEffEmpty = ReleasePhaseManager.checkEffectivityExists(context,objectId);
				if(isEffEmpty)
		    	{
		    	%>
		    	<script language="JavaScript" type="text/javascript">
		    	alert("<%=strEffectivitySet%>");
		    	</script>
		    	<%	
		    	return;
		       	}
			StringList childList = ReleasePhaseManager.getChildStateStatus(context,objectId);					
				if(!childList.isEmpty()){
						ReleasePhaseManager.setAttributesOnPartObj(context,childList);
				}
 		 %>
 		 				<script language="JavaScript" type="text/javascript">
 		 				var targetXCEFrame = emxUICore.findFrame(getTopWindow(),"PUEUEBOM");
 		 				targetXCEFrame.location.href = targetXCEFrame.location.href;
 		 				</script>
 		 <%	
 		      return;
			}
			//Modified for HPQC #5397, Redmine #8661, properties tag frame name added for set To production operation
			else if("ENCEBOMIndentedSummarySB".equals(tableName) || "MGS_ENCEBOMIndentedSummarySB".equals(tableName) || frameName.endsWith("PartProperty") || frameName.startsWith("ATPart") ) {
					boolean retVal = ReleasePhaseManager.isPartSynchronizedWithVPLM(context,objectId);
					if(!retVal)
			    	{
			    	%>
			    	<script language="JavaScript" type="text/javascript">
			    	alert("<%=strPublishToVPMAlert%>");
			    	</script>
			    	<%	
			    	return;
			       	}
				
	    	isStateEqual = ReleasePhaseManager.checkIfBOMChildStatesHigherThanParent(context,objectId);
	    	if(!isStateEqual)
	    	{
	    	%>
	    	<script language="JavaScript" type="text/javascript">
	    		alert("<%=strChildStateNotHigherThanParentErrorMsg%>");
	    		</script>
	    	<%	
	    	return;
	       	}
	    	
	    	String message = ReleasePhaseManager.checkIfChildAssociatedWithChange(context,objectId,true);
		    if("ChangeExistsForChildParts".equalsIgnoreCase(message))
		    {
		    	%>
				    <script language="JavaScript" type="text/javascript">
				    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
				    </script>
				<%	
				    return;
			}
		    if("NextRevExists".equalsIgnoreCase(message))
		    {
		    	%>
				    <script language="JavaScript" type="text/javascript">
				    	alert("<%=strNextRevisionAssociatedWithChildPartErrorMsg%>");
				    </script>
				<%	
				    return;
			}
		    
		    boolean markUpRetVal = ReleasePhaseManager.checkIfPartHasProposedMarkups(context,objectId);
		    if(!markUpRetVal)
		    {
		    	%>
				    <script language="JavaScript" type="text/javascript">
				    	alert("<%=strMarkupShouldBeApprovedORRejected%>");
				    </script>
				<%	
				    return;
			}
		    
	    	if(isStateLTFrozen){
	    		   	StringList childList = ReleasePhaseManager.getChildStateStatus(context,objectId);					
 						if(!childList.isEmpty()){
 							ReleasePhaseManager.setAttributesOnPartObj(context,childList);
 							if(!EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)domObj.getInfo(context,DomainObject.SELECT_POLICY)) && "True".equals(reviseSequence))
 								ReleasePhaseManager.resetRevision(context,childList);
							//Start Modified for HPQC 5397, Redmine 8661
							if(frameName != null && (frameName.endsWith("PartProperty") || frameName.startsWith("ATPart") ))
							{
 							%>
 			 				<script language="JavaScript" type="text/javascript">
 			 				var targetENCFrame = emxUICore.findFrame(getTopWindow(),"ENCBOM");
 			 				getTopWindow().location.href = "../common/emxNavigator.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>";
 			 				//targetENCFrame.location.href = targetENCFrame.location.href;
 			 				
 			 				</script>
 			                <%
							} else {
								%>
 			 				<script language="JavaScript" type="text/javascript">
 			 				var targetENCFrame = emxUICore.findFrame(getTopWindow(),"ENCBOM");
 			 				getTopWindow().location.href = "../common/emxNavigator.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&DefaultCategory=ENCEBOMPowerViewCommand";
 			 				//targetENCFrame.location.href = targetENCFrame.location.href;
 			 				
 			 				</script>
 			                <%
							} 
							//END Modified for HPQC #5397, Redmine #8661
 			            }
 							else
 						{
 							%>
 				<script language="JavaScript" type="text/javascript">
 				   var sURL = "../common/emxForm.jsp?form=AddChange&formHeader=emxEngineeringCentral.Markup.Create&HelpMarker=emxhelpebommarkupcreate&preProcessJavaScript=disableFieldsInENCBOMGotoProduction&mode=edit&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&isSelfTargeted=true&postProcessURL=../engineeringcentral/emxEngrBOMGoToProductionPostProcess.jsp&partObjectId="+"<%=objectId%>"+"&cancelProcessURL=../engineeringcentral/emxClearSession.jsp";
 				   showModalDialog(sURL, 850,630, true); 				
 				</script>
 				<%
 				}
 				%>
 				<script language="JavaScript" type="text/javascript">
 				//var targetENCFrame = emxUICore.findFrame(getTopWindow(),"ENCBOM");
 				//targetENCFrame.location.href = targetENCFrame.location.href;
 				</script>
 <%	
			}
 			else
 			{
				%>
 				<script language="JavaScript" type="text/javascript">
 				   var sURL = "../common/emxForm.jsp?form=AddChange&formHeader=emxEngineeringCentral.Markup.Create&HelpMarker=emxhelpebommarkupcreate&preProcessJavaScript=disableFieldsInENCBOMGotoProduction&mode=edit&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&isSelfTargeted=true&postProcessURL=../engineeringcentral/emxEngrBOMGoToProductionPostProcess.jsp&partObjectId="+"<%=objectId%>"+"&cancelProcessURL=../engineeringcentral/emxClearSession.jsp";
 				   showModalDialog(sURL, 850,630, true); 				
 				</script>
 <%	
 			}
	}
			else
 			{
				MapList changeConnected = domObj.getRelatedObjects(context,
 						ChangeConstants.RELATIONSHIP_AFFECTED_ITEM, EngineeringConstants.TYPE_CHANGE, new StringList(DomainObject.SELECT_ID),
 						null, true, false, (short) 1, "Current != " +EngineeringConstants.STATE_ECO_RELEASE, null, 0);
 				if(changeConnected.size()>0){
 			    	%>
 					    <script language="JavaScript" type="text/javascript">
 					    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
 					    </script>
 					<%	
 					    return;
 				}
				StringList busSelects = new StringList(DomainObject.SELECT_POLICY);
				busSelects.addElement(DomainObject.SELECT_ID);
				busSelects.addElement("to["+ChangeConstants.RELATIONSHIP_CHANGE_ACTION+"].from.id");
				String sWhere = "Current != Complete && Current != Cancelled";
				StringList relSelects = new StringList(ChangeConstants.SELECT_ATTRIBUTE_REQUESTED_CHANGE);
 				MapList mlCAConnected = domObj.getRelatedObjects(context,
 						ChangeConstants.RELATIONSHIP_CHANGE_AFFECTED_ITEM, ChangeConstants.TYPE_CHANGE_ACTION, busSelects,
 						relSelects, true, false, (short) 1, sWhere, null, 0);
 				String sChangeId = "";
 				if(mlCAConnected.size()>0){
 					sChangeId = (String)((Map)mlCAConnected.get(0)).get(DomainObject.SELECT_ID);
 					String sCOId = (String)((Map)mlCAConnected.get(0)).get("to["+ChangeConstants.RELATIONSHIP_CHANGE_ACTION+"].from.id");
 					String sRequestedChange = (String)((Map)mlCAConnected.get(0)).get(ChangeConstants.SELECT_ATTRIBUTE_REQUESTED_CHANGE);
 					if(ChangeConstants.FOR_RELEASE.equals(sRequestedChange) || ChangeConstants.FOR_UPDATE.equals(sRequestedChange)) {
 					
 					%>
 			    	<script language="JavaScript" type="text/javascript">
 			    		var caId = "<%=sChangeId%>";
 			    		var coId = "<%=sCOId%>";
 			    		var partId = "<%=objectId%>";
 			    		var confirmMessage = confirm("<%=strCAConnected%>");
 			    		if(confirmMessage == true) {
 			    			sendInfo();
 			    		}
	    		
 			    		var request;  
 			    		function sendInfo()  
 			    		{
	 			    		var url="../engineeringcentral/emxEngrUseExistingCO.jsp?CAId="+caId+"&COId="+coId+"&partId="+partId;  
	 			    		  
	 			    		if(window.XMLHttpRequest){  
	 			    			request=new XMLHttpRequest();  
	 			    		}  
	 			    		else if(window.ActiveXObject){  
	 			    			request=new ActiveXObject("Microsoft.XMLHTTP");  
	 			    		}  
	 			    		  
	 			    		try{  
		 			    		request.onreadystatechange=getInfo;   
		 			    		request.open("GET",url,true);  
		 			    		request.send();  
	 			    		}catch(e){alert("Unable to connect to server");}  
 			    		}  
 			    		  
 			    		function getInfo(){  
	 			    		if(request.readyState==4){  
	 			    			var val=request.responseText;  
	 			    		}  
 			    		}  
 			    		</script>
 			    	<%
 			       	return;
 				}
 					else {
 						%>
 					    <script language="JavaScript" type="text/javascript">
 					    	alert("<%=strCAConnectedNotWithForUpdate%>");
 					    </script>
 					<%
 						return;	
 					}
 					}
 				%>
 				<script language="JavaScript" type="text/javascript">
 				   var sURL = "../common/emxForm.jsp?form=AddChange&formHeader=emxEngineeringCentral.Markup.Create&HelpMarker=emxhelpebommarkupcreate&preProcessJavaScript=disableFieldsInENCBOMGotoProduction&mode=edit&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&isSelfTargeted=true&postProcessURL=../engineeringcentral/emxEngrBOMGoToProductionPostProcess.jsp&partObjectId="+"<%=objectId%>"+"&cancelProcessURL=../engineeringcentral/emxClearSession.jsp";
 				   showModalDialog(sURL, 850,630, true);
 				</script>
 <%	
 			}
		}
		catch (Exception e) {
			ContextUtil.popContext(context);
			throw e;
		} 
		finally {
			ContextUtil.popContext(context);
		}
	}
	else if("fromRMB".equals(functionality))
	{
		try {
				ContextUtil.pushContext(context);	
				DomainObject domObj = DomainObject.newInstance(context,sRMBObjectId);
				SelectList sPartSelStmts = new SelectList(2);
				StringList affectedItems = new StringList();
				StringList states = new StringList();
				affectedItems.add(sRMBObjectId);
				sPartSelStmts.addElement(DomainObject.SELECT_TYPE);
			    Map objMap = domObj.getInfo(context, (StringList)sPartSelStmts);
			    boolean isStateLTFrozen =false;

			    StringList busSelects = new StringList(DomainObject.SELECT_POLICY);
				String objWhere = "(attribute[" + EngineeringConstants.ATTRIBUTE_RELEASE_PHASE + "]=="+EngineeringConstants.DEVELOPMENT+")" ;

				MapList mapList = domObj.getRelatedObjects(context,
				DomainConstants.RELATIONSHIP_EBOM, DomainConstants.TYPE_PART, busSelects,
				null, false, true, (short) 0, objWhere, null, 0);
				 if(!mapList.isEmpty()){
						%>
					    <script language="JavaScript" type="text/javascript">
					    	alert("<%=strBOMChildReleasePhaseDevErrorMsg%>");
					    </script>
					    <%	
					    return;
					    }
				 
				//check for VPM product is attached to the parts
					String vplmVisible = domObj.getInfo(context, "attribute["+EngineeringConstants.ATTRIBUTE_VPM_VISIBLE+"].value");
					if("true".equalsIgnoreCase(vplmVisible))
					{
						boolean retVal = ReleasePhaseManager.isPartSynchronizedWithVPLM(context,objectId);
						if(!retVal)
				    	{
				    	%>
				    	<script language="JavaScript" type="text/javascript">
				    	alert("<%=strPublishToVPMAlert%>");
				    	</script>
				    	<%	
				    	return;
				       	}
					}
				if(!EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)domObj.getInfo(context,DomainObject.SELECT_POLICY))){
				boolean isStateEqual = ReleasePhaseManager.checkIfBOMChildStatesHigherThanParent(context,sRMBObjectId);
		    	if(!isStateEqual)
		    	{
		    	%>
		    	<script language="JavaScript" type="text/javascript">
		    		alert("<%=strChildStateNotHigherThanParentErrorMsg%>");
		    		</script>
		    	<%	
		    	return;
		       	}
		    	String message = ReleasePhaseManager.checkIfChildAssociatedWithChange(context,sRMBObjectId,false);
			    if("ChangeExistsForChildParts".equalsIgnoreCase(message))
			    {
			    	%>
					    <script language="JavaScript" type="text/javascript">
					    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
					    </script>
					<%	
					    return;
				}
			    if("NextRevExists".equalsIgnoreCase(message))
			    {
			    	%>
					    <script language="JavaScript" type="text/javascript">
					    	alert("<%=strNextRevisionAssociatedWithChildPartErrorMsg%>");
					    </script>
					<%	
					    return;
				}
			    
			    boolean markUpRetVal = ReleasePhaseManager.checkIfPartHasProposedMarkups(context,sRMBObjectId);
			    if(!markUpRetVal)
			    {
			    	%>
					    <script language="JavaScript" type="text/javascript">
					    	alert("<%=strMarkupShouldBeApprovedORRejected%>");
					    </script>
					<%	
					    return;
				}}				
				if(EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)domObj.getInfo(context,DomainObject.SELECT_POLICY))){
					boolean isEffEmpty = ReleasePhaseManager.checkEffectivityExists(context,sRMBObjectId);
					if(isEffEmpty)
			    	{
			    	%>
			    	<script language="JavaScript" type="text/javascript">
			    	alert("<%=strEffectivitySet%>");
			    	</script>
			    	<%	
			    	return;
			       	}
				}
			    
			    String changeRequiredState = ReleasePhase.getChangeRequiredState(context,(String)objMap.get(DomainObject.SELECT_TYPE),EngineeringConstants.DEVELOPMENT);
				if("Frozen".equals(changeRequiredState))
				states = EngineeringUtil.getOCDXStateMappingForDisplayStatePart(context,changeRequiredState);
				
				if((String)states.get(0)!=null && (String)states.get(0)!="")
					 changeRequiredState = (String)states.get(0);	
				
				if(changeRequiredState != null && !"".equals(changeRequiredState))
					isStateLTFrozen = com.matrixone.apps.domain.util.PolicyUtil.checkState(context, sRMBObjectId, changeRequiredState, com.matrixone.apps.domain.util.PolicyUtil.LT);
				
				if(EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)domObj.getInfo(context,DomainObject.SELECT_POLICY)))
				{
					isStateLTFrozen = true;
				}
				
				if(isStateLTFrozen)
				{
					MapList changeConnected = domObj.getRelatedObjects(context,
	 						ChangeConstants.RELATIONSHIP_AFFECTED_ITEM, EngineeringConstants.TYPE_CHANGE, new StringList(DomainObject.SELECT_ID),
	 						null, true, false, (short) 1, "Current != "+EngineeringConstants.STATE_ECO_RELEASE, null, 0);
	 				if(changeConnected.size()>0 && !EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)domObj.getInfo(context,DomainObject.SELECT_POLICY))){
	 			    	%>
	 					    <script language="JavaScript" type="text/javascript">
	 					    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
	 					    </script>
	 					<%	
	 					    return;
	 				}
					ReleasePhaseManager.setAttributesOnPartObj(context,affectedItems);
					if(!EngineeringConstants.POLICY_CONFIGURED_PART.equals((String)domObj.getInfo(context,DomainObject.SELECT_POLICY)) && "True".equals(reviseSequence))
						ReleasePhaseManager.resetRevision(context,affectedItems);
%>
				<script language="JavaScript" type="text/javascript">
				var frameName = emxUICore.findFrame(getTopWindow(),"ENCBOM")?emxUICore.findFrame(getTopWindow(),"ENCBOM"):emxUICore.findFrame(getTopWindow(),"PUEUEBOM")
				frameName.location.href = frameName.location.href;
 				</script>
 <%	
				}
				else
				{
					MapList changeConnected = domObj.getRelatedObjects(context,
	 						ChangeConstants.RELATIONSHIP_AFFECTED_ITEM, EngineeringConstants.TYPE_CHANGE, new StringList(DomainObject.SELECT_ID),
	 						null, true, false, (short) 1, "Current != "+EngineeringConstants.STATE_ECO_RELEASE, null, 0);
	 				if(changeConnected.size()>0){
	 			    	%>
	 					    <script language="JavaScript" type="text/javascript">
	 					    	alert("<%=strReleaseChangeAssociatedWithPartErrorMsg%>");
	 					    </script>
	 					<%	
	 					    return;
	 				}
					
					StringList slBusSelects = new StringList(DomainObject.SELECT_POLICY);
					slBusSelects.addElement(DomainObject.SELECT_ID);
					slBusSelects.addElement("to["+ChangeConstants.RELATIONSHIP_CHANGE_ACTION+"].from.id");
					String sWhere = "Current != Complete && Current != Cancelled";
					StringList relSelects = new StringList(ChangeConstants.SELECT_ATTRIBUTE_REQUESTED_CHANGE);
	 				MapList mlCAConnected = domObj.getRelatedObjects(context,
	 						ChangeConstants.RELATIONSHIP_CHANGE_AFFECTED_ITEM, ChangeConstants.TYPE_CHANGE_ACTION, slBusSelects,
	 						null, true, false, (short) 1, sWhere, null, 0);
	 				String sChangeId = "";
	 				if(mlCAConnected.size()>0){
	 					sChangeId = (String)((Map)mlCAConnected.get(0)).get(DomainObject.SELECT_ID);
	 					String sCOId = (String)((Map)mlCAConnected.get(0)).get("to["+ChangeConstants.RELATIONSHIP_CHANGE_ACTION+"].from.id");
	 					String sRequestedChange = (String)((Map)mlCAConnected.get(0)).get(ChangeConstants.SELECT_ATTRIBUTE_REQUESTED_CHANGE);
	 					if(ChangeConstants.FOR_RELEASE.equals(sRequestedChange) || ChangeConstants.FOR_UPDATE.equals(sRequestedChange)) {
	 					%>
	 			    	<script language="JavaScript" type="text/javascript">
	 			    		var caId = "<%=sChangeId%>";
	 			    		var coId = "<%=sCOId%>";
	 			    		var partId = "<%=sRMBObjectId%>";
	 			    		var confirmMessage = confirm("<%=strCAConnected%>");
	 			    		if(confirmMessage == true) {
	 			    			sendInfo();
	 			    		}
		    		
	 			    		var request;  
	 			    		function sendInfo()  
	 			    		{
		 			    		var url="../engineeringcentral/emxEngrUseExistingCO.jsp?CAId="+caId+"&COId="+coId+"&partId="+partId;  
		 			    		  
		 			    		if(window.XMLHttpRequest){  
		 			    			request=new XMLHttpRequest();  
		 			    		}  
		 			    		else if(window.ActiveXObject){  
		 			    			request=new ActiveXObject("Microsoft.XMLHTTP");  
		 			    		}  
		 			    		  
		 			    		try{  
			 			    		request.onreadystatechange=getInfo;   
			 			    		request.open("GET",url,true);  
			 			    		request.send();  
		 			    		}catch(e){alert("Unable to connect to server");}  
	 			    		}  
	 			    		  
	 			    		function getInfo(){  
		 			    		if(request.readyState==4){  
		 			    			var val=request.responseText;  
		 			    		}  
	 			    		}  
	 			    		</script>
	 			    	<%
	 			       	return;
	 				}
	 					else {
	 						%>
	 					    <script language="JavaScript" type="text/javascript">
	 					    	alert("<%=strCAConnectedNotWithForUpdate%>");
	 					    </script>
	 					<%
	 						return;	
	 					}
	 					}
					%>
					<script language="JavaScript" type="text/javascript">
					 var sURL = "../common/emxForm.jsp?form=AddChange&formHeader=emxEngineeringCentral.Markup.Create&HelpMarker=emxhelpebommarkupcreate&mode=edit&preProcessJavaScript=disableFieldsInENCBOMGotoProduction&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&isSelfTargeted=true&postProcessURL=../engineeringcentral/emxEngrBOMGoToProductionPostProcess.jsp&partObjectId="+"<%=sRMBObjectId%>"+"&cancelProcessURL=../engineeringcentral/emxClearSession.jsp";
	 			     top.showModalDialog(sURL, 850,630, true);
					</script>
					<%	
				}				
			} catch (Exception e) {
			ContextUtil.popContext(context);
			throw e;
		} finally {
			ContextUtil.popContext(context);
		}
		
		%>
		<script language="JavaScript" type="text/javascript">
		   emxUICore.findFrame(getTopWindow(),"ENCBOM").emxEditableTable.refreshRowByRowId(sRowId);
		</script>
		<%		
	}

%>

