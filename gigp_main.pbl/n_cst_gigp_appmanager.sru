forward
global type n_cst_gigp_appmanager from n_cst_appmanager
end type
end forward

global type n_cst_gigp_appmanager from n_cst_appmanager
end type
global n_cst_gigp_appmanager n_cst_gigp_appmanager

type prototypes
function uint WinExecA(ref string s, uint ui) Library "kernel32.dll" alias for "WinExecA;Ansi"

end prototypes

type variables

private:
	string	is_EfcUserID, is_Groups[]
	boolean	ib_Send_To_Printer, ib_UsingHP4Printer, ib_ImplementMWBE
end variables

forward prototypes
public subroutine of_setreportdest (string as_Switch)
public function string of_getreportdest ()
public function string of_getuserid ()
public function boolean of_ingroup (string as_group)
public function boolean of_ingroup (string as_group[])
public subroutine of_setgroups ()
public function boolean of_get_implementmwbe ()
public function boolean of_getlocked ()
public function boolean of_subjecttomwbe ()
end prototypes

public subroutine of_setreportdest (string as_Switch);CHOOSE CASE Upper(as_Switch)
CASE "PRINTER","P"
	ib_Send_To_Printer = True
CASE "SCREEN","S"
	ib_Send_To_Printer = False
END CHOOSE

end subroutine

public function string of_getreportdest ();IF ib_Send_To_Printer THEN
	Return "PRINTER"
ELSE
	Return "SCREEN"
END IF

end function

public function string of_getuserid ();
Return is_EfcUserID
end function

public function boolean of_ingroup (string as_group);

Integer	li_UB, li_Index

//*******************************************************
// Check to security group access:
//*******************************************************

If (ib_globalAccess = True) Then Return True

li_UB = UpperBound(is_Groups)

FOR li_Index = 1 TO li_UB
	IF Upper(is_Groups[li_Index]) = Upper(as_Group) THEN
		Return True
	END IF
NEXT

Return False
end function

public function boolean of_ingroup (string as_group[]);
Long 		ll_index, ll_upper
Boolean 	lb_return
String	ls_group

//*******************************************************
// Use when multiple acceptable access groups:
//*******************************************************

ll_upper = UpperBound(as_group)

If (ll_upper < 1) Then Return False

FOR ll_index = 1 to ll_upper

    lb_return = of_ingroup(as_group[ll_index])   

	 If (lb_return = True) Then Return lb_return

NEXT

Return lb_return
end function

public subroutine of_setgroups ();
String	ls_Group
Integer	li_UB

//**********************************************************
// Get all the security groups the current user belongs to.
//**********************************************************

DECLARE	c1 CURSOR FOR
SELECT	sub_group
FROM		application_rights
WHERE		name			= :is_EfcUserID
AND		application	= 'GIGP';

OPEN c1;

FETCH c1 INTO :ls_Group;

DO WHILE sqlca.SQLCode = 0	
	
	If (Upper(ls_Group) = "GLOBAL") Then
		ib_globalAccess = True
	Else
		li_UB ++
		is_Groups[li_UB] = Upper(ls_Group)		
	End If

	FETCH c1 INTO	:ls_Group;
	
LOOP

CLOSE c1;

end subroutine

public function boolean of_get_implementmwbe ();Return ib_ImplementMWBE
end function

public function boolean of_getlocked ();long ll_locked

If gl_gigp_id > 0 Then
	select locked_flag
	into :ll_locked
	from gigp_application
	where gigp_id = :gl_gigp_id;
	
	If ll_locked = 1 Then
		Return True
	Else
		Return False
	End If
	
End If

Return False
end function

public function boolean of_subjecttomwbe ();string ls_program
long ll_enforcemwbe

//Get Program
select program
into :ls_program
from gigp_application
where gigp_id = :gl_gigp_id;

//See if program is subject to MWBE
select count(*)
into :ll_enforcemwbe
from gigp_reference
where category = 'EnforceMwbe'
and ref_code = :ls_program;

//If that program is not subject to MWBE then False else return True
If ll_enforcemwbe > 0 Then
	Return True
Else
	Return False
End If
end function

event constructor;call super::constructor;//*******************************************************
// Set application information:
//*******************************************************

