forward
global type u_tabpg_profess_contracts from u_tabpg_dbaccess
end type
type dw_2 from u_dw within u_tabpg_profess_contracts
end type
type shl_1 from statichyperlink within u_tabpg_profess_contracts
end type
type dw_mwbe from u_dw_review_history within u_tabpg_profess_contracts
end type
type cb_mwbe from commandbutton within u_tabpg_profess_contracts
end type
end forward

global type u_tabpg_profess_contracts from u_tabpg_dbaccess
integer width = 2930
integer height = 2432
boolean hscrollbar = true
string text = "Professional Contracts"
string picturename = "CreateLibrary5!"
dw_2 dw_2
shl_1 shl_1
dw_mwbe dw_mwbe
cb_mwbe cb_mwbe
end type
global u_tabpg_profess_contracts u_tabpg_profess_contracts

type variables
long il_notify[]
end variables

forward prototypes
public function long of_insert_row (long al_row, string as_transtype)
public subroutine of_check_cost_amounts ()
public subroutine of_sync_mwbe_review_flag (long al_row)
public function integer of_add_eng_hold (long al_profcontractid)
public function integer of_isenghold (long al_id)
public function integer of_add_contract_notify (long al_id)
public function integer of_send_mwbe_notification ()
end prototypes

public function long of_insert_row (long al_row, string as_transtype);Long 	ll_row, ll_profContractID, ll_contractID, ll_mwbehold, ll_count
String	ls_contrName, ls_contrType, ls_user, ls_program
Integer li_hold, li_flag, li_allow

dw_1.AcceptText()	

//Set security for Active flag:
select program
into :ls_program
from gigp_application
where gigp_id = :gl_gigp_id;

ls_user = gnv_app.of_getuserid()

select count(*)
into :ll_count
from application_rights
where name = :ls_user
and application = 'GIGP'
and sub_group = 'PROFESS_CONTR_ACTIVE';

If ls_program = 'EPG' Then
	If ll_count > 0 Then
		li_allow = 0
	Else
		li_allow = 1
	End If
Else
	li_allow = 0
End If

	
If (as_transtype = "AMEND") Then	

	ll_profContractID = dw_1.GetItemNumber(al_row, "profess_contract_id")	
	ll_contractID = dw_1.GetItemnumber(al_row, "contact_id")
	ls_contrType = dw_1.GetItemString(al_row, "contract_type")	
//	ll_mwbehold =  dw_1.GetItemnumber(al_row, "mwbe_review_flag")

	ll_row = dw_1.InsertRow(al_row + 1)
	
	dw_1.SetItem(ll_row, 'allow_active_access', li_allow)
	dw_1.SetItem(ll_row, "profess_contract_id", ll_profContractID)		
	dw_1.SetItem(ll_row, "contact_id", ll_contractID)	
	dw_1.SetItem(ll_row, "contract_type",ls_contrType)
	dw_1.SetItem(ll_row, "amend_flag",1)
//	dw_1.SetItem(ll_row, "mwbe_review_flag",ll_mwbehold)
	dw_1.SetItem(ll_row, 'contract_status', 'PENDING')
	
	li_hold = dw_1.GetItemNumber(al_row, 'lobby_hold_flag')
	li_flag = dw_1.GetItemNumber(al_row, 'lobby_cert_recd_flag')
	dw_1.SetItem(ll_row, 'lobby_hold_flag', li_hold)
	dw_1.SetItem(ll_row, 'lobby_cert_recd_flag', li_flag)
	
	li_hold = dw_1.GetItemNumber(al_row, 'aecert_hold_flag')
	li_flag = dw_1.GetItemNumber(al_row, 'aecert_recd_flag')
	dw_1.SetItem(ll_row, 'aecert_hold_flag', li_hold)
	dw_1.SetItem(ll_row, 'aecert_recd_flag', li_flag)
	
Else
	ll_row = dw_1.InsertRow(al_row)
	dw_1.SetItem(ll_row, 'allow_active_access', li_allow)
	dw_1.SetItem(ll_row, "amend_flag",0)
	dw_1.SetItem(ll_row, 'contract_status', 'PENDING')
	dw_1.SetItem(ll_row, 'lobby_hold_flag', 0)
	dw_1.SetItem(ll_row, 'lobby_cert_recd_flag', 0)
	dw_1.SetItem(ll_row, 'aecert_hold_flag', 0)	//All new rows set to 0 and then ItemChanged for Contract Type will handle if Engineering
	dw_1.SetItem(ll_row, 'aecert_recd_flag', 0)
	dw_1.SetItem(ll_row, 'program', ls_program)
	
End If

dw_1.ScrollToRow(ll_row)	

Return ll_row


end function

public subroutine of_check_cost_amounts ();
Long		ll_found, ll_contrCnt, N
String 	ls_contrType, ls_holdType, ls_find
Decimal 	ld_Amount

Datastore lds_Contracts

//*************************************************************
//
//*************************************************************

ll_contrCnt = dw_1.RowCount()

If (ll_contrCnt < 1) Then Return 

lds_Contracts = CREATE Datastore

lds_Contracts.DataObject = 'd_proj_profess_contracts'

dw_1.RowsCopy(1, ll_contrCnt, Primary!, lds_Contracts, 1, Primary!)

lds_Contracts.SetSort("contract_type A")

lds_Contracts.Sort()

//lds_Contracts.Print()

