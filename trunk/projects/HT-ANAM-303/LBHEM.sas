
%include '_setup.sas';

*<lbhem----------------------------------------------------------------------------------------;

*----------------------- 1.rawdata transpose------------------------------------->;
%getVNUM(indata=source.RD_FRMHEMA, out=RD_FRMHEMA);
%getVNUM(indata=source.RD_FRMHEMAUNS, out=RD_FRMHEMAUNS);
%macro lborres(orres=,unit=,unitoth=,cs=,nd=,low=,high=,stresc=);
	length &stresc $200 orres $20 unit $20 cs $10 low $20 high $20 ;
	call missing(orres, unit, cs, low, high);
	if &orres^=. then orres=strip(put(&orres,best.));
		else if &orres=. and &nd='NOT DONE' then orres='Not Done';
			else if &orres=. and &nd^='NOT DONE' then orres='.';
	if &unitoth^='' then unit=strip(&unitoth);
		else if &unitoth='' and &unit^='' then unit=strip(&unit);
			else if &unitoth='' and &unit='' then unit='.';
	if &cs='Y' or &cs='Yes' then cs='CS';else cs='.';
	if &low ^='' then low=strip(&low );else low='.';
	if &high ^='' then high=strip(&high);else high='.';
	&stresc=strip(orres)||'#'||strip(unit)||'#'||strip(cs)||'#'||strip(low)||'#'||strip(high);
%mend lborres;
%macro hem(a1=,a2=,a3=,a4=,a5=,a6=,a7=,a8=,a9=,a10=,a11=);
	%do i=1 %to 11;
	%lborres(orres=ITMHEMA&&a&i..RESULT,unit=ITMHEMA&&a&i..UNIT,unitoth=ITMHEMA&&a&i..UNITSPEC,cs=ITMHEMA&&a&i..CS_C,nd=ITMHEMA&&a&i.._C,low=ITMHEMA&&a&i..LOW,high=ITMHEMA&&a&i..HIGH,stresc=&&a&i);
	%end;
%mend hem;

data RD_FRMHEMAALL;
	set RD_FRMHEMA RD_FRMHEMAUNS;
	%informatDate(DOV);
	%formatDate(ITMHEMACOLLDT_DTS);
	%hem(a1=HGB,a2=HCT,a3=RBC,a4=WBC,a5=NEUT,a6=MON,a7=LYM,a8=BAS,a9=EOS,a10=PLT,a11=OTH1);
	if ITMHEMAOTH1SPEC^='' then OTH=strip(ITMHEMAOTH1SPEC)||'#'||strip(OTH1);
		else OTH=strip(OTH1);
	if ITMHEMALAB_C='Y' then HEMALAB=strip(ITMHEMALABNAME); 
		else if ITMHEMALAB_C='N' then HEMALAB='No';
	if ITMHEMACOLLTM_TMS^='' then LBDT=strip(ITMHEMACOLLDT_DTS)||substr(strip(ITMHEMACOLLTM_TMS),1,6);
		else LBDT=strip(ITMHEMACOLLDT_DTS);
run;
proc sort data=RD_FRMHEMAALL;
	by SITEMNEMONIC SUBJECTNUMBERSTR visitnum VISITMNEMONIC DOV A_DOV LBDT HEMALAB; 
run;
proc transpose data=RD_FRMHEMAALL out=t_FRMHEMA;
 	by SITEMNEMONIC SUBJECTNUMBERSTR visitnum VISITMNEMONIC DOV A_DOV LBDT HEMALAB; 
 	var HGB HCT RBC WBC NEUT MON LYM BAS EOS PLT OTH; 
run;

