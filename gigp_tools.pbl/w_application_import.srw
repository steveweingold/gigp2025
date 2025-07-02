forward
global type w_application_import from w_detail
end type
type shl_1 from statichyperlink within w_application_import
end type
type dw_appinfo from u_dw within w_application_import
end type
type dw_checklist from u_dw within w_application_import
end type
type dw_keydates from u_dw within w_application_import
end type
type dw_amounts from u_dw within w_application_import
end type
type dw_notes from u_dw within w_application_import
end type
type dw_contacts from u_dw within w_application_import
end type
type dw_contactlinks from u_dw within w_application_import
end type
type cb_import from commandbutton within w_application_import
end type
type dw_metrics from u_dw within w_application_import
end type
type cbx_applicant from checkbox within w_application_import
end type
type cbx_primary from checkbox within w_application_import
end type
type cbx_location from checkbox within w_application_import
end type
type cbx_engineer from checkbox within w_application_import
end type
type em_applicant from editmask within w_application_import
end type
type em_primary from editmask within w_application_import
end type
type em_location from editmask within w_application_import
end type
type em_engineer from editmask within w_application_import
end type
type cb_reset from commandbutton within w_application_import
end type
type st_1 from statictext within w_application_import
end type
type dw_politdistricts from u_dw within w_application_import
end type
type cb_errors from commandbutton within w_application_import
end type
type cb_new from commandbutton within w_application_import
end type
type st_2 from statictext within w_application_import
end type
end forward

global type w_application_import from w_detail
string tag = "GIGP Application Import "
integer height = 1560
string title = "GIGP Application Import (Round 2)"
string menuname = "m_gigp_sheet"
event ue_process ( )
shl_1 shl_1
dw_appinfo dw_appinfo
dw_checklist dw_checklist
dw_keydates dw_keydates
dw_amounts dw_amounts
dw_notes dw_notes
dw_contacts dw_contacts
dw_contactlinks dw_contactlinks
cb_import cb_import
dw_metrics dw_metrics
cbx_applicant cbx_applicant
cbx_primary cbx_primary
cbx_location cbx_location
cbx_engineer cbx_engineer
em_applicant em_applicant
em_primary em_primary
em_location em_location
em_engineer em_engineer
cb_reset cb_reset
st_1 st_1
dw_politdistricts dw_politdistricts
cb_errors cb_errors
cb_new cb_new
st_2 st_2
end type
global w_application_import w_application_import

type variables

m_gigp_sheet	im_Menu

long il_gigpID

String is_grantType, is_user, is_errMessage

Integer il_tempContactID, il_tempID

DateTime idt_today
end variables

forward prototypes
public subroutine of_create_checklist_entry (string as_refcode, string as_comment)
public subroutine of_create_note_entry (string as_category, string as_type, string as_comment)
public subroutine of_create_date_entry (string as_refcode, datetime adt_value, string as_dateind)
public subroutine of_create_amount_entry (string as_refcode, string as_subcategory, decimal ad_amount, string as_comment)
public subroutine of_create_contactlink_entry (long as_contactid, string as_contacttype)
public function boolean of_check_contact (long al_contactid)
protected subroutine of_create_contact_entry (string as_contacttype, string as_organization, string as_name, string as_title, string as_address, string as_munitype, string as_city, string as_state, string as_zip, string as_county, string as_phone, string as_fax, string as_email, string as_gislong, string as_gislat)
public subroutine of_reset_import (string as_type)
public subroutine of_create_metric_entry (string as_subcategory, string as_refcode, decimal ad_value)
public subroutine of_build_error_message ()
public subroutine of_prescanfile ()
public subroutine of_cleanse_text (ref string as_text)
public function integer of_create_politicaldistrict_entry (string as_districttype, string as_districtnos)
end prototypes

event ue_process();
Long 		ll_importCnt, ll_newRow, ll_tempContactID,ll_tempAmtID,  ll_value
Integer	li_checkValue, li_checkValue2, li_rc
String 	ls_value
String 	ls_org, ls_name, ls_title, ls_addr, ls_muniType, ls_city, ls_state, ls_zip, ls_phone, ls_fax, ls_email, ls_cnty, ls_usCon, ls_nyAsm, ls_nySen, ls_gisLong, ls_gisLat
Decimal	ld_value
DateTime ldt_value
pfc_n_cst_string lu_string

ll_importCnt = dw_detail.RowCount()

If (ll_importCnt <> 1) Then
	MessageBox("ERROR!", "Import file not found!")
	Return
End If

If (cbx_applicant.Checked = False) Then
	
	ll_value = Long(em_applicant.Text)	
	
	If (of_check_contact(ll_value) = False) Then
		MessageBox("ERROR!", "Contact ID for Applicant not found!")
		Return
	End If

End If

If (cbx_primary.Checked = False) Then
	
	ll_value = Long(em_primary.Text)	
	
	If (of_check_contact(ll_value) = False) Then
		MessageBox("ERROR!", "Contact ID for Primary not found!")
		Return
	End If

End If

If (cbx_location.Checked = False) Then
	
	ll_value = Long(em_location.Text)	
	
	If (of_check_contact(ll_value) = False) Then
		MessageBox("ERROR!", "Contact ID for Location not found!")
		Return
	End If

End If

If (cbx_engineer.Checked = False) Then
	
	ll_value = Long(em_engineer.Text)	
	
	If (of_check_contact(ll_value) = False) Then
		MessageBox("ERROR!", "Contact ID for Engineer not found!")
		Return
	End If

End If

//*************************************************************
// Prep Application row:
//*************************************************************

dw_appinfo.InsertRow(0)
dw_appinfo.SetItem(1, "srf_program", "CW")

//*************************************************************
// CWSRF, Applicant, GPR Eligible Checklist Items:
//*************************************************************

li_checkValue = dw_detail.GetItemNumber (1, "proj_elig_cwsrf")

If (li_checkValue = 1) Then	
	of_create_checklist_entry("PROJCWSRFELIG", "")	
	li_checkValue = 0
End If

li_checkValue = dw_detail.GetItemNumber (1, "app_elig_cwssrf")

If (li_checkValue = 1) Then
	of_create_checklist_entry("APPLNTCWSRFELIG", "")	
	li_checkValue = 0
End If

li_checkValue = dw_detail.GetItemNumber (1, "proj_elig_gpr")

If (li_checkValue = 1) Then
	ls_value = Trim(dw_detail.GetItemString (1, "gpr_citation"))
	of_create_checklist_entry("GPRELIG",ls_value)	
	li_checkValue = 0
	ls_value = ""
End If

//*************************************************************
// Grant Type:
//*************************************************************

li_checkValue = dw_detail.GetItemNumber (1, "granttype_construct_flag")
li_checkValue2 = dw_detail.GetItemNumber (1, "granttype_design_flag")

If (li_checkValue =  li_checkValue2) Then
	
	//ERROR - Grant Type was not selected
	
	is_grantType = "ERROR"
Else
	
	If (li_checkValue = 1) Then
		ls_value = "Construction"
	Else
		ls_value = "Design"
	End If
		
	is_grantType = ls_value	
		
	dw_appinfo.SetItem(1,"grant_type", ls_value)	
	
End If

li_checkValue = 0
li_checkValue2 = 0
ls_value = ""	

//*************************************************************
// Applicant Info
//*************************************************************

If (cbx_applicant.Checked = True) Then

	ls_org			= Trim(dw_detail.GetItemString (1, "app_name"))
	ls_addr 		= Trim(dw_detail.GetItemString (1, "app_address1"))
	ls_muniType	= Trim(dw_detail.GetItemString (1, "app_muni_type"))
	ls_city 		= Trim(dw_detail.GetItemString (1, "app_city"))
	ls_state 		= "NY"
	ls_zip 			= Trim(dw_detail.GetItemString (1, "app_zip"))
	ls_cnty 		= Trim(dw_detail.GetItemString (1, "app_county"))
	
	of_create_contact_entry("APP", ls_org, ls_name, ls_title, ls_addr, ls_muniType, ls_city, ls_state, ls_zip, ls_cnty, ls_phone, ls_fax, ls_email, ls_gisLong, ls_gisLat)
	
	ls_org			= ""
	ls_addr 		= ""
	ls_muniType	= ""
	ls_city 		= ""
	ls_state 		= ""
	ls_zip 			= ""
	ls_cnty 		= ""
	
Else
	
	ll_value = Long(em_applicant.Text)	
	il_tempContactID = ll_value
	of_create_contactlink_entry(ll_value, "APP")
	ll_value = 0

End If

//*************************************************************
// Primary Contact:
//*************************************************************

If (cbx_primary.Checked = True) Then

	ls_name		= Trim(dw_detail.GetItemString (1, "primary_name"))
	ls_title		= Trim(dw_detail.GetItemString (1, "primary_title"))
	ls_addr 		= Trim(dw_detail.GetItemString (1, "primary_address1"))
	ls_muniType	= Trim(dw_detail.GetItemString (1, "primary_muni_type"))
	ls_city 		= Trim(dw_detail.GetItemString (1, "primary_city"))
	ls_state 		= Trim(dw_detail.GetItemString (1, "primary_state"))
	ls_zip 			= Trim(dw_detail.GetItemString (1, "primary_zip"))
	ls_cnty 		= Trim(dw_detail.GetItemString (1, "primary_county"))
	ls_phone 	= Trim(dw_detail.GetItemString (1, "primary_phone"))
	ls_fax 		= Trim(dw_detail.GetItemString (1, "primary_fax"))
	ls_email 		= Trim(dw_detail.GetItemString (1, "primary_email"))
		
	of_create_contact_entry("PRC", ls_org, ls_name, ls_title, ls_addr, ls_muniType, ls_city, ls_state, ls_zip, ls_cnty, ls_phone, ls_fax, ls_email, ls_gisLong, ls_gisLat)
		
	ls_name		= ""
	ls_title		= ""
	ls_addr 		= ""
	ls_muniType	= ""
	ls_city 		= ""
	ls_state 		= ""
	ls_zip 			= ""
	ls_cnty 		= ""
	ls_phone 	= ""
	ls_fax 		= ""
	ls_email 		= ""
		
