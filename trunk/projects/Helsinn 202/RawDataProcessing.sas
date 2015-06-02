******************************************************************************;
* Purpose: Patient Profile for Helssin 202                                   *;
* Module: Preparation                                                        *;
* Type: Sas Program                                                          *;
* Program Name: RawDataProcessing.sas                                        *;
* Function: Process Raw Datasets to make them ready for printing             *;
* Author: Ken Cao (yong.cao@q2bi.com)                                        *;
* Intial Date: 16Feb2013                                                     *;
******************************************************************************;

%include 'formats.sas';
option nofmterr;

*--->Magic Numbers (Normal Range);
%let sysbplow=90;
%let sysbphigh=140;
%let diabplow=50;
%let diabphigh=90;
%let hrlow=50;
%let hrhigh=100;
%let templow=35.5;
%let temphigh=37.8;
%let prlow=120;
%let prhigh=200;
%let qrslow=60;
%let qrshigh=109;
%let qtlow=320;
%let qthigh=450;
%let qtclow=320;
%let qtchigh=450;
**************************************;


%macro filter;
	where crfstat not in ('No Data Reviewed','No Data Locked','No Data','No Data Reviewed Locked');
%mend filter;

%macro adjustvalue(dsetlabel=);
	* --> 1. Make SUBJECT;
	* --> 2. Make VISITNUM;
	* --> 3. Modify CRFNAME;
	* --> 4. Short VISITNUM;
	* --> 5. Short CRFSTAT;
	label visitn  = 'Visit^{super [1]}'
		  crfstat = 'Form Status^{super [2]}';
	length subject $40;
	subject=strip(stno)||'-'||strip(subjid);
	visitnum=input(visitn,visitnum.);
	crfname="&dsetlabel";
	visitn=put(visitn,$visit.);
	crfstat=put(crfstat,$crfstat.);
%mend adjustvalue;

%macro notInLowHigh(orres=,low=,high=);
	%local i;
	%local var1 var2 var3;
	%local nvar1 nvar2 nvar3;

 	length __orres __low __high 8 __orresc $200 __color $40;
	if _n_=1 then do;
		%let var1=&orres; %let nvar1=__orres;
		%let var2=&low;   %let nvar2=__low;
		%let var3=&high;  %let nvar3=__high;
	end;
	%do i=1 %to 3;
		if vtype(&&var&i)='C' then do;
			__result=0; 
			%IsNumeric(InStr=&&var&i,Result=__Result);
			if __result=1 then &&nvar&i=input(&&var&i,best.);;
		end;
		else do;
			&&nvar&i=&&var&i;
		end;
	%end;
	*Ken on 2013/02/26: Fix a error in statment below:;
/*	__orresc=ifc(__orres=.,'',strip(put(__orres,best.)));*/
	__orresc=strip(&orres); /*!-- This statement may generate numeric value to character value note--*/
	if not(__low<=__orres<=__high) and n(__low,__high)>0 and __orres>. then do;
		if __orres<__low then __color="&belowcolor";
		else if __orres>__high then __color="&abovecolor";
	end;
	else if n(__low,__high)=0 and __orres>. then do;
		__color="&norangecolor";
	end;
	if __color>'' then __orresc='^{style [foreground='||strip(__color)||' fontweight=bold]'||strip(__orresc)||'}';
%mend notInLowHigh;

/*
%macro sampcollect(IsCollected=, CollDate=, Reason=);
	attrib sample length=$200 label='Sample Collection';
	if upcase(&IsCollected)="YES" then sample="Sample Collected on";
	else sample='Sample not Collected:';
	sample=strip(sample)||' '||strip(&collDate)||' '||strip(&reason);
%mend sampcollect;
*/

%macro IsPerformed(IsPerformed=, Date=, Reason=, varlabel=, TextPerformed=, TextNotPerformed=);
	attrib perform length=$200 label="&varlabel";
	if upcase(&Date)>"" then perform=&Date;
	else if &Reason>'' then perform=&Reason;
	else perform=&IsPerformed;
%mend IsPerformed;

%macro getTest(indata=,testvar=);
	%local dsid;
	%local varnum;
	%local varlen;
	%local rc;

	proc sql;
		create table __testidx as
		select distinct grpinsno, &testvar
		from &indata
		where &testvar>'';
	run;
	
	%let dsid=%sysfunc(open(&indata));
	%let varnum=%sysfunc(varnum(&dsid,&testvar));
	%let varlen=%sysfunc(varlen(&dsid,&varnum));
	%let rc=%sysfunc(close(&dsid));

	data &indata;
		length grpinsno 8 &testvar $&varlen;
		if _n_=1 then do;
			declare hash h (dataset:'__testidx');
			rc=h.defineKey('grpinsno');
			rc=h.defineData("&testvar");
			rc=h.defineDone();
			call missing(grpinsno,&testvar);
		end;
		set &indata(drop=&testvar);
		rc=h.find();
		drop rc;
	run;
%mend getTest;

%macro beforeTranspose(indata=,lbtest=,lbunit=,lbclsig=,result=,comment=,cat=);
	%getTest(indata=&indata,testvar=&lbtest);

	proc freq data=&indata(where=(&lbtest>'' and &result>'')) noprint;
		table grpinsno*&lbunit / out=__labtestidx1(drop=percent);
	run;

	proc sql;
		create table __labtestidx2 as
		select distinct grpinsno, &lbunit as __unit length=200, count
		from __labtestidx1
		group by grpinsno
		having count=max(Count);
	quit;

	data &indata;
		length grpinsno 8 __unit $200;
		if _n_=1 then do;
			declare hash h (dataset:'__labtestidx2');
			rc=h.defineKey('grpinsno');
			rc=h.defineData("__unit");
			rc=h.defineDone();
			call missing(grpinsno,__unit);
		end;
		set &indata(rename=(&result=&result._ &lbtest=&lbtest._));
		rc=h.find();
		length __unit2 &result &lbtest $200;
		label &result = 'Result' &lbtest = 'Lab Test';
		if &lbunit^=__unit then do;
			if &lbunit='' then __unit2='<NO UNIT>';
			else __unit2=&lbunit;
			if index(&result._,'^{style')>0 then &result=strip(&result._)||' '||'^{style [foreground=black]'||strip(__unit2)||'}';
			else &result=strip(&result._)||' '||strip(&lbunit);
			*->Ken on 2013/03/01: When comment exists and lab result is null, then assign <NO RESULT> to lab result;
			if &comment>'' and &result._='' then &result='<NO RESULT>';
		end;
		else &result=&result._;
		if &lbclsig='Yes' then &result=strip(&result)||' CS';
		/*
		else if &lbclsig='No' then &result=strip(&result)||' NCS';
		else if &lbclsig='NA' then &result=strip(&result)||' NA';
		*/

		* -> If there is comments for lab result, then underscore the results; 
		* -> Below use pops-up text to show comments;
/*		if &comment^='' then &result='^{style [flyover="'||strip(&comment)||'"]'||strip(&result)||'}';*/

		* -> Below use hyperlink to show comments;
		if &comment^='' and &result>'' then &result="^{style [url=""#apd2%lowcase(&cat)"" fontweight=bold linkcolor=white textdecoration=underline]"||strip(&result)||'}';
		else if &comment>'' then &result="^{style [url=""#apd2%lowcase(&cat)"" fontweight=bold linkcolor=white textdecoration=underline]<NO RESULT>"||'}';
		&lbtest=strip(&lbtest._)||'#<'||strip(__unit)||'>';
	run;
%mend beforeTranspose;

%macro TimePoint(indata=,Num=,varlist=, keepvars=);
	%local i;
	%local j;
	%local k;
	%local count;
	
	%let count=%sysfunc(countc(&varlist," "));
	%let count=%eval(&count+1);
	%do i=1 %to &count;
		%local var&i;
		%let var&i=%scan(&varlist,&i," ");
	%end;

	%do i=1 %to &Num;
		%let k=%sysfunc(ifc(&i=1,,%eval(&i-1)));
		data __tpt&i(rename=(%do j=1 %to &count; %str( &&var&j..&k=&&var&j ) %end;));
			set &indata;
			keep &keepvars %do j=1 %to &count; %str( &&var&j..&k ) %end;;
		run;
	%end;
%mend TimePoint;

