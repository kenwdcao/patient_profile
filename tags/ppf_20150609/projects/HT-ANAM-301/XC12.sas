%include '_setup.sas';

*<XC----------------------------------------------------------------------------------------;

data xc20;
	set source.RD_FRMPRVCH_ACTIVE;
	%adjustvalue(dsetlabel=Previous Chemotherapy/Immunotherapy for NSCLC);
	%informatDate(DOV);
	%formatDate(ITMPRVCHSTARTDT_DTS);
	%formatDate(ITMPRVCHSTOPDT_DTS);
	label
		A_DOV='Visit Date'
		ITMPRVCHREG='Regimen'
		ITMPRVCHCYTCHEM='Include cytotoxic chemotherapy?'
		STDTC='Start Date'
		ENDTC='Stop Date'
	;

	length  __sortkey $200;

	STDTC=ITMPRVCHSTARTDT_DTS;
	ENDTC=ITMPRVCHSTOPDT_DTS;

	__sortkey=lowcase(strip(ITMPRVCHREG));
run;

proc sort data=xc20;by SUBJECTNUMBERSTR ITMPRVCHSTARTDT_DTR __sortkey;run;

data pdata.xc12(label='Previous Chemotherapy/Immunotherapy for NSCLC');
	retain &GlobalVars1  ITMPRVCHREG ITMPRVCHCYTCHEM STDTC ENDTC __FORMIDX;
	keep &GlobalVars1 ITMPRVCHREG ITMPRVCHCYTCHEM STDTC ENDTC __FORMIDX;
	set xc20(rename=(FORMIDX=__FORMIDX));
run;
*------------------------------------------------------------------------------------------>;
