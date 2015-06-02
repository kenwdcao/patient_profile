* Program Name: TARGET.sas;
* Author: Xiu Pan (xiu.pan@januscri.com);
* Initial Date: 19/02/2014;


%include '_setup.sas';

%macro concatoth(var=,oth=,newvar=);
		if &oth>'' then &newvar=strip(&var)||': '||&oth;
		else &newvar=strip(&var);
%mend concatoth;

%macro concatoth1;
	%do i=1 %to 20;
	%concatoth(var=ntp&i._,oth=ntne&i,newvar=ntpf&i);
	%concatoth(var=ntllc&i._,oth=ntllsp&i,newvar=ntllf&i);
	%end;
%mend concatoth1;

%macro concatoth2;
	%do i=1 %to 9;
	%concatoth(var=ntpf&i._,oth=ntnef&i,newvar=ntpf&i);
	%concatoth(var=ntllf&i._,oth=ntllspf&i,newvar=ntllf&i);
	%end;
	%do i=10 %to 20;
	%concatoth(var=ntpf&i._,oth=ntnef&i,newvar=ntpf&i);
	%concatoth(var=ntllf&i._,oth=ntlspf&i,newvar=ntllf&i);
	%end;

%mend concatoth2;


data ntscr01;
	set source.ntarget(rename=(ntp1=ntp1_ ntllc1=ntllc1_ ntp2=ntp2_ ntll2=ntllc2_ ntp3=ntp3_ ntll3=ntllc3_
			ntp4=ntp4_ ntll4=ntllc4_ ntp5=ntp5_ ntll5=ntllc5_ ntp6=ntp6_ ntll6=ntllc6_ ntp7=ntp7_ ntll7=ntllc7_
			ntp8=ntp8_ ntll8=ntllc8_ ntp9=ntp9_ ntll9=ntllc9_ ntp10=ntp10_ ntll10=ntllc10_ ntp11=ntp11_ ntll11=ntllc11_ 
			ntp12=ntp12_ ntll12=ntllc12_ ntp13=ntp13_ ntll13=ntllc13_ ntp14=ntp14_ ntll14=ntllc14_ ntp15=ntp15_ ntll15=ntllc15_ 
			ntp16=ntp16_ ntll16=ntllc16_ ntp17=ntp17_ ntll17=ntllc17_ ntp18=ntp18_ ntll18=ntllc18_ ntp19=ntp19_ ntll19=ntllc19_ 
			ntp20=ntp20_ ntll20=ntllc20_ ntad1=nta1 ntad2=nta2)) ;
	%subjid;
	length ntdtc $10 visit $60 METHOD ntpf1 ntllf1 ntpf2 ntllf2 ntpf3 ntllf3 ntpf4 ntllf4 ntpf5 ntllf5 ntpf6 ntllf6 ntpf7 ntllf7 
		ntpf8 ntllf8 ntpf9 ntllf9 ntpf10 ntllf10 ntpf11 ntllf11 ntpf12 ntllf12 ntpf13 ntllf13 ntpf14 ntllf14 ntpf15 ntllf15 ntpf16 ntllf16 
		ntpf17 ntllf17 ntpf18 ntllf18 ntpf19 ntllf19 ntpf20 ntllf20 $200;

	%getCycle;
	%getDate(leadq=ntlp, numdate=ntldt)
	visit=__visit;
	ntdtc=__date;

	%concatoth(var=ntlm,oth=ntlmsp,newvar=method);
	%concatoth1;

	keep subjid method visit ntdtc ntpf1 ntllf1 ntpf2 ntllf2 ntpf3 ntllf3 ntpf4 ntllf4 ntpf5 ntllf5 ntpf6 ntllf6 ntpf7 ntllf7 
		ntpf8 ntllf8 ntpf9 ntllf9 ntpf10 ntllf10 ntpf11 ntllf11 ntpf12 ntllf12 ntpf13 ntllf13 ntpf14 ntllf14 ntpf15 ntllf15 ntpf16 ntllf16 
		ntpf17 ntllf17 ntpf18 ntllf18 ntpf19 ntllf19 ntpf20 ntllf20 ntlno1 ntllpo1 ntlm1 nta1 ntlno2 ntllpo2 ntlm2 nta2
		ntlno3 ntllpo3 ntlm3 nta3 ntlno4 ntllpo4 ntlm4 nta4 ntlno5 ntllpo5 ntlm5 nta5 ntlno6 ntllpo6 ntlm6 nta6
		ntlno7 ntllpo7 ntlm7 nta7 ntlno8 ntllpo8 ntlm8 nta8 ntlno9 ntllpo9 ntlm9 nta9 ntlno10 ntllpo10 ntlm10 nta10
		ntlno11 ntllpo11 ntlm11 nta11 ntlno12 ntllpo12 ntlm12 nta12 ntlno13 ntllpo13 ntlm13 nta13 ntlno14 ntllpo14 ntlm14 nta14
		ntlno15 ntllpo15 ntlm15 nta15 ntlno16 ntllpo16 ntlm16 nta16 ntlno17 ntllpo17 ntlm17 nta17 ntlno18 ntllpo18 ntlm18 nta18
		ntlno19 ntllpo19 ntlm19 nta19 ntlno20 ntllpo20 ntlm20;
