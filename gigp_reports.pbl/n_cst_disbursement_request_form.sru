forward
global type n_cst_disbursement_request_form from n_cst_report
end type
end forward

global type n_cst_disbursement_request_form from n_cst_report
string dataobject = "d_disbursement_request_form"
end type
global n_cst_disbursement_request_form n_cst_disbursement_request_form

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();Long 		ll_count, ll_gigpID, ll_newRow, ll_roundNo, ll_contactID, ll_profKID, ll_cfa_no
Long		ll_lastRequest, ll_nextRequest, ll_nextRequest2, ll_RC, ll_lastDisbID

Integer	li_sort

DateTime ldt_notrec, ldt_lastrec

String		ls_parm, ls_appjName, ls_projNo, ls_formattedProj, ls_projName, ls_appName, ls_costCategory, ls_last, ls_comments, ls_program, ls_programname

Decimal 	ld_awardAmt, ld_contractAmt, ld_paidtodate, ld_temp, ld_eligible_pct, ld_netrequest

Decimal	ld_netRequestLast, ld_netRequestCum, ld_eligibleLast, ld_eligibleCum, ld_retainedLast, ld_retainedCum
Decimal  ld_retreleaseLast, ld_retreleaseCum, ld_disbursedLast, ld_disbursedCum, ld_costRequestedLast, ld_deductionsLast

DateTime ldt_date, ldt_dummy

ldt_dummy = DateTime('1/1/1900 00:00:00')	

//*************************************************************
// Get Report Parm - Selected GIGP project:
//*************************************************************

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	MessageBox('ERROR!', 'Error processing report parms - See I.T.!')
	Return
End If
	
ls_parm = ids_parms.GetItemString(1, 'prm_value')	

ll_gigpID = Integer(ls_parm)


//*************************************************************
// Determine next Request No. & allow user to change:
//*************************************************************

Select Count(*)
Into :ll_nextRequest
From gigp_disbursement_request 
Where gigp_id = :ll_gigpID;

If IsNull(ll_nextRequest) Then ll_nextRequest = 0

ll_nextRequest++

OpenWithParm(w_requestno_parms, String(ll_nextRequest))

istr_parm = Message.PowerObjectParm
	
iblb_data = istr_parm.str_parm
	
ll_RC = ids_parms.SetFullState(iblb_data)

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	
	// Do nothing - Leave system generated Request No as is.
	
Else
	ls_parm = ids_parms.GetItemString(1, 'prm_value')	

	ll_nextRequest2 = Integer(ls_parm)
		
	If (ll_nextRequest <> ll_nextRequest2) Then
		ll_nextRequest = ll_nextRequest2		
	End If
	
End If

//*************************************************************
// Project Info:
//*************************************************************

Select		project_no,
			project_name,
			round_no,
			eligible_pct,
			cfa_no,
			program
Into 		:ls_projNo,
			:ls_projName,
			:ll_roundNo,
			:ld_eligible_pct,
			:ll_cfa_no,
			:ls_program
From 		gigp_application 
Where gigp_id = :ll_gigpID;

ls_formattedProj = ls_projNo

//*************************************************************
// Applicant Name:
//*************************************************************

Select		C.organization			
Into		:ls_appjName
FROM		gigp_contacts C,   
			gigp_contact_links CL  
WHERE 	C.contact_id = CL.contact_id    
AND		CL.gigp_id = :ll_gigpID
AND      	CL.contact_type = 'APP';

If IsNull(ls_appjName) Then ls_appjName = ''	


//*************************************************************
// Program Name:
//*************************************************************
Choose Case ls_program
	Case 'GIGP'
		ls_programname = 'Green Innovation Grant Program'
		
	Case 'EPG'
		ls_programname = 'Engineering Planning Grant Program'
		
	Case 'OSG'
		ls_programname = 'Sewer Overflow and Stormwater Reuse Municipal Grant Program'
		
	Case Else
		ls_programname = '[UNKNOWN PROGRAM TO THIS REPORT. CONTACT IT]'
		
