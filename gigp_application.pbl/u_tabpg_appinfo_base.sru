forward
global type u_tabpg_appinfo_base from u_tabpg_dbaccess
end type
end forward

global type u_tabpg_appinfo_base from u_tabpg_dbaccess
event ue_addrow ( long al_row )
end type
global u_tabpg_appinfo_base u_tabpg_appinfo_base

type variables
string is_notif_subj[], is_notif_body[]
long il_row[]
string is_notif_subj_constr, is_notif_body_constr
string is_inspect_coord_subj, is_inspect_coord_body
end variables

forward prototypes
public function integer of_send_notification ()
public function integer of_add_notification (string as_item, string as_user, long al_row, boolean ab_construct)
public function integer of_send_email (string as_subject, string as_sendto, string as_message)
end prototypes

public function integer of_send_notification ();integer li_index, li_count
string ls_null[], ls_switch, ls_analyst, ls_email, ls_sendto
long ll_null[]

//Check switch
select ref_code
into :ls_switch
from gigp_reference
where category = 'GANotif';

If ls_switch <> '1' Then
	Return 1
End If

//Get analyst info

// Original SQL 3-10-23
//select u.user_id, u.email_address
//into :ls_analyst, :ls_email
//from gigp_contacts c, gigp_contact_links cl, tk_usXXXers u
//where c.contact_id = cl.contact_id
//and upper(c.last_name) = upper(u.last_name)
//and cl.contact_type = 'EFCREVASSGN'
//and c.status = 'Active'
//and cl.gigp_id = :gl_gigp_id;

// New SQL - Greg - This will fail if there are ever two staff in GIGP with the same last name.
select	u.UserId,
			u.Email
into	:ls_analyst,
		:ls_email
from	gigp_contacts			c,
		gigp_contact_links	cl,
		EfcUser					u
where c.contact_id			= cl.contact_id and
		cl.contact_type		= 'EFCREVASSGN' and
		c.status					= 'Active' and
		upper(c.last_name)	= upper(u.LastName) and
		cl.gigp_id				= :gl_gigp_id;

//If the user is not the analyst then notify analyst. If no analyst then sent to batchjob_notify to route to both
If IsNull(ls_analyst) or ls_analyst = '' Then
	ls_sendto = '' //will go to batchjob notify
Else
	If ls_analyst <> gnv_app.of_getuserid() Then
		ls_sendto = ls_email
	Else
		Return 1
	End If
End If

li_count = UpperBound(is_notif_subj)

If li_count > 0 Then
	
	For li_index = 1 to li_count
		f_send_email_alert(is_notif_subj[li_index], is_notif_body[li_index], ls_sendto)
	Next
	
	il_row = ll_null
	is_notif_subj = ls_null
	is_notif_body = ls_null
	
End If

Return 1
end function

public function integer of_add_notification (string as_item, string as_user, long al_row, boolean ab_construct);integer li_index, li_round, N
string ls_proj, ls_program

select project_name, round_no, program
into :ls_proj, :li_round, :ls_program
from gigp_application
where gigp_id = :gl_gigp_id;

//If li_round >= 100 Then
//	Return 1
//End If

If ls_program <> 'GIGP' Then
	Return 1
End If

If Not ab_construct Then

	li_index = UpperBound( is_notif_subj)
	
	//Only add one entry per row
	If li_index > 0 Then
		For N = 1 to li_index
			If il_row[N] = al_row Then
				Return 1
			End If
		Next 
	End If
	
	li_index++
	
	If Right(Trim(as_item), 1) = ':' Then
		as_item = Left(Trim(as_item), Len(as_item) - 1)
	End If
	
	il_row[li_index] = al_row
	is_notif_subj[li_index] = 'GIGP Round ' + String(li_round) + ' Database update to #' + String(gl_gigp_id)
	is_notif_body[li_index] = as_item + ', on the ' + this.Tag + ' Tab, was modified for GIGP ' + String(gl_gigp_id) + ' (' + ls_proj + ') by ' + as_user + '.'
	
