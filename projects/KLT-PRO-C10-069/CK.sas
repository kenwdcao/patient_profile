%INCLUDE "_setup.sas";

*<CK--------------------------------------------------------------------------------------------------------;
data ck0;
	set source.ck;
	%adjustvalue1;
	attrib
	CKORRES_    label='Assessment Result in Original Units'   length=$20

	;

	*Ken on 2013/05/07:;
/*	if CKORRES='Y' then CKORRES_='Yes'; else if CKORRES='N' then CKORRES_='No';*/
	CKORRES_=CKORRES;
/*	if CKSTAT ^='' then CKORRES_=CKSTAT; */
	if CKSTAT ^='' then CKORRES_='ND';
	KEEP SUBJID CKSEQ CKTESTCD CKTEST CKORRES_ A_VISIT VNUM;
run;

proc sort data=ck0 out=s_ck0; by subjid cktest VNUM; run;

proc transpose data=s_ck0 out=t_ck0;
	by subjid cktest;
	id VNUM;
	var A_VISIT ckorres_;
run;

data ck1;
	set t_ck0;
	if _name_="A_VISIT" then cktest="A";
	run;

proc sort data=ck1 out=ck2 nodupkey; by SUBJID cktest; run;

%adjustVisitVarOrder(indata=ck2,othvars=SUBJID cktest);

data pdata.ck(label='MH / CM / AE Check');
	set ck2;
run;

