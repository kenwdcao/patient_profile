/*********************************************************************
 Program Nmae: dssym.sas
  @Author: Yuxiang Ni
  @Initial Date: 2015/04/23
 

 This program is originally from PCYC-1129-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data s_dssym;
    length CEDTC $19;
    set source.dssym;
	%subject;
	CEDTC = put(CEDT,yymmdd10.); 
	if not missing(VISDAY) then VISIT = catx(' ',VISIT,VISDAY);
	__CEGRPID = input(CEGRPID,best.);
run;

proc sort data = s_dssym; by SUBJECT CEDTC __CEGRPID CETERM CEOCCUR CESCAT; run;

data dssym_dm; 
   merge s_dssym(in=_in1)
         pdata.dm(in=_in2 keep=SUBJECT __RFSTDTC);
	  by SUBJECT;
   if _in1;
   
   %concatdy(CEDTC);
run;

data pdata.dssym(label="Lee cGVHD Symptom Scale");
   retain __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT CEDTC CESCAT CEGRPID CETERM CEOCCUR;
   keep __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT CEDTC CESCAT CEGRPID CETERM CEOCCUR;
   set dssym_dm(rename=(EDC_TreenodeID=__EDC_TreenodeID  EDC_EntryDate=__EDC_EntryDate));

   label CEDTC = "Assessment Date";
   label VISIT = "Visit";
run;

   
