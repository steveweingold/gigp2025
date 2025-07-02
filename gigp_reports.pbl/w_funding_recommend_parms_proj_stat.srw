forward
global type w_funding_recommend_parms_proj_stat from w_report_parms
end type
type ddlb_fundingrec from dropdownlistbox within w_funding_recommend_parms_proj_stat
end type
type st_1 from statictext within w_funding_recommend_parms_proj_stat
end type
type ddlb_program from dropdownlistbox within w_funding_recommend_parms_proj_stat
end type
type st_2 from statictext within w_funding_recommend_parms_proj_stat
end type
type ddlb_status from dropdownlistbox within w_funding_recommend_parms_proj_stat
end type
type st_3 from statictext within w_funding_recommend_parms_proj_stat
end type
type st_4 from statictext within w_funding_recommend_parms_proj_stat
end type
type dw_round from u_dw_enhanced within w_funding_recommend_parms_proj_stat
end type
type st_multi from statictext within w_funding_recommend_parms_proj_stat
end type
type ddlb_projstatus from dropdownlistbox within w_funding_recommend_parms_proj_stat
end type
type st_5 from statictext within w_funding_recommend_parms_proj_stat
end type
end forward

global type w_funding_recommend_parms_proj_stat from w_report_parms
integer x = 214
integer y = 221
integer width = 1893
integer height = 1644
string title = "Select Project Parameters:"
ddlb_fundingrec ddlb_fundingrec
st_1 st_1
ddlb_program ddlb_program
st_2 st_2
ddlb_status ddlb_status
st_3 st_3
st_4 st_4
dw_round dw_round
st_multi st_multi
ddlb_projstatus ddlb_projstatus
st_5 st_5
end type
global w_funding_recommend_parms_proj_stat w_funding_recommend_parms_proj_stat

type variables

Datastore ids_recmndParms, ids_statusParms, ids_projStatusParms
boolean ib_multi = False
end variables

on w_funding_recommend_parms_proj_stat.create
int iCurrent
call super::create
this.ddlb_fundingrec=create ddlb_fundingrec
this.st_1=create st_1
this.ddlb_program=create ddlb_program
this.st_2=create st_2
this.ddlb_status=create ddlb_status
this.st_3=create st_3
this.st_4=create st_4
this.dw_round=create dw_round
this.st_multi=create st_multi
this.ddlb_projstatus=create ddlb_projstatus
this.st_5=create st_5
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.ddlb_fundingrec
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.ddlb_program
this.Control[iCurrent+4]=this.st_2
this.Control[iCurrent+5]=this.ddlb_status
this.Control[iCurrent+6]=this.st_3
this.Control[iCurrent+7]=this.st_4
this.Control[iCurrent+8]=this.dw_round
this.Control[iCurrent+9]=this.st_multi
this.Control[iCurrent+10]=this.ddlb_projstatus
this.Control[iCurrent+11]=this.st_5
end on

on w_funding_recommend_parms_proj_stat.destroy
call super::destroy
destroy(this.ddlb_fundingrec)
destroy(this.st_1)
destroy(this.ddlb_program)
destroy(this.st_2)
destroy(this.ddlb_status)
destroy(this.st_3)
destroy(this.st_4)
destroy(this.dw_round)
destroy(this.st_multi)
destroy(this.ddlb_projstatus)
destroy(this.st_5)
end on

event ue_process;call super::ue_process;String ls_value, ls_value2, ls_category
Long ll_found, ll_count, ll_row, ll_total
n_cst_string ln_string


//*************************************************************
// Get SRF Program Parm:
//*************************************************************

ls_value = ddlb_program.Text

of_add_parm("srf_progam",ls_value, "String")


//*************************************************************
// Get  Funding Recommendation Parm:
//*************************************************************

ls_value = Trim(ddlb_fundingrec.Text)

If (ls_value = "ALL") Then
	
	ls_value2 = ls_value
	
ElseIf (ls_value = "") Then
	SetNull(ls_value)
	ls_value2 = ls_value
