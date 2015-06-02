/*********************************************************************
 Program Nmae: DS.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/13
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data ds0;
length subject $13 rfstdtc $10 exitdtc deathdtc $20 dsrea_ deathc_ $200;
if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set source.ds(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate EDC_FormLabel = __EDC_FormLabel));

    %subject;

    **exit**;
    label exitdtc = 'Date of Study Exit';
    %ndt2cdt(ndt=dsexitdt, cdt=exitdtc);
    rc = h.find();
    %concatDY(exitdtc);
    
     label dsrea_ = 'Primary Reason for Study Exit';
     dsrea_ =ifc(dsreaso^='', cat(strip(dsreas),': ', strip(dsreaso)),strip(dsreas));
    
     **death report**;
    label deathdtc = "Date of Death";
    %concatDate(year=deathyy, month=deathmm, day=deathdd, outdate=deathdtc);
    label deathc_='Cause of Death';
    if deathae^=. then deathc_=cat('AE (AE Number: ', strip(vvaluex('deathae')),')');
    else if deathcs=1 then deathc_='Progressive Disease';

run;

proc sort data=ds0; by subject exitdtc deathdtc; run;

data pdata.ds1(label='Study Exit');
    retain __edc_treenodeid __edc_entrydate subject exitdtc dsreas dsreaso ;
    keep __edc_treenodeid __edc_entrydate subject exitdtc dsreas dsreaso;
    set ds0;
    where __EDC_FormLabel='Study Exit';
run;

data pdata.ds2(label='Death Report');
    retain __edc_treenodeid __edc_entrydate subject deathdtc DEATHCS DEATHAE deathsp;
    keep __edc_treenodeid __edc_entrydate subject deathdtc DEATHCS DEATHAE deathsp;
    set ds0;
    where __EDC_FormLabel='Death Report';

    label DEATHAE = 'If AE, specify AE number:';
run;
