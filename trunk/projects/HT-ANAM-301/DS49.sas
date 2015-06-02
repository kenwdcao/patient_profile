%include '_setup.sas';

*<ds----------------------------------------------------------------------------------------;
data ds0;
	length COMPLETE $200 REASON $200;
	set source.RD_FRMEOS;
	%adjustvalue(dsetlabel=Study Completion);
	%informatDate(DOV);
	%formatDate(ITMEOSLASTCONTDT_DTS);
	%formatDate(ITMEOSETDT_DTS);
	%formatDate(ITMEOSBLINDBROKEDT_DTS);
	label
		A_DOV='Visit Date'
		COMPLETE='Did the subject complete the study'
		REASON='Reason for withdrawal'
		ITMEOSETDT_DTS='Date of study completion/ET'
		ITMEOSBLIND='Was the blind broken at the site?'
		ITMEOSBLINDBROKEDT_DTS='Date the blind was broken'
		ITMEOSBLINDBROKERSN='Reason for breaking the blind'
	;
	if ITMEOSCOMPLETE_C='COMPLETED' then COMPLETE='Yes';
		else if ITMEOSCOMPLETE_C='NOT COMPLETED' then COMPLETE='No';
			 else COMPLETE='';
	if ITMEOSCOMPLETE_C='COMPLETED' then REASON='';
	else if ITMEOSCOMPLETE_C='NOT COMPLETED' and cmiss(ITMEOSRSNDEATH,ITMEOSRSNOTH,ITMEOSLASTCONTDT_DTS,ITMEOSRSNWITHCON)^=4 
		then REASON=strip(ITMEOSREASON)||': '||coalescec(ITMEOSRSNDEATH,ITMEOSRSNOTH,ITMEOSLASTCONTDT_DTS,ITMEOSRSNWITHCON);
	else if ITMEOSCOMPLETE_C='NOT COMPLETED' and cmiss(ITMEOSRSNDEATH,ITMEOSRSNOTH,ITMEOSLASTCONTDT_DTS,ITMEOSRSNWITHCON)=4 
		then REASON=strip(ITMEOSREASON);
	else REASON='';
run;

proc sort data=ds0; by SUBJECTNUMBERSTR __visitnum; run;
data pdata.ds49(label='Study Completion');
	retain &GlobalVars1 COMPLETE REASON ITMEOSETDT_DTS ITMEOSBLIND ITMEOSBLINDBROKEDT_DTS ITMEOSBLINDBROKERSN;
	keep &GlobalVars1 COMPLETE REASON ITMEOSETDT_DTS ITMEOSBLIND ITMEOSBLINDBROKEDT_DTS ITMEOSBLINDBROKERSN;
	set ds0;
run;
*------------------------------------------------------------------------------------------>;
