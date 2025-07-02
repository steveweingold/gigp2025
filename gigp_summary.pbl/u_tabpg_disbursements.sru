forward
global type u_tabpg_disbursements from u_tabpg_dbaccess
end type
type dw_2 from u_dw within u_tabpg_disbursements
end type
type shl_1 from statichyperlink within u_tabpg_disbursements
end type
type dw_delete from u_dw within u_tabpg_disbursements
end type
type dw_3 from u_dw within u_tabpg_disbursements
end type
type shl_bankinfo from statichyperlink within u_tabpg_disbursements
end type
type dw_bankinfo from u_dw within u_tabpg_disbursements
end type
type shl_3 from statichyperlink within u_tabpg_disbursements
end type
type dw_closeout from u_dw within u_tabpg_disbursements
end type
type cb_retrelltr from commandbutton within u_tabpg_disbursements
end type
type cb_redi_memo from commandbutton within u_tabpg_disbursements
end type
type cb_redi_letter from commandbutton within u_tabpg_disbursements
end type
end forward

global type u_tabpg_disbursements from u_tabpg_dbaccess
integer width = 3918
integer height = 2432
string text = "Disbursements"
string picturename = "Custom048!"
event pfc_deleterow ( )
dw_2 dw_2
shl_1 shl_1
dw_delete dw_delete
dw_3 dw_3
shl_bankinfo shl_bankinfo
dw_bankinfo dw_bankinfo
shl_3 shl_3
dw_closeout dw_closeout
cb_retrelltr cb_retrelltr
cb_redi_memo cb_redi_memo
cb_redi_letter cb_redi_letter
end type
global u_tabpg_disbursements u_tabpg_disbursements

type variables

Long il_newDisbursID
String is_origText
end variables

forward prototypes
public function integer of_generate_retainage_letter ()
public subroutine of_add_bookmark (ref oleobject document, string as_bookmark, string as_value)
public subroutine of_generateredimemo ()
public subroutine of_generaterediletter ()
public function integer of_setbankinfosecurity ()
end prototypes

event pfc_deleterow();long		ll_disburseID

ll_disburseID = dw_1.GetItemNumber(dw_1.GetRow(), "disbursement_id")

If NOT IsNull(ll_disburseID) Then
	If Messagebox('Delete', 'Are you sure you want to delete the selected disbursement?', Question!, YesNo!, 2) = 1 Then
		// Delete Disbursement:
		delete gigp_disbursement_amount 
		where disbursement_id = :ll_disburseID;
		
		delete gigp_disbursement_request
		where disbursement_id = :ll_disburseID;
		
		dw_1.Event pfc_retrieve()
			
	End If
	
Else
	MessageBox('Delete', 'Please select a Disbursement to delete')
End If
end event

public function integer of_generate_retainage_letter ();string ls_syntax, ls_sql, ls_name, ls_title, ls_organization, ls_applicant, ls_addr1, ls_addr2, ls_city, ls_state, ls_zip, ls_projno, error_syntaxfromSQL, errorCreate
string ls_cc, ls_letter, ls_bookMark, ls_project, ls_disbursement, ls_vendor, ls_amt, ls_category, ls_prefix, ls_last_name, ls_salutation, ls_date
long ll_count, ll_row, ll_ret, ll_authrep, ll_attorney
datetime ldt_date
integer li_rc
OLEObject lou_OLE
n_ds lds_disb

/************************
**  Confirm and get Data        **
************************/
//Make sure Retainage Release transaction exists
select count(*)
into :ll_count
from gigp_disbursement_amount
where transaction_type = 'RELRET'
and gigp_id = :gl_gigp_id;

If ll_count <= 0 Then
	MessageBox('Retainage Letter', 'No Release Retainage transactions exist for GIGP ' + String(gl_gigp_id))
	Return -1
End If

//Make sure Authorized Rep exists
select max(c.contact_id)
into :ll_authrep
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.gigp_id = :gl_gigp_id
and cl.contact_type = 'AUTHREP'
and c.status = 'Active';

If IsNull(ll_authrep) or ll_authrep <= 0 Then
	MessageBox('Retainage Letter', 'No Authorized Rep exists for GIGP ' + String(gl_gigp_id))
	Return -1
End If

//Get Local counsel for CC
select max(c.contact_id)
into :ll_attorney
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.gigp_id = :gl_gigp_id
and cl.contact_type = 'LOCCON'
and c.status = 'Active';

If IsNull(ll_attorney) or ll_attorney <= 0 Then
	ls_cc = ''
Else
	select full_name + ', ' + title
	into :ls_cc
	from gigp_contacts
	where contact_id = :ll_attorney;
End If

//Get Data
select full_name, title, organization, mail_address1, mail_address2, mail_city, mail_state, mail_zip, prefix, last_name
into :ls_name, :ls_title, :ls_organization, :ls_addr1, :ls_addr2, :ls_city, :ls_state, :ls_zip, :ls_prefix, :ls_last_name
from gigp_contacts
where contact_id = :ll_authrep;

ls_applicant = f_get_applicant_name(gl_gigp_id)
If IsNull(ls_prefix) then ls_prefix = ''
If IsNull(ls_last_name) then ls_last_name = ''

If ls_prefix > '' Then
	ls_salutation = ls_prefix + ' ' + ls_last_name
Else
	ls_salutation = ls_last_name
End If

If ls_salutation = '' Then ls_salutation = '[INSERT SALUTATION]'

select project_no, project_name
into :ls_projno, :ls_project
from gigp_application
where gigp_id = :gl_gigp_id;


select ref_value
into :ls_letter
from gigp_reference
where category = 'RetainageReleaseLetter'
and sub_category = 'TemplateLocation';

//*******************************************************
// Connect to MS Word:
//*******************************************************

lou_OLE = CREATE OLEObject

li_rc = lou_OLE.ConnectToObject('', 'Word.Application')

If (li_rc <> 0)  Then 	
	li_rc = lou_OLE.ConnectToNewObject('Word.Application')

	If (li_rc <> 0)  Then
		MessageBox("ERROR!", "Error opening Microsoft Word.")
		Return -1
	End If	
End If

lou_OLE.Documents.Add(ls_letter)



//*******************************************************
// Populate Bookmarks:  of_add_bookmark(lou_Ole, 'bookmark', 'value')
//*******************************************************
of_add_bookmark(lou_Ole, 'authrepname', ls_name)
of_add_bookmark(lou_Ole, 'authreptitle', ls_title)
of_add_bookmark(lou_Ole, 'authreporganization', ls_organization)

///////////////////////////////////////////////////////////////////////////
//Handle address by populating the address line 1 and then insert the rest after that
of_add_bookmark(lou_Ole, 'address', ls_addr1)

If NOT IsNull(ls_addr2) and ls_addr2 > '' Then
	lou_Ole.Selection.InsertParagraphAfter()	//Inserts a line break
	lou_Ole.Selection.InsertAfter(ls_addr2)  //Inserts the text after the last place 
End If

lou_Ole.Selection.InsertParagraphAfter()	//Inserts a line break
lou_Ole.Selection.InsertAfter(ls_city + ', ' + ls_state + '  ' + ls_zip)
///////////////////////////////////////////////////////////////////////////

