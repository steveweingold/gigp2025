forward
global type u_tabpg_projepg from u_tabpg_appinfo_base
end type
end forward

global type u_tabpg_projepg from u_tabpg_appinfo_base
integer height = 1392
end type
global u_tabpg_projepg u_tabpg_projepg

on u_tabpg_projepg.create
call super::create
end on

on u_tabpg_projepg.destroy
call super::destroy
end on

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_projepg
integer height = 1968
string dataobject = "d_proj_project_epg"
end type

event dw_1::pfc_updateprep;call super::pfc_updateprep;Long 	ll_row, ll_gigpID

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

event dw_1::buttonclicked;call super::buttonclicked;String ls_access, ls_Text
integer li_rc

Choose Case dwo.Name 
	Case "b_edit"
	
		ls_access = "READ"
		
		dw_1.AcceptText()	
		
		ls_Text     = This.GetItemString(row, "keydate_comments")
				
		If (ib_editAccess = True) Then ls_access = "EDIT"	
		
		li_RC = f_edit_notes(ls_access, ls_Text)
		
		If (li_RC = 1) Then This.SetItem(row, "keydate_comments", ls_Text)	
		
End Choose


end event

