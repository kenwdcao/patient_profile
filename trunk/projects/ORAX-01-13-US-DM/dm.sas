
%include "_setup.sas";

**** demographics ****;
proc sort data=source.informed_consent_demographics out=s_informed_consent_demographics nodupkey; by _all_; run;

data dm_0;
      set s_informed_consent_demographics(rename=(gender=in_gender ethnic=in_ethnic race=in_race));
     attrib
        studyid     length = $20      label = 'Study Identfier'
        infdtc       length = $19      label = 'Date of Informed Consent'
		brthdtc     length = $19      label = 'Date of Birth'
        age        length = $20      label = 'Age [1]'
		gender     length = $20      label = 'Gender'
		ethnic      length = $40      label = 'Ethnicity: Hispanic/Latino'
        race        length = $200     label = 'Race'
        raceoth    length = $200     label = 'Other, Specify'
    ;

    studyid = 'ORAX-01-13-US';
	subjid=strip(ssid);
	infdtc=infcdt;
	brthdtc=brthdt;
	if length(strip(infcdt))=10 and length(strip(brthdt))=10 then do;
      __age = int((input(infcdt, yymmdd10.) - input(brthdt, yymmdd10.) + 1) / 365.25); end;
	if __age^=. then age=strip(put(__age, best.));
    gender=strip(gender_label);
	ethnic=strip(ethnic_label);
	race=strip(race_label);
	raceoth=strip(otspcfy);
	rename subinit=__subinit;
	
    keep studyid subjid subinit infdtc brthdtc __age age gender ethnic race raceoth;
run;

proc sort data=dm_0 nodupkey; by _all_; run;

**** center information ***;
proc sort data=source.study_subject_listing out=s_study_subject_listing nodupkey; by _all_; run;

data dm_1;
     set s_study_subject_listing;
     attrib
      __center       length = $100      label = 'Center'
     ;

	subjid=strip(ssid);
	if subjid='02- SF1' then subjid='02-SF1';
    __center = strip(site_protocol_name) || '/' || site_name;
    rename sex=__sex;
    keep subjid __center sex;
run;

proc sort data=dm_1 nodupkey; by _all_; run;

**** dose regimen and dose group ****;
proc sort data=source.drug_administration out=s_drug_administration nodupkey; by _all_; run;

data dose_0;
    set s_drug_administration(where=(drugcyc=1 and drugday<=7));
	subjid=strip(ssid);
    keep subjid STUDY_EVENT_OID EVENT_START_DATE ADMINTYP ADMINTYP_LABEL ADMINDT DRUGPART DRUGPART_LABEL DRUGCYC DRUGCYC_LABEL DRUGDAY DRUGDAY_LABEL ADMINTM DOSEADM DRUGRED DRUGRED_LABEL ;
run;

proc sort data=dose_0 out=dose_1 dupout=dose_dup nodupkey; by _all_; run;

proc sort data=dose_1; by subjid admintyp admindt admintm drugday; run;

/*proc sql;*/
/*     create table dose_n as*/
/*	 select distinct a.subjid, b.dose_hm, b.n_hm, c.dose_p, c.n_p from dose_1 as a */
/*	 left join (select distinct subjid, doseadm as dose_hm, count(*) as n_hm from dose_1 where admintyp=1 group by subjid) as b on a.subjid=b.subjid*/
/*	 left join (select distinct subjid, doseadm as dose_p, count(*) as n_p from dose_1 where admintyp=2 group by subjid) as c on a.subjid=c.subjid*/
/*     ;*/
/*quit;*/

proc sql;
     create table dose_2 as
	 select distinct a.subjid, a.drugpart_label,  b.n_hm,  c.n_p from dose_1 as a 
	 left join (select distinct subjid, count(*) as n_hm from dose_1 where admintyp=1 group by subjid) as b on a.subjid=b.subjid
	 left join (select distinct subjid, count(*) as n_p from dose_1 where admintyp=2 group by subjid) as c on a.subjid=c.subjid
     ;
quit;

data dm_2;
    length __dgroup $100;
    set dose_2;
	if drugpart_label='1A' and n_hm=1 then do;  __dgroup='Part 1A Arm 1'; end;
	  else if drugpart_label='1A' and n_hm>1 then do;  __dgroup='Part 1A Arm 2'; end;
	  else if drugpart_label='1B' and n_hm>1 then do;  __dgroup='Part 1B'; end;
	  else if drugpart_label='2' and n_hm>1 then do;  __dgroup='Part 2'; end;
	keep subjid __dgroup;
run;

proc sort data=dm_0; by subjid; run;
proc sort data=dm_1; by subjid; run;
proc sort data=dm_2; by subjid; run;

data dm;
     merge dm_0(in=in0) dm_1(in=in1) dm_2(in=in2);
	 by subjid;
	 if in0;
run;

data dm;
     set dm;
     __TITLE1='&escapechar{style [fontweight = bold]Subject No.}: '||strip(subjid)||'      &escapechar{style [fontweight = bold]Subject Initial}: '||strip(__subinit);
     __TITLE2='&escapechar{style [fontweight = bold]Dose Group}: '||strip(__dgroup)||'      &escapechar{style [fontweight = bold]Center}: '||strip(__center);
	 __FOOTNOTE1='[1] Age is calculated as int((Informed Consent Date - Birth Date + 1)/365.25).';
	 rename studyid=__studyid;
run;

proc sort; by subjid; run;

data pdata.dm(label='Demographics');
     retain __studyid subjid __subinit infdtc brthdtc __age age gender ethnic race raceoth __center __sex __dgroup __TITLE1 __TITLE2 __FOOTNOTE1;
	 set dm;
	 keep  __studyid subjid __subinit infdtc brthdtc __age age gender ethnic race raceoth __center __sex __dgroup __TITLE1 __TITLE2 __FOOTNOTE1;
run;
