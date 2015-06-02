/*********************************************************************
 Program Nmae: lab.sas
  @Author: Ken Cao
  @Initial Date: 2015/04/27
 
     LBCHEM
     LBCHIM
     LBCOAG
     LBHEM
     LBHEP
     LBIMUNO
     LBSUPP   
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data _lbchem;
    set source.lbchem(rename=(lborres=__lborres));
    length rawcat $255 rawtest rawtest2 $255 rawunit $255 lborres $255;
    rawcat = upcase(lbcat);
    rawtest = upcase(lbtest);
    rawtest2 = lbtest;
    rawunit = upcase(coalescec(lbunito, lborresu));

    lborres = __lborres;
    if lbnr ^= ' ' then lborres = 'Not Reported';

    keep edc_treenodeid subject visit visday lbtmunk lbcode unsseq seq lbdt lbtm edc_entrydate rawcat rawtest rawtest2 rawunit lborres lbsymb;
run;



data _lbchim;
    set source.lbchim(rename=(lborres=__lborres));
    length rawcat $255 rawtest rawtest2 $255 rawunit $255 lborres $255;
    rawcat = upcase(lbcat);
    rawtest = upcase(lbtest);
    rawtest2 = lbtest;
    rawunit = upcase(coalescec(lbunito, lborresu));

    lborres = __lborres;
    if lbnr ^= ' ' then lborres = 'Not Reported';

    keep edc_treenodeid subject visit lbtmunk lbcode unsseq seq lbdt lbtm edc_entrydate rawcat rawtest rawtest2 rawunit lborres lbsymb; 
run;


data _lbcoag;
    set source.lbcoag(rename=(lborres=__lborres));
    length rawcat $255 rawtest rawtest2 $255 rawunit $255 lborres $255;
    rawcat = upcase(lbcat);
    rawtest = upcase(lbtest);
    rawtest2 = lbtest;
    rawunit = upcase(coalescec(lbunito, lborresu));

    lborres = __lborres;
    if lbnr ^= ' ' then lborres = 'Not Reported';

    keep edc_treenodeid subject visit lbtmunk lbcode unsseq  lbdt lbtm edc_entrydate rawcat rawtest rawtest2 rawunit lborres lbsymb; 
run;


data _lbhem;
    set source.lbhem(rename=(lborres=__lborres));
    length rawcat $255 rawtest rawtest2 $255 rawunit $255 lborres $255;
    rawcat = upcase(lbcat);
    rawtest = upcase(lbtest);
    rawtest2 = lbtest;
    rawunit = upcase(coalescec(lbunito, lborresu));

    lborres = __lborres;
    if lbnr ^= ' ' then lborres = 'Not Reported';

    keep edc_treenodeid subject visit visday lbtmunk lbcode unsseq seq lbdt lbtm edc_entrydate rawcat rawtest rawtest2 rawunit lborres lbsymb
        lbacelyn lbacelsp;
run;



data _lbhep;
    set source.lbhep(rename=(lborres=__lborres));
    length rawcat $255 rawtest rawtest2 $255 rawunit $255 lborres $255;
    rawcat = upcase(lbcat);
    rawtest = upcase(lbtest);
    rawtest2 = lbtest;
    rawunit = ' ';


    lborres = __lborres;
    if lborreso ^= ' ' then lborres = strip(lborres)||ifc(lborres ^= ' ', ', Other Result: ', '')||lborreso;
    if lbnr ^= ' ' then lborres = 'Not Reported';

    keep edc_treenodeid subject visit  lbtmunk lbcode unsseq  lbdt lbtm edc_entrydate rawcat rawtest rawtest2 rawunit lborres;
run;



data _lbimuno;
    set source.lbimuno(rename=(lborres=__lborres));
    length rawcat $255 rawtest rawtest2 $255 rawunit $255 lborres $255;
    rawcat = upcase(lbcat);
    rawtest = upcase(lbtest);
    rawtest2 = lbtest;
    rawunit = upcase(coalescec(lbunito, lborresu));

    lborres = __lborres;
    if lbnr ^= ' ' then lborres = 'Not Reported';

    keep edc_treenodeid subject visit  lbtmunk lbcode unsseq seq lbdt lbtm edc_entrydate rawcat rawtest rawtest2 rawunit lborres lbsymb;
run;



data _lbsupp;
    set source.lbsupp(rename=(lborres=__lborres));
    length rawcat $255 rawtest rawtest2 $255 rawunit $255 lborres $255;
    rawcat = upcase(lbcat);
    
    rawtest = lbtest;
    *if rawtest = 'Other' and lbtesto ^= ' ' then rawtest = lbtesto;
    rawtest2 = rawtest;
    rawtest = upcase(rawtest);

    rawunit = upcase(coalescec(lbunito, lborresu));

    lborres = __lborres;
    if lbnr ^= ' ' then lborres = 'Not Reported';

    keep edc_treenodeid subject visit  lbtmunk lbcode unsseq  lbdt lbtm edc_entrydate rawcat rawtest rawtest2 rawunit lborres lbsymb lbtesto;
run;



data lab0;
    length subject $13 __rfstdtc $10 sex $7 __age 8;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc', 'sex', '__age');
        rc = h.defineDone();
        call missing(subject, __rfstdtc, sex, __age);
    end;
    set 
        _lbchem
        _lbchim
        _lbcoag
        _lbhem
        _lbhep
        _lbimuno
        _lbsupp 
    ;

    %subject;
    %visit2;

    rc = h.find();

    length lbdtc $20 lbtmc $10;
    %ndt2cdt(ndt=lbdt, cdt=lbdtc);
    %concatDY(lbdtc);

    %ntime2ctime(ntime=lbtm, ctime=lbtmc);
/*    if lbtmunk ^= ' ' then lbtmc = 'Unknown';*/


    length lborresn 8;
    %IsNumeric(InStr=lborres, Result=__Result);
    if __Result = 1 then lborresn = input(lborres, best.);
    

    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;


    keep edc_treenodeid subject lbcode edc_entrydate rawcat rawtest rawtest2 rawunit lborres visit2 lbdtc lbtmc sex __age lborresn lbsymb lbtmunk
         lbacelyn lbacelsp lbtesto;
