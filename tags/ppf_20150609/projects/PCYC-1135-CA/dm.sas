/*********************************************************************
 Program Nmae: dm.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/24
 

 This program is originally from PCYC-1135-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data dm0;
    set source.dm;
    keep EDC_TreeNodeID SITE SUBJECT VISIT AGE BRTHDAT SEX CBP ETHNIC 
		RACE1 RACE2 RACE3 RACE4 RACE5 EDC_EntryDate;
run;

data dm1;
    length subject $13 entrtgrp $36 siteid $4 SiteDescription $30;
    if _n_ = 1 then do;

        declare hash h (dataset:'source.enroll');
        rc = h.defineKey('subject');
        rc = h.defineData('entrtgrp');
        rc = h.defineDone();

        declare hash h2 (dataset:'source.sites');
        rc2 = h2.defineKey('siteid');
        rc2 = h2.defineData('SiteDescription');
        rc2 = h2.defineDone();

		call missing(subject, entrtgrp, siteid, SiteDescription);
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
/*	if BRTHDAT ne . then birthdtc = strip(put( BRTHDAT, yyddmm10.));*/
    if BRTHDAT ne . then birthdtc = strip(put( BRTHDAT, yymmdd10.)); 
	
	rc = h.find();
    drop rc;

    ** Site Name;
    length sitename $200;
    siteid = site;
    rc2 = h2.find();
    drop rc2;
    sitename = SiteDescription;
    drop siteid SiteDescription;
    
    %subject;
run;


** First Dose Date, Latest Dose Date and Treatment End Date;
***first/last dose date for Ibrutinib***;
data ex;
    length SDTCI EDTCI $19; 
    set source.ex;
    format SDTI EDTI date9.;
    if EXSTMO ne '' then EXSTMO = strip(put( EXSTMO, $mon.));
    if cmiss(EXSTYR, EXSTMO, EXSTDY) < 3 then do;
        SDTCI = strip(EXSTYR)||'-'||strip(EXSTMO)||'-'||strip(EXSTDY);
    end;
    if SDTCI ne '' then SDTI = input( SDTCI, yymmdd10.); 

    if EXENMO ne '' then EXENMO = strip(put( EXENMO, $mon.));
    if cmiss(EXENYR, EXENMO, EXENDY) < 3 then do;
        EDTCI = strip(EXENYR)||'-'||strip(EXENMO)||'-'||strip(EXENDY);
    end;
    if EDTCI ne '' then EDTI = input( EDTCI, yymmdd10.); 

    keep SUBJECT EXSTDY EXSTMO EXSTYR SDTCI SDTI EDTCI EDTI;
run;

data exi_start_end;
	set ex(keep=SUBJECT SDTCI SDTI rename=(SDTI=TRTDT SDTCI=TRTDTC))
		ex(keep=SUBJECT EDTCI EDTI rename=(EDTI=TRTDT EDTCI=TRTDTC));
run;

proc sort data=exi_start_end(where=(TRTDT^=.)) out=exi_start_end1; by SUBJECT TRTDT; run;

***first dose date for Ibrutinib***;
data ex_first_i(rename=(TRTDT=TRTSDTI TRTDTC=TRTSDTCI));
    set exi_start_end1;
    by SUBJECT TRTDT;
    if first.subject;
    keep SUBJECT TRTDTC TRTDT;
run;

***last dose date for Ibrutinib***;
data ex_last_i(rename=(TRTDT=TRTEDTI TRTDTC=TRTEDTCI));
    set exi_start_end1;
    by SUBJECT TRTDT;
    if last.subject;
    keep SUBJECT TRTDTC TRTDT;
run;

***first/last dose date for MEDI4736***;
data exmedi;
    length SDTCM $19; 
    set source.exmedi;
    format SDTM date9.;
    SDTM = DOSEDAT;
    if SDTM ne . then SDTCM = strip(put( SDTM, yymmdd10.));
    keep SUBJECT SDTCM SDTM;
run;

proc sort data=exmedi(where=(SDTM^=.)) out=exmedi1; by SUBJECT SDTM; run;

***first dose date for MEDI4736***;
data ex_first_m(rename=(SDTM=TRTSDTM SDTCM=TRTSDTCM));
    set exmedi1;
    by SUBJECT SDTM;
    if first.subject;
    keep SUBJECT SDTCM SDTM;
