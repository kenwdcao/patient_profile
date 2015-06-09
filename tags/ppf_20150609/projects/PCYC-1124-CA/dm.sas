/********************************************************************************
 Program Nmae: DM.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/25
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/02/26: Derive last dose date from "Study Drug Discontinuation-
                        Ibrutinib" page (discbtk).
 Ken Cao on 2015/02/28: Fix Last Dose Date.
 Ken Cao on 2015/03/10: Assign "N.A." for last dose date if subject is still taking
                        Ibrutinib.
 Ken Cao on 2015/03/23: 1) Change "Last Dose Date" to "Treatment End Date".
                        2) Add "Latest Dose Date".
********************************************************************************/

%include '_setup.sas';

data dm0;
    set source.dm(keep=EDC_TreeNodeID EDC_EntryDate subject birth: sex cbp cbpn: cbpno ethnic race:);

    ** site and subject identifier;
    length __site $4;
    label __site = 'Study Site';
    __site = scan(subject,2,'-');
    %subject;

    ** birth date;
    length birthdtc $10;
    label birthdtc = 'Birth Date';
    %concatDate(year=birthyy, month=birthmm, day=birthdd, outdate=birthdtc);
    drop birthyy birthmm birthdd;

    format cbpn01 $checked.  cbpn02 $checked.  cbpn03 $checked.  cbpn04 $checked.  cbpno $checked.;

    ** race;
    length race $200;
    label race = 'Race';
    array rac{*} race1-race5;
    do i = 1 to dim(rac);
        if rac[i] = 'Checked' then race = ifc(race = ' ', substr(vlabel(rac[i]), 6), strip(race)||', '||substr(vlabel(rac[i]), 6));
    end;
    drop i race1 - race5;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename EDC_EntryDate = __EDC_EntryDate;
run;



/* First and Last Dose Date and --DY */
data _exbtk0;
    set source.exbtk(where=(exdose > ' ' or exdoseo > .) rename=(exdisc=__exdisc));
    %subject;

    length __exdtc $10;
    label __exdtc = 'Dose Date';
    %ndt2cdt(ndt=exdt, cdt=__exdtc);

    keep subject __exdtc __exdisc;
run;

proc sql;
    create table _exbtk1 as
    select a.subject
        ,__fdosedtc
        ,__ldosedtc
        ,__exdisc
    from (
        select distinct subject
            ,min(__exdtc) as __fdosedtc length = 20 label = 'First Dose Date of Ibrutinib Dose Administration'
        from _exbtk0
        group by subject
        ) as a
        ,(
            select subject
                ,__exdtc as __ldosedtc length = 100 label = 'Last Dose Date of Ibrutinib Dose Administration'
                ,__exdisc
            from _exbtk0
            group by subject
            having __exdtc = max(__exdtc)
            ) as b
    where a.subject = b.subject;
quit;

/* for deriving --DY */
data pdata.rfstdtc(label = 'Reference Start Date');
    retain subject rfstdtc; 
    keep subject rfstdtc;
    set _exbtk1(rename=(__fdosedtc=rfstdtc));
run;

** Ken Cao on 2015/02/26: Derive "Last Dose Date" from discbtk.ldosedt;
data _ldosedt;
    set source.discbtk(keep=subject ldosedt);
    %subject;
    length __ldosedtc2 $100;
    %ndt2cdt(ndt=ldosedt, cdt=__ldosedtc2);
    drop ldosedt;
    if __ldosedtc2 > ' ';
run;


