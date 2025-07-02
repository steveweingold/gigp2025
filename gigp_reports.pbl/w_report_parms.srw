forward
global type w_report_parms from w_response
end type
type dw_1 from u_dw within w_report_parms
end type
type cb_cancel from commandbutton within w_report_parms
end type
type cb_ok from commandbutton within w_report_parms
end type
end forward

global type w_report_parms from w_response
integer width = 1979
integer height = 776
string title = "Report Parameters"
boolean center = true
event ue_process ( )
dw_1 dw_1
cb_cancel cb_cancel
cb_ok cb_ok
end type
global w_report_parms w_report_parms

type variables

String is_action = "CANCEL"


end variables

forward prototypes
public subroutine of_add_parm (string as_parmname, string as_parmvalue, string as_datatype)
end prototypes

event ue_process();
//*******************************************************
// Process parm selection and Close in the descendant:
//*******************************************************
end event

public subroutine of_add_parm (string as_parmname, string as_parmvalue, string as_datatype);
Long ll_row

ll_row = dw_1.InsertRow(0)

dw_1.SetItem(ll_row, "prm_name", as_parmname)
dw_1.SetItem(ll_row, "prm_value", as_parmvalue)
dw_1.SetItem(ll_row, "data_type", as_datatype)

end subroutine

on w_report_parms.create
int iCurrent
call super::create
this.dw_1=create dw_1
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
this.Control[iCurrent+2]=this.cb_cancel
this.Control[iCurrent+3]=this.cb_ok
end on

on w_report_parms.destroy
call super::destroy
destroy(this.dw_1)
destroy(this.cb_cancel)
destroy(this.cb_ok)
end on

event close;call super::close;
//OverRide//

Blob lblb_data
Long ll_RC
str_report_parm lstr_parm

If (is_action = "CANCEL") Then
	of_add_parm("CANCEL", "CANCEL", "CANCEL")
End If

//dw_1.print()

ll_RC = dw_1.GetFullstate(lblb_data)

lstr_parm.str_parm = lblb_data

CloseWithReturn(This, lstr_parm)
end event

event closequery;
//OverRide//
end event

type dw_1 from u_dw within w_report_parms
boolean visible = false
integer x = 37
integer y = 548
integer width = 407
integer height = 96
integer taborder = 10
boolean titlebar = true
string title = "Report Parms"
string dataobject = "d_report_parms"
end type

type cb_cancel from commandbutton within w_report_parms
integer x = 1600
integer y = 544
integer width = 343
integer height = 100
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Cancel"
end type

event clicked;
is_action = "CANCEL"

Close(Parent)
end event

type cb_ok from commandbutton within w_report_parms
integer x = 1202
integer y = 544
integer width = 343
integer height = 100
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "OK"
end type

event clicked;
is_action = "OK"

Parent.Event ue_process()


end event

