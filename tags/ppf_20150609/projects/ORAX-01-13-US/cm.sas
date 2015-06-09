/*
    Program Name: CM.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2013/12/03


    REVISION HISTORY

    2014/03/10 Ken Cao: Rederive culmulative dose for Paclitaxel drug from drug_administration.

*/


%include '_setup.sas';


data cm0;
    set source.gg_concomitant_medicationscm;
    attrib
        _route       length = $200       
        cmtrt2       length = $200       label = 'Concomitant Medication (Route)'
        cmstdtc      length = $200       label = 'First Day/(First Date)'
        cmendtc      length = $200       label = 'Last Day/(Last Date)'
        status       length = $200       label = 'Status#(Continuing?)'
        __cmnum      length = $10        label = 'CM Number'
    ;
    %subjid;
    _route  = coalescec(routeoth, route_label);
    if cmtrt^='' and _route^='' then cmtrt2  = strip(cmtrt) || '(' || strip(_route) || ')';
        else if cmtrt^='' and  _route='' then  cmtrt2  = strip(cmtrt);
    cmstdtc = cmstdt_min;
    cmendtc = cmenddt_max;
    status  = continue_label;
    doslvl  = strip(put(270*2, best.)) || ' mg';
    __cmnum = strip(put(item_group_repeat_key, best.));

    if cmtrt='' and doseu='' and cmstdtc='' and cmendtc='' then delete;
    keep subjid cmtrt2 cmstdtc cmendtc status __cmnum doseu;
run;

data cm1;
    length subjid $20 __fdosedt 8;
    if _n_ = 1 then
        do;
            declare hash h (dataset: 'pdata.dm');
            rc = h.defineKey('subjid');
            rc = h.defineData('__fdosedt');
            rc = h.defineDone();
            call missing(subjid, __fdosedt);
        end;
    set cm0;
    rc = h.find();
    /*
    call missing(_dy);  %dy(cmstdtc, mmddyy10.); cmstdy = _dy;
    call missing(_dy);  %dy(cmendtc, mmddyy10.); cmendy = _dy;
    */
    /* Ken Cao on 2014/10/24: Informat of CMSTDTC and CMENDTC was changed to yyyy-mm-dd in Oct 23 transfer */
    call missing(_dy);  %dy(cmstdtc, yymmdd10.); cmstdy = _dy;
    call missing(_dy);  %dy(cmendtc, yymmdd10.); cmendy = _dy;
    if cmstdy > . then cmstdtc = strip(put(cmstdy, best.)) || '/(' || strip(cmstdtc) || ')';
    if cmendy > . then cmendtc = strip(put(cmendy, best.)) || '/(' || strip(cmendtc) || ')';

    keep subjid cmtrt2 cmstdtc cmendtc status  __cmnum cmstdy cmendy doseu; 

/*    if cmstdy > 0;*/
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
    /* Ken Cao on 2014/10/24: Informat of ADMINDT was changed to yyyy-mm-dd */
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

data cm5;
    set cm1/*(drop=druglvl)*/;
    length cmstdtc2 $10;
    *cmstdtc2 = put(input(scan(cmstdtc, 2, '()'), mmddyy10.), yymmdd10.);
    /* Ken Cao on 2014/10/24: Informat of CMSTDTC was changed to yyyy-mm-dd format in Oct 23 transfer */
    cmstdtc2 = scan(cmstdtc, 2, '()');
run;

proc sql;
    create table cm6 as
    select 
        a.*,
        exstdtc,
        culmdose
    from cm5 as a
    left join _ex1 as b
    on a.subjid = b.subjid and cmstdtc2 >= exstdtc
    order by subjid, __cmnum, exstdtc
    ;
quit;

data cm7;
    set cm6;
        by subjid __cmnum;
    if last.__cmnum;
    length druglvl $200;
    if culmdose > . then druglvl = strip(put(culmdose, best.)) || ' mg';
    else druglvl = 'N/A';

   label druglvl='Investigational#Drug Level (mg)#at CM Start';

run;

%sort(indata = cm7, sortkey = subjid cmstdy cmendy cmtrt2);

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
    /* Ken Cao on 2014/10/24: Informat of ADMINDT was changed to yyyy-mm-dd */
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

data cm5_hm;
    set cm1;
    length cmstdtc2 $10;
    *cmstdtc2 = put(input(scan(cmstdtc, 2, '()'), mmddyy10.), yymmdd10.);
    /* Ken Cao on 2014/10/24: Informat of CMSTDTC was changed to yyyy-mm-dd format in Oct 23 transfer */
    cmstdtc2 = scan(cmstdtc, 2, '()');
run;

proc sql;
    create table cm6_hm as
    select 
        a.*,
        exstdtc,
        culmdose
    from cm5_hm as a
    left join _ex1_hm as b
    on a.subjid = b.subjid and cmstdtc2 >= exstdtc
    order by subjid, __cmnum, exstdtc
    ;
quit;

data cm7_hm;
    set cm6_hm;
        by subjid __cmnum;
    if last.__cmnum;
    length druglvl $200;
    if culmdose > . then druglvl = strip(put(culmdose, best.)) || ' mg';
    else druglvl = 'N/A';
run;

%sort(indata = cm7_hm, sortkey = subjid cmstdy cmendy cmtrt2);


proc sql;
    create table druglvl_1 as
    select a.*,b.druglvl2
    from cm7 as a left join cm7_hm(rename=druglvl=druglvl2) as b
    on a.subjid=b.subjid and a.cmtrt2=b.cmtrt2 and a.cmstdtc=b.cmstdtc and a.cmendtc=b.cmendtc and a.doseu=b.doseu
    ;
quit;

data druglvl_2;
    set druglvl_1;
    if druglvl='N/A' and druglvl2='N/A' then druglvl='N/A';
    else if druglvl^='N/A' and druglvl2^='N/A' then druglvl=strip(druglvl)||'(Paclitaxel)'||' + '||strip(druglvl2)||'(HM)';
    else if druglvl='N/A' and druglvl2^='N/A' then druglvl=strip(druglvl2)||'(HM)';
    else if druglvl^='N/A' and druglvl2='N/A' then druglvl=strip(druglvl)||'(Paclitaxel)';

run;

%sort(indata = druglvl_2, sortkey = subjid cmstdy cmstdtc cmendy cmendtc cmtrt2);

data pdata.cm;
    retain subjid cmtrt2 cmstdtc cmendtc status druglvl __cmnum;
/*    set cm4;*/
    set druglvl_2;
    keep subjid cmtrt2 cmstdtc cmendtc status druglvl __cmnum;
run;


        
