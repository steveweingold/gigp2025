forward
global type u_tab_gigp_summary from u_tab_dbaccess
end type
type tabpage_1 from u_tabpg_gigp_list within u_tab_gigp_summary
end type
type tabpage_1 from u_tabpg_gigp_list within u_tab_gigp_summary
end type
type tabpage_2 from u_tabpg_application within u_tab_gigp_summary
end type
type tabpage_2 from u_tabpg_application within u_tab_gigp_summary
end type
type tabpage_3 from u_tabpg_contacts within u_tab_gigp_summary
end type
type tabpage_3 from u_tabpg_contacts within u_tab_gigp_summary
end type
type tabpage_4 from u_tabpg_worflow within u_tab_gigp_summary
end type
type tabpage_4 from u_tabpg_worflow within u_tab_gigp_summary
end type
type tabpage_6 from u_tabpg_notes within u_tab_gigp_summary
end type
type tabpage_6 from u_tabpg_notes within u_tab_gigp_summary
end type
type tabpage_7 from u_tabpg_efc_agreement within u_tab_gigp_summary
end type
type tabpage_7 from u_tabpg_efc_agreement within u_tab_gigp_summary
end type
type tabpage_8 from u_tabpg_profess_contracts within u_tab_gigp_summary
end type
type tabpage_8 from u_tabpg_profess_contracts within u_tab_gigp_summary
end type
type tabpage_9 from u_tabpg_disbursements within u_tab_gigp_summary
end type
type tabpage_9 from u_tabpg_disbursements within u_tab_gigp_summary
end type
end forward

global type u_tab_gigp_summary from u_tab_dbaccess
integer width = 2958
integer height = 2552
boolean fixedwidth = true
boolean showpicture = true
tabpage_1 tabpage_1
tabpage_2 tabpage_2
tabpage_3 tabpage_3
tabpage_4 tabpage_4
tabpage_6 tabpage_6
tabpage_7 tabpage_7
tabpage_8 tabpage_8
tabpage_9 tabpage_9
event ue_call_log ( )
end type
global u_tab_gigp_summary u_tab_gigp_summary

event ue_call_log();tabpage_3.Event ue_call_log()
end event

on u_tab_gigp_summary.create
this.tabpage_1=create tabpage_1
this.tabpage_2=create tabpage_2
this.tabpage_3=create tabpage_3
this.tabpage_4=create tabpage_4
this.tabpage_6=create tabpage_6
this.tabpage_7=create tabpage_7
this.tabpage_8=create tabpage_8
this.tabpage_9=create tabpage_9
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tabpage_1
this.Control[iCurrent+2]=this.tabpage_2
this.Control[iCurrent+3]=this.tabpage_3
this.Control[iCurrent+4]=this.tabpage_4
this.Control[iCurrent+5]=this.tabpage_6
this.Control[iCurrent+6]=this.tabpage_7
this.Control[iCurrent+7]=this.tabpage_8
this.Control[iCurrent+8]=this.tabpage_9
end on

on u_tab_gigp_summary.destroy
call super::destroy
destroy(this.tabpage_1)
destroy(this.tabpage_2)
destroy(this.tabpage_3)
destroy(this.tabpage_4)
destroy(this.tabpage_6)
destroy(this.tabpage_7)
destroy(this.tabpage_8)
destroy(this.tabpage_9)
end on

event selectionchanged;call super::selectionchanged;

//******************************************************
// Limit Menu Functionality:
//******************************************************

m_gigp_master	lm_Menu

lm_Menu = iw_Parent.MenuID

//******************************************************
// Customize Menu:
//******************************************************

If (newindex = 1) Then
	lm_Menu.m_view.m_gigplist.Visible = False
	lm_Menu.m_view.m_gigplist.ToolBarItemVisible = False

Else
	lm_Menu.m_view.m_gigplist.Visible = True
	lm_Menu.m_view.m_gigplist.ToolBarItemVisible = True

End If
end event

type tabpage_1 from u_tabpg_gigp_list within u_tab_gigp_summary
integer x = 18
integer y = 112
integer width = 2921
integer height = 2424
end type

type tabpage_2 from u_tabpg_application within u_tab_gigp_summary
integer x = 18
integer y = 112
integer width = 2921
integer height = 2424
end type

type tabpage_3 from u_tabpg_contacts within u_tab_gigp_summary
integer x = 18
integer y = 112
integer width = 2921
integer height = 2424
end type

type tabpage_4 from u_tabpg_worflow within u_tab_gigp_summary
integer x = 18
integer y = 112
integer width = 2921
integer height = 2424
end type

type tabpage_6 from u_tabpg_notes within u_tab_gigp_summary
integer x = 18
integer y = 112
integer width = 2921
integer height = 2424
end type

type tabpage_7 from u_tabpg_efc_agreement within u_tab_gigp_summary
integer x = 18
integer y = 112
integer width = 2921
integer height = 2424
end type

type tabpage_8 from u_tabpg_profess_contracts within u_tab_gigp_summary
integer x = 18
integer y = 112
integer width = 2921
integer height = 2424
end type

type tabpage_9 from u_tabpg_disbursements within u_tab_gigp_summary
integer x = 18
integer y = 112
integer width = 2921
integer height = 2424
end type

