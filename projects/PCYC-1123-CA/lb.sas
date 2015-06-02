/*********************************************************************
 Program Name: LB.sas
  @Author: Ken Cao
  @Initial Date: 2015/04/15
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data lb0;
    set source.lb;
    keep EDC_TreeNodeID SUBJECT VISIT CYCLE LBCAT LBCODE LBSPEC LBTEST LBORRES LBORRESU LBUNITO LBORRESO LBUNITOS LBENDO
         LBACELYN LBACELSP LBTRYN LBTRSP UNSSEQ  LBNA LBDT LBTM LBND LBSYMB EDC_EntryDate;
    rename EDC_EntryDate = __EDC_EntryDate;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
run;

data lb1;
    length subject $13 rfstdtc $10 sex $6 __age $40;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        declare hash h2 (dataset:'pdata.dm');
        rc = h2.defineKey('subject');
        rc = h2.defineData('sex', '__age');
        rc = h2.defineDone();
        call missing(subject, rfstdtc, sex, __age);
    end;
    set lb0;
    %subject;
    %visit2;
    
    length lbdtc $20;
    %ndt2cdt(ndt=lbdt, cdt=lbdtc);
    rc = h.find();
    %concatDY(lbdtc);
    drop rc lbdt;

    length lbtmc $10;
    %ntime2ctime(ntime=lbtm, ctime=lbtmc);
    drop lbtm;


    length rawunit $40;
    if lbunito ^= ' ' then rawunit = lbunito;
    else rawunit = strip(vvaluex('lborresu'));
    rawunit = upcase(rawunit);
    if lborresu ^= 'Other' and lbunito ^= ' ' then do;
        put "WARN" "ING: Conflict value " __EDC_TREENODEID= subject= lborresu= lbunito=;
    end;
/*    drop lborresu lbunito;*/


    length lborresc $255;
    lborresc = lborres;
    if lborreso ^= ' ' then lborresc = lborreso;
    if LBSYMB ^=. then lborresc = strip(vvaluex('LBSYMB'))||lborres;

    if LBSYMB = 7 then do;
        put "WARN" "ING: Pay attention to those values: " subject= LBSYMB= lborres=;
    end;
 
    if lborres ^= 'Other' and lborres > ' ' and lborreso ^= ' ' then do;
        put "WARN" "ING: Conflict value " __EDC_TREENODEID= subject= lborres= lborreso=;
    end;

    if lbnd = 1 then lborresc = 'Not Reported';

    drop lborres lborreso lbnd;

    
    length rawcat rawtest rawtest2 $200;
    rawcat = upcase(lbcat);
    rawtest = upcase(lbtest);
    rawtest2 = lbtest; ** For later use to be displayed in the header;
    drop lbcat lbtest;

    length lborresn 8;
    __Result = 0; %IsNumeric(InStr= lborresc, Result=__Result);
    if __Result = 1 then lborresn = input(trim(left(lborresc)), best.); 
    drop __Result;

    rc2 = h2.find();
    drop rc2;
    age = input(__age, best.);
    drop __age;

    format lbna checked.;
run;


proc sql;
    create table lb_master_c as
    select * 
    from source.lb_master
    where 0
    ;

    insert into lb_master_c (rawcat, rawtest, rawunit,lbcat, lbtest, lbtestcd, lbstresu, cf)
    values('HEMATOLOGY', 'PLATELETS', '10E3/UL', 'HEMATOLOGY', 'Platelets', 'PLAT', '10^9/L', 1)
    values('THYROID STIMULATING HORMONE', 'TSH', 'MCU/ML', 'CHEMISTRY', 'Thyrotropin', 'TSH', 'mU/L', 1)
    ;
quit;

data lb_master;
    set source.lb_master lb_master_c;
run;



