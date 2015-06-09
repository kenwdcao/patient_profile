%include '_setup.sas';
/*demog_dm*/
proc sort data=source.demo out=demo(keep=subid SUBINIT  BIRTHDT SDATE SEX ETHNICTY RACE RACESP) nodupkey; by subid id; run;

data demog_dm;
	length SEX $1 ETHNICTY $40 RACE $40;
	keep SUBID SUBINIT SEX ETHNICTY RACE BIRTHDT;
	set demo(rename=(
	SEX=in_SEX
	ETHNICTY=in_ETHNICTY
	RACE=in_RACE
	));
	
	if in_SEX^=. then SEX = strip(put(in_SEX,sex.));
	if in_ETHNICTY^=. then ETHNICTY = strip(put(in_ETHNICTY,ETHNICTY.));
	if in_RACE=99 then do;
		if RACESP^='' then RACE='Other: '||strip(RACESP);
			else RACE='Other';
	end;
		else if in_RACE^=. then RACE=strip(put(in_RACE,RACE.));
	label RACE='Race'
		  ETHNICTY='Ethnicity';
run;

proc sort data=demog_dm; by SUBID; run;

/*demog_icf*/
proc sort data=source.icf out=icf(keep=subid CNSNT CNSNTDT CNSNTDTC CNVSN PVNUM PVNUMSP) nodupkey; by subid id; run;

data demog_icf;
	length CNSNT $40 PVNUM $40;
	keep SUBID CNSNT CNSNTDT CNSNTDTC CNVSN PVNUM;
	set icf(rename=(
	CNSNT=in_CNSNT
	PVNUM=in_PVNUM
	));
	if in_CNSNT^=. then CNSNT = strip(put(in_CNSNT,NOYES.));
	if in_PVNUM=2 then do;
		if PVNUMSP^='' then PVNUM='Amendment'||' '||strip(PVNUMSP);
		else PVNUM='Amendment';
	end;
		else if in_PVNUM^=. then PVNUM = strip(put(in_PVNUM,PVNUM.));
	label CNSNT='Consent Signed'
		  CNSNTDTC='Date ICF Was Signed'
		  CNVSN='ICF Version'
		  PVNUM='Protocol Version';
run;	

proc sort data=demog_icf; by SUBID; run;

/*demog_el*/
proc sort data=source.el out=el nodupkey; by SUBID ID;run;

data demog_el;
	length INCLS $200 EXCLS $200;
	keep SUBID INCLS EXCLS;
	set el;
/*	if INCLMET=0 then do;*/
/*		if INCLWAV^='' and INCLNOT^='' then INCLS='No'||',#'||strip(INCLNOT)||',Waive #'||strip(INCLWAV);*/
/*			else if INCLNOT^='' then INCLS='No'||',#'||strip(INCLNOT);*/
/*				else INCLS='No';*/
/*	end;*/
/*		else if INCLMET=1 then INCLS='Yes';*/
/*	if EXCLMET=0 then do;*/
/*		if EXCLWAV^='' and EXCLNOT^='' then EXCLS='No'||',#'||strip(EXCLNOT)||',Waive #'||strip(EXCLWAV);*/
/*			else if EXCLNOT^='' then EXCLS='No'||',#'||strip(EXCLNOT);*/
/*				else EXCLS='No';*/
/*	end;*/
/*		else if EXCLMET=1 then EXCLS='Yes';*/
	if INCLNOT^='' then INCLS='#'||strip(INCLNOT); 
	if EXCLNOT^='' then EXCLS='#'||strip(EXCLNOT); 
	label INCLS='Inclusion Criterion Not Met'
		  EXCLS='Exclusion Criterion Not Met';
run;

proc sort data=demog_el; by SUBID; run;

/*demog_preg*/
proc sort data=source.preg out=preg nodupkey; by subid id; where EVENT_ID='Pre-Study Visit'; run;

data demog_preg;
	length pregtest $200 PREGMETH $40 PREGRES $40;
	keep SUBID PREGTEST;
	set preg(rename=(
	PREGMETH=in_PREGMETH
	PREGRES=in_PREGRES
	));
	if in_PREGMETH^=. then PREGMETH=strip(put(in_PREGMETH,PREGMETH.));
	if in_PREGRES^=. then PREGRES=strip(put(in_PREGRES,PREGRES.));
	if PREGYNNA=0 then pregtest='NOT DONE';
		else if PREGYNNA=2 then pregtest='N/A';
			else if PREGYNNA=1 then do;
				pregtest=strip(catx(',',PREGMETH,PREGRES));
			end;
	label pregtest='Pregnancy Test';
