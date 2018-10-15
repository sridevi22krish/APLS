<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program
   modified as part of ALSTOM customization
   static const char RCSID[] = $Id: emxLibraryCentralObjectsDeleteProcess.jsp.rca 1.17 Wed Oct 22 16:02:24 2008 przemek Experimental przemek $
   Modification History
   --------------------
   Suresh S; 31-Aug-2017; Modifed for Redmine 6532.
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<%@ page import = "matrix.db.*, matrix.util.*,
				   com.matrixone.util.*,
				   com.matrixone.servlet.*,
				   com.matrixone.apps.framework.ui.*,
				   com.matrixone.apps.domain.util.*,
				   com.matrixone.apps.domain.*,
				   java.util.*,
				   java.io.*,
				   java.util.*,
				   com.matrixone.jsystem.util.*"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript">

</script>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>

<%
    String callPage             = emxGetParameter(request, "callPage");
    String emxTableRowIds[]     =(String[]) emxGetParameterValues(request, "emxTableRowId");
    String sGenericDocument     = LibraryCentralConstants.TYPE_GENERIC_DOCUMENT;
    String sDocument            = LibraryCentralConstants.TYPE_DOCUMENT;
    String sPart                = LibraryCentralConstants.TYPE_PART;
    String sDocumentSheet       = LibraryCentralConstants.TYPE_DOCUMENT_SHEET;
    String sFolder              = LibraryCentralConstants.TYPE_WORKSPACE_VAULT;
    String stdMsg               = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(sLanguage),"emxDocumentCentral.Deleted.NotAbleToDeleteMessage");
    String sLockMsg             = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(sLanguage),"emxDocumentCentral.Deleted.NotAbleToDeleteLockedObjectMessage");
    String sType                = null;
    Vector vecObjectIds         = new Vector();
    Vector vecLockedObjects     = new Vector();
	//Added for Redmine 6532.
    final String MCM_STRING_RESOURCE = "emxLibraryCentralStringResource";
    String strLanguage = request.getHeader("Accept-Language");
    String strMessage = EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,new Locale(strLanguage),"emxMultipleClassification.RemoveClassification.blockMessage");
	//Added for Redmine 6532.
    boolean isLocked            = false;

    StringBuffer sbErrorObjMsg  = new StringBuffer();
    StringBuffer sbLockedObjMsg = new StringBuffer();
    StringBuffer sbFinalErrMsg  = new StringBuffer();
    StringBuffer responseXML    = new StringBuffer();
    if(callPage == null) {
        callPage = "emxTable";
    }

    Map levelIdMap      = new HashMap();
    responseXML.append("<mxRoot>");
    responseXML.append("<action>remove</action>");
    // if coming from a configurable table we need to get the object id
    // out of the object id / relationship pair
    String []objIds     = getTableRowIDsArray(emxTableRowIds);
    if(objIds != null) {
        for(int i = 0; i < objIds.length; i++) {
            vecObjectIds.addElement(objIds[i]);
            StringTokenizer strTokens = new StringTokenizer(emxTableRowIds[i],"|");
            while (strTokens.hasMoreTokens()) {
                levelIdMap.put(objIds[i], strTokens.nextToken());
            }
        }
    }
    
    try {
        if (objIds.length > 0) {
            DomainObject domObj         = DomainObject.newInstance(context);
            StringBuffer sbLockedSelect = new StringBuffer();

            sbLockedSelect.append("relationship[");
            sbLockedSelect.append(com.matrixone.apps.common.CommonDocument.RELATIONSHIP_ACTIVE_VERSION);
            sbLockedSelect.append("].to.locked");

            StringList  selDocumentList = new StringList();
            selDocumentList.add(DomainObject.SELECT_TYPE);
            selDocumentList.add(DomainObject.SELECT_NAME);
            selDocumentList.add(sbLockedSelect.toString());
            selDocumentList.add(com.matrixone.apps.common.CommonDocument.SELECT_VCFILE_LOCKED);
            selDocumentList.add(DomainObject.SELECT_LOCKED);
            selDocumentList.add(DomainObject.SELECT_CURRENT);

            for (int i = 0; i < objIds.length; ++i) {
                String objectId     = objIds[i];
                domObj.setId(objectId);
                Map resultMap       = domObj.getInfo(context, selDocumentList);
                String docLocked    = (String)resultMap.get(sbLockedSelect.toString());
                String objectLocked = (String)resultMap.get(DomainObject.SELECT_LOCKED);
                String vcDocLocked  = (String)resultMap.get(com.matrixone.apps.common.CommonDocument.SELECT_VCFILE_LOCKED);
                isLocked            = (!UIUtil.isNullOrEmpty(docLocked) && docLocked.indexOf("TRUE") != -1)||
                                        (!UIUtil.isNullOrEmpty(vcDocLocked) && (vcDocLocked.equalsIgnoreCase("TRUE")))||
                                        (!UIUtil.isNullOrEmpty(objectLocked) && (objectLocked.equalsIgnoreCase("TRUE")));
                sType               = (String)resultMap.get(DomainObject.SELECT_TYPE);

                String sState       = (String)resultMap.get(DomainObject.SELECT_CURRENT);
                String sActiveState = LibraryCentralConstants.STATE_DOCUMENT_SHEET_ACTIVE;

                try {
                    if (isLocked) {
                        sbLockedObjMsg.append("\n").append(sType).append (" ").
                        append((String)resultMap.get(DomainObject.SELECT_NAME));
                        vecObjectIds.removeElement(objectId);
                    } else {
                        if(sType != null && (sType.equalsIgnoreCase(sGenericDocument) || sType.equalsIgnoreCase(sDocument))){
                            com.matrixone.apps.common.CommonDocument.deleteDocuments(context,new String[]{objectId});
                        } else if (sType.equalsIgnoreCase(sDocumentSheet) && sState.equalsIgnoreCase(sActiveState)) {
                            sbErrorObjMsg.append("\n").append(i18nNow.getAdminI18NString("Type", sType, sLanguage)).append (" ").
                            append((String)resultMap.get(DomainObject.SELECT_NAME));
                            vecObjectIds.removeElement(objectId);
                        } else {
                            BusinessType businessType = new BusinessType(sType, context.getVault());
                            String strParentType       = businessType.getParent(context);
                            String strReturn    = null;
                            if(strParentType != null && strParentType.equalsIgnoreCase(LibraryCentralConstants.TYPE_LIBRARIES)) {
                                Libraries LcObj         =(Libraries)DomainObject.newInstance(context,objectId,LibraryCentralConstants.LIBRARY);
                                strReturn    = LcObj.deleteObjects(context);
                            } else if(strParentType != null && (strParentType.equalsIgnoreCase(LibraryCentralConstants.TYPE_CLASSIFICATION) || strParentType.equalsIgnoreCase(PropertyUtil.getSchemaProperty(context, "type_AT_C_GeneralClass")) )) {
								//modified as part of ALSTOM customization for REQ01.005_US01 - start
								//modified as part of ALSTOM customization for 6532 Redmine - start
								//General Class/Branch Class will not be able to be deleted in case there are classified items/subclasses attcahed to it 
								if(sType != null && (sType.equalsIgnoreCase(PropertyUtil.getSchemaProperty(context, "type_AT_C_GeneralClass")) || sType.equalsIgnoreCase(PropertyUtil.getSchemaProperty(context, "type_AT_C_UNSPSC_BranchClass")) ) ){
									DomainObject doGC = DomainObject.newInstance(context, objectId);
									
									StringList selectStmts = new StringList(4);
								   selectStmts.addElement(DomainConstants.SELECT_ID);
								   selectStmts.addElement(DomainConstants.SELECT_TYPE);
								   selectStmts.addElement(DomainConstants.SELECT_NAME);
								   selectStmts.addElement(DomainConstants.SELECT_REVISION);
								   StringList selectRelStmts = new StringList(1);
								   selectRelStmts.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);

								   StringBuffer sbRelationships = new StringBuffer();
								   sbRelationships.append(PropertyUtil.getSchemaProperty(context, "relationship_ClassifiedItem")).append(",").append(PropertyUtil.getSchemaProperty(context, "relationship_Subclass"));
								   MapList connectedCIs = doGC.getRelatedObjects(context,
										   sbRelationships.toString(),// relationship pattern
										   DomainConstants.QUERY_WILDCARD, // object pattern
										   selectStmts, // object selects
										   selectRelStmts, // relationship selects
										   false, // to direction
										   true, // from direction
										   (short) 1, // recursion level
										   null, // object where clause
										   null); // relationship where clause
									
									if(connectedCIs.size()>0){
										sbErrorObjMsg.append("Cannot delete a General Class with Classified Items/Subclasses associated to it");
										strReturn = "false";
									}else{
										if (sState.equalsIgnoreCase(sActiveState)) {
											sbErrorObjMsg.append("\n");
											sbErrorObjMsg.append(strMessage);
											strReturn = "false";
										} else {
										doGC.delete(context);
										strReturn = "true";
										}										}
									//modified as part of ALSTOM customization for 6532 Redmine - end
								}else{
									Classification LcObj    =(Classification)DomainObject.newInstance(context,objectId,LibraryCentralConstants.LIBRARY);
									strReturn    = LcObj.deleteObjects(context);
								}
								//modified as part of ALSTOM customization for REQ01.005_US01 - end
                            } else if(sType != null && sType.equalsIgnoreCase(sPart)) {
                                com.matrixone.apps.library.Part LcObj =(com.matrixone.apps.library.Part)DomainObject.newInstance(context,objectId,LibraryCentralConstants.LIBRARY);
                                strReturn    = LcObj.deleteObjects(context);
                            } else if(sType != null && sType.equalsIgnoreCase(sFolder)) {
								DCWorkspaceVault folderObj = (DCWorkspaceVault)DomainObject.newInstance(context,objectId,LibraryCentralConstants.DOCUMENT);
                            	strReturn    = folderObj.deleteObjects(context);
                            } else {
                                domObj.deleteObject(context);
                            }
                            if(strReturn != null && strReturn.equalsIgnoreCase("false")) {
                                sbErrorObjMsg.append("\n").append(i18nNow.getAdminI18NString("Type", sType, sLanguage)).append (" ").
                                append((String)resultMap.get(DomainObject.SELECT_NAME));
                                vecObjectIds.removeElement(objectId);
                            }
                        }
                    }
                }catch (Exception exp) {
                	exp.printStackTrace();
                    sbErrorObjMsg.append("\n").append(sType).append (" ").
                    append((String)resultMap.get(DomainObject.SELECT_NAME));
                    vecObjectIds.removeElement(objectId);
                }
                
            }//End of for

            if (sbErrorObjMsg.toString().length() > 0) {
                sbFinalErrMsg.append(stdMsg).append(sbErrorObjMsg);
            }
  
            if (sbLockedObjMsg.toString().length() > 0) {
                if(sbFinalErrMsg.toString().length() > 0 ) {
                    sbFinalErrMsg.append("\n\n");
                }
                sbFinalErrMsg.append(sLockMsg).append(sbLockedObjMsg);
            }          
       } // if length() > 0 : there were some selected objects

    } catch (FrameworkException fe) {
        fe.printStackTrace();
    }
    catch(Exception e) {
        
    }
    Iterator itr =  vecObjectIds.iterator();
   // Adding the Item level details for the Deleted Objects
    while ( itr.hasNext() ){
        String objectId = (String)itr.next();
        responseXML.append("<item id='");
        responseXML.append((String)levelIdMap.get(objectId));
        responseXML.append("'/>");
    }
    responseXML.append("</mxRoot>");    
