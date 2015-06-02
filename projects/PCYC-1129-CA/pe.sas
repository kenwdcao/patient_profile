/*********************************************************************
 Program Nmae: pe.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/24
 
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


data pe1(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate peorres_=peorres));
    length subject $13 __rfstdtc $10;
    if _n_ = 1 then do;
       declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set source.pe;
    %subject;
    %visit2
    ** PEDTC;
    length pedtc $20;
    label pedtc = 'Assessment Date';
    %ndt2cdt(ndt=pedt, cdt=pedtc);
    rc = h.find();
    %concatDY(pedtc);

   
    length peorres_ $255;
    peorres_ = strip(peres );

    ** PETESTCD and Other Body System;
    length petestcd $8;
    label petestcd = 'PE Test Code';
    petestcd = put(petest, $petestcd.);
	
run;

proc sort data=pe1 ; by  subject pedtc visit2  __edc_treenodeid __edc_entrydate PEPERF; run;

***abnormal**;
proc sort data=pe1 (where=(PECOM^='')) nodupkey 
   out=p1(keep=subject pedtc visit2  __edc_treenodeid __edc_entrydate petest peorres PECOM); 
   by  subject pedtc visit2  __edc_treenodeid __edc_entrydate  petest PECOM;
run;
**end**;

proc transpose data=pe1(where =(EDC_FormLabel^='Physical Exam - Limited'))  out=pe3_(drop=_name_);
    by subject pedtc visit2  __edc_treenodeid __edc_entrydate PEPERF ;
    id petestcd;
    idlabel petest;
    var peorres;
run;


** other specify;
proc sort data=pe3_; by subject  pedtc visit2   __edc_treenodeid __edc_entrydate  peperf ;run;

proc sort data=pe1(where=(pereso^="")) out=peoth(keep= __edc_treenodeid __edc_entrydate subject visit2  peperf  pedtc pereso); 
by subject pedtc visit2  __edc_treenodeid __edc_entrydate  peperf  ;
run;


data pe3;
 merge pe3_ (in=a) peoth;
by subject pedtc visit2  __edc_treenodeid __edc_entrydate  peperf  ;
 if a;
 run;

data pdata.pe1(label='Physical Exam - Complete');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peperf ga skin heent resp card abdomen  ;
    keep  __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peperf  ga skin heent resp card abdomen  ;
    set pe3;
	label peperf='Was a Physical Examination performed at this time point?';
run;

data pdata.pe2(label='Physical Exam - Complete(Continued)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc extrem  musc lymp nervous other pereso;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc  extrem  musc lymp nervous other pereso;
    set pe3;
run;

data pdata.pe3(label='Physical Exam - Complete(Abnormal Finding)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc petest peorres pecom;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc  petest peorres pecom;
    set p1;
	label petest='Test'
	peorres='Result'
	pecom='Abnormal Description';
run;

data pdata.pe4(label='Physical Exam - Limited');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peyn peabn;
    set pe1;
	 label peyn='Was a Physical Examination performed at this timepoint?';
	 label peabn='Were there any new or worsened abnormal findings since the last PE?';
	where  EDC_FormLabel='Physical Exam - Limited';
	keep  __EDC_TreeNodeID __EDC_EntryDate subject visit2 pedtc peyn peabn;
run;

