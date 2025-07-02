forward
global type u_tabpg_projschedule from u_tabpg_appinfo_base
end type
end forward

global type u_tabpg_projschedule from u_tabpg_appinfo_base
string tag = "Project Schedule"
string text = "Schedule"
string picturename = "MonthCalendar!"
end type
global u_tabpg_projschedule u_tabpg_projschedule

on u_tabpg_projschedule.create
call super::create
end on

on u_tabpg_projschedule.destroy
call super::destroy
end on

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_projschedule
boolean enabled = false
string dataobject = "d_proj_application_sched"
end type

event dw_1::pfc_updateprep;call super::pfc_updateprep;

Long 	ll_row, ll_gigpID

//*******************************************************
// Loop thru modified rows:
//*******************************************************

ll_row	= dw_1.GetNextModified(0, Primary!)

DO WHILE ll_row > 0	
	
	//*******************************************************
	// If new row, Set key values:
	//*******************************************************

	ll_gigpID = This.GetItemNumber(ll_row, "gigp_id")

	If IsNull(ll_gigpID) Then
		This.SetItem(ll_row, "gigp_id",gl_gigp_id)	  
		This.SetItem(ll_row, "ref_code", This.GetItemString(ll_row, "ref_ref_code")) 	
		This.SetItem(ll_row, "last_updated_by", gnv_app.of_getuserid())
		This.SetItem(ll_row, "last_updated_dt", f_getdbdatetime())		
		This.SetItemStatus(ll_row, 0,  Primary!, NewModified!)
	End If
		
	ll_row = dw_1.GetNextModified(ll_row, Primary!)

LOOP

Return AncestorReturnValue

end event

