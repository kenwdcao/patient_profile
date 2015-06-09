%include '_setup.sas';

*<zs----------------------------------------------------------------------------------------;
data zs0;
	length __sortkey $200;
	set source.rd_frmsurvival_active;
	%adjustvalue(dsetlabel=Long-Term Survival);
	%informatDate(DOV);
	%formatDate(ITMSURVIVALDT_DTS);
	%formatDate(ITMSURVIVALDEATHDT_DTS);
	%formatDate(ITMSURVIVALLSTPHDT_DTS);
	%formatDate(ITMSURVIVALREGLETDT_DTS);
	label
		A_DOV='Visit Date'
		SURVIVALDT='Date'
		ITMSURVIVALMETHCON='Method of contact'
		STATUS='Patient Status'
		ITMSURVIVALAUTOPERF='Was an autopsy performed?'
		CAUDEATH='Cause of Death'
		ITMSURVIVALLSTPHDT_DTS='Date of last attempt to phone patient'
		ITMSURVIVALREGLETDT_DTS='Date of registered/formal letter to patient'
	;
	if ITMSURVIVALDONE_C='DONE' then SURVIVALDT=ITMSURVIVALDT_DTS;
		else if ITMSURVIVALDONE_C='NONE' then SURVIVALDT='None';else SURVIVALDT='';
	%concatyn(var=ITMSURVIVALPTSTAT,oth=ITMSURVIVALDEATHDT_DTS,newvar=STATUS);
	%concatoth(var=ITMSURVIVALCAUDEATH_C,oth=ITMSURVIVALDEATHOTH,newvar=CAUDEATH);

	__sortkey=lowcase(strip(ITMSURVIVALMETHCON));

	if cmiss(SURVIVALDT,ITMSURVIVALMETHCON,STATUS,ITMSURVIVALAUTOPERF,CAUDEATH,
		ITMSURVIVALLSTPHDT_DTS,ITMSURVIVALREGLETDT_DTS)< 7;

run;

proc sort data=zs0; by SUBJECTNUMBERSTR ITMSURVIVALDT __sortkey;run;
data pdata.zs54(label='Long-Term Survival');
	retain &GlobalVars2 SURVIVALDT ITMSURVIVALMETHCON STATUS ITMSURVIVALAUTOPERF CAUDEATH ITMSURVIVALLSTPHDT_DTS ITMSURVIVALREGLETDT_DTS __FORMIDX;
	keep &GlobalVars2 SURVIVALDT ITMSURVIVALMETHCON STATUS ITMSURVIVALAUTOPERF CAUDEATH ITMSURVIVALLSTPHDT_DTS ITMSURVIVALREGLETDT_DTS __FORMIDX;
	set zs0(rename=(FORMIDX=__FORMIDX));
run;
*------------------------------------------------------------------------------------------>;
