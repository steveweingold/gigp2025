forward
global type w_funding_recommend_parms from w_report_parms
end type
type ddlb_fundingrec from dropdownlistbox within w_funding_recommend_parms
end type
type st_1 from statictext within w_funding_recommend_parms
end type
type ddlb_program from dropdownlistbox within w_funding_recommend_parms
end type
type st_2 from statictext within w_funding_recommend_parms
end type
type ddlb_status from dropdownlistbox within w_funding_recommend_parms
end type
type st_3 from statictext within w_funding_recommend_parms
end type
type st_4 from statictext within w_funding_recommend_parms
end type
type dw_round from u_dw_enhanced within w_funding_recommend_parms
end type
type st_multi from statictext within w_funding_recommend_parms
end type
type shl_gigp from statichyperlink within w_funding_recommend_parms
end type
type shl_epg from statichyperlink within w_funding_recommend_parms
end type
type shl_ppg from statichyperlink within w_funding_recommend_parms
end type
type rb_program_gigp from radiobutton within w_funding_recommend_parms
end type
type rb_program_epg from radiobutton within w_funding_recommend_parms
end type
type rb_program_ppg from radiobutton within w_funding_recommend_parms
end type
type rb_program_all from radiobutton within w_funding_recommend_parms
end type
type ddlb_projstatus from dropdownlistbox within w_funding_recommend_parms
end type
type st_5 from statictext within w_funding_recommend_parms
end type
type st_6 from statictext within w_funding_recommend_parms
end type
type rb_locked from radiobutton within w_funding_recommend_parms
end type
type rb_unlocked from radiobutton within w_funding_recommend_parms
end type
type rb_bothlockedandunlocked from radiobutton within w_funding_recommend_parms
end type
type gb_1 from groupbox within w_funding_recommend_parms
end type
type gb_2 from groupbox within w_funding_recommend_parms
end type
end forward

global type w_funding_recommend_parms from w_report_parms
integer width = 1893
integer height = 2252
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
shl_gigp shl_gigp
shl_epg shl_epg
shl_ppg shl_ppg
rb_program_gigp rb_program_gigp
rb_program_epg rb_program_epg
rb_program_ppg rb_program_ppg
rb_program_all rb_program_all
ddlb_projstatus ddlb_projstatus
st_5 st_5
st_6 st_6
rb_locked rb_locked
rb_unlocked rb_unlocked
rb_bothlockedandunlocked rb_bothlockedandunlocked
gb_1 gb_1
gb_2 gb_2
end type
global w_funding_recommend_parms w_funding_recommend_parms

type variables

Datastore ids_recmndParms, ids_statusParms, ids_projStatusParms
boolean ib_multi = False
end variables

on w_funding_recommend_parms.create
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
this.shl_gigp=create shl_gigp
this.shl_epg=create shl_epg
this.shl_ppg=create shl_ppg
this.rb_program_gigp=create rb_program_gigp
this.rb_program_epg=create rb_program_epg
this.rb_program_ppg=create rb_program_ppg
this.rb_program_all=create rb_program_all
this.ddlb_projstatus=create ddlb_projstatus
this.st_5=create st_5
this.st_6=create st_6
this.rb_locked=create rb_locked
this.rb_unlocked=create rb_unlocked
this.rb_bothlockedandunlocked=create rb_bothlockedandunlocked
this.gb_1=create gb_1
this.gb_2=create gb_2
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
this.Control[iCurrent+10]=this.shl_gigp
this.Control[iCurrent+11]=this.shl_epg
this.Control[iCurrent+12]=this.shl_ppg
this.Control[iCurrent+13]=this.rb_program_gigp
this.Control[iCurrent+14]=this.rb_program_epg
this.Control[iCurrent+15]=this.rb_program_ppg
this.Control[iCurrent+16]=this.rb_program_all
this.Control[iCurrent+17]=this.ddlb_projstatus
this.Control[iCurrent+18]=this.st_5
this.Control[iCurrent+19]=this.st_6
this.Control[iCurrent+20]=this.rb_locked
this.Control[iCurrent+21]=this.rb_unlocked
this.Control[iCurrent+22]=this.rb_bothlockedandunlocked
this.Control[iCurrent+23]=this.gb_1
this.Control[iCurrent+24]=this.gb_2
end on

on w_funding_recommend_parms.destroy
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
destroy(this.shl_gigp)
destroy(this.shl_epg)
destroy(this.shl_ppg)
destroy(this.rb_program_gigp)
destroy(this.rb_program_epg)
destroy(this.rb_program_ppg)
destroy(this.rb_program_all)
destroy(this.ddlb_projstatus)
destroy(this.st_5)
destroy(this.st_6)
destroy(this.rb_locked)
destroy(this.rb_unlocked)
destroy(this.rb_bothlockedandunlocked)
destroy(this.gb_1)
destroy(this.gb_2)
end on

event ue_process;call super::ue_process;String ls_value, ls_value2, ls_category, ls_program
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
// Get Program Parm:
//*************************************************************
If rb_program_all.Checked Then
	ls_program = 'ALL'
ElseIf rb_program_gigp.Checked Then
	ls_program = 'GIGP'
