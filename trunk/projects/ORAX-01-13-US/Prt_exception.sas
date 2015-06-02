
* -----> Special Report Definition List;

%macro prt_exception;

    %if %upcase(&dset) = DM %then
        %do;
            define col / '';
        %end;

   %else  %if %upcase(&dset) = HEMA1 %then
        %do;
            FORMAT _ALL_;
        %end;

     %else  %if %upcase(&dset) = HEMA2 %then
        %do;
            FORMAT _ALL_;
        %end;

     %else  %if %upcase(&dset) = CHEMA1 %then
        %do;
            FORMAT _ALL_;
        %end;

     %else  %if %upcase(&dset) = CHEMA2 %then
        %do;
            FORMAT _ALL_;
        %end;

     %else  %if %upcase(&dset) = CHEMA3 %then
        %do;
            FORMAT _ALL_;
        %end;

	%else %if %upcase(&dset) = AE %then
		%do;
			define druglvl / 'Investigational Drug Level(mg) at AE Start';
		%end;

	%else %if %upcase(&dset) = CM %then
		%do;
			define druglvl / 'Investigational Drug Level(mg) at CM Start';
		%end;

%mend prt_exception;
