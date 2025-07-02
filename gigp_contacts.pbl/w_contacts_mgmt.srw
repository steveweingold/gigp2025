forward
global type w_contacts_mgmt from w_sheet_dbaccess
end type
type pb_2 from picturebutton within w_contacts_mgmt
end type
type st_3 from statictext within w_contacts_mgmt
end type
type pb_1 from picturebutton within w_contacts_mgmt
end type
type st_2 from statictext within w_contacts_mgmt
end type
type sle_filter from singlelineedit within w_contacts_mgmt
end type
type st_1 from statictext within w_contacts_mgmt
end type
type ddlb_filter from dropdownlistbox within w_contacts_mgmt
end type
type tab_1 from u_tab_contactsmgmt within w_contacts_mgmt
end type
type tab_1 from u_tab_contactsmgmt within w_contacts_mgmt
end type
type dw_master from u_dw_enhanced within w_contacts_mgmt
end type
end forward

global type w_contacts_mgmt from w_sheet_dbaccess
string title = "Contacts Management"
string menuname = "m_gigp_sheet"
event ue_editrow ( )
event pfc_insertrow ( )
event pfc_deleterow ( )
event pfc_finddlg ( )
event pfc_filterdlg ( )
event ue_call_log ( )
pb_2 pb_2
st_3 st_3
pb_1 pb_1
st_2 st_2
sle_filter sle_filter
st_1 st_1
ddlb_filter ddlb_filter
tab_1 tab_1
dw_master dw_master
end type
global w_contacts_mgmt w_contacts_mgmt

type variables

m_gigp_sheet	im_Menu
u_dw 			idw_links, idw_info, idw_refs, idw_politdist
Long 			il_contact_ID, il_gigpID
String      	is_newContID


end variables

forward prototypes
public subroutine of_filter (string as_type, string as_code)
end prototypes

event ue_editrow();
Long ll_row, ll_contactID, ll_rc
str_contactparms lstr_parms

lstr_parms.str_contactid =  il_contact_ID

lstr_parms.str_gigpid =  0

OpenWithParm(w_contacts_edit, lstr_parms)

ll_contactID = Message.DoubleParm

If (ll_contactID = -1) Then Return

dw_master.inv_linkage.of_Retrieve()


	












end event

event pfc_insertrow();Long ll_row, ll_contactID
str_contactparms lstr_parms

If MessageBox('New Contact', 'Please make sure that you searched to see if this Contact already exists.  Do you want to continue?', Question!, YesNoCancel!) = 1 Then

	lstr_parms.str_contactid = -1
	
	lstr_parms.str_gigpid =  0
	
	OpenWithParm(w_contacts_edit,lstr_parms)
	
	ll_contactID = Message.DoubleParm
	
	If (ll_contactID = -1) Then Return
	
	is_newContID = String(ll_contactID)
	
	dw_master.inv_linkage.of_Retrieve()
	
End If

end event

event pfc_deleterow();long ll_count
Integer	li_RC

//*******************************************************
// Check for Call logs:
//*******************************************************
If il_contact_ID > 0 Then
	
	select count(*)
	into :ll_count
	from gigp_call_log
	where contact_id = :il_contact_ID;
	
	If ll_count > 0 Then
		MessageBox('Delete', 'Call Logs exist for this Contact.  Please delete them first.')
		Return
		
	End If
	
End If

//*******************************************************
// Check for Professional Contracts:
//*******************************************************
If il_contact_ID > 0 Then
	
	select count(*)
	into :ll_count
	from gigp_professional_contracts
	where contact_id = :il_contact_ID;
	
	If ll_count > 0 Then
		MessageBox('Delete', 'This Contact is tied to at least one Professional Contract and cannot be deleted.')
		Return
		
	End If
	
End If

