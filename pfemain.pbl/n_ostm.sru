﻿//objectcomments Extension OLEStream class
forward
global type n_ostm from pfc_n_ostm
end type
end forward

global type n_ostm from pfc_n_ostm
end type
global n_ostm n_ostm

on n_ostm.create
call olestream::create
TriggerEvent( this, "constructor" )
end on

on n_ostm.destroy
call olestream::destroy
TriggerEvent( this, "destructor" )
end on

