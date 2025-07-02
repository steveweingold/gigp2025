forward
global type u_tabpg_efc_contract_dates from u_tabpg_appinfo_base
end type
end forward

global type u_tabpg_efc_contract_dates from u_tabpg_appinfo_base
string tag = "Contract Dates"
integer height = 2000
string text = "Contract Dates"
string picturename = "PictureListBox!"
end type
global u_tabpg_efc_contract_dates u_tabpg_efc_contract_dates

type variables
string is_filter
boolean ib_readytotargetnotify

end variables

on u_tabpg_efc_contract_dates.create
call super::create
end on

on u_tabpg_efc_contract_dates.destroy
call super::destroy
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Contract"}

is_filter = dw_1.Object.DataWindow.Table.Filter
end event

event ue_tab_selected;call super::ue_tab_selected;dw_1.SetFilter(is_filter)
dw_1.Filter()
end event

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_efc_contract_dates
integer x = 18
integer y = 12
integer width = 2821
integer height = 1968
string dataobject = "d_proj_project_efc_agreement_dates"
end type

event dw_1::pfc_updateprep;call super::pfc_updateprep;
Long 	ll_row, ll_gigpID

//*******************************************************
// Loop thru modified rows:
//*******************************************************

ll_row	= dw_1.GetNextModified(0, Primary!)

DO WHILE ll_row > 0	
	
	//*******************************************************
	// If new row, Set key values:
	//*******************************************************

	ll_gigpID = This.GetItemNumber(ll_row, "gigp_id")

	If IsNull(ll_gigpID) Then
		This.SetItem(ll_row, "gigp_id",gl_gigp_id)	  
		This.SetItem(ll_row, "ref_code", This.GetItemString(ll_row, "ref_ref_code")) 	
		This.SetItem(ll_row, "last_updated_by", gnv_app.of_getuserid())
		This.SetItem(ll_row, "last_updated_dt", f_getdbdatetime())		
		This.SetItemStatus(ll_row, 0,  Primary!, NewModified!)
	End If
		
	ll_row = dw_1.GetNextModified(ll_row, Primary!)

LOOP

Return AncestorReturnValue
end event

event dw_1::buttonclicked;call super::buttonclicked;String 	ls_Text, ls_noteUser, ls_appUser, ls_access, ls_cat
Integer	li_RC
Long		ll_find

Choose Case dwo.Name 
	Case "b_edit"
	
		ls_access = "READ"
		
		dw_1.AcceptText()	
		
		ls_Text     = This.GetItemString(row, "keydate_comments")
				
		If (ib_editAccess = True) Then ls_access = "EDIT"	
		
		li_RC = f_edit_notes(ls_access, ls_Text)
		
		If (li_RC = 1) Then This.SetItem(row, "keydate_comments", ls_Text)	
		
	Case 'b_amend'
		
		SetRedraw(False)		
		this.SetFilter('')
		this.Filter()
		
		//Check to see if Extension already added
		If this.Find("gigp_id > 0 and ref_sub_category = 'Amend'", 1, this.RowCount()) > 0 Then
			this.SetFilter(is_filter)
			this.Filter()
			this.SetRedraw(True)
			Return
		End If
		
		ll_find = this.Find("ref_sub_category = 'Amend'", 1, this.RowCount())
		
		Do While ll_find > 0
			this.SetItemStatus(ll_find, 0, Primary!, NewModified!)
			this.SetItemStatus(ll_find, 'keydate_value', Primary!, DataModified!)
			this.SetItem(ll_find, 'gigp_id', gl_gigp_id)
			this.SetItem(ll_find, 'ref_code', this.GetItemString(ll_find, 'ref_ref_code'))
			
			If ll_find = this.RowCount() Then
				ll_find = 0
			Else
				ll_find = this.Find("ref_sub_category = 'Amend'", ll_find + 1, this.RowCount())
			End If
			
		Loop
		
		this.SetFilter(is_filter)
		this.Filter()
		
		SetRedraw(True)
		
	Case 'b_extend'
		
		SetRedraw(False)		
		this.SetFilter('')
		this.Filter()
		
		//Check to see if ALL Extensions already added  SW, 5/2015 Added #2 and #3 as per Angela
		//******** IF ADDING NEW EXTENSION ABILITY, CHECK THE DATAWINDOW'S FILTER!
		ls_cat = 'Extend'
		If this.Find("gigp_id > 0 and ref_sub_category = 'Extend'", 1, this.RowCount()) > 0 Then
			ls_cat = 'Extend2'
			If this.Find("gigp_id > 0 and ref_sub_category = 'Extend2'", 1, this.RowCount()) > 0 Then
				ls_cat = 'Extend3'
				If this.Find("gigp_id > 0 and ref_sub_category = 'Extend3'", 1, this.RowCount()) > 0 Then
					ls_cat = 'Extend4'
					If this.Find("gigp_id > 0 and ref_sub_category = 'Extend4'", 1, this.RowCount()) > 0 Then
						ls_cat = 'Extend5'
						If this.Find("gigp_id > 0 and ref_sub_category = 'Extend5'", 1, this.RowCount()) > 0 Then
							ls_cat = 'Extend6'
							If this.Find("gigp_id > 0 and ref_sub_category = 'Extend6'", 1, this.RowCount()) > 0 Then
					
								this.SetFilter(is_filter)
								this.Filter()
								this.SetRedraw(True)
								Return
								
							End If
						End If
					End If
				End If
			End If
		End If
		
		ll_find = this.Find("ref_sub_category = '" + ls_cat + "'", 1, this.RowCount())
		
		Do While ll_find > 0
			this.SetItemStatus(ll_find, 0, Primary!, NewModified!)
			this.SetItemStatus(ll_find, 'keydate_value', Primary!, DataModified!)
			this.SetItem(ll_find, 'gigp_id', gl_gigp_id)
			this.SetItem(ll_find, 'ref_code', this.GetItemString(ll_find, 'ref_ref_code'))
			
			If ll_find = this.RowCount() Then
				ll_find = 0
			Else
				ll_find = this.Find("ref_sub_category = '" + ls_cat + "'", ll_find + 1, this.RowCount())
			End If
			
		Loop
		
		this.SetFilter(is_filter)
		this.Filter()
		
		SetRedraw(True)
		
		this.ScrollToRow(this.RowCount() - 2)
		
