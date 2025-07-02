forward
global type u_tabpg_notes from u_tabpg_dbaccess
end type
end forward

global type u_tabpg_notes from u_tabpg_dbaccess
integer width = 2930
integer height = 2432
boolean hscrollbar = true
string text = "Notes"
string picturename = "New!"
end type
global u_tabpg_notes u_tabpg_notes

forward prototypes
public subroutine of_set_last_updated_by (long al_row)
end prototypes

public subroutine of_set_last_updated_by (long al_row);
//*******************************************************
// Set the Last Updated by info:
//*******************************************************

dw_1.SetItem(al_row, "user_id", gnv_app.of_getuserid())
dw_1.SetItem(al_row, "note_dt",  f_getdbdatetime())
end subroutine

on u_tabpg_notes.create
call super::create
end on

on u_tabpg_notes.destroy
call super::destroy
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Application", "Notes"}
end event

event ue_tab_selected;call super::ue_tab_selected;
//******************************************************
// Limit Menu Functionality:
//******************************************************

m_gigp_master	lm_Menu

lm_Menu = it_Parent.iw_Parent.MenuID

//******************************************************
// Customize Menu:
//******************************************************

lm_Menu.m_edit.m_insertrow.Visible = True
lm_Menu.m_edit.m_insertrow.ToolBarItemVisible = True

lm_Menu.m_edit.m_deleterow.Visible = True
lm_Menu.m_edit.m_deleterow.ToolBarItemVisible = True

lm_Menu.m_file.m_print.Visible = True
lm_Menu.m_file.m_print.ToolBarItemVisible = True

//******************************************************
// Check Security:
//******************************************************

If (ib_editAccess = True) Then	
	lm_Menu.m_edit.m_insertrow.Enabled = True	
	lm_Menu.m_edit.m_deleterow.Enabled = True	
Else
	lm_Menu.m_edit.m_insertrow.Enabled = False	
	lm_Menu.m_edit.m_deleterow.Enabled = False
End If

//******************************************************
// Order the Sheet Toolbar:
//******************************************************

lm_Menu.m_edit.m_insertrow.ToolBarItemOrder 	= 1
lm_Menu.m_edit.m_deleterow.ToolBarItemOrder	= 2
lm_Menu.m_file.m_print.ToolBarItemOrder	 	= 3
lm_Menu.m_file.m_save.ToolBarItemOrder 		= 4
lm_Menu.m_file.m_close.ToolBarItemOrder 		= 5

end event

event ue_tab_deselected;call super::ue_tab_deselected;
//******************************************************
// Customize Menu:
//******************************************************

m_gigp_master	lm_Menu

lm_Menu = it_Parent.iw_Parent.MenuID

lm_Menu.m_edit.m_insertrow.Visible = False
lm_Menu.m_edit.m_insertrow.ToolBarItemVisible = False

lm_Menu.m_edit.m_deleterow.Visible = False
lm_Menu.m_edit.m_deleterow.ToolBarItemVisible = False

lm_Menu.m_file.m_print.Visible = False
lm_Menu.m_file.m_print.ToolBarItemVisible = False
end event

type dw_1 from u_tabpg_dbaccess`dw_1 within u_tabpg_notes
integer width = 2894
integer height = 2376
string dataobject = "d_gigp_notes"
end type

event dw_1::pfc_retrieve;
//OverRide//

String ls_appUser

ls_appUser = gnv_app.of_getuserid()

Return This.Retrieve(gl_gigp_id, ls_appUser)
end event

event dw_1::constructor;call super::constructor;
//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)

This.ib_RMBMenu = False
end event

event dw_1::buttonclicked;call super::buttonclicked;
String 	ls_Text, ls_noteUser, ls_appUser, ls_access
Integer	li_RC

Choose Case dwo.Name
	Case "b_edit"
		ls_access = "READ"
	
		dw_1.AcceptText()	
		
		ls_noteUser = Upper(This.GetItemString(row, "user_id"))
		ls_Text     = This.GetItemString(row, "comments")
		ls_appUser	= Upper(gnv_app.of_getuserid())
				
		If (ib_editAccess = True) AND (ls_noteUser = ls_appUser) Then ls_access = "EDIT"	
		
		li_RC = f_edit_notes(ls_access, ls_Text)
		
		If (li_RC = 1) Then 
			If this.GetItemNumber(row, 'cc_protect') = 0 Then
				This.SetItem(row, "comments", ls_Text)	
			End If
			
		End If
		
	Case "b_mwbe"
		open(w_mwbe_notes)
		
End Choose

end event

event dw_1::pfc_postinsertrow;call super::pfc_postinsertrow;
Integer li_RC
String ls_Text

of_set_last_updated_by(al_row)

This.SetItem(al_row, "note_type", "General")
This.SetItem(al_row, "note_category", "NOTE")
This.SetItem(al_row, "gigp_id", gl_gigp_id)
This.SetItem(al_row, 'cc_protect', 0)

li_RC = f_edit_notes("EDIT", ls_Text)

If (li_RC = 1) Then This.SetItem(al_row, "comments", ls_Text)	
end event

event dw_1::sqlpreview;call super::sqlpreview;
Long ll_keyID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN
	
	ll_keyID = This.GetItemNumber(row, "gigp_id", buffer, False)
	
	f_transactionlog("gigp_id", ll_keyID, This.DataObject, "Notes", sqlsyntax)
END IF
end event

