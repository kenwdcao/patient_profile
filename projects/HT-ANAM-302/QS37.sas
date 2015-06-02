
%include '_setup.sas';

*<qs37--------------------------------------------------------------------------------------------------------;
%getVNUM(indata=source.RD_FRMFACITF, out=RD_FRMFACITF);

data qs01;
	set RD_FRMFACITF(rename=(ITMFACITFNDAENUM=_ITMFACITFNDAENUM ITMFACITFASSESS=_ITMFACITFASSESS));
    %adjustvalue1(dsetlabel=Quality of Life - FACIT-F);
	%formatDate(ITMFACITFPERFDT_DTS); %informatDate(DOV);
	*-> Modify Variable Label;
attrib
	ASSESS				label='Assessment Date'   length=$200
	ITMFACITFGP1                label='I have a lack of energy'
	ITMFACITFGP2                label='I have nausea'
	ITMFACITFGP3                label='Because of my physical condition, I have trouble meeting the needs of my family'
	ITMFACITFGP4                label='I have pain'
	ITMFACITFGP5                label='I am bothered by side effects of treatment'
	ITMFACITFGP6                label='I feel ill'
	ITMFACITFGP7                label='I am forced to spend time in bed'
	ITMFACITFGS1                label='I feel close to my friends'
	ITMFACITFGS2                label='I get emotional support from my family'
	ITMFACITFGS3                label='I get support from my friends'
	ITMFACITFGS4                label='My family has accepted my illness'
	ITMFACITFGS5                label='I am satisfied with family communication about my illness'
	ITMFACITFGS6                label='I feel close to my partner (or the person who is my main support)'
	ITMFACITFQ1_CITMFACITFQ1    label='Prefer not to answer question below'
	ITMFACITFGS7                label='I am satisfied with my sex life'
	ITMFACITFGE1                label='I feel sad'
	ITMFACITFGE2                label='I am satisfied with how I am coping with my illness'
	ITMFACITFGE3                label='I am losing hope in the fight against my illness'
	ITMFACITFGE4                label='I feel nervous'
	ITMFACITFGE5                label='I worry about dying'
	ITMFACITFGE6                label='I worry that my condition will get worse'
	ITMFACITFGF1                label='I am able to work (include work at home)'
	ITMFACITFGF2                label='My work (include work at home) is fulfilling'
	ITMFACITFGF3                label='I am able to enjoy life'
	ITMFACITFGF4                label='I have accepted my illness'
	ITMFACITFGF5                label='I am sleeping well'
	ITMFACITFGF6                label='I am enjoying the things I usually do for fun'
	ITMFACITFGF7                label='I am content with the quality of my life right now'
	ITMFACITFHI7                label='I feel fatigued'
	ITMFACITFHI12               label='I feel weak all over'
	ITMFACITFAN1                label='I feel listless ("washed out")'
	ITMFACITFAN2                label='I feel tired'
	ITMFACITFAN3                label='I have trouble starting things because I am tired'
	ITMFACITFAN4                label='I have trouble finishing things because I am tired'
	ITMFACITFAN5                label='I have energy'
	ITMFACITFAN7                label='I am able to do my usual activities'
	ITMFACITFAN8                label='I need to sleep during the day'
	ITMFACITFAN12               label='I am too tired to eat'
	ITMFACITFAN14               label='I need help doing my usual activities'
	ITMFACITFAN15               label='I am frustrated by being too tired to do the things I want to do'
	ITMFACITFAN16               label='I have to limit my social activity because I am too tired'
	A_DOV						label='Visit Date'
	; 

/*ITMFACITFNDAENUM=put(_ITMFACITFNDAENUM,best.);*/
/*if compress(ITMFACITFNDAENUM)='.' then ITMFACITFNDAENUM='';*/

ITMFACITFNDAENUM=ifc(_ITMFACITFNDAENUM^=.,put(_ITMFACITFNDAENUM,best.),'');

if ITMFACITFPERFDT_DTS ^='' then ASSESS =ITMFACITFPERFDT_DTS;
else if ITMFACITFNDRSN^='' and ITMFACITFNDOTHSPC ^='' then ASSESS=strip(scan(ITMFACITFNDRSN,1,','))||': '||strip(ITMFACITFNDOTHSPC);
else if ITMFACITFNDRSN^='' and ITMFACITFNDAENUM ^='' then ASSESS=strip(scan(ITMFACITFNDRSN,1,','))||': '||strip(ITMFACITFNDAENUM);
else ASSESS=ITMFACITFNDRSN;

if ITMFACITFQ1_CITMFACITFQ1^='' then ITMFACITFQ1_CITMFACITFQ1='Y';

VISITMNEMONIC=put(VISITMNEMONIC,$qsvisit.);


if strip(ITMFACITFASSESS_C) ='DONE';

A='';

