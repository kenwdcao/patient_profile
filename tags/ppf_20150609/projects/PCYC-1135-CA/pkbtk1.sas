/*********************************************************************
 Program Nmae: PKBTK1.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data pkbtk1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.pksample(where=(upcase(PKCAT)='IBRUTINIB PHARMACOKINETICS - FULL'));
	%subject;
	%visit2;

	** Sample Date;
	length pkdtc $20;
	label pkdtc = 'Sample Date';
	if pkdat^=. then pkdtc=put(pkdat,yymmdd10.);else pkdtc="";
	rc = h.find();
	%concatDY(pkdtc);
	drop pkdat rc;

    ** Ibrutinib Dose Time;
	length dosedtmc $20;
	label dosedtmc = 'Ibrutinib Dose Time';
	if PKDOSTIM ^=. then dosedtmc=put(PKDOSTIM, time5.); else dosedtmc="";
/*	if PKDOSUNK ^= '' then dosedtmc = 'Unknown';*/
	drop PKDOSTIM; 

	**order PKTPT**;
	if PKTPT eq 'Pre-Dose' then PKTPTN = 1; else
		if PKTPT eq '1 hour' then PKTPTN = 2; else
			if PKTPT eq '2 hour' then PKTPTN = 3; else
				if PKTPT eq '4 hour' then PKTPTN = 4; 

	**SAMPLE TIME**;
	length pktmc $10;
	label pktmc = 'Sample Time';
/*	if PKTIM ne . and PKND eq '' then pktmc = put(PKTIM, time5.); else*/
/*		if PKTIM eq . and PKND ne '' then pktmc = 'ND';*/
	if PKTIM ne . then pktmc = put(PKTIM, time5.); 
run;

proc sort data=pkbtk1_1 out=pkbtk1_s; by subject pkdtc VISIT2 DOSEDTMC PKDOSUNK __EDC_TREENODEID __EDC_ENTRYDATE PKCAT PKTPTN PKTPT; run;

**Sample Time;
proc transpose data=pkbtk1_s out=pkbtk1_time_t(rename=(PRE_DOSE=PREDOSE  _1_HOUR=ONEHOUR _2_HOUR=TWOHOUR _4_HOUR=FOURHOUR));
	by subject pkdtc VISIT2 DOSEDTMC PKDOSUNK __EDC_TREENODEID __EDC_ENTRYDATE PKCAT;
	id PKTPT;
	var pktmc; 
run;

**Not Done;
proc transpose data=pkbtk1_s out=pkbtk1_nd_t(rename=(PRE_DOSE=PREDND  _1_HOUR=ONEHND _2_HOUR=TWOHND _4_HOUR=FOURHND));
	by subject pkdtc VISIT2 DOSEDTMC PKDOSUNK __EDC_TREENODEID __EDC_ENTRYDATE PKCAT;
	id PKTPT;
	var PKND; 
run;

**merge Sample Time & Not Done;
data pkbtk1_t;
	merge pkbtk1_time_t pkbtk1_nd_t;
	by subject pkdtc VISIT2 DOSEDTMC PKDOSUNK __EDC_TREENODEID __EDC_ENTRYDATE PKCAT;
run;

proc sort data=pkbtk1_t out=preout; by subject pkdtc VISIT2; run;

data pdata.pkbtk1(label='Ibrutinib Pharmacokinetics - Full');
    retain __EDC_TREENODEID __EDC_ENTRYDATE PKCAT SUBJECT VISIT2 PKDTC DOSEDTMC PKDOSUNK 
		PREDOSE PREDND ONEHOUR ONEHND TWOHOUR TWOHND FOURHOUR FOURHND;
    keep __EDC_TREENODEID __EDC_ENTRYDATE PKCAT SUBJECT VISIT2 PKDTC DOSEDTMC PKDOSUNK 
		PREDOSE PREDND ONEHOUR ONEHND TWOHOUR TWOHND FOURHOUR FOURHND;
    set preout;
	rename PKCAT=__PKCAT;
	attrib
	PKDOSUNK label = 'Time Unknown'
	PREDOSE label = 'Sample Time@:Pre-Dose@:Timepoint'
	PREDND label = 'Not Done@:Pre-Dose@:Timepoint'
	ONEHOUR label = 'Sample Time@:1 hour@:Timepoint'
	ONEHND label = 'Not Done@:1 hour@:Timepoint'
	TWOHOUR label = 'Sample Time@:2 hour@:Timepoint'
	TWOHND label = 'Not Done@:2 hour@:Timepoint'
	FOURHOUR label = 'Sample Time@:4 hour@:Timepoint'
	FOURHND label = 'Not Done@:4 hour@:Timepoint'
	;
run;



