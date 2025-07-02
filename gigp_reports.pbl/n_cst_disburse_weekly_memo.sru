forward
global type n_cst_disburse_weekly_memo from n_cst_report
end type
end forward

global type n_cst_disburse_weekly_memo from n_cst_report
string dataobject = "d_comp_disburse_weekly_memo"
end type
global n_cst_disburse_weekly_memo n_cst_disburse_weekly_memo

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();Long 			ll_count, ll_Cnt, N, ll_gigpID, ll_newRow, ll_disbursementID, ll_requestNo, ll_RC, ll_tx_count, ll_rr_count
long 			ll_round, ll_cfa, ll_space
Boolean		lb_state
Integer		li_arra, li_retrel
String			ls_parm, ls_disburseIDs[], ls_appjName, ls_projNo, ls_formattedProj, ls_srfProgram, ls_cwAcctNo, ls_dwAcctNo, ls_stateAcctNo, ls_ecfund, ls_extract
String			ls_names_Amt, ls_date, ls_acctNo, ls_grantsource, ls_round, ls_admin_acct_no, ls_stateProjs, ls_program, ls_state_grantsource, ls_non_state_grantsource, ls_projectname
String			ls_septicAcctNo, ls_wqiAcctNo, ls_osgAcctNo
Decimal 		ld_Amt, ld_federal, ld_state
DateTime	ldt_dummy, ldt_releaseDt, ldt_memoDt
datawindowchild 	ldwc_report
str_date_parm lstr_date_parm
n_cst_string	lu_string

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
	Return
End If
	
ldt_dummy = DateTime('1/1/1900 00:00:00')	
ls_parm = ids_parms.GetItemString(1, "prm_value")		
ll_Cnt = lu_string.of_parsetoarray(ls_parm, ",", ls_disburseIDs)


//***************************
// Get Memo Date:
//***************************
SetNull(ls_parm)	
	
ldt_memoDt = f_getdbdatetime()

lstr_date_parm.str_dateLabel1 ="Memo Date ="
lstr_date_parm.str_dateLabel2 =  "None"
lstr_date_parm.str_dateValue1 = ldt_memoDt

OpenWithParm(w_date_parm, lstr_date_parm)	

istr_parm = Message.PowerObjectParm
	
iblb_data = istr_parm.str_parm
	
ll_RC = ids_parms.SetFullState(iblb_data)

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	// Nothing	
Else
	ls_parm = ids_parms.GetItemString(1, "prm_value")	

	ls_parm = ids_parms.GetItemString(1, "prm_value")		
	ldt_memoDt = DateTime(Date(Left(ls_parm,10)))
	
End If

//***************************
// Get M&T Account Bank Info:
//***************************
Select description
Into :ls_cwAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'CW Unallocated';

Select description
Into :ls_dwAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'DW Unallocated';

Select description
Into :ls_admin_acct_no
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'Administrative Expense Account';

Select description
Into :ls_stateAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'State Money';

//Get State Grant Source
Select description
into :ls_state_grantsource
from gigp_reference
where category = 'GrantSource'
and sub_category = 'State';

//Get WQI Account
Select description
Into :ls_wqiAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'WQI Account No';

//Get Septic Account
Select description
Into :ls_septicAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'Septic Account No';

//Get OSG Account
Select description
Into :ls_osgAcctNo
From gigp_reference
Where category = 'Disbursement'
And sub_category = 'OSG Account No';


//*************************************************************
// Loop to get Project / Disbursement Info for selected Disbursements:
//*************************************************************
This.getchild("dw_detail", ldwc_report)

