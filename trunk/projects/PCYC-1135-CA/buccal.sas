/*********************************************************************
 Program Nmae: BUCCAL.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/05/04
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data buccal1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.buccal;
	%subject;
	%visit2;
	** Assessment Date;
	length LBDTC $20;
	label LBDTC = 'Collection Date';
	if LBDAT^=. then LBDTC=put(LBDAT,yymmdd10.);else LBDTC="";
	rc = h.find();
	%concatDY(LBDTC);
	drop LBDAT rc;

run;

proc sort data = buccal1; by subject LBDTC visit2; run;

data pdata.buccal(label='Buccal Swab (Central Lab)');
    retain __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 LBDTC;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 LBDTC;
    set buccal1;
run;

