/*********************************************************************
 Program Nmae: lab.sas
  @Author: Ken Cao
  @Initial Date: 2015/04/27

 
 This program is based on former ADLB.sas in DLRC project.
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

** Added 2015-04-30;
** Tumor Markers (Local);
data tumkrl;
    set source.tumkrl(rename=(lborres=__lborres lborresu=__lborresu lbtest=__lbtest));

    %subject;
    %visit2;

    length lborres lborresu $255;
    lborres = __lborres;
    if lbstat = 'Checked' then lborres = 'Not Reported';
    

    lborresu = coalescec(__lborresu, othunit);
    lborresu = ifc(upcase(__lborresu) = 'OTHER', othunit, __lborresu);

    length lbdtc lbtmc $20;
    %ndt2cdt(lbdat, lbdtc);
    %ntm2ctm(lbtim, lbtmc);

    length lbtest $200;
    lbtest = __lbtest;



    keep edc_treenodeid edc_entrydate edc_formlabel subject  visit2  lbdat lbdtc lbtmc lbnam lbtest  lborres lborresu symbol lbtimunk;
run;


** Hematology (Local);
data hematl;
    set source.hematl(rename=(lborres=__lborres lborresu=__lborresu lbtest=__lbtest));

    %subject;
    %visit2;

    length lborres lborresu $255;
    lborres = __lborres;
    if lbstat = 'Checked' then lborres = 'Not Reported';
    

    lborresu = coalescec(__lborresu, othunit);
    lborresu = ifc(upcase(__lborresu) = 'OTHER', othunit, __lborresu);

    length lbdtc lbtmc $20;
    %ndt2cdt(lbdat, lbdtc);
    %ntm2ctm(lbtim, lbtmc);

    length lbtest $200;
    lbtest = __lbtest;



    keep edc_treenodeid edc_entrydate edc_formlabel subject  visit2  lbdat lbdtc lbtmc lbnam lbtest  lborres lborresu symbol lbtimunk;
run;


** Serum Chemistry (Local);
data scheml;
    set source.scheml(rename=(lborres=__lborres lborresu=__lborresu lbtest=__lbtest));

    %subject;
    %visit2;

    length lborres lborresu $255;
    lborres = __lborres;
    if lbstat = 'Checked' then lborres = 'Not Reported';

    lborresu = ifc(upcase(__lborresu) = 'OTHER', othunit, __lborresu);

    length lbdtc lbtmc $20;
    %ndt2cdt(lbdat, lbdtc);
    %ntm2ctm(lbtim, lbtmc);

    length lbtest $200;
    lbtest = __lbtest;



     keep edc_treenodeid edc_entrydate edc_formlabel subject  visit2  lbdat lbdtc lbtmc lbnam lbtest  lborres lborresu symbol lbtimunk;
run;


**Thyroid Stimulating Hormone (Local);
data tshl;
/*    set source.tshl(rename=(lborres=__lborres lborresu=__lborresu LBNRIND=__LBNRIND lbtest=__lbtest));*/
    set source.tshl(rename=(lborres=__lborres lborresu=__lborresu lbtest=__lbtest));

    %subject;
    %visit2;

    length lborres lborresu $255;
    lborres = __lborres;
    if lbstat = 'Checked' then lborres = 'Not Reported';

    lborresu = ifc(upcase(__lborresu) = 'OTHER', othunit, __lborresu);

    length lbdtc lbtmc $20;
    %ndt2cdt(lbdat, lbdtc);
    %ntm2ctm(lbtim, lbtmc);
    
/*    length LBNRIND $20;*/
/*    if __LBNRIND = 'Checked' then LBNRIND = 'Abnormal';*/


    length lbtest $200;
    lbtest = __lbtest;

     keep edc_treenodeid edc_entrydate edc_formlabel subject  visit2  lbdat lbdtc lbtmc lbnam lbtest  lborres lborresu lbnrind symbol lbtimunk;
run;


** Urinalysis (Local);
data urinl;
    set source.urinl(rename=(lborres=__lborres lbtest=__lbtest));;
    %subject;
    %visit2;

    length lborres $255;
    lborres = __lborres;
    if lbstat = 'Checked' then lborres = 'Not Reported';
    if othres ^= ' ' then lborres = strip(lborres)||ifc(lborres^= ' ', ': ', '')||trim(othres);

    length lbdtc lbtmc $20;
    %ndt2cdt(lbdat, lbdtc);
    %ntm2ctm(lbtim, lbtmc);

    length lbtest $200;
    lbtest = __lbtest;
    
     keep edc_treenodeid edc_entrydate edc_formlabel subject  visit2  lbdat lbdtc lbtmc  lbtest lborres symbol lbtimunk;
