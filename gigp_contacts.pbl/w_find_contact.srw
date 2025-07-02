forward
global type w_find_contact from w_pick_list
end type
type cb_1 from commandbutton within w_find_contact
end type
type st_1 from statictext within w_find_contact
end type
type sle_find from singlelineedit within w_find_contact
end type
type cb_find from commandbutton within w_find_contact
end type
type st_filter from statictext within w_find_contact
end type
type rr_1 from roundrectangle within w_find_contact
end type
type cb_2 from commandbutton within w_find_contact
end type
end forward

global type w_find_contact from w_pick_list
integer x = 214
integer y = 221
integer width = 4238
integer height = 2112
string title = "Select a Contact"
cb_1 cb_1
st_1 st_1
sle_find sle_find
cb_find cb_find
st_filter st_filter
rr_1 rr_1
cb_2 cb_2
end type
global w_find_contact w_find_contact

type variables
boolean ib_filtered
end variables

forward prototypes
public subroutine of_filter (boolean ab_filter)
public subroutine of_openupdate (string as_type)
end prototypes

public subroutine of_filter (boolean ab_filter);If ab_filter then
	st_filter.Text = 'Filter ON'
	
Else
	dw_list.SetFilter('')
	dw_list.Filter()
	sle_find.Text = ''
	st_filter.Text = 'Filter OFF'
	
End If


end subroutine

public subroutine of_openupdate (string as_type);long ll_row
str_contactparms lstr_parms

//Get the ID of the Contact to add or use -1 for new
If as_type = 'Edit' Then  //Edit exisiting
	ll_row = dw_list.GetRow()
	
	If ll_row > 0 Then
		lstr_parms.str_contactid = dw_list.GetItemNumber(ll_row, 'contact_id')
	Else
		Return
	End If
	
Else	//New
	lstr_parms.str_contactid = -1
	
End If

//Set the GIGP Id
lstr_parms.str_gigpid =  gl_gigp_id

//Open the edit window
OpenWithParm(w_contacts_edit,lstr_parms)
Close(this)
end subroutine

on w_find_contact.create
int iCurrent
call super::create
this.cb_1=create cb_1
this.st_1=create st_1
this.sle_find=create sle_find
this.cb_find=create cb_find
this.st_filter=create st_filter
this.rr_1=create rr_1
this.cb_2=create cb_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.sle_find
this.Control[iCurrent+4]=this.cb_find
this.Control[iCurrent+5]=this.st_filter
this.Control[iCurrent+6]=this.rr_1
this.Control[iCurrent+7]=this.cb_2
end on

on w_find_contact.destroy
call super::destroy
destroy(this.cb_1)
destroy(this.st_1)
destroy(this.sle_find)
destroy(this.cb_find)
destroy(this.st_filter)
destroy(this.rr_1)
destroy(this.cb_2)
end on

event pfc_postopen;call super::pfc_postopen;sle_find.SetFocus()
end event

event pfc_default;//Override

of_openUpdate('Edit')
end event

type dw_list from w_pick_list`dw_list within w_find_contact
integer y = 208
integer width = 4096
integer height = 1596
string dataobject = "d_find_contacts_list"
end type

event dw_list::pfc_retrieve;call super::pfc_retrieve;Return this.Retrieve()
end event

type cb_ok from w_pick_list`cb_ok within w_find_contact
integer x = 197
integer y = 1896
end type

type cb_cancel from w_pick_list`cb_cancel within w_find_contact
integer x = 599
integer y = 1896
end type

type cb_1 from commandbutton within w_find_contact
integer x = 3611
integer y = 1896
integer width = 352
integer height = 92
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string text = "New"
end type

event clicked;of_openUpdate('New')
end event

type st_1 from statictext within w_find_contact
integer x = 59
integer y = 64
integer width = 155
integer height = 52
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Find:"
boolean focusrectangle = false
end type

type sle_find from singlelineedit within w_find_contact
integer x = 210
integer y = 44
integer width = 1248
integer height = 92
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

event getfocus;cb_find.Default = True
end event

type cb_find from commandbutton within w_find_contact
integer x = 1472
integer y = 44
integer width = 270
integer height = 92
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string text = "Find"
end type

event clicked;String ls_value, ls_filter

ls_value = Upper(sle_find.Text)
ls_filter =  "(Upper(full_name) like '%" + ls_value +  "%' ) OR (Upper(title) like '%" + ls_value +  "%') OR (Upper(organization) like '%" + ls_value +  "%') OR (Upper(cc_address) like '%" + ls_value +  "%')" 

dw_list.SetFilter(ls_filter)
dw_list.Filter()

of_filter(True)
this.Default = False
cb_ok.Default = True
end event

type st_filter from statictext within w_find_contact
integer x = 1851
integer y = 56
integer width = 416
integer height = 68
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 128
long backcolor = 16777215
string text = "Filter OFF"
alignment alignment = center!
boolean focusrectangle = false
end type

type rr_1 from roundrectangle within w_find_contact
integer linethickness = 4
long fillcolor = 16777215
integer x = 1838
integer y = 32
integer width = 686
integer height = 112
integer cornerheight = 40
integer cornerwidth = 46
end type

type cb_2 from commandbutton within w_find_contact
integer x = 2272
integer y = 44
integer width = 206
integer height = 92
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string text = "Clear"
end type

event clicked;of_filter(False)
end event

