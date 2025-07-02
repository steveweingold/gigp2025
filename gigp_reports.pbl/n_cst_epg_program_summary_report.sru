forward
global type n_cst_epg_program_summary_report from n_cst_report
end type
end forward

global type n_cst_epg_program_summary_report from n_cst_report
string dataobject = "d_design_review_rpt"
end type
global n_cst_epg_program_summary_report n_cst_epg_program_summary_report

type variables
string is_program
end variables

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();
is_program = ids_parms.GetItemString(1, "prm_value")		

this.Retrieve(is_program)

end subroutine

public subroutine of_open_parm_window ();Open(w_program_parm)


end subroutine

on n_cst_epg_program_summary_report.create
call super::create
end on

on n_cst_epg_program_summary_report.destroy
call super::destroy
end on

