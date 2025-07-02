forward
global type u_tabpg_tas_items from u_tabpg_appinfo_base
end type
end forward

global type u_tabpg_tas_items from u_tabpg_appinfo_base
string tag = "GPPI Items"
integer height = 2000
string text = "GPPI"
string picturename = "PictureListBox!"
end type
global u_tabpg_tas_items u_tabpg_tas_items

type variables
boolean ib_updateSEQR = False
boolean ib_updateCWSRFBegin = False
boolean ib_updateCWSRFEnd = False

end variables

forward prototypes
public function integer of_updatecwsrf ()
public function integer of_send_construction_notification ()
end prototypes

public function integer of_updatecwsrf ();long ll_find, ll_count, ll_ID, ll_contract, ll_date
string ls_ta, ls_Project_No, ls_user
datetime ldt_date

ls_user = gnv_app.of_getuserid()

select project_no
into :ls_Project_No
from gigp_application
where gigp_id = :gl_gigp_id;

If NOT IsNull(ls_Project_No) Then
	
	If ib_updatecwsrfbegin Then
		ll_find = dw_1.Find("ref_code = 'readyCONSTRCOMM'", 0, dw_1.RowCount())
		
		If ll_find > 0 Then
			ldt_date = dw_1.GetItemDateTime(ll_find, 'keydate_value')
			ls_ta = dw_1.GetItemString(ll_find, 'keydate_ind')
			
			If NOT IsNull(ldt_date) Then
				If gb_usehubtablesswitch Then
					//Update Hub Tables
					
					//Find existing Construction Contract
					select Max(c.ContractId)		//Should just be one, but just in case to avoid an error
					into :ll_contract
					from ProjectPhase pp, Contract c, ContractProjectPhase cpp
					where pp.ProjectPhaseId = cpp.ProjectPhaseId
					and cpp.ContractId = c.ContractId
					and c.ContractType = 'Construction'
					and pp.ProjectNumber = :ls_Project_No;
					
					If ll_contract > 0 Then
						//Find the Construction Start date for this contract
						select Max(ContractDateId)		//Should just be one, but just in case to avoid an error
						into :ll_date
						from ContractDate
						where ContractId = :ll_contract
						and DateType = 'Construction Start';

						If ll_date > 0 Then
							//Date found so Update
							update ContractDate
							set DateValue = :ldt_date,
								TargetActual = :ls_ta,
								LastUpdatedBy = :ls_user,
								LastUpdatedDt = getdate()
							where ContractDateId = :ll_date;
						
						Else
							//Date not found so Insert
							insert into ContractDate (ContractId, DateType, DateValue, TargetActual, LastUpdatedDate, LastUpdatedBy)
							values (:ll_contract, 'Construction Start', :ldt_date, :ls_ta, getdate(), :ls_user);
							
						End If
					End If
					
					
				Else
					update cwsrf_main
					set d_constr_start = :ldt_date,
						c_constr_start_ta = :ls_ta
					where c_proj_no = :ls_Project_No;
					
				End If
			End If
		End If
	End If
	
	If  ib_updatecwsrfend Then
		ll_find = dw_1.Find("ref_code = 'readyCONSTRCOMPL'", 0, dw_1.RowCount())
		
		ldt_date = dw_1.GetItemDateTime(ll_find, 'keydate_value')
		ls_ta = dw_1.GetItemString(ll_find, 'keydate_ind')
			
		If NOT IsNull(ldt_date) Then
			If gb_usehubtablesswitch Then
				//Update Hub Tables
					
				//Find existing Construction Contract
				select Max(c.ContractId)		//Should just be one, but just in case to avoid an error
				into :ll_contract
				from ProjectPhase pp, Contract c, ContractProjectPhase cpp
				where pp.ProjectPhaseId = cpp.ProjectPhaseId
				and cpp.ContractId = c.ContractId
				and c.ContractType = 'Construction'
				and pp.ProjectNumber = :ls_Project_No;
				
				If ll_contract > 0 Then
					//Find the Construction Start date for this contract
					select Max(ContractDateId)		//Should just be one, but just in case to avoid an error
					into :ll_date
					from ContractDate
					where ContractId = :ll_contract
					and DateType = 'Construction End';

					If ll_date > 0 Then
						//Date found so Update
						update ContractDate
						set DateValue = :ldt_date,
							TargetActual = :ls_ta,
							LastUpdatedBy = :ls_user,
							LastUpdatedDt = getdate()
						where ContractDateId = :ll_date;
					
					Else
						//Date not found so Insert
						insert into ContractDate (ContractId, DateType, DateValue, TargetActual, LastUpdatedDate, LastUpdatedBy)
						values (:ll_contract, 'Construction End', :ldt_date, :ls_ta, getdate(), :ls_user);
						
					End If
				End If
				
			Else
				
				update cwsrf_main
				set d_constr_complete = :ldt_date,
					c_constr_complete_ta = :ls_ta
				where c_proj_no = :ls_Project_No;
				
			End If
		End If
	End If
End If


ib_updatecwsrfbegin = False
ib_updatecwsrfend = False

Return 1

end function

public function integer of_send_construction_notification ();integer li_index, li_count
string ls_null, ls_sendto

//Get analyst info
select description
into :ls_sendto
from gigp_reference
where category = 'ConstructNotice';

If ls_sendto > '' and is_notif_subj_constr> ''  Then
	
	SetNull(ls_null)
	
	f_send_email_alert(is_notif_subj_constr, is_notif_body_constr, ls_sendto)
	is_notif_subj_constr = ls_null
	is_notif_body_constr = ls_null

End If

Return 1
end function

on u_tabpg_tas_items.create
call super::create
end on

on u_tabpg_tas_items.destroy
call super::destroy
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Contract"}
end event

event pfc_postupdate;call super::pfc_postupdate;If AncestorReturnValue = 1 Then
	this.of_send_construction_notification()
End If

Return AncestorReturnValue
end event

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_tas_items
integer x = 18
integer y = 12
integer width = 2821
integer height = 1968
string dataobject = "d_proj_project_tas_dates"
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

If dwo.name = 'keydate_value' or dwo.name = 'keydate_value2' Then
	If  this.GetItemString(row, 'ref_code') = 'readyCONSTRCOMM' or this.GetItemString(row, 'ref_code') = 'readyCONSTRCOMPL' Then
		parent.of_add_notification(this.GetItemString(row, 'ref_description'), gnv_app.of_getuserid(), row, True)
	End If
End If

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
		
		//Update CWISS
		If this.GetItemString(row, 'ref_code') = 'readyCONSTRCOMM' Then
			ib_updateCWSRFBegin = True
		End If
		
		If this.GetItemString(row, 'ref_code') = 'readyCONSTRCOMPL' Then
			ib_updateCWSRFEnd = True
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

event dw_1::pfc_postupdate;call super::pfc_postupdate;If ancestorreturnvalue >= 0 and (ib_updatecwsrfbegin or ib_updatecwsrfend) Then
	of_updateCWSRF()
End If

Return ancestorreturnvalue
end event

