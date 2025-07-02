forward
global type w_report_controller from w_detail
end type
type dw_parms from u_dw within w_report_controller
end type
type cb_select from commandbutton within w_report_controller
end type
type pb_next from picturebutton within w_report_controller
end type
type pb_previous from picturebutton within w_report_controller
end type
type cb_pdf from commandbutton within w_report_controller
end type
type pb_1 from picturebutton within w_report_controller
end type
end forward

global type w_report_controller from w_detail
boolean visible = false
string title = "GIGP Reports"
string menuname = "m_gigp_sheet"
dw_parms dw_parms
cb_select cb_select
pb_next pb_next
pb_previous pb_previous
cb_pdf cb_pdf
pb_1 pb_1
end type
global w_report_controller w_report_controller

type variables

m_gigp_sheet	im_Menu

String  is_computes[]
end variables

forward prototypes
public subroutine of_select_report ()
public subroutine of_create_report ()
public subroutine of_setpfcfilterservice ()
end prototypes

public subroutine of_select_report ();
Blob lblb_data
Long ll_RC, ll_count, ll_row
Integer li_extractFlag
String ls_reportName, ls_dataObject, ls_reportObject 
str_report_parm lstr_parm

Open(w_report_select)

lstr_parm = Message.PowerObjectParm

lblb_data = lstr_parm.str_parm

ll_RC = dw_parms.SetFullState(lblb_data)

//dw_parms.Print()

ll_count = dw_parms.RowCount()

If (ll_count < 1) Then Return

ls_ReportName = dw_parms.GetItemString(1, "prm_name")

If (ls_ReportName = "CANCEL") Then Return

of_create_report()


end subroutine

public subroutine of_create_report ();String ls_value, ls_reportName, ls_reportObject, ls_dataObject, ls_reportCategory, ls_extract
Long   ll_row, ll_count
Integer li_numcomputes
n_cst_report ln_rpt
Blob lblb_data
Long ll_RC
str_report_parm lstr_parm
pointer oldpointer 

//*******************************************************
// Get Report Parms:
//*******************************************************

ll_count = dw_parms.RowCount()

If (ll_count <> 5) Then	
	Messagebox('ERROR!', 'Error getting report information - Contact I.T.')
	Return
End If

oldpointer = SetPointer(HourGlass!)

dw_detail.SetRedraw(False)

FOR ll_row = 1 to ll_count
	
	ls_value = dw_parms.GetItemString(ll_row, "prm_name")
 
 	If (ls_value = "ReportName") Then
		ls_reportName = dw_parms.GetItemString(ll_row, "prm_value")
	ElseIf (ls_value = "DataObject") Then
		ls_dataObject = dw_parms.GetItemString(ll_row, "prm_value")
	ElseIf (ls_value = "ReportObject") Then
		ls_reportObject = dw_parms.GetItemString(ll_row, "prm_value")
	ElseIf (ls_value = 'Extract') Then
		ls_extract = dw_parms.GetItemString(ll_row, 'prm_value')
	Else //Report Category 
		ls_reportCategory = dw_parms.GetItemString(ll_row, "prm_value")
	End If       

NEXT

//*******************************************************
// Build Report:
//*******************************************************

If (ls_dataObject = ls_reportObject) Then	
	dw_detail.DataObject = ls_dataObject
	dw_detail.SetTransObject(SQLCA)
	dw_detail.Retrieve()
Else
	ln_rpt    = CREATE USING ls_reportObject
	ln_rpt.DataObject = ls_dataObject
	ln_rpt.Event ue_build_report()
	lstr_parm = ln_rpt.of_return_report()
	lblb_data = lstr_parm.str_parm
	ll_RC     = dw_detail.SetFullState(lblb_data)
	If IsValid(ln_rpt) Then Destroy ln_rpt
End If

dw_detail.SetTransObject(SQLCA)
	
//*******************************************************
// Exclude computed columns from Filter & Sort Dialog:
//*******************************************************	

of_setPFCFilterService()
	
li_numcomputes =  dw_detail.inv_sort.of_GetObjects(is_computes, "compute", "*", False)

dw_detail.inv_sort.of_setexclude(is_computes)	
dw_detail.inv_filter.of_setexclude(is_computes)		

//*******************************************************
// Disable Sorting if Report contains Groups:
//*******************************************************	

ls_value = dw_detail.Describe("DataWindow.Bands")

If (Pos(ls_value, "header.1") > 0) Then
	im_Menu.m_view.m_sort.Visible = False
	im_Menu.m_view.m_sort.ToolBarItemVisible = False
Else
	im_Menu.m_view.m_sort.Visible = True
	im_Menu.m_view.m_sort.ToolBarItemVisible = True
End If

