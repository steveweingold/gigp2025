//objectcomments NVO with functions for interfacing with gwsend.exe
forward
global type n_cst_gwsend from nonvisualobject
end type
end forward

global type n_cst_gwsend from nonvisualobject autoinstantiate
end type

type prototypes
function long WinExec(string as_Parm, uint aui_State) library "kernel32.dll" alias for "WinExec;Ansi"
end prototypes

type variables
Private:
  string	is_Recipients[], &
	is_Subject, &
	is_Message, &
	is_CC, &
	is_BCC, &
	is_Attach, &
	is_User, &
	is_Password
	
boolean ib_blat
end variables

forward prototypes
public function integer of_sendmail ()
public function integer of_addrecipient (string as_recipient)
public function integer of_setmessage (string as_message)
public function integer of_setsubject (string as_subject)
public function integer of_setcc (string as_CC)
public function integer of_setbcc (string as_BCC)
public function integer of_setattach (string as_attach)
public function integer of_setuser (string as_user)
public function integer of_setpassword (string as_password)
public subroutine of_reset ()
public function integer of_sendmail_blat ()
public function boolean of_iswhitespace (string as_source)
public function string of_removewhitespace (string as_source)
public function string of_globalreplace (string as_source, string as_old, string as_new)
end prototypes

public function integer of_sendmail ();//string	ls_Run, &
//			ls_Parm, &
//			ls_Shell
//int		li_UB, &
//			li_Index
//environment	env

////If using Blat, then redirect to Blat code
//If ib_blat Then
	Return this.of_sendmail_blat()
//End If
////////////////////////////////////////////////////////////


//li_UB = UpperBound(is_Recipients)
//
//IF li_UB <= 0 THEN
//	Return -1
//END IF
//
////Syntax:  GWSend /T[o]=<text>  [Optional Parameters]
//
//// Note: I cannot find a way to make multiple recipients work.	//
//
////Optional Parameters:
////         /S[ubject]=<text>       Specify Subject
////         /M[essage]=<text>       Specify Message (one line)
////         /C[c]=<text>            Copy this recicient
////         /B[c]=<text>            Blind Copy to this recicient
////         /A[ttach]=<file>        Attach a file
//
//// Note: Setting password and userid to something other than the userid currently		//
//// logged onto the PC will result in a response window asking for the password, even	//
//// if you pass it in on the /P="" parm.																//
//
////         /U[ser]=<text>          Specify GW User Name
////         /P[assword]=<text>      Specify GW User Password
//
//GetEnvironment(env)
//
//IF env.OSType = Windows! THEN
//	ls_Shell = "command"
//ELSE
//	ls_Shell = "cmd"
//END IF
//
//FOR li_Index = 1 TO li_UB
//	ls_Parm = 'gwsend /T="' + is_Recipients[li_Index] + &
//					'" /S="' + is_Subject + '" /M="' + is_Message + '"'
//
//	IF is_CC <> "" THEN
//		ls_Parm += ' /C="' + is_CC + '"'
//	END IF
//
//	IF is_BCC <> "" THEN
//		ls_Parm += ' /B="' + is_BCC + '"'
//	END IF
//
//	IF is_Attach <> "" THEN
//		ls_Parm += ' /A="' + is_Attach + '"'
//	END IF
//
//	IF is_User <> "" THEN
//		ls_Parm += ' /U="' + is_User + '"'
//	END IF
//
//	IF is_Password <> "" THEN
//		ls_Parm += ' /P="' + is_Password + '"'
//	END IF
//
//// /c means run and close shell			//
//// /k means run and leave shell open	//
//	ls_Run = ls_Shell + " /c " + ls_Parm
//
//	// WinExec is a locally declared external function. The 0 parm tells it to be invisible.	//
//	IF env.OSType = Windows! THEN
//		// The API call was not working on Win95.	//
//		Run(ls_Parm)
//	ELSE
//		WinExec(ls_Run,0)
//	END IF
//NEXT
//
//Return 1
//
end function

public function integer of_addrecipient (string as_recipient);int	li_UB
string ls_domain

