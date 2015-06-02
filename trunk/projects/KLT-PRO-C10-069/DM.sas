
/*
	Ken on 2013/05/08: Subject is screen failure if value of IEORRES of IE.IETESTCD.ELIG02 is N.
					   Add First Dispense Date.
						
*/

%INCLUDE "_setup.sas";

*<DM--------------------------------------------------------------------------------------------------------;
data dm0;
set source.dm;
	attrib
	subjid       label='Unique Subject Identifier'
	__sex        label='Sex' 
	age          label='Age'
	RFSTDTC      label='Reference#Start Date'
	RFENDTC      label='Reference#End Date'
	ARM          label='Arm'
	PKSUBYN_     label='Participating in#the PK sub-study'  length=$6
	PSADT        label='Baseline PSA#Date'
	PSADTRES     label='Baseline PSADT#(months)'
	BRTHDTC      label='Date of#Birth'
	;
	
	if ETHNIC="NOT HISPANIC OR LATINO" then ETHNIC ='Not Hispanic or Latino';
	if raceo ^='' then race=STRIP(put(race,$race.))||": "||strip(raceo);
		else race=put(race,$race.);
	if sex='MALE' then __sex='M'; else if sex='FEMALE' then __sex='F';

	if RFSTDTC ^='' and length(compress(RFSTDTC)) = 10 and BRTHDTC ^='' and length(compress(BRTHDTC))= 10
		then age_=int((input(RFSTDTC, yymmdd10.) - input(BRTHDTC, yymmdd10.) + 1)/365.25);
	age=ifc(age_=., '',put(age_,best.));
	if AGE='' then AGE='NA';
	__AGE=strip(AGE)||'^{super [1]}';
	PKSUBYN_=put(PKSUBYN,$yn.);
run;

data ds0;
	set source.ds;
	if dsterm ^='';
run;

data ds01 ds02;
set ds0;
if EPOCH='TREATMENT PHASE' then output ds01; 
	else output ds02;
run;

/*proc sort data=ds0 out= s_ds0; by subjid DSSEQ; run;*/
/**/
/*data ds01;*/
/*	set s_ds0;*/
/*	by subjid DSSEQ;*/
/*	if last.subjid;*/
/*run;*/

proc sql;
	create table dm01 as 
	select a.*,b.DSCOMPYN, b.DSTERM,b.DSSTDTC,b.EPOCH
	from (select * from dm0) as a
			left join 
          (select * from ds01) as b
	on a.subjid=b.subjid;
quit;

data dm01_;
	length  __stat $100;
	set dm01;
	if DSCOMPYN='Y' then __stat='Completed: '||strip(DSSTDTC);
		else if DSCOMPYN='N' then __stat=propcase(strip(DSTERM))||': '||strip(DSSTDTC);
run;

data dm01_1 dm01_2;
set dm01_;
if __stat^='' then output dm01_1;
	else output dm01_2;
run; 

proc sql;
	create table dm02 as 
	select a.*,b.DSCOMPYN, b.DSTERM,b.DSSTDTC,b.EPOCH
	from (select * from dm01_2(drop=DSCOMPYN DSTERM DSSTDTC EPOCH)) as a
			left join 
          (select * from ds02) as b
	on a.subjid=b.subjid;
quit;

data dm03;
set dm02;
__stat="Ongoing";
if dsterm='SUBJECT RANDOMIZED';
run;

data dm04;
set dm01_1 dm03;
run;

proc sql;
	create table dm05 as 
	select a.*,b.__stat
	from (select * from dm0) as a
			left join 
          (select * from dm04) as b
	on a.subjid=b.subjid;
quit;

data dm06;
set dm05;
if __stat='' then __stat="^{style [foreground=&abovecolor] Screen Failure }";
run;



*Ken on 2013/05/08;
data _scr;
	set source.ie;
	where ietestcd='ELIG02' and ieorres='N';
run;


*Ken on 2013/05/8:Add Firt Dispense Date:  Dispensed;
data _da0;
	set source.da;
	where datestcd ='DISAMT' and upcase(visit)='MONTH 0';
	keep subjid daresdtc;
run;

proc sort data=_da0; by subjid; run;

data dm06;
	merge dm06 _scr(in=a) _da0;
		by subjid;
	if a then __stat='^{style [foreground=red]Screen Failure}';
	length fdispdtc $200;
	fdispdtc=daresdtc;
	if fdispdtc='' then fdispdtc='NA';
	fdispdtc='First Drug Dispense Date: '||strip(fdispdtc);
run;


data dm_;
	length __title __title2 $200 ;
	set dm06;
	__title=strip(subjid)||' / '||strip(__SEX)||' / '||strip(__AGE)||' / '||strip(__STAT);
	__title2=fdispdtc;
run;

proc sort data=dm_ out=dm; by SUBJID;run;

data pdata.dm(label='Demographics');
    retain  SUBJID RFSTDTC RFENDTC BRTHDTC ETHNIC RACE ARM PSARES PSADT PSADTRES PKSUBYN_ __title __title2;
	keep  SUBJID RFSTDTC RFENDTC BRTHDTC ETHNIC RACE ARM PSARES PSADT PSADTRES PKSUBYN_ __title __title2;
	set dm;
run;
