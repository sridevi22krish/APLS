/*!================================================================
 * JavaScript Methods for emxCustomizedTable.jsp
 * Version 1.0
 *
 *  Copyright (c) 2008-2015 Dassault Systemes, 1993 2007. All rights reserved
 *  This program contains proprietary and trade secret information 
 *  of Dassault Systemes. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *  $Id: emxUITableCustom.js.rca 1.12.3.2 Wed Oct 22 15:48:56 2008 przemek Experimental przemek $
 *=================================================================
 */ 
//Global Varibles required for this file.

var lastIndex = new Array();
var ColumnsText = new Array();
var ColumnsValue = new Array();
var selectedColumns = new Array();
var selectedDirection = new Array();
var derivedTablelist = new Array();
var newValue;

// function to move the option elements from VisibleColumns to Availablecolumns

function moveLeft()
{
	
	var emxtableName=document.getElementById("emxtable").value;
	var availableColumn = document.customtable.AvailableColumn;
	if(availableColumn)
	{
		var len = availableColumn.options.length;
		for(i=0;i<len;i++)
		{
			availableColumn.options[i].selected = false;
		}
	}
	
	// Checking aleast one option should be selected to move
	if(document.customtable.VisibleColumn.options.selectedIndex < 0)
	{
		alert(SELECTBOX_MOVE_MSG);
	}
	else
	{
		var len;
		for(i=0;i<document.customtable.VisibleColumn.options.length;i++)
		{
			if(document.customtable.VisibleColumn.options[i].selected)
			{
				var value = document.customtable.VisibleColumn.options[i].value;
				var text = document.customtable.VisibleColumn.options[i].text;	
				//START Mandatory fields included for Redmine #7270
				if(emxtableName.endsWith("MGS_ENCEBOMIndentedSummarySB")) {
					if((value.search("separator")<0) && (value.search("Separator")<0) && text !="Part Number" && text !="Type" && text !="F/N" && text !="Qty" && text !="Unit of Measure" && text !="Ref Des" && text !="Usage UOM Type")
					{
					var myOption = document.createElement("Option");
					myOption.text = text;
					myOption.value = value;
					myOption.title = text;
					try
					{
						document.customtable.AvailableColumn.add(myOption); // IE
					}
					catch(e)
					{
						len = document.customtable.AvailableColumn.options.length;
						var oldOption = document.customtable.AvailableColumn.options[len];   // Mozilla,Netscape
						document.customtable.AvailableColumn.add(myOption,oldOption);
					}
					
					} else {
						alert(text+" columns is mandatory and cann't be removed");
					}
					if((value.search("separator")<0) && (value.search("Separator")<0) && text !="Part Number" && text !="Type" && text !="F/N" && text !="Qty" && text !="Unit of Measure" && text !="Ref Des" && text !="Usage UOM Type")
					{
						len = document.customtable.AvailableColumn.options.length;
						document.customtable.AvailableColumn.options[len-1].selected=true;
					}
					if( value.search("paneSeparator")<0  && text !="Part Number" && text !="Type" && text !="F/N" && text !="Qty" && text !="Unit of Measure" && text !="Ref Des" && text !="Usage UOM Type")
					{
						document.customtable.VisibleColumn.remove(i);
					}
					else
					{
						document.customtable.VisibleColumn.options[i].selected = false;
					}
					//END Mandatory fields included for Redmine #7270
				} else {
					
					if((value.search("separator")<0) && (value.search("Separator")<0))
					{
					var myOption = document.createElement("Option");
					myOption.text = text;
					myOption.value = value;
					myOption.title = text;
					try
					{
						document.customtable.AvailableColumn.add(myOption); // IE
					}
					catch(e)
					{
						len = document.customtable.AvailableColumn.options.length;
						var oldOption = document.customtable.AvailableColumn.options[len];   // Mozilla,Netscape
						document.customtable.AvailableColumn.add(myOption,oldOption);
					}
					
					} else {
					alert(text+" columns is mandatory and cann't be removed");
					}
					if((value.search("separator")<0) && (value.search("Separator")<0) )
					{
						len = document.customtable.AvailableColumn.options.length;
						document.customtable.AvailableColumn.options[len-1].selected=true;
					}
					if( value.search("paneSeparator")<0  && text !="Part Number")
					{
						document.customtable.VisibleColumn.remove(i);
					}
					else
					{
						document.customtable.VisibleColumn.options[i].selected = false;
					}
				}
				
				i--;
				document.customtable.colWidth.value="";
				
			}
		} 
		// To update the option element values in MultiColumn Sort
		if(document.customtable.multiColumnSort.value != "false"){
			setColumn();
			optionElement(document.customtable.firstColumn);
			populateSecondOption();
			populateThirdOption();
			for(var i=0;i<document.customtable.firstColumn.options.length;i++)
			{
				if(document.customtable.firstColumn.options[i].selected)
				{
					var selectedElement = document.customtable.firstColumn.options[i].value;
					if(selectedElement == "None")
					{
						document.customtable.secondColumn.options[0].selected = true;
						document.customtable.thirdColumn.options[0].selected = true;
					}
				}
			}
			for(var i=0;i<document.customtable.secondColumn.options.length;i++)
			{
				if(document.customtable.secondColumn.options[i].selected)
				{
					var selectedElement = document.customtable.secondColumn.options[i].value;
					if(selectedElement == "None")
					{
						document.customtable.thirdColumn.options[0].selected = true;
					}
				}
			}
		}
	}
 }
 
 // function to move the option elements from Availablecolumns to VisibleColumns 
 
