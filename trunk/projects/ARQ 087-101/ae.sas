%include '_setup.sas';

proc sort data=source.ae out=ae nodupkey; by SUBID ID;run;

data ae;
	length AEACN AEACNO AESAE AECAUS  AEOUT AEDLT AEDC $200 AEEN AEACN1-AEACN7 $200 AENCI $1;
	keep SUBID AENUM AEDESC /*M_PT M_SOC*/ AESTDTC AEEN AENCI AESAE AECAUS AEACN AEACNO AEOUT AEDLT AEDC AEACN1-AEACN7;
	set ae(rename=(
	AENCI=AENCI_
	AESAE=AESAE_
	AECAUS=AECAUS_
	AEOUT=AEOUT_
	AEDLT=AEDLT_
	AEDC=AEDC_
	));
	AEDESC=strip(AEDESC);
	if AEONGO=1 then AEEN='Ongoing';
		else if AEENDDTC^='' then AEEN=strip(AEENDDTC);
	AESTDTC=strip(AESTDTC);
	if AENCI_^=. then AENCI=strip(put(AENCI_,AENCI.));
	if AESAE_^=. then AESAE=strip(put(AESAE_,NOYES.));
	if AECAUS_^=. then AECAUS=strip(put(AECAUS_,AECAUS.));
	if AEOUT_^=. then AEOUT=strip(put(AEOUT_,AEOUT.));
	if AEDLT_^=. then AEDLT=strip(put(AEDLT_,NOYES.));
	if AEDC_^=. then AEDC=strip(put(AEDC_,NOYES.));
/*	M_PT=strip(M_PT);*/
/*	M_SOC=strip(M_SOC);*/
	if AEACTOTH=99 and AEACSP^='' then AEACNO='Other: '||strip(AEACSP);
		else if AEACTOTH=99 then AEACNO='Other';
			else AEACNO=strip(put(AEACTOTH,AEACTOTH.));
	if AEACT1=1 then AEACN1="Dose/Treatment not changed";
	if AEACT2=1 then AEACN2="Dose reduced without interruption";
	if AEACT3=1 then AEACN3="Treatment temporarily interrupted" ;
	if AEACT4=1 then AEACN4="Treatment temporarily interrupted then reduced";
	if AEACT5=1 then AEACN5="Treatment permanently discontinued";
	if AEACT6=1 then AEACN6="N/A";
	if AEACT7=1 then AEACN7="Unknown";
	AEACN = catx(',',AEACN1,AEACN2,AEACN3,AEACN4,AEACN5,AEACN6,AEACN7);
	label   AEACN = 'Action Taken'
			AEACNO = 'Other Action Taken'
			AESAE = 'SAE'
			AECAUS = 'Relationship to Study Drug'
			AENCI = 'NCI CTCAE Grade'
			AEOUT = 'Outcome'
			AEDLT = 'Is AE a DLT'
			AEDC = 'AE caused permanent discon.?'
			AEEN = 'Stop Date'
			AENUM = 'AE Number'
			AEDESC = 'Adverse Event'
			AESTDTC = 'Start Date'
			M_PT = 'Preferred Term'
			M_SOC = 'System Organ Class'
		;
run;

proc sort data=ae; by subid /*aenum*/ AESTDTC ; run;

data pdata.ae(label='Adverse Events');
	retain SUBID AENUM AEDESC AESTDTC AEEN AEOUT AENCI AECAUS AEACN AEACNO AESAE AEDLT AEDC;
	keep SUBID AENUM AEDESC AESTDTC AEEN AEOUT AENCI AECAUS AEACN AEACNO AESAE AEDLT AEDC;
	set ae;
run;

