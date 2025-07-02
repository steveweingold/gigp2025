//objectcomments Descendant of u_dw. Adds much new functionality.
forward
global type u_dw_enhanced from u_dw
end type
end forward

global type u_dw_enhanced from u_dw
end type
global u_dw_enhanced u_dw_enhanced

type variables
string	is_Keys[], &
	is_KeyTypes[], &
	is_KeyValues[]

int	ii_NumKeys

boolean	ib_SetRedraw = True	
end variables

forward prototypes
public function integer of_checkforduplicates (integer ai_row, string as_keyvalues[])
public function integer of_registerkey (string as_key)
public subroutine of_settypicalservices (boolean ab_switch)
public subroutine of_displayerror (integer ai_Row, string as_Column, string as_Message)
end prototypes

public function integer of_checkforduplicates (integer ai_row, string as_keyvalues[]);int		li_Index, &
			li_Find_Row, &
			li_RC, &
			li_Pos
string	ls_Find

// Check for valid registered keys and for valid as_KeyValues[].	//
IF ii_NumKeys < 1 OR ii_NumKeys <> UpperBound(as_KeyValues) THEN
	Return 0
END IF

// If there are filtered rows, we need to include them for this	//
// duplicate search.																//

// Un-filtering the dw with the Filter() function causes problems	//
// because it can change what row the current row passed in as		//
// ai_Row is. Also it reverses the sort order when you un-filter.	//

// That's why we'll use the RowsMove() function to move any			//
// filtered rows into the Primary! buffer for duplicate searching.//
// Then we'll move them back into the Filter! buffer.					//

IF ib_SetRedraw THEN
	// This turns off screen redraw to eliminate flicker.	//
	this.SetRedraw(False)
END IF

// How many rows are originally in the Primary! buffer?	//
li_RC = this.RowCount()

// Move all filtered rows into Primary! after the last row	//
// originally in the Primary! buffer.								//
this.RowsMove(1,999999,Filter!,this,li_RC + 1,Primary!)

// Build the find string.	//
DO WHILE li_Index < this.ii_NumKeys
	li_Index ++

	// Single and double quotes and tildes will not work in find statements.	//
	IF Pos(as_KeyValues[li_Index],"'") > 0 OR Pos(as_KeyValues[li_Index],'"') > 0 OR &
				Pos(as_KeyValues[li_Index],"~~") > 0 THEN

		li_Pos = Pos(as_KeyValues[li_Index],"'")

		// Put a tilde before every single quote found.	//
		DO WHILE li_Pos > 0
			as_KeyValues[li_Index] = Mid(as_KeyValues[li_Index],1,li_Pos - 1) + &
												"~~" + Mid(as_KeyValues[li_Index],li_Pos,99999)
			li_Pos += 2

			li_Pos = Pos(as_KeyValues[li_Index],"'",li_Pos)
		LOOP

		li_Pos = Pos(as_KeyValues[li_Index],'"')

		// Put a tilde before every double quote found.	//
		DO WHILE li_Pos > 0
			as_KeyValues[li_Index] = Mid(as_KeyValues[li_Index],1,li_Pos - 1) + &
												"~~" + Mid(as_KeyValues[li_Index],li_Pos,99999)
			li_Pos += 2

			li_Pos = Pos(as_KeyValues[li_Index],'"',li_Pos)
		LOOP

		li_Pos = Pos(as_KeyValues[li_Index],'~~')

		// Put a tilde before every tilde found.	//
		DO WHILE li_Pos > 0
			as_KeyValues[li_Index] = Mid(as_KeyValues[li_Index],1,li_Pos - 1) + &
												"~~" + Mid(as_KeyValues[li_Index],li_Pos,99999)
			li_Pos += 2

			li_Pos = Pos(as_KeyValues[li_Index],'~~',li_Pos)
		LOOP
	END IF

	IF NOT IsNull(as_KeyValues[li_Index]) AND Trim(as_KeyValues[li_Index]) <> "" THEN
		CHOOSE CASE is_KeyTypes[li_Index]
		CASE "STRING"
			ls_Find += is_Keys[li_Index] + "=~"" + as_KeyValues[li_Index] + "~" and "
		CASE "NUMBER"
			ls_Find += is_Keys[li_Index] + "=" + as_KeyValues[li_Index] + " and "
		CASE "DATETIME"
			ls_Find += is_Keys[li_Index] + "=DateTime('" + as_KeyValues[li_Index] + "') and "
		CASE "DATE"
			ls_Find += is_Keys[li_Index] + "=Date('" + as_KeyValues[li_Index] + "') and "
		CASE "TIME"
			ls_Find += is_Keys[li_Index] + "=Time('" + as_KeyValues[li_Index] + "') and "
		END CHOOSE
	END IF
