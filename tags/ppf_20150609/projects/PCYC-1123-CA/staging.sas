/********************************************************************************
 Program Nmae: STAGING.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/14
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';


data staging_;
length stagedtc $20; 
	set source.staging (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
	%subject;
	%visit2;
	if stagedt ^= . then stagedtc = put(stagedt, YYMMDD10.);
run;

proc sort data=staging_; by subject stagedtc visit2;run; 

data staging; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set staging_; 
       rc = h.find();
       %concatdy(stagedtc); 
       drop rc;
    run;

data pdata.staging(label='Staging');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 stagedtc aastage blkyn blkynsze bsympyn;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 stagedtc aastage blkyn blkynsze bsympyn;
	label stagedtc = "Assessment Date";
    set staging;
run;