Else
	
	ll_value = Long(em_primary.Text)	
	il_tempContactID = ll_value
	of_create_contactlink_entry(ll_value, "PRC")
	ll_value = 0

End If

//*************************************************************
// Political Districts
//*************************************************************
	
ls_usCon 	= Trim(dw_detail.GetItemString (1, "app_congress"))	
If Not IsNull(ls_usCon) Then
	li_rc = of_create_politicaldistrict_entry("usCongress", ls_usCon)
	If (li_rc = -1) Then
		MessageBox("ERROR!", "Congressional Districts for Applicant are formatted incorrectly and cannot be imported!")
	End If
End If
	
ls_nySen		= Trim(dw_detail.GetItemString (1, "app_senate"))	
If Not IsNull(ls_nySen) Then 
	li_rc = of_create_politicaldistrict_entry("nysSenate", ls_nySen)	
	If (li_rc = -1) Then
		MessageBox("ERROR!", "NY Senate Districts for Applicant are formatted incorrectly and cannot be imported!")
	End If
End If

ls_nyAsm 	= Trim(dw_detail.GetItemString (1, "app_assembly"))	
If Not IsNull(ls_nyAsm) Then 
	li_rc =of_create_politicaldistrict_entry("nysAssembly", ls_nyAsm)		
	If (li_rc = -1) Then
		MessageBox("ERROR!", "NY AssemblyDistricts for Applicant are formatted incorrectly and cannot be imported!")
	End If
End If
	
li_rc 			= 0		
ls_usCon 	= ""
ls_nySen		= ""
ls_nyAsm 	= ""

ls_value = Trim(dw_detail.GetItemString (1, "app_fedid"))

If Not (IsNull(ls_value)) Then 
	ls_value = lu_string.of_globalreplace(ls_value, "-", "")
	dw_appinfo.SetItem(1, "federal_id_no", ls_value)
End If

ls_value = ""

//*********************
// Muni Type:
//*********************

li_checkValue = dw_detail.GetItemNumber (1, "app_muni_flag")

If (li_checkValue = 1) Then
	ls_value = "MUNI"
End If

li_checkValue = dw_detail.GetItemNumber (1, "app_nonmuni_flag")

If (li_checkValue = 1) Then
	ls_value = "NMUN"
End If

li_checkValue = dw_detail.GetItemNumber (1, "app_jointapp_flag")

If (li_checkValue = 1) Then
	ls_value = "JAPP"		
End If

dw_appinfo.SetItem(1, "applicant_type", ls_value)
ls_value = ""

ls_value = Trim(dw_detail.GetItemString (1, "app_nonmuni_type"))

dw_appinfo.SetItem(1, "typeof_applicant", ls_value)
ls_value = ""

li_checkValue = 0

//*************************************************************
// Project Location:
//*************************************************************

If (cbx_location.Checked = True) Then

	ls_addr 		= Trim(dw_detail.GetItemString (1, "proj_address1"))
	ls_muniType	= Trim(dw_detail.GetItemString (1, "proj_muni_type"))
	ls_city 		= Trim(dw_detail.GetItemString (1, "proj_city"))
	ls_state 		= "NY"
	ls_zip 			= Trim(dw_detail.GetItemString (1, "proj_zip"))
	ls_cnty 		= Trim(dw_detail.GetItemString (1, "proj_county"))
	ls_phone 	= Trim(dw_detail.GetItemString (1, "primary_phone"))
	ls_fax 		= Trim(dw_detail.GetItemString (1, "primary_fax"))
	ls_email 		= Trim(dw_detail.GetItemString (1, "primary_email"))	
	ls_gisLong 	= Trim(dw_detail.GetItemString (1, "proj_long"))
	ls_gisLat 		= Trim(dw_detail.GetItemString (1, "proj_lat"))
	
	of_create_contact_entry("PLC", ls_org, ls_name, ls_title, ls_addr, ls_muniType, ls_city, ls_state, ls_zip, ls_cnty, ls_phone, ls_fax, ls_email, ls_gisLong, ls_gisLat)
	
	ls_addr 		= ""
	ls_muniType	= ""
	ls_city 		= ""
	ls_state 		= ""
	ls_zip 			= ""
	ls_cnty 		= ""
	ls_phone 	= ""
	ls_fax 		= ""
	ls_email 		= ""	
	ls_gisLong 	= ""
	ls_gisLat 		= ""
	
Else
	
	ll_value = Long(em_location.Text)	
	il_tempContactID = ll_value
	of_create_contactlink_entry(ll_value, "PLC")
	ll_value = 0

End If

//*************************************************************
// Political Districts:
//*************************************************************
	
ls_usCon 	= Trim(dw_detail.GetItemString (1, "proj_congress"))
If Not IsNull(ls_usCon) Then 
	li_rc = of_create_politicaldistrict_entry("usCongress", ls_usCon)
	If (li_rc = -1) Then
		MessageBox("ERROR!", "Congressional Districts for the Project are formatted incorrectly and cannot be imported!")
	End If
End If

ls_nySen		= Trim(dw_detail.GetItemString (1, "proj_senate"))
If Not IsNull(ls_nySen) Then 
	li_rc = of_create_politicaldistrict_entry("nysSenate", ls_nySen)	
	If (li_rc = -1) Then
		MessageBox("ERROR!", "NY Senate Districts for the Project are formatted incorrectly and cannot be imported!")
	End If
End If

ls_nyAsm 	= Trim(dw_detail.GetItemString (1, "proj_assembly"))
If Not IsNull(ls_nyAsm) Then
	li_rc = of_create_politicaldistrict_entry("nysAssembly", ls_nyAsm)	
	If (li_rc = -1) Then
		MessageBox("ERROR!", "NY AssemblyDistricts for the Project are formatted incorrectly and cannot be imported!")
	End If
End If
 
li_rc 			= 0		 
ls_usCon 	= ""
ls_nySen		= ""
ls_nyAsm 	= ""

ls_value = Trim(dw_detail.GetItemString (1, "proj_name"))
dw_appinfo.SetItem(1, "project_name", ls_value)
ls_value = ""

ll_value = dw_detail.GetItemNumber (1, "proj_pop")
dw_appinfo.SetItem(1, "pop_count", ll_value)
SetNull(ll_value)

ls_value = dw_detail.GetItemString (1, "proj_popsource")
dw_appinfo.SetItem(1, "pop_source", ls_value)
ls_value = ""

//*********************
// Waterbodies:
//*********************

ls_value = Trim(dw_detail.GetItemString (1, "waterbodies"))

If (Len(ls_value) > 0) Then
	of_create_note_entry("appNote", "waterBodies", ls_value)	
End If

//*********************
// SPDES Permit No.:
//*********************

ls_value = Trim(dw_detail.GetItemString (1, "spedes_no"))

dw_appinfo.SetItem(1, "spdes_no", ls_value)
ls_value = ""

//*********************
// Metrics:
//*********************

li_checkValue = dw_detail.GetItemNumber (1, "watereff_flag")

If (li_checkValue = 1) Then
	of_create_checklist_entry("WERC", "")	
	li_checkValue = 0
End If

li_checkValue = dw_detail.GetItemNumber (1, "energyeff_flag")

If (li_checkValue = 1) Then
	of_create_checklist_entry("ENEFF", "")	
	li_checkValue = 0
End If

li_checkValue = dw_detail.GetItemNumber (1, "greeninfra_flag")

If (li_checkValue = 1) Then
	of_create_checklist_entry("GWWI", "")	
	li_checkValue = 0
End If

li_checkValue = dw_detail.GetItemNumber (1, "environinnov_flag")
ls_value = Trim(dw_detail.GetItemString (1, "environ_innovative_text"))

If (li_checkValue = 1) Then
	of_create_checklist_entry("ENVIN", ls_value)	
	li_checkValue = 0
	ls_value = ""
End If

//Gallons / Year Potable Water Saved

