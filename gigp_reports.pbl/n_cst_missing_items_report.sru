forward
global type n_cst_missing_items_report from n_cst_report
end type
end forward

global type n_cst_missing_items_report from n_cst_report
string dataobject = "d_missing_items_rpt"
end type
global n_cst_missing_items_report n_cst_missing_items_report

type variables
Integer ii_gigpID
string is_proj, is_app
end variables

forward prototypes
public subroutine of_retrieve_report ()
public subroutine of_open_parm_window ()
public subroutine of_post_retrieve_report ()
public function integer of_insert_item (string as_item_type, string as_item)
end prototypes

public subroutine of_retrieve_report ();Long 		ll_count
String		ls_parm

//*************************************************************
// Get Report Parm - Selected GIGP project:
//*************************************************************

ll_count = ids_parms.RowCount()

If (ll_count <> 1) Then	
	MessageBox("ERROR!", "Error processing report parms - See I.T.!")
	Return
End If
	
ls_parm = ids_parms.GetItemString(1, "prm_value")	

ii_gigpID = Integer(ls_parm)

This.Retrieve(ii_gigpID)

If this.RowCount() > 0 Then
	is_proj = this.GetItemString(1, 'project_name') 
	is_app = this.GetItemString(1, 'applicant_name')
End If
end subroutine

public subroutine of_open_parm_window ();OpenWithParm(w_project_select, "SINGLE")
end subroutine

public subroutine of_post_retrieve_report ();long ll_count, ll_row
string ls_parm, ls_value, ls_desc
datetime ldt_value
Boolean	lb_bondres_skip = False
n_ds lds_data


/***************************************************************************
Need to update from Application Detail Tab logic... (if going to use)
****************************************************************************/



//Create Datastore
If NOT IsValid(lds_data) Then
	lds_data = CREATE n_ds
End If


////Get missing Contract Dates ?????????????????????????????????????????????
//lds_data.DataObject = 'd_proj_project_efc_agreement_dates'
//lds_data.SetTransObject(SQLCA)
//ll_count = lds_data.Retrieve(ii_gigpID)
//
//If ll_count > 0 Then
//	For ll_row = 1 to ll_count
//		If lds_data.GetItemNumber(ll_row, 'system_only') = 0 Then
//			ldt_value = lds_data.GetItemDateTime(ll_row, 'keydate_value')
//				
//			If IsNull(ldt_value) Then
//				//Insert row w/ ref_description
//				this.of_insert_item('item',lds_data.GetItemString(ll_row, 'ref_value'))
//				
//			End If
//			
//		End If
//	Next
//End If


//Get missing SEQR Dates
this.of_insert_item('heading', 'New York State Environmental Quality Review (SEQR) & State Historic Preservation Office (SHPO):')

lds_data.DataObject = 'd_proj_project_seqrinsur_dates'
lds_data.SetTransObject(SQLCA)
ll_count = lds_data.Retrieve(ii_gigpID)

If ll_count > 0 Then
	For ll_row = 1 to ll_count
		If lds_data.GetItemNumber(ll_row, 'system_only') = 0 Then
		
			ls_value = lds_data.GetItemString(ll_row, 'keydate_ind')
			
			If IsNull(ls_value) or ls_value = '' or ls_value = 'CORRECTION' Then
				//Insert row w/ ref_description
				this.of_insert_item('item', lds_data.GetItemString(ll_row, 'ref_value'))
				
			End If
		End If
	Next
End If


//Get missing Readiness Dates
this.of_insert_item('heading', 'Project Readiness and Engineering:')

//Get missing Application data (if all approved budget amounts are 0)
SELECT	count(*)
INTO		:ll_count			
FROM 	gigp_amounts GA,   
         		gigp_reference GR  
WHERE	GA.ref_code = GR.ref_code
AND		GR.category = 'budgetAmount'
AND 		GA.gigp_id = :ii_gigpID
AND		GA.approved_amt > 0;

If ll_count <= 0 Then
	//Insert row
	this.of_insert_item('item', 'Detailed Budget')
	
End If	

lds_data.DataObject = 'd_proj_project_readiness_dates'
lds_data.SetTransObject(SQLCA)
ll_count = lds_data.Retrieve(ii_gigpID)

