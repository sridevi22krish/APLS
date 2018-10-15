/*!================================================================
 *  JavaScript Core Menu Component
 *  emxUICoreMenu.js
 *  Version 1.0
 *  Requires: emxUICore.js
 *  Last Updated: 4-Apr-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains the definition of a JavaScript popup menu.
 *
 *  Copyright (c) 1992-2015 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUICoreMenu.js.rca 1.15 Wed Oct 22 15:48:18 2008 przemek Experimental przemek $
 *=================================================================
 */
var emxUICoreMenu = new Object;
emxUICoreMenu.CSS_FILE = emxUICore.getStyleSheet("emxUIMenu");
emxUICoreMenu.WATCH_DELAY = 50;
emxUICoreMenu.POPUP_MAX_HEIGHT = 740;
emxUICoreMenu.POPUP_MIN_WIDTH = 200;
emxUICoreMenu.DELAY_BETWEEN = 50;
emxUICoreMenu.SCROLL_DISTANCE = 10;
emxUICoreMenu.MAXITEMS_PER_COLUMN = 18;
emxUICoreMenu.MAXITEMS_PER_COLUMN_GB = 22;
emxUICoreMenu.HEADER_HT = 30;
emxUICoreMenu.ROW_HT = 21;
emxUICoreMenu.UI_AUTOMATION = emxUIConstants.UI_AUTOMATION;
if(getTopWindow().isMobile){
	emxUICoreMenu.HEADER_HT = 44;
	emxUICoreMenu.ROW_HT = 39;
}
emxUICoreMenu.DEF_POPUP_SRC = "<!DOCTYPE html><html style='overflow:hidden;'><head></head><body></body></html>";
var objulStatus = false;

if(emxUIConstants.STORAGE_SUPPORTED){
	var menuCache = localStorage.getItem('menuCache');

	if(typeof menuCache=="undefined" || !menuCache){
		var menuCacheJson = {"expanded":[]};
		localStorage.setItem('menuCache',JSON.stringify(menuCacheJson));
	}
}

//! Class emxUICorePopupMenu
//!     This object represents a menu.
function emxUICorePopupMenu() {
        this.superclass = emxUIObject;
        this.superclass();
        delete this.superclass;
        this.cssClass = "menu-layer";
        this.emxClassName = "emxUICorePopupMenu";
        this.items = new Array;
        this.layer = null;
        this.innerLayer = null;
        this.scrollTimeoutID = null;
        this.timeoutID = null;
        this.visible = false;
        this.maxHeight = 740;
        this.templateInnerLayer = null;
        this.templateOuterLayer = null;
        this.templateUpButton = null;
        this.templateDownButton = null;
        this.ownerWindow = self;
        this.parent = null;
        this.popup = null;
        this.stylesheet = emxUICoreMenu.CSS_FILE;
        this.displayWindow = self;
        this.uniqueID = emxUICore.getUniqueID();
        this.treeMenuRevision = false;
        this.menucontent = null;
        this.menuborder = null;
        this.menuinset = null;
        this.numColumns = 1;
        this.winheight = null;
        this.widthConstant = 231;
        this.sbheight = 0; // only for IE
        this.doIEChange = true;
        this.isRMBMenu = false;
        this.isNavigatorRMB = false;
}
emxUICorePopupMenu.prototype = new emxUIObject;
//! Protected Method emxUICorePopupMenu.addItem()
//!     This method adds an item to the menu.
emxUICorePopupMenu.prototype.addItem = function _emxUICorePopupMenu_addItem(objItem) {
        objItem.index = this.items.length;
        this.items.push(objItem);
        objItem.parent = this;
        return objItem;
};

