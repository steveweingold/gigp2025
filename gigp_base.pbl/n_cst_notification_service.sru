//objectcomments NVO with functions for interfacing with gwsend.exe
forward
global type n_cst_notification_service from nonvisualobject
end type
end forward

global type n_cst_notification_service from nonvisualobject autoinstantiate
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
	is_Password, &
	is_Domain, &
	is_From, &
	is_smtp, &
	is_port, &
	is_Path
	
	
boolean	ib_proceed = False, &
			ib_Warn = true
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
public function boolean of_iswhitespace (string as_source)
public function string of_removewhitespace (string as_source)
public function string of_globalreplace (string as_source, string as_old, string as_new)
public function integer of_setfrom (string as_from)
public function integer of_init ()
public function boolean of_isvalidemailformat (string as_email)
public subroutine of_sendhubnotification (long al_userid, string as_message)
public function integer of_sendemailnotification (long al_recip, string as_subject, string as_message)
public function integer of_sendemailnotification (string as_group, string as_subject, string as_message)
public function integer of_sendhubnotification (string as_group, string as_message)
public function integer of_getrecipients (ref string as_to)
public subroutine of_setwarn (boolean ab_warn)
public function integer of_sendemailnotification (long al_recip, string as_subject, string as_message, string as_attachment)
public function integer of_sendemailnotification (string as_group, string as_subject, string as_message, string as_attachment)
end prototypes

public function integer of_sendmail ();string	ls_Run, ls_Parm, ls_Shell, ls_to, ls_subject, ls_body, ls_from, ls_attach, ls_recip, ls_EmptyArray[]
int li_UB, li_Index
n_cst_string ln_string

// Don't verify path. Computer could have it in local path.	//
If IsNull(is_smtp) or is_smtp = '' or IsNull(is_port) or is_port = '' Then
	Return -1
End If

//Create the FROM parameter
ls_from = '-f ' + is_From + '@' + is_domain + ' '

//Start building the Blat run statement
ls_Parm = '"' + is_path + 'Blat" - -server ' + is_smtp + ' -port ' + is_port + ' '

//Add recipients as a comma separated list
If of_getrecipients(ls_to) = -1 Then
	Return -1
Else 
	ls_Parm += '-t ' + ls_to + ' '
End If

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

//Add attachment if it exists
If is_attach > '' Then
	ls_attach    = ("-attach " + '"' + is_attach + '" ')
End If
 
//Assemble the full Blat run statement
ls_Parm += ls_subject + ls_body + ls_from + ls_attach

//Create the Run command
ls_Run = "cmd /c " + ls_Parm

//Paste the command for the clipboard for troubleshooting
//Clipboard(ls_run)

//If not connected to Prod then change to TestingGroup and send
If NOT gb_isproduction Then
	If NOT ib_proceed Then
		//Clear the intended recipients & prefix the subject
		is_Recipients	= ls_EmptyArray
		ib_proceed = True
		is_Subject = 'TESTING: ' + is_Subject
		
		//Divert the message to the TestingGroup
		this.of_sendemailnotification('TestingGroup', is_Subject, is_message)
		
		Return 1
		
	Else 
		ib_proceed = false
		
	End If
	
End If

if ib_Warn then
	//Alert user about the email about to be sent so they don't freak out about the dos window
	ln_string.of_arraytostring(is_Recipients, ', ', ls_recip)
	MessageBox('Email Notification', 'An email notification is about to be sent to ' + ls_recip + ' regarding "' + is_Subject + '".')
end if

//Run the Blat command
Run(ls_Parm)

//Reset the variables
this.of_reset()

Return 1
end function

public function integer of_addrecipient (string as_recipient);int	li_UB

//Add recipient to instance array
IF NOT IsNull(as_Recipient) THEN
	If POS(as_Recipient, '@') <= 0 Then
		as_Recipient += '@' + is_domain
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
			is_Attach += ("," + as_Attach)
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

public subroutine of_reset ();string	ls_Empty, ls_EmptyArray[]

is_Attach			= ls_Empty
is_BCC			= ls_Empty
is_CC				= ls_Empty
is_Message		= ls_Empty
is_Password		= ls_Empty
is_Recipients	= ls_EmptyArray
is_Subject		= ls_Empty
is_User			= ls_Empty
is_From 			= 'noreply'

this.of_init()
end subroutine

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

public function integer of_setfrom (string as_from);is_From = as_from

Return 1


end function

public function integer of_init ();//Get EFC Domain
select value
into :is_domain
from efcreference
where module = 'hub'
and category = 'Email'
and subcategory = 'Domain';

//Get EFC SMTP
select value
into :is_smtp
from efcreference 
where category = 'Email'
and subcategory = 'SMTP';

//Get the Port
select value
into :is_port
from efcreference
where category = 'Email'
and subcategory = 'Port';

//Get the Path
select value
into :is_Path
from efcreference 
where category = 'Email'
and subcategory = 'Path';

//Set the default FROM
is_From = 'noreply'

ib_proceed = False

Return 1
end function

public function boolean of_isvalidemailformat (string as_email);//Validate the email address against the standard email address pattern
If as_email <> '' Then
	If match(as_email,'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z][a-zA-Z][a-zA-Z]*[a-zA-Z]*$') then
		Return True
	Else
		Return False
	End If
End If
end function

