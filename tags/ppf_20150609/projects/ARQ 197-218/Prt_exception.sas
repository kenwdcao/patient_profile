* Program Name: prt_exception.sas;
* Initial Date: 19/02/2014;
* Adjust individual column within each data module in patient profile;

%macro prt_exception;
   /*
    *!-- BELOW IS AN EXAMPLE --; 
    %if %upcase(&dset)=SD %then
        %do;
            define SDSTDTC/'Start Date';
            define SDDOSST/style(column)=[just=c];
            define SDMODYN/style(column)=[just=c];
        %end;
    */
	%if %upcase(&dset) = DEMOG2 %then
	    %do;
	        define COL/' ';
	        define ord / noprint;
	    %end;
	%else %if %upcase(&dset) = REFRANGE %then
		%do;
			define low / style(column) = [just = l];
			define high / style(column) = [just = l];
		%end;
	%else %if %upcase(&dset) = TARGET %then
		%do;
			define tnum / style(column) = [just = c];
		%end;
	%else %if %upcase(&dset) = NTARGET %then
		%do;
			define ntnum / style(column) = [just = c];
			define nteval / style(column) = [width=1.2in];
			define method / style(column) = [width=1.2in];
		%end;
	%else %if %upcase(&dset) = SAE %then
		%do;
			define aerel / noprint;
		%end;
	%else %if %upcase(&dset) = AE %then
		%do;
			define aesev / style(column)=[just=c];
			define aeser / style(column)=[just=c];
		%end;
	/*
	%else %if %upcase(&dset) = EG %then
		%do;
			define ecgabnsp0 / style(column)=[width=2in];
		%end;
	*/

%mend prt_exception;