ll_contrCnt = lds_Contracts.RowCount()

FOR N = 1 TO ll_contrCnt

	ls_contrType = lds_Contracts.GetItemString(N, "contract_type")

	If (N = 1) Then
		ls_holdType = ls_contrType 
	End If

	If (ls_holdType <> ls_contrType) Then		
		
		ls_find = "sub_category = '" +  ls_holdType + "'"
	
		ll_found = dw_2.Find(ls_find, 1, dw_2.RowCount())
		
		dw_2.SetItem(ll_found, "cc_contract_amt", ld_amount)
		
		ld_Amount = 0
		ls_holdType = ls_contrType
		ld_Amount = lds_Contracts.GetItemDecimal(N, "eligible_amt")
	Else
		
		ld_Amount += lds_Contracts.GetItemDecimal(N, "eligible_amt")

	End If      

NEXT

ls_find = "sub_category = '" +  ls_holdType + "'"	
ll_found = dw_2.Find(ls_find, 1, dw_2.RowCount())

dw_2.SetItem(ll_found, "cc_contract_amt", ld_amount)

Destroy lds_Contracts




end subroutine

public subroutine of_sync_mwbe_review_flag (long al_row);Long 		ll_profKID, N, ll_count, ll_compareID, ll_hx_id
Integer 	li_review, li_Code, li_amend
Decimal	ld_amt, ld_IndThreshold, ld_AggThreshold, ld_aggCheck
DateTime	ldt_date, ldt_dateThreshold
string 	ls_type, ls_user, ls_proj, ls_contract_no, ls_program
boolean	lb_inserted = false

// Are we enforcing these rules?	//
If NOT gnv_app.of_get_ImplementMWBE() Then Return

//Check the program to see if it subject to MWBE rules
If NOT gnv_app.of_subjecttomwbe() Then Return


ll_profKID 		= dw_1.GetItemNumber(al_row, "profess_contract_id")
ls_type 			= dw_1.GetItemString(al_row, 'contract_type')
ld_amt 			= dw_1.GetItemDecimal(al_row, 'contract_amt')
ldt_date 			= dw_1.GetItemDateTime(al_row, 'contract_dt')
li_review  		= dw_1.GetItemNumber(al_row, "mwbe_review_flag")
ls_contract_no	= dw_1.GetItemString(al_row, 'contract_no')
li_amend			= dw_1.GetItemNumber(al_row, 'amended_id')
ls_user			= gnv_app.of_getuserid()
ll_count			= dw_1.RowCount()

If IsNull(li_amend) Then li_amend = 0

//Get Project Number
select project_no
into :ls_proj
from gigp_application
where gigp_id = :gl_gigp_id;

//If not one of the types to be reviewed then do nothing
//If ls_type <> 'Construction' and ls_type <> 'Engineering' and ls_type <> 'Equipment' and ls_type <> 'Legal' and ls_type <> 'Miscellaneous' and ls_type <> 'Technical Force Account' Then
//	Return
//End If
Choose Case ls_type
	Case 'Construction', 'Engineering', 'Equipment / Materials', 'Legal', 'Miscellaneous', 'Administrative Consulting Svc.'
		//Continue
		
	Case Else
		Return
		
End Choose


//If already reviewed then do nothing.
If li_review = -1 Then
	Return
End If

If ls_type = 'Construction' Then
	ls_type = 'MWBECONST'
Else
	ls_type = 'MWBEOTHER'
End If

//Get Threshold values from reference table
If li_amend > 0 Then
	select convert(decimal, ref_value)
	into :ld_IndThreshold
	from gigp_reference
	where category = 'MWBEThreshold'
	and sub_category = 'IndAmend'
	and ref_code = :ls_type;
Else
	select convert(decimal, ref_value)
	into :ld_IndThreshold
	from gigp_reference
	where category = 'MWBEThreshold'
	and sub_category = 'IndOrig'
	and ref_code = :ls_type;
End If

select convert(decimal, ref_value)
into :ld_AggThreshold
from gigp_reference
where category = 'MWBEThreshold'
and sub_category = 'Aggregate'
and ref_code = :ls_type;

select convert(datetime, ref_value)
into :ldt_dateThreshold
from gigp_reference
where category = 'MWBEThreshold'
and sub_category = 'date'
and ref_code = :ls_type;


//**********************************
//Modify indvidual based on Orig / Amend
//**********************************

//Determine if this individual contract exceeds threshold. If it does, check Aggregate regardless of date
If ld_amt > ld_IndThreshold and ldt_date >= ldt_dateThreshold Then
	//Check aggregate (use datawindow instead of select sum() due to any changes)
	ld_amt = 0
	
	FOR N = 1 TO ll_count
		If dw_1.GetItemNumber(N, 'profess_contract_id') = ll_profKID Then
			ld_amt += dw_1.GetItemDecimal(N, 'contract_amt')
		End If
	NEXT

	If ld_amt > ld_AggThreshold Then
		dw_1.Setitem(al_row, 'mwbe_review_flag', 1)
		
		//NOTIFY
		this.of_add_contract_notify(dw_1.GetItemNumber(al_row, 'profess_contract_id'))
		
		/*INSERT MWBE HISTORY RECORD*/
		If NOT lb_inserted Then
			ll_hx_id = f_getmwbetokenvalue("reviewHist_id", 1)
			
			insert into mwbe_review_history_master(history_id, mwbe_id, mwbe_action, mwbe_reason, mwbe_reason_text, mwbe_comment, source_app, action_app, last_updated_by, last_updated_dt, contract_id)
			values (:ll_hx_id, null, "Don't Disburse", 'RvwThresholdMet', 'MWBE Review Threshold Met', null, 'GIGP', 'GIGP', :ls_user, getdate(), :ll_profKID);
			
			insert into mwbe_review_history_details (history_id, mwbe_id, contract_id, line_item_id, line_item_label, project_no, gigp_id, contract_dt, contract_amt)
			values (:ll_hx_id, null, :ll_profKID, :li_amend, :ls_contract_no, :ls_proj, :gl_gigp_id, :ldt_date, :ld_amt);
			
			lb_inserted = True
		End If
	End If
	
