
*--->Magic Numbers (Normal Range);
%let SYSBPLOW=90;
%let SYSBPHIGH=140;
%let DIABPLOW=50;
%let DIABPHIGH=90;
%let HRLOW=50;
%let HRHIGH=100;
%let TEMPLOW_F=95.9;
%let TEMPHIGH_F=100.04;
%let TEMPLOW=35.5;
%let TEMPHIGH=37.8;
%let RESPLOW=12;
%let RESPHIGH=18;
%let PRLOW=120;
%let PRHIGH=200;
%let QRSLOW=60;
%let QRSHIGH=109;
%let QTLOW=320;
%let QTHIGH=450;
%let QTCFLOW=320;
%let QTCFHIGH=450;
**************************************;

%macro adjustvalue;
	length VNUM $10 A_VISIT $40;
	label 
			A_VISIT='Visit';
	A_VISIT=put(VISIT,$visit.);
	VNUM=put(VISIT,$VNUM.);
%mend adjustvalue;

%macro adjustvalue1;
	length VNUM $10 A_VISIT $40;
	label 
			A_VISIT='Visit';
	A_VISIT=put(VISIT,$vist.);
	VNUM=put(VISIT,$VNUM.);
%mend adjustvalue1;

%macro IsNumeric(InStr=, Result=);
	length __InStr $200;
   &Result = 1;
   __PeriodCount = 0;

   __InStr = trim(left(&InStr));
   if substr(__InStr, 1, 1) in ('-', '+') then __InStr = trim(left(substr(__InStr, 2)));

   do __n = 1 to length(__InStr);
      if substr(__InStr, __n, 1) not in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.') 
		then &Result = 0;
      if substr(__InStr, __n, 1) = '.' then __PeriodCount = __PeriodCount + 1;
   end;
   if __PeriodCount > 1 then &Result = 0;
%mend IsNumeric;

%macro notInLowHigh(orres=,low=,high=,stresc=);
	%local i;
	%local var1 var2 var3;
	%local nvar1 nvar2 nvar3;

 	length __orres __low __high 8 __orresc $200 __color $40;
	call missing(__orres, __low, __high,  __orresc, __color);
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
	__orresc=ifc(__orres=.,'',strip(put(__orres,best.)));
	if not(__low<=__orres<=__high) and n(__low,__high)>0 and __orres>. then do;
		if __orres<__low then __color="&belowcolor";
		else if __orres>__high then __color="&abovecolor";
	end;
	else if n(__low,__high)=0 and __orres>. then do;
		__color="&norangecolor";
	end;
	if __color>'' then &stresc='^{style [foreground='||strip(__color)||']'||strip(__orresc)||'}';
	else &stresc=strip(__orresc);
%mend notInLowHigh;

%macro getVisitLabel;
	%local allname;
	%local alllabel;
	%local i;

	data _null_;
		set __prt(obs=1);
		array var{*} $ _character_;
		length allname $1024 alllabel $2048;
		call missing(allname,alllabel);
		do i=1 to dim(var);
			allname=strip(allname)||ifc(allname='','','@')||vname(var[i]);
			alllabel=strip(alllabel)||ifc(alllabel='','','@')||ifc(var[i]='','.',var[i]);
		end;
		call symput('allname',strip(allname));
		call symput('alllabel',strip(alllabel));
	run;

	%put &allname;
	%put &alllabel;

	%let cnt=%sysfunc(countc(&allname,@));
	%let cnt=%eval(&cnt+1);

	%put &cnt;

	%do i=1 %to &cnt;
		%local var&i label&i;
		%let var&i=%upcase(%scan(&allname,&i,@));
		%let label&i=%scan(%bquote(&alllabel),&i,@);
		%let label&i=%sysfunc(strip(%bquote(&&label&i)));
	%end;

	data __prt;
		set __prt(firstobs=2);
		%do i=1 %to &cnt;
			%put &&label&i;
			%if "&&label&i"^="." %then
			%do;
