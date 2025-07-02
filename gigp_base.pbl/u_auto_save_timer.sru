//objectcomments Timing object that can be started by the appmanager to prompt user to save changes at specified intervals.
forward
global type u_auto_save_timer from timing
end type
end forward

global type u_auto_save_timer from timing
end type
global u_auto_save_timer u_auto_save_timer

type variables
Private:
  boolean ib_Active
end variables

on u_auto_save_timer.create
call timing::create
TriggerEvent( this, "constructor" )
end on

on u_auto_save_timer.destroy
call timing::destroy
TriggerEvent( this, "destructor" )
end on

event timer;//	CHECK FOR PENDING CHANGES.	//

w_sheet		lw_Sheet, &
				lw_FirstSheet, &
				lw_ProcessedSheets[]
w_frame		lw_Frame
int			li_RC, &
				li_UB, &
				li_Index, &
				li_modified
powerobject	lpo_Updates[]
boolean		lb_Processed


// This switch keeps this process from starting twice. This could	//
// happen if a user did not respond to a messagebox before the		//
// next time this event fires.												//
IF ib_Active THEN
	Return
END IF

ib_Active = True

lw_Frame = gnv_App.of_GetFrame()

lw_Sheet = lw_Frame.GetFirstSheet()

// Don't ask to update if there is nothing to update.					//
// Since no windows are brought to top GetNextSheet works fine.	//
li_Modified = 0

DO WHILE IsValid(lw_Sheet) AND li_Modified = 0
	// Check each sheet to see if there is any pending changes.	//
	lw_sheet.Event pfc_AcceptText(lw_Sheet.Control,True)
		
	IF lw_Sheet.Event pfc_UpdatesPendingRef(lw_Sheet.Control,lpo_Updates) = 1 THEN
		li_Modified = 1
	END IF

	lw_Sheet = lw_frame.GetNextSheet(lw_Sheet)
LOOP

IF li_Modified = 0 THEN
	ib_Active = False
	Return
END IF

lw_Sheet = lw_Frame.GetFirstSheet()

// Save a ref to the first sheet so we can bring it back to the top if	//
// everything goes without an error.												//
lw_FirstSheet = lw_Sheet

IF MessageBox("Auto-Save Reminder",lw_Sheet.Tag + " - Save Changes?", &
		Question!,YesNo!,1) = 1 THEN
	
	DO WHILE IsValid(lw_Sheet)
		// By bringing a particular sheet to the top, you change the order of	//
		// sheets that will be returned by the GetNextSheet() function. That's	//
		// why we need to keep track of which sheets we have already processed	//
		// and skip them if we get them again in this loop.							//
	
		lb_Processed = False
	
		FOR li_Index = 1 TO li_UB
			IF lw_ProcessedSheets[li_Index] = lw_Sheet THEN
				lb_Processed = True
				Exit
			END IF
		NEXT
	
		IF NOT lb_Processed THEN
			// Add sheet to processed array.	//
			li_UB ++
			lw_ProcessedSheets[li_UB] = lw_Sheet
	
			// Need to do an AcceptText on any datawindows.	//
			IF lw_Sheet.Event pfc_AcceptText(lw_Sheet.Control,True) = -1 THEN
				// Validation error occurred. BringToTop and stop auto-save process.	//
				lw_Sheet.BringToTop = True
				ib_Active = False
				Return
			END IF
	
			// Use pfc_UpdatesPendingRef instead of pfc_UpdatesPending because	//
			// the latter will update the sheet's ipo_PendingUpdate array. We		//
			// don't want that to happen. We just want to take a peek at the		//
			// sheets without doing anything unless the user wants to.				//	
			IF lw_Sheet.Event pfc_UpdatesPendingRef(lw_Sheet.Control,lpo_Updates) = 1 THEN
						
					// If save fails, put sheet on Top and stop auto-save process.	//
					IF lw_Sheet.Event pfc_Save() < 0 THEN
						lw_Sheet.BringToTop = True
						ib_Active = False
						lw_Sheet.SetFocus()
						Return
					END IF
			END IF
		END IF
		
		lw_Sheet = lw_Frame.GetNextSheet(lw_Sheet)
	LOOP
else
	ib_Active = False
	lw_Sheet.SetFocus()
	Return
END IF

IF IsValid(lw_FirstSheet) THEN
	IF lw_FirstSheet <> lw_Frame.GetFirstSheet() THEN
		lw_FirstSheet.BringToTop = True
	END IF
END IF

ib_Active = False

end event

event constructor;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

end event