End Choose


		
//*************************************************************
// Contract Amount:
//*************************************************************

ld_awardAmt = f_get_project_amount(ll_gigpID, 'RECFR')

//*************************************************************
// Get Last  Request No:
//*************************************************************

Select Max(disbursement_id) 
Into	:ll_lastDisbID
From gigp_disbursement_request  
Where gigp_id = :ll_gigpID;

Select request_no, received_dt
Into:ll_lastRequest, :ldt_lastrec
From gigp_disbursement_request  
Where gigp_id = :ll_gigpID
And  disbursement_id = :ll_lastDisbID;

If (ll_lastRequest = 0) Then	
	ls_last = ''
Else	
	ls_last = String(ll_lastRequest)
End IF

//*************************************************************
// Get Last  Request Comments:
//*************************************************************

Select comments
Into:ls_comments
From gigp_disbursement_request  
Where gigp_id = :ll_gigpID
And  disbursement_id = :ll_lastDisbID;

//*************************************************************
// Get Requested for Last Request:
//*************************************************************

Select		Sum(requested_amt)
Into 		:ld_costRequestedLast
From	 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And  		disbursement_id = :ll_lastDisbID
And 		transaction_type in ('DISBURSE');

If IsNull(ld_costRequestedLast) Then ld_costRequestedLast = 0


//*************************************************************
// Get Deductions for Last Request:
//  - Ineligible + Withheld + Request Amount for Adjust Entries
//*************************************************************

Select		Sum(ineligible_amt + withheld_amt)
Into 		:ld_deductionsLast
From	 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And  		disbursement_id = :ll_lastDisbID
And 		transaction_type in ('DISBURSE');

If IsNull(ld_deductionsLast) Then ld_deductionsLast = 0

Select		Sum(requested_amt)
Into 		:ld_temp
From	 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And  		disbursement_id = :ll_lastDisbID
And 		transaction_type in ('ADJUST');

If IsNull(ld_temp) Then ld_temp = 0

ld_deductionsLast += ld_temp

//*************************************************************
// Get Net Requested for Last Request & Cumulative:
//*************************************************************

Select		Sum(netrequest_amt)
Into 		:ld_netRequestLast
FROM 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And  		disbursement_id = :ll_lastDisbID
And 		transaction_type in ('DISBURSE', 'ADJUST');

If IsNull(ld_netRequestLast) Then ld_netRequestLast = 0

Select 	Sum(netrequest_amt)
Into 		:ld_netRequestCum
FROM 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And 		transaction_type in ('DISBURSE', 'ADJUST');

If IsNull(ld_netRequestCum) Then ld_netRequestCum = 0

//*************************************************************
// Get Eligible Amount for Last Request & Cumulative:
//*************************************************************

Select		Sum(eligible_amt)
Into 		:ld_eligibleLast
FROM 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And  		disbursement_id = :ll_lastDisbID
And 		transaction_type in ('DISBURSE', 'ADJUST');

If IsNull(ld_eligibleLast) Then ld_eligibleLast = 0

Select 	Sum(eligible_amt)
Into 		:ld_eligibleCum
FROM 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And 		transaction_type in ('DISBURSE', 'ADJUST');

If IsNull(ld_eligibleCum) Then ld_eligibleCum = 0


//*************************************************************
// Get Retained Amount for Last Request & Cumulative:
//*************************************************************

Select		Sum(retained_amt)
Into 		:ld_retainedLast
FROM 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And  		disbursement_id = :ll_lastDisbID
And 		transaction_type in ('DISBURSE', 'ADJUST');

If IsNull(ld_retainedLast) Then ld_retainedLast = 0

Select 	Sum(retained_amt)
Into 		:ld_retainedCum
FROM 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And 		transaction_type in ('DISBURSE', 'ADJUST');

If IsNull(ld_retainedCum) Then ld_retainedCum = 0


//*************************************************************
// Get Retained Released Amount for Last Request & Cumulative:
//*************************************************************

