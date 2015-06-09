
%include '_setup.sas';

*<lbchem--------------------------------------------------------------------------------------------------------;

*----------------------- 1.rawdata transpose------------------------------------->;
%getVNUM(indata=source.RD_FRMCHEM, out=RD_FRMCHEM);
%getVNUM(indata=source.RD_FRMCHEMUNS, out=RD_FRMCHEMUNS);

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

%macro lbchem(a1=,a2=,a3=,a4=,a5=,a6=,a7=,a8=,a9=,a10=,a11=,a12=,a13=);
	%do i=1 %to 13;
	%lborres(orres=ITMCHEM&&a&i..RESULT,unit=ITMCHEM&&a&i..UNIT,unitoth=ITMCHEM&&a&i..UNITSPEC,
			cs=ITMCHEM&&a&i..CS_C,nd=ITMCHEM&&a&i.._C,low=ITMCHEM&&a&i..LOW,high=ITMCHEM&&a&i..HIGH,stresc=&&a&i);
	%end;
%mend lbchem;

data chem01;
	length SERPRE $200 SERPRE_ $200;
	set RD_FRMCHEM RD_FRMCHEMUNS;
	if ITMCHEMSERPRERESULTS ^='' then SERPRE_=ITMCHEMSERPRERESULTS;
	else if ITMCHEMSERPRE ^='' and ITMCHEMSERPREREASON ^='' then SERPRE_=strip(scan(ITMCHEMSERPRE,1,','))||', '||strip(ITMCHEMSERPREREASON);
	else SERPRE_=ITMCHEMSERPRE;
	if SERPRE_ ^='' then SERPRE=strip(SERPRE_)||'#'||' '||'#'||' '||'#'||' '||'#'||' ';


run;

data chem02;
	length LBDT $60 LABNAME $200;
	set chem01;
	%lbchem(a1=SOD,a2=POT,a3=CHL,a4=CAL,a5=TPRO,a6=ALB,a7=AST,a8=ALK,a9=ALT,a10=TBIL,a11=BUN,a12=CREA,a13=GLU);
/*	%adjustvalue(dsetlabel=Chemistry-Local);*/
	%formatDate(ITMCHEMCOLLDT_DTS);  %informatDate(DOV);
	if ITMCHEMCOLLTM_TMS ^='' then LBDT=strip(ITMCHEMCOLLDT_DTS)||strip(substr(ITMCHEMCOLLTM_TMS,1,6));
	else LBDT = ITMCHEMCOLLDT_DTS;
	if ITMCHEMLAB='Yes, <small>Normal Ranges  do not  need to be entered below, </small> Laboratory Name' 
		then LABNAME=strip(ITMCHEMLABNAME); 
	else if ITMCHEMLAB='No, <small>Normal Ranges  are required  to be entered below</small>' 
		then LABNAME='No';
	ELSE LABNAME='';
run;

proc sort data=chem02 out=s_chem02; by SUBJECTNUMBERSTR visitnum VISITMNEMONIC DOV A_DOV LBDT LABNAME SITEMNEMONIC ITMCHEMLAB_C; RUN;

proc transpose data=s_chem02 out=t_chem02;
	by  SUBJECTNUMBERSTR visitnum VISITMNEMONIC DOV A_DOV LBDT LABNAME SITEMNEMONIC ITMCHEMLAB_C;
	var SOD POT CHL CAL TPRO ALB AST ALK ALT TBIL BUN CREA GLU SERPRE;
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

data t_chem02_;
	set t_chem02;
	%varscan(var=COL1);
	rename _NAME_=chtest;
run;

%macro lb(raw=,out=);
%getVNUM(indata=&raw..RD_FRMCHEM, out=RD_FRMCHEM);
%getVNUM(indata=&raw..RD_FRMCHEMUNS, out=RD_FRMCHEMUNS);

