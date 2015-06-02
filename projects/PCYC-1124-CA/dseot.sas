/*********************************************************************
 Program Nmae: DSEOT.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data dseot0;
    set source.dseot;
    keep edc_treenodeid edc_entrydate subject eotvs eotvss;
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
    %subject;
run;

data pdata.dseot(label='Follow-Up Visit Prompt');
    retain __edc_treenodeid __edc_entrydate subject eotvs eotvss;;
    keep __edc_treenodeid __edc_entrydate subject eotvs eotvss;;
    set dseot0;
run;