ld_value = Dec(Trim(dw_detail.GetItemString (1, "we_galperyrsaved")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Water Efficiency", "GALYEARH2OSAVE", ld_value)
	SetNull(ld_value)
End If

//Gallons / Year Reused

ld_value = Dec(Trim(dw_detail.GetItemString (1, "we_galperyrused")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Water Efficiency",  "GALYEARH2OREUSE", ld_value)
	SetNull(ld_value)
End If

//Million Gallons per Day of Wastewater Eliminated / Conserved

ld_value = Dec(Trim(dw_detail.GetItemString (1, "we_galperdayconserv")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Water Efficiency",  "MILGALDAYELIM", ld_value)
	SetNull(ld_value)
End If

//Kilowatt hours / Year Saved

ld_value = Dec(Trim(dw_detail.GetItemString (1, "ee_kwhsaved")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Energy Efficiency",  "KILHRYEARSAVED", ld_value)
	SetNull(ld_value)
End If

//Kilowatt hours / Year Produced

ld_value = Dec(Trim(dw_detail.GetItemString (1, "ee_kwhproduced")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Energy Efficiency",  "KILHRYEARPROD", ld_value)
	SetNull(ld_value)
End If

//Gallons / Year Fuel Oil or Natural Gas Saved

ld_value = Dec(Trim(dw_detail.GetItemString (1, "ee_galfuelsaved")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Energy Efficiency",  "GALYEARFUELSAVED", ld_value)
	SetNull(ld_value)
End If

//Tons / Year Sediment

ld_value = Dec(Trim(dw_detail.GetItemString (1, "gi_tonsediment")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Green Infrastructure",  "TONSYEARSEDIMENT", ld_value)
	SetNull(ld_value)
End If

//Lbs / Year Road Salt

ld_value = Dec(Trim(dw_detail.GetItemString (1, "gi_lbsroadsalt")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Green Infrastructure",  "LBSYEARROADSALT", ld_value)
	SetNull(ld_value)
End If

//Lbs / Year Road Phosphorous

ld_value = Dec(Trim(dw_detail.GetItemString (1, "gi_lbsphosph")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Green Infrastructure",  "LBSYEARROADPHOS", ld_value)
	SetNull(ld_value)
End If

//Lbs / Year Road Nitrogen

ld_value = Dec(Trim(dw_detail.GetItemString (1, "gi_nitrogen")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Green Infrastructure",  "LBSYEARROADNITR", ld_value)
	SetNull(ld_value)
End If

//Planned acres of wetlands restored

ld_value = Dec(Trim(dw_detail.GetItemString (1, "gi_acrerestored")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Green Infrastructure",  "PLANACREWETRESTORE", ld_value)
	SetNull(ld_value)
End If

//Planned acres of wetlands created

ld_value = Dec(Trim(dw_detail.GetItemString (1, "gi_acrecreated")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Green Infrastructure",  "PLANACREWETCREATED", ld_value)
	SetNull(ld_value)
End If

//Planned linear feet of streambank/shoreline protected

ld_value = Dec(Trim(dw_detail.GetItemString (1, "gi_feetprotected")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Green Infrastructure",  "PLANFEETSHOREPROTECT", ld_value)
	SetNull(ld_value)
End If

//Planned linear feet of stream channel stabilized

ld_value = Dec(Trim(dw_detail.GetItemString (1, "gi_feetstailized")))

If  (ld_value > 0) Then
	of_create_metric_entry( "Green Infrastructure",  "PLANFEETSTREAMSTABILZ", ld_value)
	SetNull(ld_value)
End If

//************************************************************************************************

//Additional Water Quality Benefits

ls_value = Trim(dw_detail.GetItemString (1, "addit_waterqual_benefits"))

If (Len(ls_value) > 0) Then
	of_create_note_entry("appNote", "additWaterQualBen", ls_value)	
	ls_value = ""
End If

//Business Case

li_checkValue = dw_detail.GetItemNumber (1, "buscase_yes_flag")

If (li_checkValue = 1) Then
	of_create_checklist_entry("PRBC", "")	
	li_checkValue = 0
End If

//Executive Summary

ls_value = Trim(dw_detail.GetItemString (1, "parte_1_execsum"))

If (Len(ls_value) > 0) Then
	of_create_note_entry("appNote", "projDescription", ls_value)	
	ls_value = ""
End If

//Project will Spur Green Innovation

ls_value = Trim(dw_detail.GetItemString (1, "parte_2_spur"))

If (Len(ls_value) > 0) Then
	of_create_note_entry("appNote", "spurGreenInnov", ls_value)	
	ls_value = ""
End If

//Project will build Green Capacity

ls_value = Trim(dw_detail.GetItemString (1, "parte_3_buildgreen"))

If (Len(ls_value) > 0) Then
	of_create_note_entry("appNote", "buildGreenCapacty", ls_value)	
	ls_value = ""
End If

//Facilitate Green Technology Transfer

ls_value = Trim(dw_detail.GetItemString (1, "parte_4_techtransfer"))

If (Len(ls_value) > 0) Then
	of_create_note_entry("appNote", "facilGreenTechTranfr", ls_value)	 		
	ls_value = ""
End If

//Outreach and Educational Opportunities

ls_value = Trim(dw_detail.GetItemString (1, "parte_5_outreach"))

If (Len(ls_value) > 0) Then
	of_create_note_entry("appNote", "outrchEdOpportunty", ls_value)	 		
	ls_value = ""	
End If

//Long-Term Operation and Maintenance

ls_value = Trim(dw_detail.GetItemString (1, "parte_6a_operation"))

If (Len(ls_value) > 0) Then
	of_create_note_entry("appNote", "ltOperationMaint", ls_value)	 		
	ls_value = ""		
End If

//Address Repair or Replacement

ls_value = Trim(dw_detail.GetItemString (1, "parte_6b_repair"))

If (Len(ls_value) > 0) Then
	of_create_note_entry("appNote", "addrRepairReplace", ls_value)	 		
	ls_value = ""	
End If

//Leverages Co-Funding

li_checkValue = dw_detail.GetItemNumber (1, "parte_7leverage_flag")

If (li_checkValue = 1) Then
	of_create_checklist_entry("LEVECOFUNDING", "")	
	li_checkValue = 0
End If

//Green-up existing infrastructure

li_checkValue = dw_detail.GetItemNumber (1, "parte_7greenup_flag")

If (li_checkValue = 1) Then
	of_create_checklist_entry("GREENUPINFRA", "")	
	li_checkValue = 0
End If

//Supports community revitalization

li_checkValue = dw_detail.GetItemNumber (1, "parte_7commrevit_flag")

If (li_checkValue = 1) Then
	of_create_checklist_entry("SUPPCOMMREVITLZ", "")	
	li_checkValue = 0
End If

//Land recycling / retrofit / infill

li_checkValue = dw_detail.GetItemNumber (1, "parte_7land_flag")

If (li_checkValue = 1) Then
	of_create_checklist_entry("LANDRECYCLE", "")	
	li_checkValue = 0
End If

//Improve air quality

li_checkValue = dw_detail.GetItemNumber (1, "parte_7improves_flag")

If (li_checkValue = 1) Then
	of_create_checklist_entry("IMPROVEAIRQUAL", "")	
	li_checkValue = 0
End If

//Reduces dependence on oil

li_checkValue = dw_detail.GetItemNumber (1, "parte_7oil_flag")

If (li_checkValue = 1) Then
	of_create_checklist_entry("REDUCEDEPENDOIL", "")	
	li_checkValue = 0
End If

//Supports economic development

li_checkValue = dw_detail.GetItemNumber (1, "parte_7eddevelop_flag")

If (li_checkValue = 1)  Then
	of_create_checklist_entry("SUPPECONOMDEV", "")	
	li_checkValue = 0
End If

//Other

li_checkValue = dw_detail.GetItemNumber (1, "parte_7other_flag")
ls_value = Trim(dw_detail.GetItemString (1, "parte_7other_text"))

If (li_checkValue = 1) Then
	of_create_checklist_entry("OTHER", ls_value)	
	li_checkValue = 0
	ls_value = ""
End If

//*************************************************************
// PROJECT SCEDULE:
//*************************************************************

If (is_grantType = "Construction") Then
	
	//Engineering Report Completed
	
	ldt_value = dw_detail.GetItemdateTime(1, "cg_compl_engrpt_dt") 
	
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("PPERC", ldt_value, "Actual")
			SetNull(ldt_value)
	End If	
	
	//Conceptual Site Plan Completed
	
	ldt_value = dw_detail.GetItemdateTime(1, "cg_compl_conceptplan_dt") 
	
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("PCSPC", ldt_value, "Actual")
			SetNull(ldt_value)
	End If	
	
	//Feasibility Study Completed
	
	ldt_value = dw_detail.GetItemdateTime(1, "cg_compl_feasstudy_dt") 
	
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("PFSC", ldt_value, "Actual")
			SetNull(ldt_value)
	End If	
		
	//Project Plans and Specs
	
	ldt_value = dw_detail.GetItemdateTime(1, "cg_approvalfinalplans_dt") 
	
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("AAFPS", ldt_value, "")
			SetNull(ldt_value)		
	End If	
		
	//Award Bids
	
	ldt_value = dw_detail.GetItemdateTime(1, "cg_issuenotaward_dt") 
	ls_value = Trim(dw_detail.GetItemString (1, "constr_noticeawarddate"))
		
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("AWDBD", ldt_value, ls_value)
			SetNull(ldt_value)	
			ls_value = ""
	End If	
		
	//Notice To Proceed
	
	ldt_value = dw_detail.GetItemdateTime(1, "cg_issuenottoproceed_dt") 
	ls_value = Trim(dw_detail.GetItemString (1, "constr_noticeproceeddate"))
	
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("INPRD", ldt_value, ls_value)
			SetNull(ldt_value)	
			ls_value = ""
	End If	
		
	//Construction Commencement Date
	
	ldt_value = dw_detail.GetItemdateTime(1, "cg_constrcommence_dt") 
	ls_value = Trim(dw_detail.GetItemString (1, "constr_commencedate"))
	
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("CCMDT", ldt_value, ls_value)
			SetNull(ldt_value)	
			ls_value = ""
	End If		
		
	//Construction Completion Date
	
	ldt_value = dw_detail.GetItemdateTime(1, "cg_constrcomplete_dt") 
	ls_value = Trim(dw_detail.GetItemString (1, "constr_completedate"))
		
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("CCPDT", ldt_value, ls_value)
			SetNull(ldt_value)	
			ls_value = ""
	End If	
	
ElseIf (is_grantType = "Design") Then
	
	//Conceptual Site Plan Completed
	
	ldt_value = dw_detail.GetItemdateTime(1, "dg_siteplancomplete_dt") 
	
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("PCSPC", ldt_value, "Actual")
			SetNull(ldt_value)
	End If	
	
	//Feasibility Study Completed
	
	ldt_value = dw_detail.GetItemdateTime(1, "dg_feasstiducomplete_dt") 
	
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("PFSC", ldt_value, "Actual")
			SetNull(ldt_value)
	End If	
			
	//Project Plans and Specs
	
	ldt_value = dw_detail.GetItemdateTime(1, "dg_apprfinalplans_dt") 
	
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("AAFPS", ldt_value, "Target")
			SetNull(ldt_value)
	End If	
	
	//Award Bids
	
	ldt_value = dw_detail.GetItemdateTime(1, "dg_issuenotaward_dt") 

	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("AWDBD", ldt_value, "Target")
			SetNull(ldt_value)
	End If	

	//Notice To Proceed
	
	ldt_value = dw_detail.GetItemdateTime(1, "dg_issuenotproeceed_dt") 
		
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("INPRD", ldt_value, "Target")
			SetNull(ldt_value)
	End If	
		
	//Construction Commencement Date
	
	ldt_value = dw_detail.GetItemdateTime(1, "dg_constrcommence_dt") 
		
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("CCMDT", ldt_value, "Target")
			SetNull(ldt_value)
	End If	
	
	//Construction Completion Date
	
	ldt_value = dw_detail.GetItemdateTime(1, "dg_constrcomplete_dt") 
		
	If Not (IsNull(ldt_value)) Then
			of_create_date_entry("CCPDT", ldt_value, "Target")
			SetNull(ldt_value)
	End If	
	
End If

//*************************************************************
// Engineering Contact:
//*************************************************************

If (cbx_engineer.Checked = True) Then

	ls_org			= Trim(dw_detail.GetItemString (1, "ec_firmname"))
	ls_name		= Trim(dw_detail.GetItemString (1, "cc_eng_name"))
	ls_title		= Trim(dw_detail.GetItemString (1, "ec_title"))
	ls_addr 		= Trim(dw_detail.GetItemString (1, "ec_address1"))
	ls_muniType	= Trim(dw_detail.GetItemString (1, "ec_muni_type"))
	ls_city 		= Trim(dw_detail.GetItemString (1, "ec_city"))
	ls_state 		= Trim(dw_detail.GetItemString (1, "ec_state"))
	ls_zip 			= Trim(dw_detail.GetItemString (1, "ec_zip"))
	ls_phone 	= Trim(dw_detail.GetItemString (1, "ec_phone"))
	ls_fax 		= Trim(dw_detail.GetItemString (1, "ec_fax"))
	ls_email 		= Trim(dw_detail.GetItemString (1, "ec_email"))
	
	of_create_contact_entry("CEC", ls_org, ls_name, ls_title, ls_addr, ls_muniType, ls_city, ls_state, ls_zip, ls_cnty, ls_phone, ls_fax, ls_email, ls_gisLong, ls_gisLat)
	
	ls_org			= ""
	ls_name   	= ""
	ls_title		= ""
	ls_addr 		= ""
	ls_muniType	= ""
	ls_city 		= ""
	ls_state 		= ""
	ls_zip 			= ""
	ls_phone 	= ""
	ls_fax 		= ""
	ls_email 		= ""
	
Else
	
	ll_value = Long(em_engineer.Text)	
	il_tempContactID = ll_value
	of_create_contactlink_entry(ll_value, "CEC")
	ll_value = 0

End If

//*************************************************************
// Project Budget:
//*************************************************************

//Total Construction Costs

ll_tempAmtID++

ld_value = dw_detail.GetItemDecimal(1, 'pb_total_constrcosts')
of_create_amount_entry("TCC", "Construction", ld_value, "")
ld_value = 0

//Engineering - Planning

ld_value = dw_detail.GetItemDecimal(1, 'pb_planningcosts')
of_create_amount_entry("PLN", "Engineering", ld_value, "")
ld_value = 0

//Engineering - Design

ld_value = dw_detail.GetItemDecimal(1, 'pb_designcosts')
of_create_amount_entry("DES", "Engineering", ld_value, "")
ld_value = 0

//Engineering - Other

ld_value = dw_detail.GetItemDecimal(1, 'pb_othercosts')
ls_value = Trim(dw_detail.getItemString(1, 'cg_othercosts_text'))
of_create_amount_entry("OTH", "Engineering", ld_value, ls_value)
ld_value = 0
ls_value = ""

//Administrative Consulting Svc.

ld_value = dw_detail.GetItemDecimal(1, 'pb_consulsrvcosts')
of_create_amount_entry("ADMN", "Administrative", ld_value, "")
ld_value = 0

//Equipment

ld_value = dw_detail.GetItemDecimal(1, 'pb_equipmentcosts')
of_create_amount_entry("EQUP", "Equipment", ld_value, "")
ld_value = 0

//Legal

ld_value = dw_detail.GetItemDecimal(1, 'pb_legalcosts')
of_create_amount_entry("LGL", "Legal", ld_value, "")
ld_value = 0

//Administrative Force Account

ld_value = dw_detail.GetItemDecimal(1, 'pb_adminfacosts')
of_create_amount_entry("AFA", "Administrative Force Account", ld_value, "")
ld_value = 0

//Technical Force Account

ld_value = dw_detail.GetItemDecimal(1, 'pb_techfacosts')
of_create_amount_entry("FFA", "Technical Force Account", ld_value, "")
ld_value = 0

//Miscellaneous

ld_value = dw_detail.GetItemDecimal(1, 'pb_misccosts')
ls_value = Trim(dw_detail.getItemString(1, 'pb_misccosts_text'))
of_create_amount_entry("MISC", "Miscellaneous", ld_value, ls_value)
ld_value = 0
ls_value = ""

//*************************************************************
// Project Funding:
//*************************************************************

If (is_grantType = "Construction") Then
		
	//Requested
	
	ld_value = dw_detail.GetItemDecimal(1, 'cg_fundsrequested')
	of_create_amount_entry("GIGPFR", "Requested", ld_value, "")
	ld_value = 0
		
	//Local Match
	
	ld_value = dw_detail.GetItemDecimal(1, 'cg_localmatch')
	of_create_amount_entry("10MMN", "Matching", ld_value, "")	
	ld_value = 0	
		
	//Other
	
	ld_value = dw_detail.GetItemDecimal(1, 'cg_otherfunding')
	of_create_amount_entry("OTHFR", "Other", ld_value, "")	
	ld_value = 0

ElseIf (is_grantType = "Design") Then

	//Requested
	
	ld_value = dw_detail.GetItemDecimal(1, 'dg_fundsrequested')
	of_create_amount_entry("GIGPFR", "Requested", ld_value, "")
	ld_value = 0
		
	//Local Match
	
	ld_value = dw_detail.GetItemDecimal(1, 'dg_localmatch')
	of_create_amount_entry("10MMN", "Matching", ld_value, "")	
	ld_value = 0	
		
	//Other
	
	ld_value = dw_detail.GetItemDecimal(1, 'dg_otherfunding')
	of_create_amount_entry("OTHFR", "Other", ld_value, "")	
	ld_value = 0
	
End If

//SEQR Classification:

li_checkValue = dw_detail.GetItemNumber (1, "seqr_type1_flag")
If (li_checkValue = 1) Then ls_value = "Type1"	
li_checkValue = 0

li_checkValue = dw_detail.GetItemNumber (1, "seqr_unlisted_flag")
If (li_checkValue = 1) Then ls_value = "Unlisted"	
li_checkValue = 0

li_checkValue = dw_detail.GetItemNumber (1, "seqr_type2_flag")
If (li_checkValue = 1) Then ls_value = "Type2"	
li_checkValue = 0

dw_appinfo.SetItem(1,"seqr_type", ls_value)	

//Enforcement Status:

li_checkValue = dw_detail.GetItemNumber (1, "enforce_yes_flag")

If (li_checkValue = 1)  Then
	of_create_checklist_entry("undENFORCE", "")	
	li_checkValue = 0
End If

//Check for errors!
of_build_error_message()

If (Len(Trim(is_errMessage)) > 0) Then
	of_create_note_entry("NOTE", "POSIT", is_errMessage)		
End If

li_rc = This.Event pfc_save()

If (li_rc > 0) Then	
	ls_value = dw_appinfo.GetItemString(1, "project_name")	
	MessageBox("IMPORT", "GIGP Project " + String(il_gigpID) + " Successfully created for " + ls_value)	
	of_reset_import("FULL")
Else
	of_reset_import("PARTIAL")
End If


end event

public subroutine of_create_checklist_entry (string as_refcode, string as_comment);

Long li_checkValue, ll_newRow

ll_newRow = dw_checklist.InsertRow(0)

dw_checklist.SetItem(ll_newRow,"ref_code", as_refcode)
dw_checklist.SetItem(ll_newRow,"checklist_value", 1)
dw_checklist.SetItem(ll_newRow,"checklist_value2", 0)

If (Len(as_comment) > 0) Then
	dw_checklist.SetItem(ll_newRow,"checklist_comments", as_comment)
End If
end subroutine

public subroutine of_create_note_entry (string as_category, string as_type, string as_comment);
Long ll_newRow

ll_newRow = dw_notes.InsertRow(0)	

dw_notes.SetItem(ll_newRow, "note_category", as_category) 	
dw_notes.SetItem(ll_newRow, "note_type", as_type) 	
dw_notes.SetItem(ll_newRow, "comments", as_comment)

	


end subroutine

public subroutine of_create_date_entry (string as_refcode, datetime adt_value, string as_dateind);
Long ll_newRow
String ls_dateind

ll_newRow = dw_keydates.InsertRow(0)	

If (as_dateind = "Target") Then
	ls_dateind = "T"
ElseIf  (as_dateind = "Target") Then
	ls_dateind = "A"
Else
	ls_dateind = ""
End If	

dw_keydates.SetItem(ll_newRow,"ref_code", as_refcode)
dw_keydates.SetItem(ll_newRow,"keydate_value", adt_value)
dw_keydates.SetItem(ll_newRow,"keydate_ind",as_dateind)	


end subroutine

public subroutine of_create_amount_entry (string as_refcode, string as_subcategory, decimal ad_amount, string as_comment);
long ll_newRow

If IsNull(ad_amount) Then ad_amount = 0

ll_newRow = dw_amounts.InsertRow(0)	
	
dw_amounts.SetItem(ll_newRow,"ref_code", as_refcode)
dw_amounts.SetItem(ll_newRow,"sub_category", as_subcategory)
dw_amounts.SetItem(ll_newRow,"ref_amt",ad_amount)	
dw_amounts.SetItem(ll_newRow,"approved_amt",0)	

If (Len(as_comment) > 0) Then 
	dw_amounts.SetItem(ll_newRow,"amt_description", as_comment)	
End If
end subroutine

public subroutine of_create_contactlink_entry (long as_contactid, string as_contacttype);
Long ll_newRow

ll_newRow = dw_contactlinks.InsertRow(0)

dw_contactlinks.SetItem(ll_newRow, "contact_id", as_contactid)
dw_contactlinks.SetItem(ll_newRow, "contact_Type", as_contacttype)
end subroutine

public function boolean of_check_contact (long al_contactid);
Long ll_count

Select Count(*)
Into :ll_count
From gigp_contacts
Where contact_id = :al_contactid
And    status = "Active";

If (ll_count > 0) Then
	Return True
Else
	Return False
End If




end function

protected subroutine of_create_contact_entry (string as_contacttype, string as_organization, string as_name, string as_title, string as_address, string as_munitype, string as_city, string as_state, string as_zip, string as_county, string as_phone, string as_fax, string as_email, string as_gislong, string as_gislat);
Long ll_newRow
pfc_n_cst_string lu_string
String ls_value

//*************************************************************
//
//*************************************************************

il_tempID++

il_tempContactID = il_tempID

ll_newRow = dw_contacts.InsertRow(0)

dw_contacts.SetItem(ll_newRow, "contact_id", il_tempContactID)
dw_contacts.SetItem(ll_newRow, "Status", "Active")

of_create_contactlink_entry(il_tempContactID, as_contacttype)

//*************************************************************
//
//*************************************************************

If Not (IsNull(as_organization)) Then 	dw_contacts.SetItem(ll_newRow, "organization", as_organization)
If Not (IsNull(as_name)) Then dw_contacts.SetItem(ll_newRow, "full_name", as_name)
If Not (IsNull(as_title)) Then dw_contacts.SetItem(ll_newRow, "title", as_title)
If Not (IsNull(as_address)) Then dw_contacts.SetItem(ll_newRow, "mail_address1", as_address)
If Not (IsNull(as_munitype)) Then dw_contacts.SetItem(ll_newRow, "muni_type", as_munitype)
If Not (IsNull(as_city)) Then dw_contacts.SetItem(ll_newRow, "mail_city", as_city)
If Not (IsNull(as_state)) Then dw_contacts.SetItem(ll_newRow, "mail_state", as_state)

If Not (IsNull(as_zip)) Then 
	ls_value = lu_string.of_globalreplace(as_zip, "-", "")
	dw_contacts.SetItem(ll_newRow, "mail_zip", ls_value)
	ls_value = ""
End If

If Not (IsNull(as_county)) Then dw_contacts.SetItem(ll_newRow, "county", as_county)

If Not (IsNull(as_phone)) Then	
	ls_value = lu_string.of_globalreplace(as_phone, "(", "")
	ls_value = lu_string.of_globalreplace(ls_value, ")", "")
	ls_value = lu_string.of_globalreplace(ls_value, "-", "")
	dw_contacts.SetItem(ll_newRow, "phone_1", ls_value)
	ls_value = ""
End If

If Not (IsNull(as_fax)) Then 	
	ls_value = lu_string.of_globalreplace(as_fax, "(", "")
	ls_value = lu_string.of_globalreplace(ls_value, ")", "")
	ls_value = lu_string.of_globalreplace(ls_value, "-", "")
	dw_contacts.SetItem(ll_newRow, "fax", ls_value)	
	ls_value = ""
End If

If Not (IsNull(as_email)) Then dw_contacts.SetItem(ll_newRow, "email", as_email)
If Not (IsNull(as_gislong)) Then dw_contacts.SetItem(ll_newRow, "gis_longitude", as_gislong)
If Not (IsNull(as_gislat)) Then dw_contacts.SetItem(ll_newRow, "gis_latitude", as_gislat)




end subroutine

public subroutine of_reset_import (string as_type);

If (as_type = "FULL") Then
	
	dw_detail.Reset()
	
	cbx_applicant.Checked = True
	cbx_primary.Checked = True
	cbx_location.Checked = True
	cbx_engineer.Checked = True
	
	em_applicant.Text = ""
	em_primary.Text = ""
	em_location.Text = ""
	em_engineer.Text = ""
	
	em_applicant.Enabled = False
	em_primary.Enabled = False
	em_location.Enabled = False
	em_engineer.Enabled = False
	
End If
	
dw_appinfo.Reset()
dw_checklist.Reset()
dw_keydates.Reset()
dw_amounts.Reset()
dw_metrics.Reset()
dw_contacts.Reset()
dw_contactlinks.Reset()
dw_notes.Reset()
dw_politdistricts.Reset()

il_gigpID = 0
il_tempID = 0
il_tempContactID = 0


is_errMessage = ""
end subroutine

public subroutine of_create_metric_entry (string as_subcategory, string as_refcode, decimal ad_value);
Long ll_newRow

ll_newRow = dw_metrics.InsertRow(0)	

dw_metrics.SetItem(ll_newRow,"category", "projectMetric")
dw_metrics.SetItem(ll_newRow,"sub_category", as_subcategory)
dw_metrics.SetItem(ll_newRow,"ref_code", as_refcode)
dw_metrics.SetItem(ll_newRow,"metric_value", ad_value)	
end subroutine

public subroutine of_build_error_message ();
Integer li_value1, li_value2, li_count
String ls_value, ls_lineItem, lsErrMsgHeadr,  ls_message, ls_newline
Decimal ld_value1, ld_value2

li_count = dw_detail.Rowcount()

If (li_count < 1) Then Return

ls_newline = "~r~n"
lsErrMsgHeadr  = ("ROUND 2 APPLICATION ERRORS:" + ls_newline)
ls_message = lsErrMsgHeadr

// Check GPR Citation:

ls_value = dw_detail.GetItemString(1, "gpr_citation")

If (IsNull(ls_value) Or Trim(ls_value) = "") Then
	ls_lineItem = ("> GPR Citation Required" + ls_newline)
	ls_message += ls_lineItem
End If

ls_value = ""
ls_lineItem = ""

//Check Grant Type Selection:

li_value1 = dw_detail.GetItemNumber(1, "granttype_construct_flag")
li_value2 = dw_detail.GetItemNumber(1, "granttype_design_flag")

If((li_value1 + li_value2) = 2) Then
	ls_lineItem = (" > Both Construction & Design Grant Types Selected" + ls_newline)
	ls_message += ls_lineItem
	
ElseIf ((li_value1 + li_value2) = 0) Then
	ls_lineItem = ("> Grant Type Not Selected" + ls_newline)
	ls_message += ls_lineItem
	
End If

ld_value1 = dw_detail.GetItemDecimal(1, "cf_cg_calc")
ld_value2 = dw_detail.GetItemDecimal(1, "cf_dg_calc")

If (li_value1 = 0 and ld_value1 > 0 ) Then
	ls_lineItem = ("> Contruction Grant Type not selected but Construction Grant Amount Requested" + ls_newline)
	ls_message += ls_lineItem	
	ls_lineItem = ""
End If

If (li_value2 = 0 and ld_value2 > 0 ) Then
	ls_lineItem = ("> Design Grant Type not selected but Design Grant Amount Requested" + ls_newline)
	ls_message += ls_lineItem	
	ls_lineItem = ""
End If

li_value1 = 0
li_value2 = 0
ld_value1 = 0
ld_value2 = 0
ls_lineItem = ""

//Check Grant Amounts:

ld_value1 = dw_detail.GetItemDecimal(1, "cg_totalprojcosts")
If IsNull(ld_value1) Then ld_value1 = 0

ld_value2 = dw_detail.GetItemDecimal(1, "cf_cg_calc")
If IsNull(ld_value2) Then ld_value2 = 0

If (ld_value1 <> ld_value2) Then
	ls_lineItem = ("> Construction Grant Costs Total Incorrect" + ls_newline)
	ls_message += ls_lineItem	
End If

ld_value1 = 0
ld_value2 = 0
ls_lineItem = ""

ld_value1 = dw_detail.GetItemDecimal(1, "dg_totalprojcosts")
If IsNull(ld_value1) Then ld_value1 = 0

ld_value2 = dw_detail.GetItemDecimal(1, "cf_dg_calc")
If IsNull(ld_value2) Then ld_value2 = 0

If (ld_value1 <> ld_value2) Then
	ls_lineItem = ("> Design Grant Costs Total Incorrect" + ls_newline)
	ls_message += ls_lineItem	
End If

ld_value1 = 0
ld_value2 = 0
ls_lineItem = ""

//Check Grant Limits:

ld_value1 = dw_detail.GetItemDecimal(1, "cg_fundsrequested")
If IsNull(ld_value1) Then ld_value1 = 0

ld_value2 = dw_detail.GetItemDecimal(1, "cf_cg_requestcalc")
If IsNull(ld_value2) Then ld_value2 = 0

If (ld_value1 > ld_value2) Or( ld_value1 > 750000) Then
	ls_lineItem = ("> Construction Grant Requested Amount Exceeds Limit" + ls_newline)
	ls_message += ls_lineItem	
End If

ld_value1 = 0
ld_value2 = 0
ls_lineItem = ""

ld_value1 = dw_detail.GetItemDecimal(1, "dg_fundsrequested")
If IsNull(ld_value1) Then ld_value1 = 0

ld_value2 = dw_detail.GetItemDecimal(1, "cf_dg_requestcalc")
If IsNull(ld_value2) Then ld_value2 = 0

If (ld_value1 > ld_value2 Or ld_value1 > 50000) Then
	ls_lineItem = ("> Design Grant Requested Amount Exceeds Limit" + ls_newline)
	ls_message += ls_lineItem	
End If

ld_value1 = 0
ld_value2 = 0
ls_lineItem = ""

// Check Waterbodies:

ls_value = dw_detail.GetItemString(1, "waterbodies")

If (IsNull(ls_value) Or Trim(ls_value) = "") Then
	ls_lineItem = ("> Waterbodies Required" + ls_newline)
	ls_message += ls_lineItem
End If

ls_value = ""
ls_lineItem = ""

//WATER EFFICIENCY:

//Gallons / Year Saved:

ls_value = dw_detail.GetItemString(1, "we_galperyrsaved")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Water Efficiency - Gallons / Year Saved is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//Gallons / Year Reused:

ls_value = dw_detail.GetItemString(1, "we_galperyrused")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Water Efficiency - Gallons / Year Reused is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//Million Gallons per Day Eliminated / Conserved:

ls_value = dw_detail.GetItemString(1, "we_galperdayconserv")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Water Efficiency - Million Gallons per Day Eliminated / Conserved is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//ENERGY EFFICIENCY:

//Kilowatt Hours / Year Saved:

ls_value = dw_detail.GetItemString(1, "ee_kwhsaved")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Energy Efficiency - Kilowatt Hours / Year Saved is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//Kilowatt Hours / Year Produced:

ls_value = dw_detail.GetItemString(1, "ee_kwhproduced")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Energy Efficiency - Kilowatt Hours / Year Produced is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//Gallons / Year Fuel Oil or Natural Gas Saved:

ls_value = dw_detail.GetItemString(1, "ee_galfuelsaved")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Energy Efficiency - Gallons / Year Fuel Oil or Natural Gas Saved is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//GREEN INFRASTRUCTURE:

//Lbs/ Year Sediment:

ls_value = dw_detail.GetItemString(1, "gi_tonsediment")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Green Infrastructure - Lbs/ Year Sediment is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//Lbs/ Year Road Salt:

ls_value = dw_detail.GetItemString(1, "gi_lbsroadsalt")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Green Infrastructure - Lbs/ Year Road Salt is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//Lbs/ Year Phosphorous:

ls_value = dw_detail.GetItemString(1, "gi_lbsphosph")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Green Infrastructure - Lbs/ Year Phosphorous is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//Lbs/ Year Nitrogen:

ls_value = dw_detail.GetItemString(1, "gi_nitrogen")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Green Infrastructure - Lbs/ Year Nitrogen is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//Planned Acres of Wetlands Restored:

ls_value = dw_detail.GetItemString(1, "gi_acrerestored")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Green Infrastructure - Planned Acres of Wetlands Restored is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//Planned Acres of Wetlands Created:

ls_value = dw_detail.GetItemString(1, "gi_acrecreated")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Green Infrastructure - Planned Acres of Wetlands Created is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//Planned Linear Feet of Streanbank/Shoreline Protected:

ls_value = dw_detail.GetItemString(1, "gi_feetprotected")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Green Infrastructure - Planned Linear Feet of Streanbank/Shoreline Protected is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

//Planned Linear Feet of Stream Channel Stabilized:

ls_value = dw_detail.GetItemString(1, "gi_feetstailized")

If (Not IsNumber(ls_value)) and (Not IsNull(ls_value)) Then
	ls_lineItem = ("> PART D Green Infrastructure - Planned Linear Feet of Stream Channel Stabilized is Non-numeric" + ls_newline)
	ls_message += ls_lineItem	
End If

ls_value = ""
ls_lineItem = ""

// Executive Summary:

ls_value = dw_detail.GetItemString(1, "parte_1_execsum")

If (IsNull(ls_value) Or Trim(ls_value) = "") Then
	ls_lineItem = ("> PART E - Executive Summary Required" + ls_newline)
	ls_message += ls_lineItem
End If

ls_value = ""
ls_lineItem = ""

// Spur Green Innovation:

ls_value = dw_detail.GetItemString(1, "parte_2_spur")

If (IsNull(ls_value) Or Trim(ls_value) = "") Then
	ls_lineItem = ("> PART E - Spur Green Innovation Required" + ls_newline)
	ls_message += ls_lineItem
End If

ls_value = ""
ls_lineItem = ""

// Build Green Capacity Locally:

ls_value = dw_detail.GetItemString(1, "parte_3_buildgreen")

If (IsNull(ls_value) Or Trim(ls_value) = "") Then
	ls_lineItem = ("> PART E - Spur Build Green Capacity Locally Required" + ls_newline)
	ls_message += ls_lineItem
End If

ls_value = ""
ls_lineItem = ""

// Facilitate Green Technology Transfer:

ls_value = dw_detail.GetItemString(1, "parte_4_techtransfer")

If (IsNull(ls_value) Or Trim(ls_value) = "") Then
	ls_lineItem = ("> PART E - Facilitate Green Technology Transfer Required" + ls_newline)
	ls_message += ls_lineItem
End If

ls_value = ""
ls_lineItem = ""

// Outreach & Educational Opportunities:

ls_value = dw_detail.GetItemString(1, "parte_5_outreach")

If (IsNull(ls_value) Or Trim(ls_value) = "") Then
	ls_lineItem = ("> PART E - Outreach and Educational Opportunities Required" + ls_newline)
	ls_message += ls_lineItem
End If

ls_value = ""
ls_lineItem = ""

// Long-Term Operation & Maintenance:

ls_value = dw_detail.GetItemString(1, "parte_6a_operation")

If (IsNull(ls_value) Or Trim(ls_value) = "") Then
	ls_lineItem = ("> PART E - Long-Term Operation and Maintenance Required" + ls_newline)
	ls_message += ls_lineItem
End If

ls_value = ""
ls_lineItem = ""

// Repair & Replacement:

ls_value = dw_detail.GetItemString(1, "parte_6b_repair")

If (IsNull(ls_value) Or Trim(ls_value) = "") Then
	ls_lineItem = ("> PART E - Repair and Replacement Required" + ls_newline)
	ls_message += ls_lineItem
End If

ls_value = ""
ls_lineItem = ""

//Project Budget Total costs

ld_value1 = dw_detail.GetItemDecimal(1, "pb_totalcosts")
ld_value2 = dw_detail.GetItemDecimal(1, "cf_pb_calc")

If (ld_value1 <> ld_value2) Then
	ls_lineItem = ("> Budget Costs Total Incorrect" + ls_newline)
	ls_message += ls_lineItem	
End If

ld_value1 = 0
ld_value2 = 0
ls_value = ""
ls_lineItem = ""

//Engineering Contact - State Code

ls_value = dw_detail.GetItemString(1, "ec_state")

If (Len(ls_value) <> 2) Then
	ls_lineItem = ("> Engineering Contact - Invalid State Code" + ls_newline)
	ls_message += ls_lineItem
End If

ls_value = ""
ls_lineItem = ""


If (ls_message = lsErrMsgHeadr) Then
	is_errMessage = ""
Else
	is_errMessage  = ls_message
End If

//MessageBox("Test!", ls_message)
end subroutine

public subroutine of_prescanfile ();
Integer N
String ls_value
Long ll_upper
String lsCol[] = 	{'gpr_citation',&
                  			'waterbodies',&
                  			'environ_innovative_text',&
  		  				'addit_waterqual_benefits',&
             	 			 'parte_1_execsum',&
                  			'parte_2_spur',&
                 			 'parte_3_buildgreen',&
 						'parte_4_techtransfer', &
						'parte_5_outreach',&
						 'parte_6a_operation',& 
						'parte_6b_repair', &
						'parte_7other_text', &
						'cg_othercosts_text',&
						 'pb_misccosts_text',&
						'app_name',&
						'app_address1',&
						'app_muni_type',&
						'app_city',&
						'app_zip',&
						'app_county',&
						'primary_name',&
						'primary_title',&
						'primary_phone',&
						'app_fedid',&
						'primary_fax',&
						'primary_email',&
						'primary_address1',&
						'primary_muni_type',&
						'primary_city',&
						'primary_state',&
						'primary_zip',&
						'primary_county',&
						'app_nonmuni_type',&
						'app_congress',&
						'app_senate',&
						'app_assembly',&
						'proj_name',&
						'proj_address1',&
						'proj_muni_type',&
						'proj_city',&
						'proj_zip',&
						'proj_county',&
						'proj_lat',&
						'proj_long',&
						'proj_popsource',&
						'proj_congress',&
						'proj_senate',&
						'proj_assembly',&
						'ec_firmname',&
						'ec_title',&
						'ec_address1',&
						'ec_muni_type',&
						'ec_city',&
						'ec_state',&
						'ec_zip',&
						'ec_phone',&
						'ec_fax',&
						'ec_email'}

//Clean State Column for Engineering Contact

ls_value = Upper(dw_detail.GetItemString(1, "ec_state"))

If (ls_value = "NEW YORK") OR (ls_value = "N.Y.") Or (Lower(ls_value) = "ny") Then	
	dw_detail.SetItem(1, "ec_state", "NY")
End If

ls_value = ""

//Clean special characters from text columns

ll_upper = UpperBound(lsCol)

FOR N = 1 TO ll_upper
      ls_value = dw_detail.GetItemString(1, lsCol[N])
	of_cleanse_text(ls_value)
	dw_detail.SetItem(1,  lsCol[N], ls_value)
	ls_value = ""

NEXT

//Column not used in Import 
dw_detail.SetItem(1, "permittext6", "")
end subroutine

public subroutine of_cleanse_text (ref string as_text);
Integer			li_UBound, N
n_cst_string		lu_string
String 			ls_text

String ls_find[]		= {'“', '”', '’', '…', '–', '‘'}
String ls_replace[] = {'"', '"', "'", '...','-', "'"}

//*************************************************************
// Cleanse text of special characters that cause issues with database.
//*************************************************************

ls_text = as_text

li_UBound = UpperBound(ls_find)

FOR N = 1 TO li_UBound
     ls_text =  lu_string.of_globalreplace(ls_text, ls_find[N], ls_replace[N])
NEXT

ls_text = lu_string.of_removenonprint(ls_text)

as_text = Trim(ls_text)


end subroutine

public function integer of_create_politicaldistrict_entry (string as_districttype, string as_districtnos);
Long ll_newRow, ll_value, ll_count
Integer li_upper, n, li_values[]
String ls_value, ls_values[], ls_errorMsg
n_cst_string lu_string

//*************************************************************
// Multiple District Numbers - Comma Delimited:
//*************************************************************
		
ll_count = lu_string.of_countoccurrences(as_districtnos , ",")
		
If (ll_count < 1) Then		
	
	//*************************************************************
	// Single numeric District Number:
	//*************************************************************

	If (IsNumber (as_districtnos)) Then
		ll_newRow = dw_politdistricts.InsertRow(0)	
		dw_politdistricts.SetItem(ll_newRow,"contact_id", il_tempContactID)
		dw_politdistricts.SetItem(ll_newRow,"district_type", as_districttype)
		dw_politdistricts.SetItem(ll_newRow,"district_no", Long(as_districtnos))	
	Else
		Return -1
	End If

Else	
		lu_string.of_parsetoarray(as_districtnos, ",", ls_values)
				
		li_upper = UpperBound(ls_values)
		
		If (li_upper > 0) Then			
			
			FOR n = 1 TO li_upper

				If (IsNumber(ls_values[n])) Then
					// Convert district number to numeric
					li_values[n] = Integer(ls_values[n])	
				Else							
					Return -1
				End If

      		NEXT		
			
			li_upper = UpperBound(li_values)
			
			FOR n = 1 TO li_upper
					ll_newRow = dw_politdistricts.InsertRow(0)	
					dw_politdistricts.SetItem(ll_newRow,"contact_id", il_tempContactID)
					dw_politdistricts.SetItem(ll_newRow,"district_type", as_districttype)
					dw_politdistricts.SetItem(ll_newRow,"district_no", li_values[n])	
      		NEXT		
						
		End If
		
End If	
	
Return 1












end function

on w_application_import.create
int iCurrent
call super::create
if this.MenuName = "m_gigp_sheet" then this.MenuID = create m_gigp_sheet
this.shl_1=create shl_1
this.dw_appinfo=create dw_appinfo
this.dw_checklist=create dw_checklist
this.dw_keydates=create dw_keydates
this.dw_amounts=create dw_amounts
this.dw_notes=create dw_notes
this.dw_contacts=create dw_contacts
this.dw_contactlinks=create dw_contactlinks
this.cb_import=create cb_import
this.dw_metrics=create dw_metrics
this.cbx_applicant=create cbx_applicant
this.cbx_primary=create cbx_primary
this.cbx_location=create cbx_location
this.cbx_engineer=create cbx_engineer
this.em_applicant=create em_applicant
this.em_primary=create em_primary
this.em_location=create em_location
this.em_engineer=create em_engineer
this.cb_reset=create cb_reset
this.st_1=create st_1
this.dw_politdistricts=create dw_politdistricts
this.cb_errors=create cb_errors
this.cb_new=create cb_new
this.st_2=create st_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.shl_1
this.Control[iCurrent+2]=this.dw_appinfo
this.Control[iCurrent+3]=this.dw_checklist
this.Control[iCurrent+4]=this.dw_keydates
this.Control[iCurrent+5]=this.dw_amounts
this.Control[iCurrent+6]=this.dw_notes
this.Control[iCurrent+7]=this.dw_contacts
this.Control[iCurrent+8]=this.dw_contactlinks
this.Control[iCurrent+9]=this.cb_import
this.Control[iCurrent+10]=this.dw_metrics
this.Control[iCurrent+11]=this.cbx_applicant
this.Control[iCurrent+12]=this.cbx_primary
this.Control[iCurrent+13]=this.cbx_location
this.Control[iCurrent+14]=this.cbx_engineer
this.Control[iCurrent+15]=this.em_applicant
this.Control[iCurrent+16]=this.em_primary
this.Control[iCurrent+17]=this.em_location
this.Control[iCurrent+18]=this.em_engineer
this.Control[iCurrent+19]=this.cb_reset
this.Control[iCurrent+20]=this.st_1
this.Control[iCurrent+21]=this.dw_politdistricts
this.Control[iCurrent+22]=this.cb_errors
this.Control[iCurrent+23]=this.cb_new
this.Control[iCurrent+24]=this.st_2
end on

on w_application_import.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.shl_1)
destroy(this.dw_appinfo)
destroy(this.dw_checklist)
destroy(this.dw_keydates)
destroy(this.dw_amounts)
destroy(this.dw_notes)
destroy(this.dw_contacts)
destroy(this.dw_contactlinks)
destroy(this.cb_import)
destroy(this.dw_metrics)
destroy(this.cbx_applicant)
destroy(this.cbx_primary)
destroy(this.cbx_location)
destroy(this.cbx_engineer)
destroy(this.em_applicant)
destroy(this.em_primary)
destroy(this.em_location)
destroy(this.em_engineer)
destroy(this.cb_reset)
destroy(this.st_1)
destroy(this.dw_politdistricts)
destroy(this.cb_errors)
destroy(this.cb_new)
destroy(this.st_2)
end on

event pfc_preopen;call super::pfc_preopen;
//********************************************************************
// Limit Menu Functionality:
//********************************************************************

im_Menu = This.MenuID

//******************************************************
// Customize Menu:
//******************************************************

//im_Menu.m_file.m_save.Visible = True
//im_Menu.m_file.m_save.ToolBarItemVisible = True

//******************************************************
// Order the Sheet Toolbar:
//******************************************************

im_Menu.m_file.m_save.ToolBarItemOrder 		    	= 1
im_Menu.m_file.m_close.ToolBarItemOrder 			= 2

//*******************************************************
// Set Access Group(s):
//*******************************************************

is_accessGroups = {"TAS-Global", "Application"}


end event

event pfc_preupdate;call super::pfc_preupdate;
Long ll_rowCnt, ll_row,  ll_rowCnt2, ll_row2, ll_tempID, ll_contactID

//*************************************************************
// Set Key and Last Update Values:
//*************************************************************

idt_today = f_getdbdatetime()

il_gigpID = 	 f_gettokenvalue("gigpID", 1)

//*************************************************************
// Application Info:
//*************************************************************

dw_appinfo.SetItem(1, "gigp_id", il_gigpID)
dw_appinfo.SetItem(1, "round_no", 2)
dw_appinfo.SetItem(1, "last_updated_by", is_user)
dw_appinfo.SetItem(1, "last_updated_dt", idt_today)

//*************************************************************
// Checklist:
//*************************************************************

ll_rowCnt = dw_checklist.RowCount()

If (ll_rowCnt > 0) Then	
	FOR ll_row = 1 TO ll_rowCnt
		dw_checklist.SetItem(ll_row, "gigp_id", il_gigpID)
		dw_checklist.SetItem(ll_row, "last_updated_by", is_user)
		dw_checklist.SetItem(ll_row, "last_updated_dt", idt_today)
	NEXT	
End If 

ll_row		 = 0
ll_rowCnt = 0

//*************************************************************
// Key Dates:
//*************************************************************

ll_rowCnt = dw_keydates.RowCount()

If (ll_rowCnt > 0) Then	
	FOR ll_row = 1 TO ll_rowCnt
		dw_keydates.SetItem(ll_row, "gigp_id", il_gigpID)
		dw_keydates.SetItem(ll_row, "last_updated_by", is_user)
		dw_keydates.SetItem(ll_row, "last_updated_dt", idt_today)
	NEXT	
End If 

ll_row		 = 0
ll_rowCnt = 0

//*************************************************************
// Amounts:
//*************************************************************

ll_rowCnt = dw_amounts.RowCount()

If (ll_rowCnt > 0) Then	
	FOR ll_row = 1 TO ll_rowCnt		
		dw_amounts.SetItem(ll_row, "amount_id", f_gettokenvalue("amountID", 1))		
		dw_amounts.SetItem(ll_row, "gigp_id", il_gigpID)
		dw_amounts.SetItem(ll_row, "last_updated_by", is_user)
		dw_amounts.SetItem(ll_row, "last_updated_dt", idt_today)
	NEXT	
End If 

ll_row		 = 0
ll_rowCnt = 0

//*************************************************************
// Metrics:
//*************************************************************

ll_rowCnt = dw_metrics.RowCount()

If (ll_rowCnt > 0) Then	
	FOR ll_row = 1 TO ll_rowCnt
		dw_metrics.SetItem(ll_row, "gigp_id", il_gigpID)
		dw_metrics.SetItem(ll_row, "last_updated_by", is_user)
		dw_metrics.SetItem(ll_row, "last_updated_dt", idt_today)
	NEXT	
End If 

ll_row		 = 0
ll_rowCnt = 0

//*************************************************************
// Notes:
//*************************************************************

ll_rowCnt = dw_notes.RowCount()

If (ll_rowCnt > 0) Then	
	FOR ll_row = 1 TO ll_rowCnt
		dw_notes.SetItem(ll_row, "gigp_id", il_gigpID)
		dw_notes.SetItem(ll_row, "user_id", is_user)
		dw_notes.SetItem(ll_row, "note_dt", idt_today)
	NEXT	
End If 

ll_row		 = 0
ll_rowCnt = 0

//*************************************************************
// Contacts / Contact Links:
//*************************************************************

ll_rowCnt = dw_contactlinks.RowCount()

If (ll_rowCnt > 0) Then		
	FOR ll_row = 1 TO ll_rowCnt
		dw_contactlinks.SetItem(ll_row, "gigp_id", il_gigpID)
	NEXT	
End If 

ll_row		 = 0
ll_rowCnt = 0

ll_rowCnt = dw_contacts.RowCount()

If (ll_rowCnt > 0) Then	
	FOR ll_row = 1 TO ll_rowCnt
		
		ll_tempID = dw_contacts.GetItemnumber(ll_row, "contact_id")
		ll_contactID =  f_gettokenvalue("contactID", 1)
		
		dw_contacts.SetItem(ll_row, "contact_id", ll_contactID)
		dw_contacts.SetItem(ll_row, "last_updated_by", is_user)
		dw_contacts.SetItem(ll_row, "last_updated_dt", idt_today)
		
		// Convert Temporary Contact IDs in Contact Links		
		
		dw_contactlinks.SetFilter("contact_id = " + String(ll_tempID))
		dw_contactlinks.Filter()
		
		ll_rowCnt2 = dw_contactlinks.RowCount()

		If (ll_rowCnt2 > 0) Then		
			FOR ll_row2 = 1 TO ll_rowCnt2
				dw_contactlinks.SetItem(ll_row2, "contact_id", ll_contactID)
			NEXT	
		End If 
		
		dw_contactlinks.SetFilter("")
		dw_contactlinks.Filter()
		ll_row2 = 0
		ll_rowCnt2 = 0
				
		// Convert Temporary Contact IDs in Political Districts	
		
		dw_politdistricts.SetFilter("contact_id = " + String(ll_tempID))
		dw_politdistricts.Filter()
		
		ll_rowCnt2 = dw_politdistricts.RowCount()

		If (ll_rowCnt2 > 0) Then		
			FOR ll_row2 = 1 TO ll_rowCnt2
				dw_politdistricts.SetItem(ll_row2, "contact_id", ll_contactID)
			NEXT	
		End If 
		
		dw_politdistricts.SetFilter("")
		dw_politdistricts.Filter()
				
		ll_tempID = 0
		ll_contactID =  0
		ll_row2 = 0
		ll_rowCnt2 = 0		
		
	NEXT		
	
End If 

ll_row		 = 0
ll_rowCnt = 0

Return AncestorReturnValue
end event

event open;call super::open;
is_user = gnv_app.of_getuserid()

//This.inv_resize.of_Register(cb_reset,"FixedToRight") 
This.inv_resize.of_Register(cb_import,"FixedToRight") 
end event

event pfc_endtran;call super::pfc_endtran;
gnv_Event.of_PublishEvent("ue_newapp")

Return AncestorReturnValue
end event

type dw_detail from w_detail`dw_detail within w_application_import
integer x = 41
integer y = 256
integer width = 2377
integer height = 1088
string dataobject = "d_application_import"
boolean hscrollbar = false
boolean righttoleft = true
boolean ib_isupdateable = false
end type

event dw_detail::buttonclicked;call super::buttonclicked;
Integer	li_RC
String ls_access, ls_text, ls_column


If (Match(dwo.Name, "b_edit")) Then	
	
	Dw_detail.AcceptText()	
	
	ls_column = dwo.Tag
	
	ls_Text  = This.GetItemString(row, ls_column)
			
	 ls_access = "EDIT"	
	
	li_RC = f_edit_notes(ls_access, ls_Text)
	
	If (li_RC = 1) Then This.SetItem(row, ls_column, ls_Text)	
	
End If
end event

type shl_1 from statichyperlink within w_application_import
integer x = 50
integer y = 36
integer width = 672
integer height = 56
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean underline = true
string pointer = "HyperLink!"
long textcolor = 32768
long backcolor = 67108864
string text = "Get Application for Import"
boolean focusrectangle = false
end type

event clicked;
Integer li_rc

String  ls_file, ls_PathFile, ls_user, ls_initDir

ls_user = gnv_app.of_getuserid()

ls_initDir = "C:\Documents and Settings\" + ls_user + "\Desktop"

If Not (DirectoryExists (ls_initDir)) Then
   ls_initDir = ""

End If

//*************************************************************
// Prompt user for data file name:
//*************************************************************

IF GetFileOpenName("Get Application",ls_PathFile,ls_File,"XML","XML Files (*.XML),*.XML,", ls_initDir   ) <> 1 THEN
	Return
END IF

dw_detail.Reset()

li_rc = dw_detail.ImportFile(ls_PathFile,1) 

If (li_rc > 0) Then of_prescanfile()







end event

type dw_appinfo from u_dw within w_application_import
boolean visible = false
integer x = 32
integer y = 1024
integer width = 448
integer height = 136
integer taborder = 11
boolean bringtotop = true
boolean titlebar = true
string title = "App Info"
string dataobject = "d_import_app_info"
boolean resizable = true
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

type dw_checklist from u_dw within w_application_import
boolean visible = false
integer x = 507
integer y = 1024
integer width = 448
integer height = 136
integer taborder = 21
boolean bringtotop = true
boolean titlebar = true
string title = "Checklist"
string dataobject = "d_import_checklist"
boolean resizable = true
end type

event constructor;call super::constructor;This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

type dw_keydates from u_dw within w_application_import
boolean visible = false
integer x = 983
integer y = 1024
integer width = 448
integer height = 112
integer taborder = 31
boolean bringtotop = true
boolean titlebar = true
string title = "Key Dates"
string dataobject = "d_import_keydates"
boolean resizable = true
end type

event constructor;call super::constructor;This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

type dw_amounts from u_dw within w_application_import
boolean visible = false
integer x = 1458
integer y = 1024
integer width = 448
integer height = 112
integer taborder = 41
boolean bringtotop = true
boolean titlebar = true
string title = "Amounts"
string dataobject = "d_import_amounts"
boolean resizable = true
end type

event constructor;call super::constructor;This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

type dw_notes from u_dw within w_application_import
boolean visible = false
integer x = 1458
integer y = 1176
integer width = 448
integer height = 112
integer taborder = 51
boolean bringtotop = true
boolean titlebar = true
string title = "Notes"
string dataobject = "d_import_notes"
boolean resizable = true
end type

event constructor;call super::constructor;This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

type dw_contacts from u_dw within w_application_import
boolean visible = false
integer x = 507
integer y = 1176
integer width = 448
integer height = 112
integer taborder = 61
boolean bringtotop = true
boolean titlebar = true
string title = "Contacts"
string dataobject = "d_import_contacts"
boolean resizable = true
end type

event constructor;call super::constructor;This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

type dw_contactlinks from u_dw within w_application_import
boolean visible = false
integer x = 983
integer y = 1176
integer width = 448
integer height = 136
integer taborder = 71
boolean bringtotop = true
boolean titlebar = true
string title = "Contact Links"
string dataobject = "d_import_contactslinks"
boolean resizable = true
end type

event constructor;call super::constructor;This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

type cb_import from commandbutton within w_application_import
integer x = 2112
integer y = 148
integer width = 306
integer height = 84
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Import"
end type

event clicked;
Parent.Event ue_process()


end event

type dw_metrics from u_dw within w_application_import
boolean visible = false
integer x = 32
integer y = 1176
integer width = 448
integer height = 112
integer taborder = 81
boolean bringtotop = true
boolean titlebar = true
string title = "Metrics"
string dataobject = "d_import_metrics"
boolean resizable = true
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

type cbx_applicant from checkbox within w_application_import
integer x = 489
integer y = 156
integer width = 293
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Applicant"
boolean checked = true
end type

event clicked;
em_applicant.Text = ""

If (This.checked = True) Then
	em_applicant.Enabled = False
Else
	em_applicant.Enabled = True
End If
end event

type cbx_primary from checkbox within w_application_import
integer x = 969
integer y = 156
integer width = 242
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Primary"
boolean checked = true
end type

event clicked;
em_primary.Text = ""

If (This.checked = True) Then
	em_primary.Enabled = False
Else
	em_primary.Enabled = True
End If
end event

type cbx_location from checkbox within w_application_import
integer x = 1403
integer y = 160
integer width = 279
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Location"
boolean checked = true
end type

event clicked;
em_location.Text = ""

If (This.checked = True) Then
	em_location.Enabled = False
Else
	em_location.Enabled = True
End If
end event

type cbx_engineer from checkbox within w_application_import
integer x = 1861
integer y = 156
integer width = 279
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Engineer"
boolean checked = true
end type

event clicked;
em_engineer.Text = ""

If (This.checked = True) Then
	em_engineer.Enabled = False
Else
	em_engineer.Enabled = True
End If
end event

type em_applicant from editmask within w_application_import
integer x = 777
integer y = 156
integer width = 169
integer height = 76
integer taborder = 21
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
boolean enabled = false
alignment alignment = center!
string mask = "####"
end type

type em_primary from editmask within w_application_import
integer x = 1216
integer y = 156
integer width = 169
integer height = 76
integer taborder = 31
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
boolean enabled = false
string text = "none"
alignment alignment = center!
string mask = "####"
end type

type em_location from editmask within w_application_import
integer x = 1669
integer y = 156
integer width = 169
integer height = 76
integer taborder = 41
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
boolean enabled = false
string text = "none"
alignment alignment = center!
string mask = "####"
end type

type em_engineer from editmask within w_application_import
integer x = 2130
integer y = 156
integer width = 169
integer height = 76
integer taborder = 51
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
boolean enabled = false
string text = "none"
alignment alignment = center!
string mask = "####"
end type

type cb_reset from commandbutton within w_application_import
integer x = 1312
integer y = 20
integer width = 183
integer height = 84
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Reset"
end type

event clicked;
of_reset_import("FULL")
end event

type st_1 from statictext within w_application_import
integer x = 41
integer y = 168
integer width = 448
integer height = 56
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Import Contacts:"
boolean focusrectangle = false
end type

type dw_politdistricts from u_dw within w_application_import
boolean visible = false
integer x = 1934
integer y = 1024
integer width = 448
integer height = 112
integer taborder = 61
boolean bringtotop = true
boolean titlebar = true
string title = "Political Districts"
string dataobject = "d_import_politdistricts"
boolean resizable = true
end type

event constructor;call super::constructor;
This.SetTransObject(SQLCA)

This.ib_RMBMenu = False
end event

type cb_errors from commandbutton within w_application_import
integer x = 2075
integer y = 20
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
string text = "App. Errors"
end type

event clicked;
of_build_error_message()

f_edit_notes("READ", is_errMessage)
end event

type cb_new from commandbutton within w_application_import
integer x = 910
integer y = 20
integer width = 343
integer height = 84
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "New Row"
end type

event clicked;
Long ll_rowCnt, ll_row

ll_rowCnt = dw_detail.RowCount()

If (ll_rowCnt < 1) Then 	dw_detail.InsertRow(0)
end event

type st_2 from statictext within w_application_import
integer x = 741
integer y = 36
integer width = 160
integer height = 60
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "- OR - "
boolean focusrectangle = false
end type

