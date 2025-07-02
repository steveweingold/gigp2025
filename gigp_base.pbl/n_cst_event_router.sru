//objectcomments Service to trigger registered events on suscribing objects as needed.
forward
global type n_cst_event_router from nonvisualobject
end type
end forward

global type n_cst_event_router from nonvisualobject
end type
global n_cst_event_router n_cst_event_router

type variables
Private:
  str_event_router istr_Event_Router[]
  int                       ii_Last_Element
end variables

forward prototypes
public function integer of_unregisterevent (string as_event_id)
public function integer of_subscribe (powerobject apo_subscriber, string as_event_id)
public function integer of_unsubscribe (powerobject apo_subscriber, string as_event_id)
public function integer of_publishevent (string as_event_id)
public function integer of_repackevents (integer ai_index)
public function integer of_repacksubscribers (ref str_event_router astr_event_router, integer ai_index)
public function integer of_registerevent (string as_event_id)
end prototypes

public function integer of_unregisterevent (string as_event_id);int	li_Index

// Check parameters.	//
IF ii_Last_Element <= 0 OR IsNull(as_Event_ID) OR Trim(as_Event_ID) = "" THEN
	// Bad parameters.	//
	Return -1
END IF

FOR li_Index = 1 TO ii_Last_Element
	IF istr_Event_Router[li_Index].Event_ID = as_Event_ID THEN
		// of_RepackEvents() will move all elements after li_Index	//
		// down one spot, thereby removing the event.					//
		Return of_RepackEvents(li_Index)
	END IF
NEXT

// Event not found.	//
Return -2

end function

public function integer of_subscribe (powerobject apo_subscriber, string as_event_id);int	li_Index = 1, &
		li_PO_Index

// Check parameters.	//
IF ii_Last_Element <= 0 OR IsNull(as_Event_ID) OR Trim(as_Event_ID) = "" OR &
			NOT IsValid(apo_Subscriber) THEN
	// Bad parameters.	//
	Return -1
END IF

// Determine index of requested event.	//
DO WHILE istr_Event_Router[li_Index].Event_ID <> as_Event_ID AND &
		li_Index < ii_Last_Element
	li_Index ++
LOOP

// Requested event not found.	//
IF istr_Event_Router[li_Index].Event_ID <> as_Event_ID THEN
	Return -2
END IF

li_PO_Index = UpperBound(istr_Event_Router[li_Index].Subscribers) + 1

IF li_PO_Index <= 0 THEN
	// Weird error.	//
	Return -3
END IF

istr_Event_Router[li_Index].Subscribers[li_PO_Index] = apo_Subscriber

Return li_PO_Index

end function

public function integer of_unsubscribe (powerobject apo_subscriber, string as_event_id);int	li_Index		= 1, &
		li_Sub_Index	= 1, &
		li_UB

// Check parameters.	//
IF ii_Last_Element <= 0 OR IsNull(as_Event_ID) OR Trim(as_Event_ID) = "" OR &
			NOT IsValid(apo_Subscriber) THEN
	// Bad parameters.	//
	Return -1
END IF

// Determine index of requested event.	//
DO WHILE istr_Event_Router[li_Index].Event_ID <> as_Event_ID AND &
		li_Index < ii_Last_Element
	li_Index ++
LOOP

// Requested event not found.	//
IF istr_Event_Router[li_Index].Event_ID <> as_Event_ID THEN
	Return -2
END IF

li_UB = UpperBound(istr_Event_Router[li_Index].Subscribers)

// No subscribers.	//
IF li_UB <= 0 THEN
	Return -3
END IF

// Determine index of subscriber.	//
DO WHILE istr_Event_Router[li_Index].Subscribers[li_Sub_Index] <> apo_Subscriber AND &
		li_Sub_Index < li_UB
	li_Sub_Index ++
LOOP

// Requested subscriber not found.	//
IF istr_Event_Router[li_Index].Subscribers[li_Sub_Index] <> apo_Subscriber THEN
	Return -4
END IF

// Call of_RepackSubscribers to remove this subscriber from the array.	//
Return of_RepackSubscribers(istr_Event_Router[li_Index],li_Sub_Index)

end function

public function integer of_publishevent (string as_event_id);int	li_Index = 1, &
		li_PO_Index, &
		li_UB, &
		li_RC

