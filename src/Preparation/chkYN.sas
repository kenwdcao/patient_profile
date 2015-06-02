/*********************************************************************
 Program Nmae: chYN.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/



%macro chkYN(mvar, mval, default);

%local blank;
%let blank =;

%let mval = %upcase(&mval);
%let &mvar = %upcase(&mval);

%if "&mval" = "YES" %then %do;
    %let &mvar = Y;
    %let mval = Y;
%end;
%else %if "&mval" = "NO" %then %do;
    %let &mvar = N;
    %let mval = N;
%end;

%if "&mval" ^= "N" and "&mval" ^= "Y" %then %do;
    %put WARN&blank.ING: %UPCASE(&mvar): Invalid value: &mval . Assigning default value &default to %upcase(&mvar);
    %let &mvar = &default;
%end;

%mend chkYN;
