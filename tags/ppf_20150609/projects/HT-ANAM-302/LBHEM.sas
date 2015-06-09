
%include '_setup.sas';

*<lbhem----------------------------------------------------------------------------------------;
data dm0;
	length RACE $100;
	set source.rd_frmdm;
	%adjustvalue(dsetlabel=Demography);
	%informatDate(DOV);
	*-> Modify Variable Label;
	label 
		ITMDMIFCDT_DTS = 'Date Informed#Consent Signed'
		ITMDMDOB_DTS = 'Date of Birth'
		ITMDMGENDER='Gender'
		ITMDMETHNIC='Ethnicity'
		A_DOV='Visit Date'
		RACEOTH = 'Race Other,#Specify'
		RACE='Race'
		SITECOUNTRY='Country'
		ITMDMSTATUS='Current Status'
		INVNAM='Investigator Name'
		ITMUPWRKFLW_CITMUPWRKFLW='Update workflow for subject?'
		__SEX='Sex'
		__SUBJECT='SUBJECT'
	;
	__SEX=strip(ITMDMGENDER_C);
	%ageint(RFSTDTC=ITMDMIFCDT_DTS, BRTHDTC=ITMDMDOB_DTS, Age=AGE);
	__SUBJECT=SUBJECTNUMBERSTR;
	INVNAM=substr( SITENAME , 7);
	RACEOTH =ITMDMRACEOTHSPC;
	ITMDMRACEOTHSPC_C=propcase(ITMDMRACE_ITMDMRACEOTHSPC_C);
	RACE=catx(', ',ITMDMRACE_CITMRACEAMIND,ITMDMRACE_CITMRACEASIAN,ITMDMRACE_CITMRACEBLACK,ITMDMRACE_CITMRACEHAWPAC,ITMDMRACE_CITMRACEWHITE,ITMDMRACEOTHSPC_C);
run;
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

data dm;
   set dm0;
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
	set t_FRMHEMA;
	lbname2=upcase(strip(prxchange('s/[\n\t]+/%/',-1,HEMALAB)));
	if index(lbname2,'%')>0 then do; 
	if index(lbname2,'BAZ MEGYEI KORHAZ ES EGYETEMI OKTATOKORHAZ, SZIKSZOI TELEPHELY, KOZPONTI LABORATORIUM')>0 then lbname='SQUALI CONT_JUDIT';
	else if index(lbname2,'BAZ MEGYEI ONKORMANYZAT KORHAZA ES EGYETEMI OKTATOKORHAZ, SZIKSZOI TELEPHELY, KOZPONTI LABORATORIUM')>0 then lbname='SQUALI CONT_JUDIT';
	else if index(lbname2,'CLINICAL BIOCHEMICAL LABORATORY OF SROC')>0 then lbname='SVERDLOVSK REGIONAL';
	else if index(lbname2,'JOSA ANDRAS OKTATOKORHAZ, KOZPONTI LABORATORIUM')>0 then lbname='JOSA ANDRAS';
	else if index(lbname2,'LABORATORY OF LENINGRAD REGIONAL CLINICAL')>0 then lbname='LENINGRAD';
	else if index(lbname2,'ST. PETERSBURG STATE MEDICAL UNIVERSITY')>0 then lbname='ST PETERSBURG_ORLOV';
	else if index(lbname2,'SYNLAB SZEKESFEHERVARI LABORATORIUMA 8001')>0 then lbname='SYNLAB';
	end;
	else do;
	lbname=strip(put(lbname2, $libname.));
	end;
	%varscan(var=COL1);
	if lborres^='' and lborres^='Not Done' and lbunit='' then lbunit='(no unit)';else lbunit=lbunit;
	unit=upcase(lbunit);
	rc=h.find();
	rename _NAME_=lbtest;
	drop  rc COL1;
run;
*********** Modify: HX 20140616 *******************;
data lbconvf;
	length testcd $20;
	set source.lbconvf(where=(lbcat='HEMATOLOGY' and LBTESTCD in('BASO','BASOLE','EOS','EOSLE','HCT','HGB','LYM','LYMLE','MONO','MONOLE','NEUT','NEUTLE','PLAT','RBC','WBC')));
	if LBTESTCD in('BASO','BASOLE') then testcd='BAS';
		else if LBTESTCD='EOSLE' then testcd='EOS';
		else if LBTESTCD='LYMLE'  then testcd='LYM';
		else if LBTESTCD='NEUTLE' then testcd='NEUT';
		else if LBTESTCD in('MONO','MONOLE') then testcd='MON';
		else if LBTESTCD='PLAT' then testcd='PLT';
		else testcd=LBTESTCD;
	LBORRESU=upcase(LBORRESU);
	if LBTESTCD in('LYM','MONO','NEUT') and LBORRESU='RATIO' then delete;
