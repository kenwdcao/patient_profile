%include '_setup.sas';

*<lbchem25--------------------------------------------------------------------------------------------------------;
%getVNUM(indata=source.RD_FRMCHEM_SCTCHEMOTH_ACTIVE, out=RD_FRMCHEM_SCTCHEMOTH_ACTIVE);
%getVNUM(indata=source.RD_FRMCHEMUNS_SCTCHEMO_ACTIVE, out=RD_FRMCHEMUNS_SCTCHEMO_ACTIVE);

*<chemoth--------------------------------------------------------------------------;
data chemoth01;
	length ITMCHEMOTHUNIT $50;
	set RD_FRMCHEM_SCTCHEMOTH_ACTIVE(rename=(ITMCHEMOTHUNIT=ITMCHEMOTHUNIT_)) RD_FRMCHEMUNS_SCTCHEMO_ACTIVE(rename=(ITMCHEMOTHUNIT=ITMCHEMOTHUNIT_));
	%adjustvalue1(dsetlabel=Chemistry-Local:Other Chemistry Test);
	%informatDate(DOV);
	attrib	
	ITMCHEMOTHRESULT_			label='Results'
	ITMCHEMOTHSPECTEST          label='Specify test'
	ITMCHEMOTHUNIT				label='Units'
	A_DOV						label='Visit Date'
	;


	ITMCHEMOTHRESULT_=ifc(ITMCHEMOTHRESULT=.,'',put(ITMCHEMOTHRESULT,best.));
	if ITMCHEMOTHUNITSPEC ^='' then ITMCHEMOTHUNIT=strip(ITMCHEMOTHUNITSPEC);
	else ITMCHEMOTHUNIT=strip(ITMCHEMOTHUNIT_);

	if ITMCHEMOTHSPECTEST ^='';

	drop subjectid siteid studyversionid subjectvisitid subjectvisitrev visitid visitindex formid
		formrev formindex itemsetid itemsetindex itmchemothunitoth_c itmchemothunit_c itmchemothunitoth
		sctchemoth_nd subjectinitials formfirstdate formlastdate formmnemonic sitename
		sitecountry itemsetidx deleteditem formcommentid formcommenttext ;
run;

*<DM---------------------------------------------------------------------------;
data dm;
	set source.RD_FRMDM;
	__SEX=strip(ITMDMGENDER_C);
	%ageint(RFSTDTC=ITMDMIFCDT_DTS, BRTHDTC=ITMDMDOB_DTS, Age=AGE);
   keep SUBJECTNUMBERSTR AGE_ __SEX;
run;
*----------------------- 1.Take sex and age from dm------------------------------------->;
proc sql;
	create table chemoth_dm as
	select a.*,b.__sex,b.age_
	from chemoth01 as a left join dm as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR 
	;
quit;

*----------------------- 2.join with CHEM------------------------------------->;
proc sort data=source.rd_frmchem out=S_chem nodupkey;by _all_;run;

proc sort data=source.rd_frmchemuns out=S_chemuns nodupkey;	by _all_;run;

data chem;
	set S_chem S_chemuns;
run;

proc sql;
	create table chemoth_labname as
	select a.*,b.labname,b.itmchemlab_c
	from chemoth_dm as a left join chem(rename=(ITMCHEMLABNAME=labname)) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and a.IN_VISITMNEMONIC=b.VISITMNEMONIC and a.dov=b.dov
	;
quit;

*----------------------- 2.1 deal with lab name------------------------------------->;
data labname01;
	length labname_ $200 othunit othtest $60;
	set chemoth_labname;
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

	othunit=strip(upcase(ITMCHEMOTHUNIT));
	othtest=strip(upcase(ITMCHEMOTHSPECTEST));

	*************************;
	if upcase(strip(othunit))='UNITLESS' then othunit='';
	if othtest='GFR' and sitemnemonic='301' and labname_='SAINT LUC' and othunit='ML/MIN/1.73M^2' then othunit='ML/MIN/1.73^2';
	if othtest='LDH' and sitemnemonic='301' and labname_='SAINT LUC' and othunit='IU/L' then othunit='UI/L';
	if othtest='GAMMA GT' and sitemnemonic='301' and labname_='SAINT LUC' and othunit='IU/L' then othunit='UI/L';
	if othtest='IRON' and sitemnemonic='303' and labname_='ZNA' and othunit='UG/DL' then othunit='µG/DL';
	if othtest='FOLIC ACID' and sitemnemonic='303' and labname_='ZNA' and othunit='UG/L' then othunit='µG/L';
