%include '_setup.sas';

*<Demo----------------------------------------------------------------------------------------;
data dm0;
	set source.RD_FRMDM;
	%adjustvalue(dsetlabel=Demography);
	%informatDate(DOV);
	*-> Modify Variable Label;
	label 
		__SEX='Sex'
	;
	__SEX=strip(ITMDMGENDER_C);
	%ageint(RFSTDTC=ITMDMIFCDT_DTS, BRTHDTC=ITMDMDOB_DTS, Age=AGE);
run;

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
	%lborres(orres=ITMCHEM&&a&i..RESULT,unit=ITMCHEM&&a&i..UNIT,unitoth=ITMCHEM&&a&i..UNITSPEC,cs=ITMCHEM&&a&i..CS_C,
			nd=ITMCHEM&&a&i.._C,low=ITMCHEM&&a&i..LOW,high=ITMCHEM&&a&i..HIGH,stresc=&&a&i);
	%end;
%mend lbchem;


data chem01;
	length HBA1C $200 TSH $200 SERPRE $200 SERPRE_ $200;
	set RD_FRMCHEM RD_FRMCHEMUNS;
	ITMCHEMHBA1CRESULT_=ifc(ITMCHEMHBA1CRESULT=.,' ',put(ITMCHEMHBA1CRESULT,best.));
	if ITMCHEMHBA1CRESULT_ ^='' then ITMCHEMHBA1CRESULT_1=ITMCHEMHBA1CRESULT_;
	else if ITMCHEMHBA1CRESULT_='' and ITMCHEMHBA1C_C='NOT DONE' then ITMCHEMHBA1CRESULT_1='Not Done';
	else if ITMCHEMHBA1CRESULT_='' and ITMCHEMHBA1C_C='' then ITMCHEMHBA1CRESULT_1='.';

	if ITMCHEMHBA1CCS ='Yes'  then ITMCHEMHBA1CCS='CS'; 
		else ITMCHEMHBA1CCS='.';
	if ITMCHEMHBA1CLOW ^='' then ITMCHEMHBA1CLOW=ITMCHEMHBA1CLOW;
		else ITMCHEMHBA1CLOW='.';
	if ITMCHEMHBA1CHIGH ^='' then ITMCHEMHBA1CHIGH=ITMCHEMHBA1CHIGH;
		else ITMCHEMHBA1CHIGH='.';

	HBA1C=strip(ITMCHEMHBA1CRESULT_1)||'#'||strip(ITMCHEMHBA1CRESULT_U)||'#'||strip(ITMCHEMHBA1CCS)
	||'#'||strip(ITMCHEMHBA1CLOW)||'#'||strip(ITMCHEMHBA1CHIGH); 

	ITMCHEMTSHRESULT_=ifc(ITMCHEMTSHRESULT=.,' ',put(ITMCHEMTSHRESULT,best.));
	if ITMCHEMTSHRESULT_ ^='' then ITMCHEMTSHRESULT_=ITMCHEMTSHRESULT_;
	else if ITMCHEMTSHRESULT_='' and ITMCHEMTSH_C='NOT DONE' then ITMCHEMTSHRESULT_='Not Done';
	else if ITMCHEMTSHRESULT_='' and ITMCHEMTSH_C='' then ITMCHEMTSHRESULT_='.';

	if ITMCHEMTSHCS ='Yes'  then ITMCHEMTSHCS='CS'; 
		else ITMCHEMTSHCS='.';

	if ITMCHEMTSHUNIT ^='' then ITMCHEMTSHUNIT=ITMCHEMTSHUNIT;
		else ITMCHEMTSHUNIT='.';
	if ITMCHEMTSHLOW ^='' then ITMCHEMTSHLOW=ITMCHEMTSHLOW;
		else ITMCHEMTSHLOW='.';
	if ITMCHEMTSHHIGH ^='' then ITMCHEMTSHHIGH=ITMCHEMTSHHIGH;
		else ITMCHEMTSHHIGH='.';
	TSH=strip(ITMCHEMTSHRESULT_)||'#'||strip(ITMCHEMTSHUNIT)||'#'||strip(ITMCHEMTSHCS)||'#'
	||strip(ITMCHEMTSHLOW)||'#'||strip(ITMCHEMTSHHIGH); 

	if ITMCHEMSERPRERESULTS ^='' then SERPRE_=ITMCHEMSERPRERESULTS;
	else if ITMCHEMSERPRE ^='' and ITMCHEMSERPREREASON ^='' 
		then SERPRE_=strip(scan(ITMCHEMSERPRE,1,','))||', '||strip(ITMCHEMSERPREREASON);
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

