forward
global type u_tabpg_contactmgmt_politdistricts from u_tabpg_dbaccess
end type
end forward

global type u_tabpg_contactmgmt_politdistricts from u_tabpg_dbaccess
string text = "Legislative Districts"
string picturename = "Library!"
end type
global u_tabpg_contactmgmt_politdistricts u_tabpg_contactmgmt_politdistricts

on u_tabpg_contactmgmt_politdistricts.create
call super::create
end on

on u_tabpg_contactmgmt_politdistricts.destroy
call super::destroy
end on

event ue_delete;call super::ue_delete;
integer li_RC
li_RC = dw_1.inv_rowmanager.of_DeleteAll( )
end event

type dw_1 from u_tabpg_dbaccess`dw_1 within u_tabpg_contactmgmt_politdistricts
string dataobject = "d_political_districts"
end type

event dw_1::constructor;call super::constructor;
//********************************************************************
// Turn on the PFC Row Manager Service:
//********************************************************************

This.of_SetRowManager(TRUE)
This.inv_rowmanager.of_SetConfirmOnDelete(FALSE)

//********************************************************************
// Make Read-Only:
//********************************************************************

This.Object.DataWindow.ReadOnly="Yes"
end event

event dw_1::pfc_retrieve;
//OverRide//

//PFC Linkage Service manages Retrieve

Return 1
end event

event dw_1::sqlpreview;call super::sqlpreview;
Long ll_contactID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN
	
	ll_contactID = This.GetItemNumber(row, "contact_id", buffer, False)
	
	f_transactionlog("contact_id", ll_contactID, This.DataObject, "Contacts", sqlsyntax)
END IF
end event