FOR N = 1 TO ll_Cnt
	
	ll_newRow = ldwc_report.InsertRow(0)	
	
	ll_disbursementID = Integer(ls_disburseIDs[N])
	
	//*************************************************************
	// Get Disbursement info:
	//*************************************************************
	Select 	R.gigp_id, R.request_no, R.release_dt,
				disb_amt = (select Sum(disbursed_amt)
								from gigp_disbursement_amount
								where disbursement_id = R.disbursement_id),
				R.federal_amt, R.state_amt
	Into		:ll_gigpID, :ll_requestNo, :ldt_releaseDt, :ld_Amt, :ld_federal, :ld_state
	From		gigp_disbursement_request R
   	Where 	R.disbursement_id = :ll_disbursementID;
		
	//*************************************************************
	//Determine if State Money (SW, 1/2019):  2/2019 - changed to split for all Round 9+ 
	//2/2019 - get Federal / State split
	//If this disbursement is split then do state first and then handle federal in another line
	//*************************************************************
	If ld_state > 0 Then
		ld_Amt = ld_state
	End If
	
	//*************************************************************
	// Get Project info:
	//*************************************************************
	select a.round_no, a.cfa_no, a.project_no, a.srf_program, convert(char, a.round_no), a.program
	into :ll_round, :ll_cfa, :ls_projNo, :ls_srfProgram, :ls_round, :ls_program
	from gigp_application a
	where gigp_id = :ll_gigpID;
	
	ldwc_report.SetItem(ll_newRow, 'program', ls_program)
	
	ls_formattedProj = ls_projNo
	
	If ls_round = '1' Then
		li_arra = 1
	Else
		li_arra = 0
	End If

	//*************************************************************
	// Get Applicant info: (Add the ID in the Project Name for REDI, 3/2024
	//*************************************************************
	ls_appjName = f_get_applicant_name(ll_gigpID)
	If IsNull(ls_appjName) Then ls_appjName = ""
	
	If ls_program = 'REDI' Then
		select project_name
		into :ls_projectname
		from gigp_application
		where gigp_id = :ll_gigpID;
		
		If IsNull(ls_projectname) Then ls_projectname = ''
		ll_space = Pos(ls_projectname, ' ')
		
		If ll_space > 0 Then
			ls_appjName += ' (' + Left(ls_projectname, ll_space -1) + ')'
		End If
	End If
	
	//*************************************************************
	//Determine if Retainage Release (ALL transactions in that DR):
	//*************************************************************
	ll_tx_count = 0
	ll_rr_count = 0
	
	select count(*)
	into :ll_tx_count
	from gigp_disbursement_amount
	where disbursement_id = :ll_disbursementID;
	
	If ll_tx_count > 0 Then
		select count(*)
		into :ll_rr_count
		from gigp_disbursement_amount
		where disbursement_id = :ll_disbursementID
		and transaction_type = 'RELRET';
		
		If ll_tx_count = ll_rr_count Then
			li_retrel = 1
		Else
			li_retrel = 0
		End If
	End If
	
	//***************************
	// Grant Source:
	//***************************
	Select description
	into :ls_non_state_grantsource
	from gigp_reference
	where category = 'GrantSource'
	and sub_category = :ls_srfProgram
	and ref_code = :ls_round;
	
	Select description
	Into :ls_ecfund
	From gigp_reference
	Where category = 'Disbursement'
	And sub_category = 'DW EC Fund';
	
	If IsNull(ls_non_state_grantsource) Then ls_non_state_grantsource = ''
	
	If ld_state > 0 Then
		ls_grantsource = ls_state_grantsource
	Else
		ls_grantsource = ls_non_state_grantsource
	End If
	
	Choose Case ls_program	//Updated for WQI & Septic, SW 8/2022
		Case 'PPG-EC'	//SW, 3/2020
			select description
			into :ls_grantsource
			from gigp_reference
			where category = 'GrantSource'
			and sub_category = :ls_program
			and ref_code = :ls_round;
			
		Case 'WQI'
			select description
			into :ls_grantsource
			from gigp_reference
			where category = 'GrantSource'
			and sub_category = 'WQI';
			
		Case 'Septic'
			select description
			into :ls_grantsource
			from gigp_reference
			where category = 'GrantSource'
			and sub_category = 'Septic';
		
		Case 'OSG'
			select description
			into :ls_grantsource
			from gigp_reference
			where category = 'GrantSource'
			and sub_category = 'OSG';
		
	End Choose
	
	
	//*************************************************************
	// Determine Bank Account Number
	//*************************************************************
	ls_acctNo = ''
	
	Choose Case ls_program
		Case 'EPG'
			ls_acctNo = ls_admin_acct_no
		Case 'PPG-EC'	//SW, 3/2020
			ls_acctNo = ls_ecfund
		Case 'WQI'		//SW, 8/2022
			ls_acctNo = ls_wqiAcctNo
		Case 'Septic'	//SW, 8/2022
			ls_acctNo = ls_septicAcctNo
		Case 'OSG'	//SW, 8/2022
			ls_acctNo = ls_osgAcctNo
		Case Else	//GIGP
			If ls_srfProgram = 'CW' Then
				If ld_state > 0 Then
					ls_acctNo = ls_stateAcctNo
				Else
					ls_acctNo = ls_cwAcctNo
				End If
			Else
				ls_acctNo = ls_dwAcctNo
			End If
	End Choose
	
	////////////////////////////////////////////////////////////////////////////////////////////////
	//One-off exception for WQI Mt Vernon as per Angela. If becomes more, implement an exception by GIGP Id in the gigp_reference
	If ll_gigpID = 2144 Then
		ls_acctNo = ls_admin_acct_no
	End If
	////////////////////////////////////////////////////////////////////////////////////////////////
	

	//*************************************************************
	// Set report data:
	//*************************************************************
	ldwc_report.SetItem(ll_newRow, 'gigp_id', ll_gigpID)
	ldwc_report.SetItem(ll_newRow, 'disbursement_id', ll_disbursementID)
	ldwc_report.SetItem(ll_newRow, 'request_no', String(ll_requestNo))
	ldwc_report.SetItem(ll_newRow, 'disburse_amt', ld_Amt)
	ldwc_report.SetItem(ll_newRow, 'round_no', ll_round)
	ldwc_report.SetItem(ll_newRow, 'cfa_no', ll_cfa)
	ldwc_report.SetItem(ll_newRow, 'recipient', ls_appjName)	
	ldwc_report.SetItem(ll_newRow, 'project_no', ls_formattedProj)	
	ldwc_report.SetItem(ll_newRow, 'srf_program', ls_srfProgram)
	ldwc_report.SetItem(ll_newRow, 'arra_flag', li_arra)
	ldwc_report.SetItem(ll_newRow, 'retrel', li_retrel)
	ldwc_report.SetItem(ll_newRow, 'grant_source', ls_grantsource)
		
	If (Not (IsNull(ldt_releaseDt))) And (ldt_releaseDt <> ldt_dummy) Then					
			ldwc_report.SetItem(ll_newRow, 'release_dt', ldt_releaseDt)		
	End If
	
	If (Not (IsNull(ldt_memoDt))) And (ldt_memoDt <> ldt_dummy) Then		
		ldwc_report.SetItem(ll_newRow, 'memo_dt', ldt_memoDt)		
	End If
	
	ldwc_report.SetItem(ll_newRow, 'recip_acct_no', ls_acctNo)		
	ldwc_report.SetItem(ll_newRow, 'cw_acct_no', ls_cwAcctNo)
	
