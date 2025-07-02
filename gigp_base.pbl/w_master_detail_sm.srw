//objectcomments Master Detail ancestor window. Single master row, multiple detail rows.
forward
global type w_master_detail_sm from w_master_detail_mm
end type
type dw_1 from u_dw within w_master_detail_sm
end type
end forward

global type w_master_detail_sm from w_master_detail_mm
long backcolor = 67108864
dw_1 dw_1
end type
global w_master_detail_sm w_master_detail_sm

type variables
Protected:

  any	ia_Key

  string	is_Key_Column, &
	is_Key_Type
end variables

on w_master_detail_sm.create
int iCurrent
call super::create
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
end on

on w_master_detail_sm.destroy
call super::destroy
destroy(this.dw_1)
end on

event open;call super::open;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

datawindowchild	ldwc

// Set up dw_1, which has an external datasource.	//
dw_1.of_SetTransObject(sqlca)
dw_1.of_SetUpdateable(False)

// Inserting a row will cause the dddw associated with column 1	//
// in dw_1 to retrieve.															//
dw_1.InsertRow(0)

// Determine the column name and data type of the key column in dw_1.	//
is_Key_Column	= dw_1.Describe("#1.name")
is_Key_Type		= Lower(Left(dw_1.Describe(is_Key_Column + ".ColType"),5))

// Get a handle for the dddw associated with column 1.	//
dw_1.GetChild(is_Key_Column,ldwc)

IF ldwc.RowCount() > 0 THEN
	// Cast ia_Key's datatype and set it equal to the first key in ldwc.	//
	CHOOSE CASE is_Key_Type
	CASE "char("												// CHARACTER DATATYPE.	//
		ia_Key = ldwc.GetItemString(1,1)
	CASE "date"													// DATE DATATYPE.			//
		ia_Key = ldwc.GetItemDate(1,1)
	CASE "datet"												// DATETIME DATATYPE.	//
		ia_Key = ldwc.GetItemDateTime(1,1)
	CASE "decim"												// DECIMAL DATATYPE.		//
		ia_Key = ldwc.GetItemDecimal(1,1)
	CASE "numbe", "long", "ulong", "real"				// NUMBER DATATYPE.		//
		ia_Key = ldwc.GetItemNumber(1,1)
	CASE "time", "times"										// TIME DATATYPE.			//
		ia_Key = ldwc.GetItemTime(1,1)
	END CHOOSE
ELSE
	// There are no master rows in the db. We still need to cast ia_Key's	//
	// datatype. Then we'll set it to null.											//
	CHOOSE CASE is_Key_Type
	CASE "char("												// CHARACTER DATATYPE.	//
		ia_Key = ""
	CASE "date"													// DATE DATATYPE.			//
		ia_Key = Date(Today())
	CASE "datet"												// DATETIME DATATYPE.	//
		ia_Key = DateTime(Today())
	CASE "decim"												// DECIMAL DATATYPE.		//
		ia_Key = 0.0
	CASE "numbe", "long", "ulong", "real"				// NUMBER DATATYPE.		//
		ia_Key = 0
	CASE "time", "times"										// TIME DATATYPE.			//
		ia_Key = Now()
	END CHOOSE

	SetNull(ia_Key)
END IF

dw_1.SetItem(1,1,ia_Key)

end event

event ue_postsuccess;// OVERRIDE ANCESTOR.	//

datawindowchild	ldwc

dw_1.SetRedraw(False)

// Refresh dw_1 because we may have inserted a 	//
// new master row in the db.							//
dw_1.Reset()
dw_1.InsertRow(0)

dw_1.GetChild(is_Key_Column,ldwc)

ldwc.SetTransObject(sqlca)
ldwc.Retrieve()

// If we deleted all master rows from the db, set ia_Key = null.	//
IF ldwc.RowCount() <= 0 THEN
	// Even though we set ia_Key = null, it still retains it's datatype.	//
	SetNull(ia_Key)
END IF

dw_1.SetItem(1,1,ia_Key)

dw_1.SetRedraw(True)

call super::ue_postsuccess

end event

event pfc_postopen;// OVERRIDE ANCESTOR.	//

// Turn off redraw to prevent screen flicker.	//
this.SetRedraw(False)

call super::pfc_postopen

// dw_master is one row only. No need for the following.	//
dw_master.SetRowFocusIndicator(Off!)
dw_master.of_SetSort(False)
dw_master.of_SetFilter(False)
dw_master.of_SetFind(False)