function drawJsonMenuItems(jsonObj, placeHolder, dynamicName, gtb){
	var uiAutomation = emxUIConstants.UI_AUTOMATION;
	var menu_section = {

			template: {
		    	menupanel:function(){
		        	return jQuery('<div class="menu-panel"></div>');
		        },
		    	menupanel_profile:function(){
		        	return jQuery('<div class="menu-panel global profile"></div>');
		        },
		    	menupanel_add:function(){
		        	return jQuery('<div class="menu-panel global add"></div>');
		        },
		    	menupanel_share:function(){
		        	return jQuery('<div class="menu-panel global share"></div>');
		        },
		    	menupanel_home:function(){
		        	return jQuery('<div class="menu-panel global home"></div>');
		        },
		    	menupanel_help:function(){
		        	return jQuery('<div class="menu-panel global help"></div>');
		        },
		    	menupanelmydesk:function(){
		        	return jQuery('<div id="mydeskpanel" class="slide-in-panel menu categories my-desk"></div>');
		        },
		        menucontent:function(id){
		        	/*adding "aria-haspopup = true" attribute for supporting the hover menu on mobile and touch PC.
		        	This Indicates that the element has a popup context menu or sub-level menu.*/
		    		return jQuery('<div class="menu-content" aria-haspopup="true"></div>');
		    	},
		        menutab:function(expand){
		        	/*adding "aria-haspopup = true" attribute for supporting the hover menu on mobile and touch PC.
		        	This Indicates that the element has a popup context menu or sub-level menu.*/
		        	return jQuery('<div class="menu-tab" aria-haspopup="true"><span></span></div>');
		        },
		        menupointer:function(expand){
		        	return jQuery('<div class="menu-pointer"></div>');
		        },
		        menu_group:function(expand){
		        	
		        		try{
		        			if(!jsonObj.menuItems[i].displayMode.contains(displayView) && (jsonObj.isRMB=="false") && jsonObj.menuItems[i].displayMode!=""){
		        				var toolbarVisibleMode = jsonObj.menuItems[i].displayMode;
			        			toolbarVisibleMode=toolbarVisibleMode.split(",");
		        				displayView= displayView.toLowerCase();
		        			if( toolbarVisibleMode=="" || toolbarVisibleMode.find(displayView)==-1){
		        				return jQuery('<div class="group collapsed disabled"></div>');
		        			}
		        	
		        		}
					}
		        		catch(e){
			        		
			        	}
		        	if(((jsonObj.mainMenuExpanded=="true")&& (!(jsonObj.menuItems[i].expanded=="false"))) || (jsonObj.menuItems[i].expanded=="true")){
		        		return jQuery('<div class="group nested-indented expanded"></div>');
		        	}
		        	return jQuery('<div class="group collapsed"></div>');
		        },
		        menu_group_expanded:function(expand){
		        	return jQuery('<div class="group expanded"></div>');
		        },
		        menu_group_mydesk_expanded:function(expand){
		        	return jQuery('<div class="group expanded" style="display:none"></div>');
		        },
		        menu_group_head:function(){
		        	return jQuery('<div class="group-head"></div>');
		        },
		        menu_group_head_icon:function(){
		        	return jQuery('<div class="group-head icon"></div>');
		        },
		        menu_group_head_what:function(){
		        	return jQuery('<div class="group-head no-link"></div>');
		        },
		        menu_groupBody:function(){
		        	return jQuery('<div class="group-body"></div>');
		        },
		        menu_ul:function(){
		        	return jQuery('<ul></ul> ');
		        }
		        },

		    _getMenuGroupData:function(grpUl,menuGroupObj){
       			for (var j=0; j < menuGroupObj.items.length; j++) {
		       		label = menuGroupObj.items[j].label;
		       		var li;
		    	   		if (menuGroupObj.items[j].items) {
		    	   			if(menuGroupObj.items[j].icon && gtb != "true"){
		    	   				li = jQuery('<li class="menu collapsed icon"><a href="javascript:void(0)"><span><img HEIGHT="16" WIDTH="16" src='+menuGroupObj.items[j].icon+'></span><label>'+label+'</label></a></li>');
		    	   			}else{
		    	   				li = jQuery('<li class="menu collapsed"><a href="javascript:void(0)"><label>'+label+'</label></a></li>');
		    	   			}
		    	   			jQuery("a",li).attr("id",menuGroupObj.items[j].actualName);
		    	   			jQuery("a",li).bind("expand",function(e){
		    	   				jQuery(this).parent("li.menu").toggleClass("collapsed").toggleClass("expanded");
		    	   				showMarkOnMenuItem(this,mPanel[0]);
		    	   			});

		    	   			jQuery("a",li).click(function(){
		    	   				emxUICore.addToClientCache(this);
		    	   				jQuery(this).parent("li.menu").toggleClass("collapsed").toggleClass("expanded");

								if(dynamicName != "My Desk"){
									adjustMenuHeight(jQuery(this).closest(".menu-content"));
								}else{
									adjustMenuHeight(jQuery(this).closest(".menu-content"), true);
								}
		    		       	});

		    	   		}else{
		    	   			var obj = menuGroupObj.items[j].itemObj;
		    	   			if(menuGroupObj.items[j].menuItemClassName == "emxUIToolbarMenuSeparator"){
		    		  			li = jQuery('<li class="separator"></li>');
		    		  		} else if( menuGroupObj.items[j].url == "javascript::::"){

		       			var data ="";

		    	   				if( obj && obj.dynamicName=="AEFMyRoleCommand"){


		    	   					var path = window.location.pathname.split( '/' )[1];
		    	   				    var baseURL =  window.location.protocol+"//"+ window.location.host+"/"+path;
		    	   				var requestProxy="";
		    	   			//below check is added to identify if proxy is set or not, should be converted to a function based on the actual identification of proxy
		    	   				if(baseURL !== getTopWindow().myAppsURL){
		    	   					requestProxy="passport";
		    	   				}
		    	   				UWA.Data.proxies.passport = crossproxy;
		    	   				UWA.Data.request(getTopWindow().myAppsURL+"/resources/AppsMngt/user/process", {
		    	   						type:"json",
		    	   						method:"GET",
		    	   						cache:-1,
										proxy : requestProxy,
										onComplete : function(data){
		    	   							for (var j=0; j < data.role.length; j++) {
		    			  						var roleId = data.role[j].id;
		    			  						var isActive = data.role[j].active;
		    			  						var roleTitle = data.role[j].title;
		    			  						var isSelectable = data.role[j].selectable;
		    			  						var liclass = (true == isActive)?'class="selected"':'';
		    			  						var li = jQuery('<li '+liclass+' id='+roleId+' active='+isActive+'><a href=""><span class="checked"></span><label>'+roleTitle+'</label></a></li>');
		    			  						li.click(function(e){
		    			  							e.stopPropagation();
		    			  							e.preventDefault();
		    			  							toggleAttrAndCheckmark(this);
		    			  							var activeRoleData = getActiveRoles(jQuery(this).parent().children("li[active='true']"));
		    			  							UWA.Data.request(getTopWindow().myAppsURL+"/resources/AppsMngt/user/setPreferences",{
		    			    	   						data:{name: 'active_roles', value:activeRoleData},
		    			    	   						method:"GET",
		    			    	   						cache:-1,
		    			    	   						proxy: requestProxy,
		    			    	   						headers : {Accept : "application/json"},
		    			    	   						onComplete : function(data){
			    			  							onTopBarClick();
														}
		    			    	   					});
		    			  						});
		    			  						grpUl.append(li);
		    			  					}
		    			  					var separator = jQuery('<li class="separator"></li>');
		    			  					grpUl.append(separator);
										}
		    	   					});
		    	   				} else {
		       			jQuery.ajax({
				  				  url: "emxReadAjaxCall.jsp?cmddName=AEFTypesGlobalSearchCommand",
		  				  dataType:"html",
		  				  cache:false,
					      error: function(error, status) {
					    	  if(error.status == 401){
					    			getTopWindow().location.href = "../common/emxNavigatorErrorPage.jsp?errorCode=401";
					    	  }
					       }
		  				}).done(function(data1){
		  					setTimeout(function(){data = emxUICore.parseJSON(data1);
		  					for (var j=0; j < data.collections[0].items.length; j++) {
			    	   			var li = jQuery('<li><a href="'+data.collections[0].items[j].url+'"><span></span><label oriName='+data.collections[0].items[j].name +'>'+data.collections[0].items[j].label+'</label></a></li>');
			    	   			li.click(function(e){
			    		  			e.stopPropagation();
			    	    			e.preventDefault();
			        				var urll = this.childNodes[0].getAttribute('href');
			        				var labell = this.childNodes[0].textContent;
				    				if(urll.indexOf("javascript:updateSearchField()")>=0){
				    					emxUICore.link("javascript:updateSearchField("+"\""+ this.childNodes[0].childNodes[1].getAttribute("oriname")+"\","+"\""+ labell+"\""+")","");
				    				}
				    				showMarkOnMenuItem(this,mPanel[0]);
			    		    	});
			    	   			grpUl.append(li);
					       	}
		  					},1000);
		  				});
		    	   				}


		       		}else{
							if(obj.icon && gtb != "true"){
								li = jQuery('<li><a href="javascript:void(0)"><span><img HEIGHT="16" WIDTH="16" src='+obj.icon+'></span><label>'+label+'</label></a></li>');
							}else{
								li = jQuery('<li><a href="javascript:void(0)"><label>'+label+'</label></a></li>');
							}
		    		  		  if(obj.formFieldName == "emxExpandFilter" || obj.htmlType == "textbox" || obj.htmlType == "checkbox" || obj.htmlType == "combobox"){
					  				li = jQuery('<li><label>'+label+'</label></li>');
		    		  		  }
		    		  		  if(obj.isRMB && obj.isRMB == "true"){
		    	                  if(menuGroupObj.items[j].url != "" && menuGroupObj.items[j].target == "content"){
		    	                	  menuGroupObj.items[j].target = "popup";
		    	                     if(menuGroupObj.items[j].url.indexOf("javascript:") != 0){
		    	                    	 menuGroupObj.items[j].url = "javascript:showModalDialog(\""+menuGroupObj.items[j].url+"\",600,600,true )";
		    	                     }
		    	                   }
		    	                }

		    		  		// for enable,disable of menuitems
					    		obj.rowElement =li.get(0);

		    		  		 if(obj.grayout == "true"){
			                	obj.disable();
			                 }

		    		  		if(obj.formFieldName != "emxExpandFilter" && obj.htmlType != "textbox" && obj.htmlType != "checkbox" && obj.htmlType != "combobox"){
			    	   			li.click(function(e){
			    		  			e.stopPropagation();
			    	    			e.preventDefault();
			    	    			if(jQuery(this).hasClass("disabled")){
					    				return;
					    			}
									try{
										if(this.onClick != null){
											eval(this.onClick);
										}
									}catch(e){

									}
										if(this.url.indexOf("javascript:showWindowShadeDialog(")>=0){
											
											emxUICore.link("javascript:updateSearchField(\""+this.url.substring(this.url.indexOf("\"")+1,this.url.lastIndexOf("\""))+"\",\""+ jQuery('label', this).text() +"\",\"searchPage\")","windowshade");
											
					    				}else{
			    		  			emxUICore.link(this.url, this.target, this);
			    		  			if(dynamicName == "My Desk"){
			    		  				jQuery('.north-bgnd').removeClass('active');
			    		  				jQuery('li.active','div#mydeskpanel').removeClass("active");
			    		  				jQuery(this).addClass('active');

                                        // My Desk Changes START 
                                        // opening a view from the My Desk Menu    
                                    	if(this.target != 'popup' && this.target != 'slidein'){
    			    		  				jQuery("#leftPanelMenu").css('display','none');
                                        if(jQuery("#mydeskpanel").hasClass("appMenu")) {
                                            jQuery("#panelObjectHistory").remove();    
                                            jQuery("#content").css("width", "");  
                                            jQuery("#ExtpageHeadDiv").hide();
                                            jQuery("#resizerLeftPanelMenu").hide();
                                            jQuery("#panelToggle").css("top", "80px");
                                            jQuery("#mydeskpanel").css('left', jQuery("#leftPanelMenu").css("left"));
                                            jQuery("#mydeskpanel").css('top','80px');                                                                            
                                            jQuery("#mydeskpanel").css('max-height','');                                                                            
                                            jQuery("#mydeskpanel").css('display','block');                                                                                                                                                    
                                            jQuery("#mydeskpanel").unbind("mouseenter");
                                            jQuery("#mydeskpanel").unbind("mouseleave");                                                                           
                                            jQuery("#mydeskpanel").removeClass("appMenu"); 
                                        }    

                                        jQuery("#pageContentDiv").css("top", "80px");
                                        if(jQuery("#panelToggle").hasClass("closed")) {
                                           // jQuery("#pageContentDiv").css("left", "20px");
                                        } else {
                                            jQuery("#pageContentDiv").css("left", "212px");
                                        }
                                        
                                        jQuery("iframe[name=content]").removeClass("ObjectHistoryPanelVisible");
                                        jQuery("#panelObjectHistory").remove();
	                                        
	                                   
                                    	} else {
                                    		if(jQuery("#mydeskpanel").hasClass("appMenu")) {
	                                            jQuery("#mydeskpanel").unbind("mouseenter");
	                                            jQuery("#mydeskpanel").removeClass("appMenu");
	                                            jQuery("#mydeskpanel").hide();
	                                        } else {
	    			    		  				jQuery("#leftPanelMenu").css('display','none');
	                                        }   
                                    	}
                                        // My Desk Changes END
			    		  			}
					    		}
										if(dynamicName != "My Desk" && dynamicName != "Actions"){
				    		  			showMarkOnMenuItem(this,mPanel[0]);
										}
			    		    	});
			    	   			li.get(0).onClick = obj.onClick;
			    	   			li.get(0).url = menuGroupObj.items[j].url;
			    	    		li.get(0).target = menuGroupObj.items[j].target;
			    	    		li.get(0).label = label;
		    		  		}

		    		  		}
		    	   		}

		    	   		if(uiAutomation == "true" && li){
	    	   				li.attr('data-aid', menuGroupObj.items[j].data_aid);
	    		  		}

		    	   		grpUl.append(li);
		    	   		if(menuGroupObj.items[j].items){
		        			var ul = menu_section.template.menu_ul();
		        			li.append(ul);
		        			this._getMenuGroupData(ul, menuGroupObj.items[j]);
		        		}
		       	}
		    }
	};

	var mPanel;
	var mContent = menu_section.template.menucontent();

	if(dynamicName == "My Desk"){
		mPanel = menu_section.template.menupanelmydesk();
	} else if(dynamicName == "AEFPersonMenu"){
		mPanel = menu_section.template.menupanel_profile();
		mPanel.append(menu_section.template.menutab());
	} else if(dynamicName == "Actions"){
		mPanel = menu_section.template.menupanel_add();
		mPanel.append(menu_section.template.menutab());
	} else if(dynamicName == "AEFShareMenu"){
		mPanel = menu_section.template.menupanel_share();
		mPanel.append(menu_section.template.menutab());
	} else if(dynamicName == "AEFMyHome"){
		mPanel = menu_section.template.menupanel_home();
		mPanel.append(menu_section.template.menutab());
	} else if(dynamicName == "AEFHelpMenu"){
		mPanel = menu_section.template.menupanel_help();
		mPanel.append(menu_section.template.menutab());
	} else {
		mPanel = menu_section.template.menupanel();
		if(dynamicName == "AEFGlobalSearchHolder"){
			mPanel.append(menu_section.template.menupointer());
		}
	}


	mPanel.append(mContent);

	var objul = menu_section.template.menu_ul();
	if(dynamicName != "My Desk"){
		mContent.append(objul);
	}

	var prevItemIsMenu = false;
    for (var i=0; jsonObj.menuItems && i < jsonObj.menuItems.length; i++) {
    	var label = jsonObj.menuItems[i].label;
	      if (jsonObj.menuItems[i].items) {
	    	  prevItemIsMenu = true;
	    	  var mGroup;
	    	    if(jsonObj.menuItems[i].actualName == 'AEFGlobalSearch'){
	    			mGroup = menu_section.template.menu_group_expanded();
	    	  	} else if(dynamicName != "My Desk"){
	    	  		mGroup = menu_section.template.menu_group();
	    	  	}else {
	    	  		mGroup = menu_section.template.menu_group_mydesk_expanded();
	    	  		mGroup[0].setAttribute('id', jsonObj.menuItems[i].actualName);
	    	  	}
		       	if(uiAutomation == "true"){
		       		mGroup.attr('data-aid', jsonObj.menuItems[i].data_aid);
		  		}
		       	var mGroupHead, headData;
		       	if(jsonObj.menuItems[i].icon && gtb != "true"){
		       		mGroupHead = menu_section.template.menu_group_head_icon();
		       		headData = jQuery('<a href="javascript:void(0)"><span><img HEIGHT="16" WIDTH="16" src='+jsonObj.menuItems[i].icon+'></span><label>'+label+'</label></a>');
		       	}else{
		       		if(jsonObj.menuItems[i].actualName == 'AEFGlobalSearch'){
			       		mGroupHead = menu_section.template.menu_group_head_what();
			       		headData = jQuery('<label>'+label+'</label>');
		       	}else{
		       		mGroupHead = menu_section.template.menu_group_head();
		       		headData = jQuery('<a href="javascript:void(0)"><label>'+label+'</label></a>');
		       	}
		       	}

		     	mGroupHead.attr("id",jsonObj.menuItems[i].actualName);
		       	mGroupHead.bind('expand',function(){
		       		jQuery(this).closest(".group").toggleClass("collapsed").toggleClass("expanded");
	        		//if(dynamicName != "My Desk"){
	        		adjustMenuHeight(jQuery(this).closest(".menu-content"));
	        		//}

	    	  	});
		       	if(jsonObj.menuItems[i].actualName != 'AEFGlobalSearch'){
		       	mGroupHead.click(function(e){
		       		e.stopPropagation();
	    			e.preventDefault();

	    			emxUICore.addToClientCache(this);

	        		jQuery(this).closest(".group").toggleClass("collapsed").toggleClass("expanded");
	        		if(dynamicName != "My Desk"){
	        		adjustMenuHeight(jQuery(this).closest(".menu-content"));
	        		} else {
	        			adjustMenuHeight(jQuery(this).closest(".menu-content"), true);
	        		}
		       	});
		       	}

		       	mGroupHead.append(headData);
		       	mGroup.append(mGroupHead);

		       	var mGroupBody = menu_section.template.menu_groupBody();
		       	var grpUl = menu_section.template.menu_ul();
		       	menu_section._getMenuGroupData(grpUl, jsonObj.menuItems[i]);
		       	mGroupBody.append(grpUl);
		       	mGroup.append(mGroupBody);
		       	mContent.append(mGroup);

	      }else{
		  		var li;
		  		var obj = jsonObj.menuItems[i].itemObj;
		  		if(jsonObj.menuItems[i].menuItemClassName == "emxUIToolbarMenuSeparator" || jsonObj.menuItems[i].menuItemClassName == "emxUICalendarYearMenuSeparator"){
		  			li = jQuery('<li class="separator"></li>');
		  		}else{

		  			if(jsonObj.menuItems[i].icon && gtb != "true"){
			  			li = jQuery('<li class="icon"><a href="javascript:void(0)"><span><img HEIGHT="16" WIDTH="16" src='+jsonObj.menuItems[i].icon+'></span><label>'+label+'</label></a></li>');
			  		}else{
			  			if(jsonObj.menuItems[i].url=="javascript:updateSearchField(\"All_Search\")"){
			  				li = jQuery('<li class="link selected"><a href="javascript:void(0)"><span class="checked"></span><label>'+label+'</label></a></li>');
			  			}else if(obj.formFieldName == "emxExpandFilter" || obj.htmlType == "textbox" || obj.htmlType == "checkbox" || obj.htmlType == "combobox"){
			  				li = jQuery('<li><label>'+label+'</label></li>');
			  			}else{
			  				li = jQuery('<li><a href="javascript:void(0)"><span></span><label>'+label+'</label></a></li>');
			  			}
			  		}
	                if(uiAutomation == "true"){
			  			li.attr('data-aid', jsonObj.menuItems[i].data_aid);
			  		}
	                if(obj.isRMB && obj.isRMB == "true"){
	                  if(jsonObj.menuItems[i].url != "" && jsonObj.menuItems[i].target == "content"){
	                	  jsonObj.menuItems[i].target = "popup";
	                     if(jsonObj.menuItems[i].url.indexOf("javascript:") != 0){
	                    	 jsonObj.menuItems[i].url = "javascript:showModalDialog(\""+jsonObj.menuItems[i].url+"\",600,600,true )";
	                     }
	                   }
	                }
		    		// for enable,disable of menuitems
		    		obj.rowElement =li.get(0);

	                if(obj.grayout == "true"  || (obj.sbModeforDynamicMenu && obj.Mode && obj.Mode !== "" && obj.sbModeforDynamicMenu !== obj.Mode)){
	                	obj.disable();
	                }
	                var menuItemClassName = jsonObj.menuItems[i].menuItemClassName;
	                var index = obj.index;
	                if(obj.formFieldName != "emxExpandFilter" && obj.htmlType != "textbox" && obj.htmlType != "checkbox" && obj.htmlType != "combobox"){

			  		li.click(function(e){
			  			e.stopPropagation();
		    			e.preventDefault();
		    			if(jQuery(this).hasClass("disabled")){
		    				return;
		    			}
						var obj = jsonObj.menuItems[this.index].itemObj;
		    			obj.parent.hide(true);
						try{
							if(this.onClick != null){
								eval(this.onClick);
							}
						}catch(e){

						}
		    			if(this.url.indexOf("javascript:showPageURL(") >= 0){
		                  	var objThis = this;
		                  	objThis.element =li.get(0);
		                  	showPageURL(objThis);
		                } else {
		                	var lTempUrl = this.url;

                            if (dynamicName=="AEFShareMenu")
                            {
                                   // look if we have an url with parameters. In that case, add objectId
                                   if(this.url.indexOf("?") >= 0)
                                   {
                                          var lSplit = this.url.split("?");
                                          lTempUrl = lSplit[0] + "?objectId=" + emxUICore.getContextId() + "&" + lSplit[1];
                                   }
                            }
                            if(obj.parent.emxClassName == "emxUIPortalTabMenu"){
                             obj.click();
                            }else{
                            	// My Desk Changes START (reset page for home menu entries)
                                // opening a view from global home menu
                                if(this.target == "content") {
                                    if(lTempUrl.indexOf("objectId=") === -1) {

                                        jQuery("#ExtpageHeadDiv").hide();
                                        jQuery("#resizerLeftPanelMenu").hide();
                                        jQuery("#pageContentDiv").css("top", "80px");
                                        
                                        jQuery("#panelToggle").css("top", "80px");
                                        jQuery("#mydeskpanel").css("top", "80px");                                            
                                        jQuery("#mydeskpanel").removeClass("appMenu");
                                        jQuery("#mydeskpanel").unbind("mouseenter");
                                        jQuery("#mydeskpanel").unbind("mouseleave");                                                 
                                                                                    
                                        if(jQuery("#leftPanelMenu").is(':visible')) {                                                
                                            jQuery("#leftPanelMenu").hide();
                                            jQuery("#mydeskpanel").css("left", jQuery("#leftPanelMenu").css("left"));
                                            jQuery("#mydeskpanel").show();  
                                        }
                                        
                                        jQuery("#pageContentDiv").css("top", "80px");
                                        if(jQuery("#panelToggle").hasClass("closed")) {
                                            //jQuery("#pageContentDiv").css("left", "20px");
                                        } else {
                                            jQuery("#pageContentDiv").css("left", "212px");
                                        }                                            
                                        
                                        jQuery("iframe[name=content]").removeClass("ObjectHistoryPanelVisible");
                                        jQuery("#panelObjectHistory").remove();
                                        
                                    }
                                }                                    
                                // My Desk Changes END
		                	emxUICore.link(lTempUrl, this.target);
		                }
		                }
						showTickMark = true;
						if(dynamicName == "AEFMyHome"){
							for(var i=0; i<jsonObj.items.length; i++){
								if(jsonObj.menuItems[i].itemObj.command == "CollabSpaceAppCmd" || jsonObj.menuItems[i].itemObj.command == "AEFHomeToolbar"){
									showTickMark=false;
								}
							}
						}
						
		    			if(dynamicName != "AEFPersonMenu" &&
		    					dynamicName != "AEFShareMenu" &&
		    					dynamicName != "AEFHelpMenu" && showTickMark){
			  			showMarkOnMenuItem(this,mPanel[0]);
		    			}
			  			if(menuItemClassName == "emxUICalendarYearMenuItem"){
			  				obj.parent.calendar.setYear(parseInt(jQuery("label",this).text()));
			  			}
			  			if(menuItemClassName == "emxUICalendarMonthMenuItem"){
			  				obj.parent.calendar.setMonth(this.index);
			  			}
			    	});
			  		li.get(0).onClick = obj.onClick;
			  		li.get(0).url = jsonObj.menuItems[i].url;
		    		li.get(0).target =jsonObj.menuItems[i].target;
		    		if(index != undefined){
		    			li.get(0).index = index;
		    		}
	                }
		  		}

		  		if(prevItemIsMenu){
	    			objul = menu_section.template.menu_ul();
	    			mContent.append(objul);
	    			prevItemIsMenu = false;
	    		}




		    	if( jsonObj.menuItems[i].itemObj && jsonObj.menuItems[i].itemObj.dynamicName=="AEFCollabSpace"){
		   			var data ="";
		   			jQuery.ajax({
						  url: "emxReadAjaxCall.jsp?cmddName=AEFCollabSpace",
						  dataType:"html",
						  cache:false,
					      error: function(error, status) {
					    	  if(error.status == 401){
					    			getTopWindow().location.href = "../common/emxNavigatorErrorPage.jsp?errorCode=401";
					    	  }
					       }
						}).done(function(data1){
							setTimeout(function(){
							data = emxUICore.parseJSON(data1);
							for (var j=0; j < data.length; j++) {
								var li;
									if(getTopWindow().collabSpace == data[j].name){
										li = jQuery('<li class="selected" urlLink="'+data[j].url +'"><a href="'+data[j].url+'"><span style="display:block;" class="checked"></span><label>'+data[j].label+'</label></a></li>');
									}else {
										li = jQuery('<li urlLink="'+data[j].url +'"><a href="'+data[j].url+'"><span></span><label>'+data[j].label+'</label></a></li>');
									}
				    	   			li.click(function(e){
							       		e.stopPropagation();
										e.preventDefault();
				        				emxUICore.link(this.getAttribute("urlLink"), "content");
				    	   			});
		    	   			objul.append(li);
				       	}
							},1000);
       	});
		   		} else {
		   			objul.append(li);
	      }
	      }
    }
          this.layer = jQuery(mPanel)[0];


          if(placeHolder) {
          if(dynamicName =="My Desk"){
        	  //var slideInMenu = menu_section.template.menupanelSlidein();
        	  //jQuery(slideInMenu).css("display","none");
        	  jQuery(placeHolder).append(mPanel);
        	  //jQuery(placeHolder).append(slideInMenu);
          }else{
        	  jQuery(placeHolder).append(jQuery(mPanel));
          }
          } else {
        	  //do nothing return the layer diretcly
          }
          return this.layer;
}

