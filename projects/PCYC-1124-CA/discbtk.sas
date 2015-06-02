/*********************************************************************
 Program Nmae: DISCBTK.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/03/23: Remove row if discontinuation is “NO”.
 
*********************************************************************/

%include '_setup.sas';

data discbtk0;
    set source.discbtk;
    keep edc_treenodeid edc_entrydate subject ldosedt exyn discrs wthreso;
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
run;

data discbtk1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set discbtk0;
    
    %subject;

    ** Date of Last Dose;
    length ldosedtc $20;
    label ldosedtc = 'Date of Last Dose';
    %ndt2cdt(ndt=ldosedt, cdt=ldosedtc);
    rc = h.find();
    %concatDY(ldosedtc);
    drop ldosedt rc;
run;

proc sort data=discbtk1; by subject exyn; run;

data pdata.discbtk(label='Study Drug Discontinuation-Ibrutinib');
    retain __edc_treenodeid __edc_entrydate subject exyn ldosedtc discrs wthreso ;
    keep __edc_treenodeid __edc_entrydate subject exyn ldosedtc discrs wthreso ;
    set discbtk1;

    label exyn = 'Subject Received Any Dose of Ibrutinib';
    label wthreso = 'If Subject or Investigator decision, specify';
run;
