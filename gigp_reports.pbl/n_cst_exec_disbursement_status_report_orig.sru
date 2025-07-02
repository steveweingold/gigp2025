forward
global type n_cst_exec_disbursement_status_report_orig from n_cst_report
end type
end forward

global type n_cst_exec_disbursement_status_report_orig from n_cst_report
string dataobject = "d_exec_disbursement_status_rpt"
end type
global n_cst_exec_disbursement_status_report_orig n_cst_exec_disbursement_status_report_orig

type variables

DateTime idt_begin, idt_end
end variables

forward prototypes
public subroutine of_post_retrieve_report ()
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_post_retrieve_report ();
Integer	N, li_value
Long 		ll_rowCnt, ll_row, ll_gigpID, ll_disburseCnt
String 	ls_value, ls_formattedProj

DateTime ldt_value, ldt_dummy, ldt_today

Decimal ld_projectAmt, ld_award

Decimal ld_requested, ld_ineligible, ld_withheld, ld_netrequest, ld_eligible, ld_localshare, ld_retained, ld_disbursed, ld_netAvail

ldt_dummy = DateTime(Date("01/01/1900"))
ldt_today  = f_getdbdatetime()

ll_rowCnt = This.RowCount()

If (ll_rowCnt < 1) Then Return


FOR ll_row = 1 TO ll_rowCnt
		
	ll_gigpID = This.GetItemNumber(ll_row, "gigp_id")	
	
	ls_value = f_get_applicant_name(ll_gigpID)
	This.SetItem(ll_row, 'cc_appname', ls_value)	
	
	ld_award = f_get_project_amount(ll_gigpID, "RECFR")	
	This.SetItem(ll_row, 'cc_award_amt', ld_award)
	
	ld_projectAmt = f_get_project_amount(ll_gigpID, "RECTPF")	
	This.SetItem(ll_row, 'cc_totalprojectamt', ld_projectAmt)
		
	Select checklist_value
	Into	:li_value
	From gigp_checklist
	Where  gigp_id = :ll_gigpID
	And ref_code = 'EDAPROJ';
		
	If IsNull(li_value) Then li_value = 0;
	
	If (li_value = 1) Then
		ls_value = "Yes"
	Else
		ls_value = "No"
	End If
	
	This.SetItem(ll_row,'cc_econdistressarea', ls_value)	
	
	
	ll_disburseCnt = 0
	
	SELECT 	count(Distinct R.disbursement_id)
	INTO 		:ll_disburseCnt
    	FROM		gigp_disbursement_amount A,   
	     		gigp_disbursement_request R 
	WHERE  	R.disbursement_id = A.disbursement_id
	AND       (R.release_dt >= :idt_begin and R.release_dt  <= :idt_end)
	AND        R.release_amt > 0
	AND      	R.gigp_id = :ll_gigpID;

	This.SetItem(ll_row, 'cc_disburseCnt', ll_disburseCnt)
	
	SELECT	isnull(sum(A.requested_amt), 0) as requested_amt,   
				isnull(sum(A.ineligible_amt), 0) as ineligible_amt ,  
				isnull(sum(A.withheld_amt), 0) as withheld_amt ,   
				isnull(sum(A.netrequest_amt), 0) as netrequested_amt,   
				isnull(sum(A.eligible_amt), 0) as eligible_amt,   
				isnull(sum(A.retained_amt), 0) as retained_amt,   
				isnull(sum(A.disbursed_amt), 0) as disbursed_amt 
	INTO		:ld_requested,
				:ld_ineligible,
				:ld_withheld,
				:ld_netrequest,
				:ld_eligible, 
				:ld_retained,
				:ld_disbursed
	FROM		gigp_disbursement_request R left outer join gigp_disbursement_amount A on R.disbursement_id = A.disbursement_id
	WHERE  	(R.release_dt  >= :idt_begin and R.release_dt  <= :idt_end)
	AND      	R.gigp_id = :ll_gigpID;
	
	This.SetItem(ll_row, 'cc_requested', ld_requested)
	This.SetItem(ll_row, 'cc_ineligible', ld_ineligible)
	This.SetItem(ll_row, 'cc_withheld', ld_withheld)
	This.SetItem(ll_row, 'cc_netrequest', ld_netrequest)
	This.SetItem(ll_row, 'cc_eligible', ld_eligible)		
	This.SetItem(ll_row, 'cc_localshare', (ld_netrequest - ld_eligible))	
	This.SetItem(ll_row, 'cc_retained', ld_retained)	
	This.SetItem(ll_row, 'cc_disbursed', ld_disbursed)	
	
	This.SetItem(ll_row, 'cc_netAvail', (ld_award - ld_eligible))	
	
	SetNull(ls_value)
	
	ld_projectAmt = 0
	ld_requested = 0
	ld_ineligible = 0
	ld_withheld = 0
	ld_netrequest = 0
	ld_eligible = 0
	ld_localshare = 0
	ld_retained = 0
	ld_disbursed = 0
	ld_netAvail = 0
	