End Choose
end event

event dw_1::itemchanged;call super::itemchanged;string ls_term, ls_round, ls_program
long ll_find, ll_term, ll_gigp
decimal ld_amt
datetime ldt_expdate
date ldt_date

If lower(gnv_app.of_getuserid()) <> 'syron' and lower(gnv_app.of_getuserid()) <> 'hahn' Then
	parent.of_add_notification(this.GetItemString(row, 'ref_description'), gnv_app.of_getuserid(), row, False)
End If

If dwo.name = 'keydate_value' Then
	//Set notification for Grant Committee Target (SW, 3/2025 per Brian M)
	If this.GetItemString(row, 'ref_ref_code') = 'agreeGRANTCMTDATE' Then
		ib_readytotargetnotify = True
	End If
	
	//Set Agreement Expiration to 2 years after the Agreement fully Executed Date
	If this.GetItemString(row, 'ref_ref_code') = 'agreeAGRFULLEX' Then
		ldt_date = Date(data)
		
		select convert(varchar, round_no), program
		into :ls_round, :ls_program
		from gigp_application
		where gigp_id = :gl_gigp_id;
		
		If ls_program = 'EPG' Then
			select contract_award_amt
			into :ld_amt
			from gigp_cfa_items
			where gigp_id = :gl_gigp_id;
			
			If ld_amt > 50000 Then	//If EPG and Contract Amt over $50k then get that term
				select ref_code
				into :ls_term
				from gigp_reference 
				where category = 'AgreeTerm'
				and sub_category = 'EPGOVER50K';
				
			Else	//EPG w/ Contract Amt not over $50k just get round specific term
				select ref_code
				into :ls_term
				from gigp_reference 
				where category = 'AgreeTerm'
				and sub_category = :ls_round;
				
			End If
			
		Else	//GIGP, just get term by round
			select ref_code
			into :ls_term
			from gigp_reference 
			where category = 'AgreeTerm'
			and sub_category = :ls_round;
			
		End If
		
		ll_term = Long(ls_term)
		ldt_expdate = DateTime(RelativeDate(ldt_date, ll_term))
		
		ll_find = this.Find("ref_ref_code = 'agreeAGREXP'", 1, this.RowCount())
		
		If ll_find > 0 Then
			
			If IsNull(this.GetItemNumber(ll_find, 'gigp_id')) Then	//New
				this.SetItemStatus(ll_find, 0, Primary!, NewModified!)
				this.SetItemStatus(ll_find, 'keydate_value', Primary!, DataModified!)
				this.SetItem(ll_find, 'gigp_id', gl_gigp_id)
				this.SetItem(ll_find, 'ref_code', this.GetItemString(ll_find, 'ref_ref_code'))
				this.SetItem(ll_find, 'keydate_value', ldt_expdate)
				this.SetItem(ll_find, 'last_updated_by', gnv_app.of_getuserid())
				this.SetItem(ll_find, 'last_updated_dt', DateTime(Today()))
			Else	//Existing
				this.SetItemStatus(ll_find, 0, Primary!, DataModified!)
				this.SetItemStatus(ll_find, 'keydate_value', Primary!, DataModified!)
				this.SetItem(ll_find, 'keydate_value', ldt_expdate)
				this.SetItem(ll_find, 'last_updated_by', gnv_app.of_getuserid())
				this.SetItem(ll_find, 'last_updated_dt', DateTime(Today()))
			End If
		
		End If
		
	End If
	
End If

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
		where gigp_id = :gl_gigp_id;
		
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
		and gigp_id = :gl_gigp_id;
		
		//ls_recipients = 'steve.weingold@efc.ny.gov'	//****TESTING
		
		If ls_recipients > '' Then
		
			ls_applicant = f_get_applicant_name(gl_gigp_id)
			ls_subject = 'Small Grants Ready to Target set for ' + ls_applicant + ' (' + ls_program + ')'
			ls_message = 'Ready to Target set for ' + ls_applicant + ' (GIGP/EPG  ' + String(gl_gigp_id) + '  &  CFA App Id ' + String(ll_cfa) + ')'
			
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

