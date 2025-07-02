forward
global type w_contact_type_parms from w_report_parms
end type
type dw_parm from u_dw within w_contact_type_parms
end type
type pb_selectall from picturebutton within w_contact_type_parms
end type
type pb_deselectall from picturebutton within w_contact_type_parms
end type
end forward

global type w_contact_type_parms from w_report_parms
integer width = 1509
integer height = 1092
string title = "Contact Types"
dw_parm dw_parm
pb_selectall pb_selectall
pb_deselectall pb_deselectall
end type
global w_contact_type_parms w_contact_type_parms

type variables

Datastore ids_recmndParms
end variables

on w_contact_type_parms.create
int iCurrent
call super::create
this.dw_parm=create dw_parm
this.pb_selectall=create pb_selectall
this.pb_deselectall=create pb_deselectall
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_parm
this.Control[iCurrent+2]=this.pb_selectall
this.Control[iCurrent+3]=this.pb_deselectall
end on

on w_contact_type_parms.destroy
call super::destroy
destroy(this.dw_parm)
destroy(this.pb_selectall)
destroy(this.pb_deselectall)
end on

event ue_process;call super::ue_process;
String ls_value, ls_value2
Long ll_selectedCnt, ll_rowCnt, ll_selectedrows[], N, I

//*************************************************************
// Get selected Contact Types(s):
//*************************************************************

ll_selectedCnt = dw_parm.inv_rowselect.of_SelectedCount(ll_selectedrows)

If (ll_selectedCnt < 1) Then	
	MessageBox("ERROR!", "You must select at least one row to continue!")
	Return
End If

FOR N = 1 TO ll_selectedCnt
	
	ls_value = dw_parm.GetItemString(ll_selectedrows[N], "ref_code")
			
	If (ls_value = "-1") Then	// Selected ALL Contact Types
	
		ll_rowCnt = dw_parm.RowCount()
		
		FOR I = 1 TO ll_rowCnt
			
			ls_value = dw_parm.GetItemString(I, "ref_code")
			
			If (ls_value = "-1") Then	
			
				// Skip
				
			Else
				If (Len(ls_value2) < 1) Then
					ls_value2 = ls_value
				Else
					ls_value2 += ("," + ls_value)
				End If
				
			End If

		NEXT
		
		Goto FinishUp // ALL Contact Types
	End IF
		
	If (Len(ls_value2) < 1) Then
		ls_value2 = ls_value
	Else
		ls_value2 += ("," + ls_value)
	End If

NEXT

FinishUp:

of_add_parm("contact_type",ls_value2, "String")

//MessageBox("Test!", ls_value2)
//dw_1.Print()

Close(This)
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
end event

event close;call super::close;
If IsValid(ids_recmndParms) Then Destroy ids_recmndParms
end event

type dw_1 from w_report_parms`dw_1 within w_contact_type_parms
integer x = 297
integer y = 880
end type

type cb_cancel from w_report_parms`cb_cancel within w_contact_type_parms
integer x = 1125
integer y = 868
end type

type cb_ok from w_report_parms`cb_ok within w_contact_type_parms
integer x = 731
integer y = 868
end type

type dw_parm from u_dw within w_contact_type_parms
integer x = 27
integer y = 28
integer width = 1440
integer height = 816
integer taborder = 10
boolean bringtotop = true
string dataobject = "dddw_contacttype"
end type

event constructor;call super::constructor;
Long ll_rowCount, ll_row

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

pb_selectall.Event Clicked()
end event

event clicked;call super::clicked;
Long N, ll_Cnt
String ls_refCode

If (row < 1) Then Return

ll_Cnt = This.RowCount()

ls_refCode = dw_parm.GetItemString(row, "ref_code")

If (ls_refCode = "-1") Then		
	
	FOR N = 1 TO ll_Cnt     
		
		ls_refCode = dw_parm.GetItemString(N, "ref_code")
		
		If (ls_refCode <> "-1") Then		
			 dw_parm.SelectRow(N, False)		
		End If	
		
	NEXT
		
Else
	
	FOR N = 1 TO ll_Cnt     
		
		ls_refCode = dw_parm.GetItemString(N, "ref_code")
		
		If (ls_refCode = "-1") Then		
			 dw_parm.SelectRow(N, False)		
		End If	
		
	NEXT
		
End If	





end event

type pb_selectall from picturebutton within w_contact_type_parms
integer x = 46
integer y = 880
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
string picturename = "SelectAll!"
alignment htextalign = left!
string powertiptext = "Select All!"
end type

event clicked;
Long N, ll_Cnt
String ls_refCode

ll_Cnt = dw_parm.RowCount()

If (ll_Cnt < 1) Then Return

dw_parm.SelectRow(0, false)

FOR N = 1 TO ll_Cnt     
		
	ls_refCode = dw_parm.GetItemString(N, "ref_code")
	
	If (ls_refCode = "-1") Then		
		 dw_parm.SelectRow(N, true)		
	End If	
		
NEXT


end event

type pb_deselectall from picturebutton within w_contact_type_parms
integer x = 183
integer y = 880
integer width = 101
integer height = 88
integer taborder = 40
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

