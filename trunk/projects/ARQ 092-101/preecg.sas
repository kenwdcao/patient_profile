%include '_setup.sas';

proc sql;
    create table preecg0 as
    select 
        a.subid,
        a.event_no,
        event_id,
        id,
        parent,
        etnum,
        etnumnd,
        etdtc,
        ettmc,
        etres,
        ethr,
        ethrnd,
        etprin,
        etprnd,
        etrrin,
        etrrnd,
        etqrs,
        etqrsnd,
        etqt,
        etqtnd,
        etqtc,
        etqtcnd
    from source.preecg as a
    inner join
    (select subid, event_no from source.preecg where etres = 2 or event_no = 1) as b
    on a.subid = b.subid
    and a.event_no = b.event_no;
;
quit;


data preecg1;
    set preecg0;
    %formatDate(etdtc);

    length etdtc2 $20;
    etdtc2 = etdtc2||ifc(ettmc>' ', 'T'||strip(ettmc), ' ');

    length  etnum2 $20;
    etnum2 = strip(put(etnum, best.))||ifc(etnumnd>., ' NOT DONE', ' ');


    length ethr2 etprin2 etrrin2 etqrs2 etqt2 etqtc2 $40;
    array chrrslt{*} ethr2 etprin2 etrrin2 etqrs2 etqt2 etqtc2;
    array numrslt{*} ethr etprin etrrin etqrs etqt etqtc;
    array nd{*} ethrnd etprnd etrrnd etqrsnd etqtnd etqtcnd;

    do i = 1 to dim(chrrslt);
       chrrslt[i] = ifc(numrslt[i]>., strip(put(numrslt[i], best.)), 'NOT DONE');
    end;

    length __label $255;

    __label = "Pre-ECG in Triple (Baseline and Abnormal Values)&escapechar.2n";
    __label = strip(__label)||"&escapechar{style [foreground=black fontsize=8pt]Note: If ECG is abnormal in single tracing, the other two tracing will also be shown below.}";

    keep subid id parent event_no event_id etdtc2 etnum2 etres ethr2 etprin2 etrrin2 etqrs2 etqt2 etqtc2 __label;

    label 
        event_id    =   'Visit'
        etnum2      =   'Pre Tracing Number'
        etres       =   'Pre Results'
        etdtc2      =   'Date/Time of ECG'
        ethr2       =   'Pre Heart Rate#(bpm)' 
        etprin2     =   'Pre PR Interval#(msec)'
        etrrin2     =   'Pre RR Interval#(msec)'
        etqrs2      =   'Pre QRS Duration#(msec)'
        etqt2       =   'Pre QT Interval#(msec)'
        etqtc2      =   'Pre QTc Intreval#(msec)'
        ;

run;

data pdata.preecg(label="Pre-ECG in Triple (Baseline and Abnormal Values)");
    retain subid event_id etdtc2 etnum2 etres ethr2 etprin2 etrrin2 etqrs2 etqt2 etqtc2 __label;
    keep subid event_id etdtc2 etnum2 etres ethr2 etprin2 etrrin2 etqrs2 etqt2 etqtc2 __label;
    set preecg1;
run;
