
%include '_setup.sas';

proc format;
   value RACE
      1 = 'American Indian or Alaska Native'
      2 = 'Asian'
      3 = 'Black or African American'
      4 = 'Native Hawaiian or other Pacific Islander'
      5 = 'Caucasian'
      99 = 'Other'
      . = " "
   ;
run;
data dm1;
    length AGE GENDER ETHNICT RACE_ __TITLE __TITLE2 __TITLE3 $400;
    set source.demo;
    %ageint(RFSTDTC=CNSNTDTC, BRTHDTC=BIRTHDTC, Age=AGE);
    if SEX=1 then GENDER='M';
        else if SEX=0 then GENDER='F';
    if ETHNICTY=1 then ETHNICT='Hispanic or Latino';
        else if ETHNICTY=2 then ETHNICT='Not Hispanic or Latino';
    RACE_=strip(put(RACE,RACE.));
    if RACE_='Other' then RACE_=strip(RACESP);
    __TITLE="SUBJECT NUMBER: "||strip(SUBID)||'     INITIALS: '||strip(SUBINIT)||'      COUNTRY: USA'||'      SITE: '||strip(SITE_ID);
    __TITLE2="DATE OF BIRTH: "||strip(BIRTHDTC)||'     AGE: '||strip(AGE)||' ^{super [1]}      GENDER: '||strip(GENDER)||'      RACE: '||strip(RACE_)||'      ETHNICITY:  '||strip(ETHNICT);

    __TITLE3="INFORMED CONSENT DATE: "||strip(CNSNTDTC);
    
    length height $40;
    label height = "Height (unit)";
    height = strip(put(ht, best.))||' '||put(htu, heightu.);


    label birthdtc = 'Date of Birth ';
    label sdatec = 'Screening Date';
    label cnsntdtc = 'Date ICF Was Signed';

    if SUBID^='';

    keep SUBID  GENDER   __TITLE __TITLE2 __TITLE3
    birthdtc sdatec sex ethnicty race height cnsntdtc cnvsn pvnum;
    ;
run;
proc sort data=source.sd out=sd;by SUBID SDSTDTC;run;
data fd;
    set sd;
    by SUBID SDSTDTC; 
    if first.SUBID;
    keep SUBID SDSTDTC;
run;
proc sql;
    create table fld as
    select a.*,b. DSDDCDTC
    from fd as a left join source.sd(where=(DSDDCDTC^='')) as b
    on a.SUBID=b.SUBID;
quit;
proc sql;
    create table fld_ as
    select a.*,b. SCLDDTC
    from fld as a left join source.sc(where=(SCLDDTC^='')) as b
    on a.SUBID=b.SUBID;
quit;
proc sql;
    create table dm2 as
    select a.*,b. SDSTDTC,b. DSDDCDTC,b. SCLDDTC
    from dm1 as a left join fld_ as b
    on a.SUBID=b.SUBID;
quit;

data dm3;
    length LFDTC __TITLE4 $255;
    set dm2;
    /*
    if SDSTDTC='' then LFDTC='NA - NA';
    else if SCLDDTC ^='' then LFDTC=strip(SDSTDTC)||' - '||strip(SCLDDTC);
    else if DSDDCDTC^='' then LFDTC=strip(SDSTDTC)||' - '||strip(DSDDCDTC)||" &escapechar{super [2]}";
    else LFDTC=strip(SDSTDTC)||' - Ongoing';
    */

    ** Ken Cao on 2014/11/06: New logic to derive first/last dose date **;
    length __fdosedt $10 __ldosedt $10;
    __fdosedt = coalescec(SDSTDTC, 'NA');
    __ldosedt = coalescec(SCLDDTC, ifc(DSDDCDTC > ' ', strip(DSDDCDTC)||'[2]', ' '));
    if __ldosedt = ' ' then do;
        if __fdosedt > ' ' then __ldosedt = 'Ongoing';
        else __ldosedt = 'NA';
    end;
    LFDTC = strip(__fdosedt)||' - '||strip(__ldosedt);



    __TITLE4="STUDY TREATMENT DATES (First Dose Date - Last Dose Date): "||strip(LFDTC);
    __TITLE3=strip(__TITLE3)||'     '||strip(__TITLE4);
    length __footnote1 __footnote2 $255;
    __footnote1 = '[1] Age is calculated as (Informed Consent Date - Birthday + 1)/365.25.';
    if index(LFDTC, '[2]') > 0 then __footnote2 = '[2] Date is derived from "A.12 Date Drug Permanently Discontinued" on Study Drug Administration form.';
/*    else __footnote2 = "&escapechar{style [foreground=white][2]}";*/
run;

proc sort data=dm3;by SUBID;run;


/* Ken Cao on 2014/11/04: Cleaned Subjects */

data clnsubj;
    informat site $3. subject $4.;
    input site subject;
    format site $3. subject $4.;
    length subid $40;
    subid = site||'-'||subject;
    length __cleanfl $1;
    __cleanfl = 'Y';
    keep subid __cleanfl;
cards;
053 0001
053 0002
019 0003
053 0004
019 0005
019 0006
053 0007
053 0008
053 0009
019 0010
053 0011
019 0012
019 0013
019 0014
019 0015
053 0016
019 0017
053 0018
019 0020
019 0024
019 0033
019 0037
019 0040
;
run;


proc sort data = clnsubj; by subid; run;


data pdata.dm(label='Demographics');
    retain SUBID birthdtc sdatec sex ethnicty race cnsntdtc height cnvsn pvnum  __TITLE __TITLE2 __TITLE3 __footnote1 /*__footnote2*/ __cleanfl;
    keep SUBID birthdtc sdatec sex ethnicty race cnsntdtc height cnvsn pvnum  __TITLE __TITLE2 __TITLE3 __footnote1 /*__footnote2*/ __cleanfl;

    merge dm3(in=a) clnsubj;
        by subid;
    if a;

    ** Ken Cao on 2014/11/25: As per client comments, remove second title line **;
    __TITLE2 = __TITLE3;
    __TITLE3 = ' ';
    
    ** Ken Cao on 2014/11/25: As per client comments, remove age drivation algorithm footnote **;
    __footnote1 = __footnote2;

run; 
