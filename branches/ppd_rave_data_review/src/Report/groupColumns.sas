/*********************************************************************
 Program Nmae: groupColumns.sas
  @Author: Ken Cao
  @Initial Date: 2015/03/27
 
  This program detects if multiple columns needs to be grouped under
  a title.

 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 
 Ken Cao on 2015/03/29: Add support for three level group label. 

*********************************************************************/

%*local colstat;
%macro groupColumns(ods);

%local isGroupExist;
%local isBlnkColExist;

%let   isGroupExist = 0;
%let isBlnkColExist = 0;
%let        colstat = ;
%let            ods = %upcase(&ods);

proc contents data=__prt noprint out=_cnt(keep=name label varnum where=(name ^=: '__')); 
run;

proc sort data = _cnt;
    by varnum;
    where name ^=: '__' and upcase(name) ^= "%upcase(&subjectvar)";
run;

data _group0;
    set _cnt;

    length group1 group1 $255;
    if index(label, "@:") = 0 then return;
    call symput('isGroupExist', '1');
    group1 = scan(label, 2, "@:");
    group2 = scan(label, 3, "@:");
    label  = scan(label, 1, "@:");
    
    group1 = tranwrd(group1, '"', '""');
    group2 = tranwrd(group2, '"', '""');
    label  = tranwrd(label, '"', '""');

    keep group1 group2 label name varnum;
run;

%if &isGroupExist = 0 %then %return;

data _group1;
    set _group0;
    length grpord1 grpord2 8 lastgrp1 lastgrp2 $255;
    retain grpord1 grpord2 lastgrp1 lastgrp2 ;

    if group2 ^= ' ' and group1 = ' ' then group1 = '09'x;

    array order{*} grpord1 grpord2 ;
    array grp{*} group1 group2;
    array lgrp{*} lastgrp1 lastgrp2;

    if _n_ = 1 then do i = 1 to dim(grp);
         lgrp[i] = ' ';
        order[i] = 0;
    end;

    do i = 1 to dim(grp);
        if grp[i] ^= lgrp[i] then do;
            order[i] = order[i] + 1;
             lgrp[i] = grp[i];
        end;
    end;
run;

data _group2;
    set _group1;
        by grpord2 grpord1 varnum;

    keep name column1st column2st column1en column2en label group1 group2 column define;

    length column1st column2st column1en column2en column define $1024;

    if first.grpord2 then do;
        if group2 ^= ' ' then 
        %if &ods = RTF %then 
        column2st = "(""&escapeChar.S={just=c borderbottomwidth=1 borderbottomcolor=colors('border')}"||strip(group2)||'"';
        %else
        column2st = "(""&escapeChar{style [just=c borderbottomwidth=1 borderbottomcolor=colors('border')]"||strip(group2)||'}"';
        ;
    end;
    if first.grpord1 then do;
        if group1 ^= ' '  then 
        %if &ods = RTF %then
        column1st = " (""&escapeChar.S={just=c borderbottomwidth=1 borderbottomcolor=colors('border')}"||strip(group1)||'" ';
        %else
        column1st = " (""&escapeChar{style [just=c borderbottomwidth=1 borderbottomcolor=colors('border')]"||strip(group1)||'}" ';
        ;
    end;

    if last.grpord1 then do;
        if group1 ^= ' ' then column1en = ')';
    end;
    if last.grpord2 then do;
        if group2 ^= ' ' then column2en = ')';
    end;
    
    column = catx(' ', column2st, column1st, name, column1en, column2en);

    
    if group1 ^=  ' ' or group2 ^= ' ' then do;
        define = 'define '||strip(name)||" / """||strip(label)||""" style(header)=[bordertopwidth=1 bordertopcolor=colors('border')];";
    end;
run;


data _null_;
    set _group2(rename=(define=_define_ column=_column_)) end = _eof_;
    length column define $32767 _column2_ $1024 isBlnkColExist 8;
    retain column define _column2_ isBlnkColExist;
    if _n_ = 1 then do;
       isBlnkColExist = 0;
               define = _define_;
               column = _column_;
            _column2_ = _column_;
    end;
    else do;
        if strip(_column_) =: '(' and strip(reverse(_column2_)) =: ')' then do;
            column = strip(column)||' ___blankcol___ '||_column_;
            isBlnkColExist = 1;
        end;
        else column = strip(column)||' '||_column_;
               define = strip(define)||' '||_define_;
            _column2_ = _column_;
    end;
    if _eof_ then do;
        if isBlnkColExist = 1 then do;
            call symput('isBlnkColExist', '1');
            define = strip(define)
                ||'define ___blankcol___/" " '
                %if &ods = RTF %then
                || " style(column)=[borderbottomwidth=0 borderbottomcolor=white width=0];";
                %else
                || " style(column)=[borderbottomwidth=0 borderbottomcolor=white];";
                ;
        end;
    call symput('colstat', 'Column '||strip(column)||' __:; '||define);
    end;
run;


** Physically insert column ___BLANKCOL___ into __PRT other wise width=0 does not work;
%if &isBlnkColExist = 1 and &&ods = RTF %then %do;
proc sql;
    alter table __prt
    add ___blankcol___ char length=1;
    update __prt
    set ___blankcol___ = ' ';
quit;
%end;


%put &colstat;

%mend groupColumns;

