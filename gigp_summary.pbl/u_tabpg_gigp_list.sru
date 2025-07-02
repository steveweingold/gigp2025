forward
global type u_tabpg_gigp_list from u_tabpg_dbaccess
end type
type dw_2 from u_dw within u_tabpg_gigp_list
end type
type cb_find from commandbutton within u_tabpg_gigp_list
end type
type st_1 from statictext within u_tabpg_gigp_list
end type
type em_find from editmask within u_tabpg_gigp_list
end type
type pb_1 from picturebutton within u_tabpg_gigp_list
end type
type cb_cfa from commandbutton within u_tabpg_gigp_list
end type
type st_2 from statictext within u_tabpg_gigp_list
end type
type em_cfa from editmask within u_tabpg_gigp_list
end type
type sle_find from singlelineedit within u_tabpg_gigp_list
end type
type cb_filter from commandbutton within u_tabpg_gigp_list
end type
type cb_app from commandbutton within u_tabpg_gigp_list
end type
type st_3 from statictext within u_tabpg_gigp_list
end type
type cb_srf from commandbutton within u_tabpg_gigp_list
end type
type sle_srf from singlelineedit within u_tabpg_gigp_list
end type
end forward

global type u_tabpg_gigp_list from u_tabpg_dbaccess
integer width = 2939
integer height = 2432
boolean hscrollbar = true
string text = "Small Grants List"
string picturename = "Menu!"
event ue_newapp ( )
event ue_postconstructor ( )
dw_2 dw_2
cb_find cb_find
st_1 st_1
em_find em_find
pb_1 pb_1
cb_cfa cb_cfa
st_2 st_2
em_cfa em_cfa
sle_find sle_find
cb_filter cb_filter
cb_app cb_app
st_3 st_3
cb_srf cb_srf
sle_srf sle_srf
end type
global u_tabpg_gigp_list u_tabpg_gigp_list

type variables
string is_filter
string is_find
boolean ib_scroll, ib_log
end variables

forward prototypes
public subroutine of_set_title ()
public subroutine of_log (string as_logtype, string as_logmessage)
end prototypes

event ue_newapp();
Long ll_gigpID, ll_row, ll_count

ll_count = dw_1.Event pfc_retrieve()

Select Max(gigp_id)
Into  :ll_gigpID
From   gigp_application;

ll_row = dw_1.Find("gigp_id = " + String(ll_gigpID), 1, ll_count)

If (ll_row > 0) Then dw_1.ScrollToRow(ll_row)

end event

event ue_postconstructor();long ll_find
string ls_find

If IsNull(gs_keyname) Then
	If ib_log then of_log('Post Constructor - gs_keyname', 'NULL')
Else
	If ib_log then of_log('Post Constructor - gs_keyname', gs_keyname)
End If

If IsNull(gs_keyvalue) Then
	If ib_log then of_log('Post Constructor - gs_keyvalue', 'NULL')
Else
	If ib_log then of_log('Post Constructor - gs_keyvalue', gs_keyvalue)
End If


//Check to see if coming from another app and scroll to that project, else filter based on previous filter
If NOT IsNull(gs_keyname) and gs_keyname > '' Then
	
	Choose Case gs_keyname 
		Case 'gigp_id'
			is_find = 'gigp_id = ' + gs_keyvalue
			
		Case 'project_no'
			//is_find = 'project_no = "' + gs_keyvalue + '"'
			is_find = 'project_no like "%' + gs_keyvalue + '%"'	//Using like to handle prefix or no
			
	End Choose
	
	If ib_log then of_log('Post Contstructor - is_find', is_find)
	
	ib_scroll = true
	gs_keyname = ''
	gs_keyvalue = ''
	
Else
	If ib_log then of_log('Post Contstructor', 'Nothing passed in so filter based on users last filter')
	
	ib_scroll = false
	
	//Set the filter from the ini file if it exists (if no filter was set, then it will return "?" and will ignore)
	If NOT IsNull(is_filter) and is_filter > '' and is_filter <> '?' Then
		dw_1.SetFilter(is_filter)
		dw_1.Filter()
		
	End If
	
End If

end event

public subroutine of_set_title ();String ls_projName, ls_series, ls_title
Long   ll_row, ll_locked

ll_row = dw_1.GetRow() 

If (ll_row < 1) Then Return

//*******************************************************
// Keep track of the current applicant:
//*******************************************************

