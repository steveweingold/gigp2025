forward
global type w_call_log from w_master_detail_sm
end type
type dw_category from u_dw_enhanced within w_call_log
end type
type shl_insert_proj from statichyperlink within w_call_log
end type
type shl_insert_log from statichyperlink within w_call_log
end type
type shl_delete_log from statichyperlink within w_call_log
end type
type cb_email from commandbutton within w_call_log
end type
type st_1 from statictext within w_call_log
end type
type st_calls from statictext within w_call_log
end type
type cb_call_stack from commandbutton within w_call_log
end type
type st_2 from statictext within w_call_log
end type
type st_3 from statictext within w_call_log
end type
type st_phone1 from statictext within w_call_log
end type
type st_org from statictext within w_call_log
end type
type gb_1 from groupbox within w_call_log
end type
type gb_call_log from groupbox within w_call_log
end type
type gb_projects from groupbox within w_call_log
end type
end forward

global type w_call_log from w_master_detail_sm
string tag = "GIGP Call Log"
integer width = 2898
integer height = 1520
string title = "GIGP Call Log for "
string menuname = "m_gigp_sheet"
boolean minbox = false
windowstate windowstate = maximized!
boolean center = true
dw_category dw_category
shl_insert_proj shl_insert_proj
shl_insert_log shl_insert_log
shl_delete_log shl_delete_log
cb_email cb_email
st_1 st_1
st_calls st_calls
cb_call_stack cb_call_stack
st_2 st_2
st_3 st_3
st_phone1 st_phone1
st_org st_org
gb_1 gb_1
gb_call_log gb_call_log
gb_projects gb_projects
end type
global w_call_log w_call_log

type variables
long il_ContactId, il_CallLogId
boolean ib_cat_changed = False
string is_title
end variables

forward prototypes
public function integer of_set_category (string as_list)
public function string of_get_category ()
public subroutine of_sendemail ()
end prototypes

public function integer of_set_category (string as_list);long ll_length, ll_find, ll_index
string ls_list[], ls_code, ls_find
n_cst_string ln_string

//Reset the datawindow
dw_category.Reset()
dw_category.Retrieve()

//If a list of codes was passed in then set them
If as_list > '' Then
	//Parse to array
	ln_string.of_ParseToArray(as_list, ',', ls_list)
	
	ll_length = UpperBound(ls_list)
	
	For ll_index = 1 to ll_length
		//Find the code 
		ls_find = "ref_code = '" + ls_list[ll_index] + "'"
		ll_find = dw_category.Find(ls_find, 1, dw_category.RowCount() )
		If ll_find > 0 Then
			dw_category.SetItem(ll_find, 'checked', 1)
			
			//Handle if OTHER
			If ls_list[ll_index] = 'OTHER' Then
				dw_category.SetItem(ll_find, 'other_value', ls_list[ll_index + 1])
				
			End If
			
		End If
	Next
	
End If

Return 1
end function

public function string of_get_category ();string ls_category, ls_list[], ls_code, ls_other
long ll_count, ll_row, ll_index, ll_checked
n_cst_string ln_string

ll_index = 0

//Loop through each row and get the ones that are checked
ll_count = dw_category.RowCount()

For ll_row = 1 to ll_count
	ll_checked = dw_category.GetItemNumber(ll_row, 'checked')
	
	If ll_checked = 1 Then
		ll_index++
		
		ls_code = dw_category.GetitemString(ll_row, 'ref_code')

		ls_list[ll_index] = ls_code
		
		//Handle if OTHER
		If ls_code = 'OTHER' Then
			ll_index++
			ls_other = dw_category.GetItemString(ll_row, 'other_value')
			If IsNull(ls_other) or ls_other = '' Then 
				ls_other = '[none]'
			End If
			ls_list[ll_index] = ls_other
			
		End If
		
	End If
	
Next

If ll_index > 0 Then
	ln_string.of_ArrayToString(ls_list, ',', ls_category)
End If

Return ls_category
end function

public subroutine of_sendemail ();Integer li_rc, li_emailFlag
Long ll_row, ll_rowCnt
String ls_Msg, ls_URL, ls_MailTo,  ls_Subject = "GIGP", ls_email, ls_contact, ls_body, ls_date, ls_org, ls_phone, ls_notes, ls_cat, ls_value, ls_source, ls_source_desc
n_cst_iexplorer_srv	lnv_iexplorer

