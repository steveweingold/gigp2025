﻿//objectcomments Extension Error class
forward
global type n_err from pfc_n_err
end type
end forward

global type n_err from pfc_n_err
end type
global n_err n_err

on n_err.create
call error::create
TriggerEvent( this, "constructor" )
end on

on n_err.destroy
call error::destroy
TriggerEvent( this, "destructor" )
end on

