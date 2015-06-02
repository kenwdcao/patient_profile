
* Program Name: ref_range.sas;
* Author: Hawk Hou (tianfeng.hou@januscri.com);
* Initial Date: 19/02/2014;


*;

%include '_setup.sas';

data pdata.refrange (label = 'Appendix 1: Reference Range of Vital Signs and ECG');
	format Item $40. Low $8. Upper $8.;
   Item = 'Temperature (C)'; low = '35.5'; upper='37.8';output; 
   Item = 'Heart Rate (bmp)'; low = '50'; upper = '100'; output;
   Item = 'Respiratory Rate (rpm)'; low = '12'; upper = '18'; output;
   Item = 'Systolic BP (mmHg)'; low = '90'; upper = '140'; output;
   Item = 'Diastolic BP (mmHg)'; low = '50'; upper = '90'; output;
   Item = 'PR Interval (mesc)'; low = '120'; upper = '200'; output;
   Item = 'RR interval(Seconds)'; low = '0.6'; upper = '1'; output;
   Item = 'QRS Interval (mesc)'; low = '60'; upper = '109'; output;
   Item = 'QT Interval (mesc)'; low = '320'; upper = '450'; output;
; 
	label
	Item = 'Item'
	Low = 'Lower limit'
	Upper = 'Upper Limit'
;
run;
