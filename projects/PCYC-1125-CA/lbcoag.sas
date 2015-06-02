/*********************************************************************
 Program Name: LBCOAG.sas
  @Author: Xiaoli Huang
  @Initial Date: 2015/03/13

 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/


%include "_setup.sas";
data lbcoagl;
  length  lbtest01_	  lbtest02_	  lbtest03_	   $20 lborrs01_	lborrs02_	lborrs03_	 $200 LBORSU01_ LBORSU02_ LBORSU03_  $100;
  set source.lbcoagl;
if lbtest01 ^=. then lbtest01_ = put(lbtest01,LBTEST_A.);
if lbtest02 ^=. then  lbtest02_ = put(lbtest02,LBTEST_A.);
if lbtest03 ^=. then  lbtest03_ = put(lbtest03,LBTEST_A.);
lborrs01_ = coalescec (lbtest01_, strip(put(lborrs01, best.)));
lborrs02_ = coalescec (lbtest02_, strip(put(lborrs02, best.)));
lborrs03_ = coalescec (lbtest03_, strip(put(lborrs03, best.)));
LBORSU01_ = coalescec (LBOUNT01, strip(put(lborsu01,PTU.)));
LBORSU02_ = coalescec (LBOUNT02, strip(put(lborsu02,PTU.)));
LBORSU03_ = coalescec (LBOUNT03, strip(put(lborsu03,INRU.)));
  drop proj_id subinit state  lbdt lbtm LBORRS01 LBORSU01 LBOUNT01 LBTEST01 LBORRS02 LBORSU02 LBOUNT02
LBTEST02  LBORRS03 LBORSU03 LBOUNT03 LBTEST03  IS_LOCK ;
run;

proc sort data=lbcoagl out=coag; by site_id subid event_no event_id ;run;

proc transpose data=coag out=coag1;
  by site_id subid event_no event_id notsorted id lbnd lbcode lbdtc lbtmc lbtmunk LBORSU01_ LBORSU02_ LBORSU03_  ;
  var lborrs01_	lborrs02_	lborrs03_	;
run;

data coag2;
    length subject $255 rfstdtc $10 rawtest $200 rawunit $40;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set coag1 (rename = (lbdtc=__lbdtc  id=__id));
    %subject;
    rc = h.find();
    length lbdtc  $20;
    label lbdtc = 'Collection Date';
    lbdtc = __lbdtc;
    %concatDY(lbdtc);
if _NAME_ ="LBORRS01_" then rawtest ="PT";
if _NAME_ ="LBORRS02_" then rawtest ="PTT";
if _NAME_ ="LBORRS03_" then rawtest ="INR";
if _NAME_ ="LBORRS01_" then rawunit =LBORSU01_;
if _NAME_ ="LBORRS02_" then rawunit =LBORSU02_;
if _NAME_ ="LBORRS03_" then rawunit =LBORSU03_;
if col1 ^="." then lborrs= col1;else if col1="." then lborrs= "";
if  rawunit  ^="." then rawunit_ =rawunit;
if rawunit ^="." then rawunit= upcase(rawunit) ;else if rawunit ="." then rawunit="" ;
keep  EVENT_NO EVENT_ID __ID LBND LBCODE LBDTC LBTMC lbtmunk rawtest rawunit lborrs subject rawunit_ col1;
run;

proc sort data = coag2; by rawtest rawunit;run;

*****get lbtest from lb_master*****;
proc sort data = source.lb_master(where=(source='LBCOAGL')) out = lb_master(keep= rawcat rawtest lbtest lbcat lbtestcd) nodupkey ;
by rawtest lbtest lbcat lbtestcd rawcat;
run;

data lb_modify;
    merge coag2(in=a) lb_master(in=b);
    by rawtest ;
    if a;
	lbunit= rawunit;
run;
proc sort ; by lbtest rawunit ;run;

*****get lbunit , convf from lbconvf*****;
data lbconvf;
  set source.lbconvf(where=(lbcat='COAGULATION'));
  lbunit_= lbunit;
  lbtest_=lbtest;
run;

proc sort data = lbconvf out = convf(keep=lbtest_ lbunit_  lbtest lbunit conv lbstresu cnvu cnvcfact );by lbtest lbunit ;run;

data lbcoag1;
    merge lb_modify(in=a) convf (in=b);
    by lbtest lbunit ;
    if a;
    if lbunit ^= lbunit_ then do;
        put "WARN" "ING: LBCONVF"  lbtest=  lbunit= ;
    end;
    drop lbtest_ lbunit_;
run;

*************Get sex age from dm *****************;
proc sort data = lbcoag1; by subject;run;
data  lb_jn_master_age;
    merge lbcoag1(in=a) pdata.dm(keep = subject __age __sex);
    by subject;
    if a;
    lbsex = upcase(__sex);
    age = input(__age,best.);
run;

data lb_range(
        keep = tcd test cat spec lbmethod sex__ symbol_age_low_ agelow agehigh age_units_ symbol_range_low low symbol_range_high high stresu low_other high_other other_units);
    set source.lbrange;
    rename age_low = agelow     age_high_=agehigh      pcyc_low_range_lbstnrlo = low         pcyc_high_range_lbstnrhi = high       lbcat = cat        lbtestcd = tcd          lbtest = test
    lbspec = spec      low_range__other_units_ = low_other         high_range_other_units_ = high_other         from__other_units_ = other_units  LBSTRESU_PCYC_Standard_Units=stresu;
run;

**********Get Low, High from range dataset**************;
proc sort data = lb_range; by test tcd cat spec lbmethod sex__ symbol_age_low_ agelow agehigh age_units_ stresu symbol_range_low low symbol_range_high high descending other_units;run;
 
proc sort data = lb_range nodupkey dupout =aa;
by tcd  test cat spec lbmethod  sex__    symbol_age_low_   agelow agehigh age_units_  stresu  symbol_range_low  low    symbol_range_high    high;
run;

proc sql;
 create table lb_jn_range01 as
 select *  from (select * from lb_jn_master_age) as a
    left join  (select * from lb_range) as b 
 on a.lbtest = b.TEST and a.lbstresu=b.stresu and (a.lbsex=b.sex__ or b.sex__='BOTH' or b.sex__='') 
    and ((b.symbol_age_low_ = '>' and a.age>b.agelow) or (b.symbol_age_low_ = '<' and a.age<b.agelow) or (b.agelow ^=. and b.agehigh=. and a.age>=b.agelow) or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.age<=b.agehigh)
         or (b.agelow=. and b.agehigh=.));
quit;

data lb_jn_range;
    set lb_jn_range01(rename=(low=low_ high=high_));
	if rawunit = LBSTRESU then low=low_; else if rawunit = upcase(other_units) then low=low_other;
    else if low_ ^=. and conv ^=. then low = round(low_/conv,0.001);

    if rawunit = LBSTRESU then high=high_; else if rawunit = upcase(other_units) then high=high_other;
    else if high_ ^=. and conv ^=. then high = round(high_/conv,0.001);
    if index(lborrs ,"<")=0 and lborrs ^="" and index(lborrs,"Not") =0 and conv ^=. then lbstresn= input(lborrs,best.)*conv;
	else if index(lborrs ,"<")>0 and lborrs ^="" and index(lborrs,"Not") =0 and conv ^=. then lbstresn= input(compress(lborrs,"<"),best.)*conv;
run;

** Ken Cao on 2015/03/11: Get "Standard" unit and range.;
proc sort data = lb_jn_range01(keep=subject rawcat lbtest lbcat lbtestcd lborrs rawunit_ low high) nodup out = __std0(drop=lborrs);
    by subject rawcat lbtest ;
run;

proc sql;
    create table __std1 as
    select distinct subject,rawcat, lbtest,lbtestcd, rawunit_, low, high, count(*) as ntime
    from __std0 where rawunit_ ^=''
    group by subject, rawcat, lbtest, rawunit_ ;

    create table __std2 as
    select subject, rawcat, lbtest, lbtestcd,rawunit_, low, high
    from __std1
    group by subject, rawcat, lbtest
    having ntime = max(ntime)
    ;
quit;

proc sort data = __std2; by subject rawcat lbtest rawunit_; run;

data __std3;
    set __std2;
        by subject rawcat lbtest;
    if first.lbtest and not last.lbtest then do;
        put "WARN" "ING: More than one frequent units:" subject= rawcat= lbtest=;
    end;
    if first.lbtest;

    length __stdrange $255;
    if n(low, high) > 1 then __stdrange = ifc(low>., strip(put(low, best.)), ' ')||' - '||ifc(high>., strip(put(high, best.)), ' ');
    
    length __stdunit $255;
    __stdunit =  rawunit_;

    keep subject rawcat lbtestcd lbtest __stdunit __stdrange;
run;

proc sort data = __std3; by subject rawcat lbtestcd; run;

proc transpose data = __std3 out = __std;
    by subject rawcat ;
    id lbtestcd;
    idlabel lbtest;
    var __stdunit __stdrange;
run;


*************Derived LBNRIND ****************************;
data lb_nrind;
    length subject $255 rawcat $200 lbtest $40 __stdunit $255;
    if _n_ = 1 then do;
        declare hash h (dataset:'__std3');
        rc = h.defineKey('subject','rawcat' , 'lbtest');
        rc = h.defineData('__stdunit');
        rc = h.defineDOne();
        call missing(subject, rawcat, lbtest, __stdunit);
    end;

    length lbnrind $8 lbresult $255 ;
    attrib event_id            label = 'Visit'
            lbtest            label = 'Test'
            lbdtc           label = 'Collection Date'
            lbtmc           label = 'Collection Time'
            lbresult        label = 'Result'
            lbcode      label = 'Lab Code';

    set lb_jn_range;    

if index(lborrs,"<") = 0 then do;
    if low_ ^=. and high_ ^=. and lbstresn ^=. then do;
        if lbstresn < low_ then lbnrind = 'L';
        else if lbstresn > high_ then lbnrind = 'H';
        else if low_ <= lbstresn <= high_ then lbnrind = 'NORMAL';
    end;end;

    rc = h.find();
    lbresult = lborrs;
    if __stdunit ^= rawunit_ and rawunit_ > ' ' and lborrs > ' ' then lbresult = strip(lborrs)||" "||strip(rawunit_);
    if index(lborrs ,"Not Reported") >0 then lbresult = 'Not Reported';

    if lbnrind = 'L' then do;
        lbresult = "&escapechar{style [foreground=&belowcolor]"||strip(lbresult) ||" [L]"||"}";
    end;
    else if lbnrind ='H' then do; 
        lbresult = "&escapechar{style [foreground=&abovecolor]"||strip(lbresult) ||" [H]"||"}";
    end;

     visit=event_id;
	__event=event_no;
    keep subject visit  lbdtc lbtmc lbnd lbcode lbtest lbresult  rawcat lbtestcd lborrs low high conv lbtmunk rawunit_ __stdunit __id __event;
run;
proc sort data = lb_nrind; by subject lbdtc lbtmc __event  visit lbcode lbtestcd; run;

/*************** Transpose Lab Test **********************/

proc transpose data=lb_nrind out=t_coag(drop=_name_ _label_);
    by subject lbdtc lbtmc __event  visit lbcode lbnd __id lbtmunk;
    id lbtestcd;
    var lbresult;
run;

data __stdcoag;
    length subject $255;
    if _n_ = 1 then do;
        declare hash h (dataset:'t_coag');
        rc = h.defineKey('subject');
        rc = h.defineDone();
        call missing(subject);
    end;
    set __std;
    where rawcat = 'COAGULATION';
    rc = h.find();
    if rc = 0;
run;

data pdata.lbcoag(label='Coagulation Local');
    retain  __id subject __ord visit lbnd lbcode lbdtc lbtmc lbtmunk  PT APTT INR ;
    keep __id  subject __ord visit lbdtc lbtmc lbcode lbnd lbtmunk PT APTT INR ;
    set __stdcoag(in=a) t_coag ;
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
	attrib 
     visit label= "Visit"
	  pt label='PT'
	  APTT label='PTT'
	  inr label='INR';
run;