keep  A SUBJECTNUMBERSTR visitnum VISITMNEMONIC dov A_DOV ASSESS ITMFACITFGP1 ITMFACITFGP2 ITMFACITFGP3 ITMFACITFGP4 ITMFACITFGP5 ITMFACITFGP6 ITMFACITFGP7 
	ITMFACITFGS1 ITMFACITFGS2 ITMFACITFGS3 ITMFACITFGS4 ITMFACITFGS5 ITMFACITFGS6 ITMFACITFQ1_CITMFACITFQ1 ITMFACITFGS7 ITMFACITFGE1 ITMFACITFGE2 ITMFACITFGE3
	ITMFACITFGE4 ITMFACITFGE5 ITMFACITFGE6 ITMFACITFGF1 ITMFACITFGF2 ITMFACITFGF3 ITMFACITFGF4 ITMFACITFGF5 ITMFACITFGF6 ITMFACITFGF7 ITMFACITFHI7 ITMFACITFHI12
	ITMFACITFAN1 ITMFACITFAN2 ITMFACITFAN3 ITMFACITFAN4 ITMFACITFAN5 ITMFACITFAN7 ITMFACITFAN8 ITMFACITFAN12 ITMFACITFAN14 ITMFACITFAN15 ITMFACITFAN16;
run;


proc sort data=qs01 out=s_qs01; by  SUBJECTNUMBERSTR visitnum VISITMNEMONIC dov A_DOV ASSESS ;run;

data s_qs01_; 
	set s_qs01;
	rename VISITMNEMONIC=A_VISITMNEMONIC A_DOV=B_DOV ASSESS=C_ASSESS;
RUN;

proc transpose data=s_qs01_ out=t_qs01;
	by SUBJECTNUMBERSTR A ;
	id visitnum;
	var A_VISITMNEMONIC B_DOV C_ASSESS ITMFACITFGP1 ITMFACITFGP2 ITMFACITFGP3 ITMFACITFGP4 ITMFACITFGP5 ITMFACITFGP6 ITMFACITFGP7 
	ITMFACITFGS1 ITMFACITFGS2 ITMFACITFGS3 ITMFACITFGS4 ITMFACITFGS5 ITMFACITFGS6 ITMFACITFQ1_CITMFACITFQ1 ITMFACITFGS7 ITMFACITFGE1 ITMFACITFGE2 ITMFACITFGE3
	ITMFACITFGE4 ITMFACITFGE5 ITMFACITFGE6 ITMFACITFGF1 ITMFACITFGF2 ITMFACITFGF3 ITMFACITFGF4 ITMFACITFGF5 ITMFACITFGF6 ITMFACITFGF7 ITMFACITFHI7 ITMFACITFHI12
	ITMFACITFAN1 ITMFACITFAN2 ITMFACITFAN3 ITMFACITFAN4 ITMFACITFAN5 ITMFACITFAN7 ITMFACITFAN8 ITMFACITFAN12 ITMFACITFAN14 ITMFACITFAN15 ITMFACITFAN16;
run;

/*data qs02;*/
/*set t_qs01;*/
/*if strip(_name_)='ASSESS' then _name_='B_ASSESS';*/
/*run;*/


data qs04;
	set t_qs01(rename=(_name_=__name _label_=qstest));
	if __name='A_VISITMNEMONIC' or __name='B_DOV' or __name='C_ASSESS' then __n=0;
	else if qstest^='' then __n=input(qstest,order.);
	if strip(qstest)='Prefer not to answer question below' then qstest="^{style [textdecoration=underline]Prefer not to answer question below}";
	if __name ^='B_DOV' and __name ^='C_ASSESS';
run;


data qs05 qs06;
	set qs04;
	if __n <=21 then output qs05;
	if __n=0 or __n>21 then output qs06;
run;

data qs05_;
	set qs05;
		if __name='A_VISITMNEMONIC' then qstest='Question';

RUN; 

data qs06_;
	
	set qs06(rename=(__n=__n1));
	if __name='A_VISITMNEMONIC' then qstest='Question';
	if __N1=0 then __N=0; else __N=__N1-21;
	
	rename qstest=qstest_ _1=_1_ _3=_3_ _6=_6_ _9=_9_ _12=_12_ /*_6D1=_6D1_*/;
run;

data pdata.qs37(label='Quality of Life - FACIT-F');
	retain  __label SUBJECTNUMBERSTR qstest  _1  _3 _6  _9 _12 A QSTEST_ _1_  _3_ _6_  _9_ _12_;
	keep  __label SUBJECTNUMBERSTR qstest  _1  _3 _6  _9 _12 A QSTEST_ _1_  _3_ _6_  _9_ _12_;
	merge qs05_ qs06_;
	by SUBJECTNUMBERSTR __n;
	length __label $200;
	__label="Quality of Life - FACIT-F ^{newline 2}^{style[fontsize=7pt foreground=green]NOTE: 0=Not at all, "
	||"1=A little bit, 2=Some-what, 3=Quite a bit, 4=Very much}";
run;