run;


** Coagulation (Local);
data coagl;
    set source.coagl(rename=(lborres=__lborres lborresu=__lborresu lbtest=__lbtest));

    %subject;
    %visit2;

    length lborres lborresu $255;
    lborres = __lborres;
    if lbstat = 'Checked' then lborres = 'Not Reported';

    lborresu = ifc(upcase(__lborresu) = 'OTHER', othunit, __lborresu);

    length lbdtc lbtmc $20;
    %ndt2cdt(lbdat, lbdtc);
    %ntm2ctm(lbtim, lbtmc);

    length lbtest $200;
    lbtest = __lbtest;

     keep edc_treenodeid edc_entrydate edc_formlabel subject  visit2  lbdat lbdtc lbtmc lbnam lbtest  lborres lborresu symbol lbtimunk;
run;


** Creatinine Clearance (CrCl) (Local);
data crcl;
    set source.crcl(rename=(lborres=__lborres lborresu=__lborresu lbtest=__lbtest));

    %subject;
    %visit2;

    length lborres lborresu $255;
    lborres = __lborres;
    if lbstat = 'Checked' then lborres = 'Not Reported';

    lborresu = ifc(upcase(__lborresu) = 'OTHER', othunit, __lborresu);

    length lbdtc lbtmc $20;
    %ndt2cdt(lbdat, lbdtc);
    %ntm2ctm(lbtim, lbtmc);

    length lbtest $200;
    lbtest = __lbtest;

     keep edc_treenodeid edc_entrydate edc_formlabel subject  visit2  lbdat lbdtc lbtmc lbnam lbtest  lborres lborresu lbmethod symbol lbtimunk;
run;


** Hepatitis (Local);
data hepatl;
    set source.hepatl(rename=(lborres=__lborres lbtest=__lbtest));

    %subject;
    %visit2;

    length lborres $255;
    lborres = __lborres;

    if lbstat = 'Checked' then lborres = 'Not Reported';

    if othres ^= ' ' then lborres = strip(lborres)||ifc(lborres^= ' ', ': ', '')||trim(othres);

    length lbdtc lbtmc $20;
    %ndt2cdt(lbdat, lbdtc);
    %ntm2ctm(lbtim, lbtmc);

    length lbtest $200;
    lbtest = __lbtest;

    keep edc_treenodeid edc_entrydate edc_formlabel subject  visit2  lbdat lbdtc lbtmc lbnam lbtest  lborres  symbol lbtimunk;
run;




data lab;
    length subject $13 age 8 sex $50 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset: 'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('sex', 'age');
        rc = h.defineDone();
        declare hash h2 (dataset: 'pdata.rfstdtc');
        rc2 = h2.defineKey('subject');
        rc2 = h2.defineData('rfstdtc');
        rc2 = h2.defineDone();
        call missing(subject, sex, age, rfstdtc);
    end;

    set 
        coagl(in=__coagl)
        crcl(in=__crcl)
        hematl(in=__hematl)
        hepatl(in=__hepatl)
        scheml(in=__scheml)
        tshl(in=__tshl)
        urinl(in=__urinl)
        /** Added 2015-04-30;*/
        tumkrl(in=__tumkrl)
    ;

    length rawunit rawcat rawtest2 rawtest $255;
    rawunit = strip(upcase(lborresu));
    rawtest = strip(upcase(lbtest));
    rawtest2 = lbtest;

    __Result = 0;
    %IsNumeric(InStr=lborres, Result=__Result);
    if __Result = 1 then lborresn = input(lborres, best.);
    drop __Result;

    if __coagl then rawcat = 'COAGULATION';
    else if __crcl then rawcat = 'CREATININE CLEARANCE';
    else if __hematl then rawcat = 'HEMATOLOGY';
    else if __hepatl then rawcat = 'HEPATITIS';
    else if __scheml then rawcat = 'SERUM CHEMISTRY';
    else if __tshl then rawcat = 'THYROID STIMULATING HORMONE';
    else if __urinl then rawcat = 'URINALYSIS';
    else if __tumkrl then rawcat = compbl(tranwrd(upcase(edc_formlabel), '(LOCAL)', ''));

    rc = h.find();
    drop rc;

    rc2 = h2.find();
    %concatDY(lbdtc);

    sex = upcase(sex);

    drop lborresu lbtest;


    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
    rename edc_formlabel = __edc_formlabel;
