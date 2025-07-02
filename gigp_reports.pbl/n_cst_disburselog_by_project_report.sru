forward
global type n_cst_disburselog_by_project_report from n_cst_report
end type
end forward

global type n_cst_disburselog_by_project_report from n_cst_report
string dataobject = "d_disburselog_by_project_rpt"
end type
global n_cst_disburselog_by_project_report n_cst_disburselog_by_project_report

forward prototypes
public subroutine of_post_retrieve_report ()
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_post_retrieve_report ();
String		ls_value
Long		ll_gigpID

If (This.RowCount() < 1) Then Return

ll_gigpID = This.GetItemNumber(1, "gigp_id")		

ls_value =  ""
ls_value = f_get_applicant_name(ll_gigpID)
This.SetItem(1, 'cc_appname', ls_value)	
end subroutine

public subroutine of_retrieve_report ();
Long 		ll_count, ll_gigpID
String		ls_parm

//*************************************************************
// Get Report Parm - Selected GIGP project:
//*************************************************************

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
	Return
End If
	
ls_parm = ids_parms.GetItemString(1, "prm_value")	

ll_gigpID = Integer(ls_parm)

This.Retrieve(ll_gigpID)




end subroutine

public subroutine of_open_parm_window ();
OpenWithParm(w_project_select, "SINGLE")
end subroutine

on n_cst_disburselog_by_project_report.create
call super::create
end on

on n_cst_disburselog_by_project_report.destroy
call super::destroy
end on

