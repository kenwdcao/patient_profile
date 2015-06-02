/********************************************************************************
 Program Nmae: cr.sas
   @Author: Yuanmei Wang
  @Initial Date: 2015/04/16
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


********************************************************************************/

%include '_setup.sas';


data cr;
   set source.cr;
   rename EDC_EntryDate = __EDC_EntryDate;
   rename EDC_TreeNodeID = __EDC_TreeNodeID;
 %subject;
 %visit2;
 run;


data pdata.cr(label='Suspected CR Visit Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 crsuspyn;;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 crsuspyn;
	set cr;
run;


