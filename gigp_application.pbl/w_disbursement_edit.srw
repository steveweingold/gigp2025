forward
global type w_disbursement_edit from w_gigp_response
end type
type cb_adj from commandbutton within w_disbursement_edit
end type
type shl_1 from statichyperlink within w_disbursement_edit
end type
type cb_integrity from commandbutton within w_disbursement_edit
end type
type st_locked from statictext within w_disbursement_edit
end type
type pb_insert from picturebutton within w_disbursement_edit
end type
type pb_delete from picturebutton within w_disbursement_edit
end type
type dw_netavail from u_dw within w_disbursement_edit
end type
type dw_pendingadj from u_dw within w_disbursement_edit
end type
type dw_master from u_dw within w_disbursement_edit
end type
type dw_detail from u_dw within w_disbursement_edit
end type
type cb_unlock from commandbutton within w_disbursement_edit
end type
type pb_calculator from picturebutton within w_disbursement_edit
end type
end forward

global type w_disbursement_edit from w_gigp_response
integer x = 214
integer y = 221
integer width = 4443
integer height = 2444
boolean titlebar = false
boolean controlmenu = false
cb_adj cb_adj
shl_1 shl_1
cb_integrity cb_integrity
st_locked st_locked
pb_insert pb_insert
pb_delete pb_delete
dw_netavail dw_netavail
dw_pendingadj dw_pendingadj
dw_master dw_master
dw_detail dw_detail
cb_unlock cb_unlock
pb_calculator pb_calculator
end type
global w_disbursement_edit w_disbursement_edit

type variables

Long il_disbursementID, il_gigpID

Decimal id_eligiblePct, id_retainagePct, id_costsharePct
end variables

forward prototypes
public subroutine of_set_last_updated (long al_row)
public subroutine of_calc_lineitem (long al_row)
public subroutine of_get_disbursement_pcts ()
public function integer of_integrity_check ()
public subroutine of_get_adjustments ()
public subroutine of_create_wiretransfermemo ()
public subroutine of_set_cost_category (long al_row)
public subroutine of_checkfor_mwbe_hold (long al_row)
public subroutine of_display_text (long al_row)
public function integer of_checknetrequested ()
public function integer of_calc_retainage_release (long al_row)
public function integer of_checkdisbursedamount ()
end prototypes

public subroutine of_set_last_updated (long al_row);
String ls_user
DateTime ls_now

ls_user = gnv_app.of_getuserid()

ls_now = f_getdbdatetime()

If (al_row > 0) Then
	dw_detail.SetItem(al_row, "last_updated_by", ls_user)
	dw_detail.SetItem(al_row, "last_updated_dt",  ls_now)	
End If

//*******************************************************
// Set the Last Updated by info:
//*******************************************************

dw_master.SetItem(dw_master.GetRow(), "last_updated_by", ls_user)
dw_master.SetItem(dw_master.GetRow(), "last_updated_dt",  ls_now)
end subroutine

public subroutine of_calc_lineitem (long al_row);//*************************************************************
// 	Requested Amount - Ineligible +/- Adjusted Amount  = Net Requested
//  Net Requested X .90 = Eligible Amount
//  Eligible Amount X .05 = Retainage
//  Eligible Amount - Retainage = Disbursed Amount
//*************************************************************
Decimal{2} ld_requested, ld_withheld, ld_netRequest, ld_ineligible, ld_eligible, ld_retainage, ld_disbursed, ld_netAvail, ld_diff, ld_percent
String ls_value, ls_program
Integer li_round, li_request

dw_detail.AcceptText()

ls_value 			= dw_detail.GetItemString(al_row, 'transaction_type')
ld_requested 	= dw_detail.GetItemDecimal(al_row, 'requested_amt')
li_request		= dw_master.GetItemNumber(dw_master.GetRow(), 'request_no')

select program
into :ls_program
from gigp_application
where gigp_id = :gl_gigp_id;

//If li_round >= 100 and li_request = 1 Then
If ls_program = 'GIGP' or ls_program =  'REDI' Then
	ld_percent = id_eligiblePct
Else
	ld_percent = 1
End If

CHOOSE CASE ls_value

CASE "RELRET" // Retainage Release
	
	this.Post of_calc_retainage_release(al_row)
	
	Return
	
	
CASE "DISBURSE",  "ADJUST" // Disbursement
	
	ld_withheld 		= dw_detail.GetItemDecimal(al_row, 'withheld_amt')
	ld_ineligible 		= dw_detail.GetItemDecimal(al_row, 'ineligible_amt')
	ld_netRequest = (ld_requested  - ld_ineligible - ld_withheld)
	
	If ld_requested > 0 Then
		ld_eligible 	= (ld_netRequest * ld_percent)	
		ld_retainage = (ld_eligible * id_retainagePct)
		ld_disbursed = (ld_eligible - ld_retainage)	
	Else
		ld_eligible 	= ld_netRequest
		ld_retainage = 0
		ld_disbursed = ld_eligible
	End If


CASE "DOCONLY" //Documetation Only Transaction
	
	ld_withheld 		= 0
	ld_ineligible 		= 0
	ld_eligible 		= 0	
	ld_retainage 	= 0
//	ld_netRequest 	= ld_requested
	ld_netRequest 	= 0	//SW, 11/17/2010 as per Angela
	ld_disbursed 	= 0

	dw_detail.SetItem(al_row, 'withheld_amt', ld_withheld)
	dw_detail.SetItem(al_row, 'ineligible_amt', ld_ineligible)
		
END CHOOSE

dw_detail.SetItem(al_row, "netrequest_amt", ld_netRequest)
//dw_detail.SetItem(al_row, 'withheld_amt', ld_withheld)
//dw_detail.SetItem(al_row, 'ineligible_amt', ld_ineligible)
dw_detail.SetItem(al_row, "eligible_amt", ld_eligible)
dw_detail.SetItem(al_row, "retained_amt", ld_retainage)
dw_detail.SetItem(al_row, "disbursed_amt", ld_disbursed)

//Post of_integrity_check()


end subroutine

public subroutine of_get_disbursement_pcts ();String ls_value, ls_type, ls_round
Integer li_round


//*************************************************************
// Eligible Percent:
//*************************************************************

//Select ref_value 
//Into :ls_value
//From gigp_reference
//Where category = "Disbursement"
//And sub_category = "disbursePercent"
//And  ref_code = "eligible%";

select grant_type, round_no
into :ls_type, :li_round
from gigp_application
where gigp_id = :il_gigpID;

ls_round = String(li_round)

//USING PROJECT ELIGIBLE PCT, 11/2021
//Select ref_value 
//Into :ls_value
//From gigp_reference
//Where category = "disbursePercent"
//And sub_category = :ls_type
//And  ref_code = :ls_round;

//If IsNull(ls_value) or ls_value = '' Then
//	MessageBox(this.Title, 'Eligible Percent for this round has not been not yet added to the system. Please contact IT.')
//	id_eligiblePct = 0
//End If

//id_eligiblePct = (Integer(ls_value) / 100)

//Get the eligible percent from the project detail, 11/2021 SW
select eligible_pct / 100
into :id_eligiblePct
from gigp_application
where gigp_id = :il_gigpid;

//Get the Cost Share Percent
select cost_share_pct / 100
into :id_costsharePct
from gigp_application
where gigp_id = :il_gigpid;

If IsNull(id_costsharePct) Then id_costsharePct = 1


//*************************************************************
// Retainage Percent:
//*************************************************************
Select ref_value 
Into :ls_value
From gigp_reference
Where category = "retainPercent"
And  ref_code = :ls_round;

id_retainagePct = (Integer(ls_value) / 100)







end subroutine

public function integer of_integrity_check ();long 				ll_row, ll_count, ll_professContractID, ll_find, ll_disburseAmtID, ll_ret
String				ls_transType, ls_find, ls_contract, ls_pct, ls_program, ls_warning, ls_ProgramWarning
Decimal 			ld_eligible, ld_retainage, ld_eligibleORIG, ld_retainageORIG, ld_retNetAvail, ld_disNetAvail, ld_awardNetAvail, ld_eligSum, ld_disbursed, ld_previous_total, ld_total_grant_amt
Decimal			ld_released, ld_disbursedsum, ld_pct
dwItemStatus	l_status
DWBuffer         l_dwBuffer
Integer			li_RC, li_mwbeHold_flag

li_RC = 1

dw_detail.AcceptText()

//*************************************************************
// Check Released Amount vs sum of disbursed amounts (SW, 6/2020)
//*************************************************************
ld_released = dw_master.GetItemDecimal(dw_master.GetRow(), 'release_amt')

If ld_released > 0 Then

	ll_count = dw_detail.RowCount()
	
	ld_disbursedsum = 0
	If ll_count > 0 Then
		For ll_row = 1 to ll_count
			ld_disbursed = dw_detail.GetItemDecimal(ll_row, 'disbursed_amt')
	
			If NOT IsNull(ld_disbursed) Then
				ld_disbursedsum += ld_disbursed
			End If
			
		Next
	End If
	
	If NOT IsNull(ld_released) Then
		If ld_released <> ld_disbursedsum Then
			MessageBox('Released Amount', 'The Released Amount does not equal the sum of the Disbursed Amounts. Please fix.')
			li_rc = -1
			Goto Finishup
		End If
	End If
	
End If


//Determine if this Disbursement Request makes total disbursements exceed the defined percent for warning, by program
//Determine the program
select program
into :ls_program
from gigp_application
where gigp_id = :gl_gigp_id;

