/*********************************************************************
 Program Nmae: sched.sas
  @Author: Yuxiang Ni
  @Initial Date: 2015/04/23
 

 This program is originally from PCYC-1129-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data s_sched;
   set source.sched;
   length SCDTC $19;
   %subject;
   %visit2;
   SCDTC = put(SCDT,yymmdd10.);
run;

proc sort data = s_sched; by SUBJECT SCYN SCREAS SCDTC; run;

************* Derive SCDY ***********;
data sched_dm;
  merge s_sched(in=_in1)
        pdata.dm(in=_in2  keep=SUBJECT __RFSTDTC);
	 by SUBJECT;
  if _in1;
  %concatdy(SCDTC);
run;

data pdata.sched(label="Scheduled Study Visit Prompt");
  retain __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 SCYN SCREAS SCDTC;
  keep __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 SCYN SCREAS SCDTC;
  set sched_dm(rename=(EDC_TreenodeID=__EDC_TreenodeID  EDC_EntryDate=__EDC_EntryDate));
  label SCDTC = 'Visit Date';
run;