run;


proc sql;
    create table lb_master_c as
    select * 
    from source.lb_master
    where 0
    ;
   /**modified by LDG 2015-04-23**/
    insert into lb_master_c (rawcat, rawtest, rawunit,lbcat, lbtest, lbtestcd, lbstresu, cf)
    values('CREATININE CLEARANCE', 'CREATININE CLEARANCE (CRCL)', 'ML/MIN', 'CHEMISTRY', 'Creatinine Clearance', 'CREATCLR', 'mL/s', 0.0166666667)
    values('COAGULATION', 'INR', 'UNITLESS', 'COAGULATION', 'Prothrombin Intl. Normalized Ratio', 'INR', 'RATIO', 1)
    values('THYROID STIMULATING HORMONE', 'TSH', 'UIU/ML', 'CHEMISTRY', 'Thyrotropin', 'TSH', 'mU/L', 1)
    values('THYROID STIMULATING HORMONE', 'TSH', 'MIU/L', 'CHEMISTRY', 'Thyrotropin', 'TSH', 'mU/L', 1)
    values('THYROID STIMULATING HORMONE', 'TSH', '', 'CHEMISTRY', 'Thyrotropin', 'TSH', '', 1)
    values('THYROID STIMULATING HORMONE', 'T3', 'NG/DL', 'CHEMISTRY', 'Triiodothyronine', 'T3', 'nmol/L', 0.0154)
    values('THYROID STIMULATING HORMONE', 'FREE T4', 'NG/DL', 'CHEMISTRY', 'Thyroxine, Free', 'T4FR', 'pmol/L', 12.87)
    values('HEPATITIS', 'HEP C PCR', '', 'IMMUNOLOGY', 'HCV Viral Load', 'HCVVLD', '', 1)
    values('HEPATITIS', 'HEP B PCR', '', 'IMMUNOLOGY', 'HBV Viral Load', 'HBVVLD', '', 1)
    values('COAGULATION', 'APTT', 'SEC', 'COAGULATION', 'Activated Partial Thromboplastin Time', 'APTT', 'sec', 1)
   /** Added 2015-04-30;*/
    values('TUMOR MARKERS - BREAST CANCER', 'CA 15-3', '', 'IMMUNOLOGY', 'Cancer Antigen 15-3', 'CA15_3AG', '', 1)
    values('TUMOR MARKERS - BREAST CANCER', 'CA 27.29', 'U/ML', 'IMMUNOLOGY', 'Cancer Antigen 27-29', 'CA2729AG', 'kU/L', 1)
    values('TUMOR MARKERS - NSCLC', 'CA-125', 'U/ML', 'IMMUNOLOGY', 'Cancer Antigen 125', 'CA125AG', 'kU/L', 1)
    values('TUMOR MARKERS - NSCLC', 'CARCINOEMBRYONIC ANTIGEN (CEA)', 'U/ML', 'IMMUNOLOGY', 'Carcinoembryonic Antigen', 'CEA', 'kU/L', 1)
    values('TUMOR MARKERS - PANCREATIC CANCER', 'CA 19-9', 'U/ML', 'IMMUNOLOGY', 'Cancer Antigen 19-9', 'CA19_9AG', 'kU/L', 1)
    
   /** Added 2015-05-04;*/
    values('HEMATOLOGY', 'BANDS', '', 'HEMATOLOGY', 'Neutrophils Band Form', 'NEUTB', '10^9/L', 1)
   /** Added 2015-05-05;*/
    values('COAGULATION', 'INR', '', 'COAGULATION', 'Prothrombin Intl. Normalized Ratio', 'INR', 'RATIO', 1)
   /** Added 2015-05-06;*/
    values('TUMOR MARKERS - BREAST CANCER', 'CA 15-3', 'U/ML', 'IMMUNOLOGY', 'Cancer Antigen 15-3', 'CA15_3AG', 'kU/L', 1)
    values('TUMOR MARKERS - BREAST CANCER', 'CA 15-3', '', 'IMMUNOLOGY', 'Cancer Antigen 15-3', 'CA15_3AG', '', 1)


    ;
quit;


data lb_master;
    set source.lb_master lb_master_c;
run;