If ll_count > 0 Then
	For ll_row = 1 to ll_count
		If lds_data.GetItemNumber(ll_row, 'system_only') = 0 Then
			
			ls_desc = lds_data.GetItemString(ll_row, 'ref_value')
			
			If ls_desc = 'Copies of Permits:' Then
				ls_value = lds_data.GetItemString(ll_row, 'keydate_ind')
				
				If ls_value = '0' Then
					//Insert row w/ ref_description
					this.of_insert_item('item', lds_data.GetItemString(ll_row, 'ref_value'))
					
				End If
				
			Else
				ldt_value = lds_data.GetItemDateTime(ll_row, 'keydate_value')
				
				If IsNull(ldt_value) Then
					//Insert row w/ ref_description
					this.of_insert_item('item', lds_data.GetItemString(ll_row, 'ref_value'))
					
				End If
			End If
		End If
	Next
End If


//Get missing Legal Dates
this.of_insert_item('heading', 'Legal:')

lds_data.DataObject = 'd_proj_project_legal_dates'
lds_data.SetTransObject(SQLCA)
ll_count = lds_data.Retrieve(ii_gigpID)

If ll_count > 0 Then
	For ll_row = 1 to ll_count
		If lds_data.GetItemNumber(ll_row, 'system_only') = 0 Then
			
			ls_desc = lds_data.GetItemString(ll_row, 'ref_value')
			
			If ls_desc = 'Third Party Funding Docs Complete:' Then
				ls_value = lds_data.GetItemString(ll_row, 'keydate_choice')
				
				If ls_value = 'N' Then
					//Insert row w/ ref_description
					this.of_insert_item('item', lds_data.GetItemString(ll_row, 'ref_value'))
					
				End If
				
			Else
				ls_value = lds_data.GetItemString(ll_row, 'keydate_ind')
				
				//If Bond Resolution = N/A then no
				If ls_desc = 'Bond Resolution' and ls_value = 'NA' Then
					lb_bondres_skip = True
				End If
				
				If IsNull(ls_value) or ls_value = '' Then
					
					If (ls_desc = 'Estoppel Notice' or ls_desc = 'Permissive Referendum Notice') and lb_bondres_skip Then
						CONTINUE
					End If
						
					//Insert row w/ ref_description
					this.of_insert_item('item', lds_data.GetItemString(ll_row, 'ref_value'))

				End If
			End If
		End If
	Next
End If

//Insert MWBE standard items  
this.of_insert_item('heading', 'Minority and Women Business Enterprise – Equal Employment Opportunity (MWBE-EEO):')

lds_data.DataObject = 'd_mwbe_missing_items'
lds_data.SetTransObject(SQLCA)
ll_count = lds_data.Retrieve()

If ll_count > 0 Then
	For ll_row = 1 to ll_count
		ls_value = lds_data.GetItemString(ll_row, 'description')
		
		this.of_insert_item('item', ls_value)
		
	Next
End If


If IsValid(lds_data) Then DESTROY lds_data
end subroutine

public function integer of_insert_item (string as_item_type, string as_item);long ll_row

If this.RowCount() = 1 and this.GetItemString(1, 'missing_item') = '' and this.GetItemString(1, 'heading') = '' Then
	ll_row = 1
Else
	ll_row = this.InsertRow(0)
End If

If as_item_type = 'item' Then
	If Right(as_item, 1) = ':' Then
		as_item = Left(as_item, Len(as_item) - 1)
	End If
End If

If ll_row > 0 Then
	this.SetItem(ll_row, 'gigp_id', ii_gigpId)
	this.SetItem(ll_row, 'project_name', is_proj)
	this.SetItem(ll_row, 'applicant_name', is_app)
	
	If as_item_type = 'heading' Then
		this.SetItem(ll_row, 'heading', as_item)
		
	Else
		this.SetItem(ll_row, 'missing_item', as_item)
		
	End If
	
End If

Return ll_row
end function

on n_cst_missing_items_report.create
call super::create
end on

on n_cst_missing_items_report.destroy
call super::destroy
end on

