forward
global type w_cfa_contact_match from w_gigp_response
end type
type st_1 from statictext within w_cfa_contact_match
end type
type cb_app_add from commandbutton within w_cfa_contact_match
end type
type cb_app_match from commandbutton within w_cfa_contact_match
end type
type cb_prc_add from commandbutton within w_cfa_contact_match
end type
type cb_prc_match from commandbutton within w_cfa_contact_match
end type
type cb_oth_add from commandbutton within w_cfa_contact_match
end type
type cb_oth_match from commandbutton within w_cfa_contact_match
end type
type dw_contacts from u_dw_enhanced within w_cfa_contact_match
end type
type app1 from statictext within w_cfa_contact_match
end type
type app2 from statictext within w_cfa_contact_match
end type
type app3 from statictext within w_cfa_contact_match
end type
type app4 from statictext within w_cfa_contact_match
end type
type app5 from statictext within w_cfa_contact_match
end type
type app6 from statictext within w_cfa_contact_match
end type
type prim1 from statictext within w_cfa_contact_match
end type
type prim2 from statictext within w_cfa_contact_match
end type
type prim3 from statictext within w_cfa_contact_match
end type
type prim4 from statictext within w_cfa_contact_match
end type
type prim5 from statictext within w_cfa_contact_match
end type
type prim6 from statictext within w_cfa_contact_match
end type
type oth1 from statictext within w_cfa_contact_match
end type
type oth2 from statictext within w_cfa_contact_match
end type
type oth3 from statictext within w_cfa_contact_match
end type
type oth4 from statictext within w_cfa_contact_match
end type
type oth5 from statictext within w_cfa_contact_match
end type
type oth6 from statictext within w_cfa_contact_match
end type
type cb_1 from commandbutton within w_cfa_contact_match
end type
type sle_find from singlelineedit within w_cfa_contact_match
end type
type cb_find from commandbutton within w_cfa_contact_match
end type
type cb_3 from commandbutton within w_cfa_contact_match
end type
type gb_1 from groupbox within w_cfa_contact_match
end type
type gb_2 from groupbox within w_cfa_contact_match
end type
type gb_3 from groupbox within w_cfa_contact_match
end type
type gb_4 from groupbox within w_cfa_contact_match
end type
type gb_5 from groupbox within w_cfa_contact_match
end type
end forward

global type w_cfa_contact_match from w_gigp_response
integer x = 214
integer y = 221
integer width = 4489
integer height = 2256
st_1 st_1
cb_app_add cb_app_add
cb_app_match cb_app_match
cb_prc_add cb_prc_add
cb_prc_match cb_prc_match
cb_oth_add cb_oth_add
cb_oth_match cb_oth_match
dw_contacts dw_contacts
app1 app1
app2 app2
app3 app3
app4 app4
app5 app5
app6 app6
prim1 prim1
prim2 prim2
prim3 prim3
prim4 prim4
prim5 prim5
prim6 prim6
oth1 oth1
oth2 oth2
oth3 oth3
oth4 oth4
oth5 oth5
oth6 oth6
cb_1 cb_1
sle_find sle_find
cb_find cb_find
cb_3 cb_3
gb_1 gb_1
gb_2 gb_2
gb_3 gb_3
gb_4 gb_4
gb_5 gb_5
end type
global w_cfa_contact_match w_cfa_contact_match

type variables
integer ii_round
long il_cfa
end variables

forward prototypes
public function string of_get_answer (integer ai_question, integer ai_application)
public function integer of_match (string as_type)
public function integer of_new (string as_type)
end prototypes

public function string of_get_answer (integer ai_question, integer ai_application);string ls_answer

select Max(convert(char(255), answer))
into :ls_answer
from gigp_cfa_raw_data
where app_id = :ai_application
and question_id = :ai_question
and round_no = :ii_round;

If IsNull(ls_answer) Then ls_answer = ''

Return ls_answer
end function

