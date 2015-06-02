/*********************************************************************
 Program Nmae: DSEXIT.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/13
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/18: Add --DY to EXITDTC.
*********************************************************************/

%include '_setup.sas';


** read from source datasets;
data dsexit;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    length exitdtc $20;
    set source.dsexit(rename=(exitdtc=exitdtc_));
    %subject;
    exitdtc=exitdtc_;
    rc = h.find();
    %concatDY(exitdtc);
    __id=id;
    keep __id subject exitdtc dsreas dsotsp;
run;

proc sort data=dsexit;by subject;run;

data pdata.dsexit(label="Study Exit");
    retain __id subject exitdtc dsreas dsotsp;
    attrib
    exitdtc         label="Date of Study Exit"
    ;
    set dsexit;
    keep __id subject exitdtc dsreas dsotsp;
run;