data _exbtk2;
    length subject $13 rfstdtc $10 __ldosedtc2 $40;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        declare hash h2 (dataset:'_ldosedt');
        rc2 = h2.defineKey('subject');
        rc2 = h2.defineData('__ldosedtc2');
        rc2 = h2.defineDone();
        call missing(subject, rfstdtc, __ldosedtc2);
    end;
    set _exbtk1;
    rc = h.find();
    rc2 = h2.find();

    ** Lastest Dose Date;
    length __latestdosedtc $255;
    __latestdosedtc = __ldosedtc;
    %concatdy(__latestdosedtc);
    __latestdosedtc = substr(__latestdosedtc, 1, 10)||"&escapechar{super [3]}"||substr(__latestdosedtc, 11);
    length __footnote3 $255;
    __footnote3 = '[3] Latest Dose Date captured in Ibrutinb Drug Administration Form';
    

    %concatdy(__fdosedtc);
    if (__ldosedtc ^= __ldosedtc2) and cmiss(__ldosedtc, __ldosedtc2) = 0 then do;
        put "WARN" "ING: Controversial last dose date " subject = ". EX: " __ldosedtc " DS: " __ldosedtc2;
    end;
    __ldosedtc = coalescec(__ldosedtc2, __ldosedtc);

    ** Ken Cao on 2015/03/23: Client ask to populate treatment end date as last dose date from Discontinuation page;
    __ldosedtc = ' ';
    __ldosedtc = __ldosedtc2;
    if __ldosedtc = ' ' then do;
        __ldosedtc = 'N.A.';
        return;
    end;

    %concatdy(__ldosedtc);

    if __ldosedtc ^= 'N.A.' then do;    
        __ldosedtc = substr(__ldosedtc, 1, 10)||"&escapechar{super [2]}"||substr(__ldosedtc, 11);
        __footnote2 = '[2] Treatment End Date captured in Study Drug Discontinuation-Ibrutinib Form';
    end;
    
    /*
    if rc2 = 0 then __ldosedtc = strip(__ldosedtc)||' (Dose Stopped)';
    else if __exdisc = 'Checked' then __ldosedtc = strip(__ldosedtc)||' (Dose Stopped)';
    __ldosedtc = substr(__ldosedtc, 1, 10)||"&escapechar{super [2]}"||substr(__ldosedtc, 11);
    if rc2 > 0 and __exdisc = ' ' then __ldosedtc = strip(__ldosedtc)||' (Ongoing)';

    length __footnote2 $255;
    if rc2 = 0 then __footnote2 = '[2] Last Dose Date from Study Drug Discontinuation-Ibrutinib Form';
    else __footnote2 = '[2] Last Dose Date from Ibrutinib Dose Administration Form';

    ** Ken Cao on 2015/03/10: Assign "N.A" for subject that is still taking Ibrutinib;
    if rc2 > 0 and __exdisc = ' ' then do;
        __ldosedtc = ' ';
        __footnote2 = ' ';
    end;
    */
run;

data dm1;
    length subject $13 __fdosedtc $20 __ldosedtc $100 __latestdosedtc $255 __footnote2 __footnote3 $255;
    if _n_ = 1 then do;
        declare hash h (dataset:'_exbtk2');
        rc = h.defineKey('subject');
        rc = h.defineData('__fdosedtc', '__ldosedtc', '__latestdosedtc' , '__footnote2', '__footnote3');
        rc = h.defineDone();
        call missing(subject, __fdosedtc, __ldosedtc, __latestdosedtc, __footnote2, __footnote3);
    end;
    set dm0;
    rc = h.find();
/*    drop rc;*/
run;








/** AGE, Informed Consent Date, Protocol Version **/;
data _ie;
    set source.ie(where=(iecat = ' ') keep=subject iecat iedt ieprot ieprota);
    %subject;
    length __iedtc $20;
    label __iedtc = 'Informed Consent Date';
    %ndt2cdt(ndt=iedt, cdt=__iedtc);

    length __ieprot $40;
    if ieprot = 'Original' then __ieprot = ieprot;
    else __ieprot = strip(ieprot)||' '||ifc(ieprota>., strip(vvaluex('ieprota')), ' ');

    keep subject __iedtc __ieprot;
run;

data dm2;
    length subject $13 rfstdtc $10 __iedtc $20 __ieprot $40;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        declare hash h2 (dataset:'_ie');
        rc2 = h2.defineKey('subject');
        rc2 = h2.defineData('__iedtc', '__ieprot');
        rc2 = h2.defineDone();
        call missing(subject, rfstdtc, __iedtc, __ieprot);
    end;
    set dm1;
    rc2 = h2.find();
    length __age $40;
    label __age = 'Age';
    %ageint(RFSTDTC=__iedtc, BRTHDTC=birthdtc, AGE=__age);

    rc = h.find();
    %concatDY(__iedtc);
    if __age = ' ' then __age = 'N.A.';
    drop rc ;
run;


/** Initial DLBCL Diagnosis Date **/;
data _inidate;
    set source.ch(keep=subject chst:);
    %subject;

    length __chstdtc $10;
    label __chstdtc = 'DLBCL Diagnosis Date ';
    %concatDate(year=chstyy, month=chstmm, day=chstdd, outdate=__chstdtc);

    keep subject __chstdtc;
run;

data dm3;
    length subject $13 __chstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'_inidate');
        rc = h.defineKey('subject');
        rc = h.defineData('__chstdtc');
        rc = h.defineDone();
        call missing(subject, __chstdtc);
    end;
    set dm2;
    rc = h.find();
    drop rc;
run;


/** Site Name **/;
data dm4;
    length subject $13 __sitenm $200;
    if _n_ = 1 then do;
        declare hash h (dataset:'source.sites(rename=(siteid=__site siteDescription=__sitenm))');
        rc = h.defineKey('__site');
        rc = h.defineData('__sitenm');
        rc = h.defineDone();
        call missing(subject, __sitenm);
    end;
    set dm3;
    rc = h.find();
    drop rc;