run;

*----------------------- 3.Join witn lbrange------------------------------------->;
data lbrange01;
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

	units=upcase(units);
	lbtest=strip(upcase(lbtest));
	if lbtest^='' and (low^='' or high^='');

	***************************;
	if upcase(strip(units))='UNITLESS' then units='';

	if lbtest='BIOCARBONATE' then lbtest='BICARBONATE';
	if lbtest='ANTI-THROGLOBULINE ANTIBODIES' then lbtest='ANTI-THYROGLOBULINE ANITBODIES';
run;

proc sql;
 create table lb_range as
 select a.*,b.LOW,b.HIGH,b.units
 from labname01 as a left join lbrange01 as b 
 on a.SITEMNEMONIC = b.SITE and a.LABNAME_ = b.SHTNAME and a.othtest=b.lbtest and a.othunit = b.units and (a.__sex=b.GENDER or b.GENDER='M/F')  
    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow)
		or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh) or (b.agelow=. and b.agehigh=.) 
		or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) 
		or (b.agelow=. and b.agehigh^=. and SYMAGEL='<' and a.AGE_<b.agehigh) )
	;
quit;

data chemothlh;
	length lblow lbhigh lborres $20;
	set lb_range;
	if strip(ITMCHEMLAB_C)="Y" then do;lblow=LOW;lbhigh=HIGH;end;
		else if strip(ITMCHEMLAB_C)="N" then do; lblow=ITMCHEMOTHLOW;lbhigh=ITMCHEMOTHHIGH; end;
	if ITMCHEMOTHRESULT^=. then lborres=strip(put(ITMCHEMOTHRESULT,best.));

	if index(lbhigh,">")>0 then lbhigh=strip(compress(lbhigh,">"));

	%notInLowHigh(orres=lborres,low=lblow,high=lbhigh,stresc=lbstresc);
run;
data chemothlh_;
	length flag $10  m 8;
	set chemothlh;
	if __low ^=. and __low ^=0 and __orres ^=. and __orres^=0 and __orres/__low <0.1 then do;flag="(?)"; m=__low/__orres;end;
	else if __high ^=. and __high ^=0 and __orres ^=. and __orres^=0 and __orres/__high >10 then do;flag="(?)"; m= __orres/__high;end;
run;

*----------------------- 4.Get most common unit----------------------------------->;
proc sql;
	create table unit as
	select *, count(ITMCHEMOTHUNIT) as n
	from chemoth01
	group by SUBJECTNUMBERSTR, ITMCHEMOTHSPECTEST, ITMCHEMOTHUNIT
	;
quit;

proc sort data=unit out=unit1 nodupkey; by SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST ITMCHEMOTHUNIT n;run;

proc sort data=unit1; by SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST n;run;

data unit_;
	set unit1(rename=(ITMCHEMOTHUNIT=lbstresu));
	by SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST;
	keep SUBJECTNUMBERSTR ITMCHEMOTHSPECTEST lbstresu;
	if last.ITMCHEMOTHSPECTEST;
run;

proc sql;
	 create table chemothlh_1 as
	 select a.*,b.lbstresu
	 from (select * from chemothlh_) as a
	    left join
	    (select * from unit_) as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR and a.ITMCHEMOTHSPECTEST = b.ITMCHEMOTHSPECTEST;
quit;

