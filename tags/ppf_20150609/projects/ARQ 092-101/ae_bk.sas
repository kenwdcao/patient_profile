%include '_setup.sas';
**** Adverse Event ****;
proc format;
	value AEACN
      1 = 'None/Dose Not Changed'
      2 = 'Discontinued Permanently'
      3 = 'Reduced'
      4 = 'Temporarily Interrupted'
      5 = 'Temporarily Interrupted and Reduced'
      6 = 'N/A'
      . = " "
     ;
   value AEOUT
      1 = 'RECOVERED/RESOLVED'
      2 = 'RESOLVED/RESOLVED WITH SEQUELAE/RESIDUAL EFFECT(S) PRESENT'
      3 = 'NOT RECOVERED/NOT RESOLVED'
      4 = 'FATAL'
      5 = 'UNKNOWN'
      . = " "
     ;
run;
data ae1;
	length AEENDTC SAE CAUS AEACN AEOUT $100;
	set source.ae(rename=AEOUT=AEOUT_);
	%formatDate(AESTDTC);
	%formatDate(AEEMDDTC);
	format _all_;
	label 
		AEDESC='Event/Preferred Term'
		AESTDTC='Start Date'
		AEENDTC='Stop Date'
		SAE='Serious'
		CTC='CTCAE Grade'
		CAUS='Causality'
		AEACN='Action'
		AEOUT='Outcome'
	;
	if AEONGO=1 then AEENDTC='Ongoing';
		else AEENDTC=strip(AEEMDDTC);
	if AESAE=1 then SAE='Yes';
		else if AESAE=0 then SAE='No';
	CTC=strip(put(AENCI,best.));
	if AECAUS=1 then CAUS='Related';
		else if AECAUS=2 then CAUS='Not Related';
	AEACN=strip(put(AEACT,AEACN.));
	AEOUT=strip(put(AEOUT_,AEOUT.));
	keep SUBID ID AEDESC AESTDTC AEENDTC SAE CTC CAUS AEACN AEOUT;
run;
proc sort data=ae1;by SUBID AESTDTC AEDESC;run;
data pdata.ae(label='Adverse Event');
	retain SUBID AEDESC AESTDTC AEENDTC SAE CTC CAUS AEACN AEOUT __ID; 
	keep SUBID AEDESC AESTDTC AEENDTC SAE CTC CAUS AEACN AEOUT __ID;
	set ae1(rename=(ID=__ID));
run; 