** Get standard unit/test/test code/conversion factor from LB_MASTER;
data lab2(drop=notfound /*drop=rawcat rawtest rawunit*/) _chkMaster(keep=rawcat rawtest rawunit lborres);
    length rawcat lbcat rawtest rawunit $255  lbtest lbtestcd lbstresu $40 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'lb_master');
        rc = h.defineKey('rawcat', 'rawtest', 'rawunit');
        rc = h.defineData('lbstresu', 'cf', 'lbtest', 'lbcat', 'lbtestcd');
        rc = h.defineDone();
        call missing(rawcat, rawtest, rawunit, lbstresu, cf, lbcat, lbtest, lbtestcd);
    end;
    set lab;
    notfound = h.find();
    drop rc ;

    length lbstresn 8 lbstresc $255;
    if n(lborresn, cf) = 2 then lbstresn = lborresn * cf;

    if lbstresn > . then lbstresc = strip(put(round(lbstresn, 0.001), best.)); else
        lbstresc = lborres;

    if symbol ^= ' ' then lbstresc = strip(vvaluex('symbol'))||lbstresc;

    if lborresn = . and lborres not in ('Not Reported', ' ') and cf not in (1, .) then do;
        put "WARN" "ING: Check those values: " rawcat= +3 rawtest= rawunit= +3 lbstresu= +3 lborres= +3 cf=;
    end;

    output lab2;
    if notfound and  lborres not in ('Not Reported', ' ')  then output _chkMaster;
run;
***********************************************************************;

** Check if any failure ;
proc sort data=_chkMaster nodupkey;
    by rawcat rawtest rawunit lborres;
run;

data _null_;
    set _chkMaster;
    put "WARN" "ING: Not found in LB_MASTER: " rawcat= rawtest= rawunit= lborres=;
run;
***********************************************************************;



**** For Hema ---LE tests;
proc sort data=lb_master out=_hemalestd0 (keep=rawcat rawtest lbtest lbtestcd lbstresu) nodupkey;
    by lbtestcd lbstresu;
    where lbtestcd in ('NEUTSG', 'NEUTB', 'LYM', 'MONO', 'EOS', 'BASO') ;
run;

data _hemalestd;
    set _hemalestd0;
        by lbtestcd;
    if last.lbtestcd;
run;


data _hemale _hemawbc(rename=(lbstresn=__wbc));
    set lab2;
    where rawcat='HEMATOLOGY' and lbtestcd in ('WBC', 'NEUTSGLE', 'NEUTBLE', 'LYMLE', 'MONOLE', 'EOSLE', 'BASOLE');
    keep __edc_treenodeid lbtestcd lbtest rawtest lbstresn lbstresc  ;
    if lbtestcd = 'WBC' then output _hemawbc;
    else output _hemale;
run;

data _hemale2;
    length __edc_treenodeid $36 __wbc 8 lbtestcd lbstresu $40 rawcat rawtest $255;
    if _n_ = 1 then do;
        declare hash h (dataset: '_hemawbc');
        rc = h.defineKey('__edc_treenodeid');
        rc = h.defineData('__wbc');
        rc = h.defineDone();
        declare hash h2 (dataset: '_hemalestd');
        rc2 = h2.defineKey('lbtestcd');
        rc2 = h2.defineData('lbstresu', 'rawcat', 'rawtest', 'lbtest');
        rc2 = h2.defineDone();

        call missing(__edc_treenodeid, __wbc, lbtestcd, lbstresu, rawcat, rawtest);
    end;
    set _hemale;
    rc = h.find();
    if n(lbstresn, __wbc)=2 then lbstresn = lbstresn / 100 * __wbc;

    lbtestcd = substr(lbtestcd, 1, length(lbtestcd)-2);
    rc2 = h2.find();

    keep __edc_treenodeid lbtestcd lbstresc lbstresn lbstresu rawcat rawtest lbtest;

run;


data lab3;
    set lab2;
    if lbtestcd in ('NEUTSGLE', 'NEUTBLE', 'LYMLE', 'MONOLE', 'EOSLE', 'BASOLE') then 
        lbtestcd = substr(lbtestcd, 1, length(lbtestcd)-2);

run;

proc sort data=lab3; by __edc_treenodeid lbtestcd; run;
proc sort data=_hemale2; by __edc_treenodeid lbtestcd; run;

data lab4;
    merge lab3(in=a) _hemale2(in=b);
        by __edc_treenodeid lbtestcd;
    *if a and b then flag = 1;
