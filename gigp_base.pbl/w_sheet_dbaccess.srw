//objectcomments Use this, u_tab_dbaccess and u_tabpg_dbaccess as ancestors. All three work together with PFC and Menus.
forward
global type w_sheet_dbaccess from w_sheet
end type
end forward

global type w_sheet_dbaccess from w_sheet
integer x = 214
integer y = 221
integer width = 2917
integer height = 1420
long backcolor = 67108864
event ue_postsuccess ( )
event ue_postfailure ( )
event ue_setorigsize ( )
event ue_reconnect ( )
event ue_check_access ( )
end type
global w_sheet_dbaccess w_sheet_dbaccess

type variables
u_tab_dbaccess it_Tab

String 	is_accessGroups[]
Boolean 	ib_editAccess

Protected:
  // Used to call of_SetOrigSize() of Resize Service
  // since windows are opened Layered! instead of
  // original.

  // These numbers are the WorkSpaceWidth and
  // WorkSpaceHeight, not the Width and Height.

  // WorkSpaceWidth = Width - 28
  // WorkSpaceHeight = Height - 150  (-150 for w_sheet_dbaccess descendants only)

  int ii_Orig_Width = 2889, &
       ii_Orig_Height = 1270

end variables

event ue_postsuccess;// This event will happen after a successful update.	//

end event

event ue_postfailure;// This event will happen after an update failure.	//

end event

event ue_setorigsize;// Set ii_Orig_Height and ii_Orig_Width in this event in descendants	//
// that have changed their size in the window painter.					//

// These variables are set in the "Declare Instance Variables" section	//
// to equal this ancestor's "width - 28" and "height - 150". These		//
// numbers subtract 28 and 150 to account for the width and height of	//
// window borders and menus and toolbars and tab object.						//

end event

event ue_reconnect;// This event is called from f_recconect().	//
int	li_UB, &
		li_Index

li_UB = UpperBound(it_Tab.itp_Array)

FOR li_Index = 1 TO li_UB
	it_Tab.itp_Array[li_Index].Event Dynamic ue_reconnect()
NEXT

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
	
	ll_upper = UpperBound(Control)
	
	FOR ll_index = 1 To ll_upper
		
		IF TypeOf(Control[ll_index]) = Datawindow! THEN

			lu_dw = Control[ll_index]		
			lu_dw.Modify("DataWindow.ReadOnly=Yes")

      END IF    	

	NEXT
	
End If
end event

on w_sheet_dbaccess.create
call super::create
end on

on w_sheet_dbaccess.destroy
call super::destroy
end on

event pfc_preupdate;call super::pfc_preupdate;// it_Tab.of_PreUpdateEdits() will call the of_PreUpdateEdits()	//
// function on every tabpage on it_Tab.									//
Return it_Tab.of_PreUpdateEdits()

end event

event pfc_endtran;call super::pfc_endtran;IF ai_update_results = 1 THEN
	EXECUTE IMMEDIATE "commit";

	MessageBox(it_Tab.itp_Array[it_Tab.SelectedTab].Tag,"Update was successful.")

//	f_transactionlog(this.ClassName(),it_Tab.itp_Array[it_Tab.SelectedTab].Tag,"Successful Update",sqlca.SQLErrText,sqlca.SQLDBCode)

	it_Tab.itp_Array[it_Tab.SelectedTab].ib_Retrieved = False
	it_Tab.itp_Array[it_Tab.SelectedTab].Post of_Display()

	this.Event Post ue_PostSuccess()

	Return 1
ELSE
	EXECUTE IMMEDIATE "rollback";

	MessageBox(it_Tab.itp_Array[it_Tab.SelectedTab].Tag,"Update failed.")

//	f_transactionlog(this.ClassName(),it_Tab.itp_Array[it_Tab.SelectedTab].Tag,"Update Failed",sqlca.SQLErrText,sqlca.SQLDBCode)

	this.Event Post ue_PostFailure()

	Return -1
END IF

end event

event open;call super::open;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

// Loop thourgh controls, looking for first tab control.	//
int		li_Count, &
			li_Index
m_master	lm_Menu

SetPointer(HourGlass!)

// Give descendant a chance to set original size.	//
this.Event ue_setorigsize()

li_Count = UpperBound(this.Control)

FOR li_Index = 1 TO li_Count
	IF TypeOf(this.Control[li_Index]) = Tab! THEN
		// Tab control found. Set pointer to it.	//
		it_Tab = this.Control[li_Index]

		// Align sheet toolbar next to frame toolbar.	//
		f_aligntoolbars(this)

		// Turn on resize service for this window.	//
		this.of_SetResize(True)
		
		// Call of_SetOrigSize in case this wasn't opened with	//
		// size = Original!.													//
		this.inv_resize.of_SetOrigSize(ii_Orig_Width,ii_Orig_Height)

		this.inv_resize.of_SetMinSize(ii_Orig_Width,ii_Orig_Height)
		
		// Register tab control with resize service.	//
		this.inv_resize.of_Register(it_Tab,"ScaleToRight&Bottom")

		// Register dw_1 on every tabpage with the resize service.	//
		li_Count = UpperBound(it_Tab.itp_Array)

		FOR li_Index = 1 TO li_Count
			this.inv_resize.of_Register(it_Tab.itp_Array[li_Index].dw_1,"ScaleToRight&Bottom")
		NEXT

		Return
	END IF
NEXT

MessageBox("Programming Error","No tab control on window!",StopSign!)

Close(this)

end event

event pfc_begintran;call super::pfc_begintran;EXECUTE IMMEDIATE "begin transaction";

Return 1

end event

event pfc_postopen;call super::pfc_postopen;

//*******************************************************
// Check for edit access:
//*******************************************************

This.Event ue_check_access()

end event

