* Program Name: _publicMacros.sas;
* Author: Ken Cao (yong.cao@q2bi.com);
* Initial Date: 18/02/2014;


%macro subjid() 
    / DES = 'Remove prefix "ARQ001_" from original subject identifier';

    subjid = translate(substr(subjid, 8), '-', '_'); 
%mend subjid;


%macro numDate2Char(numdate=, chardate=, datefmt= YYMMDD10.) 
    / DES = 'Conver numeric date to string date based on given format (default is YYMMDD10.)';

    &chardate = ifc(&numdate > ., put(&numdate, &datefmt), ' ');
%mend numDate2Char;


%macro YesNo2YN(invar)
    / DES = 'Conver Yes/No to Y/N';
    &invar = substr(&invar, 1, 1);
%mend YesNo2YN;


%macro labvalue(value=, abnfl=, outvar=) 
    /DES = 'Generate color code lab test value';
    if &abnfl = 'Not Done' then &outvar = 'ND';
    else 
        do;
            &outvar = ifc(&value>., strip(put(&value, best.)), ' ');
            if &abnfl = 'Abnormal NCS' then &outvar = strip(&outvar)||'(ABN NCS)';
            else if &abnfl = 'Abnormal CS' then &outvar = strip(&outvar)||'(ABN CS)';
            else if &abnfl = 'Normal' then &outvar = strip(&outvar)||'(N)';
        end;
    if &abnfl = 'Abnormal CS' then &outvar = "&escapechar{style [foreground=&abncscolor]"||strip(&outvar)||"}";
        else if &abnfl = 'Abnormal NCS' then &outvar = "&escapechar{style [foreground=&abnncscolor]"||strip(&outvar)||"}";
%mend labvalue;


%macro concat(invars=, outvar=, ncol =, volume=155)
    / DES = 'Concatenate a list of variables. Each value is prefixed by varaible label'
;
    
    %local nvar;
    %local i;
    %local j;
    %local dlm;
    %local avglen;

    
    %let invars = %sysfunc(prxchange(s/\s+/ /, -1, &invars));
    %let invars = %sysfunc(prxchange(s/^\s//, -1, &invars));
    %let invars = %upcase(&invars);
    %let nvar   = %sysfunc(countc(&invars, " "));

    %if %length(&invars) = 0 %then %let nvar = 0;
    %else %let nvar = %eval(&nvar + 1);
    
    %if %length(&ncol) = 0 %then %let ncol = &nvar;
    %if &ncol < &nvar %then %let ncol = &nvar;

    __avglen = int(&volume/&ncol);  

    length __part1-__part&nvar $256 __sect1-__sect&nvar $256;

    %do i =  1 %to &nvar;
        %local invar&i;
        %let invar&i = %scan(&invars, &i, " ");
        __part&i = ifc(&&invar&i > ' ', &&invar&i, 'N/A');
        __len1   = length(__part&i);
        __len2   = __avglen - length(vlabel(&&invar&i)) - 2;

        __pid    = prxparse("/{style \[[^]}]*\]([^}]*)}$/i");
        __rc     = prxmatch(__pid, strip(__part&i));
        __maxlen&i = max(__len1, __len2);

        if __rc > 0 and length(prxposn(__pid, 1, __part&i)) < __len2 then 
            do; 
                __part&i = strip(__part&i)||repeat('08'x, __len2 - length(prxposn(__pid, 1, __part&i))-1);
                __maxlen&i = length(__part&i);
            end;

        __sect&i = "&escapechar{style [fontweight = bold]" || vlabel(&&invar&i) ||'}: '
                    ||substr(__part&i, 1, __maxlen&i) || '08'x;
    %end;

    &outvar = strip(__sect1) %do i =2 %to &nvar; || "&escapechar{style [foreground=black]}" ||strip(__sect&i) %end;

%mend concat;


%macro getCycle()
    / DES = 'Extract cycle information from variable WRKFLWID'
;
    __pid = prxparse('/(?<=^\d{4}-\d{2}-\d{2})(.*)(?= \d{1,2}$)/i');
    length __visit $40 __vdate $20;
    __rc = prxmatch(__pid, strip(WRKFLWID));
    __visit = upcase(prxposn(__pid, 0, strip(WRKFLWID)));
    __visit = tranwrd(__visit, 'CYCLE CYCLE', 'CYCLE'); 
    __visit = strip(__visit);
    __pid2 = prxparse('/^\d{4}-\d{2}-\d{2}/i');
    __rc = prxmatch(__pid2, strip(WRKFLWID));
    __vdate = strip(prxposn(__pid2, 0, strip(WRKFLWID)));
%mend getCycle;



%macro getDate(leadq=, numdate=)
    / DES = 'Create character date in consideration of leading question'
;
    length __date $40;
    if &leadq = 'No' then 
        do;
            if &numdate > 0 then 
                do;
                    %numDate2Char(numdate=&numdate, chardate=__date);
                    __date = strip(__date)||'(NOT DONE)';
                end;
            else
                do;
                    __date = 'NOT DONE';
                end;
        end;
    else
        do;
            %numDate2Char(numdate=&numdate, chardate=__date);
        end;
    
%mend getDate;


%macro getCycleDate(leadq=, numdate=)
    /DES = 'Include macro getCycle and getDate'
;
    %getCycle();
    %getDate(leadq=&leadq, numdate=&numdate);
%mend getCycleDate;

%macro getvnum(visit);
    visitnum=input(put(&visit,$vnum.),best.);
%mend getvnum;


%macro sendUnit2Header();

    %local ntest;
    %local i;
    
    data _null_;
        set __prt (obs = 1);
        __ntest = 0;
        array lab{*} N_:;
        __ntest = dim(lab);
        call symput('ntest', strip(put(__ntest, best.)));
    run;

    %do i = 1 %to &ntest;
        %local lbl&i;
        %local var&i;
    %end;

     data _null_;
        set __prt (obs = 1);
        array lab{*} N_:;
        __ntest = dim(lab);
        do i = 1 to dim(lab);
            call symput('lbl'||strip(put(i, best.)), strip(lab[i]));
            call symput('var'||strip(put(i, best.)), strip(vname(lab[i])));
        end;
     run;

     data __prt;
        set __prt(firstobs = 2);
        %do i = 1 %to &ntest;
            label &&var&i = "&&lbl&i";
        %end;
     run;

%mend sendUnit2Header;
