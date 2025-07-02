//objectcomments Use this ancestor for sheets that revolve around editing one table.
forward
global type w_detail from w_sheet
end type
type dw_detail from u_dw_enhanced within w_detail
end type
end forward

global type w_detail from w_sheet
long backcolor = 67108864
event ue_postsuccess ( )
event ue_postfailure ( )
event ue_setorigsize ( )
event ue_reconnect ( )
event ue_check_access ( )
dw_detail dw_detail
end type
global w_detail w_detail

type variables

String 	is_accessGroups[]
Boolean 	ib_editAccess


Protected:
  // Used to call of_SetOrigSize() of Resize Service
  // since windows are opened Layered! instead of
  // original.

  // These numbers are the WorkSpaceWidth and
  // WorkSpaceHeight, not the Width and Height.

  // WorkSpaceWidth = Width - 28
  // WorkSpaceHeight = Height - 100

  int	ii_Orig_Width = 2459, &
	ii_Orig_Height = 1384

end variables

forward prototypes
public function integer of_preupdateedits ()
end prototypes

event ue_postsuccess;// This event will happen after a successful update.	//

// Retrieve data.	//
dw_detail.Event pfc_Retrieve()

end event

event ue_postfailure;// This event will happen after an update failure.	//
end event

event ue_setorigsize;// Set ii_Orig_Height and ii_Orig_Width in this event in descendants	//
// that have changed their size in the window painter.					//

// These variables are set in the "Declare Instance Variables" section	//
// to equal this ancestor's "width - 28" and "height - 100". These		//
// numbers subtract 28 and 100 to account for the width and height of	//
// window borders and menus and toolbars.											//

end event

event ue_reconnect;// This script is called by f_reconnect().	//
dw_detail.of_SetTransObject(sqlca)

end event

event ue_check_access();
//Long ll_index, ll_upper
//u_dw lu_dw
//
////*******************************************************
//// Check for edit access:
////*******************************************************
//
//ib_editAccess = gnv_app.of_ingroup(is_accessGroups)
//
//If (ib_editAccess = True) Then
//	
//Else
//	This.Title = (This.Title + " [Read Only]")
//	
//	ll_upper = UpperBound(Control)
//	
//	FOR ll_index = 1 To ll_upper
//		
//		IF TypeOf(Control[ll_index]) = Datawindow! THEN
//
//			lu_dw = Control[ll_index]		
//			lu_dw.Modify("DataWindow.ReadOnly=Yes")
//
//      END IF    	
//
//	NEXT
//	
//End If
end event

public function integer of_preupdateedits ();// Override this in descendants and place edits there.	//
// Return 1 to let save process continue, -1 to stop it.	//

Return 1

end function

event open;call super::open;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

SetPointer(HourGlass!)

// Give descendant a chance to set original size.	//
this.Event ue_setorigsize()

dw_detail.of_SetTransObject(sqlca)

// Align sheet toolbar next to frame toolbar.	//
f_aligntoolbars(this)

// Turn on resize service.	//
this.of_SetResize(True)

// Call of_SetOrigSize in case this wasn't opened with 	//
// size = Original!.													//
this.inv_resize.of_SetOrigSize(ii_Orig_Width,ii_Orig_Height)

this.inv_Resize.of_SetMinSize(ii_Orig_Width,ii_Orig_Height)
this.inv_Resize.of_Register(dw_detail,"ScaleToRight&Bottom")

end event

on w_detail.create
int iCurrent
call super::create
this.dw_detail=create dw_detail
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail
end on

on w_detail.destroy
call super::destroy
destroy(this.dw_detail)
end on

event pfc_begintran;call super::pfc_begintran;EXECUTE IMMEDIATE "begin transaction";

Return 1

end event

event pfc_endtran;call super::pfc_endtran;IF ai_update_results = 1 THEN
	EXECUTE IMMEDIATE "commit";

	MessageBox(this.Tag,"Update was successful.")

//	f_transactionlog(this.ClassName(),this.Tag,"Successful Update","",0)

	this.Event Post ue_postsuccess()

	Return 1
ELSE
	EXECUTE IMMEDIATE "rollback";

	MessageBox(this.Tag,"Update failed.")

//	f_transactionlog(this.ClassName(),this.Tag,"Update Failed",sqlca.SQLErrText,sqlca.SQLDBCode)

	this.Event Post ue_postfailure()

	Return -1
END IF

end event

event pfc_postopen;// This function starts many services for the dw.	//
dw_detail.of_SetTypicalServices(True)

// Retrieve data.	//
dw_detail.Event pfc_Retrieve()

//*******************************************************
// Check for edit access:
//*******************************************************

This.Event ue_check_access()


end event

event pfc_preupdate;call super::pfc_preupdate;// Call stub function to allow descendant to edit data and stop update as needed.	//
Return this.of_PreUpdateEdits()
end event

type dw_detail from u_dw_enhanced within w_detail
integer x = 119
integer y = 100
integer width = 2158
integer height = 1116
boolean hscrollbar = true
boolean hsplitscroll = true
end type

event pfc_retrieve;call super::pfc_retrieve;// Override this if you need to provide retrieval arguments.	//

Return this.Retrieve()

end event

event losefocus;this.AcceptText()

end event