End If

//Get total for contract
ld_amt = 0

FOR N = 1 TO ll_count
	If dw_1.GetItemNumber(N, 'profess_contract_id') = ll_profKID Then
		//If any one contract/amendment has been reviewed, then do not evaluate the aggregate
		If dw_1.GetItemNumber(N, 'mwbe_review_flag') = -1 Then
			ld_amt = -1 
			EXIT
		End If
		
		//If the Original Contract (amended_id = 0) is less than the date threshold, then do not evaluate the aggregate
		If dw_1.GetItemNumber(N, 'amended_id') = 0 Then
			If dw_1.GetItemDateTime(N, 'contract_dt') < ldt_dateThreshold Then
				ld_amt = -1
				Exit
			End If
		End If
		
		ld_amt += dw_1.GetItemDecimal(N, 'contract_amt')
		
	End If
NEXT

//If contract was already evaluated or orig contract is less than threshold date, then do not evaluate the aggregate
If ld_amt = -1 Then Return

//Determine if the aggregate Professional Contract amount exceeds the threshold
If ld_amt > ld_AggThreshold Then
	For N = 1 to ll_count
		If dw_1.GetItemNumber(N, 'profess_contract_id') = ll_profKID Then
			dw_1.Setitem(N, 'mwbe_review_flag', 1)
			
			//NOTIFY
			this.of_add_contract_notify(dw_1.GetItemNumber(al_row, 'profess_contract_id'))
			
			
			/*INSERT MWBE HISTORY RECORD*/
			If NOT lb_inserted Then
				ll_hx_id = f_getmwbetokenvalue("reviewHist_id", 1)
				
				insert into mwbe_review_history_master(history_id, mwbe_id, mwbe_action, mwbe_reason, mwbe_reason_text, mwbe_comment, source_app, action_app, last_updated_by, last_updated_dt, contract_id)
				values (:ll_hx_id, null, "Don't Disburse", 'RvwThresholdMet', 'MWBE Review Threshold Met', null, 'GIGP', 'GIGP', :ls_user, getdate(), :ll_profKID);
				
				insert into mwbe_review_history_details (history_id, mwbe_id, contract_id, line_item_id, line_item_label, project_no, gigp_id, contract_dt, contract_amt)
				values (:ll_hx_id, null, :ll_profKID, :li_amend, :ls_contract_no, :ls_proj, :gl_gigp_id, :ldt_date, :ld_amt);
				
				lb_inserted = True
			End If
			
		End If
	Next
End If
end subroutine

public function integer of_add_eng_hold (long al_profcontractid);string ls_user

If al_profcontractid > 0 Then
	ls_user = gnv_app.of_getuserid()
	
	//Insert engineering hold criteria
	insert into gigp_contract_eng_hold (profess_contract_id, eng_hold_type, placed_dt, released_dt, comments, last_updated_dt, last_updated_by)
	select :al_profContractID, ref_code, getdate(), null, null, getdate(), :ls_user
	from gigp_reference
	where category = 'EngineeringHoldType';
	
End If

Return 1
end function

public function integer of_isenghold (long al_id);long ll_count
integer li_rc

li_rc = 0

If al_id > 0 Then
	
	select count(*)
	into :ll_count
	from Contract c, ContractHold h
	where c.ContractId = h.ContractId
	and c.LegacyGigpContractId = :al_id
	and (h.released is null or h.released > getdate());
	
	If ll_count > 0 Then li_rc = 1
	
End If

Return li_rc
end function

public function integer of_add_contract_notify (long al_id);long ll_count, ll_index

If al_id > 0 Then
	ll_count = Upperbound(il_notify)
	
	If ll_count > 0 Then
		//Check if aleady in the array
		For ll_index = 1 to ll_count
			If al_id = il_notify[ll_index] Then Return 0
		Next
	End If
	
	//Doesn't already exist so add it
	il_notify[ll_count + 1] = al_id
	
End If

Return 1
end function

public function integer of_send_mwbe_notification ();long ll_count, ll_index, ll_MwbeId, ll_empty[], ll_project
string ls_message, ls_Project_No, ls_Email, ls_Rep, ls_mwbehead
n_cst_gwsend lu_Mail

//See if there are any contracts to send notifcations
ll_count = Upperbound(il_notify)

