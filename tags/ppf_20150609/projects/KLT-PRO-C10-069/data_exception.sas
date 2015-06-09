
%macro data_exception;
	%if &nobs^=0 and %upcase(&dset)=VS %then %do;
		%getVisitLabel;
		%end;
	%else %if &nobs^=0 and %upcase(&dset)=CK %then %do;
		%getVisitLabel;
		%end;
	%else %if &nobs^=0 and %upcase(&dset)=DP %then %do;
		%getVisitLabel;
		%end;
	%else %if &nobs^=0 and %upcase(&dset)=LBBI %then %do;
		%getVisitLabel;
		%end;
	%else %if &nobs^=0 and %upcase(&dset)=LBCBC %then %do;
		%getVisitLabel;
		%end;
	%else %if &nobs^=0 and %upcase(&dset)=LBSCHEM %then %do;
		%getVisitLabel;
		%end;
	%else %if &nobs^=0 and %upcase(&dset)=QS %then %do;
		%getVisitLabel;
		%end;

%mend data_exception;
