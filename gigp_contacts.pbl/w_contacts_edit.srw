forward
global type w_contacts_edit from w_gigp_response
end type
type dw_2 from u_dw within w_contacts_edit
end type
type dw_1 from u_dw within w_contacts_edit
end type
type shl_1 from statichyperlink within w_contacts_edit
end type
type shl_2 from statichyperlink within w_contacts_edit
end type
type dw_4 from u_dw within w_contacts_edit
end type
type shl_5 from statichyperlink within w_contacts_edit
end type
type shl_6 from statichyperlink within w_contacts_edit
end type
type st_1 from statictext within w_contacts_edit
end type
type gb_2 from groupbox within w_contacts_edit
end type
type gb_4 from groupbox within w_contacts_edit
end type
type gb_1 from groupbox within w_contacts_edit
end type
end forward

global type w_contacts_edit from w_gigp_response
integer width = 3657
integer height = 2572
string title = "Contact Data Entry"
event pfc_insertrow ( )
dw_2 dw_2
dw_1 dw_1
shl_1 shl_1
shl_2 shl_2
dw_4 dw_4
shl_5 shl_5
shl_6 shl_6
st_1 st_1
gb_2 gb_2
gb_4 gb_4
gb_1 gb_1
end type
global w_contacts_edit w_contacts_edit

type variables

Long il_contactID, il_gigpID
end variables

forward prototypes
public subroutine of_build_fullname ()
public subroutine of_build_salutation ()
public subroutine of_edit_notes ()
public subroutine of_set_last_updated ()
end prototypes

public subroutine of_build_fullname ();
//*************************************************************
// Prefix & Suffix removed from Full Name (02/22/2010 mpf).
//*************************************************************

String ls_fullName, ls_fName, ls_mInit, ls_lName

dw_1.AcceptText()

ls_fName  	= dw_1.GetItemString(1, "first_name")
ls_mInit  	= dw_1.GetItemString(1, "mid_initial")
ls_lName  	= dw_1.GetItemString(1, "last_name")

If IsNull(ls_fName) 	Then ls_fName  = ""

ls_fullName += ( " " + ls_fName)

ls_fullName = Trim(ls_fullName)

If (IsNull(ls_mInit) Or Trim(ls_mInit) = "") Then
	//Skip
Else	
	ls_fullName += ( " " + ls_mInit + ".")
End If

If IsNull(ls_lName) 	Then ls_lName  = ""

ls_fullName += ( " " + ls_lName)

Trim(ls_fullName)

If (ls_fullName <> "") Then dw_1.SetItem(1, "full_name", ls_fullName)



end subroutine

public subroutine of_build_salutation ();
//*************************************************************
// Salutation Name switched to Formal Name (02/22/2010 mpf).
//*************************************************************

String ls_formalName, ls_prefix, ls_fName, ls_mInit, ls_lName, ls_suffix

dw_1.AcceptText()

ls_prefix 	= dw_1.GetItemString(1, "prefix")
ls_fName  	= dw_1.GetItemString(1, "first_name")
ls_mInit  	= dw_1.GetItemString(1, "mid_initial")
ls_lName  	= dw_1.GetItemString(1, "last_name")
ls_suffix	= dw_1.GetItemString(1, "suffix")

If Not IsNull(ls_prefix)	Then ls_formalName = Trim(ls_prefix)

If IsNull(ls_fName) 	Then ls_fName  = ""

ls_formalName += ( " " + ls_fName)

ls_formalName = Trim(ls_formalName)

If (IsNull(ls_mInit) Or Trim(ls_mInit) = "") Then
	//Skip
Else	
	ls_formalName += ( " " + ls_mInit + ".")
End If

If IsNull(ls_lName) 	Then ls_lName  = ""

ls_formalName += ( " " + ls_lName)

If Not IsNull(ls_suffix) Then ls_formalName += (" " + ls_suffix)

Trim(ls_formalName)

If (ls_formalName <> "") Then dw_1.SetItem(1, "salutation_name", ls_formalName)
end subroutine

