forward
global type u_tabpg_legal from u_tabpg_appinfo_base
end type
end forward

global type u_tabpg_legal from u_tabpg_appinfo_base
string tag = "Legal"
integer height = 2000
string text = "Legal"
string picturename = "PictureListBox!"
end type
global u_tabpg_legal u_tabpg_legal

on u_tabpg_legal.create
call super::create
end on

on u_tabpg_legal.destroy
call super::destroy
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Legal"}
end event

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_legal
event ue_set_bondres ( integer ai_enable,  boolean ab_init )
integer height = 1976
string dataobject = "d_proj_project_legal_dates"
end type

event dw_1::ue_set_bondres(integer ai_enable, boolean ab_init);long ll_count, ll_row
string ls_item
dwItemStatus ldws_status

ll_count = this.RowCount()
			
For ll_row = 1 to ll_count
	ls_item = this.GetItemString(ll_row, 'ref_description')
	
	If ls_item = 'Estoppel Notice:' or ls_item = 'Permissive Referendum Notice:' Then
		ldws_status = this.GetItemStatus(ll_row, 0, Primary!)
		this.SetItem(ll_row, 'cf_enable', ai_enable)
		this.SetItemStatus(ll_row, 0, Primary!, ldws_status)
		
		//Check for Row and insert if necessary
		If ai_enable = 0 Then
			If IsNull(this.GetItemNumber(ll_row, 'gigp_id')) or this.GetItemNumber(ll_row, 'gigp_id') <=0 Then
				//insert
				This.SetItem(ll_row, "keydate_ind", 'NA')
				This.SetItem(ll_row, "gigp_id",gl_gigp_id)	  
				This.SetItem(ll_row, "keydate_choice",'N')
				This.SetItem(ll_row, "ref_code", This.GetItemString(ll_row, "ref_ref_code")) 	
				This.SetItem(ll_row, "last_updated_by", gnv_app.of_getuserid())
				This.SetItem(ll_row, "last_updated_dt", f_getdbdatetime())		
				This.SetItemStatus(ll_row, 0,  Primary!, NewModified!)
				
			Else
				//Update
				This.SetItem(ll_row, "keydate_ind", 'NA')
				This.SetItem(ll_row, "keydate_choice",'N')
				This.SetItem(ll_row, "last_updated_by", gnv_app.of_getuserid())
				This.SetItem(ll_row, "last_updated_dt", f_getdbdatetime())
			End If
			
			If ab_init Then
				this.SetItemStatus(ll_row, 0, Primary!, NotModified!)
			End If
			
		End If
		
	End If
	
Next
end event

event dw_1::buttonclicked;call super::buttonclicked;
String 	ls_Text, ls_noteUser, ls_appUser, ls_access
Integer	li_RC

If (dwo.Name = "b_edit") Then	
	
	ls_access = "READ"
	
	dw_1.AcceptText()	
	
	ls_Text     = This.GetItemString(row, "keydate_comments")
			
	If (ib_editAccess = True) Then ls_access = "EDIT"	
	
	li_RC = f_edit_notes(ls_access, ls_Text)
	
	If (li_RC = 1) Then This.SetItem(row, "keydate_comments", ls_Text)	
	
End If
end event

event dw_1::pfc_updateprep;call super::pfc_updateprep;Long 	ll_row, ll_gigpID

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

event dw_1::itemchanged;call super::itemchanged;datetime ldt_date
string ls_status, ls_item

If lower(gnv_app.of_getuserid()) <> 'syron' and lower(gnv_app.of_getuserid()) <> 'hahn' Then
	parent.of_add_notification(this.GetItemString(row, 'ref_description'), gnv_app.of_getuserid(), row, False)
End If

If dwo.name <> 'keydate_choice' Then
	If IsNull(this.GetItemString(row, 'keydate_choice')) Then this.SetItem(row, 'keydate_choice', 'N')
End If

Choose Case dwo.name
	Case 'keydate_value'

		ldt_date = this.GetItemDateTime(row, 'keydate_value', Primary!, True)
		
		If IsNull(ldt_date) Then
			ls_status = this.GetItemString(row, 'keydate_ind')
			
			If IsNull(ls_status) Then
				this.SetItem(row, 'keydate_ind', 'PENDING')
			End If
			
		End If
		
	Case 'keydate_ind'	//handles disabling of 2 items based on Bond Res being N/A
		
		ls_item = this.GetItemString(row, 'ref_description')
		
		If ls_item = 'Bond Resolution:' Then
			If data = 'NA' Then
				this.Event Post ue_set_bondres(0, false)
			Else
				this.Event Post ue_set_bondres(1, false)
			End If
			
		End If
		
	Case 'keydate_choice'
		If data = 'N/A' Then
			this.SetItem(row, 'keydate_ind', 'NA')
		End If
		
End Choose
end event

event dw_1::retrieveend;call super::retrieveend;long ll_row
string ls_status, ls_item

For ll_row = 1 to rowcount
	ls_item = this.GetItemString(ll_row, 'ref_description')
		
		If ls_item = 'Bond Resolution:' Then
			ls_status = this.GetItemString(ll_row, 'keydate_ind')
			
			If ls_status = 'NA' Then
				this.Event Post ue_set_bondres(0, true)
			Else
				this.Event Post ue_set_bondres(1, true)
			End If
			
		End If
	
Next
end event

