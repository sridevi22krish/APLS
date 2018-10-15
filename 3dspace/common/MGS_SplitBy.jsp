
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxTagLibInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.requirements.RequirementGroup"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%

boolean isError = false;
try
{

    String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId");
    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    String timeStamp = (String)requestMap.get("timeStamp");
    String objectId = (String)requestMap.get("objectId");
    String searchTypes = null;
    String searchTable = null;
    String excludeProg = null;
    String submitHRef = null;
    String strExpandProgram = null;
    String strSelection = "multiple";
    String strShowSavedQuery = "True";
    String strSearchCollectionEnabled = "True";
    String strCancelLabel = "emxEngineeringCentral.Button.Cancel";
    boolean showCancelButton = true;
    String key="";
    
   
  
    // If a single row is selected, use it as the target ID...
    StringList strList = new StringList();
    ArrayList objectIdList = new ArrayList();
	ArrayList relIdList = new ArrayList();
    StringList parentIDList = new StringList();
    String oid = "";    
	String relid = "";   
    if(tableRowIds != null && tableRowIds.length > 0) 
    {   
       for(int i = 0; i < tableRowIds.length ; i++) 
       {                     
          if(tableRowIds[i].indexOf("|") != -1)
          {
		  System.out.println("MGS_Splitby============= tableRowIds = "+ tableRowIds[i]);
             strList = FrameworkUtil.split(tableRowIds[i], "|");
             if (strList.size() == 3)
             {
                 oid = (String)strList.get(0);
				 relid = (String)strList.get(1);
                 
             }else
             {
			 relid = (String)strList.get(0);
                 oid = (String)strList.get(1);
             }         
          }else
          {
             oid = tableRowIds[i];
          }
		  if (objectId.equals(oid)){
		  isError = true;
		  throw new Exception("CannotSelectRoot");
		  }
		   if (!"".equals(oid) && null != oid){
		  DomainObject obj = new DomainObject(oid);
		  if (!"AT_C_EXPECTED_PRODUCT".equals(obj.getInfo(context, "type"))){
		  throw new Exception("ItemNotSelectable");
		  }
		  }
		  if (!"".equals(relid) && null != relid){
		  DomainRelationship rel = new DomainRelationship(relid);
		  String relMaturity = rel.getAttributeValue(context, "MGS_Inst_Maturity");
		  if ("IN_WORK".equals(relMaturity)){
		  isError = true;
		  throw new Exception("CannotSelectNonReleasedInstance");
		  }
		  relIdList.add(relid);
		  } else {
		  isError = true;
		  throw new Exception("ItemNotSelectable");
		  }
		  
		  
		  
          objectIdList.add(oid);                  
        }      
     }
    
    java.util.Set set = new java.util.HashSet(relIdList);   
    String idsSelected  = "";
    java.util.Iterator itr = set.iterator();
    while(itr.hasNext())
    {
        String id = (String)itr.next();
        idsSelected += id;
        
        if(itr.hasNext())
            idsSelected += ",";
    }
    

    	long number = new Random(System.currentTimeMillis()).nextLong();
    	key = "ToSplit" + System.currentTimeMillis() + "_" + number;
    	session.setAttribute(key, idsSelected.toString());
    	searchTable = "MGS_ENCEBOMIndentedSummarySB";
    
    	submitHRef = "../common/MGS_SplitByProcess.jsp?key="+key;
    	strShowSavedQuery = "True";
        strSelection = "single";
		
    String dialogUrl = "../common/emxIndentedTable.jsp" +
                       "?objectId=" + objectId +
                       "&table=" + searchTable +
                       "&selection=" + strSelection +
                       "&suiteKey=EngineeringCentral" +
					   "&expandProgram=MGS_emxPart:expandObjectListForSplit" +
                       "&cancelButton=" + showCancelButton + 
                       "&cancelLabel=" + strCancelLabel +
                       "&HelpMarker=emxhelppartbom" +                      
                       (submitHRef == null                 || submitHRef.length()                 == 0? "": "&submitURL=" + submitHRef);
%>


<script language="Javascript">    
//   document.ToSplit.action="<xss:encodeForJavaScript><%=dialogUrl%></xss:encodeForJavaScript>";
 //  document.ToSplit.submit();
 window.open("<%=dialogUrl%>", "_blank", "width=1000,height=800");
</script>     
<%
} // End of try
catch (Exception ex)
{
	  String strAlertString = "emxEngineeringCentral.Alert." + ex.getMessage();
    String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), strAlertString);
    if (i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
    {
	%>
	<script language="Javascript">  
        alert("<%=ex.getMessage()%>");
		</script> 
		<%
    }
    else
    {
	%>
		<script language="Javascript">  
        alert("<%=i18nErrorMessage%>");
		</script> 
		<%
    }
	
	
} // End of catch
%>