run;
proc sort data=lbconvf nodupkey;by TESTCD LBORRESU;run;
proc sql;
	 create table hem_cf as
	 select a.*,b. CONV as conv_1, b. LBSTRESU as LBSTRESU_1
	 from (select * from hem_dm) as a
	    left join
	    (select * from lbconvf) as b 
	 on  a.lbtest = b.testcd  and a.unit = b.LBORRESU;
quit;
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
	UNITS=upcase(UNITS);
	if testcd^='' and cmiss(LOW,HIGH)^=2;
run;
*********** Modify: HX 20140616 *******************;
proc sql;
	 create table lbrange_cf as
	 select a.*,b. CONV as conv_2, b. LBSTRESU as LBSTRESU_2
	 from (select * from lbrange) as a
	    left join
	    (select * from lbconvf) as b 
	 on  a.TESTCD = b.testcd  and a.UNITS = b.LBORRESU;
quit;
/*
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
quit;*/

proc sql;
	 create table LBHEM_R as
	 select a.*,b.LOW,b.HIGH
	 from (select * from hem_cf) as a
	    left join
	    (select * from lbrange_cf) as b 
	 on a.SITEMNEMONIC = b.SITE and a.lbname = b.SHTNAME  and a.lbtest = b.TESTCD and a.LBSTRESU_1 = b.LBSTRESU_2 and a.conv_1=b.conv_2 and (a.__sex=b.GENDER or b.GENDER='M/F') 
	    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow) 
			  or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh) or (b.agelow=. and b.agehigh=.) 
			  or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) or (b.agelow=. and b.agehigh^=. and SYMAGEL='<' and a.AGE_<b.agehigh))
	;
quit;

data hem_oth;
	set hem_cf(where=(OTHTEST^=''));
run;

proc sql;
	 create table LBHEM_oth as
	 select a.*,b.LOW,b.HIGH
	 from (select * from hem_oth) as a
	    left join
	    (select * from lbrange) as b 
	 on a.SITEMNEMONIC = b.SITE and a.lbname = b.SHTNAME  and upcase(a.OTHTEST) = upcase(b.LBTEST) 
		and a.UNIT = b.UNITS and (a.__sex=b.GENDER or b.GENDER='M/F') 
	    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow) 
			  or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh) or (b.agelow=. and b.agehigh=.) 
			  or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) or (b.agelow=. and b.agehigh^=. and SYMAGEL='<' and a.AGE_<b.agehigh))
	;
quit;

data LBHEM_oth_;
	length othtest_o $200;
	set LBHEM_oth;
	othtest_o=strip(OTHTEST);
	if OTHTEST in('metamyelocyte','Metamyelocytes','metamyelocytes') then OTHTEST='metamyelocytes';
	if index(OTHTEST,'Eo,')>0 then OTHTEST='Eo, Bazo, Mono';
	if OTHTEST='Immature Granulocytes' then OTHTEST='Immature granulocytes';
	if OTHTEST='Myelocyten' then OTHTEST='Myelocytes';
run;

data hemlh;
	length lbtestall $100;
	set LBHEM_R(where=(OTHTEST='')) LBHEM_oth_;/* Modify: HX 20140612 */
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
	if __color>'' then lbstresc_='^{style [foreground='||strip(__color)||' fontweight=bold]'||strip(lborres)||'}';
	else lbstresc_=strip(lborres);
	end;
	if __color="&belowcolor" and __orres^=0 and __low/__orres>10 then do;fales='(?)';mul=__low/__orres;end;
		else if __color="&abovecolor" and __high^=0 and __orres/__high>10 then do;fales='(?)';mul=__orres/__high;end;
			else do;fales='';mul=.;end;

	/* Modify: HX 20140616 */
	if OTHTEST^='' then lbtestall=strip(lbtest)||'-'||strip(OTHTEST);
	else lbtestall=strip(lbtest);

/*	keep SUBJECTNUMBERSTR AGE_ __SEX lbname	visitnum VISITMNEMONIC DOV A_DOV LBDT HEMALAB lbtest lborres lbunit cs othtest lblow lbhigh lbstresc_ fales mul;*/
run;

*----------------------- 4.Get most common unit----------------------------------->;

proc sql;
	create table hem_unit as
	select *, count(unit) as n
	from hemlh/* Modify: HX 20140618 */
	group by SUBJECTNUMBERSTR, lbtestall, unit/* Modify: HX 20140618 */
	;