** Get standard unit/test/test code/conversion factor from LB_MASTER;
data lb2(drop=notfound /*drop=rawcat rawtest rawunit*/) _masterFail(keep=rawcat rawtest rawunit);
    length rawcat lbcat rawtest $200 rawunit lbtest lbtestcd lbstresu $40 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'lb_master');
        rc = h.defineKey('rawcat', 'rawtest', 'rawunit');
        rc = h.defineData('lbstresu', 'cf', 'lbtest', 'lbcat', 'lbtestcd');
        rc = h.defineDone();
        call missing(rawcat, rawtest, rawunit, lbstresu, cf, lbcat, lbtest, lbtestcd);
    end;
    set lb1;
    notfound = h.find();
    drop rc ;

    length lbstresn 8 lbstresc $255;
    if n(lborresn, cf) = 2 then lbstresn = lborresn * cf;
    lbstresc = ifc(lbstresn > ., strip(put(lbstresn, best.)), lborresc);

    if lborresn = . and   lborresc not in ('', 'Not Done', 'Not Done / NA', 'Not reported') and cf not in (1, .) then do;
        put "WARN" "ING: Check those values: " rawcat= +3 rawtest= rawunit= +3 lbstresu= +3 lborresc= +3 cf=;
    end;

    if notfound then do;
        
    end;

    output lb2;
    if notfound then output _masterFail;
run;
***********************************************************************;

** Check if any failure ;
proc sort data=_masterFail nodupkey;
    by rawcat rawtest rawunit;
run;

data _null_;
    set _masterFail;
    put "WARN" "ING: Not found in LB_MASTER: " rawcat= rawtest= rawunit=;
run;
***********************************************************************;


** LBRANGE;
data lbrange0;
    set source.lbrange;
    ** Ken Cao on 2015/04/15: Get local lab data;
    where lbtestcd ^= ' ' ;
    
    length agelow agehigh 8;
    agehigh = ifn(age_high_ = ., 1000, age_high_);
    agelow = ifn(age_low_ = ., 0, age_low_);
    if symbol_age_low_ = '>' then agelow = agelow + 0.01;

    length lbstresu $40 lbstnrlo lbstnrhi 8;
    lbstnrhi = PCYC_HIGH_RANGE_LBSTNRHI;
    lbstnrlo = PCYC_LOW_RANGE_LBSTNRLO;
    lbstresu = LBSTRESU_PCYC_Standard_Units;

    length flag $1;
    flag = 'Y';

    length sex $6;
    if sex__ = ' ' or sex__ = 'BOTH' then do;
        sex = 'Female';
        output;
        sex = 'Male';
        output;
    end;
    else do;
        sex = propcase(sex__);
        output;
    end;

    keep  lbtestcd lbtest lbcat lbspec lbmethod sex agelow agehigh lbstresu lbstnrlo lbstnrhi comments flag;
run;

proc sort data=lbrange0 nodupkey;
    by lbcat lbtest lbstresu sex agelow agehigh;
run;

proc sql;
    create table lbrangec as
    select *
    from lbrange0
    where 0;

    insert into lbrangec (lbcat, lbtest, lbstresu, sex, agelow, agehigh, lbstnrlo, lbstnrhi, flag)
    values('URINALYSIS', 'Specific Gravity', '', 'Female', 0, 1000, 1.002, 1.03, 'Y')
    values('URINALYSIS', 'Specific Gravity', '', 'Male', 0, 1000, 1.002, 1.03, 'Y')

    ;
quit;

data lbrange;
    set lbrange0 lbrangec;
    /***add wym***/;
    if LBSTRESU="n/a" then  LBSTRESU="";
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
    create table lb3 as
    select a.*, b.lbstnrlo, b.lbstnrhi, b.flag
    from lb2 as a left join lbrange as b
    on a.lbcat = b.lbcat
    and a.lbtest = b.lbtest
    and a.lbstresu = b.lbstresu
    and a.sex = b.sex
    and b.agelow <= a.age <= b.agehigh;
;
quit;

proc sort data=lb3 out = _chkRange nodupkey;
    by lbcat lbtest lbstresu;
    where flag = ' ' and lbstresn ^=. ;
run;

data _null_;
    set _chkRange;
    put "WARN" "ING: Range not found: " lbcat= +3 lbtest= +3 lbstresu= +3 sex= +3 age=;
run;


data lb4;
    set lb3;
    length __lbstnr $1;
    if lbstresn ^=. and n(lbstnrlo, lbstnrhi) > 1 then do;
        if lbstresn < lbstnrlo then __lbstnr = 'L';
        else if lbstresn > ifn(lbstnrhi=., 1E99, lbstnrhi) then __lbstnr = 'H';
    end;
    drop flag;
run;

proc sort data=lb4; by lbtest lbstresu; run;
proc sort data=source.lbgrade out=lbgrade; by lbtest lbstresu; run;


