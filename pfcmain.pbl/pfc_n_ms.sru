﻿//objectcomments PFC Mail Session Class
forward
global type pfc_n_ms from mailsession
end type
end forward

global type pfc_n_ms from mailsession
end type
global pfc_n_ms pfc_n_ms

forward prototypes
protected function integer of_messagebox (string as_id, string as_title, string as_text, icon ae_icon, button ae_button, integer ai_default)
end prototypes

protected function integer of_messagebox (string as_id, string as_title, string as_text, icon ae_icon, button ae_button, integer ai_default);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  			of_MessageBox
//
//	Access:  			protected
//
//	Arguments:
//	as_id			An ID for the Message.
//	as_title  	Text for title bar
//	as_text		Text for the actual message.
//	ae_icon 		The icon you want to display on the MessageBox.
//	ae_button	Set of CommandButtons you want to display on the MessageBox.
//	ai_default  The default button.
//
//	Returns:  integer
//	Return value of the MessageBox.
//
//	Description:
//	Display a PowerScript MessageBox.  
//	Allow PFC MessageBoxes to be manipulated prior to their actual display.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	6.0   Initial version
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

Return MessageBox(as_title, as_text, ae_icon, ae_button, ai_default)
end function

on pfc_n_ms.create
call mailsession::create
TriggerEvent( this, "constructor" )
end on

on pfc_n_ms.destroy
call mailsession::destroy
TriggerEvent( this, "destructor" )
end on

