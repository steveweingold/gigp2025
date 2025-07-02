forward
global type u_tabpg_contacts from u_tabpg_dbaccess
end type
type dw_2 from u_dw within u_tabpg_contacts
end type
type rb_all from radiobutton within u_tabpg_contacts
end type
type rb_vendors from radiobutton within u_tabpg_contacts
end type
type rb_efc from radiobutton within u_tabpg_contacts
end type
type st_filter from statictext within u_tabpg_contacts
end type
type rb_1 from radiobutton within u_tabpg_contacts
end type
type dw_3 from u_dw within u_tabpg_contacts
end type
type cb_addcfa from commandbutton within u_tabpg_contacts
end type
end forward

global type u_tabpg_contacts from u_tabpg_dbaccess
integer width = 4361
integer height = 2432
string text = "Contacts"
string picturename = "BrowseClasses!"
event ue_call_log ( )
dw_2 dw_2
rb_all rb_all
rb_vendors rb_vendors
rb_efc rb_efc
st_filter st_filter
rb_1 rb_1
dw_3 dw_3
cb_addcfa cb_addcfa
end type
global u_tabpg_contacts u_tabpg_contacts

forward prototypes
public subroutine of_sendemail ()
public subroutine of_set_notmodified (long al_row)
public subroutine of_filter (string as_type)
public subroutine of_retrieve_contacttypes ()
end prototypes

event ue_call_log();long ll_contactId
w_call_log lw_win

//Open the call log window passing the selected contact
If dw_1.RowCount() > 0 Then
	ll_contactId = dw_1.GetItemNumber(dw_1.GetRow(), 'contact_id')
	
	OpenSheetWithParm(lw_win, ll_contactId, gnv_app.of_getframe())
	
Else
	SetNull(ll_contactId)
	OpenSheetWithParm(lw_win, ll_contactId, gnv_app.of_getframe())
	
End If
end event

public subroutine of_sendemail ();
Integer li_rc, li_emailFlag
Long ll_row, ll_rowCnt
String ls_Msg, ls_URL, ls_MailTo,  ls_Subject = "GIGP", ls_email
n_cst_iexplorer_srv	lnv_iexplorer


ll_rowCnt = dw_1.RowCount()

If ll_rowCnt < 1 Then Return

FOR ll_row = 1 TO ll_rowCnt
	
	li_emailFlag = dw_1.GetItemNumber(ll_row, "email_flag")
	
	If (li_emailFlag = 1) Then
		
		ls_email = Trim(dw_1.GetItemString(ll_row, "email"))
		
		If (Len(Trim(ls_MailTo)) < 1) Then			
			ls_MailTo = ls_email
		Else
			ls_MailTo += (";, " + ls_email)			
		End If
				
	End If

NEXT

//ls_MailTo = Trim(dw_2.GetItemString(ll_row, "email"))

If (IsNull(ls_MailTo) Or (ls_MailTo = "")) Then 
	MessageBox("ERROR!", "No Email Addresses Selected!")
	Return
End If


// Build URL for sending mail
ls_URL = "mailto:" + ls_MailTo + "?"
 
//If ls_Subject > '' Then	
// ls_URL = ls_URL + 'subject=' + ls_Subject
//End If

// Connect to IE

If Not IsValid(lnv_iexplorer) Then
	lnv_iexplorer = Create n_cst_iexplorer_srv
End If

li_rc = lnv_iexplorer.of_Connect()
If li_rc <> 1 Then Return

// Execute URL

li_rc = lnv_iexplorer.of_LinkToURL(ls_URL, False)
//If li_rc <> 1 Then Goto Error




	






 

 



end subroutine

public subroutine of_set_notmodified (long al_row);
dw_1.SetItemStatus(al_row, 0, Primary!, NotModified!)

end subroutine

public subroutine of_filter (string as_type);
String ls_filter
	
ls_filter = "contact_type = " 	
	
If (as_type = "Vendor") Then	
	ls_filter = "pos(cc_contacttypes, 'VEND') > 0"
	
ElseIf (as_type = "EFC") Then
	ls_filter = "pos(cc_contacttypes, 'EFC') > 0 Or (organization = 'EFC')"			
	
ElseIf (as_type = "NONEFC") Then		
	ls_filter = "pos(cc_contacttypes, 'EFC') < 1 and ((organization <> 'EFC') or (IsNull(organization)))"
	
Else
	ls_filter = ""
