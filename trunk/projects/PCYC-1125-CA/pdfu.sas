/*********************************************************************
 Program Nmae: PDFU.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/16
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/18: Add --DY to FUCNTDTC FUALVDTC DEATHDTC 

*********************************************************************/

%include '_setup.sas';


** read from source datasets;

data pdfu;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    length fucntdtc fualvdtc deathdtc $20 contact $200;
    set source.pdfu(rename=(fucntdtc=fucntdtc_ deathdtc=deathdtc_ fualvdtc=fualvdtc_));
    %subject;
    if FUCND=.;
    fucntdtc=fucntdtc_;
    fualvdtc=fualvdtc_;
    if deathdtu^=. then deathdtc="Unknown";
        else if deathdtu=. then deathdtc=fucntdtc_;
    rc = h.find();
    %concatDY(fucntdtc);
    %concatDY(fualvdtc);
    %concatDY(deathdtc);
	if fucnd^=. then nd="Yes";
    if fuctos^='' then contact="Other: "||vvalue(fucnt);
        else if fuctos='' then contact=vvalue(fucnt);
    __id=id;
    keep __id subject nd fucntdtc contact fualive deathdtc fualvdtc;
run;

proc sort data=pdfu;by subject;run;

data pdata.pdfu(label="Survival Status");
    retain __id subject nd fucntdtc contact fualive deathdtc fualvdtc;
    attrib
     nd               label="Not Done"
    fucntdtc        label="Date of Contact"
    contact         label="Person Contacted"
    fualive         label="Is the Subject Alive?"
    deathdtc        label="If No, Date of Death"
    fualvdtc        label="If Lost to Follow-Up, Date Subject Last Known to be Alive"
    ;
    set pdfu;
    keep __id subject nd fucntdtc contact fualive deathdtc fualvdtc;
run;
