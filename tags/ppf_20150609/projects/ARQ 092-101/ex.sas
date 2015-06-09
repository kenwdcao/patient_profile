%include '_setup.sas';
**** Dosing ****;
proc format;
   value SDFREQ
      1 = 'QD'
      2 = 'BID'
      3 = 'QOD'
      4 = '5 of 7 Days'
      5 = '2 Weeks On, 1 Week Off'
      6 = '1 Week On, 1 Week Off'
	  7 = 'Once a Week'
      99 = 'Other'
      . = " "
   ;

   value SDABATE
      0 = 'No'
      1 = 'Yes'
      2 = 'N/A'
      . = " "
   ;
run;
data ex1;
	length FREQ EXDOSE REASON1 ABATE REAP REASON2 REFREQ REDOSE REDTC $200;
	set source.sd;
	%formatDate(SDSTDTC);
	%formatDate(SDENDDTC);
	%formatDate(SDRESUMC);
	format _all_;
	label 
		EXDOSE='Dose(mg)/Frequency'
		SDSTDTC='Start Date'
		REASON1='Was dosing stop a planned hold?'
		SDENDDTC='Stop Date'
		ABATE='Dechallenge'
		REAP='Rechallenge'
		REASON2='Was dosing reduction required?'
		REDOSE='Reduced Dose(mg)/Frequency'
		REDTC='Date Dosing Resumed/Reduced'
	;
	FREQ=strip(put(SDFREQ,SDFREQ.));
	if FREQ='Other' then FREQ='Other: '||strip(SDFREQSP);
	if SDDOSST^=. then EXDOSE=strip(put(SDDOSST,best.))||' / '||strip(FREQ);
	if SDHOLDYN=0 then do;
		if SDHDRN=1 and SDHDRNSP^='' then REASON1='No, Adverse Event: '||strip(SDHDRNSP);
		else if SDHDRN=1 and SDHDRNSP='' then REASON1='No, Adverse Event';
		else if SDHDRN=2 and SDHDRNSP^='' then REASON1='No, Investigator Decision: '||strip(SDHDRNSP);
		else if SDHDRN=2 and SDHDRNSP='' then REASON1='No, Investigator Decision';
		else if SDHDRN=99 and SDHDRNSP^='' then REASON1='No, Other: '||strip(SDHDRNSP);
		else if SDHDRN=99 and SDHDRNSP='' then REASON1='No, Other';
	end;
	else if SDHOLDYN=1 then do;
		REASON1='Yes';
	end;
	ABATE=strip(put(SDABATE,SDABATE.));
	REAP=strip(put(SDREAP,SDABATE.));
	if SDREDYN=1 then do;
		if SDRSN=1 and SDRSNSP^='' then REASON2='Yes, Adverse Event: '||strip(SDRSNSP);
		else if SDRSN=1 and SDRSNSP='' then REASON2='Yes, Adverse Event';
		else if SDRSN=2 and SDRSNSP^='' then REASON2='Yes, Investigator Decision: '||strip(SDRSNSP);
		else if SDRSN=2 and SDRSNSP='' then REASON2='Yes, Investigator Decision';
		else if SDRSN=99 and SDRSNSP^='' then REASON2='Yes, Other: '||strip(SDRSNSP);
		else if SDRSN=99 and SDRSNSP='' then REASON2='Yes, Other';
	end;
	else if SDREDYN=0 then do;
		REASON2='No';
	end;
	REFREQ=strip(put(SDRDFREQ,SDFREQ.));
	if REFREQ='Other' then REFREQ='Other: '||strip(SDRDFQSP);
	if SDRDDOS^=. then REDOSE=strip(put(SDRDDOS,best.))||' / '||strip(REFREQ);
	if SDRESUMC^='' then REDTC=strip(SDRESUMC);
		else if SDRESUMC='' and SDDC=1 then REDTC='NA - Drug Permanently Discontinued';
	keep SUBID ID SDSTDTC SDENDDTC EXDOSE REASON1 ABATE REAP REASON2 REDOSE REDTC;
run;
proc sort data=ex1;by SUBID SDSTDTC;run;
data pdata.ex(label='Dosing');
	retain SUBID SDSTDTC SDENDDTC EXDOSE REASON1 ABATE REAP REASON2 REDOSE REDTC __ID; 
	keep SUBID SDSTDTC SDENDDTC EXDOSE REASON1 ABATE REAP REASON2 REDOSE REDTC __ID;
	set ex1(rename=(ID=__ID));
run; 
