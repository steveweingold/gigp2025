forward
global type u_tabpg_projfunding from u_tabpg_appinfo_base
end type
end forward

global type u_tabpg_projfunding from u_tabpg_appinfo_base
string tag = "Project Funding"
string text = "Funding"
string picturename = "FormatDollar!"
end type
global u_tabpg_projfunding u_tabpg_projfunding

on u_tabpg_projfunding.create
call super::create
end on

on u_tabpg_projfunding.destroy
call super::destroy
end on

event ue_addrow;call super::ue_addrow;
Long ll_newRow, ll_value, ll_sort

//Add a row after current row

ll_newRow = dw_1.InsertRow(al_row + 1)

dw_1.inv_rowselect.Event pfc_rowFocusChanged(ll_newRow)

ll_value  = 	 f_gettokenvalue("AmountID", 1)

dw_1.SetItem(ll_newRow, "amount_id",  ll_value)

dw_1.SetItem(ll_newRow, "gigp_id",gl_gigp_id )

dw_1.SetItem(ll_newRow, "ref_code",  "OTHFS")
dw_1.SetItem(ll_newRow, "sub_category",   "Other")
dw_1.SetItem(ll_newRow, "description", "Other Funding Source")

dw_1.SetItem(ll_newRow, "ref_amt",  0)
dw_1.SetItem(ll_newRow, "approved_amt",  0)

Select sort_order
Into: ll_sort
From gigp_reference
Where category = "ProjectFunding"
And sub_category = "Other";

dw_1.SetItem(ll_newRow, "sort_order",  ll_sort)


end event

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_projfunding
string dataobject = "d_proj_application_funding"
end type

event dw_1::itemchanged;call super::itemchanged;This.SetItem(row, "last_updated_by", gnv_app.of_getuserid())
This.SetItem(row, "last_updated_dt", f_getdbdatetime())
end event

event dw_1::constructor;call super::constructor;
//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)
end event

event dw_1::buttonclicked;call super::buttonclicked;
If ( ib_editAccess = True) Then

	//*************************************************************
	// Insert Other Funding Source Rows
	//*************************************************************
	
	If (dwo.Name = "b_insert") Then
		Parent.Event ue_addRow(row)
	End If
	
	//*************************************************************
	// Delete Other Funding Source Row:
	//*************************************************************
	
	If (dwo.Name = "b_delete") Then
		This.Event pfc_DeleteRow()
	End If

End If
end event

event dw_1::pfc_updateprep;call super::pfc_updateprep;Long ll_row, ll_gigpID, ll_amountID

//*******************************************************
// Loop Thru DW and Validate user entry:
//*******************************************************

ll_row	= dw_1.GetNextModified(0, Primary!)

DO WHILE ll_row > 0	
	
	SetNull(ll_gigpID)
	
	ll_gigpID = dw_1.GetItemNumber(ll_row, "gigp_id")

	If (IsNull(ll_gigpID)) Then

		ll_amountID  = 	 f_gettokenvalue("AmountID",1)	
	
		dw_1.SetItem(ll_row, "amount_id", ll_amountID)
		dw_1.SetItem(ll_row, "sub_category", dw_1.GetItemString(ll_row, "ref_sub_category"))
		dw_1.SetItem(ll_row, "gigp_id", gl_gigp_id)	      
		dw_1.SetItem(ll_row, "ref_code", dw_1.GetItemString(ll_row, "ref_ref_code")) 	
		dw_1.SetItemStatus(ll_row, 0, Primary!, NewModified!)
		
	End If
	
	ll_row = dw_1.GetNextModified(ll_row, Primary!)

LOOP

Return AncestorReturnValue
end event