run;



/* Death Date */
data _death;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set source.death;
    %subject;
    length __deathdtc $255;
    label __deathdtc = 'Death Date';
    %concatDate(year=deathyy, month=deathmm, day=deathdd, outdate=__deathdtc);

    rc = h.find();
    %concatdy(__deathdtc); 

    keep subject __deathdtc;
run;

data dm5;
    length subject $13 __deathdtc $255;
    if _n_ = 1 then do;
        declare hash h (dataset:'_death');
        rc = h.defineKey('subject');
        rc = h.defineData('__deathdtc');
        rc = h.defineDone();
        call missing(subject, __deathdtc);
    end;
    set dm4;
    rc = h.find();
    drop rc;
run;


%macro concat(varlist, nblank, outvar);
%local nvar;
%local i;
%local var;

%if %length(&nblank) = 0 %then %let nblank = 5;

%let varlist = %sysfunc(prxchange(s/\s+/ /, -1, &varlist));
%let varlist = %sysfunc(strip(&varlist));

%let nvar = %eval(%sysfunc(countc(&varlist, " ")) + 1);

%do i = 1 %to &nvar;
    %let var = %scan(&varlist, &i, " ");
    &outvar = strip(&outvar)||repeat(" ", &nblank - 1)||"&escapechar{style [fontweight=bold]"||strip(vlabel(&var))||'}: '||strip(vvaluex("&var"));
%end;

&outvar = strip(&outvar);
%mend concat;


/* wrap up  */
data predm;
    set dm5(rename=(__age=__age__));
    label subject = 'Subject ID';
    length __title1 __title2  __title3 $400;
    
    if __ieprot = ' ' then __ieprot = 'N.A.';
    if __chstdtc = ' ' then __chstdtc = 'N.A.';
    if __fdosedtc = ' ' then __fdosedtc = 'N.A.';
    if __ldosedtc = ' ' then __ldosedtc = 'N.A.';
    if __deathdtc = ' ' then __deathdtc = 'N.A.';
    
    if __latestdosedtc = ' ' then __latestdosedtc = 'N.A.';

    label __age__     = "Age &escapechar{super [1]}";
    label __ieprot    = 'Protocol Version';
    label __sitenm    = 'Site Name';
    label __iedtc     = 'Informed Consent Date';
    label __chstdtc   = 'DLBCL Diagnosis Date';
    label __fdosedtc  = 'First Dose Date';
    label __ldosedtc  = 'Treatment End Date';
    label __deathdtc  = 'Death Date';
    label cbpn02      = 'Post menopausal';
    label cbpn04      = 'Hysterectomy';
    label cbpn01      = 'Bilateral oophorectomy';
    label cbpno       = 'Other(Specify)';
    label __latestdosedtc = 'Latest Dose Date';

    ** Ken Cao on 2015/03/23: Combine Site ID and Site Name ;
    length __site2 $255;
    label __site2 = 'Site';

    __site2 = strip(__site)||' ('||strip(__sitenm)||')';

    length __footnote4 $255;
    if __deathdtc = 'N.A.' then do;
        __deathdtc = strip(__deathdtc)||"&escapeChar{super [4]}";
        __footnote4 = '[4] Subject is either on treatment or lost to follow up';
    end;



    %concat(subject sex __age__, ,__title1);
    %concat(__site2 __iedtc __chstdtc, 3 ,__title2);
    %concat(__fdosedtc __ldosedtc __latestdosedtc __deathdtc ,,__title3);

    length __footnote1 $255;
    __footnote1 = '[1] Age is calculated as (Informed Consent Date - Birthday + 1)/365.25.';

    if __age__ ^= 'N.A.' then  __age = input(scan(__age__, 1, "&escapechar"), best.); ** __age is for deriving lab normal range;  
    drop __age__;
run;

proc sort data=predm; by subject; run;

/* final dataset */

data pdata.dm(label='Demographics');
    retain __edc_treenodeid __edc_entrydate subject birthdtc sex cbp cbpn02 cbpn04 cbpn01 cbpno ethnic race
         __age __title1 __title2 __title3 __footnote1 __footnote2 __footnote3 __footnote4;
    keep __edc_treenodeid __edc_entrydate subject birthdtc  sex cbp cbpn02 cbpn04 cbpn01 cbpno ethnic race
         __age __title1 __title2 __title3 __footnote1 __footnote2 __footnote3 __footnote4;
    set predm;


    label sex = 'Sex at Birth';
    label cbpn02 = "Post menopausal (no menses for >= 24 months)";
run;