// Turn on redraw.	//
this.SetRedraw(True)

end event

event ue_reconnect;call super::ue_reconnect;// This is called from f_reconnect().	//

dw_1.of_SetTransObject(sqlca)

end event

type dw_master from w_master_detail_mm`dw_master within w_master_detail_sm
integer x = 1125
integer width = 1687
integer taborder = 20
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
end type

event dw_master::pfc_retrieve;// OVERRIDE ANCESTOR.	//

Return this.Retrieve(ia_Key)

end event

event dw_master::pfc_insertrow;// OVERRIDE.	//

// Only one row is allowed in dw_master.	//
IF this.RowCount() = 1 THEN
	// There's already a row here. Reset dw_master and set dw_1's key	//
	// value to null before inserting new row.								//
	this.Reset()

	SetNull(ia_Key)
	dw_1.SetItem(1,1,ia_Key)
END IF

Return super::Event pfc_insertrow()

end event

event dw_master::pfc_addrow;// OVERRIDE.	//

Return this.Event pfc_insertrow()

end event

type dw_detail from w_master_detail_mm`dw_detail within w_master_detail_sm
integer x = 59
integer width = 2752
integer taborder = 30
end type

type dw_1 from u_dw within w_master_detail_sm
integer x = 46
integer y = 120
integer width = 841
integer height = 116
integer taborder = 10
boolean vscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event itemchanged;call super::itemchanged;int					li_Answer
datawindowchild	ldwc
string				ls_Find
powerobject			lpo_Updates[]

// Check for pending updates.	//

// Use pfc_UpdatesPendingRef() instead of pfc_UpdatesPending()	//
// to avoid affecting the object's ipo_PendingUpdates array.	//
IF parent.Event pfc_UpdatesPendingRef(parent.control,lpo_Updates) > 0 THEN
	li_Answer = MessageBox(parent.Tag,"Save Changes?",Question!,YesNoCancel!,1)

	CHOOSE CASE li_Answer
	CASE 1
		IF parent.Event pfc_Save() < 0 THEN
			Return 1
		END IF
	CASE 3
		Return 1
	END CHOOSE
END IF

this.GetChild(is_Key_Column,ldwc)

IF IsNull(data) AND ldwc.RowCount() > 0 THEN
	Return 1
END IF

// Build find string.	//
CHOOSE CASE is_Key_Type
CASE "char("
	ls_Find = is_Key_Column + " = ~"" + data + "~""
CASE "time", "times"
	ls_Find = is_Key_Column + " = Time('" + data + "')"
CASE "datet"
	ls_Find = is_Key_Column + " = DateTime('" + data + "')"
CASE "date"
	ls_Find = is_Key_Column + " = Date('" + data + "')"
CASE "decim", "numbe", "long", "ulong", "real"
	ls_Find = is_Key_Column + " = " + data
END CHOOSE

IF ldwc.Find(ls_Find,1,999999) <= 0 THEN
	MessageBox("Invalid Selection",data + " is not a valid value.",Exclamation!)
	Return 1
END IF

CHOOSE CASE is_Key_Type
CASE "char("												// CHARACTER DATATYPE.	//
	ia_Key = data
CASE "date"													// DATE DATATYPE.			//
	ia_Key = Date(data)
CASE "datet"												// DATETIME DATATYPE.	//
	ia_Key = DateTime(data)
CASE "decim"												// DECIMAL DATATYPE.		//
	ia_Key = Dec(data)
CASE "numbe", "long", "ulong", "real"				// NUMBER DATATYPE.		//
	ia_Key = Long(data)
CASE "time", "times"										// TIME DATATYPE.			//
	ia_Key = Time(data)
END CHOOSE

dw_1.SetItem(1,1,ia_Key)

dw_detail.SetRedraw(False)

dw_master.inv_Linkage.of_Retrieve()

dw_detail.SetRedraw(True)

end event

event itemerror;call super::itemerror;this.SetItem(1,1,ia_Key)

Return 1

end event

event losefocus;call super::losefocus;IF this.GetText() <> String(ia_Key) THEN
	this.TriggerEvent(ItemChanged!)
END IF

end event

event pfc_insertrow;// OVERRIDE.	//

Return dw_master.Event pfc_InsertRow()

end event

event pfc_deleterow;// OVERRIDE.	//

Return dw_master.Event pfc_DeleteRow()

end event

event pfc_addrow;// OVERRIDE.	//

Return dw_master.Event pfc_AddRow()

end event

