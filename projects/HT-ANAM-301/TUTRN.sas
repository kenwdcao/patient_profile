%include '_setup.sas';

*<TUTR1N----------------------------------------------------------------------------------------;
%getVNUM(indata=source.RD_FRMNTARGET1_ACTIVE, out=RD_FRMNTARGET1_ACTIVE);
%getVNUM(indata=source.RD_FRMNTARGET2_ACTIVE, out=RD_FRMNTARGET2_ACTIVE);
data tutr1n;
	length EVALDT $19 PROCEDURE $200 SITE $200;
	set RD_FRMNTARGET1_ACTIVE(rename=(visitnum=__visitnum));
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
	keep &GlobalVars4 TUMCOD SITE PROCEDURE EVALDT;
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
	keep &GlobalVars4 TUMCOD SITE PROCEDURE EVALDT ITMNTAR2CURSTAT;
run;
data tutrn;
	set tutr1n tutr2n;
run;
proc sort data= tutrn;by SUBJECTNUMBERSTR __visitnum a_dov TUMCOD;run;
data pdata.TUTRN(label='Non-Target Lesions');
	retain &GlobalVars4 TUMCOD SITE PROCEDURE EVALDT ITMNTAR2CURSTAT;;
	keep &GlobalVars4 TUMCOD SITE PROCEDURE EVALDT ITMNTAR2CURSTAT;;
	set TUTRN;
run;
*------------------------------------------------------------------------------------------>;
