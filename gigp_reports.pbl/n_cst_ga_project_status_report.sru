forward
global type n_cst_ga_project_status_report from n_cst_report
end type
end forward

global type n_cst_ga_project_status_report from n_cst_report
end type
global n_cst_ga_project_status_report n_cst_ga_project_status_report

forward prototypes
public subroutine of_retrieve_report ()
end prototypes

public subroutine of_retrieve_report ();long ll_row, ll_count
string ls_bond1, ls_bond2, ls_bond3, ls_seqr1, ls_seqr2, ls_seqr3, ls_seqr4, ls_seqr5, ls_seqr6, ls_seqr7, ls_seqr8, ls_seqr9
string ls_bondresult, ls_seqrresult

ll_count = this.Retrieve()

If ll_count > 0 Then
	
	For ll_row = 1 to ll_count
		//Handle Bond column
		ls_bond1 = this.GetItemString(ll_row, 'bond1')
		ls_bond2 = this.GetItemString(ll_row, 'bond2')
		ls_bond3 = this.GetItemString(ll_row, 'bond3')
		
		ls_bondresult = ''
		
		If ls_bond1 = 'PENDING' or ls_bond2 = 'PENDING' or ls_bond3 = 'PENDING' Then
			ls_bondresult = 'PENDING'
			
		Else
			If ls_bond1 = 'APPROVED' Then
				ls_bondresult = 'APPROVED'
			End If
			
			If ls_bond1 = 'NA' Then
				ls_bondresult = 'NA'
			End If
			
		End If
			
		this.SetItem(ll_row, 'BOND', ls_bondresult)
		
		//Handle SEQR column
		ls_seqr1 = this.GetItemString(ll_row, 'seqr1')
		ls_seqr2 = this.GetItemString(ll_row, 'seqr2')
		ls_seqr3 = this.GetItemString(ll_row, 'seqr3')
		ls_seqr4 = this.GetItemString(ll_row, 'seqr4')
		ls_seqr5 = this.GetItemString(ll_row, 'seqr5')
		ls_seqr6 = this.GetItemString(ll_row, 'seqr6')
		ls_seqr7 = this.GetItemString(ll_row, 'seqr7')
		ls_seqr8 = this.GetItemString(ll_row, 'seqr8')
		ls_seqr9 = this.GetItemString(ll_row, 'seqr9')
		
		ls_seqrresult = ''
		
		If ls_seqr1 = 'CORRECTION' or ls_seqr2 = 'CORRECTION' or ls_seqr3 = 'CORRECTION' or ls_seqr4 = 'CORRECTION' or ls_seqr5 = 'CORRECTION' or ls_seqr6 = 'CORRECTION' or ls_seqr7 = 'CORRECTION' or ls_seqr8 = 'CORRECTION' or ls_seqr9 = 'CORRECTION' Then
			ls_seqrresult = 'CORRECTION'
		
		ElseIf ls_seqr1 = 'PENDING' or ls_seqr2 = 'PENDING' or ls_seqr3 = 'PENDING' or ls_seqr4 = 'PENDING' or ls_seqr5 = 'PENDING' or ls_seqr6 = 'PENDING' or ls_seqr7 = 'PENDING' or ls_seqr8 = 'PENDING' or ls_seqr9 = 'PENDING' Then
			ls_seqrresult = 'PENDING'
			
		ElseIf ls_seqr1 = 'APPROVED' Then
			ls_seqrresult = 'APPROVED'
			
		ElseIf ls_seqr1 = 'NA' Then
			ls_seqrresult = 'NA'
			
		End If
		
		this.SetItem(ll_row, 'SEQR', ls_seqrresult)
		
		
	Next
	
End If
end subroutine

on n_cst_ga_project_status_report.create
call super::create
end on

on n_cst_ga_project_status_report.destroy
call super::destroy
end on

