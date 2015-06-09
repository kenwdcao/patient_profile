/*********************************************************************
 Program Nmae: DM.sas
  @Author: ZSS
  @Initial Date: 2015/03/13
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/18: Add --DY to date in titles.

*********************************************************************/

%include '_setup.sas';

proc sort data=source.dm out=s_dm nodupkey; by _all_; run;
proc sort data=source.ic out=s_ic nodupkey; by _all_; run;
proc sort data=source.fl out=s_fl nodupkey; by _all_; run;
proc sort data=source.pdfu out=s_pdfu nodupkey; by _all_; run;
proc sort data=source.death out=s_death nodupkey; by _all_; run;
proc sort data=source.dadm out=s_dadm nodupkey; by _all_; run;
proc sort data=source.exrit out=s_exrit nodupkey; by _all_; run;
proc sort data=source.sites out=s_sites nodupkey; by _all_; run;

**** demographics ***;
data dm_0;
      length race $200;
      set s_dm(rename=(ID=__ID race=in_race sex=in_sex ethnic=in_ethnic));

     %subject;
     if cbp=1 then cbpyn='Yes'; else if cbp=0 then cbpyn='No';
     if cbpn01=1 then cbpn01c="Yes";
     if cbpn02=1 then cbpn02c="Yes";
     if cbpn03=1 then cbpn03c="Yes";
     if cbpn04=1 then cbpn04c="Yes";
     if cbpno=1 then cbpnoc="Yes";
     
     if in_race=0 then race_="None Selected";
     if race01=1 then race01c="American Indian or Alaska Native";
     if race02=1 then race02c="Asian";
     if race03=1 then race03c="Black or African American";
     if race04=1 then race04c="Native Hawaiian or Other Pacific Islander";
     if race05=1 then race05c="White";
     race=catx("; ", race_, race01c, race02c, race03c, race04c, race05c, raceothe);
     siteid=site_id;
     __subid=subid;
     sex=strip(put(in_sex, sex.));
     ethnic=strip(put(in_ethnic, ethnic.));
     keep __id subject __subid siteid subinit birthdtc sex cbpyn cbpn01c cbpn02c cbpn03c cbpn04c cbpnoc cbpnos ethnic race;
run;

*** site name ***;
proc sql;
     create table dm_1 as
     select a.*, b.site_nam from dm_0 as a left join s_sites as b on a.siteid=b.site_id;
quit;

*** FL diagnosis ****;
proc sql;
     create table dm_2 as
     select a.*, b.fldxdtc, b.flgrd, b.flstg from dm_1 as a left join s_fl as b on a.siteid=b.site_id and a.__subid=b.subid;
quit;

data dm_2;
      set dm_2;
      if flgrd^=. then __flgrd=strip(put(flgrd, flgrd.));
      if flstg^=. then __flstg=strip(put(flstg, flstg.));
run;

***informed consent date ***;
proc sql;
     create table dm_3 as
     select a.*, b.iedtc, b.arm from dm_2 as a left join s_ic as b on a.siteid=b.site_id and a.__subid=b.subid;
quit;

data dm_3;
     set dm_3;
     if birthdtc^='' and iedtc^='' then age=strip(put(int((input(iedtc, yymmdd10.) - input(birthdtc, yymmdd10.) + 1)/365.25), best.));
     if arm^=. then __arm='Arm '||strip(put(arm, best.));
run;

*** dose date of Ibrutinid and Rituximab***;
data ibrdt;
     set s_dadm;

     %subject;
     keep subject dastdtc daendtc dadisco;
run;

proc sort data=ibrdt(where=(dastdtc^='')) out=ibrdtc_0; by subject dastdtc; run;

data ibrst;
     length ibrstdtc $20;
     set ibrdtc_0;
     by subject dastdtc;
     if first.subject then ibrstdtc=dastdtc;
     if first.subject;
	 keep subject ibrstdtc;
run;

