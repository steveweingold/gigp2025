forward
global type w_smallgrants_customerselect from w_pick_list
end type
type rb_wd from radiobutton within w_smallgrants_customerselect
end type
type rb_t from radiobutton within w_smallgrants_customerselect
end type
type rb_v from radiobutton within w_smallgrants_customerselect
end type
type rb_co from radiobutton within w_smallgrants_customerselect
end type
type rb_c from radiobutton within w_smallgrants_customerselect
end type
type rb_p from radiobutton within w_smallgrants_customerselect
end type
type rb_au from radiobutton within w_smallgrants_customerselect
end type
type sle_filter from singlelineedit within w_smallgrants_customerselect
end type
type pb_filter from picturebutton within w_smallgrants_customerselect
end type
type pb_clear from picturebutton within w_smallgrants_customerselect
end type
type cb_1 from commandbutton within w_smallgrants_customerselect
end type
type gb_1 from groupbox within w_smallgrants_customerselect
end type
type st_1 from statictext within w_smallgrants_customerselect
end type
type rb_sd from radiobutton within w_smallgrants_customerselect
end type
type rb_sch from radiobutton within w_smallgrants_customerselect
end type
type sle_name from singlelineedit within w_smallgrants_customerselect
end type
type rb_s from radiobutton within w_smallgrants_customerselect
end type
end forward

global type w_smallgrants_customerselect from w_pick_list
integer x = 214
integer y = 221
integer width = 2779
integer height = 3216
string title = "Match GIGP Applicant"
windowanimationstyle openanimation = rightroll!
windowanimationstyle closeanimation = rightslide!
rb_wd rb_wd
rb_t rb_t
rb_v rb_v
rb_co rb_co
rb_c rb_c
rb_p rb_p
rb_au rb_au
sle_filter sle_filter
pb_filter pb_filter
pb_clear pb_clear
cb_1 cb_1
gb_1 gb_1
st_1 st_1
rb_sd rb_sd
rb_sch rb_sch
sle_name sle_name
rb_s rb_s
end type
global w_smallgrants_customerselect w_smallgrants_customerselect

type variables
string is_applicant
long il_gigpid
end variables

forward prototypes
public function string of_createmunicode (string as_county, string as_type)
end prototypes

public function string of_createmunicode (string as_county, string as_type);string ls_muni, ls_increment, ls_checkmuni
integer li_index
long ll_count
n_cst_string ln_string

If IsNull(as_county) Then as_county = ''
If IsNull(as_type) Then as_type = ''

//Build suggested Municode based on the following:
//Position 1 & 2 = County Code
//Position 3 & 4 = Blank = 46; AU = 40; C = 02; CO = 01; CORP = 88; JB = 86; P = 65; S = 33; T = 03; V = 04; WD = 24
//Position 5 thru 12 = '00000001' then increment untill the full combination does not exist
If as_county > '' Then
	//Start the Municode with positions 1 and 2
	ls_muni = Right(String(Integer(as_county)), 2)	//To get rid of any leading Zeros
	If Len(ls_muni) = 1 Then ls_muni = '0' + ls_muni
Else
	ls_muni = '99'
End If
	
//Add positions 3 and 4 based on the Community Type
Choose Case as_type
	Case 'AU'
		ls_muni += '40'
		
	Case 'C'
		ls_muni += '02'
		
	Case 'CO'
		ls_muni += '01'
	
	Case 'CORP'
		ls_muni += '88'
		
	Case 'JB'
		ls_muni += '86'
		
	Case 'P'
		ls_muni += '65'
		
	Case 'S'
		ls_muni += '33'
		
	Case 'T'
		ls_muni += '03'
		
	Case 'V'
		ls_muni += '04'
		
	Case 'WD'
		ls_muni += '24'
		
	Case Else
		ls_muni += '46'
		
End Choose

//Fill w/ zeros to 1 and increment till new
li_index = 1
ls_increment = ln_string.of_globalreplace(ln_string.of_padleft(String(li_index), 8), ' ', '0')
ls_checkmuni = ls_muni + ls_increment

select count(*)
into :ll_count
from fin_muni_codes
where muni_code = :ls_checkmuni;

Do While ll_count > 0
	li_index++
	ls_increment = ln_string.of_globalreplace(ln_string.of_padleft(String(li_index), 8), ' ', '0')
	ls_checkmuni = ls_muni + ls_increment
	
	select count(*)
	into :ll_count
	from fin_muni_codes
	where muni_code = :ls_checkmuni;
	
Loop

ls_muni = ls_checkmuni

Return ls_muni
end function

