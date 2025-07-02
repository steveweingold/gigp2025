forward
global type w_smallgrantsconversion from window
end type
type rb_contractors from radiobutton within w_smallgrantsconversion
end type
type rb_applicants from radiobutton within w_smallgrantsconversion
end type
type st_unmatchedtotal from statictext within w_smallgrantsconversion
end type
type st_2 from statictext within w_smallgrantsconversion
end type
type cb_2 from commandbutton within w_smallgrantsconversion
end type
type st_1 from statictext within w_smallgrantsconversion
end type
type pb_1 from picturebutton within w_smallgrantsconversion
end type
type pb_save from picturebutton within w_smallgrantsconversion
end type
type cb_1 from commandbutton within w_smallgrantsconversion
end type
type dw_log from u_dw within w_smallgrantsconversion
end type
type gb_2 from groupbox within w_smallgrantsconversion
end type
type gb_3 from groupbox within w_smallgrantsconversion
end type
type dw_contractors from u_dw within w_smallgrantsconversion
end type
type dw_applicants from u_dw within w_smallgrantsconversion
end type
type gb_1 from groupbox within w_smallgrantsconversion
end type
end forward

global type w_smallgrantsconversion from window
integer width = 5298
integer height = 3256
boolean titlebar = true
string title = "GIGP to Small Grants Conversion"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
windowanimationstyle closeanimation = leftslide!
rb_contractors rb_contractors
rb_applicants rb_applicants
st_unmatchedtotal st_unmatchedtotal
st_2 st_2
cb_2 cb_2
st_1 st_1
pb_1 pb_1
pb_save pb_save
cb_1 cb_1
dw_log dw_log
gb_2 gb_2
gb_3 gb_3
dw_contractors dw_contractors
dw_applicants dw_applicants
gb_1 gb_1
end type
global w_smallgrantsconversion w_smallgrantsconversion

type variables
long il_gigpid, il_projectid, il_projectphaseid, il_financingid, il_customerid, il_fundingid
boolean ib_cancel = False
end variables

forward prototypes
public function integer of_log (string as_message)
public function long of_createdatastore (ref n_ds ads_data, string as_sql)
public function long of_createapplicant ()
public function integer of_createcontacts ()
public function integer of_createcontracts ()
public function integer of_createpoliticaldistricts ()
public function integer of_createkeydates ()
public function integer of_createdisbursements ()
public function integer of_creategrantamounts ()
public function long of_createvendor (long al_vendorid)
public function integer of_createprojecttypes ()
public function integer of_createmetrics ()
public function integer of_createcfaitems ()
public function integer of_createnotes ()
public function integer of_createdesigncalcs ()
public function integer of_createchecklist ()
public function integer of_createroot ()
public function string of_createmunicode (string as_county, string as_type)
public function integer of_createbankinfo ()
public function integer of_getchecklistvalue (string as_checklistitem)
end prototypes

public function integer of_log (string as_message);long ll_row

ll_row = dw_log.InsertRow(0)

dw_log.SetItem(ll_row, 'message', as_message)

dw_log.ScrollToRow(ll_row)
	
Return 1
end function

public function long of_createdatastore (ref n_ds ads_data, string as_sql);string ls_syntax, error_syntaxfromSQL, errorCreate
long ll_ret

ls_syntax = sqlca.SyntaxFromSQL(as_sql, 'Style(Type=Form)', error_syntaxfromSQL)

ads_data = CREATE n_ds
ads_data.CREATE(ls_syntax, errorCreate)
ads_data.SetTransObject(SQLCA)

ll_ret = ads_data.Retrieve()

Return ll_ret
end function

public function long of_createapplicant ();SetNull(il_customerid)

//Customer is stored in the gigp_application table now after running the matching process
select CustomerId
into :il_customerid
from gigp_application
where gigp_id = :il_gigpid;

If IsNull(il_customerid) then Return -1

Return il_customerid
end function

public function integer of_createcontacts ();string ls_sql,organization,prefix,first_name,last_name,mid_initial,suffix,full_name,salutation_name,ls_title,mail_address1,mail_address2,mail_address3,muni_type,county,mail_city,mail_state,mail_zip,phone_1,phone_2,fax,email,status,comments,duns_no,last_updated_by,contact_type
long ll_ret, ll_row, contact_id, ll_ContactId
DateTime last_updated_dt
Decimal gis_longitude,gis_latitude
n_ds lds_data

//Get distinct list of projet related contacts
ls_sql = "select c.contact_id,c.organization,c.prefix,c.first_name,c.last_name,c.mid_initial,c.suffix,c.full_name,c.salutation_name,c.title,c.mail_address1,c.mail_address2,c.mail_address3,c.muni_type,c.county,c.mail_city,c.mail_state,c.mail_zip,c.phone_1,c.phone_2,c.fax,c.email,c.status,c.comments,c.duns_no,c.gis_longitude,c.gis_latitude,c.last_updated_by,c.last_updated_dt,cl.contact_type from gigp_contacts c, gigp_contact_links cl where c.contact_id = cl.contact_id and cl.gigp_id = " + String(il_gigpid) + " and contact_type not in ('APP', 'PLC', 'VEND', 'nysAssembly', 'nysSenate', 'usCongress', 'JAP')"

ll_ret = of_createdatastore(lds_data, ls_sql)

