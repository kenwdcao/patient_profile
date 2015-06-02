/*********************************************************************
 Program Nmae: DISCEPOC.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data discepoc0;
    set source.discepoc;
    keep edc_treenodeid edc_entrydate subject exyn grpid discdrg discrs wthreso ldosedt;
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
run;

proc format;
    invalue drugseq
    'Cyclophosphamide' = 4
    'Doxorubicin' = 5
    'Etoposide' = 1
    'Prednisone' = 2
    'Rituximab' = 6
    'Vincristine' = 3
    ;
run;


data discepoc1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set discepoc0;
    
    %subject;

    format discdrg $checked.;

    ** Date of Last Dose;
    length ldosedtc $20;
    label ldosedtc = 'Date of Last Dose';
    %ndt2cdt(ndt=ldosedt, cdt=ldosedtc);
    rc = h.find();
    %concatDY(ldosedtc);
    drop ldosedt rc;

    ** drug sequence;
    __drugseq = input(grpid, drugseq.);
run;

proc sort data = discepoc1; by subject __drugseq; run;

data pdata.discepoc(label='Study Drug Discontinuation-EPOCH-R');
    retain __edc_treenodeid __edc_entrydate subject exyn grpid discdrg ldosedtc discrs wthreso  ;
    keep __edc_treenodeid __edc_entrydate subject exyn grpid discdrg ldosedtc discrs wthreso;
    set discepoc1;

    where DISCDRG = 'Checked';

    label exyn = 'Subject Received Any Dose of EPOCH-R';
    label grpid = 'Drug Name';
    label discdrg = 'Discontinued';
    label wthreso = 'If Subject or Investigator decision, specify';
run;
