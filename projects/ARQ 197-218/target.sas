* Program Name: TARGET.sas;
* Author: Xiu Pan (xiu.pan@januscri.com);
* Initial Date: 19/02/2014;


%include '_setup.sas';

/*list of macro variable*/
%let dlm=$;


%macro concatoth(var=,oth=,newvar=);
		if &oth>'' then &newvar=strip(&var)||': '||&oth;
		else &newvar=strip(&var);
%mend concatoth;

data tscr01;
	set source.target(rename=(tlpf1=tlpf1_ tlloc1=tlloc1_ tlpf2=tlpf2_ tlloc2=tlloc2_ tlpf3=tlpf3_ tlloc3=tlloc3_ 
				tlpf4=tlpf4_ tlloc4=tlloc4_ tlpf5=tlpf5_ tlloc5=tlloc5_ )) ;
	%subjid;
	length tdtc $10 visit $60 METHOD tlpf1 tlloc1 tlpf2 tlloc2 tlpf3 tlloc3 tlpf4 tlloc4 tlpf5 tlloc5 $200  ;

	%getCycle;
	%getDate(leadq=tlperf, numdate=tlasdt)
	visit=__visit;
	tdtc=__date;

	%concatoth(var=TLMET,oth=TLMETSP,newvar=method);

	%concatoth(var=tlpf1_,oth=tlpna1,newvar=tlpf1);
	%concatoth(var=tlloc1_,oth=tllocsp1,newvar=tlloc1);

	%concatoth(var=tlpf2_,oth=tlpna2,newvar=tlpf2);
	%concatoth(var=tlloc2_,oth=tllocsp2,newvar=tlloc2);

	%concatoth(var=tlpf3_,oth=tlpna3,newvar=tlpf3);
	%concatoth(var=tlloc3_,oth=tllocsp3,newvar=tlloc3);

	%concatoth(var=tlpf4_,oth=tlpna4,newvar=tlpf4);
	%concatoth(var=tlloc4_,oth=tllocsp4,newvar=tlloc4);

	%concatoth(var=tlpf5_,oth=tlpna5,newvar=tlpf5);
	%concatoth(var=tlloc5_,oth=tllocsp5,newvar=tlloc5);

	keep subjid method visit tdtc tlpf1 tlloc1 tlpf2 tlloc2 tlpf3 tlloc3 tlpf4 tlloc4 tlpf5 tlloc5
		tlnum1 tllocpo1 tlmeas1 tlnum2 tllocpo2 tlmeas2 tlnum3 tllocpo3 tlmeas3 tlnum4 tllocpo4 tlmeas4
		tlnum5 tllocpo5 tlmeas5 tlmsum __vdate;
run;

data tful01;
	set source.targetfu(rename=(tlpff1=tlpff1_ tllof1=tllof1_ tlpff2=tlpff2_ tllf2=tllf2_ tlpff3=tlpff3_ tllf3=tllf3_
			tlpff4=tlpff4_ tllf4=tllf4_ tlpff5=tlpff5_ tllf5=tllf5_ tlnumf1=tlnum1 tllocpf1=tllocpo1 tlmeasf1=tlmeas1
			tlnumf2=tlnum2 tllocpf2=tllocpo2 tlmeasf2=tlmeas2 tlnumf3=tlnum3 tllocpf3=tllocpo3 tlmeasf3=tlmeas3
			tlnumf4=tlnum4 tllocpf4=tllocpo4 tlmeasf4=tlmeas4 tlnumf5=tlnum5 tllocpf5=tllocpo5 tlmeasf5=tlmeas5
			tlmsumf=tlmsum));
	%subjid;
	length tdtc $10 visit $60 METHOD tlpf1 tlloc1 tlpf2 tlloc2 tlpf3 tlloc3 tlpf4 tlloc4 tlpf5 tlloc5 $200  ;
	%getCycle;
	%getDate(leadq=tlperf, numdate=tlfuasdt)
	visit=__visit;
	tdtc=__date;

	%concatoth(var=tlfum,oth=tlfumtsp,newvar=method);

	%concatoth(var=tlpff1_,oth=tlpnaf1,newvar=tlpf1);
	%concatoth(var=tllof1_,oth=tllspf1,newvar=tlloc1);

	%concatoth(var=tlpff2_,oth=tlpnaf2,newvar=tlpf2);
	%concatoth(var=tllf2_,oth=tllosf2,newvar=tlloc2);

	%concatoth(var=tlpff3_,oth=tlpnaf3,newvar=tlpf3);
	%concatoth(var=tllf3_,oth=tllspf3,newvar=tlloc3);

	%concatoth(var=tlpff4_,oth=tlpnaf4,newvar=tlpf4);
	%concatoth(var=tllf4_,oth=tllspf4,newvar=tlloc4);

	%concatoth(var=tlpff5_,oth=tlpnaf5,newvar=tlpf5);
	%concatoth(var=tllf5_,oth=tllspf5,newvar=tlloc5);

	keep subjid method visit tdtc tlpf1 tlloc1 tlpf2 tlloc2 tlpf3 tlloc3 tlpf4 tlloc4 tlpf5 tlloc5
		tlnum1 tllocpo1 tlmeas1 tlnum2 tllocpo2 tlmeas2 tlnum3 tllocpo3 tlmeas3 tlnum4 tllocpo4 tlmeas4
		tlnum5 tllocpo5 tlmeas5 tlmsum __vdate;
