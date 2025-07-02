//objectcomments Master Detail ancestor window. Mulitple master rows, multiple detail rows.
forward
global type w_master_detail_mm from w_sheet
end type
type dw_master from u_dw_enhanced within w_master_detail_mm
end type
type dw_detail from u_dw_enhanced within w_master_detail_mm
end type
end forward

global type w_master_detail_mm from w_sheet
string tag = "Master Detail"
integer width = 2917
integer height = 1420
string title = "Master Detail"
long backcolor = 67108864
event ue_postsuccess ( )
event ue_postfailure ( )
event ue_setorigsize ( )
event ue_reconnect ( )
dw_master dw_master
dw_detail dw_detail
end type
global w_master_detail_mm w_master_detail_mm

type variables
Protected:

  // Set up these arrays in the decendant's open event.
  string	is_Master_Columns[], &
	is_Detail_Columns[]

  // This specifies how dw's are related. If needed,
  // it can be changed in the decendant's open event.
  int	ii_SetUserColLinks = 1

  // Set these to more appropriate display values in the
  // descendant.
  string	is_Master_Name = "Master", &
	is_Detail_Name = "Detail"

  // Change this to false in descendants if no DB
  // referential integrity needs to be enforced.
  boolean	ib_Enforce_Integrity = True

  // Used to call of_SetOrigSize() of Resize Service
  // since windows are opened Layered! instead of
  // original.
  // These numbers are the WorkSpaceWidth and
  // WorkSpaceHeight, not the Width and Height.

  // WorkSpaceWidth = Width - 28
  // WorkSpaceHeight = Height - 100
  int	ii_Orig_Width = 2889, &
	ii_Orig_Height = 1321

Private:
  boolean ib_Violation

end variables

forward prototypes
public function integer of_preupdateedits ()
end prototypes

event ue_postsuccess;// This event will happen after a successful update.	//

dw_master.inv_linkage.of_Retrieve()

end event

event ue_postfailure;// This event will happen after an update failure.	//
end event

event ue_setorigsize;// Set ii_Orig_Height and ii_Orig_Width in this event in descendants	//
// that have changed their size in the window painter.					//

// These variables are set in the "Declare Instance Variables" section	//
// to equal this ancestor's "width - 28" and "height - 100". These		//
// numbers subtract 28 and 100 to account for the width of window			//
// borders and menus and toolbars.													//

end event

event ue_reconnect;// This event is called from f_reconnect().	//

dw_master.inv_linkage.of_SetTransObject(sqlca)

end event

public function integer of_preupdateedits ();// Override this in descendants and place edits there.	//
// Return 1 to let save process continue, -1 to stop it.	//

Return 1

end function

on w_master_detail_mm.create
int iCurrent
call super::create
this.dw_master=create dw_master
this.dw_detail=create dw_detail
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_master
this.Control[iCurrent+2]=this.dw_detail
end on

on w_master_detail_mm.destroy
call super::destroy
destroy(this.dw_master)
destroy(this.dw_detail)
end on

event pfc_postopen;int	li_Index, &
		li_Key_Columns

dw_master.SetRowFocusIndicator(Hand!)
dw_detail.SetRowFocusIndicator(Hand!)

// Start typical services.	//
dw_master.of_SetTypicalServices(True)
dw_detail.of_SetTypicalServices(True)

// Turn on linkage service for both dw's.	//
dw_master.of_SetLinkage(True)
dw_detail.of_SetLinkage(True)

// Link dw_detail to dw_master.	//
dw_detail.inv_linkage.of_SetMaster(dw_master)

// Set transaction objects for both dw's. Linkage service ripples this	//
// action through to dw_detail.														//
dw_master.inv_linkage.of_SetTransObject(sqlca)

// How many columns make up dw_detail's key?	//
li_Key_Columns = UpperBound(is_Master_Columns)

IF li_Key_Columns <= 0 THEN
	MessageBox("Programming Error","is_Master_Columns[] " + &
					"must be populated.",StopSign!)
	Close(this)
END IF

// Make sure array elements match.	//
IF li_Key_Columns <> UpperBound(is_Detail_Columns) THEN
	MessageBox("Programming Error","Number of key columns in is_Master_Columns[] " + &
					"must match number of key columns in is_Detail_Columns[]",StopSign!)
	Close(this)
END IF

// Set up linkage arguments.	//
FOR li_Index = 1 TO li_Key_Columns
	// Make sure arrays were set up right.	//
	IF NOT IsNull(is_Master_Columns[li_Index]) AND &
			NOT IsNull(is_Detail_Columns[li_Index]) THEN

		dw_detail.inv_linkage.of_Register(is_Master_Columns[li_Index], &
														is_Detail_Columns[li_Index])
	ELSE
		MessageBox("Programming Error","Null key column in is_Master_Columns[] " + &
						"or is_Detail_Columns[]",StopSign!)
		Close(this)
	END IF
