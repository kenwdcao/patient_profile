
/*
	Program Name: LB.sas
		@Author: Ken cao (yong.cao@q2bi.com)
		@Initial Date: 2013/05/07

	*************************************************************************************************
	This program deals with eDT lab data. Input datasets will be split into 3 datasets based on lab
	category. All lab test will be tranposed to be variables.
	
	Note: 1. Lab result unit is missing for now. Once unit is back, program needs to be revised so
			  that unit can be added to column label.
		  2. In case of multiple test result for single lab test with a visit, mulitple results were
	         wrapped into single value. 
	*************************************************************************************************
*/
%include '_setup.sas';

%let labedt=POI_715_Laboratory_Data_130318;


%macro IsNumeric(InStr=, Result=);
	length __InStr $200;
   &Result = 1;
   __PeriodCount = 0;

   __InStr = trim(left(&InStr));
   if substr(__InStr, 1, 1) in ('-', '+') then __InStr = trim(left(substr(__InStr, 2)));

   do __n = 1 to length(__InStr);
      if substr(__InStr, __n, 1) not in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.') then
	     &Result = 0;
      if substr(__InStr, __n, 1) = '.' then __PeriodCount = __PeriodCount + 1;
   end;
   if __PeriodCount > 1 then &Result = 0;
%mend IsNumeric;


proc format;
	invalue lbvnum
		SCREENING    =  -1
		MONTH 0      =  0
		MONTH 3      =  3
		MONTH 6      =  6
		MONTH 9      =  9
		MONTH 12     =  12
		MONTH 14     =  14
		MONTH 15     =  15
		UNSCHEDULED  =  99
		EARLY TERM   =  98
	;
run;
	

data lbedt0;
	set source.&labedt(rename=(lborres=lborres_ visit=visit_ lbfast=lbfast_));
	length lborres visit lbfast $200;
	keep subjid lbcat lbtestcd lbtest lborres lbornrlo lbornrhi lbdtc visit visitnum lbfast range;
	lborres=lborres_;
	visit=visit_;
	lbfast=lbfast_;
	length range $200;
	range=strip(lbornrlo)||' - '||strip(lbornrhi);
	if compress(range)='-' then range='';;
	*filter some records;
	where upcase(lborres_)^='CANCELLED' and not (lborres_='' and lbdtc='');
	visit=upcase(visit);
	length _lbdate $10 _lbtime $5;
	_lbdate=compress(scan(lbdtc,1," "),'/');
	_lbdate=ifc(length(_lbdate)=9, put(input(_lbdate,date9.),yymmdd10.),'');
	_lbtime=scan(lbdtc,2," ");
	lbdtc=strip(_lbdate)||'T'||strip(_lbtime);
	drop _lbdate _lbtime;
	*derive a visitnum;
	visitnum=input(visit,lbvnum.);
	*in case of MONTH XX not in informat lbvnum;
	if visitnum=. and index(visit,'MONTH')=1 then visitnum=input(strip(scan(visit,2," ")),best.);
	*for lab result with normal range;
	_nrlow=ifn(lbornrlo>'',input(lbornrlo,best.),.);
	_nrhigh=ifn(lbornrhi>'',input(lbornrhi,best.),1E99);
	__result=0;
	%IsNumeric(Instr=lborres,Result=__result);
	if __result=1 then 	_result=input(lborres,best.);
	if .<_result<_nrlow and lborres>'' then lborres="^{style [foreground=&belowcolor]"||strip(lborres)||'}';
	else if _result>_nrhigh then lborres="^{style [foreground=&abovecolor]"||strip(lborres)||'}';
	else if _nrlow=. and _nrhigh=1E99 then lborres="^{style [foreground=&norangecolor]"||strip(lborres)||'}';
run;

*get distinct subjid/visit/date;
proc sql;
	create table _lbdate0 as
	select distinct subjid,visit,visitnum, lbdtc
	from lbedt0
	order by subjid,lbdtc,visit;
quit;

data _lbdate1;
	set _lbdate0;
		by subjid;
	length dtc $20;
	retain vnum unseq dtc;
	if first.subjid and visitnum^=-1 then put "ERR" "OR:" subjid= +3;
	else if first.subjid then
	do;
		vnum=visitnum;
		unseq=0;
		dtc=lbdtc;
	end;
	else do;
		if visitnum^=99  then 
		do;
			vnum=visitnum;
			dtc=lbdtc;
			unseq=0;
		end;
		else
		do;
			if dtc^=lbdtc then
			do;
				unseq=unseq+1;
				if unseq>=10 then put "ERR" "OR: Sequence Number of Unscheduled Visit for Subject " subjid "exceeds 10";
				visitnum=vnum+unseq*0.1;
				vnum=visitnum;
			end;
			else
			do;
				visitnum=vnum;
			end;
		end;
	end;
run;

proc sort data=lbedt0; by subjid visit lbdtc; run;
proc sort data=_lbdate1; by subjid visit lbdtc; run;

*get new visitnum, unscheduled visit sorted;
data lbedt1;
	merge lbedt0(drop=visitnum) _lbdate1(keep=subjid visit lbdtc visitnum);
		by subjid visit lbdtc;