run;

%macro rename;
	%do i=1 %to 19;
	rename NTLNO&i=NTLNOF&i NTLLPO&i=NTLLPF&i NTLM&i=_NTLMF&i NTA&i=NFA&i;
	%end;
	%do i=20 %to 20;
	rename NTLNO&i=NTLNOF&i NTLLPO&i=NTLLPF&i NTLM&i=_NTLMF&i;
	%end;

%mend rename;

data ntscr02;
	set ntscr01;
	%rename;
run;

data ntscr03;
	length NTLMF1 NTLMF2 NTLMF3 NTLMF4 NTLMF5 NTLMF6 NTLMF7 NTLMF8 NTLMF9 NTLMF10 
			NTLMF11 NTLMF12 NTLMF13 NTLMF14 NTLMF15 NTLMF16 NTLMF17 NTLMF18 NTLMF19 NTLMF20 $24;
	set ntscr02;
	array var {*}  _NTLMF1-_NTLMF20;
	array newvar {*}  NTLMF1-NTLMF20;
		do i=1 to dim(var);
		newvar[i]=var[i];
		end;
run;



data ntful01;
	set source.ntargetfu(rename=(ntpf1=ntpf1_ ntllf1=ntllf1_ ntpf2=ntpf2_ ntllf2=ntllf2_ ntpf3=ntpf3_ ntllf3=ntllf3_
			ntpf4=ntpf4_ ntllf4=ntllf4_ ntpf5=ntpf5_ ntllf5=ntllf5_ ntpf6=ntpf6_ ntllf6=ntllf6_ ntpf7=ntpf7_ ntllf7=ntllf7_
			ntpf8=ntpf8_ ntllf8=ntllf8_ ntpf9=ntpf9_ ntllf9=ntllf9_ ntpf10=ntpf10_ ntlf10=ntllf10_ ntpf11=ntpf11_ ntlf11=ntllf11_ 
			ntpf12=ntpf12_ ntlf12=ntllf12_ ntpf13=ntpf13_ ntlf13=ntllf13_ ntpf14=ntpf14_ ntlf14=ntllf14_ ntpf15=ntpf15_ ntlf15=ntllf15_ 
			ntpf16=ntpf16_ ntlf16=ntllf16_ ntpf17=ntpf17_ ntlf17=ntllf17_ ntpf18=ntpf18_ ntlf18=ntllf18_ ntpf19=ntpf19_ ntlf19=ntllf19_ 
			ntpf20=ntpf20_ ntlf20=ntllf20_ ntlnf4=ntlnof4 ntmf10=ntlmf10 ntmf11=ntlmf11 ntmf12=ntlmf12 ntmf13=ntlmf13 ntmf14=ntlmf14
			ntmf15=ntlmf15 ntmf16=ntlmf16 ntmf17=ntlmf17 ntmf18=ntlmf18 ntmf19=ntlmf19 ntmf20=ntlmf20)) ;
	%subjid;
	length ntdtc $10 visit $60 METHOD ntpf1 ntllf1 ntpf2 ntllf2 ntpf3 ntllf3 ntpf4 ntllf4 ntpf5 ntllf5 ntpf6 ntllf6 ntpf7 ntllf7 
		ntpf8 ntllf8 ntpf9 ntllf9 ntpf10 ntllf10 ntpf11 ntllf11 ntpf12 ntllf12 ntpf13 ntllf13 ntpf14 ntllf14 ntpf15 ntllf15 ntpf16 ntllf16 
		ntpf17 ntllf17 ntpf18 ntllf18 ntpf19 ntllf19 ntpf20 ntllf20 $200;

	%getCycle;
	%getDate(leadq=ntlp, numdate=fntldt)
	visit=__visit;
	ntdtc=__date;

	%concatoth(var=fntlm,oth=fntlmsp,newvar=method);
	%concatoth2;

	keep subjid method visit ntdtc ntpf1 ntllf1 ntpf2 ntllf2 ntpf3 ntllf3 ntpf4 ntllf4 ntpf5 ntllf5 ntpf6 ntllf6 ntpf7 ntllf7 
		ntpf8 ntllf8 ntpf9 ntllf9 ntpf10 ntllf10 ntpf11 ntllf11 ntpf12 ntllf12 ntpf13 ntllf13 ntpf14 ntllf14 ntpf15 ntllf15 ntpf16 ntllf16 
		ntpf17 ntllf17 ntpf18 ntllf18 ntpf19 ntllf19 ntpf20 ntllf20 ntlnof1 ntllpf1 ntlmf1 nfa1 ntlnof2 ntllpf2 ntlmf2 nfa2
		ntlnof3 ntllpf3 ntlmf3 nfa3 ntlnof4 ntllpf4 ntlmf4 nfa4 ntlnof5 ntllpf5 ntlmf5 nfa5 ntlnof6 ntllpf6 ntlmf6 nfa6
		ntlnof7 ntllpf7 ntlmf7 nfa7 ntlnof8 ntllpf8 ntlmf8 nfa8 ntlnof9 ntllpf9 ntlmf9 nfa9 ntlnof10 ntllpf10 ntlmf10 nfa10
		ntlnof11 ntllpf11 ntlmf11 nfa11 ntlnof12 ntllpf12 ntlmf12 nfa12 ntlnof13 ntllpf13 ntlmf13 nfa13 ntlnof14 ntllpf14 ntlmf14 nfa14
		ntlnof15 ntllpf15 ntlmf15 nfa15 ntlnof16 ntllpf16 ntlmf16 nfa16 ntlnof17 ntllpf17 ntlmf17 nfa17 ntlnof18 ntllpf18 ntlmf18 nfa18
		ntlnof19 ntllpf19 ntlmf19 nfa19 ntlnof20 ntllpf20 ntlmf20;
