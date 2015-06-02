%include '_setup.sas';

*<ECG--------------------------------------------------------------------------------------------------------;
%macro concatABN(var=, dts=, newvar=);
	if &var >'' and &dts>'' then &newvar=strip(scan(&var,1,','))||', '||'NCS'||': '||strip(&dts);
	else if index(&var,',')>0 then &newvar=strip(scan(&var,1,','))||', '||'CS';
    else if &var >'' and &dts='' then &newvar=&var;
%mend concatABN;

%macro normalRange(var=,low=,high=,outvar=);
	if &var>. then do;
		if &var<&low then &outvar='^{style [foreground='||"&belowcolor"||' fontweight=bold]'||strip(put(&var,best.))||'}';
		else if &var>&high then &outvar='^{style [foreground='||"&abovecolor"||' fontweight=bold]'||strip(put(&var,best.))||'}';
		else &outvar=strip(put(&var,best.));
	end;
/*	else if strip(&nd)='Not Done' then do; &outvar='Not Done'; end;*/
%mend normalRange;

%macro DONE(done=,num=,doneqtcf=);
	if &done='NOT DONE' then do;
		QT&num='Not Done';
		PR&num='Not Done';
		QRS&num='Not Done';
		RR&num='Not Done';
	end;
	if &doneqtcf='Not Done' then do;
		QTCF&num='Not Done';
	end;
%mend DONE;
%macro eglh1(a1=,a2=,a3=);
	%do i=1 %to 3;
	%let bl=&&a&i..LOW;
	%let bh=&&a&i..HIGH;
	%normalRange(var=ITMPKECGFIRSTECG&&a&i,low=&&&bl,high=&&&bh,outvar=&&a&i..1);
	%end;
%mend eglh1;
%macro eglh2(a1=,a2=,a3=);
	%do i=1 %to 3;
	%let bl=&&a&i..LOW;
	%let bh=&&a&i..HIGH;
	%normalRange(var=ITMPKECGSECONDECG&&a&i,low=&&&bl,high=&&&bh,outvar=&&a&i..2);
	%end;
%mend eglh2;
%macro eglh3(a1=,a2=,a3=);
	%do i=1 %to 3;
	%let bl=&&a&i..LOW;
	%let bh=&&a&i..HIGH;
	%normalRange(var=ITMPKECGTHIRDECG&&a&i,low=&&&bl,high=&&&bh,outvar=&&a&i..3);
	%end;
%mend eglh3;
%macro eg(n=,cs=,newvar=);
	&newvar=ifc(QT&n>'',strip(QT&n),' ')||'^{style [foreground=black] / }'||ifc(PR&n>'',strip(PR&n),' ')||'^{style [foreground=black] / }'||
			ifc(QRS&n>'',strip(QRS&n),' ')||'^{style [foreground=black] / }'||ifc(RR&n>'',strip(RR&n),' ')||'^{style [foreground=black] / }'||
			ifc(QTCF&n>'',strip(QTCF&n),' ')||'^{style [foreground=black] / }'||ifc(&cs>'',strip(&cs),' ');
	if strip(&newvar)='^{style [foreground=black] / } ^{style [foreground=black] / } ^{style [foreground=black] / } ^{style [foreground=black] / } ^{style [foreground=black] / }' 
		then &newvar='';
%mend eg;