//Make sure a row has been selected
If dw_master.GetRow() <= 0 Then
	MessageBox(this.title, 'Please select a Call Log to email.')
	Return 
End If

// Build URL for sending mail
ls_URL = "mailto:" + ls_MailTo + "?"

//Subject
If NOT IsNull(il_contactid) and il_contactid > 0 Then
	select full_name, organization, phone_1
	into :ls_contact, :ls_org, :ls_phone
	from gigp_contacts
	where contact_id = :il_contactid;
ElseIf	il_contactid = 0 Then
	ls_contact = '[No Contact]'
	ls_org = '[None]'
	ls_phone = '[None]'
	
Else
	ls_contact = '[unknown]'
	ls_org = '[unknown]'
	ls_phone = '[unknown]'
End If

If IsNull(ls_contact) or ls_contact = '' Then ls_contact = '[unknown]'
If IsNull(ls_org) or ls_org = '' Then ls_org = '[unknown]'
If IsNull(ls_phone) or ls_phone = '' Then ls_phone = '[unknown]'

If il_contactid > 0 Then
	If ls_phone <> '[unknown]' Then ls_phone = Trim(String(ls_phone, '(@@@) @@@-@@@@@@@@@@@@@@@@@@@'))
End If
	
ls_Subject = 'GIGP Call Log for ' + ls_contact
 
If ls_Subject > '' Then
 ls_URL = ls_URL + 'subject=' + ls_Subject
End If

//get categories
ll_rowCnt = dw_category.RowCount()
ls_cat = ''
If ll_rowCnt > 0 Then
	For ll_row = 1 to ll_rowCnt
		If dw_category.GetItemNumber(ll_row, 'checked') = 1 Then
			ls_value = dw_category.GetItemString(ll_row, 'ref_value')
			If Upper(ls_value) = 'OTHER:' Then
				ls_value = dw_category.GetItemString(ll_row, 'other_value')
			End If
			
			If ls_cat = '' Then
				ls_cat = ls_value
			Else
				ls_cat += ', ' + ls_value
			End If
		End If
	Next
End If

If IsNull(ls_cat) or ls_cat = '' Then ls_cat = '[not specified]'


//Body
ll_row = dw_master.GetRow()
If ll_row > 0 Then
	ls_date = String(dw_master.GetItemDateTime(ll_row, 'call_dt'), 'mm/dd/yyyy')
	ls_notes = dw_master.GetItemString(ll_row, 'call_notes')
	ls_source = dw_master.GetItemString(ll_row, 'call_source')
	
	If IsNull(ls_source) or ls_source = '' Then
		ls_source_desc = '[unknown]'
	Else
		select ref_value
		into :ls_source_desc
		from gigp_reference
		where category = 'call_log_source'
		and ref_code = :ls_source;
	End If
	
	If IsNull(ls_source_desc) Then ls_source_desc = '[unknown]'
	
Else
	ls_date = '[date?]'
End If

If IsNull(ls_date) or ls_date = '' Then ls_date = '[unknown]'
If IsNull(ls_notes) Then ls_notes = ''

//Email will blow up if too long
If Len(ls_notes) > 1000 Then
	ls_notes = Left(ls_notes, 1000) + '... [see Call Log for rest of Notes]'
End If
		
ls_body = ' &body=A call log was entered in GIGP for ' + ls_contact + ' (Contact Id = ' + String(il_contactid) + ') from ' + ls_org + ' via '+ ls_source_desc  + ' on ' + ls_date + ' regarding ' + ls_cat + ' that requires your attention.  This person can be reached at ' + ls_phone + '.  Notes from the log are:  ' + ls_notes

If ls_body > '' Then
	ls_URL += ls_body
End If

// Connect to IE
If Not IsValid(lnv_iexplorer) Then
	lnv_iexplorer = Create n_cst_iexplorer_srv
End If

li_rc = lnv_iexplorer.of_Connect()
If li_rc <> 1 Then Return

// Execute URL
li_rc = lnv_iexplorer.of_LinkToURL(ls_URL, False)



