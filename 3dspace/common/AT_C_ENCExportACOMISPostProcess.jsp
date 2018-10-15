 <%--  AT_C_ENCExportACOMISPostProcess.jsp  -  
   This jsp is added as a part of ALSTOM customization - [REQP2A_01  – New link "Export to ACOMIS" ]
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>

<%@page import="java.util.Map,java.util.Calendar,java.text.SimpleDateFormat,java.util.TimeZone,java.util.HashMap,java.util.Enumeration,matrix.util.StringList,com.matrixone.apps.domain.util.PropertyUtil,com.matrixone.apps.domain.DomainObject,com.matrixone.apps.domain.util.ContextUtil,matrix.db.BusinessObject,com.matrixone.apps.domain.DomainConstants"%>


<%
System.out.println(" START ACOMIS AT_C_ENCExportACOMISPostProcess ");
String sStatusMsg = "No Object";
String logicalNodeEnt="";
String outputMessage="Export to PLM2ACOMIS processing started ";
String ProdConfigEnt="";
boolean processerror= false;
boolean creatnewDoc=false;
String LNCollbSpace="";
String LogicalNodeName="";
Calendar cal = Calendar.getInstance();
SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
//sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
String docSuffix = sdf.format(cal.getTime());
SimpleDateFormat Titlesdf = new SimpleDateFormat("yyyyMMdd");
String docTimeStamp=Titlesdf.format(cal.getTime());
System.out.println(" docSuffix :   "+docSuffix);
// Date format 10/20/2017
SimpleDateFormat sdfCheckDate = new SimpleDateFormat("M/d/yyyy");
String checkDate=sdfCheckDate.format(cal.getTime());

String sObjType = PropertyUtil.getSchemaProperty(context, "type_Document");
String LogicalNodeID = emxGetParameter(request, "parentOID");
String prodConfigID="";
System.out.println("LogicalNodeID "+LogicalNodeID);
DomainObject doLogicalNode = DomainObject.newInstance(context, LogicalNodeID);
//rowID = relId|objectId|parentId|rowId - using the tableRowId
 String arrTableRowIds= emxGetParameter(request, "emxTableRowId");
String[] arrTableIDs=arrTableRowIds.split("\\|");
		
		System.out.println("arrTableIDs length "+arrTableIDs.length);
if(arrTableIDs.length > 2 )
	 prodConfigID=arrTableIDs[1];

if(doLogicalNode !=null ) {
LogicalNodeName=doLogicalNode.getInfo(context, "name");
logicalNodeEnt="PLM2ACOMIS|"+LogicalNodeName+"|";
 LNCollbSpace=doLogicalNode.getInfo(context, "project");
System.out.println("logicalNodeEnt  "+logicalNodeEnt);
} else {
	processerror=true;
}

DomainObject doProdConfig = DomainObject.newInstance(context, prodConfigID);
String PCName=doProdConfig.getInfo(context, "name");
if(doProdConfig != null ) {
	ProdConfigEnt=doProdConfig.getInfo(context, "type")+"|"+PCName+"|"+doProdConfig.getInfo(context, "revision");
	System.out.println("ProdConfigEnt  "+ProdConfigEnt);
} else {
	processerror=true;
}

String docTitle=logicalNodeEnt+ProdConfigEnt+"|"+docTimeStamp;
String searchTitle=logicalNodeEnt+ProdConfigEnt+"|";
System.out.println("docTitle  "+docTitle);
StringList objSelects = new StringList();
		objSelects.addElement(DomainConstants.SELECT_ID);
		objSelects.addElement(DomainConstants.SELECT_NAME);
		objSelects.addElement(DomainConstants.SELECT_REVISION);
		objSelects.addElement(DomainConstants.SELECT_CURRENT);
		objSelects.addElement("attribute[Title]");
		objSelects.addElement("originated");
