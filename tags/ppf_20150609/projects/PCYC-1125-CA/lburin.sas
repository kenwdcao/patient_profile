/*********************************************************************
 Program Name: LBURIN.sas
  @Author: Xiaoli Huang
  @Initial Date: 2015/03/13

 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data lbual;
  length  lbtest01_	  lbtest02_	  lbtest03_	  lbtest04_	  lbtest05_	  lbtest06_	  lbtest07_  $20 
    lborrs01_	lborrs02_	lborrs03_	lborrs04_	lborrs05_	lborrs06_	lborrs07_ $200;
  set source.lbual;
if lbtest01 ^=. then lbtest01_ = put(lbtest01,LBTEST_A.);
if lbtest02 ^=. then  lbtest02_ = put(lbtest02,LBTEST_A.);
if lbtest03 ^=. then  lbtest03_ = put(lbtest03,LBTEST_A.);
if lbtest04 ^=. then  lbtest04_ = put(lbtest04,LBTEST_A.);
if lbtest05 ^=. then  lbtest05_ = put(lbtest05,LBTEST_A.);
if lbtest06 ^=. then  lbtest06_ = put(lbtest06,LBTEST_A.);
if lbtest07 ^=. then  lbtest07_ = put(lbtest07,LBTEST_A.);
lborrs01_ = coalescec (lbtest01_, strip(put(lborrs01, best.)));
lborrs02_ = coalescec (lbtest02_, strip(put(lborrs02, best.)));
lborrs03_ = coalescec (lbtest03_, strip(put(lborrs03, lborrs_c.)));
lborrs04_ = coalescec (lbtest04_, strip(put(lborrs04, lborrs_c.)));
lborrs05_ = coalescec (lbtest05_, strip(put(lborrs05, lborrs_c.)));
lborrs06_ = coalescec (lbtest06_, strip(put(lborrs06, lborrs_c.)));
lborrs07_ = coalescec (lbtest07_, strip(put(lborrs07, lborrs_c.)));
  drop proj_id subinit state  lbdt lbtm LBORRS01 LBTEST01	LBORRS02	LBTEST02	LBORRS03	LBTEST03	LBORRS04	LBTEST04	
LBORRS05	LBTEST05	LBORRS06	LBTEST06	LBORRS07	LBTEST07 IS_LOCK ;
run;

proc sort data=lbual out=ua; by site_id subid event_no event_id ;run;

proc transpose data=ua out=ua1;
  by site_id subid event_no event_id notsorted id lbnd lbcode lbdtc lbtmc lbtmunk   ;
  var lborrs01_	lborrs02_	lborrs03_ lborrs04_	lborrs05_	lborrs06_	lborrs07_	;
run;

data ua2;
    length subject $255 rfstdtc $10 rawtest $200 rawunit $40;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set ua1 (rename = (lbdtc=__lbdtc  id=__id));
    %subject;
    rc = h.find();
    length lbdtc  $20;
    label lbdtc = 'Collection Date';
    lbdtc = __lbdtc;
    %concatDY(lbdtc);
if _NAME_ ="LBORRS01_" then rawtest ="SPECIFIC GRAVITY";
if _NAME_ ="LBORRS02_" then rawtest ="PH";
if _NAME_ ="LBORRS03_" then rawtest ="GLUCOSE";
if _NAME_ ="LBORRS04_" then rawtest ="BILIRUBIN";
if _NAME_ ="LBORRS05_" then rawtest ="KETONES";
if _NAME_ ="LBORRS06_" then rawtest ="BLOOD";
if _NAME_ ="LBORRS07_" then rawtest ="PROTEIN";
if col1 ^="." then lborrs= col1;else if col1="." then lborrs= "";
rawunit ="" ;
keep  EVENT_NO EVENT_ID __ID LBND LBCODE LBDTC LBTMC lbtmunk rawtest lborrs subject  col1 rawunit;
run;

proc sort data = ua2; by rawtest ;run;

*****get lbtest and stresu from lb_master*****;
proc sort data = source.lb_master(where=(source='LBUAL')) out = lb_master(keep= rawcat rawunit rawtest lbtest lbcat lbtestcd lbstresu cf ) nodupkey ;
by rawtest rawunit lbtest lbcat lbtestcd rawcat;
run;

data lb_modify;
    merge ua2(in=a) lb_master(in=b);
    by rawtest rawunit;
    if a;
run;
proc sort ; by lbtest  ;run;

/*data lbua1;*/
/*    merge lb_modify(in=a) convf (in=b);*/
/*    by lbtest ;*/
/*    if a;*/
/*    if lbtest ^= lbtest_  then do;*/
/*        put "WARN" "ING: lbconvf" lbtest= ;*/
/*    end;*/
/*    drop lbtest_ ;*/
/*run;*/

