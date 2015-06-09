/*********************************************************************
 Program Nmae: IC.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/16
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/18: Add --DY to IEDTC.
 
*********************************************************************/

%include '_setup.sas';

data ic;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    length iedtc $20;
    set source.ic(rename=(iedtc=iedtc_));
    %subject;
    iedtc=iedtc_;
    rc = h.find();
    %concatDY(iedtc);
    __id=id;
    keep __id subject ieprot ieprotnm iedtc arm optttc;
run;

proc sort data=ic;by subject;run;

data pdata.ic(label="Informed Consent");
    retain __id subject ieprot ieprotnm iedtc arm optttc;
    attrib
    iedtc           label="Informed Consent Signature Date"
    optttc           label="Consent to Tumor Tissue Collection (Required at Screening for Arm 2)"
    ;
    set ic;
    keep __id subject ieprot ieprotnm iedtc arm optttc;
run;
