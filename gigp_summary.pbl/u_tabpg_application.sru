forward
global type u_tabpg_application from u_tabpg_dbaccess
end type
type tab_2 from u_tab_app_info within u_tabpg_application
end type
type tab_2 from u_tab_app_info within u_tabpg_application
end type
type cbx_required_only from checkbox within u_tabpg_application
end type
type dw_cfa from u_dw within u_tabpg_application
end type
end forward

global type u_tabpg_application from u_tabpg_dbaccess
integer width = 2930
integer height = 2432
long backcolor = 134217731
string text = "Application"
string picturename = "EditDataFreeform!"
boolean ib_editaccess = true
tab_2 tab_2
cbx_required_only cbx_required_only
dw_cfa dw_cfa
end type
global u_tabpg_application u_tabpg_application

type variables
OLEObject			iou_OLE
integer ii_row
boolean ib_required, ib_notifystatuschange = False
end variables

forward prototypes
public subroutine of_create_factsheet ()
public subroutine of_create_phonesheet ()
public subroutine of_create_termsheet ()
public subroutine of_createmissingitems ()
public subroutine of_insertmissingitem (string as_type, string as_value)
public function integer of_smartgrowth ()
public subroutine of_create_sercert ()
public function integer of_populatebookmark (string as_bookmark, string as_value)
public function string of_getdate (string al_ref_code)
public function integer of_deletebookmark (string as_bookmark)
public function integer of_create_grant_status ()
public function string of_getstatus (long al_gigp, string as_code, string as_statuscol)
public function integer of_create_completioncert ()
end prototypes

public subroutine of_create_factsheet ();//*******************************************************
// Changes made 5/2011 by sw for Round 2 (Round 1 will no longer be allowed to create since they were EPA Approved
//*******************************************************
OLEObject	lou_OLE
Integer 		li_rc, li_round
String      	ls_value, ls_value2, ls_bookMark, ls_decRegion, ls_county, ls_docPath, ls_projNo, ls_formattedProj, ls_grant, ls_start_code, ls_end_code, ls_label3, ls_gprSummary, ls_round, ls_program
String 		ls_appName, ls_projName, ls_projDescription, ls_projSummary, ls_srfProgram, ls_fispsCode, ls_seqrType, ls_fundSummary, ls_label_start, ls_label_end, ls_ta_const, ls_ta_design, ls_muni
Long			ll_cfa_no, ll_count
Decimal     	ld_amount
DateTime    	ldt_construct

//*******************************************************
// If Round 1 App then give msg
//*******************************************************
If gl_gigp_id < 300 Then
	MessageBox('Fact Sheet', 'Please refer to the EPA-approved fact sheet located in the project file')
	Return
End If


//*******************************************************
// Connect to MS Word:
//*******************************************************
lou_OLE = CREATE OLEObject

li_rc = lou_OLE.ConnectToObject('', 'Word.Application')

If (li_rc <> 0)  Then 	
	li_rc = lou_OLE.ConnectToNewObject('Word.Application')

	If (li_rc <> 0)  Then
		MessageBox("ERROR!", "Error opening Microsoft Word.")
		Goto FinishUp
	End If	
End If


//*******************************************************
// Get most application data:
//*******************************************************
 SELECT	project_name,   
         	srf_program,   
         	dec_region,   
         	county_fips_code,			
			project_no,
			grant_type,
			round_no,
			cfa_no,
			program,
			muni_code
INTO		:ls_projName,			
			:ls_srfProgram,
			:ls_decRegion,
			:ls_fispsCode,			
			:ls_projNo,
			:ls_grant,
			:li_round,
			:ll_cfa_no,
			:ls_program,
			:ls_muni
FROM 	gigp_application   
WHERE	gigp_id = : gl_gigp_id;

ls_round = String(li_round)


//*******************************************************
// Open  Factsheet Template:
//*******************************************************
Select description
Into	 :ls_docPath
From 	 gigp_reference
Where  category     = 'template'
And    sub_category = 'factsheet'
And   ref_code = :ls_program;

lou_OLE.Documents.Add(ls_docPath)
//lou_OLE.ActiveDocument.Unprotect()   //SW, 7/20/09 - just because it was BUGGING THE CRAP OUT OF ME!!!!


//*******************************************************
// Populate Bookmarks::
//*******************************************************

//*********************
// ID:
//*********************
If ls_program = 'GIGP' or ls_program = 'PPG-EC' Then
	ls_value =  String(gl_gigp_id)
	ls_bookMark = "gigpid"
	
Else
	ls_value =  String(ll_cfa_no)
	ls_bookMark = "CFAno"
	
End If

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// SRF Program & Project:
//*********************
If ls_program = 'GIGP' Then
	ls_bookMark = "srfProgram"
	
	ls_value = (ls_srfProgram + "SRF")
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_value)
	End If
	
	ls_bookMark = "srfProjNo"
	
	ls_value = ls_projNo
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_value)
	End If
End If

//*********************
// Project Name:
//*********************
If IsNull(ls_projName) Then
	ls_value = ""
Else
	ls_value = ls_projName
End If

ls_bookMark = "projname"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

If ls_program = 'EPG' Then
	ls_bookMark = "appname2"
Else
	ls_bookMark = "projname2"
End If

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// Applicant Name:
//*********************
ls_appName = f_get_applicant_name(gl_gigp_id)

If IsNull(ls_appName) Then
	ls_value = ""
Else
	ls_value = ls_appName
End If

ls_bookMark = "appname"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

If ls_program <> 'EPG' Then
	ls_bookMark = "appname2"
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_value)
	End If
End If


//*********************
// Prior CWSRF Recipient (for EPGs to start)
//*********************
If ls_program = 'EPG' Then

	if gb_UseFinSchemaTables then
		select 	count(*)
		into		:ll_count
		from		Fin.Financing	f,
					dbo.Customer	c
		where 	f.ClosingDate	<= getdate()
		and		c.CustomerId	= f.CustomerId
		and 		c.MuniCode		= :ls_muni;
	else
		select 	count(*)
		into		:ll_count
		from		ls_loan
		where 	closing_dt <= getdate()
		and 		muni_code = :ls_muni;
	end if

	
	If ll_count > 0 Then
		ls_bookMark = 'PriorCWSRFYes'
	Else
		ls_bookMark = 'PriorCWSRFNo'
	End If
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
		lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
		lou_OLE.Selection.TypeText('X')
	End If
	
End If


//*********************
// Funding Source:
//*********************
If ls_program = 'GIGP' Then
	select ref_value
	into :ls_value
	from gigp_reference
	where category = 'FundSource'
	and sub_category = :ls_round;
	
	ls_bookMark = 'FundType'
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_value)
	End If
End If


//*********************
// Round number for EPG
//*********************
If ls_program = 'EPG' Then
	ls_bookMark = "roundno"
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_round)
	End If
	
End If


//*********************
// DEC Region:
//*********************
If ls_program = 'GIGP' Then
	If IsNull(ls_decRegion) Then
		ls_value = ""
	Else
		ls_value = ls_decRegion
	End If
	
	ls_bookMark = "decregion"
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_value)
	End If
End If

//*********************
// County:
//*********************
Select ref_value
Into	 :ls_county
From 	 gigp_reference
Where  category     = 'County'
And   ref_code = :ls_fispsCode;

If IsNull(ls_county) Then
	ls_value = ""
Else
	ls_value = ls_county
End If

ls_bookMark = "county"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// Total Project Costs:
//*********************
ld_amount = f_get_project_amount(gl_gigp_id, "RECTPF")
//ld_amount = f_get_project_amount(gl_gigp_id, "TPF")

//ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
ls_value = String(ld_amount, "$#,###,##0;($#,###,##0)")

If ld_amount = 0 Then ls_value = 'None'

ls_bookMark = "tpcosts"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// Total Funds Requested:
//*********************
ld_amount = f_get_project_amount(gl_gigp_id, "FR")

//ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
ls_value = String(ld_amount, "$#,###,##0;($#,###,##0)")

If ld_amount = 0 Then ls_value = 'None'

ls_bookMark = "tprequested"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// Recommended Funds:
//*********************
//ld_amount = f_get_project_amount(gl_gigp_id, "RECTPF")
ld_amount = f_get_project_amount(gl_gigp_id, "RECFR")  //SW, 7/20/09 as per Laurie

//ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
ls_value = String(ld_amount, "$#,###,##0;($#,###,##0)")

If ld_amount = 0 Then ls_value = 'None'

ls_bookMark = "recfunds"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// Other Funding Sources:
//*********************
ld_amount = f_get_project_amount(gl_gigp_id, "OTHFS")

//ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
ls_value = String(ld_amount, "$#,###,##0;($#,###,##0)")

If ld_amount = 0 Then ls_value = 'None'

ls_bookMark = "othsources"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// Local Share:
//*********************
ld_amount = f_get_project_amount(gl_gigp_id, "10MMN")

//ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
ls_value = String(ld_amount, "$#,###,##0;($#,###,##0)")

If ld_amount = 0 Then ls_value = 'None'

ls_bookMark = "localshare"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If



//*********************
// Project Description:
//*********************
SELECT	comments         		
INTO		:ls_projDescription		
FROM 	gigp_notes
WHERE	gigp_id = : gl_gigp_id
AND 		note_category = 'appNote'
AND        note_type = 'projDescription';

ls_bookMark = "projdescription"

If IsNull(ls_projDescription) Then
	ls_value = ""
Else
	ls_value = Trim(ls_projDescription)
End If

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// GPR Summary
//*********************
If ls_program = 'GIGP' Then
	SELECT	comments         		
	INTO		:ls_gprSummary
	FROM 	gigp_notes
	WHERE	gigp_id = : gl_gigp_id
	AND 		note_category = 'appNote'
	AND        note_type = 'gprsummary';
	
	ls_bookMark = "gprsummary"
	
	If IsNull(ls_gprSummary) Then
		ls_value = ""
	Else
		ls_value = Trim(ls_gprSummary)
	End If
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_value)
	End If