select description
into :ls_domain
from efc_reference
where type = 'blat_dom';

IF NOT IsNull(as_Recipient) THEN
	If POS(as_Recipient, '@') <= 0 Then
		as_Recipient += '@' + ls_domain
	End If
	
	li_UB = UpperBound(is_Recipients)

	li_UB ++

	is_Recipients[li_UB] = as_Recipient

	Return 1
ELSE
	Return -1
END IF
end function

public function integer of_setmessage (string as_message);IF NOT IsNull(as_Message) THEN
	is_Message = as_Message

	Return 1
ELSE
	is_Message = ""

	Return -1
END IF

end function

public function integer of_setsubject (string as_subject);IF NOT IsNull(as_Subject) THEN
	is_Subject = as_Subject

	Return 1
ELSE
	is_Subject = ""

	Return -1
END IF

end function

public function integer of_setcc (string as_CC);IF NOT IsNull(as_CC) THEN
	is_CC = as_CC

	Return 1
ELSE
	is_CC = ""

	Return -1
END IF

end function

public function integer of_setbcc (string as_BCC);IF NOT IsNull(as_BCC) THEN
	is_BCC = as_BCC

	Return 1
ELSE
	is_BCC = ""

	Return -1
END IF


end function

public function integer of_setattach (string as_attach);IF NOT IsNull(as_Attach) THEN
	IF FileExists(as_Attach) THEN
		
		If IsNull(is_Attach) Or is_Attach = "" Then
			is_Attach = as_Attach
		Else
			//Blat uses comma separated, regular gwsend uses semicolon
			If ib_blat Then
				is_Attach += ("," + as_Attach)
			Else
				is_Attach += (";" + as_Attach)
			End If
		End If
		
		Return 1
	ELSE
		is_Attach = ""

		Return -1
	END IF
ELSE
	is_Attach = ""

	Return -1
END IF
end function

public function integer of_setuser (string as_user);// Note: Setting password and userid to something other than the userid currently		//
// logged onto the PC will result in a response window asking for the password, even	//
// if you pass it in on the /P="" parm.																//

IF NOT IsNull(as_User) THEN
	is_User = as_User

	Return 1
ELSE
	is_User = ""

	Return -1
END IF
end function

public function integer of_setpassword (string as_password);// Note: Setting password and userid to something other than the userid currently		//
// logged onto the PC will result in a response window asking for the password, even	//
// if you pass it in on the /P="" parm.																//

IF NOT IsNull(as_Password) THEN
	is_Password = as_Password

	Return 1
ELSE
	is_Password = ""

	Return -1
END IF
end function

public subroutine of_reset ();string	ls_Empty, &
			ls_EmptyArray[]

is_Attach		= ls_Empty
is_BCC			= ls_Empty
is_CC				= ls_Empty
is_Message		= ls_Empty
is_Password		= ls_Empty
is_Recipients	= ls_EmptyArray
is_Subject		= ls_Empty
is_User			= ls_Empty

end subroutine

public function integer of_sendmail_blat ();string	ls_Run, ls_Parm, ls_Shell, ls_smtp, ls_port, ls_to, ls_subject, ls_body, ls_from, ls_attach, ls_domain, ls_Path
int li_UB, li_Index
environment env

//Get the environment
GetEnvironment(env)

//Get smtp, port and path
select description
into :ls_smtp
from efc_reference 
where type = 'blat_smtp';

select code
into :ls_port
from efc_reference
where type = 'blat_port';

IF env.osmajorrevision >= 6 THEN
	select description
	into :ls_Path
	from efc_reference 
	where type = 'blat_path7';
ELSE
	select description
	into :ls_Path
	from efc_reference 
	where type = 'blat_path';
END IF

// Don't verify path. Computer could have it in local path.	//
If IsNull(ls_smtp) or ls_smtp = '' or IsNull(ls_port) or ls_port = '' Then
	Return -1
End If

//Use noreply for the FROM email
ls_from = 'noreply'


//Get the domain and build the "from" email address
select description
into :ls_domain
from efc_reference
where type = 'blat_dom';

