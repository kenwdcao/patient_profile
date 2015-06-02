/*********************************************************************
 Program Nmae: EG.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc format;
    value $egtestcd
	'QTc' = 'QTC'
/*    'QTcF Interval' = 'QTCF'*/
    'PR Interval' = 'PR'
    'QRS Interval' = 'QRS'
    'QT Interval' = 'QT'
    'RR Interval' = 'RR'
    'Ventricular Rate' = 'VENTRATE'
	'Heart Rate'='HR'
    ;
run;

data eg1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 __rfstdtc $10 egdtc $20 EGORRES $60;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set source.eg;
    %subject;
	 %visit2;
    ** Assessment Date;
    label egdtc = 'Assessment Date';
    %ndt2cdt(ndt=egdt, cdt=egdtc);
    rc = h.find();
    %concatDY(egdtc);

    ** EGTESTCD;
    length egtestcd $8;
    label egtestcd = 'ECG Test Code';
    egtestcd = put(egtest, $egtestcd.);

    ** EGTEST;
    length egtest2 $255;
    egtest2 = egtest;

    if egtest2 in ( 'QTcF Interval'  'PR Interval'  'QRS Interval'  'QT Interval'  'RR Interval' 'QTc' ) then egtest2 = strip(egtest2)||'#(msec)';
    else if egtest2 in( 'Ventricular Rate'  'Heart Rate' ) then egtest2 =strip(egtest2) ||'#(beats/min)';
      
	array aa  egnr  egrtype1  egrtype2 egrtype3;
   do over aa;
    aa=ifc(aa^='' ,put(aa,$checked.),'');
end;

** QTC Formula;
    length _egform $200;
    label _egform = 'QTc Formula';
    if egformo > ' ' then _egform = egformo;
    else _egform = egform;

	if egnr='Yes' then egorres='Not Reported';
run;


/* Transpose */
proc sort data = eg1;
   by __edc_treenodeid  subject  visit2  egdtc  __edc_entrydate     egoccur1 egrtype1  egrtype2 egrtype3 egrtypeo  
           egoccur2 egoccur3  egoccur4 egabnoth; 
run;

proc transpose data = eg1 out = eg_;
    by __edc_treenodeid  subject  visit2  egdtc  __edc_entrydate   egoccur1 egrtype1  egrtype2 egrtype3 egrtypeo  
           egoccur2 egoccur3  egoccur4 egabnoth;
    id egtestcd;
    idlabel egtest2;
    var egorres;
run;

/* QTC formula */
data qtcf;
    keep __edc_treenodeid _egform;
    set eg1;
    where egtestcd = 'QTC';
run;

proc sort data = qtcf nodupkey; by  __edc_treenodeid; run;

data egall;
    merge eg_ qtcf ;
        by __edc_treenodeid ;
run;

proc sort data = egall; by subject egdtc  visit2 ; run;

data pdata.eg1(label='Electrocardiogram');
    retain __edc_treenodeid __edc_entrydate subject visit2 egdtc   qtc _egform qt ventrate  hr pr rr qrs;
    keep __edc_treenodeid __edc_entrydate subject visit2 egdtc  qtc _egform qt ventrate  hr pr rr qrs;
    set egall;
run;


data pdata.eg2(label='Electrocardiogram (Continued)');
    retain __edc_treenodeid __edc_entrydate subject visit2 egdtc egoccur1 egrtype1  egrtype2 egrtype3 egrtypeo egoccur2 egoccur3  egoccur4 egabnoth; 
    keep __edc_treenodeid __edc_entrydate subject visit2 egdtc egoccur1 egrtype1  egrtype2 egrtype3 egrtypeo egoccur2 egoccur3  egoccur4 egabnoth; 
    set egall;
    label egoccur1 = 'Is the Rhythm abnormal?';
    label egrtype1 = 'Atrial fibrillation@:If Yes, specify the type of rhythm abnormality';
    label egrtype2 = 'Atrial flutter@:If Yes, specify the type of rhythm abnormality';
    label egrtype3 = 'Supraventricular tachycardia (SVT)@:If Yes, specify the type of rhythm abnormality';
    label egrtypeo = 'Other (Specify)@:If Yes, specify the type of rhythm abnormality';
    label egoccur2 = 'Left Branch Bundle Block (LBBB)?';
    label egoccur3 = 'Right Branch Bundle Block (RBBB)?';
	label egoccur4 = 'Were any other abnormalities reported?';
    label egabnoth = 'Other abnormalities reported (Specify)';
run;



