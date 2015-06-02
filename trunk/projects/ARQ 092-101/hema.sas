/*
    Program Name: hema.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/21

    Modification:
    2014/11/24 Ken Cao: Keeps only baseline and abornormal post-baseline values;
*/
%include '_setup.sas';

/*Hematology*/
proc format;
    value $hema
    'hem_bands'='Bands (Absolute)'
    'hem_bands_absolute'='Bands (%)'
    'hem_basophils'='Basophils (%)'
    'hem_basophils_absolute'='Basophils (Absolute)'
    'hem_eosinophils'='Eosinophils (%)'
    'hem_eosinophils_absolute'='Eosinophils (Absolute)'
    'hem_hematocrit'='Hematocrit'
    'hem_hemoglobin'='Hemoglobin'
    'hem_lymphocytes'='Lymphocytes (%)'
    'hem_lymphocytes_absolute'='Lymphocytes (Absolute)'
    'hem_monocytes'='Monocytes (%)'
    'hem_monocytes_absolute'='Monocytes (Absolute)'
    'hem_neutrophils'='Neutrophils (%)'
    'hem_neutrophils_absolute'='Neutrophils (Absolute)'
    'hem_platelets'='Platelets'
    'hem_rbc'='RBC'
    'hem_reticulocytes'='Reticulocyte (%)'
    'hem_reticulocytes_absolute'='Reticulocyte Count (Absolute)'
    'hem_wbc'='WBC'
    ;

    invalue lbtestn
    'Hemoglobin'=1
    'Hematocrit'=2
    'WBC'=3
    'RBC'=4
    'Platelets'=5
    'Reticulocyte Count (Absolute)'=6
    'Reticulocyte (%)'=7
    'Neutrophils (Absolute)'=8
    'Lymphocytes (Absolute)'=9
    'Monocytes (Absolute)'=10
    'Eosinophils (Absolute)'=11
    'Basophils (Absolute)'=12
    'Bands (Absolute)'=13
    'Neutrophils (%)'=14
    'Lymphocytes (%)'=15
    'Monocytes (%)'=16
    'Eosinophils (%)'=17
    'Basophils (%)'=18
    'Bands (%)'=19
    ;

run;

data collect ncollect;
    set source.lbh;
    if lbhyn=1 then output collect;
        else output ncollect;
run;

data collect_01;
    length lbtest lborresu $100 lborres $200 lblow lbhigh $60 lbrange $100 lbclsig $10 lbdtc $60 lbname $200 
            visit $100 visitnum 8 lbcat $100;
    set collect(rename=(lbdtc=lbdtc_));
    format _all_;
    lbtest=put(analyte,$hema.);
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
    if lbnd=1 then lborres='Not Done';
    lbname=strip(lab_name);
    lbtestn=input(lbtest,lbtestn.);
    lbcat='HEMATOLOGY';
    keep subid lbtest lborres lborresu lblow lbhigh lbrange lbclsig lbdtc visit visitnum lbname 
        lbtestn lbres rep_rngl rep_rngh lbcat;
run;

proc sort data=ncollect out=s_ncollect(keep=subid event_id lbhynsp) nodupkey; by subid event_id; run;

data ncollect_01;
    length visit $100 visitnum 8 lborres $200 lbtest $100 lbcat $100;
    set s_ncollect;
    visit=strip(put(event_id,$visit.));
    visitnum=input(put(event_id,$vnum.),best.);
    lborres=strip(lbhynsp);
    lbtest='HEMATOLOGY SAMPLE NOT COLLECTED';
    lbcat='HEMATOLOGY';
    keep subid visit visitnum lborres lbtest;
run;

data hema_;
    set collect_01 ncollect_01;
run;

proc sort data=hema_; by subid visitnum lbdtc lbtestn; run;

data hema;
 set hema_;
 %lablowhigh(low=REP_RNGL, high=REP_RNGH, result=LBORRES);
 drop __:;
 where subid > ' ';
run;


proc sort data=hema;by subid visitnum lbcat lbtestn; run;

** Ken Cao on 2014/11/12: Insert color code note into dataset label **;
%addnote(indata=hema, labrslt=lborres, labcat=Hematology);

proc sort data = hema; by subid lbtest lbdtc visit; run;

data pdata.hema(label='Hematology (Baseline and Abnormal Values)');
    retain subid lbtest lborresu visit lbdtc lbname lbrange lborres lbclsig __label;
    keep subid lbtest lborresu visit lbdtc lbname lbrange lborres lbclsig __label;
    set hema;
    if lbtest^='HEMATOLOGY SAMPLE NOT COLLECTED' and (lborres='Not Done' or lborres='') then delete;
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
    where strip(visit) = 'Pre-Study' or lbclsig > ' ';
run;
