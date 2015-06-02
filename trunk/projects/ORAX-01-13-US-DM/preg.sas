%include "_setup.sas";

data preg;
  set source.preg_test;
  subjid= strip(ssid);
  visit = put(STUDY_EVENT_OID, $visit.);
  __visitnum = input(put(visit,$visitnum.),best.);
  visitdt =substr(strip(event_start_date),1,10) ;
  childbp = CHILDPOTENTIAL_LABEL;
  sample=SAMPLETYPE_LABEL;
  presult=PREGRESULT_LABEL;
  keep subjid visit visitdt childbp collectdt sample presult __visitnum;
run;

proc sql;
create table preg_ as
select a.* from preg as a where subjid in (select distinct b.subjid from pdata.dm as b);
quit;

proc sort data = preg_ nodupkey; by subjid __visitnum visitdt childbp collectdt sample presult;run;

data pdata.preg (label = 'Pregnancy Test');
    keep  subjid visit visitdt childbp collectdt sample presult __visitnum;
    retain  subjid visit visitdt childbp collectdt sample presult __visitnum;
    attrib
    visit                  label = 'Visit'
    visitdt                  label = 'Visit Date'
    childbp                  label = 'Is Subject Female/Childbearing Potential?'
    collectdt                 label = 'If Yes, Date Sample Collected'
    sample                  label = 'Sample'
    presult                 label = 'Result'
    ;
    set preg_;
run;

