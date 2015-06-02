
%include '_setup.sas';

*<lbchem25--------------------------------------------------------------------------------------------------------;
%getVNUM(indata=source.RD_FRMCHEM_SCTCHEMOTH_ACTIVE, out=RD_FRMCHEM_SCTCHEMOTH_ACTIVE);
%getVNUM(indata=source.RD_FRMCHEMUNS_SCTCHEMO_ACTIVE, out=RD_FRMCHEMUNS_SCTCHEMO_ACTIVE);

data chemoth;
	length OTHRESULT $400;
	set RD_FRMCHEM_SCTCHEMOTH_ACTIVE RD_FRMCHEMUNS_SCTCHEMO_ACTIVE;
	%adjustvalue1(dsetlabel=Chemistry-Local:Other Chemistry Test);
	%informatDate(DOV);
	attrib	
	ITMCHEMOTHRESULT_			label='Results'
	ITMCHEMOTHSPECTEST          label='Specify test'
	ITMCHEMOTHUNIT				label='Units'
	A_DOV						label='Visit Date'
	;

	ITMCHEMOTHRESULT_=ifc(ITMCHEMOTHRESULT=.,'',put(ITMCHEMOTHRESULT,best.));
	if ITMCHEMOTHUNITSPEC ^='' then ITMCHEMOTHUNIT=ITMCHEMOTHUNITSPEC;
	else ITMCHEMOTHUNIT=ITMCHEMOTHUNIT;

	%notInLowHigh(orres=ITMCHEMOTHRESULT_,low=ITMCHEMOTHLOW,high=ITMCHEMOTHHIGH,stresc=OTHRESULT);
	OTHRESULT=ifc(ITMCHEMOTHRESULT=.,'@',strip(OTHRESULT));
	if strip(ITMCHEMOTHSPECTEST)='urea test' or strip(ITMCHEMOTHSPECTEST)='urea' or strip(ITMCHEMOTHSPECTEST)='Urea'
		or strip(ITMCHEMOTHSPECTEST)='UREA' then ITMCHEMOTHSPECTEST='Urea';
		else ITMCHEMOTHSPECTEST=ITMCHEMOTHSPECTEST;
	if ITMCHEMOTHSPECTEST ^='';

	/*keep SUBJECTNUMBERSTR ITEMSETIDX ITMCHEMOTHSPECTEST  ITMCHEMOTHLOW ITMCHEMOTHHIGH OTHRESULT ITMCHEMOTHUNIT DOV  A_DOV VISITNUM VISITMNEMONIC;*/
run;

%macro lb(raw=,out=);
%getVNUM(indata=&raw..RD_FRMCHEM_SCTCHEMOTH_ACTIVE, out=RD_FRMCHEM_SCTCHEMOTH_ACTIVE);
%getVNUM(indata=&raw..RD_FRMCHEMUNS_SCTCHEMO_ACTIVE, out=RD_FRMCHEMUNS_SCTCHEMO_ACTIVE);

data R_chemoth_1;
	length OTHRESULT $400;
	set RD_FRMCHEM_SCTCHEMOTH_ACTIVE RD_FRMCHEMUNS_SCTCHEMO_ACTIVE;
	%informatDate(DOV);
	attrib	
	ITMCHEMOTHRESULT_			label='Results'
	ITMCHEMOTHSPECTEST          label='Specify test'
	ITMCHEMOTHUNIT				label='Units'
	A_DOV						label='Visit Date'
	;


	ITMCHEMOTHRESULT_=ifc(ITMCHEMOTHRESULT=.,'',put(ITMCHEMOTHRESULT,best.));
	if ITMCHEMOTHUNITSPEC ^='' then ITMCHEMOTHUNIT=ITMCHEMOTHUNITSPEC;
	else ITMCHEMOTHUNIT=ITMCHEMOTHUNIT;

	%notInLowHigh(orres=ITMCHEMOTHRESULT_,low=ITMCHEMOTHLOW,high=ITMCHEMOTHHIGH,stresc=OTHRESULT);
	OTHRESULT=ifc(ITMCHEMOTHRESULT=.,'@',strip(OTHRESULT));
	if strip(ITMCHEMOTHSPECTEST)='urea test' or strip(ITMCHEMOTHSPECTEST)='urea' or strip(ITMCHEMOTHSPECTEST)='Urea'
		or strip(ITMCHEMOTHSPECTEST)='UREA' then ITMCHEMOTHSPECTEST='Urea';
		else ITMCHEMOTHSPECTEST=ITMCHEMOTHSPECTEST;
	visitnum=-2;
	visitmnemonic='Wk-1!{super [2]}';
	if ITMCHEMOTHSPECTEST ^='';
