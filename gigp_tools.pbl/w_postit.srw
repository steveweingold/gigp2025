forward
global type w_postit from w_child
end type
type dw_1 from u_dw within w_postit
end type
end forward

global type w_postit from w_child
string tag = "POSTIT"
boolean visible = false
integer x = 214
integer y = 221
integer width = 2258
integer height = 1468
string title = "POSTIT"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
long backcolor = 65535
string icon = "DosEdit5!"
boolean clientedge = true
boolean center = true
windowanimationstyle openanimation = bottomslide!
windowanimationstyle closeanimation = bottomslide!
event ue_retrieve ( string as_types )
dw_1 dw_1
end type
global w_postit w_postit

type variables
string is_types[]
end variables

event ue_retrieve(string as_types);n_cst_string ln_string

ln_string.of_ParseToArray(as_types,',', is_types)

dw_1.Event pfc_retrieve()
end event

on w_postit.create
int iCurrent
call super::create
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on w_postit.destroy
call super::destroy
destroy(this.dw_1)
end on

type dw_1 from u_dw within w_postit
integer x = 18
integer y = 4
integer width = 2185
integer height = 1344
integer taborder = 10
string dataobject = "d_postit_note"
boolean hscrollbar = true
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

event pfc_retrieve;call super::pfc_retrieve;
Long ll_rows

ll_rows = This.Retrieve(gl_gigp_id, is_types)


If (ll_rows > 0) Then
	Parent.Visible = True
Else
	Parent.Visible = False	
End If

Return ll_rows
end event

