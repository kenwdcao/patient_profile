/*********************************************************************
 Program Nmae: pdfu.sas
  @Author: Yuxiang Ni
  @Initial Date: 2015/04/23
 

 This program is originally from PCYC-1129-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data s_pdfu;
   length FUCONDTC $19 FULAVDTC $19;
   set source.pdfu;
   %subject;
   %visit2;
   FUCONDTC = put(FUCONTDT,yymmdd10.);
   FULAVDTC = put(FULALVDT,yymmdd10.);
run;
 
proc sort data = s_pdfu; by SUBJECT FUCONDTC FUALIVE FUANTINE FULAVDTC; run;

************* Derive FUCONTDY ***********;
data pdfu_dm;
  merge s_pdfu(in=_in1)
        pdata.dm(in=_in2  keep=SUBJECT __RFSTDTC);
	 by SUBJECT;
  if _in1;
  %concatdy(FUCONDTC);
  %concatdy(FULAVDTC);
run;

************* Long-Term Follow-Up *************;
data pdata.pdfu1(label="Long-Term Follow-Up");
   retain __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 FUCONDTC FUALIVE FUANTINE FULAVDTC ; 
   keep __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 FUCONDTC FUALIVE FUANTINE FULAVDTC ;
   set pdfu_dm(rename=(EDC_TreenodeID=__EDC_TreenodeID  EDC_EntryDate=__EDC_EntryDate));
   label FUCONDTC = "Date of Contact";
   label FULAVDTC = "If Lost to Follow-Up, date subject was last known to be alive";
run;

data pdata.pdfu2(label="Long-Term Follow-Up Prompt");
   retain __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 FUYN;
   keep __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 FUYN;
   set pdfu_dm(rename=(EDC_TreenodeID=__EDC_TreenodeID  EDC_EntryDate=__EDC_EntryDate));
run; 