run;

proc sort data=demog_preg; by SUBID; run;

/*demog_atd*/
proc sort data=source.atd out=demog_atd(keep=SUBID DRUGADOS) nodupkey; by subid id; run;

/*demog_sc*/
proc sort data=source.sc out=sc nodupkey; by subid id; run;

data demog_sc;
	length SCDCTX $40 RSNTERM $200 ENDTREAT $200;
	keep subid ENDTREAT;
	set sc(rename=(
	SCDCTX=in_SCDCTX
	RSNTERM=in_RSNTERM
	));
	if in_SCDCTX^=. then SCDCTX=strip(put(in_SCDCTX,NOYES.));
	if in_RSNTERM=99 and RSNTRSP^='' then RSNTERM='Other: '||strip(RSNTRSP);
		else if in_RSNTERM^=. then RSNTERM=strip(put(in_RSNTERM,RSNTERM.));
	if in_SCDCTX=0 then ENDTREAT='N';
		else if in_SCDCTX=1 then ENDTREAT='Y/'||strip(RSNTERM);
	label ENDTREAT='Discontinue Study Treatment Reason';
run;

proc sort data=demog_sc; by SUBID; run;

/*demog_ecog*/;
proc sort data=source.es out=es nodupkey; by SUBID ID; where EVENT_ID='Pre-Study Visit'; run;

data demog_ecog;
	length ECOG $40 ESPS $200;
	keep SUBID ECOG;
	set es(rename=(ESPS=in_ESPS));
	if in_ESPS^=. then ESPS=strip(put(in_ESPS,best.));
	if ESYN=0 then ECOG='NOT DONE';
		else ECOG=ESPS;
	label ECOG='ECOG Performance Status';
run;

/*demog_sd*/
proc sort data=source.sd out=sd; by SUBID SDSTDT; where SDSTDT^=. and SDDOSST^=0; run;

data demog_sd;
	keep SUBID SDSTDT SDSTDTC;
	set sd;
	by SUBID SDSTDT;
	if first.SUBID;
	label SDSTDTC='Date of First Dose';
run;

proc sort data=demog_sd; by SUBID; run;

/*demog_dth*/;
proc sort data=source.dth out=dth nodupkey; by SUBID ID; run;

data demog_dth;
	length DEATHREA $200;
	keep SUBID DEATHREA;
	set dth(rename=(DTHCOD=in_DTHCOD));
	if DTHCODSP^='' then DTHCOD='Other: '||strip(DTHCODSP);
		else if in_DTHCOD=99 then DTHCOD='Other';
			else if in_DTHCOD^=. then DTHCOD=strip(put(in_DTHCOD,DTHCOD.));
	DEATHREA=catx(',',strip(DTHDTC),DTHCOD);
	label DEATHREA='Primary Cause of Death';	
run;

proc sort data=demog_dth; by SUBID; run;

/*demog_lbh*/;

proc sort data=source.lbh out=lbh_0(keep=SUBID LBHYN ANALYTE) nodupkey; by SUBID; where EVENT_ID='Pre-Study Visit' and strip(ANALYTE) in('hem_hemoglobin','hem_neutrophils_absolute','hem_platelets'); run;
proc sort data=source.lbh out=lbh_1 nodupkey; by SUBID CHILD_ID; where EVENT_ID='Pre-Study Visit' and strip(ANALYTE) in('hem_hemoglobin','hem_neutrophils_absolute','hem_platelets') and LBRES^=''; run;

data lbh;
	merge lbh_0(in=a) lbh_1;
	by SUBID;
	if a;
run;

data lbh_all;
	length LBTEST $40 label $200 LBORRES LBUNIT EXPONENT $200;
	keep SUBID LBTEST LBORRES label;
	set lbh(rename=(LBUNIT=LBUNIT_ EXPONENT=EXPONENT_));
	if EXPONENT_^=. then EXPONENT='10^'||strip(put(EXPONENT_,best.));
/*	if LBUNIT_^='' then LBUNIT=catx('',strip(EXPONENT),strip(LBUNIT_));*/
	LBUNIT=strip(catx('',strip(EXPONENT),strip(LBUNIT_)));
	if LBHYN=0 then LBORRES='Sample not collected';
