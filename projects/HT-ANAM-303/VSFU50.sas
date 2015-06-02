
%include '_setup.sas';

*<VSFU----------------------------------------------------------------------------------------;
data vsfu_301;
	set r301.RD_FRMFOLLOW;
run;

data vsfu_302;
	set r302.RD_FRMFOLLOW;
run;

data vsfu0102;
	set vsfu_301 vsfu_302;
	if ITMFOLLOWWEIGHT ^=.;
run;

proc sort data=vsfu0102 out=s_vsfu0102; by SUBJECTNUMBERSTR DOV; RUN;

data vsfu0102_01;
	set s_vsfu0102;
	by SUBJECTNUMBERSTR DOV;;
	if last.SUBJECTNUMBERSTR;
run;

data vsfu_303;
	set source.RD_FRMFOLLOW;
	drop ITMFOLLOWWEIGHT_U;
run;

*****************Get the subjects from both in 303,(301+302)****************;
proc sort data=vsfu_303 out=s_vsfu_303(keep=SUBJECTNUMBERSTR) nodupkey; by SUBJECTNUMBERSTR; run;

proc sql;
	create table vsfu_01 as
	select a.* 
	from vsfu0102_01 as a inner join s_vsfu_303 as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
	;
quit;

data vsfu_02;
	set vsfu_01;
	visitnum=-5;
	VISITMNEMONIC="Wk-1"||'!{super [2]}';
	drop ITMFOLLOWWEIGHT_U;
run;


data VSFU_03;
	set vsfu_303 vsfu_02;
	%informatDate(DOV);
	label
		A_DOV='Visit Date'
		WEIGHT='Body weight#<kg>'
	;
	%char(var=ITMFOLLOWWEIGHT,newvar=WEIGHT);
run;

proc sort data=vsfu_03 out=s_vsfu_03; by SUBJECTNUMBERSTR dov; run;
data pdata.VSFU50(label='Follow-up Period');
	retain SUBJECTNUMBERSTR VISITMNEMONIC A_DOV WEIGHT;
	keep SUBJECTNUMBERSTR VISITMNEMONIC A_DOV WEIGHT;
	set s_vsfu_03;
	label VISITMNEMONIC='Visit';
run;
