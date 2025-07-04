﻿//objectcomments PFC DataWindow Property - The Calculator service tabpage
forward
global type pfc_u_tabpg_dwproperty_srvcalculator from u_tabpg_dwproperty_base
end type
type cbx_initialvalue from u_cbx within pfc_u_tabpg_dwproperty_srvcalculator
end type
type cbx_closeonclick from u_cbx within pfc_u_tabpg_dwproperty_srvcalculator
end type
type dw_register from u_dw within pfc_u_tabpg_dwproperty_srvcalculator
end type
end forward

global type pfc_u_tabpg_dwproperty_srvcalculator from u_tabpg_dwproperty_base
event type integer pfc_propertypopulate ( )
cbx_initialvalue cbx_initialvalue
cbx_closeonclick cbx_closeonclick
dw_register dw_register
end type
global pfc_u_tabpg_dwproperty_srvcalculator pfc_u_tabpg_dwproperty_srvcalculator

type variables
Protected:
integer	ii_style = -1
end variables

forward prototypes
public function integer of_getinfo (ref n_cst_infoattrib anv_infoattrib)
public function integer of_getpropertyinfo (ref n_cst_propertyattrib anv_attrib)
end prototypes

event pfc_propertypopulate;call super::pfc_propertypopulate;//////////////////////////////////////////////////////////////////////////////
//
//	Function:  		pfc_properypopulate
//
//	Access:    		Public
//
//	Arguments:  	None
//
//	Returns:   		Integer
//   1 if it succeeds.
//	 -1 if an error occurs.
//
//	Description:  	
//	Populate the screen edit controls with the current service values.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	6.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2005, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the GNU Lesser General
 * Public License Version 2.1, February 1999
 *
 * http://www.gnu.org/copyleft/lesser.html
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see http://pfc.codexchange.sybase.com
*/
//
//////////////////////////////////////////////////////////////////////////////

integer	li_upperall, li_upperreg
integer	li_cntall, li_cntreg
integer 	li_rc
integer	li_style
integer	li_index
integer	li_row
string	ls_allcols[]
string	ls_registeredcols[]
integer	li_registeredgui[]

// Validate references.
If IsNull(idw_requestor) or Not IsValid(idw_requestor) Then
	Return -1
End If
If IsNull(idw_requestor.iuo_calculator) or Not IsValid(idw_requestor.iuo_calculator) Then
	Return -1
End If

// Determine if InitialValue is enabled.
cbx_initialvalue.Checked = idw_requestor.iuo_calculator.of_IsInitialValue()

// Determine if Close on Click is enabled.
cbx_closeonclick.Checked = idw_requestor.iuo_calculator.of_IsCloseOnClick()

// Get all the columns the calculator object could sevice.
li_rc = idw_requestor.iuo_calculator.of_GetRegisterable(ls_allcols)
// Get all the registered columns.
li_rc = idw_requestor.iuo_calculator.of_GetRegistered(ls_registeredcols, li_registeredgui)
// Add All of the columns and Select the Registered columns
li_upperall = UpperBound(ls_allcols)
li_upperreg = UpperBound(ls_registeredcols)
For li_cntall = 1 to li_upperall
	li_row = dw_register.InsertRow(0)
	If li_row > 0 Then
		dw_register.object.columnname.primary[li_row] = ls_allcols[li_cntall]
		dw_register.object.style.primary[li_row] = 1
		// Determine if this is an registered column.
		For li_cntreg = 1 to li_upperreg
			If ls_allcols[li_cntall] = ls_registeredcols[li_cntreg] Then
				dw_register.object.register.primary[li_row] = 'Y'
				dw_register.object.style.primary[li_row] = li_registeredgui[li_cntreg]
				Exit
			End If
		Next
	End If
Next

Return 1

end event

public function integer of_getinfo (ref n_cst_infoattrib anv_infoattrib);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  		of_GetInfo
//
//	Access:   		Public
//
//	Arguments:		
//		anv_infoattrib	(By reference) The Information attributes.
//
//	Returns:  		Integer
//	 1 for success.
//	-1 for error.
//
//	Description:  
//	 Gets the Object Information.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	6.0    Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2005, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the GNU Lesser General
 * Public License Version 2.1, February 1999
 *
 * http://www.gnu.org/copyleft/lesser.html
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see http://pfc.codexchange.sybase.com
*/
//
//////////////////////////////////////////////////////////////////////////////

// Populate Information.
anv_infoattrib.is_name = 'DW Property Calculator Object'
anv_infoattrib.is_description = 'DW Property Calculator Object'

Return 1
end function

