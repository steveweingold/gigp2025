forward
global type u_tab_efc_agreement_details from u_tab_dbaccess
end type
type tabpage_1 from u_tabpg_efc_contract_dates within u_tab_efc_agreement_details
end type
type tabpage_1 from u_tabpg_efc_contract_dates within u_tab_efc_agreement_details
end type
type tabpage_2 from u_tabpg_seqrinsur_info within u_tab_efc_agreement_details
end type
type tabpage_2 from u_tabpg_seqrinsur_info within u_tab_efc_agreement_details
end type
type tabpage_7 from u_tabpg_tas_items within u_tab_efc_agreement_details
end type
type tabpage_7 from u_tabpg_tas_items within u_tab_efc_agreement_details
end type
type tabpage_8 from u_tabpg_depm_items within u_tab_efc_agreement_details
end type
type tabpage_8 from u_tabpg_depm_items within u_tab_efc_agreement_details
end type
type tabpage_4 from u_tabpg_legal within u_tab_efc_agreement_details
end type
type tabpage_4 from u_tabpg_legal within u_tab_efc_agreement_details
end type
type tabpage_5 from u_tabpg_special_conditions within u_tab_efc_agreement_details
end type
type tabpage_5 from u_tabpg_special_conditions within u_tab_efc_agreement_details
end type
type tabpage_closeout from u_tabpg_closeout_items within u_tab_efc_agreement_details
end type
type tabpage_closeout from u_tabpg_closeout_items within u_tab_efc_agreement_details
end type
type tabpage_6 from u_tabpg_projepg within u_tab_efc_agreement_details
end type
type tabpage_6 from u_tabpg_projepg within u_tab_efc_agreement_details
end type
end forward

global type u_tab_efc_agreement_details from u_tab_dbaccess
integer width = 2889
integer height = 2164
boolean fixedwidth = true
boolean showpicture = true
tabpage_1 tabpage_1
tabpage_2 tabpage_2
tabpage_7 tabpage_7
tabpage_8 tabpage_8
tabpage_4 tabpage_4
tabpage_5 tabpage_5
tabpage_closeout tabpage_closeout
tabpage_6 tabpage_6
end type
global u_tab_efc_agreement_details u_tab_efc_agreement_details

on u_tab_efc_agreement_details.create
this.tabpage_1=create tabpage_1
this.tabpage_2=create tabpage_2
this.tabpage_7=create tabpage_7
this.tabpage_8=create tabpage_8
this.tabpage_4=create tabpage_4
this.tabpage_5=create tabpage_5
this.tabpage_closeout=create tabpage_closeout
this.tabpage_6=create tabpage_6
call super::create
this.Control[]={this.tabpage_1,&
this.tabpage_2,&
this.tabpage_7,&
this.tabpage_8,&
this.tabpage_4,&
this.tabpage_5,&
this.tabpage_closeout,&
this.tabpage_6}
end on

on u_tab_efc_agreement_details.destroy
call super::destroy
destroy(this.tabpage_1)
destroy(this.tabpage_2)
destroy(this.tabpage_7)
destroy(this.tabpage_8)
destroy(this.tabpage_4)
destroy(this.tabpage_5)
destroy(this.tabpage_closeout)
destroy(this.tabpage_6)
end on

event constructor;string ls_legal

//OverRide//

u_tab_dbaccess         lt_parent
u_tabpg_dbaccess 	ltp_parent

ltp_parent = This.GetParent()

ltp_parent.of_get_it_parent(lt_parent)

iw_Parent = lt_parent.iw_parent


end event

event selectionchanging;
//OverRide//

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

event selectionchanged;call super::selectionchanged;string ls_program

select program
into :ls_program
from gigp_application
where gigp_id = :gl_gigp_id;


Choose Case ls_program
	Case 'EPG', 'PPG-EC'
		this.Tabpage_6.Visible = True
		this.Tabpage_6.Enabled = True
		this.Tabpage_1.Enabled = True
			
		this.Tabpage_2.Enabled = False
		this.Tabpage_4.Enabled = False
		this.Tabpage_5.Enabled = False
		this.Tabpage_7.Enabled = False
		this.Tabpage_8.Enabled = False
	
	
	Case Else
		this.Tabpage_6.Visible = False
		this.Tabpage_6.Enabled = False
		
		this.Tabpage_1.Enabled = True
		this.Tabpage_2.Enabled = True
		this.Tabpage_4.Enabled = True
		this.Tabpage_5.Enabled = True
		this.Tabpage_7.Enabled = True
		this.Tabpage_8.Enabled = True

End Choose
end event

type tabpage_1 from u_tabpg_efc_contract_dates within u_tab_efc_agreement_details
integer x = 18
integer y = 112
integer width = 2853
integer height = 2036
end type

type tabpage_2 from u_tabpg_seqrinsur_info within u_tab_efc_agreement_details
integer x = 18
integer y = 112
integer width = 2853
integer height = 2036
end type

type tabpage_7 from u_tabpg_tas_items within u_tab_efc_agreement_details
integer x = 18
integer y = 112
integer width = 2853
integer height = 2036
end type

type tabpage_8 from u_tabpg_depm_items within u_tab_efc_agreement_details
integer x = 18
integer y = 112
integer width = 2853
integer height = 2036
end type

type tabpage_4 from u_tabpg_legal within u_tab_efc_agreement_details
integer x = 18
integer y = 112
integer width = 2853
integer height = 2036
end type

type tabpage_5 from u_tabpg_special_conditions within u_tab_efc_agreement_details
integer x = 18
integer y = 112
integer width = 2853
integer height = 2036
end type

type tabpage_closeout from u_tabpg_closeout_items within u_tab_efc_agreement_details
integer x = 18
integer y = 112
integer width = 2853
integer height = 2036
end type

type tabpage_6 from u_tabpg_projepg within u_tab_efc_agreement_details
string tag = "Planning Grants"
integer x = 18
integer y = 112
integer width = 2853
integer height = 2036
string text = "Planning Grants"
string picturename = "PictureListBox!"
string powertiptext = "Engineering Planning Grants"
end type

