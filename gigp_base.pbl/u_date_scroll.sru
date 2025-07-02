//objectcomments A handy userobject for selecting dates. Scrolls day by day.
forward
global type u_date_scroll from userobject
end type
type em_1 from editmask within u_date_scroll
end type
type vsb_1 from vscrollbar within u_date_scroll
end type
end forward

global type u_date_scroll from userobject
integer width = 475
integer height = 128
boolean border = true
long backcolor = 67108864
long tabtextcolor = 33554432
em_1 em_1
vsb_1 vsb_1
end type
global u_date_scroll u_date_scroll

forward prototypes
public function date of_getdate ()
public subroutine of_setdate (date ad_date)
end prototypes

public function date of_getdate ();Return Date(em_1.text)

end function

public subroutine of_setdate (date ad_date);em_1.Text = String(ad_date,"mm/dd/yyyy")

end subroutine

on u_date_scroll.create
this.em_1=create em_1
this.vsb_1=create vsb_1
this.Control[]={this.em_1,&
this.vsb_1}
end on

on u_date_scroll.destroy
destroy(this.em_1)
destroy(this.vsb_1)
end on

event constructor;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

end event

type em_1 from editmask within u_date_scroll
integer x = 18
integer y = 16
integer width = 352
integer height = 84
integer taborder = 1
integer textsize = -8
integer weight = 700
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long backcolor = 16777215
borderstyle borderstyle = stylelowered!
maskdatatype maskdatatype = datemask!
string mask = "mm/dd/yyyy"
end type

type vsb_1 from vscrollbar within u_date_scroll
integer x = 384
integer y = 16
integer width = 59
integer height = 84
end type

event linedown;if IsDate(em_1.text) then
	em_1.text = String(Relativedate(Date(em_1.text), -1),"mm/dd/yyyy")
else
	em_1.text = String(Today( ),"mm/dd/yyyy")
end if


end event

event lineup;if IsDate(em_1.text) then
	em_1.text = String(Relativedate(Date(em_1.text), 1),"mm/dd/yyyy")
else
	em_1.text = String(Today(),"mm/dd/yyyy")
end if


end event

