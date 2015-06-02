%include '_setup.sas';

proc sql;
    create table pstecg0 as
    select 
        a.subid,
        a.event_no,
        event_id,
        id,
        parent,
        etnum2,
        etnumnd2,
        etdt2c,
        ettm2c,
        etres2,
        ethr2,
        ethrnd2,
        etprin2,
        etpr2nd,
        etrrin2,
        etrr2nd,
        etqrs2,
        etqrs2nd,
        etqt2,
        etqt2nd,
        etqtc2,
        etqtc2nd
    from source.pstecg as a
    inner join
    (select subid, event_no from source.pstecg where etres2 = 2 or event_no = 1) as b
    on a.subid = b.subid
    and a.event_no = b.event_no;
;
quit;


data pstecg1;
    set pstecg0;
    %formatDate(etdt2c);

    length etdtc $20;
    etdtc = etdt2c||ifc(ettm2c>' ', 'T'||strip(ettm2c), ' ');

    length  etnum $20;
    etnum = strip(put(etnum2, best.))||ifc(etnumnd2>., ' NOT DONE', ' ');


    length ethr etprin etrrin etqrs etqt etqtc $40;
    array chrrslt{*} ethr etprin etrrin etqrs etqt etqtc;
    array numrslt{*} ethr2 etprin2 etrrin2 etqrs2 etqt2 etqtc2;
    array nd{*} ethrnd2 etpr2nd etrr2nd etqrs2nd etqt2nd etqtc2nd;

    do i = 1 to dim(chrrslt);
       chrrslt[i] = ifc(numrslt[i]>., strip(put(numrslt[i], best.)), 'NOT DONE');
    end;

    length __label $255;

    __label = "Post-ECG in Triple (Baseline and Abnormal Values)&escapechar.2n";
    __label = strip(__label)||"&escapechar{style [foreground=black fontsize=8pt]Note: If ECG is abnormal in single tracing, the other two tracing will also be shown below.}";

    keep subid id parent event_no event_id etdtc etnum etres2  ethr etprin etrrin etqrs etqt etqtc __label;

    label 
        event_id    =   'Visit'
        etnum       =   'Post Tracing Number'
        etres2      =   'Post Results'
        etdtc       =   'Date/Time of ECG'
        ethr        =   'Post Heart Rate#(bpm)' 
        etprin      =   'Post PR Interval#(msec)'
        etrrin      =   'Post RR Interval#(msec)'
        etqrs       =   'Post QRS Duration#(msec)'
        etqt        =   'Post QT Interval#(msec)'
        etqtc       =   'Post QTc Intreval#(msec)'
        ;

run;

data pdata.pstecg(label="Post-ECG in Triple (Baseline and Abnormal Values)");
    retain subid event_id etnum etres2 ethr etprin etrrin etqrs etqt etqtc __label;
    keep subid event_id etnum etres2 ethr etprin etrrin etqrs etqt etqtc __label;
    set pstecg1;
run;
