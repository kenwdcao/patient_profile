/********************************************************************************
 Program Nmae: STAGING.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data staging;
length stagedtc $20; 
	set source.staging (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
	%subject;
	if visit in ('Screening' 'Response Assessment') then seq = .;
	%visit; 
	if stagedt ^= . then stagedtc = put(stagedt, YYMMDD10.);
proc sort; by subject stagedtc visit2;
run; 

data staging; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set staging; 
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