proc sort data=chem02 out=s_chem02; by SUBJECTNUMBERSTR visitnum VISITMNEMONIC DOV A_DOV LBDT LABNAME SITEMNEMONIC; RUN;

proc transpose data=s_chem02 out=t_chem02;
	by  SUBJECTNUMBERSTR visitnum VISITMNEMONIC DOV A_DOV LBDT LABNAME SITEMNEMONIC ITMCHEMLAB_C;
	var SOD POT CHL CAL TPRO ALB AST ALK ALT TBIL BUN CREA GLU HBA1C TSH SERPRE;
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
	lborres_=ifc(scan(&var,2,'#')^='.',scan(&var,2,'#'),'');
	lbunit_=ifc(scan(&var,3,'#')^='.',scan(&var,3,'#'),'');
	cs=ifc(scan(&var,4,'#')^='.',scan(&var,4,'#'),'');
	low_=ifc(scan(&var,5,'#')^='.',scan(&var,5,'#'),'');
	high_=ifc(scan(&var,6,'#')^='.',scan(&var,6,'#'),'');
	end;
%mend varscan;

/*data chem03;*/
/*	set t_chem02;*/
/*	%varscan(var=COL1);*/
/*run;*/

data dm;
   set dm0;
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
	set t_chem02;
/*	labname1=upcase(strip(prxchange('s/[\n\t]+/%/',-1,labname)));
	if index(labname1,'%')>0 and index(labname1,'HOSPITAL OF PIACENZA. ANALISYS ')>0 
		then labname_='PIACENZA';
	else if index(labname1,'%')>0 and index(labname1,'LABORATORY ANALISYS HOSPITAL')>0 
		then labname_='PIACENZA';
	else if index(labname1,'%')>0 and index(labname1,'ODD. KLINICKE BIOCHEMIE, FAKULTNI NEMOCNICE')>0 
		then labname_='SEKK_SKRICKOVA';
	else LABNAME_=put(upcase(labname1),$labname.);*/

	*********** Modify: HX 20140612 *******************;
	labname1=upcase(strip(prxchange('s/[\n\t]+/%/',-1,labname)));
	if index(labname1,'%')>0 then do;
	if index(labname1,'HOSPITAL OF PIACENZA. ANALISYS ')>0 then labname_='PIACENZA';
	else if index(labname1,'LABORATORY ANALISYS HOSPITAL')>0 then labname_='PIACENZA';
	else if index(labname1,'ODD. KLINICKE BIOCHEMIE, FAKULTNI NEMOCNICE')>0 then labname_='SEKK_SKRICKOVA';
	else if index(labname1, 'BREST')>0 then  labname_='BREST';
	else if index(labname1, 'CLINICAL DIAGNOSTIC LABORATORY OF STATE')>0 then  labname_='ALEXANDROV';
	else if index(labname1,'BIOMEDICA')>0 then  labname_='BIOMEDICA';
	else if index(labname1,'DNIPROPETROVSK')>0 then  labname_='DNIPROPETROVSK';
	else if index(labname1,'ZAPORIZH')>0 then  labname_='ZAPORIZHLA';
	else if index(labname1,'HELP')>0 then  labname_='HELP';
	else if index(labname1,'KYIV')>0 then  labname_='KYIV';
	else if index(labname1,'MINSK')>0 then  labname_='MINSK';
	else labname_='';
	end;
	else if labname1='JEWISH HOSPITAL &ST MARY''S HEALTHCARE 200 ABRAHAM FLEXNER WAY LOUISVILLE KY 40202' then do; 
		labname_='JEWISH & STMARY' ;end;
	else do; 
	labname_=strip(put(strip(upcase(labname1)), $labname.));
