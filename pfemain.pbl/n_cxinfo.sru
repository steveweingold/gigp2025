﻿//objectcomments Extension ContextInformation class
forward
global type n_cxinfo from pfc_n_cxinfo
end type
end forward

global type n_cxinfo from pfc_n_cxinfo
end type
global n_cxinfo n_cxinfo

on n_cxinfo.create
call contextinformation::create
TriggerEvent( this, "constructor" )
end on

on n_cxinfo.destroy
call contextinformation::destroy
TriggerEvent( this, "destructor" )
end on