LOOP

IF ls_Find <> "" THEN
	ls_Find = Mid(ls_Find,1,Len(ls_Find) - 5)
	
	// Look for duplicates.	//
	li_Find_Row = this.Find(ls_Find,1,ai_Row - 1)
				
	IF li_Find_Row > 0 AND li_Find_Row <> ai_Row THEN
		// Move the filtered rows back into the Filter! buff and		//
		// turn screen redraw back on.										//
		this.RowsMove(li_RC + 1,999999,Primary!,this,1,Filter!)

		IF ib_SetRedraw THEN
			this.SetRedraw(True)
		END IF

		Return li_Find_Row
	ELSE
		li_Find_Row = this.Find(ls_Find,ai_Row + 1,999999)
	
		IF li_Find_Row > 0 AND li_Find_Row <> ai_Row THEN
			// Move the filtered rows back into the Filter! buff and		//
			// turn screen redraw back on.										//
			this.RowsMove(li_RC + 1,999999,Primary!,this,1,Filter!)

			IF ib_SetRedraw THEN
				this.SetRedraw(True)
			END IF

			Return li_Find_Row
		END IF
	END IF
END IF

// Move the filtered rows back into the Filter! buff and		//
// turn screen redraw back on.										//
this.RowsMove(li_RC + 1,999999,Primary!,this,1,Filter!)

IF ib_SetRedraw THEN
	this.SetRedraw(True)
END IF

Return 0

end function

public function integer of_registerkey (string as_key);// These keys will be used during post-update retrieval to restore the current row.		//

ii_NumKeys ++
is_Keys[ii_NumKeys] = as_Key

CHOOSE CASE Lower(Left(this.Describe(as_Key + ".ColType"),5))
CASE "char("
	is_KeyTypes[ii_NumKeys]		= "STRING"
	SetNull(is_KeyValues[ii_NumKeys])

CASE "date"
	is_KeyTypes[ii_NumKeys]		= "DATE"
	SetNull(is_KeyValues[ii_NumKeys])

CASE "datet"
	is_KeyTypes[ii_NumKeys]		= "DATETIME"
	SetNull(is_KeyValues[ii_NumKeys])

CASE "time", "times"
	is_KeyTypes[ii_NumKeys]		= "TIME"
	SetNull(is_KeyValues[ii_NumKeys])

CASE "decim", "numbe", "long", "ulong", "real"
	is_KeyTypes[ii_NumKeys]		= "NUMBER"
	SetNull(is_KeyValues[ii_NumKeys])
END CHOOSE

Return 1

end function

public subroutine of_settypicalservices (boolean ab_switch);IF ab_Switch THEN
	// Start base dw services.	//
	this.of_Setbase(True)
	
	// Start find service.	//
	this.of_SetFind(True)
	
	// Start filter service.	//
	this.of_SetFilter(True)
	
	// Set what names will be displayed in filter window. 0 = db, 1 = dw, 2 = Column Header.	//
	this.inv_filter.of_SetColumnNameSource(2)
	
	// Set what type of filter dialogue to use. 0 = PB Default, 1 = Extended, 2 = Simple.	//
	this.inv_filter.of_SetStyle(2)
	
	// Start sort service.	//
	this.of_SetSort(True)
	
	// Set what names will be displayed in sort window. 0 = db, 1 = dw, 2 = Column Header.	//
	this.inv_sort.of_SetColumnNameSource(2)
	
	// Set what type of sort dialogue to use. 0 = PB Default, 1 = DragDrop, 2 = Single, 3 = Multi.	//
	this.inv_sort.of_SetStyle(1)
	
	// Set to sort on displayed values, not data values.	//
	this.inv_sort.of_SetUseDisplay(True)
	
	// Start print preview service.	//
	this.of_SetPrintPreview(True)
	
	// Start row manager service.	//
	this.of_SetRowManager(True)
	
	// Set row manager to confirm deletes.	//
	this.inv_rowmanager.of_SetConfirmOnDelete(True)
ELSE
	// Stop base dw services.	//
	this.of_Setbase(False)
	
	// Stop find service.	//
	this.of_SetFind(False)
	
	// Stop filter service.	//
	this.of_SetFilter(False)
	
	// Stop sort service.	//
	this.of_SetSort(False)
	
	// Stop print preview service.	//
	this.of_SetPrintPreview(False)
	
	// Stop row manager service.	//
	this.of_SetRowManager(False)
END IF

end subroutine

public subroutine of_displayerror (integer ai_Row, string as_Column, string as_Message);this.ScrollToRow(ai_Row)
this.SetColumn(as_Column)
this.SelectText(1,9999)

MessageBox(parent.Tag,as_Message,Exclamation!)

this.SetFocus()

end subroutine

