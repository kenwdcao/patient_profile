%include "_setup.sas";

*---------AE---------->;
proc format;
	value aetoxgr
	.=' '
	1='Grade 1: Mild'
	2='Grade 2: Moderate'
	3='Grade 3: Severe'
	4='Grade 4: Life-threatening or disabling'
	5='Grade 5: Death related to AE'
	;
run;

data sae ae;
	length AESCONG_ AESDISAB_ AESDTH_ AESHOSP_ AESLIFE_ AESMIE_ AETOXGRC $100 SAENOTE aenote aeacn_ aerel_ aeout_$250;
	set source.ae;
	if strip(AESCONG)='N'  then AESCONG_='';
	if strip(AESCONG)='Y'  then AESCONG_='Congenital Anomaly';

	if strip(AESDISAB)='N'  then AESDISAB_='';
	if strip(AESDISAB)='Y'  then AESDISAB_='Significant Disability';

	if strip(AESDTH)='N'  then AESDTH_='';
	if strip(AESDTH)='Y'  then AESDTH_='Results in Death';

	if strip(AESHOSP)='N'  then AESHOSP_='';
	if strip(AESHOSP)='Y'  then AESHOSP_='Hospitalization or Prolonged Hospitalization';

	if strip(AESLIFE)='N'  then AESLIFE_='';
	if strip(AESLIFE)='Y'  then AESLIFE_='Life Threatening';

	if strip(AESMIE)='N'  then AESMIE_='';
	if strip(AESMIE)='Y'  then AESMIE_='Medically Significant in the Opinion of the Investigator';

	SAE=catx(', ',AESCONG_, AESDISAB_, AESDTH_, AESHOSP_, AESLIFE_, AESMIE_);

	aeterm=propcase(strip(aeterm));
/*	AETOXGRC =put(AETOXGR,aetoxgr.);*/
/*	AETOXGRC = scan(AETOXGRC,2,":");*/

	if length(strip(AESTDTC))=10 then AESTDTC=strip(AESTDTC)||"(" || strip(ifc(AESTDY=.,'',put(AESTDY,best.)))||")";
/*	if aeenrf="ONGOING" then aeendtc="Ongoing";*/
/*		else if aeendtc^='' then aeendtc="End Date:"||strip(aeendtc);*/
	AETOXGRC="Toxicity Grade:"||ifc(AETOXGR=.,'',strip(put(AETOXGR,best.)));	
	if aerel='PROBABLE' or aerel="POSSIBLE" or aerel='DEFINITELY' then aerel_="Causality:"||propcase(strip(aerel));
		else aerel_='';
	if aeout='RECOVERED/RESOLVED' or aeout="RECOVERED/RESOLVED WITH SEQUELAE" then	AEOUT_=propcase(strip(AEOUT))||" on "||strip(aeendtc);
		else if aeout^='' then aeout_=propcase(strip(aeout));

	if aeacn='NONE' then aeacn='';

	if aeacnsp^='' then do;
		if strip(aeacnoth)='OTHER' then aeacnoth=strip(aeacnsp);
		else if aeacnoth='MEDICATION, OTHER'  then aeacnoth='MEDICATION,'||strip(aeacnsp);
		else if aeacnoth='MEDICATION, NONPHARMACEUTICAL THERAPY, OTHER' then aeacnoth='MEDICATION, NONPHARMACEUTICAL THERAPY,'||strip(aeacnsp);
		else aeacnoth=strip(aeacnoth) ||","||strip(aeacnsp);end;
	else if aeacnsp='' then do;
		if aeacnoth='NONE' then aeacnoth='';
		if aeacnoth^='' then aeacnoth=strip(aeacnoth); end;


	if aeacn^='' and aeacnoth^='' then aeacn_="Action taken: "||propcase(strip(aeacn))||","||propcase(strip(aeacnoth));
		else if aeacn^='' and aeacnoth='' then aeacn_="Action Taken: "||propcase(strip(aeacn));
		else if aeacn='' and aeacnoth^='' then aeacn_="Action Taken: "||propcase(strip(aeacnoth));
		else if aeacn='' and aeacnoth='' then aeacn_='';

	if aerel_^='' and aeacn_^='' then do;
	SAENOTE=strip(SAE)||"; "||strip(AETOXGRC)||"; "||strip(aerel_)||"; "||strip(aeacn_)||"; "||strip(AEOUT_);
	AENOTE=strip(AETOXGRC)||"; "||strip(aerel_)||"; "||strip(aeacn_)||"; "||strip(AEOUT_); end;

		else if aerel_^='' and aeacn_='' then do;
		SAENOTE=strip(SAE)||"; "||strip(AETOXGRC)||"; "||strip(aerel_)||"; "||strip(AEOUT_);
		AENOTE=strip(AETOXGRC)||"; "||strip(aerel_)||"; "||strip(AEOUT_); end;

		else if aerel_='' and aeacn_^='' then do;
		SAENOTE=strip(SAE)||"; "||strip(AETOXGRC)||"; "||strip(aeacn_)||"; "||strip(AEOUT_);
		AENOTE=strip(AETOXGRC)||"; "||strip(aeacn_)||"; "||strip(AEOUT_); end;


		else if aerel_='' and aeacn_='' then do;
		SAENOTE=strip(SAE)||"; "||strip(AETOXGRC)||"; "||strip(AEOUT_);
		AENOTE=strip(AETOXGRC)||"; "||strip(AEOUT_); end;



	if aeterm ^='' and sae ^='' then output sae;
		else if aeterm^='' and (aeacn_^='' or aeout_^='' or aerel_^='') then output ae;;
