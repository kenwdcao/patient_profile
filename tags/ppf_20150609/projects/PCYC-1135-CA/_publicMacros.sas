/*********************************************************************
 Program Nmae: _publicMacros.sas
  @Author: Ken Cao
  @Initial Date: 2015/04/08
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/


/*
** transform numeric date value to character date (default format is yymmdd10.);
** Example 1: use default format
length cmdtc $10;
%ndt2cdt(ndt=cmdt, cdt=cmdtc);
** Example 2: use non-default format
length cmdtc $10;
%ndt2cdt(ndt=cmdt, cdt=cmdtc, fmt=date9.);
*/
%macro ndt2cdt(ndt, cdt, fmt=yymmdd10.);
    if &ndt > . then &cdt = put(&ndt, &fmt);
%mend ndt2cdt;


/*
** transform numeric time value to character time (default format is time5.);
*/
%macro ntime2ctime(ntime=, ctime=, fmt=time5.);
    if &ntime > . then &ctime = put(&ntime, &fmt);
%mend ntime2ctime;

%macro ntm2ctm(ntm, ctm, fmt=time5.);
    %ntime2ctime(ntime=&ntm, ctime=&ctm, fmt=&fmt);
%mend ntm2ctm;



%macro concatDate(year=, month=, day=, outdate=);

    length __year $4 __month $4 __day $4;

    __year = &year;
    __month = &month;
    __day = &day;

    &outdate = ' ';

    if cmiss(__year, __month, __day) < 3 then do;
        if __year = ' ' then __year = 'UNK';
        if __month = ' ' then __month = 'UNK';
        if __day = ' ' then __day = 'UNK';
        &outdate = strip(__year)||'-'||strip(put(__month, $mon.))||'-'||strip(__day);
    end;

    drop __year __month __day;
%mend concatDate;



* removes STUDY ID from subject ID ;
%macro subject;
    subject = substr(subject, 7);
%mend subject;


%macro ageint(RFSTDTC=, BRTHDTC=, AGE=);
    __RFSTDTC = &RFSTDTC;
    __BRTHDTC = &BRTHDTC;
    if __RFSTDTC ^= '' 
    and length(compress(__RFSTDTC)) = 10 
    and __BRTHDTC ^= '' 
    and length(compress(__BRTHDTC)) = 10 then
      &AGE = strip(put(int((input(substr(__RFSTDTC, 1, 10), yymmdd10.) - input(substr(__BRTHDTC, 1, 10), yymmdd10.) + 1)/365.25), best.));
    drop __RFSTDTC __BRTHDTC;
%mend ageint; 




%macro dy(datevar, dyvar);
    __isdate = 0;
    __isdate = prxmatch('/^\d{4}-\d{2}-\d{2}$/', strip(&datevar));
    if rfstdtc = ' ' or __isdate = 0 then &dyvar = .;
    else do;
       __rfstdt__ = input(rfstdtc, yymmdd10.);
         __date__ = input(&datevar, yymmdd10.);
         &dyvar = ifn(__date__>=__rfstdt__, __date__-__rfstdt__+1, __date__-__rfstdt__);
    end;
    drop __isdate __rfstdt__ __date__ rfstdtc;
%mend dy;

