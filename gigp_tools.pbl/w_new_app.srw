forward
global type w_new_app from w_gigp_response
end type
type dw_app from u_dw within w_new_app
end type
type dw_descr from u_dw within w_new_app
end type
type dw_sched from u_dw within w_new_app
end type
type dw_budget from u_dw within w_new_app
end type
type dw_funding from u_dw within w_new_app
end type
end forward

global type w_new_app from w_gigp_response
string tag = "New GIGP Application"
integer x = 214
integer y = 221
integer width = 2144
integer height = 912
string title = "New GIGP Application"
dw_app dw_app
dw_descr dw_descr
dw_sched dw_sched
dw_budget dw_budget
dw_funding dw_funding
end type
global w_new_app w_new_app

type variables

Long il_gigpID, il_roundNo

DateTime idt_Now

String is_user
end variables

forward prototypes
public subroutine of_get_nextround ()
end prototypes

public subroutine of_get_nextround ();
String ls_round

Select ref_code
Into :ls_round
From gigp_reference
Where category = "Application"
And sub_category = "nextRound";

il_roundNo = Integer(ls_round)
end subroutine

on w_new_app.create
int iCurrent
call super::create
this.dw_app=create dw_app
this.dw_descr=create dw_descr
this.dw_sched=create dw_sched
this.dw_budget=create dw_budget
this.dw_funding=create dw_funding
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_app
this.Control[iCurrent+2]=this.dw_descr
this.Control[iCurrent+3]=this.dw_sched
this.Control[iCurrent+4]=this.dw_budget
this.Control[iCurrent+5]=this.dw_funding
end on

on w_new_app.destroy
call super::destroy
destroy(this.dw_app)
destroy(this.dw_descr)
destroy(this.dw_sched)
destroy(this.dw_budget)
destroy(this.dw_funding)
end on

event open;call super::open;
is_accessGroups = {"TAS-Global", "Application"}

//*******************************************************
// Get User Info:
//*******************************************************
	
is_user 	= 	gnv_app.of_getuserid()
idt_Now 	=   f_getdbdatetime()
	
//*******************************************************
// Insert new loan row:
//*******************************************************

dw_app.Event pfc_insertrow()

//*******************************************************
// Get/Set Next Round No.
//*******************************************************	

of_get_nextround()

dw_app.SetItem(1, "round_no",il_roundNo)	

dw_app.SetItemStatus(1, 0, Primary!, NotModified!)





end event

event ue_process;call super::ue_process;
Integer li_RC
long 		ll_value, ll_row, ll_rowCnt 
DateTime ldt_value
String	ls_value
Decimal  ld_amount

dw_app.AcceptText()

//*******************************************************
// Validate user entry:
//*******************************************************

//*********************************
// Project Name must be entered:
//*********************************

ls_value = dw_app.GetItemString(1, "project_name")
	
If IsNull(ls_value) Then
	Messagebox("ERROR!", "A Project Name must be entered!")
	is_action = "CANCEL"
	Return
End If	

//*********************************
// Applicant Type must be entered:
//*********************************	

ls_value = dw_app.GetItemString(1, "applicant_type")
	
If IsNull(ls_value) Then
	Messagebox("ERROR!", "A Applicant Type must be entered!")
	is_action = "CANCEL"
	Return 
End If	

//*********************************
// Applicant Status must be entered:
//*********************************	

ls_value = dw_app.GetItemString(1, "app_status")
	
If IsNull(ls_value) Then
	Messagebox("ERROR!", "A Applicant Status must be entered!")
	is_action = "CANCEL"
	Return 
End If	

//*******************************************************
// Set GIGP ID:
//*******************************************************	

il_gigpID = 	 f_gettokenvalue("gigpID", 1)

dw_app.SetItem(1, "gigp_id",il_gigpID)		

//*******************************************************
// Load Additional Application Related Tables:
//*******************************************************	

ll_rowCnt  = dw_descr.Retrieve(il_gigpID)

// Project Description Checklist ->

FOR ll_row = 1 TO  ll_rowCnt 
	dw_descr.SetItem(ll_row, "gigp_id",il_gigpID)	      
	dw_descr.SetItem(ll_row, "last_updated_dt", idt_Now)	
	dw_descr.SetItem(ll_row, "last_updated_by", is_user) 	
	dw_descr.SetItem(ll_row, "ref_code", dw_descr.GetItemString(ll_row, "ref_ref_code")) 	
	dw_descr.SetItemStatus(ll_row, 0, Primary!, NewModified!)
NEXT

// Project Application Schedule -> 

ll_rowCnt  = dw_sched.Retrieve(il_gigpID)

FOR ll_row = 1 TO  ll_rowCnt 
	dw_sched.SetItem(ll_row, "gigp_id",il_gigpID)	      
	dw_sched.SetItem(ll_row, "last_updated_dt", idt_Now)	
	dw_sched.SetItem(ll_row, "last_updated_by", is_user) 
	dw_sched.SetItem(ll_row, "ref_code", dw_sched.GetItemString(ll_row, "ref_ref_code")) 	
	dw_sched.SetItemStatus(ll_row, 0, Primary!, NewModified!)
NEXT

// Project Application Budget ->

ll_rowCnt  = dw_budget.Retrieve(il_gigpID)

ll_value  = 	 f_gettokenvalue("AmountID", ll_rowCnt)

