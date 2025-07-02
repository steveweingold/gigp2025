forward
global type u_tabpg_special_conditions from u_tabpg_appinfo_base
end type
type cb_custom from commandbutton within u_tabpg_special_conditions
end type
end forward

global type u_tabpg_special_conditions from u_tabpg_appinfo_base
string tag = "Special Conditions"
integer height = 2000
string text = "Special Conditions"
string picturename = "PictureListBox!"
cb_custom cb_custom
end type
global u_tabpg_special_conditions u_tabpg_special_conditions

on u_tabpg_special_conditions.create
int iCurrent
call super::create
this.cb_custom=create cb_custom
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_custom
end on

on u_tabpg_special_conditions.destroy
call super::destroy
destroy(this.cb_custom)
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "SpecialCondition"}
end event

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_special_conditions
integer y = 108
integer height = 1872
string dataobject = "d_proj_project_special_conditions"
end type

event dw_1::buttonclicked;call super::buttonclicked;String 	ls_Text, ls_noteUser, ls_appUser, ls_access, ls_desc, ls_ref_code
Integer	li_RC

If (dwo.Name = "b_edit") Then	
	
	ls_access = "READ"
	
	dw_1.AcceptText()	
	
	ls_Text     = This.GetItemString(row, "keydate_comments")
			
	If (ib_editAccess = True) Then ls_access = "EDIT"	
	
	li_RC = f_edit_notes(ls_access, ls_Text)
	
	If (li_RC = 1) Then This.SetItem(row, "keydate_comments", ls_Text)	
	
End If

If dwo.name = 'b_vew_condition' Then
	this.AcceptText()
	
	ls_ref_code = this.GetItemString(row, 'ref_ref_code')
	
	If Left(ls_ref_code, 6) = 'CUSTOM' Then
		ls_desc = this.GetItemString(row, 'alternate_text')
		ls_access = 'EDIT'
	Else
		ls_desc = this.GetItemString(row, 'ref_description')
		ls_access = 'READ'
	End If
	
	li_RC = f_edit_notes(ls_access, ls_desc)
	
	If li_RC = 1 Then 
		This.SetItem(row, "alternate_text", ls_desc)
	End If
	
end If
end event

event dw_1::pfc_updateprep;call super::pfc_updateprep;Long 	ll_row, ll_gigpID

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

event dw_1::pfc_retrieve;//override
integer li_round

//Get round number
select round_no
into :li_round
from gigp_application
where gigp_id = :gl_gigp_ID;

//Retrieve
Return This.Retrieve(gl_gigp_ID, String(li_round))
end event

type cb_custom from commandbutton within u_tabpg_special_conditions
integer x = 9
integer y = 12
integer width = 544
integer height = 80
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Custom Condition"
end type

event clicked;string ls_ref
long ll_row

ll_row = dw_1.InsertRow(dw_1.RowCount() + 1)

ls_ref = 'CUSTOM' + String(gl_gigp_ID) + 'R' + String(ll_row)	//Ref code for Custom, adding the gigp id and row num to make it unique

dw_1.SetItem(ll_row, 'ref_ref_code', ls_ref)
dw_1.SetItem(ll_row, 'keydate_choice', '1')
dw_1.SetItemStatus(ll_row, 0, Primary!,NewModified!)
end event