function moveRight()
{
	
	var visibleColumn = document.customtable.VisibleColumn;
	if(visibleColumn)
	{
		var len = visibleColumn.options.length;
		for(i=0;i<len;i++)
		{
			visibleColumn.options[i].selected = false;
		}
	}
	
	// Checking aleast one option should be selected to move
	if(document.customtable.AvailableColumn.options.selectedIndex < 0)
	{
		alert(SELECTBOX_MOVE_MSG);
	}
	else
	{
		for(i=0;i<document.customtable.AvailableColumn.options.length;i++)
		{
								
			if(document.customtable.AvailableColumn.options[i].selected)
			{
				var value = document.customtable.AvailableColumn.options[i].value;
				var text = document.customtable.AvailableColumn.options[i].text;				
				var myOption = document.createElement("Option");				
				myOption.text = text;
				myOption.value = value;
				myOption.title = text;
				
				try
				{
					//START modified for QC5628 - to Check duplicate column values
					var uniquecheck=true;
					for(k=0;k<document.customtable.VisibleColumn.options.length;k++)
					{
						var vText = document.customtable.VisibleColumn.options[k].text;	
						
						if(text === vText && "[Separator]" != vText ) {
							uniquecheck=false;
							break;
						}
					}
					if(uniquecheck)
					{
						document.customtable.VisibleColumn.add(myOption);		// IE
					} else {
						alert(text+" "+DUPLICATE_COLUMN);
						//document.customtable.AvailableColumn.options[i].selected =false;
						document.customtable.AvailableColumn.remove(i);	
						i--;
						continue;
					}
					//END modified for QC5628 - to Check duplicate column values
				}
				catch(e)
				{
					var len = document.customtable.VisibleColumn.options.length;
					var oldOption = document.customtable.VisibleColumn.options[len];	// Mozilla,Netscape
					//START modified for QC5628 - to Check duplicate column values
					if(uniquecheck)
					{
						document.customtable.VisibleColumn.add(myOption,oldOption);
					} else {
						alert(text+DUPLICATE_COLUMN);
						//document.customtable.AvailableColumn.options[i].selected =false;
						document.customtable.AvailableColumn.remove(i);	
						i--;
						continue;
					}
					//END modified for QC5628 - to Check duplicate column values
				}
				if((value.search("separator")<0) && (value.search("Separator")<0) )
				{
					document.customtable.AvailableColumn.remove(i);	
					i--;
				}	
					len = document.customtable.VisibleColumn.options.length;
					document.customtable.VisibleColumn.options[len-1].selected=true;
			}
		} 
		var widthBox = document.getElementById("colWidth");
		widthBox.value="";
		// To update he option element values in MultiColumn Sort
		if(document.customtable.multiColumnSort.value != "false"){
		setColumn();
		optionElement(document.customtable.firstColumn);
		populateSecondOption();
		populateThirdOption();
		}
		
	}
}

