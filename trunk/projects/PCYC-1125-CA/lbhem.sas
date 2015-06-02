/*********************************************************************
 Program Name: lbhema.sas
  @Author: Xiaoli Huang
  @Initial Date: 2015/03/13

 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";
data lbhem;
  length  lbtest01_	  lbtest02_	  lbtest03_	  lbtest04_	  lbtest05_	  lbtest06_	  lbtest07_	  lbtest08_	  lbtest09_	  lbtest10_	  lbtest11_	  lbtest12_	 
lbtest13_  $20
lborrs01_	lborrs02_	lborrs03_	lborrs04_	lborrs05_	lborrs06_	lborrs07_	lborrs08_	lborrs09_	lborrs10_	
lborrs11_	lborrs12_	lborrs13_	 $200 
LBORSU01_ LBORSU02_ LBORSU03_ LBORSU04_ LBORSU05_ LBORSU06_ LBORSU07_ LBORSU08_ LBORSU09_ 
LBORSU10_ LBORSU11_ LBORSU12_ LBORSU13_  $100;
  set source.lbheml;
if lbtest01 ^=. then lbtest01_ = put(lbtest01,LBTEST_A.);
if lbtest02 ^=. then  lbtest02_ = put(lbtest02,LBTEST_A.);
if lbtest03 ^=. then  lbtest03_ = put(lbtest03,LBTEST_A.);
if lbtest04 ^=. then  lbtest04_ = put(lbtest04,LBTEST_A.);
if lbtest05 ^=. then  lbtest05_ = put(lbtest05,LBTEST_A.);
if lbtest06 ^=. then  lbtest06_ = put(lbtest06,LBTEST_A.);
if lbtest07 ^=. then  lbtest07_ = put(lbtest07,LBTEST_A.);
if lbtest08 ^=. then  lbtest08_ = put(lbtest08,LBTEST_A.);
if lbtest09 ^=. then  lbtest09_ = put(lbtest09,LBTEST_A.);
if lbtest10 ^=. then  lbtest10_ = put(lbtest10,LBTEST_A.);
if lbtest11 ^=. then  lbtest11_ = put(lbtest11,LBTEST_A.);
if lbtest12 ^=. then  lbtest12_ = put(lbtest12,LBTEST_A.);
if lbtest13 ^=. then  lbtest13_ = put(lbtest13,LBTEST_A.);
lborrs01_ = coalescec (lbtest01_, strip(put(lborrs01, best.)));
lborrs02_ = coalescec (lbtest02_, strip(put(lborrs02, best.)));
lborrs03_ = coalescec (lbtest03_, strip(put(lborrs03, best.)));
lborrs04_ = coalescec (lbtest04_, strip(put(lborrs04, best.)));
lborrs05_ = coalescec (lbtest05_, strip(put(lborrs05, best.)));
lborrs06_ = coalescec (lbtest06_, strip(put(lborrs06, best.)));
lborrs07_ = coalescec (lbtest07_, strip(put(lborrs07, best.)));
lborrs08_ = coalescec (lbtest08_, strip(put(lborrs08, best.)));
lborrs09_ = coalescec (lbtest09_, strip(put(lborrs09, best.)));
lborrs12_ = coalescec (lbtest12_, strip(put(lborrs12, best.)));
if lbgl10 ^=. then do;lborrs10_ = coalescec (lbtest10_, "<"||strip(put(lborrs10, best.))); end;
  else do; lborrs10_ = coalescec (lbtest10_, strip(put(lborrs10, best.))); end;
if lbgl11 ^=. then do; lborrs11_ = coalescec (lbtest11_, "<"||strip(put(lborrs11, best.)));end;
  else do; lborrs11_ = coalescec (lbtest11_, strip(put(lborrs11, best.)));end;
lborrs13_ = coalescec (lbtest13_, strip(put(lborrs13, best.)));
LBORSU01_ = coalescec (LBOUNT01, strip(put(lborsu01,WBCU.)));
LBORSU02_ = coalescec (LBOUNT02, strip(put(lborsu02,RBCU.)));
LBORSU03_ = coalescec (LBOUNT03, strip(put(lborsu03,HGBU.)));
LBORSU04_ = coalescec (LBOUNT04, strip(put(lborsu04,HCTU.)));
LBORSU05_ = coalescec (LBOUNT05, strip(put(lborsu05,WBCU.)));
LBORSU06_ = coalescec (LBOUNT06, strip(put(lborsu06,BANDU.)));
LBORSU07_ = coalescec (LBOUNT07, strip(put(lborsu07,BANDU.)));
LBORSU08_ = coalescec (LBOUNT08, strip(put(lborsu08,BANDU.)));
LBORSU09_ = coalescec (LBOUNT09, strip(put(lborsu09,BANDU.)));
LBORSU10_ = coalescec (LBOUNT10, strip(put(lborsu10,BANDU.)));
LBORSU11_ = coalescec (LBOUNT11, strip(put(lborsu11,BANDU.)));
LBORSU12_ = coalescec (LBOUNT12, strip(put(lborsu12,BANDU.)));
LBORSU13_ = coalescec (LBOUNT13, strip(put(lborsu13,BANDU.)));

lbimmtr_ = put(lbimmtr, FFCFEEDA.);
  drop proj_id subinit state  lbdt lbtm LBORRS01 LBORSU01 LBOUNT01 LBTEST01 LBORRS02 LBORSU02 LBOUNT02
LBTEST02  LBORRS03 LBORSU03 LBOUNT03 LBTEST03 LBORRS04 LBORSU04 LBOUNT04 LBTEST04
 LBORRS05 LBORSU05 LBOUNT05 LBTEST05 LBORRS06 LBORSU06 LBOUNT06 LBTEST06  LBORRS09 LBORSU09 
LBOUNT09 LBTEST09 LBGL10 LBORRS10 LBORSU10 LBOUNT10 LBTEST10 LBGL11 LBORRS11 LBORSU11
LBOUNT11 LBTEST11 LBORRS12 LBORSU12 LBOUNT12 LBTEST12  LBORRS13 LBORSU13 LBOUNT13
LBTEST13  LBORRS08 LBORSU08 LBOUNT08 LBTEST08 LBORRS07 LBORSU07 LBOUNT07 LBTEST07  IS_LOCK  lbimmtr;
run;

proc sort data=lbhem out=hem; by site_id subid event_no event_id ;run;

proc transpose data=hem out=hem1;
  by site_id subid event_no event_id notsorted id lbnd lbcode lbdtc lbtmc lbtmunk LBORSU01_ LBORSU02_ LBORSU03_ LBORSU04_ LBORSU05_ LBORSU06_ LBORSU07_
LBORSU08_ LBORSU09_ LBORSU10_ LBORSU11_ LBORSU12_ LBORSU13_ lbimmtr_ lbimmtrs;
  var lborrs01_	lborrs02_	lborrs03_	lborrs04_	lborrs05_	lborrs06_	lborrs07_	lborrs08_	lborrs09_	lborrs10_	
lborrs11_	lborrs12_	lborrs13_;
run;

data hem2;
    length subject $255 rfstdtc $10 rawtest $200 rawunit $40;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set hem1 (rename = (lbdtc=__lbdtc  id=__id));
    %subject;
    rc = h.find();
    length lbdtc  $20;
    label lbdtc = 'Collection Date';
    lbdtc = __lbdtc;
    %concatDY(lbdtc);
if _NAME_ ="LBORRS01_" then rawtest ="WBC";
if _NAME_ ="LBORRS02_" then rawtest ="RBC";
if _NAME_ ="LBORRS03_" then rawtest ="HEMOGLOBIN";
if _NAME_ ="LBORRS04_" then rawtest ="HEMATOCRIT";
if _NAME_ ="LBORRS05_" then rawtest ="PLATELETS";
if _NAME_ ="LBORRS06_" then rawtest ="NEUTROPHILS";
if _NAME_ ="LBORRS07_" then rawtest ="BANDS";
if _NAME_ ="LBORRS08_" then rawtest ="LYMPHOCYTES";
if _NAME_ ="LBORRS09_" then rawtest ="MONOCYTES";
if _NAME_ ="LBORRS10_" then rawtest ="EOSINOPHILS";
if _NAME_ ="LBORRS11_" then rawtest ="BASOPHILS";
if _NAME_ ="LBORRS12_" then rawtest ="ATYPICAL LYMPHOCYTES";
if _NAME_ ="LBORRS13_" then rawtest ="PROLYMPHOCYTES";
if _NAME_ ="LBORRS01_" then rawunit =LBORSU01_;
if _NAME_ ="LBORRS02_" then rawunit =LBORSU02_;
if _NAME_ ="LBORRS03_" then rawunit =LBORSU03_;
if _NAME_ ="LBORRS04_" then rawunit =LBORSU04_;
if _NAME_ ="LBORRS05_" then rawunit =LBORSU05_;
if _NAME_ ="LBORRS06_" then rawunit =LBORSU06_;
if _NAME_ ="LBORRS07_" then rawunit =LBORSU07_;
if _NAME_ ="LBORRS08_" then rawunit =LBORSU08_;
if _NAME_ ="LBORRS09_" then rawunit =LBORSU09_;
if _NAME_ ="LBORRS10_" then rawunit =LBORSU10_;
if _NAME_ ="LBORRS11_" then rawunit =LBORSU11_;
if _NAME_ ="LBORRS12_" then rawunit =LBORSU12_;
if _NAME_ ="LBORRS13_" then rawunit =LBORSU13_;
if col1 ^="." then lborrs= col1;else if col1="." then lborrs= "";
if  rawunit  ^="." then rawunit_ =rawunit;
if rawunit ^="." then rawunit= upcase(rawunit) ;else if rawunit ="." then rawunit="" ;
keep  lbimmtr_ lbimmtrs EVENT_NO EVENT_ID __ID LBND LBCODE LBDTC LBTMC lbtmunk rawtest rawunit lborrs subject rawunit_ col1;
run;

proc sort data = hem2; by rawtest rawunit;run;

*****get lbtest from lb_master*****;
data lb_master;
  set source.lb_master;
  rawtest_= rawtest;
  rawunit1_=rawunit;
run; 

proc sort data = lb_master(where=(source='LBHEML')) out = lb_master(keep= rawcat rawtest lbtest lbcat lbtestcd rawunit lbstresu cf rawtest_ rawunit1_) nodupkey ;
by rawtest rawunit lbtest lbcat lbtestcd rawcat lbstresu cf;
run;

data lb_modify;
    merge hem2(in=a) lb_master(in=b);
    by rawtest rawunit;
    if a;
run;
proc sort ; by lbtest rawunit ;run;

proc sort data = lb_modify out=lbhem01 nodupkey; by rawtest rawunit rawunit1_ ;run;
data lbhem01;
  set lbhem01;
    if rawunit ^= upcase(rawunit1_) then do;
        put "WARN" "ING: LB_MASTER "  rawtest=  rawunit= ;
    end;
run;
*************Get sex age from dm *****************;
proc sort data = lb_modify(drop= rawtest_ ); by subject;run;

data  lb_jn_master_age;
    merge lb_modify(in=a) pdata.dm(keep = subject __age __sex);
    by subject;
    if a;
    lbsex = upcase(__sex);
    age = input(__age,best.);
run;

data lb_range(
        keep = tcd test cat spec lbmethod sex__ symbol_age_low_ agelow agehigh age_units_ symbol_range_low low symbol_range_high high stresu low_other high_other other_units);
    set source.lbrange(where=(lbcat='HEMATOLOGY'));
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
    set lb_jn_range01(rename=(low=low_ high=high_ cf=conv));
	if rawunit = LBSTRESU then low=low_; else if rawunit = upcase(other_units) then low=low_other;
    else if low_ ^=. and conv ^=. then low = round(low_/conv,0.001);

    if rawunit = LBSTRESU then high=high_; else if rawunit = upcase(other_units) then high=high_other;
    else if high_ ^=. and conv ^=. then high = round(high_/conv,0.001);

	    if index(lborrs ,"<")=0 and lborrs ^="" and index(lborrs,"Not") =0 and conv ^=. then lbstresn= input(lborrs,best.)*conv;
	else if index(lborrs ,"<")>0 and lborrs ^="" and index(lborrs,"Not") =0 and conv ^=. then lbstresn= input(compress(lborrs,"<"),best.)*conv;
    if index(lborrs ,"<")=0 and lborrs ^="" and index(lborrs,"Not") =0 then lborrs1 = input(lborrs,best.);
      else if index(lborrs ,"<")>0 and lborrs ^="" and index(lborrs,"Not") =0 then lborrs1 = input(compress(lborrs,"<"),best.);
run;

**  Get "Standard" unit and range.;
data lb_jn_range02;
  set lb_jn_range(rename =(lbtest=test1 lbtestcd=testcd)) ;
  length lbtest $255 lbtestcd $40;
  if test1= 'Basophils/Leukocytes' then do; lbtest='Basophils'; lbtestcd='BASO'; end;
    else if test1= 'Eosinophils/Leukocytes' then do; lbtest='Eosinophils'; lbtestcd='EOS'; end;
    else if test1= 'Lymphocytes/Leukocytes' then do; lbtest='Lymphocytes'; lbtestcd='LYM'; end;
    else if test1= 'Monocytes/Leukocytes' then do; lbtest='Monocytes'; lbtestcd='MONO'; end;
    else if test1= 'Basophils/Leukocytes' then do; lbtest='Basophils'; lbtestcd='BASO'; end;
    else if test1= 'Neutrophils Band Form/Leukocytes' then do; lbtest='Neutrophils Band Form'; lbtestcd='NEUTB'; end;
    else if test1= 'Neutrophils/Leukocytes' then do; lbtest='Neutrophils'; lbtestcd='NEUT'; end;
	else do;  lbtest=test1; lbtestcd=testcd; end;
run;

proc sort data = lb_jn_range02(keep=subject rawcat lbtest lbcat lbtestcd lborrs rawunit_ low high) nodup out = __std0(drop=lborrs);
    by subject rawcat lbtest ;
run;

proc sql;
    create table __std1 as
    select distinct subject,rawcat, lbtest,lbtestcd, rawunit_, low, high, count(*) as ntime
    from __std0 
    group by subject, rawcat, lbtest, rawunit_ ;

    create table __std2 as
    select subject, rawcat, lbtest, lbtestcd,rawunit_, low, high
    from __std1
    group by subject, rawcat, lbtest
    having ntime = max(ntime)    ;
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
    by subject rawcat;
    id lbtestcd;
    var __stdunit __stdrange;
run;


*************Derived LBNRIND ****************************;
data lb_nrind;
    length subject $255 rawcat $200 lbtest $255 __stdunit $255;
    if _n_ = 1 then do;
        declare hash h (dataset:'__std3');
        rc = h.defineKey('subject','rawcat' , 'lbtest');
        rc = h.defineData('__stdunit');
        rc = h.defineDOne();
        call missing(subject, rawcat, lbtest, __stdunit);
    end;

    length lbnrind $8 lbresult $255;
    attrib visit            label = 'Visit'
            lbtest            label = 'Test'
            lbdtc           label = 'Collection Date'
            lbtmc           label = 'Collection Time'
            lbcode      label = 'Lab Code';

    set lb_jn_range02;    

    if rawunit_ ^= other_units and low_ ^=. and high_ ^=. and lbstresn ^=. then do;
        if lbstresn < low_ then lbnrind = 'L';
        else if lbstresn > high_ then lbnrind = 'H';
        else if low_ <= lbstresn <= high_ then lbnrind = 'NORMAL';
    end;
 if rawunit_ = other_units and low ^=. and high ^=. and lborrs1 ^=. then do;
	  if lborrs1 < low then lbnrind = 'L';
      else if lborrs1 > high then lbnrind = 'H';
        else if low <= lborrs1 <= high then lbnrind = 'NORMAL';
    end;

    rc = h.find();
    lbresult = lborrs;
    if strip(__stdunit) ^= strip(rawunit_) and rawunit_ > ' ' and lborrs > ' ' then lbresult = strip(lborrs)||" "||strip(rawunit_);
    if index(lborrs ,"Not Reported") >0 then lbresult = 'Not Reported';

    if lbnrind = 'L' then do;
        lbresult = "&escapechar{style [foreground=&belowcolor]"||strip(lbresult) ||" [L]"||"}";
    end;
    else if lbnrind ='H' then do; 
        lbresult = "&escapechar{style [foreground=&abovecolor]"||strip(lbresult) ||" [H]"||"}";
    end;
    visit=event_id;
	__event=event_no;

    keep  subject visit  lbdtc lbtmc lbnd lbcode lbtest lbresult  lbimmtr_ lbimmtrs rawcat lbtestcd lborrs low high low_ high_ other_units  conv rawunit_ lbtmunk __id __event lbnrind;
run;

/*Transpose Lab Test *******************************/

