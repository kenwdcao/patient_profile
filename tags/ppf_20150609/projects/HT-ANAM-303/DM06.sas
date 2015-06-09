
%include '_setup.sas';
libname r301 "Q:\Files\C111\HT-ANAM-302\cdisc\dev\data\raw";
libname r302 "Q:\Files\C111\HT-ANAM-301\cdisc\dev\data\raw";
*<Gender--------------------------------------------------------------------------------------;
data sex;
	set r301.rd_frmdm r302.rd_frmdm;
	keep SUBJECTNUMBERSTR ITMDMGENDER_C;
run;
*<Demo----------------------------------------------------------------------------------------;
data dm0;
	length SUBJECTNUMBERSTR $20 ITMDMGENDER_C $1;
	if _n_=1 then do;
		declare hash h (dataset:'sex');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('ITMDMGENDER_C');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, ITMDMGENDER_C);
	end;
	set source.rd_frmdm;
	%adjustvalue(dsetlabel=Demography);
	%informatDate(DOV);
	*-> Modify Variable Label;
	label 
		ITMDMIFCDT_DTS = 'Date Informed#Consent Signed'
		ITMDMDOB_DTS = 'Date of Birth'
		A_DOV='Visit Date'
		SITECOUNTRY='Country'
		INVNAM='Investigator Name'
		ITMUPWRKFLW_CITMUPWRKFLW='Update workflow for subject?'
		__SEX='Sex'
		__SUBJECT='SUBJECT'
		ITMDMPERFSCRDAY1='Did subject perform Screening and Day 1 visits on the same day?'
		ITMDMPERFSCRDAY85='Did subject perform Screening and Day 85 of the base study (HT ANAM 301 or HT ANAM 302) on the same day?'
	;
	rc=h.find();
	__SEX=strip(ITMDMGENDER_C);
	%ageint(RFSTDTC=ITMDMIFCDT_DTS, BRTHDTC=ITMDMDOB_DTS, Age=AGE);
	__SUBJECT=SUBJECTNUMBERSTR;
	INVNAM=substr( SITENAME , 7);

run;
proc sql;
	create table dm06 as 
	select a.*,b.ITMEOSCOMPLETE_C,b.ITMEOSREASON,b.ITMEOSETDT_DTS
	from (select * from dm0) as a
			left join 
          (select * from source.RD_FRMEOS) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR;
quit;
data eos;
	set source.RD_FRMEOS;
	dsdov_c=strip(put(input(substr(strip(put(DOV,DATETIME20.)),1,9),date9.),yymmdd10.));
	if ITMEOSETDT_DTS='' and dsdov_c^='' then ITMEOSETDT_DTS=dsdov_c;else ITMEOSETDT_DTS=ITMEOSETDT_DTS;
	keep SUBJECTNUMBERSTR ITMEOSETDT_DTS dsdov_c;
run;
proc sql;
	create table _visitindex1 as 
	select a.*,b.ITMEOSETDT_DTS
	from (select * from pdata._visitindex) as a
			left join 
          (select * from eos) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR;
quit;
data _visitindex2;
	set _visitindex1;
	if (ITMEOSETDT_DTS='' and visitmnemonic^='Follow-up') or (dov_c=<ITMEOSETDT_DTS and dov_c^='' and visitmnemonic^='Follow-up');
run;
proc sort data=_visitindex2 out=_visitindex_;by SUBJECTNUMBERSTR VISITNUM DOV_C;run;
********* Get Last Date Before Discontinuation**************;
data lastv_;
	set _visitindex_(rename=(DOV_C=L_DOV_C));
	by SUBJECTNUMBERSTR;
	keep SUBJECTNUMBERSTR IN_VISITMNEMONIC L_DOV_C;
	if last.SUBJECTNUMBERSTR;
run;
proc sql;
	create table lastv1 as 
	select a.SUBJECTNUMBERSTR,a.IN_VISITMNEMONIC,a.VISITNUM,b.L_DOV_C
	from (select * from _visitindex_) as a
			left join 
          (select * from lastv_) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
	having a.DOV_C=b.L_DOV_C;
