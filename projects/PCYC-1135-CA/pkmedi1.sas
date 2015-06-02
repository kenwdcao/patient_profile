/*********************************************************************
 Program Nmae: pkmedi1.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data pkmedi1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.pksample(where=(upcase(PKCAT)='MEDI4736 PHARMACOKINETICS - FULL'));
	%subject;
	%visit2;

	** Sample Date;
	length pkdtc $20;
	label pkdtc = 'Sample Date';
	if pkdat^=. then pkdtc=put(pkdat,yymmdd10.);else pkdtc="";
	rc = h.find();
	%concatDY(pkdtc);
	drop pkdat rc;

	**order PKTPT**;
	if PKTPT eq 'Pre-Dose' then PKTPTN = 1; else
		if PKTPT eq '1 hour' then PKTPTN = 2; 

	**SAMPLE TIME**;
	length pktmc $10;
	label pktmc = 'Sample Time (24 Hour Clock)';
/*	if PKTIM ne . and PKND eq '' then pktmc = put(PKTIM, time5.); else*/
/*		if PKTIM eq . and PKND ne '' then pktmc = 'ND';*/
	if PKTIM ne . then pktmc = put(PKTIM, time5.); 
run;

proc sort data=pkmedi1_1 out=pkmedi1_s; by subject pkdtc VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE PKCAT PKTPTN PKTPT; run;

**Sample Time;
proc transpose data=pkmedi1_s out=pkmedi1_time_t(rename=(PRE_DOSE=PREDOSE _1_HOUR=ONEHOUR));
	by subject pkdtc VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE PKCAT;
	id PKTPT;
	var pktmc; 
run;

**Not Done;
proc transpose data=pkmedi1_s out=pkmedi1_nd_t(rename=(PRE_DOSE=PREDND _1_HOUR=ONEHND));
	by subject pkdtc VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE PKCAT;
	id PKTPT;
	var PKND; 
run;

**merge Sample Time & Not Done;
data pkmedi1_t;
	merge pkmedi1_time_t pkmedi1_nd_t;
	by subject pkdtc VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE PKCAT;
run;

proc sort data=pkmedi1_t out=preout; by subject pkdtc VISIT2; run;

data pdata.pkmedi1(label='MEDI4736 Pharmacokinetics - Full');
    retain __EDC_TREENODEID __EDC_ENTRYDATE PKCAT SUBJECT VISIT2 PKDTC PREDOSE PREDND ONEHOUR ONEHND;
    keep __EDC_TREENODEID __EDC_ENTRYDATE PKCAT SUBJECT VISIT2 PKDTC PREDOSE PREDND ONEHOUR ONEHND;
    set preout;
	rename PKCAT=__PKCAT;
	attrib
	PREDOSE label = 'Sample Time@:Pre-Dose@:Timepoint'
	PREDND label = 'Not Done@:Pre-Dose@:Timepoint'
	ONEHOUR label = 'Sample Time@:1 hour@:Timepoint'
	ONEHND label = 'Not Done@:1 hour@:Timepoint'
	;
run;



