/*********************************************************************
 Program Nmae: kps.sas
  @Author: Yuxiang Ni
  @Initial Date: 2015/04/23
 

 This program is originally from PCYC-1129-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data s_kps;
    length QSDTC $19;
    set source.kps;
	%subject;
	%visit2;
	QSDTC = put(QSDT,yymmdd10.); 
run;

proc sort data = s_kps; by SUBJECT QSDTC QSSCORE; run;

data kps_dm; 
   merge s_kps(in=_in1)
         pdata.dm(in=_in2 keep=SUBJECT __RFSTDTC);
	  by SUBJECT;
   if _in1;
   
   %concatdy(QSDTC);
run;

data pdata.kps(label="Karnofsky Performance Status (KPS)");
   retain __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 QSDTC QSSCORE ;
   keep __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 QSDTC QSSCORE ;
   set kps_dm(rename=(EDC_TreenodeID=__EDC_TreenodeID  EDC_EntryDate=__EDC_EntryDate));

   label QSDTC = "Assessment Date";
/*   label VISIT = "Visit";*/
run;
