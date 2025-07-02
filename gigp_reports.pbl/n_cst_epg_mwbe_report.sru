forward
global type n_cst_epg_mwbe_report from n_cst_report
end type
end forward

global type n_cst_epg_mwbe_report from n_cst_report
string dataobject = "d_adhoc_rpt"
end type
global n_cst_epg_mwbe_report n_cst_epg_mwbe_report

type variables
datetime idt_begin, idt_end

end variables

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();Long 				ll_count, ll_rowCount, ll_RC, ll_length, ll_place
String				ls_program, ls_roundNo, ls_parm, ls_roundParm, ls_value, ls_round, ls_roundlist
Integer			li_program, li_roundNo, li_index, li_roundFlag, li_round[]
str_date_parm lstr_date_parm


//*************************************************************
// Get Round Numbers:
//*************************************************************
ls_roundNo = ids_parms.GetItemString(4, "prm_value")
this.of_getmultiplerounds(ls_roundNo)

//Program
ls_program = ids_parms.GetItemString(5, "prm_value")


//***************************
// Get Date Range:
//***************************
ids_parms.Reset()

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

//Retrieve
ll_rowCount =This.Retrieve(idt_begin, idt_end, ii_round, is_roundlist, ls_program)

end subroutine

public subroutine of_open_parm_window ();OpenWithParm(w_funding_recommend_parms, 'MULTI')
end subroutine

on n_cst_epg_mwbe_report.create
call super::create
end on

on n_cst_epg_mwbe_report.destroy
call super::destroy
end on

