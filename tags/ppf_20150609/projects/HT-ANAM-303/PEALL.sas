
%include '_setup.sas';

*<PE--------------------------------------------------------------------------------------------------------;
data pe0;
	set source.RD_FRMPE(rename=(ITMPEPERF=_ITMPEPERF));
	%adjustvalue(dsetlabel=Abnormal Physical Examination);
	%formatDate(ITMPEPERFDT_DTS);  %informatDate(DOV);
*-> Modify Variable Label;
attrib	
	PEPERF 		label='Was a Physical Examination performed'
	ABNORMAL  length=$20 label='Abnormalities Present'
	A_DOV		label='Visit Date'
	;

%concatVAR(var1=ITMPEPERFDT_DTS, var2=_ITMPEPERF,newvar=PEPERF);

if index(ITMPEABNORMAL,',')>0 then ABNORMAL=scan(ITMPEABNORMAL,1,',')||', '||"see AE";
else ABNORMAL=ITMPEABNORMAL;

run;
proc sort data=pe0 out=pe3; by SUBJECTNUMBERSTR A_DOV; run;

data pe46;
	retain  &globalvars1 PEPERF ABNORMAL;
	keep    &globalvars1 PEPERF ABNORMAL;
	set pe3;
run;

data pdata.peall(label='Abnormal Physical Examination');
	retain  &GlobalVars1  PEPERF ABNORMAL ;
	keep    &GlobalVars1  PEPERF ABNORMAL ;
set pe46;
if ABNORMAL='Yes, see AE';
run;
