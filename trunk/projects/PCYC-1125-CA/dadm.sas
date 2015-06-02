/*********************************************************************
 Program Nmae: DADM.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/13
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/18: Add --DY to DASTDTC and DAENDTC.

*********************************************************************/

%include '_setup.sas';


** read from source datasets;
data dadm;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    length dastdtc daendtc $20 dadose daadj $200;
    set source.dadm(rename=(dastdtc=dastdtc_ daendtc=daendtc_));
    %subject;
    dastdtc=dastdtc_ ;
    daendtc=daendtc_;
    rc = h.find();
    %concatDY(dastdtc);
    %concatDY(daendtc);
    if othdose^='' then dadose=strip(othdose);else if othdose='' then dadose=vvalue(dose);
    if damdosp^='' then daadj=strip(damdosp);else if damdosp='' then daadj=vvalue(damdo);
    __id=id;
    keep __id subject dastdtc daendtc daongo dadisco dadose daadj dalotnum;
run;

proc sort data=dadm;by subject dastdtc daendtc;run;

data pdata.dadm(label="Ibrutinib Dose Administration");
    retain __id subject dastdtc daendtc daongo dadisco dadose daadj dalotnum;
    attrib
    dastdtc         label="Start Date"
    daendtc         label="End Date"
    dadose          label="Daily Dose Administered"
    daadj           label="Reason for Change or Missed Dose"
    dadisco         label="Dose Permanently Discontinued"
    ;
    set dadm;
    keep __id subject dastdtc daendtc daongo dadisco dadose daadj dalotnum;
run;


    