run;


*****************************************************************************;
* Get stanadard test name and stanard unit (as well as CF) from LB_MASTER
*****************************************************************************;

proc sql;
    create table lb_master_c as
    select * 
    from source.lb_master
    where 0
    ;
    
    insert into lb_master_c (rawcat, rawtest, rawunit,lbcat, lbtest, lbtestcd, lbstresu, cf)
    values('SERUM CHEMISTRY (LOCAL)', 'BUN', 'MMOL/L', 'CHEMISTRY', 'Blood Urea Nitrogen', 'BUN', 'MMOL/L', 1)
    values('IMMUNOSUPPRESSANT LEVEL (LOCAL)', 'CYCLOSPORIN A', 'NO RANGE FOUND', 'CHEMISTRY', 'Immunosuppressant Level', 'IMMSUP', 'OTHER', 1)

    ;
quit;

data lb_master;
    set source.lb_master lb_master_c;
run;



data lab1(drop=notfound ) _chkMaster(keep=rawcat rawtest rawunit);
    length rawcat lbcat rawtest rawunit $255  lbtest lbtestcd lbstresu $40 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'lb_master');
        rc = h.defineKey('rawcat', 'rawtest', 'rawunit');
        rc = h.defineData('lbstresu', 'cf', 'lbtest', 'lbcat', 'lbtestcd');
        rc = h.defineDone();
        call missing(rawcat, rawtest, rawunit, lbstresu, cf, lbcat, lbtest, lbtestcd);
    end;
    set lab0;
    notfound = h.find();
    drop rc ;

    length lbstresn 8 lbstresc $255;
    if n(lborresn, cf) = 2 then lbstresn = lborresn * cf;
    lbstresc = ifc(lbstresn > ., strip(put(lbstresn, best.)), lborres);
    if lbsymb ^= ' ' then lbstresc = strip(vvaluex('lbsymb'))||lbstresc;


    ** Only for 1129;
    if rawcat = 'IMMUNOSUPPRESSANT LEVEL (LOCAL)' then lbcat = 'CHEMISTRY';

    output lab1;
    if notfound then output _chkMaster;
run;


proc sort data=_chkMaster nodupkey;
    by rawcat rawtest rawunit;
run;

data _null_;
    set _chkMaster;
    put "WARN" "ING: Not found in LB_MASTER: " rawcat= rawtest= rawunit=;
run;



