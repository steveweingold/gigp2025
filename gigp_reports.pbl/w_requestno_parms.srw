forward
global type w_requestno_parms from w_report_parms
end type
type st_1 from statictext within w_requestno_parms
end type
type em_requestno from editmask within w_requestno_parms
end type
end forward

global type w_requestno_parms from w_report_parms
integer width = 1047
integer height = 396
string title = "Select Request No"
boolean controlmenu = false
st_1 st_1
em_requestno em_requestno
end type
global w_requestno_parms w_requestno_parms

on w_requestno_parms.create
int iCurrent
call super::create
this.st_1=create st_1
this.em_requestno=create em_requestno
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
this.Control[iCurrent+2]=this.em_requestno
end on

on w_requestno_parms.destroy
call super::destroy
destroy(this.st_1)
destroy(this.em_requestno)
end on

event open;call super::open;
String ls_parm

ls_parm = Message.StringParm

em_requestno.text = ls_parm

end event

event ue_process;call super::ue_process;
String ls_value


//*************************************************************
// Get Next Request No. Parm:
//*************************************************************

ls_value = em_requestno.Text

If IsNull(ls_value) Or (Integer(ls_value) < 1) Then
	
	MessageBox("ERROR!", "Enter a valid Request No.")
Else
	
	of_add_parm("nextRequest",ls_value, "String")	
	//dw_1.Print()	
	Close(This)

End If
end event

type dw_1 from w_report_parms`dw_1 within w_requestno_parms
integer x = 32
integer y = 428
end type

type cb_cancel from w_report_parms`cb_cancel within w_requestno_parms
boolean visible = false
integer x = 37
end type

type cb_ok from w_report_parms`cb_ok within w_requestno_parms
integer x = 640
integer y = 188
boolean default = true
end type

type st_1 from statictext within w_requestno_parms
integer x = 59
integer y = 36
integer width = 343
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
string text = "Request No."
alignment alignment = right!
boolean focusrectangle = false
end type

type em_requestno from editmask within w_requestno_parms
integer x = 421
integer y = 24
integer width = 443
integer height = 88
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
string mask = "######"
string minmax = "1~~"
end type