data chemothlh_2;
	length testoth resultoth rangelh $200 lbstresu_upcase othunit_upcase $60;
	set chemothlh_1;

	if labname_='' and labname='No' then labname_='No';

	****************************;
	if SUBJECTNUMBERSTR in('150-102','150-106','302-103','302-104','402-102','402-103','402-105','506-101','600-101','600-105','600-108','600-110','855-102',
'855-104','855-109','855-111','855-112','950-104','953-103','953-106','953-108') and upcase(ITMCHEMOTHSPECTEST)='UREA' then ITMCHEMOTHSPECTEST='Urea';
		else if SUBJECTNUMBERSTR='303-103' and upcase(ITMCHEMOTHSPECTEST)='GGT' then ITMCHEMOTHSPECTEST='GGT';
		else if SUBJECTNUMBERSTR='303-103' and upcase(ITMCHEMOTHSPECTEST)='CRP' then ITMCHEMOTHSPECTEST='CRP';
		else if SUBJECTNUMBERSTR='303-103' and strip(upcase(ITMCHEMOTHSPECTEST)) in('ANION GAP','ANION-GAP') then ITMCHEMOTHSPECTEST='anion gap';
		else if SUBJECTNUMBERSTR='303-103' and upcase(ITMCHEMOTHSPECTEST) in('BICARBONATE') then ITMCHEMOTHSPECTEST='Bicarbonate';
		else if SUBJECTNUMBERSTR='303-103' and upcase(ITMCHEMOTHSPECTEST) in('URIC ACID') then ITMCHEMOTHSPECTEST='uric acid';
		else if SUBJECTNUMBERSTR='404-101' and upcase(ITMCHEMOTHSPECTEST) in('CRP') then ITMCHEMOTHSPECTEST='CRP';
		else if SUBJECTNUMBERSTR='356-101' and upcase(ITMCHEMOTHSPECTEST) in('HBA1C') then ITMCHEMOTHSPECTEST='HbA1c';


	if ITMCHEMOTHSPECTEST='anion gap' and ITMCHEMOTHUNIT='meq/L' then LBSTRESU='meq/l';
	****************************;

	if lbstresu^='' then testoth=strip(ITMCHEMOTHSPECTEST)||' <'||strip(lbstresu)||'>';
		else testoth=strip(ITMCHEMOTHSPECTEST);
	if upcase(ITMCHEMOTHUNIT)=upcase(lbstresu) then resultoth=strip(coalescec(lbstresc,lborres)); 	
	 	else if upcase(ITMCHEMOTHUNIT)^=upcase(lbstresu) then resultoth=strip(coalescec(lbstresc,lborres))||' '||strip(ITMCHEMOTHUNIT);
	if cmiss(lblow,lbhigh)=2 then rangelh='  -  ';
		else rangelh=strip(lblow)||' - '||strip(lbhigh);

**************test:lbstresu_upcase^=othunit_upcase*****************;
	lbstresu_upcase=strip(upcase(lbstresu));
	othunit_upcase=strip(upcase(ITMCHEMOTHUNIT));
run;

*----------------------- 5.Get most Normal Range----------------------------------->;
proc sql;
	 create table normal01 as
	 select *, count(labname_) as n 
	 from chemothlh_2 
	 group by SUBJECTNUMBERSTR,labname_
 ;
quit;
proc sql;
	 create table normal02 as
	 select *
	 from normal01
	 group by SUBJECTNUMBERSTR
	 having n= max(n);
	 ;
quit;

proc sort data=normal02 ; by SUBJECTNUMBERSTR othtest labname_ DESCENDING OTHUNIT;run;

proc sort data=normal02 out=s_normal02 nodupkey; by SUBJECTNUMBERSTR OTHTEST;run;

proc sql;
 create table normal03 as
 select a.*,b.LOW,b.HIGH
 from (select * from s_normal02(drop=LOW HIGH)) as a
    left join
    (select * from  lbrange01) as b 
 on a.SITEMNEMONIC = b.SITE and a.LABNAME_ = b.SHTNAME and a.othtest=b.lbtest and a.othunit = b.units and (a.__sex=b.GENDER or b.GENDER='M/F')  
    and ((b.agelow^=. and b.agehigh=. and SYMAGEL='>=' and a.AGE_>=b.agelow) or ((b.agelow^=. and b.agehigh=. and SYMAGEL='>' and a.AGE_>b.agelow)
		or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.AGE_<=b.agehigh) or (b.agelow=. and b.agehigh=.) 
		or (b.agelow=. and b.agehigh^=. and SYMAGEL='<=' and a.AGE_<=b.agehigh) ) 
		or (b.agelow=. and b.agehigh^=. and SYMAGEL='<' and a.AGE_<b.agehigh) )
	;
quit;

