//objectcomments A handy userobject for selecting times. Scrolls in settable increments.
forward
global type u_time_scroll from UserObject
end type
type em_1 from editmask within u_time_scroll
end type
type vsb_1 from vscrollbar within u_time_scroll
end type
end forward

global type u_time_scroll from UserObject
int Width=425
int Height=120
boolean Border=true
long BackColor=12632256
long PictureMaskColor=25166016
long TabTextColor=33554432
long TabBackColor=67108864
em_1 em_1
vsb_1 vsb_1
end type
global u_time_scroll u_time_scroll

type variables
Private:
  long il_Increment = 900
end variables

forward prototypes
public function time of_gettime ()
public subroutine of_settime (time at_Time)
public subroutine of_setincrement (long al_Increment)
public function long of_getincrement ()
end prototypes

public function time of_gettime ();Return Time(em_1.Text)

end function

public subroutine of_settime (time at_Time);em_1.Text = String(at_Time)

end subroutine

public subroutine of_setincrement (long al_Increment);il_Increment = al_Increment

Return
end subroutine

public function long of_getincrement ();Return il_Increment

end function

on u_time_scroll.create
this.em_1=create em_1
this.vsb_1=create vsb_1
this.Control[]={this.em_1,&
this.vsb_1}
end on

on u_time_scroll.destroy
destroy(this.em_1)
destroy(this.vsb_1)
end on

event constructor;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

end event

type em_1 from editmask within u_time_scroll
int X=18
int Y=16
int Width=293
int Height=84
int TabOrder=1
Alignment Alignment=Center!
BorderStyle BorderStyle=StyleLowered!
string Mask="hh:mm:ss"
MaskDataType MaskDataType=TimeMask!
long BackColor=16777215
int TextSize=-8
int Weight=700
string FaceName="MS Sans Serif"
FontFamily FontFamily=Swiss!
FontPitch FontPitch=Variable!
end type

type vsb_1 from vscrollbar within u_time_scroll
int X=329
int Y=16
int Width=59
int Height=84
boolean Enabled=false
end type

event linedown;IF IsTime(em_1.Text) THEN
	em_1.Text = String(RelativeTime(Time(em_1.Text),-il_Increment))
ELSE
	em_1.Text = String(Now())
END IF


end event

event lineup;IF IsTime(em_1.Text) THEN
	em_1.Text = String(RelativeTime(Time(em_1.Text),il_Increment))
ELSE
	em_1.Text = String(Now())
END IF


end event

