forward
global type w_grant_type_parms from w_report_parms
end type
type st_1 from statictext within w_grant_type_parms
end type
type dw_parm from u_dw within w_grant_type_parms
end type
end forward

global type w_grant_type_parms from w_report_parms
integer x = 214
integer y = 221
integer width = 1321
integer height = 696
st_1 st_1
dw_parm dw_parm
end type
global w_grant_type_parms w_grant_type_parms

on w_grant_type_parms.create
int iCurrent
call super::create
this.st_1=create st_1
this.dw_parm=create dw_parm
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
this.Control[iCurrent+2]=this.dw_parm
end on

on w_grant_type_parms.destroy
call super::destroy
destroy(this.st_1)
destroy(this.dw_parm)
end on

event ue_process;call super::ue_process;string ls_ref
long ll_row

ll_row = dw_parm.GetSelectedRow(0)

If ll_row > 0 Then
	
	ls_ref = dw_parm.GetItemString(ll_row, 'ref_code')
	
	of_add_parm("grant_type", ls_ref, "String")
	
End If

Close(This)
end event

type dw_1 from w_report_parms`dw_1 within w_grant_type_parms
integer y = 480
end type

type cb_cancel from w_report_parms`cb_cancel within w_grant_type_parms
integer x = 873
integer y = 476
end type

type cb_ok from w_report_parms`cb_ok within w_grant_type_parms
integer x = 475
integer y = 476
end type

type st_1 from statictext within w_grant_type_parms
integer x = 50
integer y = 24
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
string text = "Grant Type:"
boolean focusrectangle = false
end type

type dw_parm from u_dw within w_grant_type_parms
integer x = 425
integer y = 28
integer width = 827
integer height = 400
integer taborder = 10
boolean bringtotop = true
string dataobject = "dddw_granttype"
end type

event constructor;call super::constructor;
Long ll_rowCount, ll_row

this.of_SetRowSelect(TRUE)

This.of_SetTransObject(SQLCA)

This.ib_RMBMenu = False

ll_rowCount = This.Retrieve()

If (ll_rowCount < 1) Then Return

ll_row = This.InsertRow(0)

This.SetItem(ll_row,"ref_value", "[ALL]")
This.SetItem(ll_row,"ref_code", "-1")

This.SetItemStatus(ll_row, 0, Primary!, NotModified!)

This.SetSort('ref_code asc')

This.Sort()

This.SelectRow(0, False)
This.ScrollToRow(1)
This.SelectRow(1,True)
end event

event doubleclicked;call super::doubleclicked;is_action = "OK"

Parent.Event ue_process()
end event