End If

dw_1.setFilter(ls_filter)
dw_1.Filter()
dw_1.Sort()

If (dw_1.RowCount() > 0) Then
	dw_1.inv_rowselect.of_rowselect(1)
	dw_1.Event rowfocuschanged(1)
End If

dw_1.SetFocus()


end subroutine

public subroutine of_retrieve_contacttypes ();
Long ll_row, ll_rowCnt, ll_contactID, ll_typeCnt, n
String ls_types, ls_value
Datastore lds

lds = CREATE Datastore
lds.DataObject = 'd_contacttypes_by_contact_project2'
lds.SetTransObject(SQLCA)

ll_rowCnt = dw_1.RowCount()

FOR ll_row = 1 TO ll_rowCnt

     ll_contactID = dw_1.GetItemNumber(ll_row, "contact_id")
		
	ll_typeCnt = lds.Retrieve(ll_contactID,gl_gigp_id )	
	
	
	If (ll_typeCnt > 0) Then
		
		FOR n = 1 TO ll_typeCnt

			ls_value = lds.GetItemString(n, 'contact_type')
			
			ls_types += ls_value
			
			If (n <> ll_typeCnt) Then
				ls_types += ', '			
			End If
		
			ls_value = ""
		
		NEXT
		
		dw_1.SetItem(ll_row, "cc_contacttypes", ls_types)
		dw_1.SetItemStatus(ll_row, 0, Primary!, NotModified!)	
		
		ls_value = ""
		ls_types = ""
		
		
	End If 
	
	

NEXT









Destroy lds
end subroutine

on u_tabpg_contacts.create
int iCurrent
call super::create
this.dw_2=create dw_2
this.rb_all=create rb_all
this.rb_vendors=create rb_vendors
this.rb_efc=create rb_efc
this.st_filter=create st_filter
this.rb_1=create rb_1
this.dw_3=create dw_3
this.cb_addcfa=create cb_addcfa
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_2
this.Control[iCurrent+2]=this.rb_all
this.Control[iCurrent+3]=this.rb_vendors
this.Control[iCurrent+4]=this.rb_efc
this.Control[iCurrent+5]=this.st_filter
this.Control[iCurrent+6]=this.rb_1
this.Control[iCurrent+7]=this.dw_3
this.Control[iCurrent+8]=this.cb_addcfa
end on

on u_tabpg_contacts.destroy
call super::destroy
destroy(this.dw_2)
destroy(this.rb_all)
destroy(this.rb_vendors)
destroy(this.rb_efc)
destroy(this.st_filter)
destroy(this.rb_1)
destroy(this.dw_3)
destroy(this.cb_addcfa)
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Contacts", "Application"}
end event

event ue_tab_deselected;call super::ue_tab_deselected;
m_gigp_master lm_Menu

lm_Menu = it_Parent.iw_Parent.MenuID

//******************************************************
// Customize Menu:
//******************************************************

lm_Menu.m_tools.m_utilities.m_contactsmgmt.ToolBarItemVisible = False

lm_Menu.m_file.m_save.Visible = True
lm_Menu.m_file.m_save.ToolBarItemVisible = True

lm_Menu.m_file.m_print.Visible = False
lm_Menu.m_file.m_print.ToolBarItemVisible = False

lm_Menu.m_edit.m_insertrow.Visible = False
lm_Menu.m_edit.m_insertrow.ToolBarItemVisible = False
lm_Menu.m_edit.m_insertrow.Text = 'Insert Row'
lm_Menu.m_edit.m_insertrow.ToolBarItemText = 'Insert Row'

//lm_Menu.m_edit.m_deleterow.Visible = False
//lm_Menu.m_edit.m_deleterow.ToolBarItemVisible = False

lm_Menu.m_edit.m_editrow.Visible =  False
lm_Menu.m_edit.m_editrow.ToolBarItemVisible =  False
lm_Menu.m_edit.m_editrow.Text = 'Edit Row'
lm_Menu.m_edit.m_editrow.ToolBarItemText = 'Edit Row'

lm_Menu.m_tools.m_email.Visible = False
lm_Menu.m_tools.m_email.ToolBarItemVisible = False


end event

event ue_tab_selected;call super::ue_tab_selected;string ls_switch
m_gigp_master lm_Menu
Boolean lb_visible


lm_Menu = it_Parent.iw_Parent.MenuID

//******************************************************
// Customize Menu:
//******************************************************

