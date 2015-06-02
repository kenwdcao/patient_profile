/*********************************************************************
 Program Nmae: LSNEW.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data lsnew1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.LSNEW;
	%subject;
	%visit2;

	** Assessment Date;
	length nldtc $20;
	label nldtc = 'Assessment Date';
	if NLDAT^=. then nldtc=put(NLDAT,yymmdd10.);else nldtc="";
	rc = h.find();
	%concatDY(nldtc);
	drop NLDAT rc;

run;

proc sort data=lsnew1_1 out=preout; by subject NLLNKID nldtc VISIT2; run;

data pdata.lsnew(label='New Lesion Assessment');
    retain __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 NLLNKID NLLOC NLLOCSPC 
		NLDTC NLMETHOD NLOMTHSP NLPDYN NLRSNSP;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 NLLNKID NLLOC NLLOCSPC 
		NLDTC NLMETHOD NLOMTHSP NLPDYN NLRSNSP;
    set preout;
	label NLOMTHSP = 'If Method is "Other", please specify';
	label NLPDYN = 'Is this considered PD?';
	label NLRSNSP = "If 'No', please specify reason";
run;

