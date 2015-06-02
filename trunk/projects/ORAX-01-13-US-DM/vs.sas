%include "_setup.sas";

data vs1;
  set source.vt_signs(drop=sublgl);
  subjid= strip(ssid);
  visit = put(STUDY_EVENT_OID, $visit.);
  __visitnum = input(put(visit,$visitnum.),best.);
  visitdt =substr(strip(event_start_date),1,10) ;
  sublgl=sublgl_label;
  keep subjid visit __visitnum visitdt weight height bsa heartrt sublgl temp systolic diastolic resp;
run;

data vs2;
  set source.vt_signs2(drop=sublgl);
  subjid= strip(ssid);
  visit = put(STUDY_EVENT_OID, $visit.);
  __visitnum = input(put(visit,$visitnum.),best.);
  visitdt =substr(strip(event_start_date),1,10) ;
  sublgl=sublgl_label;
  keep subjid visit __visitnum visitdt weight heartrt sublgl temp systolic diastolic resp;
run;

data vs ;
  set vs1 vs2;
  if weight ^=. then weight_=put(weight,best.);
  if height ^=. then height_=put(height,best.);
  if heartrt ^=. then heartrt_=put(heartrt,best.);
  if bsa ^=. then bsa_=put(bsa,best.);
  if  temp ^=. then temp_=put(temp,best.);
  if systolic^=. then systolic_=put(systolic,best.); 
  if diastolic^=. then diastolic_=put(diastolic,best.);
  if resp ^=. then resp_=put(resp,best.);
run;

proc sort data=vs nodupkey ; by subjid __visitnum visitdt weight height bsa heartrt sublgl temp systolic diastolic resp ;run;

proc sql;
create table vs_ as
select a.* from vs as a where subjid in (select distinct b.subjid from pdata.dm as b);
quit;

data pdata.vs(label='Vital Signs');
  retain subjid visit __visitnum visitdt weight_ height_ bsa_ heartrt_ sublgl temp_ systolic_ diastolic_ resp_;
  attrib
  visit                  label = 'Visit'
  visitdt                  label = 'Visit Date'
  weight_     label = "Weight (lb)"   
  height_      label = "Height (in)"   
  bsa_      label = "BSA"   
  heartrt_      label = "Heart Rate (beats/min)"   
  sublgl      label = "Temperature Type"   
 temp_       label = "Temperature (C)"   
 systolic_       label = "Systolic Blood Pressure (mmHg)"   
  diastolic_      label = "Diastolic Blood Pressure(mmHg)"   
  resp_      label = "Respiration (breaths/min)"   ;
  set vs_;
  keep subjid visit __visitnum visitdt weight_ height_ bsa_ heartrt_ sublgl temp_ systolic_ diastolic_ resp_;
run;