End If


//*********************
// Project Summary:
//*********************
SELECT	comments         		
INTO		:ls_projSummary		
FROM 	gigp_notes
WHERE	gigp_id = : gl_gigp_id
AND 		note_category = 'appNote'
AND        note_type = 'projSummary';

ls_bookMark = "projsummary"

If IsNull(ls_projSummary) Then
	ls_value = ""
Else
	ls_value = Trim(ls_projSummary)
End If

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// Funding Summary:
//*********************
SELECT	comments         		
INTO		:ls_fundSummary		
FROM 	gigp_notes
WHERE	gigp_id = : gl_gigp_id
AND 		note_category = 'appNote'
AND        note_type = 'fundSummary';

ls_bookMark = "fundsummary"

If IsNull(ls_fundSummary) Then
	ls_value = ""
Else
	ls_value = Trim(ls_fundSummary)
End If

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// SRF Program: removed 9/2016 as per Rebecca
//*********************
//ls_bookMark = "srfProgam"
//
//If(ls_srfProgram = "CW") Then
//	ls_value = "Clean Water SRF"
//ElseIf (ls_srfProgram = "DW") Then
//	ls_value = "Drinking Water SRF"
//Else
//	ls_value = ""
//End If
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//			lou_OLE.Selection.TypeText(ls_value)
//End If


//*********************
// Project Category:  removed 9/2016 as per Rebecca
//*********************
//If ls_program = 'GIGP' Then
//	ls_bookMark = "projCategory"
//	
//	SetNull(ls_value)
//	
//	ls_value = f_get_app_determination(gl_gigp_id)
//	
//	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//				lou_OLE.Selection.TypeText(ls_value)
//	End If
//End If

//*********************
// SEQR Findings:
//*********************
ls_bookMark = "seqrfindings"

SetNull(ls_value)

SELECT	keydate_comments  
INTO 		:ls_value
FROM 	gigp_key_dates  
WHERE 	ref_code = 'seqrEFCSEQRSGNOFF'
AND 		gigp_id = :gl_gigp_id; 

If IsNull(ls_value) Then
	ls_value = ""
Else
	ls_value = Trim(ls_value)
End If

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// Fill in dates based on Grant Type (Constr or Design)
//*********************

Choose Case ls_grant
	Case 'Construction'
		ls_start_code = 'readyCONSTRCOMM'	//SW, 11/2011
		ls_end_code =  'readyCONSTRCOMPL'	//SW, 11/2011
		ls_label_start = 'Construction Start'
		ls_label_end = 'Construction Completion'
		ls_label3 = ''
	Case 'Design'
		If ls_program = 'GIGP' Then
			ls_start_code = 'PFSC'
			ls_end_code =  'PCSPC'
			ls_label_start = 'Feasibility Study Completed'
			ls_label_end = 'Conceptual Site Plan Completed'
			ls_label3 = 'Final Project Report Completed'
		ElseIf ls_program = 'EPG' Then	//SW, 2/2013
			ls_start_code = 'epgEXECENGAGR'
			//ls_end_code =  'epgENGREPORTAPP'
			ls_end_code =  'epgANTICIPATEDCOMPL' //SW, 12/2021
			ls_label_start = 'Start'
			ls_label_end = 'Complete'
			ls_label3 = ''
		End If
End Choose

//***********************************
//Labels
//***********************************
If (lou_OLE.ActiveDocument.Bookmarks.Exists('labelStart')) Then
				lou_OLE.Selection.GoTo(True, 0, 0, 'labelStart')
				lou_OLE.Selection.TypeText(ls_label_start)
End If

If (lou_OLE.ActiveDocument.Bookmarks.Exists('labelEnd')) Then
			lou_OLE.Selection.GoTo(True, 0, 0, 'labelEnd')
			lou_OLE.Selection.TypeText(ls_label_end)
End If

If (lou_OLE.ActiveDocument.Bookmarks.Exists('label3')) Then
			lou_OLE.Selection.GoTo(True, 0, 0, 'label3')
			lou_OLE.Selection.TypeText(ls_label3)
End If


		
//*********************
//  Start:
//*********************
ls_bookMark = "constrStart"

SetNull(ldt_construct)

SELECT	keydate_value, keydate_choice, keydate_ind
INTO		:ldt_construct, :ls_ta_const, :ls_ta_design
FROM 	gigp_key_dates  
WHERE 	ref_code = :ls_start_code
AND 		gigp_id = :gl_gigp_id; 

If Not IsNull(ldt_construct) Then

	ls_value = String(ldt_construct, "mmmm d, yyyy")
	
	If ls_grant = 'Construction' and NOT IsNull (ls_ta_const) Then
		ls_value += ' (' + Upper(left(Trim(ls_ta_const), 1)) + ')'
	ElseIf ls_grant = 'Design' and NOT IsNull(ls_ta_design)  Then
		ls_value += ' (' + Upper(left(Trim(ls_ta_design), 1)) + ')'
	End If
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_value)
	End If

End If


//*********************
//  Completion:
//*********************
ls_bookMark = "constrEnd"

SetNull(ldt_construct)

SELECT	keydate_value, keydate_choice, keydate_ind
INTO		:ldt_construct, :ls_ta_const, :ls_ta_design
FROM 	gigp_key_dates  
WHERE 	ref_code = :ls_end_code
AND 		gigp_id = :gl_gigp_id; 

If Not IsNull(ldt_construct) Then

	ls_value = String(ldt_construct, "mmmm d, yyyy")
	
	If ls_grant = 'Construction' and NOT IsNull (ls_ta_const) Then
		ls_value += ' (' + Upper(left(Trim(ls_ta_const), 1)) + ')'
	ElseIf ls_grant = 'Design' and NOT IsNull(ls_ta_design) Then
		ls_value += ' (' + Upper(left(Trim(ls_ta_design), 1)) + ')'
	End If
	
	If ls_program = 'EPG' Then
		ls_value += ' (T)'
	End If
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_value)
	End If

End If

//*********************
//  Final Report for Design only:
//*********************
If ls_grant = 'Design' and ls_program = 'GIGP' Then
	SetNull(ldt_construct)
	
	SELECT	keydate_value, keydate_ind
	INTO		:ldt_construct, :ls_ta_design
	FROM 	gigp_key_dates  
	WHERE 	ref_code = 'PPERC'
	AND 		gigp_id = :gl_gigp_id;
	
	If Not IsNull(ldt_construct) Then
		
		ls_bookMark = 'date3'

		ls_value = String(ldt_construct, "mmmm d, yyyy")
		
		If NOT IsNull(ls_ta_design)  Then
			ls_value += ' (' + Upper(left(Trim(ls_ta_design), 1)) + ')'
		End If
		
		If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
					lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
					lou_OLE.Selection.TypeText(ls_value)
		End If
	
	End If
	
	
End If



//*******************************************************
// Finish Up:
//*******************************************************

FinishUp:

//lou_OLE.ActiveDocument.Protect(2, True)
lou_OLE.Visible = True

If IsValid(lou_OLE) Then lou_OLE.DisconnectObject()


end subroutine

public subroutine of_create_phonesheet ();

//*************************************************************
// Functionality remoced 11-05-2010 mpf
// Objects can be removed at a later date.
//*************************************************************

//Long li_count
//
//Datastore lds
//
//lds = CREATE Datastore
//
//lds.DataObject = 'd_phone_call_request_sheet_comp_rpt'
//
//lds.SetTransObject(SQLCA)
//
//li_count =  lds.Retrieve(gl_gigp_id)
//
//lds.Print()
//
//Destroy lds


end subroutine

public subroutine of_create_termsheet ();OLEObject	lou_OLE
Integer 		li_rc, li_index, N, li_upper, li_pos, li_cmtCnt, li_sort
String      	ls_value, ls_value2, ls_bookMark, ls_docPath, ls_missing[],  ls_dummy[], ls_seqrType
String 		ls_appName, ls_projName, ls_gigpFormattedID, ls_dunsNO, ls_fedIDNO, ls_naicsNO, ls_cat
u_mle           lu_mle
DateTime     ldt_value, ldt_date

lu_mle = CREATE u_mle

//*******************************************************
// Connect to MS Word:
//*******************************************************

lou_OLE = CREATE OLEObject

li_rc = lou_OLE.ConnectToObject('', 'Word.Application')

If (li_rc <> 0)  Then 	
	li_rc = lou_OLE.ConnectToNewObject('Word.Application')

	If (li_rc <> 0)  Then
		MessageBox("ERROR!", "Error opening Microsoft Word.")
		Goto FinishUp
	End If	
End If

//*******************************************************
// Open  Factsheet Template:
//*******************************************************

Select 	description
Into	 	:ls_docPath
From 	 	gigp_reference
Where  	category     = "template"
And    	sub_category = "termsheet"
And   		ref_code = "termsheet";

lou_OLE.Documents.Add(ls_docPath)

//lou_OLE.ActiveDocument.Unprotect()   //SW, 7/20/09 - just because it was BUGGING THE CRAP OUT OF ME!!!!

//*******************************************************
// Get most application data:
//*******************************************************

 SELECT	project_name,   
//         		gigp_formatted_id,   		 
         		duns_no,   
         		federal_id_no,   
         		naics_no,
			seqr_type
INTO		:ls_projName,
//			:ls_gigpFormattedID,
			:ls_dunsNO,
			:ls_fedIDNO,
			:ls_naicsNO,
			:ls_seqrType
FROM 	gigp_application   
WHERE	gigp_id = :gl_gigp_id;


//*******************************************************
// Populate Bookmarks:
//*******************************************************

//*********************
// Formatted GIGP ID:
//*********************

//ls_value = ls_gigpFormattedID
ls_value = String(gl_gigp_id)

ls_bookMark = "gigpID"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// Project Name:
//*********************

