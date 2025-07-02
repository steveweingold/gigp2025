forward
global type n_cst_proofof_payment_notreceived_report from n_cst_report
end type
end forward

global type n_cst_proofof_payment_notreceived_report from n_cst_report
string dataobject = "d_proofof_payment_notreceived_rpt"
end type
global n_cst_proofof_payment_notreceived_report n_cst_proofof_payment_notreceived_report

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

String ls_value

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
	// Get EFC Reviewer:
	//*************************************************************
	ls_value = ""
		
	SELECT  C.full_name
	INTO		:ls_value
	FROM 	gigp_contacts C,
				gigp_contact_links CL         
	WHERE 	C.contact_id = CL.contact_id
	AND		CL.contact_type = 'EFCDISBREV'   
     AND       CL.gigp_id = :ll_gigpID;
	
	This.SetItem(ll_row, "cc_reviewer", ls_value)
	
	ls_value = ""
	
NEXT


end subroutine

public subroutine of_retrieve_report ();
This.Retrieve()





end subroutine

public subroutine of_open_parm_window ();

end subroutine

on n_cst_proofof_payment_notreceived_report.create
call super::create
end on

on n_cst_proofof_payment_notreceived_report.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

