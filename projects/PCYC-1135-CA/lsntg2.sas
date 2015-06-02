/*********************************************************************
 Program Nmae: LSNTG2.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data lsntg2_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.lsntg(where=(upcase(NTCAT)='NON-TARGET LESION ASSESSMENT'));
	%subject;
	%visit2;

	** Assessment Date;
	length nldtc $20;
	label nldtc = 'Assessment Date';
	if NTDAT^=. then nldtc=put(NTDAT,yymmdd10.);else nldtc="";
	rc = h.find();
	%concatDY(nldtc);
	drop NTDAT rc;


/*	** Assessment Not Done;*/
/*	length NTASND $20;*/
/*	label NTASND = 'Assessment Not Done';*/
/*	if NTND ne '' then NTASND = 'Assessment Not Done';*/
run;

proc sort data=lsntg2_1 out=preout; by subject NTLNKID nldtc VISIT2; run;

***NOTE: when data is provided, need to handle with "Not Done"***;

data pdata.lsntg2(label='Non-Target Lesion Assessment');
    retain __EDC_TREENODEID __EDC_ENTRYDATE NTCAT SUBJECT VISIT2 NTLNKID NTLOC NTLOCSPC 
		NLDTC NTMETHOD NTOMTHSP NTSTATUS NTND;
    keep __EDC_TREENODEID __EDC_ENTRYDATE NTCAT SUBJECT VISIT2 NTLNKID NTLOC NTLOCSPC 
		NLDTC NTMETHOD NTOMTHSP NTSTATUS NTND;
	rename NTCAT=__NTCAT;
    set preout;
	label NTOMTHSP = 'If Method is "Other", please specify';
	label NTND = 'Not Done';
run;