end;

	rc=h.find();
	%varscan(var=COL1);
	if lborres^='Not Done' and lborres^='NOT DONE' and index(lborres,'Not Applicable')=0 and lborres^='Negative' 
		and lborres^='' and lbunit='' then lbunit='(no unit)';else lbunit=lbunit;
	rename _NAME_=chtest;
	lbunit_=upcase(lbunit);
run;
*********** Modify: HX 20140612 *******************;
data lbconvf;
	length testcd $20;
	set source.lbconvf(where=(lbcat='CHEMISTRY' and LBTESTCD in('ALB','ALP',	'ALT',	'AST',	'BILI','BUN','CA','CL','CREAT',	'GLUC','HBA1C','K','PROT',	'SODIUM','TSH')));
	if LBTESTCD='ALP' then testcd='ALK';
		else if LBTESTCD='BILI' then testcd='TBIL';
		else if LBTESTCD='CA'  then testcd='CAL';
		else if LBTESTCD='CL' then testcd='CHL';
		else if LBTESTCD='CREAT' then testcd='CREA';
		else if LBTESTCD='GLUC' then testcd='GLU';
		else if LBTESTCD='K' then testcd='POT';
		else if LBTESTCD='PROT' then testcd='TPRO';
		else if LBTESTCD='SODIUM' then testcd='SOD';
		else testcd=LBTESTCD;
	LBORRESU=upcase(LBORRESU);
run;
proc sort data=lbconvf nodupkey;by TESTCD LBORRESU;run;
proc sql;
	 create table chem_cf as
	 select a.*,b. CONV as conv_1, b. LBSTRESU as LBSTRESU_1
	 from (select * from lbchem_dm) as a
	    left join
	    (select * from lbconvf) as b 
	 on  a.chtest = b.testcd  and a.lbunit_ = b.LBORRESU;
quit;

*----------------------- 3.Join witn lbrange------------------------------------->;
data lbrange1;
	length TESTCD $8;
	set source.lbrange(where=(upcase(lbcat)='SERUM CHEMISTRY'));
	if AGERANGE ^='' then do;
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
	end;
	TESTCD=STRIP(put(lbtest,$chem.));
	UNITS=upcase(UNITS);
/*	IF site='026' AND testcd='BUN' AND SHTNAME='READING' AND AGERANGE='' AND GENDER='M/F' AND LOW='0.2' THEN testcd='';*/
	if testcd^='' and (low^='' or high^='');
run;

*********** Modify: HX 20140612 *******************;
proc sql;
	 create table lbrange_cf as
	 select a.*,b. CONV as conv_2, b. LBSTRESU as LBSTRESU_2
	 from (select * from lbrange1) as a
	    left join
	    (select * from lbconvf) as b 
	 on  a.TESTCD = b.testcd  and a.UNITS = b.LBORRESU;