function getJsonForMenu(objThis, menuItemsJson){

	for (var i=0; i < objThis.items.length; i++) {
		  var title = objThis.items[i].text;
		  var url = objThis.items[i].url;
		  var icon = objThis.items[i].icon;
		  var target = objThis.items[i].target;
		  var menuItemClassName = objThis.items[i].emxClassName;
		  var actualName = objThis.items[i].dynamicName;
		  var expanded = objThis.items[i].expanded.toLowerCase();
		  var displayMode = objThis.items[i].displayMode.toLowerCase();
		if(emxUIConstants.UI_AUTOMATION == "true"){
			var command = objThis.items[i].command;
			var dynamicName = objThis.items[i].dynamicName;

			var data_aid = "";
			if(command){
				data_aid = command;
			}else if(dynamicName){
				data_aid = dynamicName;
			}else if(title && title.length > 0){
				if( !(title.indexOf('<') != -1 || title.indexOf('<') != -1 || title.indexOf('<') != -1) ){
					data_aid = title;
				}
			}

			if (objThis.items[i].menu && objThis.id != "Categories") {
				var menuArr = new Array();
				jsonObj = {"label": title, "url": url, "icon": icon, "items" : menuArr, "target": target, "actualName":actualName, "data_aid": data_aid};
				menuItemsJson.push(jsonObj);
				getJsonForMenu(objThis.items[i].menu, menuArr);
			}else{
				menuItemsJson.push({"label": title, "url": url, "icon": icon, "target": target, "data_aid": data_aid, "menuItemClassName" : menuItemClassName, "itemObj": objThis.items[i],"expanded":expanded,"displayMode":displayMode});
			}
		}else{
		  	if (objThis.items[i].menu && objThis.id != "Categories") {
		  		var menuArr = new Array();
		  		if((objMenuItem.isRMB == "true") && objThis.items[i].menu.items.length!=1){
		  			jsonObj = {"label": title, "url": url, "icon": icon, "items" : menuArr, "target": target,"actualName":actualName,"expanded" : expanded,"displayMode":displayMode};
		  		menuItemsJson.push(jsonObj);

		  		getJsonForMenu(objThis.items[i].menu, menuArr);
		  		}else if((objMenuItem.isRMB=="true") && objThis.items[i].menu.items.length==1){
		  			title=title +":"+objThis.items[i].menu.items[0].text;
		  			url=objThis.items[i].menu.items[0].url;
		  			icon=objThis.items[i].menu.items[0].icon;
		  			target=objThis.items[i].menu.items[0].target;
		  			actualName=actualName+":"+objThis.items[i].menu.items[0].dynamicName;
		  			menuItemClassName=objThis.items[i].menu.items[0].emxClassName;
		  			itemObj=objThis.items[i].menu.items[0]
					menuItemsJson.push({"label": title, "url": url, "icon": icon, "target": target, "menuItemClassName" : menuItemClassName, "itemObj": itemObj});
		  			
		  		}else{
		  			jsonObj = {"label": title, "url": url, "icon": icon, "items" : menuArr, "target": target,"actualName":actualName,"expanded" : expanded,"displayMode":displayMode};
		  			menuItemsJson.push(jsonObj);
		  			getJsonForMenu(objThis.items[i].menu, menuArr);
		  		}
		  		
		  		
		    }else{
		  		menuItemsJson.push({"label": title, "url": url, "icon": icon, "target": target, "menuItemClassName" : menuItemClassName, "itemObj": objThis.items[i],"expanded" : expanded,"displayMode":displayMode});
		  	}
		}
		if(objThis.id === "Categories" && objThis.items[i].menu){
			objThis.items[i].menu.id = "Categories";
			getJsonForMenu(objThis.items[i].menu, menuItemsJson);
		}
	}

	return menuItemsJson;

}