event dberror;// OVERRIDE.	//

w_master	lw_Parent
boolean	lb_Saving

// Check for "Not Connected" dberrors.	//
IF sqldbcode = -2 THEN
	// Determine IF the window is in the save process. //
	this.of_GetParentWindow(lw_Parent)

	IF IsValid(lw_Parent) THEN
		IF lw_Parent.TriggerEvent("pfc_descendant") = 1 THEN
			lb_Saving = lw_Parent.of_GetSaveStatus()
		END IF
	END IF

	IF NOT lb_Saving THEN
		IF sqldbcode <> -2 THEN
			MessageBox("DataBase Connection Error","The connection to the database has " + &
					"been lost.~r~n~r~nReconnect using the Reconnect option under the File " + &
					"menu, THEN close this window and try opening it again.",StopSign!)
		ELSE
			MessageBox("DataBase Connection Error","The connection to the database has " + &
					"been lost.~r~n~r~nReconnect may not work until network connections " + &
					"are restored, please try again later.",StopSign!)
		END IF
	ELSE
		IF sqldbcode <> -2 THEN
			MessageBox("DataBase Connection Error","The connection to the database has " + &
					"been lost.~r~n~r~nReconnect using the Reconnect option under the File " + &
					"menu and try saving again.",StopSign!)
		ELSE
			MessageBox("DataBase Connection Error","The connection to the database has " + &
					"been lost.~r~n~r~nReconnect may not work until network connections " + &
					"are restored, please try again later.",StopSign!)
		END IF
	END IF

	// Post transaction logging to prevent rollback in window's pfc_postupdate.	//
//	Post f_transactionlog(parent.ClassName(),parent.Tag,"Update Failed",sqlerrtext,sqldbcode)
	
	Return 1

ELSEIF sqldbcode = -3 THEN
	MessageBox(parent.Tag,'Values in this window have been updated since retrieval.  Changes can no' + &
					' longer be saved. ~n~nClose and reopen window to reenter data.',StopSign!)

	// Post transaction logging to prevent rollback in window's pfc_postupdate.	//
//	Post f_transactionlog(parent.ClassName(),parent.Tag,"Update Failed",sqlerrtext,sqldbcode)

	Return 1
ELSE
	// Post transaction logging to prevent rollback in window's pfc_postupdate.	//
//	Post f_transactionlog(parent.ClassName(),parent.Tag,"Update Failed",sqlerrtext,sqldbcode)

	Return super::Event dberror(sqldbcode,sqlerrtext,sqlsyntax,buffer,row)
END IF

end event

event retrieveend;call super::retrieveend;int			li_Index, &
				li_Row, &
				li_RC, &
				li_Pos
string		ls_Find
u_dw			ldw_Details[]

IF ii_NumKeys < 1 THEN
	IF ib_SetRedraw THEN
		this.SetRedraw(True)
	END IF

	Return
END IF

li_RC = this.RowCount()

IF li_RC < 1 THEN
	IF ib_SetRedraw THEN
		this.SetRedraw(True)
	END IF

	Return
END IF

// This script won't work on linked dw's unless this is the root dw.	//
IF IsValid(inv_linkage) THEN
	IF NOT inv_linkage.of_IsRoot() THEN
		IF ib_SetRedraw THEN
			this.SetRedraw(True)
		END IF

		Return
	END IF
END IF

