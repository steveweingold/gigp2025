forward
global type n_cst_exec_disbursement_status_report from n_cst_report
end type
end forward

global type n_cst_exec_disbursement_status_report from n_cst_report
string dataobject = "d_exec_disbursement_status_rpt"
end type
global n_cst_exec_disbursement_status_report n_cst_exec_disbursement_status_report

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
Decimal ld_projectAmt, ld_award, ld_federal_amt, ld_state_amt
Decimal ld_requested, ld_eligible, ld_retained, ld_disbursed

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
	
	SELECT	isnull(sum(A.eligible_amt), 0) as eligible_amt,   
				isnull(sum(A.retained_amt), 0) as retained_amt,   
				isnull(sum(A.disbursed_amt), 0) as disbursed_amt 
	INTO		:ld_eligible, 
				:ld_retained,
				:ld_disbursed
	FROM		gigp_disbursement_request R left outer join gigp_disbursement_amount A on R.disbursement_id = A.disbursement_id
	WHERE  	(R.release_dt  >= :idt_begin and R.release_dt  <= :idt_end)
	AND      	R.gigp_id = :ll_gigpID;
	
	
	select sum(r.federal_amt), sum(r.state_amt)
	into :ld_federal_amt, :ld_state_amt
	from gigp_disbursement_request r
	where r.gigp_id = :ll_gigpID
	and r.release_dt between :idt_begin and :idt_end;
	
	If IsNull(ld_federal_amt) then ld_federal_amt = 0
	If IsNull(ld_state_amt) then ld_state_amt = 0
	
	This.SetItem(ll_row, 'cc_eligible', ld_eligible)		
	This.SetItem(ll_row, 'cc_disbursed', ld_disbursed)	
	This.SetItem(ll_row, 'cc_retained', ld_retained)	
	This.SetItem(ll_row, 'cc_netAvail', (ld_award - ld_eligible))
	This.SetItem(ll_row, 'cc_federalamt', ld_federal_amt)
	This.SetItem(ll_row, 'cc_stateamt', ld_state_amt)
	
	SetNull(ls_value)
	
	ld_projectAmt = 0
	ld_eligible = 0
	ld_retained = 0
	ld_disbursed = 0
	ld_federal_amt = 0
	ld_state_amt = 0
	
NEXT


end subroutine

public subroutine of_retrieve_report ();
Long 				ll_count, ll_rowCount, ll_RC
String				ls_program, ls_roundNo, ls_parm
Integer			li_program, li_roundNo, li_roundFlag
str_date_parm lstr_date_parm

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

//ll_rowCount =This.Retrieve(ls_program, li_program, li_roundNo, li_roundFlag, idt_begin, idt_end)
ll_rowCount =This.Retrieve(li_roundNo, li_roundFlag, idt_begin, idt_end)

end subroutine

public subroutine of_open_parm_window ();//Open(w_srfprogram_parms)
end subroutine

on n_cst_exec_disbursement_status_report.create
call super::create
end on

on n_cst_exec_disbursement_status_report.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

