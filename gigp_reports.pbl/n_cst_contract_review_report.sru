forward
global type n_cst_contract_review_report from n_cst_report
end type
end forward

global type n_cst_contract_review_report from n_cst_report
string dataobject = "d_contract_review_rpt"
end type
global n_cst_contract_review_report n_cst_contract_review_report

forward prototypes
public subroutine of_post_retrieve_report ()
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_post_retrieve_report ();Integer	N
Long 		ll_rowCnt, ll_row, ll_gigpID
String 	ls_refCode, ls_value

String     ls_code[]  =  {'agreeCOMLTRSEN', 'agreeAGRPREPDOCSNT', 'agreeAGRONROUT', 'agreeAGREFCLGL', 'agreeMAILREPSIG', 'agreeRTNEFCRECIP', 'agreeCONTRACTSNTFINRVW', 'agreeFINALLEGAPPROV', 'agreeAGRFULLEX', 'agreeEXAGRMAILRECIP', 'agreeGOVCERT', 'agreeGRANTCOMITAPP'}

String     ls_dateCol[] = {'cc_commitLtrSntDt', 'cc_agreePrepDocSntDt', 'cc_agreeRoutingDt', 'cc_agreeEfcLglDt', 'cc_agreeMailToRecipDt', 'cc_agreeReturnEfcDt', 'cc_contractSntFinRvwDt', 'cc_FinalLglApprovlDt', 'cc_AgreeFullExecDt', 'cc_ExecAgreeMailRecipDt', 'cc_GovernorsCertDt', 'cc_grantcommitteetdt'}

//String     ls_cmtsCol[] = {'cc_commitLtrSntCmt', 'cc_agreePrepDocSntCmt', 'cc_agreeRoutingCmt', 'cc_agreeEfcLgCmt', 'cc_agreeMailToRecipCmt', 'cc_agreeReturnEfcCmt', 'cc_contractSntFinRvwCmt', 'cc_FinalLglApprovlCmt', 'cc_AgreeFullExecCmt', 'cc_ExecAgreeMailRecipCmt', 'cc_GovernorsCertCmt'}

DateTime ldt_value, ldt_dummy

ldt_dummy = DateTime(Date("01/01/1900"))

ll_rowCnt = This.RowCount()

If (ll_rowCnt < 1) Then Return


FOR ll_row = 1 TO ll_rowCnt
		
	ll_gigpID = This.GetItemNumber(ll_row, "gigp_id")	

	ls_value = f_get_applicant_name(ll_gigpID)
	This.setItem(ll_row, 'cc_appname', ls_value)
	
	SetNull(ls_value)

	FOR N = 1 TO 12
	
		ls_refCode = ls_code[N] 
		
		Select		keydate_value,
					keydate_comments
		Into 		:ldt_value,
					:ls_value
		From gigp_key_dates
		Where gigp_id = :ll_gigpID
		And ref_code = :ls_refCode;			
		
		If Not IsNull(ldt_value) and (ldt_value <> ldt_dummy) Then
			This.setItem(ll_row, ls_dateCol[N], ldt_value)			
		End If
				
//		If Not IsNull(ls_value) Then 			
//			If (ls_cmtsCol[N]  <> "DUMMY") Then
//				This.setItem(ll_row, ls_cmtsCol[N] , ls_value)	
//			End If
//						
//		End If      
		
		SetNull(ls_value)
		SetNull(ldt_value)
	NEXT

NEXT


end subroutine

public subroutine of_retrieve_report ();
Long 				ll_count
String				ls_fundingrec, ls_program, ls_recommendations[],  ls_status, ls_roundNo
Integer			li_fundingrec, li_program,  li_status, li_roundNo, li_roundFlag

n_cst_string		lu_string

ll_count = ids_parms.RowCount()

//If (ll_count <> 4) Then	
//	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
//	Return
//End If

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
// Application status:
//*************************************************************

ls_status = ids_parms.GetItemString(3, "prm_value")

If (ls_status = "ALL") Then
	ls_status = "Dummy"
	li_status = 1
Else
	li_status = 0
End If	

//*************************************************************
// Round No:
//*************************************************************
//ls_roundNo = ids_parms.GetItemString(4, "prm_value")
//
//If (ls_roundNo = "ALL") Then
//	li_roundNo = 0
//	li_roundFlag = 1
//Else
//	li_roundNo = Integer(ls_roundNo)
//	li_roundFlag = 0
//End If	

//*************************************************************
// Get Round Numbers:
//*************************************************************
ls_roundNo = ids_parms.GetItemString(4, "prm_value")
this.of_getmultiplerounds(ls_roundNo)

This.Retrieve(ls_recommendations, li_fundingrec, ls_program, li_program, ls_status, li_status, ii_round, is_roundlist)

end subroutine

public subroutine of_open_parm_window ();OpenWithParm(w_funding_recommend_parms, 'MULTI')
end subroutine

on n_cst_contract_review_report.create
call super::create
end on

on n_cst_contract_review_report.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