public function integer of_match (string as_type);long ll_contact
String ls_confirm

If dw_contacts.GetSelectedRow(0) <= 0 Then
	MessageBox('Contact Match', 'Please choose a contact')
	Return -1
End If

ll_contact = dw_contacts.GetItemNumber(dw_contacts.GetSelectedRow(0), 'contact_id')

If IsNull(ll_contact) or ll_contact <= 0 Then
	MessageBox('Contact Match', 'Invalid contact chosen')
	Return -1
End If

Choose Case as_type
	Case 'APP'
		ls_confirm = 'APPLICANT'
		
	Case 'OTH'
		ls_confirm = 'OTHER Contact'
		
	Case 'PRC'
		ls_confirm = 'PRIMARY Contact'
		
End Choose

If MessageBox('Contact Match', 'Are you sure you want to use Contact ID ' + String(ll_contact) + ' for the ' + ls_confirm + '?', Question!, YesNo!, 2) = 1 Then

	insert into gigp_contact_links (contact_id, gigp_id, contact_type)
	Values (:ll_contact, :gl_gigp_id, :as_type);
	
End If

Return 1
end function

public function integer of_new (string as_type);string ls_confirm, ls_fname, ls_lname, ls_fullname, ls_title, ls_addr, ls_city, ls_state, ls_zip, ls_email, ls_phone, ls_applicant
long ll_contact
n_cst_string ln_string


Choose Case as_type
	Case 'APP'
		ls_confirm = 'APPLICANT'
	Case 'OTH'
		ls_confirm = 'OTHER Contact'
	Case 'PRC'
		ls_confirm = 'PRIMARY Contact'
End Choose

If MessageBox('Contact Match', 'Are you sure you want to create a NEW contact for the ' + ls_confirm + '?', Question!, YesNo!, 2) = 2 Then
	Return -1
End If

 ll_contact = f_gettokenvalue('contactID', 1)
 