data normal04;
	length rangelh_s $200;
	set normal03;

	if strip(ITMCHEMLAB_C)="Y" then do;lblow=LOW;lbhigh=HIGH;end;
		else if strip(ITMCHEMLAB_C)="N" then do; lblow=ITMCHEMOTHLOW;lbhigh=ITMCHEMOTHHIGH; end;
	if ITMCHEMOTHRESULT^=. then lborres=strip(put(ITMCHEMOTHRESULT,best.));

	if index(lbhigh,">")>0 then lbhigh=strip(compress(lbhigh,">"));

	if cmiss(lblow,lbhigh)=2 then rangelh_s='  -  ';
		else rangelh_s=strip(lblow)||' - '||strip(lbhigh);
	rename labname_=labname_s;
run;

proc sql;
	 create table chemothlh_s as
	 select a.*,b.rangelh_s,b.labname_s
	 from chemothlh_2 as a
	    left join
	      normal04 as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR and a.othtest = b.othtest;
quit;
/*
data normal03;
	set s_normal02;
	rename labname_=labname_s rangelh=rangelh_s;
run;
proc sql;
	 create table chemothlh_s as
	 select a.*,b.rangelh_s,b.labname_s
	 from chemothlh_2 as a
	    left join
	      normal03 as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR and a.othtest = b.othtest;
quit;*/
**************************;

data chemothlh_01;
	length vnum $100 A_VISITMNEMONIC $200 D_LABNAME_ $400;
	set chemothlh_s(rename=(VISITMNEMONIC=A_VISITMNEMONIC A_DOV=B_DOV /*LBDT=C_LBDT*/ LABNAME=D_LABNAME));
	format A_VISITMNEMONIC $200.;
	if index(A_VISITMNEMONIC,'UNS')>0 then A_VISITMNEMONIC='Unscheduled';
	vnum='v_'||strip(put(VISITNUM*10,best.));

	if labname_^=labname_s and labname_^='' then A_VISITMNEMONIC="^{style [url='#dset41' linkcolor=white foreground=blue textdecoration=underline]"||strip(A_VISITMNEMONIC)||'*}';;
	if labname_=labname_s and rangelh^=rangelh_s and resultoth^='' and strip(__COLOR)^='green' 
		then resultoth="^{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(resultoth)||' *}';
	if labname_=labname_s and rangelh=rangelh_s and resultoth^='' and upcase(ITMCHEMOTHUNIT)^=upcase(lbstresu) and strip(__COLOR)^='green' 
		then resultoth="^{style [url='#dset41' linkcolor=white textdecoration=underline]"||strip(resultoth)||' *}';

	if ITMCHEMLAB_C='N' and D_LABNAME='' then D_LABNAME='No';

	if int(VISITNUM)^=VISITNUM then vnum=strip(vnum)||'_D';
	A_VISITMNEMONIC=strip(A_VISITMNEMONIC)||'#'||strip(B_DOV);

	***********************;
    %wrapword(instr=D_LABNAME, outstr=D_LABNAME_, MAXCHAR=15, odsEscapeChar=^);
	***********************;
run;

proc sort data=chemothlh_01 out=chemothlh_01_2 nodupkey;by SUBJECTNUMBERSTR A_VISITMNEMONIC D_LABNAME ;run;

proc transpose data=chemothlh_01_2 out=t_chemoth01_2;
	by SUBJECTNUMBERSTR ;
	id Vnum;
	var A_VISITMNEMONIC D_LABNAME_ ;
run;

proc sort data=chemothlh_01 ;by SUBJECTNUMBERSTR TESTOTH rangelh_s;run;

proc transpose data=chemothlh_01 out=t_chemoth01_3;
	by SUBJECTNUMBERSTR  TESTOTH rangelh_s;
	id Vnum;
	var resultoth;
run;

data t_chemoth01_2;
	set t_chemoth01_2;
	format _name_ $60.;
run;
data t_chemoth01_3;
	set t_chemoth01_3;
	format _name_ $60.;
run;
data t_chemothall;
	set  t_chemoth01_2(drop=_label_) t_chemoth01_3;
run;
*------------------ 6.Appendix:Reference Range of Chemistry----------------------->;
data chemothidx;
	set chemothlh_01(where=(D_LABNAME^='' and resultoth^='' and strip(rangelh)^='-'));
	if labname_^=labname_s then output;
	if labname_=labname_s and rangelh^=rangelh_s then output;
	if labname_=labname_s and rangelh=rangelh_s  and upcase(ITMCHEMOTHUNIT)^=upcase(lbstresu) then output;