DO WHILE li_Index < ii_NumKeys
	li_Index ++

	// Single and double quotes and tildes will not work in find statement.	//
	IF Pos(is_KeyValues[li_Index],"'") > 0 OR Pos(is_KeyValues[li_Index],'"') > 0 THEN
		li_Pos = Pos(is_KeyValues[li_Index],"'")

		// Put a tilde before every single quote found.	//
		DO WHILE li_Pos > 0
			is_KeyValues[li_Index] = Mid(is_KeyValues[li_Index],1,li_Pos - 1) + &
												"~~" + Mid(is_KeyValues[li_Index],li_Pos,99999)

			li_Pos = Pos(is_KeyValues[li_Index],"'",li_Pos)
		LOOP

		li_Pos = Pos(is_KeyValues[li_Index],'"')

		// Put a tilde before every double quote found.	//
		DO WHILE li_Pos > 0
			is_KeyValues[li_Index] = Mid(is_KeyValues[li_Index],1,li_Pos - 1) + &
												"~~" + Mid(is_KeyValues[li_Index],li_Pos,99999)
			li_Pos += 2

			li_Pos = Pos(is_KeyValues[li_Index],'"',li_Pos)
		LOOP

		li_Pos = Pos(is_KeyValues[li_Index],'~~')

		// Put a tilde before every tilde found.	//
		DO WHILE li_Pos > 0
			is_KeyValues[li_Index] = Mid(is_KeyValues[li_Index],1,li_Pos - 1) + &
												"~~" + Mid(is_KeyValues[li_Index],li_Pos,99999)
			li_Pos += 2

			li_Pos = Pos(is_KeyValues[li_Index],'~~',li_Pos)
		LOOP
	END IF

	CHOOSE CASE is_KeyTypes[li_Index]
	CASE "STRING"
		IF NOT IsNull(is_KeyValues[li_Index]) AND Trim(is_KeyValues[li_Index]) <> "" THEN
			ls_Find += is_Keys[li_Index] + "=~"" + is_KeyValues[li_Index] + "~" and "
		END IF
	CASE "NUMBER"
		IF NOT IsNull(is_KeyValues[li_Index]) AND Trim(is_KeyValues[li_Index]) <> "" THEN
			ls_Find += is_Keys[li_Index] + "=" + is_KeyValues[li_Index] + " and "
		END IF
	CASE "DATETIME"
		IF NOT IsNull(is_KeyValues[li_Index]) AND Trim(is_KeyValues[li_Index]) <> "" THEN
			ls_Find += is_Keys[li_Index] + "=DateTime('" + is_KeyValues[li_Index] + "') and "
		END IF
	CASE "DATE"
		IF NOT IsNull(is_KeyValues[li_Index]) AND Trim(is_KeyValues[li_Index]) <> "" THEN
			ls_Find += is_Keys[li_Index] + "=Date('" + is_KeyValues[li_Index] + "') and "
		END IF
	CASE "TIME"
		IF NOT IsNull(is_KeyValues[li_Index]) AND Trim(is_KeyValues[li_Index]) <> "" THEN
			ls_Find += is_Keys[li_Index] + "=Time('" + is_KeyValues[li_Index] + "') and "
		END IF
	END CHOOSE
LOOP

IF ls_Find <> "" THEN
	ls_Find = Mid(ls_Find,1,Len(ls_Find) - 5)

	li_Index = this.Find(ls_Find,1,li_RC)

	this.ScrollToRow(li_Index)
END IF

IF ib_SetRedraw THEN
	this.SetRedraw(True)

	// Turn on redraw for linked dw's.	//
	IF IsValid(inv_linkage) THEN
		li_RC = this.inv_linkage.of_GetDetails(ldw_Details)

		FOR li_Index = 1 TO li_RC
			ldw_Details[li_Index].SetRedraw(True)
		NEXT
	END IF
END IF

end event

event retrievestart;call super::retrievestart;int			li_Index, &
				li_Row, &
				li_Details
u_dw			ldw_Details[]

IF ii_NumKeys < 1 THEN
	Return
END IF

li_Row = this.GetRow()

IF li_Row < 1 OR li_Row > this.RowCount() THEN
	Return
END IF

// This script won't work on linked dw's unless this is the root dw.	//
IF IsValid(this.inv_linkage) THEN
	IF NOT this.inv_linkage.of_IsRoot() THEN
		Return
	END IF

	IF ib_SetRedraw THEN
		// Turn off redraw for linked dw's.	//
		li_Details = this.inv_linkage.of_GetDetails(ldw_Details)

		FOR li_Index = 1 TO li_Details
			ldw_Details[li_Index].SetRedraw(False)
		NEXT

		// Reset for next loop.	//
		li_Index = 0
	END IF
END IF

DO WHILE li_Index < ii_NumKeys
	li_Index ++

	CHOOSE CASE is_KeyTypes[li_Index]
	CASE "STRING"
		is_KeyValues[li_Index] = this.GetItemString(li_Row,is_Keys[li_Index])
	CASE "DATE"
		is_KeyValues[li_Index] = String(this.GetItemDate(li_Row,is_Keys[li_Index]))
	CASE "DATETIME"
		is_KeyValues[li_Index] = String(this.GetItemDateTime(li_Row,is_Keys[li_Index]))
	CASE "TIME"
		is_KeyValues[li_Index] = String(this.GetItemTime(li_Row,is_Keys[li_Index]))
	CASE "NUMBER"
		is_KeyValues[li_Index] = String(this.GetItemNumber(li_Row,is_Keys[li_Index]))
	END CHOOSE
LOOP

IF ib_SetRedraw THEN
	this.SetRedraw(False)
END IF

end event

event constructor;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

end event

event sqlpreview;call super::sqlpreview;IF sqltype = PreviewUpdate! OR sqltype = PreviewInsert! OR sqltype = PreviewDelete! THEN
//	f_transactionlog(parent.ClassName(),parent.Tag,sqlsyntax,"",0)
END IF

end event

event pfc_populatedddw;call super::pfc_populatedddw;adwc_obj.SetTransObject(sqlca)

Return adwc_obj.Retrieve()

end event

