/*********************************************************************
 Program Nmae: enroll.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/24
*********************************************************************/
%include "_setup.sas";

data enroll;
    length subject $13 ;
    set source.enroll (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject; 
	label  visit="Visit";
run;

proc sort data=enroll; by subject; run;

%let k=%str(__edc_treenodeid __edc_entrydate subject visit enphase encohort);

data pdata.enroll(label='Treatment Assignment');
    retain &k;
    set enroll;
    keep &k;
run;
