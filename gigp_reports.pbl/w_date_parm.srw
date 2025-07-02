forward
global type w_date_parm from w_report_parms
end type
type em_rptdt1 from editmask within w_date_parm
end type
type em_rptdt2 from editmask within w_date_parm
end type
type st_dt1 from statictext within w_date_parm
end type
type st_dt2 from statictext within w_date_parm
end type
end forward

global type w_date_parm from w_report_parms
integer width = 1682
integer height = 788
windowanimationstyle openanimation = fadeanimation!
windowanimationstyle closeanimation = fadeanimation!
em_rptdt1 em_rptdt1
em_rptdt2 em_rptdt2
st_dt1 st_dt1
st_dt2 st_dt2
end type
global w_date_parm w_date_parm

type variables

String is_rptParm1,is_rptParm2
end variables

on w_date_parm.create
int iCurrent
call super::create
this.em_rptdt1=create em_rptdt1
this.em_rptdt2=create em_rptdt2
this.st_dt1=create st_dt1
this.st_dt2=create st_dt2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.em_rptdt1
this.Control[iCurrent+2]=this.em_rptdt2
this.Control[iCurrent+3]=this.st_dt1
this.Control[iCurrent+4]=this.st_dt2
end on

on w_date_parm.destroy
call super::destroy
destroy(this.em_rptdt1)
destroy(this.em_rptdt2)
destroy(this.st_dt1)
destroy(this.st_dt2)
end on

event open;call super::open;
DateTime ldt_start, ldt_end
String    	ls_value
Integer	li_pos

str_date_parm lstr_date_parm

//*******************************************************
// Get Report Parameters: 
//*******************************************************

lstr_date_parm = Message.PowerObjectParm

If Not IsValid(lstr_date_parm) Then
	MessageBox("ERROR!", "Error generating report parms - See I.T.!")
	cb_cancel.Event clicked()
End If

//*******************************************************
// Set default Date(s):
//*******************************************************

is_rptParm1 = lstr_date_parm.str_dateLabel1
st_dt1.Text = is_rptParm1

ldt_start 				= lstr_date_parm.str_dateValue1
ls_value 				= String(ldt_start, "mm/dd/yyyy")
em_rptdt1.Text		= ls_value

is_rptParm2 = lstr_date_parm.str_dateLabel2

If (is_rptParm2 <> "None") Then
	
	SetNull(ls_value)
	
	st_dt2.Text = is_rptParm2
	
	ldt_end = lstr_date_parm.str_dateValue2
	ls_value = String(ldt_end, "mm/dd/yyyy")
	
	em_rptdt2.Text = ls_value
	st_dt2.Visible = True
	em_rptdt2.Visible = True
End If

em_rptdt1.SetFocus()









end event

event ue_process;call super::ue_process;
//DateTime	ldt_start, ldt_end

String ls_startDt, ls_endDt

//ldt_start = DateTime(Date(em_rptdt1))

ls_startDt = em_rptdt1.Text

of_add_parm("fy_start", ls_startDt, "DateTime")

If (is_rptParm2 <> "None") Then
	
//	ldt_end   = DateTime(Date(em_rptdt2))
	
	ls_endDt = em_rptdt2.Text
	
	of_add_parm("fy_end", ls_endDt, "DateTime")
End If

//dw_1.Print()

Close(This)





















end event

type dw_1 from w_report_parms`dw_1 within w_date_parm
end type

type cb_cancel from w_report_parms`cb_cancel within w_date_parm
integer x = 1285
end type

type cb_ok from w_report_parms`cb_ok within w_date_parm
integer x = 887
boolean default = true
end type

type em_rptdt1 from editmask within w_date_parm
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
alignment alignment = center!
borderstyle borderstyle = stylelowered!
maskdatatype maskdatatype = datemask!
boolean dropdowncalendar = true
end type

type em_rptdt2 from editmask within w_date_parm
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
alignment alignment = center!
borderstyle borderstyle = stylelowered!
maskdatatype maskdatatype = datemask!
boolean dropdowncalendar = true
end type

type st_dt1 from statictext within w_date_parm
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
string text = "Date1"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_dt2 from statictext within w_date_parm
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
string text = "Date2"
alignment alignment = right!
boolean focusrectangle = false
end type