//*******************************************************
// Show Expand/Collapse Menu Item if a Treeview Style Report:
//*******************************************************	

ls_value = dw_detail.Describe("datawindow.tree.DefaultExpandToLevel")	
ll_count = dw_detail.Rowcount()	
	
im_Menu.m_view.m_expand.Text = "Expand All"
im_Menu.m_view.m_expand.ToolBarItemText = "Expand All"	
	
If (ls_value <> "?" and ll_count > 0) Then
	im_Menu.m_view.m_expand.Visible = True
	im_Menu.m_view.m_expand.ToolBarItemVisible = True
Else
	im_Menu.m_view.m_expand.Visible = False
	im_Menu.m_view.m_expand.ToolBarItemVisible = False
End If

//*******************************************************
// Do not allow print & remove Print Preview for extracts:
//*******************************************************	
If ls_extract = 'Y' Then
	
	dw_detail.Modify("DataWindow.Print.Preview=No")
//	im_Menu.m_file.m_print.Enabled = False	//SW, 6/2012

Else	
	dw_detail.Modify("DataWindow.Print.Preview=Yes")	
//	im_Menu.m_file.m_print.Enabled = True	//SW, 6/2012

End If

//*******************************************************
// Finish Up:
//*******************************************************	
	
SetPointer(oldpointer)
dw_detail.SetRedraw(True)

dw_detail.SetFocus()



end subroutine

public subroutine of_setpfcfilterservice ();
dw_detail.of_SetFilter(TRUE)
//dw_detail.inv_filter.of_SetColumnDisplayNameStyle(0)
dw_detail.inv_filter.of_SetStyle(0)
end subroutine

on w_report_controller.create
int iCurrent
call super::create
if this.MenuName = "m_gigp_sheet" then this.MenuID = create m_gigp_sheet
this.dw_parms=create dw_parms
this.cb_select=create cb_select
this.pb_next=create pb_next
this.pb_previous=create pb_previous
this.cb_pdf=create cb_pdf
this.pb_1=create pb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_parms
this.Control[iCurrent+2]=this.cb_select
this.Control[iCurrent+3]=this.pb_next
this.Control[iCurrent+4]=this.pb_previous
this.Control[iCurrent+5]=this.cb_pdf
this.Control[iCurrent+6]=this.pb_1
end on

on w_report_controller.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.dw_parms)
destroy(this.cb_select)
destroy(this.pb_next)
destroy(this.pb_previous)
destroy(this.cb_pdf)
destroy(this.pb_1)
end on

event pfc_postopen;call super::pfc_postopen;
of_select_report()
end event

event open;call super::open;
//******************************************************
// Customize Menu:
//******************************************************

im_Menu = This.MenuID

im_Menu.m_file.m_print.Visible = True
im_Menu.m_file.m_print.ToolBarItemVisible = True

im_Menu.m_file.m_save.Visible = False
im_Menu.m_file.m_save.ToolBarItemVisible = False

im_Menu.m_file.m_saveas.Visible = True
im_Menu.m_file.m_saveas.ToolBarItemVisible = True

im_Menu.m_view.m_zoom.Visible = True
im_Menu.m_view.m_zoom.ToolBarItemVisible = True

im_Menu.m_view.Visible = True

im_Menu.m_view.m_filter.Visible = True
im_Menu.m_view.m_filter.ToolBarItemVisible = True

im_Menu.m_view.m_sort.Visible = True
im_Menu.m_view.m_sort.ToolBarItemVisible = True

//im_Menu.m_view.m_expand.Visible = True
//im_Menu.m_view.m_expand.ToolBarItemVisible = True


im_Menu.m_view.m_expand.Text = "Expand All"
im_Menu.m_view.m_expand.ToolBarItemText = "Expand All"


this.inv_resize.of_Register(pb_next,"FixedToRight") 
this.inv_resize.of_Register(pb_previous,"FixedToRight") 
this.inv_resize.of_Register(dw_detail,"ScaleToRight&Bottom")


end event

event closequery;
//OverRide//
end event

event ue_check_access;
//OverRide//
end event

event pfc_open;call super::pfc_open;w_gigp_frame lw_frame

If Message.StringParm = 'w_report_controller' Then
	of_select_report()
Else
	lw_frame = gnv_app.of_getframe()
	If IsValid(lw_frame) Then
		lw_frame.Event Dynamic pfc_open()
	End If
End If
end event