Select		Sum(disbursed_amt)
Into 		:ld_retreleaseLast
FROM 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And  		disbursement_id = :ll_lastDisbID
And 		transaction_type = 'RELRET';

If IsNull(ld_retreleaseLast) Then ld_retreleaseLast = 0

Select 	Sum(disbursed_amt)
Into 		:ld_retreleaseCum
FROM 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And 		transaction_type = 'RELRET';

If IsNull(ld_retreleaseCum) Then ld_retreleaseCum = 0

//*************************************************************
// Get Disbursed Amount for Last Request & Cumulative:
//*************************************************************

Select		Sum(disbursed_amt)
Into 		:ld_disbursedLast
FROM 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And  		disbursement_id = :ll_lastDisbID
And 		transaction_type in ('DISBURSE', 'ADJUST');

If IsNull(ld_disbursedLast) Then ld_disbursedLast = 0

Select 	Sum(disbursed_amt)
Into 		:ld_disbursedCum
FROM 	gigp_disbursement_amount    
Where 	gigp_id = :ll_gigpID
And 		transaction_type in ('DISBURSE', 'ADJUST');

If IsNull(ld_disbursedCum) Then ld_disbursedCum = 0

//*************************************************************
// Get Professional Contracts for selected project:
//*************************************************************

//DECLARE cProfKs CURSOR FOR
//		SELECT	PC.contract_type,        
//         				PC.contact_id,   
//					PC.profess_contract_id,
//         				Sum(PC.eligible_amt) as cc_contract_amt
//		FROM 	gigp_professional_contracts PC
//		WHERE 	PC.gigp_id = :ll_gigpID		
//		GROUP BY	PC.contract_type,        
//         				PC.contact_id,   
//					PC.profess_contract_id;
					

//***6/2013, SW added					
					
DECLARE cProfKs CURSOR FOR
		SELECT	PC.contract_type,        
         				PC.contact_id,   
					PC.profess_contract_id,
         				Sum(PC.eligible_amt) as cc_contract_amt
		FROM 	gigp_professional_contracts PC
		WHERE 	PC.gigp_id = :ll_gigpID
		AND		PC.contract_type <> 'Contingency'
		and		pc.mwbe_review_flag <> 1
		and		pc.contract_status = 'ACTIVE'
		GROUP BY	PC.contract_type,        
         				PC.contact_id,   
					PC.profess_contract_id;
					
					
						
OPEN cProfKs;
	
FETCH cProfKs INTO :ls_costCategory, :ll_contactID, :ll_profKID, :ld_contractAmt;
	
DO WHILE SQLCA.sqlcode = 0		
		
	ll_newRow = This.InsertRow(0)		
		
	//*************************************************************
	// Set basic Project & Request Info:
	//*************************************************************
	If ll_roundNo < 100 Then	
		This.SetItem(ll_newRow, 'gigp_id', ll_gigpID)
	Else
		This.SetItem(ll_newRow, 'gigp_id', ll_cfa_no)
	End If
	
	This.SetItem(ll_newRow, 'project_no', ls_formattedProj)
	This.SetItem(ll_newRow, 'project_name', ls_projName)
	This.SetItem(ll_newRow, 'program', ls_program)
	This.SetItem(ll_newRow, 'programname', ls_programname)
	This.SetItem(ll_newRow, 'round_no', ll_roundNo)
	This.SetItem(ll_newRow, 'eligible_pct', ld_eligible_pct)
	This.SetItem(ll_newRow, 'applicant_name', ls_appjName)		
	This.SetItem(ll_newRow, 'contract_amt', ld_awardAmt)
	This.SetItem(ll_newRow, 'request_no', String(ll_nextRequest))		
	This.SetItem(ll_newRow, 'last_request_no', ls_last)		
	
	
	//*************************************************************
	// Set Not To Be Received Date:
	//*************************************************************
	If NOT IsNull(ldt_lastrec) and ldt_lastrec > DateTime(Date('1/1/1900')) Then
		ldt_notrec = Datetime(RelativeDate(Date(ldt_lastrec),30))
	Else
		ldt_notrec = DateTime(Date('1/1/1900'))
	End If
	
	This.SetItem(ll_newRow, 'not_rec_before_dt', ldt_notrec)
	
	//*************************************************************
	// Set Professional Contract Info:
	//*************************************************************
		
	This.SetItem(ll_newRow, 'cost_category', ls_costCategory)	
	This.SetItem(ll_newRow, 'contact_id',ll_contactID)		
	This.SetItem(ll_newRow, 'approved_amt', ld_contractAmt)			
	
	//Netrequested Amount - 5/2012, SW
	ld_netrequest = 0
	
	Select Sum(netrequest_amt)
	Into :ld_netrequest
	From gigp_disbursement_amount
	Where gigp_id = :ll_gigpID
	And professional_contract_id = :ll_profKID;