data chemall1;
	length SERPRE $200 SERPRE_ $200;
	set RD_FRMCHEM RD_FRMCHEMUNS;
	if ITMCHEMSERPRERESULTS ^='' then SERPRE_=ITMCHEMSERPRERESULTS;
	else if ITMCHEMSERPRE ^='' and ITMCHEMSERPREREASON ^='' then SERPRE_=strip(scan(ITMCHEMSERPRE,1,','))||', '||strip(ITMCHEMSERPREREASON);
	else SERPRE_=ITMCHEMSERPRE;
	if SERPRE_ ^='' then SERPRE=strip(SERPRE_)||'#'||' '||'#'||' '||'#'||' '||'#'||' ';
run;
data chemall2;
	length LBDT $60 LABNAME $200;
	set chemall1;
	%informatDate(DOV);
	if ITMCHEMCOLLTM_TMS^='' then LBDTC=strip(ITMCHEMCOLLDT_DTS)||strip(substr(ITMCHEMCOLLTM_TMS,1,6));
	ELSE LBDTC=strip(ITMCHEMCOLLDT_DTS);
	%formatDate(ITMCHEMCOLLDT_DTS);  
	%lbchem(a1=SOD,a2=POT,a3=CHL,a4=CAL,a5=TPRO,a6=ALB,a7=AST,a8=ALK,a9=ALT,a10=TBIL,a11=BUN,a12=CREA,a13=GLU);
	if ITMCHEMCOLLTM_TMS ^='' then LBDT=strip(ITMCHEMCOLLDT_DTS)||strip(substr(ITMCHEMCOLLTM_TMS,1,6));
	else LBDT = ITMCHEMCOLLDT_DTS;
	if ITMCHEMLAB='Yes, <small>Normal Ranges  do not  need to be entered below, </small> Laboratory Name' 
		then LABNAME=strip(ITMCHEMLABNAME); 
	else if ITMCHEMLAB='No, <small>Normal Ranges  are required  to be entered below</small>' 
		then LABNAME='No';
	ELSE LABNAME='';
run;

proc sort data=chemall2 out=s_chemall2; by SUBJECTNUMBERSTR VISITORDER visitnum VISITMNEMONIC LBDTC DOV A_DOV LBDT VISITIDX LABNAME SITEMNEMONIC ITMCHEMLAB_C; RUN;

proc transpose data=s_chemall2 out=t_chemall2;
	by  SUBJECTNUMBERSTR VISITORDER visitnum VISITMNEMONIC LBDTC DOV A_DOV LBDT VISITIDX LABNAME SITEMNEMONIC ITMCHEMLAB_C;
	var SOD POT CHL CAL TPRO ALB AST ALK ALT TBIL BUN CREA GLU SERPRE;
run;

DATA t_CHEMA1_;
	SET t_chemall2;
	%varscan(var=COL1);
	visitnum=-2;
	visitmnemonic='Wk-1!{super [2]}';
	DROP cs ;
RUN;
proc sort data=t_CHEMA1_;
	by SUBJECTNUMBERSTR _NAME_ LBDTC VISITORDER VISITIDX; 
run;
proc sql;
	create table t_CHEMA1_1 as
	select *
	from t_CHEMA1_
	group by SUBJECTNUMBERSTR, _NAME_  
	having count(distinct lborres) =1 and lborres^='';
quit;

DATA LB1;
	SET t_CHEMA1_1;
	BY SUBJECTNUMBERSTR _NAME_;
	IF LAST._NAME_;
RUN;

proc sql;
	create table t_CHEMA1_2 as
	select *
	from t_CHEMA1_
	group by SUBJECTNUMBERSTR, _NAME_  
	having count(distinct lborres) >1 and lborres^='';
quit;

DATA LB2;
	SET t_CHEMA1_2(WHERE=(lborres^='Not Done'));
	BY SUBJECTNUMBERSTR _NAME_;
	IF LAST._NAME_;
RUN;
data LB_1;
	set LB1 LB2;
run;

proc sort data=t_chem02 out=subject(keep=SUBJECTNUMBERSTR) nodupkey;by SUBJECTNUMBERSTR;run;
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
	set DTC1(rename=(LABNAME=LABNAME_1));
	by SUBJECTNUMBERSTR;
	keep SUBJECTNUMBERSTR LBDT A_DOV LABNAME_1;
	if last.SUBJECTNUMBERSTR;