/*		else if aeterm^='' and ((aeacn ^='' and aeacn ^='NONE') or (aeacnoth ^='' and aeacnoth ^='NONE') or (aeout='NOT RECOVERED/NOT RESOLVED'*/
/*		or aeout="RECOVERING/RESOLVING")or (aerel='PROBABLE' or aerel='DEFINITELY')) then output ae;*/

/*	keep SUBJID AETERM AESTDTC aeacn aeacnoth aerel AESER AEOUT AETOXGR AETOXGRC AESCONG_ AESDISAB_ AESDTH_ */
/*		AESHOSP_ AESLIFE_ AESMIE_ SAENOTE  aenote SAE aeendtc;*/
run;


*-----------LB----------->;

%let labedt=POI_715_Laboratory_Data_130318;

%macro IsNumeric(InStr=, Result=);
	length __InStr $200;
   &Result = 1;
   __PeriodCount = 0;

   __InStr = trim(left(&InStr));
   if substr(__InStr, 1, 1) in ('-', '+') then __InStr = trim(left(substr(__InStr, 2)));

   do __n = 1 to length(__InStr);
      if substr(__InStr, __n, 1) not in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.') then
	     &Result = 0;
      if substr(__InStr, __n, 1) = '.' then __PeriodCount = __PeriodCount + 1;
   end;
   if __PeriodCount > 1 then &Result = 0;
%mend IsNumeric;


proc format;
	invalue lbvnum
		SCREENING    =  -1
		MONTH 0      =  0
		MONTH 3      =  3
		MONTH 6      =  6
		MONTH 9      =  9
		MONTH 12     =  12
		MONTH 14     =  14
		MONTH 15     =  15
		UNSCHEDULED  =  99
		EARLY TERM   =  98
	;
run;
	

data lbedt0;
	set source.&labedt(rename=(lborres=lborres_ visit=visit_ lbfast=lbfast_ lbtest=lbtest_));
	length lborres visit lbfast $200 lbtest $100;
	keep subjid lbcat lbtestcd lbtest lborres lbornrlo lbornrhi lbdtc visit visitnum lbfast range lborres_ visit_;
	lborres=lborres_;
	visit=visit_;
	lbfast=lbfast_;
	length range $200;
	range=strip(lbornrlo)||' - '||strip(lbornrhi);
	if compress(range)='-' then range='';;
	*filter some records;
	where upcase(lborres_)^='CANCELLED' and not (lborres_='' and lbdtc='');
	visit=upcase(visit);
	length _lbdate $10 _lbtime $5;
	_lbdate=compress(scan(lbdtc,1," "),'/');
	_lbdate=ifc(length(_lbdate)=9, put(input(_lbdate,date9.),yymmdd10.),'');
	_lbtime=scan(lbdtc,2," ");