*----------------------- 2.Take sex and age from dm------------------------------------->;
%macro varscan(var=);
	if countc(&var, '#')=4 then do;
	lborres=ifc(scan(&var,1,'#')^='.',scan(&var,1,'#'),'');
	lbunit=ifc(scan(&var,2,'#')^='.',scan(&var,2,'#'),'');
	cs=ifc(scan(&var,3,'#')^='.',scan(&var,3,'#'),'');
	low_=ifc(scan(&var,4,'#')^='.',scan(&var,4,'#'),'');
	high_=ifc(scan(&var,5,'#')^='.',scan(&var,5,'#'),'');
	end;
	if countc(&var, '#')=5 then do;
	othtest=ifc(scan(&var,1,'#')^='.',scan(&var,1,'#'),'');
	lborres=ifc(scan(&var,2,'#')^='.',scan(&var,2,'#'),'');
	lbunit=ifc(scan(&var,3,'#')^='.',scan(&var,3,'#'),'');
	cs=ifc(scan(&var,4,'#')^='.',scan(&var,4,'#'),'');
	low_=ifc(scan(&var,5,'#')^='.',scan(&var,5,'#'),'');
	high_=ifc(scan(&var,6,'#')^='.',scan(&var,6,'#'),'');
	end;
%mend varscan;
data t_FRMHEMA_;
	set t_FRMHEMA;
	%varscan(var=COL1);
	rename _NAME_=lbtest;
run;

%macro lb(raw=,out=);
%getVNUM(indata=&raw..RD_FRMHEMA, out=RD_FRMHEMA1);
%getVNUM(indata=&raw..RD_FRMHEMAUNS, out=RD_FRMHEMAUNS1);

data RD_FRMHEMAALL1;
	set RD_FRMHEMA1 RD_FRMHEMAUNS1;
	%informatDate(DOV);
	if ITMHEMACOLLTM_TMS^='' then LBDTC=strip(ITMHEMACOLLDT_DTS)||substr(strip(ITMHEMACOLLTM_TMS),1,6);
	ELSE LBDTC=strip(ITMHEMACOLLDT_DTS);
	%formatDate(ITMHEMACOLLDT_DTS);
	%hem(a1=HGB,a2=HCT,a3=RBC,a4=WBC,a5=NEUT,a6=MON,a7=LYM,a8=BAS,a9=EOS,a10=PLT,a11=OTH1);
	if ITMHEMAOTH1SPEC^='' then OTH=strip(ITMHEMAOTH1SPEC)||'#'||strip(OTH1);
		else OTH=strip(OTH1);
/*	HEMALAB='';*/
	if ITMHEMALAB_C='Y' then HEMALAB=strip(ITMHEMALABNAME); 
		else if ITMHEMALAB_C='N' then HEMALAB='No';
	if ITMHEMACOLLTM_TMS^='' then LBDT=strip(ITMHEMACOLLDT_DTS)||substr(strip(ITMHEMACOLLTM_TMS),1,6);
		else LBDT=strip(ITMHEMACOLLDT_DTS);
run;
proc sort data=RD_FRMHEMAALL1;
	by SITEMNEMONIC SUBJECTNUMBERSTR VISITORDER visitnum VISITMNEMONIC LBDTC DOV A_DOV LBDT VISITIDX HEMALAB; 
run;
proc transpose data=RD_FRMHEMAALL1 out=t_FRMHEMA1;
 	by SITEMNEMONIC SUBJECTNUMBERSTR VISITORDER visitnum VISITMNEMONIC LBDTC DOV A_DOV LBDT VISITIDX HEMALAB; 
 	var HGB HCT RBC WBC NEUT MON LYM BAS EOS PLT OTH; 
run;
DATA t_FRMHEMA1_;
	SET t_FRMHEMA1;
	%varscan(var=COL1);
	visitnum=-2;
	visitmnemonic='Wk-1!{super [2]}';
	DROP cs ;
RUN;
proc sort data=t_FRMHEMA1_;
	by SUBJECTNUMBERSTR _NAME_ LBDTC VISITORDER VISITIDX; 
run;
proc sql;
	create table t_FRMHEMA1_1 as
	select *
	from t_FRMHEMA1_
	group by SUBJECTNUMBERSTR, _NAME_  
	having count(distinct lborres) =1 and lborres^='';
quit;

DATA LB1;
	SET t_FRMHEMA1_1;
	BY SUBJECTNUMBERSTR _NAME_;
	IF LAST._NAME_;
RUN;

