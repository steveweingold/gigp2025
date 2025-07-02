forward
global type w_amount_parm from w_report_parms
end type
type em_rptamt1 from editmask within w_amount_parm
end type
type em_rptamt2 from editmask within w_amount_parm
end type
type st_amt1 from statictext within w_amount_parm
end type
type st_amt2 from statictext within w_amount_parm
end type
end forward

global type w_amount_parm from w_report_parms
integer x = 214
integer y = 221
integer width = 1682
integer height = 788
windowanimationstyle openanimation = fadeanimation!
windowanimationstyle closeanimation = fadeanimation!
em_rptamt1 em_rptamt1
em_rptamt2 em_rptamt2
st_amt1 st_amt1
st_amt2 st_amt2
end type
global w_amount_parm w_amount_parm

type variables

String is_rptParm1,is_rptParm2
end variables

on w_amount_parm.create
int iCurrent
call super::create
this.em_rptamt1=create em_rptamt1
this.em_rptamt2=create em_rptamt2
this.st_amt1=create st_amt1
this.st_amt2=create st_amt2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.em_rptamt1
this.Control[iCurrent+2]=this.em_rptamt2
this.Control[iCurrent+3]=this.st_amt1
this.Control[iCurrent+4]=this.st_amt2
end on

on w_amount_parm.destroy
call super::destroy
destroy(this.em_rptamt1)
destroy(this.em_rptamt2)
destroy(this.st_amt1)
destroy(this.st_amt2)
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

//*******************************************************
// Set default Date(s):
//*******************************************************

is_rptParm1 = lstr_amount_parm.str_amtlabel1
st_amt1.Text = is_rptParm1

ld_amount1 				= lstr_amount_parm.str_amtvalue1
em_rptamt1.Text		= String(ld_amount1)
em_rptamt1.SetFocus()

is_rptParm2 = lstr_amount_parm.str_amtLabel2

If (is_rptParm2 <> "None") Then
	
	SetNull(ls_value)
	
	st_amt2.Text = is_rptParm2
	
	ld_amount2 = lstr_amount_parm.str_amtvalue2

	em_rptamt2.Text = String(ld_amount2)
	st_amt2.Visible = True
	em_rptamt2.Visible = True
End If

em_rptamt1.SetFocus()


end event

event ue_process;call super::ue_process;
String ls_amount1, ls_amount2

ls_amount1 = em_rptamt1.Text
of_add_parm("amount1", ls_amount1, "Decimal")

If (is_rptParm2 <> "None") Then	
	ls_amount2  = em_rptamt2.Text	
	of_add_parm("amount2", ls_amount2, "Decimal")
End If

//dw_1.Print()

Close(This)





















end event

type dw_1 from w_report_parms`dw_1 within w_amount_parm
end type

type cb_cancel from w_report_parms`cb_cancel within w_amount_parm
integer x = 1285
end type

type cb_ok from w_report_parms`cb_ok within w_amount_parm
integer x = 887
boolean default = true
end type

type em_rptamt1 from editmask within w_amount_parm
integer x = 1225
integer y = 104
integer width = 402
integer height = 84
integer taborder = 10
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

type em_rptamt2 from editmask within w_amount_parm
boolean visible = false
integer x = 1225
integer y = 328
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

type st_amt1 from statictext within w_amount_parm
integer x = 37
integer y = 112
integer width = 1175
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
string text = "Amount1"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_amt2 from statictext within w_amount_parm
boolean visible = false
integer x = 37
integer y = 340
integer width = 1175
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
string text = "Amount2"
alignment alignment = right!
boolean focusrectangle = false
end type