*************Get sex age from dm *****************;
proc sort data = lb_modify; by subject ;run;
data  lb_jn_master_age;
    merge lb_modify(in=a) pdata.dm(keep = subject __age __sex);
    by subject;
    if a;
    lbsex = upcase(__sex);
    age = input(__age,best.);
run;

data lb_range(
        keep = tcd test cat spec lbmethod sex__ symbol_age_low_ agelow agehigh age_units_ symbol_range_low low symbol_range_high high stresu low_other high_other other_units);
    set source.lbrange;
	if lbcat='URINALYSIS';
    rename age_low = agelow     age_high_=agehigh      pcyc_low_range_lbstnrlo = low         pcyc_high_range_lbstnrhi = high       lbcat = cat        lbtestcd = tcd          lbtest = test
    lbspec = spec      low_range__other_units_ = low_other         high_range_other_units_ = high_other         from__other_units_ = other_units  LBSTRESU_PCYC_Standard_Units=stresu;
run;

**********Get Low, High from range dataset**************;
proc sort data = lb_range; by test tcd cat spec lbmethod sex__ symbol_age_low_ agelow agehigh age_units_ stresu symbol_range_low low symbol_range_high high descending other_units;run;
 
proc sort data = lb_range nodupkey dupout =aa;
by  test stresu tcd cat spec lbmethod  sex__    symbol_age_low_   agelow agehigh age_units_    symbol_range_low  low    symbol_range_high    high;
run;

*******unit not in lb_master*******;
proc sort data=lb_jn_master_age out=aa nodupkey; by lbtest lbstresu;run;
data lb_range_ ;
  set lb_range ;
  lbtest =test;
run;
proc sort data=lb_range_ out=bb(keep = test stresu lbtest)  nodupkey; by lbtest stresu ;run;
data lbua1;
    merge aa(in=a) bb (in=b );
    by lbtest ;
    if a ;
    if lbstresu ^= stresu  then do;
        put "WARN" "ING: LB_MASTER " lbtest= stresu= ;
    end;
run;


proc sql;
 create table lb_jn_range01 as
 select *  from (select * from lb_jn_master_age) as a
    left join  (select * from lb_range) as b 
 on a.lbtest = b.TEST and (a.lbsex=b.sex__ or b.sex__='BOTH' or b.sex__='') 
    and ((b.symbol_age_low_ = '>' and a.age>b.agelow) or (b.symbol_age_low_ = '<' and a.age<b.agelow) or (b.agelow ^=. and b.agehigh=. and a.age>=b.agelow) or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.age<=b.agehigh)
         or (b.agelow=. and b.agehigh=.));
quit;

data lb_jn_range;
    set lb_jn_range01(rename=(low=low_ high=high_));
	low=low_;
    high=high_; 
run;

** 2015/03/11: Get "Standard" unit and range.;
proc sort data = lb_jn_range01(keep=subject rawcat lbtest lbcat lbtestcd lborrs low high) nodup out = __std0(drop=lborrs);
    by subject rawcat lbtest ;
run;

