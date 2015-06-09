%include '_setup.sas';

data fast01;
    set source.drug_fasting;
    attrib
        ADMDTC     length = $20      label = 'Date of Drug Administration'
        PHASE      length = $20      label = 'Part'
        VISIT      length = $60      label = 'Visit'
        FASTDTC    length = $20      label = 'Date of Fasting'
        SOL        length = $60      label = 'Fast for solids 8 hours prior to dose?'
        SOLTIME    length = $20      label = 'Pre Dosing Solids Fast Start/Stop Time'
        LIQ        length = $20      label = 'Fast for liquids 2 hours prior to dose?'
        LIQTIME    length = $20      label = 'Pre Dosing Liquids Fast Start/Stop Time'
        POST       length = $20      label = 'Fast for 1 hour post dosing (except liquids)?'
        POSTTIME   length = $20      label = 'Post Dosing Fast Start/Stop Time'

    ;
    %subjid;

    *admt=input(ADMINDTF,mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of ADMINDT was changed to yyyy-mm-dd */
    admt=input(ADMINDTF,yymmdd10.);
    ADMDTC=strip(ADMINDTF);
    PHASE=strip(DRUGPARTF_LABEL);
    VISIT='Cycle '||strip(put(DRUGCYCF,best.))||' '||'Day '||strip(put(DRUGDAYF,best.));
    *fastdt=input(DATEFAST,mmddyy10.);
    /* Ken Cao on 2014/10/24: Informat of DATEFAST was changed to yyyy-mm-dd */
    fastdt=input(DATEFAST, yymmdd10.);
    FASTDTC=strip(DATEFAST);
    SOL=strip(FASTSOL_LABEL);
    if cmiss(FASTTIM,FASTSTPTIM)=0 then  SOLTIME=strip(FASTTIM)||'/'||strip(FASTSTPTIM);
        else if cmiss(FASTTIM,FASTSTPTIM)=2 then SOLTIME='^_^_^_^_-/-';
        else if FASTTIM^='' and FASTSTPTIM='' then SOLTIME=strip(FASTTIM)||'/-';
        else if FASTTIM='' and FASTSTPTIM^='' then  SOLTIME='^_^_^_^_-/'||strip(FASTSTPTIM);
    if FASTSOL_LABEL^='Yes' then SOLTIME='';

    LIQ=strip(FASTLIQ_LABEL);
    if cmiss(FASTLIQSTRT,FASTLIQSTOP)=0 then LIQTIME=strip(FASTLIQSTRT)||'/'||strip(FASTLIQSTOP);
        else if cmiss(FASTLIQSTRT,FASTLIQSTOP)=2 then LIQTIME='^_^_^_^_-/-';
        else if FASTLIQSTRT^='' and FASTLIQSTOP='' then LIQTIME=strip(FASTLIQSTRT)||'/-';
        else if FASTLIQSTRT='' and FASTLIQSTOP^='' then LIQTIME='^_^_^_^_-/'||strip(FASTLIQSTOP);
    if FASTLIQ_LABEL^='Yes' then LIQTIME='';

    POST=strip(FASTPOST_LABEL);
    if cmiss(FASTSTRT,FASTSTP)=0 then POSTTIME=strip(FASTSTRT)||'/'||strip(FASTSTP);
        else if cmiss(FASTSTRT,FASTSTP)=2 then POSTTIME='^_^_^_^_-/-';
        else if FASTSTRT^='' and FASTSTP='' then POSTTIME=strip(FASTSTRT)||'/-';
        else if FASTSTRT='' and FASTSTP^='' then POSTTIME='^_^_^_^_-/'||strip(FASTSTP);
    if FASTPOST_LABEL^='Yes' then POSTTIME='';
    keep subjid ADMDTC PHASE VISIT FASTDTC SOL SOLTIME LIQ LIQTIME POST POSTTIME DRUGCYCF DRUGDAYF admt fastdt;
RUN;

proc sort data=fast01; by subjid fastdt DRUGCYCF DRUGDAYF; run;

data pdata.fast(label='Fasting');
    retain subjid ADMDTC PHASE VISIT FASTDTC SOL SOLTIME LIQ LIQTIME POST POSTTIME;
    keep subjid ADMDTC PHASE VISIT FASTDTC SOL SOLTIME LIQ LIQTIME POST POSTTIME;
    set /*pdata.dm(keep=subjid)*/ fast01;
run;
    
