
%include "_setup.sas";

proc sort data=source.study_end out=s_study_end nodupkey; by _all_; run;
proc sort data=source.best_overall_response out=s_best_overall_response nodupkey; by _all_; run;

data end;
     set s_study_end(rename=(dscomp=in_dscomp dsreas=in_dsreas));
	 attrib 
     dscomp      length=$3      label='Complete Study?'
	 dtcddtc       length=$19    label='Date of Study Completion or Early Discontinuation'
	 dtlastc        length=$19    label='Date of Last Study Dose'
	 dsreas        length=$200    label='Primary reason for discontinuation'
	 dsreaoth     length=$200    label='Other, Specify'
	 deathdtc        length=$19    label='Date of Death'
	 lastcontdtc        length=$19    label='Date of Last Contact'
	 ;

	 subjid=ssid;
	 dscomp=strip(dscomp_label);
	 dtcddtc=strip(dtcddt);
	 dtlastc=strip(dtlast);
	 dsreas=strip(dsreas_label);
	 dsreaoth=strip(dsreasp);
	 deathdtc=strip(deathdt);
	 lastcontdtc=strip(lastcontdt);

	 keep subjid dscomp dtcddtc dtlastc dsreas dsreaoth deathdtc lastcontdtc;
run;

data resp;
     set s_best_overall_response;
	 attrib
      bestresp   length=$40     label = 'Best Overall Response'
     ;

	 subjid=ssid;
	 bestresp=strip(OVERRESP_LABEL);
	 keep subjid bestresp;
run;

proc sql;
    create table end_resp as
	select a.*, b.subjid as subjid_resp, b.bestresp from end as a full join resp as b on a.subjid=b.subjid;
quit;

data end_resp;
    set end_resp;
    subjid=coalescec(subjid, subjid_resp);
run;

proc sql;
    create table studyend as
	select a.* from end_resp as a inner join pdata.dm as b on a.subjid=b.subjid;
quit;

proc sort; by subjid; run;

data pdata.end(label='End of Study');
     retain subjid dscomp dtcddtc dtlastc dsreas dsreaoth deathdtc lastcontdtc bestresp;
	 set studyend;
	 keep subjid dscomp dtcddtc dtlastc dsreas dsreaoth deathdtc lastcontdtc bestresp;
run;


