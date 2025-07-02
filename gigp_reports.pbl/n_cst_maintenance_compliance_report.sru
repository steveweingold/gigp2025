forward
global type n_cst_maintenance_compliance_report from n_cst_report
end type
end forward

global type n_cst_maintenance_compliance_report from n_cst_report
string dataobject = "d_design_review_rpt"
end type
global n_cst_maintenance_compliance_report n_cst_maintenance_compliance_report

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();Long 				ll_count
String				ls_fundingrec, ls_program, ls_recommendations[],  ls_status, ls_roundNo, ls_projstatus
Integer			li_fundingrec, li_program,  li_status, li_roundNo, li_roundFlag
Datetime	ldt_begin, ldt_end
n_cst_string		lu_string

ll_count = ids_parms.RowCount()

//If (ll_count <> 5) Then	
If (ll_count <> 7) Then	
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


//*************************************************************
// Application Status:
//*************************************************************
ls_projstatus = ids_parms.GetItemString(5, "prm_value")


//*************************************************************
// Date Range
//*************************************************************
ldt_begin = DateTime(Date(ids_parms.GetItemString(6, "prm_value")))
ldt_end = DateTime(Date(ids_parms.GetItemString(7, "prm_value")))


This.Retrieve(ls_recommendations, li_fundingrec, ls_program, li_program, ls_status, li_status, ii_round, is_roundlist, ls_projstatus, ldt_begin, ldt_end)

end subroutine

public subroutine of_open_parm_window ();OpenWithParm(w_funding_recommend_parms_proj_stat_date, 'MULTI')
end subroutine

on n_cst_maintenance_compliance_report.create
call super::create
end on

on n_cst_maintenance_compliance_report.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