public subroutine of_edit_notes ();
String 		ls_text
Long			ll_row, ll_mwbeID
str_notes	lstr_notes

////************************************************
//// Edit existing note entry:
////************************************************
//
//If (as_type <> "$NEW$") Then
//	
//	ll_row	= dw_1.GetRow()		
//	
//	lstr_notes.str_type = as_type
//	lstr_notes.str_text = dw_1.GetItemString(ll_row, "notes")
//
//Else
//	
////************************************************
//// Create a New note entry:
////************************************************	
//	
//	lstr_notes.str_type = as_type
//		
//End If
//
////************************************************
//// Open Notes reponse window to view / edit:
////************************************************	
//
//OpenWithParm(w_mwbe_edit_notes, lstr_notes)
//
//ls_text = Message.StringParm
//
//If (ls_text = "$CANCEL$") Then		
//	Return
//End If	
//	
//If (as_type = "$NEW$") Then
//	
//	If (ls_text = "") or IsNull(ls_text) Then
//		MessageBox("ERROR!", "Nothing entered in the notes column!")
//		Return
//	Else
//		ll_row = dw_1.InsertRow(0)
//	
//		ll_mwbeID = it_Parent.iw_Parent.Function Dynamic of_get_mwbeID()
//	
//		dw_1.SetItem(ll_row, "mwbe_id", ll_mwbeID)	
//		dw_1.SetItem(ll_row, "note_dt", f_getdbdatetime())
//		dw_1.SetItem(ll_row, "user_id", gnv_app.of_getuserid())
//		dw_1.SetItem(ll_row, "notes"  , ls_text)
//		dw_1.AcceptText()
//	End If
//	
//Else
//	
//	If IsNull(lstr_notes.str_text)	Then lstr_notes.str_text = ""
//	If IsNull(ls_text) 					Then ls_text				 = ""
//	
//	If (lstr_notes.str_text <> ls_text) Then
//		dw_1.SetItem(ll_row, "note_dt", f_getdbdatetime())
//		dw_1.SetItem(ll_row, "notes"  , ls_text)	
//		dw_1.AcceptText()
//	End If
//	
//End If
//	
//dw_1.ScrollToRow(ll_row)
end subroutine

public subroutine of_set_last_updated ();
//*******************************************************
// Set the Last Updated by info:
//*******************************************************

dw_1.SetItem(dw_1.GetRow(), "last_updated_by", gnv_app.of_getuserid())
dw_1.SetItem(dw_1.GetRow(), "last_updated_dt",  f_getdbdatetime())


end subroutine

on w_contacts_edit.create
int iCurrent
call super::create
this.dw_2=create dw_2
this.dw_1=create dw_1
this.shl_1=create shl_1
this.shl_2=create shl_2
this.dw_4=create dw_4
this.shl_5=create shl_5
this.shl_6=create shl_6
this.st_1=create st_1
this.gb_2=create gb_2
this.gb_4=create gb_4
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_2
this.Control[iCurrent+2]=this.dw_1
this.Control[iCurrent+3]=this.shl_1
this.Control[iCurrent+4]=this.shl_2
this.Control[iCurrent+5]=this.dw_4
this.Control[iCurrent+6]=this.shl_5
this.Control[iCurrent+7]=this.shl_6
this.Control[iCurrent+8]=this.st_1
this.Control[iCurrent+9]=this.gb_2
this.Control[iCurrent+10]=this.gb_4
this.Control[iCurrent+11]=this.gb_1
end on

on w_contacts_edit.destroy
call super::destroy
destroy(this.dw_2)
destroy(this.dw_1)
destroy(this.shl_1)
destroy(this.shl_2)
destroy(this.dw_4)
destroy(this.shl_5)
destroy(this.shl_6)
destroy(this.st_1)
destroy(this.gb_2)
destroy(this.gb_4)
destroy(this.gb_1)
end on

event open;call super::open;
Long ll_row
str_contactparms lstr_parms

//il_contactID = Message.DoubleParm


lstr_parms = Message.PowerObjectParm

