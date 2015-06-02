/*
    Program Name: glucose.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/25

    Modification
    2014/11/24 Ken Cao: Keeps only baseline and abornormal post-baseline values;

*/
%include '_setup.sas';

proc format;
    value $gluc
    'chem_glucose'='Glucose'
    'chem_insulin'='Insulin'
    ;

    value lbtpt
    1 = 'Pre-dose'
    2 = '2 Hours Post Dose'
    3 = '4 Hours Post Dose'
    4 = '6 Hours Post Dose'
    5 = '10 Hours Post Dose'
    6 = '24 Hours Post Dose'
    ;

run;

/*Glucose Metabolism*/
data collect ncollect;
    set source.lbgm;
    if lbgmyn^=0 then output collect;
        else output ncollect;
run;

data collect_01;
    length lbtest lborresu $100 lborres $200 lblow lbhigh $60 lbrange $100 lbclsig $10 lbdtc $60 lbname $200 
            visit $100 visitnum 8 lbfast $10 lbtpt $60;
    set collect(rename=(lbdtc=lbdtc_ lborres=lborres_ lbfast=lbfast_));
    lbtest=put(analyte,$gluc.);
    lborres=strip(lborres_);
    ** Ken Cao on 2014/12/01: Use E (instead of ^) for exponent in unit**;
    if exponent^=. and lbunit^='' then lborresu='10E'||strip(put(exponent,best.))||' '||strip(lbunit);
        else if exponent=. and lbunit^='' then lborresu=strip(lbunit);
    if rep_rngl^=. then lblow=strip(put(rep_rngl,best.));
    if rep_rngh^=. then lbhigh=strip(put(rep_rngh,best.));
    if lblow^='' and lbhigh^='' then lbrange=strip(lblow)||' - '||strip(lbhigh);
        else if lblow^='' and lbhigh='' then lbrange=strip(lblow)||' - ';
            else if lblow^='' and lbhigh='' then lbrange=' - '||strip(lbhigh);
    if lbcs=1 then lbclsig='No';
        else if lbcs=2 then lbclsig='Yes';
    if lbdtc_^='' and lbtmc^='' then lbdtc=strip(lbdtc_)||'T'||strip(lbtmc);
        else if lbdtc^='' and lbtmc='' then lbdtc=strip(lbdtc);
    visit=strip(put(event_id,$visit.));
    visitnum=input(put(event_id,$vnum.),best.);
    if nd=1 then lborres='Not Done';
    lbname=strip(lab_name);
    if lbtest='Glucose' then lbtestn=1;
        else if lbtest='Insulin' then lbtestn=2;
    if lbfast_=1 then lbfast='Yes';
        else if lbfast_=0 then lbfast='No';
    lbtpt=put(lgbmtp,lbtpt.);
    keep subid lbtest lborres lborresu lblow lbhigh lbrange lbclsig lbdtc visit visitnum lbname lbtestn 
        lbfast rep_rngl rep_rngh lbtpt lgbmtp;
run;

proc sort data=ncollect out=s_ncollect(keep=subid event_id lbghmnsp) nodupkey; by subid event_id; run;

data ncollect_01;
    length visit $100 visitnum 8 lborres $200 lbtest $100;
    set s_ncollect;
    visit=strip(put(event_id,$visit.));
    visitnum=input(put(event_id,$vnum.),best.);
    lborres=strip(lbghmnsp);
    lbtest='GLUCOSE AND INSULIN NOT TESTED';
    keep subid visit visitnum lborres lbtest;
run;

data glucose_;
    set collect_01 ncollect_01;
run;

proc sort data=glucose_; by subid visitnum lbtestn lgbmtp; run;

data glucose;
 set glucose_;
 %lablowhigh(low=REP_RNGL, high=REP_RNGH, result=LBORRES);
 drop __:;
run;


** Ken Cao on 2014/11/12: Insert color code note into dataset label **;
%addnote(indata=glucose, labrslt=LBORRES, labcat=Glucose Metabolism);

proc sort data = glucose; by subid lbtest lbdtc visit; run;

data pdata.glucose(label='Glucose Metabolism');
    retain subid lbtest lborresu  visit lbtpt lbdtc lbname lbrange lborres lbfast lbclsig __label;
    keep subid lbtest lborresu  visit lbtpt lbdtc lbname lbrange lborres lbfast lbclsig __label;
    set glucose;
    if lbtest^='GLUCOSE AND INSULIN NOT TESTED' and (lborres='Not Done' or lborres='') then delete;
    label
    lbtest='Parameter'
    lborres='Result'
    lborresu='Unit'
    lbrange='Normal Range'
    visit='Visit'
    lbdtc='Date/Time'
    lbclsig='Clinical Significance'
    lbname='Lab Name'
    lbfast='Fasting Blood Sample?'
    lbtpt='Scheduled Time'
    ;

    /*
    *** Ken Cao on 2014/11/24: Keeps only baseline and abornormal post-baseline values ;
    where visit = 'Pre-Study' or lbclsig > ' ';
    */
run;

