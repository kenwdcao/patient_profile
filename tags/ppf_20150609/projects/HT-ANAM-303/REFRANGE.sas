
%include '_setup.sas';

*--->Magic Numbers (Normal Range);
%let SYSBPLOW=90;
%let SYSBPHIGH=140;
%let DIABPLOW=50;
%let DIABPHIGH=90;
%let HRLOW=50;
%let HRHIGH=100;
%let TEMPLOW=35.5;
%let TEMPHIGH=37.8;
%let RESPLOW=12;
%let RESPHIGH=18;

* ---> Appendix 3: Reference Range of Vital Signs;
data pdata.refrange(label='Appendix 2: Reference Range of Vital Signs');
	attrib
		item	length=$200		label='Item'
		low		length=8		label='Lower Limit'
		high	length=8		label='Upper Limit'
	;
	item='Temperature (°C)';	      low=&TEMPLOW;		 	    high=&TEMPHIGH;	          output;
	item='Heart Rate (bmp)';          low=&HRLOW;       		high=&HRHIGH;             output;
	item='Respiratory Rate (rpm)';	  low=&RESPLOW;				high=&RESPHIGH;			  output;
	item='Systolic BP (mmHg)';        low=&SYSBPLOW;    		high=&SYSBPHIGH;          output;
	item='Diastolic BP (mmHg)';       low=&DIABPLOW;    		high=&DIABPHIGH;          output;

run;
