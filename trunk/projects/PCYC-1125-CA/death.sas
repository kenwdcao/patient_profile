/*********************************************************************
 Program Nmae: DEATH.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/13
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/18: Add --DY to DEATHDTC

*********************************************************************/

%include '_setup.sas';


** read from source datasets;
data death;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    length deathdtc $20 cause $200;
    set source.death(rename=(deathdtc=deathdtc_));
    %subject;
    deathdtc=deathdtc_;
    rc = h.find();
    %concatDY(deathdtc);
    if deathcs=1 then cause="Progressive Disease";
    else if deathcs=2 and deathsp^='' then cause="Other: "||strip(deathsp);
	else if deathcs=2 then cause="Other";
    else if deathcs=3 then cause="Unknown";
    __id=id;
    keep __id subject deathdtc cause;
run;

proc sort data=death;by subject;run;

data pdata.death(label="Death");
    retain __id subject deathdtc cause;
    attrib
    deathdtc        label="Date of Death"
    cause           label="Cause of Death"
    ;
    set death;
    keep __id subject deathdtc cause;
run;
