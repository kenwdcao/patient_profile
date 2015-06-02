/********************************************************************************
 Program Nmae: RECONS.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/27: Adjust variable order;

********************************************************************************/
%include '_setup.sas';

data recons;
length redt $20; 
    set source.recons (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
    if redtc ^= . then redt = put(redtc, YYMMDD10.);
proc sort; by subject redtc;
run; 

data recons; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set recons; 
       rc = h.find();
       %concatdy(redt); 
       drop rc;
    run;

data pdata.recons(label='Subject Re-Consent');
    retain __EDC_TreeNodeID __EDC_EntryDate subject recons renum reprota redt  ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject recons renum reprota redt  ;
    label   redt ="Re-consented Date"
            recons = "Re-consented to Later Versions Protocol"
            renum = 'Record Number'
            ;  
    set recons;
run;