//*************************************************************
// Initial Production Version 1.00 Deployed 05/15/2009
//*************************************************************

//This.of_SetAppIniFile("c:\windows\efc.ini")

ContextKeyword lcxk_base
string			ls_data[]
environment		le_Env
string ls_return

GetEnvironment(le_Env)

IF le_Env.osmajorrevision >= 6 THEN
	this.GetContextService("Keyword",lcxk_base)

	lcxk_base.GetContextKeywords("APPDATA",ls_data)

   IF Upperbound(ls_data) > 0 THEN
		IF NOT DirectoryExists(ls_Data[1] + "\EFC") THEN
			CreateDirectory(ls_Data[1] + "\EFC")
		END IF

		IF NOT FileExists(ls_data[1] + "\EFC\efc.ini") THEN
			FileCopy("\\efc-fs01\f-drive\PB\efc.ini",ls_Data[1] + "\EFC\efc.ini")
			
		END IF

		this.of_SetAppIniFile(ls_data[1] + "\EFC\efc.ini")
	ELSE
		this.of_SetAppIniFile("c:\windows\efc.ini")
	END IF
ELSE
	this.of_SetAppIniFile("c:\windows\efc.ini")
END IF

//Set EFC-Hub ini section if it does not exist
ls_return = ProfileString(this.of_getappinifile(),"EFC-Hub","Database", "ERROR")

If ls_return = 'ERROR' Then
	// Original version as written by Steve
	SetProfileString(this.of_getappinifile(),"EFC-Hub","Database","EFCApps")
	SetProfileString(this.of_getappinifile(),"EFC-Hub","ServerName","EFC-PRODSQL01")
//	SetProfileString(this.of_getappinifile(),"EFC-Hub","ServerName","EFC-SQL-TEST")
	SetProfileString(this.of_getappinifile(),"EFC-Hub","DBMS","OLE DB")
	SetProfileString(this.of_getappinifile(),"EFC-Hub","Prompt","0")
	SetProfileString(this.of_getappinifile(),"EFC-Hub","AutoCommit","1")
	
	// This version is for native client, either 32 or 64 bit with Trusted Authentication.
//	SetProfileString(this.of_getappinifile(),"EFC-Hub","Database","EFCApps")
//	SetProfileString(this.of_getappinifile(),"EFC-Hub","ServerName","EFC-SQL-TEST")
//	SetProfileString(this.of_getappinifile(),"EFC-Hub","DBMS","SNC")
//	SetProfileString(this.of_getappinifile(),"EFC-Hub","Prompt","0")
//	SetProfileString(this.of_getappinifile(),"EFC-Hub","AutoCommit","1")
//	SetProfileString(this.of_getappinifile(),"EFC-Hub","DbParm","Database='EFCApps',Provider='SQLNCLI11',AppName='EFC-Hub',TimeOut=5,TrustedConnection=1,TrimSpaces=1")
End If

This.of_SetUserIniFile("")
This.of_SetHelpFile("")
//This.of_SetLogo("efcsmal2.bmp")
This.of_SetCopyright("Copyright 1999-2016 NYS Environmental Facilities Corp.")
This.of_SetVersion("Version 5.74 (PB2019)")
iapp_object.DisplayName = "Green Innovation Grant Program Application"

end event

on n_cst_gigp_appmanager.create
call super::create
end on

on n_cst_gigp_appmanager.destroy
call super::destroy
end on

event pfc_open;call super::pfc_open;// EFC Login code
n_cst_logonattrib	lnv_LogonAttrib
long		ll_Handle
String 	ls_UserID, ls_token_id, ls_switch
Integer	li_authRecord, li_Code
u_nw_id	lu_NWID
n_cst_authentication_service lnv_AuthService

SetPointer(HourGlass!)

if (sqlca.of_Init(is_AppINIFile, "EFC-Hub") = -1) then
    MessageBox("Fatal Error","Unable to read initialization information from ini file.", StopSign!)
    halt close
end if

//Check to see if an authentication token was passed to the application
ls_token_id = as_commandline

