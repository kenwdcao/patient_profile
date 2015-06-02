%INCLUDE "_setup.sas";

*<DA--------------------------------------------------------------------------------------------------------;

data da0;
set source.da;
	%adjustvalue;

	if DASTAT ^='' then DAORRES="ND";
	if DAORRES ='Y' then DAORRES='Yes'; else if DAORRES='N' then DAORRES='No';
run;

data da01;
	set da0;
	keep subjid A_VISIT DARESDTC;
	if DARESDTC ^='';
run;

data da02;
	length DAORRES_ $100;
	set da0;
	if DARESDTC^='' then DAORRES_=strip(DAORRES)||"*"||strip(DARESDTC);
		else DAORRES_=DAORRES;
	keep subjid A_VISIT DATESTCD DATEST DAORRES VNUM DAORRES_;
run;


proc sort data =da02 out=s_da02; by subjid A_VISIT DATEST; run;

/*proc transpose data=s_da0 out=pdata.t_da0;*/
/*	by subjid datest;*/
/*	id VNUM;*/
/*	var A_VISIT  DARESDTC DAORRES;*/
/*run;*/


proc transpose data=s_da02 out=t_da02;
	by subjid A_VISIT;
	id DATESTCD;
	idlabel DATEST;
	var DAORRES_;
run;

data da03_;
	length CAPSU $100 DISAMT_ $100 RETAMT_ $100 DSDTC $19 REDTC $19;
	label capsu='Dispensed/Returned#/Prescribed';
	label DSDTC='Dispensed Date';
	label REDTC='Returned Date';
	set t_da02;
	if index(DISAMT,"*")>0 then do; 
		DISAMT_=scan(DISAMT,1,"*");
		DSDTC=scan(DISAMT,2,"*"); end;
		else if index(DISAMT,"*")=0 then do; 
			DISAMT_=strip(DISAMT);
			DSDTC=''; end;
	if index(RETAMT,"*")>0 then do; 
		RETAMT_=scan(RETAMT,1,"*");
		REDTC=scan(RETAMT,2,"*"); end;
		else if index(RETAMT,"*")=0 then do; 
		RETAMT_=strip(RETAMT);
		REDTC=''; end;

	if RETAMT_='' then 	CAPSU=strip(DISAMT_)||"/"||" "||"/"||strip(PRESAMT);
	else if RETAMT_ ^='' then CAPSU=strip(DISAMT_)||"/"||strip(RETAMT_)||"/"||strip(PRESAMT);
	if DISAMT_='' and RETAMT_='' and PRESAMT='' then CAPSU='';

	if visitnum=. then visitnum=100;
	__vnum=input(A_VISIT,VNUM.);

run;


proc sort data=da03_; by subjid __vnum; 
	attrib
/*	PRESAMT   label='No. of Capsules#Prescribed'*/
/*	RETAMT    label='No. of Capsules#Returned'*/
/*	DISAMT    label='No. of Capsules#Dispensed'*/
	LOTNUM    label='Lot No.'
	COMMENT   label='Record/Comment on missed doses or#any discrepancy in capsule counts'
	DOSEMOD   label='Was there a dose modification#since the last visit?'
	NEWREG    label='New Dose#Regimen'

	;

run;

data pdata.da(label='Drug Accountability');
    retain  subjid A_VISIT DSDTC  REDTC CAPSU COMP COMMENT  LOTNUM REGIMEN  DOSEMOD NEWREG ;
	keep  subjid A_VISIT DSDTC  REDTC CAPSU COMP COMMENT  LOTNUM REGIMEN  DOSEMOD NEWREG ;
	set da03_;
run;




