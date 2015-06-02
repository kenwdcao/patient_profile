/*********************************************************************
 Program Nmae: dsexit.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data dsexit0;
length subject $13 __rfstdtc $10 dsdtc $20 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set source.dsexit(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate ));
    %subject;
    %ndt2cdt(ndt=DSEXITDT, cdt=dsdtc);
    rc = h.find();
    %concatDY(dsdtc);
run;

proc sort data=dsexit0; by subject dsdtc; run;

data pdata.dsexit(label='Study Exit');
    retain __edc_treenodeid __edc_entrydate subject dsdtc dsreas dsreaso;
    keep __edc_treenodeid __edc_entrydate subject dsdtc dsreas dsreaso;
    set dsexit0;
    label dsreas = 'Indicate primary reason subject exited the study';
    label dsreaso= 'If Other, specify';
    label dsdtc = 'Date of Study Exit';
run;

