%include "_setup.sas";

data ecg;
  set source.e_c_g (drop =ecgyn ecgresult);
  ;
  subjid= strip(ssid);
  visit = put(STUDY_EVENT_OID, $visit.);
  __visitnum = input(put(visit,$visitnum.),best.);
  visitdt =substr(strip(event_start_date),1,10) ;
  ecgyn = ECGYN_LABEL;
  ecgresult= ECGRESULT_LABEL;
  keep subjid visit __visitnum visitdt ecgyn ecgnd ecgdate ecgtime heartrt qrs qtint qtc ecgresult clinsig rrint print ;
run;

proc sql;
create table eg as
select a.* from ecg as a where subjid in (select distinct b.subjid from pdata.dm as b);
quit;

proc sort data = eg; by subjid __visitnum visitdt ecgyn;run;
proc sort data = eg out=eg1 nodupkey ; by subjid __visitnum visitdt ecgyn ecgnd ;run;
proc sort data = eg out=eg2 nodupkey; by subjid __visitnum visit visitdt ecgdate ecgtime heartrt qrs rrint qtint print qtc ecgresult clinsig;run;

data pdata.ecg1(label = "ECG Part 1");
    keep __visitnum subjid visit  visitdt ecgyn ecgnd ;
    retain __visitnum subjid visit visitdt ecgyn ecgnd ;
    attrib
    visit                  label = "Visit"
    visitdt                  label = "Visit Date"
    ecgyn                  label = "Was a 12-Lead ECG Performed?"
    ecgnd                 label = "If Not Done, Please Specify Reason"
    ;
    set eg1;
run;

data pdata.ecg2(label = "ECG Part 2");
    keep __visitnum subjid visit visitdt ecgdate ecgtime heartrt qrs rrint qtint print qtc ecgresult clinsig;
    retain __visitnum subjid visit visitdt ecgdate ecgtime heartrt qrs rrint qtint print qtc ecgresult clinsig;
    attrib
    visit                  label = "Visit"
    visitdt                  label = "Visit Date"
    ecgdate                     label = "Date Completed"
    ecgtime                     label = "Time Completed"
    heartrt                     label = "Heart Rate (bpm)"
    qrs                     label = "QRS (msec)"
    qtint                     label = "QT (msec)"
    print                     label = "PR (msec)"
    qtc                     label = "QTc (msec)"
    ecgresult                     label = "Result"
    clinsig                     label = "If Abnormal CS, Describe"
    rrint                     label = "RR (msec)";
set eg2;
run;