//	And transaction_type in ( 'DISBURSE', 'ADJUST');
	
	This.SetItem(ll_newRow, 'netrequest_amt', ld_netrequest)
	
		
	Select Sum(eligible_amt)
	Into :ld_paidtodate
	From gigp_disbursement_amount
	Where gigp_id = :ll_gigpID
	And professional_contract_id = :ll_profKID
	And transaction_type in ( 'DISBURSE', 'ADJUST');
	
	If (IsNull(ld_paidtodate)) Then ld_paidtodate = 0
	
	This.SetItem(ll_newRow, 'paidtodate_amt', ld_paidtodate)

	This.SetItem(ll_newRow, 'available_amt', (ld_contractAmt - ld_paidtodate))
	
	//*************************************************************
	// Set Category Sort Order:
	//*************************************************************
	
	Select sort_order
	Into  :li_sort
	From gigp_reference
	Where category = 'budgetAmount'
	And sub_category = :ls_costCategory;
	
	This.SetItem(ll_newRow, 'category_sort', li_sort)		
	
	//*************************************************************
	// Re-initialize Variables:
	//*************************************************************	
		
	ls_costCategory = ''
	ll_contactID = 0
	ll_profKID = 0
	ld_contractAmt = 0
	ld_paidtodate = 0
	li_sort = 0
			
	FETCH cProfKs INTO :ls_costCategory, :ll_contactID, :ll_profKID, :ld_contractAmt;
	
LOOP
	
CLOSE cProfKs;	

This.Sort()

//*************************************************************
// Set Summary Totals & Comments:
//*************************************************************
	
ll_count = This.RowCount()

If (ll_count > 0) Then
	
	This.SetItem(ll_count, 'last_costrequested_amt', ld_costRequestedLast)	
	This.SetItem(ll_count, 'last_deductions_amt', ld_deductionsLast)		
	
	This.SetItem(ll_count, 'last_netrequested_amt', ld_netRequestLast)	
	This.SetItem(ll_count, 'tot_netrequested_amt', ld_netRequestCum)	
	
	This.SetItem(ll_count, 'last_eligible_amt', ld_eligibleLast)	
	This.SetItem(ll_count, 'tot_eligible_amt', ld_eligibleCum)	
	
	This.SetItem(ll_count, 'last_retained_amt', ld_retainedLast)	
	This.SetItem(ll_count, 'tot_retained_amt', ld_retainedCum)
	
	This.SetItem(ll_count, 'last_retained_rel_amt', ld_retreleaseLast)	
	This.SetItem(ll_count, 'tot_retained_rel_amt', ld_retreleaseCum)
	
	This.SetItem(ll_count, 'last_disbursed_amt', ld_disbursedLast)	
	This.SetItem(ll_count, 'tot_disbursed_amt', ld_disbursedCum)
	
	This.SetItem(ll_count, 'comments', ls_comments)	
End If
end subroutine

public subroutine of_open_parm_window ();
OpenWithParm(w_project_select, "SINGLE")
end subroutine

on n_cst_disbursement_request_form.create
call super::create
end on

on n_cst_disbursement_request_form.destroy
call super::destroy
end on