end subroutine

on w_call_log.create
int iCurrent
call super::create
if this.MenuName = "m_gigp_sheet" then this.MenuID = create m_gigp_sheet
this.dw_category=create dw_category
this.shl_insert_proj=create shl_insert_proj
this.shl_insert_log=create shl_insert_log
this.shl_delete_log=create shl_delete_log
this.cb_email=create cb_email
this.st_1=create st_1
this.st_calls=create st_calls
this.cb_call_stack=create cb_call_stack
this.st_2=create st_2
this.st_3=create st_3
this.st_phone1=create st_phone1
this.st_org=create st_org
this.gb_1=create gb_1
this.gb_call_log=create gb_call_log
this.gb_projects=create gb_projects
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_category
this.Control[iCurrent+2]=this.shl_insert_proj
this.Control[iCurrent+3]=this.shl_insert_log
this.Control[iCurrent+4]=this.shl_delete_log
this.Control[iCurrent+5]=this.cb_email
this.Control[iCurrent+6]=this.st_1
this.Control[iCurrent+7]=this.st_calls
this.Control[iCurrent+8]=this.cb_call_stack
this.Control[iCurrent+9]=this.st_2
this.Control[iCurrent+10]=this.st_3
this.Control[iCurrent+11]=this.st_phone1
this.Control[iCurrent+12]=this.st_org
this.Control[iCurrent+13]=this.gb_1
this.Control[iCurrent+14]=this.gb_call_log
this.Control[iCurrent+15]=this.gb_projects
end on

on w_call_log.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.dw_category)
destroy(this.shl_insert_proj)
destroy(this.shl_insert_log)
destroy(this.shl_delete_log)
destroy(this.cb_email)
destroy(this.st_1)
destroy(this.st_calls)
destroy(this.cb_call_stack)
destroy(this.st_2)
destroy(this.st_3)
destroy(this.st_phone1)
destroy(this.st_org)
destroy(this.gb_1)
destroy(this.gb_call_log)
destroy(this.gb_projects)
end on

event open;call super::open;m_gigp_sheet lm_sheet

this.WindowState = Maximized!

//Modify Menu
lm_sheet = this.MenuId
lm_sheet.m_file.m_save.Visible = True
lm_sheet.m_file.m_save.ToolBarItemVisible = True
lm_sheet.m_file.m_save.ToolBarItemOrder = 98

//Security
If NOT gnv_app.of_ingroup('Contacts') and NOT gnv_app.of_ingroup('TAS-Global') Then
	lm_sheet.m_file.m_save.Enabled = False
	shl_insert_log.Enabled = False
	shl_delete_log.Enabled = False
	shl_insert_proj.Enabled = False
	dw_master.object.datawindow.readonly = 'Yes'
	dw_detail.object.datawindow.readonly = 'Yes'
	dw_category.object.datawindow.readonly = 'Yes'
	cb_email.Enabled = False
	
End If

//Register master / detail columns
is_Master_Columns[1] = 'call_log_id'
is_Detail_Columns[1] = 'call_log_id'

// Turn on resize service.	//
this.of_SetResize(True)

// Call of_SetOrigSize in case this wasn't opened with 	//
// size = Original!.													//
this.inv_Resize.of_Register(dw_category,"FixedToRight&ScaleToBottom")
this.inv_Resize.of_Register(gb_call_log,"ScaleToRight&Bottom")
//this.inv_Resize.of_Register(dw_master,"ScaleToRight")
this.inv_Resize.of_Register(gb_projects,"FixedToBottom&ScaleToRight")
//this.inv_Resize.of_Register(dw_detail,"ScaleToRight&Bottom")
this.inv_Resize.of_Register(shl_insert_log,"FixedToBottom")
this.inv_Resize.of_Register(shl_delete_log,"FixedToBottom")
this.inv_Resize.of_Register(shl_insert_proj,"FixedToBottom")



//Get the passed in contact id if there is one
il_ContactId = Message.DoubleParm

If IsNull(il_ContactId) Then il_ContactId = 0


is_master_name = 'Call Log'
is_detail_name = 'Associated Projects'
is_title = this.Title
end event