NEXT

// Specify which way dw's relate.	//
dw_detail.inv_linkage.of_SetStyle(ii_SetUserColLinks)

// Retrieve data.	//
dw_master.inv_linkage.of_Retrieve()

end event

event open;call super::open;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// USAGE NOTES:																				//
//																									//
// There are two instance string arrays declared, is_Master_Columns[] and	//
// is_Detail_Columns[]. In the decendant Open! event, set up these arrays	//
// so that each one has an element for each linking column between			//
// dw_detail and dw_master.																//
//																									//
// These arrays are used in the pfc_postopen event to set up the linkage	//
// attributes. Here is an example of what to do:									//
//																									//
// In this example, dw_master displays Departments and dw_detail displays	//
// Employees within a Department.														//
//																									//
//	dw_detail has two key columns, "dept_id" and "emp_id".						//
//	dw_master has one key column, "dept_id".											//
//																									//
//	This is what should be in the descendant's open event:						//
//		is_Master_Columns[1] = "dept_id"													//
//		is_Detail_Columns[1] = "dept_id"													//
/////////////////////////////////////////////////////////////////////////////

SetPointer(HourGlass!)

// Give descendant a chance to set original size.	//
this.Event ue_setorigsize()

// Align sheet toolbar next to the frame toolbar.	//
f_aligntoolbars(this)

// Turn on resize service.	//
this.of_SetResize(True)

// Call of_SetOrigSize in case this wasn't opened with	//
// size = Original!.													//
this.inv_resize.of_SetOrigSize(ii_Orig_Width,ii_Orig_Height)

this.inv_Resize.of_SetMinSize(ii_Orig_Width,ii_Orig_Height)
this.inv_Resize.of_Register(dw_master,"ScaleToRight&Bottom")
this.inv_Resize.of_Register(dw_detail,"FixedToBottom&ScaleToRight")

end event

event pfc_endtran;call super::pfc_endtran;IF ai_update_results = 1 THEN
	EXECUTE IMMEDIATE "commit";

	MessageBox(this.Tag,"Update was successful.")

//	f_transactionlog(this.ClassName(),this.Tag,"Successful Update","",0)

	this.Event Post ue_PostSuccess()

	Return 1
ELSE
	EXECUTE IMMEDIATE "rollback";

	MessageBox(this.Tag,"Update failed.")

//	f_transactionlog(this.ClassName(),this.Tag,"Update Failed",sqlca.SQLErrText,sqlca.SQLDBCode)

	this.Event Post ue_PostFailure()

	Return -1
END IF

end event

event pfc_preupdate;call super::pfc_preupdate;// Call this stub function to allow descendants to perform pre-update edits	//
// and stop the save process if needed.													//

Return this.of_PreUpdateEdits()

end event

event pfc_begintran;call super::pfc_begintran;EXECUTE IMMEDIATE "begin transaction";

Return 1

end event

type dw_master from u_dw_enhanced within w_master_detail_mm
integer x = 46
integer y = 28
integer width = 2766
integer height = 336
integer taborder = 10
boolean hscrollbar = true
boolean hsplitscroll = true
end type

event pfc_retrieve;call super::pfc_retrieve;// Override this if you need to provide retrieval arguments.	//

Return this.Retrieve()

end event

event pfc_deleterow;// OVERRIDE.	//

IF ib_Enforce_Integrity THEN
	IF dw_detail.RowCount() > 0 THEN
		MessageBox("Delete Error","You cannot delete a " + is_Master_Name + &
				" row until all " + is_Detail_Name + " detail rows have been " + &
				"deleted.",Exclamation!)
		Return -1
	ELSE
		IF dw_detail.DeletedCount() > 0 THEN
			MessageBox("Delete Error","Deleted " + is_Detail_Name + &
					" rows have not been saved to the DataBase. Click Save " + &
					"and then try to delete this row again.",Exclamation!)
			Return -1
		END IF
	END IF
END IF

Return super::Event pfc_deleterow()

end event

event losefocus;this.AcceptText()

end event

type dw_detail from u_dw_enhanced within w_master_detail_mm
integer x = 46
integer y = 404
integer width = 2766
integer height = 868
integer taborder = 20
boolean bringtotop = true
boolean hscrollbar = true
boolean hsplitscroll = true
end type

event losefocus;call super::losefocus;this.AcceptText()

end event

event pfc_retrieve;call super::pfc_retrieve;// Override this if you need to provide retrieval arguments.	//

Return this.Retrieve()

end event

