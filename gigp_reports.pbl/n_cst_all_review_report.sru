forward
global type n_cst_all_review_report from n_cst_report
end type
end forward

global type n_cst_all_review_report from n_cst_report
string dataobject = "d_design_review_rpt"
end type
global n_cst_all_review_report n_cst_all_review_report

forward prototypes
public subroutine of_post_retrieve_report ()
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_post_retrieve_report ();Integer	N
Long 		ll_rowCnt, ll_row, ll_gigpID, ll_count
String 	ls_refCode, ls_value, ls_projno, ls_valuestatus, ls_valuecomments, ls_legal, ls_status
Decimal	ld_funding

String		ls_eng_code[]     = {'readySERPCERTSNTREG','readyCERTSNTDEC','readyFEASABILITY','readyCONCEPTPLAN'}
String		ls_eng_recdateCol[] = {'cc_serpsertdtrec','cc_regcertdtrec','cc_feasibilityrec','cc_conceptrec'}
String		ls_eng_appdateCol[] = {'cc_serpsertdtapp','cc_regcertdtapp','cc_feasibilityapp','cc_conceptapp'}
String		ls_eng_statusCol[] = {'DUMMY','DUMMY','cc_feasibilitystatus','cc_conceptstatus'}

String		ls_legal_code[]     = {'TITLE', 'BOND', 'ESTOPPEL', 'REFERENDUM', 'LOCALMATCH', 'AUTHREP', 'IMA', 'TPFDOCS', 'DISTRICTFORM'}
String		ls_legal_dateCol[] = {'cc_titleCert_dt', 'cc_bondRes_dt', 'cc_estopNot_dt', 'cc_permisRef_dt', 'cc_localMatch_dt', 'cc_authRepRes_dt', 'cc_interAgree_dt', 'cc_fundDocs_dt', 'cc_disDocs_dt'} 
String		ls_legal_statusCol[] = {'cc_titleCert_stat','cc_bondRes_stat','cc_estopNot_stat','cc_permisRef_stat','cc_localMatch_stat','cc_authRepRes_stat','cc_interAgree_stat','cc_fundDocs_stat','cc_disDocs_stat'}

String     ls_seqr_code[]     = {'seqrLASLTRISS', 'seqrEAFFORMVER', 'seqrDECLRESOLRCVD', 'seqrDETRMREASON', 'seqrNOTDETNONSIG', 'seqrENBPUBDT', 'seqrFINSHPOSOLTR', 'seqrEFCSEQRSGNOFF'}
String     ls_seqr_dateCol[] = {'cc_leadagncysolltrdt', 'cc_eafformverdt', 'cc_declresrecvddt', 'cc_determreasndt', 'cc_noticedetofnonsigdt', 'cc_enbpubdt', 'cc_finshposignoffltrdt', 'cc_efcseqrsignoffdt'} 
String     ls_seqr_cmtsCol[] = {'cc_leadagncysolcmt', 'cc_eafformvercmt', 'cc_declresrecvdcmt', 'cc_determreasncmt', 'cc_noticedetofnonsigcmt', 'cc_enbpubcmt', 'cc_finshposignoffltrcmt', 'cc_efcseqrsignoffcmt'}

String     ls_contract_code[]  =  {'agreeGRANTCOMITAPP', 'agreeMAILREPSIG', 'agreeRTNEFCRECIP', 'agreeEXAGRMAILRECIP'}
String     ls_contract_dateCol[] = {'cc_grantcommitteetdt', 'cc_agreeMailToRecipDt', 'cc_agreeReturnEfcDt', 'cc_ExecAgreeMailRecipDt'}


DateTime ldt_value, ldt_dummy, ldt_valuerec, ldt_valueapp

ldt_dummy = DateTime(Date("01/01/1900"))

ll_rowCnt = This.RowCount()

If (ll_rowCnt < 1) Then Return

