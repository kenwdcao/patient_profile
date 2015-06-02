%include '_setup.sas';

*<Demo----------------------------------------------------------------------------------------;
data dm0;
	length RACE $100;
	set source.RD_FRMDM;
	%adjustvalue(dsetlabel=Demography);
	%informatDate(DOV);
	*-> Modify Variable Label;
	label 
		ITMDMIFCDT_DTS = 'Date Informed#Consent Signed'
		ITMDMDOB_DTS = 'Date of Birth'
		ITMDMGENDER='Gender'
		ITMDMETHNIC='Ethnicity'
		A_DOV='Visit Date'
		RACEOTH = 'Race Other,#Specify'
		RACE='Race'
		SITECOUNTRY='Country'
		ITMDMSTATUS='Current Status'
		INVNAM='Investigator Name'
		ITMUPWRKFLW_CITMUPWRKFLW='Update workflow for subject?'
		__SEX='Sex'
		__SUBJECT='SUBJECT'
	;
	__SEX=strip(ITMDMGENDER_C);
	%ageint(RFSTDTC=ITMDMIFCDT_DTS, BRTHDTC=ITMDMDOB_DTS, Age=AGE);
	__SUBJECT=SUBJECTNUMBERSTR;
	INVNAM=substr( SITENAME , 7);
	RACEOTH =ITMDMRACEOTHSPC;
	ITMDMRACEOTHSPC_C=propcase(ITMDMRACE_ITMDMRACEOTHSPC_C);
	RACE=catx(', ',ITMDMRACE_CITMRACEAMIND,ITMDMRACE_CITMRACEASIAN,ITMDMRACE_CITMRACEBLACK,
					ITMDMRACE_CITMRACEHAWPAC,ITMDMRACE_CITMRACEWHITE,ITMDMRACEOTHSPC_C);
run;
proc sql;
	create table dm0_1 as 
	select a.*,b.Treatment_Group
	from dm0 as a left join source.h301_treatment_group as b
	on a.SUBJECTNUMBERSTR=b.Subject_ID;
quit;

proc sql;
	create table dm06 as 
	select a.*,b.ITMEOSCOMPLETE_C,b.ITMEOSREASON,b.ITMEOSETDT_DTS
	from (select * from dm0_1) as a
			left join 
          (select * from source.RD_FRMEOS) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR;
quit;

*********************;
data eos;
	set source.RD_FRMEOS;
	dsdov_c=strip(put(input(substr(strip(put(DOV,DATETIME20.)),1,9),date9.),yymmdd10.));
	if ITMEOSETDT_DTS='' and dsdov_c^='' then ITMEOSETDT_DTS=dsdov_c;
	else ITMEOSETDT_DTS=ITMEOSETDT_DTS;
	keep SUBJECTNUMBERSTR ITMEOSETDT_DTS dsdov_c;
run;
proc sql;
	create table _visitindex1 as 
	select a.*,b.ITMEOSETDT_DTS
	from (select * from pdata._visitindex) as a
			left join 
          (select * from eos) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR;
quit;
data _visitindex2;
	set _visitindex1;
	if ITMEOSETDT_DTS='' or (dov_c=<ITMEOSETDT_DTS and dov_c^='' and visitmnemonic^='Day 113/Wk16');
run;
proc sort data=_visitindex2 out=_visitindex_;by SUBJECTNUMBERSTR VISITNUM DOV_C;run;
data lastv_;
	set _visitindex_(rename=(DOV_C=L_DOV_C));
	by SUBJECTNUMBERSTR;
	keep SUBJECTNUMBERSTR IN_VISITMNEMONIC L_DOV_C;
	if last.SUBJECTNUMBERSTR;
run;
proc sql;
	create table lastv1 as 
	select a.SUBJECTNUMBERSTR,a.IN_VISITMNEMONIC,a.VISITNUM,b.L_DOV_C
	from (select * from _visitindex_) as a
			left join 
          (select * from lastv_) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
	having a.DOV_C=b.L_DOV_C;
quit;
proc sort data=lastv1 ;by SUBJECTNUMBERSTR L_DOV_C VISITNUM ;run;
data lastv;
	length lastvisit $100;
	set lastv1;
	by SUBJECTNUMBERSTR L_DOV_C;
	retain lastvisit;
	if first.L_DOV_C then lastvisit=IN_VISITMNEMONIC;
	else lastvisit=strip(lastvisit)||', '||strip(IN_VISITMNEMONIC);
	if last.L_DOV_C;