public function integer of_getpropertyinfo (ref n_cst_propertyattrib anv_attrib);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  		of_GetPropertyInfo
//
//	Access:   		Public
//
//	Arguments:		
//		anv_attrib	(By ref.) The Property Information attributes.
//
//	Returns:  		Integer
//	 1 for success.
//	-1 for error.
//
//	Description:  
//	 Gets the Service Property Information.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	6.0    Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2005, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the GNU Lesser General
 * Public License Version 2.1, February 1999
 *
 * http://www.gnu.org/copyleft/lesser.html
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see http://pfc.codexchange.sybase.com
*/
//
//////////////////////////////////////////////////////////////////////////////

n_cst_infoattrib lnv_infoattrib

// Get the first two attributes from the Main Information attributes.
of_GetInfo(lnv_infoattrib)
anv_attrib.is_name = lnv_infoattrib.is_name
anv_attrib.is_description = lnv_infoattrib.is_description

// The Property Tab Text.
anv_attrib.is_propertytabtext ='General'

Return 1
end function

on pfc_u_tabpg_dwproperty_srvcalculator.create
int iCurrent
call super::create
this.cbx_initialvalue=create cbx_initialvalue
this.cbx_closeonclick=create cbx_closeonclick
this.dw_register=create dw_register
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cbx_initialvalue
this.Control[iCurrent+2]=this.cbx_closeonclick
this.Control[iCurrent+3]=this.dw_register
end on

on pfc_u_tabpg_dwproperty_srvcalculator.destroy
call super::destroy
destroy(this.cbx_initialvalue)
destroy(this.cbx_closeonclick)
destroy(this.dw_register)
end on

event pfc_propertyapply;call super::pfc_propertyapply;//////////////////////////////////////////////////////////////////////////////
//
//	Function:  		pfc_PropertyApply
//
//	Access:    		Public
//
//	Arguments:  	None
//
//	Returns:   		Integer
//   1 if it succeeds.
//	 -1 if an error occurs.
//
//	Description:  		
//	 Apply the requested changes.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	6.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2005, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the GNU Lesser General
 * Public License Version 2.1, February 1999
 *
 * http://www.gnu.org/copyleft/lesser.html
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see http://pfc.codexchange.sybase.com
*/
//
//////////////////////////////////////////////////////////////////////////////

integer	li_rowcount
integer	li_row
integer 	li_rc
integer	li_index
integer	li_excludecount=0
string	ls_column
boolean	lb_current, lb_desired
integer	li_desiredstyle, li_currentstyle

// Validate references.

If IsNull(idw_requestor) or Not IsValid(idw_requestor) Then
	Return -1
End If
If IsNull(idw_requestor.iuo_calculator) or Not IsValid(idw_requestor.iuo_calculator) Then
	Return -1
End If

// -- Initial Value. --
lb_current = idw_requestor.iuo_calculator.of_IsInitialValue()
lb_desired = cbx_initialvalue.Checked
// If the desired value differs from the current value.
If  lb_current<> lb_desired Then
	li_rc = idw_requestor.iuo_calculator.of_SetInitialValue(lb_desired)
End If

// -- Close on Click. --
lb_current = idw_requestor.iuo_calculator.of_IsCloseOnClick()
lb_desired = cbx_closeonclick.Checked
// If the desired value differs from the current value.
If  lb_current<> lb_desired Then
	li_rc = idw_requestor.iuo_calculator.of_SetCloseOnClick(lb_desired)
End If

// -- Register or Unregister Columns. --
li_rowcount = dw_register.RowCount()
For li_row = 1 to li_rowcount
	// Get the column name, register flag, and style.
	ls_column = dw_register.object.columnname.primary[li_row]
	lb_desired = (dw_register.object.register.primary[li_row] = 'Y')
	li_desiredstyle = dw_register.object.style.primary[li_row]
	
	If lb_desired THEN  
		// Want this current column to be registered.
		If Not idw_requestor.iuo_calculator.of_IsRegistered(ls_column) Then
			li_rc = idw_requestor.iuo_calculator.of_Register(ls_column, li_desiredstyle)
		Else
			// Already registered, see if the style is the same.
			li_currentstyle = idw_requestor.iuo_calculator.of_GetRegisteredStyle(ls_column)
			If li_currentstyle <> li_desiredstyle Then
				// Unregister and then register back with the new style.
				li_rc = idw_requestor.iuo_calculator.of_UnRegister(ls_column)
				li_rc = idw_requestor.iuo_calculator.of_Register(ls_column, li_desiredstyle)
			End If
		End If
	Else
		// Want this current column to Not be registed.
		If idw_requestor.iuo_calculator.of_IsRegistered(ls_column) Then
			li_rc = idw_requestor.iuo_calculator.of_UnRegister(ls_column)
		End If		
	End If
Next

Return 1

end event

