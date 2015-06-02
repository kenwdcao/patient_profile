%include "_setup.sas";
data dm;
	length visit $40 orres $20;
	set source.dm;
	visit='Baseline';
	VNUM=0;
	orres=strip(PSADTRES);
	orres1=input(orres,best.);
	keep subjid orres visit VNUM orres1;
run;
data dp;
	length visit $40 orres $20;
	set source.dp(where=(DPORRES^='' AND dptest='PSADT') rename=visit=in_visit);
	visit=strip(put(in_visit,$VISIT.));
	VNUM=input(VISIT,vnum.);
	orres=strip(compress(DPORRES,,'a'));
	if index(DPORRES,',')>0 then orres=TRANSLATE(orres,'.',',');
	orres1=input(orres,best.);
	keep subjid ORRES visit VNUM orres1;
run;
data psadt;
	set dm dp;
run;
proc sort data=psadt;by subjid vnum;run;
/**************** plot=join ****************/
/*option nodate nonumber ;
ods pdf file="Q:\WorkSpace\Public\Janus\D1--CY\R203\CY\Applications\Patient Profile\work\output\KLT-PRO-C10-069\figure\psadt2.pdf" ;
goption reset=all;
title1 justify=l ' ' ;
title2 j=c 'Figure 1. Change of PSA Doubling Time (PSADT)' ;
footnote9 justify=l "SOURCE: dm, dp" justify=r "SAS VERSION 9.3";                
footnote10 justify=l "OUTPUT: 01-002" ;
symbol v=dot h=2  i=join ci=blue  w=2 pointlabel=("#ORRES1" H=1);
axis1  label=( h=1.5 'Visit')  value=(H=1.2) w=2 major=(height=0.6) minor=none order=(0 to 150 by 30) offset=(5,5);
axis2  label=( h=1.3 'PSADT') value=(H=1.2) w=2 major=(height=1) minor=none  order=(0 to 100 by 10) offset=(2,2);
proc gplot data=psadt;where subjid='01-002';
	format vnum vnum.;
    plot ORRES1*vnum/haxis=axis1 vaxis=axis2 noframe;
run;
quit;
ods pdf close;*/
/**************** end ****************/

%macro loop_v1;
	proc sql noprint;
		select distinct subjid into: _subjid_ separated by " "
		from psadt;
	quit;

	%let count=%eval(%sysfunc(countc(&_subjid_, " "))+1);

	%do i=1 %to &count;
		%let subjidall=%scan(&_subjid_,&i," ");
		option nodate nonumber ;
/*		ods pdf file="Q:\WorkSpace\Public\Janus\D1--CY\R203\CY\Applications\Patient Profile\work\output\KLT-PRO-C10-069\figure\&subjidall..pdf" ;*/
		goption reset=all;
		title1 justify=l ' ' ;
		title2 j=c 'Figure 1. Change of PSA Doubling Time (PSADT)' ;
/*		footnote9 justify=l "SOURCE: dm, dp" justify=r "SAS VERSION 9.3";                */
/*		footnote10 justify=l "OUTPUT: &subjidall" ;*/
		symbol v=dot h=2  i=join ci=blue  w=2 pointlabel=("#ORRES1" H=1);
		axis1  label=(h=1.5 'Visit')  value=(H=1.2)  w=2 major=(height=0.6) minor=none order=(0 to 150 by 30) offset=(5,5);
		axis2  label=(h=1.3 'PSADT')   value=(H=1.2) w=2 major=(height=1) minor=none  offset=(2,2);
		ods _all_ close;
		filename psadt  "Q:\WorkSpace\Public\Janus\D1--CY\R203\CY\Applications\Patient Profile\work\output\KLT-PRO-C10-069\Graphics\PSADT_&subjidall..png";
		goptions device=png hsize=12cm vsize=12cm gsfname=psadt  ;
		ods listing;
		proc gplot data=psadt;where subjid="&subjidall";
			format vnum vnum.;
		    plot ORRES1*vnum/haxis=axis1 vaxis=axis2 noframe;
		run;
/*		ods pdf close;*/
		ods listing close;
		filename psadt clear;
	%end;

%mend loop_v1;

%loop_v1;
