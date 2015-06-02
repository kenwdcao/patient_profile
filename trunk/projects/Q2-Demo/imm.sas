/*********************************************************************
 Program Name: LB.sas
  @Author: Yan Zhang
  @Initial Date: 2015/02/02
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/05: Concatenate --DY to LBDTC.
 Ken Cao on 2015/03/11: Display "standard" unit and range for each 
                        subject in the first two records.
*********************************************************************/
%include "_setup.sas";

data lb;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    length rawcat rawtest $200 lbdtc $20 timec $10 rawunit $40;
    keep rawcat rawtest lbdtc timec rawunit visit lbrefid lbgrpid _lbtest_ unit lbstat lbreasnd lbmethod lbspec result subject lbstat lborres lbnam;
    set source.pcyc1121ca_qlab1(rename=(lbdtc = dtc)); 
    subject = substr(usubjid, 14);
    rawtest = upcase(lbtest);
    _lbtest_=lbtest;
    rawunit = upcase(lborresu);
    unit = lborresu;
    rawcat = upcase(lbcat);
    lbdtc = substr(dtc,1,10);

    rc = h.find();
    %concatDY(lbdtc);
    drop rc;

    timec = put(input(substr(dtc,12,5),time5.),time5.);
    __Result = 0; %IsNumeric(InStr= lborres, Result=__Result);
    if __Result = 1 then result = input(trim(left( lborres)), best.); else result = .;;
run;

proc sort data = lb; by rawcat rawtest rawunit;run;

proc sort data = source.lb_master out = lb_master;
by rawcat rawtest rawunit;
run;

proc sort data = lb;by rawcat rawtest rawunit;run;
proc sort data = source.lb_master out = lb_master;by rawcat rawtest rawunit;run;

data lb_jn_master;
    merge lb(in=a) lb_master(in=b);
    by rawcat rawtest rawunit;
    if a;
    if a and not b then put "WARN" "ING:" subject= rawunit= rawtest=;
    if result ^=. and cf ^=. then lbstresn = result*cf;
run;

*************Get sex age from dm *****************;
proc sort data = lb_jn_master; by subject;run;
data  lb_jn_master_age;
    merge lb_jn_master(in=a) pdata.dm(in=b keep = subject __age __sex);
    by subject;
    if a and b;
    lbsex = upcase(__sex);
    age = input(scan(__age,2,":"),best.);
run;

data lb_range(
        keep = tcd testcd test cat spec sex__ symbol_age_low_ agelow agehigh age_units_ symbol_range_low low symbol_range_high high stresu low_other high_other other_units);
    set source.lb_range;
    rename age_low_ = agelow age_high_=agehigh pcyc_low_range_lbstnrlo_ = low pcyc_high_range_lbstnrhi = high lbcat = cat lbtestcd = tcd lbtest = test
    lbspec = spec _low_range__other_units_ = low_other high_range_other_units_ = high_other from__other_units_ = other_units;
run;

**********Get Low, High from range dataset**************;
proc sort data = lb_range; by tcd testcd test cat spec sex__ symbol_age_low_ agelow agehigh age_units_ stresu symbol_range_low low symbol_range_high high descending other_units;run;
 
proc sort data = lb_range nodupkey dupout =aa;
by tcd testcd test cat spec sex__ symbol_age_low_ agelow agehigh age_units_ stresu symbol_range_low low symbol_range_high high;
run;

proc sql;
 create table lb_jn_range01 as
 select *
 from (select * from lb_jn_master_age) as a
    left join
    (select * from lb_range) as b 
 on a.lbcat = b.cat and a.lbtestcd = b.tcd and a.lbstresu=b.stresu and (a.lbsex=b.sex__ or b.sex__='BOTH' or b.sex__='') 
    and ((b.symbol_age_low_ = '>' and a.age>b.agelow) or (b.symbol_age_low_ = '<' and a.age<b.agelow) or (b.agelow^=. and b.agehigh=. and a.age>=b.agelow) or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.age<=b.agehigh)
         or (b.agelow=. and b.agehigh=.));
quit;

data lb_jn_range;
	set lb_jn_range01(rename=(low=low_ high=high_));
	if unit = other_units then low=low_other;
	else if low_ ^=. and cf ^=. then low = low_/cf;

	if unit = other_units then high=high_other;
	else if high_ ^=. and cf ^=. then high = high_/cf;
run;

** Ken Cao on 2015/03/11: Get "Standard" unit and range.;
proc sort data = lb_jn_range(keep=subject _lbtest_ lborres unit low high) nodup out = __std0(drop=lborres);
    by subject _lbtest_ ;
    where lborres > ' ';
run;

proc sql;
    create table __std1 as
    select distinct subject, _lbtest_, unit, low, high, count(*) as ntime
    from __std0
    group by subject, _lbtest_, unit;

    create table __std2 as
    select subject, _lbtest_, unit, low, high, ntime
    from __std1
    group by subject, _lbtest_
    having ntime = max(ntime)
    ;
quit;

proc sort data = __std2; by subject _lbtest_ unit; run;

data __std3;
    set __std2;
        by subject _lbtest_;
    if first._lbtest_ and not last._lbtest_ then do;
        put "WARN" "ING: More than one frequent units:" subject = _lbtest_=;
    end;
    if first._lbtest_;

    length __stdrange $255;
    if n(low, high) > 1 then __stdrange = ifc(low>., strip(put(low, best.)), ' ')||' - '||ifc(high>., strip(put(high, best.)), ' ');
    
    length __stdunit $255;
    __stdunit =  unit;

    keep subject  _lbtest_ __stdunit __stdrange;