function remove()
{
	var emxtableName=document.getElementById("emxtable").value;
	if(document.customtable.AvailableColumn.options.length==0)
	{
		alert(SELECTBOX_MOVE_MSG);
	}
	
	for(i=0;i<document.customtable.VisibleColumn.options.length;i++)
	{
		var value = document.customtable.VisibleColumn.options[i].value;
		var text = document.customtable.VisibleColumn.options[i].text;	
		//START Mandatory fields included for Redmine #7270
		if(emxtableName.endsWith("MGS_ENCEBOMIndentedSummarySB")) {
			if(value.search("paneSeparator")<0 &&  text !="Part Number" && text !="Type" && text !="F/N" && text !="Qty" && text !="Unit of Measure" && text !="Ref Des" && text !="Usage UOM Type")
			{
				if((value.search("Separator")<0))
				{
					var myOption = document.createElement("Option");
					myOption.text = text;
					myOption.value = value;
					myOption.title = text;
					try
					{
						document.customtable.AvailableColumn.add(myOption);     //IE
					}
					catch(e)
					{
						var len = document.customtable.AvailableColumn.options.length;
						var oldOption = document.customtable.AvailableColumn.options[len];     // Mozilla,Netscape
						document.customtable.AvailableColumn.add(myOption,oldOption);
					}
				}
			} 
			//Mandatory fields included for Redmine #7270
			if(value.search("paneSeparator")<0 && text !="Part Number" && text !="Type" && text !="F/N" && text !="Qty" && text !="Unit of Measure" && text !="Ref Des" && text !="Usage UOM Type")
			{
				document.customtable.VisibleColumn.remove(i);	
				i--;
			}
			//END Mandatory fields included for Redmine #7270
		} else {
			if(value.search("paneSeparator")<0 )
			{
				if((value.search("Separator")<0))
				{
					var myOption = document.createElement("Option");
					myOption.text = text;
					myOption.value = value;
					myOption.title = text;
					try
					{
						document.customtable.AvailableColumn.add(myOption);     //IE
					}
					catch(e)
					{
						var len = document.customtable.AvailableColumn.options.length;
						var oldOption = document.customtable.AvailableColumn.options[len];     // Mozilla,Netscape
						document.customtable.AvailableColumn.add(myOption,oldOption);
					}
				}
			} 
			//Mandatory fields included for Redmine #7270
			if(value.search("paneSeparator")<0 )
			{
				document.customtable.VisibleColumn.remove(i);	
				i--;
			}
		}
								   	
	}
	if(emxtableName.endsWith("MGS_ENCEBOMIndentedSummarySB")) {
			alert("Columns in Red are mandatory and cann't be removed");
	}
	
	
	// To update the option element values in MultiColumn Sort
	if(document.customtable.multiColumnSort.value != "false"){
		setColumn();
		optionElement(document.customtable.firstColumn);
		populateSecondOption();
		populateThirdOption();
		document.customtable.firstColumn.options[0].selected = true;
		document.customtable.secondColumn.options[0].selected = true;
		document.customtable.thirdColumn.options[0].selected = true;
		}
}
function moveUp()
{
	var selectBox = document.customtable.VisibleColumn;
	if(selectBox)
	{
		var visLen =  selectBox.length;
		if((document.customtable.VisibleColumn.options.selectedIndex < 0) || (document.customtable.VisibleColumn.options.length==0))
		{
			alert(SELECTBOX_MOVE_MSG);
		}
		else if(document.customtable.VisibleColumn.options.selectedIndex <= 0)
		{
			// Do nothing
		}
		else
		{
			
			for(i=0;i<selectBox.options.length;i++)
			{
				if(selectBox.options[i].selected)
				{
					text = selectBox.options[i].text;
					value = selectBox.options[i].value;
					title = selectBox.options[i].title;
					if((value.indexOf('paneSeparator')!=-1) && (i<=1))
					{
						alert(FREEZE_PANE_COLUMN);
					}
					else
					{
						if((selectBox.options[i-1].value.indexOf('paneSeparator')!=-1) && (i==selectBox.options.length-1))
						{
							alert(FREEZE_PANE_COLUMN);
						}	
						else
						{
							selectBox.options[i].text = selectBox.options[i-1].text;
							selectBox.options[i].value =selectBox.options[i-1].value;
							selectBox.options[i].title =selectBox.options[i-1].text;
							selectBox.options[i-1].text = text;
							selectBox.options[i-1].value = value;
							selectBox.options[i-1].title = text;
							selectBox.options[i-1].selected = true;
							selectBox.options[i].selected = false;	
						}
					}
				}
			}
			// To update the option element values in MultiColumn Sort
			setColumn();
			
		}
	}
	
}
function moveDown()
{
	var selectBox = document.customtable.VisibleColumn;
	if(selectBox)
	{
		var visColLen = selectBox.length;
		if((selectBox.options.selectedIndex < 0) || (selectBox.options.length==0))
		{
			alert(SELECTBOX_MOVE_MSG);
		}
		else
		{
			for(i=selectBox.options.length;i>0;i--)
			{
				if(selectBox.options[i-1].selected && i==visColLen)
					break;
				if(selectBox.options[i-1].selected && i!=visColLen)
				{
					text = selectBox.options[i-1].text;
					value = selectBox.options[i-1].value;					
					if((value.indexOf('paneSeparator')!=-1) && (i==selectBox.options.length-1))
					{
						alert(FREEZE_PANE_COLUMN);
					}
					else
					{
						if((selectBox.options[i].value.indexOf('paneSeparator')!=-1) && (i==1))
						{
							alert(FREEZE_PANE_COLUMN);
						}	
						else
						{
							selectBox.options[i-1].text = selectBox.options[i].text;
							selectBox.options[i-1].value =selectBox.options[i].value;
							selectBox.options[i-1].title =selectBox.options[i].text;
							selectBox.options[i].text = text;
							selectBox.options[i].value = value;
							selectBox.options[i].title = text;
							selectBox.options[i-1].selected = false;
							selectBox.options[i].selected = true;
						}
					}
				}
			}
			// To update the option element values in MultiColumn Sort
			setColumn();
			
		}
	}
	
}

 // Submit form
 function submitForm(uiType)
 {
	
	//Checking for the VisibleColumns is empty
	if(uiType=='table' && document.customtable.VisibleColumn.options.length<=0)
 	{
 		alert(VISIBLECOLUMN_LENGTH_MSG);
 		return;
 		
 	}
 	else if(uiType =='structureBrowser' && document.customtable.VisibleColumn.options.length<=2)
 	{
 		alert(SB_COLUMN_NO);
 		return;
 	}
 	
 	//Validation for Name field
 	else if(document.customtable.txtCustomTextBox.value=="")
 	{
 		alert(TABLENAME_ALERT_MSG);
 		return;
 	}
 	//parsing the value to send to process page
 	else
 	{
	 	var visibleColumn = document.customtable.VisibleColumn.options;
		if(visibleColumn && visibleColumn.length >0)
		{
			var len = visibleColumn.length;
			var flag =0;
			for(var i=0;i<len;i++)
			{
				var optionValue = visibleColumn[i].value;
				if((optionValue.indexOf("Separator")>= 0) || (optionValue.indexOf("paneSeparator")>= 0))
					flag=1;
				else
				{
					flag=0;
					break;
				}
					
			}
			if(uiType=='structureBrowser' && visibleColumn[0].text.indexOf("Freeze Pane Separator")>=0)
			{
				alert(FREEZE_PANE_COLUMN);
				return;
			}
			else if(uiType=='structureBrowser' && visibleColumn[0].value.indexOf("Separator")>=0)
			{
				alert(SB_FIRST_COLUMN);
				return;
			}
			else if(flag == 1)
			{
				alert(VALID_COLUMN);
				return;
			}
			else
	 		{	
				if(document.customtable.multiColumnSort.value != "false"){
		 		var index = document.customtable.firstColumn.options.selectedIndex;
			 	var value = document.customtable.firstColumn.options[index].value;
			 	if(index>0)
			 	{
				 	document.customtable.hdnFirstColumn.value = value.substring(0,value.indexOf("|"))
				}
				index = document.customtable.secondColumn.options.selectedIndex;
				if(index>0)
			 	{
			 		value = document.customtable.secondColumn.options[index].value;
			 		document.customtable.hdnSecondColumn.value = value.substring(0,value.indexOf("|"))
			 	}
			 	index = document.customtable.thirdColumn.options.selectedIndex;
			 	if(index>0)
			 	{
				 	value = document.customtable.thirdColumn.options[index].value;
				 	document.customtable.hdnThirdColumn.value = value.substring(0,value.indexOf("|"))
				}
				
				//Multicolumn Sort value
				
				if(document.customtable.firstSortDirection[0].checked){
					document.customtable.hdnFirstColumnDirection.value = "ascending";	
				}else {
					document.customtable.hdnFirstColumnDirection.value = "descending";	
					}
				if(document.customtable.secondSortDirection[0].checked){
					document.customtable.hdnSecondColumnDirection.value = "ascending";	
				}else {
					document.customtable.hdnSecondColumnDirection.value = "descending";	
					}
				if(document.customtable.thirdSortDirection[0].checked){
					document.customtable.hdnThirdColumnDirection.value = "ascending";	
				}else {
					document.customtable.hdnThirdColumnDirection.value = "descending";	
					}
				}
			 	 	var columnValue = new Array();
					var columnText = new Array(); 
				 	var selectBox = document.customtable.VisibleColumn;
				 	for(i=0;i<selectBox.options.length;i++)
				 	{
				 		columnText[i] = selectBox.options[i].text;
				 		columnValue[i] = selectBox.options[i].value;
				 	}
				 	document.customtable.columnsText.value = columnText.valueOf();
				 	document.customtable.customTableColValue.value = columnValue.valueOf();
				 	document.customtable.action="emxCustomizeTableProcess.jsp";
				 	document.customtable.submit(); 
	 		}
		}
	 	
	}
 }
 
 //Getting the Value of the Column User Selected
 
 function getColumnValue()
 {
 	var selectBox = document.customtable.VisibleColumn;
 	var selectedIndex = selectBox.options.selectedIndex;
 	var columnValue = selectBox.options[selectedIndex].value; 
	return columnValue;
 }
 
 //Display the width of the Column in the Width Textbox of emxCustomizedTable.jsp
 
 function displayWidth()
 {
 	var selectBox = document.customtable.VisibleColumn;
 	if(selectBox && typeof selectBox != "undefined")
 	{
	 	var selectedIndex = selectBox.options.selectedIndex;
	 	if(selectedIndex >= 0)
	 	{
		 	var columnValue = selectBox.options[selectedIndex].value; 
		 	var columnWidth = columnValue.substring(columnValue.indexOf("~")+1,columnValue.length);
		 	if(columnWidth.search('default')>0 || columnWidth==0.0)
		 	{
		 		columnWidth='';
		 	}
		 	document.customtable.colWidth.value = columnWidth;
		 	if(lastIndex=='undefined')
		 	{
		 		lastIndex = selectedIndex;
		 	}
	 	}
 	}
 }
 //Width Validation, aleast one column to be selected before changing the width
 function validate()
 {
  	if(document.customtable.VisibleColumn.options.selectedIndex<0)
 	{
 		alert(WIDTH_MESSAGE_MSG); 
 		document.customtable.txtCustomTextBox.focus();
 		
 	}
 	else
 	{
 		var selectBox = document.customtable.VisibleColumn;
 		var j=0;
 		lastIndex.length=0;
	 	for(i=0;i<selectBox.options.length;i++)
	 	{
	 		if(selectBox.options[i].selected)
	 		{
	 			lastIndex[j] = i;
	 			j++;
	 		}
		}
 	}
 }
 
 //Updating the width of the column when user entered the value
 // Updated the method for bug no 348985
 function setWidth(textbox)
 {
 	var newValue = textbox.value;
 	var selectBox = document.customtable.VisibleColumn;
 	for(i=0;i<lastIndex.length;i++)
 	{
	 	var columnValue = selectBox.options[lastIndex[i]].value;
	 	var columnvalueArray = columnValue.split("~");
	 	columnvalueArray[1]=newValue;
	 	columnValue = columnvalueArray.join("~");
	 	document.customtable.VisibleColumn.options[lastIndex[i]].value = columnValue;
 	}
 	// End
 }
 
 //Validation for widht. 
 //User should enter any value like alphabets or special characters
 function validateWidth(e)
 {
 	var widthBox = document.getElementById("colWidth");
 	if (!isIE)
		Key = e.which;
	else
		Key = window.event.keyCode;

	if ((Key >= 48 && Key <= 57)|| Key==0 ||Key==8)
	{
		return true;
	}
	else
		return false;
 }
 
 
 //Updating the sortcolumn array in emxUIMultiColumnSort.js
 function setColumn()
 {
 	ColumnsText.length=0;
 	ColumnsValue.length=0;
 	ColumnsText.push(NONE_LABEL);
 	ColumnsValue.push("None");
 	var selectBox = document.customtable.VisibleColumn;
 	for(i=0;i<selectBox.options.length;i++)
 	{
 		var temp = selectBox.options[i].value;
 		if((temp.search('separator')<0) && (temp.search('Separator')<0))
 		{
 			if((temp.search("system@")>=0) || (temp.search("hidden@")>=0))
 			{
 				if(temp.search("true")>0)
 				{
 					ColumnsText.push(selectBox.options[i].text);
			 		ColumnsValue.push(temp);
			 	}
		 	}
		 	else if((temp.search("dynamic@Snippets")<0))
		 	{
		 		ColumnsText.push(selectBox.options[i].text);
			 	ColumnsValue.push(temp);
		 	}
		 	
	 	}
 	}
 	setSortColumnsArray(ColumnsValue,ColumnsText);
 }
 
 //if multiColumnSort parameter is false in url then the multicolumn sort is disabled.
 
 function disableSort(element)
 {
	var input = document.getElementById(element).getElementsByTagName("input");
	var select = document.getElementById(element).getElementsByTagName("select");
	for(var i = 0; i < input.length; i++)
	{
		input[i].setAttribute("disabled","true");
	}
	for(var i = 0; i < select.length; i++)
	{
		select[i].setAttribute("disabled","true");
	}
 }
 
 //submitting the form when user presses enter key
 function submitFunction(e)
 {
 	if (!isIE)
		Key = e.which;
	else
		Key = window.event.keyCode;

	if (Key == 13)
		validateNameField();
	else
		return;
 }
 

