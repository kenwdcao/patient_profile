/********************************************************************************
 Program Nmae: LBTSHL.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/25
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

proc format;
    value $lbtestcd
    'Thyroid Stimulating Hormone (TSH)' = 'TSH'
    'Free T4' = 'T4FR'
    'Free T3' = 'T3FR'
    'Anti-Thyroid Peroxidase Antibodies (Anti-TPO)' = 'ANTITPO'
    'Anti-Thyroglobulin Antibodies' = 'ANTITAB'
    'Total T3' = 'T3'    ;
run;

data lbtshl0;
    length cycle $20;
    set source.lbtshl(keep=edc_treenodeid edc_entrydate subject visit lbcat lbtmunk lbcode lbtest
                            lbnd lbsymb lborres lborresu lbunito seq lbdt lbtm);

    %subject;

    length lbtestcd $8;
    label lbtestcd = 'Lab Test Code';
    lbtestcd = put(lbtest, $lbtestcd.); ** test code to be used as variable name after transpose;
    

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

    cycle = cycle;
    %visit;

    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;

    ** variable that will be kept but will not be displayed;
    rename lbcat = __lbcat;

    __Result = 0; %IsNumeric(InStr= lborres, Result=__Result);
    if __Result = 1 then result = input(trim(left( lborres)), best.); else result = .;;
    drop __result   __instr __periodcount   __n;
run;

data lbtshl1;
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
    set lbtshl0;
    rc = h.find();
    rc2 = h2.find();
    %concatdy(lbdtc);
    drop rc rc2;
run;


/* !-- CODE TO BE ADDED HERE TO DERIVE NORMAL RANGE --*/

data lbtshl2;
    length rawtest $200 rawunit $40 rawcat $200;
    set lbtshl1;
    rawunit = upcase(lborresu2);
    rawtest = upcase(lbtest);
    rawcat = upcase(__lbcat);
    lbsex = upcase(sex);
    age = __age;
    rename lbtestcd = testcd01;
run;
***************************get LBSTRESU from dataset lb_master****************;
proc sort data = lbtshl2; by rawcat rawtest rawunit;run;

proc sort data = source.lb_master out = lb_master;
by rawcat rawtest rawunit;
run;

data lb_jn_master;
    merge lbtshl2(in=a) lb_master(in=b keep = rawcat rawtest rawunit cf lbtestcd lbstresu lbcat);
    by rawcat rawtest rawunit;
    if a;
    if a and not b then put "WARN" " ING:" subject= rawunit= rawtest=;
    if result ^=. and cf ^=. then lbstresn = result*cf;

    ** Ken Cao on 2015/03/25: Keep two digits after period;
    lbstresn = input(put(lbstresn, 10.2), best.);

run;

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

** mockup dataset;
data lbtshl_nr;
    set lb_jn_range;
    length __normrange $100;
    if lborresu2 = other_units then do;
        if low_other^=. then low_ = low_other;
        if high_other ^= . then high_ = high_other;
    end;
        else do;
        if low ^=. and cf ^=. then low_=low/cf;
        if high ^=. and cf ^=. then high_=high/cf;
        end;

    if low^=. and high ^=. then __normrange = strip(put(low_, best.))||" - "||strip(put(high_, best.)); 
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
    if index(lborres2,">=") and cf ^= . and high > . and input(compress(lborres2,">="),best.)>=(high/cf) then lbnrind = 'H';

    if lbnrind ='L' then do;
        lborres2 = "&escapechar{style [foreground=&belowcolor]"||strip(lborres2) ||" [L]"||"}";
    end;
    else if lbnrind ='H' then do; 
    lborres2 = "&escapechar{style [foreground=&abovecolor]"||strip(lborres2) ||" [H]"||"}";
    end;
run;

/*
 * fetch most frequently used unit of a lab test for a subject.
 */;