quit;
/*
proc sql;
 create table lb_range as
 select a.*,b.LOW,b.HIGH,b.units
 from (select * from lbchem_dm) as a
    left join
    (select * from  lbrange1) as b 
 on a.SITEMNEMONIC = b.SITE and a.LABNAME_ = b.SHTNAME and a.chtest=b.TESTCD and a.lbunit_=b.units and (a.__sex=b.GENDER or b.GENDER='M/F')  
    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow)
		or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh) or (b.agelow=. and b.agehigh=.) 
		or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) 
		or (b.agelow=. and b.agehigh^=. and SYMAGEL='<' and a.AGE_<b.agehigh) )
	;
quit;*/
proc sql;
 create table lb_range as
 select a.*,b.LOW,b.HIGH,b.units
 from (select * from chem_cf) as a
    left join
    (select * from  lbrange_cf) as b 
 on a.SITEMNEMONIC = b.SITE and a.LABNAME_ = b.SHTNAME and a.chtest=b.TESTCD and a.LBSTRESU_1 = b.LBSTRESU_2 and a.conv_1=b.conv_2 and (a.__sex=b.GENDER or b.GENDER='M/F')  
    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow)
		or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh) or (b.agelow=. and b.agehigh=.) 
		or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) 
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
	if __color>'' then lbstresc_='^{style [foreground='||strip(__color)||' fontweight=bold]'||strip(lborres)||'}';
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
	from lbchem_dm
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
	set LBCHEM1(rename=(VISITMNEMONIC=A_VISITMNEMONIC A_DOV=B_DOV LBDT=C_LBDT LABNAME=D_LABNAME));
	if lbstresu^='' and strip(lbstresu)^='(no unit)' then TEST=strip(put(chtest,$test.))||' <'||strip(lbstresu)||'>';
		else TEST=strip(put(chtest,$test.));

	if cmiss(lblow,lbhigh)=2 then rangelh='  -  ';
	else rangelh=strip(lblow)||' - '||strip(lbhigh);
	if D_LABNAME='No' then do;
	if nmiss(__low,__high)=2 and cmiss(LOW_,HIGH_)=2 then rangelh='  -  ';
	else if nmiss(__low,__high)=2 and cmiss(LOW_,HIGH_)^=2 then rangelh=strip(LOW_)||' - '||strip(HIGH_);
	else if nmiss(__low,__high)^=2 then rangelh=strip(put(__low,best.))||' - '||strip(put(__high,best.));
	end;

	if labname_='' and D_LABNAME='No' then labname_='No';
	else labname_=labname_;

	if lbunit=lbstresu and strip(lbstresu)^='(no unit)' then do;
  		if cs='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres));
  		else if cs^='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||' '||strip(cs);
 	end;
	else if lbunit=lbstresu and strip(lbstresu)='(no unit)' then do;
		if cs='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit);
		else if cs^='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit)||' '||strip(cs);
	end;
 	else if lbunit^=lbstresu then do;
  		if cs='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit);
  		else if cs^='' then lbstresc1=strip(COALESCEC(lbstresc_,lborres))||' '||strip(lbunit)||' '||strip(cs);
 	end;
run;

*----------------------- 5.Get Normal Range----------------------------------->;
*********** Modify: HX 20140619 *******************;
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
data lbc1__ t3;
	set lbc1_;
	if lbunit=LBSTRESU or (lbunit^=LBSTRESU and lborres='Not Done') then output lbc1__;
	else if (lbunit^=LBSTRESU and lborres^='Not Done') then output t3;
run;
*********** Modify: HX 20140612 *******************;
proc sort data=lbc1__ ; by SUBJECTNUMBERSTR chtest labname_ DESCENDING lbunit;run;
proc sort data=lbc1__ out=lbc2 nodupkey; by SUBJECTNUMBERSTR chtest;run;
/*proc sql;
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
quit;*/
*********** Modify: HX 20140612 *******************;
proc sql;
 create table LBc2_R as
 select a.*,b.LOW,b.HIGH
 from (select * from lbc2(drop=LOW HIGH)) as a
    left join
    (select * from  lbrange_cf) as b 
 on a.SITEMNEMONIC = b.SITE and a.LABNAME_ = b.SHTNAME and a.chtest=b.TESTCD and a.LBSTRESU_1 = b.LBSTRESU_2 and a.conv_1=b.conv_2 and (a.__sex=b.GENDER or b.GENDER='M/F')  
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

*********** Modify: HX 20140619 *******************;
proc sql;
 create table t1 as
 select *, count(A_VISITMNEMONIC) as n_ 
 from LBCHEM1_s 
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
data LBCHEM1_s1;
	length vnum $100 A_VISITMNEMONIC $200 D_LABNAME_ $400;
	set t2;
	format A_VISITMNEMONIC $200.;
	if index(A_VISITMNEMONIC,'UNS')>0 then A_VISITMNEMONIC='Unscheduled';
	if lborres='Not Done' and n_=m_ then vflag='Y';
	if labname_^=labname_s and labname_^='' and vflag='' then A_VISITMNEMONIC="^{style [url='#dset41' linkcolor=white foreground=blue textdecoration=underline]"||strip(A_VISITMNEMONIC)||'*}';;
	if labname_=labname_s and rangelh^=rangelh_s and lbstresc1^='Not Done' and lbstresc1^='' and strip(__COLOR)^='green' 
		then lbstresc1="^{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(lbstresc1)||' *}';
	if labname_=labname_s and rangelh=rangelh_s and lbstresc1^='Not Done' and lbstresc1^='' and lbunit^=lbstresu and strip(__COLOR)^='green' 
		then lbstresc1="^{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(lbstresc1)||' *}';

	vnum='v_'||strip(put(VISITNUM*10,best.));
	if int(VISITNUM)^=VISITNUM then vnum=strip(vnum)||'_D';
	A_VISITMNEMONIC=strip(A_VISITMNEMONIC)||'#'||strip(B_DOV);

	***********************;
    %wrapword(instr=D_LABNAME, outstr=D_LABNAME_, MAXCHAR=15, odsEscapeChar=^);
	************************;
