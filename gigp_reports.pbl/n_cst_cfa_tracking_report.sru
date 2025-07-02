forward
global type n_cst_cfa_tracking_report from n_cst_report
end type
end forward

global type n_cst_cfa_tracking_report from n_cst_report
string dataobject = "d_cfa_tracking_rpt"
end type
global n_cst_cfa_tracking_report n_cst_cfa_tracking_report

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
end prototypes

public subroutine of_retrieve_report ();long ll_ub, ll_index, ll_count, ll_gigpid, ll_cfa, ll_row, ll_length, ll_place
Integer li_roundNo, li_program_id[]
integer li_id_count, li_id_index
Integer li_index
String ls_date, ls_roundlist,  ls_program_id, ls_id[], ls_empty[]
//String ls_dateCols[] = {'Award_Letter_Sent_17','Contract_sent_to_recipient_21', 'Commencement_Date_29', 'Anticipated_Completion_Date_32','contract_executed_22','grant_closed_25'}
String ls_oft_col[] = {"CFA_System_Application_Number","CFA_System_Program_Id","Agency_Name","Applicant_Name_47","Project_Name_48","Press_Ready_Description_2","CFA_Award_Amount_3","Contract_Award_Amount_55","Street_Address_4","City_5","County_6","Zip_7","Senate_District_8","Assembly_District_9","Latitude_49","Longtitude_50","Total_Project_Cost_12","Federal_Sources_13","State_Sources_14","Local_Sources_15","Private_Sources_16","Award_Letter_Sent_17","OSC_Procurement_Sent_18","OSC_Procurement_Approved_19","Board_Approval_20","Contract_sent_to_recipient_21","Contract_Executed_22","Percent_Project_Completed_52","Attachment_A_Approval_23","OSC_Contract_Approval_24","Grant_Closed_25","Grant_Status_27","Grant_Money_dispersed_to_Date_28","Commencement_Date_29","Project_Status_30","Project_Status_Comment_31","Anticipated_Completion_Date_32","Event_Date_33","Event_Notes_34","MWBE_Goals_Established_35","Construction_Contracts:_(M)_MWBE_Utilization_to_date_($)_36","Construction_Contracts:_(M)_MWBE_Utilization_goal_($)_37","Construction_Contracts:_(W)_MWBE_Utilization_to_date_($)_38","Construction_Contracts:_(W)_MWBE_Utilization_goal_($)_39","Professional_Services_Contracts_Goal_($)_40","Job_Existing_42","Jobs_Retained_43","Environmental_Impact_46","Jobs_Projected_51","Jobs_Created_44","Job Commitment Achieved","Regions"}
String ls_sybase_col[] = {"CFA_System_Application_Number","CFA_System_Program_Id","Agency_Name","Applicant_Name_47","Project_Name_48","Press_Ready_Description_2","CFA_Award_Amount_3","Contract_Award_Amount_55","Street_Address_4","City_5","County_6","Zip_7","Senate_District_8","Assembly_District_9","Latitude_49","Longtitude_50","Total_Project_Cost_12","Federal_Sources_13","State_Sources_14","Local_Sources_15","Private_Sources_16","Award_Letter_Sent_17","OSC_Procurement_Sent_18","OSC_Procurement_Approved_19","Board_Approval_20","Contract_sent_to_recipient_21","Contract_Executed_22","Percent_Project_Completed_52","Attachment_A_Approval_23","OSC_Contract_Approval_24","Grant_Closed_25","Grant_Status_27","Grant_Money_dispersed_28","Commencement_Date_29","Project_Status_30","Project_Status_Comment_31","Anticipated_Completion_Date_32","Event_Date_33","Event_Notes_34","MWBE_Goals_Established_35","Contracts_M_to_date_36","Contracts_M_goal_37","Contracts_W_to_date_38","Contracts_W_goal_39","Professional_Services_40","Job_Existing_42","Jobs_Retained_43","Environmental_Impact_46","Jobs_Projected_51","Jobs_Created_44","Job_Commitment_Achieved","Regions"}
String ls_senate, ls_assembly, ls_roundParm, ls_value, ls_round
n_cst_string ln_string

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
	Return
End If

//*************************************************************
// Round No:
//*************************************************************
ls_roundParm = ids_parms.GetItemString(1, "prm_value")

//If (ls_roundNo = "ALL") Then
//	MessageBox("Round", "Please select one round for this Extract.")
//	Return
//Else
//	li_roundNo = Integer(ls_roundNo)
//End If	

//Build the Integer Array
ll_length = Len(ls_roundParm) 

If ll_length < 3 Then	//3 would be minimum places for 1 round with separator on either side
	MessageBox("Round", 'Invalid Round selected.')
	Return
End If

li_index = 0
ls_value = ''
ls_round = ''
ls_roundlist = ''

//Create the round number array
For ll_place = 2 to ll_length
	ls_value = Mid(ls_roundParm, ll_place, 1)
	
	If IsNumber(ls_value) Then
		ls_round += ls_value
	Else
		If ls_round > '' Then
			li_roundNo = Integer(ls_round)
			
			select ref_value
			into :ls_program_id
			from gigp_reference
			where category = 'CFAProgramId'
			and ref_code = :ls_round;
			
			//Get CFA Program IDs (multiple possible per round)
			ln_string.of_parsetoarray(ls_program_id, ',', ls_id)
			
			li_id_count = UpperBound(ls_id)
			
			If li_id_count > 0 Then
				For li_id_index = 1 to li_id_count
					li_index ++
					li_program_id[li_index] = Integer(ls_id[li_id_index])
					
				Next
				
			End If
			
			ls_roundlist += ls_round + ', '
			ls_round = ''
			ls_id = ls_empty
			
		End If
		
	End If
	
Next

ls_roundlist = Left(ls_roundlist, Len(ls_roundlist) - 2)	//remove trailing comma and space

//Retrieve
ll_count = This.Retrieve(li_program_id, ls_roundlist)

////Loop through and re-format the date values to new CFA pattern (yyyy-mm-dd) - Convert Style "111" returns yyyy/mm/dd	***REVERSED BY CFA TEAM
//If ll_count > 0 Then
//	ll_ub = UpperBound(ls_dateCols)
//	
//	For ll_row = 1 to ll_count
//		
//		For ll_index = 1 to ll_ub
//			ls_date = Trim(this.GetItemString(ll_row, ls_dateCols[ll_index]))
//			If ls_date > '' Then
//				If need to do this again, consider using n_cst_string globalreplace()
//				ls_date = Replace (ls_date, 5, 1, '-')
//				ls_date = Replace (ls_date, 8, 1, '-')
//				this.SetItem(ll_row, ls_dateCols[ll_index], ls_date)
//			End If
//		Next
//		
//	Next
//
//End If

//Add the header record 
If ll_count > 0 Then
	this.InsertRow(1)
	
	ll_ub = UpperBound(ls_oft_col)
	
	For ll_index = 1 to ll_ub
		this.SetItem(1, ls_sybase_col[ll_index], ls_oft_col[ll_index])
	Next
	
	
End If

end subroutine

public subroutine of_open_parm_window ();Open(w_roundno_multi_parm)
end subroutine

on n_cst_cfa_tracking_report.create
call super::create
end on

on n_cst_cfa_tracking_report.destroy
call super::destroy
end on

