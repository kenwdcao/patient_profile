/*
    Program Name: _dose.sas
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2013/12/04

*/

%include '_setup.sas';


/*first dose date*/

data _dose0 ;
    set source.drug_administration;
    where admintyp = 2;
    %subjid;
    attrib
        exdt    length = 8      format = date9.
        phase   length = $20    label ='Phase'
        arm         length = $20    label = 'Arm'
    ;
    *exdt = input(admindt, mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of ADMINDT was changed to yyyy-mm-dd in Oct 23 transfer */
    exdt = input(admindt, yymmdd10.);

    if DRUGPART_LABEL^='' then phase='Part '||strip(DRUGPART_LABEL);
    if length(strip(subjid))=5 then arm='Arm 1';
        else if  length(strip(subjid))=6 then arm='Arm 2';

    keep subjid admindt exdt drugday doseadm drugred phase arm ADMINTM DRUGCYC ;
run;

%sort(indata = _dose0, sortKey = subjid drugday);

data _dose1 ;
    set _dose0;
    attrib
        fdosedt     length = 8      label = 'First Dose Date of Paclitaxel '      format = date9.
    ;
    *fdosedt = input(admindt, mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of ADMINDT was changed to yyyy-mm-dd in Oct 23 transfer */
    fdosedt = input(admindt, yymmdd10.);
run;

proc sort data=_dose1 out=s_dose1; by subjid fdosedt admintm; run;

data _fdose;
    set s_dose1;
    by  subjid fdosedt admintm;
    if first.subjid;
    keep subjid FDOSEDT;
run;

*********************First dose of Study Drug*******************;
data dose_hm ;
    set source.drug_administration;
    where admintyp = 1;
    %subjid;
    *fdosedt2 = input(admindt, mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of ADMINDT was changed to yyyy-mm-dd in Oct 23 transfer */
    fdosedt2 = input(admindt, yymmdd10.);
    format fdosedt2 date9.;
run;

data dose_hm_1 ;
    set dose_hm;
    attrib
        fdosedt     length = 8      label = 'First Dose Date of Paclitaxel '      format = date9.
    ;
    *fdosedt = input(admindt, mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of ADMINDT was changed to yyyy-mm-dd in Oct 23 transfer */
    fdosedt = input(admindt, yymmdd10.);

run;

proc sort data=dose_hm_1 out=s_dose_hm; by subjid fdosedt2 admintm; run;

data _fdose2;
    set s_dose_hm;
    by  subjid fdosedt2 admintm;
    if first.subjid;
    keep subjid FDOSEDT2;
run;

**************************************;

/*culmulative dose*/
proc sort data=_dose1; by subjid DRUGCYC drugday; run;
data _dose2;
    set _dose1;
        by subjid DRUGCYC drugday;
    attrib
        culmdose        length = 8      label = 'Culmulative Dose of Paclitaxel'
    ;
    retain culmdose;
    if first.subjid then culmdose = doseadm;
    else culmdose = culmdose + doseadm;
    drop doseadm;
run;

/*determine dose regimen -- derive from dataset of drug_dispensed*/
proc sort data=source.drug_administration out=s_drug_administration nodupkey; by SSID ADMINTYP_LABEL DOSEADM; run;

proc sql;
    create table disp_adm as
    select a.*,b.DOSEADM, b.DRUGPART_LABEL
    from source.drug_dispensed as a left join s_drug_administration(where= (ADMINTYP_LABEL='Paclitaxel' and DOSEADM^=15)) as b
    on a.SSID=b.SSID
    ;
quit;

data drug_dispensed;
    length phase $20 dispdt 8;
    set disp_adm;
     %subjid; 
    if DRUGPART_LABEL^='' then phase='Part '||strip(DRUGPART_LABEL);
    *dispdt = input(DATEDISP, mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of DATEDISP was changed to yyyy-mm-dd in Oct 23 transfer */
    dispdt = input(DATEDISP, yymmdd10.);


run;

data dispensed01 dispensed02;
    set drug_dispensed;
    if DRUGTYP_LABEL='Paclitaxel' then output dispensed01;
        else if DRUGTYP_LABEL='Study Drug' then output dispensed02;
run;

data disp;
    set dispensed01;
    *dispdt=input(DATEDISP,mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of DATEDISP was changed to yyyy-mm-dd in Oct 23 transfer */
    dispdt = input(DATEDISP, yymmdd10.);
run;

proc sql;
    create table disp_ as
    select *,min(dispdt) as mindt, max(dispdt) as maxdt 
    from disp
    group by subjid
    ;
quit;

proc sort data=disp_ out=s_disp; by subjid descending dispdt; run;

data disp_01;
    set s_disp;
    by subjid descending dispdt;
    retain dispnum retnum last;
    if first.subjid then do;
        dispnum=0; retnum=CAPRET;last=CAPDISP; end;
     else do; 
        dispnum=dispnum+CAPDISP;
        retnum=ifn(retnum^=.,retnum,0)+ifn(CAPRET^=.,CAPRET,0);  
        last=last; end;
    if last.subjid;
    keep subjid dispnum retnum last ;
run;

proc sql;
    create table disp_num as 
    select a.*,b.dispnum,b.retnum,b.last
    from disp_ as a left join disp_01 as b
    on a.subjid=b.subjid
    ;
quit;

data disp_02;
    set disp_num;
    attrib
        arm         length = $20    label = 'Arm'
        num         length = 8      label = 'Number of Capsules'
        dispnum     length = 8      label = 'Total Number of Capsules Dispensed'
        retnum      length = 8      label = 'Total Number of Capsules Return'
        last        length = 8      label = 'Last Number of Capsules Dispensed'
        span        length = 8      label = 'Time Span'
        freq        length = 8      label = 'Continous Dosing Day within a Week'

    ;

    if length(strip(subjid))=5 then arm='Arm 1';
        else if  length(strip(subjid))=6 then arm='Arm 2';

    if phase='Part 1A' then num=9;
        else if phase='Part 1B' then num=7;
        else if phase='Part 2' and DOSEADM=270 then num=9;
        else if phase='Part 2' and DOSEADM=210 then num=7;

    totalnum=dispnum-retnum;
    span=maxdt-mindt;
    times=span/7*num;

    freq=int(totalnum/times) + (int(totalnum/times)< totalnum/times); 

    keep subjid arm freq phase dispnum retnum last span times;
run;

proc sort data=disp_02 nodupkey; by subjid; run;
    
data pacl01;
    set disp_02;
    attrib
        regimen     length = $100    label = 'Dose Regimen'
    ;
  if dispnum^=0 and last^=0 then do;
    regimen = '270 mg Paclitaxel ' || strip(put(freq, best.)) ||'x per week + HM30181AK-US 15 mg per week'; end;
  else if dispnum=0 and last^=0 then do;
    regimen = '270 mg Paclitaxel ' || strip(put(last/times, best.)) ||'x per week + HM30181AK-US 15 mg per week'; end;
  else if dispnum=0 and last=0 then do;
    if arm='Arm 1' then regimen = 'HM30181AK-US 15 mg per week'; 
      else if arm='Arm 2' then regimen='';  end;

run;


proc sort data=dispensed02(where=(capdisp > 0)) out=s_hm; by subjid  dispdt ; run;

data hm01;
    set s_hm;
    by subjid  dispdt ;
    if first.subjid;

    attrib
        freq       length = 8      label = 'Continous Dosing Day within a Week'
        regimen_     length = $100    label = 'Dose Regimen'
        arm         length = $20    label = 'Arm'
        num         length = 8      label = 'Number of Capsules'
    ;

    if length(strip(subjid))=5 then arm='Arm 1';
        else if  length(strip(subjid))=6 then arm='Arm 2';

    if phase='Part 1A' then num=9;
        else if phase='Part 1B' then num=7;
        else if phase='Part 2' and DOSEADM=270 then num=9;
        else if phase='Part 2' and DOSEADM=210 then num=7;

     freq = capdisp / num;
     if arm='Arm 2' then regimen_ = 'HM30181AK-US 15 mg '||strip(put(CAPDISP,best.))||'x per week';

run;

proc sql;
    create table pacl_hm as
    select a.*,b.regimen_
    from pacl01 as a left join hm01 as b
    on a.subjid=b.subjid
    ;
quit;

data _dose3;
    set pacl_hm;
    if REGIMEN_^='' then REGIMEN=strip(scan(REGIMEN,1,'+'))||' + '||strip(REGIMEN_);
    drop REGIMEN_ phase;
run;

data _dose4;
    merge _dose2 _dose3;
    by subjid;
run;

proc sql;
    create table fdose_p as
    select a.*,b.fdosedt
    from _dose4(drop=fdosedt) as a left join _fdose as b
    on a.subjid=b.subjid
    ;
quit;

proc sql;
    create table fdose_hm as
    select a.*,b.fdosedt2
    from fdose_p as a left join _fdose2 as b
    on a.subjid=b.subjid
    ;
quit;

***********************determine dose regimen -- derive from dataset of drug_administration**************************;
proc sql;
    create table admin as
    /* Ken Cao on 2014/12/15: count distinct drug day within a week*/
    select *,count(distinct DRUGDAY) as n
    from source.drug_administration(where=(DRUGCYC=1 and drugday<=7))
    group by ssid, admintyp_label
    ;
quit;

proc sort data=admin out=s_admin(keep=ssid admintyp_label n DOSEADM DRUGPART_LABEL) nodupkey; by ssid admintyp_label; run;

data admin01 admin02;
    set s_admin;
    %subjid;
    if admintyp_label='Paclitaxel' then output admin01;
        else output admin02;
run;

proc sql;
    create table admin03 as
    select a.*,b.hm_label,b.hm_n
    from admin01 as a left join admin02(rename=(admintyp_label=hm_label n=hm_n)) as b
    on a.subjid=b.subjid
    ;
quit;

data admin04;
    set admin03;
    attrib
        arm             length = $20    label = 'Arm'
        phase           length = $20
        adm_regimen     length = $100    label = 'Dose Regimen'

    ;

    if length(strip(subjid))=5 then arm='Arm 1';
        else if  length(strip(subjid))=6 then arm='Arm 2';

    if DRUGPART_LABEL^='' then phase='Part '||strip(DRUGPART_LABEL);

    if phase='Part 1A' then num=9;
        else if phase='Part 1B' then num=7;
        else if phase='Part 2' and DOSEADM=270 then num=9;
        else if phase='Part 2' and DOSEADM=210 then num=7;

/*     freq = capdisp / num;*/
     if arm='Arm 1' then do; 
        adm_regimen = '270 mg Paclitaxel ' || strip(put(n, best.))||'x per week + HM30181AK-US 15 mg per week'; end;
     if arm='Arm 2' then do;
        adm_regimen = '270 mg Paclitaxel ' || strip(put(n, best.))||'x per week + HM30181AK-US 15 mg '||strip(put(hm_n,best.))||'x per week'; end;

run;
****************************************************;
data regimen;
    merge fdose_hm admin04(keep=subjid adm_regimen phase);
    by subjid;
    regimen=coalescec(adm_regimen,regimen);
/*  regimen=coalescec(regimen,adm_regimen);*/

run;


******************;
data pdata._dose;
    retain subjid regimen  ADMINDT EXDT phase arm span freq dispnum retnum last fdosedt fdosedt2   ;
    set regimen;
    keep subjid regimen  ADMINDT EXDT phase arm span freq dispnum retnum last fdosedt fdosedt2;
run;

