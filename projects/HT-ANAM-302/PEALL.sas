
%include '_setup.sas';

*<PE--------------------------------------------------------------------------------------------------------;
data pe0;
length ABNORMAL $20;
	set source.RD_FRMPE1(rename=(ITMPEPERF=_ITMPEPERF));
	%adjustvalue(dsetlabel=Abnormal Physical Examination);
	%informatDate(DOV);
	%formatDate(ITMPEPERFDT_DTS);
	label
		A_DOV='Visit Date'
		ITMPE1NONDOMHAND='Non-dominant hand'
		PEPERF='Was a Physical Examination performed?'
		ABNORMAL='Abnormalities Present'
	;

	%concatVAR(var1=ITMPEPERFDT_DTS, var2=_ITMPEPERF,newvar=PEPERF);

	if index(ITMPE1ABNORMAL,',')>0 then ABNORMAL=strip(scan(ITMPE1ABNORMAL,1,','));else ABNORMAL=ITMPE1ABNORMAL;
	keep &GlobalVars1 ITMPE1NONDOMHAND PEPERF ABNORMAL ITMPEPERFDT;
run;
data pe1;
	set source.rd_frmpe1_sctpe1ent_active;
	%adjustvalue(dsetlabel=Abnormal Physical Examination);
	%informatDate(DOV);
	label
		A_DOV='Visit Date'
		ITMPE1BODSYS='Body System'
	;
	keep &GlobalVars1  ITMPE1BODSYS ITMPE1SPECABN ITEMSETIDX;
run;
proc sql;
	create table pe as 
	select a.*,b.ITMPE1BODSYS,b.ITMPE1SPECABN,b.ITEMSETIDX
	from (select * from pe0) as a
			left join 
          (select * from pe1) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and  a.VISIT=b.VISIT and a.A_DOV=b.A_DOV 
	order by SUBJECTNUMBERSTR, ITEMSETIDX;
quit;
data pe18;
	retain &GlobalVars1 ITMPE1NONDOMHAND PEPERF ABNORMAL ITMPE1BODSYS ITMPE1SPECABN __ITEMSETIDX ITMPEPERFDT;
	keep &GlobalVars1 ITMPE1NONDOMHAND PEPERF ABNORMAL ITMPE1BODSYS ITMPE1SPECABN __ITEMSETIDX ITMPEPERFDT;
	set PE(rename=(ITEMSETIDX=__ITEMSETIDX));
run;

data pe2;
	set source.RD_FRMPE2(rename=(ITMPEPERF=_ITMPEPERF));
	%adjustvalue(dsetlabel=Abnormal Physical Examination);
	%formatDate(ITMPEPERFDT_DTS); %informatDate(DOV);
*-> Modify Variable Label;
attrib
	PEPERF       		label='Was a Physical Examination performed' 
	ABNORMAL  length=$20 label='Abnormalities Present'
	A_DOV				label='Visit Date'
	;
%concatVAR(var1=ITMPEPERFDT_DTS, var2=_ITMPEPERF,newvar=PEPERF);

if index(ITMPE2ABNORMAL,',')>0 then ABNORMAL=scan(ITMPE2ABNORMAL,1,',')||', '||"see MH";
else ABNORMAL=ITMPE2ABNORMAL;

run;

data pe34;
	retain  &globalvars1 PEPERF ABNORMAL ITMPEPERFDT;
	keep    &globalvars1 PEPERF ABNORMAL ITMPEPERFDT;
	set pe2;
run;

data pe3;
	set source.RD_FRMPE3(rename=(ITMPEPERF=_ITMPEPERF));
	%adjustvalue(dsetlabel=Abnormal Physical Examination);
	%formatDate(ITMPEPERFDT_DTS);  %informatDate(DOV);
*-> Modify Variable Label;
attrib	
	PEPERF 		label='Was a Physical Examination performed'
	ABNORMAL  length=$20 label='Abnormalities Present'
	A_DOV		label='Visit Date'
	;

%concatVAR(var1=ITMPEPERFDT_DTS, var2=_ITMPEPERF,newvar=PEPERF);

if index(ITMPE3ABNORMAL,',')>0 then ABNORMAL=scan(ITMPE3ABNORMAL,1,',')||', '||"see AE";
else ABNORMAL=ITMPE3ABNORMAL;

run;

data pe46;
	retain  &globalvars1 PEPERF ABNORMAL ITMPEPERFDT;
	keep    &globalvars1 PEPERF ABNORMAL ITMPEPERFDT;
	set pe3;
run;

data peall;
	set pe18 pe34 pe46;
	length __sortkey1 __sortkey2 $200;
	__sortkey1=lowcase(strip(ITMPE1BODSYS));
	__sortkey2=lowcase(strip(ITMPE1SPECABN));

run;
proc sort data=peall; by SUBJECTNUMBERSTR __visitnum ITMPEPERFDT __sortkey1 __sortkey2; run;

data pdata.peall(label='Abnormal Physical Examination');
	retain  &GlobalVars1 ITMPE1NONDOMHAND PEPERF ABNORMAL ITMPE1BODSYS ITMPE1SPECABN __ITEMSETIDX;
	keep    &GlobalVars1 ITMPE1NONDOMHAND PEPERF ABNORMAL ITMPE1BODSYS ITMPE1SPECABN __ITEMSETIDX;
set peall;
if ABNORMAL='Yes' or ABNORMAL='Yes, see MH' or ABNORMAL='Yes, see AE';
run;