on w_smallgrants_customerselect.create
int iCurrent
call super::create
this.rb_wd=create rb_wd
this.rb_t=create rb_t
this.rb_v=create rb_v
this.rb_co=create rb_co
this.rb_c=create rb_c
this.rb_p=create rb_p
this.rb_au=create rb_au
this.sle_filter=create sle_filter
this.pb_filter=create pb_filter
this.pb_clear=create pb_clear
this.cb_1=create cb_1
this.gb_1=create gb_1
this.st_1=create st_1
this.rb_sd=create rb_sd
this.rb_sch=create rb_sch
this.sle_name=create sle_name
this.rb_s=create rb_s
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.rb_wd
this.Control[iCurrent+2]=this.rb_t
this.Control[iCurrent+3]=this.rb_v
this.Control[iCurrent+4]=this.rb_co
this.Control[iCurrent+5]=this.rb_c
this.Control[iCurrent+6]=this.rb_p
this.Control[iCurrent+7]=this.rb_au
this.Control[iCurrent+8]=this.sle_filter
this.Control[iCurrent+9]=this.pb_filter
this.Control[iCurrent+10]=this.pb_clear
this.Control[iCurrent+11]=this.cb_1
this.Control[iCurrent+12]=this.gb_1
this.Control[iCurrent+13]=this.st_1
this.Control[iCurrent+14]=this.rb_sd
this.Control[iCurrent+15]=this.rb_sch
this.Control[iCurrent+16]=this.sle_name
this.Control[iCurrent+17]=this.rb_s
end on

on w_smallgrants_customerselect.destroy
call super::destroy
destroy(this.rb_wd)
destroy(this.rb_t)
destroy(this.rb_v)
destroy(this.rb_co)
destroy(this.rb_c)
destroy(this.rb_p)
destroy(this.rb_au)
destroy(this.sle_filter)
destroy(this.pb_filter)
destroy(this.pb_clear)
destroy(this.cb_1)
destroy(this.gb_1)
destroy(this.st_1)
destroy(this.rb_sd)
destroy(this.rb_sch)
destroy(this.sle_name)
destroy(this.rb_s)
end on

event open;call super::open;il_gigpid = Message.DoubleParm

select organization
into :is_applicant
from gigp_contacts
where contact_id = (select max(contact_id)
							from gigp_contact_links
							where gigp_id = :il_gigpid
							and contact_type = 'APP');

sle_name.Text = is_applicant

SetNull(is_return)

end event

event pfc_postopen;call super::pfc_postopen;dw_list.SelectRow(0, False)

sle_filter.SetFocus()
end event

type dw_list from w_pick_list`dw_list within w_smallgrants_customerselect
integer x = 27
integer y = 288
integer width = 1952
integer height = 2668
string dataobject = "d_smallgrants_customerselect"
end type

event dw_list::clicked;call super::clicked;is_return = String(this.GetItemNumber(row, 'CustomerId'))
end event

type cb_ok from w_pick_list`cb_ok within w_smallgrants_customerselect
integer x = 603
integer y = 3000
string text = "Match"
boolean default = false
end type

