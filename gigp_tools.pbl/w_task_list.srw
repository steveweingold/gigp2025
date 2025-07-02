forward
global type w_task_list from w_sheet_dbaccess
end type
type dw_filter from u_dw within w_task_list
end type
type cb_clear from commandbutton within w_task_list
end type
type dw_task from u_dw_enhanced within w_task_list
end type
type gb_1 from groupbox within w_task_list
end type
end forward

global type w_task_list from w_sheet_dbaccess
string tag = "Task List"
integer x = 214
integer y = 221
integer width = 3726
integer height = 2396
string title = "Task List"
string menuname = "m_gigp_sheet"
dw_filter dw_filter
cb_clear cb_clear
dw_task dw_task
gb_1 gb_1
end type
global w_task_list w_task_list

on w_task_list.create
int iCurrent
call super::create
if this.MenuName = "m_gigp_sheet" then this.MenuID = create m_gigp_sheet
this.dw_filter=create dw_filter
this.cb_clear=create cb_clear
this.dw_task=create dw_task
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_filter
this.Control[iCurrent+2]=this.cb_clear
this.Control[iCurrent+3]=this.dw_task
this.Control[iCurrent+4]=this.gb_1
end on

on w_task_list.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.dw_filter)
destroy(this.cb_clear)
destroy(this.dw_task)
destroy(this.gb_1)
end on

event open;//override
m_gigp_master lm_sheet

// Turn on resize service.	//
this.of_SetResize(True)

this.inv_Resize.of_Register(dw_task,"ScaleToRight&Bottom")
dw_task.Event pfc_retrieve()

//Set Security
If NOT gnv_app.of_ingroup('TaskList') and NOT gnv_app.of_ingroup('TAS-Global') Then
	ib_isupdateable = False
	
	dw_task.Object.DataWindow.ReadOnly='Yes'
	
End If

//Modify Menu
lm_sheet = this.MenuId
lm_sheet.m_file.m_save.Visible = True
lm_sheet.m_file.m_save.ToolBarItemVisible = True
lm_sheet.m_file.m_save.ToolBarItemOrder = 98
If NOT ib_isupdateable Then lm_sheet.m_file.m_save.Enabled = False

lm_sheet.m_edit.m_insertrow.Visible = True
lm_sheet.m_edit.m_insertrow.ToolBarItemVisible = True
If NOT ib_isupdateable Then lm_sheet.m_edit.m_insertrow.Enabled = False

lm_sheet.m_edit.m_deleterow.Visible = True
lm_sheet.m_edit.m_deleterow.ToolBarItemVisible = True
If NOT ib_isupdateable Then lm_sheet.m_edit.m_deleterow.Enabled = False

this.x = 0
this.y = 0
this.width = gnv_app.of_getframe().width - 50
this.height = gnv_app.of_getframe().height - 425


dw_task.SetRowFocusIndicator(Hand!)
end event

event pfc_preupdate;//override

Return 1
end event

event pfc_endtran;//override
IF ai_update_results = 1 THEN
	EXECUTE IMMEDIATE "commit";

	MessageBox(this.Title,"Update was successful.")

	this.Event Post ue_PostSuccess()

	Return 1
ELSE
	EXECUTE IMMEDIATE "rollback";

	MessageBox(this.Title,"Update failed.")

	this.Event Post ue_PostFailure()

	Return -1
END IF


end event

type dw_filter from u_dw within w_task_list
event ue_clear ( )
event ue_filter ( )
integer x = 69
integer y = 60
integer width = 3145
integer height = 96
integer taborder = 30
string dataobject = "d_task_list_filters"
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event ue_clear();this.Reset()
this.InsertRow(0)
end event

event ue_filter();string ls_category, ls_status, ls_filter
long ll_round, ll_emp

//Get selected values
ll_round = this.GetItemNumber(1, 'round_no')
ll_emp = this.GetItemNumber(1, 'assigned_to')
ls_category = this.GetItemString(1, 'category')
ls_status = this.GetItemString(1, 'status')

