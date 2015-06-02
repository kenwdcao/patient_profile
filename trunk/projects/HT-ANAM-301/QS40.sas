%include '_setup.sas';

*<qs40--------------------------------------------------------------------------------------------------------;

%getVNUM(indata=source.RD_FRMFAACT, out=RD_FRMFAACT);

data qs001;
	set RD_FRMFAACT(rename=(ITMFAACTNDAENUM=_ITMFAACTNDAENUM ITMFAACTASSESS=_ITMFAACTASSESS));
	%adjustvalue1(dsetlabel=Quality of Life - FAACT);
	%formatDate(ITMFAACTPERFDT_DTS); %informatDate(DOV);
*-> Modify Variable Label;
attrib
	ASSESS    label='Assessment Date'   length=$200
	ITMFAACTC6        label='I have a good appetite'
	ITMFAACTACT1      label='The amount I eat is sufficient to meet my needs'
	ITMFAACTACT2      label='I am worried about my weight'
	ITMFAACTACT3      label='Most food tastes unpleasant to me'
	ITMFAACTACT4      label='I am concerned about how thin I look'
	ITMFAACTACT6      label='My interest in food drops as soon as I try to eat'
	ITMFAACTACT7      label='I have difficulty eating rich or "heavy" foods'
	ITMFAACTACT9      label='My family or friends are pressuring me to eat'
	ITMFAACTO2        label='I have been vomiting'
	ITMFAACTACT10     label='When I eat, I seem to get full quickly'
	ITMFAACTACT11     label='I have pain in my stomach area'
	ITMFAACTACT13     label='My general health is improving'
	A_DOV			  label='Visit Date'
	; 
ITMFAACTNDAENUM=ifc(_ITMFAACTNDAENUM=.,'',put(_ITMFAACTNDAENUM,best.));

if ITMFAACTPERFDT_DTS ^='' then ASSESS=ITMFAACTPERFDT_DTS;
else if ITMFAACTNDRSN^='' and ITMFAACTNDOTHSPC ^='' then ASSESS=strip(scan(ITMFAACTNDRSN,1,','))||': '||strip(ITMFAACTNDOTHSPC);
else if ITMFAACTNDRSN^='' and ITMFAACTNDAENUM ^='' then ASSESS=strip(scan(ITMFAACTNDRSN,1,','))||': '||strip(ITMFAACTNDAENUM);
else ASSESS=ITMFAACTNDRSN;

VISITMNEMONIC=put(VISITMNEMONIC,$qsvisit.);

IF strip(ITMFAACTASSESS_C)='DONE';
B='';
keep B SUBJECTNUMBERSTR visitnum VISITMNEMONIC dov A_DOV  ASSESS  FORMMNEMONIC ITMFAACTC6 ITMFAACTACT1 
	ITMFAACTACT2 ITMFAACTACT3 ITMFAACTACT4 ITMFAACTACT6 ITMFAACTACT7 ITMFAACTACT9 ITMFAACTO2 
	ITMFAACTACT10 ITMFAACTACT11 ITMFAACTACT13 ;

RUN; 

proc sort data=qs001 out=s_qs001 nodupkey; 
	by  SUBJECTNUMBERSTR visitnum VISITMNEMONIC dov  A_DOV ASSESS;
run;

data s_qs001_;
	set s_qs001;
	rename VISITMNEMONIC=A_VISITMNEMONIC A_DOV=B_DOV ASSESS=C_ASSESS;
RUN;

proc transpose data=s_qs001_ out=t_qs001;
	by SUBJECTNUMBERSTR B;
	id visitnum;
	var A_VISITMNEMONIC B_DOV C_ASSESS ITMFAACTC6 ITMFAACTACT1 ITMFAACTACT2 ITMFAACTACT3 ITMFAACTACT4
		ITMFAACTACT6 ITMFAACTACT7 ITMFAACTACT9 ITMFAACTO2 ITMFAACTACT10 ITMFAACTACT11 ITMFAACTACT13;
run;

data qs004;
	set t_qs001(rename=(_name_=__name _label_=qstest));
	if __name='A_VISITMNEMONIC' or __name='B_DOV' or __name='C_ASSESS' then __n=0;
	else __n=input(qstest,ord.);
	if __name ^='B_DOV' and __name ^='C_ASSESS';
run;


data qs005 qs006;
	set qs004;
	if __n <=6 then output qs005;
	if __n=0 or __n>6 then output qs006;
run;


data qs005_;
	set qs005;
	if __name='A_VISITMNEMONIC' then qstest='Question';
RUN; 

data qs006_;
	length __label $200;
	set qs006(rename=(__N=__N1));
	if __name='A_VISITMNEMONIC' then qstest='Question';
	if __N1=0 then __N=0;else __N=__N1-6;
	__label="Quality of Life - FAACT ^{newline 2}^{style[fontsize=7pt foreground=green]NOTE: 0=Not at all, "
	||"1=A little bit, 2=Some-what, 3=Quite a bit, 4=Very much}";
	rename qstest=qstest_ _1=_1_ _3=_3_ _6=_6_ _9=_9_ _12=_12_ ;
run;

data pdata.qs40(label='Quality of Life - FAACT');
	retain __label SUBJECTNUMBERSTR qstest  _1  _3 _6  _9 _12 B QSTEST_ _1_  _3_ _6_  _9_ _12_;
	keep __label SUBJECTNUMBERSTR qstest  _1  _3 _6  _9 _12 B QSTEST_ _1_  _3_ _6_  _9_ _12_;
	merge qs005_ qs006_;
	by SUBJECTNUMBERSTR __n;
run;
