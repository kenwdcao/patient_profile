%include '_setup.sas';
data REFRANGE1;
	attrib
		VSTESTCD	length=$8		label='Vital Signs Test Short Name'
		low		length=8		label='Lower Limit'
		high	length=8		label='Upper Limit'
		VSORRESU	length=$40		label='Original Units'
	;
	VSTESTCD='TEMP';	      low=&TEMPLOW;		 	    high=&TEMPHIGH;	        VSORRESU='C';          output;
	VSTESTCD='TEMP';	      low=&TEMPLOW_F;		 	    high=&TEMPHIGH_F;	VSORRESU='F';          output;
	VSTESTCD='PULSE';          low=&HRLOW;       		high=&HRHIGH; 			VSORRESU='BEATS/MIN';            output;
	VSTESTCD='RESP';	    low=&RESPLOW;				high=&RESPHIGH;			VSORRESU='BREATHS/MIN';		  output;
	VSTESTCD='SYSBP';        low=&SYSBPLOW;    		high=&SYSBPHIGH; 			VSORRESU='mmHg';         output;
	VSTESTCD='DIABP';       low=&DIABPLOW;    		high=&DIABPHIGH; 			VSORRESU='mmHg';         output;
run;
data REFRANGE;
	LENGTH LOW HIGH $20;
	SET REFRANGE1(RENAME=(low=low1 high=high1));
	low=strip(put(low1,best.));
	high=strip(put(high1,best.));
	drop low1 high1;
RUN;
data vs;
	length B_VSDTC $19  VSTESTCD $8 LOW HIGH $20 VSORRESU $40 VSSTRESC $200;
	if _n_=1 then do;
		declare hash h (dataset:'REFRANGE');
		rc=h.defineKey('VSTESTCD','VSORRESU');
		rc=h.defineData('low','high');
		rc=h.defineDone();
		call missing(VSTESTCD, VSORRESU, low, high);
	end;
	set source.vs;
	%adjustvalue;
	B_VSDTC=strip(VSDTC);
	rc=h.find();
	%notInLowHigh(orres=VSORRES,low=low,high=high,stresc=VSSTRESC);
	if VSTEST='Weight' or VSTEST='Height' then do;__color='';VSSTRESC=strip(__orresc);end;
	if VSSTAT='NOT DONE' then VSSTRESC='Not Done';
/*	TEST=strip(put(VSTEST,$VSTEST.))||'('||strip(VSORRESU)||')';*/
	drop  STUDYID DOMAIN USUBJID SITEID VSDY;
run;
proc sql;
	create table vs_unit as
	select *, count(VSORRESU) as n
	from vs
	group by SUBJID, VSTESTCD, VSORRESU
	;
quit;
proc sort data=vs_unit out=vs_unit1 nodupkey;by SUBJID VSTESTCD VSORRESU n;run;
proc sort data=vs_unit1 ;by SUBJID VSTESTCD n;run;
data unit;
	set vs_unit1(rename=(VSORRESU=vsstresu));
	by SUBJID VSTESTCD;
	keep SUBJID VSTESTCD vsstresu;
	if last.VSTESTCD;
run;
proc sql;
	 create table vs1 as
	 select a.*,b.vsstresu
	 from (select * from vs) as a
	    left join
	    (select * from unit) as b 
	 on a.SUBJID = b.SUBJID and a.VSTESTCD = b.VSTESTCD;
quit;
data vs1_;
	length TEST visitall $100;
	set vs1;
	if vsstresu^='' then TEST=strip(put(VSTEST,$VSTEST.))||'#<'||strip(vsstresu)||'>';
		else TEST=strip(put(VSTEST,$VSTEST.));
	if VSORRESU=vsstresu then VSSTRESC=strip(VSSTRESC);
	else if VSORRESU^=vsstresu and VSSTRESC^='Not Done' then  VSSTRESC=strip(VSSTRESC)||' '||strip(VSORRESU);
	else if VSORRESU^=vsstresu and VSSTRESC='Not Done' then  VSSTRESC=strip(VSSTRESC);
/*	if A_VISIT='Unscheduled' then VNUM='v_99'||strip(vsseq);*/
	visitall=strip(A_VISIT)||'#'||strip(B_VSDTC);
	if (A_VISIT^='Unscheduled' and VSSTRESC^='') or (A_VISIT='Unscheduled' and VSSTRESC^='' and VSSTRESC^='Not Done') ;
run;
proc sort data=vs1_ out=s_vs; by SUBJID visitall; run;
proc transpose data=s_vs out=t_vs1(where=(HEIGHT^=''));
	by SUBJID visitall; 
	id VSTESTCD;
	var TEST ;
run;
proc transpose data=s_vs out=t_vs2;
	by SUBJID visitall; 
	id VSTESTCD;
	var VSSTRESC ;
run;
data t_vs1_;
	length DIABP PULSE RESP	SYSBP TEMP WEIGHT HEIGHT $200;
	set  t_vs1;
	format DIABP PULSE RESP	SYSBP TEMP WEIGHT HEIGHT $200.;
	visitall='Label';
	_NAME_='A_TEST';
run;
data t_vs;
	length visit $40 vsdtc $19;
	set  t_vs1_ t_vs2;
	visit=strip(scan(visitall,1,'#'));
	vsdtc=strip(scan(visitall,2,'#'));
	__vnum=input(visit,VNUM.);
	if _NAME_='A_TEST' then do;visit='Visit';vsdtc='Date of Assessment';end;
	rename _NAME_=__NAME;
run;
proc sort data=t_vs; by SUBJID  __NAME __vnum; run;
data pdata.vs(label='Vital Signs');
	retain SUBJID visit vsdtc SYSBP DIABP TEMP PULSE RESP WEIGHT HEIGHT __vnum;
	keep SUBJID visit vsdtc SYSBP DIABP TEMP PULSE RESP WEIGHT HEIGHT __vnum;
	set t_vs;
run;
