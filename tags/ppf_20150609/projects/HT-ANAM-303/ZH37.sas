
%include '_setup.sas';

*<ZH--------------------------------------------------------------------------------------------------------;
%macro mesu(mesu=,newvar=);
	&newvar=ifc(&mesu=.,'',strip(put(&mesu,best.)));
%mend mesu;

%macro rlme(r=,l=);
%do i=1 %to 3;
%mesu(mesu=ITMHGS&r.MEAS&i,newvar=ITMHGS&r.MEAS&i._);
%mesu(mesu=ITMHGS&l.MEAS&i,newvar=ITMHGS&l.MEAS&i._);
%mesu(mesu=ITMHGS&r.MAX,newvar=ITMHGS&r.MAX_);
%mesu(mesu=ITMHGS&l.MAX,newvar=ITMHGS&l.MAX_);
%end;
%mend rlme;

data hgs301;
	set r301.RD_FRMHGS;
run;

data hgs302;
	set r302.RD_FRMHGS;
run;

data hgs0102;
	set hgs301 hgs302;
	if ITMHGSASSESS_C='DONE';
run;

proc sort data=hgs0102 out=s_hgs0102; by SUBJECTNUMBERSTR DOV ITMHGSPERFDT_DTS; run;

data hgs0102_01;
	set s_hgs0102;
	by SUBJECTNUMBERSTR DOV ITMHGSPERFDT_DTS; 
	if last.SUBJECTNUMBERSTR;
run;

data hgs303;
	set source.RD_FRMHGS;
	drop  ITMHGSRIGHTMEAS1_U  ITMHGSRIGHTMEAS2_U  ITMHGSRIGHTMEAS3_U ITMHGSRIGHTMAX_U 
		ITMHGSLEFTMEAS1_U ITMHGSLEFTMEAS2_U ITMHGSLEFTMEAS3_U ITMHGSLEFTMAX_U;
run;

*****************Get the subjects from both in 303,(301+302)****************;
proc sort data=hgs303 out=s_hgs303(keep=SUBJECTNUMBERSTR) nodupkey; by SUBJECTNUMBERSTR; run;

proc sql;
	create table hgs_01 as
	select a.* 
	from hgs0102_01 as a inner join s_hgs303 as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
	;
quit;

data hgs_02;
	set hgs_01;
	visitnum=-5;
	VISITMNEMONIC="Wk-1"||'!{super [2]}';
	drop  ITMHGSRIGHTMEAS1_U  ITMHGSRIGHTMEAS2_U  ITMHGSRIGHTMEAS3_U ITMHGSRIGHTMAX_U 
		ITMHGSLEFTMEAS1_U ITMHGSLEFTMEAS2_U ITMHGSLEFTMEAS3_U ITMHGSLEFTMAX_U;
run;

data hgs_03;
	set hgs303(rename=(ITMHGSNDAENUM=_ITMHGSNDAENUM ITMHGSASSESS=_ITMHGSASSESS))
		hgs_02(rename=(ITMHGSNDAENUM=_ITMHGSNDAENUM ITMHGSASSESS=_ITMHGSASSESS));
	%formatDate(ITMHGSPERFDT_DTS); %informatDate(DOV);
*-> Modify Variable Label;
attrib
	ITMHGSASSESS				label='Assessment Date'    length=$200
	ITMHGSRIGHTMEAS1_			label='Measurement 1' length=$200
	ITMHGSRIGHTMEAS2_			label='Measurement 2' length=$200
	ITMHGSRIGHTMEAS3_			label='Measurement 3' length=$200
	ITMHGSRIGHTMAX_				label='Max'  length=$200
	ITMHGSLEFTMEAS1_			label='Measurement 1' length=$200
	ITMHGSLEFTMEAS2_			label='Measurement 2' length=$200
	ITMHGSLEFTMEAS3_			label='Measurement 3' length=$200
	ITMHGSLEFTMAX_				label='Max'  length=$200
	A_DOV						label='Visit Date' 
	;