il_contactID = lstr_parms.str_contactid 
il_gigpID  = lstr_parms.str_gigpid 

If (il_contactID = -1) Then // New Contact
	
	//Insert new contact row
	
	ll_row = dw_1.InsertRow(0)
	
	il_contactID = f_gettokenvalue("contactID", 1)
	
	dw_1.SetItem(ll_row, "contact_id", il_contactID)
	
//	//Insert a stub contact link row
//	
//	ll_row = dw_2.InsertRow(0)
//	
//	dw_2.SetItem(ll_row, "contact_id", il_contactID)
//	dw_2.SetItemStatus(ll_row, 0, Primary!, NotModified!)
	
	
Else // Edit existing Contact
	
	dw_1.Retrieve(il_contactID)
	
	dw_2.Retrieve(il_contactID)
	dw_2.SetFilter("contact_type <> 'PLC'")	//Filter out Project Location Records
	dw_2.Filter()
	
	dw_4.Retrieve(il_contactID)
End If

//*******************************************************
// Adjust Contacts DW for Data Entry Screen:
//*******************************************************

dw_1.Modify("comments.Height=56")


end event

event pfc_preupdate;call super::pfc_preupdate;
String ls_value, ls_check

//*************************************************************
//
//*************************************************************

SetNull(ls_value)
ls_value = dw_1.GetItemString(1, "first_name")
If (Not IsNull(ls_value))  Then ls_check += ls_value
	
SetNull(ls_value)
ls_value = dw_1.GetItemString(1, "last_name")
If (Not IsNull(ls_value))  Then ls_check += ls_value
	
SetNull(ls_value)
ls_value = dw_1.GetItemString(1, "title")
If (Not IsNull(ls_value))  Then ls_check += ls_value

SetNull(ls_value)
ls_value = dw_1.GetItemString(1, "organization")
If (Not IsNull(ls_value))  Then ls_check += ls_value

SetNull(ls_value)
ls_value = dw_1.GetItemString(1, "mail_address1")
If (Not IsNull(ls_value))  Then ls_check += ls_value

SetNull(ls_value)
ls_value = dw_1.GetItemString(1, "mail_city")
If (Not IsNull(ls_value))  Then ls_check += ls_value

SetNull(ls_value)
ls_value = dw_1.GetItemString(1, "mail_state")
If (Not IsNull(ls_value))  Then ls_check += ls_value

SetNull(ls_value)
ls_value = dw_1.GetItemString(1, "mail_zip")
If (Not IsNull(ls_value))  Then ls_check += ls_value

If (Len(Trim(ls_check)) < 1) Then
	MessageBox("ERROR!", "Must enter some general contact information to continue!")
	Return -1
Else
	of_set_last_updated()	
End If

Return AncestorReturnValue
end event

event close;
//OverRide//

CloseWithReturn(This, il_contactID)
end event

event ue_process;call super::ue_process;//of_build_fullname()	

//of_build_salutation()
end event

type cb_cancel from w_gigp_response`cb_cancel within w_contacts_edit
integer x = 3232
integer y = 2360
end type

event cb_cancel::clicked;
//OverRide//

il_contactID = -1

Close(Parent)
end event

type cb_ok from w_gigp_response`cb_ok within w_contacts_edit
integer x = 2834
integer y = 2360
end type

event cb_ok::clicked;//Override
If dw_2.RowCount() = 0 Then
	If MessageBox('Contact Link', 'This Contact is not associated with any projects via the Contact Associations section of this page. Would you like to associate?', Exclamation!, YesNoCancel!, 1) = 1 Then
		Return
	End If
End If

is_action = "OK"

Parent.Event ue_process()

Close(Parent)
end event

type dw_2 from u_dw within w_contacts_edit
integer x = 64
integer y = 1512
integer width = 2464
integer height = 728
integer taborder = 20
string dataobject = "d_contacts_master_links"
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False

//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Contacts"}

//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)

this.of_SetDropDownSearch(TRUE)
this.inv_dropdownsearch.of_AddColumn("gigp_id")
end event