*****************************************************************************;
* Get standard normal range from  LBRANGE.
*****************************************************************************;
data lbrange0;
    set source.lbrange;
    ** Ken Cao on 2015/04/15: Get local lab data;
    where lbtestcd ^= ' ' ;
    
    length agelow agehigh 8;
    agehigh = ifn(age_high = ., 1000, age_high);
    agelow = ifn(age_low = ., 0, age_low);
    if symbol_age_low = '>' then agelow = agelow + 0.01;

    if SYMBOL_RANGE_LOW = '<' and lbstnrlo > . then lbstnrlo = lbstnrlo - 10E-7;
    if SYMBOL_RANGE_HIGH = '<' and lbstnrhi > . then lbstnrhi = lbstnrhi - 10E-7;

    if SYMBOL_RANGE_LOW not in ('<', ' ') or SYMBOL_RANGE_HIGH not in ('<', ' ') then do;
        put "WARN" "ING: LBRANGE symbol: " lbtest= symbol_range_low= lbstnrlo= symbol_range_high= lbstnrhi=;
    end;


    if sex = ' ' or sex = 'BOTH' then do;
        sex = 'Female';
        output;
        sex = 'Male';
        output;
    end;
    else do;
        sex = propcase(sex);
        output;
    end;

    keep  lbtestcd lbtest lbcat lbspec lbmethod sex agelow agehigh lbstresu lbstnrlo lbstnrhi comments 
         symbol_range_high lbstnrlo symbol_range_low lbstnrhi ;
run;

proc sort data=lbrange0 nodupkey;
    by lbcat lbtest lbstresu sex agelow agehigh;
run;

proc sql;
    create table lbrangec as
    select *
    from lbrange0
    where 0;

    /* 
    insert into lbrangec (lbcat, lbtest, lbstresu, sex, agelow, agehigh, lbstnrlo, lbstnrhi)
    values('URINALYSIS', 'Specific Gravity', '', 'Female', 0, 1000, 1.002, 1.03)
    values('URINALYSIS', 'Specific Gravity', '', 'Male', 0, 1000, 1.002, 1.03)
    */
    ;
quit;

data lbrange;
    set lbrange0 lbrangec;
    
    length flag $1;
    flag = 'Y';

    length __low __high lbstnr $255;
    if lbstnrlo ^=. then __low = strip(symbol_range_low)||strip(vvaluex('lbstnrlo'));
    if lbstnrhi ^=. then __high  = strip(symbol_range_high)||strip(vvaluex('lbstnrhi'));
    
    if __low ^= ' ' or __high^= ' ' then lbstnr = trim(__low)||'-'||trim(__high);

    drop __low __high;


run;

/*
proc sql;
    create table _chkdup as
    select *, count(*) as n
    from lbrange0
    group by lbcat, lbtest, lbstresu, sex, agelow, agehigh
    having n > 1;
quit;
*/

proc sql;
    create table lab2 as
    select a.*, b.lbstnrlo, b.lbstnrhi, b.flag, b.lbstnr
    from lab1 as a left join lbrange as b
    on a.lbcat = b.lbcat
    and a.lbtest = b.lbtest
    and upcase(a.lbstresu) = upcase(b.lbstresu)
    and a.SEX = b.sex
    and b.agelow <= a.__age <= b.agehigh;
;
quit;

proc sort data=lab2 out = _chkRange nodupkey;
    by lbcat lbtest lbstresu;
    where flag = ' ' and lbstresn ^=. ;
run;

data _null_;
    set _chkRange;
    put "WARN" "ING: Range not found: " lbcat= +3 lbtest= +3 lbstresu= +3 sex= +3 __age=;
run;





data lab3;
    set lab2;
    length __lbstnr $1;
    if lbstresn ^=. and n(lbstnrlo, lbstnrhi) > 1 then do;
        if lbstresn < lbstnrlo then __lbstnr = 'L';
        else if lbstresn > ifn(lbstnrhi=., 1E99, lbstnrhi) then __lbstnr = 'H';
    end;
    drop flag;
run;

proc sort data=lab3; by lbtest lbstresu; run;
proc sort data=source.lbgrade out=lbgrade; by lbtest lbstresu; run;


