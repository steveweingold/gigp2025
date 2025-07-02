forward
global type u_tabpg_contactmgmt_detail from u_tabpg_dbaccess
end type
end forward

global type u_tabpg_contactmgmt_detail from u_tabpg_dbaccess
string text = "Contact Info."
string picturename = "Picture!"
end type
global u_tabpg_contactmgmt_detail u_tabpg_contactmgmt_detail

on u_tabpg_contactmgmt_detail.create
call super::create
end on

on u_tabpg_contactmgmt_detail.destroy
call super::destroy
end on

event ue_delete;call super::ue_delete;
dw_1.DeleteRow(dw_1.GetRow())
end event

type dw_1 from u_tabpg_dbaccess`dw_1 within u_tabpg_contactmgmt_detail
string dataobject = "d_contacts_master_detail"
end type

event dw_1::constructor;call super::constructor;
This.Object.DataWindow.ReadOnly="Yes"
end event

event dw_1::buttonclicked;call super::buttonclicked;String 	ls_Text, ls_csz
Integer	li_RC
Long		ll_row
n_ds		lds_print


messagebox('test', dwo.name)

Choose Case dwo.Name
	Case 'b_edit'
		ls_Text = This.GetItemString(row, "comments")	
		li_RC = f_edit_notes("READ", ls_Text)		
		
	Case 'b_envelope'
		
		If NOT IsValid(lds_print) Then lds_print = CREATE n_ds
		
		lds_print.DataObject = 'd_envelopes_print'
		
		ll_row = lds_print.InsertRow(0)
		
		lds_print.SetItem(ll_row, 'prefix', this.GetItemString(row, 'prefix'))
		lds_print.SetItem(ll_row, 'full_name', this.GetItemString(row, 'full_name'))
		lds_print.SetItem(ll_row, 'title', this.GetItemString(row, 'title'))
		lds_print.SetItem(ll_row, 'organization_name', this.GetItemString(row, 'organization'))
		lds_print.SetItem(ll_row, 'address_line_1', this.GetItemString(row, 'mail_address1'))
		lds_print.SetItem(ll_row, 'address_line_2', this.GetItemString(row, 'mail_address2'))
		lds_print.SetItem(ll_row, 'address_line_3', this.GetItemString(row, 'mail_address3'))
		lds_print.SetItem(ll_row, 'city', this.GetItemString(row, 'mail_city'))
		lds_print.SetItem(ll_row, 'state', this.GetItemString(row, 'mail_state'))
		lds_print.SetItem(ll_row, 'zip', this.GetItemString(row, 'mail_zip'))
		
		lds_print.Event pfc_print()
		
		
		
End Choose

end event

event dw_1::pfc_retrieve;
//OverRide//

//PFC Linkage Service manages Retrieve

Return 1
end event

event dw_1::sqlpreview;call super::sqlpreview;Long ll_contactID

IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN
	
	ll_contactID = This.GetItemNumber(row, "contact_id", buffer, False)
	
	f_transactionlog("contact_id", ll_contactID, This.DataObject, "Contacts", sqlsyntax)
END IF
end event