Else	
	ll_found = ids_recmndParms.Find("ref_value = '" + ls_value + "'", 1, ids_recmndParms.RowCount())
	
	ls_category = ids_recmndParms.GetItemString(ll_found, 'category')	
		
	If (ls_category = "Funding Recommendation") Then
		ls_value2 = ids_recmndParms.GetItemString(ll_found, 'ref_code')			
	Else //Funding Recommendation 2 - Groupings		
		ls_value2 = ids_recmndParms.GetItemString(ll_found, 'description')
	End If

End If

of_add_parm("funding_rec",ls_value2, "String")


//*************************************************************
// Get App. Status Parm:
//*************************************************************

ls_value = ddlb_status.Text

If (ls_value = "ALL") Then
	
	ls_value2 = ls_value
	
Else	
	ll_found = ids_statusParms.Find("ref_value = '" + ls_value + "'", 1, ids_statusParms.RowCount())
	
	ls_value2 = ids_statusParms.GetItemString(ll_found, 'ref_code')	

End If

of_add_parm("app_status",ls_value2, "String")


//*************************************************************
// Get Round No. Parm:
//*************************************************************
If dw_round.GetSelectedRow(0) <= 0 Then
	dw_round.SelectRow(0, True)
End If

ll_count = dw_round.RowCount()
ll_total = 0
ls_value = ''

For ll_row = 1 to ll_count
	If dw_round.IsSelected(ll_row) Then
		ls_value += '|' + String(dw_round.GetItemNumber(ll_row, 'round_no')) + '|'
		ll_total++
		
	End If
	
Next

If ll_total = 1 Then	//single round, so omit the pipes
	ls_value = Trim(ln_string.of_globalreplace(ls_value, '|', ''))
End If

of_add_parm("round_no",ls_value, "String")


//*************************************************************
// Get Project Status Parm:
//*************************************************************

ls_value = ddlb_ProjStatus.Text

If (ls_value = "ALL") Then
	
	ls_value2 = ls_value
	
Else	
	ll_found = ids_projStatusParms.Find("ref_value = '" + ls_value + "'", 1, ids_projStatusParms.RowCount())
	
	ls_value2 = ids_projStatusParms.GetItemString(ll_found, 'ref_code')	

End If

of_add_parm("project_status",ls_value2, "String")


Close(This)
end event

event close;call super::close;
If IsValid(ids_recmndParms) Then Destroy ids_recmndParms
If IsValid(ids_statusParms) Then Destroy ids_statusParms
end event

event open;call super::open;string ls_parm

ls_parm = Message.StringParm

If ls_parm = 'MULTI' Then
	ib_multi = True
	st_multi.Text = '(Multiple Allowed)'
Else
	ib_multi = False
End If

If dw_round.RowCount() > 0 Then
	dw_round.SelectRow(1, True)
End If

end event

type dw_1 from w_report_parms`dw_1 within w_funding_recommend_parms_proj_stat
integer y = 1124
end type

type cb_cancel from w_report_parms`cb_cancel within w_funding_recommend_parms_proj_stat
integer x = 1499
integer y = 1440
end type