event resize;call super::resize;integer li_x

dw_master.Object.call_notes.Width = newwidth - 3225
dw_master.Object.call_notes_t.Width = newwidth - 3225
dw_master.Object.b_notes.x = Integer(dw_master.Object.call_notes.x) + Integer(dw_master.Object.call_notes.Width) + 15

end event

event pfc_postopen;call super::pfc_postopen;long ll_find
datawindowchild ldwc
dwobject ldwobj

//If a contact id was passed in, then set it to the dropdown selector and trigger the change
If il_ContactId > 0 Then
	dw_1.SetItem(dw_1.GetRow(), 'contact_id', il_ContactId)
	
	dw_1.GetChild('contact_id', ldwc)
	
	ll_find = ldwc.Find('contact_id = ' + string(il_ContactId), 1, ldwc.RowCount())

	If ll_find > 0 Then
		ldwc.ScrollToRow(ll_find)
	End If
	
	ldwobj = dw_1.Object.contact_id
	
	dw_1.Event Post ItemChanged(1, ldwobj, string(il_ContactId))
	
End If

dw_detail.SetRowFocusIndicator(Off!)


end event

event pfc_save;//Override

dw_category.AcceptText()

//If the call categories were changed then get the new list
If ib_cat_changed Then
	ib_cat_changed = False
	dw_master.SetItem(dw_master.GetRow(), 'call_category', this.of_get_category())
End If

call super::pfc_save

Return 1
end event

event activate;call super::activate;long ll_count

//Reset the Incoming Call Log count
select count(*)
into :ll_count
from gigp_call_log
where call_direction = 'I';

If ll_count >= 0 Then
	st_calls.Text = String(ll_count)
End If
end event

type dw_master from w_master_detail_sm`dw_master within w_call_log
integer x = 78
integer y = 328
integer width = 1778
integer height = 220
string dataobject = "d_call_log_detail"
boolean vscrollbar = true
borderstyle borderstyle = stylebox!
end type

event dw_master::rowfocuschanged;call super::rowfocuschanged;string ls_category

If currentrow > 0 Then
	
	il_CallLogId = this.GetItemNumber(currentrow, 'call_log_id')
	ls_category = this.GetItemString(currentrow,'call_category')
	
	parent.Post of_set_category(ls_category)
	dw_detail.Event Post pfc_retrieve()
	
End If


end event

event dw_master::constructor;call super::constructor;//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)
end event

event dw_master::pfc_preupdate;call super::pfc_preupdate;long ll_count, ll_row
datetime ldt_today

//Handle Audit Columns
ll_count = this.RowCount()

ldt_today = f_getdbdatetime()

For ll_row = 1 to ll_count
	If this.GetItemStatus(ll_row, 0, Primary!) = DataModified! or this.GetItemStatus(ll_row, 0, Primary!) = NewModified! Then
		this.SetItem(ll_row, 'last_updated_by', gnv_app.of_getuserid())
		this.SetItem(ll_row, 'last_updated_dt', ldt_today)
		
	End If
	
Next

Return 1
end event

event dw_master::rowfocuschanging;call super::rowfocuschanging;string ls_cat

If ib_cat_changed Then
	ib_cat_changed = False
	
	ls_cat = parent.of_get_category()
	
	this.SetItem(currentrow, 'call_category', ls_cat)
	
End If


end event

event dw_master::buttonclicked;call super::buttonclicked;string ls_notes, ls_notes_return
str_notes	lstr_notes

//Open Text Editor for Notes
If dwo.name = 'b_notes' Then
	this.AcceptText()
	
	//Get current notes
	ls_notes = this.GetItemString(row, 'call_notes')
	If IsNull(ls_notes) Then ls_notes = ''
	lstr_notes.str_text = ls_notes
	
	//Open the Editor
	OpenWithParm(w_edit_notes, lstr_notes)
	
	//Get the passed back text
	ls_notes_return = Message.StringParm
	
	//If text was modified then set it
	If ls_notes_return <> ls_notes and ls_notes_return <> '$CANCEL$' Then
		this.SetItem(row, 'call_notes', ls_notes_return)
	End If
	
End If
end event

event dw_master::rbuttondown;//Override


end event

event dw_master::rbuttonup;//Override


end event

event dw_master::itemchanged;call super::itemchanged;//If the call is outgoing, then set the complete flag to Yes
If dwo.name = 'call_direction' Then
	If data = 'O' Then
		this.SetItem(row, 'complete_flag', 1)
	End If
End If
end event

type dw_detail from w_master_detail_sm`dw_detail within w_call_log
integer x = 78
integer y = 784
integer width = 1778
integer height = 432
string dataobject = "d_call_log_proj"
boolean hsplitscroll = false
borderstyle borderstyle = stylebox!
boolean ib_isupdateable = false
end type