proc sql;
      create table ibrsten as
	  select distinct a.subject, b.ibrstdtc, c.daendtc as ibrendtc length=20
	  from ibrdt as a 
      left join ibrst as b on a.subject=b.subject
      left join ibrdt as c on a.subject=c.subject and c.dadisco=1;
quit;

data ritdt;
     set s_exrit;

     %subject;
     keep subject exstdtc exdisc;
run;

proc sort data=ritdt(where=(exstdtc^='')) out=ritdtc; by subject exstdtc; run;

data ritst;
     length ritstdtc $20;
     set ritdtc;
     by subject exstdtc;
     if first.subject then ritstdtc=exstdtc;
     if first.subject;
	 keep subject ritstdtc;
run;

proc sql;
      create table ritsten as
	  select distinct a.subject, b.ritstdtc, c.exstdtc as ritendtc length=20
	  from ritdt as a 
      left join ritst as b on a.subject=b.subject
      left join ritdt as c on a.subject=c.subject and c.exdisc=1;
quit;

proc sql;
     create table dm_4 as
     select a.*, b.ibrstdtc, b.ibrendtc, c.ritstdtc, c.ritendtc from dm_3 as a
     left join ibrsten as b on a.subject=b.subject
     left join ritsten as c on a.subject=c.subject;
quit;

/*
data ibrdt;
     set s_dadm;

     %subject;
     ibrdtc=dastdtc; output;
     ibrdtc=daendtc; output;

     keep subject ibrdtc;
run;

proc sort data=ibrdt(where=(ibrdtc^='')) out=ibrdtc; by subject ibrdtc; run;

data ibrsten;
     length ibrstdtc ibrendtc $20;
     set ibrdtc;
     by subject ibrdtc;
     retain ibrstdtc;
     if first.subject then ibrstdtc=ibrdtc;
     if last.subject then ibrendtc=ibrdtc;
     if last.subject;
run;

data ritdt;
     set s_exrit;

     %subject;
     keep subject exstdtc;
run;

proc sort data=ritdt(where=(exstdtc^='')) out=ritdtc; by subject exstdtc; run;

data ritsten;
     length ritstdtc ritendtc $20;
     set ritdtc;
     by subject exstdtc;
     retain ritstdtc;
     if first.subject then ritstdtc=exstdtc;
     if last.subject then ritendtc=exstdtc;
     if last.subject;
run;

proc sql;
     create table dm_4 as
     select a.*, b.ibrstdtc, b.ibrendtc, c.ritstdtc, c.ritendtc from dm_3 as a
     left join ibrsten as b on a.subject=b.subject
     left join ritsten as c on a.subject=c.subject;
quit;
*/


**** death date ****;
data death_0;
      set s_pdfu;
     %subject;
     if deathdtc='' and deathdtu^=. then do; deathdtc="Unknown"; end;
	 if deathdtc^='';
     keep subject deathdtc;
run;

data death_1;
      set s_death;
     %subject;
	 if deathdtc^='';
     keep subject deathdtc;
run;

proc sort data=death_0 out=death_2 nodupkey; by subject deathdtc; run;
proc sort data=death_1 out=death_3 nodupkey; by subject deathdtc; run;

data death;
       set death_2 (in=a)   death_3 (in=b);
	   if a or b;
run;

proc sort nodupkey; by subject deathdtc; run;

proc sql;
     create table dm_5 as
     select a.*, b.deathdtc from dm_4 as a   left join death as b on a.subject=b.subject;
quit;

data dm_5;
     set dm_5;
     array miss{5} deathdtc ibrstdtc ibrendtc ritstdtc ritendtc;
     do i=1 to 5;
     if miss{i}='' then do; miss{i}="N.A."; end;
     end;
run;

