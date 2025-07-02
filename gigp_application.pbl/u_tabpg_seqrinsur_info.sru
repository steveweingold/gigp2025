forward
global type u_tabpg_seqrinsur_info from u_tabpg_appinfo_base
end type
type dw_seqrtype from u_dw within u_tabpg_seqrinsur_info
end type
end forward

global type u_tabpg_seqrinsur_info from u_tabpg_appinfo_base
string tag = "SEQR"
integer height = 2000
string text = "SEQR"
string picturename = "PictureListBox!"
dw_seqrtype dw_seqrtype
end type
global u_tabpg_seqrinsur_info u_tabpg_seqrinsur_info

forward prototypes
public subroutine of_set_seqr_type ()
end prototypes

public subroutine of_set_seqr_type ();Long ll_rowCnt, N
String ls_seqrType, ls_null, ls_code
dwItemStatus l_status

ll_rowcnt = dw_1.RowCount()
SetNull(ls_null)

If (ll_rowCnt < 1) Then Return

dw_seqrtype.AcceptText()

ls_seqrtype = dw_seqrtype.GetItemString(1, "seqr_type")

If (IsNull(ls_seqrtype) Or Trim(ls_seqrtype) = "") Then
	ls_seqrtype = "Dummy"
End If


FOR N = 1 TO ll_rowCnt
	
	l_status = dw_1.GetItemStatus(N, 0, Primary!)	
	
	dw_1.SetItem(N, "cc_seqr_type", ls_seqrtype)
	dw_1.SetItemStatus(N, 0, Primary!, l_status)
	
	//SW, 5/2013
	If ls_seqrtype = 'Type2' Then
		ls_code = dw_1.GetItemString(N, 'ref_ref_code')
		Choose Case ls_code
			Case 'seqrDECLRESOLRCVD','seqrEAFFORMVER','seqrENBPUBDT','seqrLASLTRISS','seqrNOTDETNONSIG'
				dw_1.SetItem(N, 'keydate_ind', 'NA')
				dw_1.SetItemStatus(N, 'keydate_ind', Primary!, NotModified!)
		End Choose
	End If
	
//NEED TO HASH THIS OUT MORE	
//	If ls_seqrtype <> 'Dummy' Then
//		If dw_1.GetItemNumber(N, 'cf_enable') = 0 Then
//			dw_1.SetItem(N, 'keydate_ind', 'NA')
//		Else
//			dw_1.SetItem(N, 'keydate_ind', ls_null)
//		End If
//	End If

NEXT

end subroutine

on u_tabpg_seqrinsur_info.create
int iCurrent
call super::create
this.dw_seqrtype=create dw_seqrtype
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_seqrtype
end on

on u_tabpg_seqrinsur_info.destroy
call super::destroy
destroy(this.dw_seqrtype)
end on

event constructor;call super::constructor;
//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Legal"}
end event

type dw_1 from u_tabpg_appinfo_base`dw_1 within u_tabpg_seqrinsur_info
integer x = 18
integer y = 12
integer width = 2821
integer height = 1968
string dataobject = "d_proj_project_seqrinsur_dates"
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

event dw_1::pfc_retrieve;call super::pfc_retrieve;
 dw_seqrtype.Event pfc_retrieve()
 
 Return AncestorReturnValue
end event

event dw_1::itemchanged;call super::itemchanged;datetime ldt_date
string ls_status, ls_null

If lower(gnv_app.of_getuserid()) <> 'syron' and lower(gnv_app.of_getuserid()) <> 'hahn' Then
	parent.of_add_notification(this.GetItemString(row, 'ref_description'), gnv_app.of_getuserid(), row, False)
End If

Choose Case dwo.name
	Case  'keydate_value'
		
		ldt_date = this.GetItemDateTime(row, 'keydate_value', Primary!, True)
		
		If IsNull(ldt_date) Then
			ls_status = this.GetItemString(row, 'keydate_ind')
			
			If IsNull(ls_status) Then
				this.SetItem(row, 'keydate_ind', 'PENDING')
			End If
			
		End If
	
End Choose

end event

type dw_seqrtype from u_dw within u_tabpg_seqrinsur_info
integer x = 55
integer y = 32
integer width = 818
integer height = 96
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_proj_seqrtype"
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

event itemchanged;call super::itemchanged;

Post of_set_seqr_type()
end event

event pfc_retrieve;call super::pfc_retrieve;

 dw_seqrtype.Retrieve(gl_gigp_id)
 
 Post of_set_seqr_type()
 
 Return AncestorReturnValue
end event