run;













** LBRANGE;
data lbrange0; 
    length sex $10;
    set source.lbrange;
    ** Ken Cao on 2015/04/15: Get local lab data;
    where lbtestcd ^= ' ' ;
    
    length agelow agehigh 8;
    agehigh = ifn(age_high_ = ., 1000, age_high_);
    agelow = ifn(input(age_low_, best.) = ., 0, input(age_low_, best.));
    *agelow = input(age_low_, best.);
    if symbol_age_low_ = '>' then agelow = agelow + 0.01;
    if age_low_ = ' ' then agelow = .;

    length lbstresu $40 lbstnrlo lbstnrhi 8;
    lbstnrhi = PCYC_HIGH_RANGE_LBSTNRHI;
    lbstnrlo = PCYC_LOW_RANGE_LBSTNRLO_;
    lbstresu = LBSTRESU_PCYC_Standard_Units;



    SYMBOL_RANGE_LOW = strip(SYMBOL_RANGE_LOW);
    SYMBOL_RANGE_HIGH = strip(SYMBOL_RANGE_HIGH);

    if SYMBOL_RANGE_LOW = '<' and lbstnrlo > . then lbstnrlo = lbstnrlo - 10E-7;
    if SYMBOL_RANGE_HIGH = '<' and lbstnrhi > . then lbstnrhi = lbstnrhi - 10E-7;

    if SYMBOL_RANGE_LOW not in ('<', ' ') or SYMBOL_RANGE_HIGH not in ('<', ' ') then do;
        put "WARN" "ING: LBRANGE symbol: " lbtest= symbol_range_low= pcyc_low_range_lbstnrlo_= symbol_range_high= pcyc_high_range_lbstnrhi=;
    end;

    SEX = SEX__;    

    if SEX = ' ' or SEX = 'BOTH' then do;
        sex = 'FEMALE';
        output;
        sex = 'MALE';
        output;
        sex = ' ';
        output;
    end;
    else output;


    keep  lbtestcd lbtest lbcat lbspec lbmethod sex agelow agehigh lbstresu lbstnrlo lbstnrhi comments
          symbol_range_high pcyc_high_range_lbstnrhi symbol_range_low pcyc_low_range_lbstnrlo_ ;
run;

proc sort data=lbrange0 nodupkey;
    by lbcat lbtest lbstresu sex agelow agehigh;
run;

proc sql;
    create table lbrangec as
    select *
    from lbrange0
    where 0;
   /**modified by LDG 2015-04-23**/
    insert into lbrangec (lbcat, lbtest, lbstresu, sex, agelow, agehigh, pcyc_high_range_lbstnrhi, pcyc_low_range_lbstnrlo_)
    values('COAGULATION', 'Prothrombin Intl. Normalized Ratio', '', 'MALE', 0, 1000, 0.9, 1.2)
    values('COAGULATION', 'Prothrombin Intl. Normalized Ratio', '', 'FEMALE', 0, 1000, 0.9, 1.2)
    values('URINALYSIS', 'Specific Gravity', '', 'FEMALE', 0, 1000, 1.002, 1.03)
    values('URINALYSIS', 'Specific Gravity', '', 'MALE', 0, 1000, 1.002, 1.03)
    values('URINALYSIS', 'pH', '', 'MALE', 0, 1000, 4.6, 8)
    values('URINALYSIS', 'pH', '', 'FEMALE', 0, 1000, 4.6, 8)
    ;
quit;

data lbrange;
    set lbrange0 lbrangec;
    length flag $1;
    flag = 'Y';

    length __low __high lbstnr $255;
    if pcyc_low_range_lbstnrlo_ ^=. then __low = strip(symbol_range_low)||strip(vvaluex('pcyc_low_range_lbstnrlo_'));
    if pcyc_high_range_lbstnrhi ^=. then __high  = strip(symbol_range_high)||strip(vvaluex('pcyc_high_range_lbstnrhi'));
    
    if __low ^= ' ' or __high^= ' ' then lbstnr = trim(__low)||'-'||trim(__high);

    drop __low __high;
run;


proc sql;
    create table lab5 as
    select a.*, b.lbstnrlo, b.lbstnrhi, b.flag, b.lbstnr
    from lab4 as a left join lbrange as b
    on a.lbcat = b.lbcat
    and a.lbtest = b.lbtest
    and upcase(a.lbstresu) = upcase(b.lbstresu)
    and a.sex = b.sex
    and b.agelow <= a.age <= b.agehigh;