If ll_ret > 0 Then
	For ll_row = 1 to ll_ret
		//Get Contact data
		contact_id = lds_data.GetItemNumber(ll_row, 'contact_id')
		organization = lds_data.GetItemString(ll_row, 'organization')
		prefix = lds_data.GetItemString(ll_row, 'prefix')
		first_name = lds_data.GetItemString(ll_row, 'first_name')
		last_name = lds_data.GetItemString(ll_row, 'last_name')
		mid_initial = lds_data.GetItemString(ll_row, 'mid_initial')
		suffix = lds_data.GetItemString(ll_row, 'suffix')
		full_name = lds_data.GetItemString(ll_row, 'full_name')
		salutation_name = lds_data.GetItemString(ll_row, 'salutation_name')
		ls_title = lds_data.GetItemString(ll_row, 'title')
		mail_address1 = lds_data.GetItemString(ll_row, 'mail_address1')
		mail_address2 = lds_data.GetItemString(ll_row, 'mail_address2')
		mail_address3 = lds_data.GetItemString(ll_row, 'mail_address3')
		muni_type = lds_data.GetItemString(ll_row, 'muni_type')
		county = lds_data.GetItemString(ll_row, 'county')
		mail_city = lds_data.GetItemString(ll_row, 'mail_city')
		mail_state = lds_data.GetItemString(ll_row, 'mail_state')
		mail_zip = lds_data.GetItemString(ll_row, 'mail_zip')
		phone_1 = lds_data.GetItemString(ll_row, 'phone_1')
		phone_2 = lds_data.GetItemString(ll_row, 'phone_2')
		fax = lds_data.GetItemString(ll_row, 'fax')
		email = lds_data.GetItemString(ll_row, 'email')
		status = lds_data.GetItemString(ll_row, 'status')
		comments = lds_data.GetItemString(ll_row, 'comments')
		duns_no = lds_data.GetItemString(ll_row, 'duns_no')
		gis_longitude = Dec(lds_data.GetItemDecimal(ll_row, 'gis_longitude'))
		gis_latitude = Dec(lds_data.GetItemDecimal(ll_row, 'gis_latitude'))
		last_updated_by = lds_data.GetItemString(ll_row, 'last_updated_by')
		last_updated_dt = lds_data.GetItemDateTime(ll_row, 'last_updated_dt')
		contact_type = lds_data.GetItemString(ll_row, 'contact_type')
		
		//Find Search for Contact by first, last, and city???
		select Max(c.ContactId)
		Into :ll_ContactId
		from Contact c, ContactAddress a
		where c.ContactId = a.ContactId
		and Upper(c.FirstName) = Upper(first_name)
		and Upper(c.LastName) = Upper(last_name)
		and Upper(ca.City) = Upper(mail_city);
		
		//Add Contact if not found
		If IsNull(ll_ContactId) or ll_ContactId <= 0 Then
			//Create Contact
			INSERT INTO Contact
				,Organization
				,Prefix
				,FirstName
				,MiddleName
				,LastName
				,Suffix
				,FullName
				,SalutationName
				,Title
				,Phone1
				,Phone2
				,Fax
				,Email
				,EmailUnsubscribed
				,ElectedOfficial
				,TermExpiration
				,Comments
				,LastUpdatedDate
				,LastUpdatedBy
				,LegacySourceSystem
				LegacyContactId)
			VALUES
				(:organization
				,:prefix
				,:first_name
				,:mid_initial
				,:last_name
				,null
				,:full_name
				,:salutation_name
				,:ls_title
				,:phone_1
				,:phone_2
				,:fax
				,:email
				,0
				,0
				,null
				,'Small Grants Conversion'
				,getdate()
				,'SYSTEM'
				,'GIGP'
				,convert(varchar(:contact_id));
			
			Select @@Identity
			Into: ll_ContactId
			from Dual;
			
		End If
		
		//Create ContactLink - **Translate GIGP Contact Type to Hub Contact Type
		
//		Insert into ContactLink (ContactId, EntityName, EntityKey, ContactType, ContactSubType, LastUpdatedDate, LastUpdatedBy)
//		Values (:ll_ContactId, '??EntityName', '??EntityKey', '??ContactType', '??ContactSubType', getdate(), 'Small Grants Conversion');
		
		
	Next
	
	of_log(String(ll_ret) + ' Contacts added for GIGP ' + String(il_gigpid))
	
Else
	of_log('No Contacts found for GIGP ' + String(il_gigpid))
End If

Return 1
end function

public function integer of_createcontracts ();long ll_ret, ll_row, ll_contractor, ll_vendor, ll_contractid, ll_profess_contract_id, ll_holdcount, ll_holdrow, amended_id
integer amed_flag, mwbe_review_flag, lobby_hold_flag, lobby_cert_recd_flag, aecert_hold_flag, aecert_recd_flag
string ls_sql, ls_holdsql, eng_hold_type, hold_last_updated_by, hold_comments, contract_no, contract_type, contract_status, contract_comments, contract_last_updated_by
datetime hold_last_updated_dt, placed_dt, released_dt, contract_dt, up_approval_dt, approval_dt, issue_notice_award_dt, issue_notice_proceed_dt, received_dt, contract_last_updated_dt
decimal contract_amt, eligible_amt
n_ds lds_data, lds_holds


//Retrieve Contracts
ls_sql = "select * from gigp_professional_contracts where gigp_id = " + String(il_gigpid)
ll_ret = of_createdatastore(lds_data, ls_sql)

If ll_ret > 0 Then
	For ll_row = 1 to ll_ret
		//Get the GIGP Contact that is the vendor for this Contract
		ll_vendor = lds_data.GetItemNumber(ll_row, 'contact_id')
		
		//Pass the GIGP Contact that is the Vendor to get the Contractor
		ll_contractor = of_createvendor(ll_vendor)
		
		//Get values from Contract
		ll_profess_contract_id = lds_data.GetItemNumber(ll_row, 'profess_contract_id')
		amended_id = lds_data.GetItemNumber(ll_row, 'amended_id')
		contract_no = lds_data.GetItemString(ll_row, 'contract_no')
		contract_amt = lds_data.GetItemDecimal(ll_row, 'contract_amt')
		eligible_amt= lds_data.GetItemDecimal(ll_row, 'eligible_amt')
		contract_dt = lds_data.GetItemDateTime(ll_row, 'contract_dt')
		contract_type = lds_data.GetItemString(ll_row, 'contract_type')
		contract_status = lds_data.GetItemString(ll_row, 'contract_status')
		amed_flag = lds_data.GetItemNumber(ll_row, 'amend_flag')
		mwbe_review_flag = lds_data.GetItemNumber(ll_row, 'mwbe_review_flag')
		lobby_hold_flag = lds_data.GetItemNumber(ll_row, 'lobby_hold_flag')
		lobby_cert_recd_flag = lds_data.GetItemNumber(ll_row, 'lobby_cert_recd_flag')
		contract_comments = lds_data.GetItemString(ll_row, 'comments')
		up_approval_dt = lds_data.GetItemDateTime(ll_row, 'up_approval_dt')
		approval_dt = lds_data.GetItemDateTime(ll_row, 'approval_dt')
		issue_notice_award_dt = lds_data.GetItemDateTime(ll_row, 'issue_notice_award_dt')
		issue_notice_proceed_dt = lds_data.GetItemDateTime(ll_row, 'issue_notice_proceed_dt')
		received_dt = lds_data.GetItemDateTime(ll_row, 'received_dt')
		contract_last_updated_dt = lds_data.GetItemDateTime(ll_row, 'last_updated_dt')
		contract_last_updated_by = lds_data.GetItemString(ll_row, 'last_updated_by')
		aecert_hold_flag = lds_data.GetItemNumber(ll_row, 'aecert_hold_flag')
		aecert_recd_flag = lds_data.GetItemNumber(ll_row, 'aecert_recd_flag')

		
		
		//Create Contract OR Amendment
//		INSERT INTO Contract
//           (ContractorId
//     ContractNumber
//     ContractType
//     DepClearedAmount
//     UnpaidRetainage
//     CustomerId
//     Description
//     ExecutedNumber
//     CurrentExecutedAmount
//     CurrentExecutedDate
//     ConstructionComments
//     TechnicalComments
//     IneligibleForIup
//     IneligibleComments
//     TrackDocumentsAndVisits
//     AeAgreementStatus
//     NycPortfolioManager
//     DecPlansAndSpecsApprovalNa
//     LegacyEngContractId
//     LegacyLsContractId
//     LegacyGigpContractId
//     LastUpdatedDate
//     LastUpdatedBy)
//     VALUES
//           (<ContractorId, int,>
//     <ContractNumber, nvarchar(25),>
//     <ContractType, nvarchar(25),>
//     <DepClearedAmount, decimal(15,2),>
//     <UnpaidRetainage, decimal(15,2),>
//     <CustomerId, int,>
//     <Description, nvarchar(255),>
//     <ExecutedNumber, nvarchar(20),>
//     <CurrentExecutedAmount, decimal(15,2),>
//     <CurrentExecutedDate, datetime,>
//     <ConstructionComments, nvarchar(4000),>
//     <TechnicalComments, nvarchar(4000),>
//     <IneligibleForIup, bit,>
//     <IneligibleComments, nvarchar(4000),>
//     <TrackDocumentsAndVisits, bit,>
//     <AeAgreementStatus, nvarchar(25),>
//     <NycPortfolioManager, nvarchar(100),>
//     <DecPlansAndSpecsApprovalNa, bit,>
//     <LegacyEngContractId, int,>
//     <LegacyLsContractId, int,>
//     <LegacyGigpContractId, int,>
//     <LastUpdatedDate, datetime,>
//     <LastUpdatedBy, nvarchar(50),>)
//			  
//			  
//		INSERT INTO ContractAmendment
//           (ContractId
//     AmendmentNumber
//     AmendmentType
//     ContractDate
//     ApprovedDate
//     Status
//     Description
//     Comments
//     LastUpdatedDate
//     LastUpdatedBy)
//     VALUES
//           (<ContractId, int,>
//     <AmendmentNumber, nvarchar(10),>
//     <AmendmentType, nvarchar(50),>
//     <ContractDate, datetime,>
//     <ApprovedDate, datetime,>
//     <Status, nvarchar(255),>
//     <Description, nvarchar(2000),>
//     <Comments, nvarchar(2000),>
//     <LastUpdatedDate, datetime,>
//     <LastUpdatedBy, nvarchar(50),>)
			  
		
		select @@Identity
		into :ll_contractid
		from Dual;
		
		//Link Contract to Application
		
		
		//Get Engineering Holds
		ls_holdsql = 'select * from gigp_contract_eng_hold where profess_contract_id = ' + String(ll_profess_contract_id)
		ll_holdcount = of_createdatastore(lds_holds, ls_holdsql)
		
		If ll_holdcount > 0 Then
			For ll_holdrow = 1 to ll_holdcount
				eng_hold_type = lds_holds.GetItemString(ll_holdrow, 'eng_hold_type')
				placed_dt = lds_holds.GetItemDateTime(ll_holdrow, 'placed_dt')
				released_dt = lds_holds.GetItemDateTime(ll_holdrow, 'released_dt')
				hold_comments = lds_holds.GetItemString(ll_holdrow, 'comments')
				hold_last_updated_dt = lds_holds.GetItemDateTime(ll_holdrow, 'last_updated_dt')
				hold_last_updated_by = lds_holds.GetItemString(ll_holdrow, 'last_updated_by')
				
				
			Next
		End If
		
		
		
		
		
	Next
	
	of_log(String(ll_ret) + ' Professional Contracts added for GIGP ' + String(il_gigpid))
	
End If


Return 1
end function

public function integer of_createpoliticaldistricts ();string ls_sql, ls_code, ls_category, ls_desc
long ll_ret, ll_row
decimal ld_reqamt, ld_appamt
n_ds lds_data

//Get GIGP Political Districts. Will retrieve up to 3 (Senate, Assemble, Congress)
ls_sql = "select p.district_type, p.district_no from gigp_contacts c, gigp_political_districts p, gigp_contact_links cl where c.contact_id = p.contact_id and c.contact_id = cl.contact_id and p.census_yr = 2010 and cl.contact_type = 'PLC' and cl.gigp_id = " + String(il_gigpid)
ll_ret = of_createdatastore(lds_data, ls_sql)

If ll_ret > 0 Then
	For ll_row = 1 to ll_ret
		//Get values
		
		//Handle values in Hub table - ProjectDistrict
		

	Next
	
	of_log(String(ll_ret) + ' Political Districts added for GIGP ' + String(il_gigpid))
	
Else
	of_log('No Political Districts found for GIGP ' + String(il_gigpid))
	
End If

Return 1
end function

public function integer of_createkeydates ();long ll_ret, ll_row
DateTime ldt_date1, ldt_date2
string ls_sql, ls_code, ls_ind, ls_choice, ls_comments, ls_alttext
n_ds lds_data

ls_sql = "select * from gigp_key_dates where gigp_id = " + String(il_gigpid)

ll_ret = of_createdatastore(lds_data, ls_sql)

If ll_ret > 0 Then
	For ll_row = 1 to ll_ret
		ls_code = lds_data.GetItemString(ll_row, 'ref_code')
		ldt_date1 = lds_data.GetItemDateTime(ll_row, 'keydate_value')
		ldt_date2 = lds_data.GetItemDateTime(ll_row, 'keydate_value2')
		ls_ind = lds_data.GetItemString(ll_row, 'keydate_ind')
		ls_choice = lds_data.GetItemString(ll_row, 'keydate_choice')
		ls_comments = lds_data.GetItemString(ll_row, 'keydate_comments')
		ls_alttext = lds_data.GetItemString(ll_row, 'alternate_text')
		
		//Insert into Hub table

	Next
	
	of_log(String(ll_ret) + ' Key Dates inserted for GIGP ' + String(il_gigpid))
	
Else
	
	of_log('No Key Dates found for GIGP ' + String(il_gigpid))
	
End If

Return 1
end function

public function integer of_createdisbursements ();integer li_req
string ls_requestsql, ls_linesql, ls_comments, ls_releaseno, ls_updatedby, ls_transtype, ls_lineupdatedby, ls_invoice, ls_linecomments, ls_costcat
long ll_requestcount, ll_requestrow, ll_linecount, ll_linerow, ll_disb, ll_lock, ll_overridesplit, ll_professcontractid, ll_adjustid,  ll_proofpmt, ll_retainpaid
datetime ldt_received, ldt_doccomplete, ldt_toacct, ldt_finappr, ldt_releasedt, ldt_updateddt, ldt_lineupdateddt
decimal ld_reqamt, ld_ineligibleamt, ld_witheldamt, ld_netrequestamt, ld_eligibleamt, ld_retainedamt, ld_disbursedamt, ldt_invoicedt
decimal ld_fedamt, ld_stateamt, ld_releaseamt
n_ds lds_request, lds_line

//Going into Disbursement, DisbursementProject, DisbursementFunding, DisbursementProjectContractLine...

//Get Disbursement Requests and then Get Line Items
ls_requestsql = "select * from gigp_disbursement_request where gigp_id = " + String(il_gigpid)
ll_requestcount = of_createdatastore(lds_request, ls_requestsql)

If ll_requestcount > 0 Then
	
	For ll_requestrow = 1 to ll_requestcount
		//Get Disbursement Request data
		ll_disb = lds_request.GetItemNumber(ll_requestrow, 'disbursement_id')
		li_req = lds_request.GetItemNumber(ll_requestrow, 'request_no')
		ldt_received = lds_request.GetItemDateTime(ll_requestrow, 'received_dt')
		ldt_doccomplete = lds_request.GetItemDateTime(ll_requestrow, 'documents_complete_dt')
		ldt_toacct = lds_request.GetItemDateTime(ll_requestrow, 'to_accting_dt')
		ldt_finappr = lds_request.GetItemDateTime(ll_requestrow, 'finance_approval_dt')
		ls_releaseno = lds_request.GetItemString(ll_requestrow, 'release_no')
		ld_releaseamt = lds_request.GetItemDecimal(ll_requestrow, 'release_amt')
		ldt_releasedt = lds_request.GetItemDateTime(ll_requestrow, 'release_dt')
		ll_lock = lds_request.GetItemNumber(ll_requestrow, 'lock_flag')
		ls_comments = lds_request.GetItemString(ll_requestrow, 'comments')
		ldt_updateddt = lds_request.GetItemDateTime(ll_requestrow, 'last_updated_dt')
		ls_updatedby = lds_request.GetItemString(ll_requestrow, 'last_updated_by')
		ld_fedamt = lds_request.GetItemDecimal(ll_requestrow, 'federal_amt')
		ld_stateamt = lds_request.GetItemDecimal(ll_requestrow, 'state_amt')
		ll_overridesplit = lds_request.GetItemNumber(ll_requestrow, 'override_state_federal_split')
		
		//Insert Contract
		
		
		//Get Line Items		
		If ll_disb > 0 Then
			ls_linesql = 'select * from gigp_disbursement_amount where disbursement_id = ' + String(ll_disb)
			
			ll_linecount = of_createdatastore(lds_line, ls_linesql)
			
			If ll_linecount > 0 Then
				For ll_linerow = 1 to ll_linecount
					//Get Amounts
					ls_transtype = lds_line.GetItemString(ll_linerow, 'transaction_type')
					ls_costcat = lds_line.GetItemString(ll_linerow, 'cost_category')
					ll_professcontractid = lds_line.GetItemNumber(ll_linerow, 'professional_contract_id')
					ll_adjustid = lds_line.GetItemNumber(ll_linerow, 'adj_disbursement_amt_id')
					ld_reqamt = lds_line.GetItemDecimal(ll_linerow, 'requested_amt')
					ld_ineligibleamt = lds_line.GetItemDecimal(ll_linerow, 'ineligible_amt')
					ld_witheldamt = lds_line.GetItemDecimal(ll_linerow, 'withheld_amt')
					ld_netrequestamt = lds_line.GetItemDecimal(ll_linerow, 'netrequest_amt')
					ld_eligibleamt = lds_line.GetItemDecimal(ll_linerow, 'eligible_amt')
					ld_retainedamt = lds_line.GetItemDecimal(ll_linerow, 'retained_amt')
					ld_disbursedamt = lds_line.GetItemDecimal(ll_linerow, 'disbursed_amt')
					ls_invoice = lds_line.GetItemString(ll_linerow, 'invoice_no')
					ldt_invoicedt = lds_line.GetItemDecimal(ll_linerow, 'invoice_dt')
					ls_linecomments = lds_line.GetItemString(ll_linerow, 'comments')
					ll_proofpmt = lds_line.GetItemNumber(ll_linerow, 'proofof_pmt_flag')
					ll_retainpaid = lds_line.GetItemNumber(ll_linerow, 'retainage_pd_flag')
					ldt_lineupdateddt = lds_line.GetItemDateTime(ll_linerow, 'last_updated_dt')
					ls_lineupdatedby = lds_line.GetItemString(ll_linerow, 'last_updated_by')
					
					
					
					//Insert Line Items
					
					
				Next
				
			End If
			
		End If
		
	Next
	
	of_log(String(ll_requestcount) + ' Disbursement Requests added for GIGP ' + String(il_gigpid))
	
End If

Return 1
end function

public function integer of_creategrantamounts ();string ls_sql, ls_code, ls_category, ls_desc
long ll_ret, ll_row
decimal ld_reqamt, ld_appamt
n_ds lds_data

//Get GIGP Amounts
ls_sql = "select * from gigp_amounts where gigp_id = " + string(il_gigpid)
ll_ret = of_createdatastore(lds_data, ls_sql)

If ll_ret > 0 Then
	For ll_row = 1 to ll_ret
		ls_code = lds_data.GetItemString(ll_row, 'ref_code')
		ls_category = lds_data.GetItemString(ll_row, 'sub_category')
		ls_desc = lds_data.GetItemString(ll_row, 'amt_description')
		ld_reqamt = lds_data.GetItemDecimal(ll_row, 'ref_amt')
		ld_appamt = lds_data.GetItemDecimal(ll_row, 'approved_amt')
		
		//Handle values in Hub tables (insert? update?)
		

	Next
	
	of_log('Amounts added for GIGP ' + String(il_gigpid))
	
Else
	of_log('No Amounts found for GIGP ' + String(il_gigpid))
	
End If

Return 1
end function

public function long of_createvendor (long al_vendorid);long ll_ContractorId
string ls_vendor, ls_vendorsearch
n_cst_string ln_string

//Get Vendor Name from GIGP
Select organization
into :ls_vendor
from gigp_contacts
where contact_id = :al_vendorid;

ls_vendorsearch = Upper(ln_string.of_removewhitespace(ls_vendor))

//Search for Contractor
select Max(ContractorId)
into :ll_ContractorId
from Contractor
where SearchName = :ls_vendorsearch;

If ll_ContractorId > 0 Then
	
	of_log('Contractor ' + String(ll_ContractorId) + ' matched for Vendor: ' + ls_vendor)
	
Else
	of_log('Vendor: ' + ls_vendor + ' not found so creating new Contractor')
	
	//Create new Contractor if doesn't exist
	INSERT INTO Contractor
	           (Name
	           ,SearchName
	           ,MwbeCertifiedType
	           ,FederalIdNumber
	           ,SdvobControlNumber
	           ,Dbe
	           ,Comments
	           ,MwbeContractorId
	           ,LastUpdatedDate
	           ,LastUpdatedBy)
	     VALUES
	           (:ls_vendor
	           ,:ls_vendorsearch
	           ,null
	           ,null
	           ,null
	           ,0
	           ,'Small Grants Conversion'
	           ,null
	           ,getdate()
	           ,'SYSTEM';
	
	select @@Identity
	into :ll_ContractorId
	from Dual;
	
	of_log('Contractor ' + String(ll_ContractorId) + ' created for Vendor: ' + ls_vendor)
	
End If

Return ll_ContractorId
end function

public function integer of_createprojecttypes ();long ll_ret, ll_row
string ls_sql, ls_type
n_ds lds_data

ls_sql = 'select * from gigp_project_types where gigp_id = ' + String(il_gigpid)

ll_ret = of_createdatastore(lds_data, ls_sql)

If ll_ret > 0 Then
	For ll_row = 1 to ll_ret
		ls_type = lds_data.GetItemString(ll_row, 'project_type')
		
		//Insert...
		
		
	Next
	
End If

of_log(String(ll_ret) + ' Project Types created for ' + String(il_gigpid))

Return 1
end function

public function integer of_createmetrics ();long ll_ret, ll_row, metric_design_calc_id
string ls_sql, metric_category, metric_sub_category, metric_ref_code, metric_last_updated_by, metric_comments, metric_metric_source
decimal metric_metric_value
datetime metric_last_updated_dt
n_ds lds_data

//Create Metrics
ls_sql = 'select * from gigp_project_metrics where category = "projectMetric" and gigp_id = ' + String(il_gigpid)
ll_ret = of_createdatastore(lds_data, ls_sql)

If ll_ret > 0 Then
	For ll_row = 1 to ll_ret
		//Get values
		metric_category = lds_data.GetItemString(ll_row, 'category')
		metric_sub_category = lds_data.GetItemString(ll_row, 'sub_category')
		metric_ref_code = lds_data.GetItemString(ll_row, 'ref_code')
		metric_metric_value = lds_data.GetItemDecimal(ll_row, 'metric_value')
		metric_last_updated_by = lds_data.GetItemString(ll_row, 'last_updated_by')
		metric_last_updated_dt = lds_data.GetItemDateTime(ll_row, 'last_updated_dt')
		metric_comments = lds_data.GetItemString(ll_row, 'comments')
		metric_design_calc_id = lds_data.GetItemNumber(ll_row, 'design_calc_id')
		metric_metric_source = lds_data.GetItemString(ll_row, 'metric_source')

		
		//Insert...
		
		
	Next
End If

of_log(String(ll_ret) + ' Metrics created for ' + String(il_gigpid))

Return 1
end function

public function integer of_createcfaitems ();long ll_ret, ll_row
string ls_sql, grant_status, project_status, project_status_comment, event_notes, environmental_impact, last_updated_by
integer jobs_existing, jobs_retained, jobs_projected, percent_complete, jobs_created
datetime grant_closed_dt, event_date, last_updated_dt
decimal contract_award_amt
n_ds lds_data

ls_sql = 'select * from gigp_cfa_items where gigp_id = ' + String(il_gigpid)

ll_ret = of_createdatastore(lds_data, ls_sql)

If ll_ret > 0 Then
	For ll_row = 1 to ll_ret
		//Get values
		grant_closed_dt = lds_data.GetItemDateTime(ll_row, 'grant_closed_dt')
		grant_status = lds_data.GetItemString(ll_row, 'grant_status')
		project_status = lds_data.GetItemString(ll_row, 'project_status')
		project_status_comment = lds_data.GetItemString(ll_row, 'project_status_comment')
		event_date = lds_data.GetItemDateTime(ll_row, 'event_date')
		event_notes = lds_data.GetItemString(ll_row, 'event_notes')
		jobs_existing = lds_data.GetItemNumber(ll_row, 'jobs_existing')
		jobs_retained = lds_data.GetItemNumber(ll_row, 'jobs_retained')
		jobs_projected = lds_data.GetItemNumber(ll_row, 'jobs_projected')
		environmental_impact = lds_data.GetItemString(ll_row, 'environmental_impact')
		percent_complete = lds_data.GetItemNumber(ll_row, 'percent_complete')
		jobs_created = lds_data.GetItemNumber(ll_row, 'jobs_created')
		last_updated_dt = lds_data.GetItemDateTime(ll_row, 'last_updated_dt')
		last_updated_by = lds_data.GetItemString(ll_row, 'last_updated_by')
		contract_award_amt = lds_data.GetItemDecimal(ll_row, 'contract_award_amt')
		
		//PLUS SOME FROM gigp_application???
		
		//Insert... new Hub table to be determined
		
		
	Next

End If

of_log(String(ll_ret) + ' CFA Items created for ' + String(il_gigpid))

Return 1
end function

public function integer of_createnotes ();long ll_ret, ll_row
string ls_sql, note_category, note_type, user_id, comments
datetime note_dt
n_ds lds_data

//Handle Notes and Project Descriptions

ls_sql = 'select * from gigp_notes where gigp_id = ' + String(il_gigpid)

ll_ret = of_createdatastore(lds_data, ls_sql)

If ll_ret > 0 Then
	For ll_row = 1 to ll_ret
		//Get values
		note_dt = lds_data.GetItemDateTime(ll_row, 'note_dt')
		note_category = lds_data.GetItemString(ll_row, 'note_category')
		note_type = lds_data.GetItemString(ll_row, 'note_type')
		user_id = lds_data.GetItemString(ll_row, 'user_id')
		comments = lds_data.GetItemString(ll_row, 'comments')
		
		
		//Insert...
		
		
	Next
	
End If

of_log(String(ll_ret) + ' Notes created for ' + String(il_gigpid))

Return 1
end function

public function integer of_createdesigncalcs ();long ll_ret, ll_row, metric_design_calc_id, design_practice_no, ll_designcalccount, ll_designcalcrow, ll_metriccount, ll_metricrow, ll_designcalcid
string ls_sql, metric_category, metric_sub_category, metric_ref_code, metric_last_updated_by, metric_comments, metric_metric_source, design_practice_type, design_comments, design_last_updated_by
decimal metric_metric_value
datetime metric_last_updated_dt, design_last_updated_dt
n_ds lds_data, lds_designcalc, lds_metric

//Create Design Calcs where Design Calc --< Metrics
ls_sql = 'select * from gigp_design_calcs where  gigp_id = ' + String(il_gigpid)
ll_designcalccount = of_createdatastore(lds_designcalc, ls_sql)

If ll_designcalccount > 0 Then
	For ll_designcalcrow = 1 to ll_designcalccount
		//Get values
		ll_designcalcid = lds_designcalc.GetItemNumber(ll_designcalcrow, 'design_calc_id')
		design_practice_no = lds_designcalc.GetItemNumber(ll_designcalcrow, 'practice_no')
		design_practice_type = lds_designcalc.GetItemString(ll_designcalcrow, 'practice_type')
		design_comments = lds_designcalc.GetItemString(ll_designcalcrow, 'comments')
		design_last_updated_by = lds_designcalc.GetItemString(ll_designcalcrow, 'last_updated_by')
		design_last_updated_dt = lds_designcalc.GetItemDateTime(ll_designcalcrow, 'last_updated_dt')
		
		//Insert parent record
		
		
		//Get Metrics for that Design Calc
		ls_sql = 'select * from gigp_project_metrics where design_calc_id = ' + String(ll_designcalcid)
		ll_metriccount = of_createdatastore(lds_metric, ls_sql)
		
		If ll_metriccount > 0 Then
			For ll_metricrow = 1 to ll_metriccount
				//Get metric values
				metric_category = lds_data.GetItemString(ll_metricrow, 'category')
				metric_sub_category = lds_data.GetItemString(ll_metricrow, 'sub_category')
				metric_ref_code = lds_data.GetItemString(ll_metricrow, 'ref_code')
				metric_metric_value = lds_data.GetItemDecimal(ll_metricrow, 'metric_value')
				metric_last_updated_by = lds_data.GetItemString(ll_metricrow, 'last_updated_by')
				metric_last_updated_dt = lds_data.GetItemDateTime(ll_metricrow, 'last_updated_dt')
				metric_comments = lds_data.GetItemString(ll_metricrow, 'comments')
				metric_design_calc_id = lds_data.GetItemNumber(ll_metricrow, 'design_calc_id')
				metric_metric_source = lds_data.GetItemString(ll_metricrow, 'metric_source')
				
				
				//Insert child records
				
				
			Next
		End If
	Next
End If

of_log(String(ll_designcalccount) + ' Design Calcs created for ' + String(il_gigpid))

Return 1




Return 1
end function

public function integer of_createchecklist ();string ls_sql, ref_code, checklist_comments, last_updated_by
long ll_row, ll_ret, checklist_value, checklist_value2
datetime last_updated_dt
n_ds lds_data

//Handle Checklist and Categories tabs

ls_sql = 'select * from gigp_checklist where gigp_id = ' + String(il_gigpid)
ll_ret = of_createdatastore(lds_data, ls_sql)

If ll_ret > 0 Then
	For ll_row = 1 to ll_ret
		//Get values
		ref_code = lds_data.GetItemString(ll_row, 'ref_code')
		checklist_value = lds_data.GetItemNumber(ll_row, 'checklist_value')
		checklist_value2 = lds_data.GetItemNumber(ll_row, 'checklist_value2')
		checklist_comments = lds_data.GetItemString(ll_row, 'checklist_comments')
		last_updated_by = lds_data.GetItemString(ll_row, 'last_updated_by')
		last_updated_dt = lds_data.GetItemDateTime(ll_row, 'last_updated_dt')
		
		//Insert into new Hub table to be determined
		
	Next
	
End If

of_log(String(ll_ret) + ' Checklist Items created for ' + String(il_gigpid))

Return 1
end function

public function integer of_createroot ();long ll_financingprojectphaseid
string round_no, program, project_name, project_status_cd, locked_flag, srf_program, grant_type, eligible_pct, dec_region, muni_code, seqr_type, ls_countyname
string project_no, loan_id, typeof_applicant, applicant_type, app_recvd_dt, app_status, ccr_name, funding_recommendation, reviewing_agency, federal_id_no
string duns_no, naics_no, county_fips_code, spdes_no, pop_count, pop_source, project_score, last_updated_dt, last_updated_by, cfa_no, ppu, cfa_program_id
string project_pct_complete, consent_order, consent_order_comments, redc_region, ls_projdesc, ls_applicant, ls_status, ls_phasedesc
integer li_active, li_app_cwsrf, li_proj_cwsrf, li_gpr_eligible, li_green_wet_weather, li_ms4_permit
decimal ld_lat, ld_long, ld_totalcost, ld_grantamount
datetime ldt_smartgrowth, ldt_agreedate
string ls_sql, ls_code, ls_category, ls_desc
long ll_ret, ll_row
decimal ld_reqamt, ld_appamt
n_ds lds_data

//Get the Applicant and link to or create Project / ProjectPhase / Financing

//Create Applicant (currently just gets the applicant since matching occurred)
If of_createapplicant() < 0 Then
	Return -1
End If

//Get Checklist Items
li_app_cwsrf = of_getchecklistvalue('APPLNTCWSRFELIG')
li_proj_cwsrf = of_getchecklistvalue('PROJCWSRFELIG')
li_gpr_eligible = of_getchecklistvalue('GPRELIG')
li_green_wet_weather = of_getchecklistvalue('GWWI')
li_ms4_permit = of_getchecklistvalue('noMuniQues3')

//Get gigp_application data
select round_no,program,project_name,project_status_cd,locked_flag,srf_program,grant_type,eligible_pct,dec_region,muni_code,seqr_type,project_no,loan_id,typeof_applicant,applicant_type,app_recvd_dt,app_status,ccr_name,funding_recommendation,reviewing_agency,federal_id_no,duns_no,naics_no,county_fips_code,spdes_no,pop_count,pop_source,project_score,last_updated_dt,last_updated_by,cfa_no,ppu,cfa_program_id,project_pct_complete,consent_order,consent_order_comments,redc_region
into :round_no,:program,:project_name,:project_status_cd,:locked_flag,:srf_program,:grant_type,:eligible_pct,:dec_region,:muni_code,:seqr_type,:project_no,:loan_id,:typeof_applicant,:applicant_type,:app_recvd_dt,:app_status,:ccr_name,:funding_recommendation,:reviewing_agency,:federal_id_no,:duns_no,:naics_no,:county_fips_code,:spdes_no,:pop_count,:pop_source,:project_score,:last_updated_dt,:last_updated_by,:cfa_no,:ppu,:cfa_program_id,:project_pct_complete,:consent_order,:consent_order_comments,:redc_region
from gigp_application
where gigp_id = :il_gigpid;

//Update Customer with FederalId
If federal_id_no > '' Then
	update Customer
	set FederalIdNumber = :federal_id_no
	where CustomerId = :il_customerid
	and FederalIdNumber is null;
End If

//Get coordinates
select c.gis_latitude, c.gis_longitude
into :ld_lat, :ld_long
from gigp_contacts c
where c.contact_id = (select max(contact_id) from gigp_contact_links where gigp_id = :il_gigpid and contact_type = 'PLC');

//Get County
If county_fips_code > '' Then
	select ref_value
	into :ls_countyname
	from gigp_reference
	where category = 'County'
	and ref_code = :county_fips_code;
Else
	SetNull(ls_countyname)
End If

//Get Smart Growth Assessment Form Rec'd data
select Max(keydate_value)
into :ldt_smartgrowth
from gigp_key_dates
where gigp_id = :il_gigpid
and ref_code = 'readySMARTGROWTH';

//Get Project Description
select keydate_comments
into :ls_projdesc
from gigp_key_dates
where gigp_id = :il_gigpid
and ref_code = 'projDescription';

//Get applicant name for legacy field
select CustomerName
into :ls_applicant
from Customer
where CustomerId = :il_customerid;

//Translate Project Status code
If project_status_cd = 'projectActive' Then
	ls_status = 'Active'
	li_active = 1
Else
	ls_status = 'Closed'
	li_active = 0
End If

//Get Grant Agreement Date
select max(keydate_value)
into :ldt_agreedate
from gigp_key_dates
where gigp_id = :il_gigpid
and ref_code = 'agreeAGRFULLEX';

//Get Grant Amount***********************
ld_grantamount = 0

//Get Total Cost*****************************
ld_totalcost = 0


//Search for existing Project / Project Phase record using the exact Project Number
Select Max(ProjectId)
into :il_projectid
from Project
where ProjectNumber = :project_no;

//If exact Project Number didn't match, try root
If IsNull(il_projectid) or il_projectid <= 0 Then
	Select Max(ProjectId)
	into :il_projectid
	from Project
	where substring(ProjectNumber,1,7) = substring(:project_no,1,7);
End If

If IsNull(il_projectid) or il_projectid <= 0 Then

	//Create Project Record
	INSERT INTO Project
		(CustomerId
		,ProjectNumber
		,DecRegion
		,ProjectMhi
		,ProjectMhiComments
		,ProjectPopulation
		,ProjectPopulationComments
		,SrfProgram
		,SerpType
		,DrainageBasinCode
		,SpdesType
		,SpdesNumber
		,SpdesPermittedFlow
		,SpdesReceivingWaterbody
		,SpdesReceivingWaterbodyClass
		,PwlNumber
		,AuthorizedFacilityNumber
		,PossNumber
		,Latitude
		,Longitude
		,ProjectCounty
		,SmartGrowthFormReceived
		,ProjectDescription
		,ServiceAreaDescription
		,PlusDescription
		,EngineeringComments
		,ContractStatusComments
		,CurrentScore
		,LegacyApplicantName
		,LastUpdatedDate
		,LastUpdatedBy)
	VALUES
		(:il_customerid
		,:project_no
		,:dec_region
		,null
		,null
		,:pop_count
		,:pop_source
		,:srf_program
		,null
		,null
		,null
		,:spdes_no
		,null
		,null
		,null
		,null
		,null
		,null
		,:ld_lat
		,:ld_long
		,:ls_countyname
		,:ldt_smartgrowth
		,:ls_projdesc
		,null
		,null
		,null
		,null
		,:project_score
		,:ls_applicant
		,getdate()
		,'SYSTEM');
	
	If SQLCA.SQLCode <> 0 Then
		of_log('Error inserting Project Record for GIGP Id ' + String(il_gigpid) + ': ' + SQLCA.SQLErrText)
		Return -1
	End If
	
	select @@identity
	into :il_projectid
	from dual;
	
End If

//Search for ProjectPhase record
select max(ProjectPhaseId)
into :il_projectphaseid
from ProjectPhase
where ProjectId = :il_projectid;

If IsNull(il_projectphaseid) or  il_projectphaseid <= 0 Then
	
	//Create Phase description
	ls_phasedesc = program + ' Round ' + String(round_no)

	//Create ProjectPhase Record
	INSERT INTO ProjectPhase
	(ProjectId
	,ProjectNumber
	,PhaseNumber
	,PhaseType
	,Status
	,BondResolutionAmount
	,PhaseDescription
	,OutsideFundingComments
	,TotalCost
	,NycMarketRate
	,NycSeries
	,TargetSrfApplicationDate
	,LastUpdatedDate
	,LastUpdatedBy)
	VALUES
	(:il_projectid
	,:project_no
	,'0'
	,'Initial'
	,:ls_status
	,null
	,:ls_phasedesc
	,null
	,:ld_totalcost
	,null
	,null
	,null
	,getdate()
	,'SYSTEM');
	
	If SQLCA.SQLCode <> 0 Then
		of_log('Error inserting ProjectPhase Record for GIGP Id ' + String(il_gigpid) + ': ' + SQLCA.SQLErrText)
		Return -1
	End If
	
	select @@identity
	into :il_projectphaseid
	from dual;
	
End If

//Search for existing Financing record
select max(FinancingId)
into :il_financingid
from FinancingProjectPhase
where ProjectPhaseId = :il_projectphaseid;

If IsNull(il_financingid) or  il_financingid <= 0 Then

	//Create Financing Record
	INSERT INTO Financing
	(CustomerId
	,ClosingDate
	,LoanAgreementDate
	,MaturityDate
	,FinancingType
	,SeriesName
	,Term
	,RequiredFirstPaymentDate
	,SendBillingReminders
	,BillingReminderEmail
	,DebtServiceBillingReminderStatus
	,AdminFeeBillingReminderStatus
	,DaysBilledEarly
	,Comments
	,OldLoanId
	,Active
	,LastUpdatedDate
	,LastUpdatedBy)
	VALUES
	(:il_customerid
	,null
	,:ldt_agreedate
	,null
	,:program
	,null
	,null
	,null
	,0
	,null
	,null
	,null
	,0
	,null
	,null
	,:li_active
	,getdate()
	,'SYSTEM');
	
	If SQLCA.SQLCode <> 0 Then
		of_log('Error inserting Financing Record for GIGP Id ' + String(il_gigpid) + ': ' + SQLCA.SQLErrText)
		Return -1
	End If
	
	select @@identity
	into :il_financingid
	from dual;
	
	//Create FinancingProjectPhase record to link
	INSERT INTO FinancingProjectPhase (FinancingId,ProjectPhaseId,FullyRetiredDate,FinalDisbursementDepmApproved,FinalDisbursementMwbeApproved,LastUpdatedDate,LastUpdatedBy)
	VALUES (:il_financingId,:il_projectphaseid,null,0,0,getdate(),'SYSTEM';
	
End If

//Get FinancingProjectPhaseId
select max(FinancingProjectPhaseId)
into :ll_financingprojectphaseid
from FinancingProjectPhase
where FinancingId = :il_financingid
and ProjectPhaseId = :il_projectphaseid);


//CHECK FOR EXISTING FinancingProjectPhaseFunding
select max(FinancingProjectPhaseFundingId)
into :il_fundingid
from FinancingProjectPhaseFunding
where FinancingProjectPhaseId = :ll_financingprojectphaseid;

If IsNull(il_fundingid) or il_fundingid <= 0 Then
	//Get GIGP Amounts
	ls_sql = "select * from gigp_amounts where gigp_id = " + string(il_gigpid)
	ll_ret = of_createdatastore(lds_data, ls_sql)
	
	If ll_ret > 0 Then
		For ll_row = 1 to ll_ret
			ls_code = lds_data.GetItemString(ll_row, 'ref_code')
			ls_category = lds_data.GetItemString(ll_row, 'sub_category')
			ls_desc = lds_data.GetItemString(ll_row, 'amt_description')
			ld_reqamt = lds_data.GetItemDecimal(ll_row, 'ref_amt')
			ld_appamt = lds_data.GetItemDecimal(ll_row, 'approved_amt')
			
			//Insert FinancingProjectPhaseFunding
			INSERT INTO FinancingProjectPhaseFunding]
				([FinancingProjectPhaseId]
				,[FundingDate]
				,[FundingType]
				,[FundingSubtype]
				,[FundingAmount]
				,[DisbursementOrder]
				,[NewMoneyAmount]
				,[RefinancingAmount]
				,[LastUpdatedDate]
				,[LastUpdatedBy])
			VALUES
				(:ll_financingprojectphaseid
				,:ldt_agreedate
				,:program
				,null
				,:ld_grantamount
				,0
				,ld_grantamount
				,0
				,getdate()
				,'SYSTEM');
		
		If SQLCA.SQLCode <> 0 Then
			of_log('Error creating FinancingProjectPhaseFunding record to link Financing to ProjectPhase for GIGP Id ' + String(il_gigpid) + ': ' + SQLCA.SQLErrText)
			Return -1
		End If			  
			
	
		Next
		
	End If
	
End If


of_log('ProjectId ' + String(il_projectid) + ' created for GIGP ' + String(il_gigpid))
of_log('ProjectPhaseId ' + String(il_projectphaseid) + ' created for GIGP ' + String(il_gigpid))
of_log('FinancingId ' + String(il_financingid) + ' created for GIGP ' + String(il_gigpid))

Return 1
end function

public function string of_createmunicode (string as_county, string as_type);string ls_muni, ls_increment, ls_checkmuni
integer li_index
long ll_count
n_cst_string ln_string

If IsNull(as_county) Then as_county = ''
If IsNull(as_type) Then as_type = ''

//Build suggested Municode based on the following:
//Position 1 & 2 = County Code
//Position 3 & 4 = Blank = 46; AU = 40; C = 02; CO = 01; CORP = 88; JB = 86; P = 65; S = 33; T = 03; V = 04; WD = 24
//Position 5 thru 12 = '00000001' then increment untill the full combination does not exist
If as_county > '' Then
	//Start the Municode with positions 1 and 2
	ls_muni = as_county
Else
	ls_muni = '99'
End If
	
//Add positions 3 and 4 based on the Community Type
Choose Case as_type
	Case 'AU'
		ls_muni += '40'
		
	Case 'C'
		ls_muni += '02'
		
	Case 'CO'
		ls_muni += '01'
	
	Case 'CORP'
		ls_muni += '88'
		
	Case 'JB'
		ls_muni += '86'
		
	Case 'P'
		ls_muni += '65'
		
	Case 'S'
		ls_muni += '33'
		
	Case 'T'
		ls_muni += '03'
		
	Case 'V'
		ls_muni += '04'
		
	Case 'WD'
		ls_muni += '24'
		
	Case Else
		ls_muni += '46'
		
End Choose

//Fill w/ zeros to 1 and increment till new
li_index = 1
ls_increment = ln_string.of_globalreplace(ln_string.of_padleft(String(li_index), 8), ' ', '0')
ls_checkmuni = ls_muni + ls_increment

select count(*)
into :ll_count
from fin_muni_codes
where muni_code = :ls_checkmuni;

Do While ll_count > 0
	li_index++
	ls_increment = ln_string.of_globalreplace(ln_string.of_padleft(String(li_index), 8), ' ', '0')
	ls_checkmuni = ls_muni + ls_increment
	
	select count(*)
	into :ll_count
	from fin_muni_codes
	where muni_code = :ls_checkmuni;
	
Loop

ls_muni = ls_checkmuni

Return ls_muni
end function

public function integer of_createbankinfo ();string ls_aba, ls_accountnumber, ls_accountname
long ll_count

//Insert Bank info from project_references to ProjectPhaseWireTo

//Make sure all three values are in the db
select count(*)
into :ll_count
from gigp_project_references
where gigp_id = :il_gigpid;

If ll_count >= 3 Then
	//Get bank info
	select max(projref_value)
	into :ls_aba
	from gigp_project_references
	where gigp_id = :il_gigpid
	and ref_code = 'bankABA';
	
	select max(projref_value)
	into :ls_accountnumber
	from gigp_project_references
	where gigp_id = :il_gigpid
	and ref_code = 'acctNo';
	
	select max(projref_value)
	into :ls_accountname
	from gigp_project_references
	where gigp_id = :il_gigpid
	and ref_code = 'acctName';
	
	//Insert into Hub table
	INSERT INTO ProjectPhaseWireTo
		(ProjectPhaseId
		,AbaNumber
		,AccountNumber
		,AccountDescription
		,LastUpdatedDate
		,LastUpdatedBy)
	VALUES
		(:il_projectphaseid
		,:ls_aba
		,:ls_accountnumber
		,:ls_accountname
		,getdate()
		,'SYSTEM');
End If


Return 1
end function

public function integer of_getchecklistvalue (string as_checklistitem);integer li_result

SetNull(li_result)

select checklist_value
into :li_result
from gigp_checklist
where gigp_id = :il_gigpid
and ref_code = :as_checklistitem;

If IsNull(li_result) Then li_result = 0

Return li_result
end function

on w_smallgrantsconversion.create
this.rb_contractors=create rb_contractors
this.rb_applicants=create rb_applicants
this.st_unmatchedtotal=create st_unmatchedtotal
this.st_2=create st_2
this.cb_2=create cb_2
this.st_1=create st_1
this.pb_1=create pb_1
this.pb_save=create pb_save
this.cb_1=create cb_1
this.dw_log=create dw_log
this.gb_2=create gb_2
this.gb_3=create gb_3
this.dw_contractors=create dw_contractors
this.dw_applicants=create dw_applicants
this.gb_1=create gb_1
this.Control[]={this.rb_contractors,&
this.rb_applicants,&
this.st_unmatchedtotal,&
this.st_2,&
this.cb_2,&
this.st_1,&
this.pb_1,&
this.pb_save,&
this.cb_1,&
this.dw_log,&
this.gb_2,&
this.gb_3,&
this.dw_contractors,&
this.dw_applicants,&
this.gb_1}
end on

on w_smallgrantsconversion.destroy
destroy(this.rb_contractors)
destroy(this.rb_applicants)
destroy(this.st_unmatchedtotal)
destroy(this.st_2)
destroy(this.cb_2)
destroy(this.st_1)
destroy(this.pb_1)
destroy(this.pb_save)
destroy(this.cb_1)
destroy(this.dw_log)
destroy(this.gb_2)
destroy(this.gb_3)
destroy(this.dw_contractors)
destroy(this.dw_applicants)
destroy(this.gb_1)
end on

event open;dw_applicants.Visible = True
dw_contractors.Visible = False
end event

type rb_contractors from radiobutton within w_smallgrantsconversion
integer x = 4215
integer y = 160
integer width = 370
integer height = 72
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Contractors"
end type

event clicked;If this.Checked Then
	dw_contractors.Visible = True
	st_unmatchedtotal.Text = String(dw_contractors.RowCount())
Else
	dw_contractors.Visible = False
End If
end event

type rb_applicants from radiobutton within w_smallgrantsconversion
integer x = 3589
integer y = 160
integer width = 411
integer height = 72
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Applicants"
boolean checked = true
end type

event clicked;If this.Checked Then
	dw_applicants.Visible = True
	st_unmatchedtotal.Text = String(dw_applicants.RowCount())
Else
	dw_applicants.Visible = False
End If
end event

type st_unmatchedtotal from statictext within w_smallgrantsconversion
integer x = 2683
integer y = 380
integer width = 325
integer height = 56
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "0"
boolean focusrectangle = false
end type

type st_2 from statictext within w_smallgrantsconversion
integer x = 2683
integer y = 304
integer width = 311
integer height = 56
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Unmatched:"
boolean focusrectangle = false
end type

type cb_2 from commandbutton within w_smallgrantsconversion
integer x = 2683
integer y = 132
integer width = 311
integer height = 100
integer taborder = 30
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Run Match"
end type

event clicked;If rb_applicants.Checked Then
	dw_applicants.Event ue_automatch()
Else
	dw_contractors.Event ue_automatch()
End If
end event

type st_1 from statictext within w_smallgrantsconversion
integer x = 178
integer y = 3024
integer width = 562
integer height = 56
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Create Re-seed script"
boolean focusrectangle = false
end type

type pb_1 from picturebutton within w_smallgrantsconversion
integer x = 293
integer y = 2684
integer width = 110
integer height = 96
integer taborder = 40
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean cancel = true
string picturename = "RetrieveCancel!"
alignment htextalign = left!
string powertiptext = "Cancel Conversion!"
end type

event clicked;//Main processing loop with Yield() after each record and test for ib_cancel before the next
ib_cancel = True
end event

type pb_save from picturebutton within w_smallgrantsconversion
integer x = 293
integer y = 2804
integer width = 110
integer height = 96
integer taborder = 20
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean flatstyle = true
string picturename = "Save1!"
alignment htextalign = left!
string powertiptext = "Save Results"
end type

event clicked;dw_log.SaveAs()
end event

type cb_1 from commandbutton within w_smallgrantsconversion
integer x = 82
integer y = 128
integer width = 311
integer height = 100
integer taborder = 20
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Convert"
boolean default = true
end type

event clicked;string ls_sql
long ll_ret, ll_row
n_ds lds_data

//Get gigp_id's for all funded application records in GIGP for all Programs
ls_sql = 'select gigp_id from gigp_application where funding_recommendation = "RECC-H" and project_status_cd <> "projectWithdrawn" and round_no in (9,10,2018,2019)' //**JUST FOR TESTING
//ls_sql = 'select gigp_id from gigp_application where funding_recommendation = "RECC-H" and project_status_cd <> "projectWithdrawn"'
ll_ret = of_createdatastore(lds_data, ls_sql)

of_log('Applications retrieved: ' + string(ll_ret))

//Loop through funded gigp application records
For ll_row = 1 to ll_ret
	
	//test for cancel
	If ib_cancel Then
		ib_cancel = False
		of_log('***CONVERSION CANCELLED***')
		Exit
	End If
	
	//Get the gigp_id
	il_gigpid = lds_data.GetItemNumber(ll_row, 'gigp_id')
	
	of_log('***************************************')
	of_log('Converting GIGP Id: ' + String(il_gigpid))
	
	If il_gigpid > 0 Then
		//Create the root Application records - Project, ProjectPhase, Financing, Amounts
		If of_createroot() > 0 Then

			//Create Project Types
			of_createprojecttypes()
			
			//Create Grant Amounts
//			of_creategrantamounts()		//moved to Root
			
			//Save Bank info
			of_createbankinfo()
			
			//Create Metrics
			of_createmetrics()
			
			//Create Design Calcs
			of_createdesigncalcs()

			//Create CFA Items
			of_createcfaitems()
			
			//Create Checklist
			of_createchecklist()	//moving to root level properties
			
			//Create Notes
			of_createnotes()
			
			//Create Political Districts
			of_createpoliticaldistricts()
			
			//Create Contacts
			of_createcontacts()
			
			//Create Contracts / Vendors
			of_createcontracts()
			
			//Create Key Dates
			of_createkeydates()
			
			//Create Disbursements
			of_createdisbursements()
		
		Else
			of_log('Creation of Root Records failed for GIGP ' + String(il_gigpid))
		End If
		
	Else
		of_log('Invalid gigp_id: ' + string(il_gigpid))
	End If
	
	of_log('Done converting GIGP ' + String(il_gigpid))
	of_log('')
	
	//Yield to allow for cancel
	Yield()
	
Next

of_log('Done')
end event

type dw_log from u_dw within w_smallgrantsconversion
integer x = 425
integer y = 116
integer width = 2153
integer height = 2792
integer taborder = 10
string dataobject = "d_util_log"
boolean hscrollbar = true
end type

type gb_2 from groupbox within w_smallgrantsconversion
integer x = 41
integer y = 24
integer width = 2587
integer height = 2952
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Run Conversion"
end type

type gb_3 from groupbox within w_smallgrantsconversion
integer x = 3031
integer y = 108
integer width = 2153
integer height = 144
integer taborder = 10
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Convert:"
end type

type dw_contractors from u_dw within w_smallgrantsconversion
event ue_manualmatch ( long al_row )
event ue_automatch ( )
integer x = 3031
integer y = 300
integer width = 2153
integer height = 2608
integer taborder = 40
string dataobject = "d_contractor_conversion"
end type

event ue_manualmatch(long al_row);long ll_customerid, ll_gigpid
string ls_return

//Get the gigp id
ll_gigpid = this.GetItemNumber(al_row, 'gigp_id')

If ll_gigpid > 0 Then
	//Open the selection window and pass the gigp id
	OpenWithParm(w_smallgrants_customerselect, ll_gigpid)
	
	//Get the returned CustomerId
	ls_return = Message.StringParm
	
	//If a valid ID was passed back, update the gigp_application table and reretrieve for unmatched application records
	If IsNumber(ls_return) Then
		ll_customerid = Long(ls_return)
		
		If ll_customerid > 0 Then
			update gigp_application
			set customerid = :ll_customerid
			where gigp_id = :ll_gigpid;
			
			//Reretrieve to update unmatched records
			this.Event pfc_retrieve()
			
		End If
		
	End If
	
End If
end event

event ue_automatch();long ll_row, ll_count, ll_contract, ll_contractor
integer li_matched
string ls_contractorname, ls_gigpcontractorname

//Initialize counts
li_matched = 0

ll_count = this.RowCount()

If ll_count > 0 Then
	//Loop throughh all unmatched records
	For ll_row = 1 to ll_count
		ll_contract = this.GetItemNumber(ll_row, 'profess_contract_id')
		ls_gigpcontractorname = this.GetItemString(ll_row, 'organization')

		SetNull(ll_contractor)
		
		//Attempt match
		select con.ContractorId, con.Name
		into: ll_contractor, :ls_contractorname
		from mwbe_main mm, Contractor con
		where mm.gigp_contract_id = :ll_contract
		and mm.contractor_id = con.ContractorId;
		
		If ll_contractor > 0 Then
			li_matched++
			
			update gigp_professional_contracts
			set ContractorId = :ll_contractor
			where profess_contract_id = :ll_contract;
			
			of_log('GIGP Contractor ' + ls_gigpcontractorname + ' matched to ' + ls_contractorname + ' in SRF Home')
		End If
		
	Next
	
	//Re-retrieve
	this.Event pfc_retrieve()

	of_log('Done Auto Match')
	of_log('Matched: ' + String(li_matched))
	
End If

end event

event constructor;call super::constructor;this.of_SetRowSelect(True)
this.inv_RowSelect.of_SetStyle(0)

this.SetTransObject(SQLCA)
this.Event pfc_retrieve()
end event

event doubleclicked;call super::doubleclicked;If row > 0 Then
	this.Event ue_manualmatch(row)
End If
end event

event pfc_retrieve;call super::pfc_retrieve;long ll_ret

ll_ret = this.Retrieve()

st_unmatchedtotal.Text = String(ll_ret)

Return ll_ret
end event

type dw_applicants from u_dw within w_smallgrantsconversion
event ue_manualmatch ( long al_row )
event ue_automatch ( )
integer x = 3031
integer y = 300
integer width = 2153
integer height = 2608
integer taborder = 10
string dataobject = "d_applicant_conversion"
end type

event ue_manualmatch(long al_row);long ll_customerid, ll_gigpid
string ls_return

//Get the gigp id
ll_gigpid = this.GetItemNumber(al_row, 'gigp_id')

If ll_gigpid > 0 Then
	//Open the selection window and pass the gigp id
	OpenWithParm(w_smallgrants_customerselect, ll_gigpid)
	
	//Get the returned CustomerId
	ls_return = Message.StringParm
	
	//If a valid ID was passed back, update the gigp_application table and reretrieve for unmatched application records
	If IsNumber(ls_return) Then
		ll_customerid = Long(ls_return)
		
		If ll_customerid > 0 Then
			update gigp_application
			set customerid = :ll_customerid
			where gigp_id = :ll_gigpid;
			
			//Reretrieve to update unmatched records
			this.Event pfc_retrieve()
			
		End If
		
	End If
	
End If
end event

event ue_automatch();long ll_row, ll_count, ll_customer, ll_gigpid, ll_pos
integer li_exactcount, li_countycount, li_citycount, li_towncount, li_villagecount, li_unmatchedcount, li_matchedcount
string ls_applicant, ls_testname

//Initialize counts
li_exactcount = 0
li_countycount = 0
li_citycount = 0
li_towncount = 0
li_villagecount = 0
li_unmatchedcount = 0
li_matchedcount = 0

ll_count = this.RowCount()

If ll_count > 0 Then
	//Loop throughh all unmatched records
	For ll_row = 1 to ll_count
		ls_applicant = this.GetItemString(ll_row, 'organization')
		ll_gigpid = this.GetItemNumber(ll_row, 'gigp_id')
		SetNull(ll_customer)
		
		//Attempt exact match
		select CustomerId
		into :ll_customer
		from Customer
		where Upper(CustomerName) = Upper(:ls_applicant);
		
		If ll_customer > 0 Then
			li_exactcount++
			of_log('GIGPId ' + String(ll_gigpid) + ' for Applicant = ' + ls_applicant + ' matched EXACT to CustomerId = ' + String(ll_customer))
			GoTo NextRecord
		End If
		
		//Attempt Match County - Right(Organization, 6) = 'County' - such as Albany County
		If Right(ls_applicant, 6) = 'County' Then
			ls_testname = Left(ls_applicant, Len(ls_applicant) - 7)
			
			select CustomerId
			into :ll_customer
			from Customer
			where CustomerName = :ls_testname
			and CustomerType = 'CO';
			
			If ll_customer > 0 Then
				li_countycount++
				of_log('GIGPId ' + String(ll_gigpid) + ' for Applicant = ' + ls_applicant + ' matched BY COUNTY to CustomerId = ' + String(ll_customer))
				GoTo NextRecord
			End If
			
		End If
		
		//Attempt Match City - Left(Organization, 7) = 'City of' - such as City of Albany
		If Left(ls_applicant, 7) = 'City of' Then
			ls_testname = Right(ls_applicant, Len(ls_applicant) - 8)
			
			select CustomerId
			into :ll_customer
			from Customer
			where CustomerName = :ls_testname
			and CustomerType = 'C';
			
			If ll_customer > 0 Then
				li_citycount++
				of_log('GIGPId ' + String(ll_gigpid) + ' for Applicant = ' + ls_applicant + ' matched BY CITY to CustomerId = ' + String(ll_customer))
				GoTo NextRecord
			End If
			
		End If
		
		//Attempt Match Town - Left(Organization, 7) = 'Town of' - such as Town of Hoosick
		If Left(ls_applicant, 7) = 'Town of' Then
			ls_testname = Right(ls_applicant, Len(ls_applicant) - 8)
			
			select CustomerId
			into :ll_customer
			from Customer
			where CustomerName = :ls_testname
			and CustomerType = 'T';
			
			If ll_customer > 0 Then
				li_towncount++
				of_log('GIGPId ' + String(ll_gigpid) + ' for Applicant = ' + ls_applicant + ' matched BY TOWN to CustomerId = ' + String(ll_customer))
				GoTo NextRecord
			End If
			
		End If
		
		//Attempt Match Village - Left(Organization, 10) = 'Village of' - such as Village of Hoosick Falls
		If Left(ls_applicant, 10) = 'Village of' Then
			ls_testname = Right(ls_applicant, Len(ls_applicant) - 11)
			
			select CustomerId
			into :ll_customer
			from Customer
			where CustomerName = :ls_testname
			and CustomerType = 'V';
			
			If ll_customer > 0 Then
				li_villagecount++
				of_log('GIGPId ' + String(ll_gigpid) + ' for Applicant = ' + ls_applicant + ' matched BY VILLAGE to CustomerId = ' + String(ll_customer))
				GoTo NextRecord
			End If
			
		End If
		
		NextRecord:
		//If a Customer was found, update the gigp_application record
		If ll_customer > 0 Then
			li_matchedcount++
			update gigp_application
			set CustomerId = :ll_customer
			where gigp_id = :ll_gigpid;
		Else
			li_unmatchedcount++
			of_log('GIGPId ' + String(ll_gigpid) + ' for Applicant = ' + ls_applicant + ' UNABLE TO MATCH')
		End If
		
	Next
	
	//Re-retrieve
	dw_applicants.Event pfc_retrieve()

	of_log('Done Auto Match')
	of_log('Matched Exact: ' + String(li_exactcount))
	of_log('Matched County: ' + String(li_countycount))
	of_log('Matched City: ' + String(li_citycount))
	of_log('Matched Town: ' + String(li_towncount))
	of_log('Matched Village: ' + String(li_villagecount))
	of_log('TOTAL MATCHED: '+ String(li_matchedcount))
	of_log('TOTAL UNMATCHED: ' + String(li_unmatchedcount))
	of_log('TOTAL ATTEMPTED: ' + String(ll_count))
	
End If
end event

event constructor;call super::constructor;this.of_SetRowSelect(True)
this.inv_RowSelect.of_SetStyle(0)

this.SetTransObject(SQLCA)
this.Event pfc_retrieve()
end event

event doubleclicked;call super::doubleclicked;If row > 0 Then
	this.Event ue_manualmatch(row)
End If
end event

event pfc_retrieve;call super::pfc_retrieve;long ll_ret

ll_ret = this.Retrieve()

st_unmatchedtotal.Text = String(ll_ret)

Return ll_ret
end event

type gb_1 from groupbox within w_smallgrantsconversion
integer x = 2642
integer y = 24
integer width = 2587
integer height = 2952
integer taborder = 40
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
string text = "Unmatched GIGP Applicants (Double-click to manually match)"
end type