data lab4;
    merge lab3(in=a) lbgrade ;
        by lbtest lbstresu;
        if a;
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

        if lbtoxgr0 ^= . and __lbstnr ^= ' ' then do;
            if lbstresn < gl[1]  then __lbstnr = 'L';
            else if lbstresn < gh[1]  then __lbstnr = 'H';
        end;

    end;
  if LBTOXGR0 ^=. then LBTOXGR = trim(left(put(LBTOXGR0, best.)));

  /*
    **************for for Uric Acid grade, assign grade 1 for higher than ULN and <590umol/l*******;
    if lbtestcd = 'URATE' then do;
        lbtoxgr = '';
        if 590>lbstresn > lbstnrhi >. then lbtoxgr = '1';
        else if 590< lbstresn then lbtoxgr = '4';
    end;
    */
    drop gl1-gl4 gh1-gh4 l1-l4 h1-h4  Multiplier i deltal deltah hs labtest LBTOXGR0;
run;




**** For Hema ---LE tests;
proc sort data=lab4 out=_hemastresu(keep=lbtestcd lbstresu) nodupkey;
    by lbtestcd;
    where lbtestcd in ('NEUT', 'NEUTB', 'LYM', 'MONO', 'EOS', 'BASO') and lbstresc ^= ' ';
run;

data _hemale _hemawbc(rename=(lbstresn=__wbc));
    set lab4;
    where rawcat='HEMATOLOGY (LOCAL)' and lbtestcd in ('WBC', 'NEUTLE', 'NEUTBLE', 'LYMLE', 'MONOLE', 'EOSLE', 'BASOLE');
    keep __edc_treenodeid lbtestcd lbtest rawtest lbstresc lbstresn lbstnr;
    if lbtestcd = 'WBC' then output _hemawbc;
    else output _hemale;
run;

data _hemale2;
    length __edc_treenodeid $36 __wbc 8 lbtestcd lbstresu $40;
    if _n_ = 1 then do;
        declare hash h (dataset: '_hemawbc');
        rc = h.defineKey('__edc_treenodeid');
        rc = h.defineData('__wbc');
        rc = h.defineDone();
        declare hash h2 (dataset: '_hemastresu');
        rc2 = h2.defineKey('lbtestcd');
        rc2 = h2.defineData('lbstresu');
        rc2 = h2.defineDone();

        call missing(__edc_treenodeid, __wbc, lbtestcd, lbstresu);
    end;
    set _hemale;
    rc = h.find();
    if n(lbstresn, __wbc)=2 then lbstresn = lbstresn / 100 * __wbc;
    lbtestcd = substr(lbtestcd, 1, length(lbtestcd)-2);

    lbtestcd = substr(lbtestcd, 1, length(lbtestcd)-2);
    rc2 = h2.find();

    keep __edc_treenodeid lbtestcd lbstresc lbstresn lbstresu lbstnr;
run;



proc sort data=lab4; by __edc_treenodeid lbtestcd; run;
proc sort data=_hemale2; by __edc_treenodeid lbtestcd; run;


data lab5;
    ** Modified 2015-04-30;
    merge lab4(where=(lbtestcd not in ('NEUTSGLE', 'NEUTBLE', 'LYMLE', 'MONOLE', 'EOSLE', 'BASOLE'))) _hemale2;
        by __edc_treenodeid lbtestcd;
run;







data lab6;
    set lab5(rename=(lbstresu=__lbstresu));

    if lbstresn > . then lbstresc = put(round(lbstresn, 0.001), best.);


    if __lbstnr = 'L' then lbstresc = "&escapeChar.S={foreground=&belowcolor}"||strip(lbstresc)||' [L';
    else if __lbstnr = 'H' then lbstresc = "&escapeChar.S={foreground=&abovecolor}"||strip(lbstresc)||' [H';


    if lbtoxgr ^= ' ' then lbstresc = strip(lbstresc)||':'||strip(lbtoxgr);
    if __lbstnr ^= ' ' then lbstresc = strip(lbstresc)||']';


    
    ** Expand length to 255 for later use;
    length lbstresu $255;
    lbstresu = __lbstresu;

run;


*****************************************************************************;
* Put standard unit and standard range in the first two rows of each subject
*****************************************************************************;


proc sort data=lab6; 
    by __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbtmunk lbacelyn lbacelsp lbtesto rawcat lbcode  lbtestcd rawtest2;
run;


proc transpose data=lab6 out=t_lab0;
    by __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbtmunk lbacelyn lbacelsp lbtesto rawcat lbcode;
    id lbtestcd;
    idlabel rawtest2;
    var lbstresc;
run;

proc sort data=lab6 nodupkey out=lab7_1(keep=subject rawcat lbtestcd rawtest2 lbstresu lbstnr ) ; 
    by subject rawcat lbtestcd rawtest2;
    where lbstresu ^= ' ' or lbstnr ^= ' ';
