/*********************************************************************
 Program Nmae: DISC.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/13
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/18: Add --DY to LDOSEDTC.

*********************************************************************/

%include '_setup.sas';


** read from source datasets;
data disc;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    length ldosedtc $20;
    set source.disc(rename=(ldosedtc=ldosedtc_));
    %subject;
    ldosedtc=ldosedtc_;
    rc = h.find();
    %concatDY(ldosedtc);
    __id=id;
	if exdosed^=. then doseyn=strip(put(exdosed, noyes.));
    keep __id subject doseyn ldosedtc discreas disreaso;
run;

proc sort data=disc;by subject ldosedtc;run;

data pdata.disc(label="Treatment Discontinuation");
    retain __id subject doseyn ldosedtc discreas disreaso;
    attrib
    doseyn        label="Did the subject receive any study drug?"
    ldosedtc        label="Date of Last Dose"
    discreas        label="Primary reason study drug was permanently discontinued or never administered"
    disreaso        label="If Subject or Investigator decision, specify"
    ;
    set disc;
    keep __id subject doseyn ldosedtc discreas disreaso;
run;
