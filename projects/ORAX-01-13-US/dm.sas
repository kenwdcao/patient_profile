/*
    DM for Kinex-Oraxol_Demo
        @Author: Ken Cao (yong.cao@q2bi.com)
        @Initial Date: 2013/12/02
*/

%include '_setup.sas';

/*
    study identifier
    Sex
    Age
    Race
    Informed consent date
*/

data dm0;
    set source.informed_consent_demographics;
    attrib
        studyid     length = $20      label = 'Study Identifier'
        sex         length = $1       label = 'Sex'
        agec        length = $20      label = 'Age'
        racec       length = $200     label = 'Race'
        infdtc      length = $20      label = 'Date of Informed Consent'
    ;
    studyid = 'ORAX-01-13-US';
    %subjid;

    sex     = substr(gender_label, 1, 1);


    /*
        Ken on 2013/12/04: Age is derived as int((Informed Consent Date - Bbirth Date + 1)/365.25)
    */
    
    %_chkYMDDate(infcdt); __complete1 = __Complete;
    %_chkYMDDate(brthdt); __complete2 = __Complete;

    if __complete1 = 1 and __complete2 = 1 then
        /*__age = int((input(infcdt, mmddyy10.) - input(brthdt, mmddyy10.) + 1) / 365.25);*/
    /* Ken Cao on 2014/10/24: Informat of INFCDT and BRTHDT was changed to yyyy-mm-dd in Oct 23 transfer */
    __age = int((input(infcdt, yymmdd10.) - input(brthdt, yymmdd10.) + 1) / 365.25);

    if __age >. then agec  = strip(put(__age, best.)) || "&escapechar{super[1]}";

/*    agec    = ifc(subject_age_at_event>., strip(put(subject_age_at_event, best.)), '');*/

    racec   = coalescec(otspcfy, race_label);
    infdtc  = infcdt;

    *keep studyid subjid sex agec racec infdtc __age;
run;

proc sort data=dm0 nodupkey; by subjid; run;

/*
    Center: Site #/Name /
*/  
data dm1;
    set source.study_subject_listing;
    attrib
        center       length = $100      label = 'Center'
    ;
    
    %subjid;
    if subjid='02- SF1' then subjid='02-SF1';
    center = strip(SITE_PROTOCOL_NAME) || '/' || site_name;

    keep subjid center;
run;


/*
    ECOG Status (baseline)
*/
data dm2_1;
    set source.ecog_performance_status;
    where study_event_oid contains 'BASELINE' or study_event_oid contains 'SCREENING';
    attrib
        ecog       length = $10        label = 'ECOG Status'
    ;
    %subjid;
    ecog = ifc(ecoginv>., strip(put(ecoginv, best.)), '');
   
    keep subjid ecog STUDY_EVENT_OID;
run;

data dm2_2;
    set dm2_1;
    if index(study_event_oid, 'BASELINE')>0 then ord=1; 
        else if index(study_event_oid, 'SCREENING')>0 then ord=2;
run;
    
proc sort data=dm2_2; by subjid ord; run;

data dm2;
    set dm2_2;
    by subjid ord;
    if first.subjid;
run;

/*
    BSA
    Height
*/
data dm3;
    set source.vt_signs;
    attrib
        bsac        length = $10        label = 'BSA'
        heightc     length = $10        label = 'Height'
    ;

    %subjid;
    bsac    = strip(put(bsa, best.));
    heightc = strip(put(height, best.))||' in'; 

    keep subjid bsac heightc;
run;


/*
    Discontinuation Reason
*/
data dm4;
    set source.study_end;
    attrib
        exitrsn     length = $200       label = 'Discontinuation Reason'
    ;
    %subjid;
    if DSREASP^='' and dsreas_label^='' then exitrsn = strip(dsreas_label)||': '||strip(DSREASP);
        else  exitrsn=strip(dsreas_label);

    keep subjid exitrsn;
run;

/*
    First Diagnosis;
*/
data dm5;  
    set source.med_histhistory;
    where item_group_repeat_key = 1;
    attrib
        fstdiag     length = $200        label = 'The First Diagnosis'
    ;
    %subjid();
    fstdiag = upcase(diag);
    /*
        Ken on 2013/12/04: Wait for further input of field "The First Diagnosis".
     */
    fstdiag = ' ';
    keep subjid fstdiag;
run;


/*
    Dose Regimen
    Dose Adjustment
*/

/*
data dm6;
    set source.informed_consent_demographics;
    attrib
        dosgrp       length = $60       label = 'Dose Group'
        regimen      length = $60       label = 'Dose Regimen'
        dosadj       length = $200      label = 'Dose Adjustment'
    ;
    %subjid;
    regimen = '270 mg Paclitaxel 2x per week  + HM30181AK-US';
    dosadj  = '';
    dosgrp  = 'Oraxol (Paclitaxel + HM30181 AK-US)'; 
run;
*/

%sort(indata = pdata._dose, outdata = _dose, sortkey = subjid, nodupkey = Y);

data dm6;
    set _dose(rename = (fdosedt = __fdosedt));
    attrib
        dosgrp       length = $60       label = 'Dose Group'
        dosadj       length = $200      label = 'Dose Adjustment'
        __fdosedtc   length = $20       label = 'First Dose Date'
    ;
/*    dosgrp     = 'Oraxol (Paclitaxel + HM30181 AK-US)'; */
    dosgrp     = strip(phase)||' '||strip(arm); 

    dosadj     = ' '; /*Dummy*/
    __fdosedtc = put(__fdosedt, mmddyy10.);

    keep subjid regimen dosgrp dosadj __fdosedt __fdosedtc;
run;


%sort(indata = dm0, sortkey = subjid);
%sort(indata = dm1, sortkey = subjid);
%sort(indata = dm2, sortkey = subjid);
%sort(indata = dm3, sortkey = subjid);
%sort(indata = dm4, sortkey = subjid);
%sort(indata = dm5, sortkey = subjid);
%sort(indata = dm6, sortkey = subjid);

data pre_dm0;
    merge dm0(in=a) dm1 dm2 dm3 dm4 dm5 dm6;
        by subjid;
        if a;

    length col $1024;

    /* Ken Cao on 2014/08/14: Put a blank after "Age:" */
    __title1 = 'Subject: '|| strip(subjid)||' / '||ifc(sex = 'M', 'Male', 'Female') || ' / Age: ' || agec;
    __title2 = "Page &escapechar{thispage} of &escapechar{lastpage}";

    %concat(invars = studyid subjid center, outvar = col, nblank = 6); output;
    %concat(invars = sex agec bsac heightc ecog, outvar = col, nblank = 15); output;
    %concat(invars = racec infdtc, outvar = col, nblank = 30); output;
/*    %concat(invars = regimen dosgrp , outvar = col, nblank = 20); output;*/
    %concat(invars = regimen, outvar = col); output;
    %concat(invars = dosgrp , outvar = col); output;
    %concat(invars = exitrsn, outvar = col); output;
    %concat(invars = fstdiag, outvar = col); output;
    %concat(invars = dosadj,  outvar = col); output;

    keep subjid col __title1 __title2 __fdosedt __fdosedtc;
run;

data pre_dm1;
    set pre_dm0(rename=(col = in_col)) ;
        by subjid;
    length col $1024;
    retain col;


    if first.subjid then col = in_col;
    else col = strip(col) || "&escapechar.2n " || in_col;
    if last.subjid then output;

    
    drop in_col;
run;



data pdata.dm;
    retain subjid col __title1 __title2 ;
    set pre_dm1;
    keep subjid col __title1  __fdosedt __fdosedtc ;
run;
