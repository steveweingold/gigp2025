forward
global type u_tabpg_readiness_dates from u_tabpg_appinfo_base
end type
end forward

global type u_tabpg_readiness_dates from u_tabpg_appinfo_base
string tag = "Readiness/Engineering"
integer height = 2000
string text = "Readiness/Engineering"
string picturename = "PictureListBox!"
end type
global u_tabpg_readiness_dates u_tabpg_readiness_dates

type variables
boolean ib_updateSEQR = False
end variables

on u_tabpg_readiness_dates.create
call super::create
end on

on u_tabpg_readiness_dates.destroy
call super::destroy
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Contract"}
end event

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_readiness_dates
integer x = 18
integer y = 12
integer width = 2821
integer height = 1968
string dataobject = "d_proj_project_readiness_dates"
end type

event dw_1::pfc_updateprep;call super::pfc_updateprep;Long 	ll_row, ll_gigpID, ll_count
datetime ldt_date
string ls_user

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
	
	
	//*******************************************************
	// Check for Serp Cert Approval to update SEQR:
	//*******************************************************
	If this.GetItemString(ll_row, 'ref_ref_code') = 'readySERPCERTSNTREG' and ib_updateSEQR Then
		ib_updateSEQR = False
		
		ldt_date = this.GetItemDateTime(ll_row, 'keydate_value2')
		
		If NOT IsNull(ldt_date) Then
			ls_user = gnv_app.of_getuserid()
			
			select count(*)
			into :ll_count
			from gigp_key_dates
			where gigp_id = :gl_gigp_id
			and ref_code = 'seqrSERPCERTCOMPL';
			
			If ll_count = 0 Then
				//insert
				insert into gigp_key_dates (gigp_id, ref_code, keydate_value, keydate_ind, last_updated_by, last_updated_dt)
				values (:gl_gigp_id, 'seqrSERPCERTCOMPL', :ldt_date, 'PENDING', :ls_user, getdate());
				
			Else
				//update
				update gigp_key_dates
				set 	keydate_value = :ldt_date,
						keydate_ind = 'PENDING',
						last_updated_by = :ls_user,
						last_updated_dt = getdate()
				where gigp_id = :gl_gigp_id
				and ref_code = 'seqrSERPCERTCOMPL';
				
				
			End If
					
		End If
		
	End If
		
	ll_row = dw_1.GetNextModified(ll_row, Primary!)

LOOP

Return AncestorReturnValue











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

event dw_1::itemchanged;call super::itemchanged;datetime ldt_date
string ls_status, ls_null, ls_ind

If lower(gnv_app.of_getuserid()) <> 'syron' and lower(gnv_app.of_getuserid()) <> 'hahn' Then
	parent.of_add_notification(this.GetItemString(row, 'ref_description'), gnv_app.of_getuserid(), row, False)
End If

//If dwo.name <> 'keydate_ind' Then
//	ls_ind = this.GetItemString(row, 'keydate_ind')
//	
//	If IsNull(ls_ind) Then
//		dw_1.SetItem(row, 'keydate_ind' ,'0')
//	End If
//
//End If

Choose Case dwo.name
	Case 'keydate_ind'
		If data = 'T' Then
			this.SetItem(row, 'keydate_choice', 'TARGET')
			
		ElseIf data = 'A' Then
			this.SetItem(row, 'keydate_choice', 'ACTUAL')
			
		End If
		
	Case  'keydate_value'
		
		ldt_date = this.GetItemDateTime(row, 'keydate_value', Primary!, True)
		
		If IsNull(ldt_date) Then
			ls_status = this.GetItemString(row, 'keydate_choice')
			
			If IsNull(ls_status) Then
				this.SetItem(row, 'keydate_choice', 'PENDING')
			End If
			
		End If
		
	Case 'keydate_choice'
		If data = 'APPROVED' and this.GetItemString(row, 'ref_ref_code') = 'readySERPCERTSNTREG' Then
			ib_updateSEQR = True
		End If
		
End Choose

end event

event dw_1::pfc_retrieve;call super::pfc_retrieve;long ll_row, ll_count, ll_pos
string ls_ta
datawindowchild ldwc

//See which rows should ONLY be Target/Actual
select description
into :ls_ta
from gigp_reference
where category = 'ReadinessTA';

ll_count = this.RowCount()

For ll_row = 1 to ll_count
	If POS(ls_ta, this.GetItemString(ll_row, 'ref_ref_code')) > 0 Then
		this.SetItem(ll_row, 'TA', 1)
		
		If this.GetItemString(ll_row, 'keydate_choice') = 'TARGET' Then
			this.SetItem(ll_row, 'keydate_ind', 'T')
			this.SetItemStatus(ll_row, 'keydate_ind', Primary!, NotModified!)
		ElseIf this.GetItemString(ll_row, 'keydate_choice') = 'ACTUAL' Then
			this.SetItem(ll_row, 'keydate_ind', 'A')
			this.SetItemStatus(ll_row, 'keydate_ind', Primary!, NotModified!)
		End If
		
		this.SetItemStatus(ll_row, 0, Primary!, NotModified!)
		
	End If
Next

//Filter out Target / Actual from rest
this.GetChild('keydate_choice', ldwc)
ldwc.SetFilter("ref_code not in ('TARGET','ACTUAL')")
ldwc.Filter()

Return ancestorreturnvalue
end event

