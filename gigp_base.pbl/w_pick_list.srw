//objectcomments Use for response windows that offer a dw based list to pick one item from.
forward
global type w_pick_list from w_response
end type
type dw_list from u_dw within w_pick_list
end type
type cb_ok from u_cb within w_pick_list
end type
type cb_cancel from u_cb within w_pick_list
end type
end forward

global type w_pick_list from w_response
integer width = 1143
integer height = 760
string title = "Select a"
long backcolor = 67108864
dw_list dw_list
cb_ok cb_ok
cb_cancel cb_cancel
end type
global w_pick_list w_pick_list

type variables
string is_Return
end variables

event open;call super::open;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

Integer			li_ScreenH, li_ScreenW
Environment		le_Env

// Center window
GetEnvironment(le_Env)

li_ScreenH = PixelsToUnits(le_Env.ScreenHeight, YPixelsToUnits!)
li_ScreenW = PixelsToUnits(le_Env.ScreenWidth, XPixelsToUnits!)

This.Y = (li_ScreenH - This.Height) / 2
This.X = (li_ScreenW - This.Width) / 2

// Set trans object.	//
dw_list.of_SetTransObject(sqlca)

// This will be a pick list. Use row selection service.	//
dw_list.of_SetRowSelect(True)

// Set single row selection style.	//
dw_list.inv_rowselect.of_SetStyle(0)

// Trigger a retrieve.	//
IF dw_list.Event pfc_Retrieve() > 0 THEN
	dw_list.inv_rowselect.of_RowSelect(1)
END IF

dw_list.SetFocus()

end event

on w_pick_list.create
int iCurrent
call super::create
this.dw_list=create dw_list
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_list
this.Control[iCurrent+2]=this.cb_ok
this.Control[iCurrent+3]=this.cb_cancel
end on

on w_pick_list.destroy
call super::destroy
destroy(this.dw_list)
destroy(this.cb_ok)
destroy(this.cb_cancel)
end on

event pfc_cancel;call super::pfc_cancel;SetNull(is_Return)

CloseWithReturn(this,is_Return)

end event

event pfc_default;// Set is_Return to what you want in dw_list.RowFocusChanged!	//

CloseWithReturn(this,is_Return)

end event

type dw_list from u_dw within w_pick_list
integer x = 55
integer y = 48
integer width = 1010
integer height = 436
integer taborder = 20
end type

event pfc_retrieve;call super::pfc_retrieve;// OVERRIDE THIS IF PARAMETERS ARE NEEDED.	//

Return this.Retrieve()

end event

event rowfocuschanged;call super::rowfocuschanged;this.inv_rowselect.of_RowSelect(currentrow)
end event

event doubleclicked;IF row > 0 AND row <= this.RowCount() THEN
	this.Event rowfocuschanged(row)

	parent.Event pfc_default()
END IF

end event

type cb_ok from u_cb within w_pick_list
integer x = 101
integer y = 536
integer taborder = 30
integer weight = 700
string text = "OK"
boolean default = true
end type

event clicked;call super::clicked;parent.Event pfc_default()

end event

type cb_cancel from u_cb within w_pick_list
integer x = 667
integer y = 536
integer taborder = 10
boolean bringtotop = true
integer weight = 700
string text = "Cancel"
boolean cancel = true
end type

event clicked;call super::clicked;parent.Event pfc_cancel()

end event