of_add_bookmark(lou_Ole, 'recipient1', ls_applicant)
of_add_bookmark(lou_Ole, 'grantagreementdate', '[FILL IN DATE]')
of_add_bookmark(lou_Ole, 'gigpid', String(gl_gigp_id))
of_add_bookmark(lou_Ole, 'srfprojno', ls_projno)
of_add_bookmark(lou_Ole, 'salutation', ls_salutation)
of_add_bookmark(lou_Ole, 'projectname', ls_project)
of_add_bookmark(lou_Ole, 'recipient2', ls_applicant)

//Create Disbursement Amount line items and insert into bulleted list
//ls_sql = "select a.cost_category, c.organization, sum(disbursed_amt) as disb_total from gigp_disbursement_amount a, gigp_professional_contracts pc, gigp_contacts c where c.contact_id = pc.contact_id and pc.profess_contract_id = a.professional_contract_id and a.gigp_id = " + String(gl_gigp_id) + " and a.transaction_type = 'RELRET' group by a.cost_category, c.organization"
ls_sql = "select distinct a.cost_category, c.organization, disbursed_amt from gigp_disbursement_amount a, gigp_professional_contracts pc, gigp_contacts c where c.contact_id = pc.contact_id and pc.profess_contract_id = a.professional_contract_id and a.gigp_id = " + String(gl_gigp_id) + " and a.transaction_type = 'RELRET'"
ls_syntax = sqlca.SyntaxFromSQL(ls_sql, 'Style(Type=Form)', error_syntaxfromSQL)

lds_disb = CREATE n_ds
lds_disb.CREATE(ls_syntax, errorCreate)
lds_disb.SetTransObject(SQLCA)
ll_ret = lds_disb.Retrieve()

For ll_row = 1 to ll_ret
	ls_category = lds_disb.GetItemString(ll_row, 'cost_category')
	ls_vendor = lds_disb.GetItemString(ll_row, 'organization')
	ls_amt = String(lds_disb.GetItemDecimal(ll_row, 'disbursed_amt'), '$#,##0.00;($#,##0.00)')
	
	If IsNull(ls_category) Then ls_category = '[FILL IN CATEGORY]'
	If IsNull(ls_vendor) Then ls_vendor = '[FILL IN VENDOR]'
	If IsNull(ls_amt) Then ls_amt = '[FILL IN AMOUNT]'
	
	ls_disbursement = ls_category + ' - ' + ls_vendor + ' totaling ' + ls_amt
	
	If ll_row = 1 Then
		of_add_bookmark(lou_Ole, 'disbursement', ls_disbursement)
		
	Else
		lou_Ole.Selection.InsertParagraphAfter()	//Inserts a line break
		lou_Ole.Selection.InsertAfter(ls_disbursement)
	End If

Next

If dw_1.GetRow() > 0 Then
	//ldt_date = dw_1.GetItemDateTime(dw_1.GetRow(), 'release_dt')  //As per AP 8/2019
	ldt_date = DateTime(Today())	//As per AP 8/2019
	
	If NOT IsNull(ldt_date) Then
		ls_date = String(ldt_date, 'mmmm d, yyyy')
	Else
		ls_date = '[FILL IN DATE]'
	End If
Else
	ls_date = '[FILL IN DATE]'
End If

of_add_bookmark(lou_Ole, 'letterdate', ls_date)
of_add_bookmark(lou_Ole, 'wireddate', ls_date)
of_add_bookmark(lou_Ole, 'recipient3', ls_applicant)
of_add_bookmark(lou_Ole, 'retaindocsdt', '[FILL IN DATE]')
of_add_bookmark(lou_Ole, 'cc', ls_cc)

lou_OLE.Visible = True

If IsValid(lou_OLE) Then lou_OLE.DisconnectObject()
If IsValid(lds_disb) Then DESTROY lds_disb

Return 1
end function

public subroutine of_add_bookmark (ref oleobject document, string as_bookmark, string as_value);If IsNull(as_value) Then as_value = ''

If (document.ActiveDocument.Bookmarks.Exists(as_bookmark)) Then
	document.Selection.GoTo(True, 0, 0, as_bookmark)
	document.Selection.TypeText(as_value)
End If

end subroutine

public subroutine of_generateredimemo ();string ls_doc, ls_date, ls_app, ls_addr1, ls_addr2, ls_city, ls_state, ls_zip, ls_req, ls_org, ls_title
integer li_rc
long ll_row
decimal ld_disb
oleobject lou_OLE

ll_row = dw_1.GetRow()

If ll_row <= 0 Then
	MessageBox('REDI Memo', 'Please select  a Disbursement.')
	Return
End If

select ref_value
into :ls_doc
from gigp_reference
where category = 'REDIMemo'
and sub_category = 'TemplateLocation';

//*******************************************************
// Connect to MS Word:
//*******************************************************
lou_OLE = CREATE OLEObject

li_rc = lou_OLE.ConnectToObject('', 'Word.Application')

If (li_rc <> 0)  Then 	
	li_rc = lou_OLE.ConnectToNewObject('Word.Application')

	If (li_rc <> 0)  Then
		MessageBox("ERROR!", "Error opening Microsoft Word.")
		Return
	End If	
End If

lou_OLE.Documents.Add(ls_doc)


//*******************************************************
// Get info
//*******************************************************
ls_date = String(dw_1.GetItemDateTime(ll_row, 'release_dt'), 'm/d/yyyy')
If IsNull(ls_date) Then ls_date = '[RELEASE DATE]'
ld_disb = dw_1.GetItemDecimal(ll_row, 'disbursed_amt')
ls_req = String(dw_1.GetItemNumber(ll_row, 'request_no'))

If IsNull(ld_disb) Then ld_disb = 0

select c.title, c.mail_address1, c.mail_address2, c.mail_city, c.mail_state, c.mail_zip
into :ls_title, :ls_addr1, :ls_addr2, :ls_city, :ls_state, :ls_zip
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.contact_type = 'PRC'
and cl.gigp_id = :gl_gigp_id;

select c.organization
into :ls_org
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.contact_type = 'APP'
and cl.gigp_id = :gl_gigp_id;


If ls_addr2 > '' Then
	ls_addr1 += ', ' + ls_addr2
End If

ls_addr2 = ls_city + ', ' + ls_state + ' ' + ls_zip

If IsNull(ls_title) Then ls_title = '[TITLE]'


//*******************************************************
// Populate Bookmarks:  of_add_bookmark(lou_Ole, 'bookmark', 'value')
//*******************************************************
of_add_bookmark(lou_Ole, 'MemoDate', ls_date)
of_add_bookmark(lou_Ole, 'ApplicantName1', ls_org)
of_add_bookmark(lou_Ole, 'RequestNumber', ls_req)
of_add_bookmark(lou_Ole, 'ApplicantName2', ls_org)
of_add_bookmark(lou_Ole, 'DisbursedAmount', String(ld_disb, '$#,##0.00;($#,##0.00)'))
of_add_bookmark(lou_Ole, 'ApplicantName3', ls_org)
of_add_bookmark(lou_Ole, 'ApplicantName4', ls_org)
of_add_bookmark(lou_Ole, 'Title', ls_title)
of_add_bookmark(lou_Ole, 'AddressLine1', ls_addr1)
of_add_bookmark(lou_Ole, 'AddressLine2', ls_addr2)

