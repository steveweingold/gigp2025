forward
global type w_funding_buckets from w_gigp_response
end type
type dw_funding_buckets from u_dw_enhanced within w_funding_buckets
end type
type st_1 from statictext within w_funding_buckets
end type
type ddlb_round from dropdownlistbox within w_funding_buckets
end type
type gb_1 from groupbox within w_funding_buckets
end type
end forward

global type w_funding_buckets from w_gigp_response
integer width = 3995
integer height = 2660
string title = "Funding Buckets"
dw_funding_buckets dw_funding_buckets
st_1 st_1
ddlb_round ddlb_round
gb_1 gb_1
end type
global w_funding_buckets w_funding_buckets

type variables
long ii_round
end variables

on w_funding_buckets.create
int iCurrent
call super::create
this.dw_funding_buckets=create dw_funding_buckets
this.st_1=create st_1
this.ddlb_round=create ddlb_round
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_funding_buckets
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.ddlb_round
this.Control[iCurrent+4]=this.gb_1
end on

on w_funding_buckets.destroy
call super::destroy
destroy(this.dw_funding_buckets)
destroy(this.st_1)
destroy(this.ddlb_round)
destroy(this.gb_1)
end on

event pfc_preopen;call super::pfc_preopen;//Access group for update ability
//However - as per Mike M (2/2019) NO edit access should be allowed at this point
is_accessGroups = {"Funding"}
end event

event closequery;//Override
If is_action <> 'CANCEL' Then
	Call Super::closequery
	
End If
end event

type cb_cancel from w_gigp_response`cb_cancel within w_funding_buckets
integer x = 1906
integer y = 2456
end type

type cb_ok from w_gigp_response`cb_ok within w_funding_buckets
integer x = 1509
integer y = 2456
end type

type dw_funding_buckets from u_dw_enhanced within w_funding_buckets
integer x = 55
integer y = 248
integer width = 3881
integer height = 2156
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_funding_buckets"
boolean border = false
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;this.SetTransObject(SQLCA)
end event

event pfc_retrieve;call super::pfc_retrieve;If ii_round > 0 Then
	Return this.Retrieve(ii_round)
End If
end event

event rbuttondown;//Override
end event

event rbuttonup;//Override
end event

type st_1 from statictext within w_funding_buckets
integer x = 1074
integer y = 76
integer width = 1838
integer height = 100
boolean bringtotop = true
integer textsize = -14
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "GIGP Federal / State Funding Buckets"
alignment alignment = center!
boolean focusrectangle = false
end type

type ddlb_round from dropdownlistbox within w_funding_buckets
integer x = 114
integer y = 112
integer width = 352
integer height = 444
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

event selectionchanged;ii_round = Integer(this.Text(index))
dw_funding_buckets.Event pfc_retrieve()
end event

event constructor;long ll_row, ll_count
integer li_round
datastore lds_data

//Retrieve Rounds for funding buckets (not all rounds)
If NOT IsValid(lds_data) then lds_data = create Datastore
lds_data.DataObject = 'dddw_round_no_funding_buckets'
lds_data.SetTransObject(SQLCA)

ll_count = lds_data.Retrieve()

//Populate ddlb (using a DDLB so framework security allows it to be used by anyone)
If ll_count > 0 Then
	For ll_row = 1 to ll_count
		li_round = lds_data.GetItemNumber(ll_row, 'round_no')
		this.AddItem(String(li_round))
	Next
	
	ii_round = lds_data.GetItemNumber(1,'round_no')
	ddlb_round.SelectItem(String(ii_round),0)
	dw_funding_buckets. Event pfc_retrieve()
End If

If IsValid(lds_data) Then DESTROY lds_data
end event

type gb_1 from groupbox within w_funding_buckets
integer x = 55
integer y = 36
integer width = 457
integer height = 200
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Select Round:"
end type

