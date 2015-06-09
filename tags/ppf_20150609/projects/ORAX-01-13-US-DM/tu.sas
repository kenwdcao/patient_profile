
%include "_setup.sas";

proc sort data=source.tumor_assessments out=s_tumor_assessments nodupkey; by _all_; run;
proc sort data=source.tumor_assessmentsassessments out=s_tumor_assessmentsassessments nodupkey; by _all_; run;

data tu_0;
      set s_tumor_assessmentsassessments(rename=(lestype=in_lestype));
	  attrib
	  cycle        length=$60      label = 'Cycle'
	  lesnum     length=8         label= 'Lesion Number'
	  lestype     length=$20      label = 'Lesion Type'
	  lessite      label='Site of Lesion'
	  method    length=$60      label ='Method'
	  metoth     length=$100    label='Other, Specify'
	  evaldtc     length=$19      label ='Date of Evaluation'
	  measure   length=$60      label ='Measurements'
	  response  length=$60      label ='Response'
	  ;

	  subjid=strip(ssid);
	  cycle=strip(CYCNUM_LABEL);
      lestype=strip(lestype_label);
	  method=strip(metheval_label);
	  metoth=strip(othspec);
      evaldtc=strip(dateeval);
	  if meastar^=. then measure=strip(put(meastar, best.));
	  response=strip(respon_label);

	  keep subjid STUDY_EVENT_OID EVENT_ORDINAL cycle lesnum lestype lessite method metoth evaldtc  measure response;
run;

data tu_1;
      set s_tumor_assessments;
	  attrib
	  targetsum        length=$60      label = 'Summary of Target Measurements'  
	  ;

	  subjid=strip(ssid);
	  if summeas^=. then targetsum=strip(put(summeas, best.));

	  keep STUDY_EVENT_OID EVENT_ORDINAL subjid targetsum;
run;

proc sort data=tu_0; by subjid study_event_oid cycle evaldtc lestype lesnum; run;

data tu_2;
      set tu_0;
	  by  subjid study_event_oid cycle evaldtc lestype lesnum;
	  if lestype='Target' then do;
	      if last.lestype then __sumflag='Y';
	  end;
run;

proc sql;
      create table tu_3 as
	  select a.*, b.targetsum from tu_2 as a left join tu_1 as b 
	  on a.subjid=b.subjid and a.study_event_oid=b.study_event_oid and a.event_ordinal=b.event_ordinal and a.__sumflag='Y';
quit;

data tu;
    set tu_3;
	if cycle='Screening' then __ord=0;
	   else if cycle='Final Visit' then __ord=99;
	   else __ord=input(cycle, best.);
run;

proc sort; by subjid __ord evaldtc lesnum lestype;

data pdata.tu(label='Tumor Assessments');
     retain subjid cycle lesnum lestype lessite method metoth evaldtc  measure response targetsum __ord;
	 set tu;
	 keep subjid cycle lesnum lestype lessite method metoth evaldtc  measure response targetsum __ord;
run;