data dm;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set dm_5(rename=(iedtc=__iedtc deathdtc=__deathdtc fldxdtc=__fldxdtc 
                    ibrstdtc=__ibrstdtc ibrendtc=__ibrendtc ritstdtc=__ritstdtc ritendtc=__ritendtc));

    length iedtc deathdtc fldxdtc ibrstdtc ibrendtc ritstdtc ritendtc $20;

       iedtc = __iedtc;
    deathdtc = __deathdtc;
     fldxdtc = __fldxdtc;
    ibrstdtc = __ibrstdtc;
    ibrendtc = __ibrendtc;
    ritstdtc = __ritstdtc;
    ritendtc = __ritendtc;

    rc = h.find();

    %concatDY(iedtc);
    %concatDY(deathdtc);
    %concatDY(fldxdtc);
    %concatDY(ibrstdtc);
    %concatDY(ibrendtc);
    %concatDY(ritstdtc);
    %concatDY(ritendtc);


     __TITLE1="&escapechar{style [fontweight = bold]Subject}: "||strip(subject)||' ('||strip(subinit)||')'
                    ||"    &escapechar{style [fontweight = bold]Sex}: "||strip(sex)
                    ||"    &escapechar{style [fontweight = bold]Age &escapechar{super [1]}}: "||strip(age)
                    ||"    &escapechar{style [fontweight = bold]Arm Enrolled}: "||strip(__arm)
                    ;
     __TITLE2="&escapechar{style [fontweight = bold]Study Site}: "||strip(siteid)||' ('||strip(site_nam)||')'
                    ||"      &escapechar{style [fontweight = bold]Informed Consent Date}: "||strip(iedtc)
                    ||"      &escapechar{style [fontweight = bold]Death Date}: "||strip(deathdtc)
                    ;
     __TITLE3="&escapechar{style [fontweight = bold]Initial FL Diagnosis Date}: "||strip(fldxdtc)
                    ||"      &escapechar{style [fontweight = bold]FL Grade at Screening}: "||strip(__flgrd)
                    ||"      &escapechar{style [fontweight = bold]FL Stage at Screening}: "||strip(__flstg)
                    ;
     __TITLE4="&escapechar{style [fontweight = bold]Ibrutinib First/Last Dose Date}: "||strip(ibrstdtc)||' / '||strip(ibrendtc)
                    ||"      &escapechar{style [fontweight = bold]Rituximab First/Last Dose Date}: "||strip(ritstdtc)||' / '||strip(ritendtc)
                    ;
     __FOOTNOTE1="[1] Age is calculated as int((Informed Consent Date - Birth Date + 1)/365.25).";

     rename 
     subinit=__subinit
     sex=__sex
     age=__age
     siteid=__siteid
     site_nam=__sitenam
     /*
     iedtc=__iedtc
     deathdtc=__deathdtc
     fldxdtc=__fldxdtc
     ibrstdtc=__ibrstdtc
     ibrendtc=__ibrendtc
     ritstdtc=__ribstdtc
     ritendtc=__ribendtc
     */
    ;
run;

proc sort data=dm; by subject; run;

data pdata.dm(label="Demographics");
     retain __id subject birthdtc cbpyn cbpn01c cbpn02c cbpn03c cbpn04c cbpnoc cbpnos ethnic race __title1 __title2 __title3 __title4 __footnote1 __age __sex;
     set dm;
     attrib
        birthdtc          label = "Date of Birth"
           cbpyn          label = "Childbearing Potential"
         cbpn01c          label = "Post menopausal"
         cbpn02c          label = "Hysterectomy"
         cbpn03c          label = "Bilateral tubal ligation"
         cbpn04c          label = "Bilateral oophorectomy"
          cbpnoc          label = "Other"
          cbpnos          label = "Other specify"
          ethnic          label = "Ethnicity"
            race          label = "Race"
     ;
     keep __id subject birthdtc cbpyn cbpn01c cbpn02c cbpn03c cbpn04c cbpnoc cbpnos ethnic race __title1 __title2 __title3 __title4 __footnote1 __age __sex;
run;
