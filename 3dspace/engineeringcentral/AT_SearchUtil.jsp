<%--  SearchUtil.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>

<%@page import="com.matrixone.apps.engineering.PartFamily"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
String strObjId = emxGetParameter(request, "objectId");
//String strObjId = emxGetParameter(request, "objectId");
String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
String addMasterReference=emxGetParameter(request,"addMasterReference");
//adding for Master Reference Full Search..this block will be executed when unassigned part is added to Master Part as reference part 
if(UIUtil.isNotNullAndNotEmpty(addMasterReference)){
  	
  	String MasterId = emxGetParameter(request,"MasterId");
  	HashMap addReferenceToMasterInfo   = new HashMap();
  	Map map = new HashMap();
  	map.put("objectId",strObjId);
  	map.put("MasterId",MasterId);
  	map.put("emxTableRowId",selectedItems);
  	String [] args = JPO.packArgs(map);
  	addReferenceToMasterInfo = (HashMap)JPO.invoke(context,"emxPartFamily",null,"addReferencestoMasterFullSearch",args,HashMap.class);
%>
 <script language="javascript" src="../common/scripts/emxUICore.js"></script>
 <script language="javascript">
 getTopWindow().closeWindow();
 </script>
 <%
 return;
 }
  boolean bIsError = false;
  try {
     String strMode = emxGetParameter(request,"mode");
     strMode = (strMode != null) ? strMode : "";
     String jsTreeID = emxGetParameter(request, "jsTreeID");
     //String strObjId = emxGetParameter(request, "objectId");
     String uiType = emxGetParameter(request,"uiType");
     //String strMode1 = emxGetParameter(request,"context");
     String suiteKey = emxGetParameter(request, "suiteKey");
     String regisateredSuite = emxGetParameter(request,"SuiteDirectory");
     String strRelName = emxGetParameter(request,"relName");
     
     String fieldNameActual = emxGetParameter(request, "fieldNameActual");
     String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
     String typeAhead = emxGetParameter(request, "typeAhead");
     typeAhead = XSSUtil.encodeForJavaScript(context,typeAhead);//Modified for IR-381096

     //String frameName = emxGetParameter(request, "frameName"); //Modified for IR-184864
	 String frameName = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "frameName"));
    		 
    if (frameName == null || "".equals(frameName) || "null".equals(frameName)) {
    	frameName = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "OpenerFrame"));
    }
     String strDesRespName = "";
     String strDesRespId = "";
	
     Map rdoDetails = null;
     
     //get the selected Objects from the Full Search Results page
     String strContextObjectId[] = emxGetParameterValues(request, "emxTableRowId");
     //If the selection is empty given an alert to user

     if(strContextObjectId==null){
     %>
       <script language="javascript" type="text/javaScript">
           alert('<emxUtil:i18n localize='i18nId'>emxEngineeringCentral.Common.PleaseSelectAnItem</emxUtil:i18n>');
       </script>
     <%}
     //If the selection are made in Search results page then
     else{
%>
<script language="javascript" type="text/javaScript">
//XSSOK
var typeAhead = "<%=XSSUtil.encodeForJavaScript(context,typeAhead)%>";
var targetWindow = null;
//XSSOK
var fname = "<%=frameName%>";
if(typeAhead == "true") {
//Modified for IR-184864
	if(null!=fname && ""!=fname && "null"!=fname)
		{
		//XSSOK
        targetWindow = getTopWindow().findFrame(window.parent, "<%=frameName%>");
		}
	else
		targetWindow = window.parent;
} else {
	targetWindow = getTopWindow().getWindowOpener();
}

function assignDisplayValueToHiddenField(curFieldName){
	var currentFieldDisplay;
	var currentFieldActual;
	var userEnteredValue;
	if((curFieldName.indexOf("Display")>0) && (curFieldName.indexOf("Display")+7) == curFieldName.length){
		currentFieldDisplay = targetWindow.document.forms[0][curFieldName];		
		curFieldName = curFieldName.substring(0,curFieldName.indexOf("Display"));
		currentFieldActual = targetWindow.document.forms[0][curFieldName];		
	} else {
		currentFieldActual = targetWindow.document.forms[0][curFieldName];
		currentFieldDisplay = targetWindow.document.forms[0][curFieldName+"Display"];			
	}

	userEnteredValue = currentFieldDisplay.value;
	currentFieldActual.value = userEnteredValue;	
}

</script>
<%

     	if(strMode.equalsIgnoreCase("Chooser"))
	    {
	         try {
	             //gets the mode passed
	              String strSearchMode = emxGetParameter(request, "chooserType");
	              // if the chooser is in the Custom JSP
	              if (strSearchMode.equals("CustomChooser")) {
	                  fieldNameActual = emxGetParameter(request, "fieldNameActual");
	                  fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");

	                  StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
	                  String strObjectId = strTokenizer.nextToken() ;

	                  DomainObject objContext = new DomainObject(strObjectId);
	                  String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
	                  %>
	                      <script language="javascript" type="text/javaScript">
	                    //XSSOK
	                          var vfieldNameActual = targetWindow.document.getElementById("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
	                        //XSSOK
	                          var vfieldNameDisplay = targetWindow.document.getElementById("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
	                        //XSSOK
	                          vfieldNameDisplay.value ="<%=strContextObjectName%>" ;
	                        //XSSOK
	                          vfieldNameActual.value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
	                          
	                          
	                          if(typeAhead != "true")
		                          getTopWindow().closeWindow();
	                      </script>
	                  <%
	              } else if("PartNameChooser".equals(strSearchMode)){
	  					String actualValue = "";
	  					String displayValue = "";
	  					StringList list 		= FrameworkUtil.split(strContextObjectId[0], "|");
	  					String strObjectId 		= (String)list.get(0);
	  					DomainObject objContext = new DomainObject(strObjectId);
	  			    	StringList strList = new StringList();
	  			    	strList.addElement(DomainConstants.SELECT_NAME);
	  			    	Map resultList = objContext.getInfo(context, strList);
	  			    	String strContextObjectName = (String)resultList.get("name");
	  			   		actualValue = strContextObjectName;
	  			    	displayValue = strContextObjectName;
	  			    
	  				%>
	  				<script language="Javascript" >
	  				//XSSOK
	  					var typeAhead = "<%=XSSUtil.encodeForJavaScript(context,typeAhead)%>";
	  					var targetWindow = "";
	  					var frameName = "<%=XSSUtil.encodeForJavaScript(context, frameName)%>";
	  					//XSSOK
	  					var tmpFieldNameActual = "<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>";
	  					//XSSOK
	  					var tmpFieldNameDisplay = "<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>";
	  									   
	  					targetWindow = getTopWindow().openerFindFrame(getTopWindow(), frameName);
	  					
	  					if(targetWindow == null||targetWindow =="undefined")
	  					targetWindow = getTopWindow().openerFindFrame(getTopWindow(), "content");
	  				    
	  				    var vfieldNameActual = targetWindow.document.forms[0][tmpFieldNameActual];
	  				    var vfieldNameDisplay = targetWindow.document.forms[0][tmpFieldNameDisplay];
	  				    
	  				  //XSSOK
	  				    vfieldNameDisplay.value ="<%=displayValue%>" ;
	  				  //XSSOK 
	  				    vfieldNameActual.value ="<%=actualValue%>" ;
	  				    
	  					if(typeAhead != "true")
	  						getTopWindow().closeWindow();
	  				</script>
	  				<% } 
	              
	              else if (strSearchMode.equals("FormChooser")) {
	                  fieldNameActual = emxGetParameter(request, "fieldNameActual");
	                  fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
	                  //IR-008348 - Starts
	                  String partFamilyAutoName = emxGetParameter(request, "partFamilyAutoGenName");
	                  //IR-008348 - Ends

	                  StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ;

	                  DomainObject objContext = new DomainObject(strObjectId);
	                  String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);

	                  //Modified for IR-044857 - Starts
	                  String sPartFamilyAutoName = null;
	                  String aliasPFPolicy = null;
	                  String defaultPFPolicy = null;
	                  String revisionSeq	= null; //IR-018237
	                  if(fieldNameDisplay!=null && fieldNameDisplay.equalsIgnoreCase("partFamily")){
		                  //IR-008348 - Starts
		                   sPartFamilyAutoName  = objContext.getAttributeValue(context, PropertyUtil.getSchemaProperty(context,"attribute_PartFamilyNameGeneratorOn"));
		                  //IR-008348 - Ends
		                  //IR-018237 - Starts
		                  aliasPFPolicy   = objContext.getAttributeValue(context, PropertyUtil.getSchemaProperty(context,"attribute_DefaultPartPolicy"));
						  defaultPFPolicy = PropertyUtil.getSchemaProperty(context,aliasPFPolicy);
						  Policy policy = new Policy(defaultPFPolicy);
						  revisionSeq   = policy.getFirstInSequence(context);
		                  //IR-018237 - Ends
	                  }
	                  //Modified for IR-044857 - Ends
	                  %>
	                  <script language="javascript" type="text/javaScript">
	         		       //XSSOK
	                      var vfieldNameActual = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
	                    //XSSOK
	                      var vfieldNameDisplay = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
	                      //IR-008348 - Starts
	                      if ("<%=XSSUtil.encodeForJavaScript(context,partFamilyAutoName)%>" != "null") {
	                    	//XSSOK
	                      	var vPartFamilyAutoName = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,partFamilyAutoName)%>");
	                      //XSSOK
	                      	vPartFamilyAutoName[0].value = "<%=sPartFamilyAutoName%>";
	                      }
	                      //IR-008348 - Ends
	                      //IR-018237 - Starts
	                      var policies = targetWindow.document.getElementById("policy");
	                       //Modified for IR-044857V6R2011 - Starts
	                       //XSSOK
	                      if(policies != null && "<%=defaultPFPolicy%>"!="null"){
	                       //Modified for IR-044857V6R2011 - Ends
	                      for (var index=0; index < policies.length; index++) {
	                    	//XSSOK
	                      	if (policies[index].value == "<%=defaultPFPolicy%>") {
									var formLen = parent.getTopWindow().getWindowOpener().document.forms.length;
									revision = parent.getTopWindow().getWindowOpener().document.forms[formLen-1].elements["rev"]; //018237
									//XSSOK
									revision.value = "<%=revisionSeq%>"; //018237
	                      		targetWindow.document.getElementById("policy")[index].selected = true;
	                      		break;
		                      	}
	                      	}
	                      }
	                      //IR-018237 - Ends
	                      //XSSOK
	                      vfieldNameDisplay[0].value ="<%=strContextObjectName%>" ;
	                    //XSSOK
	                      vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
	                      
	                      
	                      
	                      if(typeAhead != "true")
	                          getTopWindow().closeWindow();

	                    </script>
	               <%
	              } else if(strSearchMode.equals("FormCustomChooser")){
                      fieldNameActual = emxGetParameter(request, "fieldNameActual");
                      fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
                      String fieldNameRDOActual = emxGetParameter(request, "fieldRDONameActual");
                      String fieldNameRDODisplay = emxGetParameter(request, "fieldRDONameDisplay");
                          StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                          String strObjectId = strTokenizer.nextToken() ;
                          DomainObject objContext = new DomainObject(strObjectId);
                          String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
                          matrix.util.StringList strlSelect = new matrix.util.StringList(2);
                          strlSelect.add("to["+DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.id");
                          strlSelect.add("to["+DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.name");
                          Map mpTemp = objContext.getInfo(context, strlSelect);
                          if(mpTemp!=null && mpTemp.containsKey("to["+DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.id")){
                              strDesRespName = (mpTemp.get("to["+DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.name")).toString();
                              strDesRespId = (mpTemp.get("to["+DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.id")).toString();
                              if(!strDesRespName.equals("")){
                                    if(strDesRespName.contains("["))
                                        strDesRespName = strDesRespName.substring(1,(strDesRespName.length()-1));
                                    if(strDesRespId.contains("["))
                                        strDesRespId = strDesRespId.substring(1,(strDesRespId.length()-1));
                              }
                          }
                          %>
                          <script language="javascript" type="text/javaScript">
                      	   //XSSOK
                             var vfieldNameActual = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                           //XSSOK
                             var vfieldNameDisplay = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                           //XSSOK
                             vfieldNameDisplay[0].value ="<%=strContextObjectName%>" ;
                           //XSSOK
                             vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
                             <% if(strDesRespName!=null && !strDesRespName.equals(""))
                             { %>
                           //XSSOK
                                var vfieldRDODisplay  = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameRDODisplay)%>");
                              //XSSOK
                                var vfieldRDOActual  =  targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameRDOActual)%>");
                              //XSSOK
                                vfieldRDODisplay[0].value = "<%=strDesRespName%>" ;
                              //XSSOK
                                vfieldRDOActual[0].value = "<%=strDesRespId%>" ;
                            <% } %>
                            
                            
                            
                            if(typeAhead != "true")
								getTopWindow().closeWindow();
                          </script>
                      <%
                  } else if (strSearchMode.equals("formCustomChooserECOField")) {
                	  fieldNameActual     = emxGetParameter(request, "fieldNameActual");
                      fieldNameDisplay    = emxGetParameter(request, "fieldNameDisplay");
                      String fieldECOId   = emxGetParameter(request, "fieldECOId");
                      String showRDOField = emxGetParameter(request, "showRDOField");                     
                      
                      StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ;
                      DomainObject objContext = new DomainObject(strObjectId);
                      String strContextObjectName = objContext.getInfo(context, DomainConstants.SELECT_NAME);                      
%>
                      <script language="javascript" type="text/javaScript">
                    //XSSOK
                         var vfieldNameActual  = targetWindow.document.getElementsByName("<%= XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                       //XSSOK
                         var vfieldNameDisplay = targetWindow.document.getElementsByName("<%= XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                       //XSSOK
                         var vfieldOID         = targetWindow.document.getElementsByName("<%= XSSUtil.encodeForJavaScript(context,fieldECOId)%>");
                       //XSSOK
                         vfieldNameDisplay[0].value = "<%= strContextObjectName%>";
                       //XSSOK
                         vfieldNameActual[0].value  = "<%= strContextObjectName%>";
                       //XSSOK
                         vfieldOID[0].value         = "<%= XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
                             
<%
                       	 String fieldNameRDOActual  = emxGetParameter(request, "fieldRDONameActual");
                            String fieldNameRDODisplay = emxGetParameter(request, "fieldRDONameDisplay");
                            String fieldRDOId          = emxGetParameter(request, "fieldRDOId");
                            
                       	 HashMap rdoInfoMap = (HashMap) JPO.invoke(context, "emxECO", null, "getRDOOfSelectedECO", new String[] {strObjectId}, HashMap.class);
					 
						 strDesRespName = (String) rdoInfoMap.get("rdoName");
						 strDesRespId   = (String) rdoInfoMap.get("rdoId");
%>
						//XSSOK
						 var vfieldRDODisplay = targetWindow.document.getElementsByName("<%= fieldNameRDODisplay%>");
						 if (vfieldRDODisplay[0] != null && vfieldRDODisplay[0] != "undefined") {
							//XSSOK
							  var vfieldRDOActual  = targetWindow.document.getElementsByName("<%= XSSUtil.encodeForJavaScript(context,fieldNameRDOActual)%>");
							//XSSOK
							  var fieldRDOId       = targetWindow.document.getElementsByName("<%= XSSUtil.encodeForJavaScript(context,fieldRDOId)%>");
							//XSSOK
							  vfieldRDODisplay[0].value = "<%= strDesRespName%>";
							//XSSOK
							  vfieldRDOActual[0].value  = "<%= strDesRespName%>";
							//XSSOK
							  fieldRDOId[0].value       = "<%= strDesRespId%>";
						  }
                             
                         if (typeAhead != "true")
                             getTopWindow().closeWindow();
                         
                      </script>
<%                  
                  } else if (strSearchMode.equals("RDOChooser")) {
	                  fieldNameActual = emxGetParameter(request, "fieldNameActual");
	                  fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");

	                  StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ;

	                  DomainObject objContext = new DomainObject(strObjectId);
	                  String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
	                  %>
	                  <script language="javascript" type="text/javaScript">
	                //XSSOK
	                      var vfieldNameActual = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
	                    //XSSOK
	                      var vfieldNameDisplay = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
	                    //XSSOK
	                      if(vfieldNameActual[0].value != "<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>") {
	                      	targetWindow.clearRelatedFields();
	                      }
	                    //XSSOK
	                      vfieldNameDisplay[0].value ="<%=strContextObjectName%>" ;
	                    //XSSOK
	                      vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
	                      
	                      
	                      
	                      if(typeAhead != "true")
	                      	getTopWindow().closeWindow();

	                    </script>
	               <%
	              } else if (strSearchMode.equals("PersonChooser")) {
	                  fieldNameActual = emxGetParameter(request, "fieldNameActual");
	                  fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");

	                  StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ;

	                  DomainObject objContext = new DomainObject(strObjectId);
	                  String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);

					%>
	                  <script language="javascript" type="text/javaScript">
	                //XSSOK
	                      var vfieldNameActual = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
	                    //XSSOK
	                      var vfieldNameDisplay = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
	                    //XSSOK
	                      vfieldNameDisplay[0].value ="<%=strContextObjectName%>" ;
	                      //Modified for FullSearch Configuration for Owner
	                      if(typeof vfieldNameActual[0]!='undefined'){
	                    	//XSSOK
	                      		vfieldNameActual[0].value ="<%=strContextObjectName%>" ;
	                      }
	                     
	                      
	                      if(typeAhead != "true")
                          	getTopWindow().closeWindow();

	                    </script>
					<%
	              } if (strSearchMode.equals("FamilyChooser")) {
	                  fieldNameActual = emxGetParameter(request, "fieldNameActual");
	                  fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
	                  String formName = emxGetParameter(request, "formName");

	                  StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
	                  String strObjectId = strTokenizer.nextToken() ;
	                  DomainObject objContext = new DomainObject(strObjectId);
	                  String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
	          %>
	                  <script language="javascript" type="text/javaScript">
	                //XSSOK
	                  var form="<%=XSSUtil.encodeForJavaScript(context,formName)%>";
	                  var vfieldNameActual;
	                  var vfieldNameDisplay;

	                  var familyChoserEle = (parent.getTopWindow().getWindowOpener().document.forms[0].elements["<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>"]);

	                  var fcindex = (familyChoserEle != null && familyChoserEle != "undefined" && familyChoserEle != "" ) ? 0 : 1;
	                  
                      vfieldNameActual = parent.getTopWindow().getWindowOpener().document.forms[fcindex].elements["<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>"];
                 
                      vfieldNameDisplay = parent.getTopWindow().getWindowOpener().document.forms[fcindex].elements["<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>"];
	                  
	                //XSSOK
	                      vfieldNameDisplay.value ="<%=strContextObjectName%>" ;
	                    //XSSOK
	                      vfieldNameActual.value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>";
						  
						  
						  
						  if(typeAhead != "true")
	                      	parent.getTopWindow().closeWindow();
	                  </script>
	                  <%
	              }
             //R208.HF1 - Ends
	         } catch (Exception e) {
	              session.putValue("error.message", e.getMessage());
	         }
	     } else if(strMode.equals("AddExistingInPartFamily")) {//Added this block to fix IR-093282V6R2012 - starts
	    	 %>
	    	<script language="javascript" type="text/javaScript">
	    	<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>	
			</script>
	    	 <%
		 		Object objToConnectObject = "";
		        String strToRefDocId = "";
				strRelName = PropertyUtil.getSchemaProperty(context,strRelName);
				PartFamily partFamily = new PartFamily(strObjId);
				    for(int i=0;i<strContextObjectId.length;i++)
				    {
						StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] ,"|");
						
						for(int j=0;j<strTokenizer.countTokens();j++){
				             objToConnectObject = strTokenizer.nextElement();
				             strToRefDocId = objToConnectObject.toString();
				             break;
				         }
						
		                if (strToRefDocId != null) {
		                    try
		                    {
		                  		partFamily.addReferenceDocument(context, strToRefDocId);
		                    }
		                    catch(Exception e)
		                    {
		                	  String sError = e.toString();
		                          session.putValue("error.message",sError);
		                    }
		                }
          		 
				    }
				 
					%>
					<script language="javascript" type="text/javaScript">
					window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
					window.getTopWindow().closeWindow();
					</script>

		<%
	     }//Added this block to fix IR-093282V6R2012 -Ends
	     else if(strMode.equals("AddExisting")) {

	    	 %>
		    	<script language="javascript" type="text/javaScript">
		    	<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>	
				</script>
		    	 <%
		        Object objToConnectObject = "";
		        String strToConnectObject = "";
				strRelName = PropertyUtil.getSchemaProperty(context,strRelName);
				
		        String strFromSide = emxGetParameter(request, "from");
		        String sSumittedFrom = emxGetParameter(request,"submittedFrom");
		        boolean From = true;
		        if (strFromSide.equals("false")){
		            From = false;
		        }

			        for(int i=0;i<strContextObjectId.length;i++){
						StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] ,"|");

						//Extracting the Object Id from the String.
						for(int j=0;j<strTokenizer.countTokens();j++){
				             objToConnectObject = strTokenizer.nextElement();
				             strToConnectObject = objToConnectObject.toString();
				             break;
				         }
						 
					    //Added for IR-088845V6R2012					
					    if(DomainConstants.RELATIONSHIP_REFERENCE_DOCUMENT.equals(strRelName) || "AT_STANDARD_MATERIAL".equals(strRelName))
						{
						   ContextUtil.pushContext(context);
						}
						//Code for connecting the objects
						//DomainRelationship.connect(context,strObjId,strRelName,strToConnectObject,From);
						//Modified above line of code for IR-252906V6R2014x
						//Modified for REQ07.003 : Link standards to a material in library.
						if("AT_STANDARD_MATERIAL".equals(strRelName))
						{							
							DomainRelationship.connect(context,strToConnectObject,strRelName,strObjId,true);
						}
						else
						{
							DomainRelationship.connect(context,strObjId,strRelName,strToConnectObject,true);
						}
					     //Added for IR-088845V6R2012  
					   if(DomainConstants.RELATIONSHIP_REFERENCE_DOCUMENT.equals(strRelName) || "AT_STANDARD_MATERIAL".equals(strRelName))
						 {
							ContextUtil.popContext(context);
						 }						
			        }
					%>
					
					<script language="javascript" type="text/javaScript">
					//window.parent.targetWindow.parent.location.href = window.parent.targetWindow.parent.location.href;
					var sSumittedFrom = "<%=sSumittedFrom%>";
					if(sSumittedFrom != null && sSumittedFrom != "undefined" && sSumittedFrom == "AddExistingDocument")
						{
							window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
						 	if (getTopWindow() && getTopWindow().getWindowOpener()) {
				             	getTopWindow().closeWindow();
				 			}
				 			else{
				 				getTopWindow().close();
				 			}
						}
					else
						window.parent.getTopWindow().getWindowOpener().location.href = window.parent.getTopWindow().getWindowOpener().location.href;

					window.getTopWindow().closeWindow();
					</script>

		<%
	     } else if(strMode.equals("clonedPartOpenInEditMode")) {
	    	 String newObjectId = emxGetParameter(request, "newObjectId");
	    	 String fromPartPropertiesNav = emxGetParameter(request, "fromPartProperties");
	    	 String fromPartFamilyNav = emxGetParameter(request, "fromPartFamilyNav");
%>	    	 
	    	 <script language="javascript" type="text/javaScript">
	    	 //XSSOK
	    	    var url = "../common/emxForm.jsp?fromPartFamilyNav=<%=XSSUtil.encodeForJavaScript(context,fromPartFamilyNav)%>&form=type_Part&formHeader=emxEngineeringCentral.Part.EditPart&mode=edit&categoryTreeName=type_Part&viewtoolbar=ENCpartPartDetailsToolBar&HelpMarker=emxhelpparteditdetails&preProcessJavaScript=preProcessInEditPart&postProcessJPO=emxPart:partEditPostProcess&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&objectId=<%=XSSUtil.encodeForJavaScript(context,newObjectId)%>&emxTableRowId=<%=XSSUtil.encodeForJavaScript(context,newObjectId)%>&cancelAction=cancel&postProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent&cancelProcessURL=../engineeringcentral/SearchUtil.jsp?mode=displayTreeContent";
	    	  //XSSOK
	    	    if ("<%= XSSUtil.encodeForJavaScript(context,fromPartPropertiesNav)%>" == "true") {	    	    	   	    	
                    getTopWindow().getWindowOpener().location.href = url;                    
	    	    } else {
	    	    	  winObject = findFrame(getTopWindow().getWindowOpener(), "content");
	    	    	  winObject.document.location.href = url;	    	    	  
	    	    }	    	    	    	    
	        </script>
<%	                    
	     }

	     else if (strMode.indexOf("displayTreeContent") > -1) {
	    	 String fromPartFamilyNav = emxGetParameter(request, "fromPartFamilyNav");
	    	 String appDirectory = (String) FrameworkProperties.getProperty(context, "eServiceSuiteEngineeringCentral.Directory");
%>
            <script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
            <script language="javascript" type="text/javaScript">
          //XSSOK
            if ("<%= XSSUtil.encodeForJavaScript(context,fromPartFamilyNav)%>" == "true") {            
            	//XSSOK
                document.location.href = "../common/emxTree.jsp?mode=insert&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjId)%>";
            } else {
            	//XSSOK
            	document.location.href = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context,strObjId)%>";
            }
            </script>
<%	    	 
	     }

	     else if("ECO".equalsIgnoreCase(fieldNameActual)) {
	         StringBuffer actualValue = new StringBuffer();
	         StringBuffer displayValue = new StringBuffer();
	         for(int i=0;i<strContextObjectId.length;i++) {
	         	StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] , "|");
	         	String strObjectId = strTokenizer.nextToken() ;		                    
	         	DomainObject objContext = new DomainObject(strObjectId);
	         	
	         	rdoDetails = EngineeringUtil.getRDODetails(context, strObjectId, "RDO");
	         	String strContextObjectName = objContext.getInfo(context, DomainConstants.SELECT_NAME);
	         	actualValue.append(strObjectId);
	         	displayValue.append(strContextObjectName);
	         }		                

		%>
		<script language="javascript" type="text/javaScript">
		//XSSOK
			var tmpFieldNameActual = "<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>";
			//XSSOK
			var tmpFieldNameDisplay = "<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>";
			var tmpFieldNameOID = tmpFieldNameActual + "OID";
			var vfieldNameActual = targetWindow.document.getElementById(tmpFieldNameActual);
			var vfieldNameDisplay = targetWindow.document.getElementById(tmpFieldNameDisplay);
			var vfieldNameOID = targetWindow.document.getElementById(tmpFieldNameOID);
			if (vfieldNameActual==null && vfieldNameDisplay==null) {
				vfieldNameActual=targetWindow.document.forms[0][tmpFieldNameActual];
				vfieldNameDisplay=targetWindow.document.forms[0][tmpFieldNameDisplay];
				vfieldNameOID=targetWindow.document.forms[0][tmpFieldNameOID];
			}
			//XSSOK
			vfieldNameDisplay.value ="<%=displayValue%>" ;
			//XSSOK
			vfieldNameActual.value ="<%=displayValue%>" ;
			if(vfieldNameOID != null)
				{
				//XSSOK
				vfieldNameOID.value ="<%=actualValue%>" ;
				}
			var vfieldRDODisplay  = targetWindow.document.getElementsByName("RDODisplay");
			if(vfieldRDODisplay.length != 0) {
	            var vfieldRDOActual  =  targetWindow.document.getElementsByName("RDO");
	            var vfieldRDOOID  =  targetWindow.document.getElementsByName("RDOOID");
	            
	        } else {
				var vfieldRDODisplay  = targetWindow.document.getElementsByName("DesignResponsibilityDisplay");	        
				var vfieldRDOActual  =  targetWindow.document.getElementsByName("DesignResponsibility");
	            var vfieldRDOOID  =  targetWindow.document.getElementsByName("DesignResponsibilityOID");
	        }
			//XSSOK
            vfieldRDODisplay[0].value = "<%=(String)rdoDetails.get("RDODisplay")%>";
          //XSSOK
            vfieldRDOActual[0].value = "<%=(String)rdoDetails.get("RDO")%>" ;
          //XSSOK
            vfieldRDOOID[0].value = "<%=(String)rdoDetails.get("RDOOID")%>" ;
                                
			if(typeAhead != "true")
				getTopWindow().closeWindow();
		</script>
		<%
	     } else if("clonePartNum".equalsIgnoreCase(fieldNameActual)) {
	         StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
	         String strObjectId = strTokenizer.nextToken() ;
	         
	         DomainObject domPFObj = DomainObject.newInstance(context, strObjectId);  
	         String SELECT_PARTFAMILY_ID = "to[" + DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM + "].from.id";
	         String SELECT_PARTFAMILY_NAME_GENERATOR_ON = "to[" + DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM + "].from.attribute[" + DomainConstants.ATTRIBUTE_PART_FAMILY_NAME_GENERATOR_ON + "]";
	         
	         StringList objectselect = new StringList(3);
			 objectselect.add(DomainConstants.SELECT_TYPE);
	         objectselect.add(SELECT_PARTFAMILY_ID);
	         objectselect.add(SELECT_PARTFAMILY_NAME_GENERATOR_ON);
	         
	         Map infoMap = domPFObj.getInfo(context, objectselect);
	         String pfId = (String) infoMap.get(SELECT_PARTFAMILY_ID); 	         
	         String pfAutoNameGenerator = (String) infoMap.get(SELECT_PARTFAMILY_NAME_GENERATOR_ON);
	         if (pfAutoNameGenerator == null) {
	        	 pfAutoNameGenerator = "false";
	         }
			 String sType=(String) infoMap.get(DomainConstants.SELECT_TYPE);
	         String selectedObjectType="_selectedType:"+sType+",type_Part";
	         //String selectedObjectSymbolicType = com.matrixone.apps.framework.ui.UICache.getSymbolicName(context, (String) infoMap.get(DomainConstants.SELECT_TYPE), "type");

		%>
		<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
		
		<script language="javascript" type="text/javaScript">
		//Modified for To Create Multiple part from Part Clone
			//XSSOK
			var tempNameField = targetWindow.document.forms[0]["nameField"].value;
			targetWindow.location.href = "../common/emxCreate.jsp?submitAction=doNothing&nameField=" + tempNameField + "&typeChooser=true&header=emxEngineeringCentral.Part.ClonePart&form=ENCClonePart&suiteKey=EngineeringCentral&multiPartCreation=true&createMode=ENG&HelpMarker=emxhelppartclone&copyObjectId=<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>&type=<%=selectedObjectType%>&postProcessJPO=emxPart:postProcessForClonePart&preProcessJavaScript=preProcessInCreatePartClone&TypeActual=Part&createJPO=emxPart:checkLicenseAndCloneObject&partFamilyID=<%=pfId%>&PartFamilyAutoName=<%=pfAutoNameGenerator%>&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp?mode=clonedPartOpenInEditMode&emxTableRowId=<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>&targetLocation=slidein";
			if(typeAhead != "true")
				getTopWindow().closeWindow();
		</script>	         
		<%
	     }
     }

  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
    //emxNavErrorObject.addMessage(e.toString().trim());
  }// End of main Try-catck block
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

