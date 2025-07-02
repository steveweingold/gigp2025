forward
global type n_cst_design_calc_summary_report from n_cst_report
end type
end forward

global type n_cst_design_calc_summary_report from n_cst_report
string dataobject = "d_epg_milestone_tracking_list"
end type
global n_cst_design_calc_summary_report n_cst_design_calc_summary_report

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();long ll_ret, ll_count, ll_length, ll_place
integer li_index
string ls_roundParm, ls_value, ls_round


//Get Rounds
ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
	Return
End If

//*************************************************************
// Round No:
//*************************************************************
ls_roundParm = ids_parms.GetItemString(1, "prm_value")

ll_length = Len(ls_roundParm) 

If ll_length < 3 Then	//3 would be minimum places for 1 round with separator on either side
	MessageBox("Round", 'Invalid Round selected.')
	Return
End If

li_index = 0
ls_value = ''
ls_round = ''
is_roundlist = ''

//Create the round number array
For ll_place = 2 to ll_length
	ls_value = Mid(ls_roundParm, ll_place, 1)
	
	If IsNumber(ls_value) Then
		ls_round += ls_value
	Else
		If ls_round > '' Then
			li_index ++
			
			ii_round[li_index] = Integer(ls_round)
			
			is_roundlist += ls_round + ', '
			
			ls_round = ''
			
		End If
		
	End If
	
Next

is_roundlist = Left(is_roundlist, Len(is_roundlist) - 2)	//remove trailing comma and space


ll_ret = This.Retrieve(ii_round, is_roundlist)
end subroutine

public subroutine of_open_parm_window ();Open(w_roundno_multi_parm)
end subroutine

on n_cst_design_calc_summary_report.create
call super::create
end on

on n_cst_design_calc_summary_report.destroy
call super::destroy
end on

