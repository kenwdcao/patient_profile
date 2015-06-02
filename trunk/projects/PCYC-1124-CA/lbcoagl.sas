/********************************************************************************
 Program Nmae: LBCOAGL.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
Yan Zhang on 2015/04/17 Modify code since the variable names are changed in raw dataset

********************************************************************************/
%include '_setup.sas';
proc format;
    value $lbtest
    'APTT' ='Activated Partial Thromboplastin Time'
    'PT' = 'Prothrombin Time'
    'INR' = 'Prothrombin Intl. Normalized Ratio';
run;

data lbcoagl0;
    length cycle $10 lbtest $200;
    set source.lbcoagl(keep=edc_treenodeid edc_entrydate subject visit lbcat lbtmunk lbcode lbtest
                            lbnd lbsymb lborres lborresu lbunito seq lbdt lbtm lborres lbtryn lbtrsp);

    %subject;

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


    cycle = cycle; ** in case that cycle is added in the furture.;
    %visit;

    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;

    ** variable that will be kept but will not be displayed;
    rename lbcat = __lbcat;

    __Result = 0; %IsNumeric(InStr= lborres, Result=__Result);
    if __Result = 1 then result = input(trim(left( lborres)), best.); else result = .;;

    ****Modify test name to standard*********;
    if lbtest = 'PTT' then lbtest = 'PTT';
run;

data lbcoagl1;
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
    set lbcoagl0;
    rc = h.find();
    rc2 = h2.find();
    %concatdy(lbdtc);
    drop rc rc2;
run;


/* !-- CODE TO BE ADDED HERE TO DERIVE NORMAL RANGE --*/

data lbcoagl2;
    length rawtest $200 rawunit $40 lbcat $11;
    set lbcoagl1;
    rawunit = upcase(lborresu2);
    rawtest = upcase(lbtest);
    lbcat = 'COAGULATION LOCAL';
    lbsex = upcase(sex);
    age = __age;
run;
***************************get LBSTRESU from dataset lb_master****************;
proc sort data = lbcoagl2; by rawtest rawunit;run;

proc sort data = source.lb_master out = lb_master(rename = (lbtest = lbtest_g));
by rawtest rawunit;
where strip(rawcat) = 'COAGULATION';
run;
data lb_jn_master;
    merge lbcoagl2(in=a) lb_master(in=b keep = rawtest rawunit cf lbtestcd lbstresu lbtest_g);
    by rawtest rawunit;
    if a;
    if a and not b then put "WARN" "ING:" subject= rawunit= rawtest=;
    if result ^=. and cf ^=. then lbstresn = result*cf;

    ** Ken Cao on 2015/03/25: Keep two digits after period;
    if lbstresn ^=. then lbstresn = round(lbstresn, 0.01);
run;

*******modify code since the variable names are changed in raw dataset**************;
data lb_range(
        keep = tcd test cat spec lbmethod sex__ symbol_age_low agelow agehigh age_units symbol_range_low low symbol_range_high high stresu low_other high_other other_units);
    set source.lbrange;
    agelow = input(age_low,best.);
    rename age_high=agehigh pcyc_low_range_lbstnrlo = low pcyc_high_range_lbstnrhi = high lbcat = cat lbtestcd = tcd lbtest = test
    lbspec = spec low_range__other_units = low_other high_range_other_units = high_other from__other_units = other_units sex = sex__ lbstresu_pcyc_standard_units = stresu ;
run;

**********Get Low, High from range dataset**************;
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
         else if Multiplier='Y' and i=1 and gl(1)^=. and LBSTRESN^=. and LBSTRESN<gl(1) then do; LBTOXGR0=1; indicatr = 'L';end;
            else if Multiplier='Y' and i^=1 and gl(1)^=. and gl(i)^=. and LBSTRESN^=. and LBSTRESN<gl(i)*gl(1) then do; LBTOXGR0=i; indicatr = 'L';end;
      if Multiplier='N' and gh(i)^=. and LBSTRESN^=. and gh(i)<LBSTRESN then do; LBTOXGR0=i; indicatr = 'L';end;
         else if Multiplier='Y' and i=1 and gh(1)^=. and LBSTRESN^=. and gh(1)<LBSTRESN then do; LBTOXGR0=1; indicatr = 'L';end;
            else if Multiplier='Y' and i^=1 and gh(1)^=. and gh(i)^=. and LBSTRESN^=. and gh(i)*gh(1)<LBSTRESN then do; LBTOXGR0=i; indicatr = 'L';end;
  end;
  if LBTOXGR0 ^=. then LBTOXGR = trim(left(put(LBTOXGR0, best.)));
run;

** mockup dataset;
data lbcoagl_nr;
    set lb_jn_grade;
    length __normrange $100 lbtest $200;

    if low^=. and high ^=. then __normrange = strip(put(low, best.))||" - "||strip(put(high, best.)); 
** normal range for this lab test and this lab unit and this subject;

************color code for result as below***********************;
    if lbsymb = '' then do;
    if low ^=. and high ^=. and lbstresn ^=. then do;
        if lbstresn < low then lbnrind = 'L';
        else if lbstresn > high then lbnrind = 'H';
        else if low <= lbstresn <= high then lbnrind = 'NORMAL';
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
     lbtest = put(lbtest,$lbtest.);
run;

/*
 * fetch most frequently used unit of a lab test for a subject.
 */;

proc sql;
    create table _std0 as
    select distinct subject, lbtest,lbtestcd, lbstresu, __normrange, count(*) as nunit
    from lbcoagl_nr
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
    if first.lbtest and not last.lbtest then put "WARN" "ING: More than one frequent unit: " subject= lbtest=;
    if last.lbtest;
    rename lbstresu = __stdunit ; ** standard unit for this subject and this lab test;
    rename __normrange = __stdnr; ** standard unit for this subject and this lab test;
run;

data lbcoagl_nr2;
    length subject $13 lbtest $200 __stdunit $100 __stdnr $100;
    if _n_ = 1 then do;
        declare hash h (dataset:'_std');
        rc = h.defineKey('subject','lbtest');
        rc = h.defineData('__stdunit', '__stdnr');
        rc = h.defineDone();
        call missing(subject,lbtest, __stdunit, __stdnr);
    end;
    set lbcoagl_nr;
    rc = h.find();
    drop rc;
    drop lborresu2;
run;

proc sort data = lbcoagl_nr2; by subject lbdtc lbtmc visit2 lbcode lbtestcd; run;

proc transpose data = lbcoagl_nr2 out = t_lbcoagl0(drop=_name_ _label_);
    by subject lbdtc lbtmc visit2 lbcode lbtryn lbtrsp __edc_treenodeid __edc_entrydate ; 
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
    set t_lbcoagl0(where=(0)) t_std0; ** so that all variables share same attribute;
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

proc sort data = t_lbcoagl0; by subject __edc_treenodeid; run;
proc sort data = t_std; by subject; run;

data pre_lbcoagl;
    set t_std t_lbcoagl0(in=__a__);
        by subject __edc_treenodeid;
    if __a__ then __ord = 2;
run;

proc sort data = pre_lbcoagl; by subject __ord lbdtc; run;

data out.lbcoagl(label = 'Coagulation Studies (Local Lab)');
    keep __edc_treenodeid __edc_entrydate subject lbdtc lbtmc visit2 lbcode lbtryn lbtrsp pt aptt inr;
    retain __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbcode lbtryn lbtrsp pt aptt inr;
    set pre_lbcoagl;
run;