If ls_program > '' Then
	ls_pct = ''
	
	//Get the percent for that program
	select ref_value, description
	into :ls_pct, :ls_ProgramWarning
	from gigp_reference
	where category = 'DrawPercentWarning'
	and sub_category = :ls_program;
	
	If ls_pct > '' Then
		If IsNumber(ls_pct) Then
			ld_pct = Dec(ls_pct)
			
			If ld_pct > 0 Then
				//Get total grant amount
				ld_total_grant_amt = f_get_project_amount(gl_gigp_id, 'RECFR')
				
				If ld_total_grant_amt > 0 Then
				
					//Get new total disbursement amount with current request
					select sum(disbursed_amt)
					into :ld_previous_total
					from gigp_disbursement_amount
					where gigp_id = :gl_gigp_id
					and disbursement_id <> :il_disbursementID;
					
					If IsNull(ld_previous_total) Then ld_previous_total = 0
					
					//Add previous total to current total and see if over the defined percentage
					ld_previous_total += ld_disbursedsum
	
					If ld_previous_total > ld_total_grant_amt * ld_pct Then
						//WARN
						ls_warning = 'This disbursement request will put the total disbursed amount greater than ' + String(ld_pct * 100) + '% of the grant award for this project. '
						ls_warning += ls_ProgramWarning
						ls_warning += '~r~n~r~nWould you like to continue?'
						
						If MessageBox('WARNING', ls_warning, StopSign!, YesNoCancel!, 2) <> 1 Then
							li_Rc = -1
							Goto Finishup
						End If
						
					End If
					
				End If
				
			End If
			
		End If
		
	End If
	
End If



//*************************************************************
// Re-Retrieve Net Available DW:
//*************************************************************

dw_netavail.SetRedraw(False)

dw_netavail.Retrieve(il_gigpID)


//*************************************************************
// Check Net Requested Amounts:  added 8/2011 by sw  , changed to Disbursed Amount 5,2022
//*************************************************************
//ll_ret = this.of_checknetrequested()
ll_ret = this.of_checkdisbursedamount()

If ll_ret > 0 Then
	select organization
	into :ls_contract
	from gigp_contacts
	where contact_id = (select max(contact_id)
								from gigp_professional_contracts
								where profess_contract_id = :ll_ret);
	
//	 If MessageBox("ALERT!", "Total Net Requested for " + ls_contract + " exceeds the Available Contract Amount. ~r~nContinue?", Question!, YesNoCancel!) <> 1 Then
//	MessageBox("ALERT!", "Total Net Requested for " + ls_contract + " exceeds the Available Contract Amount", StopSign!)
	MessageBox("ALERT!", "Total Disbursed for " + ls_contract + " exceeds the Available Contract Amount", StopSign!)
	li_RC = -1
	Goto Finishup
End iF


//*************************************************************
// 1st Loop Thru Delete Buffer and make updates to Net Available Amounts.
//*************************************************************

l_dwBuffer = Delete!

ll_count = dw_detail.DeletedCount()

FOR ll_row = 1 TO ll_count

	ls_transType			= dw_detail.GetItemString(ll_row, "transaction_type", l_dwBuffer, False)		
	ll_professContractID 	= dw_detail.GetItemNumber(ll_row, "professional_contract_id",  l_dwBuffer, False)		
		
	If IsNull(ll_professContractID) Then		
		MessageBox("ERROR!", "Cannot find the Professional Contract for deleted disbursement, See I.T.!")
		li_RC = -1
		Goto Finishup
	End If

	//*************************************************************
	// Find the applicable Professional Contract:
	//*************************************************************
		
	ls_find = "profess_contract_id = "  + String(ll_professContractID)		
	ll_find = dw_netavail.Find(ls_find, 1, dw_netavail.RowCount())
		
	If IsNull(ll_find)  Or (ll_find < 1) Then		
			MessageBox("ERROR!", "Cannot find the Professional Contract for disbursement, See I.T.!")
			li_RC = -1
			Goto Finishup
	End If

	If (ls_transType  = "RELRET") Then // Release Retainage
			
			//*************************************************************
			// Get Net Avail. Retainage Withheld for this Contract:
			//*************************************************************
				
			ld_retNetAvail =  dw_netavail.GetItemDecimal(ll_find, "cc_retavail")
			
			//*************************************************************
			// Get current Retainage Amount and adjust Net Available:
			//*************************************************************
				
			ld_retainage = 0	
						
			ld_retainage =  dw_detail.GetItemDecimal(ll_row, "disbursed_amt", l_dwBuffer, True)		
			ld_retNetAvail = (ld_retNetAvail + ld_retainage) 
			dw_netavail.SetItem(ll_find, "cc_retavail", ld_retNetAvail)					
							
		Else //Disbursement or Adjustment
			
			//*************************************************************
			// Get Disbursed &  Net Avail. Contract Amounts for this Contract:
			//*************************************************************
			
			ld_disbursed  	=  dw_netavail.GetItemDecimal(ll_find, "cc_disbAmt")
			ld_disNetAvail 	=  dw_netavail.GetItemDecimal(ll_find, "cc_netavail")
			ld_retNetAvail 	=  dw_netavail.GetItemDecimal(ll_find, "cc_retavail")
			
			//***************************************************************************
			// Get current Eligible & Retainage Amounts and adjust Net Available Amounts
			//***************************************************************************
				
			ld_eligible		= 0
			ld_retainage 	= 0
				
			ld_eligible      =  dw_detail.GetItemDecimal(ll_row, "eligible_amt", l_dwBuffer,True)
			ld_retainage =  dw_detail.GetItemDecimal(ll_row, "retained_amt",  l_dwBuffer, True)
						
			ld_disbursed = (ld_disbursed - ld_eligible) // Back out from Total disbursed
			dw_netavail.SetItem(ll_find, "cc_disbAmt", ld_disbursed)	
				
			ld_disNetAvail = (ld_disNetAvail + ld_eligible) // Add to Net Avail for disbursement
			dw_netavail.SetItem(ll_find, "cc_netavail", ld_disNetAvail)	
								
			ld_retNetAvail = (ld_retNetAvail - ld_retainage) //Back out from Retainage Withheld
			dw_netavail.SetItem(ll_find, "cc_retavail", ld_retNetAvail)					
						
		End If
		
		dw_netavail.SetItemStatus(ll_find, 0, Primary!, NotModified!)	

NEXT

//*************************************************************
// 2nd Loop Thru Primary Buffer and make updates to Net Available Amounts.
//*************************************************************

l_dwBuffer = Primary!

ll_count = 0

ll_count = dw_detail.RowCount()

If (ll_count < 1) Then 
	li_RC = 1
	Goto Finishup
End If

//*******************************************************
// Loop Thru DW and Validate user entry:
//*******************************************************

ll_row = dw_detail.GetNextModified(0, l_dwBuffer)

