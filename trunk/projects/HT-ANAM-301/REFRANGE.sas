%include '_setup.sas';

* ---> Appendix 3: Reference Range of Vital Signs and ECG;
data pdata.REFRANGE(label='Appendix 2: Reference Range of Vital Signs and ECG');
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
	item='PR Interval (mesc)';        low=&PRLOW;    		    high=&PRHIGH;              output;
	item='QRS Interval (mesc)';       low=&QRSLOW;    	     	high=&QRSHIGH;            output;
	item='QT Interval (mesc)';        low=&QTLOW;    		    high=&QTHIGH;             output;
	item='QTcF Interval (mesc)';       low=&QTCFLOW;    		    high=&QTCFHIGH;           output;

run;
*----------------------------------------------------------------------------------------------------------->;
