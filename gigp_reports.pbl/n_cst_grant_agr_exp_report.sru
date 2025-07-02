forward
global type n_cst_grant_agr_exp_report from n_cst_report
end type
end forward

global type n_cst_grant_agr_exp_report from n_cst_report
end type
global n_cst_grant_agr_exp_report n_cst_grant_agr_exp_report

type variables
boolean ib_gigp
end variables

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();long ll_count
string ls_program

If ib_gigp Then
	this.Retrieve()
Else
	ls_program = ids_parms.GetItemString(1, "prm_value")		
	this.Retrieve(ls_program)
End If

end subroutine

public subroutine of_open_parm_window ();If Pos(this.DataObject, 'gigp') = 0 Then
	ib_gigp = False
	open(w_program_parm)
Else
	ib_gigp = True
End If
end subroutine

on n_cst_grant_agr_exp_report.create
call super::create
end on

on n_cst_grant_agr_exp_report.destroy
call super::destroy
end on

