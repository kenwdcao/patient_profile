%include '_setup.sas';

*<YC----------------------------------------------------------------------------------------;
data yc0;
	set source.RD_FRMPREVSURG_ACTIVE;
	%adjustvalue(dsetlabel=Previous Surgery for NSCLC);
	%informatDate(DOV);
	%formatDate(ITMPREVSURGPROCDT_DTS);
	label
		A_DOV='Visit Date'
		ITMPREVSURGPROC='Procedure'
		ITMPREVSURGPROCDT_DTS='Date of procedure'
	;
	length __sortkey $200;

	__sortkey=lowcase(strip(ITMPREVSURGPROC));

run;

proc sort data=yc0;by SUBJECTNUMBERSTR ITMPREVSURGPROCDT_DTR __sortkey;run;

data pdata.yc11(label='Previous Surgery for NSCLC');
	retain &GlobalVars1 ITMPREVSURGPROC ITMPREVSURGPROCDT_DTS __FORMIDX;
	keep &GlobalVars1 ITMPREVSURGPROC ITMPREVSURGPROCDT_DTS __FORMIDX;
	set yc0(rename=(FORMIDX=__FORMIDX));
run;
*------------------------------------------------------------------------------------------>;
