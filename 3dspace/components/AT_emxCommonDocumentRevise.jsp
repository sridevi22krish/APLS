<%--  emxCommonDocumentRevise.jsp   -

   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDocumentRevise.jsp.rca 1.14 Wed Oct 22 16:18:27 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  //get document Id
  String[] oids = emxGetParameterValues(request, "emxTableRowId");
  String objectId = emxGetParameter(request, "objectId");
// Added for 368104
    String oldobjectId = objectId;
  String strCopyFiles = emxGetParameter(request, "copyFiles");
  String nextRev = emxGetParameter(request, "nextRev");
  
  //added for bug 344195
  boolean isRevised = false;

  // User can reach this page in two ways,
  // One thru Document Summary page, where multiple rows can be selected for revise
  // Two thru Document properties page, in this case ONLY objectId will be passed
  if( oids == null)
  {
    oids = new String[]{objectId};
  }

  if( oids != null)
  {
    Map objectMap = UIUtil.parseRelAndObjectIds(context, oids,false);
    oids = (String[])objectMap.get("objectIds");
    boolean copyFiles = Boolean.parseBoolean(strCopyFiles);
    try
    {
      for (int i=0; i<oids.length; i++ )
      {
          //build business object/open/unlock/close
          String oid = oids[i];

          CommonDocument commonDocument = (CommonDocument)DomainObject.newInstance(context,oid);
          String strIsVCDoc = commonDocument.getInfo(context,CommonDocument.SELECT_IS_KIND_OF_VC_DOCUMENT);
          if (strIsVCDoc != null && strIsVCDoc.equalsIgnoreCase("true"))
          {
            BusinessObject lastRev = commonDocument.getLastRevision(context);
            BusinessObject newbo = lastRev.revise(context,lastRev.getNextSequence(context),lastRev.getVault());
            commonDocument.setId(newbo.getObjectId());
          }
          else {
              commonDocument = commonDocument.revise(context, nextRev, copyFiles);
              objectId = commonDocument.getObjectId();
			 
			 //Start - AT Customization REQ11.018_US02
			  if(UIUtil.isNotNullAndNotEmpty(objectId)){
				  DomainObject doReviseDocument = DomainObject.newInstance(context,objectId);
				  if(doReviseDocument.isKindOf(context, PropertyUtil.getSchemaProperty("type_AT_C_DOCUMENT"))){
					  String sRendition = doReviseDocument.getInfo(context, "attribute["+PropertyUtil.getSchemaProperty("attribute_AT_C_Rendition")+"]");
					  
					  if(UIUtil.isNotNullAndNotEmpty(sRendition) && sRendition.equalsIgnoreCase("FALSE")){
						//invoke jpo to handle the files copy on new revision
						HashMap hmParam = new HashMap();
						hmParam.put("objectId",objectId);
						String initargs[] = {};
						JPO.invoke(context, "emxPart", initargs, "replicateOnlyNonRenderedFiles", JPO.packArgs(hmParam), String.class);
					  }
				  }
			  }
			  //End - AT Customization REQ11.018_US02
          }
          isRevised = true;		  
     }
    } catch (Exception ex)
    {
        session.setAttribute("error.message" , ex.toString());
    }
  }
%>
<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" >
function replaceObjectId(strHref,newObjectId)//function Added for Bug : 373517
{
        var stringIndex = strHref.indexOf("objectId=");     
        var startString = strHref.substring(0,stringIndex);
        var endString = strHref.substring(stringIndex,strHref.length);
        stringIndex = endString.indexOf("&");
        if (stringIndex>0)
        {
            endString = endString.substring(stringIndex,endString.length); 
        }
        else
        {
            endString = "";
        }
        strHref = startString+"objectId="+newObjectId+endString;
return strHref;
}
</script>
<script language="Javascript" >
  var frameContent = openerFindFrame(getTopWindow(),"detailsDisplay");
  var contentFrame = openerFindFrame(getTopWindow(), "content");
  //To update the count
  updateCountAndRefreshTree("<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>", getTopWindow());  
  if(contentFrame && contentFrame.document.location.href.indexOf("emxTree.jsp") >= 0){
	   //refresh complete tree
	   contentFrame.document.location.href = replaceObjectId(contentFrame.document.location.href,'<%=XSSUtil.encodeForJavaScript(context, objectId)%>');
   } else {   
      frameContent.document.location.href = frameContent.document.location.href;
		if(getTopWindow().opener && getTopWindow().opener.getTopWindow().RefreshHeader){
			getTopWindow().opener.getTopWindow().RefreshHeader();      
		}else if(getTopWindow().RefreshHeader){
			getTopWindow().RefreshHeader();     
		}
   }
    
</script>

</body>
</html>
<%
   // } //check if doc Id is null
%>
