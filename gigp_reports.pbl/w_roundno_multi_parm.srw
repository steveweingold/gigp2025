forward
global type w_roundno_multi_parm from w_report_parms
end type
type dw_round from u_dw_enhanced within w_roundno_multi_parm
end type
type gb_1 from groupbox within w_roundno_multi_parm
end type
end forward

global type w_roundno_multi_parm from w_report_parms
integer width = 805
integer height = 1056
string title = "Select a Round No."
dw_round dw_round
gb_1 gb_1
end type
global w_roundno_multi_parm w_roundno_multi_parm

on w_roundno_multi_parm.create
int iCurrent
call super::create
this.dw_round=create dw_round
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_round
this.Control[iCurrent+2]=this.gb_1
end on

on w_roundno_multi_parm.destroy
call super::destroy
destroy(this.dw_round)
destroy(this.gb_1)
end on

event ue_process;call super::ue_process;String ls_value
long ll_count, ll_row

//*************************************************************
// Get Round No. Parm:
//*************************************************************
ll_count = dw_round.RowCount()

ls_value = ''

For ll_row = 1 to ll_count
	If dw_round.IsSelected(ll_row) Then
		ls_value += '|' + String(dw_round.GetItemNumber(ll_row, 'round_no')) + '|'
		
	End If
	
Next

of_add_parm("round_no",ls_value, "String")


Close(This)
end event

type dw_1 from w_report_parms`dw_1 within w_roundno_multi_parm
integer x = 165
integer y = 188
end type

type cb_cancel from w_report_parms`cb_cancel within w_roundno_multi_parm
integer x = 407
integer y = 812
end type

type cb_ok from w_report_parms`cb_ok within w_roundno_multi_parm
integer x = 32
integer y = 812
end type

type dw_round from u_dw_enhanced within w_roundno_multi_parm
integer x = 183
integer y = 100
integer width = 389
integer height = 616
integer taborder = 20
boolean bringtotop = true
string dataobject = "d_round_no_list"
end type

event clicked;call super::clicked;If this.IsSelected(row) Then
	this.SelectRow(row, False)
Else
	this.SelectRow(row, True)
End If

end event

event constructor;call super::constructor;this.SetTransObject(SQLCA)

this.Retrieve()
end event

type gb_1 from groupbox within w_roundno_multi_parm
integer x = 128
integer y = 28
integer width = 503
integer height = 732
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Select Round(s)"
end type

