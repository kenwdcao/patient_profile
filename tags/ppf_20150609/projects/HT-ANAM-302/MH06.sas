
%include '_setup.sas';
*<MH----------------------------------------------------------------------------------------;
data mh0;
	set source.RD_FRMMH;
	%adjustvalue(dsetlabel=Medical History);
	%informatDate(DOV);
	%concatoth(var=ITMMHKRAS,oth=ITMMHKRASYES,newvar=KRAS);
	%concatoth(var=ITMMHEML4,oth=ITMMHEML4YES,newvar=EML4);
	label
		A_DOV='Visit Date'
		KRAS='KRAS available?'
		EGFR='EGFR available?'
		EGFR1='IHC status'
		EGFR2='Mutational status'
		EML4='EML4-ALK available?'
		ITMMHMOLMARK='Other molecular markers of note'
		ITMMHRELCS='Any relevant, clinically significant MH?'
	;
	EGFR=strip(ITMMHEGFR);
	EGFR1=coalescec(ITMMHIHC_CITM0,ITMMHIHC_CITM1PLUS,ITMMHIHC_CITM2PLUS,ITMMHIHC_CITM3PLUS,ITMMHIHC_CITMNEGATIVE,ITMMHIHC_CITMPOSITIVE);
	if coalescec(ITMMHMUT_CITMMUTATED,ITMMHMUT_CITMNOTMUTATED,ITMMHMUT_ITMMHMUTOTH)='Other, specify' then EGFR2_='Other Mutation';
		else EGFR2_=coalescec(ITMMHMUT_CITMMUTATED,ITMMHMUT_CITMNOTMUTATED,ITMMHMUT_ITMMHMUTOTH);
	%concatoth(var=EGFR2_,oth=ITMMHMUTOTH,newvar=EGFR2);
	keep &GlobalVars1 KRAS EGFR EGFR1 EGFR2 EML4 ITMMHMOLMARK ITMMHRELCS;

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
/*	if ITMMHENDDT_DTS^='' then MHENDTC=ITMMHENDDT_DTS;else MHENDTC=ENRF;*/
	mhterm=upcase(ITMMHCOND);
	keep &GlobalVars1 ITMMHCOND ITMMHSTARTDT_DTS MHENDTC ITEMSETIDX ITMMHSTARTDT_DTR mhterm;
run;
proc sql;
	create table mhall as 
	select a.*,b.ITMMHCOND,b.ITMMHSTARTDT_DTS,b.MHENDTC,b.ITEMSETIDX,b.ITMMHSTARTDT_DTR,b.mhterm
	from (select * from mh0) as a
			left join 
          (select * from mh1) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and  a.VISIT=b.VISIT and a.A_DOV=b.A_DOV 
	order by SUBJECTNUMBERSTR, ITEMSETIDX;
quit;
proc sort data=mhall;by SUBJECTNUMBERSTR ITMMHSTARTDT_DTR mhterm;run;
data pdata.mh06(label='Medical History');
/*	retain &GlobalVars1 KRAS EGFR EGFR1 EGFR2 EML4 ITMMHMOLMARK ITMMHRELCS ITMMHCOND ITMMHSTARTDT_DTR MHENDTC __ITEMSETIDX; */
/*	keep &GlobalVars1 KRAS EGFR EGFR1 EGFR2 EML4 ITMMHMOLMARK ITMMHRELCS ITMMHCOND ITMMHSTARTDT_DTR MHENDTC __ITEMSETIDX;*/
	retain &GlobalVars1 ITMMHCOND ITMMHSTARTDT_DTS MHENDTC __ITEMSETIDX; 
	keep &GlobalVars1 ITMMHCOND ITMMHSTARTDT_DTS MHENDTC __ITEMSETIDX;
	set mhall(where=(ITMMHRELCS='Yes') rename=(ITEMSETIDX=__ITEMSETIDX));
/*	if __ITEMSETIDX^=1 then do ;KRAS=''; EGFR=''; EGFR1=''; EGFR2=''; EML4=''; ITMMHMOLMARK=''; ITMMHRELCS='';end;*/
run; 
