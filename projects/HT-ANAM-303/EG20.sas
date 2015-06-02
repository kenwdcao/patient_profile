
%include '_setup.sas';

*<EG--------------------------------------------------------------------------------------------------------;
%macro concatABN(var=, dts=, newvar=);
	if &var >'' and &dts>'' then &newvar=strip(scan(&var,1,','))||', '||'NCS'||': '||&dts;
	else if index(&var,',')>0 then &newvar=strip(scan(&var,1,','))||', '||'CS';
    else if &var >'' and &dts='' then &newvar=&var;
%mend concatABN;

data eg0;
	set source.RD_FRMECG(rename=(ITMECGPERF=_ITMECGPERF ITMECGOVEINT=_ITMECGOVEINT));
	%adjustvalue(dsetlabel=Abnormal 12-Lead ECG);
	%formatDate(ITMECGPERFDT_DTS); %informatDate(DOV);
*-> Modify Variable Label;
attrib
    ITMECGPERF          		label='Was a 12-Lead ECG performed?'
	ITMECGOVEINT           		label='Overall interpretation'
	A_DOV                       label='Visit Date'
	;

	%concatVAR(var1=ITMECGPERFDT_DTS, var2=_ITMECGPERF, newvar=ITMECGPERF);
	%concatABN(var=_ITMECGOVEINT, dts=ITMECGOVEINTSPC, newvar=ITMECGOVEINT);
run;

proc sort data=eg0; by SUBJECTNUMBERSTR __visitnum; run;

data pdata.eg20(label='Abnormal 12-Lead ECG');
	retain  &globalvars1 ITMECGPERF ITMECGOVEINT;
	keep    &globalvars1 ITMECGPERF ITMECGOVEINT;
	set eg0;
	if index(ITMECGOVEINT,'Abnormal')>0;
run;
