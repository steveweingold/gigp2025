forward
global type n_cst_disbursement_received_status_report from n_cst_report
end type
end forward

global type n_cst_disbursement_received_status_report from n_cst_report
string dataobject = "d_disbursement_received_status_rpt"
end type
global n_cst_disbursement_received_status_report n_cst_disbursement_received_status_report

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

String ls_projNo, ls_formattedNo, ls_value

Decimal ld_Amt

ll_rowCnt = This.RowCount()

If (ll_rowCnt < 1) Then Return

FOR ll_row = 1 TO ll_rowCnt
			
	ll_gigpID = This.GetItemNumber(ll_row, "gigp_id")			
			
	//*************************************************************
	// Applicant Name:
	//*************************************************************
	
	ls_value = f_get_applicant_name(ll_gigpID)
	This.SetItem(ll_row, 'cc_appname', ls_value)	
	
	//*************************************************************
	// EFC Reviewer Assigned:
	//*************************************************************
	
	ls_value = ""	
	
	SELECT	C.full_name         			
	INTO		:ls_value
    	FROM		gigp_contact_links CL,   
        		 	gigp_contacts  C
   	WHERE 	CL.contact_id = C.contact_id
	AND		CL.contact_type = 'EFCDISBREV'
	AND  		CL.gigp_id = :ll_gigpID;
	
	This.setItem(ll_row, 'cc_reviewer', ls_value)	
	
	//*************************************************************
	// Funds Requested:
	//*************************************************************
	
	ld_Amt = f_get_project_amount(ll_gigpID, "FR")
	If IsNull(ld_Amt) Then ld_Amt = 0	
	This.SetItem(ll_row, "cc_requestedAmt",ld_Amt)
	
	//*************************************************************
	// Amount Awarded:
	//*************************************************************
	
	ld_Amt = f_get_project_amount(ll_gigpID, "RECFR")	
	If IsNull(ld_Amt) Then ld_Amt = 0	
	This.SetItem(ll_row, "cc_awardAmt",ld_Amt)	
	
	ls_value = ""
	
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

Open(w_roundno_parm)

istr_parm = Message.PowerObjectParm
	
iblb_data = istr_parm.str_parm
	
ll_RC = ids_parms.SetFullState(iblb_data)

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then		
	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
	Return
	
Else
	is_roundNo = ids_parms.GetItemString(1, "prm_value")

	If (is_roundNo = "ALL") Then
		ii_roundNo = 0
		ii_roundFlag = 1
	Else
		ii_roundNo = Integer(is_roundNo)
		ii_roundFlag = 0
	End If
	
End If

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

This.Retrieve(is_program, ii_program, ii_roundNo, ii_roundFlag, idt_begin, idt_end)

end subroutine

public subroutine of_open_parm_window ();
Open(w_srfprogram_parms)
end subroutine

on n_cst_disbursement_received_status_report.create
call super::create
end on

on n_cst_disbursement_received_status_report.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

