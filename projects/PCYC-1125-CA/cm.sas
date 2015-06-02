/*********************************************************************
 Program Nmae: CM.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/13
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/03/16: 1) Add CMNUM .
                        2) Add --DY to CMSTDTC and CMENDTC.

*********************************************************************/

%include '_setup.sas';


** read from source datasets;
data cm;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    length cmstdtc cmendtc $20 cmdose unit freq route $200;
    set source.cm(rename=(cmstdtc=cmstdtc_ cmendtc=cmendtc_));
    %subject;
    rc = h.find();
    if cmdosunk=1 then cmdose="Unknown";else if cmdosunk=. and cmdos^=. then cmdose=strip(put(cmdos,best.));
    if cmdosus^='' then unit='Other: '||strip(cmdosus);else if cmdosus='' then unit=vvalue(cmdosu);
    if cmdosfrs^='' then freq=''||strip(cmdosfrs);else if cmdosfrs='' then freq=vvalue(cmdosfrq);
    if cmroutes^='' then route=''||strip(cmroutes);else if cmroutes='' then route=vvalue(cmroute);
    length cmstdtc cmendtc $20;
    cmstdtc=cmstdtc_; 
    cmendtc=cmendtc_;
    %concatDY(cmstdtc);
    %concatDY(cmendtc);
    __id=id;
    keep __id subject cmnum cmtrt cmindc route cmstdtc cmprior cmendtc cmongo cmdose unit freq;
run;

proc sort data=cm;by subject cmstdtc cmendtc cmtrt;run;

data pdata.cm(label="Prior and Concomitant Medications");
    retain __id subject cmnum cmtrt cmindc route cmstdtc cmprior cmendtc cmongo cmdose unit freq;
    attrib
    cmstdtc         label="Start Date"
    cmprior         label=">1 mon. prior to 1st dose"
    cmendtc         label="End Date"
    route           label="Route"
    cmdose          label="Dose"
    unit            label="Unit"
    freq            label="Frequency"
    ;
    set cm;
    keep __id subject cmnum cmtrt cmindc route cmstdtc cmprior cmendtc cmongo cmdose unit freq;
run;
