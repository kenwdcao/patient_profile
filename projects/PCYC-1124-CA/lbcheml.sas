/********************************************************************************
 Program Nmae: LBCHEML.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/25
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
1) for for Uric Acid grade, assign grade 1 for higher than ULN and <590umol/l Yan Zhang on 2015/04/08
2) Modify normal and grade are both populated Yan Zhang on 2015/04/21

********************************************************************************/
%include '_setup.sas';

proc format;
    value $lbchem
    'Albumin' = 'ALBUMIN'
    'ALK PHOS' = 'ALKPHOS'
    'ALT (SGPT)' = 'ALT'
    'AST (SGOT)' = 'AST'
    'Bicarbonate' = 'BICARB'
    'BUN' = 'BUN'
    'Calcium' = 'CALCIUM'
    'Chloride' = 'CHLORIDE'
    'Creatinine' = 'CREAT'
    'Glucose' = 'GLUCOSE'
    'LDH' = 'LDH'
    'Magnesium' = 'MAGNESIUM'
    'Phosphate' = 'PHOSPHATE'
    'Potassium' = 'POTASSIUM'
    'Sodium' = 'SODIUM'
    'Total Bilirubin' = 'TOTBILI'
    'Total Protein' = 'TOTPROT'
    'Uric Acid' = 'URICACID'
    ;
run;

data lbcheml0;
    set source.lbcheml(keep=edc_treenodeid edc_entrydate subject yr visit cycle lbcat lbtmunk lbcode lbtest
                            lbnd lbsymb lborres lborresu lbunito seq lbdt lbtm lbsymb lborres);

    %subject;

    length lbtestcd $8;
    label lbtestcd = 'Lab Test Code';
    lbtestcd = put(lbtest, $lbchem.); ** test code to be used as variable name after transpose;
    

    length lbdtc $20;
    label lbdtc = 'Collection Date';
    %ndt2cdt(ndt=lbdt, cdt=lbdtc);
    drop lbdt;


    ** combine "unknown" into "Collection Time";
    length lbtmc $10;
    label lbtmc = 'Collection Time';
    %ntime2ctime(ntime=lbtm, ctime=lbtmc);
    if lbtmunk > ' ' and lbtmc > ' ' then put "ERR" "OR: " LBTMUNK = +3 LBTMC = ;
    if lbtmunk > ' ' then lbtmc = 'Unknown';
    drop lbtm lbtmunk;
    
    
    length lborres2 $255;
    label lborres2 = 'Result';
    if lbnd > ' ' then lborres2 = 'Not Reported';
    else lborres2 = lborres;
    if lbsymb > ' ' then lborres2 = strip(lbsymb)||lborres2; ** symbol like >, <...;
    drop lborres lbnd;


    ** combine unit and "other unit";
    length lborresu2 $100;
    label lborresu2 = 'Unit';
    if lbunito > ' ' then lborresu2 = lbunito;
    else lborresu2 = lborresu;
    drop lbunito;


    %visit;

    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;

    ** variable that will be kept but will not be displayed;
    rename lbcat = __lbcat;
    rename yr = __yr;

    __Result = 0; %IsNumeric(InStr= lborres, Result=__Result);
    if __Result = 1 then result = input(trim(left( lborres)), best.); else result = .;;
run;

data lbcheml1;
    length subject $13 rfstdtc $10;
    length sex $6 __age 8;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        declare hash h2 (dataset:'pdata.dm');
        rc2 = h2.defineKey('subject');
        rc2 = h2.defineData('sex','__age');
        rc2 = h2.defineDone();
        call missing(subject, rfstdtc, sex, __age);
    end;
    set lbcheml0;
    rc = h.find();
    rc2 = h2.find();
    %concatdy(lbdtc);
    drop rc rc2;
run;


/* !-- CODE TO BE ADDED HERE TO DERIVE NORMAL RANGE --*/

data lbcheml2;
    length rawtest $200 rawunit $40 lbcat $11;
    set lbcheml1;
    rawunit = upcase(lborresu2);
    rawtest = upcase(lbtest);
    lbcat = 'CHEMISTRY';
    lbsex = upcase(sex);
    age = __age;
    rename lbtestcd = testcd01;