If ll_count > 0 Then
	//Loop through all contracts that were set to send notifications to
	For ll_index = 1 to ll_count
		//Get Project Number
		select project_no
		into :ls_Project_No
		from gigp_application
		where gigp_id = :gl_gigp_id;
		
		If ls_Project_No > '' Then
		
			// Send email
			ls_Message = "MWBE Hold placed on GIGP contract for GIGP Id: " + String(gl_gigp_id) + ',  Project No: ' + ls_Project_No
			
		
			ll_MwbeId = 0
			select mwbe_id
			into :ll_MwbeId
			from mwbe_main
			where gigp_contract_id 	= :il_notify[ll_index];
			
			if ll_MwbeId > 0 then
				ls_Message += ", MWBE ID: " + string(ll_MwbeId) 
			end if
				
//Don't use as per Greg and Mike			
//			select mwbe_rep
//			into	:ls_Rep
//			from	mwbe_missing_docs
//			where	project_no = :ls_Project_No;

			select ProjectId
			into :ll_project
			from Project
			where ProjectNumber = :ls_Project_No;
			
			If ll_project > 0 Then
				select max(c.LastName)
				into :ls_Rep
				from Contact c,
						ContactLink cl
				where cl.EntityName    = 'Project' and
						cl.EntityKey        = :ll_project and
						cl.ContactType  = 'MWBE Representative' and
						c.ContactId         = cl.ContactId;
	
				
				if ls_Rep <> "" then
					// Convert know bad names into good.
					choose case ls_Rep
					case "560487205150"
						// Ignore
						ls_Rep = ""
					case "Carla M. Leubner"
						ls_Rep = "Leubner"
					case "Carly Glassbrenner"
						ls_Rep = "Glassbrenner"
					case "Cheryle Webber, PE."
						ls_Rep = "Webber"
					case "Donna Armstrong"
						ls_Rep = "Armstrong"
					case "Kai Earle"
						ls_Rep = "Earle"
					case "Elaine M. Martin"
						ls_Rep = "Martin"
					case "Gabriella Garcia"
						ls_Rep = "Garcia"
					case "Jonathan Hernandez"
						ls_Rep = "Hernandez"
					case "Lianne Weisheit"
						ls_Rep = "Weisheit"
					case "Lisa McCullough"
						ls_Rep = "McCullough"
					case "M. Casserly"
						ls_Rep = "Casserly"
					case "Monica Moss"
						ls_Rep = "Moss"
					case "Tamara Hack"
						ls_Rep = "Hack"
					case "Thomas E. Christian"
						ls_Rep = "Christian"
					case "Lydia Lake"
						ls_Rep = "Lake"
					case "Brenda Lee Byrne"
						ls_Rep = "Byrne"
					end choose
				
					ls_Email = ""
					select	Email
					into :ls_Email
					from EfcUser
					where LastName = :ls_Rep
					and Active	= 1;
					
				end if
				
				IF gb_Production THEN
					lu_Mail.of_Reset()
					
					select description
					into :ls_mwbehead
					from gigp_reference
					where category = 'MWBE'
					and sub_category = 'HEAD';
					
					If ls_mwbehead > '' Then
				
						lu_Mail.of_AddRecipient(ls_mwbehead)
					
						if ls_Email <> "" then
							lu_Mail.of_AddRecipient(ls_Email)
						end if
					
						lu_Mail.of_SetSubject("MWBE Hold Placed on GIGP Contract")
						lu_Mail.of_SetMessage(ls_Message)
						lu_Mail.of_SendMail()
					End If
					
				End If
				
			END IF
	
		End If

	Next
	
	//Reset notifications
	il_notify = ll_empty
	
End If


Return 1
end function

on u_tabpg_profess_contracts.create
int iCurrent
call super::create
this.dw_2=create dw_2
this.shl_1=create shl_1
this.dw_mwbe=create dw_mwbe
this.cb_mwbe=create cb_mwbe
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_2
this.Control[iCurrent+2]=this.shl_1
this.Control[iCurrent+3]=this.dw_mwbe
this.Control[iCurrent+4]=this.cb_mwbe
end on

on u_tabpg_profess_contracts.destroy
call super::destroy
destroy(this.dw_2)
destroy(this.shl_1)
destroy(this.dw_mwbe)
destroy(this.cb_mwbe)
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "professContract"}


end event

event ue_tab_selected;call super::ue_tab_selected;
//******************************************************
// Limit Menu Functionality:
//******************************************************

m_gigp_master	lm_Menu

lm_Menu = it_Parent.iw_Parent.MenuID

//******************************************************
// Customize Menu:
//******************************************************

lm_Menu.m_edit.m_insertrow.Visible = True
lm_Menu.m_edit.m_insertrow.ToolBarItemVisible = True

lm_Menu.m_edit.m_deleterow.Visible = True
lm_Menu.m_edit.m_deleterow.ToolBarItemVisible = True

lm_Menu.m_file.m_print.Visible = True
lm_Menu.m_file.m_print.ToolBarItemVisible = True

//******************************************************
// Check Security:
//******************************************************

If (ib_editAccess = True) Then	
	lm_Menu.m_edit.m_insertrow.Enabled = True	
	lm_Menu.m_edit.m_deleterow.Enabled = True	
Else
	lm_Menu.m_edit.m_insertrow.Enabled = False	
	lm_Menu.m_edit.m_deleterow.Enabled = False
End If

//******************************************************
// Order the Sheet Toolbar:
//******************************************************

lm_Menu.m_edit.m_insertrow.ToolBarItemOrder 	= 1
lm_Menu.m_edit.m_deleterow.ToolBarItemOrder	= 2
lm_Menu.m_file.m_print.ToolBarItemOrder	 	= 3
lm_Menu.m_file.m_save.ToolBarItemOrder 		= 4
lm_Menu.m_file.m_close.ToolBarItemOrder 		= 5


