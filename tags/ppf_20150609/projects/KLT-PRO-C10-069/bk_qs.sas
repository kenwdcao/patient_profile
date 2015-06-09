%include '_setup.sas';
data qs;
	length QSORRES $200 QSDTC $100;
	set source.qs(rename=(QSORRES=QSORRES1 VISITNUM=__VISITNUM QSDTC=QSDTC1));
	%adjustvalue;
	label 
		QSORRES='ECOG Status'
		QSDTC='Date of Assessment#(Study Day)';
	if QSDY^=. then QSDTC=strip(QSDTC1)||'('||strip(put(QSDY,best.))||')';
	else QSDTC=strip(QSDTC1);
	if QSSTAT^='' then QSORRES='Not Done';
	else QSORRES=strip(put(QSORRES1,$QSORRES.));
run;
proc sort data=qs;by SUBJID __VISITNUM;run;
data pdata.qs(label='ECOG Status');
	retain SUBJID A_VISIT QSDTC QSORRES __VISITNUM;
	keep SUBJID A_VISIT QSDTC QSORRES __VISITNUM;
	set qs;
run;