run;
*------------------ 6.Appendix:Reference Range of Hematology----------------------->;
data lbchemidx;
	set LBCHEM1_s(where=(D_LABNAME^='' and LBSTRESC1^='Not Done' and lbstresc1^='' and strip(rangelh)^='-'));
	if labname_^=labname_s then output;
	if labname_=labname_s and rangelh^=rangelh_s then output;
	if labname_=labname_s and rangelh=rangelh_s  and lbunit^=lbstresu then output;
run;
proc sort data=lbchemidx out=lbchemidx1 nodupkey; by SUBJECTNUMBERSTR chtest D_LABNAME rangelh lbunit A_VISITMNEMONIC;run;

data pdata.chemidx;
	length TEST1 LOW HIGH LBCAT LAB unit A_VISITMNEMONIC $200 ;
	set lbchemidx1(drop=LOW HIGH rename=A_VISITMNEMONIC=A_VISITMNEMONIC_);
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
	A_VISITMNEMONIC=strip(A_VISITMNEMONIC_);
	if index(A_VISITMNEMONIC,'UNS')>0 then A_VISITMNEMONIC="Unscheduled^{newline 1}("||strip(B_DOV)||')';
	keep SUBJECTNUMBERSTR LBCAT TEST1 LAB LOW HIGH unit A_VISITMNEMONIC;
run;

*----------------------- 7.Last transpose----------------------------------->;
proc sort data=LBCHEM1_S1 out=S_CHEM_T; by SUBJECTNUMBERSTR TEST chtest rangelh_s; run;

proc transpose data=S_CHEM_T out=T_CHEM_T;
	by SUBJECTNUMBERSTR test chtest rangelh_s; 
	id Vnum;
	var A_VISITMNEMONIC  C_LBDT D_LABNAME_ lbstresc1;
run;

data T_CHEM_T1;
	set T_CHEM_T(rename=(_NAME_=__NAME));
	label
		rangelh_s='Normal Range'
	;
	if __NAME^='lbstresc1' then do;
		if __NAME='B_DOV' then test='Visit Date';
		else if __NAME='C_LBDT' then test='Date Collected';
		else if __NAME='D_LABNAME_' then test='Local Laboratory Used';
		else if __NAME='A_VISITMNEMONIC' then test='Label ';
	end;
	if UPCASE(__NAME)^='LBSTRESC1' then rangelh_S='';
	if UPCASE(__NAME)='LBSTRESC1' then __n=input(CHtest,NUM.);else __n=0;

	drop chtest;
run;

proc sort data=T_CHEM_T1 out=T_CHEM_T2 nodupkey; by SUBJECTNUMBERSTR  __NAME test; run;

proc sort data=T_CHEM_T2 ; by SUBJECTNUMBERSTR __n  __NAME; run;
%adjustVisitVarOrder(indata=t_chem_t2,othvars=SUBJECTNUMBERSTR TEST rangelh_s __n  __NAME);

data t_chem_t2;
	set t_chem_t2;
		by SUBJECTNUMBERSTR;
	array vst{*} V_:;
	if last.SUBJECTNUMBERSTR then do i = 1 to dim(vst);
		if length(vst[i]) < 40 and vst[i]^='' then 
			vst[i]=substr(vst[i],1,39)||"&escapechar{style [foreground=white]x}";
		else if length(vst[i]) < 40 and vst[i]='' then 
			vst[i]="&escapechar{style [foreground=white]x}"||substr(vst[i],2,39)||"&escapechar{style [foreground=white]x}";
	end;

	drop i;
run;


data pdata.lbchem(label='Chemistry-Local');
	set t_chem_t2;
run;

