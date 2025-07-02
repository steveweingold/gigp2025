forward
global type n_cst_validate_password from nonvisualobject
end type
end forward

global type n_cst_validate_password from nonvisualobject autoinstantiate
end type

type prototypes
Function ULONG NWDSCreateContext() Library "netwin32.dll"
Function ULONG NWDSFreeContext (ULONG context) Library "netwin32.dll"
Function ULONG NWDSVerifyObjectPassword (ULONG context, ULONG optionsFlag,STRING objectName, STRING password) Library "netwin32.dll" alias for "NWDSVerifyObjectPassword;Ansi"

Function boolean LogonUser ( &
	string lpszUsername, &
	string lpszDomain, &
	string lpszPassword, &
	ulong dwLogonType, &
	ulong dwLogonProvider, &
	ref ulong phToken &
	) Library "advapi32.dll" Alias For "LogonUserW"

end prototypes

type variables

end variables

forward prototypes
public function boolean of_validatepassword (string as_userid, string as_password)
public function boolean of_validatepasswordad (string as_userid, string as_password)
end prototypes

public function boolean of_validatepassword (string as_userid, string as_password);ulong     lul_context, lul_optionsFlag, lul_result
string    ls_objectName, ls_password
boolean   lb_valid

boolean lb_Novell = True

Try
	// Create a Novell context, verify the password and destroy the context
	lul_context = NWDSCreateContext()
catch (Throwable ll_Throw)
	// If no Novell client installed, this will catch the failed dll call.	//
	lb_Novell = False
end try

IF lb_Novell THEN
	lul_optionsFlag = 0
	lb_valid = (0 = NWDSVerifyObjectPassword (lul_context, lul_optionsFlag,as_userId, as_password))
	NWDSFreeContext(lul_Context)
END IF

// Check both Novell and AD. Novell might be installed still but not functioning.	//
IF lb_Valid OR of_validatepasswordAD(as_userid,as_password) THEN
	Return True
ELSE
	Return False
END IF


//environment	le_Env
//
//GetEnvironment(le_Env)
//
//IF le_Env.osmajorrevision >= 6 THEN
//	Return of_validatepasswordAD(as_userid,as_password)
//ELSE
//	// Create a Novell context, verify the password and destroy the context
//
//	lul_context = NWDSCreateContext()
//
//	lul_optionsFlag = 0
//
//	lb_valid = (0 = NWDSVerifyObjectPassword (lul_context, lul_optionsFlag,as_userId, as_password))
//
//	NWDSFreeContext(lul_Context)
//
//	Return lb_Valid
//END IF
//

end function

public function boolean of_validatepasswordad (string as_userid, string as_password);Constant ULong LOGON32_LOGON_NETWORK = 3
Constant ULong LOGON32_PROVIDER_DEFAULT = 0
String ls_domain
ULong lul_token
Boolean lb_result

ls_domain   = "NYSEFC"

lb_result = LogonUser( as_userid, ls_domain, &
						as_password, LOGON32_LOGON_NETWORK, &
						LOGON32_PROVIDER_DEFAULT, lul_token )

Return lb_result
end function

on n_cst_validate_password.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_validate_password.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

