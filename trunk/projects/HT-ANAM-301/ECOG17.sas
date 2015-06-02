%include '_setup.sas';

*<ECOG----------------------------------------------------------------------------------------;
data ecog;
	set source.RD_FRMECOG;
	%adjustvalue(dsetlabel=ECOG Performance Scale);
	%informatDate(DOV);
	%formatDate(ITMECOGDT_DTS);
	label
		A_DOV='Visit Date'
		ITMECOGDT_DTS='Date performed'
		ITMECOGSCALE='ECOG Performance Scale'
	;
	a='';
run;

proc sort data=ecog; by SUBJECTNUMBERSTR __visitnum; run;

data pdata.ecog17(label='ECOG Performance Scale');
	retain &GlobalVars1 ITMECOGDT_DTS a ITMECOGSCALE;
	keep &GlobalVars1 ITMECOGDT_DTS a ITMECOGSCALE;
	set ecog;
run;
*------------------------------------------------------------------------------------------>;