/*				%if %index(%bquote(&&label&i),UNS)>0 %then %LET label&i=Unscheduled;*/
				label &&var&i = "&&label&i";
			%end;
			%else
			%do;
				%if %index(&&var&i,D)>0 %then
				%do;
					drop &&var&i;
				%end;
				%else 
				%do;
					label &&var&i = "&escapechar{style [foreground=white]i}";
				%end;
			%end;			
		%end;
	run;
%mend getVisitLabel;

%macro nullcolumn;
	data __prt;
		set __prt;
			label 
				v_910 = " "
				v_920 = " "
			;
		v_910='';
		v_920='';
	run;
%mend nullcolumn;

%macro adjustVisitVarOrder(indata=,othvars=);
	%local visitvarnamelist;

	*get all visit variable names into dataset;
	proc contents data=&indata 
		out=_visitvarnamelist(keep=name where=(upcase(name) like 'V_%'))
		noprint;
	run;

	*sort visit variables in based on visitnum;
	proc sort data=_visitvarnamelist sortseq=linguistic(numeric_collation=on);
		by name;
	run;

	*get all visit variable names into macro variable;
	data _null_;
		set _visitvarnamelist end=_eof_;
		retain visitvarnamelist;
		length visitvarnamelist $512;
		if _n_=1 then visitvarnamelist=name;
		else visitvarnamelist=strip(visitvarnamelist)||' '||name;
		if _eof_ then
		do;
			call symput('visitvarnamelist',strip(visitvarnamelist));
		end;
	run;

	*adjust variable order;
	data &indata;
		retain &othvars &visitvarnamelist;
		keep   &othvars &visitvarnamelist;
		set &indata;
	run;

%mend adjustVisitVarOrder;

/*
	For KLT studies only.;
	VISITNUM should be included in dataset &indata before call this macro. VSIITNUM should reflect chronogical order 
	of each visit except for unscheduled visits;
*/
%macro getvisitnum(indata=,indtc=,out=);

	proc sql;
		create table _visit0 as
		select distinct subjid,visit,visitnum,&indtc
		from &indata
		where &indtc>''
		order by subjid,&indtc,visitnum,visit;
	quit;

	data _visit;
		set _visit0;
			by subjid;
		length dtc $20;
		retain vnum unseq dtc;
		if first.subjid and visitnum^=-1 then put "ERR" "OR:" subjid= +3;
		else if first.subjid then
		do;
			vnum=visitnum;
			unseq=0;
			dtc=&indtc;
		end;
		else do;
			if visitnum^=99  then 
			do;
				vnum=visitnum;
				dtc=&indtc;
				unseq=0;
			end;
			else
			do;
				if dtc^=&indtc then
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

	proc sort data=&indata; by subjid visit &indtc; run;
	proc sort data=_visit;  by subjid visit &indtc; run;

	data &out;
		merge &indata(rename=visitnum=old_visitnum) _visit(keep=subjid visit &indtc visitnum);
			by subjid visit &indtc;
		visitnum=coalesce(visitnum,old_visitnum);
		drop old_visitnum;
	run;

%mend getvisitnum;

/*
	For KLT Study Only.
*/
%macro getinShape(indata=,indtc=,testvar=,resultvar=,out=);
	proc sort data=&indata out=_frame0 nodupkey; by subjid visitnum visit2; run;

	proc transpose data=_frame0 out=_frame1(drop=_name_);
		by subjid;
		id visit2;
		idlabel visit;
		var visit;
	run;

	proc transpose data=_frame0 out=_frame2(drop=_name_);
		by subjid;
		id visit2;
		idlabel visit;
		var &indtc;
	run;

	data frame;
		set _frame1(in=a) _frame2(in=b);
			by subjid;
		if a then __ord=1;
		else if b then __ord=2;
		array vst{*} V_:;
		do i=1 to dim(vst);
			if __ord=1 then vst[i]=propcase(vst[i]);
		end;
		drop i;
	run;

	proc sort data=&indata; by subjid &testvar visit2 ; run;
	proc transpose data=&indata out=_result(drop=_name_);
		by subjid &testvar;
		id visit2;
		idlabel visit;
		var &resultvar;
	run;

	data &out;
		set frame _result(in=c);
			by subjid;
		if c then __ord=3;
	run;

%mend getinShape;