//	ldwc_report.SetItem(ll_newRow, 'dw_acct_no', ls_dwAcctNo)
	ldwc_report.SetItem(ll_newRow, 'dw_acct_no', ls_ecfund)	//SW, 3/2020
	
	ldwc_report.SetItem(ll_newRow, 'admin_acct_no', ls_admin_acct_no)
	ldwc_report.SetItem(ll_newRow, 'state_acct_no', ls_stateAcctNo)
	ldwc_report.SetItem(ll_newRow, 'wqi_acct_no', ls_wqiAcctNo)		//SW, 8/2022
	ldwc_report.SetItem(ll_newRow, 'septic_acct_no', ls_septicAcctNo)	//SW, 8/2022
	ldwc_report.SetItem(ll_newRow, 'osg_acct_no', ls_osgAcctNo)	//SW, 8/2022

	
	//If money split for this disbursement between Federal and State then insert a second line for the Federal Amount
	If ld_federal > 0 and ld_state > 0 Then
		ll_newRow = ldwc_report.InsertRow(0)	
		ll_disbursementID = Integer(ls_disburseIDs[N])
		
		//Do the Federal amount now
		ld_Amt = ld_federal
		ls_acctNo = ls_cwAcctNo
		ls_grantsource = ls_non_state_grantsource
		
		//Insert values
		ldwc_report.SetItem(ll_newRow, 'program', ls_program)
		
		ldwc_report.SetItem(ll_newRow, 'gigp_id', ll_gigpID)
		ldwc_report.SetItem(ll_newRow, 'disbursement_id', ll_disbursementID)
		ldwc_report.SetItem(ll_newRow, 'request_no', String(ll_requestNo))
		ldwc_report.SetItem(ll_newRow, 'disburse_amt', ld_Amt)
		ldwc_report.SetItem(ll_newRow, 'round_no', ll_round)
		ldwc_report.SetItem(ll_newRow, 'cfa_no', ll_cfa)
		ldwc_report.SetItem(ll_newRow, 'recipient', ls_appjName)	
		ldwc_report.SetItem(ll_newRow, 'project_no', ls_formattedProj)	
		ldwc_report.SetItem(ll_newRow, 'srf_program', ls_srfProgram)
		ldwc_report.SetItem(ll_newRow, 'arra_flag', li_arra)
		ldwc_report.SetItem(ll_newRow, 'retrel', li_retrel)
		ldwc_report.SetItem(ll_newRow, 'grant_source', ls_grantsource)
			
		If (Not (IsNull(ldt_releaseDt))) And (ldt_releaseDt <> ldt_dummy) Then					
				ldwc_report.SetItem(ll_newRow, 'release_dt', ldt_releaseDt)		
		End If
		
		If (Not (IsNull(ldt_memoDt))) And (ldt_memoDt <> ldt_dummy) Then		
			ldwc_report.SetItem(ll_newRow, 'memo_dt', ldt_memoDt)		
		End If
		
		ldwc_report.SetItem(ll_newRow, 'recip_acct_no', ls_acctNo)		
		
		
	End If
		
NEXT

//***************************
//Export the data for Rob H.
//***************************
select description
into :ls_extract
from gigp_reference
where category = 'WeeklyDisburse'
and sub_category = 'ExtractLocation';

If ls_extract >  '' Then
	ldwc_report.SaveAs(ls_extract, XLSX!,true)
End If


//***************************
// Retrieve Memo Header:
//***************************

This.getchild("dw_header", ldwc_report)

ldwc_report.SetTransObject(SQLCA)

ldwc_report.Retrieve(ldt_releaseDt, ldt_memoDt)

end subroutine

public subroutine of_open_parm_window ();
Open(w_disburse_releasedate_parms)
end subroutine

on n_cst_disburse_weekly_memo.create
call super::create
end on

on n_cst_disburse_weekly_memo.destroy
call super::destroy
end on

