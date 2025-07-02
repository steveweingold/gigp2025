//objectcomments Use this, u_tab_dbaccess and w_sheet_dbaccess as ancestors. All three work together with PFC and Menus.
forward
global type u_tabpg_dbaccess from u_tabpg
end type
type dw_1 from u_dw_enhanced within u_tabpg_dbaccess
end type
end forward

global type u_tabpg_dbaccess from u_tabpg
integer width = 2866
integer height = 1204
boolean hscrollbar = true
long backcolor = 67108864
long tabbackcolor = 67108864
event ue_reconnect ( )
event ue_tab_selected ( )
event ue_tab_deselected ( )
event ue_display ( )
event ue_delete ( )
event ue_check_access ( )
dw_1 dw_1
end type
global u_tabpg_dbaccess u_tabpg_dbaccess

type variables
Public:
  	Boolean	ib_Retrieved, ib_Selected, ib_editAccess
	String		is_accessGroups[], is_title, is_titleRO
	
Protected:
  	u_tab_dbaccess it_Parent
  
  

end variables

forward prototypes
public function integer of_retrieve ()
public function integer of_display ()
public function integer of_preupdateedits ()
public subroutine of_get_it_parent (ref u_tab_dbaccess at_parent)
end prototypes

event ue_reconnect;// This event is called by f_reconnect().	//
dw_1.of_SetTransObject(sqlca)

end event

event ue_tab_selected();
//*************************************************************************
// Fired from the Tab Control's selection changed event
// Lets the tab page know when it has been selected:
//*************************************************************************

ib_Selected = True

//*******************************************************
// Check for edit access:
//*******************************************************

This.Event ue_check_access()


end event

event ue_tab_deselected();
//*************************************************************************
// Fired from the Tab Control's selection changed event
// Lets the tab page know when it has been de-selected:
//*************************************************************************

ib_Selected = False

This.Text = is_title
end event

event ue_check_access();long		ll_index, ll_upper
boolean	lb_locked
Object	l_object
u_dw		lu_dw

//*******************************************************
// Check for edit access:
//*******************************************************

lb_locked = gnv_app.of_getlocked()

//Added Locked enhancement 5/2012, SW
If lb_locked Then
	ib_editAccess = False
Else
	ib_editAccess = gnv_app.of_ingroup(is_accessGroups)
End If

If (ib_editAccess = True) Then
	This.Text = is_title
	
	ll_upper = UpperBound(Control)
	
	FOR ll_index = 1 To ll_upper
		
		IF TypeOf(Control[ll_index]) = Datawindow! THEN

			lu_dw = Control[ll_index]		
			lu_dw.Modify("DataWindow.ReadOnly=No")

		END IF    	

	NEXT
	
Else
	This.Text = is_titleRO
	
	ll_upper = UpperBound(Control)
	
	FOR ll_index = 1 To ll_upper
		
		IF TypeOf(Control[ll_index]) = Datawindow! THEN

			lu_dw = Control[ll_index]		
			lu_dw.Modify("DataWindow.ReadOnly=Yes")

      END IF    	

	NEXT
	
End If
end event

public function integer of_retrieve ();// Called by this.of_Display when neccesary.		//
//																//
// Put descendant specific code in dw_1's			//
// pfc_Retrieve() event as needed.					//
//																//
// dw_1.pfc_Retrieve() at this level performs	//
// dw_1.Retrieve() with no parms.					//

If IsValid(dw_1.inv_linkage) Then
	dw_1.inv_linkage.of_retrieve()
Else
	Return dw_1.Event pfc_Retrieve()
End If

end function

public function integer of_display ();// This function should be called from the tab object's selectionchanged event.	//
// This will retrieve dw_1 on the new tabpage if neccesary.								//

int	li_RC

IF NOT ib_Retrieved THEN
	li_RC = of_Retrieve()

	IF li_RC > 0 THEN
		ib_Retrieved = True

		IF it_Parent.itp_Array[it_Parent.SelectedTab] = this THEN
			dw_1.SetFocus()
		END IF
	ELSE
		ib_Retrieved = False
	END IF

	Return li_RC
ELSE
	Return 0
END IF

end function

public function integer of_preupdateedits ();// Override this in descendants.				//
//														//
// Put pre-update edits here.					//
// Return 1 for success, -1 for failure.	//

Return 1

end function

public subroutine of_get_it_parent (ref u_tab_dbaccess at_parent);at_parent = it_parent
end subroutine

event constructor;call super::constructor;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

// Set parent tab object.	//
it_Parent = this.GetParent()

// Register this tabpage with it's parent.	//
it_Parent.of_RegisterPage(this)

// Set dw_1's transobject.	//
dw_1.of_SetTransObject(sqlca)

// Start typical services.	//
dw_1.of_SetTypicalServices(True)

is_title   = This.Text
is_titleRO = (This.Text + " [Read Only]")

end event

on u_tabpg_dbaccess.create
int iCurrent
call super::create
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on u_tabpg_dbaccess.destroy
call super::destroy
destroy(this.dw_1)
end on

type dw_1 from u_dw_enhanced within u_tabpg_dbaccess
integer x = 5
integer y = 4
integer width = 2830
integer height = 1180
boolean hscrollbar = true
end type

event pfc_retrieve;call super::pfc_retrieve;
//*******************************************************
// Override this script in descendants if retrieval  
// arguments are needed other than "loan_id" or if any
// special processing needs to take place.			
//*******************************************************

String ls_dwargs

ls_dwargs = This.Describe ( "DataWindow.Table.Arguments" ) 

If (ls_dwargs = "?") Then	
	Return This.Retrieve()	
Else	
	Return This.Retrieve(gl_gigp_ID)
End If

end event

event pfc_postupdate;call super::pfc_postupdate;// Update worked. Flag for re-retrieval.	//

parent.ib_Retrieved = False

Return ancestorreturnvalue

end event

event losefocus;this.AcceptText()

end event