DO WHILE ll_row > 0
	
	l_status = dw_detail.GetItemStatus(ll_row, 0, l_dwBuffer)
	
	ls_transType			= dw_detail.GetItemString(ll_row, "transaction_type", l_dwBuffer, False)
	ll_professContractID 	= dw_detail.GetItemNumber(ll_row, "professional_contract_id", l_dwBuffer, False)
	li_mwbeHold_flag 		= dw_detail.GetItemNumber(ll_row, "cc_mwbehold_flag", l_dwBuffer, False)
			
	If IsNull(ll_professContractID) Then		
			MessageBox("ERROR!", "Professional Contract must be selected for disbursement!")
			dw_detail.SetItem(ll_row, "cc_error_flag", 1)
			li_RC = -1
			Goto Finishup
	End If
	
	dw_detail.SetItem(ll_row, "cc_error_flag", 0)
		
	//*************************************************************
	// Find the applicable Professional Contract:
	//*************************************************************
		
	ls_find = "profess_contract_id = "  + String(ll_professContractID)		
	ll_find = dw_netavail.Find(ls_find, 1, dw_netavail.RowCount())
		
	If IsNull(ll_find)  Or (ll_find < 1) Then		
			MessageBox("ERROR!", "Cannot find the Professional Contract for disbursement, See I.T.!")
			dw_detail.SetItem(ll_row, "cc_error_flag", 1)
			li_RC = -1
			Goto Finishup
	End If
	
	dw_detail.SetItem(ll_row, "cc_error_flag", 0)
	
	//*************************************************************
	// Cannot disburse on a Professional Contract with an MWBE Hold:
	//*************************************************************
	
	ld_disbursed =  dw_detail.GetItemDecimal(ll_row, "disbursed_amt", l_dwBuffer, False )	
	
	If ((ld_disbursed > 0) And  (li_mwbeHold_flag = 1)) Then
				MessageBox("ERROR!", "Cannot disburse on a Contract with an MWBE Hold!")
				dw_detail.SetItem(ll_row, "cc_error_flag", 1)	
				li_RC = -1
				Goto Finishup	
	End If	
	
	dw_detail.SetItem(ll_row, "cc_error_flag", 0)
	ld_disbursed = 0
	
	If (ls_transType  = "RELRET") Then // Release Retainage
		
		//*************************************************************
		// Get Net Avail. Retainage Withheld for this Contract:
		//*************************************************************
			
		ld_retNetAvail =  dw_netavail.GetItemDecimal(ll_find, "cc_retavail")
		
		//*************************************************************
		// If Row modified, get orig. Retainage Amount  and adjust Net Available:
		//*************************************************************
			
		ld_retainage 		= 0	
		ld_retainageORIG 	= 0
		
		ld_retainage =  dw_detail.GetItemDecimal(ll_row, "disbursed_amt", l_dwBuffer, False )			
						
		If (l_status = DataModified!	) Then
			
			ld_retainageORIG	=  dw_detail.GetItemDecimal(ll_row, "disbursed_amt", l_dwBuffer, True )		
						
			If (ld_retainage <> ld_retainageORIG) Then
				ld_retainage = (ld_retainageORIG - ld_retainage)
			End If
			
			ld_retNetAvail = (ld_retNetAvail + ld_retainage) 				
			
		Else // New Row
			
			ld_retNetAvail = (ld_retNetAvail - ld_retainage) 
			
		End If
		
		dw_netavail.SetItem(ll_find, "cc_retavail", ld_retNetAvail)
								
		If (ld_retNetAvail < 0) Then
				MessageBox("ERROR!", "Released Retainage Amount exceeds Contract Net Available!")
				dw_detail.SetItem(ll_row, "cc_error_flag", 1)	
				li_RC = -1
				Goto Finishup	
		End If
		
	Else // Disbursement or Adjustment
		
		//*************************************************************
		// Get Disbursed &  Net Avail. Contract Amounts for this Contract:
		//*************************************************************
				
		ld_disbursed  	=  dw_netavail.GetItemDecimal(ll_find, "cc_disbAmt")		
		ld_disNetAvail  	=  dw_netavail.GetItemDecimal(ll_find, "cc_netavail", Primary!, False)	
		ld_retNetAvail  	=  dw_netavail.GetItemDecimal(ll_find, "cc_retavail", Primary!, False)
		
		//***************************************************************************
		// If Row modified, get orig. Eligible & Retainage Amounts and adjust Net Available Amounts:		
		//***************************************************************************
			
		ld_eligible			= 0		
		ld_eligibleORIG		= 0
		ld_retainage 		= 0
		ld_retainageORIG 	= 0
				
		ld_eligible      	=  dw_detail.GetItemDecimal(ll_row, "eligible_amt", l_dwBuffer, False )
		ld_retainage	=  dw_detail.GetItemDecimal(ll_row, "retained_amt",  l_dwBuffer, False )
		
		If (l_status = DataModified!	) Then			
			
			ld_eligibleORIG  	=  dw_detail.GetItemDecimal(ll_row, "eligible_amt", l_dwBuffer, True )					
			ld_retainageORIG =  dw_detail.GetItemDecimal(ll_row, "retained_amt",  l_dwBuffer, True )	
					
			// Calc Disbursement Net Available	
					
			If (ld_eligible <> ld_eligibleORIG) Then
				ld_eligible = (ld_eligibleORIG - ld_eligible)
			End If
			
			ld_disNetAvail = (ld_disNetAvail + ld_eligible) 		
						
			ld_disbursed = (ld_disbursed - ld_eligible)
						
			////////////////////////////////////////////////////////////////			
						
			// Calc Retainage  Net Available
			
			If (ld_retainage <> ld_retainageORIG) Then
				ld_retainage = (ld_retainageORIG - ld_retainage)
			End If
			
			ld_retNetAvail = (ld_retNetAvail - ld_retainage) 						
			
		Else // New Row			
			
			ld_disNetAvail	= (ld_disNetAvail - ld_eligible)
			ld_disbursed 	= (ld_disbursed + ld_eligible)
			ld_retNetAvail 	= (ld_retNetAvail + ld_retainage) 	
			
		End If
				
		//*************************************************************
		// Get New Eligible & Retainage Amounts and adjust Net Available Amounts:
		//
		// 8/3/2011: Change to Total Net Requested cannot exceed Contract Amount as per Angela / Katie
		//
		//*************************************************************		
				
		dw_netavail.SetItem(ll_find, "cc_netavail", ld_disNetAvail)
		dw_netavail.SetItem(ll_find, "cc_disbAmt", ld_disbursed)
		dw_netavail.SetItem(ll_find, "cc_retavail", ld_retNetAvail)
								
//		If (ld_disNetAvail < 0) Or (ld_retNetAvail < 0) Then
//				MessageBox("ERROR!", "Disbursement Amounts exceeds Contract Net Available!")
//				dw_detail.SetItem(ll_row, "cc_error_flag", 1)	
//				li_RC = -1
//				Goto Finishup	
//		End If
		
	End If
	
	//*************************************************************
	// Check Net Available at the Total Award Level:
	//*************************************************************	
	
	ld_awardNetAvail =  dw_netavail.GetItemDecimal(dw_netavail.RowCount(), "cf_awardnet")		
	
	If (ld_awardNetAvail < 0) Then
				MessageBox("ERROR!", "Disbursed Amount exceeds Award Net Available!")				
				li_RC = -1
				Goto Finishup	
	End If	
	
	
	//*************************************************************
	// Eligible Amt Sum cannot be negative (possible with adjustments exceeding
	// new disbursement amounts) :  ***10/2014, commented out as per Angela for returned funds
	//*************************************************************	
	
//	ld_eligSum =  dw_detail.GetItemDecimal(dw_detail.RowCount(), "cf_eligSum")		
//	
//	If (ld_eligSum < 0) Then
//				MessageBox("ERROR!", "Disbursed Amount cannot be negative!")				
//				li_RC = -1
//				Goto Finishup	
//	End If	
		
	dw_netavail.SetItemStatus(ll_find, 0, Primary!, NotModified!)		
	
	//*************************************************************
	// Issue Key Values for new rows:
	//*************************************************************
	
	If (l_status = New!) Or (l_status = NewModified!) Then
		
		ll_disburseAmtID = f_gettokenvalue("disburseAmtID", 1)

		dw_detail.SetItem(ll_row, 'disbursement_amt_id', ll_disburseAmtID)
		dw_detail.SetItem(ll_row, 'gigp_id', il_gigpID)
		dw_detail.SetItem(ll_row, 'disbursement_id', il_disbursementID)
		
		of_set_last_updated(ll_row)
		
	End If
	
	
	ll_row = dw_detail.GetNextModified(ll_row, l_dwBuffer)

LOOP

//*************************************************************
// Finishup:
//*************************************************************

Finishup:

dw_netavail.SetRedraw(True)

Return li_RC


end function

public subroutine of_get_adjustments ();
Long 			ll_count, N, ll_disbAmtID, ll_disbID, ll_proffConID
Integer		li_adjCnt
String 		ls_costCat
Datastore 	lds_pendingADJ
Decimal		ld_requested1, ld_ineligible1, ld_adjusted1, ld_netrequest1, ld_eligible1, ld_retained1, ld_disbursed1, ld_diff
Decimal		ld_requested2, ld_ineligible2, ld_adjusted2, ld_netrequest2, ld_eligible2, ld_retained2, ld_disbursed2

//*************************************************************
//
//*************************************************************

lds_pendingADJ = CREATE Datastore

lds_pendingADJ.DataObject = 'd_disburse_pending_adjustments'

lds_pendingADJ.SetTransObject(SQLCA)

ll_count = lds_pendingADJ.Retrieve(il_gigpID)

If (ll_count < 1) Then Goto Closeup


FOR N = 1 TO ll_count
	
	ld_requested1 	= 0
	ld_ineligible1 	= 0
	ld_adjusted1 	= 0
	ld_netrequest1 = 0
	ld_eligible1 		= 0
	ld_retained1 	= 0
	ld_disbursed1 	= 0
	
	ld_requested2 	= 0
	ld_ineligible2 	= 0
	ld_adjusted2 	= 0
	ld_netrequest2 = 0
	ld_eligible2 		= 0
	ld_retained2 	= 0
	ld_disbursed2 	= 0	
	
	ll_disbAmtID 	= lds_pendingADJ.GetItemNumber(N, "disbursement_amt_id")	
	ll_disbID 			= lds_pendingADJ.GetItemNumber(N, "disbursement_id")
	ll_proffConID	= lds_pendingADJ.GetItemNumber(N, "professional_contract_id")
	ls_costCat  		= lds_pendingADJ.GetItemString(N, "cost_category")
	ld_disbursed1 	= lds_pendingADJ.GetItemDecimal(N, "disbursed_amt")	
	
	If IsNull(ld_disbursed1) Then ld_disbursed1 = 0
	
	//*************************************************************
	//
	//*************************************************************
	
	SELECT 	Count(*)
	INTO		:li_adjCnt
   	FROM 	gigp_disbursement_amount  
   	WHERE 	adj_disbursement_amt_id = :ll_disbAmtID
	AND 		disbursement_id > :ll_disbID
	AND 		transaction_type = "ADJUST"
	AND 		professional_contract_id = :ll_proffConID
	AND 		cost_category = :ls_costCat
	AND 		gigp_id = :il_gigpID;
	
	
	If (li_adjCnt > 0) Then	
	
		SELECT 	Sum(requested_amt),   
					Sum(ineligible_amt),   
					Sum(adjusted_amt),   
					Sum(netrequest_amt),   
					Sum(eligible_amt),   
					Sum(retained_amt),   
					Sum(disbursed_amt)  
		INTO		:ld_requested2, 
					:ld_ineligible2,
					:ld_adjusted2,
					:ld_netrequest2,
					:ld_eligible2,
					:ld_retained2,
					:ld_disbursed2
		FROM 	gigp_disbursement_amount  
		WHERE 	adj_disbursement_amt_id	= :ll_disbAmtID
		AND 		disbursement_id 				> :ll_disbID
		AND 		transaction_type 				= "ADJUST"
		AND 		professional_contract_id 	= :ll_proffConID
		AND 		cost_category 					= :ls_costCat
		AND 		gigp_id 							= :il_gigpID;
		

	End If
		
	//*************************************************************
	//
	//*************************************************************
	
	ld_diff =   (ld_disbursed1 - ld_disbursed2) 
		
	If (ld_diff  = 0) Then // Pending Adjustment completely reversed.
		
		// Mark Row - 
		lds_pendingADJ.SetItem(N, "cc_error_flag", 1)
		
		
	Else // Display only the remaining amount available for Pending Adjustment
				
		ld_diff = 0		
		ld_requested1 	= lds_pendingADJ.GetItemDecimal(N, "requested_amt")			
		ld_diff = (ld_requested1 - ld_requested2)		
		lds_pendingADJ.SetItem(N, "requested_amt", ld_diff)
		
		
		ld_diff = 0		
		ld_ineligible1 	= lds_pendingADJ.GetItemDecimal(N, "ineligible_amt")			
		ld_diff = (ld_ineligible1 - ld_ineligible2)		
		lds_pendingADJ.SetItem(N, "ineligible_amt", ld_diff)
		
		
		ld_diff = 0		
		ld_adjusted1 	= lds_pendingADJ.GetItemDecimal(N, "adjusted_amt")			
		ld_diff = (ld_adjusted1 - ld_adjusted2)		
		lds_pendingADJ.SetItem(N, "adjusted_amt", ld_diff)
		
		
		ld_diff = 0		
		ld_netrequest1 = lds_pendingADJ.GetItemDecimal(N, "netrequest_amt")			
		ld_diff = (ld_netrequest1 - ld_netrequest2)		
		lds_pendingADJ.SetItem(N, "netrequest_amt", ld_diff)
		
		
		ld_diff = 0		
		ld_eligible1 = lds_pendingADJ.GetItemDecimal(N, "eligible_amt")			
		ld_diff = (ld_eligible1 - ld_eligible2)		
		lds_pendingADJ.SetItem(N, "eligible_amt", ld_diff)
		
		
		ld_diff = 0		
		ld_retained1 = lds_pendingADJ.GetItemDecimal(N, "retained_amt")			
		ld_diff = (ld_retained1 - ld_retained2)		
		lds_pendingADJ.SetItem(N, "retained_amt", ld_diff)
		
				
		lds_pendingADJ.SetItemStatus(N, 0, Primary!, NotModified!)		
		
	End If
				
		