emxUICorePopupMenu.prototype.createDOM = function _emxUICorePopupMenu_createDOM(gtb) {
	var menuItemsJson = new Array();
	var menuItems = getJsonForMenu(this, menuItemsJson);

	var jsonObj = {"menuItems": menuItems,"mainMenuExpanded":this.expanded.toLowerCase(),"isRMB":this.isRMB};

        if(!this.displayWindow) {
            this.displayWindow = self;
        }
        this.numColumns = 1;
        if(isIE) {
        	var doc = this.displayWindow ? this.displayWindow.document : document;
			var ieMenuCoverForObjectTag = doc.getElementById('ieMenuCoverForObjectTag');
			if(ieMenuCoverForObjectTag) doc.body.removeChild(ieMenuCoverForObjectTag);
		}
        if (!this.displayWindow.document.body) return;
        var objDoc = this.displayWindow.document;
        //Added For Bug : 348007
        if(this.treeMenuRevision) {
        	objDoc = this.displayWindow.document;
        }

    this.layer = drawJsonMenuItems(jsonObj, objDoc.body, this.dynamicName, gtb);
		this.layer.style.visibility = "visible";
        if(this.dynamicName != 'My Desk'){
        this.layer.style.display = "none";
        }
        this.templateInnerLayer = this.layer;

	return;
};