run;

proc sort data = __std3; by subject _lbtest_; run;

proc transpose data = __std3 out = __std;
    by subject;
    id _lbtest_;
    idlabel _lbtest_;
    var __stdunit __stdrange;
run;

*************Derived LBNRIND ****************************;
data lb_nrind;
    length subject $13 _lbtest_ $100 __stdunit $255;
    if _n_ = 1 then do;
        declare hash h (dataset:'__std3');
        rc = h.defineKey('subject', '_lbtest_');
        rc = h.defineData('__stdunit');
        rc = h.defineDOne();
        call missing(subject, _lbtest_, __stdunit);
    end;

    length lbnrind $8 lbresult $255;
    keep rawcat rawtest lbdtc timec rawunit visit lbrefid lbgrpid _lbtest_ unit lbstat lbreasnd lbmethod lbspec 
         result subject lbstat low high lbnrind lbresult lbstresn lbnam;
    attrib visit            label = 'Visit'
            _lbtest_            label = 'Test'
            lbdtc           label = 'Collection Date'
            timec           label = 'Collection Time'
            lbresult        label = 'Result';

    set lb_jn_range; 
    rc = h.find();
 
    if low_ ^=. and high_ ^=. and lbstresn ^=. then do;
        if lbstresn < low_ then lbnrind = 'L';
        else if lbstresn > high_ then lbnrind = 'H';
        else if low_ <= lbstresn <= high_ then lbnrind = 'NORMAL';
    end;
    if index(lborres,">=") and cf ^= .  and input(compress(lborres,">="),best.)>=(high_/cf) then lbnrind = 'H';

    lbresult = lborres;
    if __stdunit ^= unit and unit > ' ' and lborres > ' ' then lbresult = strip(lborres)||" "||strip(unit);
    if lbstat > ' ' then lbresult = 'Not Done';

    if lbnrind = 'L' then do;
        lbresult = "&escapechar{style [foreground=&belowcolor]"||strip(lbresult) ||" [L]"||"}";
    end;
    else if lbnrind ='H' then do; 
        lbresult = "&escapechar{style [foreground=&abovecolor]"||strip(lbresult) ||" [H]"||"}";
    end;

    /*
    if lbnrind ='L' then do;
        lbresult = strip(lborres)||" "||strip(unit);
        lbresult = "&escapechar{style [foreground=&belowcolor]"||strip(lbresult) ||" [L]"||"}";
    end;
    else if lbnrind ='H' then do; 
    lbresult = strip(lborres)||" "||strip(unit);
    lbresult = "&escapechar{style [foreground=&abovecolor]"||strip(lbresult) ||" [H]"||"}";
    end;
            else if lborres ^= '' and unit ^='' then lbresult = strip(lborres)||" "||strip(unit);
                else if lborres ^= '' and unit ='' then lbresult = strip(lborres);
                else if lbstat ^='' then lbresult = 'Not Done';
    */
run;

proc sort data = lb_nrind; by subject rawcat lbdtc timec visit lbrefid lbgrpid lbreasnd lbmethod lbspec lbnam;run;
proc transpose data = lb_nrind out = lb_nrind_nm(
rename=(cd16_56_lymphocytes = cd1656le cd19_lymphocytes = cd19le cd3_lymphocytes = cd3le
cd4_lymphocytes = cd4le cd8_lymphocytes = cd8le ));
by subject rawcat lbdtc timec visit lbrefid lbgrpid lbreasnd lbmethod lbspec lbnam;
id _lbtest_;
idlabel _lbtest_;
var lbresult;
run;



data __stdimm;
    length subject $13;
    if _n_ = 1 then do;
        declare hash h (dataset:'lb_nrind_nm');
        rc = h.defineKey('subject');
        rc = h.defineDone();
        call missing(subject);
    end;
    set __std;
    rc = h.find();
    if rc = 0;
	rename cd16_56_lymphocytes = cd1656le cd19_lymphocytes = cd19le cd3_lymphocytes = cd3le
cd4_lymphocytes = cd4le cd8_lymphocytes = cd8le;
run;

data pdata.imm1(label= 'Immunology');
    keep subject __ord visit lbdtc timec lbgrpid lbrefid cd3 cd3le  cd4 cd4le lbreasnd;
    retain subject __ord visit lbdtc timec lbgrpid lbrefid cd3 cd3le  cd4 cd4le lbreasnd;
    set __stdimm(in=a ) lb_nrind_nm;
        by subject;
    if a then do;
        if _name_ = '__STDUNIT' then do;
            __ord = 0;
        end;
        else if _name_ = '__STDRANGE'  then do;
            __ord = 1;
        end;
    end;
    else __ord = 2;
run;

data pdata.imm2(label= 'Immunology (Continued)');
    keep subject __ord visit lbrefid  cd8 cd8le cd1656 cd1656le cd19 cd19le lbreasnd lbspec lbmethod lbnam ;
    retain subject __ord visit lbrefid cd8 cd8le cd1656 cd1656le cd19 cd19le lbreasnd lbspec lbmethod lbnam ;
    set __stdimm(in=a) lb_nrind_nm;
        by subject;
    if a then do;
        if _name_ = '__STDUNIT' then do;
            __ord = 0;
        end;
        else if _name_ = '__STDRANGE'  then do;
            __ord = 1;
        end;
    end;
    else __ord = 2;
run;
