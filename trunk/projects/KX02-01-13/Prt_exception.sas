
* -----> Special Report Definition List;

%macro prt_exception;

    %if %upcase(&dset) = DM %then
        %do;
            define col / '';
        %end;
	%else %if %upcase(&dset) = EOS %then
		%do;
			define col / '';
		%end;
	%else %if %upcase(&dset) = AE %then
		%do;
			define aeterm / style(column)=[cellwidth=2.25in] style(header)=[cellwidth=2.25in];
			define sev / "CTCAE#Grade&escapechar{super [2]}";
			define aerel / style(column)=[cellwidth=1.25in] style(header)=[cellwidth=1.25in];
			define aeacn / style(column)=[cellwidth=1.25in] style(header)=[cellwidth=1.25in];
			define treat / style(column)=[cellwidth=1.85in] style(header)=[cellwidth=1.85in];
			define DRUGLVL / "Investigational#Drug Level (mg)&escapechar{super [3]}" style(header)=[cellwidth=1.3in] style(column)=[cellwidth=1.3in];
		%end;
	%else %if %upcase(&dset) = CM %then
		%do;
			define DRUGLVL / "Investigational#Drug Level (mg)&escapechar{super [3]}";
		%end;
%mend prt_exception;
