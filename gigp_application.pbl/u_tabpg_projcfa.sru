forward
global type u_tabpg_projcfa from u_tabpg_appinfo_base
end type
end forward

global type u_tabpg_projcfa from u_tabpg_appinfo_base
string tag = "CFA Tracking"
string text = "CFA Tracking"
string picturename = "Library!"
end type
global u_tabpg_projcfa u_tabpg_projcfa

on u_tabpg_projcfa.create
call super::create
end on

on u_tabpg_projcfa.destroy
call super::destroy
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Application"}
end event

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_projcfa
string dataobject = "d_proj_application_cfa"
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

	End If
		
	ll_row = dw_1.GetNextModified(ll_row, Primary!)

LOOP

Return AncestorReturnValue
end event

event dw_1::buttonclicked;call super::buttonclicked;string ls_text, ls_text_return
str_notes lstr_notes

Choose Case dwo.name
	Case 'b_status_comment'
		//Get current notes
		ls_text = this.GetItemString(row, 'project_status_comment')
		If IsNull(ls_text) Then ls_text = ''
		lstr_notes.str_text = ls_text
		
		//Open the Editor
		OpenWithParm(w_edit_notes, lstr_notes)
		
		//Get the passed back text
		ls_text_return = Message.StringParm
		
		//If text was modified then set it
		If ls_text_return <> ls_text and ls_text_return <> '$CANCEL$' Then
			this.SetItem(row, 'project_status_comment', ls_text_return)
		End If
		
	Case 'b_event_notes'
		//Get current notes
		ls_text = this.GetItemString(row, 'event_notes')
		If IsNull(ls_text) Then ls_text = ''
		lstr_notes.str_text = ls_text
		
		//Open the Editor
		OpenWithParm(w_edit_notes, lstr_notes)
		
		//Get the passed back text
		ls_text_return = Message.StringParm
		
		//If text was modified then set it
		If ls_text_return <> ls_text and ls_text_return <> '$CANCEL$' Then
			this.SetItem(row, 'event_notes', ls_text_return)
		End If
		
	Case 'b_env_impact'
		//Get current notes
		ls_text = this.GetItemString(row, 'environmental_impact')
		If IsNull(ls_text) Then ls_text = ''
		lstr_notes.str_text = ls_text
		
		//Open the Editor
		OpenWithParm(w_edit_notes, lstr_notes)
		
		//Get the passed back text
		ls_text_return = Message.StringParm
		
		//If text was modified then set it
		If ls_text_return <> ls_text and ls_text_return <> '$CANCEL$' Then
			this.SetItem(row, 'environmental_impact', ls_text_return)
		End If
		
End Choose
end event

