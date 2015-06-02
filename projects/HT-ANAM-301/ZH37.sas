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

data zh0;
	set source.RD_FRMHGS(rename=(ITMHGSNDAENUM=_ITMHGSNDAENUM ITMHGSASSESS=_ITMHGSASSESS));
	%adjustvalue(dsetlabel=Hand Grip Strength Test);
	%formatDate(ITMHGSPERFDT_DTS); %informatDate(DOV);
*-> Modify Variable Label;
attrib
	ITMHGSASSESS				label='Assessment Date'    length=$200
	ITMHGSRIGHTMEAS1_			label='Measurement 1'
	ITMHGSRIGHTMEAS2_			label='Measurement 2' 
	ITMHGSRIGHTMEAS3_			label='Measurement 3'
	ITMHGSRIGHTMAX_				label='Max' 
	ITMHGSLEFTMEAS1_			label='Measurement 1'
	ITMHGSLEFTMEAS2_			label='Measurement 2' 
	ITMHGSLEFTMEAS3_			label='Measurement 3'
	ITMHGSLEFTMAX_				label='Max' 
	A_DOV						label='Visit Date'
	;
	%rlme(r=RIGHT,l=LEFT);
	/*%dtsn(dts=ITMHGSPERFDT_DTS, perf=_ITMHGSASSESS, newvar=ITMHGSASSESS);*/
	ITMHGSNDAENUM=ifc(_ITMHGSNDAENUM=.,'',strip(put(_ITMHGSNDAENUM,best.)));
	if ITMHGSPERFDT_DTS ^='' then ITMHGSASSESS=ITMHGSPERFDT_DTS;
	else if ITMHGSNDRSN^='' and ITMHGSNDOTHSPC ^='' 
		then ITMHGSASSESS=strip(scan(ITMHGSNDRSN,1,','))||': '||strip(ITMHGSNDOTHSPC);
	else if ITMHGSNDRSN^='' and ITMHGSNDMECHSPC ^='' 
		then ITMHGSASSESS=strip(scan(ITMHGSNDRSN,1,','))||': '||strip(ITMHGSNDMECHSPC);
	else if ITMHGSNDRSN^='' and ITMHGSNDAENUM ^='' 
		then ITMHGSASSESS=strip(scan(ITMHGSNDRSN,1,','))||': '||strip(ITMHGSNDAENUM);
	else ITMHGSASSESS=ITMHGSNDRSN;
run;

proc sort data=zh0 out=zh0_; by SUBJECTNUMBERSTR __VISITNUM; run;

data zh1;
	set zh0_;
	by SUBJECTNUMBERSTR __VISITNUM;
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
	create table zh1_ as 
	select a.*,b.__n1,b.__n2
	from (select * from zh0) as a
			left join 
          (select * from zh1) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR and a.__VISITNUM=b.__VISITNUM;
quit;
proc sql;
	create table zhpe as 
	select a.*,b.ITMPE1NONDOMHAND
	from (select * from zh1_) as a
			left join 
          (select * from source.RD_FRMPE1) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR;
quit;

data zhpe1;
	length __label $300;
	set zhpe;
	if ITMPE1NONDOMHAND ^="" then __label="Hand Grip Strength Test "||"^{style [foreground=&norangecolor]"
	||"(Non-dominant hand: "||strip(ITMPE1NONDOMHAND)||")"||"}";
		else __label="Hand Grip Strength Test "||"^{style [foreground=&norangecolor]"
	||"(Non-dominant hand: Unknown)"||"}";
RUN;

proc sort data=zhpe1; by SUBJECTNUMBERSTR dov; run;
data pdata.zh37(label='Hand Grip Strength Test');
	retain  &globalvars1  __label ITMHGSASSESS  ITMHGSRIGHTMEAS1_ ITMHGSRIGHTMEAS2_ ITMHGSRIGHTMEAS3_ 
			ITMHGSRIGHTMAX_ ITMHGSLEFTMEAS1_ ITMHGSLEFTMEAS2_ ITMHGSLEFTMEAS3_ ITMHGSLEFTMAX_ __n1 __n2;
	keep    &globalvars1  __label ITMHGSASSESS  ITMHGSRIGHTMEAS1_ ITMHGSRIGHTMEAS2_ ITMHGSRIGHTMEAS3_ 
			ITMHGSRIGHTMAX_ ITMHGSLEFTMEAS1_ ITMHGSLEFTMEAS2_ ITMHGSLEFTMEAS3_ ITMHGSLEFTMAX_ __n1 __n2;
	set zhpe1;
run;
*----------------------------------------------------------------------------------------------------------->;