//*******************************************************
// Check for APP or PLC
//*******************************************************
If il_contact_ID > 0 Then
	
	select count(*)
	into :ll_count
	from gigp_contact_links
	where contact_id = :il_contact_ID
	and contact_type in ('APP','PLC');
	
	If ll_count > 0 Then
		MessageBox('Delete', 'This Contact is either an Applicant or Project Location and cannot be deleted. Please see IT if you need assistance.')
		Return
		
	End If
	
End If




li_RC = Messagebox('Delete', 'WARNING: This will permanently delete the selected contact from the GIGP system.~r~n~r~nAre you sure you want to delete the selected contact?', Exclamation!, YesNo!, 2)

If (li_RC = 1) Then
	
	dw_master.SetReDraw(False)
	
	//*******************************************************
	// Delete Contact & Contact Links:
	//*******************************************************	
	
	Tab_1.TabTriggerEvent("ue_delete")
	
	
	
	
	//*******************************************************
	// Save:
	//*******************************************************
	
	This.Event pfc_save()
	
	//*******************************************************
	// Re-retrieve:
	//*******************************************************
	
	dw_master.inv_linkage.of_Retrieve()
	
	dw_master.SetReDraw(True)
	
End If




end event

event pfc_finddlg();
dw_master.Event pfc_finddlg()
end event

event pfc_filterdlg();
dw_master.Event pfc_filterdlg()
end event

event ue_call_log();long ll_contactId
w_call_log lw_win

//Open the call log window passing the selected contact
If dw_master.RowCount() > 0 Then
	ll_contactId = dw_master.GetItemNumber(dw_master.GetRow(), 'contact_id')
	OpenSheetWithParm(lw_win, ll_contactId, gnv_app.of_getframe())
	
Else
	SetNull(ll_contactId)
	OpenSheetWithParm(lw_win, ll_contactId, gnv_app.of_getframe())
	
End If
end event

public subroutine of_filter (string as_type, string as_code);
String ls_filter, ls_value
Long ll_count

If (as_type = "CONTACTTYPE") Then
	
	ls_filter = "cc_contactTypes like '%" + as_code +  "%'" 
	sle_filter.Text = ""
	
ElseIf (as_type = "STRINGPATTERN") Then
	ls_value = Upper(as_code)
	ls_filter =  "(Upper(full_name) like '%" + ls_value +  "%' ) OR (Upper(title) like '%" + ls_value +  "%') OR (Upper(organization) like '%" + ls_value +  "%') OR (Upper(cc_address) like '%" + ls_value +  "%')" 
	ddlb_filter.SelectItem("[NONE]", 1)
	
Else //Reset		
	ls_filter = ""
	sle_filter.Text = ""
	ddlb_filter.SelectItem("[NONE]", 1)
	
End If 

dw_master.SetFilter(ls_filter)
dw_master.Filter()
	
ll_count = dw_master.RowCount()
	
If (ll_count > 0) Then
	dw_master.inv_Linkage.Event pfc_rowfocuschanged(1)
	dw_master.SelectRow(0, false)
	dw_master.SelectRow(1, true)
End If
end subroutine

on w_contacts_mgmt.create
int iCurrent
call super::create
if this.MenuName = "m_gigp_sheet" then this.MenuID = create m_gigp_sheet
this.pb_2=create pb_2
this.st_3=create st_3
this.pb_1=create pb_1
this.st_2=create st_2
this.sle_filter=create sle_filter
this.st_1=create st_1
this.ddlb_filter=create ddlb_filter
this.tab_1=create tab_1
this.dw_master=create dw_master
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.pb_2
this.Control[iCurrent+2]=this.st_3
this.Control[iCurrent+3]=this.pb_1
this.Control[iCurrent+4]=this.st_2
this.Control[iCurrent+5]=this.sle_filter
this.Control[iCurrent+6]=this.st_1
this.Control[iCurrent+7]=this.ddlb_filter
this.Control[iCurrent+8]=this.tab_1
this.Control[iCurrent+9]=this.dw_master
end on