run;

proc sort data=chemothidx out=chemothidx1 nodupkey; by SUBJECTNUMBERSTR othtest D_LABNAME rangelh othunit A_VISITMNEMONIC;run;

data pdata.chemothidx;
	length TEST1 LOW HIGH LBCAT LAB unit $200 ;
	set chemothidx1(drop=LOW HIGH);
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
	TEST1=strip(ITMCHEMOTHSPECTEST);
	unit=strip(ITMCHEMOTHUNIT);
	LOW=lblow;
	HIGH=lbhigh;
	if ITMCHEMLAB_C='N' then lab='CRF'; else LAB=strip(D_LABNAME);

	if index(IN_VISITMNEMONIC,'UNS')>0 then do;
		A_VISITMNEMONIC="Unscheduled"||"^{newline}("||strip(B_DOV)||")";
	end;
	else do;
		A_VISITMNEMONIC=strip(IN_VISITMNEMONIC);
	end;

	keep SUBJECTNUMBERSTR LBCAT TEST1 LAB LOW HIGH unit A_VISITMNEMONIC;
run;


*----------------------- 7.Last transpose----------------------------------->;
data T_chemothlh_02;
	length __sortkey $200;
	set t_chemothall(rename=(_NAME_=__NAME));
	label
		rangelh_s='Normal Range'
	;
	if __NAME^='RESULTOTH' then do;
		 if __NAME='A_VISITMNEMONIC' then testoth='Label ';
		else if __NAME='D_LABNAME_' then testoth='Local Laboratory Used';
	end;
	if upcase(__NAME)='RESULTOTH' then __n=1; else __n=0;

	__sortkey=lowcase(strip(TESTOTH));
run;

proc sort data=T_chemothlh_02 out=s_T_chemothlh_02 nodupkey; by SUBJECTNUMBERSTR  __NAME testoth; run;

proc sort data=s_T_chemothlh_02 ; by SUBJECTNUMBERSTR __n  __NAME __sortkey; run;

%adjustVisitVarOrder(indata=s_T_chemothlh_02,othvars=SUBJECTNUMBERSTR testoth rangelh_s __n __NAME __sortkey);
data pdata.lbchem25(label='Chemistry-Local:Other Chemistry Test');
	set s_T_chemothlh_02;
run;
*----------------------------------------------------------------------------------------------------------->;


*******************************************;
data _null_;
	set sashelp.vcolumn ;
	where libname = 'PDATA'  and memname = 'LBCHEM25' and index(upcase(name), 'V_'); ;
	length _allvst_ $1024;
	retain _allvst_;
	if _n_ = 1 then call missing(_allvst_);
	_allvst_ = strip(_allvst_)||' '||name;
	call symput('allvisit', strip(_allvst_));
	call symput('nvisit', strip(put(_n_,best.)));
run;

%put &allvisit;
%put &nvisit;


data lbchem25_2;
	set pdata.lbchem25;
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
	from lbchem25_2;
quit;

%put &maxvisit;

data lbchem25_3;
	set lbchem25_2;
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
	set lbchem25_3;
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
	 from lbchem_p1_1 as a left join test2 as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR ;
quit;

proc sort data=lbchem_p1__ ; by SUBJECTNUMBERSTR __n  __NAME __sortkey; run;

data pdata.lbchem25_p1(label='Chemistry-Local:Other Chemistry Test');
	set lbchem_p1__;
	if m^=. and n=m then delete;
	drop __n __NAME m n;
run;


data lbchem_p2_;
	set lbchem25_3;
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
	 from lbchem_p2_1 as a left join test3 as b 
	 on a.SUBJECTNUMBERSTR = b.SUBJECTNUMBERSTR ;
quit;

proc sort data=lbchem_p2__ ; by SUBJECTNUMBERSTR __n  __NAME __sortkey; run;

data pdata.lbchem25_p2(label='Chemistry-Local:Other Chemistry Test(Continued)');
	set lbchem_p2__;
	if m^=. and n=m then delete;
	drop __n __NAME m n;
run;
*------------------------------------------------------------------------------------------>;