NEXT




Closeup:

If IsValid (lds_pendingADJ) Then Destroy lds_pendingADJ




end subroutine

public subroutine of_create_wiretransfermemo ();//NOT USED???? See u_tabpg_disbursements . ue_sendletter()

//OLEObject	lou_OLE
//Integer 		li_rc, li_round
//Long           ll_disburseID, ll_previousID, ll_requestNo
//String      	ls_value, ls_value2, ls_bookMark, ls_docPath, ls_projNo, ls_formattedProj, ls_round
//String 		ls_appName, ls_projName, ls_srfProgram, ls_acctName, ls_abaNo, ls_recipAcctNo, ls_grantsource
//Decimal     	ld_amount
//DateTime    	ldt_date, ldt_dummy
//
//If (This.of_UpdatesPending() = 1) Then
//	MessageBox("ERROR!", "This document cannot be generated while unsaved changes exist!")
//	Return
//End If
//
//ldt_dummy = DateTime('1/1/1900 00:00:00')
//
////*******************************************************
//// Connect to MS Word:
////*******************************************************
//
//lou_OLE = CREATE OLEObject
//
//li_rc = lou_OLE.ConnectToObject('', 'Word.Application')
//
//If (li_rc <> 0)  Then 	
//	li_rc = lou_OLE.ConnectToNewObject('Word.Application')
//
//	If (li_rc <> 0)  Then
//		MessageBox("ERROR!", "Error opening Microsoft Word.")
//		Goto FinishUp
//	End If	
//End If
//
////*******************************************************
//// Open  Factsheet Template:
////*******************************************************
//
//Select description
//Into	 :ls_docPath
//From 	 gigp_reference
//Where  category     = "template"
//And    sub_category = "wireTransferMemo"
//And   ref_code = "wireTransferMemo";
//
//lou_OLE.Documents.Add(ls_docPath)
//
////*******************************************************
//// Get most application data:
////*******************************************************
//
// SELECT	project_name, 
//         	srf_program,			
//			project_no,
//			round_no
//INTO		:ls_projName,			
//			:ls_srfProgram,				
//			:ls_projNo,
//			:li_round
//FROM 	gigp_application   
//WHERE	gigp_id = :il_gigpID;
//
//ls_round = String(li_round)
//
////*******************************************************
//// Populate Bookmarks::
////*******************************************************
//
////*********************
//// GIGP ID:
////*********************
//
//ls_value =  String(il_gigpID)
//
//ls_bookMark = "appID"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If
//
////*********************
//// SRF Program:
////*********************
//
//ls_bookMark = "srfProgram"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_srfProgram)
//End If
//
////*********************
//// Name/Number of Account:
////*********************
//
//ls_value = ls_srfProgram + " Unallocated"
//
//ls_bookMark = "fundingSource"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If
//
//SetNull(ls_value2)
//
//Select Description
//Into:ls_value2
//From GIGP_reference
//Where category = 'Disbursement'
//And sub_category = :ls_value;
//
//ls_bookMark = "acctNo"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value2)
//End If
//
////*********************
//// SRF Project:
////*********************
//
//ls_bookMark = "srfProjNo"
//
//ls_value = ls_projNo
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If
//
////*********************
//// Project Name:
////*********************
//
//If IsNull(ls_projName) Then
//	ls_value = ""
//Else
//	ls_value = ls_projName
//End If
//
//ls_bookMark = "projName"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If
//
////*********************
//// Grant Source:
////*********************
//Select description
//into :ls_grantsource
//from gigp_reference
//where category = 'GrantSource'
//and sub_category = :ls_srfProgram
//and ref_code = :ls_round;
//
//If IsNull(ls_grantsource) Then ls_grantsource = ''
//
//ls_bookMark = "grantSource"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_grantsource)
//End If
//
//
////*********************
//// Applicant Name:
////*********************
//
//ls_appName = f_get_applicant_name(il_gigpID)
//
//If IsNull(ls_appName) Then
//	ls_value = ""
//Else
//	ls_value = ls_appName
//End If
//
//ls_bookMark = "appName"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If
//
//ls_bookMark = "appName2"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If
//
////*********************
//// Agreement Dt:
////*********************
//
//SetNull(ldt_date)
//SetNull(ls_value)
//
//Select keydate_value
//Into	:ldt_date
//From gigp_key_dates
//Where gigp_id  = :il_gigpID
//And ref_code = 'agreeAGRFULLEX';
//
//If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
//	
//	ls_value = String(Date(ldt_date), "mmmm dd, yyyy")
//			
//	ls_bookMark = "agreeDt"
//		
//	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//		lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//		lou_OLE.Selection.TypeText(ls_value)
//	End If
//				
//End If
//
////*********************
//// Request No.
////*********************
//
//SetNull(ls_value)
//
//ll_disburseID 	= dw_master.GetItemNumber(1, 'disbursement_id')
//ll_requestNo		= dw_master.GetItemNumber(1, 'request_no')
//
//ls_value = String(ll_requestNo)
//
//If IsNull(ls_value) Then ls_value = ""	
//			
//ls_bookMark = "requestNo"
//		
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If
//
////*********************
//// Release Date:
////*********************
//
//SetNull(ls_value)
//
//ldt_date 	= dw_master.GetItemDateTime(1, 'release_dt')
//
//If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
//	
//	ls_value = String(Date(ldt_date), "mmmm dd, yyyy")
//			
//	ls_bookMark = "releaseDt"
//		
//	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//		lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//		lou_OLE.Selection.TypeText(ls_value)
//	End If
//				
//End If
//
////*********************
//// Disbursed Amount:
////*********************
//
//ld_amount = 0
//SetNull(ls_value)
//
//ld_amount = dw_detail.GetItemDecimal(dw_detail.RowCount(), 'cf_disbsum')
//
//If IsNull(ld_amount) Then ld_amount = 0
//
//ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
//
//ls_bookMark = "disburseAmt"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//			lou_OLE.Selection.TypeText(ls_value)
//End If
//
////*********************
//// Net Avail Amount:
////*********************
//
//ld_amount = 0
//SetNull(ls_value)
//
//ld_amount = dw_netavail.GetItemDecimal(dw_netavail.RowCount(), 'cf_awardnet')
//
//If IsNull(ld_amount) Then ld_amount = 0
//
//ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
//
//ls_bookMark = "netAvailAmt"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//			lou_OLE.Selection.TypeText(ls_value)
//End If
//
////*********************
//// Previous Request Info:
////*********************
//
//ld_amount = 0
//
//Select Max(disbursement_id)
//Into	:ll_previousID
//From gigp_disbursement_request  
//WHERE 	disbursement_id < :ll_disburseID
//AND gigp_id =  :il_gigpID;
//
//If (ll_previousID < 1) Then
//	// Do Nothing
//Else
//	Select Sum(disbursed_amt)
//	Into	:ld_amount
//	From gigp_disbursement_amount 
//	WHERE 	disbursement_id = :ll_previousID
//	And		gigp_id  = :il_gigpID;
//	
//	If IsNull(ld_amount) Then ld_amount = 0
//
//End If
//
//ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
//
//ls_bookMark = "prevAmt"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If
//
////*********************
//// Cumulative Retainage:
////*********************
//
//ld_amount = 0
//
//Select 	Sum(retained_amt)
//Into 		:ld_amount
//FROM 	gigp_disbursement_amount    
//Where 	gigp_id = :il_gigpID;
//
//If IsNull(ld_amount) Then ld_amount = 0
//
//ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
//
//ls_bookMark = "cumRetained"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If
//
////*********************
//// Wire To Info:
////*********************
//
//ls_value = ""
//	
//Select		C.organization
//Into		:ls_value
//FROM		gigp_contacts C,   
//			gigp_contact_links CL  
//WHERE 	C.contact_id = CL.contact_id    
//AND		CL.gigp_id = :il_gigpID
//AND      	CL.contact_type = "BNKC";
//	
//If IsNull(ls_value) Then ls_value = ""
//	
//ls_bookMark = "bankName"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If	
//
//DECLARE cWTI CURSOR FOR
//		SELECT	R.ref_code,    
//        				PR.projref_value 
//		FROM 	gigp_project_references PR,
//	 				gigp_reference R  
//		WHERE 	PR.ref_code NEED LEFT OUTER JOIN SYNTAX R.ref_code  
//		AND      	R.category = 'projectRef'
//		AND      	R.sub_category = 'bankInfo'
//		AND      	PR.gigp_id = :il_gigpID
//		ORDER BY R.sort_order ASC;
//	
//OPEN cWTI;
//	
//FETCH cWTI INTO :ls_value, :ls_value2;
//	
//DO WHILE SQLCA.sqlcode = 0
//	
//	If IsNull(ls_value2) Then ls_value2 = ""
//		
//	If (ls_value = 'bankABA') Then
//		
//		 ls_abaNo = ls_value2		 
//		 ls_bookMark = "abaNo"
//		 
//		If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//			lou_OLE.Selection.TypeText(ls_abaNo)
//		End If
//		
//	ElseIf (ls_value = 'acctName') Then
//		
//		ls_acctName = ls_value2		
//		ls_bookMark = "acctName"
//		
//		 If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//			lou_OLE.Selection.TypeText(ls_acctName)
//		End If
//		
//	ElseIf (ls_value = 'acctNo') Then
//		
//		ls_recipAcctNo = ls_value2		
//		ls_bookMark = "recipAcctNo"
//		
//		 If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//			lou_OLE.Selection.TypeText(ls_recipAcctNo)
//		End If
//		
//	End If
//			
//	FETCH cWTI INTO :ls_value, :ls_value2;
//	
//LOOP
//	
//CLOSE cWTI;
//
////*********************
//// Total Authorized Amount:
////*********************
//
//ld_amount = 0 
//ls_value = ""
//
//ld_amount = f_get_project_amount(il_gigpID, "RECFR")  
//
//ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
//
//ls_bookMark = "awardAmt"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If
//
////*************************************************************
//// Authorized Rep:		***currently removed from the memo***
////*************************************************************
//
//ls_value = ""
//	
//Select		C.full_name
//Into		:ls_value
//FROM		gigp_contacts C,   
//				gigp_contact_links CL  
//WHERE 	C.contact_id = CL.contact_id    
//AND		CL.gigp_id = :il_gigpID
//AND      	CL.contact_type = "AUTHREP";
//	
//If IsNull(ls_value) Then ls_value = ""
//	
//ls_bookMark = "authRep"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//	lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//	lou_OLE.Selection.TypeText(ls_value)
//End If	
//
////*******************************************************
//// Finish Up:
////*******************************************************
//
//FinishUp:
//
//lou_OLE.Visible = True
//
//If IsValid(lou_OLE) Then lou_OLE.DisconnectObject()
//
//
end subroutine