on w_contacts_mgmt.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.pb_2)
destroy(this.st_3)
destroy(this.pb_1)
destroy(this.st_2)
destroy(this.sle_filter)
destroy(this.st_1)
destroy(this.ddlb_filter)
destroy(this.tab_1)
destroy(this.dw_master)
end on

event open;call super::open;
This.inv_resize.of_Register(dw_master,"ScaleToRight")





end event

event pfc_postopen;call super::pfc_postopen;
Integer li_RC
Long ll_cnt

//************************************************************
// Set pointers to datawindows:
//************************************************************

idw_info	= tab_1.itp_Array[1].dw_1
idw_links	= tab_1.itp_Array[2].dw_1
idw_politdist = tab_1.itp_Array[3].dw_1

//************************************************************
// (1) Enable the linkage service for the master DataWindow:
//************************************************************

dw_master.of_SetLinkage(TRUE)

//************************************************************
// (2) Enable the linkage service for the detail DataWindow:
//************************************************************

idw_info.of_SetLinkage(True)
idw_links.of_SetLinkage(True)
idw_politdist.of_SetLinkage(True)

//************************************************************
// (3) In the detail DataWindow, link to the Master:
//************************************************************

idw_info.inv_linkage.of_SetMaster(dw_master)
idw_links.inv_linkage.of_SetMaster(dw_master)
idw_politdist.inv_linkage.of_SetMaster(dw_master)

//************************************************************
// (4) Register the related columns:
//************************************************************

idw_info.inv_linkage.of_Register ("contact_id", "contact_id")
idw_links.inv_linkage.of_Register ("contact_id", "contact_id")
idw_politdist.inv_linkage.of_Register ("contact_id", "contact_id")

//************************************************************
// (5) Establish the action taken in the detail when row
//     focus changes in the master:
//************************************************************

//dw_master.inv_linkage.of_SetStyle(dw_master.inv_linkage.RETRIEVE)
li_RC = idw_info.inv_linkage.of_SetStyle(dw_master.inv_linkage.RETRIEVE)
li_RC = idw_links.inv_linkage.of_SetStyle(dw_master.inv_linkage.RETRIEVE)
li_RC = idw_politdist.inv_linkage.of_SetStyle(dw_master.inv_linkage.RETRIEVE)

//************************************************************
// (6) Establish the transaction object for all DataWindows
//     in the linkage chain:
//************************************************************

dw_master.inv_linkage.of_SetTransObject(sqlca)

//************************************************************
// (7) Call the master DataWindow's of_Retrieve function:
//************************************************************

ll_cnt = dw_master.inv_linkage.of_Retrieve()

If (ll_cnt = 1) Then dw_master.inv_linkage.Event pfc_RowFocusChanged(1)

dw_master.SetFocus()

//************************************************************
// Check Security:
//************************************************************

If (ib_editAccess = True) Then	
	im_Menu.m_edit.m_editrow.Enabled   = True
	im_Menu.m_edit.m_insertrow.Enabled = True
	im_Menu.m_edit.m_deleterow.Enabled = True
	im_Menu.m_file.m_save.Enabled      = True
Else
	im_Menu.m_edit.m_editrow.Enabled   = False
	im_Menu.m_edit.m_insertrow.Enabled = False
	im_Menu.m_edit.m_deleterow.Enabled = False
	im_Menu.m_file.m_save.Enabled      = False
End If 



end event

event pfc_preopen;call super::pfc_preopen;
//********************************************************************
// Limit Menu Functionality:
//********************************************************************

im_Menu = This.MenuID

//******************************************************
// Customize Menu:
//******************************************************

im_Menu.m_edit.m_insertrow.Visible = True
im_Menu.m_edit.m_insertrow.ToolBarItemVisible = True

im_Menu.m_edit.m_editrow.Visible = True
im_Menu.m_edit.m_editrow.ToolBarItemVisible = True

im_Menu.m_edit.m_deleterow.Visible = True
im_Menu.m_edit.m_deleterow.ToolBarItemVisible = True

im_Menu.m_edit.m_find.Visible = True
im_Menu.m_edit.m_find.ToolBarItemVisible = True

