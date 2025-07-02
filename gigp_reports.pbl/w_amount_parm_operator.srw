forward
global type w_amount_parm_operator from w_report_parms
end type
type em_rptamt from editmask within w_amount_parm_operator
end type
type st_amt2 from statictext within w_amount_parm_operator
end type
type rb_less from radiobutton within w_amount_parm_operator
end type
type rb_greater from radiobutton within w_amount_parm_operator
end type
type st_1 from statictext within w_amount_parm_operator
end type
type gb_1 from groupbox within w_amount_parm_operator
end type
end forward

global type w_amount_parm_operator from w_report_parms
integer x = 214
integer y = 221
integer width = 1682
integer height = 656
windowanimationstyle openanimation = fadeanimation!
windowanimationstyle closeanimation = fadeanimation!
em_rptamt em_rptamt
st_amt2 st_amt2
rb_less rb_less
rb_greater rb_greater
st_1 st_1
gb_1 gb_1
end type
global w_amount_parm_operator w_amount_parm_operator

type variables

String is_rptParm1,is_rptParm2
end variables

on w_amount_parm_operator.create
int iCurrent
call super::create
this.em_rptamt=create em_rptamt
this.st_amt2=create st_amt2
this.rb_less=create rb_less
this.rb_greater=create rb_greater
this.st_1=create st_1
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.em_rptamt
this.Control[iCurrent+2]=this.st_amt2
this.Control[iCurrent+3]=this.rb_less
this.Control[iCurrent+4]=this.rb_greater
this.Control[iCurrent+5]=this.st_1
this.Control[iCurrent+6]=this.gb_1
end on

on w_amount_parm_operator.destroy
call super::destroy
destroy(this.em_rptamt)
destroy(this.st_amt2)
destroy(this.rb_less)
destroy(this.rb_greater)
destroy(this.st_1)
destroy(this.gb_1)
end on

event open;call super::open;
Decimal 	ld_amount1, ld_amount2
String  	ls_value
Integer	li_pos

str_amount_parm lstr_amount_parm

//*******************************************************
// Get Report Parameters: 
//*******************************************************

lstr_amount_parm = Message.PowerObjectParm

If Not IsValid(lstr_amount_parm) Then
	MessageBox("ERROR!", "Error generating report parms - See I.T.!")
	cb_cancel.Event clicked()
End If

em_rptamt.SetFocus()


end event

event ue_process;call super::ue_process;String ls_amount1, ls_amount2, ls_amt

ls_amt = em_rptamt.Text

If rb_greater.Checked Then
	ls_amount1 = ls_amt
	ls_amount2 = '999999999'
Else
	ls_amount1 = '0'
	ls_amount2 = ls_amt
End If



of_add_parm("amount1", ls_amount1, "Decimal")
of_add_parm("amount2", ls_amount2, "Decimal")



Close(This)





















end event

type dw_1 from w_report_parms`dw_1 within w_amount_parm_operator
integer x = 32
integer y = 440
end type

type cb_cancel from w_report_parms`cb_cancel within w_amount_parm_operator
integer x = 1285
integer y = 408
end type

type cb_ok from w_report_parms`cb_ok within w_amount_parm_operator
integer x = 887
integer y = 408
boolean default = true
end type

type em_rptamt from editmask within w_amount_parm_operator
integer x = 1225
integer y = 124
integer width = 402
integer height = 84
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
string text = "none"
alignment alignment = right!
borderstyle borderstyle = stylelowered!
string mask = "##,###,##0.00"
end type

event getfocus;This.SelectText(1, Len(This.Text))
end event

type st_amt2 from statictext within w_amount_parm_operator
integer x = 1225
integer y = 44
integer width = 402
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
string text = "*Amount:"
alignment alignment = right!
boolean focusrectangle = false
end type

type rb_less from radiobutton within w_amount_parm_operator
integer x = 727
integer y = 128
integer width = 343
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Less Than"
end type

event clicked;em_rptamt.SetFocus()
end event

type rb_greater from radiobutton within w_amount_parm_operator
integer x = 101
integer y = 128
integer width = 439
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Greater Than"
boolean checked = true
end type

event clicked;em_rptamt.SetFocus()
end event

type st_1 from statictext within w_amount_parm_operator
integer x = 585
integer y = 288
integer width = 1042
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
string text = "*For all records, use Greater Than $0.00"
alignment alignment = right!
boolean focusrectangle = false
end type

type gb_1 from groupbox within w_amount_parm_operator
integer x = 59
integer y = 64
integer width = 1102
integer height = 164
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
end type

