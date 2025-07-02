forward
global type w_mwbe_notes from w_gigp_response
end type
type dw_1 from u_dw_enhanced within w_mwbe_notes
end type
end forward

global type w_mwbe_notes from w_gigp_response
integer x = 214
integer y = 221
integer width = 4411
integer height = 2860
string title = "MWBE Notes"
dw_1 dw_1
end type
global w_mwbe_notes w_mwbe_notes

on w_mwbe_notes.create
int iCurrent
call super::create
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on w_mwbe_notes.destroy
call super::destroy
destroy(this.dw_1)
end on

type cb_cancel from w_gigp_response`cb_cancel within w_mwbe_notes
integer x = 4027
integer y = 2624
end type

type cb_ok from w_gigp_response`cb_ok within w_mwbe_notes
integer x = 3630
integer y = 2624
end type

type dw_1 from u_dw_enhanced within w_mwbe_notes
integer x = 23
integer y = 16
integer width = 4347
integer height = 2584
integer taborder = 10
string dataobject = "d_gigp_notes_mwbe"
end type

event pfc_retrieve;
//OverRide//

String ls_appUser

ls_appUser = gnv_app.of_getuserid()

Return This.Retrieve(gl_gigp_id, ls_appUser)


end event

event constructor;call super::constructor;
This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)


this.SetTransObject(SQLCA)
this.Event Post pfc_retrieve()
end event

event buttonclicked;call super::buttonclicked;String 	ls_Text, ls_noteUser, ls_appUser, ls_access
Integer	li_RC



Choose Case dwo.Name
	Case "b_ed"
		ls_access = "READ"
	
		dw_1.AcceptText()	
		
		ls_noteUser = Upper(This.GetItemString(row, "user_id"))
		ls_Text     = This.GetItemString(row, "comments")
		ls_appUser	= Upper(gnv_app.of_getuserid())
	 	
		 f_edit_notes(ls_access, ls_Text)
		 
End Choose

end event

