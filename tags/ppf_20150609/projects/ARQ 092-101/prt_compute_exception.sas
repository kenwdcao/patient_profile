* Program Name: prt_compute_exception.sas;
* Initial Date: 22/08/2014
* Add user defined compute block within each data module in patient profile;





%macro prt_compute_exception();

    ** Ken Cao on 2014/11/28: As per client comments, all letters should be black and white. ;;
    /*
    %if %upcase(&dset)=TUT %then %do;
        compute tunum;
            if upcase(tunum) = 'SUM' then do;
                call define(_row_, 'style', 'style=[fontweight=bold fontstyle=italic]');
            end;
        endcomp;
        compute pchg;
            if upcase(tunum) = 'SUM' and pchg^='' and input(pchg,best.)<=-30 then call define('pchg', 'style', 'style=[foreground=green]');
        endcomp;
        compute pcnad;
            if upcase(tunum) = 'SUM' and pcnad^='' and input(pcnad,best.)>=20 then call define('pcnad', 'style', 'style=[foreground=red]');
        endcomp;
    %end;
    %else %if %upcase(&dset)=TULYM %then %do;
        compute tunum;
            if upcase(tunum) = 'SPD' then do;
                call define(_row_, 'style', 'style=[fontweight=bold fontstyle=italic]');
            end;
        endcomp;
        compute pchg;
            if upcase(tunum) = 'SPD' and pchg^='' and input(pchg,best.)<=-50 then call define('pchg', 'style', 'style=[foreground=green]');
        endcomp;
        compute pcnad;
            if upcase(tunum) = 'SPD' and pcnad^='' and input(pcnad,best.)>=50 then call define('pcnad', 'style', 'style=[foreground=red]');
        endcomp;
    %end;
    %else %if %upcase(&dset) = AE %then %do;
        compute __aesae;
            if  __aesae='1' then do;
                call define (_row_,'style','style=[background=yellow]');
                call define ('AESAE2','style','style=[foreground=red]');
            end;
        endcomp;
        compute __aedlt;
           if __aedlt = '1' then do;
                call define(_row_,'style','style=[background=yellow]');
                call define ('AEDLT2','style','style=[foreground=red]');
           end;
        endcomp;
    %end;
    %else %if %upcase(&dset) = TUNT %then %do;
        compute asmt;
            if asmt = 'New Lesion' then call define('asmt', 'style', 'style=[foreground=red]');
        endcomp;
    %end;
    %else %if %upcase(&dset) = HEMA %then %do;
        compute lbclsig;
            if lbclsig = 'Yes' then call define('lbclsig', 'style', 'style=[foreground=red background=yellow]');
        endcomp;
    %end;

    %else %if %upcase(&dset) = LBCOAG %then %do;
        compute lbclsig;
            if lbclsig = 'Yes' then call define('lbclsig', 'style', 'style=[foreground=red background=yellow]');
        endcomp;
    %end;

    %else %if %upcase(&dset) = CHEM %then %do;
        compute lbclsig;
            if lbclsig = 'Yes' then call define('lbclsig', 'style', 'style=[foreground=red background=yellow]');
        endcomp;
    %end;

    %else %if %upcase(&dset) = LBURIN %then %do;
        compute lbclsig;
            if lbclsig = 'Yes' then call define('lbclsig', 'style', 'style=[foreground=red background=yellow]');
        endcomp;
    %end;
    */
%mend prt_compute_exception;

