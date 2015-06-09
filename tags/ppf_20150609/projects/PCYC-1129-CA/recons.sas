/*********************************************************************
 Program Nmae: recons.sas
  @Author: Yuxiang Ni
  @Initial Date: 2015/04/23
 

 This program is originally from PCYC-1129-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data s_recons;
    set source.recons;
	%subject;
run;

proc sort data = s_recons; by SUBJECT RECONS REPROTA REDTC ; run;

proc sort data=pdata.dm out=p_dm; by SUBJECT ; run;

data recons_dm;
  length REDTCC $19;
     merge s_recons(in=_in1)
	       p_dm(in=_in2 keep=SUBJECT __RFSTDTC);
		by SUBJECT;
	 if _in1;
  REDTCC = put(REDTC,yymmdd10.); 
  %concatdy(REDTCC);
run;

data pdata.recons(label="Subject Re-Consent");
  retain __EDC_TreenodeID __EDC_EntryDate SUBJECT RECONS REPROTA REDTCC;
  keep __EDC_TreenodeID __EDC_EntryDate SUBJECT RECONS REPROTA REDTCC; 
  set recons_dm(rename=(EDC_TreenodeID=__EDC_TreenodeID  EDC_EntryDate=__EDC_EntryDate));

  label REDTCC = "Informed Re-Consent Date";
  label REPROTA = "Protocol Amendment Number";
run;
  
        
