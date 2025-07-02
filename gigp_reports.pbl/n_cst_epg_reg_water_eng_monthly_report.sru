forward
global type n_cst_epg_reg_water_eng_monthly_report from n_cst_report
end type
end forward

global type n_cst_epg_reg_water_eng_monthly_report from n_cst_report
string dataobject = "d_design_review_rpt"
end type
global n_cst_epg_reg_water_eng_monthly_report n_cst_epg_reg_water_eng_monthly_report

type variables

end variables

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();long ll_gigp
string ls_type, ls_program

select gigp_id, contact_type
into :ll_gigp, :ls_type
from gigp_contact_links
where contact_type = 'EFCLEADREV'
group by gigp_id, contact_type
having count(*) > 1;

If ll_gigp > 0 Then
	MessageBox('Retrieve', 'GIGP ' + String(ll_gigp) + ' has more than one Lead Reviewer assigned. Please fix and re-run.')
	Return
End If

ls_program = ids_parms.GetItemString(1, "prm_value")		

this.Retrieve(ls_program)

end subroutine

public subroutine of_open_parm_window ();Open(w_program_parm)

end subroutine

on n_cst_epg_reg_water_eng_monthly_report.create
call super::create
end on

on n_cst_epg_reg_water_eng_monthly_report.destroy
call super::destroy
end on

