forward
global type w_edit_notes2 from w_response
end type
type sle_text from singlelineedit within w_edit_notes2
end type
type cb_print from commandbutton within w_edit_notes2
end type
type cb_ok from commandbutton within w_edit_notes2
end type
type cb_cancel from commandbutton within w_edit_notes2
end type
end forward

global type w_edit_notes2 from w_response
integer width = 2523
integer height = 404
string title = "Text Editor"
boolean center = true
windowanimationstyle openanimation = centeranimation!
windowanimationstyle closeanimation = centeranimation!
sle_text sle_text
cb_print cb_print
cb_ok cb_ok
cb_cancel cb_cancel
end type
global w_edit_notes2 w_edit_notes2

type variables

String is_return, is_OriginalText
end variables

on w_edit_notes2.create
int iCurrent
call super::create
this.sle_text=create sle_text
this.cb_print=create cb_print
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.sle_text
this.Control[iCurrent+2]=this.cb_print
this.Control[iCurrent+3]=this.cb_ok
this.Control[iCurrent+4]=this.cb_cancel
end on

on w_edit_notes2.destroy
call super::destroy
destroy(this.sle_text)
destroy(this.cb_print)
destroy(this.cb_ok)
destroy(this.cb_cancel)
end on

event open;call super::open;
str_notes	lstr_notes
Integer li_limit

lstr_notes = Message.PowerObjectParm	

is_OriginalText = lstr_notes.str_text
sle_text.Text	= lstr_notes.str_text

li_limit = lstr_notes.str_limit

If (li_limit > 1) Then
	sle_text.limit = li_limit
End If

If (lstr_notes.str_action = "READ") Then	
	sle_text.DisplayOnly 	= True
	This.Title += " (Read Only!)"	
	cb_print.x = cb_ok.x
	cb_ok.Visible = False
	cb_cancel.Text = "Close"
Else	
	sle_text.DisplayOnly 	= False
End If

//***************************************************************
// Set Return Default:
//***************************************************************

is_return = "$CANCEL$"
end event

event close;call super::close;
//OverRide//

String ls_text

If sle_text.Text = is_OriginalText Then
	is_return = "$CANCEL$"
End If

If (is_return = "$CANCEL$") Then
	ls_text = is_return
Else
	ls_text = sle_text.Text
End If

CloseWithReturn(This, ls_text) 
end event

type sle_text from singlelineedit within w_edit_notes2
integer x = 37
integer y = 28
integer width = 2427
integer height = 100
integer taborder = 40
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type cb_print from commandbutton within w_edit_notes2
integer x = 1367
integer y = 196
integer width = 329
integer height = 96
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Print"
end type

event clicked;
n_ds lds_print
string ls_text
long ll_row
 
If PrintSetup() = 1 Then
	ls_text = sle_text.Text
 
	If NOT IsValid(lds_print) Then
  		lds_print = CREATE n_ds
 	End If
 
 	lds_print.DataObject = 'd_note_print'
 	lds_print.SetTransObject(SQLCA)
 	ll_row = lds_print.InsertRow(0)
 	lds_print.Setitem(ll_row,'note_text',ls_text)
 
 	lds_print.Print()
 
 	If IsValid(lds_print) Then DESTROY lds_print
 
End If
 

end event

type cb_ok from commandbutton within w_edit_notes2
integer x = 1751
integer y = 196
integer width = 329
integer height = 96
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "OK"
boolean default = true
end type

event clicked;
is_return = "$OK$"

Close(parent)
end event

type cb_cancel from commandbutton within w_edit_notes2
integer x = 2135
integer y = 196
integer width = 329
integer height = 96
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Cancel"
boolean cancel = true
end type

event clicked;
is_return = "$CANCEL$"

Close(parent)
end event

