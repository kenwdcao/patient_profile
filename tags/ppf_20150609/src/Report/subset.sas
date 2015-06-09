

%macro subset(indata=,subject=,getvarlbl=);

data __prt;
    set &indata(in=___new);
    where &subjectvar="&subject";

    %if &compare = N %then %do;
    length __type__ $1 __diff__ $2048 __vars__ $2100 __chglbl__ $4100  __mdfnum__ 8 ;
    call missing(__type__, __diff__, __mdfnum__, __vars__, __chglbl__);
    %end;

     __n = _n_;

    drop &subjectvar;
run;

%getDsetInfo(indata=__prt,getNOBS=Y);


*deal with exceptions;
%data_exception;


*Ken Cao on 2014/11/04: Display table header even when zero record;
%if &nobs = 0 %then %do;
    data __temp;
        __temp__ = "&nodatatext";
    run;

    data __prt;
        set __prt __temp;
        drop __temp__;
        __n = 0;
    run;
%end;
%else %if %length(&getvarlbl) > 0 %then %do;
    %getVarLabelFrom1stNRow(&getvarlbl);
%end;

%mend subset;