/*	lbdtc=strip(_lbdate)||'T'||strip(_lbtime);*/
	lbdtc=strip(_lbdate);

	drop _lbdate _lbtime;
	*derive a visitnum;
	visitnum=input(visit,lbvnum.);
	*in case of MONTH XX not in informat lbvnum;
	if visitnum=. and index(visit,'MONTH')=1 then visitnum=input(strip(scan(visit,2," ")),best.);
	*for lab result with normal range;
	_nrlow=ifn(lbornrlo>'',input(lbornrlo,best.),.);
	_nrhigh=ifn(lbornrhi>'',input(lbornrhi,best.),1E99);
	__result=0;
	%IsNumeric(Instr=lborres,Result=__result);
	if __result=1 then 	_result=input(lborres,best.);
	if .<_result<_nrlow and lborres>'' then lborres="^{style [foreground=&belowcolor]"||strip(lborres)||'}';
	else if _result>_nrhigh then lborres="^{style [foreground=&abovecolor]"||strip(lborres)||'}';
	else if _nrlow=. and _nrhigh=1E99 then lborres="^{style [foreground=&norangecolor]"||strip(lborres)||'}';

	lbtest=strip(lbtest_)||": "||strip(lborres);
run;

proc sql;
	create table lbedt01 as
	select a.*,b.rfstdtc
	from (select * from lbedt0) as a
		left join
		(select * from source.dm) as b
	on a.subjid=b.subjid
	;
quit;

data lbedt02;
	length lbdy 8;
	set lbedt01;
	if input(lbdtc,yymmdd10.)>=input(rfstdtc,yymmdd10.) then lbdy=input(lbdtc,yymmdd10.)-input(rfstdtc,yymmdd10.)+1;
	else lbdy=input(rfstdtc,yymmdd10.)-input(lbdtc,yymmdd10.);
	if length(lbdtc)=10 and lbdy ^=. then lbdtc=strip(lbdtc)||"("||ifc(lbdy=.,'',strip(put(lbdy,best.)))||")";
run;


data lbbi lbcbc lbschem;
	set lbedt02;
	if lbcat='Biomarkers' and (index(lborres,"red")>0 or index(lborres,"blue")>0) then output lbbi;
	else if lbcat='CBC w/Differential' and (index(lborres,"red")>0 or index(lborres,"blue")>0) then output lbcbc;
	else if lbcat='Serum Chemistry' and (index(lborres,"red")>0 or index(lborres,"blue")>0) then output lbschem;
run;

data lbbi_;
	length lbnote $200;
	set lbbi;
	if lbornrlo^='' or lbornrhi ^='' then do;
	if index(lborres,"red")>0 then lbnote="The result is above normal range("||strip(lbornrlo)||" - "||strip(lbornrhi)||")";
		else if index(lborres,"blue")>0 then lbnote="The result is lower than normal range("||strip(lbornrlo)||" - "||strip(lbornrhi)||")";
		end;
run;

data lbcbc_;
	length lbnote $200;
	set lbcbc;
	if lbornrlo^='' or lbornrhi ^='' then do;
	if index(lborres,"red")>0 then lbnote="The result is above normal range("||strip(lbornrlo)||" - "||strip(lbornrhi)||")";
		else if index(lborres,"blue")>0 then lbnote="The result is lower than normal range("||strip(lbornrlo)||" - "||strip(lbornrhi)||")";
		end;
run;

data lbschem_;
	length lbnote $200;
	set lbschem;
	if lbornrlo^='' or lbornrhi ^='' then do;
	if index(lborres,"red")>0 then lbnote="The result is above normal range("||strip(lbornrlo)||" - "||strip(lbornrhi)||")";
		else if index(lborres,"blue")>0 then lbnote="The result is lower than normal range("||strip(lbornrlo)||" - "||strip(lbornrhi)||")";
		end;
run;

*---------PE---------->;

data pe1;
	length peorres $200 pedtc $40;
	set source.pe(where=(petestcd='COMPLETE') rename=(peorres=peorres1 pedtc=pedtc1));
	%adjustvalue;
	label 
		peorres='Were there any abnormalities?'
		pedtc='Date  Performed#(Study Day)';
	peorres=strip(put(PEORRES1,$pe.));
	if PESTAT='' and pedtc1 ^='' and PEDY^=. then pedtc=strip(pedtc1)||'('||strip(put(PEDY,best.))||')';
	else if PESTAT='' and pedtc1 ^='' and PEDY=. then pedtc=strip(pedtc1);
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

	if peorres='Yes';
