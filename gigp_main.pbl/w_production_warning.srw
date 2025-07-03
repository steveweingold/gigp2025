forward
global type w_production_warning from window
end type
type st_3 from statictext within w_production_warning
end type
type st_1 from statictext within w_production_warning
end type
end forward

global type w_production_warning from window
integer width = 2167
integer height = 644
boolean titlebar = true
string title = "WARNING!!"
boolean controlmenu = true
boolean minbox = true
windowtype windowtype = popup!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
st_3 st_3
st_1 st_1
end type
global w_production_warning w_production_warning

on w_production_warning.create
this.st_3=create st_3
this.st_1=create st_1
this.Control[]={this.st_3,&
this.st_1}
end on

on w_production_warning.destroy
destroy(this.st_3)
destroy(this.st_1)
end on

type st_3 from statictext within w_production_warning
integer y = 440
integer width = 2153
integer height = 88
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "To go back to Production, close ALL database apps and log back into the Hub"
alignment alignment = center!
boolean focusrectangle = false
end type

type st_1 from statictext within w_production_warning
integer x = 197
integer y = 44
integer width = 1719
integer height = 292
integer textsize = -20
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "YOU ARE CONNECTED TO A TEST DATABASE"
alignment alignment = center!
boolean focusrectangle = false
end type