quit;
proc sort data=hem_unit out=hem_unit1 nodupkey;by SUBJECTNUMBERSTR lbtestall unit n;run;/* Modify: HX 20140618 */
proc sort data=hem_unit1 ;by SUBJECTNUMBERSTR lbtestall n;run;/* Modify: HX 20140618 */
data unit;
	set hem_unit1(rename=(lbunit=lbstresu));
	by SUBJECTNUMBERSTR lbtestall;/* Modify: HX 20140618 */
	keep SUBJECTNUMBERSTR lbtestall lbstresu;/* Modify: HX 20140618 */
	if last.lbtestall;/* Modify: HX 20140618 */
run;
proc sql;
	 create table LBHEM1 as
	 select a.*,b.lbstresu
	 from (select * from hemlh) as a
	    left join
	    (select * from unit) as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR and a.lbtestall = b.lbtestall;/* Modify: HX 20140618 */
quit;
data LBHEM1_;
	length lbrange TEST A_VISITMNEMONIC $200;
	set LBHEM1(rename=(LBDT=C_LBDT HEMALAB=D_HEMALAB A_DOV=B_DOV VISITMNEMONIC=A_VISITMNEMONIC));
	label
		lbrange='Normal Range'
	;
	/* Modify: HX 20140618 */
	if othtest='' then do;
		if lbstresu^='' and strip(lbstresu)^='(no unit)' then TEST=strip(put(lbtest,$hem.))||' <'||strip(lbstresu)||'>';
			else TEST=strip(put(lbtest,$hem.));
	end;
	else do;
		if lbstresu^='' and strip(lbstresu)^='(no unit)' then TEST='Other cell type: '||strip(othtest)||' <'||strip(lbstresu)||'>';
		  else  TEST='Other cell type: '||strip(othtest);
	end;

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
/*	if othtest^='' then LBSTRESC=strip(othtest)||': '||strip(lbstresc1);else LBSTRESC=lbstresc1;*/ /* Modify: HX 20140618 */
	LBSTRESC=lbstresc1;/* Modify: HX 20140618 */
/*	keep SUBJECTNUMBERSTR visitnum A_VISITMNEMONIC DOV B_DOV C_LBDT D_HEMALAB TEST lbrange lbtest LBSTRESC fales mul lbname lbunit lbstresu __low __high lblow lbhigh;*/
run;
*----------------------- 5.Get Normal Range----------------------------------->;
*********** Modify: HX 20140619 *******************;
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
data lb1__ t3;
	set lb1_;
	if lbunit=LBSTRESU or (lbunit^=LBSTRESU and lborres='Not Done') then output lb1__;
	else if (lbunit^=LBSTRESU and lborres^='Not Done') then output t3;
run;
proc sort data=lb1__ ; by SUBJECTNUMBERSTR LBTESTALL lbname DESCENDING lbunit;run;/* Modify: HX 20140618 */
proc sort data=lb1__ out=lb2 nodupkey; by SUBJECTNUMBERSTR LBTESTALL;run;
/*proc sql;
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
quit;*/

*********** Modify: HX 20140618 *******************;
proc sql;
	 create table LB2_R1 as
	 select a.*,b.LOW,b.HIGH
	 from (select * from lb2(where=(OTHTEST='') drop=LOW HIGH)) as a
	    left join
	    (select * from lbrange_cf) as b 
	 on a.SITEMNEMONIC = b.SITE and a.lbname = b.SHTNAME  and a.lbtest = b.TESTCD and  a.LBSTRESU_1 = b.LBSTRESU_2 and a.conv_1=b.conv_2 and (a.__sex=b.GENDER or b.GENDER='M/F') 
	    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow) 
		or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh)
	    or (b.agelow=. and b.agehigh=.) or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) 
			or (b.agelow=. and b.agehigh^=. and SYMAGEL='<' and a.AGE_<b.agehigh) )
	;
quit;
proc sql;
	 create table LB2_R2 as
	 select a.*,b.LOW,b.HIGH
	 from (select * from lb2(where=(OTHTEST^='') drop=LOW HIGH)) as a
	    left join
	    (select * from lbrange) as b 
	 on a.SITEMNEMONIC = b.SITE and a.lbname = b.SHTNAME  and upcase(a.othtest_o) = upcase(b.LBTEST) 
		and a.UNIT = b.UNITS and (a.__sex=b.GENDER or b.GENDER='M/F') 
	    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow) 
			  or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh) or (b.agelow=. and b.agehigh=.) 
			  or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) or (b.agelow=. and b.agehigh^=. and SYMAGEL='<' and a.AGE_<b.agehigh))
	;