run;
data &out;
	length SUBJECTNUMBERSTR $20 LBDT $60 A_DOV $430 LABNAME_1 $200;
	if _n_=1 then do;
		declare hash h (dataset :'DTC2');
		rc=h.defineKey ('SUBJECTNUMBERSTR');
		rc=h.defineData ('LBDT','A_DOV','LABNAME_1');
		rc=h.defineDone ();
		call missing (SUBJECTNUMBERSTR,LBDT,A_DOV,LABNAME_1);
	end;
	set LB_1_(rename=(LBDT=LBDT_)drop=A_DOV);
	rc=h.find();
	if LBDT^=LBDT_ then LBDT_=LBDT_;else LBDT_='';
	if LABNAME_1^=LABNAME then LABNAME_1=LABNAME_1;else LABNAME_1='';
	lbunit_=upcase(lbunit);
	rename _NAME_=chtest;
	drop rc VISITORDER LBDTC VISITIDX;
run;

%mend lb;
%lb(raw=R301,out=lb_301);
%lb(raw=R302,out=lb_302);
data chemlh_lb;
	set t_chem02_ lb_301 lb_302;
run;

data dm;
	set PDATA.dm06;
	if index(__AGE,'NA')=0 then AGE_=input(substr(__AGE,1,2),best.);
	keep SUBJECTNUMBERSTR AGE_ __SEX;
run;

data lbchem_dm;
	length SUBJECTNUMBERSTR $20 AGE_ 8 __SEX $3 labname_ $200;
	if _n_=1 then do;
		declare hash h (dataset:'dm');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('AGE_','__SEX');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, AGE_, __SEX);
	end;
	set chemlh_lb;
	labname1=upcase(strip(prxchange('s/[\n\t]+/%/',-1,labname)));
	if index(labname1,'%')>0 then do; 
		if  index(labname1,'ODDELENI KLINICKE BIOCHEMIE A HEMATOLOGIE')>0 
			then labname_='OKBH';
		else if  index(labname1,'CLINICAL BIOCHEMICAL LABORATORY OF SROC')>0 
			then labname_='SVERDLOVSK REGIONAL';
		else if  index(labname1,'ODD. KLINICKE BIOCHEMIE, FAKULTNI NEMOCNICE')>0 
			then labname_='SEKK_SKRICKOVA';
		else if  index(labname1,'LABORATORY OF LENINGRAD REGIONAL CLINICAL')>0 
			then labname_='LENINGRAD';

		else if  index(labname1,'BAZ MEGYEI KORHAZ ES EGYETEMI OKTATOKORHAZ, SZIKSZOI TELEPHELY, KOZPONTI LABORATORIUM')>0 
			then labname_='SQUALI CONT_JUDIT';
		else if  index(labname1,'JOSA ANDRAS OKTATOKORHAZ, KOZPONTI LABORATORIUM')>0 
			then labname_='JOSA ANDRAS';
		else if  index(labname1,'ST. PETERSBURG STATE MEDICAL UNIVERSITY')>0 
			then labname_='ST PETERSBURG_ORLOV';
		else if  index(labname1,'HOSPITAL OF PIACENZA. ANALISYS ')>0 
			then labname_='PIACENZA';
		else if  index(labname1,'LABORATORY ANALISYS HOSPITAL')>0 
			then labname_='PIACENZA';
		else labname_='';
	end;
	else if labname1='QUEST DIAGNOSTICS' then do;
		if  substr(SUBJECTNUMBERSTR,1,3)='036' then labname_='QUEST DIAGNOSTICS_UCAR';
		else if  substr(SUBJECTNUMBERSTR,1,3)='003' then labname_='QUEST DIAGNOSTICS';
	end;
	else do;
		 LABNAME_=put(upcase(labname1),$libname.);
	end;
	rc=h.find();
	if lborres^='Not Done' and lborres^='NOT DONE' and index(lborres,'Not Applicable')=0 and lborres^='Negative' 
		and lborres^='' and lbunit='' then lbunit='(no unit)';else lbunit=lbunit;
	lbunit_=upcase(lbunit);