run;

proc sort data=R_chemoth_1;
	by SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST VISITORDER VISITIDX; 
run;

DATA chemoth_1_;
	SET R_chemoth_1(WHERE=(ITMCHEMOTHRESULT^=.));
	BY SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST;
	IF LAST.ITMCHEMOTHSPECTEST;
RUN;

proc sort data=chemoth out=subject(keep=SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST) nodupkey;by SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST;run;
proc sql;
	create table chemoth_1_1 AS
	select a.*
	from chemoth_1_ as a inner join subject as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR AND a.ITMCHEMOTHSPECTEST=b.ITMCHEMOTHSPECTEST
	;
quit;
*-------- Get most lbdtc--------->;
proc sql;
	create table DTC as
	select *, count(A_DOV) as n
	from chemoth_1_1
	group by SUBJECTNUMBERSTR, A_DOV
	;
quit;
proc sort data=DTC out=DTC1 nodupkey;by SUBJECTNUMBERSTR A_DOV n;run;
proc sort data=DTC1 ;by SUBJECTNUMBERSTR n;run;
data DTC2;
	set DTC1;
	by SUBJECTNUMBERSTR;
	keep SUBJECTNUMBERSTR A_DOV;
	if last.SUBJECTNUMBERSTR;
run;
data &out;
	length SUBJECTNUMBERSTR $20  A_DOV $430;
	if _n_=1 then do;
		declare hash h (dataset :'DTC2');
		rc=h.defineKey ('SUBJECTNUMBERSTR');
		rc=h.defineData ('A_DOV');
		rc=h.defineDone ();
		call missing (SUBJECTNUMBERSTR,A_DOV);
	end;
	set chemoth_1_1(rename=(A_DOV=A_DOV_));
	rc=h.find();
	if A_DOV^=A_DOV_ then A_DOV_=A_DOV_;else A_DOV_='';
	drop rc VISITORDER  VISITIDX;
run;
%mend lb;
%lb(raw=R301,out=lb_301);
%lb(raw=R302,out=lb_302);
data chemoth01;
	set chemoth lb_301 lb_302;
run;

proc sql;
	create table unit as
	select *, count(ITMCHEMOTHUNIT) as n
	from chemoth01
	group by SUBJECTNUMBERSTR, ITMCHEMOTHSPECTEST, ITMCHEMOTHUNIT
	;
quit;

proc sort data=unit out=unit1 nodupkey; by SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST ITMCHEMOTHUNIT n;run;

proc sort data=unit1; by SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST n;run;

data unit_;
	set unit1(rename=(ITMCHEMOTHUNIT=lbstresu));
	by SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST;
	keep SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST lbstresu;
	if last.ITMCHEMOTHSPECTEST;
run;

proc sql;
	 create table CHEMOTH_1 as
	 select a.*,b.lbstresu
	 from (select * from chemoth01) as a
	    left join
	    (select * from unit_) as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR and a.ITMCHEMOTHSPECTEST = b.ITMCHEMOTHSPECTEST;
quit;

data CHEMOTH_2;
	length TESTOTH $100;
	set CHEMOTH_1;
	if lbstresu^='' then TESTOTH=strip(ITMCHEMOTHSPECTEST)||' <'||strip(lbstresu)||'>';
		else TESTOTH=strip(ITMCHEMOTHSPECTEST);
	if ITMCHEMOTHUNIT=lbstresu then OTHRESULT=OTHRESULT; 	
 	else if ITMCHEMOTHUNIT^=lbstresu then OTHRESULT=strip(OTHRESULT)||' '||strip(ITMCHEMOTHUNIT);
	if __LOW^=. or __HIGH^=. then OTHRESULT="!{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(OTHRESULT)||' *}';
	if A_DOV_^='' then OTHRESULT=strip(OTHRESULT)||' ('||strip(A_DOV_)||')';