public subroutine of_set_cost_category (long al_row);
Long ll_professContractID
String ls_value

ll_professContractID = dw_detail.GetItemNumber(al_row, "professional_contract_id")
		
Select contract_type
Into :ls_value
From gigp_professional_contracts
Where profess_contract_id = :ll_professContractID
And gigp_id = :il_gigpID;
				
dw_detail.SetItem(al_row, 'cost_category', ls_value)
end subroutine

public subroutine of_checkfor_mwbe_hold (long al_row);

Long ll_professContractID
Integer li_mwbeHold

ll_professContractID = dw_detail.GetItemNumber(al_row, "professional_contract_id")
		
Select mwbe_hold_flag
Into :li_mwbeHold
From gigp_professional_contracts
Where profess_contract_id = :ll_professContractID
And gigp_id = :il_gigpID;
				
dw_detail.SetItem(al_row, 'cc_mwbehold_flag', li_mwbeHold)
end subroutine

public subroutine of_display_text (long al_row);
String ls_display

ls_display = dw_detail.GetItemString(al_row, 'cf_professcontract')

dw_detail.Object.t_display.Text = ls_display
end subroutine

public function integer of_checknetrequested ();long ll_count, ll_row, ll_find, ll_id, ll_profID[]
decimal ld_amt, ld_netReq, ld_contract
integer li_index
string ls_find
n_ds lds_prof
dwitemstatus lrs_status


//Get a distinct list of Professional Contract IDs for this Disbursement Requst
If NOT IsValid(lds_prof) Then lds_prof = CREATE n_ds

lds_prof.DataObject = dw_detail.DataObject
dw_detail.ShareData(lds_prof)

lds_prof.SetSort('professional_contract_id')
lds_prof.Sort()

ll_count = lds_prof.RowCount()
//If ll_count = 0 Then Return 1
If ll_count = 0 Then Return 0
li_index = 0

For ll_row = 1 to ll_count
	ll_id = lds_prof.GetItemNumber(ll_row, 'professional_contract_id')
	
	lrs_status = lds_prof.GetItemStatus(ll_row, 0, Primary!)
	
	//Only evaluate rows that were modified/inserted
	If lrs_status <> NotModified! Then
		If li_index = 0 Then
			li_index++
			ll_profID[li_index] = ll_id
		Else
			If ll_id <> ll_profID[li_index] Then
				li_index++
				ll_profID[li_index] = ll_id
			End If
		End If
	End If

Next

If IsValid(lds_prof) Then DESTROY lds_prof

//For Each Proffesional Contract, check the Total Net Requested and compare to Contract Amount
ll_count = UpperBound(ll_profID)

For li_index = 1 to ll_count
	ld_contract = 0
	ld_netReq = 0
	
	//Get Contract Amount for the Professional Contract...  ***2/2013 ADDED MWBE_REVIEW_FLAG BY SW
	//select sum(contract_amt)
	select sum(eligible_amt)	//Changed to eligible_amt as per AP (4/2014)
	into :ld_contract
	from gigp_professional_contracts
	where profess_contract_id = :ll_profID[li_index]
	and mwbe_review_flag <> 1;
	
	//Get total Net Requested for this Professional Contract that is NOT associated with this DR
	select sum(netrequest_amt)
	into :ld_netReq
	from gigp_disbursement_amount
	where gigp_id = :il_gigpid
	and professional_contract_id = :ll_profID[li_index]
	and disbursement_id <> :il_disbursementid;
	
	If IsNull(ld_netReq) Then ld_netReq = 0


	//Add Net Requested amounts from datawindow (DR) for that Professional Contract
	ls_find = 'professional_contract_id = ' + string(ll_profID[li_index])
	
	ll_find = dw_detail.Find(ls_find, 0, dw_detail.RowCount())
	
	Do While ll_find > 0
		ld_amt = dw_detail.GetItemNumber(ll_find, 'netrequest_amt')
		
		If ld_amt > 0 Then
			ld_netReq += ld_amt
		End If
		
		If ll_find = dw_detail.RowCount() Then
			ll_find = -1 
		Else
			ll_find = dw_detail.Find(ls_find, ll_find + 1, dw_detail.RowCount())
		End If
		
	Loop
	
	//Compre to Total Contract Amount
	If Round(ld_netReq,2) > Round(ld_contract,2) Then
		Return ll_profID[li_index]
	End If

Next



Return 0
end function

public function integer of_calc_retainage_release (long al_row);decimal ld_retained, ld_disbursed
long ll_id

//Make sure it is a Retrainage Release
If dw_detail.GetItemString(al_row, 'transaction_type') <> 'RELRET' Then
	Return 1
End If

//Get the professional contract id
ll_id = dw_detail.GetItemNumber(al_row, 'professional_contract_id')

//If none was found, exit
If IsNull(ll_id) or ll_id <= 0 Then
	Return 1
End If

//Get the total retained amount for that contract
select sum(retained_amt)
into :ld_retained
from gigp_disbursement_amount
where professional_contract_id = :ll_id;

If NOT IsNull(ld_retained) Then
	ld_disbursed = ld_retained
	ld_retained = ld_retained * -1
else
	ld_disbursed = 0
	ld_retained = 0
End If

//Set the amounts
dw_detail.SetItem(al_row, 'ineligible_amt', 0)
dw_detail.SetItem(al_row, 'withheld_amt', 0)
dw_detail.SetItem(al_row, "netrequest_amt", 0)
dw_detail.SetItem(al_row, "eligible_amt", 0)

dw_detail.SetItem(al_row, "retained_amt", ld_retained)

dw_detail.SetItem(al_row, "disbursed_amt", ld_disbursed)

Return 1
end function

public function integer of_checkdisbursedamount ();long ll_count, ll_row, ll_find, ll_id, ll_profID[]
decimal ld_amt, ld_netReq, ld_contract
integer li_index
string ls_find
n_ds lds_prof
dwitemstatus lrs_status


//Get a distinct list of Professional Contract IDs for this Disbursement Requst
If NOT IsValid(lds_prof) Then lds_prof = CREATE n_ds

lds_prof.DataObject = dw_detail.DataObject
dw_detail.ShareData(lds_prof)

