/*********************************************************************
 Program Nmae: EG.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/10
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc format;
    value $egtestcd
    'QTcF Interval' = 'QTCF'
    'PR Interval' = 'PR'
    'QRS Interval' = 'QRS'
    'QT Interval' = 'QT'
    'RR Interval' = 'RR'
    'Ventricular Rate' = 'VENTRATE'
    'Ventricular rate' = 'VENTRATE'
    ;
run;

data eg1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.eg;
    %subject;
     %visit2;
    ** Assessment Date;
    length egdtc $20;
    label egdtc = 'Assessment Date';
     if egdt^=. then egdtc=put(egdt,yymmdd10.);else egdtc="";
    rc = h.find();
    %concatDY(egdtc);
    drop egdt rc;

    ** Assessment Time;
    length egtmc $10;
    label egtmc = 'Time';
   
     if egtm^=. then egtmc=put(egtm, time5.); else egtmc="";
    if egtmunk ^=. then egtmc = 'Unknown';
    drop egtm egtmunk; 


    ** EGTESTCD;
    length egtestcd $8;
    label egtestcd = 'ECG Test Code';
    egtestcd = put(egtest, $egtestcd.);


    ** EGTEST;
    length egtest2 $255;
    egtest2 = egtest;

    if egtest2 = 'QTcF Interval' then egtest2 = strip(egtest2)||'#(msec)';
    else if egtest2 = 'PR Interval' then egtest2 = strip(egtest2)||'#(msec)';
    else if egtest2 = 'QRS Interval' then egtest2 = strip(egtest2)||'#(msec)';
    else if egtest2 = 'QT Interval' then egtest2 = strip(egtest2)||'#(msec)';
    else if egtest2 = 'RR Interval' then egtest2 = strip(egtest2)||'#(msec)';
    else if egtest2 = 'Ventricular Rate' or egtest2 = 'Ventricular rate' then egtest2 = 'Ventricular Rate' ||'#(beats/min)';
      
format egstat egrtype1  egrtype2 egrtype3 checked.; 
run;


/* Transpose */
data tripeg0;
    keep __edc_treenodeid __edc_entrydate subject egdtc egtmc  visit2  egtestcd egtest2 egspid egorres egstat egavqtcf
egdtc egoccur1 egrtype1  egrtype2 egrtype3 egrtypeo  
           egoccur2 egoccur3  egabnoth;
    set eg1;
run;

proc sort data = tripeg0; by __edc_treenodeid egspid subject  visit2  egdtc  __edc_entrydate  egstat egavqtcf  egoccur1 egrtype1  egrtype2 egrtype3 egrtypeo  
           egoccur2 egoccur3  egabnoth;  run;

proc transpose data = tripeg0 out = t_tripeg0;
    by __edc_treenodeid egspid subject  visit2  egdtc  __edc_entrydate egstat egavqtcf  egoccur1 egrtype1  egrtype2 egrtype3 egrtypeo  
           egoccur2 egoccur3  egabnoth;
    id egtestcd;
    idlabel egtest2;
    var egorres;
run;


/*  ECG time */
data ecgtm;
    keep __edc_treenodeid egspid egtmc;
    set eg1;
    where egtmc > ' ';
run;

/*  AVQTCF */
data avqtcf;
    keep __edc_treenodeid egspid  EGAVQTCF;
    set eg1;
    where EGAVQTCF > ' ';
run;

proc sort data = ecgtm nodupkey; by  __edc_treenodeid egspid; run;
proc sort data = t_tripeg0 nodupkey; by  __edc_treenodeid egspid; run;
proc sort data = avqtcf nodupkey; by  __edc_treenodeid egspid; run;
data t_tripeg;
    merge t_tripeg0  ecgtm avqtcf;
        by __edc_treenodeid egspid;
run;



proc sort data = t_tripeg; by subject egdtc egtmc visit2 egspid; run;
data pdata.eg1(label='Electrocardiogram - (Screening)');
    retain __edc_treenodeid __edc_entrydate subject visit2 egstat egdtc egtmc  egspid qtcf egavqtcf qt ventrate pr rr qrs;
    keep __edc_treenodeid __edc_entrydate subject visit2 egstat egdtc egtmc egspid qtcf egavqtcf qt ventrate pr rr qrs;
    set t_tripeg;
    if visit2="Screening";
    label egstat = 'Not Done';
run;


data pdata.eg2(label='Electrocardiogram - (Screening) (Continued)');
    retain __edc_treenodeid __edc_entrydate subject visit2 egdtc egspid egoccur1 egrtype1  egrtype2 egrtype3 egrtypeo 
    egoccur2 egoccur3  egabnoth; ;
    keep __edc_treenodeid __edc_entrydate subject visit2 egdtc egspid egoccur1 egrtype1  egrtype2 egrtype3 egrtypeo
    egoccur2 egoccur3  egabnoth; ;
    set t_tripeg;
    
    label egoccur1 = 'Is the Rhythm abnormal?';
    label egrtype1 = 'Atrial fibrillation@:If Yes, specify the type of rhythm abnormality';
    label egrtype2 = 'Atrial flutter@:If Yes, specify the type of rhythm abnormality';
    label egrtype3 = 'Supraventricular tachycardia (SVT)@:If Yes, specify the type of rhythm abnormality';
    label egrtypeo = 'Other (Specify)@:If Yes, specify the type of rhythm abnormality';
    label egoccur2 = 'Left Branch Bundle Block (LBBB)?';
    label egoccur3 = 'Right Branch Bundle Block (RBBB)?';
    label egabnoth = 'Other abnormalities reported (Specify)';
    if visit2="Screening";
run;


data pdata.eg3(label='Electrocardiogram - (End of Treatment- Single Measurement)');
    retain __edc_treenodeid __edc_entrydate subject visit2 egstat egdtc egtmc  qtcf  qt ventrate pr rr qrs;
    keep __edc_treenodeid __edc_entrydate subject visit2 egstat egdtc egtmc  qtcf  qt ventrate pr rr qrs;
    set t_tripeg;
        if visit2="End of Treatment";
    label egstat = 'Not Done';
run;



data pdata.eg4(label='Electrocardiogram - (End of Treatment- Single Measurement) (Continued)');
    retain __edc_treenodeid __edc_entrydate subject visit2 egdtc egtmc egoccur1 egrtype1  egrtype2 egrtype3 egrtypeo  
           egoccur2 egoccur3  egabnoth;
    keep __edc_treenodeid __edc_entrydate subject visit2 egdtc egtmc egoccur1 egrtype1  egrtype2 egrtype3 egrtypeo  
           egoccur2 egoccur3  egabnoth;
    set t_tripeg;

    label egoccur1 = 'Is the Rhythm abnormal?';
    label egrtype1 = 'Atrial fibrillation@:If Yes, specify the type of rhythm abnormality';
    label egrtype2 = 'Atrial flutter@:If Yes, specify the type of rhythm abnormality';
    label egrtype3 = 'Supraventricular tachycardia (SVT)@:If Yes, specify the type of rhythm abnormality';
    label egrtypeo = 'Other (Specify)@:If Yes, specify the type of rhythm abnormality';
    label egoccur2 = 'Left Branch Bundle Block (LBBB)?';
    label egoccur3 = 'Right Branch Bundle Block (RBBB)?';
    label egabnoth = 'Other abnormalities reported (Specify)';

    if visit2="End of Treatment";
run;

