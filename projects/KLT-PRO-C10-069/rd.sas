%include '_setup.sas';
data rd1;
	length rdorres $10 rddtc $100;
	set source.rd(where=(RDTEST^='' and RDTEST^='BONE SCAN' and RDTESTCD^='DISSITE') rename=(rdorres=rdorres1 rddtc=rddtc1));
	%adjustvalue;
	label 
		rdorres='Free of Metastatic disease?'
		rddtc='Were radiological tests performed?(Date of Scan)'
		RDTEST='Type of Scan';
	if RDSTAT='' and rddtc1 ^='' and RDDY^=. then rddtc='Yes, '||strip(rddtc1)||'('||strip(put(RDDY,BEST.))||')';
	else if RDSTAT='' and rddtc1 ^='' and RDDY=. then rddtc='Yes, '||strip(rddtc1);
		else if RDSTAT='' and rddtc1 ='' then rddtc='';
		else if RDSTAT^='' then rddtc='No';
	rdorres=strip(put(RDORRES1,$yn.));
	RDTEST=strip(put(RDTEST,$RDTEST.));
	if A_VISIT='Unscheduled' then A_VISIT=strip(A_VISIT)||strip(put(VISITNUM,best.));
	if (index(A_VISIT,'Unscheduled')=0 and rddtc^='') or (index(A_VISIT,'Unscheduled')>0 and rdorres^='' and rddtc^='No') ;
	keep SUBJID RDTEST rdorres rddtc A_VISIT rddtc1;
run;
data rd1_;
	length rdorres2 $100;
	set source.rd(where=(RDTESTCD='DISSITE') rename=(rddtc=rddtc1));
	%adjustvalue;
	label 
		rdorres2='site of Metastatic disease'
		rddtc1='Were radiological tests performed?(Date of Scan)';
	if RDSTAT='' and RDORRESO='' then rdorres2=strip(put(RDORRES,$rdsite.));
		else if RDSTAT='' and RDORRESO^='' then rdorres2=strip(RDORRESO);
		else rdorres2='Not Done';
	if A_VISIT='Unscheduled' then A_VISIT=strip(A_VISIT)||strip(put(VISITNUM,best.));
	if (index(A_VISIT,'Unscheduled')=0 and rdorres2^='') or (index(A_VISIT,'Unscheduled')>0 and rdorres2^='' and rdorres2^='Not Done') ;
	keep SUBJID rdorres2 rddtc1 A_VISIT;
run;
proc sql;
	 create table rd1_all as
	 select a.*,b.rdorres2
	 from (select * from rd1) as a
	    left join
	    (select * from rd1_) as b 
	 on a.SUBJID = b.SUBJID and a.rddtc1 = b.rddtc1 and a.A_VISIT = b.A_VISIT;
quit;
data rd1_all_;
	length rdorres $200;
	set rd1_all(rename=(rdorres=rdorres1));
	label 
		rdorres='Free of Metastatic disease?';
	if rdorres1='No' and rdorres2^='Not Done' then rdorres=strip(rdorres1)||', '||strip(rdorres2);
		else rdorres=strip(rdorres1);
	drop rdorres1 rdorres2;
run;
data rd2;
	length rdorres1 $10 rddtc_ $100;
	set source.rd(where=(RDTEST='BONE SCAN'));
	%adjustvalue;
	label 
		rdorres1='Was there evidence of new lesions present?'
		rddtc_='Was a bone scan performed?(Date of bone scan)';
	rdorres1=strip(put(RDORRES,$yn.));
	if RDSTAT='' and rddtc ^='' and RDDY^=. then rddtc_='Yes, '||strip(rddtc)||'('||strip(put(RDDY,BEST.))||')';
	else if RDSTAT='' and rddtc ^='' and RDDY=. then rddtc_='Yes, '||strip(rddtc);
		else if RDSTAT='' and rddtc ='' then rddtc_='';
		else if RDSTAT^='' then rddtc_='No';
	if A_VISIT='Unscheduled' then A_VISIT=strip(A_VISIT)||strip(put(VISITNUM,best.));
	if (index(A_VISIT,'Unscheduled')=0 and rddtc_^='') or (index(A_VISIT,'Unscheduled')>0 and rdorres1^='' and rddtc_^='No') ;
	keep SUBJID rdorres1 rddtc_ A_VISIT;
run;
proc sort data=rd1_all_;by SUBJID A_VISIT;run;
proc sort data=rd2;by SUBJID A_VISIT;run;
data rd;
	merge rd1_all_(in=a) rd2(in=b);
	by SUBJID A_VISIT;
/*	if a and b then flag=0;else if a then flag=1; else flag=-1;*/
	if index(A_VISIT,'Unscheduled')>0 then A_VISIT='Unscheduled';
	__vnum=input(A_VISIT,VNUM.);
run;
proc sort data=rd;by SUBJID __vnum;run;
data pdata.rd(label='Radiological Test');
	retain SUBJID A_VISIT RDDTC RDTEST rdorres rddtc_ rdorres1 __vnum;
	keep SUBJID A_VISIT RDDTC RDTEST rdorres rddtc_ rdorres1 __vnum;
	set rd;
run;
