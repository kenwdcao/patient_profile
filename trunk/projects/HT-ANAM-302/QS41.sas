
%include '_setup.sas';

*<QS41--------------------------------------------------------------------------------------------------------;
%getVNUM(indata= source.RD_FRMHUNGER, out=RD_FRMHUNGER);

data qs0;
	set RD_FRMHUNGER;
	%adjustvalue1(dsetlabel=Hunger Assessment Scale);
	%formatDate(ITMHUNGERDT_DTS); %informatDate(DOV);
*-> Modify Variable Label;
attrib
	ITMHUNGERASSESS			label='Date of Hunger Assessment Scale'
	A_DOV					label='Visit Date'
	; 

if ITMHUNGERASSESS ^='' and ITMHUNGERDT_DTS ^='' then ITMHUNGERASSESS=ITMHUNGERDT_DTS;
else ITMHUNGERASSESS=ITMHUNGERASSESS;

if ITMHUNGERASSESS ^='';
keep SUBJECTNUMBERSTR visitnum VISITMNEMONIC dov A_DOV  ITMHUNGERASSESS ITMHUNGERHUNGRY ITMHUNGERAPPETITE;
run;


proc sort data=qs0 out=s_qs0; by SUBJECTNUMBERSTR visitnum VISITMNEMONIC dov A_DOV; run;

data s_qs0_;
	length vnum $100 VISITMNEMONIC $400;
	set s_qs0;
	format VISITMNEMONIC $200.;
	vnum='v_'||strip(put(VISITNUM*10,best.));
	if int(VISITNUM)^=VISITNUM then vnum=strip(vnum)||'_D';
	if index(VISITMNEMONIC,'UNS')>0 then VISITMNEMONIC='Unscheduled';
	VISITMNEMONIC=strip(VISITMNEMONIC)||'#'||strip(A_DOV);
	rename VISITMNEMONIC=A_VISITMNEMONIC A_DOV=B_DOV ITMHUNGERASSESS=C_ITMHUNGERASSESS;
RUN;

proc transpose data=s_qs0_ out=t_qs0; 
	by SUBJECTNUMBERSTR;
	id vnum;
	var A_VISITMNEMONIC C_ITMHUNGERASSESS ITMHUNGERHUNGRY ITMHUNGERAPPETITE;
run;

data qs01;
	set t_qs0(rename=(_label_=qstest _name_=__name));
	label qstest='QSTEST';
	if __name='A_VISITMNEMONIC' then qstest='Label';
run;

proc sort data=qs01 out=qs01_; by SUBJECTNUMBERSTR __name;run;


%adjustVisitVarOrder(indata=qs01_,othvars=SUBJECTNUMBERSTR QSTEST);

data pdata.qs41(label='Hunger Assessment Scale');
	set qs01_;
run;
