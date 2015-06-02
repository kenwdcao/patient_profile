/*********************************************************************
 Program Name: QLAB.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/16
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";
%let sdsetname=%str(pcyc1123ca_qlab1_20150119_1);


data lab0;
   set source.&sdsetname;  
attrib SUBJECT  label="Subject Identifier" length=$13
       LBTMC label="Collection Time" length=$100;
SUBJECT=substr(scan(usubjid,4,"-"),2)|| "-" || scan(usubjid,5,"-");
lbtmc=substr(lbdtc,12,5);
lbdtc=strip(scan(lbdtc,1,"T"));
keep SUBJECT VISIT LBREFID LBCAT LBSCAT LBSPEC LBTESTCD LBTEST LBORRES LBORRESU LBSTRESC LBSTRESN LBSTRESU LBSTAT LBREASND LBNAM LBSPEC
        LBSPCCND LBMETHOD LBDTC lbtmc LBSTAT LBREASND
;
run;

proc sort data=lab0 out=lab0_(keep=LBTESTCD LBTEST LBSTRESU)  nodupkey; by LBTESTCD LBTEST LBSTRESU;run;

data lab1;
 set lab0_;
 attrib lblabel label="Test Label" length=$100;
 if LBSTRESU^="";
lblabel=strip(LBTEST)|| "#" || strip(LBSTRESU);
keep LBTESTCD LBTEST lblabel;
 run;

proc sort data=lab0; by  LBTESTCD LBTEST;run;
proc sort data=lab1; by  LBTESTCD LBTEST;run;
data lab2;
merge lab0(in=a) lab1;
 by  LBTESTCD LBTEST;
 if a;
 run;

data lab3;
    length subject $13 rfstdtc $10 sex $6 __age $40;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
        declare hash h2 (dataset:'pdata.dm');
        rc2 = h2.defineKey('subject');
        rc2 = h2.defineData('sex', '__age');
        rc2 = h2.defineDone();
        call missing(subject, rfstdtc, sex, __age);
    end;
    set lab2;
   
    rc = h.find();
    %concatDY(lbdtc);
    drop rc ;
    if lbstat^= "" then lbstresc = 'Not Done :' || strip(LBREASND);
    
    rc2 = h2.find();
    length age 8;
    age = input(__age, best.);


    length lborresn 8;
    __Result = 0; %isNumeric(Instr=lborres, Result=__Result);
    if __Result = 1 then lborresn = input(lborres, best.);
    
    length rawtest2 $255;
    rawtest2 = lbtest;

    lbcat = upcase(lbcat);
    lbtest = upcase(lbtest);
    lborresu = upcase(lborresu);

    rename lbcat = rawcat;
    rename lbtest = rawtest;
    rename lborresu = rawunit;

    drop lbtestcd  lbstresn lbstresc lbstresu;
run;


*** Ken Cao on 2015/04/20: Derive standard unit from LB_MASTER;
proc sql;
    create table lb_master_c as
    select * 
    from source.lb_master
    where 0
    ;
    /*
    insert into lb_master_c (rawcat, rawtest, rawunit,lbcat, lbtest, lbtestcd, lbstresu, cf)
    values('HEMATOLOGY', 'PLATELETS', '10E3/UL', 'HEMATOLOGY', 'Platelets', 'PLAT', '10^9/L', 1)
    values('THYROID STIMULATING HORMONE', 'TSH', 'MCU/ML', 'CHEMISTRY', 'Thyrotropin', 'TSH', 'mU/L', 1)
    */
    ;
quit;

data lb_master;
    set source.lb_master lb_master_c;
run;




** Get standard unit/test/test code/conversion factor from LB_MASTER;
data lab4(drop=notfound /*drop=rawcat rawtest rawunit*/) _masterFail(keep=rawcat rawtest rawunit);
    length rawcat lbcat rawtest $200 rawunit $200 lbtest lbtestcd lbstresu $40 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'lb_master');
        rc = h.defineKey('rawcat', 'rawtest', 'rawunit');
        rc = h.defineData('lbstresu', 'cf', 'lbtest', 'lbcat', 'lbtestcd');
        rc = h.defineDone();
        call missing(rawcat, rawtest, rawunit, lbstresu, cf, lbcat, lbtest, lbtestcd);
    end;
    set lab3;
    notfound = h.find();
    drop rc ;

    length lbstresn 8 lbstresc $255;
    if n(lborresn, cf) = 2 then lbstresn = lborresn * cf;
    lbstresc = ifc(lbstresn > ., strip(put(lbstresn, best.)), lborres);
    if lbstat^= "" and LBREASND^="" then lbstresc = 'Not Done:' || strip(LBREASND);

    if lborresn = . and   lborres not in ('', 'Not Done', 'Not Done / NA', 'Not reported') and cf not in (1, .) then do;
        put "WARN" "ING: Check those values: " rawcat= +3 rawtest= rawunit= +3 lbstresu= +3 lborres= +3 cf=;
    end;

    output lab4;
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




