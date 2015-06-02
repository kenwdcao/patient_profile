/*********************************************************************
 Program Name: lbhep.sas
  @Author: Xiaoli Huang
  @Initial Date: 2015/03/13

 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";
data lbhepl;
  length  lborrs01_	  lborrs02_	  lborrs03_	  lborrs04_	  lborrs05_	  lborrs06_	   $100 ;
  set source.lbhep;
if lbtest01 ^=. then lbtest01_ = put(lbtest01,HEPB.);
if lbtest02 ^=. then  lbtest02_ = put(lbtest02,HEPB.);
if lbtest03 ^=. then  lbtest03_ = put(lbtest03,HEPB.);
if lbtest04 ^=. then  lbtest04_ = put(lbtest04,HEPB.);
if lbtest05 ^=. then  lbtest05_ = put(lbtest05,HEPB.);
if lbtest06 ^=. then  lbtest06_ = put(lbtest06,HEPB.);
if lborrs01 ^='' then lborrs01_ = compbl(lbtest01_ ||": "|| strip(lborrs01)); else lborrs01_ = strip(lbtest01_);
if lborrs02 ^='' then lborrs02_ = compbl(lbtest02_ ||": "|| strip(lborrs02));else lborrs02_ = strip(lbtest02_);
if lborrs03 ^='' then lborrs03_ = compbl(lbtest03_ ||": "|| strip(lborrs03));else lborrs03_ = strip(lbtest03_);
if lborrs04 ^='' then lborrs04_ = compbl(lbtest04_ ||": "|| strip(lborrs04));else lborrs04_ = strip(lbtest04_);
if lborrs05 ^='' then lborrs05_ = compbl(lbtest05_ ||": "|| strip(lborrs05));else lborrs05_ = strip(lbtest05_);
if lborrs06 ^='' then lborrs06_ = compbl(lbtest06_ ||": "|| strip(lborrs06));else lborrs06_ = strip(lbtest06_);
  drop proj_id subinit state  lbdt lbtm  LBTEST01	LBTEST02	LBTEST03	LBTEST04	LBTEST05  IS_LOCK ;
run;

proc sort data=lbhepl out=hep; by site_id subid event_no event_id ;run;

proc transpose data=hep out=hep1;
  by site_id subid event_no event_id notsorted id lbnd lbcode lbdtc lbtmc lbtmunk  ;
  var lborrs01_	lborrs02_	lborrs03_ lborrs04_	lborrs05_	lborrs06_	;
run;

data hep2;
    length subject $255 rfstdtc $10 rawtest $200 rawunit $40 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set hep1 (rename = (lbdtc=__lbdtc  id=__id));
    %subject;
    rc = h.find();
    length lbdtc  $20;
    label lbdtc = 'Collection Date';
    lbdtc = __lbdtc;
    %concatDY(lbdtc);
if _NAME_ ="LBORRS01_" then rawtest ="HEPATITIS B SURFACE ANTIGEN";
if _NAME_ ="LBORRS03_" then rawtest ="HEPATITIS C ANTIBODY";
if _NAME_ ="LBORRS06_" then rawtest ="HEPATITIS B SURFACE ANTIBODY";
if _NAME_ ="LBORRS02_" then rawtest ="HEPATITIS B CORE ANTIBODY";
if _NAME_ ="LBORRS04_" then rawtest ="HBV PCR";
if _NAME_ ="LBORRS05_" then rawtest ="HCV PCR";
if col1 ^="." then lborrs= col1;else if col1="." then lborrs= "";
rawunit=""; 
keep  EVENT_NO EVENT_ID __ID LBND LBCODE LBDTC LBTMC lbtmunk rawtest lborrs subject  col1 rawunit;
run;

proc sort data = hep2; by rawtest rawunit;run;

*****get lbtest from lb_master*****;
proc sort data = source.lb_master(where=(source='LBHEP')) out = lb_master(keep= rawcat rawtest lbtest lbcat lbtestcd cf rawunit lbstresu) nodupkey ;
by rawtest rawunit lbtest lbcat lbtestcd rawcat ;
run;

proc sort data = source.lb_master(where=(source='LBHEP')) out = lb_master0(keep= rawcat rawtest lbtest lbcat lbtestcd cf rawunit lbstresu) nodupkey ;
by rawtest  lbtest lbcat lbtestcd rawcat ;
run;

data lb_master0 ;
  set lb_master0;
  unitmaster = rawunit;
run;

data lb_modify;
    merge hep2(in=a) lb_master0(in=b);
    by rawtest ;
    if a;
    if rawunit ^=unitmaster then do;
        put "WARN" "ING: LB_MASTER " lbtest= unitmaster= ;
    end;
run;
proc sort ; by lbtest  ;run;

*************Get sex age from dm *****************;
proc sort data = lb_modify; by subject;run;
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
data lbhep;
    merge aa(in=a) bb (in=b );
    by lbtest ;
    if a ;
    if lbstresu ^= stresu  then do;
        put "WARN" "ING: LB_MASTER " lbtest= stresu= ;
    end;
run;
********end;

proc sql;
 create table lb_jn_range01 as
 select *  from (select * from lb_jn_master_age) as a
    left join  (select * from lb_range) as b 
 on a.lbtest = b.TEST and a.lbstresu= b.stresu and (a.lbsex=b.sex__ or b.sex__='BOTH' or b.sex__='') 
    and ((b.symbol_age_low_ = '>' and a.age>b.agelow) or (b.symbol_age_low_ = '<' and a.age<b.agelow) or (b.agelow ^=. and b.agehigh=. and a.age>=b.agelow) or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.age<=b.agehigh)
         or (b.agelow=. and b.agehigh=.));
quit;

data lb_jn_range;
    set lb_jn_range01(rename=(low=low_ high=high_));
	low=low_;
    high=high_; 
run;

** 2015/03/11: Get "Standard" unit and range.;
proc sort data = lb_jn_range01(keep=subject rawcat lbtest lbcat lbtestcd lborrs low high symbol_range_low symbol_range_high) nodup out = __std0(drop=lborrs);
    by subject rawcat lbtest ;
run;

data __std3;
    set __std0;
        by subject rawcat lbtest;
    if first.lbtest;

    length __stdrange $255;
    if n(low, high) > 1 then __stdrange = ifc(low>., strip(put(low, best.)), ' ')||' - '||ifc(high>., strip(put(high, best.)), ' ');
	  else if symbol_range_low ^='' then __stdrange = strip(symbol_range_low) || strip(put(low, best.));
    
    __stdunit =  "";

    keep subject rawcat lbtestcd lbtest  __stdrange __stdunit;
run;

proc sort data = __std3; by subject rawcat lbtestcd; run;

proc transpose data = __std3 out = __std;
    by subject rawcat ;
    id lbtestcd;
    var __stdunit __stdrange;
run;

*************Derived LBNRIND ****************************;
data lb_nrind;
    length subject $255 rawcat $200 lbtest $40  ;
    if _n_ = 1 then do;
        declare hash h (dataset:'__std3');
        rc = h.defineKey('subject','rawcat' , 'lbtest');
        rc = h.defineData();
        rc = h.defineDOne();
        call missing(subject, rawcat, lbtest, __stdunit);
    end;

    length lbresult $255 ;
    attrib event_id            label = 'Visit'
            lbtest            label = 'Test'
            lbdtc           label = 'Collection Date'
            lbtmc           label = 'Collection Time'
            lbcode      label = 'Lab Code';

    set lb_jn_range;    

    lbresult = lborrs;
    if index(lborrs ,"Not Reported") >0 then lbresult = 'Not Reported';
    lbnrind ="";
    visit=event_id;
	__event=event_no;
    keep   subject visit  lbdtc lbtmc lbnd lbcode lbtest lbresult  rawcat lbtestcd lborrs low high cf   __id __event lbtmunk;
run;
proc sort data = lb_nrind; by subject  lbdtc lbtmc __event visit lbcode lbtestcd ; run;


 /* Transpose Lab Test**************************/;

