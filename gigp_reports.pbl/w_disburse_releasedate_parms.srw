forward
global type w_disburse_releasedate_parms from w_report_parms
end type
type ddlb_release from dropdownlistbox within w_disburse_releasedate_parms
end type
type dw_disburse from u_dw within w_disburse_releasedate_parms
end type
type st_1 from statictext within w_disburse_releasedate_parms
end type
type pb_selectall from picturebutton within w_disburse_releasedate_parms
end type
type pb_deselectall from picturebutton within w_disburse_releasedate_parms
end type
type cb_1 from commandbutton within w_disburse_releasedate_parms
end type
end forward

global type w_disburse_releasedate_parms from w_report_parms
integer x = 214
integer y = 221
integer width = 2363
integer height = 1596
ddlb_release ddlb_release
dw_disburse dw_disburse
st_1 st_1
pb_selectall pb_selectall
pb_deselectall pb_deselectall
cb_1 cb_1
end type
global w_disburse_releasedate_parms w_disburse_releasedate_parms

type variables

DateTime idt_release
boolean ib_selected = False
end variables

on w_disburse_releasedate_parms.create
int iCurrent
call super::create
this.ddlb_release=create ddlb_release
this.dw_disburse=create dw_disburse
this.st_1=create st_1
this.pb_selectall=create pb_selectall
this.pb_deselectall=create pb_deselectall
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.ddlb_release
this.Control[iCurrent+2]=this.dw_disburse
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.pb_selectall
this.Control[iCurrent+5]=this.pb_deselectall
this.Control[iCurrent+6]=this.cb_1
end on

on w_disburse_releasedate_parms.destroy
call super::destroy
destroy(this.ddlb_release)
destroy(this.dw_disburse)
destroy(this.st_1)
destroy(this.pb_selectall)
destroy(this.pb_deselectall)
destroy(this.cb_1)
end on

event ue_process;call super::ue_process;
String ls_value, ls_value2
Long ll_rowCnt, ll_selectedrows[], N

//*************************************************************
// Get selected Disbursement ID(s):          
//*************************************************************

ll_rowCnt = dw_disburse.inv_rowselect.of_SelectedCount(ll_selectedrows)


If (ll_rowCnt < 1) Then	
	MessageBox("ERROR!", "You must select at least one row to continue!")
	Return
End If


FOR N = 1 TO ll_rowCnt
	
	ls_value = String(dw_disburse.GetItemNumber(ll_selectedrows[N], "disbursement_id"))
		
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

type dw_1 from w_report_parms`dw_1 within w_disburse_releasedate_parms
integer x = 622
integer y = 1380
end type

type cb_cancel from w_report_parms`cb_cancel within w_disburse_releasedate_parms
integer x = 1966
integer y = 1376
end type

type cb_ok from w_report_parms`cb_ok within w_disburse_releasedate_parms
integer x = 1586
integer y = 1376
end type

type ddlb_release from dropdownlistbox within w_disburse_releasedate_parms
integer x = 398
integer y = 16
integer width = 366
integer height = 452
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean autohscroll = true
boolean sorted = false
boolean vscrollbar = true
string item[] = {""}
borderstyle borderstyle = stylelowered!
end type

event constructor;

DateTime ldt_release
String ls_value

DECLARE cRelease CURSOR FOR
	SELECT DISTINCT release_dt  
   	FROM gigp_disbursement_request  
   	WHERE (release_amt = 0  OR  release_amt is null )   
	ORDER BY release_dt  ASC;
	
	
OPEN cRelease;
	
FETCH cRelease INTO :ldt_release;
	
DO WHILE SQLCA.sqlcode = 0
	
	If (IsNull(ls_value) Or Trim(ls_value) = "") Then
		ls_value = "[NONE]"
	Else
		ls_value = String(Date(ldt_release), "mm/dd/yy")
	End If
	
	ddlb_release.AddItem(ls_value)
			
	FETCH cRelease INTO :ldt_release;
	
LOOP
	
CLOSE cRelease;





end event

event modified;
String ls_value

ls_value = ddlb_release.Text

If (ls_value = "[NONE]")Then
	SetNull(idt_release)
Else
	idt_release = DateTime(Date(ddlb_release.Text))
End If


dw_disburse.Retrieve(idt_release)
end event

type dw_disburse from u_dw within w_disburse_releasedate_parms
event ue_select_deselect_all ( )
integer x = 37
integer y = 156
integer width = 2272
integer height = 1156
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_disburse_tobe_released"
end type

event ue_select_deselect_all();If this.RowCount() > 0 Then
	If ib_selected Then
		this.SelectRow(0, False)
		ib_selected = False
	Else
		this.SelectRow(0, True)
		ib_selected = True
	End If

End If
end event

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False

//********************************************************************
// Start PFC Row Selection Service - Multiple Select:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(1)
end event

type st_1 from statictext within w_disburse_releasedate_parms
integer x = 37
integer y = 32
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
string text = "Release Date:"
boolean focusrectangle = false
end type

type pb_selectall from picturebutton within w_disburse_releasedate_parms
integer x = 37
integer y = 1380
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
string picturename = "SelectAll!"
alignment htextalign = left!
string powertiptext = "Select All!"
end type

event clicked;
Long ll_row, ll_rowCnt

ll_rowCnt = dw_disburse.RowCount()

If (ll_rowCnt < 1) Then return

FOR ll_row = 1 TO ll_rowCnt
      dw_disburse.SelectRow(ll_row, true)
NEXT
end event

type pb_deselectall from picturebutton within w_disburse_releasedate_parms
integer x = 174
integer y = 1380
integer width = 110
integer height = 96
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

event clicked;
dw_disburse.SelectRow(0, false)
end event

type cb_1 from commandbutton within w_disburse_releasedate_parms
integer x = 1682
integer y = 16
integer width = 626
integer height = 100
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Select / Deselect All"
end type

event clicked;dw_disburse.Event ue_select_deselect_all()
end event

