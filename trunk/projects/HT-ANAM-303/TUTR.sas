
%include '_setup.sas';

*<TUTR----------------------------------------------------------------------------------------;
%macro trtu(source=,flag=);

%do i=1 %to 2;
%getVNUM1(indata=&&source..rd_frmtarget&i._scttar&i.t_active, pdata=_visitindex_&source,out=rd_frmtarget&i._scttar&i.t_active);
%getVNUM1(indata=&&source..rd_frmtarget&i,pdata=_visitindex_&source, out=rd_frmtarget&i);
%end;

data tu1;
	length EVALDT $19 DIAM $20 PROCEDURE $200 SITE $200;
	set rd_frmtarget1_scttar1t_active;
	%informatDate(DOV);
	%formatDate(ITMTAR1EVALDT_DTS);
	label
		A_DOV='Visit Date'
		TUMCOD='Tumor Code'
		SITE='Site'
		PROCEDURE='Procedure'
		EVALDT='Date of Evaluation'
		DIAM='Diameter#<mm>'
	;
	TUMCOD=ITMTAR1TUMCOD;
	EVALDT=ITMTAR1EVALDT_DTS;
	%concatoth(var=ITMTAR1SITCDOTH_C,oth=ITMTAR1SITOTH,newvar=SITEOTH);
	if ITMTAR1SITCD^='' then SITE=ITMTAR1SITCD;else SITE=SITEOTH;
	%concatoth(var=ITMTAR1PROC_C,oth=ITMTAR1PROCOTH,newvar=PROCEDURE1);
	if ITMTAR1PROC='Other, specify' then PROCEDURE=PROCEDURE1;else PROCEDURE=ITMTAR1PROC;
	%char(var=ITMTAR1DIAM,newvar=DIAM);
	keep SUBJECTNUMBERSTR visitmnemonic dov A_DOV TUMCOD SITE EVALDT PROCEDURE DIAM ITEMSETIDX visitnum;
run; 

data tu2;
	length EVALDT $19 DIAM $20 PROCEDURE $200 SITE $200;
	set RD_FRMTARGET2_SCTTAR2T_ACTIVE;
	%informatDate(DOV);
	%formatDate(ITMTAR2EVALDT_DTS);
	label
		A_DOV='Visit Date'
		TUMCOD='Tumor Code'
		SITE='Site'
		PROCEDURE='Procedure'
		EVALDT='Date of Evaluation'
		DIAM='Diameter#<mm>'
	;
	TUMCOD=ITMTAR2TUMCOD;
	if ITMTAR2EVALDTDONE_C='NOT EVALUATED' then EVALDT=ITMTAR2EVALDTDONE;
	   else if ITMTAR2EVALDTDONE_C='DONE' then EVALDT=ITMTAR2EVALDT_DTS;
	%concatoth(var=ITMTAR2SITCDOTH_C,oth=ITMTAR2SITOTH,newvar=SITEOTH);
	if ITMTAR2SITCD^='' then SITE=ITMTAR2SITCD;else SITE=SITEOTH;
	%concatoth(var=ITMTAR2PROC_C,oth=ITMTAR2PROCOTH,newvar=PROCEDURE1);
	if ITMTAR2PROC='Other, specify' then PROCEDURE=PROCEDURE1;else PROCEDURE=ITMTAR2PROC;
	%char(var=ITMTAR2DIAM,newvar=DIAM1);
	if ITMTAR2DIAMDONE_C='NOT EVALUATED' then DIAM=ITMTAR2DIAMDONE;
	   else if ITMTAR2DIAMDONE_C='DONE' then DIAM=DIAM1;
	keep SUBJECTNUMBERSTR visitmnemonic dov A_DOV TUMCOD SITE EVALDT PROCEDURE DIAM ITEMSETIDX visitnum;
run; 

%do j=1 %to 2;
data tr&j;
	set rd_frmtarget&j;
	%informatDate(DOV);
	label
		A_DOV='Visit Date'
		DIAMSUM='Sum of Diameters#<mm>'
		UPSUM_CITMCHECKED_C='Update Sum of the Diameters calculation?'
		visitmnemonic='Visit'
	;
	%char(var=ITMTAR&j.DIAMSUM,newvar=DIAMSUM);
	UPSUM_CITMCHECKED_C=ITMTAR&j.UPSUM_CITMCHECKED_C;
	keep SUBJECTNUMBERSTR visitmnemonic dov A_DOV DIAMSUM UPSUM_CITMCHECKED_C visitnum;
run; 
proc sql;
	create table TUTR&j as 
	select a.*,b.DIAMSUM,b.UPSUM_CITMCHECKED_C
	from (select * from TU&j) as a
			left join 
          (select * from TR&j) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and  a.visitmnemonic=b.visitmnemonic and a.A_DOV=b.A_DOV 
	order by SUBJECTNUMBERSTR, ITEMSETIDX;
quit;

