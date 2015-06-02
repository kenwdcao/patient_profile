/********************************************************************************
 Program Nmae: TB.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/26: The author forgot to call macro %VISIT.

********************************************************************************/
%include '_setup.sas';

data tb;
length tbdtc tbcondtc $20 cycle $10; 
    set source.tb (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
    cycle = cycle; ** in case that cycle is added in the furture.;  
    ** Ken Cao on 2015/02/26: Call macro %visit to get variable VISIT2;
    %visit; 
    if tbdt ^= . then tbdtc = put(tbdt, YYMMDD10.);
    if tbcondt ^= . then tbcondtc = put(tbcondt, YYMMDD10.);
    tbpre = put(tbpre, $checked.);
proc sort; by subject tbdt visit2 ;
run; 

data tb; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set tb; 
       rc = h.find();
       %concatdy(tbdtc); 
       drop rc;
    run;

data pdata.tb(label='Optional Tumor Biopsy Sample');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 tbyn tbcondtc tbdtc tbrefid tbpre tbtype tbtypeo tborgs tborgso;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 tbyn tbcondtc tbdtc tbrefid tbpre tbtype tbtypeo tborgs tborgso;
    label tbdtc = "Collection Date"
          tbcondtc  = 'Consent Date';
    set tb;
    label tbcondtc = 'Optional Tumor Tissue Collection Consent Date';

run;
