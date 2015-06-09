/*********************************************************************
 Program Nmae: pkmedi2.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data pkmedi2_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.pksample(where=(upcase(PKCAT)='MEDI4736 PHARMACOKINETICS - PARTIAL'));
	%subject;
	%visit2;

	** Sample Date;
	length pkdtc $20;
	label pkdtc = 'Sample Date';
	if pkdat^=. then pkdtc=put(pkdat,yymmdd10.);else pkdtc="";
	rc = h.find();
	%concatDY(pkdtc);
	drop pkdat rc;

	**SAMPLE TIME**;
	length pktmc $10;
	label pktmc = 'Pre-Dose@:Sample Time (24 Hour Clock)';
/*	if PKTIM ne . and PKND eq '' then pktmc = put(PKTIM, time5.); else*/
/*		if PKTIM eq . and PKND ne '' then pktmc = 'ND';*/
	if PKTIM ne . then pktmc = put(PKTIM, time5.);
run;

proc sort data=pkmedi2_1 out=preout; by subject pkdtc VISIT2; run;

data pdata.pkmedi2(label='MEDI4736 Pharmacokinetics - Partial');
    retain __EDC_TREENODEID __EDC_ENTRYDATE PKCAT SUBJECT VISIT2 PKDTC PKTMC PKND;
    keep __EDC_TREENODEID __EDC_ENTRYDATE PKCAT SUBJECT VISIT2 PKDTC PKTMC PKND;
    set preout;
	rename PKCAT=__PKCAT;
	label PKTMC = 'Sample Time@:Pre-Dose@:Timepoint';
	label PKND = 'Not Done@:Pre-Dose@:Timepoint';
run;