data __std3;
    set __std0;
        by subject rawcat lbtest;
    if first.lbtest;

    length __stdrange $255;
    if n(low, high) > 1 then __stdrange = ifc(low>., strip(put(low, best.)), ' ')||' - '||ifc(high>., strip(put(high, best.)), ' ');
    __stdunit ="";
    keep subject rawcat lbtestcd lbtest  __stdrange __stdunit;
run;

proc sort data = __std3; by subject rawcat lbtestcd; run;

proc transpose data = __std3 out = __std;
    by subject rawcat ;
    id lbtestcd;
    var __stdunit __stdrange ;
run;

*************Derived LBNRIND ****************************;
data lb_nrind;
    length subject $255 rawcat $200 lbtest $40  ;
    if _n_ = 1 then do;
        declare hash h (dataset:'__std3');
        rc = h.defineKey('subject','rawcat' , 'lbtest');
        rc = h.defineData();
        rc = h.defineDOne();
        call missing(subject, rawcat, lbtest);
    end;

    length lbnrind $8 lbresult $255 ;
    attrib event_id            label = 'Visit'
            lbtest            label = 'Test'
            lbdtc           label = 'Collection Date'
            lbtmc           label = 'Collection Time'
            lbcode      label = 'Lab Code';

    set lb_jn_range;    
    if cf ^=. and lborrs ^='' and lbnd =. and lborrs not in ('Large' 'Small' 'Trace' 'Neg' 'Moderate' 'Not Reported Checked') then lbstresn = input(strip(lborrs),best.)*cf;
    if index(lborrs,"<") = 0 then do;
    if low_ ^=. and high_ ^=. and lbstresn ^=. then do;
        if lbstresn < low_ then lbnrind = 'L';
        else if lbstresn > high_ then lbnrind = 'H';
        else if low_ <= lbstresn <= high_ then lbnrind = 'NORMAL';
    end;end;

    rc = h.find();
    lbresult = lborrs;
    if index(lborrs ,"Not Reported") >0 then lbresult = 'Not Reported';

    if lbnrind = 'L' then do;
        lbresult = "&escapechar{style [foreground=&belowcolor]"||strip(lbresult) ||" [L]"||"}";
    end;
    else if lbnrind ='H' then do; 
        lbresult = "&escapechar{style [foreground=&abovecolor]"||strip(lbresult) ||" [H]"||"}";
    end;
    visit=event_id;
	__event=event_no;
    keep   subject visit  lbdtc lbtmc lbnd lbcode lbtest lbresult  rawcat lbtestcd lborrs low high cf   __id __event lbtmunk lbnrind lbstresn low_ high_  ;
run;
proc sort data = lb_nrind; by subject lbdtc lbtmc __event  visit lbcode lbtestcd; run;


 /* Transpose Lab Test******************/;

proc transpose data=lb_nrind out=t_ua(drop=_name_ );
    by subject  lbdtc lbtmc __event visit lbcode lbnd __id lbtmunk;
    id lbtestcd;
	idlabel lbtest;
    var lbresult;
run;

data __stdua;
    length subject $255;
    if _n_ = 1 then do;
        declare hash h (dataset:'t_ua');
        rc = h.defineKey('subject');
        rc = h.defineDone();
        call missing(subject);
    end;
    set __std;
    rc = h.find();
    if rc = 0;
run;

data pdata.lburin(label='Urinalysis Local');
    retain  __id subject __ord visit lbnd lbcode  lbdtc lbtmc lbtmunk spgrav pH gluc bili ketones blood prot ;
    keep __id  subject __ord visit lbcode lbnd lbdtc lbtmc lbtmunk spgrav pH gluc bili ketones blood prot ;
    set __stdua(in=a) t_ua ;
        by subject;
		if a then do;
        if _name_ = '__STDUNIT' then do;
            __edc_treenodeid = ' 0-'||strip(subject)||'-Unit'; 
            __ord = 0;
        end;
        else if _name_ = '__STDRANGE'  then do;
            __edc_treenodeid = ' 1-'||strip(subject)||'-NR'; 
            __ord = 1;
        end;
	end;
    else __ord = 2;
   attrib 
   visit label= "Visit";
run;