proc sql;
	create table t_FRMHEMA1_2 as
	select *
	from t_FRMHEMA1_
	group by SUBJECTNUMBERSTR, _NAME_  
	having count(distinct lborres) >1 and lborres^='';
quit;

DATA LB2;
	SET t_FRMHEMA1_2(WHERE=(lborres^='Not Done'));
	BY SUBJECTNUMBERSTR _NAME_;
	IF LAST._NAME_;
RUN;
data LB_1;
	set LB1 LB2;
run;

proc sort data=t_FRMHEMA out=subject(keep=SUBJECTNUMBERSTR) nodupkey;by SUBJECTNUMBERSTR;run;
proc sql;
	create table LB_1_ AS
	select a.*
	from LB_1 as a inner join subject as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
	;
quit;
*-------- Get most lbdtc--------->;
proc sql;
	create table DTC as
	select *, count(lbdtc) as n
	from LB_1_
	group by SUBJECTNUMBERSTR, lbdtc
	;
quit;
proc sort data=DTC out=DTC1 nodupkey;by SUBJECTNUMBERSTR lbdtc n;run;
proc sort data=DTC1 ;by SUBJECTNUMBERSTR n;run;
data DTC2;
	set DTC1(rename=(HEMALAB=HEMALAB_));
	by SUBJECTNUMBERSTR;
	keep SUBJECTNUMBERSTR LBDT A_DOV HEMALAB_;
	if last.SUBJECTNUMBERSTR;
run;
data &out;
	length SUBJECTNUMBERSTR $20 LBDT $38 A_DOV $430 HEMALAB_ $200;
	if _n_=1 then do;
		declare hash h (dataset :'DTC2');
		rc=h.defineKey ('SUBJECTNUMBERSTR');
		rc=h.defineData ('LBDT','A_DOV','HEMALAB_');
		rc=h.defineDone ();
		call missing (SUBJECTNUMBERSTR,LBDT,A_DOV,HEMALAB_);
	end;
	set LB_1_(rename=(LBDT=LBDT_)drop=A_DOV);
	rc=h.find();
	if LBDT^=LBDT_ then LBDT_=LBDT_;else LBDT_='';
	if HEMALAB_^=HEMALAB then HEMALAB_=HEMALAB_;else HEMALAB_='';
	unit=upcase(lbunit);
	rename _NAME_=lbtest;
	drop rc VISITORDER LBDTC VISITIDX;
run;

%mend lb;
%lb(raw=R301,out=lb_301);
%lb(raw=R302,out=lb_302);

data hemlh_lb;
	set t_FRMHEMA_ lb_301 lb_302;
run;

data dm;
	set PDATA.dm06;
	if index(__AGE,'NA')=0 then AGE_=input(substr(__AGE,1,2),best.);
	keep SUBJECTNUMBERSTR AGE_ __SEX;
run;

data hem_dm;
	length SUBJECTNUMBERSTR $20 AGE_ 8 __SEX $3 lbname2 lbname $200;
	if _n_=1 then do;
		declare hash h (dataset:'dm');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('AGE_','__SEX');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, AGE_, __SEX);
	end;
	set hemlh_lb;
	lbname2=upcase(strip(prxchange('s/[\n\t]+/%/',-1,HEMALAB)));
	if index(lbname2,'%')>0 then do; 
	if index(lbname2,'ODDELENI KLINICKE BIOCHEMIE A HEMATOLOGIE')>0 then lbname='OKBH';
	else if index(lbname2,'LABORATORY OF LENINGRAD REGIONAL CLINICAL')>0 then lbname='LENINGRAD';

	else if index(lbname2,'BAZ MEGYEI KORHAZ ES EGYETEMI OKTATOKORHAZ, SZIKSZOI TELEPHELY, KOZPONTI LABORATORIUM')>0 then lbname='SQUALI CONT_JUDIT';
	else if index(lbname2,'CLINICAL BIOCHEMICAL LABORATORY OF SROC')>0 then lbname='SVERDLOVSK REGIONAL';
	else if index(lbname2,'JOSA ANDRAS OKTATOKORHAZ, KOZPONTI LABORATORIUM')>0 then lbname='JOSA ANDRAS';
	else if index(lbname2,'ST. PETERSBURG STATE MEDICAL UNIVERSITY')>0 then lbname='ST PETERSBURG_ORLOV';
	else lbname='';
	end;
	else if lbname2='QUEST DIAGNOSTICS' then do;
	if substr(SUBJECTNUMBERSTR,1,3)='036' then lbname='QUEST DIAGNOSTICS_UCAR';
	else if substr(SUBJECTNUMBERSTR,1,3)='003' then lbname='QUEST DIAGNOSTICS';
	end;
	else do;
	lbname=strip(put(lbname2, $libname.));
	end;
	if lborres^='' and lborres^='Not Done' and lbunit='' then lbunit='(no unit)';else lbunit=lbunit;
	unit=upcase(lbunit);
	rc=h.find();
	drop rc COL1;