event pfc_propertyvalidation;call super::pfc_propertyvalidation;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  pfc_PropertyValidation
//
//	Arguments:  None
//
//	Returns: Integer
//	 1 = successful
// -1 = Error
//
//	Description:
//	 Validate the object.
//
//////////////////////////////////////////////////////////////////////////////
//	
//	Revision History
//
//	Version
//	6.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2005, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the GNU Lesser General
 * Public License Version 2.1, February 1999
 *
 * http://www.gnu.org/copyleft/lesser.html
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see http://pfc.codexchange.sybase.com
*/
//
//////////////////////////////////////////////////////////////////////////////

If dw_register.AcceptText() <= 0 Then 
	Return -1
End If

Return 1
end event

event pfc_propertysyntax;call super::pfc_propertysyntax;//////////////////////////////////////////////////////////////////////////////
//
//	Function:  		pfc_propertysyntax
//
//	Access:    		Public
//
//	Arguments:  	None
//
//	Returns:   		String
//	  The syntax required to create the currently selections.
//   '!' in error
//
//	Description:  
//	Create the required syntax to match the current selections.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	6.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2005, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the GNU Lesser General
 * Public License Version 2.1, February 1999
 *
 * http://www.gnu.org/copyleft/lesser.html
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see http://pfc.codexchange.sybase.com
*/
//
//////////////////////////////////////////////////////////////////////////////

integer	li_rowcount
integer	li_row
string	ls_column
integer	li_desiredstyle
integer	li_upper
integer	li_cnt
integer 	li_rc
integer	li_index
string	ls_syntax
boolean	lb_desired
string	ls_desiredstyle
n_cst_conversion lnv_conversion

// Validate references.
If IsNull(idw_requestor) or Not IsValid(idw_requestor) Then
	Return '!'
End If
If IsNull(idw_requestor.iuo_calculator) or Not IsValid(idw_requestor.iuo_calculator) Then
	Return '!'
End If


// -- Start the service. --
ls_syntax += 'This.of_SetDropDownCalculator(TRUE)~r~n'

// -- Initial Value. --
lb_desired = cbx_initialvalue.Checked
ls_syntax += '~r~nThis.iuo_calculator.of_SetInitialValue('+lnv_conversion.of_String(lb_desired)+')'

// -- Close on Click. --
lb_desired = cbx_closeonclick.Checked
ls_syntax += '~r~nThis.iuo_calculator.of_SetCloseOnClick('+lnv_conversion.of_String(lb_desired)+')'

// -- Register Columns. --
li_rowcount = dw_register.RowCount()
For li_row = 1 to li_rowcount
	lb_desired = (dw_register.object.register.primary[li_row] = 'Y')
	If lb_desired THEN
		ls_column = dw_register.object.columnname.primary[li_row]
		li_desiredstyle = dw_register.object.style.primary[li_row]
		Choose Case li_desiredstyle
			Case idw_requestor.iuo_calculator.NONE
				ls_desiredstyle = 'iuo_calculator.NONE'
			Case idw_requestor.iuo_calculator.DDLB
				ls_desiredstyle = 'iuo_calculator.DDLB'
			Case idw_requestor.iuo_calculator.DDLB_WITHARROW
				ls_desiredstyle = 'iuo_calculator.DDLB_WITHARROW'
			Case Else
				ls_desiredstyle = String(li_desiredstyle)
		End Choose		
		ls_syntax += '~r~nThis.iuo_calculator.of_Register("'+ls_column+'",'+ls_desiredstyle+')'
	
	End If
Next

Return ls_syntax
end event

type cbx_initialvalue from u_cbx within pfc_u_tabpg_dwproperty_srvcalculator
integer x = 27
integer y = 36
integer width = 1691
integer height = 68
integer taborder = 20
boolean bringtotop = true
string text = "Set &Initial value when none available"
end type

type cbx_closeonclick from u_cbx within pfc_u_tabpg_dwproperty_srvcalculator
integer x = 27
integer y = 120
integer width = 1691
integer height = 68
boolean bringtotop = true
string text = "Close on &click"
end type

type dw_register from u_dw within pfc_u_tabpg_dwproperty_srvcalculator
integer x = 32
integer y = 224
integer width = 1719
integer height = 1128
integer taborder = 10
string dataobject = "d_dwproperty_srvcal"
boolean border = false
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;//////////////////////////////////////////////////////////////////////////////
//
//	Function:  		constructor
//
//	Description:  		
//
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	6.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2005, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the GNU Lesser General
 * Public License Version 2.1, February 1999
 *
 * http://www.gnu.org/copyleft/lesser.html
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see http://pfc.codexchange.sybase.com
*/
//
//////////////////////////////////////////////////////////////////////////////

// This is not an updatable datawindow.
of_SetUpdateable(False)

// Disable Right Mouse Popup menu.
ib_rmbmenu = False

end event