im_Menu.m_view.m_filter.Visible = True
im_Menu.m_view.m_filter.ToolBarItemVisible = True

//******************************************************
// Order the Sheet Toolbar:
//******************************************************

im_Menu.m_edit.m_insertrow.ToolBarItemOrder 	= 1
im_Menu.m_edit.m_editrow.ToolBarItemOrder 	= 2
im_Menu.m_edit.m_deleterow.ToolBarItemOrder	= 3
im_Menu.m_edit.m_find.ToolBarItemOrder	 		= 4
im_Menu.m_view.m_filter.ToolBarItemOrder 		= 5
im_Menu.m_file.m_save.ToolBarItemOrder 		    	= 6
im_Menu.m_file.m_close.ToolBarItemOrder 			= 7

//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Contacts"}







end event

type pb_2 from picturebutton within w_contacts_mgmt
integer x = 2574
integer y = 24
integer width = 110
integer height = 96
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean originalsize = true
string picturename = "Where!"
alignment htextalign = left!
string powertiptext = "Filter List!"
end type

type st_3 from statictext within w_contacts_mgmt
integer x = 23
integer y = 28
integer width = 215
integer height = 80
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Filter by:"
boolean focusrectangle = false
end type

type pb_1 from picturebutton within w_contacts_mgmt
integer x = 2711
integer y = 24
integer width = 110
integer height = 96
integer taborder = 41
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "Undo!"
alignment htextalign = left!
string powertiptext = "Clear Filter!"
end type

event clicked;
of_filter("RESET", "")
end event

type st_2 from statictext within w_contacts_mgmt
integer x = 1431
integer y = 36
integer width = 357
integer height = 64
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 32768
long backcolor = 67108864
string text = "Pattern Match"
boolean focusrectangle = false
end type

type sle_filter from singlelineedit within w_contacts_mgmt
integer x = 1787
integer y = 28
integer width = 768
integer height = 84
integer taborder = 31
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

event getfocus;
This.Text = ""
end event

event modified;
String ls_code

ls_code = This.Text

Parent.of_filter("STRINGPATTERN", ls_code)

dw_master.SetFocus()
end event

type st_1 from statictext within w_contacts_mgmt
integer x = 283
integer y = 36
integer width = 334
integer height = 64
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 32768
long backcolor = 67108864
string text = "Contact Type"
boolean focusrectangle = false
end type

type ddlb_filter from dropdownlistbox within w_contacts_mgmt
integer x = 631
integer y = 28
integer width = 763
integer height = 1100
integer taborder = 11
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean sorted = false
boolean hscrollbar = true
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

event constructor;
String ls_value

This.AddItem("[NONE]")

DECLARE cLoadTypes CURSOR FOR
	SELECT ref_value
    	FROM gigp_reference  
   	WHERE category = 'contactType';
	
OPEN cLoadTypes;
	
FETCH cLoadTypes INTO :ls_value;
	
DO WHILE SQLCA.sqlcode = 0
				
	This.AddItem(ls_value)
	ls_value = ""
				
	FETCH cLoadTypes INTO :ls_value;
	
LOOP
	
CLOSE cLoadTypes;

ddlb_filter.SelectItem("[NONE]", 1)






end event

event selectionchanged;
String ls_selection, ls_code

ls_selection = This.Text

If (ls_selection = "[NONE]") Then
	of_filter("RESET", "")
Else
	
	SELECT ref_code
	INTO :ls_code
	FROM gigp_reference  
	WHERE category = 'contactType'   
	AND ref_value = :ls_selection;
			
	Parent.of_filter("CONTACTTYPE", ls_code)
End If

dw_master.SetFocus()
end event

type tab_1 from u_tab_contactsmgmt within w_contacts_mgmt
integer x = 23
integer y = 872
integer width = 2834
integer height = 416
integer taborder = 11
end type

event selectionchanged;

//OverRide//
end event

