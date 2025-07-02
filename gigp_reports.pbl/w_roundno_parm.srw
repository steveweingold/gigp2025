forward
global type w_roundno_parm from w_report_parms
end type
type st_4 from statictext within w_roundno_parm
end type
type ddlb_round from dropdownlistbox within w_roundno_parm
end type
end forward

global type w_roundno_parm from w_report_parms
integer width = 1262
integer height = 516
string title = "Select a Round No."
st_4 st_4
ddlb_round ddlb_round
end type
global w_roundno_parm w_roundno_parm

on w_roundno_parm.create
int iCurrent
call super::create
this.st_4=create st_4
this.ddlb_round=create ddlb_round
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_4
this.Control[iCurrent+2]=this.ddlb_round
end on

on w_roundno_parm.destroy
call super::destroy
destroy(this.st_4)
destroy(this.ddlb_round)
end on

event ue_process;call super::ue_process;
String ls_value, ls_value2

//*************************************************************
// Get Round No. Parm:
//*************************************************************

SetNull(ls_value)
SetNull(ls_value2)

ls_value = ddlb_round.Text

of_add_parm("round_no",ls_value, "String")


//dw_1.Print()

Close(This)
end event

type dw_1 from w_report_parms`dw_1 within w_roundno_parm
integer y = 244
end type

type cb_cancel from w_report_parms`cb_cancel within w_roundno_parm
integer x = 873
integer y = 244
end type

type cb_ok from w_report_parms`cb_ok within w_roundno_parm
integer x = 475
integer y = 244
end type

type st_4 from statictext within w_roundno_parm
integer x = 151
integer y = 36
integer width = 288
integer height = 56
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Round No.:"
alignment alignment = right!
boolean focusrectangle = false
end type

type ddlb_round from dropdownlistbox within w_roundno_parm
integer x = 475
integer y = 28
integer width = 384
integer height = 392
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean sorted = false
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

event constructor;
Integer li_default, li_sort
String ls_value, ls_default

This.AddItem("ALL")

DECLARE cRound CURSOR FOR
		Select ref_value, cat_default, sort_order
		From gigp_reference
		where Category = 'Application'
		And sub_category = 'Round Number'
		Order by sort_order;
	
OPEN cRound;
	
FETCH cRound INTO :ls_value, :li_default, :li_sort;
	
DO WHILE SQLCA.sqlcode = 0
			
	This.AddItem(ls_value)	
	
	If (li_default = 1) Then
		ls_default = ls_value
	End If
	
	li_default = 0
	SetNull(ls_value)
			
	FETCH cRound INTO :ls_value, :li_default, :li_sort;
	
LOOP
	
CLOSE cRound;

This.SelectItem(ls_default, 0)
end event