run;
data dm060;
	length __STAT $100 __SEX $3 SUBJECTNUMBERSTR $20 lastvisit $100 __title2 $200 __treat $100;;
	if _n_=1 then do;
		declare hash h (dataset:'lastv');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('lastvisit');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, lastvisit);
	end;
	set dm06;
	%formatDate(ITMDMIFCDT_DTS);
	%formatDate(ITMDMDOB_DTS);
	%formatDate(ITMEOSETDT_DTS);
	**************add treatment information*****************;
	if Treatment_Group='Placebo' then __treat='Placebo';
		else if Treatment_Group='Anamorelin HCl 100 mg' then __treat='Anamorelin HCl';
		else if Treatment_Group='' and ITMDMSTATUS='Subject in screening/screen failed with an SAE' then __treat='Screen Failure';
		else if Treatment_Group='' and ITMDMSTATUS='' then __treat='NA';
	**********************************************************;
	if ITMEOSCOMPLETE_C='COMPLETED' then __STAT='Completed: '||strip(ITMEOSETDT_DTS);
	else if ITMEOSCOMPLETE_C='NOT COMPLETED' then do;
		if index(ITMEOSREASON,",")>0 then __STAT=strip(scan(ITMEOSREASON,1,','))||': '||strip(ITMEOSETDT_DTS); 
		else if index(ITMEOSREASON,"Adverse Event unrelated to study drug")>0 then __STAT='AE unrelated to study drug'||': '||strip(ITMEOSETDT_DTS); 
		else if index(ITMEOSREASON,"Adverse Event related to study drug")>0 then __STAT='AE related to study drug'||': '||strip(ITMEOSETDT_DTS); 
	end;
	else if ITMEOSCOMPLETE_C='' and (ITMDMSTATUS='Randomized subject' OR strip(ITMDMSTATUS)='') 
		then __STAT="^{style [foreground=&abovecolor] Screen Failure }";
	else if ITMEOSCOMPLETE_C='' and ITMDMSTATUS='Subject in screening/screen failed with an SAE' 
		then __STAT="^{style [foreground=&abovecolor] Screen Failure }";
	if AGE='' then AGE='NA';
	__AGE=strip(AGE)||'^{super [1]}';
	if __SEX='' then __SEX='NA';
	__title=strip(__SUBJECT)||' / '||strip(__treat)||' / '||strip(__SEX)||' / '||strip(__AGE)||' / '||strip(__STAT);
	rc=h.find();
	if lastvisit^='' and __STAT^='Ongoing' then __title2= 'Last Visit Before Discontinuation: '||strip(lastvisit);
		else __title2='Last Visit Before Discontinuation: NA';
run;
proc sql;
	create table firstdose as 
	select DISTINCT SUBJECTNUMBERSTR,min(ITMDRUGFIRSTDOSEDT_DTS) as fdosedt
	from source.RD_FRMDRUG_ACTIVE
	group by SUBJECTNUMBERSTR;
quit;
data dm0601;
	length SUBJECTNUMBERSTR $20 fdosedt $19;
	if _n_=1 then do;
		declare hash h (dataset:'firstdose');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('fdosedt');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, fdosedt);
	end;
	set dm060;
	rc=h.find();
	%formatDate(fdosedt);
	if fdosedt^='' then __title2='First Dose Date: '||strip(fdosedt)|| ' / '||strip(__title2);
		else __title2='First Dose Date: NA / '||strip(__title2);
run;
data pdata.dm06(label='Demography');
	retain &globalvars1 ITMDMIFCDT_DTS ITMDMDOB_DTS ITMDMGENDER ITMDMETHNIC
		 RACE RACEOTH SITECOUNTRY ITMDMSTATUS ITMUPWRKFLW_CITMUPWRKFLW __title __title2 __SUBJECT __SEX __AGE __STAT __treat; 
	keep &globalvars1 ITMDMIFCDT_DTS ITMDMDOB_DTS ITMDMGENDER ITMDMETHNIC
		 RACE RACEOTH SITECOUNTRY ITMDMSTATUS ITMUPWRKFLW_CITMUPWRKFLW __title __title2 __SUBJECT __SEX __AGE __STAT __treat;  
	set dm0601;
/*	if __STAT^='Ongoing';*/
run;
data pdata.dmcomp(label='Demography');
	retain &globalvars1 ITMDMIFCDT_DTS ITMDMDOB_DTS ITMDMGENDER ITMDMETHNIC
		 RACE RACEOTH SITECOUNTRY ITMDMSTATUS ITMUPWRKFLW_CITMUPWRKFLW __title __title2 __SUBJECT __SEX __AGE __STAT __treat; 
	keep &globalvars1 ITMDMIFCDT_DTS ITMDMDOB_DTS ITMDMGENDER ITMDMETHNIC
		 RACE RACEOTH SITECOUNTRY ITMDMSTATUS ITMUPWRKFLW_CITMUPWRKFLW __title __title2 __SUBJECT __SEX __AGE __STAT __treat;  
	set dm0601;
	if __STAT^='Ongoing' and index(__STAT,'Screen Failure')=0;
run;
*------------------------------------------------------------------------------------------>;