**************************************;
%getVNUM(indata=source.RD_FRMPKECG, out=RD_FRMPKECG);
data ECG;
	length FIRST SECOND THIRD $400 QT1	PR1	QRS1 RR1 QTCF1 QT2	PR2	QRS2 RR2 QTCF2 	QT3	PR3	QRS3 RR3 QTCF3 $200;
	set RD_FRMPKECG(RENAME=(visitnum=__visitnum));
	%informatDate(DOV);
	%formatDate2(ITMPKECGFOODPRDTTM_DTS); 
	%formatDate2(ITMPKECGDRGPRDTTM_DTS);
	%formatDate2(ITMPKECGPKPRDTTM_DTS);
	%time(ITMPKECGFIRSTECGTM_TMS);
	%formatDate2(ITMPKECGDRGONDTTM_DTS);
	%formatDate2(ITMPKECGPK3090DTTM_DTS);
	%time(ITMPKECGSECONDECGTM_TMS);
	%formatDate2(ITMPKECGPKTHIRDDTTM_DTS);
	%time(ITMPKECGTHIRDECGTM_TMS);
	label
		A_DOV='Visit Date'
		ITMPKECGPTCOHORT='Specify the patient cohort'
		ITMPKECGFASTING='Was the patient fasting prior to the Day 43 study drug administration in the clinic?'
		ITMPKECGFOODPRDTTM_DTS='Date/Time of last food intake prior to the Day 43 study drug administration in the clinic'
		ITMPKECGDRGPRDTTM_DTS='Date/Time of study drug administration prior to Day 43 PK visit'
		ITMPKECGPKPRDTTM_DTS='Date/Time of PK sample prior to study drug administration'
		ITMPKECGFIRSTECGTM_TMS='Time performed'
		QT1 = 'QT(msec)'
		PR1 = 'PR(msec)'
		QRS1 = 'QRS(msec)'
		RR1 = 'RR(msec)'
		QTCF1 = 'QTcF(msec)'
		FIRST='QT/PR/QRS/RR/QTcF/Overall interpretation'
		FIRSTCS='Overall interpretation'
		ITMPKECGDRGONDTTM_DTS='Date/Time of study drug administration in clinic on Day 43'
		ITMPKECGPK3090DTTM_DTS='Date/Time of PK sample 30-90 minutes after study drug administration'
		ITMPKECGSECONDECGTM_TMS='Time performed'
		QT2 = 'QT(msec)'
		PR2 = 'PR(msec)'
		QRS2 = 'QRS(msec)'
		RR2 = 'RR(msec)'
		QTCF2 = 'QTcF(msec)'
		SECOND='QT/PR/QRS/RR/QTcF/Overall interpretation'
		SECONDCS='Overall interpretation'
		ITMPKECGPKTHIRDDTTM_DTS='Date/Time of PK sample - Third Draw per protocol time points'
		ITMPKECGTHIRDECGTM_TMS='Time performed'
		QT3 = 'QT(msec)'
		PR3 = 'PR(msec)'
		QRS3 = 'QRS(msec)'
		RR3 = 'RR(msec)'
		QTCF3 = 'QTcF(msec)'
		THIRD='QT/PR/QRS/RR/QTcF/Overall interpretation'
		THIRDCS='Overall interpretation'
		EGDATE='ECG Date'
	;
	%concatABN(var=ITMPKECGFIRSTECGOVIN, dts=ITMPKECGFIRSTECGCS, newvar=FIRSTCS);
	%eglh1(a1=QT,a2=PR,a3=QRS);
	%char(var=ITMPKECGFIRSTECGRR,newvar=RR1);
	%normalRange(var=ITMPKECGQTCFCAL1,low=&QTCFLOW,high=&QTCFHIGH,outvar=QTCF1);
	%DONE(done=ITMPKECGFIRSTECG_C,num=1,doneqtcf=ITMPKECGQTCFCAL1_ND);
	%eg(n=1,cs=FIRSTCS,newvar=FIRST);
	%concatABN(var=ITMPKECGSECONDECGOVIN, dts=ITMPKECGSECONDECGCS, newvar=SECONDCS);
	%eglh2(a1=QT,a2=PR,a3=QRS);
	%char(var=ITMPKECGSECONDECGRR,newvar=RR2);
	%normalRange(var=ITMPKECGQTCFCAL2,low=&QTCFLOW,high=&QTCFHIGH,outvar=QTCF2);
	%DONE(done=ITMPKECGSECONDECG_C,num=2,doneqtcf=ITMPKECGQTCFCAL2_ND);
	%eg(n=2,cs=SECONDCS,newvar=SECOND);
	%concatABN(var=ITMPKECGTHIRDECGOVIN, dts=ITMPKECGTHIRDECGCS, newvar=THIRDCS);
	%eglh3(a1=QT,a2=PR,a3=QRS);
	%char(var=ITMPKECGTHIRDECGRR,newvar=RR3);
	%normalRange(var=ITMPKECGQTCFCAL3,low=&QTCFLOW,high=&QTCFHIGH,outvar=QTCF3);
	%DONE(done=ITMPKECGTHIRDECG_C,num=3,doneqtcf=ITMPKECGQTCFCAL3_ND);
	%eg(n=3,cs=THIRDCS,newvar=THIRD);

	if ITMPKECGPKPRDTTM_DTS^='' then egdate=strip(substr(ITMPKECGPKPRDTTM_DTS,1,9)); 
	keep &GlobalVars4 ITMPKECGPTCOHORT ITMPKECGFASTING ITMPKECGFOODPRDTTM_DTS	ITMPKECGDRGPRDTTM_DTS ITMPKECGPKPRDTTM_DTS	
		ITMPKECGFIRSTECGTM_TMS	FIRST FIRSTCS ITMPKECGDRGONDTTM_DTS ITMPKECGPK3090DTTM_DTS	ITMPKECGSECONDECGTM_TMS	
    	SECOND SECONDCS	ITMPKECGPKTHIRDDTTM_DTS	ITMPKECGTHIRDECGTM_TMS THIRD THIRDCS EGDATE;
run; 
data pdata.ECG1(label='Pharmacokinetic Sampling ECG');
	retain &GlobalVars4 ITMPKECGPTCOHORT EGDATE ITMPKECGFIRSTECGTM_TMS	FIRST ITMPKECGSECONDECGTM_TMS SECOND ITMPKECGTHIRDECGTM_TMS THIRD;
	keep &GlobalVars4 ITMPKECGPTCOHORT EGDATE ITMPKECGFIRSTECGTM_TMS	FIRST ITMPKECGSECONDECGTM_TMS SECOND ITMPKECGTHIRDECGTM_TMS THIRD;
	set ECG;
run;
data pdata.ECG2(label='Pharmacokinetic Sampling ECG-Additional Information');
	retain  SUBJECTNUMBERSTR ITMPKECGFASTING ITMPKECGFOODPRDTTM_DTS	ITMPKECGDRGPRDTTM_DTS ITMPKECGPKPRDTTM_DTS	
		ITMPKECGDRGONDTTM_DTS ITMPKECGPK3090DTTM_DTS ITMPKECGPKTHIRDDTTM_DTS;
	keep  SUBJECTNUMBERSTR ITMPKECGFASTING ITMPKECGFOODPRDTTM_DTS	ITMPKECGDRGPRDTTM_DTS ITMPKECGPKPRDTTM_DTS	
		ITMPKECGDRGONDTTM_DTS ITMPKECGPK3090DTTM_DTS ITMPKECGPKTHIRDDTTM_DTS;
	set ECG;
run;