run;


proc sort data=CHEMOTH_2 out=S_CHEMOTH_2; by SUBJECTNUMBERSTR TESTOTH ITEMSETIDX  VISITMNEMONIC DOV  A_DOV VISITNUM; run;

data s_chemoth02;
	length vnum $100 A_VISITMNEMONIC $400;
	set S_CHEMOTH_2(rename=(A_DOV=B_DOV));
	vnum='v_'||strip(put(VISITNUM*10,best.));
	if int(VISITNUM)^=VISITNUM then vnum=strip(vnum)||'_D';
	if index(VISITMNEMONIC,'UNS')>0 then VISITMNEMONIC='Unscheduled';
	A_VISITMNEMONIC=strip(VISITMNEMONIC)||'#'||strip(B_DOV);
	;
RUN;

PROC SORT DATA=s_chemoth02 out=s_chemoth02_ nodupkey;by SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST A_VISITMNEMONIC ;run;
proc transpose data=s_chemoth02_ out=s_chemoth02_1;
	by SUBJECTNUMBERSTR TESTOTH;
	id Vnum;
	var A_VISITMNEMONIC;
RUN;
proc transpose data=s_chemoth02 out=t_chemoth02;
	by SUBJECTNUMBERSTR  TESTOTH;
	id Vnum;
	var OTHRESULT;
RUN;
data s_chemoth02_1;
	set s_chemoth02_1;
	format v_: $200.;
run;
data t_chemothall;
	set  t_chemoth02 s_chemoth02_1(drop= _NAME_ );
run;

data chemoth03;
	length __NAME $20;
	set t_chemothall(rename=(_NAME_=__NAME));
	if __NAME^='OTHRESULT' then do;__NAME='A_VISITMNEMONIC';testoth='Label';
/*		if __NAME='B_DOV' then testoth='Visit Date';*/
/*		if __NAME='A_VISITMNEMONIC' then testoth='Label';*/
	end;
run;

proc sort data=chemoth03; by SUBJECTNUMBERSTR  __NAME  TESTOTH ; run;

data flagoth;
	length flag1-flag50 $200;
	set chemoth03;
	by SUBJECTNUMBERSTR __NAME  TESTOTH;
	retain flag1-flag50;
	array _num{*} v_:;
	array flag{50} flag1-flag50;
	do i=1 to dim(_num);
	if first.SUBJECTNUMBERSTR then flag[i]=_num[i];
	else if _num[i]^='' then flag[i]=_num[i];
	else flag[i]=flag[i];
	if __NAME='A_VISITMNEMONIC' then _num[i]=flag[i];
	if __NAME='OTHRESULT' and flag[i]^='' then do;
	if _num[i]='' then _num[i]='N/A';
		else if strip(_num[i])='@' then _num[i]='';
			else _num[i]=_num[i];
	end;
	end;
	if last.TESTOTH;
run;

proc sort data=flagoth out=s_chemoth03_; by SUBJECTNUMBERSTR  __NAME  TESTOTH ; run;

%adjustVisitVarOrder(indata=s_chemoth03_,othvars=SUBJECTNUMBERSTR TESTOTH);
data pdata.lbchem25(label='Chemistry-Local:Other Chemistry Test');
	set s_chemoth03_;
run;

data pdata.chemothidx;
	length TEST1 LOW HIGH LBCAT LAB unit $200;
	set chemoth01(where=(__LOW^=. or __HIGH^=.) rename=(VISITMNEMONIC=A_VISITMNEMONIC));
	label
		LBCAT='Category'
		TEST1='Item'
		LAB='Local Laboratory Used'
		LOW='Lower Limit'
		HIGH='Upper Limit'
		A_VISITMNEMONIC='Visit'
		unit='Unit'
	;
	LBCAT='Serum Chemistry';
	TEST1=strip(ITMCHEMOTHSPECTEST);
	unit=strip(ITMCHEMOTHUNIT);
	LOW=strip(ITMCHEMOTHLOW);
	HIGH=strip(ITMCHEMOTHHIGH);
	LAB='CRF'; 
	keep SUBJECTNUMBERSTR LBCAT TEST1 LAB LOW HIGH A_VISITMNEMONIC unit;
run;

