
* Program Name: EG.sas;
* Author: Hawk Hou (tianfeng.hou@januscri.com);
* Initial Date: 19/02/2014;


%include '_setup.sas';

*;
data ecg0;
	retain SUBJID VISIT EGDTC ECGHR0 ECGPR0 ECGRR0 ECGQRS0 ECGQT0 ECGRES0 ECGABNSP0 __vdate;
	set source.ecg;
	%subjid;
    length egdtc $20 visit $40;
	%getCycle();
	VISIT = __visit;
	%getDate(leadq = ecgpf, numdate = ecgdt);
	ECGTMC = put(ECGTM, time8.);
	if strip(ECGTMC) ^='.' and length(strip(ECGTMC)) < 8 then ECGTMC = '0' || strip(ECGTMC);
	if __date ^= '' and __date ^='NOT DONE' then EGDTC = strip(__date) || 'T' || substr(strip(ECGTMC), 1, 5);
		else EGDTC = __date;
	ECGRES = UPCASE(ECGRES);	
	if ECGHR ^= . then ECGHR0=strip(put(ECGHR,best.)); else ECGHR0='';
	if ECGPR ^= . then ECGPR0=strip(put(ECGPR,best.)); else ECGPR0='';
	if ECGRR ^= . then ECGRR0=strip(put(ECGRR,best.)); else ECGRR0='';
	if ECGQRS ^= . then ECGQRS0=strip(put(ECGQRS,best.)); else ECGQRS0='';
	if ECGQT ^= . then ECGQT0=strip(put(ECGQT,best.)); else ECGQT0='';
	if ECGRES ^= '' then ECGRES0=upcase(strip(ECGRES)); else ECGRES0='';
	if ECGABNSP ^= '' then ECGABNSP0=strip(ECGABNSP); else ECGABNSP0='';
	label
        EGDTC = 'Date'
		VISIT = 'Visit'
		ECGHR0 = 'Heart Rate#(bpm)'
		ECGPR0 = 'PR interval#(msec)'
		ECGRR0 = 'RR interval#(Seconds)'
		ECGQRS0 = 'QRS duration#(msec)'
		ECGQT0 = 'QT interval#(msec)'
		ECGRES0 = 'Result'
		ECGABNSP0 = 'Abnormal specify'
;
	keep 
	SUBJID VISIT EGDTC ECGHR0 ECGPR0 ECGRR0 ECGQRS0 ECGQT0 ECGRES0 ECGABNSP0 __vdate;
run;

/*red-above; blue-lower; green-normal*/
*Heart Rate (bmp);
%let low1=50;
%let high1=100;
*PR interval(msec);
%let low2=120;
%let high2=200;
*RR interval(Seconds);
%let low3=0.6;
%let high3=1;
*QRS duration(msec);
%let low4=60;
%let high4=109;
*QT Interval (mesc);
%let low5=320;
%let high5=450;

%let normalcolor = black;
%let lowcolor = blue;
%let highcolor = red;

data ecg1;
	set ecg0;
	length ecg1-ecg5 8 ecgc1-ecgc5 $200;
	if ECGHR0^='' then ecg1=input(ECGHR0,best.);
	if ECGPR0^='' then ecg2=input(ECGPR0,best.);
	if ECGRR0^='' then ecg3=input(ECGRR0,best.);
	if ECGQRS0^='' then ecg4=input(ECGQRS0,best.);
	if ECGQT0^='' then ecg5=input(ECGQT0,best.);

	array ecg{*} ecg1-ecg5;
	array ecgc{*} ecgc1-ecgc5;
	array rangelow{*} low1-low5 (&low1 &low2 &low3 &low4 &low5);
	array rangehigh{*} high1-high5 (&high1 &high2 &high3 &high4 &high5);
	length color $10;
	do i = 1 to dim(ecg);
		if ecg[i] ^= . then 
			do;
				if ecg[i] < rangelow[i] then color = "&lowcolor";
				else if ecg[i] > rangehigh[i] then color = "&highcolor";
				else color = "&normalcolor";
				ecgc[i] =  "^{style [foreground=" || strip(color) || "]" ||strip(put(ecg[i],best.))||'}';
			end;
		else
			do;
			ecgc[i] = '';	
			end;
	end;
	label
        EGDTC = 'Date'
		VISIT = 'Visit'
		ECGC1 = 'Heart Rate#(bpm)'
		ECGC2 = 'PR interval#(msec)'
		ECGC3 = 'RR interval#(Seconds)'
		ECGC4 = 'QRS duration#(msec)'
		ECGC5 = 'QT interval#(msec)'
		ECGRES0 = 'Result'
		ECGABNSP0 = 'Abnormal specify'
;
	keep SUBJID VISIT EGDTC ECGC1-ECGC5 ECGRES0 ECGABNSP0 __vdate;
run;

/*hightlight end*/

data ecg2;
	set ecg1;
	format visitnum 8. ECGRES $200.;
	%getvnum(visit=visit);
	if upcase(ECGRES0)="ABNORMAL, CS" then ECGRES =  "^{style [foreground=&abncscolor]" ||strip(ECGRES0)||'}';
		else if upcase(ECGRES0)="ABNORMAL, NCS" then ECGRES =  "^{style [foreground= &abnncscolor]" ||strip(ECGRES0)||'}';
			else ECGRES = upcase(strip(ECGRES0));
	label
        ECGRES = 'Result'
		;
	keep SUBJID VISITNUM VISIT EGDTC ECGC1-ECGC5 ECGRES ECGABNSP0 __vdate;
run;

proc sort data = ecg2 out=ecg_out ; by SUBJID __vdate VISIT EGDTC; run;

data pdata.eg (label = 'Electrocardiogram');
    retain SUBJID VISIT EGDTC ECGC1-ECGC5 ECGRES ECGABNSP0;
    keep SUBJID VISIT EGDTC ECGC1-ECGC5 ECGRES ECGABNSP0;
    set ecg_out;
run;







