forward
global type u_tabpg_projsummaries from u_tabpg_appinfo_base
end type
end forward

global type u_tabpg_projsummaries from u_tabpg_appinfo_base
string tag = "Project Summaries"
string text = "Summaries"
string picturename = "ScriptYes!"
end type
global u_tabpg_projsummaries u_tabpg_projsummaries

on u_tabpg_projsummaries.create
call super::create
end on

on u_tabpg_projsummaries.destroy
call super::destroy
end on

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_projsummaries
string title = "Project Summaries"
string dataobject = "d_proj_summaries"
boolean livescroll = false
end type

event dw_1::buttonclicked;call super::buttonclicked;String 	ls_Text, ls_noteUser, ls_appUser, ls_access, ls_gprCode, ls_gprText
Integer	li_RC
Long ll_row

Choose Case dwo.Name
	Case "b_edit"
	
		ls_access = "READ"
		
		dw_1.AcceptText()	
		
		ls_Text     = This.GetItemString(row, "comments")
				
		If (ib_editAccess = True) Then ls_access = "EDIT"	
		
		li_RC = f_edit_notes(ls_access, ls_Text)
		
		If (li_RC = 1) Then This.SetItem(row, "comments", ls_Text)	
		
	Case 'b_gpr'
		If ib_editAccess Then
			Open(w_choose_gpr)
			ls_gprCode = Message.StringParm
			
			If ls_gprCode > '' Then
				select description
				into :ls_gprText
				from gigp_reference
				where category = 'GPRChoice'
				and ref_code = :ls_gprCode;
				
				If ls_gprText > '' Then
					ll_row = this.Find("ref_ref_code = 'gprsummary'", 1, this.RowCount())
					
					If ll_row > 0 Then 
						this.SetItem(ll_row, 'comments', ls_gprText)
					End If
					
				End If
				
			End If
			
		End If
	
End Choose

end event

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
		
		This.SetItem(ll_row, "note_category", "appNote") 	
		This.SetItem(ll_row, "note_type", This.GetItemString(ll_row, "ref_ref_code")) 	
		This.SetItem(ll_row, "user_id", gnv_app.of_getuserid())
		This.SetItem(ll_row, "note_dt", f_getdbdatetime())
		This.SetItemStatus(ll_row, 0,  Primary!, NewModified!)
	End If
		
	ll_row = dw_1.GetNextModified(ll_row, Primary!)

LOOP

Return AncestorReturnValue

end event

event dw_1::itemchanged;
//OverRide//

This.SetItem(row, "user_id", gnv_app.of_getuserid())
This.SetItem(row, "note_dt", f_getdbdatetime())
end event

event dw_1::sqlpreview;call super::sqlpreview;
String	ls_category
Long 	ll_gigpID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	
	ll_gigpID = This.GetItemNumber(row, "gigp_id")
	ls_category = This.Tag	
	
	f_transactionlog("gigp_id", ll_gigpID, This.DataObject, ls_category, sqlsyntax)
END IF
end event

