/*
    Program Name: _publicMacros.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2013/12/02

*/


%macro subjid();
    length subjid $20;
    label subjid  = 'Subject No.';
    subjid = ssid;
%mend subjid;

%macro sort(indata =, outdata =, sortkey=, nodupkey = N);
    proc sort data = &indata %if %length(&outdata)> 0 %then out = &outdata; %if %upcase(&nodupkey = Y) %then nodupkey;;
        by &sortkey;
    run;
%mend sort;

%macro concat(invars =, outvar =, nblank = 2);
    
    %local nvar;
    %local i;
    %local j;
    %local dlm;
    %local nblank2;

    %let nblank2 = %eval(&nblank - 1);

    %let invars = %sysfunc(prxchange(s/\s+/ /, -1, &invars));
    %let invars = %sysfunc(prxchange(s/^\s//, -1, &invars));
    %let invars = %upcase(&invars);
    %let nvar   = %sysfunc(countc(&invars, " "));

    %if %length(&invars) = 0 %then %let nvar = 0;
    %else %let nvar = %eval(&nvar + 1);

    %do i =  1 %to &nvar;
        %local invar&i;
        %let invar&i = %scan(&invars, &i, " ");
    %end;
    
    &outvar = %do i = 1 %to &nvar; "&escapechar{style [fontweight = bold]"|| strip(vlabel(&&invar&i))||'}: '||ifc(&&invar&i > ' ', strip(&&invar&i), 'N/A') %do j = 1 %to &nblank; %str(|| " ")  %end; || %end; " ";

/*    &outvar = %do i = 1 %to &nvar; strip(vlabel(&&invar&i))||': '||ifc(&&invar&i > ' ', strip(&&invar&i), 'N/A') %do j = 1 %to &nblank; %str(|| " ")  %end; || %end; " ";*/
%mend concat;


%macro dy(indate, format);
    if __fdosedt > . and input(&indate, &format.) > . then 
        _dy  = input(&indate, &format.) - __fdosedt + (input(&indate, &format.) >= __fdosedt)
%mend dy;


%macro makeBlankRecord(dset);
    data __prt0;
        __temp = .;
    run;

    data __prt1;
        set pdata.&dset;
        where 0;
    run;

    data __prt;
        set __prt1 __prt0;
        drop __temp;
        drop &subjectvar;
    run;
%mend makeBlankRecord;


%macro _chkMDYDate(indate);
    __Complete = 0;
    length __month $2 __date $2  __year $4;
    &indate    = prxchange('s/^\s//' , -1, &indate); /*remove leading blank (\r \n \t ...)*/
    if countc(&indate,'./-') = 2 then
        do;
            if prxmatch('/\d{1,2}([.\/-])\d{1,2}\1\d{4}/', &indate) = 1 then 
                do;
                    __month = scan(&indate, 1, './-');
                    __date  = scan(&indate, 2, './-');
                    __year  = scan(&indate, 3, './-');

                    if prxmatch('/0?[1-9]|1[0,1,2]/', __month) = 0 then 
                        put "ERR" "OR: 1 In" "valid Date:" &indate;
                    else if prxmatch('/31|[123]0|0?[1-9]|[12][1-9]/', __date) = 0 then
                        put "ERR" "OR: 2 In" "valid Date:" &indate;
                    else if prxmatch('/19|20\d{2}/', __year) = 0 then 
                        put "ERR" "OR: 3 In" "valid Date:" &indate;
                    else if __month in( '02', '2') and __date in ('30', '31') then
                        put "ERR" "OR: 4 In" "valid Date:" &indate;
                    else if __month in ('04', '06', '09', '11', '4' ,'6', '9') 
                        and __date in ('31') then
                            put "ERR" "OR: 5 In" "valid Date:" &indate;
                    else if __month in ('02', '2') and __date = '29' 
                        and (mod(input(__year, best.),4) > 0) then 
                            put "ERR" "OR: 6 In" "valid Date:" &indate;
                    else if __month in ('02', '2') and __date = '29' 
                        and (mod(input(__year, best.),4) = 0 
                        and mod(input(__year, best.),100) = 0 
                        and mod(input(__year, best.),400) > 0) then 
                            put "ERR" "OR: 7 In" "valid Date:" &indate;
                    else __complete = 1;
                end; 
        end;
%mend _chkMDYDate;

/* Ken Cao on 2014/10/24: Add a new macro to check yyyy-mm-dd date */

%macro _chkYMDDate(indate);
    __Complete = 0;
    length __month $2 __date $2  __year $4;
    &indate    = prxchange('s/^\s//' , -1, &indate); /*remove leading blank (\r \n \t ...)*/
    if countc(&indate,'./-') = 2 then
        do;
            if prxmatch('/\d{4}([.\/-])\d{1,2}\1\d{1,2}/', &indate) = 1 then 
                do;
                    __month = scan(&indate, 2, './-');
                    __date  = scan(&indate, 3, './-');
                    __year  = scan(&indate, 1, './-');

                    if prxmatch('/0?[1-9]|1[0,1,2]/', __month) = 0 then 
                        put "ERR" "OR: 1 In" "valid Date:" &indate;
                    else if prxmatch('/31|[123]0|0?[1-9]|[12][1-9]/', __date) = 0 then
                        put "ERR" "OR: 2 In" "valid Date:" &indate;
                    else if prxmatch('/19|20\d{2}/', __year) = 0 then 
                        put "ERR" "OR: 3 In" "valid Date:" &indate;
                    else if __month in( '02', '2') and __date in ('30', '31') then
                        put "ERR" "OR: 4 In" "valid Date:" &indate;
                    else if __month in ('04', '06', '09', '11', '4' ,'6', '9') 
                        and __date in ('31') then
                            put "ERR" "OR: 5 In" "valid Date:" &indate;
                    else if __month in ('02', '2') and __date = '29' 
                        and (mod(input(__year, best.),4) > 0) then 
                            put "ERR" "OR: 6 In" "valid Date:" &indate;
                    else if __month in ('02', '2') and __date = '29' 
                        and (mod(input(__year, best.),4) = 0 
                        and mod(input(__year, best.),100) = 0 
                        and mod(input(__year, best.),400) > 0) then 
                            put "ERR" "OR: 7 In" "valid Date:" &indate;
                    else __complete = 1;
                end; 
        end;
%mend _chkYMDDate;
