/*********************************************************************
 Program Nmae: Death.sas
  @Author: Yuxiang Ni
  @Initial Date: 2015/04/23
 

 This program is originally from PCYC-1129-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data s_death;
   length DTHDTC $19;
   set source.death;
   %subject;
   %concatDate(year=DEATHYY, month=DEATHMM, day=DEATHDD, outdate=DTHDTC);
run;

proc sort data=s_death; by SUBJECT DTHDTC DSAE DEATHCS DSAENUM; run;

proc sort data = pdata.dm out=p_dm; by SUBJECT; run;

data death_dm;

   merge s_death(in=_in1)
         p_dm(in=_in2 keep=SUBJECT __RFSTDTC);
	   by SUBJECT;
   if _in1;
   
   %concatdy(DTHDTC);
run;

data pdata.death(label="Death Report");
   retain __EDC_TreenodeID __EDC_EntryDate SUBJECT DTHDTC DSAE DEATHCS DSAENUM; 
   keep __EDC_TreenodeID __EDC_EntryDate SUBJECT DTHDTC DSAE DEATHCS DSAENUM;
   set death_dm(rename=(EDC_TreenodeID=__EDC_TreenodeID  EDC_EntryDate=__EDC_EntryDate));
   label DTHDTC = "Date of Death";
   label DSAE = "Was Date of Death within 30 days of any study drug administration (within AE Reporting Period)?";
run;
