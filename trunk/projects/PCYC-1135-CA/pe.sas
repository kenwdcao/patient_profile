/*********************************************************************
 Program Nmae: PE.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data pe1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.pe;
	%subject;
	%visit2;

	** Assessment Date;
	length pedtc $20;
	label pedtc = 'Assessment Date';
	if PEDAT^=. then pedtc=put(PEDAT,yymmdd10.);else pedtc="";
	rc = h.find();
	%concatDY(pedtc);
	drop PEDAT rc;

	** order for test;
	if PETEST eq 'General Appearance' then test_ord = 1; else
		if PETEST eq 'Cardiovascular' then test_ord = 2; else
			if PETEST eq 'Dermatologic' then test_ord = 3; else
				if PETEST eq 'HEENT' then test_ord = 4; else
					if PETEST eq 'Lymphatic' then test_ord = 5; else
						if PETEST eq 'Respiratory' then test_ord = 6; else
							if PETEST eq 'Gastrointestinal' then test_ord = 7; else
								if PETEST eq 'Genitourinary' then test_ord = 8; else
									if PETEST eq 'Musculoskeletal' then test_ord = 9; else
										if PETEST eq 'Neurological' then test_ord = 10; else
											if PETEST eq 'Psychological' then test_ord = 11; else
												if PETEST eq 'Other' then test_ord = 12; 
run;

proc sort data=pe1_1 out=preout; by subject pedtc VISIT2 test_ord; run;

data pdata.pe(label='Physical Exam');
    retain __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 PEDTC PETEST PERES PEDESC PEOTHSP;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 PEDTC PETEST PERES PEDESC PEOTHSP;
    set preout;
	label PEDESC = 'If abnormal or not done, please specify';
	label PETEST = 'Assessment';
	label PEOTHSP = 'Other abnormalities (specify only if present)';
run;

