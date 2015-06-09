/*********************************************************************
 Program Nmae: LSTG2.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data LSTG1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.LSTG(where=(upcase(TGCAT)='TARGET LESION ASSESSMENT'));
	%subject;
	%visit2;

	** Assessment Date;
	length trdtc $20;
	label trdtc = 'Assessment Date';
	if TGDAT^=. then trdtc=put(TGDAT,yymmdd10.);else trdtc="";
	rc = h.find();
	%concatDY(trdtc);
	drop TGDAT rc;

run;

proc sort data=LSTG1_1 out=preout; by subject trdtc VISIT2; run;

data pdata.lstg2(label='Target Lesion Assessment');
    retain __EDC_TREENODEID __EDC_ENTRYDATE TGCAT SUBJECT VISIT2 TGLNKID TGLOC TGLOCSPC 
		TRDTC TGMETHOD TGOMTHSP TGORRES TGSUM TGTSTM TGNORMLZ TGND;
    keep __EDC_TREENODEID __EDC_ENTRYDATE TGCAT SUBJECT VISIT2 TGLNKID TGLOC TGLOCSPC 
		TRDTC TGMETHOD TGOMTHSP TGORRES TGSUM TGTSTM TGNORMLZ TGND;
    set preout;
	rename TGCAT=__TGCAT;
	label TGOMTHSP = 'If Method is "Other", please specify';
	label TGORRES = 'Diameter (mm)';
	label TGND = 'Not Done';
run;