If IsNull(ls_projName) Then
	ls_value = ""
Else
	ls_value = ls_projName
End If

ls_bookMark = "projName"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// Applicant Name:
//*********************

ls_appName = f_get_applicant_name(gl_gigp_id)

If IsNull(ls_appName) Then
	ls_value = ""
Else
	ls_value = ls_appName
End If

ls_bookMark = "appName"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************************
// Missing Information:
//*********************************

//*********************
// DUNS No:
//*********************

If (IsNull(ls_dunsNO) Or Trim(ls_dunsNO) = "") Then	
	li_index++
	ls_missing[li_index] = "DUNS Number:"
End If

//*********************
// Federal ID No:
//*********************

If (IsNull(ls_fedIDNO) Or Trim(ls_fedIDNO) = "") Then
	li_index++
	ls_missing[li_index] = "Federal ID#:"
End If

//*********************
// NAICS Number:
//*********************

If (IsNull(ls_naicsNO) Or Trim(ls_naicsNO) = "") Then
	li_index++
	ls_missing[li_index] = "NAICS Number:"
End If

li_upper = UpperBound(ls_missing)

If (li_upper > 0) Then

	FOR N = 1 TO li_upper
	
		 ls_bookMark = ("missing" + String(N))
			
		ls_value	= ls_missing[N] 
			
		If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_value)
		End If
	
	NEXT

End If

//*********************************
// Reset variables:
//*********************************

li_index    = 0
ls_missing = ls_dummy

//*********************
// SEQR Type:
//*********************

If IsNull(ls_seqrType) Then ls_seqrType = ""

ls_value = ls_seqrType

ls_bookMark = "seqrType"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************************
// Missing SEQR Related Dates:
//*********************************

SetNull(ldt_value)	

DECLARE c123SEQRMISS CURSOR FOR
		SELECT	R.sub_category,   
         				R.description,
					D.keydate_value
		FROM 	gigp_reference R left outer join gigp_key_dates D on R.ref_code = D.ref_code and D.gigp_id = :gl_gigp_id
		WHERE  	R.category = 'SEQR'
		AND 		R.ref_code <> 'seqrEFCSEQRSGNOFF';
	
OPEN c123SEQRMISS;
	
FETCH c123SEQRMISS INTO :ls_value, :ls_value2, :ldt_value;
	
DO WHILE SQLCA.sqlcode = 0	
		
	li_pos = Pos(ls_value, ls_seqrType)	
	
	If (li_pos > 0) And IsNull(ldt_value) Then 				
		li_index++
		ls_missing[li_index] = ls_value2
	End If
			
	SetNull(ldt_value)		
			
	FETCH c123SEQRMISS INTO :ls_value, :ls_value2, :ldt_value;
	
LOOP
	
CLOSE c123SEQRMISS;			

li_upper = UpperBound(ls_missing)

If (li_upper > 0) Then

	FOR N = 1 TO li_upper
	
		 ls_bookMark = ("seqrMissing" + String(N))
			
		ls_value	= ls_missing[N] 
			
		If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_value)
		End If
	
	NEXT

End If

//*********************************
//Legal Comments:
//*********************************

DECLARE c123lglCmts CURSOR FOR
		SELECT comments, note_dt
		FROM gigp_notes  
		WHERE note_type = 'LGL'
		And gigp_id = :gl_gigp_id
		ORDER BY  note_dt ASC;
	
OPEN  c123lglCmts;
	
FETCH  c123lglCmts INTO :ls_value, :ldt_date;
	
DO WHILE SQLCA.sqlcode = 0
	
	li_cmtCnt++
	
	If (li_cmtCnt = 1) Then
		ls_value2 = ls_value
	Else
		ls_value2 += ("~n" + ls_value)
		
	End if
			
	FETCH  c123lglCmts INTO :ls_value, :ldt_date;
	
LOOP
	
CLOSE  c123lglCmts;		

lu_mle.Text = ls_value2

If Not IsNull(ls_value2) Then

	ls_bookMark = "legalCmts"
	
	If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(lu_mle.Text)
	End If

End If


//*********************************
// Reset variables:
//*********************************

li_index    = 0
ls_missing = ls_dummy

SetNull(ls_value)
SetNull(ls_value2)

//*********************************
// Missing Eng.  Related Dates:
//*********************************

SetNull(ldt_value)	

DECLARE c123ENGMISS CURSOR FOR
		SELECT	R.description,
					D.keydate_value,
					R.category,
					R.sort_order
		FROM 	gigp_reference R left outer join gigp_key_dates D on R.ref_code = D.ref_code and D.gigp_id = :gl_gigp_id
		WHERE  R.category = 'Readiness'
		AND      	R.ref_code in ('readyPROJPLANSUB','readyFINPLANSSUB')
		ORDER BY  R.category Desc,  R.sort_order ASC;

	
OPEN c123ENGMISS;
	
FETCH c123ENGMISS INTO :ls_value, :ldt_value, :ls_cat, :li_sort;
	
DO WHILE SQLCA.sqlcode = 0	
	
	If IsNull(ldt_value) Then 
		li_index++
		ls_missing[li_index] = ls_value
	End If
		
	SetNull(ldt_value)	
			
	FETCH c123ENGMISS INTO :ls_value, :ldt_value, :ls_cat, :li_sort;	
	
LOOP
	
CLOSE c123ENGMISS;			

li_upper = UpperBound(ls_missing)

If (li_upper > 0) Then

	FOR N = 1 TO li_upper
	
		 ls_bookMark = ("engMissing" + String(N))
			
		ls_value	= ls_missing[N] 
			
		If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
				lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				lou_OLE.Selection.TypeText(ls_value)
		End If
	
	NEXT

End If


//*******************************************************
// Finish Up:
//*******************************************************

FinishUp:

//lou_OLE.ActiveDocument.Protect(2, True)
lou_OLE.Visible = True

If IsValid(lou_OLE) Then lou_OLE.DisconnectObject()
Destroy lu_mle

end subroutine

public subroutine of_createmissingitems ();Integer	li_rc, li_212, li_319, li_320, li_cat
Long		ll_row, ll_count, ll_seqrtype, ll_find
String		ls_value, ls_docPath, ls_bookMark, ls_applicant, ls_project, ls_desc, ls_seqr, ls_cwa, ls_sort, ls_submis, ls_seqr_search, ls_ref_code, ls_text, ls_status, ls_comments
String		ls_coordinator, ls_tech, ls_engineer, ls_attorney, ls_award
String		ls_codes[]
Decimal 	ld_award
DateTime ldt_letter, ldt_value
n_ds lds_data

//Create Datastore
If NOT IsValid(lds_data) Then
	lds_data = CREATE n_ds
End If

//Initialize row for Word Table
ii_row = 0

If cbx_required_only.Checked Then
	ib_required = True
Else
	ib_required = False
End If

//*******************************************************
// Connect to MS Word:
//*******************************************************
iou_OLE = CREATE OLEObject

li_rc = iou_OLE.ConnectToObject('', 'Word.Application')

If (li_rc <> 0)  Then          
                li_rc = iou_OLE.ConnectToNewObject('Word.Application')

                If (li_rc <> 0)  Then
                                MessageBox("ERROR!", "Error opening Microsoft Word.")
                                Goto FinishUp
                End If    
End If

//*******************************************************
// Get Template:
//*******************************************************
Select 	description
Into        :ls_docPath
From 		gigp_reference
Where	category = 'Letter'
and 		sub_category = 'MissingItems';

iou_OLE.Documents.Add(ls_docPath)

//GIGP ID:
ls_value = String(gl_gigp_id)
ls_bookMark = "gigpID"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_value)
End If
ls_value = ''
														

//*******************************************************
// Get Application Info:
//*******************************************************
select 	applicant_name = (SELECT	C.organization
									FROM		gigp_contacts C, gigp_contact_links CL  
									WHERE 	C.contact_id = CL.contact_id    
									AND		CL.gigp_id = a.gigp_ID
									AND      	CL.contact_type = "APP"),
			a.project_name,
			a.seqr_type,
			'Part212' = (select count(*)
						from gigp_checklist
						where gigp_id = a.gigp_id
						and ref_code = 'pt212'
						and checklist_value = 1),
			'Part319' = (select count(*)
						from gigp_checklist
						where gigp_id = a.gigp_id
						and ref_code = 'pt319'
						and checklist_value = 1),
			'Part320' = (select count(*)
						from gigp_checklist
						where gigp_id = a.gigp_id
						and ref_code = 'pt320'
						and checklist_value = 1)
into 		:ls_applicant, :ls_project, :ls_seqr, :li_212, :li_319, :li_320
from 		gigp_application a
where 	a.gigp_id = :gl_gigp_id;


//Project Name
ls_bookMark = "projectName"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_project)
End If

//Award Amount
ld_award = f_get_project_amount(gl_gigp_id, "RECFR")
ls_award = String(ld_award, "$#,##0.00;($#,##0.00)")
ls_bookMark = "awardAmt"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_award)

End If

																
//Applicatn Name
ls_bookMark = "applicantName"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_applicant)

End If

//CWA Type
If li_212 > 0 Then
	ls_cwa = 'Part 212'
ElseIf li_319 > 0 Then
	ls_cwa = 'Part 319'
ElseIf li_320 > 0 Then
	ls_cwa = 'Part 320' 
Else
	ls_cwa = 'None'
End If

ls_bookMark = "cwaType"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_cwa)
End If
																
//SEQR Type
If IsNull(ls_seqr) Then ls_seqr = '[Not Received]'
ls_bookMark = "seqrType"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_seqr)
End If

//Get EFC Contacts:
select c.full_name
into :ls_coordinator
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.gigp_id = :gl_gigp_id
and cl.contact_type = 'EFCREVASSGN'
and c.status = 'Active';

select c.full_name
into :ls_tech
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.gigp_id = :gl_gigp_id
and cl.contact_type = 'EFCLANDARCH'
and c.status = 'Active';