//Handle Security for Engineers
If gnv_app.of_ingroup('ENGCONTRACT') and NOT gnv_app.of_ingroup("TAS-Global") and NOT gnv_app.of_ingroup("professContract") Then
	dw_1.Object.DataWindow.ReadOnly='No'
	dw_1.Modify("received_dt.Protect='" + '0~tIf(contract_type="Engineering",0,1)' + "'")
	dw_1.Modify("approval_dt.Protect='" + '0~tIf(contract_type="Engineering",0,1)' + "'")
	dw_1.Object.contract_type.Protect=1
	dw_1.Object.contact_id.Protect=1
	dw_1.Object.contract_no.Protect=1
	dw_1.Object.contract_dt.Protect=1
	dw_1.Object.contract_amt.Protect=1
	dw_1.Object.eligible_amt.Protect=1
	dw_1.Object.comments.Protect=1
	dw_1.Object.contract_status_1.Protect=1
	dw_1.Object.up_approval_dt.Protect=1
	dw_1.Object.issue_notice_award_dt.Protect=1
	dw_1.Object.issue_notice_proceed_dt.Protect=1
	dw_1.Object.b_amend.Enabled=0
End If

end event

event ue_tab_deselected;call super::ue_tab_deselected;
//******************************************************
// Customize Menu:
//******************************************************

m_gigp_master	lm_Menu

lm_Menu = it_Parent.iw_Parent.MenuID

lm_Menu.m_edit.m_insertrow.Visible = False
lm_Menu.m_edit.m_insertrow.ToolBarItemVisible = False

lm_Menu.m_edit.m_deleterow.Visible = False
lm_Menu.m_edit.m_deleterow.ToolBarItemVisible = False

lm_Menu.m_file.m_print.Visible = False
lm_Menu.m_file.m_print.ToolBarItemVisible = False
end event

event pfc_update;call super::pfc_update;//Send MWBE Notifications 
this.of_send_mwbe_notification()

Return AncestorReturnValue
end event

