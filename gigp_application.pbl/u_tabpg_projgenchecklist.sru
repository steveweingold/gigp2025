forward
global type u_tabpg_projgenchecklist from u_tabpg_appinfo_base
end type
end forward

global type u_tabpg_projgenchecklist from u_tabpg_appinfo_base
string tag = "Project Checklist"
string text = "Checklist"
string picturename = "CheckBox!"
end type
global u_tabpg_projgenchecklist u_tabpg_projgenchecklist

on u_tabpg_projgenchecklist.create
call super::create
end on

on u_tabpg_projgenchecklist.destroy
call super::destroy
end on

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_projgenchecklist
string dataobject = "d_proj_general_checklist"
end type

event dw_1::pfc_updateprep;call super::pfc_updateprep;

Long 	ll_row, ll_gigpID

//*******************************************************
// Loop thru modified rows:
//*******************************************************

ll_row	= dw_1.GetNextModified(0, Primary!)

DO WHILE ll_row > 0	
	
	//*******************************************************
	// If new row, Set key values:
	//*******************************************************

	ll_gigpID = This.GetItemNumber(ll_row, "gigp_id")

	If IsNull(ll_gigpID) Then
		This.SetItem(ll_row, "gigp_id",gl_gigp_id)	  
		This.SetItem(ll_row, "ref_code", This.GetItemString(ll_row, "ref_ref_code")) 	
		This.SetItem(ll_row, "last_updated_by", gnv_app.of_getuserid())
		This.SetItem(ll_row, "last_updated_dt", f_getdbdatetime())		
		This.SetItemStatus(ll_row, 0,  Primary!, NewModified!)
	End If
		
	ll_row = dw_1.GetNextModified(ll_row, Primary!)

LOOP

Return AncestorReturnValue

end event

event dw_1::buttonclicked;call super::buttonclicked;String 	ls_Text, ls_noteUser, ls_appUser, ls_access
Integer	li_RC


If (dwo.Name = "b_edit") Then	
	
	ls_access = "READ"
	
	dw_1.AcceptText()	
	
	ls_Text     = This.GetItemString(row, "checklist_comments")
			
	If (ib_editAccess = True) Then ls_access = "EDIT"	
	
	li_RC = f_edit_notes(ls_access, ls_Text)
	
	If (li_RC = 1) Then This.SetItem(row, "checklist_comments", ls_Text)	
	
End If

end event