type dw_master from u_dw_enhanced within w_contacts_mgmt
integer x = 23
integer y = 128
integer width = 2834
integer height = 704
integer taborder = 10
string dataobject = "d_contacts_master_list"
end type

event constructor;call super::constructor;
ib_RMBmenu = False

//********************************************************************
// Register Contact ID:
//********************************************************************

This.of_registerkey("contact_id")

//********************************************************************
// Start PFC Sort Service:
//********************************************************************

This.of_SetSort(True)
This.inv_sort.of_SetColumnHeader(TRUE)

//********************************************************************
// Turn on the Row Selection Service for dw's:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)

//********************************************************************
// Turn on the Find Service for dw's:
//********************************************************************

This.of_SetFind(TRUE)

//********************************************************************
// Turn on the Filter Service for dw's:
//********************************************************************

This.of_SetFilter(TRUE)
This.inv_filter.of_SetColumnDisplayNameStyle(2)
This.inv_filter.of_SetStyle(2)

This.Object.DataWindow.ReadOnly="Yes"
end event

event pfc_retrieve;call super::pfc_retrieve;
Long ll_rows, ll_row, ll_contactID
String ls_type, ls_value
Integer li_trim

ll_rows = This.Retrieve()


//****12/2017, this functionality added to query for speed
//If (ll_rows > 0) Then
//	
//	FOR ll_row = 1 TO ll_rows
//
//		ll_contactID = This.GetItemnumber(ll_row, "contact_id")
//		
//		DECLARE cGetTypes CURSOR FOR
//			SELECT Distinct contact_type  
//			FROM gigp_contact_links  
//			WHERE contact_id =  :ll_contactID;
//			
//		OPEN cGetTypes;
//			
//		FETCH cGetTypes INTO :ls_type;
//			
//		DO WHILE SQLCA.sqlcode = 0
//			
//			ls_value += (ls_type + " , ")				
//				
//			ls_type = ""	
//					
//			FETCH cGetTypes INTO :ls_type;
//		
//		LOOP
//		
//		CLOSE cGetTypes;
//		
//		If (Len(ls_value) >  0) Then
//			li_trim = (Len(Trim(ls_value)) - 1)
//			ls_value = Trim(Left( ls_value, li_trim))
//			This.SetItem(ll_row, 'cc_contactTypes', ls_value)
//			This.SetItemStatus(ll_row, 0, Primary!, NotModified!)
//		End If
//			
//		ls_type = ""	
//		ls_value = ""
//		ll_contactID = 0
//		li_trim = 0
//		
//	NEXT
//	
//End If 

Return ll_rows


end event

event rowfocuschanged;call super::rowfocuschanged;

If (currentrow < 1) Then Return AncestorReturnValue

il_contact_ID = This.GetItemNumber(currentrow, "contact_id")


end event

event doubleclicked;call super::doubleclicked;
il_contact_ID = This.GetItemNumber(This.GetRow(), "contact_id")

Parent.Event ue_editrow()
end event

event retrieveend;
//OverRide//

int			li_Index, &
				li_Row, &
				li_RC, &
				li_Pos
string		ls_Find
u_dw			ldw_Details[]

IF ii_NumKeys < 1 THEN
	IF ib_SetRedraw THEN
		this.SetRedraw(True)
	END IF

	Return
END IF

li_RC = this.RowCount()

IF li_RC < 1 THEN
	IF ib_SetRedraw THEN
		this.SetRedraw(True)
	END IF

	Return
END IF

// This script won't work on linked dw's unless this is the root dw.	//
IF IsValid(inv_linkage) THEN
	IF NOT inv_linkage.of_IsRoot() THEN
		IF ib_SetRedraw THEN
			this.SetRedraw(True)
		END IF

		Return
	END IF
END IF

If Not IsNull(is_newContID) Then	
	dw_master.is_KeyValues[1] = is_newContID
	SetNull(is_newContID)
End If

