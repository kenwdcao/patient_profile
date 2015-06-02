/*
    Program Name: AE.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2013/12/03

    REVISION HISTORY

    2014/03/10 Ken Cao: Rederive culmulative dose for Paclitaxel drug from drug_administration.
    
*/




%include '_setup.sas';

data ae0;
    set source.adverse_event_kxevents;
    attrib
        aeterm                   label = 'Adverse Event'
        aestdtc    length = $20  label = 'First Day/(First Date)'
        aeendtc    length = $20  label = 'Last Day/(Last Date)'
        outcome    length = $40  label = 'Status'
        aerel      length = $40  label = 'Relationship'
        aesev      length = $10  label = 'Severity#(CTCAE Grade)'
        dlt        length = $3   label = 'DLT'
        __aenum    length = $10  label = 'AE Number'
    ;

    %subjid;
    aestdtc = aestdt;
    aeendtc = aeenddt;
    aeterm  = upcase(aeterm);
    outcome = outcm_label;
    aerel   = rel_label;
    aesev   = ifc(sev > ., strip(put(sev, best.)), ' ');
    dlt     = doselim_label;
    __aenum = strip(put(item_group_repeat_key, best.));

    keep subjid aestdtc aeendtc aeterm aestdtc aeendtc outcome aerel aesev dlt  __aenum;
run;

data ae1;
    length subjid $20 __fdosedt 8;
    if _n_ = 1 then
        do;
            declare hash h (dataset: 'pdata.dm');
            rc = h.defineKey('subjid');
            rc = h.defineData('__fdosedt');
            rc = h.defineDone();
            call missing(subjid, __fdosedt);
        end;
    set ae0;
    rc = h.find();
    /*call missing(_dy);  %dy(aestdtc, mmddyy10.); aestdy = _dy; */
    /*call missing(_dy);  %dy(aeendtc, mmddyy10.); aeendy = _dy; */
    /* Ken Cao on 2014/10/24: Informat of AESTDTC and AEENDTC was changed to yyyy-mm-dd in Oct 23 transfer */
    call missing(_dy);  %dy(aestdtc, yymmdd10.); aestdy = _dy; 
    call missing(_dy);  %dy(aeendtc, yymmdd10.); aeendy = _dy; */    if aestdy > . then aestdtc = strip(put(aestdy, best.)) || '/(' || strip(aestdtc) || ')';
    if aeendy > . then aeendtc = strip(put(aeendy, best.)) || '/(' || strip(aeendtc) || ')';

    keep subjid aestdtc aeendtc aeterm aestdtc aeendtc outcome aerel aesev dlt __aenum aestdy aeendy;
run;

************************************************************************************;
* Ken on 2014/03/10:
* Culmulative dose level for drug Paclitaxel -- derive from drug_administration
************************************************************************************;
data _ex0;
    set source.drug_administration;
    where admintyp_label = 'Paclitaxel';
    %subjid;
    length exstdtc $10;
    *exstdtc = put(input(admindt, mmddyy10.), yymmdd10.);
    /* Ken Cao on 2014/10/24: Informat of ADMINDT was changed to yyyy-mm-dd*/
    exstdtc = admindt;
    keep subjid exstdtc doseadm;
run;

%sort(indata = _ex0, sortKey = subjid exstdtc);

data _ex1;
    set _ex0;
        by subjid;
    retain culmdose 8;
    if first.subjid then culmdose = doseadm;
    else culmdose = culmdose + doseadm;
run;

data ae5;
    set ae1/*(drop=culmdose druglvl)*/;
    length aestdtc2 $10;
    aestdtc2 = put(input(scan(aestdtc, 2, '()'), mmddyy10.), yymmdd10.);
run;

proc sql;
    create table ae6 as
    select 
        a.*,
        exstdtc,
        culmdose
    from ae5 as a
    left join _ex1 as b
    on a.subjid = b.subjid and aestdtc2 >= exstdtc
    order by subjid, __aenum, exstdtc
    ;
quit;

data ae7;
    set ae6;
        by subjid __aenum;
    if last.__aenum;
    length druglvl $200;
    if culmdose > . then druglvl = strip(put(culmdose, best.)) || ' mg';
    else druglvl = 'N/A';

   label druglvl='Investigational#Drug Level (mg)#at AE Start';

run;

%sort(indata = ae7, sortkey = subjid aestdy aeendy aeterm);

************************************************************************************;
* Xiu Pan on 2014/03/11:
* Culmulative dose level for Study Drug -- derive from drug_administration
************************************************************************************;
data _ex0_hm;
    set source.drug_administration;
    where admintyp_label = 'Study Drug';
    %subjid;
    length exstdtc $10;
    *exstdtc = put(input(admindt, mmddyy10.), yymmdd10.);
    /* Ken Cao on 2014/10/24: Informat of ADMINDT was changed to yyyy-mm-dd*/
    exstdtc = admindt;
    keep subjid exstdtc doseadm;
run;

%sort(indata = _ex0_hm, sortKey = subjid exstdtc);

data _ex1_hm;
    set _ex0_hm;
        by subjid;
    retain culmdose 8;
    if first.subjid then culmdose = doseadm;
    else culmdose = culmdose + doseadm;
run;

data ae5_hm;
    set ae1;
    length aestdtc2 $10;
    aestdtc2 = put(input(scan(aestdtc, 2, '()'), mmddyy10.), yymmdd10.);
run;

proc sql;
    create table ae6_hm as
    select 
        a.*,
        exstdtc,
        culmdose
    from ae5_hm as a
    left join _ex1_hm as b
    on a.subjid = b.subjid and aestdtc2 >= exstdtc
    order by subjid, __aenum, exstdtc
    ;
quit;

data ae7_hm;
    set ae6_hm;
        by subjid __aenum;
    if last.__aenum;
    length druglvl $200;
    if culmdose > . then druglvl = strip(put(culmdose, best.)) || ' mg';
    else druglvl = 'N/A';
run;

%sort(indata = ae7_hm, sortkey = subjid aestdy aeendy aeterm);

proc sql;
    create table druglvl_1 as
    select a.*,b.druglvl2
    from ae7 as a left join ae7_hm(rename=druglvl=druglvl2) as b
    on a.subjid=b.subjid and a.aeterm=b.aeterm and a.aestdtc=b.aestdtc and a.aeendtc=b.aeendtc
    ;
quit;


data druglvl_2;
    set druglvl_1;
    if druglvl='N/A' and druglvl2='N/A' then druglvl='N/A';
    else if druglvl^='N/A' and druglvl2^='N/A' then druglvl=strip(druglvl)||'(Paclitaxel)'||' + '||strip(druglvl2)||'(HM)';
    else if druglvl='N/A' and druglvl2^='N/A' then druglvl=strip(druglvl2)||'(HM)';
    else if druglvl^='N/A' and druglvl2='N/A' then druglvl=strip(druglvl)||'(Paclitaxel)';

run;

%sort(indata = druglvl_2, sortkey = subjid aestdy aeendy aeterm);

data pdata.ae;
    retain subjid aeterm aestdtc aeendtc outcome aerel aesev dlt druglvl __aenum;
/*    set ae4;*/
    set druglvl_2;
    keep subjid aeterm aestdtc aeendtc outcome aerel aesev dlt druglvl __aenum;
run;