type dw_detail from w_detail`dw_detail within w_report_controller
event pfc_saveas ( )
event ue_expand ( )
integer x = 27
integer y = 132
integer width = 2391
integer height = 1156
string title = "Reports"
end type

event dw_detail::pfc_saveas();
This.Saveas()
end event

event dw_detail::ue_expand();
//*************************************************************
// Expand / Collapse Treeview Style Report:
//*************************************************************

String ls_text

ls_text = im_Menu.m_view.m_expand.ToolBarItemText

If  (ls_text= "Expand All") Then
	dw_detail.ExpandAll( )
	im_Menu.m_view.m_expand.Text = "Collapse ALL"
	im_Menu.m_view.m_expand.ToolBarItemText = "Collapse ALL"
Else
	dw_detail.CollapseAll( )
	im_Menu.m_view.m_expand.Text = "Expand All"
	im_Menu.m_view.m_expand.ToolBarItemText = "Expand All"
End If

dw_detail.GroupCalc()
end event

event dw_detail::constructor;call super::constructor;
//This.Object.DataWindow.ReadOnly="Yes"

This.ib_RMBMenu = False

//********************************************************************
// Start PFC Row Selection Service:
//********************************************************************

This.of_SetRowSelect(True)
This.inv_rowselect.of_SetStyle(0)


//********************************************************************
// Start PFC Sort Service:
//********************************************************************

This.of_SetSort(True)
This.inv_sort.of_SetStyle(1)


//********************************************************************
// Turn on the Filter Service for dw's:
//********************************************************************

of_setPFCFilterService()

end event

event dw_detail::pfc_print;//OverRide//

//****REVISIT... multiple copies - first page coming out on back side of last page
//long ll_pagecount, ll_summary
//
//ll_pagecount = Long(this.Describe("Evaluate('pageCount()', 1)"))
//
//If mod(ll_pagecount, 2) <> 0 Then
//	ll_summary = Long(this.Object.DataWindow.Summary.Height)
//	
//	this.Object.DataWindow.Summary.Height = String(ll_summary + 2000)
//	
//	ll_summary = Long(this.Object.DataWindow.Summary.Height)
//	
//	messagebox('summary after', ll_summary)
//	
//End If


If IsNull(This.DataObject) Then Return -1

If (This.RowCount() < 1) Then Return -1

Return This.Print(true,true)

Return 1
end event

event dw_detail::pfc_zoom;

//OverRide//


Long ll_Count

ll_count  = This.RowCount() 

If (ll_count < 1) Then Return  0



if IsValid (inv_PrintPreview) then
	if inv_PrintPreview.of_GetEnabled() then
		return inv_PrintPreview.of_SetZoom()
	end if
end if

return FAILURE
end event

event dw_detail::pfc_filterdlg;
//OverRide//

Long ll_Count

ll_count  = This.RowCount() 

If (ll_count < 1) Then Return  0

if IsValid (inv_Filter) then return inv_Filter.Event pfc_filterdlg()

return FAILURE
end event

event dw_detail::pfc_sortdlg;
//OverRide//

Long ll_Count

ll_count  = This.RowCount() 

If (ll_count < 1) Then Return  0

if IsValid (inv_Sort) then	return inv_Sort.Event pfc_SortDlg()

return FAILURE
end event

type dw_parms from u_dw within w_report_controller
boolean visible = false
integer x = 27
integer y = 32
integer width = 215
integer height = 96
integer taborder = 10
boolean bringtotop = true
boolean titlebar = true
string title = "Parms"
string dataobject = "d_report_parms"
end type

type cb_select from commandbutton within w_report_controller
integer x = 27
integer y = 16
integer width = 421
integer height = 92
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Select a Report"
end type

event clicked;
of_select_report()
end event

type pb_next from picturebutton within w_report_controller
integer x = 2318
integer y = 16
integer width = 101
integer height = 88
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "Next!"
alignment htextalign = left!
string powertiptext = "Next Page"
end type

event clicked;

dw_detail.ScrollNextPage()
end event

type pb_previous from picturebutton within w_report_controller
integer x = 2171
integer y = 16
integer width = 101
integer height = 88
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "Prior!"
alignment htextalign = left!
string powertiptext = "Previous Page"
end type

event clicked;

dw_detail.ScrollPriorPage()
end event

type cb_pdf from commandbutton within w_report_controller
integer x = 498
integer y = 16
integer width = 421
integer height = 92
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Save As"
end type

event clicked;string ls_paper

dw_detail.SaveAs("", PDF!, false)

end event

type pb_1 from picturebutton within w_report_controller
integer x = 969
integer y = 12
integer width = 110
integer height = 96
integer taborder = 50
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "Preview!"
alignment htextalign = left!
string powertiptext = "Print Preview!"
end type

event clicked;
String ls_value

ls_value = dw_detail.Describe("DataWindow.Print.Preview")

If (ls_value = "yes") Then
	dw_detail.Modify("DataWindow.Print.Preview=no")
Else
	dw_detail.Modify("DataWindow.Print.Preview=Yes")
End If

end event