run;

*---------EG---------->;
data eg0;
	set source.eg;
	egorres=propcase(egorres);
	where not(egorres='' and egstat='' and egdtc='') and not (egorres='' and visit='UNSCHEDULED');
run;

data eg1;
length egnote $100;
	set eg0;
	if egorres^='' and egorres^="Normal";
	egtest=strip(egtest)||": abnormal";
	visit=propcase(strip(visit));
	if EGCLINSG ^='' then egnote=propcase(strip(scan(egorres,2,"-")))||": "||propcase(strip(EGCLINSG));
		else if egorres^='' then egnote=propcase(strip(scan(egorres,2,"-")));
	if length(egdtc)=10 and egdy^=. then egdtc=strip(egdtc)||"("||strip(put(egdy,best.))||")";
run;

*-------VS---------->;
*--->Magic Numbers (Normal Range);
%let SYSBPLOW=90;
%let SYSBPHIGH=140;
%let DIABPLOW=50;
%let DIABPHIGH=90;
%let HRLOW=50;
%let HRHIGH=100;
%let TEMPLOW_F=95.9;
%let TEMPHIGH_F=100.04;
%let TEMPLOW=35.5;
%let TEMPHIGH=37.8;
%let RESPLOW=12;
%let RESPHIGH=18;
%let PRLOW=120;
%let PRHIGH=200;
%let QRSLOW=60;
%let QRSHIGH=109;
%let QTLOW=320;
%let QTHIGH=450;
%let QTCFLOW=320;
%let QTCFHIGH=450;

data REFRANGE1;
	attrib
		VSTESTCD	length=$8		label='Vital Signs Test Short Name'
		low		length=8		label='Lower Limit'
		high	length=8		label='Upper Limit'
		VSORRESU	length=$40		label='Original Units'
	;
	VSTESTCD='TEMP';	      low=&TEMPLOW;		 	    high=&TEMPHIGH;	        VSORRESU='C';          output;
	VSTESTCD='TEMP';	      low=&TEMPLOW_F;		 	    high=&TEMPHIGH_F;	VSORRESU='F';          output;
	VSTESTCD='PULSE';          low=&HRLOW;       		high=&HRHIGH; 			VSORRESU='BEATS/MIN';            output;
	VSTESTCD='RESP';	    low=&RESPLOW;				high=&RESPHIGH;			VSORRESU='BREATHS/MIN';		  output;
	VSTESTCD='SYSBP';        low=&SYSBPLOW;    		high=&SYSBPHIGH; 			VSORRESU='mmHg';         output;
	VSTESTCD='DIABP';       low=&DIABPLOW;    		high=&DIABPHIGH; 			VSORRESU='mmHg';         output;
run;
data REFRANGE;
	LENGTH LOW HIGH $20;
	SET REFRANGE1(RENAME=(low=low1 high=high1));
	low=strip(put(low1,best.));
	high=strip(put(high1,best.));
	drop low1 high1;
RUN;
data vs;
	length B_VSDTC $19  VSTESTCD $8 LOW HIGH $20 VSORRESU $40 VSSTRESC vstest $200;
	if _n_=1 then do;
		declare hash h (dataset:'REFRANGE');
		rc=h.defineKey('VSTESTCD','VSORRESU');
		rc=h.defineData('low','high');
		rc=h.defineDone();
		call missing(VSTESTCD, VSORRESU, low, high);
	end;
	set source.vs(rename=(vstest=vstest_));
	%adjustvalue;
	B_VSDTC=strip(VSDTC);
	rc=h.find();
	%notInLowHigh(orres=VSORRES,low=low,high=high,stresc=VSSTRESC);
	if VSTEST_='Weight' or VSTEST_='Height' then do;__color='';VSSTRESC=strip(__orresc);end;
	if VSSTAT='NOT DONE' then VSSTRESC='Not Done';
