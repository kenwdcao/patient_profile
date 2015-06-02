
%include "_setup.sas";

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
run;

data eg0;
   set source.e_c_g;
   if ecgyn='1';
   keep ssid study_event_oid ECGDATE ECGTIME HEARTRT QRS QTINT PRINT QTC ECGRESULT ECGRESULT_LABEL CLINSIG;
run;

data eg1;
   set source.e_c_g2;
   if ecgyn2='1';
   rename
   ECGDATE2=ECGDATE
   ECGTIME2=ECGTIME
   HEARTRT2=HEARTRT
   QRS2=QRS
   QTINT2=QTINT
   PRINT2=PRINT
   QTC2=QTC
   ECGRESULT2=ECGRESULT
   ECGRESULT2_LABEL=ECGRESULT_LABEL
   CLINSIG2=CLINSIG;
   keep ssid study_event_oid ECGDATE2 ECGTIME2 HEARTRT2 QRS2 QTINT2 PRINT2 QTC2 ECGRESULT2 ECGRESULT2_LABEL CLINSIG2;
run;

data eg2;
   length visit normal signif abnormal $200;
   set eg0 eg1;
    %subjid;
   visit=put(strip(study_event_oid), $visit.);
   if upcase(ecgresult_label)='NORMAL' then normal='Y';
     else if index(upcase(ecgresult_label), 'ABNORMAL')>0 then normal='N';
   if normal='N' and ecgresult_label='Abnormal - not clinically significant' then signif='N';
     else if normal='N' and ecgresult_label='Abnormal - clinically significant' then signif='Y';
   abnormal=strip(clinsig);

run;

proc sql;
   create table eg as
   select a.*, b.__fdosedt from eg2 as a inner join pdata.dm as b on a.subjid=b.subjid;
quit;

data eg;
   length ecgdy heartrt print qrs qtint qtc $20;
   set eg(rename=(heartrt=in_heartrt print=in_print qrs=in_qrs qtint=in_qtint qtc=in_qtc));
   call missing(_dy);  %dy(ecgdate, mmddyy10.); dy = _dy;
   if dy^=. then ecgdy='Day '||strip(put(dy,best.));
   if in_heartrt^=. then heartrt=strip(put(in_heartrt, best.));
   if in_print^=. then print=strip(put(in_print, best.));
   if in_qrs^=. then qrs=strip(put(in_qrs, best.));
   if in_qtint^=. then qtint=strip(put(in_qtint, best.));
   if in_qtc^=. then qtc=strip(put(in_qtc, best.));
run;

proc sort data=eg; by subjid dy; run;

data pdata.eg(label='ECG Results');
    retain subjid visit ecgdy ecgtime heartrt print qrs qtint qtc normal signif abnormal;
    attrib
        visit    length = $200 label = 'Visit'
        ecgdy    length = $20  label = 'ECG Day'
        ecgtime    length = $40  label = 'ECG Time'
        heartrt     length = $20  label = 'Heart#Rate#(bpm)'
        print       length = $20  label = 'PR#Interval#(ms)'
        qrs     length = $20  label = 'QRS#Duration#(ms)'
        qtint     length = $20   label = 'QT#Interval#(ms)'
        qtc   length = $20  label = 'QTC#Interval#(ms)'
        normal    length = $200 label = 'Normal?'
        signif    length = $200 label = 'Significant?'
        abnormal    length = $200 label = 'Abnormalities'
    ;
	set eg;
    keep subjid visit ecgdy ecgtime heartrt print qrs qtint qtc normal signif abnormal;
run;
