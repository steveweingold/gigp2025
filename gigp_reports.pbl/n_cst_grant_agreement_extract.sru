forward
global type n_cst_grant_agreement_extract from n_cst_report
end type
end forward

global type n_cst_grant_agreement_extract from n_cst_report
string dataobject = "d_grant_agreement_extract"
end type
global n_cst_grant_agreement_extract n_cst_grant_agreement_extract

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();Long 		ll_count, ll_Cnt, N, ll_gigpID, ll_newRow, ll_row, ll_SCcount, ll_cfa
String		ls_parm, ls_gigpIDs[], ls_appjName, ls_projNo, ls_appTypeCode, ls_appType, ls_formattedProj, ls_description, ls_sc, ls_cr, ls_round, ls_ppu, ls_duns
String		ls_name, ls_title, ls_address1, ls_address2, ls_address3, ls_city, ls_state, ls_zip, ls_county, ls_Amt, ls_date, ls_email, ls_grantsource, ls_fips, ls_begin, ls_end
Integer	li_round, li_ppu
Decimal 	ld_Amt
DateTime	ldt_date, ldt_dummy
n_cst_string lu_string
datastore lds_special

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
	Return
End If
	
ldt_dummy = DateTime('1/1/1900 00:00:00')	
	
ls_parm = ids_parms.GetItemString(1, "prm_value")		

ll_Cnt = lu_string.of_parsetoarray(ls_parm, ",", ls_gigpIDs)

If NOT IsValid(lds_special) Then lds_special = CREATE datastore
lds_special.DataObject = 'd_proj_project_special_conditions'
lds_special.SetTransObject(SQLCA)

ls_cr = Char(13)	//Carriage Return

//*************************************************************
// Loop to get Project Info for selected projects:
//*************************************************************

FOR N = 1 TO ll_Cnt
	
	ll_newRow = This.InsertRow(0)	
	
	ll_gigpID = Integer(ls_gigpIDs[N])
	
	//*************************************************************
	// Project & Recipient Info:
	//*************************************************************
	
	Select		project_no,
				applicant_type,
				round_no,
				srf_program,
				ppu,
				cfa_no,
				county_fips_code,
				duns_no
	Into 		:ls_projNo,
				:ls_appTypeCode,
				:li_round,
				:ls_appType,
				:li_ppu,
				:ll_cfa,
				:ls_fips,
				:ls_duns
	From 		gigp_application 
	Where gigp_id = :ll_gigpID
	using sqlca;
	
	If IsNull(ls_appTypeCode) Then ls_appTypeCode = ""	
	
	ls_round = String(li_round)
	
	If li_round >= 100 Then
		ls_formattedProj = String(ll_cfa)
	Else
		ls_formattedProj = ls_projNo
	End If
	
	Select ref_value
	Into :ls_appType
	From gigp_reference
	Where category = 'appType'
	And ref_code = :ls_appTypeCode;
	
	If IsNull(ls_appType) Then ls_appType = ""	
	
	If IsNull(li_ppu) Then 
		ls_ppu = ''
	Else
		ls_ppu = String(li_ppu)
	End If
	
	This.SetItem(ll_newRow, 'app_id', ls_gigpIDs[N])
	This.SetItem(ll_newRow, 'project_no',ls_formattedProj)	
	This.SetItem(ll_newRow, 'applicant_type', ls_appType)			
	This.SetItem(ll_newRow, 'ppu', ls_ppu)
	This.SetItem(ll_newRow, 'duns_no', ls_duns)
	
	
	SELECT	comments         		
	INTO		:ls_description		
	FROM 	gigp_notes
	WHERE	gigp_id = :ll_gigpID
	AND 		note_category = 'appNote'
	AND        note_type = 'projDescription';
	
	
	If (IsNull(ls_description)) Then ls_description = ""	
	
	This.SetItem(ll_newRow, 'project_description', ls_description)	
	
	
	Select		C.organization,	
				C.mail_address1,   
         			C.mail_address2,   
         			C.mail_address3,   
         			C.mail_city,   
         			C.mail_state,   
         			C.mail_zip				
	Into		:ls_appjName,
				:ls_address1,
				:ls_address2,
				:ls_address3,
				:ls_city,
				:ls_state, 
				:ls_zip
	FROM		gigp_contacts C,   
         			gigp_contact_links CL  
	WHERE 	C.contact_id = CL.contact_id    
	AND		CL.gigp_id = :ll_gigpID
