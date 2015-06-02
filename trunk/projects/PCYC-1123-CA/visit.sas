/*********************************************************************
 Program Nmae: VISIT.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/21
*********************************************************************/
%include "_setup.sas";

data VISIT;
    length subject $13 rfstdtc  $10 SVSTDTC $20 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.visit(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate));
    %subject;

    label SVSTDTC = 'Visit Date';
    %ndt2cdt(ndt=SVSTDT, cdt=SVSTDTC);
    rc = h.find();
    %concatDY(SVSTDTC);

    %visit2;
run;

proc sort data=VISIT;by subject SVSTDTC;run;

data pdata.VISIT (label="Visit Date");
    retain __edc_treenodeid __edc_entrydate subject visit2 SVSTDTC;
    set VISIT;
    keep __edc_treenodeid __edc_entrydate subject visit2  SVSTDTC;
run;



