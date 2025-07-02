forward
global type w_general_app_parms from w_report_parms
end type
type ddlb_program from dropdownlistbox within w_general_app_parms
end type
type ddlb_status from dropdownlistbox within w_general_app_parms
end type
type st_1 from statictext within w_general_app_parms
end type
type st_2 from statictext within w_general_app_parms
end type
type st_3 from statictext within w_general_app_parms
end type
type ddlb_county from dropdownlistbox within w_general_app_parms
end type
type ddlb_round from dropdownlistbox within w_general_app_parms
end type
type st_4 from statictext within w_general_app_parms
end type
end forward

global type w_general_app_parms from w_report_parms
integer width = 1303
integer height = 1132
ddlb_program ddlb_program
ddlb_status ddlb_status
st_1 st_1
st_2 st_2
st_3 st_3
ddlb_county ddlb_county
ddlb_round ddlb_round
st_4 st_4
end type
global w_general_app_parms w_general_app_parms

type variables

Datastore ids_statusParms, ids_cntyParms
end variables

on w_general_app_parms.create
int iCurrent
call super::create
this.ddlb_program=create ddlb_program
this.ddlb_status=create ddlb_status
this.st_1=create st_1
this.st_2=create st_2
this.st_3=create st_3
this.ddlb_county=create ddlb_county
this.ddlb_round=create ddlb_round
this.st_4=create st_4
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.ddlb_program
this.Control[iCurrent+2]=this.ddlb_status
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.st_2
this.Control[iCurrent+5]=this.st_3
this.Control[iCurrent+6]=this.ddlb_county
this.Control[iCurrent+7]=this.ddlb_round
this.Control[iCurrent+8]=this.st_4
end on

on w_general_app_parms.destroy
call super::destroy
destroy(this.ddlb_program)
destroy(this.ddlb_status)
destroy(this.st_1)
destroy(this.st_2)
destroy(this.st_3)
destroy(this.ddlb_county)
destroy(this.ddlb_round)
destroy(this.st_4)
end on

event ue_process;call super::ue_process;
String ls_value, ls_value2
Long ll_found

//*************************************************************
// Get SRF Program Parm:
//*************************************************************

SetNull(ls_value)

ls_value = ddlb_program.Text

of_add_parm("srf_progam",ls_value, "String")

//*************************************************************
// Get App. Status Parm:
//*************************************************************

SetNull(ls_value)
SetNull(ls_value2)

ls_value = ddlb_status.Text

If (ls_value = "ALL") Then
	
	ls_value2 = ls_value
	
Else	
	ll_found = ids_statusParms.Find("ref_value = '" + ls_value + "'", 1, ids_statusParms.RowCount())
	
	ls_value2 = ids_statusParms.GetItemString(ll_found, 'ref_code')	

End If

of_add_parm("app_status",ls_value2, "String")

//*************************************************************
// Get County Parm:
//*************************************************************

SetNull(ls_value)
SetNull(ls_value2)

ls_value = ddlb_county.Text


If (ls_value = "ALL") Then
	
	ls_value2 = ls_value
	
Else	
	ll_found = ids_cntyParms.Find("cf_fips = '" + ls_value + "'", 1, ids_cntyParms.RowCount())
	
	ls_value2 = ids_cntyParms.GetItemString(ll_found, 'ref_code')
	

End If

of_add_parm("county",ls_value2, "String")


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

event close;call super::close;
If IsValid(ids_statusParms) Then destroy ids_statusParms

If IsValid( ids_cntyParms) Then destroy  ids_cntyParms


end event

type dw_1 from w_report_parms`dw_1 within w_general_app_parms
integer y = 832
integer width = 434
integer height = 108
end type

type cb_cancel from w_report_parms`cb_cancel within w_general_app_parms
integer x = 910
integer y = 840
end type

type cb_ok from w_report_parms`cb_ok within w_general_app_parms
integer x = 512
integer y = 840
end type

type ddlb_program from dropdownlistbox within w_general_app_parms
integer x = 553
integer y = 72
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

type ddlb_status from dropdownlistbox within w_general_app_parms
integer x = 553
integer y = 224
integer width = 622
integer height = 600
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
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

event constructor;
Long ll_row, ll_cnt
String ls_value

ids_statusParms = CREATE Datastore

ids_statusParms.DataObject = 'dddw_appstatus'

ids_statusParms.SetTransObject(SQLCA)

ll_cnt = ids_statusParms.Retrieve()

ls_value = "ALL"

This.AddItem(ls_value)
 
This.Text = ls_value
  
FOR ll_row = 1 TO ll_cnt
	ls_value = ids_statusParms.GetItemString(ll_row, 'ref_value')
      This.AddItem(ls_value)
NEXT


end event

type st_1 from statictext within w_general_app_parms
integer x = 41
integer y = 64
integer width = 475
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

type st_2 from statictext within w_general_app_parms
integer x = 41
integer y = 224
integer width = 475
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
string text = "Application Status:"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_3 from statictext within w_general_app_parms
integer x = 41
integer y = 392
integer width = 475
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
string text = "County FIPS Code:"
alignment alignment = right!
boolean focusrectangle = false
end type

type ddlb_county from dropdownlistbox within w_general_app_parms
integer x = 553
integer y = 392
integer width = 622
integer height = 600
integer taborder = 30
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
Long ll_row, ll_cnt
String ls_value

ids_cntyParms = CREATE Datastore

ids_cntyParms.DataObject = 'dddw_fipscode'

ids_cntyParms.SetTransObject(SQLCA)

ll_cnt = ids_cntyParms.Retrieve()

ls_value = "ALL"

This.AddItem(ls_value)
 
This.Text = ls_value
  
FOR ll_row = 1 TO ll_cnt
	ls_value = ids_cntyParms.GetItemString(ll_row, 'cf_fips')
	
	If (IsNull(ls_value) Or Trim(ls_value) = "") Then
		//Skip
	Else		
      	This.AddItem(ls_value)
	End If
NEXT


end event

type ddlb_round from dropdownlistbox within w_general_app_parms
integer x = 553
integer y = 548
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
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

event constructor;Integer li_default, li_sort
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

type st_4 from statictext within w_general_app_parms
integer x = 41
integer y = 556
integer width = 475
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

