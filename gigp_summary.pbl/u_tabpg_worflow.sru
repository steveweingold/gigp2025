forward
global type u_tabpg_worflow from u_tabpg_dbaccess
end type
type dw_2 from u_dw within u_tabpg_worflow
end type
end forward

global type u_tabpg_worflow from u_tabpg_dbaccess
integer width = 2930
integer height = 2432
string text = "Project Workflow"
string picturename = "Structure5!"
dw_2 dw_2
end type
global u_tabpg_worflow u_tabpg_worflow

on u_tabpg_worflow.create
int iCurrent
call super::create
this.dw_2=create dw_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_2
end on

on u_tabpg_worflow.destroy
call super::destroy
destroy(this.dw_2)
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Application", "Workflow"}
end event

event ue_display;call super::ue_display;
If (gl_roundNo <> 1) Then
	This.Visible = False
Else
	This.Visible = True
End If

end event

type dw_1 from u_tabpg_dbaccess`dw_1 within u_tabpg_worflow
integer width = 2894
integer height = 2388
string dataobject = "d_proj_application_workflow"
end type

event dw_1::buttonclicked;call super::buttonclicked;
String 	ls_Text, ls_noteUser, ls_appUser, ls_access
Integer	li_RC

If (dwo.Name = "b_edit") Then	
	
	ls_access = "READ"
	
	dw_1.AcceptText()	
	
	ls_Text     = This.GetItemString(row, "keydate_comments")
			
	If (ib_editAccess = True) Then ls_access = "EDIT"	
	
	li_RC = f_edit_notes(ls_access, ls_Text)
	
	If (li_RC = 1) Then This.SetItem(row, "keydate_comments", ls_Text)	
	
End If
end event

event dw_1::constructor;call super::constructor;
This.ib_RMBMenu = False
end event

event dw_1::sqlpreview;call super::sqlpreview;
IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	f_transactionlog("gigp_id", gl_gigp_id, This.DataObject, "Project Workflow", sqlsyntax)
END IF
end event

event dw_1::pfc_updateprep;call super::pfc_updateprep;
Long 			ll_row, ll_gigpID
Integer		li_alertFlg
String 		ls_description, ls_comments, ls_value, ls_subject, ls_message, ls_refCode, ls_projName, ls_user, ls_space, ls_quote
DateTime	ldt_value, ldt_last
n_cst_string lnv_string

ls_space = ""

Select project_name
Into	:ls_projName
From gigp_application
where gigp_id = :gl_gigp_id;

If (IsNull(ls_projName)) Then ls_projName = ""

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
		This.SetItemStatus(ll_row, 0,  Primary!, NewModified!)
	End If

//	//*******************************************************
//	// Determine if Alert should be sent:
//	// Disabled until further instruction - MPF 10-20-2010	
//	//*******************************************************
//
//	li_alertFlg = dw_1.GetItemNumber(ll_row, "cat_default")
//	
//	
//	If (li_alertFlg = 1) Then
//		
//		ls_description = dw_1.GetItemString(ll_row, "ref_description")
//		
//		ls_comments = dw_1.GetItemString(ll_row, "keydate_comments")
//		
//		ls_refCode = dw_1.GetItemString(ll_row, "ref_code")
//		
//		ls_user = dw_1.GetItemString(ll_row, "last_updated_by")
//		ldt_last = dw_1.GetItemDateTime(ll_row, "last_updated_dt")
//		
//		If (IsNull(ls_comments)) Then ls_comments = ""
//		
//		ldt_value = dw_1.GetItemDateTime(ll_row, "keydate_value")
//		
//		If (IsNull(ldt_value)) Then
//			ls_value = "00/00/0000"
//		Else
//			ls_value = String(ldt_value, "mm/dd/yyyy")
//		End If
//			
//			
//		ls_subject = "GIGP Alert for Project: " + String(gl_gigp_id)
//		
//		ls_message = "Project:  " + ls_projName + " (" + String(gl_gigp_id) + "),  "
//		
//		ls_message += (ls_description + "  " + ls_value + ",  Comments: " + ls_comments)
//		
//		ls_message += ",  Last Updated by " + ls_user + " on " + String(ldt_last, "mm/dd/yyyy")
//		
//		ls_message += ",  Ref Code: " + ls_refCode
//		
//		ls_quote = '"'
//		
//		ls_message = lnv_string.of_GlobalReplace (ls_message, ls_quote, ls_space)
//		
//		ls_quote = "'"
//		
//		ls_message = lnv_string.of_GlobalReplace (ls_message, ls_quote, ls_space)
//		
//		f_send_email_alert(ls_subject, ls_message)
//		
//	End If	
	ll_row = dw_1.GetNextModified(ll_row, Primary!)

LOOP

Return AncestorReturnValue











end event

event dw_1::itemchanged;call super::itemchanged;
String 		ls_refCode, ls_status
Integer		li_RC
Long			ll_row

ls_refCode = This.GetItemString(row, "ref_ref_code")

CHOOSE CASE ls_refCode

CASE  "DEEMELIG", "DEEMINELIG", "TOBEDETRM"
	
	If (dwo.Name = "keydate_value") Then
		
		If Not IsNull(data) Then
			
			If (ls_refCode = "DEEMELIG") Then		
				ls_status = "ELIGIBLE"
				
			ElseIf (ls_refCode = "DEEMINELIG") Then		
				ls_status = "INELIGIBLE"
								
			ElseIf (ls_refCode = "TOBEDETRM") Then
				ls_status = "TOBEDETRM"		
				
			End If	
						
			If Not(IsNull(ls_status)) Then		
				ll_row = dw_2.GetRow()
				li_RC = dw_2.SetItem(ll_row, "app_status", ls_status)
				li_RC = dw_2.SetItem(ll_row, "last_updated_by", gnv_app.of_getuserid())
				li_RC = dw_2.SetItem(ll_row, "last_updated_dt", f_getdbdatetime())							
			End If			
			
		End If			
		
	End If
	
END CHOOSE


This.SetItem(row, "last_updated_by", gnv_app.of_getuserid())
This.SetItem(row, "last_updated_dt", f_getdbdatetime())
end event

event dw_1::pfc_retrieve;call super::pfc_retrieve;
dw_2.Retrieve(gl_gigp_id)

Return AncestorReturnValue
end event

type dw_2 from u_dw within u_tabpg_worflow
boolean visible = false
integer x = 1349
integer y = 1960
integer width = 1550
integer height = 432
integer taborder = 11
boolean bringtotop = true
boolean titlebar = true
string title = "App Status"
string dataobject = "d_app_status"
boolean vscrollbar = false
boolean livescroll = false
end type

event sqlpreview;call super::sqlpreview;
IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	f_transactionlog("gigp_id", gl_gigp_id, This.DataObject, "Project Workflow", sqlsyntax)
END IF
end event

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

