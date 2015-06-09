
%include '_setup.sas';

*<VSALL--------------------------------------------------------------------------------------------------------;
*----------------------- Get range----------------------------------->;
*--->Magic Numbers (Normal Range);
%let SYSBPLOW=90;
%let SYSBPHIGH=140;
%let DIABPLOW=50;
%let DIABPHIGH=90;
%let HRLOW=50;
%let HRHIGH=100;
%let TEMPLOW=35.5;
%let TEMPHIGH=37.8;
%let RESPLOW=12;
%let RESPHIGH=18;

%macro concatVS(var=,done=,newvar=);
	if strip(&done)='Not Done' then &newvar='Not Done';
	else &newvar=ifc(&var=.,'',strip(put(&var,best.)));
%mend concatVS;

%macro concatVS1(var=,done=);
	if strip(&done)='Not Done' then &var='Not Done';
	else &var=&var;
%mend concatVS1;

%macro bp(sysbp=,diabp=,newvar=, nd=);
	if strip(&nd)='Not Done' then &newvar='Not Done'; 
	else &newvar=strip(&sysbp)||'!{style [foreground=black] / }'||strip(&diabp);
	if strip(&newvar)='!{style [foreground=black] / }' then &newvar='';
%mend bp;

%macro normalRange(var=,low=,high=,outvar=);
	if &var>. then do;
		if &var<&low then &outvar='!{style [foreground='||"&belowcolor"||' fontweight=bold]'||strip(put(&var,best.))||'}';
		else if &var>&high then &outvar='!{style [foreground='||"&abovecolor"||' fontweight=bold]'||strip(put(&var,best.))||'}';
		else &outvar=strip(put(&var,best.));
	end;
/*	else if strip(&nd)='Not Done' then do; &outvar='Not Done'; end;*/
%mend normalRange;

%macro lhvalue(a1=,a2=,a3=,a4=,a5=);
	%do i=1 %to 5;
	%let bl=&&a&i..LOW;
	%let bh=&&a&i..HIGH;
	%normalRange(var=ITMVS&&a&i,low=&&&bl,high=&&&bh,outvar=&&a&i);
	%end;
%mend lhvalue;

%getVNUM(indata=source.RD_FRMVS, out=RD_FRMVS);

data RD_FRMVS;
	LENGTH TEMP HR RESP BP WEIGHT SYSBP DIABP $200;
	set RD_FRMVS;
	%formatDate(ITMVSDT_DTS); 
	%informatDate(DOV);
	%lhvalue(a1=TEMP,a2=HR,a3=RESP,a4=SYSBP,a5=DIABP);
	%bp(sysbp=SYSBP,diabp=DIABP,newvar=BP,nd=ITMVSBPDONE);
	%concatVS(var=ITMVSWEIGHT,done=ITMVSWEIGHTDONE,newvar=WEIGHT);
	%concatVS1(var=TEMP,done=ITMVSTEMPDONE);
	%concatVS1(var=HR,done=ITMVSHRDONE);
	%concatVS1(var=RESP,done=ITMVSRESPDONE);
	if strip(ITMVSDTDONE)='Not Done' then ITMVSDT_DTS='Not Done';
	else ITMVSDT_DTS=ITMVSDT_DTS;
run;
*----------------------- First transpose----------------------------------->;
proc sort data=RD_FRMVS;
	by SUBJECTNUMBERSTR visitnum VISITMNEMONIC A_DOV ITMVSDT_DTS; 
run;
proc transpose data=RD_FRMVS out=t_FRMVS;
 	by SUBJECTNUMBERSTR visitnum VISITMNEMONIC A_DOV ITMVSDT_DTS; 
 	var TEMP HR RESP BP  WEIGHT ; 
run;

%macro vs(raw=,out=);
%getVNUM(indata=&raw..RD_FRMVS1, out=RD_FRMVS1);
%getVNUM(indata=&raw..RD_FRMVS2, out=RD_FRMVS2);
%getVNUM(indata=&raw..RD_FRMVS3, out=RD_FRMVS3);
data RD_FRMVS_1;
	LENGTH TEMP HR RESP BP HEIGHT WEIGHT BMI SYSBP DIABP $200;
	set RD_FRMVS1 RD_FRMVS2 RD_FRMVS3;
	VSDT=ITMVSDT_DTS;
	%formatDate(ITMVSDT_DTS); 
	%informatDate(DOV);
	%lhvalue(a1=TEMP,a2=HR,a3=RESP,a4=SYSBP,a5=DIABP);
	%bp(sysbp=SYSBP,diabp=DIABP,newvar=BP,nd=ITMVSBPDONE);
	%concatVS(var=ITMVSHEIGHT,done=ITMVSHEIGHTDONE,newvar=HEIGHT);
	%concatVS(var=ITMVSWEIGHT,done=ITMVSWEIGHTDONE,newvar=WEIGHT);
	%concatVS(var=ITMVS3BMI,done=ITMVS3BMIDONE,newvar=BMI);
	%concatVS1(var=TEMP,done=ITMVSTEMPDONE);
	%concatVS1(var=HR,done=ITMVSHRDONE);
	%concatVS1(var=RESP,done=ITMVSRESPDONE);
	if strip(ITMVSDTDONE)='Not Done' then ITMVSDT_DTS='Not Done';
	else ITMVSDT_DTS=ITMVSDT_DTS;
run;
proc sort data=RD_FRMVS_1;
	by SUBJECTNUMBERSTR VISITORDER visitnum VISITMNEMONIC VSDT A_DOV ITMVSDT_DTS FORMMNEMONIC; 
