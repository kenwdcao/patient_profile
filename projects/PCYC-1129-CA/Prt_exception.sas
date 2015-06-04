/********************************************************************************
 Program Nmae: prt_exception.sas
  @Author: 
  @Initial Date: 2015/05/04
 
 Interface to let user alter proc report statements.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/

%macro prt_exception();
%if %upcase(&dset) = AE3 %then %do;
    define aenum /    style(column) = [width=5%];
    define _AETERM /  style(column) = [width=15%];

    define AEACNI02 / style(column) = [width=6%];
    define AEACNI03 / style(column) = [width=5%];
    define AEACNI04 / style(column) = [width=6%];
    define AEACNI05 / style(column) = [width=6%];
    define AEACNI06 / style(column) = [width=6%];

    define AEACNO02 / style(column) = [width=6%];
    define AEACNO03 / style(column) = [width=6%];
    define AEACNO04 / style(column) = [width=7%];
    define AEACNO05 / style(column) = [width=6%];
    define AEACNO01 / style(column) = [width=6%];

    define aeacnoth / style(column) = [width=15%];
%end;
%else %if %upcase(&dset) = PE3 %then %do; 
    define visit2 / style(column) = [width=10%];
%end;
%mend prt_exception;