//	AND      	CL.contact_type = "APP"	//11/2019 as per RL
	AND      	CL.contact_type = "AUTHREP"
	AND		C.status = 'Active';
	
	//Get County
	Select ref_value
	into :ls_county
	From 	 gigp_reference
	Where  category     = "County"
	And   ref_code = :ls_fips;
	
	If IsNull(ls_appjName) Then ls_appjName = ""
	If IsNull(ls_address1) Then ls_address1 = ""
	If IsNull(ls_address2) Then ls_address2 = ""	
	If IsNull(ls_address3) Then ls_address3 = ""	
	If IsNull(ls_city) Then ls_city = ""	
	If IsNull(ls_state) Then ls_state = ""	
	If IsNull(ls_county) Then ls_county = ""	
	
	ls_address2 += (" " + ls_address3)
	
	This.SetItem(ll_newRow, 'recipient', ls_appjName)	
	This.SetItem(ll_newRow, 'recipient_caps', Upper(ls_appjName))		
	This.SetItem(ll_newRow, 'recip_address1', ls_address1)	
	This.SetItem(ll_newRow, 'recip_address2', Trim(ls_address2))	
	This.SetItem(ll_newRow, 'recip_town', ls_city)	
	This.SetItem(ll_newRow, 'county', ls_county)	
	
	//*************************************************************
	// Format Zip:
	//*************************************************************
		
	If (Len(ls_zip) > 5) Then
		ls_zip = (Left(ls_zip, 5) + "-" + Mid(ls_zip, 6, 4))
		
	Else
		If IsNull(ls_zip) Then ls_zip = ""
		
	End If
	
	This.SetItem(ll_newRow, 'recip_zip', ls_zip)	
	
	//*************************************************************
	// Contract Amount (Numeric & Word format):
	//*************************************************************
	
	ld_Amt = f_get_project_amount(ll_gigpID, "RECFR")
	
	ls_Amt = f_amount_to_text(ld_Amt)
	
	This.SetItem(ll_newRow, 'grant_amount_num', ld_Amt)
	This.SetItem(ll_newRow, 'grant_amount_word', ls_Amt)
	This.SetItem(ll_newRow, 'grant_amount_formatted', String(ld_Amt, '$#,##0.00;($#,##0.00)'))
	
	//*************************************************************
	// Authorized Rep:
	//*************************************************************
	
	SetNull(ls_name)
	SetNull(ls_title)
	SetNull(ls_email)
	
	Select		C.full_name,	
				C.title,
				C.email
	Into		:ls_name,
				:ls_title,
				:ls_email
	FROM		gigp_contacts C,   
         			gigp_contact_links CL  
	WHERE 	C.contact_id = CL.contact_id    
	AND		CL.gigp_id = :ll_gigpID
	AND      	CL.contact_type = "AUTHREP"
	AND		C.status = 'Active';
		
	If IsNull(ls_name) Then ls_name = ""
	If IsNull(ls_title) Then ls_title = ""
	If IsNull(ls_email) Then ls_email = ""
	
	This.SetItem(ll_newRow, 'auth_rep', ls_name)
	This.SetItem(ll_newRow, 'auth_rep_title', ls_title)
	This.SetItem(ll_newRow, 'auth_rep_email', ls_email)
	
	//*************************************************************
	// Local Counsel:
	//*************************************************************
	
	SetNull(ls_name)
	SetNull(ls_title)
	SetNull(ls_email)
	
	Select		C.full_name,
				C.email
	Into		:ls_name,
				:ls_email
	FROM		gigp_contacts C,   
         			gigp_contact_links CL  
	WHERE 	C.contact_id = CL.contact_id    
	AND		CL.gigp_id = :ll_gigpID
	AND      	CL.contact_type = "LOCCON"
	AND		C.status = 'Active';
		
	If IsNull(ls_name) Then ls_name = ""
	If IsNull(ls_email) Then ls_email = ""
	
	This.SetItem(ll_newRow, 'local_counsel', ls_name)	
	This.SetItem(ll_newRow, 'local_counsel_email', ls_email)
	
	//*************************************************************
	// Closing Date:
	//*************************************************************
		