*******************************************;
data _null_;
	set sashelp.vcolumn ;
	where libname = 'PDATA'  and memname = 'LBCHEM' and index(upcase(name), 'V_'); ;
	length _allvst_ $1024;
	retain _allvst_;
	if _n_ = 1 then call missing(_allvst_);
	_allvst_ = strip(_allvst_)||' '||name;
	call symput('allvisit', strip(_allvst_));
	call symput('nvisit', strip(put(_n_,best.)));
run;

%put &allvisit;
%put &nvisit;


data lbchem2;
	set pdata.lbchem;
		by subjectnumberstr;
	length __v_1 - __v_&nvisit $255 j 8 __flag_1 - __flag_&nvisit 8;
	array v1{*} v_:;
	array v2{*} __v_:;
	array flag{*} __flag_:;
	j = 0; 
	retain __flag_1 - __flag_&nvisit;
	drop __flag_:;
	do i = 1 to dim(v1);
		/* decide whether the visit cotnains no data */
		if first.subjectnumberstr and v1[i] > '  ' then flag[i] = 1;
		/*
			set flag = 1 if you want to keep "NOT DONE" regular visit.
			set falg = 0 if you want to drop all 'NOT DONE' visit.
		*/
		else if first.subjectnumberstr and index(upcase(vname(v1[i])), 'D') = 0 then flag[i] = 1;
		else if first.subjectnumberstr then flag[i] = 0;
		/* copy value from old visit varaible to new visit variable */
		if flag[i] = 1 then do;
			j = j +1;
			v2[j] = v1[i]; 
		end;
	end;
	drop v_: i ;
run;

proc sql noprint;
	select strip(put(max(j),best.))
	into: maxvisit 
	from lbchem2;
quit;

%put &maxvisit;

data lbchem3;
	set lbchem2;
	length v_1 - v_&maxvisit $255;
	array v1{*} v_:;
	array v2{*} __v_:;
	/* rename and drop null variables */
	do i = 1 to &maxvisit;
		v1[i] = v2[i];
	end;
	drop __v_: i j; 
run;

data lbchem_p1_;
	set lbchem3;
	drop v_9-v_15;
run;
proc sql;
	create table lbchem_p1_1 as
	select *, count(SUBJECTNUMBERSTR) as n
	from lbchem_p1_
	group by SUBJECTNUMBERSTR
	;
quit;
proc sql;
	create table test2 as
	select *, count(SUBJECTNUMBERSTR) as m
	from lbchem_p1_(where=(v_1=''))
	group by SUBJECTNUMBERSTR
	;
quit;
proc sort data=test2 nodupkey;by SUBJECTNUMBERSTR;run;

proc sql;
	 create table lbchem_p1__ as
	 select a.*,b.m
	 from (select * from lbchem_p1_1) as a
	    left join
	    (select * from test2) as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR ;
quit;

proc sort data=lbchem_p1__ ; by SUBJECTNUMBERSTR __n  __NAME; run;

data pdata.LBCHEM_P1(label='Chemistry-Local');
	set lbchem_p1__;
	if m^=. and n=m then delete;
	drop __n __NAME m n;
run;


data lbchem_p2_;
	set lbchem3;
	drop v_1-v_8;
run;
proc sql;
	create table lbchem_p2_1 as
	select *, count(SUBJECTNUMBERSTR) as n
	from lbchem_p2_
	group by SUBJECTNUMBERSTR
	;
quit;
proc sql;
	create table test3 as
	select *, count(SUBJECTNUMBERSTR) as m
	from lbchem_p2_(where=(v_9=''))
	group by SUBJECTNUMBERSTR
	;
quit;
proc sort data=test3 nodupkey;by SUBJECTNUMBERSTR;run;

proc sql;
	 create table lbchem_p2__ as
	 select a.*,b.m
	 from (select * from lbchem_p2_1) as a
	    left join
	    (select * from test3) as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR ;
quit;

proc sort data=lbchem_p2__ ; by SUBJECTNUMBERSTR __n  __NAME; run;


data pdata.LBCHEM_P2(label='Chemistry-Local(Continued)');
	set lbchem_p2__;
	if m^=. and n=m then delete;
	drop __n __NAME m n;
run;

*----------------------------------------------------------------------------------------------------------->;