ElseIf rb_program_epg.Checked Then
	ls_program = 'EPG'
ElseIf rb_program_ppg.Checked Then
	ls_program = 'PPG-EC'
Else
	ls_program = ''
End If

of_add_parm("program",ls_program, "String")


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

of_add_parm("project_status_cd",ls_value2, "String")


//*************************************************************
// Get Locked Parm:
//*************************************************************
If rb_locked.Checked Then
	ls_value = '1'
ElseIf rb_unlocked.Checked Then
	ls_value = '0'
Else
	ls_value = ''
End If

of_add_parm("locked",ls_value, "Number")



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

//If dw_round.RowCount() > 0 Then
//	dw_round.SelectRow(1, True)
//End If

end event

type dw_1 from w_report_parms`dw_1 within w_funding_recommend_parms
integer y = 1728
end type

type cb_cancel from w_report_parms`cb_cancel within w_funding_recommend_parms
integer x = 1499
integer y = 2028
end type

type cb_ok from w_report_parms`cb_ok within w_funding_recommend_parms
integer x = 1106
integer y = 2028
end type

type ddlb_fundingrec from dropdownlistbox within w_funding_recommend_parms
integer x = 37
integer y = 1296
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

type st_1 from statictext within w_funding_recommend_parms
integer x = 37
integer y = 1216
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

type ddlb_program from dropdownlistbox within w_funding_recommend_parms
integer x = 1253
integer y = 120
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

type st_2 from statictext within w_funding_recommend_parms
integer x = 869
integer y = 120
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

type ddlb_status from dropdownlistbox within w_funding_recommend_parms
integer x = 1253
integer y = 280
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

type st_3 from statictext within w_funding_recommend_parms
integer x = 869
integer y = 280
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

type st_4 from statictext within w_funding_recommend_parms
integer x = 37
integer y = 120
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

type dw_round from u_dw_enhanced within w_funding_recommend_parms
event ue_select_program ( string as_program )
integer x = 55
integer y = 188
integer width = 521
integer height = 696
integer taborder = 30
boolean bringtotop = true
string dataobject = "d_round_no_list"
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

type st_multi from statictext within w_funding_recommend_parms
integer x = 320
integer y = 120
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

type shl_gigp from statichyperlink within w_funding_recommend_parms
integer x = 585
integer y = 632
integer width = 512
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
string text = "Select all GIGP Rounds"
boolean focusrectangle = false
end type

event clicked;dw_round.Event ue_select_program('GIGP')
end event

type shl_epg from statichyperlink within w_funding_recommend_parms
integer x = 585
integer y = 724
integer width = 494
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
string text = "Select all EPG Rounds"
boolean focusrectangle = false
end type

event clicked;dw_round.Event ue_select_program('EPG')
end event

type shl_ppg from statichyperlink within w_funding_recommend_parms
integer x = 585
integer y = 816
integer width = 571
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
string text = "Select all PPG-EC Rounds"
boolean focusrectangle = false
end type

event clicked;dw_round.Event ue_select_program('PPG-EC')
end event

type rb_program_gigp from radiobutton within w_funding_recommend_parms
integer x = 1413
integer y = 748
integer width = 283
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "GIGP"
end type

type rb_program_epg from radiobutton within w_funding_recommend_parms
integer x = 1413
integer y = 820
integer width = 283
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "EPG"
end type

type rb_program_ppg from radiobutton within w_funding_recommend_parms
integer x = 1413
integer y = 892
integer width = 283
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "PPG-EC"
end type

type rb_program_all from radiobutton within w_funding_recommend_parms
integer x = 1413
integer y = 676
integer width = 283
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "All"
boolean checked = true
end type

type ddlb_projstatus from dropdownlistbox within w_funding_recommend_parms
integer x = 1253
integer y = 444
integer width = 585
integer height = 544
integer taborder = 50
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

//This.Text = "Active"
This.Text = "ALL"
end event

type st_5 from statictext within w_funding_recommend_parms
integer x = 869
integer y = 448
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

type st_6 from statictext within w_funding_recommend_parms
integer x = 9
integer y = 8
integer width = 1842
integer height = 68
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 12639424
string text = "Note: Not all choices work with every report"
alignment alignment = center!
boolean border = true
boolean focusrectangle = false
end type

type rb_locked from radiobutton within w_funding_recommend_parms
integer x = 119
integer y = 1060
integer width = 343
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Locked"
end type

type rb_unlocked from radiobutton within w_funding_recommend_parms
integer x = 530
integer y = 1060
integer width = 343
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Unlocked"
end type

type rb_bothlockedandunlocked from radiobutton within w_funding_recommend_parms
integer x = 1015
integer y = 1060
integer width = 215
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Both"
boolean checked = true
end type

type gb_1 from groupbox within w_funding_recommend_parms
integer x = 1257
integer y = 612
integer width = 567
integer height = 372
integer taborder = 40
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Program"
end type

type gb_2 from groupbox within w_funding_recommend_parms
integer x = 37
integer y = 984
integer width = 1801
integer height = 188
integer taborder = 50
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Locked"
end type