type dw_1 from u_tabpg_dbaccess`dw_1 within u_tabpg_profess_contracts
event ue_evaluate_lobby_hold ( long al_id )
integer x = 14
integer y = 92
integer width = 2894
integer height = 2312
string dataobject = "d_proj_profess_contracts"
end type

event dw_1::ue_evaluate_lobby_hold(long al_id);long ll_row, ll_count
string ls_type
int li_hold
decimal ld_total, ld_threshold

//We only evaluate for certain Contract types
select max(contract_type)
into :ls_type
from gigp_professional_contracts
where profess_contract_id = :al_id;

Choose Case ls_type
	Case 'Construction', 'Engineering', 'Equipment', 'Administrative Consulting Svc.', 'Legal', 'Equipment - Recipient Purchase'
		
	Case Else
		Return
		
End Choose

//Total the eligible amounts for this contract id
ld_total = 0
ll_count = this.RowCount()

For ll_row = 1 to ll_count
	If this.GetItemNumber(ll_row, 'profess_contract_id') = al_id Then
		ld_total += this.GetItemDecimal(ll_row, 'eligible_amt')
	End If
Next

//Get the threshold level to compare
select convert(decimal, ref_value)
into :ld_threshold
from gigp_reference
where category = 'LobbyThreshold';

//If the total equals or exceeds the threhold then set the hold
If ld_total >= ld_threshold Then
	li_hold = 1
Else
	li_hold = 0
End If

For ll_row = 1 to ll_count
	If this.GetItemNumber(ll_row, 'profess_contract_id') = al_id Then
		this.SetItem(ll_row, 'lobby_hold_flag', li_hold)
	End If
Next

end event

event dw_1::buttonclicked;call super::buttonclicked;String 	ls_Text, ls_noteUser, ls_appUser, ls_access
Integer	li_RC, li_hold
Long		ll_profess_contract_id

Choose Case dwo.Name
	Case 'b_edit'
		ls_access = "READ"
		dw_1.AcceptText()	
		ls_Text     = This.GetItemString(row, "comments")
		If (ib_editAccess = True) Then ls_access = "EDIT"	
		li_RC = f_edit_notes(ls_access, ls_Text)
		If (li_RC = 1) Then This.SetItem(row, "comments", ls_Text)	
		
	Case 'b_amend'
		of_insert_row(row, "AMEND")
		Return
		
	Case 'b_eng_hold'
		ll_profess_contract_id = this.GetItemNumber(row, 'profess_contract_id')
		
		If ll_profess_contract_id > 0 Then
			OpenWithParm(w_eng_hold_conditions, ll_profess_contract_id)
			
			li_hold = f_get_eng_hold(ll_profess_contract_id)
			this.SetItem(row, 'eng_hold', li_hold)
			this.SetItemStatus(row, 'eng_hold', Primary!, NotModified!)
			
		Else
			MessageBox('Engineering Hold', 'Please [SAVE] the new Contract before adding Engineering Hold conditions.')
		End If
		
				
End Choose


end event

event dw_1::sqlpreview;call super::sqlpreview;

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	f_transactionlog("gigp_id", gl_gigp_id, This.DataObject, "Profess. Agreements", sqlsyntax)
END IF
end event

event dw_1::pfc_insertrow;
//OverRide//

Return of_insert_row(0, "NEW")
end event

event dw_1::constructor;call super::constructor;
This.ib_RMBMenu = False

//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)



end event

event dw_1::pfc_updateprep;call super::pfc_updateprep;Long 				ll_row, ll_gigpID, ll_professContractID, ll_contactID, ll_amendID, ll_token, ll_find, ll_count, ll_del
Integer			N, li_rowCnt
DateTime		ldt_last, ldt_value
String 			ls_user, ls_value
dwItemStatus	l_status
Decimal			ld_diff, ld_value, ld_value2, ld_grant, ld_total, ld_disbursed

ls_user 	= 	gnv_app.of_getuserid()
ldt_last 	=   f_getdbdatetime()

//*******************************************************
// Loop thru modified rows:
//*******************************************************
ll_count = this.RowCount()

ll_row	= dw_1.GetNextModified(0, Primary!)

DO WHILE ll_row > 0
	
	//********************************
	// Check Total Contract Amount against Disbursed Amount (11/2012):
	//********************************	
	ld_total = 0
	ld_total = this.GetItemDecimal(ll_row, 'eligible_amt')
	ll_professContractID = this.GetItemDecimal(ll_row, 'profess_contract_id')
	
	this.Event ue_evaluate_lobby_hold(ll_professContractID)

	ll_find = this.Find('profess_contract_id = ' + String(ll_professContractID), 0, ll_count)
	
	Do While ll_find > 0
		If ll_find <> ll_row Then
			ld_total += this.GetItemDecimal(ll_find, 'eligible_amt')
		End If
		
		If ll_find <> ll_count Then
			ll_find = this.Find('profess_contract_id = ' + String(ll_professContractID), ll_find + 1, ll_count)
		Else 
			Exit
		End If
		
	Loop
	
	ld_disbursed = f_get_disbursed_amt(ll_professContractID)
	
	If ld_total < ld_disbursed Then
		ll_contactID = this.GetItemNumber(ll_row, 'contact_id')
		
		If ll_contactID > 0 Then
			Select organization
			into :ls_value
			from gigp_contacts
			where contact_id = :ll_contactID;
		End If
		
		If IsNull(ls_value) or ls_value = '' Then
			ls_value = '[Unknown]'
		End If
		
		MessageBox('Error!', 'A Professional Contract for ' + ls_value + ' has been modified to a total amount less than what has already been disbursed.')
		Return -1
	End If
	
	
	
	//********************************
	// Must have a Contractor:
	//********************************	
	
	ll_contactID = This.GetItemNumber(ll_row, "contact_id")	
	
	If (IsNull(ll_contactID) Or (ll_contactID = 0)) Then
		Messagebox("ERROR!", "You must enter a Contract Name!")
		Return -1
	End If
		
	//********************************
	// Must have a Contract Type:
	//********************************	
		
	ls_value = This.GetItemString(ll_row, "contract_type")	
		
	If (IsNull(ls_value) Or Trim(ls_value) = "")Then
		Messagebox("ERROR!", "You must enter a Contract Type!")
		Return -1
	End If
				
	//********************************
	// Must have a Contract Date:
	//********************************	
		
	ldt_value = This.GetItemDateTime(ll_row, "contract_dt")		
		
	If (IsNull(ldt_value)) Then
		Messagebox("ERROR!", "You must enter a Contract Date!")
		Return -1
	End If	
	
	//********************************************
	// 1. Contract Amount cannot be 0
	// 2. Eligible Amount cannot be 0 (Removed 3/5/2010, mpf)
	// 3. Eligible Amount must be <= Contract Amount (Removed 07/13/2010 mpf)
	//********************************************
	
	ld_value =  0
	ld_value2 =  0
	
	ld_value = This.GetItemDecimal(ll_row, "contract_amt")
	ld_value2 = This.GetItemDecimal(ll_row, "eligible_amt")
	

	
	//********************************
	// Enter Key Values for new rows:
	//********************************	
	
	l_status =    dw_1.GetItemStatus( ll_row, 0, Primary!)
	ll_amendID = dw_1.GetItemNumber(ll_row, "amend_flag")	
	
	If (l_status = New! Or l_status = NewModified!) Then
		
		dw_1.SetItem(ll_row,  "gigp_id", gl_gigp_id)
		
		If (ll_amendID = 0) Then
			ll_professContractID = f_gettokenvalue("professContractID", 1)
			dw_1.SetItem(ll_row, "profess_contract_id", ll_professContractID)
			
			//Add Eng Hold criteria if Construction **5/2022 SW, ONLY if program is subject to MWBE
			If dw_1.GetItemString(ll_row, 'contract_type') = 'Construction' Then
				If gnv_app.of_subjecttomwbe() Then
					of_add_eng_hold(ll_professContractID)
					dw_1.SetItem(ll_row, 'eng_hold', 1)
				End If
			End If
			
		Else		
			dw_1.SetItem(ll_row, "amended_id", f_gettokenvalue("amendContractID", 1))	
			
		End If
		
	End If
		
	dw_1.SetItem(ll_row, "last_updated_dt",  ldt_last)	
	dw_1.SetItem(ll_row, "last_updated_by", ls_user) 	
	
	//Sync MWBE Review Flag
	parent.of_sync_mwbe_review_flag(ll_row)
	
	ll_row = dw_1.GetNextModified(ll_row, Primary!)

LOOP

//********************************
// Check Deleted rows to make sure enough left to cover disbursed amounts (11/2012)
//********************************	
ll_del = this.DeletedCount()

If ll_del > 0 Then
	
	For ll_row = 1 to ll_del
		ll_professContractID = this.GetItemDecimal(ll_row, 'profess_contract_id', Delete!, True)
		
		ll_find = this.Find('profess_contract_id = ' + String(ll_professContractID), 0, ll_count)
		
		If ll_find > 0 Then		//Exists, then make sure enough left to cover any disbursed amounts
			ld_total = 0
			ld_total = this.GetItemDecimal(ll_find, 'eligible_amt')
		
			ll_find = this.Find('profess_contract_id = ' + String(ll_professContractID), ll_find + 1, ll_count)
			
			Do While ll_find > 0
				ld_total += this.GetItemDecimal(ll_find, 'eligible_amt')
				
				If ll_find <> ll_count Then
					ll_find = this.Find('profess_contract_id = ' + String(ll_professContractID), ll_find + 1, ll_count)
				Else 
					Exit
				End If
				
			Loop
			
			ld_disbursed = f_get_disbursed_amt(ll_professContractID)
			
			If ld_total < ld_disbursed Then
				ll_contactID = this.GetItemNumber(ll_row, 'contact_id', Delete!, True)
				
				If ll_contactID > 0 Then
					Select organization
					into :ls_value
					from gigp_contacts
					where contact_id = :ll_contactID;
				End If
				
				If IsNull(ls_value) or ls_value = '' Then
					ls_value = '[Unknown]'
				End If
				
				MessageBox('Error!', 'A Professional Contract for ' + ls_value + ' has been deleted which does not leave enough money to cover the amount already disbursed on that contract.')
				Return -1
			End If
			
		Else	//None left for this contract so see if ANY disbursements made
			ld_disbursed = f_get_disbursed_amt(ll_professContractID)
			
			If ld_disbursed > 0 Then
				ll_contactID = this.GetItemNumber(ll_row, 'contact_id', Delete!, True)
				
				If ll_contactID > 0 Then
					Select organization
					into :ls_value
					from gigp_contacts
					where contact_id = :ll_contactID;
				End If
				
				If IsNull(ls_value) or ls_value = '' Then
					ls_value = '[Unknown]'
				End If
				
				MessageBox('Error!', 'A Professional Contract for ' + ls_value + ' has been deleted and Disbursements exist for that contract.')
				Return -1
				
			End If
			
		End If
		
		delete gigp_contract_eng_hold
		where profess_contract_id = :ll_professContractID;
		
	Next
	
End If


Return AncestorReturnValue

end event

event dw_1::pfc_retrieve;call super::pfc_retrieve;Long ll_rows, ll_row, ll_count, ll_pc
Integer li_allow, li_engcontracthold
string ls_user, ls_program
DataWindowChild ldwc

//Set security for Active flag:
select program
into :ls_program
from gigp_application
where gigp_id = :gl_gigp_id;

ls_user = gnv_app.of_getuserid()

select count(*)
into :ll_count
from application_rights
where name = :ls_user
and application = 'GIGP'
and sub_group = 'PROFESS_CONTR_ACTIVE';

If ls_program = 'EPG' Then
	If ll_count > 0 Then
		li_allow = 0
	Else
		li_allow = 1
	End If
Else
	li_allow = 0
End If

ll_count = this.RowCount()

If ll_count > 0 Then
	For ll_row = 1 to ll_count
		ll_pc = this.GetItemNumber(ll_row, 'profess_contract_id')
		
		this.SetItem(ll_row, 'engcontracts_hold', parent.of_isenghold(ll_pc))
		
		this.SetItem(ll_row, 'allow_active_access', li_allow)
		this.SetItem(ll_row, 'eng_hold', f_get_eng_hold(this.GetItemNumber(ll_row, 'profess_contract_id')))
		this.SetItemStatus(ll_row, 'allow_active_access', Primary!, NotModified!)
		this.SetItemStatus(ll_row, 'eng_hold', Primary!, NotModified!)
		this.SetItemStatus(ll_row, 0, Primary!, NotModified!)	
	Next
End If

//*************************************************************
// Populate the Contractor DDDW:
//*************************************************************
This.GetChild('contact_id', ldwc)
ldwc.SetTransObject(SQLCA)
ll_rows = ldwc.Retrieve(gl_gigp_id)

//*************************************************************
// :
//*************************************************************
dw_2.Event pfc_retrieve()
of_check_cost_amounts()


Return AncestorReturnValue

end event

event dw_1::retrieveend;call super::retrieveend;long ll_empty[]


//Reset notifications
il_notify = ll_empty
end event

event dw_1::pfc_predeleterow;call super::pfc_predeleterow;
Long 		ll_profContractID, ll_amendFlag, ll_found, ll_count
String		ls_find

ll_profContractID	= This.GetItemNumber(This.GetRow(), "profess_contract_id")
ll_amendFlag 		= This.GetItemNumber(This.GetRow(), "amend_flag")

//*************************************************************
// Prevent deletion if an affiliated Disbursements exists:  ***RULE REMOVED 11/2012 because Update Prep rule for total contract amount added
//*************************************************************

//SELECT Count(disbursement_amt_id)
//INTO		:ll_count
//FROM 	gigp_disbursement_amount  
//WHERE 	professional_contract_id = :ll_profContractID;
//
//If (ll_count > 0) Then
//	MessageBox("ERROR!", "Cannot delete this Contract if an affiliated Disbursements exists!")		
//	Return 0
//End If

//*************************************************************
// Prevent deletion of an Orig. Contract if an affiliated Amendment exists:
//*************************************************************

If (ll_amendFlag = 0) Then
	
	ls_find = "profess_contract_id = " + String(ll_profContractID) + " and amend_flag = 1" 	

	ll_found = This.Find(ls_find,  1, This.RowCount())

	If (ll_found > 0) Then		
		MessageBox("ERROR!", "Cannot delete an Original Contract if an affiliated Amendment exists!")		
		Return 0
	End If
		
End If

Return 1
end event

event dw_1::itemchanged;call super::itemchanged;integer li_flag, li_round
long ll_row, ll_count, ll_id
string ls_program

Decimal ld_value

This.AcceptText()

If (dwo.Name = 'contract_amt') Then
	ld_value = This.GetItemDecimal(row, 'contract_amt')
	This.SetItem(row, 'eligible_amt', ld_value)
//	Post of_sync_mwbe_review_flag(row)  //moved to updateprep
End If

//If Lobby Cert Recd checkbox filled in, add to any amendments
If dwo.name = 'lobby_cert_recd_flag' Then
	ll_count = this.RowCount()
	li_flag = Integer(data)
	ll_id = this.GetItemNumber(row, 'profess_contract_id')
	
	For ll_row = 1 to ll_count
		If ll_row <> row Then
			If this.GetItemNumber(ll_row, 'profess_contract_id') = ll_id Then
				this.SetItem(ll_row, 'lobby_cert_recd_flag', li_flag)
			End If
		End If
	Next
End If

//If Lobby Cert Recd checkbox filled in, add to any amendments
If dwo.name = 'aecert_recd_flag' Then
	ll_count = this.RowCount()
	li_flag = Integer(data)
	ll_id = this.GetItemNumber(row, 'profess_contract_id')
	
	For ll_row = 1 to ll_count
		If ll_row <> row Then
			If this.GetItemNumber(ll_row, 'profess_contract_id') = ll_id Then
				this.SetItem(ll_row, 'aecert_recd_flag', li_flag)
			End If
		End If
	Next
End If

//If Contract Type set to Engineering and Program is GIGP, R12 forward then set the A&E Hold Flag to 1
If dwo.name = 'contract_type' Then
	If data = 'Engineering' Then
		select round_no, program
		into :li_round, :ls_program
		from gigp_application
		where gigp_id = :gl_gigp_id;
		
		If ls_program = 'GIGP' and li_round >= 12 Then
			this.SetItem(row, 'aecert_hold_flag', 1)
		End If
		
	Else
		this.SetItem(row, 'aecert_hold_flag', 0)
			
	End If
End If

end event

type dw_2 from u_dw within u_tabpg_profess_contracts
boolean visible = false
integer x = 9
integer y = 168
integer width = 2633
integer height = 1632
integer taborder = 11
boolean bringtotop = true
boolean titlebar = true
string title = "Approved Budget Summary"
string dataobject = "d_proj_budget_approvals"
boolean controlmenu = true
boolean vscrollbar = false
string icon = "AppIcon!"
boolean livescroll = false
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

ib_IsUpdateable = False

This.ib_RMBMenu = False

dw_2.X = dw_1.X	

This.Object.DataWindow.ReadOnly="Yes"
end event

event pfc_retrieve;call super::pfc_retrieve;
Long N, ll_rows
Integer li_sort
String ls_value

ll_rows = dw_2.Retrieve(gl_gigp_id)

FOR N = 1 TO ll_rows

		SetNull(ls_value)
		
      	ls_value = This.GetItemString(N, "sub_category")
		
		Select Min(sort_order)
		Into :li_sort
		From gigp_reference
		Where category = 'budgetAmount'
		And sub_category = :ls_value;
		
		This.SetItem(N, "cc_sort", li_sort)		

NEXT

This.Sort()

Return ll_rows
end event

event pfc_insertrow;
//OverRide//

Return dw_1.Event pfc_insertrow()
end event

event pfc_deleterow;
//OverRide//

Return dw_1.Event pfc_deleterow()
end event

type shl_1 from statichyperlink within u_tabpg_profess_contracts
integer x = 32
integer y = 16
integer width = 905
integer height = 56
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 32768
long backcolor = 67108864
string text = "View Approved Budget Summary"
boolean focusrectangle = false
end type

event clicked;

If (dw_2.Visible = False) Then
	dw_2.X = dw_1.X	
	dw_2.Visible = True
end If
end event

type dw_mwbe from u_dw_review_history within u_tabpg_profess_contracts
boolean visible = false
integer x = 87
integer y = 416
integer taborder = 11
boolean bringtotop = true
string title = "MWBW Review History"
boolean hscrollbar = true
end type

type cb_mwbe from commandbutton within u_tabpg_profess_contracts
integer x = 965
integer y = 12
integer width = 311
integer height = 68
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "MWBE"
end type

event clicked;long ll_contract

If dw_1.RowCount() > 0 Then
	ll_contract = dw_1.GetItemNumber(dw_1.GetRow(), 'profess_contract_id')
	
	If ll_contract > 0 Then
		dw_mwbe.Retrieve(ll_contract, 'GIGP')
		dw_mwbe.Visible = True
	End If
End If


end event