FOR ll_row = 1 TO ll_rowCnt
		
	ll_gigpID = This.GetItemNumber(ll_row, "gigp_id")	

	ls_value = f_get_applicant_name(ll_gigpID)
	This.setItem(ll_row, 'cc_appname', ls_value)
	
	ls_value = f_get_engineer(ll_gigpID)
	This.setItem(ll_row, 'cc_engineer', ls_value)
	
	//Set EFC Legal person
	select max(c.full_name)
	into :ls_legal
	from gigp_contacts c, gigp_contact_links l
	where c.contact_id = l.contact_id
	and l.gigp_id = :ll_gigpID
	and l.contact_type = 'EFCLGL';
	
	If ls_legal > '' Then
		this.SetItem(ll_row, 'cc_efc_legal', ls_legal)
	End If
	
	SetNull(ls_value)
	SetNull(ldt_valuerec)
	SetNull(ldt_valueapp)
	SetNull(ls_valuestatus)
	SetNull(ls_valuecomments)
	
	//ENG columns
	FOR N = 1 TO 4
	
		ls_refCode = ls_eng_code[N] 
		
		Select		keydate_value,
						keydate_value2,
						keydate_choice,
						keydate_comments
		Into 			:ldt_valuerec,
						:ldt_valueapp,
						:ls_valuestatus,
						:ls_valuecomments
		From gigp_key_dates
		Where gigp_id = :ll_gigpID
		And ref_code = :ls_refCode;			
		
		This.SetItem(ll_row, ls_eng_recdateCol[N], ldt_valuerec)
		This.SetItem(ll_row, ls_eng_appdateCol[N], ldt_valueapp)
		
		If ls_eng_statusCol[N] <> 'DUMMY' Then
			This.SetItem(ll_row, ls_eng_statusCol[N], ls_valuestatus)
		End If
			
		SetNull(ldt_valuerec)
		SetNull(ldt_valueapp)
		SetNull(ls_valuestatus)
		SetNull(ls_valuecomments)
		
	NEXT
	
	SetNull(ldt_value)
	SetNull(ls_status)
	
	//Legal columns
	FOR N = 1 TO 9
	
		ls_refCode = ls_legal_code[N] 
		
		Select	keydate_value,
					keydate_ind
		Into 		:ldt_value,
					:ls_status
		From gigp_key_dates
		Where gigp_id = :ll_gigpID
		And ref_code = :ls_refCode;			
		
		If Not IsNull(ldt_value) and (ldt_value <> ldt_dummy) Then
			This.setItem(ll_row, ls_legal_dateCol[N], ldt_value)			
		End If
				
		If Not IsNull(ls_status) Then
			this.SetItem(ll_row, ls_legal_statusCol[N], ls_status)
		End If
		
		SetNull(ldt_value)
		SetNull(ls_status)
	NEXT
	
	SetNull(ls_value)
	SetNull(ldt_value)
		
	//SEQR columns
	FOR N = 1 TO 8
	
		ls_refCode = ls_seqr_code[N] 
		
		Select		keydate_value,
					keydate_ind
		Into 		:ldt_value,
					:ls_value
		From gigp_key_dates
		Where gigp_id = :ll_gigpID
		And ref_code = :ls_refCode;			
		
		If Not IsNull(ldt_value) and (ldt_value <> ldt_dummy) Then
			This.setItem(ll_row, ls_seqr_dateCol[N], ldt_value)			
		End If
				
		If Not IsNull(ls_value) Then 			
			If (ls_seqr_cmtsCol[N]  <> "DUMMY") Then
				This.setItem(ll_row, ls_seqr_cmtsCol[N] , ls_value)	
			End If
						
		End If     
		
		SetNull(ls_value)
		SetNull(ldt_value)
	NEXT
	
	SetNull(ldt_value)
	
	//Contract columns
	FOR N = 1 TO 4
	
		ls_refCode = ls_contract_code[N] 
		
		Select		keydate_value
		Into 		:ldt_value
		From		gigp_key_dates
		Where gigp_id = :ll_gigpID
		And ref_code = :ls_refCode;			
		
		If Not IsNull(ldt_value) and (ldt_value <> ldt_dummy) Then
			This.setItem(ll_row, ls_contract_dateCol[N], ldt_value)			
		End If
				
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
// Round No:
//*************************************************************

ls_roundNo = ids_parms.GetItemString(4, "prm_value")

If (ls_roundNo = "ALL") Then
	li_roundNo = 0
	li_roundFlag = 1
Else
	li_roundNo = Integer(ls_roundNo)
	li_roundFlag = 0
End If	

This.Retrieve(ls_recommendations, li_fundingrec, ls_program, li_program, ls_status, li_status, li_roundNo, li_roundFlag)

end subroutine

public subroutine of_open_parm_window ();
Open(w_funding_recommend_parms)
end subroutine

on n_cst_all_review_report.create
call super::create
end on

on n_cst_all_review_report.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