type cb_ok from w_report_parms`cb_ok within w_funding_recommend_parms_proj_stat
integer x = 1106
integer y = 1440
end type

type ddlb_fundingrec from dropdownlistbox within w_funding_recommend_parms_proj_stat
integer x = 37
integer y = 692
integer width = 1801
integer height = 704
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
boolean allowedit = true
boolean sorted = false
boolean showlist = true
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

event constructor;
Long ll_row, ll_cnt
Integer li_default
String ls_value, ls_default
Datastore lds_parms

//*************************************************************
//
//*************************************************************

ls_value = "ALL"

This.AddItem(ls_value)
 
This.Text = ls_value

//*************************************************************
//
//*************************************************************

lds_parms = CREATE Datastore

lds_parms.DataObject = 'dddw_funding_recommendation2'
lds_parms.SetTransObject(SQLCA)

ll_cnt = lds_parms.Retrieve()

FOR ll_row = 1 TO ll_cnt
	ls_value = lds_parms.GetItemString(ll_row, 'ref_value')
     This.AddItem(ls_value)
NEXT

//*************************************************************
//
//*************************************************************

ids_recmndParms = CREATE Datastore
ids_recmndParms.DataObject = 'dddw_funding_recommendation'
ids_recmndParms.SetTransObject(SQLCA)
ll_cnt = ids_recmndParms.Retrieve()

FOR ll_row = 1 TO ll_cnt
	ls_value = ids_recmndParms.GetItemString(ll_row, 'ref_value')
	li_default  = ids_recmndParms.GetItemNumber(ll_row, 'cat_default')
	
	If (ls_value <> "") Then
     	This.AddItem(ls_value)
		  
		If (li_default  = 1) Then
			ls_default = ls_value
		End If	  
		  
	End If
	
	SetNull(ls_value)
	li_default = 0
	
NEXT

This.SelectItem(ls_default, 0)

//*************************************************************
//
//*************************************************************

lds_parms.RowsMove(1, lds_parms.RowCount(), Primary!, ids_recmndParms, 1, Primary!)

//ids_recmndParms.Print()

If IsValid(lds_parms) Then destroy lds_parms




end event

type st_1 from statictext within w_funding_recommend_parms_proj_stat
integer x = 37
integer y = 612
integer width = 699
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
string text = "Funding Recommendation:"
boolean focusrectangle = false
end type

type ddlb_program from dropdownlistbox within w_funding_recommend_parms_proj_stat
integer x = 1253
integer y = 28
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

type st_2 from statictext within w_funding_recommend_parms_proj_stat
integer x = 869
integer y = 28
integer width = 361
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

type ddlb_status from dropdownlistbox within w_funding_recommend_parms_proj_stat
integer x = 1253
integer y = 188
integer width = 585
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

ids_statusParms = CREATE Datastore

ids_statusParms.DataObject = 'dddw_appstatus'

ids_statusParms.SetTransObject(SQLCA)

ll_cnt = ids_statusParms.Retrieve()

ls_value = "ALL"

This.AddItem(ls_value)
 
FOR ll_row = 1 TO ll_cnt
	ls_value = ids_statusParms.GetItemString(ll_row, 'ref_value')
      This.AddItem(ls_value)
NEXT

This.Text = "Eligible"
end event

type st_3 from statictext within w_funding_recommend_parms_proj_stat
integer x = 869
integer y = 188
integer width = 361
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
string text = "App Status:"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_4 from statictext within w_funding_recommend_parms_proj_stat
integer x = 37
integer y = 28
integer width = 283
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
boolean focusrectangle = false
end type

type dw_round from u_dw_enhanced within w_funding_recommend_parms_proj_stat
integer x = 137
integer y = 96
integer width = 489
integer height = 492
integer taborder = 30
boolean bringtotop = true
string dataobject = "d_round_no_list"
end type

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

type st_multi from statictext within w_funding_recommend_parms_proj_stat
integer x = 320
integer y = 28
integer width = 517
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
string text = "(Single Only)"
boolean focusrectangle = false
end type

type ddlb_projstatus from dropdownlistbox within w_funding_recommend_parms_proj_stat
integer x = 1253
integer y = 364
integer width = 585
integer height = 544
integer taborder = 40
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

event constructor;Long ll_row, ll_cnt
String ls_value

ids_projStatusParms = CREATE Datastore

ids_projStatusParms.DataObject = 'dddw_projstatus'

ids_projStatusParms.SetTransObject(SQLCA)

ll_cnt = ids_projStatusParms.Retrieve()

ls_value = "ALL"

This.AddItem(ls_value)
 
FOR ll_row = 1 TO ll_cnt
	ls_value = ids_projStatusParms.GetItemString(ll_row, 'ref_value')
      This.AddItem(ls_value)
NEXT

This.Text = "Active"
end event

type st_5 from statictext within w_funding_recommend_parms_proj_stat
integer x = 869
integer y = 368
integer width = 375
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
string text = "Project Status:"
alignment alignment = right!
boolean focusrectangle = false
end type

