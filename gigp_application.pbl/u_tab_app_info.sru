forward
global type u_tab_app_info from u_tab_dbaccess
end type
type tabpage_1 from u_tabpg_projlocation within u_tab_app_info
end type
type tabpage_1 from u_tabpg_projlocation within u_tab_app_info
end type
type tabpage_2 from u_tabpg_projdescription within u_tab_app_info
end type
type tabpage_2 from u_tabpg_projdescription within u_tab_app_info
end type
type tabpage_3 from u_tabpg_projmetricinfo within u_tab_app_info
end type
type tabpage_3 from u_tabpg_projmetricinfo within u_tab_app_info
end type
type tabpage_5 from u_tabpg_projbudget within u_tab_app_info
end type
type tabpage_5 from u_tabpg_projbudget within u_tab_app_info
end type
type tabpage_6 from u_tabpg_projfunding within u_tab_app_info
end type
type tabpage_6 from u_tabpg_projfunding within u_tab_app_info
end type
type tabpage_7 from u_tabpg_projsummaries within u_tab_app_info
end type
type tabpage_7 from u_tabpg_projsummaries within u_tab_app_info
end type
type tabpage_8 from u_tabpg_projgenchecklist within u_tab_app_info
end type
type tabpage_8 from u_tabpg_projgenchecklist within u_tab_app_info
end type
type tabpage_9 from u_tabpg_projcfa within u_tab_app_info
end type
type tabpage_9 from u_tabpg_projcfa within u_tab_app_info
end type
end forward

global type u_tab_app_info from u_tab_dbaccess
integer width = 2889
integer height = 1348
boolean fixedwidth = true
boolean showpicture = true
tabpage_1 tabpage_1
tabpage_2 tabpage_2
tabpage_3 tabpage_3
tabpage_5 tabpage_5
tabpage_6 tabpage_6
tabpage_7 tabpage_7
tabpage_8 tabpage_8
tabpage_9 tabpage_9
end type
global u_tab_app_info u_tab_app_info

on u_tab_app_info.create
this.tabpage_1=create tabpage_1
this.tabpage_2=create tabpage_2
this.tabpage_3=create tabpage_3
this.tabpage_5=create tabpage_5
this.tabpage_6=create tabpage_6
this.tabpage_7=create tabpage_7
this.tabpage_8=create tabpage_8
this.tabpage_9=create tabpage_9
call super::create
this.Control[]={this.tabpage_1,&
this.tabpage_2,&
this.tabpage_3,&
this.tabpage_5,&
this.tabpage_6,&
this.tabpage_7,&
this.tabpage_8,&
this.tabpage_9}
end on

on u_tab_app_info.destroy
call super::destroy
destroy(this.tabpage_1)
destroy(this.tabpage_2)
destroy(this.tabpage_3)
destroy(this.tabpage_5)
destroy(this.tabpage_6)
destroy(this.tabpage_7)
destroy(this.tabpage_8)
destroy(this.tabpage_9)
end on

event selectionchanging;//OverRide//

// Prompt user to save changes before changing tab pages.					//
// You can turn off this behaviour by setting this.ib_ForceSave False.	//

int							li_RC, li_Answer
powerobject			lpo_Updates[]

IF ib_ForceSave THEN
	SetPointer(HourGlass!)
	
	IF oldindex > 0 THEN
		// Accepttect on all dw's on the tabpage we are leaving.	//
		li_RC = This.Event pfc_accepttext(This.itp_Array[oldindex].control,True)
		
		IF li_RC = -1 THEN
			Return 1
		END IF
	
		// Check the tabpage we are leaving for pending updates.	//
		
		li_RC = This.Event pfc_UpdatesPending(This.itp_Array[oldindex].control,lpo_Updates) 
	
		//////////////////////////////////////////////////
		//	 1 = updates are pending (no errors found)	//
		//	 0 = No updates pending (no errors found)		//
		//	-1 = error												//
		//////////////////////////////////////////////////
	
		CHOOSE CASE li_RC
		CASE is < 0
			Return 1
		CASE is > 0
			iw_parent.BringToTop = True

			li_Answer = MessageBox(itp_Array[oldindex].Tag,"Save Changes?",Question!,YesNoCancel!,1)
	
			CHOOSE CASE li_Answer
			CASE 1
				// If the save fails, don't change tabpages.	//
				
				IF iw_Parent.Event pfc_Save() < 0 THEN			
					Return 1
				END IF

			CASE 2
				// Re-retrieve old tabpage to erase changes.	//
				itp_Array[oldindex].ib_Retrieved = False

				// If they are equal, code below will post of_Display().	//
				IF oldindex <> newindex THEN
					itp_Array[oldindex].Function Post of_Display()
				END IF

			// If the user cancels, don't change tabpages.	//
			CASE 3
				Return 1
			END CHOOSE
		CASE 0
		END CHOOSE
	END IF
END IF

IF IsValid(itp_Array[newindex]) THEN
	// of_Display will perform a retrieve if neccesary.	//
	itp_Array[newindex].Function Post of_Display()
END IF

Return 0

end event

event constructor;//OverRide//

u_tab_dbaccess         lt_parent
u_tabpg_dbaccess 	ltp_parent

ltp_parent = This.GetParent()

ltp_parent.of_get_it_parent(lt_parent)

iw_Parent = lt_parent.iw_parent



end event

event selectionchanged;call super::selectionchanged;long ll_cfa
string ls_program

//Hide CFA Tab if no CFA number
Select cfa_no
into :ll_cfa
from gigp_application
where gigp_id = :gl_gigp_id;

If IsNull(ll_cfa) or ll_cfa <= 0 Then
	this.tabpage_9.Visible = False
Else
	this.tabpage_9.Visible = True
End IF


//disable tabs for EPG
select program
into :ls_program
from gigp_application
where gigp_id = :gl_gigp_id;

Choose Case ls_program
	Case 'EPG', 'PPG-EC'
		this.tabpage_2.Enabled = False
		this.tabpage_3.Enabled = False
		this.tabpage_5.Enabled = False
		this.tabpage_8.Enabled = False
	
	Case Else
		this.tabpage_2.Enabled = True
		this.tabpage_3.Enabled = True
		this.tabpage_5.Enabled = True
		this.tabpage_8.Enabled = True

End Choose
end event

type tabpage_1 from u_tabpg_projlocation within u_tab_app_info
integer x = 18
integer y = 112
integer width = 2853
integer height = 1220
end type

type tabpage_2 from u_tabpg_projdescription within u_tab_app_info
integer x = 18
integer y = 112
integer width = 2853
integer height = 1220
end type

type tabpage_3 from u_tabpg_projmetricinfo within u_tab_app_info
integer x = 18
integer y = 112
integer width = 2853
integer height = 1220
end type

type tabpage_5 from u_tabpg_projbudget within u_tab_app_info
integer x = 18
integer y = 112
integer width = 2853
integer height = 1220
end type

type tabpage_6 from u_tabpg_projfunding within u_tab_app_info
integer x = 18
integer y = 112
integer width = 2853
integer height = 1220
end type

type tabpage_7 from u_tabpg_projsummaries within u_tab_app_info
integer x = 18
integer y = 112
integer width = 2853
integer height = 1220
end type

type tabpage_8 from u_tabpg_projgenchecklist within u_tab_app_info
integer x = 18
integer y = 112
integer width = 2853
integer height = 1220
end type

type tabpage_9 from u_tabpg_projcfa within u_tab_app_info
integer x = 18
integer y = 112
integer width = 2853
integer height = 1220
end type

