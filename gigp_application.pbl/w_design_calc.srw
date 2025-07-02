forward
global type w_design_calc from w_gigp_response
end type
type gb_3 from groupbox within w_design_calc
end type
type cb_1 from commandbutton within w_design_calc
end type
type cb_delete_practice from commandbutton within w_design_calc
end type
type dw_practices from u_dw_enhanced within w_design_calc
end type
type dw_metrics from u_dw_enhanced within w_design_calc
end type
type dw_choose_practice from u_dw_enhanced within w_design_calc
end type
type cb_save from commandbutton within w_design_calc
end type
type st_1 from statictext within w_design_calc
end type
type st_benefit from statictext within w_design_calc
end type
type gb_2 from groupbox within w_design_calc
end type
type gb_4 from groupbox within w_design_calc
end type
type gb_1 from groupbox within w_design_calc
end type
end forward

global type w_design_calc from w_gigp_response
integer width = 4745
integer height = 2512
string title = "Design Calcs"
gb_3 gb_3
cb_1 cb_1
cb_delete_practice cb_delete_practice
dw_practices dw_practices
dw_metrics dw_metrics
dw_choose_practice dw_choose_practice
cb_save cb_save
st_1 st_1
st_benefit st_benefit
gb_2 gb_2
gb_4 gb_4
gb_1 gb_1
end type
global w_design_calc w_design_calc

forward prototypes
public function integer of_calculate_benefit ()
end prototypes

public function integer of_calculate_benefit ();string ls_value
long ll_row, ll_id

ll_row = dw_practices.GetRow()

If ll_row > 0 Then
	ll_id = dw_practices.GetItemNumber(ll_row, 'design_calc_id')

	//Calculate
	ls_value = f_get_project_benefit(ll_id)
	
Else
	ls_value = '[Choose Practice]'
	
End If

st_benefit.Text = ls_value

Return 1
end function

on w_design_calc.create
int iCurrent
call super::create
this.gb_3=create gb_3
this.cb_1=create cb_1
this.cb_delete_practice=create cb_delete_practice
this.dw_practices=create dw_practices
this.dw_metrics=create dw_metrics
this.dw_choose_practice=create dw_choose_practice
this.cb_save=create cb_save
this.st_1=create st_1
this.st_benefit=create st_benefit
this.gb_2=create gb_2
this.gb_4=create gb_4
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.gb_3
this.Control[iCurrent+2]=this.cb_1
this.Control[iCurrent+3]=this.cb_delete_practice
this.Control[iCurrent+4]=this.dw_practices
this.Control[iCurrent+5]=this.dw_metrics
this.Control[iCurrent+6]=this.dw_choose_practice
this.Control[iCurrent+7]=this.cb_save
this.Control[iCurrent+8]=this.st_1
this.Control[iCurrent+9]=this.st_benefit
this.Control[iCurrent+10]=this.gb_2
this.Control[iCurrent+11]=this.gb_4
this.Control[iCurrent+12]=this.gb_1
end on

on w_design_calc.destroy
call super::destroy
destroy(this.gb_3)
destroy(this.cb_1)
destroy(this.cb_delete_practice)
destroy(this.dw_practices)
destroy(this.dw_metrics)
destroy(this.dw_choose_practice)
destroy(this.cb_save)
destroy(this.st_1)
destroy(this.st_benefit)
destroy(this.gb_2)
destroy(this.gb_4)
destroy(this.gb_1)
end on

event pfc_postopen;call super::pfc_postopen;dw_practices.Event pfc_retrieve()
end event

event ue_process;call super::ue_process;dw_choose_practice.ResetUpdate()
this.Event pfc_save()
this.of_calculate_benefit()
end event

type cb_cancel from w_gigp_response`cb_cancel within w_design_calc
integer x = 4265
integer y = 2240
end type

type cb_ok from w_gigp_response`cb_ok within w_design_calc
integer x = 3470
integer y = 2240
end type

type gb_3 from groupbox within w_design_calc
integer x = 82
integer y = 1956
integer width = 1600
integer height = 192
integer taborder = 40
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Add New Practice"
end type

type cb_1 from commandbutton within w_design_calc
integer x = 1541
integer y = 2020
integer width = 105
integer height = 100
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "+"
end type

event clicked;string ls_practice

ls_practice = dw_choose_practice.GetItemString(1, 'practice')

If ls_practice > '' Then
	dw_practices.Event ue_add_practice(ls_practice)
End If
end event

type cb_delete_practice from commandbutton within w_design_calc
integer x = 1815
integer y = 2024
integer width = 293
integer height = 96
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Delete"
end type

event clicked;long ll_design_calc_id

If dw_practices.GetRow() <= 0 Then
	MessageBox('Delete Practice', 'Please select a Practice to delete.')
	Return
End If

If MessageBox('Delete Practice', 'Are you sure you want to delete the selected Practice?', Question!, YesNoCancel!) = 1 Then
	ll_design_calc_id = dw_practices.GetItemNumber(dw_practices.GetRow(), 'design_calc_id')
	
	If ll_design_calc_id > 0 Then
		delete gigp_project_metrics
		where design_calc_id = :ll_design_calc_id;
		
		delete gigp_design_calcs
		where design_calc_id = :ll_design_calc_id;
		
		dw_metrics.Reset()
		dw_practices.Event pfc_retrieve()
	End If

End If
end event