run;

***last dose date for MEDI4736***;
data ex_last_m(rename=(SDTM=TRTEDTM SDTCM=TRTEDTCM));
    set exmedi1;
    by SUBJECT SDTM;
    if last.subject;
    keep SUBJECT SDTCM SDTM;
run;

****Date of Last Dose from Study Drug Discontinuation form****;
proc sql;
	create table discdate as
	select distinct SUBJECT, DISCCAT, max( LDOSEDAT) as maxdtc  
	from source.disc
	group by SUBJECT, DISCCAT
	;
quit;

****merge ex_first_i ex_last_i ex_first_m ex_last_m***;
data trt2(keep=SUBJECT btkfdtc btkldtc btkendtc medfdtc medldtc medendtc);
	merge ex_first_i ex_last_i ex_first_m ex_last_m 
		  discdate(in=in_btk where=(index(upcase(DISCCAT), 'IBRUTINIB')>0))
		  discdate(in=in_med where=(index(upcase(DISCCAT), 'MEDI4736')>0))
	;
	by SUBJECT;
    %subject;
	if maxdtc ne . then LDOSEDTC = strip(put( maxdtc, yymmdd10.));
	if in_btk then btkendtc = LDOSEDTC;
	if in_med then medendtc = LDOSEDTC;
	rename
	TRTSDTCI = btkfdtc
	TRTEDTCI = btkldtc
	TRTSDTCM = medfdtc
	TRTEDTCM = medldtc
	;
run;


**************;
proc sort data=dm1; by subject; run;

data dm2;
    merge dm1 trt2;
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



data dm3;
    set dm2;
    length __title1 __title2 __title3 $1024;
    length __footnote1 __footnote2 $1024;

    label subject = 'Subject ID';
    label __sex = 'Sex';
    label __age = 'Age';
    length __sex $1 __age $20;
    label __site = 'Site';
    length __site $255;
    label __site = 'Site';
    length __site $255;
    label __entrtgrp = 'Treatment Group';
    length __entrtgrp $255;
    drop __sex __age;

    __sex = substr(sex, 1, 1);
    if age ^= . then __age = strip(put( age, best.))||" &escapeChar{Super [1]}";
    __footnote1 = '[1] Age is from Demographics form';
    __site = strip(site)||' ('||strip(sitename)||')';
    __entrtgrp = strip( entrtgrp);
    %concat(subject __site __sex __age __entrtgrp, , __title1);

    label btkfdtc   = "Ibrutinib First Dose Date";
    label btkldtc   = "Ibrutinib Latest Dose Date";
    label btkendtc  = "Ibrutinib Last Dose Date &escapeChar{super [2]}";
    label medfdtc   = "MEDI4736 First Dose Date";
    label medldtc   = "MEDI4736 Latest Dose Date";
    label medendtc  = "MEDI4736 Last Dose Date &escapeChar{super [2]}";

    %concat(btkfdtc btkldtc btkendtc, , __title2, 50);
    %concat(medfdtc medldtc medendtc, , __title3, 50);

    __footnote2 = "[2] Last Dose Date from Study Drug Discontinuation form";

run;


data pdata.dm(label="Demographic");

    retain EDC_TREENODEID EDC_ENTRYDATE SUBJECT VISIT BIRTHDTC AGE SEX CBP  
           ETHNIC RACE __ENTRTGRP /*IECOHORT*/ __TITLE1 __TITLE2 __TITLE3 __FOOTNOTE1 __FOOTNOTE2;
    keep   EDC_TREENODEID EDC_ENTRYDATE SUBJECT VISIT BIRTHDTC SEX CBP 
           RACE ETHNIC AGE __ENTRTGRP /*IECOHORT*/ __TITLE1 __TITLE2 __TITLE3 __FOOTNOTE1 __FOOTNOTE2;
    set dm3;

    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename  EDC_ENTRYDATE = __EDC_ENTRYDATE;
    rename          VISIT = __VISIT;
/*    rename            AGE = __AGE;*/
/*    rename       IECOHORT = __IECOHORT;*/

    label BIRTHDTC = 'Date of Birth';
    label      SEX = 'Sex at Birth';
    label      AGE = 'Subjects Age';
    label      CBP = "If 'Female', is subject of childbearing potential?";
/*    label IECOHORT = 'Phase 1b Cohort No.';*/
run;
