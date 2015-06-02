
%include '_setup.sas';

*<VSFU----------------------------------------------------------------------------------------;
data VSFU;
	set source.RD_FRMFOLLOW;
	%adjustvalue(dsetlabel=Follow-up Period);
	%informatDate(DOV);
	label
		A_DOV='Visit Date'
		WEIGHT='Body weight#<kg>'
	;
	%char(var=ITMFOLLOWWEIGHT,newvar=WEIGHT);
run;
proc sort data = VSFU;by SUBJECTNUMBERSTR;run;
data pdata.VSFU50(label='Follow-up Period');
	retain &GlobalVars1 WEIGHT;
	keep &GlobalVars1 WEIGHT;
	set VSFU;
run;
