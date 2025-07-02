forward
global type w_project_benefit from w_gigp_response
end type
type dw_benefits from u_dw_enhanced within w_project_benefit
end type
type pb_1 from picturebutton within w_project_benefit
end type
type st_calc from statictext within w_project_benefit
end type
type cb_1 from commandbutton within w_project_benefit
end type
end forward

global type w_project_benefit from w_gigp_response
integer width = 2482
integer height = 1404
string title = "Benefits"
dw_benefits dw_benefits
pb_1 pb_1
st_calc st_calc
cb_1 cb_1
end type
global w_project_benefit w_project_benefit

type variables
long il_gigp
end variables

event open;call super::open;il_gigp = Message.DoubleParm
end event

on w_project_benefit.create
int iCurrent
call super::create
this.dw_benefits=create dw_benefits
this.pb_1=create pb_1
this.st_calc=create st_calc
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_benefits
this.Control[iCurrent+2]=this.pb_1
this.Control[iCurrent+3]=this.st_calc
this.Control[iCurrent+4]=this.cb_1
end on

on w_project_benefit.destroy
call super::destroy
destroy(this.dw_benefits)
destroy(this.pb_1)
destroy(this.st_calc)
destroy(this.cb_1)
end on

event pfc_postopen;call super::pfc_postopen;dw_benefits.Event pfc_retrieve()
end event

type cb_cancel from w_gigp_response`cb_cancel within w_project_benefit
boolean visible = false
integer x = 1399
integer y = 1184
end type

type cb_ok from w_gigp_response`cb_ok within w_project_benefit
boolean visible = false
integer x = 1024
integer y = 1184
end type

event cb_ok::clicked;//override

Close(parent)
end event

type dw_benefits from u_dw_enhanced within w_project_benefit
integer x = 18
integer y = 20
integer width = 2382
integer height = 1056
integer taborder = 10
string dataobject = "d_project_benefits"
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;this.SetTransObject(SQLCA)
end event

event pfc_retrieve;call super::pfc_retrieve;long ll_ret
decimal ld_p, ld_wqv, ld_gallons, ld_linft, ld_acres

ll_ret = this.Retrieve(il_gigp)

If ll_ret > 0 Then
	
	If f_get_project_benefit_totals(il_gigp, ld_p, ld_wqv, ld_gallons, ld_linft, ld_acres) > 0 Then
		this.SetItem(1, 'p_inches', ld_p)
		this.SetItem(1, 'wqv', ld_wqv)
		this.SetItem(1, 'gallons', ld_gallons)
		this.SetItem(1, 'linft', ld_linft)
		this.SetItem(1, 'acres', ld_acres)
		
		this.SetItemStatus(1, 0, Primary!, NotModified!)
		
	End If
	
End If

st_calc.Visible = False

Return ll_ret
end event

type pb_1 from picturebutton within w_project_benefit
integer x = 59
integer y = 1196
integer width = 119
integer height = 104
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "Print!"
alignment htextalign = left!
end type

event clicked;dw_benefits.Event pfc_print()
end event

type st_calc from statictext within w_project_benefit
integer x = 229
integer y = 256
integer width = 1426
integer height = 296
boolean bringtotop = true
integer textsize = -36
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 15780518
long backcolor = 67108864
string text = " Calculating..."
boolean focusrectangle = false
end type

type cb_1 from commandbutton within w_project_benefit
integer x = 2057
integer y = 1188
integer width = 343
integer height = 100
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Close"
end type

event clicked;Close(parent)
end event