run;
***************************get LBSTRESU from dataset lb_master****************;
proc sort data = lbcheml2; by rawtest rawunit;run;

proc sort data = source.lb_master out = lb_master(rename = (lbtest = lbtest_g));
by rawtest rawunit;
where strip(rawcat) = 'SERUM CHEMISTRY';
run;
data lb_jn_master;
    merge lbcheml2(in=a) lb_master(in=b keep = rawtest rawunit cf lbtestcd lbstresu lbtest_g);
    by rawtest rawunit;
    if a;
    if a and not b then put "WARN" "ING:" subject= rawunit= rawtest=;
    if result ^=. and cf ^=. then lbstresn = result*cf;

    ** Ken Cao on 2015/03/25: Keep two digits after period;
    if lbstresn ^=. then lbstresn = round(lbstresn, 0.01);
run;

data lb_range(
        keep = tcd test cat spec lbmethod sex__ symbol_age_low agelow agehigh age_units symbol_range_low low symbol_range_high high stresu low_other high_other other_units);
    set source.lbrange;
    agelow = input(age_low,best.);
    rename age_high=agehigh pcyc_low_range_lbstnrlo = low pcyc_high_range_lbstnrhi = high lbcat = cat lbtestcd = tcd lbtest = test
    lbspec = spec low_range__other_units = low_other high_range_other_units = high_other from__other_units = other_units sex = sex__ lbstresu_pcyc_standard_units = stresu ;
run;

**********Get Low, High from range dataset**************;
proc sort data = lb_range; by tcd test cat spec lbmethod sex__ symbol_age_low agelow agehigh age_units stresu symbol_range_low low symbol_range_high high descending other_units;run;
 
proc sort data = lb_range nodupkey dupout =aa;
by tcd test cat spec lbmethod sex__ symbol_age_low agelow agehigh age_units stresu symbol_range_low low symbol_range_high high;
run;

proc sql;
 create table lb_jn_range as
 select *
 from (select * from lb_jn_master) as a
    left join
    (select * from lb_range) as b 
 on a.lbcat = b.cat and a.lbtestcd = b.tcd and a.lbstresu=b.stresu and (a.lbsex=b.sex__ or b.sex__='BOTH' or b.sex__='') 
    and ((b.symbol_age_low = '>' and a.age>b.agelow) or (b.symbol_age_low = '<' and a.age<b.agelow) or (b.agelow^=. and b.agehigh=. and a.age>=b.agelow) or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.age<=b.agehigh)
         or (b.agelow=. and b.agehigh=.));
quit;

***********Get lbgrade *********************;
proc sort data = source.lbgrade out = lbgrade(rename = (lbtest = lbtest_g)); by lbtest lbstresu;run;
proc sort data = lb_jn_range;by lbtest_g lbstresu;run;
data lb_jn_grade;
    merge lb_jn_range(in=a) lbgrade; 
    by lbtest_g lbstresu;
    if a;
    array gl(4) gl1-gl4;
    array gh(4) gh1-gh4;
       array l(4) l1-l4;
         array h(4) h1-h4;
     do i=1 to 4;
     if l(i)='LLN' then gl(i)=low; else if l(i)^='' then gl(i)=input(l(i), best.);
     if h(i)='ULN' then gh(i)=high; else if h(i)^='' then gh(i)=input(h(i), best.);
      if Multiplier='N' and gl(i)^=. and LBSTRESN^=. and LBSTRESN<gl(i) then do; LBTOXGR0=i; indicatr = 'L';end;
         else if Multiplier='Y' and i=1 and gl(1)^=. and LBSTRESN^=. and LBSTRESN<gl(1) then do; LBTOXGR0=1;indicatr = 'L';end;
            else if Multiplier='Y' and i^=1 and gl(1)^=. and gl(i)^=. and LBSTRESN^=. and LBSTRESN<gl(i)*gl(1) then do; LBTOXGR0=i;indicatr = 'L';end;
      if Multiplier='N' and gh(i)^=. and LBSTRESN^=. and gh(i)<LBSTRESN then do; LBTOXGR0=i; indicatr = 'H';end;
         else if Multiplier='Y' and i=1 and gh(1)^=. and LBSTRESN^=. and gh(1)<LBSTRESN then do;LBTOXGR0=1; indicatr = 'H';end;
            else if Multiplier='Y' and i^=1 and gh(1)^=. and gh(i)^=. and LBSTRESN^=. and gh(i)*gh(1)<LBSTRESN then do; LBTOXGR0=i; indicatr = 'L';end;
  end;
  if LBTOXGR0 ^=. then LBTOXGR = trim(left(put(LBTOXGR0, best.)));

  **************for for Uric Acid grade, assign grade 1 for higher than ULN and <590umol/l*******;
  if lbtestcd = 'URATE' then do;
  lbtoxgr = '';
  if 590>lbstresn > high >. then lbtoxgr = '1';
  else if 590< lbstresn then lbtoxgr = '4';
  end;
