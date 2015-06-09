/*********************************************************************
 Program Nmae: PDMEDI1.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data pdmedi1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.pdsample(where=(upcase(PDCAT)='MEDI4736 PHARMACODYNAMICS - FULL'));
	%subject;
	%visit2;

	** Sample Date;
	length pddtc $20;
	label pddtc = 'Sample Date';
	if pddat^=. then pddtc=put(pddat,yymmdd10.);else pddtc="";
	rc = h.find();
	%concatDY(pddtc);
	drop pddat rc;

	**order PDTPT**;
	if PDTPT eq 'Pre-Dose' then PDTPTN = 1; else
		if PDTPT eq '1 hour' then PDTPTN = 2; 

	**SAMPLE TIME**;
	length pdtmc $10;
	label pdtmc = 'Sample Time (24 Hour Clock)';
/*	if PDTIM ne . and PDND eq '' then pdtmc = put(PDTIM, time5.); else*/
/*		if PDTIM eq . and PDND ne '' then pdtmc = 'ND';*/
	if PDTIM ne . and PDND eq '' then pdtmc = put(PDTIM, time5.);
run;

proc sort data=pdmedi1_1 out=pdmedi1_s; by subject PDDTC VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE PDCAT PDTPTN PDTPT; run;

**Sample Time;
proc transpose data=pdmedi1_s out=pdmedi1_time_t(rename=(PRE_DOSE=PREDOSE _1_HOUR=ONEHOUR));
	by subject PDDTC VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE PDCAT;
	id PDTPT;
	var pdtmc; 
run;

**Not Done;
proc transpose data=pdmedi1_s out=pdmedi1_nd_t(rename=(PRE_DOSE=PREDND _1_HOUR=ONEHND));
	by subject PDDTC VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE PDCAT;
	id PDTPT;
	var PDND; 
run;

**merge Sample Time & Not Done;
data pdmedi1_t;
	merge pdmedi1_time_t pdmedi1_nd_t;
	by subject PDDTC VISIT2 __EDC_TREENODEID __EDC_ENTRYDATE PDCAT;
run;

proc sort data=pdmedi1_t out=preout; by subject PDDTC VISIT2; run;

data pdata.pdmedi1(label='MEDI4736 Pharmacodynamics - Full');
    retain __EDC_TREENODEID __EDC_ENTRYDATE PDCAT SUBJECT VISIT2 PDDTC PREDOSE PREDND ONEHOUR ONEHND;
    keep __EDC_TREENODEID __EDC_ENTRYDATE PDCAT SUBJECT VISIT2 PDDTC PREDOSE PREDND ONEHOUR ONEHND;
    set preout;
	rename PDCAT=__PDCAT;
	attrib
	PREDOSE label = 'Sample Time@:Pre-Dose@:Timepoint'
	PREDND label = 'Not Done@:Pre-Dose@:Timepoint'
	ONEHOUR label = 'Sample Time@:1 hour@:Timepoint'
	ONEHND label = 'Not Done@:1 hour@:Timepoint'
	;
run;


