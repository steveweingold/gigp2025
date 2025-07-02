forward
global type u_tabpg_projmetricinfo from u_tabpg_appinfo_base
end type
end forward

global type u_tabpg_projmetricinfo from u_tabpg_appinfo_base
string tag = "Project Metrics"
string text = "Metrics"
string picturename = "TabOrder!"
end type
global u_tabpg_projmetricinfo u_tabpg_projmetricinfo

on u_tabpg_projmetricinfo.create
call super::create
end on

on u_tabpg_projmetricinfo.destroy
call super::destroy
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Application"}
end event

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_projmetricinfo
string dataobject = "d_proj_metric_info"
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
		This.SetItem(ll_row, "category", This.GetItemString(ll_row, "ref_category")) 	
		This.SetItem(ll_row, "sub_category", This.GetItemString(ll_row, "ref_sub_category")) 		
		This.SetItem(ll_row, "last_updated_by", gnv_app.of_getuserid())
		This.SetItem(ll_row, "last_updated_dt", f_getdbdatetime())		
		This.SetItemStatus(ll_row, 0,  Primary!, NewModified!)
	End If
		
	ll_row = dw_1.GetNextModified(ll_row, Primary!)

LOOP

Return AncestorReturnValue
end event

event dw_1::itemchanged;call super::itemchanged;
This.SetItem(row, "last_updated_by", gnv_app.of_getuserid())
This.SetItem(row, "last_updated_dt", f_getdbdatetime())	
end event

event dw_1::buttonclicked;call super::buttonclicked;If dwo.name = 'b_designcalc' Then
	Open(w_design_calc)
End If
end event

