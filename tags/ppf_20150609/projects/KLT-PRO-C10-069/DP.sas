%INCLUDE "_setup.sas";

*<DP--------------------------------------------------------------------------------------------------------;
data dp0;
set source.dp;
	%adjustvalue1;

	if DPSTAT ^='' then DPORRES=DPSTAT;
	if DPORRES='N' then DPORRES='No'; else if DPORRES='Y' then  DPORRES='Yes';
	keep SUBJID dptestcd DPTEST DPORRES VNUM A_VISIT;
run;

data dm0;
set source.dm;
keep SUBJID PSADTRES;
run;


proc sql;
	create table dp_sc as 
	select a.*,b.PSADTRES
	from (select * from dp0) as a
			left join 
          (select * from DM0) as b
	on a.subjid=b.subjid;
quit;

proc sort data =dp_sc out=s_dp_sc; by subjid DPTEST VNUM; run;

proc transpose data=s_dp_sc out=t_dp_sc;
by subjid DPTEST PSADTRES;
id VNUM;
var A_VISIT DPORRES; 
run;

data dp1;
	set t_dp_sc;
	if _name_="A_VISIT" then dptest='A';
run;

proc sort data=dp1 out=s_dp1 nodupkey;  by subjid DPTEST;run;

data dp2;
length __label $256;
set s_dp1;
__label="Disease Progression "||"^{style [foreground=&norangecolor](Baseline PSADT:"||strip(PSADTRES)||")"||"}";
run;

%adjustVisitVarOrder(indata=dp2,othvars=subjid DPTEST  __label);

data pdata.dp(label='Disease Progression');
	set dp2;
run;