event pfc_postinsertrow;call super::pfc_postinsertrow;
//*******************************************************
// Set Contact ID:
//*******************************************************

This.SetItem(al_row, "contact_id", il_contactID)

If (il_gigpID <> 0) Then
	This.SetItem(al_row, "gigp_id", il_gigpID)
End If







end event

event sqlpreview;call super::sqlpreview;
Long ll_contactID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN
	
	ll_contactID = This.GetItemNumber(row, "contact_id", buffer, False)
	
	f_transactionlog("contact_id", ll_contactID, This.DataObject, "Contacts", sqlsyntax)
END IF
end event

event pfc_updateprep;call super::pfc_updateprep;
long 		ll_row, ll_count
String		ls_value

This.AcceptText()

ll_count = This.RowCount()

If (ll_count < 1) Then Return AncestorReturnValue

//*******************************************************
// Loop Thru DW and Validate user entry:
//*******************************************************

ll_row = This.GetNextModified(0, Primary!)

DO WHILE ll_row > 0
	
	ls_value = This.GetItemString(ll_row, "contact_type")	
	
		If IsNull(ls_value) Then
		Messagebox("ERROR!", "Contact Type Required!")
		Return -1
	End If	
	
	ll_row = This.GetNextModified(ll_row, Primary!)

LOOP

Return 1
end event

event editchanged;call super::editchanged;this.inv_dropdownsearch.Event pfc_EditChanged(row, dwo, data)
end event

event itemfocuschanged;call super::itemfocuschanged;this.inv_dropdownsearch.Event pfc_ItemFocusChanged(row, dwo)
end event

type dw_1 from u_dw within w_contacts_edit
integer x = 96
integer y = 148
integer width = 3461
integer height = 1192
integer taborder = 10
string dataobject = "d_contacts_master_detail"
boolean vscrollbar = false
boolean livescroll = false
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False

//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Contacts"}
end event

event itemchanged;call super::itemchanged;If row > 0 Then
	If this.GetItemStatus(row, 0, Primary!) <> NewModified! Then
		Choose Case dwo.name
			Case 'full_name', 'salutation_name', 'first_name', 'last_name'
				MessageBox('Conatct Edit Warning', "Do NOT change the contact here to another person by editing the name. This is only for updating the existing Contact's information")
				
		End Choose
				
	End If
	
End If
 



end event

event buttonclicked;call super::buttonclicked;String 	ls_Text
Integer	li_RC
Long		ll_row
n_ds		lds_print

Choose Case dwo.Name
	Case 'b_1'
		If NOT IsValid(lds_print) Then lds_print = CREATE n_ds
		
		lds_print.DataObject = 'd_envelopes_print'
		
		ll_row = lds_print.InsertRow(0)
		
		lds_print.SetItem(ll_row, 'prefix', this.GetItemString(row, 'prefix'))
		lds_print.SetItem(ll_row, 'full_name', this.GetItemString(row, 'full_name'))
		lds_print.SetItem(ll_row, 'title', this.GetItemString(row, 'title'))
		lds_print.SetItem(ll_row, 'organization_name', this.GetItemString(row, 'organization'))
		lds_print.SetItem(ll_row, 'address_line_1', this.GetItemString(row, 'mail_address1'))
		lds_print.SetItem(ll_row, 'address_line_2', this.GetItemString(row, 'mail_address2'))
		lds_print.SetItem(ll_row, 'address_line_3', this.GetItemString(row, 'mail_address3'))
		lds_print.SetItem(ll_row, 'city', this.GetItemString(row, 'mail_city'))
		lds_print.SetItem(ll_row, 'state', this.GetItemString(row, 'mail_state'))
		lds_print.SetItem(ll_row, 'zip', this.GetItemString(row, 'mail_zip'))
		
		lds_print.Event pfc_print()
		
	Case 'b_edit'
		ls_Text = This.GetItemString(row, "comments")	
	
		li_RC = f_edit_notes("EDIT", ls_Text)	
	
		If (li_RC = 1) Then This.SetItem(row, "comments", ls_Text)	
		
	Case 'b_fncalc'
		Post of_build_fullname()	
		
	Case 'b_sncalc'
		Post of_build_salutation()
		
	Case 'b_envelope'
		
		If NOT IsValid(lds_print) Then lds_print = CREATE n_ds
		
		lds_print.DataObject = 'd_envelopes_print'
		
		ll_row = lds_print.InsertRow(0)
		
		lds_print.SetItem(ll_row, 'prefix', this.GetItemString(row, 'prefix'))
		lds_print.SetItem(ll_row, 'full_name', this.GetItemString(row, 'full_name'))
		lds_print.SetItem(ll_row, 'title', this.GetItemString(row, 'title'))
		lds_print.SetItem(ll_row, 'organization_name', this.GetItemString(row, 'organization'))
		lds_print.SetItem(ll_row, 'address_line_1', this.GetItemString(row, 'mail_address1'))
		lds_print.SetItem(ll_row, 'address_line_2', this.GetItemString(row, 'mail_address2'))
		lds_print.SetItem(ll_row, 'address_line_3', this.GetItemString(row, 'mail_address3'))
		lds_print.SetItem(ll_row, 'city', this.GetItemString(row, 'mail_city'))
		lds_print.SetItem(ll_row, 'state', this.GetItemString(row, 'mail_state'))
		lds_print.SetItem(ll_row, 'zip', this.GetItemString(row, 'mail_zip'))
		
		lds_print.Event pfc_print()
	
		
