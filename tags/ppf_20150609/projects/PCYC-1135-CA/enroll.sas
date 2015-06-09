/*********************************************************************
 Program Nmae: enroll.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data enroll0;
    set source.enroll;
    %subject;
    keep EDC_TreeNodeID SUBJECT	VISIT ENPHASE ENTYPE ENTRTGRP ENDAT EDC_EntryDate;
run;


data enroll1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set enroll0;
	
    length endtc $20;
	label  endtc = 'Date of subject enrollment';
	%ndt2cdt(ndt=endat, cdt=endtc);
	rc = h.find();
	drop rc rfstdtc;
    %concatDY(endtc);
	label enphase = 'Which Phase is the subject enrolled in?';
run;

proc sort data = enroll1; by subject endtc; run;

data pdata.enroll(label='Subject Enrollment');
    retain EDC_TreeNodeID EDC_EntryDate subject endtc enphase entype entrtgrp; 
    keep   EDC_TreeNodeID EDC_EntryDate subject endtc enphase entype entrtgrp; 

    set enroll1;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;

run;