proc sort data = lb_nrind; by subject lbdtc lbtmc __event visit lbcode lbtestcd ; run;

proc transpose data=lb_nrind out=t_hema(drop=_name_ );
    by subject lbdtc lbtmc __event visit lbcode  lbnd __id lbtmunk lbimmtr_ lbimmtrs;
    id lbtestcd;
	idlabel lbtest;
    var lbresult;
run;

data __stdhem;
    length subject $255;
    if _n_ = 1 then do;
        declare hash h (dataset:'t_hema');
        rc = h.defineKey('subject');
        rc = h.defineDone();
        call missing(subject);
    end;
    set __std;
    rc = h.find();
    if rc = 0;
run;

data pdata.lbhem1(label= 'Hematology Local');
    retain  __id subject __ord visit lbnd lbcode lbdtc lbtmc lbtmunk  wbc rbc hgb hct plat neut;
    keep  __id subject __ord visit lbdtc lbtmc lbtmunk lbcode lbnd wbc rbc hgb hct plat neut;
    set __stdhem(in=a) t_hema ;
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
	wbc label ="WBC"
	RBC label = "RBC";
run;

data pdata.lbhem2(label= 'Hematology Local (Continued)');
    retain __id subject __ord visit lbnd  neutb  lym mono  eos  baso  lymat prolym lbimmtr_ lbimmtrs;
    keep __id subject __ord visit lbnd neutb  lym mono  eos  baso  lymat prolym lbimmtr_ lbimmtrs;
    set __stdhem(in=a) t_hema;
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
    rename lbnd = __lbnd;
		attrib 
	neutb label ="Bands"
	lbimmtr_ label="Additional Immature Cells Listed"
   lbimmtrs  lable ="Additional Immature Cells Listed Specify"
	lymat label="Atypical lymphocytes";
run;