;
quit;

proc sort data=lab5 out = _chkRange nodupkey;
    by lbcat lbtest lbstresu;
    where flag = ' ' and lbstresn ^=. ;
run;

data _null_;
    set _chkRange;
    put "WARN" "ING: Range not found: " lbcat= +3 lbtest= +3 lbstresu= +3 sex= +3 age=;
run;



data lab6;
    set lab5;
    length __lbstnr $1;
    if lbstresn ^=. and n(lbstnrlo, lbstnrhi) >= 1 then do;
        if lbstresn < lbstnrlo then __lbstnr = 'L';
        else if lbstresn > ifn(lbstnrhi=., 1E99, lbstnrhi) then __lbstnr = 'H';
    end;
    drop flag;
run;

proc sort data=lab6; by lbtest lbstresu; run;
proc sort data=source.lbgrade out=lbgrade; by lbtest lbstresu; run;


data lab7;
    merge lab6(in=a) lbgrade ;
        by lbtest lbstresu;
    array gl(4) gl1-gl4;
    array gh(4) gh1-gh4;
    array l(4) l1-l4;
    array h(4) h1-h4;
    do i=1 to 4;
        if l(i)='LLN' then gl(i)=lbstnrlo; else if l(i)^='' then gl(i)=input(l(i), best.);
        if h(i)='ULN' then gh(i)=lbstnrhi; else if h(i)^='' then gh(i)=input(h(i), best.);
        if Multiplier='N' and gl(i)^=. and LBSTRESN^=. and LBSTRESN<gl(i) then LBTOXGR0=i;
        else if Multiplier='Y' and i=1 and gl(1)^=. and LBSTRESN^=. and LBSTRESN<gl(1) then LBTOXGR0=1;
        else if Multiplier='Y' and i^=1 and gl(1)^=. and gl(i)^=. and LBSTRESN^=. and LBSTRESN<gl(i)*gl(1) then LBTOXGR0=i;
        if Multiplier='N' and gh(i)^=. and LBSTRESN^=. and gh(i)<LBSTRESN then LBTOXGR0=i;
        else if Multiplier='Y' and i=1 and gh(1)^=. and LBSTRESN^=. and gh(1)<LBSTRESN then LBTOXGR0=1;
        else if Multiplier='Y' and i^=1 and gh(1)^=. and gh(i)^=. and LBSTRESN^=. and gh(i)*gh(1)<LBSTRESN then LBTOXGR0=i;

        if LBTOXGR0 ^= .  and __lbstnr ^= ' ' then do;
            if lbstresn < gl[1]  then __lbstnr = 'L';
            else if lbstresn < gh[1]  then __lbstnr = 'H';
        end;

    end;
  if LBTOXGR0 ^=. then LBTOXGR = trim(left(put(LBTOXGR0, best.)));

  if a;


    **************for for Uric Acid grade, assign grade 1 for higher than ULN and <590umol/l*******;
    if lbtestcd = 'URATE' then do;
        lbtoxgr = '';
        if 590>lbstresn > lbstnrhi >. then lbtoxgr = '1';
        else if 590< lbstresn then lbtoxgr = '4';
    end;

    drop gl1-gl4 gh1-gh4 l1-l4 h1-h4  Multiplier i deltal deltah hs labtest LBTOXGR0;
run;





data lab8;
    length lbstresc $255;
    set lab7(rename=(lbstresu=__lbstresu lbstresc=__lbstresc));

    if lbstresn > . then lbstresc = put(round(lbstresn, 0.001), best.);
       else if __lbstresc ^= '' then lbstresc = __lbstresc;


    if __lbstnr = 'L' then lbstresc = "&escapeChar.S={foreground=&belowcolor}"||strip(lbstresc)||' [L';
    else if __lbstnr = 'H' then lbstresc = "&escapeChar.S={foreground=&abovecolor}"||strip(lbstresc)||' [H';


    if lbtoxgr ^= ' ' then lbstresc = strip(lbstresc)||':'||strip(lbtoxgr);
    if __lbstnr ^= ' ' then lbstresc = strip(lbstresc)||']';

    /*
    length lbstnr $255;
    if n(lbstnrlo, lbstnrhi) > 0 then do;
        lbstnr = ifc(lbstnrlo ^=., strip(vvaluex('lbstnrlo')), ' ' )||' - '||ifc(lbstnrhi ^=., strip(vvaluex('lbstnrhi')), ' ' );
    end;
    if symbol_range_high ^= '' and lbstnrlo = . and lbstnrhi ^= . then lbstnr = strip(symbol_range_high) || ' ' || strip(vvaluex('lbstnrhi'));
    */


    ** Expand length to 255 for later use;
    length lbstresu $255;
    lbstresu = __lbstresu;


    ** For unrine;
    if rawcat = 'URINALYSIS' then lbtestcd='U'||lbtestcd;
