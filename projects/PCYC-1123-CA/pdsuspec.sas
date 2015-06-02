/*********************************************************************
 Program Nmae: PDSUSPEC.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/15
*********************************************************************/
%include "_setup.sas";

data pdsuspec;
     length subject $13;
    set source.pdsuspec (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
    label pdsuspyn = 'Were any Suspected Disease Progression Visit(s) conducted for this subject?';
run;

proc sort data=pdsuspec; by subject ; run;

%let k=%str(__edc_treenodeid __edc_entrydate subject pdsuspyn);

data pdata.pdsuspec(label='Suspected Disease Progression Visit Prompt');
    retain &k;
    set pdsuspec;
    keep &k;
run;
