//objectcomments User object that obtains the netware user id.
forward
global type u_nw_id from nonvisualobject
end type
type lconv from structure within u_nw_id
end type
end forward

type lconv from structure
	character		decimal_point[4]
	character		thousands_sep[4]
	character		grouping[4]
	character		int_curr_symbol[8]
	character		currency_synbol[4]
	character		mon_decimal_point[4]
	character		mon_thousands_sep[4]
	character		mon_grouping[8]
	character		positive_sign[4]
	character		negative_sign[4]
	character		int_frac_digits
	character		frac_digits
	character		p_cs_precedes
	character		p_sep_by_space
	character		n_cs_precedes
	character		n_sep_by_space
	character		p_sign_posn
	character		n_sign_posn
	integer		code_page
	integer		country_id
	character		data_list_separator[2]
	character		data_separator[2]
	character		time_separator[2]
	character		time_format
	integer		date_format
	character		reserved[50]
end type

global type u_nw_id from nonvisualobject autoinstantiate
end type

type prototypes
FUNCTION INT NWDSWhoAmI(ULONG Context, REF STRING ObjectName) LIBRARY "Netwin32.DLL" alias for "NWDSWhoAmI;Ansi"
FUNCTION ULONG NWDSCreateContext() LIBRARY "Netwin32.DLL"
FUNCTION INT NWDSFreeContext(ULONG Context) LIBRARY "Netwin32.DLL"
FUNCTION INT NWCallsInit(ULONG parm1, ULONG parm2) LIBRARY "CalWin32.DLL"
FUNCTION INT NWInitUnicodeTables(int parm1, int parm2) LIBRARY "LocWin32.DLL"
SUBROUTINE NWLlocaleconv(REF LCONV s_convert) LIBRARY "LocWin32.DLL" alias for "NWLlocaleconv;Ansi"
SUBROUTINE NWFreeUnicodeTables() LIBRARY "LocWin32.DLL"

function ulong NWInitialize() library "NWInfo"
function ulong NWGetInfo( Long Drv, Long info, ref string buffer ) Library "NWInfo" alias for "NWGetInfo;Ansi"

end prototypes

type variables
private LCONV is_convert

end variables

forward prototypes
public function string of_getuserid_pb ()
public function string old_getuid ()
public function string getuid ()
end prototypes

public function string of_getuserid_pb ();
string			ls_Userid
n_cst_platform	lnv_platform

//*******************************************************
// Get the user id of the current user:
//*******************************************************

f_setplatform (lnv_platform,True)
ls_UserID = lnv_platform.of_GetUserID()
f_setplatform (lnv_platform,False)

Return ls_UserID

end function

public function string old_getuid ();//  Author:    Sawyer
//
//  Get the netware user id of the currently logged in user,
//  using the Netware API.
//
//  Parameters:
//  ----------------
//    None
//
//  Return Value:
//  -----------------
//    User Name if all goes well, the string UNKNOWN, if the call fails.
//
//  History
//  ---------
//
//    98.04.27
//    ----------
//      1.  Version 1.0 completed.
//  
//    98.04.28
//    ----------
//      1.  Additional calls added to initialize Netware/NDS API.
//
//    98.06.09
//    ----------
//      1.  Changes made to further clean up the user id that is returned.
//            It was discovered that a few people's ID contain ".O=NYSEFC"
//            on the end of them.  So now a check is made and the string
//            is removed if there.
//
//    99.03.02	Greg Holden
//    --------------------
//      1.  Determines whether running through PB or EXE. If PB, uses
//				different API call so as not to crash.
//
//		01.12.06 Steve Weingold
//		-----------------------
//			1. Moved all api code into this backup function because the NWDSWhoAmI()
//				function seemed to be gpf'ing through the executable when migrated to 
//				PB8.0.  The code in of_getuserid_pb works great for both PB and .exe.
//

int      li_StartPos
ulong ll_Context
string ls_UserId, &
            ls_BadResult
long  ll_OStart


IF Handle(GetApplication()) = 0 THEN
	// We are running through PB.	//
	Return of_GetUserID_PB()
END IF

//////////////////////////////  Constants  //////////////////////////////////////////////

//  Needed to clean up the string we obtain
//  from the Netware API.
li_StartPos = 4

//  In case call fails.
ls_BadResult = "UNKNOWN"

//////////////////////////////  End Constants  ///////////////////////////////////////

//  Initialize Netware calls
If (NWCallsInit(0,0) <> 0) then
  return ls_BadResult
End if

//  Initialize NDS
NWLlocaleConv(is_convert)

//  Initialize the unicode tables.
If (NWInitUnicodeTables(is_convert.country_id, is_convert.code_page) <> 0) then
  return ls_BadResult
End if

//  Create an NDS context.
//  Needed to pass the context to the NWDSWhoAmI()  call.
ll_Context = this.NWDSCreateContext()

//  Now, try to obtain the user id.
Choose case (this.NWDSWhoAmI(ll_Context, ls_UserId))
  case 0  // Call succeeded.
    //  Clean up the NDS name to be just the user name.
    ls_UserId = Mid(ls_UserId, li_StartPos)
    ll_OStart  = Pos(ls_UserID,".O=NYSEFC")
    If ll_OStart > 0 then
      Replace(ls_UserID, ll_OStart, len(".O=NYSEFC"), "")
    End if
  case ELSE  // Call failed.
    ls_UserId = ls_BadResult
End choose

this.NWDSFreeContext(ll_Context)
this.NWFreeUnicodeTables()

return ls_UserId

end function

public function string getuid ();
string		ls_Login, ls_Temp
environment	le_Env
int			li_Drive, li_Info
long			ll_RC

GetEnvironment(le_Env)

IF le_Env.OSMajorRevision >= 5 THEN
	
	//*******************************************************
	// Windows 2000 or greater. Use password protected user
	// name from the OS:
	//*******************************************************
	
	ls_Login = this.of_getuserid_pb()

	IF IsNull(ls_Login) OR Trim(ls_Login) = "" THEN
		MessageBox("Security Problem","Your identification cannot be determined. Application will close.",StopSign!)
		HALT CLOSE
	END IF
ELSE
	MessageBox("Operating System Problem","This application can only run on Windows 2000/XP. Application will close.",StopSign!)
	HALT CLOSE
END IF

Return ls_Login





end function

on u_nw_id.create
call super::create
TriggerEvent( this, "constructor" )
end on

on u_nw_id.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

