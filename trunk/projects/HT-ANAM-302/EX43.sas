%include '_setup.sas';

data ex;
	length mednum $10 exstdtc exendtc $19 disnum retnum misnum $50 noncmp educmp $10;
	set source.rd_frmdrug_active;
	%formatDate(ITMDRUGFIRSTDOSEDT_DTS);
	%formatDate(ITMDRUGLASTDOSEDT_DTS);
	label
		mednum = 'Medication Number'
		exstdtc = 'First Dose Date'
		exendtc = 'Last Dose Date'
		disnum = 'Number of Tablets Dispensed'
		retnum = 'Number of Tablets Returned'
		misnum = 'Calculated Number of Dose Missed'
		noncmp = 'Miss Any Doses Due to Non-Compliance?'
		educmp = 'Educated Regarding Compliance?'

	;

	mednum=strip(ITMDRUGMEDNUM);
	if ITMDRUGFIRSTDOSEDT_DTS^='' then exstdtc=ITMDRUGFIRSTDOSEDT_DTS;
		else if ITMDRUGFIRSTDOSE='None taken' then exstdtc='None taken';

	if ITMDRUGLASTDOSEDT_DTS^='' then exendtc=ITMDRUGLASTDOSEDT_DTS;
		else if ITMDRUGLASTDOSE='None taken' then exendtc='None taken';

	if ITMDRUGDISPNUM^=. then disnum=strip(put(ITMDRUGDISPNUM,best.));
		else if ITMDRUGTABDISP='Not Dispensed' then disnum='Not Dispensed';

	if ITMDRUGRETNUM^=. then retnum=strip(put(ITMDRUGRETNUM,best.));
		else if ITMDRUGTABRET='Not Returned' then retnum='Not Returned';

	if ITMDRUGDOSEMISSCALC^=. then misnum=strip(put(ITMDRUGDOSEMISSCALC,best.));
	if ITMDRUGMISSDOSES='No' then noncmp='No';
		else if ITMDRUGMISSDOSES^='' then noncmp='Yes';
	educmp=strip(ITMDRUGEDUCMP);

/*	keep SUBJECTNUMBERSTR MEDNUM EXSTDTC EXENDTC DISNUM RETNUM MISNUM NONCMP EDUCMP;*/

run;
proc sort data=ex; by SUBJECTNUMBERSTR ITMDRUGFIRSTDOSEDT; run;

data pdata.ex43(label='Study Drug Accountability');
	retain SUBJECTNUMBERSTR MEDNUM EXSTDTC EXENDTC DISNUM RETNUM MISNUM NONCMP EDUCMP;
	keep SUBJECTNUMBERSTR MEDNUM EXSTDTC EXENDTC DISNUM RETNUM MISNUM NONCMP EDUCMP;
	set ex;
run;
