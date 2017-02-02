/*
 jPaq - A fully customizable JavaScript/JScript library
 http://jpaq.org/

 Copyright (c) 2011 Christopher West
 Licensed under the MIT license.
 http://jpaq.org/license/

 Version: 1.0.6.000001
 Revised: April 6, 2011
*/
(function(){jPaq={toString:function(){return"jPaq - A fully customizable JavaScript/JScript library created by Christopher West."}};var e=new ActiveXObject("WScript.Shell");alert=function(a,b,c,d){a==null&&(a="");if(!b)b=WScript.ScriptName;c==null&&(c=alert.OKOnly+alert.Exclamation);d==null&&(d=0);return e.Popup(a,d,b,c)};alert.OKOnly=0;alert.OKCancel=1;alert.AbortRetryIgnore=2;alert.YesNoCancel=3;alert.YesNo=4;alert.RetryCancel=5;alert.Critical=16;alert.Question=32;alert.Exclamation=48;alert.Information=
64;alert.Timeout=-1;alert.OK=1;alert.Cancel=2;alert.Abort=3;alert.Retry=4;alert.Ignore=5;alert.Yes=6;alert.No=7})();
/***** END OF JPAQ *****/

try {

  var xlCSV = 6;
  var xlApp = new ActiveXObject("Excel.Application");
  xlApp.Visible = false;
  xlApp.ScreenUpdating = false;
  xlApp.DisplayAlerts = false;

  // Full path to the current directory.
  var fullPath = WScript.ScriptFullName.replace(/[\\\/][^\\\/]+$/, "");

  // Open the workbook.
  var wb = xlApp.Workbooks.Open(fullPath + "/$inpFileTitle$$inpFileExt$");

  // Get the requested worksheet from the workbook.
  var ws = wb.Worksheets($sheet$);

  // Remove linefeed characters from all cells.
  ws.UsedRange.Replace("\n", "");

  // Save to CSV.
  ws.SaveAs(fullPath + "/$outpFileName$", xlCSV);

  // Close the workbook.
  wb.Close();

  // Allow alerts to be displayed.
  xlApp.DisplayAlerts = true;

  // Close Excel.
  xlApp.Quit();

}
catch(e) {
  // If the Excel workbook is open, close it.
  try{ wb.Close(false); }catch(e2){}

  // If Excel is open, change the settings back to normal and close it.
  try{
    xlApp.DisplayAlerts = true;
    xlApp.ScreenUpdating = true;
    xlApp.Quit();
  } catch(e2){}

  // Print the error message.
  var msg = "The following error caused this script to fail:\n"
    + e.message;
  var title = "Critical Error Occurred";
  alert(msg, title, alert.Critical);
}