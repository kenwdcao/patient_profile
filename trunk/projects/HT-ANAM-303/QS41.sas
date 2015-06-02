
%include '_setup.sas';

*<QS41--------------------------------------------------------------------------------------------------------;

******************Deal with 303**********************;
%getVNUM(indata=source.RD_FRMHUNGER, out=RD_FRMHUNGER_3);

data qs0;
	set RD_FRMHUNGER_3(rename=ITMHUNGERASSESS=_ITMHUNGERASSESS);
	%adjustvalue1(dsetlabel=Hunger Assessment Scale);
	%formatDate(ITMHUNGERDT_DTS); %informatDate(DOV);
*-> Modify Variable Label;
attrib
	ITMHUNGERASSESS			label='Date of Hunger Assessment Scale' length=$60
	A_DOV					label='Visit Date'
	; 

if _ITMHUNGERASSESS ^='' and ITMHUNGERDT_DTS ^='' then ITMHUNGERASSESS=ITMHUNGERDT_DTS;
else ITMHUNGERASSESS=_ITMHUNGERASSESS;

if ITMHUNGERASSESS ^='';
keep SUBJECTNUMBERSTR visitnum VISITMNEMONIC dov A_DOV  ITMHUNGERASSESS ITMHUNGERHUNGRY ITMHUNGERAPPETITE;
run;

proc sort data=qs0 out=s_qs0; by SUBJECTNUMBERSTR dov A_DOV visitnum VISITMNEMONIC ITMHUNGERASSESS; run;

proc transpose data=s_qs0 out=t_qs0; 
	by SUBJECTNUMBERSTR dov A_DOV visitnum VISITMNEMONIC ITMHUNGERASSESS;
	var ITMHUNGERHUNGRY ITMHUNGERAPPETITE;
run;


**************Deal with 301 and 302*******************************8;
data hun301_01;
	set r301.RD_FRMHUNGER;
	qsdt=ITMHUNGERDT_DTS;
	%formatDate(ITMHUNGERDT_DTS); %informatDate(DOV);
run;
data hun302_01;
	set r302.RD_FRMHUNGER;
	qsdt=ITMHUNGERDT_DTS;
	%formatDate(ITMHUNGERDT_DTS); %informatDate(DOV);
run;

data hun0102;
	set hun301_01 hun302_01;
if strip(ITMHUNGERASSESS_C) ='DONE';
run;

proc sort data=hun0102 out=s_hun0102; by SUBJECTNUMBERSTR DOV A_DOV qsdt ITMHUNGERDT_DTS VISITMNEMONIC; RUN;

proc transpose data=s_hun0102 out=t_hun0102;
	by SUBJECTNUMBERSTR DOV A_DOV qsdt ITMHUNGERDT_DTS VISITMNEMONIC;
	var ITMHUNGERHUNGRY ITMHUNGERAPPETITE;
run;

data hun0102_01;
	set t_hun0102;
	if col1 ^='';
run;

*****************Get the subjects from both in 303,(301+302)****************;
proc sort data=t_qs0 out=qs_01(keep=SUBJECTNUMBERSTR) nodupkey; by SUBJECTNUMBERSTR; run;

proc sql;
	create table qs_02 as
	select a.* 
	from hun0102_01 as a inner join qs_01 as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
	;
quit;

*****************The last non-missing value from pre-treatment************************;
proc sort data=qs_02 out=s_hun0102_01; by SUBJECTNUMBERSTR _name_ DOV A_DOV qsdt ITMHUNGERDT_DTS VISITMNEMONIC; RUN;

data hun0102_02;
	length visitnum 8 visit $60;
	set s_hun0102_01;
	by SUBJECTNUMBERSTR _name_ DOV A_DOV qsdt ITMHUNGERDT_DTS;
	if last._name_;
	visitnum=-5;
	VISITMNEMONIC="Wk-1"||'!{super [2]}';
run;

*****************Get the last visit date from pre-treatment****************;
proc sort data=hun0102_02 out=s_hun0102_02; by SUBJECTNUMBERSTR DOV A_DOV _name_ qsdt ITMHUNGERDT_DTS VISITMNEMONIC; RUN;

