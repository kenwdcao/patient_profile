/*********************************************************************
 Program Nmae: insertDsetHeadFoot.sas
  @Author: Ken Cao
  @Initial Date: 2015/03/29
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%macro insertDsetHeadFoot();

%local existTitle;
%local existFooter;

%let  existTitle = 0;
%let existFooter = 0;

data _dsetHeadFoot;
    length headfoot $255 type $1;
    call missing(headfoot, type);
    if 0;
run;

data _null_;
    set __prt(obs=1);
    pidt=prxparse('/^__DTITLE\d?$/i');
    pidf=prxparse('/^__DFOOTNOTE\d?$/i');

    ** in case __PRT does not include any character variable;
    length ___dummy___ $1;
    ___dummy___ = ' '; 

    array ___char{*} _character_; 
    do i = 1 to dim(___char);
        if prxmatch(pidt,strip(vname(___char[i]))) = 1 then call symput('existTitle','1');
        else if prxmatch(pidf,strip(vname(___char[i])))>0 then call symput('existFooter','1');
    end;
    stop;
run;

%if &existTitle = 0 and &existFooter = 0 %then %return;

data _dsetHeadFoot;
    length headfoot $255 type $1;
    set __prt(obs = 1 keep = %if &existTitle = 1 %then __dtitle:; %if &existFooter = 1 %then __dfootnote:;);
    %if &existTitle = 1 %then %do;
        array _header{*} __dtitle:;
        do i = 1 to dim(_header);
            if _header[i] = ' ' then continue;
            headfoot = _header[i];
            type = 'T';
            output;
        end;
    %end;
    %if &existFooter = 1 %then %do;
        array _footer{*} __dfootnote:;
        do i = 1 to dim(_footer);
            if _footer[i] = ' ' then continue;
            headfoot = _footer[i];
            type = 'F';
            output;
        end;
    %end;
run;

%mend insertDsetHeadFoot;
