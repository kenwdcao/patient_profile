/*********************************************************************
 Program Nmae: PDBTK2.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data pdbtk2_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.pdsample(where=(upcase(PDCAT)='IBRUTINIB PHARMACODYNAMICS / BIOMARKERS - PARTIAL'));
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
/*	if PDNA ne '' then dosedtmc = 'Not Applicable';*/
	drop PDDOSTIM; 

	**SAMPLE TIME**;
	length pdtmc $10;
	label pdtmc = 'Sample Time';
/*	if PDTIM ne . and PDND eq '' then pdtmc = put(PDTIM, time5.); else*/
/*		if PDTIM eq . and PDND ne '' then pdtmc = 'ND';*/
	if PDTIM ne . then pdtmc = put(PDTIM, time5.); 
run;

proc sort data=pdbtk2_1 out=preout; by subject PDDTC VISIT2; run;

data pdata.pdbtk2(label='Ibrutinib Pharmacodynamics / Biomarkers - Partial');
    retain __EDC_TREENODEID __EDC_ENTRYDATE PDCAT SUBJECT VISIT2 PDDTC DOSEDTMC PDDOSUNK PDNA PDTMC PDND;
    keep __EDC_TREENODEID __EDC_ENTRYDATE PDCAT SUBJECT VISIT2 PDDTC DOSEDTMC PDDOSUNK PDNA PDTMC PDND;
    set preout;
	rename PDCAT=__PDCAT;
	label PDND = 'Not Done';
	label PDNA = 'Not Applicable';
	label PDDOSUNK = 'Time Unknown';
run;



