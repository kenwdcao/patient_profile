/*
    Program Name: EX.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2013/12/03
*/


%include '_setup.sas';

data ex0;
    set source.drug_administration;
/*    where admintyp_label = 'Study Drug';*/
    attrib
        ex          length = $20    label = 'Drug Exposure'
        exdt        length = 8    format = date9.
        cycnum      length = 8
    ;
    %subjid;

    **********modify***********;
    if admintyp_label='' then do;
        if DOSEADM=270 then admintyp_label='Paclitaxel';
            else if DOSEADM=15 then admintyp_label='Study Drug';
    end;
    ***************************;
    ex       = admintyp_label;
    *exdt   = input(admindt, mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of ADMINDT was changed to yyyy-mm-dd */
    exdt = input(admindt, yymmdd10.);
    cycnum = drugcyc;
    keep ex subjid exdt cycnum ;
run;

%sort(indata = ex0, sortkey = subjid exdt);

proc sql;
    create table ex1 as
    select distinct
        subjid,
        ex,
        put(min(exdt), mmddyy10.) as fdosedtc length = 20 label = 'First Date of Treatment',
        put(max(exdt), mmddyy10.) as ldosedtc length = 20 label = 'Last Date of Treatment',
        max(exdt) - min(exdt) + 1 as dur,
        max(cycnum) - min(cycnum) + 1 as ncycle label = 'Number of Cycles'
    from ex0
    group by subjid, ex
    ;
quit;

data ex2;
    set ex1(rename=ncycle=ncycle_);
    attrib
        duration    length = $40    label = 'Days of Treatment'
        ncycle      length = $10    label = 'Number of Cycles'
    ;
    duration = strip(put(dur, best.)) || '(Relative to First CD Dose)';
    if ncycle_^=. then ncycle=strip(put(ncycle_,best.));
    keep ex subjid fdosedtc ldosedtc duration ncycle;
run;


data pdata.ex;
    retain subjid ex fdosedtc ldosedtc duration ncycle;
    set ex2;
    keep subjid ex fdosedtc ldosedtc duration ncycle;
run;
