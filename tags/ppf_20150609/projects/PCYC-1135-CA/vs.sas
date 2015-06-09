/*********************************************************************
 Program Nmae: vs.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data vs1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE
	EDC_FORMLABEL=__EDC_FORMLABEL));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.vs;
	%subject;
	%visit2;

	** Assessment Date;
	length vsdtc $20;
	label vsdtc = 'Assessment Date';
	if VSDAT^=. then vsdtc=put(VSDAT,yymmdd10.);else vsdtc="";
	rc = h.find();
	%concatDY(vsdtc);
	drop VSDAT rc;

	** Assessment Date;
	length vstmc $20;
	label vstmc = 'Assessment Time';
	if VSTIM^=. then vstmc=put(VSTIM,time5.);else vstmc="";
	drop VSTIM;

	** result & unit;
	length RESULT $200;
	if VSND eq '' then do;
		if VSTEST in ('Body Temperature', 'Weight', 'Height') then RESULT = catx(' ', VSORRES, VSORRESU); else
			RESULT = strip( VSORRES);
	end; else
		if VSND ne '' then do;
			RESULT = 'ND';
		end; 

run;

proc sort data=vs1_1 out=vs_s; by SUBJECT VSDTC VSTMC VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE __EDC_FORMLABEL VSSEQ; run;

*Vital Signs*;
proc transpose data=vs_s(where=(__EDC_FORMLABEL='Vital Signs')) out=vs_t1; 
	by SUBJECT VSDTC VSTMC VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE __EDC_FORMLABEL VSSEQ;
	id VSTEST;
	var RESULT;
run;

*Vital Signs & Weight*;
proc transpose data=vs_s(where=(__EDC_FORMLABEL='Vital Signs & Weight')) out=vs_t2; 
	by SUBJECT VSDTC VSTMC VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE __EDC_FORMLABEL VSSEQ;
	id VSTEST;
	var RESULT;
run;

*Vital Signs & Weight/Height*;
proc transpose data=vs_s(where=(__EDC_FORMLABEL='Vital Signs & Weight/Height')) out=vs_t3; 
	by SUBJECT VSDTC VSTMC VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE __EDC_FORMLABEL VSSEQ;
	id VSTEST;
	var RESULT;
run;

data vs_t123;
	set vs_t:;
run;

proc sort data=vs_t123 out=preout; by SUBJECT VSDTC VSTMC VISIT2; run;

data pdata.vs(label='Vital Signs & Weight/Height');
    retain __EDC_TREENODEID __EDC_ENTRYDATE __EDC_FORMLABEL VSSEQ SUBJECT VISIT2 VSDTC VSTMC 
		BODY_TEMPERATURE HEART_RATE SYSTOLIC_BLOOD_PRESSURE DIASTOLIC_BLOOD_PRESSURE 
		RESPIRATORY_RATE WEIGHT HEIGHT BMI;
    keep __EDC_TREENODEID __EDC_ENTRYDATE __EDC_FORMLABEL VSSEQ SUBJECT VISIT2 VSDTC VSTMC 
		BODY_TEMPERATURE HEART_RATE SYSTOLIC_BLOOD_PRESSURE DIASTOLIC_BLOOD_PRESSURE 
		RESPIRATORY_RATE WEIGHT HEIGHT BMI;
    set preout;
	rename VSSEQ=__VSSEQ;
	rename BODY_TEMPERATURE=TEMP;
	rename HEART_RATE=HEART;
	rename SYSTOLIC_BLOOD_PRESSURE=SYSBP;
	rename DIASTOLIC_BLOOD_PRESSURE=DIABP;
	rename RESPIRATORY_RATE=RESP;

	label BODY_TEMPERATURE='Body Temperature';
	label HEART_RATE='Heart Rate (beats/min)';
	label SYSTOLIC_BLOOD_PRESSURE='Systolic Blood Pressure (mmHg)';
	label DIASTOLIC_BLOOD_PRESSURE='Diastolic Blood Pressure (mmHg)';
	label RESPIRATORY_RATE='Respiratory Rate (breaths/min)';
	label WEIGHT='Weight';
	label HEIGHT='Height';
	label BMI='Body Mass Idex';
run;