//Build the filter string
ls_filter = ''

If ll_round > 0 Then
	If ls_filter = '' Then
		ls_filter = 'round_no = ' + String(ll_round)
	Else
		ls_filter += ' and round_no = ' + String(ll_round)
	End If
	
End If

If ll_emp > 0 Then
	If ls_filter = '' Then
		ls_filter = '(assigned_staff1 = ' + String(ll_emp) + ' or assigned_staff2 = ' + String(ll_emp) + ')'
	Else
		ls_filter += ' and (assigned_staff1 = ' + String(ll_emp) + ' or assigned_staff2 = ' + String(ll_emp) + ')'
	End If
	
End If

If ls_category <> 'NONE' Then
	If ls_filter = '' Then
		ls_filter = "task_category = '" + ls_category + "'"
	Else
		ls_filter += " and task_category = '" + ls_category + "'"
	End If
	
End If

If ls_status <> 'NONE' Then
	If ls_filter = '' Then
		ls_filter = "status = '" + ls_status + "'"
	Else
		ls_filter += " and status = '" + ls_status + "'"
	End If
End If


//Set the filter string
dw_task.SetFilter(ls_filter)
dw_task.Filter()
end event

event constructor;call super::constructor;this.SetTransObject(SQLCA)
this.InsertRow(0)
end event

event itemchanged;call super::itemchanged;this.Event Post ue_filter()
end event

type cb_clear from commandbutton within w_task_list
integer x = 3259
integer y = 56
integer width = 343
integer height = 100
integer taborder = 20
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Clear"
end type

event clicked;dw_task.SetFilter('')
dw_task.Filter()
dw_filter.Event ue_clear()
end event

type dw_task from u_dw_enhanced within w_task_list
event ue_filter ( )
integer x = 41
integer y = 228
integer width = 3593
integer height = 1952
integer taborder = 10
string dataobject = "d_task_list"
boolean hscrollbar = true
end type

event ue_filter();//	

end event

event pfc_retrieve;call super::pfc_retrieve;
Return this.Retrieve()


end event

event constructor;call super::constructor;this.SetTransObject(SQLCA)
end event

event pfc_insertrow;//Override
long ll_row

ll_row = this.Event pfc_addrow()

this.ScrollToRow(ll_row)

return 1
end event

event buttonclicked;call super::buttonclicked;string ls_notes, ls_notes_return
str_notes	lstr_notes


If dwo.name = 'b_comments' Then
	this.AcceptText()
	
	//Get current notes
	ls_notes = this.GetItemString(row, 'comments')
	If IsNull(ls_notes) Then ls_notes = ''
	lstr_notes.str_text = ls_notes
	
	//Open the Editor
	OpenWithParm(w_edit_notes, lstr_notes)
	
	//Get the passed back text
	ls_notes_return = Message.StringParm
	
	//If text was modified then set it
	If ls_notes_return <> ls_notes and ls_notes_return <> '$CANCEL$' and parent.ib_isupdateable Then
		this.SetItem(row, 'comments', ls_notes_return)
	End If
	
End If

end event

event pfc_postinsertrow;call super::pfc_postinsertrow;//add values
this.SetItem(al_row, "tasklist_id", f_gettokenvalue("tasklist_id", 1))
this.SetItem(al_row, 'created_dt', DateTime(today()))
this.SetItem(al_row, 'created_by', gnv_app.of_getuserid())
this.SetItem(al_row, 'last_updated_dt', DateTime(today()))
this.SetItem(al_row, 'last_updated_by', gnv_app.of_getuserid())
end event

event pfc_postupdate;call super::pfc_postupdate;this.Sort()
this.GroupCalc()

Return ancestorreturnvalue
end event

type gb_1 from groupbox within w_task_list
integer x = 41
integer width = 3593
integer height = 180
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Filter"
end type