Choose Case as_type
	Case 'APP'
		ls_applicant = of_get_answer(546, il_cfa)
		ls_addr = of_get_answer(551, il_cfa)
		ls_city = of_get_answer(552, il_cfa)
		ls_state = of_get_answer(553, il_cfa)
		ls_zip = of_get_answer(554, il_cfa)
		ls_email = of_get_answer(555, il_cfa)
		ls_phone = of_get_answer(651, il_cfa)
		
		ls_phone = ln_string.of_globalreplace(ls_phone, '-', '')
		ls_phone = ln_string.of_globalreplace(ls_phone, '(', '')
		ls_phone = ln_string.of_globalreplace(ls_phone, ')', '')
		ls_phone = ln_string.of_globalreplace(ls_phone, ' ', '')
		
		insert into gigp_contacts (contact_id, organization, mail_address1, mail_city, mail_state, mail_zip, email, phone_1, status, last_updated_by, last_updated_dt)
		values (:ll_contact, :ls_applicant,  :ls_addr, :ls_city, :ls_state, :ls_zip, :ls_email, :ls_phone, 'Active', 'SYSTEM', getdate());

	Case 'OTH'
		ls_fname = of_get_answer(1052, il_cfa)
		ls_lname = of_get_answer(970, il_cfa)
		ls_title = of_get_answer(1051, il_cfa)
		ls_email = of_get_answer(561, il_cfa)
		ls_phone = of_get_answer(562, il_cfa)
		
		ls_phone = ln_string.of_globalreplace(ls_phone, '-', '')
		ls_phone = ln_string.of_globalreplace(ls_phone, '(', '')
		ls_phone = ln_string.of_globalreplace(ls_phone, ')', '')
		ls_phone = ln_string.of_globalreplace(ls_phone, ' ', '')
		
		If NOT IsNull(ls_fname) and NOT IsNull(ls_lname) Then
			ls_fullname = ls_fname + ' ' + ls_lname
		Else
			ls_fullname = ''
		End If
		
		insert into gigp_contacts (contact_id, first_name, last_name, title, full_name, email, phone_1, status, last_updated_by, last_updated_dt)
		values (:ll_contact, :ls_fname, :ls_lname, :ls_title, :ls_fullname, :ls_email, :ls_phone, 'Active', 'SYSTEM', getdate());
		
	Case 'PRC'
		ls_fname = of_get_answer(547, il_cfa)
		ls_lname = of_get_answer(1049, il_cfa)
		ls_title = of_get_answer(1050, il_cfa)
		
		If NOT IsNull(ls_fname) and NOT IsNull(ls_lname) Then
			ls_fullname = ls_fname + ' ' + ls_lname
		Else
			ls_fullname = ''
		End If
		
		If MessageBox("New Primary", "Use Applicant Contact info?", Question!, YesNo!, 2) = 1 Then		
			ls_addr = of_get_answer(551, il_cfa)
			ls_city = of_get_answer(552, il_cfa)
			ls_state = of_get_answer(553, il_cfa)
			ls_zip = of_get_answer(554, il_cfa)
			ls_email = of_get_answer(555, il_cfa)
			ls_phone = of_get_answer(651, il_cfa)
			
			ls_phone = ln_string.of_globalreplace(ls_phone, '-', '')
			ls_phone = ln_string.of_globalreplace(ls_phone, '(', '')
			ls_phone = ln_string.of_globalreplace(ls_phone, ')', '')
			ls_phone = ln_string.of_globalreplace(ls_phone, ' ', '')


			insert into gigp_contacts (contact_id, first_name, last_name, title, full_name, mail_address1, mail_city, mail_state, mail_zip, email, phone_1, status, last_updated_by, last_updated_dt)
			values (:ll_contact, :ls_fname, :ls_lname, :ls_title, :ls_fullname, :ls_addr, :ls_city, :ls_state, :ls_zip, :ls_email, :ls_phone, 'Active', 'SYSTEM', getdate());
		
		Else
			insert into gigp_contacts (contact_id, first_name, last_name, title, full_name, status, last_updated_by, last_updated_dt)
			values (:ll_contact, :ls_fname, :ls_lname, :ls_title, :ls_fullname,  'Active', 'SYSTEM', getdate());
			
		End If
		
		
End Choose


//Insert link
insert into gigp_contact_links (contact_id, gigp_id, contact_type)
Values (:ll_contact, :gl_gigp_id, :as_type);

MessageBox(ls_confirm, 'New Contact created.')

Return 1

end function

