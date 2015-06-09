/*********************************************************************
 Program Nmae: RFSTDTC.sas
  @Author: Ken Cao
  @Initial Date: 2015/03/12
 

 Derive first dose date.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data dadm0;
    set source.dadm;
    keep site_id subid dastdtc dose othdose;
    where (dose in (1, 96) or (dose = 99 and othdose not in ('0', ' '))) and dastdtc > ' ';
run;

data dadm1;
    set dadm0;
    %subject;
run;

proc sort data=dadm1; by subject dastdtc; run;

data dadm2;
    set dadm1;
        by subject;
    if first.subject;

    length rfstdtc $10;
    label rfstdtc = 'First Dose Date';
    rfstdtc = dastdtc;
    
    keep subject rfstdtc;
run;

data pdata.rfstdtc;
    retain subject rfstdtc;
    keep subject rfstdtc;
    set dadm2;
run;
