/*********************************************************************
 Program Nmae: PS.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/15
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include "_setup.sas";

data ps;
    length subject $13 rfstdtc $10 sgdtc $20;
	if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.ps(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate));
    %subject;

    %concatDate(year=psyy, month=psmm, day=psdd, outdate=sgdtc);
	rc = h.find();
    %concatDY(sgdtc);

run;

proc sort data=ps;by subject sgdtc;run;

data pdata.ps (label="Prior DLBCL Surgery");
    retain __edc_treenodeid __edc_entrydate subject psterm sgdtc ;
	label sgdtc = 'Day of Procedure';
    set ps;
    keep __edc_treenodeid __edc_entrydate subject psterm sgdtc ;
run;