%rlme(r=RIGHT,l=LEFT);
/*%dtsn(dts=ITMHGSPERFDT_DTS, perf=_ITMHGSASSESS, newvar=ITMHGSASSESS);*/
ITMHGSNDAENUM=ifc(_ITMHGSNDAENUM=.,'',strip(put(_ITMHGSNDAENUM,best.)));
if ITMHGSPERFDT_DTS ^='' then ITMHGSASSESS=ITMHGSPERFDT_DTS;
else if ITMHGSNDRSN^='' and ITMHGSNDOTHSPC ^='' then ITMHGSASSESS=strip(scan(ITMHGSNDRSN,1,','))||': '||strip(ITMHGSNDOTHSPC);
else if ITMHGSNDRSN^='' and ITMHGSNDMECHSPC ^='' then ITMHGSASSESS=strip(scan(ITMHGSNDRSN,1,','))||': '||strip(ITMHGSNDMECHSPC);
else if ITMHGSNDRSN^='' and ITMHGSNDAENUM ^='' then ITMHGSASSESS=strip(scan(ITMHGSNDRSN,1,','))||': '||strip(ITMHGSNDAENUM);
else ITMHGSASSESS=ITMHGSNDRSN;
run;

proc sort data=hgs_03 out=S_hgs_03; by SUBJECTNUMBERSTR DOV; run;

data hgs_04;
	set S_hgs_03;
	by SUBJECTNUMBERSTR DOV;
	if nmiss(ITMHGSRIGHTMEAS1,ITMHGSRIGHTMEAS2,ITMHGSRIGHTMEAS3)< 3 then
	max1=max(ITMHGSRIGHTMEAS1,ITMHGSRIGHTMEAS2,ITMHGSRIGHTMEAS3);
	if nmiss(ITMHGSLEFTMEAS1,ITMHGSLEFTMEAS2,ITMHGSLEFTMEAS3) < 3 then 
	max2=max(ITMHGSLEFTMEAS1,ITMHGSLEFTMEAS2,ITMHGSLEFTMEAS3);
	attrib
	__n1  length=$10    label="'Right Max Measurement' is true or false"
	__n2  length=$10    label="'Left Max Measurement' is true or false"
	;
	if max1=ITMHGSRIGHTMAX then __n1=''; else __n1='False';
	if max2=ITMHGSLEFTMAX then __n2=''; else __n2='False';
run;

proc sql;
	create table hgs_05 as 
	select a.*,b.__n1,b.__n2,b.max1,b.max2
	from (select * from hgs_03) as a
			left join 
          (select * from hgs_04) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and a.DOV=b.DOV;
quit;

data hgs_06;
	set hgs_05;
	if __n1='False' then ITMHGSRIGHTMAX_="!{style [foreground=&abovecolor textdecoration=line_through]"
	|| strip(ITMHGSRIGHTMAX_)||"}"||' '||"!{style [foreground=&norangecolor] "|| strip(put(max1,best.))||"}";
	if __n2='False' then ITMHGSLEFTMAX_="!{style [foreground=&abovecolor textdecoration=line_through]"
	|| strip(ITMHGSLEFTMAX_)||"}"||' '||"!{style [foreground=&norangecolor] "|| strip(put(max2,best.))||"}";
	rename VISITMNEMONIC=visit;
run;

data pdata.zh37(label='Hand Grip Strength Test');
	retain  SUBJECTNUMBERSTR visit A_DOV  ITMHGSASSESS  ITMHGSRIGHTMEAS1_ ITMHGSRIGHTMEAS2_ ITMHGSRIGHTMEAS3_ ITMHGSRIGHTMAX_ ITMHGSLEFTMEAS1_ ITMHGSLEFTMEAS2_ ITMHGSLEFTMEAS3_ ITMHGSLEFTMAX_ __n1 __n2;
	keep    SUBJECTNUMBERSTR visit A_DOV  ITMHGSASSESS  ITMHGSRIGHTMEAS1_ ITMHGSRIGHTMEAS2_ ITMHGSRIGHTMEAS3_ ITMHGSRIGHTMAX_ ITMHGSLEFTMEAS1_ ITMHGSLEFTMEAS2_ ITMHGSLEFTMEAS3_ ITMHGSLEFTMAX_ __n1 __n2;
	set hgs_06;
	label visit='Visit';
run;