type dw_practices from u_dw_enhanced within w_design_calc
event ue_add_practice ( string as_practice )
integer x = 59
integer y = 116
integer width = 2130
integer height = 1816
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_design_calc_practices"
boolean border = false
borderstyle borderstyle = stylebox!
end type

event ue_add_practice(string as_practice);string ls_practice_type, ls_user, ls_practice_no
integer li_practice_no
long ll_design_calc_id

select sub_category
into :ls_practice_type
from gigp_reference
where category = 'DesignCalcPractice'
and ref_code = :as_practice;

select max(practice_no)
into :li_practice_no
from gigp_design_calcs
where gigp_id = :gl_gigp_Id;

If IsNull(li_practice_no) or li_practice_no <= 0 Then
	li_practice_no = 1
Else
	li_practice_no++
End If

ls_practice_no = String(li_practice_no)

ll_design_calc_id = f_gettokenvalue('design_calc_id', 1)
ls_user = gnv_app.of_getuserid()

//Insert Practice
insert into gigp_design_calcs (design_calc_id, gigp_id, practice_no, practice_type, comments, last_updated_by, last_updated_dt)
values (:ll_design_calc_id, :gl_gigp_id, :li_practice_no, :as_practice, null, :ls_user, getdate());


//Insert Practice Metrics
insert into gigp_project_metrics (gigp_id, category, sub_category, ref_code, metric_value, last_updated_by, last_updated_dt, design_calc_id, metric_source)
select :gl_gigp_id, category, :ls_practice_no, ref_code, null, :ls_user, getdate(), :ll_design_calc_id, 'APP'
from gigp_reference
where category = 'DesignCalcMetric'
and sub_category = :ls_practice_type;

this.Retrieve(gl_gigp_id)
this.ScrollToRow(this.RowCount())
this.SelectRow(this.RowCount(), True)
dw_choose_practice.ResetUpdate()

parent.Post of_calculate_benefit()
end event

event constructor;call super::constructor;
//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************
This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)

is_accessGroups = {"TAS-Global", "DesignCalc"}

this.SetTransObject(SQLCA)

end event

event pfc_retrieve;call super::pfc_retrieve;long ll_ret, ll_id

ll_ret = this.Retrieve(gl_gigp_id)

If ll_ret > 0 Then
	this.ScrollToRow(1)
	this.SelectRow(1,True)
	ll_id = this.GetItemNumber(1, 'design_calc_id')
	If ll_id > 0 Then
		dw_metrics.Retrieve(ll_id)
	End If
End If

parent.Post of_calculate_benefit()

Return ll_ret
end event

event rowfocuschanged;call super::rowfocuschanged;long ll_id

If currentrow > 0 Then
	ll_id = this.GetItemNumber(currentrow, 'design_calc_id')
	If ll_id > 0 Then
		dw_metrics.Retrieve(ll_id)
	End If
End If

parent.Post of_calculate_benefit()
end event

event rowfocuschanging;call super::rowfocuschanging;integer li_ret

If dw_metrics.GetNextModified(0,Primary!) > 0 Then
	If MessageBox('Pending Metric Changes', 'There are pending metric changes to the current Practice.~r~nSave Changes?', Question!, YesNo!) = 1 Then
		dw_choose_practice.ResetUpdate()
		parent.Event pfc_save()
	End If
	
End If

end event

event buttonclicked;call super::buttonclicked;string ls_Text
integer li_RC

If dwo.name = 'b_comments' Then
	ls_Text = This.GetItemString(row, "comments")	
	
	li_RC = f_edit_notes("EDIT", ls_Text)	
	
	If (li_RC = 1) Then This.SetItem(row, "comments", ls_Text)	
	
End If
end event

event rbuttondown;//Override
end event

event rbuttonup;//Override
end event

type dw_metrics from u_dw_enhanced within w_design_calc
integer x = 2304
integer y = 116
integer width = 2359
integer height = 1816
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_design_calc_metrics"
end type

event constructor;call super::constructor;this.SetTransObject(SQLCA)
end event

event rbuttondown;//Override
end event

event rbuttonup;//Override
end event

type dw_choose_practice from u_dw_enhanced within w_design_calc
integer x = 128
integer y = 2024
integer width = 1399
integer height = 100
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_design_calc_choose_practice"
boolean vscrollbar = false
boolean border = false
end type

event constructor;call super::constructor;this.SetTransObject(SQLCA)
this.InsertRow(0)
end event

type cb_save from commandbutton within w_design_calc
integer x = 3867
integer y = 2240
integer width = 343
integer height = 100
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Save"
end type

event clicked;parent.Event ue_process()
end event

type st_1 from statictext within w_design_calc
integer x = 2286
integer y = 2196
integer width = 1125
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
string text = "*To update the benefit value, [Save] changes"
boolean focusrectangle = false
end type

type st_benefit from statictext within w_design_calc
integer x = 2944
integer y = 2044
integer width = 1083
integer height = 76
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
alignment alignment = center!
boolean focusrectangle = false
end type

type gb_2 from groupbox within w_design_calc
integer x = 37
integer y = 4
integer width = 2185
integer height = 2176
integer taborder = 30
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Practices"
end type

type gb_4 from groupbox within w_design_calc
integer x = 2857
integer y = 1956
integer width = 1253
integer height = 192
integer taborder = 50
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Practice Benefits*"
end type

type gb_1 from groupbox within w_design_calc
integer x = 2254
integer y = 4
integer width = 2455
integer height = 2176
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Metric Values"
end type

