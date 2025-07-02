forward
global type w_program_parm from w_report_parms
end type
type rb_gigp from radiobutton within w_program_parm
end type
type rb_epg from radiobutton within w_program_parm
end type
type rb_ppg from radiobutton within w_program_parm
end type
type rb_septic from radiobutton within w_program_parm
end type
type rb_redi from radiobutton within w_program_parm
end type
type gb_1 from groupbox within w_program_parm
end type
end forward

global type w_program_parm from w_report_parms
integer x = 214
integer y = 221
integer width = 2011
integer height = 516
string title = "Select a Program"
rb_gigp rb_gigp
rb_epg rb_epg
rb_ppg rb_ppg
rb_septic rb_septic
rb_redi rb_redi
gb_1 gb_1
end type
global w_program_parm w_program_parm

on w_program_parm.create
int iCurrent
call super::create
this.rb_gigp=create rb_gigp
this.rb_epg=create rb_epg
this.rb_ppg=create rb_ppg
this.rb_septic=create rb_septic
this.rb_redi=create rb_redi
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.rb_gigp
this.Control[iCurrent+2]=this.rb_epg
this.Control[iCurrent+3]=this.rb_ppg
this.Control[iCurrent+4]=this.rb_septic
this.Control[iCurrent+5]=this.rb_redi
this.Control[iCurrent+6]=this.gb_1
end on

on w_program_parm.destroy
call super::destroy
destroy(this.rb_gigp)
destroy(this.rb_epg)
destroy(this.rb_ppg)
destroy(this.rb_septic)
destroy(this.rb_redi)
destroy(this.gb_1)
end on

event ue_process;call super::ue_process;String ls_value

//*************************************************************
// Get Program Parm:
//*************************************************************

SetNull(ls_value)

If rb_gigp.Checked Then
	ls_value = 'GIGP'
ElseIf rb_epg.Checked Then
	ls_value = 'EPG'
ElseIf rb_septic.Checked Then
	ls_value = 'Septic'
ElseIf rb_redi.Checked Then
	ls_value = 'REDI'
Else
	ls_value = 'PPG-EC'
End If

of_add_parm("program", ls_value, "String")


CloseWithReturn(This, dw_1)
end event

type dw_1 from w_report_parms`dw_1 within w_program_parm
integer y = 244
end type

type cb_cancel from w_report_parms`cb_cancel within w_program_parm
integer x = 974
integer y = 292
end type

type cb_ok from w_report_parms`cb_ok within w_program_parm
integer x = 576
integer y = 292
end type

type rb_gigp from radiobutton within w_program_parm
integer x = 855
integer y = 128
integer width = 206
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "GIGP"
boolean lefttext = true
end type

type rb_epg from radiobutton within w_program_parm
integer x = 110
integer y = 128
integer width = 197
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "EPG"
boolean checked = true
boolean lefttext = true
end type

type rb_ppg from radiobutton within w_program_parm
integer x = 462
integer y = 128
integer width = 238
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "PPG-EC"
boolean lefttext = true
end type

type rb_septic from radiobutton within w_program_parm
integer x = 1216
integer y = 128
integer width = 206
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Septic"
boolean lefttext = true
end type

type rb_redi from radiobutton within w_program_parm
integer x = 1577
integer y = 128
integer width = 206
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "REDI"
boolean lefttext = true
end type

type gb_1 from groupbox within w_program_parm
integer x = 41
integer y = 28
integer width = 1842
integer height = 216
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Program"
end type

