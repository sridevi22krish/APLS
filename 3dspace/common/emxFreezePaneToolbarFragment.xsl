<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
       <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
        <xsl:variable name="split" select="/mxRoot/setting[@name='split']"/>
    	<xsl:variable name="compare" select="/mxRoot/requestMap/setting[@name='IsStructureCompare']" />
		 <xsl:variable name="isUnix" select="/mxRoot/setting[@name='isUnix']"/>
		 <xsl:variable name="isIE" select="/mxRoot/setting[@name='isIE']"/>    	        
       <xsl:variable name="reportType">
	      	<xsl:if test="/mxRoot/requestMap/setting[@name='IsStructureCompare'] = 'TRUE'">                                                    
	            <xsl:value-of select="/mxRoot/requestMap/setting[@name='reportType']" />                                                
	        </xsl:if>
       </xsl:variable>
    <xsl:template match="/mxRoot">
           <xsl:call-template name="massUpdateToolbar"/>
    </xsl:template>
    <xsl:template name="massUpdateToolbar">
        <!-- MASSUPDATE -->
        <!--<div class="toolbar-subcontainer" id="divMassUpdate" style="display:none">-->
             <div class="toolbar-frame">
            <xsl:choose>
              <xsl:when test="tableControlMap/setting[@name='showMassUpdate'] = 'true'">
               <div class="toolbar">
                   <xsl:if test="(requestMap/setting[@name = 'AllAreNonEditableCols']='true')">
                		<xsl:attribute name="style"> visibility:hidden;  </xsl:attribute>                                         
          		   </xsl:if>
                    <table>
                        <tr>
                                <td class="toolbar-panel-label" nowrap="nowrap"><xsl:value-of select="tableControlMap/setting[@name='Labels']/items/item[@name='MassUpdate']/value"/></td>
                                <td class="toolbar-panel-input" nowrap="nowrap">
                                    <select name="columnSelect" onclick="focusTrick()" onChange="massUpdate(this)">
                                        <option value=""/>
                                        <xsl:for-each select="columns/column[settings/setting[@name='Input Type']]">
                                        <xsl:if test="(settings/setting[@name='Editable']='true') and (not(settings/setting[@name='Mass Update']='false'))">
										<option value="{@name}">
                                            <xsl:choose>
                                            <xsl:when test="contains(@label,'img') and contains(@label,'src')">
                                             <xsl:value-of select="@name"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="@label"/>
                                            </xsl:otherwise>
                                            </xsl:choose>
                                           </option>
                                        </xsl:if>
                                        </xsl:for-each>
                                    </select>
                                </td>
                        </tr>
                    </table>
                </div>
                </xsl:when>
                 <xsl:otherwise>
                    <div class="toolbar spacer">
                    	<table>
                    	      <tr><td>&#160;</td></tr>
                    	  </table>
                    </div>	  
                     </xsl:otherwise>
                </xsl:choose> 
				<div id="mx_divStructureBrowserButtons" class="toolbar dialog-actions">
						<table>
						  <tbody>
						      <tr>
						          <td>
						
						<xsl:if test="not(requestMap/setting[@name = 'showApply']) or (requestMap/setting[@name = 'showApply']='true') ">
							<xsl:if test="/mxRoot/setting[@name='editState']='apply'">
							
								<xsl:if test="(requestMap/setting[@name = 'table']) and (requestMap/setting[@name = 'table']='ATCloneEBOMSB') ">
									<input id="ApplyButton" type="button" value="Next" onclick="applyEdits()" class="mx_btn-apply" />
								</xsl:if>
								
								<xsl:if test="(requestMap/setting[@name = 'table']) and not(requestMap/setting[@name = 'table']='ATCloneEBOMSB') ">
                                    <input id="ApplyButton" type="button" value="{tableControlMap/setting[@name='Labels']/items/item[@name='Save']/value}" onclick="applyEdits()" class="mx_btn-apply" >
                                         <xsl:attribute name="title">                                            
                                         <xsl:value-of select="/mxRoot/tableControlMap/setting[@name='Labels']/items/item[@name='ApplyBtn']/value"/>
                                         </xsl:attribute>
                                    </input>
								</xsl:if>

						</xsl:if>
						</xsl:if>
						
						<xsl:if test="/mxRoot/setting[@name='editState']='lookup'">
							<input id="ApplyButton" type="button" value="{tableControlMap/setting[@name='Labels']/items/item[@name='Lookup']/value}" onclick="lookupAction()" class="mx_btn-lookup" >
						<xsl:attribute name="title">                                            
                                         <xsl:value-of select="/mxRoot/tableControlMap/setting[@name='Labels']/items/item[@name='LookupBtn']/value"/>
                                         </xsl:attribute>
						</input>
						</xsl:if>
						
						<input id="ResetButton" type="button" value="{tableControlMap/setting[@name='Labels']/items/item[@name='Reset']/value}" onclick="resetEdits()" class="mx_btn-reset" >
						<xsl:attribute name="title">                                            
                                         <xsl:value-of select="/mxRoot/tableControlMap/setting[@name='Labels']/items/item[@name='ResetBtn']/value"/>
                                         </xsl:attribute>
                    </input>
						          </td>
						      </tr>
						  </tbody>
						</table>
						
				</div>
            </div>
        <!--</div>-->
    </xsl:template>
</xsl:stylesheet>
