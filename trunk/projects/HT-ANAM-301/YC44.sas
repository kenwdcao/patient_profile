%include '_setup.sas';

*<YC--------------------------------------------------------------------------------------------------------;
%getdy(indata=source.RD_FRMPROC_SCTPROCENTR_ACTIVE,outdata=RD_FRMPROC_SCTPROCENTR_ACTIVE,vars=ITMPROCSTARTDT_DTS);
data yc0;
	set RD_FRMPROC_SCTPROCENTR_ACTIVE(rename=(ITEMSETIDX=__ITEMSETIDX));
	%adjustvalue(dsetlabel=Concomitant Procedures);
/*	%formatDate(ITMPROCSTARTDT_DTS); */
	%informatDate(DOV);
*-> Modify Variable Label;
attrib	
	ITMPROCSTARTDT_DTS			label='Start Date*'
	A_DOV						label='Visit Date'
	; 
run;

data yc02;
	length SUBJECTNUMBERSTR $20 fdosedt 8 __label $300 __sortkey $200;
	if _n_=1 then do;
		declare hash h (dataset:'pdata.firstdose');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('fdosedt');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, fdosedt);
	end;
	set yc0;
	rc=h.find();
		if fdosedt^=. then __label="Concomitant Procedures ^{newline 2}^{style[fontsize=7pt foreground=green] *: (DY) is calculated as: Date - First Dose Date + 1 if Date is on or after First Dose Date;"
||" Date - First Dose Date if Date precedes First Dose Date}";
		else __label="Concomitant Procedures";

	__sortkey=lowcase(strip(ITMPROCREC));

	if ITMPROCREC^='' and ITMPROCSTARTDT_DTS^='';
run;
proc sort data=yc02;by SUBJECTNUMBERSTR ITMPROCSTARTDT __sortkey;run;

data pdata.yc44(label='Concomitant Procedures');
	retain  &globalvars3 __label __ITEMSETIDX ITMPROCREC ITMPROCSTARTDT_DTS;
	keep    &globalvars3 __label __ITEMSETIDX ITMPROCREC ITMPROCSTARTDT_DTS;
	set yc02;
run;
*----------------------------------------------------------------------------------------------------------->;