select c.full_name
into :ls_engineer
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.gigp_id = :gl_gigp_id
and cl.contact_type = 'EFCENG'
and c.status = 'Active';

select c.full_name
into :ls_attorney
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.gigp_id = :gl_gigp_id
and cl.contact_type = 'EFCLGL'
and c.status = 'Active';

If IsNull(ls_coordinator) or ls_coordinator = '' then ls_coordinator = '[Undefined]'
If IsNull(ls_tech) or ls_tech = '' then ls_tech = '[Undefined]'
If IsNull(ls_engineer) or ls_engineer = '' then ls_engineer = '[Undefined]'
If IsNull(ls_attorney) or ls_attorney = '' then ls_attorney = '[Undefined]'

//Coordinator
ls_bookMark = "coordinator"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_coordinator)
End If
																
//Tech Reviewer
ls_bookMark = "tech"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_tech)
End If

//Engineer
ls_bookMark = "engineer"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_engineer)
End If

//Attorney
ls_bookMark = "attorney"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_attorney)
End If

//Project Description
select max(convert(varchar(1000), comments))
into :ls_value
from gigp_notes
where gigp_id = :gl_gigp_id
and note_category = 'appNote'
and note_type = 'projDescription';

If IsNull(ls_value) Then ls_value = '[No Project Description]'

ls_bookMark = "projectDesc"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_value)
End If


//*******************************************************
// Load MS Word Table:
//*******************************************************

//Get missing Project Readiness and Engineering
//now retrieving all rows even if there is no keydate
this.of_insertmissingitem('heading', 'Project Readiness and Engineering:')
this.of_insertmissingitem('sub_mis', 'Submitted:')
ls_submis = 'Submit'
lds_data.DataObject = 'd_keydates_checklist'
lds_data.SetTransObject(SQLCA)
ls_codes[] = {'readyDETAILBUD','readyPLANFINANCE','readyFEASIBILITY','readyFEASABILITY'}
ll_count = lds_data.Retrieve(gl_gigp_id, ls_codes)

If ll_count > 0 Then
	ls_sort = 'If(IsNull(gigp_key_dates_keydate_value), 2, 1) A, gigp_reference_sort_order A'
	lds_data.SetSort(ls_sort)
	lds_data.Sort()
	
	For ll_row = 1 to ll_count
		If lds_data.GetItemNumber(ll_row, 'gigp_reference_system_only') = 0 Then
			//ls_status = lds_data.GetItemString(ll_row, 'keydate_choice')
			ls_ref_code = lds_data.GetItemString(ll_row, 'gigp_reference_ref_code')
			ls_status = this.of_getstatus(gl_gigp_id, ls_ref_code, 'keydate_choice')

			ls_comments =  lds_data.GetItemString(ll_row, 'gigp_key_dates_keydate_comments')
			If IsNull(ls_comments) Then ls_comments = ''
			
			li_cat = lds_data.GetItemNumber(ll_row, 'gigp_reference_cat_default')
			ls_desc = lds_data.GetItemString(ll_row, 'gigp_reference_ref_value')
			
			ls_value = lds_data.GetItemString(ll_row, 'gigp_key_dates_keydate_ind')
			
			If IsNull(lds_data.GetItemDateTime(ll_row, 'gigp_key_dates_keydate_value')) Then
				If IsNull(ls_value) OR  ls_value <> 'NA' Then
					If ls_submis = 'Submit' Then
						this.of_insertmissingitem('item','')
						this.of_insertmissingitem('sub_mis', 'Missing:')
						ls_submis = 'Missing'
					End If
					
					ls_text =  lds_data.GetItemString(ll_row, 'gigp_reference_ref_value') + '    ' + ls_status
				
					If (Left(ls_text, 1) = '*' and ib_required) or NOT ib_required Then
						this.of_insertmissingitem('item', ls_text)
						If ls_comments > '' Then
							this.of_insertmissingitem('comment', ls_comments)
						End If
					End If

				End If
			Else

				ls_text =  lds_data.GetItemString(ll_row, 'gigp_reference_ref_value') + '    ' + ls_status
				
				If (Left(ls_text, 1) = '*' and ib_required) or NOT ib_required Then
					this.of_insertmissingitem('item', ls_text)
					If ls_comments > '' Then
						this.of_insertmissingitem('comment', ls_comments)
					End If
				End If
			End If
		End If
	Next
End If

this.of_insertmissingitem('item','')
this.of_insertmissingitem('item','')

//Get missing SEQR Dates
this.of_insertmissingitem('heading', 'New York State Environmental Quality Review (SEQR) & State Historic Preservation Office (SHPO):')
this.of_insertmissingitem('sub_mis', 'Submitted:')
ls_submis = 'Submit'

lds_data.DataObject = 'd_proj_project_seqrinsur_dates'
lds_data.SetTransObject(SQLCA)
ll_count = lds_data.Retrieve(gl_gigp_id)

If ll_count > 0 Then
	//Sort by Submitted / Missing criteria to group them on the Word doc
	ls_sort = 'If(IsNull(keydate_value), 2, 1) A, ref_sort_order A'
	lds_data.SetSort(ls_sort)
	lds_data.Sort()
	
	For ll_row = 1 to ll_count
		//As per Rebecca (5/2016)
		If lds_data.GetItemString(ll_row, 'ref_ref_code') = 'seqrSERPCERTCOMPL' Then Continue
		
		If lds_data.GetItemNumber(ll_row, 'system_only') = 0 Then
			ls_ref_code = lds_data.GetItemString(ll_row, 'ref_ref_code')
//			ls_status = lds_data.GetItemString(ll_row, 'keydate_ind')
			ls_status = this.of_getstatus(gl_gigp_id, ls_ref_code, 'keydate_ind')
			
			ls_comments =  lds_data.GetItemString(ll_row, 'keydate_comments')
			If IsNull(ls_comments) Then ls_comments = ''
			
			//Check SEQR status
			ls_seqr_search = '%' + ls_seqr + '%'
			
			select count(*)
			into :ll_seqrtype
			from gigp_reference
			where category = 'SEQR'
			and sub_category like :ls_seqr_search
			and ref_code = :ls_ref_code;
			
			If ll_seqrtype > 0 Then
		
				If IsNull(lds_data.GetItemDateTime(ll_row, 'keydate_value')) Then
					If ls_submis = 'Submit' Then
						this.of_insertmissingitem('item','')
						this.of_insertmissingitem('sub_mis', 'Missing:')
						ls_submis = 'Missing'
					End If
					
					ls_text =  lds_data.GetItemString(ll_row, 'ref_value') + '    ' + ls_status
					
					If (Left(ls_text, 1) = '*' and ib_required) or NOT ib_required Then
						If ls_status <> 'NA' Then
							this.of_insertmissingitem('item', ls_text)
							If ls_comments > '' Then
								this.of_insertmissingitem('comment', ls_comments)
							End If
						End If
					End If
					
				Else

				ls_text =  lds_data.GetItemString(ll_row, 'ref_value') + '    ' + ls_status
					
					If (Left(ls_text, 1) = '*' and ib_required) or NOT ib_required Then
						If ls_status <> 'NA' Then
							this.of_insertmissingitem('item', ls_text)
							If ls_comments > '' Then
								this.of_insertmissingitem('comment', ls_comments)
							End If
						End If
					End If
				End If
			End If
		End If
	Next
End If

this.of_insertmissingitem('item','')
this.of_insertmissingitem('item','')


//Get missing Legal Dates
this.of_insertmissingitem('heading', 'Legal:')
this.of_insertmissingitem('sub_mis', 'Submitted:')
ls_submis = 'Submit'

lds_data.DataObject = 'd_proj_project_legal_dates'
lds_data.SetTransObject(SQLCA)
ll_count = lds_data.Retrieve(gl_gigp_id)

If ll_count > 0 Then
	//Sort by Submitted / Missing criteria to group them on the Word doc
	ls_sort = "(If(cat_default = 1, (If((IsNull(keydate_choice) or keydate_choice = 'N'), 2, 1)), (If(IsNull(keydate_value), 2, 1)))) A, sort_order A"
	lds_data.SetSort(ls_sort)
	lds_data.Sort()
	
	For ll_row = 1 to ll_count
		If lds_data.GetItemNumber(ll_row, 'system_only') = 0 Then
			//ls_status = lds_data.GetItemString(ll_row, 'keydate_ind')
			ls_ref_code = lds_data.GetItemString(ll_row, 'ref_ref_code')
			ls_status = this.of_getstatus(gl_gigp_id, ls_ref_code, 'keydate_ind')

			ls_comments =  lds_data.GetItemString(ll_row, 'keydate_comments')
			If IsNull(ls_comments) Then ls_comments = ''
			
			li_cat = lds_data.GetItemNumber(ll_row, 'cat_default')
			ls_desc = lds_data.GetItemString(ll_row, 'ref_value')
			
			If li_cat = 1 Then
				ls_value = lds_data.GetItemString(ll_row, 'keydate_choice')
				
				If ls_value = 'N' Then
					If ls_submis = 'Submit' Then
						this.of_insertmissingitem('item','')
						this.of_insertmissingitem('sub_mis', 'Missing:')
						ls_submis = 'Missing'
					End If
					
					ls_text =  lds_data.GetItemString(ll_row, 'ref_value') + '    ' + ls_status
					
					If (Left(ls_text, 1) = '*' and ib_required) or NOT ib_required Then
						this.of_insertmissingitem('item', ls_text)
						If ls_comments > '' Then
							this.of_insertmissingitem('comment', ls_comments)
						End If
					End If
					
				ElseIf ls_value = 'Y' Then
					ls_text =  lds_data.GetItemString(ll_row, 'ref_value') + '    ' + ls_status
					
					If (Left(ls_text, 1) = '*' and ib_required) or NOT ib_required Then
						this.of_insertmissingitem('item', ls_text)
						If ls_comments > '' Then
							this.of_insertmissingitem('comment', ls_comments)
						End If
					End If
				End If
			Else
				ls_value = lds_data.GetItemString(ll_row, 'keydate_ind')
				
				If IsNull(lds_data.GetItemDateTime(ll_row, 'keydate_value')) Then
					If IsNull(ls_value) OR  ls_value <> 'NA' Then
						If ls_submis = 'Submit' Then
							this.of_insertmissingitem('item','')
							this.of_insertmissingitem('sub_mis', 'Missing:')
							ls_submis = 'Missing'
						End If
						
						ls_text =  lds_data.GetItemString(ll_row, 'ref_value') + '    ' + ls_status
					
						If (Left(ls_text, 1) = '*' and ib_required) or NOT ib_required Then
							this.of_insertmissingitem('item', ls_text)
							If ls_comments > '' Then
								this.of_insertmissingitem('comment', ls_comments)
							End If
						End If
	
					End If
				Else

					ls_text =  lds_data.GetItemString(ll_row, 'ref_value') + '    ' + ls_status
					
					If (Left(ls_text, 1) = '*' and ib_required) or NOT ib_required Then
						this.of_insertmissingitem('item', ls_text)
						If ls_comments > '' Then
							this.of_insertmissingitem('comment', ls_comments)
						End If
					End If
				End If
			End If
		End If
	Next