%macro concatDT(datevar=,timevar=,newvar=);
	if &timevar>'' then &newvar=strip(&datevar)||'T'||&timevar;
	else &newvar=&datevar;
	if strip(&newvar)='T' then &newvar='';
%mend concatDT;

%macro concatSTREND(starttime=,endtime=, newvar=);
	if &starttime>'' then &newvar=&starttime;
	if &endtime>'' then &newvar=strip(&newvar)||' - '||strip(&endtime);
%mend concatSTREND;

%macro formatDate(date);
	length __Day $10 __Month $10 __Year $10;
	* - > Get Year/Month/Day Component ;
	__Year=strip(scan(&date,1,'/'));
	__Month=strip(scan(&date,2,'/'));
	__Day=strip(scan(&date,3,'/'));
	
	* -> Numeric Month Value to 3-char value;
	__Result=0;
	%IsNumeric(InStr=__Month, Result=__Result);
/*	if upcase(__Month) not in ('UN','UNK','UK','NK','') then*/
	if __Result=1 then 
		__Month=substr(put(input('1960-'||strip(__Month)||'-01',yymmdd10.),date9.),3,3);
	else if __Month^='' then __Month='UNK';
	__Month=propcase(__Month);

	* -> 4-digt year value to 2-digt year value;
	if length(__Year)=4 then __Year=substr(__Year,3);
	else if __Year>'' then __Year='UU';

	* -> Handle unknown Day value;
	__Result=0;
	%IsNumeric(InStr=__Day, Result=__Result);
	if __Result=0 and __Day>'' then __Day='UU';

	* -> New Date Format;
	&date=strip(__Day)||ifc(__Month>'','-','')||strip(__Month)||ifc(__Year>'','-','')||strip(__Year);
%mend formatDate;

%macro ENRF(ongo=,stopdate=);
	if upcase(&ongo)='YES' then &stopdate='Ongoing';
%mend ENRF;

%macro concatOTHER(var=, oth=, newvar=, displayoth=);
	%if %upcase(&displayoth)=Y %then %do;
		if &oth>'' then &newvar=strip(&var)||': '||&oth;
		else &newvar=&var;
	%end;
	%else %do;
		if &oth>'' and upcase(&var)='OTHER' then &newvar=&oth;
		else if &oth>'' then &newvar=&oth;
		else &newvar=&var;
	%end;
%mend concatOTHER;

%macro normalRange(var=,low=,high=,outvar=);
	if &var>. then do;
		if &var<&low then
			&outvar="^{style [foreground=&belowcolor]"||strip(put(&var,best.))||'}^{style [foreground=black]}';
		else if &var>&high then 
			&outvar="^{style [foreground=&abovecolor]"||strip(put(&var,best.))||'}^{style [foreground=black]}';
		else &outvar=strip(put(&var,best.));
	end;
%mend normalRange;

%global globalVars1;
%global globalVars2;

* -> With Visit; 
%let GlobalVars1=%str(subject visitnum visitn visitdt crfname crfstat);

* -> Without Visit (If Visit is removed, then VIISTDT is also removed); 
%let GlobalVars2=%str(subject visitnum crfname crfstat);




*<Demo------------------------------------------------------------------------------------------------------;
data _exit;
	length subject $40 __stat $256;
	keep subject __stat;
	set source.ds;
	subject=strip(stno)||'-'||strip(subjid);
	%adjustvalue(dsetlabel=Demographics);
	%formatDate(dsdtc);
	if dscomp='Yes' then __stat='Completed';
	else if dscomp='No' then __stat='Exited';
	else if index(crfstat,'No Data')>0 then __stat=crfstat;
	else __stat='Ongoing';
	if __stat='Exited' then
	do;
		if dsrsn='Screen Failure' then __stat='^{style [foreground=red] Screen Failure}';
		else __stat=dsrsn;
	end;
	if dsdtc>'' then __stat=strip(__stat)||': '||dsdtc;
run;

data dm0;
	set source.dm;
	length __sex $2 __age 8;
	__sex=upcase(substr(sex,1,1));
	if strip(__sex)='' then __sex='NA';
	__brthdt=ifn(dob='',.,input(translate(dob,'-','/'),yymmdd10.));
	__icdt=ifn(icdt='',.,input(translate(icdt,'-','/'),yymmdd10.));
	if n(__brthdt,__icdt)=2 then __age=(__icdt-__brthdt+1)/365.25;
	if __age>. then __agec=strip(put(__age,5.0))||"&escapechar{super [3]}";
	else __agec='NA'||"&escapechar{super [3]}";;


/*	%filter;*/
	%adjustvalue(dsetlabel=Demographics);
	%formatDate(visitdt);
	%formatDate(icdt);
	%formatDate(dob);
	*-> Modify Variable Label;
	label 
		icdt = 'Date Informed#Consent Signed'
		raceoth = 'Race Other,#Specify'
	;
run;

data pdata.dm;
	retain &globalvars1 icdt init dob sex ethnic race raceoth chbp;
	keep   &globalvars1 icdt init dob sex ethnic race raceoth chbp __sex __age __stat __title;
	length subject $40 __stat $256;
	if _n_=1 then do;
		declare hash h(dataset:'_exit');
		rc=h.defineKey('subject');
		rc=h.defineData('__stat');
		rc=h.defineDone();
		call missing(subject,__stat);
	end;
	set dm0;
	rc=h.find();
	length __title $1024;
	__title=strip(subject)||' / '||strip(__sex)||' / '||strip(__agec)||' / '||strip(__stat);
	* -> Modify Label;
	label
		chbp = 'Childbearing Potential'
	;
run;

data pdata.fulldm;
	set source.dm;
	length subject $40;
	subject=strip(stno)||'-'||strip(subjid);
run;
*----------------------------------------------------------------------------------------------------------->;

*<CLTC-------------------------------------------------------------------------------------------------------;
data cltc0;
	set source.cltc(rename=(lbcres=lbcres2));
	length lbcres $200;
	%filter;
	%adjustvalue(dsetlabel=Clinical Laboratory Tests: Chemistry);
	%formatDate(lbcdt);
	%formatDate(visitdt);
	%IsPerformed(IsPerformed=lbchem, Date=lbcdt, Reason=lbcrsn, varlabel=%str(Sample Collection),
		TextPerformed=%str(Sample Collected on), TextNotPerformed=%str(Sample not Collected:));
	%notInLowHigh(orres=lbcres2,low=lbcllr,high=lbculr);
	lbcres=__orresc;
	label lbcres ='Result'
	 perform = 'Sample#Collection'
	 ;
run;

%beforeTranspose(indata=cltc0,lbtest=lbctests,result=lbcres,lbunit=lbcunit,lbclsig=lbcclsig,comment=lbccomm,cat=CHEM);

proc sort data=cltc0; by &globalvars1 perform  grpinsno lbctests; run;

proc transpose data=cltc0 out=t_cltc0(drop=_name_ _label_);
	by &globalvars1 perform;
	id grpinsno;
	idlabel lbctests;
	var lbcres;
run;

data pdata.cltc1(drop=_9-_17) pdata.cltc2(drop=_1-_8 visitdt crfstat perform);
	set t_cltc0;
	output pdata.cltc1;
	output pdata.cltc2;
run;

data pdata.cltc1;
	set pdata.cltc1;
	crfname='Clinical Laboratory Tests: Chemistry, Part 1';
run;

data pdata.cltc2;
	set pdata.cltc2;
	crfname='Clinical Laboratory Tests: Chemistry, Part 2';
run;
*----------------------------------------------------------------------------------------------------------->;

*<CLTH-------------------------------------------------------------------------------------------------------;
data clth0;
	set source.clth(rename=(lbhres=lbhres2));
	length lbhres $200;
	%formatDate(lbhdt);
	%formatDate(visitdt);
	%IsPerformed(IsPerformed=lbhema, Date=lbhdt, Reason=lbhrsn, varlabel=%str(Sample Collection),
		TextPerformed=%str(Sample Collected on), TextNotPerformed=%str(Sample not Collected:));
	%notInLowHigh(orres=lbhres2,low=lbhllr,high=lbhulr);
	lbhres=__orresc;
	%filter;
	%adjustvalue(dsetlabel=Clinical Laboratory Tests: Hematology);
	label lbhres ='Result' 		
		 perform = 'Sample#Collection';
run;

