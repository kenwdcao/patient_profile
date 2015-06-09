
%include '_setup.sas';

*<QS33--------------------------------------------------------------------------------------------------------;
**************Deal with 301,302 and 303*******************************;
%getVNUM(indata= r301.RD_FRMKARNOFSKY, out=RD_FRMKARNOFSKY_1);
%getVNUM(indata= r302.RD_FRMKARNOFSKY, out=RD_FRMKARNOFSKY_2);
%getVNUM(indata= source.RD_FRMKARNOFSKY, out=RD_FRMKARNOFSKY_3);

data kar301_01;
	set RD_FRMKARNOFSKY_1;
	qsdt=ITMKARNOFSKYDT_DTS;
	%formatDate(ITMKARNOFSKYDT_DTS); %informatDate(DOV);
run;
data kar302_01;
	set RD_FRMKARNOFSKY_2;
	qsdt=ITMKARNOFSKYDT_DTS;
	%formatDate(ITMKARNOFSKYDT_DTS); %informatDate(DOV);
run;

data kar0102;
	set kar301_01 kar302_01;
if ITMKARNOFSKYSCORE ^='';
run;

proc sort data=kar0102 out=s_kar0102; by SUBJECTNUMBERSTR DOV A_DOV; run;

data kar0102_01;
	set s_kar0102;
	by SUBJECTNUMBERSTR DOV A_DOV;
	if last.SUBJECTNUMBERSTR;
run;

data kar303_01;
	set RD_FRMKARNOFSKY_3;
	qsdt=ITMKARNOFSKYDT_DTS;
	%formatDate(ITMKARNOFSKYDT_DTS); %informatDate(DOV);
run;


*****************Get the subjects from both in 303,(301+302)****************;
proc sort data=kar303_01 out=s_kar303_01(keep=SUBJECTNUMBERSTR) nodupkey; by SUBJECTNUMBERSTR; run;
proc sql;
	create table kar_01 as
	select a.* 
	from kar0102_01 as a inner join s_kar303_01 as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
	;
quit;

data kar_02;
	set kar_01;
	visitnum=-5;
	VISITMNEMONIC="Wk-1"||'!{super [2]}';
run;

data kar_03;
	set kar_02 kar303_01;
*-> Modify Variable Label;
	attrib
	ITMKARNOFSKYPERF       		label='Date Performed' 
	ITMKARNOFSKYSCORE      		label='Karnofsky Score' 
	A_DOV						label='Visit Date'
	;

if ITMKARNOFSKYDT_DTS^='' then ITMKARNOFSKYPERF = ITMKARNOFSKYDT_DTS;
else ITMKARNOFSKYPERF =ITMKARNOFSKYPERF;

keep SUBJECTNUMBERSTR visitnum VISITMNEMONIC dov A_DOV  ITMKARNOFSKYPERF ITMKARNOFSKYSCORE;

run;

proc sort data= kar_03 out=s_kar_03;by SUBJECTNUMBERSTR visitnum VISITMNEMONIC dov A_DOV; run;

data kar_04;
	length vnum $100 VISITMNEMONIC $400;
	set s_kar_03;
	format VISITMNEMONIC $200.;
	vnum='v_'||strip(put(VISITNUM*10,best.));
	if int(VISITNUM)^=VISITNUM then vnum=strip(vnum)||'_D';
	if index(VISITMNEMONIC,'UNS')>0 then VISITMNEMONIC='Unscheduled';
	VISITMNEMONIC=strip(VISITMNEMONIC)||'#'||strip(A_DOV);
	rename VISITMNEMONIC=A_VISITMNEMONIC A_DOV=B_DOV ITMKARNOFSKYPERF=C_ITMKARNOFSKYPERF;
RUN;

proc transpose data=kar_04 out=t_kar_04; 
	by SUBJECTNUMBERSTR;
	id vnum;
	var A_VISITMNEMONIC C_ITMKARNOFSKYPERF ITMKARNOFSKYSCORE;
run;

data kar_05;
	set t_kar_04(rename=(_label_=qstest _name_=__name));
	label qstest='QSTEST';
	if __name='A_VISITMNEMONIC' then qstest='Label';
/*	if cmiss(v__10,v_10,v_40,v_80,v_120,v_121_D)=6 then v__50='';*/
run;

proc sort data=kar_05 out=s_kar_05; by SUBJECTNUMBERSTR __name;run;
	
%adjustVisitVarOrder(indata=s_kar_05,othvars=SUBJECTNUMBERSTR QSTEST);

data pdata.qs33(label='Karnofsky Score');
	retain SUBJECTNUMBERSTR QSTEST v__50 v__10 v_10 v_40 v_80 v_120 v_121_D;
	set s_kar_05;
run;
