forward
global type u_dw_review_history from u_dw
end type
end forward

global type u_dw_review_history from u_dw
integer width = 3410
integer height = 980
boolean titlebar = true
string title = "MWBW Review History2"
string dataobject = "d_mwbe_review_history"
boolean controlmenu = true
boolean resizable = true
string icon = "AppIcon!"
event ue_read_notes ( long al_row )
end type
global u_dw_review_history u_dw_review_history

on u_dw_review_history.create
call super::create
end on

on u_dw_review_history.destroy
call super::destroy
end on

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

event buttonclicked;call super::buttonclicked;string ls_setting


CHOOSE CASE dwo.Name
		
CASE "b_notes"
		This.Event ue_read_notes(row)

CASE "b_expand"
      This.ExpandAll()

CASE "b_collapse"
	This.CollapseAll()
	
CASE "b_comments"
	ls_setting = This.Describe("master_mwbe_comment.Height.AutoSize")

	If ls_setting = 'yes' Then
		This.Modify("master_mwbe_comment.Height.AutoSize=no")
	Else
		This.Modify("master_mwbe_comment.Height.AutoSize=Yes")
	End If


END CHOOSE
end event

