
%include '_setup.sas';

*<RS----------------------------------------------------------------------------------------;
%macro rs(source=, flag=);
%getVNUM1(indata=&source..RD_FRMTMRASS, pdata=_visitindex_&source,out=RD_FRMTMRASS);
data rs0;
	length flag $20;
	set RD_FRMTMRASS(rename=(visitnum=__visitnum));
	%informatDate(DOV);
	%formatDate(ITMTMRASSDT_DTS);
	label
		A_DOV='Visit Date'
		ITMTMRASSDT_DTS='Date of assessment'
		NTARCD='Was there new target lesions found?'
		ITMTMRASSTARRSP='Response of Target Lesions'
		NONTARLES='Was there new non-target lesions found?'
		ITMTMRASSNONTARRSP='Response of Non-Target Lesions'
		ITMTMRASSOVERALL='According to RECIST 1.1 Criteria'
		visitmnemonic='Visit'
	;
	%concatyn(var=ITMTMRASSTARLES,oth=ITMTMRASSNTARCD_ITMTMRASST_1,newvar=NTARCD);
	if index(ITMTMRASSNTARCD_ITMTMRASSN_1,'and')>0 then x=compress(TRANSLATE(ITMTMRASSNTARCD_ITMTMRASSN_1,',','and'));
		else x=ITMTMRASSNTARCD_ITMTMRASSN_1;
	%concatyn(var=ITMTMRASSNONTARLES,oth=x,newvar=NONTARLES);
	flag="&flag";
run;
data rs_&source;
	retain SUBJECTNUMBERSTR flag visitmnemonic dov a_dov ITMTMRASSDT_DTS NTARCD ITMTMRASSTARRSP NONTARLES ITMTMRASSNONTARRSP ITMTMRASSOVERALL;
	keep SUBJECTNUMBERSTR flag visitmnemonic dov a_dov ITMTMRASSDT_DTS NTARCD ITMTMRASSTARRSP NONTARLES ITMTMRASSNONTARRSP ITMTMRASSOVERALL;
	set rs0;
run;
%mend rs;

%RS(source=r301,flag=ANAM301);
%RS(source=r302,flag=ANAM302);


%getVNUM(indata=source.RD_FRMTMRASS,out=RD_FRMTMRASS);
data rs0;
	length flag $20;
	set RD_FRMTMRASS(rename=(visitnum=__visitnum));
	%informatDate(DOV);
	%formatDate(ITMTMRASSDT_DTS);
	label
		A_DOV='Visit Date'
		ITMTMRASSDT_DTS='Date of assessment'
		NTARCD='Was there new target lesions found?'
		ITMTMRASSTARRSP='Response of Target Lesions'
		NONTARLES='Was there new non-target lesions found?'
		ITMTMRASSNONTARRSP='Response of Non-Target Lesions'
		ITMTMRASSOVERALL='According to RECIST 1.1 Criteria'
		visitmnemonic='Visit'
	;
	%concatyn(var=ITMTMRASSTARLES,oth=ITMTMRASSNTARCD_ITMTMRASST_1,newvar=NTARCD);
	if index(ITMTMRASSNTARCD_ITMTMRASSN_1,'and')>0 then x=compress(TRANSLATE(ITMTMRASSNTARCD_ITMTMRASSN_1,',','and'));
		else x=ITMTMRASSNTARCD_ITMTMRASSN_1;
	%concatyn(var=ITMTMRASSNONTARLES,oth=x,newvar=NONTARLES);
	flag="ANAM303";
run;

data rs_303;
	retain SUBJECTNUMBERSTR flag visitmnemonic dov a_dov ITMTMRASSDT_DTS NTARCD ITMTMRASSTARRSP NONTARLES ITMTMRASSNONTARRSP ITMTMRASSOVERALL;
	keep SUBJECTNUMBERSTR flag visitmnemonic dov a_dov ITMTMRASSDT_DTS NTARCD ITMTMRASSTARRSP NONTARLES ITMTMRASSNONTARRSP ITMTMRASSOVERALL;
	set rs0;
run;

data rs_01;
	set rs_r301 rs_r302;
run;

proc sort data=rs_303 out=s_rs_303(keep=SUBJECTNUMBERSTR) nodupkey; by SUBJECTNUMBERSTR ; run;

proc sql;
	create table rs_02 as
	select a.*
	from rs_01 as a inner join s_rs_303 as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR
;
quit;

data rs_03;
	set rs_02  rs_303;
run;

proc sort data= rs_03 out=s_rs_03;by SUBJECTNUMBERSTR dov a_dov ;run;

data pdata.RS52(label='Target and Non-Target Lesions Assessment');
	retain SUBJECTNUMBERSTR FLAG visitmnemonic A_DOV ITMTMRASSDT_DTS NTARCD ITMTMRASSTARRSP NONTARLES ITMTMRASSNONTARRSP ITMTMRASSOVERALL;
	keep SUBJECTNUMBERSTR FLAG visitmnemonic A_DOV ITMTMRASSDT_DTS NTARCD ITMTMRASSTARRSP NONTARLES ITMTMRASSNONTARRSP ITMTMRASSOVERALL;
	set s_rs_03;
	label flag='Study ID'
		  visitmnemonic='Visit';
run;