/*	TEST=strip(put(VSTEST_,$VSTEST.))||'('||strip(VSORRESU)||')';*/
	if vsorres ^=. and vsorresu^='' then vstest=strip(vstest_)||": "||strip(vsstresc)||""||'^{style [foreground=black] '||strip(vsorresu)||"}";
		else if vsorres^=. and vsorresu='' then vstest=strip(vstest_)||": "||strip(vsstresc);
		else if vsorres=. and vsorresu='' then vstest=strip(vstest_);
	if length(strip(vsdtc))=10 and vsdy^=. then vsdtc=strip(vsdtc)||"("||ifc(vsdy=.,'',strip(put(vsdy,best.)))||")";
	drop  STUDYID DOMAIN USUBJID SITEID;
run;

data vs_;
	length vsnote $200;
	set vs;
	if strip(__color)='red' then vsnote="The result is above normal range("||strip(low)||" - "||strip(high)||")";
		else if strip(__color)="blue" then lbnote="The result is lower than normal range("||strip(low)||" - "||strip(high)||")";

	if strip(__color)='red' or strip(__color)="blue";
run;

*---------DS--------->;
data ds01 ds02;
	set source.ds;
	dscat=propcase(strip(dscat));
	dsterm=propcase(strip(dsterm));
	if length(strip(DSSTDTC))=10 and dsstdy^=. then DSSTDTC=strip(DSSTDTC)||"(" || strip(ifc(DSSTDY=.,'',put(DSSTDY,best.)))||")";

	if DSTERM^='' and strip(EPOCH)="TREATMENT PHASE" then output ds01;
	else if DSTERM^='' and strip(EPOCH)="SCREENING" then output ds02;

run;

*-------CM--------->;
data cm;
	length cmnote $200;
set source.cm ;
cmtrt=propcase(strip(cmtrt));
cmae=propcase(strip(cmae));
if length(strip(CMSTDTC))=10 then CMSTDTC=strip(CMSTDTC)||"(" || strip(ifc(CMSTDY=.,'',put(CMSTDY,best.)))||")";
if cmenrf="ONGOING" then cmendtc="Ongoing";
else if cmendtc^='' then cmendtc="End Date:"||strip(cmendtc);
cmnote=strip(cmendtc)||"; Indication: "||strip(cmae);
where CMAE ^='';
run;

proc sql;
	create table nar0
	(visit char length=60,
	subjid char length=6,
	eventy char length=40,
	event char length=200,
	date char length=19,
	note char length=260);
/*	label visit='Visit' eventy='Event type' event='Event' date='Date' note='Note';*/
quit;

data nar0;
	set nar0;
	label
	visit='Visit' eventy='Event type' event='Event' date='Date' note='Note';
run;



proc sql;
	insert into nar0 
	select distinct "",SUBJID,DSCAT,DSTERM,DSSTDTC, "Epoch=Treatment Phase"
	from ds01;

	insert into nar0 
	select distinct "",SUBJID,DSCAT,DSTERM,DSSTDTC, "Epoch=Screening"
	from ds02;

	insert into nar0 
	select distinct "", SUBJID,"SAE",AETERM,AESTDTC, SAENOTE
	from sae;

	insert into nar0 
	select distinct "",SUBJID,"AE",AETERM,AESTDTC, AENOTE
	from ae;

	insert into nar0 
	select distinct "",SUBJID,"CM",CMTRT,CMSTDTC, CMNOTE
	from cm;

	insert into nar0 
	select distinct visit_,SUBJID,LBCAT,LBTEST,LBDTC, lbnote
	from lbbi_;

	insert into nar0 
	select distinct visit_,SUBJID,LBCAT,LBTEST,LBDTC, lbnote
	from lbcbc_;

	insert into nar0 
	select distinct visit_,SUBJID,LBCAT,LBTEST,LBDTC, lbnote
	from lbschem_;


/*	insert into nar0 */
/*	select distinct SUBJID,"ECOG","Ecog Performance Status",QSDTC, "rd"*/
/*	from source.QS;*/

	insert into nar0 
	select distinct a_visit,SUBJID,'PE','Physical Examination: abnormal',pedtc, peorres1
	from pe;

	insert into nar0 
	select distinct visit,SUBJID,"ECG",EGTEST,EGDTC, EGNOTE
	from eg1;

	insert into nar0 
	select distinct a_visit,SUBJID,"Vital Signs",VSTEST,VSDTC, VSNOTE
	from vs_;

quit;

proc sort data=nar0 out=pdata.NARRATIVE(label='Narrative'); by SUBJID date eventy; run;