%beforeTranspose(indata=clth0,lbtest=lbhtests,result=lbhres,lbunit=lbhunit,lbclsig=lbhclsig,comment=lbhcomm,cat=HEM);

proc sort data=clth0; by &globalvars1  perform  grpinsno lbhtests; run;

proc transpose data=clth0 out=t_clth0(drop=_name_ _label_);
	by &globalvars1 perform;
	id grpinsno;
	idlabel lbhtests;
	var lbhres;
run;
/*
data pdata.clth1(drop=_7-_12) pdata.clth2(drop=_1-_6 visitdt crfstat perform);
	set t_clth0;
	output pdata.clth1;
	output pdata.clth2;
run;
*/
data pdata.clth;
	set t_clth0;
run;

*----------------------------------------------------------------------------------------------------------->;

*<CLTU--------------------------------------------------------------------------------------------------------;
data cltu0;
	set source.cltu(rename=(lbures=lbures2));
	length lbures $200 ;
	%formatDate(lbudt);
	%formatDate(visitdt);
	%IsPerformed(IsPerformed=lburi, Date=lbudt, Reason=lbursn, varlabel=%str(Sample Collection),
		TextPerformed=%str(Sample Collected on), TextNotPerformed=%str(Sample not Collected:));
	%notInLowHigh(orres=lbures2,low=lbullr,high=lbuulr);
	lbures=__orresc;
	if lbuoth>'' then lbures=strip(lbuoth)||': '||lbures;
	%filter;
	%adjustvalue(dsetlabel=Clinical Laboratory Tests: Urinalysis);
	label lbures ='Result' 
		  lbutests='Lab Test'
		  perform = 'Sample#Collection';
		;
run;

%beforeTranspose(indata=cltu0,lbtest=lbutests,result=lbures,lbunit=lbuunit,lbclsig=lbuclsig,comment=lbucomm,cat=URIN);

proc sort data=cltu0; by &globalvars1 utcol utapp utbac perform grpinsno lbutests; run;

proc transpose data=cltu0 out=t_cltu0(drop=_name_ _label_);
	by &globalvars1 utcol utapp utbac perform;
	id grpinsno;
	idlabel lbutests;
	var lbures;
run;

data pdata.cltu1(drop=_7-_18) pdata.cltu2(drop=_1-_6 visitdt crfstat  utcol utapp utbac perform);
	set t_cltu0;
	*->Modify Label;
	label
		utcol = 'Urin. test-Color' 
		utapp = 'Urin. test-Appearance'
		utbac = 'Urin. test-Bacteria'
	;
	output pdata.cltu1;
	output pdata.cltu2;
run;

data pdata.cltu1;
	set pdata.cltu1;
	crfname='Clinical Laboratory Tests: Urinalysis, Part 1';
run;

data pdata.cltu2;
	set pdata.cltu2;
	crfname='Clinical Laboratory Tests: Urinalysis, Part 2';
run;

*------------------------------------------------------------------------------------------------------------>;


*<MH--------------------------------------------------------------------------------------------------------;
data mh0;
	set source.mh;
	%filter;
	%adjustvalue(dsetlabel=Medical History);
	%formatDate(mhstdt);
	%formatDate(mhendt);
	%formatDate(visitdt);
	%ENRF(ongo=mhongo,stopdate=mhendt);
	if mhcond>'';
run;


proc sort data=mh0; by subject grpinsno; run;

data mh1;
	retain &GlobalVars1 grpinsno mhcond mhstdt mhendt;
	keep   &GlobalVars1 grpinsno mhcond mhstdt mhendt;
	set mh0;
run;

data imh0;
	set source.imh;
	%filter;
	%adjustvalue(dsetlabel=Interim Medical History);
	%formatDate(imhstdt);
	%formatDate(imhendt);
	%formatDate(visitdt);
	%ENRF(ongo=imhongo,stopdate=imhendt);
	if imhcond>'';
run;

data imh1;
	retain &GlobalVars1 grpinsno mhcond mhstdt mhendt;
	keep   &GlobalVars1 grpinsno mhcond mhstdt mhendt;
	set imh0
	(
		rename =
		(
		imhcond = mhcond
		imhstdt = mhstdt
		imhendt = mhendt
		)
	)
	;
run;

data combineMH;
	set mh1 imh1;
run;

proc sort data=combineMH out=pdata.mh;
	by subject visitnum grpinsno;
run;


*----------------------------------------------------------------------------------------------------------->;

*<DH--------------------------------------------------------------------------------------------------------;
data dh0;
	set source.dh(rename=(dhp=__dhp));
	%filter;
	%adjustvalue(dsetlabel=Disease History);
	%formatDate(visitdt);
	%formatDate(dhdt);
	
	attrib
		dhp        length=$200      label='Primary diagnosis for which surgery is planned'
		allsite    length=$512      label='Sites of metastases (check all that apply)'
		;

	* -> Concate DHP and DHOTHSP;
	%concatOTHER(var=__dhp,oth=dhothsp, newvar=dhp, displayoth=Y);

	* -> combine all site;

	* -> Initialization;
	allsite='';
	* -> Define array, if site invovled, then show variable label in all site variable;
	array site{*} dhcns dhbs dhsk dhlu dhli dhsp dhln dhcw dhes dhst dhbr dhov dhpa dhak dhco dhre dhoi dhret;
	do i=1 to dim(site);
		if upcase(site[i])='Y' then do;
			if allsite>'' then allsite=strip(allsite)||', '||vlabel(site[i]);
			else allsite=vlabel(site[i]);
		end;
	end;	
	* -> OTHER;
	if dhothsp1>'' then do;
		if allsite>'' then allsite=strip(allsite)||', '||dhothsp;
		else allsite=dhothsp;
	end;
	drop i dhcns dhbs dhsk dhlu dhli dhsp dhln dhcw dhes dhst dhbr dhov dhpa dhak dhco dhre dhoi dhoth dhothsp1 dhothsp  dhret __: ;
run;

/*
proc sort data=dh0; by subject; run;

proc transpose data=dh0 out=t_dh0(rename=(_label_=item col1=value));
	by subject visitnum visitn visitdt crfname crfstat dhp dhothsp dhdt dhmch;
	var dhcns dhbs dhsk dhlu dhli dhsp dhln dhcw dhes dhst dhbr dhov dhpa dhak dhco dhre dhoi dhret dhoth dhothsp1;
run;
*/
data pdata.dh;
	retain &globalvars1 dhp dhdt dhmch allsite;
	keep   &globalvars1 dhp dhdt dhmch allsite;
	set dh0;
run;
*----------------------------------------------------------------------------------------------------------->;


*<PE--------------------------------------------------------------------------------------------------------;
data pe0;
	set source.pe;
	%filter;
	%adjustvalue(dsetlabel=Abnormal Physical Examination);
	%formatDate(visitdt);
	%formatDate(pedtc);
	
	attrib
		peweightc      length=$200       label='Weight'
		peheightc      length=$200       label='Height'
		peresult	   length=$200       label='Abnormal Findings'
		peresulto	   length=$200       label='Other Abnormal Findings'
		pespeco                          label='Other Body System'
	;

	peweightc=ifc(pewght=.,'',strip(put(pewght,best.)));
	peweightc=strip(peweightc)||' '||strip(pewgtun);
	peheightc=ifc(pehght=.,'',strip(put(pehght,best.)));
	peheightc=strip(peheightc)||' '||strip(pehgtun);

	* -> Concat Abnormal findings with ABNORMAL;
	if pedesc>'' then peresult='Abnormal: '||pedesc;
	else if index(upcase(peres),'ABNORMAL')>0 then peresult='Abnormal';
/*	if pespeco>'' then peoth=strip(peoth)||':'||strip(pespeco);*/
	if pedesco>'' then peresulto='Abnormal: '||pedesco;
	else if index(upcase(pereso),'ABNORMAL')>0 then peresulto='Abnormal';

	
	if pespeco^='' then peoth=strip(peoth)||'- '||strip(pespeco)||': '||pereso;
	else peoth='';
	if pedesc^='' then peres=strip(peres)||': '||pedesc;
	*-> Addtional fitlers: only list abnormal findings;
	*Ken on 2013/02/26: Fix the output filter, if pe result contains the word ABNORMAL, then output;
	if index(upcase(peres),'ABNORMAL')>0 or index(upcase(pereso),'ABNORMAL')>0;
	drop __:;
