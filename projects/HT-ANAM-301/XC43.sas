%include '_setup.sas';

*<XC--------------------------------------------------------------------------------------------------------;
%getdy(indata=source.RD_FRMCHEMO_SCTCHEMOEN_ACTIVE,outdata=RD_FRMCHEMO_SCTCHEMOEN_ACTIVE,vars=ITMCHEMOSTARTDT_DTS);
%getdy(indata=RD_FRMCHEMO_SCTCHEMOEN_ACTIVE,outdata=RD_FRMCHEMO,vars=ITMCHEMOENDDT_DTS);
data xc0;
	set RD_FRMCHEMO(rename=(ITMCHEMOFREQ=_ITMCHEMOFREQ ITMCHEMOROUTE=_ITMCHEMOROUTE
ITEMSETIDX=__ITEMSETIDX));
	%adjustvalue(dsetlabel=Concomitant Chemotherapy/Immunotherapy);
/*	%formatDate(ITMCHEMOSTARTDT_DTS); %formatDate(ITMCHEMOENDDT_DTS); */
	%informatDate(DOV);
*-> Modify Variable Label;
attrib
	ITMCHEMOSTARTDT_DTS			label='Start Date*'
	ITMCHEMOENDDT_DTS_	 length=$19 	label='Stop Date*'
	ITMCHEMOTHERAPY_    length=$200        label='Therapy Name'
	ITMCHEMOROUTE				label='Route'
	ITMCHEMOFREQ				label='Frequency'
	A_DOV						label='Visit Date'
	; 
	if ITMCHEMOMAIN ^='' then ITMCHEMOTHERAPY_=strip(ITMCHEMOTHERAPY)||''||strip(ITMCHEMOMAIN);
	else if ITMCHEMOTHER ^='' then ITMCHEMOTHERAPY_=strip(ITMCHEMOTHERAPY)||''||strip(ITMCHEMOTHER);
	else if ITMCHEMOADJU ^='' then ITMCHEMOTHERAPY_=strip(ITMCHEMOTHERAPY)||''||strip(ITMCHEMOADJU);
	else ITMCHEMOTHERAPY_=ITMCHEMOTHERAPY;

	%concatSPE(var=_ITMCHEMOFREQ, spe=ITMCHEMOFREQOTH, newvar=ITMCHEMOFREQ);
	%concatSPE(var=_ITMCHEMOROUTE, spe=ITMCHEMOROUTEOTH, newvar=ITMCHEMOROUTE);
	%ENRF(ongo=ITMCHEMOEND,stopdate=ITMCHEMOENDDT_DTS, newvar=ITMCHEMOENDDT_DTS_);
run;

data xc02;
	length SUBJECTNUMBERSTR $20 fdosedt 8 __label $300 __sortkey $200;
	if _n_=1 then do;
		declare hash h (dataset:'pdata.firstdose');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('fdosedt');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, fdosedt);
	end;
	set xc0;
	rc=h.find();
		if fdosedt^=. then __label="Concomitant Chemotherapy/Immunotherapy ^{newline 2}^{style[fontsize=7pt foreground=green] *: (DY) is calculated as: Date - First Dose Date + 1 if Date is on or after First Dose Date;"
||" Date - First Dose Date if Date precedes First Dose Date}";
		else __label="Concomitant Chemotherapy/Immunotherapy";

	__sortkey=lowcase(strip(ITMCHEMOTHERAPY_));
run;

proc sort data=xc02; by SUBJECTNUMBERSTR ITMCHEMOSTARTDT __sortkey ;run;

data pdata.xc43(label='Concomitant Chemotherapy/Immunotherapy');
	retain  &globalvars3 __label __ITEMSETIDX ITMCHEMOTHERAPY_ ITMCHEMOSTARTDT_DTS ITMCHEMOENDDT_DTS_ ITMCHEMOSTARTDOSE ITMCHEMOENDDOSE ITMCHEMOUNITS ITMCHEMOROUTE
			ITMCHEMOFREQ;
	keep    &globalvars3 __label __ITEMSETIDX ITMCHEMOTHERAPY_ ITMCHEMOSTARTDT_DTS ITMCHEMOENDDT_DTS_ ITMCHEMOSTARTDOSE ITMCHEMOENDDOSE ITMCHEMOUNITS ITMCHEMOROUTE
			ITMCHEMOFREQ;
	set xc02;
run;
*----------------------------------------------------------------------------------------------------------->;
