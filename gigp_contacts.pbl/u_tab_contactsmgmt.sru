forward
global type u_tab_contactsmgmt from u_tab_dbaccess
end type
type tabpage_1 from u_tabpg_contactmgmt_detail within u_tab_contactsmgmt
end type
type tabpage_1 from u_tabpg_contactmgmt_detail within u_tab_contactsmgmt
end type
type tabpage_2 from u_tabpg_contactmgmt_links within u_tab_contactsmgmt
end type
type tabpage_2 from u_tabpg_contactmgmt_links within u_tab_contactsmgmt
end type
type tabpage_4 from u_tabpg_contactmgmt_politdistricts within u_tab_contactsmgmt
end type
type tabpage_4 from u_tabpg_contactmgmt_politdistricts within u_tab_contactsmgmt
end type
end forward

global type u_tab_contactsmgmt from u_tab_dbaccess
boolean showpicture = true
boolean ib_forcesave = false
tabpage_1 tabpage_1
tabpage_2 tabpage_2
tabpage_4 tabpage_4
end type
global u_tab_contactsmgmt u_tab_contactsmgmt

on u_tab_contactsmgmt.create
this.tabpage_1=create tabpage_1
this.tabpage_2=create tabpage_2
this.tabpage_4=create tabpage_4
int iCurrent
call super::create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tabpage_1
this.Control[iCurrent+2]=this.tabpage_2
this.Control[iCurrent+3]=this.tabpage_4
end on

on u_tab_contactsmgmt.destroy
call super::destroy
destroy(this.tabpage_1)
destroy(this.tabpage_2)
destroy(this.tabpage_4)
end on

event selectionchanging;
//OverRide//

//PFC Linkage Service manages Retrieve

end event

type tabpage_1 from u_tabpg_contactmgmt_detail within u_tab_contactsmgmt
integer x = 18
integer y = 112
integer width = 2830
integer height = 1172
end type

type tabpage_2 from u_tabpg_contactmgmt_links within u_tab_contactsmgmt
integer x = 18
integer y = 112
integer width = 2830
integer height = 1172
string text = "Contact Links"
end type

type tabpage_4 from u_tabpg_contactmgmt_politdistricts within u_tab_contactsmgmt
integer x = 18
integer y = 112
integer width = 2830
integer height = 1172
end type

