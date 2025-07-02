forward
global type w_legislator_app_parms from w_report_parms
end type
type ddlb_program from dropdownlistbox within w_legislator_app_parms
end type
type st_1 from statictext within w_legislator_app_parms
end type
type ddlb_round from dropdownlistbox within w_legislator_app_parms
end type
type st_4 from statictext within w_legislator_app_parms
end type
type st_2 from statictext within w_legislator_app_parms
end type
type ddlb_legislator from dropdownlistbox within w_legislator_app_parms
end type
end forward

global type w_legislator_app_parms from w_report_parms
integer width = 1883
integer height = 768
ddlb_program ddlb_program
st_1 st_1
ddlb_round ddlb_round
st_4 st_4
st_2 st_2
ddlb_legislator ddlb_legislator
end type
global w_legislator_app_parms w_legislator_app_parms

type variables

Datastore ids_legislators
end variables

on w_legislator_app_parms.create
int iCurrent
call super::create
this.ddlb_program=create ddlb_program
this.st_1=create st_1
this.ddlb_round=create ddlb_round
this.st_4=create st_4
this.st_2=create st_2
this.ddlb_legislator=create ddlb_legislator
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.ddlb_program
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.ddlb_round
this.Control[iCurrent+4]=this.st_4
this.Control[iCurrent+5]=this.st_2
this.Control[iCurrent+6]=this.ddlb_legislator
end on

on w_legislator_app_parms.destroy
call super::destroy
destroy(this.ddlb_program)
destroy(this.st_1)
destroy(this.ddlb_round)
destroy(this.st_4)
destroy(this.st_2)
destroy(this.ddlb_legislator)
end on

event ue_process;call super::ue_process;String ls_value, ls_value2
Long ll_found

//*************************************************************
// Get Legislator:
//*************************************************************
SetNull(ls_value)
SetNull(ls_value2)

ls_value = ddlb_legislator.Text

ll_found = ids_legislators.Find("cc_display = '" + ls_value + "'", 1, ids_legislators.RowCount())

If ll_found > 0 Then
	ls_value2 = String(ids_legislators.GetItemNumber(ll_found, 'contact_id'))
End If
	
of_add_parm("legislator", ls_value2, "Number")

//*************************************************************
// Get SRF Program Parm:
//*************************************************************
SetNull(ls_value)

ls_value = ddlb_program.Text

of_add_parm("srf_progam",ls_value, "String")


//*************************************************************
// Get Round No. Parm:
//*************************************************************
SetNull(ls_value)

ls_value = ddlb_round.Text

of_add_parm("round_no",ls_value, "String")


Close(This)

end event

event close;call super::close;
If IsValid(ids_legislators) Then destroy ids_legislators


end event

type dw_1 from w_report_parms`dw_1 within w_legislator_app_parms
integer x = 329
integer y = 528
integer width = 434
integer height = 108
end type

type cb_cancel from w_report_parms`cb_cancel within w_legislator_app_parms
integer x = 1454
integer y = 536
end type

type cb_ok from w_report_parms`cb_ok within w_legislator_app_parms
integer x = 1056
integer y = 536
end type

type ddlb_program from dropdownlistbox within w_legislator_app_parms
integer x = 453
integer y = 200
integer width = 384
integer height = 352
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

event constructor;
Long ll_row, ll_cnt
String ls_value

Datastore lds_parms

lds_parms = CREATE Datastore

lds_parms.DataObject = 'dddw_srftype'

lds_parms.SetTransObject(SQLCA)

ls_value = "ALL"

This.AddItem(ls_value)
 
This.Text = ls_value

ll_cnt = lds_parms.Retrieve()

FOR ll_row = 1 TO ll_cnt
	ls_value = lds_parms.GetItemString(ll_row, 'ref_code')
      This.AddItem(ls_value)
NEXT

Destroy lds_parms

end event

type st_1 from statictext within w_legislator_app_parms
integer x = 41
integer y = 192
integer width = 398
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
string text = "SRF Program:"
alignment alignment = right!
boolean focusrectangle = false
end type

type ddlb_round from dropdownlistbox within w_legislator_app_parms
integer x = 453
integer y = 336
integer width = 384
integer height = 352
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean sorted = false
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

type st_4 from statictext within w_legislator_app_parms
integer x = 41
integer y = 344
integer width = 398
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

type st_2 from statictext within w_legislator_app_parms
integer x = 41
integer y = 68
integer width = 398
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
string text = "Legislator:"
alignment alignment = right!
boolean focusrectangle = false
end type

type ddlb_legislator from dropdownlistbox within w_legislator_app_parms
integer x = 453
integer y = 68
integer width = 1353
integer height = 592
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

event constructor;Long ll_row, ll_cnt
String ls_value

ids_legislators = CREATE Datastore

ids_legislators.DataObject = 'dddw_legislators'

ids_legislators.SetTransObject(SQLCA)

ll_cnt = ids_legislators.Retrieve()

FOR ll_row = 1 TO ll_cnt
	ls_value = ids_legislators.GetItemString(ll_row, 'cc_display')
	
	If (IsNull(ls_value) Or Trim(ls_value) = "") Then
		//Skip
	Else		
      	This.AddItem(ls_value)
	End If
NEXT

ls_value = ids_legislators.GetItemString(1, 'cc_display')

This.Text = ls_value
end event