%>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language=javascript>
    var vErrorMsg   = "<xss:encodeForJavaScript><%=sbFinalErrMsg.toString().trim()%></xss:encodeForJavaScript>";
    var iSize       = "<xss:encodeForJavaScript><%=vecObjectIds.size()%></xss:encodeForJavaScript>";
    var vCallPage   = "<xss:encodeForJavaScript><%=callPage%></xss:encodeForJavaScript>";
    if(vErrorMsg != "") {
        alert(vErrorMsg);
    }
    var vStructureTreeObject = getTopWindow().objStructureTree;
    var vDeleteRows = <xss:encodeForJavaScript><%=vecObjectIds.size()>0%></xss:encodeForJavaScript>;
    if(vDeleteRows) { 
        if(parent.removedeletedRows) {
            var responseXML  = "<xss:encodeForJavaScript><%=responseXML.toString()%></xss:encodeForJavaScript>";
            parent.removedeletedRows(responseXML);
        }
    }
    try {
<%
       int iSize = vecObjectIds.size();
       for (int i = 0; i < iSize; ++i) {
%>
           var childId = '<xss:encodeForJavaScript><%=(String)vecObjectIds.elementAt(i)%></xss:encodeForJavaScript>';
          //following if condition is commented as a fix of IR-169668V6R2013x
          //if (vStructureTreeObject.objects[childId]) {
    	        getTopWindow().deleteObjectFromTrees(childId,true);
          // }
<%
       }
%>
       updateCountAndRefreshTree('<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>',getTopWindow(), false);    
    }catch (ex) {
        getTopWindow().refreshTablePage();
    }
</script>