lds_prof.SetSort('professional_contract_id')
lds_prof.Sort()

ll_count = lds_prof.RowCount()
//If ll_count = 0 Then Return 1
If ll_count = 0 Then Return 0
li_index = 0

For ll_row = 1 to ll_count
	ll_id = lds_prof.GetItemNumber(ll_row, 'professional_contract_id')
	
	lrs_status = lds_prof.GetItemStatus(ll_row, 0, Primary!)
	
	//Only evaluate rows that were modified/inserted
	If lrs_status <> NotModified! Then
		If li_index = 0 Then
			li_index++
			ll_profID[li_index] = ll_id
		Else
			If ll_id <> ll_profID[li_index] Then
				li_index++
				ll_profID[li_index] = ll_id
			End If
		End If
	End If

Next

If IsValid(lds_prof) Then DESTROY lds_prof

//For Each Proffesional Contract, check the Total Net Requested and compare to Contract Amount
ll_count = UpperBound(ll_profID)

For li_index = 1 to ll_count
	ld_contract = 0
	ld_netReq = 0
	
	//Get Contract Amount for the Professional Contract...  ***2/2013 ADDED MWBE_REVIEW_FLAG BY SW
	//select sum(contract_amt)
	select sum(eligible_amt)	//Changed to eligible_amt as per AP (4/2014)
	into :ld_contract
	from gigp_professional_contracts
	where profess_contract_id = :ll_profID[li_index]
	and mwbe_review_flag <> 1;
	
	//Get total Disbursed Amount for this Professional Contract that is NOT associated with this DR
	select sum(disbursed_amt)
	into :ld_netReq
	from gigp_disbursement_amount
	where gigp_id = :il_gigpid
	and professional_contract_id = :ll_profID[li_index]
	and disbursement_id <> :il_disbursementid;
	
	If IsNull(ld_netReq) Then ld_netReq = 0


	//Add Net Requested amounts from datawindow (DR) for that Professional Contract
	ls_find = 'professional_contract_id = ' + string(ll_profID[li_index])
	
	ll_find = dw_detail.Find(ls_find, 0, dw_detail.RowCount())
	
	Do While ll_find > 0
		ld_amt = dw_detail.GetItemNumber(ll_find, 'disbursed_amt')
		
		If ld_amt > 0 Then
			ld_netReq += ld_amt
		End If
		
		If ll_find = dw_detail.RowCount() Then
			ll_find = -1 
		Else
			ll_find = dw_detail.Find(ls_find, ll_find + 1, dw_detail.RowCount())
		End If
		
	Loop
	
	//Compre to Total Contract Amount
	If Round(ld_netReq,2) > Round(ld_contract,2) Then
		Return ll_profID[li_index]
	End If

Next



Return 0
end function

on w_disbursement_edit.create
int iCurrent
call super::create
this.cb_adj=create cb_adj
this.shl_1=create shl_1
this.cb_integrity=create cb_integrity
this.st_locked=create st_locked
this.pb_insert=create pb_insert
this.pb_delete=create pb_delete
this.dw_netavail=create dw_netavail
this.dw_pendingadj=create dw_pendingadj
this.dw_master=create dw_master
this.dw_detail=create dw_detail
this.cb_unlock=create cb_unlock
this.pb_calculator=create pb_calculator
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_adj
this.Control[iCurrent+2]=this.shl_1
this.Control[iCurrent+3]=this.cb_integrity
this.Control[iCurrent+4]=this.st_locked
this.Control[iCurrent+5]=this.pb_insert
this.Control[iCurrent+6]=this.pb_delete
this.Control[iCurrent+7]=this.dw_netavail
this.Control[iCurrent+8]=this.dw_pendingadj
this.Control[iCurrent+9]=this.dw_master
this.Control[iCurrent+10]=this.dw_detail
this.Control[iCurrent+11]=this.cb_unlock
this.Control[iCurrent+12]=this.pb_calculator
end on

on w_disbursement_edit.destroy
call super::destroy
destroy(this.cb_adj)
destroy(this.shl_1)
destroy(this.cb_integrity)
destroy(this.st_locked)
destroy(this.pb_insert)
destroy(this.pb_delete)
destroy(this.dw_netavail)
destroy(this.dw_pendingadj)
destroy(this.dw_master)
destroy(this.dw_detail)
destroy(this.cb_unlock)
destroy(this.pb_calculator)
end on

event open;call super::open;
Long ll_row, ll_disbursementID
Integer li_lock
str_disbursementparms lstr_parms
String 		ls_value, ls_access, ls_title
DateTime	ldt_limit
DataWindowChild ldwc

ls_title = this.Title

lstr_parms = Message.PowerObjectParm

il_disbursementID	= lstr_parms.str_disbursementid 
il_gigpID  			= lstr_parms.str_gigpid 
ls_access 			= lstr_parms.str_access

//*************************************************************
// Check User Access:
//*************************************************************

If (ls_access = "READ") Then
	
	dw_master.Object.DataWindow.ReadOnly="Yes"
	dw_detail.Object.DataWindow.ReadOnly="Yes"
	pb_insert.Enabled = False
	pb_delete.Enabled = False
	cb_adj.Enabled = False
	cb_integrity.Enabled = False
	cb_ok.Visible = False
	cb_cancel.Text = 'OK'
	This.Title = "Disbursement Details (Read Only!)"
	
Else
	
	dw_master.Object.DataWindow.ReadOnly="No"
	dw_detail.Object.DataWindow.ReadOnly="No"
	pb_insert.Enabled = True
	pb_delete.Enabled = True
	cb_adj.Enabled = True
	cb_integrity.Enabled = True
	cb_ok.Visible = True
	cb_cancel.Text = 'Cancel'
	This.Title = ls_title
	
End If

//*************************************************************
// New / Edit Disbursement:
//*************************************************************

If (il_disbursementID = -1) Then // New Disbursement

	cb_unlock.Enabled = False
	
	//Insert new disbursement row
	
	ll_row = dw_master.InsertRow(0)
	dw_master.SetItem(ll_row, 'override_state_federal_split', 0)
	
	// Disbursement Status removed (04-20-2010, mpf)
	
//	// Get/Set Default Disbursement Status:
//	
//	Select ref_code
//	Into :ls_value
//	From gigp_reference
//	Where category = 'Disbursement'
//	And sub_category = 'disburseStatus'
//	And cat_default = 1;
//	
//	dw_master.SetItem(ll_row, 'disbursement_status', ls_value)
	
// Requiring a disbursement Amount  row removed (03-18-2010, mpf)
	
//	//Insert a stub disbursement Amount  row
//	
//	ll_row = dw_detail.Event pfc_InsertRow()
//	
//	of_set_last_updated(ll_row)
	
	// Get Next Request Token
	il_disbursementID = f_gettokenvalue("disburseID", 1)
	
	
Else // Edit existing Disbursement
	
	dw_master.Retrieve(il_disbursementID)
	
	li_lock = dw_master.GetItemNumber(1, "lock_flag")
	
	If (li_lock = 1) Then
		st_locked.Visible = True		
		
		If gnv_app.of_ingroup(is_accessGroups) Then
			cb_unlock.Enabled = True
		Else
			cb_unlock.Enabled = False
		End If
		
	Else
		st_locked.Visible = False		
		cb_unlock.Enabled = False
	End If
	
	dw_detail.Retrieve(il_disbursementID)
	
End If

//*************************************************************
//  Retrieve Professional Contracts DDDW:
//*************************************************************

dw_detail.GetChild('professional_contract_id', ldwc)
ldwc.SetTransObject(SQLCA)
ldwc.Retrieve(il_gigpID)


//*************************************************************
//  Retrieve Net Available by Professional Contracts:
//*************************************************************

dw_netavail.Retrieve(il_gigpID)


//*************************************************************
// Calc 45 day cut-off for Adjustments:
//*************************************************************

ldt_limit = DateTime(RelativeDate(Date(f_getdbdatetime()), -45))


If (il_disbursementID = -1) Then
	ll_disbursementID = 999999999
Else
	ll_disbursementID = il_disbursementID
End If

dw_pendingadj.Retrieve(il_gigpID, ldt_limit, il_disbursementID)

//*************************************************************
// Get Eligible & Retainage Percentages:
//*************************************************************

of_get_disbursement_pcts()





end event

event close;call super::close;//OverRide//

f_set_funding_buckets(il_disbursementID)

CloseWithReturn(This, il_disbursementID)
end event

type cb_cancel from w_gigp_response`cb_cancel within w_disbursement_edit
integer x = 4064
integer y = 2304
end type

event cb_cancel::clicked;
//OverRide//

il_disbursementID = -1

Close(Parent)
end event

type cb_ok from w_gigp_response`cb_ok within w_disbursement_edit
integer x = 3685
integer y = 2304
end type

event cb_ok::clicked;
//OverRide//

is_action = "OK"

Integer li_RC

li_RC = of_integrity_check()

If (li_RC = -1) Then
	Return
End If

Close(Parent)
end event

type cb_adj from commandbutton within w_disbursement_edit
integer x = 2738
integer y = 2304
integer width = 370
integer height = 100
integer taborder = 60
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Adjustments?"
end type

event clicked;
If (dw_pendingadj.Visible = False) Then
	dw_pendingadj.X = dw_master.X	
	dw_pendingadj.Visible = True
end If
end event

type shl_1 from statichyperlink within w_disbursement_edit
integer x = 37
integer y = 32
integer width = 791
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
string text = "View Disbursement Summary"
boolean focusrectangle = false
end type