// Check parameters.	//
IF ii_Last_Element <= 0 OR IsNull(as_Event_ID) OR Trim(as_Event_ID) = "" THEN
	// Bad parameters.	//
	Return -1
END IF

// Determine index of requested event.	//
DO WHILE istr_Event_Router[li_Index].Event_ID <> as_Event_ID AND &
		li_Index < ii_Last_Element
	li_Index ++
LOOP

// Requested event not found.	//
IF istr_Event_Router[li_Index].Event_ID <> as_Event_ID THEN
	Return -2
END IF

li_UB = UpperBound(istr_Event_Router[li_Index].Subscribers)

IF li_UB <= 0 THEN
	// No subscribers.	//
	Return 0
END IF

// Trigger the event in all subscribers.	//
FOR li_PO_Index = li_UB TO 1 STEP -1
	IF NOT IsNull(istr_Event_Router[li_Index].Subscribers[li_PO_Index]) THEN
		istr_Event_Router[li_Index].Subscribers[li_PO_Index].TriggerEvent &
				(istr_Event_Router[li_Index].Event_ID)
	END IF
NEXT

Return 0

end function

public function integer of_repackevents (integer ai_index);// The only way to remove an element of a variable size array is	//
// to set it equal to another array that has the proper size.		//

int					li_Index = 1
str_event_router	lstr_Init[]

// Check parms.	//
IF ai_Index <= 0 OR ai_Index > ii_Last_Element OR ii_Last_Element <= 0 THEN
	// Bad parms.	//
	Return -1
END IF

// Move data to init array.	//
DO WHILE	li_Index < ai_Index
	lstr_Init[li_Index] = istr_Event_Router[li_Index]

	li_Index ++
LOOP

// Move all elements after ai_Index into init array.	//
IF ai_Index <> ii_Last_Element THEN
	DO WHILE ai_Index < ii_Last_Element
		lstr_Init[ai_Index] = istr_Event_Router[ai_Index + 1]

		ai_Index ++
	LOOP
END IF

// Decrement last element counter.	//
ii_Last_Element --

// Set instance array equal to init array. This changes the upperbound.	//
istr_Event_Router = lstr_Init

Return ii_Last_Element

end function

public function integer of_repacksubscribers (ref str_event_router astr_event_router, integer ai_index);// The only way to remove an element of a variable size array is	//
// to set it equal to another array that has the proper size.		//

// astr_Event_Router is a single element of istr_Event_Router,		//
// passed in by reference. This function will repack the				//
// subscriber array within astr_Event_Router.							//

int					li_Index = 1, &
						li_UB
str_event_router	lstr_Init

li_UB = UpperBound(astr_Event_Router.Subscribers)

// Check parms.	//
IF ai_Index <= 0 OR ai_Index > li_UB OR li_UB <= 0 THEN
	// Bad parms.	//
	Return -1
END IF

// Move data to init array.	//
lstr_Init.Event_ID = astr_Event_Router.Event_ID

DO WHILE	li_Index < ai_Index
	lstr_Init.Subscribers[li_Index] = astr_Event_Router.Subscribers[li_Index]

	li_Index ++
LOOP

// Move all elements after ai_Index into init array.	//
IF ai_Index <> li_UB THEN
	DO WHILE ai_Index < li_UB
		lstr_Init.Subscribers[ai_Index] = astr_Event_Router.Subscribers[ai_Index + 1]

		ai_Index ++
	LOOP
END IF

// Set instance array element equal to init array. This changes the upperbound.	//
astr_Event_Router = lstr_Init

Return li_UB - 1

end function

public function integer of_registerevent (string as_event_id);// Check parms.	//
IF IsNull(as_Event_ID) OR Trim(as_Event_ID) = "" THEN
	Return -1
END IF

ii_Last_Element ++

IF ii_Last_Element <= 0 THEN
	Return -2
END IF

// Add event to structure.	//
istr_Event_Router[ii_Last_Element].Event_ID		= as_Event_ID

Return 0

end function

on n_cst_event_router.create
TriggerEvent( this, "constructor" )
end on

on n_cst_event_router.destroy
TriggerEvent( this, "destructor" )
end on

event constructor;//////////////////////////////////////////////////////////////////////////
//	Modification Log																		//
//////////////////////////////////////////////////////////////////////////
//	Date of Change		Developer		Change Description						//
//	--------------		---------		------------------						//
//																								//
//////////////////////////////////////////////////////////////////////////

end event