gl_gigp_id  	 	= dw_1.GetItemNumber(ll_row, "gigp_id")
gl_roundNo  	= dw_1.GetItemNumber(ll_row, "round_no")
ls_projName 	= dw_1.GetItemString(ll_row, "project_name")
ll_locked			= dw_1.GetItemNumber(ll_row, "locked_flag")

ls_title 			= ls_projName + " (" + String(gl_gigp_id) + ")"

If ll_locked = 1 Then
	ls_title += '  **LOCKED**'
End IF

//*******************************************************
// Set Window Title:
//*******************************************************

it_Parent.iw_Parent.Function Dynamic of_set_title(ls_title)

end subroutine

public subroutine of_log (string as_logtype, string as_logmessage);insert into EfcLog (LogCategory, LogDate, LogType, LogMessage)
values ('GIGP', GetDate(), :as_logtype, :as_logmessage);
end subroutine

on u_tabpg_gigp_list.create
int iCurrent
call super::create
this.dw_2=create dw_2
this.cb_find=create cb_find
this.st_1=create st_1
this.em_find=create em_find
this.pb_1=create pb_1
this.cb_cfa=create cb_cfa
this.st_2=create st_2
this.em_cfa=create em_cfa
this.sle_find=create sle_find
this.cb_filter=create cb_filter
this.cb_app=create cb_app
this.st_3=create st_3
this.cb_srf=create cb_srf
this.sle_srf=create sle_srf
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_2
this.Control[iCurrent+2]=this.cb_find
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.em_find
this.Control[iCurrent+5]=this.pb_1
this.Control[iCurrent+6]=this.cb_cfa
this.Control[iCurrent+7]=this.st_2
this.Control[iCurrent+8]=this.em_cfa
this.Control[iCurrent+9]=this.sle_find
this.Control[iCurrent+10]=this.cb_filter
this.Control[iCurrent+11]=this.cb_app
this.Control[iCurrent+12]=this.st_3
this.Control[iCurrent+13]=this.cb_srf
this.Control[iCurrent+14]=this.sle_srf
end on

on u_tabpg_gigp_list.destroy
call super::destroy
destroy(this.dw_2)
destroy(this.cb_find)
destroy(this.st_1)
destroy(this.em_find)
destroy(this.pb_1)
destroy(this.cb_cfa)
destroy(this.st_2)
destroy(this.em_cfa)
destroy(this.sle_find)
destroy(this.cb_filter)
destroy(this.cb_app)
destroy(this.st_3)
destroy(this.cb_srf)
destroy(this.sle_srf)
end on

event constructor;call super::constructor;//*******************************************************
// Set Access Group(s):
//*******************************************************
string ls_switch

is_accessGroups = {"TAS-Global", "APP"}

gnv_Event.of_Subscribe(this,"ue_newapp")

//Determine whether to log
select code
into :ls_switch
from EfcReference
where Module = 'Hub'
and Category = 'Logging'
and Subcategory = 'GIGP';

If ls_switch = '1' Then ib_log = True

//Get the filter from the ini file
is_filter = ProfileString(gnv_app.of_GetAppIniFile(), 'GIGP', 'FILTER', '')

If ib_log then of_log('Constructor - Filter from ini', is_filter)

this.Event Post ue_postconstructor()

//	Which CWISS system(s) do we update?
If IsNull(gs_cwissrewriteupdateindicator) or gs_cwissrewriteupdateindicator = '' Then
	//	Ref Code Valid Values: Update Both, Update Sybase, Update SQL Server
	select ref_code
	into	:gs_cwissrewriteupdateindicator
	from reference
	where ref_type = 'CWISS Rewrite Update Indicator';

End If

end event

event destructor;call super::destructor;string ls_filter

//Set the filter to the ini file
ls_filter = dw_1.Object.DataWindow.Table.Filter
SetProfileString(gnv_app.of_GetAppIniFile(), 'GIGP', 'FILTER', ls_filter)


gnv_Event.of_UnSubscribe(this,"ue_newapp")

end event

event ue_tab_selected;call super::ue_tab_selected;string ls_app
m_gigp_master lm_Menu

lm_Menu = it_Parent.iw_Parent.MenuID

//******************************************************
// Customize Menu:
//******************************************************

lm_Menu.m_tools.m_newapplication.ToolBarItemVisible = True
lm_Menu.m_tools.m_newapplication.Visible = True

//lm_Menu.m_tools.m_utilities.m_applicationimport.ToolBarItemVisible = True
//lm_Menu.m_tools.m_utilities.m_applicationimport.Visible = True