End If

this.of_insertmissingitem('item','')
this.of_insertmissingitem('item','')


//Insert MWBE standard items  
this.of_insertmissingitem('heading', 'Minority and Women Business Enterprise – Equal Employment Opportunity (MWBE-EEO):')

//4/2016 added MWBE Workplan
select keydate_choice
into :ls_value
from gigp_key_dates
where gigp_id = :gl_gigp_id
and ref_code = 'readyMWBEWORK';

If IsNull(ls_value) Then ls_value = 'MISSING'

this.of_insertmissingitem('item', '*MWBE Workplan.  Status:  ' + ls_value)

lds_data.DataObject = 'd_mwbe_missing_items'
lds_data.SetTransObject(SQLCA)
ll_count = lds_data.Retrieve()

If ll_count > 0 Then
	For ll_row = 1 to ll_count
		ls_value = lds_data.GetItemString(ll_row, 'description')
		
		If (Left(ls_value, 1) = '*' and ib_required) or NOT ib_required Then
			this.of_insertmissingitem('item', ls_value)
		End If
	Next
End If

this.of_insertmissingitem('item','')
this.of_insertmissingitem('item','')


//Get missing EFC Readiness
this.of_insertmissingitem('heading', 'EFC Readiness:')
this.of_insertmissingitem('sub_mis', 'Submitted:')
ls_submis = 'Submit'

lds_data.DataObject = 'd_keydates_checklist'
lds_data.SetTransObject(SQLCA)
ls_codes[] = {'readyDECFEASCONREV','readyCERTSNTDEC','readySERPCERTSNTREG','readySMARTGROWTH'}
ll_count = lds_data.Retrieve(gl_gigp_id, ls_codes)

If ll_count > 0 Then
	ls_sort = 'If(IsNull(gigp_key_dates_keydate_value), 2, 1) A, gigp_reference_sort_order A'
	lds_data.SetSort(ls_sort)
	lds_data.Sort()
	
	For ll_row = 1 to ll_count
		If lds_data.GetItemNumber(ll_row, 'gigp_reference_system_only') = 0 Then
			//ls_status = lds_data.GetItemString(ll_row, 'keydate_choice')
			ls_ref_code = lds_data.GetItemString(ll_row, 'gigp_reference_ref_code')
			ls_status = this.of_getstatus(gl_gigp_id, ls_ref_code, 'keydate_choice')

			ls_comments =  lds_data.GetItemString(ll_row, 'gigp_key_dates_keydate_comments')
			If IsNull(ls_comments) Then ls_comments = ''
			
			li_cat = lds_data.GetItemNumber(ll_row, 'gigp_reference_cat_default')
			ls_desc = lds_data.GetItemString(ll_row, 'gigp_reference_ref_value')
			
				ls_value = lds_data.GetItemString(ll_row, 'gigp_key_dates_keydate_ind')
				
				If IsNull(lds_data.GetItemDateTime(ll_row, 'gigp_key_dates_keydate_value')) Then
					If IsNull(ls_value) OR  ls_value <> 'NA' Then
						If ls_submis = 'Submit' Then
							this.of_insertmissingitem('item','')
							this.of_insertmissingitem('sub_mis', 'Missing:')
							ls_submis = 'Missing'
						End If
						
						ls_text =  lds_data.GetItemString(ll_row, 'gigp_reference_ref_value') + '    ' + ls_status
					
						If (Left(ls_text, 1) = '*' and ib_required) or NOT ib_required Then
							this.of_insertmissingitem('item', ls_text)
							If ls_comments > '' Then
								this.of_insertmissingitem('comment', ls_comments)
							End If
						End If
	
					End If
				Else

					ls_text =  lds_data.GetItemString(ll_row, 'gigp_reference_ref_value') + '    ' + ls_status
					
					If (Left(ls_text, 1) = '*' and ib_required) or NOT ib_required Then
						this.of_insertmissingitem('item', ls_text)
						If ls_comments > '' Then
							this.of_insertmissingitem('comment', ls_comments)
						End If
					End If
				End If
			End If
	Next
End If


//*******************************************************
// Finish Up:
//*******************************************************

FinishUp:

iou_OLE.Visible = True

If IsValid(iou_OLE) Then iou_OLE.DisconnectObject()
If IsValid(lds_data) Then DESTROY lds_data

return
end subroutine

public subroutine of_insertmissingitem (string as_type, string as_value);
// Load MS Word Table: Add row and set value
iou_OLE.ActiveDocument.Tables[2].Rows.Add()
ii_row++

If IsNull(as_value) Then as_value = ''

//If an "Item", just add the value w/ a tab before. If a "heading" then make it bold
Choose Case as_type
	Case 'heading'
		iou_OLE.ActiveDocument.Tables[2].Cell(ii_row, 1).Range.Text = as_value
		iou_OLE.ActiveDocument.Tables[2].Cell(ii_row, 1).Range.Font.Bold = 1
		iou_OLE.ActiveDocument.Tables[2].Cell(ii_row, 1).Range.Font.Underline = 1
		
	Case 'sub_mis'
		iou_OLE.ActiveDocument.Tables[2].Cell(ii_row, 1).Range.Text = as_value
		iou_OLE.ActiveDocument.Tables[2].Cell(ii_row, 1).Range.Font.Bold = 1
		iou_OLE.ActiveDocument.Tables[2].Cell(ii_row, 1).Range.ParagraphFormat.IndentCharWidth(2)
		
	Case 'item'
		iou_OLE.ActiveDocument.Tables[2].Cell(ii_row, 1).Range.Text = as_value
		iou_OLE.ActiveDocument.Tables[2].Cell(ii_row, 1).Range.ParagraphFormat.IndentCharWidth(4)
		
	Case 'comment'
		iou_OLE.ActiveDocument.Tables[2].Cell(ii_row, 1).Range.Text = 'Comment:  ' + as_value
		iou_OLE.ActiveDocument.Tables[2].Cell(ii_row, 1).Range.ParagraphFormat.IndentCharWidth(6)
		
		
End Choose

end subroutine

public function integer of_smartgrowth ();integer li_rc, li_question
string ls_docPath, ls_value, ls_bookmark, ls_projno, ls_desc, ls_projname, ls_answer, ls_round, ls_cfa, ls_applicant

//*******************************************************
// Connect to MS Word:
//*******************************************************
iou_OLE = CREATE OLEObject

li_rc = iou_OLE.ConnectToObject('', 'Word.Application')

If (li_rc <> 0)  Then          
                li_rc = iou_OLE.ConnectToNewObject('Word.Application')

                If (li_rc <> 0)  Then
                                MessageBox("ERROR!", "Error opening Microsoft Word.")
                                Goto FinishUp
                End If    
End If

//*******************************************************
// Get data:
//*******************************************************
//Template
Select 	description
Into        :ls_docPath
From 		gigp_reference
Where	category = 'template'
and 		sub_category = 'smartgrowth';

iou_OLE.Documents.Add(ls_docPath)


//App data
select a.project_no,
		a.project_name,
		a.round_no,
		a.cfa_no
into :ls_projno, :ls_projname, :ls_round, :ls_cfa
from gigp_application a
where a.gigp_id = :gl_gigp_id;

If IsNull(ls_projno) Then ls_projno = ''
If IsNull(ls_projname) Then ls_projname = ''
If IsNull(ls_round) Then ls_round = ''
If IsNull(ls_cfa) Then ls_cfa = ''

//Project Description
select convert(varchar(1000), comments)
into :ls_desc
from gigp_notes
where gigp_id = :gl_gigp_id
and note_type = 'projDescription';

//Applicant
select organization
into :ls_applicant
from gigp_contacts, gigp_contact_links
where gigp_contacts.contact_id = gigp_contact_links.contact_id
and gigp_contact_links.contact_type = 'APP'
and gigp_contact_links.gigp_id = :gl_gigp_id;


//*******************************************************
// Fill in values:
//*******************************************************

ls_bookMark = "applicant"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_applicant)
End If

ls_bookMark = "projectname"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_projname)
End If

ls_bookMark = "roundno"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_round)
End If

ls_bookMark = "gigpid"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(String(gl_gigp_id))
End If


ls_bookMark = "projno"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_projno)
End If

ls_bookMark = "cfano"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_cfa)
End If

ls_bookMark = "projdesc"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
                                                iou_OLE.Selection.TypeText(ls_desc)
End If


