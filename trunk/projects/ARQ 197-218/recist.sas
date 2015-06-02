* Program Name: RECIST.sas;
* Author: Yiqi Diao (yiqi.diao@januscri.com);
* Initial Date: 18/02/2014;


%include '_setup.sas';

*CR color;
%let rscrcolor=green;
*PD color;
%let rspdcolor=red;

data recist0;
	set source.recist;
	%subjid;
	* numeric date to character date;
	length VISIT $60 OAASSDTC $18;
	%getCycleDate(leadq=TURES, numdate=OAASSDT);
	VISIT = __visit;
	OAASSDTC = __date;
	length N_TLRES N_NTLRES N_OARES $100;
	label 
		VISIT = 'Visit'
		OAASSDTC = 'Date'
		N_TLRES = 'Target Lesion Response'
		N_NTLRES = 'Non Target Lesion Response'
		N_OARES = 'Overall Response'
		;
	N_TLRES = TLRES;
	if TLRES = 'Complete Response (CR)' then N_TLRES = "&escapechar{style [foreground=&rscrcolor]"||strip(N_TLRES) || '}';
		else if TLRES = 'Progressive Disease (PD)' then N_TLRES = "&escapechar{style [foreground=&rspdcolor]"||strip(N_TLRES)|| '}';
	N_NTLRES = NTLRES;
	if NTLRES = 'Complete Response (CR)' then N_NTLRES = "&escapechar{style [foreground=&rscrcolor]"||strip(N_NTLRES)|| '}';
		else if NTLRES = 'Progressive Disease (PD)' then N_NTLRES = "&escapechar{style [foreground=&rspdcolor]"||strip(N_NTLRES)|| '}';
	N_OARES = OARES;
	if OARES = 'Complete Response (CR)' then N_OARES = "&escapechar{style [foreground=&rscrcolor]"||strip(N_OARES)|| '}';
		else if OARES = 'Progressive Disease (PD)' then N_OARES = "&escapechar{style [foreground=&rspdcolor]"||strip(N_OARES)|| '}';
run;

proc sort data = recist0 out = recist1;
by SUBJID __vdate OAASSDTC;
run;

data pdata.recist (label='Overall Tumor Assessment');
	retain SUBJID __vdate VISIT OAASSDTC N_TLRES N_NTLRES N_OARES;
	keep SUBJID __vdate VISIT OAASSDTC N_TLRES N_NTLRES N_OARES;
	set recist1;
run;