//lm_Menu.m_tools.m_utilities.m_contactsmgmt.ToolBarItemVisible = True
lm_Menu.m_file.m_save.Visible = False
lm_Menu.m_file.m_save.ToolBarItemVisible = False

lm_Menu.m_file.m_print.Visible = True
lm_Menu.m_file.m_print.ToolBarItemVisible = True

lm_Menu.m_tools.m_email.Visible = True
lm_Menu.m_tools.m_email.ToolBarItemVisible = True

//******************************************************
// Check Security:
//******************************************************

If (ib_editAccess = True) Then	
	lb_visible = True
	
Else	
	lb_visible = False	
End If

lm_Menu.m_edit.m_insertrow.Visible = lb_visible
lm_Menu.m_edit.m_insertrow.ToolBarItemVisible = lb_visible
lm_Menu.m_edit.m_insertrow.Text = 'Add Contact'
lm_Menu.m_edit.m_insertrow.ToolBarItemText = 'Add Contact'

lm_Menu.m_edit.m_editrow.Visible = lb_visible
lm_Menu.m_edit.m_editrow.ToolBarItemVisible = lb_visible
lm_Menu.m_edit.m_editrow.Text = 'Edit Contact'
lm_Menu.m_edit.m_editrow.ToolBarItemText = 'Edit Contact'


//lm_Menu.m_edit.m_deleterow.Visible = True
//lm_Menu.m_edit.m_deleterow.ToolBarItemVisible = lb_visible

//******************************************************
// Order the Sheet Toolbar:
//******************************************************

lm_Menu.m_edit.m_insertrow.ToolBarItemOrder 	= 1
lm_Menu.m_edit.m_editrow.ToolBarItemOrder 	= 2
lm_Menu.m_edit.m_deleterow.ToolBarItemOrder	= 3
lm_Menu.m_file.m_print.ToolBarItemOrder	 		= 4
lm_Menu.m_tools.m_email.ToolBarItemOrder       	= 5
lm_Menu.m_file.m_save.ToolBarItemOrder 			= 6
lm_Menu.m_file.m_close.ToolBarItemOrder 			= 7

//******************************************************
// Force Row Focus Change to Retrieve the Detail DW:
//******************************************************

dw_1.Event rowfocuschanged(dw_1.GetRow())


//******************************************************
// Handle CFA Contact Addition
//******************************************************
select ref_code
into :ls_switch
from gigp_reference
where category = 'AddCFAContacts';

If ls_switch = '1' Then
	cb_addcfa.Visible = True
Else
	cb_addcfa.Visible = False
End If


end event