run;




*****************************************************************************;
* Put standard unit and standard range in the first two rows of each subject
*****************************************************************************;
proc sort data=lab8; 
    by __edc_treenodeid __edc_entrydate __edc_formlabel subject visit2 lbdtc lbtmc lbnam lbtimunk symbol LBMETHOD LBNRIND rawcat lbtestcd rawtest2;
run;


proc transpose data=lab8 out=t_lab0;
/*    by __edc_treenodeid __edc_entrydate __edc_formlabel subject visit2 lbdtc lbtmc lbnam lbtimunk symbol LBMETHOD LBNRIND rawcat;*/
    by __edc_treenodeid __edc_entrydate __edc_formlabel subject visit2 lbdtc lbtmc lbnam lbtimunk /*symbol*/ LBMETHOD LBNRIND rawcat;
    id lbtestcd;
    idlabel rawtest2;
    var lbstresc;
run;

proc sort data=lab8 nodupkey out=lab9_1(keep=subject rawcat lbtestcd rawtest2 lbstresu lbstnr ) ; 
    by subject rawcat lbtestcd rawtest2;
    where lbstresu ^= ' ' or lbstnr ^= ' ';
run;

proc sort data=lab8 nodupkey out=lab9_2(keep=subject rawcat lbtestcd rawtest2) ; 
    by subject rawcat lbtestcd rawtest2;
run;

data lab9;
    merge lab9_2 lab9_1;
        by subject rawcat lbtestcd rawtest2;

run;



** For lab standard unit and normal range;
proc transpose data=lab9 out=t_lab1;
    by subject rawcat;
    id lbtestcd;
    idlabel rawtest2;
    var lbstresu lbstnr;
run;

proc sort data=t_lab0; by subject rawcat; run;
proc sort data=t_lab1; by subject rawcat; run;

data t_lab3;
    set t_lab1(in=__in1) t_lab0(in=__in2);
        by subject rawcat;
    if __in1 then do;
        if _NAME_ = 'LBSTRESU' then do;
            __ord = 0;
            __edc_treenodeid = ' 0-'||strip(subject)||'-Unit';
        end;
        else if _NAME_ = 'LBSTNR' then do;
            __ord = 1;
            __edc_treenodeid = ' 1-'||strip(subject)||'-NR';
        end;
    end;
    else __ord = 2;

    label lbdtc ="Sample Date"
          lbtmc ="Sample Time"
          lbtimunk = 'Time Unknown'
        ;
run;

proc sort data = t_lab3; by rawcat subject __ord lbdtc lbtmc; run;




*****************************************************************************;
* Generate final datasets
*****************************************************************************;

data pdata.coagl(label='Coagulation (Local Lab)');
    retain __EDC_TREENODEID __EDC_ENTRYDATE subject __edc_formlabel __ord visit2 lbdtc lbtmc lbtimunk lbnam pt aptt inr;
    keep __EDC_TREENODEID __EDC_ENTRYDATE subject __edc_formlabel __ord visit2 lbdtc lbtmc lbtimunk lbnam pt aptt inr  ;

    set t_lab3;
    where rawcat = 'COAGULATION';
run;


data pdata.crcl(label='Creatinine Clearance (Local Lab)');
    retain __edc_treenodeid __edc_entrydate subject __edc_formlabel __ord visit2 lbdtc lbtmc lbtimunk lbnam LBMETHOD creatclr;
    keep __edc_treenodeid __edc_entrydate subject __edc_formlabel __ord visit2 lbdtc lbtmc lbtimunk lbnam LBMETHOD creatclr;

    set t_lab3;
    where rawcat = 'CREATININE CLEARANCE';
run;