run;

*----------------------- 3.Join witn lbrange------------------------------------->;
data lbrange;
	length TESTCD $8;
	set source.lbrange(where=(lbcat='Hematology'));
	if index(AGERANGE,'>=')>0 or index (AGERANGE,'>')>0 or index(AGERANGE,'<=')>0 or index (AGERANGE,'<')>0 
	  then SYMAGEL=strip(compress(AGERANGE,,'d'));
	if index(AGERANGE,">=")>0 then AGELOW=input(strip(compress(AGERANGE,">=")),best.);
	  else if index(AGERANGE,">")>0 then AGELOW=input(strip(compress(AGERANGE,">")),best.);
	if index(AGERANGE,"<=")>0 then AGEHIGH=input(strip(compress(AGERANGE,"<=")),best.);
	  else if index(AGERANGE,"<")>0 then AGEHIGH=input(strip(compress(AGERANGE,"<")),best.);
	if index(AGERANGE,"-")>0 then do;AGELOW=input(strip(scan(AGERANGE,1,"-")),best.);
		AGEHIGH=input(strip(scan(AGERANGE,2,"-")),best.);end;
	TESTCD=STRIP(put(lbtest,$hem.));
/******************  Modify LBRANGE ************************/
	if site='037' and SHTNAME='CLEVELAND' and lbtest='BASOPHILS' then UNITS='%';
	if site='009' and SHTNAME='QUINCY' and lbtest='MONOCYTES' then UNITS='%';
	if SHTNAME='ZOL GENK' and lbtest='HEMOGLOBIN' and AGERANGE='>65' then SYMAGEL=">=";
	if SHTNAME='ZOL GENK' and lbtest='HEMATOCRIT' and AGERANGE='>65' then SYMAGEL=">=";
	if SHTNAME='ZOL GENK' and lbtest='RED BLOOD CELLS' and AGERANGE='>65' then SYMAGEL=">=";
	UNITS=upcase(UNITS);
	if testcd^='' and cmiss(LOW,HIGH)^=2;
run;
proc sql;
	 create table LBHEM_R as
	 select a.*,b.LOW,b.HIGH
	 from (select * from hem_dm) as a
	    left join
	    (select * from lbrange) as b 
	 on a.SITEMNEMONIC = b.SITE and a.lbname = b.SHTNAME  and a.lbtest = b.TESTCD and a.unit = b.UNITS and (a.__sex=b.GENDER or b.GENDER='M/F') 
	    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow) 
		or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh)
	    or (b.agelow=. and b.agehigh=.) or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) 
			or (b.agelow=. and b.agehigh^=. and SYMAGEL='<' and a.AGE_<b.agehigh) )
	;
quit;
data hemlh;
	set LBHEM_R;
	if LOW_='' and LOW^='' then lblow=LOW;
	 else if LOW_^='' and LOW='' then lblow=LOW_;
	  else lblow='';
	if HIGH_='' and HIGH^='' then lbhigh=HIGH;
	 else if HIGH_^='' and HIGH='' then lbhigh=HIGH_;
	  else lbhigh='';
	%notInLowHigh(orres=lborres,low=lblow,high=lbhigh,stresc=lbstresc_);
	if index(lbhigh,'<')>0 then do;
	__high=input(compress(lbhigh,'<'),best.);
	__color='';
	if __orres>=__high then __color="&abovecolor";
	if __color>'' then lbstresc_='!{style [foreground='||strip(__color)||' fontweight=bold]'||strip(lborres)||'}';
	else lbstresc_=strip(lborres);
	end;
	if __color="&belowcolor" and __orres^=0 and __low/__orres>10 then do;fales='(?)';mul=__low/__orres;end;
		else if __color="&abovecolor" and __high^=0 and __orres/__high>10 then do;fales='(?)';mul=__orres/__high;end;
			else do;fales='';mul=.;end;
