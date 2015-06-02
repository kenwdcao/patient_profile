
/*
	Program Name: VS.sas
		@Author: Ken Cao (yong.cao@q2bi.com)
		@Initial Date: 2013/05/08

	**************************************
	For VS dataset of KLT.
	**************************************
*/

%include '_setup.sas';

proc format;
	invalue vsvnum
		SCREENING                 =   -1
		MONTH 0                   =   0
		MONTH 3                   =   3
		MONTH 6                   =   6
		MONTH 9                   =   9
		MONTH 12 / EARLY TERM     =   12
		MONTH 15                  =   15
		MONTH 18                  =   18
		UNSCHEDULED               =   99
	;
run;

data vs0;
	keep subjid vstestcd vstest vsorres vsorresu vsstat visitnum visit vsdtc;
	set source.vs(rename=(vsdtc=vsdtc_ visit=visit_));
	where not (vsorres=. and vsstat='' and vsdtc_='') and not (vsstat='NOT DONE' and upcase(visit_)='UNSCHEDULED');
	length vsdtc visit $200;
	vsdtc=vsdtc_;
	visit=visit_;
	*derive a visitnum;
	visitnum=input(upcase(visit),vsvnum.);
	*in case of MONTH XX not in informat lbvnum;
	if visitnum=. and index(visit,'MONTH')=1 then visitnum=input(strip(scan(visit,2," ")),best.);
	*concat DY and DTC;
	if vsdy>. then vsdtc=strip(vsdtc)||' ('||strip(put(vsdy,10.0))||')';
run;


%getvisitnum(indata=vs0,indtc=vsdtc,out=vs1);

data vs2;
	set vs1;
	length visit2 $200;
	if upcase(visit)='SCREENING' then visit2='V__0';
	else visit2='V_'||strip(put(visitnum*10,3.0));
	if int(visitnum)^=visitnum then visit2=strip(visit2)||'_D';
run;

*vital signs range;
data vsrange;
	attrib
		VSTESTCD	length=$8		label='Vital Signs Test Short Name'
		low		    length=8		label='Lower Limit'
		high	    length=8		label='Upper Limit'
		VSORRESU	length=$40		label='Original Units'
	;
	VSTESTCD='TEMP';	     low=&TEMPLOW;		 	high=&TEMPHIGH;	        VSORRESU='C';           output;
	VSTESTCD='TEMP';	     low=&TEMPLOW_F;		high=&TEMPHIGH_F;	    VSORRESU='F';            output;
	VSTESTCD='PULSE';        low=&HRLOW;       		high=&HRHIGH; 			VSORRESU='BEATS/MIN';    output;
	VSTESTCD='RESP';	     low=&RESPLOW;			high=&RESPHIGH;			VSORRESU='BREATHS/MIN';	 output;
	VSTESTCD='SYSBP';        low=&SYSBPLOW;    		high=&SYSBPHIGH; 		VSORRESU='mmHg';         output;
	VSTESTCD='DIABP';        low=&DIABPLOW;    		high=&DIABPHIGH; 		VSORRESU='mmHg';         output;
run;

data vsrange2;
	set vsrange;
	length range $200;
	range=put(low,5.1)||' - '||put(high,5.1);
run;

proc sql;
	create table vs3 as
	select a.*, low, high, range
	from vs2 as a left join vsrange2 as b
	on a.vstestcd=b.vstestcd and upcase(a.vsorresu)=upcase(b.vsorresu);
;
quit;

data vs4;
	set vs3;
	length vsresult $200;
	if .<vsorres<low then vsresult="^{style [foreground=&belowcolor]"||strip(put(vsorres,best.))||'}'; 
	else if vsorres>high>. then vsresult="^{style [foreground=&abovecolor]"||strip(put(vsorres,best.))||'}';
	else vsresult=ifc(vsorres>.,strip(put(vsorres,best.)),'');
run;

data vs5 vs6;
	set vs4;
	if vstestcd in ('DIABP','SYSBP') then output vs5;
	else output vs6;
run;

proc sort data=vs5; by subjid visitnum vsdtc descending vstestcd; run;

data vs5_1(drop=diap);
	set vs5;
		by subjid visitnum vsdtc;
	length diap bprange $200 ;
	retain diap bprange ;
	if first.vsdtc then 
	do;
		diap=vsresult;
		bprange=range;
	end;
	else 
	do;
		diap=strip(diap)||' / '||strip(vsresult);
		bprange=strip(bprange)||' /^{newline}'||strip(range);
	end;
	if compress(diap)='/' then diap='';
	if last.vsdtc then 
	do;
		vsresult=diap;
		range=bprange;
		vstestcd='BP';
		vstest='Blood Pressure';
		output;
	end;
run;

data vs7;
	set vs5_1 vs6;
	drop low high vsorres;
	if vsstat>'' and strip(vsresult)='' then vsresult=vsstat;
run;

proc sql;
	create table _unit0 as
	select distinct subjid,vstestcd,vsorresu, count(vsorresu) as nunit
	from vs7
	group by subjid,vstestcd
	;
	create table _unit as
	select distinct subjid,vstestcd,vsorresu as fvsorresu
	from _unit0
	group by subjid,vstestcd
	having nunit=max(nunit);
quit;

proc sort data=_unit; by subjid vstestcd descending fvsorresu; run;
proc sort data=_unit nodupkey; by subjid vstestcd; run;
	
proc sort data=vs7; by subjid vstestcd; run;

data vs8;
	merge vs7 _unit;
		by subjid vstestcd;
	if fvsorresu>'' then vstest=strip(vstest)||' ('||strip(fvsorresu)||')';
	if vsorresu^=fvsorresu then vsresult=vsresult||' '||vsorresu;
run;

%getinShape(indata=vs8,indtc=vsdtc, testvar=vstest, resultvar=vsresult, out=vs9);

proc sort data=vs8 out=_range; by subjid vstest descending range; run;
proc sort data=_range nodupkey; by subjid vstest; run;

proc sort data=vs9; by subjid vstest; run;
data vs10;
	merge vs9(in=a) _range;
		by subjid vstest;
	if a;
run;
%adjustVisitVarOrder(indata=vs10,othvars=SUBJID VSTEST range __ord);
data pdata.vs(label='Vital Signs');
	keep subjid vstest range V_:;
	set vs10;
	if __ord=1 then range='Range';
	else if __ord=2 then vstest='Date Performed (Study Day)';
run;