run;


%macro concatvar(num=,site=,status=,add=,eval=,loc=,newvar=);
&newvar=ifc(&num^=.,strip(put(&num,best.)),'.')||'#'||ifc(&site^='',strip(&site),'.')||'#'||ifc(&status^='',strip(&status),'.')||'#'||ifc(&eval^='',strip(&eval),'.')||'#'||ifc(&loc^='',strip(&loc),'.')||'#'||ifc(&add^='',strip(&add),'.');
%mend concatvar;

%macro concatvar0(num=,site=,status=,eval=,loc=,newvar=);
&newvar=ifc(&num^=.,strip(put(&num,best.)),'.')||'#'||ifc(&site^='',strip(&site),'.')||'#'||ifc(&status^='',strip(&status),'.')||'#'||ifc(&eval^='',strip(&eval),'.')||'#'||ifc(&loc^='',strip(&loc),'.');
%mend concatvar0;

%macro concatvar1;
	%do i=1 %to 19;
	%concatvar(num=NTLNOF&i,site=NTLLPF&i,status=NTLMF&i,add=NFA&i,eval=NTPF&i,loc=NTLLF&i,newvar=lesion&i);
	%end;
	%do i=20 %to 20;
	%concatvar0(num=NTLNOF&i,site=NTLLPF&i,status=NTLMF&i,eval=NTPF&i,loc=NTLLF&i,newvar=lesion&i);
	%end;