String docWhereClause = "attribute[Title] ~= '"+searchTitle+"*'  " ;
//String docWhereClause = "current == FROZEN ||  current == IN_WORK " ;
 MapList mlDocs = null;   
    

	try {
		mlDocs =(MapList) DomainObject.findObjects(context,sObjType,DomainConstants.QUERY_WILDCARD,docWhereClause,objSelects);
		Map mpObjInfo = null;
		String finalobjID 	 ="";
		String finaldocName ="";
		String finaldocRev	 ="";
		String finalstate 	 ="";
		String finalexTitle	 ="";
		 if(mlDocs.size() > 0 ) {
			System.out.println(" Doc found "+mlDocs.size());
			boolean isdocFound=false;
			for(int k=0;k<mlDocs.size();k++) {
				mpObjInfo = (Map)mlDocs.get(k);
				String objID = (String) mpObjInfo.get(DomainConstants.SELECT_ID);
				String exdocName = (String) mpObjInfo.get(DomainConstants.SELECT_NAME);
				String exdocRev = (String) mpObjInfo.get(DomainConstants.SELECT_REVISION);
				String obstate = (String) mpObjInfo.get(DomainConstants.SELECT_CURRENT);
				String exTitle = (String) mpObjInfo.get("attribute[Title]");
				String exOriginated = (String) mpObjInfo.get("originated");
				if(obstate.equals("FROZEN") || obstate.equals("IN_WORK") || ( obstate.equals("RELEASED") && exOriginated.contains(checkDate) ) ) {
					System.out.println(" Existing candidate document found, should not allow to create a new doc again");
					isdocFound=true;
					finalobjID=objID;
					finaldocName =exdocName;
					finaldocRev	=exdocRev;
					finalstate 	= obstate;
					finalexTitle=exTitle;
				} else {
					System.out.println(" Not today's doc");
					continue;
				}
			}
			if(isdocFound) {
				if (finalstate.equals("FROZEN")){
					outputMessage="A request "+finaldocName+ "-"+finaldocRev+" is already submitted with same Logical Node and Product Conf for processing and not yet completed ";
				} else if(finalstate.equals("IN_WORK")) {
					outputMessage="A Failed request "+finaldocName+ "-"+finaldocRev+" is already  exists with same Logical Node and Product Conf for processing which can be resubmitted";
					DomainObject docObject = DomainObject.newInstance(context, finalobjID);
					docObject.setState(context, "FROZEN");
					docObject.close(context);
					System.out.println(" Today you hav already created one document "+finalstate);
				} else if( (finalstate.equals("RELEASED") ) && (finalexTitle.endsWith(docTimeStamp)) ) {
					outputMessage="A request  "+finaldocName+ "-"+finaldocRev+" is already submitted with same Logical Node and Product Conf and processed successfully. Only one request can be submitted in a day";
					System.out.println(" Today you hav already created one document "+finalstate);
				} else if( (finalstate.equals("RELEASED") ) && (!finalexTitle.endsWith(docTimeStamp)) ) {
					System.out.println(" creating new docu, Prev Doc found and Released and Not today's document  "+finalstate);
					creatnewDoc=true;
				} else {
					System.out.println(" Document found but not in FROZEN, IN_WORK, RELEASED state");
					outputMessage="A request  "+finaldocName+ "-"+finaldocRev+" is already submitted with same Logical Node and Product Conf and is in Incorrect state: "+finalstate;
				}
				System.out.println(" Doc found : outputMessage  "+outputMessage);
			}else {
				creatnewDoc=true;
			}
			
			
		} else {
			System.out.println(" Doc not found ");
			creatnewDoc=true;
		}
		if(creatnewDoc) {
			//OK to proceed with Document creation
			System.out.println(" creating new document");
			//Modified  Placeholder object Name for Evolution PLM2ACOMIS v1.1
			String docName="PLM2ACOMIS_"+LogicalNodeName+"_"+PCName+"_"+docSuffix;
			String sActualRole = context.getRole();	
			String sContext = sActualRole.replaceFirst("ctx::", "");          
			String[] asContext = sContext.split("\\.");		
			String strContextOrganization = asContext[1];
			//String strOrgAlstom= PropertyUtil.getSchemaProperty(context, "organization_Alstom");
			String strContextCollabSpace = asContext[2];
			String sObjRev = "-";
			String sObjPolicy = PropertyUtil.getSchemaProperty(context, "policy_Document");
			String sVaulteServiceProd = PropertyUtil.getSchemaProperty(context, "vault_eServiceProduction");
			DomainObject doPlaceHolder = null;
			doPlaceHolder = DomainObject.newInstance(context);
			doPlaceHolder.createObject(context,sObjType,docName,sObjRev,sObjPolicy,sVaulteServiceProd);
			doPlaceHolder.setAttributeValue(context,DomainConstants.ATTRIBUTE_TITLE,docTitle);	
			doPlaceHolder.setOrganizationOwner(context, strContextOrganization);
			doPlaceHolder.setProjectOwner(context, LNCollbSpace);
			doPlaceHolder.setDescription(context,"Awaiting for ACOMIS batch Job");
			doPlaceHolder.setState(context, "FROZEN");
			outputMessage="Document "+docName+" "+sObjRev+ " submitted for ACOMIS Export";
			System.out.println(" Doc created :"+docName +" outputMessage  "+outputMessage);
			doPlaceHolder.close(context);
		}
	} catch (FrameworkException e) {
			e.printStackTrace();
			System.out.println("Exception in creating Document for ACOMIS "+e.getMessage());
		%> 
			<script language="javascript">
					alert("Exception in creating Document for ACOMIS EXPORT <%=e.getMessage()%>");
				</script> <% 
				System.out.println(" END  AT_C_ENCExportACOMISPostProcess ");
	} 
	%>


<script language="javascript">
	var vStatus = "<%=outputMessage%>";
	if(vStatus != null && vStatus != ""){
		alert(vStatus);
	}
	top.close();
</script>

