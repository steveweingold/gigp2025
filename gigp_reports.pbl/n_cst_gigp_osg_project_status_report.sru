forward
global type n_cst_gigp_osg_project_status_report from n_cst_report
end type
end forward

global type n_cst_gigp_osg_project_status_report from n_cst_report
string dataobject = "d_gigp_osg_project_tracking_rpt"
end type
global n_cst_gigp_osg_project_status_report n_cst_gigp_osg_project_status_report

forward prototypes
public subroutine of_retrieve_report ()
end prototypes

public subroutine of_retrieve_report ();this.Retrieve()
end subroutine

on n_cst_gigp_osg_project_status_report.create
call super::create
end on

on n_cst_gigp_osg_project_status_report.destroy
call super::destroy
end on

