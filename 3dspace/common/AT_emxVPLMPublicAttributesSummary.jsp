<%--  emxVPLMPublicAttributesSummary.jsp   -   page for Public attributes of VPLMEntities
   Copyright (c) 1992-2007 Dassault Systemes.
 
-- Wk 48 : delivery V6R2011 : use of common VPLMJWebToolsThumbnail:getThumbnailPath for thumbnail display
-- Wk 10 2011 : RI 94980 . Manage case of emxTableRowId with relId | objId
-- Wk 14 2011 : RI 85127 . Management of enum
-- Wk 28 2011 : HF-119110V6R2011x_ . Handle correctly enum
-- Wk 14 2011 : RI 85127 . Management of enum
-- Wk38 2011 - RCI - RI  RI 115025 - 127965  - MyCtx
-- Wk48 2011 - RCI - RI 143872 - Contexte unique en utilisant registerContext
-- Wk 48 : delivery V6R2011 : use of common VPLMJWebToolsThumbnail:getThumbnailPath for thumbnail display
-- Wk 10 2011 : RI 94980 . Manage case of emxTableRowId with relId | objId
-- Wk 14 2011 : RI 85127 . Management of enum
-- Wk38 2011 - RCI - RI  RI 115025 - 127965  - MyCtx
-- Wk02 2012 - RCI - RI 146552 - Ctx Mgt
-- Wk11 2012 - RCI - RI 158198 -  Reprise pour "Transaction Aborted"
-- Wk11 2012 - RCI - RI 158969 -  formatRowId
-- Wk34 2012 - RCI - RI 178053 - filtering attributes ( dejà corrigé en 210 sur le RI 132961)
-- Wk38 2012 - RCI - RI 187876 - filtering E_XParam attributes ( version crad ... à reprendre avec l'infra)
-- Wk43 2012 - RCI - manage case of null thumbnails
-- Wk13 2013 - RCI - RI 212187 - Manage SMB states for V_maturity 
-- Wk 48 : delivery V6R2011 : use of common VPLMJWebToolsThumbnail:getThumbnailPath for thumbnail display
-- Wk 10 2011 : RI 94980 . Manage case of emxTableRowId with relId | objId
-- Wk 14 2011 : RI 85127 . Management of enum
-- Wk 28 2011 : HF-119110V6R2011x_ . Handle correctly enum
-- Wk 14 2011 : RI 85127 . Management of enum
-- Wk38 2011 - RCI - RI  RI 115025 - 127965  - MyCtx
-- Wk48 2011 - RCI - RI 143872 - Contexte unique en utilisant registerContext
-- Wk 48 : delivery V6R2011 : use of common VPLMJWebToolsThumbnail:getThumbnailPath for thumbnail display
-- Wk 10 2011 : RI 94980 . Manage case of emxTableRowId with relId | objId
-- Wk 14 2011 : RI 85127 . Management of enum
-- Wk38 2011 - RCI - RI  RI 115025 - 127965  - MyCtx
-- Wk02 2012 - RCI - RI 146552 - Ctx Mgt
-- Wk11 2012 - RCI - RI 158198 -  Reprise pour "Transaction Aborted"
-- Wk11 2012 - RCI - RI 158969 -  formatRowId
-- Wk34 2012 - RCI - RI 178053 - filtering attributes ( dejà corrigé en 210 sur le RI 132961)
-- Wk38 2012 - RCI - RI 187876 - filtering E_XParam attributes ( version crad ... à reprendre avec l'infra)
-- Wk43 2012 - RCI - manage case of null thumbnails
-- Wk22 2013 - RCI - RI 202511 - Reprise gestion ctx : remplacer getMainContext par getFrameContext
-- Wk30 2013 - RCI - RI 220395 - Gestion Hidden
-- Wk47 2013 - QBQ - RI 255820 - Translation of attributes
-- Wk38 2014 - RCI - RI 187876 - filtering E_XParam attributes owned by interfaces ( and no more types ... )
-- Wk08 2016 - VZB - IR 421935 - Retreiving the value of Extension Attributes
--%>
<%@ page import = "java.util.Set" %>
<%@ page import = "java.util.List" %>
<%@ page import = "java.text.DateFormat" %>
<%@ page import = "java.text.SimpleDateFormat"%>

<%@ page import = "matrix.db.*" %>
<%@ page import = "com.matrixone.fcs.common.ImageRequestData" %>

<%@ page import = "com.dassault_systemes.vplm.productNav.interfaces.IVPLMProductNav" %>
<%@ page import = "com.dassault_systemes.vplm.interfaces.access.IPLMxCoreAccess" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.PLMCoreModelerSession" %>
<%@ page import = "com.dassault_systemes.vplm.data.service.PLMIDAnalyser"%> 
<%@ page import = "com.dassault_systemes.vplm.data.PLMxJResultSet"%> 
<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMJWebToolsThumbnail"%> 
<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMJWebToolsM1Util "%>
<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMDebugUtil"%>
<%@ page import = "com.dassault_systemes.vplm.dictionary.PLMDictionaryServices"%>
<%@ page import = "com.dassault_systemes.VPLMJCommonUIServices.VPLMJCommonUIDicoServices"%>

<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMJWebToolsM1Util" %>

<%@ page import = "com.dassault_systemes.iPLMDictionaryCoreItf.IPLMDictionaryCoreItf" %>
<%@ page import = "com.dassault_systemes.iPLMDictionaryCoreItf.IPLMDictionaryCoreClassItf" %>
<%@ page import = "com.dassault_systemes.iPLMDictionaryCoreItf.IPLMDictionaryCoreAttributeItf" %>
<%@ page import = "com.dassault_systemes.iPLMDictionaryCoreItf.IPLMDictionaryCoreFactory" %>
<%@ page import = "com.dassault_systemes.iPLMDictionaryCoreItf.IPLMDictionaryCoreAccessUtil" %>

<%@include file = "emxUIConstantsInclude.inc"%>    
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>    


<head>
  <title>Basic Information</title>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStylePropertiesInclude.inc"%>  
</head>
<%
    out.println("<body bgcolor=\"#E7EEF2\">");
	out.println("<p style=\"font-family:verdana;font-size:0.8em;\">");


	// Gets context, session - Manage Transaction
	// ------------------------------------------
	Context frameCtx = Framework.getFrameContext(session); 
	try
	{
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);

	String role = frameCtx.getRole();
	String lang = (String)context.getSession().getLanguage();
    boolean isStartedByMe = false;
   
    frameCtx.setApplication("VPLM"); // transaction Mgt  - RI 146552
    VPLMJWebToolsM1Util  instM1UtilTools  =  VPLMJWebToolsM1Util.getM1UtilInstance();  
    isStartedByMe = instM1UtilTools.prepareContext(frameCtx);

	
    // VPM APIs Access ..
    // ------------------
    PLMCoreModelerSession plmSession = VPLMJWebToolsM1Util.initializeM1SessionParameters(frameCtx, requestMap);

    try {
	plmSession.openSession();

	IPLMxCoreAccess _coreAccess=plmSession.getVPLMAccess(); 
   	IVPLMProductNav product = (IVPLMProductNav)plmSession.getModeler("com.dassault_systemes.vplm.productNav.implementation.VPLMProductNav");

   	// From M1 Id to VPLM Id ( cleaned from "|" ...")
    // ------------------------------------------------
	
    // From Id M1 ...
    String rmbId = (String) requestMap.get("emxTableRowId");
	String rmbObj = rmbId;
	rmbObj = instM1UtilTools.formatRowId(rmbObj); // RI 94980
	
	List m1idList = new ArrayList(1);
	m1idList.add(rmbObj);
    
    // Selection thru Contextual menu => we get emxTableRowId
    // Selection thru Tree => we get objectId 
    if (1==m1idList.size() && null == m1idList.get(0))
    {
      m1idList.remove(0);
      m1idList.add((String) requestMap.get("objectId"));
    }
  
    // ... to VPLM Id
    String[] plmidArray = ((IVPLMProductNav) product).getPLMObjectIdentifiers(m1idList);
    String CustoType = PLMIDAnalyser.getTypeName(plmidArray[0]);  // get Custo / Type
    int CustoTypeLength = CustoType.length() ;
    
    // GetProperties => gets all VPLM Properties
    // ------------------------------------------

    PLMxJResultSet plmxresult =_coreAccess.getProperties(plmidArray[0]);
    if (null == plmxresult) 
		throw new Exception("emxVPLMPublicAttributesSummary : plmxresult null");
	

    // Properties to display
    // -----------------------    
	String formattedAttributeValue;
	String plmType = CustoType.substring(CustoType.indexOf("/")+1, CustoType.length());
	
	String TableName=(String)plmxresult.getTableName();  // name of the queried table
 
    out.println("<table border=\"0\" width=\"100%\" cellpadding=\"5\" cellspacing=\"2\">");
    while(plmxresult.next()) 
      {
      
      //QBQ IR-255820V6R2014x Replaced Old code with new in which attributes will be translated.
	   
	    
		//HashMap<String, String> dicoAttributes = VPLMJCommonUIDicoServices.translateDicoAttributes(context, plmType, lang);
HashMap<String, String> dicoAttributes = VPLMJCommonUIDicoServices.translateDicoAttributes(frameCtx, plmType, lang);
		//First print PLM_ExternalID
		String shortNameExternalID = "PLM_ExternalID";
		String translatedAttributeName = dicoAttributes.get(shortNameExternalID);
		Object value = plmxresult.getRowValue(TableName + "." + shortNameExternalID);
      // formattedAttributeValue = VPLMJCommonUIDicoServices.formatValue(context, "emxFramework", plmType, shortNameExternalID, value, lang);
	  formattedAttributeValue = VPLMJCommonUIDicoServices.formatValue(frameCtx, "emxFramework", plmType, shortNameExternalID, value, lang);
		out.println("<tr><td class=\"label\">" + translatedAttributeName + "</td>");
		out.println("<td class=\"field\">" + formattedAttributeValue + "</td>");
		
		for (String shortName : dicoAttributes.keySet())
		{
			try
			{
				if (shortName.equals("PLM_ExternalID"))
				{
					//already handled
					continue;
				}
				
				//Start - Redmine:6877 [No need to display AT_UNSPSC_Code attribute as it is depricated]
				if (shortName.equals("AT_UNSPSC_Code"))
				{
					continue;
				}
				//End - Redmine:6877

				translatedAttributeName = dicoAttributes.get(shortName);
				value = plmxresult.getRowValue(TableName + "." + shortName);
				 //System.out.println (" traces ..., direct attribute :"+shortName+" value BEFORE formatting:  "+value);
				 //System.out.println ("traces ..., TRANSLATED  attribute :"+translatedAttributeName+" value BEFORE formatting:  "+value);
				//formattedAttributeValue = VPLMJCommonUIDicoServices.formatValue(context, "emxFramework", plmType, shortName, value, lang);
				formattedAttributeValue = VPLMJCommonUIDicoServices.formatValue(frameCtx, "emxFramework", plmType, shortName, value, lang);
				//System.out.println (" traces ... , TRANSLATED attribute : "+translatedAttributeName+" value AFTER formatting:  "+formattedAttributeValue);
				
				out.println("<tr><td class=\"label\">" + translatedAttributeName + "</td>");
				out.println("<td class=\"field\">" + formattedAttributeValue + "</td>");
			}
			catch (Exception e)
			{
				out.println("<tr><td class=\"label\">" + shortName + "</td>");
				out.println("<td class=\"field\">" + "xxx" + "</td>");
			}
		}
		
		
		out.println("</tr>");
      //QBQ 
      
  	// Thumbnails Management
	// ---------------------
    try {
               
    	String objectId = (String) requestMap.get("objectId");
    	String sHtmlOutput = null;
    	
    	VPLMJWebToolsThumbnail webThumbTools = VPLMJWebToolsThumbnail.getThumbnailToolInstance();
    	if (webThumbTools != null )
    		sHtmlOutput = webThumbTools.getThumbnailPath(frameCtx, requestMap,objectId );
        if (sHtmlOutput != null && sHtmlOutput.length() > 0)
        {
             StringBuffer imgBuffer = new StringBuffer();
             imgBuffer.append("<div align=\"left\">")
			          .append("<img src=\"")
        		      .append(sHtmlOutput)
                      .append("\" border=\"0\" height=\"128\"")  
                      .append("/>")
                      .append("</div>");
 
      		if (null != sHtmlOutput) sHtmlOutput = imgBuffer.toString();
      	}

   		if (null != sHtmlOutput) out.println(sHtmlOutput);
         		
   	   }
       catch (MatrixException me)
       {
          me.printStackTrace();
       }
  }// end of while

   
   // RCI - IR 187876 - Attributes on interfaces ...
	String[] oidList = new String[1];
    String M1Id = (String) requestMap.get("objectId");
	oidList[0] = M1Id;
   
	StringList selectStmts = new StringList();
	selectStmts.add("interface");
		
	BusinessObject busObj = new BusinessObject(M1Id);
//	BusinessObjectWithSelectList bows = busObj.getSelectBusinessObjectData(context, oidList, selectStmts);
	BusinessObjectWithSelectList bows = busObj.getSelectBusinessObjectData(frameCtx, oidList, selectStmts);
	
	for (BusinessObjectWithSelectItr iter = new BusinessObjectWithSelectItr( bows ); iter.next(); )
	{
    	final BusinessObjectWithSelect bws = iter.obj(); 
	
		List<String> AttrValues = new ArrayList<String>();
		//List ListItfAttr = VPLMJCommonUIDicoServices.M1Itf2AttrNameValue( context, bws, AttrValues, lang);   
		List ListItfAttr = VPLMJCommonUIDicoServices.M1Itf2AttrNameValue( frameCtx, bws, AttrValues, lang);
	    for( int keyIndex = 0; keyIndex < ListItfAttr.size(); keyIndex++)
        {  
			String ExtAttrName = (String) ListItfAttr.get(keyIndex);      //Extension Name + Attribute Name
			String AttrdefaultValue = (String) AttrValues.get(keyIndex);  // Attribute Default Value
			
			int endIdx = ExtAttrName.indexOf(".");
			String ExtName=ExtAttrName.substring(0, endIdx);    // Extension Name							
			String AttrName = ExtAttrName.substring(endIdx+1);	// Attribute Name
			
			String AttrNlsName = "";
            String AttrValue = "";			
			try
			{
				AttrNlsName = VPLMJCommonUIDicoServices.translateInterfacesAttribute(ExtName, AttrName, lang); // get translated attribute name is available
				
				Attribute Attr = busObj.getAttributeValues(frameCtx, ExtAttrName); // get attribute value set by user
                AttrValue = Attr.getValue();				
               
			}
			catch(Exception me)
			{
				me.printStackTrace();				
			}
	
            if(null == AttrNlsName || AttrNlsName.isEmpty() || AttrNlsName.equals(""))
				AttrNlsName = AttrName;
				
			if(null == AttrValue || AttrValue.isEmpty() || AttrValue.equals(""))
				AttrValue = AttrdefaultValue;
                       					
			out.println("<tr><td class=\"label\">" + AttrNlsName + "</td>");  // display attribute name on UI
			out.println("<td class=\"field\">" + AttrValue + "</td>");        //display attribute value on UI
        }
		out.println("</tr>");			
	
	}
	// RCI - 
	
	
	
out.println("</table>");
out.println("</body>");

} catch (Exception me) {
	       if (( me.toString() != null) && (me.toString().trim().length()>0))
    {
		emxNavErrorObject.addMessage ("emxVPLMPublicAttributesSummary: The supplied object is invalid");
	}
	   me.printStackTrace();
} finally {
		if (plmSession != null) {
			try {
				 // transaction, session Mgt 
			    // --------------------------
				plmSession.closeSession(true);
				//instM1UtilTools.postProcessContext(context, isStartedByMe);
				instM1UtilTools.postProcessContext(frameCtx, isStartedByMe);
				
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}
finally
{
	frameCtx.shutdown();
}
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>