run;

proc sort data=lbedt1; by subjid visitnum lbtest lbdtc; run;

data lbedt2;
	set lbedt1(rename=(lborres=_orres1 lbornrlo=_ornrlo1 lbornrhi=_ornrhi1 lbdtc=_dtc1 lbfast=_fast1 range=_range1));
		by subjid visitnum lbtest _dtc1;
	length _orres _ornrlo _ornrhi $40 _dtc $19 _fast $10 _range $200;
	length lborres $200 lbornrlo lbornrhi $100 lbdtc $200 lbfast $40 range $200;
	lborres  =  _orres1;
	lbornrlo =  _ornrlo1;
	lbornrhi =  _ornrhi1;
	lbdtc    =  _dtc1;
	lbfast   =  _fast1;
	range    =  _range1;
	retain _orres _ornrlo _ornrhi _dtc _fast _range;
	if first.lbtest then
	do;
		_orres  =  lborres;
		_ornrlo  =  lbornrlo;
		_ornrhi  =  lbornrhi;
		_dtc     =  lbdtc;
		_fast    =  lbfast;
		_range   =  range;
	end;
	else if last.lbtest and not first.lbtest then
	do;
		lborres  =  strip(_orres)||'^{newline} '||strip(lborres);
		lbornrlo =  strip(_ornrlo)||'^{newline} '||strip(lbornrlo);
		lbornrhi =  strip(_ornrhi)||'^{newline} '||strip(lbornrhi);
		lbdtc    =  strip(_dtc)||'^{newline} '||strip(lbdtc);
		lbfast   =  strip(_fast)||'^{newline} '||strip(lbfast);
		range  =  strip(_range)||'^{newline} '||strip(range);
	end;

	if first.lbtest and last.lbtest then output;
	else if last.lbtest then output;
	drop _:;
run;	

proc sort data=lbedt2; by subjid lbcat visitnum lbdtc  lbtestcd; run;

data lbbi lbcbc lbschem;
	set lbedt2;
	length visit2 $40;
	if visit='SCREENING' then visit2='V__0';
	else visit2='V_'||strip(put(visitnum*10,3.0));
	if int(visitnum)^=visitnum then visit2=strip(visit2)||'D';
	*Ken on 2013/05/08: Remove Time;	
	lbdtc=scan(lbdtc,1,'T');
	if lbcat='Biomarkers' then output lbbi;
	else if lbcat='CBC w/Differential' then output lbcbc;
	else if lbcat='Serum Chemistry' then output lbschem;
run;


%macro transposeLB(lb,out);
	
	proc sort data=&lb out=_frame0 nodupkey; by subjid visitnum visit2; run;
	proc transpose data=_frame0 out=_frame1(drop=_name_);
		by subjid;
		id visit2;
		idlabel visit;
		var lbdtc;
	run;

	proc transpose data=_frame0 out=_frame2(drop=_name_);
		by subjid;
		id visit2;
		idlabel visit;
		var visit;
	run;

	proc transpose data=_frame0 out=_fast(drop=_name_);
		by subjid;
		id visit2;
		idlabel visit;
		var lbfast;
	run;
	
	data _frame;
		set _frame2(in=a) _frame1(in=b) _fast(in=c) ;
		by subjid;
		if a then __ord=1;
		else if b then __ord=2;
		else __ord=3; 
		array vst{*} V_:;
		do i=1 to dim(vst);
			if __ord=1 then	vst[i]=propcase(vst[i]);
			else if __ord=3 then vst[i]=propcase(vst[i]);
		end;
	run;


	proc sort data=&lb out=_result0; by subjid lbtest visitnum; run;
	proc transpose data=_result0 out=_result(drop=_name_);
		by subjid lbtest;
		id visit2;
		idlabel visit;
		var lborres;
	run;

	data _result;
		set _result;
		__ord=4;
	run;

	proc sort data=&lb out=_range(keep=subjid lbtest range) nodupkey; by subjid lbtest; run;

	data _pre0;
		set _frame _result;
		by subjid __ord;
	run;

	data _pre1;
		merge _pre0 _range;
			by subjid lbtest ;
	run;

	data &out;
		set _pre1;
		if __ord=1 then range='Range';
		else if __ord=2 then lbtest='Sample Collection Date';
		else if __ord=3 then lbtest='Fast Status';
	run;
	
%mend transposeLB;


%transposeLB(lbbi,lbbi_);
%transposeLB(lbcbc,lbcbc_);
%transposeLB(lbschem,lbschem_);

%adjustVisitVarOrder(indata=lbbi_,othvars=SUBJID LBTEST range);
data pdata.lbbi(label='Biomarkers Results');
	set lbbi_;
run;
%adjustVisitVarOrder(indata=lbcbc_,othvars=SUBJID LBTEST range);
data pdata.lbcbc(label='CBC w/ Differential Results');
	set lbcbc_;
run;
%adjustVisitVarOrder(indata=lbschem_,othvars=SUBJID LBTEST range);
data pdata.lbschem(label='Serum Chemistry Results');
	set lbschem_;
run;




