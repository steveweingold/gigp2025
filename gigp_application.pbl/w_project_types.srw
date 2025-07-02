forward
global type w_project_types from w_gigp_response
end type
type dw_types from u_dw_enhanced within w_project_types
end type
type cb_add from commandbutton within w_project_types
end type
type gb_1 from groupbox within w_project_types
end type
end forward

global type w_project_types from w_gigp_response
integer width = 2135
integer height = 1140
string title = "Project Types"
dw_types dw_types
cb_add cb_add
gb_1 gb_1
end type
global w_project_types w_project_types

type variables
integer ii_locked
end variables

forward prototypes
public function boolean of_checkfordups ()
public subroutine of_removedupes ()
end prototypes

public function boolean of_checkfordups ();
//Create datastore to process from datawindow so user doesn't see
dw_types.SetSort('project_type')
dw_types.Sort()

dw_types.SetFilter('project_type = project_type [-1]')
dw_types.Filter()





dw_types.SetFilter('')
dw_types.Filter()


If dw_types.RowCount() > 0 Then 
	
	Return True
End If

Return False
end function

public subroutine of_removedupes ();
end subroutine

on w_project_types.create
int iCurrent
call super::create
this.dw_types=create dw_types
this.cb_add=create cb_add
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_types
this.Control[iCurrent+2]=this.cb_add
this.Control[iCurrent+3]=this.gb_1
end on

on w_project_types.destroy
call super::destroy
destroy(this.dw_types)
destroy(this.cb_add)
destroy(this.gb_1)
end on

event open;call super::open;dw_types.Event pfc_retrieve()

ib_disableclosequery = true

If ii_locked = 1 Then
	dw_types.Enabled = False
	cb_add.Enabled = False
End If
end event

event ue_process;call super::ue_process;//Remove dups
dw_types.Event ue_removedups()

//Save
dw_types.of_update(true, true)
end event

event ue_check_access;//Override
end event

event pfc_preopen;call super::pfc_preopen;ii_locked = Message.DoubleParm


end event

type cb_cancel from w_gigp_response`cb_cancel within w_project_types
integer x = 1097
integer y = 916
end type

type cb_ok from w_gigp_response`cb_ok within w_project_types
integer x = 699
integer y = 916
end type

type dw_types from u_dw_enhanced within w_project_types
event ue_removedups ( )
integer x = 151
integer y = 100
integer width = 1833
integer height = 620
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_project_types"
boolean border = false
borderstyle borderstyle = stylebox!
end type

event ue_removedups();long ll_row, ll_count

this.SetRedraw(False)

//Sort by Project Type
this.SetSort('project_type')
this.Sort()

//Filter out dups, this will leave the last of each set
this.SetFilter('project_type = project_type [-1]')
this.Filter()

ll_count = this.RowCount()

//Remove them leaving only the first of a dup set
If ll_count > 0 Then
	For ll_row = ll_count to 1 Step -1
		this.DeleteRow(ll_row)
	Next
End If

//Turn the filter off
this.SetFilter('')
this.Filter()

this.SetRedraw(True)
end event

event pfc_retrieve;call super::pfc_retrieve;Return this.Retrieve(gl_gigp_id)
end event

event constructor;call super::constructor;this.SetTransObject(SQLCA)
end event

event pfc_postinsertrow;call super::pfc_postinsertrow;this.SetItem(al_row, 'gigp_id', gl_gigp_id)
end event

type cb_add from commandbutton within w_project_types
integer x = 978
integer y = 736
integer width = 178
integer height = 88
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Add"
end type

event clicked;dw_types.Event pfc_addrow()
end event

type gb_1 from groupbox within w_project_types
integer x = 82
integer y = 40
integer width = 1966
integer height = 808
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
end type

