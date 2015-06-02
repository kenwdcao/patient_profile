/*********************************************************************
 Program Nmae: IE.sas
  @Author: Ken Cao
  @Initial Date: 2015/05/06
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data ie0;
    set source.ie;
    
    %subject;

    keep edc_treenodeid edc_entrydate subject visit ieyn iecat ietest ieorres;
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
    rename visit = __visit;
run;

proc sort data=ie0; by subject iecat; run;

data ie1;
    set ie0;
    where ieorres ^= ' ';
run;

proc sort data=ie0 nodupkey; by subject; run;
data pdata.ie1(label='Eligibility Criteria');
    retain __edc_treenodeid __edc_entrydate subject __visit ieyn ;
    keep __edc_treenodeid __edc_entrydate subject __visit ieyn;
    set ie0;
    label ieyn = 'Did the subject meet all eligibility criteria?';
run;

data pdata.ie2(label='Eligibility Criteria Not Met');
    retain __edc_treenodeid __edc_entrydate subject __visit iecat ietest ieorres;
    keep __edc_treenodeid __edc_entrydate subject __visit iecat ietest ieorres;
    set ie1;
    label ieorres = 'Criteria Not Met';
run;