//! Private Method emxUICorePopupMenu.endScroll()
//!     This method ends menu scrolling.
emxUICorePopupMenu.prototype.endScroll = function _emxUICorePopupMenu_endScroll() {
        clearTimeout(this.scrollTimeoutID);
        this.fireEvent("endscroll");
};
//! Private Method emxUICorePopupMenu.handleEvent()
//!     This method handles events for the menu.
emxUICorePopupMenu.prototype.handleEvent = function _emxUICorePopupMenu_handleEvent(strType, objEvent) {
        switch(strType) {
                case "downbutton-mouseover":
                        this.downButton.className = "downbutton-hover";
                        this.scroll(false);
                        break;
                case "downbutton-mouseout":
                        this.downButton.className = "downbutton";
                        this.endScroll();
                        break;
                case "upbutton-mouseover":
                        this.upButton.className = "upbutton-hover";
                        this.scroll(true);
                        break;
                case "upbutton-mouseout":
                        this.upButton.className = "upbutton";
                        this.endScroll();
                        break;
                case "scrollstart":
                	if (objEvent) {
				objEvent.cancelBubble = true;
				objEvent.returnValue = false;
				if (objEvent.stopPropagation) {
					objEvent.stopPropagation();
					objEvent.preventDefault();
				}
                        }
                    break;
        }
};
//! Private Method emxUICorePopupMenu.hide()
//!     This method hides the menu.
emxUICorePopupMenu.prototype.hide = function _emxUICorePopupMenu_hide(blnCascade) {
        if (this.visible) {
                clearTimeout(this.timeoutID);
                /*if (isMinIE55 && isWin) {
                        this.popup.hide();
				    } else {*/
                        //emxUICore.hide(this.layer);
                		/* This logic is added just for IE for those pages which have ActiveX or Applets in their pages.
                         * To show the menu on top of the objects this logic is introduced. Once IE problem is fixed in the
                         * browser then this code needs to be reomved
                         */
		                if(isIE) {
			                var menu = this;
			                setTimeout(function(){
			                	var doc = menu.displayWindow ? menu.displayWindow.document : document;
			                	var ieMenuCoverForObjectTag = doc.getElementById('ieMenuCoverForObjectTag');
	                			if(ieMenuCoverForObjectTag) doc.body.removeChild(ieMenuCoverForObjectTag);
	                			menu.layer.style.display = "none";
			                },5);
		                } else {
		                	this.layer.style.display = "none";
		                }

		                var fnTemp = this.fnTemp;

		                if(this.emxClassName == "emxUICalendarMonthMenu" || this.emxClassName == "emxUICalendarYearMenu")
		                {
	                        emxUICore.iterateFrames(function (objFrame) {
	                        	if(objFrame){
	                        		  emxUICore.removeEventHandler(objFrame, "mousedown", fnTemp, false);
	                				  if (!isUnix)emxUICore.removeEventHandler(objFrame, "resize", fnTemp, false);
	                        	}
	                        });
		                }
		                else{
		                	emxUICore.iterateFrames(function (objFrame) {
		            			  if(objFrame){
	                				  if(objFrame.editableTable && objFrame.editableTable.divListBody){
	                					  emxUICore.removeEventHandler(objFrame.editableTable.divListBody, "scroll", fnTemp, false);
	                					  emxUICore.removeEventHandler(objFrame.editableTable.divTreeBody, "scroll", fnTemp, false);
	                				  }
	                				  emxUICore.removeEventHandler(objFrame, "mousedown", fnTemp, false);
	                				  if (!isUnix)emxUICore.removeEventHandler(objFrame, "resize", fnTemp, false);
	            			  }
		                	});
		                }
                        	//}
                this.reset();
                this.visible = false;
                this.fireEvent("hide");
                if(blnCascade) {
                        if (this.parent) {
                                this.parent.parent.hide(true);
                        }
                }
                //In case of Dynamic Menus,
                //before hiding the Dynamic menus has to replaced with Loading menus
      		 	if(this.parent !=  null && this.parent != 'undefined')
				{
					if (this.parent.dynamicJPO != null && this.parent.dynamicJPO != "undefined"
							 && this.parent.dynamicJPO != "")
					{
					 	if (this.dynamicJPO != null && this.dynamicJPO != "undefined"
							 && this.dynamicJPO != "")
						{
							var objThis = this;
		                	objThis.items = new Array();
		                	var objMenu = new emxUIToolbarMenu();
							objMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.TEXT_ONLY, "", emxUIConstants.STR_LOADING_MENU, "","", "", "", "", "", "", "", "", false,objThis.dynamicJPO,objThis.dynamicMethod,objThis.dynamicName));
		                    for(var k = 0 ; k < objMenu.items.length ; k++)
		                 	{
		                 		objThis.addItem(objMenu.items[k]);
		                 	}
		                   	objThis.init();
		                 }
					}
				}
        }
};
//! Protected Method emxUICorePopupMenu.init()
//!     This method initializes the menu.
emxUICorePopupMenu.prototype.init = function _emxUICorePopupMenu_init(objDocument,gtb) {
        objDocument = objDocument || document;
        if(objDocument == ""){
        	objDocument = document;
        }
        /*if (isMinIE55 && isWin) {
                this.popup = this.ownerWindow.createPopup();
        } else {
        } */
        //Added For Bug : 348007
        if(typeof arguments[1] != "undefined" && arguments[1] == "revisionFilter")
        {
           this.displayWindow = objDocument;
           /*if (isMinIE55 && isWin) {
               this.popup = this.displayWindow.createPopup();
           }*/
           this.ownerWindow = this.displayWindow;
           this.treeMenuRevision = true;
        }
        //this.maxHeight = (isMinIE55 && isWin) ? screen.availHeight - getTopWindow().screenTop : emxUICore.getWindowHeight(this.displayWindow);
        this.maxHeight = emxUICore.getWinHeight(this.displayWindow);
        this.createDOM(gtb);
};
//! Private Method emxUICorePopupMenu.reset()
//!     This method resets the view of the menu.
emxUICorePopupMenu.prototype.reset = function _emxUICorePopupMenu_reset() {
	    this.selectedIndex = -1;
        for (var i=0; i < this.items.length; i++) {
                this.items[i].reset();
        }
        /*if (this.templateInnerLayer.offsetHeight > this.finalHeight) {
                //this.downButton.style.visibility = "inherit";
                emxUICore.hide(this.upButton);
        }*/
        //this.innerLayer.style.top = this.maxTop + "px";
       // this.downButton.style.top = (this.finalHeight - this.templateDownButton.offsetHeight - this.templateUpButton.offsetHeight) + "px";
        this.selectedItem = null;
};
//! Private Method emxUICorePopupMenu.scroll()
//!     This method scrolls the menu.
/*emxUICorePopupMenu.prototype.scroll = function _emxUICorePopupMenu_scroll(blnUp) {
        //var intStop = blnUp ? this.maxTop : this.minTop;
        var intStop = '';
        var intIncrement = blnUp ? emxUICoreMenu.SCROLL_DISTANCE : -emxUICoreMenu.SCROLL_DISTANCE;
        emxUICore.show(this.upButton);
        emxUICore.show(this.downButton);
        var intCurTop = parseInt(this.innerLayer.style.top);
        var intNextTop;
        if (Math.abs(intCurTop - intSgetTopWindow()) < emxUICoreMenu.SCROLL_DISTANCE){
                intNextTop = intStop;
        } else {
                intNextTop = intCurTop + intIncrement;
        }
        emxUICore.moveTo(this.innerLayer, 0, intNextTop);
        if (intNextTop != intSgetTopWindow()) {
                var objThis = this;
                this.scrollTimeoutID = setTimeout(function () { objThis.scroll(blnUp) }, emxUICoreMenu.DELAY_BETWEEN);
        } else {
                emxUICore.hide(blnUp ? this.upButton : this.downButton);
                clearTimeout(this.scrollTimeoutID);
        }
}; */
//! Private Method emxUICorePopupMenu.selectItem()
//!     This method selects an item on the menu, deselecting the others.
emxUICorePopupMenu.prototype.selectItem = function _emxUICorePopupMenu_selectItem(objItem) {
        if (this.selectedItem == objItem) return;
        if (this.selectedItem) {
                this.selectedItem.reset();
        }
        this.selectedItem = objItem;
        this.selectedItem.select();
};
//! Private Method emxUICorePopupMenu.show()
//!     This method shows the menu.
emxUICorePopupMenu.prototype.show = function _emxUICorePopupMenu_show(objRef, strDir, x, y) {
        var objThis = this;
        var intX, intY;
        /*if (isMinIE55 && isWin) {
                switch(strDir) {
                        case "down":
                        case "down-left":
                                intX = 1;
                                intY = objRef.offsetHeight;
                                this.reset();
                                break;
                        /*case "down-left":
                                intX = -this.finalWidth + objRef.offsetWidth;
                                intY = objRef.offsetHeight;
                                break;
                        case "right":
                                intX = objRef.offsetWidth;
                                intY = 0;
                                break;
                        case "absolute":
                        		intX = x;
                                intY = y+225;
                                break;
                        default:
                                throw new Error("Required argument strDirection is not valid (value='" + strDir + "'). (emxUICoreMenu.js::emxUICoreMenu.prototype.show)");
                }
                emxUICore.show(this.layer);
        		if(this.doIEChange) {
        			this.doIEChange = false;
        		var templay = this.ownerWindow.document.createElement("div");
        		templay.className = "mmenu";
        		templay.innerHTML = this.layer.innerHTML;
        		this.ownerWindow.document.body.appendChild(templay);
        		var lh = templay.offsetHeight;
        		this.ownerWindow.document.body.removeChild(templay);
	        		if(this.sbheight > 0) {
	        			this.menuborder.style.height = "" + lh + "px";
	        		}
        		this.finalHeight = Math.min(lh, this.winheight);
        		}
                this.popup.show(intX, intY, this.finalWidth + 18, this.finalHeight + 4 + this.sbheight, objRef);
                this.timeoutID = setTimeout(function () {
                        if (objThis.popup.isOpen) {
                                objThis.timeoutID = setTimeout(arguments.callee, emxUICoreMenu.WATCH_DELAY);
                        } else {
                                objThis.hide();
                        }
                }, emxUICoreMenu.WATCH_DELAY);
        } else {*/
                if (this.ownerWindow != this.displayWindow) {
                        switch(strDir) {
                                case "down":
                                case "down-left":
                                        //intX = this.displayWindow.document.body.offsetLeft + objRef.offsetLeft - 6;
                                        var parentnode1 = objRef.parentNode.parentNode.parentNode.parentNode;
                                    	intX = parentnode1.offsetLeft + objRef.offsetLeft;
                                        intY = this.displayWindow.document.body.offsetTop;
                                        this.reset();
                                        break;
                                /*case "down-left":
                                        intX = emxUICore.getActualLeft(objRef) - this.templateInnerLayer.offsetWidth + objRef.offsetWidth + this.displayWindow.document.body.scrollLeft;
                                        intY = this.displayWindow.document.body.scrollTop;
                                        break;*/
                                case "right":
                                        intX = emxUICore.getActualLeft(objRef) + objRef.offsetWidth;
                                        intY = emxUICore.getActualTop(objRef);
                                        this.layer.className = "menu-panel page";
                                        break;
                                /*case "absolute":
                        				intX = x;
                               			intY = y+100;
                                		break;*/
                                default:
                                        throw new Error("Required argument strDirection is not valid (value='" + strDir + "'). (emxUICoreMenu.js::emxUICoreMenu.prototype.show)");
                        }
                        if (!this.displayWindow.document.getElementById("menu" + this.uniqueID)) {
                                this.createDOM(this.displayWindow.document);
                                this.layer.id = "menu" + this.uniqueID;
                        }
                } else {
                        switch(strDir) {
                                case "down":
                                case "down-left":
										var toolbar = objRef.parentNode.parentNode.parentNode.parentNode.id;
                                        if(toolbar == "globalToolbar"){
                                        	//this.layer.className = "menu-panel right";
                                        	if(this.dynamicName == "AEFGlobalSearchHolder" ){
                                        		this.layer.className = "menu-panel grouped search left";
                                        		this.layer.id = "AEFGlobalSearchHolder";
                                        	}/*else if(this.dynamicName == "Actions"){
                                        		this.layer.className = "menu-panel right actions";
                                        	}*/

											var grpdiv = objRef.parentNode.parentNode.className;
											intX = objRef.offsetLeft;
											if(grpdiv.indexOf('group-right')){
												intX += objRef.offsetWidth;
											}
											var phdiv = this.displayWindow.document.getElementById("pageHeadDiv");
											intY = phdiv.offsetHeight;
										} else {
											if(x && (x.id=="displayModeMenu")){
												this.layer.className = "menu-panel display-mode page";
											}else{
											this.layer.className = "menu-panel page";
										}	
                                        var parentnode1 = objRef.parentNode.parentNode.parentNode.parentNode;
                                        var xdelta = 0;
                                    	var ydelta = 0;


                                    	//IR-175491V6R2013x
											if(objRef.parentNode.parentNode.parentNode.parentNode.id == "globalToolbar"){
                                    		xdelta = 5;
                                    	} else {
                                    		//If the menu is not a global toolbar, we need 5 pixels more Y. Not sure why!
                                    		ydelta = 4;
                                    	}
                                    	if(parentnode1.parentNode.parentNode.className == 'toolbar-container' && !!parentnode1.parentNode.parentNode.id){
                                        	intX = parentnode1.offsetLeft + objRef.offsetLeft + xdelta;
                                        	intY = parentnode1.parentNode.parentNode.offsetTop + parentnode1.parentNode.parentNode.parentNode.offsetTop + objRef.clientHeight + ydelta;
                                        }else{
                                        	if(!isIE) {
                                        		xdelta = 6;
                                        	} else {
                                        		xdelta = 1;
                                        	}
                                        	intX = parentnode1.offsetLeft + objRef.offsetLeft + xdelta;
                                        	intY = parentnode1.offsetTop + parentnode1.parentNode.offsetTop + objRef.clientHeight + ydelta;
                                        }
										}
                                        this.reset();
                                        break;
                                /*case "down-left":
                                        intX = emxUICore.getActualLeft(objRef) - this.templateInnerLayer.offsetWidth + objRef.offsetWidth;
                                        intY = emxUICore.getActualTop(objRef) + objRef.offsetHeight;
                                        break;  */
                                case "right":
                                        var dpb = this.displayWindow.parent.document.getElementById("divPageBody");
                                        if(dpb){
                                          intX = emxUICore.getActualLeft(objRef) + objRef.offsetWidth;
                                          intY = emxUICore.getActualTop(objRef);
                                        }else{
                                        intX = x;
                                        intY = y;
                                        }
                                        	this.layer.className = "menu-panel nowrap-commands page";
                                        break;

                                case "calendar-down":
									//sk
									intX = emxUICore.getActualLeft(objRef);
                                    intY = emxUICore.getActualTop(objRef) + objRef.offsetHeight;
                                    this.layer.className = "menu-panel page";
				    //calendar div's Z-index is 1001,
				    //z-index of year and month is 1002 to display them over the calendar
                                    this.layer.style.zIndex = 1002;
                                    this.reset();
                                    break;
                                case "channel-overflow":
	                                	intX = emxUICore.getActualLeft(objRef);
	                                    intY = emxUICore.getActualTop(objRef) + objRef.clientHeight -12;
	                                    this.layer.className = "menu-panel page";
	                                    this.reset();
	                                    break;

                                case "revisionFilterDropDown":
                                		intX = emxUICore.getActualLeft(objRef) - this.templateInnerLayer.offsetWidth + objRef.offsetWidth;
                                        intY = emxUICore.getActualTop(objRef) + objRef.offsetHeight;
                                        this.reset();
                                       	break;

                                /*case "absolute":
                        				intX = x;
                                		intY = y+100;
                                		break;*/
                                default:
                                        throw new Error("Required argument strDirection is not valid (value='" + strDir + "'). (emxUICoreMenu.js::emxUICoreMenu.prototype.show)");
                        }
                }

              if(strDir == 'revisionFilterDropDown'){
              	var intFinalX = intX + this.finalWidth;
              	var diff =emxUICore.getWindowWidth(this.displayWindow)- intFinalX;
              	if(diff < 0 ){
              		intX= intX + diff;
              		if(intX < 0){
              			intX = 0;
              		}
              	}
              	this.layer.style.display = "block";
              	emxUICore.moveTo(this.layer, intX, intY);
              	this.fnTemp = fnTemp = function () { objThis.hide();};
                emxUICore.iterateFrames(function (objFrame) {
                	if(objFrame){
                		if(isIE){
                	    	objFrame.document.onmousedown = function () { objThis.hide();};
                	    	if (!isUnix) {
                	    		objFrame.document.onresize = function () { objThis.hide();};
                	    	}
                	    } else {
                            objFrame.addEventListener("mousedown", fnTemp, false);
                            if (!isUnix) objFrame.addEventListener("resize", fnTemp, false);
                	    }
                	}

                });
              }  else {
            	  var wid;
            	  if(this.emxClassName != "emxUICalendarMonthMenu"){
            		  if(this.displayWindow) {
                		  wid = emxUICore.getWinWidth(this.displayWindow);
                	  } else {
                		  wid = emxUICore.getWinWidth(getTopWindow());
                	  }
                	  var diff = wid - intX;
                	  var butwidth = 29;
                	  if (objRef.xml && objRef.xml.indexOf('combo-button')>=0) {
                		  butwidth = 35;
                	  }
                	  if(diff < this.finalWidth){
                		  intX = intX - this.finalWidth + butwidth;
                	  }
                	  if(intX < 0) {
                		  intX = 0;
                	  }
            	  }

            	  //emxUICore.show(this.layer);

            	  this.layer.style.display = "block";

            	  /* This logic is added just for IE for those pages which have ActiveX or Applets in their pages.
            	   * To show the menu on top of the objects this logic is introduced. Once IE problem is fixed in the
            	   * browser then this code needs to be removed
            	   */
            	  if(isIE && !this.visible) {
            		  var menu = this;
            		  setTimeout(function(){
            			  var doc = menu.displayWindow ? menu.displayWindow.document : document;
            			  var ieMenuCoverForObjectTag = doc.createElement('iframe');
            			  ieMenuCoverForObjectTag.id='ieMenuCoverForObjectTag';
            			  ieMenuCoverForObjectTag.style.position='absolute';
            			  ieMenuCoverForObjectTag.style.width = '1px';
            			  ieMenuCoverForObjectTag.style.height = '1px';
            			  ieMenuCoverForObjectTag.style.top = (menu.layer.offsetTop) + 'px';
            			  ieMenuCoverForObjectTag.style.left = (menu.layer.offsetLeft) + 'px';
						  //Added for IR-179823V6R2013x.
            			  //Applying inline styling(minHeight) for this iFrame, this should be removed when the false frame is removed
            			  ieMenuCoverForObjectTag.style.minHeight="auto";
            			  ieMenuCoverForObjectTag.style.zIndex='99';
            			  ieMenuCoverForObjectTag.setAttribute('frameborder','0');
            			  ieMenuCoverForObjectTag.setAttribute('src','javascript:false;');
            			  doc.body.appendChild(ieMenuCoverForObjectTag);
            		  },30);
            	  }
            	  /*  Special Code for Activex and Obejcts End*/

            	  var wht;
            	  if(this.displayWindow) {
            		  wht = emxUICore.getWinHeight(this.displayWindow);
            	  } else {
            		  wht = emxUICore.getWinHeight(getTopWindow());
            	  }

            	  var diffht = wht - (intY + this.layer.offsetHeight);
            	  if(diffht < 0 && strDir == 'right'){
            		  intY = intY - this.layer.offsetHeight;
            	  }
            	  var isSlideIn = false;
            	  if(objThis && objThis.displayWindow && objThis.displayWindow.targetLocation){
            		  isSlideIn = (objThis.displayWindow.targetLocation == "slidein")? true: false;
            	  }
            	  var page_yOffset = typeof pageYOffset != "undefined" ? pageYOffset : (document.documentElement ? document.documentElement.scrollTop : null);
		          if ((this.emxClassName == "emxUICalendarMonthMenu" || this.emxClassName == "emxUICalendarYearMenu") &&  !isSlideIn) {
		        	      var totalHeight = page_yOffset != null ? (intY + this.layer.offsetHeight - page_yOffset) : (intY + this.layer.offsetHeight);
			              var totalScrollHeight =  (parent.document.getElementById('divPageBody') && page_yOffset != null) ? parent.document.getElementById('divPageBody').clientHeight : document.body.scrollHeight;
			              if (totalHeight > totalScrollHeight && totalScrollHeight > 0) {
				          var diff = totalHeight - totalScrollHeight;
				          intY = intY - diff;
			          }
		          }


            	  if(intY < 0) {
            		  intY = 0;
            	  }


            	  try{
            		  var k = 0;
            		  if(objRef.className == "search-widget"){
	           			  var tempref = getTopWindow().jQuery(objRef).find('div[id="AEFGlobalFullTextSearch"]');
	                 	  tempref = tempref[0];
            			  intX = jQuery(tempref).offset().left - Math.max(0, (jQuery(tempref).offset().left + jQuery(this.layer).width())- jQuery(window).width());
            			  k = 8;

            		  } else {
            			  intX = jQuery(objRef).offset().left - Math.max(0, (jQuery(objRef).offset().left + jQuery(this.layer).width())- jQuery(document).width());
            		  }
            		  intY = jQuery(objRef).offset().top + objRef.offsetHeight;
            		  intY = intY - k;
            	  }catch(e){
            		  //to handle custom pages where jquery will not present
            		  if(objRef.className == "search-widget"){
	           			  var tempref = getTopWindow().jQuery(objRef).find('div[id="AEFGlobalFullTextSearch"]');
	                 	  tempref = tempref[0];
            			  intX = emxUICore.getActualLeft(tempref) - Math.max(0, (emxUICore.getActualLeft(tempref) + this.layer.offsetWidth)- emxUICore.getWindowWidth(window));
            		  } else {
            			  intX = emxUICore.getActualLeft(objRef) - Math.max(0, (emxUICore.getActualLeft(objRef) + this.layer.offsetWidth)- emxUICore.getWindowWidth(document));
            		  }
            		  intY = emxUICore.getActualTop(objRef) + objRef.offsetHeight;
            	  }

				  var toolbar = objRef.parentNode.parentNode.parentNode.parentNode.id;
  				  if(toolbar == "globalToolbar"){
						if(objRef.className != "search-widget"){
		  					  try {
		  						  intX = jQuery(objRef).offset().left + jQuery(objRef).width() - jQuery(this.layer).width();
		  					  } catch(e){
		  						  intX = emxUICore.getActualLeft(objRef) + objRef.offsetWidth - this.layer.offsetWidth;
		  					  }
		  					  intX = intX + 10;

											var phdiv = this.displayWindow.document.getElementById("globalToolbar");
											intY = phdiv.offsetHeight;
										}
 				  }

  				  // to handle RMB menus, for the last objects in table page
				if((this.isRMB && this.isRMB == "true")){

					  if((emxUICore.getWinHeight() - intY) < (this.layer.offsetHeight)) {
  						adjustRMBMenuHeight(jQuery(this.layer).children(".menu-content"), intY, emxUICore.getWinHeight() - intY);
					  }
  					  if((emxUICore.getWinHeight() < (intY + this.layer.offsetHeight)) && (intY > this.layer.offsetHeight)){
  						intY = intY - this.layer.offsetHeight;
					  }
					  if(emxUICore.getWinWidth() < (intX + this.layer.offsetWidth)){
  						intX = intX - this.layer.offsetWidth;
  					  }
  				  }

  				    if(this.isNavigatorRMB)
	          	    {
  					  var navx = x;
	          		  var navy = y;
	          		  var layerht = this.layer.offsetHeight;
					  var treewht = (objStructureTree.displayFrame)?
                                     emxUICore.getWinHeight
                                     (objStructureTree.displayFrame) : wht;

                      var nodeht = (objRef.parentElement)?
                    		  objRef.parentElement.clientHeight:butwidth;

                      var appspanelwidth = jQuery("#pageContentDiv")?
                    		      jQuery("#pageContentDiv").css("left"):0;

      		         // check if the node is somewhere down at the end
      		  	     // such that menu cannot be displayed any more.
         		     if((treewht-navy)<layerht)
         		     {
         		    	// add above the node such that it is visible
         		    	navy -= layerht;
         		    	navy -= nodeht/2;
         		    	navy += this.layer.offsetTop;
         		     }
         		     else
         		     {
         		    	//push the menu down to display the RMB layer and the node
         		        navy += this.layer.offsetTop;
         		        navy += nodeht;
         		     }
         		    // if the compass panel is open,account for it.
		         	intX = navx + parseInt(appspanelwidth);
		         	intY = navy;
	          	  }
  				    if(x && x.id=="displayModeMenu"){
  				    	var menuPanel=document.getElementsByClassName("menu-panel page")[0];
  				    	var allLI=$(menuPanel).find("li");
  					  if(displayView=="detail"){
  					invokeShowMarkOnMenuItem(0,menuPanel,allLI[0]);
  					  }else if(displayView=="thumbnail"){
  					invokeShowMarkOnMenuItem(1,menuPanel,allLI[1]);
  					  }else if(displayView=="tree"){
  					invokeShowMarkOnMenuItem(2,menuPanel,allLI[2]);
  					  }
  		    	  } 
  		 		  		
  				    	
            	  emxUICore.moveTo(this.layer, intX, intY);
            	  // to add scroll to page menu, if height exceeds
				  if(!(this.isRMB && this.isRMB == "true")){
  				  adjustMenuHeight(jQuery(this.layer).children(".menu-content"));
				  }

            	  this.fnTemp = fnTemp = function (e) {
            		  if(e){
            		  		var target= e.target;
            		  		if(target && jQuery(target).closest(".menu-panel").length ==0) {
                		                                objThis.hide();
            		  		}
            		  }else{
            			  objThis.hide();
            		  }
													};

            	  if(this.emxClassName == "emxUICalendarMonthMenu" || this.emxClassName == "emxUICalendarYearMenu")
            	  {
            		  emxUICore.iterateFrames(function (objFrame) {
            			  if(objFrame){
                				  emxUICore.addEventHandler(objFrame, "mousedown", fnTemp, false);
                				  if (!isUnix) {
                				  emxUICore.addEventHandler(objFrame,"resize", fnTemp, false);
                				  }
            			  }
            		  });
            	  }
            	  else{
            		  emxUICore.iterateFrames(function (objFrame) {
            			  if(objFrame){
                				  if(objFrame.editableTable && objFrame.editableTable.divListBody){
                					  emxUICore.addEventHandler(objFrame.editableTable.divListBody, "scroll", fnTemp, false);
                					  emxUICore.addEventHandler(objFrame.editableTable.divTreeBody, "scroll", fnTemp, false);
                				  }
                				  emxUICore.addEventHandler(objFrame, "mousedown", fnTemp, false);
                				  if (!isUnix)emxUICore.addEventHandler(objFrame, "resize", fnTemp, false);
            			  }
            		  });
            	  }

              }
        this.visible = true;
        this.fireEvent("show");
       //Check if the menu is Dynamic
		if (this.dynamicJPO != null && this.dynamicJPO != "undefined"
			 && this.dynamicJPO != "")
		{
			createRequestObject();
		    var objectID=FORM_DATA['objectId'];
		    //Structure Browser timeStamp/uiType/objectId
		    var tempTimeStamp ;
		    var tempUIType ;
		    try
		    {
		    	 tempTimeStamp = timeStamp;
		    	 tempUIType = uiType;
				 //IR-076243V6R2012
				 if(objectID == null || objectID == 'undefined') {
					objectID = objectId;
				}
		    }
		    catch(e)
		    {
		    	//do nothing
		    }
		    //Table timeStamp/uiType
		    if (tempTimeStamp == null || tempTimeStamp == 'undefined')
		    {
		   		 tempTimeStamp=FORM_DATA['timeStamp'];
		   		 tempUIType=FORM_DATA['uiType'];
		   	}
		    var dynamicMenu = this.dynamicName;
			var dynamicJPO =this.dynamicJPO;
			var dynamicMethod = this.dynamicMethod;

			//added for bug : 342600
			var dynamicRMB = this.isRMB;
			var sbModeforDynamicMenu = "";
			if("oXML" in window){
				var sbModeSetting = emxUICore.selectSingleNode(oXML, "/mxRoot/setting[@name = 'sbMode']");
				sbModeforDynamicMenu = sbModeSetting ? emxUICore.getText(sbModeSetting) : sbModeforDynamicMenu;
			}
			//For Dynamic Submenus
			if(this.parent !=  null && this.parent != 'undefined')
			{
				eval(emxUICore.getData("emxUIDynamicMenu.jsp?sbModeforDynamicMenu="+sbModeforDynamicMenu+"&strJPO="+dynamicJPO+"&strMethod="+dynamicMethod+"&strName="+dynamicMenu+"&timeStamp="+tempTimeStamp+"&objectId="+objectID+"&uiType="+tempUIType+"&dynamicRMB="+dynamicRMB))
				objMenu.displayWindow = objThis.displayWindow;
				this.parent.addMenu(objMenu);
				objMenu.init();
				objMenu.setListLinks((parent.ids && parent.ids.length > 1));
				objThis.hide();
				objMenu.show1(objRef,strDir);
			}
			else
			{
				//Dynamic menus and commands directly on toolbar
				setTimeout(function() {
				//objThis.layer.style.visibility = "hidden";
				objThis.layer.style.display = "none";
				eval(emxUICore.getData("emxUIDynamicMenu.jsp?sbModeforDynamicMenu="+sbModeforDynamicMenu+"&strJPO="+dynamicJPO+"&strMethod="+dynamicMethod+"&strName="+dynamicMenu+"&timeStamp="+tempTimeStamp+"&objectId="+objectID+"&uiType="+tempUIType+"&dynamicRMB="+dynamicRMB))
				objMenu.displayWindow = objThis.displayWindow;
				objMenu.init();
				objMenu.setListLinks((parent.ids && parent.ids.length > 1));
				objMenu.show1(objRef, strDir);
				},100);
			}
		}

		var toolbar = objRef.parentNode.parentNode.parentNode.parentNode.id;
        /*if(toolbar != "globalToolbar"){
        	jQuery("div.menu-pointer", this.layer)[0].style.display = "none";
        }*/
		emxUICore.objElem = this;
};

