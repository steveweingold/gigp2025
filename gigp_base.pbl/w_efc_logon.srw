forward
global type w_efc_logon from w_logon
end type
end forward

global type w_efc_logon from w_logon
end type
global w_efc_logon w_efc_logon

on w_efc_logon.create
call super::create
end on

on w_efc_logon.destroy
call super::destroy
end on

event open;call super::open;// EFC specific text.	//
st_help.text = "Enter a User ID and Network Password to log onto the " + &
					inv_logonattrib.is_appname + "."

// Allow 5 logon attempts.	//
ii_LogonAttempts = 5

end event

event pfc_default;// Override.	//

integer	li_rc
n_cst_validate_password	lu_Validate

//////////////////////////////////////////////////////////////////////////////
// Check required fields
//////////////////////////////////////////////////////////////////////////////
if Len (sle_userid.text) = 0 then
	of_MessageBox ("pfc_logon_enterid", inv_logonattrib.is_appname, &
		"Please enter a User ID to logon.", exclamation!, OK!, 1)
	sle_userid.SetFocus()
	return
end if
if Len (sle_password.text) = 0 then
	of_MessageBox ("pfc_logon_enterpassword", inv_logonattrib.is_appname, &
		"Please enter a password to logon.", exclamation!, OK!, 1)
	sle_password.SetFocus()
	return
end if
if Isnull(inv_logonattrib.ipo_source) or Not IsValid (inv_logonattrib.ipo_source) then
	this.event pfc_cancel()
	return
End If

//////////////////////////////////////////////////////////////////////////////
// Attempt to logon
//////////////////////////////////////////////////////////////////////////////
ii_logonattempts --

//*************************//
// AUTHENTICATE WITH NDAP.	//
//*************************//

SetPointer(HourGlass!)

IF lu_Validate.of_ValidatePassword(sle_userid.Text,sle_password.Text) THEN
	li_RC = 1
ELSE
	li_RC = 0
END IF


if IsNull (li_rc) then 
	this.event pfc_cancel()
	return
ElseIf li_rc <= 0 Then
	If ii_logonattempts > 0 Then
		// There are still have more attempts for a succesful login.
		of_MessageBox ("pfc_logon_incorrectpassword", "Login", &
			"The password is incorrect.", StopSign!, Ok!, 1)
		sle_password.SetFocus()
		Return
	Else
		// Failure return code
		inv_logonattrib.ii_rc = -1	
		CloseWithReturn (this, inv_logonattrib)
	End If
Else
	// Successful return code
	inv_logonattrib.ii_rc = 1
	inv_logonattrib.is_userid = sle_userid.text
	inv_logonattrib.is_password = sle_password.text	
	CloseWithReturn (this, inv_logonattrib)	
End if

Return
end event

type p_logo from w_logon`p_logo within w_efc_logon
boolean originalsize = false
end type

type st_help from w_logon`st_help within w_efc_logon
end type

type cb_ok from w_logon`cb_ok within w_efc_logon
end type

type cb_cancel from w_logon`cb_cancel within w_efc_logon
end type

type sle_userid from w_logon`sle_userid within w_efc_logon
end type

type sle_password from w_logon`sle_password within w_efc_logon
end type

type st_2 from w_logon`st_2 within w_efc_logon
end type

type st_3 from w_logon`st_3 within w_efc_logon
end type