proc sql;
    create table _std0 as
    select distinct subject, lbtest,lbtestcd, lborresu2, __normrange, count(*) as nunit
    from lbtshl_nr
    group by subject, lbtest, lborresu2
    order by subject, lbtest, nunit
    ;

    create table _std1 as
    select subject, lbtest, lbtestcd, lborresu2, __normrange, nunit
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
    rename lborresu2 = __stdunit ; ** standard unit for this subject and this lab test;
    rename __normrange = __stdnr; ** standard unit for this subject and this lab test;
run;

data lbtshl_nr2;
    keep subject lbdtc lbtmc visit2 lbcode __edc_treenodeid __edc_entrydate lbtestcd lbtest lborres2 __stdunit __stdnr;
    length subject $13 lbtest $200 __stdunit $100 __stdnr $100;
    if _n_ = 1 then do;
        declare hash h (dataset:'_std');
        rc = h.defineKey('subject','lbtest');
        rc = h.defineData('__stdunit', '__stdnr');
        rc = h.defineDone();
        call missing(subject,lbtest, __stdunit, __stdnr);
    end;
    set lbtshl_nr;
    rc = h.find();
    drop rc;
    if __stdunit ^= lborresu2 and lborres2 ^= 'Not Reported' then lborres2 = strip(lborres2)||' '||strip(lborresu2);
    drop lborresu2;
run;

data temp;
    length lbtest $200 lbtestcd $40;
    del = 'Y';
    lbtest = 'Thyroid Stimulating Hormone (TSH)';lbtestcd = 'TSH'; output;
    lbtest = 'Total T3';lbtestcd = 'T3'; output;
    lbtest = 'Free T3';lbtestcd = 'T3FR'; output;
    lbtest = 'Free T4';lbtestcd = 'T4FR'; output;
    lbtest = 'Anti-Thyroid Peroxidase Antibodies (Anti-TPO)';lbtestcd = 'ANTITPO'; output;
    lbtest = 'Anti-Thyroglobulin Antibodies';lbtestcd = 'ANTITAB'; output;
run;

data lbtshl_nr3;
    set lbtshl_nr2 temp;
run;

proc sql;
    create table lbtshl_nr4 as select *, count(distinct del) as n from lbtshl_nr3
    order by subject, lbdtc, lbtmc, visit2, lbcode, lbtestcd;
quit;

data lbtshl_nr5;
    set lbtshl_nr4;
    if n >1 and del = 'Y' then delete;
run;

proc sort data = lbtshl_nr5; by subject lbdtc lbtmc visit2 lbcode lbtestcd; run;
proc transpose data = lbtshl_nr5 out = t_lbtshl0(drop=_name_ _label_);
    by subject lbdtc lbtmc visit2 lbcode __edc_treenodeid __edc_entrydate ; 
    id lbtestcd;
    idlabel lbtest;
    var lborres2;
run;

proc sort data = _std; by subject lbtest; run;
proc transpose data = _std out=t_std0(drop= _label_);
    by subject;
    id lbtestcd;
    idlabel lbtest;
    var __stdunit __stdnr;
run;

data t_std;
    set t_lbtshl0(where=(0)) t_std0; ** so that all variables share same attribute;
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

proc sort data = t_lbtshl0; by subject __edc_treenodeid; run;
proc sort data = t_std; by subject; run;

data pre_lbtshl;
    set t_std t_lbtshl0(in=__a__);
        by subject __edc_treenodeid;
    if __a__ then __ord = 2;
run;

proc sort data = pre_lbtshl; by subject __ord lbdtc; run;

data out.lbtshl(label = 'Thyroid Stimulating Hormones (Local Lab)');
    keep __edc_treenodeid __edc_entrydate subject lbdtc lbtmc visit2 lbcode tsh t4fr t3 t3fr antitpo antitab;
    retain __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbcode tsh t4fr t3 t3fr antitpo antitab;
    set pre_lbtshl;
    if subject ^='';
run;