data pdata.hematl1(label='Hematology (Local Lab)');
    retain __edc_treenodeid __edc_entrydate subject __edc_formlabel __ord visit2 lbdtc lbtmc lbtimunk lbnam wbc rbc hgb hct plat;
    keep __edc_treenodeid __edc_entrydate subject __edc_formlabel __ord visit2 lbdtc lbtmc lbtimunk lbnam wbc rbc hgb hct plat;

    set t_lab3;
    where rawcat = 'HEMATOLOGY';
run;

data pdata.hematl2(label='Hematology (Local Lab) (Continued)');
    retain __edc_treenodeid __edc_entrydate subject __edc_formlabel __ord visit2 lbdtc lbtmc lbtimunk neutsg lym mono eos baso neutb;
    keep __edc_treenodeid __edc_entrydate subject __edc_formlabel __ord visit2 lbdtc lbtmc lbtimunk neutsg lym mono eos baso neutb;

    set t_lab3;
    where rawcat = 'HEMATOLOGY';
run;

data pdata.hepatl1(label='Hepatitis (Local Lab)');
    retain __EDC_TREENODEID __EDC_ENTRYDATE __edc_formlabel subject visit2 lbdtc lbtmc lbtimunk lbnam hbsag hbsab;
    keep __EDC_TREENODEID __EDC_ENTRYDATE __edc_formlabel subject visit2 lbdtc lbtmc lbtimunk lbnam hbsag hbsab;

    set t_lab3;
    where rawcat = 'HEPATITIS' and __ord = 2;
run;

data pdata.hepatl2(label='Hepatitis (Local Lab) (Continued)');
    retain __EDC_TREENODEID __EDC_ENTRYDATE __edc_formlabel subject visit2 lbdtc lbtmc lbtimunk hbcab hcab hbvvld hcvvld;
    keep __EDC_TREENODEID __EDC_ENTRYDATE __edc_formlabel subject visit2 lbdtc lbtmc lbtimunk hbcab hcab hbvvld hcvvld;

    set t_lab3;
    where rawcat = 'HEPATITIS' and __ord = 2;
run;

data pdata.scheml1(label='Serum Chemistry (Local Lab)');
    retain __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk lbnam sodium k cl bicarb bun creat gluc ca prot ;
    keep __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk lbnam sodium k cl bicarb bun creat gluc ca prot ;

    set t_lab3;
    where rawcat = 'SERUM CHEMISTRY';
run;


data pdata.scheml2(label='Serum Chemistry (Local Lab) (Continued)');
    retain __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk alb ast alt alp bili ldh mg phos urate  ;
    keep __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk alb ast alt alp bili ldh mg phos urate  ;

    set t_lab3;
    where rawcat = 'SERUM CHEMISTRY';
run;

** Modified 2015-04-30;
data pdata.tshl(label='Thyroid Stimulating Hormone (Local)');
    retain __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk lbnam tsh t3 t4fr lbnrind;
    keep __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk lbnam tsh t3 t4fr lbnrind;

    set t_lab3;
    where rawcat = 'THYROID STIMULATING HORMONE';
    label lbnrind = 'Abnormal'; 
run;


data pdata.urinl(label='Urinalysis (Local)');
    retain __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk uspgrav uph ugluc ubili uketones ublood uprot;
    keep  __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk uspgrav uph ugluc ubili uketones ublood uprot;

    set t_lab3;
    where rawcat = 'URINALYSIS';
run;

/** Added 2015-04-30;*/
data pdata.tumkrl1(label='Tumor Markers (Local) - Breast Cancer');
    retain __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk lbnam ca15_3ag ca2729ag;
    keep __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk lbnam ca15_3ag ca2729ag;

    set t_lab3;
    where rawcat = 'TUMOR MARKERS - BREAST CANCER';
run;

data pdata.tumkrl2(label='Tumor Markers (Local) - NSCLC');
    retain __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk lbnam ca125ag cea;
    keep __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk lbnam ca125ag cea;
    ca125ag = ''; cea = '';
    set t_lab3;
    label ca125ag = 'CA-125'
          cea = 'Carcinoembryonic Antigen (CEA)';
    where rawcat = 'TUMOR MARKERS - NSCLC';
run;

data pdata.tumkrl3(label='Tumor Markers (Local) - Pancreatic Cancer');
    retain __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk lbnam ca19_9ag;
    keep __edc_treenodeid __edc_entrydate __edc_formlabel subject __ord visit2 lbdtc lbtmc lbtimunk lbnam ca19_9ag;

    set t_lab3;
    where rawcat = 'TUMOR MARKERS - PANCREATIC CANCER';
run;



