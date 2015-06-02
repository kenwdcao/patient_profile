
%macro getVarLabelFrom1stNRow(getvarlbl);
%local ncvar;
%local nnvar;
%local nvar;
%local i;
%local isNumVarExist;
%local blank;

%let  nvar = 0;
%let ncvar = 0;
%let nnvar = 0;

%let isNumVarExist = 0;
%let blank =;

%if %length(&getvarlbl) = 0 %then %return;
%else %if %sysfunc(prxmatch(/^\d+$/, &getvarlbl)) = 0  %then %do;
    %put ERR&blank.OR: Invalid value for parameter GETVARLBL.;
    %return;
%end;

data _null_;
    set __prt(obs=1 drop= __:);
    array _char_{*} _character_;
    call symput('nvar', strip(put(dim(_char_), best.)));
    call symput('ncvar', strip(put(dim(_char_), best.)));
    __dummy__ = 0;
    array _num_{*} _numeric_;
    do i = 1 to dim(_num_);
        if upcase(vname(_num_[i])) =: '__' or upcase(vname(_num_[i])) = 'I' then continue;
        call symput('isNumVarExist', '1');
    end;
run;

%if &isNumVarExist = 1 %then %do;
data _null_;
    set __prt(obs=1 drop= __:);
    array _num_{*} _numeric_;
    array _char_{*} _character_;

    call symput('nvar', strip(put(dim(_char_)+dim(_num_), best.)));
    call symput('nnvar', strip(put(dim(_num_), best.)));
run;
%end;

%if &nvar = 0 %then %return;

%do i = 1 %to &nvar;
    %local var&i;
    %local lbl&i;
    %local subjlbl&i;
%end;

data _null_;
    set __prt(obs=1 drop= __:);
    array _char_{*} _character_;
    do __i__ = 1 to dim(_char_);
        call symput('var'||strip(put(__i__, best.)), strip(vname(_char_[__i__])));
        call symput('lbl'||strip(put(__i__, best.)), strip(tranwrd(vlabel(_char_[__i__]), '"', '""')));
    end;
    %if &isNumVarExist = 1 %then %do;
    array _num_{*} _numeric_;
    do __i__ = 1 to dim(_num_);
    call symput('var'||strip(put(__i__ + dim(_char_),  best.)), strip(vname(_num_[__i__])));
    call symput('lbl'||strip(put(__i__ + dim(_char_) ,  best.)), strip(tranwrd(vlabel(_num_[__i__]), '"', '""')));
    %end;
run;

data _null_;
    set __prt(obs=&getvarlbl drop=__:) end = _eof_;
    array _char_{*} %do i=1 %to &ncvar; &&var&i %end;;
    length ____cvar1 - ____cvar&ncvar $32767;
    retain ____cvar1 - ____cvar&ncvar;
    array _cvar_{*} ____cvar1 - ____cvar&ncvar;
    do __i__ = 1 to &ncvar;
        if _n_ = 1 then _cvar_[__i__] = _char_[__i__];
        else _cvar_[__i__] = trim(_cvar_[__i__])||"&splitchar"||_char_[__i__];
    end;

    if _eof_ then do __i__ = 1 to &ncvar;
        call symput('subjlbl'||strip(put(__i__, best.)), strip(_cvar_[__i__]));
    end;
run;

proc sql;
    alter table __prt
    modify &var1 label = "%str(&lbl1)&splitchar%str(&subjlbl1)"
    %do i = 2 %to &nvar;
        , &&var&i label = "%str(&&lbl&i)&splitchar%str(&&subjlbl&i)"
    %end;
    ;

    delete from __prt
    where monotonic() <= &getvarlbl;
quit;
%mend getVarLabelFrom1stNRow;
