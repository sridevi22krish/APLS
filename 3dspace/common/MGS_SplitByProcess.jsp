
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUITreeUtil.js"></script>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
String emxTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
String key = emxGetParameter(request,"key");
String relIds ="";
    if(key==null||key.equals("")) //To keep earlier behavior
    {
    	relIds = emxGetParameter(request, "objectId");
    }
    else //To support large data (IR-269245V6R2014x)
    {
    	relIds=(String)session.getAttribute(key);
    }
    if(key!= null)
    {
		  session.removeAttribute("key");
		  key="";
	  }
	
	 
	try
	{
		ContextUtil.startTransaction(context, true);
		String strTableRowId = "";
		StringList relSl = new StringList(new String[] { "frommid[MGS_SplitBy].id"  });
        	StringList slEmxTableRowId = new StringList();
			DomainObject parentObject;
		if(emxTableRowIds != null) {
			for (int i = 0; i < emxTableRowIds.length; i++) {
			
			    strTableRowId = emxTableRowIds[i];
				System.out.println("MGS_SplitbyProcess============= strTableRowId = "+ strTableRowId);
			    slEmxTableRowId = FrameworkUtil.split(strTableRowId, "|");
			    if (slEmxTableRowId.size() > 0) {
				strTableRowId = (String)slEmxTableRowId.get(0);
			     if(relIds != null) {
			    	 StringTokenizer token = new StringTokenizer(relIds,",");
			             while (token.hasMoreTokens())
			             {
			                relIds = token.nextToken().trim();
							System.out.println("MGS_SplitbyProcess============= relIds = "+ relIds);
							MapList infoList = DomainRelationship.getInfo(context, new String[] { relIds }, relSl);
							String relSplitId =(String) ((Map) infoList.get(0)).get("frommid[MGS_SplitBy].id");
							if (!"".equals(relSplitId) && null != relSplitId){
							System.out.println("MGS_SplitbyProcess============= relSplitId = "+ relSplitId);
							MqlUtil.mqlCommand(context, "del connection $1;", relSplitId);
							} 
			               String id = MqlUtil.mqlCommand(context, "add connection $1 fromrel $2 torel $3 select $4 dump;", "MGS_SplitBy", relIds, strTableRowId, "id");
						   
				
		}
		}
 }
 }
        	} else {
			 if(relIds != null) {
			    	 StringTokenizer token = new StringTokenizer(relIds,",");
			             while (token.hasMoreTokens())
			             {
			                relIds = token.nextToken().trim();
							MapList infoList = DomainRelationship.getInfo(context, new String[] { relIds }, relSl);
							String relSplitId =(String) ((Map) infoList.get(0)).get("frommid[MGS_SplitBy].id");
							if (!"".equals(relSplitId) && null != relSplitId){
							MqlUtil.mqlCommand(context, "del connection $1;", relSplitId);
							} 		
		}
		}
			
			}
		ContextUtil.commitTransaction(context);
	}
	catch (Exception excp) {
		ContextUtil.abortTransaction(context);
		throw excp;
	}

%>


<script>

var contentFrame = openerFindFrame (top, "MGS_ENCBOM");
if (contentFrame) {
   contentFrame.refreshRows();
}

  top.close();

</script>
<%


%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