End Choose

end event

event sqlpreview;call super::sqlpreview;
Long ll_contactID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN
	
	ll_contactID = This.GetItemNumber(row, "contact_id", buffer, False)
	
	f_transactionlog("contact_id", ll_contactID, This.DataObject, "Contacts", sqlsyntax)
END IF
end event

event pfc_updateprep;call super::pfc_updateprep;Long 	ll_row, ll_gigpID

//*******************************************************
// Loop thru modified rows:
//*******************************************************

ll_row	= dw_1.GetNextModified(0, Primary!)

DO WHILE ll_row > 0	
	
	//*******************************************************
	// If new row, Set modified values:
	//*******************************************************
	This.SetItem(ll_row, "last_updated_by", gnv_app.of_getuserid())
	This.SetItem(ll_row, "last_updated_dt", f_getdbdatetime())		

	ll_row = dw_1.GetNextModified(ll_row, Primary!)

LOOP

Return AncestorReturnValue
end event

type shl_1 from statichyperlink within w_contacts_edit
integer x = 1893
integer y = 2256
integer width = 311
integer height = 56
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 32768
long backcolor = 67108864
string text = "Insert Row"
boolean focusrectangle = false
end type

event clicked;
dw_2.Event pfc_InsertRow()
end event

type shl_2 from statichyperlink within w_contacts_edit
integer x = 2235
integer y = 2256
integer width = 293
integer height = 56
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 32768
long backcolor = 67108864
string text = "Delete Row"
boolean focusrectangle = false
end type

event clicked;
dw_2.Event pfc_deleterow()
end event

type dw_4 from u_dw within w_contacts_edit
event ue_filter_districts ( long al_row )
integer x = 2619
integer y = 1512
integer width = 933
integer height = 728
integer taborder = 40
boolean bringtotop = true
string dataobject = "d_political_districts"
end type

event ue_filter_districts(long al_row);
String ls_Filter, ls_refCode

DataWindowChild ldwc_districts

This.GetChild('district_no', ldwc_districts)

ls_refCode = This.GetItemString(al_row, 'district_type')

ls_filter = "category = '" + ls_refCode + "'"


ldwc_districts.SetFilter(ls_Filter)
ldwc_districts.Filter()
ldwc_districts.Sort()


end event

event itemchanged;call super::itemchanged;

If (dwo.Name = 'district_type') Then
	This.Event Post ue_filter_districts(row)
End If
end event

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False

//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Contacts"}

//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)
end event

