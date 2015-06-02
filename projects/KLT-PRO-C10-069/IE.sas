/*
	Program Name: IE.sas
		@Author: Ken Cao (yong.cao@q2bi.com)
		@Initial Date: 2013/05/07

	*********************************************
	For IE dataset of KLT study .
	*********************************************
*/

%include "_setup.sas";

*get informed consent signed date;
data infcon;
	set source.ds;
	where dsdecod='INFORMED CONSENT OBTAINED';
	keep subjid dsstdtc;
	rename dsstdtc = icdtc;
	label dsstdtc = 'Date Informed Consetn Signed';
run;
proc sort data=infcon; by subjid; run;

*tranpose other test than I/E critera into variables;
data ie0;
	set source.ie(rename=ieorres=ieorres_);
	where ietestcd not like 'EX%' and ietestcd not like 'IN%';
	length ieorres $20;
	ieorres=ieorres_;
	if ieorres='N' then ieorres='No';
	else if ieorres='Y' then ieorres='Yes';
run;

proc sort data=ie0; by subjid; run;
proc transpose data=ie0 out=t_ie0(drop=_name_);
	by subjid;
	id ietestcd;
	idlabel ietest;
	var ieorres;
run;

*wrap all I/E violation into signle variable;
data ie1;
	set source.ie;
	where ietestcd like 'EX%' or ietestcd like 'IN%';
	keep subjid ietestcd ietest; 
run;

proc sort data=ie1; by subjid ietestcd; run;

data ie2;
	set ie1;
		by subjid;
	length criterion $200;
	retain criterion;
	if first.subjid then criterion=ietest;
	else criterion=strip(criterion)||'^{newline}'||ietest;
	if last.subjid;
	keep subjid criterion;
	label criterion='Inclusion/Exclusion Criteria Not Met';
run;

*other variables;
proc sort data=source.ie out=ie3(keep=subjid reaswav wavdtc) nodupkey;
	by subjid descending reaswav wavdtc; 
run;

*for 01-007;
data ie3;
	set ie3;
		by subjid;
	if first.subjid;
run;

data ie4;
	merge infcon t_ie0 ie2 ie3;
		by subjid;
run;


*final dataset;
data pdata.ie;
	retain subjid icdtc elig01 criterion waiver waivnum reaswav wavdtc elig02 SPONSOR;
	keep subjid icdtc elig01 criterion waiver waivnum reaswav wavdtc elig02 SPONSOR;
	set ie4;
run;