data lb5;
    merge lb4(in=a) lbgrade ;
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
    end;
  if LBTOXGR0 ^=. then LBTOXGR = trim(left(put(LBTOXGR0, best.)));

    **************for for Uric Acid grade, assign grade 1 for higher than ULN and <590umol/l*******;
    if lbtestcd = 'URATE' then do;
        lbtoxgr = '';
        if 590>lbstresn > lbstnrhi >. then lbtoxgr = '1';
        else if 590< lbstresn then lbtoxgr = '4';
    end;

    drop gl1-gl4 gh1-gh4 l1-l4 h1-h4  Multiplier i deltal deltah hs labtest LBTOXGR0;
run;


**** For Hema ---LE tests;
data _hemale _hemawbc(rename=(lbstresn=__wbc));
    set lb5;
    where rawcat='HEMATOLOGY' and lbtestcd in ('WBC', 'NEUTLE', 'NEUTBLE', 'LYMLE', 'MONOLE', 'EOSLE', 'BASOLE');
    keep __edc_treenodeid lbtestcd lbtest rawtest lbstresn;
    if lbtestcd = 'WBC' then output _hemawbc;
    else output _hemale;
run;

data _hemale2;
    length __edc_treenodeid $36 __wbc 8;
    if _n_ = 1 then do;
        declare hash h (dataset: '_hemawbc');
        rc = h.defineKey('__edc_treenodeid');
        rc = h.defineData('__wbc');
        rc = h.defineDone();
        call missing(__edc_treenodeid, __wbc);
    end;
    set _hemale;
    rc = h.find();
    if n(lbstresn, __wbc)=2 then lbstresn = lbstresn / 100 * __wbc;
    lbtestcd = substr(lbtestcd, 1, length(lbtestcd)-2);
    rename lbtestcd = _lbtestcd;
    rename lbstresn = _lbstresn;
run;

data _hema;
    set lb5;
    where rawcat='HEMATOLOGY' and lbtestcd in ('NEUT', 'NEUTB', 'LYM', 'MONO', 'EOS', 'BASO');
    keep __edc_treenodeid lbtestcd lbtest rawtest lbstresn;
run;

data lb5_2;
    length __edc_treenodeid $36 _lbtestcd $40 _lbstresn 8;
    if _n_ = 1 then do;
        declare hash h (dataset: '_hemale2');
        rc = h.defineKey('__edc_treenodeid', '_lbtestcd');
        rc = h.defineData('_lbstresn');
        rc = h.defineDone();
        call missing(__edc_treenodeid, _lbtestcd, _lbstresn);
    end;
    set lb5;
    where not (rawcat='HEMATOLOGY' and lbtestcd in ('NEUTLE', 'NEUTBLE', 'LYMLE', 'MONOLE', 'EOSLE', 'BASOLE'));
    
    rc = h.find();
    
    if rc = 0 then do;
        lbstresn = _lbstresn;
        lbstresc = strip(put(lbstresn, best.));
    end;
    
run;



data lb6;
    set lb5_2(rename=(lbstresu=__s_lbstresu));

    if lbstresn > . then lbstresc = put(round(lbstresn, 0.001), best.);

    if __lbstnr = 'L' then lbstresc = "&escapeChar.S={foreground=&belowcolor}"||strip(lbstresc)||' [L';
    else if __lbstnr = 'H' then lbstresc = "&escapeChar.S={foreground=&abovecolor}"||strip(lbstresc)||' [H';


    if lbtoxgr ^= ' ' then lbstresc = strip(lbstresc)||':'||strip(lbtoxgr);
    if __lbstnr ^= ' ' then lbstresc = strip(lbstresc)||']';

    if lbcat^="" ;

    length lbstnr $255;
    if n(lbstnrlo, lbstnrhi) > 0 then do;
        lbstnr = ifc(lbstnrlo ^=., strip(vvaluex('lbstnrlo')), ' ' )||' - '||ifc(lbstnrhi ^=., strip(vvaluex('lbstnrhi')), ' ' );
    end;
    
    ** Expand length to 255 for later use;
    length lbstresu $255;
    lbstresu = __s_lbstresu;

    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 LBDTC LBTMC RAWCAT LBTESTCD RAWTEST2 LBCODE LBSTRESC LBSTRESU 
         LBSTNR LBSPEC LBENDO LBACELYN LBACELSP LBTRYN LBTRSP LBSYMB LBNA;
run;

proc sort data=lb6; 
    by __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 LBDTC LBTMC LBSPEC LBENDO LBACELYN LBACELSP
          LBTRYN LBTRSP RAWCAT LBCODE LBNA LBTESTCD RAWTEST2 ;
