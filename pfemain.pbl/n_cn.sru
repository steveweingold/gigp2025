﻿//objectcomments Extension Connection class
forward
global type n_cn from pfc_n_cn
end type
end forward

global type n_cn from pfc_n_cn
end type
global n_cn n_cn

on n_cn.create
call connection::create
TriggerEvent( this, "constructor" )
end on

on n_cn.destroy
call connection::destroy
TriggerEvent( this, "destructor" )
end on