run;

data pdata.pe;
	retain &globalvars1 grpinsno pedtc peweightc peheightc petest peresult pespeco peresulto;
	keep   &globalvars1 grpinsno pedtc peweightc peheightc petest peresult pespeco peresulto;
	set pe0;
run;

/*
%getTest(indata=pe0,testvar=petest);

proc sort data=pe0; by subject visitnum visitn visitdt crfname crfstat peyn pedtc peweightc peheightc peoth grpinsno; run;

proc transpose data=pe0 out=t_pe0(drop=_name_ _label_);
	by subject visitnum visitn visitdt crfname crfstat peyn pedtc peweightc peheightc peoth;
	id grpinsno;
	idlabel petest;
	var peres;
run;

data pdata.pe1(drop=_6-_11 peoth) pdata.pe2(drop=_1-_5 peweightc peheightc);
	set t_pe0;
	output pdata.pe1;
	output pdata.pe2;
run;
*/
*----------------------------------------------------------------------------------------------------------->;

*<VS--------------------------------------------------------------------------------------------------------;
%macro bp(sysbp=,diabp=, newvar=);
	attrib
		&newvar   length=$512    label='Blood Pressure#<mmHg>'
	;
	&newvar=ifc(&sysbp='','',strip(&sysbp))||' / '||ifc(&diabp='','',strip(&diabp));
	if compress(&newvar)='/' then &newvar='';
%mend bp;


data vs0;
	set source.vs;
	attrib
		vsdtc2	  length=$20		label='Date/Time vital signs taken'
		vshrc	  length=$200		label='Heart Rate (beats/min)'
		vstempc	  length=$200		label='Temperature'
		vsdiabpc  length=$200
		vssysbpc  length=$200		
	;

	%filter;
	%adjustvalue(dsetlabel=Vital Signs);
	%formatDate(visitdt);
	%formatDate(vsdtc);
	vsdtc2=strip(vsdtc)||ifc(vsdtm>'','T','')||strip(vsdtm);

	%normalRange(var=vshr,low=&hrlow,high=&hrhigh,outvar=vshrc);
	if upcase(vstempu)='CELSIUS' then do;
		%normalRange(var=vstemp,low=&templow,high=&temphigh,outvar=vstempc);
	end;
	else  if upcase(vstempu)='FAHRENHEIT' then do;
		%normalRange(var=vstemp,low=&templow*1.8+32,high=&temphigh*1.8+32,outvar=vstempc);
	end;
	vstempc=ifc(vstempc>'', strip(vstempc)||' '||vstempu,'');


	%normalRange(var=vsdiabp,low=&diabplow,high=&diabphigh,outvar=vsdiabpc);
	%normalRange(var=vssysbp,low=&sysbplow,high=&sysbphigh,outvar=vssysbpc);
	%bp(sysbp=vssysbpc,diabp=vsdiabpc, newvar=bp);
run;



/*
data vs0;
	set source.vs;
	attrib 
		vsdtc2	length=$20		label='Date/Time vital signs taken'
		vshrc	length=$20		label='Heart Rate (beats/min)'
	;
	%filter;
	%adjustvalue(dsetlabel=Vital Signs);
	%formatDate(visitdt);
	%formatDate(vsdtc);
	* -> concat blood pressure;
	%bp(sysbp=vssysbp,diabp=vsdiabp, newvar=bp);
	* -> concat temperature with unit(C/F);
	%temp(temp=vstemp,tempunit=vstempu,newvar=vstempc);
	vsdtc2=strip(vsdtc)||ifc(vsdtm>'','T','')||strip(vsdtm);
	*-> numeric value to character value for reporting use (eliminate period from report);
	%any2char(invar=vshr,indata=source.vs);
	vshrc= _charval ;
run;
*/

data pdata.vs;
	retain &globalvars1 vsdtc2 bp vshrc vstempc;
	keep   &globalvars1 vsdtc2 bp vshrc vstempc;
	set vs0;
run;

%macro VSD(indata);
	data __vs0;
		set source.&indata;
		%filter;
		%adjustvalue(dsetlabel=Vital Signs (Dose));
		%formatDate(visitdt);
		%formatDate(vsdtc);
		%formatDate(vsdtc1);

		attrib
			vsdtcm	    length=$20   	label='Date/Time vital signs taken'
			vsdtcm1	    length=$20  	label='Date/Time vital signs taken'
			vshrc	    length=$200		label='Heart Rate (beats/min)'
			vshrc1	    length=$200		label='Heart Rate (beats/min)'
			vstempc	    length=$200		label='Temperature'
			vstempc1    length=$200		label='Temperature'
			vsdiabpc  length=$200
			vssysbpc  length=$200
			vsdiabpc1  length=$200
			vssysbpc1  length=$200		

		;

		vsdtcm=strip(vsdtc)||ifc(vsdtm>'','T','')||strip(vsdtm);
		vsdtcm1=strip(vsdtc1)||ifc(vsdtm1>'','T','')||strip(vsdtm1);


		%normalRange(var=vshr,low=&hrlow,high=&hrhigh,outvar=vshrc);
		%normalRange(var=vshr1,low=&hrlow,high=&hrhigh,outvar=vshrc1);

		if upcase(vstempu)='CELSIUS' then do;
			%normalRange(var=vstemp,low=&templow,high=&temphigh,outvar=vstempc);
		end;
		else if upcase(vstempu)='FAHRENHEIT' then do;
			%normalRange(var=vstemp,low=&templow*1.8+32,high=&temphigh*1.8+32,outvar=vstempc);
		end;

		vstempc=ifc(vstempc>'',strip(vstempc)||' '||vstempu,'');

		if upcase(vstempu1)='CELSIUS' then do;
			%normalRange(var=vstemp1,low=&templow,high=&temphigh, outvar=vstempc1);
		end;
		else if upcase(vstempu1)='FAHRENHEIT' then do;
			%normalRange(var=vstemp1,low=&templow*1.8+32,high=&temphigh*1.8+32,outvar=vstempc1);
		end;

		vstempc1=ifc(vstempc1>'',strip(vstempc1)||' '||vstempu1,'');

		%normalRange(var=vsdiabp,low=&diabplow,high=&diabphigh,outvar=vsdiabpc);
		%normalRange(var=vssysbp,low=&sysbplow,high=&sysbphigh,outvar=vssysbpc);
		%bp(sysbp=vssysbpc,diabp=vsdiabpc, newvar=bp);

		%normalRange(var=vsdiabp1,low=&diabplow,high=&diabphigh,outvar=vsdiabpc1);
		%normalRange(var=vssysbp1,low=&sysbplow,high=&sysbphigh,outvar=vssysbpc1);
		%bp(sysbp=vssysbpc1,diabp=vsdiabpc1, newvar=bp1);
	run;
	
	proc sort data=__vs0; by subject visitnum; run;	
/*
	%TimePoint(indata=__vs0, Num=2,
	keepvars=subject visitnum visitn visitdt crfname crfstat,
	varlist=vsdtc vsdtm vssysbp vsdiabp vshr vstemp vstempu);
*/	
	data &indata;
		retain &globalvars1 vsdtcm bp vshrc vstempc vsdtcm1 bp1 vshrc1 vstempc1 ;
		keep   &globalvars1 vsdtcm bp vshrc vstempc vsdtcm1 bp1 vshrc1 vstempc1 ;
		set __vs0;
		/*
		*->Amened variable label;
		label
			bp        = 'Pre-Dose#Blood Pressue#<mmHg>'      vshr    =  'Pre-Dose#Heart Rate#(beats/min)'  
			vstempc   = 'Pre-Dose#Temperature' 	             vsdtc   =  'Pre-Dose#Date'
			bp1       = 'Post-Dose#Blood Pressue#<mmHg>'     vshr1   =  'Post-Dose#Heart Rate#(beats/min)'  
			vstempc1  = 'Post-Dose#Temperature'              vsdtc1  =  'Post-Dose#Date'
		;
		*/
	run;
%mend VSD;

%VSD(vs1);
%VSD(vs2);
%VSD(vs3);

data vsd0;
	set vs1(in=a) vs2(in=b) vs3(in=c);
	attrib
		crfname1        length=$40       label='Form Name'
	;
	if a then do;      crfname1='Vital Signs (Dose 1)'; __ord=1; end;
	else if b then do; crfname1='Vital Signs (Dose 2)'; __ord=2; end;
	else if c then do; crfname1='Vital Signs (Dose 3)'; __ord=3; end;
