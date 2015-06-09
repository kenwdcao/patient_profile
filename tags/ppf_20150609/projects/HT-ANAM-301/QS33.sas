%include '_setup.sas';

*<QS33--------------------------------------------------------------------------------------------------------;
%getVNUM(indata= source.RD_FRMKARNOFSKY, out=RD_FRMKARNOFSKY);

data QS0;
	set RD_FRMKARNOFSKY;
	%adjustvalue1(dsetlabel=Karnofsky Score);
	%formatDate(ITMKARNOFSKYDT_DTS); %informatDate(DOV);
*-> Modify Variable Label;
	attrib
	ITMKARNOFSKYPERF       		label='Date Performed' 
	ITMKARNOFSKYSCORE      		label='Karnofsky Score' 
	A_DOV						label='Visit Date'
	;

if ITMKARNOFSKYDT_DTS^='' then ITMKARNOFSKYPERF = ITMKARNOFSKYDT_DTS;
else ITMKARNOFSKYPERF =ITMKARNOFSKYPERF;

keep SUBJECTNUMBERSTR visitnum VISITMNEMONIC dov A_DOV  ITMKARNOFSKYPERF ITMKARNOFSKYSCORE;

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
	rename VISITMNEMONIC=A_VISITMNEMONIC A_DOV=B_DOV ITMKARNOFSKYPERF=C_ITMKARNOFSKYPERF;
RUN;

proc transpose data=s_qs0_ out=t_qs0; 
	by SUBJECTNUMBERSTR;
	id vnum;
	var A_VISITMNEMONIC C_ITMKARNOFSKYPERF ITMKARNOFSKYSCORE;
run;

data qs01;
	set t_qs0(rename=(_label_=qstest _name_=__name));
	label qstest='QSTEST';
	if __name='A_VISITMNEMONIC' then qstest='Label';
run;

proc sort data=qs01 out=qs01_; by SUBJECTNUMBERSTR __name;run;
	
%adjustVisitVarOrder(indata=qs01_,othvars=SUBJECTNUMBERSTR QSTEST);

data pdata.qs33(label='Karnofsky Score');
	set qs01_;
run;
*----------------------------------------------------------------------------------------------------------->;
