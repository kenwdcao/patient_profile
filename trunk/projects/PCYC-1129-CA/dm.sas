/*********************************************************************
 Program Nmae: dm.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/23
 

 This program is originally from PCYC-1129-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';


*** get first dose date*******;
proc sql;
    create table fdose as
    select subject, put(EXDOSFDT, yymmdd10.) as __rfstdtc length=10 label = 'First Dose Date'
    from source.ex
    ;
quit;

data rfstdtc;
    retain subject __rfstdtc;
    keep subject __rfstdtc;
    set fdose;
	%subject;
run;


*** dm variables*******;
data dm0;
    set source.dm;
    keep EDC_TreeNodeID SITE SUBJECT VISIT CBP ETHNIC SEX BIRTHDD BIRTHMM BIRTHYY 
         CBP RACE1 RACE2 RACE3 RACE4 RACE5 EDC_EntryDate;
    %subject;
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
    iecohort = encohort;    
    keep subject iecohort;
run;


data dm1;
    length subject $13 __rfstdtc $10 siteid $3 SiteDescription $34 iedtc $20 iecohort $68;
    if _n_ = 1 then do;
        declare hash h (dataset:'rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
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

        call missing(subject, __rfstdtc, siteid, SiteDescription, iedtc, iecohort);
    end;

    set dm0;

  
    ** rfstdtc ;
    __rfstdtc=__rfstdtc;
     rc = h.find();
    drop rc;

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
    if EXDOSEF = 'Yes' then trtstfl = 'Y';
    keep subject  trtstfl exdosfdt;
run;

data trtdt;
    set  source.exbtk(in=__btk keep=subject exstdt exendt exadose where=(exadose not in ('Missed Dose', ' ')));   
    %subject;
    if exendt = . then exendt = exstdt;
    if exstdt = . or exendt = . then put "WARN" "ING: Missing Dose Date: " SUBJECT= EXSTDT= EXENDT= ;
    drop exadose;
run;

proc sql;
    create table ldsoedt as
    select subject, max(exendt) as ldosedt label = 'Latest Dose Date' format date9.
    from trtdt
    group by  subject
    ;
quit;

data trtendt;
    set source.discbtk;
    %subject;
    length trtfl $1;
    if exyn = 'Yes' then trtfl = 'Y';
    keep subject ldosedt trtfl;
    rename ldosedt = trtendt;
    label ldosedt = 'Treatment End Date';
run;

proc sort data=fdosedt; by subject ; run;
proc sort data=ldsoedt; by subject ; run;
proc sort data=trtendt; by subject ; run;

data trt;
    merge fdosedt ldsoedt trtendt;
        by subject ;
run;

data trt2;
    set trt;
    by subject ;
    length btkfdtc btkldtc btkendtc  $20;
    retain btkfdtc btkldtc btkendtc ;
    if first.subject then call missing(btkfdtc, btkldtc, btkendtc, ritfdtc, ritldtc, ritendtc, lenfdtc, lenldtc, lenendtc);
  
        %ndt2cdt(ndt=exdosfdt, cdt=btkfdtc);
        %ndt2cdt(ndt=ldosedt, cdt=btkldtc);
        %ndt2cdt(ndt=trtendt, cdt=btkendtc);
 
    if last.subject;
    keep subject btkfdtc btkldtc btkendtc  ;
run;

data trt3;
    length subject $13 __rfstdtc $10 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'work.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set trt2;
    rc = h.find();
    %concatDY(btkfdtc );
    %concatDY(btkldtc );
    %concatDY(btkendtc);
    drop rc;
run;

proc sort data=dm1; by subject; run;

data dm2;
    merge dm1 trt3 ;
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


option mprint mlogic;
data dm3;
    set dm2;
    length __title1 __title2  __footnote1 __footnote2 $1024  __sex $1 __age $20 __site $255;
    label subject = 'Subject ID';
    label __sex = 'Sex';
    label __age = 'Age';
    label __site = 'Site';
    drop __sex __age;

    __sex = substr(sex, 1, 1);
    if age ^= ' ' then __age = strip(age)||" &escapeChar{Super [1]}";
    __footnote1 = '[1] Age is calculated as (Informed Consent Date - Birthday + 1)/365.25.';
    __site = strip(site)||' ('||strip(sitename)||')';

    %concat(subject __site __sex __age,  ,__title1);

    label btkfdtc   = "Ibrutinib First Dose Date";
    label btkldtc   = "Ibrutinib Latest Dose Date";
    label btkendtc  = "Ibrutinib Last Dose Date &escapeChar{super [2]}";
 
    %concat(btkfdtc btkldtc btkendtc, , __title2);
    __footnote2 = "[2] Last Dose Date from STUDY DRUG DISCONTINUATION form";
run;


data dm4;
 set dm3;
if  age^='' then __AGE=input(age, best.); else __AGE=.;
drop age;
run;


data pdata.dm(label="Demographic");
    retain EDC_TREENODEID EDC_ENTRYDATE SUBJECT  VISIT BIRTHDTC SEX CBP  
           ETHNIC RACE __AGE IECOHORT __RFSTDTC  __TITLE1 __TITLE2   __FOOTNOTE1 __FOOTNOTE2 ;
    keep   EDC_TREENODEID EDC_ENTRYDATE SUBJECT  VISIT BIRTHDTC SEX CBP   
           ETHNIC RACE  __AGE IECOHORT __RFSTDTC __TITLE1 __TITLE2  __FOOTNOTE1 __FOOTNOTE2 ;
    set dm4;

    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename  EDC_ENTRYDATE = __EDC_ENTRYDATE;
    rename          VISIT = __VISIT;
    rename       IECOHORT = __IECOHORT;

    label BIRTHDTC = 'Date of Birth';
    label      SEX = 'Sex at Birth';
    label      CBP = "If 'Female', is subject of childbearing potential?";
    label IECOHORT = 'Phase 1b Cohort No.';
	label    __AGE = 'Age';
run;
