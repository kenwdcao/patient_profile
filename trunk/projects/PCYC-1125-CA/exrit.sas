/*********************************************************************
 Program Nmae: EXRIT.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/13
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/18: Add --DY to EXSTDTC

*********************************************************************/

%include '_setup.sas';


** read from source datasets;
data exrit;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    length exstdtc exsttmc exentmc $20 exdosl_ $200;
    set source.exrit(rename=(exstdtc=exstdtc_ exsttmc=exsttmc_ exentmc=exentmc_));
    %subject;
    exstdtc=exstdtc_; 
    rc = h.find();
    %concatDY(exstdtc);
    exsttmc=exsttmc_;
    exentmc=exentmc_;
    if exdosls^=. then exdosl_="Other: "||strip(put(exdosls,best.))||" mg/m2";
    else if exdosls=. and exdosl^=. then exdosl_=strip(vvalue(exdosl));
    __id=id;
    keep __id subject event_id exmd exdisc exdiscs exstdtc exsttmc exentmc exdelay exreasdl aenumdel exreasdo exdosl_
        exdose exadose exreasad aenumspl exreasao exinfint exrestr exrstres;
run;

proc sort data=exrit;by subject exstdtc exsttmc exentmc;run;

data pdata.exrit1(label="In-clinic Administration of Rituximab IV");
    retain __id subject event_id exmd exdisc exdiscs exstdtc exdelay exreasdl aenumdel exreasdo exsttmc exentmc ;
    attrib
    exstdtc         label="Dose Date"
    exsttmc         label="Infusion Start Time"
    exentmc         label="Infusion Stop Time"
    event_id        label="Visit"
    exreasdo        label="Other Reason Specify"
    ;
    set exrit;
    keep __id subject event_id exmd exdisc exdiscs exstdtc exsttmc exentmc exdelay exreasdl aenumdel exreasdo;
run;

data pdata.exrit2(label="In-clinic Administration of Rituximab IV (Continued)");
    retain __id subject exdosl_ exdose exadose exreasad aenumspl exreasao exinfint exrestr exrstres  ;
    attrib
    exdosl_         label="Dose Level"
    exdose          label="Dose Intended#(mg)"
    exadose         label="Dose Administered#(mg)"
    exreasad        label="Reason for Dose Administered not same as Dose Intended"
    aenumspl        label="If due to AE, specify"
    exreasao        label="If Other, specify"
    exrestr         label="If Yes, was study drug re-started on the same day?"
    exrstres        label="If Yes, What happened when study drug was re-started"

    ;
    set exrit;
    keep __id subject exdosl_ exdose exadose exreasad aenumspl exreasao exinfint exrstres exrestr ;
run;
