forward
global type n_cst_epg_milestone_report from n_cst_report
end type
end forward

global type n_cst_epg_milestone_report from n_cst_report
string dataobject = "d_epg_milestone_tracking_list"
end type
global n_cst_epg_milestone_report n_cst_epg_milestone_report

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();string ls_roundNo, ls_program


//*************************************************************
// Get Round Numbers:
//*************************************************************
ls_roundNo = ids_parms.GetItemString(4, "prm_value")
this.of_getmultiplerounds(ls_roundNo)

//Program
ls_program = ids_parms.GetItemString(5, "prm_value")

This.Retrieve(ii_round, is_roundlist, ls_program)
end subroutine

public subroutine of_open_parm_window ();//Open(w_roundno_multi_parm)

OpenWithParm(w_funding_recommend_parms, 'MULTI')
end subroutine

on n_cst_epg_milestone_report.create
call super::create
end on

on n_cst_epg_milestone_report.destroy
call super::destroy
end on

