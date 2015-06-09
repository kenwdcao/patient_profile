/********************************************************************************
 Program Nmae: LBURINE.sas
  @Author: Yan Zhang
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';
proc format;
    value $lbtestcd
    'Bilirubin' ='BILI'
    'Blood' = 'BLOOD'
    'Glucose' = 'GLUC'
    'Ketones' ='KETONES'
    'pH' = 'PH'
    'Protein' = 'PROT'
    'Specific Gravity' = 'GRAVITY';
run;

data lburine0;
    length cycle $10 lbtest $200;
    set source.lburine(keep=edc_treenodeid edc_entrydate subject visit lbcat lbtmunk lbcode lbtest
                            lbnd lborres lborreso seq lbdt lbtm lborres);

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
    drop lborres lbnd;

    cycle = cycle; ** in case that cycle is added in the furture.;
    %visit;

    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;

    ** variable that will be kept but will not be displayed;
    rename lbcat = __lbcat;

    __Result = 0; %IsNumeric(InStr= lborres, Result=__Result);
    if __Result = 1 then result = input(trim(left( lborres)), best.); else result = .;;

    if lborres= '' and lborreso ^='' then lborres2 = strip(lborreso)||" (Other Result)";
    else if lborres ^= '' and lborreso ^='' then lborres2 = strip(lborres)||", "||strip(lborreso)||" (Other Result)";
run;

data lburine1;
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
    set lburine0;
    rc = h.find();
    rc2 = h2.find();
    %concatdy(lbdtc);
    drop rc rc2;
run;


/* !-- CODE TO BE ADDED HERE TO DERIVE NORMAL RANGE --*/

data lburine2;
    length lbstresu $40 lbcat $40;
    set lburine1;
    if lbtest = 'Specific Gravity' then lbstresu = 'RATIO';
    else if lbtest = 'pH' then lbstresu = 'pH';
    lbcat = 'URINALYSIS';
    lbsex = upcase(sex);
    age = __age;
run;

data lb_range(
        keep = tcd test cat spec lbmethod sex__ symbol_age_low agelow agehigh age_units symbol_range_low low symbol_range_high high stresu);
    set source.lbrange;
    agelow = input(age_low,best.);
    rename age_high=agehigh pcyc_low_range_lbstnrlo = low pcyc_high_range_lbstnrhi = high lbcat = cat lbtestcd = tcd lbtest = test
    lbspec = spec sex = sex__ lbstresu_pcyc_standard_units = stresu;
run;

**********Get Low, High from range dataset**************;

proc sql;
 create table lb_jn_range as
 select *
 from (select * from lburine2) as a
    left join
    (select * from lb_range) as b 
 on a.lbcat = b.cat and a.lbtest = b.test and a.lbstresu=b.stresu and (a.lbsex=b.sex__ or b.sex__='BOTH' or b.sex__='') 
    and ((b.symbol_age_low = '>' and a.age>b.agelow) or (b.symbol_age_low = '<' and a.age<b.agelow) or (b.agelow^=. and b.agehigh=. and a.age>=b.agelow) or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.age<=b.agehigh)
         or (b.agelow=. and b.agehigh=.));
quit;

** mockup dataset;
data lburine_nr;
    set lb_jn_range;
    length __normrange $100 lbtest $200;

    if low^=. and high ^=. then __normrange = strip(put(low, best.))||" - "||strip(put(high, best.)); 
    ** normal range for this lab test and this lab unit and this subject;

************color code for result as below***********************;
    if low ^=. and high ^=. and result ^=. then do;
        if result < low then lbnrind = 'L';
        else if result > high then lbnrind = 'H';
        else if low <= result <= high then lbnrind = 'NORMAL';
    end;

    if lbnrind ='L' then do;
        lborres2 = "&escapechar{style [foreground=&belowcolor]"||strip(lborres2) ||" [L]"||"}";
    end;
    else if lbnrind ='H' then do; 
    lborres2 = "&escapechar{style [foreground=&abovecolor]"||strip(lborres2) ||" [H]"||"}";
    end;
run;

proc sql;
    create table _std as
    select distinct subject, lbtest, lbtestcd, __normrange
    from lburine_nr
    group by subject, lbtest
    order by subject, lbtest
    ;
quit;

proc sort data = lburine_nr; by subject lbdtc lbtmc visit2 lbcode lbtestcd; run;

proc transpose data = lburine_nr out = t_lburine0(drop=_name_ _label_);
    by subject lbdtc lbtmc visit2 lbcode __edc_treenodeid __edc_entrydate ; 
    id lbtestcd;
    idlabel lbtest;
    var lborres2;
run;

proc sort data = _std; by subject lbtest; run;
proc transpose data = _std out=t_std(drop = _name_);
    by subject;
    id lbtestcd;
    idlabel lbtest;
    var __normrange;
run;
data t_std;
    set t_lburine0(where=(0)) t_std; ** so that all variables share same attribute;
    __edc_entrydate = .;
    __edc_treenodeid = ' 1-'||strip(subject)||'-NR'; 
    __ord = 1;
run;

proc sort data = t_lburine0; by subject; run;
proc sort data = t_std; by subject; run;

data pre_lburine;
    set t_std t_lburine0(in=__a__);
    by subject;
    if __a__ then __ord = 2;
    else __ord = 1;
run;

proc sort data = pre_lburine; by subject __ord lbdtc; run;

data out.lburine(label = 'Urinalysis (Local Lab)');
    keep __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbcode gravity ph gluc bili ketones blood prot;
    retain __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbtmc lbcode gravity ph gluc bili ketones blood prot;
    set pre_lburine;
run;
