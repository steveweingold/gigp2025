forward
global type w_auto_shutdown from w_response
end type
type st_1 from statictext within w_auto_shutdown
end type
type st_3 from statictext within w_auto_shutdown
end type
type cb_1 from commandbutton within w_auto_shutdown
end type
end forward

global type w_auto_shutdown from w_response
string tag = "Auto Shut Down"
integer width = 1486
integer height = 532
string title = "Auto Shut Down"
boolean controlmenu = false
long backcolor = 65280
boolean center = true
st_1 st_1
st_3 st_3
cb_1 cb_1
end type
global w_auto_shutdown w_auto_shutdown

type prototypes
Public function Long SetWindowPos (Long hWnd, Long hWndInsertAfter, Long xx, Long yy, Long cx, Long cy, Long wFlags) library "user32"

end prototypes

type variables
boolean	ib_Dont_Shutdown
Constant Long WindowPosFlags = 83 // = SWP_NOACTIVATE + SWP_SHOWWINDOW + SWP_NOMOVE + SWP_NOSIZE
Constant Long HWND_TOPMOST = -1
Constant Long HWND_NOTOPMOST = -2

end variables

on w_auto_shutdown.create
int iCurrent
call super::create
this.st_1=create st_1
this.st_3=create st_3
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
this.Control[iCurrent+2]=this.st_3
this.Control[iCurrent+3]=this.cb_1
end on

on w_auto_shutdown.destroy
call super::destroy
destroy(this.st_1)
destroy(this.st_3)
destroy(this.cb_1)
end on

event pfc_postopen;call super::pfc_postopen;long				ll_Counter
time				lt_Start, &
					lt_End
int				li_Seconds, &
					li_Previous = 30

lt_Start = Now()
lt_End	= RelativeTime(lt_Start,30)

DO WHILE lt_End > Now()
	li_Seconds = SecondsAfter(Now(),lt_End)

	IF li_Seconds <> li_Previous THEN
		st_3.Text = "Shutting down in " + String(li_Seconds) + " seconds."
		li_Previous = li_Seconds
	END IF

	Yield()

	IF ib_Dont_Shutdown THEN
		Close(this)
		Return
	END IF
LOOP

IF ib_Dont_Shutdown THEN
	Close(this)
ELSE
	Disconnect using sqlca;

	Halt Close
END IF

end event

event open;call super::open;int			li_ScreenH, &
				li_ScreenW
environment	le_Env

// Center window.	//
GetEnvironment(le_Env)

li_ScreenH = PixelsToUnits(le_Env.ScreenHeight, YPixelsToUnits!)
li_ScreenW = PixelsToUnits(le_Env.ScreenWidth, XPixelsToUnits!)

this.Y = (li_ScreenH - this.Height) / 2
this.X = (li_ScreenW - this.Width) / 2

this.BringToTop = True

SetWindowPos (Handle (This), HWND_TOPMOST, 0, 0, 0, 0, WindowPosFlags)
end event

event key;call super::key;ib_Dont_Shutdown = True

end event

event clicked;call super::clicked;ib_Dont_Shutdown = True

end event

type st_1 from statictext within w_auto_shutdown
integer x = 23
integer y = 32
integer width = 1422
integer height = 104
integer textsize = -16
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 65280
string text = "GIGP Application"
alignment alignment = center!
boolean focusrectangle = false
end type

type st_3 from statictext within w_auto_shutdown
integer x = 23
integer y = 140
integer width = 1422
integer height = 104
integer textsize = -16
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 65280
string text = "Shutting down in 30 seconds!"
alignment alignment = center!
boolean focusrectangle = false
end type

type cb_1 from commandbutton within w_auto_shutdown
integer x = 480
integer y = 316
integer width = 480
integer height = 100
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Don~'t Shut Down"
boolean cancel = true
boolean default = true
end type

event clicked;ib_Dont_Shutdown = True

end event

