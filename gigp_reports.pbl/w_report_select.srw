forward
global type w_report_select from w_report_parms
end type
type dw_reports from u_dw within w_report_select
end type
type pb_expand from picturebutton within w_report_select
end type
end forward

global type w_report_select from w_report_parms
integer x = 214
integer y = 221
integer width = 3227
integer height = 2176
windowanimationstyle openanimation = centeranimation!
windowanimationstyle closeanimation = centeranimation!
dw_reports dw_reports
pb_expand pb_expand
end type
global w_report_select w_report_select

on w_report_select.create
int iCurrent
call super::create
this.dw_reports=create dw_reports
this.pb_expand=create pb_expand
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_reports
this.Control[iCurrent+2]=this.pb_expand
end on

on w_report_select.destroy
call super::destroy
destroy(this.dw_reports)
destroy(this.pb_expand)
end on

event ue_process;call super::ue_process;Long 		ll_row, ll_id
String	ls_value

ll_row = dw_reports.GetRow()

ls_value = dw_reports.GetItemString(ll_row, "report_name")

of_add_parm("ReportName", ls_value, "String")

ls_value = ""

ls_value = dw_reports.GetItemString(ll_row, "data_object")

// Check SRF Web switch for d_epg_program_summary.
if ls_Value = "d_epg_program_summary" and gb_UseFinSchemaTables then
	ls_Value = "d_epg_program_summary_srf_web"
end if

of_add_parm("DataObject", ls_value, "String")

ls_value = ""

ls_value = dw_reports.GetItemString(ll_row, "report_object")

of_add_parm("ReportObject", ls_value, "String")

ls_value = ""

ls_value = dw_reports.GetItemString(ll_row, "category")

of_add_parm("ReportCategory", ls_value, "String")

ls_value = ""
ls_value = dw_reports.GetItemString(ll_row, 'extract')
of_add_parm('Extract', ls_value, 'String')

//Increment the count
ll_id = dw_reports.GetItemNumber(ll_row, 'report_id')

If ll_id > 0 Then
	update gigp_reports
	set run_count = run_count + 1,
		last_run_date = getdate()
	where report_id = :ll_id;
End If

Close(This)
end event

event closequery;
//OverRide//
end event

event open;call super::open;
dw_reports.SetFocus()
end event

type dw_1 from w_report_parms`dw_1 within w_report_select
integer y = 1936
end type

type cb_cancel from w_report_parms`cb_cancel within w_report_select
integer x = 2839
integer y = 1936
end type

type cb_ok from w_report_parms`cb_ok within w_report_select
integer x = 2441
integer y = 1936
end type

type dw_reports from u_dw within w_report_select
integer x = 27
integer y = 32
integer width = 3150
integer height = 1868
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_app_reports"
end type

event constructor;call super::constructor;
This.ib_RMBMenu = False

This.SetTransObject(SQLCA)

//*******************************************************
// Start PFC Row Selection Service:
//*******************************************************
This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)

This.Retrieve()


end event

event doubleclicked;call super::doubleclicked;
cb_ok.Event Clicked()
end event

type pb_expand from picturebutton within w_report_select
integer x = 37
integer y = 40
integer width = 110
integer height = 96
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean originalsize = true
string picturename = "computesum!"
alignment htextalign = left!
string powertiptext = "Collapse All"
end type

event clicked;
If  (This.PowerTipText = "Expand All") Then
	dw_reports.ExpandAll( )
	This.PowerTipText = "Collapse All"
Else
	dw_reports.CollapseAll( )
	This.PowerTipText = "Expand All"
End If

end event

