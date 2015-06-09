/*********************************************************************
 Program Nmae: PKBTK2.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data pkbtk2_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.pksample(where=(upcase(PKCAT)='IBRUTINIB PHARMACOKINETICS - PARTIAL'));
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

	**SAMPLE TIME**;
	length pktmc $10;
	label pktmc = 'Sample Time';
/*	if PKTIM ne . and PKND eq '' then pktmc = put(PKTIM, time5.); else*/
/*		if PKTIM eq . and PKND ne '' then pktmc = 'ND';*/
	if PKTIM ne . then pktmc = put(PKTIM, time5.);
run;

proc sort data=pkbtk2_1 out=preout; by subject pkdtc VISIT2; run;

data pdata.pkbtk2(label='Ibrutinib Pharmacokinetics - Partial');
    retain __EDC_TREENODEID __EDC_ENTRYDATE PKCAT SUBJECT VISIT2 PKDTC DOSEDTMC PKDOSUNK PKTMC PKND;
    keep __EDC_TREENODEID __EDC_ENTRYDATE PKCAT SUBJECT VISIT2 PKDTC DOSEDTMC PKDOSUNK PKTMC PKND;
    set preout;
	rename PKCAT=__PKCAT;
	label PKTMC = 'Sample Time@:24 hour@:Timepoint';
	label PKND = 'Not Done@:24 hour@:Timepoint';
	label PKDOSUNK = 'Time Unknown';
run;



