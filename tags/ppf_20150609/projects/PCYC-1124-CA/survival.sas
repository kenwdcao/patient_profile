/********************************************************************************
 Program Nmae: SURVIVAL.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data survival;
length fucondtc fulaldtc $20 cycle $10; 
    set source.survival (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
    cycle = cycle; ** in case that cycle is added in the furture.;
    %visit; 
    if fucontdt ^= . then fucondtc = put(fucontdt, YYMMDD10.);
    if fulalvdt ^= . then fulaldtc = put(fulalvdt, YYMMDD10.);
proc sort; by subject fucontdt visit2 ;
run; 

data survival; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set survival; 
       rc = h.find();
       %concatdy(fucondtc); 
       drop rc;
    run;

data pdata.survival(label='Survival Status');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 dsoccur dsoccurs fucont fucondtc fualive fulaldtc;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 dsoccur dsoccurs fucont fucondtc fualive fulaldtc;
    label fucondtc = "Date of Contact"
          fulaldtc  = 'If Lost to Follow-Up, Date Last Known Alive';
    set survival;
run;
