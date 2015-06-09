/*********************************************************************
 Program Nmae: pd.sas
  @Author: Yuxiang Ni
  @Initial Date: 2015/04/23
 

 This program is originally from PCYC-1129-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data s_pd;
   length PKDTC $19 PKTMC $19;
   set source.pd;
   %subject;
   %visit2;
   PKDTC = put(PKDT,yymmdd10.);
   PKTMC = put(PKTM,time5.);
   PKCDOTMC = put(PKCDOTM,time5.);
   PKCDOTMU = ifc(PKCDOTMU^='','Yes','');
   __PDORD = ifn(PKTPT='Pre-Dose',1,2,.);
run;

proc sort data = s_pd; by SUBJECT PKDTC PKSTAT PKCDOTMC PKCDOTMU __PDORD PKTPT PKTMC PKND PKNDS; run;

   ************* Derive PKDY ***********;
data pd_dm;
  merge s_pd(in=_in1)
        pdata.dm(in=_in2  keep=SUBJECT __RFSTDTC);
	 by SUBJECT;
  if _in1;
  %concatdy(PKDTC);
run;

data pdata.pd(label="Pharmacodynamics (PD)");
  retain __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 PKDTC PKSTAT PKCDOTMC PKCDOTMU PKTPT PKTMC PKND PKNDS;;
  keep __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 PKDTC PKSTAT PKCDOTMC PKCDOTMU PKTPT PKTMC PKND PKNDS;
  set pd_dm(rename=(EDC_TreenodeID=__EDC_TreenodeID  EDC_EntryDate=__EDC_EntryDate));

  label PKDTC = "PD Sample Collection Date";
  label PKTMC = "Time of Sample";
  label PKCDOTMC = "Current Ibrutinib Dose Time";
run;
