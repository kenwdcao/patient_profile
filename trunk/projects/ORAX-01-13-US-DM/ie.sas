
%include "_setup.sas";

proc sort data=source.inc_exc_criteria out=s_inc_exc_criteria nodupkey; by _all_; run;

data ie_inc;
    set s_inc_exc_criteria;
	attrib
/*	inc_iecat         length=$20       label='Category'*/
/*	inc_metyn       length=$10       label='Meet all Criteria?'*/
/*	inc_critnum     length=$100     label='Criterion #'*/
/*	inc_waiver      length=$10       label='Waiver Given?'*/
/*	inc_wvrdtc      length=$19       label='Waiver Date'*/
/*	inc_comment  length=$200     label='Comment or Explanation'*/
	inc_metyn       length=$10       label='Meet all Inclusion Criteria Listed in the protocol?'
	inc_critnum     length=$100     label='Inclusion Criterion #'
	inc_waiver      length=$10       label='Waiver Given for Inclusion Criteria not met?'
	inc_wvrdtc      length=$19       label='Date Waiver Given'
	inc_comment  length=$200     label='Comment or Explanation'

	;
	subjid=ssid;
/*    inc_iecat='Inclusion';*/
	inc_metyn=strip(INCLUSION_LABEL);
	inc_critnum=strip(incct);
	inc_waiver=strip(INCELGWVR_LABEL);
    inc_wvrdtc=strip(INCELGWVRDT);
    inc_comment=strip(INCELGWVRCMNT);
    keep subjid  inc_metyn inc_critnum inc_waiver inc_wvrdtc inc_comment;
run;
proc sort; by subjid; run;

data ie_exc;
    set s_inc_exc_criteria;
	attrib
/*	exc_iecat         length=$20       label='Category'*/
	exc_metyn       length=$10       label='Meet any Exclusion Criteria Listed in the protocol?'
	exc_critnum     length=$100     label='Exclusion Criterion #'
	exc_waiver      length=$10       label='Waiver Given for Exclusion Criteria met?'
	exc_wvrdtc      length=$19       label='Date Waiver Given'
	exc_comment  length=$200     label='Comment or Explanation'
	;
	subjid=ssid;
/*    exc_iecat='Exclusion';*/
	exc_metyn=strip(EXCLUSION_LABEL);
	exc_critnum=strip(EXCC);
	exc_waiver=strip(EXCELGWVR_LABEL);
    exc_wvrdtc=strip(EXCELGWVRDT);
    exc_comment=strip(EXCELGWVRCMNT);
    keep subjid  exc_metyn exc_critnum exc_waiver exc_wvrdtc exc_comment;
run;
proc sort; by subjid; run;
/**/
/*data ie_all;*/
/*     set ie_inc ie_exc;*/
/*run;*/
/**/
/*proc sql;*/
/*    create table ie as*/
/*	select a.* from ie_all as a inner join pdata.dm as b on a.subjid=b.subjid;*/
/*quit;*/
/**/
/*proc sort; by subjid descending iecat; run;*/
/**/
/*data pdata.ie(label='Inclusion and Exclusion Criteria');*/
/*     retain subjid iecat metyn critnum waiver wvrdtc comment;*/
/*	 set ie;*/
/*	 keep  subjid iecat metyn critnum waiver wvrdtc comment;*/
/*run;*/

data pdata.ie1(label='Inclusion Criteria');
     retain subjid inc_metyn inc_critnum inc_waiver inc_wvrdtc inc_comment;
	 set ie_inc;
	 keep  subjid inc_metyn inc_critnum inc_waiver inc_wvrdtc inc_comment;
run;

data pdata.ie2(label='Exclusion Criteria');
     retain subjid exc_metyn exc_critnum exc_waiver exc_wvrdtc exc_comment;
	 set ie_exc;
	 keep  subjid exc_metyn exc_critnum exc_waiver exc_wvrdtc exc_comment;
run;

