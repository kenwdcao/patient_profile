%include '_setup.sas';
data pe1;
	length peorres $200 pedtc $40;
	set source.pe(where=(petestcd='COMPLETE') rename=(peorres=peorres1 pedtc=pedtc1));
	%adjustvalue;
	label 
		peorres='Were there any abnormalities?'
		pedtc='Date  Performed#(Study Day)';
	peorres=strip(put(PEORRES1,$pe.));
	if PESTAT='' and pedtc1 ^='' and PEDY^=. then pedtc='Yes, '||strip(pedtc1)||'('||strip(put(PEDY,best.))||')';
	else if PESTAT='' and pedtc1 ^='' and PEDY=. then pedtc='Yes, '||strip(pedtc1);
		else if PESTAT='' and pedtc1 ='' then pedtc='';
		else if PESTAT^='' then pedtc='No';	
	if A_VISIT='Unscheduled' then A_VISIT=strip(A_VISIT)||strip(put(VISITNUM,best.));
	if (index(A_VISIT,'Unscheduled')=0 and pedtc^='') or (index(A_VISIT,'Unscheduled')>0 and peorres^='' and pedtc^='No') ;
	keep SUBJID peorres pedtc pedtc1 A_VISIT VISITNUM;
run;
data pe2;
	length peorres1 petest1 $200;
	set source.pe(where=(petestcd^='COMPLETE' and petestcd^='') rename=(pedtc=pedtc1));
	%adjustvalue;
	label 
		petest1='Body System'
		peorres1='Abnormal Body System';
	if petesto='' then petest1=strip(put(petestcd,$petest.));
	else petest1=strip(put(petestcd,$petest.))||'('||strip(petesto)||')';
	peorres1=strip(petest1)||': '||strip(peorres)||', '||strip(peclinsg);
	if A_VISIT='Unscheduled' then A_VISIT=strip(A_VISIT)||strip(put(VISITNUM,best.));
	if (index(A_VISIT,'Unscheduled')=0 and peorres1^='') or (index(A_VISIT,'Unscheduled')>0 and peorres1^='' and peorres1^='Not Done') ;
	keep SUBJID petest1 peorres1 pedtc1 A_VISIT VISITNUM;
run;
proc sort data=pe2;by SUBJID VISITNUM pedtc1 peorres1;run;
data pe2_;
	length peorres1 $200;
	set pe2(rename=(peorres1=in_peorres1));
	label 
		peorres1='Abnormal Body System';
	by SUBJID VISITNUM pedtc1;
	retain peorres1;
	NULL='';
	if first.pedtc1 then peorres1=in_peorres1;
	else peorres1=strip(peorres1)||'; '||in_peorres1;
	if last.pedtc1;
	drop in_peorres1 petest1;
run;
proc sort data=pe1;by SUBJID A_VISIT pedtc1;run;
proc sort data=pe2_;by SUBJID A_VISIT pedtc1;run;
data pe;
	merge pe1(in=a) pe2_(in=b);
	by SUBJID A_VISIT pedtc1;
/*	if a and b then flag=0;else if a then flag=1; else flag=-1;*/
	if index(A_VISIT,'Unscheduled')>0 then A_VISIT='Unscheduled';
	RENAME VISITNUM=__VISITNUM;
run;
proc sort data=pe;by SUBJID __VISITNUM;run;
data pdata.pe(label='Physical Examination');
	retain SUBJID A_VISIT pedtc peorres NULL peorres1 __VISITNUM;
	keep SUBJID A_VISIT pedtc peorres NULL peorres1 __VISITNUM;
	set pe;
run;
