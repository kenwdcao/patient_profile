/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/16
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.ecg out=s_ecg nodupkey; by _all_; run;


**** Electrocardiogram ***;
data ecg;
     length subject $255 rfstdtc $10;
     if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
     end;

      set s_ecg(rename=(id=__id egnd=in_egnd egdtc=in_egdtc));

	  %subject;
      rc = h.find();
      length egdtc $20;   
      egdtc = in_egdtc;
     %concatDY(egdtc);

	  length measure result formula othersp $200 time $8;
	  
	  *** ECG not done ****;
      if in_egnd=1 then egnd="Yes";
	  measure=''; time=''; result=''; formula=''; othersp='';
	  if egnd^='' then output;

	  *** 1st measurement ***;
	  measure=''; time=''; result=''; formula=''; othersp='';
	  measure='1st Measurement';
	  time=strip(egtm1c);
	  if egnd1^=. then eg_nd='Not Done';
	  if egorres1^=. then result_1=strip(put(egorres1, best.));
	  if result_1^='' and eg_nd^='' then do; result=strip(result_1)||' | '||strip(eg_nd); end;
	    else do; result=strip(coalescec(result_1, eg_nd)); end;
	  if egqtc1^=. then formula=strip(put(egqtc1, egqtc_a.));
      othersp=strip(egqtco1);
	  if cmiss(time, result, formula, othersp)<4 then output;

	  *** 2nd measurement ***;
	  measure=''; time=''; result=''; formula=''; othersp='';
	  measure='2nd Measurement';
	  time=strip(egtm2c);
	  if egnd2^=. then eg_nd='Not Done';
	  if egorres2^=. then result_2=strip(put(egorres2, best.));
	  if result_2^='' and eg_nd^='' then do; result=strip(result_2)||' | '||strip(eg_nd); end;
	    else do; result=strip(coalescec(result_2, eg_nd)); end;
	  if egqtc2^=. then formula=strip(put(egqtc2, egqtc_a.));
      othersp=strip(egqtco2);
	  if cmiss(time, result, formula, othersp)<4 then output;

	  *** 3rd measurement ***;
	  measure=''; time=''; result=''; formula=''; othersp='';
	  measure='3rd Measurement';
	  time=strip(egtm1c);
	  if egnd3^=. then eg_nd='Not Done';
	  if egorres3^=. then result_3=strip(put(egorres3, best.));
	  if result_3^='' and eg_nd^='' then do; result=strip(result_3)||' | '||strip(eg_nd); end;
	    else do; result=strip(coalescec(result_3, eg_nd)); end;
	  if egqtc3^=. then formula=strip(put(egqtc3, egqtc_a.));
      othersp=strip(egqtco3);
	  if cmiss(time, result, formula, othersp)<4 then output;

run;

proc sort data=ecg; by subject  egdtc  event_no  measure; run;

data pdata.ecg(label="Electrocardiogram");
     retain __id subject __event_no event_id egnd measure egdtc time result formula othersp;
     set ecg (rename=(event_no=__event_no));
	 attrib
     event_id          label = "Visit"
     egnd                label = "ECG Not Done"
     measure                label = "Measurement"
     egdtc              label = "Assessment Date"
     time                label = "Assessment Time"
     result                label = "QTc Result#(msec)"
     formula                label = "QTc Formula"
     othersp                label = "If Other Formula, specify"

	 ;
	 keep __id subject __event_no event_id egnd measure egdtc time result formula othersp;
run;
