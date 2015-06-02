
%include '_setup.sas';

*<cm28--------------------------------------------------------------------------------------------------------;
%getdy(indata=source.RD_FRMCM_SCTCMENTRY_ACTIVE,outdata=RD_FRMCM_SCTCMENTRY_ACTIVE,vars=ITMCMSTARTDT_DTS);
%getdy(indata=RD_FRMCM_SCTCMENTRY_ACTIVE,outdata=RD_FRMCM,vars=ITMCMEND_DTS);


data cm0;
	set RD_FRMCM(rename=(ITEMSETIDX=__ITEMSETIDX ITMCMFREQ=_ITMCMFREQ ITMCMROUTE=_ITMCMROUTE));
	%adjustvalue(dsetlabel=Prior & Concomitant Medications);
/*	%formatDate(ITMCMEND_DTS); %formatDate(ITMCMSTARTDT_DTS);*/
	%informatDate(DOV);
*-> Modify Variable Label;
	attrib
	ITMCMEND_DTS_    length=$19   label='End Date*'
	ITMCMFREQ       	label='Frequency' 
	ITMCMROUTE      	label='Route' 
	ITMCMSTARTDT_DTS	label='Start Date*'
	A_DOV				label='Visit Date'
	;

	%concatSPE(var=_ITMCMFREQ, spe=ITMCMFREQOTH, newvar=ITMCMFREQ);
	%concatSPE(var=_ITMCMROUTE, spe=ITMCMROUTEOTH, newvar=ITMCMROUTE);
	%ENRF(ongo=ITMCMENDDT,stopdate=ITMCMEND_DTS, newvar=ITMCMEND_DTS_);
run;

data da;
	length firstdt 8;
	set source.RD_FRMDRUG_ACTIVE(WHERE=(ITMDRUGFIRSTDOSEDT^=.));
	%formatDate(ITMDRUGFIRSTDOSEDT_DTS);
	firstdt=input(ITMDRUGFIRSTDOSEDT_DTS,date9.);
	keep SUBJECTNUMBERSTR ITMDRUGFIRSTDOSEDT_DTS firstdt;
run;

proc sort data=da out=da_ nodupkey; by SUBJECTNUMBERSTR firstdt; run;

data da1_;
	length stdtc $19;
	set da_;
	by SUBJECTNUMBERSTR firstdt;
	retain stdtc;
	if first.SUBJECTNUMBERSTR then stdtc=ITMDRUGFIRSTDOSEDT_DTS;
	else stdtc=stdtc;
	if first.SUBJECTNUMBERSTR;
run;

proc sql;
	create table cm_stdt as
	select a.*,b.stdtc
	from(select *  from cm0) as a
		left join
		(select * from da1_) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR;
quit;

data cm2;
	length __label $300 __sortkey $200;
	set cm_stdt;
	if stdtc^='' then do; __label="Prior & Concomitant Medications ^{style [foreground=&norangecolor](First Dose Date: "||strip(stdtc)||")}"
||"^{newline 2}^{style[fontsize=7pt foreground=green] *: (DY) is calculated as: Date - First Dose Date + 1 if Date is on or after First Dose Date;"
||" Date - First Dose Date if Date precedes First Dose Date}"; end;
	else do;__label="Prior & Concomitant Medications "||"^{style [foreground=&norangecolor](First Dose Date: NA)"||"}"; end;

	__sortkey=lowcase(strip(ITMCMMED));

run;

proc sort data=cm2; by SUBJECTNUMBERSTR ITMCMSTARTDT_DTR __sortkey; run;

data pdata.cm28(label='Prior & Concomitant Medications');
	retain  &globalvars3 __ITEMSETIDX __label ITMCMMED ITMCMREASON ITMCMSTARTDT_DTS ITMCMEND_DTS_ ITMCMDOSE ITMCMUNITS ITMCMROUTE ITMCMFREQ;
	keep    &globalvars3 __ITEMSETIDX __label ITMCMMED ITMCMREASON ITMCMSTARTDT_DTS ITMCMEND_DTS_ ITMCMDOSE ITMCMUNITS ITMCMROUTE ITMCMFREQ;
	set cm2;
run;