on w_cfa_contact_match.create
int iCurrent
call super::create
this.st_1=create st_1
this.cb_app_add=create cb_app_add
this.cb_app_match=create cb_app_match
this.cb_prc_add=create cb_prc_add
this.cb_prc_match=create cb_prc_match
this.cb_oth_add=create cb_oth_add
this.cb_oth_match=create cb_oth_match
this.dw_contacts=create dw_contacts
this.app1=create app1
this.app2=create app2
this.app3=create app3
this.app4=create app4
this.app5=create app5
this.app6=create app6
this.prim1=create prim1
this.prim2=create prim2
this.prim3=create prim3
this.prim4=create prim4
this.prim5=create prim5
this.prim6=create prim6
this.oth1=create oth1
this.oth2=create oth2
this.oth3=create oth3
this.oth4=create oth4
this.oth5=create oth5
this.oth6=create oth6
this.cb_1=create cb_1
this.sle_find=create sle_find
this.cb_find=create cb_find
this.cb_3=create cb_3
this.gb_1=create gb_1
this.gb_2=create gb_2
this.gb_3=create gb_3
this.gb_4=create gb_4
this.gb_5=create gb_5
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
this.Control[iCurrent+2]=this.cb_app_add
this.Control[iCurrent+3]=this.cb_app_match
this.Control[iCurrent+4]=this.cb_prc_add
this.Control[iCurrent+5]=this.cb_prc_match
this.Control[iCurrent+6]=this.cb_oth_add
this.Control[iCurrent+7]=this.cb_oth_match
this.Control[iCurrent+8]=this.dw_contacts
this.Control[iCurrent+9]=this.app1
this.Control[iCurrent+10]=this.app2
this.Control[iCurrent+11]=this.app3
this.Control[iCurrent+12]=this.app4
this.Control[iCurrent+13]=this.app5
this.Control[iCurrent+14]=this.app6
this.Control[iCurrent+15]=this.prim1
this.Control[iCurrent+16]=this.prim2
this.Control[iCurrent+17]=this.prim3
this.Control[iCurrent+18]=this.prim4
this.Control[iCurrent+19]=this.prim5
this.Control[iCurrent+20]=this.prim6
this.Control[iCurrent+21]=this.oth1
this.Control[iCurrent+22]=this.oth2
this.Control[iCurrent+23]=this.oth3
this.Control[iCurrent+24]=this.oth4
this.Control[iCurrent+25]=this.oth5
this.Control[iCurrent+26]=this.oth6
this.Control[iCurrent+27]=this.cb_1
this.Control[iCurrent+28]=this.sle_find
this.Control[iCurrent+29]=this.cb_find
this.Control[iCurrent+30]=this.cb_3
this.Control[iCurrent+31]=this.gb_1
this.Control[iCurrent+32]=this.gb_2
this.Control[iCurrent+33]=this.gb_3
this.Control[iCurrent+34]=this.gb_4
this.Control[iCurrent+35]=this.gb_5
end on

on w_cfa_contact_match.destroy
call super::destroy
destroy(this.st_1)
destroy(this.cb_app_add)
destroy(this.cb_app_match)
destroy(this.cb_prc_add)
destroy(this.cb_prc_match)
destroy(this.cb_oth_add)
destroy(this.cb_oth_match)
destroy(this.dw_contacts)
destroy(this.app1)
destroy(this.app2)
destroy(this.app3)
destroy(this.app4)
destroy(this.app5)
destroy(this.app6)
destroy(this.prim1)
destroy(this.prim2)
destroy(this.prim3)
destroy(this.prim4)
destroy(this.prim5)
destroy(this.prim6)
destroy(this.oth1)
destroy(this.oth2)
destroy(this.oth3)
destroy(this.oth4)
destroy(this.oth5)
destroy(this.oth6)
destroy(this.cb_1)
destroy(this.sle_find)
destroy(this.cb_find)
destroy(this.cb_3)
destroy(this.gb_1)
destroy(this.gb_2)
destroy(this.gb_3)
destroy(this.gb_4)
destroy(this.gb_5)
end on

event pfc_postopen;call super::pfc_postopen;long ll_count
string ls_applicant, ls_addr, ls_city, ls_state, ls_zip, ls_email, ls_phone, ls_fname, ls_lname, ls_title
n_cst_string ln_string

//Check for existing links
select count(*)
into :ll_count
from gigp_contact_links
where gigp_id = :gl_gigp_id
and contact_type = 'APP';


ii_round = 4

select cfa_no
into :il_cfa
from gigp_application
where gigp_id = :gl_gigp_id;

If IsNull(il_cfa) or il_cfa <= 0 Then
	MessageBox('CFA Match', 'No CFA Application found for this GIGPId')
	Close(this)
End If
	
//Set Applicant info
ls_applicant = of_get_answer(546, il_cfa)
ls_addr = of_get_answer(551, il_cfa)
ls_city = of_get_answer(552, il_cfa)
ls_state = of_get_answer(553, il_cfa)
ls_zip = of_get_answer(554, il_cfa)
ls_email = of_get_answer(555, il_cfa)
ls_phone = of_get_answer(651, il_cfa)

app1.Text = ls_applicant
app2.Text = ls_addr
app3.Text = ls_city
app4.Text = ls_state + '  ' + ls_zip
app5.Text = ls_email
app6.Text = ls_phone