run;

*----------------------- 3.Join witn lbrange------------------------------------->;
data lbrange1;
	length TESTCD $8;
	set source.lbrange(where=(lbcat='Serum Chemistry'));
	if index(AGERANGE,'>=')>0 or index (AGERANGE,'>')>0 or index(AGERANGE,'<=')>0 or index (AGERANGE,'<')>0 
	  then SYMAGEL=strip(compress(AGERANGE,,'d'));
	if index(AGERANGE,">=")>0 then AGELOW=input(strip(compress(AGERANGE,">=")),best.);
	  else if index(AGERANGE,">")>0 then AGELOW=input(strip(compress(AGERANGE,">")),best.);
	if index(AGERANGE,"<=")>0 then AGEHIGH=input(strip(compress(AGERANGE,"<=")),best.);
	  else if index(AGERANGE,"<")>0 then AGEHIGH=input(strip(compress(AGERANGE,"<")),best.);
	if index(AGERANGE,"-")>0 then do;AGELOW=input(strip(scan(AGERANGE,1,"-")),best.);
		AGEHIGH=input(strip(scan(AGERANGE,2,"-")),best.);end;
	if index(AGERANGE,'more')>0 then SYMAGEL=">=";
	if index(AGERANGE,'more')>0 then AGELOW=input(strip(compress(AGERANGE,"or more")),best.);
	if index(AGERANGE,'>=')=0 and index(AGERANGE,'>')=0 and index(AGERANGE,'<=')=0 
	and index (AGERANGE,'<')=0 and index(AGERANGE,"-")=0 and index(AGERANGE,'more')=0
		then do; AGELOW=input(AGERANGE,best.); AGEHIGH=input(AGERANGE,best.); end;
	TESTCD=STRIP(put(lbtest,$chem.));
	UNITS=upcase(UNITS);
/******************  Modify LBRANGE ************************/
	IF site='026' AND testcd='BUN' AND SHTNAME='READING' AND AGERANGE='' AND GENDER='M/F' AND LOW='0.2' THEN testcd='';
	if lbtest='GLUD' THEN TESTCD='GLU';
	if SHTNAME='BIO-REFERENCE_VISVALINGAM' and lbtest='TSH' and AGERANGE='>21' then SYMAGEL=">=";
	if SHTNAME='CATALUNYA' and lbtest='GLUD' and AGERANGE='> 60' then SYMAGEL=">=";
	if SHTNAME='MATARO' and lbtest='GLUCOSE' and AGERANGE='> 60' then SYMAGEL=">=";
	if SHTNAME='ZNA' and lbtest='CALCIUM' and AGERANGE='>90' then SYMAGEL=">=";
	if SHTNAME='ZNA' and lbtest='AST' and AGERANGE='> 19' then SYMAGEL=">=";
	if SHTNAME='ZNA' and lbtest='ALKALINE PHOSPHATASE' and AGERANGE='> 20' then SYMAGEL=">=";

	if testcd^='' and (low^='' or high^='');
run;

proc sql;
 create table lb_range as
 select a.*,b.LOW,b.HIGH
 from (select * from lbchem_dm) as a
    left join
    (select * from  lbrange1) as b 
 on a.SITEMNEMONIC = b.SITE and a.LABNAME_ = b.SHTNAME and a.chtest=b.TESTCD and a.lbunit_=b.units and (a.__sex=b.GENDER or b.GENDER='M/F')  
    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow) 
	or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh)
	 or (b.agelow=. and b.agehigh=.) or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) 
		or (b.agelow=. and b.agehigh^=. and SYMAGEL='<' and a.AGE_<b.agehigh) )
	;
quit;


data chem04;
	set lb_range;
	test=put(chtest, $test.);
run;