//Get Smart Growth Answers... Questions 1059 to 1068. May need to get from DB if change for Round 4
For li_question = 1059 to 1068
	
	SetNull(ls_answer)

	select r3.answer
	into :ls_answer
	from gigp_application a, gigp_cfa_raw_data r3
	where a.cfa_no = r3.app_id
	and a.gigp_id = :gl_gigp_id
	and a.round_no = r3.round_no
	and r3.question_id = :li_question;
	
	If NOT IsNull(ls_answer) and ls_answer > '' Then
	
		ls_bookmark = 'Q' + String(li_question)
		
		If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			
				iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
				iou_OLE.Selection.TypeText(ls_answer)
				
		End If
		
	End If
	

Next

//Go to the top
ls_bookMark = "top"
If (iou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
                                                iou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
End If


//*******************************************************
// Finish Up:
//*******************************************************

FinishUp:

iou_OLE.Visible = True

If IsValid(iou_OLE) Then iou_OLE.DisconnectObject()

Return 1

end function

public subroutine of_create_sercert ();integer li_rc, li_count
string ls_docPath, ls_program, ls_projName, ls_bookMark, ls_value, ls_seqrType, ls_region, ls_regionContact, ls_today, ls_proj_no, ls_appName
string ls_address, ls_town, ls_county, ls_projDesc, ls_fips, ls_leadAgency
boolean lb_212, lb_319, lb_320

//*******************************************************
// Get base application data:
//*******************************************************
 SELECT	project_name,
 			program,
			seqr_type,
			dec_region,
			project_no,
			county_fips_code
INTO		:ls_projName,
			:ls_program,
			:ls_seqrType,
			:ls_region,
			:ls_proj_no,
			:ls_fips
FROM 	gigp_application   
WHERE	gigp_id = :gl_gigp_id;

If ls_program <> 'GIGP' Then
	MessageBox('Serp Certification Memo', 'This Memo is not available for Planning Grants.')
	Return
End If

//*******************************************************
// Connect to MS Word:
//*******************************************************
If IsValid(iou_OLE) Then Destroy(iou_OLE)

iou_OLE = CREATE OLEObject
li_rc = iou_OLE.ConnectToObject('', 'Word.Application')
If (li_rc <> 0)  Then 	
	li_rc = iou_OLE.ConnectToNewObject('Word.Application')

	If (li_rc <> 0)  Then
		MessageBox("ERROR!", "Error opening Microsoft Word.")
		Goto FinishUp
	End If	
End If


//*******************************************************
// Open  Factsheet Template:
//*******************************************************
Select description
Into	 :ls_docPath
From 	 gigp_reference
Where  category     = "template"
And    sub_category = "SerpCert"
And   ref_code = :ls_program;

iou_OLE.Documents.Add(ls_docPath)

//*******************************************************
// Determine which part(s) project is (212, 319, 320).  If 212, then delete the others:
//*******************************************************
select count(*)
into :li_count
from gigp_checklist
where gigp_id = :gl_gigp_id
and ref_code = 'pt212'
and checklist_value = 1;

If li_count > 0 Then
	lb_212 = True
	lb_319 = False
	lb_320 = False
	
	//Remove other sections
	of_deletebookmark('Part319_320Section')
	
Else
	select count(*)
	into :li_count
	from gigp_checklist
	where gigp_id = :gl_gigp_id
	and ref_code = 'pt319'
	and checklist_value = 1;
	
	If li_count > 0 Then lb_319 = True
	
	select count(*)
	into :li_count
	from gigp_checklist
	where gigp_id = :gl_gigp_id
	and ref_code = 'pt320'
	and checklist_value = 1;
	
	If li_count > 0 Then lb_320 = True
	
	//Remove other section
	If lb_319 or lb_320 Then
		of_deletebookmark('Part212Section')
	Else
		MessageBox('Serp Certification Memo', 'This project has not been designated as Part 212, 319 or 320.')
		Goto FinishUp 
	End If
	
End If


//*******************************************************
// Get General Data
//*******************************************************
If ls_region > '' Then
	select description
	into :ls_regionContact
	from gigp_reference
	where category = 'decRegion'
	and ref_code = :ls_region;
Else
	ls_regionContact = '[FILL IN REGIONAL CONTACT]'
End If

ls_today = String(Today(), 'mm/dd/yyyy')
ls_appName = f_get_applicant_name(gl_gigp_id)

select mail_address1, mail_city
into :ls_address, :ls_town
from gigp_contacts
where contact_id = (select max(contact_id)
							from gigp_contact_links
							where gigp_id = :gl_gigp_id
							and contact_type = 'APP');

If ls_fips > '' Then
	select ref_value
	into :ls_county
	from gigp_reference
	where category = 'County'
	and ref_code = :ls_fips;
Else
	ls_county = '[INSERT COUNTY]'
End If

select convert(varchar(1000), comments)
into :ls_projDesc
from gigp_notes
where note_category = 'appNote'
and note_type = 'seqrsummDesc'
and gigp_id = :gl_gigp_id;

If IsNull(ls_projDesc) or ls_projDesc = '' Then ls_projDesc = '[INSERT SEQR SUMMARY]'


//*******************************************************
// Populate Bookmarks by section:
//*******************************************************

//Header
of_populateBookmark('headerRegionContact',ls_RegionContact)
of_populateBookmark('headerGigpId',String(gl_gigp_id))
of_populateBookmark('headerProjNo',ls_proj_no)
of_populateBookmark('headerApplicant',ls_appName)
of_populateBookmark('headerAddress',ls_address)
of_populateBookmark('headerTown',ls_town)
of_populateBookmark('headerCounty',ls_county)
of_populateBookmark('headerProjDesc',ls_projDesc)

//Part 212
If lb_212 Then
	Choose Case ls_seqrType
		Case 'Type1', 'Unlisted'
			of_deletebookmark('Part212Type2')  //Remove Type 2
			of_populateBookmark('Part212SeqrType', ls_seqrType)
			of_populateBookmark('Part212Type1_date1', of_getDate('seqrEAFFORMVER'))
			of_populateBookmark('Part212Type1_date2', of_getDate('seqrDECLRESOLRCVD'))
			of_populateBookmark('Part212Type1_date3', of_getDate('seqrENBPUBDT'))
			of_populateBookmark('Part212Type1_date4', of_getDate('seqrFINSHPOSOLTR'))
			
			select convert(varchar(1000), keydate_comments)
			into :ls_leadAgency
			from gigp_key_dates
			where gigp_id = :gl_gigp_id
			and ref_code = 'seqrLASLTRISS';
			
			If IsNull(ls_leadAgency) or ls_leadAgency = '' Then ls_leadAgency = '[INSERT LEAD AGENCY]'

			of_populateBookmark('Part212_LeadAgency', ls_leadAgency)
		
		Case 'Type2'
			of_deletebookmark('Part212Type1')  //Remove Type 1
			of_populateBookmark('Part212Type2_date1', of_getDate('seqrFINSHPOSOLTR'))
			
	End Choose
	
End If

//Part 319 / 320
If lb_319 or lb_320 Then
	Choose Case ls_seqrType
		Case 'Type1'
			of_deletebookmark('Part319_320Type2') //Remove Type 2
			of_deletebookmark('Part319_320TypeUnlisted') //Remove Type Unlisted
			of_populateBookmark('Part319_320Type1_date1', of_getDate('seqrEAFFORMVER'))
			of_populateBookmark('Part319_320Type1_date2', of_getDate('seqrDECLRESOLRCVD'))
			of_populateBookmark('Part319_320Type1_date3', of_getDate('seqrENBPUBDT'))
			of_populateBookmark('Part319_320Type1_date4', of_getDate('seqrFINSHPOSOLTR'))
			
			select convert(varchar(1000), keydate_comments)
			into :ls_leadAgency
			from gigp_key_dates
			where gigp_id = :gl_gigp_id
			and ref_code = 'seqrLASLTRISS';
			
			If IsNull(ls_leadAgency) or ls_leadAgency = '' Then ls_leadAgency = '[INSERT LEAD AGENCY]'

			of_populateBookmark('Part319_320Type1_LeadAgency', ls_leadAgency)
			
		Case 'Type2'
			of_deletebookmark('Part319_320Type1') //Remove Type 1
			of_deletebookmark('Part319_320TypeUnlisted') //Remove Type Unlisted
			of_populateBookmark('Part319_320Type2_date1', of_getDate('seqrFINSHPOSOLTR'))
			
		Case 'Unlisted'
			of_deletebookmark('Part319_320Type1') //Remove Type 1
			of_deletebookmark('Part319_320Type2') //Remove Type 2
			of_populateBookmark('Part319_320TypeUnlisted_date1', of_getDate('seqrEAFFORMVER'))
			of_populateBookmark('Part319_320TypeUnlisted_date2', of_getDate('seqrDECLRESOLRCVD'))
			of_populateBookmark('Part319_320TypeUnlisted_date3', of_getDate('seqrFINSHPOSOLTR'))
			
			select convert(varchar(1000), keydate_comments)
			into :ls_leadAgency
			from gigp_key_dates
			where gigp_id = :gl_gigp_id
			and ref_code = 'seqrLASLTRISS';
			
			If IsNull(ls_leadAgency) or ls_leadAgency = '' Then ls_leadAgency = '[INSERT LEAD AGENCY]'

			of_populateBookmark('Part319_320TypeUnlisted_LeadAgency', ls_leadAgency)
			
	End Choose
	
End If


FinishUp:
If iou_OLE.ActiveDocument.Bookmarks.Exists('Top') Then
	iou_OLE.Selection.GoTo(True, 0, 0, 'Top')
End If
iou_OLE.Visible = True
If IsValid(iou_OLE) Then iou_OLE.DisconnectObject()

end subroutine

public function integer of_populatebookmark (string as_bookmark, string as_value);If NOT IsValid(iou_OLE) Then
	Return -1
End If

//Code to populate bookmark
If iou_OLE.ActiveDocument.Bookmarks.Exists(as_bookmark) Then
	// GoTo bookmark location and paste in data
	iou_OLE.Selection.GoTo(True, 0, 0, as_bookmark)
	
	iou_OLE.Selection.TypeText(as_value)
End If

Return 1
end function

public function string of_getdate (string al_ref_code);datetime ldt_date
string ls_date

SetNull(ldt_date)

select keydate_value2
into :ldt_date
from gigp_key_dates
where gigp_id = :gl_gigp_id
and ref_code = :al_ref_code;

If IsNull(ldt_date)Then
	ls_date = '[INSERT DATE]'
Else
	ls_date = String(Date(ldt_date), 'mm/dd/yyyy')
End If

Return ls_date
end function

public function integer of_deletebookmark (string as_bookmark);If NOT IsValid(iou_OLE) Then
	Return -1
End If

//Code to populate bookmark
If iou_OLE.ActiveDocument.Bookmarks.Exists(as_bookmark) Then
	// GoTo bookmark location and paste in data
	iou_OLE.Selection.GoTo(True, 0, 0, as_bookmark)
	iou_OLE.Selection.Delete
End If

Return 1
end function

public function integer of_create_grant_status ();//*******************************************************
// Changes made 5/2011 by sw for Round 2 (Round 1 will no longer be allowed to create since they were EPA Approved
//*******************************************************
OLEObject	lou_OLE
Integer 		li_rc, li_round
String      	ls_value, ls_value2, ls_bookMark, ls_decRegion, ls_county, ls_docPath, ls_projNo, ls_formattedProj, ls_grant, ls_start_code, ls_end_code, ls_label3, ls_gprSummary, ls_round, ls_program
String 		ls_appName, ls_projName, ls_projDescription, ls_projSummary, ls_srfProgram, ls_fispsCode, ls_seqrType, ls_fundSummary, ls_label_start, ls_label_end, ls_ta_const, ls_ta_design
String			ls_gpirep, ls_legal, ls_engineer
Long			ll_cfa_no, ll_ppu
Decimal     	ld_amount
DateTime    	ldt_construct

//*******************************************************
// Connect to MS Word:
//*******************************************************
lou_OLE = CREATE OLEObject

li_rc = lou_OLE.ConnectToObject('', 'Word.Application')

If (li_rc <> 0)  Then 	
	li_rc = lou_OLE.ConnectToNewObject('Word.Application')

	If (li_rc <> 0)  Then
		MessageBox("ERROR!", "Error opening Microsoft Word.")
		Goto FinishUp
	End If	
End If


//*******************************************************
// Get most application data:
//*******************************************************
 SELECT	project_name,   
         		srf_program,   
         		dec_region,   
         		county_fips_code,			
			project_no,
			grant_type,
			round_no,
			cfa_no
INTO		:ls_projName,			
			:ls_srfProgram,
			:ls_decRegion,
			:ls_fispsCode,			
			:ls_projNo,
			:ls_grant,
			:li_round,
			:ll_cfa_no
FROM 	gigp_application   
WHERE	gigp_id = : gl_gigp_id;


//*******************************************************
// Open  Factsheet Template:
//*******************************************************
Select description
Into	 :ls_docPath
From 	 gigp_reference
Where  category     = "template"
And    sub_category = "grantstatus";

lou_OLE.Documents.Add(ls_docPath)

//*******************************************************
// Populate Bookmarks::
//*******************************************************

ls_value =  String(gl_gigp_id)
ls_bookMark = "gigpid"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// Project:
//*********************
ls_bookMark = "srfProjNo"
ls_value = ls_projNo
If IsNull(ls_value) Then ls_value = '[NO PROJ#]'

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// Project Name:
//*********************
If IsNull(ls_projName) Then
	ls_value = ""
Else
	ls_value = ls_projName
End If

ls_bookMark = "projname"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// Applicant Name:
//*********************
ls_appName = f_get_applicant_name(gl_gigp_id)

If IsNull(ls_appName) Then
	ls_value = ""
Else
	ls_value = ls_appName
End If

ls_bookMark = "appname"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// County:
//*********************
Select ref_value
Into	 :ls_county
From 	 gigp_reference
Where  category     = "County"
And   ref_code = :ls_fispsCode;

If IsNull(ls_county) Then
	ls_value = ""
Else
	ls_value = ls_county
End If

ls_bookMark = "county"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//*********************
// Project Description:
//*********************
SELECT	comments         		
INTO		:ls_projDescription		
FROM 	gigp_notes
WHERE	gigp_id = : gl_gigp_id
AND 		note_category = 'appNote'
AND        note_type = 'projDescription';

ls_bookMark = "projdescription"

If IsNull(ls_projDescription) Then
	ls_value = ""
Else
	ls_value = Trim(ls_projDescription)
End If

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
//EFC Staff
//*********************
select max(c.full_name)
into :ls_engineer
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.gigp_id = :gl_gigp_id
and cl.contact_type = 'EFCENG';

If IsNull(ls_engineer) Then ls_engineer = '[FILL IN REP]'

ls_bookMark = "engineeringrep"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_engineer)
End If