//Set "Other" Contact???
ls_fname = of_get_answer(1052, il_cfa)
ls_lname = of_get_answer(970, il_cfa)
ls_title = of_get_answer(1051, il_cfa)
ls_email = of_get_answer(561, il_cfa)
ls_phone = of_get_answer(562, il_cfa)

oth1.Text = ls_fname + ' ' + ls_lname
oth2.Text = ls_title
oth3.Text = ls_email
oth4.Text = ls_phone


//Set "Primary" Contact???
ls_fname = of_get_answer(547, il_cfa)
ls_lname = of_get_answer(1049, il_cfa)
ls_title = of_get_answer(1050, il_cfa)

prim1.Text = ls_fname + ' ' + ls_lname
prim2.Text = ls_title

sle_find.SetFocus()
end event

type cb_cancel from w_gigp_response`cb_cancel within w_cfa_contact_match
integer x = 3927
integer y = 2028
end type

type cb_ok from w_gigp_response`cb_ok within w_cfa_contact_match
integer x = 3529
integer y = 2028
end type

type st_1 from statictext within w_cfa_contact_match
integer x = 50
integer y = 20
integer width = 366
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
string text = "From the CFA:"
boolean focusrectangle = false
end type

type cb_app_add from commandbutton within w_cfa_contact_match
integer x = 910
integer y = 272
integer width = 375
integer height = 100
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Insert New"
end type

event clicked;parent.of_new('APP')
end event

type cb_app_match from commandbutton within w_cfa_contact_match
integer x = 910
integer y = 408
integer width = 375
integer height = 100
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Use Selected"
end type

event clicked;parent.of_match('APP')


end event

type cb_prc_add from commandbutton within w_cfa_contact_match
integer x = 910
integer y = 940
integer width = 375
integer height = 100
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Insert New"
end type

event clicked;parent.of_new('PRC')
end event

type cb_prc_match from commandbutton within w_cfa_contact_match
integer x = 910
integer y = 1076
integer width = 375
integer height = 100
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Use Selected"
end type

event clicked;parent.of_match('PRC')


end event

type cb_oth_add from commandbutton within w_cfa_contact_match
integer x = 910
integer y = 1596
integer width = 375
integer height = 100
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Insert New"
end type

event clicked;parent.of_new('OTH')
end event

type cb_oth_match from commandbutton within w_cfa_contact_match
integer x = 910
integer y = 1732
integer width = 375
integer height = 100
integer taborder = 50
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Use Selected"
end type

event clicked;parent.of_match('OTH')

end event

type dw_contacts from u_dw_enhanced within w_cfa_contact_match
integer x = 1394
integer y = 324
integer width = 2985
integer height = 1632
integer taborder = 11
boolean bringtotop = true
string dataobject = "d_contacts_cfa_match"
end type

event constructor;call super::constructor;//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)

//********************************************************************
// Start PFC Sort Service:
//********************************************************************

This.of_SetSort(True)
This.inv_sort.of_SetColumnHeader(TRUE)

this.SetTransObject(SQLCA)
this.Retrieve()


end event

event doubleclicked;call super::doubleclicked;Long ll_row, ll_contactID, ll_rc
str_contactparms lstr_parms

ll_contactID = this.GetItemNumber(row, "contact_id")

lstr_parms.str_contactid = ll_contactID

lstr_parms.str_gigpid =  gl_gigp_id

OpenWithParm(w_contacts_edit, lstr_parms)

ll_contactID = Message.DoubleParm

If ll_contactID > 0 Then
	this.Retrieve()
	
	ll_row = this.Find('contact_id = ' + String(ll_contactID), 1, this.RowCount())
	
	If ll_row > 0 Then
		this.ScrollToRow(ll_row)
	End If
	
End IF
end event

