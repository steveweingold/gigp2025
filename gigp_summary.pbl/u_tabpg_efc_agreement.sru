forward
global type u_tabpg_efc_agreement from u_tabpg_dbaccess
end type
type tab_1 from u_tab_efc_agreement_details within u_tabpg_efc_agreement
end type
type tab_1 from u_tab_efc_agreement_details within u_tabpg_efc_agreement
end type
type dw_pending from u_dw within u_tabpg_efc_agreement
end type
end forward

global type u_tabpg_efc_agreement from u_tabpg_dbaccess
integer width = 4078
integer height = 2432
boolean hscrollbar = true
string text = "Grant Agreement"
string picturename = "Library5!"
tab_1 tab_1
dw_pending dw_pending
end type
global u_tabpg_efc_agreement u_tabpg_efc_agreement

type variables
long il_gigp_id
boolean ib_readytotargetnotify = False
end variables

on u_tabpg_efc_agreement.create
int iCurrent
call super::create
this.tab_1=create tab_1
this.dw_pending=create dw_pending
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tab_1
this.Control[iCurrent+2]=this.dw_pending
end on

on u_tabpg_efc_agreement.destroy
call super::destroy
destroy(this.tab_1)
destroy(this.dw_pending)
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Contract", "ReadyToTarget"}

end event

event ue_tab_selected;call super::ue_tab_selected;//*************************************************************
// Force Re-Retrieve of Contract Dates Checklist:
//*************************************************************

tab_1.SelectedTab = 1
tab_1.tabpage_1.of_retrieve()
end event

type dw_1 from u_tabpg_dbaccess`dw_1 within u_tabpg_efc_agreement
string tag = "Agreement Info"
integer width = 4014
integer height = 116
string dataobject = "d_agreement_header"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_1::itemchanged;call super::itemchanged;If dwo.name = 'ready_to_target' Then
	If data = '1' Then
		ib_readytotargetnotify = True
		This.SetItem(row, "ready_to_target_by", gnv_app.of_getuserid())
		This.SetItem(row, "ready_to_target_dt", f_getdbdatetime())
	Else
		ib_readytotargetnotify = False
	End If
End If

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

event dw_1::constructor;call super::constructor;
This.ib_RMBMenu = False
end event

event dw_1::buttonclicked;call super::buttonclicked;If dwo.name = 'b_pending' Then
	If dw_pending.Visible Then
		dw_pending.Visible = False
	Else
		dw_pending.Retrieve(il_gigp_id)
		dw_pending.Visible = True
	End If
End If
end event

event dw_1::pfc_retrieve;call super::pfc_retrieve;If AncestorReturnValue > 0 Then
	il_gigp_id = this.GetItemNumber(1, 'gigp_id')
	dw_pending.Retrieve(il_gigp_id)
End If

//Set User Access to Ready to Target
If gnv_app.of_ingroup('ReadyToTarget') Then
	this.SetItem(this.GetRow(), 'ready_to_target_protect', 0)
Else
	this.SetItem(this.GetRow(), 'ready_to_target_protect', 1)
End If

this.SetItemStatus(this.GetRow(), 0, Primary!, NotModified!)

Return AncestorReturnValue
end event

event dw_1::pfc_postupdate;call super::pfc_postupdate;string ls_recipients, ls_message, ls_subject, ls_applicant, ls_program
long ll_cfa
datetime ldt_targetgc
n_cst_gwsend lnvo_gwsend

If ancestorreturnvalue = 1 Then
	If ib_readytotargetnotify Then
		ib_readytotargetnotify = False
		SetNull(ldt_targetgc)
		
		//Notify
		select cfa_no, program
		into :ll_cfa, :ls_program
		from gigp_application
		where gigp_id = :il_gigp_id;
		
		If IsNull(ll_cfa) Then ll_cfa = 0
		
		select description
		into :ls_recipients
		from gigp_reference
		where category = 'ReadyToTarget'
		and sub_category = 'Notification';
		
		select keydate_value
		into :ldt_targetgc
		from gigp_key_dates
		where ref_code = 'agreeGRANTCMTDATE'
		and gigp_id = :il_gigp_id;
		
		//ls_recipients = 'steve.weingold@efc.ny.gov'	//****TESTING
		
		If ls_recipients > '' Then
		
			ls_applicant = f_get_applicant_name(il_gigp_id)
			ls_subject = 'Small Grants Ready to Target set for ' + ls_applicant + ' (' + ls_program + ')'
			ls_message = 'Ready to Target set for ' + ls_applicant + ' (GIGP/EPG  ' + String(il_gigp_id) + '  &  CFA App Id ' + String(ll_cfa) + ')'
			
			If NOT IsNull(ldt_targetgc) Then
				ls_message += ' and targeted for the Grant Committee Date of ' + String(ldt_targetgc, 'm/d/yyyy') + '.'
			Else
				ls_message += ' with no Grant Committee Date indicated at this time.'
			End If
			
			lnvo_gwsend.of_Reset()
			lnvo_gwsend.of_AddRecipient(ls_recipients)
			lnvo_gwsend.of_SetSubject(ls_subject)
			lnvo_gwsend.of_SetMessage(ls_message)
			lnvo_gwsend.of_SendMail()
			
		End If
		
	End If
End If

Return ancestorreturnvalue
end event

type tab_1 from u_tab_efc_agreement_details within u_tabpg_efc_agreement
integer x = 5
integer y = 152
integer width = 4014
integer height = 2240
integer taborder = 11
boolean bringtotop = true
end type

type dw_pending from u_dw within u_tabpg_efc_agreement
boolean visible = false
integer x = 1829
integer y = 348
integer width = 1911
integer height = 1792
integer taborder = 11
boolean bringtotop = true
boolean titlebar = true
string title = "Pending Items"
string dataobject = "d_pending_items_rpt"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
string icon = "fldropen.ico"
end type

event constructor;call super::constructor;this.SetTransObject(SQLCA)
end event

