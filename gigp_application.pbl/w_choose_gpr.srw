forward
global type w_choose_gpr from w_pick_list
end type
end forward

global type w_choose_gpr from w_pick_list
integer width = 2912
integer height = 2880
string title = "Select a GPR Summary"
end type
global w_choose_gpr w_choose_gpr

on w_choose_gpr.create
call super::create
end on

on w_choose_gpr.destroy
call super::destroy
end on

event open;call super::open;//Comment
end event

type dw_list from w_pick_list`dw_list within w_choose_gpr
integer width = 2775
integer height = 2532
string dataobject = "d_choose_gpr"
end type

event dw_list::rowfocuschanged;call super::rowfocuschanged;is_Return = this.GetItemString(currentrow, 'ref_code')

end event

type cb_ok from w_pick_list`cb_ok within w_choose_gpr
integer x = 978
integer y = 2648
end type

type cb_cancel from w_pick_list`cb_cancel within w_choose_gpr
integer x = 1545
integer y = 2648
end type