type app1 from statictext within w_cfa_contact_match
integer x = 55
integer y = 196
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type app2 from statictext within w_cfa_contact_match
integer x = 55
integer y = 272
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type app3 from statictext within w_cfa_contact_match
integer x = 55
integer y = 348
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type app4 from statictext within w_cfa_contact_match
integer x = 55
integer y = 424
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type app5 from statictext within w_cfa_contact_match
integer x = 55
integer y = 500
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type app6 from statictext within w_cfa_contact_match
integer x = 55
integer y = 576
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type prim1 from statictext within w_cfa_contact_match
integer x = 55
integer y = 836
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type prim2 from statictext within w_cfa_contact_match
integer x = 55
integer y = 912
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type prim3 from statictext within w_cfa_contact_match
integer x = 55
integer y = 988
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type prim4 from statictext within w_cfa_contact_match
integer x = 55
integer y = 1064
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type prim5 from statictext within w_cfa_contact_match
integer x = 55
integer y = 1140
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type prim6 from statictext within w_cfa_contact_match
integer x = 55
integer y = 1216
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type oth1 from statictext within w_cfa_contact_match
integer x = 55
integer y = 1492
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type oth2 from statictext within w_cfa_contact_match
integer x = 55
integer y = 1568
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type oth3 from statictext within w_cfa_contact_match
integer x = 55
integer y = 1644
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type oth4 from statictext within w_cfa_contact_match
integer x = 55
integer y = 1720
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type oth5 from statictext within w_cfa_contact_match
integer x = 55
integer y = 1796
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type oth6 from statictext within w_cfa_contact_match
integer x = 55
integer y = 1872
integer width = 791
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
boolean focusrectangle = false
end type

type cb_1 from commandbutton within w_cfa_contact_match
integer x = 1664
integer y = 2028
integer width = 343
integer height = 100
integer taborder = 60
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Refresh"
end type

event clicked;dw_contacts.Retrieve()
end event

type sle_find from singlelineedit within w_cfa_contact_match
integer x = 1381
integer y = 112
integer width = 1239
integer height = 76
integer taborder = 20
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

type cb_find from commandbutton within w_cfa_contact_match
integer x = 2642
integer y = 108
integer width = 302
integer height = 80
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Find"
boolean default = true
end type

event clicked;string ls_find, ls_string
long ll_find, ll_row

ls_find = sle_find.Text

If IsNull(ls_find) or ls_find = '' Then Return

ll_row = dw_contacts.GetRow()

If ll_row <= 0 Then Return
If ll_row = dw_contacts.RowCount() Then Return

If ll_row = 1 then ll_row = 0

ls_string = "(Upper(full_name) like '%" + Upper(ls_find) + "%') or (Upper(organization) like '%" + Upper(ls_find) + "%')"

ll_find = dw_contacts.Find(ls_string, ll_row + 1, dw_contacts.RowCount())

If ll_find > 0 Then
	dw_contacts.ScrollToRow(ll_find)
	
End If
end event

type cb_3 from commandbutton within w_cfa_contact_match
integer x = 2967
integer y = 108
integer width = 302
integer height = 80
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Top"
end type

event clicked;dw_contacts.ScrollToRow(1)
end event

type gb_1 from groupbox within w_cfa_contact_match
integer x = 27
integer y = 112
integer width = 855
integer height = 568
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Applicant"
end type

type gb_2 from groupbox within w_cfa_contact_match
integer x = 27
integer y = 760
integer width = 855
integer height = 568
integer taborder = 20
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Primary Contact"
end type

type gb_3 from groupbox within w_cfa_contact_match
integer x = 27
integer y = 1408
integer width = 855
integer height = 568
integer taborder = 30
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Other Contact"
end type

type gb_4 from groupbox within w_cfa_contact_match
integer x = 1339
integer y = 252
integer width = 3086
integer height = 1732
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "From GIGP  (Double-Click to Edit)"
end type

type gb_5 from groupbox within w_cfa_contact_match
integer x = 1339
integer y = 36
integer width = 3086
integer height = 192
integer taborder = 20
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Search"
end type