DO WHILE li_Index < ii_NumKeys
	li_Index ++

	// Single and double quotes and tildes will not work in find statement.	//
	IF Pos(is_KeyValues[li_Index],"'") > 0 OR Pos(is_KeyValues[li_Index],'"') > 0 THEN
		li_Pos = Pos(is_KeyValues[li_Index],"'")

		// Put a tilde before every single quote found.	//
		DO WHILE li_Pos > 0
			is_KeyValues[li_Index] = Mid(is_KeyValues[li_Index],1,li_Pos - 1) + &
												"~~" + Mid(is_KeyValues[li_Index],li_Pos,99999)

			li_Pos = Pos(is_KeyValues[li_Index],"'",li_Pos)
		LOOP

		li_Pos = Pos(is_KeyValues[li_Index],'"')

		// Put a tilde before every double quote found.	//
		DO WHILE li_Pos > 0
			is_KeyValues[li_Index] = Mid(is_KeyValues[li_Index],1,li_Pos - 1) + &
												"~~" + Mid(is_KeyValues[li_Index],li_Pos,99999)
			li_Pos += 2

			li_Pos = Pos(is_KeyValues[li_Index],'"',li_Pos)
		LOOP

		li_Pos = Pos(is_KeyValues[li_Index],'~~')

		// Put a tilde before every tilde found.	//
		DO WHILE li_Pos > 0
			is_KeyValues[li_Index] = Mid(is_KeyValues[li_Index],1,li_Pos - 1) + &
												"~~" + Mid(is_KeyValues[li_Index],li_Pos,99999)
			li_Pos += 2

			li_Pos = Pos(is_KeyValues[li_Index],'~~',li_Pos)
		LOOP
	END IF

	CHOOSE CASE is_KeyTypes[li_Index]
	CASE "STRING"
		IF NOT IsNull(is_KeyValues[li_Index]) AND Trim(is_KeyValues[li_Index]) <> "" THEN
			ls_Find += is_Keys[li_Index] + "=~"" + is_KeyValues[li_Index] + "~" and "
		END IF
	CASE "NUMBER"
		IF NOT IsNull(is_KeyValues[li_Index]) AND Trim(is_KeyValues[li_Index]) <> "" THEN
			ls_Find += is_Keys[li_Index] + "=" + is_KeyValues[li_Index] + " and "
		END IF
	CASE "DATETIME"
		IF NOT IsNull(is_KeyValues[li_Index]) AND Trim(is_KeyValues[li_Index]) <> "" THEN
			ls_Find += is_Keys[li_Index] + "=DateTime('" + is_KeyValues[li_Index] + "') and "
		END IF
	CASE "DATE"
		IF NOT IsNull(is_KeyValues[li_Index]) AND Trim(is_KeyValues[li_Index]) <> "" THEN
			ls_Find += is_Keys[li_Index] + "=Date('" + is_KeyValues[li_Index] + "') and "
		END IF
	CASE "TIME"
		IF NOT IsNull(is_KeyValues[li_Index]) AND Trim(is_KeyValues[li_Index]) <> "" THEN
			ls_Find += is_Keys[li_Index] + "=Time('" + is_KeyValues[li_Index] + "') and "
		END IF
	END CHOOSE
LOOP

IF ls_Find <> "" THEN
	ls_Find = Mid(ls_Find,1,Len(ls_Find) - 5)

	li_Index = this.Find(ls_Find,1,li_RC)
	
	If (li_index < 1) and (rowcount > 0) Then
		li_Index = 1		
	End If	
	
	this.ScrollToRow(li_Index)
	this.SelectRow(0, FALSE)
	this.SelectRow(li_index, TRUE)	
	
END IF

IF ib_SetRedraw THEN
	this.SetRedraw(True)

	// Turn on redraw for linked dw's.	//
	IF IsValid(inv_linkage) THEN
		li_RC = this.inv_linkage.of_GetDetails(ldw_Details)

		FOR li_Index = 1 TO li_RC
			ldw_Details[li_Index].SetRedraw(True)
		NEXT
	END IF
END IF




end event

