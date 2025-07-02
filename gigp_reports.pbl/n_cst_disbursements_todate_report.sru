forward
global type n_cst_disbursements_todate_report from n_cst_report
end type
end forward

global type n_cst_disbursements_todate_report from n_cst_report
string dataobject = "d_disbursements_todate_rpt"
end type
global n_cst_disbursements_todate_report n_cst_disbursements_todate_report

type variables

DateTime idt_begin, idt_end
end variables

forward prototypes
public subroutine of_post_retrieve_report ()
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
public subroutine of_retrieve_report_old ()
end prototypes

public subroutine of_post_retrieve_report ();Integer	N, li_value
Long 		ll_rowCnt, ll_row, ll_gigpID, ll_invoicecount
String 	ls_value, ls_formattedProj

DateTime ldt_value, ldt_dummy, ldt_today

Decimal ld_award,  ld_disbursed

Decimal  ld_disbPct

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
	
	//Get total disbursed
	SELECT	isnull(sum(A.disbursed_amt), 0) 
	INTO		:ld_disbursed
	FROM		gigp_disbursement_request R left outer join gigp_disbursement_amount A on R.disbursement_id = A.disbursement_id
	WHERE  	(R.release_dt  >= :idt_begin and R.release_dt  <= :idt_end)
	AND        R.release_amt <> 0
	AND      	R.gigp_id = :ll_gigpID;
	
	//Get count of invoices
	SELECT	isnull(count(A.disbursed_amt), 0) 
	INTO		:ll_invoicecount
	FROM		gigp_disbursement_request R left outer join gigp_disbursement_amount A on R.disbursement_id = A.disbursement_id
	WHERE  	(R.release_dt  >= :idt_begin and R.release_dt  <= :idt_end)
	AND        R.release_amt <> 0
	AND      	R.gigp_id = :ll_gigpID;
	
	This.SetItem(ll_row, 'cc_disbursed', ld_disbursed)	
	This.SetItem(ll_row, 'cc_invcount', ll_invoicecount)	
	
	If ld_award > 0 Then
		//ld_disbPct = Round((ld_disbursed / ld_award) * 100, 2)
		ld_disbPct = ld_disbursed / ld_award
	Else
		ld_disbPct = 0
	End If
	
	This.SetItem(ll_row, 'cc_disbpct', ld_disbPct)	
	
	SetNull(ls_value)	
	
	ld_award = 0	
	ld_disbursed = 0
	ld_disbPct = 0
	
	ld_award = f_get_project_amount(ll_gigpID, "RECTPF")	
	This.SetItem(ll_row, 'cc_tpf_amt', ld_award)
	
	SELECT	isnull(sum(A.netrequest_amt), 0) 
	INTO		:ld_disbursed
	FROM		gigp_disbursement_request R left outer join gigp_disbursement_amount A on R.disbursement_id = A.disbursement_id
	WHERE  	R.release_amt > 0
	AND      	R.gigp_id = :ll_gigpID;
	
	This.SetItem(ll_row, 'cc_netrequest', ld_disbursed)	
	
	If ld_award > 0 Then
		//ld_disbPct = Round((ld_disbursed / ld_award) * 100, 2)
		ld_disbPct = ld_disbursed / ld_award
	Else
		ld_disbPct = 0
	End If
	
	This.SetItem(ll_row, 'cc_netreqpct', ld_disbPct)	
	
	ld_award = 0	
	ld_disbursed = 0
	ld_disbPct = 0
	
NEXT


end subroutine

public subroutine of_retrieve_report ();Long 				ll_count, ll_rowCount, ll_RC
String				ls_fundingrec, ls_program, ls_recommendations[],  ls_status, ls_roundNo, ls_projstatus, ls_epgprogram
Integer			li_fundingrec, li_program,  li_status, li_roundNo, li_roundFlag
String				ls_parm
n_cst_string		lu_string
str_date_parm lstr_date_parm


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
// Funding Recommendation:
//*************************************************************

ls_fundingrec = ids_parms.GetItemString(2, "prm_value")		

If (ls_fundingrec = "ALL") Then
	ls_fundingrec = "Dummy"	
	lu_string.of_parsetoarray(ls_fundingrec, ",", ls_recommendations)	
	li_fundingrec = 1