type dw_1 from u_tabpg_dbaccess`dw_1 within u_tabpg_contacts
event ue_editrow ( )
event ue_sendemail ( )
integer y = 108
integer width = 4320
integer height = 872
string dataobject = "d_contact_list_by_application"
string is_updatesallowed = ""
end type

event dw_1::ue_editrow();
Long ll_row, ll_contactID, ll_rc
str_contactparms lstr_parms

ll_contactID = dw_1.GetItemNumber(dw_1.GetRow(), "contact_id")

lstr_parms.str_contactid = ll_contactID

lstr_parms.str_gigpid =  gl_gigp_id

OpenWithParm(w_contacts_edit, lstr_parms)

ll_contactID = Message.DoubleParm

If (ll_contactID = -1) Then Return

ll_rc = dw_1.of_Retrieve()

end event

event dw_1::ue_sendemail();
of_sendemail()
end event

event dw_1::constructor;call super::constructor;
//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)

//********************************************************************
// Start PFC Sort Service:
//********************************************************************

This.of_SetSort(True)
This.inv_sort.of_SetColumnHeader(TRUE)

This.ib_RMBMenu = False

//This.Object.DataWindow.ReadOnly="Yes"
end event

event dw_1::pfc_print;
//OverRide//

Return dw_2.Event pfc_print()


end event

event dw_1::pfc_retrieve;
//OverRide//

//*******************************************************
// Retrieve Contacts linked to thisapplication:
//*******************************************************

Return This.Retrieve(gl_gigp_id)
end event

event dw_1::rowfocuschanged;call super::rowfocuschanged;
Long ll_contactID

If (currentrow < 1) Then
	
	dw_2.Reset()
Else
	ll_contactID = This.GetItemNumber(currentrow, "contact_id")
	dw_2.Retrieve(ll_contactID)
	dw_3.Retrieve(ll_contactID, gl_gigp_id)
End If
end event

event dw_1::pfc_insertrow;//OverRide//
Long ll_row, ll_contactID
str_contactparms lstr_parms


//If MessageBox('New Contact', 'Please make sure that you searched to see if this Contact already exists.  Do you want to continue?', Question!, YesNoCancel!) = 1 Then
//
//	lstr_parms.str_contactid = -1
//	
//	lstr_parms.str_gigpid =  gl_gigp_id
//	
//	OpenWithParm(w_contacts_edit,lstr_parms)
//	
//	ll_contactID = Message.DoubleParm
//	
//	If (ll_contactID = -1) Then Return 1
//	
//	is_newContID = String(ll_contactID)
//	
//	dw_1.of_Retrieve()
//	
//End If

Open(w_find_contact)

this.Event pfc_retrieve()

Return 1
end event

event dw_1::pfc_deleterow;
//overRide//

//*************************************************************
// Delete contact thru contact manager only
//*************************************************************

Return 1
end event

event dw_1::itemchanged;call super::itemchanged;
Post of_set_notmodified(row)




end event

event dw_1::retrieveend;call super::retrieveend;

If (rowcount < 1) Then Return

of_retrieve_contacttypes()
end event

event dw_1::doubleclicked;call super::doubleclicked;
If ib_editaccess Then
	this.Event ue_editrow()
End If
end event

type dw_2 from u_dw within u_tabpg_contacts
event ue_sendemail ( )
event ue_editrow ( )
integer x = 800
integer y = 992
integer width = 3529
integer height = 1356
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_contacts_master_detail"
boolean hscrollbar = true
boolean ib_isupdateable = false
boolean ib_rmbmenu = false
end type

event ue_sendemail();
of_sendemail()
end event

event ue_editrow();//Trigger EditRow on the parent Datawindow  SW, 8/2/2010
dw_1.Event ue_editrow()
end event

event buttonclicked;call super::buttonclicked;
String 	ls_Text
Integer	li_RC

//*******************************************************
// Notes are Read-Only. Must Edit thru Mgmt. Screen:
//*******************************************************

If (dwo.Name = "b_edit") Then	
	
	ls_Text = This.GetItemString(row, "comments")	
	
	li_RC = f_edit_notes("READ", ls_Text)		
	
End If
end event

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False

This.Object.DataWindow.ReadOnly="Yes"
end event

event pfc_print;
//OverRide//

Return dw_2.Print()
end event

event pfc_insertrow;call super::pfc_insertrow;
//OverRide//

Return dw_1.Event pfc_InsertRow()
end event

event pfc_deleterow;
//OverRide//

Return dw_1.Event pfc_DeleteRow()
end event

type rb_all from radiobutton within u_tabpg_contacts
integer x = 251
integer y = 24
integer width = 174
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
string text = "ALL"
boolean checked = true
end type

event clicked;
of_filter("ALL")
end event

type rb_vendors from radiobutton within u_tabpg_contacts
integer x = 1125
integer y = 24
integer width = 334
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
string text = "Vendors"
end type

event clicked;
of_filter("Vendor")
end event

type rb_efc from radiobutton within u_tabpg_contacts
integer x = 507
integer y = 24
integer width = 174
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
string text = "EFC"
end type

event clicked;
of_filter("EFC")
end event

type st_filter from statictext within u_tabpg_contacts
integer x = 37
integer y = 24
integer width = 169
integer height = 56
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 32768
long backcolor = 67108864
string text = "Filter:"
alignment alignment = right!
boolean focusrectangle = false
end type

type rb_1 from radiobutton within u_tabpg_contacts
integer x = 763
integer y = 24
integer width = 334
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
string text = "NON-EFC"
end type

event clicked;
of_filter("NONEFC")
end event

type dw_3 from u_dw within u_tabpg_contacts
integer x = 5
integer y = 992
integer width = 782
integer height = 1356
integer taborder = 11
boolean bringtotop = true
string title = "Contact Types"
string dataobject = "d_contacttypes_by_contact_project2"
boolean hscrollbar = true
string icon = "UserObject5!"
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False

end event

type cb_addcfa from commandbutton within u_tabpg_contacts
integer x = 1586
integer y = 12
integer width = 453
integer height = 80
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Add from CFA"
end type

event clicked;Open(w_cfa_contact_match)

parent.of_retrieve()
end event