run;

proc sort data=vsd0; by subject visitnum vsdtcm __ord ; run; 

data pdata.vsd;
	retain &globalvars1 crfname1 __ord vsdtcm bp vshrc vstempc vsdtcm1 bp1 vshrc1 vstempc1 ;
	keep   &globalvars1 crfname1 __ord vsdtcm bp vshrc vstempc vsdtcm1 bp1 vshrc1 vstempc1 ;
	set vsd0;
run;
*----------------------------------------------------------------------------------------------------------->;


*<ECG--------------------------------------------------------------------------------------------------------;
proc format;
	value $ecgcs
		'Normal'='Normal'
		'Abnormal not clinically significant'='Abnormal NCS'
		'Abnormal clinically significant'='Abnormal CS'
	;
run;

%macro concatECG(PR=,QRS=,QT=,QTC=, newvar=);
	attrib
		&newvar    length=$1024     label="PR(ms)/QRS(ms)#/QT(ms)/QTc(ms)"
	;
	&newvar=ifc(&pr='','',strip(&PR))||'/'||ifc(&qrs='','',strip(&qrs))||'/'||
			ifc(&qt='','',strip(&qt))||'/'||ifc(&qtc='','',strip(&qtc));
	if compress(&newvar)='///' then &newvar='';
%mend concatECG;

%macro ECGCS(CS=, specify=, newvar=);
	&CS=put(&CS,$ecgcs.);
	attrib 
		&newvar    length=$256     label='CS'
	;
	&newvar=ifc(&specify>'',strip(&cs)||': '||strip(&specify), &cs);
%mend ECGCS;