//	Select keydate_value
//	Into	:ldt_date
//	From gigp_key_dates
//	Where gigp_id  = :ll_gigpID
//	And ref_code = 'agreeAGRFULLEX';
	
	ldt_date = f_getdbdatetime()
	
	If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
		ls_date = String(Date(ldt_date), "mmmm dd, yyyy")
		This.SetItem(ll_newRow, 'closing_dt', ls_date)		
	End If

	//*********************
	// Construction Start:
	//*********************
	SetNull(ldt_date)

	If li_round < 100 Then
		ls_begin = 'readyCONSTRCOMM'
	Else
		ls_begin = 'epgEXECENGAGR'
	End If
	
	SELECT	keydate_value   
	INTO		:ldt_date
	FROM 	gigp_key_dates  
	WHERE 	ref_code = :ls_begin
	AND 		gigp_id = :ll_gigpID; 
	
	If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
		ls_date = String(Date(ldt_date), "mmmm dd, yyyy")
		This.SetItem(ll_newRow, 'construct_start_dt', ls_date)		
	End If
	
	//*********************
	// Construction Completion:
	//*********************
	SetNull(ldt_date)
	
	If li_round < 100 Then
		ls_end = 'readyCONSTRCOMPL'
	Else
		ls_end = 'epgENGREPORTAPP'
	End If
	
	SELECT	keydate_value   
	INTO		:ldt_date
	FROM 	gigp_key_dates  
	WHERE 	ref_code = :ls_end
	AND 		gigp_id = :ll_gigpID; 
	
	If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
			ls_date = String(Date(ldt_date), "mmmm dd, yyyy")
			This.SetItem(ll_newRow, 'construct_end_dt', ls_date)		
	End If

	//*********************
	// Plans & Specs:
	//*********************
	
	SetNull(ldt_date)
	
	SELECT	keydate_value   
	INTO		:ldt_date
	FROM 	gigp_key_dates  
	WHERE 	ref_code = 'readyFINPLANSSUB'
	AND 		gigp_id = :ll_gigpID; 
	
	If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
			ls_date = String(Date(ldt_date), "mmmm dd, yyyy")
			This.SetItem(ll_newRow, 'plansspecs_dt', ls_date)		
	End If

	//*********************
	// Bid Advertise:
	//*********************
	
	SetNull(ldt_date)
	
	SELECT	keydate_value   
	INTO		:ldt_date
	FROM 	gigp_key_dates  
	WHERE 	ref_code = 'readyADVERTIS'
	AND 		gigp_id = :ll_gigpID; 
	
	If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
			ls_date = String(Date(ldt_date), "mmmm dd, yyyy")
			This.SetItem(ll_newRow, 'adbids_dt', ls_date)		
	End If

	//*********************
	// Bid Open:
	//*********************
	
	SetNull(ldt_date)
	
	SELECT	keydate_value   
	INTO		:ldt_date
	FROM 	gigp_key_dates  
	WHERE 	ref_code = 'readyBIDDT'
	AND 		gigp_id = :ll_gigpID; 
	
	If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
			ls_date = String(Date(ldt_date), "mmmm dd, yyyy")
			This.SetItem(ll_newRow, 'openbids_dt', ls_date)		
	End If

	//*********************
	// Bids Approved:
	//*********************
	
	SetNull(ldt_date)
	
	SELECT	keydate_value   
	INTO		:ldt_date
	FROM 	gigp_key_dates  
	WHERE 	ref_code = 'readyAWRDBIDAPRV'
	AND 		gigp_id = :ll_gigpID; 
	
	If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
			ls_date = String(Date(ldt_date), "mmmm dd, yyyy")
			This.SetItem(ll_newRow, 'awardbids_dt', ls_date)		
	End If

	//***************************
	//Construct Contracts Executed:
	//***************************
	
	SetNull(ldt_date)
	
	SELECT	keydate_value   
	INTO		:ldt_date
	FROM 	gigp_key_dates  
	WHERE 	ref_code = 'readyCONSTRCONTEX'
	AND 		gigp_id = :ll_gigpID; 
	
	If (Not (IsNull(ldt_date))) And (ldt_date <> ldt_dummy) Then		
			ls_date = String(Date(ldt_date), "mmmm dd, yyyy")
			This.SetItem(ll_newRow, 'execcontracts_dt', ls_date)		
	End If


	ls_description = ""

	
	//***************************
	//Special Conditions:
	//***************************
	ll_SCcount = lds_special.Retrieve(ll_gigpID, ls_round)
	
	ls_sc = ''
	
	If ll_SCcount > 0 Then
		For ll_row = 1 to ll_SCcount
			
			If NOT IsNull(lds_special.GetItemNumber(ll_row, 'gigp_id')) Then
				If Left(lds_special.GetItemString(ll_row, 'ref_code'), 6) = 'CUSTOM' Then
					ls_sc += lds_special.GetItemString(ll_row, 'alternate_text') + ls_cr + ls_cr
				Else
					ls_sc += lds_special.GetItemString(ll_row, 'ref_description') + ls_cr + ls_cr
				End If
				
			End If
			
		Next
		
	End If
	
	this.SetItem(ll_newRow, 'specialConditions', ls_sc)
	

NEXT

end subroutine

public subroutine of_open_parm_window ();
Open(w_project_select)
end subroutine

on n_cst_grant_agreement_extract.create
call super::create
end on

on n_cst_grant_agreement_extract.destroy
call super::destroy
end on