run;



** For lab result (use RAWTEST as label);
proc transpose data=lb6 out=t_lab0;
    by __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 LBDTC LBTMC LBSPEC LBENDO LBACELYN LBACELSP
          LBTRYN LBTRSP RAWCAT LBCODE LBNA;
    id lbtestcd;
    idlabel rawtest2;
    var lbstresc;
run;

proc sort data=lb6 nodupkey out=lb7_1(keep=subject rawcat lbtestcd rawtest2 lbstresu lbstnr ) ; 
    by subject rawcat lbtestcd rawtest2;
    where lbstresu ^= ' ' or lbstnr ^= ' ';
run;

proc sort data=lb6 nodupkey out=lb7_2(keep=subject rawcat lbtestcd rawtest2) ; 
    by subject rawcat lbtestcd rawtest2;
run;

data lb7;
    merge lb7_2 lb7_1;
        by subject rawcat lbtestcd rawtest2;
run;


** For lab standard unit and normal range;
proc transpose data=lb7 out=t_lab1;
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
    lbtmc ="Collection Time";
run;

proc sort data=t_lab3;
    by subject __ord lbdtc lbtmc visit2 rawcat;
run;

data pdata.lbcoag(LABEL='Coagulation Studies (Local Lab)');
    retain __edc_treenodeid __edc_entrydate __ord subject visit2 lbdtc lbtmc lbcode pt aptt inr lbtryn lbtrsp;
    keep __edc_treenodeid __edc_entrydate __ord subject visit2 lbdtc lbtmc lbcode pt aptt inr lbtryn lbtrsp;
    set t_lab3;
    where rawcat='COAGULATION';
run;


data pdata.lbcreat(label='Creatinine Clearance');
    retain __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc  creatclr;
    keep __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc  creatclr;
    set t_lab3;
    where rawcat='CREATININE CLEARANCE';
/*    label lbna = 'Not Done';*/
run;



data pdata.lbhem1(label='Hematology (Local Lab)');
    retain __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc lbcode wbc rbc hgb
        hct plat neut ;
    keep __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc lbcode wbc rbc hgb
        hct plat neut;
    set t_lab3;
    where rawcat='HEMATOLOGY';
run;


data pdata.lbhem2(label='Hematology (Local Lab, Continued)');
    retain __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc   neutb  lym  mono  eos  baso  lbacelyn lbacelsp;
    keep __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc   neutb  lym  mono  eos  baso  lbacelyn lbacelsp;
    set t_lab3;
    where rawcat='HEMATOLOGY';
run;


data pdata.lbser(label='Hepatitis Serologies (Local Lab)');
    retain __edc_treenodeid __edc_entrydate  subject visit2 lbna lbdtc lbtmc lbcode hbsag hbsab hbcab hcab hcvpcr;
    keep __edc_treenodeid __edc_entrydate  subject visit2 lbna lbdtc lbtmc lbcode hbsag hbsab hbcab hcab hcvpcr;
    set t_lab3;
    where rawcat='SEROLOGY' and __ord = 2;
run;


data pdata.lbchem1(label='Serum Chemistry (Local Lab)');
    retain __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc lbcode sodium k bun creat gluc ca phos mg;
    keep __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc lbcode sodium k bun creat gluc ca phos mg;
    set t_lab3;
    where rawcat='SERUM CHEMISTRY';
run;

data pdata.lbchem2(label='Serum Chemistry (Local Lab, Continued)');
    retain __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc  alb ast alt alp bili ldh urate cl prot bicarb;
    keep __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc  alb ast alt alp bili ldh urate cl prot bicarb;
    set t_lab3;
    where rawcat='SERUM CHEMISTRY';
run;



data pdata.lbthy(label='Thyroid Stimulating Hormone (Local Lab)');
    retain __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc lbcode tsh;
    keep __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc lbcode tsh;
    set t_lab3;
    where rawcat='THYROID STIMULATING HORMONE';
run;



data pdata.lburine(label='Urinalysis (Local Lab)');
    retain __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc lbcode spgrav ph gluc bili ketones blood prot;
    keep __edc_treenodeid __edc_entrydate __ord subject visit2 lbna lbdtc lbtmc lbcode spgrav ph gluc bili ketones blood prot;
    set t_lab3;
    where rawcat='URINALYSIS';
run;