lou_OLE.Visible = True

If IsValid(lou_OLE) Then lou_OLE.DisconnectObject()

end subroutine

public subroutine of_generaterediletter ();string ls_doc, ls_date, ls_app, ls_addr1, ls_addr2, ls_city, ls_state, ls_zip, ls_org, ls_salutation, ls_title, ls_projname
integer li_rc
long ll_row
decimal ld_disb
oleobject lou_OLE

ll_row = dw_1.GetRow()

If ll_row <= 0 Then
	MessageBox('REDI Letter', 'Please select  a Disbursement.')
	Return
End If

select ref_value
into :ls_doc
from gigp_reference
where category = 'REDILetter'
and sub_category = 'TemplateLocation';

//*******************************************************
// Connect to MS Word:
//*******************************************************
lou_OLE = CREATE OLEObject

li_rc = lou_OLE.ConnectToObject('', 'Word.Application')

If (li_rc <> 0)  Then 	
	li_rc = lou_OLE.ConnectToNewObject('Word.Application')

	If (li_rc <> 0)  Then
		MessageBox("ERROR!", "Error opening Microsoft Word.")
		Return
	End If	
End If

lou_OLE.Documents.Add(ls_doc)


//*******************************************************
// Get info
//*******************************************************
ls_date = String(dw_1.GetItemDateTime(ll_row, 'release_dt'), 'm/d/yyyy')
If IsNull(ls_date) Then ls_date = '[RELEASE DATE]'
ld_disb = dw_1.GetItemDecimal(ll_row, 'disbursed_amt')

If IsNull(ld_disb) Then ld_disb = 0

select c.full_name, c.salutation_name, c.title, c.mail_address1, c.mail_address2, c.mail_city, c.mail_state, c.mail_zip
into :ls_app, :ls_salutation, :ls_title, :ls_addr1, :ls_addr2, :ls_city, :ls_state, :ls_zip
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.contact_type = 'PRC'
and cl.gigp_id = :gl_gigp_id
and c.status = 'Active';

select c.organization
into :ls_org
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.contact_type = 'APP'
and cl.gigp_id = :gl_gigp_id;

select project_name
into :ls_projname
from gigp_application
where gigp_id = :gl_gigp_id;

If ls_addr2 > '' Then
	ls_addr1 += ', ' + ls_addr2
End If

ls_addr2 = ls_city + ', ' + ls_state + ' ' + ls_zip

If IsNull(ls_app) Then ls_app = '[APPLICANT NAME]'
If IsNull(ls_salutation) Then ls_salutation = '[SALUTATION NAME]'
If ls_title > '' then ls_app = ls_title + ' ' + ls_app

//*******************************************************
// Populate Bookmarks:  of_add_bookmark(lou_Ole, 'bookmark', 'value')
//*******************************************************
of_add_bookmark(lou_Ole, 'LetterDate', ls_date)
of_add_bookmark(lou_Ole, 'ApplicantName1', ls_app)
of_add_bookmark(lou_Ole, 'ProjectName', ls_projname)
of_add_bookmark(lou_Ole, 'Organization', ls_org)
of_add_bookmark(lou_Ole, 'ApplicantName2', ls_org)
of_add_bookmark(lou_Ole, 'AddressLine1', ls_addr1)
of_add_bookmark(lou_Ole, 'AddressLine2', ls_addr2)
of_add_bookmark(lou_Ole, 'SalutationName', ls_salutation)
of_add_bookmark(lou_Ole, 'DisbursedAmount', String(ld_disb, '$#,##0.00;($#,##0.00)'))


lou_OLE.Visible = True

If IsValid(lou_OLE) Then lou_OLE.DisconnectObject()

end subroutine

public function integer of_setbankinfosecurity ();long ll_count
string ls_user

//Handle Bank Info, 9/2023
ls_user = gnv_app.of_getuserid()

select count(*)
into :ll_count
from application_rights
where name = :ls_user
and application = 'GIGP'
and sub_group = 'BankInfo';

If ll_count > 0 Then
	//shl_bankinfo.Enabled = True
	dw_bankinfo.Object.DataWindow.ReadOnly="No"
Else
	//shl_bankinfo.Enabled = False
	dw_bankinfo.Object.DataWindow.ReadOnly="Yes"
End If


Return 1
end function

on u_tabpg_disbursements.create
int iCurrent
call super::create
this.dw_2=create dw_2
this.shl_1=create shl_1
this.dw_delete=create dw_delete
this.dw_3=create dw_3
this.shl_bankinfo=create shl_bankinfo
this.dw_bankinfo=create dw_bankinfo
this.shl_3=create shl_3
this.dw_closeout=create dw_closeout
this.cb_retrelltr=create cb_retrelltr
this.cb_redi_memo=create cb_redi_memo
this.cb_redi_letter=create cb_redi_letter
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_2
this.Control[iCurrent+2]=this.shl_1
this.Control[iCurrent+3]=this.dw_delete
this.Control[iCurrent+4]=this.dw_3
this.Control[iCurrent+5]=this.shl_bankinfo
this.Control[iCurrent+6]=this.dw_bankinfo
this.Control[iCurrent+7]=this.shl_3
this.Control[iCurrent+8]=this.dw_closeout
this.Control[iCurrent+9]=this.cb_retrelltr
this.Control[iCurrent+10]=this.cb_redi_memo
this.Control[iCurrent+11]=this.cb_redi_letter
end on

on u_tabpg_disbursements.destroy
call super::destroy
destroy(this.dw_2)
destroy(this.shl_1)
destroy(this.dw_delete)
destroy(this.dw_3)
destroy(this.shl_bankinfo)
destroy(this.dw_bankinfo)
destroy(this.shl_3)
destroy(this.dw_closeout)
destroy(this.cb_retrelltr)
destroy(this.cb_redi_memo)
destroy(this.cb_redi_letter)
end on

event constructor;call super::constructor;//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Disbursements"}


If NOT ib_editAccess Then
	dw_1.Modify("DataWindow.ReadOnly = Yes")
End If
end event

event ue_tab_deselected;call super::ue_tab_deselected;
m_gigp_master lm_Menu

lm_Menu = it_Parent.iw_Parent.MenuID

//******************************************************
// Customize Menu:
//******************************************************

lm_Menu.m_tools.m_utilities.m_contactsmgmt.ToolBarItemVisible = False

//lm_Menu.m_file.m_save.Visible = True
//lm_Menu.m_file.m_save.ToolBarItemVisible = True

lm_Menu.m_file.m_print.Visible = False
lm_Menu.m_file.m_print.ToolBarItemVisible = False

lm_Menu.m_edit.m_insertrow.Visible = False
lm_Menu.m_edit.m_insertrow.ToolBarItemVisible = False

lm_Menu.m_edit.m_deleterow.Visible = False
lm_Menu.m_edit.m_deleterow.ToolBarItemVisible = False

lm_Menu.m_edit.m_editrow.Visible =  False
lm_Menu.m_edit.m_editrow.ToolBarItemVisible =  False

lm_Menu.m_tools.m_email.Visible = False
lm_Menu.m_tools.m_email.ToolBarItemVisible = False

