forward
global type n_cst_report from n_ds
end type
end forward

global type n_cst_report from n_ds
event ue_build_report ( )
end type
global n_cst_report n_cst_report

type variables

DataStore 			ids_parms
Blob 					iblb_data
str_report_parm	istr_parm
Boolean 				ib_Cancel, ib_bypassParms
String					is_roundlist
Integer				ii_round[]
end variables

forward prototypes
public subroutine of_create_datastore ()
public subroutine of_destroy_datastore ()
public subroutine of_open_parm_window ()
public subroutine of_retrieve_report ()
public subroutine of_post_retrieve_report ()
public function str_report_parm of_return_report ()
public function integer of_getmultiplerounds ()
public function string of_getmultiplerounds (string as_rounds)
end prototypes

event ue_build_report();
Long ll_RC, ll_count
String ls_ReportName

This.SetTransObject(SQLCA)

If (ib_bypassParms = False) Then

	//*******************************************************
	// Create Report Parms Datastore:
	//*******************************************************
	
	of_create_datastore()
	
	//*******************************************************
	// Open Report Parm Response Window:
	//*******************************************************
	
	of_open_parm_window()
	
	//*******************************************************
	// Get Report Parms & Process Report:
	//*******************************************************
	
	istr_parm = Message.PowerObjectParm
	
	iblb_data = istr_parm.str_parm
	
	ll_RC = ids_parms.SetFullState(iblb_data)
	
	ll_count = ids_parms.RowCount()
	
	If (ll_count < 1) Then Return
	
	ls_ReportName = ids_parms.GetItemString(1, "prm_name")
	
	If (ls_ReportName = "CANCEL") Then ib_Cancel = True
	
	//*******************************************************
	// Retrieve Report:
	//*******************************************************
	
	If (ib_Cancel <> True) Then of_retrieve_report()
	
	//*******************************************************
	// Post Retrieval Processing Coded Here (If Neccessary):
	//*******************************************************

	If (ib_Cancel <> True) Then of_post_retrieve_report()	
	
Else
	
	of_retrieve_report()
	of_post_retrieve_report()
	
End If









end event

public subroutine of_create_datastore ();
ids_parms 				= CREATE Datastore
ids_parms.DataObject = 'd_report_parms'
end subroutine

public subroutine of_destroy_datastore ();
end subroutine

public subroutine of_open_parm_window ();

end subroutine

public subroutine of_retrieve_report ();
end subroutine

public subroutine of_post_retrieve_report ();


end subroutine

public function str_report_parm of_return_report ();
Blob lblb_data
Long ll_RC
str_report_parm lstr_parm

ll_RC = This.GetFullstate(lblb_data)

lstr_parm.str_parm = lblb_data

Return lstr_parm
end function

public function integer of_getmultiplerounds ();long ll_count, ll_length, ll_place
integer li_index
string ls_roundParm, ls_value, ls_round

//*************************************************************
// Get Round Numbers:
//*************************************************************
Open(w_roundno_multi_parm)
istr_parm = Message.PowerObjectParm
iblb_data = istr_parm.str_parm
ids_parms.SetFullState(iblb_data)

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	MessageBox("ERROR!", "Error getting round numbers - See I.T.!")
	Return -1
End If

ls_roundParm = ids_parms.GetItemString(1, "prm_value")

//Build the Integer Array
ll_length = Len(ls_roundParm) 

If ll_length < 3 Then	//3 would be minimum places for 1 round with separator on either side
	MessageBox("Round", 'Invalid Round selected.')
	Return -1
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

Return 1
end function

public function string of_getmultiplerounds (string as_rounds);string ls_round, ls_value
integer li_index
long ll_place, ll_length

//Build the Integer Array
ll_length = Len(as_rounds) 

If pos(as_rounds, '|') <=0 Then
	If IsNumber(as_rounds) Then
		ii_round[1] = Integer(as_rounds)
		is_roundlist = as_rounds
		Return is_roundlist
	Else
		Return as_rounds
	End If
End If

li_index = 0
ls_round = ''
ls_value = ''
is_roundlist = ''

//Create the round number array
For ll_place = 2 to ll_length
	ls_value = Mid(as_rounds, ll_place, 1)
	
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

Return is_roundlist
end function

on n_cst_report.create
call super::create
end on

on n_cst_report.destroy
call super::destroy
end on

event constructor;call super::constructor;
//********************************************************************************************
// Steps to building an Report with retrieval args:
//   (Reports w/ no arguments do not require this nvo)
//********************************************************************************************
// (1) Inherit and build a report parms window from w_ifp_report_parms or 
//     reuse a parm window already created.
// (2) Set the report data object in the properties of this nvo
// (3) Issue the open of the parm window from step 1 in of_open_parm_window()
// (4) Process the report parms from step 3 and retrieve the report in of_retrieve_report()
// (5) Post Report Retrieval Processing coded in of_post_retrieve_report()
// (6) Report Controller to issue of_return_report() to get report
//********************************************************************************************

This.SetTransObject(SQLCA)

//This.Event ue_build_report()
end event

event destructor;call super::destructor;
If IsValid(ids_parms) Then Destroy ids_parms
end event