data ecg0;
	set source.ecg;
	%filter;
	%adjustvalue(dsetlabel=12-Lead Electrocardiogram);
	%formatDate(visitdt);
	%formatDate(ecgdt);
	%IsPerformed(IsPerformed=precgper, Date=ecgdt, Reason=ecgsrsn, varlabel=%str(12-Lead ECG#Performed));

	length ecgpric ecgpric1 ecgpric2 $200 ecgqrsc ecgqrsc1 ecgqrsc2 $200
			ecgqt_c ecgqt_c1 ecgqt_c2 $200 ecgqtc_c ecgqtc_c1 ecgqtc_c2 $200
		;

	%normalRange(var=ECGPRI,low=&prlow,high=&prhigh,outvar=ECGPRIC);
	%normalRange(var=ECGPRI1,low=&prlow,high=&prhigh,outvar=ECGPRIC1);
	%normalRange(var=ECGPRI2,low=&prlow,high=&prhigh,outvar=ECGPRIC2);
	%normalRange(var=ECGQRS,low=&qrslow,high=&qrshigh,outvar=ECGQRSC);
	%normalRange(var=ECGQRS1,low=&qrslow,high=&qrshigh,outvar=ECGQRSC1);
	%normalRange(var=ECGQRS2,low=&qrslow,high=&qrshigh,outvar=ECGQRSC2);
	%normalRange(var=ECGQT,low=&qtlow,high=&qthigh,outvar=ECGQT_C);
	%normalRange(var=ECGQT1,low=&qtlow,high=&qthigh,outvar=ECGQT_C1);
	%normalRange(var=ECGQT2,low=&qtlow,high=&qthigh,outvar=ECGQT_C2);
	%normalRange(var=ECGQTC,low=&qtclow,high=&qtchigh,outvar=ECGQTC_C);
	%normalRange(var=ECGQTC1,low=&qtclow,high=&qtchigh,outvar=ECGQTC_C1);
	%normalRange(var=ECGQTC2,low=&qtclow,high=&qtchigh,outvar=ECGQTC_C2);
	
	%concatECG(PR=ECGPRIC,QRS=ECGQRSC,QT=ECGQT_C,QTC=ECGQTC_C, newvar=ecgresult);
	%concatECG(PR=ECGPRIC1,QRS=ECGQRSC1,QT=ECGQT_C1,QTC=ECGQTC_C1, newvar=ecgresult1);
	%concatECG(PR=ECGPRIC2,QRS=ECGQRSC2,QT=ECGQT_C2,QTC=ECGQTC_C2, newvar=ecgresult2);

	%ECGCS(cs=ECGASS,specify=ECGSSPEC, newvar=cs);
	%ECGCS(cs=ECGASS1,specify=ECGSSPE1, newvar=cs1);
	%ECGCS(cs=ECGASS2,specify=ECGSSPE2, newvar=cs2);

	*->Modify Label;
	label 
		ecgtm  = 'Time' 
		ecgtm1 = 'Time'
		ecgtm2 = 'Time'
	;
run;

data pdata.ecg;
	retain  &globalvars1 perform ecgtm ecgresult cs ecgtm1 ecgresult1 cs1 ecgtm2 ecgresult2 cs2;
	keep    &globalvars1 perform ecgtm ecgresult cs ecgtm1 ecgresult1 cs1 ecgtm2 ecgresult2 cs2;
	set ecg0;
run;

/*
proc sort data=ecg0; by subject visitnum; run;

%TimePoint(indata=ecg0, Num=3,
	keepvars=subject visitnum visitn visitdt crfname crfstat perform,
	varlist=ecgtm ecgpri ecgqrs ecgqt ecgass ecgsspec);
data pdata.ecg;
	retain subject visitnum visitn visitdt crfname crfstat perform ecgtm ecgpri ecgqrs ecgqt ecgass ecgsspec;
	retain subject visitnum visitn visitdt crfname crfstat perform ecgtm ecgpri ecgqrs ecgqt ecgass ecgsspec;
	set __tpt1(in=a) __tpt2(in=b) __tpt3(in=c);
		by subject visitnum;
	if a then do; tpt='Pre-Dose'; __tptnum=0; end;
	else if b then do; tpt='Post-Dose 1'; __tptnum=1;end;
	else if c then do; tpt='Post-Dose 2'; __tptnum=2;end;
run;
*/

*----------------------------------------------------------------------------------------------------------->;

*<MP--------------------------------------------------------------------------------------------------------;
%macro MP(indata);
	data __&indata;
		set source.&indata;
		%filter;
		%adjustvalue(dsetlabel=Meal Procedures);
		%formatDate(visitdt);
	run;
%mend MP;

%mp(mp1);
%mp(mp2);
%mp(mp3);

data mp0;

	set __mp1(in=a) __mp2(in=b) __mp3(in=c);

	attrib
		crfname1   length=$60    label='Form Name'
	;

	if a then do; crfname1='Meal Procedures(Morning)'; __ord=1; end;
	else if b then do; crfname1='Meal Procedures(Afternoon)'; __ord=2; end;
	else if c then do; crfname1='Meal Procedures(Evening)'; __ord=3; end;

	* -> Modify label;
	label 
		ssmase   =  'Begin Time'
		ssmare   =  'End Time'
		postm    =  'Experience Nausea?'
		postvom  =  'Vomit?'
;
run;

proc sort data=mp0; by subject visitdt __ord; run;

data pdata.mp;
	retain &globalvars1 crfname1 __ord ssmat ssmase ssmare meald postm postvom postmt;
	keep   &globalvars1 crfname1 __ord ssmat ssmase ssmare meald postm postvom postmt;

	set mp0;
run;

*----------------------------------------------------------------------------------------------------------->;

*<RCV--------------------------------------------------------------------------------------------------------;
data rcv0;
	set source.rcv;
	length question $512 rcvdtc rcvedtc $40;

	label RCVEVT='Experienced Pre-defined Events?' 
		  rcvdtc='Start Date/Time'
		  rcvedtc='Stop Date/Time';

	question='Has the patient experienced any of the following: Bowel Sounds, Bowel Movement, Flatus, NGT Insertion, NGT Removal, Vomiting Episode.';
	%filter;
	%adjustvalue(dsetlabel=GI Recovery Events);
	%formatDate(visitdt);
	%formatDate(rcvdt);
	%formatDate(rcvedt);

	if rcvtm>'' then rcvdtc=strip(rcvdt)||'T'||rcvtm; else rcvdtc=rcvdt;
	if rcvetm>'' then rcvedtc=strip(rcvedt)||'T'||rcvetm; else rcvedtc=rcvedt;
	if upcase(RCVEVT)='YES';

	if rcvdt>'' or rcvedt>'';
run;

data pdata.rcv;
	retain &globalvars1 grpinsno rcvevt rcvtp rcvdtc rcvedtc;
	keep &globalvars1 grpinsno  rcvevt rcvtp rcvdtc rcvedtc ;
	set rcv0;
run;
*----------------------------------------------------------------------------------------------------------->;


*<HS--------------------------------------------------------------------------------------------------------;
data hs0;
	set source.hs;
	%filter;
	%adjustvalue(dsetlabel=Hospitalization Summary);
	%formatDate(visitdt);
	%formatDate(hddt);
	%formatDate(hddow);
	%formatDate(hdadt);
	%formatDate(hraddt);

	attrib 
		hddtc   length=$40  label = 'Date/Time eligible for discharge based on GI function'
		hddowc  length=$40  label = 'Date Discharge Order Written'
		hdadtc   length=$40  label = 'Actual Date/Time Discharged from Hospital'
		hraddtc length=$40  label = 'Date/Time re-admitted to hospital'
		hradspec            label = 'Reason subject was re-admitted'
		allcrt  length=$512 label = 'Investigator criteria for hospital discharge (check all that apply)'
		hrad   				label = 'Was subject re-admitted to hospital within 14 days after discharge?'
	;
	allcrt='';
	%concatDT(datevar=hddt,timevar=hdtm,newvar=hddtc);
	%concatDT(datevar=hddow,timevar=hdtow,newvar=hddowc);
	%concatDT(datevar=hdadt,timevar=hdati,newvar=hdadtc);
	%concatDT(datevar=hraddt,timevar=hradtm,newvar=hraddtc);

	* -> combine all criteria;
	array hdcrit{*} hdcrit1-hdcrit5;
	cnt=0; *number of Yes;
	do i=1 to dim(hdcrit);
		if hdcrit[i]='Yes' then do;
			cnt=cnt+1;
			if cnt<=2 then
				allcrt=strip(allcrt)||ifc(allcrt>'',', ','')||vlabel(hdcrit[i]);
			else do;
				allcrt=strip(allcrt)||', ^{newline}'||vlabel(hdcrit[i]);
				cnt=1;
			end;
		end;
	end;
	if hdcrit6>'' then allcrt=strip(allcrt)||ifc(allcrt>'',', ','')||'Other';
	if hdcritsp>'' then allcrt=strip(allcrt)||':'||hdcritsp;
run;

data pdata.hs;
	retain &globalvars1 hddtc allcrt hddowc hdadtc hrad hradspec hraddtc;
	keep   &globalvars1 hddtc allcrt hddowc hdadtc hrad hradspec hraddtc ;
	set hs0;
run;
*----------------------------------------------------------------------------------------------------------->;


*<SDA--------------------------------------------------------------------------------------------------------;
data sda0;
	set source.sda(rename=(CRFINSNO=__CRFINSNO));
	%filter;
	%adjustvalue(dsetlabel=Study Drug Administration );
	%formatDate(dayinfu);
	attrib
		DYINTM    length=$40     label='Start-Stop Time of Infusin'
		DYITRETM  length=$40     label='Interruption-Restart of Infusion'
		DOSEDELC  length=$10	 label='Amount of Dose Delivered (mL)'
	;
	%concatSTREND(starttime=DYINSTTM,endtime=DYINENTM, newvar=DYINTM);
	%concatSTREND(starttime=DYITTM,endtime=DYINRETM, newvar=DYITRETM);

	*->numeric value to character ;
	dosedelc=ifc(dosedel=.,'',strip(put(dosedel,best.)));
run;


data PDATA.sda;
	retain &globalvars2 __CRFINSNO drugadm dosedelc daydose dayinfu dyintm entire entrs dyitretm rsint rsintspo finald;
	keep   &globalvars2 __CRFINSNO drugadm dosedelc daydose dayinfu dyintm entire entrs dyitretm rsint rsintspo finald;
	set sda0;	
run;


*----------------------------------------------------------------------------------------------------------->;


*<AE--------------------------------------------------------------------------------------------------------;
data ae0;
	set source.ae(rename=(CRFINSNO=__CRFINSNO));
	%filter;
	%adjustvalue(dsetlabel=Adverse Event);
	%formatDate(aestdtc);
	%formatDate(aeendtc);
	attrib
		aestdtm    length=$40     label='Start Date/Time'
		aeendtm    length=$40     label='Stop Date/Time'
		aeser                     label='Serious AE?'
		aerel                     label='Related to Study Drug?'
		aeact                     label='Action Taken'
		aetrt                     label='Treatment Required?'
		aeyn					  label='Any AE during the study?'
	;
	%concatDT(datevar=aestdtc,timevar=aesttm,newvar=aestdtm);
	%concatDT(datevar=aeendtc,timevar=aeentm,newvar=aeendtm);
	%ENRF(ongo=aeongo,stopdate=aeendtm);

run;

data pdata.ae;
	retain &globalvars2  __crfinsno aeyn aetxt  aestdtm aeendtm aeser aesev aerel aeact aeactsp aeout aetrt aetrtm aetrth aetrspec;
	keep   &globalvars2 __crfinsno aeyn aetxt  aestdtm aeendtm aeser aesev aerel aeact aeactsp aeout aetrt aetrtm aetrth aetrspec;
	set ae0;
run;
*----------------------------------------------------------------------------------------------------------->;

*<CM--------------------------------------------------------------------------------------------------------;
data cm0;
	set source.cm(rename=(CRFINSNO=__CRFINSNO cmdosu=cmdosu2 cmroute=cmroute2 cmfreq=cmfreq2));
	%filter;
	%adjustvalue(dsetlabel=Concomitant Medications);
	%formatDate(cmstdt);
	%formatDate(cmendt);
	attrib
		cmdosu   length=$200    label='Unit'
		CMROUTE  length=$200    label='Route'
		CMFREQ   length=$200    label='Frequency'
	;
	/*
	cmdosu=strip(cmdosu2)||ifc(cmdosoth>'',": ",'')||cmdosoth;
	cmroute=strip(cmdosu2)||ifc(cmrtoth>'',": ",'')||cmrtoth;
	cmfreq=strip(cmfreq2)||ifc(cmfreqot>'',": ",'')||cmfreqot;
	*/

	%concatOTHER(var=cmdosu2, oth=cmdosoth, newvar=cmdosu, displayoth=N);
	%concatOTHER(var=cmroute2, oth=cmrtoth, newvar=cmroute, displayoth=N);
	%concatOTHER(var=cmfreq2, oth=cmfreqot, newvar=cmfreq, displayoth=N);



	%ENRF(ongo=cmongo,stopdate=cmendt);

	cmfreq=scan(cmfreq,1,'()');
	cmroute=scan(cmroute,1,'()');
	%any2char(invar=cmdostot,indata=source.cm);
	cmdostotc=_charval;


	* -> Modify Label: ;
	label 
		cmae         =  'Used to#treat an AE?'
		cmdostotc    =  'Dose'
	;
run;

data pdata.cm;
	retain &globalvars2 __crfinsno cmtext cmindc cmdostotc cmdosu  cmroute cmfreq cmstdt cmendt cmae;
	keep   &globalvars2 __crfinsno cmtext cmindc cmdostotc cmdosu  cmroute cmfreq cmstdt cmendt cmae ;
	set cm0;
run;
*----------------------------------------------------------------------------------------------------------->;


*<Surgery Details--------------------------------------------------------------------------------------------------------;
data sd0(keep=subject surinc);
	set source.sd;
	%filter;
	%adjustvalue(dsetlabel=Surgery Details (1));
	%formatDate(visitdt);

	attrib
		enddtm		length=$40		label='Date/Time of endotrachael intubation'
		surstm		length=$40		label='Date/Time Surgery Started'
		sutdtm		length=$40		label='Date/Time of placement of last suture or stap'
		endexdtm	length=$40		label='Date/Time of endotracheal extubation'
	;

	%formatDate(enddt);
	%concatDT(datevar=enddt,timevar=endtm,newvar=enddtm);

	%formatDate(surst);
	%concatDT(datevar=surst,timevar=surtm,newvar=surstm);

	%formatDate(sutdt);
	%concatDT(datevar=sutdt,timevar=suttm,newvar=sutdtm);

	%formatDate(endexdt);
	%concatDT(datevar=endexdt,timevar=endextm,newvar=endexdtm);
run;

data inex0;
	set source.inex;
	%filter;
	%adjustvalue(dsetlabel=Inclusion / Exclusion);
	keep subject scrirb;
run;

proc sort data=sd0; by subject; run;
proc sort data=inex0; by subject; run;

data sd1;
	merge sd0 inex0;
		by subject;
	surinc=coalescec(surinc,scrirb);
	drop scrirb;
run;

data pse0;
	length subject $40 surinc $50;
	if _n_=1 then do;
		declare hash h (dataset:'sd1');
		rc=h.defineKey('subject');
		rc=h.defineData('surinc');
		rc=h.defineDone();
		call missing(subject,surinc);
	end;
	set source.pse;
	%filter;
	%adjustvalue(dsetlabel=Surgery Details);
	%formatDate(visitdt);
	%formatDate(randdt);
	rc=h.find();
run;

data pdata.sd;
	retain &globalvars1 surinc procal postd postl postcol;
	keep   &globalvars1 surinc procal postd postl postcol;
	set pse0;
	label 
		surinc    =    'Was the incision size greater than or equal to 10 cm?'
		procal    =    'Was the planned procedure altered during the surgery?'
		postd     =    'Type of resection performed'
		postl     =    'Location of bowel resection performed'
		postcol   =    'If Large partial bowel resection, was a colostomy reversal performed?'
	;
run;
*------------------------------------------------------------------------------------------------------->;

/*
*<PT--------------------------------------------------------------------------------------------------------;
data pt0;
	set source.pt;
	%filter;
	%adjustvalue(dsetlabel=Pregnancy Testing);
	%formatDate(visitdt);
	%formatDate(spdtc);
	%formatDate(updtc);
run;

data pdata.pt;
	retain &globalvars1 ptsyn ptsrsn ptoth spdtc spres ptuyn ptursn ptoth updtc upres; 
	keep   &globalvars1 ptsyn ptsrsn ptoth spdtc spres ptuyn ptursn ptoth updtc upres;
	set pt0;
run;
*----------------------------------------------------------------------------------------------------------->;
*/



*<PDBM--------------------------------------------------------------------------------------------------------;
data pdbm0;
	set source.pdbm;
	%filter;
	%adjustvalue(dsetlabel=Post Discharge Bowel Movement);
	%formatDate(visitdt);

	attrib
		pdbmdtc		length=$40		label='Date/Time of Post Discharge Bowel Movement'
	;

	%formatDate(pdbmdt);
	%concatDT(datevar=pdbmdt,timevar=pdbmtm,newvar=pdbmdtc);
run;

data pdata.pdbm;
	retain &globalvars1 pdbmyn pdbmdtc;
	keep   &globalvars1 pdbmyn pdbmdtc ;
	set pdbm0;
run;
*----------------------------------------------------------------------------------------------------------->;


/*
*<SPT--------------------------------------------------------------------------------------------------------;
data spt0;
	set source.spt;
	%filter;
	%adjustvalue(dsetlabel=Serum Pregnancy Testing);
	%formatDate(visitdt);
	%formatDate(spdtc);
run;

data pdata.spt;
	retain &globalvars1 ptsyn ptsrsn ptoth spdtc spres;
	keep   &globalvars1 ptsyn ptsrsn ptoth spdtc spres;;
	set spt0;
run;
*----------------------------------------------------------------------------------------------------------->;
*/

/*
*<RFD--------------------------------------------------------------------------------------------------------;
data rfd0;
	set source.rfd;
	%filter;
	%adjustvalue(dsetlabel=Readiness for Discharge);
	%formatDate(visitdt);
run;

data pdata.rfd;
	retain &globalvars1 srfd;
	keep   &globalvars1 srfd;
	set rfd0;
run;
*----------------------------------------------------------------------------------------------------------->;
*/


*<DS--------------------------------------------------------------------------------------------------------;
data ds0;
	set source.ds;
	%filter;
	%adjustvalue(dsetlabel=Study Completion/Discontinuation);
	%formatDate(dsdtc);
	%formatDate(dscondt);
	label 
		dscondt='Last Contact Date for Lost to follow-up subjects'
	;
run;

data pdata.ds;
	retain  &globalvars2 dscomp dsrsn dsothsp dsdtc dscondt;
	keep    &globalvars2 dscomp dsrsn dsothsp dsdtc dscondt;
	set ds0;
run;

*----------------------------------------------------------------------------------------------------------->;



**************************Appendix**********************************************;
* ---> Appendix 1: Visit Name Abbreviation;

data pdata.visitidx;
    length visit visit2 $40;
    visit='Adverse Events';visit2='Adverse Events';output;
    visit='Screening Visit (V1A)';visit2='Screening Visit (V1A)';output;
    visit='Post-Op Day 1 (V2)';visit2='Post-Op Day 1 (V2)';output;
    visit='Post-Op Day 2 (V3)';visit2='Post-Op Day 2 (V3)';output;
    visit='Post-Op Day 4 (V5)';visit2='Post-Op Day 4 (V5)';output;
    visit='Post-Op Day 5 (V6)';visit2='Post-Op Day 5 (V6)';output;
    visit='Post-Op Day 6 (V7)';visit2='Post-Op Day 6 (V7)';output;
    visit='Post-Op Day 7 (V8)';visit2='Post-Op Day 7 (V8)';output;
    visit='Post-Op Day 8 - Visit Optional A (VOA)';visit2='Post-Op Day 8 - VOA';output;
    visit='Outpatient/14 Day Follow-up (V101)';visit2='Outpatient/14 Day FU';output;
    visit='Unscheduled';visit2='Unscheduled';output;
    visit='Unscheduled 2';visit2='Unscheduled 2';output;
    visit='Concomitant Medications';visit2='Con. Medications';output;
    visit='Study Completion/Discontinuation';visit2='Study Comp. / Discont.';output;
    visit='Hospitalization Summary (V100)';visit2='Hosp. Summary';output;
    visit='Post Procedure (V1C)';visit2='Post Procedure (V1C)';output;
    visit='Post-Op Day 3 (V4)';visit2='Post-Op Day 3 (V4)';output;
    visit='Hospital Admission (V1B)';visit2='Hospital Admission';output;
    visit='Post-Op Day 9 - Visit Optional B (VOB)';visit2='Post-Op Day 9 - VOB';output;
    visit='Post-Op Day 10 - Visit Optional C (VOC)';visit2='Post-Op Day 10 - VOC';output;
    visit='Study Drug Administration';visit2='Study Drug Admin.';output;
run;

* -> Chemistry Comments;
data pdata.cmtchem;
	set source.cltc;
	%adjustvalue(dsetlabel=Chemistry);
	where lbccomm>'';
	keep subject visitn visitnum lbctests lbccomm;
run;

* -> Hematology Comments;
data pdata.cmthema;
	set source.clth;
	%adjustvalue(dsetlabel=Hematology);
	where lbhcomm>'';
	keep subject visitn visitnum lbhtests lbhcomm;
run;

* -> Urin Comments;
data pdata.cmturin;
	set source.cltu;
	%adjustvalue(dsetlabel=Urinalysis);
	where lbucomm>'';
	keep subject visitn visitnum lbutests lbucomm;
run;

data pdata.refrange;
	attrib
		item	length=$200		label='Item'
		low		length=8		label='Lower Limit'
		high	length=8		label='Upper Limit'
	;
	item='Systolic BP (mmHg)';        low=&sysbplow;    		high=&sysbphigh;          output;
	item='Diastolic BP (mmHg)';       low=&diabplow;    		high=&diabphigh;          output;
	item='Heart Rate(beats/min)';      low=&hrlow;       		high=&hrhigh;             output;
	item='Temperature(Celsius)'	;	  low=&templow;		 	    high=&temphigh;	          output;
	item='Temperature(Fahrenheit)';	  low=&templow*1.8+32;		high=&temphigh*1.8+32;	  output;
	item='PR Interval (ms)';		  low=&prlow;				high=&prhigh;			  output;
	item='QRS Interval (ms)';		  low=&qrslow;				high=&qrshigh;			  output;
	item='QT Interval (ms)';		  low=&qtlow;				high=&qthigh;			  output;
	item='QTC Interval (ms)';		  low=&qtclow;				high=&qtchigh;			  output;
run;




/*
Addtional Edit Check Programs for Patient Profile

@Author: Ken Cao (yong.cao@q2bi.com)

@Initial Date: 2013/02/26
*/;


*-> Cross check for Meal Procedure/GI Recovery Events/Hospitalizatin Summary;
proc sort data=pdata.mp out=_chkmp0; by subject visitn visitdt __ord; run;

data _tsubj _ntsubj(drop=toldt);
	set _chkmp0;
		by subject visitn visitdt __ord;
	length tflag 8 r_postmt $10;
	format toldt date9.;
	retain r_subject r_visitn r_visitdt r_day r__ord r_postmt toldt tflag; 
	if first.subject then do;
		*initialization;
		r_subject=subject;
		r_visitn=visitn;
		r_visitdt=visitdt;
		r_day=ifn(scan(visitdt,1,'-')>'',input(scan(visitdt,1,'-'),best.),.);
		r__ord=__ord;
		r_postmt=postmt;
		toldt=input(upcase(compress(visitdt,'-')),date9.);
		tflag=0;
	end;
	else do;
		if r_subject=subject and r_visitn=visitn and r_visitdt=visitdt and r__ord+1=__ord
			and r_postmt='Yes' and postmt='Yes' then do;

			tflag=1;
			toldt=input(upcase(compress(visitdt,'-')),date9.);

		end;
		else if r_subject=subject and /*r_day+1=ifn(scan(visitdt,1,'-')>'',input(scan(visitdt,1,'-'),best.),.)*/
		r__ord=3 and __ord=1 and r_postmt='Yes'	and postmt='Yes' then do;
				
			tflag=1;
			toldt=input(upcase(compress(visitdt,'-')),date9.);

		end;

		*replace value with current value;
		r_visitn=visitn;
		r_visitdt=visitdt;
		r_day=ifn(scan(visitdt,1,'-')>'',input(scan(visitdt,1,'-'),best.),.);
		r_postmt=postmt;
		r__ord=__ord;
	end;
	
	keep subject toldt;
	if last.subject and tflag=1 then output _tsubj;
	else if last.subject and tflag=0 then output _ntsubj;
	
run;

data _hstsubj;
	set pdata.hs;
	where index(upcase(allcrt),'FOOD TOLERATION')>0;
	keep subject;
run;

data hs1;
	set pdata.hs;
run;

data pdata_hs0;
	length subject $40 toldt 8;
	if _n_=1 then do;
		declare hash h1 (dataset:"_hstsubj");
		rc1=h1.defineKey('subject');
		rc1=h1.defineDone();
		declare hash h2 (dataset:"_tsubj");
		rc2=h2.defineKey('subject');
		rc2=h2.defineData('toldt');
		rc2=h2.defineDone();
		declare hash h3 (dataset:"_ntsubj");
		rc3=h3.defineKey('subject');
		rc3=h3.defineDone();
		call missing(subject,toldt);
	end;
	set hs1;
	rc1=h1.find();
	rc2=h2.find();
	rc3=h3.find();
	if rc1=0 and rc2>0 then do;
		allcrt=prxchange("s/Food Toleration/^{style [foreground=red textdecoration=line_through]Food Toleration}^{style [foreground=black]}/",-1,allcrt);
	end;
	else if rc1>0 and rc2=0 and input(upcase(compress(visitdt,'-')),date9.)>toldt then do;
		allcrt=strip(allcrt)||ifc(strip(allcrt)>'','; ','')||'^{style [foreground=red textdecoration=underline] Food Toleration}';
	end;
	drop rc1 rc2 rc3 toldt;
	format toldt date9.;
run;

data  _rcvmov(rename=(rcvdt=rcvdt1))  _rcvsounds(rename=(rcvdt=rcvdt2)) _rcvflatus(rename=(rcvdt=rcvdt3));
	set pdata.rcv;
	format rcvdt date9.;
	where index(rcvtp ,'Bowel Sounds')>0 or index(rcvtp ,'Bowel Movement')>0 or index(rcvtp ,'Flatus')>0;
	rcvdt=input(upcase(compress(scan(rcvdtc,1,'T'),'-')),date9.);
	if index(rcvtp ,'Bowel Sounds')>0 then do; rcvtp='Bowel Sounds'; output _rcvsounds; end;
	else if index(rcvtp,'Bowel Movement')>0 then do; rcvtp='Bowel Movement'; output _rcvmov; end;
	else if index(rcvtp,'Flatus')>0 then do; rcvtp='Flatus'; output _rcvflatus; end;
	keep subject rcvdt rcvtp;
run;

proc sort data=_rcvmov; by subject rcvdt1; run;
proc sort data=_rcvmov nodupkey; by subject; run;

proc sort data=_rcvsounds; by subject rcvdt2; run;
proc sort data=_rcvsounds nodupkey; by subject; run;

proc sort data=_rcvflatus; by subject rcvdt3; run;
proc sort data=_rcvflatus nodupkey; by subject; run;


data pdata.hs;
	length subject $40 rcvdt1 rcvdt2 rcvdt3 8;
	if _n_=1 then do;
		declare hash h1 (dataset:'_rcvmov');
		rc1=h1.defineKey("subject");
		rc1=h1.defineData("rcvdt1");
		rc1=h1.defineDone();

		declare hash h2 (dataset:'_rcvsounds');
		rc2=h2.defineKey("subject");
		rc2=h2.defineData("rcvdt2");
		rc2=h2.defineDone();

		declare hash h3 (dataset:'_rcvflatus');
		rc3=h3.defineKey("subject");
		rc3=h3.defineData("rcvdt3");
		rc3=h3.defineDone();

		call missing(subject,rcvdt1,rcvdt2,rcvdt3);
	end;

	set pdata_hs0;

	rc1=h1.find();
	rc2=h2.find();
	rc3=h3.find();
	/*
	format hddt date9.;
	hddt=input(upcase(compress(scan(hddtc,1,'T'),'-')),date9.);
	*/

	visitdt_=input(upcase(compress(scan(visitdt,1,'T'),'-')),date9.);

	if index(upcase(allcrt),'BOWEL MOVEMENT')>0 then do;
		if rc1>0 or visitdt_<rcvdt1 then do;
			allcrt=prxchange("s/Bowel Movement/^{style [foreground=red textdecoration=line_through]Bowel Movement}^{style [foreground=black]}/",-1,allcrt);
		end;
	end;
	else do;
		if rc1=0 and visitdt_>=rcvdt1 then do;
			allcrt=strip(allcrt)||ifc(strip(allcrt)>'','; ','')||'^{style [foreground=red textdecoration=underline]Bowel Movement}';
		end;
	end;

	if index(upcase(allcrt),'BOWEL SOUNDS')>0 then do;
		if rc2>0 or visitdt_<rcvdt2 then do;
			allcrt=prxchange("s/Bowel sounds/^{style [foreground=red textdecoration=line_through]Bowel sounds}^{style [foreground=black]}/",-1,allcrt);
		end;
	end;
	else do;
		if rc2=0 and visitdt_>=rcvdt2 then do;
			allcrt=strip(allcrt)||ifc(strip(allcrt)>'','; ','')||'^{style [foreground=red textdecoration=underline]Bowel sounds}';
		end;
	end;

	if index(upcase(allcrt),'FLATUS')>0 then do;
		if rc3>0 or visitdt_<rcvdt3 then do;
			allcrt=prxchange("s/Flatus/^{style [foreground=red textdecoration=line_through]Flatus}^{style [foreground=black]}/",-1,allcrt);
		end;
	end;
	else do;
		if rc3=0 and visitdt_>=rcvdt3 then do;
			allcrt=strip(allcrt)||ifc(strip(allcrt)>'','; ','')||'^{style [foreground=red textdecoration=underline]Flatus}';
		end;
	end;

	drop rc1-rc3 rcvdt1-rcvdt3 visitdt_;
run;


*Ken on 2013/05/21: Add a figure;
/*
data pdata.figure;
	set pdata.dm;
	keep subject figure;
	length figure $200;
	figure='Q:\WorkSpace\Public\Janus\D1--CY\R203\CY\Applications\Patient Profile\dev\output\Helsinn 202\Graphics';
	figure=strip(figure)||'\'||strip(subject)||'.png';
	figure='^{style [preimage="'||strip(figure)||'"]}';
run;
*/
