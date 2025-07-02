//objectcomments Copy and rename this for new PFC based apps. Follow instructions in greg application open event.
forward
global type w_gigp_frame from w_frame
end type
end forward

global type w_gigp_frame from w_frame
string tag = "Small Grants Application"
integer x = 107
string title = "Small Grants Application"
string menuname = "m_gigp_frame"
windowstate windowstate = maximized!
long backcolor = 67108864
string icon = "AppIcon!"
integer sheetlistimagesize = 1
event ue_call_log ( )
end type
global w_gigp_frame w_gigp_frame

event ue_call_log();w_call_log lw_win

OpenSheet(	lw_win, this)
end event

event pfc_open;string	ls_Sheet
w_sheet	lw_Sheet

ls_Sheet = Message.StringParm

IF Trim(ls_Sheet) <> "" AND NOT IsNull(ls_Sheet) THEN
	
	//************************************************************
	// This is neccesary to prevent toolbar from bouncing around:
	//************************************************************
	
	This.SetRedraw(False)

	IF ProfileString(gnv_App.of_GetAppIniFile(),"Application", &
			"AllowMultiSheet","NO") = "YES" THEN
			
		OpenSheet(lw_Sheet,ls_Sheet,this,0,Layered!)

//		IF IsValid(lw_Sheet) THEN
//			lw_Sheet.SetRedraw(False)
//			lw_Sheet.Event Post ReSize(0,lw_Sheet.Width,lw_Sheet.Height)
//			lw_Sheet.Function Post SetRedraw(True)
//		END IF
		
	ELSE
		lw_Sheet = this.GetActiveSheet()
		
		//************************************************************
		// If multiple instances are not allowed, look for already
		// open instance of window that we are trying to open, If
		// found, set focus on it instead of opening it.		
		//************************************************************
		
		DO WHILE IsValid(lw_Sheet)
			IF lw_Sheet.ClassName() = ls_Sheet THEN
				lw_Sheet.SetFocus()
				this.SetRedraw(True)
				Return
			END IF
	
			lw_Sheet = this.GetNextSheet(lw_Sheet)
		LOOP

		OpenSheet(lw_Sheet,ls_Sheet,this,0,Layered!)

//		IF IsValid(lw_Sheet) THEN
//			lw_Sheet.SetRedraw(False)
//			lw_Sheet.Event Post ReSize(0,lw_Sheet.Width,lw_Sheet.Height)
//			lw_Sheet.Function Post SetRedraw(True)
//		END IF
	END IF

	This.SetRedraw(True)
END IF

end event

event pfc_preopen;
This.of_SetSheetManager(True)
This.of_SetStatusBar(True)

//*******************************************************
// Timer in status bar doesn't work well with NT:
//*******************************************************

This.inv_statusbar.of_SetTimer(False)

end event

on w_gigp_frame.create
call super::create
if IsValid(this.MenuID) then destroy(this.MenuID)
if this.MenuName = "m_gigp_frame" then this.MenuID = create m_gigp_frame
end on

on w_gigp_frame.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
end on

event closequery;
// OVERRIDE.	//

call super::closequery

end event

event open;call super::open;StartServerDDE(this, "gigp","Null", "Null")

// Trigger app idle event after 180 minutes of inactivity.	//
Idle(10800)


end event

event pfc_postopen;call super::pfc_postopen;
//*******************************************************
// Display Database Connection: 
//*******************************************************

If NOT gb_production Then
	this.Title += '     Connected to ' + SQLCA.ServerName + ' / ' + SQLCA.Database
	
//	Open(w_production_warning)
	
End If

//*******************************************************
// Retrieve security informatio: 
//*******************************************************

gnv_App.of_SetGroups()

IF ProfileString(gnv_App.of_GetAppINIFile(),"GIGP","AutoOpenSummary","YES") = "YES" THEN
	message.StringParm = "w_gigp_summary"

	SetPointer(HourGlass!)

	This.Event pfc_open()
END IF




end event

