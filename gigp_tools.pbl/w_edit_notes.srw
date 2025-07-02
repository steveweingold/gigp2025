forward
global type w_edit_notes from w_response
end type
type cb_print from commandbutton within w_edit_notes
end type
type mle_notes from multilineedit within w_edit_notes
end type
type cb_ok from commandbutton within w_edit_notes
end type
type cb_cancel from commandbutton within w_edit_notes
end type
end forward

global type w_edit_notes from w_response
integer x = 214
integer y = 221
integer width = 2994
integer height = 1752
string title = "Text Editor"
boolean center = true
windowanimationstyle openanimation = centeranimation!
windowanimationstyle closeanimation = centeranimation!
cb_print cb_print
mle_notes mle_notes
cb_ok cb_ok
cb_cancel cb_cancel
end type
global w_edit_notes w_edit_notes

type variables

String is_return, is_OriginalText
end variables

forward prototypes
public subroutine of_cleanse_text ()
end prototypes

public subroutine of_cleanse_text ();
Integer			li_UBound, N
n_cst_string		lu_string
String 			ls_text

String ls_find[]		= {'“', '”', '’', '…', '–', '‘'}
String ls_replace[] = {'"', '"', "'", '...','-', "'"}

//*************************************************************
// Cleanse text of special characters that cause issues with database.
//*************************************************************

ls_text = mle_notes.Text

li_UBound = UpperBound(ls_find)

FOR N = 1 TO li_UBound
     ls_text =  lu_string.of_globalreplace(ls_text, ls_find[N], ls_replace[N])
NEXT

mle_notes.Text = ls_text


end subroutine

on w_edit_notes.create
int iCurrent
call super::create
this.cb_print=create cb_print
this.mle_notes=create mle_notes
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_print
this.Control[iCurrent+2]=this.mle_notes
this.Control[iCurrent+3]=this.cb_ok
this.Control[iCurrent+4]=this.cb_cancel
end on

on w_edit_notes.destroy
call super::destroy
destroy(this.cb_print)
destroy(this.mle_notes)
destroy(this.cb_ok)
destroy(this.cb_cancel)
end on

event open;call super::open;
str_notes	lstr_notes

lstr_notes = Message.PowerObjectParm	

is_OriginalText = lstr_notes.str_text
mle_notes.Text	= lstr_notes.str_text


If (lstr_notes.str_action = "READ") Then	
	mle_notes.DisplayOnly 	= True
	This.Title += " (Read Only!)"	
	cb_print.x = cb_ok.x
	cb_ok.Visible = False
	cb_cancel.Text = "Close"
Else	
	mle_notes.DisplayOnly 	= False
End If

//***************************************************************
// Set Return Default:
//***************************************************************

is_return = "$CANCEL$"
end event

event close;call super::close;
//OverRide//

String ls_text

If mle_notes.Text = is_OriginalText Then
	is_return = "$CANCEL$"
End If

If (is_return = "$CANCEL$") Then
	ls_text = is_return
Else
	of_cleanse_text()	
	ls_text = mle_notes.Text
End If

CloseWithReturn(This, ls_text) 
end event

type cb_print from commandbutton within w_edit_notes
integer x = 1906
integer y = 1552
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
	ls_text = mle_notes.Text
 
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

type mle_notes from multilineedit within w_edit_notes
integer x = 23
integer y = 24
integer width = 2935
integer height = 1512
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean vscrollbar = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
end type

type cb_ok from commandbutton within w_edit_notes
integer x = 2272
integer y = 1552
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

type cb_cancel from commandbutton within w_edit_notes
integer x = 2638
integer y = 1552
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

