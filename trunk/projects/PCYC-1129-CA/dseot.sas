/*********************************************************************
 Program Nmae: dseot.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data dseot0;
length subject $13 __rfstdtc $10 dsdtc $20 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set source.dseot(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate ));
    %subject;
    %ndt2cdt(ndt=eotdt, cdt=dsdtc);
    rc = h.find();
    %concatDY(dsdtc);
run;

proc sort data=dseot0; by subject dsdtc; run;

data pdata.dseot(label='End of Treatment Visit Prompt');
    retain __edc_treenodeid __edc_entrydate subject eotvs dsdtc eotvss;
    keep __edc_treenodeid __edc_entrydate subject eotvs dsdtc eotvss;
    set dseot0;
    label eotvs = 'Was an End-of-Treatment Visit completed?';
    label dsdtc = 'If Yes, provide Visit Date';
    label eotvss = 'If No, specify reason';
run;