/*	keep SUBJECTNUMBERSTR AGE_ __SEX lbname	visitnum VISITMNEMONIC DOV A_DOV LBDT HEMALAB lbtest lborres lbunit cs othtest lblow lbhigh lbstresc_ fales mul;*/
run;

*----------------------- 4.Get most common unit----------------------------------->;

proc sql;
	create table hem_unit as
	select *, count(unit) as n
	from hemlh
	group by SUBJECTNUMBERSTR, lbtest, unit
	;
quit;
proc sort data=hem_unit out=hem_unit1 nodupkey;by SUBJECTNUMBERSTR lbtest unit n;run;
proc sort data=hem_unit1 ;by SUBJECTNUMBERSTR lbtest n;run;
data unit;
	set hem_unit1(rename=(lbunit=lbstresu));
	by SUBJECTNUMBERSTR lbtest;
	keep SUBJECTNUMBERSTR lbtest lbstresu;
	if last.lbtest;
run;
proc sql;
	 create table LBHEM1 as
	 select a.*,b.lbstresu
	 from (select * from hemlh) as a
	    left join
	    (select * from unit) as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR and a.lbtest = b.lbtest;
quit;
data LBHEM1_;
	length lbrange TEST A_VISITMNEMONIC $200;
	set LBHEM1(rename=(LBDT=C_LBDT HEMALAB=D_HEMALAB A_DOV=B_DOV VISITMNEMONIC=A_VISITMNEMONIC));
	label
		lbrange='Normal Range'
	;
	if lbstresu^='' and strip(lbstresu)^='(no unit)' then TEST=strip(put(lbtest,$hem.))||' <'||strip(lbstresu)||'>';
		else TEST=strip(put(lbtest,$hem.));
	if cmiss(lblow,lbhigh)=2 then lbrange='  -  ';
	else lbrange=strip(lblow)||' - '||strip(lbhigh);
	if D_HEMALAB='No' then do;
	if nmiss(__low,__high)=2  and cmiss(LOW_,HIGH_)=2 then lbrange='  -  ';
	else if nmiss(__low,__high)=2 and cmiss(LOW_,HIGH_)^=2 then lbrange=strip(LOW_)||' - '||strip(HIGH_);
	else if nmiss(__low,__high)^=2 then lbrange=strip(put(__low,best.))||' - '||strip(put(__high,best.));
	end;
	if lbname='' and D_HEMALAB='No' then lbname='No';
	else lbname=lbname;

	if lbunit=lbstresu and strip(lbstresu)^='(no unit)' then do;
		if cs='' then lbstresc1=strip(strip(COALESCEC(lbstresc_,lborres))||' '||strip(fales));
		else if cs^='' then lbstresc1=strip(strip(COALESCEC(lbstresc_,lborres))||' '||strip(fales)||' '||strip(cs));
	end;
	else if lbunit=lbstresu and strip(lbstresu)='(no unit)' then do;
		if cs='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit);
		else if cs^='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit)||' '||strip(cs);
	end;
	else if lbunit^=lbstresu then do;
		if cs='' then lbstresc1=strip(strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit)||strip(fales));
		else if cs^='' then lbstresc1=strip(strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit)||strip(fales)||' '||strip(cs));
	end;
	if othtest^='' then LBSTRESC=strip(othtest)||': '||strip(lbstresc1);else LBSTRESC=lbstresc1;
	if LBDT_^='' then LBSTRESC=strip(LBSTRESC)||' ('||strip(LBDT_)||')';
