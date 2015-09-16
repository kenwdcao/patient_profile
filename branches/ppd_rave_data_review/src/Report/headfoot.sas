/******************************************************************************

macro: headfoot.sas
    @Author: Ken Cao (yong.cao@q2bi.com)
    @Initial Date: 2014/12/02

    This macro deal with titles and footnote.

------------------------------------------------------------------------------
Modification History:

  Ken Cao on 2015/03/01: Use macro variable &escapechar instead of ^ to refere 
                         ods escapechar character.
  Ken Cao on 2015/03/23: Add total page number for SAS 9.4.

******************************************************************************/



%macro headfoot(subject, ODS, systemtitle=, systemfooter=, user=);


%local ntitle;
%local nfoot;
%local i;
%local blank;



** selective title/footnote **;
%let ODS = %upcase(&ods);



%let ntitle = 0;
%let  nfoot = 0;
%let  blank = ;

%let         user = %upcase(&user);
%let  systemtitle = %upcase(&systemtitle);
%let systemfooter = %upcase(&systemfooter);

%if %length(&systemtitle) = 0 %then %let systemtitle = Y;
%if %length(&systemfooter) = 0 %then %let systemfooter = Y;
%if %length(&user) = 0 %then %let user = Y;

%chkYN(systemtitle, &systemtitle, Y);
%chkYN(systemfooter, &systemfooter, Y);
%chkYN(user, &user, Y);


* mockup dataset for titles and footnotes;
data _headft;
    length type $1 system $1 ods $20  seq 8 left $1024 center $1024 right $1024 text $1024 statement $1024;
    call missing(type, system, ods, seq, left, center, right, text, statement);
    if 0;
run;


** insert system titles and footnotes**;
proc sql;
    insert into _headft(type, system, ods, seq, left)
    values('T', 'Y',  ' ', 1,  "&escapechar.S={preimage=""&logo"" pretext="" &slogon""}");

    insert into _headft(type, system, ods, seq, left, center, right)
    values('T', 'Y',  'PS', 1, "Study ID: &studyid2", "Patient Profile", "Page &escapechar{thispage} of !#!");
    insert into _headft(type, system, ods, seq, left, center, right)
    values('T', 'Y',  'PDF', 1, "Study ID: &studyid2", "Patient Profile",  "Page &escapechar{thispage}");
    %if &showCoverPage = Y %then %do;
    insert into _headft(type, system, ods, seq, left, center, right)
    values('T', 'Y',  'RTF', 1, "Study ID: &studyid2", "Patient Profile", "{Page }{\field{\*\fldinst {PAGE }}}{ of }{\field{\*\fldinst{={\field{\*\fldinst {NUMPAGES}}} -1}}}");
    %end;
    %else %do;
    insert into _headft(type, system, ods, seq, left, center, right)
    values('T', 'Y',  'RTF', 1, "Study ID: &studyid2", "Patient Profile", "{Page }{\field{\*\fldinst {PAGE }}}{ of }{\field{\*\fldinst {NUMPAGES }}}");
    %end;
    %if &compare = N %then %do;
        insert into _headft(type, system, ods, seq, left, center, right)
        values('F', 'Y',  ' ', 10, "Data Transfer Date: &newtransferID", ' ', "Generated on &date.T&time");
    %end;
    %else %do;
        %if &showDeletedRecord = Y %then %do;
        insert into _headft(type, system, ods, seq, left, right)
        values('F',  'Y', ' ', 10, "&escapechar.S={backgroundcolor=&newcolor}New Record", 
                "&escapechar.S={backgroundcolor=&delcolor textdecoration=line_through}Deleted Record");
        insert into _headft(type, system, ods, seq, left, right)
        values('F',  'Y', ' ', 10, "&escapechar.S={backgroundcolor=&mdfcolor}Modified Record", 
                "&escapechar.S={backgroundcolor=&mdfvarcolor}Modified Value");
        %end;
        %else %do;
        insert into _headft(type, system, ods, seq, left, center, right)
        values('F',  'Y', ' ', 10, "&escapechar.S={backgroundcolor=&newcolor}New Record",
            "&escapechar.S={backgroundcolor=&mdfcolor}Modified Record", "&escapechar.S={backgroundcolor=&mdfvarcolor}Modified Value");
        %end;
        insert into _headft(type, system, ods, seq, left, center, right)
        values('F', 'Y',  ' ', 10, "Data Transfer Date: &newtransferID", "Benchmark Data Transfer Date: &oldtransferID", "Generated on &date.T&time");
    %end;
