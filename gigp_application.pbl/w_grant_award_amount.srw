forward
global type w_grant_award_amount from w_gigp_response
end type
type dw_1 from u_dw within w_grant_award_amount
end type
end forward

global type w_grant_award_amount from w_gigp_response
integer x = 214
integer y = 221
integer width = 1193
integer height = 1464
dw_1 dw_1
end type
global w_grant_award_amount w_grant_award_amount

on w_grant_award_amount.create
int iCurrent
call super::create
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on w_grant_award_amount.destroy
call super::destroy
destroy(this.dw_1)
end on

event ue_check_access;//Override
end event

type cb_cancel from w_gigp_response`cb_cancel within w_grant_award_amount
boolean visible = false
integer x = 581
integer y = 1240
end type

type cb_ok from w_gigp_response`cb_ok within w_grant_award_amount
integer x = 416
integer y = 1240
end type

type dw_1 from u_dw within w_grant_award_amount
integer x = 27
integer y = 20
integer width = 1115
integer height = 1176
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_grant_award_amounts"
end type

event constructor;call super::constructor;this.SetTransObject(SQLCA)
this.Retrieve()
end event

