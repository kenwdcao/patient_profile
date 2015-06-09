
%macro data_exception;
/*	%if &nobs=0 %then %do;*/
/*		data __prt;*/
/*			a='No Observation';*/
/*		run;*/
/*	%end;*/

	/*
		Any dataset needs to be reformatted, could be done here.
		Available macro variable is &dset.
	*/

/*%if &nobs=0 and &dset=PEALL %then %do;*/
/*	data __prt;*/
/*			a='No Abnormal Physical Examination Result';*/
/*		run;*/
/*	%end;*/
/**/
/*%else %if &nobs=0 and &dset=IE %then %do;*/
/*		data __prt;*/
/*			a='No I/E Violation';*/
/*		run;*/
/*	%end;*/
/*%else %if &nobs=0 and &dset=EG20 %then %do;*/
/*		data __prt;*/
/*			a=' No abnormal ECG';*/
/*		run;*/
/*	%end;*/
	%if &nobs^=0 and &dset=LBHEM %then %do;
		%getVisitLabel;
		%end;

	%else %if &nobs^=0 and &dset=LBURIN %then %do;
		%getVisitLabel;
		%nullcolumn;
		%end;

	%else %if &nobs^=0 and &dset=VSALL %then %do;
		%getVisitLabel;
		%end;

	%else %if &nobs^=0 and &dset=LBCHEM %then %do;
		%getVisitLabel;
		%end;

	%else %if &nobs^=0 and &dset=LBCHEM25 %then %do;
		%getVisitLabel;
		%end;

	%else %if &nobs^=0 and &dset=QS37 %then %do;
		%getVisitLabelqs;
		%end;

	%else %if &nobs^=0 and &dset=QS40 %then %do;
		%getVisitLabelqs;
		%end;

	%else %if &nobs^=0 and &dset=QS33 %then %do;
		%getVisitLabel;
		%end;

	%else %if &nobs^=0 and &dset=QS41 %then %do;
		%getVisitLabel;
		%end;

%mend data_exception;
