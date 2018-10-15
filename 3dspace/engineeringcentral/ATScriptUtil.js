//This file is added to include java script utility - Added for QC 4642 External Request #6546
function atCloseWindow()
{
   //Start - QC4859 External Request [Redmine-7277]
   var contentWindow = getTopWindow().findFrame(getTopWindow(),'detailsDisplay');
   //End - - QC4859 External Request [Redmine-7277]
   //Fixed QC 4642 External Request #6546 - START
   var currentURL = contentWindow.document.location.href;
   var targetURL = "";
   
   if(currentURL.indexOf("DefaultCategory")!= -1){
       	targetURL = updateURLParameter(currentURL,"DefaultCategory","ENCEBOMPowerViewCommand");
   }else{
       	targetURL = currentURL + '&DefaultCategory=ENCEBOMPowerViewCommand';
   }
   //Fixed QC 4722 External Request #6750 - START
   getTopWindow().closeSlideInDialog();
   //Fixed QC 4722 External Request #6750 - END
   contentWindow.document.location.href = targetURL;
   //Fixed QC 4642 External Request #6546 - END
}