data hun0102_03;
	set s_hun0102_02;
	by SUBJECTNUMBERSTR DOV A_DOV _name_ qsdt ITMHUNGERDT_DTS VISITMNEMONIC;
	if last.SUBJECTNUMBERSTR;
	keep SUBJECTNUMBERSTR A_DOV;
run;

*****************Get the most qsdt from pre-treatment****************;
proc sql;
	create table qsdt as
	select *,count(qsdt) as n
	from hun0102_02 
	group by SUBJECTNUMBERSTR, qsdt
	;
quit;

proc sort data=qsdt out=qsdt01 nodupkey; by SUBJECTNUMBERSTR qsdt n; run;

proc sort data=qsdt01 out=qsdt02;by SUBJECTNUMBERSTR n; run;

data qsdt03;
	set qsdt02;
	by SUBJECTNUMBERSTR n; 
	if last.SUBJECTNUMBERSTR;
/*	rename ITMHUNGERDT_DTS=ITMHUNGERASSESS;*/
run;
************************End**************************;
data hun01;
	length SUBJECTNUMBERSTR $20 ITMHUNGERDT_DTS $19;
	if _n_=1 then do;
		declare hash h (dataset :'qsdt03');
		rc=h.defineKey ('SUBJECTNUMBERSTR');
		rc=h.defineData ('ITMHUNGERDT_DTS');
		rc=h.defineDone ();
		call missing (SUBJECTNUMBERSTR,ITMHUNGERDT_DTS);
	end;
	set hun0102_02(rename=(ITMHUNGERDT_DTS=ITMHUNGERDT_DTS_));
	rc=h.find();
	if ITMHUNGERDT_DTS=ITMHUNGERDT_DTS_ then COL1=COL1;
	else COL1=strip(COL1)||' ('||strip(ITMHUNGERDT_DTS_)||')';
	keep SUBJECTNUMBERSTR visitnum visitmnemonic ITMHUNGERDT_DTS _NAME_ COL1;
run;

proc sql;
	 create table hun02 as
	 select a.*,b.A_DOV
	 from hun01 as a left join hun0102_03 as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR;
quit;

data hun03;
	set t_qs0 hun02(rename=ITMHUNGERDT_DTS=ITMHUNGERASSESS);
run;

data hun04;
	length vnum $100 VISITMNEMONIC $400 test $200;
	set hun03;
	format VISITMNEMONIC $200.;
	vnum='v_'||strip(put(VISITNUM*10,best.));
	if int(VISITNUM)^=VISITNUM then vnum=strip(vnum)||'_D';
	if index(VISITMNEMONIC,'UNS')>0 then VISITMNEMONIC='Unscheduled';
	VISITMNEMONIC=strip(VISITMNEMONIC)||'#'||strip(A_DOV);
	rename VISITMNEMONIC=A_VISITMNEMONIC A_DOV=B_DOV ITMHUNGERASSESS=C_ITMHUNGERASSESS col1=D_COL1;
	if _name_="ITMHUNGERHUNGRY" then test="I have felt hungry";
		else if _name_="ITMHUNGERAPPETITE" then test="My family and/or friends are pleased with my appetite";
run;

proc sort data=hun04; by SUBJECTNUMBERSTR test; run;
proc transpose data=hun04 out=t_hun04; 
	by SUBJECTNUMBERSTR test;
	id vnum;
	var A_VISITMNEMONIC C_ITMHUNGERASSESS D_COL1;
run;

data hun05;
	set t_hun04(rename=(test=qstest _name_=__name));
	label qstest='QSTEST';
	if __name='A_VISITMNEMONIC' then qstest='Label';
		else if __name='C_ITMHUNGERASSESS' then qstest='Date of Hunger Assessment Scale';
run;

proc sort data=hun05 out=s_hun05 nodupkey; by SUBJECTNUMBERSTR qstest;run;
proc sort data=s_hun05; by SUBJECTNUMBERSTR __name; run;


%adjustVisitVarOrder(indata=s_hun05,othvars=SUBJECTNUMBERSTR QSTEST);

data pdata.qs41(label='Hunger Assessment Scale');
	set s_hun05;
run;
