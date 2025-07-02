forward
global type n_cst_epg_eng_rpt_approval_report from n_cst_report
end type
end forward

global type n_cst_epg_eng_rpt_approval_report from n_cst_report
string dataobject = "d_epg_eng_rpt_approval_rpt"
end type
global n_cst_epg_eng_rpt_approval_report n_cst_epg_eng_rpt_approval_report

type variables

DateTime idt_begin, idt_end
end variables

forward prototypes
public subroutine of_retrieve_report ()
end prototypes

public subroutine of_retrieve_report ();Long 				ll_count, ll_rowCount, ll_RC
String				ls_fundingrec, ls_program, ls_recommendations[],  ls_status, ls_roundNo, ls_parm
Integer			li_fundingrec, li_program,  li_status
n_cst_string		lu_string
str_date_parm lstr_date_parm


idt_begin = f_getdbdatetime()
idt_end = f_getdbdatetime()

//***************************
// Get Date Range:
//***************************
	
SetNull(ls_parm)	

lstr_date_parm.str_dateLabel1 = "Approval Date >="
lstr_date_parm.str_dateLabel2 = "Approval Date <="
lstr_date_parm.str_dateValue1 = idt_begin
lstr_date_parm.str_dateValue2 = idt_end

OpenWithParm(w_date_parm, lstr_date_parm)

istr_parm = Message.PowerObjectParm
	
iblb_data = istr_parm.str_parm
	
ll_RC = ids_parms.SetFullState(iblb_data)

ll_count = ids_parms.RowCount()

If ll_count >= 2 Then
	ls_parm = ids_parms.GetItemString(1, "prm_value")	
	idt_begin = DateTime(Date(Left(ls_parm,10)))	
	ls_parm = ids_parms.GetItemString(2, "prm_value")		
	idt_end = DateTime(Date(Left(ls_parm,10)))
End If

ll_rowCount = This.Retrieve(idt_begin, idt_end)

end subroutine

on n_cst_epg_eng_rpt_approval_report.create
call super::create
end on

on n_cst_epg_eng_rpt_approval_report.destroy
call super::destroy
end on

event sqlpreview;call super::sqlpreview;
//MessageBox("Test!", sqlsyntax)
end event

