/*********************************************************************
 Program Nmae: CMRX.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/13
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/16: Add --DY

*********************************************************************/

%include '_setup.sas';


** read from source datasets;

data cmrx;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    length rxstdtc rxendtc $20;
    set source.cmrx(rename=(rxstdtc=rxstdtc_ rxendtc=rxendtc_));
    rxstdtc=rxstdtc_;
    rxendtc=rxendtc_;
    %subject;
    rc = h.find();
    %concatDY(rxstdtc);
    %concatDY(rxendtc);
    __id=id;
    keep __id subject rxtrt rxstdtc rxendtc rxongo;
run;

proc sort data=cmrx;by subject rxstdtc;run;

data pdata.cmrx(label="Any Subsequent Antineoplastic Therapy");
    retain __id subject rxtrt rxstdtc rxendtc rxongo;
    attrib
    rxstdtc         label="Start Date"
    rxendtc         label="End Date";
    set cmrx;
    keep __id subject rxtrt rxstdtc rxendtc rxongo;
run;