run;

data target01;
	length lesion1 lesion2 lesion3 lesion4 lesion5 lesion6 $200;
	set tscr01 tful01;
lesion1=ifc(TLNUM1^=.,strip(put(TLNUM1,best.)),'.')||"&dlm"||ifc(TLLOCPO1^='',strip(TLLOCPO1),'.')||"&dlm"||ifc(TLMEAS1^=.,strip(put(TLMEAS1,best.)),'.')||"&dlm"||ifc(TLPF1^='',strip(TLPF1),'.')||"&dlm"||ifc(TLLOC1^='',strip(TLLOC1),'.');
lesion2=ifc(TLNUM2^=.,strip(put(TLNUM2,best.)),'.')||"&dlm"||ifc(TLLOCPO2^='',strip(TLLOCPO2),'.')||"&dlm"||ifc(TLMEAS2^=.,strip(put(TLMEAS2,best.)),'.')||"&dlm"||ifc(TLPF2^='',strip(TLPF2),'.')||"&dlm"||ifc(TLLOC2^='',strip(TLLOC2),'.');
lesion3=ifc(TLNUM3^=.,strip(put(TLNUM3,best.)),'.')||"&dlm"||ifc(TLLOCPO3^='',strip(TLLOCPO3),'.')||"&dlm"||ifc(TLMEAS3^=.,strip(put(TLMEAS3,best.)),'.')||"&dlm"||ifc(TLPF3^='',strip(TLPF3),'.')||"&dlm"||ifc(TLLOC3^='',strip(TLLOC3),'.');
lesion4=ifc(TLNUM4^=.,strip(put(TLNUM4,best.)),'.')||"&dlm"||ifc(TLLOCPO4^='',strip(TLLOCPO4),'.')||"&dlm"||ifc(TLMEAS4^=.,strip(put(TLMEAS4,best.)),'.')||"&dlm"||ifc(TLPF4^='',strip(TLPF4),'.')||"&dlm"||ifc(TLLOC4^='',strip(TLLOC4),'.');
lesion5=ifc(TLNUM5^=.,strip(put(TLNUM5,best.)),'.')||"&dlm"||ifc(TLLOCPO5^='',strip(TLLOCPO5),'.')||"&dlm"||ifc(TLMEAS5^=.,strip(put(TLMEAS5,best.)),'.')||"&dlm"||ifc(TLPF5^='',strip(TLPF5),'.')||"&dlm"||ifc(TLLOC5^='',strip(TLLOC5),'.');
lesion6='.'||"&dlm"||'.'||"&dlm"||ifc(TLMSUM^='',"SUM: "||strip(TLMSUM),'.')||"&dlm"||'.'||"&dlm"||'.';

run;

/*proc sort data=target01 out=s_target01; by subjid tdtc visit method TLMSUM; run;*/
/*proc transpose data=s_target01 out=t_target01;*/
/*	by subjid tdtc visit method TLMSUM;*/
/*	var LESION1 LESION2 LESION3 LESION4 LESION5;*/
/*run;*/

proc sort data=target01 out=s_target01; by subjid tdtc visit method TLMSUM __vdate TLMSUM; run;

proc transpose data=s_target01 out=t_target01;
	by subjid tdtc visit method __vdate TLMSUM;
	var LESION1 LESION2 LESION3 LESION4 LESION5 lesion6;
run;