run;

proc sort data=lab6 nodupkey out=lab7_2(keep=subject rawcat lbtestcd rawtest2) ; 
    by subject rawcat lbtestcd rawtest2;
run;

data lab7;
    merge lab7_2 lab7_1;
        by subject rawcat lbtestcd rawtest2;
run;


** For lab standard unit and normal range;
proc transpose data=lab7 out=t_lab1;
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



    label lbdtc ="Collection Date"
          lbtmc ="Collection Time"
          lbtmunk = 'Time Unknown'
        ;
run;

proc sort data = t_lab3; by rawcat subject __ord lbdtc lbtmc; run;



*****************************************************************************;
* Generate final dataset
*****************************************************************************;
data pdata.lbchem1(label='Serum Chemistry (Local Lab)');
    retain __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode sodium k cl bicarb bun creat gluc ca prot;
    keep __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode sodium k cl bicarb bun creat gluc ca prot;
    set t_lab3;
    where rawcat='SERUM CHEMISTRY (LOCAL)';
run;

data pdata.lbchem2(label='Serum Chemistry (Local Lab) (Continued)');
    retain __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode alb ast alt alp bili ldh mg phos urate;
    keep __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode alb ast alt alp bili ldh mg phos urate;
    set t_lab3;
    where rawcat='SERUM CHEMISTRY (LOCAL)';
run;


data pdata.lbchim(label='Donor Chimerism Testing (Local Lab)');
    retain __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode donorce hostce;
    keep __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode donorce hostce;
    set t_lab3;
    where rawcat='DONOR CHIMERISM (LOCAL)';
run;


data pdata.lbcoag(label='Coagulation (Local Lab)');
    retain __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode pt aptt inr;
    keep __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode pt aptt inr;
    set t_lab3;
    where rawcat='COAGULATION (LOCAL)';
run;


data pdata.lbhem1(label='Hematology (Local Lab)');
    retain __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode wbc rbc hgb hct plat neut lym;
    keep __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode wbc rbc hgb hct plat neut lym;
    set t_lab3;
    where rawcat='HEMATOLOGY (LOCAL)';
run;

data pdata.lbhem2(label='Hematology (Local Lab)');
    retain __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode mono eos baso neutb lbacelyn lbacelsp;
    keep __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode  mono eos baso neutb lbacelyn lbacelsp;
    set t_lab3;
    where rawcat='HEMATOLOGY (LOCAL)';
    label lbacelyn = 'Are there additional immature cells listed as part of the CBC Differential Panel results?';
    label lbacelsp = 'If Yes, Specify';
run;


data pdata.lbhep(label='Hepatitis (Local Lab)');
    retain __edc_treenodeid __edc_entrydate subject visit2  lbdtc lbtmc lbtmunk lbcode hbsag hbsab hbcab hcab hbvvld hcvvld;
    keep __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbtmunk lbcode hbsag hbsab hbcab hcab hbvvld hcvvld;
    set t_lab3;
    where rawcat='HEPATITIS (LOCAL)' and __ord = 2;
run;


data pdata.lbimuno(label='Quantitative Serum Immunoglobulins (Local Lab)');
    retain __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode iga igg igm;
    keep __edc_treenodeid __edc_entrydate subject __ord visit2 lbdtc lbtmc lbtmunk lbcode iga igg igm;
    set t_lab3;
    where rawcat='QUANTITATIVE SERUM IMMUNOGLOBULINS (LOCAL)';
run;


proc sort data = lab6 out = _lbsuppout;
    by subject lbdtc;
    where rawcat='IMMUNOSUPPRESSANT LEVEL (LOCAL)';
run;

** Ken Cao on 2015/04/30: Use normalized structure for LBSUPP;
data pdata.lbsupp(label='Immunosuppressant Level (Local Lab)');
    retain __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbtmunk lbcode rawtest2 lbtesto lbstresc lbstresu lbstnr;
    keep __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbtmunk lbcode rawtest2 lbtesto lbstresc lbstresu lbstnr;
    set _lbsuppout;

    label    lbdtc = 'Collection Date';
    label    lbtmc = 'Collection Time';
    label  lbtmunk = 'Time Unknown';
    label rawtest2 = 'Test';
    label LBSTRESC = 'Standard Result';
    label lbstresu = 'Standard Unit';
    label   lbstnr = 'Standard Normal Range';
run;