run;

** mockup dataset;
data lbcheml_nr01;
    set lb_jn_grade;
    length __normrange $100;
    if lborresu2 = other_units then do;
        if low_other^=. then low_ = low_other;
        if high_other ^= . then high_ = high_other;
    end;
        else do;
        if low ^=. and cf ^=. then low_=low/cf;
        if high ^=. and cf ^=. then high_=high/cf;
        end;

    if low^=. and high ^=. then __normrange = strip(put(low, best.))||" - "||strip(put(high, best.)); 
** normal range for this lab test and this lab unit and this subject;

************color code for result as below***********************;
    if lbsymb = '' then do;
    if low ^=. and high ^=. and lbstresn ^=. then do;
        if lbstresn < low then lbnrind = 'L';
        else if lbstresn > high then lbnrind = 'H';
        else if low <= lbstresn <= high then lbnrind = 'N';
    end;end;
        else if lbsymb = "<" then do;
        if .<lbstresn < low then  lbnrind = 'L';
    end;

    if lbsymb ^='' and lbstresn ^=. then lbstresc = strip(lbsymb)||" "||strip(put(lbstresn,best.));
    else if lbstresn ^=. then lbstresc = strip(put(lbstresn,best.));
    else if lbstresn = . and lborres2 ^='' then lbstresc = strip(lborres2);

    if index(lborres2,">=") and cf ^= . and high > . and input(compress(lborres2,">="),best.)>=(high/cf) then lbnrind = 'H';
    lborres2 = strip(lbstresc);
    if lbnrind ='L' then do;
        if lbtoxgr ='' then lborres2 = "&escapechar{style [foreground=&belowcolor]"||strip(lbstresc) ||" [L]"||"}";
        else if lbtoxgr ^='' then lborres2 = "&escapechar{style [foreground=&belowcolor]"||strip(lbstresc) ||" [L:"||strip(lbtoxgr)||"]"||"}";
    end;
    else if lbnrind ='H' then do; 
        if lbtoxgr ='' then lborres2 = "&escapechar{style [foreground=&abovecolor]"||strip(lbstresc) ||" [H]"||"}";
        else if lbtoxgr ^='' then lborres2 = "&escapechar{style [foreground=&abovecolor]"||strip(lbstresc) ||" [H:"||strip(lbtoxgr)||"]"||"}";
    end;
/*    else if lbnrind ='N' then do; */
/*        if lbtoxgr ^='' then lborres2 = strip(lbstresc) ||" [N:"||strip(lbtoxgr)||"]";*/
/*    end;*/

    *********Modify normal and grade are both populated*********;
    else if lbnrind ='N' then do; 
        if lbtoxgr ^='' and indicatr = 'H' then lborres2 = "&escapechar{style [foreground=&abovecolor]"||strip(lbstresc) ||" [H:"||strip(lbtoxgr)||"]"||"}";;
    end;
    else if lbnrind ='N' then do; 
        if lbtoxgr ^='' and indicatr = 'L' then lborres2 = "&escapechar{style [foreground=&belowcolor]"||strip(lbstresc) ||" [L:"||strip(lbtoxgr)||"]"||"}";
    end;

run;