run;
proc transpose data=RD_FRMVS_1 out=t_FRMVS_1;
 	by SUBJECTNUMBERSTR VISITORDER visitnum VISITMNEMONIC VSDT A_DOV ITMVSDT_DTS FORMMNEMONIC; 
 	var TEMP HR RESP BP WEIGHT; 
run;
proc sort data=t_FRMVS_1;
	by SUBJECTNUMBERSTR _NAME_ VSDT VISITORDER FORMMNEMONIC; 
run;
proc sql;
	create table t_FRMVS_1_1 as
	select *
	from t_FRMVS_1
	group by SUBJECTNUMBERSTR, _NAME_  
	having count(distinct COL1) =1 and COL1^='';
quit;

DATA VS1;
	SET t_FRMVS_1_1;
	BY SUBJECTNUMBERSTR _NAME_;
	visitnum=-2;
	visitmnemonic='Wk-1!{super [2]}';
	IF LAST._NAME_;
RUN;

proc sql;
	create table t_FRMVS_1_2 as
	select *
	from t_FRMVS_1
	group by SUBJECTNUMBERSTR, _NAME_  
	having count(distinct COL1) >1 and COL1^='';
quit;

DATA VS2;
	SET t_FRMVS_1_2(WHERE=(COL1^='Not Done'));
	BY SUBJECTNUMBERSTR _NAME_;
	visitnum=-2;
	visitmnemonic='Wk-1!{super [2]}';
	IF LAST._NAME_;
RUN;
data VS_1;
	set VS1 VS2;
run;

proc sort data=t_FRMVS out=subject(keep=SUBJECTNUMBERSTR) nodupkey;by SUBJECTNUMBERSTR;run;
proc sql;
	create table VS_1_ AS
	select a.*
	from VS_1 as a inner join subject as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
	;
quit;
*-------- Get most vsdtc--------->;
proc sql;
	create table DTC as
	select *, count(VSDT) as n
	from VS_1_
	group by SUBJECTNUMBERSTR, VSDT
	;
quit;
proc sort data=DTC out=DTC1 nodupkey;by SUBJECTNUMBERSTR VSDT n;run;
proc sort data=DTC1 ;by SUBJECTNUMBERSTR n;run;
data DTC2;
	set DTC1;
	by SUBJECTNUMBERSTR;
	keep SUBJECTNUMBERSTR ITMVSDT_DTS;
	if last.SUBJECTNUMBERSTR;
run;
data VS_1_1;
	length SUBJECTNUMBERSTR $20 ITMVSDT_DTS $19;
	if _n_=1 then do;
		declare hash h (dataset :'DTC2');
		rc=h.defineKey ('SUBJECTNUMBERSTR');
		rc=h.defineData ('ITMVSDT_DTS');
		rc=h.defineDone ();
		call missing (SUBJECTNUMBERSTR,ITMVSDT_DTS);
	end;
	set VS_1_(rename=(ITMVSDT_DTS=ITMVSDT_DTS_));
	rc=h.find();
	if ITMVSDT_DTS=ITMVSDT_DTS_ then COL1=COL1;
	else COL1=strip(COL1)||' ('||strip(ITMVSDT_DTS_)||')';
	keep SUBJECTNUMBERSTR visitnum visitmnemonic ITMVSDT_DTS _NAME_ COL1;
run;

DATA VS_2;
	SET t_FRMVS_1(WHERE=(COL1^='Not Done' and COL1^=''));
	BY SUBJECTNUMBERSTR;
	IF LAST.SUBJECTNUMBERSTR;
	keep SUBJECTNUMBERSTR A_DOV;
RUN;
proc sql;
	 create table &out as
	 select a.*,b.A_DOV
	 from VS_1_1 as a left join VS_2 as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR;
quit;
%mend vs;
%vs(raw=R301,out=VS_301);
%vs(raw=R302,out=VS_302);
data FRMVS;
	length vnum $100 VISITMNEMONIC $400;
	set t_FRMVS VS_301 VS_302;
	format VISITMNEMONIC $200.;
	TEST=strip(put(_NAME_,$vs.));
	vnum='v_'||strip(put(VISITNUM*10,best.));
	if int(VISITNUM)^=VISITNUM then vnum=strip(vnum)||'_D';
	if index(VISITMNEMONIC,'UNS')>0 then VISITMNEMONIC='Unscheduled';
	VISITMNEMONIC=strip(VISITMNEMONIC)||'#'||strip(A_DOV);
	rename COL1=VSSTRESC A_DOV=B_DOV ITMVSDT_DTS=C_VSDT VISITMNEMONIC=A_VISITMNEMONIC;
run;
*----------------------- Last transpose----------------------------------->;
proc sort data=FRMVS out=s_VS_t; by SUBJECTNUMBERSTR test ; run;
proc transpose data=s_VS_t out=t_VS_t;
	by SUBJECTNUMBERSTR test; 
	id vnum;
	var  C_VSDT VSSTRESC A_VISITMNEMONIC;
run;
data t_VS_t1;
	set t_VS_t(rename=(_NAME_=__NAME));
	if __NAME^='VSSTRESC' then do;
		if __NAME='B_DOV' then test='Visit Date';
		else if __NAME='C_VSDT' then test='Date of Vital Signs';
	    else if __NAME='A_VISITMNEMONIC' then test='Label';
	end;
	if __NAME='VSSTRESC' then __n=input(test,VSN.);else __n=0;
run;
proc sort data=t_VS_t1 out=t_VS_t2 nodupkey; by SUBJECTNUMBERSTR  __NAME test; run;
proc sort data=t_VS_t2; by SUBJECTNUMBERSTR  __n __NAME ; run;
%adjustVisitVarOrder(indata=t_VS_t2,othvars=SUBJECTNUMBERSTR TEST);
data pdata.vsall(label='Vital Signs');
	set t_VS_t2;
run;