lm_Menu.m_tools.m_sendletter.Visible = False
lm_Menu.m_tools.m_sendletter.ToolBarItemVisible = False
lm_Menu.m_tools.m_sendletter.Text = is_origText
lm_Menu.m_tools.m_sendletter.ToolBarItemText = is_origText
end event

event ue_tab_selected;call super::ue_tab_selected;m_gigp_master lm_Menu
Boolean lb_visible
string ls_program

lm_Menu = it_Parent.iw_Parent.MenuID

//******************************************************
// Customize Menu:
//******************************************************

//lm_Menu.m_file.m_save.Visible = False
//lm_Menu.m_file.m_save.ToolBarItemVisible = False

is_origText = lm_Menu.m_tools.m_sendletter.Text

If (dw_1.RowCount() > 0) Then
	
	lm_Menu.m_tools.m_sendletter.Text = "Wire Letter"
	lm_Menu.m_tools.m_sendletter.ToolBarItemText = "Wire Letter"
	lm_Menu.m_tools.m_sendletter.Visible = True
	lm_Menu.m_tools.m_sendletter.ToolBarItemVisible = True
Else
	lm_Menu.m_tools.m_sendletter.Visible = False
	lm_Menu.m_tools.m_sendletter.ToolBarItemVisible = False
End If

//lm_Menu.m_file.m_print.Visible = True
//lm_Menu.m_file.m_print.ToolBarItemVisible = True

//******************************************************
// Check Security:
//******************************************************

If (ib_editAccess = True) Then	
	lb_visible = True
	lm_Menu.m_edit.m_insertrow.Enabled = True	
	lm_Menu.m_edit.m_deleterow.Enabled = True	
Else	
	lb_visible = False	
	lm_Menu.m_edit.m_insertrow.Enabled = False	
	lm_Menu.m_edit.m_deleterow.Enabled = False
End If


lm_Menu.m_edit.m_insertrow.Visible = lb_visible
lm_Menu.m_edit.m_insertrow.ToolBarItemVisible = lb_visible

lm_Menu.m_edit.m_editrow.Visible = lb_visible
lm_Menu.m_edit.m_editrow.ToolBarItemVisible = lb_visible

lm_Menu.m_edit.m_deleterow.Visible = True
lm_Menu.m_edit.m_deleterow.ToolBarItemVisible = lb_visible

//******************************************************
// Order the Sheet Toolbar:
//******************************************************

lm_Menu.m_edit.m_insertrow.ToolBarItemOrder 	= 1
lm_Menu.m_edit.m_editrow.ToolBarItemOrder 	= 2
lm_Menu.m_edit.m_deleterow.ToolBarItemOrder	= 3
lm_Menu.m_file.m_print.ToolBarItemOrder	 		= 4
lm_Menu.m_tools.m_email.ToolBarItemOrder       	= 5
lm_Menu.m_file.m_save.ToolBarItemOrder 			= 6
lm_Menu.m_tools.m_sendletter.ToolBarItemOrder = 7
lm_Menu.m_file.m_close.ToolBarItemOrder 			= 8

//******************************************************
// Force Row Focus Change to Retrieve the Detail DW:
//******************************************************
dw_1.Event rowfocuschanged(dw_1.GetRow())

//******************************************************
// Handle REDI buttons
//******************************************************

select program
into :ls_program
from gigp_application
where gigp_id = :gl_gigp_id;

If ls_program = 'REDI' Then
	cb_redi_memo.Visible = True
	cb_redi_letter.Visible = True
Else
	cb_redi_memo.Visible = False
	cb_redi_letter.Visible = False
End If

it_Parent.iw_Parent.Event  Dynamic Post ue_postit_disbursements()

//Handle Bank Info, 9/2023
this.Post of_setbankinfosecurity()
end event