/*		else if LBHYN=1 and strip(LBRES)='' then LBORRES='N/A';*/
			else if strip(LBRES)^='' then LBORRES=catx('',strip(LBRES),LBUNIT);
	if strip(ANALYTE)='hem_hemoglobin' then do;LBTEST='HGB'; label='Hemoglobin'; end;
	if strip(ANALYTE)='hem_neutrophils_absolute' then do;LBTEST='ANC'; label='ANC'; end;
	if strip(ANALYTE)='hem_platelets' then do;LBTEST='PLATE'; label='Platelet count'; end;
run;

proc sort data=lbh_all; by SUBID; run;

proc transpose data=lbh_all out=demog_lbh(drop=_name_); by SUBID; id LBTEST; idlabel label; var LBORRES; run;

proc sort data=demog_lbh; by SUBID; run;

/*demog_lbc*/;
proc sort data=source.lbc out=lbc_0(keep=SUBID LBCYN ANALYTE) nodupkey; by SUBID; where EVENT_ID='Pre-Study Visit' and strip(ANALYTE) in('chem_alt','chem_ast','chem_bilirubin_total','chem_creatinine'/*,'chem_bilirubin_total_direct'*/); run;
proc sort data=source.lbc out=lbc_1 nodupkey; by SUBID CHILD_ID; where EVENT_ID='Pre-Study Visit' and strip(ANALYTE) in('chem_alt','chem_ast','chem_bilirubin_total','chem_creatinine'/*,'chem_bilirubin_total_direct'*/) and LBORRES^=''; run;

data lbc;
	merge lbc_0(in=a) lbc_1;
	by SUBID;
	if a;
run;

data lbc_all;
	length LBTEST $40 label $200 ORRES $200;
	keep SUBID LBTEST ORRES label;
	set lbc(rename=(LBUNIT=LBUNIT_ EXPONENT=EXPONENT_));
	if EXPONENT_^=. then EXPONENT='10^'||strip(put(EXPONENT_,best.));
	if LBUNIT_^='' then LBUNIT=catx('',strip(EXPONENT),strip(LBUNIT_));
	if LBCYN=0 then ORRES='Sample not collected';
		else if LBCYN=1 and strip(LBORRES)='' then ORRES='N/A';
/*			else if strip(LBORRES)^='' then ORRES=catx(',',strip(LBDTC),catx('',strip(LBORRES),LBUNIT));*/
			else if strip(LBORRES)^='' then ORRES=catx('',strip(LBORRES),LBUNIT)||'(ULN:'||strip(put(REP_RNGH,best.))||' '||strip(LBUNIT)||')';
	if strip(ANALYTE)='chem_alt' then do;LBTEST='ALT'; label='ALT'; end;
	if strip(ANALYTE)='chem_ast' then do;LBTEST='AST'; label='AST'; end;
	if strip(ANALYTE)='chem_bilirubin_total' then do;LBTEST='BILI'; label='Total bilirubin'; end;
	if strip(ANALYTE)='chem_creatinine' then do;LBTEST='CREAT'; label='Creatinine'; end;
run;

proc sort data=lbc_all; by SUBID; run;

proc transpose data=lbc_all out=demog_lbc(drop=_name_); by SUBID; id LBTEST; idlabel label; var ORRES; run;

proc sort data=demog_lbc; by SUBID; run;

/*demog_tm*/;
proc sort data=source.tm(rename=(ID=ID_ SUBID=SUBID_)) out=tm(keep=subid_ id_ TMYN TMDATEC TMSUM); by SUBID_; where TMVIS=1; run;
proc sql;
	create table tm_all0 as
	select a.*, b.*
	from tm as a left join source.lmd as b
	on a.subid_=b.subid and a.ID_=b.parent
	;
quit;

proc sql;
	create table demog_tm as
	select distinct SUBID_ as subid, strip(put(count(TMNUM),best.)) as NUMTM length=8 label='Number of Target Lesions'
	from tm_all0
	group by SUBID
	;
quit;

/*merge all*/
data demog_all; 
	merge demog_dm demog_icf demog_el demog_sc demog_dth demog_atd demog_sd demog_preg demog_ecog demog_lbh demog_lbc demog_tm;
	by subid;
run;