event clicked;
If (dw_netavail.Visible = False) Then
	dw_netavail.X = dw_master.X	
	dw_netavail.Visible = True
end If
end event

type cb_integrity from commandbutton within w_disbursement_edit
integer x = 3145
integer y = 2304
integer width = 370
integer height = 100
integer taborder = 70
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Integrity Check"
end type

event clicked;
Integer li_RC

li_RC = of_integrity_check()

If (li_RC = 1) Then
	MessageBox("Integrity Check", "Disbursement OK!")	
End If
end event

type st_locked from statictext within w_disbursement_edit
boolean visible = false
integer x = 4037
integer y = 20
integer width = 370
integer height = 68
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 128
long backcolor = 65535
string text = "Locked!"
alignment alignment = center!
boolean border = true
boolean focusrectangle = false
end type

type pb_insert from picturebutton within w_disbursement_edit
integer x = 18
integer y = 2312
integer width = 128
integer height = 100
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "Insert!"
string disabledname = "Insert!"
alignment htextalign = left!
string powertiptext = "Insert Row!"
end type

event clicked;
dw_detail.Event pfc_InsertRow()
end event

type pb_delete from picturebutton within w_disbursement_edit
integer x = 187
integer y = 2312
integer width = 128
integer height = 100
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "DeleteRow!"
string disabledname = "DeleteRow!"
alignment htextalign = left!
string powertiptext = "Delete Row!"
end type

event clicked;
dw_detail.Event pfc_deleterow()
end event

type dw_netavail from u_dw within w_disbursement_edit
boolean visible = false
integer x = 18
integer y = 1352
integer width = 3854
integer height = 928
integer taborder = 11
boolean titlebar = true
string title = "Net Available by Project"
string dataobject = "d_disburse_netavail_byproject"
boolean controlmenu = true
boolean hscrollbar = true
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.Object.DataWindow.ReadOnly="Yes"

This.ib_RMBMenu = False
end event

event retrieveend;call super::retrieveend;

Long ll_row, ll_professContractID
Decimal ld_contractAmt, ld_eligibleAmt, ld_retainageAmt, ld_awardAmt
String ls_subCat
Integer li_sort

If (rowcount < 1) Then Return

ld_awardAmt = f_get_project_amount(gl_gigp_id, "RECFR")

FOR ll_row = 1 TO rowcount
      
	ll_professContractID 	= This.GetItemNumber(ll_row, "profess_contract_id")
	ld_contractAmt 		= This.GetItemDecimal(ll_row, "contract_amt")
	ls_subCat       			= This.GetItemString(ll_row, "contract_type")
	 
	 
	Select		Sum(eligible_amt),   
        			Sum(retained_amt)  
	Into 		:ld_eligibleAmt,
				:ld_retainageAmt
	From  	gigp_disbursement_amount   
	Where gigp_id = :gl_gigp_id
	And professional_contract_id = :ll_professContractID;		
	
	If IsNull(ld_eligibleAmt) Then ld_eligibleAmt = 0
	If IsNull(ld_retainageAmt) Then ld_retainageAmt = 0

	This.SetItem(ll_row, 	"cc_netavail", (ld_contractAmt - ld_eligibleAmt))	
	This.SetItem(ll_row, 	"cc_disbAmt", ld_eligibleAmt)	
	This.SetItem(ll_row, 	"cc_retavail", ld_retainageAmt)	
				
	//*************************************************************
	// Get/Set Sub-Category Sort Order:
	//*************************************************************
	
	Select Min(sort_order)
	Into  :li_sort
	From gigp_reference
	Where category = "budgetAmount"
	And sub_category = :ls_subCat;
	
	This.SetItem(ll_row, "cc_sort", li_sort)				
		
	This.SetItemStatus(ll_row, 0, Primary!, NotModified!)	
	
	ll_professContractID = 0
	ld_eligibleAmt = 0
	ld_retainageAmt = 0
	
	ls_subCat  = ""
	li_sort = 0	
	
NEXT

This.Sort()
This.GroupCalc()

This.SetItem(rowcount, 	"cc_awardAmt", ld_awardAmt)		
This.SetItemStatus(rowcount, 0, Primary!, NotModified!)
end event

type dw_pendingadj from u_dw within w_disbursement_edit
boolean visible = false
integer x = 18
integer y = 124
integer width = 4389
integer height = 856
integer taborder = 11
boolean titlebar = true
string title = "Pending Adjustments"
string dataobject = "d_disburse_pending_adjustments"
boolean controlmenu = true
boolean hscrollbar = true
boolean resizable = true
string icon = "StopSign!"
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.Object.DataWindow.ReadOnly="Yes"

This.ib_RMBMenu = False

//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)

end event

event clicked;call super::clicked;
This.Drag(Begin!)
end event

event dragdrop;call super::dragdrop;
IF source = this THEN
	Return
END IF
end event

type dw_master from u_dw within w_disbursement_edit
string tag = "Disbursement Request"
integer x = 18
integer y = 124
integer width = 4389
integer height = 436
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_disburse_request_edit"
boolean hscrollbar = true
boolean vscrollbar = false
boolean livescroll = false
end type

event buttonclicked;call super::buttonclicked;
String 	ls_Text
Integer	li_RC

If (dwo.Name = "b_edit") Then	
	
	ls_Text = This.GetItemString(row, "comments")	
	
	li_RC = f_edit_notes("EDIT", ls_Text)	
	
	If (li_RC = 1) Then This.SetItem(row, "comments", ls_Text)	
	
End If
end event

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False

//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Disbursements"}
end event

event sqlpreview;call super::sqlpreview;
String	ls_category
Long 	ll_gigpID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN	
	ls_category = This.Tag		
	f_transactionlog("gigp_id", il_gigpID, This.DataObject, ls_category, sqlsyntax)
END IF
end event

event pfc_updateprep;call super::pfc_updateprep;
Long ll_row, ll_value
DWItemStatus ldw_status

String ls_value

DateTime ldt_value, ldt_dummy

ldt_dummy = DateTime(Date("01/01/1900"))

ll_row = dw_master.GetRow()

//*************************************************************
// Must have a Received Date:
//*************************************************************

ldt_value = This.GetItemDateTime(ll_row, "received_dt")	


If IsNull(ldt_value) Or (ldt_value = ldt_dummy) Then
	
	Messagebox("ERROR!", "Received Date Required!")
	Return -1
End If


//*************************************************************
// Must have a Request No:
//*************************************************************

ll_value = This.GetItemNumber(ll_row, "request_no")	
	
If IsNull(ll_value) Then
		Messagebox("ERROR!", "Request No. Required!")
		Return -1
	End If	


//*************************************************************
// Must have a Received Date:
//*************************************************************

ldw_status = dw_master.GetItemStatus(ll_row, 0, Primary!)

If (ldw_status = NewModified!) Or (ldw_status =  New!) Then

//	il_disbursementID = f_gettokenvalue("disburseID", 1) - Moved to Open event
	This.SetItem(ll_row, "disbursement_id", il_disbursementID)
	
	This.SetItem(ll_row, "gigp_id", il_gigpID)	
	
End If

of_set_last_updated(0)

//MessageBox("Test!", "dw_master - pfc_updateprep")

Return 1
end event

event losefocus;call super::losefocus;
This.AcceptText()
end event

type dw_detail from u_dw within w_disbursement_edit
string tag = "Disbursement Amount"
integer x = 18
integer y = 564
integer width = 4389
integer height = 1720
integer taborder = 20
boolean bringtotop = true
string dataobject = "d_disburse_details_edit"
boolean hscrollbar = true
boolean hsplitscroll = true
boolean livescroll = false
boolean ib_rmbmenu = false
end type

event buttonclicked;call super::buttonclicked;
String 	ls_Text, ls_col, ls_Access
Integer	li_RC, li_limit

If (This.Describe("DataWindow.ReadOnly") = "yes" )Then
	ls_Access = "READ"
Else
	ls_Access = "EDIT"
End If

If (dwo.Name = "b_edit") Then	
	
	ls_Text = This.GetItemString(row, "comments")	
	
	li_RC = f_edit_notes(ls_Access, ls_Text)	
	
	If (li_RC = 1) Then This.SetItem(row, "comments", ls_Text)	
	
End If


If (dwo.Name = "b_singleedit") Then	
	
	ls_col = dwo.Tag
	
	ls_Text = This.GetItemString(row, ls_col)	
	
	li_limit = 50
	
	li_RC = f_edit_notes2(ls_Access, ls_Text, li_limit)	
	
	If (li_RC = 1) Then This.SetItem(row, ls_col, ls_Text)	
	
End If
end event

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False

//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Disbursements"}

//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)
end event

event sqlpreview;call super::sqlpreview;
String	ls_category
Long 	ll_gigpID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	ls_category = This.Tag		
	f_transactionlog("gigp_id", il_gigpID, This.DataObject, ls_category, sqlsyntax)
END IF
end event

event pfc_updateprep;call super::pfc_updateprep;
Integer	li_RC
Long 		ll_disburseAmtID, ll_row
dwItemStatus	l_status

//MessageBox("Test!", "dw_detail - pfc_updateprep")

li_RC =  of_integrity_check()

If (li_RC = -1) Then Return li_RC

ll_row = dw_detail.GetNextModified(0, Primary!)

