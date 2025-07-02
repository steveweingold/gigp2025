//objectcomments Use this, w_sheet_dbaccess and u_tabpg_dbaccess as ancestors. All three work together with PFC and Menus.
forward
global type u_tab_dbaccess from u_tab
end type
end forward

global type u_tab_dbaccess from u_tab
integer width = 2866
integer height = 1300
long backcolor = 67108864
boolean boldselectedtext = true
end type
global u_tab_dbaccess u_tab_dbaccess

type variables
u_tabpg_dbaccess	itp_Array[]
w_sheet_dbaccess	iw_Parent
boolean		ib_ForceSave = True

end variables

forward prototypes
public function integer of_preupdateedits ()
public subroutine of_refreshdddws ()
public function integer of_registerpage (u_tabpg_dbaccess atp_page)
public subroutine of_setretrieve (boolean ab_switch)
end prototypes

public function integer of_preupdateedits ();// This function will call each registered tabpage's of_PreUpdateEdits() function.	//
// This was probably called from w_sheet_dbaccess.pfc_preupdate().						//

int	li_RC, &
		li_UB, &
		li_Index

li_UB = UpperBound(itp_Array)

FOR li_Index = 1 TO li_UB
	li_RC = itp_Array[li_Index].of_PreUpdateEdits()

	IF li_RC <> 1 THEN
		Exit
	END IF

NEXT

Return li_RC

end function

public subroutine of_refreshdddws ();// This function will refresh all dddw's in dw_1 on all registered tabpages.	//

int	li_UB, &
		li_Index = 1

li_UB = UpperBound(itp_Array)

FOR li_Index = 1 TO li_UB
	itp_Array[li_Index].dw_1.inv_base.of_PopulateDDDW()

	// This call will fail in most instances, but if your tabpage needs to do extra	//
	// work for this, declare a "ue_refreshdddws" event and put code there.				//
	itp_Array[li_Index].Event Dynamic ue_refreshdddws()
NEXT

Return

end subroutine

public function integer of_registerpage (u_tabpg_dbaccess atp_page);// This function is called in the constructor event of u_tabpg_dbaccess.	//
// itp_Array[] will be used for a variety of functions.							//

int	li_Index

li_Index = UpperBound(itp_Array) + 1

itp_Array[li_Index] = atp_Page

Return li_Index

end function

public subroutine of_setretrieve (boolean ab_switch);// This function sets ib_Retrieved = ab_Switch on all tabpages.	//

int	li_Index, &
		li_UB

li_UB = UpperBound(itp_Array)

FOR li_Index = 1 TO li_UB
	itp_Array[li_Index].ib_Retrieved = ab_Switch
NEXT

end subroutine

event constructor;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

// Set pointer to window this tab has been placed on.		//
// This must be done at runtime because the user object	//
// doesn't know at compile time what window it will be	//
// placed on.															//

iw_Parent = this.GetParent()

end event

event selectionchanging;// Prompt user to save changes before changing tab pages.					//
// You can turn off this behaviour by setting this.ib_ForceSave False.	//

int			li_RC, &
				li_Answer
powerobject	lpo_Updates[]

IF ib_ForceSave THEN
	SetPointer(HourGlass!)
	
	IF oldindex > 0 THEN
		// Accepttect on all dw's on the tabpage we are leaving.	//
		li_RC = iw_Parent.Event pfc_accepttext(This.itp_Array[oldindex].control,True)
	
		IF li_RC = -1 THEN
			Return 1
		END IF
	
		// Check the tabpage we are leaving for pending updates.	//

		// Using pfc_UpdatesPendingRef() instead of pfc_UpdatesPending	//
		// to avoid affecting the object's ipo_PendingUpdates[] array.	//
		li_RC = iw_Parent.Event pfc_UpdatesPendingRef( &
					This.itp_Array[oldindex].control,lpo_Updates) 
	
		//////////////////////////////////////////////////
		//	 1 = updates are pending (no errors found)	//
		//	 0 = No updates pending (no errors found)		//
		//	-1 = error												//
		//////////////////////////////////////////////////
	
		CHOOSE CASE li_RC
		CASE is < 0
			Return 1
		CASE is > 0
			iw_parent.BringToTop = True

			li_Answer = MessageBox(itp_Array[oldindex].Tag,"Save Changes?",Question!,YesNoCancel!,1)
	
			CHOOSE CASE li_Answer
			CASE 1
				// If the save fails, don't change tabpages.	//
				IF iw_Parent.Event pfc_Save() < 0 THEN
					Return 1
				END IF

			CASE 2
				// Re-retrieve old tabpage to erase changes.	//
				itp_Array[oldindex].ib_Retrieved = False

				// If they are equal, code below will post of_Display().	//
				IF oldindex <> newindex THEN
					itp_Array[oldindex].Function Post of_Display()
				END IF

			// If the user cancels, don't change tabpages.	//
			CASE 3
				Return 1
			END CHOOSE
		CASE 0
		END CHOOSE
	END IF
END IF

IF IsValid(itp_Array[newindex]) THEN
	// of_Display will perform a retrieve if neccesary.	//
	itp_Array[newindex].Function Post of_Display()
END IF

Return 0

end event

event selectionchanged;call super::selectionchanged;
//****************************************************************************
// Let tabpages know they are being selected or deselected:
//****************************************************************************

If (oldindex > 0) Then itp_Array[oldindex].Event Post ue_tab_deselected()
If (newindex > 0) Then itp_Array[newindex].Event Post ue_tab_selected()
end event

