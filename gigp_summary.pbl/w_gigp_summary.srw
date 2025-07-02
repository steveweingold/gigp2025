forward
global type w_gigp_summary from w_sheet_dbaccess
end type
type tab_1 from u_tab_gigp_summary within w_gigp_summary
end type
type tab_1 from u_tab_gigp_summary within w_gigp_summary
end type
end forward

global type w_gigp_summary from w_sheet_dbaccess
string tag = "Small Grants Summary"
integer width = 3035
integer height = 2968
string title = "Small Grants Summary"
string menuname = "m_gigp_sheet"
boolean hscrollbar = true
integer ii_orig_width = 0
integer ii_orig_height = 0
event ue_goto_list ( )
event ue_postit ( )
event ue_call_log ( )
event ue_postit_disbursements ( )
tab_1 tab_1
end type
global w_gigp_summary w_gigp_summary

type variables

w_postit iw_posit
end variables

forward prototypes
public subroutine of_test (string as_test)
public subroutine of_test (string as_test[])
public subroutine of_set_title (string as_title)
end prototypes

event ue_goto_list();

it_Tab.selectTab(1)
end event

event ue_postit();If IsValid(iw_posit) Then
	iw_posit.Event ue_retrieve('POSIT,INELIGIBILITY')
Else	
	Open(iw_posit, This)
	iw_posit.Event ue_retrieve('POSIT,INELIGIBILITY')
End If
end event

event ue_call_log();tab_1.Event ue_call_log()
end event

event ue_postit_disbursements();If IsValid(iw_posit) Then
	iw_posit.Event ue_retrieve('POSITDISB')
Else	
	Open(iw_posit, This)
	iw_posit.Event ue_retrieve('POSITDISB')
End If
end event

public subroutine of_test (string as_test);

return
end subroutine

public subroutine of_test (string as_test[]);

return
end subroutine

public subroutine of_set_title (string as_title);
This.Title = as_title
end subroutine

on w_gigp_summary.create
int iCurrent
call super::create
if this.MenuName = "m_gigp_sheet" then this.MenuID = create m_gigp_sheet
this.tab_1=create tab_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tab_1
end on

on w_gigp_summary.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.tab_1)
end on

event ue_setorigsize;call super::ue_setorigsize;
 ii_Orig_Width  = (2999 - 28)
 ii_Orig_Height = (2724 - 150)
end event

event open;call super::open;
Integer		li_Count, li_Index

u_tabpg_gigp_list				ltp_1
u_tabpg_application			ltp_2
u_tabpg_contacts				ltp_3
u_tabpg_efc_agreement		ltp_6
u_tabpg_disbursements		ltp_8


This.Event Post ue_postit()


//*************************************************************
// GIGP Application Listing:
//*************************************************************

ltp_1 = it_Tab.itp_Array[1]


//*************************************************************
// GIGP Application Details:
//*************************************************************

ltp_2 = it_Tab.itp_Array[2]

this.inv_resize.of_UnRegister(ltp_2.dw_1)


this.inv_resize.of_Register(ltp_2.dw_1,"ScaleToRight") 
this.inv_resize.of_Register(ltp_2.tab_2,"ScaleToRight&Bottom")


// Loop through application sub-tabpages and resize:

li_Count = UpperBound(ltp_2.tab_2.itp_Array)

FOR li_Index = 1 TO li_Count
	this.inv_resize.of_Register(ltp_2.tab_2.itp_Array[li_Index].dw_1,"ScaleToRight&Bottom")
NEXT


//*************************************************************
// GIGP Contacts:
//*************************************************************

ltp_3 = it_Tab.itp_Array[3]

this.inv_resize.of_UnRegister(ltp_3.dw_1)
this.inv_resize.of_Register(ltp_3.dw_1,"ScaleToRight") 

//this.inv_resize.of_Register(ltp_3.dw_3,"FixedToRight&ScaleToBottom") 
this.inv_resize.of_Register(ltp_3.dw_3,"ScaleToBottom") 


this.inv_resize.of_Register(ltp_3.dw_2,"ScaleToRight&Bottom")

//*************************************************************
// Agreement:
//*************************************************************

ltp_6 = it_Tab.itp_Array[6]

this.inv_resize.of_UnRegister(ltp_6.dw_1)


this.inv_resize.of_Register(ltp_6.dw_1,"ScaleToRight") 
this.inv_resize.of_Register(ltp_6.tab_1,"ScaleToRight&Bottom")


// Loop through application sub-tabpages and resize:

li_Count = UpperBound(ltp_6.tab_1.itp_Array)

FOR li_Index = 1 TO li_Count
	this.inv_resize.of_Register(ltp_6.tab_1.itp_Array[li_Index].dw_1,"ScaleToRight&Bottom")
NEXT

//*************************************************************
// GIGP Disbursements:
//*************************************************************

ltp_8 = it_Tab.itp_Array[8]

this.inv_resize.of_UnRegister(ltp_8.dw_1)
this.inv_resize.of_Register(ltp_8.dw_1,"ScaleToRight") 
this.inv_resize.of_Register(ltp_8.dw_2,"ScaleToRight&Bottom")

//Make system tools visible for developers
m_gigp_sheet	lm_Menu
lm_Menu = this.MenuID

If Upper(gnv_app.of_getuserid()) = 'WEINGOLD' or Upper(gnv_app.of_getuserid()) = 'FISHER' or Upper(gnv_app.of_getuserid()) = 'HOLDEN' Then
	lm_Menu.m_systemtools.visible = True
Else
	lm_Menu.m_systemtools.visible = False
End If
end event

event close;call super::close;
If IsValid(iw_posit) Then Close(iw_posit)

m_gigp_master lm_Menu

lm_Menu = This.MenuID

lm_Menu.m_tools.m_postit.Visible = False		
lm_Menu.m_tools.m_postit.ToolBarItemVisible = False

end event

event pfc_preopen;call super::pfc_preopen;m_gigp_master lm_Menu

lm_Menu = This.MenuID

lm_Menu.m_tools.m_postit.Visible = True
lm_Menu.m_tools.m_postit.ToolBarItemVisible = True
end event

type tab_1 from u_tab_gigp_summary within w_gigp_summary
integer x = 23
integer y = 32
integer width = 2949
integer height = 2548
integer taborder = 10
end type

