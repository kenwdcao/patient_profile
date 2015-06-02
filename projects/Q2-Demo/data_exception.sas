/********************************************************************************
 Program Nmae: prt_exception.sas
  @Author: 
  @Initial Date: 2015/03/11
 
 Interface to let user alter report dataset _prt.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/

%macro data_exception();

%macro labur();
%local nvar;
%local i;

%let nvar = 0;

data _null_;
    set __prt(obs=2 drop= __:);
    array _char_{*} _character_;
    call symput('nvar', strip(put(dim(_char_), best.)));
run;

%if &nvar = 0 %then %return;

%do i = 1 %to &nvar;
    %local var&i;
    %local lbl&i;
    %local unit&i;
    %local range&i;
%end;

data _null_;
    set __prt(obs=2 drop= __:);
    array _char_{*} _character_;
    if _n_ = 1 then do __i__ = 1 to dim(_char_);
        call symput('var'||strip(put(__i__, best.)), strip(vname(_char_[__i__])));
        call symput('lbl'||strip(put(__i__, best.)), strip(tranwrd(vlabel(_char_[__i__]), '"', '""')));
        call symput('unit'||strip(put(__i__, best.)), strip(_char_[__i__]));
    end;
    else if _n_ = 2 then do __i__ = 1 to dim(_char_);
        call symput('range'||strip(put(__i__, best.)), strip(_char_[__i__]));
    end;
run;

%do i = 1 %to &nvar;
    /*
    %put &&var&i;
    %put &&lbl&i;
    %put &&unit&i;
    %put &&range&i;
    */
    %let  unit&i = &escapechar.S={foreground=cx8F8F8F fontsize=7pt just=l}&&unit&i;
    %let range&i = &escapechar.S={foreground=cx8F8F8F fontsize=7pt just=l}&&range&i;;

%end;

proc sql;
    alter table __prt
    modify &var1 label = "%str(&lbl1)&splitchar%str(&unit1)&splitchar%str(&range1)"
    %do i = 2 %to &nvar;
        , &&var&i label = "%str(&&lbl&i)&splitchar%str(&&unit&i)&splitchar%str(&&range&i)"
    %end;
    ;

    delete from __prt
    where monotonic() <= 2;
    /*
    where index(__EDC_TREENODEID, '-Unit') > 0
    or index(__EDC_TREENODEID, '-NR') > 0
    */
    ;
quit;
%mend labur;

%if &nobs > 0 and
 (  %upcase(&dset) = CHEM1 or 
    %upcase(&dset) = CHEM2 or
    %upcase(&dset) = COAG or
    %upcase(&dset) = HEM1 or
    %upcase(&dset) = HEM2 or
    %upcase(&dset) = URINE or
    %upcase(&dset) = IMM1 or
    %upcase(&dset) = IMM2
)
%then %do;
    %labur;
%end;
%mend data_exception;