proc sort data=tutr&j out=tutr&j._;by SUBJECTNUMBERSTR a_dov EVALDT ITEMSETIDX;run;
data tutr_&j;
	set tutr&j._(where=(diam^='' and diam ^='Not evaluated'));
	by SUBJECTNUMBERSTR a_dov;
	retain sum_;
   attrib
      __n  label = '"Sum of Diameters" is true or false'    length = $20;
	__n='';
	if first.a_dov then sum_=input(diam,best.); else sum_=sum_+input(diam,best.);
	%char(var=sum_,newvar=sum);
	if last.a_dov;
	keep SUBJECTNUMBERSTR dov a_dov sum __n;
run;
proc sql;
	create table TUTR&j._n as 
	select a.*,b.sum,b.__n
	from (select * from TUTR&j) as a
			left join 
          (select * from tutr_&j) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and a.A_DOV=b.A_DOV
	order by SUBJECTNUMBERSTR,TUMCOD,ITEMSETIDX; 
quit;
data trtu&&source._&j;
	keep SUBJECTNUMBERSTR visitmnemonic dov A_DOV TUMCOD SITE PROCEDURE EVALDT DIAM DIAMSUM sum UPSUM_CITMCHECKED_C __ITEMSETIDX __n visitnum;
	set TUTR&j._n(rename=(ITEMSETIDX=__ITEMSETIDX));
	if strip(diamsum)=strip(sum) then __n='';else __n='False';
	if strip(DIAM)='' then DIAMSUM='';
run;
%end;

data tutr;
	set trtu&&source._1 trtu&&source._2;
run;
proc sort data= tutr;by SUBJECTNUMBERSTR dov a_dov __ITEMSETIDX;run;
data TUTR_&source;
	length flag $20;
	set TUTR(rename=(DIAMSUM=DIAMSUM_));
	label
		DIAMSUM='Sum of Diameters#<mm>';
	if __n='False' then DIAMSUM="!{style [foreground=&abovecolor textdecoration=line_through]"
	|| strip(DIAMSUM_)||"}"||' '||"!{style [foreground=&norangecolor] "|| strip(sum)||"}";
		else DIAMSUM=strip(DIAMSUM_);
	if index(DIAMSUM,'!')>0 then __label="Target Lesions !{newline 2}!{style[fontsize=7pt foreground=green]NOTE: }"||
	"!{style[fontsize=7pt foreground=red textdecoration=line_through]incorrect value}"
	||"!{style[fontsize=7pt foreground=green] correct value by Q2}";
	else __label="Target Lesions";
	flag="&flag";
run;
%mend trtu;

%trtu(source=r301,flag=ANAM301);
%trtu(source=r302,flag=ANAM302);

%getVNUM(indata=source.rd_frmtarget_scttar2tu_active, out=rd_frmtarget_scttar2tu_active);
%getVNUM(indata=source.rd_frmtarget, out=rd_frmtarget);

data tu2;
	length EVALDT $19 DIAM $20 PROCEDURE $200 SITE $200;
	set rd_frmtarget_scttar2tu_active;
	%informatDate(DOV);
	%formatDate(ITMTAR2EVALDT_DTS);
	label
		A_DOV='Visit Date'
		TUMCOD='Tumor Code'
		SITE='Site'
		PROCEDURE='Procedure'
		EVALDT='Date of Evaluation'
		DIAM='Diameter#<mm>'
		visitmnemonic='Visit'
	;
	TUMCOD=ITMTAR2TUMCOD;
	if ITMTAR2EVALDTDONE_C='NOT EVALUATED' then EVALDT=ITMTAR2EVALDTDONE;
	   else if ITMTAR2EVALDTDONE_C='DONE' then EVALDT=ITMTAR2EVALDT_DTS;
	%concatoth(var=ITMTAR2SITCDOTH_C,oth=ITMTAR2SITOTH,newvar=SITEOTH);
	if ITMTAR2SITCD^='' then SITE=ITMTAR2SITCD;else SITE=SITEOTH;
	%concatoth(var=ITMTAR2PROC_C,oth=ITMTAR2PROCOTH,newvar=PROCEDURE1);
	if ITMTAR2PROC='Other, specify' then PROCEDURE=PROCEDURE1;else PROCEDURE=ITMTAR2PROC;
	%char(var=ITMTAR2DIAM,newvar=DIAM1);
	if ITMTAR2DIAMDONE_C='NOT EVALUATED' then DIAM=ITMTAR2DIAMDONE;
	   else if ITMTAR2DIAMDONE_C='DONE' then DIAM=DIAM1;
	keep SUBJECTNUMBERSTR visitmnemonic dov A_DOV TUMCOD SITE EVALDT PROCEDURE DIAM ITEMSETIDX;