NEXT


end subroutine

public subroutine of_retrieve_report ();
Long 				ll_count, ll_rowCount, ll_RC
String				ls_program, ls_roundNo, ls_parm
Integer			li_program, li_roundNo, li_roundFlag
str_date_parm lstr_date_parm

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
	Return
End If

//*************************************************************
// SRF Program:
//*************************************************************

ls_program = ids_parms.GetItemString(1, "prm_value")		

If (ls_program = "ALL") Then
	ls_program = "Dummy"
	li_program = 1
Else
	li_program = 0
End If	

//*************************************************************
// Round No:
//*************************************************************

Open(w_roundno_parm)

istr_parm = Message.PowerObjectParm
	
iblb_data = istr_parm.str_parm
	
ll_RC = ids_parms.SetFullState(iblb_data)

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then		
	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
	Return
	
Else
	ls_roundNo = ids_parms.GetItemString(1, "prm_value")

	If (ls_roundNo = "ALL") Then
		li_roundNo = 0
		li_roundFlag = 1
	Else
		li_roundNo = Integer(ls_roundNo)
		li_roundFlag = 0
	End If
	
End If

idt_begin = f_getdbdatetime()

idt_end = f_getdbdatetime()

//***************************
// Get Disbursement Date Range:
//***************************
	
SetNull(ls_parm)	

SELECT ref_value  
INTO :ls_parm
FROM gigp_reference  
WHERE	category 		= 'Program' 
AND 		sub_category 	= 'Round1'  
AND  		ref_code 		= 'startDate';
	
idt_begin = DateTime(Date(ls_parm))
idt_end= f_getdbdatetime()

SetNull(ls_parm)

lstr_date_parm.str_dateLabel1 = "Release Date >="
lstr_date_parm.str_dateLabel2 =  "Release Date <="
lstr_date_parm.str_dateValue1 = idt_begin
lstr_date_parm.str_dateValue2 = idt_end

OpenWithParm(w_date_parm, lstr_date_parm)

istr_parm = Message.PowerObjectParm
	
iblb_data = istr_parm.str_parm
	
ll_RC = ids_parms.SetFullState(iblb_data)

ll_count = ids_parms.RowCount()

If (ll_count <> 2) Then	
	// Nothing	
Else
	ls_parm = ids_parms.GetItemString(1, "prm_value")	
	idt_begin = DateTime(Date(Left(ls_parm,10)))	
	ls_parm = ids_parms.GetItemString(2, "prm_value")		
	idt_end = DateTime(Date(Left(ls_parm,10)))
	
End If

ll_rowCount =This.Retrieve(ls_program, li_program, li_roundNo, li_roundFlag, idt_begin, idt_end)

end subroutine

public subroutine of_open_parm_window ();
Open(w_srfprogram_parms)
end subroutine

on n_cst_exec_disbursement_status_report_orig.create
call super::create
end on

on n_cst_exec_disbursement_status_report_orig.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

