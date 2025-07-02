forward
global type w_eng_hold_conditions from w_gigp_response
end type
type dw_conditions from u_dw_enhanced within w_eng_hold_conditions
end type
type cb_insert from commandbutton within w_eng_hold_conditions
end type
end forward

global type w_eng_hold_conditions from w_gigp_response
integer x = 214
integer y = 221
integer width = 4649
integer height = 1644
string title = "Construction Hold Conditions for: "
dw_conditions dw_conditions
cb_insert cb_insert
end type
global w_eng_hold_conditions w_eng_hold_conditions

type variables
long il_professContractId
end variables

forward prototypes
public function boolean of_disbursements_exist ()
end prototypes

public function boolean of_disbursements_exist ();long ll_count

select count(*)
into :ll_count
from gigp_disbursement_amount da
where da.professional_contract_id = :il_professContractId;

If ll_count > 0 Then
	Return True
Else
	Return False
End If
end function

on w_eng_hold_conditions.create
int iCurrent
call super::create
this.dw_conditions=create dw_conditions
this.cb_insert=create cb_insert
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_conditions
this.Control[iCurrent+2]=this.cb_insert
end on

on w_eng_hold_conditions.destroy
call super::destroy
destroy(this.dw_conditions)
destroy(this.cb_insert)
end on

event open;call super::open;string ls_type, ls_org
decimal ld_amt
long ll_id

//Get the passed professiona contract it
il_professcontractid = Message.DoubleParm

//Customize the window title
SELECT Distinct 	K.contract_type,   
       					K.profess_contract_id,   
						Sum(K.eligible_amt),
       					C.organization
INTO	 				:ls_type, :ll_id, :ld_amt, :ls_org
FROM					gigp_contacts C,
			        		gigp_professional_contracts K
WHERE 				C.contact_id = K.contact_id
and					K.profess_contract_id = :il_professcontractid
GROUP BY  			K.contract_type,
						K.profess_contract_id,
						C.organization;

this.Title += Upper(ls_type) + " - " +  ls_org + ",  " + String( ld_amt , '$#,##0.00;($#,##0.00)')


//Call the retrieve
dw_conditions.Event pfc_retrieve()
end event

event pfc_preopen;call super::pfc_preopen;//Set Security
is_accessGroups = {"TAS-Global", "professContract"}
end event

event ue_process;call super::ue_process;this.Event pfc_save()
end event

event closequery;//override - just going to save on [Ok]
end event

type cb_cancel from w_gigp_response`cb_cancel within w_eng_hold_conditions
integer x = 4224
integer y = 1424
end type

type cb_ok from w_gigp_response`cb_ok within w_eng_hold_conditions
integer x = 3826
integer y = 1424
end type

type dw_conditions from u_dw_enhanced within w_eng_hold_conditions
event ue_insert_hold_conditions ( )
integer x = 32
integer y = 24
integer width = 4571
integer height = 1340
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_eng_hold_conditions"
boolean border = false
borderstyle borderstyle = stylebox!
end type

event ue_insert_hold_conditions();string ls_user

If il_professContractId > 0 Then
	
	If of_disbursements_exist() Then
		MessageBox('Insert', 'New construction hold conditions cannot be applied because disbursement amounts exist for this contract.', StopSign!)
		Return
	End If
				
	ls_user = gnv_app.of_getuserid()
	
	//Insert engineering hold criteria
	insert into gigp_contract_eng_hold (profess_contract_id, eng_hold_type, placed_dt, released_dt, comments, last_updated_dt, last_updated_by)
	select :il_professContractId, ref_code, getdate(), null, null, getdate(), :ls_user
	from gigp_reference
	where category = 'EngineeringHoldType'
	and ref_code not in (select eng_hold_type from gigp_contract_eng_hold where profess_contract_id = :il_professcontractid);
	
	this.Event pfc_retrieve()
	this.Sort()
	
End If

end event

event pfc_retrieve;call super::pfc_retrieve;this.SetTransObject(SQLCA)

Return this.Retrieve(il_professcontractid)
end event

event buttonclicked;call super::buttonclicked;datetime ldt_date
integer li_rc
string ls_Text, ls_access, ls_condition

Choose Case dwo.name
	Case 'b_release'
		this.ScrollToRow(row)
		
		If IsNull(this.GetItemDateTime(row, 'released_dt')) Then
			ldt_date = DateTime(Today(), Now())
		Else
			If of_disbursements_exist() Then
				MessageBox('Clear', 'You cannot clear this release of this condition because disbursement amounts exist for this contract.', StopSign!)
				Return
			End If
			
			SetNull(ldt_date)
			
		End If
		
		this.SetItem(row, 'released_dt', ldt_date)
		this.SetColumn('comments')
			
		
	Case 'b_edit'
		ls_access = "READ"
		
		this.AcceptText()	
		
		ls_Text     = This.GetItemString(row, "comments")
				
		If (ib_editAccess = True) Then ls_access = "EDIT"	
		
		li_RC = f_edit_notes(ls_access, ls_Text)
		
		If (li_RC = 1) Then This.SetItem(row, "comments", ls_Text)
		
	Case 'b_remove'
		ls_condition = this.GetItemString(row, 'cf_condition')
		If MessageBox('Remove', 'Are you sure you want to remove ' + ls_condition + ' hold condition from the Contract?', Question!, YesNo!, 2) = 1 Then
			this.DeleteRow(row)
		End If
		
End Choose

end event

event rbuttondown;//Override
end event

event rbuttonup;//Override
end event

event pfc_updateprep;call super::pfc_updateprep;Long 				ll_row
DateTime		ldt_last
String 			ls_user

ls_user 	= 	gnv_app.of_getuserid()
ldt_last 	=   f_getdbdatetime()

//*******************************************************
// Loop thru modified rows and set update date and user:
//*******************************************************
ll_row	= this.GetNextModified(0, Primary!)

DO WHILE ll_row > 0
	this.SetItem(ll_row, "last_updated_dt",  ldt_last)	
	this.SetItem(ll_row, "last_updated_by", ls_user) 	
	
	ll_row = this.GetNextModified(ll_row, Primary!)

LOOP
Return AncestorReturnValue

end event

type cb_insert from commandbutton within w_eng_hold_conditions
integer x = 64
integer y = 1424
integer width = 645
integer height = 100
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Insert missing conditions"
end type

event clicked;dw_conditions.Event ue_insert_hold_conditions()
end event