function invokeShowMarkOnMenuItem(itemCount,menuPanel,elem){
	  		showMarkOnMenuItem(elem,menuPanel);
	   
	  }

//! Class emxUICoreMenuItem
//!     This object represents an item on a menu. This class is
//!     not intended to be instantiated directly, but rather is used
//!     as a base class for others to extend.
function emxUICoreMenuItem() {
        this.superclass = emxUIObject;
        this.superclass();
        delete this.superclass;
        this.emxClassName = "emxUICoreMenuItem";
        this.index = -1;
        this.parent = null;
        this.rowElement = null;
        this.uniqueID = emxUICore.getUniqueID();
}
emxUICoreMenuItem.prototype = new emxUIObject;
//! Private Method emxUICoreMenuItem.createDOM()
//!     This methods creates the DOM for a given menu item.
//!     objDoc (document) - document used to create elements.
//!     The DOM element representing this menu item.
emxUICoreMenuItem.prototype.createDOM = function _emxUICoreMenuItem_createDOM(objDoc) {
        this.rowElement = objDoc.createElement("li");
        if(this.icon && this.icon.indexOf('iconActionChecked.gif') >= 0) {
        	if(this.rowElement.className.indexOf("selected") < 0 ){
	        	emxUICore.addClass(this.rowElement, "selected");
	        }
        }
        this.rowElement.setAttribute("menuUID", this.uniqueID);
        this.rowElement.id = "li" + this.uniqueID;
        var objThis = this;
        this.rowElement.onmousedown = function () {
        	var objEvent = emxUICore.getEvent(objThis.parent && objThis.parent.displayWindow ? objThis.parent.displayWindow : null);
        	objThis.fireEvent("mousedown", objEvent);
        };
        //this.rowElement.onmousedown = function () { objThis.fireEvent("mousedown", emxUICore.getEvent()); };
        this.onmousedown = function () {
        	var objEvent = emxUICore.getEvent(objThis.parent && objThis.parent.displayWindow ? objThis.parent.displayWindow : null);
        	objThis.handleEvent("mousedown", objEvent);
        };

        return this.rowElement;
};
//! Private Method emxUICoreMenuItem.handleEvent()
//!     This method handles the events for this object.
emxUICoreMenuItem.prototype.handleEvent = function _emxUICoreMenuItem_handleEvent(strType, objEvent) {
        if (objEvent && strType=="mousedown") {
                objEvent.preventDefault();
                objEvent.stopPropagation();
        }
};
//! Private Method emxUICoreMenuItem.reset()
//!     This methods resets the item to its original view.
emxUICoreMenuItem.prototype.reset = function _emxUICoreMenuItem_reset() {
};
//! Private Method emxUICoreMenuItem.select()
//!     This methods selects the item.
emxUICoreMenuItem.prototype.select = function _emxUICoreMenuItem_select() {
};
//! Class emxUICoreMenuSeparator
//!     This object represents a menu separator.
function emxUICoreMenuSeparator() {
        this.superclass = emxUICoreMenuItem;
        this.superclass();
        delete this.superclass;
        this.emxClassName = "emxUICoreMenuSeparator";
}
emxUICoreMenuSeparator.prototype = new emxUICoreMenuItem;
//! Method emxUICoreMenuSeparator.createDOM()
//!     This method creates the DOM element for the separator.
emxUICoreMenuSeparator.prototype.emxUICoreMenuItemCreateDOM = emxUICoreMenuSeparator.prototype.createDOM;
emxUICoreMenuSeparator.prototype.createDOM = function _emxUICoreMenuSeparator_createDOM(objDoc) {
        this.emxUICoreMenuItemCreateDOM(objDoc);
        var objsep = objDoc.createElement("hr");
        this.rowElement.appendChild(objsep);
        return this.rowElement;
};
//! Class emxUICoreMenuLink
function emxUICoreMenuLink (strIcon, strText, strURL, strTarget) {
        this.superclass = emxUICoreMenuItem;
        this.superclass();
        delete this.superclass;
        this.emxClassName = "emxUICoreMenuLink";
        this.menu = null;
        this.target = strTarget;
        this.text = strText;
        this.url = strURL || "javascript:;";
        this.isJS = this.url.indexOf("javascript:") == 0;
        this.icon = (strIcon ? emxUICore.getIcon(strIcon) : null);
        this.dead = false;
        this.grayout = false;
        this.anchorElement = null;
}
emxUICoreMenuLink.prototype = new emxUICoreMenuItem;
//! Method emxUICoreMenuLink.addMenu()
//!     This method adds a popup menu to the menu link.
emxUICoreMenuLink.prototype.addMenu = function _emxUICoreMenuLink_addMenu(objMenu) {
        this.menu = objMenu;
        this.menu.parent = this;
};
//! Method emxUICoreMenuLink.click()
//!     This method handles the click event for this object.
emxUICoreMenuLink.prototype.click = function _emxUICoreMenuLink_click() {
        //if (!this.dead) {
                this.parent.hide(true);
                emxUICore.link(this.url, this.target);
        //}
};
//! Private Method emxUICoreMenuLink.createDOM()
//!     This method creates the DOM representation of the link.
emxUICoreMenuLink.prototype.emxUICoreMenuItemCreateDOM = emxUICoreMenuLink.prototype.createDOM;
emxUICoreMenuLink.prototype.createDOM = function _emxUICoreMenuLink_createDOM(objDoc, cntd) {
        if (this.menu) {
                /*if (isMinIE55 && isWin) {
                        this.menu.ownerWindow = this.parent.popup.document.parentWindow;
                } else {*/
                        this.menu.displayWindow = this.parent.displayWindow;
                //}
        }
        this.emxUICoreMenuItemCreateDOM(objDoc);
        var objanchor = this.rowElement;
        if(!this.menu){
        	objanchor.className= "link";
        	var hhref = this.url;
	    	if(this.url.indexOf("javascript") < 0) {
	    		hhref = "javascript:emxUICore.link(\"" + this.url + "\", '" +  this.target + "')";
	    	}
	    	if(this.icon && this.icon.indexOf('iconActionChecked.gif') >= 0) {
	        	emxUICore.addClass(this.rowElement, "selected");
	        }
	    }

    	var objspn = objDoc.createElement("span");
    	objspn.className = "icon";
    	objanchor.appendChild(objspn);
    	//icon merge
    	if(this.icon){
    	var objimg = objDoc.createElement("img");
    	objimg.src = this.icon;
    	objspn.appendChild(objimg);
    	 } else {
    		 objspn.style.backgroundImage = "url('../common/images/utilMmenuBullets.gif')";
    	 }
    	//icon merge
        var objspnt = objDoc.createElement("span");
        if(cntd){
        	objspnt.innerHTML = this.text;
        	var objem = objDoc.createElement("em");
        	objem.innerHTML = " ("+emxUIConstants.STR_CONTINUE+") ";
        	objspnt.appendChild(objem);
        } else {
        	objspnt.innerHTML = this.text;
        }
        objanchor.appendChild(objspnt);
       	if(this.grayout == "true"){
        	this.disable();
        }
        return this.rowElement;
};
//! Private Method emxUICoreMenuLink.disable()
//!     This method disables the menu item.
emxUICoreMenuLink.prototype.disable = function _emxUICoreMenuLink_disable() {
        this.dead = true;
        if (this.rowElement) {
        	jQuery(this.rowElement).addClass("disabled");
        }
};
//! Private Method emxUICoreMenuLink.enable()
//!     This method enables the menu item.
emxUICoreMenuLink.prototype.enable = function _emxUICoreMenuLink_enable() {
        this.dead = false;
        if (this.rowElement) {
        	jQuery(this.rowElement).removeClass("disabled");
    	}
};
//! Method emxUICoreMenuLink.handleEvent()
//!     This method handles the events for this object.
emxUICoreMenuLink.prototype.handleEvent = function _emxUICoreMenuLink_handleEvent(strType, objEvent) {
        switch(strType) {
                case "mousedown":
                        if (objEvent) {
                        	objEvent.cancelBubble = true;
                        	objEvent.returnValue = false;
                        	if (objEvent.stopPropagation) {
                        		objEvent.stopPropagation();
                        		objEvent.preventDefault();
                        	}
                        }
                        if (!this.dead) {
                        this.click();
                        }
                        break;
                /*case "mouseover":
                        if (isMinIE55 && isWin && this.parent.popup.document.parentWindow.event.srcElement.tagName != "TD") {
                                return;
                        }
                        this.parent.selectItem(this);
                        break;*/
        }
};
//! Private Method emxUICoreMenuLink.reset()
//!     This method resets the view of the menu link.
emxUICoreMenuLink.prototype.reset = function _emxUICoreMenuLink_reset() {
        if(this.rowElement){
        	if(! jQuery(this.rowElement).hasClass("selected")){
            	this.dead ?   jQuery(this.rowElement).addClass("disabled") : jQuery(this.rowElement).removeClass("disabled");
            }
        }
};
//! Private Method emxUICoreMenuLink.select()
//!     This method selects the menu link.
emxUICoreMenuLink.prototype.select = function _emxUICoreMenuLink_select() {
        if (!this.dead) {
                emxUICore.addClass(this.rowElement, "menu-item-selected");
                /*if (this.menu) {
                        emxUICore.addClass(this.rowElement, "submenu-selected");
                        this.menu.show(this.rowElement, "right");
                }*/
        }
};
//! Class emxUICoreMenuTitle
function emxUICoreMenuTitle (strText) {
        this.superclass = emxUICoreMenuItem;
        this.superclass(strText);
        delete this.superclass;
        this.emxClassName = "emxUICoreMenuTitle";
        this.text = strText;
}
emxUICoreMenuTitle.prototype = new emxUICoreMenuItem;
//! Private Method emxUICoreMenuTitle.getDOM()
//!     This methods creates the DOM the menu title.
//!     objDoc (document) - document used to create elements.
//!     The DOM element representing this menu item.
emxUICoreMenuTitle.prototype.emxUICoreMenuItemCreateDOM = emxUICoreMenuTitle.prototype.createDOM;
emxUICoreMenuTitle.prototype.createDOM = function _emxUICoreMenuTitle_createDOM(objDoc) {
        this.emxUICoreMenuItemCreateDOM(objDoc);
        var objTD = objDoc.createElement("td");
        this.rowElement.appendChild(objTD);
        objTD.className = "menu-title";
        objTD.innerHTML = this.text;
        return this.rowElement;
};
//! Class emxUIMenu
//!     This object represents a menu.
function emxUIMenu() {
        this.superclass = emxUICorePopupMenu;
        this.superclass();
        delete this.superclass;
        this.emxClassName = "emxUIMenu";
}
emxUIMenu.prototype = new emxUICorePopupMenu;
//! Class emxUIMenuSeparator
//!     This object represents a menu separator.
function emxUIMenuSeparator() {
        this.superclass = emxUICoreMenuSeparator;
        this.superclass();
        delete this.superclass;
        this.emxClassName = "emxUIMenuSeparator";
}
emxUIMenuSeparator.prototype = new emxUICoreMenuSeparator;
//! Class emxUIMenuItem
function emxUIMenuItem (strIcon, strText, strURL, strTarget) {
        this.superclass = emxUICoreMenuLink;
        this.superclass(strIcon, strText, strURL, strTarget);
        delete this.superclass;
        this.emxClassName = "emxUIMenuItem";
        this.menu = null;
        this.target = strTarget;
        this.text = strText;
        this.url = strURL || "";
        this.isJS = this.url.indexOf("javascript:") == 0;
        this.icon = (strIcon ? emxUICore.getIcon(strIcon) : null);
        this.dead = false;
}
emxUIMenuItem.prototype = new emxUICoreMenuLink;
//! Class emxUIMenuTitle
function emxUIMenuTitle(strText) {
        this.superclass = emxUICoreMenuTitle;
        this.superclass(strText);
        delete this.superclass;
        this.emxClassName = "emxUIMenuTitle";
}
emxUIMenuTitle.prototype = new emxUICoreMenuTitle;

