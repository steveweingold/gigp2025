forward
global type n_cst_project_buildfilter from n_cst_report
end type
end forward

global type n_cst_project_buildfilter from n_cst_report
end type
global n_cst_project_buildfilter n_cst_project_buildfilter

type variables

String is_filterString
end variables

forward prototypes
public subroutine of_post_retrieve_report ()
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
public subroutine of_build_filter (string as_col, string as_value, string as_datatype, string as_operator)
public function string of_return_filter ()
end prototypes

public subroutine of_post_retrieve_report ();


end subroutine

public subroutine of_retrieve_report ();Long 				ll_count
String				ls_fundingrec, ls_srf_program, ls_recommendations[],  ls_status, ls_roundNo, ls_program, ls_locked
n_cst_string		lu_string
Integer			li_index, li_UBound

ll_count = ids_parms.RowCount()

//If (ll_count <> 5) Then	
//	MessageBox("ERROR!", "Error processing Filter parms - See I.T.!")
//	Return
//End If

//*************************************************************
// Process Filter Parms:
//*************************************************************

ls_srf_program = ids_parms.GetItemString(1, "prm_value")		

If (ls_srf_program <> "ALL") Then
	of_build_filter("srf_program", ls_srf_program, "String", "=")	
End If	

ls_fundingrec = ids_parms.GetItemString(2, "prm_value")		

If (ls_fundingrec<> "ALL") Then
		
	lu_string.of_parsetoarray(ls_fundingrec, ",", ls_recommendations)
	ls_fundingrec = ""
	
	li_UBound = UpperBound(ls_recommendations)
	
	If (li_UBound = 1) Then
		ls_fundingrec =  ("'" + ls_recommendations[1] + "'")
	Else
	
		For li_index = 1 to li_UBound
				
				If (Len(Trim(ls_fundingrec)) < 1) Then
					ls_fundingrec =  ("'" + ls_recommendations[li_index] + "'")				
				Else
					ls_fundingrec +=  (",'" + ls_recommendations[li_index] + "'")				
				End If	
		Next 
	
	End If
	
	ls_fundingrec = ("(" + ls_fundingrec + ")")
	of_build_filter("funding_recommendation", ls_fundingrec, "StringArray", "in")	
End If	

ls_status = ids_parms.GetItemString(3, "prm_value")

If (ls_status <> "ALL") Then
	of_build_filter("app_status", ls_status, "String", "=")	
End If	

ls_roundNo = ids_parms.GetItemString(4, "prm_value")

If (ls_roundNo <> "ALL") Then
	of_build_filter("round_no", ls_roundNo, "Integer", "in")	
End If	


ls_program = ids_parms.GetItemString(5, "prm_value")

If ls_program <> 'ALL' Then
	of_build_filter("program", ls_program, 'String', '=')
End If

//Project Status
ls_status = ids_parms.GetItemString(6, "prm_value")

If ls_status <> 'ALL' Then
	of_build_filter("project_status_cd", "'" + ls_status + "'", "string", "=")
End If

//Locked flag
ls_locked = ids_parms.GetItemString(7, "prm_value")

If ls_locked > '' then
	of_build_filter("locked_flag", ls_locked, "integer", "=")
End If

//MessageBox("Filter", is_filterString)
end subroutine

public subroutine of_open_parm_window ();
OpenWithParm(w_funding_recommend_parms, 'MULTI')
end subroutine

public subroutine of_build_filter (string as_col, string as_value, string as_datatype, string as_operator);
String ls_filter

ls_filter = (as_col + " " + as_operator + " ") 

If as_operator = 'in' Then
	ls_filter += ' (' + this.of_getmultiplerounds(as_value) + ')'
Else
	If (as_datatype = "String") Then
		ls_filter += ("'" + as_value + "'")
	Else
		ls_filter += (" " + as_value)
	End If
End If


If (Len(Trim(is_filterString)) > 0) Then
	is_filterString += (" and " + ls_filter)	
Else
	is_filterString = ls_filter	
End If



end subroutine

public function string of_return_filter ();
Return is_filterString
end function

on n_cst_project_buildfilter.create
call super::create
end on

on n_cst_project_buildfilter.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