event pfc_postinsertrow;call super::pfc_postinsertrow;Long ll_find
Integer li_census
DataWindowChild	ldwc

//*******************************************************
// Set Contact ID & Default District type:
//*******************************************************
select convert(integer, ref_code)
into :li_census
from gigp_reference
where category = 'CensusYr';

This.SetItem(al_row, 'census_yr', li_census)

This.SetItem(al_row, "contact_id", il_contactID)
This.SetItem(al_row, "district_type", 'usCongress')

This.GetChild('district_type', ldwc)

ll_find = ldwc.Find("ref_code =  'usCongress'", 1, ldwc.RowCount())
 
 If ll_find > 0 Then
  ldwc.ScrollToRow(ll_find)
 End If

end event

event sqlpreview;call super::sqlpreview;
Long ll_contactID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN
	
	ll_contactID = This.GetItemNumber(row, "contact_id", buffer, False)
	
	f_transactionlog("contact_id", ll_contactID, This.DataObject, "PoliticalDistricts", sqlsyntax)
END IF
end event

event rowfocuschanged;call super::rowfocuschanged;
If (currentrow > 0) Then
	This.Event Post ue_filter_districts(currentrow)
End If
end event

event pfc_updateprep;call super::pfc_updateprep;
long 		ll_row, ll_count
String		ls_code,  ls_value

This.AcceptText()

ll_count = This.RowCount()

If (ll_count < 1) Then Return AncestorReturnValue

//*******************************************************
// Loop Thru DW and Validate user entry:
//*******************************************************

ll_row = This.GetNextModified(0, Primary!)

DO WHILE ll_row > 0
	
	//Must have a District Number:
	
	ls_code = This.GetItemString(ll_row, "district_type")	
	ls_value = String(This.GetItemNumber(ll_row, "district_no"))
	
	If IsNull(ls_value) Or (ls_value = "") Then
		Messagebox("ERROR!", "District Number Required!")
		Return -1
	End If	
		
	//Must be a Valid District Number based on District Type:	
		
	Select Count(*)
	Into :ll_count
	From gigp_reference 
	where category = :ls_code
	And	ref_value = :ls_value
	And sub_category = 'District';
	
	If (ll_count < 1) Then
		Messagebox("ERROR!", "District Number is not Valid!")
		Return -1
	End If	
	
	ls_code = ""
	ls_value = ""
	ll_count = 0
	
	ll_row = This.GetNextModified(ll_row, Primary!)

LOOP

Return 1
end event

type shl_5 from statichyperlink within w_contacts_edit
integer x = 3269
integer y = 2256
integer width = 293
integer height = 56
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 32768
long backcolor = 67108864
string text = "Delete Row"
boolean focusrectangle = false
end type

event clicked;
dw_4.Event pfc_deleterow()
end event

type shl_6 from statichyperlink within w_contacts_edit
integer x = 2926
integer y = 2256
integer width = 311
integer height = 56
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 32768
long backcolor = 67108864
string text = "Insert Row"
boolean focusrectangle = false
end type

event clicked;
dw_4.Event pfc_InsertRow()
end event

type st_1 from statictext within w_contacts_edit
integer x = 96
integer y = 8
integer width = 3461
integer height = 72
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 65535
long backcolor = 255
string text = "DO NOT UPDATE CONTACT INFORMATION TO A DIFFERENT PERSON HERE - Use Contact Associations to assign a different Contact"
alignment alignment = center!
boolean focusrectangle = false
end type

type gb_2 from groupbox within w_contacts_edit
integer x = 37
integer y = 84
integer width = 3566
integer height = 1296
integer taborder = 20
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
string text = "Contact Information:"
end type

type gb_4 from groupbox within w_contacts_edit
integer x = 37
integer y = 1416
integer width = 2528
integer height = 920
integer taborder = 40
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
string text = "Contact Associations:"
end type

type gb_1 from groupbox within w_contacts_edit
integer x = 2578
integer y = 1416
integer width = 1024
integer height = 920
integer taborder = 40
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 67108864
string text = "Legislative Districts"
end type

