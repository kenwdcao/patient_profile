/*********************************************************************
 Program Nmae: TBX.sas
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

    set source.tbx;
	%subject;
	%visit2;

	** Sample Date;
	length tbdtc $20;
	label tbdtc = 'Sample Date';
	if TBXDAT^=. then tbdtc=put(TBXDAT,yymmdd10.);else tbdtc="";
	rc = h.find();
	%concatDY(tbdtc);
	drop TBXDAT rc;

	** Sample Type;
	length TBXSTYPO $200;
	label TBXSTYPO = 'Sample Type';
	if index(upcase(TBXSTYPE), 'OTHER')>0 then TBXSTYPO = catx(': ', TBXSTYPE, OTHTYPSP); else
		if index(upcase(TBXSTYPE), 'OTHER')=0 then TBXSTYPO = strip(TBXSTYPE); 

	** Method Used;
	length TBXMETHO $200;
	label TBXMETHO = 'Method Used';
	if index(upcase(TBXMETH), 'OTHER')>0 then TBXMETHO = catx(': ', TBXMETH, OTMETHSP); else
		if index(upcase(TBXMETH), 'OTHER')=0 then TBXMETHO = strip(TBXMETH); 

run;

proc sort data=LSTG1_1 out=preout; by subject tbdtc VISIT2; run;

data pdata.tbx(label='Tumor Biopsy');
    retain __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 TBXND TBDTC 
		TBXSTYPO TBXTTYPE TBXLOC LOCOTHSP TBXMETHO;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 TBXND TBDTC 
		TBXSTYPO TBXTTYPE TBXLOC LOCOTHSP TBXMETHO;
    set preout;
	label TBXND='Not Done';
	label LOCOTHSP='If Other soft tissue or Other site, specify';
run;
