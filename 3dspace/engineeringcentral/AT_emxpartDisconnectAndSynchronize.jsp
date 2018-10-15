<%--  emxpartDisconnectAndSynchronize.jsp  - To disconnect bom for a part.
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>

<%@page import="matrix.util.MatrixException,com.matrixone.apps.domain.util.SetUtil,java.util.HashMap,java.util.Enumeration,java.util.Vector,java.util.Iterator,matrix.util.StringList,com.matrixone.apps.domain.util.MapList,com.matrixone.apps.domain.util.XSSUtil,com.matrixone.apps.domain.util.FrameworkUtil,com.matrixone.apps.domain.util.PropertyUtil,com.matrixone.apps.domain.DomainConstants,com.matrixone.apps.domain.util.MqlUtil"%>

<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>


<%
		
	    String selectedRows = emxGetParameter(request, "selectedRows");
		StringList slRows = FrameworkUtil.split(selectedRows, "~");
		
		String sExpandLevel = emxGetParameter(request, "expandLevel");

		String sErrorSynchro = "";
		
		//System.out.println("selectedRows : "+selectedRows);

		try{
			
			ContextUtil.startTransaction(context,true);
		
			if(slRows != null){
				
				Iterator<String> itslRows = slRows.iterator();
				while(itslRows.hasNext()){
					
					//boolean allowDelete1 = true;
					StringTokenizer st1 = new StringTokenizer((String)itslRows.next(), "|");
					String sRelId1 = st1.nextToken();
					String sObjId1 = st1.nextToken();
					String sParentObjId1 = st1.nextToken();
					
					DomainObject parent = DomainObject.newInstance(context, sParentObjId1);
	                String parentType = parent.getInfo(context, DomainConstants.SELECT_TYPE);
	                
	                DomainRelationship selectRel = new DomainRelationship(sRelId1);
	                String instanceMaturity = selectRel.getAttributeValue(context, (String)PropertyUtil.getSchemaProperty(context, "attribute_MGS_Inst_Maturity"));
	                
	                if(parentType.equalsIgnoreCase("AT_C_EXPECTED_PRODUCT") && instanceMaturity.equalsIgnoreCase("RELEASED")){
	                	//String strInstanceMaturiyReleasedwithEPParent = "Released Part cannot be replaced for an EP";
	                	sErrorSynchro = "Part under Expected Product with Instance Maturity as Approved cannot be Replaced/Removed";
	                	break;
	                }
					
					DomainObject doObj = DomainObject.newInstance(context, sObjId1);
					String strObjType = (String) doObj.getInfo(context, DomainConstants.SELECT_TYPE);
					
					if(strObjType.equals("AT_C_DESIGN_PART") || strObjType.equals("AT_C_COS") || strObjType.equals("AT_C_STANDARD_PART")){
						String sDeformedVisibility = null;
						String sPLMExternalId = null;
						String sParentProductId = null;	
						StringList slDeformedInstanceToDelete = null;
						
						HashMap mEBOMLinkInfo = new HashMap();
						mEBOMLinkInfo.put("relId", sRelId1);
						mEBOMLinkInfo.put("objectId", sObjId1);
						
						String[] ebomLinkArgs = JPO.packArgs(mEBOMLinkInfo);
						Map mVPMInstanceInfo = JPO.invoke(context,"AT_emxDeformable", null, "getVPMInstanceInfoFromEBOMLink", ebomLinkArgs,Map.class); 
						 
						System.out.println("mVPMInstanceInfo : "+mVPMInstanceInfo);
						
						if(mVPMInstanceInfo.containsKey("listOfDeformedInstanceToDelete")){ slDeformedInstanceToDelete = (StringList) mVPMInstanceInfo.get("listOfDeformedInstanceToDelete");}
						if(mVPMInstanceInfo.containsKey("sParentProductId")){ sParentProductId = (String) mVPMInstanceInfo.get("sParentProductId");}

						DomainRelationship.disconnect(context, sRelId1);
						
						Hashtable mSynchro = new Hashtable();
						mSynchro.put("ROOTID", sParentObjId1);
						mSynchro.put("objectId", sParentObjId1);
						mSynchro.put("SYNC_DEPTH", "1");
						mSynchro.put("SYNC_AND_TRANSFER", "no");
					  
						String[] synchroArgs = JPO.packArgs(mSynchro);
						//Modified to fix redmine 8680 - Use public API for synchronization - start
						//Map matrixObjIDvplmObjIDMap  = (Map) JPO.invoke(context,"AT_emxDeformable", null, "launchEncapsulatedSynchro", synchroArgs,	Map.class);
						Map matrixObjIDvplmObjIDMap  = (Map) JPO.invoke(context,"AT_emxDeformable", null, "launchEncapsulatedSynchroPublicAPI", synchroArgs,	Map.class);
						//Modified to fix redmine 8680 - Use public API for synchronization - end
							
						if(matrixObjIDvplmObjIDMap != null && matrixObjIDvplmObjIDMap.containsKey("RESULT_MESSAGE")){
							 
							 HashMap mDisconnectDeformable = new HashMap();
							 mDisconnectDeformable.put("sParentProductId", sParentProductId);
							 mDisconnectDeformable.put("listOfDeformedInstanceToDelete", slDeformedInstanceToDelete);

							 String[] disconnectDeformableArgs = JPO.packArgs(mDisconnectDeformable);
							 JPO.invoke(context,"AT_emxDeformable", null, "disconnectDeformableInPostSynchro", disconnectDeformableArgs);
							 
						}else{
							if(matrixObjIDvplmObjIDMap != null && matrixObjIDvplmObjIDMap.containsKey("ERROR_MESSAGE")){
								
								Object errorMessage = matrixObjIDvplmObjIDMap.get("ERROR_MESSAGE");
								
								if(errorMessage instanceof String) {
									sErrorSynchro += (String) errorMessage;
								}else if(matrixObjIDvplmObjIDMap.get("ERROR_MESSAGE") instanceof ArrayList<?>){
									ArrayList<String> alErrorSynchro = (ArrayList<String>) errorMessage;
									Iterator<String> itResult = alErrorSynchro.iterator();
									while(itResult.hasNext()){
										sErrorSynchro += itResult.next();
									}
								}
								
								//System.out.println("sErrorSynchro : "+sErrorSynchro);
								
								ContextUtil.abortTransaction(context);
							}
						}
					}
				}
			}
			
			ContextUtil.commitTransaction(context);
				
		} catch(Exception ex){
			ex.printStackTrace();
			ContextUtil.abortTransaction(context);
			sErrorSynchro += ex.getMessage();
		}
		
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">	

	var errorSynchro = "<%=sErrorSynchro%>";

	if(errorSynchro != ""){
		alert(errorSynchro);
	}
	parent.document.location.href=parent.document.location.href+"&expandByDefault=true&expandLevel=<%=sExpandLevel%>";
	
</script>