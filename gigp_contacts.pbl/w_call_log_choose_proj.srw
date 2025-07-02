forward
global type w_call_log_choose_proj from w_pick_list
end type
end forward

global type w_call_log_choose_proj from w_pick_list
integer width = 2469
integer height = 1140
string title = "Select the Project(s)"
end type
global w_call_log_choose_proj w_call_log_choose_proj

type variables
long il_ContactId
end variables

on w_call_log_choose_proj.create
call super::create
end on

on w_call_log_choose_proj.destroy
call super::destroy
end on

event open;call super::open;// This will be a pick list. Use row selection service.	//
dw_list.of_SetRowSelect(False)
dw_list.SelectRow(0, False)


dw_list.SetFocus()


end event

event pfc_default;//Override to allow a comma separted list to be developed for is_return
long ll_row, ll_count
integer li_index
string ls_gigp[]
n_cst_string ln_string


ll_count = dw_list.RowCount()
li_index = 0

If ll_count > 0 Then
	For ll_row = 1 to ll_count
		If dw_list.GetItemNumber(ll_row, 'checked') = 1 Then
			li_index++
			ls_gigp[li_index] = String(dw_list.GetItemNumber(ll_row, 'gigp_id'))
			
		End If
	Next
End If

If li_index > 0 Then
	ln_string.of_ArrayToString(ls_gigp, ',', is_Return)

End If

CloseWithReturn(this,is_Return)
end event

event pfc_preopen;call super::pfc_preopen;il_ContactId = Message.DoubleParm
end event

event closequery;//override

end event

event pfc_cancel;//override
is_return = 'CANCEL'

CloseWithReturn(this,is_Return)
end event

type dw_list from w_pick_list`dw_list within w_call_log_choose_proj
integer x = 18
integer y = 24
integer width = 2409
integer height = 884
string dataobject = "d_call_log_choose_proj"
end type

event dw_list::pfc_retrieve;//override to use parameter

Return this.Retrieve(il_ContactId)

end event

event dw_list::rowfocuschanged;//override

end event

event dw_list::buttonclicked;call super::buttonclicked;long ll_row, ll_count

If dwo.name = 'b_check_all' Then
	ll_count = this.RowCount()
	If ll_count > 0 Then
		For ll_row = 1 to ll_count
			this.SetItem(ll_row, 'checked', 1)
		Next
	End If
End If
end event

type cb_ok from w_pick_list`cb_ok within w_call_log_choose_proj
integer x = 754
integer y = 948
end type

type cb_cancel from w_pick_list`cb_cancel within w_call_log_choose_proj
integer x = 1321
integer y = 948
end type