data demog_0;
	length age $200 __TITLE $200 SUBID1 $200;
	set demog_all;
	if CNSNTDT^=. and BIRTHDT^=. then AGE=strip(put(int((CNSNTDT-BIRTHDT)/365.25),best.));
	if age^='' then AGE=strip(age)||'&escapechar{super [1]}';
	if SUBINIT^='' then SUBID1=catx('(',strip(SUBID),strip(SUBINIT))||')';
	__TITLE=catx(' / ',strip(SUBID1),strip(sex),strip(age));
	label DRUGADOS='Dose Group'
		  ENDTREAT='Treatment Discontinuation/Reason'
		  ;
run;

data dm;
	retain  __TITLE SUBID SUBINIT SEX AGE ETHNICTY RACE CNSNTDTC CNVSN PVNUM INCLS EXCLS ENDTREAT DEATHREA DRUGADOS SDSTDTC
		    PREGTEST ECOG NUMTM HGB PLATE ANC AST ALT CREAT BILI;
	keep  __TITLE SUBID SUBINIT SEX AGE ETHNICTY RACE CNSNTDTC CNVSN PVNUM INCLS EXCLS ENDTREAT DEATHREA DRUGADOS SDSTDTC
		    PREGTEST ECOG NUMTM HGB PLATE ANC AST ALT CREAT BILI;
	set demog_0;
run;

data pre_dm;
	set dm;
	length col $2000 i 8;
/*    %concat(invars = SUBINIT ETHNICTY RACE CNSNTDTC CNVSN PVNUM INCLS EXCLS, outvar = col, nblank = 10); output;*/
/*    %concat(invars = DRUGADOS SDSTDTC ENDTREAT, outvar = col, nblank = 20); output;*/
/*    %concat(invars = NUMTM PREGTEST ECOG ANC HGB AST PLATE ALT BILI, outvar = col, nblank = 10); output;*/
/*    %concat(invars = DEATHREA, outvar = col); output;*/
/*    %concat(invars = DRUGADOS SDSTDTC ETHNICTY RACE, outvar = col, nblank = 10); i=1;output;*/
/*    %concat(invars = CNSNTDTC CNVSN PVNUM, outvar = col, nblank = 20); i=1;output;*/
/*    %concat(invars = INCLS EXCLS, outvar = col, nblank = 19); i=3;i=1;output;*/
/*    %concat(invars = NUMTM PREGTEST ECOG, outvar = col, nblank = 20); i=2; output;*/
/*    %concat(invars = HGB PLATE BILI, outvar = col, nblank = 25); i=2; output;*/
/*    %concat(invars = ANC AST ALT CREAT, outvar = col, nblank = 15); i=2; output;*/
/*    %concat(invars = ENDTREAT, outvar = col); i=3; output;*/
/*    %concat(invars = DEATHREA, outvar = col); i=3; output;*/
    %compose(invars = DRUGADOS SDSTDTC ETHNICTY RACE, outvar = col, lengths = 45); i=1;output;
    %compose(invars = CNSNTDTC CNVSN PVNUM, outvar = col, lengths = 50); i=1;output;
    %compose(invars = INCLS EXCLS, outvar = col, lengths = 50); i=1;output;
    %compose(invars = NUMTM PREGTEST ECOG, outvar = col, lengths = 50); i=2; output;
    %compose(invars = HGB PLATE BILI, outvar = col, lengths = 50); i=2; output;
    %compose(invars = ANC AST ALT CREAT, outvar = col, lengths = 45); i=2; output;
    %compose(invars = ENDTREAT, outvar = col, lengths=150); i=3; output;
    %compose(invars = DEATHREA, outvar = col,lengths=150); i=3; output;

    keep subid col __title i;
run;

proc sort data=pre_dm; by SUBID i; run;

data pre_dm0;
    set pre_dm(rename=(col = in_col)) ;
        by subid i;
    length col1 $2000;
    retain col1;
    if first.i then col1 = in_col;
    else col1 = strip(col1) || "&escapechar.2n" || in_col;
    if last.i then output;
    
    drop in_col i;
run;

data pdata.dm(label='Demographics & Baseline');
    set pre_dm0 ;
        by subid;
    length col $2000;
    retain col;
    if first.subid then col = col1;
    else col = strip(col) || "&escapechar.4n" || col1;
    if last.SUBID then output;
    
    drop COL1;
run;

