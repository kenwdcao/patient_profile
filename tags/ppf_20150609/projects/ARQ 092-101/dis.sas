%include '_setup.sas';
**** Reason for Treatment Discontinuation ****;
proc format;
    value $REASON
	'RSNAE' = 'Adverse Event/SAE'
	'RSNLTFU' = 'Lost to Follow-up'
	'RSNDETH' = 'Death'
	'RSNPV' = 'Protocol Violation'
	'RSNWC' = 'Withdrew Consent'
	'RSNREG' = 'Termination of Study By the Sponsor, FDA, or Other Regulatory Authorities'
	'RSNXRAY' = 'Radiographic Disease Progression'
	'RSNCD' = 'Clinical Disease Progression'
	'RSNPI' = 'Physician Decision'
	'RSNOTH' = 'Other'
    ;
run;
data sc1;
	length REASON_ $20;
	set source.sc;
	format _all_;
	array a(10) RSNAE RSNLTFU RSNDETH RSNPV RSNWC RSNREG RSNXRAY RSNCD RSNPI RSNOTH;
    do i=1 to 10;
	  if a(i)^=. then REASON_=strip(vname(a(i)));
    end;
run;
data sc2;
	length REASON AREASON1 AREASON2 $200;
	set sc1;
	%formatDate(RSNDODC);
	%formatDate(PGNRDTC);
	%formatDate(PGNCDTC);
	%formatDate(SCLDDTC);
	%formatDate(SCLVDTC );
	format _all_;
	label 
		REASON='Primary Reason'
		SCLDDTC='Date of Last Dose of Study Drug'
		SCLVDTC='Date of Subject’s Last Completed Study Visit'
		AREASON1='Additional Information 1'
		AREASON2='Additional Information 2'
	;
	REASON=strip(put(REASON_,$REASON.));
	if REASON_='RSNAE' then do;
	AREASON1='AE/SAE: '||strip(AESP);
	AREASON2='';
	end;
	else if REASON_='RSNDETH' then do;
	AREASON1='Cause of Death: '||strip(RSNCOD);
	AREASON2='Date of Death: '||strip(RSNDODC);
	end;
	else if REASON_='RSNXRAY' then do;
	AREASON1='Date of Radiographic Progression: '||strip(PGNRDTC);
	AREASON2='';
	end;
	else if REASON_='RSNCD' then do;
	AREASON1='Date of Clinical Progression: '||strip(PGNCDTC);
	AREASON2='';
	end;
	else if REASON_='RSNPI' then do;
	AREASON1='Physician Reason for Discontinuation: '||strip(RSNPISP);
	AREASON2='';
	end;
	else if REASON_='RSNOTH' then do;
	AREASON1='Other Discontinuation Reason: '||strip(RSNOTHSP);
	AREASON2='';
	end;
	keep SUBID REASON AREASON1 AREASON2 SCLVDTC SCLDDTC;
run;
proc sort data=sc2;by SUBID;run;
data pdata.dis(label='Reason for Treatment Discontinuation');
	retain SUBID SCLVDTC SCLDDTC REASON AREASON1 AREASON2; 
	keep SUBID SCLVDTC SCLDDTC REASON AREASON1 AREASON2;
	set sc2;
run; 
