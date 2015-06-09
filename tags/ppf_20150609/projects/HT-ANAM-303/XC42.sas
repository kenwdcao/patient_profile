
%include '_setup.sas';

*<XC----------------------------------------------------------------------------------------;
%getdy(indata=source.RD_FRMRAD_SCTRADENTRY_ACTIVE,outdata=RD_FRMRAD_SCTRADENTRY_ACTIVE,vars=ITMRADSTARTDT_DTS);
%getdy(indata=RD_FRMRAD_SCTRADENTRY_ACTIVE,outdata=RD_FRMRAD,vars=ITMRADSTOPDT_DTS);

data xc1;
	set RD_FRMRAD(rename=(ITEMSETIDX=__ITEMSETIDX));
	%adjustvalue(dsetlabel=Concomitant Radiation Therapy);
/*	%formatDate(ITMRADSTARTDT_DTS); %formatDate(ITMRADSTOPDT_DTS); */
	%informatDate(DOV);
*-> Modify Variable Label;
attrib
	STDTC			label='Start Date*'
	ENDTC			label='Stop Date*'
	REGION          label='Target Field'
	A_DOV			label='Visit Date'
	TOTDOSE			label='Total Dose#<cGy>'
	;
	length REGION $200;

	STDTC=ITMRADSTARTDT_DTS;
	ENDTC=ITMRADSTOPDT_DTS;
	REGION=ITMRADTARGETFIELD;
	TOTDOSE=ITMRADTOTDOSE;
run;

data xc02;
	length SUBJECTNUMBERSTR $20 fdosedt 8 __label $300;
	if _n_=1 then do;
		declare hash h (dataset:'pdata.firstdose');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('fdosedt');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, fdosedt);
	end;
	set xc1;
	rc=h.find();
		if fdosedt^=. then __label="Concomitant Radiation Therapy !{newline 2}!{style[fontsize=7pt foreground=green] *: (DY) is calculated as: Date - First Dose Date+1 if Date is on or after First Dose Date;"
||" Date - First Dose Date if Date precedes First Dose Date}";
		else __label="Concomitant Radiation Therapy";
run;

/*proc sort data=xc02; by SUBJECTNUMBERSTR __ITEMSETIDX; run;*/
proc sort data=xc02; by SUBJECTNUMBERSTR ITMRADSTARTDT ITMRADSTOPDT; run;

data pdata.xc42(label='Concomitant Radiation Therapy');
	retain  &globalvars3 __label  __ITEMSETIDX REGION TOTDOSE STDTC ENDTC;
	keep    &globalvars3 __label  __ITEMSETIDX REGION TOTDOSE STDTC ENDTC;
	set xc02;
run;