Else
	If Right(Trim(as_item), 1) = ':' Then
		as_item = Left(Trim(as_item), Len(as_item) - 1)
	End If
	
	is_notif_subj_constr = 'GIGP Construction Date Update to GIGP# ' + String(gl_gigp_id)
	is_notif_body_constr = 'Construction Commencement or Completion information was updated for GIGP# ' + String(gl_gigp_id) + ' (' + ls_proj + ') by ' + as_user + '.'
	
End If

 
 Return 1
end function

public function integer of_send_email (string as_subject, string as_sendto, string as_message);n_cst_gwsend lnvo_gwsend
string ls_subject

 //***************************************************************
// Send email ALERT notification :
//***************************************************************
If NOT gb_production Then 	
	ls_subject = as_subject + " (This is a Test ... Disregard!)"
Else
	ls_subject = as_subject
End If

If as_sendto = '' or IsNull(as_sendto) Then
	Return -1
End If

lnvo_gwsend.of_Reset()
lnvo_gwsend.of_AddRecipient(as_sendto)
lnvo_gwsend.of_SetSubject(ls_subject)
lnvo_gwsend.of_SetMessage(as_Message)
lnvo_gwsend.of_SendMail()

Return 1
end function

on u_tabpg_appinfo_base.create
call super::create
end on

on u_tabpg_appinfo_base.destroy
call super::destroy
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Application"}

end event

event ue_tab_selected;call super::ue_tab_selected;ib_Retrieved = False
end event

event pfc_postupdate;call super::pfc_postupdate;string ls_to

If AncestorReturnValue = 1 Then
	this.of_send_notification()
	
	//Process other email notification and clear out instance variable
	If is_inspect_coord_subj > '' Then
		select description
		into :ls_to
		from gigp_reference
		where category = 'inspect_coord_notification';
		
		this.of_send_email(is_inspect_coord_subj, ls_to, is_inspect_coord_body)
		
		is_inspect_coord_subj = ''
		is_inspect_coord_body = ''
	End If
	
End If

Return AncestorReturnValue
end event

type dw_1 from u_tabpg_dbaccess`dw_1 within u_tabpg_appinfo_base
string tag = "Project Sub Tabpage"
end type

event dw_1::constructor;call super::constructor;
This.ib_RMBMenu = False
end event

event dw_1::itemchanged;call super::itemchanged;string ls_code, ls_user, ls_program

This.SetItem(row, "last_updated_dt", f_getdbdatetime())
This.SetItem(row, "last_updated_by", gnv_app.of_getuserid())

ls_code = this.GetItemString(row, 'ref_ref_code')

Choose Case ls_code
	Case 'readyFINPLANSSUB','readyPLANSSPECSDEC','readyINSPECTION','readyINSPECTREVIEW','readyPLANSSPECS'
		//Notify Inspection Coordinator
		select program
		into :ls_program
		from gigp_application
		where gigp_id = :gl_gigp_id;
		
		If ls_program = 'GIGP' Then
			If IsNull(is_inspect_coord_subj) or is_inspect_coord_subj = '' Then
				ls_user = gnv_app.of_getuserid()
				
				is_inspect_coord_subj = 'GIGP Engineering fields updated for #' + String(gl_gigp_id)
				is_inspect_coord_body =  'The following dates where updated by ' + ls_user + ':  ' + this.GetItemString(row, 'ref_value')
			Else
				is_inspect_coord_body += ', ' + this.GetItemString(row, 'ref_value')
			End If
		End if
		
End Choose

end event

event dw_1::sqlpreview;call super::sqlpreview;
String	ls_category
Long 	ll_gigpID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	
	ll_gigpID = This.GetItemNumber(row, "gigp_id")
	ls_category = This.Tag
	
	f_transactionlog("gigp_id", ll_gigpID, This.DataObject, ls_category, sqlsyntax)
END IF
end event

