/*********************************************************************
 Program Nmae: dh.sas
  @Author: Yuxiang Ni
  @Initial Date: 2015/04/23
 

 This program is originally from PCYC-1129-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data s_dh;
   length DHSTDTC $19;
   set source.dh;
   %concatDate(year=DHSTYY, month=DHSTMM, day=DHSTDD, outdate=DHSTDTC);
   %subject;
   %visit2;
run;

proc sort data = s_dh; by SUBJECT DHSTDTC; run;

************* Derive DHSTDY ***********;
data dh_dm;
  merge s_dh(in=_in1)
        pdata.dm(in=_in2  keep=SUBJECT __RFSTDTC);
	 by SUBJECT;
  if _in1;
  %concatdy(DHSTDTC);
run;

data pdata.dh(label="cGVHD Disease History");
  retain __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 DHSTDTC;
  keep __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 DHSTDTC;
  set dh_dm(rename=(EDC_TreenodeID=__EDC_TreenodeID  EDC_EntryDate=__EDC_EntryDate));
  label DHSTDTC  = "Initial cGVHD Diagnosis Date";
run;
