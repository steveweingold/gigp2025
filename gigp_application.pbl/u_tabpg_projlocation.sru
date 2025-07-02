forward
global type u_tabpg_projlocation from u_tabpg_appinfo_base
end type
type pb_edit from picturebutton within u_tabpg_projlocation
end type
end forward

global type u_tabpg_projlocation from u_tabpg_appinfo_base
string tag = "Project Location"
string text = "Location"
string picturename = "Custom042!"
pb_edit pb_edit
end type
global u_tabpg_projlocation u_tabpg_projlocation

on u_tabpg_projlocation.create
int iCurrent
call super::create
this.pb_edit=create pb_edit
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.pb_edit
end on

on u_tabpg_projlocation.destroy
call super::destroy
destroy(this.pb_edit)
end on

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_projlocation
event ue_editrow ( )
string title = "Project Location"
string dataobject = "d_proj_location"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_1::ue_editrow();
Long ll_row, ll_contactID, ll_rc
str_contactparms lstr_parms

ll_contactID = dw_1.GetItemNumber(dw_1.GetRow(), "contact_id")

lstr_parms.str_contactid = ll_contactID

lstr_parms.str_gigpid =  gl_gigp_id

OpenWithParm(w_contacts_edit, lstr_parms)

ll_contactID = Message.DoubleParm

If (ll_contactID = -1) Then Return

ll_rc = dw_1.of_Retrieve()

end event

event dw_1::buttonclicked;call super::buttonclicked;String 	ls_Text, ls_access, ls_lat, ls_lon
Integer	li_RC
decimal ld_lat, ld_lon
inet l_inet
n_cst_string ln_string
string ls_address, ls_city, ls_state, ls_zip, ls_url

Choose Case dwo.Name
	Case 'b_edit'
		ls_access = "READ"
		ls_Text     = This.GetItemString(row, "comments")
		li_RC = f_edit_notes(ls_access, ls_Text)
		
	Case 'b_map'
		//Get reference to the default Browser
		GetContextService("Internet", l_inet)
		
		//Get the address
		ls_address = this.GetItemString(row, 'mail_address1')
		ls_city = this.GetItemString(row, 'mail_city')
		ls_state = this.GetItemString(row, 'mail_state')
		ls_zip = this.GetItemString(row, 'mail_zip')
		If IsNull(ls_address) Then ls_address = ''
		If IsNull(ls_city) Then ls_city = ''
		If IsNull(ls_state) Then ls_state = ''
		If IsNull(ls_zip) Then ls_zip = ''
		
		ls_lat = this.GetItemString(row, 'gis_latitude')
		ls_lon = this.GetItemString(row, 'gis_longitude')
		ld_lat = 0
		ld_lon = 0
		
		If IsNumber(ls_lat) Then
			ld_lat = Dec(ls_lat)
		End If
		
		If IsNumber(ls_lon) Then
			ld_lon = Dec(ls_lon)
		End If
		
		If ld_lat = 0 or ld_lon = 0 Then
			MessageBox('Map It!', 'Please enter Coordinates for mapping.')
			Return
		End If
		
		//Create and open the URL
		//ls_url = 'https://www.google.com/maps/place/' + ls_address + '+' + ls_city + ',+' + ls_state + ',+' + ls_zip
		ls_url = 'https://www.google.com/maps?q=' + string(ld_lat) + ',' + string(ld_lon)
		ls_url = ln_string.of_globalreplace(ls_url, ' ', '+')	//Replace any spaces with "+"
		l_inet.hyperlinktourl(ls_url)
	
End Choose

end event

event dw_1::pfc_updateprep;call super::pfc_updateprep;
//Long 	ll_row, ll_gigpID
//
////*******************************************************
//// Loop thru modified rows:
////*******************************************************
//
//ll_row	= dw_1.GetNextModified(0, Primary!)
//
//DO WHILE ll_row > 0	
//	
//	//*******************************************************
//	// If new row, Set key values:
//	//*******************************************************
//
//	ll_gigpID = This.GetItemNumber(ll_row, "gigp_id")
//
//	If IsNull(ll_gigpID) Then
//		This.SetItem(ll_row, "gigp_id",gl_gigp_id)	 
//		
//		This.SetItem(ll_row, "note_category", "appNote") 	
//		This.SetItem(ll_row, "note_type", This.GetItemString(ll_row, "ref_ref_code")) 			
//		This.SetItemStatus(ll_row, 0,  Primary!, NewModified!)
//	End If
//		
//	ll_row = dw_1.GetNextModified(ll_row, Primary!)
//
//LOOP
//
Return AncestorReturnValue
//
end event

event dw_1::itemchanged;
////OverRide//
//
//This.SetItem(row, "user_id", gnv_app.of_getuserid())
//This.SetItem(row, "note_dt", f_getdbdatetime())
end event

event dw_1::sqlpreview;call super::sqlpreview;
//String	ls_category
//Long 	ll_gigpID
//
//IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
//	
//	ll_gigpID = This.GetItemNumber(row, "gigp_id")
//	ls_category = This.Tag	
//	
//	f_transactionlog("gigp_id", ll_gigpID, This.DataObject, ls_category, sqlsyntax)
//END IF
end event

event dw_1::pfc_retrieve;
//OverRide//

Long ll_rowCnt

ll_rowCnt = This.Retrieve(gl_gigp_id, "PLC")

If (ll_rowCnt < 1) Then	
	This.InsertRow(0)		
End If




Return ll_rowCnt


end event

event dw_1::doubleclicked;call super::doubleclicked;
If ((row < 1) Or (ib_editAccess = False)) Then Return

This.Event ue_editrow()
end event

event dw_1::retrieveend;call super::retrieveend;
pb_edit.Visible = ib_editAccess
end event

type pb_edit from picturebutton within u_tabpg_projlocation
integer x = 14
integer y = 12
integer width = 110
integer height = 96
integer taborder = 11
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "EditStops!"
alignment htextalign = left!
end type

event clicked;
dw_1.Event ue_editrow()
end event

