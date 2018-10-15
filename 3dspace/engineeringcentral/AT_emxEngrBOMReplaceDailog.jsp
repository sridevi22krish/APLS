<%--  emxEngrBOMReplaceDailog.jsp   -  This page displays a list of parts.
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
   modified as part of ALSTOM - Redmine ticket 6893 - Replace Part in Bom doesn't keep quantity
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "emxengchgJavaScript.js"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@page import="com.matrixone.apps.engineering.Part" %>

<%

    String languageStr = request.getHeader("Accept-Language");
    String objectId   = emxGetParameter(request,"objectId");
    String jsTreeID   = emxGetParameter(request,"jsTreeID");
    String suiteKey   = emxGetParameter(request,"suiteKey");
    String bomInfo    = emxGetParameter(request,"bomInfo");
    String partFamilyContextId   = emxGetParameter(request,"partFamilyContextId");
    String selPartObjectId   = emxGetParameter(request,"selPartObjectId");
    String selPartParentOId    = emxGetParameter(request,"selPartParentOId");
    String createdPartObjId    = emxGetParameter(request,"createdPartObjId");
	String tablemode    = emxGetParameter(request,"tablemode");
    String selPartRelId = emxGetParameter(request,"selPartRelId");
    String relType = emxGetParameter(request,"relType");
	String hideWithBOMSelection = emxGetParameter(request,"hideWithBOMSelection");

    String totalCount = emxGetParameter(request,"totalCount");

    String replaceWithExisting = emxGetParameter(request,"replaceWithExisting");

     Part selPartId = new Part(selPartObjectId);
     String selPartName = selPartId.getInfo(context, "name");
     
     // Added for Part Create conversion to common comp. R211
     String sRowId = emxGetParameter(request,"sRowId");
     System.out.println("REplace Content sRowId ="+sRowId);
     
     
     String createdPartName = "";
     if (!(createdPartObjId == null) && !createdPartObjId.equals("")) {
     Part createdPartId = new Part(createdPartObjId);
     createdPartName = createdPartId.getInfo(context, "name");
  
     }
     
%>

<script language="JavaScript">

  function cancelMethod()
  {
    parent.closeWindow();
  }

  function validateForm()
    {
      var objectId = document.formReplacePart.partFamilyContextId.value;
      var selObjectId = document.formReplacePart.selPartObjectId.value;

      if (objectId == selObjectId) {
      
          alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.CannotReplaceContext</emxUtil:i18nScript>");
          return false;
      }
      return true;
   }
  function doDone()
  {
     var checkedButton = "None checked";
     if(validateForm()) {
         if (document.formReplacePart.radioBOM != null)
         {
         if (1 < document.formReplacePart.radioBOM.length)
         {
             for (i=0;i<document.formReplacePart.radioBOM.length;i++)
             {
                if (document.formReplacePart.radioBOM[i].checked)
                {
                   checkedButton = document.formReplacePart.radioBOM[i].value;
                }
             }
         }
         else
         {
           if (document.formReplacePart.radioBOM.checked)
           {
               checkedButton = document.formReplacePart.radioBOM.value;
           }
         }
         }
       if (checkedButton == "None checked")
       {
            alert("<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.PleaseMakeASelection</emxUtil:i18n>");
         }
         else
         {
            document.formReplacePart.submit();
         }
      }
  }
</script>
<%@include file = "emxEngrStartReadTransaction.inc"%>

<form name="formReplacePart" method="post" action="emxEngrBOMReplaceProcess.jsp" target="_parent" onSubmit="javascript:doDone(); return false">
    <input type="hidden" name="objectId" id="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="jsTreeID" id="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="suiteKey" id="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="partFamilyContextId" id="partFamilyContextId" value="<xss:encodeForHTMLAttribute><%=partFamilyContextId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="selPartObjectId" id="selPartObjectId" value="<xss:encodeForHTMLAttribute><%=selPartObjectId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="selPartParentOId" id="selPartParentOId" value="<xss:encodeForHTMLAttribute><%=selPartParentOId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="createdPartObjId" id="createdPartObjId" value="<xss:encodeForHTMLAttribute><%=createdPartObjId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="selPartRelId" id="selPartRelId" value="<xss:encodeForHTMLAttribute><%=selPartRelId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="tablemode" id="tablemode" value="<xss:encodeForHTMLAttribute><%=tablemode%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="relType" id="relType" value="<xss:encodeForHTMLAttribute><%=relType%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="totalCount" id="totalCount" value="<xss:encodeForHTMLAttribute><%=totalCount%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="replaceWithExisting" id="replaceWithExisting" value="<xss:encodeForHTMLAttribute><%=replaceWithExisting%></xss:encodeForHTMLAttribute>" />
     <!-- Added for Part Create conversion to common comp. R211 --> 
    <input type="hidden" name="sRowId" id="sRowId" value="<xss:encodeForHTMLAttribute><%=sRowId%></xss:encodeForHTMLAttribute>" />
<% try {
     ContextUtil.startTransaction(context, true);
%>
  <form>
  <table border="0" cellspacing="1" cellpadding="0" width="100%">
 
  <!-- Table Columns -->
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Part</emxUtil:i18n></td>
    &nbsp;
    <td class="inputField">
    <!-- XSSOK -->
    <%= selPartName %>
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.DialogField.ReplaceWith</emxUtil:i18n></td>
    &nbsp;
    <td class="inputField">
<%
     if(replaceWithExisting.equals("true") && !totalCount.equals("")) {
     
     String selPartIds[] = (String[])session.getValue("selPartIds");
     Integer count = new Integer(totalCount);

     for (int j=0;j<count.intValue();j++) {
      Part selSearchPartId = new Part(selPartIds[j]);
      String selSearchPartName = selSearchPartId.getInfo(context, "name");
  
%>    
	<!-- XSSOK -->
     <%= selSearchPartName %>,
<%   }
     } else if(!"".equals(createdPartName)) {
%>
	<!-- XSSOK -->
    <%= createdPartName %>
<%
     }
%>
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Action</emxUtil:i18n></td>
    &nbsp;
    <td class="inputField">
      <table>
        <tr class="inputField">
          <td>
            <input type="radio" name="radioBOM" value="replaceWithNoBOM" /><emxUtil:i18n localize="i18nId">emxEngineeringCentral.DialogField.ReplaceWithNoBOM</emxUtil:i18n>
          </td>
        </tr>
        <tr class="inputField">
          <td>
          <%
     if(replaceWithExisting.equals("true") && hideWithBOMSelection.equals("true")){%>
            <input type="radio" name="radioBOM" value="replaceWithExistingBOM" disabled = true /><emxUtil:i18n localize="i18nId">emxEngineeringCentral.DialogField.ReplaceWithExistingBOM</emxUtil:i18n>
        <%} else { %>
        <input type="radio" name="radioBOM" value="replaceWithExistingBOM" /><emxUtil:i18n localize="i18nId">emxEngineeringCentral.DialogField.ReplaceWithExistingBOM</emxUtil:i18n>
        <%} %>
		</td>
       </tr>
      </table>
    </td>
  </tr>
</table>

</form>
<%
        ContextUtil.commitTransaction(context);
      }
      catch(Exception ex)
      {
          
           ContextUtil.abortTransaction(context);
%>
      <%@include file = "emxEngrAbortTransaction.inc"%>
<%
        throw ex;
      }

%>
      <%@include file = "emxEngrCommitTransaction.inc"%>

  <%@include file = "emxDesignBottomInclude.inc"%>
