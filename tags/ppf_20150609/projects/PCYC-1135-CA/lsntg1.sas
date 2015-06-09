/*********************************************************************
 Program Nmae: LSNTG1.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data lsntg1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.lsntg(where=(upcase(NTCAT)='NON-TARGET LESION ASSESSMENT (BASELINE)'));
	%subject;
	%visit2;

	** Assessment Date;
	length nldtc $20;
	label nldtc = 'Assessment Date';
	if NTDAT^=. then nldtc=put(NTDAT,yymmdd10.);else nldtc="";
	rc = h.find();
	%concatDY(nldtc);
	drop NTDAT rc;

run;

proc sort data=lsntg1_1 out=preout; by subject NTLNKID nldtc VISIT2; run;

data pdata.lsntg1(label='Non-Target Lesion Assessment Baseline');
    retain __EDC_TREENODEID __EDC_ENTRYDATE NTCAT SUBJECT VISIT2 NTYN NTLNKID NTLOC NTLOCSPC 
		NLDTC NTMETHOD NTOMTHSP;
    keep __EDC_TREENODEID __EDC_ENTRYDATE NTCAT SUBJECT VISIT2 NTYN NTLNKID NTLOC NTLOCSPC 
		NLDTC NTMETHOD NTOMTHSP;
	rename NTCAT=__NTCAT;
    set preout;
	label NTYN = "Are there any reportable Non-Target Lesions at Baseline? If 'Yes', provide detailed Non-Target Lesion information";
	label NTOMTHSP = 'If Method is "Other", please specify';
run;

