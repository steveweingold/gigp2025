forward
global type n_cst_disburse_by_costcat_report from n_cst_report
end type
end forward

global type n_cst_disburse_by_costcat_report from n_cst_report
string dataobject = "d_disburse_by_costcat_rpt"
end type
global n_cst_disburse_by_costcat_report n_cst_disburse_by_costcat_report

type variables
DateTime idt_begin, idt_end
String is_program, is_roundNo
Integer ii_program, ii_roundNo, ii_roundFlag
end variables

forward prototypes
public subroutine of_post_retrieve_report ()
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_post_retrieve_report ();
Long ll_row, ll_rowCnt, ll_gigpID

String ls_projNo, ls_formattedNo, ls_costcat

Decimal ld_costCatAmt, ld_eligible, ld_netAvail, ld_priorDisbursed, ld_priorRetained

ll_rowCnt = This.RowCount()

If (ll_rowCnt < 1) Then Return

FOR ll_row = 1 TO ll_rowCnt
			
	ll_gigpID = This.GetItemNumber(ll_row, "gigp_id")			
	ls_costcat  = This.GetItemString(ll_row, "cost_category")	
	ld_eligible = This.GetItemDecimal(ll_row, "eligible_amt")	
		

	//*************************************************************
	// Get Professional Contract Amount by Cost Category:
	//*************************************************************
	
	SELECT Sum(eligible_amt)
	INTO :ld_costCatAmt
    FROM gigp_professional_contracts  
   	WHERE gigp_id = :ll_gigpID
	AND contract_type = :ls_costcat
	AND eligible_amt > 0;
	
	If (IsNull(ld_costCatAmt)) Then ld_costCatAmt = 0
	
	
//	//*************************************************************
//	// Calc Previous Disbursement & Retainage Amounts:
//	//*************************************************************
//		
//	SELECT	isnull(sum(DA.retained_amt), 0) as retained_amt,   
//         		isnull(sum(DA.disbursed_amt), 0) as disbursed_amt 
//	INTO		:ld_priorDisbursed,
//				:ld_priorRetained						
//	FROM		gigp_disbursement_request DR,
//				gigp_disbursement_amount DA         	 
//	WHERE  	DR.gigp_id = :ll_gigpID
//	AND		DR.disbursement_id = DA.disbursement_id
//	AND		(DR.release_dt < :idt_begin)   
//	AND		DA.cost_category = :ls_costcat
//	AND        DR.release_dt is not null
//	AND       	DR.release_amt > 0;
//		
//	This.SetItem(ll_row, "cc_priorDisbursed", ld_priorDisbursed)
//	This.SetItem(ll_row, "cc_priorRetained", ld_priorRetained)	
//	
//	//*************************************************************
//	// Calc Net Available by Cost Category:
//	//*************************************************************
//	
//	This.SetItem(ll_row, "cc_costcatamt", ld_costCatAmt)
//	
//	ld_netAvail = (ld_costCatAmt - ld_eligible)	
//	
//	This.SetItem(ll_row, "cc_netavail", ld_netAvail)	
	ld_costCatAmt = 0
//	ld_eligible = 0
//	ld_netAvail = 0
//	ld_priorDisbursed = 0
//	ld_priorRetained = 0
	
NEXT


end subroutine

public subroutine of_retrieve_report ();
Long 				ll_count, ll_RC
String				ls_parm
str_date_parm lstr_date_parm

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
	Return
End If

//*************************************************************
// SRF Program:
//*************************************************************

is_program = ids_parms.GetItemString(1, "prm_value")		

If (is_program = "ALL") Then
	is_program = "Dummy"
	ii_program = 1
Else
	ii_program = 0
End If	

//*************************************************************
// Round No.
//*************************************************************
//Open(w_roundno_parm)
//
//istr_parm = Message.PowerObjectParm
//	
//iblb_data = istr_parm.str_parm
//	
//ll_RC = ids_parms.SetFullState(iblb_data)
//
//ll_count = ids_parms.RowCount()
//
//If (ll_count <> 1) Then		
//	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
//	Return
//	
//Else
//	is_roundNo = ids_parms.GetItemString(1, "prm_value")
//
//	If (is_roundNo = "ALL") Then
//		ii_roundNo = 0
//		ii_roundFlag = 1
//	Else
//		ii_roundNo = Integer(is_roundNo)
//		ii_roundFlag = 0
//	End If
//	
//End If

//***************************
// Get Disbursement Date Range:
//***************************
	
SetNull(ls_parm)	

//SELECT ref_value  
//INTO :ls_parm
//FROM gigp_reference  
//WHERE	category 			= 'Program' 
//AND 		sub_category 	= 'Round1'  
//AND  		ref_code 		= 'startDate';
//	
//idt_begin = DateTime(Date(ls_parm))

idt_end= f_getdbdatetime()
idt_begin = DateTime(RelativeDate(Date(idt_end), -7))

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

//*************************************************************
// Get Round Numbers:
//*************************************************************
this.of_getmultiplerounds()


This.Retrieve(is_program, ii_program, ii_round, is_roundlist, idt_begin, idt_end)

end subroutine

public subroutine of_open_parm_window ();
Open(w_srfprogram_parms)
end subroutine

on n_cst_disburse_by_costcat_report.create
call super::create
end on

on n_cst_disburse_by_costcat_report.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

