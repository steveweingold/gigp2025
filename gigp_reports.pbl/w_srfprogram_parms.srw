forward
global type w_srfprogram_parms from w_report_parms
end type
type ddlb_program from dropdownlistbox within w_srfprogram_parms
end type
type st_1 from statictext within w_srfprogram_parms
end type
end forward

global type w_srfprogram_parms from w_report_parms
integer x = 214
integer y = 221
integer width = 1303
integer height = 656
ddlb_program ddlb_program
st_1 st_1
end type
global w_srfprogram_parms w_srfprogram_parms

type variables

Datastore ids_statusParms, ids_cntyParms
end variables

on w_srfprogram_parms.create
int iCurrent
call super::create
this.ddlb_program=create ddlb_program
this.st_1=create st_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.ddlb_program
this.Control[iCurrent+2]=this.st_1
end on

on w_srfprogram_parms.destroy
call super::destroy
destroy(this.ddlb_program)
destroy(this.st_1)
end on

event ue_process;call super::ue_process;
String ls_value, ls_value2
Long ll_found

//*************************************************************
// Get SRF Program Parm:
//*************************************************************

ls_value = ddlb_program.Text

of_add_parm("srf_progam",ls_value, "String")

//dw_1.Print()

Close(This)
end event

event close;call super::close;
If IsValid(ids_statusParms) Then destroy ids_statusParms

If IsValid( ids_cntyParms) Then destroy  ids_cntyParms


end event

type dw_1 from w_report_parms`dw_1 within w_srfprogram_parms
integer y = 316
integer width = 608
integer height = 108
end type

type cb_cancel from w_report_parms`cb_cancel within w_srfprogram_parms
integer x = 910
integer y = 440
end type

type cb_ok from w_report_parms`cb_ok within w_srfprogram_parms
integer x = 512
integer y = 440
end type

type ddlb_program from dropdownlistbox within w_srfprogram_parms
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

type st_1 from statictext within w_srfprogram_parms
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

