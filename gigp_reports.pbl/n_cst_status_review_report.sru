forward
global type n_cst_status_review_report from n_cst_report
end type
end forward

global type n_cst_status_review_report from n_cst_report
string dataobject = "d_design_review_rpt"
end type
global n_cst_status_review_report n_cst_status_review_report

forward prototypes
public subroutine of_post_retrieve_report ()
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_post_retrieve_report ();Integer	N
Long 		ll_rowCnt, ll_row, ll_gigpID, ll_count
String 	ls_refCode, ls_value, ls_projno, ls_valuestatus, ls_choice, ls_ind, ls_legal
Decimal	ld_funding
DateTime	ldt_valuerec

//String		ls_code[]     = {'readyPROJPLANSUB','readyPROJPLANDEC','readyFINPLANSSUB','readyPLANSSPECSDEC','readySERPCERTSNTREG','readyCERTSNTDEC','seqrEFCSEQRSGNOFF','TITLE','BOND','ESTOPPEL','REFERENDUM','LOCALMATCH','AUTHREP','IMA','TPFDOCS','DISTRICTFORM','readyDETAILBUD','readyPLANFINANCE','readySMARTGROWTH','readyMWBEWORK','readyFEASABILITY','readyCONCEPTPLAN','readyENGAGREE'}
//String		ls_code[]     = {'readyPROJPLANSUB','readyPROJPLANDEC','readyFINPLANSSUB','readyPLANSSPECSDEC','seqrSERPCERTCOMPL','readyCERTSNTDEC','seqrEFCSEQRSGNOFF','TITLE','BOND','ESTOPPEL','REFERENDUM','LOCALMATCH','AUTHREP','IMA','TPFDOCS','DISTRICTFORM','readyDETAILBUD','readyPLANFINANCE','readySMARTGROWTH','readyMWBEWORK','readyFEASABILITY','readyCONCEPTPLAN','readyENGAGREE'}
String		ls_code[]     = {'readyPROJPLANSUB','readyPROJPLANDEC','readyFINPLANSSUB','readyPLANSSPECSDEC','readySERPCERTSNTREG','readyCERTSNTDEC','seqrEFCSEQRSGNOFF','TITLE','BOND','ESTOPPEL','REFERENDUM','LOCALMATCH','AUTHREP','IMA','TPFDOCS','DISTRICTFORM','readyDETAILBUD','readyPLANFINANCE','readySMARTGROWTH','readyMWBEWORK','readyFEASABILITY','readyCONCEPTPLAN','readyENGAGREE'}
String		ls_statusCol[] = {'cc_efcengrptstatus','cc_decengrptstatus','cc_efcplansspecstatus','cc_decplansspecstatus','cc_serpcertstatus','cc_regcertstatus','efc_seqr_signoff','cc_titleCert','cc_bondRes','cc_estopNot','cc_permisRef','cc_localMatch','cc_authRepRes','cc_interAgree','cc_third_party_fuding','cc_dis_docs','cc_detailed_budget','cc_plan_of_finance','cc_smart_growth','cc_mwbe_workplan','cc_feasibilitystatus','cc_conceptstatus','cc_engineeragree'}

ll_rowCnt = This.RowCount()

If (ll_rowCnt < 1) Then Return

FOR ll_row = 1 TO ll_rowCnt
		
	ll_gigpID = This.GetItemNumber(ll_row, "gigp_id")	
	
	SetNull(ls_value)
	ls_value = f_get_applicant_name(ll_gigpID)
	This.setItem(ll_row, 'cc_appname', ls_value)
	
	SetNull(ls_value)
	ls_value = f_get_engineer(ll_gigpID)
	This.setItem(ll_row, 'cc_engineer', ls_value)

	//Set EFC Legal person
	SetNull(ls_legal)
	
	select max(c.last_name)
	into :ls_legal
	from gigp_contacts c, gigp_contact_links l
	where c.contact_id = l.contact_id
	and l.gigp_id = :ll_gigpID
	and l.contact_type = 'EFCLGL'
	and c.status = 'Active';
	
	If ls_legal > '' Then
		this.SetItem(ll_row, 'cc_legal', ls_legal)
	End If
	
	SetNull(ls_value)
	
	select c.last_name
	into :ls_value
	from gigp_contacts c, gigp_contact_links cl
	where c.contact_id = cl.contact_id
	and cl.gigp_id = :ll_gigpID
	and cl.contact_type = 'EFCREVASSGN'
	and c.status = 'Active';
	
	This.SetItem(ll_row, 'cc_reviewer', ls_value)
	
		
	SetNull(ls_value)
	
	select max(c.last_name)
	into :ls_value
	from gigp_contacts c, gigp_contact_links cl
	where c.contact_id = cl.contact_id
	and cl.gigp_id = :ll_gigpID
	and cl.contact_type = 'EFCLANDARCH'
	and c.status = 'Active';
	
	This.SetItem(ll_row, 'cc_landarc', ls_value)
	
	
	ld_funding = f_get_project_amount(ll_gigpID, "RECFR")
	this.SetItem(ll_row, 'grantamount', ld_funding)
	

	FOR N = 1 TO 23
	
		ls_refCode = ls_code[N] 
		
		Select		keydate_choice,
						keydate_ind
		Into 			:ls_choice,
						:ls_ind
		From gigp_key_dates
		Where gigp_id = :ll_gigpID
		And ref_code = :ls_refCode;			
		
		If Left(ls_refCode, 5) = 'ready' Then
			ls_valuestatus = ls_choice
		Else
			ls_valuestatus = ls_ind
		End If
		
		This.SetItem(ll_row, ls_statusCol[N], ls_valuestatus)
		
		SetNull(ls_valuestatus)
		SetNull(ls_choice)
		SetNull(ls_ind)
		
	NEXT
	
	select keydate_value
	into :ldt_valuerec
	from gigp_key_dates
	where gigp_id = :ll_gigpID
	and ref_code = 'agreeGRANTCOMITAPP';
	
	If NOT IsNull(ldt_valuerec) Then
		This.SetItem(ll_row, 'cc_grantcommitee', ldt_valuerec)
		SetNull(ldt_valuerec)
	End If

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

on n_cst_status_review_report.create
call super::create
end on

on n_cst_status_review_report.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