ls_from += '@' + ls_domain

//Create the from parameter
ls_from = '-f ' + ls_from + ' '

//Start run command
IF env.osmajorrevision >= 6 THEN
	// Win7 wants quotes around the path.	//
	ls_Parm = '"' + ls_Path + 'Blat" - -server ' + ls_smtp + ' -port ' + ls_port + ' '
ELSE
	ls_Parm = ls_Path + 'Blat - -server ' + ls_smtp + ' -port ' + ls_port + ' '
END IF

li_UB = UpperBound(is_Recipients)

IF li_UB <= 0 THEN
	Return -1
END IF

//Build comma separated list of recipients
ls_to = '-t '
For li_Index = 1 to li_UB
	If li_Index < li_UB Then
		ls_to += is_Recipients[li_Index] + ','
	Else
		ls_to += is_Recipients[li_Index]
	End If
Next

ls_Parm += ls_to + ' '


//Add CC if it exists
If is_cc > '' Then
	ls_Parm += '-cc ' + is_cc + ' '
End If

//Add BCC if it exists
If is_bcc > '' Then
	ls_Parm += '-bcc ' + is_bcc + ' '
End If

//Add Subject
If is_subject > '' Then
	ls_subject = '-s "' + is_subject + '" '
End If

//Create message body after removing line returns which cause Blat to fail
is_message = this.of_GlobalReplace(is_message, ' ', '***')
is_message = this.of_removewhitespace(is_message)
is_message = this.of_GlobalReplace(is_message, '***', ' ')

If is_message > '' Then
	ls_body = '-body "' + is_message + '" '
End If

//Add attachment
If is_attach > '' Then
	ls_attach    = ("-attach " + '"' + is_attach + '" ')
End If
 
//Build the statement
ls_Parm += ls_subject + ls_body + ls_from + ls_attach

IF env.osmajorrevision >= 5 THEN
	ls_Shell = "cmd"
ELSE
	ls_Shell = "command"
END IF

// /c means run and close shell			//
// /k means run and leave shell open	//
ls_Run = ls_Shell + " /c " + ls_Parm

Clipboard(ls_run)

// WinExec is a locally declared external function. The 0 parm tells it to be invisible.	//
IF env.osmajorrevision = 5 THEN
	WinExec(ls_Run,0)
ELSE
	// The API call was not working on Win95. Also does not work with Win7.	//
	Run(ls_Parm)
END IF

Return 1
end function

public function boolean of_iswhitespace (string as_source);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  		of_IsWhiteSpace
//
//	Access: 			public
//
//	Arguments:
//	as_source		The source string.
//
//	Returns:  		Boolean
//						True if the string only contains White Space characters. 
//						If any argument's value is NULL, function returns NULL.
//
//	Description:  	Determines whether a string contains only White Space
//						characters. White Space characters include Newline, Tab,
//						Vertical tab, Carriage return, Formfeed, and Backspace.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	5.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2005, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the GNU Lesser General
 * Public License Version 2.1, February 1999
 *
 * http://www.gnu.org/copyleft/lesser.html
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see http://pfc.codexchange.sybase.com
*/
//
//////////////////////////////////////////////////////////////////////////////

long 		ll_count=0
long 		ll_length
char		lc_char[]
integer	li_ascii

//Check parameters
If IsNull(as_source) Then
	boolean lb_null
	SetNull(lb_null)
	Return lb_null
End If

//Get the length
ll_length = Len (as_source)

//Check for at least one character
If ll_length=0 Then
	Return False
End If

//Move string into array of chars
lc_char = as_source


//Perform loop around all characters
//Quit loop if Non WhiteSpace character is found
do while ll_count<ll_length
	ll_count ++
	
	//Get ASC code of character.
	li_ascii = Asc (lc_char[ll_count])
	
	If li_ascii=8	or			/* BackSpae */		 		& 
		li_ascii=9 	or			/* Tab */		 			& 
		li_ascii=10 or			/* NewLine */				& 
		li_ascii=11 or			/* Vertical Tab */		& 
		li_ascii=12 or			/* Form Feed */			& 
		li_ascii=13 or			/* Carriage Return */	&
		li_ascii=32 Then		/* Space */		
		//Character is a WhiteSpace.
		//Continue with the next character.
	Else
		/* Character is Not a White Space. */
		Return False
	End If