quit;
data lbstrname;
	length lbrange_s $200;
	set LB2_R1 LB2_R2;/* Modify: HX 20140612 */
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
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR and a.LBTESTALL = b.LBTESTALL;/* Modify: HX 20140618 */
quit;

*********** Modify: HX 20140619 *******************;
proc sql;
 create table t1 as
 select *, count(A_VISITMNEMONIC) as n_ 
 from LBHEM1_s 
 group by SUBJECTNUMBERSTR,A_VISITMNEMONIC
 ;
quit;
proc sql;
 create table t2 as
 select *, count(lborres) as m_ 
 from t1 
 group by SUBJECTNUMBERSTR,A_VISITMNEMONIC,lborres
 ;
quit;
data LBHEM1_s1;
	length vnum $100 A_VISITMNEMONIC $200 D_HEMALAB_ $400;
	set t2;
	format A_VISITMNEMONIC $200.;
	if index(A_VISITMNEMONIC,'UNS')>0 then A_VISITMNEMONIC='Unscheduled';
	if lborres='Not Done' and n_=m_ then vflag='Y';
	if lbname^=lbname_s and lbname^='' and vflag='' 
		then A_VISITMNEMONIC="^{style [url='#dset41' linkcolor=white foreground=blue textdecoration=underline]"||strip(A_VISITMNEMONIC)||'*}';
	if lbname=lbname_s and lbrange^=lbrange_s and LBSTRESC^='Not Done' and LBSTRESC^='' and strip(__COLOR)^='green' 
		then LBSTRESC="^{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(LBSTRESC)||' *}';
	if lbname=lbname_s and lbrange=lbrange_s and LBSTRESC^='Not Done' and LBSTRESC^='' and lbunit^=lbstresu and strip(__COLOR)^='green' 
		then LBSTRESC="^{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(LBSTRESC)||' *}';
	vnum='v_'||strip(put(VISITNUM*10,best.));
	if int(VISITNUM)^=VISITNUM then vnum=strip(vnum)||'_D';
	A_VISITMNEMONIC=strip(A_VISITMNEMONIC)||'#'||strip(B_DOV);

	***********************;
    %wrapword(instr=D_HEMALAB, outstr=D_HEMALAB_, MAXCHAR=15, odsEscapeChar=^);
	************************;

run;
*------------------ 6.Appendix:Reference Range of Hematology----------------------->;
data lbhemidx;
	set LBHEM1_s(where=(D_HEMALAB^='' and LBSTRESC^='Not Done' and LBSTRESC^='' and strip(lbrange)^='-'));
	if lbname^=lbname_s then output;
	if lbname=lbname_s and lbrange^=lbrange_s then output;
	if lbname=lbname_s and lbrange=lbrange_s and lbunit^=lbstresu then output;
run;
proc sort data=lbhemidx out=lbhemidx1 nodupkey; 
by SUBJECTNUMBERSTR lbtest D_HEMALAB lbrange lbunit A_VISITMNEMONIC;run;
data pdata.hemidx;
	length TEST1 LOW HIGH LBCAT LAB unit A_VISITMNEMONIC $200;
	set lbhemidx1(drop=LOW HIGH unit rename=A_VISITMNEMONIC=A_VISITMNEMONIC_);
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
	A_VISITMNEMONIC=strip(A_VISITMNEMONIC_);
	if index(A_VISITMNEMONIC,'UNS')>0 then A_VISITMNEMONIC="Unscheduled^{newline 1}("||strip(B_DOV)||')';
	keep SUBJECTNUMBERSTR LBCAT TEST1 LAB LOW HIGH A_VISITMNEMONIC unit;
run;
*----------------------- 7.Last transpose----------------------------------->;
proc sort data=LBHEM1_s1 out=s_hem_t; by SUBJECTNUMBERSTR TEST lbtest lbrange_s ; run;
proc transpose data=s_hem_t out=t_hem_t;
	by SUBJECTNUMBERSTR TEST lbtest lbrange_s; 
	id Vnum;
	var C_LBDT D_HEMALAB_ LBSTRESC A_VISITMNEMONIC;
run;
data t_hem_t1;
	set t_hem_t(rename=(_NAME_=__NAME));
	label
		lbrange_s='Normal Range'
	;
	if strip(upcase(__NAME))^='LBSTRESC' then do;
		if __NAME='B_DOV' then TEST='Visit Date';
		else if __NAME='C_LBDT' then TEST='Date Collected';
		else if __NAME='D_HEMALAB_' then TEST='Local Laboratory Used';
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

