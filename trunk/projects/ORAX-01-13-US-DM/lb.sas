%include "_setup.sas";

option nofmterr;
data range;
  set source.lab_resultsranges;
  id=strip(ssid) || strip(LBRANGE_LABEL) || strip(event_start_date);
  id2=strip(ssid) || strip(LBRANGE_LABEL) ;
run;

data lb;
  set source.lab_resultsresults;
  id=strip(ssid) || strip(lbtest_label) || strip(event_start_date);
  id2=strip(ssid) || strip(lbtest_label);
run;

proc sql;
  create table lbr1 as
  select a.*, count( lbrange) as bb from range as a where LBORNRLO ^='' or LBORNRhi ^='' or LBORRESU ^='' group by ssid, lbrange 
  having bb >1;
  create table lbr2 as
  select a.*, count( lbrange) as bb , lbrange as lbtest from range as a where LBORNRLO ^='' or LBORNRhi ^='' or LBORRESU ^='' group by ssid, lbrange 
  having bb =1;
  create table lb3 as
  select * from range(where =(LBORNRLO ^='' or LBORNRhi ^='' or LBORRESU ^='' )) where id not in (select distinct id from lb);

  create table lb1 as
  select * from lb where id not in (select distinct id from range);
  create table lb111 as
  select * from lb where id2 not in (select distinct id2 from range);
  create table lb222 as
  select * from range where id not in (select distinct id from lb);

  create table lb2 as
  select * from lb where id in (select distinct id from range(where =(LBORNRLO ^='' or LBORNRhi ^='' or LBORRESU ^='' )));
quit;

proc sort data=lb; by id ; run;
proc sort data=range out=range2(keep=id lbrange LBORNRLO LBORNRHI LBORRESU); by id lbrange  ; run;

data lb20;
  merge lb(in=a) range2(in=b);
  by id;
  if a;
run;

data lb3_;
  set lb20 (drop =visit lbnrind rename=(lbtest = __lbtest lborres=lborres_));
  subjid= strip(ssid);
  visit = put(VISIT_LABEL, $avisit.);
  __visitnum=input(put(VISIT_LABEL, $avistn.),best.);
  visitdt =substr(strip(event_start_date),1,10) ;
  lbnrind=lbnrind_label;
  __lbcat = scan(lbtest_label,1,"-");
  lbtest = scan(lbtest_label,2,"-");
/*  lbtest=lbtest_label;*/
  if lborres_ ^='' and lbstresc ^='' then lborres= strip(lborres_) || " " || strip(lbstresc); else if lbstresc ^='' and lborres_ ='' then lborres= strip(lbstresc);
    else if lbstresc ='' and lborres_ ^='' then lborres= strip(lborres_);
/*  if substr(lborres,1,1)='.' then do; lborres='0' || strip(lborres);end;else if index(lborres,"<.2")>0 then do; lborres='<0.2';end;*/
  __lbstresc=lbstresc;
  keep subjid visit __visitnum __lbcat lbtest lbrefid lbdt lbtm lborres lbstresc lborresu lbornrlo lbornrhi lbnrind __lbtest EVENT_ORDINAL lbcom visitdt __lbstresc;
run;

proc sql;
create table lb3 as
select a.* from lb3_ as a where subjid in (select distinct b.subjid from pdata.dm as b);
quit;

proc sort data = lb3 ; by subjid __lbcat lbtest __visitnum visit __lbtest lbdt lbtm lborres __lbstresc lborresu lbrefid lbornrlo lbornrhi lbnrind lbcom ;run;
/*proc sort data = lb3 dupout=bb nodupkey ; by subjid __lbcat lbtest __visitnum visit __lbtest lbdt lbtm lborres __lbstresc lborresu lbrefid lbornrlo lbornrhi lbnrind lbcom ;run;*/


data lb4;
    set lb3;
    by subjid __lbcat;
    __n + 1;
    if first.__lbcat then __n = 1;
run;


data pdata.lb1(label = 'Lab-Chemistry') ;
    keep subjid visit __visitnum __lbtest __lbcat lbtest lbrefid lbdt lbtm lborres lborresu lbornrlo lbornrhi lbnrind lbcom __lbstresc;
    retain subjid visit __visitnum __lbtest __lbcat lbtest lbrefid lbdt lbtm lborres lborresu lbornrlo lbornrhi lbnrind lbcom __lbstresc;
    attrib
    visit                  label = 'Visit'
    lbtest                  label = 'Lab Test Name'
    lbrefid                  label = 'Lab Requisition Number'
    lbdt                label = 'Lab Collection Date'
    lbtm                  label = 'Lab Collection Time'
    lborres                 label = 'Lab Result'
    lborresu                 label = 'Unit'
    lbornrlo                label = 'Lab Range Lower Limit'
    lbornrhi                label = 'Lab Range Upper Limit'
    lbnrind                 label = 'Alert Flag'
    lbcom                  label = 'Lab Comment' ;
    set lb4(where=(__lbcat='Chemistry'));
/*    if subjid = '02-01' and __n > 600 then delete;*/
run;
data pdata.lb2(label = 'Lab-Hematology') ;
    keep subjid visit __visitnum __lbtest __lbcat lbtest lbrefid lbdt lbtm lborres lborresu lbornrlo lbornrhi lbnrind lbcom __lbstresc;
    retain subjid visit __visitnum __lbtest __lbcat lbtest lbrefid lbdt lbtm lborres lborresu lbornrlo lbornrhi lbnrind lbcom __lbstresc;
    attrib
    visit                  label = 'Visit'
    lbtest                  label = 'Lab Test Name'
    lbrefid                  label = 'Lab Requisition Number'
    lbdt                label = 'Lab Collection Date'
    lbtm                  label = 'Lab Collection Time'
    lborres                 label = 'Lab Result'
    lborresu                 label = 'Unit'
    lbornrlo                label = 'Lab Range Lower Limit'
    lbornrhi                label = 'Lab Range Upper Limit'
    lbnrind                 label = 'Alert Flag'
    lbcom                  label = 'Lab Comment' ;
    set lb3(where=(__lbcat='Hematology'));
run;

data pdata.lb3(label = 'Lab-Urinalysis') ;
    keep subjid visit __visitnum __lbtest __lbcat lbtest lbrefid lbdt lbtm lborres lborresu lbornrlo lbornrhi lbnrind lbcom __lbstresc;
    retain subjid visit __visitnum __lbtest __lbcat lbtest lbrefid lbdt lbtm lborres lborresu lbornrlo lbornrhi lbnrind lbcom __lbstresc;
    attrib
    visit                  label = 'Visit'
    lbtest                  label = 'Lab Test Name'
    lbrefid                  label = 'Lab Requisition Number'
    lbdt                label = 'Lab Collection Date'
    lbtm                  label = 'Lab Collection Time'
    lborres                 label = 'Lab Result'
    lborresu                 label = 'Unit'
    lbornrlo                label = 'Lab Range Lower Limit'
    lbornrhi                label = 'Lab Range Upper Limit'
    lbnrind                 label = 'Alert Flag'
    lbcom                  label = 'Lab Comment' ;
    set lb3(where=(__lbcat='Urinalysis'));
run;
