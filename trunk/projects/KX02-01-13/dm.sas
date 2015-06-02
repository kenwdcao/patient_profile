
%include '_setup.sas';

/*
    study identifier
    Sex
    Age
    Race
    Informed consent date
*/

data dm0;
    set source.inf_cnsnt_demo;
    attrib
        studyid     length = $20      label = 'Study Identifier'
        sex         length = $1       label = 'Sex'
        agec        length = $20      label = 'Age'
        racec       length = $200     label = 'Race'
        infdtc      length = $20      label = 'Date of Informed Consent'
    ;
    studyid = 'KX02-01-13';
    %subjid;

    sex     = substr(gender_label, 1, 1);

    /*
       Age is derived as int((Informed Consent Date - Bbirth Date + 1)/365.25)
    */
    
    %_chkMDYDate(infcdt); __complete1 = __Complete;
    %_chkMDYDate(brthdt); __complete2 = __Complete;

    if __complete1 = 1 and __complete2 = 1 then
        __age = int((input(infcdt, mmddyy10.) - input(brthdt, mmddyy10.) + 1) / 365.25);

    if __age >. then agec  = strip(put(__age, best.)) || "&escapechar{super[1]}";


    racec   = coalescec(otspcfy, race_label);
    infdtc  = strip(put(input(infcdt, mmddyy10.), yymmdd10.));

    keep studyid subjid sex agec racec infdtc __age;
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
    center = strip(SITE_PROTOCOL_NAME) || '/' || site_name;

    keep subjid center;
run;

/*
    Weight
    Height
*/

data dm2;
    merge source.kam_vitals2 source.kam_vitals(rename=(heightcm=heightcm_ weightkg1=weightkg1_));
	by ssid;
    attrib
        weightc        length = $10        label = 'Weight'
        heightc     length = $10        label = 'Height'
    ;

    %subjid;
    weightkg1=coalesce(weightkg1, weightkg1_);
    heightcm=coalesce(heightcm, heightcm_);
    if weightkg1^=. then weightc    = strip(put(weightkg1, best.))||' kg';
    if heightcm^=. then heightc = strip(put(heightcm, best.))||' cm'; 

    keep subjid weightc heightc STUDY_EVENT_OID;
run;


/*
    Discontinuation Reason
*/
data dm3;
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
data dm4;  
    set source.med_histhistory;
    where item_group_repeat_key = "1";
    attrib
        fstdiag     length = $200        label = 'The First Diagnosis'
    ;
    %subjid();
    fstdiag = 'Advanced Refractory Malignancies';
    keep subjid fstdiag;
run;


/*
    BSA
    ECOG Status
    Dose Group
    Dose Regimen
    Dose Adjustment
*/


data dm5;
    set source.inf_cnsnt_demo;
    attrib
        bsac        length = $10        label = 'BSA'
        ecog       length = $10        label = 'ECOG Status'
        dosgrp       length = $60       label = 'Dose Group'
        regimen      length = $60       label = 'Dose Regimen'
        dosadj       length = $200      label = 'Dose Adjustment'
    ;
    %subjid;
    bsac = '';
    ecog  = '';
    regimen = '';
    dosadj  = '';
    dosgrp  = 'Oral KX2-361'; 
    keep subjid regimen dosgrp dosadj /*bsac ecog*/;
run;

data dm6_1;
    set source.study_drug_admindrug;
    attrib
        __fdosedtc   length = $20       label = 'First Dose Date'
        __fdosedt   length = 8       label = 'First Dose Date (Num)'
    ;
    %subjid;
    __fdosedt=input(admindt, mmddyy10.); format __fdosedt date9.;
    __fdosedtc=admindt;
    keep subjid __fdosedt __fdosedtc;
run;

proc sort data=dm6_1; by subjid __fdosedt; run;

data dm6;
	set dm6_1;
	by subjid __fdosedt;
	if first.subjid;
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

    __title1 = 'Subject: '|| strip(subjid)||' / '||ifc(sex = 'M', 'Male', 'Female') || ' / Age:' || agec;

    %concat(invars = studyid , outvar = col); output;
    %concat(invars = subjid, outvar = col); output;
    %concat(invars = center, outvar = col); output;
    %concat(invars = sex, outvar = col); output;
    %concat(invars = agec,  outvar = col); output;
/*    %concat(invars = bsac,  outvar = col); output;*/
    %concat(invars = racec, outvar = col); output;
/*    %concat(invars = ecog, outvar = col); output;*/
    %concat(invars = infdtc,  outvar = col); output;
    %concat(invars = heightc,  outvar = col); output;
    %concat(invars = weightc,  outvar = col); output;
    %concat(invars = dosgrp , outvar = col); output;
    %concat(invars = regimen, outvar = col); output;
    %concat(invars = exitrsn, outvar = col); output;
    %concat(invars = fstdiag, outvar = col); output;
    %concat(invars = dosadj,  outvar = col); output;

    keep subjid col __title1 __fdosedt __fdosedtc;
run;

data pre_dm1;
    set pre_dm0(rename=(col = in_col)) ;
        by subjid;
    length col $1024;
    retain col;
    if first.subjid then col = in_col;
    else col = strip(col) || "&escapechar.2n" || in_col;
    if last.subjid then output;
    
    drop in_col;
run;



data pdata.dm(label="Demography");
    retain subjid col __title1;
    set pre_dm1;
    keep subjid col __title1 __fdosedt /*__fdosedtc*/;
run;
