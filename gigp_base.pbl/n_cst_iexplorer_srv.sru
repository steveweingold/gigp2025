//objectcomments Ole object to connect to word and merge uds data into word docs
forward
global type n_cst_iexplorer_srv from oleobject
end type
end forward

global type n_cst_iexplorer_srv from oleobject
end type
global n_cst_iexplorer_srv n_cst_iexplorer_srv

type variables
Private:
	String 	is_AppClassName = 'InternetExplorer.Application'
	Boolean 	ib_Connected = False

end variables

forward prototypes
public function boolean of_isconnected ()
public function integer of_disconnect ()
public function integer of_connect ()
public function integer of_linktourl (string as_url, boolean ab_visible)
public function integer of_close ()
end prototypes

public function boolean of_isconnected ();//************************************************************
//	Desc:	Returns ib_Connected.
//
//************************************************************
//	Date		Developer			Description
//------------------------------------------------------------
//	3/2004	Mark Callahan		Created
//************************************************************

Return this.ib_Connected	
	
end function

public function integer of_disconnect ();//************************************************************
//	Desc:	Disconnect this ole object from IE
//
//************************************************************
//	Date		Developer			Description
//------------------------------------------------------------
//	3/2004	Mark Callahan		Created
//************************************************************

If this.of_IsConnected() Then
	Return this.DisconnectObject()
End If
	


end function

public function integer of_connect ();//************************************************************
//	Desc:	Connect this ole object to Internet Explorer
//
//************************************************************
//	Date		Developer			Description
//------------------------------------------------------------
//	3/2004	Mark Callahan		Created
//************************************************************
Integer	li_rc
String	ls_Msg

If Not this.Of_IsConnected() Then
	//Connect to IE
	If this.ConnectToNewObject(This.is_AppClassName) <> 0  Then
		ls_Msg = 'Error opening Internet Explorer.'
		GoTo Error
	End If
	
End If

this.ib_Connected = True

Return 1

Error:
	If ls_Msg > '' Then
		MessageBox("ERROR!", ls_Msg)
	End If
	
	Return -1

end function

public function integer of_linktourl (string as_url, boolean ab_visible);//************************************************************
//	Desc:	Pass URL to IE for execution.
//
//************************************************************
//	Date		Developer			Description
//------------------------------------------------------------
//	6/2004	Mark Callahan		Created
//************************************************************
Integer	li_rc
String	ls_Msg

If Not this.of_IsConnected() Then
	ls_Msg = 'Internet Explorer is not connected.'
	Goto Error
End If

this.Navigate(as_URL)

If ab_Visible Then
	this.Visible = True
	this.WindowState = 1
	this.Activate()
Else
	this.Visible = False
End If

Return 1
	
Error:
	If ls_Msg > '' Then
		MessageBox("ERROR!", ls_Msg)	
	End If
	
	Return -1
	
	
end function

public function integer of_close ();//************************************************************
//	Desc:	Closes the associated IE application.
//
//************************************************************
//	Date		Developer			Description
//------------------------------------------------------------
//	6/2004	Mark Callahan		Created
//************************************************************
Integer	li_rc
String	ls_Msg

If this.of_IsConnected() Then
	this.Close()
	
	this.of_DisConnect()
End If

Return 1

//NoAction:
//	If ls_Msg > '' Then
//		f_DisplayMessage(c.MSG_INFO, '', ls_Msg)
//	End If
//	
//	Return c.RC_NOACTION
//	
//Error:
//	If ls_Msg > '' Then
//		f_DisplayMessage(c.MSG_SYSERROR, '', ls_Msg)
//	End If
//	
//	Return c.RC_FAILURE
//	
//	
end function

on n_cst_iexplorer_srv.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_iexplorer_srv.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event destructor;//************************************************************
//	Desc:	Destroy objects.
//
//************************************************************
//	Date		Developer			Description
//------------------------------------------------------------
//	3/2004	Mark Callahan		Created
//************************************************************

this.of_DisConnect()

end event