public subroutine of_sendhubnotification (long al_userid, string as_message);//If not connected to Prod then change to TestingGroup
If NOT gb_isproduction Then
	this.of_sendhubnotification('TestingGroup', as_message)
	Return
End If

//Create Hub Notification Record for the user. Insert a 0 for the EfcNotificationDefinitionId since this is not a "Tickler" message but from the system
insert into EfcNotification(EfcUserId, EfcNotificationDefinitionId, DateSent, NotificationSeen, Complete, NotificationMessage)
Values (:al_userid, 0, getdate(), 0, 0, :as_message);

end subroutine

public function integer of_sendemailnotification (long al_recip, string as_subject, string as_message);Return this.of_sendemailnotification(al_recip, as_subject, as_message, '')

end function

public function integer of_sendemailnotification (string as_group, string as_subject, string as_message);Return this.of_sendemailnotification(as_group, as_subject, as_message, '')
end function

public function integer of_sendhubnotification (string as_group, string as_message);string ls_email
long ll_user, ll_group, ll_row, ll_ret
datastore lds_members

//If not connected to Prod then change to TestingGroup
If NOT gb_isproduction Then
	as_group = 'TestingGroup'
	as_message = 'TESTING - ' + as_message
End If

//Get the group ID
select EfcNotificationGroupId
into :ll_group
from EfcNotificationGroup
where Upper(GroupName) = Upper(:as_group);

//If valid group, loop through all group memebers and send email
If ll_group > 0 Then
	
	If NOT IsValid(lds_members) Then lds_members = CREATE DataStore
	lds_members.DataObject = 'd_notificationgroupmembers'
	lds_members.SetTransObject(SQLCA)
	
	ll_ret = lds_members.Retrieve(ll_group)
	
	If ll_ret > 0 Then
		
		//Add each user to email
		For ll_row = 1 to ll_ret
			
			ll_user = lds_members.GetItemNumber(ll_row, 'efcuserid')
			
			If ll_user > 0 Then
				//Create Hub Notification Record for the user. Insert a 0 for the EfcNotificationDefinitionId since this is not a "Tickler" message but from the system
				insert into EfcNotification(EfcUserId, EfcNotificationDefinitionId, DateSent, NotificationSeen, Complete, NotificationMessage)
				Values (:ll_user, 0, getdate(), 0, 0, :as_message);
				
			End If
			
		Next
		
	End If
	
Else
	Return 0
	
End If

If IsValid(lds_members) Then DESTROY lds_members

Return 1

end function

public function integer of_getrecipients (ref string as_to);integer li_UB, li_Index

//Populate the reference argument with a comma separated list of recipients
li_UB = UpperBound(is_Recipients)

IF li_UB <= 0 THEN
	Return -1
END IF

For li_Index = 1 to li_UB
	If li_Index < li_UB Then
		as_to += is_Recipients[li_Index] + ','
	Else
		as_to += is_Recipients[li_Index]
	End If
Next

Return 1
end function

public subroutine of_setwarn (boolean ab_warn);ib_Warn = ab_Warn
end subroutine

public function integer of_sendemailnotification (long al_recip, string as_subject, string as_message, string as_attachment);string ls_recip

select Email
into :ls_recip
from EfcUser
where EfcUserId = :al_recip;

If ls_recip > '' Then
	this.of_addrecipient(ls_recip)
	this.of_setfrom('EfcHub')
	this.of_setsubject(as_subject)
	this.of_setmessage(as_message)
	
	If as_attachment > '' Then
		If FileExists(as_attachment) Then
			this.of_setattach(as_attachment)
		End If
	End If
	
	this.of_sendmail()
	
Else
	Return -1
	
End If


Return 1
end function

public function integer of_sendemailnotification (string as_group, string as_subject, string as_message, string as_attachment);string ls_email
long ll_user, ll_group, ll_row, ll_ret
datastore lds_members


//Get the group ID
select EfcNotificationGroupId
into :ll_group
from EfcNotificationGroup
where Upper(GroupName) = Upper(:as_group);

//If valid group, loop through all group memebers and send email
If ll_group > 0 Then
	
	If NOT IsValid(lds_members) Then lds_members = CREATE DataStore
	lds_members.DataObject = 'd_notificationgroupmembers'
	lds_members.SetTransObject(SQLCA)
	
	ll_ret = lds_members.Retrieve(ll_group)
	
	If ll_ret > 0 Then
		
		//Add each user to email
		For ll_row = 1 to ll_ret
			
			ll_user = lds_members.GetItemNumber(ll_row, 'efcuserid')
			
			//Get the email from the EfcUser table or from the Member table if External Email (EfcUserId = 0)
			If ll_user > 0 Then
				select Email
				into :ls_email
				from EfcUser
				where EfcUserId = :ll_user;
				
			Else
				ls_email = lds_members.GetItemString(ll_row, 'externalemail')
				
			End If
			
			If ls_email > '' Then
				this.of_addrecipient(ls_email)
			End If
			
		Next
		
		
		//Finish up and send email
		this.of_setfrom('EfcHub')
		this.of_setsubject(as_subject)
		this.of_setmessage(as_message)
		
		If as_attachment > '' Then
			If FileExists(as_attachment) Then
				this.of_setattach(as_attachment)
			End If
		End If
	
		this.of_sendmail()
		
	End If
	
Else
	Return 0
	
End If

If IsValid(lds_members) Then DESTROY lds_members

Return 1
end function

on n_cst_notification_service.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_notification_service.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;//Initialize
this.of_init()

end event

