

%include '_setup.sas';

*<TUTR1----------------------------------------------------------------------------------------;
%getVNUM(indata=source.rd_frmtarget1_scttar1t_active, out=rd_frmtarget1_scttar1t_active);
%getVNUM(indata=source.RD_FRMTARGET1, out=RD_FRMTARGET1);
data tu1;
	length EVALDT $19 DIAM $20 PROCEDURE $200 SITE $200;
	set rd_frmtarget1_scttar1t_active(rename=(visitnum=__visitnum));
	%informatDate(DOV);
	%formatDate(ITMTAR1EVALDT_DTS);
	label
		A_DOV='Visit Date'
		TUMCOD='Tumor Code'
		SITE='Site'
		PROCEDURE='Procedure'
		EVALDT='Date of Evaluation'
		DIAM='Diameter#<mm>'
		visitmnemonic='Visit'
	;
	TUMCOD=ITMTAR1TUMCOD;
	EVALDT=ITMTAR1EVALDT_DTS;
	%concatoth(var=ITMTAR1SITCDOTH_C,oth=ITMTAR1SITOTH,newvar=SITEOTH);
	if ITMTAR1SITCD^='' then SITE=ITMTAR1SITCD;else SITE=SITEOTH;
	%concatoth(var=ITMTAR1PROC_C,oth=ITMTAR1PROCOTH,newvar=PROCEDURE1);
	if ITMTAR1PROC='Other, specify' then PROCEDURE=PROCEDURE1;else PROCEDURE=ITMTAR1PROC;
	%char(var=ITMTAR1DIAM,newvar=DIAM);
	keep &GlobalVars4 TUMCOD SITE EVALDT PROCEDURE DIAM ITEMSETIDX;
run; 
data tr1;
	set RD_FRMTARGET1(rename=(visitnum=__visitnum));
	%informatDate(DOV);
	label
		A_DOV='Visit Date'
		DIAMSUM='Sum of Diameters#<mm>'
		UPSUM_CITMCHECKED_C='Update Sum of the Diameters calculation?'
		visitmnemonic='Visit'
	;
	%char(var=ITMTAR1DIAMSUM,newvar=DIAMSUM);
	UPSUM_CITMCHECKED_C=ITMTAR1UPSUM_CITMCHECKED_C;
	keep &GlobalVars4 DIAMSUM UPSUM_CITMCHECKED_C;
run; 
proc sql;
	create table TUTR1 as 
	select a.*,b.DIAMSUM,b.UPSUM_CITMCHECKED_C
	from (select * from TU1) as a
			left join 
          (select * from TR1) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and  a.visitmnemonic=b.visitmnemonic and a.A_DOV=b.A_DOV 
	order by SUBJECTNUMBERSTR, ITEMSETIDX;
quit;
*-------------------------------Add flag n--------------------------------------------*;
proc sort data=tutr1 out=tutr1_;by SUBJECTNUMBERSTR a_dov EVALDT ITEMSETIDX;run;
data tutr_1;
	set tutr1_(where=(diam^=''));
	by SUBJECTNUMBERSTR a_dov;
	retain sum_;
   attrib
      __n  label = '"Sum of Diameters" is true or false'    length = $20;
	__n='';
	if first.a_dov then sum_=input(diam,best.); else sum_=sum_+input(diam,best.);
	%char(var=sum_,newvar=sum);
	if last.a_dov;
	keep SUBJECTNUMBERSTR a_dov sum __n;
run;
proc sql;
	create table TUTR1_n as 
	select a.*,b.sum,b.__n
	from (select * from TUTR1) as a
			left join 
          (select * from tutr_1) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and a.A_DOV=b.A_DOV
	order by SUBJECTNUMBERSTR,TUMCOD,ITEMSETIDX; 
quit;
data TUTR14;
	keep &GlobalVars4 TUMCOD SITE PROCEDURE EVALDT DIAM DIAMSUM sum UPSUM_CITMCHECKED_C __ITEMSETIDX __n;
	set TUTR1_n(rename=(ITEMSETIDX=__ITEMSETIDX));
	if strip(diamsum)=strip(sum) then __n='';else __n='False';
	if strip(DIAM)='' then DIAMSUM='';
run;
*------------------------------------------------------------------------------------------>;

*<TUTR2----------------------------------------------------------------------------------------;
%getVNUM(indata=source.RD_FRMTARGET2_SCTTAR2T_ACTIVE, out=RD_FRMTARGET2_SCTTAR2T_ACTIVE);
%getVNUM(indata=source.RD_FRMTARGET2, out=RD_FRMTARGET2);
data tu2;
	length EVALDT $19 DIAM $20 PROCEDURE $200 SITE $200;
	set RD_FRMTARGET2_SCTTAR2T_ACTIVE(rename=(visitnum=__visitnum));
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
	keep &GlobalVars4 TUMCOD SITE EVALDT PROCEDURE DIAM ITEMSETIDX;
run; 
data tr2;
	set RD_FRMTARGET2(rename=(visitnum=__visitnum));
	%informatDate(DOV);
	label
		A_DOV='Visit Date'
		DIAMSUM='Sum of Diameters#<mm>'
		UPSUM_CITMCHECKED_C='Update Sum of the Diameters calculation?'
		visitmnemonic='Visit'
	;
	%char(var=ITMTAR2DIAMSUM,newvar=DIAMSUM);
	UPSUM_CITMCHECKED_C=ITMTAR2UPSUM_CITMCHECKED_C;
	keep &GlobalVars4 DIAMSUM UPSUM_CITMCHECKED_C;
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
	keep SUBJECTNUMBERSTR a_dov sum __n;
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
	keep &GlobalVars4 TUMCOD SITE PROCEDURE EVALDT DIAM DIAMSUM sum UPSUM_CITMCHECKED_C __ITEMSETIDX __n;
	set TUTR2_n(rename=(ITEMSETIDX=__ITEMSETIDX));
	if strip(diamsum)=strip(sum) then __n='';else __n='False';
	if DIAM='Not evaluated' or strip(DIAM)='' then DIAMSUM='';
run;
data tutr;
	set tutr14 tutr51;
run;
proc sort data= tutr;by SUBJECTNUMBERSTR __visitnum a_dov __ITEMSETIDX;run;
data TUTR_;
	set TUTR(rename=(DIAMSUM=DIAMSUM_));
	label
		DIAMSUM='Sum of Diameters#<mm>';
	if __n='False' then DIAMSUM="^{style [foreground=&abovecolor textdecoration=line_through]"
	|| strip(DIAMSUM_)||"}"||' '||"^{style [foreground=&norangecolor] "|| strip(sum)||"}";
		else DIAMSUM=strip(DIAMSUM_);
	if index(DIAMSUM,'^')>0 then __label="Target Lesions ^{newline 2}^{style[fontsize=7pt foreground=green]NOTE: }"||
	"^{style[fontsize=7pt foreground=red textdecoration=line_through]incorrect value}"
	||"^{style[fontsize=7pt foreground=green] correct value by Q2}";
	else __label="Target Lesions";
run;
data pdata.TUTR(label='Target Lesions');
	retain &GlobalVars4 TUMCOD SITE PROCEDURE EVALDT DIAM DIAMSUM UPSUM_CITMCHECKED_C __ITEMSETIDX __label;
	keep &GlobalVars4 TUMCOD SITE PROCEDURE EVALDT DIAM DIAMSUM UPSUM_CITMCHECKED_C __ITEMSETIDX __label;
	set TUTR_;
run;
