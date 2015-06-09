%include "_setup.sas";

data pe;
  set source.phy_examination (drop =peyn );
  ;
  subjid= strip(ssid);
  visit = put(STUDY_EVENT_OID, $visit.);
  __visitnum = input(put(visit,$visitnum.),best.);
  visitdt =substr(strip(event_start_date),1,10) ;
  peyn = peyn_LABEL;
  keep subjid visit visitdt peyn pend __visitnum;
run;

proc sql;
create table pe_ as
select a.* from pe as a where subjid in (select distinct b.subjid from pdata.dm as b);
quit;

proc sort data = pe_ nodupkey; by subjid __visitnum visitdt peyn pend;run;

data pdata.pe (label = 'Physical Examination');
    keep subjid visit visitdt peyn pend __visitnum ;
    retain subjid visit visitdt peyn pend __visitnum;
    attrib
    visit                  label = 'Visit'
    visitdt                  label = 'Visit Date'
    peyn                  label = 'Has the Physical Exam been Performed?'
    pend                 label = 'If Not Done, Please Specify Reason'
    ;
    set pe_;
run;