data chemlh;
	set chem04;
	if strip(ITMCHEMLAB_C)="Y" then do;lblow=LOW;lbhigh=HIGH;end;
		else if strip(ITMCHEMLAB_C)="N" then do; lblow=LOW_;lbhigh=HIGH_; end;
		else do;lblow='';lbhigh=''; end;
	%notInLowHigh(orres=lborres,low=lblow,high=lbhigh,stresc=lbstresc_);
	if index(lbhigh,'<')>0 then do;
	__high=input(compress(lbhigh,'<'),best.);
	__color='';
	if __orres>=__high then __color="&abovecolor";
	if __color>'' then lbstresc_='!{style [foreground='||strip(__color)||' fontweight=bold]'||strip(lborres)||'}';
	else lbstresc_=strip(lborres);
	end;
run;

data chemlh_;
	length flag $10  m 8;
	set chemlh;
	if __low ^=. and __low ^=0 and __orres ^=. and __orres^=0 and __orres/__low <0.1 then do;flag="(?)"; m=__low/__orres;end;
	else if __high ^=. and __high ^=0 and __orres ^=. and __orres^=0 and __orres/__high >10 then do;flag="(?)"; m= __orres/__high;end;
run;

*----------------------- 4.Get most common unit----------------------------------->;
proc sql;
	create table chem_unit as
	select *, count(lbunit) as n
	from chemlh_
	group by SUBJECTNUMBERSTR, chtest, lbunit
	;
quit;

proc sort data=chem_unit out=chem_unit1 nodupkey; by SUBJECTNUMBERSTR chtest lbunit n;run;

proc sort data=chem_unit1; by SUBJECTNUMBERSTR chtest n;run;

data unit;
	set chem_unit1(rename=(lbunit=lbstresu));
	by SUBJECTNUMBERSTR chtest;
	keep SUBJECTNUMBERSTR chtest lbstresu;
	if last.chtest;
run;


proc sql;
	 create table LBCHEM1 as
	 select a.*,b.lbstresu
	 from (select * from chemlh_) as a
	    left join
	    (select * from unit) as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR and a.chtest = b.chtest;
quit;

data LBCHEM1_;
	length test $100 rangelh $200 A_VISITMNEMONIC $200;
	label rangelh='Normal Range';
	set LBCHEM1(rename=(VISITMNEMONIC=A_VISITMNEMONIC A_DOV=B_DOV LBDT=C_LBDT LABNAME=D_LABNAME));
	if lbstresu^='' and strip(lbstresu)^='(no unit)' then TEST=strip(put(chtest,$test.))||' <'||strip(lbstresu)||'>';
		else TEST=strip(put(chtest,$test.));
	if lbunit=lbstresu and strip(lbstresu)^='(no unit)' then do;
		if cs='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||strip(flag);
		else if cs^='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||strip(flag)||' '||strip(cs);
	end;
	else if lbunit=lbstresu and strip(lbstresu)='(no unit)' then do;
		if cs='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit);
		else if cs^='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit)||' '||strip(cs);
	end;
 	else if lbunit^=lbstresu then do;
  		if cs='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit)||strip(flag);
  		else if cs^='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit)||strip(flag)||' '||strip(cs);
 	end;
	if LBDT_^='' then lbstresc1=strip(lbstresc1)||' ('||strip(LBDT_)||')';

	if index(high,'<')>0 then do;
		high=compress(high,'<');
		low=''; end;

	if cmiss(lblow,lbhigh)=2 then rangelh='  -  ';
	else rangelh=strip(lblow)||' - '||strip(lbhigh);

	if D_LABNAME='No' then do;
	if nmiss(__low,__high)=2 and cmiss(LOW_,HIGH_)=2 then rangelh='  -  ';
	else if nmiss(__low,__high)=2 and cmiss(LOW_,HIGH_)^=2 then rangelh=strip(LOW_)||' - '||strip(HIGH_);
	else if nmiss(__low,__high)^=2 then rangelh=strip(put(__low,best.))||' - '||strip(put(__high,best.));
	end;

	if labname_='' and D_LABNAME='No' then labname_='No';
	else labname_=labname_;

