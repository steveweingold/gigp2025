forward
global type w_select_program_round from w_report_parms
end type
type dw_round from u_dw_enhanced within w_select_program_round
end type
type shl_gigp from statichyperlink within w_select_program_round
end type
type shl_epg from statichyperlink within w_select_program_round
end type
type shl_ppg from statichyperlink within w_select_program_round
end type
type shl_redi from statichyperlink within w_select_program_round
end type
type cb_selectall from commandbutton within w_select_program_round
end type
type cb_deselectall from commandbutton within w_select_program_round
end type
type gb_rounds from groupbox within w_select_program_round
end type
end forward

global type w_select_program_round from w_report_parms
integer x = 214
integer y = 221
integer width = 1344
integer height = 1988
string title = "Select Program Round(s)"
dw_round dw_round
shl_gigp shl_gigp
shl_epg shl_epg
shl_ppg shl_ppg
shl_redi shl_redi
cb_selectall cb_selectall
cb_deselectall cb_deselectall
gb_rounds gb_rounds
end type
global w_select_program_round w_select_program_round

type variables

Datastore ids_recmndParms, ids_statusParms, ids_projStatusParms
boolean ib_multi = False
end variables

on w_select_program_round.create
int iCurrent
call super::create
this.dw_round=create dw_round
this.shl_gigp=create shl_gigp
this.shl_epg=create shl_epg
this.shl_ppg=create shl_ppg
this.shl_redi=create shl_redi
this.cb_selectall=create cb_selectall
this.cb_deselectall=create cb_deselectall
this.gb_rounds=create gb_rounds
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_round
this.Control[iCurrent+2]=this.shl_gigp
this.Control[iCurrent+3]=this.shl_epg
this.Control[iCurrent+4]=this.shl_ppg
this.Control[iCurrent+5]=this.shl_redi
this.Control[iCurrent+6]=this.cb_selectall
this.Control[iCurrent+7]=this.cb_deselectall
this.Control[iCurrent+8]=this.gb_rounds
end on

on w_select_program_round.destroy
call super::destroy
destroy(this.dw_round)
destroy(this.shl_gigp)
destroy(this.shl_epg)
destroy(this.shl_ppg)
destroy(this.shl_redi)
destroy(this.cb_selectall)
destroy(this.cb_deselectall)
destroy(this.gb_rounds)
end on

event ue_process;call super::ue_process;//String ls_value, ls_value2, ls_category, ls_program
//Long ll_found, ll_count, ll_row, ll_total
//n_cst_string ln_string
//
//
////*************************************************************
//// Get SRF Program Parm:
////*************************************************************
//
//ls_value = ddlb_program.Text
//
//of_add_parm("srf_progam",ls_value, "String")
//
//
////*************************************************************
//// Get  Funding Recommendation Parm:
////*************************************************************
//
//ls_value = Trim(ddlb_fundingrec.Text)
//
//If (ls_value = "ALL") Then
//	
//	ls_value2 = ls_value
//	
//ElseIf (ls_value = "") Then
//	SetNull(ls_value)
//	ls_value2 = ls_value
//Else	
//	ll_found = ids_recmndParms.Find("ref_value = '" + ls_value + "'", 1, ids_recmndParms.RowCount())
//	
//	ls_category = ids_recmndParms.GetItemString(ll_found, 'category')	
//		
//	If (ls_category = "Funding Recommendation") Then
//		ls_value2 = ids_recmndParms.GetItemString(ll_found, 'ref_code')			
//	Else //Funding Recommendation 2 - Groupings		
//		ls_value2 = ids_recmndParms.GetItemString(ll_found, 'description')
//	End If
//
//End If
//
//of_add_parm("funding_rec",ls_value2, "String")
//
//
////*************************************************************
//// Get App. Status Parm:
////*************************************************************
//
//ls_value = ddlb_status.Text
//
//If (ls_value = "ALL") Then
//	
//	ls_value2 = ls_value
//	
//Else	
//	ll_found = ids_statusParms.Find("ref_value = '" + ls_value + "'", 1, ids_statusParms.RowCount())
//	
//	ls_value2 = ids_statusParms.GetItemString(ll_found, 'ref_code')	
//
//End If
//
//of_add_parm("app_status",ls_value2, "String")
//
////*************************************************************
//// Get Round No. Parm:
////*************************************************************
//If dw_round.GetSelectedRow(0) <= 0 Then
//	dw_round.SelectRow(0, True)
//End If
//
//ll_count = dw_round.RowCount()
//ll_total = 0
//ls_value = ''
//
//For ll_row = 1 to ll_count
//	If dw_round.IsSelected(ll_row) Then
//		ls_value += '|' + String(dw_round.GetItemNumber(ll_row, 'round_no')) + '|'
//		ll_total++
//		
//	End If
//	
//Next
//
//If ll_total = 1 Then	//single round, so omit the pipes
//	ls_value = Trim(ln_string.of_globalreplace(ls_value, '|', ''))
//End If
//
//of_add_parm("round_no",ls_value, "String")
//
////*************************************************************
//// Get Program Parm:
////*************************************************************
//If rb_program_all.Checked Then
//	ls_program = 'ALL'
//ElseIf rb_program_gigp.Checked Then
//	ls_program = 'GIGP'
//ElseIf rb_program_epg.Checked Then
//	ls_program = 'EPG'
//ElseIf rb_program_ppg.Checked Then
//	ls_program = 'PPG-EC'
//Else
//	ls_program = ''
//End If
//
//of_add_parm("program",ls_program, "String")
//
//
////*************************************************************
//// Get Project Status Parm:
////*************************************************************
//ls_value = ddlb_ProjStatus.Text
//
//If (ls_value = "ALL") Then
//	ls_value2 = ls_value
//	
//Else	
//	ll_found = ids_projStatusParms.Find("ref_value = '" + ls_value + "'", 1, ids_projStatusParms.RowCount())
//	ls_value2 = ids_projStatusParms.GetItemString(ll_found, 'ref_code')	
//
//End If
//
//of_add_parm("project_status",ls_value2, "String")
//
//Close(This)
end event

