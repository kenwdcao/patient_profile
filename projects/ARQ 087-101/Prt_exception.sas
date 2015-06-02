

%macro prt_exception;
	%if %upcase(&dset)=DM %then
	%do;
		define COL/' ';
	%end;

	%if %upcase(&dset)=SD %then
	%do;
		define SDSTDTC/'Start Date';
		define SDDOSST/style(column)=[just=c];
		define SDMODYN/style(column)=[just=c];
	%end;
%mend prt_exception;
