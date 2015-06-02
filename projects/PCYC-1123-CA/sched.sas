/*********************************************************************
 Program Nmae: SCHED.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/15
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data sched;
length subject $13 rfstdtc $10 scdtc $20 rea  $200;
if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set source.sched(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate));
    %subject;

    
    label scdtc = 'Visit Date';
    %ndt2cdt(ndt=scdt, cdt=scdtc);
    rc = h.find();
    %concatDY(scdtc);

    %visit2;
    
     label rea = 'Was a scheduled study visit completed at this time point?';
     if screaso^='' then rea=cat('No, Other: ', strip(screaso));
        else if screas^='' then rea=cat('No, ', strip(screas));
        else rea=strip(scyn);
run;

proc sort data=sched; by subject scdtc;run;


data pdata.sched(label='Scheduled Study Visit Prompt');
    retain __edc_treenodeid __edc_entrydate subject visit2 scyn screas screaso scdtc;
    set sched;
    keep __edc_treenodeid __edc_entrydate subject visit2 scyn screas screaso scdtc;

    label    scyn = 'Was a scheduled study visit completed at this time point?';
    label  screas = 'If No, please specify reason visit was not completed';
    label screaso = 'If Other, specify';
    label   scdtc = 'Visit Date';

run;

