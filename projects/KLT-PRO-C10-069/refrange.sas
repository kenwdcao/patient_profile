%include '_setup.sas';

* ---> Appendix 3: Reference Range of Vital Signs and ECG;
data REFRANGE1;
	attrib
		item	length=$200		label='Item'
		low		length=8		label='Lower Limit'
		high	length=8		label='Upper Limit'
	;
	item='Temperature (C)';	      low=&TEMPLOW;		 	    high=&TEMPHIGH;	          output;
	item='Temperature (F)';	      low=&TEMPLOW_F;		 	    high=&TEMPHIGH_F;	          output;
	item='Heart Rate (beats/min)';          low=&HRLOW;       		high=&HRHIGH;             output;
	item='Respiration Rate (breaths/min)';	  low=&RESPLOW;				high=&RESPHIGH;			  output;
	item='Systolic Blood Pressure (mmHg)';        low=&SYSBPLOW;    		high=&SYSBPHIGH;          output;
	item='Diastolic Blood Pressure (mmHg)';       low=&DIABPLOW;    		high=&DIABPHIGH;          output;
run;
data REFRANGE_;
	LENGTH LOW HIGH $20;
	SET REFRANGE1(RENAME=(low=low1 high=high1));
	low=strip(put(low1,best.));
	high=strip(put(high1,best.));
	drop low1 high1;
run;
data pdata.REFRANGE(label='Appendix 1: Reference Range of Vital Signs');
	RETAIN item LOW HIGH;
	KEEP item LOW HIGH;
	SET REFRANGE_;
run;

*----------------------------------------------------------------------------------------------------------->;
