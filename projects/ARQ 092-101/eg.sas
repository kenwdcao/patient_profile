%include '_setup.sas';

data eg0;
    set source.eg;
    where egyn = 1 and (event_id = 'Pre-Study Visit' or egorres > 1);
    %formatDate(egdtc);

    length eghr2 egprint2 egrrint2 egdur2 egqtint2 egqtcint2 $40;
    array chrrslt{*} eghr2 egprint2 egrrint2 egdur2 egqtint2 egqtcint2;
    array numrslt{*} eghr egprint egrrint egdur egqtint egqtcint;
    array nd{*} eghrnd egprnd egrrnd egdurnd egqtnd egqtcnd;

    do i = 1 to dim(chrrslt);
       chrrslt[i] = ifc(numrslt[i]>., strip(put(numrslt[i], best.)), 'NOT DONE');
    end;

    length egdtc2 $20;
    egdtc2 = egdtc||ifc(egtmc>' ', 'T'||strip(egtmc), ' ');


    length visit $200;
    visit=strip(put(event_id,$visit.));
    visitnum=input(put(event_id,$vnum.),best.);


    keep subid visitnum visit egdtc2 egtmc egorres eghr2 egprint2 egrrint2 egdur2 egqtint2 egqtcint2;
    

    label 
        visit       =   'Visit'
        egdtc2      =   'Date/Time of ECG'
        egorres     =   'Results'
        eghr2       =   'Heart Rate#(bpm)' 
        egprint2    =   'PR Interval#(msec)'
        egrrint2    =   'RR Interval#(msec)'
        egdur2      =   'QRS Duration#(msec)'
        egqtint2    =   'QT Interval#(msec)'
        egqtcint2   =   'QTc Intreval#(msec)'
        ;
run;

proc sort data = eg0; by subid egdtc2; run;

data pdata.eg(label='12 Lead ECG (Baseline and Abnormal Values)');
    retain subid visit egdtc2 egorres eghr2 egprint2 egrrint2 egdur2 egqtint2 egqtcint2;
    keep subid visit egdtc2 egorres eghr2 egprint2 egrrint2 egdur2 egqtint2 egqtcint2;
    set eg0;
run;