/*	keep SUBJECTNUMBERSTR visitnum A_VISITMNEMONIC DOV B_DOV C_LBDT D_HEMALAB TEST lbrange lbtest LBSTRESC fales mul lbname lbunit lbstresu __low __high lblow lbhigh;*/
run;

*----------------------- 5.Get Normal Range----------------------------------->;
proc sql;
 create table lb1 as
 select *, count(lbname) as n 
 from LBHEM1_ 
 group by SUBJECTNUMBERSTR,lbname
 ;
quit;
proc sql;
 create table lb1_ as
 select *
 from lb1
 group by SUBJECTNUMBERSTR
 having n= max(n);
 ;
quit;
proc sort data=lb1_ ; by SUBJECTNUMBERSTR lbtest lbname;run;
proc sort data=lb1_ out=lb2 nodupkey; by SUBJECTNUMBERSTR lbtest;run;
proc sql;
	 create table LB2_R as
	 select a.*,b.LOW,b.HIGH
	 from (select * from lb2(drop=LOW HIGH)) as a
	    left join
	    (select * from lbrange) as b 
	 on a.SITEMNEMONIC = b.SITE and a.lbname = b.SHTNAME  and a.lbtest = b.TESTCD and strip(upcase(a.lbstresu)) = strip(b.UNITS) and (a.__sex=b.GENDER or b.GENDER='M/F') 
	    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow) 
		or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh)
	    or (b.agelow=. and b.agehigh=.) or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) 
			or (b.agelow=. and b.agehigh^=. and SYMAGEL='<' and a.AGE_<b.agehigh) )
	;
quit;
data lbstrname;
	length lbrange_s $200;
	set LB2_R;
	if D_HEMALAB='No' then do;
	if nmiss(__low,__high)=2 and cmiss(LOW_,HIGH_)=2 then lbrange_s='  -  ';
	else if nmiss(__low,__high)=2 and cmiss(LOW_,HIGH_)^=2 then lbrange_s=strip(LOW_)||' - '||strip(HIGH_);
	else if nmiss(__low,__high)^=2 then lbrange_s=strip(put(__low,best.))||' - '||strip(put(__high,best.));
	end;
	else do;
	if cmiss(LOW,HIGH)=2 then lbrange_s='  -  ';
	else lbrange_s=strip(low)||' - '||strip(high);end;
	rename  lbname=lbname_s;
run;
proc sql;
	 create table LBHEM1_s as
	 select a.*,b.lbrange_s,b.lbname_s
	 from (select * from LBHEM1_) as a
	    left join
	    (select * from lbstrname) as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR and a.lbtest = b.lbtest;
quit;
data LBHEM1_s1;
	length vnum $100 A_VISITMNEMONIC $200;
	set LBHEM1_s;
	format A_VISITMNEMONIC $200.;
	if index(A_VISITMNEMONIC,'UNS')>0 then A_VISITMNEMONIC='Unscheduled';
	if lbname^=lbname_s and lbname^='' and HEMALAB_='' 
		then A_VISITMNEMONIC="!{style [url='#dset41' linkcolor=white foreground=blue textdecoration=underline]"||strip(A_VISITMNEMONIC)||'*}';
	if lbname^=lbname_s and lbname='' and D_HEMALAB='confirmed.' 
		then A_VISITMNEMONIC="!{style [url='#dset41' linkcolor=white foreground=blue textdecoration=underline]"||strip(A_VISITMNEMONIC)||'*}';
	if lbname^=lbname_s and lbname^='' and HEMALAB_^='' and strip(lbrange)^='-'
		then LBSTRESC="!{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(LBSTRESC)||' *}';
	if lbname=lbname_s and lbname^='' and HEMALAB_^='' and strip(lbrange)^='-'
		then LBSTRESC="!{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(LBSTRESC)||' *}';
	if lbname=lbname_s and lbrange^=lbrange_s and LBSTRESC^='Not Done' and LBSTRESC^='' and strip(__COLOR)^='green' 
		then LBSTRESC="!{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(LBSTRESC)||' *}';
	if lbname=lbname_s and lbrange=lbrange_s and LBSTRESC^='Not Done' and LBSTRESC^='' and lbunit^=lbstresu and strip(__COLOR)^='green'  
		then LBSTRESC="!{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(LBSTRESC)||' *}';
	vnum='v_'||strip(put(VISITNUM*10,best.));
	if int(VISITNUM)^=VISITNUM then vnum=strip(vnum)||'_D';
	A_VISITMNEMONIC=strip(A_VISITMNEMONIC)||'#'||strip(B_DOV);
