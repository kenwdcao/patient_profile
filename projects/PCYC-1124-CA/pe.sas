/********************************************************************************
 Program Nmae: PE.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
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

data pe0;
    set source.pe(keep=edc_treenodeid subject yr visit cycle peperf peyn peabn petest peres 
                  pecom pereso peoccur seq pedt edc_entrydate);
    
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
run;

data pe1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set pe0;
    %subject;
    %visit;

    ** PEDTC;
    length pedtc $20;
    label pedtc = 'Assessment Date';
    %ndt2cdt(ndt=pedt, cdt=pedtc);
    rc = h.find();
    %concatDY(pedtc);
    drop rc pedt;

    ** Combine PERES and PECOM;
    length peorres $255;
    peorres = peres;
    if pecom > ' ' then peorres = strip(peres )||', '|| pecom;
    drop peres pecom;

    ** PETESTCD and Other Body System;
    length petestcd $8;
    label petestcd = 'PE Test Code';
    petestcd = put(petest, $petestcd.);
    /*
    length petest_ $255;
    label petest_ = 'Body System';
    petest_ = petest;
    if pereso > ' ' then petest_ = petest;
    drop petest pereso;
    */
run;

data pebase; ** PE at baseline;
    set pe1;
    keep __edc_treenodeid __edc_entrydate subject visit2 peperf pedtc petestcd petest pereso peorres peoccur;
    where visit2 = 'Screening';
run;

proc sort data=pebase; by __edc_treenodeid __edc_entrydate subject petestcd; run;
proc transpose data=pebase out=t_pebase(drop=_name_);
    by __edc_treenodeid __edc_entrydate subject visit2 peperf pedtc pereso peoccur;
    id petestcd;
    idlabel petest;
    var peorres;
run;


** PE at post-baseline;
proc sort data = pe1 out = pepbase(keep=__edc_treenodeid __edc_entrydate subject visit2 pedtc peyn peabn);
    by subject pedtc visit2;
    where visit2 ^= 'Screening';
run;


data pdata.pe1(label='Physical Exam at Baseline');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peperf ga skin heent resp card abdomen extrem  ;
    keep  __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peperf ga skin heent resp card abdomen extrem  ;
    set t_pebase;
run;

data pdata.pe2(label='Physical Exam at Baseline (Continued)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc musc lymp nervous other pereso peoccur;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc musc lymp nervous other pereso peoccur;
    set t_pebase;
run;

data pdata.pe3(label='Physical Exam at Post-Baseline');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peyn peabn;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peyn peabn;
	attrib
	peabn label = 'Any new or worsened abnormal findings since the last PE';
    set pepbase;
run;
