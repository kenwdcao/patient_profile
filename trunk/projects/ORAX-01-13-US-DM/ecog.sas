%include "_setup.sas";

data ecog;
  set source.ecog_performance_status (drop =ecogstat ecoginv );
  ;
  subjid= strip(ssid);
  visit = put(STUDY_EVENT_OID, $visit.);
  __visitnum = input(put(visit,$visitnum.),best.);
  visitdt =substr(strip(event_start_date),1,10) ;
  ecogstat =  compbl(ECOGSTAT_LABEL);
  ecoginv = compbl(ECOGINV_LABEL);
  keep subjid visit visitdt ecogstat ecoginv __visitnum;
run;

proc sql;
create table ecog_ as
select a.* from ecog as a where subjid in (select distinct b.subjid from pdata.dm as b);
quit;

proc sort data = ecog_ nodupkey; by subjid __visitnum visitdt ecogstat ecoginv;run;

data pdata.ecog (label = "ECOG Performance Status");
    keep subjid visit visitdt ecogstat ecoginv __visitnum ;
    retain subjid visit visitdt ecogstat ecoginv __visitnum;
    attrib
    visit                  label = "Visit"
    visitdt                  label = "Visit Date"
    ecogstat                  label = "What is Subject's ECOG Performance Status?"
    ecoginv                 label = "What is the Investigator's Assessment of ECOG Performance Status?"
    ;
    set ecog_;
run;