run;


*----------------------- 5.Get Normal Range----------------------------------->;
proc sql;
 create table lbc1 as
 select *, count(labname_) as n 
 from LBCHEM1_ 
 group by SUBJECTNUMBERSTR,labname_
 ;
quit;
proc sql;
 create table lbc1_ as
 select *
 from lbc1
 group by SUBJECTNUMBERSTR
 having n= max(n);
 ;
quit;
proc sort data=lbc1_ ; by SUBJECTNUMBERSTR chtest labname_;run;
proc sort data=lbc1_ out=lbc2 nodupkey; by SUBJECTNUMBERSTR chtest;run;
proc sql;
 create table LBc2_R as
 select a.*,b.LOW,b.HIGH
 from (select * from lbc2(drop=LOW HIGH)) as a
    left join
    (select * from  lbrange1) as b 
 on a.SITEMNEMONIC = b.SITE and a.LABNAME_ = b.SHTNAME and a.chtest=b.TESTCD and strip(upcase(a.lbstresu))=strip(b.units) and (a.__sex=b.GENDER or b.GENDER='M/F')  
    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow) 
	or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh)
	 or (b.agelow=. and b.agehigh=.) or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) 
		or (b.agelow=. and b.agehigh^=. and SYMAGEL='<' and a.AGE_<b.agehigh) )
	;
quit;
data lbstrname1;
	length rangelh_s $200;
	set LBc2_R;
	if D_LABNAME='No' then do;
	if nmiss(__low,__high)=2 and cmiss(LOW_,HIGH_)=2 then rangelh_s='  -  ';
	else if nmiss(__low,__high)=2 and cmiss(LOW_,HIGH_)^=2 then rangelh_s=strip(LOW_)||' - '||strip(HIGH_);
	else if nmiss(__low,__high)^=2 then rangelh_s=strip(put(__low,best.))||' - '||strip(put(__high,best.));
	end;
	else do;
	if cmiss(LOW,HIGH)=2 then rangelh_s='  -  ';
	else rangelh_s=strip(low)||' - '||strip(high);end;
	rename labname_=labname_s;
run;

proc sql;
	 create table LBCHEM1_s as
	 select a.*,b.rangelh_s,b.labname_s
	 from (select * from LBCHEM1_) as a
	    left join
	    (select * from lbstrname1) as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR and a.chtest = b.chtest;
quit;
data LBCHEM1_s1;
	length vnum $100 A_VISITMNEMONIC $200;
	set LBCHEM1_s;
	format A_VISITMNEMONIC $200.;
	if index(A_VISITMNEMONIC,'UNS')>0 then A_VISITMNEMONIC='Unscheduled';
	if labname_^=labname_s and labname_^='' and LABNAME_1='' 
		then A_VISITMNEMONIC="!{style [url='#dset41' linkcolor=white foreground=blue textdecoration=underline]"||strip(A_VISITMNEMONIC)||'*}';
	/*if labname_^=labname_s and labname_='' and D_LABNAME='confirmed.' 
		then A_VISITMNEMONIC="!{style [url='#dset41' linkcolor=white foreground=blue textdecoration=underline]"||strip(A_VISITMNEMONIC)||'*}';*/
	if labname_^=labname_s and labname_^='' and LABNAME_1^='' and strip(rangelh)^='-'
		then lbstresc1="!{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(lbstresc1)||' *}';
	if labname_=labname_s and labname_^='' and LABNAME_1^='' and strip(rangelh)^='-'
		then lbstresc1="!{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(lbstresc1)||' *}';
	if labname_=labname_s and rangelh^=rangelh_s and lbstresc1^='Not Done' and lbstresc1^='' and strip(__COLOR)^='green' 
		then lbstresc1="!{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(lbstresc1)||' *}';
	if labname_=labname_s and rangelh=rangelh_s and lbstresc1^='Not Done' and lbstresc1^='' and lbunit^=lbstresu and strip(__COLOR)^='green' 
		then lbstresc1="!{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(lbstresc1)||' *}';

	vnum='v_'||strip(put(VISITNUM*10,best.));
	if int(VISITNUM)^=VISITNUM then vnum=strip(vnum)||'_D';
	A_VISITMNEMONIC=strip(A_VISITMNEMONIC)||'#'||strip(B_DOV);