run; 
data tr2;
	set rd_frmtarget;
	%informatDate(DOV);
	label
		A_DOV='Visit Date'
		DIAMSUM='Sum of Diameters#<mm>'
		UPSUM_CITMCHECKED_C='Update Sum of the Diameters calculation?'
		visitmnemonic='Visit'
	;
	%char(var=ITMTAR2DIAMSUM,newvar=DIAMSUM);
	UPSUM_CITMCHECKED_C=ITMTAR2UPSUM_CITMCHECKED_C;
	keep SUBJECTNUMBERSTR visitmnemonic dov A_DOV DIAMSUM UPSUM_CITMCHECKED_C;
run; 
proc sql;
	create table TUTR2 as 
	select a.*,b.DIAMSUM,b.UPSUM_CITMCHECKED_C
	from (select * from TU2) as a
			left join 
          (select * from TR2) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and  a.visitmnemonic=b.visitmnemonic and a.A_DOV=b.A_DOV 
	order by SUBJECTNUMBERSTR, ITEMSETIDX;
quit;
*-------------------------------Add flag n--------------------------------------------*;
proc sort data=tutr2 out=tutr2_;by SUBJECTNUMBERSTR a_dov EVALDT ITEMSETIDX;run;
data tutr_2;
	set tutr2_(where=(diam^='' and diam^='Not evaluated'));
	by SUBJECTNUMBERSTR a_dov;
	retain sum_;
   attrib
      __n  label = '"Sum of Diameters" is true or false'    length = $20;
	__n='';
	if first.a_dov then sum_=input(diam,best.); else sum_=sum_+input(diam,best.);
	%char(var=sum_,newvar=sum);
	if last.a_dov;
	keep SUBJECTNUMBERSTR dov a_dov sum __n;
run;
proc sql;
	create table TUTR2_n as 
	select a.*,b.sum,b.__n
	from (select * from TUTR2) as a
			left join 
          (select * from tutr_2) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and a.A_DOV=b.A_DOV
	order by SUBJECTNUMBERSTR,TUMCOD,ITEMSETIDX; 
quit;
data TUTR51;
	keep SUBJECTNUMBERSTR visitmnemonic dov A_DOV TUMCOD SITE PROCEDURE EVALDT DIAM DIAMSUM sum UPSUM_CITMCHECKED_C __ITEMSETIDX __n;
	set TUTR2_n(rename=(ITEMSETIDX=__ITEMSETIDX));
	if strip(diamsum)=strip(sum) then __n='';else __n='False';
	if DIAM='Not evaluated' or strip(DIAM)='' then DIAMSUM='';
run;
data tutr;
	set tutr51;
run;
proc sort data= tutr;by SUBJECTNUMBERSTR  a_dov __ITEMSETIDX;run;
data TUTR_;
	length flag $20;
	set TUTR(rename=(DIAMSUM=DIAMSUM_));
	label
		DIAMSUM='Sum of Diameters#<mm>';
	if __n='False' then DIAMSUM="!{style [foreground=&abovecolor textdecoration=line_through]"
	|| strip(DIAMSUM_)||"}"||' '||"!{style [foreground=&norangecolor] "|| strip(sum)||"}";
		else DIAMSUM=strip(DIAMSUM_);
	if index(DIAMSUM,'!')>0 then __label="Target Lesions !{newline 2}!{style[fontsize=7pt foreground=green]NOTE: }"||
	"!{style[fontsize=7pt foreground=red textdecoration=line_through]incorrect value}"
	||"!{style[fontsize=7pt foreground=green] correct value by Q2}";
	else __label="Target Lesions";
	flag="ANAM303";
run;

data tutr_01;
	set tutr_r301 tutr_r302 ;
run;

proc sort data=TUTR_ out=s_TUTR_(keep=SUBJECTNUMBERSTR) nodupkey; by SUBJECTNUMBERSTR; run;

proc sql;
	create table tutr_02 as
	select a.*
	from tutr_01 as a inner join s_TUTR_ as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
;
quit;


data tutr_03;
	set tutr_02 TUTR_;
run;
proc sort data=tutr_03 ; by SUBJECTNUMBERSTR DESCENDING __label; run;
data tutr_04;

	set tutr_03(rename=__label=__label1);
	by SUBJECTNUMBERSTR;
	retain __label;
	if first.SUBJECTNUMBERSTR then __label=__label1;else __label=__label;
run;

proc sort data=tutr_04 out=s_tutr_03; by SUBJECTNUMBERSTR FLAG DOV; run;

data pdata.TUTR(label='Target Lesions');
	retain SUBJECTNUMBERSTR FLAG visitmnemonic A_DOV TUMCOD SITE PROCEDURE EVALDT DIAM DIAMSUM UPSUM_CITMCHECKED_C __ITEMSETIDX __label;
	keep SUBJECTNUMBERSTR FLAG visitmnemonic A_DOV TUMCOD SITE PROCEDURE EVALDT DIAM DIAMSUM UPSUM_CITMCHECKED_C __ITEMSETIDX __label;
	set s_tutr_03;
	label flag='Study ID'
		  visitmnemonic='Visit';
run;

