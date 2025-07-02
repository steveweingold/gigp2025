forward
global type w_call_log_stack from w_pick_list
end type
type gb_1 from groupbox within w_call_log_stack
end type
end forward

global type w_call_log_stack from w_pick_list
integer width = 1957
integer height = 2276
string title = "Select a Contact"
gb_1 gb_1
end type
global w_call_log_stack w_call_log_stack

on w_call_log_stack.create
int iCurrent
call super::create
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.gb_1
end on

on w_call_log_stack.destroy
call super::destroy
destroy(this.gb_1)
end on

type dw_list from w_pick_list`dw_list within w_call_log_stack
integer y = 64
integer width = 1829
integer height = 1944
string dataobject = "d_call_log_stack"
boolean border = false
borderstyle borderstyle = stylebox!
end type

event dw_list::rowfocuschanged;call super::rowfocuschanged;If currentrow > 0 Then
	is_return = String(this.GetItemNumber(currentrow, 'contact_id'))
End If
end event

type cb_ok from w_pick_list`cb_ok within w_call_log_stack
integer x = 512
integer y = 2076
end type

type cb_cancel from w_pick_list`cb_cancel within w_call_log_stack
integer x = 1079
integer y = 2076
end type

type gb_1 from groupbox within w_call_log_stack
integer x = 37
integer y = 20
integer width = 1861
integer height = 2028
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
end type

