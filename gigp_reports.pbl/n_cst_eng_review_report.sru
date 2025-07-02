forward
global type n_cst_eng_review_report from n_cst_report
end type
end forward

global type n_cst_eng_review_report from n_cst_report
string dataobject = "d_design_review_rpt"
end type
global n_cst_eng_review_report n_cst_eng_review_report

forward prototypes
public subroutine of_post_retrieve_report ()
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_post_retrieve_report ();Integer	N
Long 		ll_rowCnt, ll_row, ll_gigpID, ll_count
String 	ls_refCode, ls_value, ls_projno, ls_valuestatus, ls_valuecomments
Decimal	ld_funding

String		ls_code[]     = {'readyPROJPLANSUB','readyPROJPLANDEC','readyFINPLANSSUB','readyPLANSSPECSDEC','readySERPCERTSNTREG','readyCERTSNTDEC','seqrFINSHPOSOLTR','readyFEASABILITY','readyCONCEPTPLAN','readyENGAGREE'}
String		ls_recdateCol[] = {'cc_efcengrptdtrec','cc_decengrptdtrec','cc_efcplansspecdtrec','cc_decplansspecdtrec','cc_serpsertdtrec','cc_regcertdtrec','cc_finalshpodtrec','cc_feasibilityrec','cc_conceptrec','cc_engineeragreerec'}
String		ls_appdateCol[] = {'cc_efcengrptdtapp','cc_decengrptdtapp','cc_efcplansspecdtapp','cc_decplansspecdtapp','cc_serpsertdtapp','cc_regcertdtapp','cc_finalshpodtapp','cc_feasibilityapp','cc_conceptapp','cc_engineeragreeapp'}
String		ls_statusCol[] = {'cc_efcengrptstatus','cc_decengrptstatus','cc_efcplansspecstatus','cc_decplansspecstatus','DUMMY','DUMMY','DUMMY','cc_feasibilitystatus','cc_conceptstatus','cc_engineeragreestatus'}
String		ls_cmtsCol[] = {'cc_efcengrptcmt','cc_decengrptcmt','cc_efcplansspeccmt','cc_decplansspeccmt','DUMMY','DUMMY','DUMMY','DUMMY','DUMMY','DUMMY'}

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
	
	ld_funding = f_get_project_amount(ll_gigpID, "RECFR")
	this.SetItem(ll_row, 'grantamount', ld_funding)
	
	select comments
	into :ls_value
	from gigp_notes
	where gigp_id = :ll_gigpID
	and note_category = 'appNote'
	and note_type = 'projDescription';
	
	If ls_value > '' Then
		This.SetItem(ll_row, 'efc_summary', Trim(ls_value))
	End If
	
	SetNull(ls_value)
	select keydate_ind
	into :ls_value
	from gigp_key_dates
	where gigp_id = :ll_gigpID
	and ref_code = 'seqrDETRMREASON';
	this.SetItem(ll_row, 'cc_resseqrtype', ls_value)
	
	SetNull(ls_value)
	select keydate_ind
	into :ls_value
	from gigp_key_dates
	where gigp_id = :ll_gigpID
	and ref_code = 'seqrSERPCERTCOMPL';
	this.SetItem(ll_row, 'cc_legal_serpcert', ls_value)
	
	
	SetNull(ls_value)
	select keydate_ind
	into :ls_value
	from gigp_key_dates
	where gigp_id = :ll_gigpID
	and ref_code = 'seqrEFCSEQRSGNOFF';
	this.SetItem(ll_row, 'efc_seqr_signoff', ls_value)
	
	SetNull(ldt_value)
	select keydate_value
	into :ldt_value
	from gigp_key_dates
	where gigp_id = :ll_gigpID
	and ref_code = 'seqrEAFFORMVER';
	
	this.SetItem(ll_row, 'cc_eafformDt', ldt_value)
	
	SetNull(ldt_value)
	select keydate_value
	into :ldt_value
	from gigp_key_dates
	where gigp_id = :ll_gigpID
	and ref_code = 'seqrNOTDETNONSIG';
	
	this.SetItem(ll_row, 'cc_nonsignifDt', ldt_value)
	
	SetNull(ls_value)
	
	//GPR, Water Eff
	select count(*)
	into :ll_count
	from gigp_checklist
	where gigp_id = :ll_gigpID
	and ref_code = 'WERC'
	and checklist_value2 = 1;
	If ll_count > 0 Then
		If IsNull(ls_value) Then
			ls_value = 'WE'
		Else
			ls_value += ',WE'
		End If
	End If
	
	//GPR, Energy Eff
	select count(*)
	into :ll_count
	from gigp_checklist
	where gigp_id = :ll_gigpID
	and ref_code = 'ENEFF'
	and checklist_value2 = 1;
	If ll_count > 0 Then
		If IsNull(ls_value) Then
			ls_value = 'EE'
		Else
			ls_value += ',EE'
		End If
	End If
	
	//GPR, Green Wet Weather
	select count(*)
	into :ll_count
	from gigp_checklist
	where gigp_id = :ll_gigpID
	and ref_code = 'GWWI'
	and checklist_value2 = 1;
	If ll_count > 0 Then
		If IsNull(ls_value) Then
			ls_value = 'GI'
		Else
			ls_value += ',GI'
		End If
	End If
	
	//GPR, Env Innovation
	select count(*)
	into :ll_count
	from gigp_checklist
	where gigp_id = :ll_gigpID
	and ref_code = 'ENVIN'
	and checklist_value2 = 1;
	If ll_count > 0 Then
		If IsNull(ls_value) Then
			ls_value = 'EI'
		Else
			ls_value += ',EI'
		End If
	End If
	
	this.SetItem(ll_row, 'cc_gprtype', ls_value)

	SetNull(ls_value)
	select keydate_ind
	into :ls_value
	from gigp_key_dates
	where gigp_id = :ll_gigpID
	and ref_code = 'seqrFINSHPOSOLTR';
	
	this.SetItem(ll_row, 'cc_finalshpodtstatus', ls_value)
	
	SetNull(ldt_valuerec)
	SetNull(ldt_valueapp)
	SetNull(ls_valuestatus)
	SetNull(ls_valuecomments)

	FOR N = 1 TO 10
	
		ls_refCode = ls_code[N] 
		
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
		
		This.SetItem(ll_row, ls_recdateCol[N], ldt_valuerec)
		This.SetItem(ll_row, ls_appdateCol[N], ldt_valueapp)
		
		If ls_statusCol[N] <> 'DUMMY' Then
			This.SetItem(ll_row, ls_statusCol[N], ls_valuestatus)
		End If
		
		If ls_cmtsCol[N] <> 'DUMMY' Then
			This.SetItem(ll_row, ls_cmtsCol[N], ls_valuecomments)
		End If
				
			
		SetNull(ldt_valuerec)
		SetNull(ldt_valueapp)
		SetNull(ls_valuestatus)
		SetNull(ls_valuecomments)
		
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

public subroutine of_retrieve_report ();Long 				ll_count
String				ls_fundingrec, ls_program, ls_recommendations[],  ls_status, ls_roundNo, ls_projstatus
Integer			li_fundingrec, li_program,  li_status, li_roundNo, li_roundFlag
n_cst_string		lu_string

ll_count = ids_parms.RowCount()

//If (ll_count <> 5) Then	
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

//Project Status
ls_projstatus = ids_parms.GetItemString(5, "prm_value")

This.Retrieve(ls_recommendations, li_fundingrec, ls_program, li_program, ls_status, li_status, ii_round, is_roundlist, ls_projstatus)

end subroutine

public subroutine of_open_parm_window ();//OpenWithParm(w_funding_recommend_parms, 'MULTI')

OpenWithParm(w_funding_recommend_parms_proj_stat, 'MULTI')
end subroutine

on n_cst_eng_review_report.create
call super::create
end on

on n_cst_eng_review_report.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

