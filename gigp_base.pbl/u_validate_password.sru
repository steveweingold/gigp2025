forward
global type u_validate_password from userobject
end type
type ole_1 from olecustomcontrol within u_validate_password
end type
end forward

global type u_validate_password from userobject
integer width = 137
integer height = 116
long backcolor = 67108864
string text = "none"
long tabtextcolor = 33554432
long picturemaskcolor = 536870912
ole_1 ole_1
end type
global u_validate_password u_validate_password

forward prototypes
public function boolean of_validatepassword (string as_username, string as_password, string as_tree)
end prototypes

public function boolean of_validatepassword (string as_username, string as_password, string as_tree);SetPointer(HourGlass!)

Return ole_1.Object.ValidatePassword(as_Password,as_Tree + as_UserName)

end function

on u_validate_password.create
this.ole_1=create ole_1
this.Control[]={this.ole_1}
end on

on u_validate_password.destroy
destroy(this.ole_1)
end on

type ole_1 from olecustomcontrol within u_validate_password
integer width = 128
integer height = 112
integer taborder = 10
borderstyle borderstyle = stylelowered!
boolean focusrectangle = false
string binarykey = "u_validate_password.udo"
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
end type

