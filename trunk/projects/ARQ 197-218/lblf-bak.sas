* Program Name: LBLF.sas;
* Author: Yiqi Diao (yiqi.diao@januscri.com);
* Initial Date: 18/02/2014;

%include '_setup.sas';

data lblf0;
	set source.lblf;
	%subjid;
	* numeric date to character date;
	length _LBLFDTC LBLFDTC $28 LBLFTMC $8;
    %numDate2Char(numdate = LBLFDT, chardate = _LBLFDTC);
	LBLFTMC = put(LBLFTM, time8.);
	if length(strip(LBLFTMC)) < 8 then LBLFTMC = '0' || strip(LBLFTMC);
	if _LBLFDTC ^= '' then LBLFDTC = strip(_LBLFDTC) || 'T' || substr(strip(LBLFTMC), 1, 5);
	*handle lab values;
	length N_ASTV N_ALTV N_LDHV N_ALKPHOV N_TOTBILV N_DIRBILV $200;
	label 
		LBLFDTC = 'Date'
		N_ASTV = 'AST(SGOT)'
		N_ALTV = 'ALT(SGPT)'
		N_LDHV = 'LDH'
		N_ALKPHOV = 'Alkaline Phosphatase'
		N_TOTBILV = 'Total Bilirubin'
		N_DIRBILV = 'Direct Bilirubin'
		;
	%labvalue(value=ASTV, abnfl=ASTS, outvar=N_ASTV);
	%labvalue(value=ALTV, abnfl=ALTS, outvar=N_ALTV);
	%labvalue(value=LDHV, abnfl=LDHS, outvar=N_LDHV);
	%labvalue(value=ALKPHOV, abnfl=ALKPHS, outvar=N_ALKPHOV);
	%labvalue(value=TOTBILV, abnfl=TBILS, outvar=N_TOTBILV);
	%labvalue(value=DIRBILV, abnfl=DBILS, outvar=N_DIRBILV);
	length VISIT $60;
	label VISIT = 'Visit';
	%getCycle;
	VISIT = __visit;
/*	%getvnum(visit=VISIT);*/
	if LBLFCLCD = 0 then do;
		if LBLFDTC = '' then LBLFDTC = 'NOT DONE';
			else LBLFDTC = LBLFDTC || ' (NOT DONE)';
	end;
run;

proc sort data = lblf0 out = lblf1;
by SUBJID __vdate LBLFDTC;
run;

data pdata.lblf (label='Liver Function Tests');
	retain SUBJID __vdate VISIT LBLFNAME LBLFDTC N_ASTV N_ALTV N_LDHV N_ALKPHOV N_TOTBILV N_DIRBILV;
	keep SUBJID __vdate VISIT LBLFNAME LBLFDTC N_ASTV N_ALTV N_LDHV N_ALKPHOV N_TOTBILV N_DIRBILV;
	set lblf1;
run;

