/*********************************************************************
 Program Nmae: opth.sas
  @Author: Yuxiang Ni
  @Initial Date: 2015/04/23
 

 This program is originally from PCYC-1129-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/


%include '_setup.sas';

data s_opth;
    length OPDTC $19;
    set source.opth;
	%subject;
	%visit2;
	OPDTC = put(OPDT,yymmdd10.); 
run;

/*proc sort data = s_kps; by SUBJECT OPDTC OPTEST OPORRES OPCOM OPORRESO; run;*/

data opth_dm; 
   merge s_opth(in=_in1)
         pdata.dm(in=_in2 keep=SUBJECT __RFSTDTC);
	  by SUBJECT;
   if _in1;
   
   %concatdy(OPDTC);
run;

data pdata.opth(label="Ophthalmologic Exam");
   retain __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 OPDTC OPTEST OPORRES OPCOM OPORRESO ;
   keep __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 OPDTC OPTEST OPORRES OPCOM OPORRESO ;
   set opth_dm(rename=(EDC_TreenodeID=__EDC_TreenodeID  EDC_EntryDate=__EDC_EntryDate));

   label OPDTC = "Assessment Date";
run;
