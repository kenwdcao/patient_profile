/***********************************************************************************
 Program Nmae: DM.sas
  @Author: Taodong Chen
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/04: Display UNK and NULL for BIRTHDTC and DTHDTC.
 Ken Cao on 2015/03/05: 1) Concatenate --DY to Informed Consent Date First Dose 
                           Date and Last Dose Date.
                        2) Move Informed Consent Date to __title3.

*******************************************************************************/

%include '_setup.sas';
proc sort data=source.dm out=s_dm nodupkey; by _all_; run;
proc sort data=source.ie out=s_ie nodupkey; by _all_; run;
proc sort data=source.siteinv out=s_siteinv nodupkey; by _all_; run;
proc sort data=source.sites out=s_sites nodupkey; by _all_; run;
proc sort data=source.dr out=s_dr nodupkey; by _all_; run;
proc sort data=source.ex out=s_ex nodupkey; by _all_; run;
proc sort data=source.dd out=s_dd nodupkey; by _all_; run;

data dm1;
    length birthdtc  $40;

    set s_dm(rename =(edc_treenodeid=__edc_treenodeid EDC_EntryDate = __EDC_EntryDate) );

    %concatDateV2(year=birthyy, month=birthmm, day=birthdd, outdate=birthdtc);
    cbp=put(cbp,$checked.);

/*  array cb0n(*) cbpn01-cbpn05 _char_;*/
/*    array cbcnum(*) cbpnum1-cbpnum5 _char_;*/
/*    do i=1 to dim(cb0n);*/
/*        cbcnum(i)=put(cb0n(i),$checked.);;*/
/*    end;*/

 cbpn01=put(cbpn01,$checked.);
  cbpn02=put(cbpn02,$checked.);
   cbpn03=put(cbpn03,$checked.);
    cbpn04=put(cbpn04,$checked.);
     cbpn05=put(cbpn05,$checked.);

    if race1 ^='' then race1='American Indian or Alaska Native';
    if race2 ^='' then race2='Asian';
    if race3 ^='' then race3='Black';
    if race4 ^='' then race4='Native Hawaiian Pacific Islander';
    if race5 ^='' then  race5='White';
    ;
    drop EDC_:;
run;
proc sort;by subject;run;
/*Get Site Name from SITEINV*/
data siteinv;
length site $3;
set s_siteinv;
    site=siteid;
    keep  site site_name investigator country;
run;
proc sort data=siteinv nodupkey;by site;run;

/*Get inform consent dtc from IE*/
data ie;
    set s_ie;
    keep subject iedt;
run;
proc sort;by subject;run;

/*Get Death dtc from DR*/
data dr;
    set s_dr;

    length dthdtc  $40;

    %concatDateV2(year=deathyy, month=deathmm, day=deathdd, outdate=dthdtc);
    keep subject dthdtc;
run;
proc sort;by subject;run;

/*Get endtc from DD*/
data dd;
    set s_dd;

    length ldosedtc  $40;
     %ndt2cdt(ndt=ldosedt, cdt=ldosedtc);
    keep subject ldosedtc;
run;
proc sort;by subject;run;

/*Get  Ibrutinib Dose Date from EX*/
data ex1 ex2;
    set s_ex(where=(exadose ^='Missed Dose'));
    if exstdt ^=. then do; keep subject exstdt;output ex1;end;
    if exendt ^=. then do; keep subject exendt;output ex2;end;
run;

data ex_all;
set ex1(rename=(exstdt=dtc) drop=exendt)
    ex2(rename=(exendt=dtc) drop=exstdt)
;
run;
proc sort;by subject dtc;run;

data ex_all1;
set ex_all;
    by subject dtc;
    if first.subject then stdtc= dtc;
    if last.subject  then endtc=dtc;
    if first.subject or last.subject;
run;

data ex_all2;
retain exstdt;
set ex_all1;
    by subject dtc;
    if first.subject then exstdt=stdtc;
    exendt=endtc;
    if last.subject;
    length exstdtc $20 exendtc $20;
    %ndt2cdt(ndt=exstdt, cdt=exstdtc);
    %ndt2cdt(ndt=exendt, cdt=exendtc);
    keep subject exstdtc exendtc;
run;

data dm_ex;
    length iedtc $20;
    merge dm1(in=in0) ie(in=in1)  dr(in=in3) ex_all2(in=in4) dd(in=in5);
    by subject;
    if in0;
    %ndt2cdt(ndt=iedt, cdt=iedtc);
    %ageint(RFSTDTC=iedtc, BRTHDTC=birthdtc, Age=AGE);
    %subject;

    if exstdtc ='' then exstdtc ='NA';
    if exendtc ='' then exendtc ='NA';
    if ldosedtc='' then ldosedtc='NA';
