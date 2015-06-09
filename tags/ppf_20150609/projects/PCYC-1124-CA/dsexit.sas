/*********************************************************************
 Program Nmae: DSEXIT.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data dsexit0;
    set source.dsexit;
    keep edc_treenodeid edc_entrydate subject dsreas dsreaso dsexitdt;
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
run;

data dsexit1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set dsexit0;
    %subject;
    ** Date of Study Exit;
    length dsexitdtc $20;
    label dsexitdtc = 'Date of Study Exit';
    %ndt2cdt(ndt=dsexitdt, cdt=dsexitdtc);
    rc = h.find();
    %concatDY(dsexitdtc);
    drop dsexitdt rc;

run;

proc sort data = dsexit1; by subject; run;



data pdata.dsexit(label='Study Exit');
    retain __edc_treenodeid __edc_entrydate subject dsexitdtc dsreas dsreaso ;
    keep __edc_treenodeid __edc_entrydate subject dsexitdtc dsreas dsreaso ;
    set dsexit1;
    label dsreas = 'Primary Reason for Study Exit';
    label dsreaso = 'If Other, specify';
run;



