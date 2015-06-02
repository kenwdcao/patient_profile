
%include '_setup.sas';

*<ECOG----------------------------------------------------------------------------------------;
data ecog_301;
	set r301.RD_FRMECOG;
run;

data ecog_302;
	set r302.RD_FRMECOG;
run;

data ecog0102;
	set ecog_301 ecog_302;
	if ITMECOGSCALE ^='';
run;

proc sort data=ecog0102 out=s_ecog0102; by SUBJECTNUMBERSTR DOV; RUN;

DATA ECOG0102_01;
	SET s_ecog0102;
	by SUBJECTNUMBERSTR DOV;
	if last.SUBJECTNUMBERSTR;
run;

data ecog_303;
	set source.RD_FRMECOG;
run;

*****************Get the subjects from both in 303,(301+302)****************;
proc sort data=ecog_303 out=s_ecog_303(keep=SUBJECTNUMBERSTR) nodupkey; by SUBJECTNUMBERSTR; run;

proc sql;
	create table ecog_01 as
	select a.* 
	from ECOG0102_01 as a inner join s_ecog_303 as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
	;
quit;

data ecog_02;
	set ecog_01;
	visitnum=-5;
	VISITMNEMONIC="Wk-1"||'!{super [2]}';
run;

data ecog_03;
	set ecog_303 ecog_02;
	%informatDate(DOV);
	%formatDate(ITMECOGDT_DTS);
	label
		A_DOV='Visit Date'
		ITMECOGDT_DTS='Date performed'
		ITMECOGSCALE='ECOG Performance Scale'
		VISITMNEMONIC='Visit'
	;
	a='';
	rename VISITMNEMONIC=visit;
run;

proc sort data=ecog_03 out=s_ecog_03; by SUBJECTNUMBERSTR DOV; run;

data pdata.ecog17(label='ECOG Performance Scale');
	retain SUBJECTNUMBERSTR visit A_DOV ITMECOGDT_DTS a ITMECOGSCALE;
	keep SUBJECTNUMBERSTR visit A_DOV ITMECOGDT_DTS a ITMECOGSCALE;
	set s_ecog_03;
run;