data target02;
	length tnum tsite tmeas teval tloc $200 ;
	set t_target01;
	%getvnum(visit=visit);
	tnum=ifc(scan(col1,1,"&dlm")^='.',scan(col1,1,"&dlm"),compress(_name_,,'a'));
	tsite=ifc(scan(col1,2,"&dlm")^='.',scan(col1,2,"&dlm"),'');
	tmeas=ifc(scan(col1,3,"&dlm")^='.',scan(col1,3,"&dlm"),'');
	teval=ifc(scan(col1,4,"&dlm")^='.',scan(col1,4,"&dlm"),'');
	tloc=ifc(scan(col1,5,"&dlm")^='.',scan(col1,5,"&dlm"),'');
	
	drop _name_ col1 ;
run;

data target03;
	set target02;
	label
		SUBJID='Subject ID'
		TNUM='Lesion Number'
		TSITE='Site'
		TMEAS='Measurement#<mm>'
		TEVAL='Evaluated?'
		TLOC='Location'
		TDTC='Assessment Date'
		VISIT='Visit'
		METHOD='Method'
	;

	if TNUM^='' then  ord=input(TNUM,best.)  ;
		else if TNUM='' and index(tmeas,"SUM")>0 then ord=6;

	if index(tmeas,"SUM")>0 then do;
		visit=''; tdtc=''; method='';
	end;
run;

proc sort data=target03; by subjid __vdate ord; run;

data done notdone ;
	set target03;
	if tdtc^='NOT DONE' then output done;
		else output notdone;
run;

proc sort data=notdone out=notdone_ nodupkey; by subjid visit; run;


proc sql;
	create table done01 as
	select a.*,b.tdtc_
	from done as a left join notdone_(rename=tdtc=tdtc_) as b
	on a.subjid=b.subjid and a.visitnum=b.visitnum 
	;
quit;

data done02;
	set done01;
	if tdtc_^='' and tmeas='SUM: 0.00' then delete;
run;

**********************************;
proc sort data=done02 out=s_done02; by subjid __vdate ord; run;

data done03;
	length base $20;
	set s_done02;
	by subjid __vdate ord;
	retain base;
	if first.subjid and visit='PRE STUDY' then base=TLMSUM;
		else base=base;

run;

data done04;
	set done03;
	if index(tmeas,"SUM")=0 then base='';

	if base ^='' then teval="Base SUM: "||strip(base);
run;
	
proc sort data=done04 ; by subjid __vdate ord; run;

data s_done04;
	set done04;
	if index(tmeas,"SUM")>0;
	TLMSUM_=input(TLMSUM,best.);

run;

/*
data done05;
	set s_done04;
	by subjid visitnum ord;
	retain nad1;
	if first.subjid then do; nad1=TLMSUM_;nad2 = nad1; end;
	else nad2 = nad1;
	if nad1 > TLMSUM_ then do;
			nad1=TLMSUM_;  end;
run;
*/

data done05;
	set s_done04;
	by subjid __vdate ord;
	nad1=lag(TLMSUM_);
	if first.subjid then nad1=TLMSUM_;
run;

data done06;
	set done05;
	by subjid __vdate ord;
	retain nad2;
	if first.subjid then nad2=nad1;
		else if nad2>nad1 then nad2=nad1;

	tsite='Nadir SUM: '||strip(put(nad2,10.2));
	rename tsite=tsite_;
run;

proc sql;
	create table done07 as
	select a.*,b.tsite_
	from done04 as a left join done06 as b
	on a.subjid=b.subjid and a.__VDATE=b.__VDATE and a.visitnum=b.visitnum and a.ord=b.ord;
quit;

data done08;
	set done07;
	if tsite_^='' then tsite=tsite_;
	if visitnum=100000 and ord=6 then do;teval='';tsite=''; end;
run;
************************************;

data notdone_;
	set notdone_;
	tnum='';
run;

data target04;
	set done08 notdone_;
/*	if index(tmeas,"SUM")>0 then tmeas=strip(compress(compress(tmeas,,'a'),':'));*/
	if index(tmeas,"SUM")>0 then
		do;
			__sumline = 'Y';
			tnum = '';
		end;
run;

proc sort data=target04; by subjid __vdate visitnum ord; run;

data pdata.target(label='Target Tumor Lesions Assessments');
	retain SUBJID VISIT TDTC METHOD TNUM TEVAL TLOC TSITE TMEAS __sumline;
	keep SUBJID VISIT TDTC METHOD TNUM TEVAL TLOC TSITE TMEAS __sumline;
	set target04;
run;





	