/*
** derive --DY and concatenate it with date variable
Parameter:
    datevar: YYYY-MM-DD format date (char); !!! MAKE SURE VARIABLE LENGTH IS LONGER ENOUGH !!!
Example:
    data ae2;
        length subject $13 rfstdtc $10;
        if _n_ = 1 then do;
            declare hash h (dataset:'pdata.rfstdtc');
            rc = h.defineKey('subject');
            rc = h.defineData('rfstdtc');
            rc = h.defineDone();
            call missing(subject, rfstdtc);
        end;
        set ae;
        rc = h.find();
        %concatdy(aestdtc);
        %concatdy(aeendtc);
        drop rc;
    run;
*/
%macro concatdy(datevar);
%dy(&datevar, __dy__);
if __dy__ > . then &datevar = strip(&datevar)||' ('||strip(vvaluex('__dy__'))||')';
drop __dy__;
%mend concatdy;
/**/
/*%macro visit(source=, dsn=);*/
/*%if &dsn=eg %then  %do;*/
/*data &dsn._v1;*/
/*set &source..&dsn;*/
/*length CYCLE $10 SEQ 8;*/
/*CYCLE="";*/
/*SEQ=.;*/
/*run;*/
/*%end;*/
/**/
/*%else %if &dsn=pt or &dsn=bp  %then  %do;*/
/*data &dsn._v1;*/
/*set &source..&dsn;*/
/*length CYCLE $10;*/
/*CYCLE="";*/
/*run;*/
/*%end;*/
/**/
/*%else %if &dsn=staging %then  %do;*/
/*data &dsn._v1;*/
/*set &source..&dsn;*/
/*length CYCLE $10;*/
/*CYCLE="";*/
/*UNSSEQ=.;*/
/*SEQ=.;*/
/*run;*/
/*%end;*/
/**/
/*%else  %do;*/
/*data &dsn._v1;*/
/*set &source..&dsn;*/
/*run;*/
/*%end;*/
/**/
/*data &dsn._v(rename=(visit_=visit)) ;*/
/*set &dsn._v1;*/
/*attrib visit_ label="Visit" length=$255;*/
/*if visit="Screening" then do; visit_="Screening" ; visitnum=0;end;*/
/*else if visit="Dose Administration" then do; visit_="Dose Administration" ; visitnum=0.5;end;*/
/*else if visit="End of Treatment" then do; visit_="End of Treatment" ; visitnum=98;end;*/
/**/
/*else if visit="Response Follow-Up" and seq^=. then do; visit_=strip(visit)|| " " ||strip(put(seq,best.)); */
/*visitnum=input("100." || strip(put(seq,best.)), best.);end;*/
/**/
/*else if visit="Suspected PD" and seq^=. then do;visit_=strip(visit)|| " " ||strip(put(seq,best.));*/
/*visitnum=input("97." || strip(put(seq,best.)), best.);end;*/
/**/
/*else if visit="Unscheduled Visit" and unsseq^=. then do;visit_=strip(visit)|| " " ||strip(put(unsseq,best.));*/
/*visitnum=input("99." || strip(put(unsseq,best.)), best.);end;*/
/**/
/*else if cycle ^="" and visit="Day 22-28" then do;visit_=strip(cycle)||" " ||strip(visit);*/
/*visitnum=input((scan(cycle,2,"")||".2228"),best.);end;*/
/**/
/*else if cycle ^="" and visit^="" then do;visit_=strip(cycle)||" " ||strip(visit);*/
/*visitnum=input(scan(cycle,2,"")||"."|| strip(put(input(scan(visit,2,""),best.),z2.)),best.);end;*/
/*else do; visit_=""; visitnum=.;end;*/
/*drop visit;*/
/*run;*/
/*proc sort data=&dsn._v; by subject visitnum;run;*/
/*%mend visit;*/


%macro exvisitn(cycle, day);

__visitn = input(scan(&cycle, 2, ' '), best.) * 10E5 + &day;

%mend exvisitn;



%macro visit2();
if _n_ = 1 then do;
    ** In case some of below variables are not in the input dataset;
/*    call missing(cycle, visit, unsseq);*/
    if cycle = ' ' then cycle = ' ';
    if visit = ' ' then visit = ' ';
    if unsseq = .  then unsseq = .;
end;
length visit2 $255;
visit2 = strip(strip(vvaluex('cycle'))||' '||strip(vvaluex('visit'))||' '||ifc(unsseq > ., strip(vvaluex('unsseq')), ' '));
label visit2="Visit";
drop visit cycle unsseq;
%mend visit2;




%macro IsNumeric(InStr=, Result=);
    length __InStr $200;
   &Result = 1;
   __PeriodCount = 0;

   __InStr = trim(left(&InStr));
   if substr(__InStr, 1, 1) in ('-', '+') then __InStr = trim(left(substr(__InStr, 2)));

   do __n = 1 to length(__InStr);
      if substr(__InStr, __n, 1) not in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.') then
         &Result = 0;
      if substr(__InStr, __n, 1) = '.' then __PeriodCount = __PeriodCount + 1;
   end;
   if __PeriodCount > 1 then &Result = 0;
   drop __InStr __PeriodCount __PeriodCount __n ;
%mend IsNumeric;
