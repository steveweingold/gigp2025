forward
global type gigp from application
end type
global n_tr sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables

n_cst_event_router		gnv_event
n_cst_gigp_appmanager	gnv_app
long							gl_gigp_ID, gl_roundNo
String							gs_srfType, gs_projNo, gs_CWISSRewriteUpdateIndicator, gs_keyName, gs_keyValue
Boolean 						ib_globalAccess, gb_production, gb_UseHubTablesSwitch, gb_isproduction, &
								gb_UseFinSchemaTables
end variables

global type gigp from application
string appname = "gigp"
string displayname = "Small Grants Application"
string themepath = "C:\Program Files (x86)\Appeon\PowerBuilder 22.0\IDE\theme"
string themename = "Do Not Use Themes"
boolean nativepdfvalid = false
boolean nativepdfincludecustomfont = false
string nativepdfappname = ""
long richtextedittype = 5
long richtexteditx64type = 5
long richtexteditversion = 3
string richtexteditkey = ""
string appicon = "Q:\Powerbuilder Apps (EFC)\bitmaps\RAIN.ICO"
string appruntimeversion = "25.0.0.3683"
boolean manualsession = false
boolean unsupportedapierror = false
boolean ultrafast = false
boolean bignoreservercertificate = false
uint ignoreservercertificate = 0
long webview2distribution = 0
boolean webview2checkx86 = false
boolean webview2checkx64 = false
string webview2url = "https://developer.microsoft.com/en-us/microsoft-edge/webview2/"
integer highdpimode = 0
end type
global gigp gigp

type prototypes
Function long FindWindowA(string ClassName, string WindowName) library "user32.dll" alias for "FindWindowA;Ansi"
Function boolean BringWindowToTop(long hWnd) library "user32.dll"   
FUNCTION boolean FlashWindow(ulong hndl,boolean flash ) LIBRARY "user32.dll"
Function boolean ShowWindow(long hWnd, int nCmdShow) library "user32.dll"  
end prototypes

on gigp.create
appname="gigp"
message=create message
sqlca=create n_tr
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on gigp.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;
SetPointer(HourGlass!)

this.ToolBarText = True

gnv_event = create n_cst_event_router
gnv_event.of_RegisterEvent("ue_newapp")
										
gnv_app = create n_cst_gigp_appmanager
gnv_app.event pfc_open (commandline)
end event

event close;
gnv_app.event pfc_close()

destroy gnv_event
destroy gnv_app
end event

event connectionbegin;
gnv_app = create n_cst_appmanager

return gnv_app.event pfc_connectionbegin (userid, password, connectstring)

end event

event connectionend;
gnv_app.event pfc_connectionend ()

destroy gnv_app
end event

event idle;
gnv_app.event pfc_idle()
end event

event systemerror;
gnv_app.event pfc_systemerror()
end event

