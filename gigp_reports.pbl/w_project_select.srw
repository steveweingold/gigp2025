forward
global type w_project_select from w_report_parms
end type
type dw_parm from u_dw within w_project_select
end type
type pb_selectall from picturebutton within w_project_select
end type
type pb_deselectall from picturebutton within w_project_select
end type
type cb_filter from commandbutton within w_project_select
end type
type cb_goto from commandbutton within w_project_select
end type
type sle_goto from singlelineedit within w_project_select
end type
end forward

global type w_project_select from w_report_parms
integer x = 214
integer y = 221
integer width = 3744
integer height = 1488
dw_parm dw_parm
pb_selectall pb_selectall
pb_deselectall pb_deselectall
cb_filter cb_filter
cb_goto cb_goto
sle_goto sle_goto
end type
global w_project_select w_project_select

type variables

Datastore ids_recmndParms
end variables

on w_project_select.create
int iCurrent
call super::create
this.dw_parm=create dw_parm
this.pb_selectall=create pb_selectall
this.pb_deselectall=create pb_deselectall
this.cb_filter=create cb_filter
this.cb_goto=create cb_goto
this.sle_goto=create sle_goto
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_parm
this.Control[iCurrent+2]=this.pb_selectall
this.Control[iCurrent+3]=this.pb_deselectall
this.Control[iCurrent+4]=this.cb_filter
this.Control[iCurrent+5]=this.cb_goto
this.Control[iCurrent+6]=this.sle_goto
end on

on w_project_select.destroy
call super::destroy
destroy(this.dw_parm)
destroy(this.pb_selectall)
destroy(this.pb_deselectall)
destroy(this.cb_filter)
destroy(this.cb_goto)
destroy(this.sle_goto)
end on

event ue_process;call super::ue_process;

String ls_value, ls_value2
Long ll_rowCnt, ll_selectedrows[], N

//*************************************************************
// Get selected GIGP ID(s):
//*************************************************************

ll_rowCnt = dw_parm.inv_rowselect.of_SelectedCount(ll_selectedrows)


If (ll_rowCnt < 1) Then	
	MessageBox("ERROR!", "You must select at least one row to continue!")
	Return
End If


FOR N = 1 TO ll_rowCnt
	
	ls_value = String(dw_parm.GetItemNumber(ll_selectedrows[N], "gigp_id"))
		
	If (Len(ls_value2) < 1) Then
		ls_value2 = ls_value
	Else
		ls_value2 += ("," + ls_value)
	End If

NEXT

of_add_parm("gigp_id",ls_value2, "String")

//MessageBox("Test!", ls_value2)
//dw_1.Print()

Close(This)
end event

event close;call super::close;
If IsValid(ids_recmndParms) Then Destroy ids_recmndParms
end event

event open;call super::open;
String ls_parm

ls_parm = Message.StringParm

//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

dw_parm.of_SetRowSelect(True)

If (ls_parm = "SINGLE") Then	//Single Project Select
	dw_parm.inv_rowselect.of_SetStyle(0)	
	pb_selectall.Visible = False
	pb_deselectall.Visible = False	
	
Else  									//Multi Project Select
	dw_parm.inv_rowselect.of_SetStyle(1)		
	pb_selectall.Visible = True
	pb_deselectall.Visible = True
End If

dw_parm.SetFocus()
end event

event pfc_postopen;call super::pfc_postopen;sle_goto.SetFocus()
end event

type dw_1 from w_report_parms`dw_1 within w_project_select
integer x = 2501
integer y = 1276
integer height = 100
end type

type cb_cancel from w_report_parms`cb_cancel within w_project_select
integer x = 3351
integer y = 1276
end type

type cb_ok from w_report_parms`cb_ok within w_project_select
integer x = 2958
integer y = 1276
boolean default = true
end type

type dw_parm from u_dw within w_project_select
event ue_goto ( long al_gigpid )
integer x = 37
integer y = 28
integer width = 3653
integer height = 1216
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_project_lookup"
end type

event ue_goto(long al_gigpid);long ll_find

If al_gigpid > 0 Then
	ll_find = this.Find('gigp_id = ' + String(al_gigpid), 1, this.RowCount())
	
	If ll_find > 0 Then
		this.ScrollToRow(ll_find)
	Else
		MessageBox('Go To', 'GIGP Id ' + String(al_gigpid) + ' not found.')
	End If
	
End If
end event

event constructor;call super::constructor;
String ls_exclude[] = {'cf_applname'}

This.of_SetTransObject(SQLCA)

This.ib_RMBMenu = False


//********************************************************************
// Start PFC Filter Service:
//********************************************************************

This.of_SetFilter(True)
This.inv_filter.of_SetStyle(2)
This.inv_filter.of_SetColumnNameSource(0)

This.inv_filter.of_SetExclude(ls_exclude)

This.Retrieve()


end event

type pb_selectall from picturebutton within w_project_select
integer x = 37
integer y = 1288
integer width = 101
integer height = 88
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "SelectAll!"
alignment htextalign = left!
string powertiptext = "Select All!"
end type

event clicked;
Long N, ll_Cnt

ll_Cnt = dw_parm.RowCount()

If (ll_Cnt < 1) Then Return

FOR N = 1 TO ll_Cnt
      dw_parm.SelectRow(N, true)
NEXT


end event

type pb_deselectall from picturebutton within w_project_select
integer x = 174
integer y = 1288
integer width = 101
integer height = 88
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "SlideNoneAbove!"
alignment htextalign = left!
string powertiptext = "De-Select All!"
end type

event clicked;dw_parm.SelectRow(0, false)
end event

type cb_filter from commandbutton within w_project_select
integer x = 599
integer y = 56
integer width = 343
integer height = 76
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Filter"
end type

event clicked;
dw_parm.Event pfc_filterdlg()
end event

type cb_goto from commandbutton within w_project_select
integer x = 256
integer y = 56
integer width = 197
integer height = 76
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Go to"
end type

event clicked;long ll_gigp
String ls_goto

ls_goto = sle_goto.Text

If NOT IsNull(ls_goto) Then
	If IsNumber(ls_goto) Then
		ll_gigp = Long(ls_goto)
		dw_parm.Event ue_goto(ll_gigp)
	Else
		MessageBox('Go To', 'Please enter a valid GIGP Id')
		sle_goto.SetFocus()
	End If
End If

cb_Ok.Default = True
end event

type sle_goto from singlelineedit within w_project_select
integer x = 64
integer y = 60
integer width = 197
integer height = 76
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

event modified;cb_goto.Default = True
end event

