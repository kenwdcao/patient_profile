
%macro data_exception;
	%local addnote;

	%if %upcase(&dset)=HS %then %do;
		data _null_;
			set __prt;
			if index(allcrt,'^{style')>0 then do;
				call symput('addnote','1');
			end;
		run;
		%if &addnote=1 %then %do;
			data __prt;
				set __prt;
				label allcrt='Investigator criteria for hospital discharge (check all that apply)#^{style [foreground=green] Cross line / under line means inconsistency found}';
			run;
		%end;
	%end;
	
%mend data_exception;
