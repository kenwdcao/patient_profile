/*********************************************************************
 Program Nmae: ENROLL.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/15
*********************************************************************/
%include "_setup.sas";

data enroll;
     length subject $13 rfstdtc endtc $20;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
 
    set source.enroll (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
  
    label endtc = 'Enrollment Date';
    %ndt2cdt(ndt=ieenrdt, cdt=endtc);
    rc = h.find();
    %concatDY(endtc);
run;

proc sort data=enroll; by subject endtc; run;

%let k=%str(__edc_treenodeid __edc_entrydate subject endtc iephase iecohort);

data pdata.enroll(label='Treatment Assignment');
    retain &k;
    set enroll;
    keep &k;
run;
