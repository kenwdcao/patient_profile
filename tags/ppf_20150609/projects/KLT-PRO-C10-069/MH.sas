/*
	Program Name: MH.sas
		@Author: Ken Cao (yong.cao@q2bi.com)	
		@Intial Date: 2013/05/07

	***********************************************
	For MH data for KLT study
	***********************************************

*/

%include '_setup.sas';

data mh0 ppr0 pps0 ppt0;
	set source.mh;
	if mhcat='GENERAL' then output mh0;
	else if mhcat='PRIOR PROSTATE RADIATION' then output ppr0;
	else if mhcat='PRIOR PROSTATE SURGERY' then output pps0;
	else if mhcat='PRIOR PROSTATE THERAPY' then output ppt0;
run;


*Medical History;
data pdata.mh(label='Medical History');
	retain subjid mhterm mhdecod mhbodsys mhpresp mhstdtc mhendtc mhenrf;
	keep subjid mhterm mhdecod mhbodsys mhpresp mhstdtc mhendtc mhenrf;
	set mh0;
	label 
		mhterm  = 'Diagnosis or Procdures'
		mhstdtc = 'Start Date'
		mhpresp = 'Pre-specified Events?'
		mhendtc = 'End Date'
		mhenrf  = 'Ongoing'
	;
	if mhterm>'';
run;


*Prior Prostate Radiation;
data pdata.ppr(label='Prior Prostate Radiation');
	retain subjid mhstdtc mhendtc mhsite mhintent mhterm;
	keep subjid mhstdtc mhendtc mhsite mhintent mhterm;;
	set ppr0;
	label
		mhstdtc  = 'Start Date'
		mhendtc  = 'End Date'
		mhsite   = 'Site'
		mhintent = 'Intent'
		mhterm   = 'RT Type'
	;
	if cmiss(MHSTDTC,MHENDTC,MHSITE,MHINTENT,MHTERM)^=5;
run;


*Prior Prostate Surgery;
data pdata.pps(label='Prior Prostate Surgery');
	retain subjid mhstdtc mhterm mhintent;
	keep subjid mhstdtc mhterm mhintent;
	set pps0;
	where mhterm>'';
	label
		mhstdtc  = 'Prior Prostate Surgery'
		mhterm   = 'Procedure'
		mhintent = 'Intent'
	;
run;

*Prior Prostate Therapy;
data pdata.ppt;
	retain subjid mhspid mhterm mhstdtc mhendtc mhenrf;
	keep subjid mhspid mhterm mhstdtc mhendtc mhenrf;
	set ppt0;
	if mhterm>'';
	label
		mhspid   = 'Prior Prostate Therapy'
		mhterm   = 'Agent'
		mhstdtc  = 'Start Date'
		mhendtc  = 'End Date'
		mhenrf   = 'End Reference'
	;
run;

