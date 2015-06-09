/*********************************************************************
 Program Nmae: PREGL.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data pregl1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.pregl;
	%subject;
	%visit2;

	** Assessment Date;
	length lbdtc $20;
	label lbdtc = 'Collection Date';
	if LBDAT^=. then lbdtc=put(LBDAT,yymmdd10.);else lbdtc="";
	rc = h.find();
	%concatDY(lbdtc);
	drop LBDAT rc;

run;

proc sort data=pregl1_1 out=preout; by subject LBDTC VISIT2; run;

data pdata.pregl(label='Pregnancy Test (Local Lab)');
    retain __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 LBDTC LBSPMTYP LBORRES ULTRES;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 LBDTC LBSPMTYP LBORRES ULTRES;
    set preout;
	label LBORRES='Result of pregnancy test';
	label ULTRES="If 'Positive', result of Ultrasound";
run;