event dw_detail::pfc_retrieve;//Override
Return this.Retrieve(il_CallLogId)
end event

type dw_1 from w_master_detail_sm`dw_1 within w_call_log
integer x = 82
integer y = 104
integer width = 1111
integer height = 92
string dataobject = "d_call_log_contact_pick"
end type

event dw_1::itemchanged;call super::itemchanged;datawindowchild ldwc
string ls_phone1, ls_org

il_ContactId = Long(data)
SetNull(il_calllogId)

//Set phone info
If il_ContactId = 0 Then
	ls_phone1 = ''
	ls_org = ''
Else
	select phone_1, organization
	into :ls_phone1, :ls_org
	from gigp_contacts
	where contact_id = :il_ContactId;
	
	If IsNull(ls_phone1) or ls_phone1 = '' Then
		ls_phone1 = '[unknown]'
	Else
		ls_phone1 = Trim(String(ls_phone1, '(@@@) @@@-@@@@@@@@@@@@@@@@@@@'))
	End If
	
	If IsNull(ls_org) or ls_org = '' Then
		ls_org = '[unknown]'
	End If
	
End If

st_phone1.Text = ls_phone1
st_org.Text = ls_org

//Clear out the category
parent.of_set_category('')

//Handle detail rows and set the categories
If dw_master.RowCount() > 0 Then
	dw_master.SetFocus()
	dw_master.ScrollToRow(1)
	dw_master.SelectRow(1, True)
	il_calllogId = dw_master.GetItemNumber(1, 'call_log_id')
	parent.of_set_category(dw_master.GetItemString(1, 'call_category'))
	
	dw_detail.Event Post pfc_retrieve()
	
End If

//Set the window Title
this.GetChild('contact_id', ldwc)
parent.Title = is_title + ldwc.GetItemString(ldwc.GetRow(), 'full_name')
end event

type dw_category from u_dw_enhanced within w_call_log
integer x = 1925
integer y = 296
integer width = 905
integer height = 972
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_call_log_category"
boolean vscrollbar = false
boolean livescroll = false
boolean ib_isupdateable = false
end type

event pfc_retrieve;call super::pfc_retrieve;Return this.Retrieve()
end event

event constructor;call super::constructor;this.SetTransObject(SQLCA)
this.Event Post pfc_retrieve()
end event

event itemchanged;call super::itemchanged;ib_cat_changed = True

//Shift
If this.GetItemString(row, 'ref_code') = 'OTHER' Then
	If data = '1'  Then
		this.SetColumn('other_value')
	Else
		this.SetItem(row, 'other_value', '')
	End If
End If
end event

type shl_insert_proj from statichyperlink within w_call_log
integer x = 128
integer y = 1232
integer width = 699
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
string text = "Modify Associated Projects"
boolean focusrectangle = false
end type

event clicked;string ls_return, ls_gigp[]
integer li_count, li_index
long ll_gigp
n_cst_string ln_string

//Made sure a call log is selected
If IsNull(il_calllogid) or il_calllogid <= 0 Then
	MessageBox(parent.title, 'Please select or create a Call Log before choosing the associated Projects.')
	Return
End If

//Open the pick window for projects that the contact is related to
OpenWithParm(w_call_log_choose_proj, il_contactid)

//Get the returned 
ls_return = Message.StringParm

//Reset the Call_Log_Appl table
If ls_return <> 'CANCEL' Then
	//Delete the current set of projects if any
	delete gigp_call_log_appl
	where call_log_id = :il_calllogid;
	
	//Set new choices
	ln_string.of_ParseToArray(ls_return, ',', ls_gigp)
	
	li_count = UpperBound(ls_gigp)
	
	For li_index = 1 to li_count
		ll_gigp = Long(ls_gigp[li_index])
		
		insert into gigp_call_log_appl (gigp_id, call_log_id)
		values (:ll_gigp, :il_calllogid);
		
	Next
	
	dw_detail.Event pfc_retrieve()
	
End If
end event

type shl_insert_log from statichyperlink within w_call_log
integer x = 128
integer y = 568
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

event clicked;long ll_row

ll_row = dw_master.InsertRow(0)

If ll_row > 0 Then
	//Set Values
	dw_master.SetItem(ll_row, 'contact_id', long(ia_key))

	//Set Call_Log_Id, date, and user
	il_calllogid = f_gettokenvalue("CallLogId", 1)
	dw_master.SetItem(ll_row,'call_log_id', il_calllogid)
	dw_master.SetItem(ll_row, 'call_dt', DateTime(today(),Now()))
	dw_master.SetItem(ll_row, 'received_by', gnv_app.of_getuserid())
	dw_master.SetItem(ll_row, 'call_direction', 'I')
	dw_master.SetItem(ll_row, 'call_source', 'PHONE')
	dw_master.SetItem(ll_row, 'complete_flag', 0)
	
	//Scroll
	dw_master.ScrollToRow(ll_row)
	
	//Set Focus
	dw_master.SetFocus()

End If
end event

type shl_delete_log from statichyperlink within w_call_log
integer x = 471
integer y = 564
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
dw_master.Event pfc_deleterow()
end event

type cb_email from commandbutton within w_call_log
integer x = 1915
integer y = 92
integer width = 297
integer height = 100
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Email"
end type

event clicked;parent.of_sendemail()
end event

type st_1 from statictext within w_call_log
integer x = 2601
integer y = 112
integer width = 608
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
string text = "Incoming Calls To Date: "
boolean focusrectangle = false
end type

type st_calls from statictext within w_call_log
integer x = 3214
integer y = 112
integer width = 293
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
string text = "0"
boolean focusrectangle = false
end type

type cb_call_stack from commandbutton within w_call_log
integer x = 2254
integer y = 92
integer width = 297
integer height = 100
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Call Stack"
end type

event clicked;long ll_find
string ls_return
dwobject ldwobj
datawindowchild ldwc

//Open the call log stack pick window
Open(w_call_log_stack)

ls_return = Message.StringParm

//If the user did not cancel then set the selected contact to the window
If NOT IsNull(ls_return) Then
	il_contactId = Long(ls_return)
	
	dw_1.SetItem(dw_1.GetRow(), 'contact_id', il_ContactId)
	
	dw_1.GetChild('contact_id', ldwc)
	
	ll_find = ldwc.Find('contact_id = ' + string(il_ContactId), 1, ldwc.RowCount())

	If ll_find > 0 Then
		ldwc.ScrollToRow(ll_find)
	End If
	
	ldwobj = dw_1.Object.contact_id
	
	dw_1.Event Post ItemChanged(1, ldwobj, string(il_ContactId))
	
End If
end event

type st_2 from statictext within w_call_log
integer x = 1216
integer y = 80
integer width = 224
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
string text = "Phone:"
boolean focusrectangle = false
end type

type st_3 from statictext within w_call_log
integer x = 1216
integer y = 144
integer width = 114
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
string text = "Org:"
boolean focusrectangle = false
end type

type st_phone1 from statictext within w_call_log
integer x = 1435
integer y = 80
integer width = 439
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
boolean focusrectangle = false
end type

type st_org from statictext within w_call_log
integer x = 1349
integer y = 144
integer width = 526
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
boolean focusrectangle = false
end type

type gb_1 from groupbox within w_call_log
integer x = 41
integer y = 28
integer width = 1851
integer height = 196
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Contact"
end type

type gb_call_log from groupbox within w_call_log
integer x = 37
integer y = 260
integer width = 1851
integer height = 396
integer taborder = 20
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Call Log"
end type

type gb_projects from groupbox within w_call_log
integer x = 37
integer y = 696
integer width = 1851
integer height = 616
integer taborder = 30
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Associated Project(s)"
end type