FOR ll_row = 1 TO  ll_rowCnt 
	dw_budget.SetItem(ll_row, "amount_id", (ll_value -  ll_rowCnt + ll_row))
	dw_budget.SetItem(ll_row, "sub_category", dw_budget.GetItemString(ll_row, "ref_sub_category"))
	dw_budget.SetItem(ll_row, "gigp_id",il_gigpID)	      
	dw_budget.SetItem(ll_row, "last_updated_dt", idt_Now)	
	dw_budget.SetItem(ll_row, "last_updated_by", is_user) 
	dw_budget.SetItem(ll_row, "ref_code", dw_budget.GetItemString(ll_row, "ref_ref_code")) 	
	dw_budget.SetItem(ll_row, "ref_amt",  0)
	dw_budget.SetItem(ll_row, "approved_amt",  0)
	dw_budget.SetItemStatus(ll_row, 0, Primary!, NewModified!)
NEXT

// Project Application Funding ->

ll_rowCnt  = dw_funding.Retrieve(il_gigpID)

ll_value  = 	 f_gettokenvalue("AmountID", ll_rowCnt)

FOR ll_row = 1 TO  ll_rowCnt 
	dw_funding.SetItem(ll_row, "amount_id", (ll_value -  ll_rowCnt + ll_row))
	dw_funding.SetItem(ll_row, "sub_category", dw_funding.GetItemString(ll_row, "ref_sub_category"))
	dw_funding.SetItem(ll_row, "gigp_id",il_gigpID)	      
	dw_funding.SetItem(ll_row, "last_updated_dt", idt_Now)	
	dw_funding.SetItem(ll_row, "last_updated_by", is_user) 
	dw_funding.SetItem(ll_row, "ref_code", dw_funding.GetItemString(ll_row, "ref_ref_code")) 	
	dw_funding.SetItem(ll_row, "ref_amt",  0)
	dw_funding.SetItem(ll_row, "approved_amt",  0)
	dw_funding.SetItemStatus(ll_row, 0, Primary!, NewModified!)
NEXT

li_RC = This.Event pfc_save()

If (li_RC = 1) Then
	Close(This)
Else
	is_action = "CANCEL"
End If

end event

event pfc_begintran;call super::pfc_begintran;
EXECUTE IMMEDIATE "begin transaction";

Return 1
//

end event

event pfc_endtran;call super::pfc_endtran;
IF ai_update_results = 1 THEN
	EXECUTE IMMEDIATE "commit";
	MessageBox(this.Tag,"Update was successful.")
	Return 1
ELSE
	EXECUTE IMMEDIATE "rollback";
	MessageBox(this.Tag,"Update failed.")
	Return -1
END IF

end event

type cb_cancel from w_gigp_response`cb_cancel within w_new_app
integer x = 1755
integer y = 676
end type

type cb_ok from w_gigp_response`cb_ok within w_new_app
integer x = 1353
integer y = 676
end type

event cb_ok::clicked;
//OverRide//

is_action = "OK"

Parent.Event ue_process()
end event

type dw_app from u_dw within w_new_app
integer x = 27
integer y = 24
integer width = 2071
integer height = 624
integer taborder = 10
boolean bringtotop = true
string dataobject = "d_proj_application_new"
boolean vscrollbar = false
boolean livescroll = false
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False


end event

event sqlpreview;call super::sqlpreview;
IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	f_transactionlog("gigp_id", il_gigpID, This.DataObject, "New Application", sqlsyntax)
END IF
end event

event pfc_postinsertrow;call super::pfc_postinsertrow;
//*******************************************************
// Set last Updated by & Default Application Status:
//*******************************************************
	
dw_app.setItem(al_row, "last_updated_dt", idt_Now)	
dw_app.setItem(al_row, "last_updated_by", is_user) 
dw_app.setItem(al_row, "app_status", f_get_default_refvalue('appStatus','appStatus'))

dw_app.SetItemStatus(al_row, 0,  Primary!, NotModified!)
end event

type dw_descr from u_dw within w_new_app
boolean visible = false
integer x = 27
integer y = 676
integer width = 1248
integer height = 104
integer taborder = 11
boolean bringtotop = true
boolean titlebar = true
string title = "Project Description - Checklist"
string dataobject = "d_proj_description_checklist"
boolean resizable = true
end type

event constructor;call super::constructor;This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

event sqlpreview;call super::sqlpreview;
IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	f_transactionlog("gigp_id", il_gigpID, This.DataObject, "New Application", sqlsyntax)
END IF
end event

type dw_sched from u_dw within w_new_app
boolean visible = false
integer x = 27
integer y = 792
integer width = 1248
integer height = 104
integer taborder = 21
boolean bringtotop = true
boolean titlebar = true
string title = "Project Application - Schedule"
string dataobject = "d_proj_application_sched"
boolean resizable = true
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

event sqlpreview;call super::sqlpreview;
IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	f_transactionlog("gigp_id", il_gigpID, This.DataObject, "New Application", sqlsyntax)
END IF
end event

type dw_budget from u_dw within w_new_app
boolean visible = false
integer x = 27
integer y = 908
integer width = 1248
integer height = 104
integer taborder = 31
boolean bringtotop = true
boolean titlebar = true
string title = "Project Application - Budget"
string dataobject = "d_proj_application_budget"
boolean resizable = true
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

event sqlpreview;call super::sqlpreview;
IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	f_transactionlog("gigp_id", il_gigpID, This.DataObject, "New Application", sqlsyntax)
END IF
end event

type dw_funding from u_dw within w_new_app
boolean visible = false
integer x = 27
integer y = 1024
integer width = 1248
integer height = 104
integer taborder = 41
boolean bringtotop = true
boolean titlebar = true
string title = "Project Application - Funding"
string dataobject = "d_proj_application_funding"
boolean resizable = true
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

event sqlpreview;call super::sqlpreview;
IF (sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete!) THEN		
	f_transactionlog("gigp_id", il_gigpID, This.DataObject, "New Application", sqlsyntax)
END IF
end event