%mend concatvar1; 


data ntarget01;
	set ntscr03 ntful01;
	%concatvar1;
run;

proc sort data=ntarget01 out=s_ntarget01; by subjid ntdtc visit method; run;

proc transpose data=s_ntarget01 out=t_ntarget01;
	by subjid ntdtc visit method ;
	var LESION1 LESION2 LESION3 LESION4 LESION5 LESION6 LESION7 LESION8 LESION9 LESION10 LESION11 LESION12
		LESION13 LESION14 LESION15 LESION16 LESION17 LESION18 LESION19 LESION20;
run;

data ntarget02;
	length ntnum ntsite status nteval ntloc add $200 ;
	set t_ntarget01;
	%getvnum(visit=visit);
	if count(col1,'#')=5 then do;
	ntnum=ifc(scan(col1,1,'#')^='.',scan(col1,1,'#'),compress(_name_,,'a'));
	ntsite=ifc(scan(col1,2,'#')^='.',scan(col1,2,'#'),'');
	status=ifc(scan(col1,3,'#')^='.',scan(col1,3,'#'),'');
	nteval=ifc(scan(col1,4,'#')^='.',scan(col1,4,'#'),'');
	ntloc=ifc(scan(col1,5,'#')^='.',scan(col1,5,'#'),'');
	add=ifc(scan(col1,6,'#')^='.',scan(col1,6,'#'),'');
	end;
	if count(col1,'#')=4 then do;
	ntnum=ifc(scan(col1,1,'#')^='.',scan(col1,1,'#'),compress(_name_,,'a'));
	ntsite=ifc(scan(col1,2,'#')^='.',scan(col1,2,'#'),'');
	status=ifc(scan(col1,3,'#')^='.',scan(col1,3,'#'),'');
	nteval=ifc(scan(col1,4,'#')^='.',scan(col1,4,'#'),'');
	ntloc=ifc(scan(col1,5,'#')^='.',scan(col1,5,'#'),'');
	end;

	drop _name_ col1 ;
run;

data ntarget03;
	set ntarget02;
	label
		SUBJID='Subject ID'
		NTNUM='Lesion Number'
		NTSITE='Site'
		STATUS='Lesion Status'
		NTEVAL='Evaluated?'
		NTLOC='Location'
		NTDTC='Assessment Date'
		VISIT='Visit'
		METHOD='Method'
		ADD='Additional Non-target Lesions'
	;

	if NTNUM^='' then  ord=input(NTNUM,best.)  ;
run;


proc sort data=ntarget03; by subjid visitnum ord; run;

data done notdone ;
	set ntarget03;
	if ntdtc^='NOT DONE' then output done;
		else output notdone;
run;

proc sort data=notdone out=notdone_ nodupkey; by subjid visit; run;

data ntarget04;
	set done notdone_;
	if cmiss(ntsite, ntloc, nteval, status, add)<5 or ntdtc='NOT DONE';
run;

proc sort data=ntarget04; by subjid visitnum ord; run;

data pdata.ntarget(label='Non-Target Tumor Lesions Assessments');
	retain SUBJID VISIT NTDTC METHOD NTNUM NTEVAL NTLOC NTSITE STATUS ;
	keep SUBJID VISIT NTDTC METHOD NTNUM NTEVAL NTLOC NTSITE STATUS ;
	set ntarget04;
run;