//Enable the Locking checkbox if user has "Lock" access
If gnv_app.of_ingroup('Lock') Then
	lm_Menu.m_file.m_save.Visible = True
	lm_Menu.m_file.m_save.ToolBarItemVisible = True
Else
	lm_Menu.m_file.m_save.Visible = False
	lm_Menu.m_file.m_save.ToolBarItemVisible = False
End If

lm_Menu.m_edit.ToolBarItemVisible = False
lm_Menu.m_edit.Visible = False

lm_Menu.m_edit.m_find.Visible = True
lm_Menu.m_edit.m_find.ToolBarItemVisible = True

lm_Menu.m_view.m_filter.Visible = True
lm_Menu.m_view.m_filter.ToolBarItemVisible = True

ib_editAccess = gnv_app.of_ingroup(is_accessGroups)


//Disable the New App item based on ref table flag
select ref_code
into :ls_app
from gigp_reference
where category = 'NewAppEnable';

If ls_app = 'N' Then
	lm_menu.m_tools.m_newapplication.Enabled = False
Else
	lm_menu.m_tools.m_newapplication.Enabled = True
End If


//******************************************************
// Order the Sheet Toolbar:
//******************************************************

lm_Menu.m_edit.m_find.ToolBarItemOrder 					= 1
lm_Menu.m_view.m_filter.ToolBarItemOrder 				= 2
lm_Menu.m_tools.m_newapplication.ToolBarItemOrder	= 3
lm_Menu.m_tools.m_utilities.m_applicationimport.ToolBarItemOrder	= 4
lm_Menu.m_file.m_close.ToolBarItemOrder 					= 5


ib_retrieved = False
end event

event ue_tab_deselected;call super::ue_tab_deselected;
m_gigp_master lm_Menu

lm_Menu = it_Parent.iw_Parent.MenuID

//******************************************************
// Customize Menu:
//******************************************************

lm_Menu.m_tools.m_newapplication.ToolBarItemVisible = False
lm_Menu.m_tools.m_newapplication.Visible = False

//lm_Menu.m_tools.m_utilities.m_applicationimport.ToolBarItemVisible = False
//lm_Menu.m_tools.m_utilities.m_applicationimport.Visible = False

lm_Menu.m_file.m_save.Visible = True
lm_Menu.m_file.m_save.ToolBarItemVisible = True

lm_Menu.m_edit.ToolBarItemVisible = True
lm_Menu.m_edit.Visible = True

lm_Menu.m_edit.m_find.Visible = False
lm_Menu.m_edit.m_find.ToolBarItemVisible = False

lm_Menu.m_view.m_filter.Visible = False
lm_Menu.m_view.m_filter.ToolBarItemVisible = False

end event