quit;


** insert customized titles and footnotes from demographic dataset **;
%if &user = Y %then %do;
%insertDMTitleFooter(&subject, &demodset);
%end;




** parepare for final SAS title/footnote statements **;

%let headerFooter = %str(** generate SAS title/foonote statement;

** replace double quotation string as two consecutive double quotation string **;
** remove statement from the list. ;
array txt{*} left center right text /*statement*/;
do i = 1 to dim(txt);
    txt[i] = prxchange('s/[""]/""/', -1, txt[i]);
end;

if left ^= ' ' then left = 'j=l "'||strip(left)||'"';
if right ^= ' ' then right = 'j=r "'||strip(right)||'"';
if center ^= ' ' then center = 'j=c "'||strip(center)||'"';


if statement ^= ' ' then sasstat = statement;
else if text ^= ' ' then sasstat = 'j=l "'||strip(text)||'"';
else sasstat = catx(' ', left, center, right);

);


data __titles0;
    set _headft;
    where type = 'T' and (ods = "&ODS" or ods = " ");
    %if &user = N %then %do;
        if system = ' ' then return;
    %end;
    %if &systemtitle = N %then %do;
        if system = 'Y' then return;
    %end;
    __ord + 1;
    output;
run;

proc sort data = __titles0; by seq __ord; run;

data __titles;
    set __titles0;
    __hdrord + 1;
    
    length sasstat $1024;
    &headerFooter;

    sasstat = 'title'||strip(put(__hdrord, best.))||' '||sasstat;
    call symput('ntitle', strip(put(_n_, best.)));
    keep sasstat ods system;
run;

%do i = 1 %to &ntitle;
    %local title&i;
    %local Tods&i;
%end;

data _null_;
    set __titles;
    call symput('title'||strip(put(_n_, best.)), strip(sasstat));
    call symput('Tods'||strip(put(_n_, best.)), strip(ods));
run;

%do i = 1 %to &ntitle;
    %if &&Tods&i = &ODS or %length(&&Tods&i) = 0 %then %do;
        &&title&i;
    %end;
%end;


data __footer;
    set _headft;
    where type = 'F' and (ods = "&ODS" or ods = " ");
    %if &user = N %then %do;
        if system = ' ' then return;
    %end;
    %if &systemfooter = N %then %do;
        if system = 'Y' then return;
    %end;
    __ord + 1;
    output;
run;

proc sort data = __footer; by descending seq descending __ord; run;

data __footer2;
    set __footer;
    retain __footord;
    if _n_ = 1 then __footord = 10;
    else __footord = __footord - 1;

    length sasstat $1024;
    &headerFooter;

    sasstat = 'footnote'||strip(put(__footord, best.))||' '||sasstat;
    call symput('nfoot', strip(put(_n_, best.)));
    keep sasstat __footord ods;
run;


%do i = %eval(11 - &nfoot) %to 10;
    %local foot&i;
    %local Fods&i;
%end;

data _null_;
    set __footer2;
    call symput('foot'||strip(put(__footord, best.)), strip(sasstat));
    call symput('Fods'||strip(put(__footord, best.)), strip(ods));
run;

%do i = %eval(11 - &nfoot) %to 10;
    %if &&Fods&i = &ODS or %length(&&Fods&i) = 0 %then %do;
        &&foot&i;
    %end;
%end;

%mend headfoot;