if len(ls_token_id) > 0 then
	
	li_authRecord = lnv_AuthService.of_get_authentication_record(ls_token_id, gnv_App.of_GetAppIniFile(), "EFC-Hub")
	
	if (li_authRecord = 1) then
		is_EfcUserID = lower(lnv_AuthService.is_userID)		
	end if

end if

ll_Handle = Handle(gigp)

if (ll_Handle > 0) THEN // Runing exe 
	
	//Check for and authentication record, if none then login
	if (li_authRecord <> 1)  then
		
		// Load logon object values
		this.Event pfc_prelogondlg(lnv_LogonAttrib)
	
		// Open logon window
		if (OpenWithParm(w_efc_logon,lnv_LogonAttrib) < 0) then halt close
	
		// Get return logon object
		lnv_LogonAttrib = message.PowerObjectParm
	
		if (lnv_LogonAttrib.ii_RC <> 1) then halt close //No valid userid/password was entered
			
		is_EfcUserID = lower(lnv_LogonAttrib.is_UserID) //get user id that the user entered upon login
	end if	
	
else  // Running through PowerBuilder (login not required)
	//Get the user id from the authentication record or call the authentication service
	if (li_authRecord <> 1) then 
//		is_EfcUserID = lower(lnv_AuthService.of_get_user_id())		
		is_EfcUserID  = lower(lu_NWID.GetUID())
	end if
end if

//// Everyone logs into the database as efcuser. Application access rights is determined by the is_EfcUserID
sqlca.Logid 	 = "efcuser"
sqlca.UserID	 = "efcuser"
this.of_SetUserId("efcuser")

// This is for SNC Trusted
//this.of_SetUserId(is_EfcUserID)

// Customize next line for each app
sqlca.LogPass = lnv_AuthService.of_get_password(gnv_App.of_GetAppIniFile())
sqlca.DBPass = sqlca.LogPass
lnv_AuthService.of_get_db_connection(sqlca, is_EfcUserID, 'GIGP')

// Greg - Made this more generic. 2-18-2022
//If Upper(sqlca.ServerName) = 'EFC-PRODSQL01' Then
if Pos(Upper(sqlca.ServerName),"PROD") > 0 then
	gb_production = True
	gb_isproduction = True
Else
	gb_production = False
	gb_isproduction = False
End If

// Try to connect to the database
IF sqlca.of_Connect() = -1 THEN
	Messagebox("Application Manager Error","Could not connect to the database." &
		  + "~nSQL error code: " + string(sqlca.SQLDBCode) &
		  + "~nSQL error message: " + sqlca.SQLErrText,Exclamation!)
   HALT CLOSE
END IF

// Are we enforcing MWBE rules?
select ref_code into :li_Code from	reference where ref_type = 'MWBE Restrictions Enforced Flag';

IF IsNull(li_Code) OR li_Code <> 1 THEN
	ib_ImplementMWBE = False
Else
	ib_ImplementMWBE = True
END IF

//Coded for a single parm (gigp_id or project_no)
if (lnv_AuthService.ids_parms.rowcount() > 0) then
	gs_keyName = lnv_AuthService.ids_parms.getitemstring(1, "key_name")
	gs_keyValue = lnv_AuthService.ids_parms.getitemstring(1, "key_value")
end if

//Set HubSwtich for GIGP to use new hub tables or original CWISS / ENG tables
select code
into :ls_switch
from efcreference
where category = 'Legacy Apps Use New Project Tables Switch';

If ls_switch = '1' Then
	gb_UseHubTablesSwitch = True
Else 
	gb_UseHubTablesSwitch = False
End If

//Set gb_UseFinSchemaTables for GIGP to use new SRF Web Fin schema tables or original LS tables
select code
into :ls_switch
from efcreference
where category = 'Legacy Apps Use Fin Tables Switch';

If ls_switch = '1' Then
	gb_UseFinSchemaTables = True
Else 
	gb_UseFinSchemaTables = False
End If

//Open the frame
Open(w_gigp_frame)


end event

event pfc_logon;call super::pfc_logon;
// COMMON EFC LOGIN SCRIPT.	//

//*******************************************************
// Validation of as_UserID and as_Password combination 
// will take place on w_efc_logon. Return success code.	
//*******************************************************

Return 1

end event

event pfc_idle;call super::pfc_idle;
Open(w_auto_shutdown)
end event

