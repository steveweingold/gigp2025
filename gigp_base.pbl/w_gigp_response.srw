forward
global type w_gigp_response from w_response
end type
type cb_cancel from commandbutton within w_gigp_response
end type
type cb_ok from commandbutton within w_gigp_response
end type
end forward

global type w_gigp_response from w_response
integer height = 1064
boolean center = true
windowanimationstyle openanimation = fadeanimation!
windowanimationstyle closeanimation = fadeanimation!
event ue_process ( )
event ue_check_access ( )
cb_cancel cb_cancel
cb_ok cb_ok
end type
global w_gigp_response w_gigp_response

type variables

String 	is_action = "CANCEL"
String 	is_accessGroups[]
Boolean 	ib_editAccess
end variables

event ue_process();
return
end event

event ue_check_access();
Long ll_index, ll_upper
u_dw lu_dw

//*******************************************************
// Check for edit access:
//*******************************************************

ib_editAccess = gnv_app.of_ingroup(is_accessGroups)

If (ib_editAccess = True) Then
	
Else
	This.Title = (This.Title + " [Read Only]")
	
	cb_ok.Visible = False
	cb_cancel.Text = cb_ok.Text
	
	ll_upper = UpperBound(Control)
	
	FOR ll_index = 1 To ll_upper
		
		IF TypeOf(Control[ll_index]) = Datawindow! THEN

			lu_dw = Control[ll_index]		
			lu_dw.Modify("DataWindow.ReadOnly=Yes")

      END IF    	

	NEXT
	
End If

end event

on w_gigp_response.create
int iCurrent
call super::create
this.cb_cancel=create cb_cancel
this.cb_ok=create cb_ok
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_cancel
this.Control[iCurrent+2]=this.cb_ok
end on

on w_gigp_response.destroy
call super::destroy
destroy(this.cb_cancel)
destroy(this.cb_ok)
end on

event close;call super::close;

//OverRide//

CloseWithReturn(This, is_action)
end event

event open;call super::open;
//Check Security
This.Event Post ue_check_access()
end event

type cb_cancel from commandbutton within w_gigp_response
integer x = 2112
integer y = 824
integer width = 343
integer height = 100
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Cancel"
end type

event clicked;
is_action = "CANCEL"

Close(Parent)
end event

type cb_ok from commandbutton within w_gigp_response
integer x = 1714
integer y = 824
integer width = 343
integer height = 100
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "OK"
end type

event clicked;
is_action = "OK"

Parent.Event ue_process()

Close(Parent)
end event

