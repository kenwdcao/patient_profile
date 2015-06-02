
%include '_setup.sas';

%macro tutrn(source=,flag=);
%getVNUM1(indata=&source..RD_FRMNTARGET1_ACTIVE, pdata=_visitindex_&source,out=RD_FRMNTARGET1_ACTIVE);
%getVNUM1(indata=&source..RD_FRMNTARGET2_ACTIVE,pdata=_visitindex_&source, out=RD_FRMNTARGET2_ACTIVE);
data tutr1n;
	length EVALDT $19 PROCEDURE $200 SITE $200;
	set RD_FRMNTARGET1_ACTIVE;
	%informatDate(DOV);
	%formatDate(ITMNTAR1EVALDT_DTS);
	label
		A_DOV='Visit Date'
		TUMCOD='Tumor Code'
		SITE='Site'
		PROCEDURE='Procedure'
		EVALDT='Date of Evaluation'
	;
	TUMCOD=ITMNTAR1TUMCOD;
	EVALDT=ITMNTAR1EVALDT_DTS;
	%concatoth(var=ITMNTAR1SITCDOTH_C,oth=ITMNTAR1LSITOTH,newvar=SITEOTH);
	if ITMNTAR1SITCD^='' then SITE=ITMNTAR1SITCD;else SITE=SITEOTH;
	%concatoth(var=ITMNTAR1PROC_C,oth=ITMNTAR1PROCOTH,newvar=PROCEDURE1);
	if ITMNTAR1PROC='Other, specify' then PROCEDURE=PROCEDURE1;else PROCEDURE=ITMNTAR1PROC;
	keep SUBJECTNUMBERSTR visitmnemonic dov a_dov TUMCOD SITE PROCEDURE EVALDT;
run;
*------------------------------------------------------------------------------------------>;

*<TUTR2N----------------------------------------------------------------------------------------;
data tutr2n;
	length EVALDT $19 PROCEDURE $200 SITE $200;
	set RD_FRMNTARGET2_ACTIVE(rename=(visitnum=__visitnum));
	%informatDate(DOV);
	%formatDate(ITMNTAR2EVALDT_DTS);
	label
		A_DOV='Visit Date'
		TUMCOD='Tumor Code'
		SITE='Site'
		PROCEDURE='Procedure'
		EVALDT='Date of Evaluation'
		ITMNTAR2CURSTAT='Current Status'
	;
	TUMCOD=ITMNTAR2TUMCOD;
	if ITMNTAR2EVALDTDONE_C='NOT EVALUATED' then EVALDT=ITMNTAR2EVALDTDONE;
	   else if ITMNTAR2EVALDTDONE_C='DONE' then EVALDT=ITMNTAR2EVALDT_DTS;
	%concatoth(var=ITMNTAR2SITCDOTH_C,oth=ITMNTAR2SITOTH,newvar=SITEOTH);
	if ITMNTAR2SITCD^='' then SITE=ITMNTAR2SITCD;else SITE=SITEOTH;
	%concatoth(var=ITMNTAR2PROC_C,oth=ITMNTAR2PROCOTH,newvar=PROCEDURE1);
	if ITMNTAR2PROC='Other, specify' then PROCEDURE=PROCEDURE1;else PROCEDURE=ITMNTAR2PROC;
	keep SUBJECTNUMBERSTR visitmnemonic dov A_DOV TUMCOD SITE PROCEDURE EVALDT ITMNTAR2CURSTAT;
run;

data tutrn;
length flag $20;
	set tutr1n tutr2n;
	flag="&flag";
	keep SUBJECTNUMBERSTR FLAG visitmnemonic dov A_DOV TUMCOD SITE PROCEDURE EVALDT ITMNTAR2CURSTAT;
	retain SUBJECTNUMBERSTR FLAG visitmnemonic dov A_DOV TUMCOD SITE PROCEDURE EVALDT ITMNTAR2CURSTAT;
run;
proc sort data=tutrn OUT=tutrn_&source;by SUBJECTNUMBERSTR DOV a_dov TUMCOD;run;
%mend tutrn;

%tutrn(source=r301,flag=ANAM301);
%tutrn(source=r302,flag=ANAM302);

%getVNUM(indata=source.rd_frmntarget_active, out=rd_frmntarget_active);
*<TUTR2N----------------------------------------------------------------------------------------;
data tutr2n;
	length EVALDT $19 PROCEDURE $200 SITE $200 FLAG $20;
	set rd_frmntarget_active(rename=(visitnum=__visitnum));
	%informatDate(DOV);
	%formatDate(ITMNTAR2EVALDT_DTS);
	label
		A_DOV='Visit Date'
		TUMCOD='Tumor Code'
		SITE='Site'
		PROCEDURE='Procedure'
		EVALDT='Date of Evaluation'
		ITMNTAR2CURSTAT='Current Status'
		visitmnemonic='Visit'
	;
	TUMCOD=ITMNTAR2TUMCOD;
	if ITMNTAR2EVALDTDONE_C='NOT EVALUATED' then EVALDT=ITMNTAR2EVALDTDONE;
	   else if ITMNTAR2EVALDTDONE_C='DONE' then EVALDT=ITMNTAR2EVALDT_DTS;
	%concatoth(var=ITMNTAR2SITCDOTH_C,oth=ITMNTAR2SITOTH,newvar=SITEOTH);
	if ITMNTAR2SITCD^='' then SITE=ITMNTAR2SITCD;else SITE=SITEOTH;
	%concatoth(var=ITMNTAR2PROC_C,oth=ITMNTAR2PROCOTH,newvar=PROCEDURE1);
	if ITMNTAR2PROC='Other, specify' then PROCEDURE=PROCEDURE1;else PROCEDURE=ITMNTAR2PROC;
	flag="ANAM303";
	keep SUBJECTNUMBERSTR FLAG visitmnemonic dov A_DOV TUMCOD SITE PROCEDURE EVALDT ITMNTAR2CURSTAT;
run;

data tutrn_01;
	set tutrn_r301 tutrn_r302;
run;

proc sort data=tutr2n out=s_tutr2n(keep=SUBJECTNUMBERSTR) nodupkey; by SUBJECTNUMBERSTR ; run;

proc sql;
	create table tutrn_02 as
	select a.*
	from tutrn_01 as a inner join s_tutr2n as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
;
quit;

data tutrn_03;
	set tutrn_02 tutr2n;
run;

proc sort data= tutrn_03 out=s_tutrn_03;by SUBJECTNUMBERSTR dov a_dov TUMCOD;run;

data pdata.TUTRN(label='Non-Target Lesions');
	retain SUBJECTNUMBERSTR FLAG visitmnemonic A_DOV TUMCOD SITE PROCEDURE EVALDT ITMNTAR2CURSTAT;;
	keep SUBJECTNUMBERSTR FLAG visitmnemonic A_DOV TUMCOD SITE PROCEDURE EVALDT ITMNTAR2CURSTAT;;
	set s_tutrn_03;
	label flag='Study ID'
		  visitmnemonic='Visit';
run;