proc transpose data=lb_nrind out=t_hep(drop=_name_ );
    by subject  lbdtc lbtmc __event visit lbcode lbnd __id lbtmunk;
    id lbtestcd;
    var lbresult;
run;

data __stdhep;
    length subject $255;
    if _n_ = 1 then do;
        declare hash h (dataset:'t_hep');
        rc = h.defineKey('subject');
        rc = h.defineDone();
        call missing(subject);
    end;
    set __std;
    rc = h.find();
    if rc = 0;
run;

data pdata.lbhepa (label='Hepatitis Serologies Local');
    retain  __id subject __ord visit lbnd lbcode lbdtc lbtmc lbtmunk hcab hbsag hbsab hbcab hbvvld hcvvld ;
    keep __id  subject __ord visit lbdtc lbtmc lbtmunk lbcode lbnd  hcab hbsag hbsab hbcab hbvvld hcvvld ;
    set __stdhep(in=a) t_hep ;
        by subject;
    if _name_ = '__STDUNIT'  then do;
            __ord = 0;
        end;
    else if _name_ = '__STDRANGE'  then do;
            __ord = 1;
        end;
    else __ord = 2;   
	attrib 
	HCAB label="Hepatitis C Antibody"
HBSAG label="Hepatitis B Surface Antigen"
HBSAB label="Hepatitis B Surface Antibody"
HBCAB label="Hepatitis B Core Antibody"
HBVVLD label="HBV PCR"
HCVVLD label="HCV PCR"
visit label= "Visit";
run;