*** Ken Cao on 2015/04/20: Derive lab normal range;

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

    keep  lbtestcd lbtest lbcat lbspec lbmethod sex agelow agehigh lbstresu lbstnrlo lbstnrhi comments ;
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
    values('URINALYSIS', 'Specific Gravity', '', 'Female', 0, 1000, 1.002, 1.003)
    values('URINALYSIS', 'Specific Gravity', '', 'Male', 0, 1000, 1.002, 1.003)
    */
    ;
quit;

data lbrange;
    set lbrange0 lbrangec;

    length flag $1;
    flag = 'Y';

run;



proc sql;
    create table lab5 as
    select a.*, b.lbstnrlo, b.lbstnrhi, b.flag
    from lab4 as a left join lbrange as b
    on a.lbcat = b.lbcat
    and a.lbtest = b.lbtest
    and a.lbstresu = b.lbstresu
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
    set lab5(rename=(lbstresu=in_lbstresu));
    length lbstresu lbstnr $255;
    lbstresu = in_lbstresu;
    if n(lbstnrlo, lbstnrhi)> 0 then lbstnr = ifc(lbstnrlo=., ' ', strip(vvaluex('lbstnrlo')))||' - '||ifc(lbstnrhi=., ' ', strip(vvaluex('lbstnrhi')));
    drop in_lbstresu;
    
    if lbstresn ^=. and n(lbstnrlo, lbstnrhi) > 0 then do;
        if lbstresn < lbstnrlo then lbstresc = "&escapeChar.S={foreground=&belowcolor}"||strip(lbstresc)||' [L]';
        else if lbstresn > lbstnrhi > . then lbstresc = "&escapeChar.S={foreground=&abovecolor}"||strip(lbstresc)||' [H]';
    end;

run;



proc sort data=lab6; by subject visit  lbrefid lbdtc lbtmc;
proc transpose data=lab6 out=t_lab1(drop=_name_);
    by subject visit  lbrefid lbdtc lbtmc ;
    id lbtestcd;
    idlabel rawtest2;
    var LBSTRESC;
run;


proc sort data=lab6 nodupkey out=lab7_1(keep=subject lbtestcd rawtest2 lbstresu lbstnr); 
    by subject LBTESTCD; 
    where lbstresu ^= ' ' or lbstnr ^= ' ';
run;

proc sort data=lab6 nodupkey out=lab7_2(keep=subject lbtestcd rawtest2); 
    by subject LBTESTCD; 
run;

data lab7;
    merge lab7_2 lab7_1;
        by subject lbtestcd;
run;


proc transpose data=lab7 out=t_lab2;
    by subject;
    id lbtestcd;
    idlabel rawtest2;
    var lbstresu lbstnr;
run;

data t_lab3;
    set t_lab2(in=__in2) t_lab1(in=__in1);
        by subject;
    if __in2 then do;
        if _name_ = 'LBSTRESU' then __ord = 0;
        else __ord = 1;
    end;
    else if __in1 then __ord = 2;
    drop _name_;
run;

proc sort data=t_lab3; 
    by subject __ord lbdtc lbtmc visit lbrefid;
run;

data pdata.qlab1(label='T/B/NK Cell Counts (Central Lab)');
   retain   subject __ord visit lbdtc lbtmc lbrefid CD3 CD3LY CD4 CD4LY CD8 CD8LY ;
   keep    subject __ord visit  lbdtc lbtmc lbrefid CD3 CD3LY CD4 CD4LY CD8 CD8LY ;
       set t_lab3;
run;


data pdata.qlab2(label='T/B/NK Cell Counts (Central Lab, Continued)');
   retain   subject __ord visit  lbdtc lbtmc lbrefid CD19 CD19LY CD19ECC CD19EV CD1656 CD1656LY;
   keep    subject __ord visit lbdtc lbtmc lbrefid  CD19 CD19LY CD19ECC CD19EV CD1656 CD1656LY;
       set t_lab3;
run;
