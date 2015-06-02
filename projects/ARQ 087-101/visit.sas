/*
    Program Name: visit.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2013/12/24
*/

%include '_setup.sas';

/*dataset to be included*/
data _toBeIncl;
    informat dsetname $32. datevar $32.;
    input    dsetname $    datevar $;
    format   dsetname $32. datevar $32.;
    cards;
EG EGDTC
ES ESDTC
FU FUDTC
ICF CNSNTDTC
ICF1 UCNTDTC
LBC LBDTC
LBCOAG LBDTC
LBH LBDTC
LBTH LBDTC
LBTM LBDTC
LBU LBDTC
ME MEDTC
NT NTDTC
PDB PDDTC
PDT PDTADTC
PE PEDTC
PREG PREGDTC
SC SCLVDTC
TM TMDATEC
UNS UVDTC
VS VSDTC
;
run;

data all;
    length subid $15 event_id $40 date $10 source $32;
    call missing(subid, event_id, date, source);
    if 0;
run;


/*macro to combine all visit and visit date*/
%macro getAllVisitDate(masterDset,  output =, subjectvar = subid, librf = source);

    %local ndset;
    %local i;
    %local dset;
    %local dtvar;

    proc sql noprint;
        select count(*) 
        into: ndset
        from &masterDset
    ;
    quit;


    %do i = 1 %to &ndset;
        data _null_;
            set &masterDset (firstobs = &i obs = &i);
            call symput('dset',  strip(dsetname));
            call symput('dtvar', strip(datevar ));
        run;

        proc sql;
            insert into &output
            select distinct subid,
                            event_id,
                            &dtvar,
                            "%upcase(&dset)"
            from 
                &librf..&dset
            where 
                &dtvar is not missing   
            ;
        quit;

    %end;

%mend getAllVisitDate;

%getAllVisitDate(_toBeIncl, output = all);

data all2;
    set all;
    length visit $60 sdsetlbl $40.;
    visit    = put(event_id, $visit.);
    dsid     = open('source.'||source);
    sdsetlbl = attrc(dsid, 'label');
    rc       = close(dsid);
    visitnum = input(visit, vnum.);
    if visit not in ('Tumor Assessment', 'Unscheduled Visit') and visitnum = . then 
        do;
            put "ERR" "OR: No visitnum defined for visit " visit;
        end;
    drop event_id dsid rc;
run;

proc sort data = all2 nodup; by subid date visit sdsetlbl; run;

data all3;
    set all2;
        by subid date visit;
    length svupdes $1024;
    retain svupdes;
    if first.visit then svupdes = sdsetlbl;
    else svupdes = strip(svupdes)||"&escapechar.n"||sdsetlbl;
    if last.visit;
    drop source sdsetlbl;
run;

proc sort data = all3 out = all4; 
    by subid visitnum date ;
    where visit not in ('Tumor Assessment', 'Unscheduled Visit');;
run;

proc sort data = all3 out = all5; 
    by subid date;
    where visit in ('Tumor Assessment', 'Unscheduled Visit');
run;

data all6;
    set all4;
        by subid visitnum date ;
    length _date_ $10 __flag $1 _vnum_ 8;
    retain _date_ _vnum_;
    if first.subid then 
        do;
            _date_ = date;
            _vnum_ = visitnum;
        end;
    else if _date_ > date and _vnum_ < visitnum then
        do;
            __flag = 'Y';
            _date_ = date;
            _vnum_ = visitnum;
        end;
    else 
        do;
            _date_ = date;
            _vnum_ = visitnum;
        end;
    drop _vnum_ _date_;

run;

data all7;
    set all5 all6;
run;

proc sort data = all7; by subid date visitnum; run;

data out.visit;
    attrib
        subid    length = $40
        visit    length = $60    label = 'Visit'
        date     length = $60    label = 'Visit Date'
        svupdes  length = $1024  label = 'Source'
    ;
    set all7;
    drop visitnum;
run;