//Method parses the document.location.search
//and add the key - value pair in an Array
function createRequestObject() {
  FORM_DATA = new Object();
  var separator = ',';
  query = '' + this.location;
  qu = query
  query = query.substring((query.indexOf('?')) + 1);
  if (query.length < 1) { return false; }
  keypairs = new Object();
  numKP = 1;
  var keyName;
  var keyValue;
  while (query.indexOf('&') > -1) {
    keypairs[numKP] = query.substring(0,query.indexOf('&'));
    query = query.substring((query.indexOf('&')) + 1);
    numKP++;
  }
  keypairs[numKP] = query;
  for (i in keypairs) {
    keyName = keypairs[i].substring(0,keypairs[i].indexOf('='));
    keyValue = keypairs[i].substring((keypairs[i].indexOf('=')) + 1);
    while (keyValue.indexOf('+') > -1) {
      keyValue = keyValue.substring(0,keyValue.indexOf('+')) + ' ' + keyValue.substring(keyValue.indexOf('+') + 1);
      }
    keyValue = unescape(keyValue);
    if (FORM_DATA[keyName] && keyName == "emxTableRowId")
    {
        FORM_DATA[keyName] = FORM_DATA[keyName] + separator + keyValue;
    }
    else if(!FORM_DATA[keyName])
    {
        FORM_DATA[keyName] = keyValue;
    }
  }
  return FORM_DATA;
}
//Show method for Dynamic Menu/Commands
emxUICorePopupMenu.prototype.show1 = function _emxUICorePopupMenu_show1(objRef, strDir) {
        var objThis = this;
        var intX, intY;
        this.layer.className = "menu-panel page";
        var toolbar = objRef.parentNode.parentNode.parentNode.parentNode.id;
        /*if (isMinIE55 && isWin) {
                switch(strDir) {
                        case "down":
                        case "down-left":
                                intX = 0;
                                intY = objRef.offsetHeight;
                                this.reset();
                                break;
                        /*case "down-left":
                                intX = -this.finalWidth + objRef.offsetWidth;
                                intY = objRef.offsetHeight;
                                break;
                        case "right":
                                intX = objRef.offsetWidth;
                                intY = 0;
                                break;
                        default:
                                throw new Error("Required argument strDirection is not valid (value='" + strDir + "'). (emxUICoreMenu.js::emxUICoreMenu.prototype.show)");
                }
                emxUICore.show(this.layer);
        		if(this.doIEChange) {
        			this.doIEChange = false;
        			var templay = this.ownerWindow.document.createElement("div");
	        		templay.className = "mmenu";
	        		templay.innerHTML = this.layer.innerHTML;
	        		this.ownerWindow.document.body.appendChild(templay);
	        		var lh = templay.offsetHeight;
	        		this.ownerWindow.document.body.removeChild(templay);
	        		if(this.sbheight > 0) {
	        			this.menuborder.style.height = "" + lh + "px";
	        		}
	        		this.finalHeight = Math.min(lh, this.winheight);
        		}
                this.popup.show(intX, intY, this.finalWidth + 18, this.finalHeight + 4 + this.sbheight, objRef);

                //this.popup.show(intX, intY, this.finalWidth + 4, this.finalHeight, objRef);
                this.timeoutID = setTimeout(function () {
                        if (objThis.popup.isOpen) {
                                objThis.timeoutID = setTimeout(arguments.callee, emxUICoreMenu.WATCH_DELAY);
                        } else {
                                objThis.hide();
                        }
                }, emxUICoreMenu.WATCH_DELAY);
        } else {*/
                if (this.ownerWindow != this.displayWindow) {
                        switch(strDir) {
                                case "down":
                                case "down-left":
                                        intX = emxUICore.getActualLeft(objRef) + this.displayWindow.document.body.scrollLeft;
                                        intY = this.displayWindow.document.body.scrollTop;
                                        this.reset();
                                        break;
                                /*case "down-left":
                                        intX = emxUICore.getActualLeft(objRef) - this.templateInnerLayer.offsetWidth + objRef.offsetWidth + this.displayWindow.document.body.scrollLeft;
                                        intY = this.displayWindow.document.body.scrollTop;
                                        break;
                                case "right":
                                        intX = emxUICore.getActualLeft(objRef) + objRef.offsetWidth;
                                        intY = emxUICore.getActualTop(objRef);
                                        break;*/
                                default:
                                        throw new Error("Required argument strDirection is not valid (value='" + strDir + "'). (emxUICoreMenu.js::emxUICoreMenu.prototype.show)");
                        }
                        if (!this.displayWindow.document.getElementById("menu" + this.uniqueID)) {
                                this.createDOM(this.displayWindow.document);
                                this.layer.id = "menu" + this.uniqueID;
                        }
                } else {
                        switch(strDir) {
                                case "down":
                                case "down-left":
                                        intX = emxUICore.getActualLeft(objRef);
                                        intY = emxUICore.getActualTop(objRef) + objRef.offsetHeight;
                                        this.reset();
                                        break;
                                /*case "down-left":
                                        intX = emxUICore.getActualLeft(objRef) - this.templateInnerLayer.offsetWidth + objRef.offsetWidth;
                                        intY = emxUICore.getActualTop(objRef) + objRef.offsetHeight;
                                        break;
                                case "right":
                                        intX = emxUICore.getActualLeft(objRef) + objRef.offsetWidth;
                                        intY = emxUICore.getActualTop(objRef);
                                        break;*/
                                default:
                                        throw new Error("Required argument strDirection is not valid (value='" + strDir + "'). (emxUICoreMenu.js::emxUICoreMenu.prototype.show)");
                        }
                }
                var intFinalX = intX + this.templateInnerLayer.offsetWidth;
                var intFinalY = intY + this.finalHeight;
                if (intFinalX > emxUICore.getWinWidth(this.displayWindow) + this.displayWindow.document.body.scrollLeft) {
                        intX = this.displayWindow.document.body.scrollLeft + emxUICore.getWinWidth(this.displayWindow) - this.layer.offsetWidth;
                } else if (intX < 0) {
                        intX = 0;
                }
                if (intFinalY > emxUICore.getWinHeight(this.displayWindow) + this.displayWindow.document.body.scrollTop) {
                        intY = this.displayWindow.document.body.scrollTop + emxUICore.getWinHeight(this.displayWindow) - this.layer.offsetHeight;
                } else if (intY < 0) {
                        intY = 0;
                }
                if(toolbar == "globalToolbar" && emxUICore.getWinWidth(this.displayWindow) < (jQuery(this.layer).width() + intX)){
                	intX = intX - jQuery(this.layer).width()+objRef.offsetWidth;
                }

                emxUICore.moveTo(this.layer, intX, intY);
                /* This logic is added just for IE for those pages which have ActiveX or Applets in their pages.
            	   * To show the menu on top of the objects this logic is introduced. Once IE problem is fixed in the
            	   * browser then this code needs to be removed
            	   */
            	  if(isIE && !this.visible) {
            		  var menu = this;
            		  setTimeout(function(){
            			  var doc = menu.displayWindow ? menu.displayWindow.document : document;
            			  var ieMenuCoverForObjectTag = doc.createElement('iframe');
            			  ieMenuCoverForObjectTag.id='ieMenuCoverForObjectTag';
            			  ieMenuCoverForObjectTag.style.position='absolute';
            			  ieMenuCoverForObjectTag.style.width = menu.layer.clientWidth + 'px';
            			  ieMenuCoverForObjectTag.style.height = menu.layer.clientHeight + 'px';
            			  ieMenuCoverForObjectTag.style.top = (menu.layer.offsetTop) + 'px';
            			  ieMenuCoverForObjectTag.style.left = (menu.layer.offsetLeft) + 'px';
						  //Added for IR-179823V6R2013x.
            			  //Applying inline styling(minHeight) for this iFrame, this should be removed when the false frame is removed
            			  ieMenuCoverForObjectTag.style.minHeight="auto";
            			  ieMenuCoverForObjectTag.style.zIndex='99';
            			  ieMenuCoverForObjectTag.setAttribute('frameborder','0');
            			  ieMenuCoverForObjectTag.setAttribute('src','javascript:false;');
            			  doc.body.appendChild(ieMenuCoverForObjectTag);
            		  },30);
            	  }
            	  /*  Special Code for Activex and Obejcts End*/
                //emxUICore.show(this.layer);
                this.layer.style.display = "block";

                //this.fnTemp = fnTemp = function () { objThis.hide();};

                this.fnTemp = fnTemp = function (e) {
    		  		var target= e.target;
    		  		if(target && jQuery(target).closest(".menu-panel").length ==0) {
        		                                objThis.hide();
    		  		}
											};


                emxUICore.iterateFrames(function (objFrame) {
                	if(objFrame){
                		 emxUICore.addEventHandler(objFrame,"mousedown", fnTemp, false);
                            if (!isUnix)  emxUICore.addEventHandler(objFrame,"resize", fnTemp, false);
                	}
                });
                	//}

                /*if(jQuery("div.menu-pointer", this.layer).length > 0){
       	jQuery("div.menu-pointer", this.layer)[0].style.display = "none";
                }*/

        this.visible = true;
        this.fireEvent("show");
   };