DO WHILE ll_row > 0
	
	l_status = dw_detail.GetItemStatus(ll_row, 0, Primary!)

	//*************************************************************
	// Issue Key Values for new rows:
	//*************************************************************
	
	If (l_status = New!) Or (l_status = NewModified!) Then
		
		ll_disburseAmtID = f_gettokenvalue("disburseAmtID", 1)

		dw_detail.SetItem(ll_row, 'disbursement_amt_id', ll_disburseAmtID)
		dw_detail.SetItem(ll_row, 'gigp_id', il_gigpID)
		dw_detail.SetItem(ll_row, 'disbursement_id', il_disbursementID)
		
		of_set_last_updated(ll_row)
		
	End If

	ll_row = dw_detail.GetNextModified(ll_row, Primary!)

LOOP

return 1
end event

event pfc_predeleterow;call super::pfc_predeleterow;
// Rule removed 03-18-2010, mpf

//Long ll_rowCnt
//
//ll_rowCnt = This.RowCount()
//
//If (ll_rowCnt = 1) Then	
//	MessageBox("ERROR!", "Must have at least 1 disbursement amount entry!")
//	Return -1
//End If
//

Return AncestorReturnValue
end event

event pfc_postinsertrow;call super::pfc_postinsertrow;String ls_value, ls_program

// Get-Set Default Disbursement Transaction Type:
	
Select ref_code
Into :ls_value
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'transType'
And cat_default = 1;
	
dw_detail.SetItem(al_row, 'transaction_type', ls_value)

select program
into :ls_program
from gigp_application
where gigp_id = :il_gigpID;

If ls_program = 'WQI' or ls_program = 'Septic' Then
	this.SetItem(al_row, 'proofof_pmt_flag', 1)
	this.SetItem(al_row, 'retainage_pd_flag', 1)
End If
end event

event itemchanged;call super::itemchanged;string ls_invnum
long ll_count, ll_prof
decimal ld_requested, ld_ineligible
datetime ldt_invdate


If (row < 1) Then Return

CHOOSE CASE dwo.Name		
		
	CASE 		'professional_contract_id'
		
		Post of_set_cost_category(row)	
		Post of_checkfor_mwbe_hold(row)
		Post of_display_text(row)
		Post of_calc_retainage_release(row)
	
	CASE   'transaction_type', 'requested_amt', 'withheld_amt', 'ineligible_amt', 'retained_amt'
		If dwo.Name = 'requested_amt' Then
			If id_costsharePct < 1 Then
				ld_requested = Dec(data)
				ld_ineligible = Round((ld_requested * (1 - id_costsharePct)), 2)
				this.SetItem(row, 'ineligible_amt', ld_ineligible)
			End If
		End If
		
		of_calc_lineitem(row)
		
	CASE 'invoice_no'
		//Check for this invoice number already entered
		ld_requested = this.GetItemDecimal(row, 'requested_amt')
		ldt_invdate = this.GetItemDateTime(row, 'invoice_dt')
		
		If data > '' Then
			select count(*)
			into :ll_count
			from gigp_disbursement_amount
			where gigp_id = :il_gigpid
			and invoice_no = :data
			and requested_amt = :ld_requested
			and invoice_dt = :ldt_invdate;
			
		
			If ll_count > 0 Then
				MessageBox(parent.title, 'A Disbursement Request for this Invoice Number, Date & Amount already exists.', Exclamation!)
			End If
			
		End If
		
		
	CASE 'invoice_dt'
		//Check for this invoice number already entered
		ld_requested = this.GetItemDecimal(row, 'requested_amt')
		ldt_invdate = DateTime(Date(data))
		ls_invnum = this.GetItemString(row, 'invoice_no')
		
		select count(*)
		into :ll_count
		from gigp_disbursement_amount
		where gigp_id = :il_gigpid
		and invoice_no = :ls_invnum
		and requested_amt = :ld_requested
		and invoice_dt = :ldt_invdate;
			
		
		If ll_count > 0 Then
			MessageBox(parent.title, 'A Disbursement Request for this Invoice Number, Date & Amount already exists.', Exclamation!)
		End If
	
END CHOOSE


end event

event pfc_deleterow;call super::pfc_deleterow;
//Post of_integrity_check()

Return AncestorReturnValue
end event

event dragdrop;call super::dragdrop;
Integer	li_row, li_selectedRow

Long 		ll_proffContractID, ll_adjDisbursAmtID

String 	ls_transType, ls_costCat

Decimal	ld_requested, ld_ineligible, ld_withheld, ld_netRequest, ld_eligible, ld_retained, ld_disbursed

ls_transType = "ADJUST"

dw_detail.SetRedraw(FALSE)

IF source = This THEN
	Return
END IF

li_selectedRow = dw_pendingadj.GetSelectedRow(0)

If (li_selectedRow > 0) Then

	//*************************************************************************
	// Set the Adjustment information dragged from the  Pending Adjustments datawindow:
	//*************************************************************************

	li_row = This.InsertRow(0)
	
	ls_costCat  				= dw_pendingadj.GetItemString(li_selectedRow, "cost_category")
	ll_proffContractID  	= dw_pendingadj.GetItemNumber(li_selectedRow, "professional_contract_id")	
	ll_adjDisbursAmtID	= dw_pendingadj.GetItemNumber(li_selectedRow, "disbursement_amt_id")
	
	ld_requested 			= (dw_pendingadj.GetItemDecimal(li_selectedRow, "requested_amt") * -1)
	ld_ineligible 				= (dw_pendingadj.GetItemDecimal(li_selectedRow, "ineligible_amt") * -1)
	ld_withheld 				= (dw_pendingadj.GetItemDecimal(li_selectedRow, "withheld_amt") * -1)	
	
	This.Setitem(li_row, "transaction_type", ls_transType)
	This.Setitem(li_row, "cost_category", ls_costCat)
	This.Setitem(li_row, "professional_contract_id", ll_proffContractID)
	This.Setitem(li_row, "adj_disbursement_amt_id", ll_adjDisbursAmtID)	
	This.Setitem(li_row, "requested_amt", ld_requested)
	This.Setitem(li_row, "ineligible_amt", ld_ineligible)
	This.Setitem(li_row, "withheld_amt", ld_withheld)

	of_calc_lineitem(li_row)
	
	dw_pendingadj.DeleteRow(li_selectedRow)


End If

dw_detail.SetRedraw(TRUE)
end event

event pfc_preupdate;call super::pfc_preupdate;


Long 		ll_disburseAmtID, ll_adjAmtID, ll_row
String ls_transType


ll_row = dw_detail.GetNextModified(0, Primary!)

DO WHILE ll_row > 0
		
	//*************************************************************
	// For Adjusted entries due to proof of Payment not being provided:
	//  - Synchronize the Disbursement Amt & Adjusted Disbursement Amt IDs.
	//*************************************************************
		
	ls_transType = dw_detail.GetItemString(ll_row, "transaction_type")	
	
	If (ls_transType = "ADJUST") Then
		
		ll_adjAmtID = dw_detail.GetItemNumber(ll_row, "adj_disbursement_amt_id")
		
		If Not IsNull(ll_adjAmtID) Then
			
			ll_disburseAmtID = dw_detail.GetItemNumber(ll_row, "disbursement_amt_id")
			
			Update 	gigp_disbursement_amount
			Set 		adj_disbursement_amt_id = :ll_disburseAmtID
			Where 	disbursement_amt_id = :ll_adjAmtID;			
			
		End If
				
	End If	

	ll_row = dw_detail.GetNextModified(ll_row, Primary!)

LOOP

return 1
end event

event losefocus;call super::losefocus;
This.AcceptText()
end event

event rowfocuschanged;call super::rowfocuschanged;
If (currentrow < 1) Then Return

Post of_display_text(currentrow)
end event

type cb_unlock from commandbutton within w_disbursement_edit
integer x = 2331
integer y = 2304
integer width = 370
integer height = 100
integer taborder = 70
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean enabled = false
string text = "Unlock"
end type

event clicked;//Set the lock flag to 0
dw_master.SetItem(dw_master.GetRow(), 'lock_flag', 0)

//Remove the Locked indicator
st_locked.Visible = False

//Set editing ability
dw_master.Object.DataWindow.ReadOnly="No"
dw_detail.Object.DataWindow.ReadOnly="No"
pb_insert.Enabled = True
pb_delete.Enabled = True
cb_adj.Enabled = True
cb_integrity.Enabled = True
cb_ok.Visible = True
cb_cancel.Text = 'Cancel'
end event

type pb_calculator from picturebutton within w_disbursement_edit
integer x = 3872
integer y = 8
integer width = 110
integer height = 96
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean originalsize = true
string picturename = "Compute!"
alignment htextalign = left!
string powertiptext = "Disbursement Calculator"
end type

event clicked;OLEObject	lou_OLE
Integer 		li_rc
String      	ls_docPath

//*******************************************************
// Open  Factsheet Template:
//*******************************************************

Select description
Into	 :ls_docPath
From 	 gigp_reference
Where  category     = "template"
And    sub_category = "disburseCalculator"
And   ref_code = "disburseCalculator";


//*******************************************************
// Connect to MS Excel:
//*******************************************************

lou_OLE = CREATE OLEObject

If (lou_OLE.ConnectToObject('', 'Excel.Application') <> 0)  Then 	
	
	If (lou_OLE.ConnectToNewObject('Excel.Application') <> 0)  Then
		MessageBox("ERROR!", "Error opening Microsoft Excel.")
		Return 
	End If
	
End If

//iou_OLE.Visible = False

//*******************************************************
// Add document to oleobject:
//*******************************************************

lou_OLE.Workbooks.Open(ls_docPath)


lou_OLE.Visible = True

If IsValid(lou_OLE) Then lou_OLE.DisconnectObject()

end event

