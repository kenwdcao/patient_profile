%include '_setup.sas';

proc format;
  value $visit
"SE_SCREENING_7744" = "Screening"	
"SE_BASELINE_9186" = "Baseline"	
"SE_VISIT3" = "Visit 3"	
"SE_VISIT4" = "Visit 4"	
"SE_VISIT5" = "Visit 5"	
"SE_VISIT6" = "Visit 6"	
"SE_VISIT7" = "Visit 7"	
"SE_VISIT8" = "Visit 8"	
"SE_EARLYTERM_1267" = "Early Termination"	
"SE_UNSCHEDULED" = "Unscheduled"	
;

value $vnum
"SE_SCREENING_7744" = "-1"
"SE_BASELINE_9186" = "0"
"SE_VISIT3" = "3"
"SE_VISIT4" = "4"
"SE_VISIT5" = "5"
"SE_VISIT6" = "6"
"SE_VISIT7" = "7"
"SE_VISIT8" = "8"
"SE_EARLYTERM_1267" = "9"
"SE_UNSCHEDULED" = "10"
;
run;

proc sort data = source.vtsigns out = vtsigns; by ssid study_event_oid event_start_date; run;
proc sort data = source.temperature out = temperature; by ssid study_event_oid event_start_date; run;

data pre_vs;
  merge vtsigns  temperature(keep=ssid study_event_oid event_start_date temp);
  by ssid study_event_oid event_start_date;
run;

data vs1;
  length VISIT VSDTC $40;
  set source.kam_vitals  source.kam_vitals2 pre_vs;
  %subjid;
  if vitdate^='' then vsdtc = strip(vitdate); 
  if study_event_oid^='' then do; visit = strip(put(study_event_oid, $visit.));
     visitnum = input(strip(put(study_event_oid, $vnum.)), best.); end;
  if nmiss(systolic, diastolic, heartrt, resp, temp, weightkg1, bmi)^=7;
  keep ssid subjid systolic diastolic heartrt resp temp weightkg1 bmi visit visitnum vsdtc;
run;

proc sort data = vs1; by subjid visitnum; run;

data vs2;
   length subjid $20 __fdosedt 8 vsdy $20;
    if _n_ = 1 then
        do;
            declare hash h (dataset: 'pdata.dm');
            rc = h.defineKey('subjid');
            rc = h.defineData('__fdosedt');
            rc = h.defineDone();
            call missing(subjid, __fdosedt);
        end;
    set vs1(rename=(heartrt=heartrt_ temp=temp_ systolic=systolic_ diastolic=diastolic_ weightkg1=weightkg1_ bmi=bmi_ resp=resp_));
    rc = h.find();
    call missing(_dy);  %dy(vsdtc, mmddyy10.); 
	if _dy^=. then vsdy = strip(put(_dy, best.));
    if heartrt_^=. then heartrt=strip(put(heartrt_, best.));
    if temp_^=. then temp=strip(put(temp_, best.));
    if systolic_^=. then systolic=strip(put(systolic_, best.));
    if diastolic_^=. then diastolic=strip(put(diastolic_, best.));
    if weightkg1_^=. then weightkg1=strip(put(weightkg1_, best.));
    if bmi_^=. then bmi=strip(put(bmi_, best.));
    if resp_^=. then resp=strip(put(resp_, best.));

   label visit = 'Study Visit'
          vsdy = 'Study Day'
		  systolic = 'Systolic Blood#Pressure (mmHg)'
		  diastolic = 'Diastolic Blood#Pressure (mmHg)'
		  heartrt = 'Pulse#(beats/min)'
          resp = 'Respirations#(breaths/min)'
          temp = 'Temperature#(F)'
          weightkg1 = 'Weight#(kg)'
          bmi = 'BMI#(kg/m2)';
run;

proc sql;
  create table vs3 as
  select * from vs2 where subjid in (select distinct subjid from pdata.dm);
quit;

data pdata.vs(label = 'Vital Sign');
  retain SUBJID VISIT VSDY SYSTOLIC DIASTOLIC HEARTRT RESP TEMP WEIGHTKG1;
  keep SUBJID VISIT VSDY SYSTOLIC DIASTOLIC HEARTRT RESP TEMP WEIGHTKG1;
  set vs3;
run;