select max(c.full_name)
into :ls_legal
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.gigp_id = :gl_gigp_id
and cl.contact_type = 'EFCLGL';

If IsNull(ls_legal) Then ls_legal = '[FILL IN REP]'

ls_bookMark = "legalrep"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_legal)
End If


select max(c.full_name)
into :ls_gpirep
from gigp_contacts c, gigp_contact_links cl
where c.contact_id = cl.contact_id
and cl.gigp_id = :gl_gigp_id
and cl.contact_type = 'EFCREVASSGN';

If IsNull(ls_gpirep) Then ls_gpirep = '[FILL IN REP]'

ls_bookMark = "gppirep"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_gpirep)
End If



//*********************
// Total Project Costs:
//*********************
ld_amount = f_get_project_amount(gl_gigp_id, "RECTPF")
//ld_amount = f_get_project_amount(gl_gigp_id, "TPF")

ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")

ls_bookMark = "tpcosts"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


////*********************
//// Total Funds Requested:
////*********************
//ld_amount = f_get_project_amount(gl_gigp_id, "FR")
//
//ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")
//
//ls_bookMark = "tprequested"
//
//If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
//			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
//			lou_OLE.Selection.TypeText(ls_value)
//End If
//

//*********************
// Recommended Funds:
//*********************
//ld_amount = f_get_project_amount(gl_gigp_id, "RECTPF")
ld_amount = f_get_project_amount(gl_gigp_id, "RECFR")  //SW, 7/20/09 as per Laurie

ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")

ls_bookMark = "recfunds"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// Other Funding Sources:
//*********************
ld_amount = f_get_project_amount(gl_gigp_id, "OTHFS")

ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")

ls_bookMark = "othsources"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// Local Share:
//*********************
ld_amount = f_get_project_amount(gl_gigp_id, "10MMN")

ls_value = String(ld_amount, "$#,###,##0.00;($#,###,##0.00)")

ls_bookMark = "localshare"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// PPU:
//*********************
ll_ppu = dw_1.GetItemNumber(dw_1.GetRow(), 'ppu')

If IsNull(ll_ppu) Then
	ls_value = '[INSERT PPU]'
Else
	ls_value = String(ll_ppu) + ' Years'
End If

ls_bookMark = "ppu"

If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*******************************************************
// Finish Up:
//*******************************************************

FinishUp:
lou_OLE.Selection.GoTo(True, 0, 0, 'top')
//lou_OLE.ActiveDocument.Protect(2, True)
lou_OLE.Visible = True

If IsValid(lou_OLE) Then lou_OLE.DisconnectObject()

Return 1
end function

public function string of_getstatus (long al_gigp, string as_code, string as_statuscol);string ls_status, ls_choice, ls_date, ls_ind
datetime ldt_date
long ll_count

If IsNull(al_gigp) or al_gigp <= 0 or as_code = '' Then
	Return ''
End If

select count(*)
into :ll_count
from gigp_key_dates 
where gigp_id = :al_gigp
and ref_code = :as_code;

If ll_count > 0 Then
	Select keydate_choice, keydate_ind, keydate_value2
	into :ls_choice, :ls_ind, :ldt_date
	from gigp_key_dates
	where gigp_id = :al_gigp
	and ref_code = :as_code;
	
	If IsNull(ls_choice) or ls_choice = '' Then ls_choice = 'UKNOWN'
	If IsNull(ls_ind) or ls_ind = '' Then ls_ind = 'UKNOWN'
	
	If IsNull(ldt_date) then 
		ls_date = 'Unk'
	Else
		ls_date = String(ldt_date, "mm/dd/yyyy")
	End If
	
	If as_statuscol = 'keydate_ind' Then
		ls_status = '[' + ls_ind + ' (' + ls_date + ')]'
	Else
		ls_status = '[' + ls_choice + ' (' + ls_date + ')]'
	End If
	
Else
	//ls_status = '[Not Received]'
	ls_status = ''
	
End If

return ls_status
end function

public function integer of_create_completioncert ();OLEObject	lou_OLE
integer li_rc
String ls_value, ls_bookMark, ls_docPath, ls_applicant, ls_projName, ls_projectnumber, ls_countycode, ls_county, ls_address, ls_desc
DateTime  ldt_date
n_cst_string ln_string

//*******************************************************
// Connect to MS Word:
//*******************************************************
lou_OLE = CREATE OLEObject

li_rc = lou_OLE.ConnectToObject('', 'Word.Application')

If (li_rc <> 0)  Then 	
	li_rc = lou_OLE.ConnectToNewObject('Word.Application')

	If (li_rc <> 0)  Then
		MessageBox("ERROR!", "Error opening Microsoft Word.")
		Goto FinishUp
	End If	
End If

//*******************************************************
// Open  Factsheet Template:
//*******************************************************
Select description
Into :ls_docPath
From gigp_reference
Where category     = "template"
And ref_code = "completioncert";

lou_OLE.Documents.Add(ls_docPath)


//*******************************************************
// Get application data:
//*******************************************************
select project_name, project_no, county_fips_code
into :ls_projName, :ls_projectnumber, :ls_countycode
from gigp_application   
where gigp_id = :gl_gigp_id;

