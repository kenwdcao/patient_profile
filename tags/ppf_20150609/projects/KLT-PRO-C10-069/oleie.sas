%include '_setup.sas';
data dm;
	length Subject $11;
	set source.dm;
	if length(USUBJID)<23 then Subject='';
	else Subject=strip(substr(USUBJID,13));
	keep Subject SUBJID;
run;
data oleie;
	length Subject $11  SUBJID $6 OLEPSAPROG1 OLEMETADIS1 OLESPNAPRV1 $10 OLEENROLDTC $19 A_VISIT $40;
	if _n_=1 then do;
		declare hash h (dataset:'dm');
		rc=h.defineKey('Subject');
		rc=h.defineData('SUBJID');
		rc=h.defineDone();
		call missing(Subject, SUBJID);
	end;
	set source.oleie;
	label
		OLEPSAPROG1='Did the subject experience PSA progression?'
		OLEMETADIS1='If Yes, was there evidence of Metastatic Disease?'
		OLESPNAPRV1='Sponsor approval?'
		OLEENROLDTC='Date of Enrollment in OLE?'
		A_VISIT='Visit'
	;
	rc=h.find();
	OLEPSAPROG1=strip(put(OLEPSAPROG,$yn.));
	OLEMETADIS1=strip(put(OLEMETADIS,$yn.));
	OLESPNAPRV1=strip(put(OLESPNAPRV,$yn.));
	if OLEENROLDT^=. then OLEENROLDTC=strip(put(OLEENROLDT,yymmdd10.));
	A_VISIT=put(parentForm,$visit.);
	if cmiss(OLEPSAPROG1, OLEMETADIS1, OLESPNAPRV1, OLEENROLDTC)^=4;
run;
data pdata.oleie(label='Open Label Enrollment');
	retain SUBJID A_VISIT OLEPSAPROG1 OLEMETADIS1 OLESPNAPRV1 OLEENROLDTC;
	keep SUBJID A_VISIT OLEPSAPROG1 OLEMETADIS1 OLESPNAPRV1 OLEENROLDTC;
	set oleie;
run;