Else
	lu_string.of_parsetoarray(ls_fundingrec, ",", ls_recommendations)
	li_fundingrec = 0
End If	

//*************************************************************
// Application Status:
//*************************************************************

ls_status = ids_parms.GetItemString(3, "prm_value")

If (ls_status = "ALL") Then
	ls_status = "Dummy"
	li_status = 1
Else
	li_status = 0
End If	


//*************************************************************
// Get Round Numbers:
//*************************************************************
ls_roundNo = ids_parms.GetItemString(4, "prm_value")
this.of_getmultiplerounds(ls_roundNo)

//*************************************************************
// Get Program:
//*************************************************************
ls_epgprogram = ids_parms.GetItemString(5, "prm_value")


//*************************************************************
// Get Project Status:
//*************************************************************
ls_projstatus = ids_parms.GetItemString(6, "prm_value")



//***************************
// Get Disbursement Date Range:
//***************************

idt_begin = f_getdbdatetime()

idt_end = f_getdbdatetime()

	
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

lstr_date_parm.str_dateLabel1 = "Release Date <="
lstr_date_parm.str_dateLabel2 =  "None"
lstr_date_parm.str_dateValue1 = idt_end
//lstr_date_parm.str_dateValue2 = idt_end

OpenWithParm(w_date_parm, lstr_date_parm)

istr_parm = Message.PowerObjectParm
	
iblb_data = istr_parm.str_parm
	
ll_RC = ids_parms.SetFullState(iblb_data)

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	// Nothing	
Else
//	ls_parm = ids_parms.GetItemString(1, "prm_value")	
//	idt_begin = DateTime(Date(Left(ls_parm,10)))	
	ls_parm = ids_parms.GetItemString(1, "prm_value")		
	idt_end = DateTime(Date(Left(ls_parm,10)))
	
End If

//*************************************************************
// Get Round Numbers:
//*************************************************************
//this.of_getmultiplerounds()

//Original
ll_rowCount = This.Retrieve(ls_program, li_program, ii_round, is_roundlist, idt_begin, idt_end, ls_recommendations, li_fundingrec,  ls_status, li_status, ls_projstatus, ls_epgprogram)
end subroutine

public subroutine of_open_parm_window ();//Open(w_srfprogram_parms)
//OpenWithParm(w_funding_recommend_parms_proj_stat, 'MULTI')

OpenWithParm(w_funding_recommend_parms, 'MULTI')
end subroutine

public subroutine of_retrieve_report_old ();
Long 				ll_count, ll_rowCount, ll_RC
String				 ls_program, ls_roundNo, ls_parm
Integer			li_fundingrec, li_program,  li_status, li_roundNo, li_roundFlag
n_cst_string		lu_string
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
//	ls_roundNo = ids_parms.GetItemString(1, "prm_value")
//
//	If (ls_roundNo = "ALL") Then
//		li_roundNo = 0
//		li_roundFlag = 1
//	Else
//		li_roundNo = Integer(ls_roundNo)
//		li_roundFlag = 0
//	End If
//	
//End If

//***************************
// Get Disbursement Date Range:
//***************************

idt_begin = f_getdbdatetime()

idt_end = f_getdbdatetime()

	
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

lstr_date_parm.str_dateLabel1 = "Release Date <="
lstr_date_parm.str_dateLabel2 =  "None"
lstr_date_parm.str_dateValue1 = idt_end
//lstr_date_parm.str_dateValue2 = idt_end

OpenWithParm(w_date_parm, lstr_date_parm)

istr_parm = Message.PowerObjectParm
	
iblb_data = istr_parm.str_parm
	
ll_RC = ids_parms.SetFullState(iblb_data)

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	// Nothing	
Else
//	ls_parm = ids_parms.GetItemString(1, "prm_value")	
//	idt_begin = DateTime(Date(Left(ls_parm,10)))	
	ls_parm = ids_parms.GetItemString(1, "prm_value")		
	idt_end = DateTime(Date(Left(ls_parm,10)))
	
End If

//*************************************************************
// Get Round Numbers:
//*************************************************************
this.of_getmultiplerounds()


ll_rowCount = This.Retrieve(ls_program, li_program, ii_round, is_roundlist, idt_begin, idt_end)

end subroutine

on n_cst_disbursements_todate_report.create
call super::create
end on

on n_cst_disbursements_todate_report.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

