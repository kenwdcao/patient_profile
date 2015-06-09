/*********************************************************************
 Program Nmae: PDBTK1.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data pdbtk1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.pdsample(where=(upcase(PDCAT)='IBRUTINIB PHARMACODYNAMICS / BIOMARKERS - FULL'));
	%subject;
	%visit2;

	** Sample Date;
	length pddtc $20;
	label pddtc = 'Sample Date';
	if pddat^=. then pddtc=put(pddat,yymmdd10.);else pddtc="";
	rc = h.find();
	%concatDY(pddtc);
	drop pddat rc;

    ** Ibrutinib Dose Time;
	length dosedtmc $20;
	label dosedtmc = 'Ibrutinib Dose Time';
	if PDDOSTIM ^=. then dosedtmc=put(PDDOSTIM, time5.); else dosedtmc="";
/*	if PDDOSUNK ^= '' then dosedtmc = 'Unknown';*/
	drop PDDOSTIM; 

	**order PDTPT**;
	if PDTPT eq 'Pre-Dose' then PDTPTN = 1; else
		if PDTPT eq '4 hour' then PDTPTN = 2; else
			if PDTPT eq '24 hour' then PDTPTN = 3; 

	**SAMPLE TIME**;
	length pdtmc $10;
	label pdtmc = 'Sample Time';
/*	if PDTIM ne . and PDND eq '' then pdtmc = put(PDTIM, time5.); else*/
/*		if PDTIM eq . and PDND ne '' then pdtmc = 'ND';*/
	if PDTIM ne . then pdtmc = put(PDTIM, time5.); 
run;

proc sort data=pdbtk1_1 out=pdbtk1_s; by subject PDDTC VISIT2 DOSEDTMC PDDOSUNK __EDC_TREENODEID __EDC_ENTRYDATE PDCAT PDTPTN PDTPT; run;

**Sample Time;
proc transpose data=pdbtk1_s out=pdbtk1_time_t(rename=(PRE_DOSE=PREDOSE _4_HOUR=FOURHOUR _24_HOUR=TTFHOUR));
	by subject PDDTC VISIT2 DOSEDTMC PDDOSUNK __EDC_TREENODEID __EDC_ENTRYDATE PDCAT;
	id PDTPT;
	var pdtmc; 
run;

**Not Done;
proc transpose data=pdbtk1_s out=pdbtk1_nd_t(rename=(PRE_DOSE=PREDND _4_HOUR=FOURHND _24_HOUR=TTFHND));
	by subject PDDTC VISIT2 DOSEDTMC PDDOSUNK __EDC_TREENODEID __EDC_ENTRYDATE PDCAT;
	id PDTPT;
	var PDND; 
run;

**merge Sample Time & Not Done;
data pdbtk1_t;
	merge pdbtk1_time_t pdbtk1_nd_t;
	by subject PDDTC VISIT2 DOSEDTMC PDDOSUNK __EDC_TREENODEID __EDC_ENTRYDATE PDCAT;
run;

proc sort data=pdbtk1_t out=preout; by subject PDDTC VISIT2; run;

data pdata.pdbtk1(label='Ibrutinib Pharmacodynamics / Biomarkers - Full');
    retain __EDC_TREENODEID __EDC_ENTRYDATE PDCAT SUBJECT PDDTC VISIT2 DOSEDTMC PDDOSUNK 
		PREDOSE PREDND FOURHOUR FOURHND TTFHOUR TTFHND;
    keep __EDC_TREENODEID __EDC_ENTRYDATE PDCAT SUBJECT PDDTC VISIT2 DOSEDTMC PDDOSUNK 
		PREDOSE PREDND FOURHOUR FOURHND TTFHOUR TTFHND;
    set preout;
	rename PDCAT=__PDCAT;
	attrib
	PREDOSE label = 'Sample Time@:Pre-Dose@:Timepoint'
	PREDND label = 'Not Done@:Pre-Dose@:Timepoint'
	FOURHOUR label = 'Sample Time@:4 hour@:Timepoint'
	FOURHND label = 'Not Done@:4 hour@:Timepoint'
	TTFHOUR label = 'Sample Time@:24 hour@:Timepoint'
	TTFHND label = 'Not Done@:24 hour@:Timepoint'
	PDDOSUNK label = 'Time Unknown'
	;
run;