If ln_string.of_isempty(ls_projName) Then ls_projName = '[UNKNOWN]'

If ln_string.of_isempty(ls_projectnumber) Then 
	ls_projectnumber = '[UNKNOWN]'
Else
	select substring(SrfProgram, 1, 1) + Substring(Convert(Char, DecRegion), 1, 1) + '-' + ProjectNumber
	into :ls_projectnumber
	from Project
	where ProjectNumber = :ls_projectnumber;
End If


If IsNull(ls_countycode) Then ls_countycode = ''

ls_applicant = f_get_applicant_name(gl_gigp_id)
If ln_string.of_isempty(ls_applicant) Then ls_applicant = '[UNKNOWN]'

//Agreement Date
select keydate_value
into :ldt_date
from gigp_key_dates
where gigp_id = :gl_gigp_id
and ref_code = 'agreeAGRFULLEX';

//Address from Location record
select mail_address1
into :ls_address
from gigp_contacts
where contact_id = (select max(contact_id)
								from gigp_contact_links 
								where gigp_id = :gl_gigp_id
								and contact_type = 'PLC'); 
								
If ln_string.of_isempty(ls_address) Then ls_address = '[UNKNOWN]'
								
//Project Description
select comments
into :ls_desc
from gigp_notes
where gigp_id = :gl_gigp_id
and note_type = 'projDescription';

If ln_string.of_isempty(ls_desc) Then ls_desc = '[UNKNOWN]'


//*******************************************************
// Populate Bookmarks:
//*******************************************************
//Project Number
ls_bookMark = "ProjectNumber1"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_projectnumber)
End If


//GIGP Id
ls_value = String(gl_gigp_id)
ls_bookMark = "GigpId1"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//Applicant (2)
ls_bookMark = "Applicant"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_applicant)
End If

ls_bookMark = "Applicant2"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_applicant)
End If


//Agreement Date (2)
If NOT IsNull(ldt_date) Then
	ls_value = String(ldt_date, 'mmmm dd, yyyy')
Else
	ls_value = 'UNKNOWN'
End If

ls_bookMark = "AgreementDate"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

ls_bookMark = "AgreementDate2"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If


//*********************
// Table
//*********************
//Applicant
ls_bookMark = "Applicant3"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_applicant)
End If

//Project Number / GIGP Id
ls_value = ls_projectnumber + ' / GIGP ' + String(gl_gigp_id)
ls_bookMark = "ProjectNumber2"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_value)
End If

//County
If ls_countycode > '' Then
	select ref_value
	into :ls_county
	from gigp_reference
	where category = 'County'
	and ref_code = :ls_countycode;
Else
	ls_county = '[UNKNOWN]'
End If

ls_bookMark = "County"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_county)
End If


//Address
ls_bookMark = "Address"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_address)
End If

//Project Name
ls_bookMark = "ProjectName"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_projName)
End If


//Project Description
ls_bookMark = "ProjectDescription"
If (lou_OLE.ActiveDocument.Bookmarks.Exists(ls_bookMark)) Then
			lou_OLE.Selection.GoTo(True, 0, 0, ls_bookMark)
			lou_OLE.Selection.TypeText(ls_desc)
End If



//*******************************************************
// Finish Up:
//*******************************************************
FinishUp:
lou_OLE.Visible = True

If IsValid(lou_OLE) Then lou_OLE.DisconnectObject()

Return 1
end function

on u_tabpg_application.create
int iCurrent
call super::create
this.tab_2=create tab_2
this.cbx_required_only=create cbx_required_only
this.dw_cfa=create dw_cfa
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tab_2
this.Control[iCurrent+2]=this.cbx_required_only
this.Control[iCurrent+3]=this.dw_cfa
end on

on u_tabpg_application.destroy
call super::destroy
destroy(this.tab_2)
destroy(this.cbx_required_only)
destroy(this.dw_cfa)
end on

event ue_tab_selected;call super::ue_tab_selected;
//*************************************************************
// Force Re-Retrieve of Project Description Checklist:
//*************************************************************

tab_2.SelectedTab = 1
tab_2.tabpage_1.of_retrieve()


end event

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Application"}
end event

event ue_tab_deselected;call super::ue_tab_deselected;
//dw_3.Visible = False
end event

type dw_1 from u_tabpg_dbaccess`dw_1 within u_tabpg_application
string tag = "Project General"
integer width = 2894
integer height = 916
string dataobject = "d_proj_application_info"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_1::constructor;call super::constructor;This.ib_RMBMenu = False

end event

event dw_1::sqlpreview;call super::sqlpreview;String	ls_category
Long 	ll_gigpID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	
	ll_gigpID = This.GetItemNumber(row, "gigp_id")
	ls_category = This.Tag	
	
	f_transactionlog("gigp_id", ll_gigpID, This.DataObject, ls_category, sqlsyntax)
END IF
end event

event dw_1::itemchanged;call super::itemchanged;This.SetItem(row, "last_updated_by", gnv_app.of_getuserid())
This.SetItem(row, "last_updated_dt", f_getdbdatetime())

//If the Project Status of a GIGP project is changed, notify Group
If dwo.name = 'project_status_cd' Then
	If this.GetItemString(row, 'program') = 'GIGP' Then
		ib_notifystatuschange = True
	End If
End If
end event

event dw_1::buttonclicked;call super::buttonclicked;string ls_Text, ls_access
integer li_RC, li_locked

Choose Case dwo.Name
	Case 'b_factsheet'
		of_create_factsheet()
		
	Case 'b_smartgrowth'
		of_smartgrowth()
		
	Case 'b_phonesheet'
		of_create_phonesheet()
		
	Case 'b_termsheet'
		of_create_termsheet()
		
	Case 'b_docstatus'
		of_createMissingItems()
		
	Case 'b_serpcert'
		of_create_sercert()
		
//	Case 'b_grant_status'		//changed to b_completioncert
//		of_create_grant_status()

	Case 'b_completioncert'
		of_create_completioncert()
		
	Case 'b_benefits'
		openwithparm(w_project_benefit, gl_gigp_id)
		
	Case 'b_cfa'
		If dw_cfa.Visible = False Then 
			dw_cfa.Retrieve(this.GetItemNumber(1, 'cfa_no'), this.GetItemNumber(1, 'round_no'))
			dw_cfa.x = 10
			dw_cfa.y = 10
			dw_cfa.Width = 4000
			dw_cfa.Height = parent.Height - 250
			dw_cfa.Visible = True
		End If
		
	Case 'b_consentordecomments'
		this.AcceptText()
		ls_access = "READ"
		
		li_locked = this.GetItemNumber(row, 'locked_flag')
		
		If li_locked = 0 and ib_editAccess = True Then
			ls_access = 'EDIT'
		End If
		
		ls_Text = This.GetItemString(row, "consent_order_comments")
		
		li_RC = f_edit_notes(ls_access, ls_Text)
		
		If (li_RC = 1) Then This.SetItem(row, "consent_order_comments", ls_Text)	
		
	Case 'b_project_types'
		li_locked = this.GetItemNumber(row, 'locked_flag')
		
		OpenWithParm(w_project_types, li_locked)
		
		
End Choose

end event

type tab_2 from u_tab_app_info within u_tabpg_application
integer x = 5
integer y = 932
integer width = 2894
integer height = 1460
integer taborder = 11
boolean bringtotop = true
end type

event pfc_postupdate;call super::pfc_postupdate;string ls_message, ls_project, ls_status, ls_gigp, ls_user
long ll_row
n_cst_notification_service ln_notify

If ib_notifystatuschange Then
	ib_notifystatuschange = False
	
	ll_row = dw_1.GetRow()
	ls_gigp = String(dw_1.GetItemNumber(ll_row, 'gigp_id'))
	ls_project = dw_1.GetItemString(ll_row, 'project_no')
	ls_status = dw_1.GetItemString(ll_row, 'project_status_cd')
	
	ls_status = dw_1.describe("evaluate('lookupdisplay(project_status_cd)'," + String(ll_row) + ")")
	
	ls_user = gnv_app.of_getuserid()
	
	ls_message = 'GIGP Project #' + ls_gigp + ' / SRF Project Number ' + ls_project + ':  Project Status changed to ' + ls_status + ' by ' + ls_user
	
	ln_notify.of_sendemailnotification( 'GIGPStatusChange', 'GIGP Project Status Change', ls_message)
	
End If

Return ancestorreturnvalue
end event

type cbx_required_only from checkbox within u_tabpg_application
integer x = 357
integer y = 804
integer width = 421
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Req~'d for G.A."
end type

type dw_cfa from u_dw within u_tabpg_application
boolean visible = false
integer x = 187
integer y = 1132
integer width = 2674
integer height = 1652
integer taborder = 11
boolean bringtotop = true
boolean titlebar = true
string title = "Consolidated Funding Application Raw Data"
string dataobject = "d_cfa_rawdata"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean hscrollbar = true
boolean resizable = true
string icon = "Asterisk!"
end type

event constructor;call super::constructor;this.SetTransObject(SQLCA)
end event

event buttonclicked;call super::buttonclicked;string ls_text
str_notes lstr_notes

Choose Case dwo.name
	Case 'b_question'
		ls_text = this.GetItemString(row, 'question')
		If IsNull(ls_text) Then ls_text = ''
		lstr_notes.str_text = ls_text
		lstr_notes.str_action = "READ"
		OpenWithParm(w_edit_notes, lstr_notes)
		
	Case 'b_answer'
		ls_text = this.GetItemString(row, 'answer')
		If IsNull(ls_text) Then ls_text = ''
		lstr_notes.str_text = ls_text
		lstr_notes.str_action = "READ"
		OpenWithParm(w_edit_notes, lstr_notes)
		
	Case 'b_print'
		this.Event pfc_print()
		
End Choose

end event

