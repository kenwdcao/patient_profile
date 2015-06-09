%include '_setup.sas';
**** 30-Day Safety Follow-Up ****;
proc format;
   value FUCONTCT
      1 = 'Telephone Call'
      2 = 'Clinic Visit'
      99 = 'Other'
      . = " "
   ;

   value $TERM
	'FU1' = 'Was the 30-day safety follow-up visit done?'
	'CONTCT' = 'If Yes, Contact Method'
	'FUDTC' = 'Date of Safety Follow-Up'
	'FU2' = 'Were there any additional adverse events?'
	'FUAES' = 'If Yes, Record Adverse Event Term(s)'
	'FU3' = 'Were all previously ongoing treatment-related Adverse Events resolved?'
	'FUAEONGO' = 'If No, Record Adverse Event Term(s)'
	'FUAERSN' = 'If No, record reason the subject was not followed until all Adverse Events resolved'
	'FU4' = 'Has subject started another cancer treatment during the safety follow-up period?'
	'FUNEWDTC' = 'New Cancer Treatment Date'
	'FUNEWRX' = 'New Cancer Treatment'
   ;

   value $TERMID
	'FU1' = '1'
	'CONTCT' = '2'
	'FUDTC' = '3'
	'FU2' = '4'
	'FUAES' = '5'
	'FU3' = '6'
	'FUAEONGO' = '7'
	'FUAERSN' = '8'
	'FU4' = '9'
	'FUNEWDTC' = '10'
	'FUNEWRX' = '11'
	;

run;

data fu1;
	length FU1 CONTCT FU2 FU3 FU4 $200;
	set source.fu;
	format _all_;
	%formatDate(FUDTC);
	%formatDate(FUNEWDTC);
	if FUYN=1 then FU1='Yes';
		else if FUYN=0 then FU1='No: '||strip(FUYNSP);
	if FUCONTCT^=. then CONTCT=strip(put(FUCONTCT,FUCONTCT.));
	if CONTCT='Other' then CONTCT='Other: '||strip(FUCONTSP);
	if FUADDAE=1 then FU2='Yes';
		else if FUADDAE=0 then FU2='No';
	if FUAERES=1 then FU3='Yes';
		else if FUAERES=0 then FU3='No';
	if FUNEWYNT=1 then FU4='Yes';
		else if FUNEWYNT=0 then FU4='No';
	keep SUBID ID FU1 CONTCT FUDTC FU2 FUAES FU3 FUAEONGO FUAERSN FU4 FUNEWDTC FUNEWRX;
run;
proc sort data=fu1;by SUBID ID;run;
proc transpose data=fu1 out=fu2;
 	by SUBID ID; 
 	var FU1 CONTCT FUDTC FU2 FUAES FU3 FUAEONGO FUAERSN FU4 FUNEWDTC FUNEWRX; 
run;
proc sort data=fu2 out=fu3 nodupkey;by SUBID _NAME_ COL1;run;

data fu4;
	length TERM $200;
	set fu3;
	TERM=strip(put(_NAME_,$term.));
	RESPONSE=COL1;
	__TERMID=input(strip(put(_NAME_,$termid.)),best.);
	keep SUBID ID TERM RESPONSE __TERMID;
run;

proc sort data=fu4;by SUBID __TERMID ID;run;
data pdata.sfu(label='30-Day Safety Follow-Up');
	retain SUBID TERM RESPONSE __TERMID __ID; 
	keep SUBID TERM RESPONSE __TERMID __ID;
	set fu4(rename=ID=__ID);
run; 