quit;
proc sort data=lastv1 ;by SUBJECTNUMBERSTR L_DOV_C VISITNUM ;run;
********* Get Visit Date Before Discontinuation**************;
data lastv;
	length lastvisit $100;
	set lastv1;
	by SUBJECTNUMBERSTR L_DOV_C;
	retain lastvisit;
	if first.L_DOV_C then lastvisit=IN_VISITMNEMONIC;
	else lastvisit=strip(lastvisit)||', '||strip(IN_VISITMNEMONIC);
	if last.L_DOV_C;
run;
data dm060;
	length __STAT $100 __SEX $3 SUBJECTNUMBERSTR $20 lastvisit $100 __title2 $100;
	if _n_=1 then do;
		declare hash h (dataset:'lastv');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('lastvisit');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, lastvisit);
	end;
	set dm06;
	%formatDate(ITMDMIFCDT_DTS);
	%formatDate(ITMDMDOB_DTS);
	%formatDate(ITMEOSETDT_DTS);
	if ITMEOSCOMPLETE_C='COMPLETED' then __STAT='Completed: '||strip(ITMEOSETDT_DTS);
		else if ITMEOSCOMPLETE_C='NOT COMPLETED' then __STAT=strip(scan(ITMEOSREASON,1,','))||': '||strip(ITMEOSETDT_DTS);
			else if ITMEOSCOMPLETE_C='' then __STAT='Ongoing';
	if AGE='' then AGE='NA';
	__AGE=strip(AGE)||'!{super [1]}';
	if __SEX='' then __SEX='NA';
	__title=strip(__SUBJECT)||' / '||strip(__SEX)||' / '||strip(__AGE)||' / '||strip(__STAT);
	rc=h.find();
	if lastvisit^='' and __STAT^='Ongoing' then __title2= 'Last Visit Before Discontinuation: '||strip(lastvisit);
		else __title2='Last Visit Before Discontinuation: NA';
run;
proc sql;
	create table firstdose as 
	select DISTINCT SUBJECTNUMBERSTR,min(ITMDRUGFIRSTDOSEDT_DTS) as fdosedt
	from source.RD_FRMDRUG_ACTIVE
	group by SUBJECTNUMBERSTR;
quit;
data dm0601;
	length SUBJECTNUMBERSTR $20 fdosedt $19;
	if _n_=1 then do;
		declare hash h (dataset:'firstdose');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('fdosedt');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, fdosedt);
	end;
	set dm060;
	rc=h.find();
	%formatDate(fdosedt);
	if fdosedt^='' then __title2='First Dose Date: '||strip(fdosedt)|| ' / '||strip(__title2);
		else __title2='First Dose Date: NA / '||strip(__title2);
run;
data pdata.dm06(label='Demography');
	retain &globalvars1 ITMDMIFCDT_DTS ITMDMDOB_DTS ITMDMPERFSCRDAY1 ITMDMPERFSCRDAY85 ITMUPWRKFLW_CITMUPWRKFLW 
			__title __title2 __SUBJECT __SEX __AGE __STAT; 
	keep &globalvars1 ITMDMIFCDT_DTS ITMDMDOB_DTS ITMDMPERFSCRDAY1 ITMDMPERFSCRDAY85 ITMUPWRKFLW_CITMUPWRKFLW 
			__title __title2 __SUBJECT __SEX __AGE __STAT; 
	set dm0601;
run;
data pdata.dmcomp(label='Demography');
	retain &globalvars1 ITMDMIFCDT_DTS ITMDMDOB_DTS ITMDMPERFSCRDAY1 ITMDMPERFSCRDAY85 ITMUPWRKFLW_CITMUPWRKFLW 
			__title __title2 __SUBJECT __SEX __AGE __STAT; 
	keep &globalvars1 ITMDMIFCDT_DTS ITMDMDOB_DTS ITMDMPERFSCRDAY1 ITMDMPERFSCRDAY85 ITMUPWRKFLW_CITMUPWRKFLW 
			__title __title2 __SUBJECT __SEX __AGE __STAT; 
	set dm0601;
	if __STAT^='Ongoing';
run;