run;

*------------------ 6.Appendix:Reference Range of Hematology----------------------->;
data lbchemidx;
	set LBCHEM1_s(where=(D_LABNAME^='' and LBSTRESC1^='Not Done' and lbstresc1^='' and strip(rangelh)^='-'));
	if labname_^=labname_s then output;
	else if labname_=labname_s and rangelh^=rangelh_s then output;
	else if labname_=labname_s and rangelh=rangelh_s  and lbunit^=lbstresu then output;
	else if labname_=labname_s and rangelh=rangelh_s  and LABNAME_1^='' then output;
run;
proc sort data=lbchemidx out=lbchemidx1 nodupkey; by SUBJECTNUMBERSTR chtest D_LABNAME rangelh lbunit A_VISITMNEMONIC;run;

data pdata.chemidx;
	length TEST1 LOW HIGH LBCAT LAB unit $200 ;
	set lbchemidx1(drop=LOW HIGH);
	label
		A_VISITMNEMONIC='Visit'
		LBCAT='Category'
		TEST1='Item'
		LAB='Local Laboratory Used'
		LOW='Lower Limit'
		HIGH='Upper Limit'
		unit='Unit'
	;
	LBCAT='Serum Chemistry';
	TEST1=strip(scan(TEST,1,'<'));
	unit=strip(lbunit);
	LOW=lblow;
	HIGH=lbhigh;
/*	if D_LABNAME^='No' then do;LOW=lblow;HIGH=lbhigh;end;*/
/*	else do;*/
/*	LOW=strip(put(__low,best.));*/
/*	HIGH=strip(put(__high,best.));end;*/
	if D_LABNAME='No' then lab='CRF'; else LAB=D_LABNAME;
	keep SUBJECTNUMBERSTR LBCAT TEST1 LAB LOW HIGH unit A_VISITMNEMONIC;
run;

*----------------------- 7.Last transpose----------------------------------->;
data LBCHEM1_S2;
	set LBCHEM1_S1;
	if LABNAME_1^='' then D_LABNAME=LABNAME_1; else D_LABNAME=D_LABNAME;
run;
proc sort data=LBCHEM1_S2 out=S_CHEM_T; by SUBJECTNUMBERSTR TEST chtest rangelh_s; run;

proc transpose data=S_CHEM_T out=T_CHEM_T;
	by SUBJECTNUMBERSTR test chtest rangelh_s; 
	id Vnum;
	var A_VISITMNEMONIC  C_LBDT D_LABNAME lbstresc1;
run;

data T_CHEM_T1;
	set T_CHEM_T(rename=(_NAME_=__NAME));
	label
		rangelh_s='Normal Range'
	;
	if __NAME^='lbstresc1' then do;
		if __NAME='B_DOV' then test='Visit Date';
		else if __NAME='C_LBDT' then test='Date Collected';
		else if __NAME='D_LABNAME' then test='Local Laboratory Used';
		else if __NAME='A_VISITMNEMONIC' then test='Label ';
	end;
	if UPCASE(__NAME)^='LBSTRESC1' then rangelh_S='';
	if UPCASE(__NAME)='LBSTRESC1' then __n=input(CHtest,NUM.);else __n=0;

	drop chtest;
run;

proc sort data=T_CHEM_T1 out=T_CHEM_T2 nodupkey; by SUBJECTNUMBERSTR  __NAME test; run;

proc sort data=T_CHEM_T2 ; by SUBJECTNUMBERSTR __n  __NAME; run;
%adjustVisitVarOrder(indata=t_chem_t2,othvars=SUBJECTNUMBERSTR TEST rangelh_s);
data pdata.lbchem(label='Chemistry-Local');
	set t_chem_t2;
run;
