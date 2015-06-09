/** !-- adjustment for proc report -- **/

%macro prt_compute_exception();



** compute _blank_;
%macro insertBlnk();
compute _blank_ / character length=1;
    _blank_ = ' ';
    %if &nobs = 0 %then %do;
    call define('_blank_', 'style','style=[borderbottomwidth=0 borderbottomcolor=white]');
    %end;
endcomp;
%mend insertBlnk;

%if %upcase(&dset) = AE2 %then %do;
    %insertBlnk;
%end;
%else %if %upcase(&dset) = RD %then %do;
    %insertBlnk;
%end;
%else %if %upcase(&dset) = CT1 %then %do;
    %insertBlnk;
%end;
%else %if %upcase(&dset) = CT2 %then %do;
    %insertBlnk;
%end;
%else %if %upcase(&dset) = AM1 %then %do;
    %insertBlnk;
%end;
/*
%else %if %upcase(&dset) = AM2 %then %do;
    %insertBlnk;
%end;
*/
%mend prt_compute_exception;