type dw_1 from u_tabpg_dbaccess`dw_1 within u_tabpg_disbursements
event ue_editrow ( )
event ue_sendletter ( )
string tag = "Disbursement Request"
integer x = 14
integer y = 92
integer width = 2894
integer height = 740
string dataobject = "d_disburse_request"
end type

event dw_1::ue_editrow();
Long		ll_row, ll_disbursementID, ll_rc
Integer 	li_lock
str_disbursementparms lstr_parms


If (dw_1.Rowcount() < 1) Then Return

ll_disbursementID = dw_1.GetItemNumber(dw_1.GetRow(), "disbursement_id")
li_lock = dw_1.GetItemNumber(dw_1.GetRow(), "lock_flag")

lstr_parms.str_disbursementid = ll_disbursementID
lstr_parms.str_gigpid =  gl_gigp_id

If (li_lock = 0) Then
	If ib_editAccess Then
		lstr_parms.str_access =  "EDIT"
	Else
		lstr_parms.str_access =  "READ"
	End If
Else
	lstr_parms.str_access =  "READ"
End If

OpenWithParm(w_disbursement_edit, lstr_parms)

ll_disbursementID = Message.DoubleParm

If (ll_disbursementID = -1) Then Return

ll_rc = dw_1.of_Retrieve()

end event

event dw_1::ue_sendletter();//*************************************************************
// Wire Transfer Letter:
//*************************************************************
OLEObject	lou_OLE, lou_OLERow, lou_OLECell, lou_table
Integer 		li_rc, li_round
Long           ll_disburseID, ll_previousID, ll_requestNo, ll_row, ll_cfa_no
String      	ls_value, ls_value2, ls_bookMark, ls_docPath, ls_projNo, ls_formattedProj, ls_grantsource, ls_program
String 		ls_appName, ls_projName, ls_srfProgram, ls_acctName, ls_abaNo, ls_recipAcctNo, ls_round, ls_label
string 		ls_cwAcctNo, ls_dwAcctNo, ls_admin_acct_no, ls_stateAcctNo, ls_disburse_from_acct, ls_disburse_from_amt, ls_ecAcctNo, ls_septicAcctNo, ls_wqiAcctNo, ls_osgAcctNo
Decimal     	ld_amount, ld_federal, ld_state, ld_disburse_from_amt
DateTime    	ldt_date, ldt_dummy

If (This.of_UpdatesPending() = 1) Then
	MessageBox("ERROR!", "This document cannot be generated while unsaved changes exist!")
	Return
End If

ll_row = dw_1.GetRow()

If (ll_row < 1) Then Return

ldt_dummy = DateTime('1/1/1900 00:00:00')

//*******************************************************
// Connect to MS Word:
//*******************************************************

lou_OLE = CREATE OLEObject

li_rc = lou_OLE.ConnectToObject('', 'Word.Application')

If (li_rc <> 0)  Then 	
	li_rc = lou_OLE.ConnectToNewObject('Word.Application')

	If (li_rc <> 0)  Then
		MessageBox("ERROR!", "Error opening Microsoft Word.")
		Goto FinishUp
	End If	
End If

//*******************************************************
// Open  Factsheet Template:
//*******************************************************

Select description
Into	 :ls_docPath
From 	 gigp_reference
Where  category     = 'template'
And    sub_category = 'wireTransferMemo'
And   ref_code = 'wireTransferMemo';

lou_OLE.Documents.Add(ls_docPath)

//*******************************************************
// Get most application data:
//*******************************************************

 SELECT	project_name, 
         	srf_program,			
			project_no,
			round_no,
			cfa_no,
			program
INTO		:ls_projName,			
			:ls_srfProgram,				
			:ls_projNo,
			:li_round,
			:ll_cfa_no,
			:ls_program
FROM 	gigp_application   
WHERE	gigp_id = :gl_gigp_id;

ls_round = String(li_round)

//*******************************************************
// Populate Bookmarks::
//*******************************************************

//*********************
// GIGP ID:
//*********************
Choose Case ls_program
	Case 'EPG'
		ls_value = String(ll_cfa_no) + ' / ' + String(gl_gigp_id)
	Case 'GIGP'
		ls_value =  String(gl_gigp_id)
	Case Else
		ls_value = String(gl_gigp_id)	//3/2024 per AP
End Choose

ls_bookMark = "appID"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// SRF Program:
//*********************

ls_bookMark = "srfProgram"

Choose Case ls_program
	Case 'Septic'
		ls_value = 'State Septic System Replacement Fund'
	Case 'WQI'
		ls_value = 'Water Quality Infrastructure Program'
	Case 'OSG'
		ls_value = 'Sewer and Stormwater Reuses Municipal Grants Program'
	Case Else
		ls_value = ls_srfProgram
End Choose

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_value)
End If

//**************************************************************************
// Name/Number of Account: ****NEW 2/2019 - handle State vs Federal funding source (could be split)
//**************************************************************************
//Get bucket account numbers
Select ref_value + ' ' + cast(description as varchar)
Into :ls_cwAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'CW Unallocated';

Select ref_value + ' ' + cast(description as varchar)
Into :ls_dwAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'DW Unallocated';

Select ref_value + ' ' + cast(description as varchar)
Into :ls_admin_acct_no
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'Administrative Expense Account';

Select ref_value + ' ' + cast(description as varchar)
Into :ls_stateAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'State Money';

Select ref_value + ' ' + cast(description as varchar)
Into :ls_ecAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'DW EC Fund';

Select ref_value + ' ' + cast(description as varchar)
Into :ls_wqiAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'CW WQI Fund';

Select ref_value + ' ' + cast(description as varchar)
Into :ls_septicAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'CW Septic Fund';

Select description
Into :ls_osgAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'OSG Account No';

//Get Applicant
ls_appName = f_get_applicant_name(gl_gigp_id)
If IsNull(ls_appName) Then ls_appName = ''


//Get Amounts
ld_state = dw_1.GetItemDecimal(ll_row, 'state_amt')
ld_federal = dw_1.GetItemDecimal(ll_row, 'federal_amt')
ld_amount = dw_1.GetItemDecimal(ll_row, 'disbursed_amt')

If IsNull(ld_state) Then ld_state = 0
If IsNull(ld_federal) Then ld_federal = 0
If IsNull(ld_amount) Then ld_amount = 0


Choose Case ls_program
	Case 'EPG'
		ls_disburse_from_acct = ls_admin_acct_no
	Case 'PPG-EC'
		ls_disburse_from_acct = ls_ecAcctNo
	Case 'WQI'
		ls_disburse_from_acct = ls_wqiAcctNo
	Case 'Septic'
		ls_disburse_from_acct = ls_septicAcctNo
	Case 'OSG'
		ls_disburse_from_acct = ls_osgAcctNo 
	Case 'GIGP'	//GIGP
		If ls_srfProgram = 'CW' Then
			If ld_state > 0 Then
				ls_disburse_from_acct = ls_stateAcctNo
			Else
				ls_disburse_from_acct = ls_cwAcctNo
			End If
		Else
			ls_disburse_from_acct = ls_dwAcctNo
		End If
	Case Else
		ls_disburse_from_acct = '[UNKNOWN ACCOUNT]'
End Choose

////////////////////////////////////////////////////////////////////////////////////////////////
//One-off exception for WQI Mt Vernon as per Angela. If becomes more, implement an exception by GIGP Id in the gigp_reference
If gl_gigp_id = 2144 Then
	ls_disburse_from_acct = 'Administrative Expense Account #185-00-8216'
End If
////////////////////////////////////////////////////////////////////////////////////////////////

If ld_state > 0 Then
	ls_disburse_from_amt = String(ld_state, "$#,###,##0.00;($#,###,##0.00)")
Else
	ls_disburse_from_amt = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
End If

//Add first row of Disburse From Accounts
ls_bookmark = 'disburseFromTableCell1'
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_disburse_from_acct)
End If	

ls_bookmark = 'disburseFromTableCell2'
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_disburse_from_amt)
End If	

//If split funding, fill in second row, else delete it
If ld_state > 0 and ld_federal > 0 then
	//Add second line for Federal
	ls_disburse_from_acct = ls_cwAcctNo
	ls_disburse_from_amt = String(ld_federal, "$#,###,##0.00;($#,###,##0.00)")
	
	ls_bookmark = 'disburseFromTableCell3'
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
		lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
		lou_OLE.Selection.TypeText(ls_disburse_from_acct)
	End If	
	
	ls_bookmark = 'disburseFromTableCell4'
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
		lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
		lou_OLE.Selection.TypeText(ls_disburse_from_amt)
	End If	
	
Else
	ls_bookmark = 'disburseFromTable'
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
		lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
		lou_OLE.Selection.Rows[2].Delete
	End If	
	
End If


//*********************
// GIGP ID label
//*********************
Choose Case ls_program
	Case 'GIGP'
		ls_label = 'GIGP No. / SRF Project No.:'
	Case 'EPG'
		ls_label = 'EPG No. / Small Grants ID:'
	Case 'PPG-EC'
		ls_label = 'PPG No.:'
	Case 'WQI'
		ls_label = 'WQIP ID No.:'
	Case 'Septic'
		ls_label = 'SSRP ID No.:'
	Case 'OSG'
		ls_label = 'OSG ID No.:'
End Choose
	
ls_bookMark = "gigpno_label"
		
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_label)
End If	

//*********************
// SRF Project:
//*********************
If ls_program = 'EPG' or ls_program = 'WQI' or ls_program = 'Septic' Then
	ls_value = ' '
Else
	ls_value = '/ ' + ls_projNo
End If
	
ls_bookMark = "srfProjNo"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// Project Name:
//*********************
If IsNull(ls_projName) Then ls_projName = ''

If ls_program = 'Septic' Then
	ls_value = ls_appname
Else
	ls_value = ls_projName
End If

ls_bookMark = "projName"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_value)
End If



//*********************
// Grant Source:
//*********************
//If li_round = 1 Then
//	Choose Case ls_srfProgram
//		Case 'DW'
//			ls_value = 'DW  ARRA FUNDS, Federal Award #2F-97237809, CFDA #66.468'
//		Case 'CW'
//			ls_value = 'CW ARRA FUNDS, Federal Award #2W-36000209, CFDA #66.458'	
//	End Choose
//Else
//	ls_value = ' '
//End If

Select description
into :ls_grantsource
from gigp_reference
where category = 'GrantSource'
and sub_category = :ls_srfProgram
and ref_code = :ls_round;

If IsNull(ls_grantsource) Then ls_grantsource = ''

If ls_program = 'WQI' or ls_program = 'Setpic' Then
	ls_grantsource = ' '
End If

	
ls_bookMark = "grantSource"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_grantsource)
End If


//*********************
// Applicant Name:
//*********************
ls_bookMark = "appName"

If ls_program = 'WQI' or ls_program = 'Septic' Then
	ls_value = ' '
Else
	ls_value = ls_appName
End If

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_value)
End If

ls_bookMark = "appName2"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_appName)
End If

//*********************
// Agreement Dt:
//*********************

SetNull(ldt_date)
SetNull(ls_value)

Select keydate_value
Into	:ldt_date
From gigp_key_dates
Where gigp_id  = :gl_gigp_id
And ref_code = 'agreeAGRFULLEX';

If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
	
	ls_value = String(Date(ldt_date), "mmmm dd, yyyy")
			
	ls_bookMark = "agreeDt"
		
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
		lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
		lou_OLE.Selection.TypeText(ls_value)
	End If
				
End If

//*********************
// Request No.
//*********************

SetNull(ls_value)

ll_disburseID 	= dw_1.GetItemNumber(ll_row, 'disbursement_id')
ll_requestNo	= dw_1.GetItemNumber(ll_row, 'request_no')

ls_value = String(ll_requestNo)

If IsNull(ls_value) Then ls_value = ""	
			
ls_bookMark = "requestNo"
		
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_value)
End If



//*********************
// Release Date:
//*********************

SetNull(ls_value)

ldt_date 	= dw_1.GetItemDateTime(ll_row, 'release_dt')

If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
	
	//ls_value = String(Date(ldt_date), "mmmm dd, yyyy")
	ls_value = String(Date(ldt_date), "mmmm d, yyyy")
			
	ls_bookMark = "releaseDt"
		
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
		lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
		lou_OLE.Selection.TypeText(ls_value)
	End If
	
	ls_bookMark = "memoDt"
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
		lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
		lou_OLE.Selection.TypeText(ls_value)
	End If
	
				
End If

//*********************
// Disbursed Amount:
//*********************

ld_amount = 0
SetNull(ls_value)

ld_amount = dw_1.GetItemDecimal(ll_row, 'disbursed_amt')

If IsNull(ld_amount) Then ld_amount = 0

ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")

ls_bookMark = "disburseAmt"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// Net Avail Amount:
//*********************

ld_amount = 0
SetNull(ls_value)

ld_amount = dw_3.GetItemDecimal(dw_3.RowCount(), 'cf_awardnet')

If IsNull(ld_amount) Then ld_amount = 0

ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")

ls_bookMark = "netAvailAmt"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// Previous Request Info:
//*********************

ld_amount = 0

//Select Max(disbursement_id)
//Into	:ll_previousID
//From gigp_disbursement_request  
//WHERE 	disbursement_id < :ll_disburseID
//AND gigp_id =  :gl_gigp_id;
//
//If (ll_previousID < 1) Then
//	// Do Nothing
//Else
//	Select Sum(disbursed_amt)
//	Into	:ld_amount
//	From gigp_disbursement_amount 
//	WHERE 	disbursement_id = :ll_previousID
//	And		gigp_id  = :gl_gigp_id;
//	
//	If IsNull(ld_amount) Then ld_amount = 0
//
//End If

//Changed to obtains the cumulative previous disbursed amount (mpf 01/17/2010)

Select Sum(disbursed_amt)
Into	:ld_amount
From gigp_disbursement_amount 
WHERE 	disbursement_id < :ll_disburseID
And		gigp_id  = :gl_gigp_id;

If IsNull(ld_amount) Then ld_amount = 0

ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")

ls_bookMark = "prevAmt"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// Cumulative Retainage:
//*********************

ld_amount = 0

Select 	Sum(retained_amt)
Into 		:ld_amount
FROM 	gigp_disbursement_amount    
Where 	gigp_id = :gl_gigp_id;

If IsNull(ld_amount) Then ld_amount = 0

ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")

ls_bookMark = "cumRetained"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// Wire To Info:
//*********************

ls_value = ""
	
Select		C.organization
Into		:ls_value
FROM		gigp_contacts C,   
			gigp_contact_links CL  
WHERE 	C.contact_id = CL.contact_id    
AND		CL.gigp_id = :gl_gigp_id
AND      	CL.contact_type = 'BNKC';
	
If IsNull(ls_value) Then ls_value = ""
	
ls_bookMark = "bankName"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_value)
End If	

DECLARE cWTI CURSOR FOR
		SELECT	R.ref_code,    
        				PR.projref_value 
		FROM 	gigp_reference R left outer join gigp_project_references PR on R.ref_code = PR.ref_code and PR.gigp_id = :gl_gigp_id
		WHERE 	R.category = 'projectRef'
		AND      	R.sub_category = 'bankInfo';
	
OPEN cWTI;
	
FETCH cWTI INTO :ls_value, :ls_value2;
	
DO WHILE SQLCA.sqlcode = 0
	
	If IsNull(ls_value2) Then ls_value2 = ""
		
	If (ls_value = 'bankABA') Then
		
		 ls_abaNo = ls_value2		 
		 ls_bookMark = "abaNo"
		 
		If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_abaNo)
		End If
		
	ElseIf (ls_value = 'acctName') Then
		
		ls_acctName = ls_value2		
		ls_bookMark = "acctName"
		
		 If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_acctName)
		End If
		
	ElseIf (ls_value = 'acctNo') Then
		
		ls_recipAcctNo = ls_value2		
		ls_bookMark = "recipAcctNo"
		
		 If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_recipAcctNo)
		End If
		
	End If
			
	FETCH cWTI INTO :ls_value, :ls_value2;
	
LOOP
	
CLOSE cWTI;

//*********************
// Total Authorized Amount:
//*********************

ld_amount = 0 
ls_value = ""

ld_amount = f_get_project_amount(gl_gigp_id, "RECFR")  

ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")

ls_bookMark = "awardAmt"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_value)
End If

//*************************************************************
// Authorized Rep:
//*************************************************************

ls_value = ""
	
Select		C.full_name
Into		:ls_value
FROM		gigp_contacts C,   
				gigp_contact_links CL  
WHERE 	C.contact_id = CL.contact_id    
AND		CL.gigp_id = :gl_gigp_id
AND      	CL.contact_type = 'AUTHREP';
	
If IsNull(ls_value) Then ls_value = ""
	
ls_bookMark = "authRep"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
	lou_OLE.Selection.TypeText(ls_value)
End If	

//*******************************************************
// Finish Up:
//*******************************************************

FinishUp:

lou_OLE.Visible = True

If IsValid(lou_OLE) Then lou_OLE.DisconnectObject()


end event

event dw_1::constructor;call super::constructor;
This.ib_RMBMenu = False

This.Object.DataWindow.ReadOnly="Yes"

//********************************************************************
// Register Disbursement ID:
//********************************************************************

This.of_registerkey("disbursement_id")

//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)

//********************************************************************
// Turn on the PFC Row Manager Service:
//********************************************************************

This.of_SetRowManager(TRUE)
This.inv_rowmanager.of_SetConfirmOnDelete(FALSE)

end event

event dw_1::pfc_insertrow;
//OverRide//

Long ll_row, ll_disbursementID

str_disbursementparms lstr_parms

lstr_parms.str_disbursementid = -1
lstr_parms.str_gigpid =  gl_gigp_id
lstr_parms.str_access =  "EDIT"

OpenWithParm(w_disbursement_edit,lstr_parms)

ll_disbursementID = Message.DoubleParm

If (ll_disbursementID = -1) Then Return 1

il_newDisbursID = ll_disbursementID

dw_1.of_Retrieve()

Return 1
end event

event dw_1::pfc_retrieve;call super::pfc_retrieve;
dw_2.Event pfc_retrieve()
dw_3.Event pfc_retrieve()
dw_bankinfo.Event pfc_retrieve()
dw_closeout.Event pfc_retrieve()
dw_delete.Reset()

Return 1
end event

event dw_1::rowfocuschanged;call super::rowfocuschanged;
Long ll_disburseID

If (currentrow < 1) Then
	
	dw_2.Reset()
Else
	ll_disburseID = This.GetItemNumber(currentrow, "disbursement_id")
	dw_2.Retrieve(ll_disburseID)
End If
end event

event dw_1::sqlpreview;call super::sqlpreview;
String	ls_category
Long 	ll_gigpID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	
	ll_gigpID = gl_gigp_id
	ls_category = This.Tag	
	
	f_transactionlog("gigp_id", ll_gigpID, This.DataObject, ls_category, sqlsyntax)
END IF
end event

event dw_1::pfc_deleterow;
//OverRide//

Parent.Event pfc_deleterow()

Return 1
end event

event dw_1::buttonclicked;call super::buttonclicked;
Long	ll_disbursementID, ll_rc
str_disbursementparms lstr_parms

If (dwo.Name = 'b_details') Then
	
	ll_disbursementID = dw_1.GetItemNumber(row, "disbursement_id")

	lstr_parms.str_disbursementid = ll_disbursementID
	lstr_parms.str_gigpid =  gl_gigp_id
	lstr_parms.str_access =  "READ"

	OpenWithParm(w_disbursement_edit, lstr_parms)
	
End If
end event

event dw_1::doubleclicked;call super::doubleclicked;
Long	ll_disbursementID, ll_rc
str_disbursementparms lstr_parms

If (row < 1) Then Return

//ll_disbursementID = dw_1.GetItemNumber(row, "disbursement_id")
//
//lstr_parms.str_disbursementid = ll_disbursementID
//lstr_parms.str_gigpid =  gl_gigp_id
//lstr_parms.str_access =  "READ"
//
//OpenWithParm(w_disbursement_edit, lstr_parms)
	

this.Event ue_editrow()
end event

type dw_2 from u_dw within u_tabpg_disbursements
event ue_editrow ( )
event ue_sendletter ( )
string tag = "Disbursement Amount"
integer x = 14
integer y = 856
integer width = 2894
integer height = 1548
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_disburse_details"
boolean hscrollbar = true
end type

event ue_editrow();
dw_1.Event ue_editrow()
end event

event ue_sendletter();
dw_1.event ue_sendletter()
end event

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False

This.Object.DataWindow.ReadOnly="Yes"


end event

event retrieveend;call super::retrieveend;
DataWindowChild ldwc

Long ll_rowCnt

This.GetChild('professional_contract_id', ldwc)
ldwc.SetTransObject(SQLCA)
ll_rowCnt = ldwc.Retrieve(gl_gigp_id)
end event

event pfc_deleterow;
//OverRide//

Parent.Event pfc_deleterow()

Return 1
end event

event buttonclicked;call super::buttonclicked;
String ls_access, ls_text, ls_col
Integer li_RC, li_limit

If (dwo.Name = "b_edit") Then	
	
	ls_access = "READ"
	
	dw_1.AcceptText()	
	
	ls_Text     = This.GetItemString(row, "comments")
			
	li_RC = f_edit_notes(ls_access, ls_Text)
	
End If

If (dwo.Name = "b_singleedit") Then	
	
	ls_access = "READ"
	li_limit = 50
	
	dw_1.AcceptText()	
	
	ls_col = dwo.Tag
	
	ls_Text     = This.GetItemString(row, ls_col)
			
	li_RC = f_edit_notes2(ls_access, ls_Text, li_limit)
	
End If
end event

event pfc_insertrow;
//OverRide//

Return dw_1.Event pfc_insertrow()


end event

type shl_1 from statichyperlink within u_tabpg_disbursements
integer x = 32
integer y = 16
integer width = 768
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
string text = "View Disbursement Summary"
boolean focusrectangle = false
end type

event clicked;
If (dw_3.Visible = False) Then
	dw_3.X = dw_2.X	
	dw_3.Y = dw_2.Y
	dw_3.Visible = True
end If
end event

type dw_delete from u_dw within u_tabpg_disbursements
string tag = "Disbursement Amount"
boolean visible = false
integer x = 2185
integer y = 2304
integer width = 722
integer height = 100
integer taborder = 11
boolean titlebar = true
string title = "Delete Detail Rows"
string dataobject = "d_disburse_details"
boolean controlmenu = true
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

//********************************************************************
// Turn on the PFC Row Manager Service:
//********************************************************************

This.of_SetRowManager(TRUE)
This.inv_rowmanager.of_SetConfirmOnDelete(FALSE)


This.ib_RMBMenu = False

This.Object.DataWindow.ReadOnly="Yes"
end event

event sqlpreview;call super::sqlpreview;
String			ls_category
Long 			ll_gigpID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
		
	ll_gigpID = This.GetItemNumber(row, "gigp_id", buffer, True)
	ls_category = This.Tag	
	
	f_transactionlog("gigp_id", ll_gigpID, This.DataObject, ls_category, sqlsyntax)
END IF
end event

type dw_3 from u_dw within u_tabpg_disbursements
event ue_editrow ( )
event ue_sendletter ( )
boolean visible = false
integer x = 14
integer y = 960
integer width = 4814
integer height = 1364
integer taborder = 21
boolean bringtotop = true
boolean titlebar = true
string title = "Contract Summary"
string dataobject = "d_disburse_netavail_byproject"
boolean controlmenu = true
boolean hscrollbar = true
boolean resizable = true
end type

event ue_editrow();
dw_1.Event ue_editrow()
end event

event ue_sendletter();
dw_1.Event ue_sendletter()
end event

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.Object.DataWindow.ReadOnly="Yes"

This.ib_RMBMenu = False
end event

event pfc_retrieve;call super::pfc_retrieve;
Return This.Retrieve(gl_gigp_id)
end event

event pfc_deleterow;
//OverRide//

Parent.Event pfc_deleterow()

Return 1
end event

event retrieveend;call super::retrieveend;
Long ll_row, ll_professContractID
Decimal ld_contractAmt, ld_eligibleAmt, ld_retainageAmt, ld_awardAmt, ld_requestedAmt, ld_disbursedAmt
String ls_subCat
Integer li_sort

If (rowcount < 1) Then Return

ld_awardAmt = f_get_project_amount(gl_gigp_id, "RECFR")

FOR ll_row = 1 TO rowcount
      
	ll_professContractID 	= This.GetItemNumber(ll_row, "profess_contract_id")
	ld_contractAmt 		= This.GetItemDecimal(ll_row, "contract_amt")
	ls_subCat       			= This.GetItemString(ll_row, "contract_type")
	
	 
	Select		Sum(eligible_amt),   
        			Sum(retained_amt),
				Sum(netrequest_amt),
				Sum(disbursed_amt)
	Into 		:ld_eligibleAmt,
				:ld_retainageAmt,
				:ld_requestedAmt,
				:ld_disbursedAmt
	From  	gigp_disbursement_amount   
	Where gigp_id = :gl_gigp_id
	And professional_contract_id = :ll_professContractID;		
	
	If IsNull(ld_eligibleAmt) Then ld_eligibleAmt = 0
	If IsNull(ld_retainageAmt) Then ld_retainageAmt = 0

//	This.SetItem(ll_row, 	"cc_netavail", (ld_contractAmt - ld_eligibleAmt))	
//	This.SetItem(ll_row, 	"cc_netavail", (ld_contractAmt - ld_requestedAmt))	//6/2011 as per Angela
//	This.SetItem(ll_row, 	"cc_netavail", (ld_contractAmt - ld_eligibleAmt))	// 5/2022, back to origin as per Angela
	This.SetItem(ll_row, 	"cc_netavail", (ld_contractAmt - ld_requestedAmt))	//3/2023 should use Netrequested amount as per Angela
	
	This.SetItem(ll_row,	"cc_local_share", (ld_requestedAmt * 0.1))
	
//	This.SetItem(ll_row,	"cc_disbursed", ld_disbursedAmt) 	//Should be NetRequest Amt as per Angela, 3/2023
	This.SetItem(ll_row,	"cc_disbursed", ld_requestedAmt)
	
	This.SetItem(ll_row, 	"cc_disbAmt", ld_eligibleAmt)	
	This.SetItem(ll_row, 	"cc_retavail", ld_retainageAmt)	
				
	//*************************************************************
	// Get/Set Sub-Category Sort Order:
	//*************************************************************
	
	Select Min(sort_order)
	Into  :li_sort
	From gigp_reference
	Where category = "budgetAmount"
	And sub_category = :ls_subCat;
	
	This.SetItem(ll_row, "cc_sort", li_sort)				
		
	This.SetItemStatus(ll_row, 0, Primary!, NotModified!)	
	
	ll_professContractID = 0
	ld_eligibleAmt = 0
	ld_retainageAmt = 0
	
	ls_subCat  = ""
	li_sort = 0	
	
NEXT

This.Sort()
This.GroupCalc()

This.SetItem(rowcount, 	"cc_awardAmt", ld_awardAmt)		
This.SetItemStatus(rowcount, 0, Primary!, NotModified!)
end event

event losefocus;call super::losefocus;
dw_1.SetFocus()
end event

event buttonclicked;call super::buttonclicked;If dwo.name = 'b_print' Then
	this.Event pfc_print()
End If
end event

type shl_bankinfo from statichyperlink within u_tabpg_disbursements
integer x = 878
integer y = 16
integer width = 599
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
string text = "View Bank Information"
boolean focusrectangle = false
end type

event clicked;
If (dw_bankinfo.Visible = False) Then
	dw_bankinfo.X = dw_1.X	
	dw_bankinfo.Y = dw_1.Y	
	dw_bankinfo.Visible = True
End If
end event

type dw_bankinfo from u_dw within u_tabpg_disbursements
boolean visible = false
integer x = 14
integer y = 92
integer width = 2427
integer height = 1456
integer taborder = 31
boolean bringtotop = true
boolean titlebar = true
string title = "Bank Information"
string dataobject = "d_proj_bank_info"
boolean controlmenu = true
boolean hscrollbar = true
boolean resizable = true
end type

event constructor;call super::constructor;This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

event pfc_retrieve;call super::pfc_retrieve;Return This.Retrieve(gl_gigp_id)
end event

event itemchanged;call super::itemchanged;
This.SetItem(row, "last_updated_by", gnv_app.of_getuserid())
This.SetItem(row, "last_updated_dt", f_getdbdatetime())	
end event

event pfc_updateprep;call super::pfc_updateprep;
Long 	ll_row, ll_gigpID

//*******************************************************
// Loop thru modified rows:
//*******************************************************

ll_row	= This.GetNextModified(0, Primary!)

DO WHILE ll_row > 0	
	
	//*******************************************************
	// If new row, Set key values:
	//*******************************************************

	ll_gigpID = This.GetItemNumber(ll_row, "gigp_id")

	If IsNull(ll_gigpID) Then
		This.SetItem(ll_row, "gigp_id",gl_gigp_id)	  

		This.SetItem(ll_row, "ref_code", This.GetItemString(ll_row, "ref_ref_code")) 			
		This.SetItem(ll_row, "category", This.GetItemString(ll_row, "ref_category")) 	
		This.SetItem(ll_row, "sub_category", This.GetItemString(ll_row, "ref_sub_category")) 		
		This.SetItem(ll_row, "last_updated_by", gnv_app.of_getuserid())
		This.SetItem(ll_row, "last_updated_dt", f_getdbdatetime())		
		This.SetItemStatus(ll_row, 0,  Primary!, NewModified!)
	End If
		
	ll_row = This.GetNextModified(ll_row, Primary!)

LOOP

Return AncestorReturnValue
end event

event sqlpreview;call super::sqlpreview;
Long ll_keyID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN
	
	ll_keyID = This.GetItemNumber(row, "gigp_id", buffer, False)
	
	f_transactionlog("gigp_id", ll_keyID, This.DataObject, "Bank Information", sqlsyntax)
END IF
end event

type shl_3 from statichyperlink within u_tabpg_disbursements
integer x = 1559
integer y = 16
integer width = 773
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
string text = "View Project Closeout Values"
boolean focusrectangle = false
end type

event clicked;
If (dw_closeout.Visible = False) Then
	dw_closeout.X = dw_1.X	
	dw_closeout.Y = dw_1.Y	
	dw_closeout.Visible = True
End If
end event

type dw_closeout from u_dw within u_tabpg_disbursements
boolean visible = false
integer x = 421
integer y = 472
integer width = 1417
integer height = 908
integer taborder = 10
boolean bringtotop = true
boolean titlebar = true
string title = "Project Closeout Values"
string dataobject = "d_closeout_values_rpt"
boolean controlmenu = true
boolean vscrollbar = false
boolean resizable = true
end type

event constructor;call super::constructor;This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

event pfc_retrieve;call super::pfc_retrieve;Return This.Retrieve(gl_gigp_id)
end event

type cb_retrelltr from commandbutton within u_tabpg_disbursements
integer x = 2414
integer y = 4
integer width = 393
integer height = 80
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Ret Rel Ltr"
end type

event clicked;parent.of_generate_retainage_letter()
end event

type cb_redi_memo from commandbutton within u_tabpg_disbursements
integer x = 2821
integer y = 4
integer width = 393
integer height = 80
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "REDI Memo"
end type

event clicked;parent.of_generateredimemo()
end event

type cb_redi_letter from commandbutton within u_tabpg_disbursements
integer x = 3227
integer y = 4
integer width = 393
integer height = 80
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "REDI Letter"
end type

event clicked;parent.of_generaterediletter()

end event

