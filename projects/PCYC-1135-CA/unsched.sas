/*********************************************************************
 Program Nmae: unsched.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data unsched0;
    set source.unsched;
	%subject;
    keep EDC_TreeNodeID SUBJECT	VISIT BUCCAL COAGL CRCL TUMKRL ECOG EG HEMATL HEPATL IMG LSNEW LSNTG RS	
         PDMEDI PDSAMPLE PE PREG SCHEML LSTG TSHL TSHLFUP TBX URINL VS UNSSEQ EDC_EntryDate;
run;

data unsched1;
    set unsched0;
    %visit2;
	length uns01-uns23 $50 unsched $200;
	label unsched = 'Unscheduled Form Name';
	array unsch(*)buccal coagl crcl tumkrl ecog eg hematl hepatl img lsnew lsntg rs	
                  pdmedi pdsample pe preg scheml lstg tshl tshlfup tbx urinl vs;
	array uns(*) uns01-uns23;
	do i = 1 to dim(unsch);
        if unsch[i] = 'Checked' then uns[i] = substr(vlabel(unsch[i]), 12);
    end;
	unsched = catx(', ', of uns:);
	drop uns0:; 
run;

proc sort data = unsched1; by subject visit2; run;

data pdata.unsched(label='Unscheduled Visit Assessments');
    retain EDC_TreeNodeID EDC_EntryDate subject visit2 unsched;
	keep   EDC_TreeNodeID EDC_EntryDate subject visit2 unsched;

	set unsched1;
	
	rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
run;