loop
	
// Entire string is White Space.
return True

end function

public function string of_removewhitespace (string as_source);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  		of_RemoveWhiteSpace
//
//	Access:  		public
//
//	Arguments:
//	as_source		The string from which all WhiteSpace characters are to
//						be removed.
//
//	Returns:  		string
//						as_source with all desired characters removed.
//						If any argument's value is NULL, function returns NULL.
//
//	Description: 	Removes all WhiteSpace characters.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	5.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2005, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the GNU Lesser General
 * Public License Version 2.1, February 1999
 *
 * http://www.gnu.org/copyleft/lesser.html
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see http://pfc.codexchange.sybase.com
*/
//
//////////////////////////////////////////////////////////////////////////////

char		lch_char
long		ll_pos = 1
long		ll_loop
string	ls_source
long		ll_source_len

//Check parameters
If IsNull(as_source) Then
	string ls_null
	SetNull(ls_null)
	Return ls_null
End If

ls_source = as_source
ll_source_len = Len(ls_source)

// Remove WhiteSpace characters 
FOR ll_loop = 1 TO ll_source_len
	lch_char = Mid(ls_source, ll_pos, 1)
	if Not of_IsWhiteSpace(lch_char) then
		ll_pos ++	
	else
		ls_source = Replace(ls_source, ll_pos, 1, "")
	end if 
NEXT

Return ls_source

end function

public function string of_globalreplace (string as_source, string as_old, string as_new);boolean ab_IgnoreCase = True

//////////////////////////////////////////////////////////////////////////////
//
//	Function:  		of_GlobalReplace
//
//	Access:  		public
//
//	Arguments:
//	as_Source		The string being searched.
//	as_Old			The old string being replaced.
//	as_New			The new string.
// ab_IgnoreCase	A boolean stating to ignore case sensitivity.
//
//	Returns:  		string
//						as_Source with all occurrences of as_Old replaced with as_New.
//						If any argument's value is NULL, function returns NULL.
//
//	Description:  	Replace all occurrences of one string inside another with
//						a new string.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	5.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2005, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the GNU Lesser General
 * Public License Version 2.1, February 1999
 *
 * http://www.gnu.org/copyleft/lesser.html
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see http://pfc.codexchange.sybase.com
*/
//
//////////////////////////////////////////////////////////////////////////////

Long	ll_Start
Long	ll_OldLen
Long	ll_NewLen
String ls_Source

//Check parameters
If IsNull(as_source) or IsNull(as_old) or IsNull(as_new) or IsNull(ab_ignorecase) Then
	string ls_null
	SetNull(ls_null)
	Return ls_null
End If

//Get the string lenghts
ll_OldLen = Len(as_Old)
ll_NewLen = Len(as_New)

//Should function respect case.
If ab_ignorecase Then
	as_old = Lower(as_old)
	ls_source = Lower(as_source)
Else
	ls_source = as_source
End If

//Search for the first occurrence of as_Old
ll_Start = Pos(ls_Source, as_Old)

Do While ll_Start > 0
	// replace as_Old with as_New
	as_Source = Replace(as_Source, ll_Start, ll_OldLen, as_New)
	
	//Should function respect case.
	If ab_ignorecase Then 
		ls_source = Lower(as_source)
	Else
		ls_source = as_source
	End If
	
	// find the next occurrence of as_Old
	ll_Start = Pos(ls_Source, as_Old, (ll_Start + ll_NewLen))
Loop

Return as_Source

end function

on n_cst_gwsend.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_gwsend.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;//string ls_blat
//
////Determine whether or not to use Blat
//select code
//into :ls_blat
//from efc_reference
//where type = 'blat_switc';
//
//If ls_blat = 'Y' Then

//Else
//	ib_blat = False
//End If
//


ib_blat = True
end event

