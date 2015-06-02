/*********************************************************************
 Program Nmae: pe.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/10
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';


proc format;
    value $petestcd
    'Abdomen' = 'ABDOMEN'
    'Cardiovascular' = 'CARD'
    'Extremities' = 'EXTREM'
    'General Appearance' = 'GA'
    'HEENT' = 'HEENT'
    'Lymphatic' = 'LYMP'
    'Musculoskeletal' = 'MUSC'
    'Nervous' = 'NERVOUS'
    'Other' = 'OTHER'
    'Respiratory' = 'RESP'
    'Skin' = 'SKIN'
;
run;


data pe1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE peorres_=peorres));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.pe;
    %subject;
    %visit2
    ** PEDTC;
    length pedtc $20;
    label pedtc = 'Assessment Date';
    if pedt^=. then pedtc=put(pedt,yymmdd10.);else pedtc="";
    rc = h.find();
    %concatDY(pedtc);
    drop rc pedt;


    ** Combine PEORRES and PECOM;
    length peorres_ $255;
    if pecom > ' ' then peorres_ = strip(peorres )||', '|| pecom;
    else peorres_=peorres;
   drop peorres;
    ** PETESTCD and Other Body System;
    length petestcd $8;
    label petestcd = 'PE Test Code';
    petestcd = put(petest, $petestcd.);
    
run;


** transpose;
data pe2; 
    set pe1;
    keep __edc_treenodeid __edc_entrydate subject visit2  peperf peyn pedtc petestcd petest  peorres peoccur;
run;

proc sort data=pe2; by __edc_treenodeid __edc_entrydate subject pedtc visit2 peperf peyn  peoccur; run;
proc transpose data=pe2 out=pe3_(drop=_name_);
    by __edc_treenodeid __edc_entrydate subject pedtc visit2 peperf peyn peoccur;
    id petestcd;
    idlabel petest;
    var peorres;
run;


** other specify;
proc sort data=pe3_; by __edc_treenodeid __edc_entrydate subject visit2  peperf peyn pedtc;run;
proc sort data=pe1(where=(peorreso^="")) out=peoth(keep= __edc_treenodeid __edc_entrydate subject visit2  peperf peyn pedtc peorreso); by 
__edc_treenodeid __edc_entrydate subject visit2  peperf peyn pedtc;run;


data pe3;
 merge pe3_ (in=a) peoth;
 by __edc_treenodeid __edc_entrydate subject visit2  peperf peyn pedtc;
 if a;
 run;


** PE at baseline;
data t_pebase;
 set pe3;
  where visit2 = 'Screening';
run;

proc sort data=t_pebase; by subject pedtc visit2;run;

data pdata.pe1(label='Physical Exam (Screening)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peperf ga skin heent resp card abdomen extrem  ;
    keep  __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peperf ga skin heent resp card abdomen extrem  ;
    set t_pebase;
run;

data pdata.pe2(label='Physical Exam (Screening) (Continued)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc musc lymp nervous other peorreso peoccur;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc musc lymp nervous other peorreso peoccur;
    set t_pebase;
run;


** PE at post-baseline;
data pepbase;
 set pe3;
  where visit2 ^= 'Screening';
run;

proc sort data=pepbase out=pepbase_ ; by subject pedtc visit2;run;

data pdata.pe3(label='Physical Exam (Post-Baseline)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peperf peyn ga skin heent resp card abdomen extrem;
    keep __edc_treenodeid __edc_entrydate subject visit2 pedtc peperf peyn ga skin heent resp card abdomen extrem;
    set pepbase_;
run;

data pdata.pe4(label='Physical Exam (Post-Baseline) (Continued)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peperf peyn musc lymp nervous other peorreso ;
    keep __edc_treenodeid __edc_entrydate subject visit2 pedtc musc lymp nervous other peorreso  ;
    set pepbase_;
run;
