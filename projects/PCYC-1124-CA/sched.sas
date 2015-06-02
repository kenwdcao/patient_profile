/********************************************************************************
 Program Nmae: SCHED.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/11: Sort dataset by visit.

********************************************************************************/
%include '_setup.sas';

data sched;
length scdtc $20; 
    set source.sched (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
    if visit in ('Screening' 'Response Assessment') then seq = .;
    %visit; 
    if scdt ^= . then scdtc = put(scdt, YYMMDD10.);
    screaso = coalescec(screas, screaso);
    if sclast ^= '' then sclast = put(sclast, $checked.);  
proc sort; by subject scdtc visit2;
run; 

data sched; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set sched; 
       rc = h.find();
       %concatdy(scdtc); 
       drop rc;
       %visitn(visit2);
    run;

proc sort data = sched; by subject __visitn; run;


data pdata.sched(label='Scheduled Study Visit Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 scyn screaso scdtc sclast ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 scyn screaso scdtc sclast;
    label scdtc = "Visit Date";
    set sched;
run;