run;
*------------------ 6.Appendix:Reference Range of Hematology----------------------->;
data lbhemidx;
	set LBHEM1_s(where=(D_HEMALAB^='' and LBSTRESC^='Not Done' and LBSTRESC^='' and strip(lbrange)^='-'));
	if lbname^=lbname_s then output;
	else if lbname=lbname_s and lbrange^=lbrange_s then output;
	else if lbname=lbname_s and lbrange=lbrange_s and lbunit^=lbstresu then output;
	else if lbname=lbname_s and lbrange=lbrange_s and HEMALAB_^='' then output;
run;
proc sort data=lbhemidx out=lbhemidx1 nodupkey; by SUBJECTNUMBERSTR lbtest D_HEMALAB lbrange lbunit A_VISITMNEMONIC;run;
data pdata.hemidx;
	length TEST1 LOW HIGH LBCAT LAB unit $200;
	set lbhemidx1(drop=LOW HIGH unit);
	label
		LBCAT='Category'
		TEST1='Item'
		LAB='Local Laboratory Used'
		LOW='Lower Limit'
		HIGH='Upper Limit'
		A_VISITMNEMONIC='Visit'
		unit='Unit'
	;
	LBCAT='Hematology';
	TEST1=strip(scan(TEST,1,'<'));
	unit=strip(lbunit);
	LOW=lblow;
	HIGH=lbhigh;
/*	if D_HEMALAB^='No' then do;LOW=lblow;HIGH=lbhigh;end;*/
/*	else do;*/
/*	LOW=strip(put(__low,best.));*/
/*	HIGH=strip(put(__high,best.));end;*/
	if D_HEMALAB='No' then LAB='CRF'; else LAB=D_HEMALAB;
	keep SUBJECTNUMBERSTR LBCAT TEST1 LAB LOW HIGH A_VISITMNEMONIC unit;
run;
*----------------------- 7.Last transpose----------------------------------->;
data LBHEM1_s2;
	set LBHEM1_s1;
	if HEMALAB_^='' then D_HEMALAB=HEMALAB_; else D_HEMALAB=D_HEMALAB;
run;
proc sort data=LBHEM1_s2 out=s_hem_t; by SUBJECTNUMBERSTR TEST lbtest lbrange_s ; run;
proc transpose data=s_hem_t out=t_hem_t;
	by SUBJECTNUMBERSTR TEST lbtest lbrange_s; 
	id Vnum;
	var C_LBDT D_HEMALAB LBSTRESC A_VISITMNEMONIC;
run;
data t_hem_t1;
	set t_hem_t(rename=(_NAME_=__NAME));
	label
		lbrange_s='Normal Range'
	;
	if strip(upcase(__NAME))^='LBSTRESC' then do;
		if __NAME='B_DOV' then TEST='Visit Date';
		else if __NAME='C_LBDT' then TEST='Date Collected';
		else if __NAME='D_HEMALAB' then TEST='Local Laboratory Used';
	    else if __NAME='A_VISITMNEMONIC' then TEST='Label';
	end;
	if strip(upcase(__NAME))^='LBSTRESC' then lbrange_s='';
	if strip(upcase(__NAME))='LBSTRESC' then __n=input(lbtest,HN.);else __n=0;
	drop lbtest;
run;
proc sort data=t_hem_t1 out=t_hem_t2 nodupkey; by SUBJECTNUMBERSTR  __NAME TEST; run;
proc sort data=t_hem_t2 ; by SUBJECTNUMBERSTR __n  __NAME; run;
%adjustVisitVarOrder(indata=t_hem_t2,othvars=SUBJECTNUMBERSTR TEST lbrange_s);

data pdata.lbhem(label='Hematology-Local');
	set t_hem_t2;
run;