run;
proc sort;by site;run;

/*Get  other site info from sites*/
data sites;
    set s_sites(rename=(SiteID=Site));
    keep Site SiteDescription;
run;
proc sort ;by site;run;




data dm_sites;
length subject $13 rfstdtc $10;
if _n_ = 1 then do;
    declare hash h (dataset:'pdata.rfstdtc');
    rc = h.defineKey('subject');
    rc = h.defineData('rfstdtc');
    rc = h.defineDone();
    call missing(subject, rfstdtc);
end;    

length sitename race $100 __title __title2 __title3 $400 __footnote1 $255;
merge dm_ex(in=in0) sites(in=in1) siteinv(in=in2);
    by site;
    if in0;
    if site_name ^='' then sitename=site_name;
    else sitename=sitedescription;
 
    race=catx('; ', race1, race2, race3, race4, race5);
    if strip(investigator)='' then investigator='NA';
    if dthdtc='' then dthdtc='NA';
    age="&escapechar.S={fontweight=bold}Age&escapechar{super [1]}: "||strip(age);

    rc = h.find();
    %concatDY(iedtc);
    %concatDY(exstdtc);
    %concatDY(ldosedtc);
    %concatDY(dthdtc);
    drop rc;

    investigator = 'Demo Investigator';
    sitename = 'Demo Site';

    __TITLE="&escapechar{style [fontweight=bold]Subject ID: }"||strip(subject)||"     &escapechar{style [fontweight=bold]Study Site: }"
             ||strip(site)||"     &escapechar{style [fontweight=bold]Sex: }" ||strip(sex)||"     "||strip(age);

    __TITLE2="&escapechar{style [fontweight=bold]Site Name: }"
             ||strip(sitename)||"     &escapechar{style [fontweight=bold]Investigator Name: }"||strip(investigator)
             ||"     &escapechar{style [fontweight=bold]Informed Consent Date: }"||strip(iedtc)
             ;
    __TITLE3=  "&escapechar{style [fontweight=bold]IMP First Dose Date: }"||strip(exstdtc)
               ||"     &escapechar{style [fontweight=bold]IMP Last Dose Date: }"||strip(ldosedtc)
               ||"     &escapechar{style [fontweight=bold]Death Date: }"||strip(dthdtc);

    __footnote1 = '[1] Age is calculated as (Informed Consent Date - Birthday + 1)/365.25.';
   rename sex=__sex age=__age site=__site sitename=__sitename investigator=__investigator iedtc=__iedtc exstdtc=__exstdtc ldosedtc=__ldosedtc dthdtc=__dthdtc;
    keep __edc_treenodeid __EDC_EntryDate sitename __title __title2 __title3 __footnote1 iedtc birthdtc site subject sex cbp cbpn01 cbpn02 cbpn04 cbpn03 cbpn05 cbpno
    ethnic race country iedt investigator dthdtc exstdtc ldosedtc age;
run;
proc sort;by subject;run;

data pdata.DM(label='Demographics');
    retain  __edc_treenodeid __EDC_EntryDate subject birthdtc cbp cbpn01 cbpn02 cbpn03 cbpn04 cbpn05 cbpno
    ethnic race  country  __site  __sex __age __sitename __investigator __exstdtc __ldosedtc __dthdtc __title __title2 __title3 __footnote1;
    keep  __edc_treenodeid __EDC_EntryDate subject birthdtc cbp cbpn01 cbpn02 cbpn03 cbpn04 cbpn05 cbpno
    ethnic race  country  __site  __sex __age __sitename __investigator __exstdtc __ldosedtc __dthdtc __title __title2 __title3 __footnote1;
    set dm_sites;
    label 
        BIRTHDTC = 'Birth Date'
          CBPN01 = 'Post menopausal@:If No, Specify Reason'
          CBPN02 = 'Hysterectomy@:If No, Specify Reason'
          CBPN04 = 'Tubal Ligation@:If No, Specify Reason'
          CBPN03 = 'Bilateral oophorectomy@:If No, Specify Reason' 
          CBPN05 = 'Other@:If No, Specify Reason'
           CBPNO = 'Other Specify@:If No, Specify Reason'
            RACE = 'Race'
          ethnic = 'Ethnic'
         country = 'Country'
    ;
run;
