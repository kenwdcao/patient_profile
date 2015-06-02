
%macro prt_compute_exception();
** compute _blank_;
%macro insertBlnkCOL();
compute _blank_ / character length=1;
    _blank_ = ' ';
    %if &nobs = 0 %then %do;
    call define('_blank_', 'style','style=[borderbottomwidth=0 borderbottomcolor=white]');
    %end;
endcomp;
%mend insertBlnkCOL;


%if %upcase(&dset) = CT %then %do;
    %insertBlnkCOL;
%end;
%else %if %index(%upcase(&dset), LB) = 1 %then %do;
    compute __EDC_TREENODEID;
        if index(__EDC_TREENODEID, '-Unit') or index(__EDC_TREENODEID, '-NR') then do;
            call define(_row_, 'style', 'style=[backgroundcolor=cxDDEBF7]');
        end;
    endcomp;
%end;
%mend prt_compute_exception;
