forward
global type n_cst_epg_quarterly_report from n_cst_report
end type
end forward

global type n_cst_epg_quarterly_report from n_cst_report
string dataobject = "d_epg_quarterly_summary"
end type
global n_cst_epg_quarterly_report n_cst_epg_quarterly_report

type variables
DateTime idt_begin, idt_end
end variables

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();Long 				ll_count, ll_rowCount, ll_RC
String				ls_program, ls_roundNo, ls_parm
Integer			li_program, li_roundNo, li_roundFlag
str_date_parm lstr_date_parm


ls_program = ids_parms.GetItemString(1, "prm_value")

idt_begin = f_getdbdatetime()
idt_end = f_getdbdatetime()

SetNull(ls_parm)

lstr_date_parm.str_dateLabel1 = "Begin Date >="
lstr_date_parm.str_dateLabel2 =  "End Date <="
lstr_date_parm.str_dateValue1 = idt_begin
lstr_date_parm.str_dateValue2 = idt_end

OpenWithParm(w_date_parm, lstr_date_parm)

istr_parm = Message.PowerObjectParm
	
iblb_data = istr_parm.str_parm
	
ll_RC = ids_parms.SetFullState(iblb_data)

ll_count = ids_parms.RowCount()

If (ll_count <> 2) Then	
	// Nothing	
Else
	ls_parm = ids_parms.GetItemString(1, "prm_value")	
	idt_begin = DateTime(Date(Left(ls_parm,10)))	
	ls_parm = ids_parms.GetItemString(2, "prm_value")		
	idt_end = DateTime(Date(Left(ls_parm,10)))
	
End If

ll_rowCount =This.Retrieve(idt_begin, idt_end, ls_program)
end subroutine

public subroutine of_open_parm_window ();Open(w_program_parm)
end subroutine

on n_cst_epg_quarterly_report.create
call super::create
end on

on n_cst_epg_quarterly_report.destroy
call super::destroy
end on

