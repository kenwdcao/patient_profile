/*
    Program Name: lburin.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/22

    Modification:
    2014/11/24 Ken Cao: Keeps only baseline and abornormal post-baseline values;

*/
%include '_setup.sas';
/*Hematology*/
proc format;
    value $urin
    'urine_protein'='Protein'
    'urine_specific_gravity'='Specific Gravity'
    'urine_glucose'='Glucose'
    'urine_microscopic_wbc'='WBC'
    'urine_microscopic_rbc'='RBC'
    ;

    invalue lbtestn
    'Protein'=1
    'Specific Gravity'=2
    'Glucose'=3
    'WBC'=4
    'RBC'=5
    ;

run;

data collect ncollect;
    set source.lbu;
    if lbuyn=1 then output collect;
        else output ncollect;
run;

data collect_01;
    length lbtest lborresu $100 lborres $200 lblow lbhigh $60 lbrange $100 lbclsig $10 lbdtc $60 lbname $200 
            visit $100 visitnum 8;
    set collect(rename=(lbdtc=lbdtc_ lborres=lborres_));
    format _all_;
    lbtest=put(analyte,$urin.);
    lborres=strip(lborres_);
    ** Ken Cao on 2014/12/01: Use E (instead of ^) for exponent in unit**;
    if exponent^=. and lbunit^='' then lborresu='10E'||strip(put(exponent,best.))||strip(lbunit);
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
    lbtestn=input(lbtest,lbtestn.);
    keep subid lbtest lborres lborresu lblow lbhigh lbrange lbclsig lbdtc visit visitnum lbname lbtestn lborres_ rep_rngl rep_rngh;
run;

proc sort data=ncollect out=s_ncollect(keep=subid event_id lbuynsp) nodupkey; by subid event_id; run;

data ncollect_01;
    length visit $100 visitnum 8 lborres $200 lbtest $100;
    set s_ncollect;
    visit=strip(put(event_id,$visit.));
    visitnum=input(put(event_id,$vnum.),best.);
    lborres=strip(lbuynsp);
    lbtest='URINE SAMPLE NOT COLLECTED';
    keep subid visit visitnum lborres lbtest;
run;

data lburin_;
    set collect_01 ncollect_01;
run;

proc sort data=lburin_; by subid visitnum lbtestn; run;

data lburin;
 set lburin_;
 %lablowhigh(low=REP_RNGL, high=REP_RNGH, result=LBORRES);
 drop __:;
run;


** Ken Cao on 2014/11/12: Insert color code note into dataset label **;
%addnote(indata=lburin, labrslt=lborres, labcat=Urinalysis);

proc sort data = lburin; by subid lbtest lbdtc visit; run;

data pdata.lburin(label='Urinalysis (Baseline and Abnormal Values)');
    retain subid lbtest lborresu  visit lbdtc lbname lbrange lborres lbclsig __label;
    keep subid lbtest lborresu  visit lbdtc lbname lbrange lborres lbclsig __label;
    set lburin;
    if lbtest^='URINE SAMPLE NOT COLLECTED' and (lborres='Not Done' or lborres='') then delete;
    label
    lbtest='Parameter'
    lborres='Result'
    lborresu='Unit'
    lbrange='Normal Range'
    visit='Visit'
    lbdtc='Date/Time'
    lbclsig='Clinical Significance'
    lbname='Lab Name'
    ;

    *** Ken Cao on 2014/11/24: Keeps only baseline and abornormal post-baseline values ;
    where visit = 'Pre-Study' or lbclsig > ' ';
run;
