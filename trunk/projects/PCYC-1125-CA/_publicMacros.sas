/*********************************************************************
 Program Nmae: _publicMacros.sas
  @Author: Ken Cao
  @Initial Date: 2015/01/25
 
 Public (shared) macro goes here.
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/





* concatenate SITE_ID and SUBID;
%macro subject;
    length subject $255;
    label subject = 'Subject ID';
    subject = strip(site_id)||'-'||subid;
    drop site_id subid;
%mend subject;



%macro ageint(RFSTDTC=, BRTHDTC=, AGE=);
   __RFSTDTC = &RFSTDTC;
   __BRTHDTC = &BRTHDTC;
   if __RFSTDTC ^= '' and length(compress(__RFSTDTC)) = 10 and __BRTHDTC ^= '' and 
    length(compress(__BRTHDTC)) = 10 then
      &AGE._=int((input(substr(__RFSTDTC, 1, 10), yymmdd10.) - input(substr(__BRTHDTC, 1, 10), yymmdd10.) + 1)/365.25);
    %char(var=&AGE._,newvar=&AGE);
    drop __RFSTDTC __BRTHDTC &AGE._;
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