event close;call super::close;
If IsValid(ids_recmndParms) Then Destroy ids_recmndParms
If IsValid(ids_statusParms) Then Destroy ids_statusParms
end event

event open;call super::open;string ls_parm

ls_parm = Message.StringParm

If ls_parm = 'MULTI' Then
	ib_multi = True
//	gb_rounds.Text += ' (Multiple Allowed)'
Else
	ib_multi = False
//	gb_rounds.Text += ' (Single Only)'
End If
end event

type dw_1 from w_report_parms`dw_1 within w_select_program_round
integer y = 1452
end type

type cb_cancel from w_report_parms`cb_cancel within w_select_program_round
integer x = 677
integer y = 1756
end type

type cb_ok from w_report_parms`cb_ok within w_select_program_round
integer x = 283
integer y = 1756
end type

type dw_round from u_dw_enhanced within w_select_program_round
event ue_select_program ( string as_program )
integer x = 105
integer y = 144
integer width = 672
integer height = 1504
integer taborder = 30
boolean bringtotop = true
string dataobject = "d_selectprogramround"
end type

event ue_select_program(string as_program);long ll_count, ll_row, ll_lastrow

this.SelectRow(0, False)
ll_lastrow = 1

ll_count = this.RowCount()

For ll_row = 1 to ll_count
	If this.GetItemString(ll_row, 'program') = as_program Then
		this.SelectRow(ll_row, True)
		ll_lastrow = ll_row
	End If
	
Next

this.ScrollToRow(ll_lastrow)
end event

event clicked;call super::clicked;If ib_multi Then
	If this.IsSelected(row) Then
		this.SelectRow(row, False)
	Else
		this.SelectRow(row, True)
	End If
Else
	this.SelectRow(0, False)
	this.SelectRow(row, True)
End If

end event

event constructor;call super::constructor;this.SetTransObject(SQLCA)

this.Retrieve()
end event

type shl_gigp from statichyperlink within w_select_program_round
integer x = 846
integer y = 148
integer width = 425
integer height = 56
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 134217856
long backcolor = 67108864
string text = "Select all GIGP"
boolean focusrectangle = false
end type

event clicked;dw_round.Event ue_select_program('GIGP')
end event

type shl_epg from statichyperlink within w_select_program_round
integer x = 846
integer y = 240
integer width = 425
integer height = 56
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 134217856
long backcolor = 67108864
string text = "Select all EPG"
boolean focusrectangle = false
end type

event clicked;dw_round.Event ue_select_program('EPG')
end event

type shl_ppg from statichyperlink within w_select_program_round
integer x = 846
integer y = 332
integer width = 425
integer height = 56
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 134217856
long backcolor = 67108864
string text = "Select all PPG-EC"
boolean focusrectangle = false
end type

event clicked;dw_round.Event ue_select_program('PPG-EC')
end event

type shl_redi from statichyperlink within w_select_program_round
integer x = 846
integer y = 424
integer width = 425
integer height = 56
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 134217856
long backcolor = 67108864
string text = "Select all REDI"
boolean focusrectangle = false
end type

event clicked;dw_round.Event ue_select_program('REDI')
end event

type cb_selectall from commandbutton within w_select_program_round
integer x = 850
integer y = 580
integer width = 343
integer height = 100
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Select All"
boolean flatstyle = true
end type

type cb_deselectall from commandbutton within w_select_program_round
integer x = 850
integer y = 712
integer width = 343
integer height = 100
integer taborder = 50
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Deselect All"
boolean flatstyle = true
end type

type gb_rounds from groupbox within w_select_program_round
integer x = 55
integer y = 52
integer width = 1225
integer height = 1648
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Select Round(s)"
end type