type dw_1 from u_tabpg_dbaccess`dw_1 within u_tabpg_gigp_list
integer y = 132
integer width = 2894
integer height = 2260
integer taborder = 40
string dataobject = "d_proj_application_list"
end type

event dw_1::constructor;call super::constructor;
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
This.inv_sort.of_SetColumnHeader(TRUE)

//********************************************************************
// Register Loan ID: 
//********************************************************************

This.of_registerkey("gigp_id")


////Enable the Locking checkbox if user has "Lock" access
//If gnv_app.of_ingroup('Lock') Then
//	this.Object.locked_flag.Protect = 0			//The checkbox
//End If
end event

event dw_1::rowfocuschanged;call super::rowfocuschanged;
//*******************************************************
// Keep track of the current Loan ID & Loan Type:
//*******************************************************

If (currentrow < 1) Then Return AncestorReturnValue

of_set_title()

it_Parent.iw_Parent.Event  Dynamic Post ue_postit()

it_Parent.TabTriggerEvent("ue_display")

it_Parent.of_SetRetrieve(False)

parent.ib_Retrieved = True


end event

event dw_1::pfc_rowchanged;call super::pfc_rowchanged;
If (dw_1.RowCount() > 0) Then dw_1.Event RowFocusChanged(dw_1.GetRow())
end event

event dw_1::doubleclicked;call super::doubleclicked;
//**************************************************
// Go to the Details Tabpage: 
//**************************************************

IF row > 0 THEN
	this.Event RowFocusChanged(row)
	it_Parent.SelectedTab = 2
END IF
end event

event dw_1::pfc_retrieve;call super::pfc_retrieve;
Return dw_2.Retrieve()
end event

event dw_1::retrieveend;call super::retrieveend;////Enable the Locking checkbox if user has "Lock" access
//If gnv_app.of_ingroup('Lock') Then
//	this.Object.locked_flag.Protect = 0			//The checkbox
//	this.Object.DataWindow.ReadOnly = 'no'
//End If
//int li_Row
//
//if gs_projNo <> "" then
//	li_Row = this.Find("mid(project_no,4) = '" + gs_projNo + "'",rowcount,1)
//
//	if li_Row > 0 then
//		this.ScrollToRow(li_Row)
//	end if
//
//	gs_projNo = ""
//end if

long ll_find

If ib_log then of_log('List dw retrieveend - is_find again', is_find)

If ib_scroll Then
	ib_scroll = False
	ll_find = this.Find(is_find, 1, this.RowCount())
	
	If ib_log then of_log('List dw retrieveend - ll_find', string(ll_find))
	
	this.ScrollToRow(ll_find)
End If
end event

event dw_1::clicked;call super::clicked;//Enable the Locking checkbox if user has "Lock" access
If gnv_app.of_ingroup('Lock') Then
	this.Object.locked_flag.Protect = 0			//The checkbox
	this.Object.DataWindow.ReadOnly = 'no'
End If
end event

type dw_2 from u_dw within u_tabpg_gigp_list
boolean visible = false
integer x = 59
integer y = 284
integer width = 2615
integer height = 1680
integer taborder = 50
boolean bringtotop = true
boolean titlebar = true
string title = "Application Breakdown"
string dataobject = "d_appstatus_summary"
boolean controlmenu = true
boolean resizable = true
end type

event constructor;call super::constructor;This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

type cb_find from commandbutton within u_tabpg_gigp_list
integer x = 1678
integer y = 36
integer width = 197
integer height = 76
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean italic = true
string text = "Find!"
end type

event clicked;
String ls_gigpID, ls_findString, ls_message
Long  ll_rowCount, ll_found

ls_gigpID = em_find.Text

If (IsNull(ls_gigpID) Or Trim(ls_gigpID) = "") Then Return

ll_rowCount = dw_1.RowCount()

If (ll_rowCount < 1) Then Return

ls_findString = "gigp_id =" + ls_gigpID

ll_found = dw_1.Find(ls_findString, 1, ll_rowCount)

If (ll_found > 0) Then
	dw_1.ScrollToRow(ll_found)
	dw_1.SelectRow(ll_found, false)
	dw_1.SelectRow(ll_found, true)
Else
	ls_message = ("GIGP Project # " + ls_gigpID + " not found in the filtered projects.")
	MessageBox("ERROR!", ls_message)
End If
end event

type st_1 from statictext within u_tabpg_gigp_list
integer x = 1051
integer y = 48
integer width = 402
integer height = 48
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Small Grants ID:"
alignment alignment = right!
boolean focusrectangle = false
end type

type em_find from editmask within u_tabpg_gigp_list
integer x = 1467
integer y = 36
integer width = 201
integer height = 72
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
string mask = "#####"
end type

event getfocus;
This.Text = ""
end event

event modified;
cb_find.Event Clicked()
end event

type pb_1 from picturebutton within u_tabpg_gigp_list
integer x = 891
integer y = 32
integer width = 110
integer height = 84
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean flatstyle = true
string picturename = "Undo!"
alignment htextalign = left!
string powertiptext = "Clear Filter!"
end type

event clicked;sle_find.Text = ''
dw_1.SetFilter("")
dw_1.Filter()
dw_1.Sort()

end event

type cb_cfa from commandbutton within u_tabpg_gigp_list
integer x = 2345
integer y = 36
integer width = 197
integer height = 76
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean italic = true
string text = "Find!"
end type

event clicked;String ls_cfa, ls_findString, ls_message, ls_gigpID
Long  ll_rowCount, ll_found, ll_gigpid, ll_cfa

ls_cfa = em_cfa.Text

If (IsNull(ls_cfa) Or Trim(ls_cfa) = "") Then Return

If NOT IsNumber(ls_cfa) Then Return

ll_cfa = Long(ls_cfa)

select gigp_id
into :ll_gigpid
from gigp_application
where cfa_no = :ll_cfa;

If IsNull(ll_gigpid) or ll_gigpid <= 0 Then
	MessageBox('CFA Search', 'Application not found for CFA# ' + String(ll_cfa))
	Return
End If

ls_gigpID = String(ll_gigpid)

ll_rowCount = dw_1.RowCount()

If (ll_rowCount < 1) Then Return

ls_findString = "gigp_id =" + ls_gigpID

ll_found = dw_1.Find(ls_findString, 1, ll_rowCount)

If (ll_found > 0) Then
	dw_1.ScrollToRow(ll_found)
	dw_1.SelectRow(ll_found, false)
	dw_1.SelectRow(ll_found, true)
Else
	ls_message = ("CFA # " + ls_cfa + ' (GIGP ' + ls_gigpID + ") not found in the filtered projects.")
	MessageBox("ERROR!", ls_message)
End If
end event

type st_2 from statictext within u_tabpg_gigp_list
integer x = 1943
integer y = 48
integer width = 174
integer height = 48
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "CFA#:"
alignment alignment = right!
boolean focusrectangle = false
end type

type em_cfa from editmask within u_tabpg_gigp_list
integer x = 2135
integer y = 36
integer width = 201
integer height = 72
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
string mask = "#######"
end type

event getfocus;
This.Text = ""
end event

event modified;
cb_cfa.Event Clicked()
end event

type sle_find from singlelineedit within u_tabpg_gigp_list
integer x = 5
integer y = 36
integer width = 535
integer height = 72
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
borderstyle borderstyle = stylelowered!
end type

event modified;cb_filter.Event Clicked()
end event

type cb_filter from commandbutton within u_tabpg_gigp_list
integer x = 549
integer y = 32
integer width = 343
integer height = 84
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Quick Filter"
boolean flatstyle = true
end type

event clicked;n_cst_project_buildfilter ln_projFilter
String ls_filterString


If sle_find.Text > '' Then
	ls_filterString = "(Upper(cf_applicant_name) like '%" + Upper(sle_find.Text) + "%') or (Upper(project_name) like '%" + Upper(sle_find.Text) + "%')"
	
Else
	ln_projFilter    = CREATE n_cst_project_buildfilter
	ln_projFilter.Event ue_build_report()
	ls_filterString = ln_projFilter.of_return_filter()
	
	If ln_projFilter.ib_cancel Then Return
	
	If IsValid(ln_projFilter) Then Destroy ln_projFilter
	
End If
	
dw_1.SetFilter(ls_filterString)
dw_1.Filter()

If dw_1.RowCount() > 0 Then
	dw_1.ScrollToRow(1)
	dw_1.Event pfc_rowchanged()
End If

of_set_title()

it_Parent.TabTriggerEvent("ue_display")

it_Parent.iw_Parent.Event  Dynamic Post ue_postit()

em_find.Text = ""
em_cfa.Text = ""
end event

type cb_app from commandbutton within u_tabpg_gigp_list
integer x = 3387
integer y = 36
integer width = 622
integer height = 76
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Application Summary"
end type

event clicked;dw_2.Visible = True
end event

type st_3 from statictext within u_tabpg_gigp_list
integer x = 2656
integer y = 48
integer width = 174
integer height = 48
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "SRF#:"
alignment alignment = right!
boolean focusrectangle = false
end type

type cb_srf from commandbutton within u_tabpg_gigp_list
integer x = 3131
integer y = 36
integer width = 197
integer height = 76
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean italic = true
string text = "Find!"
end type

event clicked;String ls_srf, ls_findString, ls_message, ls_gigpID, ls_searchstring
Long  ll_rowCount, ll_found, ll_gigpid, ll_cfa

ls_srf = sle_srf.Text

If (IsNull(ls_srf) Or Trim(ls_srf) = "") Then Return

ls_searchstring = '%' + Upper(ls_srf) + '%'

select gigp_id
into :ll_gigpid
from gigp_application
where Upper(project_no) like :ls_searchstring;

If IsNull(ll_gigpid) or ll_gigpid <= 0 Then
	MessageBox('CFA Search', 'Application not found for SRF# ' + ls_srf)
	Return
End If

ls_gigpID = String(ll_gigpid)

ll_rowCount = dw_1.RowCount()

If (ll_rowCount < 1) Then Return

ls_findString = "gigp_id =" + ls_gigpID

ll_found = dw_1.Find(ls_findString, 1, ll_rowCount)

If (ll_found > 0) Then
	dw_1.ScrollToRow(ll_found)
	dw_1.SelectRow(ll_found, false)
	dw_1.SelectRow(ll_found, true)
Else
	ls_message = ("SRF # " + ls_srf + ' (GIGP ' + ls_gigpID + ") not found in the filtered projects.")
	MessageBox("ERROR!", ls_message)
End If
end event

type sle_srf from singlelineedit within u_tabpg_gigp_list
integer x = 2848
integer y = 36
integer width = 274
integer height = 72
integer taborder = 60
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
end type

event modified;cb_srf.Event Clicked()


end event

event getfocus;This.Text = ""
end event