type cb_cancel from w_pick_list`cb_cancel within w_smallgrants_customerselect
integer x = 1001
integer y = 3000
end type

type rb_wd from radiobutton within w_smallgrants_customerselect
string tag = "WD"
integer x = 2098
integer y = 864
integer width = 535
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Water District"
end type

type rb_t from radiobutton within w_smallgrants_customerselect
string tag = "T"
integer x = 2098
integer y = 264
integer width = 535
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Town"
end type

type rb_v from radiobutton within w_smallgrants_customerselect
string tag = "V"
integer x = 2098
integer y = 384
integer width = 535
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Village"
end type

type rb_co from radiobutton within w_smallgrants_customerselect
string tag = "CO"
integer x = 2098
integer y = 504
integer width = 535
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "County"
end type

type rb_c from radiobutton within w_smallgrants_customerselect
string tag = "C"
integer x = 2098
integer y = 144
integer width = 535
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "City"
boolean checked = true
end type

type rb_p from radiobutton within w_smallgrants_customerselect
string tag = "P"
integer x = 2098
integer y = 624
integer width = 535
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Private"
end type

type rb_au from radiobutton within w_smallgrants_customerselect
string tag = "AU"
integer x = 2098
integer y = 744
integer width = 535
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Authority"
end type

type sle_filter from singlelineedit within w_smallgrants_customerselect
integer x = 192
integer y = 152
integer width = 1527
integer height = 92
integer taborder = 10
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type pb_filter from picturebutton within w_smallgrants_customerselect
integer x = 1742
integer y = 148
integer width = 110
integer height = 96
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
boolean default = true
string picturename = "Filter!"
alignment htextalign = left!
string powertiptext = "Filter"
end type

event clicked;string ls_filter

If sle_filter.Text > '' Then
	ls_filter = "Upper(CustomerName) like '%" + Upper(sle_filter.Text) + "%'"
	
	dw_list.SetFilter(ls_filter)
	dw_list.Filter()
	
End If
end event

type pb_clear from picturebutton within w_smallgrants_customerselect
integer x = 1870
integer y = 148
integer width = 110
integer height = 96
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string picturename = "Clear!"
alignment htextalign = left!
string powertiptext = "Clear"
end type

event clicked;sle_filter.Text = ''
dw_list.SetFilter('')
dw_list.Filter()
end event

type cb_1 from commandbutton within w_smallgrants_customerselect
integer x = 2139
integer y = 1396
integer width = 402
integer height = 92
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string text = "Create New"
end type

event clicked;string ls_customertype, ls_municode, ll_customerid, ls_countycode, ls_countyname, ls_projectmuni
integer li_region

dw_list.SelectRow(0, False)
is_applicant = sle_name.Text	//Just in case any cleanup needs to be done
SetNull(is_return)

//Get the CustomerType
If rb_c.Checked Then
	ls_customertype = 'C'
ElseIf rb_t.Checked Then
	ls_customertype = 'T'
ElseIf rb_v.Checked Then
	ls_customertype = 'V'
ElseIf rb_co.Checked Then
	ls_customertype = 'CO'
ElseIf rb_p.Checked Then
	ls_customertype = 'P'
ElseIf rb_au.Checked Then
	ls_customertype = 'AU'
ElseIf rb_wd.Checked Then
	ls_customertype = 'WD'
ElseIf rb_sd.Checked Then
	ls_customertype = 'SD'
ElseIf rb_sch.Checked Then
	ls_customertype = 'SCH'
ElseIf rb_s.Checked Then
	ls_customertype = 'S'
End If

If MessageBox('New Customer', 'Are you sure you want to create a new Customer record for ' + is_applicant + ' of Type "' + ls_customertype + '"?', Question!, YesNo!, 2) = 2 Then
	Return
End If

//Get county / county code / dec region
select county_fips_code, dec_region, muni_code
into :ls_countycode, :li_region, :ls_projectmuni
from gigp_application
where gigp_id = :il_gigpid;

//If no county set, check the project muni's county if that is set
If IsNull(ls_countycode) or ls_countycode = '' Then
	If ls_projectmuni > '' Then
		select county_code
		into :ls_countycode
		from fin_muni_codes
		where muni_code = :ls_projectmuni;
	End If
End If

//Translate county code to name
If ls_countycode > '' Then
	select ref_value
	into :ls_countyname
	from gigp_reference
	where category = 'County'
	and ref_code = :ls_countycode;
Else
	SetNull(ls_countyname)
End If

ls_municode = of_createmunicode(ls_countycode, ls_customertype)

INSERT INTO Customer
	(MuniCode
	,GeoId
	,CustomerName
	,CustomerType
	,County
	,DecRegion
	,FiscalYearEnds
	,MoodysOrgCode
	,Comments
	,LastUpdatedDate
	,LastUpdatedBy)
VALUES
	(:ls_municode
	,null
	,:is_applicant
	,:ls_customertype
	,:ls_countyname
	,:li_region
	,null
	,null
	,'Conversion from Small Grants'
	,getdate()
	,'SYSTEM');
	
//Get the ID from the inserted row
select @@Identity
into :ll_customerid
from Dual;

is_return = String(ll_customerid)

parent.Event pfc_default()
end event

type gb_1 from groupbox within w_smallgrants_customerselect
integer x = 2039
integer y = 32
integer width = 663
integer height = 1532
integer taborder = 30
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Customer Type"
end type

type st_1 from statictext within w_smallgrants_customerselect
integer x = 27
integer y = 168
integer width = 201
integer height = 64
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Filter:"
boolean focusrectangle = false
end type

type rb_sd from radiobutton within w_smallgrants_customerselect
integer x = 2098
integer y = 984
integer width = 535
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Sewer District"
end type

type rb_sch from radiobutton within w_smallgrants_customerselect
integer x = 2098
integer y = 1104
integer width = 535
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "School District"
end type

type sle_name from singlelineedit within w_smallgrants_customerselect
integer x = 27
integer y = 44
integer width = 1952
integer height = 72
integer taborder = 40
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type rb_s from radiobutton within w_smallgrants_customerselect
integer x = 2098
integer y = 1224
integer width = 535
integer height = 64
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "State"
end type

