/*
    Program Name: chem.sas
        @Author: Xiu Pan
        @Initial Date: 2014/08/22

    MODIFICATION HISTORY:
    Ken Cao on 2014/11/24: Keeps only baseline and abonormal post-baseline values.


*/
%include '_setup.sas';

proc format;
    value $chem
    'chem_albumin'='Albumin'
    'chem_alkaline_phosphatase'='Alkaline Phosphatase'
    'chem_alt'='ALT'
    'chem_ast'='AST'
    'chem_bicarbonate'='Bicarbonate'
    'chem_bilirubin_total'='Total Bilirubin'
    'chem_bilirubin_total_direct'='Direct Bilirubin'
    'chem_bun'='Blood Urea Nitrogen (BUN)'
    'chem_calcium'='Calcium'
    'chem_chloride'='Chloride'
    'chem_cholesterol_total'='Cholesterol'
    'chem_creatinine'='Creatinine'
    'chem_glucose'='Glucose'
    'chem_hdl_cholesterol'='HDL'
    'chem_insulin'='Insulin'
    'chem_ldh'='Lactate Dehydrogenase (LDH)'
    'chem_ldl_cholesterol'='LDL'
    'chem_magnesium'='Magnesium'
    'chem_phosphorus'='Phosphorus'
    'chem_potassium'='Potassium'
    'chem_sodium'='Sodium'
    'chem_total_protein'='Total Protein'
    'chem_triglycerides'='Triglycerides'
    'chem_uric_acid'='Uric Acid'
    ;

    invalue lbtestn
    'Bicarbonate'=1
    'Calcium'=2
    'Phosphorus'=3
    'Magnesium'=4
    'Albumin'=5
    'Glucose'=6
    'Creatinine'=7
    'AST'=8
    'ALT'=9
    'Lactate Dehydrogenase (LDH)'=10
    'Alkaline Phosphatase'=11
    'Total Bilirubin'=12
    'Direct Bilirubin'=13
    'Uric Acid'=14
    'Total Protein'=15
    'Blood Urea Nitrogen (BUN)'=16
    'Sodium'=17
    'Potassium'=18
    'Chloride'=19
    'HDL'=20
    'LDL'=21
    'Cholesterol'=22
    'Triglycerides'=23
    'Insulin'=24
    ;

run;

/*Chemistry*/
data chemall;
    set source.lbc source.lbcam;
    format _all_;
run;

data collect ncollect;
    set chemall;
    if lbcyn=1 then output collect;
        else output ncollect;
run;

data collect_01;
    length lbtest lborresu $100 lborres $200 lblow lbhigh $60 lbrange $100 lbclsig $10 lbdtc $60 lbname $200 
            visit $100 visitnum 8 lbfast $10 lbcat $100 lbcatn 8;
    set collect(rename=(lbdtc=lbdtc_ lborres=lborres_));
    lbtest=put(analyte,$chem.);
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
    lbtestn=input(lbtest,lbtestn.);
    if lbcfast=1 then lbfast='Yes';
        else if lbcfast=0 then lbfast='No';
    lbcat='CHEMISTRY';
    lbcatn=1;
    keep subid lbtest lborres lborresu lblow lbhigh lbrange lbclsig lbdtc visit visitnum lbname lbtestn 
        lbfast rep_rngl rep_rngh lbcat lbcatn;
run;

proc sort data=ncollect out=s_ncollect(keep=subid event_id lbcynsp) nodupkey; by subid event_id; run;

data ncollect_01;
    length visit $100 visitnum 8 lborres $200 lbtest $100 lbcat $100 lbcatn 8;
    set s_ncollect;
    visit=strip(put(event_id,$visit.));
    visitnum=input(put(event_id,$vnum.),best.);
    lborres=strip(lbcynsp);
    lbtest='CHEMISTRY SAMPLE NOT COLLECTED';
    lbcat='CHEMISTRY';
    lbcatn=1;
    keep subid visit visitnum lborres lbtest lbcat lbcatn;
run;

data chem_;
    set collect_01 ncollect_01;
run;

proc sort data=chem_; by subid visitnum lbcat lbtestn; run;

data chem;
 set chem_;
 %lablowhigh(low=REP_RNGL, high=REP_RNGH, result=LBORRES);
 drop __:;
run;
/*Glycated Hemoglobin*/
data hba1c_;
    length lbtest lborresu $100 lborres $200 lblow lbhigh $60 lbrange $100 lbclsig $10 lbdtc $60 lbname $200 
            visit $100 visitnum 8 lbcat $100 lbcatn 8;
    set source.lbgh(rename=(lbdtc=lbdtc_));
    if lbghyn=1 then lbtest='Glycated Hemoglobin';
        else if lbghyn=0 then lbtest='GLYCATED HEMOGLOBIN SAMPLE NOT COLLECTED';
    lbcat='GLYCATED HEMOGLOBIN';
    lbcatn=2;
    if lbghyn=1 then lborres=strip(lboorres);
        else if lbghyn=0 then lborres=strip(lbghynsp);
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
    lbtestn=1;
    keep subid lbtest lborres lborresu lblow lbhigh lbrange lbclsig lbdtc visit visitnum lbname lbtestn 
         rep_rngl rep_rngh lbcat lbcatn;
run;

data hba1c;
 set hba1c_;
 %lablowhigh(low=REP_RNGL, high=REP_RNGH, result=LBORRES);
 drop __:;
run;

data pre_chem;
    set chem hba1c;
run;

proc sort data=pre_chem; by subid visitnum lbcatn lbtestn;run;


** Ken Cao on 2014/11/12: Insert color code note into dataset label **;
%addnote(indata=pre_chem, labrslt=lborres, labcat=Chemistry);


proc sort data = pre_chem; by subid lbtest lbdtc visit ; run;

************;
data pdata.chem(label='Chemistry (Baseline and Abnormal Values)');
    retain subid lbtest lborresu  visit lbdtc lbname lbrange lborres lbfast lbclsig __label;
    keep subid lbtest lborresu  visit lbdtc lbname lbrange lborres lbfast lbclsig __label;

    set pre_chem;
    if lbtest^='CHEMISTRY SAMPLE NOT COLLECTED' and (lborres='Not Done' or lborres='') then delete; 
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
    ;
    *** Ken Cao on 2014/11/24: Keeps only baseline and abornormal post-baseline values ;
    where visit = 'Pre-Study' or lbclsig > ' ';
run;
