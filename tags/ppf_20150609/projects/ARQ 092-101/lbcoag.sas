/*
    Program Name: lbcoag.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/22

    Modification:
    2014/11/24 Ken Cao: Keeps only baseline and abornormal post-baseline values;

*/
%include '_setup.sas';
/*Hematology*/
proc format;
    value $coag
    'coag_pt'='PT'
    'coag_ptt'='PTT'
    'coag_inr'='INR'
    ;

    invalue lbtestn
    'PT'=1
    'PTT'=2
    'INR'=3
    ;

run;

data collect ncollect;
    set source.lbcoag;
    if lbcoagyn=1 then output collect;
        else output ncollect;
run;

data collect_01;
    length lbtest lborresu $100 lborres $200 lblow lbhigh $60 lbrange $100 lbclsig $10 lbdtc $60 lbname $200 
            visit $100 visitnum 8;
    set collect(rename=(lbdtc=lbdtc_));
    format _all_;
    lbtest=put(analyte,$coag.);
    lborres=strip(lbres);
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
    lbtestn=input(lbtest,lbtestn.);
    keep subid lbtest lborres lborresu lblow lbhigh lbrange lbclsig lbdtc visit visitnum lbname lbtestn lbres rep_rngl rep_rngh;
run;

proc sort data=ncollect out=s_ncollect(keep=subid event_id lbcgynsp) nodupkey; by subid event_id; run;

data ncollect_01;
    length visit $100 visitnum 8 lborres $200 lbtest $100;
    set s_ncollect;
    visit=strip(put(event_id,$visit.));
    visitnum=input(put(event_id,$vnum.),best.);
    lborres=strip(lbcgynsp);
    lbtest='COAGULATION SAMPLE NOT COLLECTED';
    keep subid visit visitnum lborres lbtest;
run;

data lbcoag_;
    set collect_01 ncollect_01;
run;

proc sort data=lbcoag_; by subid visitnum lbtestn; run;

data lbcoag;
 set lbcoag_;
 %lablowhigh(low=REP_RNGL, high=REP_RNGH, result=LBORRES);
 drop __:;
run;

** Ken Cao on 2014/11/12: Insert color code note into dataset label **;
%addnote(indata=lbcoag, labrslt=lborres, labcat=Coagulation);

proc sort data = lbcoag; by subid lbtest lbdtc visit; run;

data pdata.lbcoag(label='Coagulation (Baseline and Abnormal Values)');
    retain subid lbtest lborresu visit lbdtc lbname  lbrange lborres lbclsig __label;
    keep subid lbtest lborresu visit lbdtc lbname  lbrange lborres lbclsig __label;
    set lbcoag;
    if lbtest^='COAGULATION SAMPLE NOT COLLECTED' and (lborres='Not Done' or lborres='') then delete;
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
