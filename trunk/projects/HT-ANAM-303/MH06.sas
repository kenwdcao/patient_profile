
%include '_setup.sas';
*<MH----------------------------------------------------------------------------------------;
data mh0;
	set source.RD_FRMMH;
	%adjustvalue(dsetlabel=Medical History);
	%informatDate(DOV);
	label
		A_DOV='Visit Date'
		ITMMHRELCS='Were there any relevant clinically significant medical history conditions that were not reported in the previous study?'
	;
	keep &GlobalVars1 ITMMHRELCS;
run;
data mh1;
	length MHENDTC $25;
	set source.RD_FRMMH_SCTMHENTRY_ACTIVE;
	%adjustvalue(dsetlabel=Medical History);
	%informatDate(DOV);
	%formatDate(ITMMHENDDT_DTS);
	%formatDate(ITMMHSTARTDT_DTS);
	%ENRF1(ongo=ITMMHONG,stopdate=ENRF);
	label 
		ITMMHENDDT_DTS='End Date DTC'
		ITMMHSTARTDT_DTS='Start Date'
		ENRF='Ongoing'
		MHENDTC='End Date'
	;
	IF ENRF='Ongoing' THEN MHENDTC=ENRF;ELSE MHENDTC=ITMMHENDDT_DTS;
	ITMMHCOND=upcase(ITMMHCOND);
/*	if ITMMHENDDT_DTS^='' then MHENDTC=ITMMHENDDT_DTS;else MHENDTC=ENRF;*/
	keep &GlobalVars1 ITMMHCOND ITMMHSTARTDT_DTS MHENDTC ITEMSETIDX;
run;
proc sql;
	create table mhall as 
	select a.*,b.ITMMHCOND,b.ITMMHSTARTDT_DTS,b.MHENDTC,b.ITEMSETIDX
	from (select * from mh0) as a
			left join 
          (select * from mh1) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and  a.VISIT=b.VISIT and a.A_DOV=b.A_DOV 
	order by SUBJECTNUMBERSTR, ITEMSETIDX;
quit;
data pdata.mh06(label='Medical History Updates');
	retain &GlobalVars1 ITMMHCOND ITMMHSTARTDT_DTS MHENDTC __ITEMSETIDX; 
	keep &GlobalVars1 ITMMHCOND ITMMHSTARTDT_DTS MHENDTC __ITEMSETIDX;
	set mhall(rename=(ITEMSETIDX=__ITEMSETIDX));
	if ITMMHCOND^='';
run; 
