%include '_setup.sas';

*<ZB--------------------------------------------------------------------------------------------------------;
%macro dtsn(dts=, perf=, newvar=);
	if &dts>'' then &newvar=&dts;
	else if &perf^='' then &newvar='Not Done';
%mend dtsn;

data zb0;
	set source.RD_FRMDXA(rename=(ITMDXARSNAENUM=_ITMDXARSNAENUM ITMDXAPERF=_ITMDXAPERF));
	%adjustvalue(dsetlabel=DXA body composition analysis);
	%formatDate(ITMDXADT_DTS); %informatDate(DOV);
*-> Modify Variable Label;
	attrib
	ITMDXAPERF 		label='Date of DXA scan'   length= $200
	A_DOV			label='Visit Date'
	;
	%dtsn(dts=ITMDXADT_DTS, perf=_ITMDXAPERF, newvar=ITMDXAPERF);
	ITMDXARSNAENUM=ifc(_ITMDXARSNAENUM=.,'',put(_ITMDXARSNAENUM,best.));

	if ITMDXADT_DTS ^='' then ITMDXAPERF=ITMDXADT_DTS;
	else if ITMDXARSN^='' and ITMDXARSNOTHSPC ^='' 
		then ITMDXAPERF=strip(scan(ITMDXARSN,1,','))||': '||strip(ITMDXARSNOTHSPC);
	else if ITMDXARSN^='' and ITMDXARSNMECHSPC ^='' 
		then ITMDXAPERF=strip(scan(ITMDXARSN,1,','))||': '||strip(ITMDXARSNMECHSPC);
	else if ITMDXARSN^='' and ITMDXARSNAENUM ^='' 
		then ITMDXAPERF=strip(scan(ITMDXARSN,1,','))||': '||strip(ITMDXARSNAENUM);
	else ITMDXAPERF=ITMDXARSN;

run;
proc sort data=zb0; by SUBJECTNUMBERSTR dov; run;

data pdata.zb27(label='DXA Body Composition Analysis');
	retain  &globalvars1 ITMDXAPERF;
	keep    &globalvars1 ITMDXAPERF;
	set zb0;
run;
*----------------------------------------------------------------------------------------------------------->;
