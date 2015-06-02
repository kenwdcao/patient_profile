/*********************************************************************
 Program Nmae: MH.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/16
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/18: Add --DY to MHSTDTC/MHENDTC.

*********************************************************************/

%include '_setup.sas';

data mh;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    length mhstdtc mhendtc $20;
    set source.mh(rename=(mhstdtc=mhstdtc_ mhendtc=mhendtc_));
    if mhnone=.;
    %subject;
    mhstdtc=mhstdtc_;
    mhendtc=mhendtc_;

    rc = h.find();
    %*concatDY(mhstdtc);
    %*concatDY(mhendtc);
    
    __id=id;
    keep __id subject mhnum mhterm mhstdtc mhstdatu mhendtc mhongo mhtoxgr;
run;

proc sort data=mh;by subject mhstdtc mhendtc mhterm; run;

data pdata.mh(label="Medical History");
    retain __id subject mhnum mhterm mhstdtc mhstdatu mhendtc mhongo mhtoxgr;
    attrib
    mhstdtc         label="Start Date"
    mhstdatu         label=">1 Yr. Prior to 1st Dose/Unk"
    mhendtc         label="End Date"
    ;
    set mh;
    keep __id subject mhnum mhterm mhstdtc mhstdatu mhendtc mhongo mhtoxgr;
run;