/*proc sql;*/
/*    create table unit as select distinct lbtest, lbstresu as unit from lbcheml_nr01*/
/*    where lbstresu ^=''*/
/*    order by lbtest, lbstresu;*/
/*quit;*/
/**/
/*proc sort data = lbcheml_nr01; by lbtest;run;*/
/*data lbcheml_nr;*/
/*    merge lbcheml_nr01(in=a) unit;*/
/*    by lbtest;*/
/*    if a;*/
/*    if lbstresu = '' then lbstresu = unit;*/
/*run;*/

/*
 * fetch most frequently used unit of a lab test for a subject.
 */;

proc sql;
    create table _std0 as
    select distinct subject, lbtest,lbtestcd, lbstresu, __normrange, count(*) as nunit
    from lbcheml_nr01
    group by subject, lbtest, lbstresu
    order by subject, lbtest, nunit
    ;

    create table _std1 as
    select subject, lbtest, lbtestcd, lbstresu, __normrange, nunit
    from _std0
    group by subject, lbtest
    having nunit = max(nunit)
    order by subject, lbtest
    ;
quit;

data _std;
    set _std1;
        by subject lbtest;
/*    if first.lbtest and not last.lbtest then put "WARN" "ING: More than one frequent unit: " subject= lbtest=;*/
    if last.lbtest;
    rename lbstresu = __stdunit ; ** standard unit for this subject and this lab test;
    rename __normrange = __stdnr; ** standard unit for this subject and this lab test;
run;

data lbcheml_nr2;
    length subject $13 lbtest $15 __stdunit $100 __stdnr $100;
    if _n_ = 1 then do;
        declare hash h (dataset:'_std');
        rc = h.defineKey('subject','lbtest');
        rc = h.defineData('__stdunit', '__stdnr');
        rc = h.defineDone();
        call missing(subject,lbtest, __stdunit, __stdnr);
    end;
    set lbcheml_nr01;
    rc = h.find();
    drop rc;
    drop lborresu2;
run;

proc sort data = lbcheml_nr2; by subject lbdtc lbtmc visit2 lbcode lbtestcd; run;

proc transpose data = lbcheml_nr2 out = t_lbcheml0(drop=_name_ _label_);
    by subject lbdtc lbtmc visit2 lbcode __edc_treenodeid __edc_entrydate ; 
    id lbtestcd;
    idlabel lbtest;
    var lborres2;
run;

proc sort data = _std; by subject lbtest; run;
proc transpose data = _std out=t_std0;
    by subject;
    id lbtestcd;
    idlabel lbtest;
    var __stdunit __stdnr;
run;

data t_std;
    set t_lbcheml0(where=(0)) t_std0; ** so that all variables share same attribute;
    __edc_entrydate = .;
    if _name_ = '__STDUNIT' then do;
        __edc_treenodeid = ' 0-'||strip(subject)||'-Unit'; 
        __ord = 0;
    end;
    else if _name_ = '__STDNR' then do;
        __edc_treenodeid = ' 1-'||strip(subject)||'-NR'; 
        __ord = 1;
    end;
    drop _name_;
run;

proc sort data = t_lbcheml0; by subject __edc_treenodeid; run;
proc sort data = t_std; by subject; run;

data pre_lbcheml;
    set t_std t_lbcheml0(in=__a__);
        by subject __edc_treenodeid;
    if __a__ then __ord = 2;
run;

proc sort data = pre_lbcheml; by subject __ord lbdtc; run;

data out.lbcheml1(label = 'Serum Chemistry (Local Lab)');
    keep __edc_treenodeid __edc_entrydate subject lbdtc lbtmc visit2 lbcode sodium k cl bicarb bun creat gluc ca prot;
    retain __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbcode sodium k cl bicarb bun creat gluc ca prot;
    set pre_lbcheml;
run;

data out.lbcheml2(label = 'Serum Chemistry (Local Lab) (Continued)');
    keep __edc_treenodeid __edc_entrydate subject lbdtc lbtmc visit2 alb ast alt alp bili ldh mg phos urate;
    retain __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc alb ast alt alp bili ldh mg phos urate;
    set pre_lbcheml;
run;
