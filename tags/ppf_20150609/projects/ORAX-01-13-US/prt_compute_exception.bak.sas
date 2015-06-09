* Program Name: prt_compute_exception.sas;
* Initial Date: 19/02/2014;
* Add user defined compute block within each data module in patient profile;


/*
    Revision History
    2014/03/10 Ken: Add "and &nobs = 0.5" for AE block.

*/


%macro prt_compute_exception();
    
  /* %if %upcase(&dset) = FAST %then 
        %do;
            compute after;
                line 'Fasting data to be added';
            endcomp;
        %end;   */
   %if %upcase(&dset) = FAST and &nobs = 0.5 %then 
        %do;
            compute after _page_/ style = [borderbottomwidth = 0 frame=void rules=none];
                line 'No Observation';
            endcomp;
        %end;

   %else %if %upcase(&dset) = AE and &nobs = 0.5 %then 
        %do;
            compute after _page_ / style = [borderbottomwidth = 0 frame=void rules=none];
                line 'There are no adverse events collected.';
            endcomp;
        %end;   

   %else  %if %upcase(&dset) = EX and &nobs = 0.5 %then 
        %do;
            compute after _page_ / style = [borderbottomwidth = 0 frame=void rules=none] ;
                line 'No Observation';
            endcomp;
        %end;

%mend prt_compute_exception;
