
%include '_setup.sas';

*<XC----------------------------------------------------------------------------------------;
data xc0;
	set source.RD_FRMPREVRAD_ACTIVE;
	%adjustvalue(dsetlabel=Previous Radiotherapy for NSCLC);
	%informatDate(DOV);
	%formatDate(ITMPREVRADSTARTDT_DTS);
	%formatDate(ITMPREVRADSTOPDT_DTS);
	label
		A_DOV='Visit Date'
		REGION='Region Radiated'
		TOTDOSE='Total Dose#<cGy>'
		STDTC='Start Date'
		ENDTC='Stop Date'
	;
	length REGION $200 __sortkey $200;

	STDTC=ITMPREVRADSTARTDT_DTS;
	ENDTC=ITMPREVRADSTOPDT_DTS;
	TOTDOSE=ITMPREVRADTOTDOSE;
	%concatoth(var=ITMPREVRADRG_ITMPREVRADOT_C,oth=ITMPREVRADOT,newvar=OTHER);
	REGION=catx(', ',ITMPREVRADRG_CITMRLUNG, ITMPREVRADRG_CITMLLUNG, ITMPREVRADRG_CITMCHEST, ITMPREVRADRG_CITMABDOMEN, OTHER); 

	__sortkey=lowcase(strip(REGION));

run;

proc sort data=xc0;by SUBJECTNUMBERSTR ITMPREVRADSTARTDT_DTR __sortkey;run;

data pdata.xc10(label='Previous Radiotherapy for NSCLC');
	retain &GlobalVars1  REGION TOTDOSE STDTC ENDTC __FORMIDX;
	keep &GlobalVars1  REGION TOTDOSE STDTC ENDTC __FORMIDX;
	set xc0(rename=(FORMIDX=__FORMIDX));
run; 
