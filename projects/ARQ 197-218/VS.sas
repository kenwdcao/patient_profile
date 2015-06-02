
* Program Name: VS.sas;
* Author: Hawk Hou (tianfeng.hou@januscri.com);
* Initial Date: 18/02/2014;


%include '_setup.sas';

*;
data vs0;
	set source.vs_scr(in=in0) source.vs(in=in1);
	%subjid;
    length vsdtc $10 visit $40;
	%getCycle();
	VISIT = __visit;
	if in0 then do ;%getDate(leadq = vsstat, numdate = vsscdt);
	VSDTC = __date; end;
	if in1 then do ;%getDate(leadq = vsstat, numdate = vsdt);
	VSDTC = __date; end;
	keep 
	SUBJID VISIT VSDTC WT WTUNITCD WTUNIT HT HTUNITCD HTUNIT SYSBP DIABP HR RR
	TEMP TEMPUN __vdate;
run;

data vs1;
	retain SUBJID VISIT VSDTC WT0 HT0 SYSBP0 DIABP0 HR0 RR0 TEMP0 TEMPUN;
	set vs0;
    format WT0 $20. HT0 $20. SYSBP0 $20. DIABP0 $20. HR0 $20. RR0 $20. TEMP0 $20.;
	if WT ^= . then WT0 = strip(put(WT,best.)) || ' '||strip(WTUNIT); else WT0='';
	if HT ^=. then HT0 = strip(put(HT,best.)) || ' '||Strip(HTUNIT);else HT0='';
	if SYSBP ^=. then SYSBP0 = strip(put(SYSBP,best.));else SYSBP0='';
	if DIABP ^=. then DIABP0 = strip(put(DIABP,best.));else DIABP0='';
	if HR ^= . then HR0 = strip(put(HR,best.));else HR0='';
	if RR ^= . then RR0 = strip(put(RR,best.));else RR0='';
	if TEMP ^=. then TEMP0 = strip(put(TEMP,best.)) ||' '|| strip(TEMPUN);else TEMP0='';
	label
        VSDTC = 'Date'
		VISIT = 'Visit'
		WT0 = 'Weight'
		HT0 = 'Height'
		SYSBP0 = 'Systolic BP#(mmHg)'
		DIABP0 = 'Diastolic BP#(mmHg)'
		HR0 = 'Heart Rate#(beats/min)'
		RR0 = 'Respiration Rate#(breaths/min)'
		TEMP0 = 'Temperature'
	;
	keep 
	SUBJID VISIT VSDTC WT0 HT0 SYSBP0 DIABP0 HR0 RR0 TEMP0 TEMPUN __vdate;
run;

/*red-above; blue-lower; green-normal*/
*Systolic BP (mmHg);
%let low1=90;
%let high1=140;
*Diastolic BP (mmHg);
%let low2=50;
%let high2=90;
*Heart Rate (bmp);
%let low3=50;
%let high3=100;
*Respiratory Rate (rpm);
%let low4=12;
%let high4=18;
*Temperature (°C);
%let low5=35.5;
%let high5=37.8;

%let normalcolor = black;
%let lowcolor = blue;
%let highcolor = red;

data VS2;
	set VS1;
	length VS1-VS5 8 VSC1-VSC5 $200;
	if SYSBP0^='' then VS1=input(SYSBP0,best.);
	if DIABP0^='' then VS2=input(DIABP0,best.);
	if HR0^='' then VS3=input(HR0,best.);
	if RR0^='' then VS4=input(RR0,best.);

	if TEMP0^='' and TEMPUN = 'C' then VS5=input(compress(TEMP0,'C'),best.);
		else if TEMP0^='' and TEMPUN = 'F' then VS5=(input(compress(TEMP0,'F'),best.)-32)/1.8;
		else VS5=.;

	array VS{*} VS1-VS5;
	array VSC{*} VSC1-VSC5;
	array rangelow{*} low1-low5 (&low1 &low2 &low3 &low4 &low5);
	array rangehigh{*} high1-high5 (&high1 &high2 &high3 &high4 &high5);
	length color $10;
	do i = 1 to dim(VS);
		if VS[i] ^= . then 
			do;
				if VS[i] < rangelow[i] then color = "&lowcolor";
				else if VS[i] > rangehigh[i] then color = "&highcolor";
				else color = "&normalcolor";
				VSC[i] =  "^{style [foreground=" || strip(color) || "]" ||strip(put(VS[i],best.))||'}';
			end;
		else
			do;
			VSC[i] = '';	
			end;
	end;
;
	keep SUBJID VISIT VSDTC WT0 HT0 VSC1-VSC5 TEMP0 COLOR VS1-VS5 __vdate;
run;

data VS3;
	set vs2(drop=VSC5);
	format VISITNUM 8.;
	if VS5^=. and VS5 < &LOW5  then VSC5 =  "^{style [foreground=&lowcolor" || strip(color) || "]" ||strip(TEMP0)||'}';
		else if VS5^=. and VS5 > &high5  then VSC5 =  "^{style [foreground=&highcolor" || strip(color) || "]" ||strip(TEMP0)||'}';
			else if VS5 ^=. then  VSC5 =  "^{style [foreground=&normalcolor" || strip(color) || "]" ||strip(TEMP0)||'}';
				else VSC5='';
	%getvnum(visit=visit);
	label
        VSDTC = 'Date'
		VISIT = 'Visit'
		WT0 = 'Weight'
		HT0 = 'Height'
		VSC1 = 'Systolic BP#(mmHg)'
		VSC2 = 'Diastolic BP#(mmHg)'
		VSC3 = 'Heart Rate#(beats/min)'
		VSC4 = 'Respiration Rate#(breaths/min)'
		VSC5 = 'Temperature'
;
	keep SUBJID VISIT VISITNUM VSDTC WT0 HT0 VSC1-VSC5 __vdate;
run;

/*hightlight end*/

proc sort data = vs3 out=vs_out; by SUBJID __vdate VISIT VSDTC; run;

data pdata.vs (label = 'Vital Signs');
    retain SUBJID VISIT VSDTC WT0 HT0 VSC1-VSC5;
    keep SUBJID VISIT VSDTC WT0 HT0 VSC1-VSC5;
    set vs_out;
run;







