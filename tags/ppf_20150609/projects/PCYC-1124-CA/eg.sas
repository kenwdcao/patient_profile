/*********************************************************************
 Program Nmae: EG.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data eg0;
    set source.eg;
    %subject;
    keep edc_treenodeid subject visit egnd egtmunk egspid egtest egres egunit egfor egoccur1 egforo egtype1 
         egtype2 egtype3 egtype4 egtypeo egoccur2 egoccur3 egoccur4 egoccuro seq egdt egtm edc_entrydate  ;
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
run;

proc format;
    value $egtestcd
    'QTc' = 'QTC'
    'PR Interval' = 'PR'
    'QRS Interval' = 'QRS'
    'QT Interval' = 'QT'
    'RR Interval' = 'RR'
    'Ventricular Rate' = 'VENTRATE'
    ;
run;


data eg1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set eg0;

    ** Assessment Date;
    length egdtc $20;
    label egdtc = 'Assessment Date';
    %ndt2cdt(ndt=egdt, cdt=egdtc);
    rc = h.find();
    %concatDY(egdtc);
    drop egdt rc;

    ** Assessment Time;
    length egtmc $10;
    label egtmc = 'Time';
    %ntime2ctime(ntime=egtm, ctime=egtmc);
    if egtmunk > ' ' then egtmc = 'Unknown';
    drop egtm egtmunk; 



    ** VISIT;
    length cycle $10;
    cycle = cycle; ** make a dummy variable;
    %visit;



    ** EGTESTCD;
    length egtestcd $8;
    label egtestcd = 'ECG Test Code';
    egtestcd = put(egtest, $egtestcd.);


    ** EGTEST;
    length egtest2 $255;
    egtest2 = egtest;

    if egtest2 = 'QTc' then egtest2 = strip(egtest2)||'#(msec)';
    else if egtest2 = 'PR Interval' then egtest2 = strip(egtest2)||'#(msec)';
    else if egtest2 = 'QRS Interval' then egtest2 = strip(egtest2)||'#(msec)';
    else if egtest2 = 'QT Interval' then egtest2 = strip(egtest2)||'#(msec)';
    else if egtest2 = 'RR Interval' then egtest2 = strip(egtest2)||'#(msec)';
    else if egtest2 = 'Ventricular Rate' then egtest2 = strip(egtest2)||'#(beats/min)';
        

    ** Expand length of ECG result;
    length egorres $255;
    label egorres = 'ECG Result';
    egorres = egres;
    drop egres;

    ** QTC Formula;
    length _egfor $200;
    label _egfor = 'QTc Formula';
    if egforo > ' ' then _egfor = egforo;
    else _egfor = egfor;
    drop egfor egforo;

run;


/* Triple ECG measurements */
data tripeg0;
    keep __edc_treenodeid __edc_entrydate subject egdtc visit2 egtestcd egtest2 egspid egorres;
    set eg1;
run;

proc sort data = tripeg0; by __edc_treenodeid egspid egtestcd;  run;

proc transpose data = tripeg0 out = t_tripeg0;
    by __edc_treenodeid egspid subject visit2 egdtc __edc_entrydate;
    id egtestcd;
    idlabel egtest2;
    var egorres;
run;

/* QTC formula */
data qtcf;
    keep __edc_treenodeid egspid _egfor;
    set eg1;
    where egtestcd = 'QTC';
run;

/* ECG Time */
data ecgtm;
    keep __edc_treenodeid egspid egtmc egnd;
    set eg1;
    where egtmc > ' ';
run;
proc sort data = ecgtm nodupkey; by  __edc_treenodeid egspid; run;
proc sort data = qtcf nodupkey; by  __edc_treenodeid egspid; run;
data t_tripeg;
    merge t_tripeg0 qtcf ecgtm;
        by __edc_treenodeid egspid;
run;





/*!-- Final Datasets --*/

proc sort data = t_tripeg; by subject egdtc egspid; run;
data pdata.eg1(label='Electrocardiogram - Triple Measurements');
    retain __edc_treenodeid __edc_entrydate subject visit2 egdtc egtmc  egspid  egnd qtc _egfor qt ventrate pr rr qrs;
    keep __edc_treenodeid __edc_entrydate subject visit2 egdtc egtmc  egspid  egnd qtc _egfor qt ventrate pr rr qrs;
    set t_tripeg;
run;


proc sort data = eg1 nodupkey out = eg2(keep=__edc_treenodeid __edc_entrydate subject visit2 egdtc egtype: egoccur:);
    by subject egdtc visit2; 
run;

data pdata.eg2(label='Electrocardiogram - Assessment');
    retain __edc_treenodeid __edc_entrydate subject visit2 egdtc egoccur1 egtype1  egtype2 egtype3 egtypeo  
           egoccur2 egoccur3 egoccuro;
    keep __edc_treenodeid __edc_entrydate subject visit2 egdtc egoccur1 egtype1 egtype2 egtype3 egtypeo  
           egoccur2 egoccur3 egoccuro;
    set eg2;

    format egtype1 $checked.;
    format egtype2 $checked.;
    format egtype3 $checked.;

    label egoccur1 = 'Is the Rhythm abnormal?';
    label egtype1 = 'Atrial fibrillation';
    label egtype2 = 'Atrial flutter';
    label egtype3 = 'Supraventricular tachycardia (SVT)';
    label egtypeo = 'Other (Specify)';
    label egoccur2 = 'Left Branch Bundle Block (LBBB)?';
    label egoccur3 = 'Right Branch Bundle Block (RBBB)?';
    label egoccuro = 'Other abnormalities reported (Specify)';
run;