/* V6R2014 - To support new Menu's
 * To Caculate the Height of menu and show teh scroll bar if needed.*/
   function adjustMenuHeight(menuElem, isMyDesk){
		var menuHeight = menuElem[0].clientHeight;
		var percentageHeight = 0.75;
		//For Mobile setting the Percentage to 40% as the
		//clientHeight is not giving the correct value.
		/*if(getTopWindow().isMobile){
			percentageHeight = 0.6;
		}*/
		if(isMyDesk){
			percentageHeight = 0.9;
		}
	   var tempHt = parseInt((emxUICore.getWinHeight() - emxUICore.getActualTop(menuElem[0])) * percentageHeight);
	   if((jQuery(':visible', menuElem).last().offset() && jQuery(':visible', menuElem).last().offset().top < tempHt) || menuElem[0].clientHeight < tempHt){
		   menuElem[0].removeAttribute("style");
	   }
	   if(menuElem[0].clientHeight > tempHt){
		   menuElem[0].setAttribute("style","height:"+tempHt+"px");
		}
	}


	/* To adjust the RMB menu height if the RMB menu size is morethan the window height.*/
	function adjustRMBMenuHeight(menuElem, intY, menuHeight){	
		
		if(intY < menuHeight){
			intY = parseInt(menuHeight * 0.90) ;
		}else{
			intY = parseInt(intY * 0.90) ;
		}	   
		menuElem[0].setAttribute("style","height:"+intY+"px");		
	}

   function toggleAttrAndCheckmark(elem){
	   if(jQuery(elem).attr('active')=="true"){
		   jQuery(elem).attr('active', "false");
		   jQuery(elem).removeClass("selected");
	   } else {
		   jQuery(elem).attr('active', "true");
		   jQuery(elem).addClass("selected");
	   }
   }
   function  getActiveRoles(elem){
	   var activeRoles = "";
	   for(var count = 0 ; count < elem.length ; count++) {
		   console.log(jQuery(elem[count]).attr("id"));
		   if(activeRoles==""){
			   activeRoles = jQuery(elem[count]).attr("id");
		   } else {
			   activeRoles += "," + jQuery(elem[count]).attr("id");
		   }
	   }
	   return activeRoles;
   }

   function onTopBarClick() {
	   require(['i3DXCompass/i3DXCompass'], function (Compass) {
		   Compass.onRoleChange();
	   });
   }


/* V6R2014 - To support new Menu's
 * To show the Tick Mark on teh selected Menu items*/
function showMarkOnMenuItem(elem,divHolder){
	if(jQuery('li.selected',divHolder).length > 0  && elem.className.indexOf("subgroup")<0){
		jQuery('li.selected',divHolder)[0].childNodes[0].childNodes[0].className="";
		jQuery('li.selected',divHolder).toggleClass("selected");
	}
	if(elem.localName=="ul"){
		jQuery(elem).toggleClass("selected");
	}else if(elem.localName=="li"){
		jQuery(elem).toggleClass("selected");
		jQuery(elem)[0].childNodes[0].childNodes[0].setAttribute("class","checked");
	}else{
		if(elem.className.indexOf("subgroup")<0 && elem.parentNode.parentNode.className.indexOf("subgroup")<=0)
			jQuery(elem).toggleClass("selected");
	}
}

/* V6R2014 - To support new Menu's
 * To Update the Global Text box search and it;'s hidden values.*/
function updateSearchField(typeOfsearch, value,forSavedSearches){
	if(typeOfsearch == "All_Search"){
		value= emxUIConstants.SEARCH_ALL;
	}
	var tempVal="";
	value = value.replace("...","");
	if(value.length>14 || ("ja" == emxUIConstants.BROWSER_LANGUAGE && value.length>9)){
		if("ja" == emxUIConstants.BROWSER_LANGUAGE){
			tempVal = value.substring(0, 8);
		}else{
		tempVal = value.substring(0, 13);
		}
		tempVal = tempVal+"...";
	}else{
		tempVal = value;
	}
	jQuery('#AEFGlobalFullTextSearch')[0].children[0].innerHTML = '<label>' +tempVal+ '</label>';
	if(typeof forSavedSearches!="undefined" && forSavedSearches=="searchPage"){
		typeOfsearch = "fromGlobalSearch"+typeOfsearch;
	}
	jQuery('#AEFGlobalFullTextSearch')[0].setAttribute("typeName",typeOfsearch);
	var objTextBox = document.getElementById("GlobalNewTEXT");
    textboxClicked(objTextBox);

    /*var srchcxtwidth = jQuery('.search-context').innerWidth();
	if(jQuery('.search-input')[0]){
		jQuery('.search-input')[0].style.left = srchcxtwidth + "px";
	}*/
	}
