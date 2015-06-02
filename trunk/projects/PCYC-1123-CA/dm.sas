/*********************************************************************
 Program Nmae: dm.sas
  @Author: Ken Cao
  @Initial Date: 2015/04/08
 

 This program is originally from PCYC-1123-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data dm0;
    set source.dm;
    keep EDC_TreeNodeID SITE SUBJECT VISIT CBP CBPNO ETHNIC SEX BIRTHDD BIRTHMM BIRTHYY 
         CBPN01 CBPN02 CBPN03 CBPN04 RACE1 RACE2 RACE3 RACE4 RACE5 EDC_EntryDate;
    %subject;
	format CBPN01 CBPN02 CBPN03 CBPN04 checked.;
run;

data ie;
    set source.ie;
    where iedt ^= .;

    %subject;
    
    length iedtc $20;
    %ndt2cdt(ndt=iedt, cdt=iedtc);

    keep subject iedtc;
run;

data enroll;
    set source.enroll;

    %subject;
    iecohort = scan(iecohort, 1, '()');    

    keep subject iecohort;
run;



data dm1;

    length subject $13 rfstdtc $10 siteid $3 SiteDescription $34 iedtc $20 iecohort $68;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();

        declare hash h2 (dataset:'source.sites');
        rc2 = h2.defineKey('siteid');
        rc2 = h2.defineData('SiteDescription');
        rc2 = h2.defineDone();

        declare hash h3 (dataset:'ie');
        rc3 = h3.defineKey('subject');
        rc3 = h3.defineData('iedtc');
        rc3 = h3.defineDone();

        declare hash h4 (dataset:'enroll');
        rc4 = h4.defineKey('subject');
        rc4 = h4.defineData('iecohort');
        rc4 = h4.defineDone();


        call missing(subject, rfstdtc, siteid, SiteDescription, iedtc, iecohort);
    end;

    set dm0;
    
    ** race;
    length race $200;
    label race = 'Race';
    array rac{*} race1-race5;
    do i = 1 to dim(rac);
        if vvaluex(vname(rac[i])) = 'Checked' then race = ifc(race = ' ', substr(vlabel(rac[i]), 6), strip(race)||', '||substr(vlabel(rac[i]), 6));
    end;
    drop i race1 - race5;

    ** Birth date;
    length birthdtc $20;
    %concatDate(year=BIRTHYY, month=BIRTHMM, day=BIRTHDD, outdate=birthdtc);
    drop BIRTHYY BIRTHMM BIRTHDD;

    

    ** AGE;
    rc3 = h3.find();
    drop rc3;

    length age $40;
    %ageint(RFSTDTC=iedtc, BRTHDTC=birthdtc, AGE=age);

    rc4 = h4.find();
    drop rc4;


    ** Site Name;
    length sitename $200;
    siteid = site;
    rc2 = h2.find();
    drop rc2;
    sitename = SiteDescription;
    drop siteid SiteDescription;
    
run;

** First Dose Date, Latest Dose Date and Treatment End Date;
data fdosedt;
    set source.ex;
    %subject;
    length trtstfl $1;
    if exdosed = 'Yes' then trtstfl = 'Y';
    keep subject excat trtstfl fdosedt;
run;

data trtdt;
    set 
        source.exbtk(in=__btk keep=subject exstdt exendt exadose where=(exadose not in ('Missed Dose', ' ')))
        source.exlen(in=__len keep=subject exstdt exendt exadose where=(exadose not in ('Missed Dose', ' ')))
        source.exrit(in=__rit keep=subject exstdt        exadose where=(exadose not in ('Missed Dose', ' ')))
    ;

    %subject;
    if __rit then exendt = exstdt;
    length excat $12;

    if __btk then excat = 'Ibrutinib';
    else if __len then excat = 'Lenalidomide';
    else if __rit then excat = 'Rituximab';

    if exendt = . then exendt = exstdt;

    if exstdt = . or exendt = . then put "WARN" "ING: Missing Dose Date: " SUBJECT= EXSTDT= EXENDT= ;
    
    drop exadose;
run;

proc sql;
    create table ldsoedt as
    select excat, subject, max(exendt) as ldosedt label = 'Latest Dose Date'
    from trtdt
    group by excat, subject
    ;
quit;

data trtendt;
    set source.disc;
    %subject;
    length trtfl $1 excat $12;
    excat = strip(scan(EDC_FormLabel, -1, '-'));
    if exyn = 'Yes' then trtfl = 'Y';
    keep subject excat ldosedt trtfl;
    rename ldosedt = trtendt;
    label ldosedt = 'Treatment End Date';
run;

proc sort data=fdosedt; by subject excat; run;
proc sort data=ldsoedt; by subject excat; run;
proc sort data=trtendt; by subject excat; run;

data trt;
    merge fdosedt ldsoedt trtendt;
        by subject excat;
run;

data trt2;
    set trt;
    by subject excat;
    length btkfdtc btkldtc btkendtc ritfdtc ritldtc ritendtc lenfdtc lenldtc lenendtc $20;
    retain btkfdtc btkldtc btkendtc ritfdtc ritldtc ritendtc lenfdtc lenldtc lenendtc;
    if first.subject then call missing(btkfdtc, btkldtc, btkendtc, ritfdtc, ritldtc, ritendtc, lenfdtc, lenldtc, lenendtc);
    if excat = 'Ibrutinib' then do;
        %ndt2cdt(ndt=fdosedt, cdt=btkfdtc);
        %ndt2cdt(ndt=ldosedt, cdt=btkldtc);
        %ndt2cdt(ndt=trtendt, cdt=btkendtc);
    end;
    else if excat = 'Lenalidomide' then do;
        %ndt2cdt(ndt=fdosedt, cdt=lenfdtc);
        %ndt2cdt(ndt=ldosedt, cdt=lenldtc);
        %ndt2cdt(ndt=trtendt, cdt=lenendtc);
    end; 
    else if excat = 'Rituximab' then do;
        %ndt2cdt(ndt=fdosedt, cdt=ritfdtc);
        %ndt2cdt(ndt=ldosedt, cdt=ritldtc);
        %ndt2cdt(ndt=trtendt, cdt=ritendtc);
    end;
    if last.subject;
    keep subject btkfdtc btkldtc btkendtc ritfdtc ritldtc ritendtc lenfdtc lenldtc lenendtc ;
run;

data trt3;
    length subject $13 rfstdtc $10 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set trt2;
    rc = h.find();
    %concatDY(btkfdtc );
    %concatDY(btkldtc );
    %concatDY(btkendtc);
    %concatDY(lenfdtc );
    %concatDY(lenldtc );
    %concatDY(lenendtc);
    %concatDY(ritfdtc );
    %concatDY(ritldtc );
    %concatDY(ritendtc);
    drop rc;
run;

proc sort data=dm1; by subject; run;

data dm2;
    merge dm1 trt3;
        by subject;
run;

** DTL;
data dlt;
    set source.dlt;
    %subject;
    length _aenum $20;
    array aenum{*} aenum:;
    do i = 1 to dim(aenum);
        if aenum[i] = . then continue;
        _aenum = ifc(_aenum ^= ' ', strip(_aenum)||', '||strip(vvaluex(vname(aenum[i]))), vvaluex(vname(aenum[i])));
    end;

    if dltyn = 'No' and _aenum ^= ' ' then put "WARN" "ING: Conflict " subject= dltyn= _aenum=;
    keep subject dltyn _aenum;
run;

proc sort data=dlt; by subject; run;
data dm3;
    merge dm2 dlt;
        by subject;
run;


%macro concat(varlist, nblank, outvar, fixlen);
%local nvar;
%local i;
%local var;

%if %length(&nblank) = 0 %then %let nblank = 5;

%let varlist = %sysfunc(prxchange(s/\s+/ /, -1, &varlist));
%let varlist = %sysfunc(strip(&varlist));

%let nvar = %eval(%sysfunc(countc(&varlist, " ")) + 1);

%if %length(&fixlen) > 0 %then %do;
    length ___temp $&fixlen;
    drop ___temp;
    ___temp = ' ';
%end;
%do i = 1 %to &nvar;
    %let var = %scan(&varlist, &i, " ");
    %if %length(&fixlen) = 0 %then %do;
        &outvar = strip(&outvar)||repeat(" ", &nblank - 1)||"&escapechar{style [fontweight=bold]"
                  ||strip(vlabel(&var))||'}: '||ifc(vvaluex("&var")>' ',strip(vvaluex("&var")), 'N.A.');
    %end;
    %else %do;
        &outvar = strip(&outvar)||repeat(" ", &fixlen - length(___temp))||"&escapechar{style [fontweight=bold]"
                  ||strip(vlabel(&var))||'}: '||ifc(vvaluex("&var")>' ',strip(vvaluex("&var")), 'N.A.');
        ___temp = strip(vlabel(&var))||": "||ifc(vvaluex("&var")>' ',strip(vvaluex("&var")), 'N.A.');
    %end;
%end;

&outvar = strip(&outvar);
%mend concat;



data dm4;
    set dm3;
    length __title1 __title2 __title3 __title4  $1024;
    length __footnote1 __footnote2 $1024;


    label subject = 'Subject ID';
    label __sex = 'Sex';
    label __age = 'Age';
    length __sex $1 __age $20;
    label __site = 'Site';
    label __dlt = 'DLT';
    length __site $255;
    length __dlt $255;
    drop __sex __age;

    __sex = substr(sex, 1, 1);
    if age ^= ' ' then __age = strip(age)||" &escapeChar{Super [1]}";
    __footnote1 = '[1] Age is calculated as (Informed Consent Date - Birthday + 1)/365.25.';
    __site = strip(site)||' ('||strip(sitename)||')';
    __dlt = dltyn;
    if _aenum ^= ' ' then __dlt = strip(__dlt)||': '||_aenum;
    %concat(subject __site __sex __age  __dlt, , __title1);

    label btkfdtc   = "Ibrutinib First Dose Date";
    label btkldtc   = "Ibrutinib Latest Dose Date";
    label btkendtc  = "Ibrutinib Last Dose Date &escapeChar{super [2]}";
    label lenfdtc   = "Lenalidomide First Dose Date";
    label lenldtc   = "Lenalidomide Latest Dose Date";
    label lenendtc  = "Lenalidomide Last Dose Date &escapeChar{super [2]}";
    label ritfdtc   = "Rituximab First Dose Date";
    label ritldtc   = "Rituximab Latest Dose Date";
    label ritendtc  = "Rituximab Last Dose Date &escapeChar{super [2]}";

    %concat(btkfdtc btkldtc btkendtc, , __title2, 50);
    %concat(lenfdtc lenldtc lenendtc, , __title3, 50);
    %concat(ritfdtc ritldtc ritendtc, , __title4, 50);

    __footnote2 = "[2] Last Dose Date from STUDY DRUG DISCONTINUATION form";


run;


data pdata.dm(label="Demographic");

    retain EDC_TREENODEID EDC_ENTRYDATE SUBJECT  VISIT BIRTHDTC SEX CBP CBPN01 CBPN02  CBPN04 CBPNO   
           RACE ETHNIC AGE IECOHORT __TITLE1 __TITLE2 __TITLE3 __TITLE4  __FOOTNOTE1 __FOOTNOTE2 ;
    keep   EDC_TREENODEID EDC_ENTRYDATE SUBJECT  VISIT BIRTHDTC SEX CBP CBPN01 CBPN02  CBPN04 CBPNO   
           RACE ETHNIC AGE IECOHORT __TITLE1 __TITLE2 __TITLE3 __TITLE4  __FOOTNOTE1 __FOOTNOTE2 ;
    set dm4;


    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename  EDC_ENTRYDATE = __EDC_ENTRYDATE;
    rename          VISIT = __VISIT;
    rename            AGE = __AGE;
    rename       IECOHORT = __IECOHORT;

    label BIRTHDTC = 'Date of Birth';
    label      SEX = 'Sex at Birth';
    label      CBP = "If 'Female', is subject of childbearing potential?";
    label   CBPN01 = 'Post Menopausal@:If "No", Specify Reason';
    label   CBPN02 = 'Hysterectomy@:If "No", Specify Reason';
    label   CBPN04 = 'Bilateral Oophorectomy@:If "No", Specify Reason';
    label    CBPNO = 'Other Specify@:If "No", Specify Reason';
    label IECOHORT = 'Phase 1b Cohort No.';
run;
